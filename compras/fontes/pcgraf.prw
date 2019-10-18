#include "rwmake.ch"     
#include "topconn.ch"
/*
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ PCGRAF     ¦ Autor ¦  Thiago Rocco  ¦    Data  ¦ 13/07/09 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Impressao AvPrint Pedido de Compra.						  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo V2COM										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

User Function LJ720FIM()
	

	Private nPag     := 1
	Private nPagD    := 0
	Private NumPed   := Space(6)
	Private cPerg    := "PCGRAF    "
	Private cUsrPc   := "", cUsrRes  := ""
	Private cCargPc  := "", cCargRes := ""
	Private cRespons := ""
	Private li       := 0
	Private nOpcao   := nOpc
	ValidPerg()

	If FunName() == "MATA121"
		i := 0
		aBusX1 := {}
		AAdd(aBusX1, AllTrim(SC7->C7_NUM))
		AAdd(aBusX1, AllTrim(SC7->C7_NUM))
		AAdd(aBusX1, DtoC(SC7->C7_EMISSAO))
		AAdd(aBusX1, DtoC(SC7->C7_EMISSAO))
		DbSelectArea("SX1")
		DbSetOrder(1)
		For i:=1 to Len(aBusX1)

			If DbSeek("PCGRAF    "+StrZero(i,2))
				RecLock("SX1",.F.)
				SX1->X1_CNT01:= aBusX1[i]
				MsUnLock()
				DbSkip()
			Endif

		Next i
	Endif

	If !Pergunte(cPerg,.T.)
		Return
	Endif

	RptStatus({|| Relato()})

Return
/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funcao    ¦ Relato     ¦ Autor ¦  Thiago Rocco  ¦    Data  ¦ 25/05/06 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Impressao do relatorio.									  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo V2COM										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

Static Function Relato()

	Local nOrder
	Local cCondBus
	Local nSavRec
	Local aSavRec    := {}
	Local nLinObs    := 0
	Private lEnc     := .F.
	Private lPrimPag := .T.
	Private cTitulo
	Private oFont, cCode, oPrn
	Private cCGCPict, cCepPict
	Private _ImpCab:= .T.


	cCepPict := PesqPict("SA2","A2_CEP")
	cCGCPict := PesqPict("SA2","A2_CGC")

	oFont1 := TFont():New( "Arial",,16,,.T.,,,,,.F. )
	oFont2 := TFont():New( "Arial",,16,,.F.,,,,,.F. )
	oFont3 := TFont():New( "Arial",,10,,.T.,,,,,.F. )
	oFont4 := TFont():New( "Arial",,10,,.F.,,,,,.F. )
	oFont5 := TFont():New( "Arial",,08,,.T.,,,,,.F. )
	oFont6 := TFont():New( "Arial",,08,,.F.,,,,,.F. )
	oFont7 := TFont():New( "Arial",,14,,.T.,,,,,.F. )
	oFont8 := TFont():New( "Arial",,14,,.F.,,,,,.F. )
	oFont9 := TFont():New( "Arial",,12,,.T.,,,,,.F. )
	oFont10:= TFont():New( "Arial",,12,,.F.,,,,,.F. )
	oFont11:= TFont():New( "Arial",,07,,.T.,,,,,.F. )
	oFont12:= TFont():New( "Arial",,07,,.F.,,,,,.F. )
	oFont13:= TFont():New( "Arial",,08,,.T.,,,,,.F. )
	oFont14:= TFont():New( "Arial",,06,,.F.,,,,,.F. )
	oFont15:= TFont():New( "Arial",,06,,.T.,,,,,.F. )
	oFont16:= TFont():New( "Arial",,05,,.F.,,,,,.F. )
	oFont17:= TFont():New( "Arial",,05,,.T.,,,,,.F. )


	oFont1c := TFont():New( "Courier New",,16,,.T.,,,,,.F. )
	oFont2c := TFont():New( "Courier New",,16,,.F.,,,,,.F. )
	oFont3c := TFont():New( "Courier New",,10,,.T.,,,,,.F. )
	oFont4c := TFont():New( "Courier New",,10,,.F.,,,,,.F. )
	oFont5c := TFont():New( "Courier New",,09,,.T.,,,,,.F. )
	oFont6c := TFont():New( "Courier New",,09,,.T.,,,,,.F. )
	oFont7c := TFont():New( "Courier New",,14,,.T.,,,,,.F. )
	oFont8c := TFont():New( "Courier New",,14,,.F.,,,,,.F. )
	oFont9c := TFont():New( "Courier New",,12,,.T.,,,,,.F. )
	oFont10c:= TFont():New( "Courier New",,12,,.F.,,,,,.F. )

	nDescProd := 0
	nTotal    := 0
	nTotMerc  := 0
	cCondBus  := mv_par01
	nOrder	  := 1
	nValIRR   :=0
	nValISS   :=0
	nValINS   :=0
	nValPIS   :=0
	nValCOF   :=0
	nValCSL   :=0
	DbSelectArea("SC7")
	DbSetOrder(nOrder)
	SetRegua(RecCount())
	DbSeek( xFilial("SC7") + cCondBus , .T. )
	While !Eof() .And. SC7->C7_FILIAL = XFILIAL("SC7") .And. SC7->C7_NUM >= mv_par01 .And. SC7->C7_NUM <= mv_par02

		cObs01 := " "
		cObs02 := " "
		cObs03 := " "
		cObs04 := " "
		cObs05 := " "

		If C7_EMITIDO == "S" .And. mv_par05 == 1
			DbSelectArea("SC7")
			SC7->(DbSkip())
			Loop
		Endif

		If (C7_EMISSAO < mv_par03) .Or. (C7_EMISSAO > mv_par04)
			DbSelectArea("SC7")
			SC7->(DbSkip())
			Loop
		Endif

		MaFisEnd()
		R110FIniPC(SC7->C7_NUM,,,)

		NumPed := SC7->C7_NUM
		DbSelectArea("SC7")
		DbSetOrder(1)
		DbSeek( xFilial("SC7") + NumPed + "0001", .T. )
		nPagD := _ContaPag( SC7->C7_NUM )

		For ncw:= 1 to mv_par08

			DbSelectArea("SC7")
			DbSetOrder(1)
			DbSeek( xFilial("SC7") + NumPed + "0001", .T. )

			nTotal    := 0
			nTotMerc  := 0
			nDescProd := 0
			nSavRec   := SC7->(Recno())
			nLinObs   := 0
			li        := 500
			nTotDesc  := 0
			lPcOk     := .F.
			CondCont  := ""
			nTamDesc  := 65
			cDesObs   := ""
			_Ini:= .T.
			ImpCabec()
			li:= 590
			DbSelectArea("SC7")
			While !Eof() .And. SC7->C7_FILIAL = xFilial("SC7") .And. SC7->C7_NUM == NumPed

				IncRegua()

				DbSelectArea("SC7")
				If Ascan(aSavRec,Recno()) == 0
					AAdd(aSavRec,Recno())
				Endif

				//If !Empty(SC7->C7_CONTRAT)
				//	CondCont := AllTrim(C7_CONTRAT)
				//Endif

				If C7_EMITIDO == "S" .And. mv_par05 == 1
					DbSelectArea("SC7")
					SC7->(DbSkip())
					Loop
				Endif

				If C7_TIPO == 2
					DbSelectArea("SC7")
					SC7->(DbSkip())
					Loop
				Endif

				If (C7_EMISSAO < mv_par03) .Or. (C7_EMISSAO > mv_par04)
					DbSelectArea("SC7")
					SC7->(DbSkip())
					Loop
				Endif

				lPcOk := .T.

				li+=35
				If li > 2150

					_IMPCab:= .T.


					ImpRodape()
					ImpCabec()
					li := 590
				Endif

				oPrn:Say( li, 0020, StrZero(Val(SC7->C7_ITEM),2)  ,oFont6,100 )
				oPrn:Say( li, 0080, Upper(SC7->C7_PRODUTO),oFont6,100 )

				ImpProd()

				If SC7->C7_DESC1 != 0 .Or. SC7->C7_DESC2 != 0 .Or. SC7->C7_DESC3 != 0
					nDescProd+= CalcDesc(SC7->C7_TOTAL,SC7->C7_DESC1,SC7->C7_DESC2,SC7->C7_DESC3)
				Else
					nDescProd+=SC7->C7_VLDESC
				Endif

				DbSelectArea("SC7")
				SC7->(DbSkip())
			Enddo

			DbGoto(nSavRec)

			If li > 2150 //1200

				_IMPCab:= .T.
				ImpRodape()
				ImpCabec()
				li := 500
			Endif

			DbSelectArea("SC7")
			If lPcOk
				if li > 1280
					_IMPCab:= .T.
					ImpRodape()
					ImpCabec()
					li := 500
					FinalPed()
				Else
					FinalPed()
				Endif
			Endif

		Next ncw

		MaFisEnd()

		DbGoto(aSavRec[Len(aSavRec)])

		aSavRec := {}

		DbSelectArea("SC7")
		SC7->(DbSkip(+2))
		NumPed := SC7->C7_NUM
	Enddo

	DbSelectArea("SC7")
	Set Filter To
	DbSetOrder(1)

	DbSelectArea("SX3")
	DbSetOrder(1)

	If lEnc
		oPrn:Preview()
		MS_FLUSH()
	Endif

Return

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funcao    ¦ ImpCabec   ¦ Autor ¦  Thiago Rocco  ¦    Data  ¦ 13/07/09 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Impressao do cabecalho.									  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo V2COM										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

Static Function ImpCabec()

	Local cAlter  := ""
	Local cAprova := ""
	Local cCompr  := ""
	Local cAprov := ""
	Local nOrden, cCGC
	Local cAprovado := ""
	Local dPedido :=""
	Local cMoeda


	If !lPrimPag
		oPrn:EndPage()
		oPrn:StartPage()
		nPag += 1
	Else
		lPrimPag := .F.
		lEnc     := .T.
		oPrn     := TMSPrinter():New()
		oPrn:SetPaperSize(9)
		oPrn:Setup()
	Endif
	oPrn:Say( 0020, 0020, " ",oFont,100 )


	oPrn:Box( 0050, 0010, 0420,0410)
	oPrn:Box( 0050, 0410, 0175,1950)
	oPrn:Box( 0050, 1950, 0175,2850)
	oPrn:Box( 0050, 2850, 0175,3400)
	oPrn:Box( 0175, 2750, 0175,3400)

	oPrn:Box( 0175, 0410, 0420,1600)
	oPrn:Box( 0175, 1600, 0420,2750)
	oPrn:Box( 0175, 2750, 0420,3400)
	oPrn:Box( 0420, 0010, 0540,3400)


	If _IMPCab
		If nOpcao == 1
			If nPag  < nPagD
				oPrn:Box( 0540, 0010, 0600,0075)
				oPrn:Box( 0540, 0075, 0600,0330)  //+60
				oPrn:Box( 0540, 0330, 0600,1100)
				oPrn:Box( 0540, 1100, 0600,1170)
				oPrn:Box( 0540, 1170, 0600,1370)
				oPrn:Box( 0540, 1370, 0600,1570)
				oPrn:Box( 0540, 1570, 0600,1800)
				oPrn:Box( 0540, 1800, 0600,1950)
				oPrn:Box( 0540, 1950, 0600,2100)
				oPrn:Box( 0540, 2100, 0600,2350)
				oPrn:Box( 0540, 2310, 0600,2510)
				oPrn:Box( 0540, 2510, 0600,2750)
				oPrn:Box( 0540, 2750, 0600,3400)
				oPrn:Box( 0540, 2750, 0600,2950)
				oPrn:Box( 0540, 2950, 0600 ,3400)

				oPrn:Box( 0600, 0010, 2150,0075)
				oPrn:Box( 0600, 0075, 2150,0330)
				oPrn:Box( 0600, 0330, 2150,1100)
				oPrn:Box( 0600, 1100, 2150,1170)
				oPrn:Box( 0600, 1170, 2150,1370)
				oPrn:Box( 0600, 1370, 2150,1570)
				oPrn:Box( 0600, 1570, 2150,1800)
				oPrn:Box( 0600, 1800, 2150,1950)
				oPrn:Box( 0600, 1950, 2150,2100)
				oPrn:Box( 0600, 2100, 1280,2310)
				oPrn:Box( 0600, 2310, 1280,2510)
				oPrn:Box( 0600, 2510, 1280,2750)
				oPrn:Box( 0600, 2750, 1280,2950)
				oPrn:Box( 0600, 2950, 1280,3400)

			Else
				oPrn:Box( 0540, 0010, 0600,0075)
				oPrn:Box( 0540, 0075, 0600,0330)  //+60
				oPrn:Box( 0540, 0330, 0600,1100)
				oPrn:Box( 0540, 1100, 0600,1170)
				oPrn:Box( 0540, 1170, 0600,1370)
				oPrn:Box( 0540, 1370, 0600,1570)
				oPrn:Box( 0540, 1570, 0600,1800)
				oPrn:Box( 0540, 1800, 0600,1950)
				oPrn:Box( 0540, 1950, 0600,2100)
				oPrn:Box( 0540, 2100, 0600,2310)
				oPrn:Box( 0540, 2310, 0600,2510)
				oPrn:Box( 0540, 2510, 0600,2750)
				oPrn:Box( 0540, 2750, 0600,3400)
				oPrn:Box( 0540, 2750, 0600,2950)
				oPrn:Box( 0540, 2950, 0600 ,3400)

				oPrn:Box( 0600, 0010, 1280,0075)
				oPrn:Box( 0600, 0075, 1280,0330)
				oPrn:Box( 0600, 0330, 1280,1100)
				oPrn:Box( 0600, 1100, 1280,1170)
				oPrn:Box( 0600, 1170, 1280,1370)
				oPrn:Box( 0600, 1370, 1280,1570)
				oPrn:Box( 0600, 1570, 1280,1800)
				oPrn:Box( 0600, 1800, 1280,1950)
				oPrn:Box( 0600, 1950, 1280,2100)
				oPrn:Box( 0600, 2100, 1280,2310)
				oPrn:Box( 0600, 2310, 1280,2510)
				oPrn:Box( 0600, 2510, 1280,2750)
				oPrn:Box( 0600, 2750, 1280,2950)
				oPrn:Box( 0600, 2950, 1280,3400)
			Endif
		Else // Fornecedor
			If nPag  < nPagD
				oPrn:Box( 0540, 0010, 0600,0075)
				oPrn:Box( 0540, 0075, 0600,0330)  //+60
				oPrn:Box( 0540, 0330, 0600,1100)
				oPrn:Box( 0540, 1100, 0600,1170)
				oPrn:Box( 0540, 1170, 0600,1370)
				oPrn:Box( 0540, 1370, 0600,1570)
				oPrn:Box( 0540, 1570, 0600,1800)
				oPrn:Box( 0540, 1800, 0600,1950)
				oPrn:Box( 0540, 1950, 0600,2100)
				oPrn:Box( 0540, 2100, 0600,2350)
				oPrn:Box( 0540, 2310, 0600,2510)
				oPrn:Box( 0540, 2510, 0600,2750)
				oPrn:Box( 0540, 2750, 0600,3400)
				oPrn:Box( 0540, 2750, 0600,2950)
				oPrn:Box( 0540, 2950, 0600 ,3400)
				oPrn:Box( 0600, 0010, 2150,0075)
				oPrn:Box( 0600, 0075, 2150,0330)
				oPrn:Box( 0600, 0330, 2150,1100)
				oPrn:Box( 0600, 1100, 2150,1170)//ok
	
				oPrn:Box( 0600, 1170, 2150,1600)
				oPrn:Box( 0600, 1600, 2150,2250)/*
				oPrn:Box( 0600, 1570, 2150,1800)
				oPrn:Box( 0600, 1800, 2150,1950)
				oPrn:Box( 0600, 1950, 2150,2100)
				oPrn:Box( 0600, 2100, 1280,2310)
				oPrn:Box( 0600, 2310, 1280,2510)
				oPrn:Box( 0600, 2510, 1280,2750)
				oPrn:Box( 0600, 2750, 1280,2950)
				oPrn:Box( 0600, 2950, 1280,3400)*/

			Else
				oPrn:Box( 0540, 0010, 0600,0075)
				oPrn:Box( 0540, 0075, 0600,0330)  //+60
				oPrn:Box( 0540, 0330, 0600,1100)
				oPrn:Box( 0540, 1100, 0600,1170)
				oPrn:Box( 0540, 1170, 0600,1600)
				oPrn:Box( 0540, 1600, 0600,2250)
				oPrn:Box( 0540, 2250, 0600,2710)
				oPrn:Box( 0540, 2710, 0600,2950)
				oPrn:Box( 0540, 2950, 0600,3400)
			
				oPrn:Box( 0600, 0010, 1280,0075)
				oPrn:Box( 0600, 0075, 1280,0330)
				oPrn:Box( 0600, 0330, 1280,1100)
				oPrn:Box( 0600, 1100, 1280,1170)
				oPrn:Box( 0600, 1170, 1280,1600)
				oPrn:Box( 0600, 1600, 1280,2250)
				oPrn:Box( 0600, 2250, 1280,2710)
				oPrn:Box( 0600, 2710, 1280,2950)
				oPrn:Box( 0600, 2950, 1280,3400)
			Endif
		Endif
	Endif

	oPrn:SayBitmap( 0125,0030,"logov2.jpg",0360,0200 )

	DbSelectArea("SA2")
	DbSetOrder(1)
	DbSeek(xFilial()+SC7->C7_FORNECE+SC7->C7_LOJA)

	dbSelectArea("SCR")
	dbSetOrder(1)
	If dbSeek(xFilial("SCR")+"PC"+SC7->C7_NUM)
		While !Eof() .And. SCR->CR_FILIAL+Alltrim(SCR->CR_NUM)==xFilial("SCR")+Alltrim(SC7->C7_NUM) .And. SCR->CR_TIPO == "PC"
			cAprov    += AllTrim(UsrFullName(SCR->CR_USER))+"|"
			dPedido   := SCR->CR_DATALIB
			cAprovado := SCR->CR_USERLIB
			dbSelectArea("SCR")
			dbSkip()
		Enddo
		oPrn:Say( 0430, 1700, "Aprovador: ",oFont3,100 )
		oPrn:Say( 0430, 1900, Alltrim(UsrFullName()),oFont4,100 )
		oPrn:Say( 0430, 2400, "Data Aprov: ",oFont3,100 )
		oPrn:Say( 0430, 2600, DTOC(dPedido),oFont4,100 )
	EndIf

	oPrn:Say( 0430, 0030, "Ticket(s): ",oFont3,100 )
	oPrn:Say( 0430, 0200, Alltrim(SC7->C7_TICKET),oFont4,100 )
	oPrn:Say( 0430, 0400, "Responsavéis: ",oFont3,100 )
	oPrn:Say( 0430, 0650, cAprov,oFont4,100 )
	oPrn:Say( 0490, 0030, "Orçamento: "+AllTrim(POSICIONE("SZ7",1,SC7->C7_ORCA,"Z7_DESC")) + " (" + DTOC(SC7->C7_DTREF) + ")",oFont3,100 )
	//Aprovadores

	oPrn:Say( 0430, 2850, "Comprador: ",oFont3,100 )
	oPrn:Say( 0430, 3060, Alltrim(UsrFullName(SC7->C7_USER)),oFont4,100 )

	cTipoSB1  := GetAdvfVal("SB1","B1_TIPO",xFilial("SB1") + SC7->C7_PRODUTO ,1)
	If nOpcao == 1
		oPrn:Say( 0080, 0800, "APROVAÇÃO DE PAGAMENTO: "+Alltrim(SC7->C7_NUM),oFont1,100 )
	Else
		oPrn:Say( 0080, 0800, "PEDIDO DE COMPRAS: "+Alltrim(SC7->C7_NUM),oFont1,100 )
	EndIf
	//oPrn:Say( 0045, 2225, "Nº",oFont1,100 )
	oPrn:Box( 0050, 1950, 0175,2250)
	oPrn:Box( 0050, 2250, 0175,2500	)
	oPrn:Say( 0085, 1970, "Moeda: REAL",oFont3,100 )
	oPrn:Say( 0085, 2270, "Taxa: "+ALltrim(IIF(SC7->C7_MOEDA <> 1,IIF(SC7->C7_TXMOEDA > 0,TRANSFORM(SC7->C7_TXMOEDA,"@E 999.9999"),TRANSFORM(RecMoeda(SC7->C7_EMISSAO,SC7->C7_MOEDA),"@E 999.9999")),TRANSFORM(SC7->C7_TXMOEDA,"@E 999.9999"))) ,oFont3,100 )
	oPrn:Say( 0085, 2500, "Emissão: "+DTOC(SC7->C7_EMISSAO),oFont3,100 )

	If mv_par09 = 1
		cMoeda = "R$"
	Endif
	If mv_par09 = 2
		cMoeda = "US$"
	Endif
	If mv_par09 = 4
		cMoeda = "Eur"
	Endif
	If mv_par09 = 5
		cMoeda = "Iene"
	Endif

	oPrn:Say( 0080, 2950, "FOLHA:" ,oFont5,100 )
	oPrn:Say( 0080, 3070, AllTrim(StrZero(nPag,2)) ,oFont5,100 )

	oPrn:Say( 0185, 0430, "EMPRESA",oFont3,100 )
	oPrn:Say( 0185, 1630, "FORNECEDOR",oFont3,100 )
	oPrn:Say( 0185, 2780, "INFORMAÇOES FINANCEIRAS:" ,oFont3,100 )
	//oPrn:Say( 0185, 3060, DtoC(SC7->C7_EMISSAO) ,oFont4,100 )

	oPrn:Say( 0230, 0430, SM0->M0_NOMECOM ,oFont6,100 )
	oPrn:Say( 0230, 1630, AllTrim(Substr(SA2->A2_NOME,1,28))+" - ("+SA2->A2_COD+")" ,oFont6,100 )

	DbSelectArea("CTT")
	DbSetOrder(1)

	oPrn:Say( 0265, 0430, Upper(SM0->M0_ENDENT+"-"+SM0->M0_BAIRENT) ,oFont6,100 )
	oPrn:Say( 0265, 1630, Upper(Substr(SA2->A2_END,1,30)+ Substr(SA2->A2_BAIRRO,1,10)) ,oFont6,100 )
	oPrn:Say( 0300, 0430, Upper("CEP: "+Trans(SM0->M0_CEPENT,cCepPict)),oFont6,100 )
	oPrn:Say( 0300, 1200, Upper(Trim(SM0->M0_CIDENT)+" - "+SM0->M0_ESTENT) ,oFont6,100 )
	oPrn:Say( 0300, 1630, Upper(Trim(SA2->A2_MUN)+"   "+SA2->A2_EST+" "+"CEP: "+SA2->A2_CEP) ,oFont6,100 )
	oPrn:Say( 0300, 2200, "FONE: " + "("+Substr(SA2->A2_DDD,1,3)+") "+Substr(SA2->A2_TEL,1,15) ,oFont6,100 )
	oPrn:Say( 0265, 2780, "C.C: " + AllTrim(SA2->A2_BANCO) + " . " + AllTrim(SA2->A2_AGENCIA) + " . " + AllTrim(SA2->A2_NUMCON) + "-" + SA2->A2_XDVCONT,oFont3,100 )
	oPrn:Say( 0320, 2780, "Forma Pagto: "+Substr(Alltrim(ALLTRIM(POSICIONE('SX5',1,xFilial('SX5')+'24' + SC7->C7_FORMPAG + Space((6-Len(SC7->C7_FORMPAG))),'X5_DESCRI'))),1,15),oFont3,100 ) //Analisar

	oPrn:Say( 0335, 0430, "TEL: " + SM0->M0_TEL ,oFont6,100 )
	oPrn:Say( 0335, 1200, "FAX: " + SM0->M0_FAX ,oFont6,100 )
	oPrn:Say( 0335, 1630, "VENDEDOR: " + Upper(Substr(SA2->A2_CONTATO,1,10)),oFont6,100 )
	oPrn:Say( 0335, 2200, "FAX: " + "("+Substr(SA2->A2_DDD,1,3)+") "+SA2->A2_FAX ,oFont6,100 )


	DbSelectArea("SC1")
	DbSetOrder(1)
	If DbSeek(xFilial("SC1")+SC7->C7_NUMSC+SC7->C7_ITEMSC)
		cDescri := AllTrim(C1_DESCRI)
	Endif

	DbSelectArea("SX3")
	DbSetOrder(2)
	DbSeek("A2_CGC")
	cCGC := AllTrim(X3TITULO())
	nOrden = IndexOrd()

	oPrn:Say( 0370, 0430, (cCGC) + " "+ Transform(SM0->M0_CGC,cCgcPict) ,oFont6,100 )
	oPrn:Say( 0370, 1200, "IE:" + InscrEst() ,oFont6,100 )

	DbSelectArea("SA2")
	DbSetOrder(nOrden)
	oPrn:Say( 0370, 1630, "CNPJ: " + AllTrim(SA2->A2_CGC) ,oFont6,100 )
	oPrn:Say( 0370, 2200, "IE: " + SA2->A2_INSCR ,oFont6,100 )


	If _IMPCab
		If nOpcao == 1
			oPrn:Say( 0555, 0015, "Item"  ,oFont13,100 )//
			oPrn:Say( 0555, 0080, "Código" ,oFont13,100 )
			oPrn:Say( 0555, 0450, "Descrição do Material e/ou Serviço" ,oFont13,100 )
			oPrn:Say( 0555, 1105, "UN" ,oFont13,100 )
			oPrn:Say( 0555, 1200, "Qtde"  ,oFont13,100 )
			oPrn:Say( 0555, 1400, "Qtde Entr." ,oFont13,100 )
			oPrn:Say( 0555, 1600, "Qtde Saldo" ,oFont13,100 )
			oPrn:Say( 0555, 1810, "Vl.Unit "+cMoeda ,oFont13,100 )
			oPrn:Say( 0555, 1960, "Vlr. Total" ,oFont13,100 )
			oPrn:Say( 0555, 2113, "Valor Entrega" ,oFont13,100 )
			oPrn:Say( 0555, 2315, "Valor Saldo" ,oFont13,100 )
			oPrn:Say( 0555, 2515, "%IPI" ,oFont13,100 )
			oPrn:Say( 0555, 2755, "Dt.Entrega" ,oFont13,100 )
			oPrn:Say( 0555, 2955, "TES" ,oFont13,100 )
			/*oPrn:Say( 0555, 2505, "Output" ,oFont13,100 )
			oPrn:Say( 0555, 2860, "Descrição Centro de Custo" ,oFont13,100 )*/
		Else
			oPrn:Say( 0555, 0015, "Item"  ,oFont13,100 )//
			oPrn:Say( 0555, 0080, "Código" ,oFont13,100 )
			oPrn:Say( 0555, 0450, "Descrição do Material e/ou Serviço" ,oFont13,100 )
			oPrn:Say( 0555, 1105, "UN" ,oFont13,100 )
			oPrn:Say( 0555, 1200, "Quantidade"  ,oFont13,100 )
			oPrn:Say( 0555, 1610, "Valor Unitário "+cMoeda ,oFont13,100 )
			oPrn:Say( 0555, 2260, "Valor Total" ,oFont13,100 )
			oPrn:Say( 0555, 2715, "%IPI" ,oFont13,100 )
			oPrn:Say( 0555, 2955, "Dt.Entrega" ,oFont13,100 )
		Endif
	Endif
