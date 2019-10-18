#include 'protheus.ch'
#include 'parmtype.ch'
#include 'topconn.ch'

user function IMPSE5()

	Local aArea  	:= GetArea()
	Local cTitulo	:= "Movimento Bancário a receber"
	Local nOpcao 	:= 0
	Local aButtons 	:= {}
	Local aSays    	:= {}
	Local cPerg		:= "CLI001"
	Private cArquivo:= ""
	Private oProcess
	Private lRenomear:= .F.

	//ajustaSx1(cPerg)

	Pergunte(cPerg,.F.)

	AADD(aSays,OemToAnsi("Rotina para Importação de arquivo csv de Notas de Faturamento"))
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
	Local cErro 	 := ""
	Local cLinha     := ""
	Local lPrim      := .T.
	Local aCampos    := {}
	Local aDados     := {}
	Local aCliente   := {}
	Local nCont		 := 1
	Private aErro 	 := {}
	Private lMsErroAuto := .F.
	Private lMsHelpAuto	:= .T.

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

	dbSelectArea("SE5")
	SE5->(dbSetOrder(1))

	For i:=1 to Len(aDados)

		oProcess:IncRegua1("Importando clientes..."+aDados[i,2])


		aFINA100 := {    {"E5_DATA"        ,CtoD(aDados[i,1])                    ,Nil},;
		{"E5_MOEDA"        ,"M1"                            ,Nil},;
		{"E5_VALOR"         ,Val(StrTran(aDados[i,4],",","."))                            ,Nil},;
		{"E5_NATUREZ"    ,aDados[i,6]                        ,Nil},;
		{"E5_BANCO"        ,aDados[i,7]                          ,Nil},;
		{"E5_AGENCIA"    ,aDados[i,8]                         ,Nil},;
		{"E5_CONTA"        ,aDados[i,9]                         ,Nil},;
		{"E5_DOCUMEN"        , "TH "+aDados[i,3]                      ,Nil},;
		{"E5_RECONC"        ,"x"                       ,Nil},;
		{"E5_HISTOR"    ,aDados[i,2]       ,Nil}}

		If Alltrim(Upper(aDados[i,5])) == 'P'
			MSExecAuto({|x,y,z| FinA100(x,y,z)},0,aFINA100,3)
		Else
			MSExecAuto({|x,y,z| FinA100(x,y,z)},0,aFINA100,4)
		EndIf

		If lMsErroAuto
			cErroTemp:=Mostraerro("\system\", DToC(Date())+ "_" +Time()+ ".log")
			nLinhas:=MLCount(cErroTemp)
			cBuffer:=""
			cCampo:=""
			nErrLin:=1
			//cBuffer:=RTrim(MemoLine(cErroTemp,,nErrLin))
			//Carrega o nome do campo
			While (nErrLin <= nLinhas)
				cBuffer:=Alltrim(RTrim(MemoLine(cErroTemp,,nErrLin)))
				If (Upper(SubStr(cBuffer,1,4)) == "HELP") .or. (Upper(SubStr(cBuffer,1,5)) == "AJUDA")
					cErro+="Linha: "+Alltrim(Str(i))+" -"+Alltrim(RTrim(MemoLine(cErroTemp,,1)))+" "+Alltrim(RTrim(MemoLine(cErroTemp,,2)))+" "+Alltrim(RTrim(MemoLine(cErroTemp,,3))+" "+Alltrim(RTrim(MemoLine(cErroTemp,,4))))
				EndIf
				If (Upper(SubStr(cBuffer,Len(cBuffer)-7,Len(cBuffer))) == "INVALIDO")
					cErro+="Linha: "+Alltrim(Str(i))+" -"+Alltrim(cBuffer)+" | "
				EndIf
				nErrLin++

			EndDo
			cErro+= chr(13)+chr(10)
		Endif
	Next i

	IF(MV_PAR02==1)
		If File(cArqProc)
			fErase(cArqProc)
		Endif
		fRename(Upper(cArquivo), cArqProc)
	Endif	


	If !Empty(cErro)
		cErro += "Finalizado Carga de Notas de faturamento." + CHR(13)+CHR(10)
		cTexto 	+= U_FVldcTexto(cTexto,cErro+CRLF)

		U_FWindowLog(,cTexto,cHoraIni,cArqLog,cSrvPath)
	Else
		ApMsgInfo("Importação de clientes e notas efetuada com sucesso!","SUCESSO")
	EndIf

Return

Static Function ajustaSx1(cPerg)
	XputSx1(cPerg, "01", "Arquivo"  , "", "", "mv_ch1", "C", 99, 0, 0, "G", "", "DIR", "", "","mv_par01", "", "", "", "", "", "", "","", "", "", "", "", "", "", "", "", {"Informe o arquivo TXT que será","importado (Extensão CSV)",""}, {"","",""}, {"","",""})
	XPutSx1(cPerg, "02", "Renomear?", "", "", "mv_ch2", "N",  1, 0, 2, "C", "",    "", "", "","mv_par02","Sim","Si","Yes","","Nao","No","No")
Return


User Function FA100ROT()
	Local aRotina := aClone(PARAMIXB[1])//Adiciona Rotina Customizada a EnchoiceBar
	aAdd( aRotina, { 'Importar Lançamentos' ,'U_IMPSE5', 0 , 7 })

Return aRotina//Rotina chamada pelo botão criado na EnchoiceBar

             
