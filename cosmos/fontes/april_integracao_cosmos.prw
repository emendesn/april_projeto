#include "rwmake.ch"
#include "protheus.ch"
#include "topconn.ch"
#include "totvs.ch"
#include "fileio.ch"
#include "fwmvcdef.ch"

//#################
//# Programa      # INTCOSMO
//# Data          # 19/06/2018
//# Descrição     # Integração Arquivos CSV Cosmos
//# Desenvolvedor # Elias Silva
//# Empresa       # Totvs Nacoes Unidas
//# Linguagem     # Advpl     
//# Versão        # 12
//# Sistema       # Protheus
//# Módulo        # 
//# Tabelas       # 
//# Observação    #  
//#===============#
//# Atualizações  # 
//#===============#
//#################


User Function IntCosmo()

	//Declarar variáveis locais
	Local oColumn
	Local nX
	Local lMarcar  	:= .F.
	Local cPerg		:= "INTCOSMO"

	//Declarar variáveis privadas
	Private oBrowse 	:= Nil
	Private cCadastro 	:= "Integração COSMOS"
	Private aRotina	 	:= Menudef() //Se for criar menus via MenuDef
	Private cMarc		:= "XX"

	oBrowse := FWMarkBrowse():New()
	oBrowse:SetDescription(cCadastro) //Titulo da Janela
	oBrowse:SetAlias("SZ7") //Indica o alias da tabela que será utilizada no Browse
	oBrowse:SetFieldMark("Z7_OK") //Indica o campo que deverá ser atualizado com a marca no registro
	oBrowse:SetMark(cMarc)
	oBrowse:oBrowse:SetDBFFilter(.T.)
	oBrowse:oBrowse:SetUseFilter(.T.) //Habilita a utilização do filtro no Browse
	oBrowse:oBrowse:SetFixedBrowse(.T.)
	oBrowse:SetWalkThru(.F.) //Habilita a utilização da funcionalidade Walk-Thru no Browse
	oBrowse:SetAmbiente(.T.) //Habilita a utilização da funcionalidade Ambiente no Browse
	oBrowse:oBrowse:SetSeek(.T.) //Habilita a utilização da pesquisa de registros no Browse
	oBrowse:oBrowse:SetFilterDefault("SZ7->Z7_STATUS=='P'") //Indica o filtro padrão do Browse

	//Indica o Code-Block executado no clique do header da coluna de marca/desmarca
	oBrowse:bAllMark := { || Inverte(oBrowse:Mark(),lMarcar := !lMarcar ), oBrowse:Refresh(.T.)  }

	oBrowse:oBrowse:Setfocus() //Seta o foco na grade
	//Método de ativação da classe
	oBrowse:Activate()

Return

//Caso crie os botões por função, abaixo seque um exemplo
Static Function MenuDef()
	Local aRot := {}

	ADD OPTION aRot TITLE "Integrar Eventos" 	ACTION "Processa({|| U_CosmoEv()},'Integração','Processando eventos')"  OPERATION 6 ACCESS 0

Return (Aclone(aRot))

//Função para marcar/desmarcar todos os registros do grid
Static Function Inverte(cMarca,lMarcar)
	Local aArea  := SZ7->(GetArea())

	dbSelectArea("SZ7")
	SZ7->( dbGoTop() )
	While !SZ7->( Eof() )
		RecLock( "SZ7", .F. )
		SZ7->Z7_OK := IIf( lMarcar, cMarca, '  ' )
		SZ7->(MsUnlock())
		SZ7->(dbSkip())
	EndDo	

	RestArea(aArea)
Return .T. 

