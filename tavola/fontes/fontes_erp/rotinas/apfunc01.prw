#include 'protheus.ch'
#include 'parmtype.ch'


//#################
//# Programa      # APFUNC01
//# Data          # 17/11/2017
//# Descri��o     # Gatilho para informar rotina tabela SZ9
//# Desenvolvedor # Edie Carlos
//# Empresa       # Totvs Nacoes Unidas
//# Linguagem     # eAdvpl     
//# Vers�o        # 12
//# Sistema       # Protheus
//# M�dulo        # Financeiro
//# Tabelas       # "SZ9"
//# Observa��o    #  
//#===============#
//# Atualiza��es  # 
//#===============#
//#################


user function APFUNC01(cTipo)
Local cRet:= ""


	Do Case
		
		Case M->Z9_TIPO == "PV"
		cRet :="MATA410"
		Case M->Z9_TIPO == "PC"
		cRet := "MATA120"
		Case M->Z9_TIPO == "CR"
		cRet := "FINA040"
		Case M->Z9_TIPO == "CP"
		cRet := "FINA050"
		
	EndCase

return(cRet)