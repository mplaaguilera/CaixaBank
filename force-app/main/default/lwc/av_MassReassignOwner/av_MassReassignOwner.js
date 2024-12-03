import { LightningElement, track, wire, api } from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

import fetchData from '@salesforce/apex/AV_MassReassignOwner_Controller.getBaseData';
import lookupSearch from '@salesforce/apex/AV_MassReassignOwner_Controller.search';
import lookupSearchAccount from '@salesforce/apex/AV_MassReassignOwner_Controller.searchAccount';
import lookupSearchOffice from '@salesforce/apex/AV_MassReassignOwner_Controller.searchOffice';
import getEmployees from '@salesforce/apex/AV_MassReassignOwner_Controller.getEmployees';
import assign from '@salesforce/apex/AV_MassReassignOwner_Controller.assign';
import nameContactAssign from '@salesforce/apex/AV_MassReassignOwner_Controller.nameContactAssign';
import isBankTeller from '@salesforce/apex/AV_AppUtilities.isBankTeller';
import USER_ID from '@salesforce/user/Id';
import recordLimitLabel from '@salesforce/label/c.AV_BuscadorRecordLimit';
import NAME_FIELD from '@salesforce/schema/User.Name';
import FUNCTION from '@salesforce/schema/User.AV_Funcion__c';
import OFICINA from '@salesforce/schema/User.AV_NumeroOficinaEmpresa__c';
import BPRPS from '@salesforce/customPermission/AV_PrivateBanking';


const columnsTask = [
	{ label: 'Cliente', fieldName: 'AccountNameURL', type: 'url', typeAttributes: { label: { fieldName: 'AccountName' } }, hideDefaultActions: true, wrapText: true, sortable: true, sortBy: 'AccountName' },
	{ label: 'Origen', fieldName: 'AV_Origen__c', type: 'text', hideDefaultActions: true, sortable: true, sortBy: 'AV_Origen__c' },
	{ label: 'Asunto', fieldName: 'SubjectURL', type: 'url', typeAttributes: { label: { fieldName: 'Subject' } }, hideDefaultActions: true, sortable: true, sortBy: 'Subject' },
	{ label: 'Estado', fieldName: 'Status', hideDefaultActions: true, sortable: true, sortBy: 'Status' },
	{ label: 'Prioridad', fieldName: 'Priority', type: 'text', hideDefaultActions: true, sortable: true, sortBy: 'Priority' },
	{ label: 'Edad', fieldName: 'Av_Age__c', type: 'number', typeAttributes: { label: { fieldName: 'AccountAv_Age' } }, hideDefaultActions: true, sortable: true, sortBy: 'Av_Age__c' },
	{ label: 'Ahorro e inversion', fieldName: 'AV_AhorroEInversion__c', type: 'currency', typeAttributes: { length: "16", decimalplaces: "2" }, hideDefaultActions: true, sortable: true, sortBy: 'AV_AhorroEInversion__c' },
	{ label: 'Financiación', fieldName: 'AV_Financiacion__c', type: 'currency', typeAttributes: { length: "16", decimalplaces: "2" }, hideDefaultActions: true, sortable: true, sortBy: 'AV_Financiacion__c' },
	{ label: 'Ingresos', fieldName: 'AV_Ingresos__c', type: 'currency', typeAttributes: { length: "16", decimalplaces: "2" }, hideDefaultActions: true, sortable: true, sortBy: 'AV_Ingresos__c' },//FORMULA
	{ label: 'Precondedido', fieldName: 'AV_Preconceived__c', type: 'currency', hideDefaultActions: true, sortable: true, sortBy: 'AV_Preconceived__c' },//FORMULA
	{ label: 'My Box', fieldName: 'AV_MyBox__c', type: 'picklist', hideDefaultActions: true, sortable: true, sortBy: 'AV_MyBox__c' },//FORMULA
	{ label: 'Target Auto', fieldName: 'AV_TargetAuto__c', type: 'picklist', hideDefaultActions: true, sortable: true, sortBy: 'AV_TargetAuto__c' },//FORMULA
	{ label: 'Fecha vencimiento', fieldName: 'ActivityDate', type: "date-local", typeAttributes: { month: "2-digit", day: "2-digit" }, hideDefaultActions: true, sortable: true, sortBy: 'ActivityDate' },
	{ label: 'Empleado asignado', fieldName: 'OwnerNameURL', type: 'url', typeAttributes: { label: { fieldName: 'OwnerName' } }, hideDefaultActions: true, wrapText: true, sortable: true, sortBy: 'AV_MyBox__c' },
	
	
];
const bprcolsgrp = { label: 'Grupo', fieldName: 'grupo', type:'picklist', sortable: true, sortBy:'grupo'};
const bprcolinter = { label: 'Interlocutor', fieldName: 'interlocName', type: 'text', sortable: true, sortBy:'interlocName'};

