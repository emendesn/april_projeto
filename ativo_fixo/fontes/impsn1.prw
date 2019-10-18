#include 'protheus.ch'
#include 'parmtype.ch'
#INCLUDE "Protheus.CH"
#include "rwmake.ch"

user function IMPSN1()


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

	dbSelectArea("SN1")
	SN1->(dbSetOrder(1))

	DbSelectArea("SNG")
	SNG->(DbSetOrder(1))


	For i:=1 to Len(aDados)

		oProcess:IncRegua1("Importando Ativo Fixo..."+Alltrim(Str(i)))

		aCab   := {}
		aItens := {}

		If Empty(aDados[i,1])
			Return
		EndIf

		If !dbSeek(xFilial("SN1")+aDados[i,1]+ "0001")
			AAdd(aCab,{"N1_FILIAL" , xFilial("SN1"),NIL})
			AAdd(aCab,{"N1_CBASE" , aDados[i,1] ,NIL})
			AAdd(aCab,{"N1_ITEM" , "0001" ,NIL})
			AAdd(aCab,{"N1_AQUISIC", dATE() ,NIL})
			AAdd(aCab,{"N1_DESCRIC", Substr(aDados[i,4],1,40) ,NIL})
			AAdd(aCab,{"N1_QUANTD" , 1 ,NIL})
			AAdd(aCab,{"N1_CHAPA" , aDados[i,7] ,NIL})
			AAdd(aCab,{"N1_PATRIM" ,"" ,NIL})
			AAdd(aCab,{"N1_NFISCAL" ,aDados[i,6] ,NIL})
			AAdd(aCab,{"N1_GRUPO" , Padl(aDados[i,5],4,"0") ,NIL})
			//CODIGOBEM	ITEM	DTAQUISIC	DESCRICAO	GRUPO	DT.INICIAL.DEPREC	VALOR DO BEM	SALDO DO BEM	DESCRICAO
			AAdd(aItens,{; 
			{"N3_FILIAL" , xFilial("SN3"),NIL},;
			{"N3_CBASE" , aDados[i,1] ,NIL},;
			{"N3_ITEM" , "0001" ,NIL},;
			{"N3_TIPO" , "01" ,NIL},;
			{"N3_BAIXA" , "0" ,NIL},;
			{"N3_HISTOR" , "IMPORTAÇÃO DEPRECIACAO" ,NIL},;
			{"N3_CCONTAB" , Posicione("SNG",1,xFilial("SNG")+Padl(aDados[i,5],4,"0"),"NG_CCONTAB") ,NIL},;
			{"N3_CUSTBEM" , "" ,NIL},;
			{"N3_CDEPREC" , Posicione("SNG",1,xFilial("SNG")+Padl(aDados[i,5],4,"0"),"NG_CDEPREC") ,NIL},;
			{"N3_CDESP" , "" ,NIL},;
			{"N3_CCORREC" , "" ,NIL},;
			{"N3_CCUSTO" , "" ,NIL},;
			{"N3_DINDEPR" , Date() ,NIL},;
			{"N3_VORIG1" , Val(Strtran(aDados[i,10],".","")) ,NIL},;
			{"N3_TXDEPR1" , Posicione("SNG",1,xFilial("SNG")+Padl(aDados[i,5],4,"0"),"NG_TXDEPR1") ,NIL},;
			{"N3_DESCEST" , aDados[i,4] ,NIL},;
			{"N3_VRDMES1" , Val(Strtran(aDados[i,12],".","")) ,NIL},;
			{"N3_VRDACM1" , Val(Strtran(aDados[i,13],".","")) ,NIL}})

			lMsErroAuto := .F.
			//Utilizar o MsExecAuto para incluir registros na tabela de clientes, utilizando a opção 3
			MSExecAuto({|x,y,z| Atfa012(x,y,z)},aCab,aItens,3,aParam)
			//Caso encontre erro exibir na tela
			If lMsErroAuto 

				MostraErro()
				DisarmTransaction()
			Endif
		Else //Caso o registro exista, gravar o log
			cErro +="Linha: "+Alltrim(Str(i))+" Ativo :"+aDados[i,1]+ " Item :"+aDados[i,2]+ " já cadastrado."+ CHR(13)+CHR(10)
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