#include 'protheus.ch'
#include 'parmtype.ch'
#include 'protheus.ch'
#include 'Topconn.ch'
#INCLUDE "Protheus.CH"
#include "rwmake.ch"

User function IMPCLI()	

	Local aArea  	:= GetArea()
	Local cTitulo	:= "Importação Clientes Távola"
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

	AADD(aSays,OemToAnsi("Rotina para Importação de arquivo de tavola do Távola"))
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
			aCampos := Separa(cLinha,";admin	",.T.)
			lPrim := .F.
		Else// gravar em outra variavel os registros
			AADD(aDados,Separa(StrTran(cLinha,'"',''),";",.T.))
		EndIf

		FT_FSKIP()
	EndDo

	FT_FUSE()

	oProcess:SetRegua1(len(aDados)) //guardar novamente a quantidade de registros

	dbSelectArea("SA1")
	SA1->(dbSetOrder(3))


	For i:=1 to Len(aDados)

		oProcess:IncRegua1("Cliente: "+Alltrim(aDados[i,2]))

		cQuery := " SELECT MAX(A1_COD) as A1_COD FROM "+RetSQlName("SA1")+" "
		cQuery += " WHERE  D_E_L_E_T_<>'*' "

		If Select("TRB") <> 0
			dbSelectArea("TRB")
			dbCloseArea()
		EndIf

		TCQuery cQuery New Alias "TRB"
		aCliente :={}
		cCodCli := Soma1(TRB->A1_COD)
		AAdd(aCliente,{"A1_FILIAL" , xFilial("SA1"),NIL})
		AAdd(aCliente,{"A1_COD" , cCodCli,NIL})
		AAdd(aCliente,{"A1_LOJA" ,"01" ,NIL})
		AAdd(aCliente,{"A1_PESSOA","F",NIL})
		aAdd(aCliente,{"A1_TIPO"    ,"F"       ,Nil})	
		AAdd(aCliente,{"A1_CGC"	,padl(aDados[i,16],11,'0'),NIL})
		AAdd(aCliente,{"A1_INSCRM"	,aDados[i,17] ,NIL})
		AAdd(aCliente,{"A1_INSCR","ISENTO" ,NIL})	
		AAdd(aCliente,{"A1_NOME"	,aDados[i,2] ,NIL})
		AAdd(aCliente,{"A1_NREDUZ"	,aDados[i,1] ,NIL})
		AAdd(aCliente,{"A1_END"	,aDados[i,3] ,NIL})
		AAdd(aCliente,{"A1_NR_END"	,"" ,NIL})
		AAdd(aCliente,{"A1_COMPLEM"	,"" ,NIL})
		AAdd(aCliente,{"A1_BAIRRO","" ,NIL})
		AAdd(aCliente,{"A1_EST"	  ,aDados[i,5] ,NIL})	
		AAdd(aCliente,{"A1_MUN"	 ,aDados[i,5],NIL})
		AAdd(aCliente,{"A1_CEP"	 ,aDados[i,8] ,NIL})
		AAdd(aCliente,{"A1_EMAIL","",NIL})
		AAdd(aCliente,{"A1_CONTA","1120010001",NIL})

		aVetor := FWVetByDic( aCliente, 'SA1' )
		MSExecAuto({|x,y| Mata030(x,y)},aVetor,3)
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
		EndIf
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