if(BPRPS != undefined){
	columnsTask.splice(1,0,bprcolsgrp,bprcolinter);
}



export default class Av_MassReassignOwner extends LightningElement {

	@track data;
	@track targetObjName;
	@track columns;
	@track iconName;
	@track totalRecountCount;
	@track showSpinner = false;
	@track firstSearch = false;
	labelUserId;
	initialSelection = [];
	initialSelectionOffice = [];
	errors = [];
	isMultiEntry = false;
	employeeLabel = 'Asignar a:';
	employeePlaceholder = 'Buscar empleado...';
	clientPlaceholder = 'Buscar cliente...';
	officePlaceholder = 'Buscar oficina...';
	optionsEmployee = [];
	optionsOffice = [];
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
	multiSelectionE = 0;
	multiSelectionS = 0;
	selectedEmployees = [];
	selectedStatus = [{
		label: 'Pendiente',
		value: 'Open',
		bucleId: this.multiSelectionS
	}];
	employeMultiFilter = [];
	statusMultiFilter = [];
	empleFuncion;
	isAnotherOffice = false;

	@api fromMetricChart; 

	employeeDisabled = false;
	statusDiv = true;

	@track taskFilter = false;
	@track subjectFilter = null;
	@track FechaGestionFilter = null;
	@track FechaCierreFilter = null;
	@track employeeFilter;
	@track dueDate2Filter = null;
	@track dueDateFilter = null;
	@track statusFilter = 'Open';
	@track defaultOrigen = 'Priorizador';
	@track clientFilter;
	@track office = null;
	@track myBoxFilter = null;
	@track preconceivedFilter = null;
	@track targetAutoFilter = null;
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
	@track filterProduct;
	directores = ['DC', 'DT', 'DAN', 'SSCC'];

	buttonDisabled;
	showMoreFiltersDiv = false;
	seeFiltersLabel;
	employeesDiv = true;
	isDirector;
	numOficinaEmpresa;

	

	@wire(getRecord, { recordId: USER_ID, fields: [NAME_FIELD, FUNCTION, OFICINA] })
	wiredUser({ error, data }) {
		if (data) {
			this.empleFuncion = data.fields.AV_Funcion__c.value;
			this.empleName = data.fields.Name.value;
			this.empleOfi = data.fields.AV_NumeroOficinaEmpresa__c.value === null ? '': data.fields.AV_NumeroOficinaEmpresa__c.value;
			this.isDirector = this.directores.includes(this.empleFuncion);
			// if (!this.isDirector) {
			this.selectedEmployees = [{ label: this.empleName, id: USER_ID, bucleId: this.multiSelectionE }];
			this.employeeFilter = USER_ID;
			this.getOptionsOffice();
			this.setButtonVisibility();
			// }
		} else if (error) {
			console.log(error)
		}
	}
	connectedCallback() {
		this.showDetail = true;
		this.columns = columnsTask;
	}

