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

user function VincoR()

	Local cPerg := "RELMEGA"
	Local aArea       := GetArea()

	if .not. Pergunte(cPerg, .t. )
		return
	endif

	 u_IMPREC2()

	RestArea(aArea)

return



User Function IMPREC2()

	Local cPerg       := "RELMEGA"
	Local aArea       := GetArea()
	Local oFWMsExcel
	Local oExcel
	Local cArquivo    := GetTempPath()+'zTstExc2.xml'
	Local cQuery
	Local nPointer
	Local cConta


	cQuery := " SELECT E5_BANCO AS CONTA, SE5.E5_DATA AS EMISSAO,SE5.E5_VENCTO AS VENCIMENTO," + pCTRL
	cQuery += " E5_TIPO AS TIPO,SE5.E5_NUMERO AS NUMERO,E5_PARCELA AS PARCELA,E5_HISTOR HISTORICO,SE5.E5_VALOR VALOR," + pCTRL
	cQuery += " SE5.E5_VALOR  AS RATEIO," + pCTRL
	cQuery += " SE5.R_E_C_N_O_ LANC,CT1.CT1_XMEGA CLASSE,CT1.CT1_XCONTA  CTB,CT1.CT1_DESC01 RED,SED.ED_CONTA,SED.ED_CODIGO " + pCTRL
	cQuery += " FROM " +RetSQLName('SE5')+" SE5 " 
	cQuery += " INNER JOIN " +RetSQLName('SED')+" SED ON SED.ED_CODIGO = SE5.E5_NATUREZ AND SED.D_E_L_E_T_ <> '*' "                     + pCTRL
	cQuery += " INNER JOIN " +RetSQLName('CT1')+" CT1 ON CT1.CT1_CONTA = SED.ED_CONTA AND CT1.D_E_L_E_T_ <> '*' "                       + pCTRL
	//cQuery += " INNER JOIN " +RetSQLName('SEV')+" SEV ON SEV.EV_NUM = SE5.E5_NUMERO AND SEV.EV_CLIFOR = SE5.E5_FORNECE "                       + pCTRL	
	cQuery += " WHERE SE5.D_E_L_E_T_ <> '*' AND SE5.E5_RECPAG='R' AND SE5.E5_RECONC='x' AND SE5.E5_DTDISPO BETWEEN '" + DTOS(MV_PAR01) + "' AND '"+ DTOS(MV_PAR02) + "'" 		



	TCQuery cQuery New Alias "QRYSE1"

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

	oProcess:SetRegua1(QRYSE1->(reccount()))

	//Criando as Linhas
	QRYSE1->(DBGoTop())
	While .Not. QRYSE1->(EoF())

		oProcess:IncRegua1()
		//Query para pegar Rateio
		oFWMsExcel:AddRow("Mega","Relatorio Mega", { QRYSE1->CONTA,;
		TRANSFORM( STOD(QRYSE1->EMISSAO), "@D 99/99/9999"),;
		TRANSFORM( STOD(QRYSE1->VENCIMENTO), "@D 99/99/9999"),;
		Alltrim(QRYSE1->TIPO), ;
		QRYSE1->NUMERO, ;
		Alltrim(QRYSE1->HISTORICO), ;
		QRYSE1->VALOR, ;
		IIF( EMPTY( QRYSE1->RATEIO ), QRYSE1->VALOR, QRYSE1->RATEIO ),;
		QRYSE1->LANC, ;
		IIF( EMPTY( QRYSE1->CLASSE ), "120435", QRYSE1->CLASSE ), ;
		Alltrim(QRYSE1->CTB), ;
		Alltrim(QRYSE1->RED) ;
		} )


		//Pulando Registro
		QRYSE1->(DbSkip())
	EndDo

	//Ativando o arquivo e gerando o xml
	oFWMsExcel:Activate()
	oFWMsExcel:GetXMLFile(cArquivo)

	//Abrindo o excel e abrindo o arquivo xml
	oExcel := MsExcel():New()        //Abre uma nova conexão com Excel
	oExcel:WorkBooks:Open(cArquivo)  //Abre uma planilha
	oExcel:SetVisible(.T.)           //Visualiza a planilha
	oExcel:Destroy()                 //Encerra o processo do gerenciador de tarefas

	QRYSE1->(DbCloseArea())

	RestArea(aArea)

Return

