#INCLUDE "RWMAKE.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "PROTHEUS.CH"

//----------------------------------------------------------------
/*/{Protheus.doc} PJESPA01
Pesquisa customizada de clientes
Pesquisa por parte do nome ou CPF/CNPJ

@author Rafael Domingues
@since 04.08.2017

@author Andre /TNU
@since 11/10/17
@Data 11/10/17 - Corrigir error log, acertei na posição para novas incluções e cancelamento

/*/
//----------------------------------------------------------------

User Function PJESPA01( cTitulo, cAlias, nStartOrdem, cCampoDefault, _cFiltro, _lVisu, _lIncl)

Local cTexto 		:= SPACE(60), nOrdem := nStartOrdem
Local lOk 			:= .F., aCombo, oCombo1, oFiltrar, aRadio
Local nMarca 		:= &(cAlias)->(Recno()), nOldOrd := &(cAlias)->(IndexOrd())
Local aGrid     	:= {}
Local aFiltrar  	:= {}
Local aNFiltrar 	:= {}
Local nFiltrar  	:= 1
Local nSeq      	:= 1
Local LinProd   	:= 0

Private aHeadSA1 	:= {}
Private aColSA1 	:= {}
Private nPosCgc		:= 0
Private nPosNome    := 0  
Private nPosCod     := 0 
Private nPosLoj     := 0

If _lVisu == nil
	_lVisu := .F.
EndIf

If _lIncl == nil
	_lIncl := .T.
EndIf

If _cFiltro == nil
	_cFiltro := ""
EndIF

&(cAlias)->(dbSetOrder(nStartOrdem))
@ 0,0 To 542,790 Dialog mkwdlg Title OemToAnsi(cTitulo)
@ 0.5,0.7 say "Digite parte do Nome ou CPF/CNPJ ou Codigo " OF mkwdlg
nRadio := 2
@ 20,05 GET cTexto Picture "@!" Valid ATUCOSA1(, cTexto, aFiltrar[nFiltrar], nRadio) Object oTexto
_cCampos := "A1_COD,A1_LOJA,A1_NOME,A1_NREDUZ,A1_CGC,A1_END, A1_MUN,A1_EST"
_lVisu   := .T.

Aadd(aHeadSA1, {"Status","cMostra", "@BMP", 2, 0, ".F." ,""    , "C", "", "V" ,"" , "","","V"})
Aadd(aHeadSA1, {rtrim(rettitle("A1_COD"))	, "A1_COD"	, "@!" , TamSX3("A1_COD")[1],   TamSX3("A1_COD")[2] ,,, "C","" , "V",,,,"V", ""})
Aadd(aHeadSA1, {rtrim(rettitle("A1_LOJA"))	, "A1_LOJA"	, "@!" , TamSX3("A1_LOJA")[1],   TamSX3("A1_LOJA")[2] ,,, "C","" , "V",,,,"V", ""})
Aadd(aHeadSA1, {rtrim(rettitle("A1_NREDUZ"))	, "A1_NREDUZ"	, "@!" , /*TamSX3("B1_DESC")[1]*/50,  TamSX3("A1_NREDUZ")[2],,, "C","" , "V",,,,"V", ""})
Aadd(aHeadSA1, {rtrim(rettitle("A1_CGC"))	, "A1_CGC"	, "@!" , /*TamSX3("B1_DESC")[1]*/50,  TamSX3("A1_CGC")[2],,, "C","" , "V",,,,"V", ""})
Aadd(aHeadSA1, {rtrim(rettitle("A1_NOME"))	, "A1_NOME"	, "@!" , /*TamSX3("B1_DESC")[1]*/50,  TamSX3("A1_NOME")[2],,, "C","" , "V",,,,"V", ""})
Aadd(aHeadSA1, {rtrim(rettitle("A1_END"))	, "A1_END"	, "@!" , TamSX3("A1_END")[1],  TamSX3("A1_END")[2],,, "C","" , "V",,,,"V", ""})
Aadd(aHeadSA1, {rtrim(rettitle("A1_MUN"))	, "A1_MUN"	, "@!" , TamSX3("A1_MUN")[1],  TamSX3("A1_MUN")[2],,, "C","" , "V",,,,"V", ""})
Aadd(aHeadSA1, {rtrim(rettitle("A1_EST"))	, "A1_EST"	, "@!" , TamSX3("A1_EST")[1],  TamSX3("A1_EST")[2],,, "C","" , "V",,,,"V", ""})


nPosCod  := aScan(aHeadSA1, {|aVet| AllTrim(aVet[2]) == "A1_COD"})
nPosNome := aScan(aHeadSA1, {|aVet| AllTrim(aVet[2]) == "A1_NOME"})
nPosCgc  := aScan(aHeadSA1, {|aVet| AllTrim(aVet[2]) == "A1_CGC"})
nPosLoj  := aScan(aHeadSA1, {|aVet| AllTrim(aVet[2]) == "A1_LOJA"})

