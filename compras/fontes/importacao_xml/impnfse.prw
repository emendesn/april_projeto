#include "protheus.ch"                                                                                                          
#include "totvs.ch"
#include "rwmake.ch"
#include "fileio.ch"

#Define cEnter Chr(13) + Chr(10)

//#################
//# Programa      # IMPNFSE
//# Data          # 09/10/2017
//# Descrição     # Rotina para importação de NFSE
//# Desenvolvedor # Sergio Compain
//# Empresa       # Totvs Nacoes Unidas
//# Linguagem     # eAdvpl     
//# Versão        # 12
//# Sistema       # Protheus
//# Módulo        # Financeiro
//# Tabelas       # "SF1", "SD1"
//# Observação    #  
//#===============#
//# Atualizações  # 
//#===============#
//#################

STATIC cAdmDir  //usado no SXB DIR2


User Function IMPNFSE()

	//--< VariÃ¡veis >-----------------------------------------------------------------------
	Local	lSchedule	:= .F.
	Local 	cFunction	:= "IMPNFSE"
	Local	cTitle		:= "Importação XMls"
	Local	cObs		:= ""
	Local	oProcess	:= Nil

	Private cPerg		:= PadR(cFunction, 10)

	Private aArqXMl 	:= {}
	Private cStartLido	:= ""
	Private cStartInval	:= ""
	Private cGetPath 	:= ""

	//--< Procedimentos >-------------------------------------------------------------------
	lSchedule 	:= FWGetRunSchedule()
	ValidPerg()

	If !lSchedule 
		cObs := "Essa rotina tem a finalidade de realizar a importação dos XMLs de Notas Fiscais"
		oProcess := TNewProcess():New(cFunction, cTitle, {|oSelf, lSchedule | U_IMPNFSEPro(oSelf, lSchedule)}, cObs, cPerg)
		Controle()
	Else
		ConOut(OEMToANSI(FWTimeStamp(2) + " * * * | IMPNFSE : Importação XMls ------> Inicio... "))
		U_IMPNFSEPro(Nil, lSchedule)
		U_OkProcNf( Nil, .t. )
		ConOut(OEMToANSI(FWTimeStamp(2) + " * * * | IMPNFSE: Importação XMls ------> Fim! "))
	EndIf


Return Nil

User Function IMPNFSEPro(oSelf, lSchedule)

	Local nY		:= 0
	Local nArq		:= 0
	Local nReg

	Default lSchedule	:= .F.

	//--< Procedimentos >-------------------------------------------------------------------
	If !lSchedule  
		oSelf:SaveLog(" * * * Inicio do Processamento * * * ")
		cGetPath 	:= alltrim(mv_par01)
		aArqXMl 	:= DIRECTORY(cGetPath +"\*.*")	
		nArq 		:= len(aArqXMl)
		oSelf:SetRegua1(nArq)
		oSelf:SetRegua2(nArq)
		cStartLido	:= Trim(cGetPath)+"Processados\"
		cStartInval	:= Trim(cGetPath)+"Invalidas\"
	Else
		cGetPath 	:= "\impnfse\"
		aArqXMl 	:= DIRECTORY(cGetPath +"\*.*")	
		nArq 		:= len(aArqXMl)
		cStartLido	:= Trim(cGetPath)+"Processados\"
		cStartInval	:= Trim(cGetPath)+"Invalidas\"
	EndIf

	MakeDir(cStartLido) //CRIA DIRETORIO ARQUIVOS IMPORTADOS
	MakeDir(cStartInval) //CRIA DIRETORIO invalidas

	For nY := 1 to nArq
		If !lSchedule 
			oSelf:IncRegua1("Importando o Arquivo : " + aArqXMl[nY][1] )
			oSelf:IncRegua2("Processando o Arquivo : " + CValToChar(nY) + " de " + CValToChar(nArq))
		Else
			ConOut(OEMToANSI(FWTimeStamp(2) + "Importando o Arquivo : " + aArqXMl[nY][1]))
		EndIf

		fLerXml(lSchedule, cGetPath , aArqXMl[nY][1])

	Next nY

Return()

