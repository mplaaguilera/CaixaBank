/**********************************************************************************************************************
@description
Name:	  CIBE_OppSearchEMP_Controller
Copyright © 2024  CaixaBank
------------------------------------------------------------------------------------------------
Proposito: Apex class controller to LWC CIBE_OppSearchEMP
------------------------------------------------------------------------------------------------
Historial
---------------------
VERSION		USER_STORY	        AUTHOR		   		DATE				Description
1.0			US807175		    Luis Martínez	    27/02/2024		    Init version
***********************************************************************************************************************/
public with sharing class CIBE_OppSearchEMP_Controller {

	public static DataMoreFilters moreFilters = new DataMoreFilters();
	public static List<String> participanteFilter = new List<String>();


	/**
	* @description Object to filters of table and charts
	*/
	public class DataFilter {
		@AuraEnabled
		public Boolean isDestacada;
		@AuraEnabled
		public Boolean isPendienteFirma;
		@AuraEnabled
		public Boolean isPrio;
		@AuraEnabled
		public String orderBy;
		@AuraEnabled
		public String orderingCriterion;
	}

	/**
	* @description Object to Opp View in table and charts
	*/
	public class OppSearch{
		
		@AuraEnabled
		public String destacada;
		@AuraEnabled
		public String destacadaIcon;
		@AuraEnabled
		public String iconClass;
		@AuraEnabled
		public String grupoComercial;
		@AuraEnabled
		public String grupoComercialId;
		@AuraEnabled
		public String cliente;
		@AuraEnabled
		public String clienteId;
		@AuraEnabled
		public String origen;
		@AuraEnabled
		public String estado;//etapa
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
		public String importe;
		@AuraEnabled
		public String divisa;
		@AuraEnabled
		public String financiacion;
		@AuraEnabled
		public String probabilidad;
		@AuraEnabled
		public String fechaUltimaG;
		@AuraEnabled
		public String fechaProxG;
		@AuraEnabled
		public String fechaCie;
		@AuraEnabled
		public String fechaUltimoC;
		@AuraEnabled
		public String fechaproxCi;
		@AuraEnabled
		public String propietario;
		@AuraEnabled
		public String comentario;
		@AuraEnabled
		public Boolean esg;
		@AuraEnabled
		public String propietarioId;
		@AuraEnabled 
		public String hijo;
		@AuraEnabled 
		public DateTime fechaUltContactCliente;
		@AuraEnabled 
		public String idProduct;
		@AuraEnabled 
		public String equipoOpp;

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
		public Map<String, GC> grupo;
		@AuraEnabled
		public Integer totalSize;
	}

	public class GC{
		@AuraEnabled
		public String id;
		@AuraEnabled
		public String grupoComercialId;
		@AuraEnabled
		public String grupoComercial;
		@AuraEnabled
		public List<Cliente> children;
	}

	public class Cliente {
		@AuraEnabled
		public String id;
		@AuraEnabled
		public String clienteId;
		@AuraEnabled
		public String cliente;
		@AuraEnabled
		public String grupoComercialId;
		@AuraEnabled
		public String grupoComercial;
		@AuraEnabled
		public List<OppSearch> children;

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
		public String probabilidad;
		@AuraEnabled
		public Date dateProFrom;
		@AuraEnabled
		public Date dateProUntil;
		@AuraEnabled
		public Date dateVenFrom;
		@AuraEnabled
		public Date dateVenUntil;
		@AuraEnabled
		public String pais;
		@AuraEnabled
		public String operacion;
		@AuraEnabled
		public List<MultiData> producto;
		@AuraEnabled
		public String modeloAtencion;
		@AuraEnabled
		public Boolean esg;
		@AuraEnabled
		public List<MultiData> participante;
		
	}

	/**
	* @description Object to More filters employee, stage 
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
	public static DataReturn getOpportunities(String datosString, Boolean destacadas,  String filterExpeString, String productName, List<String> listProducts, List<String> filterName, String page, String moreFiltersString){
		String methodName = 'getOpportunities';
		Integer total = 0;
		String owner = UserInfo.getUserId();
		String centroUser = [SELECT AV_Funcion__c, AV_NumeroOficinaEmpresa__c
		FROM User WHERE Id = :UserInfo.getUserId()].AV_NumeroOficinaEmpresa__c;
		String centroU = centroUser.split('-')[1];

		List<OppSearch> listOppSearch = new List<OppSearch>();
		List<OppSearch> listOppSearchGraExp = new List<OppSearch>();
		List<OppSearch> listOppSearchGraPro = new List<OppSearch>();
		List<OppSearch> listOppSearchGraName = new List<OppSearch>();
		List<OppSearch> listSearchAll= new List<OppSearch>();
		List<OppSearch> listOppSearchGC = new List<OppSearch>();
		Map<String, GC> gcMap = new Map<String, GC>();
		Map<String, Cliente> clienteList = new Map<String, Cliente>();
		List<ProductNegocio> filterExpe = new List<ProductNegocio>();
		DataFilter datos = new DataFilter();
		List<String> participanteFilter = new List<String>();
		List<String> employeeFilter = new List<String>();
		List<String> employeeFilterLabel = new List<String>();
		List<String> stageFilter = new List<String>();
		List<String> productoFilter = new List<String>();


		
		Set<String> listRTs = new Set<String>{CIBE_AppConstants.OPP_INICIATIVAEMP_RT,
			CIBE_AppConstants.OPP_ACCIONEMP_RT,
			CIBE_AppConstants.OPP_ALERTAEMP_RT,
			CIBE_AppConstants.OPP_SUGERENCIAEMP_RT};

			Set<String> listRTsDest = new Set<String>{CIBE_AppConstants.OPP_INICIATIVAEMP_RT,
				CIBE_AppConstants.OPP_ACCIONEMP_RT,
				CIBE_AppConstants.OPP_SUGERENCIAEMP_RT};

		Set<String> activas = new Set<String>{CIBE_AppConstants.OPPORTUNITY_STATUS_POTENCIAL,
			CIBE_AppConstants.OPPORTUNITY_STATUS_ENCURSO,
			CIBE_AppConstants.OPPORTUNITY_STATUS_PENDFIRMA};

		String alertComercial = CIBE_AppConstants.OPP_ALERTAEMP_RT;	

		Set<String> statusDestacadas = new Set<String>{CIBE_AppConstants.OPPORTUNITY_STATUS_ENCURSO,CIBE_AppConstants.OPPORTUNITY_STATUS_PENDFIRMA};
		Set<String> statusDestacadasAC = new Set<String>{CIBE_AppConstants.OPPORTUNITY_STATUS_ENCURSO,CIBE_AppConstants.OPPORTUNITY_STATUS_PENDFIRMA, CIBE_AppConstants.OPPORTUNITY_STATUS_POTENCIAL};
		Set<String> statusDestacadasToLabel = new Set<String>{CIBE_AppConstants.OPPORTUNITY_STATUS_ENCURSO,  'Pendiente de firma'};	
		Set<String> statusDestacadasToLabelAC = new Set<String>{CIBE_AppConstants.OPPORTUNITY_STATUS_ENCURSO, CIBE_AppConstants.OPPORTUNITY_STATUS_POTENCIAL,  'Pendiente de firma'};	
		
		String headerQuery = 'SELECT Id, CIBE_ProductName__c, CIBE_GrupoComercial__r.CIBE_GrupoComercial__c,  Account.AV_LastContactDate__c, AV_Center__c,  Amount,  CIBE_NextMeetingDate__c, AV_FechaModificacion__c,  CIBE_GrupoComercial__c, CIBE_GrupoComercial__r.Name,  CIBE_Divisa__c, OwnerId, Owner.Name,  AV_Comentarios__c,  CIBE_ProbabilidadExito__c, CIBE_Pais__c, CIBE_TipoOperacion__c, Account.AV_AttentionModel__c, CIBE_ESG__c,'+
                            ' AccountId, AV_PF__c, RecordType.DeveloperName, Account.Name, CIBE_OpportunityTeam__c, RecordType.Name, Name, AV_PF__r.Name, '+
                            ' TOLABEL(StageName), AV_FechaProximoRecordatorio__c, CloseDate, '+
                            ' AV_PF__r.AV_ExternalId__c';
		String headerCountQuery = 'SELECT COUNT(Id)';
		String countQuery;
		String avQuery = '';
		String avQuery2 = '';
		String avQuery3 = '';

		if (datosString != null) {
			datos = (DataFilter)Json.deserialize(datosString,DataFilter.class);
		}
		String searchQuery = headerQuery +' FROM Opportunity WHERE RecordType.DeveloperName IN :listRTs  AND StageName IN :activas  AND AV_Center__c = :centroU ';

		if(datos != null) {
			if (datos.isDestacada != null && datos.isDestacada) {


				avQuery =' FROM Opportunity WHERE  ((RecordType.DeveloperName IN :listRTsDest  AND StageName IN :statusDestacadas AND  '+
				' ((AV_FechaProximoRecordatorio__c= NEXT_N_DAYS:7 OR AV_FechaProximoRecordatorio__c = TODAY) OR (CloseDate = NEXT_N_DAYS:7 OR CloseDate = TODAY))) OR (Recordtype.DeveloperName = :alertComercial AND StageName IN :statusDestacadasAC)) ';

			}else{
				avQuery =' FROM Opportunity ';
			}
		}
		if (moreFiltersString != null) {
			moreFilters = (DataMoreFilters)Json.deserialize(moreFiltersString,DataMoreFilters.class);
		}
		List<String> todosList =  new List<String>();
		if(moreFilters != null) {
			if (moreFilters.employee != null ) {

				
				
				for (MultiData md : moreFilters.employee) {
					employeeFilter.add(md.id);
					employeeFilterLabel.add(md.label);
				}

				if(employeeFilterLabel[0].contains('TODOS')){
					String todos = string.join(employeeFilter,',');
					List<String> lstTodos = todos.split(',');


					if(datos.isDestacada != null && datos.isDestacada){
						avQuery = avQuery + ' AND OwnerId IN '+AV_AppUtilities.arrayToStringIn(lstTodos);
						
					}else{
						avQuery = avQuery + ' WHERE OwnerId IN '+AV_AppUtilities.arrayToStringIn(lstTodos);
					}
					searchQuery = searchQuery + ' AND OwnerId IN '+AV_AppUtilities.arrayToStringIn(lstTodos);
	
				}else{
					if(datos.isDestacada != null && datos.isDestacada){
						avQuery = avQuery + ' AND OwnerId IN '+AV_AppUtilities.arrayToStringIn(employeeFilter);
						
					}else{
						avQuery = avQuery + ' WHERE OwnerId IN '+AV_AppUtilities.arrayToStringIn(employeeFilter);
					}
					searchQuery = searchQuery + ' AND OwnerId IN '+AV_AppUtilities.arrayToStringIn(employeeFilter);
				}

				

			}

			if (moreFilters.origen != null && moreFilters.origen == 'all') {
				avQuery = avQuery+' AND RecordType.DeveloperName IN :listRTs';
			}else if (moreFilters.origen != null && moreFilters.origen != 'all') {
				avQuery = avQuery+' AND RecordType.DeveloperName = \''+moreFilters.origen+'\'';
			} 

			if (moreFilters.probabilidad != null && moreFilters.probabilidad != 'vacio') {
				avQuery = avQuery+' AND CIBE_ProbabilidadExito__c = \''+moreFilters.probabilidad+'\'';
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
			if (moreFilters.pais != null && moreFilters.pais != 'vacio') {
				avQuery = avQuery+' AND CIBE_Pais__c = \''+moreFilters.pais+'\'';
			}
			if (moreFilters.operacion != null &&  moreFilters.operacion != 'vacio') {
				avQuery = avQuery+' AND CIBE_TipoOperacion__c = \''+moreFilters.operacion+'\'';
			}
			
			if (moreFilters.esg != false ) {
				avQuery = avQuery+' AND CIBE_ESG__c = ' + moreFilters.esg;
			}

			if (moreFilters.stage != null && moreFilters.stage.size() > 0) {
				for (MultiData md : moreFilters.stage) {
					stageFilter.add(md.id);
				}
				
				if(stageFilter.contains('Activas')){
					stageFilter.add('Potencial');
					stageFilter.add('En curso');
					stageFilter.add('Pendiente de firma');
					for (Integer i = 0; i < stageFilter.size(); i++) {
						if(stageFilter[i] == 'Activas'){
							stageFilter.remove(i);
						}
					}
					avQuery = avQuery + ' AND (TOLABEL(StageName) IN :activas OR TOLABEL(StageName) IN '+AV_AppUtilities.arrayToStringIn(stageFilter) + ')';

				}else{
					avQuery = avQuery + ' AND TOLABEL(StageName) IN '+AV_AppUtilities.arrayToStringIn(stageFilter);

				}
			}

			if (moreFilters.producto != null && moreFilters.producto.size() > 0) {
				for (MultiData md : moreFilters.producto) {
					productoFilter.add(md.id);
				}
				avQuery = avQuery + ' AND AV_PF__c IN '+AV_AppUtilities.arrayToStringIn(productoFilter);
			}

			if (moreFilters.modeloAtencion != null && moreFilters.modeloAtencion != 'vacio') {
				avQuery = avQuery + ' AND Account.AV_AttentionModel__c  = \''+moreFilters.modeloAtencion+'\'';
			}

			if (moreFilters.oficina != null ) {
				String oficina2 = moreFilters.oficina;
				avQuery = avQuery + ' AND AV_Center__c  = \''+moreFilters.oficina+'\'';
			}
			
			

			if (moreFilters.participante != null && moreFilters.participante.size() > 0) {
				for (MultiData md : moreFilters.participante) {
					participanteFilter.add(md.id);
				}
				avQuery = avQuery + ' AND CIBE_OpportunityTeam__c LIKE :participanteFilter';
			}

			
		}
		
		if(datos != null) {
			if (datos.isPendienteFirma != null && datos.isPendienteFirma) {
				avQuery = avQuery+' AND StageName = \'CIBE_Pendiente_Firma\'';
			}
			if (datos.isPrio != null && datos.isPrio) {
				avQuery = avQuery+' AND Name Like \'PRIO-' + '%\'';
			}
		}
		
		if (filterName != null && filterName.size() > 0) {
			avQuery = avQuery+' AND Name in '+AV_AppUtilities.listToStringIn(filterName);
			searchQuery = searchQuery+' AND Name in '+AV_AppUtilities.listToStringIn(filterName);
		}
		if (productName != null) {
			avQuery = avQuery+' AND AV_PF__r.Name = \''+productName+'\'';
			searchQuery = searchQuery+' AND AV_PF__r.Name = \''+productName+'\'';
		} else if (listProducts != null && listProducts.size() > 0) {
			avQuery = avQuery+' AND AV_PF__r.AV_ExternalId__c in '+AV_AppUtilities.listToStringIn(listProducts);
			searchQuery = searchQuery+' AND AV_PF__r.AV_ExternalId__c in '+AV_AppUtilities.listToStringIn(listProducts);
		}
		Map<String,List<String>> mapNegocioProducts = new Map<String,List<String>>();
		List<String> listNulls = new List<String>();

		if (filterExpeString != null) {
			filterExpe = (List<ProductNegocio>)Json.deserialize(filterExpeString,List<ProductNegocio>.class);

			if (filterExpe != null && !filterExpe.isEmpty()) {
				for (ProductNegocio pn : filterExpe) {
					if (mapNegocioProducts.containsKey(pn.negocio) && pn.negocio != null && pn.product != null) {
						mapNegocioProducts.get(pn.negocio).add(pn.product);
					} else if (pn.product != null) {
						mapNegocioProducts.put(pn.negocio, new List<String> {pn.product});
					} 
				}
				if (mapNegocioProducts != null && !mapNegocioProducts.isEmpty()) {
					avQuery = avQuery+' AND (';
					searchQuery = searchQuery+' AND (';
					if (listNulls != null && !listNulls.isEmpty()) {
						avQuery = avQuery+' Id in '+AV_AppUtilities.listToStringIn(listNulls)+' OR';
						searchQuery = searchQuery+' Id in '+AV_AppUtilities.listToStringIn(listNulls)+' OR';
					}
					Integer cont = 1;
					Integer max = mapNegocioProducts.keySet().size();
					for (String negocio : mapNegocioProducts.keySet()) {
						if(cont == max) {
							avQuery = avQuery+' ( AV_PF__c in '+AV_AppUtilities.listToStringIn(mapNegocioProducts.get(negocio))+'))';
							searchQuery = searchQuery+' ( AV_PF__c in '+AV_AppUtilities.listToStringIn(mapNegocioProducts.get(negocio))+'))';
						} else {
							avQuery = avQuery+' ( AV_PF__c in '+AV_AppUtilities.listToStringIn(mapNegocioProducts.get(negocio))+') OR';
							searchQuery = searchQuery+' ( AV_PF__c in '+AV_AppUtilities.listToStringIn(mapNegocioProducts.get(negocio))+') OR';
						}
						cont++;
					}
				}
			} 
		}

		countQuery = headerCountQuery+' '+avQuery;
		String orderQuery = headerQuery+' '+avQuery;
		if(datos != null) {

			if (datos.orderBy != null && datos.orderBy != '' && datos.orderingCriterion != null && datos.orderBy != 'CIBE_GrupoComercial__r.CIBE_GrupoComercial__c') {
				avQuery3 = avQuery+' ORDER BY CIBE_GrupoComercial__r.CIBE_GrupoComercial__c ASC NULLS LAST ,' +datos.orderBy+' '+datos.orderingCriterion+' NULLS LAST';
				avQuery = avQuery+' ORDER BY '+datos.orderBy+' '+datos.orderingCriterion+' NULLS LAST';
			}else if(datos.orderBy != null && datos.orderBy != '' && datos.orderingCriterion != null && datos.orderBy == 'CIBE_GrupoComercial__r.CIBE_GrupoComercial__c'){
				avQuery3 = avQuery+' ORDER BY '+datos.orderBy+' '+datos.orderingCriterion+' NULLS LAST';
				avQuery = avQuery+' ORDER BY '+datos.orderBy+' '+datos.orderingCriterion+' NULLS LAST';
			}

			else{
				avQuery3 = avQuery;
			}

		}

		




		AV_LogDebug.printLogDebug(methodName, '-----> Query to execute: ' + avQuery);
		total = '1'.equals(page) ? getCapsulateCountQuery(countQuery) : -1;
		avQuery = headerQuery + avQuery;
		avQuery3 = headerQuery + avQuery3;
		List<Opportunity> listOpp = capsulateQuery(avQuery);
		List<Opportunity> listSearch = capsulateQuery(searchQuery);
		List<Opportunity> listSearchGC = capsulateQuery(avQuery3);
		Set<String> accountId = new Set<String>();
		if (listSearch != null && !listSearch.isEmpty()) {
			for (Opportunity opp : listSearch) {

				OppSearch oppSearch = assignOpp(opp);
				listSearchAll.add(oppSearch);
				Boolean booleanPro = true;
				Boolean booleanExp = true;
				Boolean booleanName = true;
				if(moreFilters != null) {

					if((moreFilters.origen != null && moreFilters.origen != 'all' && moreFilters.origen != opp.RecordType.DeveloperName)
					|| (moreFilters.probabilidad != null && moreFilters.probabilidad != 'vacio' && moreFilters.probabilidad != opp.CIBE_ProbabilidadExito__c)
					|| (moreFilters.oficina != null && moreFilters.oficina != opp.AV_Center__c)
					|| (moreFilters.dateProFrom != null && (opp.AV_FechaProximoRecordatorio__c == null || !(datetime.newInstance(opp.AV_FechaProximoRecordatorio__c.year(), opp.AV_FechaProximoRecordatorio__c.month(), opp.AV_FechaProximoRecordatorio__c.day()) >= datetime.newInstance(moreFilters.dateProFrom.year(), moreFilters.dateProFrom.month(), moreFilters.dateProFrom.day()))))
					|| (moreFilters.dateProUntil != null && (opp.AV_FechaProximoRecordatorio__c == null || !(datetime.newInstance(opp.AV_FechaProximoRecordatorio__c.year(), opp.AV_FechaProximoRecordatorio__c.month(), opp.AV_FechaProximoRecordatorio__c.day()) <= datetime.newInstance(moreFilters.dateProUntil.year(), moreFilters.dateProUntil.month(), moreFilters.dateProUntil.day()))))
					|| (moreFilters.dateVenFrom != null && (opp.CloseDate == null || !(datetime.newInstance(opp.CloseDate.year(), opp.CloseDate.month(), opp.CloseDate.day()) >= datetime.newInstance(moreFilters.dateVenFrom.year(), moreFilters.dateVenFrom.month(), moreFilters.dateVenFrom.day()))))
					|| (moreFilters.dateVenUntil != null && (opp.CloseDate == null || !(datetime.newInstance(opp.CloseDate.year(), opp.CloseDate.month(), opp.CloseDate.day()) <= datetime.newInstance(moreFilters.dateVenUntil.year(), moreFilters.dateVenUntil.month(), moreFilters.dateVenUntil.day()))))
					|| (moreFilters.pais != null && moreFilters.pais != 'vacio' && moreFilters.pais != opp.CIBE_Pais__c)
					|| (moreFilters.operacion != null && moreFilters.operacion != 'vacio' && moreFilters.operacion != opp.CIBE_TipoOperacion__c)
					|| (moreFilters.stage != null && moreFilters.stage.size() > 0 && !stageFilter.contains(opp.StageName))
					|| (moreFilters.producto != null && moreFilters.producto.size() > 0 && !productoFilter.contains(opp.AV_PF__c))
					|| (moreFilters.modeloAtencion != null && moreFilters.modeloAtencion != 'vacio' && moreFilters.modeloAtencion != opp.Account.AV_AttentionModel__c)
					|| (moreFilters.esg != false && moreFilters.esg != opp.CIBE_ESG__c )){
						booleanPro = false;
						booleanExp = false;
						booleanName = false;
					}

				if (moreFilters.participante != null &&  moreFilters.participante.size() > 0 ) {
					List<String> strList = new List<String>();
					if(oppSearch.equipoOpp != null){
						strList = oppSearch.equipoOpp.split(',');		
					}

					for (String variable : participanteFilter) {
						if(!strList.contains(variable)){
							booleanPro = false;
							booleanExp = false;
							booleanName = false;
						}
					}
					
				}

				}
				if (filterName != null && filterName.size() > 0 && !filterName.contains(opp.Name)) {
					booleanPro = false;
					booleanExp = false;
				}

				if ((productName != null && opp.AV_PF__r.Name != productName )|| (listProducts != null && listProducts.size() > 0 && !listProducts.contains(opp.AV_PF__r.AV_ExternalId__c))) {
					booleanExp = false;
					booleanName = false;
				}
				if (opp.AV_PF__c == null) {
					booleanPro = false;
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
			Set<String> test = new Set<String>();

			for (Opportunity opp : listOpp) {
				OppSearch oppSearch = assignOpp(opp);
				if(opp.OwnerId == owner && opp.AV_Center__c == centroU && 
				((listRTsDest.contains(opp.RecordType.DeveloperName) && (statusDestacadasToLabel.contains(opp.StageName)) && ((opp.AV_FechaProximoRecordatorio__c >= System.today() && opp.AV_FechaProximoRecordatorio__c <= System.today().addDays(7)) || (opp.CloseDate >= System.today() && opp.CloseDate <= System.today().addDays(7) )  )) || (opp.RecordType.DeveloperName == 'CIBE_AlertaComercialEMP' && statusDestacadasToLabelAC.contains(opp.StageName)))  ){
					oppSearch.destacadaIcon = 'action:priority';
					oppSearch.iconClass ='slds-icon-custom-custom16 slds-icon_container slds-var-p-top_xx-small slds-var-p-bottom_xx-small';
				}else{
					oppSearch.iconClass ='';
					oppSearch.destacadaIcon = '';
				}
				listOppSearch.add(oppSearch);
			}

		}
		


		if (listSearchGC != null && !listSearchGC.isEmpty()) {
			Set<String> test = new Set<String>();

			
			for (Opportunity opp : listSearchGC) {
				if(opp.CIBE_GrupoComercial__c != null){
					OppSearch oppSearch = assignOpp(opp);
					listOppSearchGC.add(oppSearch);
				}
			}


			Map<String, Map<String, List<OppSearch>>> mapaGroup = new Map<String, Map<String, List<OppSearch>>>();
			Map<String, Map<String, List<OppSearch>>> mapaGroup2 = new Map<String, Map<String, List<OppSearch>>>();
			Map<String, String> mapGC = new Map<String, String>();
			Map<String, String> mapCliente = new Map<String, String>();

			for (OppSearch opp : listOppSearchGC) {
				if(opp.grupoComercial != null){

					mapGC.put(opp.grupoComercialId, opp.grupoComercial);
					mapCliente.put(opp.clienteId, opp.cliente);

				
					if(mapaGroup.containsKey(opp.grupoComercialId)){
						if(mapaGroup.get(opp.grupoComercialId).containsKey(opp.clienteId)){
							mapaGroup.get(opp.grupoComercialId).get(opp.clienteId).add(opp);
						}else{
							mapaGroup.get(opp.grupoComercialId).put(opp.clienteId, new List<OppSearch>{opp});
						}
					}else{
						mapaGroup.put(opp.grupoComercialId, new Map<String, List<OppSearch>>{opp.clienteId => new List<OppSearch>{opp}});

					}
					
				}
			}

			String aux;



			for (String grupoC : mapGC.keySet()) {

				if(aux != null && ((datos.orderBy == 'CIBE_GrupoComercial__r.CIBE_GrupoComercial__c' &&  ((mapGC.get(grupoC) < mapGC.get(aux) && datos.orderingCriterion == 'ASC') ||  (mapGC.get(grupoC) > mapGC.get(aux) && datos.orderingCriterion == 'DESC' ) )))){
					if(mapaGroup2 != null){
						Map<String, Map<String, List<OppSearch>>> mapaGroup3 = new Map<String, Map<String, List<OppSearch>>>();
						mapaGroup3.put(grupoC, mapaGroup.get(grupoC));
						mapaGroup3.putAll(mapaGroup2);
						mapaGroup2 = mapaGroup3;
					}else{
						mapaGroup2.put(grupoC, mapaGroup.get(grupoC));
					}
				}else{
					mapaGroup2.put(grupoC, mapaGroup.get(grupoC));
					aux = grupoC;
				}

			}

			for (String idGrupoComercial : mapaGroup2.keySet()) {
				if(mapaGroup.get(idGrupoComercial) != null){
					for (String idCliente : mapaGroup.get(idGrupoComercial).keySet()) {
						if(mapaGroup.get(idGrupoComercial).get(idCliente) != null && !mapaGroup.get(idGrupoComercial).get(idCliente).isEmpty()){

								Cliente client = new Cliente();
								client.id = '' + Integer.valueof((Math.random() * 1000)) + '';
								client.cliente = mapCliente.get(idCliente);
								client.clienteId = idCliente;
								client.grupoComercial = mapGC.get(idGrupoComercial);
								client.grupoComercialId = idGrupoComercial;
								client.children = mapaGroup.get(idGrupoComercial).get(idCliente);


								if(gcMap.containsKey(idGrupoComercial)){

									gcMap.get(idGrupoComercial).children.add(client);

								}else{

									GC grupo = new GC();
									grupo.id = '' + Integer.valueof((Math.random() * 1000)) + '';
									grupo.grupoComercial = mapGC.get(idGrupoComercial);
									grupo.grupoComercialId = idGrupoComercial;
									grupo.children = new List<Cliente>{client};
									gcMap.put(idGrupoComercial, grupo);

								}
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
		datareturn.grupo = gcMap;
		return datareturn;
	}
		

	/**
	* @description      	Method to pass qualityClouds with query string
	* @param q				string with query
	* @return          	 	List of Opportunities
	*/
	private static List<Opportunity> capsulateQuery(String q){
		String owner = UserInfo.getUserId();
		Set<String> activas = new Set<String>{CIBE_AppConstants.OPPORTUNITY_STATUS_POTENCIAL,
			CIBE_AppConstants.OPPORTUNITY_STATUS_ENCURSO,
			CIBE_AppConstants.OPPORTUNITY_STATUS_PENDFIRMA};		
		String enCurso = CIBE_AppConstants.OPPORTUNITY_STATUS_ENCURSO;
		String pendienteFirma = CIBE_AppConstants.OPPORTUNITY_STATUS_PENDFIRMA;
		Set<String> statusDestacadas = new Set<String>{CIBE_AppConstants.OPPORTUNITY_STATUS_ENCURSO,CIBE_AppConstants.OPPORTUNITY_STATUS_PENDFIRMA};
		Set<String> statusDestacadasAC = new Set<String>{CIBE_AppConstants.OPPORTUNITY_STATUS_ENCURSO,CIBE_AppConstants.OPPORTUNITY_STATUS_PENDFIRMA, CIBE_AppConstants.OPPORTUNITY_STATUS_POTENCIAL};
		Set<String> listRTs = new Set<String>{CIBE_AppConstants.OPP_INICIATIVAEMP_RT,
			CIBE_AppConstants.OPP_ACCIONEMP_RT,
			CIBE_AppConstants.OPP_ALERTAEMP_RT,
			CIBE_AppConstants.OPP_SUGERENCIAEMP_RT};
			Set<String> listRTsDest = new Set<String>{CIBE_AppConstants.OPP_INICIATIVAEMP_RT,
				CIBE_AppConstants.OPP_ACCIONEMP_RT,
				CIBE_AppConstants.OPP_SUGERENCIAEMP_RT};
		String alertComercial = CIBE_AppConstants.OPP_ALERTAEMP_RT;	

		if (moreFilters.participante != null && moreFilters.participante.size() > 0) {
			List<String> participanteFilter = new List<String>();
			for (MultiData md : moreFilters.participante) {
				participanteFilter.add('%' + md.id + '%');
			}
		}
		String centroUser = [SELECT AV_Funcion__c, AV_NumeroOficinaEmpresa__c
		FROM User WHERE Id = :UserInfo.getUserId()].AV_NumeroOficinaEmpresa__c;
		String centroU = centroUser.split('-')[1];
	

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
	private static List<AggregateResult> capsulateCountQuery(String q){
		String owner = UserInfo.getUserId();
		Set<String> activas = new Set<String>{CIBE_AppConstants.OPPORTUNITY_STATUS_POTENCIAL,
			CIBE_AppConstants.OPPORTUNITY_STATUS_ENCURSO,
			CIBE_AppConstants.OPPORTUNITY_STATUS_PENDFIRMA};	
			Set<String> statusDestacadas = new Set<String>{CIBE_AppConstants.OPPORTUNITY_STATUS_ENCURSO,CIBE_AppConstants.OPPORTUNITY_STATUS_PENDFIRMA};
	
			Set<String> statusDestacadasAC = new Set<String>{CIBE_AppConstants.OPPORTUNITY_STATUS_ENCURSO,CIBE_AppConstants.OPPORTUNITY_STATUS_PENDFIRMA, CIBE_AppConstants.OPPORTUNITY_STATUS_POTENCIAL};

		String enCurso = CIBE_AppConstants.OPPORTUNITY_STATUS_ENCURSO;
		String pendienteFirma = CIBE_AppConstants.OPPORTUNITY_STATUS_PENDFIRMA;
		Set<String> listRTs = new Set<String>{CIBE_AppConstants.OPP_INICIATIVAEMP_RT,
			CIBE_AppConstants.OPP_ACCIONEMP_RT,
			CIBE_AppConstants.OPP_ALERTAEMP_RT,
			CIBE_AppConstants.OPP_SUGERENCIAEMP_RT};
			Set<String> listRTsDest = new Set<String>{CIBE_AppConstants.OPP_INICIATIVAEMP_RT,
				CIBE_AppConstants.OPP_ACCIONEMP_RT,
				CIBE_AppConstants.OPP_SUGERENCIAEMP_RT};
		
		String alertComercial = CIBE_AppConstants.OPP_ALERTAEMP_RT;	

					
		if (moreFilters.participante != null && moreFilters.participante.size() > 0) {
			for (MultiData md : moreFilters.participante) {
				participanteFilter.add('%' + md.id + '%');
			}
		}	
		String centroUser = [SELECT AV_Funcion__c, AV_NumeroOficinaEmpresa__c
		FROM User WHERE Id = :UserInfo.getUserId()].AV_NumeroOficinaEmpresa__c;
		String centroU = centroUser.split('-')[1];

		
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
		@AuraEnabled
		public String familia;
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
		List<String> listProduct = new List<String>();
		List<String> listProduct2 = new List<String>();
		Set<String> productoFicha = new Set<String>();
		Map<String, Map<String,String>> listProductMap = new Map<String, Map<String,String>>();

		if(listOpp != null && listOppExp != null && !listOppExp.isEmpty() && !listOpp.isEmpty()) {
			List<String> listProductNegocio = new List<String>();
			Map<String,Integer> mapProductNegocioNum = new Map<String,Integer>();
			Map<String,String> mapNegocio = new Map<String,String>();
			for (Map<String,String> opp : listOpp) {
				if ( opp.get('productoIdSales') != null ) {
					
					listProduct.add(opp.get('productoIdSales'));
					listProductMap.put(opp.get('productoIdSales'), opp);

					mapNegocio.put(opp.get('negocio')+'_'+opp.get('productoId'),opp.get('negocio'));
					if (mapProductNegocioNum.containsKey(opp.get('productoIdSales'))) {
						mapProductNegocioNum.put(opp.get('productoIdSales'),mapProductNegocioNum.get(opp.get('productoIdSales'))+1);
					} else {
						mapProductNegocioNum.put(opp.get('productoIdSales'),1);
					}


					
				}
			}
			List<String> listProductNegocio2 = new List<String>();
			Map<String,Integer> mapProductNegocioNum2 = new Map<String,Integer>();
			Map<String,String> mapNegocio2 = new Map<String,String>();
			Map<String,String> mapProduct = new Map<String,String>();
			for (Map<String,String> opp : listOppExp) {
				if ( opp.get('productoIdSales') != null ) {
					
					listProductNegocio2.add(opp.get('negocio')+'_'+opp.get('productoId'));
					listProduct2.add(opp.get('productoIdSales'));
					mapNegocio2.put(opp.get('negocio')+'_'+opp.get('productoId'),opp.get('negocio'));
					mapProduct.put(opp.get('negocio')+'_'+opp.get('productoId'),opp.get('productoIdSales'));
					if (mapProductNegocioNum2.containsKey(opp.get('negocio')+'_'+opp.get('productoId'))) {
						mapProductNegocioNum2.put(opp.get('productoIdSales'),mapProductNegocioNum.get(opp.get('productoIdSales'))+1);
					} else {
						mapProductNegocioNum2.put(opp.get('productoIdSales'),1);
					}
					
				} 
			}

			List<String> externalsProductExpe = new List<String>();
			if (listProduct != null && listProduct2 != null  && !listProduct2.isEmpty() && !listProduct.isEmpty() ) {
				List<AV_ProductExperience__c> listProExp = [SELECT AV_ExperienciaNegocio__r.AV_DescTipoExperiencia__c, AV_ProductoFicha__c, AV_ExternalID__c 
				FROM AV_ProductExperience__c 
				WHERE AV_ExperienciaNegocio__r.AV_Negocio__c = 'EMP'
				AND  AV_ProductoFicha__c IN :listProduct  ];


				if (listProExp != null && !listProExp.isEmpty()) {
					Map<String,Integer> mapExpeNum = new Map<String,Integer>();
					Map<String,List<ProductNegocio>> mapExpePro = new Map<String,List<ProductNegocio>>();
					List<String> listIdDuple = new List<String>();
					Map<String,List<ProductNegocio>> mapExpePro2 = new Map<String,List<ProductNegocio>>();



					for (AV_ProductExperience__c pe : listProExp) {
						productoFicha.add(pe.AV_ProductoFicha__c);
						
						if(listProduct.contains(pe.AV_ProductoFicha__c) && pe.AV_ExternalID__c.startsWith('EMP_')) {
							if (mapExpeNum.containsKey(pe.AV_ExperienciaNegocio__r.AV_DescTipoExperiencia__c)) {

								mapExpeNum.put(pe.AV_ExperienciaNegocio__r.AV_DescTipoExperiencia__c,mapExpeNum.get(pe.AV_ExperienciaNegocio__r.AV_DescTipoExperiencia__c)+mapProductNegocioNum.get(pe.AV_ProductoFicha__c));
							} else {

								mapExpeNum.put(pe.AV_ExperienciaNegocio__r.AV_DescTipoExperiencia__c,mapProductNegocioNum.get(pe.AV_ProductoFicha__c));
							}
							ProductNegocio pn = new ProductNegocio();
							pn.product = pe.AV_ProductoFicha__c;
							pn.negocio = 'EMP';
							
							if (mapExpePro.containsKey(pe.AV_ExperienciaNegocio__r.AV_DescTipoExperiencia__c)) {
								mapExpePro.get(pe.AV_ExperienciaNegocio__r.AV_DescTipoExperiencia__c).add(pn);
							} else {
								mapExpePro.put(pe.AV_ExperienciaNegocio__r.AV_DescTipoExperiencia__c, new List<ProductNegocio> {pn});
							}
						}
						if(listProduct2.contains(pe.AV_ProductoFicha__c)) {
							ProductNegocio pn = new ProductNegocio();
							pn.product = pe.AV_ProductoFicha__c;
							pn.negocio = 'EMP';
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
								for (ProductNegocio prod : dataChart.listProduct) {
									prod.familia = name;
								}
								listDataChart.add(dataChart);
							}
						}

					}


				}
				
			}


			for (Map<String,String> opp : listOpp) {
				if(!productoFicha.contains(opp.get('productoIdSales'))){
					ProductNegocio pn = new ProductNegocio();
					pn.product = opp.get('productoIdSales');
					pn.negocio =  opp.get('productoIdSales');
					listProSinExp.add(pn);
					numSinExp++;
				}
			}


			if (numSinExp > 0) {
				DataCharts dataChart = new DataCharts();
				dataChart.label = 'Sin experiencia';
				dataChart.value = numSinExp;
				dataChart.listProduct = listProSinExp;
				for (ProductNegocio prod : dataChart.listProduct) {
					prod.familia = 'Sin experiencia';
				}
				listDataChart.add(dataChart);
			}
		}
		return listDataChart;
	}
    
     public class OptionsField {
        @AuraEnabled
        public String label {get;set;}
        @AuraEnabled
        public String value {get;set;}
    }

    
	@AuraEnabled(cacheable=true) 
    public static List<OptionsField> getPaises() {
        List<OptionsField> selectOptions = new List<OptionsField>();

        Schema.DescribeFieldResult objFieldDescribe = Opportunity.CIBE_Pais__c.getDescribe();
        List<Schema.PicklistEntry> lstPickListValues = objFieldDescribe.getPickListValues();

		OptionsField opFieldVacio= new OptionsField();
		opFieldVacio.value='vacio';
		opFieldVacio.label='';
		selectOptions.add(opFieldVacio);

        for (Schema.PicklistEntry objPickList : lstPickListValues) {
            OptionsField opField= new OptionsField();
            opField.value=objPickList.getValue();
            opField.label=objPickList.getLabel();
            selectOptions.add(opField);
        }
        return selectOptions;
    }
    
    @AuraEnabled(cacheable=true) 
    public static List<OptionsField> getTipoOperacion() {
        List<OptionsField> selectOptions = new List<OptionsField>();

        Schema.DescribeFieldResult objFieldDescribe = Opportunity.CIBE_TipoOperacion__c.getDescribe();
        List<Schema.PicklistEntry> lstPickListValues = objFieldDescribe.getPickListValues();

        for (Schema.PicklistEntry objPickList : lstPickListValues) {
            OptionsField opField= new OptionsField();
            opField.value=objPickList.getValue();
            opField.label=objPickList.getLabel();
            selectOptions.add(opField);
        }
		OptionsField opFieldVacio= new OptionsField();
		opFieldVacio.value='vacio';
		opFieldVacio.label='';
		selectOptions.add(opFieldVacio);
        return selectOptions;
    }

	private static List<OpportunityTeamMember> capsulateQueryTM(String q){//Método para pasar qualityClouds
		return (List<OpportunityTeamMember>) Database.query(q);
	}

	@AuraEnabled(cacheable=true)
	public static List<AV_LookupSearchResult> searchParticipe(String searchTerm, List<String> selectedIds,String numOficina) {
		String methodName = 'searchParticipe';
		List<AV_LookupSearchResult> results = new List<AV_LookupSearchResult>();
		List<List<SObject>> searchResults = new List<List<SObject>>();

		String query = 'SELECT Id, Name, OpportunityId, UserId, User.name, CIBE_Centro__c';

		if(!selectedIds.isEmpty()){
			query = query + ' FROM OpportunityTeamMember WHERE UserId NOT IN'+  AV_AppUtilities.arrayToStringIn(selectedIds) + ' AND name  LIKE \'%'+searchTerm+'%\'';
		}else{
			query = query +  ' FROM OpportunityTeamMember WHERE  name  LIKE \'%'+searchTerm+'%\'';
		}

		
		List<OpportunityTeamMember> queryteamMembers = new List<OpportunityTeamMember>();
		List<OpportunityTeamMember> teamMembers = new List<OpportunityTeamMember>();
		Set<Id> setOtm = new Set<Id>();
		queryteamMembers =capsulateQueryTM(query);

		for(OpportunityTeamMember q:queryteamMembers){
			if(!setOtm.contains(q.UserId)){
				setOtm.add(q.UserId);
				teamMembers.add(q);
			}
		}
		String productIcon = 'standard:user';
		for (OpportunityTeamMember p : teamMembers) {
			results.add(
				new AV_LookupSearchResult(
					p.id,
					'OpportunityTeamMember',
					productIcon,
					p.Name,
					p.UserId
				)
			);
		}
		results.sort();

		return results;
	}

	@AuraEnabled
    public static List<AV_LookupSearchResult> searchProduct(String searchTerm) {
        String methodName = 'searchProduct';
        Integer maxResults = 10;
        searchTerm += '*';
        List<AV_LookupSearchResult> results = new List<AV_LookupSearchResult>();
        List<List<SObject>> searchResults = new List<List<SObject>>();

        Set<String> pfEMP  = new Set<String>();

        List<AV_ProductExperience__c> productosEMP = [SELECT Id, AV_ProductoFicha__c, AV_ProductoFicha__r.Name, AV_ExternalID__c  FROM AV_ProductExperience__c
                                                        WHERE AV_ExternalID__c  LIKE 'EMP%' AND  AV_ProductoFicha__r.AV_Nivel__c = null and AV_ProductoFicha__r.AV_ExternalID__c != null];

        if(!productosEMP.isEmpty()){
            for (AV_ProductExperience__c pEMP : productosEMP) {
                pfEMP.add(pEMP.AV_ProductoFicha__c);
            }
        }


        searchResults = [
            FIND :searchTerm
            IN ALL FIELDS
            RETURNING
            Product2(Id, Name, AV_ExternalID__c WHERE Id IN :pfEMP)
            LIMIT :maxResults
        ];

        String productIcon = 'standard:product';
        Product2[] listProduct = (List<Product2>) searchResults[0];
        for (Product2 p : listProduct) {
            results.add(
                new AV_LookupSearchResult(
                    p.Id,'Product2',productIcon,p.Name,'Codigo • ' + p.AV_ExternalID__c
                )
            );
        }
        results.sort();
        return results;
    }


	@AuraEnabled
	public static OppSearch assignOpp(Opportunity opp){

			OppSearch oppSearch = new OppSearch();
			oppSearch.cliente = opp.Account.Name != null ?  opp.Account.Name : null;
			oppSearch.esg = opp.CIBE_ESG__c;
			oppSearch.probabilidad = opp.CIBE_ProbabilidadExito__c;
			oppSearch.divisa = opp.CIBE_Divisa__c;
			oppSearch.origen = opp.RecordType.Name;
			oppSearch.clienteId = opp.AccountId != null ? '/'+opp.AccountId : null;
			oppSearch.nombre = opp.Name;
			oppSearch.oppId = '/'+opp.Id;
			oppSearch.producto = opp.CIBE_ProductName__c;
			oppSearch.productoId = opp.AV_PF__r.AV_ExternalId__c;
			oppSearch.productoIdSales = opp.AV_PF__c;
			oppSearch.estado = opp.StageName;
			oppSearch.propietarioId = '/'+opp.OwnerId;
			oppSearch.propietario = opp.Owner.Name;
			oppSearch.comentario = opp.AV_Comentarios__c;
			oppSearch.grupoComercialId = opp.CIBE_GrupoComercial__c != null ? '/'+opp.CIBE_GrupoComercial__c : null;
			oppSearch.grupoComercial = opp.CIBE_GrupoComercial__r.Name != null ? opp.CIBE_GrupoComercial__r.Name : null ;
			oppSearch.fechaUltContactCliente = opp.Account.AV_LastContactDate__c;
			oppSearch.importe = opp.Amount != null ? Integer.valueOf(opp.Amount.round(RoundingMode.HALF_UP)).format() : '';
			oppSearch.idProduct = '/'+opp.AV_PF__c;
			oppSearch.equipoOpp = opp.CIBE_OpportunityTeam__c;
			

			oppSearch.fechaProxG = (opp.AV_FechaProximoRecordatorio__c != null) ? opp.AV_FechaProximoRecordatorio__c.format() : null;

			oppSearch.fechaproxCi = (opp.CIBE_NextMeetingDate__c != null) ? opp.CIBE_NextMeetingDate__c.format() : null;

			oppSearch.fechaUltimaG = (opp.AV_FechaModificacion__c != null) ? opp.AV_FechaModificacion__c.format() : null;

			oppSearch.fechaCie = (opp.CloseDate != null) ? opp.CloseDate.format() : null;	

			return oppSearch;

	}

}