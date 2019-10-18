#include 'protheus.ch'
#include 'parmtype.ch'

//#################
//# Programa      # MT100GE2
//# Data          # 17/11/2017
//# Descrição     # Ponto de entrada para atualizar numero
//#				  #	cosmos titulo 
//# Desenvolvedor # Edie Carlos
//# Empresa       # Totvs Nacoes Unidas
//# Linguagem     # eAdvpl     
//# Versão        # 12
//# Sistema       # Protheus
//# Módulo        # Financeiro
//# Tabelas       # "SE2"
//# Observação    #  
//#===============#
//# Atualizações  # 
//#===============#
//#################

user function MT100GE2()

/*
SE2->(DbSelectArea("SE2"))
SE2->(RecLock("SE2"))
SE2->E2_XNUMID := SC7->C7_XNUMID
SE2->(MsUnLock())
*/	
	
return