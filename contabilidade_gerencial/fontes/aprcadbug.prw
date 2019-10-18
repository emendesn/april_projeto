#include 'protheus.ch'
#include 'parmtype.ch'

User Function APRCADBUG()

	Local cVldAlt := ".T." // Validacao para permitir a alteracao. Pode-se utilizar ExecBlock.
	Local cVldExc := ".T." // Validacao para permitir a exclusao. Pode-se utilizar ExecBlock.

	Private cString := "Z98"

	dbSelectArea("Z98")
	dbSetOrder(1)

	AxCadastro(cString,"Cadastro do Budget",cVldExc,cVldAlt)

return