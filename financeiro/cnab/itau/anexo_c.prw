#include "rwmake.ch"
#include "protheus.ch"

User Function Anexo_C()
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ Tributos ³ Autor ³ Cristina              ³ Data ³ 27/05/11 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ ExecBlock disparado do 341REM.PAG para retornar dados dos  ³±±
±±³          ³ tributos posicao 018 a 195 - Segmento N                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SISPAG                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Private _aArea := {}
_aArea := GetArea()

_BReturn   := ""
           

IF SEA->EA_MODELO == "17" // GPS


	_BReturn := _BReturn + "01" 
	_BReturn := _BReturn + STRZERO(VAL(SE2->E2_XCODREC),4) // id.do tributo + codigo de pagamento
	_BReturn := _BReturn + SE2->E2_XREFERE  //mes e ano base do tributo
	_BReturn := _BReturn + If(Empty(Alltrim(SE2->E2_XCNPJC)),SUBSTR(SA2->A2_CGC,1,14),SE2->E2_XCNPJC) // CNPJ do Contribuinte   - Fornecedor
	_BReturn := _BReturn + STRZERO(SE2->E2_SALDO*100,14) // Valor do pagamento
	_BReturn := _BReturn + STRZERO((SE2->E2_XVLENT)*100,14) // valor de outras entidades
	_BReturn := _BReturn + STRZERO(0,14) // atualizacao monetaria
	_BReturn := _BReturn + STRZERO((SE2->E2_SALDO+SE2->E2_XVLENT)*100,14) // Valor arrecadado
	_BReturn := _BReturn + GRAVADATA(SE2->E2_VENCREA,.F.,5) // Data do pagamento
	_BReturn := _BReturn + SPACE(8) // complemento de registro
	_BReturn := _BReturn + SE2->E2_IDCNAB + Space(40)  // campo de uso da empresa	
	_BReturn := _BReturn + If(Empty(Alltrim(SE2->E2_XCONTR )),SUBSTR(SA2->A2_NOME,1,60),SE2->E2_XCONTR ) // Nome do Contribuinte  - Fornecedor
	

Elseif SEA->EA_MODELO = "16" // DARF

	_BReturn := _BReturn + "02"              
	_BReturn := _BReturn + strzero(val(SE2->E2_CODRET),4) //IF(Empty(SE2->E2_CODRET),strzero(val(SE2->E2_XCODRE),4),strzero(val(SE2->E2_CODRET),4)) // id.do tributo + codigo de retencao
	_BReturn := _BReturn + "2" // tipo da inscricao 2 = cnpj	
	_BReturn := _BReturn + SUBSTR(SM0->M0_CGC,1,14) // CNPJ da Petra RJ
	_BReturn := _BReturn + GRAVADATA(SE2->E2_PERAPUR,.F.,5) // periodo de apuracao DDMMAAAA
	_BReturn := _BReturn + STRZERO(val(SE2->E2_NREFERE),17)//IF(Empty(SE2->E2_CODRET),strzero(val(SE2->E2_XCODRE),17),strzero(val(SE2->E2_CODRET),17)) // id.do tributo + codigo de retencao///STRZERO(val(SE2->E2_XNREFE),17) // numero de referencia		Caracter 17
	_BReturn := _BReturn + STRZERO((SE2->E2_SALDO)*100,14) // Valor principal
	_BReturn := _BReturn + IIF(SE2->E2_MULTA<>0,STRZERO((SE2->E2_MULTA)*100,14),STRZERO((SE2->E2_ACRESC)*100,14)) // Valor da multa
	_BReturn := _BReturn + STRZERO((SE2->E2_JUROS)*100,14) // Valor do Juros 	
	_BReturn := _BReturn + STRZERO((SE2->E2_SALDO+SE2->E2_JUROS+SE2->E2_MULTA+SE2->E2_ACRESC)*100,14) // Valor Total a ser pago
	_BReturn := _BReturn + GRAVADATA(SE2->E2_VENCREA,.F.,5) // Data de Vencimento	
	_BReturn := _BReturn + GRAVADATA(SE2->E2_VENCREA,.F.,5) // Data do pagamento
        _BReturn := _BReturn + Space(30)  // Brancos                                  
	_BReturn := _BReturn + SUBSTR(SM0->M0_NOMECOM,1,30) // Nome do Contribuinte      
	
