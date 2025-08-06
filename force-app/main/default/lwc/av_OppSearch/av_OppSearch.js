import { LightningElement,track,wire,api} from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getOpportunities from '@salesforce/apex/AV_OppSearch_Controller.getOpportunities';
import getDataToChart from '@salesforce/apex/AV_OppSearch_Controller.getDataToChart';
import nameContactAssign from '@salesforce/apex/AV_MassReassignOwner_Controller.nameContactAssign';
import assign from '@salesforce/apex/AV_MassReassignOwnerOppsBPR_Controller.assign';
import lookupSearch from '@salesforce/apex/AV_MassReassignOwner_Controller.search';
import { loadScript } from 'lightning/platformResourceLoader';
import chartjs from '@salesforce/resourceUrl/AV_ChartJsV391';
import charttreemapjs from '@salesforce/resourceUrl/AV_ChartTreeMap';
import { CurrentPageReference, NavigationMixin } from 'lightning/navigation';
import lookupSearchOffice from '@salesforce/apex/AV_OppSearch_Controller.searchOffice';
import { getRecord } from 'lightning/uiRecordApi';
import USER_ID from '@salesforce/user/Id';
import NAME_FIELD from'@salesforce/schema/User.Name';
import FUNCTION from '@salesforce/schema/User.AV_Funcion__c';
import OFICINA from '@salesforce/schema/User.AV_NumeroOficinaEmpresa__c';
import getEmployees from '@salesforce/apex/AV_OppSearch_Controller.getEmployees';
import optionsIndicador from '@salesforce/apex/AV_MassReassignOwnerOpps_Controller.getIndicadorCliOptions';
import recordLimitLabel from '@salesforce/label/c.AV_BuscadorRecordLimit';
import getTypesOptions from '@salesforce/apex/AV_OppSearch_Controller.getTypesOptions';
import enanchedGetUserInfo from '@salesforce/apex/AV_OppSearch_Controller.enanchedGetUserInfo';
import AV_NotAssigned from '@salesforce/label/c.AV_NotAssigned';


const COOKIESKEY = 'searcherFilterStorage';
const LIMITTIMESTORAGECLEAM = (24*60*60*1000);
const TIMELIMITKEY = 'timelimitkey';
export default class Av_OppSearch extends NavigationMixin(LightningElement) {
	columnsDataBasic = [
		{ label: ' ', fieldName: 'destacada', type: 'button-icon', fixedWidth: 20, typeAttributes: {iconName: { fieldName: 'destacadaIcon'},alternativeText: 'Destacada', variant: 'bare-inverse', iconClass:{ fieldName: 'iconClass'}}, hideDefaultActions: true},
		{ label: 'Potencialidad Cliente', fieldName: 'startClient', type:'text', initialWidth: 99, cellAttributes:{ style: { fieldName: 'startClientCSS' }}, hideDefaultActions: true},
		{ label: 'Cliente', fieldName: 'clienteId', type:'url', initialWidth: 185, typeAttributes: {label: { fieldName: 'cliente'},tooltip:{fieldName:'cliente'}}, hideDefaultActions: true},
		{ label: 'Origen', fieldName: 'origen', type: 'Text', initialWidth: 111, hideDefaultActions: true},
		{ label: 'Potencialidad Oportunidad', fieldName: 'startOpp', type:'text', initialWidth: 99, cellAttributes:{ style: { fieldName: 'startOppCSS' }}, hideDefaultActions: true},
		{ label: 'Producto', fieldName: 'producto', type: 'text', initialWidth: 120, hideDefaultActions: true},
		{ label: 'Nombre de la Oportunidad', fieldName: 'oppId', type: 'url', initialWidth: 192, typeAttributes: {label: { fieldName: 'nombre'},tooltip:{fieldName:'nombre'}}, hideDefaultActions: true},
		{ label: 'Tipo', fieldName: 'tipo', type: 'text', wrapText: true, initialWidth: 277, hideDefaultActions: true},
		{ label: 'Estado', fieldName: 'estado', type: 'text', initialWidth: 99, hideDefaultActions: true},
		{ label: 'Último Comentario', fieldName: 'comentario', type: 'comentario', initialWidth: 277, typeAttributes:{texto:{fieldName:'comentario'}, tooltip:{fieldName:'comentarioMore'}, isTooltip: {fieldName:'isComentarioMore'}}, hideDefaultActions: true, wrapText:true},
		{ label: 'Próxima gestión', fieldName: 'fechaPro', type: 'text',initialWidth: 92, cellAttributes: { alignment: 'right' }, hideDefaultActions: true},
		{ label: 'Canal', fieldName: 'channel', type: 'text', hideDefaultActions: true},
		{ label: 'Último contacto', fieldName: 'lastContact', type: 'text', initialWidth: 92, cellAttributes: { alignment: 'right' }, hideDefaultActions: true},
		{ label: 'Vencimiento', fieldName: 'fechaCie', type: 'text', initialWidth: 92, cellAttributes: { alignment: 'right' }, hideDefaultActions: true},
		{ label: 'Edad', fieldName: 'edad', type: 'number', initialWidth: 50, cellAttributes: { alignment: 'center' }, hideDefaultActions: true},
		{ label: 'Preconcedido', fieldName: 'preconcedido', initialWidth: 100, type: 'text', cellAttributes: { alignment: 'right' }, hideDefaultActions: true},
		{ label: 'My Box', fieldName: 'mybox', type: 'picklist', initialWidth: 50, hideDefaultActions: true},
		{ label: 'Target Auto', fieldName: 'targetAuto', type: 'picklist', initialWidth: 60, hideDefaultActions: true},
		{ label: 'Empleado', fieldName: 'gestor', type:'text',  initialWidth: 115, hideDefaultActions: true}
	];
	columnsDataClient = [
		{ label: ' ', fieldName: 'destacada', type: 'button-icon', fixedWidth: 20, typeAttributes: {iconName: { fieldName: 'destacadaIcon'},alternativeText: 'Destacada', variant: 'bare-inverse', iconClass:{ fieldName: 'iconClass'}}, hideDefaultActions: true},
		{ label: 'Potencialidad Cliente', fieldName: 'startClient', type:'text', initialWidth: 99, cellAttributes:{ style: { fieldName: 'startClientCSS' }}, hideDefaultActions: true},
		{ label: 'Cliente', fieldName: 'clienteId', type:'url', initialWidth: 267, typeAttributes: {label: { fieldName: 'cliente'},tooltip:{fieldName:'cliente'}}, hideDefaultActions: true},
		{ label: 'Potencialidad Oportunidad', fieldName: 'startOpp', type:'text', initialWidth: 99, cellAttributes:{ style: { fieldName: 'startOppCSS' }}, hideDefaultActions: true},
		{ label: 'Nombre de la Oportunidad', fieldName: 'oppId', type: 'url', initialWidth: 222, typeAttributes: {label: { fieldName: 'nombre'},tooltip:{fieldName:'nombre'}}, hideDefaultActions: true},
		{ label: 'Producto', fieldName: 'producto', type: 'text', hideDefaultActions: true},
		{ label: 'Negocio', fieldName: 'negocioView', type: 'text', hideDefaultActions: true},
		{ label: 'Ahorro / inversión', fieldName: 'ahorroEInversion', type: 'text', cellAttributes: { alignment: 'right' }, initialWidth: 95, hideDefaultActions: true},
		{ label: 'Financiación', fieldName: 'financiacion', type: 'text', cellAttributes: { alignment: 'right' }, initialWidth: 95, hideDefaultActions: true},
		{ label: 'Ingresos', fieldName: 'ingresos', type: 'text', cellAttributes: { alignment: 'right' }, initialWidth: 95, hideDefaultActions: true},
		{ label: 'Cumplimiento de modelo atención', fieldName: 'attentionModel', type: 'cumplimiento',cellAttributes:{ style: { fieldName: 'attentionModelCSS'}}, typeAttributes:{texto:{fieldName:'attentionModel'}}, initialWidth: 157, hideDefaultActions: true},
		{ label: 'Edad', fieldName: 'edad', type: 'number', cellAttributes: { alignment: 'center' }, initialWidth: 75, hideDefaultActions: true}
	];
	labels = {
		recordLimit : recordLimitLabel 
	};
	@track loading = true;
	@track showMoreFilters = false;
	@track loadingTable = true;
	@track pillSelected = true;
	@track showSpinnerFirst = true;
	@track showAll = false;
	@track showPrevious = false;
	@track showNext = true;
	@track disabledAplicar = true;
	@track showChart = true;
	firstFilterClick = false;
	secondFilterClick = false;

	helpMessage = false;
	filters;
	listOpp;
	listOppTable;
	listOppSearch;
	listOppExpe;
	listOppPro;
	listOppName;
	filterExpe;
	@track labelFilterExpe = null;
	@track filterProduct = null;
	@track filterName = null;
	@track updatedData = '';
	selectedItems;
	datasetName;
	datasetProduct;
	datasetExpe;
	@track total = 0;
	@track page = 1;
	@track totalPage = 0;
	@track selectedNames = [];
	@track selectedProducts = [];
	@track initialSelection = [];
	@track labelsNameData = [];
	@track labelsProData = [];
	@track errors = [];
	@track employeeLabel = 'Asignar a:';
	@track employeePlaceholder = 'Buscar empleado...';
	@track isMultiEntry = false;
	@track data;
	@track filterList;
	@track contactName;
	@track isModalOpen = false;
	@track endingRecord = 0; 
	@track startingRecord = 1;
	@track destacadas = true;
	@track preconcedido = false;
	@track myBox = false;
	@track targetAuto = false;
	@track orderBy = 'O';
	@track disabledOrdering = true;
	@track orderingCriterion = 'DESC';
	@track limit = '50';
	actionType;
	@track optionsProducts = [];
	@track optionsNames = [];
	@track selectedlabels = [];
	@track labelsProductId = new Map();
	initialSelectionOffice = [];
	errors = [];
	isMultiEntry = false;
	officePlaceholder = 'Buscar oficina...';
	@track optionsEmployee = [];
	optionsEmployeeAux = [];
	employeeDefault = USER_ID;
	@track employeeFilter = this.employeeDefault;
	isAnotherOffice = false;
	numOficinaEmpresa = null;
	selectedOffice = '';
	empleOfi = '';
	multiSelectionE=0;
	multiSelectionS=0;
	selectedEmployees = [];
	employeesDiv = true;
	estadoDiv = true;
	empleFuncion;
	isDirector;
	empleName = '';
	directores = ['DC','DT','DAN','SSCC'];
	@track origenFilter = 'all';
	@track statusFilter = 'En gestión/insistir';
	selectedEstado = [{label:'Potencial',id:'Potencial',bucleId:this.multiSelectionS},{label:'En Gestión',id:'En gestión/insistir',bucleId:(this.multiSelectionS+1)}];
	potencial;
	@track optionsIndicadorCli = [];
	multiSelectionIndicador = 0;
	removedIndicadores = [];
	copyOptionsIndicador = [];
	@track 	selectedIndicadores = [];
	@track 	selectedIndicadoresDiv = false;
	valueNull = null;
	fechaGestionFrom;
	fechaGestionUntil;
	fechaVencimientoFrom;
	fechaVencimientoUntil;
	fechaModificacionFrom;
	fechaModificacionUntil;
	@track disabledAplicarMoreFilters = true;
	moreFilters;
	numOfficeDefault;
	selectedEmployeesDefault;
	selectedEstadoDefault;
	officeSelectedDefault; 
	dataFromTable = true;
	type = null;
	optionsType = [{ label: '', value: null}];
	disabledType = true;
	totalClient = 0;
	viewTotalClient = true;
	optionAll;
	isDisabledEmployee = false;
	find = '';
	isMultiOffi = false;
	firstEmployeeFilling = false;
	currentFilterStorageObj = {};
	applyStorage = false;
	firtsRender = false;
	sessionId;
	chartsFirstRender = false;
	renderedTable = false;
	selectedRowsStorage = [];
	firstChartRender = false;
	multigestor;
	@track currentPageReference;
    @wire(CurrentPageReference)
    setCurrentPageReference(currentPageReference) {
		if(currentPageReference.state.c__comesFromHome){
			let currentState = {};
			for(let key in currentPageReference.state){
				if(key != 'c__comesFromHome'){
					currentState[key] =   currentPageReference.state[key];
				}
			}
			this.emptyCookies();
			this[NavigationMixin.Navigate]({
				type: 'standard__navItemPage',
				attributes: {
					apiName: "AV_OppSearchTab"
				},
				state: currentState
			});
		}
        if(this.currentPageReference!= null && currentPageReference.state.c__refresh != this.currentPageReference.state.c__refresh) {
			this.dispatchEvent(new CustomEvent("refreshtaboppsearch"));
		}
		this.currentPageReference = currentPageReference;
		if (this.currentPageReference.state.c__singestor != null && this.currentPageReference.state.c__singestor[0] === AV_NotAssigned) {
			this.selectedEmployees = [{label:this.currentPageReference.state.c__singestor[0],id:this.currentPageReference.state.c__singestor[1],bucleId:this.multiSelectionE}];
			this.employeeFilter = this.currentPageReference.state.c__singestor[1];
        }
    }

