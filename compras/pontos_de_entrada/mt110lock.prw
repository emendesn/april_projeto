#include 'protheus.ch'
#include 'parmtype.ch'
#include 'Topconn.ch'

User Function MT110LOK()

	// Declara��o de variaveis
	Local _lRet	:= .T.
/*
	// Busca posi��o do campos
	Local _nPosBdg	:= aScan(aHeader,{|x| AllTrim(x[2]) == 'C1_BUDGET'})
	Local _nPosProj := aScan(aHeader,{|x| AllTrim(x[2]) == 'C1_PRJBDGT'})
	Local _nPosNes	:= aScan(aHeader,{|x| AllTrim(x[2]) == 'C1_DATPRF'})

	cQuery :=" SELECT Z98_MES"+Alltrim(AlltoChar(Month(aCols[n][_nPosNes])))+" AS VALOR,Z98_RESP FROM "+RetSQlName("Z98")+" "
	cQuery +=" WHERE Z98_LINHA = '"+aCols[n][_nPosBdg]+"'"
	cQuery +=" AND Z98_EXERC = '"+Alltrim(AlltoChar(Year(aCols[n][_nPosNes])))+"'"
	cQuery +=" AND Z98_PROJET =  '"+Alltrim(AlltoChar(aCols[n][_nPosProj]))+"'"
	cQuery +=" AND D_E_L_E_T_<>'*'"

	If Select("TRB") <> 0
		dbSelectArea("TRB")
		dbCloseArea()
	EndIf

	TCQuery cQuery New Alias "TRB"

	// Valida��o a ser executada
	If TRB->VALOR <= 0
		MsgStop("O Respons�vel: "+Alltrim(TRB->Z98_RESP)+","+Chr(13)+chr(10)+"N�o possui or�amento para o m�s/ano de: "+Alltrim(AlltoChar(MesExtenso(aCols[n][_nPosNes])))+"/"+Alltrim(AlltoChar(Year(aCols[n][_nPosNes])))	,"A T E N � � O !!")
		_lRet := .F. // Quando false o sistema n�o permitir� que o usu�rio prossiga para a proxima linha
	EndIf*/
Return _lRet