User Function CosmoEv()
	Local aArea		:= GetArea()
	Local aAreaSZ7 	:= SZ7->(GetArea())
	Local cAliasSZ7	:= GetNextAlias()
	Local nCount	:= 0
	Local cQuebra	:= chr(13) + chr(10)

	BeginSql alias cAliasSZ7
		SELECT COUNT(Z7_OBJNUM) QTDREG FROM
		%table:SZ7% SZ7
		WHERE 
		Z7_FILIAL = %xFilial:SZ7%
		AND Z7_STATUS <> 'I'
		AND Z7_OK = 'XX'
		AND SZ7.%notDel%
	EndSql

	If !(cAliasSZ7)->(Eof())
		nCount 	:= (cAliasSZ7)->QTDREG 
		ProcRegua(nCount)
	Else
		Alert ("Não há dados")
		(cAliasSZ7)->(DbCloseArea())
		Return
	EndIf

	(cAliasSZ7)->(DbCloseArea())

	SZ7->(DbGoTop())
	SZ2->(DbGoTop())
	SZ2->(DbSetOrder(1)) // Z2_FILIAL+Z2_EVENTO+Z2_CODE+Z2_PARTID+Z2_SUPID+Z2_PRODUTO

	While !SZ7->(Eof())

		If SZ7->Z7_OK == "XX" .AND. SZ7->Z7_STATUS == "P"

			If Alltrim(SZ7->Z7_SUPID) $ GetMV("MV_CLAIMS")
				//If Alltrim(SZ7->Z7_SUPID)<>'317' //zurick reembolso
				//se for 130. april, gta e turist. ( emissão <01-01-2014 = coram.) // TPA APRIL USA PAGA NORMAL 
				Titulo("1","R")

			Else //APRIL INTERNATIONAL USA(88375) E QBE (PLANILHA VANESSA)- PARAMETRO      
				//REVALIDAÇÃO DE PAGAMENTO, BRUNA TESTAR - OK
				//FATURA NEGATIVA ( ABATER NDF) - OK VERIFICAR O CREDITO.
				//OPEN CASES - ZURICH ( THAIS REUNIÃO SEMANA QUE VEM)
				//REINVOICE EXEMPLO DE CASO BR 19028/2018        
				//(FEE) - CONTAS A RECEER ( VERIFICAR O CANCELAMENTO VALOR NEGATIVO)
				//LIABILITY /TPA APRIL BRASIL/REIMBURSEMENT FOR NECESSARY EXPENSES - GASTOS COM LIGAÇÕES TELEFONICAS ( REFLEXO DO PAID.)
				//TERCERIZAÇÃO DE SERVIÇOS DA APRIL ( 100% DESPESAS DA APRIL)
				//EXCEDEU O VALOR DA APOLICE?
				
				
			
				
				If SZ2->(dbSeek(xFilial("SZ2")+SZ7->(Z7_OBJTYPE+Z7_ACTION+Z7_PARTID+Z7_SUPID+Z7_PRDID)))


					// Fazer tratamento para gerar o evento
					If (SZ2->Z2_ACAO == '1' .or. SZ2->Z2_ACAO == '2') //Para fornecedores em Geral
						Titulo("1",SZ2->Z2_ACAO)
					Elseif (SZ2->Z2_ACAO == '3' .or. SZ2->Z2_ACAO == '4')
						PV(SZ2->Z2_ACAO)//Reinvoince
					ElseIf (SZ2->Z2_ACAO == '5' .or. SZ2->Z2_ACAO == '6')
						//Colocar e-mail do fiscal (fiscal@aprilbrasil.com.br)
						U_StartEml("Inicio Processamento Prestadores - Inicio.",Time(),"thiagomt.rocco@gmail.com","fiscal@aprilbrasil.com.br","Processamento Prestadores - Inicio")
						PC(SZ2->Z2_ACAO)//Suppliers
						U_StartEml("Fim Processamento Prestadores - Fim.",Time(),"thiagomt.rocco@gmail.com","fiscal@aprilbrasil.com.br","Processamento Prestadores - Fim")
					ElseIf (SZ2->Z2_ACAO == '7' .or. SZ2->Z2_ACAO == '8')
						TitRec(SZ2->Z2_ACAO)//Reinvoice
					Else
						Reclock("SZ7",.F.)
						SZ7->Z7_STATUS := "E"
						SZ7->Z7_LOGINT := "Regra de Ação inválida"
						SZ7->(MsUnlock())
					Endif	
				Else
					Reclock("SZ7",.F.)
					SZ7->Z7_STATUS := "E"
					SZ7->Z7_LOGINT := "Não encontrada regra definida." + cQuebra +;
					"Chave: " + cQuebra +; 
					"Filial: " + xFilial("SZ2")+ cQuebra +;
					"Object Type: " + SZ7->Z7_OBJTYPE+ cQuebra +;
					"Action: " + SZ7->Z7_ACTION+ cQuebra +;
					"Partner ID: " + SZ7->Z7_PARTID+ cQuebra +;
					"Supplier ID: " + SZ7->Z7_SUPID+ cQuebra +;
					"Product ID: " + SZ7->Z7_PRDID			
					SZ7->(MsUnlock())		

				Endif
				//Endif
				IncProc()
			Endif
		Endif
		SZ7->(DbSkip())
	End

	RestArea(aAreaSZ7)
	RestArea(aArea)	
