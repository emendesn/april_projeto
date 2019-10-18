#include 'protheus.ch'
#include 'parmtype.ch'

user function CN120PED()

	Local aCab := PARAMIXB[1] 
	Local aItm := PARAMIXB[2] 
	Local aArea:= GetArea() 
	Local aPergs   := {}
	Local aRet	   := {}

	aAdd( aPergs ,{1,"Digite a Observação do Pedido",space(140),"@!",,,'.T.',240,.T.})
	If ParamBox(aPergs ,"Exemplo",aRet)
		For Nx:=1 to Len(aItm) 

			// C7_OBS
			If (nLin :=aScan(aItm[Nx],{|x|x[1]=="C7_OBS"}))>0  
				aItm[Nx][nLin][2] := aRet[1]
			Else 
				aAdd(aItm[Nx],{"C7_OBS",aRet[1],nil}) 
			EndIf 

			If (nLin :=aScan(aItm[Nx],{|x|x[1]=="C7_OBSM"}))>0  
				aItm[Nx][nLin][2] := aRet[1]
			Else 
				aAdd(aItm[Nx],{"C7_OBSM",aRet[1],nil}) 
			EndIf 
			
			If (nLin :=aScan(aItm[Nx],{|x|x[1]=="C7_XTPCOM"}))>0  
				aItm[Nx][nLin][2] := CN9->CN9_TPCTR
			Else 
				aAdd(aItm[Nx],{"C7_XTPCOM",CN9->CN9_TPCTR,nil}) 
			EndIf 
		Next 
	EndIf
	RestArea(aArea) 


Return({aCab,aItm}) 

User Function MT094CPC()
	Local cCampos := "C7_OBS" //  A separação dos campos devem ser feitos com uma barra vertical ( | ), igual é demonstrado no exemplo. 
Return (cCampos)

User Function CN120GSC()



Return .T.