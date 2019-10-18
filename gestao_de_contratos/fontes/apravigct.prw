#include 'protheus.ch'
#include 'parmtype.ch'
#include 'topconn.ch'

user function APRAVIGCT()
	//Envio de vencimento de contrato.
	local lxEnvmail    := .f.
	local _cRemet	   := ""
	Local _cAssunto := "Aviso de Vencimento de Contrato - April Brasil"                                    
	Local _cRemet := "protheus@aprilbrasil.com.br"

	//Query para Verificar os produtos com Bloqueio ( enviar todo dia 00:00.)
	_cQuery := " SELECT CN9_DONO FROM "+RetSQLName("CN9")+" "
	_cQuery += " WHERE D_E_L_E_T_<>'*' "
	_cQuery += " GROUP BY CN9_DONO "

	If Select("TRB1") <> 0
		dbSelectArea("TRB1")
		dbCloseArea()
	EndIf

	TCQuery _cQuery New Alias "TRB1"

	While TRB1->(!Eof())

		_cQuery := " SELECT A2_NOME,CN9_NUMERO,CN9_DTFIM,CN9_VLINI ,"
		_cQuery += " DATEDIFF(day,         GETDATE(),CN9_DTFIM) AS DATA"
		_cQuery += " FROM "+RetSQLName("CNC")+" CNC"
		_cQuery += " INNER JOIN "+RetSQLName("CN9")+" CN9 ON CNC.CNC_FILIAL = CN9.CN9_FILIAL AND CNC.CNC_NUMERO=CN9.CN9_NUMERO" 
		_cQuery += " AND CNC.CNC_REVISA = CN9.CN9_REVISA"
		_cQuery += " INNER JOIN "+RetSQLName("SA2")+" SA2 ON  SA2.A2_COD = CNC.CNC_CODIGO AND SA2.A2_LOJA = CNC.CNC_LOJA"
		_cQuery += " WHERE CN9_DONO = '"+TRB1->CN9_DONO+"' AND CN9.D_E_L_E_T_='' AND CNC.D_E_L_E_T_='' AND SA2.D_E_L_E_T_='' "

		If Select("TRB") <> 0
			dbSelectArea("TRB")	
			dbCloseArea()
		EndIf

		TCQuery _cQuery New Alias "TRB"

		_cHTML := "<!-- saved from url=(0022)http://internet.e-mail -->"
		_cHTML += "<!DOCTYPE html PUBLIC '-//W3C//DTD XHTML 1.0 Transitional//EN' 'http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd'>"
		_cHTML += "<html xmlns='http://www.w3.org/1999/xhtml'>"
		_cHTML += "<head>"
		_cHTML += "<meta http-equiv='Content-Type' content='text/html; charset=iso-8859-1' />"
		_cHTML += "<title>Aviso de Contratos para vencer</title>"
		_cHTML += "<style type='text/css'>"
		_cHTML += "<!--"
		_cHTML += ".style13 {"
		_cHTML += "	font-size: 24px;"
		_cHTML += "	font-weight: bold;"
		_cHTML += "	color: #FFFFFF;"
		_cHTML += "}"
		_cHTML += ".style14 {color: #FFFFFF}"
		_cHTML += ".style7 {font-family: Tahoma; font-size: 10px; color: #000000; font-weight: bold; }"
		_cHTML += "table.bordasimples {border-collapse: collapse;}"
		_cHTML += "table.bordasimples tr td {border:1px solid #000000;}"
		_cHTML += ".style16 {font-family: Tahoma; font-size: 18px; color: #000000; font-weight: bold; }"
		_cHTML += ".style17 {font-size: 18px; color: #000000; font-family: Tahoma;}"
		_cHTML += "-->"
		_cHTML += "</style>"
		_cHTML += "</head>"
		_cHTML += "<body>"
		_cHTML += "<table width='1128' height='158' align='center' class='bordasimples'>"
		_cHTML += " <tr>"
		_cHTML += "   <td width='187' bgcolor='#555555'><img src='https://aprilbrasil.com.br/seguroviagem/img/logo_april_brasil.png' width='179' height='74' /></td>"
		_cHTML += "   <td height='90' colspan='4' bgcolor='#555555'><div align='center' class='style13'>Aviso de vencimento de contrato  - April Turismo </div></td>"
		_cHTML += " </tr>"
		_cHTML += " <tr>"
		_cHTML += "    <td width='187' height='23' bgcolor='#808080'><div align='center' class='style14'><strong>Data de aviso </strong></div></td>"
		_cHTML += "   <td width='307' height='23' bgcolor='#808080'><div align='center' class='style14'><strong>Fornecedor</strong></div></td>"
		_cHTML += "   <td width='169' height='23'  bgcolor='#808080'><div align='center' class='style14'><strong>Vencimento  do contrato</strong> </div></td>"
		_cHTML += "   <td width='295' height='23'  bgcolor='#808080'><div align='center' class='style14'><strong>Tipo de Contrato </strong></div></td>"
		_cHTML += "   <td width='146' bgcolor='#808080'><div align='center' class='style14'><strong>Valor do Contrato </strong></div></td>"
		_cHTML += " </tr>"

		While TRB->(!Eof())
			_cHTML += "<tr>"
			_cHTML += " <td height='23'><div align='center'><span class='style7'>"+Date()+"</span></div></td>"
			_cHTML += "<td height='23'><div align='center'><span class='style7'>"+TRB->A2_NOME+" </span></div></td>"
			_cHTML += "<td height='23'><div align='center'><span class='style7'>"+StoD(TRB->CN9_DTFIM)+"</span></div></td>"
			_cHTML += "<td height='23'><div align='center'><span class='style7'>CONSULTORIA DE INFORM&Aacute;TICA</span></div></td>"
			_cHTML += "<td height='23'><div align='center'><span class='style7'>R$ 10000,000</span></div></td>"
			_cHTML += " </tr>"
			TRB->(DbSkip())
		End
		_cHTML += "</table>	"
		_cHTML += "</body>"
		_cHTML += "</html>"
		
		// _cDest :=  ""
		// _cCC:= ""
		//Alltrim(UsrRetMail(TRB1->CN9_DONO)
		lxEnvmail := U_EnvMail(_cRemet, "thiagomt.rocco@gmail.com", "", _cAssunto, _cHTML, .T.)
		TRB1->(DbSkip())
	End
return