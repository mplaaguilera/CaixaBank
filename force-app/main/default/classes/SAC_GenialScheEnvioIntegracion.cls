/*****************************************************************
* Name: SAC_GenialScheEnvioIntegracion
* Copyright © 2024  CaixaBank
* 
* @description : Copia del SAC_GenialScheSendAzure para su ampliación a programación
* con openServices. Según su configuración en el campo de Param1__c decidirá cuál
* es la integración a usar.
* 
* Historial
* -------
* VERSION        USER_STORY       AUTHOR                 DATE         Description
* 1.0            US967489         Alex Pérez             06/08/24     creación
*****************************************************************/
public with sharing class SAC_GenialScheEnvioIntegracion extends CBK_SCH_Queueable_Abstract{

    public override void execute(QueueableContext ctx) {

    try{
            List<CBK_SCH_PendingProcess__c> lstInfoPp = this.lstInfoProcess;
            Set<Id> setIdsReclamacion = new Set<Id>();
            map<Id, string> mapIntegracion = new map<Id, string>();
    
            for (CBK_SCH_PendingProcess__c pendingProcessReclamacion : lstInfoPp) {
                setIdsReclamacion.add(pendingProcessReclamacion.RecordId__c);
                mapIntegracion.put(pendingProcessReclamacion.RecordId__c, pendingProcessReclamacion.param1__c);
            }
    
            //obtención del description para pasárselo al envío hacia la IA
            list<case> reclamacionList = [SELECT Id, description FROM Case WHERE Id IN : setIdsReclamacion WITH SECURITY_ENFORCED];
            list<id> listaReclamaciones = new list<id>();
    
            for(case reclamacion : reclamacionList){
                if(mapIntegracion.get(reclamacion.Id) == 'Azure'){
                    SAC_GenialSendAzure.sendToIA(reclamacion.Id, reclamacion.Description);
                } else {
                    /*AsyncOptions options = new AsyncOptions();
                    options.DuplicateSignature = QueueableDuplicateSignature.Builder()
                                        .addId(reclamacion.Id)
                                        .addString('progEnv')
                                        .build();
                    System.enqueueJob(new SAC_GenialOpenServices_Queueable(null, null, reclamacion.Id), options);*/
                    //nuevo queueable lanzamiento de 1 en 1 o modificar el queueable para aceptar más de 1 schedulado
                    listaReclamaciones.add(reclamacion.Id);
                }
                
            }
            if(!listaReclamaciones.isEmpty()){
                AsyncOptions options = new AsyncOptions();
                options.DuplicateSignature = QueueableDuplicateSignature.Builder()
                    .addId(ctx.getJobId())
                    .addString('progEnv')
                    .build();
                System.enqueueJob(new SAC_GenialOpenServices_Queueable(listaReclamaciones), options);
            }
        } catch(exception e) {
            cbk_log.error(e);
        }
            
 
    }
}