#include 'protheus.ch'
#include 'parmtype.ch'

user function FA080TIT()
Local lRetorno:= .T.

	dbSelectArea("SZ1")
	SZ1->(DbSetOrder(1))

	

	If SZ1->(DbSeek(xFilial("SZ1")+PADR((SE2->E2_NUM),15)+SE2->E2_PARCELA))
		RecLock("SZ1",.F.)
		SZ1->Z1_VLRBX 	:= SE2->E2_VALLIQ
		SZ1->Z1_DTBX	:= SE2->E2_BAIXA
		SZ1->Z1_USRBX	:= Alltrim(UsrRetName(__CUSERID)) //nÃO Existia na base teste
		SZ1->Z1_SLDTIT	:= SE2->E2_SALDO
		SZ1->Z1_DTCANC	:= CTOD("  /  /  ")
		SZ1->Z1_HRCANC	:= ''
		SZ1->Z1_USERC	:= ''
		SZ1->Z1_STATT	:= ''
		SZ1->Z1_CANC	:= ''
		SZ1->(MsUnlock())
	Endif

return(lRetorno)