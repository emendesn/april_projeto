#include 'protheus.ch'
#include 'parmtype.ch'
#INCLUDE "rwmake.ch"
#INCLUDE "topConn.ch"

User Function AprEnvP2()

	local lxEnvmail    := .f.
	local _cRemet	   := ""
	Local _cAssunto := "Novos Produtos Cadastrados"                                    
	Local _cRemet := "thiagomt.rocco@gmail.com"
	Local nX     := 0
	_cDest :=  "thiagomt.rocco@gmail.com,danielle.santana@aprilbrasil.com.br,celia.moraes@aprilbrasil.com.br"
	_cCC:= ""

	//Query para Verificar os produtos com Bloqueio ( enviar todo dia 00:00.)
	_cQuery := " SELECT B1_COD,X5_DESCRI,B1_DESC FROM "+RetSQLName("SB1")+" B1 "
	_cQuery += " INNER JOIN "+RetSQLName("SX5")+" X5 ON B1_TIPO = X5_CHAVE "
	_cQuery += " WHERE X5.D_E_L_E_T_<>'*' AND B1_MSBLQL ='1' AND B1.D_E_L_E_T_<>'*' AND X5_TABELA='02' ""

	If Select("TRB") <> 0
		dbSelectArea("TRB")
		dbCloseArea()
	EndIf

	TCQuery _cQuery New Alias "TRB"

	_cHTML := "<!-- saved from url=(0022)http://internet.e-mail -->"
	_cHTML += "<html xmlns='http://www.w3.org/1999/xhtml'>"
	_cHTML += "<head>"
	_cHTML += "<meta http-equiv='Content-Type' content='text/html; charset=iso-8859-1' />"
	_cHTML += "<title>Cadastro de Produto</title>"
	_cHTML += "<style type='text/css'>"
	_cHTML += "<!--"
	_cHTML += ".style13 {"
	_cHTML += "	font-size: 24px;"
	_cHTML += "	font-weight: bold;"
	_cHTML += "	color: #FFFFFF;"
	_cHTML += "}"
	_cHTML += ".style14 {color: #FFFFFF}"
	_cHTML += "table.bordasimples {border-collapse: collapse;}"
	_cHTML += "table.bordasimples tr td {border:1px solid #000000;}"
	_cHTML += "-->"
	_cHTML += "</style>"
	_cHTML += "</head>"
	_cHTML += "<body>"
	_cHTML += " <table width='1133' height='228' align='center' class='bordasimples'>"
	_cHTML += "  <tr>"
	_cHTML += "   <td bgcolor='#555555'><div align='center'><img src='https://aprilbrasil.com.br/seguroviagem/img/logo_april_brasil.png' width='111' height='53' /></div></td>"
	_cHTML += "   <td height='97' colspan='3' bgcolor='#555555'><div align='center' class='style13'>Solicita&ccedil;&atilde;o de desbloqueio de produtos  - April Turismos </div>"
	_cHTML += "   <div align='center'></div></td>"
	_cHTML += "  </tr>"
	_cHTML += " <tr>"
	_cHTML += "   <td width='160' height='23' bgcolor='#808080' class='style14'><p align='center'><strong>C&Oacute;DIGO PRODUTO </strong></p>    </td>"
	_cHTML += "  <td width='185' bgcolor='#808080' class='style14'><div align='center'><strong>TIPO</strong></div></td>"
	_cHTML += "  <td width='607' height='23' bgcolor='#808080' class='style14'><div align='center'><strong>DESCRI&Ccedil;&Atilde;O</strong></div></td>"
	_cHTML += "   <td width='161' height='23' bgcolor='#808080' class='style14'><div align='center'><strong>USU&Aacute;RIO</strong></div></td>"
	_cHTML += "</tr>"

	While TRB->(!Eof())
		nX++
		_cHTML += "<tr>"
		_cHTML += "  <td height='45'>"+Alltrim(TRB->B1_COD)+"</td>"
		_cHTML += "  <td height='45'>"+Alltrim(TRB->X5_DESCRI)+"</td>"
		_cHTML += "  <td height='45'>"+Alltrim(TRB->B1_DESC)+"</td>"
		_cHTML += " <td height='45'>"+Alltrim(Upper(UsrFullName(RetCodUsr())))+"</td>"
		_cHTML += " </tr>"

		TRB->(DbSkip())
	End
	_cHTML += " <tr>"
	_cHTML += "   <td height='23' colspan='4'><div align='center'></div></td>"
	_cHTML += "  </tr>"
	_cHTML += "</table>	"
	_cHTML += "</body>"
	_cHTML += "</html>"

	If nX > 0
		lxEnvmail := U_EnvMail(_cRemet, Alltrim(_cDest), _cCC, _cAssunto, _cHTML, .T.)
		//RpcClearEnv()
	EndIf
Return nil
