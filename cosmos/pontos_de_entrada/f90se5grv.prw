#include "protheus.ch"
#include "rwmake.ch"

//#################
//# Programa      # F90SE5GRV
//# Data          #  2017
//# Descrição     # Ponto de Entrada após gravação da baixa automatica
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

User Function F90SE5GRV()
/*
Reclock("SE5",.F.)
SE5->E5_XNUMID := SE2->E2_XNUMID
SE5->(MsUnlock())
*/
Return