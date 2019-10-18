#Include 'Protheus.ch'
#Include 'FWMVCDef.ch'
#INCLUDE "RWMAKE.CH"
#Include 'Protheus.ch'


user function APFATA02()

	Local oBrowse	:= Nil
	Local cFilter	:= ""
	Local cQuery	:= ""
	Local cChave	:= ""
	Local aColumns	:= {}
	Local nX		:= 0
	Local aStru		:= SZ4->(DBSTRUCT())
	Local bOk		:= {||}
	Local cTitulo	:= "Controle de Transferencia"


	cQuery := " SELECT DISTINCT Z4_TIPO "
	cQuery += " FROM "+ RetSqlName("SZ4") +" SZ4 "
	cQuery += "WHERE SZ4.Z4_FILIAL = '" + xFilial("SZ4") + "' "
	cQuery += "AND SZ4.D_E_L_E_T_ = ' ' "


	cArqTrab := CriaTrab(aStru, .T.) // Nome do arquivo temporario
	dbUseArea(.T., __LocalDriver, cArqTrab, cArqTrab, .F.)
	Processa({||SqlToTrb(cQuery, aStru, cArqTrab)})	// Cria arquivo temporario
	DbSetOrder(0) // Fica na ordem da query

	//Browse
	For nX := 1 To Len(aStru)
		If	aStru[nX][1] $ "Z4_TIPO"
			AAdd(aColumns,FWBrwColumn():New())
			aColumns[Len(aColumns)]:SetData( &("{||"+aStru[nX][1]+"}") )
			aColumns[Len(aColumns)]:SetTitle(RetTitle(aStru[nX][1]))
			aColumns[Len(aColumns)]:SetSize(aStru[nX][3])
			aColumns[Len(aColumns)]:SetDecimal(aStru[nX][4])
			aColumns[Len(aColumns)]:SetPicture(/*Iif( aStru[nX][1] != "FWA_STATUS", */PesqPict("SZ4",aStru[nX][1])/*, PesqPict("FWA",aStru[nX][1]) )*/ )  
		EndIf
	Next nX

	oBrowse:= FWMBrowse():New()
	oBrowse:SetAlias(cArqTrab)
	oBrowse:SetDescription(cTitulo)
	oBrowse:SetColumns(aColumns)
	oBrowse:DisableDetails()
	oBrowse:Activate()

return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณMenuDef   บAutor  ณEdie Carlos         บ Data ณ  30/03/17   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Defini็ใo do menu                                          บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function MenuDef()
	Local _aRotina := {}

	ADD OPTION _aRotina TITLE 'Visualizar' ACTION 'VIEWDEF.APFATA02' OPERATION MODEL_OPERATION_VIEW   ACCESS 0 //OPERATION 1
	ADD OPTION _aRotina TITLE 'Incluir'    ACTION 'VIEWDEF.APFATA02' OPERATION MODEL_OPERATION_INSERT ACCESS 0 //OPERATION 3
	ADD OPTION _aRotina TITLE 'Alterar'    ACTION 'VIEWDEF.APFATA02' OPERATION MODEL_OPERATION_UPDATE ACCESS 0 //OPERATION 4
	ADD OPTION _aRotina TITLE 'Excluir'    ACTION 'VIEWDEF.APFATA02' OPERATION MODEL_OPERATION_DELETE ACCESS 0 //OPERATION 5

return _aRotina   

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณModelDef  บAutor  ณRenato Lucena Neves บ Data ณ  30/03/17   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Definicao do modelo de dados                               บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function ModelDef()

	Local oStruSZ1 := FWFormStruct( 1, 'SZ4',{ |x| ALLTRIM(x) $ 'Z4_TIPO' } ) 
	Local oStruSZ2 := FWFormStruct( 1, 'SZ4',{ |x| ALLTRIM(x) $ 'Z4_CAMPO,Z4_DESCRI' } )
	Local oModel
	Local aAux := {}

	//ADICIONA CAMPO DE CKECK NO GRID
	oStruSZ2:AddField( 'Mark',;        // cTitle // 'Mark'
	'Mark',;        // cToolTip // 'Mark'
	'AA3_FLAG',;    // cIdField
	'L',;           // cTipo
	1,;             // nTamanho
	0,;             // nDecimal
	{||.T.},;       // bValid
	{|| .T.},;      // bWhen
	Nil,;           // aValues
	Nil,;           // lObrigat
	Nil,;           // bInit
	Nil,;           // lKey
	.F.,;           // lNoUpd
	.T. )           // lVirtual



	oModel := MPFormModel():New('APFATA2M',,,)
	oModel:AddFields( 'CABECALHO', /*cOwner*/, oStruSZ1,,, )
	oModel:addGrid('Grid','CABECALHO',oStruSZ2,,,,,{|oGrid| GerSX3(oGrid,"1")})   
	oModel:SetDescription( 'Modelo de Separacao' )
	oModel:SetPrimaryKey( {} )
	oModel:GetModel( 'CABECALHO' ):SetDescription( 'Cabe็alo da Separa็ใo' )

