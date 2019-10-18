#include "PROTHEUS.CH"
#include "fileio.ch"
#include "FINA430.CH"
#include "FWMVCDEF.CH"

Static lFWCodFil := .T.
Static _oFina430

user function RetSant(nPosAuto)
	Local lPanelFin := IsPanelFin()
	Local lOk		:= .F.
	Local aSays 	:= {}
	Local aButtons  := {}
	Local cPerg		:= "AFI430"

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Define o cabecalho da tela de baixas ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	PRIVATE cCadastro := OemToAnsi( STR0006 )  //"Retorno CNAB Pagar"
	Private aTit  
	Private cTipoBx  := ""
	Private nVlrCnab := 0
	Private lMVCNBImpg := GetNewPar("MV_CNBIMPG",.F.)

	// Retorno Automatico via Job
	// parametro que controla execucao via Job utilizado para pontos de entrada que nao tem como passar o parametro
	Private lExecJob := ExecSchedule()

	// Retorno Automatico via Job
	if lExecJob
		nPosAuto := 1 // Envia arquivo
	Endif

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica as perguntas selecionadas                 ³
	//³                                                    ³
	//³ Parametros                                         ³
	//³                                                    ³
	//³ MV_PAR01: Mostra Lanc. Contab  ? Sim Nao           ³
	//³ MV_PAR02: Aglutina Lanc. Contab? Sim Nao           ³
	//³ MV_PAR03: Arquivo de Entrada   ?                   ³
	//³ MV_PAR04: Arquivo de Config    ?                   ³
	//³ MV_PAR05: Banco                ?                   ³
	//³ MV_PAR06: Agencia              ?                   ³
	//³ MV_PAR07: Conta                ?                   ³
	//³ MV_PAR08: SubConta             ?                   ³
	//³ MV_PAR09: Contabiliza          ?                   ³
	//³ MV_PAR10: Padrao Cnab          ? Modelo1 Modelo 2  ³
	//³ MV_PAR11: Processa filiais     ? Modelo1 Modelo 2  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	A460FSA2()	//Aplica Filtro na tabela de Fornecedores (SA2)

	If lPanelFin .and. ! lExecJob  // Retorno Automatico via Job
		lPergunte := PergInPanel(cPerg,.T.)
	Else
		if lExecJob    // Retorno Automatico via Job
			Pergunte(cPerg,.F.,Nil,Nil,Nil,.F.)  // carrega as perguntas que foram atualizadas pelo FINA435
			lPergunte := .T.
		Else
			lPergunte := pergunte(cPerg,.T.)
		Endif
	Endif

	If lPergunte
		MV_PAR03 := UPPER(MV_PAR03)

		dbSelectArea("SE2")
		dbSetOrder(1)

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Inicializa o log de processamento                            ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		ProcLogIni( aButtons )

		If nPosAuto <> Nil
			lOk := .T.
		Else
			aADD(aSays,STR0013)
			aADD(aSays,STR0014)
			If lPanelFin  //Chamado pelo Painel Financeiro
				aButtonTxt := {}
				If Len(aButtons) > 0
					AADD(aButtonTxt,{STR0002,STR0002,aButtons[1][3]}) // Visualizar
				Endif
				AADD(aButtonTxt,{STR0001,STR0001, {||Pergunte("AFI430",.T. )}}) // Parametros
				FaMyFormBatch(aSays,aButtonTxt,{||lOk:=.T.},{||lOk:=.F.})
			Else
				aADD(aButtons, { 5,.T.,{|| Pergunte("AFI430",.T. ) } } )
				aADD(aButtons, { 1,.T.,{|| lOk := .T.,FechaBatch()}} )
				aADD(aButtons, { 2,.T.,{|| FechaBatch() }} )
				FormBatch( cCadastro, aSays, aButtons ,,,535)
			EndIf
		Endif
		If lOk
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Atualiza o log de processamento   ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			if lExecJob
				ProcLogAtu("INICIO",STR0016+" - "+STR0017+mv_par03) // "Retorno Bancario Automatico (Pagar)" # "Arquivo:"
			Else
				ProcLogAtu("INICIO")
			Endif

			fa430gera("SE2")

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Atualiza o log de processamento   ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If lExecJob
				ProcLogAtu("FIM",,STR0016+" - "+STR0017+mv_par03) // "Retorno Bancario Automatico (Pagar)" # "Arquivo:"
			Else
				ProcLogAtu("FIM")
			Endif
		EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Recupera a Integridade dos dados                             ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		dbSelectArea("SE2")
		dbSetOrder(1)
	EndIf

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ fA430Ger ³ Autor ³ Wagner Xavier         ³ Data ³ 26/05/92 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Comunicacao Bancaria - Retorno                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ fA430Ger(cAlias)                                           ³±±
±±³          ³ cAlias - Alias corrente para executar a funcao             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ FinA430                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function fa430gera(cAlias)
	PRIVATE cLotefin	:= Space(TamSX3("EE_LOTECP")[1])
	PRIVATE nTotAbat	:= 0,cConta := " "
	PRIVATE nHdlBco		:= 0,nHdlConf := 0,nSeq := 0 ,cMotBx := "DEB"
	PRIVATE nValEstrang	:= 0
	PRIVATE cMarca		:= GetMark()
	PRIVATE aAC			:= { STR0004,STR0005 }  //"Abandona"###"Confirma"
	PRIVATE nTotAGer	:= 0
	PRIVATE VALOR		:= 0
	PRIVATE ABATIMENTO	:= 0
	Private nAcresc, nDecresc

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Ponto de Entrada para Tratamento baixa - Citibank³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If ExistBlock("F430CIT")
		ExecBlock("F430CIT",.F.,.F.)
	Endif

	Processa({|lEnd| fa430Ger(cAlias)})  // Chamada com regua

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Fecha os Arquivos ASCII ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If nHdlBco > 0
		FCLOSE(nHdlBco)
	Endif

	If nHdlConf > 0
		FCLOSE(nHdlConf)
	Endif

