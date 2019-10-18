#INCLUDE 'TOTVS.CH'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'FWBROWSE.CH'
#Include 'TopConn.ch'
#INCLUDE 'TBICONN.CH'

User Function APRCOM001()

	Local oMark
	Private aRotina := MenuDef()

	//estanciamento da classe mark
	oMark := FWMarkBrowse():New()   

	//tabela que sera utilizada
	oMark:SetAlias( "ZZD" )

	//Titulo
	oMark:SetDescription( "Browse de Marcação" )
	//campo que recebera a marca
	oMark:SetFieldMark( "ZZD_OK" )                                          

	oMark:AddLegend( "ZZD_STATUS =='1'", "GREEN","Pendente" )
	oMark:AddLegend( "ZZD_STATUS =='2'", "RED" , "Processado" )
	oMark:AddLegend( "ZZD_STATUS =='3'", "BLUE" ,"Erro" )

	//Ativa
	oMark:Activate()

	Return

Return NIL
//-------------------------------------------------------------------
Static Function MenuDef()
	Local aRotina := {}
	ADD OPTION aRotina TITLE 'Visualizar' ACTION 'VIEWDEF.COMP001_MVC' OPERATION 2 ACCESS 0
	ADD OPTION aRotina TITLE 'Alterar' ACTION    'VIEWDEF.COMP001_MVC' OPERATION 4 ACCESS 0
	ADD OPTION aRotina TITLE 'Importar' ACTION   'U_COMP01IMP()' OPERATION 3 ACCESS 0
	ADD OPTION aRotina TITLE 'Gerar Pedido de Compras' ACTION  'U_COMP01PROC()' OPERATION 2 ACCESS 0
	ADD OPTION aRotina TITLE 'Excluir'  ACTION   'U_COMP01EXCL()' OPERATION 2 ACCESS 0
	ADD OPTION aRotina TITLE 'Exportar' ACTION   'U_COMP01CSV()' OPERATION 6 ACCESS 0
Return aRotina

//-------------------------------------------------------------------
Static Function ModelDef()
	Local oStruZZD := FWFormStruct( 1, 'ZZD' )
	Local oModel // Modelo de dados que será construído
	// Cria o objeto do Modelo de Dados
	oModel := MPFormModel():New('COMP001M' )
	// Adiciona ao modelo um componente de formulário
	oModel:AddFields( 'ZZDMASTER', /*cOwner*/, oStruZZD)

	oModel:SetPrimaryKey( { "Z1_FILIAL", "Z1_DEMONS","Z1_EMISSO","Z1_GCG" } )

	// Adiciona a descrição do Modelo de Dados
	oModel:SetDescription( 'Seleção de OVER para Emissão de Pedido de Compra')
	// Adiciona a descrição do Componente do Modelo de Dados
	oModel:GetModel( 'ZZDMASTER' ):SetDescription('Dados do Pedido')
	// Retorna o Modelo de dados
Return oModel


//-------------------------------------------------------------------
Static Function ViewDef()
	// Cria um objeto de Modelo de dados baseado no ModelDef() do fonte informado
	Local oModel := FWLoadModel( 'COMP001_MVC' )
	// Cria a estrutura a ser usada na View
	Local oStruSZ1 := FWFormStruct( 2, 'ZZD' )
	// Interface de visualização construída
	Local oView
	// Cria o objeto de View
	oView := FWFormView():New()
	// Define qual o Modelo de dados será utilizado na View
	oView:SetModel( oModel )
	// Adiciona no nosso View um controle do tipo formulário
	// (antiga Enchoice)
	oView:AddField( 'VIEW_ZZD', oStruSZ1, 'ZZDMASTER' )
	// Criar um "box" horizontal para receber algum elemento da view
	oView:CreateHorizontalBox( 'TELA' , 100 )
	// Relaciona o identificador (ID) da View com o "box" para exibição
	oView:SetOwnerView( 'VIEW_ZZD', 'TELA' )
	// Retorna o objeto de View criado
	Return oView

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³SEL_ARQ   ºAutor  ³Marçal de Campos    º Data ³  17/11/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Abre tela no servidor para o usuario localizar o arquivo   º±±
±±º          ³ que será utilizado.                                        º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ P10                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function SEL_ARQ()

	Local cSvAlias		:= Alias()
	Local cNewPathArq   := cGetFile( "Arquivo CSV (*.CSV)|*.CSV|", "Selecione o Arquivo",,, .T., GETF_NETWORKDRIVE + GETF_LOCALHARD)

Return(cNewPathArq)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³COMP001_MVCºAutor  ³Microsiga           º Data ³  08/30/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function COMP01IMP()
	Private oProcess
	Private cRetArq

	cRetArq := U_SEL_ARQ()

	oProcess := MsNewProcess():New( { || Importa() } , "Importação de registros " , "Aguarde..." , .F. )
	oProcess:Activate()
