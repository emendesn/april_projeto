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
#Define _cEol	Chr(13) + Chr(10) 

/*/{Protheus.doc} WsAprilBilhetes

WSDL com métodos a serem consumidos pela aplicação TAVOLA 
da empresa  APRIL BRASIL TURISMO VIAGENS E ASSISTENCIA INTERNACIONAL LTDA, 
com o objetivo de alimentar a tabela Ponte Customizada SZ4  para geração de Bilhetes.
 
@type 	Fonte WSDL
@author Edie Carlos - TNU
@since 	04/05/2017 
 /*/
 

user function WsAprilBilhetes()

 // Inicio Definição Requisições - Inclusão //STRING, DATE, INTEGER, FLOAT, BOOLEAN, BASE64Binary

WsStruct _aSolBil

Wsdata CCHAVE		As String
Wsdata CEMP			As String
Wsdata CFIL			As String
Wsdata CTPMOD		As String
Wsdata CTPFAT		As String
Wsdata CBILHETE		As String
Wsdata CEMISSAO		As String
Wsdata CIDCGC		As String
Wsdata NVLRBILH		As Float
Wsdata CCANC		As String
Wsdata CDTCANC  	As String
Wsdata CHRCANC		As String
Wsdata CUSRCANC		As String
Wsdata CFATURA		As String
Wsdata CFATPRM		As String
Wsdata CFTCOM1		As String
Wsdata CFTCOM2		As String
Wsdata CFTCOM3		As String
Wsdata CFTCOM4		As String
Wsdata CFTCOM5		As String
Wsdata CFTCOM6		As String
Wsdata CFTCOM7		As String
Wsdata CFTCOM8		As String
Wsdata CFTCOM9		As String
Wsdata CNPJFOR		As String
Wsdata NFATPREM		As Float
Wsdata NCOMISS1		As Float
Wsdata NCOMISS2		As Float
Wsdata NCOMISS3		As Float
Wsdata NCOMISS4		As Float
Wsdata NCOMISS5		As Float
Wsdata NCOMISS6		As Float
Wsdata NCOMISS7		As Float
Wsdata NCOMISS8		As Float
Wsdata NCOMISS9		As Float
Wsdata CIDCTB		As String

EndWsstruct

//Estrutura para alteração
WsStruct _aBSolAlt

	Wsdata CAUTENTICACAO  	As String
	Wsdata CCHAVE	  		As String 
	Wsdata CAMPOS 			As String 
	Wsdata CCONTEUDO 		As String 

EndWsstruct

WsStruct EstSolAlt

  Wsdata aSolAltIt As Array of _aBSolAlt

ENDWSSTRUCT

WsStruct _aBilAlt
	
	Wsdata CCHAVE	 AS String 
	//Wsdata CID		 AS String 
	Wsdata CMSGRET	 AS String 
	Wsdata CRETORNO  AS String 
	
EndWsstruct

WsStruct BilrRetAlt

	Wsdata aRetAlt As Array of _aBilAlt

EndWsstruct
  
// Final Definição Requisição


WsStruct EstrSolBil

  Wsdata _eSolBil As Array of _aSolBil

EndwSstruct

// Inicio Definição da estrutura Dados Retorno - Inclusão

WsStruct _aRetSolBil
	
	Wsdata CCHAVE	 AS String 
	Wsdata CBILHETE	 AS String 
	Wsdata CMSGRET	 As String
	Wsdata CRETORNO	 As String
 
EndWsstruct

WsStruct EstrRetIBil
         
	Wsdata _eRetSolBil As Array of _aRetSolBil
 
EndWsstruct


WSSERVICE WsAprilBilhetes DESCRIPTION "Serviço destinado Inclusão de dados no MIDDLEWARE Emissao de Bilhete entre Tavola x Protheus"
 
	Wsdata WSSOLINCBIL 	As EstrSolBil
	Wsdata WSRETINCBIL	As EstrRetIBil
	
	WsData WSSOLANT       As EstSolAlt
	WsData WSRetAltBil    As BilrRetAlt
	
	//  Métodos //
	WsMethod PedIncluir Description "Inclusão de dados no MIDDLEWARE para posterior alimentar tabela de bilhetes - específico: Távola x Protheus"
	WsMethod PedAlter 	Description "Alteração de dados no MIDDLEWARE para posterior alimentar tabela de bilhetes - específico: Távola x Protheus"