Return
Static Function Titulo(cAcao,cTipo)
	Local lRet		:= .T.
	Local lOk		:= .T.
	Local cNumTit	:= ""
	Local cNumFor	:= ""
	Local cNumLoja	:= ""
	Local lGeraTit  := .F.
	Local cTypeBank := ""
	Local aMoeda	:= {}
	Local cPath		:= GetSrvProfString("Startpath","")
	Local aDados 	:= {}
	Local cAlias	:= GetNextAlias()
	Local aArea		:= GetArea()

	Private lMsErroAuto := .F.


	If cAcao == '1'
		//Fazer tratamento para CLAIMS
		If cTipo <>'R'
			BeginSql alias cAlias
				SELECT Z9_CODFOR, Z9_LOJA 
				FROM %table:SZ9% SZ9
				WHERE 
				Z9_FILIAL = %xFilial:SZ9%
				AND Z9_SUPID = %exp:SZ7->Z7_SUPID%
				AND LTRIM(RTRIM(Z9_CODFOR)) <> ''
				AND SZ9.%notdel%
			EndSql


			If !(cAlias)->(Eof())
				cNumFor 	:= (cAlias)->Z9_CODFOR
				cNumLoja	:= (cAlias)->Z9_LOJA
			Else
				Reclock("SZ9",.T.)
				SZ9->Z9_FILIAL := xFilial("SZ9")
				SZ9->Z9_SUPID  := SZ7->Z7_SUPID
				SZ9->Z9_SUPNAME:= SZ7->Z7_SUPNAM
				SZ9->(MsUnlock())

				Reclock("SZ7",.F.)
				SZ7->Z7_STATUS := "E"
				SZ7->Z7_LOGINT := "Não encontrado fornecedor"
				SZ7->(MsUnlock())
				lOk := .F.

			Endif

			(cAlias)->(DbCloseArea())

		Else
			aString := strtokarr (SZ7->Z7_LOCBANK, "#") 
			If aString[8] == '01'				
				cTypeBank := '1'
			Elseif aString[8] == '02'	
				cTypeBank := '2'
			Elseif aString[8] == '12'	
				cTypeBank := '1'
			Elseif aString[8] == '12'	
				cTypeBank := '2'
			Else
				cTypeBank := '1'
			Endif
			DbSelectArea("SA2")
			SA2->(DbSetOrder(3))
			If SA2->(Dbseek(xFilial("SA2")+alltrim(SZ7->Z7_TPPID)))
				cNumFor 	:= SA2->A2_COD
				cNumLoja	:= SA2->A2_LOJA
				cQuery := " UPDATE "+RetSQlName("SA2")+" SET A2_BANCO= '"+Substr(aString[3],1,3)+"'"
				cQuery += " ,A2_AGENCIA= '"+aString[4]+"', A2_DVAGE = '"+aString[5]+"',A2_NUMCON = '"+aString[6]+"' "
				cQuery += " ,A2_DVCTA= '"+aString[7]+"', A2_TIPCTA = '"+cTypeBank+"'"
				cQuery += " WHERE A2_COD='"+cNumFor+"' A2_LOJA='"+cNumLoja+"' AND D_E_L_E_T_<>'*'"

				If TCSQLExec(cQuery) < 0
					MsgStop( "TCSQLError() " + TCSQLError(), 'April Brasil' )
					Return( .F. )
				EndIf
				lGeraTit := .T.
			Else
				aDadosFor := {}
				cCod := GETSXENUM("SA2","A2_COD")
				AADD(aDadosFor,{"A2_COD",cCod})                                                                                                      
				AADD(aDadosFor,{"A2_LOJA","01" })
				AADD(aDadosFor,{"A2_NOME", Substr(Alltrim(SZ7->Z7_TPPNAME),1,TAMSX3("A2_NOME")[1])})
				AADD(aDadosFor,{"A2_NREDUZ", Substr(Alltrim(SZ7->Z7_TPPNAME),1,TAMSX3("A2_NREDUZ")[1])})
				AADD(aDadosFor,{"A2_END","ALAMEDA SANTOS,1357"})
				AADD(aDadosFor,{"A2_BAIRRO ","CERQUEIRA CESAR"})
				AADD(aDadosFor,{"A2_EST ", "SP"})
				AADD(aDadosFor,{"A2_MUN", "SAO PAULO"})
				AADD(aDadosFor,{"A2_CEP", "01419908"})
				AADD(aDadosFor,{"A2_TIPO",If(Len(alltrim(SZ7->Z7_TPPID))<=11,"F","J")})
				AADD(aDadosFor,{"A2_CGC", Alltrim(SZ7->Z7_TPPID)})
				AADD(aDadosFor,{"A2_CONTA", "2110020003"   })       
				AADD(aDadosFor,{"A2_DDD", ""	})	
				AADD(aDadosFor,{"A2_TEL",""})
				AADD(aDadosFor,{"A2_COD_MUN","50308"})
				AADD(aDadosFor,{"A2_PAIS","105"})
				AADD(aDadosFor,{"A2_CODPAIS","01058"})
				AADD(aDadosFor,{"A2_INSCR ", "ISENTO"})
				AADD(aDadosFor,{"A2_EMAIL ",""})
				AADD(aDadosFor,{"A2_BANCO ", Substr(aString[3],1,3)})
				AADD(aDadosFor,{"A2_AGENCIA ", aString[4]})
				AADD(aDadosFor,{"A2_DVAGE", aString[5]})
				AADD(aDadosFor,{"A2_NUMCON  ",aString[6]})
				AADD(aDadosFor,{"A2_DVCTA",aString[7]})
				AADD(aDadosFor,{"A2_TIPCTA",cTypeBank})//tIPO DE CONTA1 1= conta corrente
				AADD(aDadosFor,{"A2_CODNIT",""})
				AADD(aDadosFor,{"A2_CATEG",""})
				AADD(aDadosFor,{"A2_OCORREN",""})
				AADD(aDadosFor,{"A2_PFISICA",""})

				aVetor := FWVetByDic( aDadosFor, 'SA2' )
				MsExecAuto({|x,y| MATA020(x,y)},aVetor, 3)		
				//Verifique se houve erro no MsExecAuto
				If (lMsErroAuto)
					Reclock("SZ7",.F.)
					SZ7->Z7_STATUS := "E"
					SZ7->Z7_LOGINT := MemoRead(cPath + "logint.log")
					SZ7->(MsUnlock())
					RollBackSX8() // Se deu algum erro ele libera o n° do auto incremento para ser usado novamente;
				Else
					ConfirmSX8()   // Confirma se o auto incremento foi usado;
					cNumFor 	:= cCod
					cNumLoja	:= "01"	
					cQuery := " UPDATE "+RetSQlName("SA2")+" SET A2_MSBLQL ='2'"
					cQuery += " WHERE A2_COD='"+cCod+"' AND D_E_L_E_T_<>'*'"

					If TCSQLExec(cQuery) < 0
						MsgStop( "TCSQLError() " + TCSQLError(), 'April Brasil' )
						Return( .F. )
					EndIf
					lGeraTit := .T.
				EndIf	
			endIf
		endIf
		If cTipo <>'R'
			If SYF->(Dbseek(xFilial("SYF")+Alltrim(SZ7->Z7_FORCUR)))
				cMoeda :=SYF->YF_MOEFAT
			Else
				Reclock("SZ7",.F.)
				SZ7->Z7_STATUS := "E"
				SZ7->Z7_LOGINT := "Moeda não encontrada nos parametros do financeiro: " + AllTrim(SZ7->Z7_FORCUR) 
				SZ7->(MsUnlock())
				lOk := .F.
			Endif
		EndIf
		If !lOk
			Return .f.
		Endif

		// Proximo numero Titulos a Pagar
		cNumTit = NumTit(SZ2->Z2_TIPO)
		If CDOW(DATE()-1)== 'Monday' 
			dEmissao := DATE() + 1
		ElseIf CDOW(DATE()-1)== 'Tuesday'
			dEmissao := DATE() 
		ElseIf CDOW(DATE()-1)== 'Wednesday'
			dEmissao := DATE()+4 
		ElseIf CDOW(DATE()-1)== 'Thursday'
			dEmissao := DATE()+3 
		ElseIf CDOW(DATE()-1)== 'Friday'
			dEmissao := DATE()+2 
		ElseIf CDOW(DATE()-1)== 'Saturday'
			dEmissao := DATE()+1 
		ElseIf CDOW(DATE()-1)== 'Sunday'
			dEmissao := DATE() 
		EndIf
		//Acerto do Numero do Titulo baseado em Case Number

		If Substr(SZ7->Z7_PARTNAM,1,3)=='AXA'
			cModalidade := '2.04.01'
		ElseIf Substr(SZ7->Z7_PARTNAM,1,3)=='QBE'
			cModalidade := '2.02.01'
		ElseIf Substr(SZ7->Z7_PARTNAM,1,5)=='CORAM'
			cModalidade := '2.06.01'
		Else
			cModalidade := '2.07.01'
		EndIf

		If lGeraTit == .T.
			aAdd(aDados,{ "E2_PREFIXO" 		, "COS"			 	, NIL })
			aAdd(aDados,{ "E2_NUM" 			, cNumTit			, NIL })
			aAdd(aDados,{ "E2_TIPO" 		, "TF"		 		, NIL })
			aAdd(aDados,{ "E2_NATUREZ" 		, cModalidade	 	, NIL })
			aAdd(aDados,{ "E2_PARCELA" 		, "01"			 	, NIL })
			aAdd(aDados,{ "E2_FORNECE" 		, cNumFor 			, NIL })
			aAdd(aDados,{ "E2_LOJA" 		, cNumLoja 			, NIL })
			aAdd(aDados,{ "E2_EMISSAO" 		, dDataBase			, NIL })//
			aAdd(aDados,{ "E2_VENCTO" 		, SZ7->Z7_DUEDATE   , NIL })//Verificar Regra de Vencimento. dEmissao
			aAdd(aDados,{ "E2_VALOR" 		, SZ7->Z7_FORAMNT 	, NIL })
			aAdd(aDados,{ "E2_XNUMID" 		, SZ7->Z7_OBJNUM 	, NIL })
			aAdd(aDados,{ "E2_XCASEID" 		, SZ7->Z7_CASENUM 	, NIL })
			aAdd(aDados,{ "E2_XPARTN" 		, SZ7->Z7_PARTNAM 	, NIL })
			If cTipo <>'R'		
				aAdd(aDados,{ "E2_MOEDA"		, aMoeda[1]			, NIL })
				aAdd(aDados,{ "E2_TXMOEDA"		, aMoeda[2]			, NIL })
			EndIf
			MsExecAuto( { |x,y,z| FINA050(x,y,z)}, aDados,, 3) 


			If lMsErroAuto
				MostraErro(cPath, "logint.log")
				Reclock("SZ7",.F.)
				SZ7->Z7_STATUS := "E"
				SZ7->Z7_LOGINT := MemoRead(cPath + "logint.log")
				SZ7->(MsUnlock())
			Else
				RecLock("SZ7",.F.)
				SZ7->Z7_STATUS  := "I"
				SZ7->Z7_TITULOP := Alltrim(cNumTit)
				SZ7->Z7_LOGINT  := "Título incluído com sucesso!, Número: "+Alltrim(cNumTit)
				SZ7->(MsUnlock())
			Endif
		Endif
	Else
		BeginSql alias cAlias
			SELECT E2_FILIAL,E2_PREFIXO,E2_NUM,E2_PARCELA,E2_TIPO,E2_FORNECE,E2_LOJA
			FROM %table:SE2% SE2
			WHERE SE2.E2_FILIAL = %xFilial:SE2%
			AND SE2.E2_XNUMID = %exp:SZ7->Z7_ID%
			AND SE2.%notDel%
		EndSql

		If !(cAlias)->(Eof())

			aAdd(aDados,{ "E2_FILIAL" 	, (cAlias)->E2_FILIAL 		, NIL })
			aAdd(aDados,{ "E2_PREFIXO" 	, (cAlias)->E2_PREFIXO 		, NIL })
			aAdd(aDados,{ "E2_NUM" 		, (cAlias)->E2_NUM 			, NIL })
			aAdd(aDados,{ "E2_PARCELA" 	, (cAlias)->E2_PARCELA 		, NIL })
			aAdd(aDados,{ "E2_TIPO" 	, (cAlias)->E2_TIPO 		, NIL })
			aAdd(aDados,{ "E2_FORNECE"	, (cAlias)->E2_FORNECE 		, NIL })
			aAdd(aDados,{ "E2_LOJA" 	, (cAlias)->E2_LOJA 		, NIL })
			MsExecAuto( { |x,y,z| FINA050(x,y,z)}, aDados,, 5) // 3 - Inclusao, 4 - Alteração, 5 - Exclusão


			If lMsErroAuto
				MostraErro(cPath, "logint.log")
				Reclock("SZ7",.F.)
				SZ7->Z7_STATUS := "E"
				SZ7->Z7_LOGINT := MemoRead(cPath + "logint.log")
				SZ7->(MsUnlock())
			Else
				RecLock("SZ7",.F.)
				SZ7->Z7_STATUS := "I"
				SZ7->Z7_LOGINT := "Título excluído com sucesso!"
				SZ7->(MsUnlock())
			Endif

		Else
			RecLock("SZ7",.F.)
			SZ7->Z7_STATUS := "I"
			SZ7->Z7_LOGINT := "Não há dados para excluir."
			SZ7->(MsUnlock())
		Endif

	Endif
	RestArea(aArea)