	reportWindowSize = (e) => {
		this.getCharts();
	};
	renderedCallback(){
		if(!this.chartsFirstRender){
			this.handleHideChartWithoutSwitch();
		}
		if(!this.renderedTable){
			this.renderStorageTable();
		}
	}
	renderStorageTable(){
		if(this.currentFilterStorageObj[this.empleOfi]?.['dataFromTable'] != null || this.currentFilterStorageObj[this.empleOfi]?.['selectedRows']){
			if(this.currentFilterStorageObj[this.empleOfi]?.['dataFromTable'] != undefined){
				if(this.currentFilterStorageObj[this.empleOfi]?.['dataFromTable']){
					this.dataFromTable = true;
					this.template.querySelector('[data-id="DataBasic"]').className = 'slds-tabs_default__item slds-is-active';
					this.template.querySelector('[data-id="DataClient"]').className = 'slds-tabs_default__item';
					this.setCookieObj('dataFromTable',this.dataFromTable);
			
				}else{
					this.dataFromTable = false;
					this.template.querySelector('[data-id="DataClient"]').className = 'slds-tabs_default__item slds-is-active';
					this.template.querySelector('[data-id="DataBasic"]').className = 'slds-tabs_default__item';
					this.setCookieObj('dataFromTable',this.dataFromTable);
			
				}
			}
			
			if(this.currentFilterStorageObj[this.empleOfi]?.['selectedRows'] != null){
				this.selectedRowsStorage =  [];
				this.currentFilterStorageObj[this.empleOfi]?.['selectedRows'].forEach(row => {this.selectedRowsStorage.push(row)});
				this.renderedTable = true;
			}
		}
	}
	get optionsOrderBy() {
		return [
			{ label: 'Potencialidad Cliente', value: 'C' },
			{ label: 'Origen', value: 'RecordType.Name' },
			{ label: 'Potencialidad Oportunidad', value: 'O' },
			{ label: 'Producto', value: 'AV_PF__r.Name' },
			{ label: 'Nombre de la Oportunidad', value: 'Name' },
			{ label: 'Tipo', value: 'AV_Type__c' },
			{ label: 'Estado', value: 'StageName' },
			{ label: 'Próxima gestión', value: 'AV_FechaProximoRecordatorio__c' },
			{ label: 'Último contacto', value: 'Account.AV_LastContactDate__c'},
			{ label: 'Vencimiento', value: 'CloseDate' },
			{ label: 'Edad', value: 'Account.AV_Age__c' },
			{ label: 'Preconcedido', value: 'Account.AV_Preconceived__c' },
			{ label: 'My Box', value: 'Account.AV_MyBox__c' },
			{ label: 'Target Auto', value: 'Account.AV_TargetAuto__c' },
			{ label: 'Negocio', value: 'Account.AV_FormulaNegocio__c' },
			{ label: 'Ahorro/inversión', value: 'Account.AV_AhorroEInversion__c' },
			{ label: 'Financiación', value: 'Account.AV_Financiacion__c' },
			{ label: 'Ingresos', value: 'Account.AV_Ingresos__c' }
		];
	}
	emptyCookies(){
		delete this.currentFilterStorageObj[this.empleOfi];
		localStorage.setItem(COOKIESKEY,JSON.stringify(this.currentFilterStorageObj));
		this.selectedRowsStorage = [];
	}
	get optionsOrderingCriterion() {
		return [
			{ label: 'Ascendente', value: 'ASC'},
			{ label: 'Descendente', value: 'DESC' }
		];
	}
	get optionsLimit() {
		return [
			{ label: '50', value: '50'},
			{ label: '100', value: '100' }
		];
	}
	get optionsOppoOrigen() {
		return [
			{ label: 'Alerta Comercial', value: 'AV_AlertaComercial' },
			{ label: 'Iniciativa', value: 'AV_Iniciativa' },
			{ label: 'Acciones Comerciales', value: 'AV_Propuesta' },
			{ label: 'Sugerencia', value: 'AV_Sugerencia' },
			{ label: 'Call Me', value: 'AV_CallMe'},
			{ label: 'Todos',value: 'all'}
		];
	}
	get optionsOppoStatus() {
		return [
			{ label: 'Potencial', value: 'Potencial' },
			{ label: 'En Gestión', value: 'En gestión/insistir' },
			{ label: '', value: ''}
		];
	}
	get optionsExpectativaVenta(){
		return [
			{label: 'Venta programada' , value: 'VP'},
			{label: 'Muy alta' , value: 'A'},
			{label: 'Alta' , value: 'S'},
			{label: 'Media' , value: 'M'},
			{label: 'Baja' , value: 'B'},
			{label: '', value : null}
		];
	}

	connectedCallback() {
		this.getUserInfo();
		window.addEventListener('resize', this.reportWindowSize);
		this.filters = {
			preconcedido: this.preconcedido,
			myBox: this.myBox,
			targetAuto: this.targetAuto,
			orderBy: this.orderBy,
			orderingCriterion: this.orderingCriterion,
			limite: this.limit,
			type: this.type
		};
		if (this.currentPageReference.state.c__singestor != null && this.currentPageReference.state.c__singestor[0] === AV_NotAssigned) {
			this.selectedEmployees = [{label:this.currentPageReference.state.c__singestor[0],id:this.currentPageReference.state.c__singestor[1],bucleId:this.multiSelectionE}];
		}
		var employee = this.selectedEmployees.slice();
		var stage = this.selectedEstado.slice();
		var segmento = this.selectedIndicadores.slice();

		this.moreFilters = {
			oficina : this.numOficinaEmpresa,
			employee : employee,
			origen : this.origenFilter,
			stage : stage,
			expSale : this.potencial,
			dateProFrom : this.fechaGestionFrom,
			dateProUntil : this.fechaGestionUntil,
			dateVenFrom : this.fechaVencimientoFrom,
			dateVenUntil : this.fechaVencimientoUntil,
			dateModFrom : this.fechaModificacionFrom,
			dateModUntil : this.fechaModificacionUntil,
			segmento : segmento
		};
		this.getOptionsIndicadorCli();		
	}


	handleSearchProduct(e) {
		if ((e.detail.selectedvalues.length > 0 || (this.selectedProducts.length > 0 && e.detail.selectedvalues.length == 0)) && JSON.stringify(this.selectedProducts) != JSON.stringify(e.detail.selectedvalues)) {
			this.selectedProducts = e.detail.selectedvalues;
			this.selectedlabels = e.detail.selectedlabels;
			this.filterProduct = null;
			this.template.querySelector('[data-id="borderProduct"]').style.height = '';
			this.template.querySelector('[data-id="borderName"]').style.height = '';
			this.template.querySelector('[data-id="borderExp"]').style.height = '';
			if (this.orderBy === 'C') {
				this.orderBy = 'O';
				this.filters.orderBy = 'O';
			} else if (e.detail.selectedvalues.length === 0 && this.orderBy === 'O' && this.selectedNames.length === 0 && this.filterExpe != null){
				this.orderBy = 'C';
				this.filters.orderBy = 'C';
			}
			this.destacadas = false;
			this.getOpp();
		}
		this.setCookieObj('selectedProducts',this.selectedProducts);
		this.setCookieObj('selectedlabels',this.selectedlabels);
		this.setCookieObj('filterProduct',this.filterProduct);
		this.disabledType = this.validateType();
		if (!this.disabledType) {
			this.generateOptionsTypes();
		} else {
			this.disabledType = true;
			this.type = null;
			if (this.filters != null) {
				this.filters.type = this.type;
			}
			this.setCookieObj('type',this.type);
			this.disabledAplicar = !this.viewFilters();
		}
	}
	
	handleSearchName(e) {
		if ((e.detail.selectedvalues.length > 0 || (this.selectedNames.length > 0 && e.detail.selectedvalues.length == 0)) && JSON.stringify(this.selectedNames) != JSON.stringify(e.detail.selectedvalues)) {
			var valuesNames = [];
			for (var i = 0; i < e.detail.selectedvalues.length; i++ ) {
				valuesNames.push(e.detail.selectedvalues[i]);
			}
			this.selectedNames = valuesNames;
			this.filterName = null;
			this.template.querySelector('[data-id="borderProduct"]').style.height = '';
			this.template.querySelector('[data-id="borderName"]').style.height = '';
			this.template.querySelector('[data-id="borderExp"]').style.height = '';
			if (this.orderBy === 'C') {
				this.orderBy = 'O';
				this.filters.orderBy = 'O';
			} else if (e.detail.selectedvalues.length === 0 && this.orderBy === 'O' && this.selectedProducts.length === 0 && this.filterExpe != null){
				this.orderBy = 'C';
				this.filters.orderBy = 'C';
			}
			this.setCookieObj('filterName',this.filterName);
			this.setCookieObj('selectedNames',this.selectedNames);
	
			this.destacadas = false;
			this.getOpp();
		}
	}

	handleAplicar() {
		this.selectedRowsStorage = [];
		this.setCookieObj('selectedRows',[]);

		this.filters = {
			preconcedido: this.preconcedido,
			myBox: this.myBox,
			targetAuto: this.targetAuto,
			orderBy: this.orderBy,
			orderingCriterion: this.orderingCriterion,
			limite: this.limit,
			type: this.type
		};
		this.disabledAplicar = true;
		this.resetTablePag();
		this.getOpp();
	}

