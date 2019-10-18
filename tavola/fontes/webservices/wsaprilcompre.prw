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

/*/{Protheus.doc} WsAprilComPre

WSDL com métodos a serem consumidos pela aplicação TAVOLA 
da empresa  APRIL BRASIL TURISMO VIAGENS E ASSISTENCIA INTERNACIONAL LTDA, 
com o objetivo de alimentar a tabela Ponte Customizada SZ3 com a finalidade de gerar
Comissão e Prêmio.

@type 	Fonte WSDL
@author Ivan de Oliveira - TNU
@since 	03/05/2017 
 /*/
 
 // Inicio Definição Requisição//STRING, DATE, INTEGER, FLOAT, BOOLEAN, BASE64Binary
WsStruct _aSolComPre

	Wsdata CCHAVE	 	As String
  	Wsdata cFATURA		AS String
	Wsdata cTP			AS String
	Wsdata cIDCLI		AS String
	Wsdata cIDCGC		AS String
	Wsdata cIDCPF		AS String
	Wsdata cPARCELA		AS String
	Wsdata cEMISSAO		AS Date
	Wsdata cVENDEDOR	AS String
	Wsdata cVLRPREM		AS Float
	Wsdata cVLRCOM		AS Float
	Wsdata cCANC		AS String
	Wsdata cDTCANC		AS Date
	Wsdata cHRCANC		AS String
	Wsdata cUSRCANC		AS String
	WsData cCnpj_emit	AS String
	Wsdata nVLRDSR		AS Float
 
EndWsstruct

WsStruct EstrSolComPre

  Wsdata _eSolItens As Array of _aSolComPre

EndwSstruct
// Final Definição Requisição

 // Inicio Definição da estrutura Dados Retorno - Inclusão
WsStruct _aRetComPre
	
	Wsdata CCHAVE	 	AS String 
	Wsdata CEMP		 	AS String 
	Wsdata CFIL	 		AS String 
	Wsdata CFATURA  	AS String 
	Wsdata CMSGRET  	AS String
	WsData CRETORNO		as String
	
EndWsstruct

WsStruct EstrRetCPre

	Wsdata _eRetSolic As Array of _aRetComPre

EndWsstruct
// Final Definição Retorno

WSSERVICE WsAprilComPre DESCRIPTION "Serviço destinado Inclusão de dados no MIDDLEWARE como ponte para emissão Comissão e Prêmio entre Tavola x Protheus"
 
	Wsdata WSSOLCOMPRE 	As EstrSolComPre
	Wsdata WSRETSOLCPRE	As EstrRetCPre
	
	//  Métodos //
	WsMethod ComIncluir Description "Inclusão na tabela no MIDDLEWARE para integração: Távola x Protheus"
	 
EndWsservice

/*/{Protheus.doc} ComIncluir
Método de WebService para inclusão tabela no MIDDLEWARE 
@type 		Método Fonte WSDL
@author 	Ivan de Oliveira
@since 		03/05/2017 
@version 	1.0
@return 	${Lógico}, ${.t.}
 /*/ 
WSMETHOD ComIncluir WSRECEIVE WSSOLCOMPRE WSSEND WSRETSOLCPRE WSSERVICE WsAprilComPre

Local _cEmp 	:= _cFil := _cGrpEmp := _cUnNeg := ''
Local _aEmpresas:= {}
Local _nIt  	:= 0
Local _nOpc 	:= 0
Local _cMensRet := ''
Local _bError  	:= { |e| _oError := e , Break(e) }
Local _bErrBlk  := ErrorBlock( _bError )
 
Private lMsErroAuto := .f. 

