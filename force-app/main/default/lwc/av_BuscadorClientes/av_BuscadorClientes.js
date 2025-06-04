import {LightningElement, track, wire} from 'lwc';
import {ShowToastEvent} from 'lightning/platformShowToastEvent';
import {getRecord} from 'lightning/uiRecordApi';
import fetchData from '@salesforce/apex/AV_BuscadorClientes_Controller.getBaseData';
import lookupSearchOffice from '@salesforce/apex/AV_BuscadorClientes_Controller.searchOffice';
import getEmployees from '@salesforce/apex/AV_BuscadorClientes_Controller.getEmployees';
import getBooks from '@salesforce/apex/AV_BuscadorClientes_Controller.getBooks';
import recordLimitLabel from '@salesforce/label/c.AV_BuscadorRecordLimit';
import USER_ID from '@salesforce/user/Id';
import NAME_FIELD from '@salesforce/schema/User.Name';
import FUNCTION from '@salesforce/schema/User.AV_Funcion__c';
import OFICINA from '@salesforce/schema/User.AV_NumeroOficinaEmpresa__c';
import POOL from '@salesforce/schema/User.AV_Pool__c';
import enanchedGetUserInfo from '@salesforce/apex/AV_OppSearch_Controller.enanchedGetUserInfo';

const columnsCli = [
	{label: 'Nombre Cliente', fieldName: 'nameUrl', type: 'url', typeAttributes: {label: {fieldName: 'name'}, tooltip: {fieldName: 'name'}}, hideDefaultActions: true, wrapText: true, sortable: true, sortBy: 'name'},
	{label: 'Cesta/Cartera', fieldName: 'carteraName', type: 'text', sortable: true, sortBy: 'carteraName'},
	{label: 'Modelo de atención', fieldName: 'modelo', type: 'text', sortable: true, sortBy: 'modelo'},
	{label: 'NIF', fieldName: 'nif', type: 'text', sortable: true, sortBy: 'nif'},
	{label: 'Edad', fieldName: 'edad', type: 'number', hideDefaultActions: true, sortable: true, sortBy: 'edad'},
	{label: 'Ingresos', fieldName: 'ingresos', hideDefaultActions: true, type: 'currency', typeAttributes: {currencyCode: 'EUR', maximumSignificantDigits: '20'}, sortable: true, sortBy: 'ingresos'},
	{label: 'Ahorro e Inversión', fieldName: 'ahorro', hideDefaultActions: true, sortable: true, sortBy: 'ahorro', type: 'currency', typeAttributes: {currencyCode: 'EUR', maximumSignificantDigits: '20'}},
	{label: 'Financiación', fieldName: 'financiacion', hideDefaultActions: true, sortable: true, sortBy: 'financiacion', type: 'currency', typeAttributes: {currencyCode: 'EUR', maximumSignificantDigits: '20'}},
	{label: 'Rentabilidad', fieldName: 'rentabilidad', hideDefaultActions: true, sortable: true, sortBy: 'rentabilidad', type: 'currency', typeAttributes: {currencyCode: 'EUR', maximumSignificantDigits: '20'}},
	{label: 'Negocio', fieldName: 'negocio', type: 'text', sortable: true, sortBy: 'negocio'},
	{label: 'Vinculación', fieldName: 'vinculacion', type: 'text', sortable: true, sortBy: 'vinculacion'},
	{label: 'Experiencia de Cliente', fieldName: 'experiencia', type: 'text', sortable: true, sortBy: 'experiencia'},
	{label: 'Empleado', fieldName: 'gestorUrl', type: 'url', typeAttributes: {label: {fieldName: 'gestorName'}, tooltip: {fieldName: 'gestorName'}}, hideDefaultActions: true, wrapText: true, sortable: true, sortBy: 'gestorName'},
	{label: 'Oficina principal', fieldName: 'office', type: 'text', sortable: true, sortBy: 'office'},
	{label: 'My Box', fieldName: 'myBox', type: 'picklist', sortable: true, sortBy: 'myBox'},
	{label: 'Preconcedido', fieldName: 'preconceived', hideDefaultActions: true, sortable: true, sortBy: 'preconceived', type: 'currency', typeAttributes: {currencyCode: 'EUR', maximumSignificantDigits: '20'}},
	{label: 'Target Auto', fieldName: 'targetAuto', type: 'picklist', sortable: true, sortBy: 'targetAuto'}
];


