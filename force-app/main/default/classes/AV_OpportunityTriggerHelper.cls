/**********************************************************************************************************************
Name:    AV_OpportunityTriggerHelper
Copyright © 2020  CaixaBank
------------------------------------------------------------------------------------------------
Proposito: Clase auxiliar de los Triggers de Opportunity.
------------------------------------------------------------------------------------------------
Historial
------------------------------------------------------------------------------------------------
VERSION  USER_STORY   AUTHOR        	 DATE        	 Description
1.0      App FSC      Carolina Alonso    02/06/2020      Init version
2.0      App FSC      Carolina Alonso    01/07/2020      Add logic for Opportunities AV_Iniciativa
2.1      App FSC      Carolina Alonso    08/09/2020      Delete soql queries to get RecordTypeIds
3.0      App FSC      Esperanza Conde    21/09/2020      Add logic to copy review date to close date
3.1      App FSC      David Rufo         28/09/2020      Added OrigenApp when the app is created
3.2      App FSC      David Rufo         04/10/2020      Fix problems with nullpointer
3.3      US99751      Álvaro López       07/10/2020      Added validateForbiddenWords method
3.4      US128581     Sandra Gómez       15/10/2020      Added setFieldsFromOppTask method
3.5      US126439     David Rufo         20/10/2020      New value in AV_OrigenApp__c when the task is created
3.6      OwnerID      Carolina Alonso    21/10/2020      Add method 'processOwnerEAPGestor' to regularize the ownerIds
3.7      US130994     Jashanpreet        21/10/2020      Added telephoneContracting
3.8      US117506     Eric Vázquez       22/10/2020      Add method to call API Opportunity
3.9      US117509     Eric Vázquez       27/10/2020      Add method validate to delete Opportunity
4.0      US135452     Jashanpreet        03/11/2020      added logic processOwnerEAPGestor for insert
4.1      App FSC      Sandra Gómez       12/11/2020      Fix Opportunity Alerta Comercial
5.0      App FSC      Esperanza Conde    16/11/2020      Add method validatePF
5.1      App FSC      Jashanpreet        07/12/2020      Delete soql queries to get RecordTypeIds
5.2      Valid PF     David Rufo         09/12/2020      Fix error: Too many queries in "validatePF" method
5.3      Check RT     David Rufo         09/12/2020      Improve common method to check RT + general RT
5.4      Check Api Only David Rufo       15/12/2020      No send data to GCF when the user has the API Only profile
5.5      US147562     Sandra Gómez       14/01/2020      Added new method createOpportunityComentarios
5.6      US158008     Eric Vázquez       27/01/2021      Add new validation with check in createTask
5.6      US155069     Eric Vázquez       29/01/2021      Add new method removeDuplictyTask
5.7      US160173     Sandra Gómez       01/02/2021      Add new method opportunityValueNumeroDocumento
5.8      US161442     Álvaro López       11/02/2021      Added new method fillClientProduct
5.9      CustomPS     David Rufo         15/02/2021      Change API Only check for integration by Custom Permission
6.0      Fix bug      Eric Vazquez       23/02/2021      Add new method for fill the AV_fechaAlta__c from opp
6.1      Fix bug      David Rufo         08/03/2021      Fix method "createTarea" problem with Adobe when try to create task mixing data with employee and empty
6.2      US189148     Sandra Gómez       17/03/2021      change in methods updateTaskWithOpp and createTareaWithCheckClient add method updateListOpp
6.3      DE44621      Víctor Santiago    20/04/2021      Added field AV_FechaVencimiento__c to setFieldsFromOppTask
6.4      DE46491/DE46686 Sandra Gómez    02/06/2021      Change method processOwnerEAPGestor
6.5      FIX          David Rufo         01/07/2021      Fix method validation delete opp
6.6      FIX          David Rufo         15/07/2021      Fix problems with check on/off priorizador
6.7      US244590     Víctor Santiago    19/07/2021      Added method checkUserFields. Modified method saveFieldsFromOpp,added mapOldObj parameter and checkUserFields call.
6.8      FIX          Sandra Gómez       30/07/2021      Fix problems with check on/off priorizador
6.9      FIX Owners   Sandra Gómez       24/08/2021      Fix process Owners Gestor
7.0      FIX Confiden.Víctor Santiago    05/10/2021      Created method setConfidentiality
7.1      DE52465      Sandra Gómez       30/09/2021      refactor EAP/Gestor
7.2      US245181     Daniel Rodríguez   01/12/2021      Include AV_EmployeeCustomer__c field in updateOppConfidentiality method
7.3      DE54985      Carolina Alonso    21/12/2021      Modify updateCloseDate to include all Opportunity RTs to copy fecha prox gestión in close date 
7.4      Fix          Sandra Gómez       12/01/2022      Change order update task and headertask
7.5      US312995     Daniel Rodríguez   17/01/2022      Include new filter AV_ProyectUser in method saveFieldsFromOpp
7.6      AV_Query IT  Daniel Rodríguez   03/02/2022      Change AV_Query to SOQL for User, Account, Contact
7.7      US312995     Carolina Alonso    07/02/2022      Delete filter of AV_ProyectUser in method saveFieldsFromOpp
7.8      US325412     Víctor Santiago    02/03/2022      Added checkStageName method
7.9      US310766     Luis Fernández     21/03/2022      Added updateFechaActivación method
8.0      US339508     Luis Fernández     30/03/2022      Added UpdateCentro method
8.1      US310702     Luis Fernández     12/04/2022      Modify changeOwner to include new GFC user and make him owner of Opportunities with an Owner who has no EAP.
8.2      US365180     Víctor Santiago    14/04/2022      Added calls to queueable in insertTaskWithOpp, updateTaskWithOpp
8.3      US332485     Luis Fernández     28/04/2022      Modify updateCentro method
8.4      US332485     Víctor Santiago    05/05/2022      Populate created task center with opp center in createTarea and createTareaWithCheckClient
8.5      US349217     Luis Fernández     29/06/2022      Added "blockCloseDateUpdate" method to prevent to change the closeDate in the flexipage.
8.5      US387146     Luis Fernández     01/07/2022      Modified saveFieldsFromOpp method to do not change the owner when an opportunity insert.
8.6		 DE63589	  Sandra Gómez		 01/09/2022		 Add new method updateGCF
8.7		 US451923	  Patricia Solano	 28/09/2022		 Modify saveFieldsFromOpp method to do not change the last modified date if only OwnerId is changed
8.8		 US457715	  Eduardo González	 19/10/2022		 Add new method updateSinGestor
8.9		 US460963     Luis Fernández	 31/10/2022	     Addes updateLastEmpleModificacion() method
9.0		 DE70320	  Sandra Gómez		 03/01/2023		 Change changeOwner add if compare with null
9.1      US500108     Elisabeth R.       09/01/2023      Changed updateGCF method
9.2      DE70065      Elisabeth R.       10/01/2023      Changed updateFechaActivacion method
9.3      US418584     Oscar Moreno       16/01/2023      Added updateStageName method
9.4		 US498642     Vladislav Lityagin 19/01/2023		 Added checkCallMeRT, createTaskCallMe, createTareaCallMe and getOwners 
9.5		 US411482	  Vladislav Lityagin 03/02/2023		 Added assignPropensity
9.6      DE71659      Sandra Gómez       15/02/2023      Change method updateGCF add CloseDate
9.7      DE72504      Elisabeth R.       24/02/2023      Added emptyResolutionField method
9.8 	 US552657	  Ángel Medina		 15/03/2023		 Modify the query of the validatePF method
9.9 	 US482011	  Patricia Solano    28/03/2023		 Added new method deleteRecordsRelatedWithOpportunity to delete related content
10.0 	 US499876  	  Patricia Solano    13/04/2023		 Modify method getAllRT to add Call Me RecordType 
10.1	 US582623	  Luis Fernández	 10/05/2023		 Modified updateGFC method. Conditional added
10.2	 FIX 	 	  Luis Fernández	 30/05/2023		 Fixed method validatePF
10.2	 US586351	  Luis Fernández	 30/05/2023		 Added new stage to filter query in ValidatePF method (Vencido)
10.3     DE80526      Elisabeth R.       08/08/2023      Delete createTareaOportunidadCM and getOwners. Added createTaskCallMeFromJSON method. Modified createTaskCallMe method
10.4	 Fix		  Sandra Gómez		 17/08/2023		 Add method backReport
10.5     US662921 	  Luis Fernández	 17/08/2023		 Added filter AV_SalesforceClientReport in checkStageName, insertTaskWithOpp and updateTaskWithOpp in order to bypass prioritzing logic
10.6     US662921 	  Luis Fernández	 17/08/2023		 Added AV_AmountEuro__c, AV_MarginEuro__c,AV_ByProduct__c to setFieldsFromOppTask method
10.7	 Fix		  Carolina Alonso	 23/08/2023		 Modify changeOwner method to check if OwnerId is not blank
10.8     US686939     Oscar Moreno       24/08/2023      Create updateCommentsHistory, createCommentsHistory and deleteCommentsHistory methods
10.9	 US662921	  Sandra Gómez		 28/08/2023		 Modify method checkStageName and blockCloseDateUpdate add origin back and sendDataToGCF not call with origenapp AV_SalesforceClientReport to TO_ROW_LOCK and updateTaskWithOpp and insertTaskWithOpp no pass if origin AV_BackReport
11.0     Fix          Elisabeth R.       28/08/2023      Fix validatePF method to change externalId only if RT is Iniciativa gestor
11.1	 US662921	  Sandra Gómez		 14/09/2023		 Add validations in trigger and bypass of origin all in a method and do insert to this method
11.2	 Fix		  Sandra Gómez		 28/09/2023		 Add bypass of origin backnewopp in method byPassOpp and change methods updateTaskWithOpp, insertTaskWithOpp and sendDataToGCF to add origin bypass
11.3	 Fix PMD Errors Daniel Rodriguez 05/10/2023	     Modify method updateCommentsHistory,  createCommentsHistory,deleteCommentsHistory, Add WITH SECURITY_ENFORCED in queries and reuse userGFC. Modify updateCentro, validatePF to replace query for record type
11.4	 Fix		  Sandra Gómez		 07/10/2023		 Change method setFieldsFromOppTask add parameter mapByPass
11.5	 Fix		  Sandra Gómez		 13/11/2023		 Change method setFieldsFromOppTask add fields resolution and channel
11.6	 Fix		  Sandra Gómez		 24/11/2023		 Change method createTaskCallMe delete WITH SECURITY_ENFORCED in query CustomNotificationType
11.7	 Fix 		  Sandra Gómez		 16/11/2023		 Change method updateTaskWithOpp to change variable updateTask of List to Map
11.8     US621640     Oscar Moreno       05/12/2023      Change updateCloseDate method. When AV_FechaProximoRecordatorio__c is modified, the CloseDate  will be equal AV_FechaProximoRecordatorio__c + 7 days
11.8	 Fix Label	  Humberto Vilchez	 05/12/2023		 Change method validationsOpportunity replace messages with Custom Labels
11.9	 FE144643     Luis Fernández     27/12/2023		 Added new calculateScoreOpp method 
12.0	 FE144643     Luis Fernández     29/12/2023		 Added new calculateScoreClient method
12.1	              Gonzalo Ávila      11/01/2024      Added a check of the AV_PilotCenters__c customSetting centers before creating the task in the createTask and createTaskCallMe methods
12.2                  Oscar Moreno       12/01/2024      Comment setFieldsFromOppTask method
12.3	US839366	  Ángel Medina		 06/03/2024		 Add bypass of origin updatewallet in method byPassOpp	
12.4	US839366	  Ángel Medina		 06/03/2024		 Change method updateGCF add condition AV_OrigenApp__c != AV_AppConstants.OPP_ORIGEN_UPDATE_WALLET
12.5	Fix PF		  Sandra Gómez		 06/03/2024		 Change method validatePF to see externalId with · date, change method sendDataToGCF to not send if externalId with · date and change method byPassOpp to validate externalid null in insert
12.6    IN1135458     Elisabeth R.       19/03/2024      Changed createCommentsHistory and updateCommentsHistory to map employee
12.3	FIX18040954	  Luis Fernández	 19/04/2024		 Added null controll in all loops in calculateScoreClient in order to not send empty Id accounts to queuable
12.4	DT08		  Luis Fernández	 22/04/2024		 Elimintated calculateScoreOpp and sended to a without sharing class AV_OpportunityTriggerAux to avoid sharing rules
12.5    FIX IOP 7 Mayo Elisabeth R.      06/052024       Changed createCommentsHistory method to AV_OpportunityTriggerHelperSharing class due to sharing settings of the CSBD user who is creating the opportunity with comments
12.6    FIX IOP 22 Mayo Elisabeth R.     09/05/2024      Changed createTareaOportunidad method to AV_OpportunityTriggerHelperSharing class due to sharing settings of the CSBD user who is creating the AV_CustomActivityOpportunity__c 
12.3	PPM100205278   Luis Fernández	 21/05/2024		 Added Producto Rechazado to the evaluated StageNames in emptyResolutionField method and all places where its needed (Because of the presence of Cerrado positivo or No interesado) and No gestionada wherever Vencida is
12.4    PPM100205278   Elisabeth R.      22/05/2024      Added fillSubState and blankSubState methods
12.5    PPM100130465   Sandra Gómez      30/07/2024		 Change metohds updateCommentsHistory and byPassOpp to add parameter mapByPassOld
12.6	PPM100265161   Sandra Gómez		 11/10/2024		 Change method updateGCF and byPassOpp to add filter DATAPIPELINES_ORIGENAPP
***********************************************************************************************************************/
public with sharing class AV_OpportunityTriggerHelper {
	private static final String SUFFIX_EXTERNALID     = 'Opp-';
	private static final String ERROR_MESSAGE      = Label.AV_deleteToOpp;
	private static final String ERROR_MESSAGE_PF    = Label.AV_PFDuplicate;
	private static final String ERROR_UNCHECKPRIORIZE  = Label.AV_uncheckClientsPriorize;
	public static DateTime dateExternalId;
	private static AV_AppUtilities.SearchRT rtAlertaComercial   = new AV_AppUtilities.SearchRT(AV_AppConstants.OBJECT_NAME_OPPORTUNITY, AV_AppConstants.OPPALERTACOM_RT);
	private static AV_AppUtilities.SearchRT rtIniciativa     = new AV_AppUtilities.SearchRT(AV_AppConstants.OBJECT_NAME_OPPORTUNITY, AV_AppConstants.OPPINICIATIVA_RT);
	private static AV_AppUtilities.SearchRT rtPropuesta     = new AV_AppUtilities.SearchRT(AV_AppConstants.OBJECT_NAME_OPPORTUNITY, AV_AppConstants.OPPPROPUESTA_RT);
	private static AV_AppUtilities.SearchRT rtSugerencia     = new AV_AppUtilities.SearchRT(AV_AppConstants.OBJECT_NAME_OPPORTUNITY, AV_AppConstants.OPPSUGERENCIA_RT);
	private static AV_AppUtilities.SearchRT rtCallMe     = new AV_AppUtilities.SearchRT(AV_AppConstants.OBJECT_NAME_OPPORTUNITY, AV_AppConstants.OPPLLAMADA_RT);
	private static Set<Id> setRtAll     = getAllRT();
	private static Set<Id> setRtAlerta     = getIdsRT(new Set<AV_AppUtilities.SearchRT>{rtAlertaComercial});
	private static Set<Id> setRtIniciativa  = getIdsRT(new Set<AV_AppUtilities.SearchRT>{rtIniciativa});
	private static Set<Id> setRtPropuesta   = getIdsRT(new Set<AV_AppUtilities.SearchRT>{rtPropuesta});
	private static Set<Id> setRtSugerencia   = getIdsRT(new Set<AV_AppUtilities.SearchRT>{rtSugerencia});
	private static Set<Id> setRtCallMe   = getIdsRT(new Set<AV_AppUtilities.SearchRT>{rtCallMe});
	private static Set<Id> setRts = getIdsRT(new Set<AV_AppUtilities.SearchRT>{rtAlertaComercial, rtIniciativa,rtPropuesta,rtSugerencia});
	private static AV_AppUtilities.SearchRT rtTaskAlerta     = new AV_AppUtilities.SearchRT(AV_AppConstants.OBJECT_NAME_TASK, AV_AppConstants.TASKALERTACOM_RT);
	private static AV_AppUtilities.SearchRT rtTaskIniciativa  = new AV_AppUtilities.SearchRT(AV_AppConstants.OBJECT_NAME_TASK, AV_AppConstants.TASKINICIATIVA_RT);
	private static Set<Id> setRtTaskAlerta     = getIdsRT(new Set<AV_AppUtilities.SearchRT>{rtTaskAlerta});
	private static Set<Id> setRtTaskIniciativa   = getIdsRT(new Set<AV_AppUtilities.SearchRT>{rtTaskIniciativa});
	private static User userGFC = [SELECT ID FROM USER WHERE Alias = 'AV-TF9' and IsActive = TRUE LIMIT 1];
	
	/**
	* @description       Check the record types
	* @param listNews    list of new records
	*/
	public static List<Opportunity> checkGeneralRT(List<Opportunity> listNews){
		List<Opportunity> listData = new List<Opportunity>();
		for(Opportunity dataNew : listNews){
			if((setRtAll).contains(dataNew.RecordTypeId)){
				listData.add(dataNew);
			}
		}
		return listData;
	}
	
	/**
	* @description       Check the record types Call Me
	* @param listNews    list of new records
	*/
	public static List<Opportunity> checkCallMeRT(List<Opportunity> listNews){
		List<Opportunity> listData = new List<Opportunity>();
		for(Opportunity dataNew : listNews){
			if((setRtCallMe).contains(dataNew.RecordTypeId)){
				listData.add(dataNew);
			}
		}
		return listData;
	}
	
	/**
	* @description       Get all the ID's of the RT
	*/
	public static Set<Id> getAllRT(){
		Set<AV_AppUtilities.SearchRT> setLabelsRt = new Set<AV_AppUtilities.SearchRT>{rtAlertaComercial, rtIniciativa, rtPropuesta, rtSugerencia, rtCallMe};
			return AV_AppUtilities.getRecordTypeIdsInSet(setLabelsRt);
	}
	
	/**
	* @description       Get the ID's of the RT's requested by param
	* @param setRT      List of the RT
	*/
	public static Set<Id> getIdsRT(Set<AV_AppUtilities.SearchRT> setRT){
		return AV_AppUtilities.getRecordTypeIdsInSet(setRT);
	}
	
	/**
	* @description     Create a Task associated with a Opportunity 
	* @param  listOpp  list of Opportunities
	*/
	public static void createTask(List<Opportunity> listOpp) {  
		String methodName='createTask';  
		Id rtTask     = (new List<Id>(setRtTaskAlerta)).get(0);
		List<Task> listTask = new List<Task>();
		Map<String, Task> mapTask     = new Map<String, Task>();
		List<Opportunity> listUsedOpp   = new List<Opportunity>();
		Map<Id, String> mapAccNames   = getMapAccountNames(listOpp);
		Map<Id, Contact> mapGestor     = getMapGestores(listOpp);
		List<AV_PilotCenters__c> listAvPilotCenters = AV_PilotCenters__c.getall().values();
		List<String> officeNumbers = new List<String>();
		if(listAvPilotCenters != null && !listAvPilotCenters.isEmpty()){
			for (AV_PilotCenters__c pilotCenterGroup : listAvPilotCenters){
				List<String> pilotCenterOfficeNumbers = new List<String>();
				if(pilotCenterGroup.AV_OfficeNumber__c!=null && !String.isEmpty(pilotCenterGroup.AV_OfficeNumber__c)){
					pilotCenterOfficeNumbers = pilotCenterGroup.AV_OfficeNumber__c.split(',');
					for(String officeNumber : pilotCenterOfficeNumbers){
							officeNumbers.add(officeNumber);
					}
				}
			}
		}
		for(Opportunity opp : listOpp){
			Boolean checkPilotCenters = true;
			if(opp.AV_Center__c != null && !String.isEmpty(opp.AV_Center__c) && listAvPilotCenters != null && !listAvPilotCenters.isEmpty()){
				if(officeNumbers.contains(opp.AV_Center__c)){
					checkPilotCenters = false;
				}
			}
			if(setRtAlerta.contains(opp.RecordTypeId) && String.isNotBlank(opp.AV_ExternalID__c) && checkPilotCenters){
				Date activityDate = date.today() + 5;
				if(opp.AV_DueDateTask__c!=null){
					activityDate= opp.AV_DueDateTask__c;
				}
				Task tarea = createTarea(opp, activityDate, rtTask, mapAccNames, mapGestor);   
				listTask.add(tarea);
				listUsedOpp.add(opp);
				mapTask.put(tarea.AV_ExternalID__c, tarea);
			}
		}
		if (listTask!=null && !listTask.isEmpty()) { //Insertar la lista de Tareas creadas.
			List<Database.SaveResult> updateResults= Database.insert(listTask, false);
			AV_AppUtilities.displayErrors(methodName, updateResults);
			Set<String> setExternalIds = new Set<String>();
			setExternalIds = mapTask.keySet();
			createTareaOportunidad(setExternalIds, listUsedOpp); //Crear una Tarea-Oportunidad asociada a la oportunidad y la cabecera-tarea asociada a la tarea.
		}
	}

	
	/**
	* @description     Update Task associated with a Opportunity when check on/off 
	* @param  listOpp   old list of Opportunities
	* @param  newListOpp  new list of Opportunities
	*/
	public static void updateTaskWithOpp(List<Opportunity> listOpp, Map<Id, Opportunity> mapOldObj, Map<String, Opportunity> mapByPass) {
		String methodName = 'updateTaskWithOpp';
		//Get recordId AV_Otros for Tasks
		Id rtTaskIni   = (new List<Id>(setRtTaskIniciativa)).get(0);
		Set<String> oppStageNotClosed = new Set<String>{'Potencial','En gestión/insistir'};
		//Variable's
		List<Opportunity> listUsedOpp = new List<Opportunity>();
		Map<String, Task> mapNewTask = new Map<String, Task>();
		List<Task> newTask = new List<Task>();
		Map<Id,Task> updateTask = new Map<Id,Task>();
		List<Id> deleteTareaOpp = new List<Id>();
		List<Id> deleteHeaderTsk = new List<Id>();
		List<Id> deleteTask = new List<Id>();
		List<Opportunity> updateListOpp= new List<Opportunity>();
		Map<Id, Contact> mapGestor;
		List<Task> lstTask = new List<Task>();
		Set<String> setListIdOpp = new Set<String>();
		Set<String> setListIdPF = new Set<String>();
		Map<String, Product2> mapProducts = new Map<String, Product2>();
		Map<String, List<String>> mapExtIdTaskOpp = new Map<String, List<String>>();
		Map<String, Task> mapExistTask = new Map<String, Task>();
		Map<String, List<AV_CustomActivityOpportunity__c>> mapTaskOpp = new Map<String, List<AV_CustomActivityOpportunity__c>>();
		List<Opportunity> listOppNews = new List<Opportunity>();
		//Loop to get the Opp and PF ID's
		for(Opportunity opp : listOpp){
			if(!mapByPass.containsKey(opp.AV_ExternalID__c)){
				setListIdOpp.add(opp.Id);
				setListIdPF.add(opp.AV_PF__c);
				listOppNews.add(opp);
			}
		}
		if(setListIdPF != null && !setListIdPF.isEmpty()){
			List<Product2> listProduct = [Select Id, Name from Product2 where Id in :setListIdPF WITH SECURITY_ENFORCED];
			mapProducts = new Map<String, Product2>(listProduct);
			mapGestor = getMapGestores(listOppNews);
		}
		//***************************************************
		//1. Get the related task's (if exist)
		//***************************************************
		if(setListIdOpp != null && !setListIdOpp.isEmpty()){
			Set<String> setListTareaOpp = new Set<String>();
			List<AV_CustomActivityOpportunity__c> listTaskAndOpp = [Select Id, AV_Task__c, AV_IsMain__c, AV_Task__r.AV_ExternalID__c, AV_Opportunity__c from AV_CustomActivityOpportunity__c where AV_IsMain__c = true and AV_Opportunity__c in :setListIdOpp WITH SECURITY_ENFORCED];
			//Get the id of the header-task
			for(AV_CustomActivityOpportunity__c tskOpp : listTaskAndOpp){
				if (tskOpp.AV_Task__r.AV_ExternalID__c!= null) {
					setListTareaOpp.add(tskOpp.AV_Task__r.AV_ExternalID__c);
					if(!mapExtIdTaskOpp.containsKey(tskOpp.AV_Opportunity__c)) {
						mapExtIdTaskOpp.put(tskOpp.AV_Opportunity__c, new List<String>{tskOpp.AV_Task__r.AV_ExternalID__c});
					} else {
						mapExtIdTaskOpp.get(tskOpp.AV_Opportunity__c).add(tskOpp.AV_Task__r.AV_ExternalID__c);
					}
				}
				if(!mapTaskOpp.containsKey(tskOpp.AV_Opportunity__c)) {
					mapTaskOpp.put(tskOpp.AV_Opportunity__c, new List<AV_CustomActivityOpportunity__c>{tskOpp});
				} else {
					mapTaskOpp.get(tskOpp.AV_Opportunity__c).add(tskOpp);
				}
			}
			//Get data of header-task
			if(setListTareaOpp != null && !setListTareaOpp.isEmpty()){
				lstTask = [SELECT Id, AV_ExternalID__c, Status, IsClosed, ActivityDate, AV_OrigenApp__c, RecordTypeId FROM TASK WHERE AV_ExternalId__c IN :setListTareaOpp AND AV_OrigenApp__c = 'AV_SalesforceTaskOpp' WITH SECURITY_ENFORCED];
				for (Task task : lstTask){
					mapExistTask.put(task.AV_ExternalId__c, task);
				}
				//Check if the relationship is event (this will not check in the process)
				List<Event> lstEvent = [Select Id, AV_ExternalId__c from Event where AV_ExternalId__c in :setListTareaOpp WITH SECURITY_ENFORCED];
				Map<String, Event> mapExistEvent = new Map<String, Event>();
				for (Event evt : lstEvent){
					mapExistEvent.put(evt.AV_ExternalId__c, evt);
				}
				if (!lstEvent.isEmpty()){
					List<String> listAuxExtData = new List<String>();
					for (String idOpp : mapExtIdTaskOpp.keySet()){
						List<String> listExtData = mapExtIdTaskOpp.get(idOpp);
						if (listExtData!=null && !listExtData.isEmpty()){
							for(String ext : listExtData){
								if (!mapExistEvent.keySet().contains(ext)){
									listAuxExtData.add(ext);
								}
							}
						}
						mapExtIdTaskOpp.get(idOpp).clear();
						mapExtIdTaskOpp.get(idOpp).addAll(listAuxExtData);
					}
					List<AV_CustomActivityOpportunity__c> listAuxDataTareaOpp = new List<AV_CustomActivityOpportunity__c>();
					for (String idOpp : mapTaskOpp.keySet()) {
						List<AV_CustomActivityOpportunity__c> listDataTareaOpp = mapTaskOpp.get(idOpp);
						if (listDataTareaOpp!=null && !listDataTareaOpp.isEmpty()) {
							for(AV_CustomActivityOpportunity__c ext : listDataTareaOpp){
								if (!mapExistEvent.keySet().contains(ext.AV_Task__r.AV_ExternalID__c)){
									listAuxDataTareaOpp.add(ext);
								}
							}
						}
						mapTaskOpp.get(idOpp).clear();
						mapTaskOpp.get(idOpp).addAll(listAuxDataTareaOpp);
					}
				}
			}
		}
		//***************************************************
		//2. Check "Fecha Proximo Recordatorio" + "Stage Opp" 
		//    + "Status Task" + "Check On/Off" 
		//***************************************************
		//Lists used to insert or update or delete
		if (listOppNews != null && !listOppNews.isEmpty()) {  
			for(Opportunity opp : listOppNews) {
				List<String> extIdTask = new List<String>();
				if(mapExtIdTaskOpp != null && !mapExtIdTaskOpp.isEmpty()){
					if (mapExtIdTaskOpp.containsKey(opp.Id)) {
						extIdTask = mapExtIdTaskOpp.get(opp.Id);
					}
				}
				//No exist task -> create task + task-opp if check change OFF to ON
				if (extIdTask.isEmpty() && opp.AV_FechaProximoRecordatorio__c != null && opp.AV_FechaProximoRecordatorio__c >= System.today() && opp.AV_IncludeInPrioritizingCustomers__c && !mapOldObj.get(opp.Id).AV_IncludeInPrioritizingCustomers__c && oppStageNotClosed.contains(opp.StageName)){
					Date activityDate = opp.AV_FechaProximoRecordatorio__c;
					Task tarea = createTareaWithCheckClient(opp, activityDate, rtTaskIni, mapGestor, mapProducts);
					newTask.add(tarea);
					listUsedOpp.add(opp);
					mapNewTask.put(tarea.AV_ExternalID__c, tarea);
				} else if (!extIdTask.isEmpty()){ //Exist task
					AV_LogDebug.printLogDebug(methodName, 'mapExistTask: ' + mapExistTask);
					List<Task> listTask= new List<Task>();
					Task taskNotClosed;
					Integer contTaskClosed=0;
					for (String extId : extIdTask) {
						if (mapExistTask.containsKey(extId)) {
							Task ta = mapExistTask.get(extId);
							listTask.add(ta);
						}
					}       
					for(Task ta : listTask){
						if (ta.IsClosed) {
							contTaskClosed++;
						}else {
							taskNotClosed = ta;
						}
					}
					AV_LogDebug.printLogDebug(methodName, 'listTask: ' + listTask);
					if (!listTask.isEmpty()){
						//Check OFF - ON and related tasks is Closed
						boolean newTaskOK = false;
						if (opp.AV_FechaProximoRecordatorio__c != null && opp.AV_FechaProximoRecordatorio__c >= System.today() && opp.AV_IncludeInPrioritizingCustomers__c && !mapOldObj.get(opp.Id).AV_IncludeInPrioritizingCustomers__c && oppStageNotClosed.contains(opp.StageName) && listTask.size()==contTaskClosed){
							Date activityDate = opp.AV_FechaProximoRecordatorio__c;
							Task tarea = createTareaWithCheckClient(opp, activityDate, rtTaskIni, mapGestor, mapProducts);
							newTask.add(tarea);
							listUsedOpp.add(opp);
							mapNewTask.put(tarea.AV_ExternalID__c, tarea);
							newTaskOK = true;
						}
						//If opp convert to close stage and task is not closed then: check false, blank date and delete task
						if (!oppStageNotClosed.contains(opp.StageName) && oppStageNotClosed.contains(mapOldObj.get(opp.Id).StageName) && listTask.size()>contTaskClosed && taskNotClosed != null){
							AV_CustomActivityOpportunity__c cap;
							List<AV_CustomActivityOpportunity__c> listCap = mapTaskOpp.get(opp.Id);
							for (AV_CustomActivityOpportunity__c tareaOpp : listCap) {
								if (tareaOpp.AV_Task__r.AV_ExternalID__c == taskNotClosed.AV_ExternalID__c) {
									cap = tareaOpp;
								}
							}
							if(cap!=null){
								deleteTareaOpp.add(cap.Id);
								deleteHeaderTsk.add(cap.AV_Task__c);
							}
							deleteTask.add(taskNotClosed.Id);
							updateListOpp.add(opp);
						}	
						//update revision date if it is changed and check true
						if(mapOldObj!=null && opp.AV_FechaProximoRecordatorio__c != mapOldObj.get(opp.Id).AV_FechaProximoRecordatorio__c && opp.AV_IncludeInPrioritizingCustomers__c){
							if (listTask.size()==contTaskClosed && !newTaskOK) {
								Date activityDate = opp.AV_FechaProximoRecordatorio__c;
								Task tarea = createTareaWithCheckClient(opp, activityDate, rtTaskIni, mapGestor, mapProducts);
								newTask.add(tarea);
								listUsedOpp.add(opp);
								mapNewTask.put(tarea.AV_ExternalID__c, tarea);
							} else if (taskNotClosed!=null) {
								taskNotClosed.ActivityDate = opp.AV_FechaProximoRecordatorio__c;
								updateTask.put(taskNotClosed.Id,taskNotClosed);
							}
						} 
						//Check change from ON to OFF
						if(opp.AV_FechaProximoRecordatorio__c != null && mapOldObj!=null && !opp.AV_IncludeInPrioritizingCustomers__c && mapOldObj.get(opp.Id).AV_IncludeInPrioritizingCustomers__c){
							//if task is not closed then delete task and task-opp
							if(listTask.size()>contTaskClosed && taskNotClosed != null) {
								AV_CustomActivityOpportunity__c cap;
								List<AV_CustomActivityOpportunity__c> listCap = mapTaskOpp.get(opp.Id);
								for (AV_CustomActivityOpportunity__c tareaOpp : listCap) {
									if (tareaOpp.AV_Task__r.AV_ExternalID__c == taskNotClosed.AV_ExternalID__c) {
										cap = tareaOpp;
									}
								}
								if(cap!=null){
									deleteTareaOpp.add(cap.Id);
									deleteHeaderTsk.add(cap.AV_Task__c);
								}
								deleteTask.add(taskNotClosed.Id);
							}
						}
					} else if (opp.AV_FechaProximoRecordatorio__c != null && opp.AV_FechaProximoRecordatorio__c >= System.today() && opp.AV_IncludeInPrioritizingCustomers__c && !mapOldObj.get(opp.Id).AV_IncludeInPrioritizingCustomers__c && oppStageNotClosed.contains(opp.StageName)){
						Date activityDate = opp.AV_FechaProximoRecordatorio__c;
						Task tarea = createTareaWithCheckClient(opp, activityDate, rtTaskIni, mapGestor, mapProducts);
						newTask.add(tarea);
						listUsedOpp.add(opp);
						mapNewTask.put(tarea.AV_ExternalID__c, tarea);
					}
				}
			}
		}
		//Create task's + task-opp
		if(!newTask.isEmpty()){
			System.enqueueJob(new AV_CheckOnOff_Queueable(newTask, mapNewTask, listUsedOpp, dateExternalId));
		}
		//Update Task's
		if (updateTask!=null && !updateTask.isEmpty()){
			AV_LogDebug.printLogDebug(methodName, 'updateTask: ' + updateTask.values());
			System.enqueueJob(new AV_CheckOnOff_Queueable(updateTask.values()));
		}
		//Delete Task-Opp, Header-Task and Task
		if (deleteTareaOpp!=null && !deleteTareaOpp.isEmpty() && deleteHeaderTsk!=null && !deleteHeaderTsk.isEmpty() && deleteTask!=null && !deleteTask.isEmpty()){
			System.enqueueJob(new AV_CheckOnOff_Queueable(deleteTareaOpp,deleteTask,deleteHeaderTsk));
		}
		if (!updateListOpp.isEmpty() && !System.isFuture() && !System.isBatch()) {
			System.enqueueJob(new AV_CheckOnOff_Queueable(updateListOpp));
		}
	}
	
	/** -- No borrar --
	* @description      update Opportunity when check on/off 
	* @param  jsonString  list of Opportunities to update
	*/
	/*@Future
	public static void updateListOpp(String jsonString) {
		List<Opportunity> updateList = (List<Opportunity>)Json.deserialize(jsonString,List<Opportunity>.class);
		for(Opportunity opp :updateList) {
			opp.AV_IncludeInPrioritizingCustomers__c = false;
			if(opp.AV_FechaProximoRecordatorio__c >= System.today()){
				opp.AV_FechaProximoRecordatorio__c = null;
			}
		}
		Database.update(updateList, false);
	}*/
	
	/**
	* @description     insert Task associated with a Opportunity when check on/off 
	* @param  newListOpp  new list of Opportunities
	*/
	public static void insertTaskWithOpp(List<Opportunity> newListOpp,  Map<String, Opportunity> mapByPass) {
		Id rtTaskIni   = (new List<Id>(setRtTaskIniciativa)).get(0);
		Map<Id, Contact> mapGestor;
		Set<String> oppStageNotClosed = new Set<String>{'Potencial','En gestión/insistir'};
		List<Task> listTask = new List<Task>();
		List<Opportunity> listUsedOpp = new List<Opportunity>();
		Map<String, Product2> mapProducts = new Map<String, Product2>();
		Map<String, Task> mapTask = new Map<String, Task>();
		//Get the list of product's name
		Set<String> setListIdPF = new Set<String>();
		List<Opportunity> listOppFil = new List<Opportunity>();
		for(Opportunity opp : newListOpp){
			if(!mapByPass.containsKey(opp.AV_ExternalID__c) && opp.AV_IncludeInPrioritizingCustomers__c){
				setListIdPF.add(opp.AV_PF__c);
				listOppFil.add(opp);
			}
		}
		if(setListIdPF != null && !setListIdPF.isEmpty()){	
			List<Product2> listProduct = [Select Id, Name from Product2 where Id in :setListIdPF WITH SECURITY_ENFORCED];
			mapProducts = new Map<String, Product2>(listProduct);
			mapGestor = getMapGestores(newListOpp);
		}
		//Create task if check is on and "fecha-proximo-recordatorio" is not null
		if (listOppFil != null && !listOppFil.isEmpty()) {
			for(Opportunity opp : listOppFil){
				if(opp.AV_FechaProximoRecordatorio__c != null && opp.AV_FechaProximoRecordatorio__c >= System.today() && oppStageNotClosed.contains(opp.StageName)){
					Date activityDate = opp.AV_FechaProximoRecordatorio__c;
					Task tarea = createTareaWithCheckClient(opp, activityDate, rtTaskIni, mapGestor, mapProducts);
					listTask.add(tarea);
					listUsedOpp.add(opp);
					mapTask.put(tarea.AV_ExternalID__c, tarea);
				} else if(!oppStageNotClosed.contains(opp.StageName)){
					opp.addError(Label.AV_checkStatusClientePriorizador);
				} else if(opp.AV_FechaProximoRecordatorio__c < System.today()){
					opp.addError(Label.AV_controlFechaRecordatorio);
				}
			}
		}
		if(!listTask.isEmpty()){
			System.enqueueJob(new AV_CheckOnOff_Queueable(listTask, mapTask, listUsedOpp, dateExternalId));
		}      
	}
	
	/** -- No borrar --
	* @description     insert Tarea-Oportunidad when check on/off 
	* @param  listTask  list of Task for create Tarea-Oportunidad
	* @param  mapTask  map of Task for create Tarea-Oportunidad
	* @param  listUsedOpp  list of Opportunity for create Tarea-Oportunidad
	*/
	/*private static void createTaskCheckOnOff(List<Task> listTask, Map<String, Task> mapTask, List<Opportunity> listUsedOpp){
		 //Insert task + task-opp
		 if (listTask!=null && !listTask.isEmpty()){
			 //Insert task
			 Database.insert(listTask, false);
			 List<AV_CustomActivityOpportunity__c> newlistTaskAndOpp = AV_OpportunityTriggerHelperAux.createTaskOppWhenCheck(mapTask.keySet(), listUsedOpp, SUFFIX_EXTERNALID);
			 //Insert task-opp
			 if(newlistTaskAndOpp != null && !newlistTaskAndOpp.isEmpty()){
				 Database.insert(newlistTaskAndOpp, false);
			 }
			 Map<String, AV_CustomActivityOpportunity__c> mapTaskOpp = new Map<String, AV_CustomActivityOpportunity__c>();
			 for(AV_CustomActivityOpportunity__c cap : newlistTaskAndOpp){
				 mapTaskOpp.put(cap.AV_Task__c, cap);
			 }
			 //Update header-task with the id of the Task
			 List<AV_HeaderCustomActivity__c> listHeaderTask = [Select Id, AV_ExternalID__c, IDTask__c from AV_HeaderCustomActivity__c where Id in :mapTaskOpp.keySet()];
			 Map<String, AV_HeaderCustomActivity__c> mapHeaderTask = new Map<String, AV_HeaderCustomActivity__c>();
			 for(AV_HeaderCustomActivity__c hca : listHeaderTask){
				 mapHeaderTask.put(hca.AV_ExternalID__c, hca);
			 }
			 if(listHeaderTask != null && !listHeaderTask.isEmpty()){
				 AV_OpportunityTriggerHelperAux.fillHeaderTask(listTask, mapHeaderTask);
			 }
		 }
	}*/
	
	/**
	* @description         Create Tarea-Oportunidad associated with a Opportunity and a Cabecera-Tarea.
	* @param  setExternalIds    set of Task's external Ids.
	* @param  listOpp      list of Opportunities.
	*/
	private static void createTareaOportunidad(Set<String> setExternalIds, List<Opportunity> listOpp) {
		//Obtenemos todas las Cabecera-Tarea creadas.
		List<Task> listTareas = [Select Id, AV_ExternalID__c, AV_Task__c from Task where AV_ExternalID__c in :setExternalIds WITH SECURITY_ENFORCED];
		//Creo un mapa para guardar los externalId con sus correspondientes IDs de Tareas.              
		Map<String, String> mapTaskExternalID = new Map<String, String>();
		for(Task tarea : listTareas){
			if(tarea != null){
				mapTaskExternalID.put(tarea.AV_ExternalID__c, tarea.AV_Task__c);
			}
		}
		List<AV_CustomActivityOpportunity__c> listTareaOpp = new List<AV_CustomActivityOpportunity__c>();
		//Recorremos las oportunidades
		for(Opportunity opp : listOpp){
			if( opp != null && setExternalIds.contains(SUFFIX_EXTERNALID + opp.AV_ExternalID__c)){
				AV_CustomActivityOpportunity__c tareaOpp = new AV_CustomActivityOpportunity__c();  
				tareaOpp.AV_Task__c = mapTaskExternalID.get(SUFFIX_EXTERNALID + opp.AV_ExternalID__c);
				tareaOpp.AV_Opportunity__c = opp.Id;
				listTareaOpp.add(tareaOpp);
			}  
		}
		
		if(Schema.sObjectType.AV_CustomActivityOpportunity__c.isCreateable()){
			AV_OpportunityTriggerHelperSharing.insertTareaOpp(listTareaOpp);
		}    
	}
	
	/**
	* @description         Create Task associated with the Opportunity.
	* @param  opp        Opportunity.
	* @param  activityDate   Due Date
	* @param  rt         record type
	* @param  mapAccNames    map with the account names
	* @param  mapGestores    map with the employee's
	*/
	private static Task createTarea(Opportunity opp, Date activityDate, Id rt, Map<Id, String> mapAccNames, Map<Id, Contact> mapGestores) {
		Task tarea = new Task();
		if(String.isNotBlank(opp.AV_ExternalID__c)){
			tarea.AV_ExternalID__c = SUFFIX_EXTERNALID + opp.AV_ExternalID__c;
		}else{
			tarea.AV_ExternalID__c = SUFFIX_EXTERNALID + opp.Id;
		}
		tarea.ActivityDate = activityDate;
		if(String.isNotBlank(opp.AccountId)){
			tarea.WhatId = opp.AccountId;
		}
		if(mapAccNames!=null && !mapAccNames.isEmpty()){
			tarea.Subject = opp.Name;
		}
		tarea.Status = 'Open';
		tarea.Priority = 'A';
		tarea.RecordTypeId = rt;
		tarea.AV_OrigenApp__c = 'AV_SalesforceTaskOpp_Iniciativa';
		assignGestor(tarea, opp, mapGestores);
		tarea.AV_Center__c = opp.AV_Center__c;
		return tarea;
	}
	
	/**
	* @description      Assign the employee to the task object
	* @param  tarea      Task to update with the employee
	* @param  opp      Opportunity data to get the employee
	* @param  mapGestores  List of the employees
	*/
	private static Task assignGestor(Task tarea, Opportunity opp, Map<Id, Contact> mapGestores){
		String methodName = 'assignGestor';
		if(mapGestores!=null && !mapGestores.isEmpty()){
			Contact gestor = mapGestores.get(opp.AV_Gestor__c);
			AV_LogDebug.printLogDebug(methodName, 'Map gestores: ' + mapGestores);
			AV_LogDebug.printLogDebug(methodName, 'gestor: ' + gestor);
			if (gestor!=null){
				tarea.AV_CodigoGestorAsignado__c = gestor.CC_Matricula__c;
				if (gestor.AV_UsuarioAsociado__c!=null){
					tarea.OwnerId = gestor.AV_UsuarioAsociado__c;    
				}
			}
		}
		return tarea;
	}
	
	/**
	* @description     Create a Map with the Account Id and Account Name
	* @param  listOpp  List of Opportunities.
	*/
	private static Map<Id, String> getMapAccountNames(List<Opportunity> listOpp){
		Set<Id> accId = new Set<Id>();
		for(Opportunity opp : listOpp){
			if(String.isNotBlank(opp.AccountId)){
				accId.add(opp.AccountId);
			}
		}
		List<Account> listAcc = new List<Account>();
		if(accId != null && !accId.isEmpty()) {
			listAcc= [Select Id, Name From Account Where Id in :accId WITH SECURITY_ENFORCED];
		}
		Map<Id, String> mapAccNames = new Map<Id,String>();
		if(listAcc != null && !listAcc.isEmpty()) {
			for(Account acc : listAcc){
				mapAccNames.put(acc.Id, acc.Name);
			}
		}
		return mapAccNames;
	}
	
	/**
	* @description     Create a Map with the Contact Id and a Map with the Contact Name and Matricula associated with.
	* @param  listOpp  List of Opportunities.
	*/
	private static Map<Id, Contact> getMapGestores(List<Opportunity> listOpp){
		Set<Id> gestorId = new Set<Id>();
		for(Opportunity opp : listOpp){
			if(String.isNotBlank(opp.AV_Gestor__c)){
				gestorId.add(opp.AV_Gestor__c);
			}   
		}
		List<Contact> listGestor = new List<Contact>();
		Map<Id, Contact> mapGestor = null;
		if(gestorId != null && !gestorId.isEmpty()) {
			listGestor= [Select Id, Name, CC_Matricula__c, AV_UsuarioAsociado__c From Contact Where Id in :gestorId WITH SECURITY_ENFORCED];
			mapGestor = new Map<Id, Contact>(listGestor);
		}
		return mapGestor;
	}
	
	/**
	* @description       Copy Review Date to Close Date for all RTs
	* @param  listOpp    List of Opportunities
	* @param  mapOldObj    Map of old status Opportunities
	*/
	public static void updateCloseDate(List<Opportunity> listOpp, Map<Id, Opportunity> mapOldObj){
		for(Opportunity opp : listOpp){
			//Validate the RT for Intouch project
			if(setRts.contains(opp.RecordTypeId)){
				//Copy the closedate to "fechaProximoRecordatorio"
				if(opp.AV_FechaProximoRecordatorio__c != null && (mapOldObj == null ||  (mapOldObj != null && opp.AV_FechaProximoRecordatorio__c != mapOldObj.get(opp.Id).AV_FechaProximoRecordatorio__c))){
					opp.CloseDate = opp.AV_FechaProximoRecordatorio__c.addDays(7); 
				}
				//Copy the "fechaProximoRecordatorio" to closedate
				else if(opp.AV_FechaProximoRecordatorio__c == null && 'En gestión/insistir'.equalsIgnoreCase(opp.StageName)){
					opp.AV_FechaProximoRecordatorio__c = opp.CloseDate;
				}
			}
			if (opp.AV_FechaProximoRecordatorio__c == null && (AV_AppConstants.OPP_STATUS_NOINTERE.equals(opp.StageName) || AV_AppConstants.OPP_STATUS_CERRPOST.equals(opp.StageName) || AV_AppConstants.OPP_STATUS_PROD_RECH.equals(opp.StageName) || AV_AppConstants.OPP_STATUS_PROD_CONTR.equals(opp.StageName))) {
				opp.AV_FechaProximoRecordatorio__c = System.today();
				opp.CloseDate = opp.AV_FechaProximoRecordatorio__c;
			}
		}
	}
	
	/** -- No borrar --
	* @description     Validate forbidden words in Opportunity field 
	* @param  listNews  list of new Opportunity records
	* @param mapOlds map of old Opportunity records
	*/
	/*public static void validateForbiddenWords(List<Opportunity> listNews, Map<Id, Opportunity> mapOlds) {
		List<Opportunity> listToProcess = new List<Opportunity>();
		Set<String> setFields = new Set<String>{'AV_Comentarios__c', 'Name'};
			if(mapOlds != null && !mapOlds.isEmpty()) {
				for(Opportunity opp : listNews) {
					if( (setRtAll).contains(opp.RecordTypeId) && (String.isNotBlank(opp.AV_Comentarios__c) && mapOlds.get(opp.Id).AV_Comentarios__c != opp.AV_Comentarios__c) || (String.isNotBlank(opp.Name) && mapOlds.get(opp.Id).Name != opp.Name)) {
						listToProcess.add(opp);
					}
				}
			} else {
				for(Opportunity opp : listNews) {
					if((setRtAll).contains(opp.RecordTypeId) && String.isNotBlank(opp.AV_Comentarios__c) || String.isNotBlank(opp.Name)) {
						listToProcess.add(opp);
					}
				}
			}
		if(listToProcess!=null && !listToProcess.isEmpty()) {
			AV_ForbiddenWords.validateRecords(listToProcess, setFields);
		}
	}*/
	
	/**
	* @description       Set Fields From AV_CustomActivityOpportunity__c
	* @param  listOpp    List of Opportunities
	* @param  mapOldObj    Map of old status Opportunities
	*/
	/*public static void setFieldsFromOppTask(List<Opportunity> listNews, Map<Id, Opportunity> mapOlds, Map<String, Opportunity> mapByPass) {
		List<Opportunity> listToProcess = new List<Opportunity>();
		for(Opportunity opp : listNews) {
			if((setRtAll).contains(opp.RecordTypeId) && mapOlds.get(opp.Id).Name != opp.Name || mapOlds.get(opp.Id).AV_PF__c != opp.AV_PF__c ||
			   mapOlds.get(opp.Id).AV_Gestor__c != opp.AV_Gestor__c || mapOlds.get(opp.Id).AV_Potencial__c != opp.AV_Potencial__c ||
			   mapOlds.get(opp.Id).AV_FechaProximoRecordatorio__c != opp.AV_FechaProximoRecordatorio__c ||
			   mapOlds.get(opp.Id).StageName != opp.StageName || mapOlds.get(opp.Id).AV_Valor1__c != opp.AV_Valor1__c ||
			   mapOlds.get(opp.Id).AV_Concepto1__c != opp.AV_Concepto1__c || mapOlds.get(opp.Id).AV_Valor2__c != opp.AV_Valor2__c ||
			   mapOlds.get(opp.Id).AV_Concepto2__c != opp.AV_Concepto2__c || mapOlds.get(opp.Id).AV_Valor3__c != opp.AV_Valor3__c ||
			   mapOlds.get(opp.Id).AV_Concepto3__c != opp.AV_Concepto3__c || mapOlds.get(opp.Id).AV_Valor4__c != opp.AV_Valor4__c ||
			   mapOlds.get(opp.Id).AV_Concepto4__c != opp.AV_Concepto4__c || mapOlds.get(opp.Id).AV_Valor5__c != opp.AV_Valor5__c ||
			   mapOlds.get(opp.Id).AV_Concepto5__c != opp.AV_Concepto5__c || mapOlds.get(opp.Id).AV_Tenencia__c != opp.AV_Tenencia__c ||
			   mapOlds.get(opp.Id).AV_Entidad__c != opp.AV_Entidad__c || mapOlds.get(opp.Id).CloseDate != opp.CloseDate ||
			   mapOlds.get(opp.Id).AV_Cuota__c != opp.AV_Cuota__c || mapOlds.get(opp.Id).Amount != opp.Amount ||
			   mapOlds.get(opp.Id).AV_TipoInteres__c != opp.AV_TipoInteres__c || mapOlds.get(opp.Id).AV_Comentarios__c != opp.AV_Comentarios__c ||
			   mapOlds.get(opp.Id).AV_IncludeInPrioritizingCustomers__c != opp.AV_IncludeInPrioritizingCustomers__c ||
			   mapOlds.get(opp.Id).AV_FechaVencimiento__c != opp.AV_FechaVencimiento__c ||
			   mapOlds.get(opp.Id).AV_LicensePlate__c != opp.AV_LicensePlate__c) {
				   listToProcess.add(opp);
			   }
		}
		if(!listToProcess.isEmpty()) {
			Set<String> setOppTaskStage = new Set<String>{'Potencial','En gestión/insistir','En espera'};
				List<AV_CustomActivityOpportunity__c> listOppTask = [SELECT Id, AV_Opportunity__c, Name, AV_Product__c, AV_Gestor__c, RecordTypeId, RecordType.Name, AV_Priority__c, AV_ReviewDate__c, AV_Stage__c, AV_Valor1__c, AV_Concepto1__c, AV_Valor2__c, AV_Concepto2__c, AV_Valor3__c, AV_Concepto3__c, AV_Valor4__c, AV_Concepto4__c, AV_Valor5__c, AV_Concepto5__c, AV_HoldingAnotherEntity__c, AV_Entity__c, AV_DueDate__c, AV_FeeAmount__c, AV_Amount__c, AV_TypeOfInterest__c, AV_Commentary__c, AV_IncludeInPrioritizingCustomers__c, AV_FechaVencimiento__c FROM AV_CustomActivityOpportunity__c WHERE AV_Opportunity__c IN :listToProcess AND AV_Stage__c in :setOppTaskStage WITH SECURITY_ENFORCED];
			Map<String, List<AV_CustomActivityOpportunity__c>> mapOppTask = new Map<String, List<AV_CustomActivityOpportunity__c>>();
			for(AV_CustomActivityOpportunity__c oppTask : listOppTask) {
				if(!mapOppTask.containsKey(oppTask.AV_Opportunity__c)) {
					mapOppTask.put(oppTask.AV_Opportunity__c, new List<AV_CustomActivityOpportunity__c>{oppTask});
				} else {
					mapOppTask.get(oppTask.AV_Opportunity__c).add(oppTask);
				}
			}
			List<AV_CustomActivityOpportunity__c> listOppTaskToProcess = new List<AV_CustomActivityOpportunity__c>();
			for(Opportunity opp : listToProcess) {
				if(mapOppTask.containsKey(opp.Id)) {
					for(AV_CustomActivityOpportunity__c oppTaskToProcess : mapOppTask.get(opp.Id)) {
						oppTaskToProcess.Name = opp.Name;
						oppTaskToProcess.AV_Product__c = opp.AV_PF__c;
						oppTaskToProcess.AV_Gestor__c = opp.AV_Gestor__c;
						oppTaskToProcess.AV_Priority__c = opp.AV_Potencial__c;
						oppTaskToProcess.AV_ReviewDate__c = opp.AV_FechaProximoRecordatorio__c;
						oppTaskToProcess.AV_Stage__c = opp.StageName;
						oppTaskToProcess.AV_Valor1__c = opp.AV_Valor1__c;
						oppTaskToProcess.AV_Concepto1__c = opp.AV_Concepto1__c;
						oppTaskToProcess.AV_Valor2__c = opp.AV_Valor2__c;
						oppTaskToProcess.AV_Concepto2__c = opp.AV_Concepto2__c;
						oppTaskToProcess.AV_Valor3__c = opp.AV_Valor3__c;
						oppTaskToProcess.AV_Concepto3__c = opp.AV_Concepto3__c;
						oppTaskToProcess.AV_Valor4__c = opp.AV_Valor4__c;
						oppTaskToProcess.AV_Concepto4__c = opp.AV_Concepto4__c;
						oppTaskToProcess.AV_Valor5__c = opp.AV_Valor5__c;
						oppTaskToProcess.AV_Concepto5__c = opp.AV_Concepto5__c;
						oppTaskToProcess.AV_HoldingAnotherEntity__c = opp.AV_Tenencia__c;
						oppTaskToProcess.AV_Entity__c = opp.AV_Entidad__c;
						oppTaskToProcess.AV_DueDate__c = opp.CloseDate;
						oppTaskToProcess.AV_FeeAmount__c = opp.AV_Cuota__c;
						oppTaskToProcess.AV_Amount__c = opp.Amount;
						oppTaskToProcess.AV_TypeOfInterest__c = opp.AV_TipoInteres__c;
						oppTaskToProcess.AV_Commentary__c = opp.AV_Comentarios__c;
						oppTaskToProcess.AV_IncludeInPrioritizingCustomers__c = opp.AV_IncludeInPrioritizingCustomers__c;
						oppTaskToProcess.AV_FechaVencimiento__c = opp.AV_FechaVencimiento__c;
						oppTaskToProcess.AV_LicensePlate__c = opp.AV_LicensePlate__c;
						oppTaskToProcess.AV_AmountEuro__c = opp.AV_AmountEuro__c;
						oppTaskToProcess.AV_MarginEuro__c = opp.AV_MarginEuro__c;
						oppTaskToProcess.AV_ByProduct__c = opp.AV_ByProduct__c;
						oppTaskToProcess.AV_Resolucion__c = opp.AV_Resolucion__c;
						oppTaskToProcess.AV_Channel__c = opp.AV_Channel__c;
						if(mapByPass.containsKey(opp.AV_ExternalID__c)) {
							oppTaskToProcess.AV_OrigenApp__c = AV_AppConstants.CLIENT_REPORT_ORIGENAPP;
						} else {
							oppTaskToProcess.AV_OrigenApp__c = opp.AV_OrigenApp__c;
						}
						listOppTaskToProcess.add(oppTaskToProcess);
					}
				}
			}
			if(Schema.sObjectType.AV_CustomActivityOpportunity__c.isUpdateable()){
				Database.update(listOppTaskToProcess, false);
			}
		}
	}*/
	
	/**
	* @description     Procces owners of Opportunity where field EAP Gestor has changed
	* @param  listNews  list of new Opportunity records
	* @param mapOlds  map of old Opportunity records
	*/
	public static void processOwnerEAPGestor(List<Opportunity> listNews, Map<Id, Opportunity> mapOlds){
		Set<Id> gestorsIds = new Set<Id>();
		List<Opportunity> listOpp = new List<Opportunity>();
		List<Opportunity> listOppSinEap = new List<Opportunity>();
		//Comparamos los valores de los Gestores asociados antiguos y nuevos.
		//Si han cambiado el Gestor asociado lo añadimos a una lista para actualizar.
		if(mapOlds != null && !mapOlds.isEmpty()) {
			for(Opportunity opp : listNews) {
				if((setRtAll).contains(opp.RecordTypeId) && String.isNotBlank(opp.AV_Gestor__c) && opp.AV_Gestor__c != mapOlds.get(opp.Id).AV_Gestor__c){
					listOpp.add(opp);
					gestorsIds.add(opp.AV_Gestor__c);
				} else if((setRtAll).contains(opp.RecordTypeId) && String.isBlank(opp.AV_Gestor__c) && opp.AV_Gestor__c != mapOlds.get(opp.Id).AV_Gestor__c){
					listOppSinEap.add(opp);
				}
			}
		} else {
			for(Opportunity opp : listNews) {
				if((setRtAll).contains(opp.RecordTypeId) && String.isNotBlank(opp.AV_Gestor__c)){
					listOpp.add(opp);
					gestorsIds.add(opp.AV_Gestor__c);
				}
			}
		}
		if(listOppSinEap!=null && !listOppSinEap.isEmpty()){
			for(Opportunity opp : listOppSinEap){
                if(userGFC != null){
					opp.OwnerId = userGFC.Id;
                }
			}
		}
		if(gestorsIds!=null && !gestorsIds.isEmpty()) {
			Map<Id,Id> mapGestorUser = new Map<Id,Id>();
			//Obtenemos los Contactos que se han asociado nuevos a las Opp "cambio para".
			List<Contact> listEmployees= [Select Id, AV_UsuarioAsociado__c From Contact Where Id in :gestorsIds and AV_UsuarioAsociado__r.IsActive = true WITH SECURITY_ENFORCED];
			if(listEmployees.size() > 0 && listEmployees != null){
				for(Contact c : listEmployees){
					//Metemos en un mapa los Ids del Contado con su usuario Asociado
					mapGestorUser.put(c.Id, c.AV_UsuarioAsociado__c);
				}
			}
			//Recorremos todas las Oportunidad en las que se ha modificado en Gestor y actualizamos en OwnerId.
			for(Opportunity opp : listOpp){
				if(mapGestorUser.get(opp.AV_Gestor__c) != null) {
					opp.OwnerId = mapGestorUser.get(opp.AV_Gestor__c);
				} else {
					opp.OwnerId = userGFC.Id;
				}
			}
		}
	}
	
	/**
	* @description     Procces owners of Opportunity where create a Opportunity type Iniciativa so fill the fields and send to API Oppotunity
	* @param  listNews  list of new Opportunity records
	*/
	public static void sendDataToGCF(List<Opportunity> listNews, String origen,  Map<String, Opportunity> mapByPass){
		List<Opportunity> listOpps = new List<Opportunity>();
		String bigdot = AV_AppConstants.BIGDOT;
		Boolean hasBulkApi = FeatureManagement.checkPermission('AV_AvoidBulkApi');
		if(!hasBulkApi && !System.isFuture() && !System.isBatch() && listNews!=null && !listNews.isEmpty()){
			for(Opportunity opp: listNews){
				if(setRtIniciativa.contains(opp.RecordTypeId) && !mapByPass.containsKey(opp.AV_ExternalID__c) && ((opp.AV_ExternalID__c != null && !opp.AV_ExternalID__c.contains(bigdot)) || opp.AV_ExternalID__c == null)){
					//Fix segunda llamada a GCF
					DateTime dtNow = Datetime.now();
					DateTime createdDateOpp = opp.CreatedDate.addSeconds(12);
					if((dtNow <= createdDateOpp && !origen.equals('AU')) || (createdDateOpp < dtNow && origen.equals('AU'))){
					listOpps.add(opp);
				}
			}
			}
			if(listOpps!=null && !listOpps.isEmpty()){
				String jsonString = json.serialize(listOpps);
				AV_SetFieldsAPIOpp_SyncOpportunity.sendToGCF(jsonString);
			}
		}
	}
	
	/**
	* @description    Opportunities that have the modified Telephone Contracting fields must create an event in GCF
	* @param  listNews  list of new Opportunity records
	* @param mapOlds  map of old Opportunity records
	*/
	public static void telephoneContracting(List<Opportunity> listNews,  Map<Id, Opportunity> mapOlds){
		List<Opportunity> listOpps = new List<Opportunity>();
		Boolean hasBulkApi = FeatureManagement.checkPermission('AV_AvoidBulkApi');
		if(!hasBulkApi && !System.isFuture() && !System.isBatch()){
			if(mapOlds != null && !mapOlds.isEmpty()) {
				for(Opportunity opp : listNews) {
					if((setRtAll).contains(opp.RecordTypeId) && opp.AV_ModificacionTelefonica__c
					   && !mapOlds.get(opp.Id).AV_ModificacionTelefonica__c){
						   listOpps.add(opp);
					   }
				}
			}else{
				for(Opportunity opp : listNews) {
					if((setRtAll).contains(opp.RecordTypeId) && opp.AV_ModificacionTelefonica__c){
						listOpps.add(opp);
					}
				}
			}
			if (listOpps!=null && !listOpps.isEmpty()) {
				String jsonString = json.serialize(listOpps);
				AV_CitaPrevia_SyncEvents.insertEventTelephoneContracting(jsonString);
			}
		}
	}
	
	/**
	* @description     Validate Opportunities to delete when Opportunity RT Iniciativa 
	* @param  listOlds  list of old Opportunity records
	*/
	public static void validateDeleteOpportunity(List<Opportunity> listOlds){
		Map<Id, Opportunity> mapOpps = new Map<Id, Opportunity>();
		for (Opportunity opp : listOlds){
			if ((setRtIniciativa).contains(opp.RecordTypeId) && opp.Id!=null){
				mapOpps.put(opp.Id, opp);
			}
		}
		//Get the list of task-opp related with the opps
		List<AV_CustomActivityOpportunity__c> listTaskAndOpp = [Select Id, AV_Opportunity__c from AV_CustomActivityOpportunity__c where AV_Opportunity__c in :mapOpps.keySet() WITH SECURITY_ENFORCED];
		//Set of the id's opp included in Task-Opp object
		Set<Id> taskOppIdsOpp = new Set<Id>();
		for (AV_CustomActivityOpportunity__c cao : listTaskAndOpp){
			if (cao.AV_Opportunity__c!=null){
				taskOppIdsOpp.add(cao.AV_Opportunity__c);
			}
		}
		if(!mapOpps.isEmpty()){
			for(Id oppId : mapOpps.keySet()){
				if(!taskOppIdsOpp.isEmpty() && taskOppIdsOpp.contains(oppId)){
					Opportunity opp = mapOpps.get(oppId);
					opp.addError(ERROR_MESSAGE);
				}
			}
		}
	}
	
	/**
	* @description     Validate Opportunities to exist only one with a PF 
	* @param  listNew   list of Opportunity to create
	*/
	public static void validatePF(List<Opportunity> listNew){
		String bigdot = AV_AppConstants.BIGDOT;

		Set<String> openStatusInitiativeRT = new Set<String>{
			AV_AppConstants.OPP_STATUS_POTENCIAL, 
			AV_AppConstants.OPP_STATUS_ENGESTION,
			AV_AppConstants.OPP_STATUS_VENCIDO,
			AV_AppConstants.OPP_STATUS_NO_GESTIONADA
		};

		Set<String> closedStatusInitiativeRT = new Set<String>{
			AV_AppConstants.OPP_STATUS_ENESPERA,
			AV_AppConstants.OPP_STATUS_CERRPOST,
			AV_AppConstants.OPP_STATUS_CERRNEG,
			AV_AppConstants.OPP_STATUS_NOINTERE,
			AV_AppConstants.OPP_STATUS_CONVENTA,
			AV_AppConstants.OPP_STATUS_PROD_CONTR,
			AV_AppConstants.OPP_STATUS_PROD_RECH
		};

		Set<String> openStatusOtherRT = new Set<String>{
			AV_AppConstants.OPP_STATUS_POTENCIAL, 
			AV_AppConstants.OPP_STATUS_ENGESTION
		};

		Set<String> rts = new Set<String>{
			AV_AppConstants.OPPALERTACOM_RT, 
			AV_AppConstants.OPPPROPUESTA_RT,
			AV_AppConstants.OPPSUGERENCIA_RT, 
			AV_AppConstants.OPPINICIATIVA_RT,
			AV_AppConstants.OPPLLAMADA_RT
		};

		Set<String> allStatus = new Set<String>();
		allStatus.addAll(openStatusInitiativeRT);
		allStatus.addAll(closedStatusInitiativeRT);
		

		Boolean hasBulkApi = FeatureManagement.checkPermission('AV_AvoidBulkApi');
		if(!hasBulkApi){
			Map<Id, String> mapAccProd = new Map<Id, String>();
			Map<String, Opportunity> mapNew = new Map<String, Opportunity>();
			Set<String> setPF = new Set<String>();
			for(Opportunity opp : listNew){
				if(String.isNotBlank(opp.AV_PF__c)){
					setPF.add(opp.AV_PF__c);
					mapAccProd.put(opp.AccountId, opp.AV_PF__c);
					String oppOk = string.valueOf(opp.AV_PF__c) + string.valueOf(opp.AccountId);
					mapNew.put(oppOk, opp);
				}
			}
			if(setPF!=null && !setPF.isEmpty()){
				List<Opportunity> listOpp = [SELECT Id, AV_PF__c, AccountId,  SystemModStamp, AV_ExternalID__c, RecordType.DeveloperName, StageName FROM Opportunity WHERE AV_PF__c IN :setPF AND AccountId IN :mapAccProd.keySet() AND (StageName  IN :allStatus AND RecordType.DeveloperName IN :rts) WITH SECURITY_ENFORCED]; 
				if(listOpp!=null && !listOpp.isEmpty()){
					Map<String,List<Opportunity>> accProdListOpp = new Map<String,List<Opportunity>>();
					for(Opportunity oppToCheck : listOpp){
						String newKey = string.valueOf(oppToCheck.AV_PF__c) + string.valueOf(oppToCheck.AccountId);
						if(!accProdListOpp.keySet().contains(newKey)){
							accProdListOpp.put(newKey,new List<Opportunity>{oppToCheck});
						}else{
							accProdListOpp.get(newkey).add(oppToCheck);
						}
					}
					List<Opportunity> listOpportunity = new List<Opportunity>();
					for(Opportunity opp : listOpp){
						if(closedStatusInitiativeRT.contains(opp.stageName) && opp.RecordType.DeveloperName == AV_AppConstants.OPPINICIATIVA_RT){
							String oppVigente = string.valueOf(opp.AV_PF__c) + string.valueOf(opp.AccountId);
							Opportunity opportunityNew = mapNew.get(oppVigente);
							if(opportunityNew != null){
								String stringSystemModStamp = string.valueOfGmt(opp.SystemModStamp);				
								for(Opportunity existentOppo : accProdListOpp.get(oppVigente)){								
									if(opp.AV_ExternalID__c != null && !opp.AV_ExternalID__c.contains(bigdot)){
										opportunityNew.AV_ExternalID__c = opp.AV_ExternalID__c;
										opp.AV_ExternalID__c =  opp.AV_ExternalID__c + bigdot + stringSystemModStamp; 
										listOpportunity.add(opp);
										break;
									} else if (opp.AV_ExternalID__c != null && opp.AV_ExternalID__c.contains(bigdot)) {
										opportunityNew.AV_ExternalID__c = opp.AV_ExternalID__c.split(bigdot)[0];
									}
								}
							}
						}
						else{
							String idProd = mapAccProd.get(opp.AccountId);
							if (String.isNotBlank(idProd)){
								for(Opportunity newOpp : listNew){
									if (newOpp.AV_PF__c != null && opp.AV_PF__c != null && newOpp.AV_PF__c == opp.AV_PF__c  && newOpp.AccountId != null && opp.AccountId != null && newOpp.AccountId == opp.AccountId && setRtIniciativa.contains(newOpp.RecordTypeId)/*newOpp.RecordTypeId.equals(iniciativa.Id)*/ && opp.RecordTypeId != newOpp.RecordTypeId &&  openStatusOtherRT.contains(opp.stageName)){
                                        newOpp.addError(ERROR_MESSAGE_PF);
                                    }
                                    if (newOpp.AV_PF__c != null && opp.AV_PF__c != null && newOpp.AV_PF__c == opp.AV_PF__c  && newOpp.AccountId != null && opp.AccountId != null && newOpp.AccountId == opp.AccountId && setRtIniciativa.contains(newOpp.RecordTypeId) /*newOpp.RecordTypeId.equals(iniciativa.Id)*/ && opp.RecordTypeId == newOpp.RecordTypeId &&  openStatusInitiativeRT.contains(opp.stageName)){
                                        newOpp.addError(ERROR_MESSAGE_PF);
                                    }
								}
							}
						}
					}
					if(!listOpportunity.isEmpty()){
						if(Schema.sObjectType.Opportunity.isUpdateable()){
							update listOpportunity;
						}
					}
				}
			}
		}
	}

	/**
	* @description     Create a Opportunity if Opportunity has AV_Comentarios__c
	* @param  listNews  list of new Opportunity records
	* @param  mapOlds   map of old Opportunity records
	*/
	public static void createOpportunityComentarios(List<Opportunity> listNews, Map<Id, Opportunity> mapOlds) {
		List<Opportunity> lstToProcess = new List<Opportunity>();
		if(mapOlds == null) {
			for(Opportunity opp : listNews) {
				if(String.isNotBlank(opp.AV_Comentarios__c)) {
					lstToProcess.add(opp);
				}
			}
		} else {
			for(Opportunity opp : listNews) {
				if(String.isNotBlank(opp.AV_Comentarios__c) && opp.AV_Comentarios__c != mapOlds.get(opp.Id).AV_Comentarios__c) {
					lstToProcess.add(opp);
				}
			}
		}
		if(!lstToProcess.isEmpty()) {
			User currentUser  = [Select Name, AV_NumeroOficinaEmpresa__c From User Where Id = :UserInfo.getUserId() WITH SECURITY_ENFORCED Limit 1];
			String employeeInfo = currentUser.Name;
			if(String.isNotBlank(currentUser.AV_NumeroOficinaEmpresa__c) && currentUser.AV_NumeroOficinaEmpresa__c.contains('-')) {
				employeeInfo += ' (ofi ' + currentUser.AV_NumeroOficinaEmpresa__c.split('-').get(1) + ')';
			}
			for (Opportunity opp : lstToProcess){
				opp.AV_CommentLastModifiedBy__c = employeeInfo;
				opp.AV_CommentLastModifiedDate__c = System.now();
			}
		}
	}
	
	/**
	* @description     Create a Opportunity if Opportunity has AV_NumeroDocumento__c
	* @param  listNews  list of new Opportunity records
	* @param  mapOlds   map of old Opportunity records
	*/
	public static void opportunityValueNumeroDocumento(List<Opportunity> listNews) {
		List<Opportunity> lstToProcess = new List<Opportunity>();
		Map<Id,Opportunity> mapAccOpp = new Map<Id,Opportunity>();
		for(Opportunity opp : listNews) {
			lstToProcess.add(opp);
			mapAccOpp.put(opp.AccountId, opp);
		}
		if(!lstToProcess.isEmpty()) {
			List<Account> listAcc = [Select Id, CC_Numero_Documento__c From Account Where Id = :mapAccOpp.keySet() WITH SECURITY_ENFORCED];
			Map<Id, Account> mapAcc = new Map<Id,Account>(listAcc);
			for(Opportunity opp : lstToProcess){
				if(mapAcc.containsKey(opp.AccountId)) {
					opp.AV_NumeroDocumento__c = mapAcc.get(opp.AccountId).CC_Numero_Documento__c;
				}
			}
		}
	}
	
	/**
	* @description     Fill the AV_ClientProduct__c field
	* @param  listNews  list of new Opportunity records
	*/
	public static void fillClientProduct(List<Opportunity> listNews) {
		Map<String, Opportunity> mapToProcess = new Map<String, Opportunity>();
		Set<String> setAccIds = new Set<String>();
		Set<String> setPFIds = new Set<String>();
		for(Opportunity opp : listNews) {
			if(opp.AV_PF__c != null && opp.AccountId != null && opp.AV_ClientProduct__c == null) {
				String mapKey = opp.AccountId + '-' + opp.AV_PF__c;
				mapToProcess.put(mapKey, opp);
				setAccIds.add(opp.AccountId);
				setPFIds.add(opp.AV_PF__c);
			}
		}
		if(!mapToProcess.values().isEmpty() && mapToProcess != null) {
			Map<String, String> mapClientProds = new Map<String, String>();
			List<AV_ProductClient__c> listClientProds = [Select Id, AV_Cliente__c, AV_ProductoFicha__r.AV_ProductoFicha__c from AV_ProductClient__c where AV_Cliente__c in :setAccIds and AV_ProductoFicha__r.AV_ProductoFicha__c = :setPFIds WITH SECURITY_ENFORCED];
			for(AV_ProductClient__c pc : listClientProds) {
				String mapKey = pc.AV_Cliente__c + '-' + pc.AV_ProductoFicha__r.AV_ProductoFicha__c;
				mapClientProds.put(mapKey, pc.Id);
			}
			for(String prodKey: mapToProcess.keySet()) {
				if(mapClientProds.containsKey(prodKey)) {
					mapToProcess.get(prodKey).AV_ClientProduct__c = mapClientProds.get(prodKey);
				}
			}
		}
	}
	
	/**
	* @description   This method create the task associate from the opportunity
	* @param opp retrieve opp
	* @param activityDate field date for task
	* @param rt retrieve record type Iniciativa
	* @param mapGestores map gestores
	* @param listProduct retrieve list products
	*/
	private static Task createTareaWithCheckClient(Opportunity opp, Date activityDate, Id rt, Map<Id, Contact> mapGestores, Map<String, Product2> mapProduct) {
		Task tarea = new Task();
		dateExternalId = DateTime.now();
		if(String.isNotBlank(opp.AV_ExternalID__c)){
			tarea.AV_ExternalID__c = SUFFIX_EXTERNALID + opp.AV_ExternalID__c + dateExternalId;
		}else{
			tarea.AV_ExternalID__c = SUFFIX_EXTERNALID + opp.Id + dateExternalId;
		}
		tarea.ActivityDate = activityDate;
		if(String.isNotBlank(opp.AccountId)){
			tarea.WhatId = opp.AccountId;
		}
		String updateNewFormateDate = activityDate.format();
		Product2 p2 = mapProduct.get(opp.AV_PF__c);
		if (p2!=null){
			tarea.Subject = updateNewFormateDate + ' - ' + p2.Name;
		}else{
			tarea.Subject = updateNewFormateDate;
		}
		tarea.Status = 'Open';
		tarea.Priority = 'A';
		tarea.RecordTypeId = rt;
		tarea.AV_OrigenApp__c = 'AV_SalesforceTaskOpp';
		tarea.OwnerId = UserInfo.getUserId();
		tarea.AV_Center__c = opp.AV_Center__c;
		return tarea;
	}
	
	/**
	* @description     This method is used to fill in fields of the opportunity at the time of creation
	* @param  listNews  list of new Opportunity records
	*/
	public static void fillFieldsFromOpp(List<Opportunity> listNews ){
		Date createdFormatDate = system.today();
		for(Opportunity opp: listNews){
			opp.AV_FechaAlta__c = createdFormatDate;
		}
	}
	
	/**
	* @description     This method is used to update fields of the opportunity
	* @param  listNews  list of new Opportunity records
	* @param  mapOldObj  map of old oppotunities 
	* @param  isUpdate  field that indicates if the opportunity is an insert or an update
	*/
	public static void saveFieldsFromOpp(List<Opportunity> listNews, Map<Id, Opportunity> mapOldObj, Boolean isUpdate){
		Map<Id, List<Opportunity>> mapOppOwners = new Map<Id, List<Opportunity>>();
		Set<String> updatedFields=new Set<String>();
		if (isUpdate) {
			updatedFields = checkUserFields(listNews, mapOldObj);
		}
		for(Opportunity opp : listNews) {
			if(mapOppOwners.containsKey(opp.OwnerId)) {
				mapOppOwners.get(opp.OwnerId).add(opp);
			} else {
				mapOppOwners.put(opp.OwnerId, new List<Opportunity>{opp});
			}
		}
		if(!mapOppOwners.containsKey(UserInfo.getUserId())){ 
			mapOppOwners.put(UserInfo.getUserId(), new List<Opportunity>());
		}
		List<Contact> listCont= [Select id, lastmodifieddate, AV_UsuarioAsociado__c From Contact Where AV_UsuarioAsociado__c in :mapOppOwners.keySet() and RecordType.DeveloperName = 'CC_Empleado' WITH SECURITY_ENFORCED];
		Id idContactUser=null;
		for (Contact cont1 : listCont) {
			if(cont1.AV_UsuarioAsociado__c!=null && cont1.AV_UsuarioAsociado__c == UserInfo.getUserId()){
				idContactUser= cont1.id ;
			}
		}  
		List<Contact> currentUserContact = [SELECT ID FROM CONTACT WHERE AV_UsuarioAsociado__c = :UserInfo.getUserId() WITH SECURITY_ENFORCED LIMIT 1];
		for(Contact cont : listCont) {
			if(mapOppOwners.containsKey(cont.AV_UsuarioAsociado__c)) {
				for(Opportunity oppToProcess : listNews) {
					Datetime currentD = (Datetime) System.now();
					Date dt = date.newinstance(currentD.year(), currentD.month(), currentD.day());
					if (isUpdate) { 
						if (!((updatedFields.contains('AV_Center__c') && updatedFields.size() == 1) || (updatedFields.contains('AV_Gestor__c') && updatedFields.size() == 1) || (updatedFields.contains('OwnerId') && updatedFields.size() == 1) || (updatedFields.contains('Name') && updatedFields.size() == 1) || 
						(updatedFields.contains('AV_Center__c') && updatedFields.contains('AV_Gestor__c') && updatedFields.contains('OwnerId') && updatedFields.contains('Name') && updatedFields.size() == 4) || (updatedFields.contains('AV_Gestor__c') && updatedFields.contains('OwnerId') && updatedFields.contains('Name') && updatedFields.size() == 3) ||
						(updatedFields.contains('AV_Center__c') && updatedFields.contains('OwnerId') && updatedFields.contains('Name') && updatedFields.size() == 3) ||
						(updatedFields.contains('AV_Center__c') && updatedFields.contains('AV_Gestor__c') && updatedFields.contains('Name') && updatedFields.size() == 3) ||
						(updatedFields.contains('AV_Center__c') && updatedFields.contains('AV_Gestor__c') && updatedFields.contains('OwnerId') && updatedFields.size() == 3) ||
						(updatedFields.contains('OwnerId') && updatedFields.contains('Name') && updatedFields.size() == 2) ||
						(updatedFields.contains('AV_Gestor__c') && updatedFields.contains('Name') && updatedFields.size() == 2) ||
						(updatedFields.contains('AV_Center__c') && updatedFields.contains('Name') && updatedFields.size() == 2) ||
						(updatedFields.contains('AV_Gestor__c') && updatedFields.contains('OwnerId') && updatedFields.size() == 2) ||
						(updatedFields.contains('AV_Center__c') && updatedFields.contains('OwnerId') && updatedFields.size() == 2) ||
						(updatedFields.contains('AV_Center__c') && updatedFields.contains('AV_Gestor__c') && updatedFields.size() == 2)
						) && updatedFields.size() != 0 && !System.isFuture()) {
							oppToProcess.AV_FechaModificacion__c = dt;
							if(!currentUserContact.isEmpty()){
								oppToProcess.AV_EmpleadoModificacion__c = currentUserContact[0].Id;
							}
						}
					}
					if(!isUpdate){
						oppToProcess.AV_FechaAlta__c = dt;
						oppToProcess.AV_EmpleadoAlta__c = idContactUser;
						if(setRtIniciativa.contains(oppToProcess.RecordTypeId)) {
							oppToProcess.AV_FechaModificacion__c = dt;   
							if(!currentUserContact.isEmpty()){
								oppToProcess.AV_EmpleadoModificacion__c = currentUserContact[0].Id;
							}
						}
					}
				}
			}
		}
	}

	
	/**
	* @description     Change AV_Gestor__c when change OwnerId
	* @param  listNews  list of new Opportunity records
	* @param  mapOlds   map of old Opportunity records
	*/
	public static void changeOwner(List<Opportunity> listNews, Map<Id, Opportunity> mapOlds) {
		List<Opportunity> listToProcess= new List<Opportunity>();
		List<String> listOwners= new List<String>();
		if(mapOlds == null) { 
			for(Opportunity opp : listNews) {
                if(String.isNotBlank(opp.OwnerId)){
                    listOwners.add(opp.OwnerId);
					listToProcess.add(opp);
                }
			}
		} else {
			for(Opportunity opp : listNews) {
				if(String.isNotBlank(opp.OwnerId) && opp.OwnerId != mapOlds.get(opp.Id).OwnerId) {
					listOwners.add(opp.OwnerId);
					listToProcess.add(opp);
				}
			}
		}
		if(listOwners != null && listToProcess != null && !listOwners.isEmpty() && !listToProcess.isEmpty()) {
			Contact contNoUsuarioAsociado = null;
			List<Contact> contSinGestorEAP=[Select Id from Contact Where AV_UsuarioAsociado__c = :userGFC.Id WITH SECURITY_ENFORCED limit 1];
			List<User> userOwner = [Select AV_ExternalID__c from User where id =: listOwners[0] WITH SECURITY_ENFORCED limit 1];
			if (userOwner != null && !userOwner.isEmpty() && userOwner[0].AV_ExternalID__c != null) {
				List<Contact> contactEmployeeNumber = [Select Id from Contact Where CC_Matricula__c =:userOwner[0].AV_ExternalID__c WITH SECURITY_ENFORCED limit 1];
				if(contactEmployeeNumber != null && !contactEmployeeNumber.isEmpty()){
					contNoUsuarioAsociado = contactEmployeeNumber[0];
				}else{
					if(contSinGestorEAP != null && !contSinGestorEAP.isEmpty()) {
						contNoUsuarioAsociado = contSinGestorEAP[0];
					}
				}
			}else {
				if(contSinGestorEAP != null && !contSinGestorEAP.isEmpty()) {
					contNoUsuarioAsociado = contSinGestorEAP[0];
				}
			}
			List<Contact> listCont= [Select Id, lastmodifieddate, AV_UsuarioAsociado__c From Contact Where AV_UsuarioAsociado__c in :listOwners WITH SECURITY_ENFORCED];
			if (listCont!= null && !listCont.isEmpty()) {
				Map<String,String> mapUserContact = new Map<String,String>();
				for (Contact con: listCont) {
					mapUserContact.put(con.AV_UsuarioAsociado__c,con.Id);
				}
				for(Opportunity opp: listToProcess) {
					if (mapUserContact.get(opp.OwnerId) != null) {
						opp.AV_Gestor__c = mapUserContact.get(opp.OwnerId);
					}else {
						opp.OwnerId = userGFC.Id;
						if (contSinGestorEAP != null && !contSinGestorEAP.isEmpty()) {
							opp.AV_Gestor__c = contSinGestorEAP[0].Id;
						}
					}
				}
			} else {
				for(Opportunity opp: listToProcess) {
					opp.OwnerId = userGFC.Id;
					if (contSinGestorEAP != null && !contSinGestorEAP.isEmpty()) {
						opp.AV_Gestor__c = contNoUsuarioAsociado.id;
					}
				}
			}
		}
	}
	
	/**
	* @description     	Returns a set containing all the fields that are accessible to the user and have been modified.
	* @param  listNew  list of new Opportunity records
	* @param  mapOld   map of old Opportunity records.
	*/
	public static Set<String> checkUserFields(List<Opportunity> listNew, Map<Id, Opportunity> mapOld) {
		SObjectAccessDecision decision = Security.stripInaccessible(AccessType.UPSERTABLE, listNew);
		Map<String, Object> m = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(decision.getRecords().get(0)));
		Set<String> updatedFields = new Set<String>();
		for (Integer i = 0; i < listNew.size(); i++) {
			for (String field : m.keySet()) {
				if ('attributes'.equals(field)) {
					continue;
				}
				if (listNew.get(i).get(field) != mapOld.get(listNew.get(i).Id).get(field)) {
					updatedFields.add(field);
				}
			}
		}
		return updatedFields;
	}
		
	/**
	* @description     	Updates opp's confidentiality according to its related account.
	* @param  listNew  list of new Opportunity records
	* @param  isInsert   boolean to be insert
	*/
	public static void setConfidentiality(List<Opportunity> listNew, Boolean isInsert) {
		Set<Id> cliIds = new Set<Id>();
		Map<Id, Boolean> cliConfidentiality = new Map<Id, Boolean>();
		Map<Id, Boolean> cliEmployee = new Map<Id, Boolean>();
		for (Opportunity opp : listNew) {
			cliIds.add(opp.AccountId);
		}
		List<Account> clients = [Select Id, AV_Confidencial__c, AV_Empleado__c From Account Where Id in :cliIds WITH SECURITY_ENFORCED];
		if (!clients.isEmpty()) {
			for (Account client : clients) {
				cliConfidentiality.put(client.Id, client.AV_Confidencial__c);
				cliEmployee.put(client.Id, client.AV_Empleado__c);
			}
			if (isInsert) {
				for (Opportunity opp : listNew) {
					if(opp.AccountId!=null){
						opp.AV_ClienteConfidencial__c = cliConfidentiality.get(opp.AccountId);
						opp.AV_EmployeeCustomer__c = cliEmployee.get(opp.AccountId);
					}
				}
			} else {
				for (Opportunity opp : listNew) {
					if(opp.AccountId!=null){
						if ((opp.AV_ClienteConfidencial__c != cliConfidentiality.get(opp.AccountId)) || (opp.AV_EmployeeCustomer__c != cliEmployee.get(opp.AccountId))) {
							opp.AV_ClienteConfidencial__c = cliConfidentiality.get(opp.AccountId);
							opp.AV_EmployeeCustomer__c = cliEmployee.get(opp.AccountId);
						}
					}
				}
			}
		}
	}

	/**
	* @description     	Enter the date when an Oppo pass from Stage 'Potencial' to any other but 'Vencido'. In that case the field will remain blank.
	* @param  listOpp  list of new Opportunity records
	* @param  mapOldObj   map of old Opportunity records.
	*/
	public static void updateFechaActivacion(List<Opportunity> listOpp, Map<Id, Opportunity> mapOldObj){
		for(Opportunity opp : listOpp){
			String newStage = opp.StageName;
			String oldStage = mapOldObj.get(opp.Id).StageName;
			if(oldStage!= newStage){
				if(oldStage == 'Potencial' && newStage!='Vencido' && newStage != AV_AppConstants.OPP_STATUS_NO_GESTIONADA ){
					opp.AV_FechaActivacion__c= System.today();
				}
			}
		}
	}

	/**
	* @description     	Update the field AV_Center when the owner of an opportunity iniciativaGestor is updated.If the new owner is no SalesForce User, the field will remain blank.
	* @param  listOpp  list of new Opportunity records
	* @param  mapOldObj   map of old Opportunity records.
	*/
	public static void updateCentro(List<Opportunity> listOpp, Map<Id, Opportunity> mapOldObj){
		Map<Id,String> mapOwnerOffice = new Map<Id,String>();
		Set<Id> owners = new Set<Id>();
		List<Opportunity> oppToProcess = new List<Opportunity>();
		String offiNumber='';
		if(mapOldObj != null && !mapOldObj.isEmpty()){//Updating existint opp
			for(Opportunity opp : listOpp){
				if(opp.OwnerId != mapOldObj.get(opp.Id).OwnerId){
					owners.add(opp.OwnerId);
					oppToProcess.add(opp);        
				}      
			}
		} else{
			for(Opportunity opp : listOpp){
				if(setRtIniciativa.contains(opp.RecordTypeId) || setRtAlerta.contains(opp.RecordTypeId)){
					owners.add(opp.OwnerId);
					oppToProcess.add(opp);        
				}      
			}
		}
		if (owners != null && oppToProcess != null) {

			List<User> ownerOffice = [SELECT ID,AV_NumeroOficinaEmpresa__c FROM USER WHERE ID in :owners WITH SECURITY_ENFORCED];

			for(User owner : ownerOffice) {
				mapOwnerOffice.put(owner.Id,owner.AV_NumeroOficinaEmpresa__c);
			}
			for(Opportunity opp : oppToProcess){

				if(opp.OwnerId != userGFC.Id){

					offiNumber= mapOwnerOffice.get(opp.OwnerId);
					if (offiNumber != null) {
						opp.AV_Center__c = offiNumber.substring(offiNumber.length()-5);
					}
				}
			}
		}  
	}

	/**
	* @description     	Validation to GCF
	* @param  listNews  list of new Opportunity records
	* @param  mapOldObj   map of old Opportunity records
	*/
	public static void updateGCF(List<Opportunity> listOpp, Map<Id, Opportunity> mapOldObj){ 	
		if (UserInfo.getUserId() == userGFC.id) {
			if(mapOldObj != null){
				for(Opportunity opp : listOpp) {
					if(opp.AV_OrigenApp__c != AV_AppConstants.OPP_ORIGEN_UPDATE_WALLET && opp.AV_OrigenApp__c != AV_AppConstants.DATAPIPELINES_ORIGENAPP){
						Opportunity oldOpp = mapOldObj.get(opp.Id);
						//Si te llega el toDelete a true y la fecha de actualización está rellena -->  pongo el toDelete a lo previo 
						if (opp.AV_FechaModificacion__c != null && oldOpp.AV_ToDelete__c != opp.AV_ToDelete__c && opp.AV_ToDelete__c == true) { 
							opp.AV_ToDelete__c = oldOpp.AV_ToDelete__c;
						}
						//Si estaba en etapa Cerrada positiva, Producto rechazado, cerrada negativa o Producto Contratado y no pasa a Con Venta llegando una modificación de etapa, fecha de próxima gestión o comentario --> pongo etapa, fecha de próxima gestión y comentario lo previo y dejo pasar el resto de campos 
						//Si estaba en etapa Con venta y no pasa a Cerrado Negativo o Producto Rechazado llegando una modificación de etapa, fecha de próxima gestión o comentario --> pongo etapa, fecha de próxima gestión y comentario lo previo y dejo pasar el resto de campos
						//Si estaba en etapa En gestión/insistir y pasa a Potencial llegando una modificación de etapa, fecha de próxima gestión o comentario -->  pongo fecha de próxima gestión y comentario lo previo y dejo pasar el resto de campos 
						if ((oldOpp.AV_Comentarios__c != opp.AV_Comentarios__c || oldOpp.AV_FechaProximoRecordatorio__c != opp.AV_FechaProximoRecordatorio__c || oldOpp.StageName != opp.StageName) && (((oldOpp.StageName == AV_AppConstants.OPP_STATUS_CERRPOST || oldOpp.StageName == AV_AppConstants.OPP_STATUS_PROD_RECH || oldOpp.StageName == AV_AppConstants.OPP_STATUS_NOINTERE || oldOpp.StageName == AV_AppConstants.OPP_STATUS_PROD_CONTR) && opp.StageName != AV_AppConstants.OPP_STATUS_CONVENTA) || (oldOpp.StageName == AV_AppConstants.OPP_STATUS_CONVENTA && (opp.StageName != AV_AppConstants.OPP_STATUS_NOINTERE && opp.StageName != AV_AppConstants.OPP_STATUS_PROD_RECH) ) || (oldOpp.StageName == AV_AppConstants.OPP_STATUS_ENGESTION && opp.StageName == AV_AppConstants.OPP_STATUS_POTENCIAL))) { 
							opp.StageName = oldOpp.StageName;
							opp.AV_Comentarios__c = oldOpp.AV_Comentarios__c;
							opp.AV_FechaProximoRecordatorio__c = oldOpp.AV_FechaProximoRecordatorio__c;
						} 
						//Si llega un cambio de centro o empleado y la fecha de actualización está rellena --> pongo centro o empleado previo y dejo pasar el resto de cambios 
						if ((oldOpp.AV_Center__c != opp.AV_Center__c || oldOpp.AV_Gestor__c != opp.AV_Gestor__c) && opp.AV_FechaModificacion__c != null) { 
							opp.AV_Center__c = oldOpp.AV_Center__c;
							opp.AV_Gestor__c = oldOpp.AV_Gestor__c;
						}

						if((oldOpp.CloseDate) != opp.CloseDate && oldOpp.StageName != AV_AppConstants.OPP_STATUS_POTENCIAL){
							opp.CloseDate = oldOpp.CloseDate;
						}
					}
				}
			}
		}
	}

	/**
	* @description      Cambio Owner SinGestor
	* @param  listNews  list of new Opportunity records
	* @param  mapOldObj map of old Opportunity records
	*/
	public static void updateSinGestor(List<Opportunity> listOpp, Map<Id, Opportunity> mapOldObj){

		for(Opportunity opp :listOpp){
			if((opp.StageName == AV_AppConstants.OPP_STATUS_ENGESTION ||opp.StageName == AV_AppConstants.OPP_STATUS_CERRPOST || opp.StageName == AV_AppConstants.OPP_STATUS_CERRNEG ||opp.StageName == AV_AppConstants.OPP_STATUS_PROD_RECH || opp.StageName == AV_AppConstants.OPP_STATUS_PROD_CONTR) && opp.StageName != mapOldObj.get(opp.Id).StageName && opp.OwnerId == userGFC.Id){
				opp.OwnerId = UserInfo.getUserId();
			} else if(opp.StageName == AV_AppConstants.OPP_STATUS_CONVENTA && opp.StageName != mapOldObj.get(opp.Id).StageName && opp.AV_AssignedManagerSales__c != null && opp.OwnerId == userGFC.Id &&  opp.AV_AssignedManagerSales__c != opp.AV_Gestor__c){
				opp.AV_Gestor__c = opp.AV_AssignedManagerSales__c;     
			}
		}
	}

	/**
	* @description     	if AV_FechaProximoRecordatorio__c is changed and StageName is 'Potencial', the field StageName changes to 'Gestion e insistir'
	* @param  listOpp  list of new Opportunities
	* @param  mapOldObj  list of old Opportunities
	*/
	public static void updateStageName(List<Opportunity> listOpp, Map<Id, Opportunity> mapOldObj){
		for(Opportunity opp: listOpp){
			if(opp.StageName == AV_AppConstants.OPP_STATUS_POTENCIAL){
				if(opp.AV_FechaProximoRecordatorio__c != mapOldObj.get(opp.Id).AV_FechaProximoRecordatorio__c){
					opp.StageName=AV_AppConstants.OPP_STATUS_ENGESTION;
				}
			}
		}
	}

	/**
	* @description     Create a Task associated with a Opportunity Call Me
	* @param  listOpp  list of new Opportunities
	* @param  mapOldObj  list of old Opportunities
	*/
	public static void createTaskCallMe(List<Opportunity> listOpp, Map<Id, Opportunity> mapOldObj) {
		List<Opportunity> oppToCreateTaskList = new List<Opportunity>();
		Set<Id> ownerOppsIds = new Set<Id>();
		for(Opportunity opp : listOpp){
			//SI LA OPP TIENE ESTADO POTENCIAL Y SE HA ACTUALIZADO EL OWNER, SE CAMBIA EL ESTADO A 'EN GESTIÓN/INSISTIR' Y SE CREARÁ UNA TAREA ALERTA COMERCIAL
			if(opp.StageName == AV_AppConstants.OPP_STATUS_POTENCIAL && opp.OwnerId != mapOldObj.get(opp.Id).OwnerId){ 
				opp.StageName = AV_AppConstants.OPP_STATUS_ENGESTION;
				oppToCreateTaskList.add(opp);
				ownerOppsIds.add(opp.OwnerId);
			}
		}
		if(oppToCreateTaskList != null && !oppToCreateTaskList.isEmpty()){
			Id rtTask = (new List<Id>(setRtTaskAlerta)).get(0);
			Date activityDate = date.today() + 5;
			List<Task> taskToInsertList = new List<Task>();
			Map<Id, String> oppIdTaskExternalIdMap = new Map<Id, String>();
			Map<Id,User> userMap = new Map<Id,User>([SELECT Id, AV_NumeroOficinaEmpresa__c FROM User WHERE Id IN: ownerOppsIds]);
			List<AV_PilotCenters__c> listAvPilotCenters = AV_PilotCenters__c.getall().values();
			List<String> officeNumbers = new List<String>();
			if(listAvPilotCenters != null && !listAvPilotCenters.isEmpty()){
				for (AV_PilotCenters__c pilotCenterGroup : listAvPilotCenters){
					List<String> pilotCenterOfficeNumbers = new List<String>();
					if(pilotCenterGroup.AV_OfficeNumber__c!=null && !String.isEmpty(pilotCenterGroup.AV_OfficeNumber__c)){
						pilotCenterOfficeNumbers = pilotCenterGroup.AV_OfficeNumber__c.split(',');
						for(String officeNumber : pilotCenterOfficeNumbers){
								officeNumbers.add(officeNumber);
						}
					}
				}	
			}
			for(Opportunity o : oppToCreateTaskList){
				Boolean checkPilotCenters = true;
					if(o.AV_Center__c != null && !String.isEmpty(o.AV_Center__c) && listAvPilotCenters != null && !listAvPilotCenters.isEmpty()){
						if(officeNumbers.contains(o.AV_Center__c)){
							checkPilotCenters = false;
						}
					}
					if(checkPilotCenters){

						Task taskToInsert = createTaskCommercialAlert( o, activityDate, rtTask, userMap.get(o.ownerId).AV_NumeroOficinaEmpresa__c );
						taskToInsertList.add(taskToInsert);
						oppIdTaskExternalIdMap.put(o.Id, taskToInsert.AV_ExternalID__c);
					}			
			}
			if (taskToInsertList!=null && !taskToInsertList.isEmpty()){
				//INSERTA LAS TAREAS PARA CADA OPORTUNIDAD
				Database.SaveResult[] resultList = Database.insert(taskToInsertList, false);
				Set<String> idTasksInserted = new Set<String>();
				for (Database.SaveResult res : resultList) {
                    if (res.isSuccess()) {
						idTasksInserted.add(res.getId());
                    }
                }
				if(idTasksInserted != null && !idTasksInserted.isEmpty()){
					List<Task> tasksInserted = [SELECT Id, AV_ExternalID__c, AV_Task__c, OwnerId  FROM Task WHERE Id = :idTasksInserted WITH SECURITY_ENFORCED];
					//ENVIA NOTIFICACIÓN DE LAS TAREAS
					CustomNotificationType templateInfoDetail = [SELECT Id, DeveloperName FROM CustomNotificationType WHERE DeveloperName = 'AV_NotificationCallMe' LIMIT 1];
					Map<String, String> externalIdTaskMap = new Map<String, String>();
					for(Task t : tasksInserted){
						if(t != null){
							externalIdTaskMap.put(t.AV_ExternalID__c, t.AV_Task__c);
							sendNotificationCallMe(t, templateInfoDetail);
						}
					}
					//Crea la Tarea-Oportunidad asociada a la oportunidad y a la tarea insertadas
					List<AV_CustomActivityOpportunity__c> taskOppList = new List<AV_CustomActivityOpportunity__c>();
					for(Opportunity opp : oppToCreateTaskList){
							AV_CustomActivityOpportunity__c taskOpp = new AV_CustomActivityOpportunity__c();
							taskOpp.AV_Task__c = externalIdTaskMap.get(oppIdTaskExternalIdMap.get(opp.Id));
							taskOpp.AV_Opportunity__c = opp.Id;
							taskOppList.add(taskOpp);
					}
					Database.insert(taskOppList, false);
				}
			}  
		}
	}

	/**
	* @description         Create Task associated with the Opportunity Call Me.
	* @param  opp        Opportunity.
	* @param  activityDate   Due Date
	* @param  rt         record type
	* @param  numCent    center number
	*/
	private static Task createTaskCommercialAlert(Opportunity opp, Date activityDate, Id rt, String numCent) {
		Task tarea = new Task();
		if(String.isNotBlank(opp.AV_ExternalID__c)){
			tarea.AV_ExternalID__c = SUFFIX_EXTERNALID + opp.AV_ExternalID__c + System.now();
		}else{
			tarea.AV_ExternalID__c = SUFFIX_EXTERNALID + opp.Id + System.now();
		}
		tarea.ActivityDate = activityDate;
		tarea.AV_FechaFinAccionComercial__c = activityDate;
		if(String.isNotBlank(opp.AccountId)){
			tarea.WhatId = opp.AccountId;
		}
		if(opp.Name!=null){
			tarea.Subject = opp.Name;
		}
		tarea.Status = 'Open';
		tarea.Priority = 'Y';
		tarea.RecordTypeId = rt;
		tarea.AV_CodigoGestorAsignado__c = opp.owner.AV_ExternalID__c;
		tarea.AV_Center__c = numCent.substring(numCent.length()-5);
		tarea.AV_OrigenApp__c = AV_AppConstants.OPPLLAMADA_RT;
		tarea.AV_Tipo__c = AV_AppConstants.LLAMADA_TIPO;
		return tarea;
	}
	
	/**
	* @description		 	Set propensity in Opportunity
	* @param  listOpp  list of new Opportunities 
	* @param  mapOldObj   map of old Opportunities
	*/
	public static void assignPropensity(List<Opportunity> listOpp, Map<Id, Opportunity> mapOldObj){
		for(Opportunity opp : listOpp){
			if(mapOldObj!=null && mapOldObj.get(opp.Id).AV_Potencial__c!=opp.AV_Potencial__c && setRtIniciativa.contains(opp.RecordTypeId)){
				if(opp.AV_Potencial__c!=null){
					AV_Propensity__c propensityCS = AV_Propensity__c.getValues(opp.AV_Potencial__c);
					if(propensityCS!=null){
						opp.AV_Propensity__c = propensityCS.AV_Propensity__c;
					}
				}else if(opp.AV_Potencial__c==null){
					AV_Propensity__c propensityCS = AV_Propensity__c.getValues('X');
					if(propensityCS!=null){
						opp.AV_Propensity__c = propensityCS.AV_Propensity__c;
					}
				}
			}else if(mapOldObj==null && setRtCallMe.contains(opp.RecordTypeId)){
				AV_Propensity__c propensityCS = AV_Propensity__c.getValues(AV_AppConstants.OPPLLAMADA_RT);
				if(propensityCS!=null){
					opp.AV_Propensity__c = propensityCS.AV_Propensity__c;
				}   
			}else if(mapOldObj==null && setRtIniciativa.contains(opp.RecordTypeId)){
				if(opp.AV_Potencial__c!=null){
					AV_Propensity__c propensityCS = AV_Propensity__c.getValues(opp.AV_Potencial__c);
					if(propensityCS!=null){
						opp.AV_Propensity__c = propensityCS.AV_Propensity__c;
					}
				}else if(opp.AV_Potencial__c==null){
					AV_Propensity__c propensityCS = AV_Propensity__c.getValues('X');
					if(propensityCS!=null){
						opp.AV_Propensity__c = propensityCS.AV_Propensity__c;
					}
				}
			}else if(mapOldObj==null && setRtAlerta.contains(opp.RecordTypeId)){
				if(opp.AV_Propensity__c == null){
					opp.AV_Propensity__c = 100;
				}
			}
		}
	}
	
	/**
	* @description		 	Send notification when Task is created
	* @param  t  task associated to notificatiion
	* @param  templateInfoDetail   the type of notification
	*/
	private static void sendNotificationCallMe(Task t, CustomNotificationType templateInfoDetail){
		String methodName='sendNotificationCallMe';
		Set<String> recipientId = new Set<String>();
		recipientId.add(t.OwnerId);
		// Create a new custom notification
		Messaging.CustomNotification currNotification = new Messaging.CustomNotification();
		// Set the contents for the delinking notification
		currNotification.setTitle('Nueva Tarea Call Me');
		currNotification.setBody('Priorice esta tarea');
		// Set the notification type and target
		currNotification.setNotificationTypeId(templateInfoDetail.Id);
		currNotification.setTargetId(t.Id);
		// Send the notification
		try{
			currNotification.send(recipientId);
		}
		catch(System.Exception ex) {
			AV_LogDebug.printException(methodName,ex);
		}
	}
	
	/**
	* @description    Empty AV_Resolucion__c field if StageName is not 'No interesado'
	* @param  listNew  list of new Opportunities 
	* @param  mapOld   map of old Opportunities 
	**/
	public static void emptyResolutionField(List<Opportunity> listNew, Map<Id, Opportunity> mapOld) {
		for (Opportunity o : listNew) {
			if (!o.StageName.equalsIgnoreCase(mapOld.get(o.Id).StageName) && !(o.StageName.equalsIgnoreCase(AV_AppConstants.OPP_STATUS_NOINTERE) || o.StageName.equalsIgnoreCase(AV_AppConstants.OPP_STATUS_PROD_RECH)) && !String.isBlank(o.AV_Resolucion__c) ) {
				o.AV_Resolucion__c = null;
			}
		}
	}

	/**
	* @description     	Delete AV_CustomActivityOpportunity related with Opportunity
	* @param  deletedOpportunityList  list of delete Opportunity records
	*/
	public static void deleteRecordsRelatedWithOpportunity(List<Opportunity> deletedOpportunityList){
		List<AV_CustomActivityOpportunity__c> custActOppList = [SELECT Id FROM AV_CustomActivityOpportunity__c WHERE AV_Opportunity__c IN :deletedOpportunityList AND Recordtype.DeveloperName = :AV_AppConstants.OPPTASK_RT WITH SECURITY_ENFORCED];
		if(custActOppList.size() > 0) {
			System.enqueueJob(new AV_DeleteRelatedOppQueueable(custActOppList));
		}	
	}

	/**
	* @description   object AV_CommentsHistory is updated when a Opportunity with the AV_Comentarios__ field informed is updated
	* @param  listNew  list of new Opportunities 
	* @param  mapOld   map of old Opportunities 
	*/
	public static void updateCommentsHistory(List<Opportunity> listNew, Map<Id, Opportunity> mapOld,Map<String, Opportunity> mapByPass, Map<String, Opportunity> mapByPassOld){
		List<AV_CommentsHistory__c> lstCommHist = new List<AV_CommentsHistory__c>();

		String commentOwnerId = UserInfo.getUserId();

		List<User> commentUserId = [SELECT Id, AV_ExternalID__c FROM User WHERE Id =:commentOwnerId LIMIT 1];
		List<Contact> commentEmployee = [SELECT Id FROM Contact WHERE CC_Matricula__c =: commentUserId[0].AV_ExternalID__c LIMIT 1];

		for(Opportunity opp : listNew){
			if(opp.AV_Comentarios__c != null && !mapByPass.containsKey(opp.AV_ExternalID__c) && !mapByPassOld.containsKey(opp.AV_ExternalID__c) && ((String.isNotBlank(opp.AV_Comentarios__c) && !opp.AV_Comentarios__c.equals(mapOld.get(opp.Id).AV_Comentarios__c)) || mapOld.get(opp.Id).StageName != opp.StageName)){
				AV_CommentsHistory__c commHist = new AV_CommentsHistory__c();
				commHist.OwnerId = opp.LastModifiedById;
				commHist.AV_ModificationDate__c = opp.AV_CommentLastModifiedDate__c;
				if (String.isNotBlank(opp.AV_Comentarios__c)) {
					commHist.AV_OldComment__c = mapOld.get(opp.Id).AV_Comentarios__c;
					commHist.AV_NewComment__c = opp.AV_Comentarios__c;
				}
				commHist.AV_OpportunityStatus__c = opp.StageName;
				commHist.AV_OldStatus__c = mapOld.get(opp.Id).StageName;
				if(commentEmployee != null && !commentEmployee.isEmpty()){
					commHist.AV_AssignedEmployee__c = commentEmployee[0].Id;
				}else{
					commHist.AV_AssignedEmployee__c = opp.AV_Gestor__c;
				}
				commHist.AV_Opportunity__c = opp.Id;
				lstCommHist.add(commHist);
			}	
		}
		if(Schema.sObjectType.AV_CommentsHistory__c.isCreateable()){
			Database.insert(lstCommHist,false);
		}
	}

	
	/**
	* @description     	Delete AV_CommentsHistory objects related With Opportunity
	* @param  deletedOpportunityList  list of delete Opportunity records
	*/
	public static void deleteCommentsHistory(List<Opportunity> deletedOpportunityList){
		List<AV_CommentsHistory__c> commHistList = [SELECT Id FROM AV_CommentsHistory__c WHERE AV_Opportunity__c IN : deletedOpportunityList WITH SECURITY_ENFORCED];
		if(commHistList.size()>0){
			if(Schema.sObjectType.AV_CommentsHistory__c.isDeletable()){
				Database.delete(commHistList,false);			
			}
		}
	}

	/**
	* @description     Validations to Opportunity
	* @param  listNew  list of new Opportunity records
	* @param  mapOld   map of old Opportunity records.
	*/
	public static void validationsOpportunity(List<Opportunity> listNew, Map<Id, Opportunity> mapOld) {
		Boolean hasByPassValidationRulesAv = FeatureManagement.checkPermission('AV_ByPassValidationRules');
		Boolean hasByPassValidationRulesCbk = FeatureManagement.checkPermission('CBK_BypassValidationRules');
		for(Opportunity o : listNew) {
			if (mapOld != null) { //Update
				if ((mapOld.get(o.Id).StageName != AV_AppConstants.OPP_STATUS_POTENCIAL && o.StageName != AV_AppConstants.OPP_STATUS_ENGESTION && o.AV_FechaProximoRecordatorio__c == mapOld.get(o.Id).AV_FechaProximoRecordatorio__c) && (!o.StageName.equalsIgnoreCase(mapOld.get(o.Id).StageName) && !AV_AppConstants.OPP_ORIGEN_SF_REPORT.equals(o.AV_OrigenApp__c) && !AV_AppConstants.CLIENT_REPORT_ORIGENAPP.equals(o.AV_OrigenApp__c) && !AV_AppConstants.OPP_ORIGEN_BACK_REPORT.equals(o.AV_OrigenApp__c) && !AV_AppConstants.BACK_REPORT_NEW_OPP_ORIGENAPP.equals(o.AV_OrigenApp__c))) {
					o.addError(Label.AV_ValidateOppToEditOppUseButt	);
				}
				if (o.CloseDate != o.AV_FechaProximoRecordatorio__c && o.CloseDate != mapOld.get(o.Id).CloseDate && (!AV_AppConstants.OPP_ORIGEN_SF_REPORT.equals(o.AV_OrigenApp__c) && !AV_AppConstants.CLIENT_REPORT_ORIGENAPP.equals(o.AV_OrigenApp__c) && !AV_AppConstants.OPP_ORIGEN_BACK_REPORT.equals(o.AV_OrigenApp__c) && !AV_AppConstants.BACK_REPORT_NEW_OPP_ORIGENAPP.equals(o.AV_OrigenApp__c))){
					o.addError(Label.AV_ValidateOppChangeCloseDateManual);
				}
				if (UserInfo.getUserId() == userGFC.id || Test.isRunningTest()) {
					if (o.StageName != mapOld.get(o.Id).StageName && o.AV_OrigenApp__c != AV_AppConstants.OPP_ORIGEN_BACK_REPORT && !AV_AppConstants.BACK_REPORT_NEW_OPP_ORIGENAPP.equals(o.AV_OrigenApp__c) && (!hasByPassValidationRulesAv && !hasByPassValidationRulesCbk) && (o.StageName == AV_AppConstants.OPP_STATUS_POTENCIAL || o.StageName == AV_AppConstants.OPP_STATUS_CONVENTA || o.StageName == AV_AppConstants.OPP_STATUS_NO_GESTIONADA||o.StageName == AV_AppConstants.OPP_STATUS_VENCIDO)) {
						o.addError(Label.AV_ValidateOppStage); //El gestor no puede cambiar el estado a "Vencido", "Con venta" y "Potencial", ni modificar estado de "Con Venta"
					}
					if (o.StageName != mapOld.get(o.Id).StageName && mapOld.get(o.Id).StageName == AV_AppConstants.OPP_STATUS_CONVENTA && (o.StageName == AV_AppConstants.OPP_STATUS_CERRPOST || o.StageName == AV_AppConstants.OPP_STATUS_NOINTERE || o.StageName == AV_AppConstants.OPP_STATUS_ENGESTION ||o.StageName == AV_AppConstants.OPP_STATUS_PROD_RECH || o.StageName == AV_AppConstants.OPP_STATUS_PROD_CONTR) && o.AV_OrigenApp__c != AV_AppConstants.OPP_ORIGEN_BACK_REPORT && !AV_AppConstants.BACK_REPORT_NEW_OPP_ORIGENAPP.equals(o.AV_OrigenApp__c) && (!hasByPassValidationRulesAv && !hasByPassValidationRulesCbk)) {
						o.addError(Label.AV_ValidateOppReturnStagInSalesStatus); //No permite modificar a una etapa anterior si está en estado 'Con Venta'
					}
					if (o.AV_IncludeInPrioritizingCustomers__c != mapOld.get(o.Id).AV_IncludeInPrioritizingCustomers__c && o.AV_IncludeInPrioritizingCustomers__c && o.StageName != AV_AppConstants.OPP_STATUS_POTENCIAL && o.StageName != AV_AppConstants.OPP_STATUS_ENGESTION && o.AV_OrigenApp__c != AV_AppConstants.OPP_ORIGEN_BACK_REPORT && !AV_AppConstants.BACK_REPORT_NEW_OPP_ORIGENAPP.equals(o.AV_OrigenApp__c) && (!hasByPassValidationRulesAv && !hasByPassValidationRulesCbk)) {
						o.addError(Label.AV_checkStatusClientePriorizador);
					}
					if (o.AV_IncludeInPrioritizingCustomers__c != mapOld.get(o.Id).AV_IncludeInPrioritizingCustomers__c && o.AV_IncludeInPrioritizingCustomers__c && o.AV_FechaProximoRecordatorio__c < date.today() && o.AV_OrigenApp__c != AV_AppConstants.OPP_ORIGEN_BACK_REPORT && !AV_AppConstants.BACK_REPORT_NEW_OPP_ORIGENAPP.equals(o.AV_OrigenApp__c) && (!hasByPassValidationRulesAv && !hasByPassValidationRulesCbk)) {
						o.addError(Label.AV_controlFechaRecordatorio); 
					}
					if (o.AV_Resolucion__c != mapOld.get(o.Id).AV_Resolucion__c && o.StageName == mapOld.get(o.Id).StageName && (o.StageName != AV_AppConstants.OPP_STATUS_NOINTERE ||o.StageName != AV_AppConstants.OPP_STATUS_PROD_RECH  )&& o.AV_OrigenApp__c != AV_AppConstants.OPP_ORIGEN_BACK_REPORT && !AV_AppConstants.BACK_REPORT_NEW_OPP_ORIGENAPP.equals(o.AV_OrigenApp__c) && (!hasByPassValidationRulesAv && !hasByPassValidationRulesCbk)) {
						o.addError(Label.AV_ValidateOppNoResoIfNegClosed);
					}
					if (o.AV_Resolucion__c != mapOld.get(o.Id).AV_Resolucion__c && o.AV_Resolucion__c == AV_AppConstants.OPP_RESOLUTION_VD && o.AV_OrigenApp__c != AV_AppConstants.OPP_ORIGEN_BACK_REPORT && !AV_AppConstants.BACK_REPORT_NEW_OPP_ORIGENAPP.equals(o.AV_OrigenApp__c) && (!hasByPassValidationRulesAv && !hasByPassValidationRulesCbk)) {
						o.addError(Label.AV_ValidateOppNoResoDisSalesIsAutomRes); //El gestor no puede cambiar la resolución a Venta desestimada.
					}
				}
			}
			//Insert/Update
			if (UserInfo.getUserId() == userGFC.id || Test.isRunningTest()) {
				if ((setRtAlerta.contains(o.RecordTypeId) || setRtIniciativa.contains(o.RecordTypeId) || setRtPropuesta.contains(o.RecordTypeId) || setRtSugerencia.contains(o.RecordTypeId)) && o.AV_FechaProximoRecordatorio__c == null && (o.StageName == AV_AppConstants.OPP_STATUS_ENGESTION) && o.AV_OrigenApp__c != AV_AppConstants.OPP_ORIGEN_BACK_REPORT && !AV_AppConstants.BACK_REPORT_NEW_OPP_ORIGENAPP.equals(o.AV_OrigenApp__c) && (!hasByPassValidationRulesAv && !hasByPassValidationRulesCbk)) {
					o.addError(Label.AV_FechaProximaGestion); //Será obligatorio rellenar la fecha de próxima gestión cuando las etapas sean en gestión/insistir y no apto.
				}
				if(o.AV_Resolucion__c == AV_AppConstants.OPP_RESOLUTION_OTROS && o.AV_Comentarios__c == null && o.AV_OrigenApp__c != AV_AppConstants.OPP_ORIGEN_BACK_REPORT && !AV_AppConstants.BACK_REPORT_NEW_OPP_ORIGENAPP.equals(o.AV_OrigenApp__c) && (!hasByPassValidationRulesAv && !hasByPassValidationRulesCbk)) {
					o.addError(Label.AV_ValidateOppCommentReq); //Validacion de cuando se elige la opcion Otros de Resolucion y el campo Coemntario esta vacio
				}
			}
		}
	}

	/**
	* @description     Bypass in Opp by report or back
	* @param  listNew  list of new Opportunity records
	* @param  mapOld   map of old Opportunity records.
	*/
	public static ResultadoByPass byPassOpp(List<Opportunity> listNew, Map<Id, Opportunity> mapOld) {
		Map<String, Opportunity> mapReturnToAfter = new Map<String, Opportunity>();
		Map<String, Opportunity> mapReturnOldToAfter = new Map<String, Opportunity>();
		for (Opportunity o : listNew) {
			if (mapOld != null && !mapOld.isEmpty()) {
				if(o.AV_OrigenApp__c != null && String.isNotBlank(o.AV_OrigenApp__c) && !o.AV_OrigenApp__c.equals(mapOld.get(o.Id).AV_OrigenApp__c) && o.AV_OrigenApp__c == AV_AppConstants.OPP_ORIGEN_BACK_REPORT){
					mapReturnToAfter.put(o.AV_ExternalID__c,o);
					o.AV_OrigenApp__c = AV_AppConstants.OPP_ORIGEN_BACK_REPORT.equals(mapOld.get(o.Id).AV_OrigenApp__c) ? '' : mapOld.get(o.Id).AV_OrigenApp__c;
				}
				if(o.AV_OrigenApp__c != null && String.isNotBlank(o.AV_OrigenApp__c) && !o.AV_OrigenApp__c.equals(mapOld.get(o.Id).AV_OrigenApp__c) && o.AV_OrigenApp__c == AV_AppConstants.OPP_ORIGEN_SF_REPORT){
					mapReturnOldToAfter.put(o.AV_ExternalID__c,o);
					o.AV_OrigenApp__c = AV_AppConstants.OPP_ORIGEN_SF_REPORT.equals(mapOld.get(o.Id).AV_OrigenApp__c) ? '' : mapOld.get(o.Id).AV_OrigenApp__c;
				}
				if(o.AV_OrigenApp__c != null && String.isNotBlank(o.AV_OrigenApp__c) && !o.AV_OrigenApp__c.equals(mapOld.get(o.Id).AV_OrigenApp__c) && o.AV_OrigenApp__c == AV_AppConstants.CLIENT_REPORT_ORIGENAPP){
				    mapReturnToAfter.put(o.AV_ExternalID__c,o);
					o.AV_OrigenApp__c = AV_AppConstants.CLIENT_REPORT_ORIGENAPP.equals(mapOld.get(o.Id).AV_OrigenApp__c) ? '' : mapOld.get(o.Id).AV_OrigenApp__c;
				}
				if(o.AV_OrigenApp__c != null && String.isNotBlank(o.AV_OrigenApp__c) && !o.AV_OrigenApp__c.equals(mapOld.get(o.Id).AV_OrigenApp__c) && o.AV_OrigenApp__c == AV_AppConstants.BACK_REPORT_NEW_OPP_ORIGENAPP){
					o.AV_OrigenApp__c = AV_AppConstants.BACK_REPORT_NEW_OPP_ORIGENAPP.equals(mapOld.get(o.Id).AV_OrigenApp__c) ? '' : mapOld.get(o.Id).AV_OrigenApp__c;
				}
				if(o.AV_OrigenApp__c != null && String.isNotBlank(o.AV_OrigenApp__c) && !o.AV_OrigenApp__c.equals(mapOld.get(o.Id).AV_OrigenApp__c) && o.AV_OrigenApp__c == AV_AppConstants.OPP_ORIGEN_UPDATE_WALLET){
					o.AV_OrigenApp__c = AV_AppConstants.OPP_ORIGEN_UPDATE_WALLET.equals(mapOld.get(o.Id).AV_OrigenApp__c) ? '' : mapOld.get(o.Id).AV_OrigenApp__c;
				}
				if(o.AV_OrigenApp__c != null && String.isNotBlank(o.AV_OrigenApp__c) && !o.AV_OrigenApp__c.equals(mapOld.get(o.Id).AV_OrigenApp__c) && o.AV_OrigenApp__c == AV_AppConstants.DATAPIPELINES_ORIGENAPP){
					o.AV_OrigenApp__c = AV_AppConstants.DATAPIPELINES_ORIGENAPP.equals(mapOld.get(o.Id).AV_OrigenApp__c) ? '' : mapOld.get(o.Id).AV_OrigenApp__c;
				}
			} else {
				if(o.AV_OrigenApp__c != null && String.isNotBlank(o.AV_OrigenApp__c) && (o.AV_OrigenApp__c == AV_AppConstants.OPP_ORIGEN_BACK_REPORT || o.AV_OrigenApp__c == AV_AppConstants.OPP_ORIGEN_SF_REPORT || o.AV_OrigenApp__c == AV_AppConstants.CLIENT_REPORT_ORIGENAPP || o.AV_OrigenApp__c == AV_AppConstants.BACK_REPORT_NEW_OPP_ORIGENAPP)){
					if (o.AV_OrigenApp__c != AV_AppConstants.BACK_REPORT_NEW_OPP_ORIGENAPP && o.AV_OrigenApp__c != AV_AppConstants.OPP_ORIGEN_SF_REPORT){
						if (o.AV_ExternalID__c == null) {
							o.AV_ExternalID__c = SUFFIX_EXTERNALID+(Math.round(Math.random()*1000000) + Datetime.now().getTime());
						}
						mapReturnToAfter.put(o.AV_ExternalID__c,o);
					}
					o.AV_OrigenApp__c = '';
				}
			}
		}
		ResultadoByPass rbp = new ResultadoByPass();
		rbp.mapByPass = mapReturnToAfter;
		rbp.mapByPassOld = mapReturnOldToAfter;
		return rbp;
	}

	public class ResultadoByPass{
		public Map<String, Opportunity> mapByPass = new Map<String, Opportunity> ();
		public Map<String, Opportunity> mapByPassOld = new Map<String, Opportunity> ();
	}

	/**
	 * @param opposForRecalculateScoring opportunities that has been recalculated
	 * @param clientsInEmptyCase clients that has been stripped of all opportunities
	 * @param isQueuable whether has to make the update or just return the list of calculate account scoring
	 * @param transactionType
	 * @return List<Account>
	 */
	public static List<Account> calculateScoreClient(List<Opportunity> opposForRecalculateScoring,List<String> clientsInEmptyCase,Boolean isQueuable,String transactionType){
		Map<Id,List<Opportunity>> clientToHisOpportunitys = new Map<Id,List<Opportunity>>();
		List<Account> accountsToUpdateScore = new List<Account>();
		if(!opposForRecalculateScoring.isEmpty()){
			for(Opportunity oppo : opposForRecalculateScoring){
				if(clientToHisOpportunitys.containsKey(oppo.AccountId)){
					clientToHisOpportunitys.get(oppo.AccountId).add(oppo);
				}else{
					clientToHisOpportunitys.put(oppo.AccountId,new List<Opportunity>{oppo});
				}
			} 
			for(Id accToUpdt : clientToHisOpportunitys.keySet()){
				if(accToUpdt != null){
					Decimal finalScore = 0;
					for(Opportunity oppo : clientToHisOpportunitys.get(accToUpdt)){
						Decimal nextScore = (oppo.AV_PotencialityOpportunityValue__c != null) ? oppo.AV_PotencialityOpportunityValue__c : 0;
						finalScore += nextScore; 
					}
					accountsToUpdateScore.add(new Account(Id = accToUpdt , AV_PotencialityClientValue__c = finalScore));
				}
			}
			if(!clientsInEmptyCase.isEmpty()){
				for(String accWithoutOpp : new Set<String>(clientsInEmptyCase)){
					if(!clientToHisOpportunitys.containsKey(accWithoutOpp) && accWithoutOpp != null ){
						accountsToUpdateScore.add(new Account(Id = accWithoutOpp , AV_PotencialityClientValue__c = 0));
					}
				}
			}
		}else{
			for(String clientToEmptyId : new Set<String>(clientsInEmptyCase)){
				if(clientToEmptyId != null){
					accountsToUpdateScore.add(new Account(Id = clientToEmptyId, AV_PotencialityClientValue__c = 0));
				}
			}
		}
		if(!isQueuable){
			try{
				List<Database.SaveResult> srUpdtAcc = Database.update(accountsToUpdateScore,false);
				Set<String> failedClients = new Set<String>();
				String errMsg;
				for(Integer i=0;i<srUpdtAcc.size();i++){
					if(!srUpdtAcc[i].isSuccess()){
						failedClients.add(accountsToUpdateScore[i].Id);
						errMsg =srUpdtAcc[i].getErrors()[0].getMessage();
					}
				}
				if(!failedClients.isEmpty()){
					throw new ClientStackTraceException(failedClients,errMsg);
				}
			}catch(ClientStackTraceException err){
				Exception expToQueueable = new ClientException(err.getStackTraceString(),err.getMessage());
				System.enqueueJob(new AV_ReTryScoringQueueable(err.failedClients,expToQueueable,0,transactionType),1);
			}
		}	
		return accountsToUpdateScore;
	}

	private class ClientStackTraceException extends Exception{
		Set<String> failedClients;
		public String errMsg;
		public ClientStackTraceException(Set<String> failedClients,String errMsg){
			this.failedClients = failedClients;
			this.errMsg = errMsg;
		}
		public override string getMessage(){
			return errMsg;
		}
	}

	private class ClientException extends Exception{
		public String errMsg;
		public String stackTrace;
		public ClientException(String stackTrace,String errMsg){
			this.errMsg = errMsg;
			this.stackTrace = stackTrace;
		}
		public override string getMessage(){
			return errMsg;
		}
		public override string getStackTraceString(){
			return this.stackTrace;
		}
	}


	/**
	* @description    Fill AV_Subestado__c field with value 'Pendiente' of opportunities with stageName 'Potencial'
	* @param  listNew  list of new Opportunities 
	**/
	public static void fillSubState(List<Opportunity> listNew) {
		for (Opportunity o : listNew) {
			if (o.StageName.equalsIgnoreCase(AV_AppConstants.OPP_STATUS_POTENCIAL) ) {
				o.AV_Subestado__c = 'Pendiente';
			}
		}
	}



	/**
	* @description    Blank AV_Subestado__c field when opportunities change from stageName 'Potencial' to another stageName
	* @param  listNew  list of new Opportunities 
	* @param  mapOld   map of old Opportunities 
	**/
	public static void blankSubState(List<Opportunity> listNew, Map<Id, Opportunity> mapOld) {
		for (Opportunity o : listNew) {
			if ( !(o.StageName.equalsIgnoreCase(mapOld.get(o.Id).StageName)) && ((mapOld.get(o.Id).StageName).equalsIgnoreCase(AV_AppConstants.OPP_STATUS_POTENCIAL)) ) {
				o.AV_Subestado__c = null;
			}
		}
	}


}