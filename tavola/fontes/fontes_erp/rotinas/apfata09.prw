#Include 'Protheus.ch'
#Include 'FWMVCDef.ch'
#INCLUDE "FWBROWSE.CH"
#Include "ApWizard.ch"
#INCLUDE "RWMAKE.CH"
#INCLUDE "TOPCONN.CH"

//#################
//# Programa      # APFATA09
//# Data          # 17/11/2017
//# Descrição     # Rotina Grupo de produto cosmos
//# Desenvolvedor # Edie Carlos
//# Empresa       # Totvs Nacoes Unidas
//# Linguagem     # eAdvpl     
//# Versão        # 12
//# Sistema       # Protheus
//# Módulo        # Financeiro
//# Tabelas       # "SZB"
//# Observação    #  
//#===============#
//# Atualizações  # 
//#===============#
//#################

user function APFATA09()

Local oBrowse	:= Nil
	Local cFilter	:= ""
	Local cQuery	:= ""
	Local cChave	:= ""
	Local aColumns	:= {}
	Local nX		:= 0
	Local aStru		:= SZB->(DBSTRUCT())
	Local bOk		:= {||}
	Local cTitulo	:= "Grupo de produto cosmos"


	cQuery := " SELECT DISTINCT ZB_GRUPO,ZB_DESCGRP "
	cQuery += " FROM "+ RetSqlName("SZB") +" SZB "
	cQuery += "WHERE SZB.ZB_FILIAL = '" + xFilial("SZB") + "' "
	cQuery += "AND SZB.D_E_L_E_T_ = ' ' "


	cArqTrab := CriaTrab(aStru, .T.) // Nome do arquivo temporario
	dbUseArea(.T., __LocalDriver, cArqTrab, cArqTrab, .F.)
	Processa({||SqlToTrb(cQuery, aStru, cArqTrab)})	// Cria arquivo temporario
	DbSetOrder(0) // Fica na ordem da query

	//Browse
	For nX := 1 To Len(aStru)
		If	aStru[nX][1] $ "ZB_GRUPO|ZB_DESCGRP"
			AAdd(aColumns,FWBrwColumn():New())
			aColumns[Len(aColumns)]:SetData( &("{||"+aStru[nX][1]+"}") )
			aColumns[Len(aColumns)]:SetTitle(RetTitle(aStru[nX][1]))
			aColumns[Len(aColumns)]:SetSize(aStru[nX][3])
			aColumns[Len(aColumns)]:SetDecimal(aStru[nX][4])
			aColumns[Len(aColumns)]:SetPicture(/*Iif( aStru[nX][1] != "FWA_STATUS", */PesqPict("SZB",aStru[nX][1])/*, PesqPict("FWA",aStru[nX][1]) )*/ )  
		EndIf
	Next nX

	oBrowse:= FWMBrowse():New()
	oBrowse:SetAlias(cArqTrab)
	oBrowse:SetDescription(cTitulo)
	oBrowse:SetColumns(aColumns)
	oBrowse:DisableDetails()
	oBrowse:Activate()

Return

//#################
//# Programa      # MenuDef
//# Data          # 17/11/2017
//# Descrição     # Rotina Menu MVC
//# Desenvolvedor # Edie Carlos
//# Empresa       # Totvs Nacoes Unidas
//# Linguagem     # eAdvpl     
//# Versão        # 12
//# Sistema       # Protheus
//# Módulo        # Financeiro
//# Tabelas       # "SZB"
//# Observação    #  
//#===============#
//# Atualizações  # 
//#===============#
//#################


Static Function MenuDef()

	Local aRotina := {}

	ADD OPTION aRotina TITLE 'Incluir'    ACTION 'VIEWDEF.APFATA09' OPERATION 3 ACCESS 0
	ADD OPTION aRotina TITLE 'Visualizar' ACTION 'VIEWDEF.APFATA09' OPERATION 2 ACCESS 0
	ADD OPTION aRotina TITLE 'Altera'     ACTION 'VIEWDEF.APFATA09' OPERATION 4 ACCESS 0
	ADD OPTION aRotina TITLE 'Excluir'    ACTION 'VIEWDEF.APFATA09' OPERATION 5 ACCESS 0

