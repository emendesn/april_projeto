#INCLUDE "PROTDEF.CH"
#INCLUDE "RWMAKE.CH" 

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ITAUTRIB  ºAutor  ³Eduardo Augusto     º Data ³  02/26/13   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³  CNAB SISPAG - Banco Itau	                              º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ A5 Solutions							                      º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

User Function ItauTrib()                      

Local _cRet		:=""
If SEA->EA_MODELO$"17" //Pagamento GPS
	_cRet:="01"																//Codigo do tributo / pos. 018-019
	_cRet+=Substr(SE2->E2_ESCRT  ,1,4)										//Codigo do pagamento / pos. 020-023	
	_cRet+=STRZERO(VAL(SE2->E2_XCOMPET),6)									//Competencia / pos. 024-029
	_cRet+=PADL(ALLTRIM(SM0->M0_CGC),14,"0")								//Identificação do Contribuinte - CNPJ/CGC/CPF / 030-043
	_cRet+=STRZERO(SE2->E2_SALDO*100,14)									//Valor de pagamento do INSS / 044-057
	_cRet+=STRZERO(SE2->E2_OUTENT*100,14)									//Valor somado ao valor do documento / 058-071
	_cRet+=REPL("0",14)														//Atualização monetaria /	072-085
	_cRet+=STRZERO((SE2->E2_SALDO + SE2->E2_ACRESC)*100,14)	//Valor total arrecadado / 086-099
	_cRet+=StrZero(Day(SE2->E2_VENCREA),2)+STRZERO(MONTH(SE2->E2_VENCREA),2)+STR(YEAR(SE2->E2_VENCREA),4)//Data da arrecadação / 100-107
	_cRet+=Space(08)														//Brancos / 108-115
	_cRet+=Space(50)														//Uso da empresa / 116-165
	_cRet+=Substr(SM0->M0_NOMECOM,1,30)										//Nome do Contribuinte / 166-195
ElseIf SEA->EA_MODELO$"16" //Pagamento de Darf Normal
	_cRet:="02"																//Codigo do tributo / pos. 018-019	
	_cRet+=Substr(SE2->E2_ESCRT  ,1,4)										//Codigo do pagamento / pos. 020-023		
	_cRet+="2"																//Tipo de Inscr. Contribuinte / pos. 024-024
	_cRet+=PADL(ALLTRIM(SM0->M0_CGC),14,"0")								//Identificação do Contribuinte - CNPJ/CGC/CPF / 025-038
	_cRet+=StrZero(Day(SE2->E2_XAPURAC),2)+STRZERO(MONTH(SE2->E2_XAPURAC),2)+STR(YEAR(SE2->E2_XAPURAC),4) //Competencia / 039-046
	_cRet+=IIF(EMPTY(SE2->E2_ESNREF),STRZERO(0,17),STRZERO(SE2->E2_ESNREF,17))	//Numero de referencia / 047-063	
	_cRet+=STRZERO(SE2->E2_SALDO*100,14)									//Valor Principal / 064-077
	_cRet+=STRZERO(SE2->E2_MULTA*100,14)									//Valor da Multa / 078-091
	_cRet+=STRZERO((SE2->E2_JUROS+SE2->E2_ACRESC)*100,14)						//Valor de Juros+Encargos / 092-105
	_cRet+=STRZERO((SE2->E2_SALDO+SE2->E2_MULTA+SE2->E2_JUROS+SE2->E2_ACRESC)*100,14)//Valor total arrecadado / 106-119
	_cRet+=StrZero(Day(SE2->E2_VENCREA),2)+STRZERO(MONTH(SE2->E2_VENCREA),2)+STR(YEAR(SE2->E2_VENCREA),4)//Data de Vencimento / 120-127
	_cRet+=StrZero(Day(SE2->E2_VENCREA),2)+STRZERO(MONTH(SE2->E2_VENCREA),2)+STR(YEAR(SE2->E2_VENCREA),4)//Data de pagamento  / 128-135
	_cRet+=space(30)		                              					// Brancos / 136-165
	_cRet+=Substr(SM0->M0_NOMECOM,1,30)										//Nome do Contribuinte / 166-195	
