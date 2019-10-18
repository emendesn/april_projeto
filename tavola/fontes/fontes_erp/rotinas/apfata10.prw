#include 'protheus.ch'
#include 'parmtype.ch'

//#################
//# Programa      # APFATA10
//# Data          # 17/11/2017
//# Descrição     # Rotina log de processamento WS
//# Desenvolvedor # Edie Carlos
//# Empresa       # Totvs Nacoes Unidas
//# Linguagem     # eAdvpl     
//# Versão        # 12
//# Sistema       # Protheus
//# Módulo        # Faturamento
//# Tabelas       # "SZ6"
//# Observação    #  
//#===============#
//# Atualizações  # 
//#===============#
//#################

user function APFATA10()
oBrw := FwMarkBrowse():New()
oBrw:SetAlias("SZ6")
oBrw:SetMenudef("APFATA10")
oBrw:SetDescription("Log de Erros") // "Equipamentos não separados"

oBrw:Activate()

return

Static Function Menudef()

Local aMenu := {}

aAdd(aMenu,{ 'Pesquisar' , 'PesqBrw'           , 0 , 1, 0, .T. } ) // 'Pesquisar'
aAdd(aMenu,{ 'Visualizar' , 'VIEWDEF.APFATA10' , 0 , 2, 0, .F. } ) // 'Visualizar'

//ADD OPTION aMenu TITLE 'Pesquisar'    ACTION 'PesqBrw' OPERATION 1 ACCESS 0
//ADD OPTION aMenu TITLE 'Visualizar'   ACTION 'VIEWDEF.APFATA10' OPERATION 2 ACCESS 0


Return aMenu 

Static Function ModelDef()

Local oStru1 	:= FWFormStruct( 1, "SZ6")
Local oModel		:= Nil
Local aRelacSZB	:= {}

// Cria o objeto do Modelo de Dados
oModel := MPFormModel():New( 'FAT10M', /*bPreValidacao*/, /*bPreValidacao*/ , /*bPosGrava*/ , /*bCancel*/ )

// Adiciona ao modelo uma estrutura de formulário de edição por campo
oModel:AddFields( 'SZEMASTER', /*cOwner*/, oStru1 )
oModel:SetPrimaryKey( {} )


// Adiciona a descricao do Modelo de Dados
oModel:SetDescription( "Log Integração") //'Alçadas de aprovação por operação'

// Adiciona a descricao do Componente do Modelo de Dados
oModel:GetModel( 'SZEMASTER' ):SetDescription("Dados do Grupo") // //'Alçadas de aprovação por operação'

Return oModel


Static Function ViewDef()

	// Cria a estrutura a ser usada na View
Local oStru1 := FWFormStruct( 2, 'SZ6' )

// Cria um objeto de Modelo de Dados baseado no ModelDef do fonte informado
Local oModel   := FWLoadModel( 'APFATA10' )
Local oView		:= Nil

// Cria o objeto de View
oView := FWFormView():New()

// Define qual o Modelo de dados será utilizado
oView:SetModel( oModel )

//Adiciona no nosso View um controle do tipo FormFields(antiga enchoice)
oView:AddField( 'VIEW_1', oStru1, 'SZEMASTER' )

// Criar "box" horizontal para receber algum elemento da view
oView:CreateHorizontalBox( 'SUPERIOR' ,100 )


// Relaciona o ID da View com o "box" para exibicao
oView:SetOwnerView( 'VIEW_1', 'SUPERIOR'     	)


// Liga a identificacao do componente
oView:EnableTitleView( 'VIEW_1' )


Return oView