	setDinamycVar(filter,value){
		filter = value;
	}
	buildCookies(){
		if(localStorage.getItem(COOKIESKEY)){
			this.currentFilterStorageObj = JSON.parse(localStorage.getItem(COOKIESKEY));
			if(this.currentFilterStorageObj[this.empleOfi]){
				if(this.currentFilterStorageObj[this.empleOfi][TIMELIMITKEY] != null){
					if(Date.now() - this.currentFilterStorageObj[this.empleOfi][TIMELIMITKEY] > LIMITTIMESTORAGECLEAM){
						this.emptyCookies();
						return;
					}
				}
				if(this.currentFilterStorageObj[this.empleOfi]?.['oficina'] != null){
					this.initialSelectionOffice = this.currentFilterStorageObj[this.empleOfi]['oficinaVisual'];
					this.numOficinaEmpresa = this.currentFilterStorageObj[this.empleOfi]['oficina'];
				}

				if(this.currentFilterStorageObj[this.empleOfi]['origen'] != null){
					this.origenFilter = this.currentFilterStorageObj[this.empleOfi]['origen'];
					this.showMoreFilters = true;
				}
				if(this.currentFilterStorageObj[this.empleOfi]['proximaGestionDesde'] != null){
					this.fechaGestionFrom = this.currentFilterStorageObj[this.empleOfi]['proximaGestionDesde'];
					this.showMoreFilters = true;
				}
				if(this.currentFilterStorageObj[this.empleOfi]['proximaGestionHasta'] != null){
					this.fechaGestionUntil = this.currentFilterStorageObj[this.empleOfi]['proximaGestionHasta'];
					this.showMoreFilters = true;
				}
				if(this.currentFilterStorageObj[this.empleOfi]['fechaVencimientoDesde'] != null){
					this.fechaVencimientoFrom = this.currentFilterStorageObj[this.empleOfi]['fechaVencimientoDesde'];
					this.showMoreFilters = true;
				}
				if(this.currentFilterStorageObj[this.empleOfi]['fechaVencimientoHasta'] != null){
					this.fechaVencimientoUntil = this.currentFilterStorageObj[this.empleOfi]['fechaVencimientoHasta'];
					this.showMoreFilters = true;
				}
				if(this.currentFilterStorageObj[this.empleOfi]['fechaUltimaModificacionDesde'] != null){
					this.fechaModificacionFrom = this.currentFilterStorageObj[this.empleOfi]['fechaUltimaModificacionDesde'];
					this.showMoreFilters = true;
				}
				if(this.currentFilterStorageObj[this.empleOfi]['fechaUltimaModificacionHasta'] != null){
					this.fechaModificacionUntil = this.currentFilterStorageObj[this.empleOfi]['fechaUltimaModificacionHasta'];
					this.showMoreFilters = true;
				}
				if(this.currentFilterStorageObj[this.empleOfi]['expectativa'] != null){
					this.potencial = this.currentFilterStorageObj[this.empleOfi]['expectativa'];
					this.showMoreFilters = true;
				}
				
				if(this.currentFilterStorageObj[this.empleOfi]['empleadosAsignados'] != null && this.currentFilterStorageObj[this.empleOfi]['empleadosAsignados']?.length > 0){
					this.selectedEmployees = [];
					this.currentFilterStorageObj[this.empleOfi]['empleadosAsignados'].forEach(emp => {this.selectedEmployees.push(emp)});
					this.showMoreFilters = true;
				}
				if(this.currentFilterStorageObj[this.empleOfi]['employeeDefault'] != null){
					this.employeeFilter = this.currentFilterStorageObj[this.empleOfi]['employeeDefault'];
					this.showMoreFilters = true;
				}
				if(this.currentFilterStorageObj[this.empleOfi]['stage'] != null && this.currentFilterStorageObj[this.empleOfi]['stage']?.length > 0){
					this.selectedEstado = [];
					this.currentFilterStorageObj[this.empleOfi]['stage'].forEach(emp => {this.selectedEstado.push(emp)});
					this.showMoreFilters = true;
				}
				
				if(this.currentFilterStorageObj[this.empleOfi]['segmentos'] != null && this.currentFilterStorageObj[this.empleOfi]['segmentos']?.length > 0){
					this.selectedIndicadores = [];
					this.currentFilterStorageObj[this.empleOfi]['segmentos'].forEach(emp => {this.selectedIndicadores.push(emp)});
					this.selectedIndicadoresDiv = true;
					this.showMoreFilters = true;
				}

				if(this.currentFilterStorageObj[this.empleOfi]['targetAuto'] != null){
					this.disabledAplicar = false;
					this.targetAuto = this.currentFilterStorageObj[this.empleOfi]['targetAuto'];
				}
				if(this.currentFilterStorageObj[this.empleOfi]['preconcedido'] != null){
					this.disabledAplicar = false;
					this.preconcedido = this.currentFilterStorageObj[this.empleOfi]['preconcedido'];
				}
				if(this.currentFilterStorageObj[this.empleOfi]['myBox'] != null){
					this.disabledAplicar = false;
					this.myBox = this.currentFilterStorageObj[this.empleOfi]['myBox'];
				}
				if(this.currentFilterStorageObj[this.empleOfi]['orderBy'] != null){
					this.orderBy = this.currentFilterStorageObj[this.empleOfi]['orderBy'];
				}
				if(this.currentFilterStorageObj[this.empleOfi]['orderingCriterion'] != null){
					this.orderingCriterion = this.currentFilterStorageObj[this.empleOfi]['orderingCriterion'];
				}
				if(this.currentFilterStorageObj[this.empleOfi]['disabledOrdering'] != null){
					this.disabledOrdering = this.currentFilterStorageObj[this.empleOfi]['disabledOrdering'];
				}
				if(this.currentFilterStorageObj[this.empleOfi]['limit'] != null){
					this.limit = this.currentFilterStorageObj[this.empleOfi]['limit'];
				}

				if(this.currentFilterStorageObj[this.empleOfi]['filterExpe'] != null){
					this.filterExpe = this.currentFilterStorageObj[this.empleOfi]['filterExpe'];
					this.labelFilterExpe = this.currentFilterStorageObj[this.empleOfi]['labelFilterExpe'];
				}

				if(this.currentFilterStorageObj[this.empleOfi]['filterProduct'] != null){
					this.filterProduct = this.currentFilterStorageObj[this.empleOfi]['filterProduct'];
					this.selectedlabels = [this.filterProduct];

				}	
				if(this.currentFilterStorageObj[this.empleOfi]['selectedProducts'] != null){
					this.selectedProducts = this.currentFilterStorageObj[this.empleOfi]['selectedProducts'];
					this.selectedlabels = this.currentFilterStorageObj[this.empleOfi]['selectedlabels'];

				}	
				if(this.currentFilterStorageObj[this.empleOfi]['filterName'] != null){
					this.filterName  = this.currentFilterStorageObj[this.empleOfi]['filterName'];
					this.selectedNames = [this.filterName];
				}
				if(this.currentFilterStorageObj[this.empleOfi]['selectedNames'] != null){
					this.selectedNames  = this.currentFilterStorageObj[this.empleOfi]['selectedNames'];
					this.filterName = null;
				}
				if(this.currentFilterStorageObj[this.empleOfi]['destacadas'] != null){
					this.destacadas = this.currentFilterStorageObj[this.empleOfi]['destacadas'];
				}

				if(this.currentFilterStorageObj[this.empleOfi]['type'] != null){
					this.type = this.currentFilterStorageObj[this.empleOfi]['type'];
				}
				this.disabledAplicarMoreFilters = !this.viewMoreFilter();
				if(this.currentFilterStorageObj[this.empleOfi]['isAnotherOffice'] != null){
					this.isAnotherOffice = this.currentFilterStorageObj[this.empleOfi]['isAnotherOffice'];

				}
				if(this.currentFilterStorageObj[this.empleOfi]['showMoreFilters'] != null){
					this.showMoreFilters = this.currentFilterStorageObj[this.empleOfi]['showMoreFilters'];

				}
				if(this.currentFilterStorageObj[this.empleOfi]['showChart'] != null){
					this.showChart = this.currentFilterStorageObj[this.empleOfi]['showChart'];

				}
			
				if(this.showMoreFilters){
					this.applyStorage = true;
				}
			}
		}
	}
	getOpp() {
		this.helpMessage = false;
		this.loading = true;
		this.loadingTable = true;
		getOpportunities({datosString: JSON.stringify(this.filters), filterExpeString: JSON.stringify(this.filterExpe), productName: this.filterProduct, listProducts: this.selectedProducts, filterName: this.selectedNames, page: this.page, destacadas: this.destacadas, moreFiltersString: JSON.stringify(this.moreFilters)})
		.then(result => {
			if (this.template.querySelector('[data-id="borderProduct"]') != null) {
				var height = this.template.querySelector('[data-id="borderProduct"]').offsetHeight;
				if (height < this.template.querySelector('[data-id="borderName"]').offsetHeight) {
					height = this.template.querySelector('[data-id="borderName"]').offsetHeight;
				}
				this.template.querySelector('[data-id="borderExp"]').style.height = height+'px';
				this.template.querySelector('[data-id="borderProduct"]').style.height = height+'px';
				this.template.querySelector('[data-id="borderName"]').style.height = height+'px';
			}
			if (result != null) {
				var today =new Date();
				this.updatedData = this.setNumber(today.getDate())+'/'+this.setNumber(today.getMonth()+1)+'/'+today.getFullYear()+' '+this.setNumber(today.getHours())+':'+this.setNumber(today.getMinutes());
				var listAdded = [];
				var listAddedName = [];
				this.optionsNames = [];
				var optionsNamesWithOutOrder = new Map();
				this.optionsProducts = [];
				var optionsProductsWithOutOrder = new Map();
				this.listOppSearch = result.listOppSearch; 
				this.listOppExpe = result.listOppGraExp; 
				this.listOppPro = result.listOppGraPro;
				this.listOppName = result.listOppGraName;	
				var dataName = new Map();
				var dataProducts = new Map();
				for (var i = 0; i < this.listOppPro.length; i++) {
					if (this.listOppPro[i].producto != null && this.listOppPro[i].productoId != null && !listAdded.includes(this.listOppPro[i].productoId) && this.selectedProducts != null && this.selectedProducts.includes(this.listOppPro[i].productoId)) {
						listAdded.push(this.listOppPro[i].productoId);
						optionsProductsWithOutOrder.set(this.listOppPro[i].producto,{ label: this.listOppPro[i].producto, value: this.listOppPro[i].productoId, selected: true});
					} else if (this.listOppPro[i].producto != null && this.listOppPro[i].productoId != null && !listAdded.includes(this.listOppPro[i].productoId)) {
						listAdded.push(this.listOppPro[i].productoId);
						optionsProductsWithOutOrder.set(this.listOppPro[i].producto,{ label: this.listOppPro[i].producto, value: this.listOppPro[i].productoId, selected: false});
					}
					if (dataProducts.get(this.listOppPro[i].producto) != null) {
						dataProducts.set(this.listOppPro[i].producto, dataProducts.get(this.listOppPro[i].producto)+1);
					} else {
						dataProducts.set(this.listOppPro[i].producto, 1);
					}
				}
				for (var i = 0; i < this.listOppName.length; i++) {
					if (this.listOppName[i].nombre != null && !listAddedName.includes(this.listOppName[i].nombre) && this.selectedNames != null && this.selectedNames.includes(this.listOppName[i].nombre)) {
						listAddedName.push(this.listOppName[i].nombre);
						optionsNamesWithOutOrder.set(this.listOppName[i].nombre,{ label: this.listOppName[i].nombre, value: this.listOppName[i].nombre, selected: true});
					} else if (this.listOppName[i].nombre != null && !listAddedName.includes(this.listOppName[i].nombre)) {
						listAddedName.push(this.listOppName[i].nombre);
						optionsNamesWithOutOrder.set(this.listOppName[i].nombre,{ label: this.listOppName[i].nombre, value: this.listOppName[i].nombre, selected: false});
					}
					if (dataName.get(this.listOppName[i].nombre) != null) {
						dataName.set(this.listOppName[i].nombre, dataName.get(this.listOppName[i].nombre)+1);
					} else {
						dataName.set(this.listOppName[i].nombre,1);
					}
				}
				var mapArraName = Array.from(dataName).sort((a, b) => {
					let aIsPotencial = this.listOppName.find(opp => opp.nombre === a[0] && opp.priorityOpportunity && opp.estado == 'Potencial') ? 1 : 0;
					let bIsPotencial = this.listOppName.find(opp => opp.nombre === b[0] && opp.priorityOpportunity && opp.estado == 'Potencial') ? 1 : 0;
					return bIsPotencial - aIsPotencial || b[1] - a[1];
				});
				var mapName = new Map(mapArraName);
				var iterName = mapName.keys();
				for (var k = 0 ; k < optionsNamesWithOutOrder.size ; k++) {
					var name = iterName.next().value;
					if(optionsNamesWithOutOrder.get(name) != null) {
						this.optionsNames.push(optionsNamesWithOutOrder.get(name));
					}
				}
				var mapArraPro = Array.from(dataProducts).sort((a, b) => b[1] - a[1]);
				var mapPro = new Map(mapArraPro);
				var iterPro = mapPro.keys();
				for (var q = 0 ; q < optionsProductsWithOutOrder.size ; q++) {
					var pro = iterPro.next().value;
					if(optionsProductsWithOutOrder.get(pro) != null) {
						this.optionsProducts.push(optionsProductsWithOutOrder.get(pro));
					}
				}
				this.data = result.listOpp;
				this.displayRecordPerPage(this.page);
				if (result.totalSize != -1) {
					this.total = result.totalSize;
				}
				if (result.totalSizeClient != -1) {
					this.totalClient = result.totalSizeClient;
					this.viewTotalClient= true;
				} else {
					this.viewTotalClient= false;
				}
				this.totalPage = Math.ceil(this.total / this.limit);
				if (result.totalSize > 2000) {
					this.helpMessage = true;
					if (this.limit== 50) {
						this.totalPage = 40;
					} else if (this.limit == 100){
						this.totalPage = 20;
					}
				}
				if (this.totalPage<=1) {
					this.isMultipagina= false;
				}else{
					this.isMultipagina= true;
				}
				this.showAll = true;
				this.loadingTable = false;
				this.getDataChart();
			}
		}).catch(error => {
			console.log(error);
			const evt = new ShowToastEvent({
				title: 'Error',
				message: 'No se han podido cargar los datos.',
				variant: 'error',
				mode: 'error'
			});
			this.dispatchEvent(evt);
			this.loading = false;
			this.loadingTable = false;
			this.showSpinnerFirst = false;
		})
	}

	getDataChart() {
		var filterWithOthersCharts = false;
		if(this.filterName != null) {
			filterWithOthersCharts = true;
		}else if (this.selectedNames !=  null && this.selectedNames.length > 0) {
			filterWithOthersCharts = true;
		} else if (this.selectedProducts !=  null && this.selectedProducts.length > 0) {
			filterWithOthersCharts = true;
		} else if (this.filterProduct !=  null) {
			filterWithOthersCharts = true;
		} else if (this.filters != null && this.filters.myBox != null && this.filters.myBox) {
			filterWithOthersCharts = true;
		} else if (this.filters != null && this.filters.targetAuto != null && this.filters.targetAuto) {
			filterWithOthersCharts = true;
		} else if (this.filters != null && this.filters.preconcedido != null && this.filters.preconcedido) {
			filterWithOthersCharts = true;
		} else if (this.moreFilters != null && this.moreFilters.origen != null && this.moreFilters.origen != 'all') {
			filterWithOthersCharts = true;
		} else if (this.moreFilters != null && this.moreFilters.dateProFrom != null) {
			filterWithOthersCharts = true;
		} else if (this.moreFilters != null && this.moreFilters.dateProUntil != null) {
			filterWithOthersCharts = true;
		} else if (this.moreFilters != null && this.moreFilters.expSale != null && this.moreFilters.expSale != '') {
			filterWithOthersCharts = true;
		} else if (this.moreFilters != null && this.moreFilters.dateVenFrom != null) {
			filterWithOthersCharts = true;
		} else if (this.moreFilters != null && this.moreFilters.dateVenUntil != null) {
			filterWithOthersCharts = true;
		} else if (this.moreFilters != null && this.moreFilters.dateModFrom != null) {
			filterWithOthersCharts = true;
		} else if (this.moreFilters != null && this.moreFilters.dateModUntil != null) {
			filterWithOthersCharts = true;
		} else if (this.moreFilters != null && this.moreFilters.stage != null && this.moreFilters.stage.length > 0) {
			filterWithOthersCharts = true;
		} else if (this.moreFilters != null && this.moreFilters.segmento != null && this.moreFilters.segmento.length > 0) {
			filterWithOthersCharts = true;
		}

		getDataToChart({listOppExp: this.listOppSearch, listOpp: this.listOppExpe, filterWithOthersCharts: filterWithOthersCharts})
		.then(result => {
			if (result != null) {
				this.dataset = result;
				this.getCharts();
			}
			this.loading = false;
			this.showSpinnerFirst = false;
		}).catch(error => {
			console.log(error);
			const evt = new ShowToastEvent({
				title: 'Error',
				message: 'No se ha podido cargar los datos de los gráficos.',
				variant: 'error',
				mode: 'error'
			});
			this.dispatchEvent(evt);
			this.loading = false;
			this.showSpinnerFirst = false;
		})
	}

