/**********************************************************************************************************************
	Name:	  CIBE_AppUtilities
	Copyright © 2022  CaixaBank
	Test 		CIBE_AppUtilities_Test
-----------------------------------------------------------------------------------------------------------------------
Proposito: Clase de métodos útiles para la aplicación CIBE y EMP
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
	VERSION		USER_STORY	        AUTHOR		   		DATE			  Description
	1.0         App Utilities       Jose Maria          08/08/2022        Init version
    2.0         Get app definition  Jose Maria          
***********************************************************************************************************************/
public with sharing class CIBE_AppUtilities {

	
    /**
	 * @description		 	Retrieve All RecordTypes
	 * @param  objectName   Name of SObject
	 * @return			  	Return all RecordTypes 
	 */
	public static List<RecordType> getRecordTypes(String objectName){
        List<RecordType> listRT= [Select Id, DeveloperName, SobjectType, Name from RecordType where DeveloperName LIKE '%CIBE%' and SobjectType = :objectName];
		return listRT;
	}
    
	/**
	 * @description		 Retrieve RecordType
	 * @param  objectName  name of SObject
	 * @param  developerName	developerName of RecordType
	 * @return			  Return a RecordType 
	 */
	public static RecordType getRecordType(String objectName, String developerName){
        SObject so = [Select Id, DeveloperName, SobjectType, Name from RecordType where DeveloperName = :developerName and SobjectType = :objectName limit 1];
		return (RecordType) so;
	}
	
	/**
	 * @description		 Retrieve RecordType filter by Set of Developer Names
	 * @param  recorTypeName  set of Developer Names of RecordType
	 * @return			  Return a List of RecordType Ids
	 */
	public static Set<Id> getRecordTypeIdsInSet(Set<String> recorTypeName){
        List<RecordType> listRT = [Select Id, DeveloperName from RecordType where DeveloperName in :recorTypeName];
		Set<Id> setIdsRt = (new Map<Id,RecordType>(listRT)).keySet().clone();
		return setIdsRt;
	}
    
    /**
     * Wrapper class to search RT ID's without queries
     */
    public class SearchRT {
        public String strObjectName;
        public String strDeveloperName;
        
        public SearchRT(String objectName, String developerName){
            strObjectName = objectName;
            strDeveloperName = developerName;
        }
    }
    
    /**
	 * @description		 Retrieve RecordType filter by Set of Developer Names
	 * @param  recorTypeName  set of Developer Names of RecordType
	 * @return			  Return a List of RecordType Ids
	 */
	/*
    OLD VERSION
    public static Set<Id> getRecordTypeIdsInSet(Set<SearchRT> setRTs){
		Set<Id> setIdsRt = new Set<Id>();
        if(setRTs!=null && !setRTs.isEmpty()){
            for(SearchRT data : setRTs){
                if (String.isNotBlank(data.strObjectName) && String.isNotBlank(data.strDeveloperName)){
                    String idRT = Schema.getGlobalDescribe().get(data.strObjectName).getDescribe().getRecordTypeInfosByDeveloperName().get(data.strDeveloperName).getRecordTypeId();
                    setIdsRt.add(idRT);
                }
            }
        }
		return setIdsRt;
	}*/

    /**
     * @description      Retrieve RecordType filter by Set of Developer Names
     * @param  recorTypeName  set of Developer Names of RecordType
     * @return            Return a List of RecordType Ids
     *
     */
    public static Set<Id> getRecordTypeIdsInSet(Set<SearchRT> setRTs){
        Set<Id> setIdsRt = new Set<Id>();
        if(setRTs!=null && !setRTs.isEmpty()){
            // Acceder una vez al Schema, por si viene más de un objeto.
            Map<String,Map<String,Schema.RecordTypeInfo>> mapObjectRT = new Map<String,Map<String,Schema.RecordTypeInfo>>();
            for(SearchRT data : setRTs){                
                if (String.isNotBlank(data.strObjectName) && String.isNotBlank(data.strDeveloperName) && !mapObjectRT.containsKey(data.strObjectName)){
                    if (data.strObjectName == 'Opportunity') {
                        mapObjectRT.put(data.strObjectName, Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName());
                    }else if (data.strObjectName == 'Task') {
                        mapObjectRT.put(data.strObjectName, Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName());
                    } else if (data.strObjectName == 'Event') {
                        mapObjectRT.put(data.strObjectName, Schema.SObjectType.Event.getRecordTypeInfosByDeveloperName());
                    } else if (data.strObjectName == 'Account') {
                        mapObjectRT.put(data.strObjectName, Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName());
                    } else if (data.strObjectName == 'Contact') {
                        mapObjectRT.put(data.strObjectName, Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName());
                    } else {
                        mapObjectRT.put(data.strObjectName, Schema.getGlobalDescribe().get(data.strObjectName).getDescribe().getRecordTypeInfosByDeveloperName());
                    }
                }
            }
 
            for(SearchRT data : setRTs){                
                if (String.isNotBlank(data.strObjectName) && String.isNotBlank(data.strDeveloperName)){
                    String idRT = mapObjectRT?.get(data.strObjectName)?.get(data.strDeveloperName)?.getRecordTypeId();
                    if (String.isNotBlank(idRT)) {
                        setIdsRt.add(idRT);
                    }
                }
            }
        }
        return setIdsRt;
    }
    
    /**
	 * @description		 Retrieve RecordType filter by List of Developer Names
	 * @param  setName  set of String
	 * @return			  Return a List of String
	 */
	public static List<String> getListFromSet(Set<String> setName){
		List<String> listString = new List<String>();
        for(String setValue : setName){
			listString.add('\''+setValue+'\'');
		}
		return listString;
	}

	/**
     * Method to retrieve the sobject type from the record id
     *
     * @param recordIdOrPrefix  -> ID of the record
     * @return  string with the object type
     */
	public static String findObjectNameFromRecordIdPrefix(String recordIdOrPrefix){
		String objectName = AV_AppConstants.EMPTY;
		if (String.isBlank(recordIdOrPrefix)){
			throw new AV_ApplicationException('ID has no value');
		}
		try{
			
			String myIdPrefix = String.valueOf(recordIdOrPrefix).substring(0,3);

			Map<String, Schema.SObjectType> gd =  Schema.getGlobalDescribe();

			for(Schema.SObjectType stype : gd.values()){
				Schema.DescribeSObjectResult r = stype.getDescribe();
				String prefix = r.getKeyPrefix();
				if(String.isNotBlank(prefix) && prefix.equals(myIdPrefix)){
					objectName = r.getName();
					AV_LogDebug.printLogDebug('findObjectNameFromRecordIdPrefix', 'Object Name! ' + objectName);
					break;
				}
			}
		}catch(Exception e){
			AV_LogDebug.printException('findObjectNameFromRecordIdPrefix', e);
		}
		return objectName;
	}
	
	/**
	 * @description		 Class to compare datetime
	 * @param  fechaRefresh  Datetime of the last call to CLI api
	 * @param  today	Datetime of now just
	 * @return			  Return the different beetween both datetime in hours   
	 */
	public static Long calculateTimeDifferences(DateTime fechaRefresh, DateTime today){
		Long hours;
		Long fechaRefreshLong = fechaRefresh.getTime();
		Long todayLong = today.getTime();
		Long milliseconds = todayLong - fechaRefreshLong;
		Long seconds = milliseconds / 1000;
		Long minutes = seconds / 60;
		hours = minutes / 60;

		return hours;
	}

	/**
	 * Get the metadata scheduler
	 * @param developerName -> name of the batch
	 * @return	the data scheduler: Label + CronTrigger
	 */
	public static AV_ScheduleBatch__mdt getScheduleBatch(String developerName){
        SObject so = [Select Id, DeveloperName, MasterLabel, Language, NamespacePrefix, Label, QualifiedApiName, AV_Active__c, AV_CronTrigger__c, AV_NumDays__c, AV_Limit__c, AV_Description__c from AV_ScheduleBatch__mdt where DeveloperName = :DeveloperName limit 1];
		
		return (AV_ScheduleBatch__mdt)so;
	}
    
    /**
     * Retrieve the user logged in the system
     */
    public static User getUserInfo(){
        User userLoggeado = [Select Id, AV_Funcion__c, AV_ExternalID__c, AV_NumeroOficinaEmpresa__c, AV_ProfileName__c From User Where Id = :UserInfo.getUserId() limit 1];
        
        return userLoggeado;
	}

        /**
     * Retrieve API User info
     */
    public static User getUserGCF(){
        User userGcf = new User();
        if(Schema.SObjectType.USER.fields.Id.isAccessible()){
            userGcf = [SELECT Id FROM User WHERE Profile.Name = 'API Only' AND Alias = 'AV-TF9' LIMIT 1];
        }
        
        return userGcf;
	}
	
	/**
     * Retrieve the application from user is logged in the system
     */
	public static String getApplication() {
        List <LoginHistory> app = [SELECT application
                                   FROM LoginHistory 
                                   WHERE Id IN 
                                   (SELECT LoginHistoryId
                                    FROM AuthSession 
                                    WHERE IsCurrent = true
                                    AND UsersId =: UserInfo.getUserId())];
        if(app.isEmpty()){
            return null;
        }else{
            return app[0].application;
        }
    }

    /**
     * Display the errors from database Result: operation save
     */
    public static void displayErrors(String methodName, List<Database.SaveResult> listUpdateResult){
        if (listUpdateResult!=null && !listUpdateResult.isEmpty()){
            AV_LogDebug.printLogError(methodName, '***************************');
            for (Database.SaveResult sr : listUpdateResult) {
                if (!sr.isSuccess()) {
                
                    for(Database.Error err : sr.getErrors()) {
                        AV_LogDebug.printLogError(methodName, '----ERR status: ' + err.getStatusCode() + ': ' + err.getMessage());
                        AV_LogDebug.printLogError(methodName, '----ERR fields: ' + err.getFields());
                    }
                }
            }
            AV_LogDebug.printLogError(methodName, '***************************');
        }
    }
    
    /**
     * Display the errors from database Result: operation upsert
     */
    public static void displayErrors(String methodName, List<Database.UpsertResult> listUpdateResult){
        if (listUpdateResult!=null && !listUpdateResult.isEmpty()){
            AV_LogDebug.printLogError(methodName, '***************************');
            for (Database.UpsertResult sr : listUpdateResult) {
                if (!sr.isSuccess()) {
                    // Operation failed, so get all errors
                    for(Database.Error err : sr.getErrors()) {
                        AV_LogDebug.printLogError(methodName, '----ERR status: ' + err.getStatusCode() + ': ' + err.getMessage());
                        AV_LogDebug.printLogError(methodName, '----ERR fields: ' + err.getFields());
                    }
                }
            }
            AV_LogDebug.printLogError(methodName, '***************************');
        }
    }
    
    /**
     * Display the errors from database Result: operation delete
     */
    public static void displayErrors(String methodName, List<Database.DeleteResult> listDeleteResult){
        if (listDeleteResult!=null && !listDeleteResult.isEmpty()){
            AV_LogDebug.printLogError(methodName, '***************************');
            for (Database.DeleteResult sr : listDeleteResult) {
                if (!sr.isSuccess()) {
                    // Operation failed, so get all errors
                    for(Database.Error err : sr.getErrors()) {
                        AV_LogDebug.printLogError(methodName, '----ERR status: ' + err.getStatusCode() + ': ' + err.getMessage());
                        AV_LogDebug.printLogError(methodName, '----ERR fields: ' + err.getFields());
                    }
                }
            }
            AV_LogDebug.printLogError(methodName, '***************************');
        }
    }
    
    /**
     * Delete data of customer:
     * 1.- Task-Opp
     * 2.- Opp
     * 3.- Header-Task
     * 4.- Header-Event
     * 5.- Manage History
     * 6.- CBK Activity Extension
     * 6.- Task
     * 7.- Event
     */
    public static void deleteDataCustomer(String idCustomer){
        String methodName = 'deleteDataCustomer';
        if (String.isNotBlank(idCustomer)){
            //*******************************
            //************* Delete task-opp
            List<AV_CustomActivityOpportunity__c> listDataTaskOpp = [Select Id From AV_CustomActivityOpportunity__c Where AV_Opportunity__r.AccountId = :idCustomer and RecordType.DeveloperName like 'AV_%'];
            
            List<Database.DeleteResult> listResultDatabase = Database.delete(listDataTaskOpp, false);
            AV_LogDebug.printLogDebug(methodName, 'Delete Task-Opp, Number: ' + listDataTaskOpp.size());
            displayErrors(methodName, listResultDatabase);
            
            //*******************************
            //************* Delete Opp
            List<Opportunity> listDataOpp = [Select Id From Opportunity Where AccountId = :idCustomer and RecordType.DeveloperName like 'CIBE_%'];
            
            listResultDatabase = Database.delete(listDataOpp, false);
            AV_LogDebug.printLogDebug(methodName, 'Delete Opp, Number: ' + listDataOpp.size());
            displayErrors(methodName, listResultDatabase);
            
            deleteTaskCustomer(idCustomer);
            deleteEventCustomer(idCustomer);
        }
    }
    
    public static void deleteTaskCustomer(String idCustomer){
        String methodName = 'deleteTaskCustomer';
        //*******************************
        //************* Delete Task
        List<Task> listDataTask = [Select Id, AV_Task__c, AV_ExternalID__c From Task Where AccountId = :idCustomer and RecordType.DeveloperName like 'CIBE_%'];
        
        Map<Id, Task> mapIdsTask = new Map<Id, Task>(listDataTask);
        
        List<Id> listIdsHeaderTask = new List<Id>();
        Set<String> listExternalIdsHeaderTask = new Set<String>();
        for (Task aux : listDataTask){
            if (String.isNotBlank(aux.AV_Task__c)){
                listIdsHeaderTask.add(aux.AV_Task__c);
            }
            else if (String.isNotBlank(aux.AV_ExternalID__c)){
                listExternalIdsHeaderTask.add(aux.AV_ExternalID__c);
            }
        }
        
        //Delete Management History
        List<AV_ManagementHistory__c> listDataManagementHistory = [Select Id From AV_ManagementHistory__c Where AV_ActivityId__c in :mapIdsTask.keySet()];
        
        List<Database.DeleteResult> listResultDatabase = Database.delete(listDataManagementHistory, false);
        AV_LogDebug.printLogDebug(methodName, 'Delete Management History Task, Number: ' + listDataManagementHistory.size());
        displayErrors(methodName, listResultDatabase);
        
        //Delete CBK Activity Extension
        List<CBK_Activity_Extension__c> listTaskExtension = [Select Id From CBK_Activity_Extension__c Where AV_ActivityId__c in :mapIdsTask.keySet() or AV_ReasignarCartera_Id_Task__c in :mapIdsTask.keySet()];
       
        listResultDatabase = Database.delete(listTaskExtension, false);
        AV_LogDebug.printLogDebug(methodName, 'Delete Task Extension, Number: ' + listTaskExtension.size());
        displayErrors(methodName, listResultDatabase);
        
        //Delete Task
        listResultDatabase = Database.delete(listDataTask, false);
        AV_LogDebug.printLogDebug(methodName, 'Delete Task, Number: ' + listDataTask.size());
        displayErrors(methodName, listResultDatabase);
        
        //Delete Header-Task
        List<AV_HeaderCustomActivity__c> listHeaderTask = [Select Id From AV_HeaderCustomActivity__c Where Id in :listIdsHeaderTask or AV_ExternalID__c in :listExternalIdsHeaderTask];
        
        listResultDatabase = Database.delete(listHeaderTask, false);
        AV_LogDebug.printLogDebug(methodName, 'Delete Header-Task, Number: ' + listHeaderTask.size());
        displayErrors(methodName, listResultDatabase);
    }
    
    public static void deleteEventCustomer(String idCustomer){
        String methodName = 'deleteEventCustomer';
        //*******************************
        //************* Delete Event
        List<Event> listDataEvent = [Select Id, AV_Task__c, AV_ExternalID__c From Event Where AccountId = :idCustomer and IsRecurrence2 = false and IsRecurrence = false and RecordType.DeveloperName like 'CIBE_%'];
        
        Map<Id, Event> mapIdsEvent = new Map<Id, Event>(listDataEvent);
        
        List<Id> listIdsHeaderEvent = new List<Id>();
        Set<String> listExternalIdsHeaderEvent = new Set<String>();
        for (Event aux : listDataEvent){
            if (String.isNotBlank(aux.AV_Task__c)){
                listIdsHeaderEvent.add(aux.AV_Task__c);
            }
            else if (String.isNotBlank(aux.AV_ExternalID__c)){
                listExternalIdsHeaderEvent.add(aux.AV_ExternalID__c);
            }
        }
        
        //Delete Management History
        List<AV_ManagementHistory__c> listDataManagementHistory = [Select Id From AV_ManagementHistory__c Where AV_ActivityId__c in :mapIdsEvent.keySet()];
        
        List<Database.DeleteResult> listResultDatabase = Database.delete(listDataManagementHistory, false);
        AV_LogDebug.printLogDebug(methodName, 'Delete Management History Event, Number: ' + listDataManagementHistory.size());
        displayErrors(methodName, listResultDatabase);
        
        //Delete CBK Activity Extension
        List<CBK_Activity_Extension__c> listEventExtension = [Select Id From CBK_Activity_Extension__c Where AV_ActivityId__c in :mapIdsEvent.keySet() or AV_ReasignarCartera_Id_Task__c in :mapIdsEvent.keySet()];
       
        listResultDatabase = Database.delete(listEventExtension, false);
        AV_LogDebug.printLogDebug(methodName, 'Delete Event Extension, Number: ' + listEventExtension.size());
        displayErrors(methodName, listResultDatabase);
        
        //Delete Event
        listResultDatabase = Database.delete(listDataEvent, false);
        AV_LogDebug.printLogDebug(methodName, 'Delete Event, Number: ' + listDataEvent.size());
        displayErrors(methodName, listResultDatabase);
        
        //Delete Header-Event
        List<AV_HeaderCustomActivity__c> listHeaderEvent = [Select Id From AV_HeaderCustomActivity__c Where Id in :listIdsHeaderEvent or AV_ExternalID__c in :listExternalIdsHeaderEvent];
       
        listResultDatabase = Database.delete(listHeaderEvent, false);
        AV_LogDebug.printLogDebug(methodName, 'Delete Header-Event, Number: ' + listHeaderEvent.size());
        displayErrors(methodName, listResultDatabase);
    }

    /**
	 * Used to determine whether the current user is a Bank Teller
	 * necessary for conditional rendering in a LWC.
	 */
	@AuraEnabled
	public static Boolean isBankTeller() {
        return FeatureManagement.checkPermission('AV_BankTeller_Custom');
	}

    /**
	 * Set pass to String format ('Ejemplo','Prueba')
	 */
    public static String setToStringIn(Set<String> setUserIds) {
        String listUserIds = '(';
		Integer cont=0;
		for(String s: setUserIds) {
			listUserIds=listUserIds+'\''+ s + '\'';
			if (cont == setUserIds.size()-1){
				listUserIds=listUserIds+')';
			} else {
				listUserIds=listUserIds+',';
			}
			cont++;
		}
        System.debug('prueba2 ' + listUserIds);
        return listUserIds;
	}

        /**
     * Check if th status code is error or not.
     * Usually the responses accepted are: 200, 201 or 204
     */
    public static boolean checkErrorStatusCode(HTTPResponse response){
        Set<String> httpStatusList = new Set<String>();
        httpStatusList.add(CIBE_AppConstants.HTTP_STATUS_OK);
        httpStatusList.add(CIBE_AppConstants.HTTP_STATUS_CREATED);
        httpStatusList.add(CIBE_AppConstants.HTTP_STATUS_ACCEPTED);
        String codigoStado = String.valueOf(response.getStatusCode());
        return httpStatusList.contains(codigoStado);
    }

    @AuraEnabled(cacheable=true) 
	public static String getAppDefinition() {
        if(Schema.sObjectType.UserAppInfo.isAccessible() && Schema.sObjectType.AppDefinition.isAccessible()){
            List <UserAppInfo> lstUsAppInfo = new List <UserAppInfo>();
            Set<Id> setIds = new Set<Id>();
            AppDefinition appDefinition = null;
            try{
                lstUsAppInfo = [SELECT Id, AppDefinitionId FROM UserAppInfo WHERE UserId = :UserInfo.getUserId() AND FormFactor ='Large'];
            }catch(Exception e){
                AV_LogDebug.printException('getAppDefinition - userAppInfo ', e);
            }
            if(lstUsAppInfo!=null && !lstUsAppInfo.isEmpty()){
                for(UserAppInfo uai: lstUsAppInfo){
                    setIds.add(uai.AppDefinitionId);
                }
                if(setIds!=null && !setIds.isEmpty()){
                    try{
                        appDefinition = [SELECT id, DurableId, DeveloperName FROM AppDefinition WHERE DurableId = :setIds LIMIT 1];
                    }catch(Exception e){
                        AV_LogDebug.printException('getAppDefinition - appDefinition ', e);
                    }
                }
            }
            if(appDefinition!=null){
                return appDefinition.DeveloperName;
            }
        }
        return null;
    }

    public static String getMonthName(Integer month, String locale) {
        switch on locale {
            when 'es' {
                Map<Integer, String> spanishMonths = new Map<Integer, String>{
                    1 => 'Enero',
                    2 => 'Febrero',
                    3 => 'Marzo',
                    4 => 'Abril',
                    5 => 'Mayo',
                    6 => 'Junio',
                    7 => 'Julio',
                    8 => 'Agosto',
                    9 => 'Septiembre',
                    10 => 'Octubre',
                    11 => 'Noviembre',
                    12 => 'Diciembre'
                };

                return spanishMonths.containsKey(month) ? spanishMonths.get(month) : '';
            }
            when 'en_US' {
                Map<Integer, String> englishMonths = new Map<Integer, String>{
                    1 => 'January',
                    2 => 'February',
                    3 => 'March',
                    4 => 'April',
                    5 => 'May',
                    6 => 'June',
                    7 => 'July',
                    8 => 'August',
                    9 => 'September',
                    10 => 'October',
                    11 => 'November',
                    12 => 'December'
                };

                return englishMonths.containsKey(month) ? englishMonths.get(month) : '';
            }
            when else {
                return '';
            }
        }
    }

}