ElseIf SEA->EA_MODELO$"18"//Pagamento de Darf Simples
	_cRet:="03"																//Codigo do tributo / pos. 018-019	
	_cRet+=Substr(SE2->E2_ESCRT  ,1,4)										//Codigo do pagamento / pos. 020-023		
	_cRet+="2"																//Tipo de Inscr. Contribuinte / pos. 024-024
	_cRet+=PADL(ALLTRIM(SM0->M0_CGC),14,"0")								//Identificação do Contribuinte - CNPJ/CGC/CPF / 025-038
	_cRet+=StrZero(Day(SE2->E2_XAPURAC),2)+STRZERO(MONTH(SE2->E2_XAPURAC),2)+STR(YEAR(SE2->E2_XAPURAC),4) //Competencia / 039-046
	_cRet+=STRZERO(SE2->E2_ESVRBA*100,9)									//Valor da receita bruta acumulada / 047-055
	_cRet+=STRZERO(SE2->E2_ESPRB,4)											//Percentual da receita Bruta / 056-059
	_cRet+=Space(04)														//Brancos / 060-063	
	_cRet+=STRZERO(SE2->E2_SALDO*100,14)									//Valor Principal / 064-077
	_cRet+=STRZERO(SE2->E2_MULTA*100,14)									//Valor da Multa / 078-091
	_cRet+=STRZERO((SE2->E2_JUROS+SE2->E2_ACRESC)*100,14)						//Valor de Juros+Encargos / 092-105
	_cRet+=STRZERO((SE2->E2_SALDO+SE2->E2_MULTA+SE2->E2_JUROS+SE2->E2_ACRESC)*100,14)	//Valor total arrecadado / 106-119
	_cRet+=StrZero(Day(SE2->E2_VENCREA),2)+STRZERO(MONTH(SE2->E2_VENCREA),2)+STR(YEAR(SE2->E2_VENCREA),4)//Data de Vencimento / 120-127
	_cRet+=StrZero(Day(SE2->E2_VENCREA),2)+STRZERO(MONTH(SE2->E2_VENCREA),2)+STR(YEAR(SE2->E2_VENCREA),4)//Data de pagamento  / 128-135
	_cRet+=space(30)		                              					// Brancos / 136-165
	_cRet+=Substr(sm0->m0_nomecom,1,30)										//Nome do Contribuinte / 166-195	
ElseIf SEA->EA_MODELO$"21" // Pagamento de DARJ
	_cRet:="03"																//Codigo do tributo / pos. 018-019	
	_cRet+=Substr(SE2->E2_ESCRT  ,1,4)										//Codigo do pagamento / pos. 020-023		
	_cRet+="2"																//Tipo de Inscr. Contribuinte / pos. 024-024
	_cRet+=PADL(ALLTRIM(SM0->M0_CGC),14,"0")								//Identificação do Contribuinte - CNPJ/CGC/CPF / 025-038
	_cRet+=PADL(ALLTRIM(SM0->M0_INSC),8,"0")								//Identificação do Contribuinte - IE / 039-046
	_cRet+=STRZERO(SE2->E2_ESNORIG,16)										//Numero do documento de origem / 047-062
	_cRet+=Space(01)														//Branco / 063-063
	_cRet+=STRZERO(SE2->E2_SALDO*100,14)									//Valor de pagamento do INSS / 064-077
	_cRet+=STRZERO(SE2->E2_ACRESC*100,14)									//Valor somado ao valor do documento / 078-091
	_cRet+=STRZERO(SE2->E2_JUROS*100,14)									//Valor de Juros+Encargos / 092-105	
	_cRet+=STRZERO(SE2->E2_MULTA*100,14)									//Valor da Multa / 106-119
	_cRet+=STRZERO((SE2->E2_SALDO+SE2->E2_MULTA+SE2->E2_JUROS+SE2->E2_ACRESC)*100,14)	//Valor total arrecadado / 120-133
	_cRet+=StrZero(Day(SE2->E2_VENCREA),2)+STRZERO(MONTH(SE2->E2_VENCREA),2)+STR(YEAR(SE2->E2_VENCREA),4)//Data de Vencimento / 134-141
	_cRet+=StrZero(Day(SE2->E2_VENCREA),2)+STRZERO(MONTH(SE2->E2_VENCREA),2)+STR(YEAR(SE2->E2_VENCREA),4)//Data de pagamento  / 142-149
	_cRet+=STRZERO(VAL(SE2->E2_XCOMPET),6)									//Competencia / pos. 150-155
	_cRet+=space(10)		                              					// Brancos / 156-165
	_cRet+=Substr(SM0->M0_NOMECOM,1,30)										//Nome do Contribuinte / 166-195	
