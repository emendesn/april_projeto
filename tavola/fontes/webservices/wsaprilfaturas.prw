#include "apwebsrv.ch"
#include "totvs.ch"
#include "fileio.ch"
#include 'protheus.ch'
#include "xmlxfun.ch"
#include "topconn.ch"
#include "rwmake.ch"
#include "tbiconn.ch"
#include "error.ch" 
#include "fwcommand.ch"


/*/{Protheus.doc} WsAprilFaturas

WSDL com métodos a serem consumidos pela aplicação TAVOLA 
da empresa  APRIL BRASIL TURISMO VIAGENS E ASSISTENCIA INTERNACIONAL LTDA, 
com o objetivo de alimentar a tabela Ponte Customizada SZ0  para geração de Faturas.
 
@type 	Fonte WSDL
@author Ivan de Oliveira - TNU
@since 	04/05/2017 
 /*/
 
 // Inicio Definição Requisições - Inclusão //STRING, DATE, INTEGER, FLOAT, BOOLEAN, BASE64Binary
WsStruct _aSolFat

	Wsdata CCHAVE		 As String
	Wsdata CIDCLIENT	 As String
	Wsdata CFATURA		 As String
	Wsdata CTPMOD		 As String
	Wsdata CTPFAT		 As String
	Wsdata CBDVPAI		 As String
	Wsdata CNUM    		 As String
	Wsdata CCLIENTE		 As String
	Wsdata CLOJACLI		 As String
	Wsdata CIDCGC		 As String
	Wsdata CIDCPF		 As String
	Wsdata CPARCELA		 As String
	Wsdata CDTVEN		 As String
	Wsdata CEMISSAO		 As String
	Wsdata NPREMIO		 As Float
	Wsdata NVLRTO		 As Float
	Wsdata NIOF			 As Float
	Wsdata CCANC		 As String
	Wsdata DCANC		 As String
	Wsdata CHRCANC		 As String
	Wsdata CUSRLOG		 As String
	Wsdata CNFFAT		 As String
	Wsdata CSERIRNF		 As String
	Wsdata CEMISNF		 As String
	Wsdata CCNPJ_EMIT	 As String
	Wsdata CVEND1		 As String
	Wsdata NCOMIS1		 As Float 
	Wsdata CVEND2		 As String
	Wsdata NCOMIS2		 As Float 
	Wsdata CVEND3		 As String
	Wsdata NCOMIS3		 As Float 
	Wsdata CVEND4		 As String
	Wsdata NCOMIS4		 As Float 
	Wsdata CVEND5		 As String
	Wsdata NCOMIS5		 As Float 
	Wsdata CVEND6		 As String
	Wsdata NCOMIS6 		 As Float 	
	Wsdata CVEND7	 	 As String	
	Wsdata NCOMIS7		 As Float 
	Wsdata CVEND8		 As String
	Wsdata NCOMIS8		 As Float 
	Wsdata CVEND9		 As String
	Wsdata NCOMIS9		 As Float 
	Wsdata NCARTCRED	 As Float
	Wsdata NDSR     	 As Float
	
EndWsstruct

WsStruct EstrSolFat

  Wsdata _eSolFat As Array of _aSolFat

EndwSstruct

//  Definição Requisições - Consulta
WsStruct _aSolConsFat

	Wsdata CCHAVE		As String
	Wsdata CFATURA		As String
	Wsdata CCNPJ_EMIT 	As String
	
EndwSstruct

WsStruct EstrConsFat

  Wsdata _eSolConsFat As Array of _aSolConsFat

EndwSstruct
 
// Final Definição Requisições

//.............................................................
// Inicio Definição da estrutura Dados Retorno - Inclusão

WsStruct _aRetSolFat
	
	Wsdata CCHAVE	 AS String 
	Wsdata CFATURA	 AS String 
	Wsdata CMSGRET	 As String
	Wsdata CRETORNO	 As String
 
EndWsstruct
 
WsStruct EstrRetIFat
         
	Wsdata _eRetSolFat As Array of _aRetSolFat
 
EndWsstruct

//.............................................................
// Inicio Definição da estrutura Dados Retorno - Consulta
 
WsStruct _aRetConsFat
	
	Wsdata CCHAVE	 	AS String 
	Wsdata CIDCLIENT 	AS String 
	Wsdata CFATURA		AS String 
	Wsdata CTPMOD		AS String 
	Wsdata CTPFAT		AS String 
	Wsdata CBDVPAI		As String
	Wsdata CNUM   		AS String  
	Wsdata CCLIENTE		AS String 
	Wsdata CLOJACLI		AS String 
	Wsdata CIDCGC		AS String 
	Wsdata CIDCPF		AS String 
	Wsdata CPARCELA		AS String 
	Wsdata CDTVEN		AS String 
	Wsdata CEMISSAO		AS String 
	Wsdata NPREMIO		As Float
	Wsdata NVLRTO		As Float
	Wsdata NIOF			As Float 
	Wsdata CCANC		AS String 
	Wsdata DCANC		AS String 
	Wsdata CHRCANC		AS String 
	Wsdata CUSRLOG		AS String 
	Wsdata CNFFAT		AS String 
	Wsdata CSERIRNF		AS String 
	Wsdata CEMISNF		AS String 
	Wsdata CVEND1		 As String
	Wsdata NCOMIS1		 As Float 
	Wsdata CVEND2		 As String
	Wsdata NCOMIS2		 As Float 
	Wsdata CVEND3		 As String
	Wsdata NCOMIS3		 As Float 
	Wsdata CVEND4		 As String
	Wsdata NCOMIS4		 As Float 
	Wsdata CVEND5		 As String
	Wsdata NCOMIS5		 As Float 
	Wsdata CVEND6		 As String
	Wsdata NCOMIS6 		 As Float 	
	Wsdata CVEND7	 	 As String	
	Wsdata NCOMIS7		 As Float 
	Wsdata CVEND8		 As String
	Wsdata NCOMIS8		 As Float 
	Wsdata CVEND9		 As String
	Wsdata NCOMIS9		 As Float 
	Wsdata CMSGRET		 AS String 
	Wsdata CRETORNO		 AS String 
	
