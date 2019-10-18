#include "protheus.ch"	
#include "totvs.ch"
#include "fileio.ch"
#INCLUDE "tbiconn.ch"

//#################
//# Programa      # JobCosmo
//# Data          # 05/11/2018
//# Descrição     # Funcao para ler os arquivos .CSV automaticamente por Schedule(JOB) 
//# Desenvolvedor # Washington Miranda Leão
//# Empresa       # Totvs Nações Unidas
//# Linguagem     # eAdvpl     
//# Versão        # 12
//# Sistema       # Protheus
//# Módulo        # Financeiro
//# Tabelas       # "SZ7", ".CSV"
//# Observação    # Usado para gravação no middleware do cancelamento da baixa 
//#===============#
//# Atualizações  # Paulo Henrique - TNU - 08/04/2019 
//#===============#
//#################




User Function JobCosmo()
	Local nRet
	Local nI
	Local sRet
	Local nX		:= 0
	Local cPasta    := ""
	Local aArquivos	:= {}
	Local nX		:= 1
	Local lAuto := .F.

	Private oFTPHandle
	//MyOpenSM0()
	RpcClearEnv()
	RpcSetType(3)
	WFprepenv("01","0101") 
	lAuto := .T.
	cPasta := "\COSMOS\RECEBIDOS\" 
	U_StartEml("Leitura Arquivo Cosmos - Inicio.",Time(),"thiagomt.rocco@gmail.com","edilson.mendes.nascimento@gmail.com","Leitura Arquivo Cosmos - Inicio")

	aArquivos := Directory(cPasta + "pre*.csv")

	If Len(aArquivos) == 0
		U_StartEml("Leitura Arquivo Cosmos - Inicio.",Time(),"thiagomt.rocco@gmail.com","edilson.mendes.nascimento@gmail.com","Leitura Arquivo Cosmos - Sem arquivos")
		Return
	EndIf

	Importa(cPasta, aArquivos)

	
	If lAuto 
		RpcClearEnv() 
	EndIf 

Return