Static Function	fLerXml(lSchedule , cGetPath , cArqXml)

	Local cError	:= ""
	Local cWarning	:= ""
	Local cTipo 	:= ""
	Local cNumNf	:=	""
	Local nValor 	:=	0			
	Local cPrestador:= ""
	Local cTomador 	:= ""
	Local cDescri 	:=	""			
	Local cEspeci	:= "NFS"
	Local cStatus	:= ""
	Local cObs		:= ""
	Local cSerie	:= ""
	Local cChvNfe	:= ""
	Local cFilOri	:= ""
	Local cCodFor	:= ""
	Local cNomFor	:= ""
	Local nY		:= 0
	Local lSPRJ		:= .f.
	Local cItens	:= ""
	Local cEnd		:= ""
	Local cCodMun	:= ""
	Local cEst		:= ""
	Local cNomFan	:= ""  
	Local cIss := ""
	Local nAliqIss := 0
	Local lCadFor := .F.	
	Local lProd	  := .F.	

	Private oXml
	Private cCodPro := "" //SuperGetmv("FS_NFSPRO",.F.,"ST_06912")

	If !lSchedule
		nHdl    := fOpen(cGetPath+"\"+cArqXml,0)
		If nHdl == -1
			If !Empty(cArqXml)
				cError := "Erro ao abrir o arquivo" 
			Endif
		Else
			nTamFile := fSeek(nHdl,0,2)
			fSeek(nHdl,0,0)
			cBuffer  := Space(nTamFile)                // Variavel para criacao da linha do registro para leitura
			nBtLidos := fRead(nHdl,@cBuffer,nTamFile)  // Leitura  do arquivo XML
			fClose(nHdl)
			oXml := XmlParser(cBuffer,"_",@cWarning,@cError)
		Endif
	Else 
		oXml := XmlParserFile(cGetPath+cArqXml,"_",@cError,@cWarning)
	EndIf

	If !Empty(cError) //erro ao abrir o xml
		GravaErro(cArqXml,cError,"9","","","",0,cTod(""),"","",.t.) 
	Else
		If Type("oXml:_ns4_Nfse") <> "U"    //ginfes
			cTipo 	:= "GINFES"
			cNumNf	:=	oXml:_ns4_Nfse:_ns4_InfNfse:_ns4_Numero:Text
			dDtEmis	:=	oXml:_ns4_Nfse:_ns4_InfNfse:_ns4_DataEmissao:Text
			dDtEmis	:= CTOD( Substr(dDtEmis,9,2) + "/" + SubsTr(dDtEmis,6,2) + "/" + Substr(dDtEmis,1,4))
			nValor 	:=	val(oXml:_ns4_Nfse:_ns4_InfNfse:_ns4_Servico:_ns4_Valores:_ns4_ValorServicos:Text)
			cCodPro := oXml:_NS4_NFSE:_NS4_INFNFSE:_NS4_SERVICO:_NS4_ITEMLISTASERVICO:TEXT

			If Type("oXml:_ns4_Nfse:_ns4_InfNfse:_ns4_PrestadorServico:_ns4_IdentificacaoPrestador:_ns4_Cnpj") <> "U"
				cPrestador 	:= oXml:_ns4_Nfse:_ns4_InfNfse:_ns4_PrestadorServico:_ns4_IdentificacaoPrestador:_ns4_Cnpj:Text
			ElseIf Type("oXml:_ns4_Nfse:_ns4_InfNfse:_ns4_PrestadorServico:_ns4_IdentificacaoPrestador:_ns4_Cpf") <> "U"
				cPrestador 	:= oXml:_ns4_Nfse:_ns4_InfNfse:_ns4_PrestadorServico:_ns4_IdentificacaoPrestador:_ns4_Cpf:Text
			EndIf
			If Type("oXml:_ns4_Nfse:_ns4_InfNfse:_ns4_TomadorServico:_ns4_IdentificacaoTomador:_ns4_CpfCnpj:_ns4_Cnpj") <> "U"
				cTomador 	:= oXml:_ns4_Nfse:_ns4_InfNfse:_ns4_TomadorServico:_ns4_IdentificacaoTomador:_ns4_CpfCnpj:_ns4_Cnpj:Text
			ElseIf Type("oXml:_ns4_Nfse:_ns4_InfNfse:_ns4_TomadorServico:_ns4_IdentificacaoTomador:_ns4_CpfCnpj:_ns4_Cpf") <> "U"
				cTomador 	:= oXml:_ns4_Nfse:_ns4_InfNfse:_ns4_TomadorServico:_ns4_IdentificacaoTomador:_ns4_CpfCnpj:_ns4_Cpf:Text
			EndIf
			cNomFor		:= oXml:_ns4_Nfse:_ns4_InfNfse:_ns4_PrestadorServico:_ns4_RazaoSocial:Text
			cDescri 	:= Alltrim(oXml:_ns4_Nfse:_ns4_InfNfse:_ns4_Servico:_ns4_Discriminacao:Text)			
			If Type("oXml:_NS4_NFSE:_NS4_INFNFSE:_NS4_PRESTADORSERVICO:_NS4_NOMEFANTASIA:TEXT") <> "U"
				cNomFan		:= oXml:_NS4_NFSE:_NS4_INFNFSE:_NS4_PRESTADORSERVICO:_NS4_NOMEFANTASIA:TEXT					   
			Else
				cNomFan		:= oXml:_ns4_Nfse:_ns4_InfNfse:_ns4_PrestadorServico:_ns4_RazaoSocial:Text
			EndIf
			cEnd		:= oXml:_ns4_Nfse:_ns4_InfNfse:_ns4_PrestadorServico:_ns4_Endereco:_ns4_Endereco:Text    
			cCodMun		:= oXml:_ns4_Nfse:_ns4_InfNfse:_ns4_PrestadorServico:_ns4_Endereco:_ns4_CodigoMunicipio:Text  
			cEst		:= oXml:_ns4_Nfse:_ns4_InfNfse:_ns4_PrestadorServico:_ns4_Endereco:_ns4_UF:Text    
			cEspeci		:= "NFS"
			cStatus		:= "1"
			cObs		:= ""
			cSerie		:= ""
			cChvNFE		:= oXml:_ns4_Nfse:_ns4_InfNfse:_ns4_CodigoVerificacao:Text
			cCodIss		:= oXml:_NS4_NFSE:_NS4_INFNFSE:_NS4_SERVICO:_NS4_ITEMLISTASERVICO:TEXT
			nAliqIss 	:= oXml:_NS4_NFSE:_NS4_INFNFSE:_NS4_SERVICO:_NS4_VALORES:_NS4_ISSRETIDO:TEXT

			lProd := VldProd(oXml:_NS4_NFSE:_NS4_INFNFSE,cPrestador,@cObs,cIss, nAliqIss,cTipo,cNumNf,dDtEmis,nValor,cTomador,cDescri,cArqXMl,cEspeci,cStatus,cSerie,cChvNFE,cFilOri,cCodFor,cNomFor,cItens)

		ElseIf Type("oXml:_CompNfse:_Nfse:_InfNfse") <> "U"    //betha
			cTipo 	:= "BETHA"
			cNumNf	:= oXml:_CompNfse:_Nfse:_InfNfse:_Numero:Text
			dDtEmis	:= oXml:_CompNfse:_Nfse:_InfNfse:_DataEmissao:Text
			dDtEmis	:= CTOD( Substr(dDtEmis,9,2) + "/" + SubsTr(dDtEmis,6,2) + "/" + Substr(dDtEmis,1,4))
			nValor	:= Val(oXml:_CompNfse:_Nfse:_InfNfse:_ValoresNfse:_ValorLiquidoNfse:Text)
			cCodPro := oXml:_COMPNFSE:_NFSE:_INFNFSE:_DECLARACAOPRESTACAOSERVICO:_INFDECLARACAOPRESTACAOSERVICO:_SERVICO:_ITEMLISTASERVICO:TEXT

			If Type("oXml:_CompNfse:_Nfse:_InfNfse:_PrestadorServico:_IdentificacaoPrestador:_CpfCnpj:_Cnpj") <> "U"
				cPresTador	:= oXml:_CompNfse:_Nfse:_InfNfse:_PrestadorServico:_IdentificacaoPrestador:_CpfCnpj:_Cnpj:Text
			ElseIf Type("oXml:_CompNfse:_Nfse:_InfNfse:_PrestadorServico:_IdentificacaoPrestador:_CpfCnpj:_Cpf") <> "U"
				cPresTador	:= oXml:_CompNfse:_Nfse:_InfNfse:_PrestadorServico:_IdentificacaoPrestador:_CpfCnpj:_Cpf:Text
			EndIf
			If Type("oXml:_CompNfse:_Nfse:_InfNfse:_DeclaracaoPrestacaoServico:_InfDeclaracaoPrestacaoServico:_Tomador:_IdentificacaoTomador:_CpfCnpj:_Cnpj") <> "U"
				cTomador	:= oXml:_CompNfse:_Nfse:_InfNfse:_DeclaracaoPrestacaoServico:_InfDeclaracaoPrestacaoServico:_Tomador:_IdentificacaoTomador:_CpfCnpj:_Cnpj:Text
			ElseIf Type("oXml:_CompNfse:_Nfse:_InfNfse:_DeclaracaoPrestacaoServico:_InfDeclaracaoPrestacaoServico:_Tomador:_IdentificacaoTomador:_CpfCnpj:_Cpf") <> "U"
				cTomador	:= oXml:_CompNfse:_Nfse:_InfNfse:_DeclaracaoPrestacaoServico:_InfDeclaracaoPrestacaoServico:_Tomador:_IdentificacaoTomador:_CpfCnpj:_Cpf:Text
			EndIf
			cNomFor		:= oXml:_CompNfse:_Nfse:_InfNfse:_PrestadorServico:_RazaoSocial:Text
			cDescri		:= AllTrim(oXml:_CompNfse:_Nfse:_InfNfse:_DeclaracaoPrestacaoServico:_InfDeclaracaoPrestacaoServico:_Servico:_Discriminacao:Text)
			If Type("oXml:_CompNfse:_Nfse:_InfNfse:_PrestadorServico:_NomeFantasia:Text") <> "U"
				cNomFan		:= oXml:_CompNfse:_Nfse:_InfNfse:_PrestadorServico:_NomeFantasia:Text      
			Else
				cNomFan		:= oXml:_CompNfse:_Nfse:_InfNfse:_PrestadorServico:_RazaoSocial:Text
			EndIf

			cEnd		:= oXml:_CompNfse:_Nfse:_InfNfse:_PrestadorServico:_ENDERECO:_ENDERECO:text		
			cCodMun		:= oXml:_CompNfse:_Nfse:_InfNfse:_PrestadorServico:_ENDERECO:_CODIGOMUNICIPIO:TEXT
			cEst		:= oXml:_CompNfse:_Nfse:_InfNfse:_PrestadorServico:_ENDERECO:_UF:TEXT
			cEspeci		:= "NFS"
			cStatus		:= "1"
			cObs		:= ""
			cSerie		:= ""
			cChvNFE		:= oXml:_CompNfse:_Nfse:_InfNfse:_CodigoVerificacao:Text
			If Type("oXml:_CompNfse:_NfseCancelamento") <> "U"  //nota cancelada 
				cStatus		:= "2"
				cObs		:= "Nota Cancelada - "+oXml:_CompNfse:_NfseCancelamento:_Confirmacao:_DataHora:Text
			Endif
		ElseIf Type("oXml:_NFEPROC:_NFE:_INFNFE") <> "U" //Danfe  
			cNumNf		:=	oXml:_NFEPROC:_NFE:_INFNFE:_IDE:_NNF:TEXT 
			cSerie		:= oXml:_NFEPROC:_NFE:_INFNFE:_IDE:_SERIE:TEXT
			dDtEmis		:= oXml:_NFEPROC:_NFE:_INFNFE:_IDE:_DHEMI:TEXT
			dDtEmis		:= CTOD( Substr(dDtEmis,9,2) + "/" + SubsTr(dDtEmis,6,2) + "/" + Substr(dDtEmis,1,4))
			nValor		:= Val(oXml:_NFEPROC:_NFE:_INFNFE:_TOTAL:_ICMSTot:_vNF:Text)	

			If Type("oXml:_NFEPROC:_NFE:_INFNFE:_EMIT:_CNPJ") <> "U"  
				cPresTador	:= oXml:_NFEPROC:_NFE:_INFNFE:_EMIT:_CNPJ:TEXT   
			ElseIf Type("oXml:_NFEPROC:_NFE:_INFNFE:_EMIT:_CPF") <> "U"
				cPresTador	:= oXml:_NFEPROC:_NFE:_INFNFE:_EMIT:_CPF:TEXT
			EndIf			
			If Type("oXml:_NFEPROC:_NFE:_INFNFE:_DEST:_CNPJ") <> "U" 
				cTomador	:= oXml:_NFEPROC:_NFE:_INFNFE:_DEST:_CNPJ:TEXT
			ElseIf Type("oXml:_NFEPROC:_NFE:_INFNFE:_DEST:_CPF") <> "U"
				cTomador	:= oXml:_NFEPROC:_NFE:_INFNFE:_DEST:_CPF:TEXT
			EndIf			
			cNomFor		:= oXml:_NFEPROC:_NFE:_INFNFE:_EMIT:_XNOME:Text 

			If Type("oXml:_NFEPROC:_NFE:_INFNFE:_EMIT:_xFant:Text ") <> "U"
				cNomFan		:= oXml:_NFEPROC:_NFE:_INFNFE:_EMIT:_xFant:Text 
			Else
				cNomFan		:= oXml:_NFEPROC:_NFE:_INFNFE:_EMIT:_XNOME:Text  
			EndIf
			cEnd		:= oXml:_NFEPROC:_NFE:_INFNFE:_EMIT:_ENDEREMIT:_XLGR:TEXT
			cCodMun		:= oXml:_NFEPROC:_NFE:_INFNFE:_EMIT:_ENDEREMIT:_CMUN:TEXT
			cEst		:= oXml:_NFEPROC:_NFE:_INFNFE:_EMIT:_ENDEREMIT:_UF:TEXT
			cChvNFE		:= Substr(oXml:_NFEPROC:_NFE:_INFNFE:_ID:TEXT,4,44)
			cEspeci		:= "SPED"
			cStatus		:= "1"
			cObs			:= ""
			If ValType(oXml:_NFEPROC:_NFE:_INFNFE:_DET) == "O"
				XmlNode2Arr(oXml:_NFEPROC:_NFE:_INFNFE:_DET, "_DET")
			EndIf
			If val(oXml:_NFEPROC:_NFE:_INFNFE:_TOTAL:_ICMSTot:_vProd:Text) = 0 //serviços
				cTipo 	:= "DANFE_S"
				cDescri	:= AllTrim(oXml:_NFEPROC:_NFE:_INFNFE:_DET[1]:_PROD:_XPROD:TEXT)
			Else //nota de produtos
				cTipo 	:= "DANFE_P"
				cCodPro	:= oXml:_NFEPROC:_NFE:_INFNFE:_DET[1]:_PROD:_CPROD:TEXT //cCodPro	:= "DIVERSOS"
				cDescri	:= AllTrim(oXml:_NFEPROC:_NFE:_INFNFE:_DET[1]:_PROD:_XPROD:TEXT) //"PRODUTOS DIVERSOS"
				cItens	:= MontaJItens(oXml:_NFEPROC:_NFE:_INFNFE:_DET,cPrestador,@cObs)
			EndIf
		ElseIf Type("oXml:_NFe:_ChaveNFe") <> "U"    //Paulista
			cTipo 		:= "PAULISTA"
			cNumNf		:=	oXml:_NFe:_ChaveNFe:_NumeroNFe:Text
			cSerie		:= ""
			dDtEmis		:=	oXml:_NFe:_DataEmissaoNFe:Text
			dDtEmis		:= CTOD( Substr(dDtEmis,9,2) + "/" + SubsTr(dDtEmis,6,2) + "/" + Substr(dDtEmis,1,4))
			nValor		:= Val(oXml:_NFe:_ValorServicos:Text)
			If Type("oXml:_NFe:_CPFCNPJPrestador:_CNPJ") <> "U"   
				cPresTador	:= oXml:_NFe:_CPFCNPJPrestador:_CNPJ:TEXT
			ElseIf Type("oXml:_NFe:_CPFCNPJPrestador:_CPF") <> "U"
				cPresTador	:= oXml:_NFe:_CPFCNPJPrestador:_CPF:TEXT
			EndIf			
			If Type("oXml:_NFe:_CPFCNPJTomador:_CNPJ") <> "U"
				cTomador	:= oXml:_NFe:_CPFCNPJTomador:_CNPJ:TEXT
			ElseIf Type("oXml:_NFe:_CPFCNPJTomador:_CPF") <> "U"
				cTomador	:= oXml:_NFe:_CPFCNPJTomador:_CPF:TEXT
			EndIf			

			cCodPro := oXml:_NFe:_CodigoServico:TEXT
			cNomFor := oXml:_NFe:_RazaoSocialPrestador:TEXT

			If Type("oXml:_NFe:_NomeFantasia:TEXT  ") <> "U"
				cNomFan		:= oXml:_NFe:_NomeFantasia:TEXT  
			Else
				cNomFan		:= oXml:_NFe:_RazaoSocialPrestador:TEXT
			EndIF

			cEnd 	:= oXml:_NFe:_ENDERECOPRESTADOR:_LOGRADOURO:TEXT
			cEst 	:= oXml:_NFe:_ENDERECOPRESTADOR:_UF:TEXT
			cCodMun	:= oXml:_NFe:_ENDERECOPRESTADOR:_CIDADE:TEXT
			cDescri := Alltrim(oXml:_NFe:_Discriminacao:Text)			
			cEspeci	:= "NFS"
			cStatus	:= "1"
			cObs	:= ""
			cSerie	:= ""
			cChvNFE	:= oXml:_NFe:_ChaveNFe:_CodigoVerificacao:Text             
			//		lProd	:= VldProd(oXml:_NFEPROC:_NFE:_INFNFE:_DET,cPrestador,@cObs,cIss, nAliqIss,cTipo,cNumNf,dDtEmis,nValor,cTomador,cDescri,cArqXMl,cEspeci,cStatus,cSerie,cChvNFE,cFilOri,cCodFor,cNomFor,cItens,oItens,cIss, nAliqIss)

		ElseIf Type("oXml:_RetornoConsulta:_Cabecalho:_Sucesso") <> "U" //Paulistana
			If Upper(Alltrim(oXml:_RetornoConsulta:_Cabecalho:_Sucesso:Text)) = "TRUE"
				If Type("oXml:_RetornoConsulta:_Nfe") <> "U"
					lSPRJ := .t.
					For nY := 1 to len(oxml:_RetornoConsulta:_nfe)
						cTipo 	:= "PAULISTANA"
						cNumNf 	:= oXml:_RetornoConsulta:_Nfe[nY]:_ChaveNFe:_NumeroNFe:Text
						cSerie	:= ""
						dDtEmis	:=	oXml:_RetornoConsulta:_Nfe[nY]:_DataEmissaoNFe:Text
						dDtEmis	:= CTOD( Substr(dDtEmis,9,2) + "/" + SubsTr(dDtEmis,6,2) + "/" + Substr(dDtEmis,1,4))
						nValor	:= Val(oXml:_RetornoConsulta:_Nfe[nY]:_ValorServicos:Text)
						If Type("oXml:_RetornoConsulta:_Nfe["+str(nY)+"]:_CPFCNPJPrestador:_CNPJ") <> "U"
							cPresTador := oXml:_RetornoConsulta:_Nfe[nY]:_CPFCNPJPrestador:_CNPJ:Text
						ElseIf Type("oXml:_RetornoConsulta:_Nfe["+str(nY)+"]:_CPFCNPJPrestador:_CPF") <> "U"
							cPresTador := oXml:_RetornoConsulta:_Nfe[nY]:_CPFCNPJPrestador:_CPF:Text
						EndIf					
						If Type("oXml:_RetornoConsulta:_Nfe["+str(nY)+"]:_CPFCNPJTomador:_CNPJ") <> "U"
							cTomador := oXml:_RetornoConsulta:_Nfe[nY]:_CPFCNPJTomador:_CNPJ:Text
						ElseIf Type("oXml:_RetornoConsulta:_Nfe["+str(nY)+"]:_CPFCNPJTomador:_CPF") <> "U"
							cTomador := oXml:_RetornoConsulta:_Nfe[nY]:_CPFCNPJTomador:_CPF:Text
						EndIf					
						cNomFor	:= oXml:_RetornoConsulta:_Nfe[nY]:_RazaoSocialPrestador:Text

						If Type("oXml:_RetornoConsulta:_Nfe[nY]:_NomeFantasia:Text") <> "U"
							cNomFan := oXml:_RetornoConsulta:_Nfe[nY]:_NomeFantasia:Text
						Else
							cNomFan	:= oXml:_RetornoConsulta:_Nfe[nY]:_RazaoSocialPrestador:Text
						EndIf

						/*  PEGAR ESTES DADOS                                                      
						cNomFan		:= oXml:_CompNfse:_Nfse:_InfNfse:_PrestadorServico:_NomeFantasia:Text      
						cEnd		:= oXml:_ns4_Nfse:_ns4_InfNfse:_ns4_PrestadorServico:_ns4_Endereco:_ns4_Endereco:Text    
						cCodMun		:= oXml:_ns4_Nfse:_ns4_InfNfse:_ns4_PrestadorServico:_ns4_Endereco:_ns4_CodigoMunicipio:Text  
						cEst		:= oXml:_ns4_Nfse:_ns4_InfNfse:_ns4_PrestadorServico:_ns4_Endereco:_ns4_UF:Text
						*/

						cChvNFE		:=	oXml:_RetornoConsulta:_Nfe[nY]:_ChaveNFe:_CodigoVerificacao:Text
						cEspeci		:= "NFS"
						cStatus		:= "1"
						cObs		:= ""
						cDescri		:= AllTrim(oXml:_RetornoConsulta:_Nfe[nY]:_Discriminacao:Text)

						If ValidNota(cTipo,cNumNf,dDtEmis,nValor,cPrestador,cTomador,cDescri,cArqXMl,cEspeci,cStatus,cObs,cSerie,cChvNFE,@cFilOri,@cCodFor,@cNomFor,@cItens,cNomFan,cEnd,cCodMun,cEst)
							GravaZZA(cTipo,cNumNf,dDtEmis,nValor,cPrestador,cTomador,cDescri,cArqXMl,cEspeci,cStatus,cObs,cSerie,cChvNFE,cFilOri,cCodFor,cNomFor,cItens,.t.)
						EndIf
					Next nY
				EndIf
			EndIf
		ElseIf Type("oXml:_ConsultarNfseResposta:_ListaNfse") <> "U" //Carioca

			lSPRJ := .t.

			For nY := 1 to len(oxml:_ConsultarNfseResposta:_ListaNfse:_CompNfse)
				cTipo 	:= "CARIOCA"
				cNumNf 	:= oxml:_ConsultarNfseResposta:_ListaNfse:_CompNfse[nY]:_Nfse:_InfNfse:_Numero:Text
				cSerie	:= ""
				dDtEmis	:=	oxml:_ConsultarNfseResposta:_ListaNfse:_CompNfse[nY]:_Nfse:_InfNfse:_DataEmissao:Text
				dDtEmis	:= CTOD( Substr(dDtEmis,9,2) + "/" + SubsTr(dDtEmis,6,2) + "/" + Substr(dDtEmis,1,4))
				nValor	:= Val(oxml:_ConsultarNfseResposta:_ListaNfse:_CompNfse[nY]:_Nfse:_InfNfse:_Servico:_Valores:_ValorServicos:Text)
				If Type("oxml:_ConsultarNfseResposta:_ListaNfse:_CompNfse["+str(nY)+"]:_Nfse:_InfNfse:_PrestadorServico:_IdentificacaoPrestador:_Cnpj") <> "U"
					cPresTador	:= oxml:_ConsultarNfseResposta:_ListaNfse:_CompNfse[ny]:_Nfse:_InfNfse:_PrestadorServico:_IdentificacaoPrestador:_Cnpj:Text
				ElseIf Type("oxml:_ConsultarNfseResposta:_ListaNfse:_CompNfse["+str(nY)+"]:_Nfse:_InfNfse:_PrestadorServico:_IdentificacaoPrestador:_Cpf") <> "U"
					cPresTador	:= oxml:_ConsultarNfseResposta:_ListaNfse:_CompNfse[nY]:_Nfse:_InfNfse:_PrestadorServico:_IdentificacaoPrestador:_Cpf:Text
				EndIf					
				If Type("oxml:_ConsultarNfseResposta:_ListaNfse:_CompNfse["+str(nY)+"]:_Nfse:_InfNfse:_TomadorServico:_IdentificacaoTomador:_CpfCnpj:_Cnpj") <> "U"
					cTomador	:= oxml:_ConsultarNfseResposta:_ListaNfse:_CompNfse[ny]:_Nfse:_InfNfse:_TomadorServico:_IdentificacaoTomador:_CpfCnpj:_Cnpj:Text
				ElseIf Type("oxml:_ConsultarNfseResposta:_ListaNfse:_CompNfse["+str(nY)+"]:_Nfse:_InfNfse:_TomadorServico:_IdentificacaoTomador:_CpfCnpj:_Cpf") <> "U"
					cTomador	:= oxml:_ConsultarNfseResposta:_ListaNfse:_CompNfse[nY]:_Nfse:_InfNfse:_TomadorServico:_IdentificacaoTomador:_CpfCnpj:_Cpf:Text
				EndIf					
				cNomFor	:= oxml:_ConsultarNfseResposta:_ListaNfse:_CompNfse[nY]:_Nfse:_InfNfse:_TomadorServico:_RazaoSocial:Text

				If Type("oxml:_ConsultarNfseResposta:_ListaNfse:_CompNfse[nY]:_Nfse:_InfNfse:_TomadorServico:_NomeFantasia:Text") <> "U"
					cNomFan	:= oxml:_ConsultarNfseResposta:_ListaNfse:_CompNfse[nY]:_Nfse:_InfNfse:_TomadorServico:_NomeFantasia:Text
				Else
					cNoman	:= oxml:_ConsultarNfseResposta:_ListaNfse:_CompNfse[nY]:_Nfse:_InfNfse:_TomadorServico:_RazaoSocial:Text
				EndIf	
				/*  PEGAR ESTES DADOS                                                      
				cNomFan		:= oXml:_CompNfse:_Nfse:_InfNfse:_PrestadorServico:_NomeFantasia:Text      
				cEnd		:= oXml:_ns4_Nfse:_ns4_InfNfse:_ns4_PrestadorServico:_ns4_Endereco:_ns4_Endereco:Text    
				cCodMun		:= oXml:_ns4_Nfse:_ns4_InfNfse:_ns4_PrestadorServico:_ns4_Endereco:_ns4_CodigoMunicipio:Text  
				cEst		:= oXml:_ns4_Nfse:_ns4_InfNfse:_ns4_PrestadorServico:_ns4_Endereco:_ns4_UF:Text
				*/

				cChvNFE	:=	oxml:_ConsultarNfseResposta:_ListaNfse:_CompNfse[nY]:_Nfse:_InfNfse:_CodigoVerificacao:Text
				cEspeci	:= "NFS"
				cStatus	:= "1"
				cObs	:= ""
				cDescri	:=	Alltrim(oxml:_ConsultarNfseResposta:_ListaNfse:_CompNfse[nY]:_Nfse:_InfNfse:_Servico:_Discriminacao:Text)

				If ValidNota(cTipo,cNumNf,dDtEmis,nValor,cPrestador,cTomador,cDescri,cArqXMl,cEspeci,cStatus,cObs,cSerie,cChvNFE,@cFilOri,@cCodFor,@cNomFor,@cItens,cNomFan,cEnd,cCodMun,cEst)
					GravaZZA(cTipo,cNumNf,dDtEmis,nValor,cPrestador,cTomador,cDescri,cArqXMl,cEspeci,cStatus,cObs,cSerie,cChvNFE,cFilOri,cCodFor,cNomFor,cItens,.t.)
				EndIf

			Next nY
		EndIf

		If !lSPRJ .And. !lProd
			If !Empty(cTipo)
				If ValidNota(cTipo,cNumNf,dDtEmis,nValor,cPrestador,cTomador,cDescri,cArqXMl,cEspeci,cStatus,cObs,cSerie,cChvNFE,@cFilOri,@cCodFor,@cNomFor,@cItens,cNomFan,cEnd,cCodMun,cEst)
					GravaZZA(cTipo,cNumNf,dDtEmis,nValor,cPrestador,cTomador,cDescri,cArqXMl,cEspeci,cStatus,cObs,cSerie,cChvNFE,cFilOri,cCodFor,cNomFor,cItens,.t.)
				EndIf
			Else
				GravaErro(cArqXml,"Arquivo XML - Invalido ou Layout nao desenvolvido","9","","","",0,ctod(""),"","",.t.)
			EndIf
		EndIf
	EndIf

Return()


Static Function GravaErro(cArqXml,cError,cStatus,cNumNf,cPrestador,cTomador,nValor,dDtEmis,cCodFor,cNomFor,lPasta)

	Local aAreatu := getarea()

	dbSelectArea("ZZA")
	dbSetOrder(1)
	Reclock("ZZA",.T.)
	ZZA->ZZA_FILIAL := xFilial("ZZA")
	ZZA->ZZA_ARQXML := Alltrim(cArqXml)
	ZZA->ZZA_STATUS	:= cStatus
	ZZA->ZZA_OBS	:= Alltrim(cError)
	ZZA->ZZA_CHREG 	:= dtos(dDatabase)+substr(time(),1,2)+substr(time(),4,2)+substr(time(),7,2)
	ZZA->ZZA_USINC	:= upper(Alltrim(cUserName))
	ZZA->ZZA_DTINC	:= dDataBase
	ZZA->ZZA_HRINC	:= TIME()
	ZZA->ZZA_NFDOC	:= cNumNf
	ZZA->ZZA_CGCPRE	:= cPrestador
	ZZA->ZZA_CGCTOM	:= cTomador
	ZZA->ZZA_VALOR	:= nValor
	ZZA->ZZA_EMISSA	:= dDtEmis
	ZZA->ZZA_CODFOR := cCodFor
	ZZA->ZZA_NOMFOR	:= cNomFor
	MsUnlock()

	If lPasta
		//-- Move arquivo para pasta invalidos
		cArqTXT     := cGetPath+cArqXml
		cNomNovArq  := cStartInval+cArqXml
		If MsErase(cNomNovArq)
			__CopyFile(cArqTXT,cNomNovArq)
			FErase(cArqTXT)
		EndIf
	EndIf

	RestArea(aAreatu)

Return()


Static Function GravaZZA(cTipo,cNumNf,dDtEmis,nValor,cPrestador,cTomador,cDescri,cArqXMl,cEspeci,cStatus,cObs,cSerie,cChvNFE,cFilOri,cCodFor,cNomFor,cItens,lPasta)

	Local aAreatu 		:= getarea()
	Local cArqTXT     	:= ""
	Local cNomNovArq  	:= ""

	dbSelectArea("ZZA")
	dbSetOrder(1)
	Reclock("ZZA",.T.)
	ZZA->ZZA_FILIAL := xFilial("ZZA")
	ZZA->ZZA_ARQXML := Alltrim(cArqXml)
	ZZA->ZZA_STATUS	:= cStatus
	ZZA->ZZA_TPNF	:= cTipo
	ZZA->ZZA_NFDOC	:= cNumNf
	ZZA->ZZA_CGCPRE	:= cPrestador
	ZZA->ZZA_CGCTOM	:= cTomador
	ZZA->ZZA_VALOR	:= nValor
	ZZA->ZZA_EMISSA	:= dDtEmis
	ZZA->ZZA_DESCRI	:= cDescri
	ZZA->ZZA_ESPECI	:= cEspeci
	ZZA->ZZA_PRODUT	:= cCodPro
	ZZA->ZZA_USINC	:= upper(Alltrim(cUserName))
	ZZA->ZZA_DTINC	:= dDataBase
	ZZA->ZZA_HRINC	:= TIME()
	ZZA->ZZA_OBS	:= cObs
	ZZA->ZZA_NFSER	:= cSerie
	ZZA->ZZA_CHVNF	:= cChvNFE
	ZZA->ZZA_CHREG 	:= dtos(dDatabase)+substr(time(),1,2)+substr(time(),4,2)+substr(time(),7,2)
	ZZA->ZZA_FILORI	:= cFilOri
	ZZA->ZZA_CODFOR := cCodFor
	ZZA->ZZA_NOMFOR	:= cNomFor
	ZZA->ZZA_ITENS	:= cItens
	MsUnlock()

	//If lPasta
	//-- Move arquivo para pasta processados
	//	cArqTXT     := cGetPath+cArqXml
	//	cNomNovArq  := cStartLido+cArqXml
	//	If MsErase(cNomNovArq)
	//		__CopyFile(cArqTXT,cNomNovArq)
	//		FErase(cArqTXT)
	//	EndIf
	//EndIf

	RestArea(aAreatu)

Return()

Static Function ValidNota(cTipo,cNumNf,dDtEmis,nValor,cPrestador,cTomador,cDescri,cArqXMl,cEspeci,cStatus,cObs,cSerie,cChvNFE,cFilOri,cCodFor,cNomFor,cItens,cNomFan,cEnd,cCodMun,cEst)

	Local lOk 		:= .t.
	Local aAreaAtu 	:= getarea()
	Local cError	:= ""
	Local nRecnoSM0	:= SM0->(Recno())
	Local oObjIT
	Local nIt		:= 0
	Local cPerg		:= "FORNECXML "
	Local lCadFor	:= .F.
	Local lOkFor	:= .F.

	//Valida se a nota ja nao foi processada
	dbSelectArea("ZZA")
	dbsetOrder(1)

	If dbseek(xFilial("ZZA") + Padr(cPrestador,14) + Padr(cNumNf,9) + Padr(cArqXMl,60))
		If ZZA->ZZA_STATUS = "8" //JA TEM PRE NOTA
			lOk 	:= .f.
			cError 	:= "Nota já Incluida"
			cStatus := "5"
			GravaErro(cArqXml,cError,cStatus,cNumNf,cPrestador,cTomador,nValor,dDtEmis,ZZA->ZZA_CODFOR,ZZA->ZZA_NOMFOR,.t.)
		Else
			Reclock("ZZA",.F.)
			dbdelete()
			MsUnlock()
		EndIf
	EndIf

	If lok
		//Valida o Tomador April
		dbSelectArea("SM0")
		dbgotop()
		While !eof()
			If AllTrim(SM0->M0_CGC) = Alltrim(cTomador)
				cFilOri := SM0->M0_CODFIL	
			EndIf	
			SM0->(dbskip())
		End
		SM0->(DbGoTo(nRecnoSM0))

		If Empty(cFilOri)
			lOk 	:= .f.
			cError 	:= "Tomador Invalido"
			cStatus := "3"
			GravaErro(cArqXml,cError,cStatus,cNumNf,cPrestador,cTomador,nValor,dDtEmis,"",cNomFor,.t.)
		EndIf	
	EndIf

	If lOk
		//Valida o Prestador / Fornecedor
		DbSelectArea("SA2")
		SA2->(DbSetOrder(3))
		If !SA2->(DbSeek(xFilial("SA2")+Padr(AllTrim(cPrestador),14)))

			IncCadFor(@lOkFor,cPrestador,cTomador,cCodFor,cNomFor,cNomFan,cEnd,cCodMun,cEst,@lCadFor)

			If !lCadFor
				lOk 		:= .f.
				cStatus 	:= "4"
				cObs		:= "Prestador/Fornecedor não cadastrado "

				GravaZZA(cTipo,cNumNf,dDtEmis,nValor,cPrestador,cTomador,cDescri,cArqXMl,cEspeci,cStatus,cObs,cSerie,cChvNFE,cFilOri,cCodFor,cNomFor,cItens,.f.)
			Else
				cCodFor := SA2->A2_COD+SA2->A2_LOJA
				cNomFor := SA2->A2_NREDUZ	
			EndIf
		Else
			cCodFor := SA2->A2_COD+SA2->A2_LOJA
			cNomFor := SA2->A2_NREDUZ
		EndIf
	EndIf

	If lOk .and. !Empty(cItens) .and. !Empty(cObs) //valida produtos
		lOk 		:= .f.
		cStatus 	:= "7"  //produtos nao cadastrado
		GravaZZA(cTipo,cNumNf,dDtEmis,nValor,cPrestador,cTomador,cDescri,cArqXMl,cEspeci,cStatus,cObs,cSerie,cChvNFE,cFilOri,cCodFor,cNomFor,cItens,.f.)
	EndIf

	RestArea(aAreaAtu)

Return(lOk)

Static Function ValidPerg()

	Local aArea  := GetArea()
	Local aRegs  := {}
	Local i := j := 0

	dbSelectArea("SX1")
	dbSetOrder(1)
	cPerg := PADR(cPerg,10)

	//GRUPO,ORDEM,PERGUNTA              ,PERGUNTA,PERGUNTA,VARIAVEL,TIPO,TAMANHO,DECIMAL,PRESEL,GSC,VALID,VAR01,DEF01,DEFSPA01,DEFING01,CNT01,VAR02,DEF02,DEFSPA02,DEFING02,CNT02,VAR03,DEF03,DEFSPA03,DEFING03,CNT03,VAR04,DEF04,DEFSPA04,DEFING04,CNT04,VAR05,DEF05,DEFSPA05,DEFING05,CNT05,F3,GRPSXG
	AADD(aRegs,{cPerg,"01","Local dos XMLs  ?","","","mv_ch1","C",60,0,0,"G","","mv_par01","","","","","","","","","","","","","","","","","","","","","","","","","DIR2",""})

	For i:=1 to Len(aRegs)
		If !dbSeek(cPerg+aRegs[i,2])
			RecLock("SX1",.T.)
			For j:=1 to FCount()
				If j <= Len(aRegs[i])
					FieldPut(j,aRegs[i,j])
				Endif
			Next
			MsUnlock()
		Endif
	Next

	RestArea(aArea)

Return


Static Function Controle()

	Local aTitles2  := {OemToAnsi("A Processar"),OemToAnsi("Invalidas")}

	Private aCoors 		:= FWGetDialogSize( oMainWnd )
	Private oDlgPri,oFont02,oFont01
	Private oTela,oCont0,oCont1,oCont2,oCont3,oCont4
	Private oPastas,oPanelSup,oSayLeng,oGroupId,oFoldNF,oBarSup
	Private oTButton1,oTButton2,oGetZAC,oGetZAD

	Private aCpoZAC  	:= {"ZZA_FILORI","ZZA_TPNF","ZZA_NFDOC","ZZA_NFSER","ZZA_EMISSA","ZZA_NOMFOR","ZZA_VALOR","ZZA_DESCRI","ZZA_OBS","ZZA_ITENS","ZZA_ARQXML"}
	Private aAltZAC  	:= {}
	Private aHeadZAC 	:= RetHeader(aCpoZAC)
	Private aColsZAC 	:= RetCols(aHeadZAC)

	Private aCpoZAD  	:= {"ZZA_FILORI","ZZA_TPNF","ZZA_NFDOC","ZZA_NFSER","ZZA_EMISSA","ZZA_CGCPRE","ZZA_NOMFOR","ZZA_VALOR","ZZA_DESCRI","ZZA_OBS","ZZA_ITENS","ZZA_ARQXML"}
	Private aAltZAD  	:= {}
	Private aHeadZAD 	:= RetHeader(aCpoZAD)
	Private aColsZAD 	:= RetCols(aHeadZAD)

	Private bLinOk 		:= {|| .T. /*flinOk()*/} 
	Private bLinDel 	:= {|| .T. /*fLinDel()*/} 
	Private bVldCpo 	:= {|| .T. /*fValidCpo()*/} 
	Private bChange 	:= {|| .T. /*fLinhaPlaca()*/} 
	Private bSuperDel 	:= {|| Alert("SuperDel")} 

	DEFINE FONT oFont02  NAME "Arial" SIZE 0,15  BOLD
	DEFINE FONT oFont01  NAME "Arial" SIZE 0,42  BOLD

	oDlgPri := TDialog():New(aCoors[1], aCoors[2],aCoors[3], aCoors[4],"Importação de XMls",,,,,,,,,.T.,,,,,) 

	oTela := FWFormContainer():New( oDlgPri )
	oCont0 := oTela:createVerticalBox( 15 )
	oCont1 := oTela:createVerticalBox( 85 )
	oCont2 := oTela:createHorizontalBox( 05,oCont1 )
	oCont3 := oTela:createHorizontalBox( 90,oCont1 )
	oCont4 := oTela:createHorizontalBox( 05,oCont1 )

	oTela:Activate( oDlgPri, .F. )

	oBarSup 	:= oTela:GetPanel( oCont0 )
	oPastas 	:= oTela:GetPanel( oCont3 )

	oPanelSup 	:= tPanel():New(01,03,"",oBarSup,,,,,RGB(160,183,237),((oBarSup:nRight - oBarSup:nLeft) / 2) - 5,((oBarSup:nBottom - oBarSup:nTop) / 2)-15,.t.,.F.)

	oSayLeng := TSay():New( 010,005 ,{||"LEGENDA"} ,oPanelSup,,oFont02,.F.,.F.,.F.,.T.,CLR_RED,CLR_WHITE,100,050)
	Legenda()

	oTButton1 	:= TButton():New( ((oBarSup:nBottom - oBarSup:nTop)/2)-040, 03, "Sair"	,oPanelSup,{||oDlgPri:End()}	,((oBarSup:nRight - oBarSup:nLeft) / 2) - 15,15,,oFont02,.F.,.T.,.F.,,.F.,,,.F. ) 
	oTButton2 	:= TButton():New( ((oBarSup:nBottom - oBarSup:nTop)/2)-100, 03, "Gerar Pre-Nota" ,oPanelSup,{||GeraPreNF()} ,((oBarSup:nRight - oBarSup:nLeft) / 2) - 15,15,,oFont02,.F.,.T.,.F.,,.F.,,,.F. ) 
	oTButton3 	:= TButton():New( ((oBarSup:nBottom - oBarSup:nTop)/2)-060, 03, "Produtos x Fornecedor" ,oPanelSup,{||fProdFor()} ,((oBarSup:nRight - oBarSup:nLeft) / 2) - 15,15,,oFont02,.F.,.T.,.F.,,.F.,,,.F. ) 

	oFoldNF 	:= TFolder():New(oPastas:nTop,oPastas:nLeft,aTitles2,{"HEADER"},oPastas,1,,, .T., .F.,((oPastas:nRight - oPastas:nLeft) / 2) - 7,((oPastas:nBottom - oPastas:nTop) / 2) - 3,)
	fDadosNF()

	oDlgPri:Activate(,,,.T.)

Return()

Static Function fDadosNF()

	Local nModo := 0 //GD_UPDATE+GD_INSERT+GD_DELETE
	Local nMaxLin := 999

	oGetZAC := MsNewGetDados():New( 2, 3,((oPastas:nBottom - oPastas:nTop) / 2)-15, ((oPastas:nRight - oPastas:nLeft) / 2) - 8 ,nModo,'Eval(bLinOk)',/*ctudoOk*/ ,/*cIniCpos*/ ,aAltZAC,0,nMaxLin,'Eval(bVldCpo)','Eval(bSuperDel)' ,'Eval(bLinDel)', oFoldNF:aDialogs[1], aHeadZAC, aColsZAC,bChange)
	oGetZAD := MsNewGetDados():New( 2, 3,((oPastas:nBottom - oPastas:nTop) / 2)-15, ((oPastas:nRight - oPastas:nLeft) / 2) - 8 ,nModo,'Eval(bLinOk)',/*ctudoOk*/ ,/*cIniCpos*/ ,aAltZAD,0,nMaxLin,'Eval(bVldCpo)','Eval(bSuperDel)' ,'Eval(bLinDel)', oFoldNF:aDialogs[2], aHeadZAD, aColsZAD,bChange)

	AtuDadosNf()

Return()


Static Function AtuDadosNf()

	Local cQuery 	:= ""

	cQuery := " SELECT ZZA_FILORI,ZZA_TPNF,ZZA_NFDOC,ZZA_NFSER,ZZA_EMISSA,ZZA_CGCPRE,ZZA_NOMFOR,ZZA_VALOR,ZZA_ARQXML,ZZA_STATUS," 
	cQuery += "  ISNULL(CONVERT(VARCHAR(6000), CONVERT(VARBINARY(6000), ZZA_OBS)),'') ZZA_OBS, " 
	cQuery += "  ISNULL(CONVERT(VARCHAR(6000), CONVERT(VARBINARY(6000), ZZA_DESCRI)),'') ZZA_DESCRI, " 
	cQuery += "  ISNULL(CONVERT(VARCHAR(6000), CONVERT(VARBINARY(6000), ZZA_ITENS)),'') ZZA_ITENS " 
	cQuery += " FROM "+RetSqlName("ZZA")+" ZZA "
	cQuery += " WHERE ZZA_FILIAL = '"+xfilial("ZZA")+"' "
	cQuery += "  AND ZZA_STATUS IN ('1','6') "
	cQuery += "  AND ZZA.D_E_L_E_T_ ='' "
	cQuery += " ORDER BY 1,2,3 "
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),'TRBZZA',.T.,.T.)
	TCSetField("TRBZZA", "ZZA_EMISSA" ,"D", 8, 0 )

	If !TRBZZA->(EOF())
		aColsZAC := RetCols(aHeadZAC,"TRBZZA",.t.)
	Else
		aColsZAC := RetCols(aHeadZAC,"")
	EndIF

	oGetZAC:aCols := aColsZAC
	oGetZAC:oBrowse:nAt := 1 
	oGetZAC:oBrowse:Refresh()

	TRBZZA->(dbCloseArea())

	cQuery := " SELECT ZZA_FILORI,ZZA_TPNF,ZZA_NFDOC,ZZA_NFSER,ZZA_EMISSA,ZZA_CGCPRE,ZZA_NOMFOR,ZZA_VALOR,ZZA_ARQXML, ZZA_STATUS," 
	cQuery += "  ISNULL(CONVERT(VARCHAR(6000), CONVERT(VARBINARY(6000), ZZA_OBS)),'') ZZA_OBS, " 
	cQuery += "  ISNULL(CONVERT(VARCHAR(6000), CONVERT(VARBINARY(6000), ZZA_DESCRI)),'') ZZA_DESCRI, " 
	cQuery += "  ISNULL(CONVERT(VARCHAR(6000), CONVERT(VARBINARY(6000), ZZA_ITENS)),'') ZZA_ITENS " 
	cQuery += " FROM "+RetSqlName("ZZA")+" ZZA "
	cQuery += " WHERE ZZA_FILIAL = '"+xfilial("ZZA")+"' "
	cQuery += "  AND ZZA_STATUS NOT IN ('1','8','6')"
	cQuery += "  AND LEFT(ZZA_CHREG,8) >= '"+dtos(ddatabase-5)+"'"  
	cQuery += "  AND ZZA.D_E_L_E_T_ ='' "
	cQuery += " ORDER BY 1,2,3 "

	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),'TRBZZA',.T.,.T.)
	TCSetField("TRBZZA", "ZZA_EMISSA" ,"D", 8, 0 )

	If !TRBZZA->(EOF())
		aColsZAD := RetCols(aHeadZAD,"TRBZZA",.t.)
	Else
		aColsZAD := RetCols(aHeadZAD,"")
	EndIF

	oGetZAD:aCols := aColsZAD
	oGetZAD:oBrowse:nAt := 1 
	oGetZAD:oBrowse:Refresh()

	TRBZZA->(dbCloseArea())