ElseIf SEA->EA_MODELO$"22" //Pagamento de Gare-SP (ICMS/DR/ITCMD)
	_cRet:="05"																//Codigo do tributo / pos. 018-019	
	_cRet+=Substr(SE2->E2_ESCRT  ,1,4)										//Codigo do pagamento / pos. 020-023		
	_cRet+="2"																//Tipo de Inscr. Contribuinte / pos. 024-024
	_cRet+=PADL(ALLTRIM(SM0->M0_CGC),14,"0")								//Identificação do Contribuinte - CNPJ/CGC/CPF / 025-038
	_cRet+=PADL(ALLTRIM(SM0->M0_INSC),12,"0")								//Identificação do Contribuinte - IE / 039-050
	_cRet+=STRZERO(SE2->E2_ESCDA,13)										//Numero da divida ativa / 051-063
	_cRet+=STRZERO(VAL(SE2->E2_XCOMPET),6)									//Competencia / pos. 064-069
	_cRet+=STRZERO(SE2->E2_ESNPN,13)										//Numero da parcela / 070-082
	_cRet+=STRZERO(SE2->E2_SALDO*100,14)									//Valor de pagamento / 083-091
	_cRet+=STRZERO((SE2->E2_JUROS+SE2->E2_ACRESC)*100,14)					//Valor de Juros+Encargos / 092-096
	_cRet+=STRZERO(SE2->E2_MULTA*100,14)									//Valor da Multa / 097-110
	_cRet+=STRZERO((SE2->E2_SALDO+SE2->E2_MULTA+SE2->E2_JUROS+SE2->E2_ACRESC)*100,14)	//Valor total arrecadado / 111-124
	_cRet+=StrZero(Day(SE2->E2_VENCREA),2)+STRZERO(MONTH(SE2->E2_VENCREA),2)+STR(YEAR(SE2->E2_VENCREA),4)//Data de Vencimento / 139-146
	_cRet+=StrZero(Day(SE2->E2_VENCREA),2)+STRZERO(MONTH(SE2->E2_VENCREA),2)+STR(YEAR(SE2->E2_VENCREA),4)//Data de pagamento  / 147-154
	_cRet+=space(11)		                              					// Brancos / 155-165
	_cRet+=Substr(sm0->m0_nomecom,1,30)										//Nome do Contribuinte / 166-195	
ElseIf SEA->EA_MODELO$"25" //Pagamentto de IPVA
	_cRet:="07"																//Codigo do tributo / pos. 018-019	
	_cRet+=Space(04)														//Brancos			 / pos. 020-023		
	_cRet+="2"																//Tipo de Inscr. Contribuinte / pos. 024-024
	_cRet+=PADL(ALLTRIM(SM0->M0_CGC),14,"0")								//Identificação do Contribuinte - CNPJ/CGC/CPF / 025-038
	_cRet+=STR(YEAR(SE2->E2_EMISSAO),4)										//Competencia / pos. 039-042
	_cRet+=PADL(ALLTRIM(SE2->E2_RENAV),9,"0")								//Codigo do Renavan / 043-051
	_cRet+=PADL(ALLTRIM(SE2->E2_UFESPAN),2,"0")//UF do estado do veiculo / 052-053
	_cRet+=PADL(ALLTRIM(SE2->E2_MUESPAN),5,"0")							//Codigo do Municipio / 054-058
	_cRet+=PADL(STRTRAN(ALLTRIM(SE2->E2_PLACA),"-",""),7,"0")				//Placa do Veiculo / 059-065
	_cRet+=PADL(ALLTRIM(SE2->E2_ESOPIP),1,"0")								//Codigo da cond. de pgto / 066-066
	_cRet+=STRZERO(SE2->E2_SALDO*100,14)									//Valor de pagamento / 067-080
	_cRet+=STRZERO(SE2->E2_DESCONT*100,14)									//Valor de desconto / 081-094 
	_cRet+=STRTRAN(STRZERO(SE2->E2_SALDO-SE2->E2_DESCONT*100,15,2),".","")	//Valor de pagamento / 095-108
	_cRet+=StrZero(Day(SE2->E2_VENCREA),2)+STRZERO(MONTH(SE2->E2_VENCREA),2)+STR(YEAR(SE2->E2_VENCREA),4)//Data de pagamento  / 109-116
	_cRet+=StrZero(Day(SE2->E2_VENCREA),2)+STRZERO(MONTH(SE2->E2_VENCREA),2)+STR(YEAR(SE2->E2_VENCREA),4)//Data de pagamento  / 117-124
	_cRet+=space(41)		                              					// Brancos / 125-165
	_cRet+=Substr(sm0->m0_nomecom,1,30)										//Nome do Contribuinte / 166-195	
