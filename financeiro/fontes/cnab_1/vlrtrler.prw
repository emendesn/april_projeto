#Include "Protheus.ch"
#Include "Rwmake.ch"

#DEFINE ENTER CHR(13)+CHR(10)

/*�����������������������������������������������������������������������������������������
�������������������������������������������������������������������������������������������
����������������������������������������������������������������������������������������"��
��� Programa      � VLRTRLER                                       � Data � 05/05/2014  ���
���������������������������������������������������������������������������������������͹��
��� Descricao     � Fonte para Calculo do Trailer do Lote Santander Posicao (024 a 041) ���
���������������������������������������������������������������������������������������͹��
��� Desenvolvedor � Eduardo Augusto      � Empresa � Totvs Nacoes Unidas                ���
���������������������������������������������������������������������������������������͹��
��� Linguagem     � Advpl      � Versao � 11    � Sistema � Microsiga                   ���
���������������������������������������������������������������������������������������͹��
��� Modulo(s)     � SIGAFIN                                                             ���
���������������������������������������������������������������������������������������͹��
��� Tabela(s)     � SEA                                                                 ���
���������������������������������������������������������������������������������������͹��
��� Observacao    �                                                                     ���
���������������������������������������������������������������������������������������ͼ��
�������������������������������������������������������������������������������������������
�������������������������������������������������������������������������������������������
�������������������������������������������������������������������������������������������
�������������������������������������������������������������������������������������������
����������������������������������������������������������������������������������������"��
���                                      ATUALIZACOES                                   ���
���������������������������������������������������������������������������������������͹��
��� Desenvolvedor � Data      �  Alteracao                                              ���
���������������������������������������������������������������������������������������͹��
���               �           �                                                         ���
���������������������������������������������������������������������������������������ͼ��
�������������������������������������������������������������������������������������������
�����������������������������������������������������������������������������������������*/

User Function VLRTRLER()

	Local cRet		:= ""
	Local cQuery	:= ""
	
	cQuery := " SELECT SUM(E2_SALDO + E2_ACRESC - E2_DECRESC + E2_JUROS + E2_MULTA) VALOR, E2_NUMBOR FROM " + RetSqlName("SE2") + " SE2 " + ENTER
	cQuery += " WHERE SE2.E2_FILIAL = '" + xFilial("SE2")+ "' " + ENTER
	cQuery += " AND SE2.D_E_L_E_T_ = ' ' " + ENTER
	cQuery += " AND SE2.E2_NUMBOR = '" + SEA->EA_NUMBOR + "' " + ENTER
	cQuery += " GROUP BY SE2.E2_NUMBOR "
	cQuery := ChangeQuery(cQuery)
	
	If Select("TMP") > 0
		TMP->(DbCloseArea())
	EndIf                                         
	
	DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), 'TMP', .F., .T.)
	TcSetField("TMP","VALOR" ,"N",12,2)
	DbSelectArea("TMP")
	DbGoTop()
	cRet := PadL(StrTran(Alltrim(StrTran(Transform(NoRound(TMP->VALOR),"@E 999,999,999,999,999.99"),",","")),".",""),18,"0")
	DbSelectArea("TMP")
	DbSkip()
	TMP->(DbCloseArea())

Return cRet  