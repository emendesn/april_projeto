#include 'protheus.ch'
#include 'parmtype.ch'

//-------------------------------------------------------------------
/*/{Protheus.doc} FVldcTexto
Verifica tamanho de variavel caracter

@author LOTVS Intelligence
@since 	12/11/2013
@version P11
@obs    Importa XML
/*/
//-------------------------------------------------------------------
User Function FVldcTexto(cTexto,cConteudo)
Local cRetorno	:= ""

If ((Len(cTexto)+Len(cConteudo)) <  1005000)
	cRetorno := cConteudo
EndIf

Return( cRetorno )
//---------------------