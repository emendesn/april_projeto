#include "Protheus.ch"
#include "TopConn.ch"
#include "tbiconn.ch"
#include "tbicode.ch"
#INCLUDE "Ap5Mail.ch"

//Imp.CSV p/ Motor
User Function INFRACTE()

	Private cDir := "C:\MOTOR\"
	Private nTotArq := 0

	If !MsgYesNo("Essa rotina irá buscar os arquivos no diretório "+cDir+"*.CSV de acordo com as regras abaixo:"+CHR(13)+;
	" Arquivos iniciando com CTE (CTES de Entrada)"+CHR(13)+;
	" ** Se houver arquivos dentro do diretório que não inicie com as especificações acima serão desprezados **";
	,"Deseja Continuar ?")
		Return
	Endif

	Processa({||fAImport(),"Importando arquivo..."})

Return

Static Function fAImport()

	Local aFiles := {} // O array receberá os nomes dos arquivos e do diretório
	Local aSizes := {} // O array receberá os tamanhos dos arquivos e do diretorio
	Local nX 
	Local nTotReg   // Total de registros importados

	ADir(cDir+"*.csv", aFiles, aSizes)
	nCount  := Len( aFiles )
	lTemArq := .F.

	ProcRegua(nCount)

	If nCount > 0
		For nX := 1 to nCount

			If Upper(Substr(aFiles[nX],1,3)) == "CTE"
				lTemArq := .T.
				IncProc( 'Arquivo: ' + aFiles[nX], "CTE" )
				fProcARQ(aFiles[nX],"CTE")                      
				nTotArq ++                                                                    
			Endif                                                 

			If fRename(cDir+aFiles[nX],cDir+"\importados\"+aFiles[nX]) < 0
				MsgStop("Não foi possível transferir o arquivo para a pasta importados. Verifique os direitos de usuário na pasta ou se o arquivo está aberto.")
			Endif  

		Next nX

		If !lTemArq
			MsgStop("Verifique se as regras de nome de arquivo estão corretas [CTE].","NÃO EXECUTADO")   
			Return
		Endif

	Else
		MsgStop("Verifique se o diretório "+cDir+" existe OU se existe arquivos CSV no diretório.","NÃO EXECUTADO")
		Return
	Endif

	//MsgInfo("Concluído ! Foram processados ["+nTotArq+"] arquivos CSV. Total geral de ["+nTotReg+"] registros importados.")
	MsgInfo("Concluído ! Foram processados ["+alltrim(str(nTotArq))+"] arquivos CSV.")

Return

Static Function fProcARQ(cArq,cMod)

	Local cArqProc := cDir+cArq
	Local lPrimeiro := .T.
	Local aCabec := {}   
	Local aDados := {}
	Local aMov   := {}      
	Local i          
	Local nTotLida := 0

	FT_FUSE(cArqProc)
	ProcRegua(FT_FLASTREC())        
	FT_FGOTOP()                     

	While !FT_FEOF()

		IncProc("Lendo arquivo... ["+alltrim(str(nTotLida))+"]") 

		//le a linha                                 
		cLinha := FT_FREADLN()                                 
		nTotLida++

		//transforma as aspas duplas em aspas simples
		cLinha := StrTran(cLinha,'"',"'")
		cLinha := '{"'+cLinha+'"}'            

		//Tira os pontos
		cLinha := StrTran(cLinha,'.','')

		//Troca as vírgulas por ponto
		cLinha := StrTran(cLinha,',','.')   

		//adiciona o cLinha no array trocando o delimitador ; por , para ser reconhecido como elementos de um array 
		cLinha := StrTran(cLinha,';','","')

		If lPrimeiro // Se For primeira linha     
			aAdd(aCabec, &cLinha)
			lPrimeiro := .F.     
		Else
			aAdd(aDados, &cLinha)

			//For i:=1 to len(aDados[1])
			// aAdd(aMov,{aCabec[1,i],aDados[1,i]})
			//Next            
		Endif     

		//passa para a próxima linha 
		FT_FSKIP()

	EndDo   

	FT_FUSE()

	If Alltrim(cMod) == "CTE"
		fGravaCTE(aCabec,aDados)
	Endif

Return       

// #######################
// #                     #
// #         CTE         #
// #                     #
// #######################

Static Function fGravaCTE(aCabec,aDados)

	Local i   
	Local cDocAnt

	cDocAnt := ""
	DbSelectArea ("PIK")
	DbSetOrder(1)
	For i:=1 to len(aDados)

		// If aDados[i,2] <> cDocAnt 
		//  cDocAnt := aDados[i,2]
		If !DbSeek("  " + aDados[i,1] + aDados[i,2])
			RecLock("PIK",.T.)  //Cabeçalhos NFS 
			PIK->PIK_ACAO   := "1"    // 1 - Inclusão / 2 - Alteração / 3 - Exclusão/ 4 - Cancelamento / 5- Inutilizada / 6 - Denegada                                                                                      
			PIK->PIK_CODORI := "2"    // 2 - sistema legado
			PIK->PIK_CODDES := "1"
			PIK->PIK_PREFIXO:= "CTE"
			PIK->PIK_STATUS := "A"
			PIK->PIK_FILIAL := Strzero(Val(aDados[i,1]),4)
			PIK->PIK_DOC := aDados[i,2]
			PIK->PIK_SERIE := aDados[i,3]
			PIK->PIK_ESPECI := "CTE"
			If Len(Alltrim(aDados[i,4])) > 11  // cnpj
				cCgc := Strzero(Val(Alltrim(aDados[i,4])),14)
			Else         // cpf
				cCgc := Strzero(Val(Alltrim(aDados[i,4])),11)   
			Endif
			PIK->PIK_XCGC := cCgc   
			//   PIK->PIK_EST    := aDados[i,5]
			//   PIK->PIK_TIPOCL := aDados[i,6]
			PIK->PIK_MOEDA  := 1   
			PIK->PIK_XNATUR := aDados[i,5]
			PIK->PIK_COND   := aDados[i,6]    
			PIK->PIK_EMISSA := CTOD(aDados[i,7])
			PIK->PIK_DTDIGIT:= CTOD(aDados[i,8])
			PIK->PIK_VALMER := val(aDados[i,9])
			PIK->PIK_VALBRU := val(aDados[i,10])   
			PIK->PIK_TIPO := "N"
			PIK->PIK_DESCON := val(aDados[i,11])
			PIK->PIK_ISS    := val(aDados[i,12])
			PIK->PIK_BASEIN := val(aDados[i,13])
			PIK->PIK_BASPIS := val(aDados[i,14])
			PIK->PIK_BASCOF := val(aDados[i,15])
			PIK->PIK_BASCSL := val(aDados[i,16])
			PIK->PIK_INSS   := val(aDados[i,17])
			PIK->PIK_VALPIS := val(aDados[i,18])
			PIK->PIK_VALCOF := val(aDados[i,19])
			PIK->PIK_VALCSL := val(aDados[i,20])         
			PIK->PIK_VALIRF := val(aDados[i,21]) 
			PIK->PIK_BASEIC := val(aDados[i,22])
			PIK->PIK_VALICM := val(aDados[i,23])
			PIK->PIK_BASPIS := val(aDados[i,24])
			PIK->PIK_VALPIS := val(aDados[i,25])
			PIK->PIK_BASCOF := val(aDados[i,26])
			PIK->PIK_VALCOF := val(aDados[i,27])
			PIK->PIK_XCODEX := aDados[i,28]   
			PIK->PIK_DATEXP := DDATABASE
			MsUnlock()              

			DbSelectArea("SB1")
			SB1->(DbSetOrder(1))
			DbSeek(xFilial("SB1")+aDados[i,29]))                    

			RecLock("PIE",.T.)                    
			PIE->PIE_ACAO := "1"    //1 - Inclusão / 2 - Alteração / 3 - Exclusão/ 4 - Cancelamento / 5- Inutilizada / 6 - Denegada                                                                                      
			PIE->PIE_CODORI := "2"    // 2 - sistema legado
			PIE->PIE_CODDES := "1"      
			PIE->PIE_FILIAL := PIK->PIK_FILIAL
			PIE->PIE_COD  := aDados[i,29]
			PIE->PIE_ITEM   := "01"   
			PIE->PIE_UM     := SB1->B1_UM                         //UM - SB1
			PIE->PIE_QUANT  := 1
			PIE->PIE_PRCVEN := PIK->PIK_VALBRU
			PIE->PIE_TOTAL  := PIK->PIK_VALBRU
			PIE->PIE_TES    := "980"
			PIE->PIE_CF     := SF4->SF4_F4_CF
			PIE->PIE_LOCAL  := "01"
			PIE->PIE_DOC    := PIK->PIK_DOC
			PIE->PIE_SERIE  := PIK->PIK_SERIE
			PIE->PIE_TP     := SB1->B1_TIPO                         //tipo do produto - SB1
			PIE->PIE_EMISSA := PIK->PIK_EMISSA
			PIE->PIE_BASEIC := PIK->PIK_BASEIC
			PIE->PIE_PICM   := val(aDados[i,30])
			PIE->PIE_VALICM := PIK->PIK_VALICM //val(aDados[i,32])
			PIE->PIE_BASECO := PIK->PIK_BASCOF
			PIE->PIE_VALCOF := PIK->PIK_VALCOF //val(aDados[i,33])
			PIE->PIE_BASEPI := PIK->PIK_BASPIS
			PIE->PIE_VALPIS := PIK->PIK_VALPIS //val(aDados[i,34])
			PIE->PIE_XCODEX := PIK->PIK_XCODEX
			PIE->PIE_DATEXP := DDATABASE
			MsUnlock()   

		Endif

	Next

Return

