import { LightningElement, track, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getRecord } from 'lightning/uiRecordApi';
//Apex
import fetchData from '@salesforce/apex/CIBE_MassReassignOwnerOpps_Controller.getBaseData';
import lookupSearch from '@salesforce/apex/CIBE_MassReassignOwnerOpps_Controller.search';
import lookupSearchProduct from '@salesforce/apex/CIBE_MassReassignOwnerOpps_Controller.searchProduct';
import lookupSearchAccount from '@salesforce/apex/CIBE_MassReassignOwnerOpps_Controller.searchAccount';
import lookupSearchOffice from '@salesforce/apex/CIBE_MassReassignOwnerOpps_Controller.searchOffice';
import lookupSearchParticipe from '@salesforce/apex/CIBE_MassReassignOwnerOpps_Controller.searchParticipe';
import getEmployees from '@salesforce/apex/CIBE_MassReassignOwnerOpps_Controller.getEmployees';
import assign from '@salesforce/apex/CIBE_MassReassignOwnerOpps_Controller.assign';
import nameContactAssign from '@salesforce/apex/CIBE_MassReassignOwnerOpps_Controller.nameContactAssign';
import isBankTeller from '@salesforce/apex/AV_AppUtilities.isBankTeller';
//labels
import recordLimitLabel from '@salesforce/label/c.AV_BuscadorRecordLimit';
import etapa from '@salesforce/label/c.CIBE_Etapa';
import centro from '@salesforce/label/c.CIBE_Centro';
import producto from '@salesforce/label/c.CIBE_Producto';
import empleadoAsignado from '@salesforce/label/c.CIBE_EmplAsig';
import errorOcc from '@salesforce/label/c.CIBE_AnErrorOccured';
import clienteLab from '@salesforce/label/c.CIBE_Cliente';
import miOficinaLab from '@salesforce/label/c.CIBE_MiOficina';
import productoLab from '@salesforce/label/c.CIBE_Producto';
import participeLab from '@salesforce/label/c.CIBE_Participe';





//records
import USER_ID from '@salesforce/user/Id';
import NAME_FIELD from'@salesforce/schema/User.Name';
import FUNCTION from '@salesforce/schema/User.AV_Funcion__c';
import OFICINA from '@salesforce/schema/User.AV_NumeroOficinaEmpresa__c';
//labels flow
import newOppor from '@salesforce/label/c.CIBE_NuevaOportunidad';
import filtroB from '@salesforce/label/c.CIBE_FiltrosBusqueda';
import pais from '@salesforce/label/c.CIBE_PaisOppo';
import equipoOppo from '@salesforce/label/c.CIBE_equipoOppo';
import industriaInter from '@salesforce/label/c.CIBE_IndustriaInter';
import buscar from '@salesforce/label/c.CIBE_buscar';
import reset from '@salesforce/label/c.CIBE_Reiniciar';
import etapaOpo from '@salesforce/label/c.CIBE_EtapaOportunidad';
//flow
import getActions   from '@salesforce/apex/CIBE_Oportunidades_Vinculadas_Controller.getActions';
const columnsOpp = [
	{ label: 'Cliente', fieldName: 'AccountNameURL', type: 'url', typeAttributes: {label: { fieldName: 'AccountName' } }, hideDefaultActions: true, wrapText:true},
	{ label: 'Nombre de la oportunidad', fieldName: 'OppNameURL', type: "url",	typeAttributes:{ label: { fieldName: 'Name' } }, hideDefaultActions: true, wrapText:true},
	{ label: 'Importe de la oportunidad', fieldName: 'Amount',type: 'currency', hideDefaultActions: true,sortable:true },
	{ label: 'Impacto en balance', fieldName: 'CIBE_Balance__c',type: 'currency', hideDefaultActions: true,sortable:true },
	{ label: 'Comisiones', fieldName: 'CIBE_Comisiones__c',type: 'currency', hideDefaultActions: true,sortable:true },
	{ label: 'Etapa', fieldName: 'StageName',type: 'text', hideDefaultActions: true ,sortable:true },
	{ label: 'Origen', fieldName: 'AV_Origen__c', type: 'text',hideDefaultActions: true},
	{ label: 'Producto', fieldName: 'PFName', type: 'text', hideDefaultActions: true },
	{ label: 'Empleado asignado', fieldName: 'OwnerNameURL', type: 'url',	typeAttributes:{ label: { fieldName: 'OwnerName' } }, hideDefaultActions: true, wrapText:true},
	{ label: 'Participe', fieldName: 'ParticipeRow', type: 'text', hideDefaultActions: true },
	{ label: 'Fecha de Cierre', fieldName: 'CloseDate', type: "date-local",typeAttributes:{ month: "2-digit", day: "2-digit" }, sortable: true}
];

