#Include "Protheus.ch"
#INCLUDE "TBICONN.CH"

#DEFINE _APROVADOR "A"
#DEFINE _DIRETOR "01"


/*
 * Compras - Aprovação de Pedido de Compra

@ALTERACOES:
@ 01/07/16 - Zema - Excluir as colunas de centro de custos e item contábil. Inserir a classe de valores nos itens
 */
User Function CAPROVPC
           
	Private _pPedido 	:= 2,;
			_pForn 		:= 3,;
			_pTicket 	:= 4,;
			_pItem		:= 5,;
			_pProd		:= 6,;
			_pValor		:= 7,;
			_pCCusto	:= 8,;
			_pOutput    := 9,;
			_pUsuario	:= 10,;
			_pData		:= 11,;
			_pFPag		:= 12,;
			_pNatureza	:= 13,;
			_pTES		:= 14,;
			_pVUnit		:= 15,;
			_pQtd		:= 16,;
			_pFrete		:= 17,;
			_pMoeda		:= 18,;
			_pCodOrca	:= 19,;
			_pOrca		:= 20,;
			_pDtRef		:= 21,;
			_pCodForn	:= 22,;
			_pClasse	:= 23  // Zema 01/07/16
		
    Private	oOk := LoadBitmap(GetResources(),"LBOK")
	Private	oNo := LoadBitmap(GetResources(),"LBNO")
	Private	oMainLst, aMainLst := {}, aMainMap := Nil
	Private	oSubLst, aSubLst := {}, aSubMap := Nil
	Private cNivel := "00", lAprov := .F.
	Private cAprov := GetAprov(__CUSERID,@cNivel,@lAprov)
	Private aItensPC := {} 
	Private lViewAll := .F.

//	aSubMap := {_pItem,_pProd,_pQtd,_pMoeda,_pVUnit,_pValor,_pFrete,_pCCusto,_pOutput,_pTES}  // Zema 01/07/16
//	aMainMap := {1,_pPedido,_pForn,_pTicket,_pValor,_pFPag,_pNatureza,_pOrca,_pUsuario,_pCCusto,_pData}  // Zema 01/07/16
	aSubMap := {_pItem,_pProd,_pQtd,_pMoeda,_pVUnit,_pValor,_pFrete,_pClasse,_pTES}  // Zema 01/07/16
	aMainMap := {1,_pPedido,_pForn,_pTicket,_pValor,_pFPag,_pNatureza,_pOrca,_pUsuario,_pData}  // Zema 01/07/16

			
	Define MsDialog oDlg Title "Aprovação de Pedido de Compra" From (100),(100) to (750),(1200) Pixel
    
	@05,05 Button "Marcar" Size 37,12 PIXEL OF oDlg action	(ChgState(aMainLst,.T.))
	@05,45 Button "Desmarcar" Size 37,12 PIXEL OF oDlg action	(ChgState(aMainLst,.F.))
	if (__CUSERID == "000000" .Or. cNivel == _DIRETOR)
		@05,505 Checkbox oViewAll Var lViewAll Prompt 'Ver Todos' Size 100,210 Pixel of oDlg
		oViewAll:bSetGet 	:= {|| lViewAll }
		oViewAll:bLClicked	:= {|| lViewAll := !lViewAll, LoadMainL() }
		oViewAll:bWhen		:= {|| .T. }
	endif
	
	@20,05 Say "Pedidos Pendentes" Size 18,08 COLOR CLR_BLACK PIXEL OF oDlg
//	@30,05 ListBox oMainLst Fields Header "","Pedido","Fornecedor","Ticket","Valor (R$)","F.Pag.","Natureza","Orcamento","Solicitante","C.Custo","Data" Pixel Size 540,150 of oDlg ;  // Zema 01/07/16
	@30,05 ListBox oMainLst Fields Header "","Pedido","Fornecedor","Ticket","Valor (R$)","F.Pag.","Natureza","Orcamento","Solicitante","Data" Pixel Size 540,150 of oDlg ;  // Zema 01/07/16
		on dblClick(aMainLst[oMainLst:nAt,1] := !aMainLst[oMainLst:nAt,1], oMainLst:Refresh()) ;
		on change (ChgSubLst(oMainLst:nAt))
		
	oMainLst:bHeaderClick := {|oBrw,nCol| SortBy(oMainLst,aMainMap,nCol)}
	
	@190, 05 Say "Itens do pedido" Size 100,08 COLOR CLR_BLACK PIXEL OF oDlg