Elseif SEA->EA_MODELO = "18" // DARF SIMPLES

	_BReturn := _BReturn + "03" 
	_BReturn := _BReturn + strzero(val(SE2->E2_CODRET),4) //IF(Empty(SE2->E2_CODRET),strzero(val(SE2->E2_XCODRE),4),strzero(val(SE2->E2_CODRET),4)) // id.do tributo + codigo de retencao
	_BReturn := _BReturn + "2" // tipo da inscricao 2 = cnpj	
	_BReturn := _BReturn + SUBSTR(SM0->M0_CGC,1,14) // CNPJ do Contribuinte                                               
	_BReturn := _BReturn + GRAVADATA(SE2->E2_PERAPUR,.F.,5) // periodo de apuracao DDMMAAAA
	_BReturn := _BReturn + "000000000"      // valor da receita bruta
    _BReturn := _BReturn + "0000"      // percentual   
    _BReturn := _BReturn + Space(4)  // Brancos                                  
	_BReturn := _BReturn + STRZERO((SE2->E2_SALDO)*100,14) // Valor principal
	_BReturn := _BReturn + IIF(SE2->E2_MULTA<>0,STRZERO((SE2->E2_MULTA)*100,14),STRZERO((SE2->E2_ACRESC)*100,14)) // Valor da multa
	_BReturn := _BReturn + STRZERO((SE2->E2_JUROS)*100,14) // Valor do Juros 	
	_BReturn := _BReturn + STRZERO((SE2->E2_SALDO+SE2->E2_JUROS+SE2->E2_MULTA+SE2->E2_ACRESC)*100,14) // Valor Total a ser pago
	_BReturn := _BReturn + GRAVADATA(SE2->E2_VENCREA,.F.,5) // Data de Vencimento	
	_BReturn := _BReturn + GRAVADATA(SE2->E2_VENCREA,.F.,5) // Data do pagamento
    _BReturn := _BReturn + Space(30)  // Brancos                                  
	_BReturn := _BReturn + SUBSTR(SM0->M0_NOMECOM,1,30) // Nome do Contribuinte      


Elseif SEA->EA_MODELO = "21" // DARJ

	_BReturn := _BReturn + "04" 
	_BReturn := _BReturn + strzero(val(SE2->E2_CODRET),4) //IF(Empty(SE2->E2_CODRET),strzero(val(SE2->E2_XCODRE),4),strzero(val(SE2->E2_CODRET),4))  // id.do tributo + codigo de retencao
	_BReturn := _BReturn + "2" // tipo da inscricao 2 = cnpj	
	_BReturn := _BReturn + SUBSTR(SM0->M0_CGC,1,14) // CNPJ do Contribuinte                                               
	_BReturn := _BReturn + STRZERO(VAL(SM0->M0_INSC),8) // Inscricao Estadual do Contribuinte                                               	
	_BReturn := _BReturn + STRZERO(VAL(SE2->E2_IDCNAB),16)  // numero do documento de origem	
    _BReturn := _BReturn + Space(1)  // Brancos                                  
	_BReturn := _BReturn + STRZERO((SE2->E2_SALDO)*100,14) // Valor principal
	_BReturn := _BReturn + STRZERO(0,14) // valor de atualizacao monetaria
	_BReturn := _BReturn + STRZERO((SE2->E2_JUROS)*100,14) // Valor da mora
	_BReturn := _BReturn + IIF(SE2->E2_MULTA<>0,STRZERO((SE2->E2_MULTA)*100,14),STRZERO((SE2->E2_ACRESC)*100,14)) // Valor da multa
	_BReturn := _BReturn + STRZERO((SE2->E2_SALDO+SE2->E2_JUROS+SE2->E2_MULTA+SE2->E2_ACRESC)*100,14) // Valor Total a ser pago
	_BReturn := _BReturn + GRAVADATA(SE2->E2_VENCREA,.F.,5) // Data de Vencimento	
	_BReturn := _BReturn + GRAVADATA(SE2->E2_VENCREA,.F.,5) // Data do pagamento
	_BReturn := _BReturn + SUBSTR(SE2->E2_XREFERE,4,4)
    _BReturn := _BReturn + Space(10)  // Brancos                                  
	_BReturn := _BReturn + SUBSTR(SM0->M0_NOMECOM,1,30) // Nome do Contribuinte      
  


