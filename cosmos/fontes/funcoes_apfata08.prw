#include 'protheus.ch'
#include 'parmtype.ch'
#include 'topconn.ch'


//#################
//# Programa      # APFATA08
//# Data          #   
//# Descrição     # Rotina para atualização de Moedas 
//# Desenvolvedor # Edie Carlos 
//# Empresa       # Totvs Nacoes Unidas
//# Linguagem     # eAdvpl     
//# Versão        # 12
//# Sistema       # Protheus
//# Módulo        # Faturamento
//# Tabelas       # "SZA"
//# Observação    # Usado para fazer donwload site do bacen para atualizaçãode moedas 
//#===============#
//# Atualizações  # 
//#===============#
//#################

user function APFATA08()

	Local lAuto := .F.
	Local dDataIni := dDataBase - 320
	Private cCadas := "Cadastro de Taxas Bacen"
	U_StartEml("Atualização Moedas Bacen - Inicio.",Time(),"thiagomt.rocco@gmail.com","edilson.mendes.nascimento@gmail.com","Atualizar Moedas Bacen - Inicio")
	For nX :=1 to 320
		dDataBase := dDataIni
		If Select("SX2")==0 // Testa se está sendo rodado do menu 
			RpcClearEnv()
			RpcSetType(3)
			WFprepenv("01","0101") 
			lAuto := .T.
			U_DownBacen()
			U_ATUSM2()
		Else
			Processa( {|| U_DownBacen() }, cCadas, "Download BACEN..."+Str(nX) )
			Processa( {|| U_ATUSM2(dDataBase) }, "Atualiza Moedas do Sistema", "Download BACEN..." )

		Endif

		If lAuto 
			RpcClearEnv() 
		EndIf 
		dDataIni:= dDataIni+1
	Next nX
	U_StartEml("Atualização Moedas Bacen - Fim.",Time(),"thiagomt.rocco@gmail.com","edilson.mendes.nascimento@gmail.com","Atualizar Moedas Bacen - Fim")
	Msginfo("Importação Finalizada", "Download BACEN")
Return	

