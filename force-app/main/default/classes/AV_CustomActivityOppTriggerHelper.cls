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
	3.2			Fix										Sandra Gómez 		13/11/2023	Change method updateNextManagementDateOpp bypass
***********************************************************************************************************************/
public with sharing class AV_CustomActivityOppTriggerHelper {

	private static final String CABECERATAREA = 'AV_CabeceraTarea';

	/**
	 * @description		 	Check the record types
	 * @param listNews  	list of new records
	 */
	public static List<AV_CustomActivityOpportunity__c> checkGeneralRT(List<AV_CustomActivityOpportunity__c> listNews){
		Set<Id> setIdsRt = getAllRT();
		List<AV_CustomActivityOpportunity__c> listData = new List<AV_CustomActivityOpportunity__c>();
		for(AV_CustomActivityOpportunity__c dataNew : listNews){
			if((setIdsRt).contains(dataNew.RecordTypeId)){
				listData.add(dataNew);
			}
		}
		return listData;
	}
	
	/**
	 * @description		 	Get all the ID's of the RT
	 */
	public static Set<Id> getAllRT(){
		Schema.DescribeSObjectResult objDescribe = AV_CustomActivityOpportunity__c.SObjectType.getDescribe();
		List<Schema.RecordTypeInfo> recordTypeObj = objDescribe.getRecordTypeInfos();
		Set<Id> setIdsRt = New Set<Id>();
		
		for (Schema.RecordTypeInfo rt: recordTypeObj){
			if (rt.getDeveloperName().left(3)=='AV_') {
				setIdsRt.add(rt.getRecordTypeId());
			}
		}
		return setIdsRt;
	}
	
	/**
	 * @description		 	Get the ID's of the RT's requested by param
	 * @param setRT			List of the RT
	 */
	public static Set<Id> getIdsRT(Set<String> setRT){
		return AV_AppUtilities.getRecordTypeIdsInSet(setRT);
	}

	/**
	* @description		 	Update fields Task-Opportunity with value Opportunity
	* @param  listNews  	list of new Task-Opportunity records
	*/
	public static void setFieldsFromOpp(List<AV_CustomActivityOpportunity__c> listNews) {
		Set<Id> setIdsRt = getAllRT();
		Map<String, AV_CustomActivityOpportunity__c> mapOppTask = new Map<String, AV_CustomActivityOpportunity__c>();
		List<String> listIpOpp = new List<String>();
		List<AV_CustomActivityOpportunity__c> listTaskOpp = new List<AV_CustomActivityOpportunity__c>();
		Map<String, Opportunity> mapOpp = new Map<String, Opportunity>();
		for(AV_CustomActivityOpportunity__c oppTask : listNews) {
			if((setIdsRt).contains(oppTask.RecordTypeId) && oppTask.AV_Opportunity__c != null) {
				mapOppTask.put(oppTask.AV_Opportunity__c, oppTask);
				listIpOpp.add(oppTask.AV_Opportunity__c);
				listTaskOpp.add(oppTask);
			}
		}
		if(listIpOpp != null && listTaskOpp != null && !listIpOpp.isEmpty() && !listTaskOpp.isEmpty()) {
			List<Opportunity> listOpp = [Select Id, Name, AV_PF__c, AV_Gestor__c, RecordTypeId, RecordType.Name, AV_Potencial__c, AV_FechaProximoRecordatorio__c, StageName, AV_Valor1__c, AV_Concepto1__c, AV_Valor2__c, AV_Concepto2__c, AV_Valor3__c, AV_Concepto3__c, AV_Valor4__c, AV_Concepto4__c, AV_Valor5__c, AV_Concepto5__c, AV_Tenencia__c, AV_Entidad__c, CloseDate, AV_Cuota__c, Amount, AV_TipoInteres__c, AV_Comentarios__c,AV_FechaVencimiento__c,AV_LicensePlate__c,AV_IncludeInPrioritizingCustomers__c,AV_Resolucion__c, AV_ByProduct__c, AV_AmountEuro__c, AV_MarginEuro__c FROM Opportunity Where id in :listIpOpp];
			if (listOpp != null && !listOpp.isEmpty()) {
			for(Opportunity opp : listOpp) {
					mapOpp.put(opp.Id,opp);
				}
			}
			for(AV_CustomActivityOpportunity__c oppTask : listTaskOpp) {
				if(mapOpp.containsKey(oppTask.AV_Opportunity__c)) {
					oppTask.Name = mapOpp.get(oppTask.AV_Opportunity__c).Name;
					oppTask.AV_Product__c = mapOpp.get(oppTask.AV_Opportunity__c).AV_PF__c;
					oppTask.AV_Gestor__c = mapOpp.get(oppTask.AV_Opportunity__c).AV_Gestor__c;
					oppTask.AV_Priority__c = mapOpp.get(oppTask.AV_Opportunity__c).AV_Potencial__c;
					oppTask.AV_ReviewDate__c = mapOpp.get(oppTask.AV_Opportunity__c).AV_FechaProximoRecordatorio__c;
					oppTask.AV_Stage__c = mapOpp.get(oppTask.AV_Opportunity__c).StageName;
					oppTask.AV_Valor1__c = mapOpp.get(oppTask.AV_Opportunity__c).AV_Valor1__c;
					oppTask.AV_Concepto1__c = mapOpp.get(oppTask.AV_Opportunity__c).AV_Concepto1__c;
					oppTask.AV_Valor2__c = mapOpp.get(oppTask.AV_Opportunity__c).AV_Valor2__c;
					oppTask.AV_Concepto2__c = mapOpp.get(oppTask.AV_Opportunity__c).AV_Concepto2__c;
					oppTask.AV_Valor3__c = mapOpp.get(oppTask.AV_Opportunity__c).AV_Valor3__c;
					oppTask.AV_Concepto3__c = mapOpp.get(oppTask.AV_Opportunity__c).AV_Concepto3__c;
					oppTask.AV_Valor4__c = mapOpp.get(oppTask.AV_Opportunity__c).AV_Valor4__c;
					oppTask.AV_Concepto4__c = mapOpp.get(oppTask.AV_Opportunity__c).AV_Concepto4__c;
					oppTask.AV_Valor5__c = mapOpp.get(oppTask.AV_Opportunity__c).AV_Valor5__c;
					oppTask.AV_Concepto5__c = mapOpp.get(oppTask.AV_Opportunity__c).AV_Concepto5__c;
					oppTask.AV_HoldingAnotherEntity__c = mapOpp.get(oppTask.AV_Opportunity__c).AV_Tenencia__c;
					oppTask.AV_Entity__c = mapOpp.get(oppTask.AV_Opportunity__c).AV_Entidad__c;
					oppTask.AV_DueDate__c = mapOpp.get(oppTask.AV_Opportunity__c).CloseDate;
					oppTask.AV_FechaVencimiento__c = mapOpp.get(oppTask.AV_Opportunity__c).AV_FechaVencimiento__c;
					oppTask.AV_FeeAmount__c = mapOpp.get(oppTask.AV_Opportunity__c).AV_Cuota__c;
					oppTask.AV_Amount__c = mapOpp.get(oppTask.AV_Opportunity__c).Amount;
					oppTask.AV_TypeOfInterest__c = mapOpp.get(oppTask.AV_Opportunity__c).AV_TipoInteres__c;
					oppTask.AV_Commentary__c = mapOpp.get(oppTask.AV_Opportunity__c).AV_Comentarios__c;
					oppTask.AV_LicensePlate__c = mapOpp.get(oppTask.AV_Opportunity__c).AV_LicensePlate__c;
					oppTask.AV_IncludeInPrioritizingCustomers__c = mapOpp.get(oppTask.AV_Opportunity__c).AV_IncludeInPrioritizingCustomers__c;
					oppTask.AV_Resolucion__c = mapOpp.get(oppTask.AV_Opportunity__c).AV_Resolucion__c;
					oppTask.AV_ByProduct__c = mapOpp.get(oppTask.AV_Opportunity__c).AV_ByProduct__c;
					oppTask.AV_MarginEuro__c = mapOpp.get(oppTask.AV_Opportunity__c).AV_MarginEuro__c;
					oppTask.AV_AmountEuro__c = mapOpp.get(oppTask.AV_Opportunity__c).AV_AmountEuro__c;
				}
			}
		}
	}

	/**
	* @description		 			   Update fields Opportunity with value Task-Opportunity
	* @param  listNews  			   list of new Task-Opportunity records
	* @param  mapOldCustomActivityOpp  map of old Task-Opportunity records
	*/
	public static void setFieldsToOpp(List<AV_CustomActivityOpportunity__c> listNews, Map<Id, AV_CustomActivityOpportunity__c> mapOldCustomActivityOpp) {
		Set<Id> setIdsRt = getAllRT();
		Map<String, AV_CustomActivityOpportunity__c> mapOppTask = new Map<String, AV_CustomActivityOpportunity__c>();
		List<Opportunity> listOppToUpdate = new List<Opportunity>();

		for(AV_CustomActivityOpportunity__c oppTask : listNews) {
			if((setIdsRt).contains(oppTask.RecordTypeId) && oppTask.AV_Opportunity__c != null 
			&& (oppTask.Name != mapOldCustomActivityOpp.get(oppTask.id).Name ||
				oppTask.AV_Gestor__c != mapOldCustomActivityOpp.get(oppTask.id).AV_Gestor__c ||
				oppTask.AV_Priority__c != mapOldCustomActivityOpp.get(oppTask.id).AV_Priority__c ||
				oppTask.AV_ReviewDate__c != mapOldCustomActivityOpp.get(oppTask.id).AV_ReviewDate__c ||
				oppTask.AV_Stage__c != mapOldCustomActivityOpp.get(oppTask.id).AV_Stage__c ||
				oppTask.AV_HoldingAnotherEntity__c != mapOldCustomActivityOpp.get(oppTask.id).AV_HoldingAnotherEntity__c ||
				oppTask.AV_Entity__c != mapOldCustomActivityOpp.get(oppTask.id).AV_Entity__c ||
				oppTask.AV_DueDate__c != mapOldCustomActivityOpp.get(oppTask.id).AV_DueDate__c ||
				oppTask.AV_FechaVencimiento__c != mapOldCustomActivityOpp.get(oppTask.id).AV_FechaVencimiento__c ||
				oppTask.AV_FeeAmount__c != mapOldCustomActivityOpp.get(oppTask.id).AV_FeeAmount__c ||
				oppTask.AV_Amount__c != mapOldCustomActivityOpp.get(oppTask.id).AV_Amount__c ||
				oppTask.AV_TypeOfInterest__c != mapOldCustomActivityOpp.get(oppTask.id).AV_TypeOfInterest__c ||
				oppTask.AV_Commentary__c != mapOldCustomActivityOpp.get(oppTask.id).AV_Commentary__c ||
				oppTask.AV_IncludeInPrioritizingCustomers__c != mapOldCustomActivityOpp.get(oppTask.id).AV_IncludeInPrioritizingCustomers__c ||
				oppTask.AV_LicensePlate__c != mapOldCustomActivityOpp.get(oppTask.id).AV_LicensePlate__c ||
				oppTask.AV_OrigenApp__c != mapOldCustomActivityOpp.get(oppTask.id).AV_OrigenApp__c ||
				oppTask.AV_Channel__c != mapOldCustomActivityOpp.get(oppTask.id).AV_Channel__c ||
				oppTask.AV_ByProduct__c != mapOldCustomActivityOpp.get(oppTask.id).AV_ByProduct__c || 
				oppTask.AV_MarginEuro__c != mapOldCustomActivityOpp.get(oppTask.id).AV_MarginEuro__c ||
				oppTask.AV_AmountEuro__c != mapOldCustomActivityOpp.get(oppTask.id).AV_AmountEuro__c 
				)){
				mapOppTask.put(oppTask.AV_Opportunity__c, oppTask);
			}
		} 
		if(!mapOppTask.values().isEmpty()) {
			List<Opportunity> listOpp = [Select Id, Name, AV_PF__c, AV_Gestor__c, RecordTypeId, RecordType.Name, AV_Potencial__c, AV_FechaProximoRecordatorio__c, StageName, AV_Valor1__c, AV_Concepto1__c, AV_Valor2__c, AV_Concepto2__c, AV_Valor3__c, AV_Concepto3__c, AV_Valor4__c, AV_Concepto4__c, AV_Valor5__c, AV_Concepto5__c, AV_Tenencia__c, AV_Entidad__c, CloseDate, AV_Cuota__c, Amount, AV_TipoInteres__c, AV_Comentarios__c, AV_FechaVencimiento__c, AV_OrigenApp__c, AV_Channel__c,AV_IncludeInPrioritizingCustomers__c,AV_Resolucion__c, AV_ByProduct__c, AV_AmountEuro__c, AV_MarginEuro__c FROM Opportunity Where id in :mapOppTask.keySet()];
			for(Opportunity opp : listOpp) {
				if(mapOppTask.containsKey(opp.Id)) {
					opp.Name = mapOppTask.get(opp.Id).Name;
					opp.AV_Gestor__c = mapOppTask.get(opp.Id).AV_Gestor__c;
					opp.AV_Potencial__c = mapOppTask.get(opp.Id).AV_Priority__c;
					opp.AV_FechaProximoRecordatorio__c = mapOppTask.get(opp.Id).AV_ReviewDate__c;
					opp.StageName = mapOppTask.get(opp.Id).AV_Stage__c; 
					opp.AV_Tenencia__c = mapOppTask.get(opp.Id).AV_HoldingAnotherEntity__c;
					opp.AV_Entidad__c = mapOppTask.get(opp.Id).AV_Entity__c;
					opp.AV_FechaVencimiento__c = mapOppTask.get(opp.Id).AV_FechaVencimiento__c;
					opp.CloseDate = mapOppTask.get(opp.Id).AV_DueDate__c;
					opp.AV_Cuota__c = mapOppTask.get(opp.Id).AV_FeeAmount__c;
					opp.Amount = mapOppTask.get(opp.Id).AV_Amount__c;
					opp.AV_TipoInteres__c = mapOppTask.get(opp.Id).AV_TypeOfInterest__c;
					opp.AV_Comentarios__c = mapOppTask.get(opp.Id).AV_Commentary__c;
					opp.AV_Resolucion__c = mapOppTask.get(opp.Id).AV_Resolucion__c;
					opp.AV_Channel__c = mapOppTask.get(opp.Id).AV_Channel__c;
					opp.AV_ByProduct__c = mapOppTask.get(opp.Id).AV_ByProduct__c;
					opp.AV_MarginEuro__c = mapOppTask.get(opp.Id).AV_MarginEuro__c;
					opp.AV_AmountEuro__c = mapOppTask.get(opp.Id).AV_AmountEuro__c;
					if(opp.AV_IncludeInPrioritizingCustomers__c != mapOppTask.get(opp.Id).AV_IncludeInPrioritizingCustomers__c){
						opp.AV_IncludeInPrioritizingCustomers__c = mapOppTask.get(opp.Id).AV_IncludeInPrioritizingCustomers__c;
					}
					opp.AV_LicensePlate__c = mapOppTask.get(opp.Id).AV_LicensePlate__c;
					opp.AV_OrigenApp__c = mapOppTask.get(opp.Id).AV_OrigenApp__c;
					if(mapOppTask.get(opp.Id).AV_Stage__c!= null && mapOppTask.get(opp.Id).AV_Stage__c!= 'Vencido'){
						opp.AV_FechaActivacion__c = System.today();
					}
					listOppToUpdate.add(opp);
				}
			}
		}
		if(!listOppToUpdate.isEmpty()){
			Database.update(listOppToUpdate);
		}
	}

	/**
	* @description		 Update updateNextManagementDateOpp of opportunity
	* @param  listNews  list of new Task records
	*/
	public static void updateNextManagementDateOpp(List<AV_CustomActivityOpportunity__c> listNews){
		String methodName = 'updateNextManagementDateOpp';
		Set<String> setLabelsRtsTask = new Set<String>{AV_AppConstants.TASKINICIATIVA_RT};
		Set<String> setLabelsRtsEvent = new Set<String>{AV_AppConstants.EVENTCLIENTE_RT};
		Set<Id> setIdsRtsTask = getIdsRT(setLabelsRtsTask);
		Set<Id> setIdsRtsEvent = getIdsRT(setLabelsRtsEvent);
		Set<Id> setOpp = new Set<Id>();
		Map<Id,List<String>> mapOppTask = new Map<Id,List<String>>();
		Map<String,List<String>> mapTaskOpp = new Map<String,List<String>>();
		Map<Id,Date> mapOppFieldHist = new Map<Id,Date>();
		List<Opportunity> listOppUpdate = new List<Opportunity>();
		List<OpportunityFieldHistory> listOldValueOpp = new List<OpportunityFieldHistory>();
		List<String> listOrigenOpp = new List<String>();
		List<String> ids= new List<String>();
		Date dateOppNew = null;
		for(AV_CustomActivityOpportunity__c cAopp : listNews){
			if(cAopp?.AV_Opportunity__c != null  && cAopp.AV_Opportunity__r.AV_OrigenApp__c != AV_AppConstants.CLIENT_REPORT_ORIGENAPP){
				setOpp.add(cAopp.AV_Opportunity__c);
			}
		}
		if(setOpp !=null && !setOpp.isEmpty()){ 
			List<AV_CustomActivityOpportunity__c> listTaskAndOppRelated = [Select Id, AV_Task__r.AV_ExternalID__c, AV_Opportunity__c, AV_OrigenApp__c from AV_CustomActivityOpportunity__c where AV_Opportunity__c in :setOpp];
			for (Integer i = listTaskAndOppRelated.size()-1; i >= 0; i--) {
				if (String.isNotBlank(listTaskAndOppRelated.get(i).AV_Task__r.AV_ExternalID__c) && ((String) listTaskAndOppRelated.get(i).AV_Task__r.AV_ExternalID__c).startsWith('Opp-006')) {
					listTaskAndOppRelated.remove(listTaskAndOppRelated.indexOf(listTaskAndOppRelated.get(i)));
				}
			}
			if(listTaskAndOppRelated.isEmpty()){
				listOldValueOpp = [Select Id, oldValue, OpportunityId from OpportunityFieldHistory where OpportunityId in :setOpp and Field = 'AV_FechaProximoRecordatorio__c' order by CreatedDate DESC];
				if (!listOldValueOpp.isEmpty()) {
					for(OpportunityFieldHistory oppHist : listOldValueOpp){
						if(!mapOppFieldHist.containsKey(oppHist.OpportunityId) && oppHist.oldValue != null) {
							mapOppFieldHist.put(oppHist.OpportunityId, date.valueof(oppHist.oldValue));
						}
					}
				}
				if (mapOppFieldHist!=null) {
					for(Id oppHist : mapOppFieldHist.keySet()){
						Opportunity oppUpdate = new Opportunity(Id= oppHist, AV_FechaProximoRecordatorio__c = mapOppFieldHist.get(oppHist));
						listOppUpdate.add(oppUpdate);
					}
				}
			}else{ 
				for(AV_CustomActivityOpportunity__c taskOppRelated : listTaskAndOppRelated){
					if(mapOppTask.containsKey(taskOppRelated.AV_Opportunity__c)) {
						mapOppTask.get(taskOppRelated.AV_Opportunity__c).add(taskOppRelated.AV_Task__r.AV_ExternalID__c);
					} else {
						mapOppTask.put(taskOppRelated.AV_Opportunity__c, new List<String> { taskOppRelated.AV_Task__r.AV_ExternalID__c });
					}
					if(mapTaskOpp.containsKey(taskOppRelated.AV_Task__r.AV_ExternalID__c)) {
						mapTaskOpp.get(taskOppRelated.AV_Task__r.AV_ExternalID__c).add(taskOppRelated.AV_Opportunity__c);
					} else {
						mapTaskOpp.put(taskOppRelated.AV_Task__r.AV_ExternalID__c, new List<String> {taskOppRelated.AV_Opportunity__c});
					}
					ids.add(taskOppRelated.AV_Task__r.AV_ExternalID__c);
					if(taskOppRelated.AV_OrigenApp__c == AV_AppConstants.CLIENT_REPORT_ORIGENAPP || taskOppRelated.AV_OrigenApp__c == AV_AppConstants.OPP_ORIGEN_BACK_REPORT) {
						listOrigenOpp.add(taskOppRelated.AV_Opportunity__c);
					}
				}
			}
		}  
		if(!mapOppTask.isEmpty()){ 
			Set<String> statusTask = new Set<String>{AV_AppConstants.TASK_STATUS_PENDIENTE, AV_AppConstants.TASK_STATUS_PENDIENTE_NO_LOCAL};
			Set<String> statusEvent = new Set<String>{AV_AppConstants.EVENT_STATUS_PENDIENTE};
			Map<String,Date> mapOppFecha = new Map<String,Date>();
			List<Task> listTaskAndOppRelated = [Select Id, AV_ExternalID__c, ActivityDate from Task where Status in :statusTask and RecordtypeId in :setIdsRtsTask and AV_ExternalID__c in :ids and ActivityDate >= TODAY order by ActivityDate ASC];
			AV_LogDebug.printLogDebug(methodName, 'listTaskAndOppRelated: '+listTaskAndOppRelated.size());
			for(Task ta:listTaskAndOppRelated) {
				if (mapTaskOpp.get(ta.AV_ExternalID__c)!=null) {
					for(String oppId:mapTaskOpp.get(ta.AV_ExternalID__c)) {
						if (mapOppFecha.get(oppId) == null){
							mapOppFecha.put(oppId,ta.ActivityDate);
						}else if (mapOppFecha.get(oppId) > ta.ActivityDate) {
							mapOppFecha.put(oppId,ta.ActivityDate);
						}
					}
				}
			}
			List<Event> listEventAndOppRelated = [Select Id, AV_ExternalID__c, ActivityDate from Event where CSBD_Evento_Estado__c in :statusEvent and RecordtypeId in :setIdsRtsEvent and AV_ExternalID__c in :ids and ActivityDate >= TODAY order by ActivityDate ASC limit 1];
			AV_LogDebug.printLogDebug(methodName, 'listEventAndOppRelated: '+listEventAndOppRelated.size());
			for(Event e:listEventAndOppRelated) {
				if (mapTaskOpp.get(e.AV_ExternalID__c)!=null) {
					for(String oppId:mapTaskOpp.get(e.AV_ExternalID__c)) {
						if (mapOppFecha.get(oppId) == null) {
							mapOppFecha.put(oppId,e.ActivityDate);
						}else if (mapOppFecha.get(oppId) > e.ActivityDate) {
							mapOppFecha.put(oppId,e.ActivityDate);
						}
					}
				}
			}
			if(mapOppFecha != null) {
				for (Id idOpp : mapOppTask.keySet()){
					if (mapOppFecha.get(idOpp) != null) {
						Opportunity oppUpdate;
						if(listOrigenOpp.contains(idOpp)) {
							oppUpdate = new Opportunity(Id= idOpp, AV_FechaProximoRecordatorio__c = mapOppFecha.get(idOpp), AV_OrigenApp__c = AV_AppConstants.CLIENT_REPORT_ORIGENAPP);
						} else {
							oppUpdate = new Opportunity(Id= idOpp, AV_FechaProximoRecordatorio__c = mapOppFecha.get(idOpp));
						}
						listOppUpdate.add(oppUpdate);
					}	
				}
			}
		}
		if(!listOppUpdate.isEmpty()){
			AV_LogDebug.printLogDebug(methodName, 'Oportunidades: ' + listOppUpdate.size());
			List<Database.SaveResult> listUpdateResult=database.update(listOppUpdate);
			AV_AppUtilities.displayErrors(methodName,listUpdateResult);
		}
	}

	/**
	* @description		 Update Channel field of opportunity and task-opportunity
	* @param  taskOppList  list of new Task-Opportunity records
	*/
	public static void fillChannelField(List<AV_CustomActivityOpportunity__c> taskOppList){
		List<String> headerTaskIdList = new List<String>();
		List<AV_CustomActivityOpportunity__c> listTaskOpp = new List<AV_CustomActivityOpportunity__c>();
		for(AV_CustomActivityOpportunity__c to : taskOppList){ 
			if(to.AV_Task__c != null && to.AV_Opportunity__c != null){
				headerTaskIdList.add(to.AV_Task__c);
				listTaskOpp.add(to);
			} 
		}
		if(headerTaskIdList != null && !headerTaskIdList.isEmpty()){
			updateChannelFieldOpp(System.JSON.serialize(headerTaskIdList),System.JSON.serialize(listTaskOpp));
		}
	}

	/**
	* @description		 Update Channel field of opportunity
	* @param  listOppJson  String with list of Opportunity records
	*/
	@Future
	public static void updateChannelFieldOpp(String headerTaskIdListJson, String taskOppListJson) {
		List<String> headerTaskIdList = (List<String>)Json.deserialize(headerTaskIdListJson,List<String>.class);
		List<AV_CustomActivityOpportunity__c> taskOppList = (List<AV_CustomActivityOpportunity__c>)Json.deserialize(taskOppListJson,List<AV_CustomActivityOpportunity__c>.class);
		List<AV_CustomActivityOpportunity__c> listTaskOppUpdate = new List<AV_CustomActivityOpportunity__c>();
			List<Task> taskList = [SELECT Id, AV_Tipo__c, AV_Task__c FROM Task WHERE AV_Task__c IN: headerTaskIdList AND RecordType.DeveloperName LIKE : AV_AppConstants.AV_PREFIX];
			List<Event> eventList = [SELECT Id, AV_Tipo__c, AV_Task__c FROM Event WHERE AV_Task__c IN: headerTaskIdList AND RecordType.DeveloperName =: AV_AppConstants.EVENTCLIENTE_RT];
			Map<String, String> idTypeMap = new Map<String, String>();
			if(taskList != null && !taskList.isEmpty()){
				for(Task t : taskList){
					idTypeMap.put(t.AV_Task__c, t.AV_Tipo__c);
				}
			}
			if(eventList != null && !eventList.isEmpty()){
				for(Event e : eventList){
					idTypeMap.put(e.AV_Task__c, e.AV_Tipo__c);
				}
			}
			List<Opportunity> oppToUpdate = new List<Opportunity>();
			if(idTypeMap != null && !idTypeMap.isEmpty()){
				for(AV_CustomActivityOpportunity__c ao : taskOppList){
					if(idTypeMap.get(ao.AV_Task__c) != null){
						ao.AV_Channel__c = idTypeMap.get(ao.AV_Task__c);
					listTaskOppUpdate.add(ao);
						Opportunity opp = new Opportunity();
						opp.Id = ao.AV_Opportunity__c;
						opp.AV_Channel__c = ao.AV_Channel__c;
						oppToUpdate.add(opp);
					}
				}
			if (listTaskOppUpdate != null && !listTaskOppUpdate.isEmpty()) {
				Database.update(listTaskOppUpdate,false);
			}
				if(oppToUpdate != null && !oppToUpdate.isEmpty()){
				Database.update(oppToUpdate,false);
			}
		}
	}

}