Return

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funcao    ¦ ImpProd
¦ Autor ¦  Thiago Rocco  ¦    Data  ¦ 13/07/09 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Impressao dos dados relacionados ao produto.				  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo V2COM										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

Static Function ImpProd()

	Local cDesc, nLinRef := 1, nBegin := 0, cDescri := "", nLinha:=0,;
	nTamDesc := 65 , aColuna := Array(8)

	If mv_par06 == 1
		DbSelectArea("SB1")
		DbSetOrder(1)
		DbSeek( xFilial()+SC7->C7_PRODUTO )
		cDescri := AllTrim(SB1->B1_DESC)
	ElseIf  mv_par06 == 2
		DbSelectArea("SC7")
		cDescri := AllTrim(SC7->C7_DESCRI)
	ElseIf  mv_par06 == 3
		DbSelectArea("SB5")
		DbSetOrder(1)
		If DbSeek( xFilial()+SC7->C7_PRODUTO )
			cDescri := AllTrim(SB5->B5_CEME)
		Endif
	ElseIf  mv_par06 == 4
		DbSelectArea("SC1")
		DbSetOrder(1)
		If DbSeek(xFilial("SC1")+SC7->C7_NUMSC+SC7->C7_ITEMSC)
			cDescri := AllTrim(C1_DESCRI)
		Endif
	Endif

	DbSelectArea("SC7")

	nLinha := MLCount(cDescri,nTamDesc)
	oPrn:Say( li, 0335, MemoLine(cDescri,nTamDesc,1) ,oFont12,100 )

	cOrcDesc := " "

	ImpCampos()

	For nBegin:= 2 to nLinha
		li+=35
		If li > 2100
			_IMPCab:= .T.
			ImpRodape()
			ImpCabec()
			li := 500
		Endif
		oPrn:Say( li, 00335, MemoLine(cDescri,nTamDesc,nBegin) ,oFont6,100 )
	Next nBegin


