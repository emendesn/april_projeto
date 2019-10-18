#include "protheus.ch"
#include "TbiConn.ch"
#include "TbiCode.ch"
#include "topconn.ch"
#Include 'ApWebEx.ch'
#include "prtopdef.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณWFW120P   บAutor  ณThiago Rocco      บ Fecha 26/07/2018     บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณPE na gravacao do Pedido de compras para ativacao de WF     บฑฑ
ฑฑบ          ณdo controle de alcadas                                      บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ COPPEL                                                     บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

USER function WFW120P(nOpcao,oProcess)
	Local lContinua := .T.
	Private cPerg := "WFW120P"


	//Corrigo a observa็ใo do Pedido
	/*
	cQuery := " UPDATE "+RetSQlName("SC7")+" SET C7_OBS=SUBSTRING(C7_OBSM,1,30)"
	cQuery += " WHERE D_E_L_E_T_<>'*' AND C7_OBSM <>'' AND C7_NUM='"+SC7->C7_NUM+"'"

	If TCSQLExec(cQuery) < 0
	MsgStop( "TCSQLError() " + TCSQLError(), 'April Brasil' )
	EndIf
	*/

	CONOUT("LOGWF: ***ENTRADA DO WF")

	If ValType(nOpcao) = "A"
		nOpcao := nOpcao[1]
	Endif

	If nOpcao == NIL
		nOpcao := 0
	End

	If nOpcao == 0
			MsDocument( "SC7", SC7->( RecNo() ), 3 ) 
	Endif

	cDirUsr  := '\workflow\http\messenger\documentos\'
	cDirSrv  := '\dirdoc\co01\shared\'
	cDirFull := '\\SEU_IP\Protheus_Data' + cDirSrv
	aDirAux  := Directory(cDirSrv+'*.*')

	//Percorre os arquivos
	For nAtual := 1 To Len(aDirAux)
		//Pegando o nome do arquivo
		cNomArq := aDirAux[nAtual][1]

		//Copia o arquivo do Servidor para a mแquina do usuแrio
		__CopyFile(cDirSrv+cNomArq, cDirUsr+cNomArq)
	Next nAtual




	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณCriacao do processo do WorkFlow               ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	If nOpcao <> 0 .AND. oProcess == NIL
		PREPARE ENVIRONMENT EMPRESA '01' FILIAL '0101'
		oProcess := TWFProcess():New( "000001", "Pedido de Compras" )
		conout("LOGWF: Cria novo processo 1 : "+oProcess:fProcessID)
	End

	Do Case
		Case nOpcao == 0
		CONOUT("LOGWF: OPCAO 0")
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณVerifica qual o proximo usuario para liberacao              ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		cNum := SC7->C7_NUM



		lPerg := .F.
		lAprov1 := .F.
		lPoupUp := .F.

		DbSelectArea("SCR")
		SCR->(DbSetOrder(1))
		DbGoTop()
		If (SCR->(DbSeek(xFilial("SCR")+"PC"+PadR(cNum,TamSx3("CR_NUM")[1]))) .or. SCR->(DbSeek(xFilial("SCR")+"IP"+PadR(cNum,TamSx3("CR_NUM")[1]))))
			//While !lPerg
			While SCR->(!EOF()) .And. (SCR->CR_TIPO = "IP" .OR. SCR->CR_TIPO = "PC") .And. AllTrim(SCR->CR_NUM) = AllTrim(cNum)
				If !(SCR->CR_STATUS $ "01/02")
					Return
				EndIf

				mv_par01 := SCR->CR_APROV

				//If Posicione("SY1",3,xFilial("SY1")+SC7->C7_USER,"Y1_GRUPCOM") $ GetMv("MV_XGPAPRO")
				//lPoupUp := .T.
				//End

				If SCR->CR_NIVEL = "01" .And. SCR->CR_STATUS <> "03" .and. lPoupUp == .F.
					SPCIniciar(cNum,SCR->CR_APROV,SCR->CR_APROV)
				ElseIf SCR->CR_NIVEL = "01" .And. SCR->CR_STATUS $ "03/05"
					lAprov1 := .T.
				EndIf

				If SCR->CR_NIVEL = "02" .And. !(SCR->CR_STATUS $ "03/05") .And. lAprov1
					SPCIniciar(cNum,SCR->CR_APROV,SCR->CR_APROV)

				EndIf

				//EndDo
				If (SCR->CR_NIVEL = "01" .OR. SCR->CR_NIVEL = "1")
					DbSelectArea("SAK")
					DbSetOrder(1)
					If DbSeek(xFilial("SAK")+mv_par01)
						lPerg := .T.

						CONOUT("LOGWF: CR_NIVEL : "+SCR->CR_NIVEL)

						aSCRArea := SCR->(GetArea())
						SPCIniciar(cNum,mv_par01,mv_par01)
					EndIf

				EndIf

				SCR->(DbSkip())

			EndDo
		EndIf

		Case nOpcao == 1
		conout("LOGWF: nOpcao = 1")
		SPCRetorno( oProcess )
		oProcess:Free()
		Case nOpcao == 2
		conout("LOGWF: nOpcao = 2")
		SPCTimeOut( oProcess )
		oProcess:Free()
	EndCase