export default class Av_BuscadorClientes extends LightningElement {

    @track data;

	@track targetObjName = 'Opportunity';

	@track columns;

	@track iconName;

	@track totalRecountCount;

	@track showSpinner = false;

	@track firstSearch = false;

	@track optionsBook = [];

	initialSelection = [];

	initialSelectionOffice = [];

	initialSelectionBook = [];

	errors = [];

	isMultiEntry = false;

	officePlaceholder = 'Buscar oficina...';

	bookPlaceholder = 'Buscar cartera...';

	optionsEmployee = [];

	optionsEmployeeAux = []; //used when other employee's toggle is checked

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

	selectedBooks = [];

	empleFuncion;

	isDirector;

	directores = ['DC', 'DT', 'DAN', 'SSCC'];

	buttonDisabled = true;

	seeFiltersLabel = 'Ver más filtros';

	multiSelectionE = 0;

	multiSelectionS = 0;

	employeesDiv = true;

	showMoreFiltersDiv = false;

	employeMultiFilter = [];

	productsMultiFilter = [];

	myBoxFilter = null;

	preconceivedFilter = null;

	targetAutoFilter = null;

	numOficinaEmpresa = null;

	multigestorId;

	@track employeeFilter;

	@track filterList;

    @track negocioFilter = 'TODOS';

    @track carteraFilter;

    @track modeloFilter;

    @track edadMinFilter;

	@track edadMaxFilter;

    @track ingresosMinFilter;

	@track ingresosMaxFilter;

    @track ahorroMinFilter;

	@track ahorroMaxFilter;

    @track financiacionMinFilter;

	@track financiacionMaxFilter;

    @track rentabilidadMinFilter;

	@track rentabilidadMaxFilter;

	@track preconMinFilter;

	@track preconMaxFilter;

    @track experienciaFilter;

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

	@track placeHolder;

    @track emptyBook;

	@wire(getRecord, {recordId: USER_ID, fields: [NAME_FIELD, FUNCTION, OFICINA, POOL]})
    wiredUser({error, data}) {
    	if (data) {
    		this.empleFuncion = data.fields.AV_Funcion__c.value;
    		this.empleName = data.fields.Name.value;
    		this.empleOfi = data.fields.AV_NumeroOficinaEmpresa__c.value === null ? '' : data.fields.AV_NumeroOficinaEmpresa__c.value;
    		this.isDirector = this.directores.includes(this.empleFuncion);
    		this.selectedEmployees = [{label: this.empleName, id: USER_ID, bucleId: this.multiSelectionE}];
    		this.getOptionsOffice();
    		this.employeeFilter = USER_ID;
    		this.setButtonVisibility();

    	} else if (error) {
    		console.log(error);
    	}
    }

	connectedCallback() {
		this.showDetail = true;
		this.columns = columnsCli;
		this.setButtonVisibility();
	}

	get optionsModelo() {
		return [
			{label: 'Alto potencial', value: 'A'},
			{label: 'Potencial', value: 'B'},
			{label: 'Puntual', value: 'C'},
			{label: 'inTouch', value: 'D'},
			{label: 'Imagin', value: 'E'},
			{label: 'Premier', value: 'H'},
			{label: 'Premier Senior', value: 'I'},
			{label: 'InTouch Alto Potencial', value: 'J'},
			{label: 'InTouch Potencial', value: 'K'},
			{label: 'Privada Base', value: 'L'},
			{label: 'Privada Estándar', value: 'M'},
			{label: 'Privada Plus', value: 'N'},
			{label: 'Sin consentimiento GDPR', value: 'X'},
			{label: '', value: null}
		];
	}

