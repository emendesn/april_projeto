#include "protheus.ch"

//#################
//# Programa      # A120SSER
//# Data          # 27/11/2017
//# Descri��o     # Ponto de Entrada para integra��o do PC com o SisConServ
//# Desenvolvedor # Sergio Compain
//# Empresa       # Totvs Nacoes Unidas
//# Linguagem     # eAdvpl     
//# Vers�o        # 12
//# Sistema       # Protheus
//# M�dulo        # Compras
//# Tabelas       # 
//# Observa��o    #  
//#===============#
//# Atualiza��es  # 
//#===============#
//#################


User Function A120SSER()

	Local cPedido	:= cA120Num
	Local xSeek     := ""
	Local xLinha    := {}

	aCab      := {}
	aItens    := {}

	dbSelectArea("SC7")
	dbSetOrder(1)
	/*
	If SC7->C7_MOEDA <> 1
		aadd(aCab,{"EJW_FILIAL",xFilial("SC7")		,Nil})
		aAdd(aCab,{"EJW_PROCES",cPedido   			,NIL})
		aAdd(aCab,{"EJW_ORIGEM","SIGACOM"			,NIL})

		If dbSeek(xSeek:=xFilial("SC7")+cPedido)
			//��������������������������������������������������������������������Ŀ
			//�Montagem do aCab (Array que contem o cabecalho do pedido de compras)|
			//����������������������������������������������������������������������
			aAdd(aCab,{"EJW_EXPORT",SC7->C7_FORNECE 	,NIL})
			aAdd(aCab,{"EJW_LOJEXP",SC7->C7_LOJA    	,NIL})
			aAdd(aCab,{"EJW_MOEDA" ,SC7->C7_MOEDA   	,NIL})
			aAdd(aCab,{"EJW_COMPL" ,SC7->C7_OBS			,NIL}) 
			aAdd(aCab,{"EJW_CONDPG",SC7->C7_COND		,Nil})

			//��������������������������������������������������������������������Ŀ
			//�Montagem do Itens (Array que contem os itens do pedido de compras)  |
			//����������������������������������������������������������������������
			Do While !Eof() .And. xSeek == SC7->C7_FILIAL+SC7->C7_NUM
				xLinha := {}
				aadd(xLinha,{"EJX_FILIAL"		,SC7->C7_FILIAL		,Nil})
				aadd(xLinha,{"EJX_PROCES"		,SC7->C7_NUM			,Nil})
				aadd(xLinha,{"EJX_SEQPRC"		,SC7->C7_ITEM		,Nil})
				aadd(xLinha,{"EJX_ITEM"		,SC7->C7_PRODUTO	,Nil})
				aadd(xLinha,{"EJX_QTDE"		,SC7->C7_QUANT		,Nil})
				aadd(xLinha,{"EJX_PRCUN"  	,SC7->C7_XVLMOED	,Nil}) 
				aadd(xLinha,{"EJX_VL_MOE"		,SC7->C7_XVLMOED	,Nil})			
				aadd(xLinha,{"EJX_TX_MOE"		,SC7->C7_TXMOEDA   	,NIL}) 
				aadd(xLinha,{"EJX_COMPL"		,SC7->C7_OBS			,Nil})
				aadd(aItens,xLinha)
				SC7->(dbSkip())
			EndDo
		EndIf
	EndIf
	*/
Return()