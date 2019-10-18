#include 'protheus.ch'
#include 'parmtype.ch'
#include 'protheus.ch'
#include 'parmtype.ch'
#INCLUDE "Protheus.CH"
#include "rwmake.ch"



user function IMPCT2()



	Local aArea  	:= GetArea()
	Local cTitulo	:= "Acertos Contabeis"
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

	AADD(aSays,OemToAnsi("Rotina para Importação de arquivo texto para tabela CT2"))
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
	Local _lOk := .T.
	Local aItens := {}
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

		If lPrim //considerando que a primeira linha são os campos do cadastros, reservar numa variavel
			aCampos := Separa(cLinha,";",.T.)
			lPrim := .F.
		Else// gravar em outra variavel os registros
			AADD(aDados,Separa(cLinha,";",.T.))
		EndIf

		FT_FSKIP()
	EndDo

	FT_FUSE()

	oProcess:SetRegua1(len(aDados)) //guardar novamente a quantidade de registros

	For i:=1 to Len(aDados)

		oProcess:IncRegua1("Importando Titulo..."+Alltrim(aDados[i,4]))


		If Empty(aDados[i,1])
			Return
		EndIf

		aCliente := {}

		dbSelectArea("CT2")
		dbSetOrder(1)
		dbGoTop()

		//Neste exemplo iremos incluir registros, portanto iremos validar se o mesmo não existe na tabela de clientes
		Reclock("CT2",.T.)
		CT2->CT2_FILIAL  := "0101"
		CT2->CT2_DATA    := ctoD(aDados[i,2])
		CT2->CT2_LOTE    := aDados[i,3]
		CT2->CT2_SBLOTE  := "0001"
		CT2->CT2_DOC     := Padl(aDados[i,5],6,'0')
		CT2->CT2_LINHA   := Padl(aDados[i,6],3,'0')
		CT2->CT2_MOEDLC  := "01"
		CT2->CT2_DC      := aDados[i,8]
		CT2->CT2_DEBITO  := aDados[i,9]
		CT2->CT2_CREDIT  := aDados[i,10]
		CT2->CT2_VALOR   := Val(StrTran(aDados[i,11],',','.'))
		CT2->CT2_HIST    := UPPER(FwNoAccent(aDados[i,12]))
		CT2->CT2_EMPORI  := "01"
		CT2->CT2_FILORI  := "0101"
		CT2->CT2_TPSALD  := aDados[i,15]
		CT2->CT2_MANUAL  := aDados[i,16]
		CT2->CT2_AGLUT   := aDados[i,17]
		CT2->CT2_SEQHIS  := aDados[i,18]
		CT2->CT2_SEQLAN  := aDados[i,6]
		CT2->CT2_CCC     := aDados[i,20]
		CT2->CT2_CCD     := aDados[i,21]
		CT2->CT2_ITEMD   := aDados[i,22]
		CT2->CT2_ITEMC   := aDados[i,23]
		CT2->CT2_CLVLDB  := aDados[i,24]
		CT2->CT2_CLVLCR  := aDados[i,25]

		MsUnlock()
	Next i
	
	IF(MV_PAR02==1)
		If File(cArqProc)
			fErase(cArqProc)
		Endif
		fRename(Upper(cArquivo), cArqProc)
	Endif

	If !Empty(cErro)
		cErro += "Finalizado Carga de Ativo." + CHR(13)+CHR(10)
		cTexto 	+= U_FVldcTexto(cTexto,cErro+CRLF)

		U_FWindowLog(,cTexto,cHoraIni,cArqLog,cSrvPath)
	Else
		ApMsgInfo("Importação de Carga de Ativo efetuada com sucesso!","SUCESSO")
	EndIf

Return