ElseIf SEA->EA_MODELO$"27" //Pagamento DPVAT
	_cRet:="08"																//Codigo do tributo / pos. 018-019	
	_cRet+=Space(04)														//Brancos			 / pos. 020-023		
	_cRet+="2"																//Tipo de Inscr. Contribuinte / pos. 024-024
	_cRet+=PADL(ALLTRIM(SM0->M0_CGC),14,"0")								//Identificação do Contribuinte - CNPJ/CGC/CPF / 025-038
	_cRet+=STR(YEAR(SE2->E2_EMISSAO),4)										//Competencia / pos. 039-042
	_cRet+=PADL(ALLTRIM(SE2->E2_RENAV),9,"0")								//Codigo do Renavan / 043-051
	_cRet+=PADL(ALLTRIM(SE2->E2_UFESPAN),2,"0")//UF do estado do veiculo / 052-053
	_cRet+=PADL(ALLTRIM(SE2->E2_MUESPAN),5,"0")							//Codigo do Municipio / 054-058
	_cRet+=PADL(STRTRAN(ALLTRIM(SE2->E2_PLACA),"-",""),7,"0")				//Placa do Veiculo / 059-065
	_cRet+=PADL(ALLTRIM(SE2->E2_ESOPIP),1,"0")								//Codigo da cond. de pgto / 066-066
	_cRet+=STRZERO(SE2->E2_SALDO*100,14)									//Valor de pagamento / 067-080
	_cRet+=STRZERO(SE2->E2_DESCONT*100,14)									//Valor de desconto / 081-094 
	_cRet+=STRTRAN(STRZERO(SE2->E2_SALDO-SE2->E2_DESCONT*100,15,2),".","")	//Valor de pagamento / 095-108
	_cRet+=StrZero(Day(SE2->E2_VENCREA),2)+STRZERO(MONTH(SE2->E2_VENCREA),2)+STR(YEAR(SE2->E2_VENCREA),4)//Data de pagamento  / 109-116
	_cRet+=StrZero(Day(SE2->E2_VENCREA),2)+STRZERO(MONTH(SE2->E2_VENCREA),2)+STR(YEAR(SE2->E2_VENCREA),4)//Data de pagamento  / 117-124
	_cRet+=space(41)		                              					// Brancos / 125-165
	_cRet+=Substr(sm0->m0_nomecom,1,30)										//Nome do Contribuinte / 166-195	
ElseIf SEA->EA_MODELO$"35" // Pagamento de FGTS c/ Codigo de Barras
	_cRet:="11"																//Codigo do tributo / pos. 018-019	
	_cRet+=Padl(Alltrim(SE2->E2_ESCRT),4,"0")								//Codigo do pagamento / pos. 020-023		
	_cRet+="1"																//Tipo de Inscr. Contribuinte / pos. 024-024
	_cRet+=PADL(ALLTRIM(SM0->M0_CGC),14,"0")								//Identificação do Contribuinte - CNPJ/CGC/CPF / 025-038
	_cRet+=SUBSTR(SE2->E2_CODBAR,1,48)										//Codigo de Barras / 039-086
	_cRet+=STRZERO(SE2->E2_ESNFGTS,16)										//Ident. do FGTS / 087-102
	_cRet+=STRZERO(SE2->E2_ESLACRE,9)										//Lacre do FGTS / 103-111
	_cRet+=STRZERO(SE2->E2_ESDGLAC,2)										//DG Lacre do FGTS / 112-113
	_cRet+=Substr(sm0->m0_nomecom,1,30)										//Nome do Contribuinte / 114-143
	_cRet+=strzero(day(SE2->E2_VENCREA),2)+strzero(month(SE2->E2_VENCREA),2)+strzero(year(SE2->E2_VENCREA),4)//Data de pagamento  / 144-151
	_cRet+=STRZERO(SE2->E2_SALDO*100,14)									//Valor de pagamento / 152-165
	_cRet+=space(30)		                              					// Brancos / 166-195
EndIf
Return(_cRet)