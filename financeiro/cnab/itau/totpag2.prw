#Include "rwmake.ch"

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±ºPrograma  ³TOTPAG2   ºAutor  ³Microsiga           º Data ³  28/08/17   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Programa para tratamento do Trailer de Lote de 			  º±±
±±º          ³ Impostos Modelo 16                                         º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³                                                            º±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

User Function Totpag2(nTipo)

Local _area := GetArea()
Local _cRet	:= 0
Local _cRet2:= 0
Local _cRet3:= 0
Local _cRet4:= 0
Local _cRet5:= 0
Local _Soma := nSomaVlLote
Local _Soma2:=0


DbSelectArea("SE2")
DBSetORder(15)
DBSeek(xFILIAL("SE2")+SEA->EA_NUMBOR)
Do While !eof() .And. xFILIAL("SE2")+SEA->EA_NUMBOR == SE2->e2_FILIAL + SE2->E2_NUMBOR
	_cRet +=SE2->E2_XJUROS
	_cRet2+=SE2->E2_ACRESC
	_cRet3+=SE2->E2_XMULTA
	_cRet4+=SE2->E2_DECRESC
	_cRet5+=SE2->E2_XOUTENT
	
	SE2->(dBSKIP())
EndDo

If nTipo == 1
	_Soma2:= Strzero(((_Soma-_cRet2-_cRet4-_cRet5)*100),14)
ElseIf nTipo == 2
	_Soma2:= Strzero((_cRet2*100),14)
ElseIf nTipo == 3
	_Soma2:= Strzero((_cRet3*100),14)
ElseIf nTipo == 4
	_Soma2:= Strzero((_cRet4*100),14)
ElseIf nTipo == 5
	_Soma2:= Strzero((_cRet5*100),14)
EndIf

RestArea(_area)

Return(_Soma2)
