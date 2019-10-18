#include "protheus.ch"
#include "TbiConn.ch"
#include "TbiCode.ch"
#include "topconn.ch"
#Include 'ApWebEx.ch'
#include "prtopdef.ch"
#include "fwmvcdef.ch"


User Function CosmosI() 

	Local aArea   := GetArea()
	Local oBrowse
	Local cTitulo := "Fornecedores Internacionais"
	Private aRotina := Menudef()

	//Instโnciando FWMBrowse - Somente com dicionแrio de dados
	oBrowse := FWMBrowse():New()

	//Setando a tabela de cadastro de Autor/Interprete
	oBrowse:SetAlias("SA2")

	//Setando a descri็ใo da rotina
	oBrowse:SetDescription(cTitulo)
	//oBrowse:SetFilterDefault("A2_TIPO ='X'") //Indica o filtro padrใo do Browse
	//Ativa a Browse
	oBrowse:Activate()

	RestArea(aArea)
Return Nil

Static Function MenuDef()
	Local aRot := {}

	ADD OPTION aRot TITLE 'Visualizar' ACTION 'A020Visual' OPERATION MODEL_OPERATION_VIEW   ACCESS 0 //OPERATION 1
	ADD OPTION aRot TITLE 'Mostrar Contas a Pagar' ACTION 'U_APFINCO()' OPERATION MODEL_OPERATION_VIEW   ACCESS 0 //OPERATION 1
Return aRot


User Function APFINCO()


	Local aRet2 := {}
	Local aParamBox := {}
	Local aCombo := {"AXA","QBE","ZURICH","CAIXA","APRIL USA",""}
	Local i := 0
	Local cFiltro := ""

	Private cCadastro := "Processamento Integra็ใo Cosmos"

	aAdd(aParamBox,{2,"Tipo de Processamento",1,aCombo,100,"",.F.})


	If ParamBox(aParamBox,"Escolha as Op็๕es...",@aRet2)

		If aRet2[1] == 1
			IntCosmo3("AXA Seguros S.A.")
		ElseIf aRet2[1] == 2
			IntCosmo3("CAIXA SEGURADORA S.A.")
		ElseIf aRet2[1] == 3
			IntCosmo3("QBE BRASIL SEGUROS")
		Else 
			IntCosmo3("FIDELIA ASSISTANCE")
		EndIf
	Endif

	Return

	Static Function IntCosmo3()


	Private oMark
	Private aRotina := MMdef()

	//Criando o MarkBrow
	oMark := FWMarkBrowse():New()
	oMark:SetAlias('SE2')

	//Setando semแforo, descri็ใo e campo de mark
	//oMark:SetSemaphore(.T.)
	oMark:SetDescription('Sele็ใo de Titulos para Cota็ใo')
	oMark:SetFieldMark( 'E2_OKWF' )
	oMark:oBrowse:SetFilterDefault("E2_FORNECE='"+SA2->A2_COD+"'")
	oMark:oBrowse:Setfocus()

	//Ativando a janela
	oMark:Activate()
Return NIL

Static Function MMDef()
	Local aRotina := {}

	//Cria็ใo das op็๕es
	ADD OPTION aRotina TITLE 'Processar'  ACTION 'zMarkProc6()'     OPERATION 2 ACCESS 0
Return aRotina