Return

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funcao    ¦ ImpCampos  ¦ Autor ¦  Thiago Rocco  ¦    Data  ¦ 13/07/09 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Impressao do detalhe.									  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo V2COM										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

Static Function ImpCampos()

	//Criada essa função para busca de saldo fisico e financeiro no pedido.
	aInfo := BuscaInf(SC7->C7_NUM,SC7->C7_ITEM,1)
	DbSelectArea("SC7")

	If mv_par07 == 2 .And. !Empty(SC7->C7_SEGUM)
		oPrn:Say( li, 1105, SC7->C7_SEGUM ,oFont6,100 )
	Else
		oPrn:Say( li, 1105, SC7->C7_UM ,oFont6,100 )
	Endif
	If nOpcao == 1
		oPrn:Say( li, 1180, Transform(SC7->C7_QUANT,PesqPict("SC7","C7_QUANT",14,mv_par09)) ,oFont6,100 )
		oPrn:Say( li, 1787, Transform(xMoeda(SC7->C7_PRECO,SC7->C7_MOEDA,1,SC7->C7_EMISSAO,,SC7->C7_TXMOEDA),PesqPict("SC7","C7_TOTAL",14,mv_par09)) ,oFont6,100 )

		nAliqISS := GetAdvfVal("SB1","B1_ALIQISS",xFilial("SB1") + SC7->C7_PRODUTO ,1)

		oPrn:Say( li, 1940, Transform(xMoeda(SC7->C7_TOTAL,mv_par09,1,SC7->C7_EMISSAO),PesqPict("SC7","C7_TOTAL",14,mv_par09)) ,oFont6,100 )
		oPrn:Say( li, 2515, Transform(SC7->C7_IPI,PesqPict("SC7","C7_IPI",6,mv_par09)) ,oFont6,100 )
		oPrn:Say( li, 2756, DtoC(SC7->C7_DATPRF) ,oFont6,100 )
		//Valor de Entrega - nok
		oPrn:Say( li, 2150, Transform(xMoeda(aInfo[1,2],mv_par09,1,SC7->C7_EMISSAO),PesqPict("SC7","C7_TOTAL",14,mv_par09)) ,oFont6,100 )
		//Valor do Saldo - ok
		oPrn:Say( li, 2330, Transform(xMoeda((SC7->C7_QUANT - SC7->C7_QUJE)*SC7->C7_PRECO,mv_par09,1,SC7->C7_EMISSAO),PesqPict("SC7","C7_TOTAL",14,mv_par09)) ,oFont6,100 )

		oPrn:Say( li, 2957, Alltrim(SC7->C7_TES)+"-"+Posicione("SF4",1,xFilial("SF4")+SC7->C7_TES,"F4_TEXTO") ,oFont6,100 )

		//Quantidade Entregue - nok 
		oPrn:Say( li, 1390, Transform(xMoeda(aInfo[1,1],mv_par09,1,SC7->C7_EMISSAO),PesqPict("SC7","C7_TOTAL",14,mv_par09)) ,oFont6,100 )

		//Quantidade Saldo - ok
		oPrn:Say( li, 1600, Transform(xMoeda(SC7->C7_QUANT - SC7->C7_QUJE,mv_par09,1,SC7->C7_EMISSAO),PesqPict("SC7","C7_QUJE",14,mv_par09)) ,oFont6,100 )

		nTotal   := nTotal+aInfo[1,2]-aInfo[1,3]-aInfo[1,4]-aInfo[1,5]-aInfo[1,6]-aInfo[1,7]-aInfo[1,8]
		nTotMerc += aInfo[1,2]
		nTotDesc += SC7->C7_VLDESC
		nValIRR  += aInfo[1,8]
		nValISS  += aInfo[1,6]
		nValINS  += aInfo[1,7]
		nValPIS  += aInfo[1,3]
		nValCOF  += aInfo[1,4]
		nValCSL  += aInfo[1,5]
	Else
		oPrn:Say( li, 1180, Transform(SC7->C7_QUANT,PesqPict("SC7","C7_QUANT",14,mv_par09)) ,oFont6,100 )
		oPrn:Say( li, 1787, Transform(xMoeda(SC7->C7_PRECO,SC7->C7_MOEDA,1,SC7->C7_EMISSAO,,SC7->C7_TXMOEDA),PesqPict("SC7","C7_TOTAL",14,mv_par09)) ,oFont6,100 )

		nAliqISS := GetAdvfVal("SB1","B1_ALIQISS",xFilial("SB1") + SC7->C7_PRODUTO ,1)

		oPrn:Say( li, 2300, Transform(xMoeda(SC7->C7_TOTAL,mv_par09,1,SC7->C7_EMISSAO),PesqPict("SC7","C7_TOTAL",14,mv_par09)) ,oFont6,100 )
		oPrn:Say( li, 2800, Transform(SC7->C7_IPI,PesqPict("SC7","C7_IPI",6,mv_par09)) ,oFont6,100 )
		oPrn:Say( li, 2980, DtoC(SC7->C7_DATPRF) ,oFont6,100 )
		
		nTotal   := nTotal+SC7->C7_TOTAL - SC7->C7_VLDESC
		nTotMerc := MaFisRet(,"NF_TOTAL")
		nTotDesc += SC7->C7_VLDESC
	EndIf

