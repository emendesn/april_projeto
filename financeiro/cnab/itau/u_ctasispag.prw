User Function U_CTASISPAG//retornará para Sispag segmento "A" - Transferencia entre contas/Doc/Ted os dados bancarios conforme manual
Local cDadosbanc := ""

IF SUBS(SEA->EA_MODELO,1,2) == "01"     // SE FOR CREDITO EM CC (ITAU OU UNIBANCO)
   cDadosbanc := "0"+PADL(ALLTRIM(SUBST(SA2->A2_AGENCIA,1,4)), 4, "0")+' '+"000000"+PADL(ALLTRIM(SUBST(SA2->A2_NUMCON,1,6)), 6, "0")+" "+PADL(ALLTRIM(SUBST(SA2->A2_DVCTA,1,1)), 1, "0")
ELSE                                    // PARA OUTROS BANCOS (NO CASO TED OU DOC)
   cDadosbanc := PADL(ALLTRIM(SUBST(SA2->A2_AGENCIA,1,5)), 5, "0")+" "+PADL(ALLTRIM(SUBST(SA2->A2_NUMCON,1,12)), 12, "0")+" "+PADL(ALLTRIM(SUBST(SA2->A2_DVCTA,1,1)), 1, "0")
ENDIF

Return cDadosbanc                                                                                                                                                                                                        