Elseif SEA->EA_MODELO = "22" // ICMS

	_BReturn := _BReturn + "05" 
	_BReturn := _BReturn + strzero(val(SE2->E2_CODRET),4) //IF(Empty(SE2->E2_CODRET),strzero(val(SE2->E2_XCODRE),4),strzero(val(SE2->E2_CODRET),4)) // codigo da receita caracter 4
	_BReturn := _BReturn + "1" // tipo da inscricao 1 = cnpj	
	_BReturn := _BReturn + SUBSTR(SM0->M0_CGC,1,14) // CNPJ do Contribuinte                                               
	_BReturn := _BReturn + strzero(val(SM0->M0_INSC),12) // Inscricao Estadual do Contribuinte                                               	
	_BReturn := _BReturn + STRZERO(0,13)  // divida ativa / numero da etiqueta   Numerico 13
	_BReturn := _BReturn + SE2->E2_XREFERE//mes e ano
	_BReturn := _BReturn + strzero(val(SE2->E2_PARCELA),13) // numero da parcela / notificacao  Numerico 13
	_BReturn := _BReturn + STRZERO((SE2->E2_SALDO)*100,14) // Valor principal
	_BReturn := _BReturn + STRZERO((SE2->E2_ACRESC)*100,14) // Valor da mora
	_BReturn := _BReturn + "00000000000000" //IIF(SE2->E2_MULTA<>0,STRZERO((SE2->E2_MULTA)*100,14),STRZERO((SE2->E2_ACRESC)*100,14)) // Valor da multa
	_BReturn := _BReturn + STRZERO((SE2->E2_SALDO+SE2->E2_ACRESC)*100,14) // Valor Total a ser pago
	_BReturn := _BReturn + GRAVADATA(SE2->E2_VENCREA,.F.,5) // Data de Vencimento	
	_BReturn := _BReturn + GRAVADATA(SE2->E2_VENCREA,.F.,5) // Data do pagamento
	_BReturn := _BReturn + SPACE(11)  // complemento de registro
	_BReturn := _BReturn + SUBSTR(SM0->M0_NOMECOM,1,30) // Nome do Contribuinte      

Elseif SEA->EA_MODELO = "25" // IPVA

	_BReturn := _BReturn + "07"  // id.do tributo
	_BReturn := _BReturn + Space(4)  // Brancos                                  	
	_BReturn := _BReturn + "2" // tipo da inscricao 2 = cnpj	
	_BReturn := _BReturn + SUBSTR(SM0->M0_CGC,1,14) // CNPJ do Contribuinte                                               
	_BReturn := _BReturn + SUBSTR(SE2->E2_XREFERE,3,4)  // ano base do tributo
	_BReturn := _BReturn + STRZERO(SE2->E2_XRENAV,9)   // codigo do renavam    Numerico 9
	_BReturn := _BReturn + SA2->A2_EST // unidade de federacao 
	_BReturn := _BReturn + SA2->A2_COD_MUN // codigo do municipio 
	_BReturn := _BReturn + SE2->E2_XPLACA   // placa do veiculo   caracter 7
	_BReturn := _BReturn + SE2->E2_XOPAGTO    // opcoes de pagamento       caracter 1 (0=Pgto DPVAT;1=Parc.Unica c/desconto;2=Parc.Unica s/desconto;3=Parc.1;4=Parc.2;5=Parc.3;6=Parc.4;7=Parc.5;8=Parc.6)
	_BReturn := _BReturn + STRZERO((SE2->E2_SALDO)*100,14) // Valor principal
	_BReturn := _BReturn + STRZERO((SE2->E2_DECRESC)*100,14) // Valor do desconto
	_BReturn := _BReturn + STRZERO((SE2->E2_SALDO-SE2->E2_DECRESC)*100,14) // Valor Total a ser pago
	_BReturn := _BReturn + GRAVADATA(SE2->E2_VENCREA,.F.,5) // Data de Vencimento	
	_BReturn := _BReturn + GRAVADATA(SE2->E2_XDTPGT,.F.,5) // Data do pagamento
    _BReturn := _BReturn + Space(41)  // Brancos                                  
	_BReturn := _BReturn + SUBSTR(SM0->M0_NOMECOM,1,30) // Nome do Contribuinte      