EndWsstruct

WsStruct EstrRetCFat

	Wsdata _eRetConsFat As Array of _aRetConsFat

EndWsstruct
// Final Definição Retorno
 
WSSERVICE WsAprilFaturas DESCRIPTION "Serviço destinado Inclusão de dados no MIDDLEWARE como ponte para emissão Comissão e Prêmio entre Tavola x Protheus"
 
	Wsdata WSSOLINCFAT 	As EstrSolFat
	Wsdata WSRETINCFAT	As EstrRetIFat
	
	Wsdata WSSOLCONSFAT As EstrConsFat
	Wsdata WSRETCONSFAT	As EstrRetCFat
	
	//  Métodos //
	WsMethod PedIncluir Description "Inclusão de dados no MIDDLEWARE para posterior alimentar Pedido de Vendas - específico: Távola x Protheus"
	WsMethod PedCons 	Description "Consulta de dados no MIDDLEWARE para recuperar dados processados no Protheus."
	 
EndWsservice

/* {Protheus.doc} PedIncluir
Método de WebService para inclusão tabela no MIDDLEWARE ( Faturas - SZ0 )
@type 		Método Fonte WSDL
@author 	Ivan de Oliveira
@since 		04/05/2017 
@version 	1.0
@return 	${Lógico}, ${.t.}
 */
 
WSMETHOD PedIncluir WSRECEIVE WSSOLINCFAT WSSEND WSRETINCFAT WSSERVICE WsAprilFaturas

