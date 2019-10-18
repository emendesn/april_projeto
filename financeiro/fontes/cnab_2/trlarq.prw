#INCLUDE "PROTHEUS.CH"


/*���������������������������������������������������������������������������
���Programa  �TRLARQ     �Autor  �EDUARDO AUGUSTO    � Data �  28/08/2012 ���
�������������������������������������������������������������������������͹��
���Desc.     �PROGRAMA PARA TRATAMENTO DO TRAILLER DO ARQUIVO DE CNAB DE  ���
���          �TODOS OS SEGMENTOS REFERENTE A QUANTIDADE DE REGISTROS.     ���
�������������������������������������������������������������������������͹��
���Uso       � RESITECH                                                   ���
���������������������������������������������������������������������������*/

User Function TRLARQ()

cRet := ""
//TRATAMENTO PARA O TRAILLER DO ARQUIVO DOS SEGMENTOS J / N / O / W
If SEA->EA_MODELO$"11/13/30/31/16/17/18/19/20/21/22/23/24/25/26/27/35"
	cRet := STRZERO(M->NSEQ+4,6)
ElseIf SEA->EA_MODELO$"01/02/03/04/05/10/34/41/43/50"//TRATAMENTO PARA O TRAILLER DO ARQUIVO DOS SEGMENTOS A / B / D
	cRet := STRZERO((NSEQ+2)*2,6)
Else
	cRet := STRZERO(0,6)	
EndIf
Return(cRet)