RETURN

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณSPCIniciarบAutor  ณThiago Rocco      บ Data ณ  26/07/2018   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณAtiva processo inicial do WorkFlow                          บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ COPPEL                                                      บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function SPCIniciar(cNum,cCodAprov,cAprovAnt)

	Local lUsaLink		:= .T.
	Local cDirWF		:= "workflow"

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณVariaveis utilizadas para envio via Link                      ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	//Local cServer   	:= SuperGetMV("MV_XLINKWF",.F.,"sistemas.hopelingerie.com.br:8088/confirmacao")  // --> Messenger
	Local cServer   	:= "187.94.53.11:11008"//"localhost:8084"//SuperGetMV("MV_XLINKWF",.F.,"10.45.247.168:8084/confirmacao")  // --> Messenger
	Local cPastaWf		:= "workflow"
	Local cID           := ""
	Local oProcess		:= nil
	Local cEmailCC      := 'thiagomt.rocco@gmail.com'//SuperGetMv("MV_XMAILWF",.F.,"")

	DbSelectArea("SC7")
	DbSetOrder(1)
	DbGotop()
	If !MsSeek(xFilial("SC7")+cNum)
		CONOUT("LOGWF: WF PC: Pedido de compra nao encontrado:"+cNum)
		Return
	EndIf

	If Right(cDirWF,1) == "\"
		cDirWF := SubStr(cDirWF,1,Len(cDirWF)-1)
	EndIf
	If Left(cDirWF,1) == "\"
		cDirWF := SubStr(cDirWF,2,Len(cDirWF)-1)
	EndIf

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณCriacao de uma nova tarefa e abertura do WTML                ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	oProcess := TWFProcess():New( "000001", "Pedido de Compras" )
	oProcess:NewTask( "Pedido", "\"+cDirWF+"\html\wfw120p1.html" )
	oProcess:cSubject := "Aprovacao de Pedido de Compra "+ cNum
	oProcess:bReturn := "U_WFW120P(1)"

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณAtualiza variaveis do modelo de WF              ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	U_WFATUVAR(@oProcess,"Aprova็ใo de Pedido de Compras",cAprovAnt)

	oProcess:fDesc := "Pedido de Compras No "+ cNum

	cIdProcess := oProcess:start("\workflow\http\messenger\confirmacao\")

	If lUsaLink
		cNomAprov := Posicione("SAK",1,xFilial("SAK")+cCodAprov,"AK_NOME") 

		oProcEmail := TWFProcess():New("000001","Pedido de Compras - Link")
		//oProcEmail:NewTask( "Pedido", "\workflow\html\WFPCLINK3.html" )
		oProcEmail:NewTask( "Pedido", "\workflow\WFLINKCOTA1.html" )
		oProcEmail:cTo		:= UsrRetMail(Posicione("SAK",1,xFilial("SAK")+cCodAprov,"AK_USER"))
		oProcEmail:cCC		:= cEmailCC
		//ProcEmail:cSubject := "Aprova็ใo do Pedido de Compra: "+ cNum + " - Aprovador(a): "+cNomAprov
		If SC7->C7_NENVIO == 0
			oProcEmail:cSubject := "Aprova็ใo do Pedido de Compra: "+ cNum + " - Aprovador(a): "+cNomAprov
		Else
			oProcEmail:cSubject := "Reenvio Nบ"+Alltrim(Str(SC7->C7_NENVIO))+"- Aprova็ใo do Pedido de Compra Alterado: "+ cNum + " - Aprovador(a): "+cNomAprov
		Endif

		CONOUT("LOGWF: WFID LINK:"+cIdProcess)
		oProcEmail:ohtml:valbyname("Aprovador",cNomAprov)
		oProcEmail:ohtml:valbyname("QtdeTit",SC7->C7_NUM)
		oProcEmail:ohtml:valbyname("DataSol",DtoC(SC7->C7_EMISSAO))
		oProcEmail:ohtml:valbyname("solicitante",UsrRetName(SC7->C7_USER))
		oProcEmail:ohtml:valbyname("cLink","http://"+cServer+"/http/messenger/confirmacao/"+AllTrim(cIdProcess)+".htm") //Link para resposta do Processo ///http/messenger/confirmacao
		oProcEmail:start()
		oProcEmail:Free()

		RecLock("SC7",.F.)
		SC7->C7_WFID := cIdProcess
		MsUnlock()

	EndIf

	oProcess:Free()

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณSPCRetornoบAutor  ณThiago Rocco      บ Data ณ  26/07/2018   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณTratamento do Retorno do WorkFlow de Pedido de compras      บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ COPPEL                                                     บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function SPCRetorno( oProcess )
	Private cNum 	  := ""
	Private cNivelSCR := ""
	Private cUsrLib   := ""
	Private cAprov    := ""
	Private nTotSCR   := 0
	Private lPedOK	  := .F.
	Private nRecSCR	  := 0
	Private lTemNivel := .F.
	Private cStatus   := ""
	Private nValLib   := 0
	Private cTipoLim  := ""
	Private cObs      := 0
	Private cCodApv   := 0

	cNum 	   := oProcess:oHtml:RetByName('C7_NUM')
	cSC7User   := oProcess:oHtml:RetByName('C7_USER')
	cNivelSCR  := oProcess:oHtml:RetByName('CR_NIVEL')
	cUsrLib    := oProcess:oHtml:RetByName('CR_USER')
	cAprov     := oProcess:oHtml:RetByName('APROVADOR')
	nTotSCR    := Val(StrTran(StrTran(oProcess:oHtml:RetByName('CR_TOTAL'),".",""),",","."))
	aItens     := oProcess:oHtml:RetByName('it.item')
	aProds     := oProcess:oHtml:RetByName('it.produto')
	cObserv    := oProcess:oHtml:RetByName('OBS')

	Conout("LOGWF: RETORNO - Pedido:"+cNum+" Nivel: "+cNivelSCR+" Aprovacao: "+Upper(oProcess:oHtml:RetByName("Aprovacao")))

	if Upper(oProcess:oHtml:RetByName("Aprovacao")) <> "S"
		Conout("LOGWF: ENTROU NO IF REPROVADO")
		dbSelectarea("SCR")
		dbSetorder(1)
		dbGoTop()
		dbSeek( xFilial("SCR") + "IP" + alltrim(cNum))
		While !EOF() .and. alltrim(SCR->CR_NUM) == alltrim(cNum)
			If Empty(SCR->CR_DATALIB)
				If AllTrim(SCR->CR_APROV) = AllTrim(cAprov)
					cStatus  := "04"
					cObs     := oProcess:oHtml:RetByName('OBS')
					RecLock("SCR",.f.)
					SCR->CR_DATALIB := dDataBase
					SCR->CR_STATUS  := cStatus  // Bloqueado
					SCR->CR_OBS     := cObs
					SCR->CR_USERLIB := cUsrLib
					SCR->CR_LIBAPRO := cAprov
					SCR->CR_VALLIB  := 0
					MsUnLock()
				EndIf
			Endif
			Dbskip()
		End
		SPCAprov(.F.) //Envia email de reprovacao
	Else
		Conout("LOGWF: ENTROU NO IF APROVADO")
		SC7->(DBSETORDER(1))
		SC7->(DBGoTop())
		If SC7->(dbseek(xFilial("SC7")+cNum)) .AND. SC7->C7_CONAPRO <> "L"
			Conout("LOGWF: ENTROU NO IF APROVADO 1 ")
			SCR->(dbsetorder(1))
			If SCR->(dbseek(xFilial("SCR")+"IP"+PadR(cNum,TamSx3("CR_NUM")[1])+cNivelSCR)) .OR. SCR->(dbseek(xFilial("SCR")+"PC"+PadR(cNum,TamSx3("CR_NUM")[1])+cNivelSCR))
				Conout("LOGWF: ENTROU NO IF APROVADO 2")
				While !EOF() .and. alltrim(SCR->CR_NUM) == alltrim(cNum) .And. AllTrim(SCR->CR_NIVEL) == AllTrim(cNivelSCR) 

					iF AllTrim(SCR->CR_APROV) == AllTrim(cAprov)
						If SCR->CR_STATUS $ "01/02"

							conout("LOGWF: ==>>WF APROVADO")

							If AllTrim(SCR->CR_APROV) = AllTrim(cAprov)
								cStatus  := "03"
								nValLib  := nTotSCR
								cTipoLim := Posicione("SAK",1,xFilial("SAK")+SCR->CR_APROV,"AK_TIPO")
								cCodApv  := cAprov

								SCR->(RecLock("SCR",.F.))
								SCR->CR_DATALIB := dDataBase
								SCR->CR_STATUS  := cStatus
								SCR->CR_USERLIB := cUsrLib
								SCR->CR_LIBAPRO := cCodApv
								SCR->CR_VALLIB  := nValLib
								SCR->CR_TIPOLIM := cTipoLim
								SCR->CR_OBS     := oProcess:oHtml:RetByName('OBS')
								SCR->(MsUnLock())
								nRecSCR	:= SCR->(Recno())
							EndIf
							lPedOK := .T.
						EndIf
					EndIf
					SCR->(DbSkip())
				EndDo
			EndIf
		EndIf
	EndIf

	oProcess:Finish()
	oProcess:Free()

	If lPedOK
		lCont := .T.

		DbSelectArea("SCR")
		SCR->(dbsetorder(1))
		If SCR->(dbseek(xFilial("SCR")+"IP"+PadR(cNum,TamSx3("CR_NUM")[1])))
			While !EOF() .and. alltrim(SCR->CR_NUM) == alltrim(cNum)
				If SCR->CR_STATUS <> "03"
					If SCR->CR_NIVEL $ "02" .And. !(SCR->CR_STATUS $ '04/05')
						Conout("LOGWF: Enviando para o 2บ nํvel.")
						SPCIniciar(cNum,SCR->CR_APROV,cAprov)
					EndIf
					lCont := .F.
				EndIf
				SCR->(DbSkip())
			EndDo
		EndIf


		If lCont
			SC7->(DBSETORDER(1))
			SC7->(DBGoTop())
			SC7->(dbseek(xFilial("SC7")+cNum))
			Conout("LOGWF: pedido ok aprovado")
			while !SC7->(EOF()) .and. SC7->C7_Num == cNum
				SC7->(RecLock("SC7",.F.))
				SC7->C7_ConaPro := "L"
				SC7->(MsUnLock())
				SC7->(DBSkip())
			enddo
			SPCAprov(.T.) //Envia email de Aprovacao
		EndIf
	EndIf

	//Conout("LOGWF: Executa WFW120P novamente. ")
	//U_WFW120P(0)

Return

Static Function SPCAprov(lAprovado)
	Local nx       := 0
	Local cEmailCC := "thiagomt.rocco@gmail.com,danielle.santana@aprilbrasil.com.br,celia.moraes@aprilbrasil.com.br"//SuperGetMv("MV_XMAILWF",.F.,"")

	CONOUT("LOGWF: Envia email de aprovacao: "+cNum)

	oProcAprov := TWFProcess():New("000001","Pedido de Compras - Aprovacao")
	If lAprovado
		oProcAprov:NewTask("Pedido","\workflow\html\wfw120p2.html")
		oProcAprov:cSubject := "Pedido de Compra Nบ "+cNum+" aprovado."
		CONOUT("LOGWF: Aprovado. Pedido: "+cNum)
	Else
		oProcAprov:NewTask("Pedido","\workflow\html\wfw120p3.html")
		oProcAprov:cSubject := "Pedido de Compra Nบ "+cNum+" reprovado."
		CONOUT("LOGWF: Reprovado. Pedido: "+cNum)
	EndIf
	oProcAprov:cTo		:= UsrRetMail(cSC7User)
	oProcAprov:cCC		:= cEmailCC
	oProcAprov:ohtml:valbyname("Num",cNum)
	oProcAprov:ohtml:valbyname("Emissao",DtoC(Posicione("SC7",1,xFilial("SC7")+cNum,"C7_EMISSAO")))
	oProcAprov:ohtml:valbyname("Req",UsrRetName(cSC7User))
	oProcAprov:ohtml:valbyname("Contrato",Posicione("SC7",1,xFilial("SC7")+cNum,"C7_CONTRA"))//Possui Contrato

	For nx := 1 to Len(aItens)
		AAdd((oProcAprov:oHTML:ValByName("it.item")),aItens[nx])
		AAdd((oProcAprov:oHTML:ValByName("it.produto")),aProds[nx])
	Next

	oProcAprov:ohtml:valbyname("Motivo",cObserv)

	oProcAprov:start()
	oProcAprov:Free()

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณWFAtuVar  บAutor  ณThiago Rocco      บ Data ณ  26/07/2018   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณAtualiza variaveis do modelo de WorkFlow                    บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ COPPEL                                                     บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
User Function WFAtuVar(oProcess,cTitulo,cAprovAnt)
	Local aArea		:= GetArea()
	Local aSC7Area	:= SC7->(GetArea())
	Local aSCRArea	:= SCR->(GetArea())
	Local nVlrTotal	:= 0
	Local nVlrFrete := 0
	Local nTotGeral := 0
	Local nTotDesc  := 0
	Local cNum 		:= SC7->C7_NUM
	Local cCotacao 	:= SC7->C7_NUMCOT
	Local cNumSC	:= SC7->C7_NUMSC
	Local cLogo		:= ""
	Local cFilterCR	:= SCR->(DbFilter())

	oProcess:oHTML:ValByName( "C7_NUM", SC7->C7_NUM )
	oProcess:oHTML:ValByName( "C7_EMISSAO", DtoC(SC7->C7_EMISSAO) )
	oProcess:oHTML:ValByName( "C7_USER", SC7->C7_USER)
	oProcess:oHTML:ValByName( "NOMEFIL", SM0->M0_FILIAL)

	dbSelectArea('SA2')
	dbSetOrder(1)
	dbSeek(xFilial('SA2')+SC7->C7_FORNECE+SC7->C7_LOJA)
	oProcess:oHTML:ValByName( "A2_NOME", SA2->A2_COD+"/"+SA2->A2_LOJA+" - "+SA2->A2_NOME )

	DbSelectArea("SE4")
	DbSetOrder(1)
	If MsSeek(xFilial("SE4")+SC7->C7_COND)
		oProcess:oHTML:ValByName( "E4_DESCRI", SE4->E4_CODIGO + " - " + SE4->E4_DESCRI )
	EndIf

	oProcess:oHTML:ValByName("aprovant",Posicione("SAK",1,xFilial("SAK")+cAprovAnt,"AK_NOME"))

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณDados do aprovador corrente             ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	oProcess:oHTML:ValByName( "APROVADOR"	, SCR->CR_APROV )
	oProcess:oHTML:ValByName( "CR_FILIAL"	, SCR->CR_FILIAL )
	oProcess:oHTML:ValByName( "CR_NUM" 		, SCR->CR_NUM )
	oProcess:oHTML:ValByName( "CR_NIVEL"	, SCR->CR_NIVEL )
	oProcess:oHTML:ValByName( "CR_USER"		, SCR->CR_USER )//Posicione("SAK",1,xFilial("SAK")+mv_par01,"AK_USER") )
	oProcess:oHTML:ValByName( "CR_TOTAL"	, SCR->CR_TOTAL )

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณTratamento dos itens                 ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	dbSelectArea('SB1')
	SB1->( dbSetOrder(1) )
	SB1->( DbGoTop() )

	dbSelectArea('SC7')
	SC7->( dbSetOrder(1) )
	SC7->( DbGoTop() )
	SC7->( dbSeek(xFilial('SC7')+cNum) )

	nVlrFrete := SC7->C7_VALFRE

	Do While SC7->(!Eof()) .AND. (Alltrim(SC7->C7_NUM) == Alltrim(cNum))

		nVlrTotal := nVlrTotal + SC7->C7_TOTAL
		nTotDesc  := nTotDesc + SC7->C7_VLDESC
		nTotGeral := nTotGeral + SC7->C7_TOTAL + SC7->C7_VALIPI - SC7->C7_VLDESC
		SB1->(dbSeek(xFilial('SB1')+SC7->C7_PRODUTO) )

		AAdd( (oProcess:oHTML:ValByName( "it.item" ))	,SC7->C7_ITEM )
		AAdd( (oProcess:oHTML:ValByName( "it.produto" ))	,SC7->C7_PRODUTO + " - "+SB1->B1_DESC )
		AAdd( (oProcess:oHTML:ValByName( "it.cc" ))	  ,SC7->C7_CC +" - "+Alltrim(Posicione("CTT",1,xFilial("CTT")+SC7->C7_CC,"CTT_DESC01"))  )
		AAdd( (oProcess:oHTML:ValByName( "it.quant" ))	,TRANSFORM( SC7->C7_QUANT ,'@E 99,999.99' ) )
		AAdd( (oProcess:oHTML:ValByName( "it.um" ))		,SB1->B1_UM )
		AAdd( (oProcess:oHTML:ValByName( "it.bdg" ))	,SC7->C7_OBSM)//Budget Alltrim(SC7->C7_BUDGET)+" - "+Alltrim(SC7->C7_PRJBDGT
		AAdd( (oProcess:oHTML:ValByName( "it.preco" ))	,TRANSFORM( SC7->C7_PRECO ,'@E 999,999,999.99' ) )
		AAdd( (oProcess:oHTML:ValByName( "it.vldesc" ))	,TRANSFORM( SC7->C7_VLDESC ,'@E 999,999,999.99' ) )
		AAdd( (oProcess:oHTML:ValByName( "it.total" ))	,TRANSFORM( SC7->C7_TOTAL ,'@E 999,999,999.99' ) )

		SC7->( dbSkip() )
	Enddo

	oProcess:oHTML:ValByName("vlrtotal",TRANSFORM(nVlrTotal,'@E 999,999,999.99'))
	oProcess:oHTML:ValByName("vlrfrete",TRANSFORM(nVlrFrete,'@E 999,999,999.99'))
	oProcess:oHTML:ValByName("vlrdesc",TRANSFORM(nTotDesc,'@E 999,999,999.99'))
	oProcess:oHTML:ValByName("totgeral",TRANSFORM(nTotGeral,'@E 999,999,999.99'))

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณDados das Cotacoes                                  ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	DbSelectArea("SC8")
	DbSetOrder(1)
	DbGoTop()
	If DbSeek(xFilial("SC8")+cCotacao)
		nTotCot  := 0
		cFornCot := ""
		While !EOF() .AND. xFilial("SC8")+cCotacao == SC8->(C8_FILIAL+C8_NUM)
			If cFornCot <> SC8->C8_FORNECE
				If !Empty(cFornCot)
					AAdd( (oProcess:oHTML:ValByName( "ct.cot" 	))	, "  " )
					AAdd( (oProcess:oHTML:ValByName( "ct.fornec"	))	, "  " )
					AAdd( (oProcess:oHTML:ValByName( "ct.produto"))	, "  " )
					AAdd( (oProcess:oHTML:ValByName( "ct.emissao"))	, "  " )
					AAdd( (oProcess:oHTML:ValByName( "ct.cond"	))	, "  " )
					AAdd( (oProcess:oHTML:ValByName( "ct.prev"	))	, "  " )
					AAdd( (oProcess:oHTML:ValByName( "ct.obs"	))	, "  " )
					AAdd( (oProcess:oHTML:ValByName( "ct.qtde" 	))	, "  " )
					AAdd( (oProcess:oHTML:ValByName( "ct.um"   	))	, "  " )
					AAdd( (oProcess:oHTML:ValByName( "ct.vlunit"	))	, "<b>Total:</b>" )
					AAdd( (oProcess:oHTML:ValByName( "ct.vlTot" 	))	, "<b>"+TRANSFORM(nTotCot,'@E 999,999,999.99' )+"</b>" )
				EndIf
				cFornCot := SC8->C8_FORNECE
				nTotCot  := 0
				AAdd( (oProcess:oHTML:ValByName( "ct.cot"     	)), SC8->C8_NUM )
				AAdd( (oProcess:oHTML:ValByName( "ct.fornec" 	)), Alltrim(Posicione("SA2",1,xFilial("SA2")+SC8->(C8_FORNECE+C8_LOJA),"A2_NREDUZ"))  )
			Else
				AAdd( (oProcess:oHTML:ValByName( "ct.cot"     	)), SC8->C8_NUM )
				AAdd( (oProcess:oHTML:ValByName( "ct.fornec" 	)), "  " )
			EndIf
			AAdd( (oProcess:oHTML:ValByName( "ct.produto"  	)), SC8->C8_PRODUTO+" - "+Alltrim(Posicione("SB1",1,xFilial("SB1")+SC8->C8_PRODUTO,"B1_DESC")) )
			AAdd( (oProcess:oHTML:ValByName( "ct.emissao" 	)), DtoC(SC8->C8_EMISSAO) )
			AAdd( (oProcess:oHTML:ValByName( "ct.cond"		)), Alltrim(Posicione("SE4",1,xFilial("SE4")+SC8->C8_COND,"E4_DESCRI"))  )
			AAdd( (oProcess:oHTML:ValByName( "ct.prev"		)), DtoC(SC8->C8_DATPRF)  )
			AAdd( (oProcess:oHTML:ValByName( "ct.obs"		)), SC8->C8_OBS  )
			AAdd( (oProcess:oHTML:ValByName( "ct.qtde" 		)), TRANSFORM( SC8->C8_QUANT,'@E 99,999.99' )  )
			AAdd( (oProcess:oHTML:ValByName( "ct.um" 		)), Alltrim(Posicione("SB1",1,xFilial("SB1")+SC8->C8_PRODUTO,"B1_UM")) )
			AAdd( (oProcess:oHTML:ValByName( "ct.vlunit"	)), TRANSFORM( SC8->C8_PRECO,'@E 999,999,999.99' )  )
			AAdd( (oProcess:oHTML:ValByName( "ct.vlTot" 	)), TRANSFORM( SC8->C8_TOTAL,'@E 999,999,999.99' )  )

			nTotCot += SC8->C8_TOTAL

			DbSelectArea("SC8")
			DbSkip()
		EndDo
		//AAdd( (oProcess:oHTML:ValByName( "tabela"		)), "<td bgcolor='#555555'><font size='1'><b><font face='Arial' color='#FFFFFF'>Cota็ใo</font></b></font></td>" )


		AAdd( (oProcess:oHTML:ValByName( "ct.cot" 	))	, "  " )
		AAdd( (oProcess:oHTML:ValByName( "ct.fornec"	))	, "  " )
		AAdd( (oProcess:oHTML:ValByName( "ct.produto"))	, "  " )
		AAdd( (oProcess:oHTML:ValByName( "ct.emissao"))	, "  " )
		AAdd( (oProcess:oHTML:ValByName( "ct.cond"	))	, "  " )
		AAdd( (oProcess:oHTML:ValByName( "ct.prev"	))	, "  " )
		AAdd( (oProcess:oHTML:ValByName( "ct.obs"	))	, "  " )
		AAdd( (oProcess:oHTML:ValByName( "ct.qtde" 	))	, "  " )
		AAdd( (oProcess:oHTML:ValByName( "ct.um"))	, "  " )
		AAdd( (oProcess:oHTML:ValByName( "ct.vlunit"	))	, "<b>Total:</b>" )
		AAdd( (oProcess:oHTML:ValByName( "ct.vlTot" 	))	, "<b>"+TRANSFORM(nTotCot,'@E 999,999,999.99' )+"</b>" )
	Else
		AAdd( (oProcess:oHTML:ValByName( "ct.cot" 	))	, "  " )
		AAdd( (oProcess:oHTML:ValByName( "ct.fornec"	))	, "Pedido sem Cota็ใo" )
		AAdd( (oProcess:oHTML:ValByName( "ct.produto"))	, "  " )
		AAdd( (oProcess:oHTML:ValByName( "ct.emissao"))	, "  " )
		AAdd( (oProcess:oHTML:ValByName( "ct.cond"	))	, "  " )
		AAdd( (oProcess:oHTML:ValByName( "ct.prev"	))	, "  " )
		AAdd( (oProcess:oHTML:ValByName( "ct.obs"	))	, "  " )
		AAdd( (oProcess:oHTML:ValByName( "ct.qtde" 	))	, "  " )
		AAdd( (oProcess:oHTML:ValByName( "ct.um"))	, "  " )
		AAdd( (oProcess:oHTML:ValByName( "ct.vlunit"	))	, "  " )
		AAdd( (oProcess:oHTML:ValByName( "ct.vlTot" 	))	, "  " )
	EndIf

	//Link Documento

	cQuery := " SELECT * FROM "+RetSQlName("AC9")+" AC9 "
	cQuery += " INNER JOIN "+RetSQlName("ACB")+" ACB ON ACB.ACB_CODOBJ = AC9.AC9_CODOBJ "
	cQuery += " WHERE AC9.D_E_L_E_T_<>'*' AND SUBSTRING(AC9_CODENT,5,6) = '"+cNum+"' AND ACB.D_E_L_E_T_<>'*' AND AC9_ENTIDA='SC7'"

	If Select("TRB2") <> 0
		dbSelectArea("TRB2")
		dbCloseArea()
	EndIf

	TCQuery cQuery New Alias "TRB2"

	While TRB2->(!Eof())

		AAdd( (oProcess:oHTML:ValByName( "ct1.documento"    	)), TRB2->ACB_CODOBJ )
		AAdd( (oProcess:oHTML:ValByName( "ct1.link"    	)), "http://187.94.53.11:11008/http/messenger/documentos/"+AllTrim(TRB2->ACB_OBJETO))

		TRB2->(Dbskip())
	EndDo

	SCR->(RestArea(aSCRArea))
	SC7->(RestArea(aSC7Area))
	RestArea(aArea)
Return

