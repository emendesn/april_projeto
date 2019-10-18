#include 'protheus.ch'
#include 'parmtype.ch'

// Cadastro de Moedas Bacen
// Elias  
user function CADSZA()

Local cVldAlt := ".T." 
Local cVldExc := ".T." 

dbSelectArea("SZA")
dbSetOrder(1)

AxCadastro( "SZA", "Cadastro Moedas Bacen", cVldExc, cVldAlt )

Return( Nil )