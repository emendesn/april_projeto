//Bibliotecas
#Include "Protheus.ch"
#Include "TopConn.ch"

//Constantes
#Define STR_PULA    Chr(13)+Chr(10)

/*/{Protheus.doc} zTstExc1
Função que cria um exemplo de FWMsExcel
@author Atilio
@since 06/08/2016
@version 1.0
@example
u_zTstExc1()
/*/

User Function RAPRRAT()
	Local aArea        := GetArea()d
	Local cQuery        := ""
	Local oFWMsExcel
	Local oExcel
	Local cArquivo    := GetTempPath()+'zTstExc2.xml'

	//Pegando os dados
	cQuery := " SELECT DE_FILIAL,DE_DOC,D1_EMISSAO,D1_DTDIGIT,DE_FORNECE,A2_NOME,DE_ITEMNF,DE_ITEM,DE_PERC,DE_CC,CTT_DESC01,DE_CONTA,CT1_DESC01,DE_CUSTO1 "+ STR_PULA
	cQuery += " FROM "+RetSQLName('SDE')+" SDE  "+ STR_PULA
	cQuery += " INNER JOIN "+RetSQLName('SD1')+" SD1 ON D1_FILIAL=DE_FILIAL AND D1_DOC=DE_DOC AND D1_SERIE=DE_SERIE AND DE_FORNECE=D1_FORNECE AND DE_ITEMNF=D1_ITEM "+ STR_PULA
	cQuery += " INNER JOIN "+RetSQLName('SA2')+" SA2 ON DE_FORNECE = A2_COD AND DE_LOJA = A2_LOJA "+ STR_PULA
	cQuery += " INNER JOIN "+RetSQLName('CT1')+" CT1 ON CT1_CONTA = DE_CONTA "+ STR_PULA
	cQuery += " INNER JOIN "+RetSQLName('CTT')+" CTT ON CTT_CUSTO = DE_CC "+ STR_PULA
	cQuery += " WHERE SDE.D_E_L_E_T_<>'*' AND SD1.D_E_L_E_T_<>'*' AND SA2.D_E_L_E_T_<>'*' AND CT1.D_E_L_E_T_<>'*' AND CTT.D_E_L_E_T_<>'*' "+ STR_PULA
	TCQuery cQuery New Alias "QRYPRO"

	//Criando o objeto que irá gerar o conteúdo do Excel
	oFWMsExcel := FWMSExcel():New()

	//Aba 02 - Rateios
	oFWMsExcel:AddworkSheet("Rateio Compras")
	//Criando a Tabela
	oFWMsExcel:AddTable("Rateio Compras","Rateios")
	oFWMsExcel:AddColumn("Rateio Compras","Rateios","Filial",1)
	oFWMsExcel:AddColumn("Rateio Compras","Rateios","Nº da NF",1)
	oFWMsExcel:AddColumn("Rateio Compras","Rateios","Dt.Emissao",1)
	oFWMsExcel:AddColumn("Rateio Compras","Rateios","Dt.Digitação",1)
	oFWMsExcel:AddColumn("Rateio Compras","Rateios","Fornecedor",1)
	oFWMsExcel:AddColumn("Rateio Compras","Rateios","Nome Fornecedor",1)
	oFWMsExcel:AddColumn("Rateio Compras","Rateios","%Rateio",1)
	oFWMsExcel:AddColumn("Rateio Compras","Rateios","Codigo C.C",1)
	oFWMsExcel:AddColumn("Rateio Compras","Rateios","Descrição C.C",1)
	oFWMsExcel:AddColumn("Rateio Compras","Rateios","Conta Contábil",1)
	oFWMsExcel:AddColumn("Rateio Compras","Rateios","Descrição Conta Contábil",1)
	oFWMsExcel:AddColumn("Rateio Compras","Rateios","Valor Rateado",1)
	
	//Criando as Linhas... Enquanto não for fim da query
	While !(QRYPRO->(EoF()))
		oFWMsExcel:AddRow("Rateio Compras","Rateios",{;
		QRYPRO->DE_FILIAL,;
		QRYPRO->DE_DOC,;
		QRYPRO->D1_EMISSAO,;
		QRYPRO->D1_DTDIGIT,;
		QRYPRO->DE_FORNECE,;
		QRYPRO->A2_NOME,;
		QRYPRO->DE_PERC,;
		QRYPRO->DE_CC,;
		QRYPRO->CTT_DESC01,;
		QRYPRO->DE_CONTA,;
		QRYPRO->CT1_DESC01,;
		QRYPRO->DE_CUSTO1;
		})

		//Pulando Registro
		QRYPRO->(DbSkip())
	EndDo

	//Ativando o arquivo e gerando o xml
	oFWMsExcel:Activate()
	oFWMsExcel:GetXMLFile(cArquivo)

	//Abrindo o excel e abrindo o arquivo xml
	oExcel := MsExcel():New()             //Abre uma nova conexão com Excel
	oExcel:WorkBooks:Open(cArquivo)     //Abre uma planilha
	oExcel:SetVisible(.T.)                 //Visualiza a planilha
	oExcel:Destroy()                        //Encerra o processo do gerenciador de tarefas

	QRYPRO->(DbCloseArea())
	RestArea(aArea)
Return