//	@200, 05 ListBox oSubLst Fields Header "Item","Produto","Qtd","Moeda","V.Unit","Total","Frete","C.Custo","Output","TES" Pixel Size 540,100 of oDlg  // Zema 01/07/16
	@200, 05 ListBox oSubLst Fields Header "Item","Produto","Qtd","Moeda","V.Unit","Total","Frete","Projeto","TES" Pixel Size 540,100 of oDlg 	
	
	oSubLst:bHeaderClick := {|oBrw,nCol| SortBy(oSubLst,aSubMap,nCol)}    

	@305,05 Button "Cancelar" Size 37,12 PIXEL OF oDlg action	(oDlg:end())
	@305,505 Button "Aprovar" Size 37,12 PIXEL OF oDlg action	(SetAprov(aMainLst,__CUSERID,cAprov), LoadMainL()) When lAprov

	LoadMainL()
		
	Activate MsDialog oDlg Centered
			
Return

Static Function SortBy(oLst, aMap, nCol )
        
	Local bTmpLine := oLst:bLine
	Local nPos := aMap[nCol]
	oLst:SetArray( aSort( oLst:aArray,,, { |x, y| x[nPos] < y[nPos] }) )
	oLst:nAt := 1
	oLst:bLine := bTmpLine
	oLst:Refresh()
	
Return


Static Function ChgSubLst(nPos)     
                
	Local cPed
    Local nC
    
	aSubLst := {}    

	oSubLst:SetArray(aSubLst)
		                                //_pCodOrca  
	if len(aMainLst) > 0

		
		IF cEmpAnt == "02"
	
			cPed 	:= aMainLst[nPos,_pPedido]+aMainLst[nPos,_pCodOrca]	
		
			for nC := 1 to len(aItensPC)
				if aItensPC[nC,_pPedido]+aItensPC[nC,_pCodOrca] == cPed
					AADD(aSubLst,aItensPC[nC])
				endif
			next		
		
		ELSE
	
			cPed 	:= aMainLst[nPos,_pPedido]

			for nC := 1 to len(aItensPC)
				if aItensPC[nC,2] == cPed
					AADD(aSubLst,aItensPC[nC])
				endif
			next
	
		ENDIF
	
		oSubLst:SetArray(aSubLst)                 

		oSubLst:bLine := {||{aSubLst[oSubLst:nAt,_pItem],aSubLst[oSubLst:nAt,_pProd],aSubLst[oSubLst:nAt,_pQtd],aSubLst[oSubLst:nAt,_pMoeda],;
			alltrim(transform(aSubLst[oSubLst:nAt,_pVUnit],"@E 9,999,999.99")),;
			alltrim(transform(aSubLst[oSubLst:nAt,_pValor],"@E 9,999,999.99")),;                                                                                                        
			alltrim(transform(aSubLst[oSubLst:nAt,_pFrete],"@E 9,999,999.99")),aSubLst[oSubLst:nAt,_pClasse],aSubLst[oSubLst:nAt,_pTES]}} // Zema 01/07/16			
//			alltrim(transform(aSubLst[oSubLst:nAt,_pFrete],"@E 9,999,999.99")),aSubLst[oSubLst:nAt,_pCCusto],aSubLst[oSubLst:nAt,_pOutput],aSubLst[oSubLst:nAt,_pTES]}} // Zema 01/07/16
	else
//		oSubLst:bLine := {||{"","","","","","","","","",""}}// Zema 01/07/16
		oSubLst:bLine := {||{"","","","","","","","",""}}// Zema 01/07/16		
	endif
	oSubLst:Refresh()
Return


