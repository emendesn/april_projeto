#include "protheus.ch"

//#################
//# Programa      # FINA110
//# Data          # 05/11/2018  
//# Descrição     # Ponto de Entrada após gravação da baixa automatica(Contabilização da baixa automática)
//# Desenvolvedor # Washington Miranda Leao
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