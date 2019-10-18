#include 'protheus.ch'
#include 'parmtype.ch'

User function CTBDEB()

	Local aArea := GetArea()
	Local cConta := ""

	If SRA->RA_XTIPO == '2' // Comercial

		If SRZ->RZ_VAL > 0 
			cConta := POSICIONE("SRV",1,xFilial("SRV")+SRZ->RZ_PD,ALLTRIM("RV_DEBITO"))
		Else
			cConta := POSICIONE("SRV",1,xFilial("SRV")+SRZ->RZ_PD,ALLTRIM("RV_CREDITO")) 
		EndIf    

	ElseIf SRA->RA_XTIPO == '3' // Diversos
		If SRZ->RZ_VAL > 0 
			cConta := POSICIONE("SRV",1,xFilial("SRV")+SRZ->RZ_PD,ALLTRIM("RV_XCTB3"))
		Else
			cConta := POSICIONE("SRV",1,xFilial("SRV")+SRZ->RZ_PD,ALLTRIM("RV_XCTB4")) 
		EndIf    

	ElseIf SRA->RA_XTIPO == '1' // Assistência
		If SRZ->RZ_VAL > 0 
			cConta := POSICIONE("SRV",1,xFilial("SRV")+SRZ->RZ_PD,ALLTRIM("RV_XCTB1"))
		Else
			cConta := POSICIONE("SRV",1,xFilial("SRV")+SRZ->RZ_PD,ALLTRIM("RV_XCTB2")) 
		EndIf 

	ElseIf SRA->RA_XTIPO == '4' // Autonomo.
		If SRZ->RZ_VAL > 0 
			cConta := POSICIONE("SRV",1,xFilial("SRV")+SRZ->RZ_PD,ALLTRIM("RV_XCTB5"))
		Else
			cConta := POSICIONE("SRV",1,xFilial("SRV")+SRZ->RZ_PD,ALLTRIM("RV_XCTB6")) 
		EndIf 

	Else
		cConta := "FALTA CTA"
	Endif
	If Empty(Alltrim(cConta))
		cConta := "FALTA CTA"
	EndIf

	RestArea(aArea)
return Alltrim(cConta)

//If(SRZ->RZ_VAL < 0, POSICIONE("SRV",1,xFilial("SRV")+SRZ->RZ_PD,ALLTRIM("RV_DEBITO")), POSICIONE("SRV",1,xFilial("SRV")+SRZ->RZ_PD,ALLTRIM("RV_CREDITO"))  )

User function CTBCRED()

	Local aArea := GetArea()
	Local cConta := ""

	If SRA->RA_XTIPO == '2' // Comercial

		If SRZ->RZ_VAL < 0 
			cConta := POSICIONE("SRV",1,xFilial("SRV")+SRZ->RZ_PD,ALLTRIM("RV_DEBITO"))
		Else
			cConta := POSICIONE("SRV",1,xFilial("SRV")+SRZ->RZ_PD,ALLTRIM("RV_CREDITO")) 
		EndIf    

	ElseIf SRA->RA_XTIPO == '3' // Diversos
		If SRZ->RZ_VAL < 0 
			cConta := POSICIONE("SRV",1,xFilial("SRV")+SRZ->RZ_PD,ALLTRIM("RV_XCTB3"))
		Else
			cConta := POSICIONE("SRV",1,xFilial("SRV")+SRZ->RZ_PD,ALLTRIM("RV_XCTB4")) 
		EndIf    

	ElseIf SRA->RA_XTIPO == '1' // Assistência
		If SRZ->RZ_VAL < 0 
			cConta := POSICIONE("SRV",1,xFilial("SRV")+SRZ->RZ_PD,ALLTRIM("RV_XCTB1"))
		Else
			cConta := POSICIONE("SRV",1,xFilial("SRV")+SRZ->RZ_PD,ALLTRIM("RV_XCTB2")) 
		EndIf 

	ElseIf SRA->RA_XTIPO == '4' // Autonomo
		If SRZ->RZ_VAL < 0 
			cConta := POSICIONE("SRV",1,xFilial("SRV")+SRZ->RZ_PD,ALLTRIM("RV_XCTB5"))
		Else
			cConta := POSICIONE("SRV",1,xFilial("SRV")+SRZ->RZ_PD,ALLTRIM("RV_XCTB6")) 
		EndIf 

	Else
		cConta := "FALTA CTA"
	Endif
	If Empty(Alltrim(cConta))
		cConta := "FALTA CTA"
	EndIf

	RestArea(aArea)
return Alltrim(cConta)                                           