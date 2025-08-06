/**********************************************************************************************************************
 Name:	  CIBE_OpportunityTriggerHelper
 Copyright © 2022  CaixaBank
------------------------------------------------------------------------------------------------
Proposito: Clase auxiliar de los Triggers de Opportunity para CIBE
------------------------------------------------------------------------------------------------
Historial
------------------------------------------------------------------------------------------------
	VERSION		USER_STORY		AUTHOR				DATE				Description
	1.0							Jose Maria			09/06/2022			Init version Opp 
	2.0							Jose Maria			17/10/2022			Mejora método setConfidentiality
	3.0			US481662		Jose Maria			29/11/2022			Funcionalidad Cartera y Sector añadido al metodo ChangeOwner
	4.0        	US506932     	Ali		            31/01/2023    		Método addRelationshipManager()
	5.0        	US523654     	Lucía Muñoz         07/02/2023    		Método newAtributtesOpp
	6.0        	US583945     	Ali              	05/06/2023			Método stateOpportunity()
	7.0        	IT     			Lucía Muñoz         11/07/2023			Eliminar el metodo newAtributtesOpp();
	8.0			US616750		Alex Campos 	    27/07/2023			setOpportunityUsers
	9.0        	US674811      	Lucía Muñoz         15/09/2023			modificar stateOpportunity;
	10.0        US643353      	Ali y Bea	       	21/09/2023			crear el metodo insertOppTM()
	11.0	    US717936        Bea                 04/12/2023      	Método updateStageName
	12.0	    US732988        Ali                 05/12/2023      	Método createCommentsHistory(), updateCommentsHistory() y deleteCommentsHistory()
	13.0		US812745		Luis				14/03/2023			Mod Método insertTaskWithOpp() para excluir RT Alerta Comercial EMP
	14.0		US733917		Lucia				18/03/2023			Modificar los metodos insertTaskWithOpp y updateTaskWithOpp
	15.0		US872914		Lucia				06/05/2024			Nuevo metodo deleteRelations
	16.0		IN1216697		Luis				14/10/2024			Mod Método updateCommentsHistory() por error en la visualización 360 de registros no relacionados a la Oportunidad

------------------------------------------------------------------------------------------------
***********************************************************************************************************************/
public with sharing class CIBE_OpportunityTriggerHelper {
    private static final String SUFFIX_EXTERNALID     = 'Opp-';
	private static final String ERROR_MESSAGE			= Label.AV_deleteToOpp;
    private static final String ERROR_MESSAGE_CONTACT	= Label.CIBE_ErrorContact;
    public static DateTime dateExternalId;
    
    private static CIBE_AppUtilities.SearchRT rtINICIATIVACIB = new CIBE_AppUtilities.SearchRT(CIBE_AppConstants.OBJECT_NAME_OPPORTUNITY, CIBE_AppConstants.OPP_INICIATIVACIB_RT);
    private static CIBE_AppUtilities.SearchRT rtINICIATIVAEMP = new CIBE_AppUtilities.SearchRT(CIBE_AppConstants.OBJECT_NAME_OPPORTUNITY, CIBE_AppConstants.OPP_INICIATIVAEMP_RT);
    private static CIBE_AppUtilities.SearchRT rtSUGERENCIACIB = new CIBE_AppUtilities.SearchRT(CIBE_AppConstants.OBJECT_NAME_OPPORTUNITY, CIBE_AppConstants.OPP_SUGERENCIACIB_RT);
    private static CIBE_AppUtilities.SearchRT rtSUGERENCIAEMP = new CIBE_AppUtilities.SearchRT(CIBE_AppConstants.OBJECT_NAME_OPPORTUNITY, CIBE_AppConstants.OPP_SUGERENCIAEMP_RT);
    private static CIBE_AppUtilities.SearchRT rtALERTACOMERCIALCIB = new CIBE_AppUtilities.SearchRT(CIBE_AppConstants.OBJECT_NAME_OPPORTUNITY, CIBE_AppConstants.OPP_ALERTACIB_RT);
    private static CIBE_AppUtilities.SearchRT rtALERTACOMERCIALEMP = new CIBE_AppUtilities.SearchRT(CIBE_AppConstants.OBJECT_NAME_OPPORTUNITY, CIBE_AppConstants.OPP_ALERTAEMP_RT);
    private static CIBE_AppUtilities.SearchRT rtACCIONCOMERCIALCIB = new CIBE_AppUtilities.SearchRT(CIBE_AppConstants.OBJECT_NAME_OPPORTUNITY, CIBE_AppConstants.OPP_ACCIONCIB_RT);
    private static CIBE_AppUtilities.SearchRT rtACCIONCOMERCIALEMP = new CIBE_AppUtilities.SearchRT(CIBE_AppConstants.OBJECT_NAME_OPPORTUNITY, CIBE_AppConstants.OPP_ACCIONEMP_RT);
    
    private static CIBE_AppUtilities.SearchRT rtTASKINICIATIVACIB = new CIBE_AppUtilities.SearchRT(CIBE_AppConstants.OBJECT_NAME_TASK, CIBE_AppConstants.TASK_OTROS_CIB_RT);
    private static CIBE_AppUtilities.SearchRT rtTASKINICIATIVAEMP = new CIBE_AppUtilities.SearchRT(CIBE_AppConstants.OBJECT_NAME_TASK, CIBE_AppConstants.TASK_OTROS_EMP_RT);
    
    private static Set<Id> setRtTaskIniciativa   = getIdsRT(new Set<CIBE_AppUtilities.SearchRT>{rtTASKINICIATIVACIB, rtTASKINICIATIVAEMP});
	private static Set<Id> setRtIniciativa = getIdsRT(new Set<CIBE_AppUtilities.SearchRT>{rtINICIATIVACIB, rtINICIATIVAEMP});
    private static Set<Id> setRts = getIdsRT(new Set<CIBE_AppUtilities.SearchRT>{rtINICIATIVACIB, rtINICIATIVAEMP, rtSUGERENCIACIB, rtSUGERENCIAEMP, rtALERTACOMERCIALCIB, rtALERTACOMERCIALEMP, rtACCIONCOMERCIALCIB, rtACCIONCOMERCIALEMP});
    private static Set<Id> setRtAll = getAllRT();

	private static Set<Id> setRtOppCIB   = getIdsRT(new Set<CIBE_AppUtilities.SearchRT>{rtINICIATIVACIB, rtSUGERENCIACIB, rtALERTACOMERCIALCIB, rtACCIONCOMERCIALCIB});
    private static Set<Id> setRtOppEMP   = getIdsRT(new Set<CIBE_AppUtilities.SearchRT>{rtINICIATIVAEMP, rtSUGERENCIAEMP, rtALERTACOMERCIALEMP, rtACCIONCOMERCIALEMP});
    /**
	 * @description		 	Check the record types
	 * @param listNews  	list of new records
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
	 * @description		 	Get all the ID's of the RT
	 */
    public static Set<Id> getAllRT(){
		
        Set<CIBE_AppUtilities.SearchRT> setLabelsRt = new Set<CIBE_AppUtilities.SearchRT>{rtINICIATIVACIB, rtINICIATIVAEMP, rtSUGERENCIACIB, rtSUGERENCIAEMP, rtALERTACOMERCIALCIB, rtALERTACOMERCIALEMP, rtACCIONCOMERCIALCIB, rtACCIONCOMERCIALEMP};
		return CIBE_AppUtilities.getRecordTypeIdsInSet(setLabelsRt);
    }
        
    /**
	 * @description		 	Get the ID's of the RT's requested by param
	 * @param setRT			List of the RT
	 */
    public static Set<Id> getIdsRT(Set<CIBE_AppUtilities.SearchRT> setRT){
		

        return CIBE_AppUtilities.getRecordTypeIdsInSet(setRT);
    }
    
    /**
	 * @description		 This method is used to fill in fields of the opportunity at the time of creation
	 * @param  listNews  list of new Opportunity records
	 * @param  mapOldObj  map with old Opportunity records
	 */
	public static void fillFieldsFromOpp(List<Opportunity> listNews,Map<Id, Opportunity> mapOldObj){
		Date createdFormatDate = System.today();
		for(Opportunity opp: listNews){
            if(mapOldObj == null || (mapOldObj != null && mapOldObj.get(opp.id).StageName != opp.StageName)){
				opp.CIBE_LastStageModifiedDate__c = createdFormatDate;
				//US807446
				if(opp.StageName == 'CIBE_Vencido' && setRtOppEMP.contains(opp.RecordTypeId) && mapOldObj != null){
					opp.CIBE_LastUpdatedCerradoNegativo__c = createdFormatDate;
				}
            }
			
		}
	}
    
    /**
	 * @description		 This method is used to asign "Alta" values if Stage field value change from "Potencial" to "En curso"
	 * @param  listNews  list of new Opportunity records
	 * @param  mapOldObj  map with old Opportunity records
	 */
	public static void asignAltaValues(List<Opportunity> listNews,Map<Id, Opportunity> mapOldObj){
		List<Contact> listContactOfUsers = new List<Contact> ();
		if(
			Schema.SObjectType.Contact.fields.Id.isAccessible()
		) {
			listContactOfUsers=[SELECT Id FROM Contact WHERE AV_UsuarioAsociado__c = :UserInfo.getUserId()];
		}
        Date dt = System.today();
		for(Opportunity opp: listNews){
            if(mapOldObj.get(opp.id).StageName.equals('Potencial') && opp.StageName.equals('En curso')){
                if(!listContactOfUsers.isEmpty()){
					opp.AV_EmpleadoAlta__c=listContactOfUsers[0].id;
                    opp.AV_FechaAlta__c = dt;
                }else{ 
                    opp.addError(ERROR_MESSAGE_CONTACT);  
                }
            }
        }
	}
    
    /**
	 * @description		 Validate Opportunities to delete when Opportunity RT CIBE_INICIATIVA Y RT CIBE_OPERATIVA_CENTRALIZADA
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
		List<AV_CustomActivityOpportunity__c> listTaskAndOpp = new List<AV_CustomActivityOpportunity__c>();
		if(
			Schema.SObjectType.AV_CustomActivityOpportunity__c.fields.AV_Opportunity__c.isAccessible()
		) {
			listTaskAndOpp= [SELECT Id, AV_Opportunity__c FROM AV_CustomActivityOpportunity__c WHERE AV_Opportunity__c=: mapOpps.keySet()];
		}
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
	 * @description		 This method is used to update fields of the opportunity
	 * @param  listNews  list of new Opportunity records
	 * @param  mapOldObj  map of old oppotunities 
	 * @param  isUpdate  field that indicates if the opportunity is an insert or an update
	 */
	public static void saveFieldsFromOpp(List<Opportunity> listNews, Map<Id, Opportunity> mapOldObj, Boolean isUpdate){
		

		Map<Id, List<Opportunity>> mapOppOwners = new Map<Id, List<Opportunity>>();
        
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
		List<Contact> listCont =new List<Contact>();
		if(
			Schema.SObjectType.Contact.fields.LastModifiedDate.isAccessible() &&
			Schema.SObjectType.Contact.fields.AV_UsuarioAsociado__c.isAccessible()
		) {
			listCont = [SELECT Id, LastModifiedDate, AV_UsuarioAsociado__c FROM Contact WHERE RecordType.DeveloperName = 'CC_Empleado' AND AV_UsuarioAsociado__c IN :mapOppOwners.keySet()];
		}

		Id idContactUser;
		for (Contact cont1 : listCont) {
			if(cont1.AV_UsuarioAsociado__c!=null && cont1.AV_UsuarioAsociado__c == UserInfo.getUserId()){
				idContactUser= cont1.id ;
			}
		}

		if(idContactUser != null) {
			for(Opportunity oppToProcess : listNews) {
				Datetime currentD = (Datetime) System.now();
				Date dt = date.newinstance(currentD.year(), currentD.month(), currentD.day());
				
				oppToProcess.AV_EmpleadoModificacion__c = idContactUser;
				oppToProcess.AV_FechaModificacion__c = dt;
				if(!isUpdate){
					oppToProcess.AV_FechaAlta__c = dt;
					oppToProcess.AV_EmpleadoAlta__c = idContactUser;
				}
			}
		}
	}

	/**
	* @description     Retrieves comercial group related to the client
	* @param news  map of new Opportunity records
	* @param mapOlds map of old Opportunity records
	*/
	public static void retrieveComercialGroup(List<Opportunity> news, Map<Id, Opportunity> mapOlds) {
		String methodName = 'retrieveComercialGroup';        
		Map<Id, List<Opportunity>> accountIds = new Map<Id, List<Opportunity>>();
		if(mapOlds == null) {
			for(Opportunity opp : news) {
				if(String.isNotBlank(opp.AccountId)) {
					if(!accountIds.containsKey(opp.AccountId)) {
						accountIds.put(opp.AccountId, new List<Opportunity>{opp});
					} else {
						accountIds.get(opp.AccountId).add(opp);
					}
				}
			}
		} else {
			for(Opportunity opp : news) {
				if(mapOlds.containsKey(opp.Id) && String.isNotBlank(opp.AccountId) && opp.AccountId != mapOlds.get(opp.Id).AccountId) {
					if(!accountIds.containsKey(opp.AccountId)) {
						accountIds.put(opp.AccountId, new List<Opportunity>{opp});
					} else {
						accountIds.get(opp.AccountId).add(opp);
					}
				}
			}
		}

		List<FinServ__AccountAccountRelation__c> relations = new List<FinServ__AccountAccountRelation__c>();
		if( Schema.SObjectType.FinServ__AccountAccountRelation__c.fields.Id.isAccessible()
			&& Schema.SObjectType.FinServ__AccountAccountRelation__c.fields.RecordTypeId.isAccessible()
			&& Schema.SObjectType.FinServ__AccountAccountRelation__c.fields.FinServ__Account__c.isAccessible()
			&& Schema.SObjectType.FinServ__AccountAccountRelation__c.fields.FinServ__RelatedAccount__c.isAccessible()) {
				relations = [SELECT Id, FinServ__Account__c, FinServ__RelatedAccount__c FROM FinServ__AccountAccountRelation__c WHERE RecordType.DeveloperName = 'CIBE_GrupoComercial' AND FinServ__Account__r.RecordType.DeveloperName = 'CIBE_GrupoComercial' AND FinServ__RelatedAccount__c IN :accountIds.keySet()];
		}

		if(relations!=null && !relations.isEmpty()) {
			for(FinServ__AccountAccountRelation__c relation : relations) {
				if(accountIds.containsKey(relation.FinServ__RelatedAccount__c)) {
					for(Opportunity opp : accountIds.get(relation.FinServ__RelatedAccount__c)) {
						opp.CIBE_GrupoComercial__c = relation.FinServ__Account__c;
					}
				}
			}
		}
	}

	/**
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
		if(listToProcess!=null && !listToProcess.isEmpty() && !Test.isRunningTest()) {
			AV_ForbiddenWords.validateRecords(listToProcess, setFields);
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
		Map<String,String> mapConGestorUser = new Map<String,String>();
		List<String> listIdGestores = new List<String>();
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
        
		List<User> userGFC= new List<User>();
		if(	Schema.SObjectType.User.fields.Id.isAccessible()) {
			userGFC = [SELECT ID FROM User WHERE Alias = 'AV-TF9' and IsActive = TRUE LIMIT 1];
		}
		if(listOppSinEap!=null && !listOppSinEap.isEmpty()){
			for(Opportunity opp : listOppSinEap){
				opp.OwnerId = userGFC[0].Id;
			}
		}
       
		if(gestorsIds!=null && !gestorsIds.isEmpty()) {
			Map<Id,Id> mapGestorUser = new Map<Id,Id>();
			//Obtenemos los Contactos que se han asociado nuevos a las Opp "cambio para".
			List<Contact> listEmployees= [Select Id, AV_UsuarioAsociado__c From Contact Where Id in :gestorsIds and AV_UsuarioAsociado__r.IsActive = true];
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
					opp.OwnerId = userGFC[0].Id;
				}
			}
		}
	}
	/**
	* @description     Change AV_Gestor__c,CIBE_Sector__c & CIBE_Cartera__c when change OwnerId
	* @param  listNews  list of new Opportunity records
	* @param  mapOlds   map of old Opportunity records
	*/
	public static void changeOwner(List<Opportunity> listNews, Map<Id, Opportunity> mapOlds) {
		List<Opportunity> listToProcess= new List<Opportunity>();
		List<String> listOwners= new List<String>();

		if(mapOlds == null) {
			for(Opportunity opp : listNews) {
				if(String.isNotBlank(opp.OwnerId)) {
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
        
		List<User> userGFC= new List<User>();
		if(	Schema.SObjectType.User.fields.Id.isAccessible() ) {
			userGFC = [SELECT ID FROM USER WHERE Alias = 'AV-TF9' and IsActive = TRUE LIMIT 1];
		}


		if(!listOwners.isEmpty() && !listToProcess.isEmpty()) {
			List<Contact> contSinGestorEAP= new List<Contact>();
			List<Contact> listCont = new List<Contact>();

			if(
				Schema.SObjectType.Contact.fields.lastmodifieddate.isAccessible() &&
				Schema.SObjectType.Contact.fields.CIBE_Sector__c.isAccessible()&&
				Schema.SObjectType.Contact.fields.CIBE_Cartera__c.isAccessible()&&
				Schema.SObjectType.Contact.fields.AV_UsuarioAsociado__c.isAccessible()
			) {
				contSinGestorEAP=[SELECT Id FROM Contact WHERE AV_UsuarioAsociado__c = :userGFC[0].Id LIMIT 1];
				listCont= [SELECT Id, lastmodifieddate,CIBE_Sector__c, CIBE_Cartera__c, AV_UsuarioAsociado__c FROM Contact WHERE AV_UsuarioAsociado__c IN :listOwners];
			}

			if (!listCont.isEmpty()) {
				Map<String,Contact> mapUserContact = new Map<String,Contact>();
				for (Contact con: listCont) {
					mapUserContact.put(con.AV_UsuarioAsociado__c,con);
				}
				for(Opportunity opp: listToProcess) {
					if (mapUserContact.containsKey(opp.OwnerId)) {
						opp.AV_Gestor__c = mapUserContact.get(opp.OwnerId).id;
						opp.CIBE_Sector__c = mapUserContact.get(opp.OwnerId).CIBE_Sector__c;
						opp.CIBE_Cartera__c = mapUserContact.get(opp.OwnerId).CIBE_Cartera__c;
					}else {
						opp.OwnerId = userGFC[0].Id;
						opp.AV_Gestor__c = contSinGestorEAP[0].Id;
						opp.CIBE_Sector__c = null; 
						opp.CIBE_Cartera__c = null;
					}
				}
			} else {
				for(Opportunity opp: listToProcess) {
					opp.CIBE_Sector__c = null;
					opp.CIBE_Cartera__c = null;
					opp.OwnerId = userGFC[0].Id;
					if (!contSinGestorEAP.isEmpty()) {
						opp.AV_Gestor__c = contSinGestorEAP[0].Id;
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
			List<User> currentUser = new List<User>();
			if(
				Schema.SObjectType.User.fields.AV_NumeroOficinaEmpresa__c.isAccessible() &&
				Schema.SObjectType.User.fields.Name.isAccessible()
			) {
				currentUser  = [Select Name, AV_NumeroOficinaEmpresa__c From User Where Id = :UserInfo.getUserId() Limit 1];
			}
			String employeeInfo = currentUser[0].Name;
			if(String.isNotBlank( currentUser[0].AV_NumeroOficinaEmpresa__c) &&  currentUser[0].AV_NumeroOficinaEmpresa__c.contains('-')) {
				employeeInfo += ' (ofi ' +  currentUser[0].AV_NumeroOficinaEmpresa__c.split('-').get(1) + ')';
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
			List<Account> listAcc= new List<Account>();
			if(
				Schema.SObjectType.Account.fields.CC_Numero_Documento__c.isAccessible()
			) {
				listAcc = [Select Id, CC_Numero_Documento__c From Account Where Id = :mapAccOpp.keySet()];
			}

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
			List<AV_ProductClient__c> listClientProds = new List<AV_ProductClient__c>();
			if(
				Schema.SObjectType.AV_ProductClient__c.fields.AV_ProductoFicha__c.isAccessible() &&
				Schema.SObjectType.AV_ProductClient__c.fields.AV_Cliente__c.isAccessible()
			) {
				listClientProds = [SELECT Id, AV_Cliente__c, AV_ProductoFicha__r.AV_ProductoFicha__c FROM AV_ProductClient__c WHERE AV_Cliente__c in :setAccIds and AV_ProductoFicha__r.AV_ProductoFicha__c = :setPFIds];
			}
			
			
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
	* @description    Updates opp's confidentiality according to its related account.
	*/
	public static void setConfidentiality(List<Opportunity> listNew) {

		Set<Id> cliIds = new Set<Id>();
		Map<Id, Boolean> cliConfidentiality = new Map<Id, Boolean>();
		
		for (Opportunity opp : listNew) {
			if(opp.AccountId !=null){
				cliIds.add(opp.AccountId);
			}
		}

		List<Account> clients= new List<Account>();
		if(
			Schema.SObjectType.Account.fields.AV_Confidencial__c.isAccessible() &&
			Schema.SObjectType.Account.fields.AV_Empleado__c.isAccessible()
		) {
			clients = [Select Id, AV_Confidencial__c, AV_Empleado__c From Account Where Id in :cliIds];
		}

		if (!clients.isEmpty()) {
			for (Account client : clients) {
				if(client.AV_Confidencial__c){
					cliConfidentiality.put(client.Id, client.AV_Confidencial__c);
				}
			}
			
            for (Opportunity opp : listNew) {
                if(opp.AccountId!=null){
                    if(cliConfidentiality.containsKey(opp.AccountId) && cliConfidentiality.get(opp.AccountId)){
                        opp.AV_ClienteConfidencial__c = cliConfidentiality.get(opp.AccountId);
                    }
                }
            }
		}
	}

	/**
	* Update the field AV_Center when the owner of an opportunity iniciativaGestor is updated. 
	* If the new owner is no SalesForce User, the field will remain blank.
	*/
	public static void updateCentro(List<Opportunity> listOpp, Map<Id, Opportunity> mapOldObj){
		

		Map<Id,String> mapOwnerOffice = new Map<Id,String>();
		Set<Id> owners = new Set<Id>();
		List<Opportunity> oppToProcess = new List<Opportunity>();
		String offiNumber='';
		RecordType iniciativaCIB = CIBE_AppUtilities.getRecordType('Opportunity','CIBE_IniciativaEmpleadoCIB');
		RecordType iniciativaEMP = CIBE_AppUtilities.getRecordType('Opportunity','CIBE_IniciativaEmpleadoEMP');
		RecordType alertaComercialCIB = CIBE_AppUtilities.getRecordType('Opportunity','CIBE_AccionComercialCIB');
		RecordType alertaComercialEMP = CIBE_AppUtilities.getRecordType('Opportunity','CIBE_AccionComercialEMP');

		if(mapOldObj != null && !mapOldObj.isEmpty()){//Updating existint opp
			for(Opportunity opp : listOpp){
				if(opp.OwnerId != mapOldObj.get(opp.Id).OwnerId){
					owners.add(opp.OwnerId);
					oppToProcess.add(opp);        
				}      
			}
		} else{//New Oppo
			for(Opportunity opp : listOpp){
				if(opp.RecordTypeId.equals(iniciativaCIB.Id) || opp.RecordTypeId.equals(iniciativaEMP.Id) || opp.RecordTypeId.equals(alertaComercialCIB.Id) || opp.RecordTypeId.equals(alertaComercialEMP.Id)){
					owners.add(opp.OwnerId);
					oppToProcess.add(opp);        
				}      
			}
		}

		List<User> userGFC= new List<User>();
		if(	Schema.SObjectType.User.fields.Id.isAccessible()) {
			userGFC = [SELECT ID FROM USER WHERE Alias = 'AV-TF9' AND IsActive = TRUE LIMIT 1];
		}

		if (owners != null && oppToProcess != null) {
			List<User> ownerOffice= new List<User>();
			if(
				Schema.SObjectType.User.fields.Id.isAccessible() &&
				Schema.SObjectType.USER.fields.AV_NumeroOficinaEmpresa__c.isAccessible()
			) {
				ownerOffice = [SELECT ID,AV_NumeroOficinaEmpresa__c FROM USER WHERE ID in :owners];
			}


			for(User owner : ownerOffice) {
				mapOwnerOffice.put(owner.Id,owner.AV_NumeroOficinaEmpresa__c);
			}
			for(Opportunity opp : oppToProcess){
				if(opp.OwnerId != userGFC[0].Id){
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
		Set<String> stageOpen = new Set<String>{CIBE_AppConstants.OPPORTUNITY_STATUS_POTENCIAL, CIBE_AppConstants.OPPORTUNITY_STATUS_ENCURSO, CIBE_AppConstants.OPPORTUNITY_STATUS_PENDFIRMA};
		Set<String> stageClose = new Set<String>{CIBE_AppConstants.OPPORTUNITY_STATUS_CERRPOSI, CIBE_AppConstants.OPPORTUNITY_STATUS_CERRNEGA, CIBE_AppConstants.OPPORTUNITY_STATUS_VENCIDO, CIBE_AppConstants.OPPORTUNITY_STATUS_CONVENTA, CIBE_AppConstants.OPPORTUNITY_STATUS_NOAPTO, CIBE_AppConstants.OPPORTUNITY_STATUS_NOINTERE};
		List<User> userApiOnly= new List<User>();
		if(	Schema.SObjectType.User.fields.Id.isAccessible() ) {
			userApiOnly = [SELECT id FROM User WHERE Id = :UserInfo.getUserId() AND Profile.Name='API Only'];
		}

		if (!userApiOnly.isEmpty()) {
			if(mapOldObj != null){
				for(Opportunity opp : listOpp) {
					//Si te llega el toDelete a true y la fecha de actualización está rellena -->  pongo el toDelete a lo previo 
					if (opp.AV_FechaModificacion__c != null && mapOldObj.get(opp.Id).AV_ToDelete__c != opp.AV_ToDelete__c && opp.AV_ToDelete__c == true) { 
						opp.AV_ToDelete__c = mapOldObj.get(opp.Id).AV_ToDelete__c;
					}
					//Si estaba en etapa 'Cerrada positiva', 'cerrada negativa' o 'no apto' y no pasa a Con Venta, llegando una modificación de etapa, fecha de próxima gestión o comentario --> pongo etapa, fecha de próxima gestión y comentario lo previo y dejo pasar el resto de campos 
					//Si estaba en etapa 'Con venta' y no pasa a 'Cerrado Negativo', llegando una modificación de etapa, fecha de próxima gestión o comentario --> pongo etapa, fecha de próxima gestión y comentario lo previo y dejo pasar el resto de campos
					//Si estaba en etapa 'En curso' y pasa a 'Potencial', llegando una modificación de etapa, fecha de próxima gestión o comentario -->  pongo fecha de próxima gestión y comentario lo previo y dejo pasar el resto de campos 
					if ((mapOldObj.get(opp.Id).AV_Comentarios__c != opp.AV_Comentarios__c 
					|| mapOldObj.get(opp.Id).AV_FechaProximoRecordatorio__c != opp.AV_FechaProximoRecordatorio__c 
					|| mapOldObj.get(opp.Id).StageName != opp.StageName) 
						&& (((mapOldObj.get(opp.Id).StageName == CIBE_AppConstants.OPPORTUNITY_STATUS_CERRPOSI 
							|| mapOldObj.get(opp.Id).StageName == CIBE_AppConstants.OPPORTUNITY_STATUS_CERRNEGA 
							|| mapOldObj.get(opp.Id).StageName == CIBE_AppConstants.OPPORTUNITY_STATUS_NOAPTO 
							|| mapOldObj.get(opp.Id).StageName == CIBE_AppConstants.OPPORTUNITY_STATUS_NOINTERE) && opp.StageName != CIBE_AppConstants.OPPORTUNITY_STATUS_CONVENTA) 

							|| (mapOldObj.get(opp.Id).StageName == CIBE_AppConstants.OPPORTUNITY_STATUS_CONVENTA && opp.StageName != CIBE_AppConstants.OPPORTUNITY_STATUS_NOINTERE) 
							|| (mapOldObj.get(opp.Id).StageName == CIBE_AppConstants.OPPORTUNITY_STATUS_ENCURSO && opp.StageName == CIBE_AppConstants.OPPORTUNITY_STATUS_POTENCIAL))) { 
						opp.StageName = mapOldObj.get(opp.Id).StageName;
						opp.AV_Comentarios__c = mapOldObj.get(opp.Id).AV_Comentarios__c;
						opp.AV_FechaProximoRecordatorio__c = mapOldObj.get(opp.Id).AV_FechaProximoRecordatorio__c;
					} 
					//Si llega un cambio de centro o empleado y la fecha de actualización está rellena --> pongo centro o empleado previo y dejo pasar el resto de cambios 
					if ((mapOldObj.get(opp.Id).AV_Center__c != opp.AV_Center__c || mapOldObj.get(opp.Id).AV_Gestor__c != opp.AV_Gestor__c) && opp.AV_FechaModificacion__c != null) { 
						opp.AV_Center__c = mapOldObj.get(opp.Id).AV_Center__c;
						opp.AV_Gestor__c = mapOldObj.get(opp.Id).AV_Gestor__c;
					}
				}
			}
		}  
	} 

		/**
	* @description     	Validation of closeDate
	* @param  listNews  list of new Opportunity records
	* @param  mapOldObj   map of old Opportunity records
	*/
	public static void checkCloseDate(List<Opportunity> listOpp, Map<Id, Opportunity> mapOldObj){

		if (listOpp != null){
			for (Opportunity opp : listOpp){
				if ((mapOldObj.get(opp.id).StageName.equals(CIBE_AppConstants.OPPORTUNITY_STATUS_POTENCIAL) || 
					mapOldObj.get(opp.id).StageName.equals(CIBE_AppConstants.OPPORTUNITY_STATUS_ENCURSO) || 
					mapOldObj.get(opp.id).StageName.equals(CIBE_AppConstants.OPPORTUNITY_STATUS_PENDFIRMA)) 
					&& (
					opp.StageName == CIBE_AppConstants.OPPORTUNITY_STATUS_CERRPOSI || 
					opp.StageName == CIBE_AppConstants.OPPORTUNITY_STATUS_CERRNEGA) && ( opp.CIBE_Visto__c == 'NO' || String.isBlank(opp.CIBE_Visto__c))){
					
						opp.closeDate = System.today();
				}
			}
		}


	} 
	/**
	* Enter the date when an Oppo pass from Stage 'Potencial' to any other but 'Vencido'. In that case the field will remain blank.
	*/
	public static void updateFechaActivacion(List<Opportunity> listOpp, Map<Id, Opportunity> mapOldObj){
		

		for(Opportunity opp : listOpp){
			String newStage = opp.StageName;
			String oldStage = mapOldObj.get(opp.Id).StageName;
			if(oldStage!= newStage){
				if(oldStage == 'Potencial' && newStage!='CIBE_Vencido' ){
					opp.AV_FechaActivacion__c= System.today();
				}
			}
		}
	}


/**
* @description       Set Fields From AV_CustomActivityOpportunity__c
* @param  listOpp    List of Opportunities
* @param  mapOldObj    Map of old status Opportunities
*/
public static void setFieldsFromOppTask(List<Opportunity> listNews, Map<Id, Opportunity> mapOlds) {
	

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

		List<AV_CustomActivityOpportunity__c> listOppTask= new List<AV_CustomActivityOpportunity__c>();
		if(
			Schema.SObjectType.AV_CustomActivityOpportunity__c.fields.AV_Opportunity__c.isAccessible() &&
			Schema.SObjectType.AV_CustomActivityOpportunity__c.fields.Name.isAccessible()&&
			Schema.SObjectType.AV_CustomActivityOpportunity__c.fields.AV_Product__c.isAccessible() &&
			Schema.SObjectType.AV_CustomActivityOpportunity__c.fields.AV_Gestor__c.isAccessible()&&
			Schema.SObjectType.AV_CustomActivityOpportunity__c.fields.RecordTypeId.isAccessible() &&
			Schema.SObjectType.AV_CustomActivityOpportunity__c.fields.AV_Priority__c.isAccessible() &&
			Schema.SObjectType.AV_CustomActivityOpportunity__c.fields.AV_ReviewDate__c.isAccessible()&&
			Schema.SObjectType.AV_CustomActivityOpportunity__c.fields.AV_Stage__c.isAccessible() &&
			Schema.SObjectType.AV_CustomActivityOpportunity__c.fields.AV_Valor1__c.isAccessible()&&
			Schema.SObjectType.AV_CustomActivityOpportunity__c.fields.AV_Concepto1__c.isAccessible() &&
			Schema.SObjectType.AV_CustomActivityOpportunity__c.fields.AV_Valor2__c.isAccessible()&&
			Schema.SObjectType.AV_CustomActivityOpportunity__c.fields.AV_Concepto2__c.isAccessible() &&
			Schema.SObjectType.AV_CustomActivityOpportunity__c.fields.AV_Valor3__c.isAccessible() &&
			Schema.SObjectType.AV_CustomActivityOpportunity__c.fields.AV_Concepto3__c.isAccessible()&&
			Schema.SObjectType.AV_CustomActivityOpportunity__c.fields.AV_Valor4__c.isAccessible() &&
			Schema.SObjectType.AV_CustomActivityOpportunity__c.fields.AV_Concepto4__c.isAccessible()&&
			Schema.SObjectType.AV_CustomActivityOpportunity__c.fields.AV_Valor5__c.isAccessible() &&
			Schema.SObjectType.AV_CustomActivityOpportunity__c.fields.AV_Concepto5__c.isAccessible()&&
			Schema.SObjectType.AV_CustomActivityOpportunity__c.fields.AV_DueDate__c.isAccessible() &&
			Schema.SObjectType.AV_CustomActivityOpportunity__c.fields.AV_FeeAmount__c.isAccessible()&&
			Schema.SObjectType.AV_CustomActivityOpportunity__c.fields.AV_Amount__c.isAccessible() &&
			Schema.SObjectType.AV_CustomActivityOpportunity__c.fields.AV_TypeOfInterest__c.isAccessible()&&
			Schema.SObjectType.AV_CustomActivityOpportunity__c.fields.AV_Commentary__c.isAccessible()&&
			Schema.SObjectType.AV_CustomActivityOpportunity__c.fields.AV_IncludeInPrioritizingCustomers__c.isAccessible()&&
			Schema.SObjectType.AV_CustomActivityOpportunity__c.fields.AV_FechaVencimiento__c.isAccessible()
		) {
			listOppTask = [SELECT Id, AV_Opportunity__c, Name, AV_Product__c, AV_Gestor__c, RecordTypeId, RecordType.Name, AV_Priority__c, AV_ReviewDate__c, AV_Stage__c, AV_Valor1__c, AV_Concepto1__c, AV_Valor2__c, AV_Concepto2__c, AV_Valor3__c, AV_Concepto3__c, AV_Valor4__c, AV_Concepto4__c, AV_Valor5__c, AV_Concepto5__c, AV_HoldingAnotherEntity__c, AV_Entity__c, AV_DueDate__c, AV_FeeAmount__c, AV_Amount__c, AV_TypeOfInterest__c, AV_Commentary__c, AV_IncludeInPrioritizingCustomers__c, AV_FechaVencimiento__c FROM AV_CustomActivityOpportunity__c WHERE AV_Opportunity__c IN :listToProcess AND AV_Stage__c in :setOppTaskStage];
		}
		
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
					listOppTaskToProcess.add(oppTaskToProcess);
				}
			}
		}

		if(Schema.sObjectType.AV_CustomActivityOpportunity__c.isUpdateable()){
			Database.update(listOppTaskToProcess, false);
		}
	}
}

	/**
	* Calculate the value of selected currency
	*/
	public static void calculateCurrency(List<Opportunity> listOpp, Map<Id, Opportunity> mapOlds) {
		List<Opportunity> oppDivisa =  new List<Opportunity>();
		if(!listOpp.isEmpty()){
			for(Opportunity opp : listOpp){
				if(opp.CIBE_Divisa__c!=null){
					if(mapOlds != null) { //Update
						if(mapOlds.get(opp.id).CIBE_Divisa__c!=opp.CIBE_Divisa__c || 
                            mapOlds.get(opp.id).CIBE_AmountDivisa__c!=opp.CIBE_AmountDivisa__c ||
                            mapOlds.get(opp.id).CIBE_BalanceDivisa__c!=opp.CIBE_BalanceDivisa__c ||
                            mapOlds.get(opp.id).CIBE_FechaCambioDivisa__c!=opp.CIBE_FechaCambioDivisa__c ||
                            mapOlds.get(opp.id).CIBE_ComisionesDivisa__c!=opp.CIBE_ComisionesDivisa__c ||
                            mapOlds.get(opp.id).CIBE_ImpactoDIvisaBalanceCierreAnio__c!=opp.CIBE_ImpactoDIvisaBalanceCierreAnio__c ||
                            mapOlds.get(opp.id).CIBE_ImpactoDivisaComisionesCierreAnio__c!=opp.CIBE_ImpactoDivisaComisionesCierreAnio__c 
						){
							oppDivisa.add(opp);
						}else if(CIBE_AppConstants.OPPORTUNITY_STATUS_POTENCIAL.equals(opp.StageName) ||
                            CIBE_AppConstants.OPPORTUNITY_STATUS_ENCURSO.equals(opp.StageName) ||
                            CIBE_AppConstants.OPPORTUNITY_STATUS_PENDFIRMA.equals(opp.StageName)){
							oppDivisa.add(opp);
						}else if (
							(CIBE_AppConstants.OPPORTUNITY_STATUS_POTENCIAL.equals(mapOlds.get(opp.id).StageName) ||
							CIBE_AppConstants.OPPORTUNITY_STATUS_ENCURSO.equals(mapOlds.get(opp.id).StageName) ||
							CIBE_AppConstants.OPPORTUNITY_STATUS_PENDFIRMA.equals(mapOlds.get(opp.id).StageName)) && 
							(CIBE_AppConstants.OPPORTUNITY_STATUS_CERRPOSI.equals(opp.StageName) ||
							CIBE_AppConstants.OPPORTUNITY_STATUS_CERRNEGA.equals(opp.StageName) ||
							CIBE_AppConstants.OPPORTUNITY_STATUS_VENCIDO.equals(opp.StageName))
						){
							oppDivisa.add(opp);
						}else if(
							(mapOlds.get(opp.id).CIBE_RenewModificationAmount__c != opp.CIBE_RenewModificationAmount__c || mapOlds.get(opp.id).CIBE_OperationTotalAmount__c != opp.CIBE_OperationTotalAmount__c) && (CIBE_AppConstants.OPPORTUNITY_STATUS_PENDFIRMA.equals(opp.StageName) ||
							CIBE_AppConstants.OPPORTUNITY_STATUS_ENCURSO.equals(opp.StageName))
						){
							oppDivisa.add(opp);
						}

					}else{//insert
						opp.CIBE_FechaCambioDivisa__c = System.today();
						oppDivisa.add(opp);
					}
				}
			}
			if(!oppDivisa.isEmpty()){
				List<CIBE_Divisas__c> listDivisa = new List<CIBE_Divisas__c>();
				if(
					Schema.SObjectType.CIBE_Divisas__c.fields.CIBE_DivisaBase__c.isAccessible() &&
					Schema.SObjectType.CIBE_Divisas__c.fields.CIBE_CodigoDivisa__c.isAccessible()&&
					Schema.SObjectType.CIBE_Divisas__c.fields.CIBE_NombreDivisa__c.isAccessible()&&
					Schema.SObjectType.CIBE_Divisas__c.fields.CIBE_TipoCambio__c.isAccessible()&&
					Schema.SObjectType.CIBE_Divisas__c.fields.CIBE_FechaTipoCambio__c.isAccessible()
				) {
					listDivisa= [SELECT id,CIBE_DivisaBase__c, CIBE_CodigoDivisa__c, CIBE_NombreDivisa__c, CIBE_TipoCambio__c, CIBE_FechaTipoCambio__c FROM CIBE_Divisas__c];
				}
				if(!listDivisa.isEmpty()){
					Map<String, CIBE_Divisas__c> mapDivisas = new Map<String, CIBE_Divisas__c>();
					for(CIBE_Divisas__c divisa:listDivisa){
						mapDivisas.put(divisa.CIBE_CodigoDivisa__c,divisa);
					}
					
					for(Opportunity opp : oppDivisa){
						if(opp.CIBE_Divisa__c!=null){
							if(mapDivisas.get(opp.CIBE_Divisa__c) != null){
								opp.Amount = (opp.CIBE_AmountDivisa__c!=null)?(opp.CIBE_AmountDivisa__c / Decimal.valueOf(mapDivisas.get(opp.CIBE_Divisa__c).CIBE_DivisaBase__c)):0;
								opp.CIBE_Balance__c = (opp.CIBE_BalanceDivisa__c!=null)?(opp.CIBE_BalanceDivisa__c / Decimal.valueOf(mapDivisas.get(opp.CIBE_Divisa__c).CIBE_DivisaBase__c)):0;
								opp.CIBE_Comisiones__c = (opp.CIBE_ComisionesDivisa__c!=null)?(opp.CIBE_ComisionesDivisa__c / Decimal.valueOf(mapDivisas.get(opp.CIBE_Divisa__c ).CIBE_DivisaBase__c)):0;
								opp.CIBE_Impacto_Balance_Cierre_Anio__c = (opp.CIBE_ImpactoDIvisaBalanceCierreAnio__c!=null)?(opp.CIBE_ImpactoDIvisaBalanceCierreAnio__c / Decimal.valueOf(mapDivisas.get(opp.CIBE_Divisa__c).CIBE_DivisaBase__c)):0;
								opp.CIBE_Impacto_Comisiones_Cierre_Anio__c = (opp.CIBE_ImpactoDivisaComisionesCierreAnio__c!=null)?(opp.CIBE_ImpactoDivisaComisionesCierreAnio__c / Decimal.valueOf(mapDivisas.get(opp.CIBE_Divisa__c).CIBE_DivisaBase__c)):0;
								opp.CIBE_TipoCambioDivisa__c = (mapDivisas.get(opp.CIBE_Divisa__c)!=null && mapDivisas.get(opp.CIBE_Divisa__c).CIBE_DivisaBase__c!=null)?(mapDivisas.get(opp.CIBE_Divisa__c).CIBE_DivisaBase__c):null;
								opp.CIBE_FechaCambioDivisa__c = (mapDivisas.get(opp.CIBE_Divisa__c)!=null && mapDivisas.get(opp.CIBE_Divisa__c).CIBE_FechaTipoCambio__c!=null)?(mapDivisas.get(opp.CIBE_Divisa__c).CIBE_FechaTipoCambio__c):null;
								opp.CIBE_OperationTotalAmountEUR__c = (opp.CIBE_OperationTotalAmount__c!=null)?(opp.CIBE_OperationTotalAmount__c / Decimal.valueOf(mapDivisas.get(opp.CIBE_Divisa__c).CIBE_DivisaBase__c)):0;
								opp.CIBE_RenewModificationAmountEUR__c = (opp.CIBE_RenewModificationAmount__c!=null)?(opp.CIBE_RenewModificationAmount__c / Decimal.valueOf(mapDivisas.get(opp.CIBE_Divisa__c).CIBE_DivisaBase__c)):0;

							}
						}
					}
				}
			}
		}
	}	

	/**
	* @description     	Delete AV_CustomActivityOpportunity related with Opportunity
	* @param  deletedOpportunityList  list of delete Opportunity records
	*/
	public static void deleteRecordsRelatedWithOpportunity(List<Opportunity> deletedOpportunityList){

		List<AV_CustomActivityOpportunity__c> custActOppList = [SELECT Id FROM AV_CustomActivityOpportunity__c WHERE AV_Opportunity__c IN :deletedOpportunityList AND Recordtype.DeveloperName = :AV_AppConstants.OPPTASK_RT];
		if(custActOppList.size() > 0) {
			System.enqueueJob(new CIBE_DeleteRelatedOppQueueable(custActOppList));
		}	
	}

	/**
	* @description     	Cuando se modifique dentro de 'Comité': 
						CIBE_PriceApprove__c || CIBE_ApprovalRisk__c != 'Pendiente aprobación'
						el StageName pasará a 'Pendiente de firma'
	* @param  listNews    	List of Opportunities
	* @param  mapOldObj    	Map of old status Opportunities
	*/
	public static void stateOpportunity(List<Opportunity> listNews, Map<Id, Opportunity> mapOlds) {
		List<Opportunity> lstToProcess = new List<Opportunity>();
		if(mapOlds != null) {
			for(Opportunity opp : listNews) {
				String a = opp.RecordType.DeveloperName;
				if(mapOlds.get(opp.id).CIBE_PriceApprove__c != opp.CIBE_PriceApprove__c || mapOlds.get(opp.id).CIBE_ApprovalRisk__c != opp.CIBE_ApprovalRisk__c){
					if((setRtOppCIB.contains(opp.RecordTypeId)) &&  (opp.CIBE_PriceApprove__c != 'Pendiente aprobación' && opp.CIBE_ApprovalRisk__c != 'Pendiente aprobación')){
						opp.StageName = CIBE_AppConstants.OPPORTUNITY_STATUS_PENDFIRMA;	
					}
				}
			}
		}
	}

	/**
	* @description     	Cuando se modifique el owner de la oportunidad se recalcula el campo de ids del opportunity team para CIB
	* @param  listNews  List of Opportunities
	* @param  mapOlds  	Map of old Opportunities
	*/
	public static void setOpportunityUsers(List<Opportunity> listNews, Map<Id, Opportunity> mapOlds) {
		List<Opportunity> process = new List<Opportunity>();
		Set<Id> opportunityIds = new Set<Id>();
		for(Opportunity opp : listNews) {
			if(opp.OwnerId != mapOlds.get(opp.Id).OwnerId) {
				process.add(opp);
				opportunityIds.add(opp.Id);
			}
		}
		if(process!=null && !process.IsEmpty()){
			Map<Id, Set<Id>> userIds = new Map<Id, Set<Id>>();
			if(Schema.SObjectType.OpportunityTeamMember.fields.OpportunityId.isAccessible()) {
				for(OpportunityTeamMember opportunityTM : [SELECT Id, OpportunityId, UserId FROM OpportunityTeamMember WHERE OpportunityId IN :opportunityIds]) {
					if(!userIds.containsKey(opportunityTM.OpportunityId)) {
						userIds.put(opportunityTM.OpportunityId, new Set<Id>());
					}
					userIds.get(opportunityTM.OpportunityId).add(opportunityTM.UserId);
				}
			}

			for(Opportunity opportunity : process) {
				if(!userIds.containsKey(opportunity.Id)) {
					userIds.put(opportunity.Id, new Set<Id>());
				}
				userIds.get(opportunity.Id).add(opportunity.OwnerId);
			}

			List<Opportunity> toUpdate = new List<Opportunity>();
			for(Id opportunityId : userIds.keySet()) {

				toUpdate.add(
					new Opportunity(
						Id = opportunityId,
						CIBE_OpportunityTeam__c = String.join(new List<Id>(userIds.get(opportunityId)), ',')
					));
			}

			Database.SaveResult[] updates = Database.update(toUpdate, false);
			boolean hasError = false;
			List<Object> objs = new List<Object>();
			Map<String, String> msjs = new Map<String, String>();
			for (Integer i = 0; i < toUpdate.size(); i++) {
				Database.SaveResult dr = updates[i];
				if(!dr.isSuccess() && !dr.getErrors().isEmpty()) {
					msjs.put(toUpdate[i].Id, ((String)dr.getErrors()[0].getMessage()));
					objs.add(toUpdate[i]);
					hasError = true;
				}
			}

			if(hasError) {
				CBK_Log.error(msjs, objs);
			}
		}
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
		List<Contact> listGestor 	= new List<Contact>();
		Map<Id, Contact> mapGestor 	= null;
		if(gestorId != null && !gestorId.isEmpty()) {
			listGestor= [Select Id, Name, CC_Matricula__c, AV_UsuarioAsociado__c From Contact Where Id in :gestorId];
			mapGestor = new Map<Id, Contact>(listGestor);
		}
		return mapGestor;
	}
    
    /**
	* @description     insert Task associated with a Opportunity when check on/off 
	* @param  newListOpp  new list of Opportunities
	*/
	public static void insertTaskWithOpp(List<Opportunity> newListOpp) {
        Id rtTaskIniCIB     = (new List<Id>(setRtTaskIniciativa)).get(0);
		Id rtTaskIniEMP   	= (new List<Id>(setRtTaskIniciativa)).get(1);        
        Id rtOppIniCIB     	= (new List<Id>(setRtIniciativa)).get(0);
		Id rtOppIniEMP   	= (new List<Id>(setRtIniciativa)).get(1);
		//US812745
		Id rtOppAlertEMP 	= (new List<Id>(setRtOppEMP)).get(2);
		Set<Id> setRTBypass = new Set<Id>{rtOppAlertEMP};

		Id rtTaskIni;
		Map<Id, Contact> mapGestor;
		Set<String> oppStageNotClosed = new Set<String>{'Potencial','En gestión/insistir'};
		Set<String> oppStageVencido = new Set<String>{'Vencido'};
		List<Task> listTask = new List<Task>();
		List<Opportunity> listUsedOpp = new List<Opportunity>();
		Map<String, Product2> mapProducts = new Map<String, Product2>();
		Map<String, Task> mapTask = new Map<String, Task>();
		//Get the list of product's name
		Set<String> setListIdPF = new Set<String>();
		List<Opportunity> listOppFil = new List<Opportunity>();
		for(Opportunity opp : newListOpp){
			if(opp.AV_OrigenApp__c != AV_AppConstants.CLIENT_REPORT_ORIGENAPP && opp.AV_IncludeInPrioritizingCustomers__c &&
			!setRTBypass.contains(opp.RecordTypeId)){
				setListIdPF.add(opp.AV_PF__c);
				listOppFil.add(opp);
			}
		}
		if(setListIdPF != null && !setListIdPF.isEmpty()){	
			List<Product2> listProduct = [Select Id, Name from Product2 where Id in :setListIdPF];
			mapProducts = new Map<String, Product2>(listProduct);
			mapGestor = getMapGestores(newListOpp);
		}
		//Create task if check is on and "fecha-proximo-recordatorio" is not null
		if (listOppFil != null && !listOppFil.isEmpty()) {
			for(Opportunity opp : listOppFil){					
			if(!setRtOppEMP.contains(opp.RecordTypeId)){
				if(opp.AV_FechaProximoRecordatorio__c != null && opp.AV_FechaProximoRecordatorio__c >= System.today() && opp.StageName != 'CIBE_Vencido'){
					Date activityDate = opp.AV_FechaProximoRecordatorio__c;
					rtTaskIni = opp.RecordTypeId == rtOppIniCIB ? rtTaskIniCIB : rtTaskIniEMP;
					Task tarea = createTareaWithCheckClient(opp, activityDate, rtTaskIni, mapGestor, mapProducts);
					listTask.add(tarea);
					listUsedOpp.add(opp);
					mapTask.put(tarea.AV_ExternalID__c, tarea);
				} else if(opp.AV_FechaProximoRecordatorio__c < System.today()){
					opp.addError(Label.AV_controlFechaRecordatorio);
				}
			}
		}
		}
		if(!listTask.isEmpty()){
			System.enqueueJob(new AV_CheckOnOff_Queueable(listTask, mapTask, listUsedOpp, dateExternalId));
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
		Product2 p2 = new Product2 ();
		dateExternalId = DateTime.now();
		if(opp!=null && String.isNotBlank(opp.AV_ExternalID__c)){
			tarea.AV_ExternalID__c = SUFFIX_EXTERNALID + opp.AV_ExternalID__c + dateExternalId;
		}else{
			tarea.AV_ExternalID__c = SUFFIX_EXTERNALID + opp.Id + dateExternalId;
		}
		if(opp!=null && String.isNotBlank(opp.AccountId)){
			tarea.WhatId = opp.AccountId;
		}
		if(opp!=null && String.isNotBlank(opp.AV_PF__c)){
			p2 = mapProduct.get(opp.AV_PF__c);
		}

		if(activityDate !=null){
			tarea.ActivityDate = activityDate;
			String updateNewFormateDate = activityDate.format();
			tarea.Subject =  p2.Name!=null ? updateNewFormateDate + ' - ' + p2.Name :updateNewFormateDate;
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
	* @description     Update Task associated with a Opportunity when check on/off 
	* @param  listOpp   old list of Opportunities
	* @param  newListOpp  new list of Opportunities
	*/
	public static void updateTaskWithOpp(List<Opportunity> listOpp, Map<Id, Opportunity> mapOldObj) {
		String methodName = 'updateTaskWithOpp';
		//Get recordId AV_Otros for Tasks
		Id rtTaskIni   = (new List<Id>(setRtTaskIniciativa)).get(0);
		//Variable's
		List<Opportunity> listUsedOpp = new List<Opportunity>();
		Map<String, Task> mapNewTask = new Map<String, Task>();
		List<Task> newTask = new List<Task>();
		List<Task> updateTask = new List<Task>();
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
		//Loop to get the Opp and PF ID's
		for(Opportunity opp : listOpp){
			if(opp.AV_OrigenApp__c != AV_AppConstants.CLIENT_REPORT_ORIGENAPP){
				setListIdOpp.add(opp.Id);
				setListIdPF.add(opp.AV_PF__c);
			}
		}
		if(setListIdPF != null && !setListIdPF.isEmpty()){
			List<Product2> listProduct = [Select Id, Name from Product2 where Id in :setListIdPF];
			mapProducts = new Map<String, Product2>(listProduct);
			mapGestor = getMapGestores(listOpp);
		}
		//***************************************************
		//1. Get the related task's (if exist)
		//***************************************************
		if(setListIdOpp != null && !setListIdOpp.isEmpty()){
			Set<String> setListTareaOpp = new Set<String>();
			List<AV_CustomActivityOpportunity__c> listTaskAndOpp = [Select Id, AV_Task__c, AV_IsMain__c, AV_Task__r.AV_ExternalID__c, AV_Opportunity__c from AV_CustomActivityOpportunity__c where AV_IsMain__c = true and AV_Opportunity__c in :setListIdOpp];
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
				lstTask = [SELECT Id, AV_ExternalID__c, Status, IsClosed, ActivityDate, AV_OrigenApp__c, RecordTypeId FROM TASK WHERE AV_ExternalId__c IN :setListTareaOpp AND AV_OrigenApp__c = 'AV_SalesforceTaskOpp'];
				for (Task task : lstTask){
					mapExistTask.put(task.AV_ExternalId__c, task);
				}
				//Check if the relationship is event (this will not check in the process)
				List<Event> lstEvent = [Select Id, AV_ExternalId__c from Event where AV_ExternalId__c in :setListTareaOpp];
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
		if (listOpp != null && !listOpp.isEmpty()) {
			for(Opportunity opp : listOpp) {
				List<String> extIdTask = new List<String>();
				if(mapExtIdTaskOpp != null && !mapExtIdTaskOpp.isEmpty()){
					if (mapExtIdTaskOpp.containsKey(opp.Id)) {
						extIdTask = mapExtIdTaskOpp.get(opp.Id);
					}
				}
				//No exist task -> create task + task-opp if check change OFF to ON
				//if (extIdTask.isEmpty() && opp.AV_FechaProximoRecordatorio__c != null && opp.AV_FechaProximoRecordatorio__c >= System.today() && opp.AV_IncludeInPrioritizingCustomers__c && !mapOldObj.get(opp.Id).AV_IncludeInPrioritizingCustomers__c && oppStageNotClosed.contains(opp.StageName)){

				if(!setRtOppEMP.contains(opp.RecordTypeId)){
					if (extIdTask.isEmpty() && opp.AV_FechaProximoRecordatorio__c != null && opp.AV_FechaProximoRecordatorio__c >= System.today() &&
                    opp.AV_IncludeInPrioritizingCustomers__c && !mapOldObj.get(opp.Id).AV_IncludeInPrioritizingCustomers__c && opp.StageName != 'CIBE_Vencido'){
						
					Date activityDate = opp.AV_FechaProximoRecordatorio__c;
					Task tarea = createTareaWithCheckClient(opp, activityDate, rtTaskIni, mapGestor, mapProducts);
					newTask.add(tarea);
					listUsedOpp.add(opp);
					mapNewTask.put(tarea.AV_ExternalID__c, tarea);
				} else if (!extIdTask.isEmpty()){ //Exist task
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
					if (!listTask.isEmpty()){
						//Check OFF - ON and related tasks is Closed
						boolean newTaskOK = false;
						//if (opp.AV_FechaProximoRecordatorio__c != null && opp.AV_FechaProximoRecordatorio__c >= System.today() && opp.AV_IncludeInPrioritizingCustomers__c && !mapOldObj.get(opp.Id).AV_IncludeInPrioritizingCustomers__c && oppStageNotClosed.contains(opp.StageName) && listTask.size()==contTaskClosed){
						if (opp.AV_FechaProximoRecordatorio__c != null && opp.AV_FechaProximoRecordatorio__c >= System.today() && opp.AV_IncludeInPrioritizingCustomers__c && !mapOldObj.get(opp.Id).AV_IncludeInPrioritizingCustomers__c && opp.StageName != 'CIBE_Vencido' && listTask.size()==contTaskClosed){
							Date activityDate = opp.AV_FechaProximoRecordatorio__c;
							Task tarea = createTareaWithCheckClient(opp, activityDate, rtTaskIni, mapGestor, mapProducts);
							newTask.add(tarea);
							listUsedOpp.add(opp);
							mapNewTask.put(tarea.AV_ExternalID__c, tarea);
							newTaskOK = true;
						}
						//If opp convert to close stage and task is not closed then: check false, blank date and delete task
						//if (!oppStageNotClosed.contains(opp.StageName) && oppStageNotClosed.contains(mapOldObj.get(opp.Id).StageName) && listTask.size()>contTaskClosed && taskNotClosed != null){
						if (opp.StageName == 'CIBE_Vencido' && opp.StageName != mapOldObj.get(opp.Id).StageName && listTask.size()>contTaskClosed && taskNotClosed != null){
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
								updateTask.add(taskNotClosed);
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
					//} else if (opp.AV_FechaProximoRecordatorio__c != null && opp.AV_FechaProximoRecordatorio__c >= System.today() && opp.AV_IncludeInPrioritizingCustomers__c && !mapOldObj.get(opp.Id).AV_IncludeInPrioritizingCustomers__c && oppStageNotClosed.contains(opp.StageName)){
					} else if (opp.AV_FechaProximoRecordatorio__c != null && opp.AV_FechaProximoRecordatorio__c >= System.today() && opp.AV_IncludeInPrioritizingCustomers__c && !mapOldObj.get(opp.Id).AV_IncludeInPrioritizingCustomers__c && opp.StageName != 'CIBE_Vencido'){
						Date activityDate = opp.AV_FechaProximoRecordatorio__c;
						Task tarea = createTareaWithCheckClient(opp, activityDate, rtTaskIni, mapGestor, mapProducts);
						newTask.add(tarea);
						listUsedOpp.add(opp);
						mapNewTask.put(tarea.AV_ExternalID__c, tarea);
					}
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
			System.enqueueJob(new AV_CheckOnOff_Queueable(updateTask));
		}
		//Delete Task-Opp, Header-Task and Task
		if (deleteTareaOpp!=null && !deleteTareaOpp.isEmpty() && deleteHeaderTsk!=null && !deleteHeaderTsk.isEmpty() && deleteTask!=null && !deleteTask.isEmpty()){
			System.enqueueJob(new AV_CheckOnOff_Queueable(deleteTareaOpp,deleteTask,deleteHeaderTsk));
		}
		if (!updateListOpp.isEmpty() && !System.isFuture() && !System.isBatch()) {
			String jsonString = json.serialize(updateListOpp);
			System.enqueueJob(new AV_CheckOnOff_Queueable(updateListOpp));
		}
	}

    /**
    *  	@param description: Method that insert opportunityTeamMember when AV_Book__c = INT
	* 	@param  listOpp   old list of Opportunities
    */
    public static void insertOppTM(List<Opportunity> listOpp, Map<Id, Opportunity> mapOldObj) {
		String userlog = UserInfo.getUserId();
		User user;
		String tipoCartera;
		String carteraCIB;
		String carteraEMP;
		List<String> listaTipoCartera;
        List<OpportunityTeamMember> lstOTMyGest = new List<OpportunityTeamMember>();
		List<OpportunityTeamMember> otraListaDeOTM = new List<OpportunityTeamMember>();
		Account sinCliente = new Account();
		String cliente = CIBE_AppConstants.ACC_SINCLIENTE;

		if(!listOpp.isEmpty() && Schema.SObjectType.Account.fields.Id.isAccessible()){
			try {
				sinCliente = [SELECT Id FROM Account WHERE Name = :cliente AND AV_InterlocName__c = :cliente AND RecordType.DeveloperName =:CIBE_AppConstants.ACCOUNT_CLIENTE_RT LIMIT 1];
			}catch(Exception e) {
				CBK_Log.error(e);
			}
		}

        if(Schema.SObjectType.User.fields.Id.isAccessible()){
            user = [SELECT Id, CIBE_RoleName__c FROM User WHERE Id = :userlog LIMIT 1];
        }
		if (user.CIBE_RoleName__c == 'EMP' ) {
			carteraEMP = CIBE_DataMapping__mdt.getInstance('CIBE_CarteraEMP').CIBE_Value__c;
			listaTipoCartera = carteraEMP.split(',');
			
		}else{
			carteraCIB = CIBE_DataMapping__mdt.getInstance('CIBE_CarteraCIB').CIBE_Value__c;
			listaTipoCartera = carteraCIB.split(',');
		}

		// Mapa (AccountId, Opp)
		Map<Id, Opportunity> mapOpps = new Map<Id, Opportunity>();
		// Mapa Cartera Cliente (AccountId, bookM)
		Map<Id, AV_BookMember__c> mapBookMembers = new Map<Id, AV_BookMember__c>();
		// Mapa Cartera Gestor (IdBookMM, bookMM)
		Map<Id, AV_BookManagementMember__c> mapBookManagementMembers = new Map<Id, AV_BookManagementMember__c>();
		Map<Id, AV_BookManagementMember__c> gestores = new Map<Id, AV_BookManagementMember__c>();
		List<Opportunity> listOppEMP = new List<Opportunity>();
		
		if (!listOpp.isEmpty() && Schema.SObjectType.Opportunity.fields.AccountId.isAccessible()) {
			for (Opportunity opp : listOpp) {

				if(mapOldObj == null || ( sinCliente != null && mapOldObj.get(opp.Id).AccountId == sinCliente.Id && mapOldObj.get(opp.Id).AccountId != opp.AccountId && user.CIBE_RoleName__c != 'EMP')){
					mapOpps.put(opp.AccountId, opp);
				} else if (sinCliente != null && mapOldObj.get(opp.Id).AccountId == sinCliente.Id && mapOldObj.get(opp.Id).AccountId != opp.AccountId && user.CIBE_RoleName__c == 'EMP'){
					listOppEMP.add(opp);
				}
			}
			if (!mapOpps.isEmpty() && Schema.SObjectType.AV_BookMember__c.fields.AV_Cartera__c.isAccessible()) {
				for (AV_BookMember__c bookM : [SELECT Id, AV_Cliente__c, AV_Cartera__c, AV_Cartera__r.AV_TipoCartera__c 
												FROM AV_BookMember__c 
												WHERE AV_Cliente__c = :mapOpps.keySet() AND AV_Cartera__r.AV_TipoCartera__c IN :listaTipoCartera 
												AND AV_Cartera__r.AV_ToDelete__c = false AND AV_ToDelete__c = false
												]) {
					mapBookMembers.put(bookM.AV_Cartera__c, bookM);
				}
				if (!mapBookMembers.isEmpty() && Schema.SObjectType.AV_BookManagementMember__c.fields.AV_Cartera__c.isAccessible()) {
					for (AV_BookManagementMember__c bookMM : 	[SELECT Id, AV_Cartera__c, AV_EmpleadoGestor__c, AV_EmpleadoGestor__r.AV_UsuarioAsociado__c 
																FROM AV_BookManagementMember__c 
																WHERE AV_Cartera__c IN :mapBookMembers.keySet() AND AV_ToDelete__c = false]) {
						if (mapBookMembers.get(bookMM.AV_Cartera__c).AV_Cartera__r.AV_TipoCartera__c == 'INT') {
							gestores.put(bookMM.AV_EmpleadoGestor__c, bookMM);
						} else if (mapBookMembers.get(bookMM.AV_Cartera__c).AV_Cartera__r.AV_TipoCartera__c != 'INT'){
							mapBookManagementMembers.put(bookMM.Id, bookMM);
						}
					}
					List<CIBE_Hierarchy__c> listHierarchy = [SELECT Id, CIBE_Contact__c, CIBE_RedesSegmentos__r.Name, CIBE_Contact__r.AV_UsuarioAsociado__c
															FROM CIBE_Hierarchy__c 
															WHERE CIBE_RedesSegmentos__r.Name = 'Sucursales' and CIBE_Contact__c IN :gestores.keySet()];
					if (!listHierarchy.isEmpty()) {
						for (CIBE_Hierarchy__c hierarchy : listHierarchy) {
							if(gestores.containsKey(hierarchy.CIBE_Contact__c)){
								mapBookManagementMembers.put(gestores.get(hierarchy.CIBE_Contact__c).Id, gestores.get(hierarchy.CIBE_Contact__c));
							}
						}
					}
				}
			}
		}


		List<OpportunityTeamMember> newOppTMs = new List<OpportunityTeamMember>();
		Set<Id> setUserTM = new Set<Id>();
		if (!mapBookManagementMembers.isEmpty()) {
			for(AV_BookManagementMember__c value  : mapBookManagementMembers.values()) {
                if (value.AV_EmpleadoGestor__r?.AV_UsuarioAsociado__c != null ) {
                    OpportunityTeamMember newOppTM = new OpportunityTeamMember();
                    newOppTM.OpportunityId = mapOpps.get(mapBookMembers.get(value.AV_Cartera__c).AV_Cliente__c).Id;
                    newOppTM.UserId = value.AV_EmpleadoGestor__r?.AV_UsuarioAsociado__c;
                    newOppTM.TeamMemberRole = CIBE_AppConstants.PARTICIPANTE;
                    newOppTM.OpportunityAccessLevel = 'Edit';
                    newOppTMs.add(newOppTM);
                    setUserTM.add(value.AV_EmpleadoGestor__r.AV_UsuarioAsociado__c);
                }
			}
		}
		 //Busca e incluye al EAPGestor      
		if (!mapOpps.values().isEmpty()) {
            lstOTMyGest = addRelationshipManager(mapOpps.values(),newOppTMs,setUserTM);
        }
        if (!listOppEMP.isEmpty()) {
            otraListaDeOTM = addRelationshipManager(listOppEMP,newOppTMs,setUserTM);
            for(OpportunityTeamMember otm: otraListaDeOTM){
                if(!lstOTMyGest.contains(otm)){
                    lstOTMyGest.add(otm);
                }
            }
        }
		if(lstOTMyGest != null && lstOTMyGest.isEmpty() && !newOppTMs.isEmpty() ){
			lstOTMyGest = newOppTMs;
		}
		
		boolean hasError = false;
        List<Object> objs = new List<Object>();
        Map<String, String> msjs = new Map<String, String>();
        Database.SaveResult[] lsr = null;
        if(Schema.sObjectType.OpportunityTeamMember.isCreateable() && lstOTMyGest != null && !lstOTMyGest.isEmpty()) {
            lsr = Database.insert(lstOTMyGest, false);
        }

		if(lsr!=null){
            for (Integer i = 0; i < lsr.size(); i++) {
                if(!lsr[i].isSuccess() && !lsr[i].getErrors().isEmpty()) {
                    msjs.put(lstOTMyGest[i].UserId, ((String)lsr[i].getErrors()[0].getMessage()));
                    objs.add(lstOTMyGest[i]);
                    hasError = true;
                }
            }
            if(hasError) {
                CBK_Log.error(msjs, objs);
            }
        }
	}

	/**
	* @description       Crear gestores principales en una oportunidad 
	* @param listOpp 	 List of Opportunities
	* @param  newOppTMs  List of OpportunityTeamMembers
	* @param  setUserTM  Set of Ids of OpportunityTeamMembers 
	*/

	public static List<OpportunityTeamMember> addRelationshipManager(List<Opportunity> listOpp,List<OpportunityTeamMember> newOppTMs,Set<Id> setUserTM) {

		Set<Id> listAccIds =  new Set<Id>();
		for(Opportunity opp : listOpp) {
			listAccIds.add(opp.AccountId);
		}

		Map<Id, Account> mapEAPGestor = new Map<Id, Account>();
		if( Schema.SObjectType.Account.fields.AV_EAPGestor__c.isAccessible()) {
			mapEAPGestor =  new Map<Id, Account>([SELECT Id, name, AV_EAPGestor__r.AV_UsuarioAsociado__c 
			FROM Account 
			WHERE Id IN :listAccIds AND AV_EAPGestor__r.AV_UsuarioAsociado__r.IsActive = true AND AV_EAPGestor__r.AV_UsuarioAsociado__c NOT IN:setUserTM
            ]);
		}			

		for(Opportunity opp : listOpp) {
			if(mapEAPGestor.containsKey(opp.AccountId) && mapEAPGestor.get(opp.AccountId).AV_EAPGestor__c !=null &&
			mapEAPGestor.get(opp.AccountId).AV_EAPGestor__r.AV_UsuarioAsociado__c != null &&
			mapEAPGestor.get(opp.AccountId).AV_EAPGestor__r.AV_UsuarioAsociado__c != opp.OwnerId &&
			!mapEAPGestor.get(opp.AccountId).name.equalsIgnoreCase(CIBE_AppConstants.ACC_SINCLIENTE)) {
				OpportunityTeamMember newAccTM = new OpportunityTeamMember();
				newAccTM.OpportunityId = opp.Id;
				newAccTM.UserId = mapEAPGestor.get(opp.AccountId).AV_EAPGestor__r.AV_UsuarioAsociado__c;
				newAccTM.TeamMemberRole = CIBE_AppConstants.PARTICIPANTE;
				newAccTM.OpportunityAccessLevel = 'Edit';
				newOppTMs.add(newAccTM);
			}
		}
		return newOppTMs;
	}
	
	/**
    *  	@param description: Method that update related Task, Event when AccountId change
	* 	@param  listOpp   list of new Opportunities
	* 	@param  mapOldObj  map old of Opportunities
    */
    public static void updateRelaSobjSinClient(List<Opportunity> listOpp, Map<Id, Opportunity> mapOldObj) {
		Account sinCliente = new Account();
		String cliente = CIBE_AppConstants.ACC_SINCLIENTE;
		Map <Id,AV_CustomActivityOpportunity__c> mapCAO = new Map <Id,AV_CustomActivityOpportunity__c>();
		Map<Id, Opportunity> mapOppU = new Map<Id, Opportunity>();
		Set <Id> setIDTask = new Set<Id>();
		Set <String> setExt = new Set<String>();
		Set <String> setExtUp = new Set<String>();
		String sOppo = null;
		List<SObject> lsTask = new List<SObject> ();
		Map <Id,AV_CustomActivityOpportunity__c> mapTaskCAO = new Map <Id,AV_CustomActivityOpportunity__c>();

		if(!listOpp.isEmpty() && Schema.SObjectType.Account.fields.Id.isAccessible() && !System.isFuture() && !System.isBatch()){
			try{
				sinCliente = [SELECT Id FROM Account WHERE Name = :cliente AND AV_InterlocName__c = :cliente AND RecordType.DeveloperName =:CIBE_AppConstants.ACCOUNT_CLIENTE_RT LIMIT 1];
			}catch(Exception e) {
				CBK_Log.error(e);
			}

			for(Opportunity opp: listOpp){
				if( mapOldObj != null && sinCliente != null && mapOldObj.get(opp.Id).AccountId == sinCliente.Id && opp.AccountId != mapOldObj.get(opp.Id).AccountId){
					mapOppU.put(opp.Id,opp);
				}
			}
		}

		if(mapOppU != null && Schema.SObjectType.AV_CustomActivityOpportunity__c.fields.AV_Task__c.isAccessible() ){
			for(AV_CustomActivityOpportunity__c cao:[SELECT Id,AV_Opportunity__c, AV_Task__c , AV_Task__r.IDTask__c, AV_Task__r.AV_ExternalID__c  FROM AV_CustomActivityOpportunity__c WHERE AV_Opportunity__c IN: mapOppU.values()]){
				if(cao.AV_Task__c !=null){
					mapTaskCAO.put(cao.AV_Task__c,cao);
				}
				if(cao.AV_Task__c !=null && cao.AV_Task__r.IDTask__c !=null ){
					setIDTask.add(cao.AV_Task__r.IDTask__c);
					mapCAO.put(cao.AV_Task__r.IDTask__c,cao);
				}
				if(cao.AV_Task__c !=null && cao.AV_Task__r.AV_ExternalID__c !=null ){
					setExt.add(cao.AV_Task__r.AV_ExternalID__c);
				}
			}

			//IDTask__c
			if(!setIDTask.isEmpty()){
				for(Id seTa:setIDTask){
					if(mapCAO.containsKey(seTa) && mapCAO.get(seTa).AV_Task__r?.AV_ExternalID__c !=null){
						sOppo = mapCAO.get(seTa).AV_Task__r.AV_ExternalID__c.substring(4,22);
					}

					if(seTa !=null && String.valueOf(seTa).startsWith('00T') && mapOppU.get(sOppo).AccountID!=null){
						Task tarea = new Task();
						tarea.Id = seTa;
						tarea.WhatId = mapOppU.get(sOppo).AccountID;
						if(!lsTask.contains(tarea)){
							lsTask.add(tarea);
						}					}
					if(seTa !=null && String.valueOf(seTa).startsWith('00U') && mapOppU.get(sOppo).AccountID!=null){
						Event evento = new Event();
						evento.Id = seTa;
						evento.WhatId = mapOppU.get(sOppo).AccountID;
						if(!lsTask.contains(evento)){
							lsTask.add(evento);
						}
					}
				}
			}

			//AV_ExternalID__c y AV_Task__c
			if(!setExt.isEmpty()){
				for(String seTa:setExt){
					if(seTa.contains('006')){
						sOppo = seTa.substring(5,23);
						setExtUp.add(sOppo);
					}
				}

				for(Task tsk :[SELECT Id, accountId, AV_ExternalID__c,AV_Task__c FROM Task WHERE AV_ExternalID__c IN: setExtUp OR AV_Task__c IN:mapTaskCAO.keySet()]){
					Task tarea = new Task();
					tarea.Id = tsk.id;
					if(mapOppU.containsKey(listOpp[0].Id) && mapOppU.get(listOpp[0].Id).AccountId !=null){
						tarea.WhatId = mapOppU.get(listOpp[0].Id).AccountID;
						if(!lsTask.contains(tarea)){
							lsTask.add(tarea);
						}
					}
				}

				for(Event evt :[SELECT Id,accountId,AV_ExternalID__c,AV_Task__c FROM Event WHERE AV_ExternalID__c IN: setExtUp OR AV_Task__c IN:mapTaskCAO.keySet()]){
					Event evento = new Event();
					evento.Id = evt.Id;
					if(mapOppU.containsKey(mapTaskCAO.get(evt.AV_Task__c).AV_Opportunity__c) && mapOppU.get(mapTaskCAO.get(evt.AV_Task__c).AV_Opportunity__c).AccountId !=null){
						evento.WhatId = mapOppU.get(listOpp[0].Id).AccountID;
						if(!lsTask.contains(evento)){
							lsTask.add(evento);
						}					
					}
				}
			}
		}
		Database.Update(lsTask,false);
	}

	/**
	*  	@param description: Method that update stageName when CloseDate change
	* 	@param  listOpp   list of new Opportunities
	* 	@param  mapOldObj  map old of Opportunities
	*/
	public static void updateStageName(List<Opportunity> listOpp, Map<Id, Opportunity> mapOldObj) {
		
		Set<String> setEstadosCerrados = new Set <String> {CIBE_AppConstants.OPPORTUNITY_STATUS_CERRPOSI,CIBE_AppConstants.OPPORTUNITY_STATUS_CERRNEGA};
		Set<String> setOtrosEstados = new Set <String> {CIBE_AppConstants.OPPORTUNITY_STATUS_POTENCIAL,CIBE_AppConstants.OPPORTUNITY_STATUS_ENCURSO,CIBE_AppConstants.OPPORTUNITY_STATUS_PENDFIRMA};
		Boolean hasCustomPermission = FeatureManagement.checkPermission('AV_AvoidBulkApi');

		for (Opportunity opp : listOpp) {

			Opportunity oldOpp = mapOldObj.get(opp.Id);
			
			if (oldOpp.StageName == CIBE_AppConstants.OPPORTUNITY_STATUS_VENCIDO && opp.CloseDate >= Date.today() && oldOpp.CloseDate != opp.CloseDate ) {
				opp.StageName = 'En curso';

			}else if (setRtOppEMP.contains(opp.RecordTypeId) && oldOpp.StageName == CIBE_AppConstants.OPPORTUNITY_STATUS_VENCIDO && setEstadosCerrados.contains(opp.StageName) && ( opp.CIBE_Visto__c == 'NO' || String.isBlank(opp.CIBE_Visto__c)) ) {
				opp.CloseDate = Date.today();
				
			}else if (!hasCustomPermission && oldOpp.StageName == CIBE_AppConstants.OPPORTUNITY_STATUS_VENCIDO && setOtrosEstados.contains(opp.StageName) && setRtOppCIB.contains(opp.RecordTypeId)) {
				opp.addError(Label.CIBE_CambioEstadoNoPermitido);
			}
		}
	}

	/**
	* @description   object AV_CommentsHistory is updated when a Opportunity with the AV_Comentarios__ field informed is updated
	* @param  listNew  list of new Opportunities 
	* @param  mapOld   map of old Opportunities 
	*/
	public static void updateCommentsHistory(List<Opportunity> listNew, Map<Id, Opportunity> mapOld){
		Map<Id, Opportunity> mapOppEmp = new Map<Id, Opportunity>();
		List<AV_CommentsHistory__c> lstCommHist = new List<AV_CommentsHistory__c>();

		for(Opportunity opp: listNew){
			if(setRtOppEMP.contains(opp.RecordTypeId) ){
				mapOppEmp.put(opp.Id,opp);
			}
		}

		//recuperamos los campos de oportunidad en la query para no recorrer cada Oportunidad por cada CAO 
		List<AV_CustomActivityOpportunity__c> relacionado = [SELECT Id, AV_Task__c, AV_Opportunity__c FROM AV_CustomActivityOpportunity__c WHERE AV_Opportunity__c IN :mapOppEmp.keySet()];

		if(relacionado.isEmpty()){
			DateTime ahora = System.now();
			for(Opportunity opp : mapOppEmp.Values()){
				if(opp.AV_Comentarios__c != null && String.isNotBlank(opp.AV_Comentarios__c) && !opp.AV_Comentarios__c.equals(mapOld.get(opp.Id).AV_Comentarios__c)){
					AV_CommentsHistory__c commHist = new AV_CommentsHistory__c();
					commHist.OwnerId = opp.LastModifiedById;
					commHist.AV_ModificationDate__c = ahora;
					commHist.AV_OldComment__c = mapOld.get(opp.Id).AV_Comentarios__c;
					commHist.AV_NewComment__c = opp.AV_Comentarios__c;
					commHist.AV_OpportunityStatus__c = opp.StageName;
					commHist.AV_AssignedEmployee__c = opp.AV_Gestor__c;
					commHist.AV_Opportunity__c = opp.Id;
					lstCommHist.add(commHist);
				}
				
				if(opp.StageName != null && String.isNotBlank(opp.StageName) && !opp.StageName.equals(mapOld.get(opp.Id).StageName)){
					AV_CommentsHistory__c commHist2 = new AV_CommentsHistory__c();
					commHist2.OwnerId = opp.LastModifiedById;
					commHist2.AV_OldStatus__c = mapOld.get(opp.Id).StageName;
					commHist2.AV_NewStatus__c = opp.StageName;
					commHist2.AV_OpportunityStatus__c = opp.StageName;
					commHist2.AV_AssignedEmployee__c = opp.AV_Gestor__c;
					commHist2.AV_Opportunity__c = opp.Id;
					commHist2.AV_ModificationDate__c = ahora;
					commHist2.AV_NewComment__c = opp.AV_Comentarios__c;
					lstCommHist.add(commHist2);
				}
			}
		}else{
			Set<String> setIdsAvTask = new Set<String>();
			Set<Id> setTasks = new Set<Id>();
			Set<Id> setEvents = new Set<Id>();

			for (AV_CustomActivityOpportunity__c cao : relacionado) {
				if(cao.AV_Task__c!=null){
					setIdsAvTask.add(cao.AV_Task__c);
				}
		}
		
			if(!setIdsAvTask.isEmpty()){
				//buscamos el AV_Task para diferenciar el objeto al que pertenece y rellenamos los sets 
				for(Event evt: [SELECT AV_Task__c FROM Event WHERE AV_Task__c IN :setIdsAvTask]){
					setEvents.add(evt.AV_Task__c);
				}
				for(Task tsk: [SELECT AV_Task__c FROM Task WHERE AV_Task__c IN :setIdsAvTask]){
					setTasks.add(tsk.AV_Task__c);
				}
			}
			DateTime ahora = System.now();
			//recorremos los relacionados para crear su registro de AV_CommentsHistory__c relacionado.
			for (AV_CustomActivityOpportunity__c cao : relacionado) {
						AV_CommentsHistory__c commHist3 = new AV_CommentsHistory__c();
				commHist3.OwnerId = mapOppEmp.get(cao.AV_Opportunity__c).OwnerId;
				commHist3.AV_ModificationDate__c = ahora;
				commHist3.AV_AssignedEmployee__c = mapOppEmp.get(cao.AV_Opportunity__c).AV_Gestor__c;
				commHist3.AV_Opportunity__c = cao.AV_Opportunity__c;
				commHist3.AV_NewComment__c = mapOppEmp.get(cao.AV_Opportunity__c).AV_Comentarios__c;

				if(setEvents !=null && setEvents.contains(cao.AV_Task__c)){
					commHist3.AV_Event__c = cao.AV_Task__c;
				}else if(setTasks !=null && setTasks.contains(cao.AV_Task__c)){
					commHist3.AV_Task__c = cao.AV_Task__c;
						}

				if(mapOppEmp.get(cao.AV_Opportunity__c).AV_Comentarios__c != null && String.isNotBlank(mapOppEmp.get(cao.AV_Opportunity__c).AV_Comentarios__c) && !mapOppEmp.get(cao.AV_Opportunity__c).AV_Comentarios__c.equals(mapOld.get(cao.AV_Opportunity__c).AV_Comentarios__c)){
					commHist3.AV_NewComment__c = mapOppEmp.get(cao.AV_Opportunity__c).AV_Comentarios__c;
					commHist3.AV_OldComment__c = mapOld.get(cao.AV_Opportunity__c).AV_Comentarios__c;
						}

				if(mapOppEmp.get(cao.AV_Opportunity__c).StageName != null && String.isNotBlank(mapOppEmp.get(cao.AV_Opportunity__c).StageName) && !mapOppEmp.get(cao.AV_Opportunity__c).StageName.equals(mapOld.get(cao.AV_Opportunity__c).StageName)){
					commHist3.AV_OldStatus__c = mapOld.get(cao.AV_Opportunity__c).StageName;
					commHist3.AV_NewStatus__c = mapOppEmp.get(cao.AV_Opportunity__c).StageName;
					commHist3.AV_OpportunityStatus__c = mapOppEmp.get(cao.AV_Opportunity__c).StageName;
				}

				if(((mapOppEmp.get(cao.AV_Opportunity__c).AV_Comentarios__c != null && !mapOppEmp.get(cao.AV_Opportunity__c).AV_Comentarios__c.equals(mapOld.get(cao.AV_Opportunity__c).AV_Comentarios__c)) || (mapOppEmp.get(cao.AV_Opportunity__c).StageName != null && !mapOppEmp.get(cao.AV_Opportunity__c).StageName.equals(mapOld.get(cao.AV_Opportunity__c).StageName)))  ){
							lstCommHist.add(commHist3);
						}
					}
				}

		if(Schema.sObjectType.AV_CommentsHistory__c.isCreateable()){
			try{
				Database.insert(lstCommHist);
			}catch(Exception e) {
				CBK_Log.error(e);
			}
		}
	}

	/**
	* @description   object AV_CommentsHistory is created when a new Opportunity with the AV_Comentarios__ field informed is inserted
	* @param  listNew  list of new Opportunities 
	*/
	public static void createCommentsHistory(List<Opportunity> listNew){
		
		List<Opportunity> oppList =  new List<Opportunity>();
		for(Opportunity opp: listNew){
			if(setRtOppEMP.contains(opp.RecordTypeId) ){
				oppList.add(opp);
			}
		}

		List<AV_CommentsHistory__c> lstCommHist = new List<AV_CommentsHistory__c>();
		for(Opportunity opp: oppList){
			if(oppList != null && String.isNotBlank(opp.AV_Comentarios__c)  ){
				AV_CommentsHistory__c commHist = new AV_CommentsHistory__c();
				commHist.OwnerId = opp.LastModifiedById;
				commHist.AV_ModificationDate__c = opp.AV_CommentLastModifiedDate__c;
				commHist.AV_NewComment__c = opp.AV_Comentarios__c;
				commHist.AV_OpportunityStatus__c = opp.StageName;
				commHist.AV_AssignedEmployee__c = opp.AV_Gestor__c;
				commHist.AV_Opportunity__c = opp.Id;
				lstCommHist.add(commHist);
			}
		}
		if(Schema.sObjectType.AV_CommentsHistory__c.isCreateable()){
			try{
				Database.insert(lstCommHist);
			}catch(Exception e) {
				CBK_Log.error(e);
			}
		}
	}

		/**
	* @description     	Delete AV_CommentsHistory objects related With Opportunity
	* @param  deletedOpportunityList  list of delete Opportunity records
	*/
	public static void deleteCommentsHistory(List<Opportunity> deletedOpportunityList){
		List<Opportunity> oppList =  new List<Opportunity>();
		for(Opportunity opp: deletedOpportunityList){
			if(setRtOppEMP.contains(opp.RecordTypeId) ){
				oppList.add(opp);
			}
		}
		List<AV_CommentsHistory__c> commHistList = [SELECT Id FROM AV_CommentsHistory__c WHERE AV_Opportunity__c IN : oppList WITH SECURITY_ENFORCED];
		if(commHistList.size()>0){
			if(Schema.sObjectType.AV_CommentsHistory__c.isDeletable()){
				Database.delete(commHistList,false);			
			}
		}
	}



	/**
	* @description     	Delete deleteRelations objects related With Opportunity
	* @param  deletedOpportunityList  list of delete Opportunity records
	*/
	public static void deleteRelations(List<Opportunity> deletedOpportunityList){
		User currentUser  = [SELECT Name, AV_ProfileName__c FROM User WHERE Id = :UserInfo.getUserId()];
		String profileCu = currentUser.AV_ProfileName__c;
		List<String> oppSet =  new List<String>();
		if(!deletedOpportunityList.isEmpty() && profileCu == 'CIBE_Gestor'){
			List<Opportunity> oppListCIB =  new List<Opportunity>();
			for(Opportunity opp: deletedOpportunityList){
				if(setRtOppEMP.contains(opp.RecordTypeId)){
					oppSet.add(opp.Id);
				}else if(setRtOppCIB.contains(opp.RecordTypeId)){
					oppListCIB.add(opp);
				}
			}

			if(!oppSet.isEmpty()){
				List<AV_CustomActivityOpportunity__c> customActi = [SELECT Id, AV_Task__c FROM AV_CustomActivityOpportunity__c WHERE AV_Opportunity__c IN : oppSet];
				
				if(!customActi.isEmpty()){
					if(Schema.sObjectType.AV_CommentsHistory__c.isDeletable()){
						List<Database.DeleteResult> srList = Database.delete(customActi,false);
						for(Database.deleteResult res : srList) {
							if(!res.isSuccess()) {
								for(Database.Error err : res.getErrors()) {
									CBK_Log.error(err.getStatusCode() + ': ' + err.getMessage());
								}
							}
						}
						
					}
				}
			}else if(!oppListCIB.isEmpty()){
				CIBE_OpportunityTriggerHelper.validateDeleteOpportunity(oppListCIB);
			}
		}

	}
		
	}