	get optionsNegocio() {
		return [
			{label: 'Todos', value: 'TODOS'},
			{label: 'Banca Empresas', value: 'EMP'},
			{label: 'Banca Corporativa', value: 'COR'},
			{label: 'Banca Privada', value: 'BPR'},
			{label: 'Banca Particulares', value: 'BPA'},
			{label: 'Negocios', value: 'NEG'},
			{label: 'Corporate Institutions Banking', value: 'CIB'},
			{label: 'Banca Emprendedores', value: 'MIC'},
			{label: 'Banca Promotores', value: 'PRO'},
			{label: 'Banca Premier', value: 'BPE'},
			{label: 'Internacional', value: 'INT'},
			{label: 'Seguros', value: 'SEG'},
			{label: 'Banca Privada. Oficina', value: 'BPO'},
			{label: 'Clientes Potenciales', value: 'POT'},
			{label: 'Banca Instituciones', value: 'INS'},
			{label: 'Pendiente de asignación', value: 'PDT'},
			{label: 'Gestionada por otros gestores', value: 'OTR'},
			{label: 'Gestionada por la oficina', value: 'OFI'},
			{label: 'Bancos Corresponsales', value: 'BCO'},
			{label: 'Analista de Riesgo', value: 'RIE'},
			{label: 'Especialista Morosidad', value: 'MOR'},
			{label: 'Especialista Financiación', value: 'FIN'},
			{label: 'Especialista Tesorería', value: 'TES'},
			{label: 'Especialista Comex', value: 'CMX'},
			{label: 'Banca Privada Asesoramiento independiete', value: 'BAI'},
			{label: 'Banca Privada Relacionada', value: 'BIR'},
			{label: 'Banca Privada Asesoramiento Independiente. Oficina', value: 'BIO'}
		];
	}

	get optionsExperiencia() {
		return [
			{label: 'Promotor', value: '1'},
			{label: 'Neutro', value: '2'},
			{label: 'Detractor', value: '3'},
			{label: '', value: null}
		];
	}

	getLabelExperiencia(value) {
		let label = '';
		if (value) {
			switch (value) {
				case '1':
					label = 'Promotor';
					break;
				case '2':
					label = 'Neutro';
					break;
				case '3':
					label = 'Detractor';
					break;
				default:
					label = '';
			}
		}
		return label;
	}

	get optionsYesOrNo() {
		return [
			{label: 'Sí', value: 'S'},
			{label: 'No', value: 'N'},
			{label: '', value: null}
		];
	}

