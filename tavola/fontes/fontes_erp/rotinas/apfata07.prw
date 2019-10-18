//Bibliotecas
#Include 'Protheus.ch'
#Include 'FWMVCDef.ch'
#INCLUDE "RWMAKE.CH"

user function APFATA07()

	Local aArea   := GetArea()
	Local oBrowse
	Private cTitulo := 'Cadastro Moedas Bacen'

	//Inst�nciando FWMBrowse - Somente com dicion�rio de dados
	oBrowse := FWMBrowse():New()

	//Setando a tabela de cadastro de Autor/Interprete
	oBrowse:SetAlias("SZA")

	//Setando a descri��o da rotina
	oBrowse:SetDescription('Cadastro Moedas Bacen')

	//Ativa a Browse
	oBrowse:Activate()


Return Nil

/*---------------------------------------------------------------------*
| Func:  MenuDef                                                      |
| Autor: Edie Carlos                                                  |
| Data:  11/10/2017                                                   |
| Desc:  Cria��o do menu MVC                                          |
| Obs.:  /                                                            |
*---------------------------------------------------------------------*/

Static Function MenuDef()
	Local aRotina := {}

	//Adicionando op��es
	ADD OPTION aRotina TITLE 'Visualizar' ACTION 'VIEWDEF.APFATA07' OPERATION 2   ACCESS 0 //OPERATION 1
	ADD OPTION aRotina TITLE 'Incluir'    ACTION 'VIEWDEF.APFATA07' OPERATION 3 ACCESS 0 //OPERATION 3
	ADD OPTION aRotina TITLE 'Alterar'    ACTION 'VIEWDEF.APFATA07' OPERATION 4 ACCESS 0 //OPERATION 4
	ADD OPTION aRotina TITLE 'Excluir'    ACTION 'VIEWDEF.APFATA07' OPERATION 5 ACCESS 0 //OPERATION 5

Return aRotina

/*---------------------------------------------------------------------*
| Func:  ModelDef                                                     |
| Autor: Edie Carlos                                                |
| Data:  11/10/2017                                                   |
| Desc:  Cria��o do modelo de dados MVC                               |
| Obs.:  /                                                            |
*---------------------------------------------------------------------*/

Static Function ModelDef()

	Local oModel := Nil
	Local oStSZA := FWFormStruct(1, "SZA")


	oModel := MPFormModel():New("APFATA7M",/*bPre*/, /*bPos*/,/*bCommit*/,/*bCancel*/)

	oModel:AddFields("FORMSZA",/*cOwner*/,oStSZA)
	oModel:SetPrimaryKey( {} )


	//Adicionando descri��o ao modelo
	oModel:SetDescription("Modelo de Dados do Cadastro "+cTitulo)

	//Setando a descri��o do formul�rio
	oModel:GetModel("FORMSZA"):SetDescription("Formul�rio do Cadastro "+cTitulo)
Return oModel

/*---------------------------------------------------------------------*
| Func:  ViewDef                                                      |
| Autor: Edie Carlos                                                  |
| Data:  10/10/2017                                                   |
| Desc:  Cria��o da vis�o MVC                                         |
| Obs.:  /                                                            |
*---------------------------------------------------------------------*/

Static Function ViewDef()

	//Cria��o da estrutura de dados utilizada na interface do cadastro de Autor
	Local oModel := FWLoadModel( 'APFATA07' )
	Local oStSZA := FWFormStruct(2, "SZA")  //pode se usar um terceiro par�metro para filtrar os campos exibidos { |cCampo| cCampo $ 'SBM_NOME|SBM_DTAFAL|'}

	//Criando oView como nulo
	Local oView := Nil

	//Criando a view que ser� o retorno da fun��o e setando o modelo da rotina
	oView := FWFormView():New()
	oView:SetModel(oModel)

	//Atribuindo formul�rios para interface
	oView:AddField("VIEW_SZA" , oStSZA, "FORMSZA")


	//Criando um container com nome tela com 100%
	oView:CreateHorizontalBox( 'SUPERIOR', 100 )
	//oView:CreateHorizontalBox( 'INFERIOR', 100 )

	//oView:CreateVerticalBox( 'INFERIOR_ESQUERDA', 100, 'INFERIOR' )
	//oView:CreateVerticalBox( 'INFERIOR_DIREITA', 100, 'INFERIOR' )

	// Relaciona o identificador (ID) da View com o "box" para exibi��o
	oView:SetOwnerView( 'VIEW_SZA', 'SUPERIOR' )


	//Colocando t�tulo do formul�rio
	oView:EnableTitleView('VIEW_SZA', 'Dados Moeda' ) 


	Return oView

