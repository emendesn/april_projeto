//Bibliotecas
#Include 'Protheus.ch'
#Include 'FWMVCDef.ch'
#INCLUDE "RWMAKE.CH"
 
//Vari�veis Est�ticas
Static cTitulo := "Cadastro de Natureza X Modalidade"
 
/*/{Protheus.doc} zMVCMd1
Fun��o para cadastro de Natureza X Modadildade
@author Edie Carlos 
@since 11/10/2017
@version 1.0
@return Nil, Fun��o n�o tem retorno
@example
u_zMVCMd1()
@obs N�o se pode executar fun��o MVC dentro do f�rmulas
/*/
 
User Function APFATA01()
    Local aArea   := GetArea()
    Local oBrowse
     
    //Inst�nciando FWMBrowse - Somente com dicion�rio de dados
    oBrowse := FWMBrowse():New()
     
    //Setando a tabela de cadastro de Autor/Interprete
    oBrowse:SetAlias("SZ2")
 
    //Setando a descri��o da rotina
    oBrowse:SetDescription(cTitulo)
    
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
    ADD OPTION aRotina TITLE 'Visualizar' ACTION 'VIEWDEF.APFATA01' OPERATION 2   ACCESS 0 //OPERATION 1
    ADD OPTION aRotina TITLE 'Incluir'    ACTION 'VIEWDEF.APFATA01' OPERATION 3 ACCESS 0 //OPERATION 3
    ADD OPTION aRotina TITLE 'Alterar'    ACTION 'VIEWDEF.APFATA01' OPERATION 4 ACCESS 0 //OPERATION 4
    ADD OPTION aRotina TITLE 'Excluir'    ACTION 'VIEWDEF.APFATA01' OPERATION 5 ACCESS 0 //OPERATION 5
 
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
    Local oStSZ2 := FWFormStruct(1, "SZ2")
    Local oStSZ5 := FWFormStruct(1, "SZ5")
     
   oModel := MPFormModel():New("MPFATA01",/*bPre*/, /*bPos*/,/*bCommit*/,/*bCancel*/)
   
   oModel:AddFields("FORMSZ2",/*cOwner*/,oStSZ2)
   oModel:addGrid('Grid','FORMSZ2',oStSZ5,,,,,)
     
    //Setando a chave prim�ria da rotina
    oModel:SetPrimaryKey({})
     
    //Adicionando descri��o ao modelo
    oModel:SetDescription("Modelo de Dados do Cadastro "+cTitulo)
     
    //Setando a descri��o do formul�rio
    oModel:GetModel("FORMSZ2"):SetDescription("Formul�rio do Cadastro "+cTitulo)
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
    Local oModel := FWLoadModel( 'MPFATA01' )
    Local oStSZ2 := FWFormStruct(2, "SZ2")  //pode se usar um terceiro par�metro para filtrar os campos exibidos { |cCampo| cCampo $ 'SBM_NOME|SBM_DTAFAL|'}
    Local oStSZ5 := FWFormStruct(2, "SZ5") 
    //Criando oView como nulo
    Local oView := Nil
 
    //Criando a view que ser� o retorno da fun��o e setando o modelo da rotina
    oView := FWFormView():New()
    oView:SetModel(oModel)
     
    //Atribuindo formul�rios para interface
    oView:AddField("VIEW_SZ2" , oStSZ2, "FORMSZ2")
    oView:AddGrid( 'VIEW_GRID', oStSZ5,'Grid' )
     
    //Criando um container com nome tela com 100%
    oView:CreateHorizontalBox( 'SUPERIOR', 30 )
	oView:CreateHorizontalBox( 'INFERIOR', 70 )
	
	oView:CreateVerticalBox( 'INFERIOR_ESQUERDA', 40, 'INFERIOR' )
	oView:CreateVerticalBox( 'INFERIOR_DIREITA', 60, 'INFERIOR' )
    
    // Relaciona o identificador (ID) da View com o "box" para exibi��o
    oView:SetOwnerView( 'VIEW_SZ2', 'SUPERIOR' )
	oView:SetOwnerView( 'VIEW_GRID', 'INFERIOR' )
	     
    //Colocando t�tulo do formul�rio
    oView:EnableTitleView('VIEW_SZ2', 'Dados Modalidade' ) 
     
        
Return oView