// Tratamentos de erros
Begin Sequence

	// Montando ESTRUTURA retorno
	::WSRETSOLCPRE:_eRetSolic := Array(1)
		 
	::WSRETSOLCPRE:_eRetSolic[01]:= WSClassNew("_aRetComPre")
	::WSRETSOLCPRE:_eRetSolic[01]:CCHAVE   := 'Erro Estrutural'   
	::WSRETSOLCPRE:_eRetSolic[01]:CEMP 	   := _cEmp 
	::WSRETSOLCPRE:_eRetSolic[01]:CFIL	   := _cFil 
	::WSRETSOLCPRE:_eRetSolic[01]:CFATURA  := ' '
	::WSRETSOLCPRE:_eRetSolic[01]:CMSGRET  := ' '
	::WSRETSOLCPRE:_eRetSolic[01]:CRETORNO := '.F.'
	
	//Verificando se a entrada dados e uma estrutura
	if valtype(::WSSOLCOMPRE:_eSolItens) == 'A'.AND. !Empty(::WSSOLCOMPRE:_eSolItens)
		
		// Verificando se o CNPJ emitente existe
		_cCnpjEmit := Alltrim(::WSSOLCOMPRE:_eSolItens[01]:cCnpj_emit)	
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
			if Alltrim(SuperGetmv('AP_AUTWS', .T., 'April@2017' )) <> Alltrim(Decode64(::WSSOLCOMPRE:_eSolItens[01]:CCHAVE ))
		
				_cMensRet := 'Error 999 - Token Invalido. Obtenha e Informe um Novo Token.'
				::WSRETSOLCPRE:_eRetSolic[01]:CCHAVE  := ::WSSOLCOMPRE:_eSolItens[01]:CCHAVE
				::WSRETSOLCPRE:_eRetSolic[01]:CFATURA := ::WSSOLCOMPRE:_eSolItens[01]:cFATURA 
				::WSRETSOLCPRE:_eRetSolic[01]:CMSGRET := _cMensRet 
			
			Else
	
				// Coletando informações.
 				for _nIt := 1 to Len( ::WSSOLCOMPRE:_eSolItens )
 			
	 				// Verificando Identificador do cadastro
					_cIdent		:= Upper(FwNoAccent((::WSSOLCOMPRE:_eSolItens[_nIt]:cTP)))
					_cCnpj 		:= Alltrim(::WSSOLCOMPRE:_eSolItens[_nIt]:cIDCGC)
					_cFatura 	:= Alltrim(::WSSOLCOMPRE:_eSolItens[_nIt]:cFATURA)
					_cParcela	:= Alltrim(::WSSOLCOMPRE:_eSolItens[_nIt]:cPARCELA)
					lMsErroAuto := .T.
					_lGerarMov  := .f.
	 			
	 				// Caso diferente logar noutra empresa/filial
			 		if _cCnpjEmit#Alltrim(::WSSOLCOMPRE:_eSolItens[01]:cCnpj_emit)
			 			
		 				_cCnpjEmit := Alltrim(::WSSOLCOMPRE:_eSolItens[01]:cCnpj_emit)
		 				_nPos := ascan(_aEmpresas,{|x| Alltrim(x[03]) == _cCnpjEmit})
			 				
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
	 			
					// Validando Comissão ou Premio
					if _cIdent $ '|C|P|'.and. empty(_cMensRet)
					
						// Validando Cnpj ou CPF
						if CGC(_cCnpj)
						
							if _cIdent == 'C'
							
								_nTamC := TAMSX3("A1_CGC")[1]
							
								// Verifica se o funcionário existe
								dbSelectArea("SRA")
								dbSetOrder(5)
								
								_lEnc := SRA->( DbSeek( FwxFilial("SRA") + Padr(_cCnpj,_nTamC) ) ) 
	     
								// Verifica se encontrado e não esta com bloqueio
								if .T. // _lEnc .and. Empty(SRA->RA_DEMISSA)  
								
									_lGerarMov := .T.
									// _cEmp
									// _cFil
								
								Else
								
									_cMensRet := 'Error – 003 – Cadastro de Funcionario não localizado ou bloqueado para utilização.' 
								
								Endif
								
							Else
							
								_nTamF := TAMSX3("A1_CGC")[1]
								
								// Verifica se o fornecedor existe
								dbSelectArea("SA2")
								SA2->( dbSetOrder(3) )
								
								_lEnc := SA2->( DbSeek( FwxFilial("SA2") + Padr(_cCnpj,_nTamF) ) )
								
								// Verifica se encontrado e não esta com bloqueio
								if _lEnc .and. SA2->A2_MSBLQL <> '1'
								
									_lGerarMov := .T.
									// _cEmp
									// _cFil
								
								Else
								
									_cMensRet := 'Error – 002 – Cadastro de Fornecedor não localizado ou bloqueado para utilização.'
								
								Endif
							
							Endif
							
							// Se de acordo validações gerar o registro.
							if _lGerarMov
							
								// Verificando se registro já foi incluído.
								dbSelectArea("SZ3")
								SZ3->( dbSetOrder(1) )
								_nTamFt:= TAMSX3("Z3_NUMERO")[1] 
	 	 
								if !SZ3->( DbSeek( FwxFilial("SZ3") + Padr(_cFatura,_nTamFt) + Padr(_cParcela,_nTamFt) ) )
								
									if Reclock("SZ3", .T.)
									
										SZ3->Z3_FILIAL  := FwxFilial("SZ3")
										SZ3->Z3_NUMERO	:= _cFatura
										SZ3->Z3_TP		:= _cIdent
										SZ3->Z3_IDCLI	:= ::WSSOLCOMPRE:_eSolItens[_nIt]:cIDCLI
										SZ3->Z3_IDCGC	:= _cCnpj
										SZ3->Z3_IDCPF	:= ::WSSOLCOMPRE:_eSolItens[_nIt]:cIDCPF
										SZ3->Z3_PARCELA	:= _cParcela
										SZ3->Z3_EMISSAO	:= ::WSSOLCOMPRE:_eSolItens[_nIt]:cEMISSAO
										SZ3->Z3_VENDEDOR:= ::WSSOLCOMPRE:_eSolItens[_nIt]:cVENDEDOR
										SZ3->Z3_VLRPREM	:= ::WSSOLCOMPRE:_eSolItens[_nIt]:cVLRPREM
										SZ3->Z3_VLRCOM	:= ::WSSOLCOMPRE:_eSolItens[_nIt]:cVLRCOM
										SZ3->Z3_DSR     := ::WSSOLCOMPRE:_eSolItens[_nIt]:NVLRDSR
										SZ3->Z3_GRPEMP  := _cGrpEmp
										SZ3->Z3_FILEMIS	:= _cFil
										SZ3->Z3_EMPEMIS	:= _cEmp
										SZ3->Z3_UNDNEG 	:= _cUnNeg
										
	 									Msunlock()
	 									
	 									// Retorno do processo.
	 									_cMensRet   := 'Ok – 001 – Processo registrado com Sucesso.'
										lMsErroAuto := .F.
	 									
	 								Else
	 								
	 									_cMensRet := 'Error 006 - Ocorreu um erro na tentativa de bloqueio registro tabela SZ3(Erp-Totvs).' 
	 								
	 								Endif
	 				 
	 							Else
							
									_cMensRet := 'Error 005 - Registro já incluido.' 
							
								Endif
								
							Endif
					
						Else
				
							_cMensRet := 'Error 004 - Cnpj/Cpf Invalido.'  
							 
						Endif
						
					Elseif empty(_cMensRet)
					
						_cMensRet := 'Error – 001- TAG (Comissão/Premio) não preenchida ou identificada.'  
						
					Endif
			 		
			 		// Completando itens do retorno.
			 		if Empty(::WSRETSOLCPRE:_eRetSolic[01]:CMSGRET)  
			     					
			     		// Grava mensagem de retorno
						::WSRETSOLCPRE:_eRetSolic[01]:CCHAVE  := Alltrim(::WSSOLCOMPRE:_eSolItens[_nIt]:cFATURA)+ '-' + Alltrim(::WSSOLCOMPRE:_eSolItens[_nIt]:cPARCELA)
						::WSRETSOLCPRE:_eRetSolic[01]:CEMP    := _cEmp
						::WSRETSOLCPRE:_eRetSolic[01]:CFIL 	  := _cFil
						::WSRETSOLCPRE:_eRetSolic[01]:CFATURA := Alltrim(::WSSOLCOMPRE:_eSolItens[_nIt]:cFATURA) 
						::WSRETSOLCPRE:_eRetSolic[01]:CMSGRET := _cMensRet
						::WSRETSOLCPRE:_eRetSolic[01]:CRETORNO:= cValToChar(!lMsErroAuto)
										
			    	Else
			     					
		     			// Cria e alimenta uma nova instancia do Retorno
		  				oRetSol :=  WSClassNew("_aRetComPre")
		  							
		  				oRetSol:CCHAVE  := Alltrim(::WSSOLCOMPRE:_eSolItens[_nIt]:cFATURA)+ '-' + Alltrim(::WSSOLCOMPRE:_eSolItens[_nIt]:cPARCELA) 
						oRetSol:CEMP    := _cEmp
						oRetSol:CFIL 	:= _cFil
						oRetSol:CFATURA := ::WSSOLCOMPRE:_eSolItens[_nIt]:cFATURA 
						oRetSol:CMSGRET := _cMensRet
						oRetSol:CRETORNO:= cValToChar(!lMsErroAuto)
		  							 
	  					AAdd( ::WSRETSOLCPRE:_eRetSolic, oRetSol )
	  					
	  				Endif
			 		
				Next 
				
			Endif
			
			//Reseta ambientes  
			//RpcClearEnv()
			
		Else
		
			_cMensRet := 'Error 900 - Empresa Emitente não existe no cadsatro Empresas do ERP Totvs.'
			::WSRETSOLCPRE:_eRetSolic[01]:CMSGRET	:= _cMensRet
			
		Endif 
		
	Else
	
		_cMensRet := 'Error 998 - Erro na estrutura de dados da solicitação.'
		::WSRETSOLCPRE:_eRetSolic[01]:CMSGRET	:= _cMensRet
	
	Endif
	
RECOVER

	::WSRETSOLCPRE:_eRetSolic[01]:CMSGRET := 'Metodo: ' + Procname() + ', Erro: - ' + _oError:Description  
	
End Sequence


Return .T.



 