	setNumber(num) {
		var listNums = [0,1,2,3,4,5,6,7,8,9];
		if(listNums.includes(num)) {
			num = '0'+num;
		}
		return num;
	}

	getSelectedName(event) {
		this.selectedItems = event.detail.selectedRows.length;
		this.setCookieObj('selectedRows',event.detail.selectedRows.map(row => row.oppId))
	}

	handleSearch(event) {
		lookupSearch(event.detail)
			.then((results) => {
				if (event.detail.myOffice == 'true') {
					this.template.querySelector('[data-id="lookup1"] > c-av_-lookup').setSearchResults(results);
				} else {
					this.template.querySelector('[data-id="lookup6"] > c-av_-lookup').setSearchResults(results);
				}
			})
			.catch((error) => {
				console.error('Lookup error', JSON.stringify(error));
				this.errors = [error];
			});
	}

	handleSelectionChange(event) {
		this.checkForErrors(event);
	}
	setCookieObj(key,value){
		if(!this.currentFilterStorageObj[this.empleOfi]){
			this.currentFilterStorageObj[this.empleOfi] = {};
		}
		this.currentFilterStorageObj[this.empleOfi][key]=value;
		this.currentFilterStorageObj[this.empleOfi][TIMELIMITKEY] = Date.now();
		localStorage.setItem(COOKIESKEY,JSON.stringify(this.currentFilterStorageObj));
	}
	checkForErrors(event) {
		this.errors = [];
		let targetId = event.target.dataset.id;
		if (targetId === 'clookup1') {
			targetId = 'lookup1';
		} else if (targetId === 'clookup6') {
			targetId = 'lookup6';
		}
		if (targetId == 'lookup1' || targetId == 'lookup6') {
			const selection = this.template.querySelector(`[data-id="${targetId}"] > c-av_-lookup`).getSelection();
			if (selection.length !== 0) {
				for (let sel of selection) {
					this.filterList = String(sel.id);
				}
				this.contactNameA(this.filterList);
			} else {
				this.filterList = null;
			}
		} else if (targetId == 'clookup2') {
			const selection = this.template.querySelector(`[data-id="${targetId}"]`).getSelection();

			if(selection.length !== 0){
				for(let sel of selection) {
					if (sel.title == 'Todas') {
						this.numOficinaEmpresa = this.optionAll;
						this.employeeFilter = this.employeeDefault;
						this.selectedEmployees = [{label:this.empleName,id:this.employeeDefault,bucleId:this.multiSelectionE}];
						this.isDisabledEmployee = true;
						this.isAnotherOffice = false;
						this.employeesDiv = true;
					} else {
						this.find = '';
						this.numOficinaEmpresa = sel.title.substring(0,5);
						this.isDisabledEmployee = false;
						this.getOptionsEmployee(this.numOficinaEmpresa);
					}
				}
				this.setCookieObj('oficina',this.numOficinaEmpresa);
				this.setCookieObj('oficinaVisual',selection[0]);
				this.disabledAplicarMoreFilters = !this.viewMoreFilter();
			} else {
				this.numOficinaEmpresa = null;
				this.disabledAplicarMoreFilters = !this.viewMoreFilter();
			}
			this.disabledType = this.validateType();
			if (!this.disabledType) {
				this.generateOptionsTypes();
			} else {
				this.disabledType = true;
				this.type = null;
				if (this.filters != null) {
					this.filters.type = this.type;
				}
				this.setCookieObj('type',this.type);

				this.disabledAplicar = !this.viewFilters();
			}
		}
	}

	contactNameA(contactId) {
		nameContactAssign({ contactId: contactId })
			.then(result => {
				if (result != null) {
					this.contactName = result;
				}
			})
			.catch(error => {
				console.log(error);
			});
	}

	handleSave() {
		this.loadingTable = true;
		this.loading = true;
		var el = this.template.querySelector('c-a-v_-opp-search-data-table');
		var selected = el.getSelectedRows();
		if (selected != null && selected.length > 0) {
			var selectedIds = [];
			for(let i=0; i< selected.length ; i++){
				selectedIds.push(selected[i].oppId.substring(1));
			}
			assign({ contactId: this.filterList, selectedRowIds: selectedIds })
				.then(result => {
					if (result != null && result > 0) {
						const evt = new ShowToastEvent({
							title: 'Operación correcta',
							message: 'Se reasignarán ' + result + ' oportunidades a ' + this.contactName + '. Esta operación puede tardar varios segundos.',
							variant: 'success',
							mode: 'dismissable'
						});
						this.dispatchEvent(evt);
					} else {
						const evt = new ShowToastEvent({
							title: 'Operación incorrecta',
							message: 'El usuario ' + this.contactName + ' no tiene un contacto asociado.',
							variant: 'error',
							mode: 'dismissable'
						});
						this.dispatchEvent(evt);
					}
					this.resetTablePag();
					this.getOpp();
					this.handleCloseModal();
					this.template.querySelector('c-a-v_-opp-search-data-table').selectedRows = [];
				})
				.catch(error => {
					console.log(error);
					this.loadingTable = false;
					this.loading = false;
					this.handleCloseModal();
				});
		} else {
			this.handleCloseModal();
		}
	}

	handleCloseModal() {
		this.isModalOpen = false;
	}

	handleHideChart() {
		this.showChart = !this.showChart;
		this.setCookieObj('showChart',this.showChart);
		if(!this.showChart) {
			this.template.querySelector('[data-id="showChart"]').classList.add('invisible');
		} else {
			this.template.querySelector('[data-id="showChart"]').classList.remove('invisible');
			this.template.querySelector('[data-id="borderProduct"]').style.height = '';
			this.template.querySelector('[data-id="borderName"]').style.height = '';
			this.template.querySelector('[data-id="borderExp"]').style.height = '';
			this.getCharts();
		}
	}
	handleHideChartWithoutSwitch(){
		if(!this.showChart) {
			if(this.template.querySelector('[data-id="showChart"]') != null){
				this.template.querySelector('[data-id="showChart"]').classList.add('invisible');
				this.chartsFirstRender = true;
			}
		} else {
			if(
				this.template.querySelector('[data-id="showChart"]') != null &&
				this.template.querySelector('[data-id="borderProduct"]') != null &&
				this.template.querySelector('[data-id="borderName"]') != null &&
				this.template.querySelector('[data-id="borderExp"]') != null 
			){

				this.template.querySelector('[data-id="showChart"]').classList.remove('invisible');
				this.template.querySelector('[data-id="borderProduct"]').style.height = '';
				this.template.querySelector('[data-id="borderName"]').style.height = '';
				this.template.querySelector('[data-id="borderExp"]').style.height = '';
				this.chartsFirstRender = true;
		}
		}
	}
	

	handleDestacadas(event) {
		this.destacadas = event.target.checked;
		this.setCookieObj('destacadas',this.destacadas);
		this.resetTablePag();
		this.getOpp();
	}

	handlePreconcedido(event) {
		this.preconcedido = event.target.checked;
		this.setCookieObj('preconcedido',this.preconcedido);
		this.disabledAplicar = !this.viewFilters();
	}
	
	handleMyBox(event) {
		this.myBox = event.target.checked;
		this.setCookieObj('myBox',this.myBox);
		this.disabledAplicar = !this.viewFilters();
	}
	
	handleTargetAuto(event) {
		this.targetAuto = event.target.checked;
		this.setCookieObj('targetAuto',this.targetAuto);
		this.disabledAplicar = !this.viewFilters();
	}

	handleOrderBy(event) {
		this.orderBy = event.target.value;
		if (this.orderBy == 'C' || this.orderBy == 'O') {
			this.orderingCriterion = 'DESC';
			this.disabledOrdering = true;
		} else {
			this.disabledOrdering = false;
		}
		this.setCookieObj('orderBy',this.orderBy);
		this.setCookieObj('orderingCriterion',this.orderingCriterion);
		this.setCookieObj('disabledOrdering',this.disabledOrdering);
		this.disabledAplicar = !this.viewFilters();
	}

	handleOrderingCriterion(event) {
		this.orderingCriterion = event.target.value;
		this.setCookieObj('orderingCriterion',this.orderingCriterion);
		this.setCookieObj('disabledOrdering',this.disabledOrdering);
		this.disabledAplicar = !this.viewFilters();
	}

	handleLimit(event) {
		this.limit = event.target.value;
		this.setCookieObj('limit',this.limit);
		this.disabledAplicar = !this.viewFilters();
	}

	viewFilters() { 
		var resultado = false;
		if (this.filters != null && this.filters.preconcedido != this.preconcedido) {
			resultado = true;
		} else if (this.filters != null && this.filters.myBox != this.myBox) {
			resultado = true;
		} else if (this.filters != null && this.filters.targetAuto != this.targetAuto) {
			resultado = true;
		} else if (this.filters != null && this.filters.orderBy != this.orderBy) {
			resultado = true;
		} else if (this.filters != null && this.filters.orderingCriterion != this.orderingCriterion) {
			resultado = true;
		} else if (this.filters != null && this.filters.limite != this.limit) {
			resultado = true;
		} else if (this.filters != null && this.filters.type != this.type) {
			resultado = true;
		}
		return resultado;
	}
 
	handleQuitarFiltros() {
		this.preconcedido = false;
		this.myBox = false;
		this.targetAuto = false;
		this.orderBy = 'O';
		this.orderingCriterion = 'DESC';
		
		this.disabledOrdering = true;
		this.limit = '50';
		this.type = null;
		this.filters = {
			preconcedido: this.preconcedido,
			myBox: this.myBox,
			targetAuto: this.targetAuto,
			orderBy: this.orderBy,
			orderingCriterion: this.orderingCriterion,
			limite: this.limit,
			type: this.type
		};
		this.numOficinaEmpresa = this.numOfficeDefault;
		this.initialSelectionOffice = this.officeSelectedDefault;
		this.getOptionsEmployee(this.numOficinaEmpresa);
		this.selectedEmployees = [];
		this.selectedEmployeesDefault.forEach(emp =>{
			emp.bucleId = ++this.multiSelectionE;
			if(!this.employeesDiv){
				this.employeesDiv = true;
			}
		});
		this.selectedEmployeesDefault.forEach( emp => {this.selectedEmployees.push(emp)});
		this.employeeFilter = this.employeeDefault;
		this.origenFilter = 'all';
		this.statusFilter = 'En gestión/insistir';
		this.selectedEstado = [{label:'Potencial',id:'Potencial',bucleId:(this.multiSelectionS+1)},{label:'En Gestión',id:'En gestión/insistir',bucleId:(this.multiSelectionS+2)}];;
		this.multiSelectionS = this.multiSelectionS+2; 
		this.isAnotherOffice = false;
		this.potencial = null;
		this.fechaGestionFrom = null;
		this.fechaGestionUntil = null;
		this.fechaVencimientoFrom = null;
		this.fechaVencimientoUntil = null;
		this.fechaModificacionFrom = null;
		this.fechaModificacionUntil = null;
		this.selectedIndicadores = [];
		this.selectedIndicadoresDiv = false;
		this.valueNull = null;
		var employee = this.selectedEmployees.slice();
		var stage = this.selectedEstado.slice();
		var segmento = this.selectedIndicadores.slice();
		this.isDisabledEmployee = false;
		this.moreFilters = {
			oficina : this.numOficinaEmpresa,
			employee : employee,
			origen : this.origenFilter,
			stage : stage,
			expSale : this.potencial,
			dateProFrom : this.fechaGestionFrom,
			dateProUntil : this.fechaGestionUntil,
			dateVenFrom : this.fechaVencimientoFrom,
			dateVenUntil : this.fechaVencimientoUntil,
			dateModFrom : this.fechaModificacionFrom,
			dateModUntil : this.fechaModificacionUntil,
			segmento : segmento
		};
		this.disabledAplicar = true;
		this.disabledType = true;
		this.filterExpe = null;
		this.labelFilterExpe = null;
		this.filterName = null;
		this.selectedNames = [];
		if(this.template.querySelector('[data-id="searchNameMulti"]') != null) {
			this.template.querySelector('[data-id="searchNameMulti"]').refreshAll();
		}
		this.selectedProducts = [];
		this.selectedlabels = [];
		this.labelsProduct = [];
		if(this.template.querySelector('[data-id="searchProductMulti"]') != null) {
			this.template.querySelector('[data-id="searchProductMulti"]').refreshAll();
		}
		this.pillSelected = false;
		this.pillSelected = true;
		this.filterProduct = null;
		this.destacadas = true;
		if(this.template.querySelector('[data-id="borderProduct"]') != null) {
			this.template.querySelector('[data-id="borderProduct"]').style.height = '';
		}
		if(this.template.querySelector('[data-id="borderName"]') != null) {
			this.template.querySelector('[data-id="borderName"]').style.height = '';
		}
		if(this.template.querySelector('[data-id="borderExp"]') != null) {
			this.template.querySelector('[data-id="borderExp"]').style.height = '';
		}
		this.resetTablePag();
		this.emptyCookies();
		this.getOpp();
	}

	resetTablePag(){
		this.showPrevious = false;
		this.showNext = true;
		this.page = 1;
	}

	actuData() {
		this.resetTablePag();
		this.getOpp();
	}

