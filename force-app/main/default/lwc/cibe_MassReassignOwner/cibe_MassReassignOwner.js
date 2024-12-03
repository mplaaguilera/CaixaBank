import { LightningElement, track, wire,api } from 'lwc';
import {getRecord} from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
//methods
import fetchData from '@salesforce/apex/CIBE_MassReassignOwner_Controller.getBaseData';
import lookupSearch from '@salesforce/apex/CIBE_MassReassignOwner_Controller.search';
import lookupSearchAccount from '@salesforce/apex/CIBE_MassReassignOwner_Controller.searchAccount';
import lookupSearchOffice from '@salesforce/apex/CIBE_MassReassignOwner_Controller.searchOffice';
import getEmployees from '@salesforce/apex/CIBE_MassReassignOwner_Controller.getEmployees';
import assign from '@salesforce/apex/CIBE_MassReassignOwner_Controller.assign';
import nameContactAssign from '@salesforce/apex/CIBE_MassReassignOwner_Controller.nameContactAssign';
import getApplicationN from '@salesforce/apex/CIBE_AppUtilities.getAppDefinition';
//schema fields
import USER_ID from '@salesforce/user/Id';
import recordLimitLabel from '@salesforce/label/c.AV_BuscadorRecordLimit';
import NAME_FIELD from'@salesforce/schema/User.Name';
import FUNCTION from '@salesforce/schema/User.AV_Funcion__c';
import OFICINA from '@salesforce/schema/User.AV_NumeroOficinaEmpresa__c';
//labels
import pendiente from '@salesforce/label/c.CIBE_Pendiente';
import pendienteAsig from '@salesforce/label/c.CIBE_PendienteAsignacion';
import pendienteNoLoc from '@salesforce/label/c.CIBE_PendienteNoLocalizado';
import gestionPosi from '@salesforce/label/c.CIBE_GestionadaPositiva';
import gestionNeg from '@salesforce/label/c.CIBE_GestionadaNegativa';
import noGestion from '@salesforce/label/c.CIBE_No_Gestionada';
import gestionNoLoc from '@salesforce/label/c.CIBE_GestionadoNoLocalizado';
import cliente from '@salesforce/label/c.CIBE_Cliente';
import origen from '@salesforce/label/c.CIBE_Origen';
import asunto from '@salesforce/label/c.CIBE_Asunto';
import estado from '@salesforce/label/c.CIBE_Estado';
import prioridad from '@salesforce/label/c.CIBE_Prioridad';
import feschaVen from '@salesforce/label/c.CIBE_FechaDeVencimiento';
import empleadoAs from '@salesforce/label/c.CIBE_EmplAsig';
import oficina from '@salesforce/label/c.CIBE_Oficina';
import alertaCom from '@salesforce/label/c.CIBE_Alerta_Comercial';
import avisos from '@salesforce/label/c.CIBE_Avisos';
import experienciCli from '@salesforce/label/c.CIBE_Experiencia_Cliente';
import gestionaPrior from '@salesforce/label/c.CIBE_Gestionar_Priorizados';
import onboarding from '@salesforce/label/c.CIBE_Onboarding';
import iniciativaGes from '@salesforce/label/c.CIBE_Iniciativa_Ges';
import fechaMay from '@salesforce/label/c.CIBE_fechaMayor';
import reasigTar from '@salesforce/label/c.CIBE_reasignarTareas';
import noContact from '@salesforce/label/c.CIBE_NoContact';
import debeInfo from '@salesforce/label/c.CIBE_debeInformar';
import asignarA from '@salesforce/label/c.CIBE_asignar';
import buscarEmp from '@salesforce/label/c.CIBE_buscarEmpleado';
import buscarCli from '@salesforce/label/c.CIBE_buscarCliente';
import buscarOfi from '@salesforce/label/c.CIBE_buscarOficina';
import verMasF from '@salesforce/label/c.CIBE_debeInformar';

export default class CIBE_MassReassignOwner extends LightningElement {

	labels = {
		pendiente,
		pendienteAsig,
		pendienteNoLoc,
		gestionPosi,
		gestionNeg,
		noGestion,
		gestionNoLoc,
		cliente,
		origen,
		asunto,
		estado,
		prioridad,
		feschaVen, 
		empleadoAs,
		oficina,
		alertaCom,
		avisos,
		experienciCli,
		gestionaPrior,
		onboarding,
		iniciativaGes,
		fechaMay,
		reasigTar,
		noContact,
		debeInfo
	}