Return

Static Function GeraPreNF()

	Local oProcNf
	Local lProcOK	:= .t.

	If MsgYesNo("Deseja gerar as Pre-Notas ?")
		oProcNf:= MsNewProcess():New( { |lEnd| u_OkProcNf( oProcNf, @lProcOK ) }, "", "", .F. )
		oProcNf:Activate()
		If lProcOk 
			fDadosNF()
		Else	
			MsgInfo("Houve algum erro na geração das Pre-Notas verifique !!")
		EndIf
	EndIf

Return()

User Function OkProcNf( oObj,lProcOk )

	Local nY				:= 0
	Local cQuery   		:= ""
	Local lObj	    	:= ValType(oObj) == "O"
	Local nReg			:= 0

	cQuery := " SELECT ZZA.*, ZZA.R_E_C_N_O_ RECZZA," 
	cQuery += "  ISNULL(CONVERT(VARCHAR(6000), CONVERT(VARBINARY(6000), ZZA_ITENS)),'') ITENS " 
	cQuery += " FROM "+RetSqlName("ZZA")+" ZZA "
	cQuery += " WHERE ZZA_FILIAL = '"+xfilial("ZZA")+"' "
	cQuery += "  AND ZZA_STATUS IN ('1','6') "
	cQuery += "  AND ZZA.D_E_L_E_T_ ='' "
	cQuery += " ORDER BY ZZA_FILORI,ZZA_CODFOR,ZZA_NFDOC"
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),'TRBZZA',.T.,.T.)
	dbSelectArea( "TRBZZA" )
	DbGoTop()
	bAcao:= {|| nReg ++ }
	dbEval(bAcao,,{||!Eof()},,,.T.)
	dbSelectArea("TRBZZA")
	dbGotop()

	If nReg <> 0
		lProcOk := .t.

		If lObj
			oObj:SetRegua1(nReg)
		EndIf

		While !Eof()

			If lObj
				oObj:IncRegua1("Gerando a Pre-Nota : "+TRBZZA->ZZA_NFDOC)
			Else
				ConOut(OEMToANSI(FWTimeStamp(2) + "Gerando a Pre-Nota : "+TRBZZA->ZZA_NFDOC))
			EndIf

			Begin Transaction      
				GeraSF1SD1( 	TRBZZA->ZZA_FILORI,;
				TRBZZA->ZZA_NFDOC,;
				TRBZZA->ZZA_NFSER,;
				STOD(TRBZZA->ZZA_EMISSA),;
				TRBZZA->ZZA_CODFOR,;
				TRBZZA->ZZA_ESPECI,;
				TRBZZA->ZZA_PRODUT,;
				TRBZZA->ZZA_VALOR,;
				TRBZZA->ZZA_CHVNF,;
				AllTrim(TRBZZA->ITENS),;
				TRBZZA->RECZZA )
			End Transaction

			dbSelectArea("TRBZZA")
			dbSkip()
		End

	EndIf

	TRBZZA->(dbCloseArea())

