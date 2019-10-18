#include 'protheus.ch'
#include 'parmtype.ch'


//#################
//# Programa      # MS520VLD
//# Data          #   
//# Descrição     # Ponto de Entrada para validar exclusão na nf 
//# Desenvolvedor # Edie Carlos 
//# Empresa       # Totvs Nacoes Unidas
//# Linguagem     # eAdvpl     
//# Versão        # 12
//# Sistema       # Protheus
//# Módulo        # Faturamento
//# Tabelas       # "SE1"
//# Observação    # Usado para excluir os titulos de geração manual 
//#===============#
//# Atualizações  # 
//#===============#
//#################

user function MS520VLD()

Local   lRet        := .T.
Local 	aAreaSF2	:= SF2->(GetArea())
Local 	aAreaSE1	:= SE1->(GetArea())

dbSelectArea("SE1")
SE1->(dbSetOrder(1))

//EXCLUSAO DO TITULO 
	IF SE1->(DbSeek(xFilial("SE1")+SF2->F2_SERIE+SF2->F2_DOC)) //Exclusão deve ter o registro SE1 posicionado
	//VERIFICA SE O TITULO FOI GERADO MANUAL PELA INTEGRAÇÃO
		 dbSelectArea("SZ2")
		 SZ2->(DbSetOrder(1))
		 IF SZ2->(Dbseek( FwxFilial("SZ2") + SE1->E1_XTPFAT  + SE1->E1_XMODFAT ))
		 	IF SZ2->Z2_GERAFIN == "S" .AND. SZ2->Z2_GERACR == 'N'
			 	WHILE SE1->(!EOF()) .AND. SE1->E1_PREFIXO+SE1->E1_NUM == SF2->F2_SERIE+SF2->F2_DOC
			 	   	IF !Empty(SE1->E1_BAIXA)
				 	   	MSGINFO("Existe titulo baixado para esse documento, Cancele baixa para excluir esse documento!!")
				 	   	Return(.F.)
				   	ENDIF				
				SE1->(dbSkip())
					
				EndDo
			ENDIF
		ENDIF	
	ENDIF

RestArea(aAreaSF2)
RestArea(aAreaSE1)
	
return (lRet)