Return

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funcao    ¦ ImpRodape  ¦ Autor ¦  Thiago Rocco  ¦    Data  ¦ 13/07/09 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Impressao do rodape.										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo V2COM										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

Static Function ImpRodape()

	oPrn:Say( 2250, 0070, "CONTINUA ..." ,oFont3,100 )

Return

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funcao    ¦ FinalPed   ¦ Autor ¦  Thiago Rocco  ¦    Data  ¦ 13/07/09 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Finaliza o pedido de compra.								  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo V2COM										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/
Static Function FinalPed()

	Local nk 		 := 1,nG
	Local nQuebra	 := 0
	Local lNewAlc	 := .F.
	Local lLiber 	 := .F.
	Local lImpLeg	 := .T.
	Local cAlter	 := ""
	Local cAprova	 := ""
	Local aColuna    := Array(8), nTotLinhas
	Local nTotIpi	 := MaFisRet(,'NF_VALIPI')
	Local nTotIcms	 := MaFisRet(,'NF_VALICM')
	Local nTotDesp	 := MaFisRet(,'NF_DESPESA')
	Local nTotFrete	 := MaFisRet(,'NF_FRETE')
	Local nTotalNF	 := MaFisRet(,'NF_TOTAL')
	Local nTotSeguro := MaFisRet(,'NF_SEGURO')
	Local aValIVA    := MaFisRet(,"NF_VALIMP")
	Local li         := 465
	Local nTamLin    := 120   //tamanho da linha
	Local nTab       := 30
	Local cString    := CondCont //campo memo
	Local cLocEnt    := ""

	oPrn:Box( 1280, 0010, 1510,1300)
	oPrn:Box( 1280, 1300, 1510,2250)
	oPrn:Box( 1280, 2250, 1510,3400)
	oPrn:Box( 1390, 2250, 1510,3400)

	oPrn:Say( 1280, 2280, "TOTAL LÍQUIDO: " ,oFont3,100 )

	oPrn:Say( 1280, 2890, Transform(xMoeda(nTotal,mv_par09,1,SC7->C7_EMISSAO),PesqPict("SC7","C7_TOTAL",14,mv_par09)) ,oFont9c,100 )

	cAlias := Alias()
	DbSelectArea("SM0")
	DbSetOrder(1)
	nRegistro := Recno()

	DbSeek(Substr(cNumEmp,1,2)+SC7->C7_FILENT)

	oPrn:Say( 1280, 0020, "Local de Entrega: " ,oFont3,100 )

	//cLocEnt:=  Posicione("SX5",1,xFilial("SX5")+"ZH"+alltrim(MV_PAR10),Alltrim("SX5->X5_DESCRI")+Alltrim("SX5->X5_DESCSPA"))
	cLocEnt:= AllTrim(SM0->M0_ENDENT)+"  -  "+AllTrim(SM0->M0_BAIRENT)+"   "+"CEP: "+Trans(SM0->M0_CEPENT,cCepPict)
	cLocCid:= AllTrim(SM0->M0_CIDENT)+"  -  "+SM0->M0_ESTENT

	If Empty(mv_par10)
		oPrn:Say( 1285, 0340, Upper(cLocEnt) ,oFont6,100 ) //0325
		oPrn:Say( 1315, 0325, Upper(cLocCid),oFont6,100 )        //0325
	Else
		oPrn:Say( 1285, 0325, Upper(MV_PAR10) ,oFont6,100 )
	Endif

	DbGoto(nRegistro)
	DbSelectArea( cAlias )

	oPrn:Say( 1350,0020, "Local de Cobrança: ",oFont3,100 )
	oPrn:Say( 1350,0360, alltrim(SM0->M0_ENDCOB)+" CEP: "+ AllTrim(SM0->M0_CEPCOB)+" - "+ AllTrim(SM0->M0_CIDCOB) ,oFont6,100 )//0325

	DbSelectArea("SE4")
	DbSetOrder(1)

	DbSeek(xFilial()+SC7->C7_COND)
	DbSelectArea("SC7")

	oPrn:Say( 1395, 0020, "Condição de Pagto: ",oFont3,100 )
	oPrn:Say( 1400, 0370, AllTrim(Substr(SE4->E4_CODIGO,1,60))+" - "+AllTrim(Substr(SE4->E4_DESCRI,1,60)),oFont6,100 )       //0325

	oPrn:Say( 1440, 0020, "Tipo do Frete: ",oFont13,100 )
	If SC7->C7_TPFRETE == "C"
		oPrn:Say( 1440, 0325, "CIF",oFont6,100)
	ElseIf SC7->C7_TPFRETE == "F"
		oPrn:Say( 1440, 0325, "FOB",oFont6,100)
	Else
		oPrn:Say( 1440, 0325, "",oFont6,100)
	Endif

	oPrn:Say( 1473, 0020, "E-mail NF Eletrônica: ",oFont13,100 )//Alterado dia 10/12/09 por Thiago Matos
	oPrn:Say( 1473, 0345, "FINANCEIRO@V2COM.MOBI",oFont13,100)//Alterado dia 10/12/09 por Thiago Matos
	oPrn:Say( 1390, 2280, "TOTAL BRUTO: ",oFont3,100 )
	oPrn:Say( 1390, 2890, Transform(xMoeda(nTotMerc,mv_par09,1,SC7->C7_EMISSAO),PesqPict("SC7","C7_TOTAL",14,mv_par09)),oFont9c,100 )

	oPrn:Say( 1300, 1310, "IPI :" ,oFont3,100 )
	oPrn:Say( 1300, 2050, Transform(xMoeda(nTotIPI,mv_par09,1,SC7->C7_EMISSAO),tm(nTotIpi,14,MsDecimais(mv_par09))) ,oFont6,100 )
	//oPrn:Say( 1345, 1010, "ICMS :" ,oFont15,100 )
	//oPrn:Say( 1345, 1550, Transform(xMoeda(nTotIcms,mv_par09,1,SC7->C7_EMISSAO),tm(nTotIcms,14,MsDecimais(mv_par09))) ,oFont14,100 )
	oPrn:Say( 1345, 1310, "Frete/Despesas :" ,oFont3,100 )
	oPrn:Say( 1345, 2050, Transform(xMoeda(nTotFrete,mv_par09,1,SC7->C7_EMISSAO),tm(nTotFrete,14,MsDecimais(mv_par09))) ,oFont6,100 )
	oPrn:Say( 1390, 1310, "Seguro :" ,oFont3,100 )
	oPrn:Say( 1390, 2050, Transform(xMoeda(nTotSeguro,mv_par09,1,SC7->C7_EMISSAO),tm(nTotSeguro,14,MsDecimais(mv_par09))) ,oFont6,100 )
	oPrn:Say( 1435, 1310, "Desconto:" ,oFont3,100 )
	oPrn:Say( 1435, 2050, Transform(xMoeda(nTotDesc,mv_par09,1,SC7->C7_EMISSAO),tm(nTotSeguro,14,MsDecimais(mv_par09))) ,oFont6,100 )


	DbSelectArea("SM4")
	DbSetOrder(1)
	DbSeek(xFilial()+SC7->C7_MSG)
	cObs05 := AllTrim(SM4->M4_FORMULA)
	DbSelectArea("SC7")

	If nOpcao == 1
		oPrn:Box( 1510, 0010, 1600,3400)
		oPrn:Box( 1600, 0010, 1810,3400)
		//oPrn:Box( 1510, 2250, 1680,3400)
		// COLOCAR OS IMPOSTOS
		oPrn:Say( 1530, 0035, "PIS: "+Alltrim(Str(nValPIS)),oFont3,100 )
		oPrn:Say( 1530, 0435, "COFINS: "+Alltrim(Str(nValCOF)),oFont3,100 )
		oPrn:Say( 1530, 0835, "CSLL: "+Alltrim(Str(nValCSL)),oFont3,100 )
		oPrn:Say( 1530, 1235, "ISS: "+Alltrim(Str(nValISS)),oFont3,100 )
		oPrn:Say( 1530, 1600, "INSS: "+Alltrim(Str(nValINS)),oFont3,100 )
		oPrn:Say( 1530, 2000, "IR: "+Alltrim(Str(nValIRR)),oFont3,100 )
		//oPrn:Say( 1680, 0035, cObs05,oFont6,100 )
		oPrn:Say( 1610, 0035,  " Observações do Pedido: ",oFont3,100 )
		oPrn:Say( 1615, 0535, Alltrim(SUBSTR(AllTrim(SC7->C7_OBS),1,250)),oFont6,100 )
	Else
		oPrn:Box( 1510, 0010, 1810,3400)
		oPrn:Say( 1520, 0035,  " Observações do Pedido: ",oFont3,100 )
		oPrn:Say( 1520, 0535, Alltrim(SUBSTR(AllTrim(SC7->C7_OBS),1,250)),oFont6,100 )
	EndIf

	oPrn:Box( 1810, 0010, 2130,3400)
	oPrn:Say( 1820, 0008,  " NOTAS ",oFont13,100 ) //0035
	oPrn:Say( 1860, 0035,  "1) Só aceitamos a mercadoria se na sua Nota Fiscal constar o número do nosso Pedido de Compras. ",oFont5,100 )
	oPrn:Say( 1900, 0035,  "2) Só aceitamos NF e Boletos Bancários emitidos da mesma empresa (CNPJ) que constar neste Pedido de Compra.",oFont5,100 )

	If nOpcao == 1
		oPrn:Box( 2130, 0010, 2300,3400)
		oPrn:Say( 2145, 0020, "   Assinatura Comprador:",oFont3,100 )
		oPrn:Say( 2145, 1080, "|  Assinatura Tesouraria:",oFont3,100 )
		oPrn:Say( 2145, 2200, "|  Assinatura Controladoria: ",oFont3,100 )

		oPrn:Say( 2155, 1080, "|",oFont4,100 )
		oPrn:Say( 2155, 2200, "|",oFont4,100 )

		oPrn:Say( 2175, 1080, "|",oFont4,100 )
		oPrn:Say( 2175, 2200, "|",oFont4,100 )

		oPrn:Say( 2185, 1080, "|",oFont4,100 )
		oPrn:Say( 2185, 2200, "|",oFont4,100 )

		oPrn:Box( 2215, 0010, 2300,3400)
		oPrn:Say( 2215, 0020, "   Assinatura Diretoria:",oFont3,100 )
	EndIf
	DbSelectArea("SC7")
	SC7->(DbSkip())

