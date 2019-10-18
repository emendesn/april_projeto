#Include 'Protheus.ch'

/*/{Protheus.doc} ChecarErro
Retornar Erro em tempo de execução
@type 		User function
@author 	Totvs Nações Unidas - Ivan de Oliveira - 
@since 		12/09/2017
@version 	1.0

@Param  	${Objeto}, ${e}		- Objeto do erro em tempo de execução
@return 	${Lógico}, ${Lret}	- Retorno do processo.

@example 
EFATM001(e, _cLin, _cExpr )
 /*/

User Function EFATM001(e, _cLin, _cExpr)

Local _cDescErro := Upper(e:ErrorStack)
Local _nPos      := at('LINE', _cDescErro)
Local _lRet		 := .t.

_cLin  := 's/id'
_cExpr := ''

if _nPos > 0
 
 	_cLin := Substr(_cDescErro, _nPos, 10 )
 	_lRet := .F.
 	
 Endif
 
 if !empty(e:Description)
 
 	_cExpr := e:Description
 	_lRet  := .F.
 	
 Endif
 
Return _lRet

 

