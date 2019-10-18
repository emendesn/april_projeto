#include "rwmake.ch"
#include "protheus.ch"
#include "totvs.ch"
#include "fileio.ch"
#include "fwmvcdef.ch"
#include "topconn.ch"

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


User Function IntCos()

	_cQuery := " SELECT * FROM "+RetSQLName("SZ7")+" "
	_cQuery += " WHERE D_E_L_E_T_<>'*' AND Z7_STATUS='A'"

	If Select("TRB1") <> 0
		dbSelectArea("TRB1")
		dbCloseArea()
	EndIf

	TCQuery _cQuery New Alias "TRB1"

	DbSelectArea("SA2")
	SA2->(DbSetOrder(3))

	While TRB1->(!Eof())



		If SA2->(Dbseek(xFilial("SA2")+alltrim(TRB1->Z7_TPPID)))
			cNumFor 	:= SA2->A2_COD
			cNumLoja	:= SA2->A2_LOJA
			lGeraTit := .T.
		Else
			aDadosFor := {}
			cCod := GETSXENUM("SA2","A2_COD")
			aString := strtokarr (TRB1->Z7_LOCBANK, "#") 
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

			AADD(aDadosFor,{"A2_COD",cCod})                                                                                                      
			AADD(aDadosFor,{"A2_LOJA","01" })
			AADD(aDadosFor,{"A2_NOME", Substr(Alltrim(TRB1->Z7_TPPNAME),1,TAMSX3("A2_NOME")[1])})
			AADD(aDadosFor,{"A2_NREDUZ", Substr(Alltrim(TRB1->Z7_TPPNAME),1,TAMSX3("A2_NREDUZ")[1])})
			AADD(aDadosFor,{"A2_END","ALAMEDA SANTOS,1357"})
			AADD(aDadosFor,{"A2_BAIRRO ","CERQUEIRA CESAR"})
			AADD(aDadosFor,{"A2_EST ", "SP"})
			AADD(aDadosFor,{"A2_MUN", "SAO PAULO"})
			AADD(aDadosFor,{"A2_CEP", "01419908"})
			AADD(aDadosFor,{"A2_TIPO",If(Len(alltrim(TRB1->Z7_TPPID))<=11,"F","J")})
			AADD(aDadosFor,{"A2_CGC", Alltrim(TRB1->Z7_TPPID)})
			AADD(aDadosFor,{"A2_CONTA", "2110020003"   })       
			AADD(aDadosFor,{"A2_DDD", ""	})	
			AADD(aDadosFor,{"A2_TEL",""})
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

				cPath := "C:\TEMP" 
				cNomeArq := "Erro_MsExecAuto_MATA020.txt" 	
				//Mostra em Tela o Erro Ocorrido
				MostraErro(cPath, cNomeArq)	
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
		cNumTit := cNumTit()
		aAdd(aDados,{ "E2_PREFIXO" 		, "COS"			 	, NIL })
		aAdd(aDados,{ "E2_NUM" 			, cNumTit	, NIL })
		aAdd(aDados,{ "E2_TIPO" 		, "TF"		 		, NIL })
		aAdd(aDados,{ "E2_NATUREZ" 		, "2.02.01"		 	, NIL })
		aAdd(aDados,{ "E2_FORNECE" 		, cNumFor 			, NIL })
		aAdd(aDados,{ "E2_LOJA" 		, cNumLoja 			, NIL })
		aAdd(aDados,{ "E2_EMISSAO" 		, dDataBase   			, NIL })//
		aAdd(aDados,{ "E2_VENCTO" 		, dDataBase         , NIL })//Verificar Regra de Vencimento. dEmissao
		aAdd(aDados,{ "E2_VALOR" 		, TRB1->Z7_FORAMNT 	, NIL })
		aAdd(aDados,{ "E2_XNUMID" 		, TRB1->Z7_OBJNUM 	, NIL })
		aAdd(aDados,{ "E2_XCASEID" 		, TRB1->Z7_CASENUM 	, NIL })
		aAdd(aDados,{ "E2_XPARTN" 		, TRB1->Z7_PARTNAM 	, NIL })
		If cTipo <>'R'		
			aAdd(aDados,{ "E2_MOEDA"		, aMoeda[1]			, NIL })
			aAdd(aDados,{ "E2_TXMOEDA"		, aMoeda[2]			, NIL })
		EndIf
		MsExecAuto( { |x,y,z| FINA050(x,y,z)}, aDados,, 3) 


		If lMsErroAuto
			MostraErro(cPath, "logint.log")
		Endif

		TRB1->(DbSkip())
	End

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