#INCLUDE "PROTHEUS.CH"
#DEFINE SIMPLES Char( 39 )
#DEFINE DUPLAS  Char( 34 )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±º Programa ³ UPDFST   º Autor ³ Eduardo Augusto    º Data ³  25/02/2013 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º Descricao³ Funcao de update dos dicionários para compatibilização dos ³±±
±±º          ³ Campos Customizados.                                       º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±³ Uso      ³ UPDFST     - Gerado por EXPORDIC / Upd. V.4.5.2 EFS        ³±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

User Function UPDCAMP()
Local   aSay     := {}
Local   aButton  := {}
Local   aMarcadas:= {}
Local   cTitulo  := "ATUALIZAÇÃO DE DICIONÁRIOS E TABELAS"
Local   cDesc1   := "Esta rotina tem como função fazer  a atualização  dos dicionários do Sistema ( SX?/SIX )"
Local   cDesc2   := "Este processo deve ser executado em modo EXCLUSIVO, ou seja não podem haver outros"
Local   cDesc3   := "usuários  ou  jobs utilizando  o sistema.  É extremamente recomendavél  que  se  faça um"
Local   cDesc4   := "BACKUP  dos DICIONÁRIOS  e da  BASE DE DADOS antes desta atualização, para que caso "
Local   cDesc5   := "ocorra eventuais falhas, esse backup seja ser restaurado."
Local   cDesc6   := ""
Local   cDesc7   := ""
Local   lOk      := .F.
Private oMainWnd  := NIL
Private oProcess  := NIL
#IFDEF TOP
    TCInternal( 5, '*OFF' ) // Desliga Refresh no Lock do Top
#ENDIF
__cInterNet := NIL
__lPYME     := .F.
Set Dele On
// Mensagens de Tela Inicial
aAdd( aSay, cDesc1 )
aAdd( aSay, cDesc2 )
aAdd( aSay, cDesc3 )
aAdd( aSay, cDesc4 )
aAdd( aSay, cDesc5 )
//aAdd( aSay, cDesc6 )
//aAdd( aSay, cDesc7 )
// Botoes Tela Inicial
aAdd(  aButton, {  1, .T., { || lOk := .T., FechaBatch() } } )
aAdd(  aButton, {  2, .T., { || lOk := .F., FechaBatch() } } )
FormBatch(  cTitulo,  aSay,  aButton )
If lOk
	aMarcadas := EscEmpresa()
	If !Empty( aMarcadas )
		If  MsgNoYes( "Confirma a atualização dos dicionários ?", cTitulo )
			oProcess := MsNewProcess():New( { | lEnd | lOk := FSTProc( @lEnd, aMarcadas ) }, "Atualizando", "Aguarde, atualizando ...", .F. )
			oProcess:Activate()
			If lOk
				Final( "Atualização Concluída." )
			Else
				Final( "Atualização não Realizada." )
			EndIf
		Else
			MsgStop( "Atualização não Realizada.", "UPDFST" )
		EndIf
	Else
		MsgStop( "Atualização não Realizada.", "UPDFST" )
	EndIf
EndIf
Return NIL

Static Function FSTProc( lEnd, aMarcadas )	// Funcao de processamento da Gravação dos Arquivos
Local   aInfo     := {}
Local   aRecnoSM0 := {}
Local   cAux      := ""
Local   cFile     := ""
Local   cFileLog  := ""
Local   cMask     := "Arquivos Texto (*.TXT)|*.txt|"
Local   cTCBuild  := "TCGetBuild"
Local   cTexto    := ""
Local   cTopBuild := ""
Local   lOpen     := .F.
Local   lRet      := .T.
Local   nI        := 0
Local   nPos      := 0
Local   nRecno    := 0
Local   nX        := 0
Local   oDlg      := NIL
Local   oFont     := NIL
Local   oMemo     := NIL
Private aArqUpd   := {}
If ( lOpen := MyOpenSm0(.T.) )
	DbSelectArea( "SM0" )
	DbGoTop()
	While !SM0->( EOF() )
		// So adiciona no aRecnoSM0 se a empresa for diferente
		If aScan( aRecnoSM0, { |x| x[2] == SM0->M0_CODIGO } ) == 0 .AND. aScan( aMarcadas, { |x| x[1] == SM0->M0_CODIGO } ) > 0
			aAdd( aRecnoSM0, { Recno(), SM0->M0_CODIGO } )
		EndIf
		SM0->( dbSkip() )
	End
	SM0->( dbCloseArea() )
	If lOpen
		For nI := 1 To Len( aRecnoSM0 )
			If !( lOpen := MyOpenSm0(.F.) )
				MsgStop( "Atualização da Empresa " + aRecnoSM0[nI][2] + " não efetuada." )
				Exit
			EndIf
			SM0->( dbGoTo( aRecnoSM0[nI][1] ) )
			RpcSetType( 3 )
			RpcSetEnv( SM0->M0_CODIGO, SM0->M0_CODFIL )
			lMsFinalAuto := .F.
			lMsHelpAuto  := .F.
			cTexto += Replicate( "-", 128 ) + CRLF
			cTexto += "Empresa : " + SM0->M0_CODIGO + "/" + SM0->M0_NOME + CRLF + CRLF
			oProcess:SetRegua1( 8 )
			oProcess:IncRegua1( "Dicionário de arquivos - " + SM0->M0_CODIGO + " " + SM0->M0_NOME + " ..." )	// Atualiza o dicionário SX2 
			FSAtuSX2( @cTexto )
			FSAtuSX3( @cTexto )	// Atualiza o dicionário SX3
			oProcess:IncRegua1( "Dicionário de índices - " + SM0->M0_CODIGO + " " + SM0->M0_NOME + " ..." )	// Atualiza o dicionário SIX
			FSAtuSIX( @cTexto )
			oProcess:IncRegua1( "Dicionário de dados - " + SM0->M0_CODIGO + " " + SM0->M0_NOME + " ..." )
			oProcess:IncRegua2( "Atualizando campos/índices")
			// Alteracao fisica dos arquivos
			__SetX31Mode( .F. )
			If FindFunction(cTCBuild)
				cTopBuild := &cTCBuild.()
			EndIf
			For nX := 1 To Len( aArqUpd )
				If cTopBuild >= "20090811" .AND. TcInternal( 89 ) == "CLOB_SUPPORTED"
					If ( ( aArqUpd[nX] >= 'NQ ' .AND. aArqUpd[nX] <= "NZZ" ) .OR. ( aArqUpd[nX] >= "O0 " .AND. aArqUpd[nX] <= "NZZ" ) ) .AND. !aArqUpd[nX] $ "NQD,NQF,NQP,NQT"
						TcInternal( 25, "CLOB" )
					EndIf
				EndIf
				If Select( aArqUpd[nX] ) > 0
					dbSelectArea( aArqUpd[nX] )
					dbCloseArea()
				EndIf
				X31UpdTable( aArqUpd[nX] )
				If __GetX31Error()
					Alert( __GetX31Trace() )
					MsgStop( "Ocorreu um erro desconhecido durante a atualização da tabela : " + aArqUpd[nX] + ". Verifique a integridade do dicionário e da tabela.", "ATENÇÃO" )
					cTexto += "Ocorreu um erro desconhecido durante a atualização da estrutura da tabela : " + aArqUpd[nX] + CRLF
				EndIf
				If cTopBuild >= "20090811" .AND. TcInternal( 89 ) == "CLOB_SUPPORTED"
					TcInternal( 25, "OFF" )
				EndIf
			Next nX
			oProcess:IncRegua1( "Dicionário de parâmetros - " + SM0->M0_CODIGO + " " + SM0->M0_NOME + " ..." )	// Atualiza o dicionário SX6
			FSAtuSX6( @cTexto )
			oProcess:IncRegua1( "Dicionário de gatilhos - " + SM0->M0_CODIGO + " " + SM0->M0_NOME + " ..." )	// Atualiza o dicionário SX7
			FSAtuSX7( @cTexto )
			oProcess:IncRegua1( "Dicionário de pastas - " + SM0->M0_CODIGO + " " + SM0->M0_NOME + " ..." )	// Atualiza o dicionário SXA
			FSAtuSXA( @cTexto )
			oProcess:IncRegua1( "Dicionário de consultas padrão - " + SM0->M0_CODIGO + " " + SM0->M0_NOME + " ..." )	// Atualiza o dicionário SXB
			FSAtuSXB( @cTexto )
			oProcess:IncRegua1( "Dicionário de tabelas sistema - "  + SM0->M0_CODIGO + " " + SM0->M0_NOME + " ..." )	// Atualiza o dicionário SX5
			FSAtuSX5( @cTexto )
			oProcess:IncRegua1( "Dicionário de relacionamentos - "  + SM0->M0_CODIGO + " " + SM0->M0_NOME + " ..." )	// Atualiza o dicionário SX9
			FSAtuSX9( @cTexto )
			oProcess:IncRegua1( "Dicionário de perguntas - "  + SM0->M0_CODIGO + " " + SM0->M0_NOME + " ..." )	// Atualiza o dicionário SX1
			FSAtuSX1( @cTexto )
			oProcess:IncRegua1( "Helps de Campo - "  + SM0->M0_CODIGO + " " + SM0->M0_NOME + " ..." )	// Atualiza os helps
			FSAtuHlp( @cTexto )
			FSAtuHlpX1( @cTexto )
			RpcClearEnv()
		Next nI
		If MyOpenSm0(.T.)
			cAux += Replicate( "-", 128 ) + CRLF
			cAux += Replicate( " ", 128 ) + CRLF
			cAux += "LOG DA ATUALIZACAO DOS DICIONÁRIOS" + CRLF
			cAux += Replicate( " ", 128 ) + CRLF
			cAux += Replicate( "-", 128 ) + CRLF
			cAux += CRLF
			cAux += " Dados Ambiente'        + CRLF
			cAux += " --------------------"  + CRLF
			cAux += " Empresa / Filial...: " + cEmpAnt + "/" + cFilAnt  + CRLF
			cAux += " Nome Empresa.......: " + Capital( AllTrim( GetAdvFVal( "SM0", "M0_NOMECOM", cEmpAnt + cFilAnt, 1, "" ) ) ) + CRLF
			cAux += " Nome Filial........: " + Capital( AllTrim( GetAdvFVal( "SM0", "M0_FILIAL" , cEmpAnt + cFilAnt, 1, "" ) ) ) + CRLF
			cAux += " DataBase...........: " + DtoC( dDataBase )  + CRLF
			cAux += " Data / Hora Inicio.: " + DtoC( Date() ) + " / " + Time()  + CRLF
			cAux += " Environment........: " + GetEnvServer()  + CRLF      
			cAux += " StartPath..........: " + GetSrvProfString( "StartPath", "" )  + CRLF
			cAux += " RootPath...........: " + GetSrvProfString( "RootPath", "" )  + CRLF
			cAux += " Versao.............: " + GetVersao(.T.)  + CRLF
			cAux += " Usuario TOTVS    ..: " + __cUserId + " " +  cUserName + CRLF
			cAux += " Computer Name......: " + GetComputerName()  + CRLF
			aInfo   := GetUserInfo()
			If ( nPos    := aScan( aInfo,{ |x,y| x[3] == ThreadId() } ) ) > 0
				cAux += " "  + CRLF
				cAux += " Dados Thread" + CRLF
				cAux += " --------------------"  + CRLF
				cAux += " Usuario da Rede....: " + aInfo[nPos][1] + CRLF
				cAux += " Estacao............: " + aInfo[nPos][2] + CRLF
				cAux += " Programa Inicial...: " + aInfo[nPos][5] + CRLF
				cAux += " Environment........: " + aInfo[nPos][6] + CRLF
				cAux += " Conexao............: " + AllTrim( StrTran( StrTran( aInfo[nPos][7], Chr( 13 ), "" ), Chr( 10 ), "" ) )  + CRLF
			EndIf
			cAux += Replicate( "-", 128 ) + CRLF
			cAux += CRLF
			cTexto := cAux + cTexto + CRLF
			cTexto += Replicate( "-", 128 ) + CRLF
			cTexto += " Data / Hora Final.: " + DtoC( Date() ) + " / " + Time()  + CRLF
			cTexto += Replicate( "-", 128 ) + CRLF
			cFileLog := MemoWrite( CriaTrab( , .F. ) + ".log", cTexto )
			Define Font oFont Name "Mono AS" Size 5, 12
			Define MsDialog oDlg Title "Atualizacao concluida." From 3, 0 to 340, 417 Pixel
			@ 5, 5 Get oMemo Var cTexto Memo Size 200, 145 Of oDlg Pixel
			oMemo:bRClicked := { || AllwaysTrue() }
			oMemo:oFont     := oFont
			Define SButton From 153, 175 Type  1 Action oDlg:End() Enable Of oDlg Pixel // Apaga
			Define SButton From 153, 145 Type 13 Action ( cFile := cGetFile( cMask, '' ), If( cFile == '', .T., ;
			MemoWrite( cFile, cTexto ) ) ) Enable Of oDlg Pixel // Salva e Apaga //'Salvar Como...'
			Activate MsDialog oDlg Center
		EndIf
	EndIf