ATUCOSA1(.T.)

If cAlias<>"SA1"
	DbSelectArea("SIX")
	DbSeek(cAlias)
	aCombo := {}
	Do While SIX->INDICE == cAlias
		AADD(aCombo,SIX->DESCRICAO)
		DbSkip()
	EndDo
Else
	aCombo := {}
	AADD(aCombo,"Codigo")
	AADD(aCombo,"Nome")
	AADD(aCombo,"CNPJ")
Endif

DbSelectArea("SX3")
DbSetOrder(1)
DbSeek(cAlias,.T.)
Do While X3_ARQUIVO == cAlias
	If X3_BROWSE == "S" .AND. X3_CONTEXT <> "V" .AND. (Empty(_cCampos) .OR. (AllTrim(X3_CAMPO)$_cCampos))
		AADD(aGrid,{X3_CAMPO,X3_DESCRIC,X3_PICTURE})
		
		If X3_TIPO == "C"
			AADD(aFiltrar ,X3_CAMPO)
			AADD(aNFiltrar,X3_DESCRIC)
			If AllTrim(X3_CAMPO) == cCampoDefault
				nFiltrar := nSeq
			EndIf
			nSeq++
		EndIf
	EndIf
	DbSkip()
EndDo

DbSelectArea(cAlias)

oABC := MsNewGetDados():New(45, 1, 240, 397,0,,, ,,,,,,,, aHeadSA1, aColSA1)
oABC:oBrowse:bchange:= {||    nLinProd := oABC:oBrowse:nAt }

@ 250,147 Button OemToAnsi("_Legenda") Size 36,12 Action Eval({|| tLegenda(), Close(mkwdlg)})  Object obj02
@ 250,189 Button OemToAnsi("_Ok") Size 36,12 Action Eval({|| lOk:= .T., Close(mkwdlg)})  Object obj02
@ 250,231 Button OemToAnsi("_Incluir Novo") Size 36,12 Action fIncluir(cAlias) Object obj01
@ 250,273 Button OemToAnsi("_Visualizar") Size 36,12 Action fVisualizar(cAlias) Object obj01
@ 250,315 Button OemToAnsi("_Fechar") Size 36,12 Action Close(mkwdlg) Object obj03

oABC:oBrowse:blDblClick := {|| RETSA1(), lOk:= .T., Close(mkwdlg)}
oABC:oBrowse:lColDrag   := .t.

oTexto:SetFocus()
Activate Dialog mkwdlg CENTERED

If Empty(Alias())
	RETSA1(nLinProd)
Endif

nPosicionar := Recno()
DbSelectArea(cAlias)
&(cAlias)->(DbClearFil())
DbSetOrder(nOldOrd)

If lOk
	DbGoTo(nPosicionar)
Else
	DbGoTo(nMarca)
EndIf

Return lOk

Static Function fVisualizar(_cAlias)

Local aArea := GetArea()

RETSA1()

AxVisual(_cAlias,Recno(),2)
RestArea(aArea)

Return

Static Function fIncluir(_cAlias)

Local aArea     := GetArea()
Local lbkpInclui
Local lbkpAltera
Local lMarcInc := .F.
Local lMarcAlt := .F.

If !Type("INCLUI") == "U"
	lMarcInc   := .T.
	lbkpInclui := INCLUI
Endif
If !Type("ALTERA") == "U"
	lMarcAlt   := .T.
	lbkpAltera := ALTERA
Endif
Inclui := .T.
DbSelectArea(_cAlias)
AxInclui(_cAlias,Recno(),3)

If lMarcInc
	INCLUI := lbkpInclui
Endif

If lMarcAlt
	ALTERA := lbkpAltera
Endif

RestArea(aArea)

Return

Static Function ATUCOSA1(lInicio, cTexto, cCampo, nTipo)
Local  cSQL      := ""

Default lInicio := .F.
Default cCampo  := ""
Default cTexto  := ""
Default nTipo   := 2

/*Alterado por Xavier 04/10/2017
# incluso a legenda para verificar se o cliente possui titulo vencido  linha 179 a 220
# corrigido o erro de array of bounds no bLine devido não esta sendo passado um unico array e sim 22 arrays*/

