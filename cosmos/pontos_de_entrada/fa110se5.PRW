#include "protheus.ch"

//#################
//# Programa      # FA110SE5
//# Data          #  
//# Descrição     # Ponto de Entrada para gravação de dados complementadores
//# Desenvolvedor # TF
//# Empresa       # Totvs Nacoes Unidas
//# Linguagem     # eAdvpl     
//# Versão        # 12
//# Sistema       # Protheus
//# Módulo        # Financeiro
//# Tabelas       # "SE1", "SE5"
//# Observação    # Usado para gravação no middleware das informações da baixa 
//#===============#
//# Atualizações  # 
//#===============#
//#################

User Function FA110SE5()
/*
Reclock("SE5",.F.)
SE5->E5_XNUMID := SE1->E1_XNUMID
SE5->(MsUnlock())
*/
Return