Else
	lRet := .F.
EndIf
Return lRet

Static Function FSAtuSX2( cTexto )	// Funcao de processamento da gravacao do SX2 - Arquivos
Local aEstrut   := {}
Local aSX2      := {}
Local cAlias    := ""
Local cEmpr     := ""
Local cPath     := ""
Local nI        := 0
Local nJ        := 0
cTexto  += "Inicio da Atualizacao do SX2" + CRLF + CRLF
aEstrut := { "X2_CHAVE", "X2_PATH", "X2_ARQUIVO", "X2_NOME", "X2_NOMESPA", "X2_NOMEENG", "X2_DELET", "X2_MODO" , "X2_TTS" , "X2_ROTINA" , "X2_PYME", "X2_UNICO"  , "X2_MODULO" }
DbSelectArea( "SX2" )
SX2->( DbSetOrder( 1 ) )
SX2->( DbGoTop() )
cPath := SX2->X2_PATH
cEmpr := Substr( SX2->X2_ARQUIVO, 4 )
cTexto += CRLF + "Final da Atualizacao do SX2" + CRLF + Replicate( "-", 128 ) + CRLF + CRLF
Return aClone( aSX2 )

Static Function FSAtuSX3( cTexto )	// Funcao de processamento da gravacao do SX3 - Campos
Local aEstrut   := {}
Local aSX3      := {}
Local cAlias    := ""
Local cAliasAtu := ""
Local cMsg      := ""
Local cSeqAtu   := ""
Local lTodosNao := .F.
Local lTodosSim := .F.
Local nI        := 0
Local nJ        := 0
Local nOpcA     := 0
Local nPosArq   := 0
Local nPosCpo   := 0
Local nPosOrd   := 0
Local nPosSXG   := 0
Local nPosTam   := 0
Local nSeqAtu   := 0
Local nTamSeek  := Len( SX3->X3_CAMPO )
cTexto  += "Inicio da Atualizacao do SX3" + CRLF + CRLF
aEstrut := { "X3_ARQUIVO", "X3_ORDEM"  , "X3_CAMPO"  , "X3_TIPO"   , "X3_TAMANHO", "X3_DECIMAL", "X3_TITULO" , "X3_TITSPA" , "X3_TITENG" , "X3_DESCRIC", ;
			 "X3_DESCSPA", "X3_DESCENG", "X3_PICTURE", "X3_VALID"  , "X3_USADO"  , "X3_RELACAO", "X3_F3"     , "X3_NIVEL"  , "X3_RESERV" , "X3_CHECK"  , ;
			 "X3_TRIGGER", "X3_PROPRI" , "X3_BROWSE" , "X3_VISUAL" , "X3_CONTEXT", "X3_OBRIGAT", "X3_VLDUSER", "X3_CBOX"   , "X3_CBOXSPA", "X3_CBOXENG", ;
             "X3_PICTVAR", "X3_WHEN"   , "X3_INIBRW" , "X3_GRPSXG" , "X3_FOLDER" , "X3_PYME"   }
// Tabela SA2 (Cadastro de Fornecedores)
aAdd( aSX3, { "SA2", "28", "A2_DVAGE", "C", 1, 0, "Dig. Agencia", "Dig. Agencia", "Dig. Agencia", "Digito da Agencia", "Digito da Agencia", "Digito da Agencia", ; 
			  "@!", "", Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + 	Chr(128) + Chr(128) + ;
			  Chr(128) + Chr(128) + Chr(160), "", "", 0, Chr(254) + Chr(192), "", "", "U", "N", "A", "R", "", "", "", "", "", "", "", "", "", "2", "" } ) 
aAdd( aSX3, { "SA2", "30", "A2_DIGCC", "C", 2, 0, "Digito C/C.", "Digito C/C.", "Digito C/C.", "Digito Conta Corrente", "Digito Conta Corrente", "Digito Conta Corrente", ;
			  "@!", "", Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
			  Chr(128) + Chr(128) + Chr(160), "", "", 0, Chr(254) + Chr(192), "", "", "U", "N", "A", "R", "", "", "", "", "", "", "", "", "", "2", "" } ) 
// Tabela SE2 (Contas a Pagar)
aAdd( aSX3, { "SE2", "C4", "E2_PLACA", "C", 7, 0, "Placa", "Placa", "Placa", "Placa do Veiculo", "Placa do Veiculo", "Placa do Veiculo", "@!", "", ;
		      Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160), ;
		      "", "", 0, Chr(254) + Chr(192),	"", "", "U", "N", "A", "R", "", "", "", "", "", "", "", "", "", "6", "" } )
aAdd( aSX3, { "SE2", "C5", "E2_XAPURAC", "D", 8, 0, "Dt. Apuracao", "Dt. Apuracao", "Dt. Apuracao", "Data de Apuracao", "Data de Apuracao", "Data de Apuracao", ;
			  "@!", "", Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
			  Chr(128) + Chr(128) + Chr(160), "", "", 0, Chr(254) + Chr(192), "", "S", "U", "N", "A", "R", "", "", "", "", "", "", "", ;
			  "", "", "1", "" } ) 
aAdd( aSX3, { "SE2", "K2", "E2_ESCRT", "C", 6, 0, "Cod Pgto/Rec", "Cod Pgto/Rec", "Cod Pgto/Rec", "Cod. Pagamento /Receita", "Cod. Pagamento /Receita", "Cod. Pagamento /Receita", ;
			  "@!", "", Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + 	Chr(128) + Chr(128) + ;
			  Chr(128) + Chr(128) + Chr(160), "", "", 0, Chr(254) + Chr(192), "", "", "U", "N", "A", "R", "", "", "", "", "", "", "", "", "", "1", "" } ) 
aAdd( aSX3, { "SE2", "K3", "E2_ESNFGTS", "N", 16, 0, "Ident. FGTS", "Ident. FGTS", "Ident. FGTS", "Identificador do FGTS", "Identificador do FGTS", "Identificador do FGTS", ;
			  "@E 9999999999999999", "", Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
			  Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160), "", "", 0, Chr(254) + Chr(192), "", "", "U", "N", "A", "R", "", "",	"", "", "", "", "", "", "", "3", "" } )
aAdd( aSX3, { "SE2", "K4", "E2_ESLACRE", "N", 9, 0, "Cod Recolhi.", "Cod Recolhi.",	"Cod Recolhi.", "Cod. Recolhimento FGTS", "Cod. Recolhimento FGTS", "Cod. Recolhimento FGTS", ;
			  "@E 999999999", "", Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
			  Chr(128) + Chr(128) + Chr(128) + Chr(160), "", "", 0, Chr(254) + Chr(192), "", "", "U", "N", "A", "R", "", "", "", "", "", "", "", "", "", "3", "" } ) 
