#include "apwebsrv.ch"
#include "totvs.ch"
#include "fileio.ch"
#include 'protheus.ch'
#include "xmlxfun.ch"
#include "topconn.ch"
#include "rwmake.ch"
#include "tbiconn.ch"
#include "error.ch"   

#Define _cEol	Chr(13) + Chr(10) 

/*/{Protheus.doc} WsAprilCliFor

WSDL com m�todos a serem consumidos pela aplica��o TAVOLA 
da empresa  APRIL BRASIL TURISMO VIAGENS E ASSISTENCIA INTERNACIONAL LTDA, 
com o objetivo principal cadastrar ou consultar Cliente / Fornecedor / Vendedores.

@type Fonte WSDL
@author Ivan de Oliveira
@since 24/04/2017 
 /*/
 
 // Inicio Defini��o Requisi��o
 WsStruct _aSolicita
 
	 Wsdata CAUTENTICACAO  	As String
	 Wsdata CIDTAVOLA  		AS String 
	 Wsdata CNOME 			AS String 
	 Wsdata CNREDUZ 		AS String 
	 Wsdata CPESSOA 		AS String 
	 Wsdata CEND     		AS String 
	 Wsdata CTIPO  	 		AS String  
	 Wsdata CEST    		AS String  
	 Wsdata CESTADO 		AS String 
	 Wsdata CCOD_MUN 		AS String 
	 Wsdata CMUN     		AS String 
	 Wsdata CBAIRRO 		AS String 
	 Wsdata CCEP    		AS String  
	 Wsdata CCGC    		AS String 
	 Wsdata CINSCR   		AS String 
	 Wsdata CIDENTIF 		AS String 
	 Wsdata CCODPAIS 		AS String
	 
EndWsstruct

WsStruct _aSolAlt

	Wsdata CAUTENTICACAO  	As String
	Wsdata CCHAVE	  		As String 
	Wsdata CIDTAVOLA		As String 
	Wsdata CAMPOS 			As String 
	Wsdata CCONTEUDO 		As String 

EndWsstruct
 

WsStruct EstrSol

��Wsdata aSolItens As Array of _aSolicita

ENDWSSTRUCT
 
WsStruct EstrSolAlt

��Wsdata aSolAltIt As Array of _aSolAlt

ENDWSSTRUCT
  
// Final Defini��o Requisi��o
 
// Inicio Defini��o da estrutura Dados Retorno - Inclus�o
WsStruct _aCliforInc
	
	Wsdata CCHAVE	 AS String 
	Wsdata CID		 AS String 
	Wsdata CMSGRET	 AS String 
	Wsdata CRETORNO  AS String 
	
EndWsstruct  
 	
WsStruct _aCliForAlt
	
	Wsdata CCHAVE	 AS String 
	Wsdata CID		 AS String 
	Wsdata CMSGRET	 AS String 
	Wsdata CRETORNO  AS String 
	
EndWsstruct
 
WsStruct EstrRetInc

	Wsdata aRetIncl As Array of _aCliforInc

EndWsstruct

WsStruct EstrRetAlt

	Wsdata aRetAlt As Array of _aCliForAlt

EndWsstruct

// Final Estrutura Retorno  

WSSERVICE WsAprilCliFor DESCRIPTION "Servi�o destinado a inclus�o e consulta de Cliente/Fornecedor/Vendedor oriundos de integra��o Tavola x Protheus"
 
	Wsdata WSRETINCLFOR 	As EstrRetInc
	Wsdata WSSOLICITA		As EstrSol
	
	WsData WSSOLANT         As EstrSolAlt
	WsData WSRetAltClFor    As EstrRetAlt
 
	//  M�todos //
	WsMethod CliIncluir Description "Inclus�o de Cliente/Fornecedor/Vendedor por integra��o: T�vola"
	WsMethod CliAlter 	Description "Altera��o de Cliente/Fornecedor/Vendedorpor integra��o: T�vola"
	
EndWsservice

/*/{Protheus.doc} CliIncluir
M�todo de WebService para inclus�o Cliente/Fornecedor/Vendedor
@type M�todo Fonte WSDL
@author Ivan de Oliveira
@since 24/04/2017
@version 1.0
@return ${L�gico}, ${.t.}
 /*/ 
WSMETHOD CliIncluir WSRECEIVE WSSOLICITA WSSEND WSRETINCLFOR WSSERVICE WsAprilCliFor

Local _cEmp 	:= '01'
Local _cFil 	:= '0101'
Local _nIt  	:= 0
Local _nOpc 	:= 0
Local _cMensRet := ''
Local _nItDel   := 0
Local _oError   := ErrorBlock({|e| u_EFATM001(e,@_cErroFont,@_cLinErro)})

Private lMsErroAuto := .f. 
Private _cErroFont  := ''
Private _cLinErro   := 's/id'

