#include "protheus.ch"

//#################
//# Programa      # FA110SE5
//# Data          #  
//# Descri��o     # Ponto de Entrada para grava��o de dados complementadores
//# Desenvolvedor # TF
//# Empresa       # Totvs Nacoes Unidas
//# Linguagem     # eAdvpl     
//# Vers�o        # 12
//# Sistema       # Protheus
//# M�dulo        # Financeiro
//# Tabelas       # "SE1", "SE5"
//# Observa��o    # Usado para grava��o no middleware das informa��es da baixa 
//#===============#
//# Atualiza��es  # 
//#===============#
//#################

User Function FA110SE5()
/*
Reclock("SE5",.F.)
SE5->E5_XNUMID := SE1->E1_XNUMID
SE5->(MsUnlock())
*/
Return