/**********************************************************************************************************************
 Name:	  AV_AppUtilities
 Copyright © 2020  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Clase de métodos útiles para la aplicación
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
   VERSION		USER_STORY	   AUTHOR		   		DATE			  Description
   	1.0			App FSC		  David Rufo	   		11/02/2020		  Init version
   	1.1			App FSC		  David Rufo	   		11/02/2020		  Method for send emails
	1.2			App FSC		  Carolina Alonso	   	27/04/2020		  Method for retrieve RecordType
	1.3			App FSC		  Carolina Alonso	   	06/05/2020		  Method for retrieve RecordTypeIds in Set
	1.4			App FSC		  Esperanza Conde		01/10/2020		  Method to calculate time differences
	1.5			App FSC		  Sandra Gómez			04/11/2020		  Method to get the limit batches
	1.6			App FSC		  Sandra Gómez			16/11/2020		  Comment Method
	1.7			App FSC		  David Rufo			15/12/2020		  New method to retrieve the user info logged
	1.8			App FSC		  Jashanpreet			01/03/2020		  New method to retrieve the app where user is logged
	1.9			App FSC		  David Rufo			12/05/2020		  New method to display errors for database results
	1.10		App FSC		  David Rufo			14/05/2020		  Improve the get RT ID without query
	1.11		App FSC		  David Rufo			30/06/2020		  Method to delete data of a customer
    1.12		US276250	  Víctor Santiago		15/10/2021		  Added method dmlFichaProd
    1.13		Fix IOP Dic	  Víctor Santiago		14/12/2021		  Deleted method dmlFichaProd
    1.14		AV_Query IT	  Daniel Rodríguez  	3/02/2022		  Change AV_Query to SOQL for User and Account
    1.15		US284560	  Víctor Santiago		11/02/2022		  Added method isBankTeller
	1.2			OrgHealth	  Carolina Alonso		17/03/2022		  Added method getListFromSet to get a List from a set os strings
    1.3			Test Class	  Sandra Gómez		    22/03/2022		  Added method setToStringIn
    1.4         Fix           Sandra Gómez          06/04/2022        Added method listToStringIn
***********************************************************************************************************************/
public with sharing class AV_AppUtilities {

	/**
	 * @description		 Send mail to recipients
	 * @param  toAddresses  email of recipients
	 * @param  ccAddress	email for copy recipients
	 * @param  bccAddress   email for bcc recipients
	 * @param  subject	  subject of the mail
	 * @param  message	  plain text message of the mail(If null it will be send a html template)
	 * @param  htmlBody	 Body of the html template in plain text
	 * @param  sender	   Sender of the mail
	 * @return			  Return an status code of the process: If no errors 'ok', else 'error'
	 */
	/*public static void sendMessageMail(String[] toAddresses, String[] ccAddress, String[] bccAddress, String subject, String message, String htmlBody, String sender){
		Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
		mail.setToAddresses(toAddresses);
		if(ccAddress!=null && !ccAddress.isEmpty()){
			mail.setCcAddresses(ccAddress);
		}
		if(bccAddress!=null && !bccAddress.isEmpty()){
			mail.setBccAddresses(bccAddress);
		}
		mail.setSubject(subject);
		if(String.isBlank(htmlBody)){
			mail.setPlainTextBody(message);
		}else{
			mail.setHtmlBody(htmlBody);
		}
		if (String.isNotBlank(sender)){
			//mail.setSenderDisplayName(sender);
			mail.setOrgWideEmailAddressId(sender);
		}
		try{
			Messaging.SingleEmailMessage[] messages = new List<Messaging.SingleEmailMessage> {mail};
			Messaging.sendEmailResult[] results = new List<Messaging.SendEmailResult>();
			results = Messaging.sendEmail(messages);
		}catch(System.EmailException e){
			AV_LogDebug.printException('sendMessageMail', e);
			throw new AV_ApplicationException(e.getMessage());
		}
	}*/

	/**
	 * @DEPRECATED------------------------------------------------------------
	 * -----------------------------------------------------------------------
	 * @description		 Retrieve RecordType
	 * @param  objectName  name of SObject
	 * @param  developerName	developerName of RecordType
	 * @return			  Return a RecordType 
	 */
	public static RecordType getRecordType(String objectName, String developerName){
        SObject so;
        if(Schema.sObjectType.RecordType.isAccessible()){

            so = [Select Id, DeveloperName, SobjectType, Name from RecordType where DeveloperName = :developerName and SobjectType = :objectName limit 1];
        }
		/*SObject so = new AV_Query('RecordType')
							.selectFields('Id, DeveloperName, SobjectType, Name')
							.addConditionEq('DeveloperName', developerName)
							.addConditionEq('SobjectType', objectName)
							.fetch();*/
		return (RecordType) so;
	}
	
	/**
	 * @DEPRECATED------------------------------------------------------------
	 * -----------------------------------------------------------------------
	 * @description		 Retrieve RecordType filter by Set of Developer Names
	 * @param  recorTypeName  set of Developer Names of RecordType
	 * @return			  Return a List of RecordType Ids
	 */
	public static Set<Id> getRecordTypeIdsInSet(Set<String> recorTypeName){
        List<RecordType> listRt = new List<RecordType>();
        if(Schema.sObjectType.RecordType.isAccessible()){
             listRT = [Select Id, DeveloperName from RecordType where DeveloperName in :recorTypeName];
        }
		/*List<RecordType> listRT = new AV_Query('RecordType')
										.selectFields('Id, DeveloperName')
										.addConditionIn('DeveloperName', recorTypeName)
										.run();*/
		Set<Id> setIdsRt = (new Map<Id,RecordType>(listRT)).keySet().clone();
		return setIdsRt;
	}
    /**
     * @description Generate a map with the Name of a set of RT's and the Object RT
     * @param List of Recordtypes to map.
     * @return Return a map joining RT Name and Rt Object
     */
    public static Map<String,RecordType> getRecordTypeInMap(Set<String> recordTypeName){
        List<RecordType> listRt = new List<RecordType>();
        if(Schema.sObjectType.RecordType.isAccessible()){
         listRT = [SELECT ID,NAME,DeveloperName FROM RecordType WHERE DeveloperName in :recordTypeName];
        }
        Map<String,RecordType> mapRT = new Map<String,RecordType>();
        for(RecordType rt : listRt){
            mapRT.put(rt.Name,rt);
        }
        return mapRT;
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
    public static Set<Id> getRecordTypeIdsInSet(Set<SearchRT> setRTs){
        Set<Id> setIdsRt = new Set<Id>();
        if(setRTs!=null && !setRTs.isEmpty()){
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
			//Get prefix from record ID
			//This assumes that you have passed at least 3 characters
			String myIdPrefix = String.valueOf(recordIdOrPrefix).substring(0,3);

			//Get schema information
			Map<String, Schema.SObjectType> gd =  Schema.getGlobalDescribe();

			//Loop through all the sObject types returned by Schema
			for(Schema.SObjectType stype : gd.values()){
				//if (!sObj.contains('__')) to exclude managed package objects
				Schema.DescribeSObjectResult r = stype.getDescribe();
				String prefix = r.getKeyPrefix();

				//Check if the prefix matches with requested prefix
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

	/*public static Integer sumaPesos(String secuencia) {
		Integer[] pesos = new Integer[]{6, 3, 7, 9, 10, 5, 8, 4, 2, 1};
		Integer i = 0;
		Integer peso = 0;
		Integer val = 0;
		Integer len = 0;
		
		len = secuencia.length();
		for (i = 1; i <= len; ++i) {
		  val = secuencia.charAt(len - i);
		  peso = peso + pesos[i - 1] * val;
		}
		peso = 11 - Math.mod(peso, 11);
		if (peso == 10) {
		  peso = 1;
		}
		else if (peso == 11) {
		  peso = 0;
		}
		return peso;
	  }

	  /**
     * Para comprobar que el formato del numero de cuenta es correcto
     */
    /*public static Boolean VerificaDigitControl(String InString) {

		String entidad; //= InString.substring(0, 4);9690
		String oficina; //= InString.substring(4, 8);0325
		String digitosControl; //= InString.substring(8, 10);32
		String modalidad; //= InString.substring(10, 12);70
		String numeroCuenta;  //= InString.substring(12, 18);4529
		String digitosControlCuenta; //= InString.substring(18, 20);
		// 
		for(integer i = 0; i < InString.length(); i++) {
            if(i<4) {
                entidad = InString.substring(0,4);
            } 
            if(i>=4 && i<=7) {
                oficina = InString.substring(4,8);
            } 
            if(i>=8 && i<=9) {
                digitosControl = InString.substring(8,10);
			}
			if(i>=10 && i<=11) {
                modalidad = InString.substring(10,12);
			}
			if(InString.length() >= 18){
				if(i>=12 && i<=17) {
					numeroCuenta = InString.substring(12,18);
				}
				if(InString.length() == 20){
					if(i>=18 && i<=19) {
						digitosControlCuenta = InString.substring(18,20);
					}
				}
			}else{
				if(i>=12 && i<=InString.length()) {
					numeroCuenta = InString.substring(12,InString.length());
				}
			} 
        }
		String digitosControlCCC = (sumaPesos(entidad + oficina)).format() + sumaPesos(modalidad + numeroCuenta + (digitosControlCuenta)).format();
		
		if (digitosControlCCC == digitosControl) {
		  return true;
		}
		else {
		  return false;
		}
	}*/

	/**
	 * Get the metadata scheduler
	 * @param developerName -> name of the batch
	 * @return	the data scheduler: Label + CronTrigger
	 */
	public static AV_ScheduleBatch__mdt getScheduleBatch(String developerName){
        SObject so;
        if(Schema.sObjectType.AV_ScheduleBatch__mdt.isAccessible()){
            so  = [Select Id, DeveloperName, MasterLabel, Language, NamespacePrefix, Label, QualifiedApiName, AV_Active__c, AV_CronTrigger__c, AV_NumDays__c, AV_Limit__c, AV_Description__c from AV_ScheduleBatch__mdt where DeveloperName = :DeveloperName limit 1];
        }
		/*SObject so = new AV_Query('AV_ScheduleBatch__mdt')
				.selectAllFields()
				.addConditionEq('DeveloperName', developerName)
				.fetch();*/
		return (AV_ScheduleBatch__mdt)so;
	}
    
    /**
     * Retrieve the user logged in the system
     */
    public static User getUserInfo(){
        User userLoggeado;
        if(Schema.sObjectType.User.isAccessible()){
            userLoggeado = [Select Id, AV_Funcion__c, AV_ExternalID__c, AV_NumeroOficinaEmpresa__c, AV_ProfileName__c From User Where Id = :UserInfo.getUserId() limit 1];
        }
        /*User userLoggeado = (User)new AV_Query('User')
                                .selectFields('Id, AV_Funcion__c, AV_ExternalID__c, AV_NumeroOficinaEmpresa__c, AV_ProfileName__c')
                                .addConditionEq('Id', UserInfo.getUserId())
                                .fetch();*/
        return userLoggeado;
	}
	
	/**
     * Retrieve the application from user is logged in the system
     */
	public static String getApplication() {
        List <LoginHistory> app = new List <LoginHistory>();

        if(Schema.sObjectType.LoginHistory.isAccessible() && Schema.sObjectType.AuthSession.isAccessible()){

            app = [SELECT application
            FROM LoginHistory 
            WHERE Id IN 
            (SELECT LoginHistoryId
            FROM AuthSession 
            WHERE IsCurrent = true
            AND UsersId =: UserInfo.getUserId())];
        }
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
            List<AV_CustomActivityOpportunity__c> listDataTaskOpp = new List<AV_CustomActivityOpportunity__c>();
            if(Schema.sObjectType.AV_CustomActivityOpportunity__c.isAccessible()){
                listDataTaskOpp = [Select Id From AV_CustomActivityOpportunity__c Where AV_Opportunity__r.AccountId = :idCustomer and RecordType.DeveloperName like 'AV_%'];
            }
            /*AV_Query avQuery = new AV_Query('AV_CustomActivityOpportunity__c')
                                        .selectFields('ID')
                                        .addConditionEq('AV_Opportunity__r.AccountId', idCustomer)
                                        .addConditionLike('RecordType.DeveloperName', 'AV_%');
			AV_LogDebug.printLogDebug(methodName, 'Delete Task-Opp, Query to execute: ' + avQuery.toQueryString());
            List<AV_CustomActivityOpportunity__c> listDataTaskOpp = avQuery.run();*/
            List<Database.DeleteResult> listResultDatabase = Database.delete(listDataTaskOpp, false);
            AV_LogDebug.printLogDebug(methodName, 'Delete Task-Opp, Number: ' + listDataTaskOpp.size());
            displayErrors(methodName, listResultDatabase);
            
            //*******************************
            //************* Delete Opp
            List<Opportunity> listDataOpp = new List<Opportunity>();
            if(Schema.sObjectType.Opportunity.isAccessible()){
                listDataOpp = [Select Id From Opportunity Where AccountId = :idCustomer and RecordType.DeveloperName like 'AV_%'];
            }
            /*avQuery = new AV_Query('Opportunity')
                                        .selectFields('ID')
                                        .addConditionEq('AccountId', idCustomer)
                                        .addConditionLike('RecordType.DeveloperName', 'AV_%');
			AV_LogDebug.printLogDebug(methodName, 'Delete Opp, Query to execute: ' + avQuery.toQueryString()); 
            List<Opportunity> listDataOpp = avQuery.run();*/
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
        List<Task> listDataTask = new List<Task>();
        if(Schema.sObjectType.Task.isAccessible()){
             listDataTask = [Select Id, AV_Task__c, AV_ExternalID__c From Task Where AccountId = :idCustomer and RecordType.DeveloperName like 'AV_%'];
        }
        /*AV_Query avQuery = new AV_Query('Task')
            .selectFields('Id, AV_Task__c, AV_ExternalID__c')
            .addConditionEq('AccountId', idCustomer)
            .addConditionLike('RecordType.DeveloperName', 'AV_%');
        AV_LogDebug.printLogDebug(methodName, 'Delete Task, Query to execute: ' + avQuery.toQueryString()); 
        List<Task> listDataTask = avQuery.run();*/
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
        List<AV_ManagementHistory__c> listDataManagementHistory = new List<AV_ManagementHistory__c>();
        if(Schema.sObjectType.AV_ManagementHistory__c.isAccessible()){
            listDataManagementHistory = [Select Id From AV_ManagementHistory__c Where AV_ActivityId__c in :mapIdsTask.keySet()];
        }
        /*avQuery = new AV_Query('AV_ManagementHistory__c')
            .selectFields('Id')
            .addConditionIn('AV_ActivityId__c', mapIdsTask.keySet());
        AV_LogDebug.printLogDebug(methodName, 'Delete Management History Task, Query to execute: ' + avQuery.toQueryString()); 
        List<AV_ManagementHistory__c> listDataManagementHistory = avQuery.run();*/
        List<Database.DeleteResult> listResultDatabase = Database.delete(listDataManagementHistory, false);
        AV_LogDebug.printLogDebug(methodName, 'Delete Management History Task, Number: ' + listDataManagementHistory.size());
        displayErrors(methodName, listResultDatabase);
        
        //Delete CBK Activity Extension
        List<CBK_Activity_Extension__c> listTaskExtension = new List<CBK_Activity_Extension__c>();
        if(Schema.sObjectType.CBK_Activity_Extension__c.isAccessible()){
            listTaskExtension = [Select Id From CBK_Activity_Extension__c Where AV_ActivityId__c in :mapIdsTask.keySet() or AV_ReasignarCartera_Id_Task__c in :mapIdsTask.keySet()];
        }
        /*avQuery = new AV_Query('CBK_Activity_Extension__c')
            .selectFields('Id')
            .addCondition(
                AV_Query.doOr(
                    AV_Query.conditionIn('AV_ActivityId__c', mapIdsTask.keySet()),
                    AV_Query.conditionIn('AV_ReasignarCartera_Id_Task__c', mapIdsTask.keySet())
                )
            );
        AV_LogDebug.printLogDebug(methodName, 'Delete Task Extension, Query to execute: ' + avQuery.toQueryString()); 
        List<CBK_Activity_Extension__c> listTaskExtension = avQuery.run();*/
        listResultDatabase = Database.delete(listTaskExtension, false);
        AV_LogDebug.printLogDebug(methodName, 'Delete Task Extension, Number: ' + listTaskExtension.size());
        displayErrors(methodName, listResultDatabase);
        
        //Delete Task
        listResultDatabase = Database.delete(listDataTask, false);
        AV_LogDebug.printLogDebug(methodName, 'Delete Task, Number: ' + listDataTask.size());
        displayErrors(methodName, listResultDatabase);
        
        //Delete Header-Task
        List<AV_HeaderCustomActivity__c> listHeaderTask = new List<AV_HeaderCustomActivity__c>();
        if(Schema.sObjectType.AV_HeaderCustomActivity__c.isAccessible()){

            listHeaderTask = [Select Id From AV_HeaderCustomActivity__c Where Id in :listIdsHeaderTask or AV_ExternalID__c in :listExternalIdsHeaderTask];
        }
        /*avQuery = new AV_Query('AV_HeaderCustomActivity__c')
            .selectFields('Id')
            .addCondition(
                AV_Query.doOr(
                    AV_Query.conditionIn('Id', listIdsHeaderTask),
                    AV_Query.conditionIn('AV_ExternalID__c', listExternalIdsHeaderTask)
                )
            )
            .addConditionLike('RecordType.DeveloperName', 'AV_%');
        AV_LogDebug.printLogDebug(methodName, 'Delete Header-Task, Query to execute: ' + avQuery.toQueryString());
        List<AV_HeaderCustomActivity__c> listHeaderTask = avQuery.run();*/
        listResultDatabase = Database.delete(listHeaderTask, false);
        AV_LogDebug.printLogDebug(methodName, 'Delete Header-Task, Number: ' + listHeaderTask.size());
        displayErrors(methodName, listResultDatabase);
    }
    
    public static void deleteEventCustomer(String idCustomer){
        String methodName = 'deleteEventCustomer';
        //*******************************
        //************* Delete Event
        List<Event> listDataEvent = new List<Event>();
        if(Schema.sObjectType.Event.isAccessible()){
            listDataEvent = [Select Id, AV_Task__c, AV_ExternalID__c From Event Where AccountId = :idCustomer and IsRecurrence2 = false and IsRecurrence = false and RecordType.DeveloperName like 'AV_%'];
        }
        /*AV_Query avQuery = new AV_Query('Event')
            .selectFields('Id, AV_Task__c, AV_ExternalID__c')
            .addConditionEq('AccountId', idCustomer)
            .addConditionEq('IsRecurrence2', false)
            .addConditionEq('IsRecurrence', false)
            .addConditionLike('RecordType.DeveloperName', 'AV_%');
        AV_LogDebug.printLogDebug(methodName, 'Delete Event, Query to execute: ' + avQuery.toQueryString()); 
        List<Event> listDataEvent = avQuery.run();*/
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
        /*avQuery = new AV_Query('AV_ManagementHistory__c')
            .selectFields('Id')
            .addConditionIn('AV_ActivityId__c', mapIdsEvent.keySet());
        AV_LogDebug.printLogDebug(methodName, 'Delete Management History Event, Query to execute: ' + avQuery.toQueryString()); 
        List<AV_ManagementHistory__c> listDataManagementHistory = avQuery.run();*/
        List<Database.DeleteResult> listResultDatabase = Database.delete(listDataManagementHistory, false);
        AV_LogDebug.printLogDebug(methodName, 'Delete Management History Event, Number: ' + listDataManagementHistory.size());
        displayErrors(methodName, listResultDatabase);
        
        //Delete CBK Activity Extension
        List<CBK_Activity_Extension__c> listEventExtension = [Select Id From CBK_Activity_Extension__c Where AV_ActivityId__c in :mapIdsEvent.keySet() or AV_ReasignarCartera_Id_Task__c in :mapIdsEvent.keySet()];
        /*avQuery = new AV_Query('CBK_Activity_Extension__c')
            .selectFields('Id')
            .addCondition(
                AV_Query.doOr(
                    AV_Query.conditionIn('AV_ActivityId__c', mapIdsEvent.keySet()),
                    AV_Query.conditionIn('AV_ReasignarCartera_Id_Task__c', mapIdsEvent.keySet())
                )
            );
        AV_LogDebug.printLogDebug(methodName, 'Delete Event Extension, Query to execute: ' + avQuery.toQueryString()); 
        List<CBK_Activity_Extension__c> listEventExtension = avQuery.run();*/
        listResultDatabase = Database.delete(listEventExtension, false);
        AV_LogDebug.printLogDebug(methodName, 'Delete Event Extension, Number: ' + listEventExtension.size());
        displayErrors(methodName, listResultDatabase);
        
        //Delete Event
        listResultDatabase = Database.delete(listDataEvent, false);
        AV_LogDebug.printLogDebug(methodName, 'Delete Event, Number: ' + listDataEvent.size());
        displayErrors(methodName, listResultDatabase);
        
        //Delete Header-Event
        List<AV_HeaderCustomActivity__c> listHeaderEvent = [Select Id From AV_HeaderCustomActivity__c Where Id in :listIdsHeaderEvent or AV_ExternalID__c in :listExternalIdsHeaderEvent];
        /*avQuery = new AV_Query('AV_HeaderCustomActivity__c')
            .selectFields('Id')
            .addCondition(
                AV_Query.doOr(
                    AV_Query.conditionIn('Id', listIdsHeaderEvent),
                    AV_Query.conditionIn('AV_ExternalID__c', listExternalIdsHeaderEvent)
                )
            )
            .addConditionLike('RecordType.DeveloperName', 'AV_%');
        AV_LogDebug.printLogDebug(methodName, 'Delete Header-Event, Query to execute: ' + avQuery.toQueryString());
        List<AV_HeaderCustomActivity__c> listHeaderEvent = avQuery.run();*/
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
        return listUserIds;
	}

    /**
	 * List pass to String format ('Ejemplo','Prueba')
	 */
    public static String listToStringIn(List<String> setUserIds) {
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
        return listUserIds;
	}

     /**
	 * Array pass to String format ('Ejemplo','Prueba')
	 */
    public static String arrayToStringIn(String[] setUserIds) {
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
        return listUserIds;
	}

    /**
     * Retrieve the Salesforce application where the user is
     */
    public static String getCurrentSFApplication() {
        UserAppInfo userAppInfo;
        AppDefinition appDefinition;
        if(Schema.sObjectType.UserAppInfo.isAccessible() && Schema.sObjectType.AppDefinition.isAccessible()){
            userAppInfo = [SELECT Id, AppDefinitionId FROM UserAppInfo WHERE UserId = :UserInfo.getUserId() LIMIT 1];
            appDefinition = [SELECT DurableId, Label, DeveloperName FROM AppDefinition Where DurableId = :userAppInfo.AppDefinitionId LIMIT 1];
        }
        return appDefinition.DeveloperName;
    }

}