Static Function LoadMainL()

	aMainLst := {}	    
	                       
	IF cEmpAnt == "02"
	
		Processa({||aItensPC := LoadData2(@aMainLst),"Carregando Pedidos"})
		
	ELSE 

		Processa({||aItensPC := LoadData(@aMainLst),"Carregando Pedidos"})	
	
	ENDIF	
	                    
	oMainLst:SetArray(aMainLst)
		
	if Len(aMainLst) >= 1
		oMainLst:nAt := 1
		
		oMainLst:bLine := {||{iif(aMainLst[oMainLst:nAt,1],oOk,oNo),;
			aMainLst[oMainLst:nAt,_pPedido],aMainLst[oMainLst:nAt,_pForn],aMainLst[oMainLst:nAt,_pTicket],;
			AllTrim(transform(aMainLst[oMainLst:nAt,_pValor],"@E 9,999,999.99")),aMainLst[oMainLst:nAt,_pFPag],aMainLst[oMainLst:nAt,_pNatureza],;         
			aMainLst[oMainLst:nAt,_pOrca],aMainLst[oMainLst:nAt,_pUsuario],aMainLst[oMainLst:nAt,_pData]}} // Zema 01/07/16			
//			aMainLst[oMainLst:nAt,_pOrca],aMainLst[oMainLst:nAt,_pUsuario],aMainLst[oMainLst:nAt,_pCCusto],aMainLst[oMainLst:nAt,_pData]}} // Zema 01/07/16

		ChgSubLst(1) 
	else    
		oMainLst:bLine := {||{oNo,;
			"","","",;
			"","","",;                   
			"","",""}}    //Zema 01/07/16			
//			"","","",""}} //Zema 01/07/16
			
		ChgSubLst(0) 
		
		MsgInfo("Nenhum Pedido de Compra pendente para aprovação")
	endif                                                        
	
	oMainLst:Refresh()
Return