EndWsservice


/* {Protheus.doc} PedIncluir
Método de WebService para inclusão tabela no MIDDLEWARE ( Faturas - SZ0 )
@type 		Método Fonte WSDL
@author 	Ivan de Oliveira
@since 		04/05/2017 
@version 	1.0
@return 	${Lógico}, ${.t.}
 */
 
WSMETHOD PedIncluir WSRECEIVE WSSOLINCBIL WSSEND WSRETINCBIL WSSERVICE WsAprilBilhetes

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
	::WSRETINCBIL:_eRetSolBil := Array(1)
	
	::WSRETINCBIL:_eRetSolBil[01]:= WSClassNew("_aRetSolBil")
	::WSRETINCBIL:_eRetSolBil[01]:CCHAVE   := 'Erro Estrutural'   
	::WSRETINCBIL:_eRetSolBil[01]:CBILHETE  := ' '
	::WSRETINCBIL:_eRetSolBil[01]:CMSGRET  := ' '
	::WSRETINCBIL:_eRetSolBil[01]:CRETORNO := '.F.'
	
	//Verificando se a entrada dados e uma estrutura
	if valtype(::WSSOLINCBIL:_eSolBil) == 'A' .and. !Empty(::WSSOLINCBIL:_eSolBil)
	
		// Verificando se o CNPJ emitente existe
		_cCnpjEmit := Alltrim(::WSSOLINCBIL:_eSolBil[01]:CNPJFOR)	
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
			if Alltrim(SuperGetmv('AP_AUTWS', .T., 'April@2017' )) <> Alltrim(Decode64(::WSSOLINCBIL:_eSolbil[01]:CCHAVE ))//'April@2017' <> Alltrim(WSSOLINCBIL:_eSolbil[01]:CCHAVE )//Alltrim(SuperGetmv('AP_AUTWS', .T., 'April@2017' ))
			 
	
				_cMensRet := 'Error 999 - Token Invalido. Obtenha e Informe um Novo Token.'
				::WSRETINCBIL:_eRetSolBil[01]:CCHAVE  := ::WSSOLINCBIL:_eSolBil[01]:CCHAVE
				::WSRETINCBIL:_eRetSolBil[01]:CBILHETE := ::WSSOLINCBIL:_eSolBil[01]:CBILHETE 
				::WSRETINCBIL:_eRetSolBil[01]:CMSGRET := _cMensRet
		
			Else
		
				// Coletando informações.
	 			for _nIt := 1 to Len( ::WSSOLINCBIL:_eSolBil )
	 			
					// Verificando Identificador do cadastro
					_cCnpj 		:= Alltrim(::WSSOLINCBIL:_eSolBil[_nIt]:CIDCGC)
					//_cCPF       := Alltrim(::WSSOLINCBIL:_eSolBil[_nIt]:CIDCPF)
					_cBilhete 	:= Alltrim(::WSSOLINCBIL:_eSolBil[_nIt]:CBILHETE)
					_cChave     := Alltrim(::WSSOLINCBIL:_eSolBil[_nIt]:CBILHETE)
					_cVldCgcCpf := if (Empty(_cCnpj),_cCPF, _cCnpj)
					
					// Caso diferente logar noutra empresa/filial
			 		if _cCnpjEmit#Alltrim(::WSSOLINCBIL:_eSolBil[_nIt]:CNPJFOR)
			 			
		 				_cCnpjEmit := Alltrim(::WSSOLINCBIL:_eSolBil[_nIt]:CNPJFOR)
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
					_nTamBl:= TAMSX3("Z4_BILHETE")[1] 
					
					
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
		     
		     			If SA1->(DbSeek( FwxFilial("SA1") + Padr(_cVldCgcCpf,_nTamC)))  
								
							// Verifica se encontrado e não esta com bloqueio
							if SA1->A1_MSBLQL <> '1'
							   _cMensRet := 'Error 008 - Cadastro de Direcionamento não encontrado!'
											
									// Verificando numerações de fatura
											if empty(_cBilhete)
								
							 					_cMensRet := 'Error – 006 - Número de Fatura inválido.'
												_cChave := Alltrim(::WSSOLINCBIL:_eSolBil[_nIt]:CBILHETE)
							
											Else
							
												_lGerarMov := .T.
							
											Endif
								
										Endif
										
									Endif
									
								Endif
								
										
							
						// Se de acordo validações gerar o registro.
						if _lGerarMov
						
							_cChave := Alltrim(::WSSOLINCBIL:_eSolBil[_nIt]:CBILHETE)
							
							// Verificando se registro já foi incluído. --> Z0_FILIAL+Z0_FATURA+Z0_PARCELA 
							dbSelectArea("SZ4")
							SZ4->( dbSetOrder(1) )
							
							if !SZ4->( DbSeek( FwxFilial("SZ4") + Padr(_cBilhete,_nTamBl) ) )
								
								if Reclock("SZ4", .T.)
								 
								 	
									SZ4->Z4_EMP      := _cEmp
									SZ4->Z4_FILIAL   := FwxFilial("SZ4")
									SZ4->Z4_TPMOD    := ::WSSOLINCBIL:_eSolBil[_nIt]:CTPMOD
									SZ4->Z4_TPFAT    := ::WSSOLINCBIL:_eSolBil[_nIt]:CTPFAT
									SZ4->Z4_BILHETE  := ::WSSOLINCBIL:_eSolBil[_nIt]:CBILHETE
									SZ4->Z4_EMISSAO  := ctod(::WSSOLINCBIL:_eSolBil[_nIt]:CEMISSAO)   
									SZ4->Z4_VLRBILH  := ::WSSOLINCBIL:_eSolBil[_nIt]:NVLRBILH
									SZ4->Z4_CANC     := ::WSSOLINCBIL:_eSolBil[_nIt]:CCANC
									SZ4->Z4_DTCANC   := ctod(::WSSOLINCBIL:_eSolBil[_nIt]:CDTCANC)
									SZ4->Z4_HRCANC   := ::WSSOLINCBIL:_eSolBil[_nIt]:CHRCANC
									SZ4->Z4_USRCANC  := ::WSSOLINCBIL:_eSolBil[_nIt]:CUSRCANC
									SZ4->Z4_FATURA   := ::WSSOLINCBIL:_eSolBil[_nIt]:CFATURA
									SZ4->Z4_FATPRM   := ::WSSOLINCBIL:_eSolBil[_nIt]:CFATPRM
									SZ4->Z4_FTCOM1   := ::WSSOLINCBIL:_eSolBil[_nIt]:CFTCOM1
									SZ4->Z4_FTCOM2   := ::WSSOLINCBIL:_eSolBil[_nIt]:CFTCOM2
									SZ4->Z4_FTCOM3   := ::WSSOLINCBIL:_eSolBil[_nIt]:CFTCOM3
									SZ4->Z4_FTCOM4   := ::WSSOLINCBIL:_eSolBil[_nIt]:CFTCOM4 
									SZ4->Z4_FTCOM5   := ::WSSOLINCBIL:_eSolBil[_nIt]:CFTCOM5
									SZ4->Z4_FTCOM6   := ::WSSOLINCBIL:_eSolBil[_nIt]:CFTCOM6
									SZ4->Z4_FTCOM7   := ::WSSOLINCBIL:_eSolBil[_nIt]:CFTCOM7
									SZ4->Z4_FTCOM8   := ::WSSOLINCBIL:_eSolBil[_nIt]:CFTCOM8
									SZ4->Z4_FTCOM9   := ::WSSOLINCBIL:_eSolBil[_nIt]:CFTCOM9
									SZ4->Z4_CNPJFOR  := ::WSSOLINCBIL:_eSolBil[_nIt]:CIDCGC
									SZ4->Z4_VLRPREM  := ::WSSOLINCBIL:_eSolBil[_nIt]:NFATPREM
									SZ4->Z4_VLRCOM1  := ::WSSOLINCBIL:_eSolBil[_nIt]:NCOMISS1
									SZ4->Z4_VLRCOM2  := ::WSSOLINCBIL:_eSolBil[_nIt]:NCOMISS2
									SZ4->Z4_VLRCOM3  := ::WSSOLINCBIL:_eSolBil[_nIt]:NCOMISS3
									SZ4->Z4_VLRCOM4  := ::WSSOLINCBIL:_eSolBil[_nIt]:NCOMISS4
									SZ4->Z4_VLRCOM5  := ::WSSOLINCBIL:_eSolBil[_nIt]:NCOMISS5
									SZ4->Z4_VLRCOM6  := ::WSSOLINCBIL:_eSolBil[_nIt]:NCOMISS6
									SZ4->Z4_VLRCOM7  := ::WSSOLINCBIL:_eSolBil[_nIt]:NCOMISS7
									SZ4->Z4_VLRCOM8  := ::WSSOLINCBIL:_eSolBil[_nIt]:NCOMISS8
									SZ4->Z4_VLRCOM9  := ::WSSOLINCBIL:_eSolBil[_nIt]:NCOMISS9
									SZ4->Z4_IDCTB    := ::WSSOLINCBIL:_eSolBil[_nIt]:CIDCTB
									
									SZ4->(Msunlock())
								 
									// Retorno do processo.
	 								_cMensRet   := 'Ok – 001 – Processo registrado com Sucesso.'
									lMsErroAuto := .F.
									
								Else
	 									
	 								_cMensRet := 'Error 005 - Ocorreu um erro na tentativa de bloqueio registro tabela SZ0(Erp-Totvs).' 
	 								
	 							Endif
	 				 
	 						Else
							
								_cMensRet := 'Error 003 - Registro já incluido.' 
							
							Endif
							
								
					Elseif empty(_cMensRet)
				
						_cMensRet := 'Error 004 - Cnpj/Cpf Invalido.'  
						_cChave   := _cVldCgcCpf
							 
					Endif
						
					// Completando itens do retorno.
			 		if Empty(::WSRETINCBIL:_eRetSolBil[01]:CMSGRET)  
			     					
			     		// Grava mensagem de retorno
						::WSRETINCBIL:_eRetSolBil[01]:CCHAVE   := _cChave
						::WSRETINCBIL:_eRetSolBil[01]:CBILHETE := Alltrim(::WSSOLINCBIL:_eSolBil[_nIt]:CBILHETE)
						::WSRETINCBIL:_eRetSolBil[01]:CMSGRET  := _cMensRet
						::WSRETINCBIL:_eRetSolBil[01]:CRETORNO := cValToChar(!lMsErroAuto)
						
					Else
			     					
		     			// Cria e alimenta uma nova instancia do Retorno
		  				oRetSol :=  WSClassNew("_aRetComPre")
		  							
		  				oRetSol:CCHAVE   := _cChave  
						oRetSol:CBILHETE := Alltrim(::WSSOLINCBIL:_eSolBil[_nIt]:CBILHETE) 
						oRetSol:CMSGRET  := _cMensRet
						oRetSol:CRETORNO := cValToChar(!lMsErroAuto)
		  							 
	  					AAdd( ::WSRETINCBIL:_eRetSolBil, oRetSol )
	  					
	  				Endif
			 		
				Next 
				
			Endif
				
							
		Else
		
			_cMensRet := 'Error 900 - Empresa Emitente não existe no cadsatro Empresas do ERP Totvs.'
			::WSRETINCBIL:_eRetSolBil[01]:CCHAVE  := _cCnpjEmit
			::WSRETINCBIL:_eRetSolBil[01]:CMSGRET := _cMensRet
			
		Endif 
		
	Else
	
		_cMensRet := 'Error 998 - Erro na estrutura de dados da solicitação.'
		::WSRETINCBIL:_eRetSolBil[01]:CMSGRET := _cMensRet
	
	Endif
 
