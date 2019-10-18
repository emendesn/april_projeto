#include "apwebsrv.ch"
#include "totvs.ch"
#include "fileio.ch"
#include 'protheus.ch'
#include "xmlxfun.ch"
#include "topconn.ch"
#include "rwmake.ch"
#include "tbiconn.ch"
#include "error.ch" 

/*/{Protheus.doc} WsAprilCanFat
WSDL com métodos a serem consumidos pela aplicação TAVOLA 
da empresa  APRIL BRASIL TURISMO VIAGENS E ASSISTENCIA INTERNACIONAL LTDA, 
com o objetivo de realizar cancelamentos de Fatura na tabela Ponte Customizada SZ0.

@type 	Fonte WSDL
@author Ivan de Oliveira - TNU
@since 	10/05/2017 
/*/
 
 // Inicio Definição Requisição//STRING, DATE, INTEGER, FLOAT, BOOLEAN, BASE64Binary
WsStruct _aSolFtCanc

	WSDATA CCHAVE		As String
	WSDATA CIDCLIENT	As String
	WSDATA CFATURA		As String
	WSDATA CTPMOD		As String
	WSDATA CTPFAT		As String
	WSDATA CNUM  		As String  
	WSDATA CCLIENTE		As String
	WSDATA CLOJACLI		As String
	WSDATA CIDCGC		As String
	WSDATA CIDCPF		As String
	WSDATA CPARCELA		As String
	WSDATA CDTVEN		As String
	WSDATA CEMISSAO		As String
	WSDATA NPREMIO 		as Float
	WSDATA NVLRTO		as Float
	WSDATA NIOF			as Float
	WSDATA CCANC		As String
	WSDATA DCANC		As String
	WSDATA CHRCANC		As String
	WSDATA CUSRLOG		As String
	WSDATA CNFFAT		As String
	WSDATA CSERIRNF		As String
	WSDATA CEMISNF		As String
	WSDATA CCNPJ_EMIT	As String
	
EndWsstruct

WsStruct EstrSolCanFT

  Wsdata _eSolCanc As Array of _aSolFtCanc

EndwSstruct
// Final Definição Requisição

 // Inicio Definição da estrutura Dados Retorno - Inclusão
WsStruct _aRetCancF
	
	Wsdata CCHAVE	 	AS String 
	Wsdata CEMP		 	AS String 
	Wsdata CFIL	 		AS String 
	Wsdata CFATURA  	AS String 
	Wsdata CMSGRET  	AS String
	WsData CRETORNO		as String
	
EndWsstruct

WsStruct EstrRetCanFT

	Wsdata _eRetCancF As Array of _aRetCancF

EndWsstruct
// Final Definição Retorno

WSSERVICE WsAprilCanFat DESCRIPTION "Serviço destinado ao cancelamento na tabela MIDDLEWARE como ponte para emissão Faturas Tavola x Protheus"
 
	Wsdata WSSOLCANCFAT As EstrSolCanFT
	Wsdata WSRETCANCFAT	As EstrRetCanFT
	
	//  Métodos //
	WsMethod FatCanc Description "Cancelamento de Fatura na tabela no MIDDLEWARE para emissão Faturas: Távola x Protheus"
	 
EndWsservice

/*/{Protheus.doc} FatCanc
Método de WebService para Cancelamento de Fatura tabela no MIDDLEWARE SZ0 
@type 		Método Fonte WSDL
@author 	Ivan de Oliveira
@since 		10/05/2017 
@version 	1.0
@return 	${Lógico}, ${.t.}
 /*/ 
WSMETHOD FatCanc WSRECEIVE WSSOLCANCFAT WSSEND WSRETCANCFAT WSSERVICE WsAprilCanFat

Local _cEmp 	:= _cFil := _cGrpEmp := _cUnNeg := ''
Local _aEmpresas:= {}
Local _nIt  	:= 0
Local _nOpc 	:= 0
Local _cMensRet := ''
Local _cErroFont:= ''
Local _cLinErro := 's/id'
Local _oError   := ErrorBlock({|e| u_EFATM001(e, @_cLinErro, @_cErroFont)})
 
 
Private lMsErroAuto := .f. 