	getCharts() {
		var dataProducts = new Map();
		this.labelsProductId = new Map();
		var dataName = new Map();
		var labelsName = [];
		var labelsProduct = [];
		var listProductNor = [];
		var listNameNor = [];
		for (var l = 0; l < this.listOppName.length; l++) {
			if (dataName.get(this.listOppName[l].nombre) != null) {
				dataName.set(this.listOppName[l].nombre, dataName.get(this.listOppName[l].nombre)+1);
			} else {
				dataName.set(this.listOppName[l].nombre,1);
			}
			if (!labelsName.includes(this.listOppName[l].nombre)) {
				labelsName.push(this.listOppName[l].nombre);
			}
		}
		for (var l = 0; l < this.listOppPro.length; l++) {
			if (dataProducts.get(this.listOppPro[l].producto) != null) {
				dataProducts.set(this.listOppPro[l].producto, dataProducts.get(this.listOppPro[l].producto)+1);
			} else {
				dataProducts.set(this.listOppPro[l].producto, 1);
			}
			if (!labelsProduct.includes(this.listOppPro[l].producto)) {
				labelsProduct.push(this.listOppPro[l].producto);
			}
			this.labelsProductId.set(this.listOppPro[l].producto, this.listOppPro[l].productoId);
		}
		var mapArraName = Array.from(dataName).sort((a, b) => {
			let aIsPotencial = this.listOppName.find(opp => opp.nombre === a[0] && opp.priorityOpportunity && opp.estado == 'Potencial') ? 1 : 0;
			let bIsPotencial = this.listOppName.find(opp => opp.nombre === b[0] && opp.priorityOpportunity && opp.estado == 'Potencial') ? 1 : 0;
			return bIsPotencial - aIsPotencial || b[1] - a[1];
		});
		var mapName = new Map(mapArraName);
		this.labelsNameData = [];
		var iterName = mapName.keys();
		for (var k = 0 ; k < labelsName.length ; k++) {
			var name = iterName.next().value;
			this.labelsNameData.push(name);
			listNameNor.push(mapName.get(name));
		}
		var mapArraPro = Array.from(dataProducts).sort((a, b) => b[1] - a[1]);
		var mapPro = new Map(mapArraPro);
		this.labelsProData = [];
		var iterPro = mapPro.keys();
		for (var q = 0 ; q < labelsProduct.length ; q++) {
			var pro = iterPro.next().value;
			this.labelsProData.push(pro);
			listProductNor.push(mapPro.get(pro));
		}
		this.datasetProduct = {
			datasets: [{
				label:'Total',
				backgroundColor: (ctx)=> this.colorFromRawPro(ctx),
				data: listProductNor,
				barThickness: 16,
  				barPercentage: 0.5
			}],
			labels: this.labelsProData
		};
		this.datasetName = {
			datasets: [{
				label:'Total',
				backgroundColor: (ctx)=> this.colorFromRawName(ctx),
				data: listNameNor,
				barThickness: 16,
  				barPercentage: 0.5
			}],
			labels: this.labelsNameData
		};
		this.datasetExpe = [{
			label:'Total',
			backgroundColor: (ctx)=> this.colorFromRaw(ctx),
			tree: this.dataset,
			labels:{
				display: true,
				formatter:(ctx) => {
					if((ctx.raw._data.label.length*5)+((ctx.raw._data.label.split(' ').length-1)*2) < ctx.raw.w) {
						var numero = ctx.raw._data.value;
						if(numero >= 1000000) {
							numero = numero.toString().substring(0,numero.toString().length-6)+'M';
						} else if(numero >= 1000) {
							numero = numero.toString().substring(0,numero.toString().length-3)+'K';
						}
						return [ctx.raw._data.label,`(${numero})`];
					}
					return '';
				},
				color: (ctx)=> this.colorFontFromRawExp(ctx)
			},
			key: 'value'
		}];
		loadScript(this, (chartjs + '/chart.min.js')).then(() => {
			loadScript(this, (charttreemapjs + '/chartjs-chart-treemap.js')).then(() => {
				let canvas = document.createElement('canvas');
				const divPrincipal = this.template.querySelector('div.productChart');
				const divScroll = document.createElement('div');
				while (divPrincipal.firstChild) {
					divPrincipal.firstChild.remove();
				}
				if (labelsProduct.length > 15) {
					const newHeight = 250 + ((labelsProduct.length - 7) * 20);
					canvas.style.height = `${newHeight}px`;
					canvas.style.width = '-webkit-fill-available';
					divScroll.style.height = '380px';
					divScroll.classList.add('scroll');
					divScroll.classList.add('body-card-chart-pro');
				} else {
					canvas.style.height = '380px';
					canvas.style.width = '-webkit-fill-available';
					divScroll.style.height = '380px';
					divScroll.classList.add('scroll');
					divScroll.classList.add('body-card-chart-pro');
				}
				divPrincipal.appendChild(divScroll).appendChild(canvas);
				const ctx = canvas.getContext('2d');
				this.chart = new window.Chart(ctx, this.createConfig('1'));
	
				let canvas2 = document.createElement('canvas');
				const divPrincipal2 = this.template.querySelector('div.nameChart');
				const divScroll2 = document.createElement('div');
				while (divPrincipal2.firstChild) {
					divPrincipal2.firstChild.remove();
				}
				if (labelsName.length > 15) {
					const newHeight2 = 250 + ((labelsName.length - 7) * 20);
					canvas2.style.height = `${newHeight2}px`;
					canvas2.style.width = '-webkit-fill-available';
					divScroll2.style.height = '380px';
					divScroll2.classList.add('scroll');
					divScroll2.classList.add('body-card-chart');
				} else {
					canvas2.style.height = '380px';
					canvas2.style.width = '-webkit-fill-available';
					divScroll2.style.height = '380px';
					divScroll2.classList.add('scroll');
					divScroll2.classList.add('body-card-chart');
				}
				divPrincipal2.appendChild(divScroll2).appendChild(canvas2);
				const ctx2 = canvas2.getContext('2d');
				this.chart2 = new window.Chart(ctx2, this.createConfig('2'));
				
				let canvas3 = document.createElement('canvas');
				const divPrincipal3 = this.template.querySelector('div.expChart');
				const divScroll3 = document.createElement('div');
				while (divPrincipal3.firstChild) {
					divPrincipal3.firstChild.remove();
				}
				canvas3.style.height = '380px';
				canvas3.style.width = '-webkit-fill-available';
				divScroll3.style.height = '380px';
				divScroll3.classList.add('scroll');
				divScroll3.classList.add('body-card-chart-ex');
				divPrincipal3.appendChild(divScroll3).appendChild(canvas3);
				const ctx3 = canvas3.getContext('2d');
				this.chart3 = new window.Chart(ctx3, this.createConfig('3'));
				this.loading = false;
				this.showSpinnerFirst = false;
			}).catch(error => {
				console.log(error);
				this.loading = false;
				this.showSpinnerFirst = false;
			});
		}).catch(error => {
			console.log(error);
			this.loading = false;
			this.showSpinnerFirst = false;
		});
	}

	createConfig(num) {
		var counter = {
			id: 'counter',
			afterDraw(chart, arg, options) {
				var ctx = chart.ctx;
				var meta;
				var data;
				var metas = chart.getSortedVisibleDatasetMetas();
				chart.data.datasets.forEach(function (dataset, i) {
					meta = metas[i];
					meta.data.forEach(function (bar, index) {
						data = dataset.data[index];
						if (data !== 0) {
							data = dataset.data[index];
							if(data >= 1000000) {
								data = data.toString().substring(0,data.toString().length-6)+'M';
							} else if(data >= 1000) {
								data = data.toString().substring(0,data.toString().length-3)+'K';
							}
							ctx.textAlign = 'left';
							ctx.textBaseline = 'center';
							if (!isNaN(bar.width)) {
								if (data.toString().length == 4) {
									if (bar.width > 36) {
										ctx.fillStyle = 'white';
										ctx.fillText(data, bar.x - 35, bar.y + 5);
									} else {
										ctx.fillStyle = 'black';
										ctx.fillText(data, bar.x + 5, bar.y + 5);
									}
								} else if (data.toString().length == 3) {
									if (bar.width > 26) {
										ctx.fillStyle = 'white';
										ctx.fillText(data, bar.x - 25, bar.y + 5);
									} else {
										ctx.fillStyle = 'black';
										ctx.fillText(data, bar.x + 5, bar.y + 5);
									}
								} else if (data.toString().length == 2) {
									if (bar.width > 18) {
										ctx.fillStyle = 'white';
										ctx.fillText(data, bar.x - 17, bar.y + 5);
									} else {
										ctx.fillStyle = 'black';
										ctx.fillText(data, bar.x + 5, bar.y + 5);
									}
								} else {
									if (bar.width > 13) {
										ctx.fillStyle = 'white';
										ctx.fillText(data, bar.x - 12, bar.y + 5);
									} else {
										ctx.fillStyle = 'black';
										ctx.fillText(data, bar.x + 5, bar.y + 5);
									}
								}
							}
						}
					});
				});
			}
		};
		var config;
		if (num == '1') {
			config = {
				type: 'bar',
				data: this.datasetProduct,
				options: {
					locale: 'es-ES',
					onClick: (event, elements, chart) => {
						if (elements[0] != null) { 
							this.emptySelectedRows();
				
							if(this.filterProduct == null || this.filterProduct != chart.config._config.data.labels[elements[0].index]) {
								this.filterProduct = chart.config._config.data.labels[elements[0].index];
								this.selectedProducts = [this.labelsProductId.get(this.filterProduct)];
								this.selectedlabels = [this.filterProduct];
								this.labelsProduct = [this.filterProduct];
								this.template.querySelector('[data-id="searchProductMulti"]').refreshAll();
								this.template.querySelector('[data-id="searchProductMulti"]').selectedlabels = this.selectedlabels;
								this.template.querySelector('[data-id="searchProductMulti"]').selectedvalues = this.selectedProducts;
								this.template.querySelector('[data-id="searchProductMulti"]').refreshOrginalList();
								this.destacadas = false;
								if (this.orderBy === 'C') {
									this.orderBy = 'O';
									this.filters.orderBy = 'O';
								}
								this.disabledType = this.validateType();
								if (!this.disabledType) {
									this.generateOptionsTypes();
								} else {
									this.disabledType = true;
									this.type = null;
									if (this.filters != null) {
										this.filters.type = this.type;;
									}
									this.disabledAplicar = !this.viewFilters();
								}
							} else {
								this.filterProduct = null;
								this.selectedProducts = [];
								this.selectedlabels = [];
								this.labelsProduct = [];
								this.template.querySelector('[data-id="searchProductMulti"]').refreshAll();
								this.destacadas = false;
								if (this.orderBy === 'O' && this.selectedNames.length == 0 && this.filterExpe != null) {
									this.orderBy = 'C';
									this.filters.orderBy = 'C';
								}
								this.disabledType = true;
								this.type = null;
								if (this.filters != null) {
									this.filters.type = this.type;
								}
								this.disabledAplicar = !this.viewFilters();
							}
							this.resetTablePag();
							this.setCookieObj('filterProduct',this.filterProduct);
							this.setCookieObj('selectedProducts',this.selectedProducts);
							this.setCookieObj('selectedlabels',this.selectedlabels);
							this.setCookieObj('destacadas',this.destacadas);
							this.setCookieObj('orderBy',this.orderBy);
							this.setCookieObj('type',this.type);

							this.getOpp();
						}
					},
					indexAxis: 'y',
					cutout: 30,
					title: {
						text: this.title
					},
					scales: {
						x:{
							display: false,
							grid:{
								drawOnChartArea: false
							},
							stacked: true
						},
						y:{
							grid:{
								drawOnChartArea: false
							},
							stacked: true
						}
					},
					plugins: {
						legend: {
							display: false
						},
						tooltip: {
							enabled: true
						}
					},
					responsive: false
				},
				plugins: [counter]
			};
		} else if (num == '2') {
			config = {
				type: 'bar',
				data: this.datasetName,
				options: {
					locale: 'es-ES',
					onClick: (event, elements, chart) => {
						if (elements[0] != null) { 
							this.emptySelectedRows();
				
							if(this.filterName == null || this.filterName != chart.config._config.data.labels[elements[0].index]) {
								this.filterName = chart.config._config.data.labels[elements[0].index];
								this.selectedNames = [this.filterName];
								this.template.querySelector('[data-id="searchNameMulti"]').refreshAll();
								this.template.querySelector('[data-id="searchNameMulti"]').selectedvalues = this.selectedNames;
								this.template.querySelector('[data-id="searchNameMulti"]').refreshOrginalList();
								this.destacadas = false;
								if (this.orderBy === 'C') {
									this.orderBy = 'O';
									this.filters.orderBy = 'O';
								}
							} else {
								this.filterName = null;
								this.selectedNames = [];
								this.template.querySelector('[data-id="searchNameMulti"]').refreshAll();
								this.destacadas = false;
								if (this.orderBy === 'O' && this.selectedProducts.length === 0 && this.filterExpe != null) {
									this.orderBy = 'C';
									this.filters.orderBy = 'C';
								}
							}
							this.resetTablePag();
							this.setCookieObj('filterName',this.filterName);
							this.setCookieObj('selectedNames',this.selectedNames);
							this.setCookieObj('destacadas',this.destacadas);
							this.setCookieObj('orderBy',this.orderBy);
							this.getOpp();
						}
					},
					indexAxis: 'y',
					cutout: 30,
					scales: {
						x:{
							display: false,
							grid:{
								drawOnChartArea: false
							},
							stacked: true
						},
						y:{
							grid:{
								drawOnChartArea: false
							},
							stacked: true,
							ticks: {
								callback: function(value) {
									var label = this.getLabelForValue(value);
									if (label != null && label.length > 26) {
										label = this.getLabelForValue(value).substr(0, 26)+'...';
									}
									return label;
								}
							}
						}
					},
					plugins: {
						legend: {
							display: false
						},
						tooltip: {
							enabled: true,
							callbacks: {
								title: (context) => {
									return [context[0].label];
								}
							}
						}
					},
					responsive: false
				},
				plugins: [counter]
			};
		} else if (num == '3') {
			config = {
				type: 'treemap',
				data: {
					datasets: this.datasetExpe
				},
				options: {
					locale: 'es-ES',
					onClick: (event, elements, chart) => {
						if (elements[0] != null) {
							this.emptySelectedRows();

							if(this.labelFilterExpe == chart.config._config.data.datasets[0].data[elements[0].index]._data.label) {
								this.filterExpe = null;
								this.labelFilterExpe = null;
								this.destacadas = false;
								if (this.orderBy === 'C') {
									this.orderBy = 'O';
									this.filters.orderBy = 'O';
								}
							} else {
								this.filterExpe = chart.config._config.data.datasets[0].data[elements[0].index]._data.listProduct;
								this.labelFilterExpe = chart.config._config.data.datasets[0].data[elements[0].index]._data.label;
								this.destacadas = false;
								if (this.orderBy === 'O' && this.selectedProducts.length === 0 && this.selectedNames.length === 0) {
									this.orderBy = 'C';
									this.filters.orderBy = 'C';
								}
							}
							this.setCookieObj('filterExpe',this.filterExpe);
							this.setCookieObj('labelFilterExpe',this.labelFilterExpe);
							this.setCookieObj('destacadas',this.destacadas);
							this.setCookieObj('orderBy',this.orderBy);
							this.resetTablePag();
							this.getOpp();
						}
					},
					indexAxis: 'y',
					cutout: 30,
					title: {
						text: this.title
					},
					scales: {
						x:{
							display: false,
							grid:{
								drawOnChartArea: false
							},
							stacked: true
						},
						y:{
							grid:{
								drawOnChartArea: false
							},
							stacked: true
						}
					},
					plugins: {
						legend: {
							display: false
						},
						tooltip: {
							enabled: true,
							callbacks: {
								title: (context) => {
									return [context[0].raw._data.label];
								}
							}
						}
					},
					responsive: false
				}
			};
		}
		return config;
	}

