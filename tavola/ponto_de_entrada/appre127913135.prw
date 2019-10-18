#include "protheus.ch"

//#################   
//# Programa      # FA070CAN
//# Data          # /2017
//# Descrição     # Ponto de Entrada após gravação do cancelamento da baixa 
//# Desenvolvedor #  
//# Empresa       # Totvs Nacoes Unidas
//# Linguagem     # eAdvpl     
//# Versão        # 12
//# Sistema       # Protheus
//# Módulo        # Financeiro
//# Tabelas       # "SZ1", "SE1"
//# Observação    # Usado para gravação no middleware do cancelamento da baixa 
//#===============#
//# Atualizações  # 
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