Static Function LoadData(aHeader) 

	// CR_STATUS: 02 = PENDENTE, 03 = APROVADO, 04 = BLOQUEADO
	Local cQPend := ""
	Local aPed := Nil
	Local aNum := {}, aTot := {}
	Local nQtd := 0
	Local nPos := 0
	Local lPri := .f., lAdd := .f.
	Local nC := 0
	
	if !lViewAll .And. cAprov <> Nil
		cQPend := "SELECT C7_NUM, SUM((C7_TOTAL+C7_VALIPI+C7_DESPESA+C7_FRETE-C7_VLDESC) * " +;
				"(CASE WHEN C7_TXMOEDA = 0 THEN 1 ELSE C7_TXMOEDA END)) AS C7_TOTAL FROM " + RetSqlName("SC7") + " AS SC7 INNER JOIN " + RetSqlName("SAL") +;
				" AS SAL ON (SAL.D_E_L_E_T_ <> '*' AND AL_FILIAL = '" + xFilial("SAL") + "' AND AL_COD = C7_APROV AND AL_USER = '" + __CUSERID + "')" + ;
				" WHERE SC7.D_E_L_E_T_ <> '*' AND C7_CONAPRO <> 'L' AND C7_FILIAL = '" + xFilial("SC7") + "' GROUP BY C7_NUM"
	else
		cQPend := "SELECT C7_NUM, SUM((C7_TOTAL+C7_VALIPI+C7_DESPESA+C7_FRETE-C7_VLDESC) * " +;
				"(CASE WHEN C7_TXMOEDA = 0 THEN 1 ELSE C7_TXMOEDA END)) AS C7_TOTAL FROM " + RetSqlName("SC7") + " AS SC7 " +;
				" WHERE SC7.D_E_L_E_T_ <> '*' AND C7_CONAPRO <> 'L' AND C7_FILIAL = '" + xFilial("SC7") + "' GROUP BY C7_NUM"
	endif
		
	dbUseArea(.T.,"TOPCONN", TCGenQry(,,cQPend),"QRA", .F., .T.)	
	Dbselectarea("QRA")
	Dbgotop()
	
	While QRA->(!eof()) 
		cNumPed := AllTrim(QRA->C7_NUM) 
		if ASCAN(aNum,cNumPed) == 0
			AAdd(aNum,cNumPed)
			AAdd(aTot,QRA->C7_TOTAL)  
		endif
		QRA->(dbskip())
	enddo
	
	DbSelectArea("QRA")
	dbCloseArea("QRA")  
	
	if Len(aNum) > 0   
		ProcRegua(Len(aNum))
		aPed := {}
	
		DbSelectArea("SC7")	
		SC7->(Dbsetorder(1))
		
		for nC := 1 to len(aNum)
			
			SC7->(Dbseek(xFilial("SC7") + aNum[nC],.T.))
				
			lPri := .t.       
			lAdd := .f.
			nPos := nPos + 1

			IncProc("Carregando Pedido " + 	aNum[nC])
			While SC7->(!eof()) .and. AllTrim(SC7->C7_NUM) == aNum[nC]
				AADD(aPed,{.f.,;
						SC7->C7_NUM,;                											// 02 = Pedido
						AllTrim(Posicione("SA2",1,xFilial("SA2")+SC7->C7_FORNECE,"A2_NOME")),;	// 03 = Fornecedor
						AllTrim(SC7->C7_TICKET),;                                    				// 04 = Ticket
						SC7->C7_ITEM,;																// 05 = Item do Ped.
						IIF(LEN(AllTrim(SC7->C7_DESCRI)) == 0,;
							AllTrim(Posicione("SB1",1,xFilial("SB1")+SC7->C7_PRODUTO,"B1_DESC")),;
							AllTrim(SC7->C7_DESCRI)),;												// 06 = Produto
						SC7->C7_TOTAL+SC7->C7_VALIPI+SC7->C7_DESPESA+SC7->C7_FRETE-SC7->C7_VLDESC,;	// 07 = Total do Item
						AllTrim(Posicione("CTT",1,xFilial("CTT")+SC7->C7_CC,"CTT_DESC01")),;		// 08 = C.Custo
						AllTrim(Posicione("CTD",1,xFilial("CTD")+SC7->C7_ITEMCTA,"CTD_DESC01")),;	// 09 = Output
						AllTrim(GetUser(SC7->C7_USER)),;											// 10 = Usuário
						SC7->C7_EMISSAO,;                                               			// 11 = Date de Emissao
						AllTrim(Posicione("SX5",1,xFilial("SX5")+"24"+SC7->C7_FORMPAG,"X5_DESCRI")),;	// 12 = Forma de Pagamento
						AllTrim(Posicione("SED",1,xFilial("SED")+SC7->C7_NATUREZ,"ED_DESCRIC")),;		// 13 = Natureza
						AllTrim(Posicione("SF4",1,xFilial("SF4")+SC7->C7_TES,"F4_TEXTO")),;				// 14 = TES
						SC7->C7_PRECO,;						   											// 15 = Valor Unitário
						SC7->C7_QUANT,;																	// 16 = Quantidade
						SC7->C7_VALFRE,;																// 17 = Frete
						IIF(SC7->C7_MOEDA == 1,"R$","US$"),;											// 18 = Moeda
						SC7->C7_ORCA,;																	// 19 = Cod Orcamento
						AllTrim(POSICIONE("SZ7",1,SC7->C7_ORCA,"Z7_DESC")) +;
							IF(POSICIONE("SZ7",1,SC7->C7_ORCA,"Z7_TIPO")=="1",;
								"("+SUBSTR(DTOC(SC7->C7_DTREF),4,6)+")",""),;							// 20 = Orcamento
						SC7->C7_DTREF,;																	// 21 = Data Referencia
						SC7->C7_FORNECE,;																// 22 = Cod. Fornecedor
						AllTrim(Posicione("CTH",1,xFilial("CTH")+SC7->C7_CLVL,"CTH_DESC01"));																	// 23 = Classe de Valores - Projeto
						})
					
				if lPri
				
					aInner := {}
					for nD := 1 to len(aPed[nQtd+1])
						AADD(aInner,aPed[nQtd+1,nD])
					next
					
					AADD(aHeader,aInner)
					lAdd := .t.
				endif
				
				lPri := .f.
	
				SC7->(dbskip())
				nQtd := nQtd + 1
			enddo
			        
			if len(aHeader) >= nPos .And. lAdd
				aHeader[nPos,_pValor] := aTot[nC]
			endif
			
		next
		
		DbSelectArea("SC7")
		dbCloseArea("SC7")
	endif
	
Return aPed

Static Function ChgState(aPeds, lState)
	Local nC := 0
	for nC := 1 to len(aPeds)
		aPeds[nC,1] := lState
	next
Return

Static Function GetUser(cUser)

	Local cNome := ""
	
	PswOrder(1)
	if PswSeek(cUser,.t.)
		cNome = PswRet()[1][2]
	endif
	
Return cNome

