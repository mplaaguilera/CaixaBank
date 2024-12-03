public with sharing class CBK_LWC_ChangeOwner_Controller {
    
    @AuraEnabled(cacheable=true)
    public static List<SObject> getRegistros(String tipoObjeto, String cadenaBusqueda, String project, String recordId) {
        List<string> lstRecordsId = recordId.split(',');
        String sObjName = Id.valueOf(lstRecordsId[0]).getSObjectType().getDescribe().getName();
        Map<String, CBK_ChangeOwnerConfiguration__mdt> config = CBK_ChangeOwnerConfiguration__mdt.getAll();
        map<String,List<String>> mQueueByApp =  new map<String,List<String>>();
        map<String,List<String>> mPsByApp =  new map<String,List<String>>();
        List<String> lstQueue;
        List<String> lstPs;

        if (config.keyset().size() > 0){
            for(string key : config.keyset()){
                if(config.containsKey(key)){
                    CBK_ChangeOwnerConfiguration__mdt changeOwnerConf = config.get(key);
                    Boolean isActive = changeOwnerConf.Active__c;
                    if (test.isRunningTest()){
                        isActive = true;
                    }
                    if (isActive){
                        if (changeOwnerConf.Type__c == 'User'){
                            if(mPsByApp.containsKey(changeOwnerConf.Project__c)){
                                lstPs = new List<String>();
                                lstPs = changeOwnerConf.PernisionSetName__c.split(';');
                                mPsByApp.get(changeOwnerConf.Project__c).addAll(lstPs);
                            }else{
                                lstPs = new List<String>();
                                lstPs = changeOwnerConf.PernisionSetName__c.split(';');
                                mPsByApp.put(changeOwnerConf.Project__c, lstPs);
                            }
                        }else{
                            if(mQueueByApp.containsKey(changeOwnerConf.Project__c)){
                                lstQueue = new List<String>();
                                lstQueue = changeOwnerConf.QueueName__c.split(';');
                                mQueueByApp.get(changeOwnerConf.Project__c).addAll(lstQueue);
                            }else{
                                lstQueue = new List<String>();
                                lstQueue = changeOwnerConf.QueueName__c.split(';');
                                mQueueByApp.put(changeOwnerConf.Project__c, lstQueue);
                            }
                        }
                    }
                }
            }
            CBK_log.debug('Queues: ' + JSON.serialize(mQueueByApp),  LoggingLevel.INFO);
            CBK_log.debug('Permision Sets: ' + JSON.serialize(mPsByApp),  LoggingLevel.INFO); 
        }
        if (String.isBlank(project)){
            project = getAppProjectByUser();
        }
        if (tipoObjeto == 'Usuario') {          
            lstPs = mPsByApp.get(project);
            lstPs = lstPs != null ? lstPs : new List<String>();
            CBK_log.debug('Lista PS por App: ' + project + ' - ' + JSON.serialize(mPsByApp),  LoggingLevel.INFO);
            return Database.query('SELECT Id, PermissionSet.Name, Assignee.Name FROM PermissionSetAssignment WHERE PermissionSet.Name IN :lstPs AND Assignee.Name LIKE \'%' + String.escapeSingleQuotes(cadenaBusqueda) + '%\' ORDER BY Assignee.Name LIMIT 20');
        } else {
            lstQueue = mQueueByApp.get(project);
            CBK_log.debug('Lista Queues por App: ' + project + ' - ' + JSON.serialize(lstQueue),  LoggingLevel.INFO);
            lstQueue = lstQueue != null ? lstQueue : new List<String>();
            return Database.query('SELECT Id, QueueId, SobjectType, Queue.DeveloperName, Queue.Name, Queue.type FROM QueueSobject WHERE Queue.Type = \'Queue\' AND SobjectType =\''+ String.escapeSingleQuotes(sObjName) + '\' AND Queue.DeveloperName IN :lstQueue  AND Queue.Name LIKE \'%' + String.escapeSingleQuotes(cadenaBusqueda) + '%\' ORDER BY Queue.Name LIMIT 20');
        }
    } 
    
    @AuraEnabled
    public static string functionChangeOwner(SObject obj,String recordId) {
        CBK_log.debug('Change Owner - RecordsId: '+ recordId + ' json object: ' + JSON.serialize(obj),  LoggingLevel.INFO);
        List<string> lstRecordsId = recordId.split(',');
        String sObjName = Id.valueOf(lstRecordsId[0]).getSObjectType().getDescribe().getName();
        string result;

        List<SObject> sObj =  Database.query('SELECT Id, OwnerId FROM ' + String.escapeSingleQuotes(sObjName) + ' WHERE Id IN :lstRecordsId');
        CBK_log.debug('Change Owner Objects - sObj: ' + JSON.serialize(sObj),  LoggingLevel.INFO);
        List<SObject> sObjUdp =  new List<SObject>();

        if (lstRecordsId.size() <= 10){
            if(sObj.size() > 0){
                for(SObject ob : sObj){
                    if(String.valueOf(obj.getSObjectType()) == 'QueueSobject'){
                        ob.put('OwnerId',obj.getSObject('Queue').get('Id'));
                        sObjUdp.add(ob);
                    }else{
                        ob.put('OwnerId',obj.getSObject('Assignee').get('Id'));
                        sObjUdp.add(ob);
                    }
                }

                Database.SaveResult[] lstResp = Database.update(sObjUdp, false);
                CBK_log.debug('ChangeOwner < 10: Response Update - ' + JSON.serialize(lstResp),  LoggingLevel.INFO);
                for(Database.SaveResult res : lstResp){
                    if (res.success){
                        result = 'OK';
                        CBK_log.debug('ChangeOwner < 10 - Update OK  - response: ' + json.serialize(res), LoggingLevel.INFO);
                    }else{
                        result =  'KO';
                        CBK_Log.error('Error ChangeOwner < 10 - Update KO - Response: ' + json.serialize(res.getErrors()));
                    }
                }
            }else{
                result =  'KO';
            }
        }else{
            result = createScheduleRegister(lstRecordsId, obj);
        }
        return result;
    }

    public static string getAppProjectByUser() {
        String strProject = '';

        if (!Test.isRunningTest()){
            List<UserAppInfo> userAppInfo = [SELECT Id, AppDefinitionId FROM UserAppInfo WHERE UserId = :UserInfo.getUserId() LIMIT 1];

            List<AppDefinition> appDefinition = [SELECT DurableId, Label, DeveloperName FROM AppDefinition Where DurableId = :userAppInfo[0].AppDefinitionId LIMIT 1];

            List<CBK_ChangeOwnerApp__mdt> changeOwnerConfig = [SELECT DeveloperNameApp__c, Project__c  FROM CBK_ChangeOwnerApp__mdt WHERE DeveloperNameApp__c =: appDefinition[0].DeveloperName limit 1];
            strProject = changeOwnerConfig.size() > 0 ? changeOwnerConfig[0].Project__c : '';
        }else{
            strProject = 'CBK';
        }
        return strProject;
	}

    public static string createScheduleRegister(List<string> lstIds, SObject obj){
        Datetime vToday = datetime.now();
        List<CBK_SCH_PendingProcess__c> lstSch =  new List<CBK_SCH_PendingProcess__c>();
        CBK_SCH_PendingProcess__c sch;
        string ownerOrQueueID = '';
        if(String.valueOf(obj.getSObjectType()) == 'QueueSobject'){
            ownerOrQueueID = String.valueOf(obj.getSObject('Queue').get('Id'));
        }else{
            ownerOrQueueID = String.valueOf(obj.getSObject('Assignee').get('Id'));
        }

        for(string ids : lstIds){
            String sObjName = Id.valueOf(ids).getSObjectType().getDescribe().getName();
            sch = new CBK_SCH_PendingProcess__c();
            sch.RecordId__c = ids;
            sch.Param1__c = sObjName;
            sch.Param2__c = ownerOrQueueID;
            sch.Type__c = String.valueOf(obj.getSObjectType());
            sch.Schedule_Time__c =  vToday.addMinutes(1);
            sch.ClassName__c = 'CBK_SCH_ChangeOwner';
            lstSch.add(sch);
        }

        List<CBK_ScheduleProcess_Controller.ResponseInsert> respInsert = CBK_ScheduleProcess_Controller.createRecordSchProcess(lstSch);
        CBK_log.debug('ChangeOwner Create Schedule register - response: ' + JSON.serialize(respInsert),  LoggingLevel.INFO);

        String result;
        for(CBK_ScheduleProcess_Controller.ResponseInsert resp : respInsert){

            if (!resp.hasError){
                result = 'OK';
                CBK_log.debug('ChangeOwner -  Create Schedule OK  - response: ' + json.serialize(resp), LoggingLevel.INFO);
            }else{
                result = 'KO';
                CBK_Log.error('Error ChangeOwner - Create schedule:  response: ' + json.serialize(resp));
            }
        }
        return result;
    }

    public class PicklistItems
	{
		@AuraEnabled
		public String value { get; set; }

		@AuraEnabled
		public string label { get; set; }
	}
}