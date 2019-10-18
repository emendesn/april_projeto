#INCLUDE 'TOTVS.CH'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'FWBROWSE.CH'
#Include 'TopConn.ch'
#INCLUDE 'TBICONN.CH'

// Constante para os valores logicos
#DEFINE pTRUE               .T.
#DEFINE pFALSE              .F.

// Constante para End Of Line
#DEFINE pEOL                CHR(13)+CHR(10)

#DEFINE pEMISSOR            1
#DEFINE pCPF                2
#DEFINE pVENCIMENTO         3
#DEFINE pFATURA             4
#DEFINE pVALOR              5
#DEFINE pSAQUE              6
#DEFINE pID_SAQUE           7
#DEFINE pAREA               8
#DEFINE pCARTAO_OVER        9
#DEFINE pCC                10
#DEFINE pITEM              11
#DEFINE pPRODUTO           12
#DEFINE pFEE               13


// C7_XOVR_ID C  4    // ID Tavola
// C7_XOVRPRE C  3    // Prefixo
// C7_XOVREMI C 40    // Nome do Emissor
// C7_XOVRCPF C 14    // CPF Emissor
// C7_XOVRFAT C  6    // Fatura Over
// C7_XOVRSAQ C  4    // ID Saque
// C7_XOVRARE C  7    // Area Emissor
// C7_XOVRFEE N  3,2  // Percentual do Fee
// C7_XOVRVEN D  8    // Vencimento



/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³OVER      ºAutor  ³Edilson Mendes      º Data ³  14/09/19   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Rotina pra o processamento das informacoes relacionadas ao º±±
±±º          ³ over disponibilizadas pelo Tavola.                         º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ P12                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
User Function OVER

	Private oProcess
	Private cRetArq

	if .not. empty( cRetArq := SELEARQ() )

	oProcess := MsNewProcess():New( { || Importa() } , "Importação de registros " , "Aguarde..." , pFALSE )
	oProcess:Activate()

	Endif

Return


/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³SEL_ARQ   ºAutor  ³Edilson Mendes      º Data ³  14/09/19   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Abre tela no servidor para o usuario localizar o arquivo   º±±
±±º          ³ que será utilizado.                                        º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ P12                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
STATIC FUNCTION SeleArq()
   Return( cGetFile( "Arquivo CSV (*.CSV)|*.CSV|", "Selecione o Arquivo",,, pTRUE, GETF_NETWORKDRIVE + GETF_LOCALHARD) )


/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³IMPORTA   ºAutor  ³Edilson Mendes    º Data ³    14/09/19   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Rotina para a importacao do arquivo CSV                    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ P12                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function Importa()

Local cIDTavola

Local aCampos
Local aDados   := {}
Local cLinha   := ""
Local lPrim    := pTRUE
Local nCont    := 1
Local nPos

Local oLogFile
Local oCard
Local oNoCard

