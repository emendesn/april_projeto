#INCLUDE "Protheus.ch"
#INCLUDE "rwmake.ch"
#INCLUDE "ap5mail.ch"
#include "topconn.ch"  


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ ENVMAIL  บ Autor ณ Mauricio Exclusiv  บ Data ณ  31/09/12   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Rotina para envio de email                                 บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Porto Seguro Telecomunicacoes                              บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/

User Function EnvMail(_cRemet, _cDest, _cCC, _cAssunto, _cBody, lInterface, cAnexo)

Local _cSerMail		:= "smtp.office365.com:587" 	// 
Local _cDe     		:= "protheus@aprilbrasil.com.br" 	//
Local _cSenha		:= "uwew@007"    	// senha
Local lSmtpAuth  	:= GetMv("MV_RELAUTH",,.F.)
Local _lEnviado		:= .F.
Local _lConectou	:= .F.
Local _cMailError	:= ""
Local lInterfac		:= .T.

DEFAULT cAnexo 		:= ""

// Conecta ao servidor de email
//CONNECT SMTP SERVER _cSerMail ACCOUNT _cDe PASSWORD _cSenha Result _lConectou      // 
CONNECT SMTP SERVER _cSerMail ACCOUNT _cDe PASSWORD _cSenha Result _lConectou 
	Conout("Iniciando Email  ")
	Conout("=======================================================") 
	Conout("Parametros " + _cSerMail +" " + _cDe + _cSenha)


if !(_lConectou)
	// Se nao conectou ao servidor de email, avisa ao usuario
	GET MAIL ERROR _cMailError
	IF lInterface 
		MsgBox("Nao foi possivel conectar ao Servidor de email."+chr(13)+chr(10)+;
		"Procure o Administrador da rede."+chr(13)+chr(10)+;
		"Erro retornado: "+_cMailError)
	Else
		Conout("Nao foi possivel conectar ao Servidor de email."+chr(13)+chr(10)+;
		"Procure o Administrador da rede."+chr(13)+chr(10)+;
		"Erro retornado: "+_cMailError)
	ENDIF	
else   

	IF lSmtpAuth
        
		lAutOk := MailAuth("protheus@aprilbrasil.com.br","uwew@007")//lAutOk := MailAuth(_cDe,_cSenha)
    ELSE
        lAutOK := .t.
    ENDIF

    IF !lAutOk 
    	IF lInterface
          // msgstop("Nao foi possivel autenticar no servidor .")
          MsgBox("Nao foi possivel autenticar no servidor .")
        ENDIF
    else
	
	   //	SEND MAIL FROM _cRemet ;
			SEND MAIL FROM _cDe ;
		To _cDest ;
		Cc _cCc ;
		SUBJECT	_cAssunto ;
		Body _cBody ;
		ATTACHMENT  cAnexo ;
		RESULT _lEnviado
		
		if !(_lEnviado)
			GET MAIL ERROR _cMailError
			IF lInterface 
				MsgBox("Nao foi possivel enviar o email."+chr(13)+chr(10)+;
				"Procure o Administrador da rede."+chr(13)+chr(10)+;
				"Erro retornado: "+_cMailError)
			Else
			    Conout("Nao foi possivel enviar o email."+chr(13)+chr(10)+;
				"Procure o Administrador da rede."+chr(13)+chr(10)+;
				"Erro retornado: "+_cMailError )
			Endif
		else
		    IF lInterface
	    	    MSGBOX("E-Mail enviado com sucesso!")
	    	Else
	    	    Conout("E-mail enviado com sucesso.")
	    	Endif
		Endif
    ENDIF		
	DISCONNECT SMTP SERVER
	
endif

return _lEnviado          