Static Function GetAprov(cUser, cNivel, lAprov)

	Local cCod := Nil
	
	Dbselectarea("SAK")
	SAK->(Dbsetorder(2))
	SAK->(Dbgotop())
	
	if SAK->(Dbseek(xFilial("SAK") + cUser))
		cCod = SAK->AK_COD
	elseif cUser == "000000"
		cCod := cUser
	else
		Alert("Usuário não é aprovador de Pedido de Compra")
	endif
	
	DbSelectArea("SAK")
	dbCloseArea("SAK")
	
	Dbselectarea("SAL")
	SAL->(Dbsetorder(3))
	SAL->(Dbgotop())
	                   
	cNivel := Nil
	WHILE SAL->(!EOF()) .And. cNivel == Nil
		IF SAL->AL_APROV == cCod
			cNivel 	:= SAL->AL_NIVEL
			lAprov	:= SAL->AL_LIBAPR == _APROVADOR
		ENDIF
		SAL->(DBSKIP())
	ENDDO

	DbSelectArea("SAL")
	dbCloseArea("SAL")
		
Return cCod

Static Function CanAprov(cOrca, cUser, dRef, nValor, cFornece,pSimul)
      
    Local nGasto := 0    
    Local lSimul := IF(TYPE("pSimul") == "L", pSimul, .F.)
    
   	if LEN(ALLTRIM(cOrca)) == 0
//  		Alert("Pedido liberado sem orçamento vinculado")
		Alert("Pedido sem numero de orçamento vinculado !")
		return (.F.)		
	endif
    
	DbSelectArea("SZ7")	
	SZ7->(dbSetOrder(1))
	if SZ7->(dbSeek(cOrca), .T.)       
		    
		if SZ7->Z7_RESP <> cUser .And. "01" <> cNivel
			Alert("Vc não tem permissão de aprovar pedidos do orcamento: " + AllTrim(SZ7->Z7_DESC))
			return(.F.)
		endif
		
		if SZ7->Z7_TIPO == "1" .And. (;
			(SZ7->Z7_FORNEC1 <> cFornece) .And. (SZ7->Z7_FORNEC2 <> cFornece) .And. (SZ7->Z7_FORNEC3 <> cFornece) .And.;
			(SZ7->Z7_FORNEC4 <> cFornece) .And. (SZ7->Z7_FORNEC5 <> cFornece) .And. (SZ7->Z7_FORNEC6 <> cFornece .And. (SZ7->Z7_FORNEC7 <> cFornece)))			
			Alert("Não eh permitido pedidos do orçamento " + SZ7->Z7_DESC + " para o fornecedor " + cFornece)
			return(.F.)
		endif

		if SZ7->Z7_DTLIMIT <> Nil .And. SZ7->Z7_DTLIMIT < dRef
			Alert("Pedido não pode ser aprovado em um orcamento encerrado")
			return(.F.)			
		endif
		
		nGasto := U_CCALCORC(cOrca, dRef, SZ7->Z7_TIPO)	
		                           
		if SZ7->Z7_VALOR >= (nGasto + nValor)
			if SZ7->Z7_TIPO <> "1" .Or. (SUBSTR(DTOC(dRef), 4, 6) == SUBSTR(DTOC(dDatabase), 4, 6)) .AND. !lSimul
				RecLock("SZ7",.f.)
				SZ7->Z7_TOTAL := nValor + nGasto
				MsUnlock()
			endif
			
			return(.T.)
		endif
		
		Alert("Pedido não pode ser liberado por limite de orçamento. Ultrapassou em R$ " + cValToChar( (nGasto + nValor) - SZ7->Z7_VALOR ) )
	else   
  		Alert("Pedido liberado sem orçamento vinculado")
		return (.t.)
	endif
	
Return(.F.)

