#include "rwmake.ch"

//#################
//# Programa      # FA060QRY
//# Data          # 08/06/2017
//# Descri��o     # O ponto de entrada FA060QRY permite a inclus�o de uma condi��o adicional na consulta SQL (Query) de sele��o dos t�tulos a receber, para posterior marca��o em tela.
//#				  #	A condi��o adicionada deve seguir a sintaxe SQL e ir� interferir na sele��o dos t�tulos a receber que ser�o exibidos em tela..
//# Desenvolvedor # Elias dos Santos
//# Empresa       # Totvs Nacoes Unidas
//# Linguagem     # eAdvpl     
//# Vers�o        # 12
//# Sistema       # Protheus
//# M�dulo        # Financeiro
//# Tabelas       # "SE1"
//# Observa��o    # Usado para filtro do border� para exibir somente titulos que venham do Tavola 
//#===============#
//# Atualiza��es  # 
//#===============#
//#################

User Function FA060QRY()
Local cRet := ""// Expressao SQL de filtro que sera adicionada a clausula WHERE da Query.

cRet := " E1_NUMBCO <>'' " //" LTRIM(RTRIM(E1_NUMBCO)) <> '' "

Return cRet