Static Function zMarkProc6()
	Local aArea       	:= GetArea()
	Local cMarca      	:= oMark:Mark()
	Local lInverte    	:= oMark:IsInvert()
	Local nCt         	:= 0
	Local aDados      	:= {}
	Local cId         	:= ""
	Local aParamBox   	:= {}
	Private aRet        := {}
	Private nTotal      := 0
	Private nX          := 0
	Private cFornece 	:= ""
	Private cLoja    	:=""
	Private nControl 	:= GetMV("MV_FCONTRO")
	Private cCadastro 	:= "Preencher Link com Documentos Cota็ใo"

	aAdd(aParamBox,{1,"Preencher Link",Space(200),"","","","",0,.T.}) // Tipo caractere
	aAdd(aParamBox,{1,"Fornecedor do Cambio",Space(6),"","","SA2","",0,.T.}) 

	If ParamBox(aParamBox,"Link com Documentos",@aRet)

		//Percorrendo os registros da SE2
		SE2->(DbGoTop())
		While !SE2->(EoF())
			//Caso esteja marcado, aumenta o contador
			If oMark:IsMark(cMarca)
				//Efetuo a soma para envio no Workflow.
				nTotal+=SE2->E2_SALDO
				cFornece := SE2->E2_FORNECE
				cLoja    := SE2->E2_LOJA
				RecLock('SE2', .F.)
				SE2->E2_XID := nControl
				SE2->(MsUnlock())
				nX++		
			EndIf

			//Pulando registro
			SE2->(DbSkip())
		EndDo

		//Pego o resultado do Envio do Workflow
		lResult := U_WF(,,nTotal,nX,nControl,cFornece,cLoja)

		While !SE2->(EoF())
			//Caso esteja marcado, aumenta o contador
			If oMark:IsMark(cMarca)
				If lResult
					//Limpando a marca
					RecLock('SE2', .F.)
					SE2->E2_OKWF := ''
					SE2->E2_STATWF := 'S'
					SE2->(MsUnlock())

					//ATUALIZAR O PARAMETRO
					PUTMV("MV_FCONTRO", nControl+=1)
				Else

					//Limpando a marca
					RecLock('SE2', .F.)
					SE2->E2_OKWF := ''
					SE2->E2_STATWF := 'E'
					SE2->(MsUnlock())
				EndIf
			EndIf

			//Pulando registro
			SE2->(DbSkip())
		EndDo
		MsgInfo('E-mail enviado com sucesso', "Aten็ใo")
	EndIf
	//Mostrando a mensagem de registros marcados
	//	MsgInfo('Foram marcados <b>' + cValToChar( nCt ) + ' artistas</b>.', "Aten็ใo")

	//Restaurando แrea armazenada
	RestArea(aArea)
Return NIL
/*

FUNวรO PARA ENVIO DO WORKFLOW

*/

User Function WF(nOpcao,oProcess,nTotal,nX,nControl)

	Local lRet := .T.

	CONOUT("LOGWF: ***ENTRADA DO WF - COTAวรO")

	If ValType(nOpcao) = "A"
		nOpcao := nOpcao[1]
	Endif

	If nOpcao == NIL
		nOpcao := 0
	End

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณCriacao do processo do WorkFlow               ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	If nOpcao <> 0 .AND. oProcess == NIL
		CONOUT("LOGWF: OPCAO 1")
		PREPARE ENVIRONMENT EMPRESA '01' FILIAL '01' 
		oProcess := TWFProcess():New( "000001", "Pedido de Compras" )
		conout("LOGWF: Cria novo processo 1 : "+oProcess:fProcessID)
	End

	Do Case
		Case nOpcao == 0                                                                                                             
		CONOUT("LOGWF: OPCAO 0")
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณVerifica qual o proximo usuario para liberacao              ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		CotIniciar()

		Case nOpcao == 1 
		conout("LOGWF: nOpcao = 1")
		SPCRetorno( oProcess )
		oProcess:Free()
		Case nOpcao == 2       
		conout("LOGWF: nOpcao = 2")
		SPCTimeOut( oProcess )
		oProcess:Free()
	EndCase

Return

