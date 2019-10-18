#include 'protheus.ch'
#include 'parmtype.ch'

User Function F240FIL()

	Local cRet := ""
	Local aArea:= GetArea() 
	Local aPergs   := {}
	Local aRet	   := {}

	If MsgYesNo( 'Deseja Filtrar o Bordero?', 'April Brasil' )
		aAdd( aPergs ,{1,"Escolha o Banco",space(8),"@!",,"SA6",'.T.',8,.T.})
		aAdd( aPergs ,{1,"Escolha o Prefixo",space(8),"@!",,"",'.T.',8,.T.})
		aAdd( aPergs ,{3,"Pagamento no mesmo Banco?",1,{"Sim","Não"},50,"",.F.})


		If ParamBox(aPergs ,"Filtro do Bordero",aRet)
			If aRet[3] == 1
				cRet := "( (cAliasSE2)->E2_PREFIXO == '"+Alltrim(aRet[2])+"' .AND. Posicione('SA2',1,xFilial('SA2')+(cAliasSE2)->E2_FORNECE+(cAliasSE2)->E2_LOJA,'A2_BANCO') == '"+Alltrim(aRet[1])+"' ) "
			Else
				cRet := "( (cAliasSE2)->E2_PREFIXO == '"+Alltrim(aRet[2])+"' .AND. Posicione('SA2',1,xFilial('SA2')+(cAliasSE2)->E2_FORNECE+(cAliasSE2)->E2_LOJA,'A2_BANCO') <> '"+Alltrim(aRet[1])+"' ) "
			Endif
		EndIf
	Else
		cRet:= ""
	Endif
	RestArea(aArea) 

Return cRet