	@track data;
	@track targetObjName='Task';
	@track columns;
	@track iconName;
	@track totalRecountCount;
	@track showSpinner = false;
	@track firstSearch = false;
	labelUserId;
	@track initialSelection = [];
	@track initialSelectionOffice = [];
	@track errors = [];
	@track isMultiEntry = false;
	@track employeeLabel = asignarA; 
	@track employeePlaceholder = buscarEmp;
	@track clientPlaceholder = buscarCli;
	@track officePlaceholder = buscarOfi;
	@track seeFiltersLabel = verMasF;
	@track optionsEmployee = [];
	@api employeeDefault = USER_ID;
	@track showDetail = false;
	@track showAssignment = true;
	sortedBy;
	@track defaultSortDirection = 'asc';
    @track sortDirection = 'asc';
	totalNumberOfRecords;
	@api size = 0;
	@api MAX_PAGE_NUM = 20; //Query offset limit = 2000 (100 records * 20 pages)
	@track helpMessage = false;
	@api recordLimit = recordLimitLabel;
	@api multiSelectionE = 0;
	@api multiSelectionS = 0;
	@track selectedEmployees = [];
	@track selectedStatus = [{ label: this.labels.pendiente, value: 'Open' ,bucleId:this.multiSelectionS}];
	@api employeMultiFilter = [];
	@api statusMultiFilter = [];
	empleFuncion;
	@track isAnotherOffice = false;
	@api fromMetricChart; 
	@track statusDiv = true;
	@track employeeOffice = null;
	@track taskFilter = false;
	@track subjectFilter = null;
	@track employeeFilter;
	@track fechaVHasta = null;
	@track fechaVDesde = null;
	@track statusFilter = 'Open';
	@track origenFilter = 'CIBE_GestionarPriorizadosEMP';
	@track defaultOrigen ;
	@track clientFilter;
	@track office = null;
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
	//Paginación
	@track items;
	@track totalPage = 0;
	@track startingRecord = 1;
    @track endingRecord = 0; 
    @track pageSize = 100; 
	@track page = 1; 
	@track isMultipagina = true;
	@track isMultiEntry2 = false;
	@api directores = ['DC','DT','DAN'];
	//'SSCC' ¿?
	@track buttonDisabled;
	@track showMoreFiltersDiv = false;
	@track employeesDiv = true;
	@track seeFiltersLabel = verMasF;
	appOrigin;
	isDirector;
	numOficinaEmpresa;
	//instanciando variables globales
	@api varTarget;
	@api mes;	
	@api dia;
	@api today;
	@api statusPick;
	@api insert;
	@api divToDel;
	@api employeeName;
	@api mmsjeReasig;
	@api mmsjeNoContact;
	
	@track columnsTask = [
		{ label: this.labels.cliente, fieldName: 'AccountNameURL', type: 'url', typeAttributes: {label: { fieldName: 'AccountName' } }, hideDefaultActions: true, wrapText:true,sortable: true, sortBy: 'AccountName'},
		{ label: this.labels.origen, fieldName: 'AV_Origen__c', type: 'text', hideDefaultActions: true, sortable: true},
		{ label: this.labels.asunto, fieldName: 'SubjectURL', type: 'url',typeAttributes:{ label: { fieldName: 'Subject' } }, hideDefaultActions: true,sortable: true},
		{ label: this.labels.estado, fieldName: 'Status', hideDefaultActions: true,sortable:true },
		{ label: this.labels.prioridad, fieldName: 'Priority', type: 'text', hideDefaultActions: true, sortable: true},
		{ label: this.labels.feschaVen, fieldName: 'ActivityDate', type: "date-local",	typeAttributes:{ month: "2-digit", day: "2-digit" }, hideDefaultActions: true, sortable: true},
		{ label: this.labels.empleadoAs, fieldName: 'OwnerNameURL', type: 'url',	typeAttributes:{ label: { fieldName: 'OwnerName' } }, hideDefaultActions: true, wrapText:true,sortable: true},
		{ label: this.labels.oficina, fieldName: 'Oficina', type: 'text', hideDefaultActions: true,sortable: true}
	];
	
