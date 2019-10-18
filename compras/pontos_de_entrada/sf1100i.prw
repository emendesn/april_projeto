#include 'protheus.ch'
#include 'parmtype.ch'
#include 'Topconn.ch'

User Function SF1100I()

	Local _lRet   := .T. 
	Local cQuery  := ""
	Local cNomFor := Substr(Alltrim(Posicione("SA2",1,xFilial("SA2")+SF1->F1_FORNECE+SF1->F1_LOJA,"A2_NOME")),1,TAMSX3("F1_NOMEFOR")[1])

	cQuery := " UPDATE "+RetSQlName("SF1")+" SET F1_NOMEFOR='"+StrTran(cNomFor,"'","")+"'"
	cQuery += " WHERE F1_FORNECE='"+SF1->F1_FORNECE+"' AND F1_LOJA='"+SF1->F1_LOJA+"' AND D_E_L_E_T_<>'*'"

	If TCSQLExec(cQuery) < 0
		MsgStop( "TCSQLError() " + TCSQLError(), 'April Brasil' )
		Return( .F. )
	EndIf
	u_AceNome()

Return _lRet   


User Function AceNome()

	cQuery := " SELECT F1_FORNECE,F1_LOJA FROM "+RetSQlName("SF1")+" WHERE D_E_L_E_T_<>'*' AND F1_NOMEFOR='' GROUP BY F1_FORNECE,F1_LOJA"
	If Select("TRB2") <> 0
		dbSelectArea("TRB2")
		dbCloseArea()
	EndIf

	TCQuery cQuery New Alias "TRB2"

	While TRB2->(!Eof())

		cNomFor := Substr(Alltrim(Posicione("SA2",1,xFilial("SA2")+TRB2->F1_FORNECE+TRB2->F1_LOJA,"A2_NOME")),1,TAMSX3("F1_NOMEFOR")[1])
		cQuery := " UPDATE "+RetSQlName("SF1")+" SET F1_NOMEFOR='"+StrTran(cNomFor,"'","")+"'"
		cQuery += " WHERE F1_FORNECE='"+TRB2->F1_FORNECE+"' AND F1_LOJA='"+TRB2->F1_LOJA+"' AND D_E_L_E_T_<>'*'"

		If TCSQLExec(cQuery) < 0
			MsgStop( "TCSQLError() " + TCSQLError(), 'April Brasil' )
		EndIf

		TRB2->(DbSkip())
	End
	cQuery := " UPDATE "+RetSQlName("SN3")+" SET N3_FILIAL='0101'"

	If TCSQLExec(cQuery) < 0
		MsgStop( "TCSQLError() " + TCSQLError(), 'April Brasil' )
	EndIf

	TRB2->(DbSkip())


Return    

User Function CRIAFOR()

	Local aArea := GetArea()
	Local aDadosFor :={}
	//Variavel de Controle do MsExecAuto
	Private lMsErroAuto := .F.

	DbSelectArea("SA2")
	SA2->(DbSetOrder(3))

	cQuery := " SELECT * FROM "+RetSQlName("SRA")+" "
	cQuery += " WHERE RA_SITFOLH<>'D' AND D_E_L_E_T_<>'*' "
	cQuery += " ORDER BY RA_MAT"

	If Select("TRB") <> 0
		dbSelectArea("TRB")
		dbCloseArea()
	EndIf

	TCQuery cQuery New Alias "TRB"


	While TRB->(!Eof())

		aDadosFor := {}

		If !SA2->(DbSeek("SA2")+TRB->RA_CIC)

			AADD(aDadosFor,{"A2_COD",GETSXENUM("SA2","A2_COD")})                                                                                                      
			AADD(aDadosFor,{"A2_LOJA","01" })
			AADD(aDadosFor,{"A2_NOME", Substr(Alltrim(TRB->RA_NOMECMP),1,TAMSX3("A2_NOME")[1])})
			AADD(aDadosFor,{"A2_NREDUZ", Substr(Alltrim(TRB->RA_NOMECMP),1,TAMSX3("A2_NREDUZ")[1])})
			AADD(aDadosFor,{"A2_END",Alltrim(TRB->RA_ENDEREC)+", "+Alltrim(TRB->RA_NUMENDE)+" "+Alltrim(TRB->RA_COMPLEM)})
			AADD(aDadosFor,{"A2_BAIRRO ",TRB->RA_BAIRRO})
			AADD(aDadosFor,{"A2_EST ", TRB->RA_ESTADO})
			AADD(aDadosFor,{"A2_MUN", TRB->RA_MUNICIP})
			AADD(aDadosFor,{"A2_CEP", TRB->RA_CEP})
			AADD(aDadosFor,{"A2_CGC", TRB->RA_CIC})
			AADD(aDadosFor,{"A2_TIPO","F"})
			AADD(aDadosFor,{"A2_CONTA", "2110020001"   })       
			AADD(aDadosFor,{"A2_DDD", TRB->RA_DDDFONE	})	
			AADD(aDadosFor,{"A2_TEL", TRB->RA_TELEFON})
			AADD(aDadosFor,{"A2_INSCR ", "ISENTO"})
			AADD(aDadosFor,{"A2_EMAIL ", Substr(Alltrim(TRB->RA_EMAIL),1,TAMSX3("A2_EMAIL")[1])})
			AADD(aDadosFor,{"A2_BANCO ", Substr(TRB->RA_BCDEPSA,1,3)})
			AADD(aDadosFor,{"A2_AGENCIA ", Substr(TRB->RA_BCDEPSA,4,4)})
			AADD(aDadosFor,{"A2_NUMCON  ",Substr(TRB->RA_CTDEPSA,1,Len(Alltrim(TRB->RA_CTDEPSA))-1)})
			AADD(aDadosFor,{"A2_DVCTA",Right(Alltrim(TRB->RA_CTDEPSA),1)})
			AADD(aDadosFor,{"A2_DTNASC",StoD(TRB->RA_NASC)})
			AADD(aDadosFor,{"A2_CODNIT",SUBSTR(TRB->RA_PIS,1,TAMSX3("A2_CODNIT")[1])})
			AADD(aDadosFor,{"A2_CATEG",""})
			AADD(aDadosFor,{"A2_OCORREN",""})
			AADD(aDadosFor,{"A2_PFISICA",TRB->RA_RG})


			MsExecAuto({|x,y| MATA020(x,y)},aDadosFor, 3)		
			//Verifique se houve erro no MsExecAuto
			If (lMsErroAuto)

				cPath := "C:\TEMP" 
				cNomeArq := "Erro_MsExecAuto_MATA020.txt" 		
				//Mostra em Tela o Erro Ocorrido
				MostraErro(cPath, cNomeArq)		
			EndIf	
		Endif
		TRB->(DbSkip())
	End
	RestArea(aArea)
Return    

USER FUNCTION SF1DOC()
	If !Empty(M->F1_DOC) .Or. !Empty(cNFISCAL)
		M->F1_DOC := StrZero(Val(M->F1_DOC),9)
		CNFISCAL := M->F1_DOC
	Endif   
Return(.T.)
