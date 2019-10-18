//Bibliotecas
#Include 'Protheus.ch'
#Include 'FWMVCDef.ch'
#INCLUDE "RWMAKE.CH"
#Include 'Protheus.ch'
#Include 'FWEditPanel.ch'
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
    oModel:SetPrimaryKey({ "Z2_FILIAL", "Z2_TPMOD", "Z2_TPFAT" } )
    oModel:SetRelation( 'Grid', { { 'Z5_FILIAL', 'xFilial( "SZ2" )' } , { "Z5_TPMOD" , "Z2_TPMOD" }, { "Z5_TPFAT" , "Z2_TPFAT" } }, SZ5->( IndexKey( 2 ) ) )
    
      
    //Adicionando descri��o ao modelo
    oModel:SetDescription("Modelo de Dados do Cadastro "+cTitulo)
     
    //Setando a descri��o do formul�rio
    oModel:GetModel("FORMSZ2"):SetDescription("Formul�rio do Cadastro "+cTitulo)
    
    oStSZ2:SetProperty('Z2_TES',MODEL_FIELD_VALID, {|| APFATA1B()}) 
      
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
    Local oModel := FWLoadModel( 'APFATA01' )
    Local oStSZ2 := FWFormStruct(2, "SZ2")  //pode se usar um terceiro par�metro para filtrar os campos exibidos { |cCampo| cCampo $ 'SBM_NOME|SBM_DTAFAL|'}
    Local oStSZ5 := FWFormStruct(2, "SZ5") 
    //Criando oView como nulo
    Local oView := Nil
    
    // Remove campos da estrutura para nao aparecer na grid
    oStSZ5:RemoveField( 'Z5_TPMOD' )
    oStSZ5:RemoveField( 'Z5_TPFAT' )
 
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


//#################
//# Programa      # APFATA1B
//# Data          #   
//# Descri��o     # Valida��o Tes 
//# Desenvolvedor # Edie Carlos 
//# Empresa       # Totvs Nacoes Unidas
//# Linguagem     # eAdvpl     
//# Vers�o        # 12
//# Sistema       # Protheus
//# M�dulo        # Faturamento
//# Tabelas       # "SF4"
//# Observa��o    # Usado para excluir os titulos de gera��o manual 
//#===============#
//# Atualiza��es  # 
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
		Help( ,, 'HELP',, 'Informar somente tes que n�o gere financeiro!!', 1, 0)
		lRet := .F.
		ENDIF	
	
	ELSE
		Help( ,, 'HELP',, 'Tes n�o encontrada no cadastro!!', 1, 0)  
		lRet := .F.  
	ENDIF

Return(lRet)