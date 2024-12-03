/**********************************************************************************************************************
Name:	  AV_DetailOpp_Controller
Copyright © 2019  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Clase controladora del componente "av_DetailOpp"
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
VERSION		USER_STORY								AUTHOR			   DATE			Description
1.0			Oportunidades vinculadas con las tareas	Álvaro López	   09/10/2020	Init version
1.1			Oportunidades vinculadas a un evento	Álvaro López	   11/11/2020	Error management and deleteOpp method
1.2			Oportunidades vinculadas a un evento	Álvaro López	   18/11/2020	Remove deleteOpp method
1.3		    AV_Query IT	        					Daniel Rodríguez   03/03/2022	Change AV_Query to SOQL for User, Account, Contact
1.4		    US385253	    						Víctor Santiago    16/06/2022	Added wrapper with activitydate and status

***********************************************************************************************************************/
public with sharing class AV_DetailOpp_Controller {

	@AuraEnabled
	public static String linkOpp(String recordInfo, Opportunity opp){
		//Busca la cabecera tarea de la opp
		if(String.isNotBlank(recordInfo)) {
			List<AV_CustomActivityOpportunity__c> listOppTask;
			//Creo la tarea opp
			Id rt = Schema.SObjectType.AV_CustomActivityOpportunity__c.getRecordTypeInfosByDeveloperName().get(AV_AppConstants.OPPTASK_RT).getRecordTypeId();
			AV_CustomActivityOpportunity__c taskOpp = new AV_CustomActivityOpportunity__c();
			taskOpp.AV_Opportunity__c = opp.Id;
			taskOpp.RecordTypeId = rt;
			if (recordInfo.length() > 18) {
				AV_ListOpportunities_Controller.RecordInfo wrapper = (AV_ListOpportunities_Controller.RecordInfo)JSON.deserialize(recordInfo, AV_ListOpportunities_Controller.RecordInfo.class);
				taskOpp.AV_Task__c = wrapper.taskHeader;
				taskOpp.AV_ActivityDate__c = wrapper.activityDate;
				taskOpp.AV_Status__c = wrapper.status;
				listOppTask = [Select Id from AV_CustomActivityOpportunity__c where AV_Task__c =: wrapper.taskHeader];
			} else {
				taskOpp.AV_Task__c = recordInfo;
				listOppTask = [Select Id from AV_CustomActivityOpportunity__c where AV_Task__c =: recordInfo];
			}
			if(listOppTask.isEmpty()) {
			    taskopp.AV_IsMain__c = true;
			}

			Database.SaveResult sr = Database.insert(taskOpp, false);
			if(!sr.isSuccess()) {
				// Operation failed, so get all errors		    
				for(Database.Error err : sr.getErrors()) {
					AV_LogDebug.printLogDebug('linkOpp', 'Error: ' + err.getStatusCode() + ' - ' + err.getMessage() + '. ' + 'Fields that affected this error: ' + err.getFields());
				}
				return 'KO';
			}
			return 'OK';
		} else {
			return 'KO';
		}
	}
}