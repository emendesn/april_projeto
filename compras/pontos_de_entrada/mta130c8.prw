#include 'protheus.ch'
#include 'parmtype.ch'
#include 'Topconn.ch'

user function MT131WF()

	Local aArea := GetArea()
	Local cCotacao := PARAMIXB[1]
	Local aAreaC8 := SC8->(GetArea())
	Local aAreaC1 := SC1->(GetArea())
/*
	cQuery := " SELECT * FROM "+RetSqlName("SC8")+" WHERE D_E_L_E_T_<>'*' AND C8_NUM='"+PARAMIXB[1]+"'"
	If Select("TRB") <> 0
		dbSelectArea("TRB")
		dbCloseArea()
	EndIf

	TCQuery cQuery New Alias "TRB"

	While TRB->(!Eof())

		cQuery := " SELECT * FROM "+RetSqlName("SC1")+" WHERE D_E_L_E_T_<>'*' AND C1_NUM='"+TRB->C8_NUMSC+"' AND C1_ITEM='"+TRB->C8_ITEMSC+"' "
		If Select("TRB2") <> 0
			dbSelectArea("TRB2")
			dbCloseArea()
		EndIf

		TCQuery cQuery New Alias "TRB2"


		While TRB2->(!Eof())

			cQuery := " UPDATE "+RetSQlName("SC8")+" SET C8_CC='"+TRB2->C1_CC+"',C8_BUDGET ='"+TRB2->C1_BUDGET+"',C8_PRJBDGT ='"+TRB2->C1_PRJBDGT+"'"
			cQuery += " WHERE C8_NUM='"+TRB2->C1_COTACAO+"' AND C8_ITEMSC='"+TRB->C8_ITEM+"'"

			If TCSQLExec(cQuery) < 0
				MsgStop( "TCSQLError() " + TCSQLError(), 'April Brasil' )
			EndIf
			TRB2->(DbSkip())
		End

		TRB->(DbSkip())
	End


*/

	RestArea(aAreaC8)
	RestArea(aAreaC1)
	RestArea(aArea)

return