#include "protheus.ch"

/*
Cadastro de Suppliers Cosmos
Elias - 07/08/18
*/

User Function AprilSup()
 
Local cFiltro   := ""
Local aCores  := {{ 'Empty(SZ9->Z9_CODFOR)' , 'ENABLE'  },;    				// Ativo
                 { 	'!Empty(SZ9->Z9_CODFOR)' , 'DISABLE' }}    				// Inativo
 
Private cAlias   	:= 'SZ9'
Private _aCpos		:= {"Z9_SUPID","Z9_SUPNAME","Z9_CODFOR","Z9_LOJA","Z9_NOMFOR"}
Private cCadastro 	:= "Suppliers Cosmos"
Private aRotina		:= {}

AADD(aRotina, { "Pesquisar"		, "AxPesqui"	, 0, 1 })
AADD(aRotina, { "Visualizar"	, "AxVisual"  	, 0, 2 })
//AADD(aRotina, { "Incluir"      	, "AxInclui"   	, 0, 3 })
AADD(aRotina, { "Alterar"     	, "AxAltera('SZ9',SZ9->(Recno()),3,,_aCpos,,,'u_SupLog(4)')"  	, 0, 4 })

AADD(aRotina, { "Excluir"     	, "AxDeleta('SZ9',SZ9->(Recno()),4,'u_SupLog(5)')" 	, 0, 5 }) 
AADD(aRotina, {"Legenda"   		, "U_LegSup"	, 0, 7, 0, .F. })

dbSelectArea("SZ9")
dbSetOrder(1)
 
mBrowse( ,,,,"SZ9",,,,,,aCores,,,,,,,,cFiltro)
 
Return


User Function LegSup()
   
   aLegenda := { { "ENABLE",     "Não Integrado" },;
                 { "DISABLE",    "Integrado"   } }
   BrwLegenda( cCadastro, "Legenda", aLegenda )
   
Return .t.


User Function SupLog(nOpc)
Local cMsg := ""

If nOpc == 4
	cMsg := DTOC(dDataBase) + " - " + Substr(Time(),1,5) + ": Alterado por " + cUserName
	M->Z9_LOG += chr(13) + chr(10) + cMsg
Else
	cMsg := DTOC(dDataBase) + " - " + Substr(Time(),1,5) + ": Excluido por " + cUserName
	Reclock("SZ9",.F.)
	SZ9->Z9_LOG += chr(13) + chr(10) + cMsg
	SZ9->(MsUnlock())
Endif


Return .T.