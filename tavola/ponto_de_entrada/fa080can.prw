#include "protheus.ch"

//#################
//# Programa      # FA080CAN
//# Data          # 05/11/2018
//# Descri��o     # Ponto de Entrada ap�s grava��o do cancelamento da baixa 
//# Desenvolvedor # Washington Miranda Leao
//# Empresa       # Totvs Nacoes Unidas
//# Linguagem     # eAdvpl     
//# Vers�o        # 12
//# Sistema       # Protheus
//# M�dulo        # Financeiro
//# Tabelas       # "SZ1", "SE2"
//# Observa��o    # Usado para grava��o no middleware do cancelamento da baixa 
//#===============#
//# Atualiza��es  # 
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