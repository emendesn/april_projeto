#include "protheus.ch"

//#################
//# Programa      # FA080CAN
//# Data          # 05/11/2018
//# Descrição     # Ponto de Entrada após gravação do cancelamento da baixa 
//# Desenvolvedor # Washington Miranda Leao
//# Empresa       # Totvs Nacoes Unidas
//# Linguagem     # eAdvpl     
//# Versão        # 12
//# Sistema       # Protheus
//# Módulo        # Financeiro
//# Tabelas       # "SZ1", "SE2"
//# Observação    # Usado para gravação no middleware do cancelamento da baixa 
//#===============#
//# Atualizações  # 
//#===============#
//#################

User Function FA080CAN()

Local aArea := GetArea()
dbSelectArea("SZ1")
SZ1->(DbSetOrder(1))

If SZ1->(DbSeek(xFilial("SZ1")+PADR(SE2->E2_NUM,15) + SE2->E2_PARCELA))
	RecLock("SZ1",.F.)
	SZ1->Z1_VLRBX 	:= 0
	SZ1->Z1_DTBX	:= CTOD("  /  /  ")
	SZ1->Z1_CANC	:= "C"
	SZ1->Z1_DTCANC	:= dDataBase
	SZ1->Z1_HRCANC	:= Time()
	SZ1->Z1_USERC	:= Alltrim(UsrRetName(__CUSERID))
	SZ1->Z1_SLDTIT	:= SE2->E2_SALDO
	SZ1->(MsUnlock())
Endif

RestArea(aArea)


Return