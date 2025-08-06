/**************************************************************************************************************************************************
 Name:	  AV_LeadTriggerHelper
 Copyright © 2022  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Clase auxiliar de los Triggers de Lead.
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
	VERSION		USER_STORY	                            						AUTHOR		   			DATE				Description
	1.0			US-371544 Estados Lead y LeadOpp	    					Vladislav Lityagin	   	12/05/2022		    	Init version
	1.1			US-336956 Logica Fecha Vencimiento y marca Cliente			Vladislav Lityagin		21/06/2022
	1.2			US-379346 Campos Fecha Cierre Gestion Y fecha conversion	Alex Cubells			11/07/2022
	1.3			US336956  Logica Fecha Vencimiento y marca Cliente			Vladislav Lityagin		07/10/2022				Added checkDueDate, checkLeadOpportunityHolders
	1.4			US378818 - Incorporar Tarea automática 						Vladislav Lityagin		14/10/2022				Added checkIfOfferIsSent
    1.5                                                                     Oscar Moreno            12/02/2024              Modify checkStatus

***************************************************************************************************************************************************/
public with sharing class AV_LeadTriggerHelper {
    
	private static AV_AppUtilities.SearchRT rtPPHH   = new AV_AppUtilities.SearchRT(AV_AppConstants.OBJECT_NAME_LEAD, AV_AppConstants.LEAD_PPHH_RT);
    private static Set<Id> setRtPPHH = getIdsRT(new Set<AV_AppUtilities.SearchRT>{rtPPHH});

   /**
    * @description       Get the ID's of the RT's requested by param
    * @param setRT      List of the RT
    */
	public static Set<Id> getIdsRT(Set<AV_AppUtilities.SearchRT> setRT){
		return AV_AppUtilities.getRecordTypeIdsInSet(setRT);
	}
    
    /**
    * @description		 	Update Status Lead
    */
    
    public static void updateLeadStatus(List<Lead> listNewObj, Map<Id, Lead> mapOldObj){
        String methodName = 'updateLeadStatus';
        Set<Id> leadIsClientIds = new Set<Id>();
        for(Lead l : listNewObj){
            Lead lOld = mapOldObj.get(l.Id);
            
            if(!lOld.AV_IsClient__c && l.AV_IsClient__c){
                l.AV_FechaConversionCliente__c = Date.today();
                Boolean hasCustomPermission = FeatureManagement.checkPermission('AV_AvoidBulkApi');
                l.AV_ByPass_VR__c = true;
                l.Status = 'Convertido';
                leadIsClientIds.add(l.Id);
            }
        }
        if(!leadIsClientIds.isEmpty()){
         	checkIfOfferIsSent(leadIsClientIds);
        }
    }
    
     /**
    * @description		 	Reset bypass vr Lead
    */
    public static void resetBypass(List<Lead> listNewObj, Map<Id, Lead> mapOldObj){
        String methodName = 'resetBypass';  
        for(Lead l : listNewObj){
            Lead lOld = mapOldObj.get(l.Id);
            if(lOld.AV_byPass_VR__c || l.AV_ByPass_VR__c){
                l.AV_ByPass_VR__c = false;
            }
        }
    }

    /**
    * @description		 Trow error if Manager changes Lead status from Layout 
    */
    public static void checkStatus(List<Lead> listNew, Map<Id, Lead> mapOld) {
        Id profileId = UserInfo.getProfileId();
        List<Profile> profiles = [SELECT Name FROM Profile WHERE Id =: profileId LIMIT 1];
        
        if (!profiles.isEmpty()) {  
            Profile profile = profiles[0];
            if (profile.Name.equals('AV_Usuario_CaixaBank')) {
                for (Lead l : listNew) {
                    if (!l.Status.equalsIgnoreCase(mapOld.get(l.Id).Status)) {
                        if (!l.AV_ByPass_VR__c) {
                            l.addError('No se puede modificar el estado del Lead.');
                        }
                        l.AV_ByPass_VR__c = mapOld.get(l.Id).AV_ByPass_VR__c ? false : mapOld.get(l.Id).AV_ByPass_VR__c;
                    }
                }
            }
        }
    }
    
    
      /**
    * @description		 	Check due date used for insert and update
    */
    public static void checkDueDate(List<Lead> listNewObj, Map<Id, Lead> mapOldObj){
        String methodName = 'checkDueDate';  
        Set<Id> leadIds = new Set<Id>();
        
        for(Lead l : listNewObj){
        	Lead lOld = mapOldObj.get(l.Id);
            if(!lOld.AV_IsClient__c && l.AV_IsClient__c){
            	l.AV_DueDateLead__c = null;
                leadIds.add(l.Id);
			}
		}

        if(leadIds != null && !leadIds.isEmpty()){
            checkLeadOpportunityHolders(leadIds);
        }
    }
    
    @TestVisible
    private static void checkLeadOpportunityHolders(Set<Id> leadIds){
        
        List<AV_LeadOpportunity__c> listLeadOpp = [SELECT Id, AV_DueDate__c, AV_StatusLeadOpp__c, AV_Lead__c, AV_Lead2__c, AV_Lead__r.AV_IsClient__c, AV_Lead2__r.AV_IsClient__c FROM AV_LeadOpportunity__c WHERE (AV_Lead__c in :leadIds OR AV_Lead2__c in :leadIds) AND RecordType.DeveloperName =: AV_AppConstants.LEAD_PPHH_RT];
        List<AV_LeadOpportunity__c> leadOppToUpdate = new List<AV_LeadOpportunity__c>();

        if(listLeadOpp.size()>0){
            for(AV_LeadOpportunity__c lo : listLeadOpp){
                //Comprobar si el lead opp tiene un titular, segundo titular o los dos titulares
                //Solo tiene un titular y es Lead1
                if(lo.AV_Lead__c!=null && lo.AV_Lead2__c==null){
                    //Blanquear fecha y poner en gestión insistir
                    lo.AV_DueDate__c = null;
                    lo.AV_StatusLeadOpp__c = AV_AppConstants.LEADOPP_STAGE_GESTION;
                    leadOppToUpdate.add(lo);
                }
                //Solo tiene un titular y es Lead2
                if(lo.AV_Lead__c==null && lo.AV_Lead2__c!=null){
                    //Blanquear fecha y poner en gestión insistir
                    lo.AV_DueDate__c = null;
                    lo.AV_StatusLeadOpp__c = AV_AppConstants.LEADOPP_STAGE_GESTION;
                    leadOppToUpdate.add(lo);
                }
                //Tiene ambos titulares
                if(lo.AV_Lead__c!=null && lo.AV_Lead2__c!=null){
                    //Tienen que ser clientes ambos titulares para cambiar a En gestion/insistir la etapa del lead
                    if(lo.AV_Lead__r.AV_IsClient__c==true && lo.AV_Lead2__r.AV_IsClient__c==false){
                        //Blanquear fecha y poner en gestión insistir
                        lo.AV_DueDate__c = null;
                        lo.AV_StatusLeadOpp__c = AV_AppConstants.LEADOPP_STAGE_GESTION;
                        leadOppToUpdate.add(lo);
                    }else if(lo.AV_Lead__r.AV_IsClient__c==false && lo.AV_Lead2__r.AV_IsClient__c==true){
                        //Blanquear fecha y poner en gestión insistir
                        lo.AV_DueDate__c = null;
                        lo.AV_StatusLeadOpp__c = AV_AppConstants.LEADOPP_STAGE_GESTION;
                        leadOppToUpdate.add(lo);
                    }   
                }
            }

            if(!leadOppToUpdate.isEmpty()){
                List<Database.SaveResult> listUpdateResult=database.update(leadOppToUpdate);
                AV_AppUtilities.displayErrors('apputilities display error',listUpdateResult);
            }
        }
    }
    
    public static void checkIfOfferIsSent(Set<Id> leadIds){
        Id rt = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName(AV_AppConstants.OBJECT_NAME_TASK, AV_AppConstants.TASKAVISOS_RT);
		List<Task> taskToInsert = new List<Task>();
        List<AV_LeadOpportunity__c> listLeadOpp = [SELECT Id, AV_EstadoEnvioOfComercial__c, OwnerId, AV_Lead__r.AV_numperso__c,  AV_Lead2__r.AV_numperso__c FROM AV_LeadOpportunity__c WHERE (AV_Lead__c in :leadIds OR AV_Lead2__c in :leadIds) AND (AV_Lead__r.AV_IsClient__c = FALSE OR AV_Lead2__r.AV_IsClient__c = FALSE) AND RecordType.DeveloperName =: AV_AppConstants.LEAD_PPHH_RT];

        if(!listLeadOpp.isEmpty()){
			for(AV_LeadOpportunity__c lo : listLeadOpp){
                //Crear la tarea
                Task t = new Task(
                    Status = AV_AppConstants.GESTIONADO_POSITIVO_ESTADO,
                    CC_Fecha_Vencimiento__c = Date.today(),
                    Subject = 'Cliente contactado por NOW IN SALES',
                    Description = 'Cliente contactado por el centro 4223 – Now In Sales por solicitud de préstamo hipotecario a través de PHD (Plataforma Hipotecaria Digital).',
                    OwnerId = lo.OwnerId,
                    AV_Center__c = '04223 - NOW IN SALES',
                    AV_Tipo__c = AV_AppConstants.LLAMADA_TIPO,//Llamada
                    Priority = 'M',
                    RecordTypeId = rt,
                    //WhatId = lo.AV_Lead__r.AV_numperso__c,
                    AV_OrigenApp__c = 'AV_NowIn',
                    ActivityDate = Date.today()
                );
                if(lo.AV_EstadoEnvioOfComercial__c != null && lo.AV_EstadoEnvioOfComercial__c.equals(AV_AppConstants.LEADOPP_OFFER_STATUS_SENT)){
                    if(lo.AV_Lead__r.AV_numperso__c != null){
                        t.WhatId = lo.AV_Lead__r.AV_numperso__c;
                        taskToInsert.add(t);
                    }
                    if(lo.AV_Lead2__r.AV_numperso__c != null){
                        t.WhatId = lo.AV_Lead2__r.AV_numperso__c;
                        taskToInsert.add(t);
                    }
                }
        	}
        }
        
        if(!taskToInsert.isEmpty()){
            insert taskToInsert;
        }
    }
    
    public static List<Lead> checkMortgagePlatformRT(List<Lead> listNews){
        List<Lead> listData = new List<Lead>();
		for(Lead dataNew : listNews){
			if((setRtPPHH).contains(dataNew.RecordTypeId)){
				listData.add(dataNew);
			}
		}
		return listData;
    }
    
}