aAdd( aSX3, { "SE2", "K5", "E2_ESDGLAC", "N", 1, 0, "Dig. Recolhi", "Dig. Recolhi", "Dig. Recolhi", "Digito Recolhimento FGTS", "Digito Recolhimento FGTS", "Digito Recolhimento FGTS", ;
			  "@E 9", "", Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
			  Chr(128) + Chr(128) + Chr(160), "", "", 0, Chr(254) + Chr(192), "", "", "U", "N", "A", "R", "", "", "", "", "", "", "", "", "", "3", "" } ) 
aAdd( aSX3, { "SE2", "K6", "E2_ESOPIP", "C", 1, 0, "Cond. Pagto", "Cond. Pagto", "Cond. Pagto", "Condicao de Pagamento", "Condicao de Pagamento", "Condicao de Pagamento", ;
			  "@!", "", Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
			  Chr(128) + Chr(128) + Chr(160), "", "", 0, Chr(254) + Chr(192), "", "", "U", "N", "A", "R", "", "", "0=Pagto DPVAT;1=Parc Unica c/ Desc;2=Parc Unica s/ Desc;3=Parc n° 1;4=Parc n° 2;5=Parc n° 3;6=Parc n° 4;7=Parc n° 5;8=Parc n° 6 ", "", "", "", "", "", "", "6", "" } ) 
aAdd( aSX3, { "SE2", "K7", "E2_MUESPAN", "C", 5, 0, "Municipio", "Municipio", "Municipio", "Municipio da Placa", "Municipio da Placa", "Municipio da Placa", ;
			  "@!", "", Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
			  Chr(128) + Chr(128) + Chr(160), "", "", 0, Chr(254) + Chr(192), "", "", "U", "N", "A", "R", "", "", "", "", "", "", "", "", "", "6", "" } ) 
aAdd( aSX3, { "SE2", "K8", "E2_ESNPN", "N", 13, 0, "N° Parcela", "N° Parcela", "N° Parcela", "N° de Parcela", "N° de Parcela", "N° de Parcela", "@E 9999999999999", ;
			  "", Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
			  Chr(128) + Chr(160), "", "", 0, Chr(254) + Chr(192), "", "", "U", "N", "A", "R", "", "", "", "", "", "", "", "", "", "5", "" } ) 
aAdd( aSX3, { "SE2", "K9", "E2_ESCDA", "N", 13, 0, "N° Div Ativa", "N° Div Ativa", "N° Div Ativa", "N° da Divida Ativa", "N° da Divida Ativa", "N° da Divida Ativa", "@E 9999999999999", ;
			  "", Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
			  Chr(128) + Chr(160), "", "", 0, Chr(254) + Chr(192), "", "", "U", "N", "A", "R", "", "", "", "", "", "", "", "", "", "4", "" } ) 
aAdd( aSX3, { "SE2", "L0", "E2_ESNORIG", "N", 16, 0, "N Doc Origem", "N Doc Origem", "N Doc Origem", "N° do Documento Origem", "N° do Documento Origem", "N° do Documento Origem", ;
			  "@E 9999999999999999", "", Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
			  Chr(128) + Chr(128) + Chr(128) + Chr(160), "", "", 0, Chr(254) + Chr(192), "", "", "U", "N", "A", "R", "", "", "", "", "", "", "", "", "", "5", "" } ) 
aAdd( aSX3, { "SE2", "L1", "E2_ESPRB", "N", 4, 2, "% Rec. Bruta", "% Rec. Bruta", "% Rec. Bruta", "% Receita Bruta", "% Receita Bruta", "% Receita Bruta", "@E 9.99", ;
			  "", Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
			  Chr(128) + Chr(160), "", "", 0, Chr(254) + Chr(192), "", "", "U", "N", "A", "R", "", "", "", "", "", "", "", "", "", "2", "" } ) 
aAdd( aSX3, { "SE2", "L2", "E2_ESVRBA", "N", 9, 2, "Vl Rec Bruta", "Vl Rec Bruta", "Vl Rec Bruta", "Valor da Receita Bruta", "Valor da Receita Bruta", "Valor da Receita Bruta", ;
			  "@E 999,999.99", "", Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
			  Chr(128) + Chr(128) + Chr(160), "", "", 0, Chr(254) + Chr(192), "", "", "U", "N", "A", "R", "", "", "", "", "", "", "", "", "", "2", "" } ) 
aAdd( aSX3, { "SE2", "L3", "E2_ESNREF", "N", 17, 0, "N Referencia", "N Referencia", "N Referencia", "N° de Referencia", "N° de Referencia", "N° de Referencia", ;
			  "@E 99999999999999999", "", Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
			  Chr(128) + Chr(128) + Chr(128) + Chr(160), "", "", 0, Chr(254) + Chr(192), "", "", "U", "N", "A", "R", "", "", "", "", "", "", "", "", "", "2", "" } ) 
aAdd( aSX3, { "SE2", "L4", "E2_ESOCOR2", "C", 1, 0, "Tp Movimento", "Tp Movimento", "Tp Movimento","Tipo de Movimento", "Tipo de Movimento", "Tipo de Movimento", ;
			  "@!", "", Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
			  Chr(128) + Chr(160), "'0'", "", 0, Chr(254) + Chr(192), "", "", "U", "N", "A", "R", "", "", "0=INCLUSAO;1=CONSULTA;3=ESTORNO;5=ALTERACAO;7=LIQUIDACAO;9=EXCLUSAO", ;
			  "", "", "", "", "", "", "", "" } ) 
aAdd( aSX3, { "SE2", "L5", "E2_RENAV", "C", 11, 0, "Renavam", "Renavam", "Renavam", "Renavam do Veiculo", "Renavam do Veiculo", "Renavam do Veiculo", ;
			  "@!", "", Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
			  Chr(128) + Chr(128) + Chr(160), "", "", 0, Chr(254) + Chr(192), "", "", "U", "N", "A", "R", "", "", "", "", "", "", "", "", "", "6", "" } ) 
aAdd( aSX3, { "SE2", "L6", "E2_UFESPAN", "C", 2, 0, "UF do Estado", "UF do Estado", "UF do Estado", "UF do Estado da Placa", "UF do Estado da Placa", "UF do Estado da Placa", ;
			  "@!", "", Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
			  Chr(128) + Chr(128) + Chr(160), "", "", 0, Chr(254) + Chr(192), "", "", "U", "N", "A", "R", "", "", "", "", "", "", "", "", "", "6", "" } ) 
aAdd( aSX3, { "SE2", "L7", "E2_XCOMPET", "C", 6, 0, "Competencia", "Competencia", "Competencia", "Data de Competencia", "Data de Competencia", "Data de Competencia", ;
			  "@!", "", Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + 	Chr(128) + Chr(128) + ;
			  Chr(128) + Chr(128) + Chr(160), "", "", 0, Chr(254) + Chr(192), "", "", "U", "N", "A", "R", "", "", "", "", "", "", "", "", "", "1", "" } ) 
// Tabela SEE
aAdd( aSX3, { "SEE", "48", "EE_JUROS", "N", 5, 2, "Juros diario", "Juros diario", "Juros diario", "Juros diario", "Juros diario", "Juros diario", "@E 99.99", ;
			  "", Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
			  Chr(128) + Chr(160), "", "", 0, Chr(254) + Chr(192), "", "", "U", "N", "A", "R", "", "", "", "", "", "", "", "", "", "1", "" } ) 
aAdd( aSX3, { "SEE", "49", "EE_MULTA", "N", 5, 2, "Multa mes", "Multa mes", "Multa mes", "Multa mes", "Multa mes", "Multa mes", "@E 99.99", "", ;
			  Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
			  Chr(128) + Chr(160), "", "", 0, Chr(254) + Chr(192), "", "", "U", "N", "A", "R", "", "", "", "", "", "", "", "", "", "1", "" } ) 
aAdd( aSX3, { "SEE", "50", "EE_CONTACP", "C", 7, 0, "C/C Complem.", "C/C Complem.", "C/C Complem.", "C/C Complementar", "C/C Complementar", "C/C Complementar", "@!", ;
			  "", Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
			  Chr(128) + Chr(128) + Chr(160), "", "", 0, Chr(254) + Chr(192), "", "", "U", "N", "A", "R", "", "", "", "", "", "", "", "", "", "1", "" } ) 
