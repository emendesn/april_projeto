#include 'protheus.ch'
#include 'parmtype.ch'
#include 'topconn.ch'

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �NOVO5     �Autor  �Thiago Rocco        � Data �  04/24/19   ���
�������������������������������������������������������������������������͹��
���Desc.     � Rotina para preenchido do campo E2_XNOMUSER                ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � Especifico                                                 ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

User Function ACELGI()

	Local aArea := GetArea()

	cQuery := " SELECT R_E_C_N_O_ AS REC,E2_USERLGI  FROM "+RetSQlName("SE2")+"  WHERE E2_XNOMUSE = '' AND E2_USERLGI <> '' "
	cQuery := ChangeQuery(cQuery)
	If Select("TRB2") <> 0
		dbSelectArea("TRB2")
		dbCloseArea()
	EndIf

	TCQuery cQuery New Alias "TRB2"

	While TRB2->(!Eof())

		cQuery := " UPDATE "+RetSQlName("SE2")+" SET E2_XNOMUSE='"+Alltrim(FWLeUserlg("TRB2->E2_USERLGI",1))+"'"
		cQuery += " WHERE R_E_C_N_O_="+Alltrim(Str(TRB2->REC))+" AND D_E_L_E_T_<>'*'"
		Alert(cQuery)
		If TCSQLExec(cQuery) < 0
			MsgStop( "TCSQLError() " + TCSQLError(), 'Fast' )
		EndIf

		TRB2->(DbSkip())
	End

	MsgInfo( 'Processo Finalizado', 'Fast' )
	RestArea(aArea)
Return