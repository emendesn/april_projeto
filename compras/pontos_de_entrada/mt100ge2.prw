#include 'protheus.ch'
#include 'parmtype.ch'

User Function MT100GE2() 
 
/*
  
      dbSelectArea("SX6")
      dbsetorder(1)
            
        IF DBSEEK(SX6->("01MV_CODFOR")) 
           IF SX6->X6_CONTEUDE <> SF1->F1_FORNECE
              RECLOCK("SX6")
              REPLACE SX6->X6_CONTEUD WITH SF1->F1_FORNECE
              REPLACE SX6->X6_CONTENG WITH SX6->X6_CONTEUD
              REPLACE SX6->X6_CONTSPA WITH SX6->X6_CONTENG   
              MSUNLOCK()
           ENDIF
           
            RECLOCK("SE2")
            REPLACE SE2->E2_CODFOR WITH  SX6->X6_CONTEUD
            MSUNLOCK()    
        ELSE
            RECLOCK("SE2")
            REPLACE SE2->E2_CODFOR WITH "F50IRF"
            MSUNLOCK()
              
        ENDIF   
      */      
   
RETURN NIL   