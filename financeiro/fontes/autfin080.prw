#include 'protheus.ch'
#include 'parmtype.ch'
#include 'topconn.ch'

user function AUTFIN080()
	Private lMsErroAuto := .F.

	cQuery := " SELECT * FROM "+RetSQlName("SE2")+" WHERE D_E_L_E_T_<>'*' "
	cQuery += " AND E2_SALDO > 0 AND E2_XDTBX ='"+DtoS(dDatabase)+"' AND E2_MOEDA <>'1' ORDER BY E2_XDTBX"
	If Select("TRB") <> 0
		dbSelectArea("TRB")
		dbCloseArea()
	EndIf

	TCQuery cQuery New Alias "TRB"

	While TRB->(!Eof())

		cHistBaixa := "BX Interncional"
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
		//³Monta array com os dados da baixa a pagar do título³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ 
		aBaixa := {}
		AADD(aBaixa, {"E2_FILIAL" , TRB->E2_FILIAL , Nil})
		AADD(aBaixa, {"E2_PREFIXO" , TRB->E2_PREFIXO , Nil})
		AADD(aBaixa, {"E2_NUM" , TRB->E2_NUM , Nil})
		AADD(aBaixa, {"E2_PARCELA" , TRB->E2_PARCELA , Nil})
		AADD(aBaixa, {"E2_TIPO" , TRB->E2_TIPO , Nil})
		AADD(aBaixa, {"E2_FORNECE" , TRB->E2_FORNECE , Nil})
		AADD(aBaixa, {"E2_LOJA" , TRB->E2_LOJA , Nil}) 
		AADD(aBaixa, {"AUTMOTBX" , "DAC" , Nil})
		AADD(aBaixa, {"AUTBANCO" , "ADV" , Nil})
		AADD(aBaixa, {"AUTAGENCIA" , "XXXXX" , Nil})
		AADD(aBaixa, {"AUTCONTA" , "XXXXXX" , Nil})
		AADD(aBaixa, {"AUTDTBAIXA" , stoD(TRB->E2_XDTBX) , Nil}) 
		AADD(aBaixa, {"AUTDTCREDITO", stoD(TRB->E2_XDTBX) , Nil})
		AADD(aBaixa, {"AUTHIST" , cHistBaixa , Nil})
		AADD(aBaixa, {"AUTVLRPG" , TRB->E2_VLCRUZ   , Nil})
		ACESSAPERG("FIN080", .F.)
		MSEXECAUTO({|x,y| FINA080(x,y)}, aBaixa, 3)

		If lMsErroAuto
			MOSTRAERRO() 
		EndIf 
		TRB->(DbSkip())
	End
Return