//aAdd( aSX3, { "SEE", "51", "EE_CART", "C", 3, 0, "Carteira", "Carteira", "Carteira", "Carteira", "Carteira", "Carteira", "@!", "", ;
//			  Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
//			  Chr(128) + Chr(160), "", "", 0, Chr(254) + Chr(192), "", "", "U", "N", "A", "R", "", "", "", "", "", "", "", "", "", "", "" } )                                                                                                                                
//aAdd( aSX3, { "SEE", "50", "EE_MSGBOL", "C", 30, 0, "Msg Boleto", "Msg Boleto", "Msg Boleto", "Mensagem do Boleto", "Mensagem do Boleto", "Mensagem do Boleto", ;
//			  "@!", "", Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
//			  Chr(128) + Chr(128) + Chr(160), "", "", 0, Chr(254) + Chr(192), "", "", "U", "N", "A", "R", "", "", "", "", "", "", "", "", "", "", "" } ) 
nPosArq := aScan( aEstrut, { |x| AllTrim( x ) == "X3_ARQUIVO" } )
nPosOrd := aScan( aEstrut, { |x| AllTrim( x ) == "X3_ORDEM"   } )
nPosCpo := aScan( aEstrut, { |x| AllTrim( x ) == "X3_CAMPO"   } )
nPosTam := aScan( aEstrut, { |x| AllTrim( x ) == "X3_TAMANHO" } )
nPosSXG := aScan( aEstrut, { |x| AllTrim( x ) == "X3_GRPSXG"  } )
aSort( aSX3,,, { |x,y| x[nPosArq]+x[nPosOrd]+x[nPosCpo] < y[nPosArq]+y[nPosOrd]+y[nPosCpo] } )
oProcess:SetRegua2( Len( aSX3 ) )
DbSelectArea( "SX3" )
DbSetOrder( 2 )
cAliasAtu := ""
For nI := 1 To Len( aSX3 )
	// Verifica se o campo faz parte de um grupo e ajsuta tamanho
	If !Empty( aSX3[nI][nPosSXG] )
		SXG->( dbSetOrder( 1 ) )
		If SXG->( MSSeek( aSX3[nI][nPosSXG] ) )
			If aSX3[nI][nPosTam] <> SXG->XG_SIZE
				aSX3[nI][nPosTam] := SXG->XG_SIZE
				cTexto += "O tamanho do campo " + aSX3[nI][nPosCpo] + " nao atualizado e foi mantido em ["
				cTexto += AllTrim( Str( SXG->XG_SIZE ) ) + "]"+ CRLF
				cTexto += "   por pertencer ao grupo de campos [" + SX3->X3_GRPSXG + "]" + CRLF + CRLF
			EndIf
		EndIf
	EndIf
	SX3->( DbSetOrder( 2 ) )
	If !( aSX3[nI][nPosArq] $ cAlias )
		cAlias += aSX3[nI][nPosArq] + "/"
		aAdd( aArqUpd, aSX3[nI][nPosArq] )
	EndIf
	If !SX3->( DbSeek( PadR( aSX3[nI][nPosCpo], nTamSeek ) ) )
		// Busca ultima ocorrencia do alias
		If ( aSX3[nI][nPosArq] <> cAliasAtu )
			cSeqAtu   := "00"
			cAliasAtu := aSX3[nI][nPosArq]
			DbSetOrder( 1 )
			SX3->( DbSeek( cAliasAtu + "ZZ", .T. ) )
			DbSkip( -1 )
			If ( SX3->X3_ARQUIVO == cAliasAtu )
				cSeqAtu := SX3->X3_ORDEM
			EndIf
			nSeqAtu := Val( RetAsc( cSeqAtu, 3, .F. ) )
		EndIf
		nSeqAtu++
		cSeqAtu := RetAsc( Str( nSeqAtu ), 2, .T. )
		RecLock( "SX3", .T. )
		For nJ := 1 To Len( aSX3[nI] )
			If     nJ == 2    // Ordem
				FieldPut( FieldPos( aEstrut[nJ] ), cSeqAtu )
			ElseIf FieldPos( aEstrut[nJ] ) > 0
				FieldPut( FieldPos( aEstrut[nJ] ), aSX3[nI][nJ] )
			EndIf
		Next nJ
		dbCommit()
		MsUnLock()
		cTexto += "Criado o campo " + aSX3[nI][nPosCpo] + CRLF
	Else
		// Verifica se o campo faz parte de um grupo e ajsuta tamanho
		If !Empty( SX3->X3_GRPSXG ) .AND. SX3->X3_GRPSXG <> aSX3[nI][nPosSXG]
			SXG->( DbSetOrder( 1 ) )
			If SXG->( MSSeek( SX3->X3_GRPSXG ) )
				If aSX3[nI][nPosTam] <> SXG->XG_SIZE
					aSX3[nI][nPosTam] := SXG->XG_SIZE
					cTexto += "O tamanho do campo " + aSX3[nI][nPosCpo] + " nao atualizado e foi mantido em ["
					cTexto += AllTrim( Str( SXG->XG_SIZE ) ) + "]"+ CRLF
					cTexto += "   por pertencer ao grupo de campos [" + SX3->X3_GRPSXG + "]" + CRLF + CRLF
				EndIf
			EndIf
		EndIf
		// Verifica todos os campos
		For nJ := 1 To Len( aSX3[nI] )
			// Se o campo estiver diferente da estrutura
			If aEstrut[nJ] == SX3->( FieldName( nJ ) ) .AND. PadR( StrTran( AllToChar( SX3->( FieldGet( nJ ) ) ), " ", "" ), 250 ) <> ;
				PadR( StrTran( AllToChar( aSX3[nI][nJ] )           , " ", "" ), 250 ) .AND. ;
				AllTrim( SX3->( FieldName( nJ ) ) ) <> "X3_ORDEM"
				cMsg := "O campo " + aSX3[nI][nPosCpo] + " está com o " + SX3->( FieldName( nJ ) ) + " com o conteúdo" + CRLF + ;
				"[" + RTrim( AllToChar( SX3->( FieldGet( nJ ) ) ) ) + "]" + CRLF + "que será substituido pelo NOVO conteúdo" + CRLF + ;
				"[" + RTrim( AllToChar( aSX3[nI][nJ] ) ) + "]" + CRLF + "Deseja substituir ? "
				If      lTodosSim
					nOpcA := 1
				ElseIf  lTodosNao
					nOpcA := 2
				Else
					nOpcA := Aviso( "ATUALIZAÇÃO DE DICIONÁRIOS E TABELAS", cMsg, { "Sim", "Não", "Sim p/Todos", "Não p/Todos" }, 3,"Diferença de conteúdo - SX3" )
					lTodosSim := ( nOpcA == 3 )
					lTodosNao := ( nOpcA == 4 )
					If lTodosSim
						nOpcA := 1
						lTodosSim := MsgNoYes( "Foi selecionada a opção de REALIZAR TODAS alterações no SX3 e NÃO MOSTRAR mais a tela de aviso." + CRLF + "Confirma a ação [Sim p/Todos] ?" )
					EndIf
					If lTodosNao
						nOpcA := 2
						lTodosNao := MsgNoYes( "Foi selecionada a opção de NÃO REALIZAR nenhuma alteração no SX3 que esteja diferente da base e NÃO MOSTRAR mais a tela de aviso." + CRLF + "Confirma esta ação [Não p/Todos]?" )
					EndIf
				EndIf
				If nOpcA == 1
					cTexto += "Alterado o campo " + aSX3[nI][nPosCpo] + CRLF
					cTexto += "   " + PadR( SX3->( FieldName( nJ ) ), 10 ) + " de [" + AllToChar( SX3->( FieldGet( nJ ) ) ) + "]" + CRLF
					cTexto += "            para [" + AllToChar( aSX3[nI][nJ] )          + "]" + CRLF + CRLF
					RecLock( "SX3", .F. )
					FieldPut( FieldPos( aEstrut[nJ] ), aSX3[nI][nJ] )
					dbCommit()
					MsUnLock()
				EndIf
			EndIf
		Next
	EndIf
	oProcess:IncRegua2( "Atualizando Campos de Tabelas (SX3)..." )
Next nI
cTexto += CRLF + "Final da Atualizacao do SX3" + CRLF + Replicate( "-", 128 ) + CRLF + CRLF
Return aClone( aSX3 )

Static Function FSAtuSIX( cTexto )	// Funcao de processamento da gravacao do SIX - Indices
Local aEstrut   := {}
Local aSIX      := {}
Local lAlt      := .F.
Local lDelInd   := .F.
Local nI        := 0
Local nJ        := 0
cTexto  += "Inicio da Atualizacao do SIX" + CRLF + CRLF
aEstrut := { "INDICE" , "ORDEM" , "CHAVE", "DESCRICAO", "DESCSPA"  , "DESCENG", "PROPRI", "F3"   , "NICKNAME" , "SHOWPESQ" }
aAdd( aSIX, { "SE2", "G", "E2_NUM", "No. Titulo", "Num. Titulo", "Bill Number", "U", "", "", "S" } ) 
aAdd( aSIX, { "SE2", "H", "E2_VALOR", "Vlr.Titulo", "Vlr. Titulo", "Bill Value", "U", "", "", "S" } ) 
oProcess:SetRegua2( Len( aSIX ) )
DbSelectArea( "SIX" )
SIX->( DbSetOrder( 1 ) )
For nI := 1 To Len( aSIX )
	lAlt := .F.
	If !SIX->( dbSeek( aSIX[nI][1] + aSIX[nI][2] ) )
		RecLock( "SIX", .T. )
		lDelInd := .F.
		cTexto += "Índice criado " + aSIX[nI][1] + "/" + aSIX[nI][2] + " - " + aSIX[nI][3] + CRLF
	Else
		lAlt := .F.
		RecLock( "SIX", .F. )
	EndIf
	If !StrTran( Upper( AllTrim( CHAVE )       ), " ", "") == ;
	    StrTran( Upper( AllTrim( aSIX[nI][3] ) ), " ", "" )
		aAdd( aArqUpd, aSIX[nI][1] )
		If lAlt
			lDelInd := .T.  // Se for alteracao precisa apagar o indice do banco
			cTexto += "Índice alterado " + aSIX[nI][1] + "/" + aSIX[nI][2] + " - " + aSIX[nI][3] + CRLF
		EndIf
		For nJ := 1 To Len( aSIX[nI] )
			If FieldPos( aEstrut[nJ] ) > 0
				FieldPut( FieldPos( aEstrut[nJ] ), aSIX[nI][nJ] )
			EndIf
		Next nJ
		If lDelInd
			TcInternal( 60, RetSqlName( aSIX[nI][1] ) + "|" + RetSqlName( aSIX[nI][1] ) + aSIX[nI][2] ) // Exclui sem precisar baixar o TOP
		EndIf
	EndIf
	dbCommit()
	MsUnLock()
	oProcess:IncRegua2( "Atualizando índices..." )
Next nI
cTexto += CRLF + "Final da Atualizacao do SIX" + CRLF + Replicate( "-", 128 ) + CRLF + CRLF
Return aClone( aSIX )

