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

/*/{Protheus.doc} WsAprilParcelas
WsClientParce.prw
WSDL com métodos a serem consumidos pela aplicação TAVOLA 
da empresa  APRIL BRASIL TURISMO VIAGENS E ASSISTENCIA INTERNACIONAL LTDA, 
com o objetivo de alimentar a tabela Ponte Customizada SZ2  para geração de Parcelas.

@type 	Fonte WSDL
@author Ivan de Oliveira - TNU
@since 	24/05/2017 
/*/

// Inicio Definição Requisições - Inclusão //STRING, DATE, INTEGER, FLOAT, BOOLEAN, BASE64Binary
WsStruct _aSolIncPar

	Wsdata CCHAVE 		As String
	Wsdata CIDCLIENT	As String
	Wsdata CFATURA		As String
	Wsdata CTPMOD		As String
	Wsdata CTPFAT		As String
	Wsdata CIDCGC		As String
	Wsdata CIDCPF		As String
	Wsdata CPARCELA		As String
	Wsdata CEMISSAO		As String
	Wsdata CVENCTO		As String
	Wsdata NVLRTO		As Float
	Wsdata CCANC		As String
	Wsdata DCANC		As String
	Wsdata CUSRLOG		As String
	Wsdata CHRCANC		As String
	Wsdata CVLRBX 		As String
	Wsdata DDTBX 		As String
	Wsdata CUSRBX 		As String
	Wsdata CVLRSLD 		As String
	Wsdata CSTATP 		As String
	Wsdata CSTATT 		As String
	WsData CNUMAUT 		As String
	Wsdata CCNPJ_EMIT	As String

EndWsstruct

WsStruct EstrIncPar   

	  Wsdata _eIncParc As Array of _aSolIncPar

EndwSstruct

//  Definição Requisições - Consulta
WsStruct _aSolConPar

	Wsdata CCHAVE   	As String
	Wsdata CFATURA  	As String
	Wsdata CPARCELA 	As String
	Wsdata CSTATT		As String
	Wsdata CCNPJ_EMIT	As String

EndWsstruct


//  Definição Requisições - Nosso Numero

WsStruct EstrConsPar

	  Wsdata _eSolConsFat As Array of _aSolConPar

EndwSstruct

//  Definição Requisições - Confirmação Távora
WsStruct _aSolParU

	Wsdata CCHAVE 		As String
	Wsdata CFATURA 		As String
	Wsdata CSTATT		As String
	Wsdata CRETORNO		As String
	Wsdata CCNPJ_EMIT	As String

EndWsstruct

WsStruct EstrConfPar

	  Wsdata _eSolConfPar As Array of _aSolParU

EndwSstruct
// Final Definição Requisições



//.............................................................
// Inicio Definição da estrutura Dados Retorno - Inclusão

WsStruct _aRetIncPar

	Wsdata CCHAVE	 AS String 
	Wsdata CFATURA	 AS String 
	Wsdata CPARCELA	 As String
	Wsdata NVLRTO	 As Float
	Wsdata CMSGRET	 As String
	Wsdata CRETORNO	 As String

EndWsstruct

WsStruct EstrRetIPar

	Wsdata _eRetIncPar As Array of _aRetIncPar

EndWsstruct

//.............................................................
// Inicio Definição da estrutura Dados Retorno - Consulta
WsStruct _aRetConsPar

	Wsdata CCHAVE		As String
	Wsdata CIDCLIENT	As String
	Wsdata CFATURA		As String
	Wsdata CTPMOD		As String
	Wsdata CTPFAT		As String
	Wsdata CIDCGC		As String
	Wsdata CIDCPF		As String
	Wsdata CPARCELA		As String
	Wsdata CEMISSAO		As String
	Wsdata CVENCTO		As String
	Wsdata NVLRTO		As Float
	Wsdata CCANC		As String
	Wsdata DCANC		As String
	Wsdata CUSRLOG		As String
	Wsdata CHRCANC		As String
	Wsdata CVLRBX		As String
	Wsdata DDTBX		As String
	Wsdata CUSRBX		As String
	Wsdata CVLRSLD		As String
	Wsdata CSTATP		As String
	Wsdata CSTATT		As String
	Wsdata CMSGRET 		As String
	Wsdata CRETORNO		As String

EndWsstruct

WsStruct EstrRetcPar

	Wsdata _eRetConsPar As Array of _aRetConsPar

EndWsstruct

//.............................................................
// Inicio Definição da estrutura Dados Retorno - Confirmação Távora
WsStruct _aSolRetUpd

	Wsdata CCHAVE 	As String
	Wsdata CMSGRET 	As String
	Wsdata CRETORNO	As String

EndWsstruct

WsStruct EstrRetUpd

	  Wsdata _eSolRetUpd As Array of _aSolRetUpd

EndwSstruct

WsStruct _aSolUpdNN

	Wsdata CCHAVE   	As String
	Wsdata CFATURA  	As String
	Wsdata CPARCELA 	As String
	Wsdata NOSSONUMERO	As String
	Wsdata CCNPJ_EMIT	As String

EndWsstruct

WsStruct EstrUpdNN

	  Wsdata _eSolNN As Array of _aSolUpdNN

EndwSstruct

WsStruct _aRetNN

	Wsdata CCHAVE	 AS String 
	Wsdata CFATURA	 AS String 
	Wsdata CMSGRET	 As String
	Wsdata CRETORNO	 As String

EndWsstruct

WsStruct EstrRetNN

	Wsdata _eRetSolNN As Array of _aRetNN

EndWsstruct

// Final Definição Retorno


