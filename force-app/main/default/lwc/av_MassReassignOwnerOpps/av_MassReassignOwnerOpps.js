import { LightningElement, track, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getRecord } from 'lightning/uiRecordApi';
import fetchData from '@salesforce/apex/AV_MassReassignOwnerOpps_Controller.getBaseData';
import lookupSearch from '@salesforce/apex/AV_MassReassignOwnerOpps_Controller.search';
import lookupSearchProduct from '@salesforce/apex/AV_MassReassignOwnerOpps_Controller.searchProduct';
import lookupSearchAccount from '@salesforce/apex/AV_MassReassignOwnerOpps_Controller.searchAccount';
import lookupSearchOffice from '@salesforce/apex/AV_MassReassignOwnerOpps_Controller.searchOffice';
import getEmployees from '@salesforce/apex/AV_MassReassignOwnerOpps_Controller.getEmployees';
import assign from '@salesforce/apex/AV_MassReassignOwnerOpps_Controller.assign';
import nameContactAssign from '@salesforce/apex/AV_MassReassignOwnerOpps_Controller.nameContactAssign';
import optionsIndicador from '@salesforce/apex/AV_MassReassignOwnerOpps_Controller.getIndicadorCliOptions';
import isBankTeller from '@salesforce/apex/AV_AppUtilities.isBankTeller';
import recordLimitLabel from '@salesforce/label/c.AV_BuscadorRecordLimit';
import USER_ID from '@salesforce/user/Id';
import NAME_FIELD from'@salesforce/schema/User.Name';
import FUNCTION from '@salesforce/schema/User.AV_Funcion__c';
import OFICINA from '@salesforce/schema/User.AV_NumeroOficinaEmpresa__c';


const columnsOpp = [
	{ label: 'Cliente', fieldName: 'AccountNameURL', type: 'url', typeAttributes: {label: { fieldName: 'AccountName' }, tooltip:{fieldName: 'AccountName'} }, hideDefaultActions: true, wrapText:true, sortable: true, sortBy:'AccountName'},
	{ label: 'Origen', fieldName: 'AV_Origen__c', type: 'text',hideDefaultActions: true, sortable: true, sortBy:'AV_Origen__c'},
	{ label: 'Producto', fieldName: 'PFName', type: 'text', hideDefaultActions: true, sortable: true, sortBy:'PFName' },
	{ label: 'Etapa', fieldName: 'StageName',type: 'text', hideDefaultActions: true , sortable: true, sortBy:'StageName' },
	{ label: 'Nombre de la oportunidad', fieldName: 'OppNameURL', type: "url",	typeAttributes:{ label: { fieldName: 'Name' }, tooltip:{fieldName: 'Name'}}, hideDefaultActions: true, wrapText:true, sortable: true, sortBy:'Name'},
	{ label: 'Expectativa de venta', fieldName: 'AV_Potencial__c',type: 'text', hideDefaultActions: true, sortable: true, sortBy:'AV_Potencial__c' },
	{ label: 'Edad', fieldName: 'AV_Age__c',type: 'number', hideDefaultActions: true, sortable: true, sortBy:'AV_Age__c' },
	{ label: 'Ahorro e Inversión', fieldName: 'AV_AhorroEInversion__c',type: 'currency', hideDefaultActions: true, sortable: true, sortBy:'AV_AhorroEInversion__c', typeAttributes: {minimumFractionDigits: 0, maximumFractionDigits: 2} },
	{ label: 'Financiacion', fieldName: 'AV_Financiacion__c',type: 'currency', hideDefaultActions: true, sortable: true, sortBy:'AV_Financiacion__c' },
	{ label: 'Ingresos', fieldName: 'AV_Ingresos__c',type: 'currency', hideDefaultActions: true, sortable: true, sortBy:'AV_Ingresos__c' },
	{ label: 'Preconcedido', fieldName: 'AV_Preconceived__c',type: 'number', hideDefaultActions: true, sortable: true, sortBy:'AV_Preconceived__c' },
	{ label: 'My Box', fieldName: 'AV_MyBox__c', type: 'picklist', hideDefaultActions: true, sortable: true, sortBy:'AV_MyBox__c' },
	{ label: 'Target Auto', fieldName: 'AV_TargetAuto__c', type:'picklist', hideDefaultActions: true, sortable: true, sortBy:'AV_TargetAuto__c' },
	{ label: 'Fecha de vencimiento', fieldName: 'CloseDate', type: "date-local",typeAttributes:{ month: "2-digit", day: "2-digit" }, sortable: true, sortBy:'CloseDate'},
	{ label: 'Fecha de próxima gestión', fieldName: 'AV_FechaProximoRecordatorio__c',  type: "date-local",typeAttributes:{ month: "2-digit", day: "2-digit" }, sortable: true, sortBy:'AV_FechaProximoRecordatorio__c'},
	{ label: 'Empleado asignado', fieldName: 'OwnerNameURL', type: 'url',	typeAttributes:{ label: { fieldName: 'OwnerName' }}, hideDefaultActions: true, wrapText:true, sortable: true, sortBy:'OwnerName'},
	{ label: 'Oficina', fieldName: 'officeRow', type: 'text', hideDefaultActions: true, sortable: true, sortBy:'officeRow' },
	{ label: 'Indicador Priorizador', fieldName: 'AV_IncludeInPrioritizingCustomers__c',type: 'boolean', sortable: true, sortBy:'AV_IncludeInPrioritizingCustomers__c'}
	
];

 
export default class Av_MassReassignOwnerOpps extends LightningElement {

