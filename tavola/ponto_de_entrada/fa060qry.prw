#include "rwmake.ch"

//#################
//# Programa      # FA060QRY
//# Data          # 08/06/2017
//# Descrição     # O ponto de entrada FA060QRY permite a inclusão de uma condição adicional na consulta SQL (Query) de seleção dos títulos a receber, para posterior marcação em tela.
//#				  #	A condição adicionada deve seguir a sintaxe SQL e irá interferir na seleção dos títulos a receber que serão exibidos em tela..
//# Desenvolvedor # Elias dos Santos
//# Empresa       # Totvs Nacoes Unidas
//# Linguagem     # eAdvpl     
//# Versão        # 12
//# Sistema       # Protheus
//# Módulo        # Financeiro
//# Tabelas       # "SE1"
//# Observação    # Usado para filtro do borderô para exibir somente titulos que venham do Tavola 
//#===============#
//# Atualizações  # 
//#===============#
//#################

User Function FA060QRY()
Local cRet := ""// Expressao SQL de filtro que sera adicionada a clausula WHERE da Query.

cRet := " E1_NUMBCO <>'' " //" LTRIM(RTRIM(E1_NUMBCO)) <> '' "

Return cRet