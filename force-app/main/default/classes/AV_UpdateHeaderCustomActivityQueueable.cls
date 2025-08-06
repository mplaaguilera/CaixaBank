/**********************************************************************************************************************
Name:      AV_UpdateHeaderCustomActivityQueueable
Copyright © 2019  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Update Cabecera tarea
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
VERSION        USER_STORY                             AUTHOR              DATE                Description
1.0            Temas    							  Jashanpreet         02/06/2021          Init version

***********************************************************************************************************************/
public with sharing class AV_UpdateHeaderCustomActivityQueueable implements Queueable{
    private AV_HeaderCustomActivity__c headerTask;
    public AV_UpdateHeaderCustomActivityQueueable(AV_HeaderCustomActivity__c headerTask) {
        this.headerTask = headerTask;
    }

    public void execute(System.QueueableContext qc) {
        Database.update(headerTask);
    }
}