Static Function FSAtuSX6( cTexto )	// Funcao de processamento da gravacao do SX6 - Parâmetros
Local aEstrut   := {}
Local aSX6      := {}
Local cAlias    := ""
Local cMsg      := ""
Local lContinua := .T.
Local lReclock  := .T.
Local lTodosNao := .F.
Local lTodosSim := .F.
Local nI        := 0
Local nJ        := 0
Local nOpcA     := 0
Local nTamFil   := Len( SX6->X6_FIL )
Local nTamVar   := Len( SX6->X6_VAR )
cTexto  += "Inicio da Atualizacao do SX6" + CRLF + CRLF
aEstrut := { "X6_FIL" , "X6_VAR" , "X6_TIPO" , "X6_DESCRIC" , "X6_DSCSPA" , "X6_DSCENG" , "X6_DESC1" , "X6_DSCSPA1" ,;
             "X6_DSCENG1", "X6_DESC2", "X6_DSCSPA2", "X6_DSCENG2", "X6_CONTEUD", "X6_CONTSPA", "X6_CONTENG", "X6_PROPRI" , "X6_PYME" }
aAdd( aSX6, { "  ", "MV_AG10925", "C", "Indica se os impostos do PCC serao aglutinados em", "", "", "um titulo apenas quando ocorrerem os tres impostos", ; 
			  "", "", "no mesmo titulo. 1= Aglutina e 2= Nao aglutina.", "", "", "1", "1", "1", "U", "" } ) 
aAdd( aSX6, { "  ", "MV_DESCFIN", "C", "Indica se o desconto financeiro sera aplicado inte", "", "", "gral ('I') no primeiro pagamento, ou proporcional", "", "", "('P') ao valor pago en cada parcela.", "", "", "I", "I", "I", "U", "" } ) 
aAdd( aSX6, { "  ", "MV_FINATFN", "C", "'1' = Fluxo Caixa On-Line;'2' = Fluxo Caixa Off-Lin", "", "", "ne", "", "", "", "", "", "1", "1", "1", "U", "" } ) 
aAdd( aSX6, { "  ", "MV_ORCVLD", "L", "Cancela os Orcamentos por validade automaticamente", "Anula los Presupuestos por validez automaticamente", ; 
			  "Cancel Budgets per validity automatically", "", "", "", "", "", "", ".F.", ".F.", ".F.", "U", "" } ) 
aAdd( aSX6, { "  ", "MV_XDTPRF", "C", "Dias de Soma para data de Necessidade", "", "", "", "", "", "Especifico Triah", "", "", "30", "", "", "U", "" } ) 
aAdd( aSX6, { "  ", "MV_XEDTCPA", "C", "Define o momento para a inclusao do vidro na lista", "Especifico Triah", "", "P=Arquivo de Producao, C=Arquivo de Compras", ; 
			  "", "", "Especifico Triah", "", "", "P", "", "", "U", "" } ) 
aAdd( aSX6, { "  ", "MV_XFTPCON", "C", "Parametro de Conexao FTP que sera utilizada pelo", "", "", "integrador (host, porta, usuario, senha)", "", "", ; 
			  "Especifico Triah", "", "", "argusportal.com.br;21;siga;siga", "", "", "U", "" } ) 
aAdd( aSX6, { "  ", "MV_XFTPDEL", "C", "Indica se os arquivos do FTP serao apagados apos", "", "", "baixalos com sucesso", "", "", "Especifico Triah", "", "", ;
			  "N", "", "", "U", ""	} ) 
aAdd( aSX6, { "  ", "MV_XFTPDIR", "C", "Diretorio para onde os arquivos serao baixados do", "", "", "FTP (abaixo do PROTHEUS_DATA)", "", "", "Especifico Triah", ; 
			  "", "", "integrador", "", "", "U", ""	} ) 
aAdd( aSX6, { "  ", "MV_XFTPUOK", "C", "Indica se usa arquivo de controle .OK para os", "", "", "arquivos a baixar", "", "", "Especifico Triah", "", "", "S", ;
			  "", "", "U", "" } ) 
aAdd( aSX6, { "  ", "MV_XGEREMP", "C", "Indica se o sistema ira gerar as lista de empenho", "", "", "", "", "", "Especifico Triah", "", "Especifico Triah", ;
			  "N", "", "", "U", ""	} ) 
aAdd( aSX6, { "  ", "MV_XGRPCMP", "C", "Codigo do Grupo de Produtos para Componentes", "", "", "", "", "", "Especifico Triah", "", "", "SEMG", "", "", "U", ""	} ) 
aAdd( aSX6, { "  ", "MV_XGRPPRF", "C", "Codigo do Grupo de Produtos para Perfis", "", "", "", "", "", "Especifico Triah", "", "", "PALC", "", "", "U", "" } ) 
aAdd( aSX6, { "  ", "MV_XGRPTIP", "C", "Codigo do Grupo de Produtos para Tipologia", "", "", "", "", "", "Especifico Triah", "", "", "ESQ", "", "", "U", "" } ) 
aAdd( aSX6, { "  ", "MV_XGRPVDO", "C", "Codigo do Grupo de Produtos para Vidros", "", "", "", "", "", "Especifico Triah", "", "", "VC", "", "", "U", ""	} ) 
aAdd( aSX6, { "  ", "MV_XLOCPMP", "C", "Indica Armazem padrao para produtos Materia Prima", "", "", "na geracao de produtos pela integracao", "", "", "Especifico Triah", ;
			  "", "", "00000", "", "", "U", "" } ) 
aAdd( aSX6, { "  ", "MV_XLOCPPA", "C", "Indica o armazem padrao para produtos acabados na", "", "", "geracao de tipologia pela integracao", "", "", "Especifico Triah", ;
			  "", "", "00001", "", "", "U", ""	} ) 
aAdd( aSX6, { "  ", "MV_XNCMESQ", "C", "Codigo da NCM para Tipologia", "", "", "", "", "", "Especifico Triah", "", "", "00000000", "", "", "U", "" } ) 
aAdd( aSX6, { "  ", "MV_XNCMPRF", "C", "Codigo da NCM para Perfil", "", "", "", "", "", "Especifico Triah", "", "", "00000000", "", "", "U", ""	} ) 
aAdd( aSX6, { "  ", "MV_XNCMVID", "C", "Codigo da NCM para Vidro", "", "", "", "", "", "Especifico Triah", "", "", "00000000", "", "", "U", "" } )
aAdd( aSX6, { "  ","MV_XTPLOG", "C", "Indica o nivel do LOG (SZ0)", "", "", "1=Somente Erros, 2=Resumido, 3=Completo", "", "", "Especifico Triah", "", "", "3", ;
			  "", "", "U", "" } ) 
oProcess:SetRegua2( Len( aSX6 ) )
DbSelectArea( "SX6" )
DbSetOrder( 1 )
For nI := 1 To Len( aSX6 )
	lContinua := .T.
	lReclock  := .T.
	If SX6->( dbSeek( PadR( aSX6[nI][1], nTamFil ) + PadR( aSX6[nI][2], nTamVar ) ) )
		lReclock  := .F.
		If !StrTran( SX6->X6_CONTEUD, " ", "" ) == StrTran( aSX6[nI][13], " ", "" )
			cMsg := "O parâmetro " + aSX6[nI][2] + " está com o conteúdo" + CRLF + "[" + RTrim( StrTran( SX6->X6_CONTEUD, " ", "" ) ) + "]" + CRLF + ;
			", que é será substituido pelo NOVO conteúdo " + CRLF + "[" + RTrim( StrTran( aSX6[nI][13]   , " ", "" ) ) + "]" + CRLF + "Deseja substituir ? "
			If      lTodosSim
				nOpcA := 1
			ElseIf  lTodosNao
				nOpcA := 2
			Else
				nOpcA := Aviso( "ATUALIZAÇÃO DE DICIONÁRIOS E TABELAS", cMsg, { "Sim", "Não", "Sim p/Todos", "Não p/Todos" }, 3,"Diferença de conteúdo - SX6" )
				lTodosSim := ( nOpcA == 3 )
				lTodosNao := ( nOpcA == 4 )
				If lTodosSim
					nOpcA := 1
					lTodosSim := MsgNoYes( "Foi selecionada a opção de REALIZAR TODAS alterações no SX6 e NÃO MOSTRAR mais a tela de aviso." + CRLF + "Confirma a ação [Sim p/Todos] ?" )
				EndIf
				If lTodosNao
					nOpcA := 2
					lTodosNao := MsgNoYes( "Foi selecionada a opção de NÃO REALIZAR nenhuma alteração no SX6 que esteja diferente da base e NÃO MOSTRAR mais a tela de aviso." + CRLF + "Confirma esta ação [Não p/Todos]?" )
				EndIf
			EndIf
			lContinua := ( nOpcA == 1 )
			If lContinua
				cTexto += "Foi alterado o parâmetro " + aSX6[nI][1] + aSX6[nI][2] + " de [" + ;
				AllTrim( SX6->X6_CONTEUD ) + "]" + " para [" + AllTrim( aSX6[nI][13] ) + "]" + CRLF
			EndIf
		Else
			lContinua := .F.
		EndIf
	Else
		cTexto += "Foi incluído o parâmetro " + aSX6[nI][1] + aSX6[nI][2] + " Conteúdo [" + AllTrim( aSX6[nI][13] ) + "]"+ CRLF
	EndIf
	If lContinua
		If !( aSX6[nI][1] $ cAlias )
			cAlias += aSX6[nI][1] + "/"
		EndIf
		RecLock( "SX6", lReclock )
		For nJ := 1 To Len( aSX6[nI] )
			If FieldPos( aEstrut[nJ] ) > 0
				FieldPut( FieldPos( aEstrut[nJ] ), aSX6[nI][nJ] )
			EndIf
		Next nJ
		dbCommit()
		MsUnLock()
		oProcess:IncRegua2( "Atualizando Arquivos (SX6)...")
	EndIf
Next nI
cTexto += CRLF + "Final da Atualizacao do SX6" + CRLF + Replicate( "-", 128 ) + CRLF + CRLF
Return aClone( aSX6 )