Return
/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funcao    ¦ _ContaPag ¦ Autor ¦  Thiago Rocco   ¦   Data  ¦ 13/07/09  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Conta o numero total de paginas.				    		  ¦¦¦
¦+----------+-------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo V2COM										  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/
Static Function _ContaPag(xPedido)

	Local xRetorno := 1
	Local Linha    := 465
	Local nTamDesc := 65
	Local nQtLin   := 0

	DbSelectArea("SC7")
	DbSetOrder(1)
	DbSeek( xFilial("SC7") + xPedido + "0001", .T. )
	While !Eof() .And. SC7->C7_FILIAL = xFilial("SC7") .And. SC7->C7_NUM == xPedido

		If mv_par06 == 1
			DbSelectArea("SB1")
			DbSetOrder(1)
			DbSeek( xFilial()+SC7->C7_PRODUTO )
			cDescri := AllTrim(SB1->B1_DESC)
		ElseIf  mv_par06 == 2
			DbSelectArea("SC7")
			cDescri := AllTrim(SC7->C7_DESCRI)
		ElseIf  mv_par06 == 3
			DbSelectArea("SB5")
			DbSetOrder(1)
			If DbSeek( xFilial()+SC7->C7_PRODUTO )
				cDescri := AllTrim(SB5->B5_CEME)
			Endif
		ElseIf  mv_par06 == 4
			DbSelectArea("SC1")
			DbSetOrder(1)
			If DbSeek(xFilial("SC1")+SC7->C7_NUMSC+SC7->C7_ITEMSC)
				cDescri := AllTrim(C1_DESCRI)
			Endif
		Endif
		DbSelectArea("SC7")
		nQtLin := MLCount(cDescri,nTamDesc)

		Linha += 35
		If Linha > 1280
			Linha := 500
			xRetorno += 1
		Endif

		If nQtLin > 1
			For _x:= 2 to nQtLin
				Linha += 35
				If Linha > 1280
					Linha := 500
					xRetorno += 1
				Endif
			Next _x
		Endif

		//cObser := AllTrim(SC7->C7_OBS)
		//If !Empty(cObser)
		//	nQtLin := MLCount(cObser,nTamDesc)
		//	For _x:= 1 to nQtLin
		//		Linha += 35
		//		If Linha > 1280
		//			Linha := 500
		//			xRetorno += 1
		//		Endif
		//	Next _x
		//Endif

		DbSelectArea("SC7")
		SC7->(DbSkip())
	Enddo

