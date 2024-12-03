global class CC_CierreCasos_AutomatedProcess_Batch implements Database.Batchable<sObject>, Database.AllowsCallouts {

    global Database.QueryLocator start(Database.BatchableContext bc) {
        Datetime halfHourBack = Datetime.now().addMinutes(-30);
        String query = '';
        if (Test.isRunningTest()){
            query = 'SELECT Id, CreatedDate, CaseNumber, Status, CC_Tipo_ChatTranscript__c, OwnerId, Owner.Name, CC_Chat_Atendido__c FROM Case WHERE CC_Tipo_ChatTranscript__c IN (\'Hidden\', \'Agente\') and Origin = \'Chat\' and Status = \'Activo\' and Case.CC_MCC_Motivo__c = null and Owner.Name =\'Automated Process\' Order by Id desc, createdDate desc';
        } else {
        	query = 'SELECT Id, CreatedDate, CaseNumber, Status, CC_Tipo_ChatTranscript__c, OwnerId, Owner.Name, CC_Chat_Atendido__c FROM Case WHERE CC_Tipo_ChatTranscript__c IN (\'Hidden\', \'Agente\') and Origin = \'Chat\' and Status = \'Activo\' and Case.CC_MCC_Motivo__c = null and Owner.Name =\'Automated Process\' and CreatedDate >= LAST_N_DAYS:2 and CreatedDate <= : halfHourBack and RecordType.DeveloperName = \'CC_Empleado\' Order by Id desc, createdDate desc';
             } 
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext bc, List<Case> scope) {
        List<Case> oUpdCaso = new List<Case>();
        for(Case cs : scope){
        	try{
                if (cs.Owner.Name == 'Automated Process'){
                    Case oCaso = new Case();
                    oCaso.Id = cs.Id;
                    //oCaso.Canal_del_Empleado__c  = 'Hidden';
                    if(cs.CC_Chat_Atendido__c == true){
                        oCaso.Status = 'Cerrado';
                    }else{
                        oCaso.Status = 'Rechazado';
                    }
                    oUpdCaso.add(oCaso);
                }
            } catch (Exception e) {
                CBK_Log.error(e);
                //system.debug('Error : '+e);
            }
		}
        // Update de los casos
        if (oUpdCaso.size() > 0){
            Database.SaveResult[] oResult = Database.update(oUpdCaso, false);
        }
    }

    global void finish(Database.BatchableContext bc) {
        String scheduleName = 'Cierre Casos Hidden ';
             CC_Cierre_Casos_Hidden_Schedule newJob = new CC_Cierre_Casos_Hidden_Schedule(); 
             String dt = DateTime.now().addMinutes(30).format('s m H d M ? y'); 
             String cronExp = string.valueOf(dt); 
         if(!Test.isRunningTest()){
             System.schedule(scheduleName + dt, cronExp, newJob);        
         }
    }
}