Return lRet

Static Function NumTit(cTipo)
	Local cNumTit	:= ""
	Local cAlias 	:= GetNextAlias()

	BeginSql alias cAlias
		SELECT MAX(E2_NUM) E2_NUM
		FROM  %table:SE2%
		WHERE E2_FILIAL = %xFilial:SE2%
		AND E2_TIPO = 'TF' AND E2_PREFIXO='COS'
	EndSql

	If !(cAlias)->(Eof())
		cNumTit := Soma1((cAlias)->E2_NUM)
	Else

		cNumTit := "COS000001"
	Endif

	(cAlias)->(DbCloseArea())
Return cNumTit

Static Function PC(cAcao)
	Local lRet 			:= .T.
	Local aCabec 		:= {}
	Local aItens 		:= {}
	Local aLinha 		:= {}
	Local aMoeda		:= {}
	Local nX 			:= 0
	Local nY 			:= 0
	Local cDoc 			:= ""
	Local cNumFor		:= ""
	Local cNumLoja		:= ""
	Local _cMoeda		:= ""
	Local cPath			:= GetSrvProfString("Startpath","")
	Local lOk			:= .T.
	Local cMoeda        := ""
	Local cAlias		:= GetNextAlias()
	Private lMsErroAuto	:= .F.


	aCabec := {}
	aItens := {}
	If cAcao == '5'
		BeginSql alias cAlias
			SELECT Z9_CODFOR, Z9_LOJA 
			FROM %table:SZ9% SZ9
			WHERE 
			Z9_FILIAL = %xFilial:SZ9%
			AND Z9_SUPID = %exp:SZ7->Z7_SUPID%
			AND LTRIM(RTRIM(Z9_CODFOR)) <> ''
			AND SZ9.%notdel%
		EndSql


		If !(cAlias)->(Eof())
			cNumFor 	:= (cAlias)->Z9_CODFOR
			cNumLoja	:= (cAlias)->Z9_LOJA
		Else

			cQuery := " SELECT Z9_CODFOR, Z9_LOJA  FROM "+RetSQlName("SZ9")+" 
			cQuery += " WHERE D_E_L_E_T_<>'*' AND Z9_SUPID='"+SZ7->Z7_SUPID+"'"
			If Select("TRB2") <> 0
				dbSelectArea("TRB2")
				dbCloseArea()
			EndIf

			TCQuery cQuery New Alias "TRB2"

			If  TRB2->(Eof())
				Reclock("SZ9",.T.)
				SZ9->Z9_FILIAL := xFilial("SZ9")
				SZ9->Z9_SUPID  := SZ7->Z7_SUPID
				SZ9->Z9_SUPNAME:= SZ7->Z7_SUPNAM
				SZ9->(MsUnlock())

				Reclock("SZ7",.F.)
				SZ7->Z7_STATUS := "E"
				SZ7->Z7_LOGINT := "Não encontrado fornecedor"
				SZ7->(MsUnlock())
				lOk := .F.
			Else
				Reclock("SZ7",.F.)
				SZ7->Z7_STATUS := "E"
				SZ7->Z7_LOGINT := "Não encontrado fornecedor"
				SZ7->(MsUnlock())
				lOk := .F.
			Endif
		Endif

		(cAlias)->(DbCloseArea())	

		DbSelectArea("SYF")
		SYF->(DbSetOrder(1))

		If SYF->(Dbseek(xFilial("SYF")+Alltrim(SZ7->Z7_FORCUR)))
			cMoeda :=SYF->YF_MOEFAT
		Else
			Reclock("SZ7",.F.)
			SZ7->Z7_STATUS := "E"
			SZ7->Z7_LOGINT := "Moeda não encontrada nos parametros do financeiro: " + AllTrim(SZ7->Z7_FORCUR) 
			SZ7->(MsUnlock())
			lOk := .F.
		Endif
		*/

		If !lOk
			Return .f.
		Endif

		DbSelectArea("SM2")
		SM2->(DbSetOrder(1))
		SM2->(DbSeek(SZ7->Z7_INVDATE+1))
		cCampo:= Alltrim("M2_MOEDA"+cValtoChar(cMoeda))


		cDoc	:= GetNumSC7()//NumPc()

		aadd(aCabec,{"C7_NUM" 		,cDoc					,Nil})
		aadd(aCabec,{"C7_EMISSAO" 	,SZ7->Z7_INVDATE+1		,Nil})
		aadd(aCabec,{"C7_FORNECE" 	,cNumFor				,Nil})
		aadd(aCabec,{"C7_LOJA" 		,cNumLoja				,Nil})
		aadd(aCabec,{"C7_COND" 		,SZ2->Z2_CONDPG			,Nil})
		aadd(aCabec,{"C7_CONTATO" 	,"AUTO"					,Nil})
		aadd(aCabec,{"C7_FILENT" 	,xFilial("SC7")			,Nil})			
		aadd(aCabec,{"C7_XNUMID" 	,Alltrim(SZ7->Z7_OBJNUM)	,Nil})
		aadd(aCabec,{"C7_XOBJEXTN" 	,Alltrim(SZ7->Z7_OBJEXTN)	,Nil})
		aadd(aCabec,{"C7_XCASE" 	,Alltrim(SZ7->Z7_CASENUM),Nil})	
		aadd(aCabec,{"C7_XPART" 	,Alltrim(SZ7->Z7_PARTNAM),Nil})		
		aadd(aCabec,{"C7_MOEDA" 	,If(!Empty(cMoeda),cMoeda,"1"),Nil})		
		aadd(aCabec,{"C7_TXMOEDA" 	,If(!Empty(cMoeda) .AND. cMoeda <> 1 ,SM2->&cCampo,1)				,Nil})	
		//Usar a taxa do banco central.

		aLinha := {}
		aadd(aLinha,{"C7_PRODUTO" 	,SZ2->Z2_PRODID			,Nil})
		aadd(aLinha,{"C7_QUANT" 	,1 						,Nil})
		aadd(aLinha,{"C7_PRECO" 	,SZ7->Z7_FORAMNT 		,Nil})
		aadd(aLinha,{"C7_TOTAL" 	,SZ7->Z7_FORAMNT		,Nil})
		aadd(aLinha,{"C7_TES" 		,SZ2->Z2_TES 			,Nil})
		aadd(aItens,aLinha)

		MATA120(1,aCabec,aItens,3)
		If lMsErroAuto
			MostraErro(cPath, "logint.log")
			Reclock("SZ7",.F.)
			SZ7->Z7_STATUS := "E"
			SZ7->Z7_LOGINT := MemoRead(cPath+"logint.log")
			SZ7->(MsUnlock())
		Else
			RecLock("SZ7",.F.)
			SZ7->Z7_STATUS := "I"
			SZ7->Z7_LOGINT := "Pedido de Compra com sucesso, Número: "+Alltrim(cDoc)
			SZ7->Z7_PEDCOM := Alltrim(cDoc)
			SZ7->(MsUnlock())
		EndIf

		//Caso o Fornecedor seja internacional, gerar o documento de entrada com a Invoice.

		If Posicione("SA2",1,xFilial("SA2")+cNumFor+cNumLoja,"A2_TIPO") == 'X' // Outros
			//Inicia a criação do documento de entrada.

			aCab 	  := {}
			aItem 	  := {}
			aItens 	  := {}
			aItensRat := {}
			aCodRet   := {}
			nOpc      := 3 

			//Capturo o pedido de compras
			cQuery := " SELECT *  FROM "+RetSQlName("SC7")+" 
			cQuery += " WHERE D_E_L_E_T_<>'*' AND C7_NUM='"+cDoc+"'"
			If Select("TRB") <> 0
				dbSelectArea("TRB")
				dbCloseArea()
			EndIf

			TCQuery cQuery New Alias "TRB"

			//Cabeçalho
			aadd(aCab,{"F1_TIPO" ,"N" ,NIL})
			aadd(aCab,{"F1_FORMUL" ,"N" ,NIL})
			aadd(aCab,{"F1_DOC" ,Iif(Empty(Alltrim(TRB->C7_XOBJEXTN)),TRB->C7_NUM,TRB->C7_XOBJEXTN) ,NIL})
			aadd(aCab,{"F1_SERIE" ,"1 " ,NIL})
			aadd(aCab,{"F1_EMISSAO" ,StoD(TRB->C7_EMISSAO) ,NIL})
			aadd(aCab,{"F1_DTDIGIT" ,StoD(TRB->C7_EMISSAO) ,NIL})
			aadd(aCab,{"F1_FORNECE" ,TRB->C7_FORNECE ,NIL})
			aadd(aCab,{"F1_LOJA" ,TRB->C7_LOJA ,NIL})
			aadd(aCab,{"F1_ESPECIE" ,"INV" ,NIL})
			aadd(aCab,{"F1_COND" ,TRB->C7_COND,NIL})
			aadd(aCab,{"F1_DESPESA" ,0 ,NIL})
			aadd(aCab,{"F1_DESCONT" , 0 ,Nil})
			aadd(aCab,{"F1_SEGURO" , 0 ,Nil})
			aadd(aCab,{"F1_FRETE" , 0 ,Nil})
			aadd(aCab,{"F1_MOEDA" , TRB->C7_MOEDA ,Nil})
			aadd(aCab,{"F1_TXMOEDA" , TRB->C7_TXMOEDA ,Nil})
			aadd(aCab,{"F1_STATUS" , "A" ,Nil})

			//Itens
			For nX := 1 To 1
				aItem := {}
				aadd(aItem,{"D1_ITEM" ,TRB->C7_ITEM ,NIL})
				aadd(aItem,{"D1_COD" ,TRB->C7_PRODUTO ,NIL})
				aadd(aItem,{"D1_UM" ,TRB->C7_UM ,NIL})
				aadd(aItem,{"D1_LOCAL" ,"01" ,NIL})
				aadd(aItem,{"D1_QUANT" ,TRB->C7_QUANT ,NIL}) 
				aadd(aItem,{"D1_VUNIT" ,TRB->C7_PRECO,NIL}) 
				aadd(aItem,{"D1_TOTAL" ,TRB->C7_TOTAL ,NIL})
				aadd(aItem,{"D1_TES" ,"013" ,NIL})
				aAdd(aItens,aItem)
			Next nX
			MSExecAuto({|x,y,z,a,b| MATA103(x,y,z,,,,,a,,,b)},aCab,aItens,nOpc)

			If lMsErroAuto
				MostraErro()
			Else
				Alert("OK")
			EndIf
		Else
			//Manda e-mail para o fiscal avisando que tem pedido com prestado nacional.

		Endif
	Else

		BeginSql alias cAlias
			SELECT C7_NUM FROM %table:SC7% SC7
			WHERE C7_FILIAL = %xFilial:SC7%
			AND C7_XNUMID = %exp:SZ7->Z7_ID%
			AND SC7.%notdel%
		EndSql

		If !(cAlias)->(EOF())
			SC7->(DbSetOrder(1))
			If SC7->(DbSeek(xFilial("SC7")+(cAlias)->C7_NUM))

				aCabec := {}
				aItens := {}
				aadd(aCabec,{"C7_NUM" 		,SC7->C7_NUM			,Nil})
				aadd(aCabec,{"C7_EMISSAO" 	,SC7->C7_EMISSAO		,Nil})
				aadd(aCabec,{"C7_FORNECE" 	,SC7->C7_FORNECE		,Nil})
				aadd(aCabec,{"C7_LOJA" 		,SC7->C7_LOJA			,Nil})
				aadd(aCabec,{"C7_COND" 		,SC7->C7_COND			,Nil})

				cNumPc	:=  SC7->C7_NUM

				While !SC7->(Eof()) .and. SC7->C7_NUM == cNumPc 
					aLinha := {}
					aadd(aLinha,{"C7_ITEM"		,SC7->C7_ITEM		,Nil})
					aadd(aLinha,{"C7_PRODUTO"	,SC7->C7_PRODUTO	,Nil})
					aadd(aLinha,{"C7_QUANT"		,SC7->C7_QUANT		,Nil})
					aadd(aLinha,{"C7_PRECO"		,SC7->C7_PRECO		,Nil})
					aadd(aLinha,{"C7_TOTAL"		,SC7->C7_TOTAL		,Nil})
					aadd(aLinha,{"C7_REC_WT" 	,SC7->(RECNO()) 	,Nil})
					aadd(aItens,aLinha)
					SC7->(DbSkip())
				End
				MATA120(1,aCabec,aItens,5)
				If lMsErroAuto
					MostraErro(cPath, "logint.log")
					Reclock("SZ7",.F.)
					SZ7->Z7_STATUS := "E"
					SZ7->Z7_LOGINT := MemoRead(cPath+"logint.log")
					SZ7->(MsUnlock())
				Else
					RecLock("SZ7",.F.)
					SZ7->Z7_STATUS := "I"
					SZ7->Z7_LOGINT := "Pedido de Compra excluido com sucesso! Número: "+Alltrim(SC7->C7_NUM)
					SZ7->(MsUnlock())
				EndIf

			Endif
		Endif
		(cAlias)->(DbCloseArea())
	Endif