Static Function FSAtuSX7( cTexto )	// Funcao de processamento da gravacao do SX7 - Gatilhos
Local aEstrut   := {}
Local aSX7      := {}
Local cAlias    := ""
Local nI        := 0
Local nJ        := 0
Local nTamSeek  := Len( SX7->X7_CAMPO )
cTexto  += "Inicio da Atualizacao do SX7" + CRLF + CRLF
aEstrut := { "X7_CAMPO", "X7_SEQUENC", "X7_REGRA", "X7_CDOMIN", "X7_TIPO", "X7_SEEK", "X7_ALIAS", "X7_ORDEM"  , "X7_CHAVE", "X7_PROPRI", "X7_CONDIC" }
aAdd( aSX7, { "E2_CODBAR", "001", "ExecBlock('FSHINP03',.T.)", "E2_CODBAR", "P", "N", "", 0, "", "U", "" } ) 
oProcess:SetRegua2( Len( aSX7 ) )
dbSelectArea( "SX7" )
dbSetOrder( 1 )
For nI := 1 To Len( aSX7 )
	If !SX7->( dbSeek( PadR( aSX7[nI][1], nTamSeek ) + aSX7[nI][2] ) )
		If !( aSX7[nI][1] $ cAlias )
			cAlias += aSX7[nI][1] + "/"
			cTexto += "Foi incluído o gatilho " + aSX7[nI][1] + "/" + aSX7[nI][2] + CRLF
		EndIf
		RecLock( "SX7", .T. )
	Else
		If !( aSX7[nI][1] $ cAlias )
			cAlias += aSX7[nI][1] + "/"
			cTexto += "Foi alterado o gatilho " + aSX7[nI][1] + "/" + aSX7[nI][2] + CRLF
		EndIf
		RecLock( "SX7", .F. )
	EndIf
	For nJ := 1 To Len( aSX7[nI] )
		If FieldPos( aEstrut[nJ] ) > 0
			FieldPut( FieldPos( aEstrut[nJ] ), aSX7[nI][nJ] )
		EndIf
	Next nJ
	dbCommit()
	MsUnLock()
	oProcess:IncRegua2( "Atualizando Arquivos (SX7)...")
Next nI
cTexto += CRLF + "Final da Atualizacao do SX7" + CRLF + Replicate( "-", 128 ) + CRLF + CRLF
Return aClone( aSX7 )

Static Function FSAtuSXA( cTexto )	// Funcao de processamento da gravacao do SXA - Pastas (Tabela SE2)
Local aEstrut   := {}
Local aSXA      := {}
Local cAlias    := ""
Local nI        := 0
Local nJ        := 0
cTexto  += "Inicio da Atualizacao do SXA" + CRLF + CRLF
aEstrut := { "XA_ALIAS", "XA_ORDEM", "XA_DESCRIC", "XA_DESCSPA", "XA_DESCENG", "XA_PROPRI" }
aAdd( aSXA, { "SE2", "1", "Cadastrais", "Cadastrais", "Cadastrais", "U" } )
aAdd( aSXA, { "SE2", "2", "Darf Simples /Normal", "Darf Simples /Normal", "Darf Simples /Normal", "U" } ) 
aAdd( aSXA, { "SE2", "3", "Fgts - Gfip", "Fgts - Gfip", "Fgts - Gfip", "U"	} ) 
aAdd( aSXA, { "SE2", "4", "Gare SP ICMS", "Gare SP ICMS", "Gare SP ICMS", "U" } ) 
aAdd( aSXA, { "SE2", "5", "Gnre", "Gnre", "Gnre", "U" } ) 
aAdd( aSXA, { "SE2", "6", "Ipva /Dpvat /Licenciamento", "Ipva /Dpvat /Licenciamento", "Ipva /Dpvat /Licenciamento", "U" } ) 
oProcess:SetRegua2( Len( aSXA ) )
DbSelectArea( "SXA" )
DbSetOrder( 1 )
For nI := 1 To Len( aSXA )
	If !SXA->( dbSeek( aSXA[nI][1] + aSXA[nI][2] ) )
		If !( aSXA[nI][1] $ cAlias )
			cAlias += aSXA[nI][1] + "/"
		EndIf
		RecLock( "SXA", .T. )
		For nJ := 1 To Len( aSXA[nI] )
			If FieldPos( aEstrut[nJ] ) > 0
			FieldPut( FieldPos( aEstrut[nJ] ), aSXA[nI][nJ] )
			EndIf
		Next nJ
		dbCommit()
		MsUnLock()
		cTexto += "Foi incluída a pasta " + aSXA[nI][1] + "/" + aSXA[nI][2]  + CRLF
		oProcess:IncRegua2( "Atualizando Arquivos (SXA)...")
	EndIf
Next nI
cTexto += CRLF + "Final da Atualizacao do SXA" + CRLF + Replicate( "-", 128 ) + CRLF + CRLF
Return aClone( aSXA )

Static Function FSAtuSXB( cTexto )	// Funcao de processamento da gravacao do SXB - Consultas Padrao
Local aEstrut   := {}
Local aSXB      := {}
Local cAlias    := ""
Local cMsg      := ""
Local lTodosNao := .F.
Local lTodosSim := .F.
Local nI        := 0
Local nJ        := 0
Local nOpcA     := 0
cTexto  += "Inicio da Atualizacao do SXB" + CRLF + CRLF
aEstrut := { "XB_ALIAS" , "XB_TIPO" , "XB_SEQ" , "XB_COLUNA" , "XB_DESCRI" , "XB_DESCSPA" , "XB_DESCENG" , "XB_CONTEM" }
cTexto += CRLF + "Final da Atualizacao do SXB" + CRLF + Replicate( "-", 128 ) + CRLF + CRLF
Return aClone( aSXB )

Static Function FSAtuSX5( cTexto )	// Funcao de processamento da gravacao do SX5 - Indices
Local aEstrut   := {}
Local aSX5      := {}
Local cAlias    := ""
Local nI        := 0
Local nJ        := 0
cTexto  += "Inicio Atualizacao SX5" + CRLF + CRLF
aEstrut := { "X5_FILIAL", "X5_TABELA", "X5_CHAVE", "X5_DESCRI", "X5_DESCSPA", "X5_DESCENG" }
oProcess:SetRegua2( Len( aSX5 ) )
DbSelectArea( "SX5" )
SX5->( DbSetOrder( 1 ) )
For nI := 1 To Len( aSX5 )
	oProcess:IncRegua2( "Atualizando tabelas..." )
	If !SX5->( DbSeek( aSX5[nI][1] + aSX5[nI][2] + aSX5[nI][3]) )
		cTexto += "Item da tabela criado. Tabela "   + AllTrim( aSX5[nI][1] ) + aSX5[nI][2] + "/" + aSX5[nI][3] + CRLF
		RecLock( "SX5", .T. )
	Else
		cTexto += "Item da tabela alterado. Tabela " + AllTrim( aSX5[nI][1] ) + aSX5[nI][2] + "/" + aSX5[nI][3] + CRLF
		RecLock( "SX5", .F. )
	EndIf
	For nJ := 1 To Len( aSX5[nI] )
		If FieldPos( aEstrut[nJ] ) > 0
			FieldPut( FieldPos( aEstrut[nJ] ), aSX5[nI][nJ] )
		EndIf
	Next nJ
	MsUnLock()
	aAdd( aArqUpd, aSX5[nI][1] )
	If !( aSX5[nI][1] $ cAlias )
		cAlias += aSX5[nI][1] + "/"
	EndIf
Next nI
cTexto += CRLF + "Final da Atualizacao do SX5" + CRLF + Replicate( "-", 128 ) + CRLF + CRLF
Return aClone( aSX5 )

Static Function FSAtuSX1( cTexto )	// Funcao de processamento da gravacao do SX1 - Perguntas
Local aEstrut   := {}
Local aSX1      := {}
Local aStruDic  := SX1->( dbStruct() )
Local cAlias    := ""
Local nI        := 0
Local nJ        := 0
Local nTam1     := Len( SX1->X1_GRUPO )
Local nTam2     := Len( SX1->X1_ORDEM )
cTexto  += "Inicio Atualizacao SX1" + CRLF + CRLF
aEstrut := { "X1_GRUPO"  , "X1_ORDEM"  , "X1_PERGUNT", "X1_PERSPA" , "X1_PERENG" , "X1_VARIAVL", "X1_TIPO"   , "X1_TAMANHO", "X1_DECIMAL", "X1_PRESEL" , ;
			 "X1_GSC"    , "X1_VALID"  , "X1_VAR01"  , "X1_DEF01"  , "X1_DEFSPA1", "X1_DEFENG1", "X1_CNT01"  , "X1_VAR02"  , "X1_DEF02"  , "X1_DEFSPA2", ;
			 "X1_DEFENG2", "X1_CNT02"  , "X1_VAR03"  , "X1_DEF03"  , "X1_DEFSPA3", "X1_DEFENG3", "X1_CNT03"  , "X1_VAR04"  , "X1_DEF04"  , "X1_DEFSPA4", ;
			 "X1_DEFENG4", "X1_CNT04"  , "X1_VAR05"  , "X1_DEF05"  , "X1_DEFSPA5", "X1_DEFENG5", "X1_CNT05"  , "X1_F3"     , "X1_PYME"   , "X1_GRPSXG" , ;
			 "X1_HELP"   , "X1_PICTURE", "X1_IDFIL"   }
