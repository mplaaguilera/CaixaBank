/********************************************************************************************************************
 Name:	  AV_OppBlockEventTask_Controller
 Copyright © 2023  CaixaBank
--------------------------------------------------------------------------------------------------------------------
 Proposito: Gives support to av_OpportunityBlockEventTaskReport
---------------------------------------------------------------------------------------------------------------------
 Historial
 - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
 VERSION		USER_STORY			AUTHOR				DATE			Description
 1.0			US602653         	Sandra Gómez		03/10/2023		Init version.
 1.1            Fix subject         Sandra Gómez        12/02/2024      Change field AV_Product__c to AV_ProductName__c in object OppoWrap
 1.2			PPM100205278		 Luis Fernández		02/05/2024		Added new propoerty to retrieved opportunities: Product2.AV_NewReportActions__c. Added thisfield to the lookup retrieve methods
 *********************************************************************************************************************/
public with sharing class AV_OppBlockEventTask_Controller {

	public class OppoWrap implements Comparable{
		@AuraEnabled 
		public String Id;
		@AuraEnabled 
		public String Name;
		@AuraEnabled 
		public String Stage;
		@AuraEnabled 
		public Date Fecha;
		@AuraEnabled 
		public String Potencial;
		@AuraEnabled 
		public String Comentarios;
		@AuraEnabled 
		public String Resolucion;
		@AuraEnabled 
		public Decimal ImportePropio;
		@AuraEnabled 
		public Decimal Margen;
		@AuraEnabled 
		public Decimal ImporteOtraEntidad;    
		@AuraEnabled 
		public String OtraEntidad;
		@AuraEnabled 
		public String OtraEntidadNombre;
		@AuraEnabled
		public Decimal ImporteCuota;
		@AuraEnabled
		public String SubProductId;
		@AuraEnabled
		public String SubProductName;
		@AuraEnabled
		public String ProductoMain;
		@AuraEnabled
		public Decimal Propension;
		@AuraEnabled 
		public Date CloseDate;
		@AuraEnabled 
		public Boolean mainVinculed = false;
		@AuraEnabled
		public String HistoryComment = '';
		@AuraEnabled 
		public Boolean Prioritzed;
		@AuraEnabled
		public String ProductName;
		@AuraEnabled 
		public Boolean IsNewProduct;
		@AuraEnabled
		public String owneridopp;
	

		public OppoWrap(Opportunity oppo){
			this.Id = oppo.Id; 
			this.Name = oppo.Name;
			this.Stage = oppo.StageName; 
			  this.Fecha = oppo.AV_FechaProximoRecordatorio__c;
			  this.Potencial = oppo.AV_Potencial__c;
			  this.Comentarios = oppo.AV_Comentarios__c;
			  this.Resolucion = oppo.AV_Resolucion__c;
			  this.ImportePropio = oppo.AV_AmountEuro__c;
			  this.Margen = oppo.AV_MarginEuro__c;
			  this.ImporteOtraEntidad = oppo.Amount;
			  this.OtraEntidad = oppo.AV_Tenencia__c;
			  this.OtraEntidadNombre = oppo.AV_Entidad__c;
			  this.ImporteCuota = oppo.AV_Cuota__c;
			  this.SubProductId = oppo.AV_ByProduct__c;
			  this.SubProductName = oppo.AV_ByProduct__r.Name;
			  this.ProductoMain = oppo.AV_PF__c;
			  this.Propension = oppo.AV_Propensity__c;
			  this.CloseDate = oppo.CloseDate;
			  this.Prioritzed = oppo.AV_IncludeInPrioritizingCustomers__c;
			  this.ProductName = oppo.AV_ProductName__c;
			  this.IsNewProduct = oppo.AV_PF__r.AV_NewReportActions__c;
			  this.owneridopp = oppo.OwnerId; 
		}
		public Integer compareTo(Object compareTo) {
			OppoWrap compareToEmp = (OppoWrap) compareTo;
			 if (this.Propension > compareToEmp.Propension) {
				return 1;
			}
			if (this.Propension == compareToEmp.Propension) {
				return 0;
			}
			return -1;        
		}
	}

	public class SendOppLists {
		@AuraEnabled 
		public List<OppoWrap> listOppAccounts;
		@AuraEnabled 
		public List<OppoWrap> listOppRecord;
	}

	private static String formatDate(String lastDate){
		String dateParsed = lastDate.substring(0,10);
		String[] dateAtomized = dateParsed.split(AV_AppConstants.DASH);

		return dateAtomized[2]+'/'+dateAtomized[1]+'/'+dateAtomized[0];
	}

	/**
	* @description 			get Opportunities show
	* @param recordId 		Id of header task or event
	* @param accountId 		Id of account
	* @return 				list opps in account and in event/task
	*/
	@AuraEnabled
	public static SendOppLists retrieveAccountOpportunities(String accountId, String recordId){
		Set<String> retailRts = new Set<String>{ 
			AV_AppConstants.OPPINICIATIVA_RT,
			AV_AppConstants.OPPALERTACOM_RT,
			AV_AppConstants.OPPPROPUESTA_RT,
			AV_AppConstants.OPPSUGERENCIA_RT,
			AV_AppConstants.OPPLLAMADA_RT
		};
		Set<String> requiredStages = new Set<String> {
			AV_AppConstants.OPP_STATUS_POTENCIAL,
			AV_AppConstants.OPP_STATUS_ENGESTION,
			AV_AppConstants.OPP_STATUS_VENCIDO,
			AV_AppConstants.OPP_STATUS_NO_GESTIONADA

		};
		List<AV_CustomActivityOpportunity__c> listTaskOpp = [SELECT AV_Opportunity__c, AV_IsMain__c FROM AV_CustomActivityOpportunity__c WHERE AV_Task__c = :recordId AND AV_Opportunity__c != null AND AV_Task__c != null];
		Map<String, Boolean> stageMainOpp = new Map<String, Boolean>();
		List<String> listIdsOpps = new List<String>();
		if (listTaskOpp != null && !listTaskOpp.isEmpty()) {
			for(AV_CustomActivityOpportunity__c to : listTaskOpp) {
				listIdsOpps.add(to.AV_Opportunity__c);
				stageMainOpp.put(to.AV_Opportunity__c, to.AV_IsMain__c);
			}
		}
		List<Opportunity> associatedOppo = [SELECT Id,Name,StageName,AV_FechaProximoRecordatorio__c,AV_PF__r.AV_NewReportActions__c,AV_Potencial__c,AV_Comentarios__c,AV_Resolucion__c,AV_AmountEuro__c,AV_MarginEuro__c,Amount,AV_Tenencia__c,AV_Entidad__c,AV_Cuota__c,AV_ByProduct__c,AV_ByProduct__r.Name,AV_PF__c,AV_Product__c,AV_ProductName__c,AV_Propensity__c,CloseDate,AV_IncludeInPrioritizingCustomers__c,OwnerId FROM Opportunity WHERE AccountId = :accountId AND (RecordType.DeveloperName IN :retailRts AND StageName IN :requiredStages) ORDER BY AV_FechaProximoRecordatorio__c DESC NULLS LAST];
		Set<Id> retrievedOppos = new Set<Id>();

		for(Opportunity oppId : associatedOppo){
			retrievedOppos.add(oppId.Id);
		}
		
		List<AV_CommentsHistory__c> comentaryList = [SELECT AV_Opportunity__c,AV_NewComment__c,LastModifiedDate FROM AV_CommentsHistory__c WHERE AV_Opportunity__c IN :retrievedOppos AND AV_Opportunity__c != null ORDER BY AV_Opportunity__c, LastModifiedDate DESC];
		Map<Id,String> commentOppo = new Map<Id,String>();
		for(AV_CommentsHistory__c cmm : comentaryList){
			if(!commentOppo.keySet().contains(cmm.AV_Opportunity__c)  && !String.isBlank(cmm.AV_NewComment__c)/*&& !restrictedComments.contains(cmm.AV_Opportunity__c)*/){
				commentOppo.put(cmm.AV_Opportunity__c,formatDate( String.valueOf(cmm.LastModifiedDate))+'{|}'+cmm.AV_NewComment__c);
			}
		}
		List<OppoWrap> objToSend = new List<OppoWrap>();
		List<OppoWrap> objToSendTaskOpp = new List<OppoWrap>();
		Map<String,List<OppoWrap>> stageOppoMap = new Map<String,List<OppoWrap>>();
		Map<String,List<OppoWrap>> stageOppoMapTaskOpp = new Map<String,List<OppoWrap>>();
		for(Opportunity opp : associatedOppo){
			if (listIdsOpps.contains(opp.Id)) {
				OppoWrap nextOpp = new OppoWrap(opp);
				if(commentOppo.keySet().contains(opp.Id)){
					nextOpp.HistoryComment = commentOppo.get(opp.Id);
				}
				if(stageMainOpp.keySet().contains(opp.Id)){
					nextOpp.mainVinculed = stageMainOpp.get(opp.Id);
				}
				if(stageOppoMapTaskOpp.keySet().contains(opp.StageName)){
					stageOppoMapTaskOpp.get(opp.StageName).add(nextOpp);
				}else{
					stageOppoMapTaskOpp.put(opp.StageName,new List<OppoWrap>{nextOpp});
				}
			} else {
				OppoWrap nextOpp = new OppoWrap(opp);
				if(commentOppo.keySet().contains(opp.Id)){
					nextOpp.HistoryComment = commentOppo.get(opp.Id);
				}
				if(stageOppoMap.keySet().contains(opp.StageName)){
					stageOppoMap.get(opp.StageName).add(nextOpp);
				}else{
					stageOppoMap.put(opp.StageName,new List<OppoWrap>{ nextOpp});
				}
			}
		}
		if(stageOppoMap.get(AV_AppConstants.OPP_STATUS_POTENCIAL) != null){
			stageOppoMap.get(AV_AppConstants.OPP_STATUS_POTENCIAL).sort();
		}
		if(stageOppoMap.get(AV_AppConstants.OPP_STATUS_ENGESTION) != null){
			objToSend.addAll(stageOppoMap.get(AV_AppConstants.OPP_STATUS_ENGESTION));
		}
		if(stageOppoMap.get(AV_AppConstants.OPP_STATUS_POTENCIAL) != null){
			objToSend.addAll(stageOppoMap.get(AV_AppConstants.OPP_STATUS_POTENCIAL));
		}
		if(stageOppoMap.get(AV_AppConstants.OPP_STATUS_VENCIDO) != null){
			objToSend.addAll(stageOppoMap.get(AV_AppConstants.OPP_STATUS_VENCIDO));
		}
		if(stageOppoMap.get(AV_AppConstants.OPP_STATUS_NO_GESTIONADA) != null){
			objToSend.addAll(stageOppoMap.get(AV_AppConstants.OPP_STATUS_NO_GESTIONADA
		));
		}
		if(stageOppoMapTaskOpp.get(AV_AppConstants.OPP_STATUS_POTENCIAL) != null){
			stageOppoMapTaskOpp.get(AV_AppConstants.OPP_STATUS_POTENCIAL).sort();
		}
		if(stageOppoMapTaskOpp.get(AV_AppConstants.OPP_STATUS_ENGESTION) != null){
			objToSendTaskOpp.addAll(stageOppoMapTaskOpp.get(AV_AppConstants.OPP_STATUS_ENGESTION));
		}
		if(stageOppoMapTaskOpp.get(AV_AppConstants.OPP_STATUS_POTENCIAL) != null){
			objToSendTaskOpp.addAll(stageOppoMapTaskOpp.get(AV_AppConstants.OPP_STATUS_POTENCIAL));
		}
		if(stageOppoMapTaskOpp.get(AV_AppConstants.OPP_STATUS_VENCIDO) != null){
			objToSendTaskOpp.addAll(stageOppoMapTaskOpp.get(AV_AppConstants.OPP_STATUS_VENCIDO));
		}
		if(stageOppoMapTaskOpp.get(	AV_AppConstants.OPP_STATUS_NO_GESTIONADA) != null){
			objToSendTaskOpp.addAll(stageOppoMapTaskOpp.get(AV_AppConstants.OPP_STATUS_NO_GESTIONADA
		));
		}
		SendOppLists results = new SendOppLists();
		results.listOppAccounts = objToSend;
		results.listOppRecord = objToSendTaskOpp;
		return results;
	}

	/**
	* @description 			search products to insert
	* @param searchTerm 	filter search
	* @param selectedIds 	list of Ids products
	* @param accountId 		Id of account
	* @return 				list products of return query
	*/
	@AuraEnabled
	public static List<AV_LookupSearchResult> searchProduct(String searchTerm, List<String> selectedIds, String accountId) {
		Integer maxResults = 10;
		String methodName = 'searchProduct';
		searchTerm += '*';
		List<AV_LookupSearchResult> results = new List<AV_LookupSearchResult>();
		List<List<SObject>> searchResults = new List<List<SObject>>();
		Set<String> rts = new Set<String>{
			AV_AppConstants.OPPALERTACOM_RT, 
			AV_AppConstants.OPPPROPUESTA_RT,
			AV_AppConstants.OPPSUGERENCIA_RT, 
			AV_AppConstants.OPPINICIATIVA_RT,
			AV_AppConstants.OPPLLAMADA_RT
		};
		Set<String> openStatusInitiativeRT = new Set<String>{
			AV_AppConstants.OPP_STATUS_POTENCIAL, 
			AV_AppConstants.OPP_STATUS_ENGESTION,
			AV_AppConstants.OPP_STATUS_NOAPTO,
			AV_AppConstants.OPP_STATUS_VENCIDO,
			AV_AppConstants.OPP_STATUS_NO_GESTIONADA
		};
		List<String> listProductIds = new List<String>();
		List<Opportunity> listOpp = [SELECT AV_PF__c FROM Opportunity WHERE AccountId = :accountId AND (StageName  IN :openStatusInitiativeRT AND RecordType.DeveloperName IN :rts)]; 
		if (listOpp != null && !listOpp.isEmpty()) {
			for (Opportunity o : listOpp) {
				if(o.AV_PF__c != null) {
					listProductIds.add(o.AV_PF__c);
				}
			}
		}
		if(selectedIds != null && !selectedIds.isEmpty()){
			if (listProductIds != null && !listProductIds.isEmpty()) {
				searchResults = [
					FIND :searchTerm
					IN ALL FIELDS
					RETURNING
						Product2(Id, Name, AV_ExternalID__c ,AV_NewReportActions__c  WHERE Id NOT IN :selectedIds and Id NOT IN :listProductIds and RecordType.DeveloperName = 'AV_PF' and AV_Nivel__c=null and AV_ExternalID__c!=null and AV_Visible__c = true)
					LIMIT :maxResults
				];
			} else {
				searchResults = [
					FIND :searchTerm
					IN ALL FIELDS
					RETURNING
						Product2(Id, Name, AV_ExternalID__c ,AV_NewReportActions__c  WHERE Id NOT IN :selectedIds and RecordType.DeveloperName = 'AV_PF' and AV_Nivel__c=null and AV_ExternalID__c!=null and AV_Visible__c = true)
					LIMIT :maxResults
				];
			}
		} else{
			if (listProductIds != null && !listProductIds.isEmpty()) {
				searchResults = [
					FIND :searchTerm
					IN ALL FIELDS
					RETURNING
						Product2(Id, Name, AV_ExternalID__c ,AV_NewReportActions__c  WHERE Id NOT IN :listProductIds and RecordType.DeveloperName = 'AV_PF' and AV_Nivel__c=null and AV_ExternalID__c!=null and AV_Visible__c = true)
					LIMIT :maxResults
				];
			} else {
				searchResults = [
					FIND :searchTerm
					IN ALL FIELDS
					RETURNING
						Product2(Id, Name, AV_ExternalID__c,AV_NewReportActions__c   WHERE RecordType.DeveloperName = 'AV_PF' and AV_Nivel__c=null and AV_ExternalID__c!=null and AV_Visible__c = true)
					LIMIT :maxResults
				];
			}
		}
		String productIcon = 'standard:product';
		Product2[] listProduct = (List<Product2>) searchResults[0];
		for (Product2 p : listProduct) {
			results.add(
				new AV_LookupSearchResult(
					p.Id,'Product2',productIcon,p.Name,'Codigo • ' + p.AV_ExternalID__c,p.AV_NewReportActions__c
				)
			);
		}
		results.sort();
		return results;
	}
}