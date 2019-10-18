#INCLUDE "PROTHEUS.CH"
#INCLUDE 'Fileio.ch'
#INCLUDE "TOPCONN.CH"

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑบPrograma  ณ LISTSE1  บAutor  ณEduardo Augusto     บ Data ณ  26/09/2014 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Fonte para Tela de Impressใo de Boletos com filtros para   บฑฑ
ฑฑบ          ณ Sele็ใo dos titulos da Tabela SE1 (Contas a Receber).      บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP								                          บฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/

User Function TELABOL()  

Local cTitulo  := "SELEวรO DE BOLETOS"
Local oOk := LoadBitmap(GetResources(),"LBOK")
Local oNo := LoadBitmap(GetResources(),"LBNO")
Local cVar
Local oDlg
Local oChk
Local oLbx
Local lChk 		:= .F.
Local lMark 	:= .F.
Local aVetor 	:= {}

Local _cBanco		:= ""
Local _cAgencia		:= ""
Local _cConta		:= ""
Local _cSubcta		:= ""
Local _Tipo			:= ""
Local _EmisIni		:= Ctod("  /  /  ")
Local _EmisFim		:= Ctod("  /  /  ")
Local _cTitulo		:= ""
Local cQuery 		:= ""  
Local _cDirPdf 		:= ''
Local _lGerouPdf 	:= .F. 
Local _lSche		:= .F.
Local nOpcao		:= 0

Private cPerg 		:= "BOLETO"  
Private cType 		:= "*.*"
Private oSayDir		:= Nil

ValidPerg()
If !Pergunte(cPerg, .T. )	  
	Return
EndIf

_cBanco			:= Mv_Par01
_cAgencia		:= Mv_Par02
_cConta			:= Mv_Par03
_cSubcta		:= Mv_Par04
_Tipo			:= Mv_Par05
_EmisIni		:= Mv_Par06
_EmisFim		:= Mv_Par07
_cTitulo		:= Mv_Par08

If Select("TMP") > 0
	TMP->(DbCloseArea())
EndIf

cQuery := " SELECT E1_PORTADO, E1_AGEDEP, E1_CONTA, E1_FILIAL, E1_PREFIXO, E1_NUM, E1_PARCELA, E1_CLIENTE, E1_LOJA, E1_NOMCLI, E1_EMISSAO, E1_VALOR, E1_VENCTO, E1_VENCREA, E1_TIPO, E1_PORTADO, E1_NUMBOR, E1_NUMBCO FROM "
cQuery += RetSqlName("SE1")
cQuery += " WHERE "
cQuery += "    D_E_L_E_T_ = '' AND "
cQuery += "    E1_FILIAL = '" + xFilial( "SE1" ) + "' "
//cQuery += " AND E1_PORTADO = '"+_cBanco+"' "
//cQuery += " AND E1_AGEDEP = '"+_cAgencia+"' "
//cQuery += " AND E1_CONTA = '"+_cConta+"' "

If Mv_Par05 == 1
	cQuery += " AND E1_SALDO <> 0 "
	cQuery += " AND E1_NUMBCO = '' "
	cQuery += " AND E1_TIPO IN ('NF','BOL','FT','DP','ND') "
	If !Empty(_cTitulo)
		cQuery += " AND E1_NUM = '" + _cTitulo + "' "
	Else
		cQuery += " AND E1_EMISSAO BETWEEN  '" + DtoS(_EmisIni) + "' AND '" + DtoS(_EmisFim) + "' "
	EndIf
ElseIf Mv_Par05 == 2
	cQuery += " AND E1_SALDO <> 0 "
	cQuery += " AND E1_NUMBCO <> '' "
	cQuery += " AND E1_TIPO IN ('NF','BOL','FT','DP','ND') "
	If !Empty(_cTitulo)
		cQuery += " AND E1_NUM = '" + _cTitulo + "' "
	Else
		cQuery += " AND E1_EMISSAO BETWEEN  '" + DtoS(_EmisIni) + "' AND '" + DtoS(_EmisFim) + "' "
	EndIf
EndIf

If Select("TMP") > 0
	TMP->(DbcloseArea())
EndIf
	    	