cSQL := "SELECT TOP 30 CASE  ( SELECT  COUNT(*)  FROM " + retSqlName("SE1") + " SE1  (NOLOCK)" + CRLF
cSQL += "   			WHERE SE1.D_E_L_E_T_ = '' " + CRLF
cSQL += "   			AND SE1.E1_VENCREA > '" +dtos(dDataBase)+"'" + CRLF
cSQL += "   			AND SE1.E1_SALDO > 0 " + CRLF
cSQL += "  				AND SE1.E1_BAIXA   = '' " + CRLF
cSQL += "   			AND SE1.E1_CLIENTE = SA1.A1_COD " + CRLF
cSQL += "				AND SE1.E1_LOJA    = SA1.A1_LOJA " + CRLF
cSQL += "   			AND SE1.E1_FILIAL = '"+xFilial("SE1")+"') " + CRLF
cSQL += "  		WHEN 0 THEN 'br_verde' " +  CRLF
cSQL += " 			ELSE  'br_vermelho' " + CRLF
cSQL += " 		END AS LEGENDA ,     "+ CRLF
//cSQL += " A1_COD, A1_NOME, A1_CGC, A1_LOJA"+ CRLF
cSQL += " A1_COD,A1_LOJA,A1_NOME,A1_NREDUZ,A1_CGC,A1_END, A1_MUN,A1_EST"+ CRLF
cSQL += " FROM" + RetSQLName("SA1") + " SA1  (NOLOCK)" + CRLF
cSQL += " WHERE SA1.A1_FILIAL = '" + xFilial("SA1") + "'"+ CRLF
cSQL += " AND SA1.D_E_L_E_T_ <> '*' AND SA1.A1_MSBLQL <> '1' "  + CRLF

If !Empty(cTexto)
	cSQL +=  " AND SA1.A1_NOME LIKE '%"+AllTrim(cTexto)+"%' OR SA1.A1_CGC LIKE '%"+AllTrim(cTexto)+"%' "+ CRLF
	cSql += "  OR SA1.A1_COD LIKE '%"+AllTrim(cTexto)+"%' " + CRLF
Endif

cSQL += " ORDER BY SA1.A1_COD "+ CRLF
cSQL := ChangeQuery(cSQL)

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSQL),"TMP",.T.,.T.)

DbSelectArea("TMP")
aColSA1 := {}

While TMP->(!Eof())
	//A1_COD,A1_LOJA,A1_NOME,A1_NREDUZ,A1_CGC,A1_END, A1_MUN,A1_EST
	AADD(aColSA1,{TMP->LEGENDA ,;
				  TMP->A1_COD,;
				  TMP->A1_LOJA,;
	 			  TMP->A1_NREDUZ,;
	 			  TMP->A1_CGC,;
	 			  TMP->A1_NOME,;	 			  
	 			  TMP->A1_END,;
	 			  TMP->A1_MUN,;
	 			  TMP->A1_EST ,.F.})
	TMP->(DbSkip())
EndDo

TMP->(DbCloseArea())

If !lInicio
	oABC:aCols := {}
	oABC:aCols := aClone(aColSA1)
	oABC:oBrowse:Refresh()
Endif

Return(.T.)

Static Function RETSA1(nLinProd)

local cSeek := ""
Default nLinProd := 0

If Len(oABC:aCols)>0
	
	DbSelectArea("SA1")
	SA1->(DbSetOrder(RetOrder("SA1","A1_FILIAL+A1_COD+A1_LOJA")))
	
	cSeek := xFilial("SA1") +  oABC:aCols[IIF(nLinProd == 0, oABC:oBrowse:nAt, nLinProd), nPosCod]
	cSeek += oABC:aCols[IIF(nLinProd == 0, oABC:oBrowse:nAt, nLinProd), nPosLoj]
	
	If SA1->(msseek(cSeek))
		
		IF ( Type("M->UA_LOJA") <> "U" )
			M->UA_LOJA := SA1->A1_LOJA
		EndIF
	
	EndIF

EndIf

Return(.T.)


User Function RetSx()

If(ReadVar() == 'M->UA_XOPER' .OR. ReadVar() == 'M->UA_CLIENTE' )
	return GetAdvFVal("SX5","X5_DESCRI", xFilial("SX5")+"DJ"+M->UA_XOPER)
Endif

Return cRet

User Function RetModal()

	If(ReadVar() == 'M->UA_XMODAL' .OR. ReadVar() == 'M->UA_CLIENTE' )
			return GetAdvFVal("SZA","ZA_DESCR", xFilial("SZA")+M->UA_XMODAL)
	Endif 

Return

/* 
Author ...: Xavier 22/11/2017
Motivo ...: Identificar Legenda da consulta de cliente 

*/

static function tLegenda()
Local aLegenda := {}

aAdd( aLegenda, { "BR_VERDE"		, "Sem Titulos em Atraso" })
aAdd( aLegenda, { "BR_VERMELHO"		, "Com Titulos em Atraso" })

Return( BrwLegenda( "Título", "Legenda", aLegenda ) )