Return()

Static Function GeraSF1SD1(cFilOri,cNumNf,cSerie,dDtEmissa,cCodfor,cEspeci,cCodPro,nValor,cChvNf,cJItens,nRecZZA)

	Local aCabec 		:= {}
	Local aLinha 		:=	{}
	Local aItens			:= {} 
	Local cFilBkp		:= cFilAnt
	Local tmD1_ITEM  	:= TAMSX3("D1_ITEM")[1]
	Local cItem      	:= SOMA1(REPLICATE("0",tmD1_ITEM),tmD1_ITEM)
	Local aLog			:= {}
	Local cStrErro		:= ""
	Local aAreaAtu		:= getarea()
	Local cDesPro		:= posicione("SB1",1,xFilial("SB1")+cCodPro,"B1_DESC")
	Local cArqTXT     	:= ""
	Local cNomNovArq  	:= ""

	cFilAnt := cFilOri

	Private lMsErroAuto := .f.
	Private lAutoErrNoFile := .t.

	aCabec := {		{'F1_TIPO'		,'N'			,	NIL},;		
	{'F1_FORMUL'	,'N'			,	NIL},;		
	{'F1_DOC'		,cNumNF    		,	NIL},;		
	{'F1_SERIE'		,cSerie			,	NIL},;		
	{'F1_ESPECIE'	,cEspeci		,	NIL},;		
	{'F1_EMISSAO'	,dDtEmissa		,	NIL},;		
	{'F1_FORNECE'	,Left(cCodFor,6),	NIL},;		
	{'F1_LOJA'		,Right(cCodFor,2),	NIL}}		

	If Empty(cJItens)
		aLinha :=	{	{'D1_ITEM'		,cItem 			,NIL},;	
		{'D1_COD'		,cCodPro		,NIL},;		
		{'D1_XDESC'		,cDesPro		,NIL},;		
		{'D1_UM'		,'UN'			,NIL},;				
		{'D1_QUANT'		,1				,NIL},;		
		{'D1_VUNIT'		,nValor			,NIL},;		
		{'D1_TOTAL'		,nValor			,NIL}}

		AAdd(aItens,aLinha)			
	Else	

		aItens := fJSonItens(cJItens)

	EndIf

	MSExecAuto({|x,y,z| MATA140(x,y,z)}, aCabec, aItens, 3)

	If lMsErroAuto      
		MostraErro()
		aLog := GetAutoGRLog()
		For X := 1 To LEN(aLog)
			cStrErro += (Alltrim(aLog[X]) + CRLF )	
		Next X
		cStatus := "6" //Erro	
	Else	
		cStrErro := ""	
		cStatus := "8"	//Pre Nota Gerada
	EndIf

	dbSelectArea("ZZA")
	dbgoto(nRecZZA)
	Reclock("ZZA",.f.)
	ZZA->ZZA_STATUS	:= cStatus
	ZZA->ZZA_OBS	:= cStrErro
	MsUnlock()

	If cStatus = "8"
		//-- Move arquivo para pasta processados
		cArqTXT     := cGetPath+AllTrim(ZZA->ZZA_ARQXML)
		cNomNovArq  := cStartLido+AllTrim(ZZA->ZZA_ARQXML)
		If MsErase(cNomNovArq)
			__CopyFile(cArqTXT,cNomNovArq)
			FErase(cArqTXT)
		EndIf
	EndIf

	cFilAnt := cFilBkp

	RestArea(aAreaAtu)

