#Include 'Protheus.ch'
#Include 'FWMVCDef.ch'
#INCLUDE "RWMAKE.CH"
#INCLUDE "TOPCONN.CH"
#include 'parmtype.ch'
#include "totvs.ch"

//#################
//# Programa      # SE5FI080
//# Data          # 
//# Descri��o     # Ponto de Entrada para grava��o de dados complementadores
//# Desenvolvedor # TF
//# Empresa       # Totvs Nacoes Unidas
//# Linguagem     # eAdvpl     
//# Vers�o        # 12
//# Sistema       # Protheus
//# M�dulo        # Financeiro
//# Tabelas       # "SE2", "SE5"
//# Observa��o    # Usado para grava��o no middleware das informa��es da baixa 
//#===============#
//# Atualiza��es  # 
//#===============#
//#################

User Function SE5FI080()

Local cCamposE5 := ParamIxb 
Local cTeste := "TESTE"
cCamposE5 += ",{'' , '' }"

dbSelectArea("SZ1")
SZ1->(DbSetOrder(1))

If SZ1->(DbSeek(xFilial("SZ1")+PADR(SE2->E2_NUM,15) + SE2->E2_PARCELA))
	RecLock("SZ1",.F.)
	SZ1->Z1_VLRBX 	:= SE2->E2_VALLIQ
	SZ1->Z1_DTBX	:= SE2->E2_BAIXA
	SZ1->Z1_USRBX	:= Alltrim(UsrRetName(__CUSERID)) 
	SZ1->Z1_SLDTIT	:= (SE2->E2_VALLIQ - SZ1->Z1_VLRTO)
	SZ1->Z1_DTCANC	:= CTOD("  /  /  ")
	SZ1->Z1_HRCANC	:= ''
	SZ1->Z1_USERC	:= ''
	SZ1->Z1_STATT	:= ''
	SZ1->Z1_CANC	:= ''
	SZ1->(MsUnlock())
Endif


Return cCamposE5