	@wire(getRecord,{recordId:USER_ID,fields:[NAME_FIELD,FUNCTION,OFICINA]})
	wiredUser({error,data}){
		if(data){
			this.empleName=data.fields.Name.value;
			this.selectedEmployees = [];
			this.empleFuncion=data.fields.AV_Funcion__c.value;
			this.empleOfi = data.fields.AV_NumeroOficinaEmpresa__c.value;
			this.isDirector = this.directores.includes(this.empleFuncion);
			if(!this.isDirector){
				this.selectedEmployees = [{label:this.empleName,id:USER_ID,bucleId:this.multiSelectionE}];
				this.getOptionsOffice();
			}
			//this.getOptionsOffice();
			this.setVisibilityOptions();
		}else if(error){
			console.log(error)
		}
	}
	
	connectedCallback() {
		this.showDetail = true;
		this.columns=this.columnsTask;
	}

	/*renderedCallback(){
		console.log('renderedCallback: ');
		console.log('this.origenFilter: '+this.origenFilter);

		this.getApplicationN();
		this.origenFilter;
				console.log('this.origenFilter: '+this.origenFilter);

	}
	*/
	get optionsTaskStatus() {
		return [
			{label: this.labels.pendiente, value: 'Open' },
			{label: this.labels.pendienteNoLoc, value: 'Pendiente no localizado' },
			{label: this.labels.gestionPosi, value: 'Gestionada positiva'},
			{label: this.labels.gestionNeg, value: 'Gestionada negativa'},
			{label: this.labels.noGestion, value: 'No gestionada'},
			{label: this.labels.gestionNoLoc, value: 'Gestionado no localizado'}
		];
	}

	get optionsTaskOrigen() {
		return [
			{ label: this.labels.alertaCom, value: 'CIBE_AlertaComercialEMP' },
			{ label: this.labels.avisos, value: 'CIBE_AvisosEMP' },
			{ label: this.labels.experienciCli, value: 'CIBE_ExperienciaClienteEMP' },
			{ label: this.labels.gestionaPrior, value: 'CIBE_GestionarPriorizadosEMP' },
			{ label: this.labels.onboarding, value: 'CIBE_OnboardingEMP' },
			{ label: this.labels.iniciativaGes, value: 'CIBE_OtrosEMP' }
		];
	}

	getOptionsEmployee(data){
		getEmployees({oficina : data}).then(result => {
			if(result != null && result.length > 0 ) {
				this.optionsEmployee = JSON.parse(JSON.stringify(result));
				if (result.value == USER_ID) {
					this.labelUserId=result.label;
				}
				/*if (this.isDirector) {
					this.optionsEmployee.push({value:USER_ID,label:this.empleName});
				}
				*/
				const isUser = false;
				if(this.fromMetricChart == "true"){ 
					for(let i = 0; i < this.optionsEmployee.length; i++){
						if((this.optionsEmployee[i].label).includes('Sin Gestor')){
							this.employeeFilter = this.optionsEmployee[i].value;
							this.selectedEmployees.splice(0,2);
							this.selectedEmployees.push({label:this.optionsEmployee[i].label,id:this.optionsEmployee[i].value,bucleId:this.multiSelectionE});
							this.setVisibilityOptions();
						}
						if(this.optionsEmployee[i].id === USER_ID){
							isUser = true;
						}
					}
					if(!isUser){
						this.optionsEmployee.push({value:USER_ID,label:this.empleName});
					}
				}else{
					if(this.isAnotherOffice === false){
						this.employeeFilter = this.employeeDefault;
					}
					
				}
			}
		}).catch(error => {
			console.log(error);
		})	
	}


	getOptionsOffice() {
		lookupSearchOffice({searchTerm: this.empleOfi.substring(4), selectedIds: null})
			.then(result => {
				this.template.querySelector('[data-id="clookup5"]').setSearchResults(result);
				this.template.querySelector('[data-id="clookup5"]').scrollIntoView();
				this.employeeOffice = result[0].id;
				this.numOficinaEmpresa = this.empleOfi.substring(4);
				this.initialSelectionOffice=[{id: result[0].id, icon:result[0].icon, title: result[0].title}];

				this.getOptionsEmployee(this.empleOfi.substring(4));
				this.setVisibilityOptions();
			}).catch(error => {
				console.log(error);
			})
	}