Return()      

Static Function IncSt(cStatus)

	Local oVerde    := LoadBitmap( GetResources(), "BR_VERDE" 	)
	Local oAmarelo 	:= LoadBitmap( GetResources(), "BR_AMARELO"	)
	Local oAzul    	:= LoadBitmap( GetResources(), "BR_AZUL" 		)
	Local oCinza    := LoadBitmap( GetResources(), "BR_CINZA" 	)
	Local oBranco  	:= LoadBitmap( GetResources(), "BR_BRANCO" 	)
	Local oPreto  	:= LoadBitmap( GetResources(), "BR_PRETO" 	)
	Local oLaranja 	:= LoadBitmap( GetResources(), "BR_LARANJA" 	)
	Local oVermelho := LoadBitmap( GetResources(), "BR_VERMELHO"	)
	Local oBmp

	If cStatus = "1"	
		oBmp := oVerde
	ElseIf cStatus = "2"	
		oBmp := oAmarelo
	ElseIf cStatus = "3"	
		oBmp := oAzul
	ElseIf cStatus = "4"	
		oBmp := oVermelho
	ElseIf cStatus = "5"	
		oBmp := oCinza
	ElseIf cStatus = "6"	
		oBmp := oBranco
	ElseIf cStatus = "7"	
		oBmp := oLaranja
	ElseIf cStatus = "9"	
		oBmp := oPreto
	Endif	

