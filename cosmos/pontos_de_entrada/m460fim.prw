#include 'protheus.ch'
#include 'parmtype.ch'


/*/{Protheus.doc} M460FIM
Ponto de Entrada para atualizar tabela MIDDLEWARE 
da empresa  APRIL BRASIL TURISMO VIAGENS E ASSISTENCIA INTERNACIONAL LTDA, 
com o objetivo de atualizar numero da Fatura na tabela Ponte Customizada SZ0.
@type 	Ponto de Entrada
@author Edie Carlos - TNU
@since 	23/10/2017 
/*/

User function M460FIM()
	Local 	aArea	:=	GetArea()
	Local   cUpdSE1 := ""
	/*
	//INTEGRAÇÃO COSMOS
		IF !Empty(SC5->C5_XNUMID)
		//ATUALIZA TITULO CODIGO COSMOS
		cUpdSE1 := " UPDATE " + RetSqlName("SE1") + " SET E1_XNUMID ='"+SC5->C5_XNUMID+"' "
		cUpdSE1 += " WHERE E1_PREFIXO = '"+SF2->F2_SERIE+"' AND E1_NUM ='"+SF2->F2_DOC+"' "
		cUpdSE1 += " AND E1_FILIAL='"+xFilial("SE1")+"' AND E1_CLIENTE ='"+SF2->F2_CLIENTE+"' AND E1_LOJA ='"+SF2->F2_LOJA+"' "
		TcSqlExec(cUpdSE1)
	ENDIF

	RestArea(aArea)
*/
return()