Return(xRetorno)

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funcao    ¦ ValidPerg ¦ Autor ¦  Thiago Rocco   ¦   Data  ¦ 13/07/09  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ Cria o SX1.												  ¦¦¦
¦+----------+-------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Exclusivo V2COM	    								  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

Static Function ValidPerg()

	Private _aPerguntas := {}

	AAdd(_aPerguntas,{cPerg,"01","Pedido de          ?","","","mv_ch1","C",06,0,0,"G","","mv_par01","","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
	AAdd(_aPerguntas,{cPerg,"02","Pedido ate         ?","","","mv_ch2","C",06,0,0,"G","","mv_par02","","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
	AAdd(_aPerguntas,{cPerg,"03","Emissao de         ?","","","mv_ch3","D",08,0,0,"G","","mv_par03","","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
	AAdd(_aPerguntas,{cPerg,"04","Emissao ate        ?","","","mv_ch4","D",08,0,0,"G","","mv_par04","","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
	AAdd(_aPerguntas,{cPerg,"05","Somente os novos   ?","","","mv_ch5","N",01,0,0,"C","","mv_par05","Sim","","","","","Nao","","","","","","","","","","","","","","","","","","","","","","","","",""})
	AAdd(_aPerguntas,{cPerg,"06","Descricao Produto  ?","","","mv_ch6","N",01,0,0,"C","","mv_par06","Desc.Prod.SB1","","","","","Desc.Ped.SC7","","","","","Desc.Cient.SB5","","","","","Desc.Solic.SC1","","","","","","","","","","","","","","",""})
	AAdd(_aPerguntas,{cPerg,"07","Qual Unid.de Med.  ?","","","mv_ch7","N",01,0,0,"C","","mv_par07","Primaria","","","","","Secundaria","","","","","","","","","","","","","","","","","","","","","","","","",""})
	AAdd(_aPerguntas,{cPerg,"08","Numero de vias     ?","","","mv_ch8","N",02,0,0,"G","","mv_par08","","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
	AAdd(_aPerguntas,{cPerg,"09","Qual Moeda         ?","","","mv_ch9","N",01,0,0,"C","","mv_par09","Moeda 1","","","","","Moeda 2","","","","","Moeda 3","","","","","Moeda 4","","","","","Moeda 5","","","","","","","","","",""})
	AAdd(_aPerguntas,{cPerg,"10","End.Entrega        ?","","","mv_cha","C",50,0,0,"G","","mv_par10","","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})

	DbSelectArea("SX1")
	For _i:= 1 to Len(_aPerguntas)
		If !DbSeek( cPerg + StrZero(_i,2) )
			RecLock("SX1",.T.)
			For _j:= 1 to FCount()
				FieldPut(_j,_aPerguntas[_i,_j])
			Next _j
			MsUnLock()
		Endif
	Next _i

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³R110FIniPC³ Autor ³ Edson Maricate        ³ Data ³20/05/2000³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Inicializa as funcoes Fiscais com o Pedido de Compras      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ R110FIniPC(ExpC1,ExpC2)                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 := Numero do Pedido                                  ³±±
±±³          ³ ExpC2 := Item do Pedido                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MATR110,MATR120,Fluxo de Caixa                             ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function R110FIniPC(cPedido,cItem,cSequen,cFiltro)

	Local aArea		:= GetArea()
	Local aAreaSC7	:= SC7->(GetArea())
	Local cValid		:= ""
	Local nPosRef		:= 0
	Local nItem		:= 0
	Local cItemDe		:= IIf(cItem==Nil,'',cItem)
	Local cItemAte	:= IIf(cItem==Nil,Repl('Z',Len(SC7->C7_ITEM)),cItem)
	Local cRefCols	:= ''
	Local cSequen	:= ""
	Local cFiltro	:= ""

	dbSelectArea("SC7")
	dbSetOrder(1)
	If dbSeek(xFilial("SC7")+cPedido+cItemDe+Alltrim(cSequen))
		MaFisEnd()
		MaFisIni(SC7->C7_FORNECE,SC7->C7_LOJA,"F","N","R",{})
		While !Eof() .AND. SC7->C7_FILIAL+SC7->C7_NUM == xFilial("SC7")+cPedido .AND. ;
		SC7->C7_ITEM <= cItemAte .AND. (Empty(cSequen) .OR. cSequen == SC7->C7_SEQUEN)

			// Nao processar os Impostos se o item possuir residuo eliminado
			If &cFiltro
				dbSelectArea('SC7')
				dbSkip()
				Loop
			EndIf

			// Inicia a Carga do item nas funcoes MATXFIS
			nItem++
			MaFisIniLoad(nItem)
			dbSelectArea("SX3")
			dbSetOrder(1)
			dbSeek('SC7')
			While !EOF() .AND. (X3_ARQUIVO == 'SC7')
				cValid	:= StrTran(UPPER(SX3->X3_VALID)," ","")
				cValid	:= StrTran(cValid,"'",'"')
				If "MAFISREF" $ cValid
					nPosRef  := AT('MAFISREF("',cValid) + 10
					cRefCols := Substr(cValid,nPosRef,AT('","MT120",',cValid)-nPosRef )
					// Carrega os valores direto do SC7.
					MaFisLoad(cRefCols,&("SC7->"+ SX3->X3_CAMPO),nItem)
				EndIf
				dbSkip()
			End
			MaFisEndLoad(nItem,2)
			dbSelectArea('SC7')
			dbSkip()
		End
	EndIf

	RestArea(aAreaSC7)
	RestArea(aArea)

Return .T.

Static Function BuscaInf(cPedido,cItem,nOpc)

	Local aDados := {}

	cQuery := " SELECT TOP 1 * FROM "+RetSQlName("SD1")+"  where D_E_L_E_T_<>'*' AND D1_FILIAL = '"+xFilial("SD1")+"' "
	cQuery += " AND D1_PEDIDO = '"+cPedido+"' and D1_ITEM='"+cItem+"' ORDER BY R_E_C_N_O_ DESC"

	If Select("TMP") > 0            // Verificar se o Alias ja esta aberto.
		DbSelectArea("TMP")        // Se estiver, devera ser fechado.
		DbCloseArea("TMP")
	EndIf

	TCQUERY cQuery ALIAS TMP NEW

	If TMP->D1_QUANT == 0
		Aadd(aDados,{0,0,0,0,0,0,0,0})	
	Else
		Aadd(aDados,{TMP->D1_QUANT,TMP->D1_TOTAL,TMP->D1_VALPIS,TMP->D1_VALCOF,TMP->D1_VALCSL,TMP->D1_VALISS,TMP->D1_VALINS,TMP->D1_VALIRR})
	EndIf

Return aDados