#INCLUDE "rwmake.ch"
#INCLUDE "tbiconn.ch"
/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � CFATI002 � Autor � Mauricio Exclusiv  � Data �  27/04/12   ���
�������������������������������������������������������������������������͹��
���Descricao � Rotina para importacao de Clientes com origem no sistema   ���
���          � de BSCS da Ericsson-Tab Z01 para SA1                       ���
�������������������������������������������������������������������������͹��
���Uso       � Porto Seguro Telecomunicacoes                              ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

User Function StartEml(cProcesso,cHorario,_cDest,_cCC,_cAssunto)
local _cHTML       := ""
local lxEnvmail    := .f.
local _cRemet	   := ""
                                    �
_cRemet := "protheus@aprilbrasil.com.br"


//StartEml(cProcesso,cHorario,_cRemet,_cDest,_cCC,_cAssunto)

	_cHTML := " <html><head><title>"+cProcesso+"</title><meta http-equiv='Content-Type' content='text/html; charset=iso-8859-1'>"
	_cHTML += " </head><body>"                                                                                                    
	_cHTML += " <table width='95%' border='2' cellspacing='2' cellpadding='2' >"
	_cHTML += "   <tr> "
	_cHTML += "     <td colspan='10'> <div align='center'><font color='#000099' size='3' face='Georgia, Times New Roman, Times, serif'>"
	_cHTML += "         "+ cProcesso + "  " +cHorario +"</font></div></td>"
 	_cHTML += "   </tr>"
	_cHTML += " </table>"
	_cHTML += " </tr>"
	_cHTML += "    </body></html>"
	lxEnvmail := U_EnvMail(_cRemet, Alltrim(_cDest), _cCC, _cAssunto, _cHTML,.F.)

//RpcClearEnv()
Return nil