WSSERVICE WsAprilParcelas DESCRIPTION "Serviço destinado Inclusão de dados no MIDDLEWARE como ponte para emissão Parcelas entre Tavola x Protheus"

	Wsdata WSSOLINCPAR 	As EstrIncPar
	Wsdata WSRETINCPAR	As EstrRetIPar

	Wsdata WSCONSPARC 	As EstrConsPar
	Wsdata WSRETCONSPAR	As EstrRetcPar

	Wsdata WSCONFTAVORA As EstrConfPar
	Wsdata WSRETCONFTAV	As EstrRetUpd

	Wsdata WSNNTAVORA   As EstrUpdNN
	Wsdata WSRETNNTAV	As EstrRetNN

	//  Métodos //
	WsMethod BolIncluir Description "Inclusão de dados no MIDDLEWARE para posterior alimentar Financeiro - específico: Távola x Protheus"
	WsMethod BolCons 	Description "Consulta de dados no MIDDLEWARE para recuperar dados processados no Financeiro Protheus."
	WsMethod BolConf	Description "Confirmação de leitura – Tavola ."
	WsMethod BolAtu 	Description "Atualiza Nosso Numero – Tavola ."

EndWsservice

/* {Protheus.doc} BolIncluir
Método de WebService para inclusão tabela no MIDDLEWARE ( Parcelas - SZ1 )
@type 		Método Fonte WSDL
@author 	Ivan de Oliveira
@since 		24/05/2017
@version 	1.0
@return 	${Lógico}, ${.t.}
*/