End Sequence

ErrorBlock(_oError)

if !empty(_cErroFont)
	::WSRETINCBIL:_eRetSolBil[01]:CMSGRET := 'Descr.Erro Proc.: ' + _cLinErro + '|' +  _cErroFont
Endif

//Reseta ambientes 
//RpcClearEnv() 

Return .T.
	
/*/{Protheus.doc} PedAlter
Método de WebService para alterações dos Bilhetes
@type Método Fonte WSDL
@author Edie Carlos
@since 02/05/2017
@version 1.0
@return ${Lógico}, ${.t.}
 /*/ 
WSMETHOD PedAlter WSRECEIVE WSSOLANT WSSEND WSRetAltBil WSSERVICE WsAprilBilhetes

Local _cEmp 	:= '01'
Local _cFil 	:= '0101'
Local _nIt  	:= 0
Local _nOpc 	:= 0
Local _nItCpo   := 0
Local _cMensRet := ''
Local _oError   := ErrorBlock({|e| ChecarErro(e)})
Local _aCposAlt := {}

// Sincronização dos campos a alterar
AAdd( _aCposAlt, { "SZ4","Falha – 004 – Bilhete não alterado"	 	,'Ok – 001 – Bilhete Alterado com Sucesso.' 	,"" })


Private lMsErroAuto := .f.
Private _cErroFont  := ''
Private _cLinErro   := 's/id'