	colorFontFromRawExp(ctx) {
		var color = 'black';
		if (ctx.raw != null && ctx.raw._data != null && (this.labelFilterExpe == null || (this.labelFilterExpe != null && this.labelFilterExpe == ctx.raw._data.label))) {
			if (ctx.raw._data.label == 'Día a día' || ctx.raw._data.label == 'Facilitar el día a día') {
				color = 'white';
			} else if (ctx.raw._data.label == 'Disfrutar de la vida' || ctx.raw._data.label == 'Impulsar el crecimiento') {
				color = 'white';
			} else if (ctx.raw._data.label == 'Dormir tranquilo' || ctx.raw._data.label == 'Asegurar la tranquilidad') {
				color = 'black';
			} else if (ctx.raw._data.label == 'Pensar en el futuro' || ctx.raw._data.label == 'Gestionar los recursos') {
				color = 'black';
			} else {
				color = 'white';
			}
		}
		return color;
	}

	colorFromRaw(ctx) {
		var color;
		if(ctx.type !=='data') {
			return 'transparent';
		}
		if (this.labelFilterExpe != null && ctx.raw._data != null && this.labelFilterExpe != ctx.raw._data.label){
			color = 'rgb(134, 136, 137)';
		} else {
			if (ctx.raw._data.label == 'Día a día' || ctx.raw._data.label == 'Facilitar el día a día') {
				color = '#064F70';
			} else if (ctx.raw._data.label == 'Disfrutar de la vida' || ctx.raw._data.label == 'Impulsar el crecimiento') {
				color = '#007EAE';
			} else if (ctx.raw._data.label == 'Dormir tranquilo' || ctx.raw._data.label == 'Asegurar la tranquilidad') {
				color = '#2BC0ED';
			} else if (ctx.raw._data.label == 'Pensar en el futuro' || ctx.raw._data.label == 'Gestionar los recursos') {
				color = '#A5EAFD';
			} else {
				color = '#333333';
			}
		}
		return color;
	}

	colorFromRawPro(ctx) {
		var color;
		if (ctx.dataIndex !== null && ((this.filterProduct != null && this.filterProduct !== this.labelsProData[ctx.dataIndex]) || ((this.selectedlabels === null && this.selectedlabels.length === 0) || (this.selectedlabels !== null && this.selectedlabels.length > 0 && !this.selectedlabels.includes(this.labelsProData[ctx.dataIndex]))))){
			color = 'rgb(134, 136, 137)';
		} else {
			color = 'rgb(0,126,174)';
		}
		return color;
	}

	colorFromRawName(ctx) {
		var color;
		let isPotencial = false;
	
	
		this.listOppName.forEach(opp => {
			if(opp.priorityOpportunity && opp.nombre === this.labelsNameData[ctx.dataIndex] && opp.estado == 'Potencial'){
				isPotencial = true;
			}
		})
	
		if (ctx.dataIndex !== null && ((this.filterName !== null && this.filterName !== this.labelsNameData[ctx.dataIndex]) || ((this.selectedNames === null && this.selectedNames.length === 0) || (this.selectedNames !== null && this.selectedNames.length > 0 && !this.selectedNames.includes(this.labelsNameData[ctx.dataIndex]))))){
			color = 'rgb(134, 136, 137)';
		} else {
			if(isPotencial){
				color = 'rgb(0, 40, 100)';
			}
			else{
				color = 'rgb(0,126,174)';
			}
		}
		return color;
	}

	previousHandler() {
		if (this.page > 1) {
			this.page = this.page - 1;
			this.displayRecordPerPage(this.page);
			if(this.page === 1) {
				this.showPrevious = false;
			} else {
				this.showPrevious = true;
			}
		}
		if(this.page !== this.totalPage) {
			this.showNext = true;
		} else {
			this.showNext = false;
		}
	}

	nextHandler() {
		if((this.page<this.totalPage) && this.page !== this.totalPage){
			this.page = this.page + 1; 
			this.displayRecordPerPage(this.page);
		}
		if (this.page === this.totalPage) {
			this.showNext = false;
		} else {
			this.showNext = true;
		}
		if(this.page !== 1) {
			this.showPrevious = true;
		} else {
			this.showPrevious = false;
		}    
	}

	displayRecordPerPage(page){
		this.startingRecord = ((page -1) * this.limit) ;
		this.endingRecord = (this.limit * page);
		this.listOppTable = this.data.slice(this.startingRecord, this.endingRecord);
		this.startingRecord = this.startingRecord + 1;
	}

	handleModal(event) {
		if(this.filterList != null && this.selectedItems > 0){
			if (event.target.className === 'my-office-true') {
				this.actionType = 'oppoAsignar';
			} else {
				this.actionType = 'oppoAsignarOtraOficina';
			}		
			this.isModalOpen = true;
		}else if(this.filterList  == null){
			this.actionType = 'noEmpleado';
			this.isModalOpen = true;
		}else {
			this.actionType = 'noOppos';
			this.isModalOpen = true;
		}
	}

	doAction(event) {
		var actionType = event.detail.action;
		if (actionType == 'oppoAsignar') {
			this.handleSave();
			this.template.querySelector('[data-id="lookup1"] > c-av_-lookup').handleClearSelection();
			this.selectedItems=null;
			this.filterList = null;
		} else if (actionType == 'oppoAsignarOtraOficina') {
			this.handleSave();
			this.template.querySelector('[data-id="lookup6"] > c-av_-lookup').handleClearSelection();
			this.selectedItems=null;
			this.filterList = null;
		} else {
			this.handleCloseModal();
		}
	}

	closePillProd(event){
		let selection = event.target.dataset.value;
		let selectedpills2 = this.selectedlabels;
		let pillIndex2 = selectedpills2.indexOf(selection);
		this.selectedlabels.splice(pillIndex2, 1);
		this.filterProduct = null;
		this.selectedProducts.splice(pillIndex2, 1);
		this.template.querySelector('[data-id="searchProductMulti"]').selectedlabels = this.selectedlabels;
		this.template.querySelector('[data-id="searchProductMulti"]').selectedvalues = this.selectedProducts;
		this.template.querySelector('[data-id="searchProductMulti"]').refreshOrginalList();
		this.template.querySelector('[data-id="borderProduct"]').style.height = '';
		this.template.querySelector('[data-id="borderName"]').style.height = '';
		this.template.querySelector('[data-id="borderExp"]').style.height = '';
		this.pillSelected = false;
		this.pillSelected = true;
		if (this.selectedlabels.length === 0 && this.orderBy === 'O' && this.selectedNames.length === 0 && this.filterExpe != null) {
			this.orderBy = 'C';
			this.filters.orderBy = 'C';
		}
		this.setCookieObj('filterProduct',this.filterProduct);
		this.setCookieObj('selectedProducts',this.selectedProducts);
		this.setCookieObj('selectedlabels',this.selectedlabels);
		this.getOpp();
		this.disabledType = this.validateType();
		if (!this.disabledType) {
			this.generateOptionsTypes();
		} else {
			this.disabledType = true;
			this.type = null;
			if (this.filters != null) {
				this.filters.type = this.type;
				
			}
			this.setCookieObj('type',this.type);
			this.disabledAplicar = !this.viewFilters();
		}
	}

	closePillName(event){
		let selection = event.target.dataset.value;
		let selectedpills = this.selectedNames;
		let pillIndex = selectedpills.indexOf(selection);
		this.selectedNames.splice(pillIndex, 1);
		this.filterName = null;
		this.template.querySelector('[data-id="searchNameMulti"]').selectedvalues = this.selectedNames;
		this.template.querySelector('[data-id="searchNameMulti"]').refreshOrginalList();
		this.template.querySelector('[data-id="borderProduct"]').style.height = '';
		this.template.querySelector('[data-id="borderName"]').style.height = '';
		this.template.querySelector('[data-id="borderExp"]').style.height = '';
		this.pillSelected = false;
		this.pillSelected = true;
		if (this.selectedNames.length === 0 && this.orderBy === 'O' && this.selectedProducts.length === 0 && this.filterExpe != null) {
			this.orderBy = 'C';
			this.filters.orderBy = 'C';
		}
		this.setCookieObj('filterName',this.filterName);
		this.setCookieObj('selectedNames',this.selectedNames);

		this.getOpp();
	}

	showFiltersClick(){ 
		this.showMoreFilters = !this.showMoreFilters;
		this.setCookieObj('showMoreFilters',this.showMoreFilters);
	}

	handleSearchOffice(event) {
		this.find = event.detail.searchTerm;
		lookupSearchOffice({searchTerm: event.detail.searchTerm, selectedIds: null})
		.then((results) => {
			this.template.querySelector('[data-id="clookup2"]').setSearchResults(results.listOfi);
			this.optionAll = results.optionAll;
			this.isMultiOffi = results.isMultiOffi;
		})
		.catch((error) => {
			console.error('Lookup error', JSON.stringify(error));
			this.errors = [error];
		});
	}

	handleSearchOfficeClick(event) {
		if (this.find == '' && this.numOficinaEmpresa == null) {
			lookupSearchOffice({searchTerm: event.detail.searchTerm, selectedIds: null})
			.then((results) => {
				this.template.querySelector('[data-id="clookup2"]').setSearchResults(results.listOfi);
				this.optionAll = results.optionAll;
				this.isMultiOffi = results.isMultiOffi;
			})
			.catch((error) => {
				console.error('Lookup error', JSON.stringify(error));
				this.errors = [error];
			});
		}
	}

	getOptionsOffice() {
		lookupSearchOffice({searchTerm: this.empleOfi.substring(4), selectedIds: null})
		.then(result => {
			if (result != null && result.listOfi != null) {
				if(this.template.querySelector('[data-id="clookup2"]') != null) {
					this.template.querySelector('[data-id="clookup2"]').setSearchResults(result.listOfi);
				}
				let storageBeforeInit = JSON.parse(localStorage.getItem(COOKIESKEY))
				this.numOficinaEmpresa = 
				(storageBeforeInit?.[this.empleOfi]?.['oficina'])
					?storageBeforeInit?.[this.empleOfi]['oficina']
					:this.empleOfi.substring(4);
				
				this.initialSelectionOffice = 
					(storageBeforeInit?.[this.empleOfi]?.['oficinaVisual'])
					?storageBeforeInit?.[this.empleOfi]['oficinaVisual']
					:[{id: result.listOfi[0].id, icon:result.listOfi[0].icon, title: result.listOfi[0].title}];
				this.officeSelectedDefault = [{id: result.listOfi[0].id, icon:result.listOfi[0].icon, title: result.listOfi[0].title}];
				this.selectedOffice = this.selectedOffice === '' ? this.empleOfi.substring(4) : this.selectedOffice;
				this.optionAll = result.optionAll;
				this.getOptionsEmployee(this.empleOfi.substring(4));
			}
		}).catch(error => {
			console.log(error);
		});
	}

