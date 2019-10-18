#INCLUDE "PROTHEUS.CH"
#include "TBICONN.CH"
#include "RWMAKE.CH"
#include 'topconn.ch'
#include "TbiCode.ch"


Static __cPeriodCalc
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณGPEX001   บAutor  ณTiago Caires        บ Data ณ  11/09/2015 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Lista dos Eventos da Folha de Pagamento de acordo com      บฑฑ
ฑฑบ          ณ Especificacao de Customizacao de 02/Set/2015               บฑฑ
ฑฑบ          ณ Saida em planilha Excel(XML)                               บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Uso especifico April Brasil                                บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/

User Function GPEX001()
	Local cTitulo	:= "Planilha dos Eventos da Folha de Pagamento "

	Local cDesc1	:= "Este programa emite uma planilha com a rela็ใo dos eventos    "
	Local cDesc2	:= "da folha de pagamento de acordo com o periodo selecionado     "
	Local cDesc3	:= "pelo Usuแrio                                                  "
	Local cDesc4	:= "                                                              "
	Local cDesc5	:= "                                                              "
	Local cDesc6	:= "Versใo I (Set/2015)                    Especํfico APril Brasil"
	Local cDesc7	:= "Versใo II(Set/2018)                    Especํfico APril Brasil"

	Local nOpca		:= 0
	Local cCadastro :=OemToAnsi(cTitulo)
	Local aSays		:= {}
	Local aButtons	:= {}
	Local cPerg		:= "GPEX001   "
	Local _lRet		:= .t.
	Local cFolMes	:= __cPeriodCalc
	Local cAlias	:= ""

	CriaSX1(cPerg)

	AADD(aSays,OemToAnsi(cDesc1))
	AADD(aSays,OemToAnsi(cDesc2))
	AADD(aSays,OemToAnsi(cDesc3))
	AADD(aSays,OemToAnsi(cDesc4))
	AADD(aSays,OemToAnsi(cDesc5))
	AADD(aSays,OemToAnsi(cDesc6))
	AADD(aSays,OemToAnsi(cDesc7))

	If !Pergunte(cPerg,.T.)
		Return()
	EndIf

	AADD(aButtons, { 5,.T.,{|o| Pergunte(cPerg,.T.) } } )
	AADD(aButtons, { 1,.T.,{|o| nOpca:= 1,o:oWnd:End() } } )
	AADD(aButtons, { 2,.T.,{|o| o:oWnd:End() }} )

	FormBatch( cCadastro, aSays, aButtons )

	IF nOpcA == 1
		SetPeriodCalc( '201712' )
		cFolMes	:= __cPeriodCalc

		_lRet := Iif(Len(Alltrim(MV_PAR01))<>6,.f.,_lRet)		
		_lRet := Iif(Left(MV_PAR01,4) >= "1900" .and. Left(MV_PAR01,4) <= "2099",_lRet,.F.)
		_lRet := Iif(Right(MV_PAR01,2) >= "01" .and. Right(MV_PAR01,2) <= "13",_lRet,.F.)
		_lRet := Iif(MV_PAR01 > AnoMes( dDataBase ),.f.,_lRet) 

		If _lRet
			Processa({|| SelDados(cAlias)},"Planilha dos eventos da Folha de Pagamento")
		Else
			Alert("Data Invแlida! Verifique")
		EndIf

	EndIf