	@track data;
	@track targetObjName = 'Opportunity';
	@track columns;
	@track iconName;
	@track totalRecountCount;
	@track showSpinner = false;
	@track firstSearch = false;
	initialSelection = [];
	initialSelectionOffice = [];
	errors = [];
	isMultiEntry = false;
	employeeLabel = 'Asignar a:';
	employeePlaceholder = 'Buscar empleado...';
	clientPlaceholder = 'Buscar cliente...';
	officePlaceholder = 'Buscar oficina...';
 	@track optionsEmployee = [];
	optionsEmployeeAux = []; // used when other employee's toggle is checked
	employeeDefault = USER_ID;
	showDetail = false;
	sortedBy;
	defaultSortDirection = 'asc';
    sortDirection = 'asc';
	showAssignment = true;
	totalNumberOfRecords;
	size = 0;
	MAX_PAGE_NUM = 20; //Query offset limit = 2000 (100 records * 20 pages)
	helpMessage = false;
	recordLimit = recordLimitLabel;
	selectedEmployees = [];
	selectedProducts = [];
	showSelectedProducts;
	selectedOffice = '';
	empleFuncion;
	isDirector;
	directores = ['DC','DT','DAN','SSCC'];
	buttonDisabled = true;
	@track seeFiltersLabel = '';
	@track optionsIndicadorCli = [];
	multiSelectionE=0;
	multiSelectionS=0;
	employeesDiv = true;
	showMoreFiltersDiv = false;
	employeMultiFilter = [];
	productsMultiFilter = [];
	myBoxFilter = null;
	preconceivedFilter = null;
	targetAutoFilter = null;
	numOficinaEmpresa = null;
	isAnotherOffice = false;
	todosLookUpCmp = null;
	multiSelectionIndicador = 0;
	removedIndicadores = [];
	copyOptionsIndicador = [];

	//delete
	@track evaluated = false;
	@track taskFilter = false;
	@track oppFilter = false;
	@track subjectFilter = null;
	@track FechaGestionFilter = null;
	@track FechaCierreFilter = null;
	@track employeeFilter = this.employeeDefault;
	@track dueDate2Filter = null;
	@track dueDateFilter = null;
	@track statusFilter = 'En gestión/insistir';
	@track origenFilter = 'AV_Iniciativa';
	@track clientFilter;
	@track filterList;
	@track contactName;
	@track selectedRows = [];
	@track opps; //All opportunities available for data table    
    @track showTable = false; //Used to render table after we get the data from apex controller    
    @track recordsToDisplay = []; //Records to be displayed on the page
    @track rowNumberOffset; //Row number
	@track selectedItems = 0;
	@track isModalOpen = false;
	@track actionType;
	@track office = null;
	//Paginación
	@track items;
	@track totalPage = 0;
	@track startingRecord = 1;
    @track endingRecord = 0; 
    @track pageSize = 100; 
	@track page = 1; 
	@track isMultipagina = true;
	@track isMultiEntry2 = false;
	@track filterProduct;
	@track indicadoresDiv = false;
	@track 	selectedIndicadores = [];
	@track 	selectedIndicadoresDiv = false;
	nullValue = null;

	

	
	@wire(getRecord,{ recordId:USER_ID, fields:[NAME_FIELD,FUNCTION,OFICINA]})
	wiredUser({error,data}){		
		if(data){
			
			this.empleFuncion = data.fields.AV_Funcion__c.value;
			this.empleOfi = data.fields.AV_NumeroOficinaEmpresa__c.value === null ? '': data.fields.AV_NumeroOficinaEmpresa__c.value;
			this.numOficinaEmpresa = this.empleOfi.split('-')[1];
			this.isDirector = this.directores.includes(this.empleFuncion);
			this.empleName = data.fields.Name.value;
			this.getOptionsOffice();
			this.selectedEmployees = [{label:this.empleName,id:USER_ID,bucleId:this.multiSelectionE}];
			this.setButtonVisibility();
		}else if(error){
			console.log(error)
		}
	}

	connectedCallback() {
		this.showDetail = true;
		this.getOptionsIndicadorCli();
	}