Return

Static Function Importa()

	Local aDados     := {}
	Local nCont      := 0
	Local cLinha     := ""
	Local lPrim      := .T.
	Local cDemons    := ""

	If Empty(cRetArq)
		Return
	EndIf

	FT_FUSE(cRetArq) //Abre o arquivo texto
	oProcess:SetRegua1(FT_FLASTREC()) //Preenche a regua com a quantidade de registros encontrados
	FT_FGOTOP() //coloca o arquivo no topo

	While !FT_FEOF()
		nCont++
		oProcess:IncRegua1('Validando Linha: ' + Alltrim(Str(nCont)))

		cLinha := FT_FREADLN()
		cLinha := ALLTRIM(cLinha)

		If lPrim //considerando que a primeira linha são os campos do cadastros, reservar numa variavel
			aCampos := Separa(cLinha,";",.T.)
			lPrim := .F.
			cDemons := Right(aCampos[1],4)
		Else// gravar em outra variavel os registros
			AADD(aDados,Separa(cLinha,";",.T.))
		EndIf

		FT_FSKIP()
	EndDo

	FT_FUSE()

	oProcess:SetRegua1(len(aDados)) //guardar novamente a quantidade de registros

	dbSelectArea("ZZD")
	ZZD->(dbSetOrder(1))

	For i:=2 to Len(aDados)

		oProcess:IncRegua1("Importando Emissor..."+Alltrim(aDados[i,1])+chr(13)+chr(10))

		If substr(aDados[i,1],1,5)<>'TOTAL'
			If substr(aDados[i,1],1,5)<>'EMISS'
				//If !dbSeek(xFilial("SN1")+aDados[i,1]+ Padl(aDados[i,2],4,"0"))
				Reclock("ZZD",.T.)
				ZZD->ZZD_FILIAL  := xFilial("ZZD")
				ZZD->ZZD_DEMONS  := cDemons
				ZZD->ZZD_EMISSO  := aDados[i,1]
				ZZD->ZZD_CGC     := aDados[i,2]
				ZZD->ZZD_VENCTO  := CtoD(aDados[i,3])
				ZZD->ZZD_FATURA  := aDados[i,4]
				ZZD->ZZD_VALOR   := Val(aDados[i,5])
				ZZD->ZZD_DTSAQ   := CtoD(aDados[i,6])
				ZZD->ZZD_IDSAQ   := aDados[i,7]
				ZZD->ZZD_AREA    := aDados[i,8]
				ZZD->ZZD_STATUS  := '1'
				MsUnlock()
			EndIf
		EndIf
	Next i

	ApMsgInfo( 'Leitura e processamento de Over efetuado com sucesso!', 'TERMINO' )
Return          

//-------------------------------------------------------------------
User Function COMP01PROC()
 
Processa( { || lOk := Runproc() },'Aguarde','Processando...',.F.)

Return()

Static function Runproc()

Local aArea 	:= GetArea()
Local cMarca 	:= oMark:Mark()
Local nCt 		:= 0
Local nVlFrete	:= 0
Local cEnd		:= ''
Local cBairro	:= ''
Local cMun		:= ''
Local cUF		:= ''
Local cCEP		:= ''
Local cComplem	:= ''

ZZD->( dbGoTop() )

