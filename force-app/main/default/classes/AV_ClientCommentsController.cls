/**********************************************************************************************************************
Name:	  AV_ClientCommentsController
Copyright © 2019  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Clase controladora de los componentes "av_ClientComments"
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
    VERSION		USER_STORY		AUTHOR			DATE			Description
    1.0			US147562		Álvaro López	20/01/2021		Init version
    1.1			US147315		Sandra Gómez	15/03/2021		Add recordId in CommentItem and remove condition AV_CommentLastModifiedDate__c
	1.2			FIX				David Rufo		10/05/2021		Fix issue with tasks and events don't display historical comments
	1.3			FIX				David Rufo		28/06/2021		Fix queries to filter by RecordType of MC project (AV_%)
	1.4			Fix performance	Carolina Alonso	21/10/2021		Fix performance in the method getEventTasks and getOpps
	1.5		    AV_Query IT	    Daniel Rodríguez02/03/2022	    Change AV_Query to SOQL for User, Account, Contact
	1.6         US673516        Elisabeth R.    02/10/2023      Changed getOppsHistory method, added getCases method and changed map to return
	1.7         US796361        Oscar Moreno    20/03/2024      Create getColorLabelstNmOpp fro assign a color to the differents values of StageName of Opportunity.Modiify getEventTasks, getOppsHistory and getClases methods. 
	                                                            Create CommentHistoryItem class.Create this attrributes for CommentItem class: colorStageNameLabelOppsNested,comentarios and nestedOpportunities
	1.8			PPM100205278    Luis Fernández	15/05/2024		Added new status to getColorLabel 
    1.9         US912532        Oscar Moreno    23/05/2024      Added this condition ( RecordType.DeveloperName !='AV_Otros' AND AV_OrigenApp__c != 'AV_SFReportNoLocalizado') in the getEventTask  method for Task
	2.0			Fix Timeline    Luis Fernández	03/06/2024		Modified conditional on getEventTasks in order that every Event comes out with the comments history that points them in AV_Event__c field
	2.1         FIX30091022     Oscar Moreno    14/10/2024      Modified getCases method to no show Case-null if the case doesn't have a product
    2.2         PPM100353686   Oscar Moreno     22/10/2024      Add getProceso getAccion methods
***********************************************************************************************************************/
public with sharing class AV_ClientCommentsController {

	/**
	 * @description		Get client comments from event, task and opportunity records 
	 * @param accID   	String format accountId
	 * @return Map<String,List<CommentItem>> returns a map of String (month and year) and list of CommentItem class with the client comments info 
	 */
	@AuraEnabled
	public static Map<String,List<CommentItem>> getClientComments(String accId, String filter) {
		
		List<CommentItem> lstCommItems = new List<CommentItem>();
        getEventTasks(accId, lstCommItems, filter);
        AV_LogDebug.printLogDebug('getClientComments', 'List of events + tasks: ' + lstCommItems.size());

        getOppsHistory(accId, lstCommItems, filter);
		
		getCases(accId, lstCommItems, filter);
        AV_LogDebug.printLogDebug('getClientComments', 'List of events + tasks + opps + cases: ' + lstCommItems.size());


		getProceso(accId,lstCommItems,filter);
		getAccion(accId,lstCommItems,filter);
        
        //Order data + return list of data
		lstCommItems.sort();

		Map<String,List<CommentItem>> dateCommentListMap = groupByDate(lstCommItems);

		return dateCommentListMap;
	}


	 /**
     * Returns a map that relates the apiName and the label of the values from the picklist field Status from Activity.
     * @param String typeApiName
     * @return String
     */
    private static Map<String,String> getTaskStatusLabel(){
        List<Schema.PicklistEntry> statusPicklist = Task.Status.getDescribe().getPicklistValues();
		Map<String,String> result = new Map<String,String>();
		for(Schema.PicklistEntry status : statusPicklist){
			result.put(status.getValue(), status.getLabel());
		}
        return result;
    }

	private static Map<String,String> getProcesoSituacionLabel(){
        List<Schema.PicklistEntry> situacionPicklist = SIREC__SIREC_obj_proceso__c.SIR_fld_Situacion_SF__c.getDescribe().getPicklistValues();
		Map<String,String> result = new Map<String,String>();
		for(Schema.PicklistEntry sit : situacionPicklist){
			result.put(sit.getValue(), sit.getLabel());
		}
        return result;
    }

	private static Map<String,String> getProcesoMotivosBajaLabel(){
        List<Schema.PicklistEntry> motivosBajaPicklist = SIREC__SIREC_obj_proceso__c.SIREC__SIREC_fld_motivosBaja__c.getDescribe().getPicklistValues();
		Map<String,String> result = new Map<String,String>();
		for(Schema.PicklistEntry mot : motivosBajaPicklist){
			result.put(mot.getValue(), mot.getLabel());
		}
        return result;
    }

	private static Map<String,String> getAccionNameLabel(){
		List<Schema.PicklistEntry> accionNameLabels= SIREC__SIREC_obj_acciones__c.SIREC__SIREC_fld_accion__c.getDescribe().getPicklistValues();
		Map<String,String> result = new Map<String,String>();
		for(Schema.PicklistEntry a : accionNameLabels){
			result.put(a.getValue(), a.getLabel());
		}
        return result;

	}

	private static Map<String,String> getAccionTypeLabel(){
		List<Schema.PicklistEntry> accionTypeLabels= SIREC__SIREC_obj_acciones__c.SIREC__SIREC_fld_tipo__c.getDescribe().getPicklistValues();
		Map<String,String> result = new Map<String,String>();
		for(Schema.PicklistEntry a : accionTypeLabels){
			result.put(a.getValue(), a.getLabel());
		}
        return result;

	}

	private static Map<String,String> getAccionResultadoLabel(){
		List<Schema.PicklistEntry> accionRsLabels= SIREC__SIREC_obj_acciones__c.SIREC__SIREC_fld_resultado__c.getDescribe().getPicklistValues();
		Map<String,String> result = new Map<String,String>();
		for(Schema.PicklistEntry a : accionRsLabels){
			result.put(a.getValue(), a.getLabel());
		}
        return result;

	}


	 /**
     * Returns a map that relates the apiName and the label of the values from the picklist field AV_Tipo__c from event.
     * @param String typeApiName
     * @return String
     */
    private static Map<String,String> getContactTypeLabel(){
        List<Schema.PicklistEntry> typePicklist = Task.AV_Tipo__c.getDescribe().getPicklistValues();
		Map<String,String> result = new Map<String,String>();
		for(Schema.PicklistEntry type : typePicklist){
			result.put(type.getValue(), type.getLabel());
		}
        return result;
    }

	 /**
     * Returns a map that relates the apiName and the label of the values from the picklist field Status from Case.
     * @param String typeApiName
     * @return String
     */
    private static Map<String,String> getCaseStatusLabel(){
        List<Schema.PicklistEntry> typePicklist = Case.Status.getDescribe().getPicklistValues();
		Map<String,String> result = new Map<String,String>();
		for(Schema.PicklistEntry type : typePicklist){
			result.put(type.getValue(), type.getLabel());
		}
        return result;
    }

	/**
     * Returns a map that relates the apiName and the label of the values from the picklist field Stage from Opportunity.
     * @param String typeApiName
     * @return String
     */
    private static Map<String,String> getOppStageLabel(){
        List<Schema.PicklistEntry> typePicklist = Opportunity.StageName.getDescribe().getPicklistValues();
		Map<String,String> result = new Map<String,String>();
		for(Schema.PicklistEntry type : typePicklist){
			result.put(type.getValue(), type.getLabel());
		}
        return result;
    }

	  /**
     * Returns a map that relates the apiName and the label of the values from the picklist field Status from Event.
     * @param String typeApiName
     * @return String
     */
    private static Map<String,String> getStatusOfEventsLabel(){
        List<Schema.PicklistEntry> typePicklist = Event.CSBD_Evento_Estado__c.getDescribe().getPicklistValues();
                Map<String,String> result = new Map<String,String>();
                for(Schema.PicklistEntry type : typePicklist){
                        result.put(type.getValue(), type.getLabel());
                }
        return result;
    
    }
    
    /**
     * Returns the value of teh color of teh StageName Label of the Opportunity.
     * @param String stageName
     * @return String
     */
    private static String getColorLabelstNmOpp(String stageName){
                if(stageName == AV_AppConstants.OPP_STATUS_ENGESTION){
                        return '#CDE4EC';
                }else if(stageName == AV_AppConstants.OPP_STATUS_CERRPOST || stageName == AV_AppConstants.OPP_STATUS_PROD_CONTR){
                        return '#C9E1D2';
                }else if(stageName == AV_AppConstants.OPP_STATUS_CERRNEG || stageName == AV_AppConstants.OPP_STATUS_PROD_RECH){
                        return '#CE8E8E8';
                }else if(stageName == AV_AppConstants.OPP_STATUS_VENCIDO || stageName == AV_AppConstants.OPP_STATUS_NO_GESTIONADA){
                        return '#F2C7CC';
                }else if(stageName == AV_AppConstants.OPP_STATUS_CONVENTA){
                        return '#C9E1D2';
                }else if(stageName == AV_AppConstants.OPP_STATUS_POTENCIAL){
                        return '#F8DDB7';
                }else if(stageName == AV_AppConstants.OPP_STATUS_FORMALIZADA){
                        return '#C9E1D2';
                }else if(stageName == AV_AppConstants.OPP_STATUS_VENCIDO){
                        return '#F2C7CC';
                }else if(stageName == AV_AppConstants.OPP_STATUS_PERDIDA){
                        return '#F2C7CC';
                }
                else{
                        return '';
                }
                
    }
    
    
    private static void getEventTasks(String accId, List<CommentItem> lstCommItems, String filter){
		Set<String> setTaskRT = new Set<String>{'AV_AlertaComercial','AV_Priorizador', 'AV_ConversacionPendiente', 'AV_MorosidadNormativa',
											'AV_Priorizador','AV_ExperienciaCliente', 'AV_Onboarding'};
		
		Set<String> setTaskStatus = new Set<String>{'Gestionada positiva', 'Gestionada negativa', 'Gestionado no localizado'};


		List<Event> lstClientEvents;
		List<Task> lstClientTasks;
		List<Event> lstClientEvents2;
		List<Task> lstClientTasks2;


		List<AV_CommentsHistory__c> lstCm; 
		set<Id> idsEvt; 
		
		
		if(filter == null ){
			lstClientEvents = [Select Id, Description, Subject, AV_Tipo__c, OwnerId, Owner.Name,AV_Task__c,CSBD_Evento_Estado__c,ActivityDateTime, ActivityDate From Event Where AccountId =: accId and RecordType.DeveloperName ='AV_EventosConCliente' and IsChild = false and (CSBD_Evento_Estado__c ='Gestionada Positiva' OR (CSBD_Evento_Estado__c ='Pendiente' and ActivityDate >=LAST_N_DAYS:30) OR CSBD_Evento_Estado__c ='Cancelado' )];

			lstClientTasks = [Select Id, Description, Subject, AV_Tipo__c, Status, OwnerId, Owner.Name, ActivityDate,AV_Task__c,CSBD_Evento_Estado__c From Task Where AccountId =: accId AND Status in : setTaskStatus and AV_ToDelete__c = FALSE AND ( (RecordType.DeveloperName in :setTaskRT) OR ( RecordType.DeveloperName = 'AV_Otros' AND AV_OrigenApp__c != 'AV_SFReportNoLocalizado'))];

		}else{

			String filterLike = '%'+filter+'%';
			lstClientEvents = [Select Id, Description, Subject, AV_Tipo__c, OwnerId, Owner.Name, ActivityDate,AV_Task__c,CSBD_Evento_Estado__c,ActivityDateTime From Event Where AccountId =: accId and RecordType.DeveloperName ='AV_EventosConCliente' and IsChild = false and (CSBD_Evento_Estado__c ='Gestionada Positiva' OR (CSBD_Evento_Estado__c ='Pendiente' and ActivityDate >=LAST_N_DAYS:30) OR CSBD_Evento_Estado__c ='Cancelado' ) AND Subject LIKE : filterLike];
			lstClientTasks = [Select Id, Description, Subject, AV_Tipo__c, Status, OwnerId, Owner.Name, ActivityDate,AV_Task__c,CSBD_Evento_Estado__c From Task Where AccountId =: accId  AND Status in : setTaskStatus and AV_ToDelete__c = FALSE 
			AND Subject LIKE :filterLike AND ( (RecordType.DeveloperName in :setTaskRT) OR (RecordType.DeveloperName ='AV_Otros' AND AV_OrigenApp__c != 'AV_SFReportNoLocalizado')) ];

			List<AV_CommentsHistory__c> listCao = new List<AV_CommentsHistory__c>();
			Set<Id> hdId=new Set<Id>();
			
			listCao = [SELECT Id,AV_Opportunity__r.AV_Product__c,AV_Opportunity__r.AccountId,AV_Task__c FROM AV_CommentsHistory__c WHERE AV_Opportunity__r.AccountId =: accId AND AV_Opportunity__r.AV_Product__c LIKE: filterLike];
			if(!listCao.isEmpty()){
				for(AV_CommentsHistory__c c: listCao){
					hdId.add(c.AV_Task__c);
				}
			}
			if(!hdId.isEmpty()){
				lstClientEvents2 = [SELECT Id, Description, Subject, AV_Tipo__c, OwnerId, Owner.Name, ActivityDate,AV_Task__c,CSBD_Evento_Estado__c,ActivityDateTime FROM Event WHERE AccountId=: accId AND  Id IN: hdId and RecordType.DeveloperName ='AV_EventosConCliente' and IsChild = false and (CSBD_Evento_Estado__c ='Gestionada Positiva' OR (CSBD_Evento_Estado__c ='Pendiente' and ActivityDate >=LAST_N_DAYS:30) OR CSBD_Evento_Estado__c ='Cancelado' )] ;
				if(lstClientEvents2 != null && !lstClientEvents2.isEmpty()){
					lstClientEvents.addAll(lstClientEvents2);
				}
				lstClientTasks2 = [SELECT Id, Description, Subject, AV_Tipo__c, Status, OwnerId, Owner.Name, ActivityDate,AV_Task__c,CSBD_Evento_Estado__c,AV_OrigenApp__c,RecordType.DeveloperName From Task Where AccountId =: accId AND Id IN: hdId   AND Status in : setTaskStatus and AV_ToDelete__c = FALSE AND ((RecordType.DeveloperName in :setTaskRT) OR (RecordType.DeveloperName ='AV_Otros' AND AV_OrigenApp__c != 'AV_SFReportNoLocalizado'))];
				if(lstClientTasks2 != null && !lstClientTasks2.isEmpty()){
					lstClientTasks.addAll(lstClientTasks2);
				}
			}
			
		}
		
		
		Set<Id> idsEvents = new Set<Id>();
		Set<Id> idsTasks = new Set<Id>();
		for(Event ev : lstClientEvents) {
			idsEvents.add(ev.id);  
			
		}
		for(Task tsk : lstClientTasks) {
			idsTasks.add(tsk.id);  
			
		}
        //List of events
        if(lstClientEvents != null && !lstClientEvents.isEmpty()) {
			Map<String,String> typeEventLabels = getContactTypeLabel();
			
			List <AV_CommentsHistory__c> listComentarios = [SELECT Id,name,AV_NewComment__c,AV_Event__c, AV_Task__c,AV_OpportunityStatus__c,AV_OldComment__c,AV_OldStatus__c, AV_NewStatus__c,CreatedDate, AV_Opportunity__r.CloseDate,AV_Opportunity__r.AV_CommentLastModifiedDate__c, AV_Opportunity__c, AV_Opportunity__r.Owner.Name, AV_Opportunity__r.AV_PF__r.Name, AV_Opportunity__r.Name, AV_Opportunity__r.StageName, AV_Opportunity__r.LastModifiedDate , AV_AssignedEmployee__c, AV_AssignedEmployee__r.Name, AV_ModificationDate__c FROM AV_CommentsHistory__c  WHERE AV_Event__c =: idsEvents AND AV_Opportunity__c != NULL ORDER BY CreatedDate] ;
			Map<Id, Map<Id, DateTime>> comentariosPorEventoYOpportunity2 = new Map<Id, Map<Id, DateTime>>();   
			List<Id> listOppCom = new List<Id>(); //id de Opps
			
			for (AV_CommentsHistory__c comentario : listComentarios) {
				if(comentariosPorEventoYOpportunity2.containsKey(comentario.AV_Event__c)){
					if((comentariosPorEventoYOpportunity2.get(comentario.AV_Event__c).containsKey(comentario.AV_Opportunity__c) && comentario.CreatedDate > comentariosPorEventoYOpportunity2.get(comentario.AV_Event__c).get(comentario.AV_Opportunity__c)) || !comentariosPorEventoYOpportunity2.get(comentario.AV_Event__c).containsKey(comentario.AV_Opportunity__c)){
						comentariosPorEventoYOpportunity2.get(comentario.AV_Event__c).put(comentario.AV_Opportunity__c,comentario.CreatedDate);
					}
				}else{
					comentariosPorEventoYOpportunity2.put(comentario.AV_Event__c,new Map<Id,DateTime>{comentario.AV_Opportunity__c => comentario.CreatedDate});
				}
				if(!listOppCom.contains(comentario.AV_Opportunity__c)) {
					listOppCom.add(comentario.AV_Opportunity__c);
				}
			}
			
			List<AV_CommentsHistory__c> listCommHist = [SELECT Id,name,AV_NewComment__c,AV_Event__c, AV_Task__c,AV_OpportunityStatus__c,AV_OldComment__c,AV_OldStatus__c, AV_NewStatus__c,CreatedDate, AV_Opportunity__r.CloseDate,AV_Opportunity__r.AV_CommentLastModifiedDate__c, AV_Opportunity__c, AV_Opportunity__r.Owner.Name, AV_Opportunity__r.AV_PF__r.Name, AV_Opportunity__r.Name, AV_Opportunity__r.StageName, AV_Opportunity__r.LastModifiedDate , AV_AssignedEmployee__c, AV_AssignedEmployee__r.Name, AV_ModificationDate__c 
			FROM AV_CommentsHistory__c WHERE AV_Opportunity__c IN: listOppCom ORDER BY CreatedDate DESC ];
			
			Map<Id, List<AV_CommentsHistory__c>> mapOppsListCmH= new Map<Id, List<AV_CommentsHistory__c>>();
			for (AV_CommentsHistory__c comentario : listCommHist) {
				if (!mapOppsListCmH.containsKey(comentario.AV_Opportunity__c)) {
					mapOppsListCmH.put(comentario.AV_Opportunity__c, new List<AV_CommentsHistory__c>{comentario});
				}else{
					mapOppsListCmH.get(comentario.AV_Opportunity__c).add(comentario);
				}	
			}
			
			Map<Id,Map<Id,List<AV_CommentsHistory__c>>> mapaFinal = new Map<Id,Map<Id,List<AV_CommentsHistory__c>>>();
			for (Id eventId : comentariosPorEventoYOpportunity2.keySet()) {
				if(comentariosPorEventoYOpportunity2.get(eventId)!= null){
					for (Id opportunityId : comentariosPorEventoYOpportunity2.get(eventId).keySet()) {
						for(AV_CommentsHistory__c c: mapOppsListCmH.get(opportunityId)){
							if(c.CreatedDate <= comentariosPorEventoYOpportunity2.get(eventId).get(opportunityId) && c.AV_Event__c != null && c.AV_Event__c.equals(eventId)){
								if(mapaFinal.containsKey(eventId)){
									if(mapaFinal.get(eventId).containsKey(opportunityId)){
										mapaFinal.get(eventId).get(opportunityId).add(c);
									}else{
										mapaFinal.get(eventId).put(opportunityId,new List<AV_CommentsHistory__c>{c});
									}
								}else{
									mapaFinal.put(eventId,new Map<Id,List<AV_CommentsHistory__c>>{opportunityId => new List<AV_CommentsHistory__c>{c}});
								}
							}
						}
					}
				}
			}
		
			Map<Id, Set<Id>> oportunidadesAgregadasPorEvento = new Map<Id, Set<Id>>();
			Map<String,String> stageOppLabels = getOppStageLabel();
			Map<String,String> statusEvLabels = getStatusOfEventsLabel();
			Map<Id,String> oppsForOrderComment = new Map<Id,String>();
			for(Event data : lstClientEvents) {
				CommentItem cmItEv = new CommentItem(data.ActivityDateTime, data.ActivityDateTime.format('dd-MM-yyyy'), 'event', data.Owner.Name, null, 'Cita - ' + data.Subject, data.Id, statusEvLabels.get(data.CSBD_Evento_Estado__c), typeEventLabels.get(data.AV_Tipo__c),null);
				cmItEv.comment = data.Description;
				if( mapaFinal!=null && mapaFinal.get(data.Id)!=null){
					for(Id oppId: mapaFinal.get(data.Id).keySet()){
						if(mapaFinal.get(data.Id).get(oppId)!=null){
							Integer contador = 0;
							CommentItem cmItmOpp;
							for (AV_CommentsHistory__c cm :mapaFinal.get(data.Id).get(oppId)){
								if(contador == 0){
									cmItmOpp = new CommentItem(cm.CreatedDate, cm.CreatedDate.format('dd-MM-yyyy'), 'opportunity', cm.AV_Opportunity__r.Owner.Name, 
									cm.AV_Opportunity__r.AV_PF__r.Name, 'Oportunidad - ' +  cm.AV_Opportunity__r.Name, cm.AV_Opportunity__c, stageOppLabels.get(cm.AV_Opportunity__r.StageName), null, null);
									cmItmOpp.colorStageNameLabelOppsNested = getColorLabelstNmOpp(cm.AV_Opportunity__r.StageName);
									contador++;
								}
						
								if(cm.AV_NewComment__c!=null){
									cmItmOpp.comentarios.add(new CommentHistoryItem(cm.CreatedDate.format('dd/MM/yyyy'),cm.AV_NewComment__c));
								}
							}							
							cmItEv.nestedOpportunities.add(cmItmOpp);	
						}
					}
				}
				lstCommItems.add(cmItEv);					
			}
		}
        
        //List of tasks
        if(lstClientTasks != null && !lstClientTasks.isEmpty()) {
			Map<String,String> statusTaskLabels = getTaskStatusLabel();
			Map<String,String> typeTaskLabels = getContactTypeLabel();
			Map<String,String> stageOppLabels = getOppStageLabel();
			
			List <AV_CommentsHistory__c> listComentarios = [SELECT Id,name,AV_NewComment__c,AV_Event__c, AV_Task__c,AV_OpportunityStatus__c,AV_OldComment__c,AV_OldStatus__c, AV_NewStatus__c,CreatedDate, AV_Opportunity__r.CloseDate,AV_Opportunity__r.AV_CommentLastModifiedDate__c, AV_Opportunity__c, AV_Opportunity__r.Owner.Name, AV_Opportunity__r.AV_PF__r.Name, AV_Opportunity__r.Name, AV_Opportunity__r.StageName, AV_Opportunity__r.LastModifiedDate , AV_AssignedEmployee__c, AV_AssignedEmployee__r.Name, AV_ModificationDate__c FROM AV_CommentsHistory__c  WHERE AV_Task__c =: idsTasks AND AV_Opportunity__c != NULL ORDER BY CreatedDate] ;
			Map<Id, Map<Id, DateTime>> comentariosPorEventoYOpportunity2 = new Map<Id, Map<Id, DateTime>>();   
			List<Id> listOppCom = new List<Id>(); //id de Opps
			
			for (AV_CommentsHistory__c comentario : listComentarios) {
				if(comentariosPorEventoYOpportunity2.containsKey(comentario.AV_Task__c)){
					if((comentariosPorEventoYOpportunity2.get(comentario.AV_Task__c).containsKey(comentario.AV_Opportunity__c) && comentario.CreatedDate > comentariosPorEventoYOpportunity2.get(comentario.AV_Task__c).get(comentario.AV_Opportunity__c)) || !comentariosPorEventoYOpportunity2.get(comentario.AV_Task__c).containsKey(comentario.AV_Opportunity__c)){
						comentariosPorEventoYOpportunity2.get(comentario.AV_Task__c).put(comentario.AV_Opportunity__c,comentario.CreatedDate);
					}
				}else{
					comentariosPorEventoYOpportunity2.put(comentario.AV_Task__c,new Map<Id,DateTime>{comentario.AV_Opportunity__c => comentario.CreatedDate});
				}
				if(!listOppCom.contains(comentario.AV_Opportunity__c)) {
					listOppCom.add(comentario.AV_Opportunity__c);
				}
			}
			
			List<AV_CommentsHistory__c> listCommHist = [SELECT Id,name,AV_NewComment__c,AV_Event__c, AV_Task__c,AV_OpportunityStatus__c,AV_OldComment__c,AV_OldStatus__c, AV_NewStatus__c,CreatedDate, AV_Opportunity__r.CloseDate,AV_Opportunity__r.AV_CommentLastModifiedDate__c, AV_Opportunity__c, AV_Opportunity__r.Owner.Name, AV_Opportunity__r.AV_PF__r.Name, AV_Opportunity__r.Name, AV_Opportunity__r.StageName, AV_Opportunity__r.LastModifiedDate , AV_AssignedEmployee__c, AV_AssignedEmployee__r.Name, AV_ModificationDate__c 
			FROM AV_CommentsHistory__c WHERE AV_Opportunity__c IN: listOppCom ORDER BY CreatedDate DESC ];
			
			Map<Id, List<AV_CommentsHistory__c>> mapOppsListCmH= new Map<Id, List<AV_CommentsHistory__c>>();
			for (AV_CommentsHistory__c comentario : listCommHist) {
				if (!mapOppsListCmH.containsKey(comentario.AV_Opportunity__c)) {
					mapOppsListCmH.put(comentario.AV_Opportunity__c, new List<AV_CommentsHistory__c>{comentario});
				}else{
					mapOppsListCmH.get(comentario.AV_Opportunity__c).add(comentario);
				}	
			}
			
			Map<Id,Map<Id,List<AV_CommentsHistory__c>>> mapaFinal = new Map<Id,Map<Id,List<AV_CommentsHistory__c>>>();
			for (Id taskId : comentariosPorEventoYOpportunity2.keySet()) {
				if(comentariosPorEventoYOpportunity2.get(taskId)!= null){
					for (Id opportunityId : comentariosPorEventoYOpportunity2.get(taskId).keySet()) {
						for(AV_CommentsHistory__c c: mapOppsListCmH.get(opportunityId)){
							if(c.CreatedDate <= comentariosPorEventoYOpportunity2.get(taskId).get(opportunityId) && c.AV_Task__c != null && c.AV_Task__c.equals(taskId)){
								if(mapaFinal.containsKey(taskId)){
									if(mapaFinal.get(taskId).containsKey(opportunityId)){
										mapaFinal.get(taskId).get(opportunityId).add(c);
									}else{
										mapaFinal.get(taskId).put(opportunityId,new List<AV_CommentsHistory__c>{c});
									}
								}else{
									mapaFinal.put(taskId,new Map<Id,List<AV_CommentsHistory__c>>{opportunityId => new List<AV_CommentsHistory__c>{c}});
								}
							}
						}
					}
				}
			}
		
			Map<Id, Set<Id>> oportunidadesAgregadasPorEvento = new Map<Id, Set<Id>>();
			Map<Id,String> oppsForOrderComment = new Map<Id,String>();
			for(Task data : lstClientTasks) {
				CommentItem cmItTask = new CommentItem(datetime.newInstance(data.ActivityDate.year(), data.ActivityDate.month(),data.ActivityDate.day()), datetime.newInstance(data.ActivityDate.year(), data.ActivityDate.month(),data.ActivityDate.day()).format('dd-MM-yyyy'), 'task', data.Owner.Name, null, 
                                                          'Tarea - ' + data.Subject, data.Id, statusTaskLabels.get(data.Status), typeTaskLabels.get(data.AV_Tipo__c), null);
				cmItTask.comment = data.Description;
				if( mapaFinal!=null && mapaFinal.get(data.Id)!=null){
					for(Id oppId: mapaFinal.get(data.Id).keySet()){
						if(mapaFinal.get(data.Id).get(oppId)!=null){
							Integer contador = 0;
							CommentItem cmItmOpp;
							for (AV_CommentsHistory__c cm :mapaFinal.get(data.Id).get(oppId)){
								if(contador == 0){
									cmItmOpp = new CommentItem(cm.CreatedDate, cm.CreatedDate.format('dd-MM-yyyy'), 'opportunity', cm.AV_Opportunity__r.Owner.Name, 
									cm.AV_Opportunity__r.AV_PF__r.Name, 'Oportunidad - ' +  cm.AV_Opportunity__r.Name, cm.AV_Opportunity__c, stageOppLabels.get(cm.AV_Opportunity__r.StageName), null, null);
									cmItmOpp.colorStageNameLabelOppsNested = getColorLabelstNmOpp(cm.AV_Opportunity__r.StageName);
									contador++;
								}
								//No mostrar comentarios cuyo valor del campo AV_NewComment__c es null
								if(cm.AV_NewComment__c!=null){
									cmItmOpp.comentarios.add(new CommentHistoryItem(cm.CreatedDate.format('dd/MM/yyyy'),cm.AV_NewComment__c));
								}
							}							
							cmItTask.nestedOpportunities.add(cmItmOpp);	
						}
					}
				}
				lstCommItems.add(cmItTask);					
			}
		}
    }

	
	private static void getOppsHistory(String accId, List<CommentItem> lstCommItems, String filter){

		Set<String> setRTOpp = new Set<String>{'AV_AlertaComercial', 'AV_Iniciativa', 'AV_Propuesta', 'AV_Sugerencia','CSBD_Accion_Comercial','CSBD_Chat','CSBD_CMB','CSBD_CMN','CSBD_Compra_Estrella','CSBD_Desistimiento','CSBD_DesistimientoPAI','CSBD_Hipoteca','CSBD_Prestamo','CSBD_Renting','CSBD_TPV','AV_CallMe'};
		Set<String> setStatusOpp = new Set<String>{'Cerrado positivo','No interesado','Producto Contratado','Producto Rechazado','No Gestionada','Con venta','Potencial','En gestión/insistir','Cerrado positivo','Cerrada negativa','Formalizada','Perdida','Vencido'};

		List<AV_CommentsHistory__c> lstClientOppsHistory;

		if(filter == null ){
			lstClientOppsHistory = [Select Id, AV_NewComment__c,CreatedDate, AV_Opportunity__r.CloseDate,AV_Opportunity__r.AV_CommentLastModifiedDate__c, AV_Opportunity__c, AV_Opportunity__r.Owner.Name, AV_Opportunity__r.AV_PF__r.Name, AV_Opportunity__r.Name, AV_Opportunity__r.StageName, AV_Opportunity__r.LastModifiedDate , AV_AssignedEmployee__c, AV_AssignedEmployee__r.Name, AV_ModificationDate__c From AV_CommentsHistory__c Where AV_Opportunity__r.AccountId = :accId AND  AV_Opportunity__r.RecordType.DeveloperName in : setRTOpp AND AV_Opportunity__r.StageName in : setStatusOpp AND AV_Event__c = null AND AV_Task__c = null];
		}else{

			String filterLike = '%'+filter+'%';
			lstClientOppsHistory = [Select Id, AV_NewComment__c,CreatedDate, AV_Opportunity__r.CloseDate, AV_Opportunity__r.AV_CommentLastModifiedDate__c, AV_Opportunity__c, AV_Opportunity__r.Owner.Name, AV_Opportunity__r.AV_PF__r.Name, AV_Opportunity__r.Name, AV_Opportunity__r.StageName, AV_Opportunity__r.LastModifiedDate, AV_AssignedEmployee__c, AV_AssignedEmployee__r.Name, AV_ModificationDate__c From AV_CommentsHistory__c Where AV_Opportunity__r.AccountId = :accId AND  AV_Opportunity__r.RecordType.DeveloperName in : setRTOpp AND AV_Opportunity__r.StageName in : setStatusOpp AND (AV_Opportunity__r.Name LIKE :filterLike OR AV_Opportunity__r.AV_Product__c LIKE :filterLike) AND AV_Event__c = null AND AV_Task__c = null];

		}

        
        //List of opportunities history
		if(lstClientOppsHistory != null && !lstClientOppsHistory.isEmpty()) {
			Map<String,String> stageOppLabels = getOppStageLabel();
			for(AV_CommentsHistory__c oppH : lstClientOppsHistory) {
				if (String.isNotBlank(oppH.AV_NewComment__c)) {
					CommentItem citOpp = new CommentItem(oppH.CreatedDate, oppH.CreatedDate.format('dd-MM-yyyy'), 'opportunity', oppH.AV_Opportunity__r.Owner.Name,  oppH.AV_Opportunity__r.AV_PF__r.Name, 'Oportunidad - ' +  oppH.AV_Opportunity__r.Name, oppH.AV_Opportunity__c, stageOppLabels.get(oppH.AV_Opportunity__r.StageName), null, null);
					citOpp.colorStageNameLabelOppsNested = getColorLabelstNmOpp(oppH.AV_Opportunity__r.StageName);
					citOpp.comment = oppH.AV_NewComment__c;
					if(oppH.AV_NewComment__c!=null){
						citOpp.comentarios.add(new CommentHistoryItem(oppH.CreatedDate.format('dd/MM/yyyy'),oppH.AV_NewComment__c));
					}
					lstCommItems.add(citOpp);
				}
			}
		}
	}

	private static void getCases(String accId, List<CommentItem> lstCommItems, String filter){

		List<Case> lstClientCases;
		if(filter == null){

			lstClientCases = [Select Id, ProductId, Product.Name, CC_Tipo_Contacto__c, Status, Origin, CC_Fecha_Prevista__c, CreatedDate  From Case Where AccountId = :accId ];

		}else{

			String filterLike = '%'+filter+'%';
			lstClientCases = [Select Id, ProductId, Product.Name, CC_Tipo_Contacto__c, Status, Origin, CC_Fecha_Prevista__c, CreatedDate  From Case Where AccountId = :accId AND Product.Name LIKE : filterLike];

		}
        //List of cases
		if(lstClientCases != null && !lstClientCases.isEmpty()) {
			Map<String,String> statusCaseLabels = getCaseStatusLabel();
			for(Case c : lstClientCases) {
				
				CommentItem ciCase;
				if(c.Product.Name != null){
					ciCase = new CommentItem(c.CreatedDate, c.CreatedDate.format('dd-MM-yyyy'), 'case', null, c.ProductId, 'Caso - '  + c.Product.Name, c.Id, statusCaseLabels.get(c.Status), null, c.Origin);
				}else{
				    ciCase = new CommentItem(c.CreatedDate, c.CreatedDate.format('dd-MM-yyyy'), 'case', null, c.ProductId, 'Caso ', c.Id, statusCaseLabels.get(c.Status), null, c.Origin);
				}
				
				lstCommItems.add(ciCase);					 
				ciCase.comment = c.CC_Tipo_Contacto__c;
			}
		}
    }

	
	private static void getProceso(String accId, List<CommentItem> lstCommItems, String filter){
		Map<String,String> situacionProcesoLabels = getProcesoSituacionLabel();
		Map<String,String> motivosBajaProcesoLabels = getProcesoMotivosBajaLabel();
		List<SIREC__SIREC_obj_proceso__c> lstClientProcesos;
		if(filter == null || filter =='Proceso'){
			lstClientProcesos = [SELECT Id,Name,SIREC__SIREC_fld_fechaSituacion__c,SIREC__SIREC_fld_motivosBaja__c,SIREC__SIREC_fld_fechaBaja__c,SIREC__SIREC_fld_cliente__c,SIREC__SIREC_fld_fechaInicio__c,RecordType.Name,Owner.name,SIR_DeudaTotal__c,SIR_fld_Situacion_SF__c FROM SIREC__SIREC_obj_proceso__c WHERE SIREC__SIREC_fld_cliente__c  = :accId ];
		}else{
			String filterLike = '%'+filter+'%';
			lstClientProcesos = [SELECT Id,Name,SIREC__SIREC_fld_fechaSituacion__c,SIREC__SIREC_fld_motivosBaja__c,SIREC__SIREC_fld_fechaBaja__c,SIREC__SIREC_fld_cliente__c,SIREC__SIREC_fld_fechaInicio__c,RecordType.Name,Owner.name,SIR_DeudaTotal__c,SIR_fld_Situacion_SF__c FROM SIREC__SIREC_obj_proceso__c WHERE SIREC__SIREC_fld_cliente__c  = :accId  AND Name LIKE : filterLike];
		}

		if(lstClientProcesos != null && !lstClientProcesos.isEmpty()) {
			for(SIREC__SIREC_obj_proceso__c c : lstClientProcesos) {
				CommentItem ciProceso = new CommentItem('Proceso MCS-'+c.Name,c.SIREC__SIREC_fld_fechaInicio__c,'proceso',c.RecordType.Name,c.Owner.name,c.id);
	
				if(c.SIR_fld_Situacion_SF__c != null){
					String sit = situacionProcesoLabels.get(c.SIR_fld_Situacion_SF__c);
					ciProceso.status= sit;
				}
				
				if (c.SIR_DeudaTotal__c != null) {
					ciProceso.comment = 'Deuda Total: ' + c.SIR_DeudaTotal__c + ' ';
				}else{
					ciProceso.comment ='';
				}

				if (c.SIREC__SIREC_fld_fechaSituacion__c != null) {
					String fechaFormateada = formatDate(c.SIREC__SIREC_fld_fechaSituacion__c);
					if(ciProceso.comment == ''){
						ciProceso.comment += 'Fecha Situación: ' + fechaFormateada + ' ';
					}else{
						ciProceso.comment += '- Fecha Situación: ' + fechaFormateada + ' ';
					}
				}else{
					ciProceso.comment += '';
				}

				if (c.SIREC__SIREC_fld_motivosBaja__c != null ) {
					if(ciProceso.comment == ''){
						ciProceso.comment += 'Motivo Baja: ' + motivosBajaProcesoLabels.get(c.SIREC__SIREC_fld_motivosBaja__c) + ' ';
					}else{
						ciProceso.comment += '- Motivo Baja: ' + motivosBajaProcesoLabels.get(c.SIREC__SIREC_fld_motivosBaja__c) + ' ';
					}
				}else{
					ciProceso.comment +='';
				}
				if (c.SIREC__SIREC_fld_fechaBaja__c != null) {
					String fechaFormateada = formatDate(c.SIREC__SIREC_fld_fechaBaja__c);
					if(ciProceso.comment == ''){
						ciProceso.comment += 'Fecha de Baja: ' + fechaFormateada;
					}else{
						ciProceso.comment += '- Fecha de Baja: ' + fechaFormateada;
					}
				}else{
					ciProceso.comment +='';
				}
				lstCommItems.add(ciProceso);
			}
		}
	}
	
	private static String formatDate(Date fech) {
        if (fech == null) {
            return ''; 
        }else{
			String day = String.valueOf(fech.day());
			String month = String.valueOf(fech.month());
			String year = String.valueOf(fech.year());
			return day + '-' + month + '-' + year;
		}
    }

	private static void getAccion(String accId, List<CommentItem> lstCommItems, String filter){
		Map<String,String> namesAccionLabels = getAccionNameLabel();
		Map<String,String> namesTypeLabels = getAccionTypeLabel();
		Map<String,String> namesResultadoLabels = getAccionResultadoLabel();

		List<String> apiNameFilter = new List<String>();
		List<SIREC__SIREC_obj_acciones__c> lstClientAcciones;
		List<SIREC__SIREC_obj_proceso__c> lstClientProcesos  = [SELECT Id,SIREC__SIREC_fld_cliente__c FROM SIREC__SIREC_obj_proceso__c WHERE SIREC__SIREC_fld_cliente__c  = :accId ];

		if(lstClientProcesos!=null && !lstClientProcesos.isEmpty()){

			if(filter == null || filter=='Acción' || filter ==''){
				lstClientAcciones = [SELECT Id,Name,SIREC__SIREC_fld_proceso__r.name,SIREC__SIREC_fld_accion__c,SIREC__SIREC_fld_comentarios__c,SIREC__SIREC_fld_fechaContacto__c,SIREC__SIREC_fld_tipo__c,SIREC__SIREC_fld_resultado__c,SIREC__SIREC_fld_responsable__r.name,SIR_FechaCompromisoPago__c
				FROM SIREC__SIREC_obj_acciones__c 
				WHERE SIREC__SIREC_fld_proceso__c =: lstClientProcesos];
			}else{
				List<String> listValuesNamesAccionLabels= new List<String>();
				List<String> valoresPosibles = new List<String>();
				
				for (String key : namesAccionLabels.keySet()) {
					String value = namesAccionLabels.get(key);
					if (value != null && value.toLowerCase().contains(filter.toLowerCase())) {
						apiNameFilter.add(key);  
					}
				}

				if(apiNameFilter!= null){
					lstClientAcciones = [SELECT Id,Name,SIREC__SIREC_fld_proceso__r.name,SIREC__SIREC_fld_accion__c,SIREC__SIREC_fld_comentarios__c,SIREC__SIREC_fld_fechaContacto__c,SIREC__SIREC_fld_tipo__c,SIREC__SIREC_fld_resultado__c,SIREC__SIREC_fld_responsable__r.name,SIR_FechaCompromisoPago__c
					FROM SIREC__SIREC_obj_acciones__c 
					WHERE SIREC__SIREC_fld_proceso__c =: lstClientProcesos AND  SIREC__SIREC_fld_accion__c =: apiNameFilter ];
				}
			}
	
			if(lstClientAcciones != null && !lstClientAcciones.isEmpty()) {
				for(SIREC__SIREC_obj_acciones__c c : lstClientAcciones) {
					CommentItem ciAccion = new CommentItem(c.SIREC__SIREC_fld_fechaContacto__c	,'accion',c.id);
					
					if(c.SIREC__SIREC_fld_responsable__r.name !=null){
						ciAccion.employee= c.SIREC__SIREC_fld_responsable__r.name;
					}else{
						ciAccion.employee = '';
					}
	
	
					if(c.SIREC__SIREC_fld_accion__c !=null){
						ciAccion.subject= 'Acción MCS-'+namesAccionLabels.get(c.SIREC__SIREC_fld_accion__c);
					}else{
						ciAccion.subject = 'Acción MCS ';
					}
					
					if(c.SIREC__SIREC_fld_tipo__c !=null){
						ciAccion.contactType= namesTypeLabels.get(c.SIREC__SIREC_fld_tipo__c);
					}else{
						ciAccion.contactType = '';
					}
	
					if(c.SIREC__SIREC_fld_resultado__c !=null){
						ciAccion.status= namesResultadoLabels.get(c.SIREC__SIREC_fld_resultado__c);
					}else{
						ciAccion.status = '';
					}
					
				
					if(c.SIR_FechaCompromisoPago__c!= null){
						String fechaFormateada = formatDate(c.SIR_FechaCompromisoPago__c);
						ciAccion.comment = 'Fecha Compromiso de Pago: ' + fechaFormateada ;
						if (c.SIREC__SIREC_fld_comentarios__c != null) {
							ciAccion.comment += ' - ' + c.SIREC__SIREC_fld_comentarios__c ;
						}else{
							ciAccion.comment +='';
						}
					}else{
						if (c.SIREC__SIREC_fld_comentarios__c != null) {
							ciAccion.comment =  c.SIREC__SIREC_fld_comentarios__c ;
						}else{
							ciAccion.comment ='';
						}
					}	
					lstCommItems.add(ciAccion);
				}
			}
		}
		
	}
	

	private static Map<String, List<CommentItem>> groupByDate(List<CommentItem> lstCommItems){

    Map<String, List<CommentItem>> dateCommentListMap = new Map<String, List<CommentItem>>();
    Map<String, String> monthMap = new Map<String, String>{
        'January' => 'Enero', 'February' => 'Febrero', 'March' => 'Marzo',
        'April' => 'Abril', 'May' => 'Mayo', 'June' => 'Junio',
        'July' => 'Julio', 'August' => 'Agosto', 'September' => 'Septiembre',
        'October' => 'Octubre', 'November' => 'Noviembre', 'December' => 'Diciembre'
    };

    for(CommentItem c : lstCommItems){
        if(c.dateTimeField != null){
            Date dateFieldAux = c.dateTimeField.date();
            String monthYearString =  monthMap.get(c.dateTimeField.format('MMMM')) + ' ' + String.valueOf(dateFieldAux.year());
            List<CommentItem> commentList = dateCommentListMap.get(monthYearString);
            if(commentList == null){
				commentList = new List<CommentItem>();
            }
            commentList.add(c);
            dateCommentListMap.put(monthYearString, commentList);
			
        }		
    }

    return dateCommentListMap;
}

	


	public class CommentItem implements Comparable {
		@AuraEnabled
		public Long id;
		@AuraEnabled
		public String type;
		@AuraEnabled
		public String employee;
		@AuraEnabled
		public String product;
		@AuraEnabled
		public String comment;
		@AuraEnabled
		public String subject;
		@AuraEnabled
		public DateTime dateTimeField;
		@AuraEnabled
		public String dateField;
		@AuraEnabled
		public String recordId;
		@AuraEnabled
		public String status;
		@AuraEnabled
		public String contactType;
		@AuraEnabled
		public String caseChannel;
		@AuraEnabled
        public List<CommentItem> nestedOpportunities;
         @AuraEnabled
        public String colorStageNameLabelOppsNested;
		@AuraEnabled
        public List<CommentHistoryItem> comentarios;
		

		// Constructor
		public CommentItem(DateTime dt, String  d, String ty, String emp, String prod, String sub, String rId, String statusC, String cType, String caseChannelC) {
			type = ty;
			employee = emp;
			product = prod;
			subject = sub;
			dateTimeField = dt;
			dateField = d;
			recordId = rId;
			status = statusC;
			contactType = cType;
			caseChannel = caseChannelC;
			comentarios = new List<CommentHistoryItem>();
			nestedOpportunities = new List<CommentItem>();  
            colorStageNameLabelOppsNested = null; 
		}

		
		public CommentItem(String name,Date fechIn,String ty,String rt ,String ow,String rId){
			subject = name;
			dateTimeField = Datetime.newInstance(fechIn, Time.newInstance(0, 0, 0, 0));
			dateField = String.valueOf(fechIn.day()) + '-' + String.valueOf(fechIn.month()) + '-' + String.valueOf(fechIn.year());
			type = ty;
			contactType = rt;
			employee = ow;
			recordId = rId;
			
		}

		public CommentItem(Date fechIn,String ty,String rId){
			dateTimeField = Datetime.newInstance(fechIn, Time.newInstance(0, 0, 0, 0));
			dateField = String.valueOf(fechIn.day()) + '-' + String.valueOf(fechIn.month()) + '-' + String.valueOf(fechIn.year());
			type = ty;
			recordId = rId;
		}
		

		public Integer compareTo(Object compareTo) {
			CommentItem compareToItem = (CommentItem)compareTo;
			if (dateTimeField == compareToItem.dateTimeField) {
				return 0;
			} else if (dateTimeField > compareToItem.dateTimeField) {
					return -1; // fecha actual es más reciente
			} else {
					return 1; // fecha actual es más antigua
			}			        
		}
	}

	
	public class CommentHistoryItem{
		@AuraEnabled
        public String fechaComentario;
		@AuraEnabled
        public String comentario;

		public CommentHistoryItem(String fchCom,String cm){
			fechaComentario = fchCom;
			comentario = cm;
		}
	}


}