TCQuery cQuery NEW ALIAS "TMP"
/*
TcSetField("TMP","E1_EMISSAO","D")
TcSetField("TMP","E1_VENCTO" ,"D")
TcSetField("TMP","E1_VENCREA","D")
TcSetField("TMP","E1_VALOR"  ,"N",12,2)
*/

DbSelectArea("TMP")
DbGoTop()

While !TMP->(Eof())
	aAdd(aVetor, { lMark, TMP->E1_PREFIXO, TMP->E1_NUM, TMP->E1_PARCELA, TMP->E1_CLIENTE, TMP->E1_LOJA, TMP->E1_NOMCLI, Stod(TMP->E1_EMISSAO), AllTrim(Transform(TMP->E1_VALOR,"@E 999,999,999.99")), Stod(TMP->E1_VENCTO), Stod(TMP->E1_VENCREA), TMP->E1_TIPO, MV_PAR01, MV_PAR02, MV_PAR03, TMP->E1_NUMBOR, TMP->E1_NUMBCO, TMP->E1_FILIAL })
	TMP->(dbSkip())
Enddo

DbSelectArea("TMP")
DbCloseArea()

If Len(aVetor) == 0
	MsgAlert("Nใo foi Selecionado nenhum Titulo para Impressใo de Boleto",cTitulo)
	Return
EndIf


DEFINE MSDIALOG oDlg TITLE cTitulo FROM 0,0 To 511,1292 PIXEL
@010,010 LISTBOX oLbx VAR cVar FIELDS Header " ", "Prefixo", "Nฐ Titulo", "Parcela", "Cod. Cliente", "Loja", "Nome Cliente", "Data Emissใo", "Valor R$", "Vencimento", "Vencimento Real", "Tipo", "Portador", "Agencia", "Conta", "Bordero", "Nosso Nฐ Sistema",  "Filial" SIZE 630,200 Of oDlg PIXEL ON dblClick(aVetor[oLbx:nAt,1] := !aVetor[oLbx:nAt,1],oLbx:Refresh())
oLbx:SetArray(aVetor)
oLbx:bLine := {|| { Iif(aVetor[oLbx:nAt,1],oOk,oNo), aVetor[oLbx:nAt,2], aVetor[oLbx:nAt,3], aVetor[oLbx:nAt,4], aVetor[oLbx:nAt,5], aVetor[oLbx:nAt,6], aVetor[oLbx:nAt,7], aVetor[oLbx:nAt,8], aVetor[oLbx:nAt,9], aVetor[oLbx:nAt,10], aVetor[oLbx:nAt,11], aVetor[oLbx:nAt,12], aVetor[oLbx:nAt,13], aVetor[oLbx:nAt,14], aVetor[oLbx:nAt,15], aVetor[oLbx:nAt,16], aVetor[oLbx:nAt,17], aVetor[oLbx:nAt,18] }}

If oChk <> Nil
	@212,010 CHECKBOX oChk VAR lChk Prompt "Marca/Desmarca" Size 60,007 PIXEL Of oDlg On Click(Iif(lChk,Marca(lChk,aVetor),Marca(lChk,aVetor)))
EndIf

@212,010 CHECKBOX oChk VAR lChk Prompt "Marca/Desmarca" SIZE 60,007 PIXEL Of oDlg On Click(aEval(aVetor,{|x| x[1] := lChk}),oLbx:Refresh())
@233,068 Say oSayDir Prompt _cDirPdf Size 300, 08 Of oDlg Pixel 
@230,065 to 241,330 OF oDlg PIXEL
@230,010 BUTTON "Diretorio Gravacao"  SIZE 050, 011 Font oDlg:oFont ACTION ( _cDirPdf := cGetFile( cType, "Sele็ใo de Pasta principal dos fontes", 0, ,.T., GETF_RETDIRECTORY+GETF_LOCALFLOPPY+GETF_LOCALHARD+GETF_NETWORKDRIVE ), oSayDir:cCaption := _cDirPdf, oSayDir:Refresh(), SysRefresh() )  OF oDlg PIXEL


@230,380 BUTTON "Cancelar Boletos Total" SIZE 060, 011 Font oDlg:oFont ACTION {CanceTot(aVetor),oDlg:End()} OF oDlg PIXEL
@230,450 BUTTON "Consulta"  SIZE 050, 011 Font oDlg:oFont ACTION VisuSE1() OF oDlg PIXEL