WSMETHOD BOLINCLUIR WSRECEIVE WSSOLINCPAR WSSEND WSRETINCPAR WSSERVICE WsAprilParcelas

	Local _cEmp 	:= _cFil := _cGrpEmp := _cUnNeg := ''
	Local _nIt  	:= 0
	Local _nOpc 	:= 0
	Local _cMensRet := ''
	Local _aEmpresas:= {}
	Local _bError  	:= { |e| _oError := e , Break(e) }
	Local _bErrBlk  := ErrorBlock( _bError )

	Private lMsErroAuto := .f. 

	// Tratamentos de erros
	Begin Sequence

		// Montando ESTRUTURA retorno
		::WSRETINCPAR:_eRetIncPar := Array(1)

		::WSRETINCPAR:_eRetIncPar[01]:= WSClassNew("_aRetIncPar")
		::WSRETINCPAR:_eRetIncPar[01]:CCHAVE   := 'Erro Estrutural'   
		::WSRETINCPAR:_eRetIncPar[01]:CFATURA  := ' '
		::WSRETINCPAR:_eRetIncPar[01]:CPARCELA := ' '
		::WSRETINCPAR:_eRetIncPar[01]:NVLRTO   := 0.00
		::WSRETINCPAR:_eRetIncPar[01]:CMSGRET  := ' '
		::WSRETINCPAR:_eRetIncPar[01]:CRETORNO := '.F.' 

		//Verificando se a entrada dados e uma estrutura
		if valtype(::WSSOLINCPAR:_eIncParc) == 'A' .and. !Empty(::WSSOLINCPAR:_eIncParc)

			// Verificando se o CNPJ emitente existe
			_cCnpjEmit := Alltrim(::WSSOLINCPAR:_eIncParc[01]:CCNPJ_EMIT)	
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
				if Alltrim(SuperGetmv('AP_AUTWS', .T., 'April@2017' )) <> Alltrim(Decode64(::WSSOLINCPAR:_eIncParc[01]:CCHAVE ))

					_cMensRet := 'Error 999 - Token Invalido. Obtenha e Informe um Novo Token.'
					::WSRETINCPAR:_eRetIncPar[01]:CCHAVE  := ::WSSOLINCPAR:_eIncParc[01]:CFATURA + '-' + ::WSSOLINCPAR:_eIncParc[01]:CPARCELA
					::WSRETINCPAR:_eRetIncPar[01]:CFATURA := ::WSSOLINCPAR:_eIncParc[01]:CFATURA 
					::WSRETINCPAR:_eRetIncPar[01]:CMSGRET := _cMensRet

				Else

					// Coletando informações.
					for _nIt := 1 to Len( ::WSSOLINCPAR:_eIncParc )

						// Verificando Identificador do cadastro
						_cCnpj 		:= Alltrim(::WSSOLINCPAR:_eIncParc[_nIt]:CIDCGC)   
						_cCPF       := Alltrim(::WSSOLINCPAR:_eIncParc[_nIt]:CIDCPF)
						_cFatura 	:= Alltrim(::WSSOLINCPAR:_eIncParc[_nIt]:CFATURA)
						_cParcela	:= Alltrim(::WSSOLINCPAR:_eIncParc[_nIt]:CPARCELA)
						_cModFat	:= Alltrim(::WSSOLINCPAR:_eIncParc[_nIt]:CTPFAT)
						_cModalidade:= Alltrim(::WSSOLINCPAR:_eIncParc[_nIt]:CTPMOD) 

						_cVldCgcCpf := if (Empty(_cCnpj),_cCPF, _cCnpj)
						_cMensRet 	:= ''

						lMsErroAuto := .T.
						_lGerarMov  := .f.

						// Caso diferente logar noutra empresa/filial
						if _cCnpjEmit#Alltrim(::WSSOLINCPAR:_eIncParc[_nIt]:CCNPJ_EMIT)

							_cCnpjEmit := Alltrim(::WSSOLINCPAR:_eIncParc[_nIt]:CCNPJ_EMIT)
							_nPos := ascan(_aEmpresas,{|x| Alltrim(x[03]) == _cCnpjEmit})

							if _nPos>0

								_cEmp 	   := _aEmpresas[_nPos][01]
								_cFil 	   := _aEmpresas[_nPos][02]

								// Limpa ambiente atual Abrindo próximo
								RpcClearEnv()
								RpcSetType(3)
								RpcSetEnv(_cEmp, _cFil)

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
						_nTamC := TamSx3("A1_CGC")[1]
						_nTamFt:= TamSx3("Z1_FATURA")[1] 
						_nTamPa:= TamSx3("Z1_PARCELA")[1]
						_nTamTF:= TamSx3("Z2_TPFAT")[1]
						_nTamM := TamSx3("Z2_TPMOD")[1]

						// Validando Cnpj ou CPF
						if CGC(_cVldCgcCpf).and. empty(_cMensRet)

							// Verifica se o cliente existe
							DbSelectArea("SA1")
							DbSetOrder(3)
							lMsErroAuto := .T.
							_cMensRet 	:= 'Error – 002 - Cadastro de cliente não localizado ou bloqueado para utilização.'

							If DbSeek( FwxFilial("SA1") + Padr(_cVldCgcCpf,_nTamC))  

								// Verifica se encontrado e não esta com bloqueio
								if SA1->A1_MSBLQL <> '1'

									_cMensRet  := ' '

									// Verificando se a MODALIDADE X NATUREZA existe
									dbSelectArea("SZ2") 
									SZ2->(DbSetOrder(1))  

									_cMensRet := 'Error – 001 - Cadastro de Natureza para a operação não localizado'
									if Dbseek( FwxFilial("SZ2") + Padr(_cModFat,_nTamTF) + Padr(_cModalidade,_nTamM)   ) 

										_lGerarMov := .T.
										_cMensRet  := ' '

									Endif

								Endif

							Endif

							// Se de acordo validações gerar o registro.
							if _lGerarMov

								// Verificando se registro já foi incluído. --> Z1_FILIAL+Z1_FATURA+Z1_PARCELA 
								dbSelectArea("SZ1")
								SZ1->( dbSetOrder(1) )

								if !SZ1->( DbSeek( FwxFilial("SZ1") + Padr(_cFatura,_nTamFt) + Padr(_cParcela,_nTamPa) ) )

									if Reclock("SZ1", .T.)

										SZ1->Z1_FILIAL  := _cFil
										SZ1->Z1_FATURA	:= _cFatura
										SZ1->Z1_TPMOD	:= Alltrim(::WSSOLINCPAR:_eIncParc[_nIt]:CTPMOD)
										SZ1->Z1_TPFAT	:= Alltrim(::WSSOLINCPAR:_eIncParc[_nIt]:CTPFAT)
										SZ1->Z1_IDCGC	:= Alltrim(::WSSOLINCPAR:_eIncParc[_nIt]:CIDCGC)
										SZ1->Z1_IDCPF	:= Alltrim(::WSSOLINCPAR:_eIncParc[_nIt]:CIDCPF)
										SZ1->Z1_PARCELA	:= _cParcela
										SZ1->Z1_EMISSAO	:= Ctod(Alltrim(::WSSOLINCPAR:_eIncParc[_nIt]:CEMISSAO))
										SZ1->Z1_VENCTO	:= Ctod(Alltrim(::WSSOLINCPAR:_eIncParc[_nIt]:CVENCTO))
										SZ1->Z1_VLRTO	:= ::WSSOLINCPAR:_eIncParc[_nIt]:NVLRTO
										SZ1->Z1_NUMAUT  := ::WSSOLINCPAR:_eIncParc[_nIt]:CNUMAUT
										SZ1->Z1_GRPEMP  := _cGrpEmp
										SZ1->Z1_FILEMIS	:= _cFil
										SZ1->Z1_EMPEMIS	:= _cEmp
										SZ1->Z1_UNDNEG 	:= _cUnNeg

										/* := 
										SZ1->Z1_NUMBCO	:= 
										SZ1->Z1_NUMAUT	:= 
										SZ1->Z1_CANC
										SZ1->Z1_DTCANC
										SZ1->Z1_USERC
										SZ1->Z1_HORAC
										SZ1->Z1_VLRBX
										SZ1->Z1_DTBX
										SZ1->Z1_USRBX
										SZ1->Z1_SLDTIT
										SZ1->Z1_STATP
										SZ1->Z1_STATT
										*/

										Msunlock()

										// Retorno do processo.
										_cMensRet   := 'Ok – 001 – Processo registrado com Sucesso.'
										lMsErroAuto := .F.

									Else

										_cMensRet := 'Error 003 - Ocorreu um erro na tentativa de bloqueio registro tabela SZ0(Erp-Totvs).' 

									Endif

								Else

									_cMensRet := 'Error 004 - Registro já incluido.' 

								Endif

							Endif

						Elseif empty(_cMensRet)

							_cMensRet := 'Error 005 - Cnpj/Cpf Invalido.'  

						Endif

						// Completando itens do retorno.
						if Empty(::WSRETINCPAR:_eRetIncPar[01]:CMSGRET)  

							// Grava mensagem de retorno
							::WSRETINCPAR:_eRetIncPar[01]:CCHAVE  := Alltrim(::WSSOLINCPAR:_eIncParc[_nIt]:CFATURA) + '-' + Alltrim(::WSSOLINCPAR:_eIncParc[_nIt]:CPARCELA)
							::WSRETINCPAR:_eRetIncPar[01]:CFATURA := Alltrim(::WSSOLINCPAR:_eIncParc[_nIt]:CFATURA)
							::WSRETINCPAR:_eRetIncPar[01]:CPARCELA:= Alltrim(::WSSOLINCPAR:_eIncParc[_nIt]:CPARCELA)
							::WSRETINCPAR:_eRetIncPar[01]:NVLRTO  := ::WSSOLINCPAR:_eIncParc[_nIt]:NVLRTO
							::WSRETINCPAR:_eRetIncPar[01]:CMSGRET := _cMensRet
							::WSRETINCPAR:_eRetIncPar[01]:CRETORNO:= cValToChar(!lMsErroAuto)

						Else

							// Cria e alimenta uma nova instancia do Retorno
							oRetSol :=  WSClassNew("_aRetComPre")

							oRetSol:CCHAVE  	:= Alltrim(::WSSOLINCPAR:_eIncParc[_nIt]:CFATURA) + '-' + Alltrim(::WSSOLINCPAR:_eIncParc[_nIt]:CPARCELA) 
							oRetSol:CFATURA 	:= Alltrim(::WSSOLINCPAR:_eIncParc[_nIt]:CFATURA) 
							oRetSol:CPARCELA	:= Alltrim(::WSSOLINCPAR:_eIncParc[_nIt]:CPARCELA)
							oRetSol:NVLRTO 		:= ::WSSOLINCPAR:_eIncParc[_nIt]:NVLRTO
							oRetSol:CMSGRET 	:= _cMensRet
							oRetSol:CRETORNO	:= cValToChar(!lMsErroAuto)

							AAdd( ::WSRETINCPAR:_eRetIncPar, oRetSol )

						Endif

					Next 

				Endif

				//Reseta ambientes  
				//RpcClearEnv()

			Else

				_cMensRet := 'Error 900 - Empresa Emitente não existe no cadsatro Empresas do ERP Totvs.'
				::WSRETINCPAR:_eRetIncPar[01]:CCHAVE  := _cCnpjEmit
				::WSRETINCPAR:_eRetIncPar[01]:CMSGRET := _cMensRet

			Endif 

		Else

			_cMensRet := 'Error 998 - Erro na estrutura de dados da solicitação.'
			::WSRETINCPAR:_eRetIncPar[01]:CMSGRET := _cMensRet

		Endif


		RECOVER

		::WSRETINCPAR:_eRetIncPar[01]:CMSGRET := 'Metodo: ' + Procname() + ', Erro: - ' +_oError:Description 

	End Sequence