Local cEmailLog := GetMv("MV_XOVRMAI",,"edilson.mendes.nascimento@gmail.com") // Parametro com os email para recebimento do Workflow
Local cEmailCC  := GetMv("MV_XOVRCC" ,,"")                       // Parametro com os email para recebimento da copia do Workflow
Local cForCnpj  := GetMv("MV_XOVRCNP",, "05401489000399")        // CNPJ dor fornecedor do Pedido
Local cProd1    := GetMv("MV_XOVRPRO",, "GG0000000000064")       // Produto no pedido
Local cProd2    := GetMv("MV_XOVRFEE",, "GG0000000000090")       // Codigo Produto do Fee
Local cTes      := GetMv("MV_XOVRTES",, "004")                   // Codigo do TES gerado no pedido
Local nFee      := GetMv("MV_XOVRPER",, 1.5)                     // Percentual para o calculo do Fee                      
Local cWriteLog := GetMv("MV_XOVRLOG",, "\logs\over\")           // Diretorio de gracao do log de processamento
Local cReadFile := GetMv("MV_XOVRREA",, "\integra\over\")        // Diretorio contendo os arquivos a serem processados
Local cBackFile := GetMv("MV_XOVRBCK",, "\integra\over\sucess\") // Diretorio com os arquivos processados com sucesso
Local cErrFile  := GetMv("MV_XOVRERR",, "\integra\over\error\")  // Diretorio com os arquivos com erro de processamento


	FT_FUSE(cRetArq) //Abre o arquivo texto
	oProcess:SetRegua1(FT_FLASTREC()) //Preenche a regua com a quantidade de registros encontrados
	FT_FGOTOP() //coloca o arquivo no topo
	
	While !FT_FEOF()
		nCont++
		oProcess:IncRegua1('Validando Linha: ' + Alltrim(Str(nCont)))
		
		cLinha := FT_FREADLN()
		cLinha := ALLTRIM(cLinha)
		
		If lPrim //considerando que a primeira linha são os campos do cadastros, reservar numa variavel
			cIDTavola := SUBSTR( cLinha, at( ":", cLinha ) + 1, len( cLinha ) )
			cIDTavola := Alltrim(StrTran( cIDTavola, ";","" ))
			lPrim := pFALSE
		ElseIf nCont == 5   // Adiciona o Cabecario
			aCampos := Separa(cLinha,";",pTRUE)
		ElseIf nCont >= 6 .and. cLinha <> ';;;;;;;;;'  // Adiciona os dados
			AADD(aDados,Separa(cLinha,";",pTRUE))
		EndIf
		
		FT_FSKIP()
	EndDo
	
	FT_FUSE()
	
	IF len( aDados ) > 0
		
		// arquivo de LOG
		oLogFile         := Log():New()
		oLogFile:cDirLog := cWriteLog
		
		// Objeto Cartao
		oCard   := Cartao():New()
		oCard:cPrefixo  := "OVR"
		oCard:cIdTavola := cIDTavola
		oCard:cProduto  := cProd1
		oCard:cTes      := cTes
		oCard:cProdFee  := cProd2
		oCard:nPercFee  := nFee
		
		oNoCard := Cartao():New()
		oNoCard:cPrefixo  := "OVR"
		oNoCard:cIdTavola := cIDTavola
		oNoCard:cProduto  := cProd1
		oNoCard:cTes      := cTes
		oNoCard:cProdFee  := cProd2
		oNoCard:nPercFee  := nFee
		
		
		// Separa os cartoes
		FOR nPos := 1 TO LEN( aDados )
			IF aDados[ nPos ][ pCARTAO_OVER ] == "S"
				oCard:Add( aDados[ nPos ] )
			ELSE
				oNoCard:Add( aDados[ nPos ] )
			ENDIF
		NEXT
		
		oProcess:SetRegua2(len(aDados))
		
		If Alltrim(SM0->M0_CODFIL) == '0101'
			
			// Com cartaao
			if oCard:lStable
				
				oCard:cPedido := GetNumSC7()
				
				if GeraPed( cForCnpj, oCard, oLogFile, cEmailLog, cEmailCC )
					CONFIRMSX8()
					
					// Atualiza os campos customizados do pedido
					if SC7->( DBSetOrder(1), DBseek( xFilial("SC7")+oCard:cPedido ) )
						
						while SC7->C7_FILIAL == xFilial("SC7") .AND. SC7->C7_NUM == oCard:cPedido .AND. SC7->( .NOT. EOF() )
							
							if .not. empty( oCard:SeekItem( SC7->C7_ITEM ) )
								Begin Transaction
									RecLock("SC7", pFALSE )
									SC7->C7_XOVRPRE := oCard:cPrefixo
									SC7->C7_XOVR_ID := oCard:cIdTavola
									SC7->C7_XOVRPRE := oCard:cPrefixo
									SC7->C7_XOVR_ID := oCard:cIdTavola
									SC7->C7_XOVREMI := oCard:cEmissor
									SC7->C7_XOVRCPF := oCard:cCPF
									SC7->C7_XOVRFAT := oCard:cFatura
									SC7->C7_XOVRSAQ := oCard:cIdSaque
									SC7->C7_XOVRARE := oCard:cArea
									// SC7->C7_XOVRVEN := oCard:dVencimento
									SC7->( MsUnlock() )
								End Transaction
							endif
							
							SC7->( DBSkip() )
							
						enddo
						
					endif
					
				endif
				
			endif
			
			// Sem cartaao
			if oNoCard:lStable
				
				oNoCard:cPedido   := GetNumSC7()
				
				if GeraPed( cForCnpj, oNoCard, oLogFile, cEmailLog, cEmailCC )
					CONFIRMSX8()
					
					// Atualiza os campos customizados do pedido
					if SC7->( DBSetOrder(1), DBseek( xFilial("SC7")+oNoCard:cPedido ) )
						
						while SC7->C7_FILIAL == xFilial("SC7") .AND. SC7->C7_NUM == oNoCard:cPedido .AND. SC7->( .NOT. EOF() )
							
							if .not. empty( oNoCard:SeekItem( SC7->C7_ITEM ) )
								Begin Transaction
									RecLock("SC7", pFALSE )
									SC7->C7_XOVRPRE := oNoCard:cPrefixo
									SC7->C7_XOVR_ID := oNoCard:cIdTavola
									SC7->C7_XOVRPRE := oNoCard:cPrefixo
									SC7->C7_XOVR_ID := oNoCard:cIdTavola
									SC7->C7_XOVREMI := oNoCard:cEmissor
									SC7->C7_XOVRCPF := oNoCard:cCPF
									SC7->C7_XOVRFAT := oNoCard:cFatura
									SC7->C7_XOVRSAQ := oNoCard:cIdSaque
									SC7->C7_XOVRARE := oNoCard:cArea
									// SC7->C7_XOVRVEN := oNoCard:dVencimento
									SC7->( MsUnlock() )
								End Transaction
							endif
							
							SC7->( DBSkip() )
							
						enddo
						
					endif
					
				endif
				
			endif
			
		endif
		
	Endif
							
Return


/*±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³GeraPedºAutor  ³Edilson Mendes          º Data ³  14/09/19  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Rotina para a geracao do pedido de compra.                 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ cCnpj     - CNPJ do fornecedor do pedido gerado.           º±±
±±º          ³ oCartao   - Objeto utilizado para a montagem do Workflow.  º±±
±±º          ³ oLog      - Objeto responsavel pelo arquivo de log.        º±±
±±º          ³ cEmailLog - Email do destinatario que recebera workflow.   º±±
±±º          ³ cEmailCC  - Email de quem recebera a copia do workflow.    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ P12                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
STATIC FUNCTION GeraPed( cCnpj, oCartao, oLog, cEmailLog, cEmailCC )

Local lRetValue := pTRUE
local aCabec    := {}
local aLinha    := {}
Local aItens    := {}


	if SA2->(dbSetOrder(3),dbSeek(xFilial("SA2")+cCnpj))
		
		aadd(aCabec,{"C7_NUM",     oCartao:cPedido,   Nil})
		aadd(aCabec,{"C7_EMISSAO", dDataBase,         Nil})
		aadd(aCabec,{"C7_FORNECE", SA2->A2_COD,       Nil})
		aadd(aCabec,{"C7_LOJA",    SA2->A2_LOJA,      Nil})
		aadd(aCabec,{"C7_COND",    "001",             Nil})
		aadd(aCabec,{"C7_CONTATO", oCartao:cPrefixo,  Nil})
		aadd(aCabec,{"C7_FILENT",  xFilial("SC7"),    Nil})
		//					aadd(aCabec,{"C7_MOEDA",   "1",            Nil})
		//			aadd(aCabec,{"C7_TXMOEDA", If(!Empty(cMoeda) .AND. !Empty(cMoeda),SZ7->Z7_EXRATE,0), Nil})
		
		oCartao:Top()
		while .not. oCartao:eof()
			
			oProcess:IncRegua2("Gerando o Pedido:" + oCartao:cPedido )
			
			aLinha := {}
			aadd(aLinha,{"C7_ITEM",    oCartao:cItem,     Nil})
			aadd(aLinha,{"C7_PRODUTO", oCartao:cProdItem, Nil})
			aadd(aLinha,{"C7_QUANT",   1,                 Nil})
			aadd(aLinha,{"C7_PRECO",   oCartao:nValor,    Nil})
			aadd(aLinha,{"C7_TOTAL",   oCartao:nValor,    Nil})
			aadd(aLinha,{"C7_TES",     oCartao:cTes,      Nil})
//			aadd(aLinha,{"C7_CC",      oCartao:cCC,       Nil})
			aadd(aItens,aLinha)
			
			oLog:AddLog( padL( cCnpj, 14) + "|" + padL( oCartao:cPedido, 6) + "|" + ;
			             padL( oCartao:cProdItem, 15 ) + "|" + padR( oCartao:cEmissor, 40 ) + "|" + padL( oCartao:cCPF, 14 ) + "|" + ;
			             padL( oCartao:cFatura, 6 ) + "|" + padL( oCartao:cIdSaque, 4 ) + "|" + padR( oCartao:cArea, 7 ) + "|" + padR( oCartao:cCC, 5 ) )
			
			// Salta o registro no Objeto
			oCartao:Skip()
			
		enddo
		
		// Adiciona a linha com o percentual
		
		//****************************************************************
		//* Teste de Inclusao
		//****************************************************************
		
		lMsErroAuto := pFALSE
		If .not. Empty( aCabec ) .and. .not. Empty( aItens )
			
			BEGIN TRANSACTION
				MSExecAuto({|x,y,z,w| MATA120(x,y,z,w)},1,aCabec,aItens,3)
			END TRANSACTION
			
			If lMSErroAuto
				
				lRetValue := pFALSE

				WF_ERRO( oCartao:cPedido, cEmailLog, cEmailCC, "Erro na geracao do pedido " + oCartao:cPedido )
				
			Else
				// Grava o arquivo de LOG
				oLog:Flush()
				
				WF_SUCESS( cCnpj, oCartao, cEmailLog, cEmailCC )
				
			Endif
			
		endif
		
	else
		WF_ERRO( oCartao:cPedido, cEmailLog, cEmailCC, "CNPJ : " + padL( cCnpj, 14) + " - Nao encontrado" )
	endif
	
return( lRetValue )


/*±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³WF_ERROºAutor  ³Edilson Mendes          º Data ³  14/09/19  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Rotiina para o envio de workflow caso ocorra erro no      º±±
±±º          ³ momento da integracao.                                     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ cPedido   - Codigo do pedido para anexar e o worflow       º±±
±±º          ³             enviado.                                       º±±
±±º          ³ cEmailLog - Email do destinatario que recebera workflow.   º±±
±±º          ³ cEmailCC  - Email de quem recebera a copia do workflow.    º±±
±±º          ³ cMsg      - Mensagem a ser anexada no Workflow.            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ P12                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
STATIC PROCEDURE WF_ERRO( cPedido, cEmailLog, cEmailCC, cMsg )

Local oWf
Local oHtml
Local cPath := GetSrvProfString("Startpath","")

	if .not. empty(cEmailLog)
	
		oWf   := TWFProcess():New("WF_OVER","Pedido de Over")
		oWf:NewTask('Inicio',"\workflow\html\wfover001.htm")
		if file( cPath + "logint.log" )
			MostraErro(cPath + "logint.log")
			// Adiciona o arquivo de erro para envio
			oWf:AttachFile( cPath + "logint.log" )
		endif
		
		oHtml := oWf:oHtml
		oHtml:ValByName("fornecedor", "" )
		oHtml:ValByName("cCNPJfornecedor", "" )
		oHtml:ValByName("cID_Tavola", "" )
		
		//titulos
		oHtml:ValByName("it1.item",       {})
		oHtml:ValByName("it1.produto",    {})
		oHtml:ValByName("it1.quantidade", {})
		oHtml:ValByName("it1.preco",      {})
		oHtml:ValByName("it1.total",      {})
		oHtml:ValByName("it1.tes",        {})
		oHtml:ValByName("it1.emissor",    {})
		oHtml:ValByName("it1.cpf",        {})
		oHtml:ValByName("it1.vencimento", {})
		oHtml:ValByName("it1.fatura",     {})
		oHtml:ValByName("it1.valor",      {})
		oHtml:ValByName("it1.saque",      {})
		oHtml:ValByName("it1.id_saque",   {})
		oHtml:ValByName("it1.area",       {})
		oHtml:ValByName("it1.cc",         {})
		oHtml:ValByName("observacao",     {})
		
		aadd(oHtml:ValByName("it1.item"),       ""  )
		aadd(oHtml:ValByName("it1.produto"),    ""  )
		aadd(oHtml:ValByName("it1.quantidade"), ""  )
		aadd(oHtml:ValByName("it1.preco"),      ""  )
		aadd(oHtml:ValByName("it1.total"),      ""  )
		aadd(oHtml:ValByName("it1.tes"),        ""  )
		aadd(oHtml:ValByName("it1.emissor"),    ""  )
		aadd(oHtml:ValByName("it1.cpf"),        ""  )
		aadd(oHtml:ValByName("it1.vencimento"), ""  )
		aadd(oHtml:ValByName("it1.fatura"),     ""  )
		aadd(oHtml:ValByName("it1.saque"),      ""  )
		aadd(oHtml:ValByName("it1.id_saque"),   ""  )
		aadd(oHtml:ValByName("it1.area"),       ""  )
		aadd(oHtml:ValByName("it1.cc"),         ""  )
		
		aadd(oHtml:ValByName("observacao"),     ""  )
		
		oHtml:ValByName("quantidade",           "0" )
		oHtml:ValByName("totalgeral",           "0" )
		
		//envia o e-mail
		oWf:ClientName( Subs(cUsuario,7,15) )
		oWf:cTo      := cEmailLog
		oWf:cCC      := iif( valtype(cEmailCC) == "U", "", cEmailCC )
		oWf:cSubject := iif( .not. empty(cMsg), FwNoAccent(cMsg), "Erro na geracao do Pedido" ) 
		oWf:Start()
		oWf:Finish()
		
	endif
	
RETURN

/*±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³WF_SUCESSºAutor  ³Edilson Mendes        º Data ³  14/09/19  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Rotiina para o envio de workflow com os dados integrados   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ cCnpj     - CNPJ do fornecedor do pedido gerado            º±±
±±º          ³ oObj      - Objeto utilizado para a montagem do Workflow.  º±±
±±º          ³ cEmailLog - Email do destinatario que recebera workflow.   º±±
±±º          ³ cEmailCC  - Email de quem recebera a copia do workflow.    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ P12                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
STATIC PROCEDURE WF_SUCESS( cCnpj, oObj, cEmailLog, cEmailCC )

Local oWf
Local oHtml

	if valtype( oObj ) == "O"
		
		if .not. empty(cCnpj) .and. .not. empty(cEmailLog)
			
			if SA2->(dbSetOrder(3),dbSeek(xFilial("SA2")+cCnpj))
				
				// Envia WF do pedido gerado
				oWf   := TWFProcess():New("WF_OVER","Pedido de Over")
				oWf:NewTask('Inicio',"\workflow\html\wfover001.htm")
				
				oHtml := oWf:oHtml
				oHtml:ValByName("fornecedor", SA2->A2_COD + "-" + SA2->A2_LOJA + "-" + SA2->A2_NOME )
				oHtml:ValByName("cCNPJfornecedor", SA2->A2_CGC )
				oHtml:ValByName("cID_Tavola", oObj:cIdTavola )
				
				//titulos
				oHtml:ValByName("it1.item",       {})
				oHtml:ValByName("it1.produto",    {})
				oHtml:ValByName("it1.quantidade", {})
				oHtml:ValByName("it1.preco",      {})
				oHtml:ValByName("it1.total",      {})
				oHtml:ValByName("it1.tes",        {})
				oHtml:ValByName("it1.emissor",    {})
				oHtml:ValByName("it1.cpf",        {})
				oHtml:ValByName("it1.vencimento", {})
				oHtml:ValByName("it1.fatura",     {})
				oHtml:ValByName("it1.valor",      {})
				oHtml:ValByName("it1.saque",      {})
				oHtml:ValByName("it1.id_saque",   {})
				oHtml:ValByName("it1.area",       {})
				oHtml:ValByName("it1.cc",         {})
				
				oObj:Top()
				while .not. oObj:eof()
					
					aadd(oHtml:ValByName("it1.item"),       oObj:cItem )
					aadd(oHtml:ValByName("it1.produto"),    oObj:cProdItem )
					aadd(oHtml:ValByName("it1.quantidade"), "1" )
					aadd(oHtml:ValByName("it1.preco"),      transform( oObj:nValor, "@E 9,999.99" ) )
					aadd(oHtml:ValByName("it1.total"),      transform( oObj:nValor, "@E 9,999.99" ) )
					aadd(oHtml:ValByName("it1.tes"),        oObj:cTes )
					aadd(oHtml:ValByName("it1.emissor"),    oObj:cEmissor )
					aadd(oHtml:ValByName("it1.cpf"),        oObj:cCPF )
					aadd(oHtml:ValByName("it1.vencimento"), dtoc( oObj:dVencimento ) )
					aadd(oHtml:ValByName("it1.fatura"),     oObj:cFatura )
					aadd(oHtml:ValByName("it1.saque"),      dtoc( oObj:dSaque ) )
					aadd(oHtml:ValByName("it1.id_saque"),   oObj:cIdSaque )
					aadd(oHtml:ValByName("it1.area"),       oObj:cArea )
					aadd(oHtml:ValByName("it1.cc"),         oObj:cCC )
					
					oObj:Skip()
					
				enddo
				
				oHtml:ValByName("quantidade", transform( oObj:QuantItens(), "@E 9,999" ) )
				oHtml:ValByName("totalgeral", transform( oObj:TotalGeral(), "@E 999,999.99" ) )
				
				//envia o e-mail
				oWf:ClientName( Subs(cUsuario,7,15) )
				oWf:cTo      := cEmailLog
				oWf:cCC      := iif( valtype(cEmailCC) == "U", "", cEmailCC )
				oWf:cSubject := "Pedido de Over: " + oObj:cPedido
				oWf:Start()
				oWf:Finish()
				
			endif
			
		endif
		
	endif
		
RETURN




/*±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³LOG   ºAutor  ³Edilson Mendes          º Data ³  14/09/19   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Classe para a geracao do LOG dos registros processados     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºPropried. ³ cFileLog - Nome do aruivo que sera criado.                 º±±
±±º          ³ cDirLog  - Diretorio de destino do arquivo gerado.         º±±
±±º          ³ aDataLog - Informacoes do LOG.                             º±±
±±º          ³ lExitDir - Logico indicado a existencoa do diretorio.      º±±
±±º          ³ nHandle  - Ponteiro do arquivo criado.                     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºMetodos   ³ ::New            - Cria o objeto.                          º±±
±±º          ³ ::AddLog         - Adiciona a informacao do log.           º±±
±±º          ³ ::ExistDirectory - Verifica a existencia do diretorio e    º±± 
±±º          ³                    cria caso nao exista.                   º±±
±±º          ³ ::Flush          - Grava as informacoes no arquivo.        º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ P12                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
CLASS Log 

	// Declaracao das propriedades da Classe
	DATA cFileLog
	DATA cDirLog
	DATA aDataLog
	DATA lExitDir
	DATA nHandle
	
	// Declaração dos Métodos da Classe
	METHOD New() CONSTRUCTOR
	METHOD AddLog( cString )
	METHOD ExistDirectory()
	METHOD Flush()
	
ENDCLASS

METHOD New() Class Log
	::cFileLog  := "log-over-" + dtos( date() ) + ".log"	
	::cDirLog   := "\logs\over\"
	::aDataLog	:= {}
	::lExitDir  := pFALSE
    ::nHandle   := 0
Return Self    
    
METHOD AddLog( cString ) Class Log

	LOCAL cLog
	
	if .not. empty( cString )
		cLog := "[" + Time() + "]-["+ alltrim( upper( cString ) ) + "]"
		aadd( ::aDataLog, cLog )
	endif
			
Return

METHOD Flush() Class Log

	local nPos
	
	//Realiza a gravacao das informacoes no arquivo de log
	if .not. empty( ::aDataLog )
		if ::ExistDirectory()
			If .not. file( ::cDirLog + ::cFileLog )
				::nHandle := FCreate( ::cDirLog + ::cFileLog )
			Else
				if ( ::nHandle := fopen( ::cDirLog + ::cFileLog, 2+64) ) > 0
					fseek( ::nHandle, 0, 2 )
				endif
			Endif
			
			if ::nHandle > 0
				for nPos := 1 to len( ::aDataLog )
					FWrite( ::nHandle, ::aDataLog[ nPos ] + pEOL )
				next
				::aDataLog := {}
				FClose( ::nHandle )
			endif
		endif
	endif
				
Return Self

METHOD ExistDirectory() Class Log

	LOCAL cString := ""
	LOCAL nPos
	LOCAL nPointer
	
	if .not. empty( ::cDirLog )
		
		if ( len( Directory( ::cDirLog + "*.", "D" ) ) ) > 0
			::lExitDir := pTRUE
		else
			
			for nPos := 1 to len( alltrim( ::cDirLog ) )
				cString += substr( alltrim( ::cDirLog ), nPos, 1 )				
				if substr( alltrim( cString ), nPos, 1 ) == "\" .AND. nPos <= LEN( alltrim( cString ) )					
					IF ( nPointer := ASCAN( Directory( cString + "*.", "D" ), {|xDir| xDir[5] == "D"})) == 0
						IF ( ::lExitDir := ( MakeDir( cString,, pTRUE ) == 0 ) )
							EXIT
						ENDIF
					ENDIF
				endif
			next
			
		endif
	endif
					
Return ::lExitDir


/*±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³CARTAOºAutor  ³Edilson Mendes          º Data ³  14/09/19   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Classe para o tratamento dos dados do cartao de credito    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºPropried. ³ cPedido     - Numero do pedido que sera gerado.            º±±
±±º          ³ cPrefixo    - Codigo do prefixo que sera gravado no pedido º±±
±±º          ³               Gerado.                                      º±±
±±º          ³ cIdTavola   - Codigo de identificaçao do relatorio do      º±±
±±º          ³               Tavola.                                      º±±
±±º          ³ cProduto    - Codigo do produto do over.                   º±±
±±º          ³ cTes        - Codigo da TES informada no pedido.           º±±
±±º          ³ cProdFee    - Codigo do produto do over.                   º±±
±±º          ³ nPercFee    - Percentual para o calculo do Fee.            º±±
±±º          ³ cEmissor    - Nome do emissor do Over.                     º±±
±±º          ³ cCPF        - CPF do emissor do Over.                      º±±
±±º          ³ dVencimento - Data do vencimento do Over.                  º±±
±±º          ³ cFatura     - Codigo da Fatura.                            º±±
±±º          ³ nValor      - Valor do Over.                               º±±
±±º          ³ dSaque      - Data do Saque.                               º±±
±±º          ³ cIdSaque    - Identificacao do Saque.                      º±±
±±º          ³ cArea       - Centro do custo do Over no Tavola.           º±±
±±º          ³ cCC         - Centro do custo do Over no Protheus.         º±±
±±º          ³ cItem       - Codigo sequencial do pedido.                 º±±
±±º          ³ cProdItem   - Codigo do produto do Item.                   º±±
±±º          ³ nFeeItem    - Percentual do Fee calculado.                 º±±
±±º          ³ aDados      - Array com os dados da elaboraçao do Pedido.  º±±
±±º          ³ nPointer    - Ponteiro interno referenciando o item ao     º±±
±±º          ³               vetor a aDados.                              º±±
±±º          ³ lStable     - Variavel identificando objeto Estavel.       º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºMetodos   ³ ::New()           - Cria o objeto.                         º±±
±±º          ³ ::Add(aArray)     - Adiciona a informacao ao vetor aDados. º±±
±±º          ³ ::Corrente()      - Atualiza as variaveis com o objeto     º±± 
±±º          ³                     corrente.                              º±± 
±±º          ³ ::Skip(nSkip)     - Salta para o item dentro do vetor      º±±
±±º          ³                     aDados.                                º±±
±±º          ³ ::Bof()           - Informa se é o Inicio do vetor aDados. º±±
±±º          ³ ::Eof()           - Informa se é o Final do vetor aDados.  º±±
±±º          ³ ::Top()           - Posiciona no Inicio do vetor.          º±±
±±º          ³ ::CalcFee(nVal)   - Calcula o Fee para o registro corrente.º±±
±±º          ³ ::QuantItens()    - Retorna a quantidade de Itens.         º±±
±±º          ³ ::TotalGeral()    - Retorna o total Itens.                 º±±
±±º          ³ ::SeekItem(cItem) - Procura o item no vetor aDados.        º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ P12                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
CLASS Cartao

	// Declaracao das variaveis para a Classe
	DATA cPedido
	DATA cPrefixo
	DATA cIdTavola
	DATA cProduto
	DATA cTes
	DATA cProdFee
	DATA nPercFee

    // Declaracao das variaveis para o vetor aDados
	DATA cEmissor
	DATA cCPF
	DATA dVencimento
	DATA cFatura
	DATA nValor
	DATA dSaque
	DATA cIdSaque
	DATA cArea
	DATA cCC
	DATA cItem
	DATA cProdItem
	DATA nFeeItem
	
	DATA aDados
	DATA nPointer
	DATA lStable
	
	// Declaração dos Métodos da Classe
	METHOD New() CONSTRUCTOR
	METHOD Add( aArray )
	METHOD Corrente()
	METHOD Skip( nSkip )
	METHOD Bof()
	METHOD Eof()
	METHOD Top()
	METHOD CalcFee( nVal )
	METHOD QuantItens()
	METHOD TotalGeral()
	METHOD SeekItem( cItem )

ENDCLASS

METHOD New() Class Cartao

	::cPedido     := ""
	::cPrefixo    := ""
	::cIdTavola   := ""
	::cProduto    := ""
	::cTes        := ""
	::cProdFee    := ""
	::nPercFee    := 0

	::cEmissor    := ""
	::cCPF        := ""
	::dVencimento := ctod("")
	::cFatura     := ""
	::nValor      := 0
	::dSaque      := ctod("")
	::cIdSaque    := ""
	::cArea       := ""
	::cCC         := ""
	::cItem       := ""
	::cProdItem   := ""
	::nFeeItem    := 0
	
	::aDados      := {}
	::nPointer    := 0
	::lStable     := pFALSE
    
Return Self    

METHOD Add( aArray ) Class Cartao

	local aTemp
	local nPerc := 0
	
	if valtype( aArray ) == "A"
		
		aTemp := aClone( aArray )
		ASize( aTemp, Len( aArray ) + 3 )
		
		if len( ::aDados ) == 0
			::nPointer        := 1
			aTemp[ pITEM ]    := 1
			aTemp[ pPRODUTO ] := ::cProduto
			aTemp[ pFEE ]     := ::nPercFee
			aadd( ::aDados, aTemp )
			::Corrente()
		else
			aTemp[ pITEM ]    := len( ::aDados ) + 1
			aTemp[ pPRODUTO ] := ::cProduto
			aTemp[ pFEE ]     := ::nPercFee
			aadd( ::aDados, aTemp )
		endif
		
			
		// Caso seja informado o Produto e o Percentual de Fee
		// Cria mais um item com o calculo do fee proporcional
		if len( ::aDados ) > 0 .and. .not. empty( ::cProdFee ) .and. ::nPercFee > 0
		    aTemp := aClone( aArray )
		    ASize( aTemp, Len( aArray ) + 3 )
		
		    nPerc             := ::CalcFee( val( aTemp[ pVALOR ] ) )
			aTemp[ pITEM ]    := len( ::aDados ) + 1
			aTemp[ pVALOR ]   := alltrim( str( nPerc ) )
			aTemp[ pPRODUTO ] := ::cProdFee
			aTemp[ pFEE ]     := 0
			aadd( ::aDados, aTemp )		
		endif			
		
	endif
							
Return

METHOD Corrente() Class Cartao

	if ::nPointer > 0 .and. ::nPointer <= len( ::aDados )
		::cEmissor    := FwNoAccent( ::aDados[ ::nPointer ][ pEMISSOR ] )
		::cCPF        := FwNoAccent( ::aDados[ ::nPointer ][ pCPF ] )
		::dVencimento := ctod( ::aDados[ ::nPointer ][ pVENCIMENTO ] )
		::cFatura     := FwNoAccent( ::aDados[ ::nPointer ][ pFATURA ] )
		::nValor      := val( ::aDados[ ::nPointer ][ pVALOR ] )
		::dSaque      := ctod( ::aDados[ ::nPointer ][ pSAQUE ] )
		::cIdSaque    := FwNoAccent( ::aDados[ ::nPointer ][ pID_SAQUE ] )
		::cArea       := FwNoAccent( ::aDados[ ::nPointer ][ pAREA ] )
		::cCC         := FwNoAccent( ::aDados[ ::nPointer ][ pCC ] )
		::cItem       := StrZero( ::aDados[ ::nPointer ][ pITEM ], 4 )
		::cProdItem   := alltrim( ::aDados[ ::nPointer ][ pPRODUTO ] )
		::nFeeItem    := ::aDados[ ::nPointer ][ pFEE ]
		
		::lStable     := pTRUE
		
	endif
							
Return

METHOD Skip( nSkip ) Class Cartao

	if valtype( nSkip ) == "U"
		
		if .not. ::eof()
			::nPointer++
			::Corrente()
		endif
		
	elseif valtype( nSkip ) == "N"
		::nPointer += nSkip
		if ::eof()
			::nPointer := len( ::aDados )
		elseif Bof()
			::nPointer := 1
		endif
		::Corrente()
	endif
								
Return

METHOD Bof() Class Cartao

	local lRetValue := pFALSE
	
	if ::nPointer == 1
		lRetValue := pTRUE
	endif

Return lRetValue

METHOD Eof() Class Cartao

local lRetValue := pFALSE

	if ::nPointer > len( ::aDados )
		::nPointer := len( ::aDados )
		lRetValue := pTRUE
	endif
	
Return lRetValue

METHOD Top() Class Cartao

	::nPointer := 1
	::Corrente()

Return

METHOD CalcFee( nVal ) Class Cartao

	local nRetValue := 0
	
	if nVal > 0 .and. ::nPercFee > 0
		// Calcula o Percentual
		nRetValue := nVal * ::nPercFee
		nRetValue /= 100
	endif
		
Return nRetValue

METHOD QuantItens() Class Cartao

	local nRetValue := 0
	
	if len( ::aDados ) > 0
		nRetValue := len( ::aDados )
	endif
		
Return nRetValue

METHOD TotalGeral() Class Cartao

	local nRetValue := 0
	
	if len( ::aDados ) > 0
		AEVAL( ::aDados, { |xTot| nRetValue += val( xTot[ pVALOR ] ) } )
	endif
		
Return nRetValue

METHOD SeekItem( cItem ) Class Cartao

	local cRetValue := ""
	Local nPos
	
	if .not. empty( cItem )
		if len( ::aDados ) > 0
			if ( nPos := ascan( ::aDados, { |xItem| xItem[ pITEM ] == val( cItem ) } ) ) > 0
				::nPointer := nPos
				::Corrente()
				cRetValue := ::cItem
			endif
		endif
	endif
			
Return cRetValue