@230,532 BUTTON "Confirmar" SIZE 050, 011 Font oDlg:oFont ACTION ( nOpcao := 1, oDlg:End() ) Of oDlg PIXEL
@230,588 BUTTON "Cancela"   SIZE 050, 011 Font oDlg:oFont ACTION oDlg:End() OF oDlg PIXEL

ACTIVATE MSDIALOG oDlg CENTER

If nOpcao == 1

	lProcessa := .F.
	For nx := 1 to Len( aVetor )
		If aVetor[ nx, 1 ]
			lProcessa := .T.
			exit	
		Endif
	Next

	If Empty(_cDirPdf)
		Alert( "O Diret๓rio de grava็ใo nใo foi informado. Os boletos nใo serใo gerados!" )
		lProcessa := .F.
   	Endif
	
	If lProcessa
		If _cBanco == "341"
			U_Process3(@aVetor,_cBanco,_cAgencia,_cConta,"R",1,_EmisIni,_EmisFim,SF2->F2_DOC,_lSche, _cDirPdf, @_lGerouPdf)
		ElseIf _cBanco == "001"
			U_Process4(@aVetor,_cBanco,_cAgencia,_cConta,"R",1,_EmisIni,_EmisFim,SF2->F2_DOC,_lSche, _cDirPdf, @_lGerouPdf)
		ElseIf _cBanco $ "237#707"
			U_Process5(@aVetor,_cBanco,_cAgencia,_cConta,"R",1,_EmisIni,_EmisFim,SF2->F2_DOC,_lSche, _cDirPdf, @_lGerouPdf)
		ElseIf _cBanco $ "033#637"
			U_Process6(@aVetor,_cBanco,_cAgencia,_cConta,"R",1,_EmisIni,_EmisFim,SF2->F2_DOC,_lSche, _cDirPdf, @_lGerouPdf)
		ElseIf _cBanco == "422"
			U_Process9(@aVetor,_cBanco,_cAgencia,_cConta,"R",1,_EmisIni,_EmisFim,SF2->F2_DOC,_lSche, _cDirPdf, @_lGerouPdf)
		ElseIf _cBanco == "246"
			U_Proces10(@aVetor,_cBanco,_cAgencia,_cConta,"R",1,_EmisIni,_EmisFim,SF2->F2_DOC,_lSche, _cDirPdf, @_lGerouPdf)
		ElseIf _cBanco $ "755"
			U_Process11(@aVetor,_cBanco,_cAgencia,_cConta,"R",1,_EmisIni,_EmisFim,SF2->F2_DOC,_lSche, _cDirPdf, @_lGerouPdf)
		EndIf     
	Endif	

Endif	
	
Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑบPrograma  ณ VisuSE1  บAutor  ณEduardo Augusto     บ Data ณ  22/10/2013 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Funcao para Chamada do mBrowse da Tela de Inlcusao do      บฑฑ
ฑฑบ          ณ Contas a Receber (Somente Consulta)             			  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ I2I Eventos							                      บฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/

Static Function VisuSE1()
Local cDelFunc 		:= ".T."
Local cString 		:= "SE1"

Private cCadastro 	:= "Tela do Contas a Receber"
Private aRotina 	:= { {"Pesquisar","AxPesqui",0,1}, {"Visualizar","AxVisual",0,2} }

DbSelectArea("SE1")
SE1->(dbSetOrder(1))
dbSelectArea(cString)

mBrowse(6,1,22,75,cString)

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑบPrograma  ณMarca     บAutor  ณEduardo Augusto     บ Data ณ  22/10/2013 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Funcao que Marca ou Desmarca todos os Objetos.             บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ I2I Eventos						                          บฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/

Static Function Marca(lMarca,aVetor)

Local i
For i := 1 To Len(aVetor)
	aVetor[i][1] := lMarca
Next
oLbx:Refresh()

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑบPrograma  ณCANCETOT  บAutor  ณEduardo Augusto     บ Data ณ  22/10/2013 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Funcao para Limpar os campos da Tabela SE1 quando o Boleto บฑฑ
ฑฑบ		     ณ sofrer cancelamento total das informa็๕es...				  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Mirai							                          บฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/

Static Function CanceTot(aVetor)