Return(oBmp)

Static Function Legenda()

	//legenda
	@ 20,05 BITMAP aBmp1 RESNAME "BR_VERDE" of oPanelSup SIZE 20,20 NOBORDER WHEN .F. PIXEL
	@ 20,15 SAY "Gerar Pre-Nota"	SIZE 60,7 PIXEL OF oPanelSup 

	@ 30,05 BITMAP aBmp1 RESNAME "BR_AMARELO" of oPanelSup SIZE 20,20 NOBORDER WHEN .F. PIXEL
	@ 30,15 SAY "Nota Cancelada"	SIZE 60,7 PIXEL OF oPanelSup 

	@ 40,05 BITMAP aBmp1 RESNAME "BR_AZUL" of oPanelSup SIZE 20,20 NOBORDER WHEN .F. PIXEL
	@ 40,15 SAY "Tomador Invalido"	SIZE 60,7 PIXEL OF oPanelSup 

	@ 50,05 BITMAP aBmp1 RESNAME "BR_VERMELHO" of oPanelSup SIZE 20,20 NOBORDER WHEN .F. PIXEL
	@ 50,15 SAY "Prestador Invalido" SIZE 60,7 PIXEL OF oPanelSup 

	@ 60,05 BITMAP aBmp1 RESNAME "BR_CINZA" of oPanelSup SIZE 20,20 NOBORDER WHEN .F. PIXEL
	@ 60,15 SAY "Nota já Incluida"		SIZE 60,7 PIXEL OF oPanelSup 

	@ 70,05 BITMAP aBmp1 RESNAME "BR_BRANCO" of oPanelSup SIZE 20,20 NOBORDER WHEN .F. PIXEL
	@ 70,15 SAY "Erro na Pre-Nota"		SIZE 60,7 PIXEL OF oPanelSup 

	@ 80,05 BITMAP aBmp1 RESNAME "BR_PRETO" of oPanelSup SIZE 20,20 NOBORDER WHEN .F. PIXEL
	@ 80,15 SAY "Arq. XML Invalidos"	SIZE 60,7 PIXEL OF oPanelSup 

	@ 90,05 BITMAP aBmp1 RESNAME "BR_LARANJA" of oPanelSup SIZE 20,20 NOBORDER WHEN .F. PIXEL
	@ 90,15 SAY "Produto nao encontrado"		SIZE 60,7 PIXEL OF oPanelSup 