Return()

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuncao    ณSelDados  บAutor  ณTiago Caires        บ Data ณ  11/09/2015 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Seleciona dados da Folha                                   บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Uso especifico April Brasil                                บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function SelDados(cAlias)
	Local cQuery		:= ""
	Local nPOs			:= 0
	Local aCpos			:= {}
	Local nReg			:= 0
	Local cCateg		:= ""
	Local i				:= 0
	Local lAberto 		:= .T.


	//Avalia็ใo se o Periodo estแ fechado ou aberto, caso esteja em aberto iremos pegar da SRC caso Contrario SRD.
	c_Query := "	SELECT RCH_DTFECH FROM "+RetSqlName("RCH")+"  WHERE D_E_L_E_T_<>'*' "
	c_Query += "	AND RCH_ROTEIR='FOL' AND RCH_PER='"+mv_par01+"'      "
	c_Query += "    AND RCH_FILIAL BETWEEN '"+mv_par02+"' and '"+mv_par03+"' "
	//Fecha Alias se estiver aberto
	If Select("WRCH") > 0
		WRCH->(dbCloseArea())
	Endif

	TCQuery c_Query New Alias "WRCH"

	While !WRCH->(Eof())

		If !Empty(WRCH->RCH_DTFECH)
			lAberto := .F.
		EndIf

		WRCH->(dbSkip())
	Enddo


	If lAberto

		cQuery += 		"SELECT RV.RV_XCTB CTB,RV_XCODRED XCODRED,"+Chr(13)+Chr(10)
		cQuery += 			"RC.RC_FILIAL FILIAL, "+Chr(13)+Chr(10)
		cQuery += 			"CASE WHEN RA.RA_TPCONTR = '1' THEN 'Tempo Indetermindado' ELSE 'Tempo Determinado' END TPCONTR, "+Chr(13)+Chr(10)
		cQuery += 			"RA.RA_ADMISSA ADMISSA, "+Chr(13)+Chr(10)
		cQuery += 			"RTRIM(LTRIM(RC.RC_CC))+'-'+RTRIM(LTRIM(CTT.CTT_DESC01)) CCUSTO, "+Chr(13)+Chr(10)
		cQuery += 			"RTRIM(LTRIM(RA.RA_CODFUNC))+'-'+RJ.RJ_DESC FUNCAO, "+Chr(13)+Chr(10)
		cQuery += 			"RC.RC_MAT MAT, "+Chr(13)+Chr(10)
		cQuery += 			"RC.RC_MAT+'-'+RC.RC_FILIAL MATFIL, "+Chr(13)+Chr(10)
		cQuery += 			"RA.RA_NOME NOME, "+Chr(13)+Chr(10)
		cQuery += 			"RC.RC_MAT+'-'+RA.RA_NOME MATNOME, "+Chr(13)+Chr(10)
		cQuery += 			"CASE "+Chr(13)+Chr(10)
		cQuery += 				"WHEN RV.RV_TIPOCOD = '1' THEN 'P' "+Chr(13)+Chr(10)
		cQuery += 				"WHEN RV.RV_TIPOCOD = '2' THEN 'D' "+Chr(13)+Chr(10)
		cQuery += 			"ELSE 'B' END TPVERBA, "+Chr(13)+Chr(10)
		cQuery += 			"RC.RC_PD+'-'+RV.RV_DESC VERBA, "+Chr(13)+Chr(10)
		cQuery += 			"SUBSTRING(RC_PERIODO,1,4)+'_'+substring(RC_PERIODO,5,2) COMPETENCIA, "+Chr(13)+Chr(10)
		cQuery += 			"RC.RC_VALOR TOTAL "+Chr(13)+Chr(10)
		cQuery += 		"FROM "+RetSqlName("SRC")+"  RC, "+Chr(13)+Chr(10)
		cQuery += 			RetSqlName("SRA")+"  RA, "+Chr(13)+Chr(10)
		cQuery += 			RetSqlName("CTT")+" CTT, "+Chr(13)+Chr(10)
		cQuery += 			RetSqlName("SRJ")+"  RJ,  "+Chr(13)+Chr(10)
		cQuery += 			RetSqlName("SRV")+"  RV  "+Chr(13)+Chr(10)
		cQuery += 		"WHERE "+Chr(13)+Chr(10)
		cQuery += 			"RC.RC_FILIAL BETWEEN '"+MV_PAR02+"' AND '"+MV_PAR03+"' "+Chr(13)+Chr(10)
		cQuery += 		"AND RC.D_E_L_E_T_ = '' "+Chr(13)+Chr(10)
		cQuery += 		"AND RA.RA_FILIAL = RC.RC_FILIAL "+Chr(13)+Chr(10)
		cQuery += 		"AND RA.RA_MAT = RC.RC_MAT "+Chr(13)+Chr(10)
		cQuery += 		"AND RA.D_E_L_E_T_ = '' "+Chr(13)+Chr(10)
		cQuery += 		"AND RJ.RJ_FUNCAO = RA.RA_CODFUNC "+Chr(13)+Chr(10)
		cQuery += 		"AND RJ.D_E_L_E_T_ = '' "+Chr(13)+Chr(10)
		cQuery += 		"AND CTT.CTT_CUSTO = RA.RA_CC "+Chr(13)+Chr(10)
		cQuery += 		"AND CTT.D_E_L_E_T_ = '' "+Chr(13)+Chr(10)
		cQuery += 		"AND RV.RV_COD = RC.RC_PD "+Chr(13)+Chr(10) 
		cQuery += 		"AND RC.RC_PERIODO = '"+MV_PAR01+"' "+Chr(13)+Chr(10)
		cQuery += 		"AND RV.D_E_L_E_T_ = '' "+Chr(13)+Chr(10)
		cQuery +=		"ORDER BY "+Chr(13)+Chr(10)
		cQuery += 			"RC.RC_FILIAL, "+Chr(13)+Chr(10)
		cQuery += 			"RC.RC_CC, "+Chr(13)+Chr(10)
		cQuery += 			"RA.RA_NOME "+Chr(13)+Chr(10)

	Else
		cQuery += 		"SELECT RV.RV_XCTB CTB,RV_XCODRED XCODRED,"+Chr(13)+Chr(10)
		cQuery += 			"RD.RD_FILIAL FILIAL, "+Chr(13)+Chr(10)
		cQuery += 			"CASE WHEN RA.RA_TPCONTR = '1' THEN 'Tempo Indetermindado' ELSE 'Tempo Determinado' END TPCONTR, "+Chr(13)+Chr(10)
		cQuery += 			"RA.RA_ADMISSA ADMISSA, "+Chr(13)+Chr(10)
		cQuery += 			"RTRIM(LTRIM(RD.RD_CC))+'-'+RTRIM(LTRIM(CTT.CTT_DESC01)) CCUSTO, "+Chr(13)+Chr(10)
		cQuery += 			"RTRIM(LTRIM(RA.RA_CODFUNC))+'-'+RJ.RJ_DESC FUNCAO, "+Chr(13)+Chr(10)
		cQuery += 			"RD.RD_MAT MAT, "+Chr(13)+Chr(10)
		cQuery += 			"RD.RD_MAT+'-'+RD.RD_FILIAL MATFIL, "+Chr(13)+Chr(10) 
		cQuery += 			"CASE WHEN RA.RA_NOMECMP = '' THEN RA.RA_NOME ELSE RA.RA_NOMECMP END NOME, "+Chr(13)+Chr(10)
		//cQuery += 			"RA.RA_NOME NOME, "+Chr(13)+Chr(10)
		cQuery += 			"RD.RD_MAT+'-'+CASE WHEN RA.RA_NOMECMP = '' THEN RA.RA_NOME ELSE RA.RA_NOMECMP END MATNOME, "+Chr(13)+Chr(10)
		cQuery += 			"CASE "+Chr(13)+Chr(10)
		cQuery += 				"WHEN RV.RV_TIPOCOD = '1' THEN 'P' "+Chr(13)+Chr(10)
		cQuery += 				"WHEN RV.RV_TIPOCOD = '2' THEN 'D' "+Chr(13)+Chr(10)
		cQuery += 			"ELSE 'B' END TPVERBA, "+Chr(13)+Chr(10)
		cQuery += 			"RD.RD_PD+'-'+RV.RV_DESC VERBA, "+Chr(13)+Chr(10)
		cQuery += 			"'"+LEFT(MV_PAR01,4)+"_"+RIGHT(MV_PAR01,2)+"' COMPETENCIA, "+Chr(13)+Chr(10)
		cQuery += 			"RD.RD_VALOR TOTAL "+Chr(13)+Chr(10)
		cQuery += 		"FROM "+RetSqlName("SRD")+"  RD, "+Chr(13)+Chr(10)
		cQuery += 			RetSqlName("SRA")+"  RA, "+Chr(13)+Chr(10)
		cQuery += 			RetSqlName("CTT")+" CTT, "+Chr(13)+Chr(10)
		cQuery += 			RetSqlName("SRJ")+"  RJ,  "+Chr(13)+Chr(10)
		cQuery += 			RetSqlName("SRV")+"  RV  "+Chr(13)+Chr(10)
		cQuery += 		"WHERE "+Chr(13)+Chr(10)
		cQuery += 			"RD.RD_FILIAL BETWEEN '"+MV_PAR02+"' AND '"+MV_PAR03+"' "+Chr(13)+Chr(10)
		cQuery += 		"AND RD.D_E_L_E_T_ = '' "+Chr(13)+Chr(10)
		cQuery += 		"AND RA.RA_FILIAL = RD.RD_FILIAL "+Chr(13)+Chr(10)
		cQuery += 		"AND RA.RA_MAT = RD.RD_MAT "+Chr(13)+Chr(10)
		cQuery += 		"AND RA.D_E_L_E_T_ = '' "+Chr(13)+Chr(10)
		cQuery += 		"AND RJ.RJ_FUNCAO = RA.RA_CODFUNC "+Chr(13)+Chr(10)
		cQuery += 		"AND RJ.D_E_L_E_T_ = '' "+Chr(13)+Chr(10)
		cQuery += 		"AND CTT.CTT_CUSTO = RA.RA_CC "+Chr(13)+Chr(10)
		cQuery += 		"AND CTT.D_E_L_E_T_ = '' "+Chr(13)+Chr(10)
		cQuery += 		"AND RD.RD_PERIODO = '"+MV_PAR01+"' "+Chr(13)+Chr(10)
		cQuery += 		"AND RV.RV_COD = RD.RD_PD "+Chr(13)+Chr(10)
		cQuery += 		"AND RV.D_E_L_E_T_ = '' AND RD.RD_ROTEIR='FOL'"+Chr(13)+Chr(10)
		cQuery +=		"ORDER BY "+Chr(13)+Chr(10)
		cQuery += 			"RD.RD_FILIAL, "+Chr(13)+Chr(10)
		cQuery += 			"RD.RD_CC, "+Chr(13)+Chr(10)
		cQuery += 			"RA.RA_NOME "+Chr(13)+Chr(10)

	EndIf

	If Select("TRB") <> 0
		dbSelectArea("TRB")
		dbCloseArea()
	EndIf

	dbUseArea( .t. , "TOPCONN" , TcGenQry(,,cQuery) , "TRB" , .T. , .T. )

	dbSelectArea("TRB")
	dbGotop()
	TRB->(dbEval( { || nReg++ } ,, { || !Eof() } ))
	dbGotop()

	If nReg == 0

		Alert("Nenhum registro foi selecionado. Verifique os Parโmetros!")

		dbSelectArea("TRB")
		dbCloseArea()

		Return()

	EndIf

	Planilha(nReg)