// Tratamentos de erros
Begin Sequence

	//Abrindo os ambientes
	RpcSetType(3)
	RpcSetEnv(_cEmp, _cFil)
 
	// Montando mensagem retorno
	::WSRetAltBil:aRetAlt := Array(1)
		 
	::WSRetAltBil:aRetAlt[01]:= WSClassNew("_aBilAlt")
	::WSRetAltBil:aRetAlt[01]:CCHAVE 	:= ::WSSOLANT:aSolAltIt[01]:CCHAVE    
	//::WSRetAltBil:aRetAlt[01]:CID 	:= Alltrim(::WSSOLANT:aSolAltIt[01]:CIDTAVOLA)
	::WSRetAltBil:aRetAlt[01]:CMSGRET	:= ' ' 
	::WSRetAltBil:aRetAlt[01]:CRETORNO:= '.F.'
	
	// Padronizar tamanho campos
	
	_nTamF := TAMSX3("Z4_BILHETE")[1]
	
	
	// Verificando autenticação
	if Alltrim(SuperGetmv('AP_AUTWS', .T., 'April@2017' )) <> ::WSSOLANT:aSolAltIt[01]:CAUTENTICACAO//Alltrim(Decode64(::WSSOLANT:aSolAltIt[01]:CAUTENTICACAO))
	
		_cMensRet := 'Falha 999 - Token Invalido. Obtenha e Informe um Novo Token'
		::WSRetAltClFor:aRetAlt[01]:CMSGRET	 := _cMensRet
		 
	Else
	
		// Coletando informações.
 		for _nIt := 1 to Len( ::WSSOLANT:aSolAltIt )
 		
 			// Verificando qual campo será alterado
 			_cCpo 	   := upper(Alltrim(::WSSOLANT:aSolAltIt[_nIt]:CAMPOS))
 			_cConteudo := upper(Alltrim(::WSSOLANT:aSolAltIt[_nIt]:CCONTEUDO))
 			_cBil      := Alltrim(::WSSOLANT:aSolAltIt[01]:CCHAVE)

 			// Conteúdo de retorno
 				lMsErroAuto := .t.
 				_cMensRet   := ''//_aCposAlt[_nItCpo][02]
 				
						dbSelectArea("SX3") 
						dbSetOrder(2) 
		
						// Se encontrou, verifica se campo poderá ser alterado.
						if dbSeek(_cCpo)
					
							// Verificano se o campo é editável
							if SX3->X3_VISUAL <> 'V' .and. Empty(SX3->X3_WHEN)
						
								// Posicionando no registro.
								dbSelectArea("SZ4")
								dbSetOrder(1)
								
								_lRet := SZ4->(DbSeek( FwxFilial("SZ4") + Padr(_cBil,_nTamF) ))
								
															
								// Em encontrando, alterar o campo.
								if _lRet
								
									// Altera o campo solicitado.
									RecLock("SZ4", .f.)
								
										_cAltCpo := "SZ4" 	    + "->" +;
											    	_cCpo+ " := '" + _cConteudo + "'"
								
										__ExecMacro(_cAltCpo)
								
							 		MsUnlock()
							 		
							 		// Retorno alteração correta.
							 		_cMensRet   := _aCposAlt[1][03] + _cAltCpo
							 		lMsErroAuto := .F.
							 		
								Else
								
									_cMensRet += '(Cnpj ou Id.Távola não encontrado).'  
										 
								Endif
						
							Else
							
								_cMensRet += ' (Campo:' + _cCpo + ' não permite alteração no Erp Totvs).'
								
							Endif
							
						Else
						
							_cMensRet += '(Campo:' + _cCpo + ' inexistente no Erp Totvs).'
							
						Endif
					
				// Se for o primeiro, somente edita
		     	if Empty(::WSRetAltBil:aRetAlt[01]:CMSGRET)  
		     					
		     		// Grava mensagem de retorno
					::WSRetAltBil:aRetAlt[01]:CMSGRET  := _cMensRet
					::WSRetAltBil:aRetAlt[01]:CRETORNO := cValToChar(!lMsErroAuto)
									
		     	Else
		     					
     				// Cria e alimenta uma nova instancia do Retorno
					oRetSol :=  WSClassNew("_aCliForAlt")
						
					oRetSol:CCHAVE  := ::WSSOLANT:aSolAltIt[01]:CCHAVE  
					//oRetSol:CID     := Alltrim(::WSSOLANT:aSolAltIt[01]:CIDTAVOLA)
					oRetSol:CMSGRET := _cMensRet
					oRetSol:CRETORNO:= cValToChar(!lMsErroAuto)
	  							 
  					AAdd( ::WSRetAltBil:aRetAlt, oRetSol )
								    
				Endif
							
			//Next
 						
 		Next
 	
 	Endif// Autenticação
	
	//Reseta ambientes
	//RpcClearEnv() 
 
