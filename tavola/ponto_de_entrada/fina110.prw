#include "protheus.ch"

//#################
//# Programa      # FINA110
//# Data          # 05/11/2018  
//# Descri��o     # Ponto de Entrada ap�s grava��o da baixa automatica(Contabiliza��o da baixa autom�tica)
//# Desenvolvedor # Washington Miranda Leao
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


User Function FINA110()
Local aArea := GetArea()

dbSelectArea("SZ1")
SZ1->(DbSetOrder(1))

If SZ1->(DbSeek(xFilial("SZ1")+SE1->E1_XFATURA+SE1->E1_PARCELA))
	RecLock("SZ1",.F.)
	SZ1->Z1_VLRBX 	:= SE1->E1_VALLIQ
	SZ1->Z1_DTBX	:= SE1->E1_BAIXA
	SZ1->Z1_USRBX	:= Alltrim(UsrRetName(__CUSERID)) 
	SZ1->Z1_SLDTIT	:= SE1->E1_SALDO
	SZ1->(MsUnlock())
Endif

RestArea(aArea)

Return