	getDataList(clientFilter,subjectFilter, origenFilter, statusFilter, fechaVHasta,fechaVDesde, employeeFilter,page,numOfiEmp) {
		fetchData({clientFilter : clientFilter , subjectFilter: subjectFilter, origenFilter : this.origenFilter, statusFilter : statusFilter, fechaVHasta : fechaVHasta, fechaVDesde : fechaVDesde, employeeFilter : employeeFilter,  page : page,office:numOfiEmp})
			.then(result => {
				this.helpMessage = false;
				this.columns = this.columnsTask;
				this.iconName = 'standard:task';
				
				if(result.recordList != null && result.recordList.length > 0) {
					var rows = result.recordList;
					if(this.targetObjName === 'Task') {
						for (var i = 0; i < rows.length; i++) {
							var row = rows[i];
							if(row.Account) {
								row.AccountName = row.Account.Name;
								row.AccountNameURL = '/'+row.AccountId;
							}
							if(row.Subject) {
								row.SubjectURL = '/'+row.Id;
							}
							if(row.Owner){
								row.OwnerName = row.Owner.Name;
								row.OwnerNameURL = '/'+row.OwnerId;
								row.Oficina = row.AV_Center__c ? row.AV_Center__c : null;
							}
                            if(row.CloseDate){
								row.CloseDate = row.CloseDate ? row.CloseDate : null;
							}							
						}
					}
					if (this.page > 1) {
						this.data = this.data.concat(rows);
					} else {
						this.data = [];
						this.data = JSON.parse(JSON.stringify(rows));
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

	handleSelectionChange(event) {
		this.checkForErrors(event);
	}

	handleClear() {
		this.initialSelection = [];
		this.errors = [];
	}

	checkForErrors(event) {
		this.errors = [];
		this.varTarget = event.target.dataset.id;
		if(this.varTarget == 'clookup1'){
			this.varTarget = 'lookup1';
		}else if(this.varTarget == 'clookup2'){
			this.varTarget = 'lookup2';
		} else if (this.varTarget == 'clookup6') {
			this.varTarget = 'lookup6';
		}
		if (this.varTarget =='clookup3') {
			const selection = this.template.querySelector(`[data-id="${this.varTarget}"]`).getSelection();
			if(selection.length !== 0){
				for(let sel of selection) {
					this.filterProduct  = String(sel.id);
				}
			} else {
				this.filterProduct = null;
			}
		} else if (this.varTarget == 'lookup1' || this.varTarget == 'lookup6'){
			const selection = this.template.querySelector(`[data-id="${this.varTarget}"] > c-av_-lookup`).getSelection();
			if(selection.length !== 0){
				for(let sel of selection) {
					this.filterList  = String(sel.id);
				}
				this.contactNameA(this.filterList);
			} else {
				this.filterList = null;
			}
		} else if (this.varTarget =='clookup4'){
			const selection = this.template.querySelector(`[data-id="${this.varTarget}"]`).getSelection();
			if(selection.length !== 0){
				for(let sel of selection) {
					this.clientFilter  = String(sel.id);
				}
			} else {
				this.clientFilter = null;
			}
		} else if (this.varTarget == 'clookup5') {
			const selection = this.template.querySelector(`[data-id="${this.varTarget}"]`).getSelection();
			if(selection.length !== 0){
				for(let sel of selection) {
					this.getOptionsEmployee(sel.title.substring(0,5));
					this.numOficinaEmpresa = sel.title;
					this.employeeOffice = String(sel.id);
					this.setVisibilityOptions();
				}
			} else {
				console.log('Error retrieving offices');
			}
		}
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
	
	handleSearchData() {
		this.page = 1;
		this.size = 0;
		this.today = new Date();
		this.mes =this.today.getMonth()+1;
		if (this.mes<=9) {
			this.mes='0'.concat(this.mes);
		}
		this.dia=this.today.getDate();
		if (this.dia<=9) {
			this.dia='0'.concat(this.dia);
		}
		this.fecha=this.today.getFullYear() + '-' + this.mes + '-' + this.dia;
		this.targetObjName = 'Task'
		if(this.targetObjName === 'Task'){
			this.employeMultiFilter=[];
			this.statusMultiFilter=[];
			this.selectedEmployees.forEach(emp => {
				if(!this.employeMultiFilter.includes(emp.id)){
					this.employeMultiFilter.push(emp.id);
				}
			});
			this.selectedStatus.forEach(stat => {
				if(!this.statusMultiFilter.includes(stat.value)){
					this.statusMultiFilter.push(stat.value);
				}				
			});
		}
		if (((this.fecha<=this.fechaVHasta || this.fechaVHasta == null)&& (this.fecha>=this.fechaVDesde || this.fechaVDesde == null) && this.targetObjName=='Task')) {
			this.firstSearch = true;
			this.data = null;
			this.toggleSpinner();
			switch (this.targetObjName) {
				case 'Task':
					this.getDataList(this.clientFilter, this.subjectFilter, this.origenFilter, this.statusMultiFilter, this.fechaVHasta,this.fechaVDesde, this.employeMultiFilter,this.page,this.numOficinaEmpresa);
					break;
			}
		}else {
			const evt = new ShowToastEvent({
				title: 'Filtro incorrecto',
				message: this.labels.fechaMay,
				variant: 'error',
				mode: 'dismissable'
			});
			this.dispatchEvent(evt);
		}
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
		console.log('handleChangeOrigen: '+event.target.value);
		this.origenFilter = event.target.value;
		this.setVisibilityOptions();
	}
	
	handleChangeEstado(event) {
		this.statusFilter = event.target.value;
		this.multiSelectionS++;
		for(let i=0;i<this.optionsTaskStatus.length;i++){
			if(this.optionsTaskStatus[i]['value']===event.target.value){
				this.statusPick=this.optionsTaskStatus[i];
				this.statusPick['bucleId']=this.multiSelectionS;
				break;
			}
		}
		this.insert = true;	
		if(this.selectedStatus.length > 0){
			for (let i = 0; i < this.selectedStatus.length; i++) {
				if (this.selectedStatus[i].value==this.statusPick.value) {
					this.insert = false;
					break;
				}
			}
		}	
		if (this.insert) {
			this.selectedStatus.push(this.statusPick);
		}
		this.setVisibilityOptions();
		this.statusDiv=true;

	}
	unSelectStatus(cmp){
		this.divToDel = cmp.target.parentNode;
		for(let i=0;i<this.selectedStatus.length;i++){
			if(this.selectedStatus[i].value === cmp.target.name){
				this.selectedStatus.splice(i,1);
				break;
			}
		}
		this.divToDel.classList.add('delete');
		cmp.target.remove();
		if (this.selectedStatus != null || typeof this.selectedStatus != 'undefined') {
			if (this.selectedStatus.length > 0) {
				this.statusFilter = this.selectedStatus[this.selectedStatus.length-1].value;
			} else if (this.selectedStatus.length === 0) {
				this.statusFilter = null;
			}
		}
		this.setButtonVisibility();
	}

	handleChangeDueDate(event) {
		this.fechaVDesde = event.target.value;
	}

	handleChangeDueDate2(event) {
		this.fechaVHasta = event.target.value;
	}

	handleChangeEmployee(event) {
		this.multiSelectionE++;
		this.employeeFilter = event.target.value;
		console.log('this.employeeFilter: '+this.employeeFilter);
		console.log('this.selectedEmployees: '+this.selectedEmployees);

		for(let i=0;i<this.optionsEmployee.length;i++){
			if(this.optionsEmployee[i]['value']===event.target.value){
				this.employeeName=this.optionsEmployee[i]['label'];
				// if TODOS selected, remove everyone from selected list
				if (this.employeeName.includes('TODOS')) {
					this.selectedEmployees = [];
				}
				break;
			}
		}
		this.insert = true;
		if(this.selectedEmployees.length > 0 ){
			// if TODOS selected, remove TODOS when someone gets added to selected list
			if (this.selectedEmployees[0]['label'].includes('TODOS')) {
				this.selectedEmployees.splice(0, 1); // 0 == TODOS
			}
			for (let i = 0; i < this.selectedEmployees.length; i++) {
				if (this.selectedEmployees[i]['label']===this.employeeName) {
					this.insert = false;
					break;
				}				
			}
		}			
		if (this.insert) {
			this.selectedEmployees.push({label:this.employeeName,id:event.target.value,bucleId:this.multiSelectionE});	
		}
		this.employeesDiv = true;
		this.setVisibilityOptions();
	}

	unSelectEmployee(cmp){
		this.divToDel = cmp.target.parentNode;
		for(let i=0;i<this.selectedEmployees.length;i++){
			if(this.selectedEmployees[i].id === cmp.target.name){
				this.selectedEmployees.splice(i,1);
				break;
			}
		}
		this.divToDel.classList.add('delete');
		cmp.target.remove();
		if (this.selectedEmployees != null || typeof this.selectedEmployees != 'undefined') {
			if (this.selectedEmployees.length > 0) {
				this.employeeFilter = this.selectedEmployees[this.selectedEmployees.length-1].id;
			} else if (this.selectedEmployees.length === 0) {
				this.employeeFilter = null;
			}
		}
		this.setButtonVisibility();
	}


	//Capture the event fired from the paginator component
    handlePaginatorChange(event){
        this.recordsToDisplay = event.detail;
    }

	resetFilters(){
		this.template.querySelectorAll('lightning-input').forEach(each => {
			each.value = '';
		});
		this.fechaVDesde = null;
		this.fechaVHasta = null;
		this.origenFilter = null;
		this.statusFilter = null;
		this.subjectFilter = null;
		this.filterList = null;
		this.employeeFilter = null;
		try {
			const lookup4 = this.template.querySelector('[data-id="clookup4"]');
			if (lookup4 != null || typeof lookup4 != 'undefined') {
				lookup4.handleClearSelection()
			}
		} catch (e) {
			console.log('e1',e);
		}
		try {
			const lookup1 = this.template.querySelector('[data-id="lookup1"] > c-av_-lookup');
			if (lookup1 != null || typeof lookup1 != 'undefined') {
				lookup1.handleClearSelection();
			}
		} catch (e) {
			console.log('e2',e);
		}
		try {
			const lookup5 = this.template.querySelector('[data-id="clookup5"]');
			if (lookup5 != null || typeof lookup5 != 'undefined') {
				lookup5.handleClearSelection()
			}
		} catch (e) {
			console.log('e3',e);
		}
		this.selectedEmployees = [];
		this.selectedStatus = [];
		this.buttonDisabled = true;
		this.preconceivedFilter = null;
		this.targetAutoFilter= null;
		this.statusMultiFilter = [];
		this.employeMultiFilter = [];
		this.isAnotherOffice = false;
		this.firstSearch = false;
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
			assign({objectName: this.targetObjName,  contactId : this.filterList ,selectedRows : selected})
			.then(result => {
				this.mmsjeReasig = this.labels.reasigTar;
				if(result != null && result > 0) {
					this.mmsjeReasig = this.mmsjeReasig.replace('result',result);
					this.mmsjeReasig = this.mmsjeReasig.replace('contactName ',this.contactName);
						const evt = new ShowToastEvent({
							title: 'Operación correcta',
							message: this.mmsjeReasig,
							variant: 'success',
							mode: 'dismissable'
						});
						this.dispatchEvent(evt);
				} else {
					let mmsjeNoContact = this.labels.noContact;
					mmsjeNoContact = mmsjeNoContact.replace('contactName ',this.contactName);
					const evt = new ShowToastEvent({
						title: 'Operación incorrecta',
						message: mmsjeNoContact,
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
					this.contactName = JSON.parse(JSON.stringify(result));
				}
			})
			.catch(error => {
				console.log(error);
			});
	}

	get todaysDate() {
		this.today = new Date();
		return this.today.getFullYear() + '-' + (this.today.getMonth()+1) + '-' + this.today.getDate();
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
			}
			this.isModalOpen = true;
		}
		
    }

	doAction(event) {
        this.actionType = event.detail.action;
		if ( this.actionType =='taskAsignar' ) {
			this.handleSave();
			this.template.querySelector('[data-id="lookup1"] > c-av_-lookup').handleClearSelection();
			this.selectedItems=null;
			this.filterList = null;
		} else if ( this.actionType == 'taskAsignarOtraOficina' ) {
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
		this.targetObjName = 'Task'//BORRAR
		if(this.targetObjName === 'Task'){
			this.selectedEmployees.forEach(emp => {
				if(!this.employeMultiFilter.includes(emp.id)){
					this.employeMultiFilter.push(emp.id);
				}
			});
			this.selectedStatus.forEach(stat => {
				if(!this.statusMultiFilter.includes(stat.value)){
					this.statusMultiFilter.push(stat.value);
				}				
			});
		}
        if((this.page<this.totalPage) && this.page !== this.totalPage){
            this.page = this.page + 1; //increase page by 1
			if (this.page*100 > this.data.length) {
				switch (this.targetObjName) {
					case 'Task':
						this.getDataList(this.clientFilter, this.subjectFilter, this.origenFilter, this.statusMultiFilter, this.fechaVHasta,this.fechaVDesde, this.employeMultiFilter,this.page,this.numOficinaEmpresa);
						break;
				}
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

    /*onHandleSort(event) {
		console.log('onHandleSort');
		console.log(event.detail);
        const  aux = { fieldName: sortedBy, sortDirection } = event.detail;
		console.log(sortedBy);
		console.log(sortDirection);
        const cloneData = [...this.items];
		const rowName = event.detail.row.id;
        const hasChildrenContent = event.detail.hasChildrenContent;
        cloneData.sort(this.sortBy(sortedBy, sortDirection === 'asc' ? 1 : -1));
        this.items = cloneData;
        this.sortDirection = sortDirection;
        this.sortedBy = sortedBy;
		console.log(this.sortDirection);
		console.log(this.sortedBy);
		console.log(this.items);
    }*/

	onHandleSort(event) {
		let sortedBy = event.detail.fieldName;
		let sortDirection = event.detail.sortDirection;
		const cloneData = [...this.items];
		const sortFieldName = this.columns.find(field => sortedBy === field.fieldName).sortBy;
		cloneData.sort(this.sortBy(sortFieldName, sortDirection === 'asc' ? 1 : -1));
		this.items = cloneData;
		this.sortDirection = sortDirection;
		this.sortedBy = sortedBy;
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

	/**
	 * show App value
	 */
	getApplicationN() {
		getApplicationN()
			.then((result) => {
				if (result) {
					console.log('Aplicacion: '+JSON.stringify(result));
					if(result =='CIBE_MisClientesEMP'){
						this.appOrigin = true;
						this.origenFilter = 'CIBE_GestionarPriorizadosEMP';
					}else{
						this.appOrigin = false;
						this.origenFilter = 'CIBE_OtrosCIB';
					}
				}
			})
			.catch((error) => {
				console.error('Hide assignment error', JSON.stringify(error));
				this.errors = [error];
			});
	}

	setVisibilityOptions() {

		if ((this.office != null || this.employeeOffice != null) && this.statusFilter != null) {
				this.buttonDisabled = false;
				this.seeFiltersLabel = 'Ver más filtros';
		}
	}

	setButtonVisibility() {
		if (this.employeeFilter == null || typeof this.employeeFilter == 'undefined' ||
			this.statusFilter == null || typeof this.statusFilter == 'undefined') {
			this.buttonDisabled = true;
		}
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

	/**
	 * @description		Get the employees that are not assigned to the selected office but
	 * 					own tasks in the selected office
	 * @param event 	Toggle check
	 */
	handleAnotherOffice(event) {
		// Check if office and status exist for the query to run faster
		if (this.initialSelectionOffice != null && this.statusFilter != null && this.origenFilter != null) {
			this.isAnotherOffice = event.detail.checked;
			this.selectedEmployees = [];
			if (event.detail.checked === true) {
				console.log(this.employeeFilter);
				this.optionsEmployeeAux = this.optionsEmployee;
				this.employeeFilter = null;
				console.log(this.optionsEmployeeAux);
				console.log(this.optionsEmployee);
				console.log(this.empleOfi);
				console.log(this.empleOfi.substring(4));
				console.log(this.numOficinaEmpresa);
				const data = this.empleOfi.substring(4) + '{|}' + this.statusFilter + '{|}' + this.origenFilter;
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
			let mmsjeDebe = this.labels.debeInfo;
			const evt = new ShowToastEvent({
				title: 'Filtro incorrecto',
				message: mmsjeDebe,
				variant: 'info',
				mode: 'dismissable'
			});
			this.dispatchEvent(evt);
		}
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

}