#include 'protheus.ch'
#include 'parmtype.ch'
#include 'Topconn.ch'
#include "rwmake.ch"
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


user function ExecClaims()

	Local aArea		:= GetArea()
	Local aAreaSZ7 	:= SZ7->(GetArea())
	Local cAliasSZ7	:= GetNextAlias()
	Local nCount	:= 0
	Local cQuebra	:= chr(13) + chr(10)
	Local cNumTit	:= ""
	Local cNumFor	:= ""
	Local cNumLoja	:= ""
	Local lGeraTit  := .F.
	Local cTypeBank := ""
	Local aMoeda	:= {}
	Local cPath		:= GetSrvProfString("Startpath","")
	Local aDados 	:= {}
	Private lMsErroAuto := .F.

	U_StartEml("Processamento Claims Cosmos - Inicio.",Time(),"thiagomt.rocco@gmail.com","edilson.mendes.nascimento@gmail.com","Processamento Claims Cosmos - Inicio")

	cQuery := " SELECT * FROM "+RetSQlName("SZ7")+" WHERE D_E_L_E_T_<>'*' "
	cQuery += " AND Z7_STATUS='P' AND Z7_SUPID ='"+Alltrim(GetMV('MV_CLAIMS') )+"' AND Z7_DUEDATE = '20190617' "
	
	If Select("TRB") <> 0
		dbSelectArea("TRB")
		dbCloseArea()
	EndIf

	TCQuery cQuery New Alias "TRB"
	DbSelectArea("SA2")
	SA2->(DbSetOrder(3))

	While TRB->(!Eof())
	
		aString := strtokarr (TRB->Z7_LOCBANK, "#") 
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

		If SA2->(Dbseek(xFilial("SA2")+alltrim(TRB->Z7_TPPID)))
			cNumFor 	:= SA2->A2_COD
			cNumLoja	:= SA2->A2_LOJA
			cQuery1 := " UPDATE "+RetSQlName("SA2")+" SET A2_BANCO= '"+Substr(aString[3],1,3)+"'"
			cQuery1 += " ,A2_AGENCIA= '"+aString[4]+"', A2_DVAGE = '"+aString[5]+"',A2_NUMCON = '"+aString[6]+"' "
			cQuery1 += " ,A2_DVCTA= '"+aString[7]+"', A2_TIPCTA = '"+cTypeBank+"'"
			cQuery1 += " WHERE A2_COD='"+cNumFor+"' AND A2_LOJA='"+cNumLoja+"' AND D_E_L_E_T_<>'*'"

			If TCSQLExec(cQuery1) < 0
				MsgStop( "TCSQLError() " + TCSQLError(), 'April Brasil' )
				Return( .F. )
			EndIf
			lGeraTit := .T.
		Else
			aDadosFor := {}
			cCod := GETSXENUM("SA2","A2_COD")
			AADD(aDadosFor,{"A2_COD",cCod})                                                                                                      
			AADD(aDadosFor,{"A2_LOJA","01" })
			AADD(aDadosFor,{"A2_NOME", Substr(Alltrim(TRB->Z7_TPPNAME),1,TAMSX3("A2_NOME")[1])})
			AADD(aDadosFor,{"A2_NREDUZ", Substr(Alltrim(TRB->Z7_TPPNAME),1,TAMSX3("A2_NREDUZ")[1])})
			AADD(aDadosFor,{"A2_END","ALAMEDA SANTOS,1357"})
			AADD(aDadosFor,{"A2_BAIRRO ","CERQUEIRA CESAR"})
			AADD(aDadosFor,{"A2_EST ", "SP"})
			AADD(aDadosFor,{"A2_MUN", "SAO PAULO"})
			AADD(aDadosFor,{"A2_CEP", "01419908"})
			AADD(aDadosFor,{"A2_TIPO",If(Len(alltrim(TRB->Z7_TPPID))<=11,"F","J")})
			AADD(aDadosFor,{"A2_CGC", Alltrim(TRB->Z7_TPPID)})
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

				cQuery2 := " UPDATE "+RetSQlName("SZ7")+" SET Z7_STATUS='U',Z7_LOGINT = '"+MemoRead(cPath + "	logint.log")+"'"
				cQuery2 += " Z7_LOGERR = '"+MemoRead(cPath + "	logint.log")+"' WHERE Z7_ID='"+TRB->Z7_ID+"' AND D_E_L_E_T_<>'*'"

				If TCSQLExec(cQuery2) < 0
					MsgStop( "TCSQLError() " + TCSQLError(), 'April Brasil' )
					Return( .F. )
				EndIf
				RollBackSX8() // Se deu algum erro ele libera o n° do auto incremento para ser usado novamente;
			Else
				ConfirmSX8()   // Confirma se o auto incremento foi usado;
				cNumFor 	:= cCod
				cNumLoja	:= "01"	
				cQuery3 := " UPDATE "+RetSQlName("SA2")+" SET A2_MSBLQL ='2'"
				cQuery3 += " WHERE A2_COD='"+cCod+"' AND D_E_L_E_T_<>'*'"

				If TCSQLExec(cQuery3) < 0
					MsgStop( "TCSQLError() " + TCSQLError(), 'April Brasil' )
					Return( .F. )
				EndIf
				lGeraTit := .T.
			EndIf
		EndIf
		//Caso tudo OK, efetuo a geração do Titulo	
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

			MsExecAuto( { |x,y,z| FINA050(x,y,z)}, aDados,, 3) 


			If lMsErroAuto
				MostraErro(cPath, "logint.log")

				cQuery4 := " UPDATE "+RetSQlName("SZ7")+" SET Z7_STATUS='E', Z7_LOGINT = '"+MemoRead(cPath + "	logint.log")+"'"
				cQuery4 += " Z7_LOGERR = '"+MemoRead(cPath + "	logint.log")+"' WHERE Z7_ID='"+TRB->Z7_ID+"' AND D_E_L_E_T_<>'*'"

				If TCSQLExec(cQuery4) < 0
					MsgStop( "TCSQLError() " + TCSQLError(), 'April Brasil' )
					Return( .F. )
				EndIf
			Else
				cQuery5 := " UPDATE "+RetSQlName("SZ7")+" SET Z7_STATUS='I',Z7_TITULOP = '"+Alltrim(cNumTit)+"'"
				cQuery5 += "  WHERE R_E_C_N_O_="+Str(TRB->R_E_C_N_O_)+" AND D_E_L_E_T_<>'*'"

				If TCSQLExec(cQuery5) < 0
					MsgStop( "TCSQLError() " + TCSQLError(), 'April Brasil' )
					Return( .F. )
				EndIf
			Endif
		Endif
		TRB->(DbSkip())
	End
	U_StartEml("Processamento Claims Cosmos - Fim.",Time(),"thiagomt.rocco@gmail.com","edilson.mendes.nascimento@gmail.com","Processamento Claims Cosmos - Fim")
Return

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