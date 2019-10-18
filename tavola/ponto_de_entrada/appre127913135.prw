#include "protheus.ch"

//#################   
//# Programa      # FA070CAN
//# Data          # /2017
//# Descri��o     # Ponto de Entrada ap�s grava��o do cancelamento da baixa 
//# Desenvolvedor #  
//# Empresa       # Totvs Nacoes Unidas
//# Linguagem     # eAdvpl     
//# Vers�o        # 12
//# Sistema       # Protheus
//# M�dulo        # Financeiro
//# Tabelas       # "SZ1", "SE1"
//# Observa��o    # Usado para grava��o no middleware do cancelamento da baixa 
//#===============#
//# Atualiza��es  # 
//#===============#
//#################

User Function FA070CAN()

Local aArea := GetArea()

dbSelectArea("SZ1")
SZ1->(DbSetOrder(1))

If SZ1->(DbSeek(xFilial("SZ1")+SE1->E1_XFATURA + SE1->E1_PARCELA))
	RecLock("SZ1",.F.)
	SZ1->Z1_VLRBX 	:= 0
	SZ1->Z1_DTBX	:= CTOD("  /  /  ")
	SZ1->Z1_USRBX	:= ""
	SZ1->Z1_CANC	:= "C"
	SZ1->Z1_DTCANC	:= dDataBase
	SZ1->Z1_HRCANC	:= Time()
	SZ1->Z1_USERC	:= Alltrim(UsrRetName(__CUSERID))
	SZ1->Z1_SLDTIT	:= SE1->E1_SALDO
	SZ1->Z1_STATTP	:= ''
	SZ1->(MsUnlock())
Endif

RestArea(aArea)


Return