Return()


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPlanilha  บAutor  ณTiago Caires        บ Data ณ  11/09/2015 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Exporta Planilha                                           บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Uso especifico April Brasil                                บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function Planilha(nRegs)

	Local aXML		:= {}
	Local i			:= 0
	Local cPlanilha	:= StrTran(StrTran(Upper(Alltrim(MV_PAR04)+"\"+Alltrim(MV_PAR05)+".XML"),"\\","\"),".XML.XML",".XML")
	Local nHdlPla	:= -1
	Local cLinha	:= ""
	Local nPos		:= 0
	Local nValor	:= 0
	Local oExcel := FWMSEXCEL():New()

	While nHdlPla == -1

		If File(cPlanilha)
			fErase(cPlanilha)
		EndIf

		nHdlPla := fCreate(cPlanilha)

		If nHdlPla == -1

			cMsg := "O arquivo "+cPlanilha+" estแ aberto ou"+chr(13)+chr(10)+"a pasta nใo foi criada!"

			If !MsgNoYes(cMsg+chr(13)+chr(10)+"Continua? ","Aten็ใo")

				dbSelectArea("TRB")
				dbCloseArea()
				Return()

			EndIf

		EndIf

	EndDo

	ProcRegua(nRegs)

	// Montagem das colunas

	aAdd(aXML,'<?xml version="1.0"?>')
	aAdd(aXML,'<?mso-application progid="Excel.Sheet"?>')
	aAdd(aXML,'<Workbook xmlns="urn:schemas-microsoft-com:office:spreadsheet"')
	aAdd(aXML,' xmlns:o="urn:schemas-microsoft-com:office:office"')
	aAdd(aXML,' xmlns:x="urn:schemas-microsoft-com:office:excel"')
	aAdd(aXML,' xmlns:ss="urn:schemas-microsoft-com:office:spreadsheet"')
	aAdd(aXML,' xmlns:html="http://www.w3.org/TR/REC-html40">')
	aAdd(aXML,' <DocumentProperties xmlns="urn:schemas-microsoft-com:office:office">')
	aadd(aXML,'  <Author>'+Alltrim("Protheus_11_"+PSWRet()[1,4])+'</Author>')
	aadd(aXML,'  <LastAuthor>'+Alltrim(PSWRet()[1,2])+'</LastAuthor>')
	aadd(aXML,'  <Created>'+Left(DtoS(Date()),4)+"-"+subs(DtoS(Date()),5,2)+"-"+Right(DtoS(Date()),2)+"T"+time()+"Z"+'</Created>')
	aadd(aXML,'  <LastSaved>'+Left(DtoS(Date()),4)+"-"+subs(DtoS(Date()),5,2)+"-"+Right(DtoS(Date()),2)+"T"+time()+"Z"+'</LastSaved>')
	aAdd(aXML,'  <Version>14.00</Version>')
	aAdd(aXML,' </DocumentProperties>')
	aAdd(aXML,' <OfficeDocumentSettings xmlns="urn:schemas-microsoft-com:office:office">')
	aAdd(aXML,'  <AllowPNG/>')
	aAdd(aXML,' </OfficeDocumentSettings>')
	aAdd(aXML,' <ExcelWorkbook xmlns="urn:schemas-microsoft-com:office:excel">')
	aAdd(aXML,'  <WindowHeight>7230</WindowHeight>')
	aAdd(aXML,'  <WindowWidth>20115</WindowWidth>')
	aAdd(aXML,'  <WindowTopX>240</WindowTopX>')
	aAdd(aXML,'  <WindowTopY>105</WindowTopY>')
	aAdd(aXML,'  <ProtectStructure>False</ProtectStructure>')
	aAdd(aXML,'  <ProtectWindows>False</ProtectWindows>')
	aAdd(aXML,' </ExcelWorkbook>')
	aAdd(aXML,' <Styles>')
	aAdd(aXML,'  <Style ss:ID="Default" ss:Name="Normal">')
	aAdd(aXML,'   <Alignment ss:Vertical="Bottom"/>')
	aAdd(aXML,'   <Borders/>')
	aAdd(aXML,'   <Font ss:FontName="Calibri" x:Family="Swiss" ss:Size="11" ss:Color="#000000"/>')
	aAdd(aXML,'   <Interior/>')
	aAdd(aXML,'   <NumberFormat/>')
	aAdd(aXML,'   <Protection/>')
	aAdd(aXML,'  </Style>')
	aAdd(aXML,'  <Style ss:ID="s16" ss:Name="Vํrgula">')
	aAdd(aXML,'   <NumberFormat ss:Format="_-* #,##0.00_-;\-* #,##0.00_-;_-* &quot;-&quot;??_-;_-@_-"/>')
	aAdd(aXML,'  </Style>')
	aAdd(aXML,'  <Style ss:ID="s65">')
	aAdd(aXML,'   <Interior ss:Color="#A6A6A6" ss:Pattern="Solid"/>')
	aAdd(aXML,'  </Style>')
	aAdd(aXML,'  <Style ss:ID="s66">')
	aAdd(aXML,'   <NumberFormat ss:Format="Short Date"/>')
	aAdd(aXML,'  </Style>')
	aAdd(aXML,'  <Style ss:ID="s67" ss:Parent="s16">')
	aAdd(aXML,'   <Font ss:FontName="Calibri" x:Family="Swiss" ss:Size="11" ss:Color="#000000"/>')
	aAdd(aXML,'  </Style>')
	aAdd(aXML,' </Styles>')
	aAdd(aXML,' <Worksheet ss:Name="Folha_aaaamm">')
	aAdd(aXML,'  <Table ss:ExpandedColumnCount="15" ss:ExpandedRowCount="'+Alltrim(Str(1+nRegs,0))+'" x:FullColumns="1"')
	aAdd(aXML,'   x:FullRows="1" ss:DefaultRowHeight="15">')
	aAdd(aXML,'   <Column ss:Width="32.25"/>')
	aAdd(aXML,'   <Column ss:Width="99" ss:Span="1"/>')
	aAdd(aXML,'   <Column ss:Index="4" ss:Width="257.25"/>')
	aAdd(aXML,'   <Column ss:Width="179.25"/>')
	aAdd(aXML,'   <Column ss:Width="59.25"/>')
	aAdd(aXML,'   <Column ss:Width="97.5"/>')
	aAdd(aXML,'   <Column ss:Width="221.25"/>')
	aAdd(aXML,'   <Column ss:Width="257.25"/>')
	aAdd(aXML,'   <Column ss:Width="75"/>')
	aAdd(aXML,'   <Column ss:Width="240.75"/>')
	aAdd(aXML,'   <Column ss:Width="81.75"/>')
	aAdd(aXML,'   <Column ss:Width="81"/>')
	aAdd(aXML,'   <Column ss:Width="73.5"/>')
	aAdd(aXML,'   <Column ss:Width="75"/>')
	aAdd(aXML,'   <Row>')
	aAdd(aXML,'    <Cell ss:StyleID="s65"><Data ss:Type="String">FILIAL</Data></Cell>')
	aAdd(aXML,'    <Cell ss:StyleID="s65"><Data ss:Type="String">TIPO DE CONTRATO</Data></Cell>')
	aAdd(aXML,'    <Cell ss:StyleID="s65"><Data ss:Type="String">DATA DE ADMISS&Atilde;O</Data></Cell>')
	aAdd(aXML,'    <Cell ss:StyleID="s65"><Data ss:Type="String">COD C.C.+DESCRI&Ccedil;&Atilde;O</Data></Cell>')
	aAdd(aXML,'    <Cell ss:StyleID="s65"><Data ss:Type="String">DESCRI&Ccedil;&Atilde;O DA FUN&Ccedil;&Atilde;O</Data></Cell>')
	aAdd(aXML,'    <Cell ss:StyleID="s65"><Data ss:Type="String">MATR&Iacute;CULA</Data></Cell>')
	aAdd(aXML,'    <Cell ss:StyleID="s65"><Data ss:Type="String">MATR&Iacute;CULA + FILIAL</Data></Cell>')
	aAdd(aXML,'    <Cell ss:StyleID="s65"><Data ss:Type="String">NOME</Data></Cell>')
	aAdd(aXML,'    <Cell ss:StyleID="s65"><Data ss:Type="String">MAT+NOME</Data></Cell>')
	aAdd(aXML,'    <Cell ss:StyleID="s65"><Data ss:Type="String">TIPO DE VERBA</Data></Cell>')
	aAdd(aXML,'    <Cell ss:StyleID="s65"><Data ss:Type="String">COD VERBA+NOME</Data></Cell>')
	aAdd(aXML,'    <Cell ss:StyleID="s65"><Data ss:Type="String">COD CONTA D&Eacute;B</Data></Cell>')
	//aAdd(aXML,'    <Cell ss:StyleID="s65"><Data ss:Type="String">COD CONTA CRE</Data></Cell>')
	//aAdd(aXML,'    <Cell ss:StyleID="s65"><Data ss:Type="String">COMPET&Ecirc;NCIA</Data></Cell>')
	aAdd(aXML,'    <Cell ss:StyleID="s65"><Data ss:Type="String">TOTAL</Data></Cell>')
	aAdd(aXML,'   </Row>')


	For i := 1 to Len(aXML)

		cLinha := aXML[i]+Chr(13)+chr(10)

		If fWrite(nHdlPla,cLinha,Len(cLinha)) != Len(cLinha)

			Alert("Ocorreu um erro na gravacao da Plainlha. Programa serแ abortadodo.","Atencao!")
			fClose(nHdlPla)
			fErase(cPlanilha)
			lRet := .f.
			Return()

		Endif

	Next i

	aXML := {}

	nCont := 0

	cTitulo := "Gerando XML(Salvar Planilha como Excel)"

	While !TRB->(EOF())
		IncProc(Alltrim(TRB->FILIAL)+" "+Alltrim(TRB->MAT+" - Andamento : " + AllTrim(Str(ROUND(100 / nRegs * nCont,2))) + " %"))

		aAdd(aXML,'   <Row>')
		aAdd(aXML,'    <Cell><Data ss:Type="String">'+TRB->FILIAL+'</Data></Cell>')
		aAdd(aXML,'    <Cell><Data ss:Type="String">'+TRB->TPCONTR+'</Data></Cell>')
		aAdd(aXML,'    <Cell ss:StyleID="s66"><Data ss:Type="DateTime">'+LEFT(TRB->ADMISSA,4)+'-'+SUBS(TRB->ADMISSA,5,2)+'-'+RIGHT(TRB->ADMISSA,2)+'T00:00:00.000</Data></Cell>')
		aAdd(aXML,'    <Cell><Data ss:Type="String">'+Alltrim(TRB->CCUSTO)+'</Data></Cell>')
		aAdd(aXML,'    <Cell><Data ss:Type="String">'+Alltrim(TRB->FUNCAO)+'</Data></Cell>')
		aAdd(aXML,'    <Cell><Data ss:Type="String">'+Alltrim(TRB->MAT)+'</Data></Cell>')
		aAdd(aXML,'    <Cell><Data ss:Type="String">'+Alltrim(TRB->MATFIL)+'</Data></Cell>')
		aAdd(aXML,'    <Cell><Data ss:Type="String">'+Alltrim(TRB->NOME)+'</Data></Cell>')
		aAdd(aXML,'    <Cell><Data ss:Type="String">'+Alltrim(TRB->MATNOME)+'</Data></Cell>')
		aAdd(aXML,'    <Cell><Data ss:Type="String">'+Alltrim(TRB->TPVERBA)+'</Data></Cell>')
		aAdd(aXML,'    <Cell><Data ss:Type="String">'+Alltrim(TRB->VERBA)+'</Data></Cell>')
		//aAdd(aXML,'    <Cell><Data ss:Type="String">'+TRB->DEBITO+'</Data></Cell>')
		//aAdd(aXML,'    <Cell><Data ss:Type="String">'+TRB->CREDITO+'</Data></Cell>')
		aAdd(aXML,'    <Cell><Data ss:Type="String">'+TRB->COMPETENCIA+'</Data></Cell>')
		aAdd(aXML,'    <Cell ss:StyleID="s67"><Data ss:Type="Number">'+STRTRAN(ALLTRIM(STR(TRB->TOTAL,15,2)),",",".")+'</Data></Cell>')
		aAdd(aXML,'   </Row>')

		nCont++

		If nCont == 200

			For i := 1 to Len(aXML)

				cLinha := aXML[i]+Chr(13)+chr(10)

				If fWrite(nHdlPla,cLinha,Len(cLinha)) != Len(cLinha)

					Alert("Ocorreu um erro na gravacao da Plainlha. Programa serแ abortadodo.","Atencao!")
					fClose(nHdlPla)
					fErase(cPlanilha)
					lRet := .f.
					Return()

				Endif

			Next i

			aXML := {}

			nCont := 0

		EndIf

		dbSelectArea("TRB")	
		dbSkip()

	EndDo

	aAdd(aXML,'  </Table>')
	aAdd(aXML,'  <WorksheetOptions xmlns="urn:schemas-microsoft-com:office:excel">')
	aAdd(aXML,'   <PageSetup>')
	aAdd(aXML,'    <Header x:Margin="0.31496062000000002"/>')
	aAdd(aXML,'    <Footer x:Margin="0.31496062000000002"/>')
	aAdd(aXML,'    <PageMargins x:Bottom="0.78740157499999996" x:Left="0.511811024"')
	aAdd(aXML,'     x:Right="0.511811024" x:Top="0.78740157499999996"/>')
	aAdd(aXML,'   </PageSetup>')
	aAdd(aXML,'   <Selected/>')
	aAdd(aXML,'   <FreezePanes/>')
	aAdd(aXML,'   <FrozenNoSplit/>')
	aAdd(aXML,'   <SplitHorizontal>1</SplitHorizontal>')
	aAdd(aXML,'   <TopRowBottomPane>1</TopRowBottomPane>')
	aAdd(aXML,'   <ActivePane>2</ActivePane>')
	aAdd(aXML,'   <Panes>')
	aAdd(aXML,'    <Pane>')
	aAdd(aXML,'     <Number>3</Number>')
	aAdd(aXML,'    </Pane>')
	aAdd(aXML,'    <Pane>')
	aAdd(aXML,'     <Number>2</Number>')
	aAdd(aXML,'    </Pane>')
	aAdd(aXML,'   </Panes>')
	aAdd(aXML,'   <ProtectObjects>False</ProtectObjects>')
	aAdd(aXML,'   <ProtectScenarios>False</ProtectScenarios>')
	aAdd(aXML,'  </WorksheetOptions>')
	aAdd(aXML,' </Worksheet>')
	aAdd(aXML,'</Workbook>')


	For i := 1 to Len(aXML)

		cLinha := aXML[i]+Chr(13)+chr(10)

		If fWrite(nHdlPla,cLinha,Len(cLinha)) != Len(cLinha)

			Alert("Ocorreu um erro na gravacao da Plainlha. Programa serแ abortadodo.","Atencao!")
			fClose(nHdlPla)
			fErase(cPlanilha)
			lRet := .f.
			Return()

		Endif

	Next i

	aXML := {}

	dbSelectArea("TRB")
	dbCloseArea()

	fClose(nHdlPla)

	If ! ApOleClient( 'MsExcel' )
		MsgAlert( 'MsExcel nao instalado' )
	Else
		oExcelApp := MsExcel():New()
		oExcelApp:WorkBooks:Open( cPlanilha )
		oExcelApp:SetVisible(.T.)
	EndIf

Return()
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuncao    ณCriaSX1   บAutor  ณTiago Caires        บ Data ณ  11/09/2015 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Gera o conjunto de Perguntas da rotina caso nใo existam    บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Uso especifico April Brasil                                บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function CriaSx1(cPerg)

	Local aArea	:= GetArea()

	Local aP:= {}
	Local i:= 0
	Local cSeq
	Local cMvCh
	Local cMvPar
	Local aHelp:= {}

	aAdd(aP,{"Data de Refer๊ncia ","C",06,0,"G","                                 ",""      ,""           ,""           ,"","","",""})
	aAdd(aP,{"Filial De          ","C",04,0,"C","                                 ","SM0"   ,""           ,""           ,"","","",""})
	aAdd(aP,{"Filial At้         ","C",04,0,"C","                                 ","SM0"   ,""           ,""           ,"","","",""})
	aAdd(aP,{"Caminho da planilha","C",99,0,"G","CS040DIR().AND.(!Empty(mv_par04))",""      ,""           ,""           ,"","","",""})
	aAdd(aP,{"Nome (Sem Extensใo)","C",10,0,"G","(!Empty(mv_par05))               ",""      ,""           ,""           ,"","","",""})

	aAdd(aHelp,{"Informe o AAAAMM referente ao","perํodo para sele็ใo dos valores.","Exemplo: 201507 = Jul/2015","         2014/13 = 13o. Sal/2014 "})
	aAdd(aHelp,{"Informe a Filial Inicial","para sele็ใo dos dados"})
	aAdd(aHelp,{"Informe a Filial Final","para sele็ใo dos dados"})
	aAdd(aHelp,{"Informe o caminho do arquivo","para gera็ใo da planilha (*.xml).","Ex. 'c:\excel'"})
	aAdd(aHelp,{"Informe o Nome do arquivo","para gera็ใo da planilha (*.xml).","Nใo precisa informar a extensใo.","Ex. 'Folha201509'"})

	For i:=1 To Len(aP)
		cSeq   := StrZero(i,2,0)
		cMvPar := "mv_par"+cSeq
		cMvCh  := "mv_ch"+IIF(i<=9,Chr(i+48),Chr(i+87))
		PutSx1(cPerg,;
		cSeq,;
		aP[i,1],aP[i,1],aP[i,1],;
		cMvCh,;
		aP[i,2],;
		aP[i,3],;
		aP[i,4],;
		0,;
		aP[i,5],;
		aP[i,6],;
		aP[i,7],;
		"",;
		"",;
		cMvPar,;
		aP[i,8],aP[i,8],aP[i,8],;
		"",;
		aP[i,9],aP[i,9],aP[i,9],;
		aP[i,10],aP[i,10],aP[i,10],;
		aP[i,11],aP[i,11],aP[i,11],;
		aP[i,12],aP[i,12],aP[i,12],;
		aHelp[i],;
		{},;
		"")
	Next i

	RestArea(aArea)

Return()

User Function ProvMes(cTipo, cMatr, cUnid)

	Local nValor := 0
	If cTipo == '1'
		cQuery := " SELECT RT_VALOR - (SELECT RT_VALOR FROM "+RetSQlName("SRT")+" WHERE RT_MAT = '"+cMatr+"' AND D_E_L_E_T_<>'*' AND RT_TIPPROV='2'  and RT_FILIAL ='"+cUnid+"' AND RT_VERBA='750' "
		cQuery += " AND SUBSTRing(RT_DATACAL,1,6) = '201808' ) AS VALOR FROM "+RetSQlName("SRT")+" WHERE RT_MAT = '"+cMatr+"' AND RT_TIPPROV='2' AND D_E_L_E_T_<>'*' and RT_FILIAL ='"+cUnid+"' AND RT_VERBA='750'"
		cQuery += " AND SUBSTRing(RT_DATACAL,1,6) = '201809' "

	ElseIf cTipo == '2' // 881
		cQuery := " SELECT RT_VALOR - (SELECT RT_VALOR FROM "+RetSQlName("SRT")+" WHERE RT_MAT = '"+cMatr+"' AND D_E_L_E_T_<>'*' AND RT_TIPPROV='2' and RT_FILIAL ='"+cUnid+"' AND RT_VERBA='825' "
		cQuery += " AND SUBSTRing(RT_DATACAL,1,6) = '201808' ) AS VALOR FROM "+RetSQlName("SRT")+" WHERE RT_MAT = '"+cMatr+"' AND D_E_L_E_T_<>'*' AND RT_TIPPROV='2' and RT_FILIAL ='"+cUnid+"' AND RT_VERBA='825'"
		cQuery += " AND SUBSTRing(RT_DATACAL,1,6) = '201809' "

	ElseIf cTipo == '3' //882
		cQuery := " SELECT RT_VALOR - (SELECT RT_VALOR FROM "+RetSQlName("SRT")+" WHERE RT_MAT = '"+cMatr+"' AND D_E_L_E_T_<>'*' AND RT_TIPPROV='2'  and RT_FILIAL ='"+cUnid+"' AND RT_VERBA='826' "
		cQuery += " AND SUBSTRing(RT_DATACAL,1,6) = '201808' ) AS VALOR FROM "+RetSQlName("SRT")+" WHERE RT_MAT = '"+cMatr+"' AND RT_TIPPROV='2'  AND D_E_L_E_T_<>'*' and RT_FILIAL ='"+cUnid+"' AND RT_VERBA='826'"
		cQuery += " AND SUBSTRing(RT_DATACAL,1,6) = '201809' "

	ElseIf cTipo == '4' //883
		cQuery := " SELECT RT_VALOR - (SELECT RT_VALOR FROM "+RetSQlName("SRT")+" WHERE RT_MAT = '"+cMatr+"' AND D_E_L_E_T_<>'*' AND RT_TIPPROV='2'  and RT_FILIAL ='"+cUnid+"' AND RT_VERBA='751' "
		cQuery += " AND SUBSTRing(RT_DATACAL,1,6) = '201808' ) AS VALOR FROM "+RetSQlName("SRT")+" WHERE RT_MAT = '"+cMatr+"' AND RT_TIPPROV='2'  AND D_E_L_E_T_<>'*' and RT_FILIAL ='"+cUnid+"' AND RT_VERBA='751'"
		cQuery += " AND SUBSTRing(RT_DATACAL,1,6) = '201809' "
	Else
		cQuery := " SELECT RT_VALOR - (SELECT RT_VALOR FROM "+RetSQlName("SRT")+" WHERE RT_MAT = '"+cMatr+"' AND D_E_L_E_T_<>'*' AND RT_TIPPROV='2' and RT_FILIAL ='"+cUnid+"' AND RT_VERBA='752' "
		cQuery += " AND SUBSTRing(RT_DATACAL,1,6) = '201808' ) AS VALOR FROM "+RetSQlName("SRT")+" WHERE RT_MAT = '"+cMatr+"' AND D_E_L_E_T_<>'*' AND RT_TIPPROV='2' and RT_FILIAL ='"+cUnid+"' AND RT_VERBA='752'"
		cQuery += " AND SUBSTRing(RT_DATACAL,1,6) = '201809' "	

	EndIf
	//Verificando se a query estแ aberta na mem๓ria 
	If Select('TRB2') <> 0 
		TRB2->(DbCloseArea()) 
	EndIf 

	TCQUERY cQuery NEW ALIAS 'TRB2'

	nValor := TRB2->VALOR

Return nValor