	handleChangeEmployee(event) {
		this.multiSelectionE++;
		this.employeeFilter = event.target.value;
		let employeeName = '';
		for(let i=0;i<this.optionsEmployee.length;i++){
			if(this.optionsEmployee[i]['value']===event.target.value){
				employeeName=this.optionsEmployee[i]['label'];
				if (employeeName.includes('Todos')) {
					this.selectedEmployees = [];
				}
				break;
			}
		}
		let insert = true;
		if(this.selectedEmployees.length > 0 ){
			if (this.selectedEmployees[0]['label'].includes('Todos')) {
				this.selectedEmployees.splice(0, 1);
			}
			for (let i = 0; i < this.selectedEmployees.length; i++) {
				if (this.selectedEmployees[i]['label']===employeeName) {
					insert = false;
					break;
				}				
			}
		}
		if (insert && employeeName != '') {
			this.selectedEmployees.push({label:employeeName,id:event.target.value,bucleId:this.multiSelectionE});
		}
		this.setCookieObj('empleadosAsignados',this.selectedEmployees);
		this.setCookieObj('employeeDefault',this.employeeFilter);
		this.employeesDiv = true;
		this.disabledAplicarMoreFilters = !this.viewMoreFilter();
		this.disabledType = this.validateType();
		if (!this.disabledType) {
			this.generateOptionsTypes();
		} else {
			this.disabledType = true;
			this.type = null;
			if (this.filters != null) {
				this.filters.type = this.type;
			}
			this.setCookieObj('type',this.type);

			this.disabledAplicar = !this.viewFilters();
		}
	}

	handleAnotherOffice(event) {
		if (this.numOficinaEmpresa != null && this.selectedEstado != null && this.selectedEstado.length > 0 && this.origenFilter != null) {
			this.isAnotherOffice = event.detail.checked;
			this.selectedEmployees = [];
			if (event.detail.checked === true) {
				this.optionsEmployeeAux = this.optionsEmployee;
				this.employeeFilter = '';
				var statusAll = '';
				if (this.selectedEstado.length > 1) {
					for (var i = 0; i < this.selectedEstado.length; i++) {
						if (i === this.selectedEstado.length) {
							statusAll = statusAll + this.selectedEstado[i]['id'];
						} else {
							statusAll = statusAll + this.selectedEstado[i]['id'] +',';
						}
					}
				} else {
					statusAll = this.selectedEstado[0]['id'];
				}
				var data = this.numOficinaEmpresa+'{|}'+statusAll+'{|}'+this.origenFilter;
				this.getOptionsEmployee(data);
				this.employeesDiv = false;
			} else {
				this.optionsEmployee = this.optionsEmployeeAux;
				this.employeeFilter = this.employeeDefault;
				this.handleChangeEmployee(new Object({'target': {'value':this.employeeFilter}}));
				this.employeesDiv = true;
			}
		} else {
			const el = this.template.querySelector('.another-office');
			el.checked = false;
			this.optionsEmployee = this.optionsEmployeeAux;
			this.employeeFilter = this.employeeDefault;
			this.handleChangeEmployee(new Object({'target': {'value':this.employeeFilter}}));
			this.employeesDiv = true;
			this.isAnotherOffice = false;
			const evt = new ShowToastEvent({
				title: 'Filtro incorrecto',
				message: 'Los campos oficina, etapa y origen deben estar informados.',
				variant: 'info',
				mode: 'dismissable'
			});
			this.dispatchEvent(evt);
		}
		this.setCookieObj('isAnotherOffice',this.isAnotherOffice);
		this.setCookieObj('empleadosAsignados',this.selectedEmployees);
		this.disabledAplicarMoreFilters = !this.viewMoreFilter();
		this.disabledType = this.validateType();
		if (!this.disabledType) {
			this.generateOptionsTypes();
		} else {
			this.disabledType = true;
			this.type = null;
			if (this.filters != null) {
				this.filters.type = this.type;
			}
			this.setCookieObj('type',this.type);

			this.disabledAplicar = !this.viewFilters();
		}
	}

	getUserInfo(){
		enanchedGetUserInfo({userId:USER_ID})
		.then(data => {

			if(data){
			let gestor = data.gestor;
			this.empleFuncion = gestor.AV_Funcion__c;
			this.empleOfi = gestor.AV_NumeroOficinaEmpresa__c === null ? '': gestor.AV_NumeroOficinaEmpresa__c;
			this.numOficinaEmpresa = this.empleOfi.split('-')[1];
			this.numOfficeDefault = this.empleOfi.split('-')[1];
			this.isDirector = this.directores.includes(this.empleFuncion);
			this.empleName = gestor.Name;
			
			this.getOptionsOffice();
			if (this.currentPageReference.state.c__singestor != null && this.currentPageReference.state.c__singestor[0] === AV_NotAssigned) {
				this.selectedEmployees = [{label:this.currentPageReference.state.c__singestor[0],id:this.currentPageReference.state.c__singestor[1],bucleId:this.multiSelectionE}];
			}else{
				if(this.currentFilterStorageObj[this.empleOfi]?.['empleadosAsignados'] == null || this.currentFilterStorageObj[this.empleOfi]?.['empleadosAsignados'] == 0 ){
					if(data.multigestor != undefined && data.multigestor != null){
						this.multigestor = data.multigestor.Id;
						this.selectedEmployees = [{label:this.empleName,id:USER_ID,bucleId:this.multiSelectionE},{label:'Banca de Particulares',id:data.multigestor.Id,bucleId:++this.multiSelectionE}];
					}else{
						this.selectedEmployees = [{label:this.empleName,id:USER_ID,bucleId:this.multiSelectionE}];

					}
				}
			}
			this.selectedEmployeesDefault = [{label:this.empleName,id:USER_ID,bucleId:this.multiSelectionE}];
			if(this.multigestor != null){
				this.selectedEmployeesDefault.push({label:'Banca de Particulares',id:data.multigestor.Id,bucleId:++this.multiSelectionE});
			}
			this.selectedEstado= [{label:'Potencial',id:'Potencial',bucleId:this.multiSelectionS},{label:'En Gestión',id:'En gestión/insistir',bucleId:(this.multiSelectionS+1)}];
			this.selectedEstadoDefault= [{label:'Potencial',id:'Potencial',bucleId:this.multiSelectionS},{label:'En Gestión',id:'En gestión/insistir',bucleId:(this.multiSelectionS+1)}];
			if(!this.applyStorage){
				this.buildCookies();
				this.filters = {
					preconcedido: this.preconcedido,
					myBox: this.myBox,
					targetAuto: this.targetAuto,
					orderBy: this.orderBy,
					orderingCriterion: this.orderingCriterion,
					limite: this.limit,
					type: this.type
				};
			}
		
			this.multiSelectionS++;
			var employee = this.selectedEmployees.slice();
			var stage = this.selectedEstado.slice();
			var segmento = this.selectedIndicadores.slice();

			this.moreFilters = {
				oficina : this.numOficinaEmpresa,
				employee : employee,
				origen : this.origenFilter,
				stage : stage,
				expSale : this.potencial,
				dateProFrom : this.fechaGestionFrom,
				dateProUntil : this.fechaGestionUntil,
				dateVenFrom : this.fechaVencimientoFrom,
				dateVenUntil : this.fechaVencimientoUntil,
				dateModFrom : this.fechaModificacionFrom,
				dateModUntil : this.fechaModificacionUntil,
				segmento : segmento
			};
	
			this.getOpp();
		}else if(error){
			console.log(error);
		}
	}).catch(error => {
		console.error(error);
	})
	}

	getOptionsEmployee(data){
		this.loadingEmployee = true;
		this.multiSelectionE++;
		getEmployees({officeFilterData: data})
		.then(result => {
			if(result != null && result.length > 1) {
				if((this.origenFilter === 'all') && result.length > 0 && result[0].label.includes('Todos')){
					result.shift();
				}

				this.optionsEmployee = result;
				if ((!this.isAnotherOffice && this.isDirector) || (!this.isDirector && this.isMultiOffi)) {
					if (!JSON.stringify(this.optionsEmployee).includes(USER_ID)) {
						this.optionsEmployee.push({value:USER_ID,label:this.empleName});
					}
				}
				this.optionsEmployee.push({value:'',label:''});
				if(this.isAnotherOffice === false){
					if (this.currentPageReference.state.c__singestor != null && this.currentPageReference.state.c__singestor[0] === AV_NotAssigned) {
						this.employeeFilter = this.currentPageReference.state.c__singestor[1];
						this.selectedEmployees = [{label:this.currentPageReference.state.c__singestor[0],id:this.currentPageReference.state.c__singestor[1],bucleId:this.multiSelectionE}];
					}else {
						if(this.currentFilterStorageObj[this.empleOfi] != null){
							if((this.currentFilterStorageObj[this.empleOfi]?.['empleadosAsignados'] == null || this.currentFilterStorageObj[this.empleOfi]?.['empleadosAsignados'] == undefined || this.firstEmployeeFilling)){

								this.employeeFilter = this.employeeDefault;
								if(this.multigestor != undefined && this.multigestor != null){
									this.selectedEmployees = [{label:this.empleName,id:USER_ID,bucleId:this.multiSelectionE},{label:'Banca de Particulares',id:this.multigestor,bucleId:++this.multiSelectionE}];
								}else{
									this.selectedEmployees = [{label:this.empleName,id:USER_ID,bucleId:this.multiSelectionE}];
			
								}
							}
						}else if(this.currentFilterStorageObj[this.empleOfi]?.['empleadosAsignados' != null && this.currentFilterStorageObj[this.empleOfi]?.['empleadosAsignados'].length > 0] && !this.firstEmployeeFilling){
							this.firstEmployeeFilling = true;
						}
					}
					
				}
			} else if (result != null) {
				this.optionsEmployee = result;
				if (!this.isDirector && this.isMultiOffi) {
					if (!JSON.stringify(this.optionsEmployee).includes(USER_ID)) {
						this.optionsEmployee.push({value:USER_ID,label:this.empleName});	
					}
				}
				this.optionsEmployee.push({value:'',label:''});
				if (this.isMultiOffi) {
					if (this.currentPageReference.state.c__singestor != null && this.currentPageReference.state.c__singestor[0] === AV_NotAssigned) {
						this.employeeFilter = this.currentPageReference.state.c__singestor[1];
						this.selectedEmployees = [{label:this.currentPageReference.state.c__singestor[0],id:this.currentPageReference.state.c__singestor[1],bucleId:this.multiSelectionE}];
					}else{
						this.employeeFilter = this.employeeDefault;
						if(this.multigestor != undefined && this.multigestor != null){
							this.selectedEmployees = [{label:this.empleName,id:USER_ID,bucleId:this.multiSelectionE},{label:'Banca de Particulares',id:this.multigestor,bucleId:++this.multiSelectionE}];
						}else{
							this.selectedEmployees = [{label:this.empleName,id:USER_ID,bucleId:this.multiSelectionE}];
	
						}
					}
				} else {
					this.employeeFilter = '';
					this.selectedEmployees = [];
				}
			}
			this.disabledType = this.validateType();
			if (!this.disabledType) {
				this.generateOptionsTypes();
			} else {
				this.disabledType = true;
				this.type = null;
				if (this.filters != null) {
					this.filters.type = this.type;
				}
				this.setCookieObj('type',this.type);

				this.disabledAplicar = !this.viewFilters();
			}
			this.loadingEmployee = false;
		}).catch(error => {
			this.loadingEmployee = false;
			console.log(error);
		});
	}

	unSelectEmployee(cmp){
		let divToDel = cmp.target.parentNode;
		for(let i=0;i<this.selectedEmployees.length;i++){
			if(this.selectedEmployees[i].id === cmp.target.name){
				this.selectedEmployees.splice(i,1);
			} else if (this.selectedEmployees[i].id != null) {
				this.employeeFilter = this.selectedEmployees[i].id;
			}
		}
		this.setCookieObj('empleadosAsignados',this.selectedEmployees);
		divToDel.classList.add('delete');
		cmp.target.remove();
		if (this.selectedEmployees.length === 0) {
			this.employeesDiv = false;
			this.employeeFilter = '';
		}
		this.disabledAplicarMoreFilters = !this.viewMoreFilter();
		this.disabledType = this.validateType();
		if (!this.disabledType) {
			this.generateOptionsTypes();
		} else {
			this.disabledType = true;
			this.type = null;
			if (this.filters != null) {
				this.filters.type = this.type;
			}
			this.setCookieObj('type',this.type);

			this.disabledAplicar = !this.viewFilters();
		}
	}

	handleChangeOrigen(event) {
		this.origenFilter = event.target.value;
		this.setCookieObj('origen',this.origenFilter);
		if (this.isAnotherOffice === true) {
			this.handleAnotherOffice(new Object({'detail': {'checked': true}}));
		}else{
			this.getOptionsEmployee(this.numOficinaEmpresa);
		}
		this.disabledAplicarMoreFilters = !this.viewMoreFilter();
	}

