#include "protheus.ch"
#include "rwmake.ch"

//#################
//# Programa      # F90SE5GRV
//# Data          #  2017
//# Descri��o     # Ponto de Entrada ap�s grava��o da baixa automatica
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

User Function F90SE5GRV()
/*
Reclock("SE5",.F.)
SE5->E5_XNUMID := SE2->E2_XNUMID
SE5->(MsUnlock())
*/
Return