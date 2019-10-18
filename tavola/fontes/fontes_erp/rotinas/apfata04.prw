#include 'protheus.ch'
#include 'parmtype.ch'

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} APFATA04
@sample.....: Rotina atualizar nosso numero SE1
@return.....: 
@author.....: Edie Carlos
@since......: 26/10/2017
@version....: P12
/*/
//------------------------------------------------------------------------------------------

user function APFATA04()

Local _cAlias     := GetNextAlias()




	BeginSql Alias _cAlias
	
		%noParser%
	
		SELECT *                        
		FROM
		%Table:SZ1% SZ1  
		Where Z1_NUMBCO <> ''
		AND   Z1_STATTP = '' 
		AND   Z1_CANC    = ''
		
	EndSql
	(_cAlias)->( DbGotop() )
	
	While  (_cAlias)->(!EOF())
		
		//ATUALIZA TABELA 
		cUpdSE1 := " UPDATE " + RetSqlName("SE1") + " SET E1_NUMBCO ='"+(_cAlias)->Z1_NUMBCO+"'  "
		cUpdSE1 += " WHERE E1_FILIAL='"+(_cAlias)->Z1_FILIAL+"' AND E1_XFATURA = '"+(_cAlias)->Z1_FATURA+"' AND E1_PARCELA= '"+(_cAlias)->Z1_PARCELA+"'"
		TcSqlExec(cUpdSE1) 	
	
		(_cAlias)->(dbSkip())
	EndDo
	
	(_cAlias)->(dbCloseArea())
	
return