Local _cEmp 	:= _cFil := _cGrpEmp := _cUnNeg := ''
Local _aEmpresas:= {}
Local _cUnN     := ''
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
	::WSRETINCFAT:_eRetSolFat := Array(1)
		 									 
	::WSRETINCFAT:_eRetSolFat[01]:= WSClassNew("_aRetSolFat")
	::WSRETINCFAT:_eRetSolFat[01]:CCHAVE   := 'Erro Estrutural'   
	::WSRETINCFAT:_eRetSolFat[01]:CFATURA  := ' '
	::WSRETINCFAT:_eRetSolFat[01]:CMSGRET  := ' '
	::WSRETINCFAT:_eRetSolFat[01]:CRETORNO := '.F.'
	
	//Verificando se a entrada dados e uma estrutura
	if valtype(::WSSOLINCFAT:_eSolFat) == 'A' .and. !Empty(::WSSOLINCFAT:_eSolFat)
	
		// Verificando se o CNPJ emitente existe
		_cCnpjEmit := Alltrim(::WSSOLINCFAT:_eSolFat[01]:cCnpj_emit)	
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
			if Alltrim(SuperGetmv('AP_AUTWS', .T., 'April@2017' )) <> Alltrim(Decode64(::WSSOLINCFAT:_eSolFat[01]:CCHAVE ))
	
				_cMensRet := 'Error 999 - Token Invalido. Obtenha e Informe um Novo Token.'
				::WSRETINCFAT:_eRetSolFat[01]:CCHAVE  := ::WSSOLINCFAT:_eSolFat[01]:CCHAVE
				::WSRETINCFAT:_eRetSolFat[01]:CFATURA := ::WSSOLINCFAT:_eSolFat[01]:CFATURA 
				::WSRETINCFAT:_eRetSolFat[01]:CMSGRET := _cMensRet
		
			Else
		
				// Coletando informações.
	 			for _nIt := 1 to Len( ::WSSOLINCFAT:_eSolFat )
	 			
					// Verificando Identificador do cadastro
					_cTpFat		:= Alltrim(::WSSOLINCFAT:_eSolFat[_nIt]:CTPFAT)
					_cModFat    := Alltrim(::WSSOLINCFAT:_eSolFat[_nIt]:CTPMOD)
					_cCnpj 		:= Alltrim(::WSSOLINCFAT:_eSolFat[_nIt]:CIDCGC)
					_cCPF       := Alltrim(::WSSOLINCFAT:_eSolFat[_nIt]:CIDCPF)
					_cFatura 	:= Alltrim(::WSSOLINCFAT:_eSolFat[_nIt]:CFATURA)
					_cParcela	:= Alltrim(::WSSOLINCFAT:_eSolFat[_nIt]:CPARCELA)
					_cCodProd   := Alltrim(::WSSOLINCFAT:_eSolFat[_nIt]:CTPFAT)
					_cChave     := Alltrim(::WSSOLINCFAT:_eSolFat[_nIt]:CFATURA) + '-' + Alltrim(::WSSOLINCFAT:_eSolFat[_nIt]:CPARCELA)
					_cVldCgcCpf := if (Empty(_cCnpj),_cCPF, _cCnpj)
					
					// Caso diferente logar noutra empresa/filial
			 		if _cCnpjEmit#Alltrim(::WSSOLINCFAT:_eSolFat[_nIt]:cCnpj_emit)
			 			
		 				_cCnpjEmit := Alltrim(::WSSOLINCFAT:_eSolFat[_nIt]:cCnpj_emit)
		 				_nPos      := ascan(_aEmpresas,{|x| Alltrim(x[03]) == _cCnpjEmit})
			 				
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
					_nTamC := TAMSX3("A1_CGC")[1]
					_nTamP := TAMSX3("B1_COD")[1]
					_nTamFt:= TAMSX3("Z0_FATURA")[1] 
					_nTamPa:= TAMSX3("Z0_PARCELA")[1]
					_nTamTF:= TamSx3("Z2_TPFAT")[1]
				 	_nTamM := TamSx3("Z2_TPMOD")[1]
					
					lMsErroAuto := .T.
					_lGerarMov  := .f.
					
					// Validando Cnpj ou CPF
					if CGC(_cVldCgcCpf).and. empty(_cMensRet)
						
						// Verifica se o cliente existe
						DbSelectArea("SA1")
		     			DbSetOrder(3)
		     			lMsErroAuto := .T.
		     			_cMensRet 	:= 'Error – 001 - Código de cliente não localizado ou bloqueado para utilização.'
		     			_cChave   	:= _cVldCgcCpf
		     
		     			If DbSeek( FwxFilial("SA1") + Padr(_cVldCgcCpf,_nTamC))  
								
							// Verifica se encontrado e não esta com bloqueio
							if SA1->A1_MSBLQL <> '1'
							
								//_cMensRet := 'Error – 002 - Código de produto não localizado ou bloqueado para utilização.'
								
								//Verificando CADASTRO DE DIRECIONAMENTO Z2_FILIAL+Z2_TPFAT+Z2_TPMOD
								dbSelectArea("SZ2")
								SZ2->(DbSetOrder(1))
								if Dbseek( FwxFilial("SZ2") + Padr(_cTpFat,_nTamTF)  + Padr(_cModFat,_nTamM) ) 
								
									_cCodProd := SZ2->Z2_PRODUTO
								 
									dbSelectArea("SB1") 
									SB1->(DbSetOrder(1))  
						
									_cMensRet := 'Error – 002 - Código de produto não localizado ou bloqueado para utilização.'
									_cChave   := _cCodProd
									if Dbseek( FwxFilial("SB1") + Padr(_cCodProd,_nTamP) ) 
						
										// Verifica se encontrado e não esta com bloqueio
										if SB1->B1_MSBLQL <> '1'
										
											_cMensRet  := ''
											 
											// Verificando numerações de fatura
											if empty(_cFatura)
								
							 					_cMensRet := 'Error – 006 - Número de Fatura inválido.'
												_cChave := Alltrim(::WSSOLINCFAT:_eSolFat[_nIt]:CFATURA) + '-' + Alltrim(::WSSOLINCFAT:_eSolFat[_nIt]:CPARCELA)
							
						 	
											Elseif empty(_cParcela)
							
												_cMensRet := 'Error – 007 - Número de Parcela inválido.'
												_cChave := Alltrim(::WSSOLINCFAT:_eSolFat[_nIt]:CFATURA) + '-' + Alltrim(::WSSOLINCFAT:_eSolFat[_nIt]:CPARCELA)
												
											Else
							
												_lGerarMov := .T.
							
											Endif
								
										Endif
										
									Endif
									
								Endif
								
							Endif
								
						Endif
						
						// Se de acordo validações gerar o registro.
						if _lGerarMov
						
							_cChave := Alltrim(::WSSOLINCFAT:_eSolFat[_nIt]:CFATURA) + '-' + Alltrim(::WSSOLINCFAT:_eSolFat[_nIt]:CPARCELA)
							
							// Verificando se registro já foi incluído. --> Z0_FILIAL+Z0_FATURA+Z0_PARCELA 
							dbSelectArea("SZ0")
							SZ0->( dbSetOrder(1) )
							
							if !SZ0->( DbSeek( FwxFilial("SZ0") + Padr(_cFatura,_nTamFt) + Padr(_cParcela,_nTamPa) ) )
								
								if Reclock("SZ0", .T.)
								 
								 	SZ0->Z0_FILIAL  := _cFil
									SZ0->Z0_FATURA  := Padr(_cFatura,_nTamFt)
									SZ0->Z0_IDCLI	:= SA1->A1_XIDTAVC
									SZ0->Z0_TPMOD	:= ::WSSOLINCFAT:_eSolFat[_nIt]:CTPMOD
									SZ0->Z0_TPFAT	:= ::WSSOLINCFAT:_eSolFat[_nIt]:CTPFAT
									SZ0->Z0_NUM   	:= ::WSSOLINCFAT:_eSolFat[_nIt]:CNUM
									SZ0->Z0_BDVPAI	:= ::WSSOLINCFAT:_eSolFat[_nIt]:CBDVPAI
									SZ0->Z0_CLIENTE	:= SA1->A1_COD
									SZ0->Z0_LOJACLI	:= SA1->A1_LOJA
									SZ0->Z0_IDCGC	:= ::WSSOLINCFAT:_eSolFat[_nIt]:CIDCGC
									SZ0->Z0_IDCPF	:= ::WSSOLINCFAT:_eSolFat[_nIt]:CIDCPF
									SZ0->Z0_PARCELA	:= Padr(_cParcela,_nTamPa)
									SZ0->Z0_DTVEN	:= ctod(::WSSOLINCFAT:_eSolFat[_nIt]:CDTVEN)
									SZ0->Z0_EMISSAO	:= ctod(::WSSOLINCFAT:_eSolFat[_nIt]:CEMISSAO)
									SZ0->Z0_VLRPREM	:= ::WSSOLINCFAT:_eSolFat[_nIt]:NPREMIO
									SZ0->Z0_VLRTO	:= ::WSSOLINCFAT:_eSolFat[_nIt]:NVLRTO
									SZ0->Z0_IOF		:= ::WSSOLINCFAT:_eSolFat[_nIt]:NIOF
									SZ0->Z0_VEND1  	:= ::WSSOLINCFAT:_eSolFat[_nIt]:CVEND1		 
									SZ0->Z0_COMIS1 	:= ::WSSOLINCFAT:_eSolFat[_nIt]:NCOMIS1		  
									SZ0->Z0_VEND2  	:= ::WSSOLINCFAT:_eSolFat[_nIt]:CVEND2		 
									SZ0->Z0_COMIS2 	:= ::WSSOLINCFAT:_eSolFat[_nIt]:NCOMIS2		 
									SZ0->Z0_VEND3  	:= ::WSSOLINCFAT:_eSolFat[_nIt]:CVEND3		  
									SZ0->Z0_COMIS3 	:= ::WSSOLINCFAT:_eSolFat[_nIt]:NCOMIS3		 
									SZ0->Z0_VEND4  	:= ::WSSOLINCFAT:_eSolFat[_nIt]:CVEND4		  
									SZ0->Z0_COMIS4 	:= ::WSSOLINCFAT:_eSolFat[_nIt]:NCOMIS4		  
									SZ0->Z0_VEND5  	:= ::WSSOLINCFAT:_eSolFat[_nIt]:CVEND5		  
									SZ0->Z0_COMIS5 	:= ::WSSOLINCFAT:_eSolFat[_nIt]:NCOMIS5		  
									SZ0->Z0_VEND6  	:= ::WSSOLINCFAT:_eSolFat[_nIt]:CVEND6		  
									SZ0->Z0_COMIS6 	:= ::WSSOLINCFAT:_eSolFat[_nIt]:NCOMIS6 		  	
									SZ0->Z0_VEND7  	:= ::WSSOLINCFAT:_eSolFat[_nIt]:CVEND7	 	  
									SZ0->Z0_COMIS7 	:= ::WSSOLINCFAT:_eSolFat[_nIt]:NCOMIS7		  
									SZ0->Z0_VEND8  	:= ::WSSOLINCFAT:_eSolFat[_nIt]:CVEND8		  
									SZ0->Z0_COMIS8 	:= ::WSSOLINCFAT:_eSolFat[_nIt]:NCOMIS8		  
									SZ0->Z0_VEND9  	:= ::WSSOLINCFAT:_eSolFat[_nIt]:CVEND9		 
									SZ0->Z0_COMIS9 	:= ::WSSOLINCFAT:_eSolFat[_nIt]:NCOMIS9
									SZ0->Z0_CARTCRE := ::WSSOLINCFAT:_eSolFat[_nIt]:NCARTCRED	  
									SZ0->Z0_DSR     := ::WSSOLINCFAT:_eSolFat[_nIt]:NDSR
									SZ0->Z0_PROCESS :=  'N'
									SZ0->Z0_GRPEMP  := _cGrpEmp
									SZ0->Z0_FILEMIS	:= _cFil
									SZ0->Z0_EMPEMIS	:= _cEmp
									SZ0->Z0_UNDNEG 	:= _cUnNeg
							 
									//SZ0->Z0_CANC	 := 
									//SZ0->Z0_DTCANC :=
									//SZ0->Z0_HRCANC :=
									//SZ0->Z0_USRCANC:=
									//SZ0->Z0_NFFAT	 :=
									//SZ0->Z0_SERIRNF:=
									//SZ0->Z0_EMISNF :=
									
		 							Msunlock()
								 
									// Retorno do processo.
	 								_cMensRet   := 'Ok – 001 – Processo registrado com Sucesso.'
									lMsErroAuto := .F.
									
								Else
	 									
	 								_cMensRet := 'Error 005 - Ocorreu um erro na tentativa de bloqueio registro tabela SZ0(Erp-Totvs).' 
	 								
	 							Endif
	 				 
	 						Else
							
								_cMensRet := 'Error 003 - Registro já incluido.' 
							
							Endif
							
						Endif
								
					Elseif empty(_cMensRet)
				
						_cMensRet := 'Error 004 - Cnpj/Cpf Invalido.'  
						_cChave   := _cVldCgcCpf
							 
					Endif
						
					// Completando itens do retorno.
			 		if Empty(::WSRETINCFAT:_eRetSolFat[01]:CMSGRET)  
			     					
			     		// Grava mensagem de retorno
						::WSRETINCFAT:_eRetSolFat[01]:CCHAVE  := _cChave
						::WSRETINCFAT:_eRetSolFat[01]:CFATURA := Alltrim(::WSSOLINCFAT:_eSolFat[_nIt]:CFATURA)
						::WSRETINCFAT:_eRetSolFat[01]:CMSGRET := _cMensRet
						::WSRETINCFAT:_eRetSolFat[01]:CRETORNO:= cValToChar(!lMsErroAuto)
						
					Else
			     					
		     			// Cria e alimenta uma nova instancia do Retorno
		  				oRetSol :=  WSClassNew("_aRetComPre")
		  							
		  				oRetSol:CCHAVE  := _cChave  
						oRetSol:CFATURA := Alltrim(::WSSOLINCFAT:_eSolFat[_nIt]:CFATURA) 
						oRetSol:CMSGRET := _cMensRet
						oRetSol:CRETORNO:= cValToChar(!lMsErroAuto)
		  							 
	  					AAdd( ::WSRETINCFAT:_eRetSolFat, oRetSol )
	  					
	  				Endif
			 		
				Next 
				
			Endif
				
			//Reseta ambientes 
			//RpcClearEnv() 
				
		Else
		
			_cMensRet := 'Error 900 - Empresa Emitente não existe no cadsatro Empresas do ERP Totvs.'
			::WSRETINCFAT:_eRetSolFat[01]:CCHAVE  := _cCnpjEmit
			::WSRETINCFAT:_eRetSolFat[01]:CMSGRET := _cMensRet
			
		Endif 
		
	Else
	
		_cMensRet := 'Error 998 - Erro na estrutura de dados da solicitação.'
		::WSRETINCFAT:_eRetSolFat[01]:CMSGRET := _cMensRet
	
	Endif
 