Return .T.

/*
{Protheus.doc} BolCons
Método de WebService para consultar tabela no MIDDLEWARE ( Parcelas - SZ1 )
@type 		Método Fonte WSDL
@author 	Ivan de Oliveira
@since 		24/05/2017 
@version 	1.0
@return 	${Lógico}, ${.t.}
*/  

WSMETHOD BOLCONS WSRECEIVE WSCONSPARC WSSEND WSRETCONSPAR WSSERVICE WsAprilParcelas

	Local _cEmp 	:= _cFil := _cGrpEmp := _cUnNeg := ''
	Local _nIt  	:= 0
	Local _nOpc 	:= 0
	Local _cMensRet := ''
	Local _bError  	:= { |e| _oError := e, Break(e) }
	Local _bErrBlk  := ErrorBlock( _bError )
	Local _aEmpresas:= {}

	Private lMsErroAuto := .f. 

	// Tratamentos de erros
	Begin Sequence

		// Montando ESTRUTURA retorno
		::WSRETCONSPAR:_eRetConsPar := Array(1)

		::WSRETCONSPAR:_eRetConsPar[01]:= WSClassNew("_aRetConsPar")
		::WSRETCONSPAR:_eRetConsPar[01]:CCHAVE	 	:= 'Erro Estrutural'   
		::WSRETCONSPAR:_eRetConsPar[01]:CIDCLIENT 	:= ' ' 
		::WSRETCONSPAR:_eRetConsPar[01]:CFATURA		:= ' ' 
		::WSRETCONSPAR:_eRetConsPar[01]:CTPMOD		:= ' ' 
		::WSRETCONSPAR:_eRetConsPar[01]:CTPFAT		:= ' ' 
		::WSRETCONSPAR:_eRetConsPar[01]:CIDCGC		:= ' ' 
		::WSRETCONSPAR:_eRetConsPar[01]:CIDCPF		:= ' ' 
		::WSRETCONSPAR:_eRetConsPar[01]:CPARCELA	:= ' ' 
		::WSRETCONSPAR:_eRetConsPar[01]:CEMISSAO	:= ' ' 
		::WSRETCONSPAR:_eRetConsPar[01]:CVENCTO		:= ' ' 
		::WSRETCONSPAR:_eRetConsPar[01]:NVLRTO		:=  0.00
		::WSRETCONSPAR:_eRetConsPar[01]:CCANC		:= ' ' 
		::WSRETCONSPAR:_eRetConsPar[01]:DCANC		:= ' ' 
		::WSRETCONSPAR:_eRetConsPar[01]:CUSRLOG		:= ' ' 
		::WSRETCONSPAR:_eRetConsPar[01]:CHRCANC		:= ' ' 
		::WSRETCONSPAR:_eRetConsPar[01]:CVLRBX		:= ' ' 
		::WSRETCONSPAR:_eRetConsPar[01]:DDTBX		:= ' ' 
		::WSRETCONSPAR:_eRetConsPar[01]:CUSRBX		:= ' ' 
		::WSRETCONSPAR:_eRetConsPar[01]:CVLRSLD		:= ' ' 
		::WSRETCONSPAR:_eRetConsPar[01]:CSTATP		:= ' ' 
		::WSRETCONSPAR:_eRetConsPar[01]:CSTATT		:= ' ' 
		::WSRETCONSPAR:_eRetConsPar[01]:CMSGRET 	:= ' '
		::WSRETCONSPAR:_eRetConsPar[01]:CRETORNO	:= '.F.'

		//Verificando se a entrada dados e uma estrutura
		if valtype(::WSCONSPARC:_eSolConsFat) == 'A'.AND. !Empty(::WSCONSPARC:_eSolConsFat)

			// Verificando se o CNPJ emitente existe
			_cCnpjEmit := Alltrim(::WSCONSPARC:_eSolConsFat[01]:CCNPJ_EMIT)	
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
				if Alltrim(SuperGetmv('AP_AUTWS', .T., 'April@2017' )) <> Alltrim(Decode64(::WSCONSPARC:_eSolConsFat[01]:CCHAVE ))

					_cMensRet := 'Error 999 - Token Invalido. Obtenha e Informe um Novo Token.'
					::WSRETCONSPAR:_eRetConsPar[01]:CCHAVE	:= ::WSCONSPARC:_eSolConsFat[01]:CCHAVE
					::WSRETCONSPAR:_eRetConsPar[01]:CFATURA := ::WSCONSPARC:_eSolConsFat[01]:CFATURA 
					::WSRETCONSPAR:_eRetConsPar[01]:CMSGRET := _cMensRet

				Else

					// Coletando informações.
					for _nIt := 1 to Len( ::WSCONSPARC:_eSolConsFat )

						// Verificando Identificador do cadastro
						_cFatura 	:= Alltrim(::WSCONSPARC:_eSolConsFat[_nIt]:CFATURA)
						_cParcela	:= Alltrim(::WSCONSPARC:_eSolConsFat[_nIt]:CPARCELA)
						lMsErroAuto := .T.
						_lGerarMov  := .T.
						_cMensRet   := ''

						// Caso diferente logar noutra empresa/filial
						if _cCnpjEmit#Alltrim(::WSCONSPARC:_eSolConsFat[_nIt]:CCNPJ_EMIT)

							_cCnpjEmit := Alltrim(::WSCONSPARC:_eSolConsFat[_nIt]:CCNPJ_EMIT)
							_nPos := ascan(_aEmpresas,{|x| Alltrim(x[03]) == _cCnpjEmit})

							if _nPos>0

								_cEmp 	   := _aEmpresas[_nPos][01]
								_cFil 	   := _aEmpresas[_nPos][02]

								// Limpa ambiente atual Abrindo próximo
								RpcClearEnv()
								RpcSetType(3)
								RpcSetEnv(_cEmp, _cFil)

								// Coleta informações da filial, unid neg, grupo etc.
								_aInfoFil := FWArrFilAtu(_cEmp, _cFil)

								// Grupo Empresa e Un Neg.
								_cGrpEmp := _aInfoFil[03]
								_cUnNeg  := _aInfoFil[04]

							Else

								// Sai do Loop erro de empresa
								_cMensRet := 'Error 900 - Empresa Emitente não existe no cadsatro Empresas do ERP Totvs.'
								_lGerarMov:= .F.

							Endif

						Endif

						// Padronizar tamanho campos
						_nTamC := TamSx3("A1_CGC")[1]
						_nTamFt:= TamSx3("Z1_FATURA")[1] 
						_nTamPa:= TamSx3("Z1_PARCELA")[1]
						_nTamTF:= TamSx3("Z2_TPFAT")[1]
						_nTamM := TamSx3("Z2_TPMOD")[1]

						//Localizando os itens para envio da consulta
						// Se de acordo validações gerar o registro.
						if _lGerarMov

							// Verificando se registro EXISTE. --> Z1_FILIAL+Z1_FATURA+Z1_PARCELA 
							dbSelectArea("SZ1")
							SZ1->( dbSetOrder(1) )

							if SZ1->( DbSeek( FwxFilial("SZ1") + Padr(_cFatura,_nTamFt) + Padr(_cParcela,_nTamPa) ) )

								// Posicionando cliente para retirada código Távola
								_cCnpj := if (Empty(SZ1->Z1_IDCGC),SZ1->Z1_IDCPF, SZ1->Z1_IDCGC)

								DbSelectArea("SA1")
								DbSetOrder(3)
								DbSeek( FwxFilial("SA1") + Padr(_cCnpj,_nTamC))  

								// Completando itens do retorno.
								dbSelectArea("SZ1")
								lMsErroAuto := .F.

								if Empty(::WSRETCONSPAR:_eRetConsPar[01]:CMSGRET)  

									// Grava mensagem de retorno
									::WSRETCONSPAR:_eRetConsPar[01]:= WSClassNew("_aRetConsPar")
									::WSRETCONSPAR:_eRetConsPar[01]:CCHAVE	 	:= ::WSCONSPARC:_eSolConsFat[01]:CCHAVE   
									::WSRETCONSPAR:_eRetConsPar[01]:CIDCLIENT 	:= SA1->A1_XIDTAVC 
									::WSRETCONSPAR:_eRetConsPar[01]:CFATURA		:= _cFatura
									::WSRETCONSPAR:_eRetConsPar[01]:CTPMOD		:= Alltrim(SZ1->Z1_TPMOD)  
									::WSRETCONSPAR:_eRetConsPar[01]:CTPFAT		:= Alltrim(SZ1->Z1_TPFAT)   
									::WSRETCONSPAR:_eRetConsPar[01]:CIDCGC		:= Alltrim(SZ1->Z1_IDCGC)  
									::WSRETCONSPAR:_eRetConsPar[01]:CIDCPF		:= Alltrim(SZ1->Z1_IDCPF)    
									::WSRETCONSPAR:_eRetConsPar[01]:CPARCELA	:= _cParcela
									::WSRETCONSPAR:_eRetConsPar[01]:CEMISSAO	:= DTOC(SZ1->Z1_EMISSAO)
									::WSRETCONSPAR:_eRetConsPar[01]:CVENCTO		:= DTOC(SZ1->Z1_VENCTO)
									::WSRETCONSPAR:_eRetConsPar[01]:NVLRTO		:= SZ1->Z1_VLRTO
									::WSRETCONSPAR:_eRetConsPar[01]:CCANC		:= Alltrim(SZ1->Z1_CANC)
									::WSRETCONSPAR:_eRetConsPar[01]:DCANC		:= DTOC(SZ1->Z1_DTCANC)
									::WSRETCONSPAR:_eRetConsPar[01]:CUSRLOG		:= Alltrim(SZ1->Z1_USERC)  
									::WSRETCONSPAR:_eRetConsPar[01]:CHRCANC		:= Alltrim(SZ1->Z1_HRCANC) 
									::WSRETCONSPAR:_eRetConsPar[01]:CVLRBX		:= Alltrim(SZ1->Z1_VLRBX)
									::WSRETCONSPAR:_eRetConsPar[01]:DDTBX		:= DTOC(SZ1->Z1_DTBX)   
									::WSRETCONSPAR:_eRetConsPar[01]:CUSRBX		:= ' ' 
									::WSRETCONSPAR:_eRetConsPar[01]:CVLRSLD		:= Alltrim(SZ1->Z1_SLDTIT) 
									::WSRETCONSPAR:_eRetConsPar[01]:CSTATP		:= Alltrim(SZ1->Z1_STATTP) 
									::WSRETCONSPAR:_eRetConsPar[01]:CSTATT		:= Alltrim(SZ1->Z1_STATT)
									::WSRETCONSPAR:_eRetConsPar[01]:CMSGRET 	:= ' '
									::WSRETCONSPAR:_eRetConsPar[01]:CRETORNO	:= cValToChar(!lMsErroAuto)

								Else

									// Cria e alimenta uma nova instancia do Retorno
									oRetSol :=  WSClassNew("_aRetConsPar")
									oRetSol:CCHAVE	 	:= ::WSCONSPARC:_eSolConsFat[01]:CCHAVE                      
									oRetSol:CIDCLIENT	:= SA1->A1_XIDTAVC                                                      
									oRetSol:CFATURA		:= _cFatura                                                  
									oRetSol:CTPMOD		:= Alltrim(SZ1->Z1_TPMOD)                                    
									oRetSol:CTPFAT		:= Alltrim(SZ1->Z1_TPFAT)                                    
									oRetSol:CIDCGC		:= Alltrim(SZ1->Z1_IDCGC)                                    
									oRetSol:CIDCPF		:= Alltrim(SZ1->Z1_IDCPF)                                    
									oRetSol:CPARCELA	:= _cParcela                                                 
									oRetSol:CEMISSAO	:= DTOC(SZ1->Z1_EMISSAO)                                     
									oRetSol:CVENCTO		:= DTOC(SZ1->Z1_VENCTO)                                      
									oRetSol:NVLRTO		:=  SZ1->Z1_VLRTO                                             
									oRetSol:CCANC		:= Alltrim(SZ1->Z1_CANC)                                     
									oRetSol:DCANC		:= DTOC(SZ1->Z1_DTCANC)                                      
									oRetSol:CUSRLOG		:= Alltrim(SZ1->Z1_USERC)                                    
									oRetSol:CHRCANC		:= Alltrim(SZ1->Z1_HRCANC)                                   
									oRetSol:CVLRBX		:= Alltrim(SZ1->Z1_VLRBX)                                    
									oRetSol:DDTBX		:= DTOC(SZ1->Z1_DTBX)                                        
									oRetSol:CUSRBX		:= ''                                                       
									oRetSol:CVLRSLD		:= Alltrim(SZ1->Z1_SLDTIT)                                   
									oRetSol:CSTATP		:= Alltrim(SZ1->Z1_STATTP)                                   
									oRetSol:CSTATT		:= Alltrim(SZ1->Z1_STATT)                                    
									oRetSol:CMSGRET 	:= ' '                                                       
									oRetSol:CRETORNO	:= cValToChar(!lMsErroAuto)

									AAdd( ::WSRETCONSPAR:_eRetConsPar, oRetSol )

								Endif

							ElseIF Empty(_cMensRet)

								_cMensRet := 'Error – 001 - Fatura não localizada.'
								::WSRETCONSPAR:_eRetConsPar[01]:CCHAVE	:= _cFatura + '-' + _cParcela
								::WSRETCONSPAR:_eRetConsPar[01]:CFATURA := ::WSCONSPARC:_eSolConsFat[_nIt]:CFATURA 
								::WSRETCONSPAR:_eRetConsPar[01]:CMSGRET := _cMensRet

							Endif

						Endif	 

					Next

				Endif

				//Reseta ambientes  
				//RpcClearEnv()

			Else

				_cMensRet := 'Error 900 - Empresa Emitente não existe no cadsatro Empresas do ERP Totvs.'
				::WSRETCONSPAR:_eRetConsPar[01]:CCHAVE  := _cCnpjEmit
				::WSRETCONSPAR:_eRetConsPar[01]:CMSGRET := _cMensRet

			Endif

		Else

			_cMensRet := 'Error 998 - Erro na estrutura de dados da solicitação.'
			::WSRETCONSPAR:_eRetConsPar[01]:CMSGRET	:= _cMensRet

		Endif


		RECOVER

		::WSRETCONSPAR:_eRetConsPar[01]:CMSGRET := 'Metodo: ' + Procname() + ', Erro: - ' +_oError:Description

	End Sequence	