	get optionsTaskStatus() {
		return [
			{ label: 'Pendiente', value: 'Open' },
			{ label: 'Pendiente no localizado', value: 'Pendiente no localizado' },
			{ label: 'Gestionada positiva', value: 'Gestionada positiva' },
			{ label: 'Gestionada negativa', value: 'Gestionada negativa' },
			{ label: 'No gestionada', value: 'No gestionada' },
			{ label: 'Gestionado no localizado', value: 'Gestionado no localizado' }
		];
	}

	get optionsTaskOrigen() {
		let withoutManager;
		for (let i = 0; i < this.selectedEmployees.length; i++) {
			if ((this.selectedEmployees[i].label).includes('Sin Gestor')) {
				withoutManager = true;
			}
		}
		if(withoutManager){
			return [
				{ label: 'Experiencia Cliente', value: 'Experiencia Cliente' },
				{ label: 'Avisos', value: 'Avisos' },
				{ label: 'Alertas Comerciales', value: 'Alertas Comerciales' },
				{ label: 'Onboarding Intouch', value: 'Onboarding Intouch' },
				{ label: 'Iniciativa Gestor/a', value: 'Iniciativa Gestor/a' },
				{ label: 'Priorizador', value: 'Priorizador' },
				{ label: 'Clientes priorizados sin asignar', value: 'notAssigned' }
			];
		}else{
			return [
				{ label: 'Experiencia Cliente', value: 'Experiencia Cliente' },
				{ label: 'Avisos', value: 'Avisos' },
				{ label: 'Alertas Comerciales', value: 'Alertas Comerciales' },
				{ label: 'Onboarding Intouch', value: 'Onboarding Intouch' },
				{ label: 'Iniciativa Gestor/a', value: 'Iniciativa Gestor/a' },
				{ label: 'Priorizador', value: 'Priorizador' }
			];
		}
	}

	get optionsYesOrNo() {
		return [
			{ label: 'Sí', value: 'S' },
			{ label: 'No', value: 'N' },
			{ label: '', value: null }
		];
	}

	get optionsPrecon() {
		return [
			{ label: 'Sí', value: 'true' },
			{ label: 'No', value: 'false' },
			{ label: '', value: null }
		];
	}

	getOptionsEmployee(data) {
		getEmployees({ oficina: data }).then(result => {
			if (result != null && result.length > 0) {
				this.optionsEmployee = result;
				if (result.value == USER_ID) {
					this.labelUserId = result.label;
				}
				if (!this.isAnotherOffice) {
					// if (!this.isAnotherOffice && this.isDirector) {
					if (!JSON.stringify(this.optionsEmployee).includes(USER_ID)) {
						this.optionsEmployee.push({ value: USER_ID, label: this.empleName });
					}
				}
				if (this.fromMetricChart != null) {
					if (this.fromMetricChart === 'AV_WarningsToManageSensibleData' || this.fromMetricChart === 'AV_WarningsToManage') {
						this.defaultOrigen = 'Avisos';
					}else{
						this.defaultOrigen = 'notAssigned';
						this.employeeDisabled = true;
					}
					for (let i = 0; i < this.optionsEmployee.length; i++) {
						if ((this.optionsEmployee[i].label).includes('Sin Gestor')) {
							this.employeeFilter = this.optionsEmployee[i].value;
							this.selectedEmployees.splice(0, 2);
							this.selectedEmployees.push({ label: this.optionsEmployee[i].label, id: this.optionsEmployee[i].value, bucleId: this.multiSelectionE });
							this.setButtonVisibility();
						}
					}
					this.handleSearchData();
				} else {
					if (this.isAnotherOffice === false) {
						this.employeeFilter = this.employeeDefault;
						this.selectedEmployees = [{ label: this.empleName, id: this.employeeDefault, bucleId: this.multiSelectionE }];
						this.setButtonVisibility();
					}
				}
			}
		}).catch(error => {
			console.log(error);
		})
	}