Return .T.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ fA430Gera³ Autor ³ Wagner Xavier         ³ Data ³ 26/05/92 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Comunicacao Bancaria - Retorno                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ fA430Ger(cAlias)                                           ³±±
±±³          ³ cAlias - Alias corrente para executar a funcao             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ FinA430                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function fA430Ger(cAlias)

	Local cPosNum,cPosData,cPosDesp,cPosDesc,cPosAbat,cPosPrin,cPosJuro,cPosMult,cPosForne
	Local cPosOcor,cPosTipo,cPosCgc, cRejeicao, cPosDebito, cPosRejei
	Local cChave430,cNumSe2,cChaveSe2
	Local cArqConf,cArqEnt,cPosNsNum
	Local cTabela    := "17",cPadrao,cLanca,cNomeArq
	Local cFilOrig   := cFilAnt	// Salva a filial para garantir que nao seja alterada em customizacao
	Local xBuffer
	Local lPosNum    := .f., lPosData := .f.
	Local lPosDesp   := .f., lPosDesc := .f., lPosAbat := .f.
	Local lPosPrin   := .f., lPosJuro := .f., lPosMult := .f.
	Local lPosOcor   := .f., lPosTipo := .f., lMovAdto := .F.
	Local lPosNsNum  := .f., lPosForne:= .f., lPosRejei:= .f.
	Local lPosCgc    := .f., lPosdebito:=.f.
	Local lDesconto,lContabiliza,lUmHelp := .F.,lCabec := .f.
	Local lPadrao    := .f., lBaixou := .f., lHeader := .f.
	Local lF430VAR   := ExistBlock("F430VAR"),lF430Baixa := ExistBlock("F430BXA")
	Local lF430Rej   := ExistBlock("F430REJ"),lFa430Oco  := ExistBlock("FA430OCO")
	Local lFa430Se2  := ExistBlock("FA430SE2"),lFa430Pa  := ExistBlock("FA430PA")
	Local lFa430Fil  := Existblock("FA430FIL")
	Local lFA430LP	 := Existblock("FA430LP")
	Local lRet       := .T.
	Local nLidos,nLenNum,nLenData,nLenDesp,nLenDesc,nLenAbat,nLenForne,nLenRejei
	Local nLenPrin,nLenJuro,nLenMult,nLenOcor,nLenTipo,nLenCgc, nLenDebito,nLenNsNum
	Local nTotal     := 0,nPos,nPosEsp,nBloco := 0
	Local nSavRecno  := Recno()
	Local nTamForn   := Tamsx3("E2_FORNECE")[1]
	Local nTamOcor   := TamSx3("EB_REFBAN")[1]
	Local nTamEEOcor := 2
	Local aTabela    := {},aLeitura := {},aValores := {},aCampos := {}
	Local dDebito
	Local nTamPre	:= TamSX3("E1_PREFIXO")[1]
	Local nTamNum	:= TamSX3("E1_NUM")[1]
	Local nTamPar	:= TamSX3("E1_PARCELA")[1]
	Local nTamTit	:= nTamPre+nTamNum+nTamPar
	Local lAchouTit := .F.
	Local nTamBco	:= Tamsx3("A6_COD")[1]
	Local nTamAge	:= TamSx3("A6_AGENCIA")[1]
	Local nTamCta	:= Tamsx3("A6_NUMCON")[1]
	Local lMultNat 	:= IIF(mv_par12==1,.T.,.F.)
	Local aColsSEV 	:= {}
	Local lOk 		:= .F. //Controla se foi confirmada a distribuicao
	Local nTotLtEZ 	:= 0	//Totalizador da Bx Lote Mult Nat CC
	Local nHdlPrv	:= 0
	Local aArqConf	:= {}	// Atributos do arquivo de configuracao
	Local lCtbExcl	:= !Empty( xFilial("CT2") )
	Local aFlagCTB	:= {}
	Local lUsaFlag	:= SuperGetMV( "MV_CTBFLAG" , .T. /*lHelp*/, .F. /*cPadrao*/)
	Local lF430PORT := ExistBlock("F430PORT")
	Local lAltPort 	:= .F.
	Local aDtMvFinOk := {} //Array para as datas de baixa válidas
	Local aDtMvFinNt := {} //Array para as datas de baixa inconsistentes com o parâmetro MV_DATAFIN
	Local lTrocaLP	:= .F.
	Local lPCCBaixa := SuperGetMv("MV_BX10925",.T.,"2") == "1"
	Local lIRPFBaixa := .F.
	Local cPadAux	:= ""
	Local lF080Grv := .F.
	Local aCtBaixa := {}
	Local nX 	   := 0
	//DDA - Debito Direto Autorizado
	Local lUsaDDA	:= FDDAInUse()
	Local lProcDDA	:= .F.
	Local lF430COMP := ExistBlock( "F430COMP" )
	Local lFA430FIG	:= ExistBlock( "FA430FIG" )
	Local cFilAux	:= ""

	//Reestruturacao SE5
	Local oModelMov	:= Nil //Model de Movimento
	Local oSubFK2	:= Nil
	Local oSubFK5	:= Nil
	Local oSubFKA	:= ""
	Local cLog		:= ""
	Local cCamposE5	:= ""
	Local cChaveTit	:= ""
	Local cIDDoc	:= ""
	Local lBxCnab	:= GetMv("MV_BXCNAB") == "S"
	Local cBcoOfi	:= ""
	Local cAgeOfi	:= ""
	Local cCtaOfi	:= ""
	Local cNatLote:= FINNATMOV("P")
	Local cLocRec := SuperGetMV( "MV_LOCREC" , .F. , .F. )
	Local aAreaCorr := {}
	Local lF430GRAFIL := ExistBlock("F430GRAFIL")
	Local cCGCFilHeader := ""
	Local aAreaCnab
	Local nExit 	:= 0
	Local nValImp	:= 0
	Local nOldValPgto := 0
	Local nMoeda	:= 0
	Local nTxMoeda	:= 0
	Local lRet		:= .T.
	Local lBp10925	:= SuperGetMv("MV_BP10925",.F.,"2") == "1"
	Local lPagAnt	:= .F.
	Local cAliasTmp 		:= GetNextAlias()

	Private cBanco, cAgencia, cConta
	Private cHist070, cArquivo
	Private lAut		:=.f., nTotAbat := 0
	Private cCheque 	:= " ", cPortado := " ", lAdiantamento := .F.
	Private cNumBor 	:= " ", cForne  := " " , cCgc := "", cDebito := ""
	Private cModSpb 	:= "1"  // Colocado apenas para não dar problemas nas rotinas de baixa
	Private cAutentica 	:= Space(25)  //Autenticacao retornada pelo segmento Z
	Private cLote		:= Space(TamSX3("EE_LOTECP")[1])
	Private cBenef      := ""  // JBS - 26/08/2013 - Controle da gravação do nome do beneficiario

	//Reestruturacao SE5
	PRIVATE nDescCalc 	:= 0
	PRIVATE nJurosCalc 	:= 0
	PRIVATE nMultaCalc 	:= 0
	PRIVATE nCorrCalc	:= 0
	PRIVATE nDifCamCalc	:= 0
	PRIVATE nImpSubCalc	:= 0
	PRIVATE nPisCalc	:= 0
	PRIVATE nCofCalc	:= 0
	PRIVATE nCslCalc	:= 0
	PRIVATE nIrfCalc	:= 0
	PRIVATE nIssCalc	:= 0
	PRIVATE nPisBaseR 	:= 0
	PRIVATE nCofBaseR	:= 0
	PRIVATE nCslBaseR 	:= 0
	PRIVATE nIrfBaseR 	:= 0
	PRIVATE nIssBaseR 	:= 0
	PRIVATE nPisBaseC 	:= 0
	PRIVATE nCofBaseC 	:= 0
	PRIVATE nCslBaseC 	:= 0
	PRIVATE nIrfBaseC 	:= 0
	PRIVATE nIssBaseC 	:= 0
	Private lOnline	:= .F.
	Private lVlrMaior := .F.
	Private nVlrMaior	:= 0

	lChqPre := .F.

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Posiciona no Banco indicado                                  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cBanco  := mv_par05
	cAgencia:= mv_par06
	cConta  := mv_par07
	cSubCta := mv_par08

	If ExecSchedule() // Anula parâmetro MV_LOCREC quando vem de schedule
		cLocRec:=""
	Endif
	dbSelectArea("SA6")
	DbSetOrder(1)
	SA6->( dbSeek(xFilial("SA6")+cBanco+cAgencia+cConta) )

	dbSelectArea("SEE")
	DbSetOrder(1)
	SEE->( dbSeek(xFilial("SEE")+cBanco+cAgencia+cConta+cSubCta) )

	// Buscar a Conta Oficial. Abaixo eu seto os novos valores 
	If !Empty(SEE->EE_CTAOFI)

		cBcoOfi	:= SEE->EE_CODOFI
		cAgeOfi	:= SEE->EE_AGEOFI 
		cCtaOfi	:= SEE->EE_CTAOFI

		cBanco		:= SEE->EE_CODOFI
		cAgencia	:= SEE->EE_AGEOFI 
		cConta		:= SEE->EE_CTAOFI

	endif

	nBloco := If( SEE->EE_NRBYTES==0,402,SEE->EE_NRBYTES+2)
	If !SEE->( found() )
		if ! lExecJob
			Help(" ",1,"PAR150")
		Endif

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Atualiza o log de processamento com o erro  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		ProcLogAtu("ERRO","PAR150",Ap5GetHelp("PAR150"))

		lRet:= .F.
	Endif

	If lRet .And. lBxCnab // Baixar arquivo recebidos pelo CNAB aglutinando os valores
		If Empty(SEE->EE_LOTECP)
			cLoteFin := StrZero( 1, TamSX3("EE_LOTECP")[1] )
		Else
			cLoteFin := FinSomaLote(SEE->EE_LOTECP)
		EndIf
	EndIf

	lRet := DtMovFin(dDatabase,,"1")
	IF !lret
		return(.f.)
	Endif

	//Tratamento para gestão corporativa
	If FWSizeFilial() > 2
		If (FWModeAccess("CT2", 3) == "C") .Or. ( FWModeAccess("CT2", 2) == "C") .Or. ( FWModeAccess("CT2", 1) == "C")
			lCtbExcl := .F.
		EndIf
	EndIf

	If lRet
		cTabela := Iif( Empty(SEE->EE_TABELA), "17" , SEE->EE_TABELA )
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Verifica se a tabela existe           ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		dbSelectArea( "SX5" )
		If !SX5->( dbSeek( xFilial("SX5")+ cTabela ) )
			if ! lExecJob
				Help(" ",1,"PAR430")
			Endif

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Atualiza o log de processamento com o erro  ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			ProcLogAtu("ERRO","PAR430",Ap5GetHelp("PAR430"))

			lRet := .F.
		Endif
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	// Verifica se a contabilidade está em modo exclusivo e   ³
	// se foi solicitado o processamento de todas as filiais. ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lRet .And. mv_par11 == 2
		If lCtbExcl .and. ! ExecSchedule()
			// Neste caso, o sistema não realiza a contabilização on-line. Confirma mesmo assim?
			lRet := MsgYesNo( STR0015, STR0010 )
		EndIf
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica se arquivo ja foi processado anteriormente	³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lRet .And. !(Chk430File())
		lRet := .F.
	Endif

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	// Retorno Automatico via Job se o arquivo estiver	     ³
	// no diretorio vai reprocessar sempre se for JOB	     ³
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	If lExecJob .and. ! lRet
		ProcLogAtu("ALERTA",STR0017+Alltrim(mv_par03)+STR0018) 	// "Arquivo :" # " processado anteriormente."
		Aadd(aMsgSch, STR0017+Alltrim(mv_par03)+STR0018) 		// "Arquivo :" # " processado anteriormente."
	Endif

	//Altero banco da baixa pelo portador ?
	If lF430PORT
		lAltPort := ExecBlock("F430PORT",.F.,.F.)
	Endif

	While lRet .And. !SX5->(Eof()) .and. SX5->X5_TABELA == cTabela
		AADD(aTabela,{Alltrim(X5Descri()),PadR(AllTrim(SX5->X5_CHAVE),3)})
		SX5->(dbSkip( ))
	EndDo

	If lRet
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Verifica o numero do Lote   ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		LoteCont("FIN")

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Abre arquivo de configuracao ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cArqConf:=mv_par04
		If !FILE(cArqConf)
			if ! lExecJob
				Help(" ",1,"NOARQPAR")
			Endif

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Atualiza o log de processamento com o erro  ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			ProcLogAtu("ERRO","NOARQPAR",Ap5GetHelp("NOARQPAR"))

			lRet:= .F.
		ElseIf ( MV_PAR10 == 1 )
			nHdlConf:=FOPEN(cArqConf,0+64)
		EndIF
	EndIf

	If lRet .And. ( MV_PAR10 == 1 )
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Lˆ arquivo de configuracao ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		nLidos:=0
		FSEEK(nHdlConf,0,0)
		nTamArq:=FSEEK(nHdlConf,0,2)
		FSEEK(nHdlConf,0,0)
		While nLidos <= nTamArq

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Verifica o tipo de qual registro foi lido ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			xBuffer:=Space(85)
			FREAD(nHdlConf,@xBuffer,85)

			IF SubStr(xBuffer,1,1) == CHR(1)
				nLidos+=85
				Loop
			EndIF
			IF SubStr(xBuffer,1,1) == CHR(3)
				Exit
			EndIF
			IF !lPosNum
				cPosNum:=Substr(xBuffer,17,10)
				nLenNum:=1+Int(Val(Substr(xBuffer,20,3)))-Int(Val(Substr(xBuffer,17,3)))
				lPosNum:=.t.
				nLidos+=85
				Loop
			EndIF
			IF !lPosData
				cPosData:=Substr(xBuffer,17,10)
				nLenData:=1+Int(Val(Substr(xBuffer,20,3)))-Int(Val(Substr(xBuffer,17,3)))
				lPosData:=.t.
				nLidos+=85
				Loop
			End
			IF !lPosDesp
				cPosDesp:=Substr(xBuffer,17,10)
				nLenDesp:=1+Int(Val(Substr(xBuffer,20,3)))-Int(Val(Substr(xBuffer,17,3)))
				lPosDesp:=.t.
				nLidos+=85
				Loop
			End
			IF !lPosDesc
				cPosDesc:=Substr(xBuffer,17,10)
				nLenDesc:=1+Int(Val(Substr(xBuffer,20,3)))-Int(Val(Substr(xBuffer,17,3)))
				lPosDesc:=.t.
				nLidos+=85
				Loop
			End
			IF !lPosAbat
				cPosAbat:=Substr(xBuffer,17,10)
				nLenAbat:=1+Int(Val(Substr(xBuffer,20,3)))-Int(Val(Substr(xBuffer,17,3)))
				lPosAbat:=.t.
				nLidos+=85
				Loop
			EndIF
			IF !lPosPrin
				cPosPrin:=Substr(xBuffer,17,10)
				nLenPrin:=1+Int(Val(Substr(xBuffer,20,3)))-Int(Val(Substr(xBuffer,17,3)))
				lPosPrin:=.t.
				nLidos+=85
				Loop
			EndIF
			IF !lPosJuro
				cPosJuro:=Substr(xBuffer,17,10)
				nLenJuro:=1+Int(Val(Substr(xBuffer,20,3)))-Int(Val(Substr(xBuffer,17,3)))
				lPosJuro:=.t.
				nLidos+=85
				Loop
			EndIF
			IF !lPosMult
				cPosMult:=Substr(xBuffer,17,10)
				nLenMult:=1+Int(Val(Substr(xBuffer,20,3)))-Int(Val(Substr(xBuffer,17,3)))
				lPosMult:=.t.
				nLidos+=85
				Loop
			EndIF
			IF !lPosOcor
				cPosOcor:=Substr(xBuffer,17,10)
				nLenOcor:=1+Int(Val(Substr(xBuffer,20,3)))-Int(Val(Substr(xBuffer,17,3)))
				lPosOcor:=.t.
				nLidos+=85
				Loop
			EndIF
			IF !lPosTipo
				cPosTipo:=Substr(xBuffer,17,10)
				nLenTipo:=1+Int(Val(Substr(xBuffer,20,3)))-Int(Val(Substr(xBuffer,17,3)))
				lPosTipo:=.t.
				nLidos+=85
				Loop
			EndIF
			IF !lPosNsNum
				cPosNsNum := Substr(xBuffer,17,10)
				nLenNsNum := 1+Int(Val(Substr(xBuffer,20,3)))-Int(Val(Substr(xBuffer,17,3)))
				lPosNsNum := .t.
				nLidos += 85
				Loop
			EndIF
			IF !lPosRejei
				cPosRejei := Substr(xBuffer,17,10)
				nLenRejei := 1+Int(Val(Substr(xBuffer,20,3)))-Int(Val(Substr(xBuffer,17,3)))
				lPosRejei := .t.
				nLidos += 85
				Loop
			EndIF
			IF !lPosForne
				cPosForne := Substr(xBuffer,17,10)
				nLenForne := 1+Int(Val(Substr(xBuffer,20,3)))-Int(Val(Substr(xBuffer,17,3)))
				lPosForne := .t.
				nLidos += 85
				Loop
			EndIF
			IF !lPosCgc
				cPosCgc   := Substr(xBuffer,17,10)
				nLenCgc   := 1+Int(Val(Substr(xBuffer,20,3)))-Int(Val(Substr(xBuffer,17,3)))
				lPosCgc   := .t.
				nLidos += 85
				Loop
			EndIF
			IF !lPosDebito
				cPosDebito:=Substr(xBuffer,17,10)
				nLenDebito:=1+Int(Val(Substr(xBuffer,20,3)))-Int(Val(Substr(xBuffer,17,3)))
				lPosDebito:=.t.
				nLidos+=85
				Loop
			EndIF
		EndDo
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Fecha arquivo de configuracao ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		Fclose(nHdlConf)
	EndIf
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Abre arquivo enviado pelo banco ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lRet
		//MV_LOCREC  -Parâmetro onde será gravado o diretório

		If Empty(cLocRec) .AND. !ExecSchedule()

			cArqEnt:=mv_par03

		Else
			If ExecSchedule()
				cArqEnt:=mv_par03
				// Verifica qual barra está o parâmetro , e o que está na ultima posição através do RAT
			ElseIf AT("\",alltrim(cLocRec))>0 .and. RAT("\",SUBSTR(alltrim(cLocRec),LEN(alltrim(cLocRec)),1)) = 0

				cArqEnt:=cLocRec+"\"+TRIM(mv_par03)

			ElseIf AT("\",alltrim(cLocRec))>0 .and. RAT("\",SUBSTR(alltrim(cLocRec),LEN(alltrim(cLocRec)),1)) > 0

				cArqEnt:=cLocRec+TRIM(mv_par03)

			ElseIf AT("/",alltrim(cLocRec))>0 .and. RAT("/",SUBSTR(alltrim(cLocRec),LEN(alltrim(cLocRec)),1)) > 0

				cArqEnt:=SuperGetMV( "MV_LOCREC" , .F. , .F. )+TRIM(mv_par03)

			ElseIf AT("/",alltrim(cLocRec))>0 .and. RAT("/",SUBSTR(alltrim(cLocRec),LEN(alltrim(cLocRec)),1)) = 0

				cArqEnt:=cLocRec+"/"+TRIM(mv_par03)

			Endif

		Endif 

		// Validar as Inconsistências 
		If !Empty(cLocRec) .and. (Empty(mv_par03) .or. AT(":",mv_par03)>0 .or. (AT("/",mv_par03)>0 .or. AT("\",mv_par03)>0))
			Help(" ",1,"F150ARQ",,STR0023,1,0) //"Nome do Arquivo de Saida Inválido
			Return .F.
		Endif

		If !FILE(cArqEnt)
			If ! lExecJob
				Help(" ",1,"NOARQENT")
			Endif

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Atualiza o log de processamento com o erro  ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			ProcLogAtu("ERRO","NOARQENT",Ap5GetHelp("NOARQENT"))

			lRet:= .F.
		Else
			nHdlBco:=FOPEN(cArqEnt,0+64)
		EndIF
	EndIf

	If lRet
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Lˆ arquivo enviado pelo banco ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		nLidos:=0
		FSEEK(nHdlBco,0,0)
		nTamArq:=FSEEK(nHdlBco,0,2)
		FSEEK(nHdlBco,0,0)

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Desenha o cursor e o salva para poder moviment -lo ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		ProcRegua( nTamArq/nBloco )

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Certifico de que o TRB esta fechado.                ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If (Select("TRB")<>0)
			dbSelectArea("TRB")
			dbCloseArea()
		EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Gera arquivo de Trabalho                            ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		AADD(aCampos,{"FILMOV"	,"C",IIf( lFWCodFil, FWGETTAMFILIAL, 2 ),0})
		AADD(aCampos,{"BANCO"	,"C",TamSx3("A6_COD")[1],0})
		AADD(aCampos,{"AGENCIA"	,"C",TamSx3("A6_AGENCIA")[1],0})
		AADD(aCampos,{"CONTA"	,"C",TamSx3("A6_NUMCON")[1],0})
		AADD(aCampos,{"DATAD"	,"D",08,0})
		AADD(aCampos,{"NATURE"	,"C",TAMSX3("E2_NATUREZ")[1],0})
		AADD(aCampos,{"MOEDA"	,"C",TAMSX3("E2_MOEDA")[1],0})
		AADD(aCampos,{"TOTAL"	,"N",17,2})

		If(_oFina430 <> NIL)

			_oFina430:Delete()
			_oFina430 := NIL

		EndIf

		_oFina430 := FwTemporaryTable():New("TRB")
		_oFina430:SetFields(aCampos)
		_oFina430:AddIndex("1",{"FILMOV","BANCO","AGENCIA","CONTA","DATAD"})
		_oFina430:Create()

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Carrega atributos do arquivo de configuracao                 ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		aArqConf := Directory(mv_par04)

		Begin Transaction

			While nLidos <= nTamArq
				IncProc()
				nDespes :=0
				nDescont:=0
				nAbatim :=0
				nValRec :=0
				nJuros  :=0
				nMulta  :=0
				nValCc  :=0
				nValPgto:=0
				nMoeda	:=0
				nTxMoeda:=0
				nCM     :=0
				ABATIMENTO := 0
				lPagAnt	:= .F.
				lProcDDA := .F.

				cFilAnt := cFilOrig	//Sempre restaura a filial original

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Tipo qual registro foi lido ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If ( MV_PAR10 == 1 )
					xBuffer:=Space(nBloco)
					FREAD(nHdlBco,@xBuffer,nBloco)
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Considera a primeira linha sempre³
					//³ como um cabe‡alho                ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If lHeader .AND. SubStr(xBuffer,1,1) != "1" .AND. Substr(xBuffer,1,3) != "001" .OR. (cBanco == "409" .and. SubStr(xBuffer,1,1) == "2")  
						If lFA430FIG
							cCGCFilHeader := Substr(xBuffer, 12,14) // ler o novo cnpj do header.	
						EndIf
					EndIf
					IF !lHeader
						lHeader := .T.
						nLidos	+=nBloco
						cCGCFilHeader := Substr(xBuffer, 12,14)
						Loop
					EndIF

					If SubStr(xBuffer,1,1) == "1" .or. Substr(xBuffer,1,3) == "001" .or.;
					(cBanco == "409" .and. SubStr(xBuffer,1,1) == "2")  // Unibanco

						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³ Lˆ os valores do arquivo Retorno ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						cNumTit :=Substr(xBuffer,Int(Val(Substr(cPosNum, 1,3))),nLenNum )
						cData   :=Substr(xBuffer,Int(Val(Substr(cPosData,1,3))),nLenData)
						cData   :=ChangDate(cData,SEE->EE_TIPODAT)
						dBaixa  :=Ctod(Substr(cData,1,2)+"/"+Substr(cData,3,2)+"/"+Substr(cData,5),"ddmm"+Replicate("y",Len(Substr(cData,5))))
						dDebito :=dBaixa		// se nao for preenchido, usa dBaixa
						cTipo   :=Substr(xBuffer,Int(Val(Substr(cPosTipo, 1,3))),nLenTipo )
						cNsNum  := " "

						If !Empty(cPosDesp)
							nDespes:=Round(Val(Substr(xBuffer,Int(Val(Substr(cPosDesp,1,3))),nLenDesp))/100,2)
						EndIf
						If !Empty(cPosDesc)
							nDescont:=Round(Val(Substr(xBuffer,Int(Val(Substr(cPosDesc,1,3))),nLenDesc))/100,2)
						EndIf
						If !Empty(cPosAbat)
							nAbatim:=Round(Val(Substr(xBuffer,Int(Val(Substr(cPosAbat,1,3))),nLenAbat))/100,2)
						EndIf
						If !Empty(cPosPrin)
							nValPgto :=Round(Val(Substr(xBuffer,Int(Val(Substr(cPosPrin,1,3))),nLenPrin))/100,2)
						EndIF
						If !Empty(cPosJuro)
							nJuros  :=Round(Val(Substr(xBuffer,Int(Val(Substr(cPosJuro,1,3))),nLenJuro))/100,2)
						EndIf
						If !Empty(cPosMult)
							nMulta  :=Round(Val(Substr(xBuffer,Int(Val(Substr(cPosMult,1,3))),nLenMult))/100,2)
						EndIf
						If !Empty(cPosNsNum)
							cNsNum  :=Substr(xBuffer,Int(Val(Substr(cPosNsNum,1,3))),nLenNsNum)
						EndIf
						IF !Empty(cPosRejei)
							cRejeicao  :=Substr(xBuffer,Int(Val(Substr(cPosRejei,1,3))),nLenRejei)
						End
						IF !Empty(cPosForne)
							cForne  :=Substr(xBuffer,Int(Val(Substr(cPosForne,1,3))),nLenForne)
						End

						nTamEEOcor := IIF(cPaisLoc == "BRA", SEE->EE_TAMOCOR, 2) // Tamanho da Ocorrencia Bancaria retornada pelo banco.
						cOcorr := Substr(xBuffer,Int(Val(Substr(cPosOcor,1,3))),nLenOcor)
						cOcorr := PadR( Left(Alltrim(cOcorr),nTamEEOcor) , nTamOcor)

						If !Empty(cPosCgc)
							cCgc  :=Substr(xBuffer,Int(Val(Substr(cPosCgc,1,3))),nLenCgc)
						Endif
						If !Empty(cPosDebito)
							cDebito :=Substr(xBuffer,Int(Val(Substr(cPosDebito,1,3))),nLenDebito)
							cDebito :=ChangDate(cDebito,SEE->EE_TIPODAT)
							If !Empty(cDebito)
								dDebito :=Ctod(Substr(cDebito,1,2)+"/"+Substr(cDebito,3,2)+"/"+Substr(cDebito,5),"ddmm"+Replicate("y",Len(Substr(cDebito,5))))
							Endif
						Endif
						nCM     := 0

						//Processo DDA - Bradesco
						cRastro	:= Substr(xBuffer,264,2)     //Operacao de rastreamento = 30 (Fixo)
						cDDA		:= Substr(xBuffer,279,2)		//Operacao de rastreamento = "FS" (Fixo)

						//Rastreamento DDA - Bradesco
						If lUsaDDA .and. cBanco = "237" .And. cRastro == "30" .and. cDDA == "FS"

							cBcoForn := Substr(xBuffer,096,3)		//01-03 Banco do cedente - Fornecedor
							cCodBar	:= ""							//Codigo de barras completo
							cFatorVc:= ""							//Fator de Vencimento
							cMoeda	:= "9"							//Moeda do titulo (9 = Real)
							cDV		:= ""							//Digito verificador do codigo de barras (sera calculado)
							cVencto	:= ""							//Data de vencimento
							cOcorr	:= PadR("FS",nTamOcor)			//Forco Ocorrencia pois a mesma pode voltar vazia em caso de rastreamento DDA

							//Calculo do Fator de Vencimento
							cVencto		:= Substr(xBuffer,166,8)
							cVencto  	:= ChangDate(cVencto,SEE->EE_TIPODAT)
							cVencto  	:= Substr(cVencto,1,2)+"/"+Substr(cVencto,3,2)+"/"+Substr(cVencto,5)
							cFatorVc	:= StrZero(ctod(cVencto) - ctod("07/10/97"),4)			//Fator de Vencimento

							//Valor do documento
							cValPgto := Substr(xBuffer,195,10)		//Valor do Titulo

							//Bando do Cedente = Bradesco
							If cBcoForn == "237"

								//Campo Livre do codigo de barras
								cCpoLivre:= Substr(xBuffer,100,4)+ ;		//Agencia
								Substr(xBuffer,137,2)+ ;	//Carteira
								Substr(xBuffer,140,11)+;	//Nosso Numero
								Substr(xBuffer,111,7)+ ;	//Conta corrente
								"0"							//Zero (fixo)

								//Bando do Cedente <> Bradesco
							Else

								cCpoLivre:= Substr(xBuffer,374,25)		//Campo Livre do codigo de barras

							Endif

							//Calculo do digito verificador do codigo de barras
							cDV := DV_BarCode(cBcoForn + cMoeda + cFatorVc + cValPgto + cCpoLivre)

							//Montagem do código de barras
							cCodBar :=	cBcoForn 	+ ;		//01-03 - Codigo do banco
							cMoeda		+ ;		//04-04 - Codigo da moeda
							cDV			+ ;		//05-05 - Digito verificador
							cFatorVc	+ ;		//06-09 - Fator vencimento
							cValPgto	+ ;		//10-19 - Valor do documento
							cCpoLivre			//20-44 - Campo Livre


							If !Empty(cCodBar)
								lProcDDA := .T.
							Endif

						Endif

						If lFa430Fil
							Execblock("FA430FIL",.F.,.F.,{xBuffer} )
						Endif

						If lF430Var
							//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
							//³ o array aValores ir  permitir ³
							//³ que qualquer exce‡„o ou neces-³
							//³ sidade seja tratado no ponto  ³
							//³ de entrada em PARAMIXB        ³
							//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
							// Estrutura de aValores
							//	Numero do T¡tulo	- 01
							//	data da Baixa		- 02
							// Tipo do T¡tulo		- 03
							// Nosso Numero			- 04
							// Valor da Despesa		- 05
							// Valor do Desconto	- 06
							// Valor do Abatiment	- 07
							// Valor Pagamento   	- 08
							// Juros				- 09
							// Multa				- 10
							// Fornecedor			- 11
							// Ocorrencia			- 12
							// CGC					- 13
							// nCM					- 14
							// Rejeicao				- 15
							// Linha Inteira		- 16

							aValores := ( { cNumTit, dBaixa, cTipo,;
							cNsNum, nDespes, nDescont,;
							nAbatim, nValPgto, nJuros,;
							nMulta, cForne, cOcorr,;
							cCGC, nCM, cRejeicao, xBuffer })

							ExecBlock("F430VAR",.F.,.F.,{aValores})

						Endif

						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³ Verifica especie do titulo    ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						nPos := Ascan(aTabela, {|aVal|aVal[1] == Alltrim(Substr(cTipo,1,3))})
						If nPos != 0
							cEspecie := aTabela[nPos][2]
						Else
							cEspecie	:= "  "
						EndIf
						If cEspecie $ MVABATIM		// Nao lˆ titulo de abatimento
							nLidos += nBloco
							Loop
						EndIf
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³ Ponto de entrada para permitir ou nao a baixa de ³
						//³ um determinadotipo de titulo. PA por exemplo.    ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						If lFa430Pa
							If !(ExecBlock("FA430PA",.F.,.F.,cEspecie))
								nLidos += nBloco
								Loop
							Endif
						Endif
					Else
						nLidos += nBloco
						Loop
					EndIf
				Else
					If Valtype(MV_PAR04)=="C"
						cArqConf := MV_PAR04
					Endif 
					aLeitura := ReadCnab2(nHdlBco,cArqConf,nBloco,aArqConf)
					cNumTit  := SubStr(aLeitura[1],1, nTamTit)
					cData    := aLeitura[04]
					cData    := ChangDate(cData,SEE->EE_TIPODAT)
					dBaixa   := Ctod(Substr(cData,1,2)+"/"+Substr(cData,3,2)+"/"+Substr(cData,5),"ddmm"+Replicate("y",Len(Substr(cData,5))))
					cTipo    := aLeitura[02]
					cNsNum   := aLeitura[11]
					nDespes  := aLeitura[06]
					nDescont := aLeitura[07]
					nAbatim  := aLeitura[08]
					nValPgto := aLeitura[05]
					nJuros   := aLeitura[09]
					nMulta   := aLeitura[10]
					cNsNum   := aLeitura[11]
					nTamEEOcor := IIF(cPaisLoc == "BRA", SEE->EE_TAMOCOR, 2)// Tamanho da Ocorrencia Bancaria retornada pelo banco.
					cOcorr   := PadR( Left(Alltrim(aLeitura[03]),nTamEEOcor) , nTamOcor)

					cForne   := aLeitura[16]
					dDebito	 := dBaixa
					xBuffer	 := aLeitura[17]

					//Segmento Z - Autenticacao
					If Len(aLeitura) > 17
						cAutentica := aLeitura[18]
					Endif

					//CGC
					If Len(aLeitura) > 19
						cCgc := aLeitura[20]
					Endif

					// Buscar a Conta Oficial. Abaixo alteramos os novos valores de acordo com a SEE
					If !Empty(cCtaOfi)
						cBanco		:= cBcoOfi
						cAgencia	:= cAgeOfi 
						cConta		:= cCtaOfi
					Else
						If Len(aLeitura) > 20
							cBanco	 := PAD(aLeitura[21],nTamBco)
							cAgencia := PAD(aLeitura[22],nTamAge)
							cConta	 := PAD(aLeitura[23],nTamCta)
						Else
							cBanco  := mv_par05
							cAgencia:= mv_par06
							cConta  := mv_par07
						Endif
					Endif

					//DDA - Debito Direto Autorizado
					If lUsaDDA .and. Len(aLeitura) > 23
						//Caso o CNPJ do Fornecedor seja retornado no Segmento H, assumo este valor
						If !Empty(aLeitura[24]) .and. Substr(aLeitura[24],1,7) != "0000000"
							cCgc := aLeitura[24]
						Endif
						cCodBar := aLeitura[25]
						If !Empty(cCodBar)
							lProcDDA := .T.
						Endif

					Endif

					If lF430Var
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³ o array aValores ir  permitir ³
						//³ que qualquer exce‡„o ou neces-³
						//³ sidade seja tratado no ponto  ³
						//³ de entrada em PARAMIXB        ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						// Estrutura de aValores
						// Numero do T¡tulo		- 01
						// Data da Baixa		- 02
						// Tipo do T¡tulo		- 03
						// Nosso Numero			- 04
						// Valor da Despesa		- 05
						// Valor do Desconto	- 06
						// Valor do Abatiment	- 07
						// Valor Pagamento   	- 08
						// Juros				- 09
						// Multa				- 10
						// Fornecedor			- 11
						// Ocorrencia			- 12
						// CGC					- 13
						// nCM					- 14
						// Rejeicao				- 15
						// Linha Inteira		- 16
						// Autenticacao 	    - 17
						// Banco             	- 18
						// Agencia           	- 19
						// Conta             	- 20
						aValores := ( { cNumTit, dBaixa, cTipo,;
						cNsNum, nDespes, nDescont,;
						nAbatim, nValPgto, nJuros,;
						nMulta, cForne, cOcorr,;
						cCGC, nCM,cRejeicao,xBuffer,;
						cAutentica,cBanco,cAgencia,cConta })

						ExecBlock("F430VAR",.F.,.F.,{aValores})

					Endif

					If Empty(cNumTit) .And. !lProcDDA
						nLidos += nBloco
						Loop
					Endif

					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Verifica especie do titulo    ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					nPos := Ascan(aTabela, {|aVal|aVal[1] == Alltrim(Substr(cTipo,1,3))})
					If nPos != 0
						cEspecie := aTabela[nPos][2]
					Else
						cEspecie	:= "  "
					EndIf
					If cEspecie $ MVABATIM			// Nao lˆ titulo de abatimento
						Loop
					EndIf
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Ponto de entrada para permitir ou nao a baixa de ³
					//³ um determinadotipo de titulo. PA por exemplo.    ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If lFa430Pa
						If !(ExecBlock("FA430PA",.F.,.F.,cEspecie))
							Loop
						Endif
					Endif
				EndIf
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Verifica se existe o titulo no SE2. Caso este titulo nao seja ³
				//³ localizado, passa-se para a proxima linha do arquivo retorno. ³
				//³ O texto do help sera' mostrado apenas uma vez, tendo em vista ³
				//³ a possibilidade de existirem muitos titulos de outras filiais.³
				//³ OBS: Sera verificado inicialmente se nao existe outra chave   ³
				//³ igual para tipos de titulo diferentes.                        ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				dbSelectArea("SE2")
				dbSetOrder( 1 )
				lHelp := .F.
				lAchouTit := .F.

				/*Verifica a data de baixa do arquivo em relação ao parâmetro MV_DATAFIN*/
				If AScan( aDtMvFinOk , dBaixa ) == 0
					If AScan( aDtMvFinNt , dBaixa ) == 0 
						If !DtMovFin( dBaixa , .F.,"1" )
							aAdd( aDtMvFinNt , dBaixa )		
							If mv_par10 == 1
								nLidos+=nBloco
							EndIf
							ProcLogAtu( "ERRO" , "DTMOVFIN" , Ap5GetHelp( "DTMOVFIN" ) + " " + DtoC( dBaixa ) )
							Loop
						Else
							aAdd( aDtMvFinOk , dBaixa )
						EndIf
					Else		
						If mv_par10 == 1
							nLidos+=nBloco
						EndIf
						Loop
					EndIf
				EndIf

				aValores := ( { cNumTit, dBaixa, cTipo, cNsNum, nDespes, nDescont, nAbatim, nValPgto, nJuros, nMulta, cForne, cOcorr, cCGC, nCM, cRejeicao, xBuffer })
				//Processamento normal - Nao se trata de processamento de arquivo de DDA
				If !lProcDDA
					// Ponto de entrada para posicionar o SE2
					If lFa430SE2 .and. !lProcDDA
						ExecBlock("FA430SE2", .F.,.F.,{aValores})
					Else
						// Se processa todas as filiais, tem o novo indice somente por IDCNAB e a filial da SE2 estah preenchida.
						If mv_par11 == 2 .And. !Empty(xFilial("SE2"))
							//Busca por IdCnab (sem filial)
							SE2->(dbSetOrder(13)) // IdCnab
							If SE2->(MsSeek(Substr(cNumTit,1,10)))
								cFilAnt	:= SE2->E2_FILIAL
								If lCtbExcl
									mv_par09 := 2  //Desligo contabilizacao on-line
								EndIf
							Endif
						Else
							//Busca por IdCnab
							SE2->(dbSetOrder(11)) // Filial+IdCnab
							SE2->(MsSeek(xFilial("SE2")+	Substr(cNumTit,1,10)))
						Endif

						//Se nao achou, utiliza metodo antigo (titulo)
						If SE2->(!Found())
							SE2->(dbSetOrder(1))
							//Chave retornada pelo banco
							cChave430 := IIf(!Empty(cForne),Pad(cNumTit,nTamTit)+cEspecie+SubStr(cForne,1,nTamForn),Pad(cNumTit,nTamTit)+cEspecie)
							While !lAchouTit
								If !dbSeek(xFilial()+cChave430)
									nPos := Ascan(aTabela, {|aVal|aVal[1] == AllTrim(Substr(cTipo,1,3))},nPos+1)
									If nPos != 0
										cEspecie := aTabela[nPos][2]
										cChave430 := IIf(!Empty(cForne),Pad(cNumTit,nTamTit)+cEspecie+SubStr(cForne,1,nTamForn),Pad(cNumTit,nTamTit)+cEspecie)
									Else
										Exit
									Endif
								Else
									lAchouTit := .T.
								Endif
							Enddo

							//Chave retornada pelo banco com a adicao de espacos para tratar chave enviada ao banco com
							//tamanho de nota de 6 posicoes e retornada quando o tamanho da nota e 9 (atual)
							If !lAchouTit
								cNumTit := SubStr(cNumTit,1,nTamPre)+Padr(Substr(cNumTit,4,6),nTamNum)+SubStr(cNumTit,10,nTamPar)
								cChave430 := IIf(!Empty(cForne),Pad(cNumTit,nTamTit)+cEspecie+SubStr(cForne,1,nTamForn),Pad(cNumTit,nTamTit)+cEspecie)
								nPos := Ascan(aTabela, {|aVal|aVal[1] == Alltrim(Substr(cTipo,1,3))})
								While !lAchouTit
									If !dbSeek(xFilial()+cChave430)
										nPos := Ascan(aTabela, {|aVal|aVal[1] == AllTrim(Substr(cTipo,1,3))},nPos+1)
										If nPos != 0
											cEspecie := aTabela[nPos][2]
											cChave430 := IIf(!Empty(cForne),Pad(cNumTit,nTamTit)+cEspecie+SubStr(cForne,1,nTamForn),Pad(cNumTit,nTamTit)+cEspecie)
										Else
											Exit
										Endif
									Else
										lAchouTit := .T.
									Endif
								Enddo
							Endif

							//Se achou o titulo, verificar o CGC do fornecedor
							If lAchouTit
								cNumSe2   := SE2->E2_PREFIXO+SE2->E2_NUM+SE2->E2_PARCELA+SE2->E2_TIPO
								cChaveSe2 := IIf(!Empty(cForne),cNumSe2+SE2->E2_FORNECE,cNumSe2)
								nPosEsp	  := nPos	// Gravo nPos para volta-lo ao valor inicial, caso encontre o titulo

								While !Eof() .and. SE2->E2_FILIAL+cChaveSe2 == xFilial("SE2")+cChave430
									nPos := nPosEsp
									If Empty(cCgc)
										Exit
									Endif
									dbSelectArea("SA2")
									If dbSeek(xFilial()+SE2->E2_FORNECE+SE2->E2_LOJA)
										If Substr(SA2->A2_CGC,1,14) == cCGC .or. StrZero(Val(SA2->A2_CGC),14,0) == StrZero(Val(cCGC),14,0)
											Exit
										Endif
									Endif
									dbSelectArea("SE2")
									dbSkip()
									cNumSe2   := SE2->E2_PREFIXO+SE2->E2_NUM+SE2->E2_PARCELA+SE2->E2_TIPO
									cChaveSe2 := IIf(!Empty(cForne),cNumSe2+SE2->E2_FORNECE,cNumSe2)
									nPos 	  := 0
								Enddo
							EndIF
						Else
							nPos := 1
						Endif

						If nPos == 0
							lHelp := .T.
						EndIF
					Endif

					If !lUmHelp .And. lHelp
						if ! lExecJob
							Help(" ",1,"NOESPECIE",,cNumTit+	" "+cEspecie,5,1)
						Endif

						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³ Atualiza o log de processamento com o erro  ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						ProcLogAtu("ERRO","NOESPECIE",Ap5GetHelp("NOESPECIE"))

						lUmHelp := .T.
					Endif
				Endif


				// Retorno Automatico via Job
				// controla o status para emissao do relatorio de processamento
				if ExecSchedule()
					cStProc := ""
					if ! lAchouTit
						cStProc := STR0019 // "Titulo Inexistente"
						Aadd(aFa205R,{cNumTit,"", "", dBaixa,	0, nValPgto, cStProc })
					Elseif lHelp
						cStProc := STR0020 // "Titulo com Erro"
					Endif
				Endif

				If !lHelp
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Verifica codigo da ocorrencia ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					dbSelectArea("SEB")
					dbSetOrder(1)
					If !(dbSeek(xFilial("SEB")+mv_par05+cOcorr+"P"))
						if ! lExecJob
							Help(" ",1,"FA430OCORR")
						Endif

						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³ Atualiza o log de processamento com o erro  ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						ProcLogAtu("ERRO","FA430OCORR",Ap5GetHelp("FA430OCORR"))

					Endif
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Reposicionar o SEB para uma chave diferente, que considere³
					//³ tamb‚m, campos espec¡ficos criados no SEB.                ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If lFa430Oco
						ExecBlock("FA430OCO", .F., .F., {aValores})
					Endif
					dbSelectArea("SE2")
					IF ( SEB->EB_OCORR $ "01|06|07|08" )      //Baixa do Titulo

						lPagAnt := SE2->E2_TIPO $ MVPAGANT
						If lFA430LP
							lTrocaLP:= ExecBlock("FA430LP",.F.,.F.)
						Endif
						If !lTrocaLP
							cPadrao:="530"
						Else
							cPadrao:="532"
						EndIf
						cPadrao := If( lPagAnt, "513", cPadrao)
						If cPadrao != cPadAux // Prote‡?o de performance
							lPadrao := VerPadrao(cPadrao)
							lContabiliza := Iif(mv_par09==1,.T.,.F.)
							cPadAux := cPadrao
						EndIf

						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³ Monta Contabilizacao.         ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						If !lCabec .and. lPadrao .and. lContabiliza
							nHdlPrv := HeadProva( cLote,;
							"FINA430",;
							substr( cUsuario, 7, 6 ),;
							@cArquivo )

							lCabec := .T.
						EndIf

						nValEstrang := SE2->E2_SALDO
						lDesconto   := .F.
						nTotAbat	:= SumAbatPag(SE2->E2_PREFIXO,SE2->E2_NUM,SE2->E2_PARCELA,;
						SE2->E2_FORNECE,SE2->E2_MOEDA,"S",dBaixa,SE2->E2_LOJA)
						ABATIMENTO  := nTotAbat

						// Ajusta tamanho suportado pelo campo de Autenticacao Bancÿria
						cAutentica	:= PadR(Alltrim(cAutentica),TamSx3("FK2_AUTBCO")[1])

						If !Empty(cCtaOfi) .and. !lAltPort
							cBanco		:= cBcoOfi
							cAgencia	:= cAgeOfi 
							cConta		:= cCtaOfi
						Else
							If lAltPort
								dbSelectArea("SEA")
								dbSetOrder(1)
								dbSeek(xFilial()+SE2->E2_NUMBOR+SE2->E2_PREFIXO+SE2->E2_NUM+SE2->E2_PARCELA+SE2->E2_TIPO+SE2->E2_FORNECE+SE2->E2_LOJA)
								cBanco      := IiF(Empty(SEA->EA_PORTADO),cBanco,SEA->EA_PORTADO)
								cAgencia    := IiF(Empty(SEA->EA_AGEDEP),cAgencia,SEA->EA_AGEDEP)
								cConta      := IiF(Empty(SEA->EA_NUMCON),cConta,SEA->EA_NUMCON)
							ElseIf Empty(cBanco+cAgencia+cConta)
								cBanco      := mv_par05
								cAgencia    := mv_par06
								cConta      := mv_par07
							EndIf
						Endif

						cHist070    := STR0008  //"Valor Pago s/ Titulo"

						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³ Verifica se a despesa esta    ³
						//³ descontada do valor principal ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						If SEE->EE_DESPCRD == "S"
							nValPgto+=nDespes
						EndIF
						nTotAger += nValPgto
						cLanca := Iif(mv_par09==1,"S","N")
						cBenef := SE2->E2_NOMFOR

						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³ Ponto de Entrada para Tratamento baixa           ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						If ExistBlock("FA430LRM")
							ExecBlock("FA430LRM",.F.,.F.,{xBuffer})
						Endif

						If SE2->E2_TIPO $ MVPAGANT+"/"+MVTXA

							DbSelectArea("SE5")
							SE5->( DbSetOrder(7) )
							SE5->( DbGoTop() )

							// Busca movimentação já existente para este PAGAMENTO ANTECIPADO
							If !MsSeek(xFilial("SE5") + SE2->(E2_PREFIXO + E2_NUM + E2_PARCELA + E2_TIPO + E2_FORNECE + E2_LOJA) ) .Or. ;
							( MsSeek(xFilial("SE5") + SE2->(E2_PREFIXO + E2_NUM + E2_PARCELA + E2_TIPO + E2_FORNECE + E2_LOJA) ) .And. ( SE5->E5_TIPODOC = "BA" .And. SE5->E5_MOTBX = "PCC" ) .And. SE2->(E2_PIS + E2_COFINS + E2_CSLL + E2_IRRF) > 0 )  

								//Define os campos que não existem na FK5 e que serão gravados apenas na E5, para que a gravação da E5 continue igual
								If !Empty(cCamposE5)
									cCamposE5 += "|"
								Endif
								//Estrutura para o E5_CAMPOS: "{{'SE5->CAMPO', Valor}, {'SE5->CAMPO', Valor}}"
								cCamposE5 += "{"
								cCamposE5 += " {'E5_DTDIGIT', dDataBase  }"
								cCamposE5 += ",{'E5_LOTE'	, '" + cLoteFin	 + "'}"
								cCamposE5 += ",{'E5_TIPO'	, '" + If(lPagAnt,MVPAGANT,MVTXA)	 + "'}"
								cCamposE5 += ",{'E5_BENEF'  , '" + Iif(Empty(cBenef),SA2->A2_NOME,cBenef)+"'   }" // JBS - 26/08/2013 - Gravação do nome do Benenficiario -   SA2->A2_NOME
								cCamposE5 += ",{'E5_PREFIXO', '" + SE2->E2_PREFIXO	+ "'}"
								cCamposE5 += ",{'E5_NUMERO'	, '" + SE2->E2_NUM		+ "'}"
								cCamposE5 += ",{'E5_PARCELA', '" + SE2->E2_PARCELA	+ "'}"
								cCamposE5 += ",{'E5_CLIFOR'	, '" + SE2->E2_FORNECE	+ "'}"
								cCamposE5 += ",{'E5_FORNECE', '" + SE2->E2_FORNECE	+ "'}"					
								cCamposE5 += ",{'E5_LOJA'	, '" + SE2->E2_LOJA		+ "'}"
								cCamposE5 += ",{'E5_MOTBX'	, 'NOR'}"
								cCamposE5 += "}"

								oModelMov := FWLoadModel("FINM030")					//Model de Movimento a Receber
								oModelMov:SetOperation( MODEL_OPERATION_INSERT )	//Inclusao
								oModelMov:Activate()
								oModelMov:SetValue( "MASTER", "E5_GRV"		,.T.		)	//Informa se vai gravar SE5 ou não
								oModelMov:SetValue( "MASTER", "NOVOPROC"	,.T.		)	//Informa que a inclusão será feita com um novo número de processo
								oModelMov:SetValue( "MASTER", "E5_CAMPOS"	,cCamposE5 )	//Informa os campos da SE5 que serão gravados indepentes de FK5

								oSubFK5 := oModelMov:GetModel("FK5DETAIL")
								oSubFKA := oModelMov:GetModel("FKADETAIL")

								oSubFKA:SetValue( "FKA_IDORIG", FWUUIDV4() )
								oSubFKA:SetValue( "FKA_TABORI", "FK5" )

								//Dados da tabela auxiliar com o código do título a pagar
								cChaveTit := xFilial("SE2") + "|" + SE2->E2_PREFIXO + "|" + SE2->E2_NUM 	+ "|" + SE2->E2_PARCELA + "|" + ;
								SE2->E2_TIPO 	+ "|" + SE2->E2_FORNECE + "|" + SE2->E2_LOJA

								cIDDoc := FINGRVFK7("SE2", cChaveTit)

								//Informacoes do movimento
								oSubFK5:SetValue( "FK5_ORIGEM"	, FunName() )
								oSubFK5:SetValue( "FK5_DATA"	, dBaixa )
								oSubFK5:SetValue( "FK5_VALOR"	, SE2->E2_VLCRUZ )
								oSubFK5:SetValue( "FK5_VLMOE2"	, SE2->E2_VALOR )
								oSubFK5:SetValue( "FK5_MOEDA"	, StrZero(SE2->E2_MOEDA,2))
								oSubFK5:SetValue( "FK5_NATURE"	, SE2->E2_NATUREZ	)
								oSubFK5:SetValue( "FK5_RECPAG"	, "P" )
								oSubFK5:SetValue( "FK5_TPDOC"	, If(lPagAnt,"PA","VL"))
								oSubFK5:SetValue( "FK5_HISTOR"	, SE2->E2_HIST )
								oSubFK5:SetValue( "FK5_BANCO"	, cBanco )
								oSubFK5:SetValue( "FK5_AGENCI"	, cAgencia )
								oSubFK5:SetValue( "FK5_CONTA"	, cConta )
								oSubFK5:SetValue( "FK5_DTDISP"	, dBaixa )
								oSubFK5:SetValue( "FK5_FILORI"	, cFilAnt )
								oSubFK5:SetValue( "FK5_IDDOC"   , cIDDoc )
								oSubFK5:SetValue( "FK5_LA"	    , If( lPadrao .And. (cLanca == "S") .and. !lUsaFlag,"S","N") )
								oSubFK5:SetValue( "FK5_CCUSTO"  , SE2->E2_CCUSTO)
								If SpbInUse()
									oSubFK5:SetValue( "FK5_MODSPB"	, SE2->E2_MODSPB )
								Endif
								If SE2->E2_RATEIO == "S"
									oSubFK5:SetValue( "FK5_RATEIO",  "1" )
								Else
									oSubFK5:SetValue( "FK5_RATEIO",  "2" )
								EndIf
								If oModelMov:VldData()
									oModelMov:CommitData()
									SE5->(dbGoto(oModelMov:GetValue( "MASTER", "E5_RECNO" )))
								Else
									lRet := .F.
									cLog := cValToChar(oModelMov:GetErrorMessage()[4]) + ' - '
									cLog += cValToChar(oModelMov:GetErrorMessage()[5]) + ' - '
									cLog += cValToChar(oModelMov:GetErrorMessage()[6])
									Help( ,,"FA430GerPA",,cLog, 1, 0 )
								Endif
								oModelMov:DeActivate()
								oModelMov:Destroy()
								oModelMov := Nil
								oSubFK5   := Nil
								oSubFKA	:= Nil

								If lPadrao .And. cLanca == "S" .and. !lUsaFlag
									RecLock("SE2",.F.)
									SE2->E2_LA	:= "S"
									MsUnlock()
								EndIf

								If lUsaFlag // Armazena em aFlagCTB para atualizar no modulo Contabil
									aAdd( aFlagCTB, { "E5_LA", "S", "SE5", SE5->( RecNo() ), 0, 0, 0} )
									aAdd( aFlagCTB, { "E2_LA", "S", "SE2", SE2->( RecNo() ), 0, 0, 0} )
								EndIf

								If SE2->E2_TIPO $ MVTXA
									Reclock("SE2",.F.)
									SE2->E2_OK := 'TA'
									SE2->(MsUnlock())
								EndIf

								AtuSalBco( cBanco,cAgencia,cConta,SE5->E5_DTDISPO,SE5->E5_VALOR,"-" )
								lBaixou := .T.
								lMovAdto := .T.
							EndIf
						Else

							// Tratamento Moeda Estrangeira
							nMoeda		:= SE2->E2_MOEDA
							nTxMoeda 	:= IIF(nMoeda > 1, IIF(SE2->E2_TXMOEDA > 0 .and. Empty(SE2->E2_DTVARIA), SE2->E2_TXMOEDA,RecMoeda(dBaixa,nMoeda)),0)

							// Serao usadas na Fa080Grv para gravar a baixa do titulo, considerando os acrescimos e decrescimos
							nAcresc     := Round(NoRound(xMoeda(SE2->E2_SDACRES,nMoeda,1,dBaixa,3),3),2)
							nDecresc    := Round(NoRound(xMoeda(SE2->E2_SDDECRE,nMoeda,1,dBaixa,3),3),2)

							nDescont := nDescont - nDecresc
							nJuros	:= nJuros - nAcresc

							if nDescont < 0
								nDescont := 0
							Endif 

							if nJuros < 0
								nJuros := 0
							Endif 

							If cPaisLoc == "BRA" 
								If lMVCNBImpg

									aTit := {} 
									lMsErroAuto := .F.
									aAreaCnab := GetArea()
									dbSelectArea("SA2")
									SA2->( dbSetOrder(1) )
									dbSeek(xFilial("SA2")+SE2->E2_FORNECE+SE2->E2_LOJA)
									lIRPFBaixa := IIf( cPaisLoc = "BRA" , SA2->A2_CALCIRF == "2", .F.) .And. Posicione("SED",1,xfilial("SED") + SE2->(E2_NATUREZ),"ED_CALCIRF") = "S" .And. !SE2->E2_TIPO $ MVPAGANT
									RestArea(aAreaCnab)

									nOldValPgto	:= nValPgto
									nValPgto := nValPgto - nJuros + nDescont - nMulta - nAcresc + nDecresc

									nValImp := SE2->( E2_PIS + E2_COFINS + E2_CSLL + E2_IRRF + E2_ISS + E2_INSS )
									nVlrCnab := SE2->E2_VALOR -  nTotAbat

									//Valores acessorios
									nVlrCnab	:= nVlrCnab + nJuros - nDescont + nMulta + nAcresc - nDecresc

									// IRRF
									If lIRPFBaixa
										nVlrCnab -= SE2->E2_IRRF
									EndIf

									// PCC
									If lPCCBaixa
										nVlrCnab -= SE2->( E2_PIS + E2_COFINS + E2_CSLL )
									EndIf

									Do Case
										Case nOldValPgto == 0
										lRet := .F.							
										Case nOldValPgto == nVlrcnab
										cTipoBx := "Baixa Total por CNAB"	
										Case nOldValPgto - nValImp == nVlrcnab 		// Caso o cliente pague o valor bruto do t­tulo ao inv?s do l­quido
										cTipoBx := "Baixa Total por CNAB"														
										nOldValPgto -= nValImp
										Case nOldValPgto + nValImp < nVlrcnab					
										cTipoBx := "Baixa parcial por CNAB"							   									   	
										Case nOldValPgto + nValImp > nVlrcnab 
										cTipoBx := "Baixa Total a mais por CNAB"
										lVlrMaior	:= .T.
										nVlrMaior	:= nOldValPgto - nVlrcnab
									EndCase 

									nValPgto := Round(NoRound(nValPgto,2),2)

									If lRet
										AADD( aTit, { "E2_FILIAL"	, xFilial("SE2")	, Nil})
										AADD( aTit, { "E2_PREFIXO"	, SE2->E2_PREFIXO	, Nil } )
										AADD( aTit, { "E2_NUM"		, SE2->E2_NUM		, Nil } )
										AADD( aTit, { "E2_PARCELA"	, SE2->E2_PARCELA	, Nil } )
										AADD( aTit, { "E2_TIPO"		, SE2->E2_TIPO		, Nil } )
										AADD( aTit, { "E2_FORNECE"	, SE2->E2_FORNECE	, Nil})
										AADD( aTit, { "E2_LOJA"		, SE2->E2_LOJA		, Nil})
										AADD( aTit, { "AUTMOTBX"  	, cMotbx 			, Nil } )	
										AADD( aTit, { "AUTBANCO"	, cBanco			, Nil})
										AADD( aTit, { "AUTAGENCIA" 	, cAgencia			, Nil})
										AADD( aTit, { "AUTCONTA"	, cConta			, Nil})
										AADD( aTit, { "AUTDTBAIXA"	, dBaixa			, Nil } )
										AADD( aTit, { "AUTDTCREDITO", dDebito			, Nil } )
										AADD( aTit, { "AUTHIST"   	, cTipoBx		   	, Nil } )
										AADD( aTit, { "AUTVLRPG"  	, nValPgto - nVlrMaior , Nil } )
										AADD( aTit, { "AUTJUROS"  	, nJuros			, Nil } )
										AADD( aTit, { "AUTDESCONT" 	, nDescont			, Nil } )
										AADD( aTit, { "AUTMULTA" 	, nMulta			, Nil } )
										AADD( aTit, { "AUTACRESC" 	, nAcresc			, Nil } )
										AADD( aTit, { "AUTDECRESC" 	, nDecresc			, Nil } )

										MSExecAuto({|x, y, a, b, c, d| FINA080(x, y, a, b, c, d)}, aTit, 3,,,lOnline,lOnline)

										If  lMsErroAuto
											MOSTRAERRO()     
											DisarmTransaction()
											lBaixou := .F.
										Else
											lBaixou := .T.
										EndIf
										// recarrega os mv_parx da rotina fina430, pois foi alterado no fina080
										pergunte("AFI430",.F.)								
									Endif
								Else
									lBaixou:=fA080Grv(lPadrao,.F.,.T.,cLanca, mv_par03, nTxMoeda,,,,,,@aCtBaixa) // Retorno Automatico via Job							
									lF080Grv := .T.
									lMovAdto := .F.
								Endif
							Else
								lBaixou:=fA080Grv(lPadrao,.F.,.T.,cLanca, mv_par03,,,,,,,@aCtBaixa) // Retorno Automatico via Job
								lF080Grv := .T.
								lMovAdto := .F.
							EndIf

							If lF080Grv
								If !Empty(aCtBaixa) .and. !lUsaFlag
									For nX := 1 to Len(aCtBaixa)
										If aCtBaixa[nX, 1] == "FK2"
											dbSelectArea("FK2")
											FK2->(dbSetOrder(1))
											If FK2->(dbSeek( xFilial("FK2") + aCtBaixa[nX, 2] ))
												RecLock("FK2",.F.)
												FK2->FK2_LA := "S"
												MsUnlock()
											EndIf
										ElseIf aCtBaixa[nX, 1] == "FK5"
											dbSelectArea("FK5")
											FK5->(dbSetOrder(1))
											If FK5->(dbSeek( xFilial("FK5") + aCtBaixa[nX, 2] ))
												RecLock("FK5",.F.)
												FK5->FK5_LA := "S"
												MsUnlock()
											EndIf
										Elseif aCtBaixa[nX, 1] == "SE5"
											dbSelectArea("SE5")
											DbGoTo(aCtBaixa[nX, 2])
											If SE5->(!BoF() .And. !EoF())
												RecLock("SE5",.F.)
												SE5->E5_LA := "S"
												MsUnlock()
											EndIf
										EndIf
									Next nX
								EndIf
								lF080Grv := .F.
							EndIf


						EndIf

						// Retorno Automatico via Job
						// armazena os dados do titulo para emissao de relatorio de processamento
						If ExecSchedule()
							if lBaixou
								Aadd(aFa205R,{SE2->E2_NUM,	SE2->E2_FORNECE,SE2->E2_LOJA,dBaixa,SE2->E2_VALOR, nValPgto, "Baixado ok" })
							Else
								Aadd(aFa205R,{SE2->E2_NUM,	SE2->E2_FORNECE,SE2->E2_LOJA,dBaixa,SE2->E2_VALOR, nValPgto, cStProc })
							Endif
						Endif

						If lBaixou .and. !lMovAdto		// somente gera pro lote quando nao for PA para nao duplicar no Extrato
							dbSelectArea("TRB")
							If !(dbSeek(xFilial("SE5")+cBanco+cAgencia+cConta+Dtos(dDebito)))
								Reclock("TRB",.T.)
								Replace FILMOV	With xFilial("SE5")
								Replace BANCO		With cBanco
								Replace AGENCIA	With cAgencia
								Replace CONTA		With cConta
								Replace DATAD		With dDebito
								Replace NATURE	With cNatLote 
								Replace MOEDA		With StrZero(SE2->E2_MOEDA,2)
							Else
								Reclock("TRB",.F.)
							Endif
							Replace TOTAL WITH TOTAL + nValPgto
							MsUnlock()
						Endif

						If lUsaFlag .and. lBaixou// Armazena em aFlagCTB para atualizar no modulo Contabil
							aAdd( aFlagCTB, { "E5_LA", "S", "SE5", SE5->( RecNo() ), 0, 0, 0} )
						EndIf

						If lF430Baixa
							Execblock("F430BXA",.F.,.F.)
						Endif

						If lBaixou
							//Contabiliza Rateio Multinatureza
							If lMultNat .and. (SE2->E2_MULTNAT == "1")
								MultNatB("SE2", .F., "1", @lOk, @aColsSEV, @lMultNat, .T.)
								If lOk
									MultNatC("SE2", @nHdlPrv, @nTotal,;
									@cArquivo, (mv_par09 == 1), .T., "1",;
									@nTotLtEZ, lOk, aColsSEV, lBaixou)
								Endif
							Else
								//Contabiliza o que nao possuir rateio multinatureza
								If lCabec .and. lPadrao .and. lContabiliza .and. lBaixou
									nTotal += DetProva( nHdlPrv,;
									cPadrao,;
									"FINA430" /*cPrograma*/,;
									cLote,;
									/*nLinha*/,;
									/*lExecuta*/,;
									/*cCriterio*/,;
									/*lRateio*/,;
									/*cChaveBusca*/,;
									/*aCT5*/,;
									/*lPosiciona*/,;
									@aFlagCTB,;
									/*aTabRecOri*/,;
									/*aDadosProva*/ )
								EndIf
							Endif
						EndIf
					EndIf

					If ( SEB->EB_OCORR $ "03" )      //Titulo Rejeitado
						dbSelectArea("SE2")
						dbSetOrder(11)  // Filial+IdCnab
						If !DbSeek(xFilial("SE2")+	Substr(cNumTit,1,nTamTit))
							dbSetOrder(1)
							dbSeek(xFilial()+Pad(cNumTit,nTamTit)+cEspecie) // Filial+Prefixo+Numero+Parcela+Tipo
						Endif
						cFilAux := cFilAnt
						cFilAnt := cFilOrig //Restauro a filial de origem que estava logada para posicionar o borderô correto
						dbSelectArea("SEA")
						dbSetOrder(1)
						dbSeek(xFilial()+SE2->E2_NUMBOR+SE2->E2_PREFIXO+;
						SE2->E2_NUM+SE2->E2_PARCELA+;
						SE2->E2_TIPO+SE2->E2_FORNECE+SE2->E2_LOJA)
						If ( Found() .And. SE2->E2_SALDO != 0 )
							//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
							//³ PONTO DE ENTRADA F430REJ                                     ³
							//³ Tratamento de dados de titulo rejeitado antes de "zerar" os 	³
							//³ dados do mesmo.                                               ³
							//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
							If lF430Rej
								Execblock("F430REJ",.F.,.F.)
							Endif
							FA590Canc()// Chamada Função FA590Canc para que o Título seja retirado corretamente do borderô Imp.							
							cFilAnt := cFilAux
						EndIf
					EndIf

					//DDA - Debito Direto Autorizado
					If lUsaDDA .and. lProcDDA .and. SEB->EB_OCORR $ "02"      //Entrada de titulo via DDA

						// Ponto de entrada para permitir alteracoes no CGC antes de posicionar o fornecedor
						// para gravacao de dados na tabela FIG
						If lFA430FIG
							dbSelectArea("SA2")
							dbSetOrder(3)	

							if !Empty(cCGC)
								If MsSeek(xFilial("SA2")+cCGC)
									cCodForn := SA2->A2_COD
								EndIf			
							EndIf	
							cQuery := "SELECT SE2.E2_PREFIXO,SE2.E2_NUM,SE2.E2_PARCELA,SE2.E2_FORNECE,SE2.E2_LOJA FROM " + RetSqlName("SE2") + " SE2 " 
							cQuery += "WHERE SE2.E2_IDCNAB = '" + cNumTit + "' AND SE2.E2_FORNECE = '" + SA2->A2_COD + "' AND SE2.D_E_L_E_T_ <> '*'" 				
							cQuery := ChangeQuery(cQuery)
							dbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), cAliasTmp, .F., .T. )
							(cAliasTmp)->(DbGotop())
							cCGC := ExecBlock( "FA430FIG", .F., .F., { cCGC, cCodForn,(cAliasTmp)->E2_PREFIXO,cNumTit,(cAliasTmp)->E2_PARCELA})
							(cAliasTmp)->(DbCloseArea())
						EndIf

						//Posiciona cadastro de fornecedores para obter
						//- Codigo do Fornecedor
						//- Loja do Fornecedor
						//Caso nao encontre os dados do Fornecedor, os dados ficarao em branco
						//Para que o usuario possa visualizar esta falha de cadastro.
						dbSelectArea("SA2")
						dbSetOrder(3)
						MsSeek(xFilial()+cCGC)

						//Grava arquivo de conciliação DDA
						RecLock("FIG",.T.)
						FIG_FILIAL	:= xFilial("FIG")
						FIG_DATA	:= dDataBase
						FIG_FORNEC	:= SA2->A2_COD
						FIG_LOJA	:= SA2->A2_LOJA
						FIG_NOMFOR	:= SA2->A2_NREDUZ
						FIG_TITULO	:= cNumTit
						FIG_TIPO	:= cEspecie
						FIG_VENCTO	:= dBaixa
						FIG_VALOR	:= nValPgto
						FIG_CONCIL	:= "2"
						FIG_CNPJ	:= cCGC
						FIG_CODBAR	:= cCodBar
						MsUnlock()
					Endif

					//Ponto de entrada para gravar na tabela fig a filial pertecente ao cnpj da linha header contido do arquivo .ret			
					If lF430GRAFIL
						aAreaCorr := GetArea()		
						DbSelectArea("SM0")
						SM0->(DbGoTop())

						cCGCFilHeader := Iif(mv_par10 == 1, cCGCFilHeader, cCGC) 

						While SM0->( !Eof() ) .And. !Empty(cCGCFilHeader)
							If (cCGCFilHeader == SM0->M0_CGC)						
								Exit												
							EndIf 					
							SM0->( DbSkip() )
						EndDo

						ExecBlock( "F430GRAFIL", .F., .F., SM0->M0_CODFIL)

						RestArea(aAreaCorr)				
					EndIf

					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
					//³Integracao protheus X tin	³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
					If FWHasEAI("FINA080",,,.T.)
						ALTERA := .T.
						INCLUI := .F.
						FwIntegDef( 'FINA080' )
					Endif

				EndIf

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				// A funcao ReadCnab2 se encarrega de incrementar a leitura, portanto
				// a incrementacao so devera ser feita no caso do CNAB "1"
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				If mv_par10 == 1
					nLidos+=nBloco
				EndIf
			EndDo

			cFilAnt := cFilOrig		// Sempre restaura a filial original

			If lCabec .and. lPadrao .and. lContabiliza
				dbSelectArea("SE2")
				dbGoBottom()
				dbSkip()
				SE5->(dbGoBottom())
				SE5->(dbSkip())
				VALOR := nTotAger
				ABATIMENTO := 0
				nTotal += DetProva( nHdlPrv,;
				cPadrao,;
				"FINA430" /*cPrograma*/,;
				cLote,;
				/*nLinha*/,;
				/*lExecuta*/,;
				/*cCriterio*/,;
				/*lRateio*/,;
				/*cChaveBusca*/,;
				/*aCT5*/,;
				/*lPosiciona*/,;
				@aFlagCTB,;
				/*aTabRecOri*/,;
				/*aDadosProva*/ )
			Endif

			IF lPadrao .and. lContabiliza .and. lCabec
				RodaProva(  nHdlPrv,;
				nTotal )

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Envia para Lancamento Contabil                      ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				lDigita:=IIF(mv_par01==1,.T.,.F.)
				lAglut :=IIF(mv_par02==1,.T.,.F.)
				cA100Incl( cArquivo,;
				nHdlPrv,;
				3 /*nOpcx*/,;
				cLote,;
				lDigita,;
				lAglut,;
				/*cOnLine*/,;
				/*dData*/,;
				/*dReproc*/,;
				@aFlagCTB,;
				/*aDadosProva*/,;
				/*aDiario*/ )

				aFlagCTB := {}  // Limpa o coteudo apos a efetivacao do lancamento
			End

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Ponto de entrada para renomear arquivo de retorno   ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			IF (ExistBlock("FA430REN"))
				FCLOSE(nHdlBco)
				ExecBlock("FA430REN",.f.,.f.)
			Endif

			// Atualiza os dados da multa pelo SIGAFIN, quando feito retorno pagamento.
			If FindFunction( "NGBAIXASE2" ) .And. GetNewPar( "MV_NGMNTFI","N" ) == 'S' //Se houver integração entre os módulos Manutenção de Ativos e Financeiro
				NGBAIXASE2( 1 )
			Endif

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Grava no SEE o n£mero do £ltimo lote recebido e gera ³
			//³ movimentacao bancaria											³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If !Empty(cLoteFin) .and. lBxCnab
				If TRB->(Reccount()) > 0
					RecLock("SEE",.F.)
					SEE->EE_LOTECP := cLoteFin
					MsUnLock()
					dbSelectArea("TRB")
					dbGotop()
					While !Eof()
						cFilAnt := TRB->FILMOV

						//Define os campos que não existem na FK5 e que serão gravados apenas na E5, para que a gravação da E5 continue igual
						//Estrutura para o E5_CAMPOS: "{{'SE5->CAMPO', Valor}, {'SE5->CAMPO', Valor}}"
						cCamposE5 := "{"
						cCamposE5 += " {'E5_DTDIGIT'	,STOD('" + DTOS(TRB->DATAD) + "')}"
						cCamposE5 += ",{'E5_TIPODOC'	,' '}"
						cCamposE5 += ",{'E5_LOTE'	,'" + cLoteFin + "'}"
						cCamposE5 += "}"

						oModelMov := FWLoadModel("FINM030")							//Model de Movimento Bancário
						oModelMov:SetOperation( MODEL_OPERATION_INSERT )			//Inclusao
						oModelMov:Activate()										//Ativa o modelo de dados
						oModelMov:SetValue( "MASTER","E5_GRV"		,.T.		)	//Informa se vai gravar SE5 ou não
						oModelMov:SetValue( "MASTER","NOVOPROC"		,.T.		)	//Informa que a inclusão será feita com um novo número de processo
						oModelMov:SetValue( "MASTER","E5_CAMPOS"	,cCamposE5	)	//Informa os campos da SE5 que serão gravados indepentes de FK5

						oSubFK5 := oModelMov:GetModel("FK5DETAIL")
						oSubFKA := oModelMov:GetModel("FKADETAIL")

						oSubFKA:SetValue( "FKA_IDORIG", FWUUIDV4() )
						oSubFKA:SetValue( "FKA_TABORI", "FK5" )

						//Informacoes do movimento
						oSubFK5:SetValue( "FK5_ORIGEM"	,FunName() )
						oSubFK5:SetValue( "FK5_DATA"	,Iif(!Empty(TRB->DATAD),TRB->DATAD,dBaixa) )
						oSubFK5:SetValue( "FK5_VALOR"	,TRB->TOTAL )
						oSubFK5:SetValue( "FK5_RECPAG"	,"P" )
						oSubFK5:SetValue( "FK5_BANCO"	,TRB->BANCO )
						oSubFK5:SetValue( "FK5_AGENCI"	,TRB->AGENCIA )
						oSubFK5:SetValue( "FK5_CONTA"	,TRB->CONTA )
						oSubFK5:SetValue( "FK5_DTDISP"	,TRB->DATAD )
						oSubFK5:SetValue( "FK5_HISTOR"	,STR0009 + " " + cLoteFin ) // "Baixa por Retorno CNAB / Lote :"
						oSubFK5:SetValue( "FK5_MOEDA"	,TRB->MOEDA	)
						oSubFK5:SetValue( "FK5_NATURE"	,TRB->NATURE	)
						oSubFK5:SetValue( "FK5_TPDOC"	,"VL"	)
						oSubFK5:SetValue( "FK5_FILORI"	,cFilAnt )
						oSubFK5:SetValue( "FK5_LOTE"	,cLoteFin ) 
						If SpbInUse()
							oSubFK5:SetValue( "FK5_MODSPB", "1" )
						Endif

						If oModelMov:VldData()
							oModelMov:CommitData()
							SE5->(dbGoto(oModelMov:GetValue( "MASTER", "E5_RECNO" )))
						Else
							lRet := .F.
							cLog := cValToChar(oModelMov:GetErrorMessage()[4]) + ' - '
							cLog += cValToChar(oModelMov:GetErrorMessage()[5]) + ' - '
							cLog += cValToChar(oModelMov:GetErrorMessage()[6])
							Help( ,,"M030_FA430MOV",,cLog, 1, 0 )
						Endif
						oModelMov:DeActivate()
						oModelMov:Destroy()
						oModelMov := Nil
						oSubFK5 := Nil
						oSubFKA := Nil

						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³ Atualiza saldo bancario.      ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						AtuSalBco(TRB->BANCO,TRB->AGENCIA,TRB->CONTA,SE5->E5_DATA,SE5->E5_VALOR,"-")
						dbSelectArea("TRB")
						dbSkip()
					Enddo
				Endif
			EndIf

		End Transaction

		If(_oFina430 <> NIL)

			_oFina430:Delete()
			_oFina430 := NIL

		EndIf

		VALOR := 0
		dbSelectArea( cAlias )
		dbGoTo( nSavRecno )

		IF lF430COMP
			ExecBlock("F430COMP",.f.,.f.)
		EndIF

	EndIf

	cFilAnt := cFilOrig		// Sempre restaura a filial original

Return .F.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³fA430Par  ³ Autor ³ Wagner Xavier         ³ Data ³ 26/05/92 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Aciona parametros do Programa                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³fA430Par()                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function fA430Par()

	Pergunte( "AFI430" )

	MV_PAR03 := UPPER(MV_PAR03)

Return .T.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ChangDate ³ Autor ³ Wagner Xavier         ³ Data ³ 23/06/98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Converte um string data para o formato ddmmaa de acordo com ³±±
±±³          ³um determionado tipo passado para a fun‡„o.                 ³±±
±±³          ³Tipo 1 - ddmmaa                                             ³±±
±±³          ³Tipo 2 - mmddaa                                             ³±±
±±³          ³Tipo 3 . aammdd                                             ³±±
±±³          ³Tipo 4 - ddmmaaaa                                           ³±±
±±³          ³Tipo 5 - aaaammdd                                           ³±±
±±³          ³Tipo 6 - mmddaaaa                                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function ChangDate(__cData,nPosicao)
	LOCAL nPosDia:=0,nPosMes:=0,nPosAno:=0
	LOCAL aSubs  := {}

	// posicao do dia,mes,ano,tamanho do ano;
	AADD( aSubs,{ 01,03,05,2 } )
	AADD( aSubs,{ 03,01,05,2 } )
	AADD( aSubs,{ 05,03,01,2 } )
	AADD( aSubs,{ 01,03,05,4 } )
	AADD( aSubs,{ 07,05,01,4 } )
	AADD( aSubs,{ 03,01,05,4 } )

	If nPosicao == 0;nPosicao++;Endif

	nPosDia := aSubs[nPosicao][1]
	nPosMes := aSubs[nPosicao][2]
	nPosAno := aSubs[nPosicao][3]

	__cData := Substr(__cData,nPosDia,2)+Substr(__cData,nPosMes,2)+Substr(__cData,nPosAno,aSubs[nPosicao][4])

	If Len(__cData) == 8
		__cData := Substr(__cData,1,4)+Substr(__cData,7,2)
	Endif

Return(__cData)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³Chk430File³ Autor ³ Mauricio Pequim Jr    ³ Data ³ 24/11/97 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Checa se arquivo de TB j  foi processado anteriormente	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³Chk430File()  											  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³Fina430													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Chk430File()

	Local cFile 	:= "TB"+cNumEmp+".VRF"
	Local lRet		:= .F.
	Local aFiles	:= {}
	Local cString
	Local nTam
	Local nHdlFile
	Local l430Chkfile := ExistBlock("F430CHK")

	If l430ChkFile		// garantir que o arquivo nao seja reenviado
		Return Execblock("F430CHK",.F.,.F.)
	Endif

	If !FILE(cFile)
		nHdlFile := fCreate(cFile)
	ELSE
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Tenta abrir o arquivo em modo exclusivo e Leitura/Gravacao ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		While (nHdlFile := fOpen(cFile,FO_READWRITE+FO_EXCLUSIVE))==-1 .AND. ;
		if(ExecSchedule(),.T., MsgYesNo( STR0011+cNumEmp+STR0012, STR0010 ))
		Enddo
	Endif

	If nHdlFile > 0

		nTam := TamSx1("AFI430","03")[1] // Tamanho do parametro
		xBuffer := SPACE(nTam)

		// Le o arquivo e adiciona na matriz
		While fReadLn(nHdlFile,@xBuffer,nTam)
			Aadd(aFiles, Trim(xBuffer))
		Enddo

		If ASCAN(aFiles,Trim(MV_PAR03)) > 0
			// Retorno Automatico via Job
			// exibe as mensagens apenas para processamento via menu
			if ! lExecJob
				Help(" ",1,"CHK200FILE")       // Arquivo de Trans.Banc. j  processado
			Endif

			if !lExecJob // verifica se vem do schedule
				//Questiona o usuário se ele deseja efetuar um reprocessamento do arquivo
				If !MsgYesNo( STR0021, STR0010 )
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Atualiza o log de processamento com o erro  ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					ProcLogAtu("ERRO","CHK200FILE",Ap5GetHelp("CHK200FILE"))
				Else
					lRet := .T.
				EndIf
			Else
				lRet := .T.
			Endif

		Else
			fSeek(nHdlFile,0,2) // Posiciona no final do arquivo
			cString := Alltrim(mv_par03)+Chr(13)+Chr(10)
			fWrite(nHdlFile,cString)	// Grava nome do arquivo a ser processado
			lRet := .T.
		Endif
		fClose (nHdlFile)
	Else
		If ! lExecJob
			Help(" ", 1, "CHK200ERRO") // Erro na leitura do arquivo de entrada
		Endif

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Atualiza o log de processamento com o erro  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		ProcLogAtu("ERRO","CHK200ERRO",Ap5GetHelp("CHK200ERRO"))
	EndIf

Return lRet



/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ FAVerInd ³ Autor ³ Mauricio Pequim Jr    ³ Data ³ 02/05/07 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Verifica existencia dos indices 19(SE1) e 13(SE2)          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function FAVerInd()

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºRotina    ³Dv_BarCodeºAutor  ³Claudio D. de Souza º Data ³  14/12/01   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Calcula o digito verificador de um codigo de barras padrao  º±±
±±º          ³Febraban.                                                   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ CodBarVl2                                                  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function DV_BarCode( cBarCode )
	Local cDig
	Local nPos
	Local nAux := 0

	For nPos := 1 To 43
		nAux += Val(SubStr(cBarCode,nPos,1)) * If( nPos<= 3, ( 5-nPos),     ;
		If( nPos<=11, (13-nPos),     ;
		If( nPos<=19, (21-nPos),     ;
		If( nPos<=27, (29-nPos),     ;
		If( nPos<=35, (37-nPos),     ;
		(45-nPos) )))))
	Next
	nAux := nAux % 11
	cDig := If( (11-nAux)>9, 1, (11-nAux) )

Return Str(cDig,1)

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³FinA430T   ³ Autor ³ Marcelo Celi Marques ³ Data ³ 15.05.08 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Chamada semi-automatica utilizado pelo gestor financeiro   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ FINA430                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function FinA430T(aParam)
	cRotinaExec := "FINA380"
	ReCreateBrow("SE2",FinWindow)
	FinA430()
	ReCreateBrow("SE2",FinWindow)
	dbSelectArea("SE2")

	INCLUI := .F.
	ALTERA := .F.

Return .T.



/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ExecSchedule³ Autor ³ Aldo Barbosa dos Santos      ³21/12/10³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Retorna se o programa esta sendo executado via schedule     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function ExecSchedule()
	Local lRetorno := .T.

	lRetorno := IsBlind()

Return( lRetorno )

/*/
{Protheus.doc} A460FSA2
Aplicar Filtro na Tabela de Fornecedores (Campo reservado A2_MSBLQL)

@author norbertom
@since 02/02/2016
@version 1.0
@param nil
@return nil
/*/
Static Function A460FSA2()
	Local cFilter  := SA2->(dbFilter())
	Local cFilBlq  := " !SA2->A2_MSBLQL == '1' "
	Local aGetArea := GETAREA()

	dbSelectArea("SA2")
	If SA2->(FieldPos("A2_MSBLQL")) > 0
		If !'A2_MSBLQL' $ cFilter
			If !Empty(cFilter)
				cFilter += " .AND. "
			EndIf
			cFilter += cFilBlq
			SA2->(dbSetFilter({||&cFilter},cFilter))
		EndIf
	EndIf

	RESTAREA(aGetArea)
Return nil

