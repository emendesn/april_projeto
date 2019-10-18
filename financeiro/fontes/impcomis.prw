#include 'protheus.ch'
#include 'parmtype.ch'
#INCLUDE "Protheus.CH"
#include "rwmake.ch"
#include "Topconn.ch"

user function IMPCOMIS()//


	Local aArea  	:= GetArea()
	Local cTitulo	:= "Importação Ativo Fixo"
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

	AADD(aSays,OemToAnsi("Rotina para Importação de arquivo texto para tabela SN1/SN3"))
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
		AADD(aDados,Separa(cLinha,";",.T.))
		FT_FSKIP()
	EndDo

	FT_FUSE()

	oProcess:SetRegua1(len(aDados)) //guardar novamente a quantidade de registros
	dbSelectArea("SE2")
	SE2->(dbSetOrder(1))

	For i:=1 to Len(aDados)

		oProcess:IncRegua1("Importando Titulo..."+Alltrim(aDados[i,1]))

		If Alltrim(aDados[i,1]) <> '|'

			cQuery1 := " SELECT * FROM "+RetSQlName("SA2")+" "
			cQuery1 += " WHERE D_E_L_E_T_<>'*' AND A2_CGC='"+StrTran(aDados[i,87],'"','')+"' "
			If Select("TRB2") <> 0
				dbSelectArea("TRB2")
				dbCloseArea()
			EndIf

			TCQuery cQuery1 New Alias "TRB2"

			Reclock("SE2",.T.)
			SE2->E2_FILIAL := xFilial("SE2")
			SE2->E2_PREFIXO := "COM"
			SE2->E2_NUM := StrTran(aDados[i,3],'"','')
			SE2->E2_TIPO := "TF"
			SE2->E2_NATUREZ := '2.08.01'
			SE2->E2_FORNECE := TRB2->A2_COD
			SE2->E2_NOMFOR := SUBSTR(TRB2->A2_NREDUZ,1,20)
			SE2->E2_LOJA := "01"
			SE2->E2_EMISSAO := StoD(aDados[i,6])
			SE2->E2_VENCTO := Stod(aDados[i,7])
			SE2->E2_VENCREA:= Stod(aDados[i,7])
			SE2->E2_VALOR := Val(StrTran(StrTran(aDados[i,15],",","."),'"',''))//Val(StrTran(aDados[i,15],',','.'))
			SE2->E2_HIST := StrTran(aDados[i,22],'"','')
			Msunlock()

		EndIf
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