Elseif SEA->EA_MODELO = "27" // DPVAT

	_BReturn := _BReturn + "08"  // id.do tributo
	_BReturn := _BReturn + Space(1)  // Brancos                                  	
	_BReturn := _BReturn + "2" // tipo da inscricao 2 = cnpj	
	_BReturn := _BReturn + SUBSTR(SM0->M0_CGC,1,14) // CNPJ do Contribuinte                                               
	_BReturn := _BReturn + SUBSTR(SE2->E2_XREFERE,4,4) // ano base do tributo
	_BReturn := _BReturn + STRZERO(SE2->E2_XRENAV,9)   // codigo do renavam campo numerico 9
	_BReturn := _BReturn + SA2->A2_EST // unidade de federacao 
	_BReturn := _BReturn + SA2->A2_COD_MUN // codigo do municipio 
	_BReturn := _BReturn + SE2->E2_XPLACA   // placa do veiculo
	_BReturn := _BReturn + SE2->E2_XOPAGTO    // opcoes de pagamento 
	_BReturn := _BReturn + STRZERO((SE2->E2_SALDO)*100,14) // Valor principal
	_BReturn := _BReturn + STRZERO((SE2->E2_DECRESC)*100,14) // Valor do desconto
	_BReturn := _BReturn + STRZERO((SE2->E2_SALDO-SE2->E2_DECRESC)*100,14) // Valor Total a ser pago
	_BReturn := _BReturn + GRAVADATA(SE2->E2_VENCREA,.F.,5) // Data de Vencimento	
	_BReturn := _BReturn + GRAVADATA(SE2->E2_VENCREA,.F.,5) // Data do pagamento
    _BReturn := _BReturn + Space(41)  // Brancos                                  
	_BReturn := _BReturn + SUBSTR(SM0->M0_NOMECOM,1,30) // Nome do Contribuinte      


Elseif SEA->EA_MODELO = "35" // FGTS-GFIP

	_BReturn := _BReturn + "11" 
	_BReturn := _BReturn + strzero(val(SE2->E2_CODRET),4) //IF(Empty(SE2->E2_CODRET),strzero(val(SE2->E2_XCODRE),4),strzero(val(SE2->E2_CODRET),4)) // id.do tributo + codigo de retencao
	_BReturn := _BReturn + "1" // tipo da inscricao 2 = cnpj	
	_BReturn := _BReturn + SUBSTR(SM0->M0_CGC,1,14) // CNPJ do Contribuinte                                               
	_BReturn := _BReturn + SUBSTR(SE2->E2_CODBAR,1,48)   // codigo de barras   
	_BReturn := _BReturn + SE2->E2_XIDENT   // Identificador do FGTS     caracter 16
	_BReturn := _BReturn + SE2->E2_XLACRE  // lacre de conectividade social   caracter  9
	_BReturn := _BReturn + IIF(!Empty(SE2->E2_XDACLAC),STRZERO(val(SE2->E2_XDACLAC),2),Substr(SE2->E2_XDACLAC,1,2))  // digito do lacre	caracter 2
	_BReturn := _BReturn + SUBSTR(SM0->M0_NOMECOM,1,30) // Nome do Contribuinte      
	_BReturn := _BReturn + GRAVADATA(SE2->E2_VENCREA,.F.,5) // Data de Vencimento	
	_BReturn := _BReturn + STRZERO((SE2->E2_SALDO)*100,14) // Valor principal		
    _BReturn := _BReturn + Space(30)  // Brancos                                  		
	
Endif

RestArea(_aArea)

Return(_BReturn)

