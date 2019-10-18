#Include "Protheus.ch"
#Include "TopConn.ch"

//Constantes
#Define STR_PULA    Chr(13)+Chr(10)

user function IMPCADF()
	Local aArea        := GetArea()
	Local cQuery        := ""
	Local oFWMsExcel
	Local oExcel
	Local cArquivo    := GetTempPath()+'zTstExc1.xml'

	cQuery2 := " SELECT RA_FILIAL,RA_MAT,RA_NOMECMP,RA_NOME,RA_CEP,RA_BAIRRO,RA_MUNICIP,RA_ESTADO,RA_DDDCELU,RA_NUMCELU,RA_CIC,RA_NASC,RA_SITFOLH,"
	cQuery2 += " RTRIM(LTRIM(RA_LOGRTP))+'. '+RTRIM(LTRIM(RA_LOGRDSC))+', '+LTRIM(RTRIM(RA_NUMENDE))+' '+RTRIM(LTRIM(RA_COMPLEM)) AS ENDEREC "                                                + STR_PULA
	cQuery2 += " FROM "                                                    + STR_PULA
	cQuery2 += "     "+RetSQLName('SRA')+" SRA "                           + STR_PULA
	cQuery2 += " WHERE SRA.D_E_L_E_T_<>'*'  ORDER BY SRA.RA_MAT   "                           + STR_PULA

	TCQuery cQuery2 New Alias "QRYPRO2"



	//Pegando os dados
	cQuery := " SELECT RA_FILIAL,RA_NOMECMP,RA_MAT,RA_NOME,RB_NOME,RB_SEXO,RB_DTNASC" + STR_PULA
	cQuery += " FROM "                                                    + STR_PULA
	cQuery += "     "+RetSQLName('SRB')+" RB "                            + STR_PULA
	cQuery += "     INNER JOIN "+RetSQLName('SRA')+"  RA ON RA_FILIAL=RB_FILIAL AND RA_MAT=RB_MAT"        + STR_PULA
	cQuery += "     WHERE RB.D_E_L_E_T_<>'*' AND RA.D_E_L_E_T_<>'*' ORDER BY RA_MAT"                                            + STR_PULA
	TCQuery cQuery New Alias "QRYPRO"

	//Criando o objeto que irá gerar o conteúdo do Excel
	oFWMsExcel := FWMSExcel():New()

	//Aba 01 - Teste
	oFWMsExcel:AddworkSheet("Dados Funcionarios") //Não utilizar número junto com sinal de menos. Ex.: 1-
	//Criando a Tabela
	oFWMsExcel:AddTable("Dados Funcionarios","Titulo Tabela")
	//Criando Colunas

	//Nome	Sobrenome	Endereço	CEP	Bairro	Cidade	Estado	Numéro de Celular	CPF	Data de nascimento

	oFWMsExcel:AddColumn("Dados Funcionarios","Titulo Tabela","Empresa",1,1) //1 = Modo Texto
	oFWMsExcel:AddColumn("Dados Funcionarios","Titulo Tabela","Matricula",1,1) //1 = Modo Texto
	oFWMsExcel:AddColumn("Dados Funcionarios","Titulo Tabela","Nome Completo",1,1) //2 = Valor sem R$
	oFWMsExcel:AddColumn("Dados Funcionarios","Titulo Tabela","Endereço",1,1) //3 = Valor com R$
	oFWMsExcel:AddColumn("Dados Funcionarios","Titulo Tabela","CEP",1,1)
	oFWMsExcel:AddColumn("Dados Funcionarios","Titulo Tabela","Bairro",1,1)
	oFWMsExcel:AddColumn("Dados Funcionarios","Titulo Tabela","Cidade",1,1)
	oFWMsExcel:AddColumn("Dados Funcionarios","Titulo Tabela","Estado",1,1)
	oFWMsExcel:AddColumn("Dados Funcionarios","Titulo Tabela","Celular",1,1)
	oFWMsExcel:AddColumn("Dados Funcionarios","Titulo Tabela","CPF",1,1)
	oFWMsExcel:AddColumn("Dados Funcionarios","Titulo Tabela","Data de Nascimento",1,1)
	oFWMsExcel:AddColumn("Dados Funcionarios","Titulo Tabela","Situação Folha",1,1)
	//Criando as Linhas
	While !(QRYPRO2->(EoF()))

		//Situação da Folha
		If (Alltrim(QRYPRO2->RA_SITFOLH)=="D")
			cSithFol := "Demitido"
		Elseif (Alltrim(QRYPRO2->RA_SITFOLH)=="A")
			cSithFol := "Ausente"
		Elseif (Alltrim(QRYPRO2->RA_SITFOLH)=="F")
			cSithFol := "Férias"
		Else
			cSithFol := "Ativo"
		EndIf

		//Endereço
		//Alltrim(QRYPRO2->RA_ENDEREC)+","++"-"+Alltrim(QRYPRO2->RA_COMPLEM)

		oFWMsExcel:AddRow("Dados Funcionarios","Titulo Tabela",{;
		Iif(QRYPRO2->RA_FILIAL == '0101', 'São Paulo', 'Rio de Janeiro'),;
		Alltrim(QRYPRO2->RA_MAT),;
		Iif(Empty(Alltrim(QRYPRO2->RA_NOMECMP)), QRYPRO2->RA_NOME,QRYPRO2->RA_NOMECMP),;
		Alltrim(QRYPRO2->ENDEREC),;
		Alltrim(QRYPRO2->RA_CEP),;
		Alltrim(QRYPRO2->RA_BAIRRO),;
		Alltrim(QRYPRO2->RA_MUNICIP),;
		Alltrim(QRYPRO2->RA_ESTADO),;
		Alltrim(QRYPRO2->RA_DDDCELU)+"-"+Alltrim(QRYPRO2->RA_NUMCELU),;
		QRYPRO2->RA_CIC,;
		StoD(Alltrim(QRYPRO2->RA_NASC)),;
		cSithFol;
		})

		//Pulando Registro
		QRYPRO2->(DbSkip())
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
	QRYPRO2->(DbCloseArea())
	RestArea(aArea)
Return