	get optionsPrecon() {
		return [
			{label: 'Sí', value: 'true'},
			{label: 'No', value: 'false'},
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
					this.initialSelectionOffice = [{id: result[0].id, icon: result[0].icon, title: result[0].title}];
					this.getOptionsEmployee(this.empleOfi.substring(4));
					this.getOptionsBooks(this.employeeFilter);
					this.setButtonVisibility();
				}
			}).catch(error => {
				console.log(error);
			});
	}

	getOptionsEmployee(data) {
		getEmployees({oficina: data})
			.then(result => {
				if (result != null && result.length > 0) {
					this.optionsEmployee = result;
					if (this.isDirector) {
						if (!JSON.stringify(this.optionsEmployee).includes(USER_ID)) {
							this.optionsEmployee.push({value: USER_ID, label: this.empleName});
						}
					}
					this.employeeFilter = USER_ID;
					this.selectedEmployees = [{label: this.empleName, id: this.employeeDefault, bucleId: this.multiSelectionE}];
					this.setButtonVisibility();
				}
			}).catch(error => {
				console.log(error);
			});
	}

	getOptionsBooks(employeeId) {
		getBooks({employeeId: employeeId})
		.then(result => {
			this.optionsBook = [];
			if (result != null && result.length > 0) {
				this.optionsBook = result;
				this.placeHolder = '--Seleccionar--';
				this.emptyBook = false;
			} else {
				this.placeHolder = 'Empleado sin carteras';
				this.emptyBook = true;
			}
		}).catch(error => {
			console.log(error);
		});
	}

	getDataList(numOficinaEmpresa, negocioFilter, employeMultiFilter, carteraFilter, modeloFilter, edadMinFilter, edadMaxFilter, ingresosMinFilter, ingresosMaxFilter, ahorroMinFilter, ahorroMaxFilter, financiacionMinFilter, financiacionMaxFilter, rentabilidadMinFilter, rentabilidadMaxFilter, experienciaFilter, myBoxFilter, preconMinFilter, preconMaxFilter, targetAutoFilter, page) {
		fetchData({office: numOficinaEmpresa, negocio: negocioFilter, employeeFilter: employeMultiFilter, cartera: carteraFilter, modelo: modeloFilter, edadMin: edadMinFilter, edadMax: edadMaxFilter, ingresosMin: ingresosMinFilter, ingresosMax: ingresosMaxFilter, ahorroMin: ahorroMinFilter, ahorroMax: ahorroMaxFilter, financiacionMin: financiacionMinFilter, financiacionMax: financiacionMaxFilter, rentabilidadMin: rentabilidadMinFilter, rentabilidadMax: rentabilidadMaxFilter, exp: experienciaFilter, mybox: myBoxFilter, preconMin: preconMinFilter, preconMax: preconMaxFilter, targetAuto: targetAutoFilter, page: page})
			.then(result => {
				this.targetObjName == 'Opportunity';
				this.helpMessage = false;
				if (result.recordList != null && result.recordList.length > 0) {
					this.columns = columnsCli;
					this.iconName = 'custom:custom15';
					let rows = result.recordList;

					for (let i = 0; i < rows.length; i++) {
						let row = rows[i];
						row.carteraName = row.cartera != null ? row.cartera.AV_Cartera__r.AV_ExternalID__c : null;
						row.modelo = row.modelo;
						row.name = row.name;
						row.nameUrl = '/' + row.id;
						row.nif = row.nif;
						row.edad = row.edad;
						row.negocio = row.negocio;
						row.vinculacion = row.vinculacion;
						row.experiencia = row.experiencia ? this.getLabelExperiencia(row.experiencia) : null;
						row.financiacion = Math.floor(row.financiacion);
						row.ahorro = Math.floor(row.ahorro);
						row.ingresos = Math.floor(row.ingresos);
						row.rentabilidad = Math.floor(row.rentabilidad);
						row.office = row.office ? row.office : null;
						if (row.gestorName != null) {
							row.gestorName = row.gestorName;
						} else {
							row.gestorName = '';
						}
						if (row.gestorId != null) {
							row.gestorUrl = '/' + row.gestorId;
						} else {
							row.gestorUrl = '';
						}

						row.preconceived = row.precon ? row.precon : null;
						row.myBox = row.myBox ? row.myBox : null;
						row.targetAuto = row.targetAuto ? row.targetAuto : null;
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
						if (this.size == 100000) {
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
					this.totalRecountCount  = 'Total 0';
					this.toggleSpinner();
				}
			})
			.catch(error => {
				console.log(error);
				this.toggleSpinner();
			});
	}

	handleLookupTypeChange(event) {
		this.initialSelection = [];
		this.errors = [];
		this.isMultiEntry = event.target.checked;
	}

	handleSearchOffice(event) {
		lookupSearchOffice(event.detail)
			.then(results => {
				this.template.querySelector('[data-id="clookup5"]').setSearchResults(results);
				this.template.querySelector('[data-id="clookup5"]').scrollIntoView();
			})
			.catch(error => {
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
		if (targetId == 'clookup4') {
			const selection = this.template.querySelector(`[data-id="${targetId}"]`).getSelection();
			if (selection.length !== 0) {
				for (let sel of selection) {
					this.carteraFilter = String(sel.id);
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
			//Notify via alert
			//eslint-disable-next-line no-alert
			alert(`${title}\n${message}`);
		} else {
			//Notify via toast
			const toastEvent = new ShowToastEvent({title, message, variant});
			this.dispatchEvent(toastEvent);
		}
	}

	handleSearchData() {
		this.page = 1;
		this.size = 0;
		this.firstSearch = true;
		this.data = null;
		this.setMultiSelectors();

		enanchedGetUserInfo({userId: USER_ID})
			.then(response => {
				const gestor = response.gestor;
				const hasPool = gestor.AV_Pool__c;
				let searchEmployeeFilter = [];

				this.multigestorId = response.multigestor ? response.multigestor.Id : null;

				if (!this.isEmployeeSelectedManually) {
					if (hasPool) {
						searchEmployeeFilter = [gestor.Id];
						if (response.multigestor) {
							searchEmployeeFilter.push(this.multigestorId);
						}
					} else {
						searchEmployeeFilter = [this.employeeFilter];
					}
				} else {
					searchEmployeeFilter = [this.employeeFilter];
					if (this.employeeFilter === USER_ID && hasPool) {
						searchEmployeeFilter = [gestor.Id];
						if (response.multigestor) {
							searchEmployeeFilter.push(this.multigestorId);
						}
					}
				}

				this.getDataList(this.numOficinaEmpresa, this.negocioFilter, searchEmployeeFilter, this.carteraFilter, this.modeloFilter, this.edadMinFilter, this.edadMaxFilter, this.ingresosMinFilter, this.ingresosMaxFilter, this.ahorroMinFilter, this.ahorroMaxFilter, this.financiacionMinFilter, this.financiacionMaxFilter, this.rentabilidadMinFilter, this.rentabilidadMaxFilter, this.experienciaFilter, this.myBoxFilter, this.preconMinFilter, this.preconMaxFilter, this.targetAutoFilter, this.page);
				this.toggleSpinner();
			})
			.catch(error => {
				console.error('Error al obtener información del usuario: ', error);
				this.toggleSpinner();
			});
	}

	toggleSpinner() {
		this.showSpinner = !this.showSpinner;
	}

	handleChangeClient(event) {
		this.clientFilter = event.target.value;
	}

	handleChangeNegocio(event) {
		this.negocioFilter = event.target.value;
		this.setButtonVisibility();
	}

	handleChangeCartera(event) {
		this.carteraFilter = event.target.value;
	}

	handleChangeModelo(event) {
		this.modeloFilter = event.target.value;
	}

	handleChangeEdadMin(event) {
		this.edadMinFilter = event.target.value;
	}

	handleChangeEdadMax(event) {
		this.edadMaxFilter = event.target.value;
	}

	handleChangeIngresosMin(event) {
		this.ingresosMinFilter = event.target.value;
	}

	handleChangeIngresosMax(event) {
		this.ingresosMaxFilter = event.target.value;
	}

	handleChangeAhorroMin(event) {
		this.ahorroMinFilter = event.target.value;
	}

	handleChangeAhorroMax(event) {
		this.ahorroMaxFilter = event.target.value;
	}

	handleChangeFinanciacionMin(event) {
		this.financiacionMinFilter = event.target.value;
	}

	handleChangeFinanciacionMax(event) {
		this.financiacionMaxFilter = event.target.value;
	}

	handleChangeRentabilidadMin(event) {
		this.rentabilidadMinFilter = event.target.value;
	}

	handleChangeRentabilidadMax(event) {
		this.rentabilidadMaxFilter = event.target.value;
	}

	handleChangeExperiencia(event) {
		this.experienciaFilter = event.target.value;
	}

	handleChangeMyBox(event) {
		this.myBoxFilter = event.target.value;
	}

	handleChangePreconMin(event) {
		this.preconMinFilter = event.target.value;
	}

	handleChangePreconMax(event) {
		this.preconMaxFilter = event.target.value;
	}

	handleChangeTargetAuto(event) {
		this.targetAutoFilter = event.target.value;
	}

	handleChangeEmployee(event) {
		this.multiSelectionE++;
		this.employeeFilter = event.target.value;
		this.isEmployeeSelectedManually = true;
		this.getOptionsBooks(this.employeeFilter);
		let employeeName = '';
		for (let i = 0;i < this.optionsEmployee.length;i++) {
			if (this.optionsEmployee[i]['value'] === event.target.value) {
				employeeName = this.optionsEmployee[i]['label'];
				//if TODOS selected, remove everyone from selected list
				if (employeeName.includes('TODOS')) {

					this.selectedEmployees = [];
				}
				break;
			}
		}
		let insert = true;
		if (this.selectedEmployees.length > 0) {
			//if TODOS selected, remove TODOS when someone gets added to selected list
			if (this.selectedEmployees[0]['label'].includes('TODOS')) {
				this.selectedEmployees.splice(0, 1); //0 == TODOS
			}
			for (let i = 0; i < this.selectedEmployees.length; i++) {
				if (this.selectedEmployees[i]['label'] === employeeName) {
					insert = false;
					break;
				}
			}
		}
		if (insert && employeeName != '') {
			this.selectedEmployees = []; //si se quita esto la multiseleccion vuelve a funcionar
			this.selectedEmployees.push({label: employeeName, id: event.target.value, bucleId: this.multiSelectionE});
		}

		this.employeesDiv = true;
		this.setButtonVisibility();
	}

	handleChangeBook(event) {
		this.multiSelectionE++;
		this.carteraFilter = event.target.value;
		let bookExternal = '';
		for (let i = 0;i < this.optionsBook.length;i++) {
			if (this.optionsBook[i]['value'] === event.target.value) {
				bookExternal = this.optionsBook[i]['label'];
				//if TODOS selected, remove everyone from selected list
				if (bookExternal.includes('TODOS')) {
					this.selectedBooks = [];
				}
				break;
			}
		}
		let insert = true;
		if (this.selectedBooks.length > 0) {
			//if TODOS selected, remove TODOS when someone gets added to selected list
			if (this.selectedBooks[0]['label'].includes('TODOS')) {
				this.selectedBooks.splice(0, 1); //0 == TODOS
			}
			for (let i = 0; i < this.selectedBooks.length; i++) {
				if (this.selectedBooks[i]['label'] === bookExternal) {
					insert = false;
					break;
				}
			}
		}
		if (insert && bookExternal != '') {
			this.selectedBooks = []; //si se quita esto la multiseleccion vuelve a funcionar
			this.selectedBooks.push({label: bookExternal, id: event.target.value, bucleId: this.multiSelectionE});
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
	}

	//Capture the event fired from the paginator component
	handlePaginatorChange(event) {
		this.recordsToDisplay = event.detail;
	}

	resetFilters() {

		const lookup5 = this.template.querySelector('[data-id="clookup5"]');
		if (lookup5 != null || typeof lookup5 != 'undefined') {
			lookup5.handleClearSelection();
		}

		this.template.querySelectorAll('lightning-input').forEach(each => {
			each.value = '';
		});
		this.template.querySelectorAll('lightning-combobox').forEach(each => {
			each.value = '';
		});
		this.negocioFilter = null;
    	this.carteraFilter = null;
    	this.modeloFilter = null;
    	this.edadMinFilter = null;
		this.edadMaxFilter = null;
    	this.ingresosMinFilter = null;
		this.ingresosMaxFilter = null;
    	this.ahorroMinFilter = null;
		this.ahorroMaxFilter = null;
    	this.financiacionMinFilter = null;
		this.financiacionMaxFilter = null;
    	this.rentabilidadMinFilter = null;
		this.rentabilidadMaxFilter = null;
		this.preconMinFilter = null;
		this.preconMaxFilter = null;
    	this.experienciaFilter = null;
		this.employeeFilter = null;
		this.myBoxFilter = null;
		this.preconceivedFilter = null;
		this.targetAutoFilter = null;
		this.selectedEmployees = [];
		this.numOficinaEmpresa = null;
		this.employeMultiFilter = [];
		this.setButtonVisibility();
	}

	toggleShow() {
		if (this.showDetail === true) {
			this.showDetail = false;
		} else {
			this.showDetail = true;
		}
	}

	getSelectedName(event) {
		const selectedRows = event.detail.selectedRows;
		//Display that fieldName of the selected rows
		this.selectedItems = selectedRows.length;
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
		if (this.page < this.totalPage && this.page !== this.totalPage) {
			this.page = this.page + 1; //increase page by 1
			if (this.page * 100 > this.data.length) {
				this.setMultiSelectors();
				this.getDataList(this.numOficinaEmpresa, this.negocioFilter, this.employeeFilter, this.carteraFilter, this.modeloFilter, this.edadMinFilter, this.edadMaxFilter, this.ingresosMinFilter, this.ingresosMaxFilter, this.ahorroMinFilter, this.ahorroMaxFilter, this.financiacionMinFilter, this.financiacionMaxFilter, this.rentabilidadMinFilter, this.rentabilidadMaxFilter, this.experienciaFilter, this.myBoxFilter, this.preconMinFilter, this.preconMaxFilter, this.targetAutoFilter, this.page);
				this.toggleSpinner();
			}
			this.toggleSpinner();
			this.displayRecordPerPage(this.page);
			this.toggleSpinner();
		}
	}

	//this method displays records page by page
	displayRecordPerPage(page) {
		this.startingRecord = (page - 1) * this.pageSize ;
		this.endingRecord = this.pageSize * page;
		this.endingRecord = this.endingRecord > this.totalNumberOfRecords
			? this.totalNumberOfRecords : this.endingRecord;
		this.items = this.data.slice(this.startingRecord, this.endingRecord);
		this.startingRecord = this.startingRecord + 1;
	}


	sortBy(field, reverse, primer) {

		if (field == 'edad' || field == 'ingresos' || field == 'ahorro' || field == 'financiacion' || field == 'rentabilidad' ||  field == 'preconceived') {

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
				let result;
				if (a == null) {
					result = 1;
				} else if (b == null) {
					result = -1;
				} else {
					result = reverse * ((a  > b) - (b  > a));
				}
				return result;
			};
		} else {

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
				let result;
				if (a == null) {
					result = 1;
				} else if (b == null) {
					result = -1;
				} else {
					result = reverse * ((a.toLowerCase()  > b.toLowerCase()) - (b.toLowerCase()  > a.toLowerCase()));
				}
				return result;
			};
		}
	}

	onHandleSort(event) {
		const {fieldName: sortedBy, sortDirection} = event.detail;
		const cloneData = [...this.items];
		const sortFieldName = this.columns.find(field=>sortedBy === field.fieldName).sortBy;
		cloneData.sort(this.sortBy(sortFieldName, sortDirection === 'asc' ? 1 : -1));
		this.items = cloneData;
		this.sortDirection = sortDirection;
		this.sortedBy = sortedBy;
	}

	setButtonVisibility() {
		if (this.employeeFilter != null && this.negocioFilter != null && this.numOficinaEmpresa != null) {
			this.buttonDisabled = false;
			this.seeFiltersLabel = 'Ver más filtros';
		} else {
			this.buttonDisabled = true;
		}
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

}