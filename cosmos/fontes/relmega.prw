#Include "Protheus.ch"
#Include "TopConn.ch"
//Constantes
#DEFINE pCTRL      CHR(13)+CHR(10)

#DEFINE pCONTA     { { "03", "CX1", "CAIXNHA SP" }, ;
{ "09", "237", "BRADESCO"   }, ;
{ "10", "033", "SANTANDER"  }, ; 
{ "12", "341", "ITAU"       }, ; 
{ "13", "033", "SANTANDER"  }, ; 
{ "23", "707", "DAYCOVAL"   }  ;
}

STATIC oProcess

user function IMPMEGA()

	Local cPerg := "RELMEGA"
	Local aArea       := GetArea()

	if .not. Pergunte(cPerg, .t. )
		return
	endif

	if MV_PAR03 == 1
		oProcess := MsNewProcess():New( { || ImpPagar() } , "Gerando relatorio" , "Aguarde..." , .F. )
		oProcess:Activate()
	elseif MV_PAR03 == 2
		u_IMPREC()
	endif

	RestArea(aArea)

return


/*#######################################################################
## Funcao:     ## ImpReceber                                           ##
#########################################################################
## Descricao:  ## Rorina para geracao de planilha excel com os         ##
##             ## movimentos do contas a Pagar                         ##
#########################################################################
## Parametros: ##                                                      ##
#########################################################################
## Retorno:    ## VOID                                                 ##
#########################################################################
## Autor :     ## Edilson Mendes Nascimento                            ##
#########################################################################
## Data:       ## 28/06/2010                                           ##
#########################################################################
## Uso : Especifico para April                                         ##
#########################################################################
## Palavras Chaves: Relatorio                                          ##
#######################################################################*/
Static Procedure ImpPagar()

	Local cPerg       := "RELMEGA"
	Local aArea       := GetArea()
	Local oFWMsExcel
	Local oExcel
	Local cArquivo    := GetTempPath()+'zTstExc1.xml'
	Local cQuery
	Local nPointer
	Local cConta

	cQuery := " SELECT E5_BANCO AS CONTA, SE5.E5_DATA AS EMISSAO,SE5.E5_VENCTO AS VENCIMENTO," + pCTRL
	cQuery += " E5_TIPO AS TIPO,SE5.E5_NUMERO AS NUMERO,E5_PARCELA AS PARCELA,E5_HISTOR HISTORICO,SE5.E5_VALOR VALOR," + pCTRL
	cQuery += "  SEV.EV_VALOR  AS RATEIO, SDE.DE_CUSTO1  AS RATEIO1," + pCTRL
	cQuery += " SE5.R_E_C_N_O_ LANC,CT1.CT1_XMEGA CLASSE,CT1.CT1_XCONTA  CTB,CT1.CT1_DESC01 RED,SED.ED_CONTA,SED.ED_CODIGO " + pCTRL
	cQuery += " FROM " +RetSQLName('SE5')+" SE5 " 
	cQuery += " INNER JOIN " +RetSQLName('SED')+" SED ON SED.ED_CODIGO = SE5.E5_NATUREZ AND SED.D_E_L_E_T_ <> '*' "                     + pCTRL
	cQuery += " INNER JOIN " +RetSQLName('CT1')+" CT1 ON CT1.CT1_CONTA = SED.ED_CONTA AND CT1.D_E_L_E_T_ <> '*' "                       + pCTRL
	cQuery += " INNER JOIN " +RetSQLName('SEV')+" SEV ON SEV.EV_NUM = SE5.E5_NUMERO AND SEV.EV_CLIFOR = SE5.E5_CLIFOR "                       + pCTRL	
	cQuery += " INNER JOIN " +RetSQLName('SDE')+" SDE ON SDE.DE_DOC = SE5.E5_NUMERO AND SDE.D_E_L_E_T_ <> '*' "                       + pCTRL	
	cQuery += " WHERE SE5.D_E_L_E_T_ <> '*'  AND SE5.E5_RECPAG='P' AND SE5.E5_RECONC='x' AND "  + pCTRL
	cQuery += "  SE5.E5_DTDISPO BETWEEN '" + DTOS(MV_PAR01) + "' AND '"+ DTOS(MV_PAR02) + "'"  + pCTRL


	TCQuery cQuery New Alias "QRYSE2"

	//Criando o objeto que irá gerar o conteúdo do Excel
	oFWMsExcel := FWMSExcel():New()

	//Aba 01 - Teste
	oFWMsExcel:AddworkSheet("Mega") //Não utilizar número junto com sinal de menos. Ex.: 1-
	//Criando a Tabela
	oFWMsExcel:AddTable("Mega","Relatorio Mega")
	//Criando Colunas

	//Conta	   Emissao    Vencimento    Tipo Doc    Num Doc    Historico    Vlr.Lancto.    Vlr.Rateado    Lancamento    Classe    CTB    RED

	oFWMsExcel:AddColumn("Mega","Relatorio Mega","Conta",1,1)
	oFWMsExcel:AddColumn("Mega","Relatorio Mega","Emissao",1,1)
	oFWMsExcel:AddColumn("Mega","Relatorio Mega","Vencimento",1,1)
	oFWMsExcel:AddColumn("Mega","Relatorio Mega","Tipo Doc.",1,1)
	oFWMsExcel:AddColumn("Mega","Relatorio Mega","Num.Doc.",1,1)
	oFWMsExcel:AddColumn("Mega","Relatorio Mega","Historico",1,1)
	oFWMsExcel:AddColumn("Mega","Relatorio Mega","Vlr.Lancto",1,1)
	oFWMsExcel:AddColumn("Mega","Relatorio Mega","Vlr.Rateado",1,1)
	oFWMsExcel:AddColumn("Mega","Relatorio Mega","Lancamento",1,1)
	oFWMsExcel:AddColumn("Mega","Relatorio Mega","Classe",1,1)
	oFWMsExcel:AddColumn("Mega","Relatorio Mega","CTB",1,1)
	oFWMsExcel:AddColumn("Mega","Relatorio Mega","RED",1,1)

	oProcess:SetRegua1(QRYSE2->(reccount()))

	//Criando as Linhas
	QRYSE2->(DBGoTop())
	While QRYSE2->(!EoF())

		oProcess:IncRegua1()
		//Pegar o rateio
		nValRat := 0
		If QRYSE2->RATEIO1 <=0
			If QRYSE2->RATEIO <=0
				nValRat := QRYSE2->VALOR
			Else
				nValRat := QRYSE2->RATEIO 
			EndIf
		Else
			nValRat := QRYSE2->RATEIO1 
		EndIf
		
		oFWMsExcel:AddRow("Mega","Relatorio Mega", { QRYSE2->CONTA,;
		TRANSFORM( STOD(QRYSE2->EMISSAO), "@D 99/99/9999"),;
		TRANSFORM( STOD(QRYSE2->VENCIMENTO), "@D 99/99/9999"),;
		Alltrim(QRYSE2->TIPO), ;
		QRYSE2->NUMERO, ;
		Alltrim(QRYSE2->HISTORICO), ;
		QRYSE2->VALOR, ;
		nValRat,;
		QRYSE2->LANC, ;
		IIF( EMPTY( QRYSE2->CLASSE ), "120435", QRYSE2->CLASSE ), ;
		Alltrim(QRYSE2->CTB), ;
		Alltrim(QRYSE2->RED) } )

		//Pulando Registro
		QRYSE2->(DbSkip())
	EndDo

	//Ativando o arquivo e gerando o xml
	oFWMsExcel:Activate()
	oFWMsExcel:GetXMLFile(cArquivo)

	//Abrindo o excel e abrindo o arquivo xml
	oExcel := MsExcel():New()        //Abre uma nova conexão com Excel
	oExcel:WorkBooks:Open(cArquivo)  //Abre uma planilha
	oExcel:SetVisible(.T.)           //Visualiza a planilha
	oExcel:Destroy()                 //Encerra o processo do gerenciador de tarefas

	QRYSE2->(DbCloseArea())

	RestArea(aArea)

Return