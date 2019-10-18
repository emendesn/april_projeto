#include 'protheus.ch'
#include 'parmtype.ch'
#include 'topconn.ch'

user function IMPSA1()
	Local aArea  	:= GetArea()
	Local cTitulo	:= "Importação Cadastro de Notas"
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

	//utilizaremos a aScan para localizar a posição dos campos na variavel que armazenará o nome dos campos
	nPosCod    	:= aScan(aCampos,{ |x| ALLTRIM(x) == "A1_COD" })
	nPosLoja   	:= aScan(aCampos,{ |x| ALLTRIM(x) == "A1_LOJA" })
	nPosNome   	:= aScan(aCampos,{ |x| ALLTRIM(x) == "A1_NOME" })
	nPosEst    	:= aScan(aCampos,{ |x| ALLTRIM(x) == "A1_EST" })
	nPosCodMun 	:= aScan(aCampos,{ |x| ALLTRIM(x) == "A1_COD_MUN" })
	nPessoa 	:= aScan(aCampos,{ |x| ALLTRIM(x) == "A1_PESSOA" })

	oProcess:SetRegua1(len(aDados)) //guardar novamente a quantidade de registros

	For i:=2 to Len(aDados)

		oProcess:IncRegua1("Importando clientes..."+aDados[i,38])

		aCliente := {}
		aAI0Auto  := {}

		dbSelectArea("SA1")
		SA1->(dbSetOrder(3))

		dbSelectArea("SF2")
		SF2->(dbSetOrder(1))


		//Tratamento para SP ou RJ
		If Alltrim(SM0->M0_CODFIL) == '0101'
			//Dados do Cliente
			cCnpj1  :=StrTran(aDados[i,35],"-","")
			cPessoa :=Iif(aDados[i,34]=='1',"F","J") 
			cInscM  :=aDados[i,36]
			cInscE  :=If(Empty(aDados[i,37]),"ISENTO",aDados[i,37])
			cEndereco := IIF(Empty(Upper(FwNoAccent(aDados[i,39]))),Alltrim(Upper(FwNoAccent(aDados[i,39])))+" "+Substr(Upper(FwNoAccent(aDados[i,40])),1,TAMSX3("A1_END")[1]),Substr(Upper(FwNoAccent(aDados[i,40])),1,TAMSX3("A1_END")[1]))
			cNumEnd  :=aDados[i,41]
			cComplem :=aDados[i,42]
			cNome   :=Substr(Upper(aDados[i,38]),1,TAMSX3("A1_NOME")[1])
			cNReduz :=Substr(Upper(aDados[i,38]),1,TAMSX3("A1_NREDUZ")[1])
			cCep    :=STRZERO(VAL(StrTran(aDados[i,46],"-","")),8)
			cEst    := aDados[i,45]
			cMun    :=Upper(FwNoAccent(aDados[i,44]))
			cBairro :=Upper(FwNoAccent(aDados[i,43]))
			cEmail  :=Substr(Upper(aDados[i,47]),1,TAMSX3("A1_EMAIL")[1]) 
			//Dados da NF
			cNumDoc  := aDados[i,2]
			dEmissao := CtoD(aDados[i,8])
			cCodPro  :="SP000000000"+aDados[i,29]
			nPreco   :=Val(StrTran(aDados[i,27],",","."))
			cCnpj2 :=StrTran(cCnpj1,"/","")
			cCnpj3 :=StrTran(cCnpj2,".","")
			If(aDados[i,34])=='1'
				cCnpj := STRZERO(VAL(StrTran(cCnpj3,"/","")),11)
			Else
				cCnpj := STRZERO(VAL(StrTran(cCnpj3,"/","")),14) 
			EndIf

		Else // RJ
			//Dados do Cliente
			cCnpj1  :=StrTran(aDados[i,27],"-","")
			cPessoa :=Iif(aDados[i,26]=='1',"F","J") 
			cInscM  :=aDados[i,28]
			cInscE  :=If(Empty(aDados[i,29]),"ISENTO",aDados[i,29])
			cEndereco := IIF(Empty(Upper(FwNoAccent(aDados[i,32]))),Alltrim(Upper(FwNoAccent(aDados[i,32])))+" "+Substr(Upper(FwNoAccent(aDados[i,32])),1,TAMSX3("A1_END")[1]),Substr(Upper(FwNoAccent(aDados[i,32])),1,TAMSX3("A1_END")[1]))
			cNumEnd  :=aDados[i,33]
			cComplem :=aDados[i,34]
			cNome   :=Substr(Upper(aDados[i,30]),1,TAMSX3("A1_NOME")[1])
			cNReduz :=Substr(Upper(aDados[i,30]),1,TAMSX3("A1_NREDUZ")[1])
			cCep    :=STRZERO(VAL(StrTran(aDados[i,38],"-","")),8)
			cEst    := aDados[i,37]
			cMun    :=Upper(FwNoAccent(aDados[i,36]))
			cBairro :=Upper(FwNoAccent(aDados[i,35]))
			cEmail  :=Substr(Upper(aDados[i,40]),1,TAMSX3("A1_EMAIL")[1]) 
			//Dados da NF
			cNumDoc  := aDados[i,8]
			dEmissao := CtoD(aDados[i,9])
			cCodPro  :="SP0000000000902"
			nPreco   :=Val(StrTran(aDados[i,51],",","."))
			cCnpj2 :=StrTran(cCnpj1,"/","")
			cCnpj3 :=StrTran(cCnpj2,".","")
			If(aDados[i,26])=='1'
				cCnpj := STRZERO(VAL(StrTran(cCnpj3,"/","")),11)
			Else
				cCnpj := STRZERO(VAL(StrTran(cCnpj3,"/","")),14) 
			EndIf

		EndIf



		//Neste exemplo iremos incluir registros, portanto iremos validar se o mesmo não existe na tabela de clientes

		If !SA1->(dbSeek(xFilial("SA1")+cCnpj3))
			oProcess:SetRegua2(len(aCampos))

			cQuery := " SELECT MAX(A1_COD) as A1_COD FROM "+RetSQlName("SA1")+" "
			cQuery += " WHERE  D_E_L_E_T_<>'*' "

			If Select("TRB") <> 0
				dbSelectArea("TRB")
				dbCloseArea()
			EndIf

			TCQuery cQuery New Alias "TRB"

			cCodCli := Soma1(TRB->A1_COD)
			AAdd(aCliente,{"A1_FILIAL" , xFilial("SA1"),NIL})
			AAdd(aCliente,{"A1_COD" , cCodCli,NIL})
			AAdd(aCliente,{"A1_LOJA" ,"01" ,NIL})
			AAdd(aCliente,{"A1_PESSOA",cPessoa ,NIL})
			aAdd(aCliente,{"A1_TIPO"    ,"F"       ,Nil})	
			AAdd(aCliente,{"A1_CGC"	,cCnpj,NIL})
			AAdd(aCliente,{"A1_INSCRM"	,cInscM ,NIL})
			AAdd(aCliente,{"A1_INSCR",cInscE ,NIL})	
			AAdd(aCliente,{"A1_NOME"	,cNome ,NIL})
			AAdd(aCliente,{"A1_NREDUZ"	,cNReduz ,NIL})
			AAdd(aCliente,{"A1_END"	,cEndereco ,NIL})
			AAdd(aCliente,{"A1_NR_END"	,cNumEnd ,NIL})
			AAdd(aCliente,{"A1_COMPLEM"	,cComplem ,NIL})
			AAdd(aCliente,{"A1_BAIRRO",cBairro ,NIL})
			AAdd(aCliente,{"A1_EST"	  ,cEst ,NIL})	
			AAdd(aCliente,{"A1_MUN"	 ,cMun,NIL})
			AAdd(aCliente,{"A1_CEP"	 ,cCep ,NIL})
			AAdd(aCliente,{"A1_EMAIL",cEmail,NIL})

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
		EndIf

		If SA1->(dbSeek(xFilial("SA1")+cCnpj3)) //Importa a NF para o MATA920
			cSerie:= If(xFilial("SF2")=='0101',"SP1","RJ1")

			aCabec := {}
			aItens := {}
			aadd(aCabec,{"F2_FILIAL"   ,xFilial("SF2")})
			aadd(aCabec,{"F2_TIPO"   ,"N"})
			aadd(aCabec,{"F2_FORMUL" ,"S"})
			aadd(aCabec,{"F2_DOC"    ,cNumDoc})
			aadd(aCabec,{"F2_SERIE"  ,cSerie})
			aadd(aCabec,{"F2_EMISSAO",dEmissao})
			aadd(aCabec,{"F2_CLIENTE",SA1->A1_COD})
			aadd(aCabec,{"F2_LOJA"   ,"01"})
			aadd(aCabec,{"F2_ESPECIE","NFS"})
			aadd(aCabec,{"F2_COND","001"})
			aadd(aCabec,{"F2_DESCONT",0})
			aadd(aCabec,{"F2_FRETE",0})
			aadd(aCabec,{"F2_SEGURO",0})
			aadd(aCabec,{"F2_DESPESA",0})

			aLinha := {}
			aadd(aLinha,{"D2_ITEM" ,StrZero(i,2),Nil})
			aadd(aLinha,{"D2_COD"  ,cCodPro,Nil})
			aadd(aLinha,{"D2_QUANT",1,Nil})
			aadd(aLinha,{"D2_PRCVEN",nPreco,Nil})
			aadd(aLinha,{"D2_TOTAL",nPreco,Nil})
			aadd(aLinha,{"D2_TES","502",Nil})
			aadd(aItens,aLinha)

			aCabec2 := FWVetByDic( aCabec, 'SF2' )
			//aItens2 := FWVetByDic( aItens, 'SD2' )
			//-- Teste de Inclusao
			If !SF2->(DbSeek(xFilial("SF2")+cNumDoc))
				MATA920(aCabec2,aItens)

				If !lMsErroAuto
					ConOut("Incluido com sucesso!")
				Else
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
			Else
				If !Empty(Alltrim(aDados[i,24]))
					MATA920(aCabec2,aItens,5)
					If !lMsErroAuto
						ConOut("Incluido com sucesso!")
					Else
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
				EndIf
			EndIf

		Else
			cErro+="Linha: "+Alltrim(Str(i))+" - Cliente não encontrado | "
		EndIf

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