Local j
For j := 1 To Len(aVetor)
	If aVetor [j][1] == .T.
		DbSelectArea("SE1")
		DbSetOrder(1)
		If DbSeek(xFilial("SE1") + aVetor[j][2] + aVetor[j][3] + aVetor[j][4] + aVetor[j][12])
			RecLock("SE1",.F.)
			SE1->E1_NUMBCO	:= ""
			SE1->E1_NUMBCO	:= ""
			SE1->E1_CODBAR	:= ""
			SE1->E1_CODDIG	:= ""
			//SE1->E1_PORTADO	:= ""
			//SE1->E1_AGEDEP	:= ""
			//SE1->E1_CONTA	:= ""
			MsUnLock()
		EndIf
	EndIf
Next
MsgInfo("Cancelamento de Boleto Total Finalizado com Sucesso")

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑบPrograma  ณMarca     บAutor  ณEduardo Augusto     บ Data ณ  22/10/2013 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Funcao que Perguntas do SX1.					              บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ I2I Eventos						                          บฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/

Static Function ValidPerg()

Local i
Local j

_sAlias := Alias()

DbSelectArea("SX1")
DbSetOrder(1)

cPerg := PADR(cPerg,10)
aRegs :={}

// Grupo/Ordem/Pergunta/Variavel/Tipo/Tamanho/Decimal/Presel/GSC/Valid/Var01/Def01/Cnt01/Var02/Def02/Cnt02/Var03/Def03/Cnt03/Var04/Def04/Cnt04/Var05/Def05/Cnt05
aAdd(aRegs,{cPerg,"01","Banco              :","","","mv_ch1","C",03,0,0,"G","","Mv_Par01",""    ,"","",""      ,"","","","","","","","","","",""})
aAdd(aRegs,{cPerg,"02","Agencia            :","","","mv_ch2","C",05,0,0,"G","","Mv_Par02",""    ,"","",""      ,"","","","","","","","","","",""})
aAdd(aRegs,{cPerg,"03","Conta              :","","","mv_ch3","C",10,0,0,"G","","Mv_Par03",""    ,"","",""      ,"","","","","","","","","","",""})
aAdd(aRegs,{cPerg,"04","SubCta             :","","","mv_ch4","C",03,0,0,"G","U_VALSUBCT()","Mv_Par04",""    ,"","",""      ,"","","","","","","","","","",""})
aAdd(aRegs,{cPerg,"05","Tipo de Impressao  :","","","mv_ch5","N",01,0,0,"C","","Mv_Par05","1ฐ Via","1ฐ Via","1ฐ Via","","","2ฐ Via","2ฐ Via","2ฐ Via","","","","","","","","","","","","","","","","","","","","",""})
aAdd(aRegs,{cPerg,"06","Emissao de         :","","","mv_ch6","D",08,0,0,"G","","Mv_Par06",""    ,"","",""      ,"","","","","","","","","","",""})
aAdd(aRegs,{cPerg,"07","Emissao ate        :","","","mv_ch7","D",08,0,0,"G","","Mv_Par07",""    ,"","",""      ,"","","","","","","","","","",""})
aAdd(aRegs,{cPerg,"08","Nฐ do Titulo       :","","","mv_ch8","C",09,0,0,"G","","Mv_Par08",""    ,"","",""      ,"","","","","","","","","","",""})

For i:=1 to Len(aRegs)
	If ! DBSeek(cPerg+aRegs[i,2])
		RecLock("SX1",.T.)
		For j:=1 to Len(aRegs[i])
			FieldPut(j,aRegs[i,j])
		Next
		MsUnlock()
	EndIf
Next
DbSkip()
DbSelectArea(_sAlias)

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑบPrograma  ณVALSUBCT   บAutor  ณMicrosiga          บ Data ณ  28/08/2015 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Programa de validador da Subconta.						  บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Plastit                                                    บฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/

User Function VALSUBCT()

Local lRet := .T.
DbSelectArea("SEE")
DbSetOrder(1)
lRet := dbSeek(xFilial("SEE") + Mv_Par01 + Mv_Par02 + Mv_Par03 + Mv_Par04 )
If !lRet
	MsgAlert("Subconta nใo relacionada com o Banco informado no Parโmetro, favor informar a Subconta correta!!!")
	lRet := .F.
EndIf

Return lRet