Static Function SetAprov(aLista, cUser, cAprov)
                              
	Local cPed := nil, nCount := 0, lCanAprov := .F.
	Local nC := 0
	            
	            
	IF cEmpAnt == "02"  
		SetAprov2(aLista, cUser, cAprov)
		Return
	ENDIF		            
	            
	            
	                
	//-- Inicializa a gravacao dos lancamentos do SIGAPCO
	PcoIniLan("000055")

	
	for nC := 1 to len(aLista)
	
		if aLista[nC,1]
			cPed := aLista[nC,_pPedido]
			nCount += 1		           
				
			lCanAprov := .F.
			
			if CanAprov(aLista[nC,_pCodOrca], cAprov, aLista[nC,_pDtRef], aLista[nC,_pValor], aLista[nC,_pCodForn])
				    
				lCanAprov := .T.
				
				DbSelectArea("SC7")	
				SC7->(Dbsetorder(1))
			
				if SC7->(Dbseek(xFilial("SC7") + cPed,.T.))
				
					while SC7->C7_NUM == cPed
						RecLock("SC7",.f.)
						SC7->C7_CONAPRO := "L"
						MsUnlock()       
						
						PcoDetLan("000055","02","MATA097")						
						
						SC7->(dbskip())
					enddo
				else
					Alert("Pedido nao encontrado: " + cPed)					
				endif
			endif
			
			DbSelectArea("SC7")
			dbCloseArea("SC7")

			if lCanAprov
				// CR_STATUS: 02 = PENDENTE, 03 = APROVADO, 04 = BLOQUEADO
				Dbselectarea("SCR")
				SCR->(dbSetOrder(2))	// Filial, Tipo, Num, User
				
				if SCR->(Dbseek(xFilial("SCR") + "PC" + cPed,.T.))
					while AllTrim(SCR->CR_NUM) == cPed
						RecLock("SCR",.f.)
						SCR->CR_STATUS := '03'
						SCR->CR_DATALIB := ddatabase
						SCR->CR_USERLIB := cUser
						SCR->CR_LIBAPRO := cAprov
						MsUnlock()
						SCR->(dbskip())
					enddo
				endif
				
				DbSelectArea("SCR")
				dbCloseArea("SCR")
			endif
		endif
	next

	PcoFinLan("000052")

	if nCount == 0		
		Alert("Nenhum pedido de compra selecionado")
	elseif lCanAprov
		MsgInfo(cValToChar(nCount) + " Pedido(s) de compra liberado(s)")
	endif
	
Return                  

Static Function SetAprov2(aLista, cUser, cAprov)
                              
	Local cPed := nil, nCount := 0, lCanAprov := .F.
	Local nC := 0   
	Local aAprov := {}    
	Local nX     := 0
	Local aLidos := {}
	                
	//-- Inicializa a gravacao dos lancamentos do SIGAPCO
	PcoIniLan("000055")
    
	nC := 1
	WHILE nC <= LEN(aLista)

		cPed := aLista[nC,_pPedido]

		if aLista[nC,1]	.AND. ASCAN(aLidos,cPed) == 0	 	

			nCount += 1	
			AADD(aLidos,cPed)	           
             
			// Totaliza por orçamento

			DbSelectArea("SC7")	
			SC7->(Dbsetorder(1))
			                   
			aProv := {}     
			
			lCanAprov := .T.			                
			
			if SC7->(Dbseek(xFilial("SC7") + cPed,.T.))
				while SC7->C7_NUM == cPed 
					
					nValOrc := (C7_TOTAL+C7_VALIPI+C7_DESPESA+C7_FRETE-C7_VLDESC) * IF(SC7->C7_TXMOEDA == 0, 1 ,SC7->C7_TXMOEDA)					
					
					IF (nPOR := ASCAN(aProv,{|x| x[1] == SC7->C7_ORCA})) == 0     
						AADD(aAprov, {SC7->C7_ORCA,nValOrc})
					ELSE
						aAprov[nPOR][2] += nValOrc
					ENDIF	 
										      	
				    SC7->(DBSKIP())
				END

				For nX := 1 TO LEN(aAprov)
					if !CanAprov(aAprov[nX][1], cAprov, aLista[nC,_pDtRef], aAprov[nX][2], aLista[nC,_pCodForn],.T.)				
						lCanAprov := .F.  
						EXIT
					ENDIF
				Next nX
			
				if lCanAprov
					lCanAprov := .F.
					if CanAprov(aLista[nC,_pCodOrca], cAprov, aLista[nC,_pDtRef], aLista[nC,_pValor], aLista[nC,_pCodForn],.F.)
				    

						DbSelectArea("SC7")	
						SC7->(Dbsetorder(1))
			
						if SC7->(Dbseek(xFilial("SC7") + cPed,.T.))
				
							while SC7->C7_NUM == cPed
								RecLock("SC7",.f.)
								SC7->C7_CONAPRO := "L"
								MsUnlock()       
						
								PcoDetLan("000055","02","MATA097")						
						
								SC7->(dbskip())
							enddo
							
							lCanAprov := .T.							
							
						else
							Alert("Pedido nao encontrado: " + cPed)					
						endif
					endif
				endif			
			else 
				Alert("Pedido nao encontrado: " + cPed)								
			endif
			//DbSelectArea("SC7")
			//dbCloseArea("SC7")

			if lCanAprov
				// CR_STATUS: 02 = PENDENTE, 03 = APROVADO, 04 = BLOQUEADO
				Dbselectarea("SCR")
				SCR->(dbSetOrder(2))	// Filial, Tipo, Num, User
				
				if SCR->(Dbseek(xFilial("SCR") + "PC" + cPed,.T.))
					while AllTrim(SCR->CR_NUM) == cPed
						RecLock("SCR",.f.)
						SCR->CR_STATUS := '03'
						SCR->CR_DATALIB := ddatabase
						SCR->CR_USERLIB := cUser
						SCR->CR_LIBAPRO := cAprov
						MsUnlock()
						SCR->(dbskip())
					enddo
				endif
				
				DbSelectArea("SCR")
				dbCloseArea("SCR")
			endif
		endif
		nC++
	end

	PcoFinLan("000055")

	if nCount == 0		
		Alert("Nenhum pedido de compra selecionado")
	elseif lCanAprov
		MsgInfo(cValToChar(nCount) + " Pedido(s) de compra liberado(s)")
	endif
	