Return()


Static Function RetHeader(aCpo)

	Local aRet 	:= {}
	Local nX	:= 0


	Aadd(aRet,{	"",;
	"COR",;
	"@BMP",;
	1,;
	0,;
	.T.,;
	"",;
	"",;
	"",;
	"R",;
	"",;
	""}) //,;


	dbSelectArea("SX3")
	dbSetOrder(2)

	For nX := 1 To Len(aCpo)
		If dbSeek(aCpo[nx])
			Aadd(aRet,{	AllTrim(X3Titulo()),;
			AllTrim(SX3->X3_CAMPO),;
			SX3->X3_PICTURE,;
			SX3->X3_TAMANHO,;
			SX3->X3_DECIMAL,;
			SX3->X3_VALID,;
			SX3->X3_USADO,;
			SX3->X3_TIPO,;
			SX3->X3_F3,;
			SX3->X3_CONTEXT,;
			SX3->X3_CBOX,;
			SX3->X3_RELACAO}) //,;
		EndIf
	Next

Return aRet



Static Function RetCols(aHead,cXAlias)

	Local aRet 	   		:= {}
	Local nX	      		:= 0
	Local nCntFor     	:= 0

	Default cXAlias   	:= ""

	If !Empty(cXAlias)

		dbSelectArea(cXAlias)
		While (cXAlias)->(!Eof())

			aAdd(aRet,Array(Len(aHead)+1))

			aRet[Len(aRet)][1]	:= IncSt((cXAlias)->ZZA_STATUS)

			For nCntFor	:= 2 To Len(aHead)
				dbSelectArea(cXAlias)
				aRet[Len(aRet)][nCntFor] := FieldGet(FieldPos(aHead[nCntFor][2]))
			Next nCntFor

			aRet[Len(aRet), Len(aHead)+1] := .F.
			(cXAlias)->(dbSkip())

		EndDo
	EndIf

	If Empty(aRet)

		aAdd(aRet,Array(Len(aHead)+1))

		aRet[Len(aRet)][1]	:= IncSt("1")

		For nX := 2 To Len(aHead)
			aRet[1, nX] := CriaVar(aHead[nX][2], (aHead[nX][10] <> "V") )
		Next nX

		aRet[Len(aRet), Len(aHead)+1] := .F.

	EndIf


Return aRet


Static Function SchedDef()

	Local aParam 	:= {}		//array de retorno

	aParam := { 	"P"				,;	//Tipo R para relatorio P para processo
	"PARAMDEF"	,;	//Nome do grupo de perguntas (SX1)
	Nil		,;	//cAlias (para Relatorio)
	Nil		,;	//aArray (para Relatorio)
	Nil		}	//Titulo (para Relatorio)

Return aParam


