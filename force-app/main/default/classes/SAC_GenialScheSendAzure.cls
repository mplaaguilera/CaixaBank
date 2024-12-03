/*****************************************************************
* Name: SAC_GenialScheSendAzure
* Copyright © 2024  CaixaBank
* 
* Proposito: Programar el envío de la información a azure para realizarla en un momento concreto
* Framework - Schedulable
* 
* Historial
* -------
* VERSION        USER_STORY       AUTHOR                 DATE         Description
* 1.0            US914420         Alex Pérez             07/05/24     Creación     
*****************************************************************/
public with sharing class SAC_GenialScheSendAzure extends CBK_SCH_Queueable_Abstract{

    public override void execute(QueueableContext ctx) {

    try{
            List<CBK_SCH_PendingProcess__c> lstInfoPp = this.lstInfoProcess;
            Set<Id> setIdsReclamacion = new Set<Id>();
    
            for (CBK_SCH_PendingProcess__c pendingProcessReclamacion : lstInfoPp) {
                setIdsReclamacion.add(pendingProcessReclamacion.RecordId__c);
            }
    
            //obtención del description para pasárselo al envío hacia la IA
            list<case> reclamacionList = [SELECT Id, description FROM Case WHERE Id IN : setIdsReclamacion WITH SECURITY_ENFORCED];
    
            for(case reclamacion : reclamacionList){
                SAC_GenialSendAzure.sendToIA(reclamacion.Id, reclamacion.Description);
            }
        } catch(exception e) {
            cbk_log.error(e);
        }
            
 
    }
}