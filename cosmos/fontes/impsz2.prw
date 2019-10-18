#include 'protheus.ch'
#include 'parmtype.ch'

user function IMPSZ2()
	Local aArea  	:= GetArea()
	Local cTitulo	:= "Importação Fornecedores Távola"
	Local nOpcao 	:= 0
	Local aButtons 	:= {}
	Local aSays    	:= {}
	Local cPerg		:= "CLI001"
	Private cArquivo:= ""
	Private oProcess
	Private lRenomear:= .F.
	Private lMsErroAuto := .F.

	ajustaSx1(cPerg)

	Pergunte(cPerg,.F.)

	AADD(aSays,OemToAnsi("Rotina para Importação de arquivo de fornecedores do Távola"))
	AADD(aSays,"")
	AADD(aSays,OemToAnsi("Clique no botão PARAM para informar os parametros que deverão ser considerados."))
	AADD(aSays,"")
	AADD(aSays,OemToAnsi("Após isso, clique no botão OK."))

	AADD(aButtons, { 1,.T.,{|o| nOpcao:= 1,o:oWnd:End()} } )
	AADD(aButtons, { 2,.T.,{|o| nOpcao:= 2,o:oWnd:End()} } )
	AADD(aButtons, { 5,.T.,{| | pergunte(cPerg,.T.)  } } )

	FormBatch( cTitulo, aSays, aButtons,,200,530 )

	if nOpcao = 1
		cArquivo:= Alltrim(MV_PAR01)

		if Empty(cArquivo)
			MsgStop("Informe o nome do arquivo!!!","Erro")
			return
		Endif

		oProcess := MsNewProcess():New( { || Importa() } , "Importação de registros " , "Aguarde..." , .F. )
		oProcess:Activate()

	EndIf

	RestArea(aArea)

Return

Static Function Importa()
	Local cArqProc   := cArquivo+".processado"
	Local cTexto    := ""
	Local cHoraIni 	:= " Data / Hora Inicio.: "+DToC(Date())+ " / " +Time()+ CRLF
	Local cArqLog	:= "PR" + DToS(Date()) + StrTran(Time(),":","")+".log"
	Local cSrvPath  := GetPvProfString(GetEnvServer(),"StartPath","",GetADV97())
	Local cLinha     := ""
	Local lPrim      := .T.
	Local aCampos    := {}
	Local aDados     := {}
	Local aProdutos   := {}
	Local nCont		 := 1
	Local cErro 	 := ""
	Private aErro 	 := {}
	Private aParam := {}

	If !File(cArquivo)
		MsgStop("O arquivo " + cArquivo + " não foi encontrado. A importação será abortada!","[AEST904] - ATENCAO")
		Return
	EndIf

	FT_FUSE(cArquivo) //Abre o arquivo texto
	oProcess:SetRegua1(FT_FLASTREC()) //Preenche a regua com a quantidade de registros encontrados
	FT_FGOTOP() //coloca o arquivo no topo
	While !FT_FEOF()
		nCont++
		oProcess:IncRegua1('Validando Linha: ' + Alltrim(Str(nCont)))

		cLinha := FT_FREADLN()
		cLinha := ALLTRIM(cLinha)

		//If lPrim //considerando que a primeira linha são os campos do cadastros, reservar numa variavel
		//	aCampos := Separa(cLinha,";admin	",.T.)
		//	lPrim := .F.
		//Else// gravar em outra variavel os registros
		AADD(aDados,Separa(StrTran(cLinha,'"',''),";",.T.))
		//EndIf

		FT_FSKIP()
	EndDo

	FT_FUSE()

	oProcess:SetRegua1(len(aDados)) //guardar novamente a quantidade de registros

	dbSelectArea("SZ2")
	SZ2->(dbSetOrder(1))


	For i:=1 to Len(aDados)

		oProcess:IncRegua1("Fornecedor: "+Alltrim(aDados[i,2]))
		Reclock("SZ2",.T.)
		SZ2->Z2_FILIAL  := "0101"

		SZ2->Z2_EVENTO :=aDados[i,1]
		SZ2->Z2_CODE   :=aDados[i,2]
		SZ2->Z2_PARTID :=aDados[i,3]
		SZ2->Z2_SUPID  :=aDados[i,4]
		SZ2->Z2_PRODUTO:=aDados[i,5]
		SZ2->Z2_ACAO   :=aDados[i,6]
		SZ2->Z2_PRODID :=aDados[i,7]
		SZ2->Z2_PARTNAM:=aDados[i,8]
		SZ2->Z2_SUPNAM :=aDados[i,9]
		SZ2->Z2_EMISSAO:=aDados[i,10]
		SZ2->Z2_VENCTO :=aDados[i,11]
		SZ2->Z2_PREFIXO:=aDados[i,12]
		SZ2->Z2_TIPO   :=aDados[i,13]
		SZ2->Z2_CONDPG :=aDados[i,14]
		MsUnlock()

	Next i

	IF(MV_PAR02==1)
		If File(cArqProc)
			fErase(cArqProc)
		Endif
		fRename(Upper(cArquivo), cArqProc)
	Endif

	If !Empty(cErro)
		cErro += "Finalizado Carga de Fornecedor Távola." + CHR(13)+CHR(10)
		cTexto 	+= U_FVldcTexto(cTexto,cErro+CRLF)

		U_FWindowLog(,cTexto,cHoraIni,cArqLog,cSrvPath)
	Else
		ApMsgInfo("Importação de Carga de Fornecedor Távola efetuada com sucesso!","SUCESSO")
	EndIf

Return