End Sequence

ErrorBlock(_oError)

if !empty(_cErroFont)
	::WSRETINCFAT:_eRetSolFat[01]:CMSGRET := 'Descr.Erro Proc.: ' + _cLinErro + '|' +  _cErroFont
Endif

Return .T.

 /*
 {Protheus.doc} PedCons
Método de WebService para consultar tabela no MIDDLEWARE ( Faturas - SZ0 )
@type 		Método Fonte WSDL
@author 	Ivan de Oliveira
@since 		04/05/2017 
@version 	1.0
@return 	${Lógico}, ${.t.}
*/  
 
WSMETHOD PedCons WSRECEIVE WSSOLCONSFAT WSSEND WSRETCONSFAT WSSERVICE WsAprilFaturas

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
	::WSRETCONSFAT:_eRetConsFat := Array(1)
		 
	::WSRETCONSFAT:_eRetConsFat[01]:= WSClassNew("_aRetConsFat")
	::WSRETCONSFAT:_eRetConsFat[01]:CCHAVE	 	:= 'Erro Estrutural'   
	::WSRETCONSFAT:_eRetConsFat[01]:CIDCLIENT 	:= ' ' 
	::WSRETCONSFAT:_eRetConsFat[01]:CFATURA		:= ' ' 
	::WSRETCONSFAT:_eRetConsFat[01]:CTPMOD		:= ' ' 
	::WSRETCONSFAT:_eRetConsFat[01]:CTPFAT		:= ' ' 
	::WSRETCONSFAT:_eRetConsFat[01]:CNUM   		:= ' '
	::WSRETCONSFAT:_eRetConsFat[01]:CBDVPAI		:= ' '  
	::WSRETCONSFAT:_eRetConsFat[01]:CCLIENTE	:= ' '
	::WSRETCONSFAT:_eRetConsFat[01]:CLOJACLI	:= ' ' 
	::WSRETCONSFAT:_eRetConsFat[01]:CIDCGC		:= ' ' 
	::WSRETCONSFAT:_eRetConsFat[01]:CIDCPF		:= ' ' 
	::WSRETCONSFAT:_eRetConsFat[01]:CPARCELA	:= ' '
	::WSRETCONSFAT:_eRetConsFat[01]:CDTVEN		:= ' ' 
	::WSRETCONSFAT:_eRetConsFat[01]:CEMISSAO	:= ' '
	::WSRETCONSFAT:_eRetConsFat[01]:NPREMIO		:= 0.00
	::WSRETCONSFAT:_eRetConsFat[01]:NVLRTO		:= 0.00
	::WSRETCONSFAT:_eRetConsFat[01]:NIOF		:= 0.00
 	::WSRETCONSFAT:_eRetConsFat[01]:CCANC		:= ' ' 
	::WSRETCONSFAT:_eRetConsFat[01]:DCANC		:= ' ' 
	::WSRETCONSFAT:_eRetConsFat[01]:CHRCANC		:= ' ' 
	::WSRETCONSFAT:_eRetConsFat[01]:CUSRLOG		:= ' ' 
	::WSRETCONSFAT:_eRetConsFat[01]:CNFFAT		:= ' ' 
	::WSRETCONSFAT:_eRetConsFat[01]:CSERIRNF	:= ' '
	::WSRETCONSFAT:_eRetConsFat[01]:CEMISNF		:= ' ' 
	::WSRETCONSFAT:_eRetConsFat[01]:CMSGRET		:= ' ' 
	::WSRETCONSFAT:_eRetConsFat[01]:CVEND1		:= ' ' 
	::WSRETCONSFAT:_eRetConsFat[01]:NCOMIS1		:= 0.00
	::WSRETCONSFAT:_eRetConsFat[01]:CVEND2		:= ' ' 
	::WSRETCONSFAT:_eRetConsFat[01]:NCOMIS2		:= 0.00
	::WSRETCONSFAT:_eRetConsFat[01]:CVEND3		:= ' ' 
	::WSRETCONSFAT:_eRetConsFat[01]:NCOMIS3		:= 0.00
	::WSRETCONSFAT:_eRetConsFat[01]:CVEND4		:= ' ' 
	::WSRETCONSFAT:_eRetConsFat[01]:NCOMIS4		:= 0.00
	::WSRETCONSFAT:_eRetConsFat[01]:CVEND5		:= ' ' 
	::WSRETCONSFAT:_eRetConsFat[01]:NCOMIS5		:= 0.00
	::WSRETCONSFAT:_eRetConsFat[01]:CVEND6		:= ' ' 
	::WSRETCONSFAT:_eRetConsFat[01]:NCOMIS6 	:= 0.00
	::WSRETCONSFAT:_eRetConsFat[01]:CVEND7	 	:= ' ' 
	::WSRETCONSFAT:_eRetConsFat[01]:NCOMIS7		:= 0.00
	::WSRETCONSFAT:_eRetConsFat[01]:CVEND8		:= ' ' 
	::WSRETCONSFAT:_eRetConsFat[01]:NCOMIS8		:= 0.00
	::WSRETCONSFAT:_eRetConsFat[01]:CVEND9		:= ' ' 
	::WSRETCONSFAT:_eRetConsFat[01]:NCOMIS9		:= 0.00
	::WSRETCONSFAT:_eRetConsFat[01]:CRETORNO 	:= '.F.'
	
	//Verificando se a entrada dados e uma estrutura
	if valtype(::WSSOLCONSFAT:_eSolConsFat) == 'A'.AND. !Empty(::WSSOLCONSFAT:_eSolConsFat)
	
		// Verificando se o CNPJ emitente existe
		_cCnpjEmit := Alltrim(::WSSOLCONSFAT:_eSolConsFat[01]:cCnpj_emit)	
		
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
			if Alltrim(SuperGetmv('AP_AUTWS', .T., 'April@2017' )) <> Alltrim(Decode64(::WSSOLCONSFAT:_eSolConsFat[01]:CCHAVE ))
	
				_cMensRet := 'Error 999 - Token Invalido. Obtenha e Informe um Novo Token.'
				::WSRETCONSFAT:_eRetConsFat[01]:CCHAVE	:= ::WSSOLCONSFAT:_eSolConsFat[01]:CCHAVE
				::WSRETCONSFAT:_eRetConsFat[01]:CFATURA := ::WSSOLCONSFAT:_eSolConsFat[01]:CFATURA 
				::WSRETCONSFAT:_eRetConsFat[01]:CMSGRET := _cMensRet
		
			Else
		
				// Coletando informações.
	 			for _nIt := 1 to Len( ::WSSOLCONSFAT:_eSolConsFat )
	 			
					// Verificando Identificador do cadastro
					_cFatura 	:= Alltrim(::WSSOLCONSFAT:_eSolConsFat[_nIt]:CFATURA)
					lMsErroAuto := .F.
					_lGerarMov  := .F.
					_cMensRet   := ''
					
					// Caso diferente logar noutra empresa/filial
			 		if _cCnpjEmit#Alltrim(::WSSOLCONSFAT:_eSolConsFat[01]:cCnpj_emit)	
			 			
		 				_cCnpjEmit := Alltrim(::WSSOLCONSFAT:_eSolConsFat[01]:cCnpj_emit)	
		 				_nPos      := ascan(_aEmpresas,{|x| Alltrim(x[03]) == _cCnpjEmit})
			 				
			 			if _nPos>0
			 				
		 					_cEmp := Alltrim(_aEmpresas[_nPos][01])
		 					_cFil := Alltrim(_aEmpresas[_nPos][02])
		 					 
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
					_nTamFt:= TAMSX3("Z0_FATURA")[1] 
				 	_nTamPa:= TAMSX3("Z0_PARCELA")[1]
				 	
				 	// Caso sem erro.
				 	if Empty(_cMensRet)
				 	
				 		//Localizando os itens para envio da consulta
						dbSelectArea("SZ0")
						SZ0->( dbSetOrder(1) )
							
						if SZ0->( DbSeek( FwxFilial("SZ0") + Padr(_cFatura,_nTamFt) ) )
				 
				 	 		_cIndice := FwxFilial("SZ0") + Padr(_cFatura,_nTamFt) 
					 		While SZ0->( !EOF() ) .and. ( SZ0->Z0_FILIAL + SZ0->Z0_FATURA ==  _cIndice)
							
								// Completando itens do retorno.
				 				if Empty(::WSRETCONSFAT:_eRetConsFat[01]:CMSGRET)  
				     					
						     		// Grava mensagem de retorno
									::WSRETCONSFAT:_eRetConsFat[01]:CCHAVE	 	:= _cFatura + '-' + SZ0->Z0_PARCELA
									::WSRETCONSFAT:_eRetConsFat[01]:CIDCLIENT 	:= SZ0->Z0_IDCLI		 
									::WSRETCONSFAT:_eRetConsFat[01]:CFATURA		:= _cFatura  
									::WSRETCONSFAT:_eRetConsFat[01]:CTPMOD		:= SZ0->Z0_TPMOD	 
									::WSRETCONSFAT:_eRetConsFat[01]:CTPFAT		:= SZ0->Z0_TPFAT		 
									::WSRETCONSFAT:_eRetConsFat[01]:CNUM   		:= SZ0->Z0_NUM	 		 
									::WSRETCONSFAT:_eRetConsFat[01]:CBDVPAI		:= SZ0->Z0_BDVPAI
									::WSRETCONSFAT:_eRetConsFat[01]:CCLIENTE	:= SZ0->Z0_CLIENTE		 
									::WSRETCONSFAT:_eRetConsFat[01]:CLOJACLI	:= SZ0->Z0_LOJACLI 	 
									::WSRETCONSFAT:_eRetConsFat[01]:CIDCGC		:= SZ0->Z0_IDCGC		 
									::WSRETCONSFAT:_eRetConsFat[01]:CIDCPF		:= SZ0->Z0_IDCPF	 
									::WSRETCONSFAT:_eRetConsFat[01]:CPARCELA	:= SZ0->Z0_PARCELA 
								 	::WSRETCONSFAT:_eRetConsFat[01]:NPREMIO		:= SZ0->Z0_VLRPREM
									::WSRETCONSFAT:_eRetConsFat[01]:NVLRTO		:= SZ0->Z0_VLRTO		 
									::WSRETCONSFAT:_eRetConsFat[01]:NIOF		:= SZ0->Z0_IOF  
									::WSRETCONSFAT:_eRetConsFat[01]:CCANC		:= SZ0->Z0_CANC	
									::WSRETCONSFAT:_eRetConsFat[01]:CUSRLOG		:= SZ0->Z0_USRCANC	
									::WSRETCONSFAT:_eRetConsFat[01]:CHRCANC   	:= SZ0->Z0_HRCANC	
									::WSRETCONSFAT:_eRetConsFat[01]:CNFFAT		:= SZ0->Z0_NFFAT		 
									::WSRETCONSFAT:_eRetConsFat[01]:CSERIRNF	:= SZ0->Z0_SERIENF
									::WSRETCONSFAT:_eRetConsFat[01]:CEMISNF		:= cValToChar(SZ0->Z0_EMISNF) 
									::WSRETCONSFAT:_eRetConsFat[01]:CDTVEN		:= cValToChar(SZ0->Z0_DTVEN)
									::WSRETCONSFAT:_eRetConsFat[01]:DCANC		:= cValToChar(SZ0->Z0_DTCANC)
									::WSRETCONSFAT:_eRetConsFat[01]:CEMISSAO	:= cValToChar(SZ0->Z0_EMISSAO)
									::WSRETCONSFAT:_eRetConsFat[01]:CMSGRET		:= _cMensRet
									::WSRETCONSFAT:_eRetConsFat[01]:CRETORNO 	:= cValToChar(!lMsErroAuto)
									::WSRETCONSFAT:_eRetConsFat[01]:CVEND1		:= SZ0->Z0_VEND1 
									::WSRETCONSFAT:_eRetConsFat[01]:NCOMIS1		:= SZ0->Z0_COMIS1 
									::WSRETCONSFAT:_eRetConsFat[01]:CVEND2		:= SZ0->Z0_VEND2 
									::WSRETCONSFAT:_eRetConsFat[01]:NCOMIS2		:= SZ0->Z0_COMIS2
									::WSRETCONSFAT:_eRetConsFat[01]:CVEND3		:= SZ0->Z0_VEND3
									::WSRETCONSFAT:_eRetConsFat[01]:NCOMIS3		:= SZ0->Z0_COMIS3
									::WSRETCONSFAT:_eRetConsFat[01]:CVEND4		:= SZ0->Z0_VEND4 
									::WSRETCONSFAT:_eRetConsFat[01]:NCOMIS4		:= SZ0->Z0_COMIS4 
									::WSRETCONSFAT:_eRetConsFat[01]:CVEND5		:= SZ0->Z0_VEND5  
									::WSRETCONSFAT:_eRetConsFat[01]:NCOMIS5		:= SZ0->Z0_COMIS5
									::WSRETCONSFAT:_eRetConsFat[01]:CVEND6		:= SZ0->Z0_VEND6 
									::WSRETCONSFAT:_eRetConsFat[01]:NCOMIS6 	:= SZ0->Z0_COMIS6
									::WSRETCONSFAT:_eRetConsFat[01]:CVEND7	 	:= SZ0->Z0_VEND7
									::WSRETCONSFAT:_eRetConsFat[01]:NCOMIS7		:= SZ0->Z0_COMIS7
									::WSRETCONSFAT:_eRetConsFat[01]:CVEND8		:= SZ0->Z0_VEND8 
									::WSRETCONSFAT:_eRetConsFat[01]:NCOMIS8		:= SZ0->Z0_COMIS8
									::WSRETCONSFAT:_eRetConsFat[01]:CVEND9		:= SZ0->Z0_VEND9 
									::WSRETCONSFAT:_eRetConsFat[01]:NCOMIS9		:= SZ0->Z0_COMIS9
									
								Else
				     					
					     			// Cria e alimenta uma nova instancia do Retorno
					  				oRetSol :=  WSClassNew("_aRetConsFat")
					  				
					  				oRetSol:CCHAVE	 	:= _cFatura + '-' + SZ0->Z0_PARCELA
									oRetSol:CIDCLIENT 	:= SZ0->Z0_IDCLI		 
									oRetSol:CFATURA		:= _cFatura 
									oRetSol:CTPMOD		:= SZ0->Z0_TPMOD		 
									oRetSol:CTPFAT		:= SZ0->Z0_TPFAT		 
									oRetSol:CNUM   		:= SZ0->Z0_NUM	 		 
									oRetSol:CBDVPAI  	:= SZ0->Z0_BDVPAI
									oRetSol:CCLIENTE	:= SZ0->Z0_CLIENTE		 
									oRetSol:CLOJACLI	:= SZ0->Z0_LOJACLI 	 
									oRetSol:CIDCGC		:= SZ0->Z0_IDCGC		 
									oRetSol:CIDCPF		:= SZ0->Z0_IDCPF		 
									oRetSol:CPARCELA	:= SZ0->Z0_PARCELA 	 
									oRetSol:CDTVEN		:= cValToChar(SZ0->Z0_DTVEN)	 
									oRetSol:CEMISSAO	:= cValToChar(SZ0->Z0_EMISSAO) 
									oRetSol:NPREMIO		:= SZ0->Z0_VLRPREM		 
									oRetSol:NVLRTO		:= SZ0->Z0_VLRTO		 
									oRetSol:NIOF		:= SZ0->Z0_IOF			 
									oRetSol:CCANC		:= SZ0->Z0_CANC		 
									oRetSol:DCANC		:= cValToChar(SZ0->Z0_DTCANC) 
									oRetSol:CHRCANC		:= SZ0->Z0_HRCANC
									oRetSol:CUSRLOG		:= SZ0->Z0_USRCANC		 
									oRetSol:CNFFAT		:= SZ0->Z0_NFFAT		 
									oRetSol:CSERIRNF	:= SZ0->Z0_SERIENF		 
									oRetSol:CEMISNF		:= cValToChar(SZ0->Z0_EMISNF) 
									oRetSol:CVEND1		:= SZ0->Z0_VEND1 
									oRetSol:NCOMIS1		:= SZ0->Z0_COMIS1 
									oRetSol:CVEND2		:= SZ0->Z0_VEND2 
									oRetSol:NCOMIS2		:= SZ0->Z0_COMIS2
									oRetSol:CVEND3		:= SZ0->Z0_VEND3
									oRetSol:NCOMIS3		:= SZ0->Z0_COMIS3
									oRetSol:CVEND4		:= SZ0->Z0_VEND4 
									oRetSol:NCOMIS4		:= SZ0->Z0_COMIS4 
									oRetSol:CVEND5		:= SZ0->Z0_VEND5  
									oRetSol:NCOMIS5		:= SZ0->Z0_COMIS5
									oRetSol:CVEND6		:= SZ0->Z0_VEND6 
									oRetSol:NCOMIS6 	:= SZ0->Z0_COMIS6
									oRetSol:CVEND7	 	:= SZ0->Z0_VEND7
									oRetSol:NCOMIS7		:= SZ0->Z0_COMIS7
									oRetSol:CVEND8		:= SZ0->Z0_VEND8 
									oRetSol:NCOMIS8		:= SZ0->Z0_COMIS8
									oRetSol:CVEND9		:= SZ0->Z0_VEND9 
									oRetSol:NCOMIS9		:= SZ0->Z0_COMIS9
									oRetSol:CMSGRET		:= _cMensRet
									oRetSol:CRETORNO 	:= cValToChar(!lMsErroAuto)
									
					  				AAdd( ::WSRETCONSFAT:_eRetConsFat, oRetSol )
			  					
		  						Endif
		  						
		  						SZ0->( dbSkip() )
		  						
		  					Enddo
		  				 
		  					
		  				Else
					
							_cMensRet := 'Error – 001 - Fatura não localizada.'
							::WSRETCONSFAT:_eRetConsFat[01]:CCHAVE	:= ::WSSOLCONSFAT:_eSolConsFat[01]:CCHAVE
							::WSRETCONSFAT:_eRetConsFat[01]:CFATURA := ::WSSOLCONSFAT:_eSolConsFat[_nIt]:CFATURA 
							::WSRETCONSFAT:_eRetConsFat[01]:CMSGRET := _cMensRet
							
						Endif
						
					Else
				
						::WSRETCONSFAT:_eRetConsFat[01]:CCHAVE	:= _cCnpjEmit
						::WSRETCONSFAT:_eRetConsFat[01]:CFATURA := ::WSSOLCONSFAT:_eSolConsFat[_nIt]:CFATURA 
						::WSRETCONSFAT:_eRetConsFat[01]:CMSGRET := _cMensRet
		  					
		  			Endif
				
				Next
				
			Endif
				
			//Reseta ambientes  
			//RpcClearEnv()
				
		Else
		
			_cMensRet := 'Error 900 - Empresa Emitente não existe no cadsatro Empresas do ERP Totvs.'
			::WSRETCONSFAT:_eRetConsFat[01]:CCHAVE  := _cCnpjEmit
			::WSRETCONSFAT:_eRetConsFat[01]:CMSGRET := _cMensRet
		
		Endif
				
	Else
	
		_cMensRet := 'Error 998 - Erro na estrutura de dados da solicitação.'
		::WSRETCONSFAT:_eRetConsFat[01]:CMSGRET	:= _cMensRet
		
	Endif
		
End Sequence

ErrorBlock(_oError)

if !empty(_cErroFont)
	::WSRETCONSFAT:_eRetConsFat[01]:CMSGRET := 'Descr.Erro Proc.: ' + _cLinErro + '|' +  _cErroFont
Endif	
 
Return .t.
 

