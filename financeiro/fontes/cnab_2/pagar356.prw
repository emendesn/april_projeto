#INCLUDE "RWMAKE.CH"

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±ºPrograma  ³PAGAR356  ºAutor    ³Marciane Gennari    º Data ³  22/10/10 º±±  
±±º			 ³			ºAlterado ³Flavio Ricci	       º Data ³  29/02/12 º±±
±±º			 ³			ºAlterado ³Eduardo Augusto     º Data ³  22/02/13 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Gera as informacoes para o cnab a pagar o banco do REAL  . º±±
±±º                                                                       º±±
±±ºParametros:                                                            º±±
±±º                                                                       º±±
±±º  01 - Retorna o nome do contribuinte (segmento N)                     º±±
±±º  02 - Retorna os detalhes do segmento N (depende do tipo do tributo)  º±±
±±º                                                                       º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³  Protheus 11 - Bimetal                                     º±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

User Function Pagar356(_cOpcao)

Local _cReturn := ""
If _cOpcao == "01"   // Nome do Contribuinte
   If !Empty(SE2->E2_ESIDPG)
      _cReturn := Substr(SE2->E2_XCONTR,1,30)
      If Empty(_cReturn)
         MsgAlert("Nome do Contribuinte não informado para o segmento N - Titulo " + AllTrim(SE2->E2_PREFIXO) + "-" + AllTrim(SE2->E2_NUM) + "-" +; 
         AllTrim(SE2->E2_PARCELA) + ". Atualize o Nome do Contribuinte no titulo indicado e execute esta rotina novamente.")
      EndIf
  Else
      _cReturn := Substr(SM0->M0_NOMECOM,1,30)
  EndIf   
ElseIf _cOpcao == "02"   // Detalhes Segmento N 
  If SEA->EA_MODELO == "18"	// Codigo Receita do Tributo - Posicao 111 a 116                                                                         
     _cReturn := "006106"+SPACE(2)	// Para DARF Simples - fixar código 6106
  Else
     _cReturn := If(!Empty(SE2->E2_ESCRT),"00" + SE2->E2_ESCRT,SE2->E2_CODRET)
  EndIf 
  If !Empty(SE2->E2_ESIDPG)	// Tipo de Identificacao do Contribuinte - Posicao 117 a 118
     _cReturn += Iif (Len(AllTrim(SE2->E2_ESIPDG))>11,"02","01")	// CNPJ (2) /  CPF (1)             
  Else               
     _cReturn += "01"           
  EndIf
  If SEA->EA_MODELO == "22"  // Para GARE ICMS - Retornar o CNPJ da Filial do SE2->E2_FILIAL
      _cReturn +=  Strzero(Val(u_dadosSM0("02",SE2->E2_FILIAL)),14)	                               
  Else
      If !Empty(SE2->E2_ESIDPG)
         _cReturn += Strzero(Val(SE2->E2_ESIDPG),14)	// Identificacao do Contribuinte - Posicao 119 a 132
      Else
        _cReturn += Subs(SM0->M0_CGC,1,14)	// CNPJ/CPF do Contribuinte    
      EndIf
  EndIf                          
  _cReturn += SEA->EA_MODELO 

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±ºDesc.     ³  Identificacao do Tributo - Posicao 133 a 134              º±±
±±º          ³  16 - DARF Normal                                          º±±
±±º          ³  17 - GPS                                                  º±±
±±º          ³  18 - DARF Simples                                         º±±
±±º          ³  19 - IPTU                                                 º±±
±±º          ³  22 - GARE-SP ICMS                                         º±±   // Alteracao Eduardo Augusto
±±º          ³  23 - GARE-SP DR                                           º±±
±±º          ³  24 - GARE-SP ITCMD                                        º±±
±±º          ³  25 - IPVA                                                 º±±
±±º          ³  26 - Licenciamento                                        º±±
±±º          ³  27 - DPVAT                                                º±±
±±º          ³  35 - FGTS                                                 º±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
                  
  If SEA->EA_MODELO == "17" //GPS
     _cReturn += Strzero(Month(SE2->E2_EMISSAO),2)+Strzero(Year(SE2->E2_EMISSAO),4)	// Competencia (Mes/Ano) - Posicao 135 a 140  Formato MMAAAA
     _cReturn += Strzero((SE2->E2_SALDO-SE2->E2_ACRESC)*100,15)						// Valor do Tributo - Posicao 141 a 155
     _cReturn += Strzero(SE2->E2_ACRESC*100,15)          							// Valor Outras Entidades - Posicao 156 a 170             
     _cReturn += Strzero((SE2->E2_MULTA+SE2->E2_JUROS)*100,15)						// Atualizacao Monetaria - Posicao 171 a 185                        
     If Empty(SE2->E2_ESCRT)	// Mensagem ALERTA que está sem Codigo da Receita
             MsgAlert("Tributo sem Codigo Receita. Informe o campo Cod.Receita no Titulo: " + AllTrim(SE2->E2_PREFIXO) +" " + AllTrim(SE2->E2_NUM) + " " +;
             AllTrim(SE2->E2_PARCELA) + " Tipo: " + AllTrim(SE2->E2_TIPO) + " Fornecedor/Loja: " + AllTrim(SE2->E2_FORNECE) + "-" + AllTrim(SE2->E2_LOJA)+ " e execute esta rotina novamente.")
     EndIf
     If Empty(SE2->E2_EMISSAO)    // Mensagem ALERTA que está sem Periodo de Apuração                              
        MsgAlert("Tributo sem Periodo de Apuracao. Informe o campo Per.Apuracao no Titulo: " + AllTrim(SE2->E2_PREFIXO) + " " + AllTrim(SE2->E2_NUM) + " " +;
        AllTrim(SE2->E2_PARCELA) + " Tipo: " + AllTrim(SE2->E2_TIPO) + " Fornecedor/Loja: " + AllTrim(SE2->E2_FORNECE) + "-" + AllTrim(SE2->E2_LOJA) + " e execute esta rotina novamente.")
     EndIf   
  ElseIf SEA->EA_MODELO == "16" // DARF Normal
     _cReturn += Gravadata(SE2->E2_EMISSAO,.F.,5)		// Periodo de Apuracao - Posicao 135 a 142  Formato DDMMAAAA                               
     _cReturn += Strzero(Val(SE2->E2_ESNREF),17)		// N° de Referencia - Posicao 143 a 159                     
     _cReturn += Strzero(SE2->E2_SALDO*100,15)			// Valor Principal - Posicao 160 a 174
     _cReturn += Strzero(SE2->E2_MULTA*100,15)			// Valor da Multa - Posicao 175 a 189             
     _cReturn += Strzero(SE2->E2_JUROS*100,15)			// Valor Juros/Encargos - Posicao 190 a 204                        
     _cReturn += Gravadata(SE2->E2_VENCTO,.F.,5)		// Data de Vencimento - Posicao 205 a 212  Formato DDMMAAAA