	get optionsTaskStatus() {
		return [
			{ label: '', value: null },
			{ label: 'Pendiente', value: 'Open' },
			{ label: 'Pendiente no localizado', value: 'Pendiente no localizado' }
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
	get optionsOppoStatus() {
		return [
			{ label: 'Potencial', value: 'Potencial' },
			{ label: 'En Gestión', value: 'En gestión/insistir' },
			{ label: 'Cerrada negativa', value: 'No interesado'},
			{ label: 'Producto Rechazado', value: 'Producto Rechazado'},
			{ label: 'Cerrada positiva', value: 'Cerrado positivo'},
			{ label: 'Producto Contratado', value: 'Producto Contratado'},
			{ label: 'Vencida', value: 'Vencido'},
			{ label: 'Con venta', value: 'Con venta'}
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

	get optionsTaskOrigen() {
		return [
			{ label: '', value: null },
			{ label: 'Experiencia Cliente', value: 'Experiencia Cliente' },
			{ label: 'Avisos', value: 'Avisos' },
			{ label: 'Tareas AVE', value: 'Tareas AVE' },
			{ label: 'Alertas Comerciales', value: 'Alertas Comerciales' },
			{ label: 'Onboarding Intouch', value: 'Onboarding Intouch' },
			{ label: 'Iniciativa Gestor/a', value: 'Iniciativa Gestor/a' },
			{ label: 'Priorizador', value: 'Priorizador' }
		];
	}

	get optionsYesOrNo(){
		return[
			{label: 'Sí', value:'S'},
			{label: 'No', value:'N'},
			{label: '', value: null}
		];
	}

	get optionsPrecon(){
		return[
			{label: 'Sí', value:'true'},
			{label: 'No', value:'false'},
			{label: '', value: null}
		];
	}

	getOptionsOffice() {
		lookupSearchOffice({searchTerm: this.empleOfi.substring(4), selectedIds: null})
		.then(result => {
				if (result != null) {
					this.template.querySelector('[data-id="clookup5"]').setSearchResults(result);
					this.template.querySelector('[data-id="clookup5"]').scrollIntoView();
					this.numOficinaEmpresa = this.empleOfi.substring(4);
					this.initialSelectionOffice=[{id: result[0].id, icon:result[0].icon, title: result[0].title}];
					this.selectedOffice = this.selectedOffice === '' ? this.empleOfi.substring(4) : this.selectedOffice;
					this.getOptionsEmployee(this.empleOfi.substring(4));
					this.setButtonVisibility();
				}
			}).catch(error => {
				console.log(error);
			})
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

	getOptionsEmployee(data){
		getEmployees({officeFilterData: data})
			.then(result => {
			if(result != null && result.length > 0) {
				if((this.origenFilter === 'all') && result.length > 1){
					result.shift();
				}
				this.optionsEmployee = result;
				if (!this.isAnotherOffice && this.isDirector) {
					if (!JSON.stringify(this.optionsEmployee).includes(USER_ID)) {
						this.optionsEmployee.push({value:USER_ID,label:this.empleName});
					}
				}
				if(this.isAnotherOffice === false){
					this.employeeFilter = this.employeeDefault;
					this.selectedEmployees = [{label:this.empleName,id:this.employeeDefault,bucleId:this.multiSelectionE}];
					this.setButtonVisibility();
				}
			}
		}).catch(error => {
			console.log(error);
		})
	}

	getDataList(clientFilter, subjectFilter, origenFilter, statusFilter, dueDate2Filter, dueDateFilter, employeMultiFilter, productsMultiFilter, FechaCierreFilter, FechaGestionFilter, page, myBoxFilter, preconceivedFilter, targetAutoFilter, numOficinaEmpresa,potencial,fechaModif,indicadoresFilter) {
		fetchData({clientFilter: clientFilter, subjectFilter : subjectFilter , origenFilter : origenFilter, statusFilter : statusFilter, dueDate2Filter : dueDate2Filter , dueDateFilter : dueDateFilter, employeeFilter : employeMultiFilter, filterList: productsMultiFilter, fechaCierreFilter : FechaCierreFilter, fechaGestionFilter : FechaGestionFilter, page : page, myBoxFilter : myBoxFilter, preconceivedFilter : preconceivedFilter, targetAutoFilter : targetAutoFilter, office : numOficinaEmpresa, potencial: potencial,fechaModif:fechaModif,indicadoresCli:indicadoresFilter})
			.then(result => {
				this.targetObjName === 'Opportunity';
				this.helpMessage = false;
				if(result.recordList != null && result.recordList.length > 0) {
					this.columns = columnsOpp;
					this.iconName = 'standard:opportunity';
					var rows = result.recordList;
						for (var i = 0; i < rows.length; i++) {
							var row = rows[i];
							if(row.Owner){
								row.OwnerName = row.Owner.Name;
								row.OwnerNameURL = '/'+row.OwnerId;
							} 
							if(row.AV_PF__c){
								row.PFName = row.AV_PF__r.Name;
							} 
							if(row.Account) {
								row.AccountName = row.Account.Name;
								row.AccountNameURL = '/'+row.AccountId;
								row.AV_Age__c = row.Account.AV_Age__c ? row.Account.AV_Age__c : null;
								row.AV_AhorroEInversion__c = row.Account.AV_AhorroEInversion__c ? row.Account.AV_AhorroEInversion__c : 0;
								row.AV_Financiacion__c = row.Account.AV_Financiacion__c ? row.Account.AV_Financiacion__c : 0;
								row.AV_Ingresos__c = row.Account.AV_Ingresos__c ? row.Account.AV_Ingresos__c : 0;
								row.AV_Preconceived__c = row.Account.AV_Preconceived__c ? row.Account.AV_Preconceived__c : null;
								row.AV_MyBox__c = row.Account.AV_MyBox__c ? row.Account.AV_MyBox__c : null;
								row.AV_TargetAuto__c = row.Account.AV_TargetAuto__c ? row.Account.AV_TargetAuto__c : null;
							} 
							if(row.recordTypeName){
								row.RecordtypeName = row.recordTypeName;
							} 
							if(row.oppName){
								row.OppNameURL =  '/'+row.Id;
							}
						}
					if (this.page > 1) {
						this.data = this.data.concat(rows);
					} else {
						this.data = [];
						this.data = rows;
					}
					if (result.totalSize != -1) {
						this.size = result.totalSize;
					}
					if (this.size > 2000) {
						if (this.size === 100000) {
							this.totalRecountCount = 'Total 2000/' + this.size + '+';
						} else {
							this.totalRecountCount = 'Total 2000/' + this.size;
						}
						this.helpMessage = true;
						this.totalPage = this.MAX_PAGE_NUM;
					} else {
						this.totalRecountCount = 'Total ' + this.size;
						this.totalPage = Math.ceil(this.size / this.pageSize);
					}
					if (this.totalPage<=1) {
						this.isMultipagina= false;
					}else{
						this.isMultipagina= true;
					}
					this.items = this.data.slice((this.page-1)*100,this.pageSize*this.page); 
					this.endingRecord = this.pageSize;
					this.toggleSpinner();
				} else {
					this.totalRecountCount  = 'Total 0';
					this.toggleSpinner();
				}
			})
			.catch(error => {
				console.log(error);
				this.toggleSpinner();
			})
	} 

	handleLookupTypeChange(event) {
		this.initialSelection = [];
		this.errors = [];
		this.isMultiEntry = event.target.checked;
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
				this.notifyUser('Lookup Error', 'An error occured while searching with the lookup field.', 'error');
				console.error('Lookup error', JSON.stringify(error));
				this.errors = [error];
			});
	}

	handleSearchProduct(event) {
		lookupSearchProduct(event.detail)
			.then((results) => {
				this.template.querySelector('[data-id="clookup3"]').setSearchResults(results);
				this.template.querySelector('[data-id="clookup3"]').scrollIntoView();
			})
			.catch((error) => {
				this.notifyUser('Lookup Error', 'An error occured while searching with the lookup field.', 'error');
				console.error('Lookup error', JSON.stringify(error));
				this.errors = [error];
			});
	}

	handleSearchAccount(event) {
		lookupSearchAccount(event.detail)
			.then((results) => {
				this.template.querySelector('[data-id="clookup4"]').setSearchResults(results);
				this.template.querySelector('[data-id="clookup4"]').scrollIntoView();
			})
			.catch((error) => {
				this.notifyUser('Lookup Error', 'An error occured while searching with the lookup field.', 'error');
				console.error('Lookup error', JSON.stringify(error));
				this.errors = [error];
			});
	}

	handleSearchOffice(event) {
		lookupSearchOffice(event.detail)
			.then((results) => {
				this.template.querySelector('[data-id="clookup5"]').setSearchResults(results);
				this.template.querySelector('[data-id="clookup5"]').scrollIntoView();
			})
			.catch((error) => {
				this.notifyUser('Lookup Error', 'An error occured while searching with the lookup field.', 'error');
				console.error('Lookup error', JSON.stringify(error));
				this.errors = [error];
			});
	}

	handleSelectionChange(event) {
		this.checkForErrors(event);
		this.setButtonVisibility();
	}
  
	handleClear() {
		this.initialSelection = [];
		this.errors = [];
	}
  
	checkForErrors(event) {
		this.errors = [];
		let targetId = event.target.dataset.id;
		if(targetId === 'clookup1'){
		  targetId = 'lookup1';
		}else if(targetId === 'clookup2'){
		  targetId = 'lookup2';
		} else if (targetId === 'clookup6') {
			targetId = 'lookup6';
		}
		if (targetId=='clookup3') {
			const selection = this.template.querySelector(`[data-id="${targetId}"]`).getSelection();
			let selectedIds = [];
			if(selection.length !== 0){
				this.selectedProducts.forEach(prod => {
					selectedIds.push(prod.id);
				});
				for(let sel of selection) {
					if(!selectedIds.includes(sel.id)){
						this.filterProduct  = String(sel.id);
						this.multiSelectionS++;
						this.selectedProducts.push({label:String(sel.title),id:String(sel.id),bucleId:this.multiSelectionS});
					}
				}
				if(this.selectedProducts.length > 0){
					this.showSelectedProducts = true;
				}else{
					this.showSelectedProducts = true;
				}
			} else {
				this.filterProduct = null;
			}
			this.initialSelection= [];
		} else if (targetId=='lookup1' || targetId == 'lookup6'){
			const selection = this.template.querySelector(`[data-id="${targetId}"] > c-av_-lookup`).getSelection();
			if(selection.length !== 0){
				for(let sel of selection) {
					this.filterList  = String(sel.id);
				}
				this.contactNameA(this.filterList);
			} else {
				this.filterList = null;
			}
		} else if (targetId=='clookup4'){
			const selection = this.template.querySelector(`[data-id="${targetId}"]`).getSelection();
			if(selection.length !== 0){
				for(let sel of selection) {
					this.clientFilter  = String(sel.id);
				}
			} else {
				this.clientFilter = null;
			}
		} else if (targetId == 'clookup5') {
			const selection = this.template.querySelector(`[data-id="${targetId}"]`).getSelection();
			if(selection.length !== 0){
				for(let sel of selection) {
					this.getOptionsEmployee(sel.title.substring(0,5));
					this.numOficinaEmpresa = sel.title.substring(0,5);
					this.setButtonVisibility();
				}
			} else {
				this.numOficinaEmpresa = null;
				this.setButtonVisibility();
			}
		}
	}

	unSelectProduct(cmp){
		let divToDel = cmp.target.parentNode;
		for(let i=0;i<this.selectedProducts.length;i++){
			if(this.selectedProducts[i].label === cmp.target.label){
				this.selectedProducts.splice(i,1);
				break;
			}
		}
		if(this.selectedProducts.length > 0){
			this.showSelectedProducts = true;
		}else{
			this.showSelectedProducts = false;
		}
		divToDel.classList.add('delete');
		cmp.target.remove();
		this.setButtonVisibility();
	}
	
	unSelectEmployee(cmp){
		let divToDel = cmp.target.parentNode;
		for(let i=0;i<this.selectedEmployees.length;i++){
			if(this.selectedEmployees[i].id === cmp.target.name){
				this.selectedEmployees.splice(i,1);
				break;
			}
		}
		divToDel.classList.add('delete');
		cmp.target.remove();
		this.setButtonVisibility();
	}
  
	notifyUser(title, message, variant) {
	  if (this.notifyViaAlerts) {
		  // Notify via alert
		  // eslint-disable-next-line no-alert
		  alert(`${title}\n${message}`);
	  } else {
		  // Notify via toast
		  const toastEvent = new ShowToastEvent({ title, message, variant });
		  this.dispatchEvent(toastEvent);
	  }
	}

	get objOptions() {
        return [
			//{ label: 'Clientes', value: 'Account' },
            //{ label: 'Tareas', value: 'Task' },
            { label: 'Oportunidades', value: 'Opportunity' }
        ];
    }
	
	handleSearchData() {
		this.page = 1;
		this.size = 0;
		var today = new Date();
		var mes =today.getMonth()+1;
		if (mes<=9) {
			mes='0'.concat(mes);
		}
		var dia=today.getDate();
		if (dia<=9) {
			dia='0'.concat(dia);
		}
		var fecha=today.getFullYear() + '-' + mes + '-' + dia;
		let indicadoresFilter = [];
		this.selectedIndicadores.forEach(indi => {
			indicadoresFilter.push(indi['id']);
		})
		this.firstSearch = true;
		this.data = null;
		this.setMultiSelectors();
		this.getDataList(this.clientFilter, this.subjectFilter, this.origenFilter, this.statusFilter, this.dueDate2Filter,this.dueDateFilter, this.employeMultiFilter, this.productsMultiFilter, this.FechaCierreFilter, this.FechaGestionFilter, this.page, this.myBoxFilter,this.preconceivedFilter,this.targetAutoFilter,this.numOficinaEmpresa,this.potencial,this.fechaModif,indicadoresFilter);
		this.toggleSpinner();
	}

	toggleSpinner() {
        this.showSpinner = !this.showSpinner;
    }
	handleChangeClient(event) {
		this.clientFilter = event.target.value;
	}

	handleChangeSubject(event) {
		this.subjectFilter = event.target.value;
	}

	handleChangeOrigen(event) {
		this.origenFilter = event.target.value;
		if (this.isAnotherOffice === true) {
			this.handleAnotherOffice(new Object({'detail': {'checked': true}}));
		}else{
			this.getOptionsEmployee(this.numOficinaEmpresa);
		}
		this.setButtonVisibility();
	}

	handleChangeEstado(event) {
		this.statusFilter = event.target.value;
		if (this.isAnotherOffice === true) {
			this.handleAnotherOffice(new Object({'detail': {'checked': true}}));
		}
		this.setButtonVisibility();
	}

	handleChangeDueDate(event) {
		this.dueDateFilter = event.target.value;
	}

	handleChangeDueDate2(event) {
		this.dueDate2Filter = event.target.value;
	}

	handleChangeEmployee(event) {
		this.multiSelectionE++;
		this.employeeFilter = event.target.value;
		let employeeName = '';
		for(let i=0;i<this.optionsEmployee.length;i++){
			if(this.optionsEmployee[i]['value']===event.target.value){
				employeeName=this.optionsEmployee[i]['label'];
				// if TODOS selected, remove everyone from selected list
				if (employeeName.includes('TODOS')) {
					this.selectedEmployees = [];
				}
				break;
			}
		}
		let insert = true;
		if(this.selectedEmployees.length > 0 ){
			// if TODOS selected, remove TODOS when someone gets added to selected list
			if (this.selectedEmployees[0]['label'].includes('TODOS')) {
				this.selectedEmployees.splice(0, 1); // 0 == TODOS
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
		this.employeesDiv = true;
		this.setButtonVisibility();
	}

	/**
	 * @description		Get the employees that are not assigned to the selected office but
	 * 					own opportunities in the selected office
	 * @param event 	Toggle check
	 */
	handleAnotherOffice(event) {
		// Check if office, product and stagename exist for the query to run faster
		if (this.numOficinaEmpresa != null && this.statusFilter != null && this.origenFilter != null) {
			this.isAnotherOffice = event.detail.checked;
			this.selectedEmployees = [];
			if (event.detail.checked === true) {
				this.optionsEmployeeAux = this.optionsEmployee;
				this.employeeFilter = null;
				const data = this.selectedOffice + '{|}' + this.statusFilter + '{|}' + this.origenFilter;
				this.getOptionsEmployee(data);
			} else {
				this.optionsEmployee = this.optionsEmployeeAux;
				this.employeeFilter = this.employeeDefault;
				const evt = new Object({'target': {'value':this.employeeFilter}});
				this.handleChangeEmployee(evt);
			}
			this.setButtonVisibility();
		} else {
			const el = this.template.querySelector('.another-office');
			el.checked = false;
			this.isAnotherOffice = false;
			const evt = new ShowToastEvent({
				title: 'Filtro incorrecto',
				message: 'Los campos oficina, etapa y origen deben estar informados.',
				variant: 'info',
				mode: 'dismissable'
			});
			this.dispatchEvent(evt);
		}
	}

	/**
	 * @description		Fill the multiselectors for the query
	 */
	setMultiSelectors() {
		this.employeMultiFilter = [];
		this.productsMultiFilter = [];
		this.selectedEmployees.forEach(emp => {
			if (!this.employeMultiFilter.includes(emp.id)) {
				if (emp.label.includes('TODOS')) {
					emp.id.split(',').forEach(id => {
						this.employeMultiFilter.push(id);
					});
				} else {
					this.employeMultiFilter.push(emp.id);
				}
			}
		});
		this.selectedProducts.forEach(prod => {
			if (!this.productsMultiFilter.includes(prod.id)) {
				this.productsMultiFilter.push(prod.id);
			}				
		});
	}

	handleChangeFechaCierre(event) {
		this.FechaCierreFilter = event.target.value;
	}
	
	handleChangeFechaGestion(event) {
		this.FechaGestionFilter = event.target.value;
	}

	handleChangeMyBox(event){
		this.myBoxFilter = event.target.value;
	}

	handleChangePreconceived(event){
		this.preconceivedFilter = event.target.value;
	}

	handleChangeTargetAuto(event){
		this.targetAutoFilter= event.target.value;
	}

	//Capture the event fired from the paginator component
    handlePaginatorChange(event){
        this.recordsToDisplay = event.detail;
    }

	resetFilters(){
			const lookup5 = this.template.querySelector('[data-id="clookup5"]');
			if (lookup5 != null || typeof lookup5 != 'undefined') {
				lookup5.handleClearSelection();
			}
			console.log('Lookup Error ==> ',e);
		
			const lookup3 = this.template.querySelector('[data-id="clookup3"]');
			if (lookup3 != null || typeof lookup3 != 'undefined') {
				lookup3.handleClearSelection();
			}
			console.log('Lookup Error ==> ',e);
			const lookup4 = this.template.querySelector('[data-id="clookup4"]');
			if (lookup4 != null || typeof lookup4 != 'undefined') {
				lookup4.handleClearSelection();
			}
			console.log('Lookup Error ==> ',e);
			this.template.querySelectorAll('lightning-input').forEach(each => {
			each.value = '';
		});
		this.dueDateFilter = null;
		this.dueDate2Filter = null;
		this.FechaCierreFilter = null;
		this.FechaGestionFilter = null;
		this.origenFilter = 'AV_Iniciativa';
		this.statusFilter = null;
		this.subjectFilter = null;
		this.filterList = null;
		this.filterProduct =null;
		this.employeeFilter = null;
		this.myBoxFilter = null;
		this.preconceivedFilter = null;
		this.targetAutoFilter = null;
		this.selectedEmployees = [];
		this.selectedProducts = [];
		this.employeMultiFilter = [];
		this.productsMultiFilter = [];
		this.isAnotherOffice = false;
		this.showSelectedProducts = false;
		this.potencial = null;
		this.numOficinaEmpresa = null;
		this.selectedIndicadores = [];
		this.selectedIndicadoresDiv=false;
		this.setButtonVisibility();
	}

	toggleShow() {
        if(this.showDetail === true){
            this.showDetail = false;
        }else{
            this.showDetail = true;
        }
    }

	handleSave(){
		this.toggleSpinner();
		var el = this.template.querySelector('lightning-datatable');
        var selected = el.getSelectedRows();
		// pop up de confirmacion
		if(selected != null && selected.length > 0){
			//Selected es 0 que no se ejecuted
			assign({objectName: this.targetObjName,  contactId : this.filterList ,selectedRows : selected})
			.then(result => {
				if(result != null && result > 0) {
					if (this.targetObjName == 'Task'){
						const evt = new ShowToastEvent({
							title: 'Operación correcta',
							message: 'Se reasignarán ' + result + ' tareas a '+this.contactName+'. Esta operación puede tardar varios segundos.',
							variant: 'success',
							mode: 'dismissable'
						});
						this.dispatchEvent(evt);
					}else{
						const evt = new ShowToastEvent({
							title: 'Operación correcta',
							message: 'Se reasignarán ' + result + ' oportunidades a '+this.contactName+'. Esta operación puede tardar varios segundos.',
							variant: 'success',
							mode: 'dismissable'
						});
						this.dispatchEvent(evt);
					}
				} else {
					const evt = new ShowToastEvent({
						title: 'Operación incorrecta',
						message: 'El usuario ' + this.contactName + ' no tiene un contacto asociado.',
						variant: 'error',
						mode: 'dismissable'
					});
					this.dispatchEvent(evt);
				}
				this.handleSearchData();
				this.toggleSpinner();
				this.handleCloseModal();
			})
			.catch(error => {
				console.log(error);
				this.toggleSpinner();
				this.handleCloseModal();
			});
		}else{
			this.handleCloseModal();
		}
		
	}

	contactNameA(contactId) {
		nameContactAssign({contactId : contactId})
			.then(result => {
				if(result != null) {
					this.contactName=result;
				}
			})
			.catch(error => {
				console.log(error);
			});
	}

	get todaysDate() {
		var today = new Date();
		return today.getFullYear() + '-' + (today.getMonth()+1) + '-' + today.getDate();
	}

	handleModal(event) {
		if(this.filterList != null && this.selectedItems > 0){
			switch (this.targetObjName) {
				case 'Task':
					if (event.target.className === 'my-office-true') {
						this.actionType = 'taskAsignar';
					} else {
						this.actionType = 'taskAsignarOtraOficina';
					}
					break;
				case 'Opportunity':
					if (event.target.className === 'my-office-true') {
						this.actionType = 'oppoAsignar';
					} else {
						this.actionType = 'oppoAsignarOtraOficina';
					}
					break;
			}
			this.isModalOpen = true;
		}else if(this.filterList  == null){
			this.actionType = 'noEmpleado';
			this.isModalOpen = true;
		}else {
			switch (this.targetObjName) {
				case 'Task':
					this.actionType = 'noTareas';
					break;
	
				case 'Opportunity':
					this.actionType = 'noOppos';
					break;
			}
			this.isModalOpen = true;
		}
		
    }

	doAction(event) {
        var actionType = event.detail.action;
		if (actionType == 'oppoAsignar' || actionType =='taskAsignar') {
			this.handleSave();
			this.template.querySelector('[data-id="lookup1"] > c-av_-lookup').handleClearSelection();
			this.selectedItems=null;
			this.filterList = null;
		} else if (actionType == 'oppoAsignarOtraOficina' || actionType == 'taskAsignarOtraOficina') {
			this.handleSave();
			this.template.querySelector('[data-id="lookup6"] > c-av_-lookup').handleClearSelection();
			this.selectedItems=null;
			this.filterList = null;
		} else {
			this.handleCloseModal();
		}
    }

	getSelectedName(event) {
		const selectedRows = event.detail.selectedRows;
		// Display that fieldName of the selected rows
		this.selectedItems = selectedRows.length;
	}

	handleCloseModal() {
		this.isModalOpen = false;
	}

	//clicking on previous button this method will be called
    previousHandler() {
		this.toggleSpinner();
        if (this.page > 1) {
            this.page = this.page - 1; //decrease page by 1
            this.displayRecordPerPage(this.page);
        }
		this.toggleSpinner();
    }

    //clicking on next button this method will be called
    nextHandler() {
        if((this.page<this.totalPage) && this.page !== this.totalPage){
            this.page = this.page + 1; //increase page by 1
			if (this.page*100 > this.data.length) {
				this.setMultiSelectors();
				this.getDataList(this.clientFilter, this.subjectFilter, this.origenFilter, this.statusFilter, this.dueDate2Filter,this.dueDateFilter, this.employeMultiFilter, this.productsMultiFilter, this.FechaCierreFilter, this.FechaGestionFilter, this.page, this.myBoxFilter,this.preconceivedFilter,this.targetAutoFilter,this.numOficinaEmpresa);
				this.toggleSpinner();
			}
			this.toggleSpinner();
            this.displayRecordPerPage(this.page);
			this.toggleSpinner();
        }             
    }

    //this method displays records page by page
    displayRecordPerPage(page){
        this.startingRecord = ((page -1) * this.pageSize) ;
        this.endingRecord = (this.pageSize * page);
        this.endingRecord = (this.endingRecord > this.totalNumberOfRecords) 
                            ? this.totalNumberOfRecords : this.endingRecord; 
        this.items = this.data.slice(this.startingRecord, this.endingRecord);
        this.startingRecord = this.startingRecord + 1;
    }

	sortBy(field, reverse, primer) {
		
		if(field== 'AV_Age__c' || field== 'AV_AhorroEInversion__c' || field== 'AV_Financiacion__c' || field== 'AV_Ingresos__c' ||  field== 'AV_Preconceived__c' || field == 'AV_IncludeInPrioritizingCustomers__c'){

			const key = primer
            ? function(x) {
                  return primer(x[field]);
              }
            : function(x) {
                  return x[field];
              };

			return function(a, b) {
				a = key(a);
				b = key(b);
				var result;
				if (a == null) {
					result = 1;
				}
				else if (b == null) {
					result = -1;
				}else{
					result = (reverse * ((a  > b) - (b  > a )));
				};
				return result;
			}
		}else{
			
			const key = primer
			? function(x) {
				return primer(x[field]);
			}
			: function(x) {
				return x[field];
			};
			
			return function(a, b) {
				a = key(a);
				b = key(b);
				var result;
				if (a == null) {
					result= 1;
				}
				else if (b == null) {
					result= -1;
				}else{
					result=( reverse * ((a.toLowerCase()  > b.toLowerCase() ) - (b.toLowerCase()  > a.toLowerCase() )));
				};
				return result;
			}
		}
	}

    onHandleSort(event) {
        //const { fieldName: sortedBy, sortDirection } = event.detail;
        const cloneData = [...this.items];
		const sortFieldName = this.columns.find(field=>sortedBy===field.fieldName).sortBy;
        cloneData.sort(this.sortBy(sortFieldName, sortDirection === 'asc' ? 1 : -1));
        this.items = cloneData;
        this.sortDirection = sortDirection;
        this.sortedBy = sortedBy;
    }

	/**
	 * Hides assignment depending on showAssignment value
	 */
	hideAssignment() {
		isBankTeller()
			.then((result) => {
				if (result) {
					this.showAssignment = false;
				}
			})
			.catch((error) => {
				console.error('Hide assignment error', JSON.stringify(error));
				this.errors = [error];
			});
	}

	setButtonVisibility() {
		if (this.employeeFilter != null && this.statusFilter != null && this.numOficinaEmpresa != null && this.origenFilter != null) {
			this.buttonDisabled = false;
			this.seeFiltersLabel = 'Ver más filtros';
		} else {
			this.buttonDisabled = true;
		}
	}

	showMoreFilters(){
		if (this.showMoreFiltersDiv == false) {
			this.showMoreFiltersDiv = true;
			this.seeFiltersLabel = 'Ver menos filtros';
		} else if (this.showMoreFiltersDiv == true) {
			this.showMoreFiltersDiv = false;
			this.seeFiltersLabel = 'Ver más filtros';
		}
	}

	handleChangePotencial(e){
		this.potencial = e.target.value;
	}

	handleChangeFechaModif(e){
		this.fechaModif = e.target.value;
	}

	handleChangeIndicadorCli(event) {
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
		}
		this.selectedIndicadoresDiv = true;
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
		this.valueNull = null;
		this.selectedIndicadoresDiv = (this.selectedIndicadores.length != 0);
	}
}