//Usado SBB DIR2
User Function AdmPath()

	Local cType			:= "*.*"
	Local cRootPath		:= "C:"

	//cAdmArq	:= cGetFile(cType, (STR0003+Subs(cType,1,7) ),,,,GETF_NETWORKDRIVE+GETF_LOCALHARD+GETF_LOCALFLOPPY ) // "Selecione arquivo "
	cAdmDir	:= cGetFile( "" , OemToAnsi("Selecione o caminho onde estão localizados os arquivos") , 1 ,; 
	cRootPath +"\"  , .F. ,  nOR( GETF_LOCALHARD, GETF_RETDIRECTORY ))
Return !Empty(cAdmDir)

User Function AdmDir()
Return(cAdmDir)

//Essa função realiza o parse de uma string no formato Json
Static Function fJSonItens(cJItens)

	Local aRetItens := {}
	Local oObjIT
	Local aLinha		:= {}
	Local nIt			:= 0

	If FWJsonDeserialize(cJItens,@oObjIT)

		For nIt := 1 to len(oObjIT:Itens)

			aLinha :=	{	{'D1_ITEM'		,oObjIT:Itens[nIt]:item				,NIL},;	
			{'D1_COD'			,oObjIT:Itens[nIt]:produto			,NIL},;		
			{'D1_XDESC'		,oObjIT:Itens[nIt]:descri				,NIL},;		
			{'D1_UM'			,oObjIT:Itens[nIt]:um					,NIL},;				
			{'D1_QUANT'		,Val(oObjIT:Itens[nIt]:qtd)			,NIL},;		
			{'D1_VUNIT'		,Val(oObjIT:Itens[nIt]:vunit)		,NIL},;		
			{'D1_TOTAL'		,Val(oObjIT:Itens[nIt]:total)		,NIL}}

			AAdd(aRetItens,aLinha)			

		Next nIt	

	EndIf


Return(aRetItens)

//monta um arquivo Json para os Itens da nota
Static Function MontaJItens(oItens,cPrestador,cObs)

	Local xITens 	:= ""
	Local xCITens 	:= ""
	Local xRITens 	:= ""
	Local ny		:= 0
	Local xItem		:= ""
	Local xCodPro 	:= ""
	Local xDescri	:= ""
	Local xUM		:= ""
	Local xQtd		:= ""
	Local xVlUnit	:= ""
	Local xTotal	:= ""
	Local xCodFor	:= ""
	Local xLojFor	:= ""
	Local xObs		:= ""

	//Valida o Prestador / Fornecedor
	DbSelectArea("SA2")
	SA2->(DbSetOrder(3))
	If SA2->(DbSeek(xFilial("SA2")+Padr(AllTrim(cPrestador),14)))
		xCodFor 	:= SA2->A2_COD
		xLojFor 	:= SA2->A2_LOJA
	EndIf

	xCItens := ''				
	xCItens += '{' + CRLF
	xCItens += '"Itens":' + CRLF
	xCItens += '[' + CRLF

	xRItens += ']' + CRLF
	xRItens += '}' + CRLF

	For nY := 1 to Len(oItens)
		xItem	:= STRZERO(ny,TAMSX3("D1_ITEM")[1])
		xCodPro := AllTrim(oItens[ny]:_Prod:_cProd:Text)
		xDescri	:= AllTrim(oItens[ny]:_Prod:_xProd:Text)
		xUM		:= AllTrim(oItens[ny]:_Prod:_uCom:Text)
		xQtd	:= AllTrim(oItens[ny]:_Prod:_qCom:Text)
		xVlUnit	:= AllTrim(oItens[ny]:_Prod:_vUnCom:Text)
		xTotal	:= AllTrim(oItens[ny]:_Prod:_vProd:Text)

		If !Empty(xCodFor)
			dbSelectArea("SA5") //AMARRAÇÃO PRODUTO X FORNECEDOR
			dbSetOrder(14)
			If dbseek(xFilial("SA5")+xCodFor+xLojFor+Padr(xCodPro,20))
				xCodPro 	:= Alltrim(SA5->A5_PRODUTO)
				xDescri		:= Alltrim(posicione("SB1",1,xFilial("SB1")+xCodPro,"B1_DESC"))
				xUM			:= Alltrim(SB1->B1_UM)
			Else
				xObs += '{' + CRLF
				xObs += '"item":"'+xItem+'",' + CRLF   
				xObs += '"produto":"'+xCodPro+'", ' + CRLF 
				xObs += '"descri":"'+xDescri+'", ' + CRLF 
				xObs += '"um":"'+xUM+'", ' + CRLF 
				xObs += '"qtd":"'+xQtd+'", ' + CRLF 
				xObs += '"vunit":"'+xVlUnit+'", ' + CRLF 
				xObs += '"total":"'+xTotal+'" ' + CRLF 
				xObs += '},' + CRLF
			EndIf   
		EndIf

		xItens += '{' + CRLF
		xItens += '"item":"'+xItem+'",' + CRLF   
		xItens += '"produto":"'+xCodPro+'", ' + CRLF 
		xItens += '"descri":"'+xDescri+'", ' + CRLF 
		xItens += '"um":"'+xUM+'", ' + CRLF 
		xItens += '"qtd":"'+xQtd+'", ' + CRLF 
		xItens += '"vunit":"'+xVlUnit+'", ' + CRLF 
		xItens += '"total":"'+xTotal+'" ' + CRLF 
		xItens += '},' + CRLF

	Next nY

	xItens := Substr(xItens,1,Len(xItens)-3)+ CRLF //TIRA A ULTIMA VIRGULA

	If !Empty(xObs)
		xObs := Substr(xObs,1,Len(xObs)-3)+ CRLF //TIRA A ULTIMA VIRGULA
		cObs := xCItens+xObs+xRItens
	EndIf

Return(xCItens+xItens+xRItens)


Static Function fProdFor()

	Local cItens	:= AllTrim(oGetZAD:aCols[oGetZAD:oBrowse:nAt,GDFieldPos("ZZA_ITENS",aHeadZAD)])
	Local cObsIt	:= AllTrim(oGetZAD:aCols[oGetZAD:oBrowse:nAt,GDFieldPos("ZZA_OBS",aHeadZAD)])
	Local cCGCFor 	:= AllTrim(oGetZAD:aCols[oGetZAD:oBrowse:nAt,GDFieldPos("ZZA_CGCPRE",aHeadZAD)])
	Local aRetItens := {}
	Local oObjIT
	Local nIt		:= 0

	If !Empty(cItens) .and. !Empty(cObsIt)
		DbSelectArea("SA2")
		SA2->(DbSetOrder(3))
		If SA2->(DbSeek(xFilial("SA2")+Padr(AllTrim(cCGCFor),14)))
			If FWJsonDeserialize(cObsIt,@oObjIT)
				For nIt := 1 to len(oObjIT:Itens)
					aadd(aRetItens,{oObjIT:Itens[nIt]:produto,oObjIT:Itens[nIt]:descri})
				Next nIt	
			EndIf
		EndIf
	Else	
		MsgInfo("Não existem Produtos para a Amarração Produto x Forcedor","Observação")	
		Return()
	EndIf

	If !Empty(aRetItens)
		ProdForn(aRetItens)
	Else
		MsgInfo("Não existem Produtos para a Amarração Produto x Forcedor","Observação")	
	EndIf

Return()

Static Function ProdForn(aPF)

	Local oBtnCanc
	Local oBtnInc
	Local lRet	:= .F.

	Private oDlgPF
	Private aHeaderEx 	:= {}
	Private oMSProds	:= Nil
	Private aColsEx 	:= {}


	DEFINE MSDIALOG oDlgPF TITLE "Produtos / Fornecedores" FROM 000, 000  TO 300, 700 COLORS 0, 16777215 PIXEL

	fMSProds(aPF)
	@ 109, 300 BUTTON oBtnInc PROMPT "&Incluir" ACTION (IIF(Incluir(@lRet),Close(oDlgPF),Nil)) SIZE 047, 012 OF oDlgPF PIXEL
	@ 124, 300 BUTTON oBtnCanc PROMPT "&Cancelar" ACTION (Close(oDlgPF)) SIZE 047, 012 OF oDlgPF PIXEL

	ACTIVATE MSDIALOG oDlgPF CENTERED

Return lRet


Static Function fMSProds(aPF)

	Local nX	:= 0
	Local nI	:= 0


	Private aFieldFill 	:= {}
	Private aFields 		:= {"PRODFOR","DESCFOR","PRODERP","DESCERP"}
	Private aAlterFields 	:= {"PRODERP"}

	  	Aadd(aHeaderEx, {"Produto Fornecedor","PRODFOR", "@!",   15,0,"","","C","","R","", "", ""})	
	   	Aadd(aHeaderEx, {"Descrição Fornecedor", "DESCFOR", "@!", 30,0,"", "", "C", "", "R", "", "", ""})
	   Aadd(aHeaderEx, {"Produto ERP", "PRODERP",  "@!", 15, 0, "U_VALERP(M->PRODERP)", "", "C", "SB1", "R", "", "", ""})			
	   	Aadd(aHeaderEx, {"Descrição ERP","DESCERP", "@!", 30, 0, "", "", "C", "", "R", "", "", ""})		

	For nI := 1 To Len(aPF) 
		aFieldFill 	:= {}
		For nX := 1 to Len(aFields)
			If AllTrim(aFields[nX]) == "PRODFOR"
				aAdd(aFieldFill, PADR(aPF[nI][1],15))
			Elseif AllTrim(aFields[nX]) == "DESCFOR"
				aAdd(aFieldFill, PADR(aPF[nI][2],30))	      		      		
			Elseif AllTrim(aFields[nX]) == "PRODERP"
				Aadd(aFieldFill, PADR("",15))
			Elseif AllTrim(aFields[nX]) == "DESCERP"
				Aadd(aFieldFill, PADR("",30))	      	
			Endif
		Next nX
		Aadd(aFieldFill, .F.)
		Aadd(aColsEx, aFieldFill)
	Next nI

	oMSProds := MsNewGetDados():New( 010, 006, 099, 350, GD_UPDATE, "AllwaysTrue()", "AllwaysTrue()", "", aAlterFields,, 999, "AllwaysTrue()", "", "AllwaysTrue()", oDlgPF, aHeaderEx, aColsEx)

Return

User Function VALERP(cProdSB1)

	Local lOk := .t.

	If !Empty(cProdSB1)
		dbSelectArea("SB1")
		dbSetOrder(1)
		If dbseek(xFilial("SB1")+cProdSB1)
			aColsEx[n][4]	:= M->DESCERP := SB1->B1_DESC
			oMsProds:aCols[n][4] := SB1->B1_DESC
		Else
			MsgInfo("Produto não cadastrado","Atenção")
			aColsEx[n][4]	:= M->DESCERP := space(30)
			oMsProds:aCols[n][4] := space(30)
			lOk := .f.
		EndIf
	EndIf	
	oMSProds:Refresh()

Return(lOk) 

Static Function Incluir(lRet)
	Local nX	:= 0
	Local aArea	:= GetArea()
	Local nMsg  := 0
	Local lCad  := .F.

	For nX := 1 To Len(oMsProds:aCols)  
		If Empty(oMsProds:aCols[nX,GDFieldPos("PRODERP",aHeaderEx)]) .And. nMsg == 0
			MsgStop( "Produto ERP não informado.", "Informe o Produto ERP" ) 
			nMsg := 1
		Else
			lCad := .T.	
			If lCad .And. nMsg == 0 
				If RecLock("SA5",.T.)
					SA5->A5_FILIAL 		:= xFilial("SA5")
					SA5->A5_FORNECE		:= SA2->A2_COD
					SA5->A5_LOJA		:= SA2->A2_LOJA
					SA5->A5_NOMEFOR		:= SA2->A2_NOME
					SA5->A5_PRODUTO 	:= oMsProds:aCols[nX,GDFieldPos("PRODERP",aHeaderEx)]	
					SA5->A5_NOMPROD		:= oMsProds:aCols[nX,GDFieldPos("DESCERP",aHeaderEx)]
					SA5->A5_CODPRF		:= oMsProds:aCols[nX,GDFieldPos("PRODFOR",aHeaderEx)]
					SA5->(MsUnlock())
					lRet := .T.
				Else
					lRet := .F.
				Endif
			Endif
		Endif
	Next nX 

	If lRet
		dbSelectArea("ZZA")  
		ZZA->(dbSetOrder(2)) // ZZA_FILIAL+ZZA_CGCPRE+ZZA_ARQXML
		If dbseek(xFilial("ZZA")+aColsZAD[1][7]+aColsZAD[1][13])
			Reclock("ZZA",.f.)
			ZZA->ZZA_STATUS	:= '1'
			MsUnlock()
			//		oGetZAD:aCols:Refresh()
		EndIf	
	EndIf	 

	RestArea(aArea)

Return lRet                

Static Function IncCadFor(lOkFor,cPrestador,cTomador,cCodFor,cNomFor,cNomFan,cEnd,cCodMun,cEst,lCadFor)
	Local aArea	:= GetArea()

	If MsgYesNo( "O Fornecedor / Prestador "+cNomFor+" do arquivo XML: não está cadastrado. Deseja cadastrar?", "" )
		oProcess := MsNewProcess():New( { | lEnd | lOkFor := fCadForn(cPrestador,cTomador,cCodFor,cNomFor,cNomFan,cEnd,cCodMun,cEst,@lCadFor) }, "Atualizando", "Aguarde, atualizando ...", .F. )
		oProcess:Activate()

		If lOkFor
			MsgInfo( "Atualização Realizada.", "" )
		Else
			MsgStop( "Atualização não Realizada.", "" )
		EndIf
	EndIf

	RestArea(aArea)

Return(lOkFor)

Static Function fCadForn(cPrestador,cTomador,cCodFor,cNomFor,cNomFan,cEnd,cCodMun,cEst,lCadFor)

	Local cStrErro		:= ""
	Local aLog			:= {}	

	Private lMsErroAuto := .f.

	cCodFor := GetSxeNum("SA2","A2_COD")
	cCodMun := Substr(cCodMun,3,5)   

	If Len(cPrestador) == 14
		cTipo := 'J'
	ElseIf	Len(cPrestador) == 11
		cTipo := 'F'
	Else
		cTipo := 'X'
	EndIf

	aDados := {	{'A2_COD'		,cCodFor		,NIL},;		
	{'A2_LOJA'		,'01'			,NIL},;		
	{'A2_NOME'		,cNomFor		,NIL},;		
	{'A2_NREDUZ'		,cNomFan		,NIL},;		
	{'A2_EST'			,cEst			,NIL},;
	{'A2_END'			,cEnd			,NIL},;		
	{'A2_COD_MUN'		,cCodMun		,NIL},;
	{'A2_TIPO'		,cTipo			,NIL},;		
	{'A2_CGC'			,cPrestador		,NIL}} 

	MSExecAuto({|x, y| MATA020(x, y)},aDados, 3)	     

	If lMsErroAuto      
		MostraErro()
		aLog := GetAutoGRLog()
		For X := 1 To LEN(aLog)
			cStrErro += (Alltrim(aLog[X]) + CRLF )	
		Next X
	Else	
		cStrErro := ""	
		lCadFor := .T.
	EndIf

Return lCadFor                                     

Static Function VldProd(oItens,cPrestador,cObs,cIss,nAliqIss,cTipo,cNumNf,dDtEmis,nValor,cTomador,cDescri,cArqXMl,cEspeci,cStatus,cSerie,cChvNFE,cFilOri,cCodFor,cNomFor,cItens)

	Local cQuery := ""
	Local lProd := .F.

	cQuery := " SELECT B1_CODISS, B1_ALIQISS " 
	cQuery += " FROM "+RetSqlName("SB1")+" SB1 "
	cQuery += " WHERE B1_FILIAL = '"+xfilial("SB1")+"' "
	cQuery += "  AND B1_CODISS = '"+cIss+"'"
	cQuery += "  AND B1_ALIQISS = "+nAliqIss+""                              
	cQuery += "  AND SB1.D_E_L_E_T_ ='' "

	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),'TRBSB1',.T.,.T.)

	dbSelectArea( "TRBSB1" )
	DbGoTop()
	If TRBSB1->(EOF())
		lProd	:= .T.
		cStatus := "7"  
		cObs	:= "Produto nao Cadastrado"
		GravaZZA(cTipo,cNumNf,dDtEmis,nValor,cPrestador,cTomador,cDescri,cArqXMl,cEspeci,cStatus,cObs,cSerie,cChvNFE,cFilOri,cCodFor,cNomFor,cItens,.f.)
	EndIf

Return(lProd)