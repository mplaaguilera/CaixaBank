/**********************************************************************************************************************
 Name:	  AV_CustomActivityOppTriggerHelper
 Copyright © 2020  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Clase auxiliar de los Triggers de AV_CustomActivityOpportunity__c.
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
	VERSION		USER_STORY	                            AUTHOR		   		DATE		Description
	1.0			Oportunidades vinculadas a una tarea    Álvaro López	   	13/10/2020	Init version
	1.1			Oportunidades vinculadas a una tarea    Esperanza Conde	   	13/10/2020	Init version
	2.0         Check RT			                    Jashanpreet			09/12/2020	Improve common method to check RT + general RT
	2.1         HOTFIX			                    	Sandra Gómez		22/10/2021	Change method setFieldsToOpp
	2.2         US286825 			                    Daniel Rodríguez	10/01/2022	Add method updateNextManagementDateOpp
	2.3			US286825 								Daniel Rodríguez	13/01/2022	Add Method updateNextManagementDateOpp for unification of expiration dates of opportunities with date of event or task
	2.4			US325412 								Víctor Santiago		09/03/2022	Added AV_OrigenApp__c in setFieldsToOpp
	2.5			Fix-bucle								Sandra Gómez		08/04/2022	Change method updateNextManagementDateOpp queries in for
	2.6			US365180								Víctor Santiago		14/04/2022	Added condition: if task created by checkonoff dont update opp in updateNextManagementDateOpp
	2.7			US336957								Luis Fernández		01/09/2022  Modified setFieldsFromOpp and setFieldsAndOpp.Query retrieved and informed AV_Resolucion field in both.
	2.8			US481618								Elisabeth Rodríguez	18/01/2023  Add method fillChannelField()
    2.9			US481572								Patricia Solano 	25/01/2023  Modified methods setFieldsFromOpp y setFieldsToOpp to add new fields 
	3.0			Fix										Sandra Gómez		20/07/2023	Change method fillChannelField for add method updateChannelFieldOpp to opp asinc and delete hardcodes in all code
	3.1			DE75778									Sandra Gómez		23/08/2023	Change method setFieldsFromOpp to go through the list of Task-Oppotunity
	3.2			Fix PMD Errors							Daniel Rodriguez	30/10/2023	Modify method updateNextManagementDateOpp, remove getRTId and add queries WITH SECURITY_ENFORCED
	3.3			Fix										Sandra Gómez 		13/11/2023	Change method updateNextManagementDateOpp bypass
	3.4			Fix										Sandra Gómez 		16/11/2023	Change method updateChannelFieldOpp duplicity correction
	3.5			DE76222									Humberto Vilchez	27/12/2023	Change method setFieldsToOpp to fix UNABLE_TO_LOCK_ROW error
	3.6			DE76223									Humberto Vilchez	08/01/2024	Change method updateNextManagementDateOpp to fix UNABLE_TO_LOCK_ROW error
	3.7                                                 Oscar Moreno        18/01/2024  Comments setFieldsFromOpp,setFieldsToOpp, updateNextManagementDateOpp, fillChannelField,updateChannelFieldOpp, checkGeneralRT,getAllRT,getIdsRT methods
    3.8                                                 Oscar Moreno        23/01/2024  Add getCustomActivityOpp to pass the coverage of the test
	3.9       US839366                                  Luis Fernández      18/03/2024  Added   updateOpportunityNextEventDateField method to update opportunities field AV_NextEventDate__c when associations with events are done or undone      
	4.0		  Fix 										Sandra Gómez		18/04/2024	Change method updateOpportunityNextEventDateField add filter date
	4.1		  DT09									    Luis Fernández		25/04/2024  Added RecordType filters to all querys
	4.2		  Fix 										Sandra Gómez		20/05/2024	Change method updateOpportunityNextEventDateField to control of nulls
***********************************************************************************************************************/
public with sharing class AV_CustomActivityOppTriggerHelper {
	/**
	 * Update the the av_nextEvent__c opportunity field to the recent Event when an opportunity is vinculed to an event
	 * @param listNews
	 */
	public static void updateOpportunityNextEventDateField(List<AV_CustomActivityOpportunity__c> listNews){
		String methodName = 'updateOpportunityNextEventDateField';
		if(!listNews.isEmpty()){
			List<Opportunity> opposObjToUpdate = new List<Opportunity>();
			Set<String> unOrderedOppoList = new Set<String>();
			for(AV_CustomActivityOpportunity__c cao : listNews){
				if(cao.AV_Opportunity__c != null){
					unOrderedOppoList.add(cao.AV_Opportunity__c);
				}
			}
			Set<String> opposRetalRt = new Set<String>{AV_AppConstants.OPPINICIATIVA_RT,AV_AppConstants.OPPALERTACOM_RT,AV_AppConstants.OPPPROPUESTA_RT,AV_AppConstants.OPPSUGERENCIA_RT,AV_AppConstants.OPPLLAMADA_RT};
			Set<String> evtRetailRt = new Set<String>{AV_AppConstants.EVENTCLIENTE_RT,AV_AppConstants.EVENTGESTOR_RT};
			List<AV_CustomActivityOpportunity__c> caosRelatedToOppos = [SELECT AV_Task__c, AV_Opportunity__c,AV_Opportunity__r.AV_NextEventDate__c FROM AV_CustomActivityOpportunity__c WHERE AV_Opportunity__c IN :unOrderedOppoList AND AV_Task__c != null AND RecordType.DeveloperName = :AV_AppConstants.OPPTASK_RT AND AV_Opportunity__r.RecordType.DeveloperName IN :opposRetalRt];
			Set<String> unOrderedHeaderList = new Set<String>();
			Map<String,List<String>> opposToHisTaskId = new Map<String,List<String>>();
			Map<String,Date> opposToHisDate = new Map<String,Date>();
			if (caosRelatedToOppos != null && !caosRelatedToOppos.isEmpty()) {
			for(AV_CustomActivityOpportunity__c cao1 : caosRelatedToOppos){
					if(!opposToHisDate.containsKey(cao1.AV_Opportunity__c)){
						opposToHisDate.put(cao1.AV_Opportunity__c,cao1.AV_Opportunity__r.AV_NextEventDate__c);
					}
				unOrderedHeaderList.add(cao1.AV_Task__c);
				if(opposToHisTaskId.containsKey(cao1.AV_Opportunity__c)){
					opposToHisTaskId.get(cao1.AV_Opportunity__c).add(cao1.AV_Task__c);
				}else{
					opposToHisTaskId.put(cao1.AV_Opportunity__c,new List<String>{cao1.AV_Task__c});
				}
			}
			List<Event> eventRelated = [SELECT ActivityDate,AV_Task__c FROM Event WHERE AV_Task__c IN :unOrderedHeaderList AND CSBD_Evento_Estado__c = :AV_AppConstants.EVENT_STATUS_PENDIENTE AND ActivityDate >= TODAY AND RecordType.DeveloperName IN :evtRetailRt ORDER BY ActivityDate ASC];
			if(!eventRelated.isEmpty()){
				for(String oppId : opposToHisTaskId.keySet()){
					List<String> tasksOfTheOpp = opposToHisTaskId.get(oppId);
					Boolean endBybreak = false;
					for(Event evt : eventRelated){
						if(tasksOfTheOpp.contains(evt.AV_Task__c)){
							opposObjToUpdate.add(new Opportunity(Id = oppId,AV_NextEventDate__c = evt.ActivityDate));
							endBybreak = true;
							break;
						}
					}
					if(!endBybreak){
						opposObjToUpdate.add(new Opportunity(Id = oppId,AV_NextEventDate__c = null));
					}
				}
			}else{
				for(String oppId : unOrderedOppoList){
					opposObjToUpdate.add(new Opportunity(Id = oppId,AV_NextEventDate__c = null));
				}
			}
				if (opposObjToUpdate != null && !opposObjToUpdate.isEmpty()) {
					List<Database.SaveResult> srList = Database.update(opposObjToUpdate,false);
			for(Database.SaveResult sr : srList){
				if(!sr.isSuccess()){
					for(Database.Error err : sr.getErrors()){
						AV_LogDebug.printLogError(methodName, err.getMessage());
					}
				}
			}
				}
			}
		}
	}
}