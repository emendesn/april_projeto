#include 'protheus.ch'
#include 'parmtype.ch'
#include 'protheus.ch'
#include 'Topconn.ch'
#INCLUDE "Protheus.CH"
#include "rwmake.ch"



user function IMPFOR()	

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

	dbSelectArea("SA2")
	SA2->(dbSetOrder(3))


	For i:=1 to Len(aDados)

		oProcess:IncRegua1("Fornecedor: "+Alltrim(aDados[i,2]))

		aDadosFor   := {}

		cQuery := " SELECT * FROM "+RetSQlName("CC2")+" WHERE D_E_L_E_T_<>'*' AND CC2_EST='"+Alltrim(aDados[i,6])+"' AND CC2_MUN='"+FwNoAccent(Alltrim(aDados[i,8]))+"'"
		If Select("TRB2") <> 0
			dbSelectArea("TRB2")
			dbCloseArea()
		EndIf

		TCQuery cQuery New Alias "TRB2"

		If !SA2->(Dbseek(xFilial("SA2")+alltrim(aDados[i,17])))
			AADD(aDadosFor,{"A2_COD",GetSxeNum("SA2","A2_COD")})                                                                                                      
			AADD(aDadosFor,{"A2_LOJA","01" })
			AADD(aDadosFor,{"A2_NOME", Substr(Alltrim(aDados[i,3]),1,TAMSX3("A2_NOME")[1])})
			AADD(aDadosFor,{"A2_NREDUZ", Substr(Alltrim(aDados[i,2]),1,TAMSX3("A2_NREDUZ")[1])})
			AADD(aDadosFor,{"A2_END",Substr(Alltrim(aDados[i,4]),1,TAMSX3("A2_END")[1])})
			AADD(aDadosFor,{"A2_BAIRRO ",Substr(Alltrim(aDados[i,5]),1,TAMSX3("A2_BAIRRO")[1])})
			AADD(aDadosFor,{"A2_EST ", Alltrim(aDados[i,6])})
			AADD(aDadosFor,{"A2_MUN", FwNoAccent(Alltrim(aDados[i,8]))})
			AADD(aDadosFor,{"A2_CEP",PadL(StrTran(Alltrim(aDados[i,9]),"-",""),TAMSX3("A2_CEP")[1],"0") })
			AADD(aDadosFor,{"A2_TIPO",Alltrim(aDados[i,20])})
			AADD(aDadosFor,{"A2_CGC",Alltrim(aDados[i,17])})
			AADD(aDadosFor,{"A2_CONTA", "2110020003"   })   //Questionar Controladoria    
			AADD(aDadosFor,{"A2_DDD", Substr(StrTran(StrTran(Alltrim(aDados[i,11]),"(",""),")",""),1,2)	})	
			AADD(aDadosFor,{"A2_TEL",Substr(StrTran(StrTran(Alltrim(aDados[i,11]),"(",""),")",""),3,8)})
			AADD(aDadosFor,{"A2_COD_MUN",TRB2->CC2_CODMUN})
			AADD(aDadosFor,{"A2_PAIS","105"})
			AADD(aDadosFor,{"A2_CODPAIS","01058"})
			AADD(aDadosFor,{"A2_INSCR ", Alltrim(aDados[i,16])})
			AADD(aDadosFor,{"A2_EMAIL ",Substr(Alltrim(aDados[i,34]),1,TAMSX3("A2_EMAIL")[1])})
			AADD(aDadosFor,{"A2_BANCO ", Substr(Alltrim(aDados[i,21]),1,TAMSX3("A2_BANCO")[1])})
			AADD(aDadosFor,{"A2_AGENCIA ", Substr(Alltrim(aDados[i,22]),1,TAMSX3("A2_AGENCIA")[1])})
			AADD(aDadosFor,{"A2_DVAGE", SUBSTR(Alltrim(aDados[i,22]),Len(Alltrim(aDados[i,22])),Len(Alltrim(aDados[i,22]))-1)})
			AADD(aDadosFor,{"A2_NUMCON  ",cValtoChar(Val(SUBSTR(Alltrim(aDados[i,23]),1,Len(Alltrim(aDados[i,23]))-1)))})
			AADD(aDadosFor,{"A2_DVCTA",SUBSTR(Alltrim(aDados[i,23]),Len(Alltrim(aDados[i,23])),Len(Alltrim(aDados[i,23]))-1)})
			AADD(aDadosFor,{"A2_TIPCTA","1"})//tIPO DE CONTA1 1= conta corrente
			AADD(aDadosFor,{"A2_CODNIT",""})
			AADD(aDadosFor,{"A2_CATEG",""})
			AADD(aDadosFor,{"A2_OCORREN","T"})
			AADD(aDadosFor,{"A2_XCODTAV",Alltrim(aDados[i,1])})
			AADD(aDadosFor,{"A2_PFISICA",""})

			lMsErroAuto := .F.
			aVetor := FWVetByDic( aDadosFor, 'SA2' )
			MsExecAuto({|x,y| MATA020(x,y)},aVetor, 3)	
			//Caso encontre erro exibir na tela
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
			cCod := Soma1(cCod)
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