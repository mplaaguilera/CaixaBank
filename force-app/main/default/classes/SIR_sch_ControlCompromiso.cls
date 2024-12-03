/*****************************************************************
 Name:  SIR_sch_ControlCompromiso
 Copyright © 2021  CaixaBank
============================================================
Proposito:   Clase Schedulable para lanzar el batch de control de compromiso                                                                                                                 
============================================================
    Historial
    -------                                                            
    VERSION        USER_STORY       AUTHOR         DATE               Description
    1.0                             Atmira         21/12/2021     	 Created    

*****************************************************************/

public with sharing class SIR_sch_ControlCompromiso implements Schedulable{
    public void execute(SchedulableContext sc)

    {
        SIR_Batch_ControlCompromiso myBatchObject = new SIR_Batch_ControlCompromiso();
        //Se pone el límite a 50 porque es el límite de future methods por transacción y dado que cada vez que se inserta una acción hay que enviarla a SIREC, definimos esté como límite
        Database.executeBatch(myBatchObject, 50);

    }
}