User Function DownBacen()

	Local cFile, cTexto, nLinhas, j, lAuto,jj := .F.
	Local cMoeda :='' 
	Local cArqImpor := "\system\moedasbcb.csv" 
	Local nTimeOut 	:= 120 
	Local aHeadOut 	:= {} 
	Local cHeadRet 	:= "" 
	Local cGetRet 	:= "" 

	If Select("SX2")==0 // Testa se está sendo rodado do menu 
		RpcClearEnv()
		RpcSetType(3)
		WFprepenv("01","01") 
		lAuto := .T. 
	EndIf 

	dDataRef := dDataBase - 1 
	cFile := Dtos(DataValida(dDataRef,.f.))+'.csv' //Utiliza dia util anterior se for fim de semana ou feriado cadastrado na tabela SX5 - 63


	cURL := "https://www4.bcb.gov.br/download/fechamento/"+cFile
	AAdd(aHeadOut,"User-Agent: Mozilla/4.0 (compatible; Protheus "+GetBuild()+")")
	cTexto := HTTPSGet(cURL,GetPvProfString(GetEnvServer(),"RootPath","",GetADV97())+"\certs\000001_cert.pem",GetPvProfString(GetEnvServer(),"RootPath","",GetADV97())+"\certs\000001_key.pem","April0213","WSDL",nTimeOut, aHeadOut,@cHeadRet)


	nArquivo := FCreate( cArqImpor, 0 )  	
	FWrite( nArquivo , cTexto)
	fClose( nArquivo ) 

	//+---------------------------------------------------------------------+
	//| Abertura do arquivo texto                                           |
	//+---------------------------------------------------------------------+
	nHdl := fOpen(cArqImpor)

	If nHdl == -1 
		IF FERROR()== 516 
			If	( lAuto )
				ALERT("Feche a planilha que gerou o arquivo.")
			ENDIF
			ConOut("Feche a planilha que gerou o arquivo.")
		EndIF
	EndIf

	//+---------------------------------------------------------------------+
	//| Posiciona no Inicio do Arquivo                                      |
	//+---------------------------------------------------------------------+
	FSEEK(nHdl,0,0)

	//+---------------------------------------------------------------------+
	//| Traz o Tamanho do Arquivo TXT                                       |
	//+---------------------------------------------------------------------+
	nTamArq:=FSEEK(nHdl,0,2)

	//+---------------------------------------------------------------------+
	//| Posicona novamemte no Inicio                                        |
	//+---------------------------------------------------------------------+
	FSEEK(nHdl,0,0)

	//+---------------------------------------------------------------------+
	//| Fecha o Arquivo                                                     |
	//+---------------------------------------------------------------------+
	fClose(nHdl)
	FT_FUse(cArqImpor)  //abre o arquivo 
	FT_FGOTOP()         //posiciona na primeira linha do arquivo      
	nTamLinha := Len(FT_FREADLN()) //Ve o tamanho da linha
	FT_FGOTOP()

	//+---------------------------------------------------------------------+
	//| Verifica quantas linhas tem o arquivo                               |
	//+---------------------------------------------------------------------+
	nLinhas := Int(nTamArq/nTamLinha)

	ProcRegua(nLinhas)		                                                            

	aDados:={}	      
	nCont := 0
	If Substr(cTexto,1,5) <> "<?xml"
		While !FT_FEOF()// .and. ncont &lt; 16 

			IncProc('Validando Linha: ' + Alltrim(Str(nCont)) )
			aTab := {}
			clinha := FT_FREADLN() 

			/*if (At("&lt;!",cLinha)>0)
			MsgStop("Não foi encontrado no Banco Central o arquivo correspondente ("+cFile+")")
			Return
			Endif*/

			aLinha  :=  Separa(cLinha,";",.T.)
			cData  	:= aLinha[1]                
			cMoeda  := aLinha[2]
			cBacen  := aLinha[4]                
			cCompra := aLinha[5] 
			cVenda  := aLinha[6]


			DbSelectArea("SZA") 
			DbSetOrder(1) 

			dData := CTOD(cData) 
			If SZA->(DbSeek(xFilial("SZA")+DTOS(dData)+cMoeda)) 
				Reclock("SZA",.F.) 
			Else 
				Reclock("SZA",.T.) 
				Replace ZA_DATA   With dData 
			EndIf 
			Replace ZA_CODBACE With cBacen
			Replace ZA_VLVENDA With Val(StrTran( cVenda, ",", ".")) 
			Replace ZA_VLCOMPR With Val(StrTran( cCompra, ",", "."))
			Replace ZA_MOEDA   With cMoeda 
			MsUnlock("SZA")  


			FT_FSKIP()
			nCont++
		EndDo
	EndIf
	FErase(cArqImpor)	
	FT_FUse()
	fClose(nHdl) 


Return


User Function ATUSM2(dData)	

	Local cQuery := ""
	Local nQuant := 0

	cQuery2 := " SELECT COUNT(*) AS SOMA FROM "+RetSqlName("SYF")+" YF "
	cQuery2 += " WHERE YF.D_E_L_E_T_<>'*'"
	cQuery2 += " AND YF_CODMOE<>''"

	If Select("TRB1") <> 0
		dbSelectArea("TRB1")
		dbCloseArea()
	EndIf
	TCQuery cQuery2 New Alias "TRB1"
	nQuant := TRB1->SOMA +1

	cQuery := " SELECT * FROM "+RetSqlName("SZA")+" ZA "
	cQuery += " INNER JOIN SYF010 YF ON YF_COD_GI = ZA_MOEDA "
	cQuery += " WHERE ZA.D_E_L_E_T_<>'*' AND YF.D_E_L_E_T_<>'*'AND ZA_DATA > ='"+DtoS(dData)+"'"
	cQuery += " AND YF_CODMOE<>''"

	If Select("TRB") <> 0
		dbSelectArea("TRB")
		dbCloseArea()
	EndIf
	TCQuery cQuery New Alias "TRB"



	DbSelectArea("SM2")				
	SM2->(DbSetorder(1))

	While TRB->(!Eof())


		lGrava := SM2->(DbSeek(StoD(TRB->ZA_DATA)))  
		Reclock('SM2',!lGrava)
		SM2->M2_DATA	:= StoD(TRB->ZA_DATA)
		For nX:=2 to nQuant
			cCampo:= Alltrim("M2"+Substr(TRB->YF_CODMOE,3,8))
			SM2->&cCampo:= TRB->ZA_VLVENDA	
			SM2->M2_INFORM	:= "S"
		Next nX
		SM2->(MsUnlock())
		SM2->(dbCloseArea())
		TRB->(DbSkip())
	End

Return