End Sequence

ErrorBlock(_oError)

if !empty(_cErroFont)
	::WSRetAltClFor:aRetAlt[01]:CMSGRET := 'Descr.Erro Proc.: ' + _cLinErro + '|' +  _cErroFont
Endif

Return .t.

/*/{Protheus.doc} _VerErr
Retornar Campo com Erro de Error.LOG(ExecAuto)
@type 	Static function
@author Totvs Nações Unidas - Ivan de Oliveira - 
@since 	23/08/2017
@version 1.0

@Param  ${Caractere},${_cArqMErr}, Local e nome do arquivo de LOG
@return ${Caractere},${_cCampo}  , Nome do campo e seu conteúdo com erros.

@example 
_VerErr(_cArqMErr)
 /*/
Static Function _VerErr(_cArqMErr)

_nLinhas:=MLCount(_cArqMErr) 
_cBuffer:="" 
_cCampo:="" 
_nErrLin:=1 
_cBuffer:=RTrim(MemoLine(_cArqMErr,,_nErrLin))      
          
//Carrega o nome do campo 
While (_nErrLin <= _nLinhas) 

	 _nErrLin++ 
	 _cBuffer:=RTrim(MemoLine(_cArqMErr,,_nErrLin)) 
	 
	 // Procura a linha com a Mensage de Inválido
     If (Upper(SubStr(_cBuffer,Len(_cBuffer)-7,Len(_cBuffer))) == "INVALIDO") 
     
     	_cCampo	:= _cBuffer 
      	_xTemp	:= AT("-",_cBuffer) 
      	_cCampo	:= AllTrim(SubStr(_cBuffer,_xTemp+1,AT("<",_cBuffer)-_xTemp-2))
        _cCampo := StrTran(_cCampo, ":=","=") 
        Exit
         
     EndIf 
     
EndDo                
 
Return _cCampo

	