return aRotina   

	
Static Function ModelDef()

Local oStru1 	:= FWFormStruct( 1, "SZB", { |x| ALLTRIM(x) $ 'ZB_GRUPO,ZB_DESCGRP' } )
Local oStru2 	:= FWFormStruct( 1, "SZB", { |x| ALLTRIM(x) $ 'ZB_PRODUTO,ZB_DESCPR' }  )
Local oModel		:= Nil
Local aRelacSZB	:= {}

// Cria o objeto do Modelo de Dados
oModel := MPFormModel():New( 'APFATA9M', /*bPreValidacao*/, /*bPreValidacao*/ , /*bPosGrava*/ , /*bCancel*/ )

// Adiciona ao modelo uma estrutura de formulário de edição por campo
oModel:AddFields( 'SZEMASTER', /*cOwner*/, oStru1 )

// Adiciona ao modelo uma estrutura de formulário de edição por grid
oModel:AddGrid( 'SZBDETAIL'	, 'SZEMASTER'	, oStru2, /*bLinePre*/ , /*bLinePost*/, /*bPreVal*/, /*bPosVal*/, /*BLoad*/ )

//Relacionamento da tabela Etapa com Projeto
aAdd(aRelacSZB,{ 'ZB_FILIAL'	, 'xFilial( "SZB" )'	})
aAdd(aRelacSZB,{ 'ZB_GRUPO'	    , 'ZB_GRUPO' 		})


// Faz relaciomaneto entre os compomentes do model
oModel:SetPrimarykey({'ZB_FILIAL','ZB_GRUPO'})
oModel:SetRelation( 'SZBDETAIL', aRelacSZB , SZB->( IndexKey( 1 ) )  )

//Deixa o prenchimento das tabelas opcional
//oModel:GetModel( 'FNLDETAIL' ):SetOptional( .T. )

// Liga o controle de nao repeticao de linha
oModel:GetModel( 'SZBDETAIL' ):SetUniqueLine( { 'ZB_PRODUTO' } )

// Adiciona a descricao do Modelo de Dados
oModel:SetDescription( "Grupo Produto Cosmos") //'Alçadas de aprovação por operação'

// Adiciona a descricao do Componente do Modelo de Dados
oModel:GetModel( 'SZEMASTER' ):SetDescription("Dados do Grupo") // //'Alçadas de aprovação por operação'
oModel:GetModel( 'SZBDETAIL' ):SetDescription("Itens do Grupo") //'Itens da alçada de aprovação por operação'



Return oModel


Static Function ViewDef()

	// Cria a estrutura a ser usada na View
Local oStru1 := FWFormStruct( 2, 'SZB', { |x| ALLTRIM(x) $ 'ZB_GRUPO,ZB_DESCGRP' } )
Local oStru2 := FWFormStruct( 2, 'SZB', { |x| ALLTRIM(x) $ 'ZB_PRODUTO,ZB_DESCPR'} )
// Cria um objeto de Modelo de Dados baseado no ModelDef do fonte informado
Local oModel   := FWLoadModel( 'APFATA09' )
Local oView		:= Nil

// Cria o objeto de View
oView := FWFormView():New()

// Define qual o Modelo de dados será utilizado
oView:SetModel( oModel )

//Adiciona no nosso View um controle do tipo FormFields(antiga enchoice)
oView:AddField( 'VIEW_1', oStru1, 'SZEMASTER' )

//Adiciona no nosso View um controle do tipo FormGrid(antiga newgetdados)
oView:AddGrid(  'VIEW_2', oStru2, 'SZBDETAIL' )

// Criar "box" horizontal para receber algum elemento da view
oView:CreateHorizontalBox( 'SUPERIOR' , 20 )
oView:CreateHorizontalBox( 'INFERIOR' , 80 )

// Relaciona o ID da View com o "box" para exibicao
oView:SetOwnerView( 'VIEW_1', 'SUPERIOR'     	)
oView:SetOwnerView( 'VIEW_2', 'INFERIOR' 	)

// Liga a identificacao do componente
oView:EnableTitleView( 'VIEW_1' )
oView:EnableTitleView( 'VIEW_2' )

Return oView