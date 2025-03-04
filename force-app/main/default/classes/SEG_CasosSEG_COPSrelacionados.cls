public with sharing class SEG_CasosSEG_COPSrelacionados implements Queueable{
    private String messageId;
    private String body;
    private String subject;
    
    public SEG_CasosSEG_COPSrelacionados(String messageId, String body, String subject){
        this.messageId= messageId;
        this.body= body;
        this.subject= subject;
    }

    public void execute(QueueableContext context) {
        Id recordTypeTask=CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Task', 'OS_Task');
        List<Task> tareasCOPS = new List<Task>();
        List<Case> casos = [SELECT Id, CC_CasoRelacionado__c, RecordType.DeveloperName FROM Case WHERE Createddate = TODAY AND Recordtype.Developername IN ('SEG_Cliente','SEG_Seguimiento','OS_Cliente','OS_Empleado') AND SEG_Id_Related_Mail__c = :messageId ORDER BY CREATEDDATE DESC];
        List<Case> casosUpdate = new List<Case>();
        List<Case> lstCasoSeg = new List<Case>();
        List<Case> lstCasoCops = new List<Case>();

        if(!casos.isEmpty()){
            for (Case caso : casos) {
                if(caso.RecordType.DeveloperName.startsWith ('SEG_')){
                    lstCasoSeg.add(caso);
                }else {
                    Task tarea = new Task();
                    tarea.RecordTypeId = recordTypeTask;
                    tarea.Type = 'Relación Segmentos';
                    tarea.Subject = subject;
                    tarea.ActivityDate = System.today();
                    tarea.Status = 'Completed';
                    tarea.Description = body;
                    tarea.WhatId = caso.Id; 
                    tareasCOPS.add(tarea);

                    lstCasoCops.add(caso);
                }
            }

            if(!lstCasoSeg.isEmpty() && !lstCasoCops.isEmpty()){
                for (Case casoSeg : lstCasoSeg) {
                    casoSeg.CC_CasoRelacionado__c = lstCasoCops[0].Id;
                    casosUpdate.add(casoSeg);
                }

                for (Case casoCops : lstCasoCops) {
                    casoCops.CC_CasoRelacionado__c = lstCasoSeg[0].Id;
                    casosUpdate.add(casoCops);
                }
                        
                if(!tareasCOPS.isEmpty()){
                    try {
                        List<Database.SaveResult> results = Database.insert(tareasCOPS, false); 
                    } catch (Exception e) {
                        
                        CBK_Log.error(e, 'Error en insertar tarea', tareasCOPS);
                    }
                }

                if(!casosUpdate.isEmpty()){
                    try {
                        List<Database.SaveResult> results = Database.update(casosUpdate, false); 
                    } catch (Exception e) {
                        
                        CBK_Log.error(e, 'Error en actualizar casos', casosUpdate);
                    }
                }
            }
        } 
    }
}