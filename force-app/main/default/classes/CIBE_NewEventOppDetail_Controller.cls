/**********************************************************************************************************************
Name:      CIBE_NewEventController
Copyright © 2023  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Clase controladora para el componente CIBE_NewEvent, cibe_NewEventReportDetail, cibe_newEventTab
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
	VERSION        USER_STORY       AUTHOR                  DATE                Description
	1.0                             Alvaro, Lucia                              Init version
	1.1             US774293        Bea, Ali                16/01/2024
	1.2             FIX             Luis                    18/03/2024          Mejora performance getOpportunitiesFromEvent()             
***********************************************************************************************************************/

public without sharing class  CIBE_NewEventOppDetail_Controller {

	private static List<String> OppRct = new List<String> {CIBE_AppConstants.OPP_INICIATIVAEMP_RT, CIBE_AppConstants.OPP_ACCIONEMP_RT, CIBE_AppConstants.OPP_ALERTAEMP_RT, CIBE_AppConstants.OPP_SUGERENCIAEMP_RT};

	@AuraEnabled
	public static List<OpportunityWrapper> getAccountOpportunities(String accountId){
		List<OpportunityWrapper> response = new List<OpportunityWrapper>();
		String currentUserId = UserInfo.getUserId();
		
		List<Opportunity> oppList = [SELECT Id, CIBE_OpportunityTeam__c,  name, AccountId, stageName, AV_PF__c, CloseDate, CIBE_AmountDivisa__c, CIBE_ProbabilidadExito__c, AV_Comentarios__c, AV_FechaVencimiento__c,
										AV_CommentLastModifiedDate__c, CIBE_Divisa__c, CIBE_Balance__c, CIBE_ComisionesDivisa__c, CIBE_ESG__c, Amount, Account.Name,
										AV_ClienteConfidencial__c, AV_Entidad__c, CIBE_Margen__c, CIBE_Impacto_Balance_Cierre_Anio__c, OwnerId, AV_FechaProximoRecordatorio__c, CIBE_ImporteOtraEntidad__c, TOLABEL(CIBE_CerradoNegativo__c)
									FROM Opportunity 
									WHERE AccountId = :accountId 
									AND RecordType.DeveloperName IN :OppRct 
									AND AV_ToDelete__c = FALSE
									AND 
									(( StageName IN ('Potencial', 'En curso', 'CIBE_Pendiente_Firma') AND CloseDate >= Today) 
									OR (StageName = 'CIBE_Vencido'))   
									ORDER BY CloseDate ASC];
									// StageName NOT IN ('CIBE_Cerrado positivo', 'Cerrado negativo', 'CIBE_Vencido')
									// AND
		Set<String> oppIds = new Set<String>();
		for(Opportunity opp: oppList){
			oppIds.add(opp.Id);
		}
		
		List<OpportunityTeamMember> oppTeamMemberList = [SELECT OpportunityId FROM OpportunityTeamMember
													WHERE OpportunityId IN :oppIds and userID = :currentUserId ];
		
		Set<Id> oppTeamSet = new Set<Id>();
		for(OpportunityTeamMember oppTeam: oppTeamMemberList){
			oppTeamSet.add(oppTeam.OpportunityId);
		}
			
			OpportunityWrapper wrap;
		
			for(Opportunity opp: oppList){
				if(opp.OwnerId == currentUserId || oppTeamSet.contains(opp.Id)){
					wrap = parseWrapper(opp, true, null);
				}else{
					wrap = parseWrapper(opp, false, null);
				}
				
				response.add(wrap);
			}
		return response;
	}

	@AuraEnabled
	public static List<OpportunityAccWrapper> getAccountOpportunitiesGC(List<String> lstAccounts){
		List<OpportunityAccWrapper> response = new List<OpportunityAccWrapper>();
		Map<String, List<OpportunityWrapper>> mapOppWr = new Map <String, List<OpportunityWrapper>>();
		List<OpportunityWrapper> lstOppWr = new List<OpportunityWrapper>();
		String currentUserId = UserInfo.getUserId();
		
		List<Opportunity> oppList = [SELECT Id, CIBE_OpportunityTeam__c,  name, AccountId,Account.name, stageName, AV_PF__c, CloseDate, CIBE_AmountDivisa__c, CIBE_ProbabilidadExito__c, AV_Comentarios__c, AV_FechaVencimiento__c,
										AV_CommentLastModifiedDate__c, CIBE_Divisa__c, CIBE_Balance__c, CIBE_ComisionesDivisa__c, CIBE_ESG__c, Amount,
										AV_ClienteConfidencial__c, AV_Entidad__c, CIBE_Margen__c, CIBE_Impacto_Balance_Cierre_Anio__c, OwnerId, AV_FechaProximoRecordatorio__c, CIBE_ImporteOtraEntidad__c, TOLABEL(CIBE_CerradoNegativo__c)
									FROM Opportunity 
									WHERE AccountId IN :lstAccounts 
									AND RecordType.DeveloperName IN :OppRct 
									AND AV_ToDelete__c = FALSE
									AND 
									(( StageName IN ('Potencial', 'En curso', 'CIBE_Pendiente_Firma') AND CloseDate >= Today) 
									OR (StageName = 'CIBE_Vencido'))   
									ORDER BY CloseDate, AccountId ASC];
									// StageName NOT IN ('CIBE_Cerrado positivo', 'Cerrado negativo', 'CIBE_Vencido')
									// AND
		Set<String> oppIds = new Set<String>();
		for(Opportunity opp: oppList){
			oppIds.add(opp.Id);
		}
		
		List<OpportunityTeamMember> oppTeamMemberList = [SELECT OpportunityId FROM OpportunityTeamMember
													WHERE OpportunityId IN :oppIds and userID = :currentUserId ];
		
		Set<Id> oppTeamSet = new Set<Id>();
		for(OpportunityTeamMember oppTeam: oppTeamMemberList){
			oppTeamSet.add(oppTeam.OpportunityId);
		}
			
			OpportunityWrapper wrap;
		
			for(Opportunity opp: oppList){
				if(opp.OwnerId == currentUserId || oppTeamSet.contains(opp.Id)){
					wrap = parseWrapper(opp, true, null);
				}else{
					wrap = parseWrapper(opp, false, null);
				}
				
				lstOppWr.add(wrap);
			}

			for(OpportunityWrapper opp: lstOppWr){
				if(opp.nomCliente!=null){
					if(!mapOppWr.containsKey(opp.nomCliente)){
						mapOppWr.put(opp.nomCliente, new List<OpportunityWrapper>());
					}
					mapOppWr.get(opp.nomCliente).add(opp);
				}
			}

			for(String opp: mapOppWr.KeySet()){
				OpportunityAccWrapper wrapAccOpp = new OpportunityAccWrapper();
					// wrapAccOpp.cliente = opp+' ('+mapOppWr.get(opp).size()+')';
					wrapAccOpp.cliente = opp;
					wrapAccOpp.lstOppWr = mapOppWr.get(opp);
					response.add(wrapAccOpp);
			}

		return response;
	}

	// @AuraEnabled(cacheable = true)
	// public static List<AggregateResult> geCountRelated(String eventId){
	//     Event evt = [SELECT AV_Task__c FROM Event WHERE Id = :eventId LIMIT 1];
	//     List<AggregateResult> relatedCount = new List<AggregateResult>();
	//     if(evt!=null && evt.AV_Task__c!=null){
	//         relatedCount = [SELECT COUNT(Id) total FROM AV_CustomActivityOpportunity__c WHERE AV_Task__c = : evt.AV_Task__c];
	//     }
	//     return relatedCount;
	// }

	@AuraEnabled
	public static Integer geCountRelated(String eventId){
		Event evt = [SELECT AV_Task__c FROM Event WHERE Id = :eventId LIMIT 1];
		List<AggregateResult> relatedCount = new List<AggregateResult>();
		Integer num =0;
		if(evt!=null && evt.AV_Task__c!=null){
			relatedCount = [SELECT AV_Opportunity__c FROM AV_CustomActivityOpportunity__c WHERE AV_Task__c = : evt.AV_Task__c GROUP BY AV_Opportunity__c Limit 30];
		}
		if(!relatedCount.isEmpty()){
			// num = relatedCount.size();
			num = [SELECT COUNT() FROM AV_CustomActivityOpportunity__c WHERE AV_Task__c = : evt.AV_Task__c  Limit 30];
		}
		return num;
	}

	
	@AuraEnabled(cacheable = true)
	public static Boolean getActivityDate(String eventId){
		Boolean futuro = false;
		if(eventId !=null && !String.isBlank(eventId)){
			List<Event> evt = [SELECT ActivityDate, ActivityDateTime FROM Event WHERE Id = :eventId LIMIT 1];
			if(!evt.isEmpty() && evt[0].ActivityDateTime!=null && evt[0].ActivityDateTime >= DateTime.now()){
				futuro = true;
			}
		}

		return futuro;
	}


	@AuraEnabled
	public static List<OpportunityWrapper> getOpportunitiesFromEvent(String eventId){
		List<OpportunityWrapper> response = new List<OpportunityWrapper>();
		if(eventId!=null){
			Event evt = [SELECT AV_Task__c, AccountId FROM Event WHERE Id = :eventId LIMIT 1];
			if(evt!=null && evt.AV_Task__c !=null ){
				Map<String,AV_CustomActivityOpportunity__c> vinculedOpp = new Map<String,AV_CustomActivityOpportunity__c>();                                                                    
				for(AV_CustomActivityOpportunity__c cao: [SELECT Id, AV_IsMain__c, AV_Opportunity__c FROM AV_CustomActivityOpportunity__c 
														WHERE AV_Task__c = :evt.AV_Task__c AND AV_Opportunity__r.Recordtype.DeveloperName IN :OppRct ORDER BY AV_IsMain__c DESC]){
					vinculedOpp.put(cao.AV_Opportunity__c, cao);
				}
	
				String currentUserId = UserInfo.getUserId();
				Map<Id,Opportunity> oppMap = new Map<Id,Opportunity>( [SELECT Id, name, CIBE_OpportunityTeam__c,  stageName, AV_PF__c, CloseDate, CIBE_AmountDivisa__c, CIBE_ProbabilidadExito__c, AV_Comentarios__c, AV_FechaVencimiento__c,
												AV_CommentLastModifiedDate__c, CIBE_Divisa__c, CIBE_Balance__c, CIBE_ComisionesDivisa__c, CIBE_ESG__c, Amount, AccountId, Account.Name,
												AV_ClienteConfidencial__c, AV_Entidad__c, CIBE_Margen__c, CIBE_Impacto_Balance_Cierre_Anio__c, OwnerId, AV_FechaProximoRecordatorio__c, CIBE_ImporteOtraEntidad__c, TOLABEL(CIBE_CerradoNegativo__c)
											FROM Opportunity 
											WHERE Id IN:vinculedOpp.KeySet() OR (
											AccountId = :evt.accountId 
											AND RecordType.DeveloperName IN :OppRct 
											AND AV_ToDelete__c = FALSE
											AND ((StageName IN ('Potencial', 'En curso', 'CIBE_Pendiente_Firma')
											AND CloseDate >= Today) OR (StageName = 'CIBE_Vencido'))
											AND CreatedDate >= LAST_N_MONTHS:12 ) 
											ORDER BY CloseDate ASC]);        
				
				List<OpportunityTeamMember> oppTeamMemberList = [SELECT OpportunityId FROM OpportunityTeamMember
																WHERE OpportunityId IN :oppMap.KeySet() and userID = :currentUserId ];
				Set<Id> oppTeamSet = new Set<Id>();
				for(OpportunityTeamMember oppTeam: oppTeamMemberList){
					oppTeamSet.add(oppTeam.OpportunityId);
				}
					
					OpportunityWrapper wrap;
					for(AV_CustomActivityOpportunity__c cao: vinculedOpp.Values()){
						if(oppMap.containsKey(cao.AV_Opportunity__c) && (oppMap.get(cao.AV_Opportunity__c).OwnerId == currentUserId ||
							oppTeamSet.contains(cao.AV_Opportunity__c))){
								wrap = parseWrapper(oppMap.get(cao.AV_Opportunity__c), true, cao);
							}else if(oppMap.containsKey(cao.AV_Opportunity__c)){
								wrap = parseWrapper(oppMap.get(cao.AV_Opportunity__c), false, cao);
							}
							if(wrap != null && !response.contains(wrap) ){
								response.add(wrap);
							}
					} 
	
					for(Id oppId: oppMap.KeySet()){
						// if(vinculedOpp.containsKey(oppId)){
						//     if(oppMap.get(oppId).OwnerId == currentUserId || oppTeamSet.contains(oppId)){
						//         wrap = parseWrapper(opp, true, vinculedOpp.get(oppId));
						//     }else{
						//         wrap = parseWrapper(opp, false, vinculedOpp.get(oppId));
						//     }
						// }
						if(!vinculedOpp.containsKey(oppId)){
							if(oppMap.get(oppId).OwnerId == currentUserId || oppTeamSet.contains(oppId)){
								wrap = parseWrapper(oppMap.get(oppId), true, null);
							}else{
								wrap = parseWrapper(oppMap.get(oppId), false, null);
							}
						}
						if(wrap != null && !response.contains(wrap) ){
							response.add(wrap);
						}                
					}
			}
		}

		return response;
	}

	@AuraEnabled
	public static List<OpportunityAccWrapper> getOpportunitiesFromEventGC(String eventId, List<String> lstAccounts){
		List<OpportunityAccWrapper> response = new List<OpportunityAccWrapper>();
		Map<String, List<OpportunityWrapper>> mapOppWr = new Map <String, List<OpportunityWrapper>>();
		List<OpportunityWrapper> lstOppWr = new List<OpportunityWrapper>();
		if(eventId!=null){
			Event evt = [SELECT AV_Task__c, AccountId FROM Event WHERE Id = :eventId LIMIT 1];
			if(evt!=null && evt.AV_Task__c !=null ){
				Map<String,AV_CustomActivityOpportunity__c> vinculedOpp = new Map<String,AV_CustomActivityOpportunity__c>();                                                                    
				for(AV_CustomActivityOpportunity__c cao: [SELECT Id, AV_IsMain__c, AV_Opportunity__c FROM AV_CustomActivityOpportunity__c 
														WHERE AV_Task__c = :evt.AV_Task__c AND AV_Opportunity__r.Recordtype.DeveloperName IN :OppRct ORDER BY AV_IsMain__c DESC]){
					vinculedOpp.put(cao.AV_Opportunity__c, cao);
				}
	
				String currentUserId = UserInfo.getUserId();
				Map<Id,Opportunity> oppMap = new Map<Id,Opportunity>( [SELECT Id, name, CIBE_OpportunityTeam__c,  stageName, AV_PF__c, CloseDate, CIBE_AmountDivisa__c, CIBE_ProbabilidadExito__c, AV_Comentarios__c, AV_FechaVencimiento__c,
												AV_CommentLastModifiedDate__c, CIBE_Divisa__c, CIBE_Balance__c, CIBE_ComisionesDivisa__c, CIBE_ESG__c, Amount, AccountId, Account.Name,
												AV_ClienteConfidencial__c, AV_Entidad__c, CIBE_Margen__c, CIBE_Impacto_Balance_Cierre_Anio__c, OwnerId, AV_FechaProximoRecordatorio__c, CIBE_ImporteOtraEntidad__c, TOLABEL(CIBE_CerradoNegativo__c)
											FROM Opportunity 
											WHERE Id IN:vinculedOpp.KeySet() OR (
											AccountId IN:lstAccounts
											AND RecordType.DeveloperName IN :OppRct 
											AND AV_ToDelete__c = FALSE
											AND ((StageName IN ('Potencial', 'En curso', 'CIBE_Pendiente_Firma')
											AND CloseDate >= Today) OR (StageName = 'CIBE_Vencido'))
											AND CreatedDate >= LAST_N_MONTHS:12 ) 
											ORDER BY CloseDate ASC]);        
				
				List<OpportunityTeamMember> oppTeamMemberList = [SELECT OpportunityId FROM OpportunityTeamMember
																WHERE OpportunityId IN :oppMap.KeySet() and userID = :currentUserId ];
				Set<Id> oppTeamSet = new Set<Id>();
				for(OpportunityTeamMember oppTeam: oppTeamMemberList){
					oppTeamSet.add(oppTeam.OpportunityId);
				}
					
					OpportunityWrapper wrap;
					for(AV_CustomActivityOpportunity__c cao: vinculedOpp.Values()){
						if(oppMap.containsKey(cao.AV_Opportunity__c) && (oppMap.get(cao.AV_Opportunity__c).OwnerId == currentUserId ||
							oppTeamSet.contains(cao.AV_Opportunity__c))){
								wrap = parseWrapper(oppMap.get(cao.AV_Opportunity__c), true, cao);
							}else if(oppMap.containsKey(cao.AV_Opportunity__c)){
								wrap = parseWrapper(oppMap.get(cao.AV_Opportunity__c), false, cao);
							}
							if(wrap != null && !lstOppWr.contains(wrap) ){
								lstOppWr.add(wrap);
							}
					}

					for(Id oppId: oppMap.KeySet()){
						if(!vinculedOpp.containsKey(oppId)){
							if(oppMap.get(oppId).OwnerId == currentUserId || oppTeamSet.contains(oppId)){
								wrap = parseWrapper(oppMap.get(oppId), true, null);
							}else{
								wrap = parseWrapper(oppMap.get(oppId), false, null);
							}
						}
						if(wrap != null && !lstOppWr.contains(wrap) ){
								lstOppWr.add(wrap);
							}              
					} 
					//new
					for(OpportunityWrapper opp: lstOppWr){
						if(opp.nomCliente!=null){
							if(!mapOppWr.containsKey(opp.nomCliente)){
								mapOppWr.put(opp.nomCliente, new List<OpportunityWrapper>());
							}
							mapOppWr.get(opp.nomCliente).add(opp);
						}
					}
		
					for(String opp: mapOppWr.KeySet()){
						OpportunityAccWrapper wrapAccOpp = new OpportunityAccWrapper();
							wrapAccOpp.cliente = opp;
							wrapAccOpp.lstOppWr = mapOppWr.get(opp);
							response.add(wrapAccOpp);
					}
			}
		}

		return response;
	}

	@AuraEnabled(cacheable = true)
	public static Event getAccountId (String recordId){

		if(recordId !=null && !String.isBlank(recordId)){
			Event evt = [SELECT AccountId, AV_Task__c, ActivityDate from Event where Id =:recordId limit 1];
			return evt;
		}

		return null;        
	}

	@AuraEnabled
	public static void updateChecked (String recordId){
		if(!recordId.containsIgnoreCase('idProvisional')){
		Opportunity oppToUpdate = new Opportunity(Id = recordId, StageName = 'CIBE_Cerrado positivo', closeDate = date.today());
		update oppToUpdate;    
	}
	}


	@AuraEnabled
	public static void updateCanceled (String recordId){
		if(!recordId.containsIgnoreCase('idProvisional')){
		Opportunity oppToUpdate = new Opportunity(Id = recordId, StageName = 'Cerrado negativo', CIBE_CerradoNegativo__c = 'Anulada');
		update oppToUpdate;    
	}
	}

	@AuraEnabled
	public static void updateClosed (String recordId, String cerradoNegativo){
		if(!recordId.containsIgnoreCase('idProvisional')){
		Opportunity oppToUpdate = new Opportunity(Id = recordId, StageName = 'Cerrado negativo', CIBE_CerradoNegativo__c = cerradoNegativo, closeDate = date.today());

		update oppToUpdate;    
	}
	}

	@AuraEnabled
	public static void updatePendienteFirma (String recordId){
		if(!recordId.containsIgnoreCase('idProvisional')){
		Opportunity oppToUpdate = new Opportunity(Id = recordId, StageName = 'CIBE_Pendiente_Firma');
		update oppToUpdate;    
	}
	}

	@AuraEnabled
	public static void vinculateOpportunity (String recordId, String opportunityId){
		Boolean vincula = false;
		Map<Id, Event> mapOlds = null;
		if(!String.isBlank(recordId)){
			List<Event> evt = [SELECT AV_Task__c, AccountId, ActivityDate, RecordTypeId, Account.AV_Negocio__c FROM Event WHERE Id = :recordId LIMIT 1];
			if (evt != null && !evt.isEmpty())  {
				List<AV_CustomActivityOpportunity__c> vinculedOpportunities = [Select Id, AV_Task__c, AV_IsMain__c, AV_Opportunity__c, AV_Opportunity__r.StageName
																		FROM AV_CustomActivityOpportunity__c 
																		WHERE AV_Task__c = : evt[0].AV_Task__c];
				AV_CustomActivityOpportunity__c caoToInsert = new AV_CustomActivityOpportunity__c();                                                           
				if(vinculedOpportunities.isEmpty() && opportunityId !=null && !opportunityId.contains('idProvisional')){
					caoToInsert = new AV_CustomActivityOpportunity__c(AV_Task__c = evt[0].AV_Task__c, AV_Opportunity__c = opportunityId, AV_IsMain__c = true);
					insert caoToInsert;
					Opportunity opoBd = [Select Id, StageName FROM Opportunity WHERE Id =:opportunityId];
					if(opoBd !=null && opoBd.StageName == 'CIBE_Vencido'){
						opoBd.StageName ='En Curso';
						update opoBd;
					}
				}else if(opportunityId !=null && !opportunityId.contains('idProvisional')){
					caoToInsert = new AV_CustomActivityOpportunity__c(AV_Task__c = evt[0].AV_Task__c, AV_Opportunity__c = opportunityId);
					insert caoToInsert; 
					Opportunity opoBd = [Select Id, StageName FROM Opportunity WHERE Id =:opportunityId];
					if(opoBd !=null && opoBd.StageName == 'CIBE_Vencido'){
						opoBd.StageName ='En Curso';
						update opoBd;
					}
				}
				CIBE_EventTriggerHelper.updateNextMeetingDate(evt, mapOlds, null);
			}
		}
	}

	@AuraEnabled
	public static void disVinculateOpportunity (String recordId, String opportunityId){
		String oppId;
		Map<Id, Event> mapOlds = null;
		List<Event> evt = [SELECT AV_Task__c, AccountId, RecordTypeId, ActivityDate, Account.AV_Negocio__c FROM Event WHERE Id = :recordId LIMIT 1];
		if(!evt.isEmpty() && !String.Isblank(opportunityId) && !opportunityId.containsIgnoreCase('idProvisional')){
			List<AV_CustomActivityOpportunity__c> vinculedOpportunities = [Select Id, AV_Task__c, AV_IsMain__c, AV_Opportunity__c 
																			FROM AV_CustomActivityOpportunity__c 
																			WHERE AV_Task__c = :evt[0].AV_Task__c ORDER BY AV_IsMain__c DESC];
			if( !vinculedOpportunities.isEmpty()){
				AV_CustomActivityOpportunity__c caoToDelete ;
				AV_CustomActivityOpportunity__c caoToUpdateMain ;
				Boolean isMain = false;
				oppId = vinculedOpportunities[0] !=null && vinculedOpportunities[0].AV_Opportunity__c!=null ? vinculedOpportunities[0].AV_Opportunity__c :'';
				
				for(AV_CustomActivityOpportunity__c cao: vinculedOpportunities){
					if(cao.AV_Opportunity__c == opportunityId && cao.AV_IsMain__c){
						caoToDelete     = new AV_CustomActivityOpportunity__c(Id = cao.Id);
						isMain  = true;
					}else if(cao.AV_Opportunity__c == opportunityId && cao.AV_IsMain__c == false){
						caoToDelete     = new AV_CustomActivityOpportunity__c(Id = cao.Id);
					}else if(isMain){
						caoToUpdateMain = new AV_CustomActivityOpportunity__c(Id = cao.Id, AV_IsMain__c = true);
						break;
					}
				}
				if(caoToDelete != null){
					delete caoToDelete;
				}
				if(caoToUpdateMain != null){
					update caoToUpdateMain;
				}    
				CIBE_EventTriggerHelper.updateNextMeetingDate(evt, mapOlds, oppId);
			}
		}
	}


	@AuraEnabled
	public static void makePrincipal(String recordId, String opportunityId){
		Event evt = [SELECT AV_Task__c, AccountId FROM Event WHERE Id = :recordId LIMIT 1];
		List<AV_CustomActivityOpportunity__c> vinculedOpportunities = [Select Id, AV_Task__c, AV_IsMain__c, AV_Opportunity__c 
																	FROM AV_CustomActivityOpportunity__c 
																	WHERE AV_Task__c = : evt.AV_Task__c ORDER BY AV_IsMain__c DESC];
		List<AV_CustomActivityOpportunity__c> caoToUpdateList = new List<AV_CustomActivityOpportunity__c>();
		for(AV_CustomActivityOpportunity__c cao: vinculedOpportunities){
			if(cao.AV_Opportunity__c == opportunityId && cao.AV_IsMain__c  == false){
				caoToUpdateList.add(new AV_CustomActivityOpportunity__c(Id = cao.Id, AV_IsMain__c = true));
			}else if(cao.AV_IsMain__c == true){
				caoToUpdateList.add(new AV_CustomActivityOpportunity__c(Id = cao.Id, AV_IsMain__c = false));
			}
		}

		if(!caoToUpdateList.isEmpty()){
			update caoToUpdateList;
		}
	}

	
	public static OpportunityWrapper parseWrapper (Opportunity opp, Boolean isEditable, AV_CustomActivityOpportunity__c cao){
		OpportunityWrapper wrap = new OpportunityWrapper();
		wrap.id  						= opp.id;
		wrap.name 						= opp.name;
		wrap.status  					= opp.stageName;
		wrap.vencimiento 				= opp.AV_FechaVencimiento__c;
		wrap.ProductId					= opp.AV_PF__c;
		wrap.amount 					= opp.CIBE_AmountDivisa__c!= null ? Integer.valueOf(opp.CIBE_AmountDivisa__c.round(RoundingMode.HALF_UP)).format() : '';
		wrap.probability 				= opp.CIBE_ProbabilidadExito__c;
		wrap.comments 					= opp.AV_Comentarios__c;
		wrap.commentsLastModifieddate 	= opp.AV_CommentLastModifiedDate__c;
		wrap.divisa  					= opp.CIBE_Divisa__c;
		wrap.balanceImpact 				= opp.CIBE_Balance__c;
		wrap.comissionImpact 			= opp.CIBE_ComisionesDivisa__c;
		wrap.ESG 						= opp.CIBE_ESG__c;
		wrap.confidential 				= opp.AV_ClienteConfidencial__c;
		wrap.entity 					= opp.AV_Entidad__c;
		wrap.price                      = opp.CIBE_ImporteOtraEntidad__c;
		wrap.margin 					= opp.CIBE_Margen__c;
		wrap.isVinculated               = cao != null ? true : false;
		wrap.isPrincipal                = cao != null ? cao.AV_IsMain__c : false;
		wrap.customActOppId             = cao != null ? cao.Id : null;
		wrap.isEditable                 = isEditable;
		wrap.impactoBalance             = opp.CIBE_Impacto_Balance_Cierre_Anio__c;
		wrap.closeDate                  = opp.CloseDate;
		wrap.state                      = opp.CIBE_CerradoNegativo__c;
		wrap.owner                      = opp.OwnerId;
		wrap.proximaGestion             = opp.AV_FechaProximoRecordatorio__c;
		wrap.cliente                    = opp.AccountId;
		wrap.checked                    = false;
		wrap.closedLost                 = false;
		wrap.canceled                   = false;
		wrap.teamOpp                    = opp.CIBE_OpportunityTeam__c;
		wrap.nomCliente                 = opp.Account.Name;

		
		if(opp.StageName == 'CIBE_Cerrado positivo'){
			wrap.checked                    = true;
		}else if(opp.StageName == 'Cerrado negativo' && opp.CIBE_CerradoNegativo__c == 'Anulada'){
			wrap.canceled                   = true;
		}else if(opp.StageName == 'CIBE_Cerrado positivo'){
			wrap.closedLost                 = true;
		}
		return wrap;
	}
	public class OpportunityWrapper{
		@AuraEnabled public String id {get;set;}
		@AuraEnabled public String name {get;set;}
		@AuraEnabled public String status {get;set;}
		@AuraEnabled public Date vencimiento {get;set;}
		@AuraEnabled public String productId {get;set;}
		@AuraEnabled public String amount {get;set;}
		@AuraEnabled public String probability {get;set;}
		@AuraEnabled public String comments {get;set;}
		@AuraEnabled public DateTime commentsLastModifieddate {get;set;}
		@AuraEnabled public String divisa {get;set;}
		@AuraEnabled public Double balanceImpact {get;set;}
		@AuraEnabled public Double comissionImpact {get;set;}
		@AuraEnabled public Boolean esg {get;set;}
		@AuraEnabled public Boolean confidential {get;set;}
		@AuraEnabled public String entity {get;set;}
		@AuraEnabled public Date closeDate {get;set;}
		@AuraEnabled public Decimal price {get;set;}
		@AuraEnabled public Double margin {get;set;}
		@AuraEnabled public Boolean isVinculated {get;set;}
		@AuraEnabled public Boolean isPrincipal{get;set;}
		@AuraEnabled public Double impactoBalance {get;set;}
		@AuraEnabled public Boolean isEditable {get;set;}

		@AuraEnabled public Boolean checked {get;set;}
		@AuraEnabled public Boolean closedLost {get;set;}
		@AuraEnabled public Boolean canceled {get;set;}
		@AuraEnabled public String customActOppId {get;set;}
		@AuraEnabled public String cliente {get;set;}

		@AuraEnabled public Date proximaGestion {get;set;}
		@AuraEnabled public String state {get;set;}
		@AuraEnabled public String owner {get;set;}
		@AuraEnabled public String teamOpp {get;set;}
		@AuraEnabled public String nomCliente {get;set;}

	}

	public class OpportunityAccWrapper{
		@AuraEnabled public String cliente {get;set;}
		@AuraEnabled public List<OpportunityWrapper> lstOppWr {get;set;}

	}

}