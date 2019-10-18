#include "protheus.ch"

//#################
//# Programa      # SACI008
//# Data          #   
//# Descrição     # Ponto de Entrada após gravação da baixa.
//# Desenvolvedor # TF
//# Empresa       # Totvs Nacoes Unidas
//# Linguagem     # eAdvpl     
//# Versão        # 12
//# Sistema       # Protheus
//# Módulo        # Financeiro
//# Tabelas       # "SZ1", "SE1"
//# Observação    # Usado para gravação no middleware das informações da baixa 
//#===============#
//# Atualizações  # SACI008 - Após gravação dos dados da baixa a receber
//#===============#
//#################


User Function SACI008()
Local aArea := GetArea()

/*
SZ1->(DbSetOrder(1))

If SZ1->(DbSeek(xFilial("SZ1")+SE1->E1_XFATURA + SE1->E1_PARCELA))
	RecLock("SZ1",.F.)
	SZ1->Z1_VLRBX 	:= SE1->E1_VALLIQ
	SZ1->Z1_DTBX	:= SE1->E1_BAIXA
	SZ1->Z1_USRBX	:= Alltrim(UsrRetName(__CUSERID)) 
	SZ1->Z1_SLDTIT	:= SE1->E1_SALDO
	SZ1->Z1_DTCANC	:= CTOD("  /  /  ")
	SZ1->Z1_HRCANC	:= ''
	SZ1->Z1_USERC	:= ''
	SZ1->Z1_STATT	:= ''
	SZ1->Z1_CANC	:= ''
	SZ1->(MsUnlock())
Endif

/*
// Gravar o numero do Middleware na SE5
SE5->(DbSetOder(7))
If SE5->(DbSeek(DbSeek(xFilial("SE1")+SE1->E1_FILIAL+E1_PREFIXO+SE1->E1_NUM+SE1->E1_PARCELA+;
		SE1->E1_TIPO+SE1->E1_CLIENTE+SE1->E1_LOJA)))
		
		While !SE5->(Eof()) .and. (SE1->E1_FILIAL == SE5->E5_FILIAL;
		 							.and. SE1->E1_PREFIXO == SE5->E5_PREFIXO;
		 							.and. SE1->E1_NUM == SE5->E5_NUMERO;
		 							.and. SE1->E1_PARCELA == SE5->E5_PARCELA;
		 							.and. SE1->E1_TIPO == SE5->E5_TIPO;
		 							.and. SE1->E1_CLIENTE == SE5->E5_CLIFOR;
		 							.and. SE1->E1_LOJA == SE5->E5_LOJA)
		 					
		 		Reclock("SE5",.F.)
		 		SE5->E5_XNUMID := SE1->E1_XNUMID			
		 		SE5->(MsUnlock())
		 		SE5->(DbSkip())
		End
Endif
*/
RestArea(aArea)
Return