#include 'protheus.ch'
#include 'parmtype.ch'
#include 'Topconn.ch'
#include 'parmtype.ch'
#INCLUDE "Protheus.CH"
#include "rwmake.ch"



user function IMPSE2()

	Local aArea  	:= GetArea()
	Local cTitulo	:= "Importação Cosmos"
	Local nOpcao 	:= 0
	Local aButtons 	:= {}
	Local aSays    	:= {}
	Local cPerg		:= "CLI001"
	Private cArquivo:= ""
	Private oProcess
	Private lRenomeabr:= .F.
	Private lMsErroAuto := .F.

	ajustaSx1(cPerg)

	Pergunte(cPerg,.F.)

	AADD(aSays,OemToAnsi("Rotina para Importação de arquivo texto para tabela SE2"))
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

	dbSelectArea("SE2")
	SE2->(dbSetOrder(1))

	DbSelectArea("SE1")
	SE1->(DbSetOrder(1))


	For i:=1 to Len(aDados)

		oProcess:IncRegua1("Importando Titulo..."+Alltrim(aDados[i,4]))

		aCab   := {}
		aItens := {}

		If Empty(aDados[i,1])
			Return
		EndIf

		aCliente := {}
		If Upper(Alltrim(aDados[i,17]))== 'P'

			dbSelectArea("SE2")
			SE2->(dbSetOrder(1))

			cQuery := " SELECT COUNT(*) AS TOT FROM "+RetSQlName("SE2")+" WHERE D_E_L_E_T_<>'*' AND E2_TIPO='"+Alltrim(aDados[i,18])+"'AND E2_NUM='"+aDados[i,8]+"'"
			If Select("TRB2") <> 0
				dbSelectArea("TRB2")
				TRB2->(dbCloseArea())
			EndIf

			TCQuery cQuery New Alias "TRB2"
			nValor := 0
			nTaxas := 0
			nIof := 0
			nTotal := 0
			nVlCruz := 0
			
			If TRB2->TOT < 1

					nValor := Val(StrTran(aDados[i,4],',','.'))
					nTaxas := Val(StrTran(aDados[i,14],',','.')) 
					nIof   := Val(StrTran(aDados[i,15],',','.')) 	
					nTotal := Val(StrTran(aDados[i,22],',','.')) 
					nVlCruz:= (Val(StrTran(aDados[i,4],',','.')) * Val(StrTran(aDados[i,6],',','.')))
				
				Reclock("SE2",.T.)
				SE2->E2_FILIAL :=  "0101"	

				SE2->E2_PREFIXO :=  "SUP"		 	
				SE2->E2_NUM     :=aDados[i,8]	
				SE2->E2_TIPO   := aDados[i,20]
				SE2->E2_NATUREZ:= aDados[i,9] 	
				SE2->E2_PARCELA:= ""			
				SE2->E2_FORNECE:= PADL(ALLTRIM(aDados[i,2]),6,"0") 	
				SE2->E2_NOMFOR := Substr(Posicione("SA2",1,xFilial("SA2")+PADL(ALLTRIM(aDados[i,2]),6,"0") +"01","A2_NOME"),1,20) 
				SE2->E2_LOJA   := "01"	 		
				SE2->E2_EMISSAO:= CtoD(aDados[i,10])  
				SE2->E2_VENCTO := Ctod(aDados[i,11])  
				SE2->E2_VENCREA:= Ctod(aDados[i,11])  
				SE2->E2_VALOR  := nValor	
				SE2->E2_SALDO  := nValor	
				SE2->E2_VLCRUZ := nVlCruz
				SE2->E2_HIST   := aDados[i,7] 	
				SE2->E2_XCASEID:= aDados[i,12]	
				SE2->E2_XPARTN := aDados[i,13] 	
				SE2->E2_XTAXAS := nTaxas
				SE2->E2_XVLIOF := nIof	
				SE2->E2_MOEDA  := Val(aDados[i,5]) 	
				SE2->E2_TXMOEDA:= Val(StrTran(aDados[i,6],',','.')) 	
				SE2->E2_XNUMID := Alltrim(aDados[i,16]) 	
				SE2->E2_XDTBX  := CtoD(aDados[i,19]) 	
				SE2->E2_XNOME  := ALLTRIM(aDados[i,21])	
				SE2->E2_XVLBRL := nTotal
				SE2->E2_XCODCOS := ALLTRIM(aDados[i,23])
				SE2->E2_XNSUPPL := ALLTRIM(aDados[i,21])
				MsUnlock()
				//lMsErroAuto := .F.
				//aCliente := FWVetByDic( aCliente, 'SE2' )
				//MsExecAuto( { |x,y,z| FINA050(x,y,z)}, aCliente,, 3) 

			Else
				dbSelectArea("SE1")
				SE1->(dbSetOrder(1))

				aAdd(aCliente,{ "E1_PREFIXO" 	, "INT"		 	, NIL })
				aAdd(aCliente,{ "E1_NUM" 		, aDados[i,8]	, NIL })
				aAdd(aCliente,{ "E1_TIPO" 		, "TF"		 	, NIL })
				aAdd(aCliente,{ "E1_NATUREZ" 	, aDados[i,9] 	, NIL })
				aAdd(aCliente,{ "E1_PARCELA" 	, ""			, NIL })
				aAdd(aCliente,{ "E1_CLIENTE" 	, aDados[i,2] 	, NIL	 })
				aAdd(aCliente,{ "E1_LOJA" 		, "01"	 		, NIL })
				aAdd(aCliente,{ "E1_EMISSAO" 	, CtoD(aDados[i,10])  , NIL })//
				aAdd(aCliente,{ "E1_VENCTO" 	, Ctod(aDados[i,11])  , NIL })//Verificar Regra de Vencimento. dEmissao
				aAdd(aCliente,{ "E1_VALOR" 		, Val(StrTran(aDados[i,4],',','.'))	, NIL })
				aAdd(aCliente,{ "E1_HIST" 		, Upper(aDados[i,7]) 	, NIL })
				aAdd(aCliente,{ "E1_XCASENU" 	, Upper(aDados[i,12])	, NIL })
				aAdd(aCliente,{ "E1_XPARTNE" 	, Upper(aDados[i,13]) 	, NIL })
				aAdd(aCliente,{ "E1_XVLRBAN" 	, Val(StrTran(aDados[i,14],',','.')) 	, NIL })
				aAdd(aCliente,{ "E1_XDESPB" 	, Val(StrTran(aDados[i,18],',','.')) 	, NIL })
				aAdd(aCliente,{ "E1_XVLRIOF" 	, Val(StrTran(aDados[i,15],',','.')) 	, NIL })
				aAdd(aCliente,{ "E1_MOEDA" 		, Val(aDados[i,5]) 	, NIL })
				aAdd(aCliente,{ "E1_TXMOEDA"	, Val(StrTran(aDados[i,6],',','.')) 	, NIL })
				aAdd(aCliente,{ "E1_XNUMID" 	, Alltrim(aDados[i,16]) 	, NIL })
				aAdd(aCliente,{ "E1_XTPFAT" 	, "C" 	, NIL })
				aAdd(aCliente,{ "E1_XMODFAT" 	, "C" 	, NIL })

				lMsErroAuto := .F.
				aCliente := FWVetByDic( aCliente, 'SE1' )
				MsExecAuto( { |x,y| FINA040(x,y)}, aCliente, 3) 
			Endif

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