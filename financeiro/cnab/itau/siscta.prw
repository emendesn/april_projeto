#Include "Protheus.ch"

// Programa para pegar o numero da conta sem o digito para o Sispag
User Function SisCta(cCta)

	//cConta := Trim(cConta)
	Local cConta := StrZero(Val(cCta),TAMSX3("A2_NUMCON")[1])



Return cConta

// Programa para pegar o numero do convenio para o Sispag
User Function SISCV(cCta)

	Local cConven := POSICIONE('SEE',1,xFilial('SEE')+cCta+'001',"EE_CODEMP")
	cConven := PADR(ALLTRIM(cConven), 20," ")

return cConven

User Function CTACRED()
	Local cCred :=""

	If SUBSTR(Alltrim(SF1->F1_NOMEFOR),1,5) == 'APRIL' .OR. SUBSTR(Alltrim(SF1->F1_NOMEFOR),1,5) == 'CORIS'
		If SA2->A2_TIPO <>'X'
			cCred:='2110030003'
		Else
			cCred:='2110030004'
		EndIf
	Else
		If SA2->A2_TIPO <>'X'
			cCred:='2110020003'
		Else
			cCred:='2110020004'
		EndIf

	EndIf
Return cCred

User Function CTADEB()
	Local cCred :=""

	If SUBSTR(Alltrim(SF1->F1_NOMEFOR),1,5) == 'APRIL' .OR. SUBSTR(Alltrim(SF1->F1_NOMEFOR),1,5) == 'CORIS'
		cCred:='1810010001'
	Else
		cCred := '1810010002'
	EndIf
Return cCred

User Function ValorMed()

	nValor :=0
	If !Empty(Alltrim(SF1->F1_NOMEFOR))
		nValor := SD1->(D1_TOTAL-D1_VALDESC+D1_ICMSRET+D1_VALFRE+D1_DESPESA+SD1->D1_VALCMAJ +SD1->D1_VALPMAJ )                                                                                                                                                                  
	EndIf
Return nValor

//////REINVOICE//////
User Function CTACREDR()
	Local cCred :=""

	If SUBSTR(Alltrim(SF1->F1_NOMEFOR),1,5) == 'APRIL' .OR. SUBSTR(Alltrim(SF1->F1_NOMEFOR),1,5) == 'CORIS'
		cCred:='1810010001'
	Else
		cCred:='1810010002'
	EndIf

Return cCred

User Function CTADEBR()
	Local cCred :=""

	If SUBSTR(Alltrim(SF1->F1_NOMEFOR),1,5) == 'APRIL' .OR. SUBSTR(Alltrim(SF1->F1_NOMEFOR),1,5) == 'CORIS'
		cCred:='1120030001'
	Else
		If SA1->A1_TIPO <>'X'
			cCred:='1130020002'
		Else
			cCred:='1130020003'
		EndIf
	EndIf
Return cCred

	