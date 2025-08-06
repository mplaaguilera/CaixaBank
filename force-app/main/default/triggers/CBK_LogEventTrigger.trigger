trigger CBK_LogEventTrigger on CBK_LogEvent__e (after insert) {  
    OrgWideEmailAddress[] owea = [select Id from OrgWideEmailAddress where DisplayName = 'Framework de Login'];
    
    String emailNotif;
    Boolean notif;    
    CBK_Framework_Login__mdt conf;
    List<CBK_Log__c> lstLog = New List<CBK_Log__c>();
    
    Map<String,CBK_Framework_Login__mdt> mapPrj = New Map<String,CBK_Framework_Login__mdt>();
    list<Messaging.SingleEmailMessage> lstmail = New list<Messaging.SingleEmailMessage>();
    
    //Configuración de traza por clases o prefijos
    for(CBK_Framework_Login__mdt prj :[select label,proyecto__c, Email_Notif__c, Notif__c from CBK_Framework_Login__mdt])
    {
        mapPrj.put(prj.label, prj);
    }
    
    Id recordTypeId =Schema.SObjectType.CBK_Log__c.getRecordTypeInfosByDeveloperName().get('Apex_Log').getRecordTypeId();
    
    for (CBK_LogEvent__e event : Trigger.New) {
        try{
            //Se genera el CBK_Log a partir del CBK_LogEvent__e
            CBK_Log__c EvtLog = CBK_Log.generateLogFromEvent(event);
            
            //Cálculo del proyecto
            Map<String, String> mapCalculateProject = CBK_Log.calculateProject(mapPrj, EvtLog.Apex_Class__c);
            EvtLog.Project__c = mapCalculateProject.get('project');
            emailNotif = mapCalculateProject.get('emailNotif');
            notif = Boolean.valueOf(mapCalculateProject.get('notif'));
            
            //Notificaciones por mail
            if (notif && (EvtLog.Log_Level__c=='ERROR') && ( owea.size() > 0 ) && (emailNotif!='')) {
                lstmail.add(CBK_Log.enviomail(EvtLog,owea.get(0).Id,emailNotif));
            }
            
            //Se añade el CBK_Log generado a la lista
            lstLog.add(EvtLog);
        }
        catch(Exception e){
            System.debug('The following exception has occurred: ' + e.getMessage());
        }
        
        // Set the Replay ID of the last successfully processed event message. 
        // If a limit is hit, the trigger refires and processing starts with the 
        // event after the last one processed (the set Replay ID).
        EventBus.TriggerContext.currentContext().setResumeCheckpoint(event.replayId);
    }
                
    //Inserción de registros CBK_Log
    Database.SaveResult[] srList = Database.insert(lstLog,false);
    CBK_Log.generaDetallesdeErrores(srList);
    
    //Envío de mails generados en el trigger
    for (Messaging.SingleEmailMessage msg : lstmail){
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { msg });
    }	
}