Return


Static Function LoadData2(aHeader) 

	// CR_STATUS: 02 = PENDENTE, 03 = APROVADO, 04 = BLOQUEADO
	Local cQPend := ""
	Local aPed := Nil
	Local aNum := {}, aTot := {}
	Local nQtd := 0
	Local nPos := 0
	Local lPri := .f., lAdd := .f.
	Local nC := 0
	
	if !lViewAll .And. cAprov <> Nil
		cQPend := "SELECT C7_NUM, C7_ORCA, SUM((C7_TOTAL+C7_VALIPI+C7_DESPESA+C7_FRETE-C7_VLDESC) * " +;
				"(CASE WHEN C7_TXMOEDA = 0 THEN 1 ELSE C7_TXMOEDA END)) AS C7_TOTAL FROM " + RetSqlName("SC7") + " AS SC7 INNER JOIN " + RetSqlName("SAL") +;
				" AS SAL ON (SAL.D_E_L_E_T_ <> '*' AND AL_FILIAL = '" + xFilial("SAL") + "' AND AL_COD = C7_APROV AND AL_USER = '" + __CUSERID + "')" + ;
				" WHERE SC7.D_E_L_E_T_ <> '*' AND C7_CONAPRO <> 'L' AND C7_FILIAL = '" + xFilial("SC7") + "' GROUP BY C7_NUM, C7_ORCA ORDER BY C7_NUM"
	else
		cQPend := "SELECT C7_NUM, C7_ORCA, SUM((C7_TOTAL+C7_VALIPI+C7_DESPESA+C7_FRETE-C7_VLDESC) * " +;
				"(CASE WHEN C7_TXMOEDA = 0 THEN 1 ELSE C7_TXMOEDA END)) AS C7_TOTAL FROM " + RetSqlName("SC7") + " AS SC7 " +;
				" WHERE SC7.D_E_L_E_T_ <> '*' AND C7_CONAPRO <> 'L' AND C7_FILIAL = '" + xFilial("SC7") + "' GROUP BY C7_NUM, C7_ORCA ORDER BY C7_NUM"
	endif
		
	dbUseArea(.T.,"TOPCONN", TCGenQry(,,cQPend),"QRA", .F., .T.)	
	Dbselectarea("QRA")
	Dbgotop()
	
	While QRA->(!eof()) 
		cNumPed := AllTrim(QRA->C7_NUM)
		cNumOrca:= AllTrim(QRA->C7_ORCA)
		if ASCAN(aNum,{|x| x[1]+x[2] == cNumPed+cNumOrca}) == 0
			AAdd(aNum,{cNumPed,cNumOrca})
			AAdd(aTot,QRA->C7_TOTAL)  
		endif
		QRA->(dbskip())
	enddo
	
	DbSelectArea("QRA")
	dbCloseArea("QRA")  
	
	if Len(aNum) > 0   
		ProcRegua(Len(aNum))
		aPed := {}
	
		DbSelectArea("SC7")	
		SC7->(Dbsetorder(1))
		
		for nC := 1 to len(aNum)
			
			SC7->(Dbseek(xFilial("SC7") + aNum[nC][1],.T.))
				
			lPri := .t.       
			lAdd := .f.
			nPos := nPos + 1

			IncProc("Carregando Pedido " + 	aNum[nC][1])
			While SC7->(!eof()) .and. AllTrim(SC7->C7_NUM) == aNum[nC][1]      
			
			    IF ALLTRIM(SC7->C7_ORCA) == ALLTRIM(aNum[nC][2])
		                
			        IF !EMPTY(SC7->C7_ORCA)        
			                
				   		__cOrca := AllTrim(POSICIONE("SZ7",1,SC7->C7_ORCA,"Z7_DESC")) +	IF(SZ7->Z7_TIPO=="1","("+SUBSTR(DTOC(SC7->C7_DTREF),4,6)+")","")
					ELSE
						__cOrca := "SEM ORÇAMENTO"
					ENDIF
			
					AADD(aPed,{.f.,;
							SC7->C7_NUM,;                											// 02 = Pedido
							AllTrim(Posicione("SA2",1,xFilial("SA2")+SC7->C7_FORNECE,"A2_NOME")),;	// 03 = Fornecedor
							AllTrim(SC7->C7_TICKET),;                                    				// 04 = Ticket
							SC7->C7_ITEM,;																// 05 = Item do Ped.
							IIF(LEN(AllTrim(SC7->C7_DESCRI)) == 0,;
								AllTrim(Posicione("SB1",1,xFilial("SB1")+SC7->C7_PRODUTO,"B1_DESC")),;
								AllTrim(SC7->C7_DESCRI)),;												// 06 = Produto
							SC7->C7_TOTAL+SC7->C7_VALIPI+SC7->C7_DESPESA+SC7->C7_FRETE-SC7->C7_VLDESC,;	// 07 = Total do Item
							AllTrim(Posicione("CTT",1,xFilial("CTT")+SC7->C7_CC,"CTT_DESC01")),;		// 08 = C.Custo
							AllTrim(Posicione("CTD",1,xFilial("CTD")+SC7->C7_ITEMCTA,"CTD_DESC01")),;	// 09 = Output
							AllTrim(GetUser(SC7->C7_USER)),;											// 10 = Usuário
							SC7->C7_EMISSAO,;                                               			// 11 = Date de Emissao
							AllTrim(Posicione("SX5",1,xFilial("SX5")+"24"+SC7->C7_FORMPAG,"X5_DESCRI")),;	// 12 = Forma de Pagamento
							AllTrim(Posicione("SED",1,xFilial("SED")+SC7->C7_NATUREZ,"ED_DESCRIC")),;		// 13 = Natureza
							AllTrim(Posicione("SF4",1,xFilial("SF4")+SC7->C7_TES,"F4_TEXTO")),;				// 14 = TES
							SC7->C7_PRECO,;						   											// 15 = Valor Unitário
							SC7->C7_QUANT,;																	// 16 = Quantidade
							SC7->C7_VALFRE,;																// 17 = Frete
							IIF(SC7->C7_MOEDA == 1,"R$","US$"),;											// 18 = Moeda      
							SC7->C7_ORCA,;																	// 19 = Cod Orcamento
							__cOrca,;							// 20 = Orcamento
							SC7->C7_DTREF,;																	// 21 = Data Referencia
							SC7->C7_FORNECE,;																// 22 = Cod. Fornecedor
							AllTrim(Posicione("CTH",1,xFilial("CTH")+SC7->C7_CLVL,"CTH_DESC01"));																	// 23 = Classe de Valores - Projeto
							})
						
					if lPri
					
						aInner := {}
						for nD := 1 to len(aPed[nQtd+1])
							AADD(aInner,aPed[nQtd+1,nD])
						next
						
						AADD(aHeader,aInner)
						lAdd := .t.
					endif
					
					lPri := .f.
		

					nQtd := nQtd + 1
				Endif
				SC7->(dbskip())

			enddo
			        
			if len(aHeader) >= nPos .And. lAdd
				aHeader[nPos,_pValor] := aTot[nC]
			endif
			
		next
		
		DbSelectArea("SC7")
		dbCloseArea("SC7")
	endif
	
Return aPed