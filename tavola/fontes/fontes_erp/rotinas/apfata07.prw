//Bibliotecas
#Include 'Protheus.ch'
#Include 'FWMVCDef.ch'
#INCLUDE "RWMAKE.CH"

user function APFATA07()

	Local aArea   := GetArea()
	Local oBrowse
	Private cTitulo := 'Cadastro Moedas Bacen'

	//Instânciando FWMBrowse - Somente com dicionário de dados
	oBrowse := FWMBrowse():New()

	//Setando a tabela de cadastro de Autor/Interprete
	oBrowse:SetAlias("SZA")

	//Setando a descrição da rotina
	oBrowse:SetDescription('Cadastro Moedas Bacen')

	//Ativa a Browse
	oBrowse:Activate()


Return Nil

/*---------------------------------------------------------------------*
| Func:  MenuDef                                                      |
| Autor: Edie Carlos                                                  |
| Data:  11/10/2017                                                   |
| Desc:  Criação do menu MVC                                          |
| Obs.:  /                                                            |
*---------------------------------------------------------------------*/

Static Function MenuDef()
	Local aRotina := {}

	//Adicionando opções
	ADD OPTION aRotina TITLE 'Visualizar' ACTION 'VIEWDEF.APFATA07' OPERATION 2   ACCESS 0 //OPERATION 1
	ADD OPTION aRotina TITLE 'Incluir'    ACTION 'VIEWDEF.APFATA07' OPERATION 3 ACCESS 0 //OPERATION 3
	ADD OPTION aRotina TITLE 'Alterar'    ACTION 'VIEWDEF.APFATA07' OPERATION 4 ACCESS 0 //OPERATION 4
	ADD OPTION aRotina TITLE 'Excluir'    ACTION 'VIEWDEF.APFATA07' OPERATION 5 ACCESS 0 //OPERATION 5

Return aRotina

/*---------------------------------------------------------------------*
| Func:  ModelDef                                                     |
| Autor: Edie Carlos                                                |
| Data:  11/10/2017                                                   |
| Desc:  Criação do modelo de dados MVC                               |
| Obs.:  /                                                            |
*---------------------------------------------------------------------*/

Static Function ModelDef()

	Local oModel := Nil
	Local oStSZA := FWFormStruct(1, "SZA")


	oModel := MPFormModel():New("APFATA7M",/*bPre*/, /*bPos*/,/*bCommit*/,/*bCancel*/)

	oModel:AddFields("FORMSZA",/*cOwner*/,oStSZA)
	oModel:SetPrimaryKey( {} )


	//Adicionando descrição ao modelo
	oModel:SetDescription("Modelo de Dados do Cadastro "+cTitulo)

	//Setando a descrição do formulário
	oModel:GetModel("FORMSZA"):SetDescription("Formulário do Cadastro "+cTitulo)
Return oModel

/*---------------------------------------------------------------------*
| Func:  ViewDef                                                      |
| Autor: Edie Carlos                                                  |
| Data:  10/10/2017                                                   |
| Desc:  Criação da visão MVC                                         |
| Obs.:  /                                                            |
*---------------------------------------------------------------------*/

Static Function ViewDef()

	//Criação da estrutura de dados utilizada na interface do cadastro de Autor
	Local oModel := FWLoadModel( 'APFATA07' )
	Local oStSZA := FWFormStruct(2, "SZA")  //pode se usar um terceiro parâmetro para filtrar os campos exibidos { |cCampo| cCampo $ 'SBM_NOME|SBM_DTAFAL|'}

	//Criando oView como nulo
	Local oView := Nil

	//Criando a view que será o retorno da função e setando o modelo da rotina
	oView := FWFormView():New()
	oView:SetModel(oModel)

	//Atribuindo formulários para interface
	oView:AddField("VIEW_SZA" , oStSZA, "FORMSZA")


	//Criando um container com nome tela com 100%
	oView:CreateHorizontalBox( 'SUPERIOR', 100 )
	//oView:CreateHorizontalBox( 'INFERIOR', 100 )

	//oView:CreateVerticalBox( 'INFERIOR_ESQUERDA', 100, 'INFERIOR' )
	//oView:CreateVerticalBox( 'INFERIOR_DIREITA', 100, 'INFERIOR' )

	// Relaciona o identificador (ID) da View com o "box" para exibição
	oView:SetOwnerView( 'VIEW_SZA', 'SUPERIOR' )


	//Colocando título do formulário
	oView:EnableTitleView('VIEW_SZA', 'Dados Moeda' ) 


	Return oView