oProcess:SetRegua2( Len( aSX1 ) )
dbSelectArea( "SX1" )
SX1->( dbSetOrder( 1 ) )
For nI := 1 To Len( aSX1 )
	oProcess:IncRegua2( "Atualizando perguntas..." )
	If !SX1->( dbSeek( PadR( aSX1[nI][1], nTam1 ) + PadR( aSX1[nI][2], nTam2 ) ) )
		cTexto += "Pergunta Criada. Grupo/Ordem "   + aSX1[nI][1] + "/" + aSX1[nI][2] + CRLF
		RecLock( "SX1", .T. )
	Else
		cTexto += "Pergunta Alterada. Grupo/Ordem " + aSX1[nI][1] + "/" + aSX1[nI][2] + CRLF
		RecLock( "SX1", .F. )
	EndIf
	For nJ := 1 To Len( aSX1[nI] )
		If aScan( aStruDic, { |aX| PadR( aX[1], 10 ) == PadR( aEstrut[nJ], 10 ) } ) > 0
			SX1->( FieldPut( FieldPos( aEstrut[nJ] ), aSX1[nI][nJ] ) )
		EndIf
	Next nJ
	MsUnLock()
Next nI
cTexto += CRLF + "Final da Atualizacao do SX1" + CRLF + Replicate( "-", 128 ) + CRLF + CRLF
Return aClone( aSX1 )

Static Function FSAtuSX9( cTexto )	// Funcao de processamento da gravacao do SX9 - Relacionamento
Local aEstrut   := {}
Local aSX9      := {}
Local cAlias    := ""
Local nI        := 0
Local nJ        := 0
Local nTamSeek  := Len( SX9->X9_DOM )
cTexto  += "Inicio da Atualizacao do SX9" + CRLF + CRLF
aEstrut := { "X9_DOM"   , "X9_IDENT"  , "X9_CDOM"   , "X9_EXPDOM", "X9_EXPCDOM" ,"X9_PROPRI", "X9_LIGDOM", "X9_LIGCDOM", "X9_CONDSQL", "X9_USEFIL", "X9_ENABLE" }
cTexto += CRLF + "Final da Atualizacao do SX9" + CRLF + Replicate( "-", 128 ) + CRLF + CRLF
Return aClone( aSX9 )

Static Function FSAtuHlp( cTexto )	// Funcao de processamento da gravacao dos Helps de Campos
Local aHlpPor   := {}
Local aHlpEng   := {}
Local aHlpSpa   := {}
cTexto += "Inicio da Atualizacao ds Helps de Campos" + CRLF + CRLF
oProcess:IncRegua2(  "Atualizando Helps de Campos ..." )
// Helps Tabela SA2
aHlpPor := {}
aAdd( aHlpPor, "Digito da Agencia." )
aHlpEng := {}
aHlpSpa := {}
PutHelp( "PA2_DVAGE  ", aHlpPor, aHlpEng, aHlpSpa, .T. )
cTexto += "Atualizado o Help do campo A2_DVAGE  " + CRLF
aHlpPor := {}
aAdd( aHlpPor, "Digito Conta Corrente." )
aHlpEng := {}
aHlpSpa := {}
PutHelp( "PA2_DIGCC  ", aHlpPor, aHlpEng, aHlpSpa, .T. )
cTexto += "Atualizado o Help do campo A2_DIGCC  " + CRLF
// Helps Tabela SE2
aHlpPor := {}
aAdd( aHlpPor, "Placa." )
aHlpEng := {}
aHlpSpa := {}
PutHelp( "PE2_PLACA  ", aHlpPor, aHlpEng, aHlpSpa, .T. )
cTexto += "Atualizado o Help do campo E2_PLACA  " + CRLF
aHlpPor := {}
aAdd( aHlpPor, "Dt. Apuracao." )
aHlpEng := {}
aHlpSpa := {}
PutHelp( "PE2_XAPURAC", aHlpPor, aHlpEng, aHlpSpa, .T. )
cTexto += "Atualizado o Help do campo E2_XAPURAC" + CRLF
aHlpPor := {}
aAdd( aHlpPor, "Cod. Pagamento /Receita." )
aHlpEng := {}
aHlpSpa := {}
PutHelp( "PE2_ESCRT  ", aHlpPor, aHlpEng, aHlpSpa, .T. )
cTexto += "Atualizado o Help do campo E2_ESCRT  " + CRLF
aHlpPor := {}
aAdd( aHlpPor, "Identificador do FGTS." )
aHlpEng := {}
aHlpSpa := {}
PutHelp( "PE2_ESNFGTS", aHlpPor, aHlpEng, aHlpSpa, .T. )
cTexto += "Atualizado o Help do campo E2_ESNFGTS" + CRLF
aHlpPor := {}
aAdd( aHlpPor, "Codigo de Recolhimento FGTS." )
aHlpEng := {}
aHlpSpa := {}
PutHelp( "PE2_ESLACRE", aHlpPor, aHlpEng, aHlpSpa, .T. )
cTexto += "Atualizado o Help do campo E2_ESLACRE" + CRLF
aHlpPor := {}
aAdd( aHlpPor, "Digito de Recolhimento FGTS." )
aHlpEng := {}
aHlpSpa := {}
PutHelp( "PE2_ESDGLAC", aHlpPor, aHlpEng, aHlpSpa, .T. )
cTexto += "Atualizado o Help do campo E2_ESDGLAC" + CRLF
aHlpPor := {}
aAdd( aHlpPor, "Condicao de Pagamento." )
aHlpEng := {}
aHlpSpa := {}
PutHelp( "PE2_ESOPIP ", aHlpPor, aHlpEng, aHlpSpa, .T. )
cTexto += "Atualizado o Help do campo E2_ESOPIP " + CRLF
aHlpPor := {}
aAdd( aHlpPor, "Codigo de Veiculo." )
aHlpEng := {}
aHlpSpa := {}
PutHelp( "PE2_MUESPAN", aHlpPor, aHlpEng, aHlpSpa, .T. )
cTexto += "Atualizado o Help do campo E2_MUESPAN" + CRLF
aHlpPor := {}
aAdd( aHlpPor, "N° de Parcela." )
aHlpEng := {}
aHlpSpa := {}
PutHelp( "PE2_ESNPN  ", aHlpPor, aHlpEng, aHlpSpa, .T. )
cTexto += "Atualizado o Help do campo E2_ESNPN  " + CRLF
aHlpPor := {}
aAdd( aHlpPor, "N° da Divida Ativa." )
aHlpEng := {}
aHlpSpa := {}
PutHelp( "PE2_ESCDA  ", aHlpPor, aHlpEng, aHlpSpa, .T. )
cTexto += "Atualizado o Help do campo E2_ESCDA  " + CRLF
aHlpPor := {}
aAdd( aHlpPor, "N° do Documento Origem." )
aHlpEng := {}
aHlpSpa := {}
PutHelp( "PE2_ESNORIG", aHlpPor, aHlpEng, aHlpSpa, .T. )
cTexto += "Atualizado o Help do campo E2_ESNORIG" + CRLF
aHlpPor := {}
aAdd( aHlpPor, "% Receita Bruta." )
aHlpEng := {}
aHlpSpa := {}
PutHelp( "PE2_ESPRB  ", aHlpPor, aHlpEng, aHlpSpa, .T. )
cTexto += "Atualizado o Help do campo E2_ESPRB  " + CRLF
aHlpPor := {}
aAdd( aHlpPor, "Valor da Receita Bruta." )
aHlpEng := {}
aHlpSpa := {}
PutHelp( "PE2_ESVRBA ", aHlpPor, aHlpEng, aHlpSpa, .T. )
cTexto += "Atualizado o Help do campo E2_ESVRBA " + CRLF
aHlpPor := {}
aAdd( aHlpPor, "N° de Referencia." )
aHlpEng := {}
aHlpSpa := {}
PutHelp( "PE2_ESNREF ", aHlpPor, aHlpEng, aHlpSpa, .T. )
cTexto += "Atualizado o Help do campo E2_ESNREF " + CRLF
aHlpPor := {}
aAdd( aHlpPor, "Tipo de Movimento." )
aHlpEng := {}
aHlpSpa := {}
PutHelp( "PE2_ESOCOR2", aHlpPor, aHlpEng, aHlpSpa, .T. )
cTexto += "Atualizado o Help do campo E2_ESOCOR2" + CRLF
aHlpPor := {}
aAdd( aHlpPor, "Renavam." )
aHlpEng := {}
aHlpSpa := {}
PutHelp( "PE2_RENAV  ", aHlpPor, aHlpEng, aHlpSpa, .T. )
cTexto += "Atualizado o Help do campo E2_RENAV  " + CRLF
aHlpPor := {}
aAdd( aHlpPor, "UF do Estado." )
aHlpEng := {}
aHlpSpa := {}
PutHelp( "PE2_UFESPAN", aHlpPor, aHlpEng, aHlpSpa, .T. )
cTexto += "Atualizado o Help do campo E2_UFESPAN" + CRLF
aHlpPor := {}
aAdd( aHlpPor, "Data de Competencia." )
aHlpEng := {}
aHlpSpa := {}
PutHelp( "PE2_XCOMPET", aHlpPor, aHlpEng, aHlpSpa, .T. )
cTexto += "Atualizado o Help do campo E2_XCOMPET" + CRLF
// Helps Tabela SEE
aHlpPor := {}
aAdd( aHlpPor, "Juros diario" )
aHlpEng := {}
aHlpSpa := {}
PutHelp( "PEE_JUROS  ", aHlpPor, aHlpEng, aHlpSpa, .T. )
cTexto += "Atualizado o Help do campo EE_JUROS  " + CRLF
aHlpPor := {}
aAdd( aHlpPor, "Multa mes" )
aHlpEng := {}
aHlpSpa := {}
PutHelp( "PEE_MULTA  ", aHlpPor, aHlpEng, aHlpSpa, .T. )
cTexto += "Atualizado o Help do campo EE_MULTA  " + CRLF
aHlpPor := {}
aAdd( aHlpPor, "C/C Complementar." )
aHlpEng := {}
aHlpSpa := {}
PutHelp( "PEE_CONTACP", aHlpPor, aHlpEng, aHlpSpa, .T. )
cTexto += "Atualizado o Help do campo EE_CONTACP" + CRLF
//aHlpPor := {}
//aAdd( aHlpPor, "Carteira." )
//aHlpEng := {}
//aHlpSpa := {}
//PutHelp( "PEE_CART   ", aHlpPor, aHlpEng, aHlpSpa, .T. )
//cTexto += "Atualizado o Help do campo EE_CART   " + CRLF
//aHlpPor := {}
//aAdd( aHlpPor, "Codigo da Carteira." )
//aAdd( aHlpPor, "5 = Cobranca Simples (Rapida com" )
//aAdd( aHlpPor, "Registro)" )
//aAdd( aHlpPor, "4 = Cobranca Descontada ( Eletronica com" )
//aHlpEng := {}
//aHlpSpa := {}
//PutHelp( "PEE_CODCART", aHlpPor, aHlpEng, aHlpSpa, .T. )
//cTexto += "Atualizado o Help do campo EE_CODCART" + CRLF
cTexto += CRLF + "Final da Atualizacao dos Helps de Campos" + CRLF + Replicate( "-", 128 ) + CRLF + CRLF
Return {}