	getOptionsOffice() {
		lookupSearchOffice({ searchTerm: this.empleOfi.substring(4), selectedIds: null })
			.then(result => {
				if (result != null) {
					this.template.querySelector('[data-id="clookup5"]').setSearchResults(result);
					this.template.querySelector('[data-id="clookup5"]').scrollIntoView();
					this.numOficinaEmpresa = this.empleOfi.substring(4);
					this.initialSelectionOffice = [{ id: result[0].id, icon: result[0].icon, title: result[0].title }];
					this.getOptionsEmployee(this.empleOfi.substring(4));
					this.setButtonVisibility();
				}
			}).catch(error => {
				console.log(error);
			})
	}

	getDataList(clientFilter, filterList, FechaCierreFilter, FechaGestionFilter, origenFilter, statusFilter, subjectFilter, employeeFilter, dueDate2Filter, dueDateFilter, page, myBoxFilter, preconceivedFilter, targetAutoFilter, numOfiEmp) {
		fetchData({ objectName: this.targetObjName, clientFilter: clientFilter, filterList: filterList, FechaCierreFilter: FechaCierreFilter, FechaGestionFilter: FechaGestionFilter, origenFilter: origenFilter, statusFilter: statusFilter, subjectFilter: subjectFilter, employeeFilter: employeeFilter, dueDateFilter: dueDateFilter, dueDate2Filter: dueDate2Filter, page: page, myBoxFilter: myBoxFilter, preconceivedFilter: preconceivedFilter, targetAutoFilter: targetAutoFilter, office: numOfiEmp })
			.then(result => {
				this.helpMessage = false;
				if (this.targetObjName === 'Task') {
					this.columns = columnsTask;
					this.iconName = 'standard:task';
				}
				if (result.recordList != null && result.recordList.length > 0) {
					var rows = result.recordList;
					if (this.targetObjName === 'Task') {
						for (var i = 0; i < rows.length; i++) {
							var row = rows[i];
							if (row.Owner) {
								row.OwnerName = row.Owner.Name;
							}
							if (row.Account) {
								row.grupo = row.Account.AV_Group__c;
								row.interlocName = row.Account.AV_InterlocName__c;
								row.AccountName = row.Account.Name;
								row.AccountNameURL = '/' + row.AccountId;
								if (row.Account.AV_Age__c) {
									row.Av_Age__c = row.Account.AV_Age__c;
								}
								if (row.Account.AV_AhorroEInversion__c) { row.AV_AhorroEInversion__c = row.Account.AV_AhorroEInversion__c; } else { row.AV_AhorroEInversion__c = 0 }
								if (row.Account.AV_Financiacion__c) { row.AV_Financiacion__c = row.Account.AV_Financiacion__c; } else { row.AV_Financiacion__c = 0 }
								if (row.Account.AV_Ingresos__c != null) { row.AV_Ingresos__c = row.Account.AV_Ingresos__c; } else { row.AV_Ingresos__c = 0 }
								if (row.Account.AV_Preconceived__c) { row.AV_Preconceived__c = row.Account.AV_Preconceived__c };
								if (row.Account.AV_MyBox__c) {
									row.AV_MyBox__c = row.Account.AV_MyBox__c;
								}
								if (row.Account.AV_TargetAuto__c) {
									row.AV_TargetAuto__c = row.Account.AV_TargetAuto__c;
								}
							}
							if (row.Subject) {
								row.SubjectURL = '/' + row.Id;
							}
							if (row.Owner) {
								row.OwnerName = row.Owner.Name;
								row.OwnerNameURL = '/' + row.OwnerId;
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
					if (this.totalPage <= 1) {
						this.isMultipagina = false;
					} else {
						this.isMultipagina = true;
					}
					this.items = this.data.slice((this.page - 1) * 100, this.pageSize * this.page);
					this.endingRecord = this.pageSize;
					this.toggleSpinner();
				} else {
					this.totalRecountCount = 'Total 0';
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
		let targetId = event.target.dataset.id;
		if (targetId === 'clookup1') {
			targetId = 'lookup1';
		} else if (targetId === 'clookup2') {
			targetId = 'lookup2';
		} else if (targetId === 'clookup6') {
			targetId = 'lookup6';
		}
		if (targetId == 'clookup3') {
			const selection = this.template.querySelector(`[data-id="${targetId}"]`).getSelection();
			if (selection.length !== 0) {
				for (let sel of selection) {
					this.filterProduct = String(sel.id);
				}
			} else {
				this.filterProduct = null;
			}
		} else if (targetId == 'lookup1' || targetId == 'lookup6') {
			const selection = this.template.querySelector(`[data-id="${targetId}"] > c-av_-lookup`).getSelection();
			if (selection.length !== 0) {
				for (let sel of selection) {
					this.filterList = String(sel.id);
				}
				this.contactNameA(this.filterList);
			} else {
				this.filterList = null;
			}
		} else if (targetId == 'clookup4') {
			const selection = this.template.querySelector(`[data-id="${targetId}"]`).getSelection();
			if (selection.length !== 0) {
				for (let sel of selection) {
					this.clientFilter = String(sel.id);
				}
			} else {
				this.clientFilter = null;
			}
		} else if (targetId == 'clookup5') {
			const selection = this.template.querySelector(`[data-id="${targetId}"]`).getSelection();
			if (selection.length !== 0) {
				for (let sel of selection) {
					this.getOptionsEmployee(sel.title.substring(0, 5));
					this.numOficinaEmpresa = sel.title.substring(0, 5);
					this.setButtonVisibility();
					
				}
			} else {
				this.numOficinaEmpresa = null;
				this.setButtonVisibility();
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
		var today = new Date();
		var mes = today.getMonth() + 1;
		if (mes <= 9) {
			mes = '0'.concat(mes);
		}
		var dia = today.getDate();
		if (dia <= 9) {
			dia = '0'.concat(dia);
		}
		var fecha = today.getFullYear() + '-' + mes + '-' + dia;
		this.targetObjName = 'Task'
		if (this.targetObjName === 'Task') {
			this.employeMultiFilter = [];
			this.statusMultiFilter = [];
			this.selectedEmployees.forEach(emp => {
				if (!this.employeMultiFilter.includes(emp.id)) {
					this.employeMultiFilter.push(emp.id);
				}
			});
			this.selectedStatus.forEach(stat => {
				if (!this.statusMultiFilter.includes(stat.value)) {
					this.statusMultiFilter.push(stat.value);
				}
			});
		}
		if (((fecha <= this.FechaCierreFilter || this.FechaCierreFilter == null) && (fecha <= this.FechaGestionFilter || this.FechaGestionFilter == null) && this.targetObjName == 'Opportunity')
			|| ((fecha <= this.dueDate2Filter || this.dueDate2Filter == null) && (fecha <= this.dueDateFilter || this.dueDateFilter == null) && this.targetObjName == 'Task')) {
			this.firstSearch = true;
			this.data = null;
			this.toggleSpinner();
			switch (this.targetObjName) {
				case 'Task':
					this.getDataList(this.clientFilter, this.filterProduct, this.FechaCierreFilter, this.FechaGestionFilter, this.defaultOrigen, this.statusMultiFilter, this.subjectFilter, this.employeMultiFilter, this.dueDate2Filter, this.dueDateFilter, this.page, this.myBoxFilter, this.preconceivedFilter, this.targetAutoFilter, this.numOficinaEmpresa);
					break;
			}
		} else {
			const evt = new ShowToastEvent({
				title: 'Filtro incorrecto',
				message: 'La fecha tiene que se mayor o igual a hoy',
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
		this.defaultOrigen = event.target.value;
		if(this.defaultOrigen == 'notAssigned'){
			this.selectedEmployees = [];
			for (let i = 0; i < this.optionsEmployee.length; i++) {
				if ((this.optionsEmployee[i].label).includes('Sin Gestor')) {
					this.employeeFilter = this.optionsEmployee[i].value;
					this.selectedEmployees.push({ label: this.optionsEmployee[i].label, id: this.optionsEmployee[i].value, bucleId: this.multiSelectionE });
				}
			}
			this.employeeDisabled = true;
		}else{
			this.employeeDisabled = false;
		}
		this.setButtonVisibility();
	}

	handleChangeEstado(event) {
		this.statusFilter = event.target.value;
		let statusPick;
		this.multiSelectionS++;
		for (let i = 0; i < this.optionsTaskStatus.length; i++) {
			if (this.optionsTaskStatus[i]['value'] === event.target.value) {
				statusPick = this.optionsTaskStatus[i];
				statusPick['bucleId'] = this.multiSelectionS;
				break;
			}
		}
		let insert = true;
		if (this.selectedStatus.length > 0) {
			for (let i = 0; i < this.selectedStatus.length; i++) {
				if (this.selectedStatus[i].value == statusPick.value) {
					insert = false;
					break;
				}
			}
		}
		if (insert) {
			this.selectedStatus.push(statusPick);
		}
		this.setButtonVisibility();
		this.statusDiv = true;

	}
	unSelectStatus(cmp) {
		let divToDel = cmp.target.parentNode;
		for (let i = 0; i < this.selectedStatus.length; i++) {
			if (this.selectedStatus[i].value === cmp.target.name) {
				this.selectedStatus.splice(i, 1);
				break;
			}
		}
		divToDel.classList.add('delete');
		cmp.target.remove();
		if (this.selectedStatus != null || typeof this.selectedStatus != 'undefined') {
			if (this.selectedStatus.length > 0) {
				this.statusFilter = this.selectedStatus[this.selectedStatus.length - 1].value;
			} else if (this.selectedStatus.length === 0) {
				this.statusFilter = null;
			}
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
		let employeeName = "";
		for (let i = 0; i < this.optionsEmployee.length; i++) {
			if (this.optionsEmployee[i]['value'] === event.target.value) {
				employeeName = this.optionsEmployee[i]['label'];
				// if TODOS selected, remove everyone from selected list
				if (employeeName.includes('TODOS')) {
					this.selectedEmployees = [];
				}
				break;
			}
		}
		let insert = true;
		if (this.selectedEmployees.length > 0) {
			// if TODOS selected, remove TODOS when someone gets added to selected list
			if (this.selectedEmployees[0]['label'].includes('TODOS')) {
				this.selectedEmployees.splice(0, 1); // 0 == TODOS
			}
			for (let i = 0; i < this.selectedEmployees.length; i++) {
				if (this.selectedEmployees[i]['label'] === employeeName) {
					insert = false;
					break;
				}
			}
		}
		if (insert) {
			this.selectedEmployees.push({ label: employeeName, id: event.target.value, bucleId: this.multiSelectionE });
		}
		this.employeesDiv = true;
		this.setButtonVisibility();
	}

	handleChangeFechaCierre(event) {
		this.FechaCierreFilter = event.target.value;
	}

	handleChangeFechaGestion(event) {
		this.FechaGestionFilter = event.target.value;
	}

	unSelectEmployee(cmp) {
		let divToDel = cmp.target.parentNode;
		for (let i = 0; i < this.selectedEmployees.length; i++) {
			if (this.selectedEmployees[i].id === cmp.target.name) {
				this.selectedEmployees.splice(i, 1);
				break;
			}
		}
		divToDel.classList.add('delete');
		cmp.target.remove();
		if (this.selectedEmployees != null || typeof this.selectedEmployees != 'undefined') {
			if (this.selectedEmployees.length > 0) {
				this.employeeFilter = null;
				this.employeeFilter = this.selectedEmployees[this.selectedEmployees.length - 1].id;
			} else if (this.selectedEmployees.length == 0) {
				this.employeeFilter = null;
			}
		}
		//this.optionsTaskOrigen;
		this.setButtonVisibility();
	}

	handleChangeMyBox(event) {
		this.myBoxFilter = event.target.value;
	}
	handleChangePreconceived(event) {
		this.preconceivedFilter = event.target.value;
	}
	handleChangeTargetAuto(event) {
		this.targetAutoFilter = event.target.value;
	}
	//Capture the event fired from the paginator component
	handlePaginatorChange(event) {
		this.recordsToDisplay = event.detail;
	}

	resetFilters() {
		this.template.querySelectorAll('lightning-input').forEach(each => {
			each.value = '';
		});
		this.dueDateFilter = null;
		this.dueDate2Filter = null;
		this.FechaCierreFilter = null;
		this.FechaGestionFilter = null;
		this.defaultOrigen = 'Priorizador';
		this.statusFilter = null;
		this.subjectFilter = null;
		this.filterList = null;
		this.filterProduct = null;
		this.employeeFilter = null;
		try {
			const lookup4 = this.template.querySelector('[data-id="clookup4"]');
			if (lookup4 != null || typeof lookup4 != 'undefined') {
				lookup4.handleClearSelection();
			}
		} catch (e) {
			console.log('clookup4', e);
		}
		try {
			const lookup1 = this.template.querySelector('[data-id="clookup5"]');
			if (lookup1 != null || typeof lookup1 != 'undefined') {
				lookup1.handleClearSelection();
			}
		} catch (e) {
			console.log('clookup5', e);
		}
		this.selectedEmployees = [];
		this.selectedStatus = [];
		this.buttonDisabled = true;
		this.myBoxFilter = null;
		this.preconceivedFilter = null;
		this.targetAutoFilter = null;
		this.statusMultiFilter = [];
		this.employeMultiFilter = [];
		this.isAnotherOffice = false;
		this.numOficinaEmpresa = null;
	}

	toggleShow() {
		if (this.showDetail === true) {
			this.showDetail = false;
		} else {
			this.showDetail = true;
		}
	}

	handleSave() {
		this.toggleSpinner();
		var el = this.template.querySelector('lightning-datatable');
		var selected = el.getSelectedRows();
		// pop up de confirmacion
		if (selected != null && selected.length > 0) {
			assign({ objectName: this.targetObjName, contactId: this.filterList, selectedRows: selected })
				.then(result => {
					if (result != null && result > 0) {
						if (this.targetObjName == 'Task') {
							const evt = new ShowToastEvent({
								title: 'Operación correcta',
								message: 'Se reasignarán ' + result + ' tareas a ' + this.contactName + '. Esta operación puede tardar varios segundos.',
								variant: 'success',
								mode: 'dismissable'
							});
							this.dispatchEvent(evt);
						} else {
							const evt = new ShowToastEvent({
								title: 'Operación correcta',
								message: 'Se reasignarán ' + result + ' oportunidades a ' + this.contactName + '. Esta operación puede tardar varios segundos.',
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
		} else {
			this.handleCloseModal();
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

	get todaysDate() {
		var today = new Date();
		return today.getFullYear() + '-' + (today.getMonth() + 1) + '-' + today.getDate();
	}

	handleModal(event) {
		if (this.filterList != null && this.selectedItems > 0) {
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
		} else if (this.filterList == null) {
			this.actionType = 'noEmpleado';
			this.isModalOpen = true;
		} else {
			switch (this.targetObjName) {
				case 'Task':
					this.actionType = 'noTareas';
					break;
			}
			this.isModalOpen = true;
		}

	}

	doAction(event) {
		var actionType = event.detail.action;
		if (actionType == 'taskAsignar') {
			this.handleSave();
			this.template.querySelector('[data-id="lookup1"] > c-av_-lookup').handleClearSelection();
			this.selectedItems = null;
			this.filterList = null;
		} else if (actionType == 'taskAsignarOtraOficina') {
			this.handleSave();
			this.template.querySelector('[data-id="lookup6"] > c-av_-lookup').handleClearSelection();
			this.selectedItems = null;
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
		if (this.targetObjName === 'Task') {
			this.selectedEmployees.forEach(emp => {
				if (!this.employeMultiFilter.includes(emp.id)) {
					this.employeMultiFilter.push(emp.id);
				}
			});
			this.selectedStatus.forEach(stat => {
				if (!this.statusMultiFilter.includes(stat.value)) {
					this.statusMultiFilter.push(stat.value);
				}
			});
		}
		if ((this.page < this.totalPage) && this.page !== this.totalPage) {
			this.page = this.page + 1; //increase page by 1
			if (this.page * 100 > this.data.length) {
				switch (this.targetObjName) {
					case 'Task':
						this.getDataList(this.clientFilter, this.filterProduct, this.FechaCierreFilter, this.FechaGestionFilter, this.defaultOrigen, this.statusMultiFilter, this.subjectFilter, this.employeMultiFilter, this.dueDate2Filter, this.dueDateFilter, this.page, this.myBoxFilter, this.preconceivedFilter, this.targetAutoFilter, this.numOficinaEmpresa);
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
	displayRecordPerPage(page) {

		this.startingRecord = ((page - 1) * this.pageSize);
		this.endingRecord = (this.pageSize * page);

		this.endingRecord = (this.endingRecord > this.totalNumberOfRecords)
			? this.totalNumberOfRecords : this.endingRecord;
		this.items = this.data.slice(this.startingRecord, this.endingRecord);

		this.startingRecord = this.startingRecord + 1;
	}

	sortBy(field, reverse, primer) {

		if (field == 'Av_Age__c' || field == 'AV_AhorroEInversion__c' || field == 'AV_Financiacion__c' || field == 'AV_Ingresos__c' || field == 'AV_Preconceived__c') {

			const key = primer
				? function (x) {
					return primer(x[field]);
				}
				: function (x) {
					return x[field];
				};

			return function (a, b) {
				a = key(a);
				b = key(b);
				var result;
				if (a == null) {
					result = 1;
				}
				else if (b == null) {
					result = -1;
				} else {
					result = (reverse * ((a > b) - (b > a)));
				};
				return result;
			}
		} else {

			const key = primer
				? function (x) {
					return primer(x[field]);
				}
				: function (x) {
					return x[field];
				};

			return function (a, b) {
				a = key(a);
				b = key(b);
				var result;
				if (a == null) {
					result = 1;
				}
				else if (b == null) {
					result = -1;
				} else {
					result = (reverse * ((a.toLowerCase() > b.toLowerCase()) - (b.toLowerCase() > a.toLowerCase())));
				};
				return result;
			}
		}
	}

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

	showMoreFilters() {
		if (this.showMoreFiltersDiv == false) {
			this.showMoreFiltersDiv = true;
			this.seeFiltersLabel = 'Ver menos filtros';
		} else if (this.showMoreFiltersDiv == true) {
			this.showMoreFiltersDiv = false;
			this.seeFiltersLabel = 'Ver más filtros';
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

	setButtonVisibility() {
		if (this.employeeFilter != null && this.statusFilter != null && this.numOficinaEmpresa != null && this.defaultOrigen != null) {
			this.buttonDisabled = false;
			this.seeFiltersLabel = 'Ver más filtros';
		} else {
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
		if (this.statusFilter != null && this.numOficinaEmpresa != null && this.defaultOrigen != null) {
			this.isAnotherOffice = event.detail.checked;
			this.selectedEmployees = [];
			if (event.detail.checked == true) {
				this.optionsEmployeeAux = this.optionsEmployee;
				this.employeeFilter = null;
				const data = this.empleOfi.substring(4) + '{|}' + this.statusFilter + '{|}' + this.defaultOrigen;
				this.getOptionsEmployee(data);
			} else {
				this.optionsEmployee = this.optionsEmployeeAux;
				this.employeeFilter = this.employeeDefault;
				const evt = new Object({ 'target': { 'value': this.employeeFilter } });
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

}