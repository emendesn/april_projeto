#include 'protheus.ch'
#include 'parmtype.ch'

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} M460MARK
@sample.....: Verificar se as parcelas foram integradas!
@return.....: 
@author.....: Edie Carlos
@since......: 26/10/2017
@version....: P12
/*/
//------------------------------------------------------------------------------------------


user function M460MARK()
Local aAreaSC9 := SC9->(GetArea())
Local aAreaSC5 := SC5->(GetArea())
Local _lRet          := .T.
Local _cMark      := PARAMIXB[1] 

/*
±±ºDesc.     ³Verifica se a TES atualiza estoque e se a virada de saldo   º±±
±±º          ³já foi realizada                                           º±±
*/
If SC9->C9_OK == _cMark 
	If SC5->(dbSetOrder(1), dbSeek(xFilial("SC5")+SC9->C9_PEDIDO))
		IF Empty(SC5->C5_XCOSMOS) .AND. !Empty(SC5->C5_XFATURA)
			dbSelectArea("SZ1")
			SZ1->(dbSetOrder(1))
			
			If !SZ1->(dbSeek(xFilial("SZ1")+SC5->C5_XFATURA))
					AVISO("ATENCAO","NAO É POSSIVEL FATURAR O PEDIDO:"+SC9->C9_PEDIDO+" NAO FOI INTEGRADO A(S) PARCELA(S) DESSE PEDIDO..",{"OK"})
				_lRet := .f.
			Endif
		ENDIF	
	Endif
Endif

RestArea(aAreaSC9)
RestArea(aAreaSC5)


Return _lRet
	
