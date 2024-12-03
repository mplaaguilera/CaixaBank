/**********************************************************************************************************************
 Name:	  AV_LeadOpportunityTriggerHelper
 Copyright © 2022  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Clase auxiliar de los Triggers de Lead Oportunidad.
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
	VERSION		USER_STORY	                            	AUTHOR		   			DATE			Description
	1.0			US-371544 Estados Lead y LeadOpp	    Vladislav Lityagin	   	11/05/2022		    Init version
    1.1			US-412925 Campo Origen en el Lead	    Vladislav Lityagin	   	24/08/2022		    Added updateLeadsOrigin
	1.2			US336956  Actualizar fecha vencimiento	Vladislav Lityagin		27/09/2022			Added updateLeadOppDueDate
    1.3			US-449777 Campo Comentario	            Elisabeth Rodríguez		28/09/2022			Added validateForbiddenWords method
	1.4			US378818 - Incorporar Tarea automática 	Vladislav Lityagin		14/10/2022			Added createTaskIfOfferIsSent
    1.5                                                 Oscar Moreno            06/02/2024          Control null for the oldStage and oldStatus in the checkLeadOppStage method
***********************************************************************************************************************/
public with sharing class AV_LeadOpportunityTriggerHelper {
    private static AV_AppUtilities.SearchRT rtPPHH   = new AV_AppUtilities.SearchRT(AV_AppConstants.OBJECT_NAME_LEADOPP, AV_AppConstants.LEAD_PPHH_RT);
    private static Set<Id> setRtPPHH = getIdsRT(new Set<AV_AppUtilities.SearchRT>{rtPPHH});
    
       /**
    * @description       Get the ID's of the RT's requested by param
    * @param setRT      List of the RT
    */
	public static Set<Id> getIdsRT(Set<AV_AppUtilities.SearchRT> setRT){
		return AV_AppUtilities.getRecordTypeIdsInSet(setRT);
	}
    
    /**
    * @description		 	Get all owners from Lead Opportunity
    */
    public static Map<Id, User> getOwners(Set<Id> ownerIds){
        return new Map<Id, User>([Select Id, AV_ExternalID__c, ProfileId FROM User where Id in :ownerIds]);
    }
    
    /**
    * @description		 	Get Lead1 from Lead Opportunity
    */
    public static Map<Id, Lead> getLead(Set<Id> leadIds){
        return new Map<Id, Lead>([Select Id, Status, AV_ByPass_VR__c FROM Lead where Id in :leadIds AND RecordType.DeveloperName =: AV_AppConstants.LEAD_PPHH_RT]);
    }
    
    
    /**
    * @description		 	Update Status Lead Opportunity
    * Este metodo es para cuando se hace un insert de LeadOpp
    */
    public static void updateLeadOppStatus(List<AV_LeadOpportunity__c> listNewObj){
        Set<Id> ownerIds = new Set<Id>();
        //Set<Id> leadIds = new Set<Id>();
        
        String methodName = 'updateLeadOppStatus';
        List<AV_LeadOpportunity__c> leadOppToUpdate = new List<AV_LeadOpportunity__c>();
        
        for (AV_LeadOpportunity__c lo : listNewObj) {
            ownerIds.add(lo.OwnerId);
			//leadIds.add(lo.AV_Lead__c);
        }
        
        Map<Id, User> userMap = getOwners(ownerIds);
		//Map<Id, Lead> leadMap = getLead(leadIds);
        
        try{
            for(AV_LeadOpportunity__c lo : listNewObj){
                User uOwner = userMap.get(lo.OwnerId);
                //Lead l = leadMap.get(lo.AV_Lead__c);
               
                 //• NUEVO → Campo automático → Se aplica este estado cuando se ha recibido el Lead y esta pendiente de asignar un empleado en el campo Owner.            
                if(uOwner != null && uOwner.AV_ExternalId__c != null && lo.AV_Status__c != null){
                    if(!lo.AV_Status__c.equals('02') && !uOwner.AV_ExternalId__c.contains('U01')){

                        lo.AV_Status__c = AV_AppConstants.LEADOPP_STATUS_NUEVO;
                        lo.AV_StatusLeadOpp__c = AV_AppConstants.LEADOPP_STAGE_POTENCIAL;
                        leadOppToUpdate.add(lo);
                    }
                }
                
                //•	RECHAZADO → Campo automático → Se aplica este estado cuando el Lead tiene el estado Rechazado. No hace falta lógica, si el lead entra como rechazado asi se va a quedar
                if( lo.AV_Status__c != null){
                    if(lo.AV_Status__c.equals('02')){
                        lo.AV_StatusLeadOpp__c = AV_AppConstants.OPP_STATUS_NOAPTO;
                    }
                }
        	}
        }catch(DmlException e){
			AV_LogDebug.printLogDebug(methodName, 'Error: ' + e.getMessage());
        }
    }
    
     /**
    * @description		 	Update Status Lead Opportunity
    * Este metodo es para las posibilidades cuando se hace un update sobre un LeadOpp
    */
    public static void updateLeadOppStatus(List<AV_LeadOpportunity__c> listNewObj, Map<Id, AV_LeadOpportunity__c> mapOldObj){
        Set<Id> ownerIds = new Set<Id>();
        Set<Id> setLeadIds = new Set<Id>();
        
		Map<Id, User> userMap = new Map<Id, User>();
        Map<Id,Lead> leadMap=new Map<Id,Lead>(); 
       	Boolean hasBulkApi = FeatureManagement.checkPermission('AV_AvoidBulkApi');
       
        
        String methodName = 'updateLeadOppStatus';
        List<AV_LeadOpportunity__c> leadOppToUpdate = new List<AV_LeadOpportunity__c>();
        List <Lead> leadToUpdate=new List<Lead>(); 
        
        for (AV_LeadOpportunity__c lo : listNewObj) {
            ownerIds.add(lo.OwnerId);
        }

        userMap = getOwners(ownerIds);
        
        for(AV_LeadOpportunity__c lo : listNewObj){
            User uOwner = userMap.get(lo.OwnerId);
            
            //•	ENVIADA OFERTA COMERCIAL → Campo automático ->Se aplica este estado cuando se asigna este Lead oportunidad a un empleado (campo Owner informado por un empleado U01XXXXX).
            if(mapOldObj.get(lo.Id).OwnerId != lo.OwnerId){
            if(!String.isEmpty(uOwner.AV_ExternalId__c) && uOwner.AV_ExternalId__c != null && uOwner.AV_ExternalId__c.contains('U01') && !lo.AV_Status__c.equals(AV_AppConstants.LEADOPP_STATUS_ACTIVO) && !lo.AV_Status__c.equals('02')){
                lo.AV_Status__c = AV_AppConstants.LEADOPP_STATUS_ENVIADA;
                }
            }
            
            //•	CERRADO → Campo automático → Al seleccionar las etapas Cerrada Negativa o Cerrada Positiva
            if(mapOldObj.get(lo.Id).AV_StatusLeadOpp__c != lo.AV_StatusLeadOpp__c){
            if(!String.isEmpty(lo.AV_StatusLeadOpp__c) && (lo.AV_StatusLeadOpp__c.equals(AV_AppConstants.LEADOPP_STAGE_POSITIVA) || lo.AV_StatusLeadOpp__c.equals(AV_AppConstants.LEADOPP_STAGE_NEGATIVA))){
                lo.AV_Status__c = AV_AppConstants.LEADOPP_STATUS_CERRADO;
                if(!hasBulkApi){
                    lo.AV_FechaCierreGestion__c = Date.today();
                }
            }
            
            //Si el gestor cambia la etapa a En gestión/insistir poner estado Activo
            if(!String.isEmpty(lo.AV_StatusLeadOpp__c) && lo.AV_StatusLeadOpp__c.equals(AV_AppConstants.LEADOPP_STAGE_GESTION)){
                lo.AV_Status__c = AV_AppConstants.LEADOPP_STATUS_ACTIVO;
                    lo.AV_RejectReason__c = null;
            }
            
                
            if(!String.isEmpty(lo.AV_StatusLeadOpp__c)&&(lo.AV_StatusLeadOpp__c.equals(AV_AppConstants.LEADOPP_STAGE_NO_APTO))){
                lo.AV_Status__c=AV_AppConstants.LEADOPP_STATUS_RECHAZADO;
                lo.AV_RejectReason__c=AV_AppConstants.LEADOPP_STATUS_RECHAZADOTXT;
                setLeadIds.add(lo.AV_Lead__c);
                setLeadIds.add(lo.AV_Lead2__c);
                }
            }
        }
        
        if(setLeadIds != null && !setLeadIds.isEmpty()){
        leadMap = getLead(setLeadIds);
        for (Id key : leadMap.keySet()) {
            Lead l = leadMap.get(key);
            l.AV_ByPass_VR__c = true;
                l.Status=AV_AppConstants.LEADOPP_STATUS_RECHAZADOTXT;
            leadToUpdate.add(l);
        }
        }

        if(!leadToUpdate.isEmpty()){
            List<Database.SaveResult> listUpdateResult=database.update(leadToUpdate);
			AV_AppUtilities.displayErrors('apputilities display error',listUpdateResult);
        }
        
        
    }
    
    
    public static void checkLeadOppStage(Map<Id, AV_LeadOpportunity__c> mapOldObj, List<AV_LeadOpportunity__c> listNewObj){
        String newStage = '';
        String oldStage = '';
        String newStatus = '';
        String oldStatus = '';
		Boolean hasBulkApi = FeatureManagement.checkPermission('AV_AvoidBulkApi');
        for(AV_LeadOpportunity__c leadOpp : listNewObj){
            newStage = leadOpp.AV_StatusLeadOpp__c;
            oldStage = mapOldObj.get(leadOpp.Id).AV_StatusLeadOpp__c;
            newStatus = leadOpp.AV_Status__c;
            oldStatus = mapOldObj.get(leadOpp.Id).AV_Status__c;

            

            if(oldStage != newStage){
                if(newStage!=null){
                    if(!newStage.equals(AV_AppConstants.LEADOPP_STAGE_NEGATIVA) /*&& !oldStage.equals(newStage)*/){
                    leadOpp.AV_Resolution__c = null;
                }

            /*•	Al seleccionar manualmente o automáticamente las etapas de No apto o Vencida se debe informar el campo Fecha cierre gestión con
            la fecha de cuando se ha seleccionado la etapa. */
                if(oldStage == null || (newStage.equals(AV_AppConstants.LEADOPP_STAGE_NO_APTO) || newStage.equals(AV_AppConstants.LEADOPP_STAGE_VENCIDA))){  
                    if(!hasBulkApi){
                    	leadOpp.AV_FechaCierreGestion__c = Date.today();
                    }
                }
            //Informar Fecha Cierre Gestion si no viene de Cerrado Positivo a Con venta.
                    if(oldStage== null || (!oldStage.equals(AV_AppConstants.LEADOPP_STAGE_POSITIVA) && newStage.equals(AV_AppConstants.LEADOPP_STAGE_VENTA) && mapOldObj.get(leadOpp.Id).AV_FechaCierreGestion__c==null)){  
                       
                        if(!hasBulkApi){
                    	leadOpp.AV_FechaCierreGestion__c = Date.today();
                    }
            	} 
            }
            }
            
            if(oldStatus != newStatus){
                /*•	Si se activa un Lead Oportunidad cerrado o rechazado se debería eliminar la información de este campo  */
                if((oldStatus == null || oldStatus.equals(AV_AppConstants.LEADOPP_STATUS_CERRADO) || oldStatus.equals('02')) && newStatus.equals(AV_AppConstants.LEADOPP_STATUS_ACTIVO)){  
                    leadOpp.AV_FechaCierreGestion__c = null;
                }
            }
        }
    }
    
    public static void updateLeadsOrigin(List<AV_LeadOpportunity__c> listNewObj, Map<Id, AV_LeadOpportunity__c> mapOldObj){
        //Actualizar Origen Titulares 1 y 2
        Set<Id> leadIds = new Set<Id>();
        List<Lead> leadsToUpdate = new List<Lead>();
		Map<Id, String> mapLeads = new Map<Id, String>();
        
        //En caso de insert
        if(mapOldObj==null){
        for(AV_LeadOpportunity__c lo : listNewObj){
            String origen = lo.AV_PrescriberId__c;
            
            if(lo.AV_Lead__c != null){
                leadIds.add(lo.AV_Lead__c);
                mapLeads.put(lo.AV_Lead__c, origen);
            }
            
            if(lo.AV_Lead2__c != null){
                leadIds.add(lo.AV_Lead2__c);
                mapLeads.put(lo.AV_Lead2__c, origen);
            }
        }
        }else{
            for(AV_LeadOpportunity__c lo : listNewObj){
                String origen = lo.AV_PrescriberId__c;
                if(mapOldObj.get(lo.Id).AV_PrescriberId__c != lo.AV_PrescriberId__c){
                    if(lo.AV_Lead__c != null){
                        leadIds.add(lo.AV_Lead__c);
                        mapLeads.put(lo.AV_Lead__c, origen);
                    }
        
                    if(lo.AV_Lead2__c != null){
                        leadIds.add(lo.AV_Lead2__c);
                        mapLeads.put(lo.AV_Lead2__c, origen);
                    }
                }
            }
        }
        if(leadIds!=null && !leadIds.isEmpty()){
            List<Lead> listLeads = [SELECT Id, AV_Origin__c FROM Lead WHERE Id in :leadIds AND RecordType.DeveloperName =: AV_AppConstants.LEAD_PPHH_RT];
        
            for(Lead l : listLeads){
                String origen = mapLeads.get(l.Id);
                if(origen!=null && !String.isEmpty(origen)){
                    l.AV_Origin__c = origen; 
                    leadsToUpdate.add(l);
                }
            }
        }
        
        if(!leadsToUpdate.isEmpty()){
            List<Database.SaveResult> listUpdateResult=database.update(leadsToUpdate);
			AV_AppUtilities.displayErrors('apputilities display error',listUpdateResult);
        }
    }
    
     public static void updateLeadOppDueDate(List<AV_LeadOpportunity__c> listNewObj){
         
        //Informar Fecha de vencimiento = Fecha Inicio + 30 dias
        List<AV_LeadOpportunity__c> leadsOppWith2HoldersToUpdate = new List<AV_LeadOpportunity__c>();
        List<AV_LeadOpportunity__c> leadsOpppWithHolder1ToUpdate = new List<AV_LeadOpportunity__c>();
        List<AV_LeadOpportunity__c> leadsOpppWithHolder2ToUpdate = new List<AV_LeadOpportunity__c>();
        for(AV_LeadOpportunity__c lo : listNewObj){
            if(lo.AV_CreationDate__c != null){
                if(lo.AV_Lead__c != null && lo.AV_Lead2__c == null){
                    leadsOpppWithHolder1ToUpdate.add(lo);
                }
                if(lo.AV_Lead__c == null && lo.AV_Lead2__c != null){
                    leadsOpppWithHolder2ToUpdate.add(lo);
                }
                if(lo.AV_Lead__c != null && lo.AV_Lead2__c != null){
                    leadsOppWith2HoldersToUpdate.add(lo);
                }
            }
        }
         
         if(leadsOpppWithHolder1ToUpdate.size()>0){
             checkHolderIsClient(leadsOpppWithHolder1ToUpdate,'holder1');
         }
         if(leadsOpppWithHolder2ToUpdate.size()>0){
             checkHolderIsClient(leadsOpppWithHolder2ToUpdate,'holder2');
         }
         if(leadsOppWith2HoldersToUpdate.size()>0){
             checkHolderIsClient(leadsOppWith2HoldersToUpdate,'2holders');
         }
    }
    
    public static void checkHolderIsClient(List<AV_LeadOpportunity__c> leadOppList, String typeOfHolder){
        /*LeadOpp - Before Insert (AV_CreationDate__c + 30) en la fecha de vencimiento
        ###### Existe el Lead 1 y el Lead1. isclient = false -->  fecha de vencimiento Lead =  fecha de vencimiento del LeadOpp
        Existe el Lead 2 y el Lead2. isclient = false -->  fecha de vencimiento Lead 2 =  fecha de vencimiento del LeadOpp
        Si existe Lead 1 y Lead 2 y ambos isclient = true -> fecha de vencimiento opp vacia
        Si existe Lead 1 y no existe Lead 2 y Lead 1 isclient = true  -> fecha de vencimiento opp vacia
        Si existe Lead 2 y no existe Lead 1 y Lead 2 is client =  true   -> fecha de vencimiento opp vacia*/
        
        Map<Id, AV_LeadOpportunity__c> lead1Ids = new Map<Id, AV_LeadOpportunity__c>();
        Map<Id, AV_LeadOpportunity__c> lead2Ids = new Map<Id, AV_LeadOpportunity__c>();
        Map<Id, AV_LeadOpportunity__c> holdersLead1And2Id = new Map<Id, AV_LeadOpportunity__c>();
        
        Set<Id> setLead1Ids = new Set<Id>();
        Set<Id> setLead2Ids = new Set<Id>();
        Set<Id> setHoldersLead1And2Id = new Set<Id>();
                
        if(typeOfHolder.equals('holder1')){
            for(AV_LeadOpportunity__c lo : leadOppList){
                lead1Ids.put(lo.AV_Lead__c, lo);
                setLead1Ids.add(lo.AV_Lead__c);
            }

			List<Lead> leadsToUpdate = new List<Lead>();
            List<Lead> listLeads = [SELECT Id, AV_IsClient__c, AV_DueDateLead__c FROM Lead WHERE Id in :setLead1Ids AND RecordType.DeveloperName =: AV_AppConstants.LEAD_PPHH_RT];
            
            for(Lead l : listLeads){
                AV_LeadOpportunity__c lo = lead1Ids.get(l.Id);
                //Existe el Lead 1 y el Lead1. isclient = false -->  fecha de vencimiento Lead =  fecha de vencimiento del LeadOpp
                if(!l.AV_IsClient__c){
                    Date creationDate = Date.newinstance(lo.AV_CreationDate__c.year(), lo.AV_CreationDate__c.month(), lo.AV_CreationDate__c.day());
					Date dueDateLeadOpp = creationDate.addDays(30);
                	lo.AV_DueDate__c = dueDateLeadOpp; 
                    
                    l.AV_DueDateLead__c = dueDateLeadOpp;
                    leadsToUpdate.add(l);
                }
            }
            
            if(!leadsToUpdate.isEmpty()){
                List<Database.SaveResult> listUpdateResult=database.update(leadsToUpdate);
                AV_AppUtilities.displayErrors('apputilities display error',listUpdateResult);
        	}
            
        }
        
        if(typeOfHolder.equals('holder2')){
            for(AV_LeadOpportunity__c lo : leadOppList){
                lead2Ids.put(lo.AV_Lead2__c, lo);
                setLead2Ids.add(lo.AV_Lead2__c);
            }
            
            List<Lead> leadsToUpdate = new List<Lead>();
            List<Lead> listLeads = [SELECT Id, AV_IsClient__c, AV_DueDateLead__c FROM Lead WHERE Id in :setLead2Ids AND RecordType.DeveloperName =: AV_AppConstants.LEAD_PPHH_RT];
            
            for(Lead l : listLeads){
                AV_LeadOpportunity__c lo = lead2Ids.get(l.Id);
                //Existe el Lead 1 y el Lead1. isclient = false -->  fecha de vencimiento Lead =  fecha de vencimiento del LeadOpp
                if(!l.AV_IsClient__c){
                    Date creationDate = Date.newinstance(lo.AV_CreationDate__c.year(), lo.AV_CreationDate__c.month(), lo.AV_CreationDate__c.day());
                    Date dueDateLeadOpp = creationDate.addDays(30);
                    lo.AV_DueDate__c = dueDateLeadOpp; 
                    
                    l.AV_DueDateLead__c = dueDateLeadOpp;
                    leadsToUpdate.add(l);
                }
            }
            
            if(!leadsToUpdate.isEmpty()){
                List<Database.SaveResult> listUpdateResult=database.update(leadsToUpdate);
                AV_AppUtilities.displayErrors('apputilities display error',listUpdateResult);
        	}
        }
        
        if(typeOfHolder.equals('2holders')){
            for(AV_LeadOpportunity__c lo : leadOppList){
                holdersLead1And2Id.put(lo.AV_Lead__c, lo);
                holdersLead1And2Id.put(lo.AV_Lead2__c, lo);
                setHoldersLead1and2Id.add(lo.AV_Lead__c);
                setHoldersLead1and2Id.add(lo.AV_Lead2__c);

            }
            
            List<Lead> leadsToUpdate = new List<Lead>();
            List<Lead> listLeads = [SELECT Id, AV_IsClient__c, AV_DueDateLead__c FROM Lead WHERE Id in :setHoldersLead1and2Id AND RecordType.DeveloperName =:AV_AppConstants.LEAD_PPHH_RT];
            
            for(Lead l : listLeads){
                AV_LeadOpportunity__c lo = holdersLead1And2Id.get(l.Id);
                //Existe el Lead 1 y el Lead1. isclient = false -->  fecha de vencimiento Lead =  fecha de vencimiento del LeadOpp
                if(!l.AV_IsClient__c){
                    Date creationDate = Date.newinstance(lo.AV_CreationDate__c.year(), lo.AV_CreationDate__c.month(), lo.AV_CreationDate__c.day());
                    Date dueDateLeadOpp = creationDate.addDays(30);
                    lo.AV_DueDate__c = dueDateLeadOpp;
                    
                    l.AV_DueDateLead__c = dueDateLeadOpp;
                    leadsToUpdate.add(l);
                }
            }
            
            if(!leadsToUpdate.isEmpty()){
                List<Database.SaveResult> listUpdateResult=database.update(leadsToUpdate);
                AV_AppUtilities.displayErrors('apputilities display error',listUpdateResult);
        	}
        }
    }

    /**
    * @description     Validate forbidden words in AV_LeadOpportunity__c field 
    * @param  listNews  list of new AV_LeadOpportunity__c records
    * @param mapOlds map of old AV_LeadOpportunity__c records
    */
	/*public static void validateForbiddenWords(List<AV_LeadOpportunity__c> listNews, Map<Id, AV_LeadOpportunity__c> mapOlds) {
		List<AV_LeadOpportunity__c> listToProcess = new List<AV_LeadOpportunity__c>();
		Set<String> setFields = new Set<String>{'AV_Comment__c', 'Name'};
			if(mapOlds != null && !mapOlds.isEmpty()) {
				for(AV_LeadOpportunity__c leadOpportunity : listNews) {
					if( (String.isNotBlank(leadOpportunity.AV_Comment__c) && mapOlds.get(leadOpportunity.Id).AV_Comment__c != leadOpportunity.AV_Comment__c) || (String.isNotBlank(leadOpportunity.Name) && mapOlds.get(leadOpportunity.Id).Name != leadOpportunity.Name)) {
						listToProcess.add(leadOpportunity);
					}
				}
			} else {
				for(AV_LeadOpportunity__c leadOpportunity : listNews) {
					if( String.isNotBlank(leadOpportunity.AV_Comment__c) || String.isNotBlank(leadOpportunity.Name)) {
						listToProcess.add(leadOpportunity);
					}
				}
			}
		if(listToProcess!=null && !listToProcess.isEmpty()) {
			AV_ForbiddenWords.validateRecords(listToProcess, setFields);
		}
	}*/



    /**
    * @description     Change Product field  
    * @param  listNews  list of new AV_LeadOpportunity__c records
    */
    public static void changeProduct(List<AV_LeadOpportunity__c> listNews) {
        try{
            Product2 productoHipoteca=[Select Id from Product2 where AV_ExternalID__c='50030' limit 1];
            
            if(productoHipoteca!=null){
                for(AV_LeadOpportunity__c leadOpportunity : listNews) {
				leadOpportunity.AV_Producto__c = productoHipoteca.Id;
				}
            }
            
        }catch(QueryException e){
            AV_LogDebug.printException('changeProduct', e);
        }
	}
    
    public static void createTaskIfOfferIsSent(Map<Id, AV_LeadOpportunity__c> mapOldObj, List<AV_LeadOpportunity__c> listNewsObj){
        Id rt = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName(AV_AppConstants.OBJECT_NAME_TASK, AV_AppConstants.TASKAVISOS_RT);
        //Recorrer los leads Oportunidad y si tiene estado envio of comercial = Sent y además isClient del titular = true crear nuev tarea
        Map<Id, AV_LeadOpportunity__c> leadsOppMap = new Map<Id, AV_LeadOpportunity__c>();
       
        for(AV_LeadOpportunity__c lo : listNewsObj){
            if(mapOldObj != null){
                AV_LeadOpportunity__c loOld = mapOldObj.get(lo.Id);
                if(loOld.AV_EstadoEnvioOfComercial__c != lo.AV_EstadoEnvioOfComercial__c){
                    if(lo.AV_EstadoEnvioOfComercial__c!=null && lo.AV_EstadoEnvioOfComercial__c.equals(AV_AppConstants.LEADOPP_OFFER_STATUS_SENT)){
                    if(lo.AV_Lead__c!=null){
                        leadsOppMap.put(lo.AV_Lead__c, lo);
                    }
                    if(lo.AV_Lead2__c!=null){
                        leadsOppMap.put(lo.AV_Lead2__c, lo);
                        }
                    }
                }
            }else{
                if(lo.AV_EstadoEnvioOfComercial__c!=null && lo.AV_EstadoEnvioOfComercial__c.equals(AV_AppConstants.LEADOPP_OFFER_STATUS_SENT)){
                    if(lo.AV_Lead__c!=null){
                        leadsOppMap.put(lo.AV_Lead__c, lo);
                    }
                    if(lo.AV_Lead2__c!=null){
                        leadsOppMap.put(lo.AV_Lead2__c, lo);
                    }
                }
            }
        }
        
        Set<Id> leadIds = leadsOppMap.keySet();
        List<Lead> leadsList = [SELECT Id, AV_numperso__c FROM Lead WHERE Id in :leadIds AND AV_IsClient__c=true AND RecordType.DeveloperName =: AV_AppConstants.LEAD_PPHH_RT];
        List<Task> taskToInsert = new List<Task>();
        //Recorrer la lista para crear las tareas
        for(Lead l : leadsList){
            AV_LeadOpportunity__c lo = leadsOppMap.get(l.Id);
            if(lo.AV_EstadoEnvioOfComercial__c!= null && lo.AV_EstadoEnvioOfComercial__c.equals(AV_AppConstants.LEADOPP_OFFER_STATUS_SENT)){
                if(l.AV_numperso__c != null){
                    //Crear la tarea
                	Task t = new Task(
                	Status = AV_AppConstants.GESTIONADO_POSITIVO_ESTADO,
                    CC_Fecha_Vencimiento__c = Date.today(),
                    Subject = 'Cliente contactado por NOW IN SALES',
                	Description = 'Cliente contactado por el centro 4223 – Now In Sales por solicitud de préstamo hipotecario a través de PHD (Plataforma Hipotecaria Digital).',
                    OwnerId = lo.OwnerId,
                    AV_Center__c = '04223',
                    AV_Tipo__c = AV_AppConstants.LLAMADA_TIPO,
                    Priority = 'M',
                    RecordTypeId = rt,
                    //Comentario tarea relacionada
                    WhatId = l.AV_numperso__c,
                    AV_OrigenApp__c = 'AV_NowIn',
                    ActivityDate = Date.today()
                );
                taskToInsert.add(t);
                }
            }
        }
        if(!taskToInsert.isEmpty()){
            
            insert taskToInsert;
        }
    }
    
    public static List<AV_LeadOpportunity__c> checkMortgagePlatformRT(List<AV_LeadOpportunity__c> listNews){
        List<AV_LeadOpportunity__c> listData = new List<AV_LeadOpportunity__c>();
		for(AV_LeadOpportunity__c dataNew : listNews){
			if((setRtPPHH).contains(dataNew.RecordTypeId)){
				listData.add(dataNew);
			}
		}
		return listData;
    }
}