Return .t.

/* {Protheus.doc} BolConf
Método de WebService para Confirmação Távora tabela no MIDDLEWARE ( Parcelas - SZ1 )
@type 		Método Fonte WSDL
@author 	Ivan de Oliveira
@since 		24/05/2017
@version 	1.0
@return 	${Lógico}, ${.t.}
*/

WSMETHOD BolConf WSRECEIVE WSCONFTAVORA WSSEND WSRETCONFTAV WSSERVICE WsAprilParcelas

	Local _cEmp 	:= _cFil := _cGrpEmp := _cUnNeg := ''
	Local _nIt  	:= 0
	Local _nOpc 	:= 0
	Local _cMensRet := ''
	Local _bError  	:= { |e| _oError := e , Break(e) }
	Local _aEmpresas:= {}
	Local _bErrBlk  := ErrorBlock( _bError )

	Private lMsErroAuto := .f. 

	// Tratamentos de erros
	Begin Sequence

		// Montando ESTRUTURA retorno
		::WSRETCONFTAV:_eSolRetUpd := Array(1)

		::WSRETCONFTAV:_eSolRetUpd[01]:= WSClassNew("_aSolRetUpd")
		::WSRETCONFTAV:_eSolRetUpd[01]:CCHAVE   := 'Erro Estrutural'   
		::WSRETCONFTAV:_eSolRetUpd[01]:CMSGRET  := ' '
		::WSRETCONFTAV:_eSolRetUpd[01]:CRETORNO := '.F.'

		//Verificando se a entrada dados e uma estrutura
		if valtype(::WSCONFTAVORA:_eSolConfPar) == 'A' .and. !Empty(::WSCONFTAVORA:_eSolConfPar)

			// Verificando se o CNPJ emitente existe
			_cCnpjEmit := Alltrim(::WSCONFTAVORA:_eSolConfPar[01]:CCNPJ_EMIT)
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
				if Alltrim(SuperGetmv('AP_AUTWS', .T., 'April@2017' )) <> Alltrim(Decode64(::WSCONFTAVORA:_eSolConfPar[01]:CCHAVE ))

					_cMensRet := 'Error 999 - Token Invalido. Obtenha e Informe um Novo Token.'
					::WSRETCONFTAV:_eSolRetUpd[01]:CCHAVE  := ::WSCONFTAVORA:_eSolConfPar[01]:CFATURA
					::WSRETCONFTAV:_eSolRetUpd[01]:CMSGRET := _cMensRet

				Else

					// Coletando informações.
					for _nIt := 1 to Len( ::WSCONFTAVORA:_eSolConfPar )

						// Verificando Identificador do cadastro
						_cFatura 	:= Alltrim(::WSCONFTAVORA:_eSolConfPar[_nIt]:CFATURA)
						_cStatus	:= upper(Alltrim(::WSCONFTAVORA:_eSolConfPar[_nIt]:CSTATT))
						lMsErroAuto := .T.
						_lGerarMov  := .T.

						// Caso diferente logar noutra empresa/filial
						if _cCnpjEmit#Alltrim(::WSCONFTAVORA:_eSolConfPar[_nIt]:CCNPJ_EMIT)

							_cCnpjEmit := Alltrim(::WSCONFTAVORA:_eSolConfPar[_nIt]:CCNPJ_EMIT)
							_nPos := ascan(_aEmpresas,{|x| Alltrim(x[03]) == _cCnpjEmit})

							if _nPos>0

								_cEmp 	   := _aEmpresas[_nPos][01]
								_cFil 	   := _aEmpresas[_nPos][02]

								// Limpa ambiente atual Abrindo próximo
								RpcClearEnv()
								RpcSetType(3)
								RpcSetEnv(_cEmp, _cFil)

								// Coleta informações da filial, unid neg, grupo etc.
								_aInfoFil := FWArrFilAtu(_cEmp, _cFil)

								// Grupo Empresa e Un Neg.
								_cGrpEmp := _aInfoFil[03]
								_cUnNeg  := _aInfoFil[04]

							Else

								// Sai do Loop erro de empresa
								_cMensRet := 'Error 900 - Empresa Emitente não existe no cadsatro Empresas do ERP Totvs.'
								_lGerarMov:= .F.

							Endif

						Endif

						// Padronizar tamanho campos
						_nTamC := TAMSX3("A1_CGC")[1]
						_nTamFt:= TAMSX3("Z3_FATURA")[1] 
						_nTamPa:= TAMSX3("Z3_PARCELA")[1] 

						// Se de acordo validações gerar o registro.
						if _lGerarMov

							// Verificando se registro EXISTE. --> Z1_FILIAL+Z1_FATURA+Z1_PARCELA 
							dbSelectArea("SZ1")
							SZ1->( dbSetOrder(1) )

							if SZ1->( DbSeek( FwxFilial("SZ1") + Padr(_cFatura,_nTamFt) ) )

								_cIndice := SZ1->Z1_FILIAL  + Padr(_cFatura,_nTamFt)  
								While SZ1->( !EOF() ) .and. ( SZ1->Z1_FILIAL + SZ1->Z1_FATURA ==  _cIndice )

									_cMensRet := 'Error – 004 – Status já atualizado.'
									if SZ1->Z1_STATT <> 'S'

										if Reclock("SZ1", .F.)

											lMsErroAuto   := .F.
											SZ1->Z1_STATT := _cStatus
											Msunlock()

											_cMensRet := 'Ok – 001 – Processo registrado com Sucesso.'

										Else

											_cMensRet := 'Error 003 - Ocorreu um erro na tentativa de bloqueio registro tabela SZ1(Erp-Totvs).'

										Endif

									Endif

									SZ1->( dbSkip() )

								Enddo

							Else

								_cMensRet := 'Error – 002 - Fatura não localizada.' 

							Endif

						Endif

						// Completando itens do retorno.
						if Empty(::WSRETCONFTAV:_eSolRetUpd[01]:CMSGRET)  

							// Grava mensagem de retorno
							::WSRETCONFTAV:_eSolRetUpd[01]:CCHAVE  := Alltrim(::WSCONFTAVORA:_eSolConfPar[_nIt]:CFATURA)
							::WSRETCONFTAV:_eSolRetUpd[01]:CMSGRET := _cMensRet
							::WSRETCONFTAV:_eSolRetUpd[01]:CRETORNO:= cValToChar(!lMsErroAuto)

						Else

							// Cria e alimenta uma nova instancia do Retorno
							oRetSol :=  WSClassNew("_aSolRetUpd")

							oRetSol:CCHAVE  := Alltrim(::WSCONFTAVORA:_eSolConfPar[_nIt]:CFATURA)  
							oRetSol:CMSGRET := _cMensRet
							oRetSol:CRETORNO:= cValToChar(!lMsErroAuto)

							AAdd( ::WSRETCONFTAV:_eSolRetUpd, oRetSol )

						Endif

					Next

				Endif

				//Reseta ambientes  
				//RpcClearEnv()

			Else

				_cMensRet := 'Error 900 - Empresa Emitente não existe no cadsatro Empresas do ERP Totvs.'
				::WSRETCONFTAV:_eSolRetUpd[01]:CCHAVE  := _cCnpjEmit
				::WSRETCONFTAV:_eSolRetUpd[01]:CMSGRET := _cMensRet

			Endif

		Else

			_cMensRet := 'Error 998 - Erro na estrutura de dados da solicitação.'
			::WSRETCONFTAV:_eSolRetUpd[01]:CMSGRET := _cMensRet

		Endif


		RECOVER

		::WSRETCONFTAV:_eSolRetUpd[01]:CMSGRET := 'Metodo: ' + Procname() + ', Erro: - ' + _oError:Description 

	End Sequence


