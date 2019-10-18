#Include 'Protheus.ch'
#Include 'FWMVCDef.ch'
#INCLUDE "RWMAKE.CH"
#INCLUDE "TOPCONN.CH"
#include 'parmtype.ch'
#include "totvs.ch"



/*/{Protheus.doc} APFATA03

Job de fatura pela aplicação TAVOLA 
da empresa  APRIL BRASIL TURISMO VIAGENS E ASSISTENCIA INTERNACIONAL LTDA, 
@type Fonte 
@author Edie Carlos 	
@since 24/04/2017 
/*/

User function APFATA03(aParam)
	local   aSC6		:= {}
	local   aRow   		:= {}
	local   aSC5  		:= {}
	Local 	cTotal      := ""
	Local 	cTipo       := ""
	Local 	cMod        := ""
	Local 	cDoc 	    := ""
	Local 	cCodProd 	:= ""
	Local 	cTes        := ""
	Local 	lGera       := .T.
	Local   cUpdSZ0     := ""
	Local   lMsErroAuto := .F.
	Private lGeraCp     := .F. 
	Private _cAlias     := "TMPFAT"//GetNextAlias()
	Private cErro       := ""
	Private cArqErro1	:= "Erro_Aut.txt"
	Private aLog        := {} 


	RpcClearEnv()
	RpcSetType(3)
	RpcSetEnv(aParam[1],aParam[2] )//, "admin","april123", "FAT", "RPC", aTables)aParam[1],aParam[2]

	dbSelectArea("SA1")
	SA1->(DbSetOrder(1))

	dbSelectArea("SZ5")
	dbSetOrder(2)

	dbSelectArea("SZ2")
	SZ2->(DbSetOrder(1))

	dbSelectArea("SE4")
	SE4->(dbSetOrder(1))



	BeginSql Alias _cAlias

	%noParser%

	SELECT *                        
	FROM
	%Table:SZ0% SZ0  
	Where Z0_NUM = ''
	AND Z0_PROCESS = 'N' 
	AND Z0_CANC  = ''
	AND SZ0.%notdel%
	AND Z0_FILIAL = %EXP:aParam[2]%//aParam[2]  
	ORDER BY  SZ0.Z0_FILIAL,SZ0.Z0_TPMOD,SZ0.Z0_TPFAT
	EndSql

	(_cAlias)->( DbGotop() ) 

	cTipo := (_cAlias)->Z0_TPFAT
	cMod  := (_cAlias)->Z0_TPMOD

	//***********************************************************************
	//* Verifica formação do valor referente Tipo e modalidade do faturamento          
	//***********************************************************************

	IF SZ5->(dbSeek(xFilial("SZ5")+ALLTRIM((_cAlias)->Z0_TPMOD)+ALLTRIM((_cAlias)->Z0_TPFAT)))
		While !SZ5->(EOF()) .AND. ALLTRIM(SZ5->Z5_TPFAT) == ALLTRIM((_cAlias)->Z0_TPFAT) .AND. ALLTRIM(SZ5->Z5_TPMOD) == ALLTRIM((_cAlias)->Z0_TPMOD)
			cTotal:= IIF(Empty(cTotal),""+ ALLTRIM(SZ5->Z5_CAMPO)+"" ,cTotal+""+'+'+ ""+ALLTRIM(SZ5->Z5_CAMPO)+"")
			SZ5->(dbSkip())
		EndDo
	ENDIF

	//****************************************
	//* Verifica se gera financeiro BDV OU BDU         
	//****************************************
	dbSelectArea("SZ2")
	SZ2->(dbSetOrder(1))

	_cEmp := (_cAlias)->Z0_EMPEMIS
	_cFil := (_cAlias)->Z0_FILEMIS

	//Abrindo os ambientes

	While !(_cAlias)->( Eof() )

		//Abrindo os ambientes


		IF SZ2->(dbSeek(xFilial("SZ2")+(_cAlias)->Z0_TPFAT+(_cAlias)->Z0_TPMOD))

			cCodProd := SZ2->Z2_PRODUTO
			cTes     := SZ2->Z2_TES
			IF SZ2->Z2_GERACR == "S"
				lGeraCp:= .T.
			ELSE
				//Verifica se condição de pagamento existe 
				IF !SE4->(dbSeek(xFilial("SE4")+SZ2->Z2_CONDPAG))
					lGera := .F. 
					GRAVAERRO((_cAlias)->Z0_FATURA,"Condição de pagamento nao cadastrada","I")
				ENDIF

				//Verifica se tes existe 
				IF !SF4->(dbSeek(xFilial("SF4")+SZ2->Z2_TES))
					lGera := .F. 
					GRAVAERRO((_cAlias)->Z0_FATURA,"Tes nao cadastrada","I")
				ENDIF

			ENDIF
		ELSE
			lGera := .F. 
			GRAVAERRO((_cAlias)->Z0_FATURA,"Modalidade nao encontrada","I")
		ENDIF

		//VERIFICA SE O VALOR NÃO ESTA ZERADO

		IF EMPTY(cTotal)
			lGera := .F. 
			GRAVAERRO((_cAlias)->Z0_FATURA,"Valor da Fatura Zerada","I")
		ENDIF


		IF  !lGeraCp 

			IF lGera

				lGera 	:= .T.
				aSC5 	:= {}
				aSC6   	:= {}
				aRow   	:= {}
				cMsg   	:= ''
				cDoc 	:= ''
				cDoc 	:=GetSxeNum("SC5","C5_NUM")
				RollBAckSx8()
				ConfirmSX8()

				aadd(aSC5,{"C5_FILIAL"   ,xFilial("SC5"),Nil})
				aadd(aSC5,{"C5_NUM"   ,cDoc,Nil})
				aadd(aSC5,{"C5_TIPO" ,"N",Nil})
				aadd(aSC5,{"C5_CLIENTE",(_cAlias)->Z0_CLIENTE,Nil})
				aadd(aSC5,{"C5_LOJACLI",(_cAlias)->Z0_LOJACLI,Nil})
				aadd(aSC5,{"C5_LOJAENT",(_cAlias)->Z0_LOJACLI,Nil})
				aadd(aSC5,{"C5_CONDPAG","001",Nil})
				aadd(aSC5,{"C5_XFATURA",(_cAlias)->Z0_FATURA ,Nil})
				aadd(aSC5,{"C5_XTPMOD" ,(_cAlias)->Z0_TPMOD ,Nil})
				aadd(aSC5,{"C5_XTPFAT" ,(_cAlias)->Z0_TPFAT ,Nil})
				aadd(aSC5,{"C5_CONDPAG","001",Nil})

				aSC5:=FWVetByDic(aSC5,"SC5",.F.,1)

				aadd(aRow,{"C6_FILIAL",xFilial("SC6"),Nil})
				aadd(aRow,{"C6_ITEM",'01',Nil})
				aadd(aRow,{"C6_PRODUTO",cCodProd,Nil})
				aadd(aRow,{"C6_QTDVEN",1,Nil})
				aadd(aRow,{"C6_PRCVEN",(_cAlias)->&(cTotal),Nil})
				aadd(aRow,{"C6_PRUNIT",(_cAlias)->&(cTotal),Nil})
				//aadd(aLinha,{"C6_VALOR",(_cAlias)->&(cTotal),Nil})
				aadd(aRow,{"C6_TES","502",Nil})
				//ele deve ter pego o c5_num ja utilizado
				aRow:=FWVetByDic(aRow,"SC6",.F.,1)
				aadd(aSC6,aRow)
				//****************************************************************
				//* Teste de Inclusao              
				//****************************************************************

				lMsErroAuto := .f.
				//MSExecAuto({|x,y,z| Mata410(x,y,z)},aCabec,aItens,3)
				MATA410(aSC5,aSC6,3)
				If !lMsErroAuto
					aLog := GetAutoGRLog()
					nD:= Len(aLog)

					For nT:= 1 to Len(aLog)
						cMsg := aLog[nT]
					Next nT

					IF !EMPTY (cMsg)
						GRAVAERRO((_cAlias)->Z0_FATURA,cMsg,"I")
					ELSE
						//****************************************************************
						//* Atualiza registro da tabela SZ3             
						//****************************************************************
						GRAVAERRO((_cAlias)->Z0_FATURA,cMsg,"D")
						cUpdSZ0 := "UPDATE " + RetSqlName("SZ0") + " SET Z0_NUM ='"+cDoc+"',Z0_PROCESS ='S' WHERE Z0_FATURA ='"+(_cAlias)->Z0_FATURA+"'"
						TcSqlExec(cUpdSZ0) 
						cDoc:=""
					ENDIF

				Else

					//****************************************************************
					//* Atualiza registro da tabela SZ6             
					//****************************************************************

					MostraErro( GetSrvProfString("Startpath","") , cArqErro1 )
					cMsg := MemoRead(  GetSrvProfString("Startpath","") + '\' + cArqErro1 )

					GRAVAERRO((_cAlias)->Z0_FATURA,cMsg,"I")

				EndIf
			Endif	   

		ELSE//PARA GERA CONTAS PAGAR
			IF SA2->(Dbseek( FwxFilial("SA2") + (_cAlias)->Z0_CLIENTE + (_cAlias)->Z0_LOJACLI  ))
				lGeraCp:=.F.
				// Gerar título NDC.
				_aTit := {}

				dbSelectArea("SZ1")
				SZ1->(dbSetOrder(1))
				IF SZ1->(dbSeek(xFilial("SZ1")+(_cAlias)->Z0_FATURA))
					//VERIFICA SE TITULO JÁ EXISTE
					dbSelectArea("SE2")
					SE2->(dbSetOrder(1))
					IF !SE2->(dbSeek(xFilial("SE2")+SZ2->Z2_TPFAT+alltrim((_cAlias)->Z0_FATURA)+SZ1->Z1_PARCELA+"NDC"+(_cAlias)->Z0_CLIENTE+(_cAlias)->Z0_LOJACLI))
						While !SZ1->(EOF()) .AND. SZ1->Z1_FATURA == (_cAlias)->Z0_FATURA


							AaDd( _aTit, {"E2_FILIAL" , FwxFilial("SE2") 		,Nil})
							AaDd( _aTit, {"E2_PREFIXO", SZ2->Z2_TPFAT    		,Nil})
							AaDd( _aTit, {"E2_NUM"    , (_cAlias)->Z0_FATURA    ,Nil})
							AaDd( _aTit, {"E2_PARCELA", SZ1->Z1_PARCELA 		,Nil})
							AaDd( _aTit, {"E2_TIPO"   , "NDC"     		  		,Nil})
							AaDd( _aTit, {"E2_FORNECE", (_cAlias)->Z0_CLIENTE   ,Nil})
							AaDd( _aTit, {"E2_LOJA"   , (_cAlias)->Z0_LOJACLI   ,Nil})
							AaDd( _aTit, {"E2_EMISSAO", SZ1->Z1_EMISSAO	  		,Nil})
							AaDd( _aTit, {"E2_VENCTO" , SZ1->Z1_VENCTO	  		,Nil})
							AaDd( _aTit, {"E2_VALOR"  , SZ1->Z1_VLRTO           ,Nil})
							AaDd( _aTit, {"E2_NATUREZ", SZ2->Z2_NATUREZ         ,Nil})


							//3-Inclusao //5-Exclusao
							MSExecAuto({|x,y| Fina050(x,y)}, _aTit, 3) 

							//Ocorrendo erro de autoexecução.
							If lMsErroAuto
								aLog := GetAutoGRLog()
								nD:= Len(aLog)

								For nT:= 1 to Len(aLog)
									cMsg := aLog[nT]
								Next nT

								GRAVAERRO((_cAlias)->Z0_FATURA,cMsg,"I")

							ELSE
								//****************************************************************
								//* Atualiza registro da tabela SZ0             
								//****************************************************************
								cUpdSZ0 := "UPDATE " + RetSqlName("SZ0") + " SET Z0_PROCESS ='S',Z0_NFFAT='"+(_cAlias)->Z0_FATURA+"',Z0_SERIENF='"+SZ2->Z2_TPFAT+"' " 
								cUpdSZ0 += "WHERE Z0_FATURA ='"+(_cAlias)->Z0_FATURA+"' AND Z0_FILIAL='"+xFilial("SZ0")+"'"
								TcSqlExec(cUpdSZ0)
								
								//VERIFICA SE EXISTE ALGUM ERRO REFERENTE ESSA FATURA
								GRAVAERRO((_cAlias)->Z0_FATURA,"","D") 						 
							EndIf
							SZ1->(dbSkip())
						EndDo	
					ELSE
						cMsg := "Titulo já cadastrado"
						GRAVAERRO((_cAlias)->Z0_FATURA,cMsg,"I")
					ENDIF

				ELSE
					cMsg := "Parcela nao encontrada"
					GRAVAERRO((_cAlias)->Z0_FATURA,cMsg,"I")
				ENDIF

			ELSE
				cMsg := "Cliente nao cadastrado como fornecedor"
				GRAVAERRO((_cAlias)->Z0_FATURA,cMsg,"I")
			ENDIF
		
		ENDIF

		(_cAlias)->(dbSkip())


		//****************************************************************
		//* Verifica se alterou o tipo e modalidade             
		//****************************************************************

		If cTipo <> (_cAlias)->Z0_TPFAT .and. cMod <> (_cAlias)->Z0_TPMOD
			cTotal  := ""
			lGeraCp := .F.
			cTipo := (_cAlias)->Z0_TPFAT
			cMod  := (_cAlias)->Z0_TPMOD

			IF SZ5->(dbSeek(xFilial("SZ5")+ALLTRIM((_cAlias)->Z0_TPMOD)+ALLTRIM((_cAlias)->Z0_TPFAT)))
				While !SZ5->(EOF()) .AND. ALLTRIM(SZ5->Z5_TPFAT) == ALLTRIM((_cAlias)->Z0_TPFAT) .AND. ALLTRIM(SZ5->Z5_TPMOD) == ALLTRIM((_cAlias)->Z0_TPMOD)
					cTotal:= IIF(Empty(cTotal),""+ ALLTRIM(SZ5->Z5_CAMPO)+"" ,cTotal+""+'+'+ ""+ALLTRIM(SZ5->Z5_CAMPO)+"")
					SZ5->(dbSkip())
				EndDo
			ENDIF
		EndIf 

	EndDo

	(_cAlias)->(dbCloseArea())

	/*
	//****************************************************************
	//* Verifica se algum pedido foi cancelado              
	//****************************************************************
	_cAlias     := GetNextAlias()


	BeginSql Alias _cAlias

	%noParser%

	SELECT *                        
	FROM
	%Table:SZ0% SZ0  
	Where Z0_NUM <> ''
	AND Z0_PROCESS = 'N' 
	AND Z0_CANC  <> ''
	AND Z0_FILIAL = %EXP:xFilial("SZ0")%  //aParam[2]
	AND SZ0.%notdel%
	ORDER BY  SZ0.Z0_TPMOD,SZ0.Z0_TPFAT

	EndSql
	(_cAlias)->( DbGotop() ) 


	While !(_cAlias)->( Eof() ) 

	CancelPed((_cAlias)->Z0_NUM,(_cAlias)->Z0_TPMOD,(_cAlias)->Z0_TPFAT)

	(_cAlias)->(dbSkip())
	EndDo


	*/
	RpcClearEnv()
	return

	*/
	/*/{Protheus.doc} CancelPed
	Rotina para Cancelamento de pedido 
	da empresa  APRIL BRASIL TURISMO VIAGENS E ASSISTENCIA INTERNACIONAL LTDA, 
	@type Fonte 
	@author Edie Carlos 
	@since 24/04/2017 
	/*/
	/*
	Static Function CancelPed(cNumPed,TPMOD,TPFAT)
	Local lLibera     :=.T.
	Local lMsErroAuto := .F.  
	Local lExcTit 	  := .T.
	Local cNota       := ""
	Local cSerie      := ""
	Local cPed        := ""
	Local lGeraCp	  :=.F.


	//***************************************
	//* Verifica tipo de modalidade             
	//***************************************

	IF SZ2->(dbSeek(xFilial("SZ2")+TPFAT+TPMOD))
	IF SZ2->Z2_GERACR == "S"
	lGeraCp:= .T.
	ENDIF  
	ENDIF

	IF  !lGeraCp

	dbSelectArea("SC5")
	SC5->(dbSetOrder(1))
	IF SC5->(dbSeek(xFilial("SC5")+cNumPed))
	cNota  := SC5->C5_NOTA
	cSerie := SC5->C5_SERIE
	cPed   := SC5->C5_NUM
	//***************************************
	//* Verifica se tem documento de saida             
	//***************************************
	IF !Empty(SC5->C5_NOTA)
	lLibera := CanNf(SC5->C5_NOTA,SC5->C5_SERIE)
	//**********************************************************
	//* Verifica se nao existe titulo criado manualmente baixado             
	//**********************************************************
	lExcTit:= VLDTIT(SC5->C5_SERIE,SC5->C5_NOTA)

	ENDIF  

	//********************************************
	//* Se Estiver tudo ok Exclui pedido de venda             
	//********************************************
	IF lLibera .AND. lExcTit

	aCabec := {}
	aItens := {}


	aadd(aCabec,{"C5_NUM"     ,SC5->C5_NUM     ,Nil})
	aadd(aCabec,{"C5_TIPO"    ,SC5->C5_TIPO    ,Nil})
	aadd(aCabec,{"C5_CLIENTE" ,SC5->C5_CLIENTE ,Nil})
	aadd(aCabec,{"C5_LOJACLI" ,SC5->C5_LOJACLI ,Nil})
	aadd(aCabec,{"C5_LOJAENT" ,SC5->C5_LOJAENT ,Nil})
	aadd(aCabec,{"C5_CONDPAG" ,SC5->C5_CONDPAG ,Nil})

	aLinha := {}
	dbSelectArea("SC6")
	SC6->(dbSetOrder(1))
	SC6->(dbSeek(xFilial("SC6")+SC5->C5_NUM))

	aadd(aLinha,{"C6_ITEM"    ,SC6->C6_ITEM     ,Nil})
	aadd(aLinha,{"C6_PRODUTO" ,SC6->C6_PRODUTO  ,Nil})
	aadd(aLinha,{"C6_QTDVEN"  ,1                ,Nil})
	aadd(aLinha,{"C6_PRCVEN"  ,SC6->C6_ITEM     ,Nil})
	aadd(aLinha,{"C6_PRUNIT"  ,SC6->C6_PRUNIT   ,Nil})
	aadd(aLinha,{"C6_VALOR"   ,SC6->C6_VALOR    ,Nil})
	aadd(aLinha,{"C6_TES"     ,SC6->C6_TES      ,Nil})

	aadd(aItens,aLinha)

	//****************************************************************
	//* Exclusão pedido de venda              
	//****************************************************************
	MATA410(aCabec,aItens,5)
	If !lMsErroAuto

	//****************************************************************
	//* Atualiza SZ0 Zerando campo nota se tiver preenchido              
	//****************************************************************

	dbSelectArea("SZ0")
	SZ0->(dbSetOrder(2))
	IF SZ0->(dbSeek(xFilial("SZ0")+cPed))

	RecLock("SZ0",.F.)
	SZ0->Z0_NFFAT 	  := ''
	SZ0->Z0_SERIENF   := ''
	SZ0->Z0_NUM       := ''
	SZ0->Z0_PROCESS   := 'S'

	SZ0->(MsUnLock())
	//****************************************************************
	//* Exclusão Titulos             
	//****************************************************************
	dbSelectArea("SE1")
	SE1->(dbSetOrder(1))
	IF SE1->(dbSeek(xFilial("SE1")+cSerie+cNota))
	lExcTit:=.T.
	While SE1->(!EOF()) .AND. SE1->E1_FILIAL+SE1->E1_PREFIXO+SE1->E1_NUM == xFilial("SC5")+cSerie+cNota
	aArray :={}
	aArray := { { "E1_PREFIXO" , SE1->E1_PREFIXO , NIL },;
	{ "E1_NUM"     , SE1->E1_NUM     , NIL } }

	MsExecAuto( { |x,y| FINA040(x,y)} , aArray, 5)  // 3 - Inclusao, 4 - Alteração, 5 - Exclusão

	If lMsErroAuto

	//****************************************************************
	//* Atualiza registro da tabela SZ6             
	//****************************************************************

	MostraErro( GetSrvProfString("Startpath","") , cArqErro1 )
	cMsg := MemoRead(  GetSrvProfString("Startpath","") + '\' + cArqErro1 )

	GRAVAERRO((_cAlias)->Z0_FATURA,cMsg,"I")

	Else
	SE1->(dbSkip())
	Endif
	EndDo

	ENDIF	

	Endif	

	Else

	//****************************************************************
	//* Atualiza registro da tabela SZ6             
	//****************************************************************

	MostraErro( GetSrvProfString("Startpath","") , cArqErro1 )
	cMsg := MemoRead(  GetSrvProfString("Startpath","") + '\' + cArqErro1 )

	GRAVAERRO((_cAlias)->Z0_FATURA,cMsg,"I")

	EndIf
	Endif	   


	ENDIF
	ELSE// lGeraCp
	//****************************************************************
	//* Exclusão Titulos             
	//****************************************************************
	dbSelectArea("SZ0")
	SZ0->(dbSetOrder(2))
	IF SZ0->(dbSeek(xFilial("SZ0")+cPed))
	EXCLCP((_cAlias)->Z0_NFAT,(_cAlias)->Z0_SERIENF)
	ENDIF

	ENDIF

	Return()

	*/
	/*/{Protheus.doc} CanNf
	Rotina para Cancelamento de nota fiscal 
	da empresa  APRIL BRASIL TURISMO VIAGENS E ASSISTENCIA INTERNACIONAL LTDA, 
	@type Fonte 
	@author Edie Carlos 
	@since 24/04/2017 
	/*/
	/*
	Static Function CanNf(cNota,cSerie)
	Local lRet := .T.
	Local lEst := .T.
	Local aRegSD2 	:={}
	Local aRegSE2 	:={}
	Local aRegSE1 	:={}


	dbSelectArea("SF2")
	SF2->(dbSetOrder(1))

	IF SF2->(dbSeek(xFilial("SF2")+cNota+cSerie))
	//-- Verifica se o estorno do documento de saida pode ser feito.
	If MaCanDelF2('SF2',SF2->(RecNo()),@aRegSD2,@aRegSE1,@aRegSE2)
	//-- Estorna o documento de saida.
	lEst:= SF2->(MaDelNFS(aRegSD2,aRegSE1,aRegSE2,.F.,.F.,.F.,.T.,,1))
	If !lEst
	lRet := .F.
	EndIf
	Else
	lRet := .F.
	EndIf

	ENDIF

	Return(lRet)
	*/
	/*/{Protheus.doc} Exclui Titulo
	Rotina para excluir titulos
	da empresa  APRIL BRASIL TURISMO VIAGENS E ASSISTENCIA INTERNACIONAL LTDA, 
	@type Fonte 
	@author Edie Carlos 
	@since 24/04/2017 
	/*/
	/*
	Static Function EXCLCP(cNota,cSerie)

	dbSelectArea("SE2")
	SE2->(dbSetOrder(1))
	IF SE2->(dbSeek(xFilial("SE1")+cSerie+cNota))
	lExcTit:= VLDTIT(cSerie,cNota)
	IF lExcTit
	While SE2->(!EOF()) .AND. SE2->E2_FILIAL+SE2->E2_PREFIXO+SE2->E2_NUM == xFilial("SE2")+cSerie+cNota
	aArray :={}
	aArray := { { "E2_PREFIXO" , SE2->E2_PREFIXO , NIL },;
	{ "E2_NUM"     , SE2->E2_NUM     , NIL } }

	MsExecAuto( { |x,y| FINA050(x,y)} , aArray, 5)  // 3 - Inclusao, 4 - Alteração, 5 - Exclusão

	If lMsErroAuto

	//****************************************************************
	//* Atualiza registro da tabela SZ6             
	//****************************************************************

	MostraErro( GetSrvProfString("Startpath","") , cArqErro1 )
	cMsg := MemoRead(  GetSrvProfString("Startpath","") + '\' + cArqErro1 )
	//****************************************************************
	//* CHAMA FUNÇÃO PARA GRAVA O ERRO             
	//****************************************************************
	GRAVAERRO((_cAlias)->Z0_FATURA,cMsg,"I")							
	Else
	SE1->(dbSkip())
	Endif
	EndDo
	ENDIF
	ENDIF

	Return()
	*/
	/*/{Protheus.doc} Grava erro
	Rotina para grava erro
	da empresa  APRIL BRASIL TURISMO VIAGENS E ASSISTENCIA INTERNACIONAL LTDA, 
	@type Fonte 
	@author Edie Carlos 
	@since 24/04/2017 
	/*/

Static Function GRAVAERRO(_cFatura,_cMsg,cTipo)
	Local lAchou := .F.

	dbSelectArea("SZ6")
	dbSetOrder(2)

	IF cTipo == "D"
		IF SZ6->(dbSeek(xFilial("SZ6")+"F"+_cFatura))
			RecLock("SZ6",.F.)
			dbDelete()
			SZ6->(MsUnLock())
		ENDIF
	ENDIF 

	IF cTipo == "I"	
		IF SZ6->(dbSeek(xFilial("SZ6")+"F"+_cFatura))
			RecLock("SZ6",.F.)
		ELSE
			RecLock("SZ6",.T.)
		ENDIF	
		SZ6->Z6_FILIAL  := xFilial("SZ6")
		SZ6->Z6_INTEGRA := "F"
		SZ6->Z6_NUMERO  := _cFatura
		SZ6->Z6_MOTIVO  := _cMsg
		SZ6->(MsUnLock())
	ENDIF	


	Return()

	/*/{Protheus.doc} Valida Titulo
	Rotina para grava erro
	da empresa  APRIL BRASIL TURISMO VIAGENS E ASSISTENCIA INTERNACIONAL LTDA, 
	@type Fonte 
	@author Edie Carlos 
	@since 24/04/2017 
	/*/
/*
Static Function VLDTIT(_cSerie,_cNota)
Local lRet := .T.

dbSelectArea("SE1")
SE1->(dbSetOrder(1))
IF SE1->(dbSeek(xFilial("SE1")+_cSerie+_cNota))

While SE1->(!EOF()) .AND. SE1->E1_FILIAL+SE1->E1_PREFIXO+SE1->E1_NUM == xFilial("SC5")+_cSerie+_cNota
IF !EMPTY(SE1->E1_BAIXA)
lRet := .F.
ENDIF
SE1->(dbSkip())
EndDo

ENDIF 

Return(lRet)
*/