#INCLUDE "PROTHEUS.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³M020INC   ºAutor                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³  Importa o cadastro dos fornecedores para o Item Contábil  º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³                                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/


User Function M020Inc()
	DbSelectarea("CTD")
	CTD->(DbSetOrder(1)) // CTD_FILIAL + CTD_ITEM
	If CTD->(!DbSeek(xFilial("CTD") + "F" + ALLTRIM(SA2->A2_COD) + ALLTRIM(SA2->A2_LOJA) ))
		RecLock("CTD",.T.)
		CTD->CTD_FILIAL := xFilial("CTD")
		CTD->CTD_ITEM 	:= "F" + ALLTRIM(SA2->A2_COD) + ALLTRIM(SA2->A2_LOJA) 
		CTD->CTD_CLASSE := "2"
		CTD->CTD_DESC01 := ALLTRIM(SA2->A2_NOME)
		CTD->CTD_DTEXIS := CTOD("01/01/1980")
		CTD->CTD_BLOQ 	:= "2" 
		CTD->(MsUnlock())

		RecLock("SA2",.F.)
		SA2->A2_XITEMCT := "F" + ALLTRIM(SA2->A2_COD) + ALLTRIM(SA2->A2_LOJA)
		SA2->(MsUnlock())
	EndIf
	//U_AprEnvF2()
Return()


//Para manutenção do registro ja existentes.
User Function M020X()  // U_M020X()      

	Private _aArea	:= GetArea()
	Private _cQuery := " "

	_cQuery :=	" SELECT * "
	_cQuery +=	" FROM "+RETSQLNAME("SA2")+" "
	_cQuery +=	" WHERE D_E_L_E_T_ = '' AND A2_XITEMCT = ''"

	dbUseArea(.T.,"TOPCONN",TCGENQRY(,,_cQuery),"QUERY",.F.,.T.)

	dbSelectArea("QUERY")
	Do While !QUERY->(Eof())

		DbSelectarea("CTD")
		CTD->(DbSetOrder(1)) // CTD_FILIAL + CTD_ITEM
		If CTD->(!DbSeek(xFilial("CTD") + "F" + ALLTRIM(QUERY->A2_COD) + ALLTRIM(QUERY->A2_LOJA) ))
			RecLock("CTD",.T.)
			CTD->CTD_FILIAL := xFilial("CTD")
			CTD->CTD_ITEM 	:= "F" + ALLTRIM(QUERY->A2_COD) + ALLTRIM(QUERY->A2_LOJA) 
			CTD->CTD_CLASSE := "2"
			CTD->CTD_DESC01 := ALLTRIM(QUERY->A2_NOME)
			CTD->CTD_DTEXIS := CTOD("01/01/1980")
			CTD->CTD_BLOQ 	:= "2" 
			CTD->(MsUnlock())

			DbSelecArea("SA2")
			DbSetOrder(1)
			DbGoTo(QUERY->R_E_C_N_O_)
			RecLock("SA2",.F.)
			SA2->A2_XITEMCT := "F" + ALLTRIM(QUERY->A2_COD) + ALLTRIM(QUERY->A2_LOJA)
			SA2->(MsUnlock())
			//Caso tenha achado e o campo esteja em branco.
		Else
			RecLock("SA2",.F.)
			SA2->A2_XITEMCT := "F" + ALLTRIM(QUERY->A2_COD) + ALLTRIM(QUERY->A2_LOJA)
			SA2->(MsUnlock())
		EndIf


		QUERY->(dbSkip())                                                     
	EndDo 
	QUERY->(DBCLOSEAREA())

	MsgAlert("OK, Cadastrado Item Contabil ","Atenção")
	
	RestArea(_aArea)
Return(.T.)

