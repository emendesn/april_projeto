//Bibliotecas
#Include 'Protheus.ch'
#Include 'FWMVCDef.ch'
#INCLUDE "RWMAKE.CH"
#Include 'Protheus.ch'
#Include 'FWEditPanel.ch'
//Variáveis Estáticas
Static cTitulo := "Cadastro cosmos"

/*/{Protheus.doc} APFAT05
Função para cadastro de direcionamento cosmo
@author Edie Carlos 
@since 11/10/2017
@version 1.0
@return Nil, Função não tem retorno
@example
u_zMVCMd1()
@obs Não se pode executar função MVC dentro do fórmulas
/*/

user function APFATA05()
	Local aArea   := GetArea()
	Local oBrowse

	//Instânciando FWMBrowse - Somente com dicionário de dados
	oBrowse := FWMBrowse():New()

	//Setando a tabela de cadastro de Autor/Interprete
	oBrowse:SetAlias("SZ9")

	//Setando a descrição da rotina
	oBrowse:SetDescription(cTitulo)

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
	ADD OPTION aRotina TITLE 'Visualizar' ACTION 'VIEWDEF.APFATA05' OPERATION 2   ACCESS 0 //OPERATION 1
	ADD OPTION aRotina TITLE 'Incluir'    ACTION 'VIEWDEF.APFATA05' OPERATION 3 ACCESS 0 //OPERATION 3
	ADD OPTION aRotina TITLE 'Alterar'    ACTION 'VIEWDEF.APFATA05' OPERATION 4 ACCESS 0 //OPERATION 4
	ADD OPTION aRotina TITLE 'Excluir'    ACTION 'VIEWDEF.APFATA05' OPERATION 5 ACCESS 0 //OPERATION 5

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
	Local oStSZ9 := FWFormStruct(1, "SZ9")


	oModel := MPFormModel():New("MPFATA05",/*bPre*/, /*bPos*/,/*bCommit*/,/*bCancel*/)

	oModel:AddFields("FORMSZ9",/*cOwner*/,oStSZ9)
	oModel:SetPrimaryKey( {} )


	//Adicionando descrição ao modelo
	oModel:SetDescription("Modelo de Dados do Cadastro "+cTitulo)

	//Setando a descrição do formulário
	oModel:GetModel("FORMSZ9"):SetDescription("Formulário do Cadastro "+cTitulo)
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
	Local oModel := FWLoadModel( 'APFATA05' )
	Local oStSZ9 := FWFormStruct(2, "SZ9")  //pode se usar um terceiro parâmetro para filtrar os campos exibidos { |cCampo| cCampo $ 'SBM_NOME|SBM_DTAFAL|'}

	//Criando oView como nulo
	Local oView := Nil

	//Criando a view que será o retorno da função e setando o modelo da rotina
	oView := FWFormView():New()
	oView:SetModel(oModel)

	//Atribuindo formulários para interface
	oView:AddField("VIEW_SZ9" , oStSZ9, "FORMSZ9")


	//Criando um container com nome tela com 100%
	oView:CreateHorizontalBox( 'SUPERIOR', 100 )
	//oView:CreateHorizontalBox( 'INFERIOR', 100 )

	//oView:CreateVerticalBox( 'INFERIOR_ESQUERDA', 100, 'INFERIOR' )
	//oView:CreateVerticalBox( 'INFERIOR_DIREITA', 100, 'INFERIOR' )

	// Relaciona o identificador (ID) da View com o "box" para exibição
	oView:SetOwnerView( 'VIEW_SZ9', 'SUPERIOR' )


	//Colocando título do formulário
	oView:EnableTitleView('VIEW_SZ9', 'Dados Modalidade' ) 


	Return oView


