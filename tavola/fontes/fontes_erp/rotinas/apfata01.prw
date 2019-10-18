//Bibliotecas
#Include 'Protheus.ch'
#Include 'FWMVCDef.ch'
#INCLUDE "RWMAKE.CH"
#Include 'Protheus.ch'
#Include 'FWEditPanel.ch'
//Variáveis Estáticas
Static cTitulo := "Cadastro de Natureza X Modalidade"
 
/*/{Protheus.doc} zMVCMd1
Função para cadastro de Natureza X Modadildade
@author Edie Carlos 
@since 11/10/2017
@version 1.0
@return Nil, Função não tem retorno
@example
u_zMVCMd1()
@obs Não se pode executar função MVC dentro do fórmulas
/*/
 
User Function APFATA01()
    Local aArea   := GetArea()
    Local oBrowse
     
    //Instânciando FWMBrowse - Somente com dicionário de dados
    oBrowse := FWMBrowse():New()
     
    //Setando a tabela de cadastro de Autor/Interprete
    oBrowse:SetAlias("SZ2")
 
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
    ADD OPTION aRotina TITLE 'Visualizar' ACTION 'VIEWDEF.APFATA01' OPERATION 2   ACCESS 0 //OPERATION 1
    ADD OPTION aRotina TITLE 'Incluir'    ACTION 'VIEWDEF.APFATA01' OPERATION 3 ACCESS 0 //OPERATION 3
    ADD OPTION aRotina TITLE 'Alterar'    ACTION 'VIEWDEF.APFATA01' OPERATION 4 ACCESS 0 //OPERATION 4
    ADD OPTION aRotina TITLE 'Excluir'    ACTION 'VIEWDEF.APFATA01' OPERATION 5 ACCESS 0 //OPERATION 5
 
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
    Local oStSZ2 := FWFormStruct(1, "SZ2")
    Local oStSZ5 := FWFormStruct(1, "SZ5")
     
   oModel := MPFormModel():New("MPFATA01",/*bPre*/, /*bPos*/,/*bCommit*/,/*bCancel*/)
   
   oModel:AddFields("FORMSZ2",/*cOwner*/,oStSZ2)
   oModel:addGrid('Grid','FORMSZ2',oStSZ5,,,,,)
     
    //Setando a chave primária da rotina
    oModel:SetPrimaryKey({ "Z2_FILIAL", "Z2_TPMOD", "Z2_TPFAT" } )
    oModel:SetRelation( 'Grid', { { 'Z5_FILIAL', 'xFilial( "SZ2" )' } , { "Z5_TPMOD" , "Z2_TPMOD" }, { "Z5_TPFAT" , "Z2_TPFAT" } }, SZ5->( IndexKey( 2 ) ) )
    
      
    //Adicionando descrição ao modelo
    oModel:SetDescription("Modelo de Dados do Cadastro "+cTitulo)
     
    //Setando a descrição do formulário
    oModel:GetModel("FORMSZ2"):SetDescription("Formulário do Cadastro "+cTitulo)
    
    oStSZ2:SetProperty('Z2_TES',MODEL_FIELD_VALID, {|| APFATA1B()}) 
      
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
    Local oModel := FWLoadModel( 'APFATA01' )
    Local oStSZ2 := FWFormStruct(2, "SZ2")  //pode se usar um terceiro parâmetro para filtrar os campos exibidos { |cCampo| cCampo $ 'SBM_NOME|SBM_DTAFAL|'}
    Local oStSZ5 := FWFormStruct(2, "SZ5") 
    //Criando oView como nulo
    Local oView := Nil
    
    // Remove campos da estrutura para nao aparecer na grid
    oStSZ5:RemoveField( 'Z5_TPMOD' )
    oStSZ5:RemoveField( 'Z5_TPFAT' )
 
    //Criando a view que será o retorno da função e setando o modelo da rotina
    oView := FWFormView():New()
    oView:SetModel(oModel)
     
    //Atribuindo formulários para interface
    oView:AddField("VIEW_SZ2" , oStSZ2, "FORMSZ2")
    oView:AddGrid( 'VIEW_GRID', oStSZ5,'Grid' )
     
    //Criando um container com nome tela com 100%
    oView:CreateHorizontalBox( 'SUPERIOR', 30 )
	oView:CreateHorizontalBox( 'INFERIOR', 70 )
	
	oView:CreateVerticalBox( 'INFERIOR_ESQUERDA', 40, 'INFERIOR' )
	oView:CreateVerticalBox( 'INFERIOR_DIREITA', 60, 'INFERIOR' )
    
    // Relaciona o identificador (ID) da View com o "box" para exibição
    oView:SetOwnerView( 'VIEW_SZ2', 'SUPERIOR' )
	oView:SetOwnerView( 'VIEW_GRID', 'INFERIOR' )
	     
    //Colocando título do formulário
    oView:EnableTitleView('VIEW_SZ2', 'Dados Modalidade' ) 
     
        
Return oView


//#################
//# Programa      # APFATA1B
//# Data          #   
//# Descrição     # Validação Tes 
//# Desenvolvedor # Edie Carlos 
//# Empresa       # Totvs Nacoes Unidas
//# Linguagem     # eAdvpl     
//# Versão        # 12
//# Sistema       # Protheus
//# Módulo        # Faturamento
//# Tabelas       # "SF4"
//# Observação    # Usado para excluir os titulos de geração manual 
//#===============#
//# Atualizações  # 
//#===============#
//#################
Static Function APFATA1B()
Local oMdlTd  	:= FwModelActive()
Local oMd	    := oMdlTd:GetModel('FORMSZ2')
Local lRet      := .T.

dbSelectArea("SF4")
dbSetOrder(1)

	IF SF4->(dbSeek(xFilial("SF4")+oMd:GetValue("Z2_TES")))
		IF SF4->F4_TIPO <> 'S'
			Help( ,, 'HELP',, 'Informar somente tes de saida!!', 1, 0)
			lRet := .F.
		ENDIF
		
		IF SF4->F4_DUPLIC <> 'N'
		Help( ,, 'HELP',, 'Informar somente tes que não gere financeiro!!', 1, 0)
		lRet := .F.
		ENDIF	
	
	ELSE
		Help( ,, 'HELP',, 'Tes não encontrada no cadastro!!', 1, 0)  
		lRet := .F.  
	ENDIF

Return(lRet)