#include 'protheus.ch'
#include 'parmtype.ch'

//#################
//# Programa      # APFATA08
//# Data          #   
//# Descri��o     # Rotina para atualiza��o de Moedas 
//# Desenvolvedor # Edie Carlos 
//# Empresa       # Totvs Nacoes Unidas
//# Linguagem     # eAdvpl     
//# Vers�o        # 12
//# Sistema       # Protheus
//# M�dulo        # Faturamento
//# Tabelas       # "SZA"
//# Observa��o    # Usado para fazer donwload site do bacen para atualiza��ode moedas 
//#===============#
//# Atualiza��es  # 
//#===============#
//#################

user function APFATA08()

	Local cFile, cTexto, nLinhas, j, lAuto,jj := .F.
	Local cMoeda :='' 

	If Select("SX2")==0 // Testa se est� sendo rodado do menu 
		RpcClearEnv()
		RpcSetType(3)
		WFprepenv("01","01") 
		lAuto := .T. 
	EndIf 

	dDataRef := dDataBase - 1 
	cFile := DTOS(dDataRef)+".csv" 

	cTexto := HTTPGET("http://www4.bcb.gov.br/download/fechamento/"+cFile) 
	nLinhas := MLCount(cTexto, 81) 

	If ! Empty(cTexto)

			For j := 1 to nLinhas 
				jj:=.t. 
				cLinha := Memoline(cTexto,81,j) 
				cData  := Substr(cLinha,1,10)
				cCodM  := Substr(cLinha,12,3) 
				cMoeda  := Substr(cLinha,18,3)
				cCompra := StrTran(Substr(cLinha,22,10),",",".") 
				cVenda  := StrTran(Substr(cLinha,22+11,10),",",".")
				 
	
				DbSelectArea("SZA") 
				DbSetOrder(1) 
	
					dData := CTOD(cData) 
					If DbSeek(DTOS(dData)+cMoeda) 
						Reclock("SZA",.F.) 
					Else 
						Reclock("SZA",.T.) 
						Replace ZA_DATA   With dData 
					EndIf 
					Replace ZA_CODBACE With cCodM
					Replace ZA_VLVENDA With Val(cVenda) 
					Replace ZA_VLCOMPR With Val(cCompra)
					Replace ZA_MOEDA   With cMoeda 
					MsUnlock("SZA")  

		   next 
	else 
		Alert(" Falha no processamento, verifique conexao com internet ou tente mais tarde !")       
	EndIf 

	If lAuto 
		RpcClearEnv() 
	EndIf 

Return 