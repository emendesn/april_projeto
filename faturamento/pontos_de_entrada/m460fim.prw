#Include "Protheus.ch"
#INCLUDE "MSOBJECT.CH"
#INCLUDE "TBICONN.CH"   

/* http://tdn.totvs.com/kbm#19489
* Ponto de Entrada - Gravação da NF saida
* Este P.E. e' chamado apos a Gravacao da NF de Saida, e fora da transação.
*/

User Function M460FIM()
	/*
	Local cChaveE1
	Local aArray := {}
	Private lMsErroAuto := .F.

	// Copia dos dados de exportação
	RecLock("SF2",.F.)
	SF2->F2_UFEMBEX := SC5->C5_UFEMBEX
	SF2->F2_LCEMBEX := SC5->C5_LCEMBEX
	// Copia dos dados de garantia
	SF2->F2_DTGAR	:= SC5->C5_DTGAR
	// Copia do Contrato de Venda - #35048

	SF2->F2_CRTVEND	:= SC5->C5_CRTVEND
	MsUnlock()

	//Atualização dos dados de Premio / Comissao
	cChaveE1 := xFilial("SE1") + SF2->F2_CLIENTE + SF2->F2_LOJA + SF2->F2_SERIE + SF2->F2_DOC

	dbSelectArea("SE1")
	dbSetOrder(2)
	dbGoTop()
	if SE1->(dbSeek(cChaveE1))
		while SE1->(!eof()) .And. (E1_FILIAL + E1_CLIENTE + E1_LOJA + E1_PREFIXO + E1_NUM) == cChaveE1
			RecLock("SE1",.F.)				
			SE1->E1_XPREMIO := SC5->C5_CRTVEND
			SE1->E1_XFATURA := SC5->C5_CRTVEND
			MsUnlock()
			SE1->(dbSkip())
		enddo
	endif

	dbCloseArea("SE1")

	//Criação do ExecAuto de Premio

	If XXXX > 0
		aAdd(aArray,{ "E2_PREFIXO" , "ND" , NIL })
		aAdd(aArray,{ "E2_NUM" , "0001" , NIL })
		aAdd(aArray,{ "E2_TIPO" , "PA" , NIL })
		aAdd(aArray,{ "E2_NATUREZ" , "001" , NIL })
		aAdd(aArray,{ "E2_FORNECE" , "0001" , NIL })
		aAdd(aArray,{ "E2_EMISSAO" , CtoD("17/02/2012"), NIL })
		aAdd(aArray,{ "E2_VENCTO" , CtoD("17/02/2012"), NIL })
		aAdd(aArray,{ "E2_VENCREA" , CtoD("17/02/2012"), NIL })
		aAdd(aArray,{ "E2_VALOR" , 5000 , NIL })
		aAdd(aArray,{ "AUTBANCO" , "001" , NIL })
		aAdd(aArray,{ "AUTAGENCIA" , "12345" , NIL })
		aAdd(aArray,{ "AUTCONTA" , "0000012345" , NIL })

		MsExecAuto( { |x,y,z| FINA050(x,y,z)}, aArray,, 3) // 3 - Inclusao, 4 - Alteração, 5 - Exclusão


		If lMsErroAuto
			MostraErro()
		Else
			Alert("Título de adiantamento incluído com sucesso!")
		Endif

	Endif

	//Criação do ExecAuto de Pedido de compras de comissao, no caso do Tipo Cartão

	If XXXX > 0
		aAdd(aArray,{ "E2_PREFIXO" , "ND" , NIL })
		aAdd(aArray,{ "E2_NUM" , "0001" , NIL })
		aAdd(aArray,{ "E2_TIPO" , "PA" , NIL })
		aAdd(aArray,{ "E2_NATUREZ" , "001" , NIL })
		aAdd(aArray,{ "E2_FORNECE" , "0001" , NIL })
		aAdd(aArray,{ "E2_EMISSAO" , CtoD("17/02/2012"), NIL })
		aAdd(aArray,{ "E2_VENCTO" , CtoD("17/02/2012"), NIL })
		aAdd(aArray,{ "E2_VENCREA" , CtoD("17/02/2012"), NIL })
		aAdd(aArray,{ "E2_VALOR" , 5000 , NIL })
		aAdd(aArray,{ "AUTBANCO" , "001" , NIL })
		aAdd(aArray,{ "AUTAGENCIA" , "12345" , NIL })
		aAdd(aArray,{ "AUTCONTA" , "0000012345" , NIL })

		MsExecAuto( { |x,y,z| FINA050(x,y,z)}, aArray,, 3) // 3 - Inclusao, 4 - Alteração, 5 - Exclusão


		If lMsErroAuto
			MostraErro()
		Else
			Alert("Título de adiantamento incluído com sucesso!")
		Endif

	Endif

*/
Return