/*
     If Empty(SE2->E2_CODRET)	// Mensagem ALERTA que está sem Codigo da Receita para DARF de Retenção                              
     	MsgAlert("Tributo sem Codigo Receita. Informe o campo Cd.Retenção no Titulo: " + AllTrim(SE2->E2_PREFIXO) + " " + AllTrim(SE2->E2_NUM) + " " +;
     	AllTrim(SE2->E2_PARCELA) + " Tipo: " + AllTrim(SE2->E2_TIPO) + " Fornecedor/Loja: " + AllTrim(SE2->E2_FORNECE) + "-" + AllTrim(SE2->E2_LOJA) + " e execute esta rotina novamente.")
     EndIf
*/     
     If Empty(se2->e2_e_apur)	// Mensagem ALERTA que está sem periodo de apuração
        MsgAlert("Tributo sem Periodo de Apuracao. Informe o campo Per.Apuracao no Titulo: " + AllTrim(SE2->E2_PREFIXO) + " " + AllTrim(SE2->E2_NUM) + " " +; 
        AllTrim(SE2->E2_PARCELA) + " Tipo: " + AllTrim(SE2->E2_TIPO) + " Fornecedor/Loja: " + AllTrim(SE2->E2_FORNECE) + "-" + AllTrim(SE2->E2_LOJA) + " e execute esta rotina novamente.")
     EndIf
  ElseIf SEA->EA_MODELO == "18"	// DARF Simples                  
     _cReturn += Gravadata(SE2->E2_EMISSAO,.F.,5)	// Periodo de Apuração  (Dia/Mes/Ano) - Posicao 135 a 142  Formato DDMMAAAA
     _cReturn += Repl("0",15)						// Receita Bruta - Posicao 143 a 157                     
     _cReturn += Repl("0",7)						// Percentual - Posicao 158 a 164
     _cReturn += Strzero(SE2->E2_SALDO*100,15)		// Valor Principal - Posicao 165 a 179
     _cReturn += Strzero(SE2->E2_XMULTA*100,15)		// Valor da Multa - Posicao 180 a 194             
     _cReturn += Strzero(SE2->E2_E_JUROS*100,15)	// Valor Juros/Encargos - Posicao 195 a 209                        
     If Empty(SE2->E2_EMISSAO)	// Mensagem ALERTA que está sem periodo de apuração
        MsgAlert("Tributo sem Periodo de Apuracao. Informe o campo Per.Apuracao no Titulo: " + AllTrim(SE2->E2_PREFIXO) + " " + AllTrim(SE2->E2_NUM) + " " +; 
        AllTrim(SE2->E2_PARCELA) + " Tipo: " + AllTrim(SE2->E2_TIPO) + " Fornecedor/Loja: " + AllTrim(SE2->E2_FORNECE) + "-" + AllTrim(SE2->E2_LOJA) + " e execute esta rotina novamente.")
     EndIf   
  ElseIf SEA->EA_MODELO == "22" // GARE ICMS - SP
     _cReturn += Gravadata(SE2->E2_VENCREA,.F.,5)									// Data de Vencimento - Posicao 135 a 142  Formato DDMMAAAA
     _cReturn += Strzero(Val(u_dadosSM0("01",SE2->E2_FILIAL)),12)					// Inscricao Estadual - Posicao 143 a 154                                                 
     _cReturn += Strzero(Val(SE2->E2_ESCDA),13)										// Divida Ativa / Etiqueta - Posicao 155 a 167 
     _cReturn += Strzero(Month(SE2->E2_EMISSAO),2)+Strzero(Year(SE2->E2_EMISSAO),4)	// Periodo de Referencia (Mes/Ano) - Posicao 168 a 173  Formato MMAAAA  
     _cReturn += Strzero(Val(SE2->E2_ESNPN),13)										// N. Parcela / Notificação - Posicao 174 a 186 
     _cReturn += Strzero(SE2->E2_SALDO*100,15)										// Valor da Receita (Principal) - Posicao 187 a 201
     _cReturn += Strzero(SE2->E2_JUROS*100,14)										// Valor Juros/Encargos - Posicao 202 a 215                                                      
     _cReturn += Strzero(SE2->E2_MULTA*100,14)										// Valor da Multa - Posicao 216 a 229                  
  ElseIf SEA->EA_MODELO == "25"  .or. SEA->EA_MODELO == "26" .or. SEA->EA_MODELO == "27"	// 25 = IPVA, 26 = Licenciamento, 27 = DPVAT
     _cReturn += Strzero(SE2->E2_ANOBAS,4)			// Exercicio Ano Base - Posicao 135 a 138
      _cReturn +=  Strzero(Val(SE2->E2_RENAV),9)	// Renavam - Posicao 139 a 147 
      _cReturn +=  Upper(SE2->E2_IPVUF)				// Unidade Federação - Posicao 148 a 149 
     _cReturn += Strzero(Val(SE2->E2_CODMUN),5)		// Codigo do Municipio - Posicao 150 a 154
      _cReturn +=  SE2->E2_PLACA					// Placa - Posicao 155 a 161 
     If SEA->EA_MODELO == "25"						// Opção de Pagamento - Posicao 162 a 162 - Para DPVAT sempre opção 5
        _cReturn += Alltrim(SE2->E2_OPCAO)
     Else
        _cReturn += "5"   // Para 27-DPVAT e 26-Licenciamento é obrigatório utilizar o código 5.
     EndIf
    //---- 1 = Correio
    //---- 2 = Detran / Ciretran
     If SEA->EA_MODELO == "26"	// Opção de Retirada do CRVL - Posicao 163 a 163 - Somente para LICENCIAMENTO    
        _cReturn += "1"    // Definido por Giovana sempre 1 = Correio
     EndIf
  EndIf           
EndIf       
Return(_cReturn)       

User Function DadosSM0(_cOpc,_cFilSE2)	// Retornar Inscrição Estadual e CNPJ da Filial do Título do SE2
                                                            
Local _cVolta := ""
Local _nRecnoSM0 :=SM0->(Recno())
  SM0->(dbSetOrder(1))
  SM0->(dbSeek(cEmpAnt+_cFilSE2))
  If _cOpc == "01"
     _cVolta := SM0->M0_INSC 
  Else
    _cVolta := SM0->M0_CGC
  EndIf
SM0->(dbGoto(_nRecnoSM0))
Return(_cVolta)