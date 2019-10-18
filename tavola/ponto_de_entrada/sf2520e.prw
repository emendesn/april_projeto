#include 'protheus.ch'
#include 'parmtype.ch'

//#################
//# Programa      # SF2520E
//# Data          #   
//# Descrição     # Ponto de Entrada para excluir os titulos 
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


user function SF2520E()
Local 	aRegSD2 	:={}
Local 	aRegSE2 	:={}
Local 	aRegSE1 	:={}
Local 	lApaga 		:= .T.
Local 	aAreaSF2	:= SF2->(GetArea())
Local 	lRet		:= .T.
Local 	lSF2520E 	:= Existblock('SF2520E')
LOCAL 	aVetor 		:= {}
PRIVATE lMsErroAuto := .F.


//-- Verifica se o estorno do documento de saida pode ser feito.
	If MaCanDelF2('SF2',SF2->(RecNo()),@aRegSD2,@aRegSE1,@aRegSE2)
		
		//EXCLUSAO DO TITULO 
		SE1->(DbSeek(xFilial("SE1")+SF2->F2_SERIE+SF2->F2_DOC)) //Exclusão deve ter o registro SE1 posicionado
		
		//VERIFICA SE O TITULO FOI GERADO MANUAL PELA INTEGRAÇÃO
		 dbSelectArea("SZ2")
		 SZ2->(DbSetOrder(1))
		 IF SZ2->(Dbseek( FwxFilial("SZ2") + SE1->E1_XTPFAT  + SE1->E1_XMODFAT ))
		 	IF SZ2->Z2_GERAFIN == "S" .AND. SZ2->Z2_GERACR == 'N'
			 	WHILE SE1->(!EOF()) .AND. SE1->E1_PREFIXO+SE1->E1_NUM == SF2->F2_SERIE+SF2->F2_DOC
			 	   					
					aArray := { { "E1_PREFIXO" , SE1->E1_PREFIXO , NIL },;
								{ "E1_NUM"     , SE1->E1_NUM     , NIL } }
					
					MsExecAuto( { |x,y| FINA040(x,y)} , aArray, 5)  // 3 - Inclusao, 4 - Alteração, 5 - Exclusão
					
					If lMsErroAuto
						MostraErro()
						lRet:= .F.
					Endif
					
					SE1->(dbSkip())
					
				EndDo
			ENDIF
		 ENDIF	
	Endif


RestArea(aAreaSF2)
	
return(lRet)