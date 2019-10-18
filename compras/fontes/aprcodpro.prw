#include 'protheus.ch'
#include 'parmtype.ch'

Static __cB1CodStc

user function APRCODPRO()

	Local aArea := GetArea()

	cCdgProd := ""
	nCont 	 := 0

	cPulaLinha := chr(13)+chr(10)

	//_cSQL := "SELECT MAX(B1_COD) CODIGO FROM "+ RetSqlName("SB1") +" WHERE B1_TIPO = "+ M->B1_TIPO+ " AND D_E_L_E_T_ <> '*'"

	_cSQL := "SELECT MAX(B1_COD) CODIGO FROM !SB1! " + cPulaLinha
	_cSQL += "WHERE B1_TIPO = '!B1_TIPO!' AND D_E_L_E_T_ <> '*' " 

	_cSQL := StrTran(_cSQL,"!SB1!"     ,RetSqlName("SB1"))
	_cSQL := StrTran(_cSQL,"!B1_TIPO!" ,M->B1_TIPO) 
	_cSQL := StrTran(_cSQL,"!B1_GRUPO!" ,M->B1_GRUPO)

	_cSQL := ChangeQuery(_cSQL) //comando para adequar o SQL para o banco do usuáruio.                                         

	If Select("QRY") > 0
		QRY->(DbCloseArea())
	Endif 

	dbUseArea(.T.,"TOPCONN",TCGENQRY(,,_cSQL),"QRY",.F.,.T.)  

	cCdgProd := QRY->CODIGO

	If Empty(cCdgProd)
		cCdgProd := alltrim(M->B1_TIPO)+"0000000000001"	
	Else
		cCdgProd := alltrim(M->B1_TIPO)+alltrim(padl(val(substr(cCdgProd,3,13))+1,13,"0")) 

	Endif 
	
	
	
	QRY->(DbCloseArea())

	RestArea(aArea)

Return (cCdgProd)