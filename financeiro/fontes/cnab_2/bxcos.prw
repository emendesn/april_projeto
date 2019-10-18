#include 'protheus.ch'
#include 'parmtype.ch'
#include 'Topconn.ch'

user function BXCOS()


	Local aBaixa := {}

	cQuery1 := " SELECT * FROM "+RetSQlName("SA6")+" "
	cQuery1 += " WHERE A6_NUMCON='13000568'  AND D_E_L_E_T_<>'*' "


	If Select("QRY1") <> 0
		dbSelectArea("QRY1")
		dbCloseArea()
	EndIf

	TCQuery cQuery1 New Alias "QRY1"


	cQuery := " SELECT * FROM "+RetSQlName("SE1")+" "
	cQuery += " WHERE E1_NUM IN "
	cQuery += " ('Q00000007','Q00000056','Q00000058','Q00000059','Q00000097')  AND E1_BAIXA=''"

	If Select("QRY") <> 0
		dbSelectArea("QRY")
		dbCloseArea()
	EndIf

	TCQuery cQuery New Alias "QRY"


	While QRY->(!Eof())

		aBaixa := {{"E1_PREFIXO"  ,QRY->E1_PREFIXO                   ,Nil    },;
		{"E1_NUM"      ,QRY->E1_NUM             ,Nil    },;
		{"E1_TIPO"     ,QRY->E1_TIPO                ,Nil    },;
		{"AUTMOTBX"    ,"NOR"                  ,Nil    },;
		{"AUTBANCO"    ,QRY1->A6_COD                   ,Nil    },;
		{"AUTAGENCIA"  ,QRY1->A6_AGENCIA                ,Nil    },;
		{"AUTCONTA"    ,QRY1->A6_NUMCON          ,Nil    },;
		{"AUTDTBAIXA"  ,cTod("28/01/2019")              ,Nil    },;
		{"AUTDTCREDITO",cTod("28/01/2019")               ,Nil    },;
		{"AUTHIST"     ,"BAIXA PAID CASES"          ,Nil    },;
		{"AUTJUROS"    ,0                      ,Nil,.T.},;
		{"AUTVALREC"   ,QRY->E1_VALOR                    ,Nil    }}

		lMsErroAuto := .F.
		MSExecAuto({|x,y| Fina070(x,y)},aBaixa,3) 

		If lMsErroAuto
			MostraErro()
		EndIf

		QRY->(DbSkip())
	EndDo


return