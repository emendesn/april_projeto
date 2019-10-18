#INCLUDE "PROTHEUS.CH"

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �M020INC   �Autor                                            ���
�������������������������������������������������������������������������͹��
���Desc.     �  Importa o cadastro dos Cliente para o Item Cont�bil       ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       �                                                            ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/


User Function M030Inc()
DbSelectarea("CTD")
CTD->(DbSetOrder(1)) // CTD_FILIAL + CTD_ITEM
If CTD->(!DbSeek(xFilial("CTD") + "C" + ALLTRIM(SA1->A1_COD) + ALLTRIM(SA1->A1_LOJA) ))
	RecLock("CTD",.T.)
		CTD->CTD_FILIAL := xFilial("CTD")
		CTD->CTD_ITEM := "C" + ALLTRIM(SA1->A1_COD) + ALLTRIM(SA1->A1_LOJA)
		CTD->CTD_CLASSE := "2"
		CTD->CTD_DESC01 := ALLTRIM(SA1->A1_NOME)
		CTD->CTD_DTEXIS := CTOD("01/01/1980")
		CTD->CTD_BLOQ 	:= "2"
	CTD->(MsUnlock())
	
	RecLock("SA1",.F.)
		SA1->A1_XITEMCT := "C" + ALLTRIM(SA1->A1_COD) + ALLTRIM(SA1->A1_LOJA)
	SA1->(MsUnlock())	
EndIf
u_AprEnvBLC()
Return()


//Para manuten��o do registro ja existentes.
User Function M030X()  // U_M030X()      

Private _aArea	:= GetArea()
Private _cQuery := " "
          
_cQuery :=	" SELECT *, R_E_C_N_O_  "
_cQuery +=	" FROM "+RETSQLNAME("SA1")+" "
_cQuery +=	" WHERE D_E_L_E_T_ = '' "

dbUseArea(.T.,"TOPCONN",TCGENQRY(,,_cQuery),"QUERY",.F.,.T.)
                                     
dbSelectArea("QUERY")
Do While !QUERY->(Eof())

	DbSelectarea("CTD")
	CTD->(DbSetOrder(1)) // CTD_FILIAL + CTD_ITEM
	If CTD->(!DbSeek(xFilial("CTD") + "C" + ALLTRIM(QUERY->A1_COD) + ALLTRIM(QUERY->A1_LOJA) ))
		RecLock("CTD",.T.)
			CTD->CTD_FILIAL := xFilial("CTD")
			CTD->CTD_ITEM 	:= "C" + ALLTRIM(QUERY->A1_COD) + ALLTRIM(QUERY->A1_LOJA)
			CTD->CTD_CLASSE := "2"
			CTD->CTD_DESC01 := ALLTRIM(QUERY->A1_NOME)
			CTD->CTD_DTEXIS := CTOD("01/01/1980")
			CTD->CTD_BLOQ 	:= "2"
		CTD->(MsUnlock())
	EndIf
	
	DbSelecArea("SA1")
	DbSetOrder(1)
	DbGoTo(QUERY->R_E_C_N_O_)
 	RecLock("SA1",.F.)
 		SA1->A1_XITEMCT := "C" + ALLTRIM(QUERY->A1_COD) + ALLTRIM(QUERY->A1_LOJA)
 	SA1->(MsUnlock())	
	
QUERY->(dbSkip())                                                     
EndDo 
QUERY->(DBCLOSEAREA())
                   
//MsgAlert("OK, Cadastrado Item Contabil ","Aten��o")
                                                          	
RestArea(_aArea)
Return(.T.)