Return .T.


/* {Protheus.doc} Atualiza Nosso Numero
Método de WebService para Confirmação Távora tabela no MIDDLEWARE ( Parcelas - SZ1 )
@type 		Método Fonte WSDL
@author 	Ivan de Oliveira
@since 		24/05/2017
@version 	1.0
@return 	${Lógico}, ${.t.}
*/

WSMETHOD BolAtu WSRECEIVE WSNNTAVORA WSSEND WSRETNNTAV WSSERVICE WsAprilParcelas

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
		::WSRETNNTAV:_eRetSolNN := Array(1)

		::WSRETNNTAV:_eRetSolNN[01]:= WSClassNew("_aRetNN")
		::WSRETNNTAV:_eRetSolNN[01]:CCHAVE   := 'Erro Estrutural'   
		::WSRETNNTAV:_eRetSolNN[01]:CFATURA  := ' '
		::WSRETNNTAV:_eRetSolNN[01]:CMSGRET  := ' '
		::WSRETNNTAV:_eRetSolNN[01]:CRETORNO := '.F.'

		//Verificando se a entrada dados e uma estrutura
		if valtype(::WSNNTAVORA:_eSolNN) == 'A' .and. !Empty(::WSNNTAVORA:_eSolNN)

			// Verificando se o CNPJ emitente existe
			_cCnpjEmit := Alltrim(::WSNNTAVORA:_eSolNN[01]:CCNPJ_EMIT)	
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
				if Alltrim(SuperGetmv('AP_AUTWS', .T., 'April@2017' )) <> Alltrim(Decode64(::WSNNTAVORA:_eSolNN[01]:CCHAVE ))//'April@2017' <> Alltrim(WSNNTAVORA:_eSolNN[01]:CCHAVE )//Alltrim(SuperGetmv('AP_AUTWS', .T., 'April@2017' ))


					_cMensRet := 'Error 999 - Token Invalido. Obtenha e Informe um Novo Token.'
					::WSRETNNTAV:_eRetSolNN[01]:CCHAVE  := ::WSNNTAVORA:_eSolNN[01]:CCHAVE
					::WSRETNNTAV:_eRetSolNN[01]:CFATURA := ::WSNNTAVORA:_eSolNN[01]:CFATURA 
					::WSRETNNTAV:_eRetSolNN[01]:CMSGRET := _cMensRet

				Else

					// Coletando informações.
					for _nIt := 1 to Len( ::WSNNTAVORA:_eSolNN )

						// Verificando Identificador do cadastro
						_cFatura 	:= Alltrim(::WSNNTAVORA:_eSolNN[_nIt]:CFATURA)
						_cParcela     := Alltrim(::WSNNTAVORA:_eSolNN[_nIt]:CPARCELA)
						_cNNumero     := Alltrim(::WSNNTAVORA:_eSolNN[_nIt]:NOSSONUMERO)
						//_cVldCgcCpf := if (Empty(_cCnpj),_cCPF, _cCnpj)

						// Caso diferente logar noutra empresa/filial
						if _cCnpjEmit#Alltrim(::WSNNTAVORA:_eSolNN[_nIt]:CCNPJ_EMIT)

							_cCnpjEmit := Alltrim(::WSNNTAVORA:_eSolNN[_nIt]:CCNPJ_EMIT)
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
						_nTamC := TAMSX3("Z1_PARCELA")[1]
						_nTamP := TAMSX3("Z1_FATURA")[1]



						lMsErroAuto := .T.
						_lGerarMov  := .f.

						// Verificando numerações de fatura
						if empty(_cFatura)

							_cMensRet := 'Error – 006 - Número de Fatura inválido.'
							_cChave := Alltrim(::WSNNTAVORA:_eSolNN[_nIt]:CFATURA)

						Else

							_lGerarMov := .T.

						Endif

					


			// Se de acordo validações gerar o registro.
			if _lGerarMov

				_cChave := Alltrim(::WSNNTAVORA:_eSolNN[_nIt]:CFATURA)

				dbSelectArea("SZ1")
				SZ1->( dbSetOrder(1) )

				if SZ1->( DbSeek( FwxFilial("SZ1") + Padr(_cFatura,_nTamP) + Padr(_cParcela,_nTamC) ) )

					if Reclock("SZ1", .F.)
					  
					  SZ1->Z1_NUMBCO := _cNNumero
					  SZ1->Z1_STATTP := ''
					  SZ1->(Msunlock())

						// Retorno do processo.
						_cMensRet   := 'Ok – 001 – Processo registrado com Sucesso.'
						lMsErroAuto := .F.

					Else

						_cMensRet := 'Error 005 - Ocorreu um erro na tentativa de bloqueio registro tabela SZ1(Erp-Totvs).' 

					Endif

				Else

					_cMensRet := 'Error 003 - Registro nao encontrado.' 

				Endif

			Endif

			// Completando itens do retorno.
			if Empty(::WSRETNNTAV:_eRetSolNN[01]:CMSGRET)  

				// Grava mensagem de retorno
				::WSRETNNTAV:_eRetSolNN[01]:CCHAVE   := _cChave
				::WSRETNNTAV:_eRetSolNN[01]:CFATURA := Alltrim(::WSNNTAVORA:_eSolNN[_nIt]:CFATURA)
				::WSRETNNTAV:_eRetSolNN[01]:CMSGRET  := _cMensRet
				::WSRETNNTAV:_eRetSolNN[01]:CRETORNO := cValToChar(!lMsErroAuto)

			Else

				// Cria e alimenta uma nova instancia do Retorno
				oRetSol :=  WSClassNew("_aRetComPre")

				oRetSol:CCHAVE   := _cChave  
				oRetSol:CFATURA := Alltrim(::WSNNTAVORA:_eSolNN[_nIt]:CFATURA) 
				oRetSol:CMSGRET  := _cMensRet
				oRetSol:CRETORNO := cValToChar(!lMsErroAuto)

				AAdd( ::WSRETNNTAV:_eRetSolNN, oRetSol )

			Endif

		Next 

	Endif


	Else

		_cMensRet := 'Error 900 - Empresa Emitente não existe no cadsatro Empresas do ERP Totvs.'
		::WSRETNNTAV:_eRetSolNN[01]:CCHAVE  := _cCnpjEmit
		::WSRETNNTAV:_eRetSolNN[01]:CMSGRET := _cMensRet

	Endif 

	Else

		_cMensRet := 'Error 998 - Erro na estrutura de dados da solicitação.'
		::WSRETNNTAV:_eRetSolNN[01]:CMSGRET := _cMensRet

	Endif

	End Sequence

	ErrorBlock(_oError)

	if !empty(_cErroFont)
		::WSRETNNTAV:_eRetSolNN[01]:CMSGRET := 'Descr.Erro Proc.: ' + _cLinErro + '|' +  _cErroFont
	Endif

	//Reseta ambientes 
	//RpcClearEnv() 

Return .T.