While !ZZD->( EOF() )
    
    _cPedido:= SZ1->Z1_ID                               
	_cNumItem		:= StrZero(0,TamSX3("C7_ITEM")[1])
	_aItens	:= {}
	n:=1

	If oMark:IsMark(cMarca)
	
		While !EOF() .AND. SZ1->Z1_ID == _cPedido
			
			If oMark:IsMark(cMarca) .AND. SZ1->Z1_STATUS <> "2"

				If Empty( cCEP ) .Or. cCEP <> SZ1->Z1_CEP
					cEnd	:= RTrim( SZ1->Z1_RUA )
					cBairro	:= RTrim( SZ1->Z1_BAIRRO )
					cMun	:= RTrim( SZ1->Z1_MUN )
					cUF		:= RTrim( SZ1->Z1_UF )
					cCEP	:= SZ1->Z1_CEP
					cComplem:= RTrim( SZ1->Z1_COMPLE )
				EndIf

				Dbselectarea("SB1")
				Dbsetorder(1)
				Dbseek(xFilial("SB1") + SZ1->Z1_COD)				        
				Dbselectarea("SA1")
				Dbsetorder(3)	//CGC

				// Entra neste bloco quando nao encontrar o cliente (INCLUSAO) 
				IF !SA1->( Msseek(xFilial("SA1") + SZ1->Z1_CGC) )	// EXISTE CLIENTE CADASTRADO

					aVetor := {}
		                                          
					lMsErroAuto := .F.
		            IF !EMPTY(SZ1->Z1_COD_MUN)
					    _cCodMun:=SZ1->Z1_COD_MUN 
				    ELSE
						Dbselectarea("CC2")
						Dbsetorder(2)
						Dbseek(xFilial("CC2") + ALLTRIM(SZ1->Z1_MUN) + SPACE(60 - LEN(ALLTRIM(SZ1->Z1_MUN))))					
						_cCodMun:= CC2_CODMUN
					ENDIF

					aVetor:={ {"A1_COD"  ,GetSXENum("SA1","A1_COD"),Nil},; // Codigo       C 06
							 {"A1_LOJA"      ,"01"               ,Nil},; // Loja         C 02
							 {"A1_PESSOA"    ,SZ1->Z1_TIPO       ,Nil},; // 
							 {"A1_NOME"      ,SZ1->Z1_CLIENTE ,Nil},; // Nome         C 40
							 {"A1_NREDUZ"    ,SUBSTR(SZ1->Z1_CLIENTE,1,20),Nil},; // Nome reduz.  C 20
							 {"A1_TIPO"      ,"F"				    ,Nil},; // Tipo         C 01 //R Revendedor
							 {"A1_END"       ,ALLTRIM(SZ1->Z1_RUA),Nil},; // Endereco     C 40
							 {"A1_BAIRRO"    ,SZ1->Z1_BAIRRO,Nil},; // Endereco     C 40
							 {"A1_CEP"       ,SZ1->Z1_CEP,Nil},; // Endereco     C 40
							 {"A1_DDD"       ,SZ1->Z1_DDD,Nil},; // Endereco     C 40
							 {"A1_TEL"       ,SZ1->Z1_FONE,Nil},; // Endereco     C 40
							 {"A1_EMAIL"     ,SZ1->Z1_EMAIL,Nil},; // Endereco     C 40
							 {"A1_CGC"       ,SZ1->Z1_CGC,Nil},; // Endereco     C 40
							 {"A1_PFISICA"   ,SZ1->Z1_RG,Nil},; // Endereco     C 40
							 {"A1_COMPLEM"   ,SZ1->Z1_COMPLE,Nil},; // Endereco     C 40
							 {"A1_EST"       ,SZ1->Z1_UF   ,Nil},; // Cidade       C 15
							 {"A1_RISCO"     ,"A",Nil},; // Cidade       C 15
							 {"A1_MUN"       ,SZ1->Z1_MUN,Nil}}  // Estado       C 02
							 
					MSExecAuto({|x,y| Mata030(x,y)},aVetor,3) //Inclusao

					If lMsErroAuto
						Alert("Erro ao criar Cliente")
						DisarmTransaction()
						MOSTRAERRO()
						
						Dbselectarea("SZ1")
				    	Reclock("SZ1",.F.)
				    	SZ1->Z1_STATUS:= "3"
				    	MsUnlock()
						dbskip()
	                    loop
					
					Else                                    
						ConfirmSX8()
						Dbselectarea("SA1")
						Dbsetorder(3)
						Dbseek(xFilial("SA1") + SZ1->Z1_CGC)
						Reclock("SA1",.F.)
					  	SA1->A1_COD_MUN:= _cCodMun
						MsUnlock()
					Endif
		    	
		    	Endif
		    	
			//	_cNumItem 	:= SOMA1(_cNumItem)
			//_aItens :={}
			aAdd(_aItens,{})
			aAdd( _aItens[n],				{"C6_ITEM"			    ,StrZero(n,2) 																												,Nil} ) // Codigo do Produto
			aAdd( _aItens[n],				{"C6_PRODUTO"			, SZ1->Z1_COD 													,Nil} ) // Codigo do Produto
			aAdd( _aItens[n],				{"C6_UM"     			, Posicione("SB1",1,xFilial("SB1") + SZ1->Z1_COD,"B1_UM") 		,Nil} )// Unidade de Medida Primar.
			aAdd( _aItens[n],				{"C6_TES"    			, "501"             											,Nil} )// Tipo de Entrada/Saida do Item
  	    	aAdd( _aItens[n],				{"C6_QTDVEN" 			, SZ1->Z1_QUANT 												,Nil} ) // Quantidade Vendida
			aAdd( _aItens[n],				{"C6_PRCVEN" 			, SZ1->Z1_PRCVEN - SZ1->Z1_DESCONT								,Nil} ) // Preco Unitario Liquido
			aAdd( _aItens[n],				{"C6_VALOR"  			, SZ1->Z1_TOTAL - SZ1->Z1_DESCONT								,Nil} ) // Valor Total do Item
			aAdd( _aItens[n],				{"C6_LOCAL"  			, Posicione("SB1",1,xFilial("SB1") + SZ1->Z1_COD,"B1_LOCPAD")	,Nil} ) // Almoxarifado
			aAdd( _aItens[n],				{"C6_CLI"    			, Posicione("SA1",3,xFilial("SA1") + SZ1->Z1_CGC,"A1_COD")    	,Nil} ) // Cliente
			aAdd( _aItens[n],				{"C6_ENTREG" 			, dDataBase					         							,Nil} ) // Data da Entrega CtoD(_aListItem[_nItem,5])
			aAdd( _aItens[n],				{"C6_LOJA"   			, Posicione("SA1",3,xFilial("SA1") + SZ1->Z1_CGC,"A1_LOJA")		,Nil} )
			aAdd( _aItens[n],				{"C6_PARCEIR"   		, SZ1->Z1_PARCEIR    											,Nil} ) 
			aAdd( _aItens[n],				{"C6_CAMPANH"   		,  SZ1->Z1_CAMPANH    											,Nil} )// Loja do Cliente
			aAdd( _aItens[n],				{"C6_CCUPOM"   			, SZ1->Z1_CUPOM    												,Nil} )
			aAdd( _aItens[n],				{"C6_DESCRI"   			, Posicione("SB1",1,xFilial("SB1") + SZ1->Z1_COD,"B1_DESC")     ,Nil} )
			If SZ1->Z1_DESCONT > 0
				//aAdd( _aItens[n],			{"C6_DESCONT"   		, SZ1->Z1_DESCONT   											,Nil} ) // Desconto por item
				aAdd( _aItens[n],			{"C6_VALDESC"   		, SZ1->Z1_DESCONT   											,Nil} ) // Desconto por item
				aAdd( _aItens[n],			{"C6_DESCONT"   		, (SZ1->Z1_DESCONT * 100)/SZ1->Z1_PRCVEN						,Nil} ) // % Desconto por item
			EndIf
			nVlFrete += SZ1->Z1_VLFRETE
			Dbselectarea("SZ1")
			Reclock("SZ1",.F.)
			SZ1->Z1_STATUS:= "2"
			MsUnlock()

		    Endif
	
			Dbselectarea("SZ1")
			SZ1->( dbSkip() )
			n:=n+1
			nCt++
		Enddo
	
		lMsErroAuto := .F.
		
		_aCab		:= {}
		
		_aCab	 := {{"C5_TIPO"		, "N"				, Nil},;
					{"C5_CLIENTE"	, SA1->A1_COD		, Nil},;
					{"C5_LOJACLI"	, SA1->A1_LOJA      , Nil},;
					{"C5_TIPOCLI"	, SA1->A1_TIPO		, Nil},;
					{"C5_CONDPAG"	, "001"				, Nil},;
					{"C5_EMISSAO"	, dDataBase			, Nil},;
					{"C5_MOEDA"		, 1					, Nil},;
					{"C5_IDPORTA"	, _cPedido			, Nil},;
					{"C5_END"		, cEnd			   	, Nil},;
					{"C5_BAIRRO"	, cBairro		   	, Nil},;
					{"C5_MUN"		, cMun			   	, Nil},;
					{"C5_EST"		, cUF			   	, Nil},;
					{"C5_CEP"		, cCEP			   	, Nil},;
					{"C5_COMPLEM"	, cComplem		   	, Nil},;
					{"C5_XORIGEM"	, "IMP" 		   	, Nil},;
					{"C5_FRETE"		, nVlFrete		  	, Nil},;
					{"C5_TIPLIB"	, "1"				, Nil}}		                                   

		nVlFrete := 0

		If !Empty(_aCab) .and. !Empty(_aItens)
	
			MSExecAuto({|x,y,z| MATA410(x,y,z)},_aCab,_aItens,3)
	
			
			If lMSErroAuto 
			
				DisarmTransaction()
				MOSTRAERRO()    
		
				Dbselectarea("SZ1")
		    	Reclock("SZ1",.F.)
		    	SZ1->Z1_STATUS:= "3"
		    	MsUnlock()
			
			Else
            	_cNUMPED:=SC5->C5_NUM
				U_GERANF(SC5->C5_NUM)				
	       		Dbselectarea("SZ1")
	       		Dbsetorder(1)
	            // GRAVA NOTA, SERIE E PEDIDO GERADO NA TABELA SZ1
			EndIf		
		Endif   
    Else
   		Dbselectarea("SZ1")
		SZ1->( dbSkip() )
	Endif
			
End

RestArea( aArea )

Return NIL