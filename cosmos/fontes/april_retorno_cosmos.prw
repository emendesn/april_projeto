#include "protheus.ch"
#include "rwmake.ch"
#include "totvs.ch"
#include "topconn.ch"

#define CRLF  chr(13) + chr(10)

// Envia arquivo de retorno COSMOS
// Elias 05/07/2018
User Function RetCosmos()
	Local cPasta	:= ""
	Local cFile		:= ""
	Local cDrive, cDir, cNome, cExt

	cPasta 		:= cGetFile( '*.csv' , 'Arquivos (CSV)', 1, "C:\", .T.,;
	nOR( GETF_LOCALHARD, GETF_LOCALFLOPPY, GETF_RETDIRECTORY ),.T., .T. )

	If Empty(cPasta)
		Alert ("Cancelado pelo usuário.")
		Return
	Endif

	cFile := cPasta + "ARQRET" + dTos(dDatabase) + StrTran(Time(),":","") + ".CSV"

	MsgRun("Aguarde, gerando arquivo.","Retorno Cosmos",{|x| u_JRetCosm(cFile) })

Return


User Function JRetCosm(cFile)
	Local cLinha	:= ""
	Local cData		:= ""
	Local cFlag		:= ""
	Local cCurr		:= "BRL"
	Local nHandle	:= 0
	Local lAuto		:= !(Select("SX6") > 0)


	If lAuto
		RpcSetEnv("01","0101", "totvs1", "tnu2018") 
	Endif

	nHandle := FCREATE(cFile)

	if nHandle = -1
		conout("Erro ao criar arquivo - ferror " + Str(Ferror()))
		return .f.
	endif

	// Cabeçalho
	cLinha := "Invoice number;Payment date;Flag;Local amount;Local currency;Comment"
	FWrite(nHandle, cLinha + CRLF)

		cQuery := " SELECT SE2A.E2_NUM, SE2A.E2_XNUMID, SE2A.E2_BAIXA, SE2A.E2_VALLIQ, SE2A.E2_HIST,SE2A.E2_TXADM,SE2A.E2_XVLIOF, SE2A.D_E_L_E_T_ DEL FROM "+RetSQlName("SE2")+" SE2A "
		cQuery += " WHERE  SE2A.E2_SALDO <= 0 AND SE2A.D_E_L_E_T_<>'*' AND SE2A.E2_XNUMID <>'' AND E2_BAIXA >='20190213'"

			If Select("TRB") <> 0
				dbSelectArea("TRB")
				dbCloseArea()
			EndIf

			TCQuery cQuery New Alias "TRB"
	
	
	While !TRB->(Eof())

		cLinha	:= TRB->E2_XNUMID  + ";" 									// Invoice Number

		If !Empty(TRB->E2_BAIXA)
			cData	:= 	Substr(TRB->E2_BAIXA,1,4) + "-" +;
			Substr(TRB->E2_BAIXA,5,2) + "-" +;
			Substr(TRB->E2_BAIXA,7,2)  
			cLinha	+= cData + ";"
		Else
			cLinha += ";"
		Endif																// Payment date
		cLinha	+= iif(AllTrim(TRB->DEL) == "","PAID","CANCELED") + ";"		// Flag
		cLinha	+= Alltrim(Str(TRB->(E2_VALLIQ+E2_TXADM+E2_XVLIOF))) + ";" 	// Local Amount Alterado por Washington Leao 31/10/2018
		// Inclui dois campos na soma do E2_VALLIQ),falta um
		cLinha	+= cCurr + ";"												// Local Currency
		cLinha	+= AllTrim(TRB->E2_HIST)									// Histórico
		FWrite(nHandle, cLinha  + CRLF)
		TRB->(DbSkip())
	End

	FClose(nHandle)

	TRB->(DbCloseArea())

	If lAuto
		RpcClearEnv()
	Endif

Return