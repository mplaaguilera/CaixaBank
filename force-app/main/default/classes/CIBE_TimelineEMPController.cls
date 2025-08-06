/**********************************************************************************************************************
Name:	  CIBE_TimelineEMPController
Copyright © 2023  CaixaBank
----------------------------------------------------------------------------------------------------------------------
Proposito: Clase controladora de los componentes "CIBE_TimelineEMP"
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
    VERSION		USER_STORY		AUTHOR			DATE			Description
    1.0			US732988		Ali				04/12/2023		Init version
    1.1			IN1217329		Lucía			25/10/2024		Modify getTask()

***********************************************************************************************************************/
public with sharing class CIBE_TimelineEMPController {
	
	private static Set<Id> setOppIdEvnt = new Set<Id>();
	private static Set<Id> setOppIdTsk = new Set<Id>();

 	/**
	 * @description		 	Get the ID's of the RT's requested by param
	 * @param setRT			List of the RT
	 */
    public static Set<Id> getIdsRT(Set<CIBE_AppUtilities.SearchRT> setRT){
		

        return CIBE_AppUtilities.getRecordTypeIdsInSet(setRT);
    }

	/**
		* @description								Get client comments FROM event, task AND opportunity records 
		* @param accID   							String format accountId
		* @return Map<String,List<CommentItem>> 	returns a map of String (month AND year) AND list of CommentItem class with the client comments info 
		*/
		@AuraEnabled
		public static Map<String,List<CommentItem>> getClientComments(String accId, String filter, Boolean cita, Boolean oportunidad, Boolean tarea, Boolean caso, Boolean inicial) {
			
			if(inicial){
				List<CommentItem> lstCommItems = new List<CommentItem>();

				getEvent(accId, lstCommItems, filter, false);

				getTask(accId, lstCommItems, filter, false);
			
				getOppsHistory(accId, lstCommItems, filter, false);
			
				getCases(accId, lstCommItems, filter);
			
				lstCommItems.sort();
				Map<String,List<CommentItem>> dateCommentListMap = groupByDate(lstCommItems);
				return dateCommentListMap;

			} else{
				List<CommentItem> lstCommItems = new List<CommentItem>();
				Boolean oppAux = oportunidad == true ? false : true;

				if(cita == true ){
					getEvent(accId, lstCommItems, filter, oppAux);
				}
				if(tarea == true ){
					getTask(accId, lstCommItems, filter, oppAux);
				}
				if(oportunidad == true ){
					getOppsHistory(accId, lstCommItems, filter, true);
				}
				if(caso == true ){
					getCases(accId, lstCommItems, filter);
				}

				
			
				lstCommItems.sort();
				Map<String,List<CommentItem>> dateCommentListMap = groupByDate(lstCommItems);
				return dateCommentListMap;
			}
		}
	
		/**
		* Returns a map that relates the apiName AND the label of the values FROM the picklist field Status FROM Activity.
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
	
		/**
		* Returns a map that relates the apiName AND the label of the values FROM the picklist field AV_Tipo__c FROM event.
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
		 * Returns a map that relates the apiName AND the label of the values FROM the picklist field Status FROM Case.
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
		 * Returns a map that relates the apiName AND the label of the values FROM the picklist field Stage FROM Opportunity.
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
		
		private static void getTask(String accId, List<CommentItem> lstCommItems, String filter, Boolean check){
	
			Set<String> setTaskRT = new Set<String>{CIBE_AppConstants.TASK_ALERTACOMERCIAL_EMP_RT, CIBE_AppConstants.TASK_ONBOARDING_EMP_RT,
													CIBE_AppConstants.TASK_PRIORIZADOS_EMP_RT, CIBE_AppConstants.TASK_OTROS_EMP_RT,
													CIBE_AppConstants.TASK_AVISOS_EMP_RT, CIBE_AppConstants.TASK_EXPERIENCIACLIENTE_EMP_RT};												
			
			
			Set<String> setTaskStatus = new Set<String>{CIBE_AppConstants.GESTIONADO_POSITIVO_ESTADO, CIBE_AppConstants.GESTIONADO_NEGATIVA_ESTADO};
			List<Task> lstClientTasks;
			List<Task> tareas;
	
			if(filter == null){
				lstClientTasks = [SELECT Id, LastModifiedDate, Description, Subject, AV_Tipo__c, Status, OwnerId, Owner.Name, ActivityDate, CompletedDateTime , AV_Task__c
									FROM Task 
									WHERE AccountId =: accId 
									AND RecordType.DeveloperName IN :setTaskRT 
									AND Status IN : setTaskStatus  ORDER BY LastModifiedDate DESC];
				tareas = [SELECT Id, LastModifiedDate, Description, Subject, AV_Tipo__c, Status, OwnerId, Owner.Name, ActivityDate, CompletedDateTime, AV_Task__c
									FROM Task 
									WHERE AccountId =: accId 
									AND RecordType.DeveloperName IN :setTaskRT 
									AND ActivityDate > TODAY  ORDER BY LastModifiedDate DESC];
			}else{
				String filterLike = '%'+filter+'%';

				lstClientTasks = [SELECT Id, LastModifiedDate, Description, Subject, AV_Tipo__c, Status, OwnerId, Owner.Name, ActivityDate, CompletedDateTime , AV_Task__c
									FROM Task 
									WHERE AccountId =: accId 
									AND RecordType.DeveloperName IN :setTaskRT 
									AND Status IN : setTaskStatus 
									AND Subject LIKE :filterLike  ORDER BY LastModifiedDate DESC];
				tareas = [SELECT Id, LastModifiedDate, Description, Subject, AV_Tipo__c, Status, OwnerId, Owner.Name, ActivityDate, CompletedDateTime, AV_Task__c
									FROM Task 
									WHERE AccountId =: accId 
									AND RecordType.DeveloperName IN :setTaskRT 
									AND ActivityDate > TODAY  AND Subject LIKE :filterLike  ORDER BY LastModifiedDate DESC];
			}
			Integer task = lstClientTasks.size();
	
			Map<String, Task> mapTasks = new Map<String, Task>();
			Map<String, Task> mapTasks2 = new Map<String, Task>();
			Set<String> setTaskId = new Set<String>();
			Set<String> idTask = new Set<String>();

			

			for(Task tsk : lstClientTasks) {
				mapTasks.put(tsk.AV_Task__c, tsk);
			}

			if(!tareas.isEmpty()){
				for(Task tsk : tareas) {
					mapTasks2.put(tsk.AV_Task__c, tsk);
				}
			

				List<AV_CustomActivityOpportunity__c> oppVinculadad = [SELECT Id, AV_Task__c, AV_Opportunity__c FROM AV_CustomActivityOpportunity__c WHERE AV_Task__c IN :mapTasks2.keySet()];
				

				if(!oppVinculadad.isEmpty()){
					for (AV_CustomActivityOpportunity__c relation : oppVinculadad) {
						if(relation.AV_Opportunity__c != null){
							setTaskId.add(relation.AV_Task__c);
						}
					}

					List<Task> tareaFuturo = [SELECT Id, LastModifiedDate, AV_Task__c, ActivityDate, Subject, Description, AV_Tipo__c, OwnerId, Owner.Name, CompletedDateTime, Status FROM Task WHERE AV_Task__c IN : setTaskId ORDER BY LastModifiedDate DESC];
					if(!tareaFuturo.isEmpty()){
						for (Task relation : tareaFuturo) {
							if(!mapTasks.containsKey(relation.AV_Task__c)){
								mapTasks.put(relation.AV_Task__c, relation);
								lstClientTasks.add(relation);
							}
						}
					}
				}

				if(mapTasks2 != null){
					for (Task tareaComment : mapTasks2.values()) {
						if(tareaComment.Description != null || (!mapTasks.containsKey(tareaComment.AV_Task__c) && tareaComment.Description != null) ){
							if(!mapTasks.containsKey(tareaComment.AV_Task__c)){
								lstClientTasks.add(tareaComment);
								mapTasks.put(tareaComment.AV_Task__c, tareaComment);
							}
						}
					}
				}

			}	
			
			if(check == true){
				if(lstClientTasks != null && !lstClientTasks.isEmpty()) {
		
					Map<String,String> statusTaskLabels = getTaskStatusLabel();
					Map<String,String> typeTaskLabels = getContactTypeLabel();
		
					for(Task data : lstClientTasks) {

						Datetime dtTask = datetime.newInstance(data.LastModifiedDate.year(), data.LastModifiedDate.month(),data.LastModifiedDate.day());

						String dateOutput = dtTask.format('dd-MM-yyyy');
						Map<String,String> stageOppLabels = getOppStageLabel();


						CommentItem cmItTask = new CommentItem(data.LastModifiedDate, dtTask, dateOutput,'task', data.Owner.Name, null, data.Description, Label.CIBE_Task + ' - ' + data.Subject, data.Id, 
						statusTaskLabels.get(data.Status), typeTaskLabels.get(data.AV_Tipo__c), null);
						lstCommItems.add(cmItTask);	
					}
				}
			}else{

				List <AV_CommentsHistory__c> listComentarios = [SELECT Id,name, AV_Opportunity__r.RecordType.DeveloperName, AV_NewComment__c,AV_Event__c, CreatedDate, AV_Task__c,AV_OpportunityStatus__c,AV_OldComment__c,AV_OldStatus__c, AV_NewStatus__c,  AV_Opportunity__r.CloseDate,AV_Opportunity__r.AV_CommentLastModifiedDate__c, AV_Opportunity__c, AV_Opportunity__r.Owner.Name, AV_Opportunity__r.AV_PF__r.Name, AV_Opportunity__r.Name, AV_Opportunity__r.StageName, AV_Opportunity__r.LastModifiedDate , AV_AssignedEmployee__c, AV_AssignedEmployee__r.Name, AV_ModificationDate__c FROM AV_CommentsHistory__c 
				WHERE AV_Task__c = :mapTasks.keySet() ORDER BY AV_ModificationDate__c DESC];

				Map<Id, Map<Id, DateTime>> comentariosPorEventoYOpportunity2 = new Map<Id, Map<Id, DateTime>>();   
				List<Id> listOppCom = new List<Id>();

				for (AV_CommentsHistory__c comentario : listComentarios) {
					if(comentario.AV_Opportunity__c != null){

						if(comentariosPorEventoYOpportunity2.containsKey(comentario.AV_Task__c)){
							if((comentariosPorEventoYOpportunity2.get(comentario.AV_Task__c).containsKey(comentario.AV_Opportunity__c) && comentario.CreatedDate > comentariosPorEventoYOpportunity2.get(comentario.AV_Task__c).get(comentario.AV_Opportunity__c)) || !comentariosPorEventoYOpportunity2.get(comentario.AV_Task__c).containsKey(comentario.AV_Opportunity__c)){
								comentariosPorEventoYOpportunity2.get(comentario.AV_Task__c).put(comentario.AV_Opportunity__c,comentario.CreatedDate);
							}
						}else{
							comentariosPorEventoYOpportunity2.put(comentario.AV_Task__c,new Map<Id,DateTime>{comentario.AV_Opportunity__c => comentario.CreatedDate});
						}
						if(!listOppCom.contains(comentario.AV_Opportunity__c)) {
							if(comentario.AV_Opportunity__r.StageName == CIBE_AppConstants.OPPORTUNITY_STATUS_POTENCIAL && comentario.AV_Opportunity__r.CloseDate > System.today()){
								listOppCom.add(comentario.AV_Opportunity__c);
							}else if(comentario.AV_Opportunity__r.StageName != CIBE_AppConstants.OPPORTUNITY_STATUS_POTENCIAL){
								listOppCom.add(comentario.AV_Opportunity__c);
							}
						}
					}
				}	

				
				List<AV_CommentsHistory__c> listCommHist = [SELECT Id,name,AV_NewComment__c,AV_Event__c, AV_Task__c,AV_OpportunityStatus__c,AV_OldComment__c,AV_OldStatus__c, AV_NewStatus__c,CreatedDate, AV_Opportunity__r.CloseDate,AV_Opportunity__r.AV_CommentLastModifiedDate__c, AV_Opportunity__c, AV_Opportunity__r.Owner.Name, AV_Opportunity__r.AV_PF__r.Name, AV_Opportunity__r.Name, AV_Opportunity__r.StageName, AV_Opportunity__r.LastModifiedDate , AV_AssignedEmployee__c, AV_AssignedEmployee__r.Name, AV_ModificationDate__c , AV_Opportunity__r.AV_Comentarios__c
				FROM AV_CommentsHistory__c WHERE AV_Opportunity__c IN: listOppCom ORDER BY AV_ModificationDate__c DESC ];

				Map<Id, List<AV_CommentsHistory__c>> mapOppsListCmH= new Map<Id, List<AV_CommentsHistory__c>>();
				Map<Id,Map<Id,List<AV_CommentsHistory__c>>> mapaFinal = new Map<Id,Map<Id,List<AV_CommentsHistory__c>>>();
				if(!listCommHist.isEmpty()){
					for (AV_CommentsHistory__c comentario : listCommHist) {

						if(comentario.AV_Task__c != null){
							if (!mapOppsListCmH.containsKey(comentario.AV_Opportunity__c)) {
								mapOppsListCmH.put(comentario.AV_Opportunity__c, new List<AV_CommentsHistory__c>{comentario});
							}else{
								mapOppsListCmH.get(comentario.AV_Opportunity__c).add(comentario);
							}
						}

						
					}


					if(mapOppsListCmH != null){
						for (Id taskId : comentariosPorEventoYOpportunity2.keySet()) {
							if(comentariosPorEventoYOpportunity2.get(taskId)!= null){
								for (Id opportunityId : comentariosPorEventoYOpportunity2.get(taskId).keySet()) {
									if(mapOppsListCmH.get(opportunityId) != null){
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
						}
					}

				}
			
			
			

			
				if(lstClientTasks != null && !lstClientTasks.isEmpty()) {
		
					Map<String,String> statusTaskLabels = getTaskStatusLabel();
					Map<String,String> typeTaskLabels = getContactTypeLabel();
		
					for(Task data : lstClientTasks) {
						Datetime dtTask = datetime.newInstance(data.LastModifiedDate.year(), data.LastModifiedDate.month(),data.LastModifiedDate.day());

						String dateOutput = dtTask.format('dd-MM-yyyy');
						Map<String,String> stageOppLabels = getOppStageLabel();

						CommentItem cmItTask = new CommentItem(data.LastModifiedDate, dtTask, dateOutput,'task', data.Owner.Name, null, data.Description, Label.CIBE_Task + ' - ' + data.Subject, data.Id, 
						statusTaskLabels.get(data.Status), typeTaskLabels.get(data.AV_Tipo__c), null);
						if( mapaFinal!=null && mapaFinal.get(data.AV_Task__c)!=null){
							for(Id oppId: mapaFinal.get(data.AV_Task__c).keySet()){
								if(mapaFinal.get(data.AV_Task__c).get(oppId)!=null){
									Integer contador = 0;
									CommentItem cmItmOpp;
									for (AV_CommentsHistory__c cm :mapaFinal.get(data.AV_Task__c).get(oppId)){
										if(cm.AV_Opportunity__c != null && cm.AV_Opportunity__r.LastModifiedDate != null){
											setOppIdTsk.add(cm.AV_Opportunity__c);
											Datetime dtTaskCompare = datetime.newInstance(cm.AV_Opportunity__r.LastModifiedDate.year(), cm.AV_Opportunity__r.LastModifiedDate.month(),cm.AV_Opportunity__r.LastModifiedDate.day());

											String dateOutput2;
											if(cm.AV_ModificationDate__c != null){
												dateOutput2 = cm.AV_ModificationDate__c.format('dd-MM-yyyy');
											}else{
												dateOutput2 = '';
											}

											if(contador == 0){
												cmItmOpp = new CommentItem(dtTaskCompare, cm.AV_Opportunity__r.LastModifiedDate, cm.AV_Opportunity__r.LastModifiedDate.format('dd-MM-yyyy'), 'opportunity', cm.AV_Opportunity__r.Owner.Name, 
												cm.AV_Opportunity__r.AV_PF__r.Name, null,  Label.CIBE_Oportunidad + ' - ' +  cm.AV_Opportunity__r.Name, cm.AV_Opportunity__c, stageOppLabels.get(cm.AV_Opportunity__r.StageName), null, null);
												cmItmOpp.colorStageNameLabelOppsNested = getColorLabelstNmOpp(cm.AV_Opportunity__r.StageName);
												
												if(cm.AV_NewComment__c!=null){
													cmItmOpp.comentarios.add(new CommentHistoryItem(dateOutput2, cm.AV_NewComment__c));
												}
												
												contador++;
											}

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
		}

		private static void getEvent(String accId, List<CommentItem> lstCommItems, String filter, Boolean check){
	
			List<Event> lstClientEvents;
			List<Task> lstClientTasks;
			Set<Id> setIdEvent = new Set<Id>();
			List<CBK_Activity_Extension__c> lstActExtension;

			if(filter == null ){
				lstClientEvents = [SELECT Id, Description, ActivityDateTime,  Subject, AV_Tipo__c, OwnerId, Owner.Name, ActivityDate, StartDateTime, CSBD_Evento_Estado__c, AV_Task__c, AV_EventoEstado__c
									FROM Event 
									WHERE AccountId =: accId 
									AND RecordType.DeveloperName ='CIBE_EventoCliente' 
									AND IsChild = false 
									AND (CSBD_Evento_Estado__c ='Gestionada Positiva' OR CSBD_Evento_Estado__c ='Pendiente')   ORDER BY ActivityDateTime DESC ];

			}else{
				String filterLike = '%'+filter+'%';

				lstClientEvents = [SELECT Id, Description, ActivityDateTime,  Subject, AV_Tipo__c, OwnerId, Owner.Name, ActivityDate, StartDateTime, CSBD_Evento_Estado__c, AV_Task__c, AV_EventoEstado__c
									FROM Event 
									WHERE AccountId =: accId 
									AND RecordType.DeveloperName ='CIBE_EventoCliente' 
									AND IsChild = false 
									AND (CSBD_Evento_Estado__c ='Gestionada Positiva' OR CSBD_Evento_Estado__c ='Pendiente') 
									AND Subject LIKE : filterLike  ORDER BY ActivityDateTime DESC];
			}
	
			Map<Id, Event> mapEvts = new Map<Id, Event>();
			if(!lstClientEvents.isEmpty()){
				for(Event ev : lstClientEvents) {
					if(ev != null && ev.AV_Task__c != null && ev.Id != null){
						mapEvts.put(ev.AV_Task__c, ev);
						setIdEvent.add(ev.Id);
					}
				}
			}

			lstActExtension = [SELECT Id, AV_ActivityId__c, CIBE_ComentarioCita__c FROM CBK_Activity_Extension__c WHERE AV_ActivityId__c =: setIdEvent];
			Map<String, CBK_Activity_Extension__c> mapActEx = new Map<String, CBK_Activity_Extension__c>();
			for(CBK_Activity_Extension__c actEx : lstActExtension) {
				if(actEx.AV_ActivityId__c !=null){
					mapActEx.put(actEx.AV_ActivityId__c, actEx);
				}
			}

			if(check == true){
				if(lstClientEvents != null && !lstClientEvents.isEmpty()) {
					Map<String,String> typeEventLabels = getContactTypeLabel();
				
					for(Event data : lstClientEvents) {
						Datetime dtEvent = datetime.newInstance(data.StartDateTime.year(), data.StartDateTime.month(),data.StartDateTime.day());
						String dateOutput = dtEvent.format('dd-MM-yyyy');
						String comentarioCita = mapActEx.get(data.Id) != null ? mapActEx.get(data.Id).CIBE_ComentarioCita__c : '';
				
						CommentItem cmItEv = new CommentItem(data.ActivityDateTime, dtEvent, dateOutput, 'event', data.Owner.Name, null, comentarioCita, Label.CIBE_Event + ' - ' + data.Subject, data.Id, data.AV_EventoEstado__c, typeEventLabels.get(data.AV_Tipo__c), null);
						lstCommItems.add(cmItEv);
					}
				}
			}else{
				if(lstClientEvents != null && !lstClientEvents.isEmpty()) {
					Map<String,String> typeEventLabels = getContactTypeLabel();
					Map<String,String> stageOppLabels = getOppStageLabel();


					List <AV_CommentsHistory__c> listComentarios = [SELECT  Id,name, AV_Opportunity__r.RecordType.DeveloperName, AV_NewComment__c,AV_Event__c, CreatedDate, AV_Task__c,AV_OpportunityStatus__c,AV_OldComment__c,AV_OldStatus__c, AV_NewStatus__c,  AV_Opportunity__r.CloseDate,AV_Opportunity__r.AV_CommentLastModifiedDate__c, AV_Opportunity__c, AV_Opportunity__r.Owner.Name, AV_Opportunity__r.AV_PF__r.Name, AV_Opportunity__r.Name, AV_Opportunity__r.StageName, AV_Opportunity__r.LastModifiedDate , AV_AssignedEmployee__c, AV_AssignedEmployee__r.Name, AV_ModificationDate__c 
						FROM AV_CommentsHistory__c  WHERE AV_Event__c = :mapEvts.keySet() 
						ORDER BY AV_ModificationDate__c DESC];
					Map<Id, Map<Id, DateTime>> comentariosPorEventoYOpportunity2 = new Map<Id, Map<Id, DateTime>>();   
					List<Id> listOppCom = new List<Id>(); //id de Opps
					Map<Id,Map<Id,List<AV_CommentsHistory__c>>> mapaFinal = new Map<Id,Map<Id,List<AV_CommentsHistory__c>>>();
					Map<Id, List<AV_CommentsHistory__c>> mapOppsListCmH= new Map<Id, List<AV_CommentsHistory__c>>();

					if(!listComentarios.isEmpty()){
						for (AV_CommentsHistory__c comentario : listComentarios) {

							if(comentario.AV_Opportunity__c != null){
								if(comentariosPorEventoYOpportunity2.containsKey(comentario.AV_Event__c)){
									if((comentariosPorEventoYOpportunity2.get(comentario.AV_Event__c).containsKey(comentario.AV_Opportunity__c) && comentario.CreatedDate > comentariosPorEventoYOpportunity2.get(comentario.AV_Event__c).get(comentario.AV_Opportunity__c)) || !comentariosPorEventoYOpportunity2.get(comentario.AV_Event__c).containsKey(comentario.AV_Opportunity__c)){
										comentariosPorEventoYOpportunity2.get(comentario.AV_Event__c).put(comentario.AV_Opportunity__c,comentario.CreatedDate);
									}
								}else{
									comentariosPorEventoYOpportunity2.put(comentario.AV_Event__c,new Map<Id,DateTime>{comentario.AV_Opportunity__c => comentario.CreatedDate});
								}
		
								if(!listOppCom.contains(comentario.AV_Opportunity__c)) {
									if(comentario.AV_Opportunity__r.StageName == CIBE_AppConstants.OPPORTUNITY_STATUS_POTENCIAL && comentario.AV_Opportunity__r.CloseDate > System.today()  ){
										listOppCom.add(comentario.AV_Opportunity__c);
									}
									if(comentario.AV_Opportunity__r.StageName != CIBE_AppConstants.OPPORTUNITY_STATUS_POTENCIAL){
										listOppCom.add(comentario.AV_Opportunity__c);
									}
								}
							}
						}
	
						List<AV_CommentsHistory__c> listCommHist = [SELECT Id,name,AV_NewComment__c,AV_Event__c, AV_Task__c,AV_OpportunityStatus__c,AV_OldComment__c,AV_OldStatus__c, AV_NewStatus__c,CreatedDate, AV_Opportunity__r.CloseDate,AV_Opportunity__r.AV_CommentLastModifiedDate__c, AV_Opportunity__c, AV_Opportunity__r.Owner.Name, AV_Opportunity__r.AV_PF__r.Name, AV_Opportunity__r.Name, AV_Opportunity__r.StageName, AV_Opportunity__r.LastModifiedDate , AV_AssignedEmployee__c, AV_AssignedEmployee__r.Name, AV_ModificationDate__c , AV_Opportunity__r.AV_Comentarios__c
						FROM AV_CommentsHistory__c WHERE AV_Opportunity__c IN: listOppCom  ORDER BY AV_ModificationDate__c DESC ];
	
						if(!listCommHist.isEmpty()){
							for (AV_CommentsHistory__c comentario : listCommHist) {
								if(comentario.AV_Event__c != null){
									if (!mapOppsListCmH.containsKey(comentario.AV_Opportunity__c)) {
										mapOppsListCmH.put(comentario.AV_Opportunity__c, new List<AV_CommentsHistory__c>{comentario});
									}else{
										mapOppsListCmH.get(comentario.AV_Opportunity__c).add(comentario);
									}
								}
							}
			
							if(comentariosPorEventoYOpportunity2 != null){
								for (Id eventId : comentariosPorEventoYOpportunity2.keySet()) {
									if(comentariosPorEventoYOpportunity2.get(eventId)!= null){
										for (Id opportunityId : comentariosPorEventoYOpportunity2.get(eventId).keySet()) {
											if(mapOppsListCmH.get(opportunityId) != null){
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
								}
							}
						}				
					}

					for(Event data : lstClientEvents) {
						Datetime dtEvent = datetime.newInstance(data.StartDateTime.year(), data.StartDateTime.month(),data.StartDateTime.day());
						String dateOutput = dtEvent.format('dd-MM-yyyy');
						String comentarioCita = mapActEx.get(data.Id) != null ? mapActEx.get(data.Id).CIBE_ComentarioCita__c : '';
						CommentItem cmItEv = new CommentItem(data.ActivityDateTime, dtEvent, dateOutput, 'event', data.Owner.Name, null, comentarioCita, Label.CIBE_Event + ' - ' + data.Subject, data.Id, data.AV_EventoEstado__c, typeEventLabels.get(data.AV_Tipo__c), null);
						if( mapaFinal!=null && mapaFinal.get(data.AV_Task__c)!=null){
							for(Id oppId: mapaFinal.get(data.AV_Task__c).keySet()){
								if(mapaFinal.get(data.AV_Task__c).get(oppId)!=null){
									Integer contador = 0;
									CommentItem cmItmOpp;
									for (AV_CommentsHistory__c cm :mapaFinal.get(data.AV_Task__c).get(oppId)){
										if(cm.AV_Opportunity__c != null && cm.AV_Opportunity__r.LastModifiedDate != null){
											setOppIdEvnt.add(cm.AV_Opportunity__c);

											Datetime dtEvntCompare = datetime.newInstance(cm.AV_Opportunity__r.LastModifiedDate.year(), cm.AV_Opportunity__r.LastModifiedDate.month(),cm.AV_Opportunity__r.LastModifiedDate.day());
	
											String dateOutput2;
											if(cm.AV_Opportunity__r.AV_CommentLastModifiedDate__c != null){
												dateOutput2 = cm.AV_ModificationDate__c.format('dd-MM-yyyy');
											}else{
												dateOutput2 = '';
											}
	
											if(contador == 0){
												cmItmOpp = new CommentItem(dtEvntCompare, cm.AV_Opportunity__r.LastModifiedDate, cm.AV_Opportunity__r.LastModifiedDate.format('dd-MM-yyyy'), 'opportunity', cm.AV_Opportunity__r.Owner.Name, 
												cm.AV_Opportunity__r.AV_PF__r.Name, null,  Label.CIBE_Oportunidad + ' - ' +  cm.AV_Opportunity__r.Name, cm.AV_Opportunity__c, stageOppLabels.get(cm.AV_Opportunity__r.StageName), null, null);
												cmItmOpp.colorStageNameLabelOppsNested = getColorLabelstNmOpp(cm.AV_Opportunity__r.StageName);
												contador++;
	
												if(cm.AV_NewComment__c != null){
													cmItmOpp.comentarios.add(new CommentHistoryItem(dateOutput2, cm.AV_NewComment__c));
												}
											}
										}

									}
									if(cmItmOpp != null){
										cmItEv.nestedOpportunities.add(cmItmOpp);
									}	
									
								}
							}
						}
						lstCommItems.add(cmItEv);		
					}
				}
			}
		}
	
		private static void getOppsHistory(String accId, List<CommentItem> lstCommItems, String filter, Boolean check){
	
			Set<String> setRTOpp = new Set<String>{CIBE_AppConstants.OPP_INICIATIVAEMP_RT, CIBE_AppConstants.OPP_ACCIONEMP_RT, CIBE_AppConstants.OPP_ALERTAEMP_RT, CIBE_AppConstants.OPP_SUGERENCIAEMP_RT};
			
			Set<String> setStatusOpp = new Set<String>{CIBE_AppConstants.OPPORTUNITY_STATUS_PENDFIRMA, CIBE_AppConstants.OPPORTUNITY_STATUS_VENCIDO, 
													CIBE_AppConstants.OPPORTUNITY_STATUS_CERRPOSI, CIBE_AppConstants.OPPORTUNITY_STATUS_CERRNEGA,
													CIBE_AppConstants.OPPORTUNITY_STATUS_ENCURSO};
			
			List<AV_CommentsHistory__c> lstClientOppsHistory;
			Set<String> oppId = new Set<String>();
			Set<String> oppEvnt = new Set<String>();

			if(check){
				if(String.isBlank(filter)){
					lstClientOppsHistory = [SELECT Id, AV_NewComment__c, AV_Opportunity__r.AV_CommentLastModifiedDate__c, AV_Opportunity__r.CloseDate, AV_Opportunity__c, AV_Opportunity__r.Owner.Name, AV_Opportunity__r.AV_PF__r.Name, AV_Opportunity__r.Name, AV_Opportunity__r.StageName, AV_Opportunity__r.LastModifiedDate , AV_AssignedEmployee__c, AV_AssignedEmployee__r.Name, AV_ModificationDate__c, LastModifiedDate , AV_Opportunity__r.AV_Comentarios__c
											FROM AV_CommentsHistory__c 
											WHERE AV_Opportunity__r.AccountId = :accId 
											AND AV_Opportunity__r.RecordType.DeveloperName IN : setRTOpp 
											AND AV_Opportunity__r.StageName IN : setStatusOpp 
											ORDER BY AV_ModificationDate__c DESC
											];
		
				}else{
					String filterLike = '%'+filter+'%';
					lstClientOppsHistory = [SELECT Id, AV_NewComment__c, AV_Opportunity__r.AV_CommentLastModifiedDate__c, AV_Opportunity__r.CloseDate, AV_Opportunity__c, AV_Opportunity__r.Owner.Name, AV_Opportunity__r.AV_PF__r.Name, AV_Opportunity__r.Name, AV_Opportunity__r.StageName, AV_Opportunity__r.LastModifiedDate , AV_AssignedEmployee__c, AV_AssignedEmployee__r.Name, AV_ModificationDate__c, LastModifiedDate , AV_Opportunity__r.AV_Comentarios__c
											FROM AV_CommentsHistory__c 
											WHERE AV_Opportunity__r.AccountId = :accId 
											AND AV_Opportunity__r.RecordType.DeveloperName IN : setRTOpp 
											AND AV_Opportunity__r.StageName IN : setStatusOpp 
											AND AV_Opportunity__r.Name LIKE :filterLike 
											ORDER BY AV_ModificationDate__c DESC
											];
				}
			}else{

				if(String.isBlank(filter)){
					lstClientOppsHistory = [SELECT Id, AV_NewComment__c, AV_Opportunity__r.AV_CommentLastModifiedDate__c, AV_Opportunity__r.CloseDate, AV_Opportunity__c, AV_Opportunity__r.Owner.Name, AV_Opportunity__r.AV_PF__r.Name, AV_Opportunity__r.Name, AV_Opportunity__r.StageName, AV_Opportunity__r.LastModifiedDate , AV_AssignedEmployee__c, AV_AssignedEmployee__r.Name, AV_ModificationDate__c, LastModifiedDate , AV_Opportunity__r.AV_Comentarios__c
											FROM AV_CommentsHistory__c 
											WHERE AV_Opportunity__r.AccountId = :accId 
											AND AV_Opportunity__r.RecordType.DeveloperName IN : setRTOpp 
											AND AV_Opportunity__r.StageName IN : setStatusOpp 
											AND (AV_Event__c = null OR AV_Task__c = null) AND (AV_Opportunity__c NOT IN :setOppIdEvnt AND AV_Opportunity__c NOT IN :setOppIdTsk) ORDER BY AV_ModificationDate__c DESC
											];
				}else{
					String filterLike = '%'+filter+'%';
					lstClientOppsHistory = [SELECT Id, AV_NewComment__c, AV_Opportunity__r.AV_CommentLastModifiedDate__c, AV_Opportunity__r.CloseDate, AV_Opportunity__c, AV_Opportunity__r.Owner.Name, AV_Opportunity__r.AV_PF__r.Name, AV_Opportunity__r.Name, AV_Opportunity__r.StageName, AV_Opportunity__r.LastModifiedDate , AV_AssignedEmployee__c, AV_AssignedEmployee__r.Name, AV_ModificationDate__c, LastModifiedDate , AV_Opportunity__r.AV_Comentarios__c
											FROM AV_CommentsHistory__c 
											WHERE AV_Opportunity__r.AccountId = :accId 
											AND AV_Opportunity__r.RecordType.DeveloperName IN : setRTOpp 
											AND AV_Opportunity__r.StageName IN : setStatusOpp 
											AND AV_Opportunity__r.Name LIKE :filterLike 
											AND  (AV_Event__c = null OR AV_Task__c = null) AND (AV_Opportunity__c NOT IN :setOppIdEvnt AND AV_Opportunity__c NOT IN :setOppIdTsk)  ORDER BY AV_ModificationDate__c DESC
											];
				}
			}
	
			
			Integer size = lstClientOppsHistory.size();

			if(lstClientOppsHistory != null && !lstClientOppsHistory.isEmpty()) {
				Map<String,String> stageOppLabels = getOppStageLabel();
	
				for(AV_CommentsHistory__c oppH : lstClientOppsHistory) {
						
						Date dateOpp = oppH.AV_Opportunity__r.LastModifiedDate.date();
						String dateOutput = oppH.AV_Opportunity__r.LastModifiedDate.format('dd-MM-yyyy');
						String dateOutput2;
						if(oppH.AV_ModificationDate__c != null){
							dateOutput2 = oppH.AV_ModificationDate__c.format('dd-MM-yyyy');
						}else{
							dateOutput2 = '';
						}
						Datetime dtOppCompare = datetime.newInstance(oppH.AV_Opportunity__r.LastModifiedDate.year(), oppH.AV_Opportunity__r.LastModifiedDate.month(),oppH.AV_Opportunity__r.LastModifiedDate.day());

						CommentItem citOpp = new CommentItem(dtOppCompare,dateOpp, 
						dateOutput, 
						'opportunity', 
						oppH.AV_Opportunity__r.Owner.Name, 
						oppH.AV_Opportunity__r.AV_PF__r.Name,
						oppH.AV_NewComment__c,
						Label.CIBE_Oportunidad + ' - ' +  oppH.AV_Opportunity__r.Name, 
						oppH.AV_Opportunity__c, 
						stageOppLabels.get(oppH.AV_Opportunity__r.StageName), 
						null, 
						null);

						citOpp.comment = oppH.AV_NewComment__c;
						citOpp.colorStageNameLabelOppsNested = getColorLabelstNmOpp(oppH.AV_Opportunity__r.StageName);
						if(oppH.AV_Opportunity__r.AV_Comentarios__c != null){
							citOpp.comentarios.add(new CommentHistoryItem(dateOutput2, oppH.AV_NewComment__c));
						}

						if(!oppId.contains(oppH.AV_Opportunity__c)){
							oppId.add(oppH.AV_Opportunity__c);
							lstCommItems.add(citOpp);
						}
				}
			}
		}
	
		private static void getCases(String accId, List<CommentItem> lstCommItems, String filter){
	
			List<Case> lstClientCases;
			if(String.isBlank(filter)){
				lstClientCases = [SELECT Id, CC_MCC_ProdServ__c, CC_MCC_ProdServ__r.Name, Status, Origin, SEG_Fecha_planificaci_n__c, CreatedDate, LastModifiedDate  
									FROM Case 
									WHERE AccountId = :accId ];
			}else{
				String filterLike = '%'+filter+'%';
				lstClientCases = [SELECT Id, CC_MCC_ProdServ__c, CC_MCC_ProdServ__r.Name, Status, Origin, SEG_Fecha_planificaci_n__c, CreatedDate, LastModifiedDate  
									FROM Case 
									WHERE AccountId = :accId 
									AND CC_MCC_ProdServ__r.Name LIKE : filterLike ];
			}
			Integer size = lstClientCases.size();
			
			if(lstClientCases != null && !lstClientCases.isEmpty()) {
				Map<String,String> statusCaseLabels = getCaseStatusLabel();
				String productName;
	
				for(Case c : lstClientCases) {
	
					if(c.CC_MCC_ProdServ__r?.Name != null){
						productName = c.CC_MCC_ProdServ__r?.Name;
					}else{
						productName='' ;
					}

					Date dateCase = c.LastModifiedDate.date();
					String dateOutput = c.LastModifiedDate.format('dd-MM-yyyy');
					lstCommItems.add(new CommentItem(c.CreatedDate, c.LastModifiedDate, 
														dateOutput, 
														'case', 
														null, 
														null, 
														null,
														Label.CIBE_Caso + ' - ' + productName, 
														c.Id, 
														statusCaseLabels.get(c.Status), 
														null, 
														c.Origin));
				}
			}
		}
	
		private static Map<String,List<CommentItem>> groupByDate(List<CommentItem> lstCommItems){
	
			Map<String,List<CommentItem>> dateCommentListMap = new Map<String,List<CommentItem>>();
			Map<String,String> monthMap = new Map<String,String>{'January' => 'Enero', 'February' => 'Febrero', 'March' => 'Marzo','April' => 'Abril', 'May' => 'Mayo', 'June' => 'Junio','July' => 'Julio', 'August' => 'Agosto', 'September' => 'Septiembre','October' => 'Octubre', 'November' => 'Noviembre', 'December' => 'Diciembre'};
	
			for(CommentItem c: lstCommItems){
				if(c.dateTimeField != null){
					Date dateFieldAux = c.dateTimeField.date();
					String monthYearString =  monthMap.get(c.dateTimeField.format('MMMM')) + ' ' + String.valueOf(dateFieldAux.year());
	
					if( dateCommentListMap.containsKey(monthYearString) ){
						List<CommentItem> commentList = dateCommentListMap.get(monthYearString);
						commentList.add(c);
						dateCommentListMap.put(monthYearString, commentList);
					}else{
						List<CommentItem> commentList = new List<CommentItem>();
						commentList.add(c);
						dateCommentListMap.put(monthYearString, commentList);
					}
				}
			}
	
			return dateCommentListMap;
		}
	
		public class CommentItem implements Comparable {
			@AuraEnabled
			public DateTime dateTimeCompare;
			@AuraEnabled
			public DateTime dateTimeField;
			@AuraEnabled
			public String dateField;
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
			public String recordId;
			@AuraEnabled
			public String status;
			@AuraEnabled
			public String contactType;
			@AuraEnabled
			public String caseChannel;
			@AuraEnabled
			public Long id;
			@AuraEnabled
			public String colorStageNameLabelOppsNested;
			@AuraEnabled
			public List<CommentItem> nestedOpportunities;
			@AuraEnabled
			public List<CommentHistoryItem> comentarios;
			
			public CommentItem(DateTime dtc, DateTime dt, String  d, String ty, String emp, String prod, String comm, String sub, String rId, String statusC, String cType, String caseChannelC) {
				dateTimeCompare = dtc;
				dateTimeField = dt;
				dateField = d;
				type = ty;
				employee = emp;
				product = prod;
				comment = comm;
				subject = sub;
				recordId = rId;
				status = statusC;
				contactType = cType;
				caseChannel = caseChannelC;
				colorStageNameLabelOppsNested = null;  
				nestedOpportunities = new List<CommentItem>();  
				comentarios = new List<CommentHistoryItem>();
			}
	
			public Integer compareTo(Object compareTo) {
				CommentItem compareToItem = (CommentItem)compareTo;
			
				// Convertir las fechas a DateTime y luego a milisegundos (timestamp) para la comparación
				Long thisTimestamp = dateTimeCompare != null ? dateTimeCompare.getTime() : null;
				Long compareToTimestamp = compareToItem.dateTimeCompare != null ? compareToItem.dateTimeCompare.getTime() : null;
			
				// Manejar casos donde dateTimeField puede ser null en alguno de los objetos
				if (thisTimestamp == null && compareToTimestamp == null){
					return 0;
				} 
				if (thisTimestamp == null){
					return 1; // o -1 dependiendo de si quieres nulls al principio o al final
				} 
				if (compareToTimestamp == null){
					return -1; // o 1 dependiendo de si quieres nulls al principio o al final
				} 
				// Comparar los timestamps
				if (thisTimestamp < compareToTimestamp){
					return 1; // o -1 para orden ascendente
				} 
				if (thisTimestamp > compareToTimestamp){
					return -1; // o 1 para orden ascendente
				} 
			
				return 0;        
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


		/**
     * Returns the value of teh color of teh StageName Label of the Opportunity.
     * @param String stageName
     * @return String
     */
    private static String getColorLabelstNmOpp(String stageName){
		if(stageName == CIBE_AppConstants.OPPORTUNITY_STATUS_PENDFIRMA){
				return  '#fae7b8'; 
		}else if(stageName == CIBE_AppConstants.OPPORTUNITY_STATUS_CERRPOSI){
			return  '#ccffe0';
		}else if(stageName == CIBE_AppConstants.OPPORTUNITY_STATUS_CERRNEGA){
			return  '#a6a6a6';
		}else if(stageName == CIBE_AppConstants.OPPORTUNITY_STATUS_POTENCIAL){
			return  '#d9d9d9';
		}else{
			return   '#66c2ff';
		}
		
	}
}