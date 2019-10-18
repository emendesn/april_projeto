#include 'protheus.ch'
#include 'parmtype.ch'
#include 'protheus.ch'
#include 'Topconn.ch'
#INCLUDE "Protheus.CH"
#include "rwmake.ch"

user function FATFAV()

	Local aArea  	:= GetArea()
	Local cTitulo	:= "Importação Título de Comissão do Távola"
	Local nOpcao 	:= 0
	Local aButtons 	:= {}
	Local aSays    	:= {}
	Local cPerg		:= "CLI001"
	Private cArquivo:= ""
	Private oProcess
	Private lRenomear:= .F.
	Private lMsErroAuto := .F.

	//ajustaSx1(cPerg)

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

	dbSelectArea("ZZD")
	ZZD->(dbSetOrder(1))

	For i:=1 to Len(aDados)

		oProcess:IncRegua1("CNPJ: "+Alltrim(aDados[i,1]))
		Reclock("ZZD",.T.)
		ZZD->ZZD_FILIAL := xFilial("ZZD")
		ZZD->ZZD_EMISSO := aDados[i,1]
		ZZD->ZZD_CPF := aDados[i,2]
		ZZD->ZZD_VENC := aDados[i,3]
		ZZD->ZZD_FAT := aDados[i,4]
		ZZD->ZZD_VAL := Val(aDados[i,5])
		ZZD->ZZD_SAQ := aDados[i,6]
		ZZD->ZZD_IDSAQ := aDados[i,7]
		ZZD->ZZD_AREA := aDados[i,8]
		ZZD->ZZD_ID := aDados[i,9]

		MsUnlock()
	Next i

	IF(MV_PAR02==1)
		If File(cArqProc)
			fErase(cArqProc)
		Endif
		fRename(Upper(cArquivo), cArqProc)
	Endif

	If !Empty(cErro)
		cErro += "Finalizado Carga de Fornecedor Távdola." + CHR(13)+CHR(10)
		cTexto 	+= U_FVldcTexto(cTexto,cErro+CRLF)

		U_FWindowLog(,cTexto,cHoraIni,cArqLog,cSrvPath)
	Else
		ApMsgInfo("Importação de Carga de Fornecedor Távola efetuada com sucesso!","SUCESSO")
	EndIf

Return