Static Function FSAtuHlpX1( cTexto )	// Funcao de processamento da gravacao dos Helps de Perguntas
Local aHlpPor   := {}
Local aHlpEng   := {}
Local aHlpSpa   := {}
cTexto += "Inicio da Atualizacao ds Helps de Perguntas" + CRLF + CRLF
cTexto += CRLF + "Final da Atualizacao dos Helps de Perguntas" + CRLF + Replicate( "-", 128 ) + CRLF + CRLF
Return {}

Static Function EscEmpresa()	// Funcao Generica p/ escolha de Empresa, montado pelo SM0_. Retorna vetor contendo as selecoes feitas. Se nao For marcada nenhuma o vetor volta vazio.
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Parametro  nTipo                           ³
//³ 1  - Monta com Todas Empresas/Filiais      ³
//³ 2  - Monta so com Empresas                 ³
//³ 3  - Monta so com Filiais de uma Empresa   ³
//³                                            ³
//³ Parametro  aMarcadas                       ³
//³ Vetor com Empresas/Filiais pre marcadas    ³
//³                                            ³
//³ Parametro  cEmpSel                         ³
//³ Empresa que sera usada para montar selecao ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local   aSalvAmb := GetArea()
Local   aSalvSM0 := {}
Local   aRet     := {}
Local   aVetor   := {}
Local   oDlg     := NIL
Local   oChkMar  := NIL
Local   oLbx     := NIL
Local   oMascEmp := NIL
Local   oMascFil := NIL
Local   oButMarc := NIL
Local   oButDMar := NIL
Local   oButInv  := NIL
Local   oSay     := NIL
Local   oOk      := LoadBitmap( GetResources(), "LBOK" )
Local   oNo      := LoadBitmap( GetResources(), "LBNO" )
Local   lChk     := .F.
Local   lOk      := .F.
Local   lTeveMarc:= .F.
Local   cVar     := ""
Local   cNomEmp  := ""
Local   cMascEmp := "??"
Local   cMascFil := "??"
Local   aMarcadas  := {}
If !MyOpenSm0(.F.)
	Return aRet
EndIf
DbSelectArea( "SM0" )
aSalvSM0 := SM0->( GetArea() )
DbSetOrder( 1 )
DbGoTop()
While !SM0->( EOF() )
	If aScan( aVetor, {|x| x[2] == SM0->M0_CODIGO} ) == 0
		aAdd(  aVetor, { aScan( aMarcadas, {|x| x[1] == SM0->M0_CODIGO .and. x[2] == SM0->M0_CODFIL} ) > 0, SM0->M0_CODIGO, SM0->M0_CODFIL, SM0->M0_NOME, SM0->M0_FILIAL } )
	EndIf
	dbSkip()
End
RestArea( aSalvSM0 )
Define MSDialog  oDlg Title "" From 0, 0 To 270, 396 Pixel
oDlg:cToolTip := "Tela para Múltiplas Seleções de Empresas/Filiais"
oDlg:cTitle := "Selecione a(s) Empresa(s) para Atualização"
@ 10, 10 Listbox  oLbx Var  cVar Fields Header " ", " ", "Empresa" Size 178, 095 Of oDlg Pixel
oLbx:SetArray(  aVetor )
oLbx:bLine := {|| {IIf( aVetor[oLbx:nAt, 1], oOk, oNo ), aVetor[oLbx:nAt, 2], aVetor[oLbx:nAt, 4]}}
oLbx:BlDblClick := { || aVetor[oLbx:nAt, 1] := !aVetor[oLbx:nAt, 1], VerTodos( aVetor, @lChk, oChkMar ), oChkMar:Refresh(), oLbx:Refresh()}
oLbx:cToolTip   :=  oDlg:cTitle
oLbx:lHScroll   := .F. // NoScroll
@ 112, 10 CheckBox oChkMar Var  lChk Prompt "Todos"   Message "Marca / Desmarca Todos" Size 40, 007 Pixel Of oDlg on Click MarcaTodos( lChk, @aVetor, oLbx )
@ 123, 10 Button oButInv Prompt "&Inverter"  Size 32, 12 Pixel Action ( InvSelecao( @aVetor, oLbx, @lChk, oChkMar ), VerTodos( aVetor, @lChk, oChkMar ) ) Message "Inverter Seleção" Of oDlg
// Marca/Desmarca por mascara
@ 113, 51 Say  oSay Prompt "Empresa" Size  40, 08 Of oDlg Pixel
@ 112, 80 MSGet  oMascEmp Var  cMascEmp Size  05, 05 Pixel Picture "@!"  Valid (  cMascEmp := StrTran( cMascEmp, " ", "?" ), cMascFil := StrTran( cMascFil, " ", "?" ), oMascEmp:Refresh(), .T. ) Message "Máscara Empresa ( ?? )"  Of oDlg
@ 123, 50 Button oButMarc Prompt "&Marcar"    Size 32, 12 Pixel Action ( MarcaMas( oLbx, aVetor, cMascEmp, .T. ), VerTodos( aVetor, @lChk, oChkMar ) ) Message "Marcar usando máscara ( ?? )"    Of oDlg
@ 123, 80 Button oButDMar Prompt "&Desmarcar" Size 32, 12 Pixel Action ( MarcaMas( oLbx, aVetor, cMascEmp, .F. ), VerTodos( aVetor, @lChk, oChkMar ) ) Message "Desmarcar usando máscara ( ?? )" Of oDlg
Define SButton From 111, 125 Type 1 Action ( RetSelecao( @aRet, aVetor ), oDlg:End() ) OnStop "Confirma a Seleção"  Enable Of oDlg
Define SButton From 111, 158 Type 2 Action ( IIf( lTeveMarc, aRet :=  aMarcadas, .T. ), oDlg:End() ) OnStop "Abandona a Seleção" Enable Of oDlg
Activate MSDialog  oDlg Center
RestArea( aSalvAmb )
DbSelectArea( "SM0" )
DbCloseArea()
Return  aRet

Static Function MarcaTodos( lMarca, aVetor, oLbx )	// Funcao Auxiliar para marcar/desmarcar todos os itens do ListBox Ativo
Local  nI := 0
For nI := 1 To Len( aVetor )
	aVetor[nI][1] := lMarca
Next nI
oLbx:Refresh()
Return NIL

Static Function InvSelecao( aVetor, oLbx )	// Funcao Auxiliar para inverter selecao do ListBox Ativo
Local  nI := 0
For nI := 1 To Len( aVetor )
	aVetor[nI][1] := !aVetor[nI][1]
Next nI
oLbx:Refresh()
Return NIL

Static Function RetSelecao( aRet, aVetor )	// Funcao Auxiliar que monta o retorno com as selecoes
Local  nI    := 0
aRet := {}
For nI := 1 To Len( aVetor )
	If aVetor[nI][1]
		aAdd( aRet, { aVetor[nI][2] , aVetor[nI][3], aVetor[nI][2] +  aVetor[nI][3] } )
	EndIf
Next nI
Return NIL

Static Function MarcaMas( oLbx, aVetor, cMascEmp, lMarDes )	// Funcao para marcar/desmarcar usando mascaras
Local cPos1 := SubStr( cMascEmp, 1, 1 )
Local cPos2 := SubStr( cMascEmp, 2, 1 )
Local nPos  := oLbx:nAt
Local nZ    := 0
For nZ := 1 To Len( aVetor )
	If cPos1 == "?" .or. SubStr( aVetor[nZ][2], 1, 1 ) == cPos1
		If cPos2 == "?" .or. SubStr( aVetor[nZ][2], 2, 1 ) == cPos2
			aVetor[nZ][1] :=  lMarDes
		EndIf
	EndIf
Next
oLbx:nAt := nPos
oLbx:Refresh()
Return NIL

Static Function VerTodos( aVetor, lChk, oChkMar )	// Funcao auxiliar para verificar se estao Todos Marcardos ou Nao
Local lTTrue := .T.
Local nI     := 0
For nI := 1 To Len( aVetor )
	lTTrue := IIf( !aVetor[nI][1], .F., lTTrue )
Next nI
lChk := IIf( lTTrue, .T., .F. )
oChkMar:Refresh()
Return NIL

Static Function MyOpenSM0(lShared)	// Funcao de processamento abertura do SM0 modo exclusivo
Local lOpen := .F.
Local nLoop := 0
For nLoop := 1 To 20
	DbUseArea( .T., , "SIGAMAT.EMP", "SM0", lShared, .F. )
	If !Empty( Select( "SM0" ) )
		lOpen := .T.
		dbSetIndex( "SIGAMAT.IND" )
		Exit
	EndIf
	Sleep( 500 )
Next nLoop
If !lOpen
	MsgStop( "Não foi possível a abertura da tabela " + IIf( lShared, "de Empresas (SM0).", "de Empresas (SM0) de forma exclusiva." ), "ATENÇÃO" )
EndIf
Return lOpen