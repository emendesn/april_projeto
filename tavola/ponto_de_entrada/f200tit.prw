#include "protheus.ch"

//#################
//# Programa      # F200TIT
//# Data          #  2017
//# Descrição     # Ponto de Entrada após gravação da baixa do retorno do cnab.
//# Desenvolvedor #  
//# Empresa       # Totvs Nacoes Unidas
//# Linguagem     # eAdvpl     
//# Versão        # 12
//# Sistema       # Protheus
//# Módulo        # Financeiro
//# Tabelas       # "SZ1", "SE1"
//# Observação    # Usado para gravação no middleware das informações da baixa 
//#===============#
//# Atualizações  # 
//#===============#
//#################


User Function F200TIT()

Local aArea := GetArea()

SZ1->(DbSetOrder(2))

If SZ1->(DbSeek(xFilial("SZ1")+SE1->E1_NUMBCO))
	RecLock("SZ1",.F.)
	SZ1->Z1_VLRBX 	:= SE1->E1_VALLIQ
	SZ1->Z1_DTBX	:= SE1->E1_BAIXA
	SZ1->Z1_USRBX	:= Alltrim(UsrRetName(__CUSERID)) 
	SZ1->Z1_SLDTIT	:= SE1->E1_SALDO
	SZ1->(MsUnlock())
Endif

RestArea(aArea)

Return
