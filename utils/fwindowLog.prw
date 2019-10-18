#include 'protheus.ch'
#include 'parmtype.ch'

/*----------------------------------------------*/
/*/{Protheus.doc} FWindowLog
Tela de log de processos

@author LOTVS Intelligence
@since 	12/11/2013
@version P11
@obs    Importa XML
/*/
//-------------------------------------------------------------------
User Function FWindowLog(oObjMain,cTexto,cHoraIni,cArqLog,cDirLog)
Local cAux      := ""
Local cFile     := ""
Local cFileLog  := ""
Local cMask     := "Arquivos Texto" + "(*.TXT)|*.txt|"
Local oDig		:= Nil
Local oFont     := Nil
Local oMemo     := Nil

DbSelectArea("SM0")

cAux += Replicate( "-", 128 ) 	+ CRLF
cAux += CRLF
cAux += " Dados Ambiente" + CRLF
cAux += " --------------------"  + CRLF
cAux += " Empresa / Filial...: " + cEmpAnt + "/" + cFilAnt  + CRLF
cAux += " Nome Empresa.......: " + Capital( AllTrim( GetAdvFVal( "SM0", "M0_NOMECOM", cEmpAnt + cFilAnt, 1, "" ) ) ) + CRLF
cAux += " Nome Filial........: " + Capital( AllTrim( GetAdvFVal( "SM0", "M0_FILIAL" , cEmpAnt + cFilAnt, 1, "" ) ) ) + CRLF
cAux += " DataBase...........: " + DtoC( dDataBase )  + CRLF
cAux += cHoraIni
cAux += " Environment........: " + GetEnvServer()  + CRLF
cAux += " Versao.............: " + GetVersao(.T.)  + CRLF
cAux += " Usuario TOTVS .....: " + __cUserId + " " +  cUserName + CRLF
cAux += " Computer Name......: " + GetComputerName() + CRLF
cAux += " Executado via Job..: " + IiF(IsBlind(),"Sim","Nao") + CRLF
cAux += Replicate( "-", 128 ) + CRLF
cAux += CRLF

cTexto := cAux + cTexto + CRLF

cTexto += Replicate( "-", 128 ) + CRLF
cTexto += " Data / Hora Final.: " + DtoC( Date() ) + " / " + Time()  + CRLF
cTexto += Replicate( "-", 128 ) + CRLF

//If !IsBlind()
cFileLog := MemoWrite( CriaTrab( , .F. ) + ".log", cTexto )

If oObjMain == Nil
	
	oDig 	:= MSDialog():New(3,0,510,617,OEMTOANSI("Log de Erros "),,,,,,,,oMainWnd,.T.)  // Tela aumentada
Else
	oDig	:= oObjMain
EndIf

//Define Font oFont Name "Mono AS" Size 5, 12
Define Font oFont Name "Mono AS" Size 7, 15  // Aumentei a fonte para melhorar a experiencia do usuario
//@ 5,5 Get oMemo Var cTexto Memo Size 200, 145 Of oDig Pixel
@ 5,5 Get oMemo Var cTexto Memo Size 300, 220 Of oDig Pixel
oMemo:bRClicked := { || AllwaysTrue() }
oMemo:oFont     := oFont

If oObjMain == Nil
	//Define SButton From 153, 175 Type  1 Action oDig:End() Enable Of oDig Pixel
	//Define SButton From 153, 145 Type 13 Action (cFile := cGetFile(cMask,""),If(cFile == "",.T.,MemoWrite(cFile,cTexto)))Enable Of oDig Pixel
	Define SButton From 235, 175 Type  1 Action oDig:End() Enable Of oDig Pixel
	Define SButton From 235, 145 Type 13 Action (cFile := cGetFile(cMask,""),If(cFile == "",.T.,MemoWrite(cFile,cTexto)))Enable Of oDig Pixel
	oDig:Activate(,,,.T.,,,)
EndIf
//EndIf
//FSaveLog(cArqLog,cDirLog,cTexto,)

Return( .T. )

