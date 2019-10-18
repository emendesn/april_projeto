#include "protheus.ch"

//#################
//# Programa      # MTA140MNU
//# Data          # 28/04/2017
//# Descrição     # Ponto de Entrada para adição de menus no rotina pré-nota
//# Desenvolvedor # Elias dos Santos
//# Empresa       # Totvs Nacoes Unidas
//# Linguagem     # eAdvpl     
//# Versão        # 12
//# Sistema       # Protheus
//# Módulo        # Financeiro
//# Tabelas       # 
//# Observação    # Usado para adição de menu para rotina de importação de nfse 
//#===============#
//# Atualizações  # 
//#===============#
//#################

User Function MTA140MNU()

aAdd(aRotina,{ "Importar XMLs", "U_IMPNFSE", 0 , 2, 0, .F.})  

Return