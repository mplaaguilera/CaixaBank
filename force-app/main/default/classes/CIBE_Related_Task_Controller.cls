public  with sharing class CIBE_Related_Task_Controller {
    @AuraEnabled
    public static List<EventExtensionWrapper> getRecordInfo(String recordId) {
        Event evt = [SELECT AV_Task__c, accountId FROM Event WHERE Id = :recordId LIMIT 1];
		List<EventExtensionWrapper> response = new List<EventExtensionWrapper>();
        String avTaskString = null;
        String accId = null;
        List<Task> taskList;
        if(evt != null){
            avTaskString = evt.AV_Task__c;
            accId = evt.accountId;
        }

        if(avTaskString != null){
            List<CIBE_RelaccionadoCita__c> listEventTask = [SELECT Id, CIBE_TareaRelaccionada__c, CIBE_CitaRelaccionada__c, CIBE_IsMain__c
            				FROM CIBE_RelaccionadoCita__c WHERE CIBE_CitaRelaccionada__c = :avTaskString AND CIBE_TareaRelaccionada__c != NULL ORDER BY CIBE_IsMain__c ASC];
            Map<String, CIBE_RelaccionadoCita__c> eventExtensionMap = new Map<String, CIBE_RelaccionadoCita__c>();
            for(CIBE_RelaccionadoCita__c evtTask: listEventTask){
                eventExtensionMap.put(evtTask.CIBE_TareaRelaccionada__c, evtTask);
            }
            
        
        
            if(eventExtensionMap!= null && !eventExtensionMap.isEmpty()){
                for(Task tsk: [SELECT Id, AV_Task__c
                            	FROM Task where accountId = :accId AND AV_Task__c in :eventExtensionMap.KeySet()]){
                    
                    EventExtensionWrapper wrap = new EventExtensionWrapper();
                    wrap.Id = tsk.Id;
                    wrap.avTask = eventExtensionMap.get(tsk.AV_Task__c).CIBE_TareaRelaccionada__c;
                    wrap.avEvent = eventExtensionMap.get(tsk.AV_Task__c).CIBE_CitaRelaccionada__c;
                    wrap.isMain = eventExtensionMap.get(tsk.AV_Task__c).CIBE_IsMain__c;
                   	
                    response.add(wrap);
                }
            }
        
    	}
        response.sort();
        return response;
    }
    
    public class EventExtensionWrapper implements Comparable{
        @AuraEnabled public String id {get;set;}
        @AuraEnabled public String avTask {get;set;}
        @AuraEnabled public String avEvent {get;set;}
        @AuraEnabled public Boolean isMain {get;set;}

                
        public Integer compareTo(Object compareTo) {
                
            EventExtensionWrapper compareToWrap = (EventExtensionWrapper)compareTo;
            
            Integer returnValue = 0;
            if (compareToWrap.isMain) {
                returnValue = 1;
            } else{
                returnValue = -1;
            }       
            return returnValue;       
        }
    }
    
    
    /**
     * Retrieve the list of the opp's no related with task or event but is related with the customer
     */
    @AuraEnabled
    public static List<Task> retrieveListWithOutMeeting(String recordId){
       
        String methodName = 'retrieveListWithOutMeeting';
        Event evt = [SELECT AV_Task__c, accountId FROM Event WHERE Id = :recordId LIMIT 1];

        String avTaskString = null;
        String accId = null;
        List<Task> listTaskRes;
        if(evt != null){
            avTaskString = evt.AV_Task__c;
            accId = evt.accountId;
        }

        if(avTaskString != null){
            List<CIBE_RelaccionadoCita__c> listEventTask = [SELECT Id, CIBE_TareaRelaccionada__c
            				FROM CIBE_RelaccionadoCita__c WHERE CIBE_CitaRelaccionada__c = :avTaskString AND CIBE_TareaRelaccionada__c != NULL ORDER BY CIBE_IsMain__c DESC];
            Set<String> externalTaskIds = new Set<String>();
            
            for(CIBE_RelaccionadoCita__c evtTask: listEventTask){
                externalTaskIds.add(evtTask.CIBE_TareaRelaccionada__c);
                
            }              
            //Get the opp's no related
            
            if(accId != null){
                List<String> taskCIBRecordtypes = new List<String>{CIBE_AppConstants.TASK_ALERTACOMERCIAL_CIB_RT, CIBE_AppConstants.TASK_ONBOARDING_CIB_RT,
                                    CIBE_AppConstants.TASK_PRIORIZADOS_CIB_RT, CIBE_AppConstants.TASK_OTROS_CIB_RT, CIBE_AppConstants.TASK_AVISOS_CIB_RT,
                                    CIBE_AppConstants.TASK_EXPERIENCIACLIENTE_CIB_RT};

                listTaskRes = [SELECT Id From TASK WHERE AccountId = :accId and recordtype.developername in :taskCIBRecordtypes 
                                and AV_Task__c not in :externalTaskIds];
            }
        }
        return listTaskRes;
            
    }

    @AuraEnabled
    public static Boolean getMain(String recordId, String taskId) {
        List<CIBE_RelaccionadoCita__c> listEventTask = [SELECT Id, CIBE_IsMain__c
            				FROM CIBE_RelaccionadoCita__c WHERE CIBE_TareaRelaccionada__c = :taskId and CIBE_CitaRelaccionada__c = :recordId];
        if(!listEventTask.isEmpty()) {
            return listEventTask.get(0).CIBE_IsMain__c;
        }
        
        return false;
    }
    
    
    @AuraEnabled(cacheable=true)
    public static Task getTaskFields(String recordId) {
        List<Task> tasks = new List<Task>();
        if(String.isNotBlank(recordId) && Task.SObjectType.getDescribe().isAccessible()) {
            tasks = [SELECT Id, AV_Task__c, Subject, ActivityDate, Description, Account.Name, Owner.Name
             		FROM Task WHERE Id = :recordId];
        }
        if(!tasks.isEmpty()) {
            return tasks.get(0);
        }
        
        return null;
    }

    @AuraEnabled
    public static String linkTask(String recordId, String taskId){
            String avEvent = [SELECT AV_Task__c FROM Event WHERE Id = :recordId LIMIT 1].AV_Task__c;
            String  avTask = [SELECT AV_Task__c FROM Task WHERE Id = :taskId LIMIT 1].AV_Task__c;
        
        if(avEvent != null && avTask != null) {
            List<CIBE_RelaccionadoCita__c> listEventTask = [SELECT Id FROM CIBE_RelaccionadoCita__c 
                                                            WHERE CIBE_CitaRelaccionada__c = :avEvent AND CIBE_IsMain__c = true];
            

            List<CIBE_RelaccionadoCita__c> listOppTask = new List<CIBE_RelaccionadoCita__c>();
            if(CIBE_RelaccionadoCita__c.SObjectType.getDescribe().isAccessible()) {
                listOppTask = [SELECT Id  FROM CIBE_RelaccionadoCita__c WHERE CIBE_CitaRelaccionada__c = :avEvent AND CIBE_TareaRelaccionada__c = :avTask LIMIT 1];
            }


            if(!listOppTask.isEmpty()) {
                return 'KO';
            }
            
            //Id rt = Schema.SObjectType.CIBE_RelaccionadoCita__c.getRecordTypeInfosByDeveloperName().get(AV_AppConstants.OPPTASK_RT).getRecordTypeId();
            CIBE_RelaccionadoCita__c evtTask = new CIBE_RelaccionadoCita__c();
            evtTask.CIBE_CitaRelaccionada__c = avEvent;
            evtTask.CIBE_TareaRelaccionada__c = avTask;

            if(listEventTask.isEmpty()){
                evtTask.CIBE_IsMain__c = true;
            }
                
            if(CIBE_RelaccionadoCita__c.SObjectType.getDescribe().isCreateable()) {
                insert evtTask;
            }
            return 'OK';
        } else {
            return 'KO';
        }
    }
    
    
    /**
	* Method that delete the opp-task record when user unlink the oppoportunity from task
	* 
	*/
	@AuraEnabled
	public static void unlinkTask(String taskId, String eventId ) {
        String methodName = 'unlinkOpp';
        String avEvent = [Select AV_Task__c From Event Where Id = :eventId limit 1].AV_Task__c;
        String avTask = [Select AV_Task__c From Task where Id = :taskId limit 1].AV_Task__c;

        if(String.isNotBlank(avTask)){
            List<CIBE_RelaccionadoCita__c> listToDelete = new List<CIBE_RelaccionadoCita__c>();
            if(CIBE_RelaccionadoCita__c.SObjectType.getDescribe().isAccessible()) {
                listToDelete = [SELECT Id FROM CIBE_RelaccionadoCita__c WHERE CIBE_TareaRelaccionada__c =:avTask AND CIBE_CitaRelaccionada__c =:avEvent];
            }
           
            if(!listToDelete.isEmpty()){
                User user = AV_AppUtilities.getUserInfo();
                CIBE_RelaccionadoCita__c oppTask2 = new CIBE_RelaccionadoCita__c(Id=listToDelete.get(0).id, OwnerId=user.Id);
                
                if(CIBE_RelaccionadoCita__c.SObjectType.getDescribe().isUpdateable()) {
                    Database.update(oppTask2, false);
                }

                AV_LogDebug.printLogDebug(methodName, 'oppTask: ' + oppTask2);
                
                Database.DeleteResult deleteResult = Database.delete(oppTask2, false);
                List<Database.DeleteResult> listDeleteResult = new List<Database.DeleteResult>();
                listDeleteResult.add(deleteResult);
                AV_AppUtilities.displayErrors(methodName, listDeleteResult);                

            }
        }
	}
    
    
    /**
	* Method that update the opp-task main check
	*
	* @param oppTask AV_CustomActivityOpportunity__c record to update
	* @return void
	*/
	@AuraEnabled
	public static void updateMainRecord(String eventId, String taskId) {
        String avEvent = [SELECT AV_Task__c FROM Event WHERE Id = :eventId LIMIT 1].AV_Task__c;
		String avTask = [SELECT AV_Task__c FROM Task WHERE Id = :taskId LIMIT 1].AV_Task__c;
        
        if(String.isNotBlank(avEvent) && String.isNotBlank(avTask) && String.isNotBlank(eventId) && String.isNotBlank(taskId)){
            List<CIBE_RelaccionadoCita__c> listEventTask = new List<CIBE_RelaccionadoCita__c>();
            if(CIBE_RelaccionadoCita__c.SObjectType.getDescribe().isAccessible()) {
                listEventTask = [SELECT Id, CIBE_IsMain__c, CIBE_TareaRelaccionada__c FROM CIBE_RelaccionadoCita__c WHERE CIBE_CitaRelaccionada__c = :avEvent ];
                Map<String, CIBE_RelaccionadoCita__c> mapEventTsk = new Map<String, CIBE_RelaccionadoCita__c>();
            }
            
            List<CIBE_RelaccionadoCita__c> listToUpd = new List<CIBE_RelaccionadoCita__c>();                                 
            for(CIBE_RelaccionadoCita__c eventTask : listEventTask) {
                if(eventTask.CIBE_TareaRelaccionada__c == avTask && eventTask.CIBE_IsMain__c) {
                    eventTask.CIBE_IsMain__c = false;
                } else if(eventTask.CIBE_TareaRelaccionada__c == avTask && !eventTask.CIBE_IsMain__c){
                    eventTask.CIBE_IsMain__c = true;
                }else if(eventTask.CIBE_IsMain__c){
                    eventTask.CIBE_IsMain__c = false;
                }
                listToUpd.add(eventTask);
            }
            
            if(CIBE_RelaccionadoCita__c.SObjectType.getDescribe().isUpdateable()) {
                update listToUpd;
            }
        }
	}
    
    
    /**
     * @description     Determine if a user is part of a account team member
     * @param opportunityId   Id of opportunity
     * @param currentUser     CurrentUser Id
     */
    @AuraEnabled
    public static Boolean getAccountTeamMember(String taskId, String currentUser){
        Boolean result = true;
        List<Task> taskList = [SELECT AccountId FROM Task where Id = :taskId];
        
        if(!taskList.isEmpty() && taskList.get(0).accountId != null){
            List<AccountTeamMember> accTeamMemberList = [SELECT ID FROM AccountTeamMember 
                                                            WHERE AccountId = :taskList.get(0).accountId AND
                                                            (UserId = :currentUser OR Account.OwnerId = :currentUser)];
    
            List<Task> taskOwnerList = [SELECT Id from Task WHERE Id =:taskId AND OwnerId = :currentUser];
            if(!accTeamMemberList.isEmpty() || !taskOwnerList.isEmpty()){
                result = false;
            }
        }
        return result;
    }

}