Static Function CotIniciar()

	Local lUsaLink		:= .T.
	Local cDirWF		:= "workflow"

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณVariaveis utilizadas para envio via Link                      ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	//Local cServer   	:= SuperGetMV("MV_XLINKWF",.F.,"sistemas.hopelingerie.com.br:8088/confirmacao")  // --> Messenger
	Local cServer   	:= "187.94.53.11:11008"//SuperGetMV("MV_XLINKWF",.F.,"10.45.247.168:8084/confirmacao")  // --> Messenger
	Local cPastaWf		:= "workflow"
	Local cID           := ""
	Local oProcess		:= nil  
	Local cEmailCC      := "vanessa.braz@aprilbrasil.com.br"

	If Right(cDirWF,1) == "\"
		cDirWF := SubStr(cDirWF,1,Len(cDirWF)-1)
	EndIf
	If Left(cDirWF,1) == "\"
		cDirWF := SubStr(cDirWF,2,Len(cDirWF)-1)
	EndIf

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณCriacao de uma nova tarefa e abertura do WTML                ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	oProcess := TWFProcess():New( "000001", "Cota็ใo de Moedas" )
	oProcess:NewTask( "Pedido", "\"+cDirWF+"\html\cotmoeda.html" )
	oProcess:cSubject := "April Turismo - Cota็ใo de Cโmbio "+ SA2->A2_NOME
	oProcess:bReturn := "U_WF(1)"

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณAtualiza variaveis do modelo de WF              ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	U_WFCOTAT(@oProcess,"Aprova็ใo de Pedido de Compras",nX,nControl)    

	oProcess:fDesc := "April Turismo - Cota็ใo de Cโmbio "+ SA2->A2_NOME//"Pedido de Compras No "+ cNum                                                                                           

	cIdProcess := oProcess:start("\workflow\http\messenger\confirmacao\")

	If lUsaLink

		oProcEmail := TWFProcess():New("000001","Pedido de Compras - Link") 
		//oProcEmail:NewTask( "Pedido", "\workflow\html\WFPCLINK3.html" )	
		oProcEmail:NewTask( "Pedido", "\workflow\WFLINKCOTA.html" )	
		oProcEmail:cTo		:= SuperGetMv("MV_XMAILWF",.F.,"")//UsrRetMail(Posicione("SAK",1,xFilial("SAK")+cCodAprov,"AK_USER"))
		oProcEmail:cCC		:= cEmailCC
		oProcEmail:cSubject := "April Turismo - Cota็ใo de Cโmbio "+ SA2->A2_NOME

		CONOUT("LOGWF: WFID LINK:"+cIdProcess)
		oProcEmail:ohtml:valbyname("QtdeTit",nX)
		oProcEmail:ohtml:valbyname("DataSol",DtoC(Date()))
		oProcEmail:ohtml:valbyname("solicitante",cUserName)    
		oProcEmail:ohtml:valbyname("cLink","http://"+cServer+"/http/messenger/confirmacao/"+AllTrim(cIdProcess)+".htm")//Link para resposta do Processo  	
		oProcEmail:start()	
		oProcEmail:Free() 


	EndIf

	oProcess:Free()

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณWFAtuVar  บAutor  ณThiago Rocco     บ Data ณ  26/07/2018   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณAtualiza variaveis do modelo de WorkFlow                    บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ APRIL TURISMO                                                     บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
User Function WFCOTAT(oProcess,cTitulo,nX,nControl)
	Local aArea		:= GetArea()


	oProcess:oHTML:ValByName( "FORNECEDOR" 	,Posicione("SA2",1,xFilial("SA2")+cFornece+cLoja,"A2_NOME"))
	oProcess:oHTML:ValByName( "BENEFICIARIO" 	,Posicione("SA2",1,xFilial("SA2")+cFornece+cLoja,"A2_XBENEF"))  
	oProcess:oHTML:ValByName( "ENDERECO" 	,Posicione("SA2",1,xFilial("SA2")+cFornece+cLoja,"A2_END"))
	oProcess:oHTML:ValByName( "BANCO" 	,Posicione("SA2",1,xFilial("SA2")+cFornece+cLoja,"A2_XBANCO"))
	oProcess:oHTML:ValByName( "CONTA" 	,Posicione("SA2",1,xFilial("SA2")+cFornece+cLoja,"A2_END"))
	oProcess:oHTML:ValByName( "ABA" 	,Posicione("SA2",1,xFilial("SA2")+cFornece+cLoja,"A2_XIBAN"))
	oProcess:oHTML:ValByName( "SWIFT" 	,Posicione("SA2",1,xFilial("SA2")+cFornece+cLoja,"A2_XSWIFT"))
	oProcess:oHTML:ValByName( "TAXID" 	,Posicione("SA2",1,xFilial("SA2")+cFornece+cLoja,"A2_NIFEX"))
	oProcess:oHTML:ValByName( "EMAIL" 	,Posicione("SA2",1,xFilial("SA2")+cFornece+cLoja,"A2_EMAIL"))
	oProcess:oHTML:ValByName( "TELEFONE" 	,Posicione("SA2",1,xFilial("SA2")+cFornece+cLoja,"A2_TEL"))

	oProcess:oHTML:ValByName( "MOEDA" 	,Posicione("SA2",1,xFilial("SA2")+cFornece+cLoja,"A2_XMOEDA"))
	oProcess:oHTML:ValByName( "CONTROL"	, nControl )
	oProcess:oHTML:ValByName( "QUANT"	, nX )
	oProcess:oHTML:ValByName( "LINK2", Alltrim(aRet[1]) )
	oProcess:oHTML:ValByName( "FORNECE", Alltrim(aRet[2]) )
	oProcess:oHTML:ValByName( "TOTAL" 	,TRANSFORM( nTotal ,'@E 999,999,999.99') ) 

	RestArea(aArea)
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณSPCRetornoบ1Autor  ณThiago Rocco       Data ณ  26/07/2018   บฑฑ
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

	Local aArray       :={}
	Private nControl   := 0
	Private nTaxas	   := 0
	Private nIOF 	   := 0
	Private cCtrCamb := ""
	PRIVATE lMsErroAuto := .F.

	nIOF      := Val(StrTran(StrTran(oProcess:oHtml:RetByName('IOF'),".",""),",","."))
	cObserv   := oProcess:oHtml:RetByName('CONTROL')
	nQuant    := Val(oProcess:oHtml:RetByName('QUANT'))

	cQuery := " SELECT * FROM "+RetSQLName("SE2") "
	cQuery += " WHERE E2_XID = '"+oProcess:oHtml:RetByName('CONTROL')+"' AND D_E_L_E_T_<>'*' "

	//Verificando se a query estแ aberta na mem๓ria 
	If Select('TRB') <> 0 
		TRB->(DbCloseArea()) 
	EndIf 

	TCQUERY cQuery NEW ALIAS 'TRB'

	/*
	F๓rmula do Valor Total:
	VALOR TOTAL * NOVO CAMBIO = X
	VALOR TOTAL * IOF = Z	
	TAXAS ADMINISTRATIVAS / QUANTIDADE DE TITULOS = Y
	Y+X+Z
	*/


	While !TRB->(EOF()) 
		//Efetuo o Update pelo XID e aloco os valores corretamente.
		cSQL := " UPDATE "+RetSQLName("SE2")+ " SET E2_XIOF="+AlltrIM(STR(nIOF))+", "
		cSQL += " E2_TXADM  ="+Str(Val(StrTran(StrTran(oProcess:oHtml:RetByName('TAX'),".",""),",","."))/Val(oProcess:oHtml:RetByName('QUANT')))+","
		cSQL += " E2_XTAXAS="+Str(Val(StrTran(StrTran(oProcess:oHtml:RetByName('TXCAMB'),".",""),",",".")))+","
		cSQL += " E2_XVLIOF ="+Str(Round(((E2_VALOR* Val(StrTran(StrTran(oProcess:oHtml:RetByName('TXCAMB'),".",""),",",".")))*nIOF)/100,2))+","
		cSQL += " E2_CCONTR ='"+Upper(oProcess:oHtml:RetByName('CTRCAMB'))+"' "
		cSQL += " WHERE E2_XID = '"+oProcess:oHtml:RetByName('CONTROL')+"' AND D_E_L_E_T_<>'*' "

		If TCSQLExec(cSQL) < 0
			Conout( "TCSQLError() " + TCSQLError() )
			Return( Nil )

			//Efetuar a baixa

			//Criar Titulo da Advanced Corretora	

		Else

			PUTMV("MV_FCONTRO", Val(oProcess:oHtml:RetByName('CONTROL'))+1)
			//Mandar e-mail para a Vanessa com o Retorno da Cota็ใo se possivel.

		Endif

		TRB->(Dbskip())
	End

	Conout("LOGWF: RETORNO - Pedido:"+cObserv)

	oProcess:Finish()
	oProcess:Free()

Return