export default class CIBE_MassReassignOwnerOpps extends LightningElement {

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
	optionsEmployee = [];
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
	selectedParticipe = [];
	showSelectedProducts;
	showSelectedParticipe;
	selectedOffice = '';
	empleFuncion;
	isDirector;
	directores = ['DC','DT','DAN','SSCC'];
	buttonDisabled = true;
	seeFiltersLabel;
	multiSelectionE=0;
	multiSelectionS=0;
	multiSelectionP=0;
	employeesDiv = true;
	showMoreFiltersDiv = false;
	employeMultiFilter = [];
	productsMultiFilter = [];
	participesMultiFilter = [];
	preconceivedFilter = null;
	@track numOficinaEmpresa = null;
	isAnotherOffice = false;

	//delete
	//@track footerDisplay = false;
	@track taskFilter = false;
	@track oppFilter = false;
	@track subjectFilter = null;
	@track FechaGestionFilter = null;
	@track fechaCierreD = null;
	@track fechaCierreH = null;
	@track employeeFilter = this.employeeDefault;
	@track statusFilter = 'Potencial';
	@track origenFilter = 'CIBE_AccionComercialEMP';
	@track targetProbabilidad;
	@track clientFilter;
	@track importeFilter = 0;
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
	@track isMultiEntry3 = false;
	@track filterProduct;
	@track filterPartiipe;
	//flow
    actionSetting = 'CIBE_New_Opportunity';
	@track flowlabel;
	@track flowName;
	@track flowOutput;
	@track redirectId;
	@track objectAPIName;
	@track isShowFlowAction = false;

	labels = {
		newOppor,
		filtroB,
		pais,
		equipoOppo,
		industriaInter,
		reset,
		buscar,
		etapaOpo,
		etapa,
		centro,
		producto,
		reset,
		buscar,
		empleadoAsignado,
		errorOcc,
		clienteLab,
		miOficinaLab,
		productoLab,
		participeLab
	}
	
	
	@wire(getRecord,{recordId:USER_ID,fields:[NAME_FIELD,FUNCTION,OFICINA]})
	wiredUser({error,data}){
		if(data){
			this.empleName = data.fields.Name.value;
			this.selectedEmployees = [{label:this.empleName,id:USER_ID,bucleId:this.multiSelectionE}];
			this.empleFuncion = data.fields.AV_Funcion__c.value;
			this.empleOfi = data.fields.AV_NumeroOficinaEmpresa__c.value;
			this.isDirector = this.directores.includes(this.empleFuncion);
            this.getOptionsOffice();
			this.setVisibilityOptions();
			this.setButtonVisibility();
		}else if(error){
			console.log(error)
		}
	}

	connectedCallback() {
		this.showDetail = true;
	}

	get optionsOppoStatus() {
		return [
			{ label: 'Potencial', value: 'Potencial' },
            { label: 'En curso', value: 'En curso' },
			{ label: 'Pendiente de firma', value: 'CIBE_Pendiente_Firma' },
			{ label: 'Cerrada negativa', value: 'Cerrado negativo'},
			{ label: 'Cerrada positiva', value: 'CIBE_Cerrado positivo'},
			{ label: 'Vencida', value: 'CIBE_Vencido'}
		];
	}


	get optionsOppoOrigen() {
		return [
			{ label: 'Iniciativa Empleado', value: 'CIBE_IniciativaEmpleadoEMP' },
			{ label: 'Acción Comercial', value: 'CIBE_AccionComercialEMP' },
			{ label: 'Sugerencia', value: 'CIBE_SugerenciaEMP' },
			{ label: 'Alerta Comercial', value: 'CIBE_AlertaComercialEMP' }
		];
	}

	get optionsProbabilidad() {
		return [
			{ label: 'Alta', value: 'Alta' },
			{ label: 'Media', value: 'Media' },
			{ label: 'Baja', value: 'Baja' }
		];
	}

