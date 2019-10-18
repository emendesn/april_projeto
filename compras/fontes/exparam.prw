#include 'protheus.ch'
#include 'parmtype.ch'

#DEFINE pEOL           CHR(13)+CHR(10)

User Function ExParam()
	Local aPergs   := {}
	Local cCodRec  := space(08)
	Local cRecDest := space(340)
	Local cArquivo := padr("",150)
	Local aRet	   := {}

	aAdd( aPergs ,{1,"Campo texto",cRecDest,"@!",,,'.T.',340,.T.})


	If ParamBox(aPergs ,"Exemplo",aRet)
		If TCSQLExec(aRet[1]) < 0 
			MsgStop( "TCSQLError() " + TCSQLError(), 'April Brasil' )
		Else
			MsgInfo( "Executado com Sucesso!!!", 'April Brasil'  )
		EndIf
	Else
		Aviso("Processo cancelado")
	EndIf
Return .T.



user function xp2()


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

	//ajustaSx1(cPerg)

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

	LOCAL aLogString

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

		oProcess:IncRegua1("Importando Ativo Fixo..."+Alltrim(aDados[i,1]))

		aLogString := {}		

		If TCSQLExec(aDados[i,1]) < 0
			//MsgStop( "TCSQLError() " + TCSQLError(), 'April Brasil' )
			AADD(aLogString, "["+PADC(TIME(),10) + "]-" + "TCSQLError() " + TCSQLError() )
		Else
			AADD(aLogString, "["+PADC(TIME(),10) + "]-" + aDados[i,1] )
		EndIf

		GERALog( aLogString )

	Next i

Return


//
// Rotina utilizada para a gravacao do log dos registros
//
STATIC PROCEDURE GERALog(aLogString)

	LOCAL cPasta     := "\logs\logadmin\"
	LOCAL nHandle
	LOCAL cNomLog
	LOCAL nPos
	LOCAL cLogString := ""


	if ExistDirectory( cPasta ) == 0

		cNomLog := cPasta + "log-admin-" + DTOS( DATE() ) + ".log"

		//Realiza a gravacao das informacoes no arquivo de log
		If .NOT. FILE( cNomLog )
			nHandle := FCreate(cNomLog)
			FWrite(nHandle,Replicate( "-", 128 ) + pEOL )
			FWrite(nHandle," Data - Hora     : " + DTOC( DATE() ) + " - " + TIME() + pEOL )
			FWrite(nHandle,Replicate( "-", 128 ) + pEOL )
		Else
			nHandle := FOPEN(cNomLog,2+64)
			nLength := FSEEK(nHandle,0,2)
		Endif

		FOR nPos := 1 TO LEN(aLogString)
			cLogString += aLogString[ nPos ]+" | "
		Next

		FWrite( nHandle, cLogString + pEOL )
		FClose( nHandle )

	ENDIF

Return


//
// Rotina para checar e criar o diretorio caso nao exista.
//
STATIC FUNCTION ExistDirectory( cPath )

	LOCAL nRetValue := 0
	LOCAL aDirTemp
	LOCAL cString   := ""
	LOCAL nPos
	LOCAL nPointer


	IF .NOT. EMPTY( cPath )
		FOR nPos := 1 to LEN( ALLTRIM( cPath ) )
			cString += SUBSTR( ALLTRIM( cPath ), nPos, 1 )

			IF SUBSTR( ALLTRIM( cPath ), nPos, 1 ) == "\" .AND. nPos <= LEN( ALLTRIM( cPath ) )
				aDirTemp := Directory( cString + "*.", "D" )
				IF ( nPointer := ASCAN( aDirTemp,{|x| x[5] == "D"})) == 0
					IF ( nRetValue := MakeDir( cString ) ) > 0
						EXIT
					ENDIF
				ENDIF
			ENDIF

		NEXT
	ENDIF

RETURN( nRetValue )


User Function AceDigit()
	Local aPergs   := {}
	Local cCodFor  := space(06)
	Local cRecDest := space(340)
	Local cArquivo := padr("",150)
	Local aRet	   := {}

	aAdd( aPergs ,{1,"Código do Fornecedor",Space(9),"@!",,"SA2",'.T.',20,.T.})
	aAdd( aPergs ,{1,"Loja do Fornecedor",Space(9),"@!",,,'.T.',20,.T.})	
	aAdd( aPergs ,{1,"Nota Fiscal",Space(9),"@!",,"SF1",'.T.',20,.T.})
	aAdd( aPergs ,{1,"Série NF",Space(9),"@!",,,'.T.',20,.F.})
	aAdd( aPergs ,{1,"Data Digitação",Ctod(Space(50)),,,,'.T.',50,.T.})

	If ParamBox(aPergs ,"Atualiza Data de Digitação",aRet)

		cQuery := " UPDATE "+RetSQlName("SF1")+" SET F1_DTDIGIT='"+DtoS(aRet[5])+"'"
		cQuery += " WHERE F1_FORNECE='"+Alltrim(aRet[1])+"' AND F1_LOJA='"+Alltrim(aRet[2])+"' 
		cQuery += " AND F1_DOC ='"+Alltrim(aRet[3])+"' AND F1_SERIE ='"+Alltrim(aRet[4])+"' AND D_E_L_E_T_<>'*'"

		If TCSQLExec(cQuery) < 0
			MsgStop( "TCSQLError() " + TCSQLError(), 'April Brasil' )
			Return( .F. )
		Else
			AVISO("Processo Atualizado - Cabeçalho da NF ","Atualização da NF: "+Alltrim(aRet[3])+" feita com sucesso", {"Fechar"}, 2)
		EndIf

		cQuery := " UPDATE "+RetSQlName("SD1")+" SET D1_DTDIGIT='"+DtoS(aRet[5])+"'"
		cQuery += " WHERE D1_FORNECE='"+Alltrim(aRet[1])+"' AND D1_LOJA='"+Alltrim(aRet[2])+"' 
		cQuery += " AND D1_DOC ='"+Alltrim(aRet[3])+"' AND D1_SERIE ='"+Alltrim(aRet[4])+"' AND D_E_L_E_T_<>'*'"

		If TCSQLExec(cQuery) < 0
			MsgStop( "TCSQLError() " + TCSQLError(), 'April Brasil' )
			Return( .F. )
		Else
			AVISO("Processo Atualizado - Itens da NF" ,"Atualização da NF: "+Alltrim(aRet[3])+" feita com sucesso", {"Fechar"}, 2)
		EndIf

	Else

		AVISO("Processo cancelado","Processo cancelado pelo usuário", {"Fechar"}, 2)
	EndIf
Return .T.