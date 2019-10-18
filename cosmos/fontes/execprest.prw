#include 'protheus.ch'
#include 'parmtype.ch'
#include 'Topconn.ch'
#include "rwmake.ch"
#include "totvs.ch"
#include "fileio.ch"
#include "fwmvcdef.ch"



user function ExecPrest()

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
	Local aErros        :={}
	Private lMsErroAuto	:= .F.
	RpcClearEnv()
	RpcSetType(3)
	WFprepenv("01","0101") 

	U_StartEml("Processamento Reembolso Passageiro Cosmos - Inicio.",Time(),"thiagomt.rocco@gmail.com","edilson.mendes.nascimento@gmail.com","Processamento Reembolso Passageiro Cosmos - Inicio")

	cQuery := " SELECT * FROM "+RetSQlName("SZ7")+" WHERE D_E_L_E_T_<>'*' AND Z7_ACTION ='SUV' "
	cQuery += " AND Z7_STATUS='P' AND Z7_SUPID <> ='"+Alltrim(GetMV('MV_CLAIMS') )+"' AND Z7_DUEDATE = '"+DtoS(dDataBase)+"' AND Z7_FORCUR='BRL'"

	If Select("TRB") <> 0
		dbSelectArea("TRB")
		dbCloseArea()
	EndIf

	TCQuery cQuery New Alias "TRB"

	While TRB->(!Eof())


		aCabec := {}
		aItens := {}
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




		TRB->(DbSkip())
	End
	U_StartEml("Processamento Claims Cosmos - Fim.",Time(),"thiagomt.rocco@gmail.com","edilson.mendes.nascimento@gmail.com","Processamento Claims Cosmos - Fim")

	RpcClearEnv() 
Return
