#include "protheus.ch"

//#################
//# Programa      # F200TIT
//# Data          #  2017
//# Descri��o     # Ponto de Entrada ap�s grava��o da baixa do retorno do cnab.
//# Desenvolvedor #  
//# Empresa       # Totvs Nacoes Unidas
//# Linguagem     # eAdvpl     
//# Vers�o        # 12
//# Sistema       # Protheus
//# M�dulo        # Financeiro
//# Tabelas       # "SZ1", "SE1"
//# Observa��o    # Usado para grava��o no middleware das informa��es da baixa 
//#===============#
//# Atualiza��es  # 
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
