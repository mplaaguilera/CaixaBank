/**********************************************************************************************************************
@description
Name:	  AV_OppSearch_Controller
Copyright © 2020  CaixaBank
------------------------------------------------------------------------------------------------
Proposito: Apex class controller to LWC AV_OppSearch
------------------------------------------------------------------------------------------------
Historial
---------------------
VERSION		USER_STORY	        AUTHOR		   		DATE				Description
1.0			US767515		    Sandra Gómez	    28/11/2023		    Init version
1.1			Fase II				Sandra Gómez	    16/01/2024		    Add start Opportunity and client
1.2		 	Revisar queries 	Ángel Medina		12/02/2024			Modify query from sosl to soql
1.3         US839366            Oscar Moreno        28/02/2024          change method getOpportunities to add AND ((AV_NextEventDate__c > TODAY) OR (AV_NextEventDate__c < TODAY)) condition in query when 'destacadas' is checked
1.4			US866737			Sandra Gómez		19/04/2024			Add method getTypesOptions and add new filter tipo
1.5			US814957			Sandra Gómez		08/05/2024			Change method searchOffice to add gestormultiofi
1.6			Fix Label Gestión	Luis Fernández		06/06/06			Addes ternary in getOpportunities method in order to show the richt label for 'En gestión/insistir' stage opportunities
1.7			PPM100340509 		Ángel Medina		14/06/2024			Modify query destacadas method getOpportunities to add RT AV_Propuesta and field AV_PriorityOpportunity__c
1.8			PPM100408652		Luis Fernández		15/06/2024			Added new method enhancedGetUserInfo.
1.9			PPM100492394		Ángel Medina		19/09/2024			Modify method getEmployee and getOpportunities to add multigestor
***********************************************************************************************************************/
public with sharing class AV_OppSearch_Controller {

	/**
	* @description Object to options employee in filters more
	*/
	public class OptionsEmployee implements Comparable  {
		@AuraEnabled
		public String value;
		@AuraEnabled
		public String label;
		public OptionsEmployee(String value, String label){
			this.label = label;
			this.value = value;		
		}
		public Integer compareTo(Object compareTo) {
			OptionsEmployee compareToEmp = (OptionsEmployee)compareTo;
				if (this.label > compareToEmp.label) {
				return 1;
			}
			if (this.label == compareToEmp.label) {
				return 0;
			}
			return -1;        
		}
	}

	/**
	* @description Object to filters of table and charts
	*/
	public class DataFilter {
		@AuraEnabled
		public Boolean preconcedido;
		@AuraEnabled
		public Boolean myBox;
		@AuraEnabled
		public Boolean targetAuto;
		@AuraEnabled
		public String orderBy;
		@AuraEnabled
		public String orderingCriterion;
		@AuraEnabled
		public String limite;
		@AuraEnabled
		public String type;
	}

	/**
	* @description Object to Opp View in table and charts
	*/
	public class OppSearch {
		@AuraEnabled
		public String destacada;
		@AuraEnabled
		public String destacadaIcon;
		@AuraEnabled
		public String iconClass;
		@AuraEnabled
		public String cliente;
		@AuraEnabled
		public String clienteId;
		@AuraEnabled
		public String origen;
		@AuraEnabled
		public String nombre;
		@AuraEnabled
		public String oppId;
		@AuraEnabled
		public String producto;
		@AuraEnabled
		public String productoId;
		@AuraEnabled
		public String productoIdSales;
		@AuraEnabled
		public String estado;
		@AuraEnabled
		public String fechaPro;
		@AuraEnabled
		public String fechaCie;
		@AuraEnabled
		public String negocio;
		@AuraEnabled
		public String negocioView;
		@AuraEnabled
		public Decimal edad;
		@AuraEnabled
		public String ahorroEInversion;
		@AuraEnabled
		public String financiacion;
		@AuraEnabled
		public String ingresos;
		@AuraEnabled
		public String preconcedido;
		@AuraEnabled
		public String mybox;
		@AuraEnabled
		public String targetAuto;
		@AuraEnabled
		public String tipo;
		@AuraEnabled
		public String startOppCSS;
		@AuraEnabled
		public String startOpp;
		@AuraEnabled
		public String startClientCSS;
		@AuraEnabled
		public String startClient;
		@AuraEnabled
		public String comentario;
		@AuraEnabled
		public String comentarioMore;
		@AuraEnabled
		public Boolean isComentarioMore;
		@AuraEnabled
		public String channel;
		@AuraEnabled
		public String lastContact;
		@AuraEnabled
		public String attentionModel;
		@AuraEnabled
		public String attentionModelCSS; 
		@AuraEnabled 
		public Boolean priorityOpportunity;
		@AuraEnabled
		public String gestor;
	}

	/**
	* @description Object to return opportunities
	*/
	public class DataReturn {
		@AuraEnabled
		public List<OppSearch> listOpp;
		@AuraEnabled
		public List<OppSearch> listOppGra;
		@AuraEnabled
		public List<OppSearch> listOppGraExp;
		@AuraEnabled
		public List<OppSearch> listOppGraPro;
		@AuraEnabled
		public List<OppSearch> listOppGraName;
		@AuraEnabled
		public List<OppSearch> listOppSearch;
		@AuraEnabled
		public Integer totalSize;
		@AuraEnabled
		public Integer totalSizeClient;
	}

	/**
	* @description Object to More filters
	*/
	public class DataMoreFilters {
		@AuraEnabled
		public String oficina;
		@AuraEnabled
		public List<MultiData> employee;
		@AuraEnabled
		public String origen;
		@AuraEnabled
		public List<MultiData> stage;
		@AuraEnabled
		public String expSale;
		@AuraEnabled
		public Date dateProFrom;
		@AuraEnabled
		public Date dateProUntil;
		@AuraEnabled
		public Date dateVenFrom;
		@AuraEnabled
		public Date dateVenUntil;
		@AuraEnabled
		public Date dateModFrom;
		@AuraEnabled
		public Date dateModUntil;
		@AuraEnabled
		public List<MultiData> segmento;
	}

	/**
	* @description Object to More filters employee, stage and segmento
	*/
	public class MultiData {
		@AuraEnabled
		public String label;
		@AuraEnabled
		public String id;
		@AuraEnabled
		public String bucleId;
	}

	/**
	* @description      	Get Opportunities to view in all search
	* @param datosString	filters of button aplicar
	* @param destacadas		filters of opportunities destacadas
	* @param filterExpe		filters of chart experience
	* @return          	 	List of Opportunities
	*/
	@AuraEnabled
	public static DataReturn getOpportunities(String datosString, Boolean destacadas, String filterExpeString, String productName, List<String> listProducts, List<String> filterName, String page, String moreFiltersString){
		String methodName = 'getOpportunities';
		Integer total = 0;
		Integer totalClient = 0;
		List<OppSearch> listOppSearch = new List<OppSearch>();
		List<OppSearch> listOppSearchGraExp = new List<OppSearch>();
		List<OppSearch> listOppSearchGraPro = new List<OppSearch>();
		List<OppSearch> listOppSearchGraName = new List<OppSearch>();
		List<OppSearch> listSearchAll= new List<OppSearch>();
		List<String> stageFilter = new List<String>();
		List<String> segmentoFilter = new List<String>();
		List<ProductNegocio> filterExpe = new List<ProductNegocio>();
		DataFilter datos = new DataFilter();
		DataMoreFilters moreFilters = new DataMoreFilters();
		Set<String> setRTPotencialDes = new Set<String>{AV_AppConstants.OPPALERTACOM_RT,AV_AppConstants.OPPLLAMADA_RT};
		Set<String> setRTPotencialPrior = new Set<String>{AV_AppConstants.OPPALERTACOM_RT,AV_AppConstants.OPPLLAMADA_RT, AV_AppConstants.OPPPROPUESTA_RT};
		String headerQuery = 'SELECT Id, Account.AV_IndicadorDeCumplimiento__c, Account.AV_LastContactDate__c, TOLABEL(AV_Channel__c), AV_Comentarios__c, AV_NextEventDate__c,AV_Potencial__c, LastModifiedDate, Account.AV_IndicadoresClientes__c, AV_PotencialityOpportunity__c, Account.AV_ClientPotencialityFormula__c, AccountId, AV_PF__c, RecordType.DeveloperName, Account.Name, AV_Type__c, Account.AV_FormulaNegocio__c, RecordType.Name, Name, AV_PF__r.Name, Account.AV_Priority__c, StageName, AV_FechaProximoRecordatorio__c, CloseDate, Account.AV_Negocio__c, Account.AV_Age__c, Account.AV_AhorroEInversion__c, Account.AV_Financiacion__c, Account.AV_Ingresos__c, Account.AV_Preconceived__c, TOLABEL(Account.AV_MyBox__c), TOLABEL(Account.AV_TargetAuto__c), Account.AV_IsPreconceived__c, AV_Propensity__c, AV_PF__r.AV_ExternalId__c, AV_FechaAlta__c,OwnerId, Owner.Name, AV_PriorityOpportunity__c';
		String headerCountQuery = 'SELECT COUNT(Id)';
		String countQuery;
		String countQueryClient;
		String avQuery = '';
		String avQuery2 = '';
		List<String> employeeFilter = new List<String>();
		List<User> currentUser;
		String multigeUser;
		String  idGcf = (String) [SELECT Id FROM User WHERE Alias = :AV_AppConstants.AV_ALIAS_AVTF9 LIMIT 1].Id;
		if (destacadas != null && destacadas) {
			avQuery = avQuery+' FROM Opportunity WHERE ((AV_FechaAlta__c <= TODAY AND AV_FechaAlta__c >= LAST_N_DAYS:7 AND StageName = :potencial AND RecordType.DeveloperName in :setRTPotencialDes) OR(AV_FechaProximoRecordatorio__c <= TODAY AND AV_FechaProximoRecordatorio__c >= LAST_N_DAYS:7 AND StageName = :gestion AND RecordType.DeveloperName in :setRTGestion ) OR(StageName = :potencial AND RecordType.DeveloperName in :setRTPotencialPrior AND AV_PriorityOpportunity__c = true))  AND (AV_NextEventDate__c != TODAY)';
		} else {
			avQuery =' FROM Opportunity WHERE ((RecordType.DeveloperName in :setRTPotencial AND StageName = :potencial) OR (RecordType.DeveloperName in :setRTGestion AND StageName = :gestion))';
		}
		if (moreFiltersString != null) {
			moreFilters = (DataMoreFilters)Json.deserialize(moreFiltersString,DataMoreFilters.class);
		}
		if(moreFilters != null) {
			if (moreFilters.origen != null && moreFilters.origen != 'all') {
				avQuery = avQuery+' AND RecordType.DeveloperName = \''+moreFilters.origen+'\'';
			}
			if (moreFilters.expSale != null && moreFilters.expSale != '') {
				avQuery = avQuery+' AND AV_Potencial__c = \''+moreFilters.expSale+'\'';
			}
			if (moreFilters.dateProFrom != null) {
				Datetime dt = (DateTime) moreFilters.dateProFrom;
				avQuery = avQuery+' AND AV_FechaProximoRecordatorio__c >= '+dt.format('yyyy-MM-dd');
			}
			if (moreFilters.dateProUntil != null) {
				Datetime dt = (DateTime) moreFilters.dateProUntil;
				avQuery = avQuery+' AND AV_FechaProximoRecordatorio__c <= '+dt.format('yyyy-MM-dd');
			}
			if (moreFilters.dateVenFrom != null) {
				Datetime dt = (DateTime) moreFilters.dateVenFrom;
				avQuery = avQuery+' AND CloseDate >= '+dt.format('yyyy-MM-dd');
			}
			if (moreFilters.dateVenUntil != null) {
				Datetime dt = (DateTime) moreFilters.dateVenUntil;
				avQuery = avQuery+' AND CloseDate <= '+dt.format('yyyy-MM-dd');
			}
			if (moreFilters.dateModFrom != null) {
				Datetime dt = (DateTime) moreFilters.dateModFrom;
				avQuery = avQuery+' AND LastModifiedDate >= '+dt.format('yyyy-MM-dd')+'T00:00:00.000+0000';
			}
			if (moreFilters.dateModUntil != null) {
				Datetime dt = (DateTime) moreFilters.dateModUntil;
				avQuery = avQuery+' AND LastModifiedDate <= '+dt.format('yyyy-MM-dd')+'T23:59:59.000+0000';
			}
			if (moreFilters.employee != null && moreFilters.oficina != null && moreFilters.employee.size() > 0) {
				Boolean addMultige = false;
				for (MultiData md : moreFilters.employee) {
					if(!md.label.equals(AV_AppConstants.MULTIGENAME)){
						employeeFilter.add(md.id);
					}else{
						addMultige = true;
					}
				}
				if(addMultige){
					currentUser = [SELECT Id,AV_NumeroOficinaEmpresa__c,AV_Pool__c FROM User WHERE Id = :UserInfo.getUserId()];
					if(currentUser != null){
						multigeUser = AV_PoolEvents_Controller.getCurrentDT(currentUser[0].AV_NumeroOficinaEmpresa__c);
						if(multigeUser != null){
							employeeFilter.add(multigeUser);
						}
					}
				}

				List<String> listOffice = new List<String>{moreFilters.oficina};
				if (moreFilters.oficina.contains(',')) {
					listOffice = moreFilters.oficina.split(',');
				} else {
					listOffice.add(moreFilters.oficina);
				}
				if (idGcf.equalsIgnoreCase(employeeFilter[0]) && employeeFilter.size()==1) {
					avQuery = avQuery + ' AND OwnerId = \''+idGcf+'\' AND AV_Center__c IN '+AV_AppUtilities.listToStringIn(listOffice);
					avQuery2 = avQuery2 + ' AND OwnerId = \''+idGcf+'\' AND AV_Center__c IN '+AV_AppUtilities.listToStringIn(listOffice);
				} else if (employeeFilter[0].contains(idGcf) && employeeFilter.size()==1) {
					avQuery = avQuery + ' AND AV_Center__c IN '+AV_AppUtilities.listToStringIn(listOffice);
					avQuery2 = avQuery2 + ' AND AV_Center__c IN '+AV_AppUtilities.listToStringIn(listOffice);
				} else if (employeeFilter.contains(idGcf)) {
					avQuery = avQuery + ' AND OwnerId IN '+AV_AppUtilities.arrayToStringIn(employeeFilter)+' AND AV_Center__c IN '+AV_AppUtilities.listToStringIn(listOffice);
					avQuery2 = avQuery2 + ' AND OwnerId IN '+AV_AppUtilities.arrayToStringIn(employeeFilter)+' AND AV_Center__c IN '+AV_AppUtilities.listToStringIn(listOffice);
				} else {
					avQuery = avQuery + ' AND OwnerId IN '+AV_AppUtilities.arrayToStringIn(employeeFilter)+' AND AV_Center__c IN '+AV_AppUtilities.listToStringIn(listOffice);
					avQuery2 = avQuery2 + ' AND OwnerId IN '+AV_AppUtilities.arrayToStringIn(employeeFilter)+' AND AV_Center__c IN '+AV_AppUtilities.listToStringIn(listOffice);
				}
			}
			if (moreFilters.stage != null && moreFilters.stage.size() > 0) {
				for (MultiData md : moreFilters.stage) {
					stageFilter.add(md.id);
				}
				avQuery = avQuery + ' AND StageName IN '+AV_AppUtilities.arrayToStringIn(stageFilter);
			}
			if (moreFilters.segmento != null && moreFilters.segmento.size() > 0) {
				for (MultiData md : moreFilters.segmento) {
					segmentoFilter.add(md.id);
				}
				avQuery = avQuery + ' AND Account.AV_IndicadoresClientes__c INCLUDES '+AV_AppUtilities.arrayToStringIn(segmentoFilter);
			}
		}
		String searchQuery = headerQuery +' FROM Opportunity WHERE ((RecordType.DeveloperName in :setRTPotencial AND StageName = :potencial) OR (RecordType.DeveloperName in :setRTGestion AND StageName = :gestion)) '+avQuery2;
		if (datosString != null) {
			datos = (DataFilter)Json.deserialize(datosString,DataFilter.class);
		}
		if(datos != null) {
			if (datos.type != null) {
				avQuery = avQuery+' AND AV_Type__c = \''+datos.type+'\'';
			}
			if (datos.preconcedido != null && datos.preconcedido) {
				avQuery = avQuery+' AND Account.AV_IsPreconceived__c = true';
			}
			if (datos.myBox != null && datos.myBox) {
				avQuery = avQuery+' AND Account.AV_MyBox__c = \'S\'';
			}
			if (datos.targetAuto != null && datos.targetAuto) {
				avQuery = avQuery+' AND Account.AV_TargetAuto__c = \'S\'';
			}
		}
		
		if (filterName != null && filterName.size() > 0) {
			avQuery = avQuery+' AND Name in '+AV_AppUtilities.listToStringIn(filterName);
		}
		if (productName != null) {
			avQuery = avQuery+' AND AV_PF__r.Name = \''+productName+'\'';
		} else if (listProducts != null && listProducts.size() > 0) {
			avQuery = avQuery+' AND AV_PF__r.AV_ExternalId__c in '+AV_AppUtilities.listToStringIn(listProducts);
		}
		Map<String,List<String>> mapNegocioProducts = new Map<String,List<String>>();
		List<String> listNulls = new List<String>();
		if (filterExpeString != null) {
			filterExpe = (List<ProductNegocio>)Json.deserialize(filterExpeString,List<ProductNegocio>.class);
			if (filterExpe != null && !filterExpe.isEmpty()) {
				for (ProductNegocio pn : filterExpe) {
					if (mapNegocioProducts.containsKey(pn.negocio) && pn.negocio != null && pn.product != null) {
						mapNegocioProducts.get(pn.negocio).add(pn.product);
					} else if (pn.negocio != null && pn.product != null) {
						mapNegocioProducts.put(pn.negocio, new List<String> {pn.product});
					} else if ((pn.negocio == null || pn.product == null) || (pn.negocio == null && pn.product == null)) {
						listNulls.add(pn.product);
					}
				}
				if (mapNegocioProducts != null && !mapNegocioProducts.isEmpty()) {
					avQuery = avQuery+' AND (';
					if (listNulls != null && !listNulls.isEmpty()) {
						avQuery = avQuery+' Id in '+AV_AppUtilities.listToStringIn(listNulls)+' OR';
					}
					Integer cont = 1;
					Integer max = mapNegocioProducts.keySet().size();
					for (String negocio : mapNegocioProducts.keySet()) {
						if(cont == max) {
							avQuery = avQuery+' (Account.AV_Negocio__c INCLUDES  (\''+negocio+'\') AND AV_PF__c in '+AV_AppUtilities.listToStringIn(mapNegocioProducts.get(negocio))+'))';
						} else {
							avQuery = avQuery+' (Account.AV_Negocio__c INCLUDES  (\''+negocio+'\') AND AV_PF__c in '+AV_AppUtilities.listToStringIn(mapNegocioProducts.get(negocio))+') OR';
						}
						cont++;
					}
				}
			} 
		}
		countQuery = headerCountQuery+' '+avQuery;
		countQueryClient = headerCountQuery+' '+avQuery+' GROUP BY AccountId';
		if(datos != null) {
			if (datos.orderBy != null && datos.orderBy != '' && datos.orderBy != 'O' && datos.orderBy != 'C' && datos.orderingCriterion != null) {
				if (filterExpe != null && !filterExpe.isEmpty() && productName == null && (listProducts != null && listProducts.size() == 0) && (filterName != null && filterName.size() == 0)) {
					avQuery = avQuery+' ORDER BY '+datos.orderBy+' '+datos.orderingCriterion+' NULLS LAST, Account.AV_PotencialityCLientValue__c DESC NULLS LAST';
				} else {
					avQuery = avQuery+' ORDER BY '+datos.orderBy+' '+datos.orderingCriterion+' NULLS LAST, AV_PotencialityOpportunityValue__c DESC NULLS LAST, Account.AV_PotencialityCLientValue__c DESC NULLS LAST';
				}
			} else {
				if (datos.orderBy != 'O' && (datos.orderBy == 'C' || ((filterExpe != null && !filterExpe.isEmpty()) && productName == null && (listProducts != null && listProducts.size() == 0) && (filterName != null && filterName.size() == 0)))) {
					avQuery = avQuery+' ORDER BY Account.AV_PotencialityCLientValue__c DESC NULLS LAST';
				} else {
					avQuery = avQuery+' ORDER BY AV_PotencialityOpportunityValue__c DESC NULLS LAST, Account.AV_PotencialityCLientValue__c DESC NULLS LAST';
				}
			}
		} else {
			avQuery = avQuery+' ORDER BY Account.AV_Priority__c DESC NULLS LAST, Account.AV_NumPerso__c  ASC NULLS LAST LIMIT 50';
		}
		AV_LogDebug.printLogDebug(methodName, '-----> Query to execute: ' + avQuery);
		if (employeeFilter.size() == 1 && !idGcf.equalsIgnoreCase(employeeFilter[0])
			|| (currentUser != null && !currentUser.isEmpty() && currentUser[0].AV_Pool__c && multigeUser != null && employeeFilter.size() == 2 && !employeeFilter.contains(idGcf) && employeeFilter.contains(currentUser[0].Id) && employeeFilter.contains(multigeUser) )) {
		
			totalClient = '1'.equals(page) ? getCapsulateCountQueryClient(countQueryClient) : -1;
		} else {
			totalClient = -1;
		}
		total = '1'.equals(page) ? getCapsulateCountQuery(countQuery) : -1;
		avQuery = headerQuery + avQuery;
		List<Opportunity> listOpp = capsulateQuery(avQuery);
		List<Opportunity> listSearch = capsulateQuery(searchQuery);
		if (listSearch != null && !listSearch.isEmpty()) {
			for (Opportunity opp : listSearch) {
				OppSearch oppSearch = new OppSearch();
				oppSearch.destacada = '';
				if (((System.today().addDays(-7) >= opp.AV_FechaProximoRecordatorio__c && System.today() <= opp.AV_FechaProximoRecordatorio__c && opp.StageName == AV_AppConstants.OPP_STATUS_ENGESTION) || (System.today().addDays(-7) >= opp.AV_FechaAlta__c && System.today() <= opp.AV_FechaAlta__c && opp.StageName == AV_AppConstants.OPP_STATUS_POTENCIAL && setRTPotencialDes.contains(opp.RecordType.DeveloperName)) || (opp.AV_PriorityOpportunity__c == true && setRTPotencialPrior.contains(opp.RecordType.DeveloperName)&& opp.StageName == AV_AppConstants.OPP_STATUS_POTENCIAL))) {
					oppSearch.destacadaIcon = 'action:priority';
					oppSearch.iconClass ='slds-icon-custom-custom16 slds-icon_container slds-var-p-top_xx-small slds-var-p-bottom_xx-small';
				} else {
					oppSearch.iconClass ='';
					oppSearch.destacadaIcon = '';
				}
				oppSearch.cliente = opp.Account.Name;
				oppSearch.origen = opp.RecordType.Name;
				oppSearch.clienteId = '/'+opp.AccountId;
				oppSearch.nombre = opp.Name;
				oppSearch.oppId = '/'+opp.Id;
				oppSearch.producto = opp.AV_PF__r.Name;
				oppSearch.productoId = opp.AV_PF__r.AV_ExternalId__c;
				oppSearch.productoIdSales = opp.AV_PF__c;
				oppSearch.estado = (opp.StageName.equals(AV_AppConstants.OPP_STATUS_ENGESTION)) ? 'En Gestión' : opp.StageName;
				oppSearch.priorityOpportunity = opp.AV_PriorityOpportunity__c;
				if (opp.Account.AV_IndicadorDeCumplimiento__c != null) {
					oppSearch.attentionModel = opp.Account.AV_IndicadorDeCumplimiento__c.substringAfterLast('>');
					oppSearch.attentionModelCSS =  'background-image: url(/resource'+opp.Account.AV_IndicadorDeCumplimiento__c.substringAfter('/resource').substringBefore('"')+'); background-repeat: no-repeat;background-size: auto; background-position: left;';
				} else {
					oppSearch.attentionModel = '';
					oppSearch.attentionModelCSS = '';
				}
				if(opp.Account.AV_LastContactDate__c != null) {
					oppSearch.lastContact = opp.Account.AV_LastContactDate__c.format();
				} else {
					oppSearch.lastContact = '';
				}
				oppSearch.channel = opp.AV_Channel__c;
				if (opp.AV_Comentarios__c != null && opp.AV_Comentarios__c.length() > 250) {
					oppSearch.comentario = opp.AV_Comentarios__c.substring(0,250)+'...';
					oppSearch.comentarioMore = opp.AV_Comentarios__c;
					oppSearch.isComentarioMore = true;
				}else {
					oppSearch.comentario = opp.AV_Comentarios__c;
					oppSearch.comentarioMore = opp.AV_Comentarios__c;
					oppSearch.isComentarioMore = false;
				}
				if (opp.Account.AV_ClientPotencialityFormula__c != null && opp.Account.AV_ClientPotencialityFormula__c.contains('AV_FancyStar5')) {
					oppSearch.startClientCSS = 'background-image: url(/resource/AV_FancyStar5); background-repeat: no-repeat;background-size: auto; background-position: left;';
				} else if (opp.Account.AV_ClientPotencialityFormula__c != null && opp.Account.AV_ClientPotencialityFormula__c.contains('AV_FancyStar4')) {
					oppSearch.startClientCSS = 'background-image: url(/resource/AV_FancyStar4); background-repeat: no-repeat;background-size: auto; background-position: left;';
				} else if (opp.Account.AV_ClientPotencialityFormula__c != null && opp.Account.AV_ClientPotencialityFormula__c.contains('AV_FancyStar3')) {
					oppSearch.startClientCSS = 'background-image: url(/resource/AV_FancyStar3); background-repeat: no-repeat;background-size: auto; background-position: left;';
				}
				oppSearch.startClient='';
				if (opp.AV_PotencialityOpportunity__c != null && opp.AV_PotencialityOpportunity__c.contains('AV_FancyStar5')) {
					oppSearch.startOppCSS = 'background-image: url(/resource/AV_FancyStar5); background-repeat: no-repeat;background-size: auto; background-position: left;';
				} else if (opp.AV_PotencialityOpportunity__c != null && opp.AV_PotencialityOpportunity__c.contains('AV_FancyStar4')) {
					oppSearch.startOppCSS = 'background-image: url(/resource/AV_FancyStar4); background-repeat: no-repeat;background-size: auto; background-position: left;';
				} else if (opp.AV_PotencialityOpportunity__c != null && opp.AV_PotencialityOpportunity__c.contains('AV_FancyStar3')) {
					oppSearch.startOppCSS = 'background-image: url(/resource/AV_FancyStar3); background-repeat: no-repeat;background-size: auto; background-position: left;';
				}
				oppSearch.startOpp='';
				if(opp.AV_FechaProximoRecordatorio__c != null) {
					oppSearch.fechaPro = opp.AV_FechaProximoRecordatorio__c.format();
				} else {
					oppSearch.fechaPro = '';
				}
				if(opp.CloseDate != null) {
					oppSearch.fechaCie = opp.CloseDate.format();
				} else {
					oppSearch.fechaCie = '';
				}
				if(opp.OwnerId != null){
					oppSearch.gestor = opp.Owner.Name;
				}else{
					oppSearch.gestor ='';
				}
				oppSearch.negocio = opp.Account.AV_Negocio__c;
				if(opp.Account.AV_FormulaNegocio__c != null && opp.Account.AV_FormulaNegocio__c.contains('<br>')) {
					if(opp.Account.AV_FormulaNegocio__c.replaceAll('<br>', ';').contains(';')) {
						String nego = opp.Account.AV_FormulaNegocio__c.replaceAll('<br>', ';');
						oppSearch.negocioView = nego.substring(0,nego.length()-1);
					} else {
						oppSearch.negocioView = opp.Account.AV_FormulaNegocio__c.replaceAll('<br>', ';');
					}
				} else {
					oppSearch.negocioView = opp.Account.AV_FormulaNegocio__c;
				}
				oppSearch.edad = opp.Account.AV_Age__c;
				if(opp.Account.AV_AhorroEInversion__c != null) {
					oppSearch.ahorroEInversion = opp.Account.AV_AhorroEInversion__c.setScale(0).format()+' €';
				} else {
					oppSearch.ahorroEInversion = '0 €';
				}
				if(opp.Account.AV_Financiacion__c != null) {
					oppSearch.financiacion = opp.Account.AV_Financiacion__c.setScale(0).format()+' €';
				} else {
					oppSearch.financiacion = '0 €';
				}
				if(opp.Account.AV_Ingresos__c != null) {
					oppSearch.ingresos = opp.Account.AV_Ingresos__c.setScale(0).format()+' €';
				} else {
					oppSearch.ingresos = '0 €';
				}
				if(opp.Account.AV_Preconceived__c != null) {
					oppSearch.preconcedido = opp.Account.AV_Preconceived__c.setScale(0).format()+' €';
				} else {
					oppSearch.preconcedido = '0 €';
				}
				oppSearch.mybox = opp.Account.AV_MyBox__c;
				oppSearch.targetAuto = opp.Account.AV_TargetAuto__c;
				oppSearch.tipo = opp.AV_Type__c;
				listSearchAll.add(oppSearch);
				Boolean booleanPro = true;
				Boolean booleanExp = true;
				Boolean booleanName = true;
				if(datos != null) {
					if (datos.preconcedido != null && datos.preconcedido && opp.Account.AV_IsPreconceived__c != true) {
						booleanPro = false;
						booleanExp = false;
						booleanName = false;
					}
					if (datos.myBox != null && datos.myBox && opp.Account.AV_MyBox__c != 'Sí') {
						booleanPro = false;
						booleanExp = false;
						booleanName = false;
					}
					if (datos.targetAuto != null && datos.targetAuto && opp.Account.AV_TargetAuto__c != 'Sí') {
						booleanPro = false;
						booleanExp = false;
						booleanName = false;
					}
					if (datos.type != null && opp.AV_Type__c != datos.type) {
						booleanPro = false;
						booleanExp = false;
						booleanName = false;
					}
				}
				if(moreFilters != null) {
					if (moreFilters.origen != null && moreFilters.origen != 'all' && moreFilters.origen != opp.RecordType.DeveloperName) {
						booleanPro = false;
						booleanExp = false;
						booleanName = false;
					}
					if (moreFilters.expSale != null && moreFilters.expSale != '' && moreFilters.expSale != opp.AV_Potencial__c) {
						booleanPro = false;
						booleanExp = false;
						booleanName = false;
					}
					if (moreFilters.dateProFrom != null && (opp.AV_FechaProximoRecordatorio__c == null || !(datetime.newInstance(opp.AV_FechaProximoRecordatorio__c.year(), opp.AV_FechaProximoRecordatorio__c.month(), opp.AV_FechaProximoRecordatorio__c.day()) >= datetime.newInstance(moreFilters.dateProFrom.year(), moreFilters.dateProFrom.month(), moreFilters.dateProFrom.day())))) {
						booleanPro = false;
						booleanExp = false;
						booleanName = false;
					}
					if (moreFilters.dateProUntil != null && (opp.AV_FechaProximoRecordatorio__c == null || !(datetime.newInstance(opp.AV_FechaProximoRecordatorio__c.year(), opp.AV_FechaProximoRecordatorio__c.month(), opp.AV_FechaProximoRecordatorio__c.day()) <= datetime.newInstance(moreFilters.dateProUntil.year(), moreFilters.dateProUntil.month(), moreFilters.dateProUntil.day())))) {
						booleanPro = false;
						booleanExp = false;
						booleanName = false;
					}
					if (moreFilters.dateVenFrom != null && (opp.CloseDate == null || !(datetime.newInstance(opp.CloseDate.year(), opp.CloseDate.month(), opp.CloseDate.day()) >= datetime.newInstance(moreFilters.dateVenFrom.year(), moreFilters.dateVenFrom.month(), moreFilters.dateVenFrom.day())))) {
						booleanPro = false;
						booleanExp = false;
						booleanName = false;
					}
					if (moreFilters.dateVenUntil != null && (opp.CloseDate == null || !(datetime.newInstance(opp.CloseDate.year(), opp.CloseDate.month(), opp.CloseDate.day()) <= datetime.newInstance(moreFilters.dateVenUntil.year(), moreFilters.dateVenUntil.month(), moreFilters.dateVenUntil.day())))) {
						booleanPro = false;
						booleanExp = false;
						booleanName = false;
					}
					if (moreFilters.dateModFrom != null && (opp.LastModifiedDate == null || !(datetime.newInstance(moreFilters.dateModFrom.year(), moreFilters.dateModFrom.month(), moreFilters.dateModFrom.day(), 0, 0, 0) <= datetime.newInstance(opp.LastModifiedDate.year(), opp.LastModifiedDate.month(), opp.LastModifiedDate.day(), opp.LastModifiedDate.hour(), opp.LastModifiedDate.minute(), opp.LastModifiedDate.second())))) {
						booleanPro = false;
						booleanExp = false;
						booleanName = false;
					}
					if (moreFilters.dateModUntil != null && (opp.LastModifiedDate == null || !(datetime.newInstance(moreFilters.dateModUntil.year(), moreFilters.dateModUntil.month(), moreFilters.dateModUntil.day(), 23, 59, 59) >= datetime.newInstance(opp.LastModifiedDate.year(), opp.LastModifiedDate.month(), opp.LastModifiedDate.day(), opp.LastModifiedDate.hour(), opp.LastModifiedDate.minute(), opp.LastModifiedDate.second())))) {
						booleanPro = false;
						booleanExp = false;
						booleanName = false;
					}
					if (moreFilters.stage != null && moreFilters.stage.size() > 0 && !stageFilter.contains(opp.StageName)) {
						booleanPro = false;
						booleanExp = false;
						booleanName = false;
					}
					if (moreFilters.segmento != null && moreFilters.segmento.size() > 0) {
						if(opp.Account.AV_IndicadoresClientes__c != null && opp.Account.AV_IndicadoresClientes__c.contains(';')) {
							List<String> listIndi = opp.Account.AV_IndicadoresClientes__c.split(';');
							Integer cont = 0;
							for (String seg : listIndi) {
								if(segmentoFilter.contains(seg)) {
									cont++;
								}
							}
							if(cont == 0) {
								booleanPro = false;
								booleanExp = false;
								booleanName = false;
							}
						} else if (!segmentoFilter.contains(opp.Account.AV_IndicadoresClientes__c)) {
							booleanPro = false;
							booleanExp = false;
							booleanName = false;
						}
					}
				}
				if (filterName != null && filterName.size() > 0 && !filterName.contains(opp.Name)) {
					booleanPro = false;
					booleanExp = false;
				}
				if (filterExpe != null && mapNegocioProducts != null && !mapNegocioProducts.isEmpty() && !filterExpe.isEmpty() && opp.Account.AV_Negocio__c != null && opp.AV_PF__c != null) {
					if (opp.Account.AV_Negocio__c.contains(';')) {
						Boolean booleanNeg = false;
						for (String negocio : opp.Account.AV_Negocio__c.split(';')) {
							if (mapNegocioProducts.get(negocio) != null && mapNegocioProducts.get(negocio).contains(opp.AV_PF__c)) {
								booleanNeg = true;
							}
						}
						if(!booleanNeg) {
							booleanPro = false;
							booleanName = false;
						}
					} else if (mapNegocioProducts.get(opp.Account.AV_Negocio__c) == null || !mapNegocioProducts.get(opp.Account.AV_Negocio__c).contains(opp.AV_PF__c)) {
						booleanPro = false;
						booleanName = false;
					}
				} else if (opp.Account.AV_Negocio__c == null) {
					booleanPro = false;
					booleanName = false;
				} else if (opp.AV_PF__c == null) {
					booleanPro = false;
					booleanName = false;
				}
				if (productName != null && opp.AV_PF__r.Name != productName) {
					booleanExp = false;
					booleanName = false;
				} else if (listProducts != null && listProducts.size() > 0 && !listProducts.contains(opp.AV_PF__r.AV_ExternalId__c)) {
					booleanExp = false;
					booleanName = false;
				}
				if (booleanPro) {
					listOppSearchGraPro.add(oppSearch);
				}
				if (booleanExp) {
					listOppSearchGraExp.add(oppSearch);
				}
				if (booleanName) {
					listOppSearchGraName.add(oppSearch);
				}
			}
		}
		if (listOpp != null && !listOpp.isEmpty()) {
			Map<String,List<OppSearch>> mapOppSearch = new Map<String,List<OppSearch>>();
			for (Opportunity opp : listOpp) {
				OppSearch oppSearch = new OppSearch();
				oppSearch.destacada = '';
				if (((System.today().addDays(-7) <= opp.AV_FechaProximoRecordatorio__c && System.today() >= opp.AV_FechaProximoRecordatorio__c && opp.StageName == AV_AppConstants.OPP_STATUS_ENGESTION) || (System.today().addDays(-7) <= opp.AV_FechaAlta__c && System.today() >= opp.AV_FechaAlta__c && opp.StageName == AV_AppConstants.OPP_STATUS_POTENCIAL && setRTPotencialDes.contains(opp.RecordType.DeveloperName))) || (opp.AV_PriorityOpportunity__c == true && setRTPotencialPrior.contains(opp.RecordType.DeveloperName) && opp.StageName == AV_AppConstants.OPP_STATUS_POTENCIAL))  {
					oppSearch.destacadaIcon = 'action:priority';
					oppSearch.iconClass ='slds-icon-custom-custom16 slds-icon_container slds-var-p-top_xx-small slds-var-p-bottom_xx-small';
				} else {
					oppSearch.iconClass ='';
					oppSearch.destacadaIcon = '';
				}
				oppSearch.cliente = opp.Account.Name;
				oppSearch.clienteId = '/'+opp.AccountId;
				oppSearch.origen = opp.RecordType.Name;
				oppSearch.nombre = opp.Name;
				oppSearch.oppId = '/'+opp.Id;
				oppSearch.producto = opp.AV_PF__r.Name;
				oppSearch.productoId = opp.AV_PF__r.AV_ExternalId__c;
				oppSearch.productoIdSales = opp.AV_PF__c;
				oppSearch.estado = (opp.StageName.equals(AV_AppConstants.OPP_STATUS_ENGESTION)) ? 'En Gestión' : opp.StageName;
				oppSearch.priorityOpportunity = opp.AV_PriorityOpportunity__c;
				if (opp.Account.AV_IndicadorDeCumplimiento__c != null) {
					oppSearch.attentionModel = opp.Account.AV_IndicadorDeCumplimiento__c.substringAfterLast('>');
					oppSearch.attentionModelCSS =  'background-image: url(/resource'+opp.Account.AV_IndicadorDeCumplimiento__c.substringAfter('/resource').substringBefore('"')+'); background-repeat: no-repeat;background-size: auto; background-position: left;';
				} else {
					oppSearch.attentionModel = '';
					oppSearch.attentionModelCSS = '';
				}
				if(opp.Account.AV_LastContactDate__c != null) {
					oppSearch.lastContact = opp.Account.AV_LastContactDate__c.format();
				} else {
					oppSearch.lastContact = '';
				}
				oppSearch.channel = opp.AV_Channel__c;
				if (opp.AV_Comentarios__c != null && opp.AV_Comentarios__c.length() > 250) {
					oppSearch.comentario = opp.AV_Comentarios__c.substring(0,250);
					oppSearch.comentarioMore = opp.AV_Comentarios__c;
					oppSearch.isComentarioMore = true;
				}else {
					oppSearch.comentario = opp.AV_Comentarios__c;
					oppSearch.comentarioMore = opp.AV_Comentarios__c;
					oppSearch.isComentarioMore = false;
				}
				if (opp.Account.AV_ClientPotencialityFormula__c != null && opp.Account.AV_ClientPotencialityFormula__c.contains('AV_FancyStar5')) {
					oppSearch.startClientCSS = 'background-image: url(/resource/AV_FancyStar5); background-repeat: no-repeat;background-size: auto; background-position: left;';
				} else if (opp.Account.AV_ClientPotencialityFormula__c != null && opp.Account.AV_ClientPotencialityFormula__c.contains('AV_FancyStar4')) {
					oppSearch.startClientCSS = 'background-image: url(/resource/AV_FancyStar4); background-repeat: no-repeat;background-size: auto; background-position: left;';
				} else if (opp.Account.AV_ClientPotencialityFormula__c != null && opp.Account.AV_ClientPotencialityFormula__c.contains('AV_FancyStar3')) {
					oppSearch.startClientCSS = 'background-image: url(/resource/AV_FancyStar3); background-repeat: no-repeat;background-size: auto; background-position: left;';
				}
				oppSearch.startClient='';
				if (opp.AV_PotencialityOpportunity__c != null && opp.AV_PotencialityOpportunity__c.contains('AV_FancyStar5')) {
					oppSearch.startOppCSS = 'background-image: url(/resource/AV_FancyStar5); background-repeat: no-repeat;background-size: auto; background-position: left;';
				} else if (opp.AV_PotencialityOpportunity__c != null && opp.AV_PotencialityOpportunity__c.contains('AV_FancyStar4')) {
					oppSearch.startOppCSS = 'background-image: url(/resource/AV_FancyStar4); background-repeat: no-repeat;background-size: auto; background-position: left;';
				} else if (opp.AV_PotencialityOpportunity__c != null && opp.AV_PotencialityOpportunity__c.contains('AV_FancyStar3')) {
					oppSearch.startOppCSS = 'background-image: url(/resource/AV_FancyStar3); background-repeat: no-repeat;background-size: auto; background-position: left;';
				}
				oppSearch.startOpp='';
				if(opp.AV_FechaProximoRecordatorio__c != null) {
					oppSearch.fechaPro = opp.AV_FechaProximoRecordatorio__c.format();
				} else {
					oppSearch.fechaPro = '';
				}
				if(opp.CloseDate != null) {
					oppSearch.fechaCie = opp.CloseDate.format();
				} else {
					oppSearch.fechaCie = '';
				}
				if(opp.OwnerId != null){
					oppSearch.gestor = opp.Owner.Name;
				}else{
					oppSearch.gestor ='';
				}
				oppSearch.negocio = opp.Account.AV_Negocio__c;
				if(opp.Account.AV_FormulaNegocio__c != null && opp.Account.AV_FormulaNegocio__c.contains('<br>')) {
					if(opp.Account.AV_FormulaNegocio__c.replaceAll('<br>', ';').contains(';')) {
						String nego = opp.Account.AV_FormulaNegocio__c.replaceAll('<br>', ';');
						oppSearch.negocioView = nego.substring(0,nego.length()-1);
					} else {
						oppSearch.negocioView = opp.Account.AV_FormulaNegocio__c.replaceAll('<br>', ';');
					}
				} else {
					oppSearch.negocioView = opp.Account.AV_FormulaNegocio__c;
				}
				oppSearch.edad = opp.Account.AV_Age__c;
				if(opp.Account.AV_AhorroEInversion__c != null) {
					oppSearch.ahorroEInversion = opp.Account.AV_AhorroEInversion__c.setScale(0).format()+' €';
				} else {
					oppSearch.ahorroEInversion = '0 €';
				}
				if(opp.Account.AV_Financiacion__c != null) {
					oppSearch.financiacion = opp.Account.AV_Financiacion__c.setScale(0).format()+' €';
				} else {
					oppSearch.financiacion = '0 €';
				}
				if(opp.Account.AV_Ingresos__c != null) {
					oppSearch.ingresos = opp.Account.AV_Ingresos__c.setScale(0).format()+' €';
				} else {
					oppSearch.ingresos = '0 €';
				}
				if(opp.Account.AV_Preconceived__c != null) {
					oppSearch.preconcedido = opp.Account.AV_Preconceived__c.setScale(0).format()+' €';
				} else {
					oppSearch.preconcedido = '0 €';
				}
				oppSearch.mybox = opp.Account.AV_MyBox__c;
				oppSearch.targetAuto = opp.Account.AV_TargetAuto__c;
				oppSearch.tipo = opp.AV_Type__c;
				if(mapOppSearch.containsKey(oppSearch.clienteId)) {
					String idClient = oppSearch.clienteId;
					oppSearch.startClientCSS = '';
					oppSearch.clienteId = '';
					oppSearch.cliente = '';
					oppSearch.mybox = '';
					oppSearch.targetAuto = '';
					oppSearch.edad = null;
					mapOppSearch.get(idClient).add(oppSearch);
				} else {
					mapOppSearch.put(oppSearch.clienteId, new List<OppSearch> {oppSearch});
				}
			}
			if (mapOppSearch != null) {
				for (String idAcc : mapOppSearch.keySet()) {
					if (mapOppSearch.get(idAcc) != null) {
						for (OppSearch os : mapOppSearch.get(idAcc)) {
							listOppSearch.add(os);
						}
					}
				}
			}
		}
		DataReturn datareturn = new DataReturn();
		datareturn.listOpp = listOppSearch;
		datareturn.listOppGraPro = listOppSearchGraPro;
		datareturn.listOppGraExp = listOppSearchGraExp;
		datareturn.listOppGraName = listOppSearchGraName;
		datareturn.listOppSearch = listSearchAll;
		datareturn.totalSize = total;
		datareturn.totalSizeClient = totalClient;
		return datareturn;
	}

	/**
	* @description      	Method to pass qualityClouds with query string
	* @param q				string with query
	* @return          	 	List of Opportunities
	*/
	private static List<Opportunity> capsulateQuery(String q){
		Set<String> setRTPotencial = new Set<String>{AV_AppConstants.OPPALERTACOM_RT,AV_AppConstants.OPPLLAMADA_RT,AV_AppConstants.OPPPROPUESTA_RT};
		Set<String> setRTPotencialDes = new Set<String>{AV_AppConstants.OPPALERTACOM_RT,AV_AppConstants.OPPLLAMADA_RT};
		Set<String> setRTPotencialPrior = new Set<String>{AV_AppConstants.OPPALERTACOM_RT,AV_AppConstants.OPPLLAMADA_RT, AV_AppConstants.OPPPROPUESTA_RT};
		Set<String> setRTGestion = new Set<String>{AV_AppConstants.OPPALERTACOM_RT,AV_AppConstants.OPPLLAMADA_RT,AV_AppConstants.OPPPROPUESTA_RT,AV_AppConstants.OPPINICIATIVA_RT,AV_AppConstants.OPPSUGERENCIA_RT};
		String potencial = AV_AppConstants.OPP_STATUS_POTENCIAL;
		String gestion = AV_AppConstants.OPP_STATUS_ENGESTION;
		String owner = UserInfo.getUserId();
		return (List<Opportunity>) Database.query(q);
	}

	/**
	* @description      	Method to pass qualityClouds with query string
	* @param q				string with query
	* @return          	 	List of Opportunities
	*/
	private static Integer getCapsulateCountQuery(String q){
		return Integer.valueOf((capsulateCountQuery(q)).get(0).get('expr0'));
	}

	/**
	* @description      	Method to pass qualityClouds with query string
	* @param q				string with query
	* @return          	 	List of Opportunities
	*/
	private static Integer getCapsulateCountQueryClient(String q){
		return Integer.valueOf((capsulateCountQuery(q)).size());
	}

	/**
	* @description      	Method to pass qualityClouds with query string
	* @param q				string with query
	* @return          	 	List of Opportunities
	*/
	private static List<AggregateResult> capsulateCountQuery(String q){
		Set<String> setRTPotencial = new Set<String>{AV_AppConstants.OPPALERTACOM_RT,AV_AppConstants.OPPLLAMADA_RT,AV_AppConstants.OPPPROPUESTA_RT};
		Set<String> setRTPotencialDes = new Set<String>{AV_AppConstants.OPPALERTACOM_RT,AV_AppConstants.OPPLLAMADA_RT};
		Set<String> setRTPotencialPrior = new Set<String>{AV_AppConstants.OPPALERTACOM_RT,AV_AppConstants.OPPLLAMADA_RT, AV_AppConstants.OPPPROPUESTA_RT};
		Set<String> setRTGestion = new Set<String>{AV_AppConstants.OPPALERTACOM_RT,AV_AppConstants.OPPLLAMADA_RT,AV_AppConstants.OPPPROPUESTA_RT,AV_AppConstants.OPPINICIATIVA_RT,AV_AppConstants.OPPSUGERENCIA_RT};
		String potencial = AV_AppConstants.OPP_STATUS_POTENCIAL;
		String gestion = AV_AppConstants.OPP_STATUS_ENGESTION;
		String owner = UserInfo.getUserId();
		return (List<AggregateResult>) Database.query(q);
	}

	/**
	* @description Object to to view charts
	*/
	public class DataCharts {
		@AuraEnabled
		public String label;
		@AuraEnabled
		public Integer value;
		@AuraEnabled
		public List<ProductNegocio> listProduct;
	}

	/**
	* @description Object to chart experience
	*/
	public class ProductNegocio {
		@AuraEnabled
		public String product;
		@AuraEnabled
		public String negocio;
	}

	/**
	* @description      		Get Opportunities to view in all search
	* @param listOppString		filters of opportunities with filters
	* @param listOppExpString	filters of opportunities all
	* @param filterExpe			filters of chart experience
	* @return          	 		List of Opportunities
	*/
	@AuraEnabled
	public static List<DataCharts> getDataToChart(List<Map<String,String>> listOpp, List<Map<String,String>> listOppExp, Boolean filterWithOthersCharts){
		String methodName = 'getDataToChart';
		List<DataCharts> listDataChart = new List<DataCharts>();
		Integer numSinExp = 0;
		List<ProductNegocio> listProSinExp = new List<ProductNegocio>();
		if(listOpp != null && listOppExp != null && !listOppExp.isEmpty() && !listOpp.isEmpty()) {
			List<String> listProductNegocio = new List<String>();
			Map<String,Integer> mapProductNegocioNum = new Map<String,Integer>();
			Map<String,String> mapNegocio = new Map<String,String>();
			for (Map<String,String> opp : listOpp) {
				if (opp.get('negocio') != null && opp.get('productoId') != null) {
					if(opp.get('negocio').contains(';')) {
						listProductNegocio.add(opp.get('negocio').split(';')[0]+'_'+opp.get('productoId'));
						mapNegocio.put(opp.get('negocio').split(';')[0]+'_'+opp.get('productoId'),opp.get('negocio').split(';')[0]);
						if (mapProductNegocioNum.containsKey(opp.get('negocio').split(';')[0]+'_'+opp.get('productoId'))) {
							mapProductNegocioNum.put(opp.get('negocio').split(';')[0]+'_'+opp.get('productoId'),mapProductNegocioNum.get(opp.get('negocio').split(';')[0]+'_'+opp.get('productoId'))+1);
						} else {
							mapProductNegocioNum.put(opp.get('negocio').split(';')[0]+'_'+opp.get('productoId'),1);
						}
					} else {
						listProductNegocio.add(opp.get('negocio')+'_'+opp.get('productoId'));
						mapNegocio.put(opp.get('negocio')+'_'+opp.get('productoId'),opp.get('negocio'));
						if (mapProductNegocioNum.containsKey(opp.get('negocio')+'_'+opp.get('productoId'))) {
							mapProductNegocioNum.put(opp.get('negocio')+'_'+opp.get('productoId'),mapProductNegocioNum.get(opp.get('negocio')+'_'+opp.get('productoId'))+1);
						} else {
							mapProductNegocioNum.put(opp.get('negocio')+'_'+opp.get('productoId'),1);
						}
					}
				}
			}
			List<String> listProductNegocio2 = new List<String>();
			Map<String,Integer> mapProductNegocioNum2 = new Map<String,Integer>();
			Map<String,String> mapNegocio2 = new Map<String,String>();
			Map<String,String> mapProduct = new Map<String,String>();
			for (Map<String,String> opp : listOppExp) {
				if (opp.get('negocio') != null && opp.get('productoId') != null) {
					if(opp.get('negocio').contains(';')) {
						listProductNegocio2.add(opp.get('negocio').split(';')[0]+'_'+opp.get('productoId'));
						mapNegocio2.put(opp.get('negocio').split(';')[0]+'_'+opp.get('productoId'),opp.get('negocio').split(';')[0]);
						mapProduct.put(opp.get('negocio').split(';')[0]+'_'+opp.get('productoId'),opp.get('productoIdSales'));
						if (mapProductNegocioNum2.containsKey(opp.get('negocio').split(';')[0]+'_'+opp.get('productoId'))) {
							mapProductNegocioNum2.put(opp.get('negocio').split(';')[0]+'_'+opp.get('productoId'),mapProductNegocioNum2.get(opp.get('negocio').split(';')[0]+'_'+opp.get('productoId'))+1);
						} else {
							mapProductNegocioNum2.put(opp.get('negocio').split(';')[0]+'_'+opp.get('productoId'),1);
						}
					} else {
						listProductNegocio2.add(opp.get('negocio')+'_'+opp.get('productoId'));
						mapNegocio2.put(opp.get('negocio')+'_'+opp.get('productoId'),opp.get('negocio'));
						mapProduct.put(opp.get('negocio')+'_'+opp.get('productoId'),opp.get('productoIdSales'));
						if (mapProductNegocioNum2.containsKey(opp.get('negocio')+'_'+opp.get('productoId'))) {
							mapProductNegocioNum2.put(opp.get('negocio')+'_'+opp.get('productoId'),mapProductNegocioNum2.get(opp.get('negocio')+'_'+opp.get('productoId'))+1);
						} else {
							mapProductNegocioNum2.put(opp.get('negocio')+'_'+opp.get('productoId'),1);
						}
					}
				} else if ((opp.get('negocio') == null || opp.get('productoId') == null) || (opp.get('negocio') == null && opp.get('productoId') == null)) {
					ProductNegocio pn = new ProductNegocio();
					pn.product = opp.get('oppId').substring(1);
					pn.negocio = null;
					listProSinExp.add(pn);
					if (!filterWithOthersCharts) {
						numSinExp++;
					}
				}
			}
		
			List<String> externalsProductExpe = new List<String>();
			if (listProductNegocio != null && listProductNegocio2 != null && !listProductNegocio2.isEmpty() && !listProductNegocio.isEmpty()) {
				List<AV_ProductExperience__c> listProExp = [SELECT AV_ExperienciaNegocio__r.AV_DescTipoExperiencia__c, AV_ProductoFicha__c, AV_ExternalID__c FROM AV_ProductExperience__c WHERE AV_ExternalID__c IN :listProductNegocio OR AV_ExternalID__c IN :listProductNegocio2];
				if (listProExp != null && !listProExp.isEmpty()) {
					Map<String,Integer> mapExpeNum = new Map<String,Integer>();
					Map<String,List<ProductNegocio>> mapExpePro = new Map<String,List<ProductNegocio>>();
					List<String> listIdDuple = new List<String>();
					Map<String,List<ProductNegocio>> mapExpePro2 = new Map<String,List<ProductNegocio>>();
					for (AV_ProductExperience__c pe : listProExp) {
						if(listProductNegocio.contains(pe.AV_ExternalID__c)) {
							if (mapExpeNum.containsKey(pe.AV_ExperienciaNegocio__r.AV_DescTipoExperiencia__c)) {
								mapExpeNum.put(pe.AV_ExperienciaNegocio__r.AV_DescTipoExperiencia__c,mapExpeNum.get(pe.AV_ExperienciaNegocio__r.AV_DescTipoExperiencia__c)+mapProductNegocioNum.get(pe.AV_ExternalID__c));
							} else {
								mapExpeNum.put(pe.AV_ExperienciaNegocio__r.AV_DescTipoExperiencia__c,mapProductNegocioNum.get(pe.AV_ExternalID__c));
							}

							ProductNegocio pn = new ProductNegocio();
							pn.product = pe.AV_ProductoFicha__c;
							pn.negocio = mapNegocio.get(pe.AV_ExternalID__c);
							if (mapExpePro.containsKey(pe.AV_ExperienciaNegocio__r.AV_DescTipoExperiencia__c)) {
								mapExpePro.get(pe.AV_ExperienciaNegocio__r.AV_DescTipoExperiencia__c).add(pn);
							} else {
								mapExpePro.put(pe.AV_ExperienciaNegocio__r.AV_DescTipoExperiencia__c, new List<ProductNegocio> {pn});
							}
						}
						if(listProductNegocio2.contains(pe.AV_ExternalID__c)) {
							ProductNegocio pn = new ProductNegocio();
							pn.product = pe.AV_ProductoFicha__c;
							pn.negocio = mapNegocio2.get(pe.AV_ExternalID__c);
							if (mapExpePro2.containsKey(pe.AV_ExperienciaNegocio__r.AV_DescTipoExperiencia__c)) {
								mapExpePro2.get(pe.AV_ExperienciaNegocio__r.AV_DescTipoExperiencia__c).add(pn);
							} else {
								mapExpePro2.put(pe.AV_ExperienciaNegocio__r.AV_DescTipoExperiencia__c, new List<ProductNegocio> {pn});
							}
						}
						externalsProductExpe.add(pe.AV_ExternalID__c);
					}
					if (mapExpeNum != null && mapExpePro != null && mapExpePro2 != null && !mapExpePro2.isEmpty() && !mapExpeNum.isEmpty() && !mapExpePro.isEmpty()) {
						for (String name : mapExpeNum.keySet()) {
							if (mapExpeNum.get(name) != null && mapExpePro.get(name) != null) {
								DataCharts dataChart = new DataCharts();
								dataChart.label = name;
								dataChart.value = mapExpeNum.get(name);
								dataChart.listProduct = mapExpePro2.get(name);
								listDataChart.add(dataChart);
							}
						}
					}
				}
				for (String external : listProductNegocio2) {
					if(((externalsProductExpe != null && !externalsProductExpe.isEmpty() && !externalsProductExpe.contains(external)) || externalsProductExpe == null || externalsProductExpe.isEmpty())) {
						ProductNegocio pn = new ProductNegocio();
						pn.product = mapProduct.get(external);
						pn.negocio = mapNegocio2.get(external);
						listProSinExp.add(pn);
					}
				}
				for (String external : listProductNegocio) {
					if(((externalsProductExpe != null && !externalsProductExpe.isEmpty() && !externalsProductExpe.contains(external)) || externalsProductExpe == null || externalsProductExpe.isEmpty())) {
						if (listProductNegocio.contains(external) && (!filterWithOthersCharts || (mapProduct.get(external) != null && mapNegocio2.get(external) != null))) {
							numSinExp++;
						}
					}
				}
				if (numSinExp > 0) {
					DataCharts dataChart = new DataCharts();
					dataChart.label = 'Sin experiencia';
					dataChart.value = numSinExp;
					dataChart.listProduct = listProSinExp;
					listDataChart.add(dataChart);
				}
			}
		}
		return listDataChart;
	}

	/**
	* @description Object to search of offices
	*/
	public class SearchOffices {
		@AuraEnabled
		public List<AV_LookupSearchResult> listOfi;
		@AuraEnabled
		public String optionAll;
		@AuraEnabled
		public Boolean isMultiOffi;
	}

	/**
	 * @description		Lookup of Office 
	 * @param	searchTerm	The search term to look up users.
	 * @param	selectedIds	A list of selected user IDs.
	 */
	@AuraEnabled(cacheable=true)
	public static SearchOffices searchOffice(String searchTerm, List<String> selectedIds) {
		Integer maxResult = 10;
		Boolean isMultiOffi = false;
		Set<String> directores = new Set<String>{AV_AppConstants.FUNCION_DT, AV_AppConstants.FUNCION_DC, AV_AppConstants.FUNCION_DAN};
		Set<String> gestor = new Set<String>{AV_AppConstants.FUNCION_GESTOR, AV_AppConstants.FUNCION_OFICINA};
		String sscc = AV_AppConstants.FUNCION_SSCC;
		searchTerm +='*';
		List<AV_LookupSearchResult> results = new List<AV_LookupSearchResult>();
		List<List<SObject>> searchResults = new List<List<SObject>>();
		Id accRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(AV_AppConstants.ACCOUNT_CTO_RT).getRecordTypeId();
		User currentUser = [SELECT AV_Funcion__c, AV_NumeroOficinaEmpresa__c, AV_OriginalOfficeNumber__c FROM User WHERE Id = :UserInfo.getUserId()];
		Set<Id> offices;
		if (currentUser.AV_OriginalOfficeNumber__c != null) {
			offices = AV_MassReassignOwner_Controller.getInferiorCenterIds(currentUser);
		}else {
			offices = AV_MassReassignOwner_Controller.getInferiorCenterIds();
		}
		Account centroUsuario = [SELECT Id, Name, CC_Numero_Oficina__c, AV_CentroSuperior__c, CC_Numero_Oficina_Empresa__c FROM Account WHERE CC_Numero_Oficina_Empresa__c = :currentUser.AV_NumeroOficinaEmpresa__c];
		// Aqui se revisa si es un gestor multi oficina para recoger las otras oficinas que tiene
		List<String> listCenters = new List<String>();
		if ((String.isNotBlank(currentUser.AV_Funcion__c) && gestor.contains(currentUser.AV_Funcion__c)))  {
			List<Contact> contactUser = [SELECT Id, AV_CodFuncion__c FROM Contact WHERE AV_UsuarioAsociado__c  = :UserInfo.getUserId()];
			if (contactUser != null && !contactUser.isEmpty()) {
				List<AV_ChangeOfficeCode__mdt> codesOffices = [SELECT AV_CodFuncion__c FROM AV_ChangeOfficeCode__mdt];
				if (codesOffices != null && !codesOffices.isEmpty()) {
					List<String> listCodesOffi = new List<String>();
					for (AV_ChangeOfficeCode__mdt coc : codesOffices) {
						listCodesOffi.add(coc.AV_CodFuncion__c);
					}
					if (listCodesOffi.contains(contactUser[0].AV_CodFuncion__c)) {
						isMultiOffi = true;
						List<AggregateResult> listOppCenters = [SELECT AV_Center__c FROM Opportunity WHERE OwnerId = :UserInfo.getUserId() AND AV_Center__c != null GROUP BY AV_Center__c];
						for (AggregateResult ar : listOppCenters) {
							listCenters.add((String)ar.get('AV_Center__c'));
						}
					}
				}
			}
		}
		if (String.isNotBlank(currentUser.AV_Funcion__c) && directores.contains(currentUser.AV_Funcion__c)) {
			if(!selectedIds.isEmpty()){
				if (currentUser.AV_OriginalOfficeNumber__c != null) {
					searchResults = [
						FIND :searchTerm
						IN Name FIELDS
						RETURNING
							Account(Id, Name, CC_Numero_Oficina__c, CC_Numero_Oficina_Empresa__c WHERE Id NOT IN :selectedIds and (Id = :centroUsuario.Id or Id IN :offices) and RecordType.Id =: accRecordTypeId)
						LIMIT :maxResult
					];
				} else {
					searchResults = [
						FIND :searchTerm
						IN Name FIELDS
						RETURNING
							Account(Id, Name, CC_Numero_Oficina__c, CC_Numero_Oficina_Empresa__c WHERE Id NOT IN :selectedIds and Id IN :offices and RecordType.Id =: accRecordTypeId)
						LIMIT :maxResult
					];
				}
			} else{
				if (currentUser.AV_OriginalOfficeNumber__c != null) {
					searchResults = [
						FIND :searchTerm
						IN Name FIELDS
						RETURNING
							Account(Id, Name, CC_Numero_Oficina__c, CC_Numero_Oficina_Empresa__c WHERE (Id = :centroUsuario.Id or Id IN :offices) and RecordType.Id =: accRecordTypeId)
						LIMIT :maxResult
					];
				}else {
					searchResults = [
						FIND :searchTerm
						IN Name FIELDS
						RETURNING
							Account(Id, Name, CC_Numero_Oficina__c, CC_Numero_Oficina_Empresa__c WHERE (Id = :centroUsuario.Id or Id IN :offices) and RecordType.Id =: accRecordTypeId)
						LIMIT :maxResult
					];
				}
			}
		} else if ((String.isNotBlank(currentUser.AV_Funcion__c) && gestor.contains(currentUser.AV_Funcion__c))) {
			if(!selectedIds.isEmpty()){
				if (currentUser.AV_OriginalOfficeNumber__c != null) {
					if (listCenters != null && !listCenters.isEmpty()) {
						searchResults = [
							FIND :searchTerm
							IN Name FIELDS
							RETURNING
								Account(Id, Name, CC_Numero_Oficina__c, CC_Numero_Oficina_Empresa__c WHERE (Id = :centroUsuario.Id or Id in :offices or CC_Numero_Oficina__c IN :listCenters) and Id NOT IN :selectedIds and RecordType.DeveloperName = :AV_AppConstants.ACCOUNT_CTO_RT)
							LIMIT :maxResult
						];
					} else {
					searchResults = [
						FIND :searchTerm
						IN Name FIELDS
						RETURNING
							Account(Id, Name, CC_Numero_Oficina__c, CC_Numero_Oficina_Empresa__c WHERE (Id = :centroUsuario.Id or Id in :offices) and Id NOT IN :selectedIds and RecordType.DeveloperName = :AV_AppConstants.ACCOUNT_CTO_RT)
						LIMIT :maxResult
					];
					}
				} else {
					if (listCenters != null && !listCenters.isEmpty()) {
						searchResults = [
							FIND :searchTerm
							IN Name FIELDS
							RETURNING
								Account(Id, Name, CC_Numero_Oficina__c, CC_Numero_Oficina_Empresa__c WHERE (Id = :centroUsuario.Id or CC_Numero_Oficina__c IN :listCenters) and Id NOT IN :selectedIds and RecordType.DeveloperName = :AV_AppConstants.ACCOUNT_CTO_RT)
							LIMIT :maxResult
						];
				} else {
					searchResults = [
						FIND :searchTerm
						IN Name FIELDS
						RETURNING
							Account(Id, Name, CC_Numero_Oficina__c, CC_Numero_Oficina_Empresa__c WHERE Id = :centroUsuario.Id and Id NOT IN :selectedIds and RecordType.DeveloperName = :AV_AppConstants.ACCOUNT_CTO_RT)
						LIMIT :maxResult
					];
				}
				}
			} else{
				if (currentUser.AV_OriginalOfficeNumber__c != null) {
					if (listCenters != null && !listCenters.isEmpty()) {
						searchResults = [
							FIND :searchTerm
							IN Name FIELDS
							RETURNING
								Account(Id, Name, CC_Numero_Oficina__c, CC_Numero_Oficina_Empresa__c WHERE (Id = :centroUsuario.Id or Id in :offices or CC_Numero_Oficina__c IN :listCenters) and RecordType.DeveloperName = :AV_AppConstants.ACCOUNT_CTO_RT)
							LIMIT :maxResult
						];
					} else {
					searchResults = [
						FIND :searchTerm
						IN Name FIELDS
						RETURNING
							Account(Id, Name, CC_Numero_Oficina__c, CC_Numero_Oficina_Empresa__c WHERE (Id = :centroUsuario.Id or Id in :offices) and RecordType.DeveloperName = :AV_AppConstants.ACCOUNT_CTO_RT)
						LIMIT :maxResult
					];
					}
				} else {
					if (listCenters != null && !listCenters.isEmpty()) {
						searchResults = [
							FIND :searchTerm
							IN Name FIELDS
							RETURNING
								Account(Id, Name, CC_Numero_Oficina__c, CC_Numero_Oficina_Empresa__c WHERE (Id = :centroUsuario.Id or CC_Numero_Oficina__c IN :listCenters) and RecordType.DeveloperName = :AV_AppConstants.ACCOUNT_CTO_RT)
							LIMIT :maxResult
						];
				} else {
					searchResults = [
						FIND :searchTerm
						IN Name FIELDS
						RETURNING
							Account(Id, Name, CC_Numero_Oficina__c, CC_Numero_Oficina_Empresa__c WHERE Id = :centroUsuario.Id and RecordType.DeveloperName = :AV_AppConstants.ACCOUNT_CTO_RT)
						LIMIT :maxResult
					];
				}
			}	
			}	
		} else if (String.isNotBlank(currentUser.AV_Funcion__c) && sscc.equals(currentUser.AV_Funcion__c)) {
			if(!selectedIds.isEmpty()){
				if (currentUser.AV_OriginalOfficeNumber__c != null) {
					searchResults = [
						FIND :searchTerm
						IN Name FIELDS
						RETURNING
							Account(Id, Name, CC_Numero_Oficina__c, CC_Numero_Oficina_Empresa__c WHERE Id in :offices and Id NOT IN :selectedIds and RecordType.DeveloperName = :AV_AppConstants.ACCOUNT_CTO_RT)
						LIMIT :maxResult
					];
				} else {
					searchResults = [
						FIND :searchTerm
						IN Name FIELDS
						RETURNING
							Account(Id, Name, CC_Numero_Oficina__c, CC_Numero_Oficina_Empresa__c WHERE Id NOT IN :selectedIds and RecordType.DeveloperName = :AV_AppConstants.ACCOUNT_CTO_RT)
						LIMIT :maxResult
					];
				}
			} else{
				if (currentUser.AV_OriginalOfficeNumber__c != null) {
					searchResults = [
						FIND :searchTerm
						IN Name FIELDS
						RETURNING
							Account(Id, Name, CC_Numero_Oficina__c, CC_Numero_Oficina_Empresa__c WHERE Id in :offices and RecordType.DeveloperName = :AV_AppConstants.ACCOUNT_CTO_RT)
						LIMIT :maxResult
					];
				} else {
					searchResults = [
						FIND :searchTerm
						IN Name FIELDS
						RETURNING
							Account(Id, Name, CC_Numero_Oficina__c, CC_Numero_Oficina_Empresa__c WHERE RecordType.DeveloperName = :AV_AppConstants.ACCOUNT_CTO_RT)
						LIMIT :maxResult
					];
				}
			}	
		}
		String productIcon = 'standard:account';
		List<String> accAll = new List<String>();
		List<Account> listAccountAll = new List<Account>();
		if (listCenters != null && offices != null && !listCenters.isEmpty() && !offices.isEmpty()) {
			listAccountAll = [SELECT Id, Name, CC_Numero_Oficina__c FROM Account WHERE CC_Numero_Oficina__c IN :listCenters or Id = :centroUsuario.Id or Id in :offices];
			for (Account acc : listAccountAll) {
				accAll.add(acc.CC_Numero_Oficina__c);
			}
		} else if (listCenters != null && !listCenters.isEmpty()) {
			listAccountAll = [SELECT Id, Name, CC_Numero_Oficina__c FROM Account WHERE CC_Numero_Oficina__c IN :listCenters or Id = :centroUsuario.Id];
			for (Account acc : listAccountAll) {
				accAll.add(acc.CC_Numero_Oficina__c);
			}
		}
		if (accAll != null && !accAll.isEmpty() && accAll.size() > 1) {
			results.add(
				new AV_LookupSearchResult(
					null,
					AV_AppConstants.OBJECT_NAME_ACCOUNT,
					productIcon,
					'Todas',
					null
				)
			);
		}
		Account[] listAccount = (List<Account>) searchResults[0];
		for (Account acc : listAccount) {
			results.add(
				new AV_LookupSearchResult(
					acc.Id,
					AV_AppConstants.OBJECT_NAME_ACCOUNT,
					productIcon,
					acc.Name,
					'Número • ' + acc.CC_Numero_Oficina__c
				)
			);
		}
		if (listAccountAll != null && !listAccountAll.isEmpty()) {
			Integer cont = 1;
			for (Account acc : listAccountAll) {
				if (cont <= maxResult) {
					results.add(
						new AV_LookupSearchResult(
							acc.Id,
							AV_AppConstants.OBJECT_NAME_ACCOUNT,
							productIcon,
							acc.Name,
							'Número • ' + acc.CC_Numero_Oficina__c
						)
					);
					cont++;
				} else {
					break;
				}
            }
		}
		results.sort();
		SearchOffices so = new SearchOffices();
		so.listOfi = results;
		so.optionAll = String.join(accAll, ',');
		so.isMultiOffi = isMultiOffi;
		return so;
	}

	/**
	 * @description		Lookup of User Assigment
	 * @param officeFilterData The filter for the office.
	 */
	@AuraEnabled
	public static List<OptionsEmployee> getEmployees(String officeFilterData){
		String  idGcf = (String) [SELECT Id FROM User WHERE Alias = :AV_AppConstants.AV_ALIAS_AVTF9 LIMIT 1].Id;	
		String allLabel = 'all';
		Integer maxLimit = 49900;
		List<OptionsEmployee> employees = new List<OptionsEmployee>();
		List<OptionsEmployee> employeesSorted = new List<OptionsEmployee>();
		List<Id> employeesId = new List<Id>();
		User emp  = [Select Id, AV_ExternalID__c, AV_NumeroOficinaEmpresa__c From User Where Id = :UserInfo.getUserId()];
		
		if (String.isNotBlank(officeFilterData)) {
			String[] data = officeFilterData.split('\\{\\|}');
			if (data.size() > 1) {
				String profileId = [
					SELECT Id
					FROM Profile
					WHERE Name = :AV_AppConstants.AV_PROFILE
				].Id;
				Set<String> allRts = new Set<String>{
					AV_AppConstants.OPPINICIATIVA_RT,
					AV_AppConstants.OPPALERTACOM_RT,
					AV_AppConstants.OPPPROPUESTA_RT,
					AV_AppConstants.OPPSUGERENCIA_RT,
					AV_AppConstants.OPPLLAMADA_RT
				};
				List<RecordType> listRt = new List<RecordType>();
				
				Set<Id> setIdsRts = new Set<Id>();
				if(data[2] != allLabel){
					setIdsRts = AV_AppUtilities.getRecordTypeIdsInSet(new Set<String>{data[2]});			
				}else{
					setIdsRts = AV_AppUtilities.getRecordTypeIdsInSet(allRts);			
				}
				List<String> status;
				if (data[1].contains(',')) {
					status = data[1].split(',');
				} else {
					status = new List<String>{data[1]};
				}		
				AggregateResult[] oppsWithCenter = [
					SELECT OwnerId, Owner.Name
					FROM Opportunity
					WHERE AV_Center__c = :data[0] AND Owner.ProfileId = :profileId AND StageName IN :status AND RecordTypeId IN :setIdsRts 
					GROUP BY OwnerId, Owner.Name
				];
				if (!oppsWithCenter.isEmpty()) {
					for (AggregateResult opp : oppsWithCenter) {
						employeesId.add((Id)opp.get('OwnerId'));
						employeesSorted.add(new OptionsEmployee((Id)opp.get('OwnerId'),(String)opp.get('Name')));
					}
				}
			} else if (data.size() == 1) {
				String profileId = [
					SELECT Id
					FROM Profile
					WHERE Name = :AV_AppConstants.AV_PROFILE
				].Id;
				List<User> searchResults = [
					SELECT Id, Name, AV_NumeroOficinaEmpresa__c FROM User WHERE ProfileId = :profileId
					AND AV_NumeroOficinaEmpresa__c LIKE :('%' + officeFilterData + '%') 
					LIMIT :maxLimit
				];
				if(!searchResults.isEmpty() && searchResults != null){
					for(User u : searchResults){
						employeesId.add(u.Id);
						employeesSorted.add(new OptionsEmployee(u.Id,u.Name));
					}
				}
			}
		}
		if(employeesId.size() > 1) {
			String employeesAlls=string.join(employeesId,',');
			employees.add(new OptionsEmployee(idGcf+','+employeesAlls,'Todos-' + officeFilterData.split('\\{\\|}')[0]));
		}
		employees.add(new OptionsEmployee(idGcf, AV_AppConstants.SINGESTOR_EAP_CENTRO + officeFilterData.split('\\{\\|}')[0]));
		employees.add(new OptionsEmployee('005000000000000000',AV_AppConstants.MULTIGENAME));

		if(employeesId.size() > 0){
			employeesSorted.sort();
			employees.addAll(employeesSorted);
		}
		return employees;		
	}

	/**
	 * @description				Get options to combobox of field type
	 * @param oficina			Filter of oficina
	 * @param employee		 	Filter of employee
	 * @param listProducts		Filter of products
	 */
	@AuraEnabled
	public static List<OptionsEmployee> getTypesOptions(String oficina, String employee, List<String> listProducts) {
		List<OptionsEmployee> listOptions = new List<OptionsEmployee>();
		String avQuery ='SELECT AV_Type__c FROM Opportunity WHERE ((RecordType.DeveloperName in :setRTPotencial AND StageName = :potencial) OR (RecordType.DeveloperName in :setRTGestion AND StageName = :gestion))';
		if (employee != null && oficina != null) {
			avQuery = avQuery + ' AND OwnerId = \''+employee+'\' AND AV_Center__c =\''+oficina+'\'';
		}
		if (listProducts != null && listProducts.size() > 0) {
			avQuery = avQuery+' AND AV_PF__r.AV_ExternalId__c in '+AV_AppUtilities.listToStringIn(listProducts);
		}
		avQuery = avQuery+' GROUP BY AV_Type__c';
		List<AggregateResult> listType = capsulateCountQuery(avQuery);
		if (listType != null && !listType.isEmpty()) {
			for (AggregateResult ar : listType) {
				if (ar.get('AV_Type__c') != null) {
					listOptions.add(new OptionsEmployee((String)ar.get('AV_Type__c'),(String)ar.get('AV_Type__c')));
				}
			}
		}
		listOptions.add(new OptionsEmployee(null,''));
		return listOptions;
	}
	@AuraEnabled 
	public static Map<String,User> enanchedGetUserInfo(String userId){
		List<User> mainUser =  [SELECT Id, Name,AV_Funcion__c,AV_NumeroOficinaEmpresa__c,AV_Pool__c FROM User WHERE Id = :userId LIMIT 1];
		Map<String,User> response = new Map<String,User>{'gestor' => mainUser[0]};
		if(mainUser[0].AV_Pool__c){
			String multige = AV_PoolEvents_Controller.getCurrentDT(mainUser[0].AV_NumeroOficinaEmpresa__c);
			if(multige != null){
					response.put('multigestor',new User(Id = multige));
			}
		}

		return response;
	}


}