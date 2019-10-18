#INCLUDE "PROTHEUS.CH"

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±ºPrograma  ³MORA()   ºAutor  ³Eduardo Augusto      º Data ³  14/06/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ FONTE DESENVOLVIDO PARA CALCULO DE JUROS MORA/DIA,         º±±
±±º          ³ CONFORME LAYOUT CNAB ITAU COBRANÇA. (POSICOES 161 A 173)   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Expressa Distribuidora de Medicamentos Ltda                º±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

User Function MULTA()
Local _nMulta 	:= 0
Local _cBanco	:= SEE->EE_CODIGO
Local _cAgencia	:= SEE->EE_AGENCIA
Local _cConta	:= SEE->EE_CONTA	
DbSelectArea("SEE")       
Dbsetorder(1)
Dbseek(xfilial("SEE")+_cBanco+_cAgencia+_cConta+"R")                     
If _cBanco=="341"
	_nMulta := Padl( Alltrim(StrTran(Transform(((SE1->E1_VALOR*SEE->EE_MULTA)/100),"@E 99,999,999.99"),",","")), 13, "0" )
ElseIf _cBanco=="001"
	_nMulta := Padl( Alltrim(StrTran(Transform(((SE1->E1_VALOR*SEE->EE_MULTA)/100),"@E 99,999,999.99"),",","")), 15, "0" )
Else                                                                                                                        
	_nMulta := Padl( Alltrim(StrTran(Transform(((SE1->E1_VALOR*SEE->EE_MULTA)/100),"@E 99,999,999.99"),",","")), 13, "0" )
EndIf
Return _nMulta