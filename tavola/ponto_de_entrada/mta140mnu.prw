#include "protheus.ch"

//#################
//# Programa      # MTA140MNU
//# Data          # 28/04/2017
//# Descri��o     # Ponto de Entrada para adi��o de menus no rotina pr�-nota
//# Desenvolvedor # Elias dos Santos
//# Empresa       # Totvs Nacoes Unidas
//# Linguagem     # eAdvpl     
//# Vers�o        # 12
//# Sistema       # Protheus
//# M�dulo        # Financeiro
//# Tabelas       # 
//# Observa��o    # Usado para adi��o de menu para rotina de importa��o de nfse 
//#===============#
//# Atualiza��es  # 
//#===============#
//#################

User Function MTA140MNU()

aAdd(aRotina,{ "Importar XMLs", "U_IMPNFSE", 0 , 2, 0, .F.})  

Return