// Tratamentos de erros
Begin Sequence

	// Montando ESTRUTURA retorno
	::WSRETCANCFAT:_eRetCancF := Array(1)
		 
	::WSRETCANCFAT:_eRetCancF[01]:= WSClassNew("_aRetCancF")
	::WSRETCANCFAT:_eRetCancF[01]:CCHAVE   := 'Erro Estrutural'   
	::WSRETCANCFAT:_eRetCancF[01]:CEMP 	   := _cEmp 
	::WSRETCANCFAT:_eRetCancF[01]:CFIL	   := _cFil 
	::WSRETCANCFAT:_eRetCancF[01]:CFATURA  := ' '
	::WSRETCANCFAT:_eRetCancF[01]:CMSGRET  := ' '
	::WSRETCANCFAT:_eRetCancF[01]:CRETORNO := '.F.'
	
	//Verificando se a entrada dados e uma estrutura
	if valtype(::WSSOLCANCFAT:_eSolCanc) == 'A' .AND. !Empty(::WSSOLCANCFAT:_eSolCanc)
	
		// Verificando se o CNPJ emitente existe
		_cCnpjEmit := Alltrim(::WSSOLCANCFAT:_eSolCanc[01]:CCNPJ_EMIT)	
		if u_FatM001(_cCnpjEmit,@_cEmp, @_cFil,@_aEmpresas )
	
			//Abrindo os ambientes
			RpcSetType(3)
			RpcSetEnv(_cEmp, _cFil)
			
			// Coleta informações da filial, unid neg, grupo etc.
			_aInfoFil := FWArrFilAtu(_cEmp, _cFil)
			
			// Grupo Empresa e Un Neg.
			_cGrpEmp := _aInfoFil[03]
			_cUnNeg  := _aInfoFil[04]
	
	 		// Verificando autenticação
			if Alltrim(SuperGetmv('AP_AUTWS', .T., 'April@2017' )) <> Alltrim(Decode64(::WSSOLCANCFAT:_eSolCanc[01]:CCHAVE ))
		
				_cMensRet := 'Error 999 - Token Invalido. Obtenha e Informe um Novo Token.'
				::WSRETCANCFAT:_eRetCancF[01]:CCHAVE  := alltrim(::WSSOLCANCFAT:_eSolCanc[01]:cFATURA) + alltrim(::WSSOLCANCFAT:_eSolCanc[01]:CPARCELA)
				::WSRETCANCFAT:_eRetCancF[01]:CFATURA := alltrim(::WSSOLCANCFAT:_eSolCanc[01]:cFATURA)
				::WSRETCANCFAT:_eRetCancF[01]:CMSGRET := _cMensRet
			
			Else
	
				// Coletando informações.
	 			for _nIt := 1 to Len( ::WSSOLCANCFAT:_eSolCanc )
	 			
					// Verificando Identificador do cadastro
					_cCnpj 		:= Alltrim(::WSSOLCANCFAT:_eSolCanc[_nIt]:CIDCGC)
					_cCPF       := Alltrim(::WSSOLCANCFAT:_eSolCanc[_nIt]:CIDCPF)
					_cFatura 	:= Alltrim(::WSSOLCANCFAT:_eSolCanc[_nIt]:CFATURA)
					_cParcela	:= Alltrim(::WSSOLCANCFAT:_eSolCanc[_nIt]:CPARCELA)
					_cAprovCanc := Alltrim(::WSSOLCANCFAT:_eSolCanc[_nIt]:CUSRLOG)
					 
					_cVldCgcCpf := if (Empty(_cCnpj),_cCPF, _cCnpj)
					
					lMsErroAuto := .T.
					_lGerarMov  := .t.
					_lLibNF     := .t.
					_lPrz24     := .f.
					_cForn 	    := _cLojF := ''
					
					// Caso diferente logar noutra empresa/filial
			 		if _cCnpjEmit#Alltrim(::WSSOLCANCFAT:_eSolCanc[01]:CCNPJ_EMIT)	
			 			
		 				_cCnpjEmit := Alltrim(::WSSOLCANCFAT:_eSolCanc[01]:CCNPJ_EMIT)	
		 				_nPos 	   := ascan(_aEmpresas,{|x| Alltrim(x[03]) == _cCnpjEmit})
			 				
			 			if _nPos>0
			 				
		 					_cEmp 	   := _aEmpresas[_nPos][01]
		 					_cFil 	   := _aEmpresas[_nPos][02]
		 					 
		 			 		// Limpa ambiente atual Abrindo próximo
		 			 		RpcClearEnv()
							RpcSetType(3)
							WFprepenv(_cEmp, _cFil)
							
							// Coleta informações da filial, unid neg, grupo etc.
							_aInfoFil := FWArrFilAtu(_cEmp, _cFil)
		
							// Grupo Empresa e Un Neg.
							_cGrpEmp := _aInfoFil[03]
							_cUnNeg  := _aInfoFil[04]
								
						Else
							
							// Sai do Loop erro de empresa
							_cMensRet := 'Error 900 - Empresa Emitente não existe no cadsatro Empresas do ERP Totvs.'
								 
						Endif
							
					Endif
	 			
					// Padronizar tamanho campos
					_nTamC 		:= TAMSX3("RA_CIC")[1]
					_nTamF 		:= TAMSX3("A2_CGC")[1]
					_nTamFt		:= TAMSX3("Z3_FATURA")[1] 
					_nTamPa		:= TAMSX3("Z3_PARCELA")[1]
					_nTamPF     := TAMSX3("E1_PARCELA")[1]
					_nTamNF		:= TAMSX3("F2_DOC")[1] 
					_nTamSE		:= TAMSX3("F2_SERIE")[1]
					_nHorasPrz 	:= GetNewPar("MV_SPEDEXC",24)
								 
					// Validando Cnpj ou CPF
					if CGC(_cVldCgcCpf).and. empty(_cMensRet)
						
						// Verifica se o cliente existe
						DbSelectArea("SA1")
		     			DbSetOrder(3)
		     			lMsErroAuto := .T.
		     			_cMensRet 	:= 'Error – 007 - Cadastro de cliente não localizado ou bloqueado para utilização.'
		     
		     			If DbSeek( FwxFilial("SA1") + Padr(_cVldCgcCpf,_nTamC))  
								
							// Verifica se encontrado e não esta com bloqueio
							if SA1->A1_MSBLQL <> '1'
								
								_cMensRet  := ' '
								_lGerarMov := .t.
								
							Else
							
								_lGerarMov  := .F.
						 
							Endif
							
						Endif
						
						// Verificando Fornededor
						_cMensRet := 'Error – 007 - Cadastro de fornecedor não localizado ou bloqueado para utilização.'
						dbSelectArea("SA2")
						SA2->( dbSetOrder(3) )
						
						If SA2->( DbSeek( FwxFilial("SA2") + Padr(_cVldCgcCpf,_nTamC) ) )
						
							// Verifica se encontrado e não esta com bloqueio
							if SA2->A2_MSBLQL <> '1'
								
								_cMensRet  := ' '
								_lGerarMov := .t.
								_cForn 	   := SA2->A2_COD
								_cLojF     := SA2->A2_LOJA 
								
							Else
							
								_lGerarMov  := .F.
						 
							Endif
							
						Endif
						
						// Se de acordo validações gerar o registro.
						if _lGerarMov
							
							// Verificando se registro já foi incluído. --> Z0_FILIAL+Z0_FATURA+Z0_PARCELA 
							dbSelectArea("SZ0")
							SZ0->( dbSetOrder(1) )
							
							if SZ0->( DbSeek( FwxFilial("SZ0") + Padr(_cFatura,_nTamFt) + Padr(_cParcela,_nTamPa) ) ).and.;
							   Empty(SZ0->Z0_DTCANC) 
							
								dbselectarea("SF2")
								dbsetorder(3)
								
								_cNF := Alltrim(SZ0->Z0_NFFAT)
								_cSer:= Alltrim(SZ0->Z0_SERIENF)
								
								_lLibNF := dbseek(FwxFilial("SF2") + Padr(_cNF,_nTamFt) + Padr(_cSer,_nTamFt) )
								
								// Localiza a NF(caso emitida) e verifica prazo para cancelamento !
								if _lLibNF  
	
									_nHoras := SubtHoras(IIF(SF2->(FieldPos("F2_DAUTNFE")) <> 0 .And.;
											  !Empty(SF2->F2_DAUTNFE),SF2->F2_DAUTNFE,dDtdigit),;
											  IIF(SF2->(FieldPos("F2_HAUTNFE")) <> 0 .And. ;
											  !Empty(SF2->F2_HAUTNFE),SF2->F2_HAUTNFE,SF2->F2_HORA),dDataBase,;
											  substr(Time(),1,2)+":"+substr(Time(),4,2) )
											  
									if _nHoras > _nHorasPrz .and. _nHoras <= 480 
									
										_lPrz24 := .t.
									
										// Sem aprovador, não possibilitar cancelamento
										if empty(_cAprovCanc)
									
											_lGerarMov := .f.
											_cMensRet  := 'Error – 003 – Cancelamento não permitido, s/ Autorizador.'
											
										Endif
									
									Endif
									
									if  _nHoras > 480 
									
										_lGerarMov := .f.
										_cMensRet  := 'Error – 004 – Cancelamento não permitido, prazo superior a 480 horas.'
									
									Endif
									
									// Verificando período contábil
									if !CtbValiDt( ,SF2->F2_EMISSAO,,,,{"FIN001","FIN002"},)
										
										_cMensRet := 'Error – 002 – Cancelamento não permitido, período contábil fechado.'
										_lGerarMov:= .F.
										
									Else
									
										// Verificando se existe título baixado 
										//Posiciona nos titulos a receber e pega vencimento/parcela e valor
										dbSelectArea("SE1")
										dbSetOrder(1)
										if dbSeek( FwxFilial("SE1")+ SF2->F2_SERIE + SF2->F2_DOC + Padr(_cParcela,_nTamPF) )
									 
											//_aBaixas := Baixas(SE1->E1_NATUREZ,SE1->E1_PREFIXO,SE1->E1_NUM,SE1->E1_PARCELA,SE1->E1_TIPO,;
											//			     1,"R",SE1->E1_CLIENTE,dDataBase,SE1->E1_LOJA)
													
											if SE1->E1_VALOR <> SE1->E1_SALDO
									
												_cMensRet := 'Error – 001 – Cancelamento não permitido, títulos baixados.'
												_lGerarMov:= .F.
											
											Endif
											
										Endif
									
									Endif
									
								Endif
								
								// Autorizado Cancelamento
								if _lGerarMov
								
									// Gerando multa, caso prazo passou de 24 hs e menor de 480
									// Mensagens de retorno
									lMsErroAuto := .F.
									if !_lPrz24
									
										_cMensRet := 'OK – 001 – Cancelamento dentro do Prazo'
										
									Else	
									
										_cMensRet := 'OK – 002 – Cancelamento fora do Prazo c/ Multa Autorizado.'
										
										// Gerar título da Multa.
										_aTitMulta := {}
										_nVlrMulta := Round((SE1->E1_SALDO * 1.5)/100,2)
										
										AaDd( _aTitMulta, {"E2_FILIAL" , FwxFilial("SE2") ,Nil})
								     	AaDd( _aTitMulta, {"E2_PREFIXO", SE1->E1_PREFIXO  ,Nil})
								    	AaDd( _aTitMulta, {"E2_NUM"    , SE1->E1_NUM      ,Nil})
								     	AaDd( _aTitMulta, {"E2_PARCELA", SE1->E1_PARCELA  ,Nil})
								     	AaDd( _aTitMulta, {"E2_TIPO"   , "PR"     		  ,Nil})
								     	AaDd( _aTitMulta, {"E2_FORNECE", _cForn 		  ,Nil})
								     	AaDd( _aTitMulta, {"E2_LOJA   ", _cLojF     	  ,Nil})
								     	AaDd( _aTitMulta, {"E2_EMISSAO", ddatabase 		  ,Nil})
								     	AaDd( _aTitMulta, {"E2_VENCTO" , ddatabase 		  ,Nil})
								     	AaDd( _aTitMulta, {"E2_VALOR"  , _nVlrMulta  	  ,Nil})
								     	AaDd( _aTitMulta, {"E2_HIST"   , "Pagto.Multa por Cancelameto NF." ,Nil})
	        							AaDd( _aTitMulta, {"E2_NATUREZ", SE1->E1_NATUREZ  ,Nil})
	        							
	     								
	     								//3-Inclusao //5-Exclusao
	    								MSExecAuto({|x,y| Fina050(x,y)}, _aTitMulta, 3) 
	    								
	    								//Ocorrendo erro de autoexecução.
									    If lMsErroAuto
									    	
									 		// Recuperando a linha do erro
											_cMensErro := MemoRead(NomeAutoLog())    
										
											// Recupera o erro
											_cMensRet := 'Ocorreu um erro na tentativa de inclusão de Título Multa: ' + _cEol + _cMensErro  
										 
									    EndIf
										
									Endif
									
									if !lMsErroAuto
								
										// Gravando cancelamento na tabela Middle de FaturasCancela registro, efetuando retorno
										RecLock('SZ0', .F.)
										
											SZ0->Z0_CANC   := ::WSSOLCANCFAT:_eSolCanc[01]:CCANC 
											SZ0->Z0_DTCANC := ctod(::WSSOLCANCFAT:_eSolCanc[01]:DCANC)
											SZ0->Z0_HRCANC := ::WSSOLCANCFAT:_eSolCanc[01]:CHRCANC
											SZ0->Z0_USRCANC:= ::WSSOLCANCFAT:_eSolCanc[01]:CUSRLOG
											SZ0->Z0_PROCESS:= "N" 
											
										MsUnLock()
								
										lMsErroAuto := .F.
										
									Endif
									
								Endif
	 				 
	 						Else
	 						
	 							if Empty(SZ0->Z0_DTCANC) 
							
									_cMensRet := 'Error 005 - Registro de fatura não encontrado.' 
									
								Else
								
									_cMensRet := 'Error 008 - Registro de fatura já cancelado.' 
								
								Endif
							
							Endif
							
						Endif
								
					ElseIf empty(_cMensRet)
				
						_cMensRet := 'Error 006 - Cnpj/Cpf Invalido.'  
							 
					Endif
					
					// Se for o primeiro, somente edita
			     	if Empty(::WSRETCANCFAT:_eRetCancF[01]:CMSGRET)  
			     					
			     		// Grava mensagem de retorno
						::WSRETCANCFAT:_eRetCancF[01]:CMSGRET  := _cMensRet
						::WSRETCANCFAT:_eRetCancF[01]:CRETORNO := cValToChar(!lMsErroAuto)
										
			     	Else
			     	
			     		// Cria e alimenta uma nova instancia do Retorno
		  				oRetSol :=  WSClassNew("_aRetCancF")
		  							
						oRetSol:CCHAVE  := Alltrim(::WSSOLCANCFAT:_eSolCanc[01]:cFATURA)+'-'+Alltrim(::WSSOLCANCFAT:_eSolCanc[_nIt]:CPARCELA)
					    oRetSol:CFATURA := Alltrim(::WSSOLCANCFAT:_eSolCanc[01]:cFATURA) 
					    oRetSol:CMSGRET := _cMensRet
					    oRetSol:CRETORNO:= cValToChar(!lMsErroAuto)
					    
		  				AAdd( ::WSRETCANCFAT:_eRetCancF, oRetSol )
			     					  
					Endif
						
				Next 
				
			Endif
			
			//Reseta ambientes  
			//RpcClearEnv()
			
		Else
		
			_cMensRet := 'Error 900 - Empresa Emitente não existe no cadsatro Empresas do ERP Totvs.'
			::WSRETCANCFAT:_eRetCancF[01]:CMSGRET := _cMensRet
			
		Endif 
		
	Else
	
		_cMensRet := 'Error 998 - Erro na estrutura de dados da solicitação.'
		::WSRETCANCFAT:_eRetCancF[01]:CMSGRET := _cMensRet
		
	
	Endif
	
End Sequence
	
ErrorBlock(_oError)

if !empty(_cErroFont)
	::WSRETCANCFAT:_eRetCancF[01]:CMSGRET := 'Descr.Erro Proc.: ' + _cLinErro + '|' +  _cErroFont
Endif	

Return .T.

