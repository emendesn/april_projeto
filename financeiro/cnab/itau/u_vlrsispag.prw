#include 'protheus.ch'
#include 'parmtype.ch'
#include 'topconn.ch'

User Function U_VLRSISPAG//retornará para Sispag segmento "J" - Valor total, ou seja, valor + acrescimos - descrescimos
	Local nValor := 0

	nValor := STRZERO(((SE2->E2_SALDO+SE2->E2_ACRESC-SE2->E2_DECRESC)*100),15)            

Return nValor      

User Function F240SUM ()

	Local nVlr

	nVlr := SE2->E2_SALDO+SE2->E2_ACRESC-SE2->E2_DECRESC

Return nVlr

User Function F420SUMD()
	Local nVlr

	nVlr := SE2->E2_SALDO+SE2->E2_ACRESC-SE2->E2_DECRESC

Return nVlr