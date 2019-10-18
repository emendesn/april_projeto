#include 'protheus.ch'
#include 'parmtype.ch'
#include 'topconn.ch'

user function MT160WF()
	Local aArea    := GetArea()
	Local aPedidos := {}
/*
	cQuery := " SELECT * "
	cQuery += " FROM "+RetSQLName("SC7")+" SC7"
	cQuery += " INNER JOIN "+RetSQLName("SC1")+" SC1 ON SC1.C1_COTACAO = SC7.C7_NUMCOT and SC7.C7_ITEM = SC1.C1_ITEM and SC7.C7_FILIAL = SC1.C1_FILIAL "
	cQuery += " WHERE C7_FILIAL = '"+xFilial("SC7")+"'  "
	cQuery += " AND C7_NUM = '"+SC7->C7_NUM+"' "
	cQuery += " AND SC7.D_E_L_E_T_<>'*' AND SC1.D_E_L_E_T_<>'*'  "


	If Select("TRB") <> 0
		dbSelectArea("TRB")
		dbCloseArea()
	EndIf

	TCQuery cQuery New Alias "TRB"
	//C1_CC,C1_BUDGET,C1_PRJBDGT,C1_DATPRF
	While TRB->(!Eof())

		cQuery :=" UPDATE "+RetSQlName("Z98")+" SET "
		cQuery +=" Z98_MES"+Alltrim(AlltoChar(Month(TRB->C1_DATPRF)))+" = Z98_MES"+Alltrim(AlltoChar(Month(TRB->C1_DATPRF)))+" - "+TRB->C7_TOTAL+"  "
		cQuery +=" WHERE Z98_LINHA = '"+TRB->C1_BUDGET+"'"
		cQuery +=" AND Z98_EXERC = '"+Alltrim(AlltoChar(Year(TRB->C1_DATPRF)))+"'"
		cQuery +=" AND Z98_PROJET =  '"+Alltrim(AlltoChar(TRB->C1_PRJBDGT))+"'"
		cQuery +=" AND D_E_L_E_T_<>'*'"

		If TCSQLExec(cQuery) < 0
			MsgStop( "TCSQLError() " + TCSQLError(), 'April Brasil' )
		EndIf
		TRB->(DbSkip())
	End*/
	
	MsDocument( "SC7", SC7->( RecNo() ), 3 )
	RestArea(aArea)

Return

User Function MT161OK()

	Local aPropostas := PARAMIXB[1,1] // Array contendo todos os dados da proposta da cotação
	Local cTpDoc := PARAMIXB[2] // Tipo do documento
	Local lContinua := .T.
/*
	For nX :=1 to Len(PARAMIXB[1,1])

		If PARAMIXB[1,1,nX,2,1,1] == .T.
		
			cQuery :=" SELECT Z98_MES"+Alltrim(AlltoChar(Month(SC1->C1_DATPRF)))+" AS VALOR,Z98_RESP FROM "+RetSQlName("Z98")+" "
			cQuery +=" WHERE Z98_LINHA = '"+SC1->C1_BUDGET+"'"
			cQuery +=" AND Z98_EXERC = '"+Alltrim(AlltoChar(Year(SC1->C1_DATPRF)))+"'"
			cQuery +=" AND Z98_PROJET =  '"+Alltrim(AlltoChar(SC1->C1_PRJBDGT))+"'"
			cQuery +=" AND D_E_L_E_T_<>'*'"
			
			//PARAMIXB[1,1,nX,2,1,4] = Valor Aprovado.
			
			
			If Select("TRB") <> 0
				dbSelectArea("TRB")
				dbCloseArea()
			EndIf

			TCQuery cQuery New Alias "TRB"

			// Validação a ser executada
			If TRB->VALOR < PARAMIXB[1,1,nX,2,1,4]
				MsgStop("O Responsável: "+Alltrim(TRB->Z98_RESP)+","+Chr(13)+chr(10)+"Não possui orçamento para o mês/ano de: "+Alltrim(AlltoChar(MesExtenso(SC1->C1_DATPRF)))+"/"+Alltrim(AlltoChar(Year(SC1->C1_DATPRF)))	,"A T E N Ç Ã O !!")
				lContinua := .F. // Quando false o sistema não permitirá que o usuário prossiga para a proxima linha
			EndIf

		Endif

	Next nX*/
	
	 

Return (lContinua)