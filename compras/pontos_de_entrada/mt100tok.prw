#INCLUDE "RWMAKE.CH"

/*
http://tdn.totvs.com/kbm#17143
TDN > Inteligência Protheus > Manufatura > Compras > Pontos de Entrada > MT100TOK

LOCALIZAÇÃO : Function A100TudOk() 

EM QUE PONTO : Apos a digitacao dos items do MATA100 ao confirmar encerrando a entrada de dados, depois 
de fazer todas as verificacoes normais e antes de iniciar o processo de gravacao dos dados.
*/

User Function MT100TOK()

Local lRet := .T.
/*
	Local _nPosPed := Ascan(aHeader,{|x| Alltrim(x[2]) == "D1_PEDIDO" })
	_aAreaF4 := GetArea()
	lRet:= .F.


	For i:=1 to len(aCols)

		If !Empty(Alltrim(aCols[n,_nPosPed]))
			lRet:= .T.
		Endif

	Next

	If !lRet
		MsgStop("É necessário informar o pedido de compras em ao menos 1 item."	,"A T E N Ç Ã O !!")
	Endif
	//Verificar a Natureza "padrão", no caso de MultiNaturezas
	//Lembrete para preencher o campo E2_DIRF.
	/*
	If MsgYesNo( 'Confirma?', 'UniversoADVPL' )
	MsgInfo( 'Sim', 'UniversoADVPL' )
	Else
	MsgInfo( 'Não', 'UniversoADVPL' )
	Endif
	
	RestArea(_aAreaF4)*/

Return(lRet)

User Function MT103FIM()

	Local nOpcao    := PARAMIXB[1]   // Opção Escolhida pelo usuario no aRotina 
	Local nConfirma := PARAMIXB[2]   // Se o usuario confirmou a operação de gravação da NFECODIGO DE APLICAÇÃO DO USUARIO.....
	Local cUpd      := "" 
	Local nError    := 0
	Local aArea     := GetArea()
	Local cUpd      := ""

	If INCLUI 
		If Posicione("SF4",1,xFilial("SD4")+SD1->D1_TES,"F4_CODIGO") == '010'
			cUpd := "UPDATE "+ RetSqlName("SN1") +" SET N1_AQUISIC ='"+DtoS(SF1->F1_EMISSAO)+"' "
			cUpd += " WHERE N1_NFISCAL = '"+Alltrim(cnFiscal)+"' AND N1_NSERIE= '"+Alltrim(CSERIE)+"' AND N1_FORNEC= '"+Alltrim(CA100FOR)+"' AND N1_LOJA= '"+Alltrim(CLOJA)+"'"

			nError := TCSQLExec(cUpd)

			If nError!=0
				Conout("Erro: "+tcSQLError())
				nError := 0
			Endif 
		Endif
	Endif
	//Efetuar Update com base no Pedido de Compras.
	
	
	RestArea(aArea)

Return

User Function MT120GRV

	Local lRet := .T.
	Local cNum  := PARAMIXB[1]
	Local lAltera := ParamIxb[3]
	nQuant := 0

	If lAltera
		nQuant := SC7->C7_NENVIO+1
		cUpd := "UPDATE "+ RetSqlName("SC7") +" SET C7_NENVIO ="+Str(nQuant)+" WHERE C7_NUM = '"+cNum+"' AND D_E_L_E_T_<>'*'"

		nError := TCSQLExec(cUpd)

		If nError!=0
			Alert("Erro: "+tcSQLError())
			nError := 0
		Endif 
	Endif

Return lRet