Return oModel

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณViewDef   บAutor  ณRenato Lucena Neves บ Data ณ  30/03/17   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Define a camada de visualizacao da separacao               บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function ViewDef()

	Local oModel   := FWLoadModel( 'APFATA02' )
	Local oStruSZ1 := FWFormStruct( 2, 'SZ4',{ |x| ALLTRIM(x) $ 'Z4_TIPO' } ) 
	Local oStruSZ2 := FWFormStruct( 2, 'SZ4',{ |x| ALLTRIM(x) $ 'Z4_CAMPO,Z4_DESCRI' } ) 
	Local oView


	oStruSZ2:AddField( 'AA3_FLAG',;             // cIdField
	'01',;                   // cOrdem
	'Mark',;                // cTitulo // 'Mark'
	'Mark',;                // cDescric // 'Mark'
	{'Marque os itens para serem separados ', 'no atendimento da loca็ใo'},;     // aHelp  // 'Marque os itens para serem separados ' ### 'no atendimento da loca็ใo'
	'CHECK',;                // cType
	'@!',;                   // cPicture
	Nil,;                    // nPictVar
	Nil,;   	                 // Consulta F3
	.T.,;                    // lCanChange
	'01',;                   // cFolder
	Nil,;                    // cGroup
	Nil,;                    // aComboValues
	Nil,;                    // nMaxLenCombo
	Nil,;                    // cIniBrow
	.T.,;   	                 // lVirtual
	Nil )       	             // cPictVar



	oView := FWFormView():New()
	oView:SetModel( oModel )

	oView:AddField( 'VIEW_CABEC', oStruSZ1, 'CABECALHO' )
	oView:AddGrid( 'VIEW_GRID', oStruSZ2,'Grid' )

	// Cria um "box" horizontal para receber cada elemento da view
	oView:CreateHorizontalBox( 'SUPERIOR', 30 )
	oView:CreateHorizontalBox( 'INFERIOR', 70 )

	oView:CreateVerticalBox( 'INFERIOR_ESQUERDA', 20, 'INFERIOR' )
	oView:CreateVerticalBox( 'INFERIOR_DIREITA', 70, 'INFERIOR' )

	// Relaciona o identificador (ID) da View com o "box" para exibi็ใo
	oView:SetOwnerView( 'VIEW_CABEC', 'SUPERIOR' )
	oView:SetOwnerView( 'VIEW_GRID', 'INFERIOR' )

	oView:EnableTitleView( 'VIEW_CABEC' )


Return oView


Static Function GerSX3()
	Local oMdlTd  	:= FwModelActive()
	Local oView 	:= FwViewActive()
	Local oMdl      := oMdlTd:GetModel('CABECALHO')
	Local oMdlGri   := oMdlTd:GetModel('Grid')
	Local aSave     := GetArea()
	oMdlGri:Goline(oMdlGri:Length())

	DBSelectArea( "SX3" )
	DBSeek("SZ0")

	Do While !Eof() .and. X3_ARQUIVO == "SZ0"

		IF X3USO( X3_USADO ) .and. X3_TIPO == "N"
			oMdlGri:AddLine()

			oMdlTd:LoadValue("Grid","Z4_CAMPO"  , AllTrim( X3_CAMPO ))
			oMdlTd:LoadValue("Grid","Z4_CAMPO"  , AllTrim( X3_DESCRI ))
		ENDIF

		DBSkip()
	EndDo		

	RestArea(aSave)
	oView:Refresh()							
Return(.T.)