Return lRet

Static Function TitRec(cAcao)
	Local lRet		:= .T.
	Local lOk		:= .T.
	Local cNumTit	:= ""
	Local cNumCli	:= ""
	Local cNumLoja	:= ""
	Local aMoeda	:= {}
	Local cPath		:= GetSrvProfString("Startpath","")
	Local aDados 	:= {}
	Local cAlias	:= GetNextAlias()
	Local aArea		:= GetArea()

	Private lMsErroAuto := .F.


	If cAcao == '7'

		BeginSql alias cAlias
			SELECT Z9_CODFOR, Z9_LOJA
			FROM %table:SZ9% SZ9
			WHERE 
			Z9_FILIAL = %xFilial:SZ9%
			AND Z9_SUPID = %exp:SZ7->Z7_PARTID%
			AND SZ9.%notdel%
		EndSql


		If !(cAlias)->(Eof())
			cNumCli 	:= (cAlias)->Z9_CODFOR
			cNumLoja	:= (cAlias)->Z9_LOJA
		Else
			Reclock("SZ9",.T.)
			SZ9->Z9_FILIAL := xFilial("SZ9")
			SZ9->Z9_SUPID  := SZ7->Z7_SUPID
			SZ9->Z9_SUPNAME:= SZ7->Z7_SUPNAM
			SZ9->(MsUnlock())

			Reclock("SZ7",.F.)
			SZ7->Z7_STATUS := "E"
			SZ7->Z7_LOGINT := "Não encontrado fornecedor"
			SZ7->(MsUnlock())
			lOk := .F.

		Endif

		(cAlias)->(DbCloseArea())

		DbSelectArea("SYF")
		SYF->(DbSetOrder(1))

		If SYF->(Dbseek(xFilial("SYF")+Alltrim(SZ7->Z7_FORCUR)))
			cMoeda :=SYF->YF_MOEFAT
		Else
			Reclock("SZ7",.F.)
			SZ7->Z7_STATUS := "E"
			SZ7->Z7_LOGINT := "Moeda não encontrada nos parametros do financeiro: " + AllTrim(SZ7->Z7_FORCUR) 
			SZ7->(MsUnlock())
			lOk := .F.
		Endif

		If !lOk
			Return .f.
		Endif

		// Proximo numero Titulos a Pagar
		cNumTit = NumSE1("INV")

		aAdd(aDados,{ "E1_PREFIXO" 		, SZ2->Z2_PREFIXO 	, NIL })
		aAdd(aDados,{ "E1_NUM" 			, cNumTit 			, NIL })
		aAdd(aDados,{ "E1_TIPO" 		, SZ2->Z2_TIPO 		, NIL })
		aAdd(aDados,{ "E1_NATUREZ" 		, SZ2->Z2_NATUREZ 	, NIL })
		aAdd(aDados,{ "E1_CLIENTE" 		, cNumCli 			, NIL })
		aAdd(aDados,{ "E1_LOJA" 		, cNumLoja 																, NIL })
		aAdd(aDados,{ "E1_EMISSAO" 		, iiF(SZ7->Z7_DUEDATE<SZ7->Z7_ACTDATE,SZ7->Z7_DUEDATE,SZ7->Z7_ACTDATE)	, NIL })
		aAdd(aDados,{ "E1_VENCTO" 		, SZ7->Z7_DUEDATE 	, NIL })
		aAdd(aDados,{ "E1_VALOR" 		, SZ7->Z7_FORAMNT 	, NIL })
		aAdd(aDados,{ "E1_XNUMID" 		, SZ7->Z7_OBJNUM	, NIL })	
		aAdd(aDados,{ "E1_XCASENU" 		, SZ7->Z7_CASENUM	, NIL })	
		aAdd(aDados,{ "E1_XPARTNE" 		, SZ7->Z7_PARTNAM	, NIL })	
		aAdd(aDados,{ "E1_MOEDA" 		, If(!Empty(cMoeda),cMoeda,"1") 		, NIL })
		aAdd(aDados,{ "E1_TXMOEDA" 		, If(!Empty(cMoeda) .AND. !Empty(cMoeda),Round((C/SZ7->Z7_FORAMNT),2),0)		, NIL })	


		MsExecAuto( { |x,y| FINA040(x,y)}, aDados, 3) 

		If lMsErroAuto
			MostraErro(cPath, "logint.log")
			Reclock("SZ7",.F.)
			SZ7->Z7_STATUS := "E"
			SZ7->Z7_LOGINT := MemoRead(cPath + "logint.log")
			SZ7->(MsUnlock())
		Else
			RecLock("SZ7",.F.)
			SZ7->Z7_STATUS := "I"
			SZ7->Z7_LOGINT := "Título incluído com sucesso!"
			SZ7->(MsUnlock())
		Endif
	Else
		BeginSql alias cAlias
			SELECT E1_FILIAL,E1_PREFIXO,E1_NUM,E1_PARCELA,E1_TIPO,E1_CLIENTE,E1_LOJA
			FROM %table:SE1% SE1
			WHERE SE1.E1_FILIAL = %xFilial:SE1%
			AND SE1.E1_XNUMID = %exp:SZ7->Z7_ID%
			AND SE1.%notDel%
		EndSql

		If !(cAlias)->(Eof())


			DbSelectArea("SE1")  
			DbSetOrder(1)
			DbSeek((cAlias)->E1_FILIAL+(cAlias)->E1_PREFIXO+(cAlias)->E1_NUM+(cAlias)->E1_PARCELA+(cAlias)->E1_TIPO) //Exclusão deve ter o registro SE1 posicionado

			aAdd(aDados,{ "E1_FILIAL" 	, (cAlias)->E1_FILIAL 		, NIL })
			aAdd(aDados,{ "E1_PREFIXO" 	, (cAlias)->E1_PREFIXO 		, NIL })
			aAdd(aDados,{ "E1_NUM" 		, (cAlias)->E1_NUM 			, NIL })
			aAdd(aDados,{ "E1_PARCELA" 	, (cAlias)->E1_PARCELA 		, NIL })
			aAdd(aDados,{ "E1_TIPO" 	, (cAlias)->E1_TIPO 		, NIL })
			aAdd(aDados,{ "E1_CLIENTE"	, (cAlias)->E1_CLIENTE		, NIL })
			aAdd(aDados,{ "E1_LOJA" 	, (cAlias)->E1_LOJA 		, NIL })
			MsExecAuto( { |x,y| FINA040(x,y)}, aDados, 5) // 3 - Inclusao, 4 - Alteração, 5 - Exclusão

			If lMsErroAuto
				MostraErro(cPath, "logint.log")
				Reclock("SZ7",.F.)
				SZ7->Z7_STATUS := "E"
				SZ7->Z7_LOGINT := MemoRead(cPath + "logint.log")
				SZ7->(MsUnlock())
			Else
				RecLock("SZ7",.F.)
				SZ7->Z7_STATUS := "I"
				SZ7->Z7_LOGINT := "Título excluído com sucesso!"
				SZ7->(MsUnlock())
			Endif

		Else
			RecLock("SZ7",.F.)
			SZ7->Z7_STATUS := "E"
			SZ7->Z7_LOGINT := "Não há dados para excluir."
			SZ7->(MsUnlock())
		Endif

	Endif
	RestArea(aArea)
Return lRet

Static Function NumSE1(cTipo)
	Local cNumTit	:= ""
	Local cAlias 	:= GetNextAlias()

	BeginSql alias cAlias
		SELECT MAX(E1_NUM) E1_NUM
		FROM  %table:SE1%
		WHERE E1_FILIAL = %xFilial:SE1%
		AND E1_TIPO = %exp:cTipo%
	EndSql

	If !(cAlias)->(Eof())
		cNumTit := Soma1((cAlias)->E1_NUM)
	Else
		cNumTit := "000000001"
	Endif

	(cAlias)->(DbCloseArea())
Return cNumTit