	getOptionsOffice() {
		lookupSearchOffice({searchTerm: this.empleOfi.substring(4), selectedIds: null})
			.then(result => {
				this.template.querySelector('[data-id="clookup5"]').setSearchResults(result);
				this.template.querySelector('[data-id="clookup5"]').scrollIntoView();
				this.employeeOffice = result[0].id;
				this.numOficinaEmpresa = result[0].subtitle.substring(result[0].subtitle.length-5);
				this.initialSelectionOffice=[{id: result[0].id, icon:result[0].icon, title: result[0].title}];
				this.selectedOffice = this.selectedOffice === '' ? this.empleOfi.substring(4) : this.selectedOffice;
				this.getOptionsEmployee(this.empleOfi.substring(4));
				this.setVisibilityOptions();
			}).catch(error => {
				console.log(error);
			})
	}

	getOptionsEmployee(data){
		getEmployees({officeFilterData: data})
			.then(result => {
			if(result != null && result.length > 0) {
				this.optionsEmployee = result;
			}
		}).catch(error => {
			console.log(error);
		})
	}

	getDataList(clientFilter, subjectFilter, origenFilter, statusFilter, employeMultiFilter, productsMultiFilter, fechaCierreD, fechaCierreH, page, numOficinaEmpresa,targetProbabilidad,importeFilter,participesMultiFilter) {
		fetchData({clientFilter: clientFilter, subjectFilter : subjectFilter , origenFilter : origenFilter, statusFilter : statusFilter, employeeFilter : employeMultiFilter, filterList: productsMultiFilter, fechaCierreD : fechaCierreD, fechaCierreH : fechaCierreH, page : page, office : numOficinaEmpresa, targetProbabilidad:targetProbabilidad, importeFilter:importeFilter, participesFilter:participesMultiFilter})
		.then(result => {
				this.targetObjName == 'Opportunity';
				this.helpMessage = false;
				if(result.recordList != null && result.recordList.length > 0) {
					this.columns = columnsOpp;
					this.iconName = 'standard:opportunity';
					var rows = result.recordList;
						for (var i = 0; i < rows.length; i++) {
							var row = rows[i];
							//console.log('OpportunityTeamMemberName: '+row.OpportunityTeamMembers[i]);
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
								//row.AV_Age__c = row.Account.AV_Age__c ? row.Account.AV_Age__c : null;
								row.AV_AhorroEInversion__c = row.Account.AV_AhorroEInversion__c ? row.Account.AV_AhorroEInversion__c : 0;
								row.AV_Financiacion__c = row.Account.AV_Financiacion__c ? row.Account.AV_Financiacion__c : 0;
								row.AV_Ingresos__c = row.Account.AV_Ingresos__c ? row.Account.AV_Ingresos__c : 0;
							} 
							if(row.RecordType){
								row.RecordtypeName = row.RecordType.Name;
							} 
							if(row.Name){
								row.OppNameURL =  '/'+row.Id;
							}
							if(row.CIBE_Comisiones__c){
								row.CIBE_Comisiones__c = row.CIBE_Comisiones__c ? row.CIBE_Comisiones__c : null;
							}
							if(row.Amount){
								row.Amount = row.Amount ? row.Amount : null;
							}
							if(row.CIBE_Balance__c){
								row.CIBE_Balance__c = row.CIBE_Balance__c ? row.CIBE_Balance__c : null;
							}
							if(row.CloseDate){
								row.CloseDate = row.CloseDate ? row.CloseDate : null;
							}
							if(row.OpportunityTeamMembers!= undefined && row.OpportunityTeamMembers.length > 0 ){
								row.ParticipeRow = row.OpportunityTeamMembers[0].Name ? row.OpportunityTeamMembers[0].Name : '';
								for (var f = 1; f < row.OpportunityTeamMembers.length; f++) {
									console.log('OpportunityTeamMemberName: '+row.OpportunityTeamMembers[f].Name);
									row.ParticipeRow += row.OpportunityTeamMembers[f].Name ? ' / '+row.OpportunityTeamMembers[f].Name : '';
								}
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
	//Mi Oficina
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
				this.notifyUser('Lookup Error', labels.errorOcc+labels.miOficinaLab+'.', 'error');
				console.error('Lookup error', JSON.stringify(error));
				this.errors = [error];
			});
	}
	//Producto
	handleSearchProduct(event) {
		lookupSearchProduct(event.detail)
			.then((results) => {
				this.template.querySelector('[data-id="clookup3"]').setSearchResults(results);
				this.template.querySelector('[data-id="clookup3"]').scrollIntoView();
			})
			.catch((error) => {
				this.notifyUser('Lookup Error', labels.errorOcc+labels.productoLab+'.', 'error');
				console.error('Lookup error', JSON.stringify(error));
				this.errors = [error];
			});
	}

	//Participe
	handleSearchParticipe(event) {
		let targetId = event.target.dataset.id;
		const selection = this.template.querySelector(`[data-id="${targetId}"]`).value;
		let escribo = event.detail.searchTerm;
		lookupSearchParticipe({searchTerm : escribo, selectedIds:null, numOficina : this.numOficinaEmpresa})
			.then((results) => {
				this.template.querySelector('[data-id="clookupPar"]').setSearchResults(results);
				this.template.querySelector('[data-id="clookupPar"]').scrollIntoView();
			})
			.catch((error) => {
				this.notifyUser('Lookup Error', labels.errorOcc+labels.participeLab+'.', 'error');
				console.error('Lookup error', JSON.stringify(error));
				this.errors = [error];
			});
	}

	//Cliente
	handleSearchAccount(event) {
		lookupSearchAccount(event.detail)
			.then((results) => {
				this.template.querySelector('[data-id="clookup4"]').setSearchResults(results);
				this.template.querySelector('[data-id="clookup4"]').scrollIntoView();
			})
			.catch((error) => {
				this.notifyUser('Lookup Error', labels.errorOcc+labels.clienteLab+'.', 'error');
				console.error('Lookup error', JSON.stringify(error));
				this.errors = [error];
			});
	}
	//Oficina
	handleSearchOffice(event) {
		lookupSearchOffice(event.detail)
			.then((results) => {
				this.template.querySelector('[data-id="clookup5"]').setSearchResults(results);
				this.template.querySelector('[data-id="clookup5"]').scrollIntoView();
			})
			.catch((error) => {
				this.notifyUser('Lookup Error', labels.errorOcc+ labels.errorOcc+'.', 'error');
				console.error('Lookup error', JSON.stringify(error));
				this.errors = [error];
			});
	}

	handleSelectionChange(event) {
		this.checkForErrors(event);
		this.setVisibilityOptions();
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
					this.selectedOffice = String(sel.subtitle).slice(-5); // Get the office number
					if (this.empleOfi.slice(-5) != this.selectedOffice) {
						this.selectedEmployees = [];
		}
					this.getOptionsEmployee(sel.title.substring(0,5));
					if (this.isAnotherOffice) {
						this.handleAnotherOffice(new Object({'detail': {'checked': true}}));
					}
					this.employeeOffice = String(sel.id);
					this.setVisibilityOptions();
				}
			}
		}else if (targetId == 'clookupPar') {
			const selection = this.template.querySelector(`[data-id="${targetId}"]`).getSelection();
			let selectidPa =[];
			if(selection.length !== 0){
				this.selectedParticipe.forEach(parti => {
					selectidPa.push(parti.title);
				});
				for(let selp of selection) {
					if(!selectidPa.includes(selp.title)){
						this.filterPartiipe  = String(selp.title);
						this.multiSelectionP++;
						this.selectedParticipe.push({label:String(selp.title),bucleId:this.multiSelectionP});
					}
				}
				if(this.selectedParticipe.length > 0){
					this.showSelectedParticipe = true;
				}else{
					this.showSelectedParticipe = true;
				}
			} else {
				this.filterParticipe = null;
			}
			this.initialSelection= [];
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
	
	unSelectParticipe(cmp){
		let divToDel = cmp.target.parentNode;
		for(let i=0;i<this.selectedParticipe.length;i++){
			if(this.selectedParticipe[i].label === cmp.target.label){
				this.selectedParticipe.splice(i,1);
				break;
			}
		}
		if(this.selectedParticipe.length > 0){
			this.showSelectedParticipe = true;
		}else{
			this.showSelectedParticipe = false;
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

    handleChangeObj(event) {
        this.targetObjName = event.detail.value;
		switch (this.targetObjName) {
			case 'Task':
				this.taskFilter = true;
				this.oppFilter = false;
				break;

			case 'Opportunity':
				this.taskFilter = false;
				this.oppFilter = true;
				break;
		}
		this.filterList = null;
		this.selectedItems=null;
		this.firstSearch=false;
		this.fechaCierreD = null;
		this.fechaCierreH = null;
		this.origenFilter = null;
		this.statusFilter = null;
		this.subjectFilter = null;
		this.filterProduct =null;
		this.filterPartiipe = null;
		this.employeeFilter = USER_ID;
		this.clientFilter = null;
		this.hideAssignment();
	}
	
	handleSearchData() {
		console.log('handleSearchData');
		this.page = 1;
		this.size = 0;
		this.firstSearch = true;
		this.data = null;
		this.setMultiSelectors();
		this.getDataList(this.clientFilter, this.subjectFilter, this.origenFilter, this.statusFilter, this.employeMultiFilter, this.productsMultiFilter, this.fechaCierreD, this.fechaCierreH, this.page, this.numOficinaEmpresa, this.targetProbabilidad, this.importeFilter,this.participesMultiFilter);
		this.toggleSpinner();
	}

	toggleSpinner() {
        this.showSpinner = !this.showSpinner;
    }
	handleChangeClient(event) {
		this.clientFilter = event.target.value;
	}
	handleChangeImporte(event) {
		this.importeFilter = event.target.value;
		console.log('importeFilter: '+this.importeFilter);
		if(this.importeFilter =='' ||this.importeFilter ==null || this.importeFilter == undefined ){
			this.importeFilter =0;
		}
		console.log('importeFilter: '+this.importeFilter);

	}

	handleChangeSubject(event) {
		this.subjectFilter = event.target.value;
	}
	handleChangeOrigen(event) {
		this.origenFilter = event.target.value;
		if (this.isAnotherOffice) {
			this.handleAnotherOffice(new Object({'detail': {'checked': true}}));
		}
		this.setVisibilityOptions();
		this.setButtonVisibility();
	}
	
	handleChangeProbabilidad(event) {
		this.targetProbabilidad = event.target.value;
		if (this.isAnotherOffice) {
			this.handleAnotherOffice(new Object({'detail': {'checked': true}}));
		}
		this.setVisibilityOptions();
		this.setButtonVisibility();
	}

	handleChangeEstado(event) {
		this.statusFilter = event.target.value;
		if (this.isAnotherOffice) {
			this.handleAnotherOffice(new Object({'detail': {'checked': true}}));
		}
		this.setVisibilityOptions();
		this.setButtonVisibility();
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
		this.setVisibilityOptions();
		this.setButtonVisibility();
	}

	/**
	 * @description		Get the employees that are not assigned to the selected office but
	 * 					own opportunities in the selected office
	 * @param event 	Toggle check
	 */
	handleAnotherOffice(event) {
		// Check if office, product and stagename exist for the query to run faster
		if (this.selectedOffice != null && this.statusFilter != null && this.origenFilter != null) {
			this.isAnotherOffice = event.detail.checked;
			this.selectedEmployees = [];
			if (event.detail.checked) {
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
				message: 'Los campos oficina y etapa deben estar informados.',
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
		console.log('Entra setMultiSelectors');
		this.employeMultiFilter = [];
		this.productsMultiFilter = [];
		this.participesMultiFilter = [];

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
		this.selectedParticipe.forEach(part => {
			if (!this.selectedParticipe.includes(part.id)) {
				this.participesMultiFilter.push(part.id);
			}				
		});
	}

	handleChangeFechaCierreD(event) {
		this.fechaCierreD = event.target.value;
	}

	handleChangeFechaCierreH(event) {
		this.fechaCierreH = event.target.value;
	}

	//Capture the event fired from the paginator component
    handlePaginatorChange(event){
        this.recordsToDisplay = event.detail;
    }

	resetFilters(){
		const lookup5 = this.template.querySelector('[data-id="clookup5"]');
		try {
			if (lookup5 != null || typeof lookup5 != 'undefined') {
				lookup5.handleClearSelection()
			}
		} catch (e) {
			console.log('Lookup Error ==> ',e);
		}
		const lookup3 = this.template.querySelector('[data-id="clookup3"]');
		try {
			
			if (lookup3 != null || typeof lookup3 != 'undefined') {
				lookup3.handleClearSelection()
			}
		} catch (e) {
			console.log('Lookup Error ==> ',e);
		}
		const lookup4 = this.template.querySelector('[data-id="clookup4"]');
		try {
			
			if (lookup4 != null || typeof lookup4 != 'undefined') {
				lookup4.handleClearSelection()
			}
		} catch (e) {
			console.log('Lookup Error ==> ',e);
		}
		this.template.querySelectorAll('lightning-input').forEach(each => {
			each.value = '';
		});
		this.template.querySelectorAll('lightning-combobox').forEach(each => {
			each.value = '';
		});

		this.fechaCierreD = null;
		this.fechaCierreH = null;
		this.origenFilter ='CIBE_AccionComercialEMP';
		this.targetProbabilidad = null;
		this.statusFilter = null;
		this.subjectFilter = null;
		this.filterList = null;
		this.filterProduct =null;
		this.filterPartiipe = null
		this.employeeFilter = null;
		this.importeFilter = null;
		this.selectedEmployees = [];
		this.selectedProducts = [];
		this.selectedParticipe = [];
		this.employeMultiFilter = [];
		this.productsMultiFilter = [];
		this.participesMultiFilter = [];
		this.isAnotherOffice = false;
		this.showSelectedProducts = false;
		this.showSelectedParticipe = false;
		this.setVisibilityOptions();
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

	get cero() {
		let cero = new Number();
		return 0;
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
				this.getDataList(this.clientFilter, this.subjectFilter, this.origenFilter, this.statusFilter, this.dueDate2Filter,this.dueDateFilter, this.employeMultiFilter, this.productsMultiFilter, this.fechaCierreD, this.fechaCierreH, this.page, this.numOficinaEmpresa, this.targetProbabilidad, this.importeFilter,this.participesMultiFilter);
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
        this.endingRecord = (this.endingRecord > this.totalNumberOfRecords) ? this.totalNumberOfRecords : this.endingRecord; 
        this.items = this.data.slice(this.startingRecord, this.endingRecord);
        this.startingRecord = this.startingRecord + 1;
    }

    sortBy(field, reverse, primer) {
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
            return reverse * ((a > b) - (b > a));
        };
    }

    onHandleSort(event) {
        const cloneData = [...this.items];
		const { fieldName: sortedBy, sortDirection } = event.detail;


        cloneData.sort(this.sortBy(sortedBy, sortDirection === 'asc' ? 1 : -1));
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

	setVisibilityOptions() {
		if ((this.office != null || this.employeeOffice != null) && this.employeeFilter != null &&
			this.statusFilter != null ) {
				this.seeFiltersLabel = 'Ver más filtros';
		}
	}

	setButtonVisibility() {
		if (((this.employeeFilter === null || typeof this.employeeFilter === 'undefined') ||
			(this.statusFilter === null || typeof this.statusFilter === 'undefined')) 
		){
			// ||
			// ((this.origenFilter === 'CIBE_IniciativaEmpleadoEMP') &&
			// (!this.showSelectedProducts || this.selectedEmployees === null || this.selectedEmployees.length === 0))) {
				
				//this.filterProduct === null || typeof this.filterProduct === 'undefined' 
			this.buttonDisabled = true;
		} else {
			this.buttonDisabled = false;
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
	
	get showEmployees(){
		if(this.selectedEmployees){
			return this.selectedEmployees.length>0;
		}
		return false;
	}

		//flow
		handleClickOppo() {
			getActions({ actionSetting: this.actionSetting })
			.then(data=>{
				this.isLoaded = false;
				this.flowlabel = data[0].label;
				this.flowName = data[0].name;
				this.flowOutput = data[0].output;
				this.redirectId = null;
				this.isShowFlowAction = true;
			}) .catch(error => {
				this.showToast(this.labels.error, this.labels.errorActualizandoEvento, 'error', 'pester');
				this.isLoaded = false;
			});
		}
	
		handleStatusChange(event) {
			const status = event.detail.status;
			const outputVariables = event.detail.outputVariables;
			if(outputVariables) {
				outputVariables.forEach(e => {
					this.flowOutput.split(',').forEach(v => {
						if(e.name == v && e.value) {
							this.redirectId = e.value;
						}
					});
				});       
			}
			console.log(status);
			if(status === 'FINISHED') {
				this.isShowFlowAction = false;
				const selectedEvent = new CustomEvent('closetab', {detail: {recordId: this.redirectId}});
				this.dispatchEvent(selectedEvent);
				eval('$A.get("e.force:refreshView").fire();');
				if(this.redirectId) {
					var redirect = eval('$A.get("e.force:navigateToURL");');
					redirect.setParams({
						"url": "/" + this.redirectId
					});
					redirect.fire();
				}
			}
		}
	
		hideFlowAction() {
			this.isShowFlowAction = false;
		}
}