	handleChangeEstado(event) {
		this.multiSelectionS++;
		var statusName = '';
		for(let i=0;i<this.optionsOppoStatus.length;i++){
			if(this.optionsOppoStatus[i]['value']===event.target.value){
				statusName=this.optionsOppoStatus[i]['label'];
				break;
			}
		}
		let insert = true;
		if(this.selectedEstado.length > 0){
			for (let i = 0; i < this.selectedEstado.length; i++) {
				if (this.selectedEstado[i]['id']===event.target.value) {
					insert = false;
					break;
				}				
			}
		}
		if (insert && event.target.value != '') {
			this.statusFilter = event.target.value;
			this.selectedEstado.push({label:statusName,id:event.target.value,bucleId:this.multiSelectionS});
		}
		this.setCookieObj('stage',this.selectedEstado);
		if (this.isAnotherOffice === true) {
			this.handleAnotherOffice(new Object({'detail': {'checked': true}}));
		}
		if (event.target.value != '') {
			this.estadoDiv = true;
		}
		this.disabledAplicarMoreFilters = !this.viewMoreFilter();
	}
	
	unSelectEstado(cmp){
		let divToDel = cmp.target.parentNode;
		for(let i=0;i<this.selectedEstado.length;i++){
			if(this.selectedEstado[i].id === cmp.target.name){
				this.selectedEstado.splice(i,1);
			} else if (this.selectedEstado[i].id != null){
				this.statusFilter = this.selectedEstado[i].id;
			}
		}
		this.setCookieObj('stage',this.selectedEstado);
		divToDel.classList.add('delete');
		cmp.target.remove();
		if (this.selectedEstado.length === 0) {
			this.estadoDiv = false;
			this.statusFilter = '';
		}
		if (this.isAnotherOffice === true) {
			this.handleAnotherOffice(new Object({'detail': {'checked': true}}));
		}
		this.disabledAplicarMoreFilters = !this.viewMoreFilter();
	}

	handleChangePotencial(e){
		this.potencial = e.target.value;
		this.setCookieObj('expectativa',this.potencial);
		this.disabledAplicarMoreFilters = !this.viewMoreFilter();
	}

	handleChangeIndicadorCli(event) {
		this.valueNull = '';
		this.multiSelectionIndicador++;
		let indicadorName = '';
		let itemToUnlist;
		for(let i=0;i<this.optionsIndicadorCli.length;i++){
			if(this.optionsIndicadorCli[i]['value']===event.target.value){
				indicadorName=this.optionsIndicadorCli[i]['label'];
				itemToUnlist = this.optionsIndicadorCli[i]['value'];
				break;
			}
		}
		this.getOptionsIndicadorCli(itemToUnlist);
		let insert = true;
		if (insert && indicadorName != '') {
			this.selectedIndicadores.push({label:indicadorName,id:event.target.value,bucleId:this.multiSelectionIndicador});
			this.selectedIndicadoresDiv = true;
		}
		this.setCookieObj('segmentos',this.selectedIndicadores);
		this.disabledAplicarMoreFilters = !this.viewMoreFilter();
	}
	
	getOptionsIndicadorCli(alreadySelectedValue){
		if(this.copyOptionsIndicador.length ===0){
			optionsIndicador()
			.then(result => {
				result.unshift({label:'',value:null});
				this.copyOptionsIndicador= result;
				this.optionsIndicadorCli = result;
			});
			
		}else{
			this.optionsIndicadorCli = [];
			if(alreadySelectedValue != null){
				this.removedIndicadores.push(alreadySelectedValue);
			}
			this.copyOptionsIndicador.forEach(indi =>{
				if(!this.removedIndicadores.includes(indi['value'])){
					this.optionsIndicadorCli.push(indi);
				}
			});
		}
	}

	unSelectIndicador(cmp){
		var itemToListReturnValue;
		for(let i=0;i<this.selectedIndicadores.length;i++){
			if(this.selectedIndicadores[i].id === cmp.target.name){
				this.selectedIndicadores.splice(i,1);
				itemToListReturnValue= cmp.target.name;
				break;
			}
		}
		for(let i=0;i<this.removedIndicadores.length;i++){
			if(this.removedIndicadores[i] === itemToListReturnValue){
				this.removedIndicadores.splice(i,1);
				break;
			}
		}
		this.getOptionsIndicadorCli();
		this.selectedIndicadoresDiv = (this.selectedIndicadores.length != 0);
		this.setCookieObj('segmentos',this.selectedIndicadores);
		this.valueNull = null;
		this.disabledAplicarMoreFilters = !this.viewMoreFilter();
	}
	
	handleChangeFechaGestionFrom(event) {
		this.fechaGestionFrom = event.target.value;
		this.setCookieObj('proximaGestionDesde',this.fechaGestionFrom);
		this.disabledAplicarMoreFilters = !this.viewMoreFilter();
	}
	
	handleChangeFechaGestionUntil(event) {
		this.fechaGestionUntil = event.target.value;
		this.setCookieObj('proximaGestionHasta',this.fechaGestionUntil);
		this.disabledAplicarMoreFilters = !this.viewMoreFilter();
	}
	
	handleChangeFechaVencimientoFrom(event) {
		this.fechaVencimientoFrom = event.target.value;
		this.setCookieObj('fechaVencimientoDesde',this.fechaVencimientoFrom);
		this.disabledAplicarMoreFilters = !this.viewMoreFilter();
	}
	
	handleChangeFechaVencimientoUntil(event) {
		this.fechaVencimientoUntil = event.target.value;
		this.setCookieObj('fechaVencimientoHasta',this.fechaVencimientoUntil);
		this.disabledAplicarMoreFilters = !this.viewMoreFilter();
	}
	
	handleChangeFechaModificacionFrom(event) {
		this.fechaModificacionFrom = event.target.value;
		this.setCookieObj('fechaUltimaModificacionDesde',this.fechaModificacionFrom);
		this.disabledAplicarMoreFilters = !this.viewMoreFilter();
	}
	
	handleChangeFechaModificacionUntil(event) {
		this.fechaModificacionUntil = event.target.value;
		this.setCookieObj('fechaUltimaModificacionHasta',this.fechaModificacionUntil);
		this.disabledAplicarMoreFilters = !this.viewMoreFilter();
	}
	emptySelectedRows(){
		this.selectedRowsStorage = [];
		this.setCookieObj('selectedRows',[]);

	}
	handleAplicarMoreFilters() {
		if(this.selectedEmployees != null && this.numOficinaEmpresa != null && this.origenFilter != null && this.selectedEstado != null && this.selectedEstado.length > 0 && this.selectedEmployees.length > 0 && ((this.fechaGestionFrom != null && this.fechaGestionUntil != null && this.fechaGestionFrom <= this.fechaGestionUntil) || this.fechaGestionUntil == null || this.fechaGestionFrom == null) && ((this.fechaVencimientoFrom != null && this.fechaVencimientoUntil != null && this.fechaVencimientoFrom <= this.fechaVencimientoUntil) || this.fechaVencimientoUntil == null || this.fechaVencimientoFrom == null) && ((this.fechaModificacionFrom != null && this.fechaModificacionUntil != null && this.fechaModificacionFrom <= this.fechaModificacionUntil) || this.fechaModificacionUntil == null || this.fechaModificacionFrom == null)) {
			this.emptySelectedRows();
			var employee = this.selectedEmployees.slice();
			var stage = this.selectedEstado.slice();
			var segmento = this.selectedIndicadores.slice();
			this.moreFilters = {
				oficina : this.numOficinaEmpresa,
				employee : employee,
				origen : this.origenFilter,
				stage : stage,
				expSale : this.potencial,
				dateProFrom : this.fechaGestionFrom,
				dateProUntil : this.fechaGestionUntil,
				dateVenFrom : this.fechaVencimientoFrom,
				dateVenUntil : this.fechaVencimientoUntil,
				dateModFrom : this.fechaModificacionFrom,
				dateModUntil : this.fechaModificacionUntil,
				segmento : segmento
			};
			this.disabledAplicarMoreFilters = true;
			this.resetTablePag();
			this.destacadas = false;
			this.setCookieObj('destacadas',false);
			this.getOpp();
		} else if(this.fechaGestionFrom != null && this.fechaGestionUntil != null && this.fechaGestionFrom > this.fechaGestionUntil) {
			const evt = new ShowToastEvent({
				title: 'Filtro incorrecto',
				message: 'El campo "Fecha de próxima gestión (desde)" debe de ser menor que el campo "Fecha de próxima gestión (hasta)".',
				variant: 'error',
				mode: 'error'
			});
			this.dispatchEvent(evt);
		} else if(this.fechaVencimientoFrom != null && this.fechaVencimientoUntil != null && this.fechaVencimientoFrom > this.fechaVencimientoUntil) {
			const evt = new ShowToastEvent({
				title: 'Filtro incorrecto',
				message: 'El campo "Fecha de vencimiento (desde)" debe de ser menor que el campo "Fecha de vencimiento (hasta)".',
				variant: 'error',
				mode: 'error'
			});
			this.dispatchEvent(evt);
		} else if(this.fechaModificacionFrom != null && this.fechaModificacionUntil != null && this.fechaModificacionFrom > this.fechaModificacionUntil) {
			const evt = new ShowToastEvent({
				title: 'Filtro incorrecto',
				message: 'El campo "Fecha de última modificación (desde)" debe de ser menor que el campo "Fecha de última modificación (hasta)".',
				variant: 'error',
				mode: 'error'
			});
			this.dispatchEvent(evt);
		} else {
			const evt = new ShowToastEvent({
				title: 'Filtro incorrecto',
				message: 'Los campos oficina, empleado asignado, origen y etapa deben estar informados.',
				variant: 'error',
				mode: 'error'
			});
			this.dispatchEvent(evt);
		}
	}

	viewMoreFilter() {
		var resultado = false;
		if (this.moreFilters != null && this.moreFilters.oficina != this.numOficinaEmpresa) {
			resultado = true;
		} else if (this.moreFilters != null && this.viewListSelected(this.moreFilters.employee, this.selectedEmployees)) {
			resultado = true;
		} else if (this.moreFilters != null && this.moreFilters.origen != this.origenFilter) {
			resultado = true;
		} else if (this.moreFilters != null && this.viewListSelected(this.moreFilters.stage, this.selectedEstado)) {
			resultado = true;
		} else if (this.moreFilters != null && this.moreFilters.expSale != this.potencial) {
			resultado = true;
		} else if (this.moreFilters != null && this.moreFilters.dateProFrom != this.fechaGestionFrom) {
			resultado = true;
		} else if (this.moreFilters != null && this.moreFilters.dateProUntil != this.fechaGestionUntil) {
			resultado = true;
		} else if (this.moreFilters != null && this.moreFilters.dateVenFrom != this.fechaVencimientoFrom) {
			resultado = true;
		} else if (this.moreFilters != null && this.moreFilters.dateVenUntil != this.fechaVencimientoUntil) {
			resultado = true;
		} else if (this.moreFilters != null && this.moreFilters.dateModFrom != this.fechaModificacionFrom) {
			resultado = true;
		} else if (this.moreFilters != null && this.moreFilters.dateModUntil != this.fechaModificacionUntil) {
			resultado = true;
		} else if (this.moreFilters != null && this.viewListSelected(this.moreFilters.segmento, this.selectedIndicadores)) {
			resultado = true;
		}
		return resultado;
	}

	viewListSelected(moreFilter, selected) {
		var resultado = false;;
		if (moreFilter.length === selected.length) {
			var coin = 0;
			for (var i = 0;i < moreFilter.length; i++) {
				for (var a = 0;a < selected.length; a++) {
					if (moreFilter[i].id === selected[a].id) {
						coin++;
						break;
					}
				}
				if (coin === i) {
					resultado = true;
					break;
				}
			}
		} else {
			resultado = true;
		} 
		return resultado;
	}

	tabDataTableBasic() {
		this.dataFromTable = true;
		this.template.querySelector('[data-id="DataBasic"]').className = 'slds-tabs_default__item slds-is-active';
		this.template.querySelector('[data-id="DataClient"]').className = 'slds-tabs_default__item';
		this.setCookieObj('dataFromTable',this.dataFromTable);
		this.setCookieObj('selectedRows',[]);
		this.selectedRowsStorage = [];
	}

	tabDataTableClient(){
		this.dataFromTable = false;
		this.template.querySelector('[data-id="DataClient"]').className = 'slds-tabs_default__item slds-is-active';
		this.template.querySelector('[data-id="DataBasic"]').className = 'slds-tabs_default__item';
		this.setCookieObj('dataFromTable',this.dataFromTable);
		this.setCookieObj('selectedRows',[]);
		this.selectedRowsStorage = [];
	}

	handleType(event) {
		this.type = event.target.value;
		this.setCookieObj('type',this.type);
		this.disabledAplicar = !this.viewFilters();
	}

	validateType() {
		var resultado = false;
		var employee = this.selectedEmployees.slice();
		if (this.numOficinaEmpresa == null) {
			resultado = true;
		} else if (employee == null || (employee != null && (employee.length == 0 || employee.length > 1)) || (employee != null && employee.length == 1 && employee[0].label.includes(AV_NotAssigned))) {
			resultado = true;
		} else if (this.selectedProducts == null || (this.selectedProducts != null && this.selectedProducts.length == 0)) {
			resultado = true;
		}
		return resultado;
	}

	generateOptionsTypes() {
		getTypesOptions({oficina: this.numOficinaEmpresa, employee: this.selectedEmployees.slice()[0].id, listProducts: this.selectedProducts})
		.then(result => {
			if (result != null) {
				this.optionsType = result;
			}
		}).catch(error => {
			console.log(error);
		});
	}

	
}