global class CC_Cierre_Casos_Hidden_Batch implements Database.Batchable<sObject>, Database.AllowsCallouts {

    global Database.QueryLocator start(Database.BatchableContext bc) {
        Datetime halfHourBack = Datetime.now().addMinutes(-30);
        String query = '';
        if (Test.isRunningTest()){
            query = 'SELECT Id, CreatedDate, Case.CaseNumber, Status, Case.Status, Case.CC_Tipo_ChatTranscript__c, CaseId, Case.OwnerId, Case.Owner.Name FROM LiveChatTranscript WHERE Status IN (\'Completed\',\'Missed\') and CC_Tipo__c IN (\'Hidden\',\'Agente\') and Case.CC_Tipo_ChatTranscript__c IN (\'Hidden\',\'Agente\') and Case.Origin = \'Chat\' and Case.Status = \'Activo\' and Case.CC_MCC_Motivo__c = null Order by Id desc, createdDate desc';
        } else {
        	query = 'SELECT Id, CreatedDate, Case.CaseNumber, Status, Case.Status, Case.CC_Tipo_ChatTranscript__c, CaseId, Case.OwnerId, Case.Owner.Name FROM LiveChatTranscript WHERE Status IN (\'Completed\',\'Missed\') and CC_Tipo__c IN (\'Hidden\',\'Agente\') and Case.CC_Tipo_ChatTranscript__c IN (\'Hidden\',\'Agente\') and Case.Origin = \'Chat\' and Case.Status = \'Activo\' and Case.CC_MCC_Motivo__c = null  and CreatedDate >= LAST_N_DAYS:2 and CreatedDate <= : halfHourBack and RecordType.DeveloperName = \'CC_Empleados\' Order by Id desc, createdDate desc';
        }
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext bc, List<LiveChatTranscript> scope) {
        List<Case> oUpdCaso = new List<Case>();
        Map<Id,Id> mapIdCaso = new Map<Id,Id>();
        
        //Buscar para las trancriptions la última para cada caso y si es de Agente y no es Missed que cierre y haga lo que tenga que hacer
        List<ID> caseID = new List<ID>();
        for(LiveChatTranscript transcript : scope){
            caseID.add(transcript.CaseId);
        }
        Set<ID> newSet = new Set<ID>();
        List<ID> resCases = new List<ID>();
        newSet.addAll(caseID);
        resCases.addAll(newSet);
        //Version post sep2020
        List<Case> oCaso2 = [SELECT Id, CaseNumber, Status, CC_Tipo_ChatTranscript__c, OwnerId, Owner.Name, CC_Chat_Atendido__c,
                            (SELECT Id, CreatedDate,Status,CC_Tipo__c 
                                FROM LiveChatTranscripts WHERE CC_Tipo__c <> 'Chatbot' ORDER BY CreatedDate DESC LIMIT 1)
         					FROM Case WHERE Id IN :resCases];

        for(Case cs : oCaso2){
        	try{
                if (cs.CC_Tipo_ChatTranscript__c == 'Agente' || cs.CC_Tipo_ChatTranscript__c == 'Hidden'){
                    for (LiveChatTranscript oTrans : cs.LiveChatTranscripts){
                        if(oTrans.CC_Tipo__c == 'Hidden' || (oTrans.CC_Tipo__c == 'Agente' && oTrans.Status == 'Missed')){
                            String s1 = String.valueof(cs.OwnerId);
                            if (!s1.startsWithIgnoreCase('00G')){ //Cuando el owner del Caso sea un grupo/cola se ignora y no se hace nada
                                Case oCaso = new Case();
                                oCaso.Id = cs.Id;
                                if(cs.CC_Chat_Atendido__c == true ){
                                    oCaso.Status = 'Cerrado'; 
                                } else if (cs.Owner.Name == 'Automated Process'){
                                    oCaso.Status = 'Rechazado';
                                } else if(oTrans.Status == 'Completed' ){
                                    oCaso.Status = 'Cerrado'; 
                                } else {
                                    oCaso.Status = 'Rechazado';
                                }
                                oUpdCaso.add(oCaso);
                            }
                        }
                    }
                }
            } catch (Exception e) {
                CBK_Log.error(e);
				//system.debug('Error : '+e);
        	}
        }
        if (oUpdCaso.size() > 0){
            Database.SaveResult[] oResult = Database.update(oUpdCaso, false);
        }
        
        //Version previa Sep2020
        /*List<LiveChatTranscript> oTranscript = [SELECT Id, CreatedDate, Case.CaseNumber, Status, Case.Status, Case.CC_Tipo_ChatTranscript__c, CaseId, Case.OwnerId, 
                                                Case.Owner.Name FROM LiveChatTranscript WHERE Case.CC_Tipo_ChatTranscript__c IN ('Agente') 
                                                AND CC_Tipo__c = 'Hidden' AND CaseId IN :resCases Order by createdDate desc];*/
		
        /*for(LiveChatTranscript cs : scope){
        	try{
                //Si el owner del caso es el Automated Process se rechazan
                //Transcript Missed con agente real se rechaza el caso
                //Transcript Completed con agente real se cierra el caso
                String s1 = String.valueof(cs.Case.OwnerId);
                //System.assert(s1.startsWith('00G')); sensitive
                //System.assert(s1.startsWithIgnoreCase('00G')); insensitive
                if (!s1.startsWithIgnoreCase('00G')){ //Cuando el owner del Caso sea un grupo/cola se ignora y no se hace nada
                    Case oCaso = new Case();
                    oCaso.Id = cs.CaseId;
                    if (cs.Case.Owner.Name == 'Automated Process'){
                        oCaso.Status = 'Rechazado';
                    } else if(cs.Status == 'Completed'){
                            oCaso.Status = 'Cerrado'; 
                    } else {
                        oCaso.Status = 'Rechazado';
                    }
                    //La primera de cada caso entrara, las siguientes ya no
                    if(mapIdCaso.get(cs.CaseId) != oCaso.Id){ //Si ya esta incluido para updatear, no lo volvemos a añadir
						oUpdCaso.add(oCaso);
						mapIdCaso.put(cs.CaseId,cs.CaseId);
                    }
                }
            } catch (Exception e) {
                system.debug('Error : '+e);
            }
		}
        // Update de los casos, quitamos duplicados
        Set<Case> myset = new Set<Case>();
        List<Case> result = new List<Case>();
        myset.addAll(oUpdCaso);
        result.addAll(myset);
        if (oUpdCaso.size() > 0){
            Database.SaveResult[] oResult = Database.update(result, false);
        }*/
    }

    global void finish(Database.BatchableContext bc) {
        /*String scheduleName = 'Cierre Casos Hidden ';
        if(!Test.isRunningTest()){
            CC_Cierre_Casos_Hidden_Schedule newJob = new CC_Cierre_Casos_Hidden_Schedule();
            String dt = DateTime.now().addMinutes(30).format('s m H d M ? y');
            String CRON_EXP = string.valueOf(dt);
            System.schedule(scheduleName + dt, CRON_EXP, newJob);        
        }*/
        
        CC_CierreCasos_AutomatedProcess_Batch batch = new CC_CierreCasos_AutomatedProcess_Batch();      
        Database.executeBatch(batch,1);//(Test.isRunningTest()?1:50)
    }
}