// Tratamentos de erros
Begin Sequence

	//Abrindo os ambientes
	RpcSetType(3)
	RpcSetEnv(_cEmp, _cFil)
 
 	// Montando mensagem retorno
	::WSRETINCLFOR:aRetIncl := Array(1)
		 
	::WSRETINCLFOR:aRetIncl[01]:= WSClassNew("_aCliforInc")
	::WSRETINCLFOR:aRetIncl[01]:CCHAVE 	:= ::WSSOLICITA:aSolItens[01]:CCGC    
	::WSRETINCLFOR:aRetIncl[01]:CID 	:= Alltrim(::WSSOLICITA:aSolItens[01]:CIDTAVOLA)
	::WSRETINCLFOR:aRetIncl[01]:CMSGRET	:= ' ' 
	::WSRETINCLFOR:aRetIncl[01]:CRETORNO:= '.F.'
	
	// Padronizar tamanho campos
	_nTamV := TAMSX3("A3_CGC")[1]
	_nTamC := TAMSX3("A1_CGC")[1]
	_nTamF := TAMSX3("A2_CGC")[1]
	_nTamIT:= TAMSX3("A3_XIDTAVC")[1]
	
	// Pasta onde ser�o enviados Error.LOG
	_cTmpErr := '\WsErros'
	if !ExistDir( _cTmpErr)
										
		MakeDir( _cTmpErr )
											
	Endif
 
	// Verificando autentica��o
	if Alltrim(SuperGetmv('AP_AUTWS', .T., 'April@2017' )) <> Alltrim(Decode64(::WSSOLICITA:aSolItens[01]:CAUTENTICACAO ))
	
		_cMensRet := 'Falha 999 - Token Invalido. Obtenha e Informe um Novo Token'
		::WSRETINCLFOR:aRetIncl[01]:CMSGRET	 := _cMensRet
		
	Else
	
		// Coletando informa��es.
 		for _nIt := 1 to Len( ::WSSOLICITA:aSolItens )
 			
			// Verificando Identificador do cadastro
			_cIdent		:= Upper(FwNoAccent((::WSSOLICITA:aSolItens[_nIt]:CIDENTIF)))
			_cCnpj 		:= Alltrim(::WSSOLICITA:aSolItens[_nIt]:CCGC)
			_cIdTav		:= Alltrim(::WSSOLICITA:aSolItens[_nIt]:CIDTAVOLA)
			_cResp 		:= '000'
			_aContrInc  := {}
			lMsErroAuto := .f.
		 
			// Validando Cnpj ou CPF
			if CGC(_cCnpj)
			
				// Localiza na TABELA SX5
				_aItGer := _VerSx5(_cIdent)
 				
				if Empty(_aItGer)
			
					_cMensRet := 'Falha 007 - Idenficador n�o cadastrado no Erp Totvs, tabela SX5'
					::WSRETINCLFOR:aRetIncl[01]:CID 	:= _cIdent
					::WSRETINCLFOR:aRetIncl[01]:CMSGRET := _cMensRet
			
				Else
				
					//Verificando e/ou incluindo Cliente, Vendedor ou Fornecedor.
					for _nOpc := 1 to len(_aItGer)
					
						// verificando se o c�digo de pa�s foi enviado.
						if !Empty(upper(::WSSOLICITA:aSolItens[_nIt]:CCODPAIS))  
					
							// Vari�vel de inclus�o
							_aIncluir := {}
						
							// Cliente
							if _aItGer[_nOpc] == 'ZC' .and.!lMsErroAuto
							
								DbSelectArea("SA1")
	     						DbSetOrder(3)
	     						lMsErroAuto := .T.
	     
	     						If !DbSeek(FwxFilial("SA1") + Padr(_cCnpj,_nTamC))  
	     					
		     						// Verifica o c�digo sequencial de cliente
		     						_cCodCli := _cLjCli := ' '
		     						_VerCli( Left(_cCnpj,8), @_cCodCli,@_cLjCli, 'C' )
		     						 
		     			 
		     						_aIncluir :={ 	{"A1_FILIAL"    , FwxFilial("SA1")							 	,Nil},; 
		     										{"A1_COD"       , _cCodCli                    	     		 	,Nil},; 
		                         			  		{"A1_LOJA"      , _cLjCli                       	    	 	,Nil},; 
		                         			  		{"A1_NOME"      , upper(::WSSOLICITA:aSolItens[_nIt]:CNOME)  	,Nil},; 
			                         			  	{"A1_PESSOA"    , upper(::WSSOLICITA:aSolItens[_nIt]:CPESSOA)	,Nil},; 
			                         			  	{"A1_NREDUZ"    , upper(::WSSOLICITA:aSolItens[_nIt]:CNREDUZ)	,Nil},; 
						                         	{"A1_END"       , upper(::WSSOLICITA:aSolItens[_nIt]:CEND)   	,Nil},; 
						                         	{"A1_TIPO"      , upper(::WSSOLICITA:aSolItens[_nIt]:CTIPO)  	,Nil},; 
						                         	{"A1_ESTADO"	, upper(::WSSOLICITA:aSolItens[_nIt]:CESTADO)	,Nil},; 
						                         	{"A1_EST"       , upper(::WSSOLICITA:aSolItens[_nIt]:CEST)   	,Nil},; 
						                         	{"A1_COD_MUN"   , ::WSSOLICITA:aSolItens[_nIt]:CCOD_MUN 	 	,Nil},; 
						                         	{"A1_MUN"       , upper(::WSSOLICITA:aSolItens[_nIt]:CMUN)   	,Nil},; 
						                         	{"A1_BAIRRO"    , upper(::WSSOLICITA:aSolItens[_nIt]:CBAIRRO)	,Nil},; 
						                         	{"A1_CEP"       , ::WSSOLICITA:aSolItens[_nIt]:CCEP     	 	,Nil},; 
						                         	{"A1_CGC"       , ::WSSOLICITA:aSolItens[_nIt]:CCGC     	 	,Nil},; 
						                         	{"A1_INSCR"		, ::WSSOLICITA:aSolItens[_nIt]:CINSCR	  	 	,Nil},; 
						                         	{"A1_PAIS"      , upper(::WSSOLICITA:aSolItens[_nIt]:CCODPAIS)	,Nil},;  
						                         	{"A1_MSBLQL"    , "1"                        				 	,Nil},;
						                       		{"A1_XIDTAVC"	, _cIdTav									    ,Nil}} 
		     										 
	 								lMsErroAuto := .F. 
									MSExecAuto({|x,y| Mata030(x,y)},_aIncluir,3) 
							 
									//Ocorrendo erro de autoexecu��o.
									if lMsErroAuto
									
										// Recuperando a linha do erro
										//_cMensErro := MemoRead(NomeAutoLog())    
										_cArqMErr := Mostraerro( _cTmpErr +'\', Dtos(date())+StrTran(Time(),':','') + ".log")
										_cMensErro := _VerErr(_cArqMErr)
									
										// Recupera o erro
										_cMensRet := 'Ocorreu um erro na tentativa de inclus�o de Cliente. Verifique o campo/conte�do: ' + _cMensErro  
										 
									Else
									
										aadd(_aContrInc, { 'SA1', SA1->(recno()) } )
			     						_cResp   := Left(_cResp,2) + '1' 
			     						_cMensRet:= 'Ok � 001 � Cliente registrado com Sucesso.'
			     					Endif
			     					
			     				Else
		     						
		     						_cMensRet := 'Falha 004 � Cliente j� cadastrado.'  
		     						 
		     					Endif
	     					
		     					// Se for o primeiro, somente edita
			     				if Empty(::WSRETINCLFOR:aRetIncl[01]:CMSGRET)  
			     					
			     					// Grava mensagem de retorno
			     					::WSRETINCLFOR:aRetIncl[01]:CCHAVE	 := ::WSSOLICITA:aSolItens[_nIt]:CCGC
									::WSRETINCLFOR:aRetIncl[01]:CMSGRET  := _cMensRet
									::WSRETINCLFOR:aRetIncl[01]:CRETORNO := cValToChar(!lMsErroAuto)
										
			     					
			     				Else
			     				
				     				// Cria e alimenta uma nova instancia do Retorno
		  							oRetSol :=  WSClassNew("_aCliforInc")
		  							
		  							oRetSol:CCHAVE  := ::WSSOLICITA:aSolItens[_nIt]:CCGC
								    oRetSol:CID     := Alltrim(::WSSOLICITA:aSolItens[_nIt]:CIDTAVOLA)
								    oRetSol:CMSGRET := _cMensRet
								    oRetSol:CRETORNO:= cValToChar(!lMsErroAuto)
		  							 
	  								AAdd( ::WSRETINCLFOR:aRetIncl, oRetSol )
			     					  
								Endif
							 
							// Fornecedor
							ElseIf _aItGer[_nOpc] == 'ZF' .and. !lMsErroAuto
							
								dbSelectArea("SA2")
								SA2->( dbSetOrder(3) )
								lMsErroAuto := .T.
								
								If  !SA2->( DbSeek( FwxFilial("SA2") + Padr(_cCnpj,_nTamF) ) )
								
									_cCodFor := _cLjFor := ' '
									_aIncluir:= {}
		     						_VerCli( Left(_cCnpj,8), @_cCodFor,@_cLjFor, 'F' )
		     	            
		     						// Montando array de inclus�o
		     						AAdd(_aIncluir,{"A2_FILIAL"	 , FwXFilial("SA2")	,nil})
									AAdd(_aIncluir,{"A2_COD"	 , _cCodFor			,nil})
									AAdd(_aIncluir,{"A2_LOJA"	 , _cLjFor			,nil})
									AAdd(_aIncluir,{"A2_NOME"	 , upper(::WSSOLICITA:aSolItens[_nIt]:CNOME)	,nil})
									AAdd(_aIncluir,{"A2_NREDUZ"	 , upper(::WSSOLICITA:aSolItens[_nIt]:CNREDUZ)	,nil})
								 	AAdd(_aIncluir,{"A2_END"	 , upper(::WSSOLICITA:aSolItens[_nIt]:CEND) 	,nil})
									AAdd(_aIncluir,{"A2_BAIRRO"	 , upper(::WSSOLICITA:aSolItens[_nIt]:CBAIRRO) 	,nil})
									AAdd(_aIncluir,{"A2_EST"	 , upper(::WSSOLICITA:aSolItens[_nIt]:CEST)		,nil})
									AAdd(_aIncluir,{"A2_COD_MUN" , ::WSSOLICITA:aSolItens[_nIt]:CCOD_MUN 		,nil})
									AAdd(_aIncluir,{"A2_MUN"	 , upper(::WSSOLICITA:aSolItens[_nIt]:CMUN)		,nil})
									AAdd(_aIncluir,{"A2_CEP"	 , ::WSSOLICITA:aSolItens[_nIt]:CCEP 			,nil})
									AAdd(_aIncluir,{"A2_TIPO"	 , upper(::WSSOLICITA:aSolItens[_nIt]:CPESSOA)	,nil})
	 								AAdd(_aIncluir,{"A2_CGC"	 , ::WSSOLICITA:aSolItens[_nIt]:CCGC			,nil})
		 							AAdd(_aIncluir,{"A2_INSCR"	 , ::WSSOLICITA:aSolItens[_nIt]:CINSCR 			,nil})
		 							AAdd(_aIncluir,{"A2_PAIS"    , upper(::WSSOLICITA:aSolItens[_nIt]:CCODPAIS)	,Nil})
		 							AAdd(_aIncluir,{"A2_MSBLQL"	 , "1"											,nil})
		 							aAdd(_aIncluir,{"A2_XIDTAVC" , _cIdTav									    ,nil}) 
		 							
		 							lMsErroAuto := .F.
									MSExecAuto({|x,y| MATA020(x,y)},_aIncluir,3)                   					 
					                       	 
						            // Ocorrendo Erro, retornar a mensagem
		     						If lMsErroAuto	
		     						
		     							// Recuperando a linha do erro
										// Recuperando a linha do erro
										//_cMensErro := MemoRead(NomeAutoLog())    
										_cArqMErr := Mostraerro( _cTmpErr +'\', Dtos(date())+StrTran(Time(),':','') + ".log")
										_cMensErro := _VerErr(_cArqMErr)
									
										// Recupera o erro
										_cMensRet := 'Ocorreu um erro na tentativa de inclus�o de Fornecedor. Verifique o campo/conte�do: ' + _cMensErro  
										 
										// Apagar registro anterior, em caso de erro
										for _nItDel := 1 to len(_aContrInc)
										
											_cTabExc := _aContrInc[_nItDel][01]
										
											dbSelectArea(_cTabExc)
											Dbgoto(_aContrInc[_nItDel][02])
											RecLock(_cTabExc, .F.)
												dbDelete()
											MsUnLock()
									
										Next
								 
									Else
								
										aadd(_aContrInc, { 'SA2', SA2->(recno()) } )
										_cResp   := '1' + substr(_cResp,2,len(_cResp))
										_cMensRet:= 'Ok � 002 � Fornecedor registrado com Sucesso.'  
								
									Endif
									
								Else
								
									_cMensRet := 'Falha 006 - Fornecedor j� cadastrado.' 
								 
								Endif
								
								// Se for o primeiro, somente edita
			     				if Empty(::WSRETINCLFOR:aRetIncl[01]:CMSGRET)  
			     					
			     					// Grava mensagem de retorno
			     					::WSRETINCLFOR:aRetIncl[01]:CCHAVE	 := ::WSSOLICITA:aSolItens[_nIt]:CCGC
									::WSRETINCLFOR:aRetIncl[01]:CMSGRET  := _cMensRet
									::WSRETINCLFOR:aRetIncl[01]:CRETORNO := cValToChar(!lMsErroAuto)
										
			     					
			     				Else
			     					
		     						// Cria e alimenta uma nova instancia do Retorno
		  							oRetSol :=  WSClassNew("_aCliforInc")
		  							
		  							oRetSol:CCHAVE  := _cCnpj  
								    oRetSol:CID     := Alltrim(::WSSOLICITA:aSolItens[_nIt]:CIDTAVOLA)
								    oRetSol:CMSGRET := _cMensRet
								    oRetSol:CRETORNO:= cValToChar(!lMsErroAuto)
		  							 
	  								AAdd( ::WSRETINCLFOR:aRetIncl, oRetSol )
									    
								Endif
					
						
							// Vendedores 
							ElseIf  _aItGer[_nOpc] == 'ZV' .and. !lMsErroAuto
							
								// Verificando se j� incluso
								dbSelectArea("SA3")
		     					SA3->(DbOrderNickName("IDTAVORA"))
		     					
		     					lMsErroAuto := .T.
		     					if !dbSeek( FwxFilial("SA3") + Padr(_cIdTav,_nTamIT) )
		     					
		     						// Pega c�digo vendedor.
		     						_cCodVend:=  GetSXENum("SA3","A3_COD")
		     						_aIncluir:= {}
		     					
		     						// Armando a autoexecu��o
		     						aAdd( _aIncluir, {"A3_FILIAL"	, FwxFilial("SA3")								, nil})
		     						aAdd( _aIncluir, {"A3_COD"   	, _cCodVend	            						, nil})
		     						aAdd( _aIncluir, {"A3_NOME"  	, upper(::WSSOLICITA:aSolItens[_nIt]:CNOME)		, nil})
		     						aAdd( _aIncluir, {"A3_NREDUZ"   , upper(::WSSOLICITA:aSolItens[_nIt]:CNREDUZ)	, Nil})
		     						aAdd( _aIncluir, {"A3_END"		, upper(::WSSOLICITA:aSolItens[_nIt]:CEND) 		, nil})   
		     						aAdd( _aIncluir, {"A3_BAIRRO"	, upper(::WSSOLICITA:aSolItens[_nIt]:CBAIRRO)	, nil})
		     						aAdd( _aIncluir, {"A3_MUN" 		, upper(::WSSOLICITA:aSolItens[_nIt]:CMUN) 		, nil}) 
		     						aAdd( _aIncluir, {"A3_CGC" 		, ::WSSOLICITA:aSolItens[_nIt]:CCGC  			, nil})  
		     						aAdd( _aIncluir, {"A3_EST" 		, upper(::WSSOLICITA:aSolItens[_nIt]:CEST)		, nil})
		     					   	aAdd( _aIncluir, {"A3_CEP" 		, ::WSSOLICITA:aSolItens[_nIt]:CCEP  			, nil})   
		     						aAdd( _aIncluir, {"A3_MSBLQL"	, "1"											, nil})
		     						aAdd( _aIncluir, {"A3_XIDTAVC"	, _cIdTav									    , nil})  
		     						
		     						lMsErroAuto := .F.
		     						MSExecAuto({|x,y|mata040(x,y)},_aIncluir,3)
		     						
		     						// Ocorrendo Erro, retornar a mensagem
		     						If lMsErroAuto	
		     						
		     							// Recuperando a linha do erro
										//_cMensErro := MemoRead(NomeAutoLog())    
										_cArqMErr := Mostraerro( _cTmpErr +'\', Dtos(date())+StrTran(Time(),':','') + ".log")
										_cMensErro := _VerErr(_cArqMErr)
									
										// Recupera o erro
										_cMensRet := 'Ocorreu um erro na tentativa de inclus�o de Vendedor. Verifique o campo/conte�do: ' + _cMensErro  
										 
										// Apagar registro anterior, em caso de erro
										for _nItDel := 1 to len(_aContrInc)
										
											_cTabExc := _aContrInc[_nItDel][01]
										
											dbSelectArea(_cTabExc)
											Dbgoto(_aContrInc[_nItDel][02])
											RecLock(_cTabExc, .F.)
												dbDelete()
											MsUnLock()
									
										Next  
										 
		     						Else
		     						
		     							_cResp   := Left(_cResp,1) +  '1' + substr(_cResp,3,len(_cResp))
		     							_cMensRet:= 'Ok � 003 � Vendedor registrado com Sucesso.'    
		     							
		     						Endif
		     						
		     					Else
		     					
		     						_cMensRet := 'Falha 005 - Vendedor j� cadastrado.'  
		     						 
		     					Endif
		     					
		     					// Se for o primeiro, somente edita
			     				if Empty(::WSRETINCLFOR:aRetIncl[01]:CMSGRET)  
			     					
			     					// Grava mensagem de retorno
			     					::WSRETINCLFOR:aRetIncl[01]:CCHAVE	 := _cIdTav
									::WSRETINCLFOR:aRetIncl[01]:CMSGRET  := _cMensRet
									::WSRETINCLFOR:aRetIncl[01]:CRETORNO := cValToChar(!lMsErroAuto)
										
			     					
			     				Else
			     				
			     					// Cria e alimenta uma nova instancia do Retorno
		  							oRetSol :=  WSClassNew("_aCliforInc")
		  							
		  							oRetSol:CCHAVE  := _cIdTav 
								    oRetSol:CID     := Alltrim(::WSSOLICITA:aSolItens[_nIt]:CIDTAVOLA)
								    oRetSol:CMSGRET := _cMensRet
								    oRetSol:CRETORNO:= cValToChar(!lMsErroAuto)
		  							 
	  								AAdd( ::WSRETINCLFOR:aRetIncl, oRetSol )
	  								
								Endif
					 
		     				Endif 
							
						Else
						
							_cMensRet := 'Falha 009 � C�digo de Pa�s inv�lido.' 
							::WSRETINCLFOR:aRetIncl[01]:CID 	:= upper(::WSSOLICITA:aSolItens[_nIt]:CCODPAIS) 
							::WSRETINCLFOR:aRetIncl[01]:CMSGRET	:= _cMensRet
	     						
	     				Endif	
										
					Next
				
				Endif
				
			Else
			
				_cMensRet := 'Falha 008 - Cnpj/Cpf Invalido.'  
				::WSRETINCLFOR:aRetIncl[01]:CMSGRET	:= _cMensRet
			
			Endif
			
		next  
		
	Endif
  	
  	//Reseta ambientes
	//RpcClearEnv() 
    
End Sequence

ErrorBlock(_oError)

if !empty(_cErroFont)
	::WSRETINCLFOR:aRetIncl[01]:CMSGRET := 'Descr.Erro Proc.: ' + _cLinErro + '|' +  _cErroFont
Endif

Return .T.


 
 /*/{Protheus.doc} _VerSx5
Retornar C�digo das Tabela referente a Identifica��o de cadastro.
@type Static function
@author Totvs Na��es Unidas - Ivan de Oliveira - 
@since 26/04/2017
@version 1.0

@Param  ${Caractere},${Identifica��o do Cadastro}
@return ${Array},	 ${C�digo tabela SX5}

@example 
_VerSx5('Plataforma')
 /*/
Static Function _VerSx5(_cId)

Local _aRet := {}

// Selecionando itens para o relat�rio 
_cAlias := GetNextAlias() 

BeginSql ALIAS _cAlias 
 
	%noParser% 
	SELECT 
			DISTINCT X5_TABELA, X5_CHAVE 
	FROM
			%table:SX5% A  
	WHERE
			X5_FILIAL     = %Exp:xFilial("SX5")% 
			AND X5_TABELA IN('ZV','ZC','ZF')  
			AND X5_CHAVE  = %Exp:_cId% 
			AND A.%notDel% 
			
	ORDER BY  X5_TABELA
	
Endsql 
	 
// Processando as linhas 
(_cAlias)->( DbGotop() ) 
While !(_cAlias)->( Eof() ) 

	if ascan(_aRet, Alltrim(Upper((_cAlias)->X5_TABELA ) ) ) == 0
  
		aadd( _aRet, Alltrim(Upper((_cAlias)->X5_TABELA )))
		
	Endif
    (_cAlias)->(DbSkip())
Enddo

(_cAlias)->(DbCloseArea()) 
   
Return _aRet

/*/{Protheus.doc} _VerCli
Retornar C�digo/Loja Cliente
@type Static function
@author Totvs Na��es Unidas - Ivan de Oliveira - 
@since 28/04/2017
@version 1.0

@Param  ${Caractere},${_cCnpj}, Cnpj Cliente/Fornecedor/Vendedor
		${Caractere},${_cCli} , C�digo do CLiente/Fornecedor/Vendedor
		${Caractere},${_cLoja}, Loja   do CLiente/Fornecedor
		${Caractere},${_cTipo}, Qual cadastro consultar: C/F/V
		
@return ${Null},	 ${Null}

@example 
_VerCli(_cCli, _cLoja)
 /*/
Static Function _VerCli( _cCnpj, _cCli, _cLoja, _cTipo)

Local _aRet := {}

// Selecionando itens para o relat�rio GetLastQuery()[2]
_cAlias := GetNextAlias() 

//Consulta Cliente
if  _cTipo == 'C'

	BeginSql ALIAS _cAlias 

 		SELECT 
				MAX(NVL(CONCAT(A1_COD, A1_LOJA),' ')) CODCLI, A1_COD
		FROM
				%table:SA1% A  
		WHERE
				A1_FILIAL     			  = %Exp:xFilial("SA1")% 
				AND SUBSTRING(A1_CGC,1,8) = %Exp:_cCnpj% 
				AND A.A1_PESSOA 		  = 'J' 
				AND A.%notDel% 
				
	 	GROUP BY A1_COD
	 	
 	Endsql
 
 	// Processando as linhas 
	(_cAlias)->( DbGotop() ) 
	if !(_cAlias)->( Eof() )
	
		// Se estiver vazio, pegar pr�xima sequencia SXE.
		if !Empty((_cAlias)->(CODCLI)) 
		
			 _cCli  :=(_cAlias)->(A1_COD)
			 _cLoja := Soma1(Right( Alltrim((_cAlias)->(CODCLI)),2 ))
			 
	 	Endif

	Endif
  
 	(_cAlias)->(DbCloseArea()) 
  
    if empty(_cCli) .and. empty(_cLoja) 
    
    	_cCli  := GetSXENum("SA1","A1_COD")
		_cLoja := '01'
		ConfirmSX8()
		
	Endif
	
//Consulta Cliente
Elseif _cTipo == 'F'
 
 	BeginSql ALIAS _cAlias 
 
	 
		SELECT 
				MAX(NVL(CONCAT(A2_COD, A2_LOJA), ' ' )) CODCLI, A2_COD
		FROM
				%table:SA2% A  
		WHERE
				A2_FILIAL             	  = %Exp:xFilial("SA2")% 
				AND SUBSTRING(A2_CGC,1,8) = %Exp:_cCnpj%  
				AND A2_TIPO = 'J'       
				AND A.%notDel% 
				
		GROUP BY A2_COD
		
	Endsql 
	  
	// Processando as linhas 
	(_cAlias)->( DbGotop() ) 
	if !(_cAlias)->( Eof() )
	
		// Se estiver vazio, pegar pr�xima sequencia SXE.
		if !Empty((_cAlias)->(CODCLI)) 
		
			 _cCli  :=(_cAlias)->(A2_COD)
			 _cLoja := Soma1(Right( Alltrim((_cAlias)->(CODCLI)),2 ))
			 
	 	Endif

	Endif
    
    (_cAlias)->(DbCloseArea()) 
    
    if empty(_cCli) .and. empty(_cLoja) 
    
    	_cCli  := GetSXENum("SA2","A2_COD")
		_cLoja := '01'
		ConfirmSX8()
		
	Endif
 	
Endif

Return Nil

/*/{Protheus.doc} CliAlter
M�todo de WebService para altera��es em Cliente/Fornecedor/Vendedor
@type M�todo Fonte WSDL
@author Ivan de Oliveira
@since 02/05/2017
@version 1.0
@return ${L�gico}, ${.t.}
 /*/ 
WSMETHOD CliAlter WSRECEIVE WSSOLANT WSSEND WSRetAltClFor WSSERVICE WsAprilCliFor

Local _cEmp 	:= '01'
Local _cFil 	:= '0101'
Local _nIt  	:= 0
Local _nOpc 	:= 0
Local _nItCpo   := 0
Local _cMensRet := ''
Local _oError   := ErrorBlock({|e| ChecarErro(e)})
Local _aCposAlt := {}

// Sincroniza��o dos campos a alterar
AAdd( _aCposAlt, { "SA1","Falha � 004 � Cliente n�o alterado"	 	,'Ok � 001 � Cliente Alterado com Sucesso.' 	,"A1_NOME","A1_PESSOA","A1_NREDUZ","A1_END","A1_TIPO","A1_ESTADO"	,"A1_EST","A1_COD_MUN","A1_MUN","A1_BAIRRO","A1_CEP","A1_CGC","A1_INSCR","A1_XIDTAVC", "A1_PAIS","A1_CODPAIS" })
AAdd( _aCposAlt, { "SA2","Falha � 006 � Fornecedor n�o alterado"	,'Ok � 003 � Fornecedor Alterado com Sucesso.'	,"A2_NOME","A2_TIPO"  ,"A2_NREDUZ","A2_END"," "      ," "			,"A2_EST","A2_COD_MUN","A2_MUN","A2_BAIRRO","A2_CEP","A2_CGC","A2_INSCR","A2_XIDTAVC","A2_PAIS", "A2_CODPAIS" })
AAdd( _aCposAlt, { "SA3","Falha � 005 � Vendedor n�o alterado" 		,'Ok � 002 � Vendedor Alterado com Sucesso.'	,"A3_NOME",""		  ,"A3_NREDUZ","A3_END",""	   	 ,""	        ,"A3_EST",""		  ,"A3_MUN","A3_BAIRRO","A3_CEP","A3_CGC"," "	    ,"" 		 , ""       , "" 		  })	 

Private lMsErroAuto := .f.
Private _cErroFont  := ''
Private _cLinErro   := 's/id'

// Tratamentos de erros
Begin Sequence

	//Abrindo os ambientes
	RpcSetType(3)
	RpcSetEnv(_cEmp, _cFil)
 
	// Montando mensagem retorno
	::WSRetAltClFor:aRetAlt := Array(1)
		 
	::WSRetAltClFor:aRetAlt[01]:= WSClassNew("_aCliforAlt")
	::WSRetAltClFor:aRetAlt[01]:CCHAVE 	:= ::WSSOLANT:aSolAltIt[01]:CCHAVE    
	::WSRetAltClFor:aRetAlt[01]:CID 	:= Alltrim(::WSSOLANT:aSolAltIt[01]:CIDTAVOLA)
	::WSRetAltClFor:aRetAlt[01]:CMSGRET	:= ' ' 
	::WSRetAltClFor:aRetAlt[01]:CRETORNO:= '.F.'
	
	// Padronizar tamanho campos
	_nTamV := TAMSX3("A3_CGC")[1]
	_nTamC := TAMSX3("A1_CGC")[1]
	_nTamF := TAMSX3("A2_CGC")[1]
	_nTamIT:= TAMSX3("A3_XIDTAVC")[1]
	
	// Verificando autentica��o
	if Alltrim(SuperGetmv('AP_AUTWS', .T., 'April@2017' )) <> Alltrim(Decode64(::WSSOLANT:aSolAltIt[01]:CAUTENTICACAO))
	
		_cMensRet := 'Falha 999 - Token Invalido. Obtenha e Informe um Novo Token'
		::WSRetAltClFor:aRetAlt[01]:CMSGRET	 := _cMensRet
		 
	Else
	
		// Coletando informa��es.
 		for _nIt := 1 to Len( ::WSSOLANT:aSolAltIt )
 		
 			// Verificando qual campo ser� alterado
 			_cCpo 	   := upper(Alltrim(::WSSOLANT:aSolAltIt[_nIt]:CAMPOS))
 			_cConteudo := upper(Alltrim(::WSSOLANT:aSolAltIt[_nIt]:CCONTEUDO))
 			_cCnpj     := Alltrim(::WSSOLANT:aSolAltIt[01]:CCHAVE)
 			_cIdTav	   := Alltrim(::WSSOLANT:aSolAltIt[01]:CIDTAVOLA)
 			
 			// Localiza a posi��o do campo a ser alterado.
 			_nPosTab	:= aScan( _aCposAlt,{|x| AllTrim(x[01])== 'S'+ Left(_cCpo,2) })
 			
 			// Verificando a posi��o do campo
 			if _nPosTab > 0
 			
 				_nPosCpo :=  Ascan(_aCposAlt[_nPosTab], _cCpo )
 				
 			Endif
 			
 			// Execu��o dos campos
 			For _nItCpo := 1 to len(_aCposAlt)
 			
 				// Conte�do de retorno
 				lMsErroAuto := .t.
 				_cMensRet   := _aCposAlt[_nItCpo][02]
 				
 				//Verificando se a tabela do Campo existe	
 				if _nPosTab > 0 .and. _nPosCpo > 0
 			
 					// Verificando campos a serem alterados(Cliente/Fornec/Vendedor)
 					if !empty(_aCposAlt[_nItCpo][_nPosCpo])
 					
						dbSelectArea("SX3") 
						dbSetOrder(2) 
		
						// Se encontrou, verifica se campo poder� ser alterado.
						if dbSeek(_cCpo)
					
							// Verificano se o campo � edit�vel
							if SX3->X3_VISUAL <> 'V' .and. Empty(SX3->X3_WHEN)
						
								// Posicionando no registro.
								dbSelectArea(_aCposAlt[_nItCpo][01])
								dbSetOrder(3)
								
								_lRet := DbSeek( FwxFilial(_aCposAlt[_nItCpo][01]) + Padr(_cCnpj,_nTamF) )
								
								// Se n�o encontrou vai pelo ID T�vola.
								if !_lRet .and. _aCposAlt[_nItCpo][01] == 'SA3'
								
									SA3->(DbOrderNickName("IDTAVORA"))
									_lRet := DbSeek( FwxFilial(_aCposAlt[_nItCpo][01]) + Padr(_cIdTav,_nTamIT))
								
								Endif
								
								// Em encontrando, alterar o campo.
								if _lRet
								
									// Altera o campo solicitado.
									RecLock(_aCposAlt[_nItCpo][01], .f.)
								
										_cAltCpo := _aCposAlt[_nItCpo][01] 	    + "->" +;
											    	_aCposAlt[_nItCpo][_nPosCpo]+ " := '" + _cConteudo + "'"
								
										__ExecMacro(_cAltCpo)
								
							 		MsUnlock()
							 		
							 		// Retorno altera��o correta.
							 		_cMensRet   := _aCposAlt[_nItCpo][03] + _cAltCpo
							 		lMsErroAuto := .F.
							 		
								Else
								
									_cMensRet += '(Cnpj ou Id.T�vola n�o encontrado).'  
										 
								Endif
						
							Else
							
								_cMensRet += ' (Campo:' + _cCpo + ' n�o permite altera��o no Erp Totvs).'
								
							Endif
							
						Else
						
							_cMensRet += '(Campo:' + _cCpo + ' inexistente no Erp Totvs).'
							
						Endif
					
					Endif
					
				Else
				
					_cMensRet += '(Campo:' + _cCpo + ' inexistente no Erp Totvs).'
						
				Endif
				
				// Se for o primeiro, somente edita
		     	if Empty(::WSRetAltClFor:aRetAlt[01]:CMSGRET)  
		     					
		     		// Grava mensagem de retorno
					::WSRetAltClFor:aRetAlt[01]:CMSGRET  := _cMensRet
					::WSRetAltClFor:aRetAlt[01]:CRETORNO := cValToChar(!lMsErroAuto)
									
		     	Else
		     					
     				// Cria e alimenta uma nova instancia do Retorno
					oRetSol :=  WSClassNew("_aCliForAlt")
						
					oRetSol:CCHAVE  := ::WSSOLANT:aSolAltIt[01]:CCHAVE  
					oRetSol:CID     := Alltrim(::WSSOLANT:aSolAltIt[01]:CIDTAVOLA)
					oRetSol:CMSGRET := _cMensRet
					oRetSol:CRETORNO:= cValToChar(!lMsErroAuto)
	  							 
  					AAdd( ::WSRetAltClFor:aRetAlt, oRetSol )
								    
				Endif
							
			Next
 						
 		Next
 	
 	Endif
	
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
@author Totvs Na��es Unidas - Ivan de Oliveira - 
@since 	23/08/2017
@version 1.0

@Param  ${Caractere},${_cArqMErr}, Local e nome do arquivo de LOG
@return ${Caractere},${_cCampo}  , Nome do campo e seu conte�do com erros.

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
	 
	 // Procura a linha com a Mensage de Inv�lido
     If (Upper(SubStr(_cBuffer,Len(_cBuffer)-7,Len(_cBuffer))) == "INVALIDO") 
     
     	_cCampo	:= _cBuffer 
      	_xTemp	:= AT("-",_cBuffer) 
      	_cCampo	:= AllTrim(SubStr(_cBuffer,_xTemp+1,AT("<",_cBuffer)-_xTemp-2))
        _cCampo := StrTran(_cCampo, ":=","=") 
        Exit
         
     EndIf 
     
EndDo                
 
Return _cCampo