//###################
//# Statig Function # Importa
//# Data            # 05/11/2018
//# Descrição       # Funcao para importar os dados dos arquivos .CSV importados automaticamente por Schedule(JOB) 
//# Desenvolvedor   # Washington Miranda Leão
//# Empresa         # Totvs Nações Unidas
//# Linguagem       # eAdvpl     
//# Versão          # 12
//# Sistema         # Protheus
//# Módulo          # Financeiro
//#=================#
//# Atualizações    # Paulo Henrique - TNU - 08/04/2019
//#=================#
//###################
Static Function Importa(cPasta, aArquivos)
	Local nX     := 0
	Local nY     := 0 
	Local aDados := {}
	Local cArq   := ""
	Local lOk    := .F.

	ErrorBlock( { |oErro|  GravaLog( , oErro, cArq )  } )

	Begin Sequence

		For nY := 1 To Len(aArquivos)
			cArq   := cPasta + aArquivos[nY][1]
			aDados := Arq2Arr(cArq)
			cNewArq := aArquivos[nY][1]+"_" + StrTran(dtoc(Date()),"/","-")+"_"+StrTran(Time(),":","")
			For nX := 2 To Len(aDados)
				RecLock("SZ7",.T.)
				SZ7->Z7_FILIAL	:= xFilial("SZ7")
				SZ7->Z7_ID   	:= Upper(aDados[nX][1]) 
				SZ7->Z7_PREFIX	:= Upper(aDados[nX][2]) 
				SZ7->Z7_OBJTYPE	:= Upper(aDados[nX][3]) 
				SZ7->Z7_OBJID	:= Upper(aDados[nX][4])	   		
				SZ7->Z7_OBJNUM 	:= Upper(aDados[nX][5])
				SZ7->Z7_OBJEXTN	:= Upper(aDados[nX][6])
				SZ7->Z7_OBJPARN	:= Upper(aDados[nX][7])
				SZ7->Z7_ACTION 	:= Upper(aDados[nX][8])
				SZ7->Z7_ACTDATE := STOD(StrTran(aDados[nX][9],"-",""))
				SZ7->Z7_ACTUSER := Upper(aDados[nX][10])
				SZ7->Z7_ACCTDAT	:= STOD(StrTran(aDados[nX][11],"-",""))
				SZ7->Z7_DUEDATE	:= STOD(StrTran(aDados[nX][12],"-",""))+1
				SZ7->Z7_RCPDATE	:= STOD(StrTran(aDados[nX][13],"-",""))
				SZ7->Z7_INVDATE	:= STOD(StrTran(aDados[nX][14],"-",""))+1
				SZ7->Z7_PAYTYPE	:= Upper(aDados[nX][15])
				SZ7->Z7_LOCBANK	:= Upper(aDados[nX][16])
				SZ7->Z7_CASEID 	:= Upper(aDados[nX][17])
				SZ7->Z7_CASENUM	:= Upper(aDados[nX][18])
				SZ7->Z7_CASEEXT	:= Upper(aDados[nX][19])
				SZ7->Z7_CASEDAT	:= STOD(StrTran(aDados[nX][20],"-",""))
				SZ7->Z7_CSEVDAT	:= STOD(StrTran(aDados[nX][21],"-",""))
				SZ7->Z7_CASETYP	:= Upper(aDados[nX][22])
				SZ7->Z7_CASUBTY	:= Upper(aDados[nX][23])	
				SZ7->Z7_PRDID  	:= Upper(aDados[nX][24])
				SZ7->Z7_PRODNAM	:= Upper(aDados[nX][25])
				SZ7->Z7_PARTID 	:= Upper(aDados[nX][26])
				SZ7->Z7_PARTNAM	:= Upper(aDados[nX][27])
				SZ7->Z7_BENNAME	:= Upper(aDados[nX][28])
				SZ7->Z7_POLNUM 	:= Upper(aDados[nX][29])	   		
				SZ7->Z7_POLDATE	:= STOD(StrTran(aDados[nX][30],"-",""))
				SZ7->Z7_SERVID 	:= Upper(aDados[nX][31])
				SZ7->Z7_SERVINU	:= Upper(aDados[nX][32])
				SZ7->Z7_SERVDES	:= Upper(aDados[nX][33])
				SZ7->Z7_SUPID  	:= Upper(aDados[nX][34]) // Pega a posição 33 do arquivo .CSV Supplier ID
				SZ7->Z7_SUPNAM 	:= Upper(aDados[nX][35]) // Pega a posição 34 do arquivo .CSV Supplier name
				SZ7->Z7_TPPID  	:= Upper(aDados[nX][36]) // Pega a posiçao 35 do arquivo .CSV TPP ID
				SZ7->Z7_TPPTYPE	:= Upper(aDados[nX][37]) 
				SZ7->Z7_TPPNAME := Upper(aDados[nX][38]) // Pega a posição 37 do arquivo .CSV TPP name
				SZ7->Z7_INITIAL	:= Val(aDados[nX][39])
				SZ7->Z7_VAT		:= Val(aDados[nX][40])
				SZ7->Z7_MRKPAMO	:= Val(aDados[nX][41])
				SZ7->Z7_WTAMOUN	:= Val(aDados[nX][42])
				SZ7->Z7_DOBAMOU	:= Val(aDados[nX][43])
				SZ7->Z7_DOBREIN	:= Val(aDados[nX][44])
				SZ7->Z7_DSCAMOU	:= Val(aDados[nX][45])
				SZ7->Z7_CLTSHAR	:= Val(aDados[nX][46])
				SZ7->Z7_REPRICE	:= Val(aDados[nX][47])
				SZ7->Z7_TLOCAL 	:= Val(aDados[nX][48])
				SZ7->Z7_LOCCUR 	:= Val(aDados[nX][49])
				SZ7->Z7_FORAMNT	:= Val(aDados[nX][50])
				SZ7->Z7_FORCUR 	:= Upper(aDados[nX][51])
				SZ7->Z7_EXRATE 	:= Val(aDados[nX][52])
				SZ7->Z7_EXDATE 	:= STOD(Strtran(aDados[nX][53],"-",""))
				SZ7->Z7_EXPLOC 	:= Val(aDados[nX][54])
				SZ7->Z7_STATUS 	:= "P"
				SZ7->Z7_NOMEARQ	:= cNewArq
				SZ7->(MsUnlock())
			Next nX

			//__copyfile("\COSMOS\RECEBIDOS\"+cArq, "\COSMOS\RECEBIDOS\SUCESSO\"+cArq)

			nStatus1 := FRenameEX ("\COSMOS\RECEBIDOS\"+aArquivos[nY][1],"\COSMOS\RECEBIDOS\SUCESSO\"+cNewArq+".csv") 
			IF nStatus1 == -1
				__copyfile(cArq, StrTran(cArq, "\COSMOS\RECEBIDOS\", "\COSMOS\RECEBIDOS\ERROS\"))		
				U_StartEml("Leitura Arquivo Cosmos"+cArq+" - Erro "+str(ferror(),4),Time(),"thiagomt.rocco@gmail.com","edilson.mendes.nascimento@gmail.com","Leitura Arquivo Cosmos - Erro")
			Else
			U_StartEml("Leitura Arquivo Cosmos"+cArq+" - com Sucesso",Time(),"thiagomt.rocco@gmail.com","edilson.mendes.nascimento@gmail.com","Leitura Arquivo Cosmos - Sucesso")
			Endif
			fErase(cArq)

		Next nY
		U_StartEml("Leitura Arquivo Cosmos: "+cArq+" - processado com Sucesso - Quantidade de Regs: "+Str((nX-2))+ " ","","thiagomt.rocco@gmail.com","edilson.mendes.nascimento@gmail.com","Leitura Arquivo Cosmos - Fim")
	End Sequence

Return

//###################
//# Statig Function # Arq2Arr
//# Data            # 05/11/2018
//# Descrição       # Funcao para leitura dos dados dos arquivos .CSV importados automaticamente por Schedule(JOB) 
//# Desenvolvedor   # Washington Miranda Leão
//# Empresa         # Totvs Nações Unidas
//# Linguagem       # eAdvpl     
//# Versão          # 12
//# Sistema         # Protheus
//# Módulo          # Financeiro
//#=================#
//# Atualizações    # Paulo Henrique - TNU - 08/04/2019
//#=================#
//###################
Static Function Arq2Arr (cArq)
	Local cAux	  := ""
	Local aAux	  := {}
	Local aRet	  := {}
	Local nHandle := FT_FUSE( cArq )
	Local nX := 0

	// Se houver erro de abertura abandona processamento
	if nHandle = -1
		GravaLog("Erro ao abrir o arquivo [" + cArq + "]", Nil, cArq)
		Return()
	EndIf

	// Posiciona na primeria linha
	FT_FGOTOP()

	While !FT_FEOF()
		nX++
		cAux := StrTran(FT_FREADLN(),'"','')
		aAux := Separa(cAux, ";")
		aAdd(aRet, aAux)
		FT_FSKIP()
	EndDo

	FT_FUSE()

RETURN aRet

//###################
//# Statig Function # GravaLog
//# Data            # 05/11/2018
//# Descrição       # Funcao para gravação do log de erro da importação 
//# Desenvolvedor   # Washington Miranda Leão
//# Empresa         # Totvs Nações Unidas
//# Linguagem       # eAdvpl     
//# Versão          # 12
//# Sistema         # Protheus
//# Módulo          # Financeiro
//#=================#
//# Atualizações    # Paulo Henrique - TNU - 08/04/2019
//#=================#
//###################
Static Function GravaLog(cLog,  oErro, cArq)

	Local cFileLog := StrTran(UPPER(cArq), ".CSV", "_" + Dtos(Date()) + "_" + StrTran(Time(), ":", "") + ".LOG")

	DEFAULT cLog  := oErro:ERRORSTACK

	__copyfile(cArq, StrTran(cArq, "\COSMOS\RECEBIDOS\", "\COSMOS\RECEBIDOS\ERROS\"))

	cFileLog := StrTran(cFileLog, "\COSMOS\RECEBIDOS\", "\COSMOS\RECEBIDOS\ERROS\")
	nHandle  := FCreate(cFileLog)

	FWrite(nHandle,cLog)
	FClose(nHandle)

	FT_FUSE()
	fErase(cArq)

	If oErro <> Nil
		BREAK( @oErro )
	EndIf   

	U_StartEml("Leitura Arquivo Cosmos"+cArq+" - Erro "+str(ferror(),4),Time(),"thiagomt.rocco@gmail.com","edilson.mendes.nascimento@gmail.com","Leitura Arquivo Cosmos - Erro")

Return

//###################
//# Statig Function # MyOpenSM0
//# Data            # 05/11/2018
//# Descrição       # Funcao para verificação das empresas utilizadas para a leitura do CSV 
//# Desenvolvedor   # Washington Miranda Leão
//# Empresa         # Totvs Nações Unidas
//# Linguagem       # eAdvpl     
//# Versão          # 12
//# Sistema         # Protheus
//# Módulo          # Financeiro
//#=================#
//# Atualizações    # Paulo Henrique - TNU - 08/04/2019
//#=================#
//###################
Static Function MyOpenSM0()

	Local aParam := {}
	Private cCadastro := "Job de leitura de CSV"

	If Select("SM0") > 0
		Return
	EndIf

	Set Dele On
	dbUseArea( .T., , 'SIGAMAT.EMP', 'SM0', .T., .F. )
	dbSetIndex( 'SIGAMAT.IND' )
	dbGoTop()

	RpcSetType( 3 )
	RpcSetEnv( SM0->M0_CODIGO, SM0->M0_CODFIL )

	If LastRec() > 1 .And. !IsBlind()

		Aadd(aParam, {1, "Empresa", Space(2), "@!"	, "", "SM0", "", 002, .F.})

		IF ! ParamBox(aParam, "Parâmetros da rotina",, {|| AllwaysTrue()},,,,,,, .F.)
			Return .F.
		EndIf

		SM0->(dbSeek(mv_par01))

		cOEmp := SM0->M0_CODIGO
		cOFil := SM0->M0_CODFIL

		RpcClearEnv()
		RpcSetEnv( cOEmp, cOFil )

	EndIf

Return