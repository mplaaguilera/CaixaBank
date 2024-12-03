import { LightningElement, track, wire, api } from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';
import { loadScript } from 'lightning/platformResourceLoader';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { IsConsoleNavigation, getFocusedTabInfo, setTabIcon, setTabLabel } from 'lightning/platformWorkspaceApi';
import { NavigationMixin } from 'lightning/navigation';
import { CurrentPageReference } from 'lightning/navigation';




import chartjs from '@salesforce/resourceUrl/AV_ChartJsV391';
import charttreemapjs from '@salesforce/resourceUrl/AV_ChartTreeMap';


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
import errorProdRellenoConFiltroTodos from '@salesforce/label/c.CIBE_ErrorProdRellenoConFiltroTodos';
import cliente from '@salesforce/label/c.CIBE_Cliente';
import oportunidad from '@salesforce/label/c.CIBE_Oportunidad';
import importe from '@salesforce/label/c.CIBE_Importe';
import origen from '@salesforce/label/c.CIBE_Origen';
import participe from '@salesforce/label/c.CIBE_Participe';
import fCierre from '@salesforce/label/c.CIBE_FechaCierre';
import oficina from '@salesforce/label/c.CIBE_MiOficinaT';
import otraOficina from '@salesforce/label/c.CIBE_OtraOficina';
import iniciativaEmpleado from '@salesforce/label/c.CIBE_IniciativaEmpleado';
import todos from '@salesforce/label/c.CIBE_Todos';
import accionComercial from '@salesforce/label/c.CIBE_AccionComercial';
import sugerencia from '@salesforce/label/c.CIBE_Sugerencia';
import alertaComercial from '@salesforce/label/c.CIBE_Alerta_Comercial';
import potencial from '@salesforce/label/c.CIBE_Potencial';
import enCurso from '@salesforce/label/c.CIBE_EnCurso';
import pendienteFirma from '@salesforce/label/c.CIBE_PendienteFirma';
import cerradaNegativa from '@salesforce/label/c.CIBE_CerradaNegativa';
import cerradaPositiva from '@salesforce/label/c.CIBE_CerradaPositiva';
import vencida from '@salesforce/label/c.CIBE_Vencida';
import alta from '@salesforce/label/c.CIBE_Alta';
import media from '@salesforce/label/c.CIBE_Media';
import baja from '@salesforce/label/c.CIBE_Baja';
import nombreOpp from '@salesforce/label/c.CIBE_NombreOportunidad';
import importeDesde from '@salesforce/label/c.CIBE_ImporteDesde';
import fechaCierreDesde from '@salesforce/label/c.CIBE_FechaCierreDesde';
import fechaCierreHasta from '@salesforce/label/c.CIBE_FechaCierreHasta';
import probabilidadExito from '@salesforce/label/c.CIBE_ProbabilidadExito';
import buscarParticipe from '@salesforce/label/c.CIBE_BuscarParticipante';
import resultados from '@salesforce/label/c.Cibe_resultadosBusqueda';
import pagina from '@salesforce/label/c.CIBE_Pagina';
import de from '@salesforce/label/c.CIBE_of';
import asignar from '@salesforce/label/c.CIBE_AsignarS';
import anterior from '@salesforce/label/c.CIBE_Anterior';
import posterior from '@salesforce/label/c.CIBE_Posterior';
import empleadosSeleccionados from '@salesforce/label/c.CIBE_EmpleadosSeleccionados';
import productosSeleccionados from '@salesforce/label/c.CIBE_ProductoSseleccionados';
import participesSeleccionados from '@salesforce/label/c.CIBE_ParticipeSeleccionados';
import seleccionar from '@salesforce/label/c.CIBE_Seleccionar';
import buscarProductos from '@salesforce/label/c.CIBE_BuscarProductos';

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
import getActions from '@salesforce/apex/CIBE_Oportunidades_Vinculadas_Controller.getActions';

//Apex
import lookupSearchOffice from '@salesforce/apex/CIBE_MassReassignOwnerOpps_Controller.searchOffice';
import lookupSearchProduct from '@salesforce/apex/CIBE_OppSearchEMP_Controller.searchProduct';
import getEmployees from '@salesforce/apex/CIBE_MassReassignOwnerOpps_Controller.getEmployeesEMP';
import getPaises from '@salesforce/apex/CIBE_OppSearchEMP_Controller.getPaises';
import lookupSearchParticipe from '@salesforce/apex/CIBE_OppSearchEMP_Controller.searchParticipe';
import getTipoOperacion from '@salesforce/apex/CIBE_OppSearchEMP_Controller.getTipoOperacion';
import getOpportunities from '@salesforce/apex/CIBE_OppSearchEMP_Controller.getOpportunities';
import getDataToChart from '@salesforce/apex/CIBE_OppSearchEMP_Controller.getDataToChart';
import lookupSearch from '@salesforce/apex/CIBE_MassReassignOwnerOpps_Controller.search';
import assign from '@salesforce/apex/CIBE_MassReassignOwnerOpps_Controller.assign';
import nameContactAssign from '@salesforce/apex/CIBE_MassReassignOwnerOpps_Controller.nameContactAssign';
import getShadow from '@salesforce/apex/CIBE_GruposComerciales_Controller.getShadow';


//records
import USER_ID from '@salesforce/user/Id';
import NAME_FIELD from '@salesforce/schema/User.Name';
import FUNCTION from '@salesforce/schema/User.AV_Funcion__c';
import OFICINA from '@salesforce/schema/User.AV_NumeroOficinaEmpresa__c';

const TAB_ICON = 'utility:animal_and_nature';
const TAB_ICON_ALT_TEXT = 'Animal and Nature';
const TAB_LABEL = 'Awesome Label';
const initialExpandedRows = [10];

export default class Cibe_oppSearchEMP extends NavigationMixin(LightningElement) {

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
		empleadoAsignado,
		errorOcc,
		clienteLab,
		miOficinaLab,
		productoLab,
		participeLab,
		errorProdRellenoConFiltroTodos,
		cliente,
		oportunidad,
		origen,
		importe,
		fCierre,
		participe,
		oficina,
		otraOficina,
		iniciativaEmpleado,
		todos,
		accionComercial,
		sugerencia,
		alertaComercial,
		potencial,
		enCurso,
		pendienteFirma,
		cerradaNegativa,
		cerradaPositiva,
		vencida,
		alta,
		media,
		baja,
		nombreOpp,
		importeDesde,
		fechaCierreDesde,
		fechaCierreHasta,
		probabilidadExito,
		buscarParticipe,
		resultados,
		pagina,
		de,
		asignar,
		anterior,
		posterior,
		empleadosSeleccionados,
		productosSeleccionados,
		participesSeleccionados,
		seleccionar,
		buscarProductos

	}


	@track loadingTable = true;
	@track loading = true;
	@track showChart = true;
	@track showMoreFilters = false;
	initialSelection = [];
	initialSelectionOffice = [];
	@track initialSelectionMO = [];

	errors = [];
	officePlaceholder = 'Buscar oficina...';
	employeeLabel = 'Asignar a:';
	employeePlaceholder = 'Buscar empleado...';
	@track isMultiEntry = false;
	@track isMultiEntry2 = false;
	@track origenFilter = 'all';
	@track statusFilter = 'Activas';
	optionsEmployee = [];
	optionsEmployeeAux = [];
	employeeDefault = USER_ID;
	@track employeeFilter = this.employeeDefault;
	directores = ['DC', 'DT', 'DAN', 'SSCC'];
	@track targetProbabilidad;
	@track targetPaises;
	@track optionPaises = [];
	@track fechaCierreD = null;
	@track fechaCierreH = null;
	@track fechaProximaGestionD = null;
	@track fechaProximaGestionH = null;
	@track isMultiEntry3 = false;
	isAnotherOffice = false;
	selectedOffice = '';
	employeesDiv = true;
	selectedEmployees = [];
	multiSelectionE = 0;
	@track optionTipoOperacion = [];
	@track targetTipoOperacion;
	@track targetAttentionModel;
	esg = false;
	datasetName;
	listOpp;
	listOppTable;
	listOppTable2;
	listOppSearch;
	listOppExpe;
	listOppPro;
	listOppName;
	@track optionsNames = [];
	@track selectedNames = [];
	@track selectedProducts = [];
	@track selectedFamilia = [];
	@track labelsNameData = [];
	@track labelsProData = [];
	datasetExpe;
	@track optionsProducts = [];
	@track optionsFamilia = [];
	@track selectedlabels = [];
	@track pillSelected = true;
	@track filterName = null;
	selectedEstado = [{ label: 'Activas', id: 'Activas' }];
	@track disabledAplicarMoreFilters = true;
	moreFilters;
	filterExpe;
	@track labelFilterExpe = null;
	@track filterProduct = null;
	numOficinaEmpresa = null;
	showSelectedParticipe;
	selectedParticipe = [];
	multiSelectionP = 0;
	showAssignment = true;
	@track isModalOpen = false;
	//@track firstSearch = true;
	numOfficeDefault;
	showSelectedProducts = false;
	selectedProductsFilter = [];
	estadoDiv = true;
	@track selectedRows = [];
	selectedItems;
	contactName;
	@track filterList;
	@track productsExpe = [];
	@track destacadas = true;
	@track pendienteFirma = false;
	@track priorizado = false;
	filters;
	@track gridData = [];
	@track disabledAplicar = true;



	//flow
	actionSetting = 'CIBE_New_Opportunity';
	@track flowlabel;
	@track flowName;
	@track flowOutput;
	@track redirectId;
	@track objectAPIName;
	@track isShowFlowAction = false;



	//paginacion
	@track limit = '50';
	@track total = 0;
	@track page = 1;
	@track data;
	@track totalPage = 0;
	@track endingRecord = 0;
	@track startingRecord = 1;


	//paginacion 2
	@track pageNumber = 0;
	@track totalPages = 0;
	@track pageData = [];

	@track pageNumber2 = 0;
	@track totalPages2 = 0;
	@track pageData2 = [];

	//order
	@track orderingCriterion = 'ASC';
	orderBy = 'CIBE_GrupoComercial__r.CIBE_GrupoComercial__c';

	@track onClickFam = false;

	@wire(getRecord, { recordId: USER_ID, fields: [NAME_FIELD, FUNCTION, OFICINA] })
	wiredUser({ error, data }) {
		if (data) {

			this.empleName = data.fields.Name.value;
			this.selectedEmployees = [{ label: this.empleName, id: USER_ID, bucleId: this.multiSelectionE }];
			this.empleFuncion = data.fields.AV_Funcion__c.value;
			this.empleOfi = data.fields.AV_NumeroOficinaEmpresa__c.value === null ? '' : data.fields.AV_NumeroOficinaEmpresa__c.value;
			this.numOficinaEmpresa = this.empleOfi.split('-')[1];
			this.numOfficeDefault = this.empleOfi.split('-')[1];
			this.isDirector = this.directores.includes(this.empleFuncion);


			this.getOptionsOffice();

			this.moreFilters = {
				oficina: this.numOficinaEmpresa,
				employee: this.selectedEmployees,
				origen: 'all',
				stage: this.selectedEstado,
				esg: this.esg
			};
			this.filters = {
				isDestacada: this.destacadas,
				isPendienteFirma: this.pendienteFirma,
				isPrio: this.priorizado,
				orderBy: this.orderBy,
				orderingCriterion: this.orderingCriterion
			};

			this.getOpp();

		} else if (error) {
			console.log(error)
		}
	}

	getOptionsOffice() {
		lookupSearchOffice({ searchTerm: this.empleOfi.substring(4), selectedIds: null })
			.then(result => {
				this.template.querySelector('[data-id="clookup5"]')?.setSearchResults(result);
				this.template.querySelector('[data-id="clookup5"]')?.scrollIntoView();
				this.employeeOffice = result[0].id;
				this.numOficinaEmpresa = this.empleOfi.substring(4);
				this.initialSelectionOffice = [{ id: result[0].id, icon: result[0].icon, title: result[0].title }];
				this.selectedOffice = this.selectedOffice === '' ? this.empleOfi.substring(4) : this.selectedOffice;
				this.getOptionsEmployee(this.empleOfi.substring(4));
				//this.setVisibilityOptions();
			}).catch(error => {
				console.log(error);
			})
	}

	getOptionsEmployee(data) {
		getEmployees({ officeFilterData: data })
			.then(result => {
				if (result != null && result.length > 0) {
					this.optionsEmployee = result;
				}
			}).catch(error => {
				console.log(error);
			})
	}


	handleHideChart() {
		this.showChart = !this.showChart;
		if (!this.showChart) {
			this.template.querySelector('[data-id="showChart"]').classList.add('invisible');
		} else {
			this.template.querySelector('[data-id="showChart"]').classList.remove('invisible');
			this.template.querySelector('[data-id="borderProduct"]').style.height = '';
			this.template.querySelector('[data-id="borderName"]').style.height = '';
			this.template.querySelector('[data-id="borderExp"]').style.height = '';
			this.getCharts();
		}
	}

	showFiltersClick() {
		this.showMoreFilters = !this.showMoreFilters;
	}

	//Oficina
	handleSearchOffice(event) {
		lookupSearchOffice(event.detail)
			.then((results) => {
				this.template.querySelector('[data-id="clookup5"]').setSearchResults(results);
				this.template.querySelector('[data-id="clookup5"]').scrollIntoView();
			})
			.catch((error) => {
				this.notifyUser('Lookup Error', this.labels.errorOcc + '.', 'error');
				console.error('Lookup error', JSON.stringify(error));
				this.errors = [error];
			});
	}

	@track producto;
	handleSelectionChange(event) {
		this.disabledAplicarMoreFilters = false;
		let targetId = event.target.dataset.id;

		if (targetId === 'clookup3') {
			const selection = this.template.querySelector(`[data-id="${targetId}"]`).getSelection();
			let selectedIds = [];
			if (selection.length !== 0) {
				this.selectedProductsFilter.forEach(prod => {
					selectedIds.push(prod.id);
				});
				for (let sel of selection) {
					if (!selectedIds.includes(sel.id)) {
						this.selectedProductsFilter.push({ label: String(sel.title), id: String(sel.id), bucleId: this.multiSelectionS });
					}
				}
				if (this.selectedProductsFilter.length > 0) {
					this.showSelectedProducts = true;
				} else {
					this.showSelectedProducts = false;
				}
			}
			this.initialSelection = [];
		} else if (targetId === 'clookupPar') {
			const selection = this.template.querySelector(`[data-id="${targetId}"]`).getSelection();
			let selectidPa = [];
			if (selection.length !== 0) {
				this.selectedParticipe.forEach(parti => {
					selectidPa.push(parti.title);
				});
				for (let selp of selection) {
					if (!selectidPa.includes(selp.title)) {
						this.filterPartiipe = String(selp.title);
						this.multiSelectionP++;
						this.selectedParticipe.push({ label: this.filterPartiipe, id: selp.subtitle, bucleId: this.multiSelectionP });
						this.selectIdPar.push(selp.subtitle);
					}
				}
				if (this.selectedParticipe.length > 0) {
					this.showSelectedParticipe = true;
				} else {
					this.showSelectedParticipe = false;
				}
			} else {
				this.filterParticipe = null;
			}
			this.initialSelection = [];
		} else if (targetId === 'clookup5') {
			this.isAnotherOffice = false;
			const selection = this.template.querySelector(`[data-id="${targetId}"]`).getSelection();
			if (selection.length !== 0) {
				for (let sel of selection) {
					this.numOficinaEmpresa = sel.title.substring(0, 5);
				}
				this.getOptionsEmployee(this.numOficinaEmpresa);
				this.disabledAplicarMoreFilters = !this.viewMoreFilter();
			} else {
				this.numOficinaEmpresa = null;
				this.disabledAplicarMoreFilters = !this.viewMoreFilter();
			}
		}

		if (targetId === 'clookupMO' || targetId === 'clookupAssig') {
			this.checkForErrors(targetId);
		}
	}

	checkForErrors(targ) {
		this.errors = [];
		if (targ === 'clookupMO') {
			targ = 'lookupMO';
		} else if (targ === 'clookupAssig') {
			targ = 'lookupAssig';
		}
		if (targ === 'lookupMO' || targ === 'lookupAssig') {
			const selection = this.template.querySelector(`[data-id="${targ}"]> c-av_-lookup`).getSelection();
			if (selection.length !== 0) {
				for (let sel of selection) {
					this.filterList = String(sel.id);
				}
				this.contactNameA(this.filterList);
			} else {
				this.filterList = null;
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

	setButtonVisibility() {
		if (((this.employeeFilter === null || typeof this.employeeFilter === 'undefined') ||
			(this.statusFilter === null || typeof this.statusFilter === 'undefined'))) {
			// ||
			// ((this.origenFilter === 'CIBE_IniciativaEmpleadoEMP') &&
			// (!this.showSelectedProducts || this.selectedEmployees === null || this.selectedEmployees.length === 0))) {

			//this.filterProduct === null || typeof this.filterProduct === 'undefined' 
			this.buttonDisabled = true;
			this.isOriginAll = false;
		} else if (this.origenFilter == 'CIBE_IniciativaEmpleadoEMP,CIBE_AccionComercialEMP,CIBE_SugerenciaEMP,CIBE_AlertaComercialEMP' && this.selectedProducts.length === 0) {
			this.buttonDisabled = true;
			this.isOriginAll = true;
		} else {
			this.buttonDisabled = false;
			this.isOriginAll = false;
		}
	}

	get optionsOppoOrigen() {
		return [
			{ label: this.labels.todos, value: 'all' },
			{ label: this.labels.iniciativaEmpleado, value: 'CIBE_IniciativaEmpleadoEMP' },
			{ label: this.labels.accionComercial, value: 'CIBE_AccionComercialEMP' },
			{ label: this.labels.sugerencia, value: 'CIBE_SugerenciaEMP' },
			{ label: this.labels.alertaComercial, value: 'CIBE_AlertaComercialEMP' }
		];
	}

	get optionsOppModeloAtencion() {
		return [
			{ label: 'Cliente de alto valor', value: '1' },
			{ label: 'Cliente a potenciar', value: '2' },
			{ label: 'Cliente a mantener', value: '3' },
			{ label: '', value: 'vacio' }
		];
	}

	handleChangeOrigen(event) {
		this.origenFilter = event.target.value;
		this.disabledAplicarMoreFilters = false;
		this.setButtonVisibility();
	}

	handleAnotherOffice(event) {
		this.disabledAplicarMoreFilters = true;
		this.selectedOffice = this.numOficinaEmpresa;
		// Check if office, product and stagename exist for the query to run faster
		if (this.selectedOffice != null) {
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
				const evt = new Object({ 'target': { 'value': this.employeeFilter } });
				this.handleChangeEmployee(evt);
			}
		} else {
			const el = this.template.querySelector('.another-office');
			el.checked = false;
			this.isAnotherOffice = false;
			const evt = new ShowToastEvent({
				title: 'Filtro incorrecto',
				message: 'El campo oficina debe estar informado.',
				variant: 'info',
				mode: 'dismissable'
			});
			this.dispatchEvent(evt);
		}
	}

	get optionsOppoStatus() {
		return [
			{ label: this.labels.potencial, value: 'Potencial' },
			{ label: this.labels.enCurso, value: 'En curso' },
			{ label: this.labels.pendienteFirma, value: 'Pendiente de firma' },
			{ label: this.labels.cerradaNegativa, value: 'Cerrada negativa' },
			{ label: this.labels.cerradaPositiva, value: 'Cerrada positiva' },
			{ label: this.labels.vencida, value: 'Vencida' },
			{ label: 'Activas', value: 'Activas' }

		];
	}


	handleChangeEstado(event) {
		this.multiSelectionS++;
		var statusName = '';
		this.estadoDiv = true;
		for (let i = 0; i < this.optionsOppoStatus.length; i++) {
			if (this.optionsOppoStatus[i]['value'] === event.target.value) {
				statusName = this.optionsOppoStatus[i]['label'];
				break;
			}
		}
		let insert = true;
		if (this.selectedEstado.length > 0) {
			for (let i = 0; i < this.selectedEstado.length; i++) {
				if (this.selectedEstado[i]['id'] === event.target.value) {
					insert = false;
					break;
				}
			}
		}
		if (insert && event.target.value != '') {
			this.statusFilter = event.target.value;
			this.selectedEstado.push({ label: statusName, id: event.target.value, bucleId: this.multiSelectionS });
		}
		if (event.target.value != '') {
			this.estadoDiv = true;
		}
		this.disabledAplicarMoreFilters = false;
	}





	//Producto
	handleSearchProduct(event) {
		lookupSearchProduct(event.detail)
			.then((results) => {
				this.template.querySelector('[data-id="clookup3"]').setSearchResults(results);
				this.template.querySelector('[data-id="clookup3"]').scrollIntoView();
			})
			.catch((error) => {
				this.notifyUser('Lookup Error', labels.errorOcc + labels.productoLab + '.', 'error');
				console.error('Lookup error', JSON.stringify(error));
				this.errors = [error];
			});

	}

	handleChangeEmployee(event) {
		this.multiSelectionE++;
		this.employeeFilter = event.target.value;
		let employeeName = '';
		var todosArr = new Array();
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
		if (insert && employeeName !== '') {
			this.selectedEmployees.push({ label: employeeName, id: event.target.value, bucleId: this.multiSelectionE });
		}
		this.employeesDiv = true;
		this.disabledAplicarMoreFilters = false;

	}

	get optionsProbabilidad() {
		return [
			{ label: this.labels.alta, value: 'Alta' },
			{ label: this.labels.media, value: 'Media' },
			{ label: this.labels.baja, value: 'Baja' },
			{ label: '', value: 'vacio' }
		];
	}

	handleChangeProbabilidad(event) {
		this.targetProbabilidad = event.target.value;
		this.disabledAplicarMoreFilters = false;
	}

	@wire(getPaises)
	wiredPaises({ error, data }) {
		if (data) {
			this.optionPaises = data;
		}
		if (error) { 
			console.log('wiredPaises:', error); 
		}
	}

	handleChangePaises(event) {
		this.targetPaises = event.target.value;
		this.disabledAplicarMoreFilters = false;
	}

	handleChangeFechaCierreD(event) {
		this.fechaCierreD = event.target.value;
		this.disabledAplicarMoreFilters = false;
	}

	handleChangeFechaCierreH(event) {
		this.fechaCierreH = event.target.value;
		this.disabledAplicarMoreFilters = false;
	}

	handleChangeProximaGestionD(event) {
		this.fechaProximaGestionD = event.target.value;
		this.disabledAplicarMoreFilters = false;
	}

	handleChangeProximaGestionH(event) {
		this.fechaProximaGestionH = event.target.value;
		this.disabledAplicarMoreFilters = false;
	}

	@track selectIdPar = [];
	//Participe
	handleSearchParticipe(event) {
		let escribo = event.detail.searchTerm;
		lookupSearchParticipe({ searchTerm: escribo, selectedIds: this.selectIdPar, numOficina: this.numOficinaEmpresa })
			.then((results) => {
				this.template.querySelector('[data-id="clookupPar"]').setSearchResults(results);
				this.template.querySelector('[data-id="clookupPar"]').scrollIntoView();
			})
			.catch((error) => {
				this.notifyUser('Lookup Error', labels.errorOcc + labels.participeLab + '.', 'error');
				console.error('Lookup error', JSON.stringify(error));
				this.errors = [error];
			});
	}


	@wire(getTipoOperacion)
	wiredTipoOperacion({ error, data }) {
		if (data) {
			this.optionTipoOperacion = data;
		} 
		if (error) { 
			console.log('wiredTipoOperacion:', error); 
		}
	}


	handleChangeTipoOperacion(event) {
		this.targetTipoOperacion = event.target.value;
		this.disabledAplicarMoreFilters = false;
	}



	handleAttentionModel(event) {
		this.targetAttentionModel = event.target.value;
		this.disabledAplicarMoreFilters = false;
	}

	handleESG(event) {
		this.esg = event.detail.checked;
		this.disabledAplicarMoreFilters = false;
	}

	handleQuitarFiltros() {
		// this.loading = true;
		// this.loadingTable = true;
		this.employeeFilter = this.employeeDefault;
		this.esg = false;
		this.targetAttentionModel = null;
		this.targetTipoOperacion = null;
		this.targetPaises = null;
		this.targetProbabilidad = null;
		this.statusFilter = null;
		this.origenFilter = 'all';
		this.fechaCierreD = null;
		this.fechaCierreH = null;
		this.fechaProximaGestionD = null;
		this.fechaProximaGestionH = null;
		this.isAnotherOffice = false;
		this.optionsEmployee = this.optionsEmployeeAux;

		this.showMoreFilters = false;

		this.selectedProducts = [];
		this.selectIdPar = [];
		this.selectedlabels = [];
		this.labelsProduct = [];
		if (this.template.querySelector('[data-id="searchProductMulti"]') != null) {
			this.template.querySelector('[data-id="searchProductMulti"]').refreshAll();
		}

		this.selectedNames = [];
		if (this.template.querySelector('[data-id="searchNameMulti"]') != null) {
			this.template.querySelector('[data-id="searchNameMulti"]').refreshAll();
		}

		this.selectedFamilia = [];
		if (this.template.querySelector('[data-id="searchFamiliaMulti"]') != null) {
			this.template.querySelector('[data-id="searchFamiliaMulti"]').refreshAll();
		}

		if (this.template.querySelector('[data-id="borderProduct"]') != null) {
			this.template.querySelector('[data-id="borderProduct"]').style.height = '';
		}
		if (this.template.querySelector('[data-id="borderName"]') != null) {
			this.template.querySelector('[data-id="borderName"]').style.height = '';
		}
		if (this.template.querySelector('[data-id="borderExp"]') != null) {
			this.template.querySelector('[data-id="borderExp"]').style.height = '';
		}

		this.filterExpe = null;
		this.labelFilterExpe = null;
		this.filterName = null;
		this.selectedNames = [];
		this.filterProduct = null;

		this.numOficinaEmpresa = this.numOfficeDefault;
		this.getOptionsEmployee(this.numOficinaEmpresa);

		this.selectedParticipe = [];
		this.selectedProductsFilter = [];
		this.selectedEstado = [];
		this.estadoDiv = true;
		this.showSelectedProducts = false;
		this.showSelectedParticipe = false;
		this.selectedEmployees = [];
		this.selectedEmployees = [{ label: this.empleName, id: USER_ID, bucleId: this.multiSelectionE }];
		this.selectedEstado = [{ label: 'Activas', id: 'Activas' }];

		this.destacadas = true;
		this.pendienteFirma = false;
		this.priorizado = false;
		this.orderBy = 'CIBE_GrupoComercial__c';

		this.filters = {
			isDestacada: this.destacadas,
			isPendienteFirma: this.pendienteFirma,
			isPrio: this.priorizado,
			orderBy: this.orderBy,
			orderingCriterion: this.orderingCriterion
		};



		this.moreFilters = {
			oficina: this.numOficinaEmpresa,
			employee: this.selectedEmployees,
			origen: 'all',
			stage: this.selectedEstado,
			esg: this.esg
		};








		this.resetTablePag();
		this.getOpp();

	}

	@track dataOpp;


	@track prueba = [];
	@track expandedTreeGRows = [];

	get currentExpandedStr() {
		return this.expandedTreeGRows;
	}

	@track columns = [
		{ label: ' ', fieldName: 'destacada', type: 'button-icon', initialWidth: 50, typeAttributes: { disabled: true, iconName: { fieldName: 'destacadaIcon' }, alternativeText: 'Destacada', variant: 'bare-inverse', iconClass: { fieldName: 'iconClass' } }, hideDefaultActions: true },
		{ type: 'button', typeAttributes: { iconName: 'utility:event', class: 'slds-size_small', variant: 'base', name: 'createEvent' }, initialWidth: 40, },
		{ label: 'Grupo comercial', fieldName: 'grupoComercialId', type: 'url', initialWidth: 200, typeAttributes: { label: { fieldName: 'grupoComercial' }, tooltip: { fieldName: 'grupoComercial' } }, hideDefaultActions: true },
		{ label: 'Cliente', fieldName: 'clienteId', type: 'url', initialWidth: 200, typeAttributes: { label: { fieldName: 'cliente' }, tooltip: { fieldName: 'cliente' } }, hideDefaultActions: true },
		{ label: 'Origen', fieldName: 'origen', type: 'text', initialWidth: 140 },
		{ label: 'Etapa', fieldName: 'estado', type: 'text', initialWidth: 120 },
		{ label: 'Nombre Oportunidad', fieldName: 'oppId', type: 'url', initialWidth: 200, typeAttributes: { label: { fieldName: 'nombre' }, tooltip: { fieldName: 'nombre' } }, hideDefaultActions: true },
		{ label: 'Producto', fieldName: 'producto', type: 'text', initialWidth: 170 },
		{ label: 'Importe', fieldName: 'importe', initialWidth: 100, cellAttributes: { alignment: 'right' } },
		{ label: 'Divisa', fieldName: 'divisa', initialWidth: 80 },
		{ label: 'Financiación sostenible', fieldName: 'esg', initialWidth: 160, type: 'boolean', cellAttributes: { alignment: 'center' } },
		{ label: 'Probabilidad éxito', fieldName: 'probabilidad', initialWidth: 160 },
		{ label: 'Fecha última gestión', fieldName: 'fechaUltimaG', initialWidth: 170, cellAttributes: { alignment: 'right' } },
		{ label: 'Próxima gestión', fieldName: 'fechaProxG', initialWidth: 140, cellAttributes: { alignment: 'right' } },
		{ label: 'Fecha cierre', fieldName: 'fechaCie', initialWidth: 130, cellAttributes: { alignment: 'right' } },
		{ label: 'Fecha último contacto con el cliente', fieldName: 'fechaUltContactCliente', initialWidth: 260, type: 'date', typeAttributes: { day: "2-digit", month: "2-digit", year: "numeric" }, cellAttributes: { alignment: 'right' } },
		{ label: 'Fecha próxima cita', fieldName: 'fechaproxCi', initialWidth: 170, cellAttributes: { alignment: 'right' } },
		{ label: 'Propietario', fieldName: 'propietarioId', type: 'url', initialWidth: 140, typeAttributes: { label: { fieldName: 'propietario' }, tooltip: { fieldName: 'propietario' } }, hideDefaultActions: true },
		{ label: 'Comentario', fieldName: 'comentario', initialWidth: 300 }

	];

	@track columns2 = [
		{ label: 'Nombre', fieldName: 'clienteId', type: 'url', initialWidth: 300, typeAttributes: { label: { fieldName: 'cliente' }, tooltip: { fieldName: 'cliente' } }, hideDefaultActions: true },
		{ label: 'Origen', fieldName: 'origen', type: 'text', initialWidth: 140 },
		{ label: 'Etapa', fieldName: 'estado', type: 'text', initialWidth: 120 },
		{ label: 'Producto', fieldName: 'producto', type: 'text', initialWidth: 170 },
		{ label: 'Importe', fieldName: 'importe', initialWidth: 100, cellAttributes: { alignment: 'right' } },
		{ label: 'Divisa', fieldName: 'divisa', initialWidth: 80 },
		{ label: 'Financiación sostenible', fieldName: 'esg', initialWidth: 160, type: 'boolean', cellAttributes: { alignment: 'center' } },
		{ label: 'Probabilidad éxito', fieldName: 'probabilidad', initialWidth: 160 },
		{ label: 'Fecha última gestión', fieldName: 'fechaUltimaG', initialWidth: 170, cellAttributes: { alignment: 'right' } },
		{ label: 'Próxima gestión', fieldName: 'fechaProxG', initialWidth: 140, cellAttributes: { alignment: 'right' } },
		{ label: 'Fecha cierre', fieldName: 'fechaCie', initialWidth: 130, cellAttributes: { alignment: 'right' } },
		{ label: 'Fecha último contacto con el cliente', fieldName: 'fechaUltContactCliente', initialWidth: 260, type: 'date', typeAttributes: { day: "2-digit", month: "2-digit", year: "numeric" }, cellAttributes: { alignment: 'right' } },
		{ label: 'Fecha próxima cita', fieldName: 'fechaproxCi', initialWidth: 170, cellAttributes: { alignment: 'right' } },
		{ label: 'Propietario', fieldName: 'propietarioId', type: 'url', initialWidth: 140, typeAttributes: { label: { fieldName: 'propietario' }, tooltip: { fieldName: 'propietario' } }, hideDefaultActions: true },
		{ label: 'Comentario', fieldName: 'comentario', initialWidth: 300 }

	];

	@track expanded;

	getOpp() {
		this.loading = true;
		this.loadingTable = true;
		getOpportunities({ datosString: JSON.stringify(this.filters), filterExpeString: JSON.stringify(this.filterExpe), productName: this.filterProduct, listProducts: this.selectedProducts, filterName: this.selectedNames, page: this.page, destacadas: this.destacadas, moreFiltersString: JSON.stringify(this.moreFilters) })
			.then(result => {
				this.expandedTreeGRows = [];
				this.loading = false;
				let chidrenOpp = [];
				let arr = [];

				for (let key in result.grupo) {
					let random = Math.floor(Math.random() * 140);
					arr.push({ id: '' + random + '', clienteId: result.grupo[key].grupoComercialId, cliente: result.grupo[key].grupoComercial, children: result.grupo[key].children });
				}





				for (let index = 0; index < arr.length; index++) {
					if (!this.expandedTreeGRows.includes(arr[index].id)) {
						this.expandedTreeGRows.push(arr[index].id);
					}
					let related = arr[index]['children'];
					if (related) {
						arr[index]._children = arr[index].children;
						delete arr[index].children;
					}


					for (let i = 0; i < arr[index]._children.length; i++) {
						if (!this.expandedTreeGRows.includes(arr[index]._children[i].id)) {
							this.expandedTreeGRows.push(arr[index]._children[i].id);
						}
						let related2 = arr[index]._children[i]['children'];
						if (related2) {
							arr[index]._children[i]._children = arr[index]._children[i].children;

							arr[index]._children[i]._children.forEach(element => {
								element.clienteId = element.oppId;
								element.cliente = element.nombre
							});

							delete arr[index]._children[i].children;
						}
					}
				}


				this.gridData = arr;

				if (this.template.querySelector('[data-id="borderProduct"]') != null) {
					var height = this.template.querySelector('[data-id="borderProduct"]').offsetHeight;
					if (height < this.template.querySelector('[data-id="borderName"]').offsetHeight) {
						height = this.template.querySelector('[data-id="borderName"]').offsetHeight;
					}
				}
				if (result != null) {
					var today = new Date();
					this.updatedData = this.setNumber(today.getDate()) + '/' + this.setNumber(today.getMonth() + 1) + '/' + today.getFullYear() + ' ' + this.setNumber(today.getHours()) + ':' + this.setNumber(today.getMinutes());
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
							optionsProductsWithOutOrder.set(this.listOppPro[i].producto, { label: this.listOppPro[i].producto, value: this.listOppPro[i].productoId, selected: true });
						} else if (this.listOppPro[i].producto != null && this.listOppPro[i].productoId != null && !listAdded.includes(this.listOppPro[i].productoId)) {
							listAdded.push(this.listOppPro[i].productoId);
							optionsProductsWithOutOrder.set(this.listOppPro[i].producto, { label: this.listOppPro[i].producto, value: this.listOppPro[i].productoId, selected: false });
						}
						if (dataProducts.get(this.listOppPro[i].producto) != null) {
							dataProducts.set(this.listOppPro[i].producto, dataProducts.get(this.listOppPro[i].producto) + 1);
						} else {
							dataProducts.set(this.listOppPro[i].producto, 1);
						}
					}
					for (var i = 0; i < this.listOppName.length; i++) {
						if (this.listOppName[i].nombre != null && !listAddedName.includes(this.listOppName[i].nombre) && this.selectedNames != null && this.selectedNames.includes(this.listOppName[i].nombre)) {
							listAddedName.push(this.listOppName[i].nombre);
							optionsNamesWithOutOrder.set(this.listOppName[i].nombre, { label: this.listOppName[i].nombre, value: this.listOppName[i].nombre, selected: true });
						} else if (this.listOppName[i].nombre != null && !listAddedName.includes(this.listOppName[i].nombre)) {
							listAddedName.push(this.listOppName[i].nombre);
							optionsNamesWithOutOrder.set(this.listOppName[i].nombre, { label: this.listOppName[i].nombre, value: this.listOppName[i].nombre, selected: false });
						}
						if (dataName.get(this.listOppName[i].nombre) != null) {
							dataName.set(this.listOppName[i].nombre, dataName.get(this.listOppName[i].nombre) + 1);
						} else {
							dataName.set(this.listOppName[i].nombre, 1);
						}
					}
					var mapArraName = Array.from(dataName).sort((a, b) => b[1] - a[1]);
					var mapName = new Map(mapArraName);
					var iterName = mapName.keys();
					for (var k = 0; k < optionsNamesWithOutOrder.size; k++) {
						var name = iterName.next().value;
						if (optionsNamesWithOutOrder.get(name) != null) {
							this.optionsNames.push(optionsNamesWithOutOrder.get(name));
						}
					}
					var mapArraPro = Array.from(dataProducts).sort((a, b) => b[1] - a[1]);
					var mapPro = new Map(mapArraPro);
					var iterPro = mapPro.keys();
					for (var q = 0; q < optionsProductsWithOutOrder.size; q++) {
						var pro = iterPro.next().value;
						if (optionsProductsWithOutOrder.get(pro) != null) {
							this.optionsProducts.push(optionsProductsWithOutOrder.get(pro));
						}
					}

					this.listOppTable = result.listOpp;
					this.listOppTable2 = result.grupo;
					this.showAll = true;
					this.loadingTable = false;

					if (result.totalSize != -1) {
						this.total = result.totalSize;
					}

					this.pageNumber = 0;
					this.totalPages = this.listOppTable.length > 0 ? (Math.ceil(this.listOppTable.length / parseInt(this.limit, 0)) - 1) : 0;
					this.updatePage();

					this.pageNumber2 = 0;
					this.totalPages2 = this.gridData.length > 0 ? (Math.ceil(this.gridData.length / parseInt(this.limit, 0)) - 1) : 0;
					this.updatePage2();

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
				dataName.set(this.listOppName[l].nombre, dataName.get(this.listOppName[l].nombre) + 1);
			} else {
				dataName.set(this.listOppName[l].nombre, 1);
			}
			if (!labelsName.includes(this.listOppName[l].nombre)) {
				labelsName.push(this.listOppName[l].nombre);
			}
		}
		for (var l = 0; l < this.listOppPro.length; l++) {
			if (dataProducts.get(this.listOppPro[l].producto) != null) {
				dataProducts.set(this.listOppPro[l].producto, dataProducts.get(this.listOppPro[l].producto) + 1);
			} else {
				dataProducts.set(this.listOppPro[l].producto, 1);
			}
			if (!labelsProduct.includes(this.listOppPro[l].producto)) {
				labelsProduct.push(this.listOppPro[l].producto);
			}
			this.labelsProductId.set(this.listOppPro[l].producto, this.listOppPro[l].productoId);
		}
		var mapArraName = Array.from(dataName).sort((a, b) => b[1] - a[1]);
		var mapName = new Map(mapArraName);
		this.labelsNameData = [];
		var iterName = mapName.keys();
		for (var k = 0; k < labelsName.length; k++) {
			var name = iterName.next().value;
			this.labelsNameData.push(name);
			listNameNor.push(mapName.get(name));
		}
		var mapArraPro = Array.from(dataProducts).sort((a, b) => b[1] - a[1]);
		var mapPro = new Map(mapArraPro);
		this.labelsProData = [];
		var iterPro = mapPro.keys();
		for (var q = 0; q < labelsProduct.length; q++) {
			var pro = iterPro.next().value;
			this.labelsProData.push(pro);
			listProductNor.push(mapPro.get(pro));
		}
		this.datasetProduct = {
			datasets: [{
				label: 'Total',
				backgroundColor: (ctx) => this.colorFromRawPro(ctx),
				data: listProductNor,
				barThickness: 16,
				barPercentage: 0.5
			}],
			labels: this.labelsProData
		};
		this.datasetName = {
			datasets: [{
				label: 'Total',
				backgroundColor: (ctx) => this.colorFromRawName(ctx),
				data: listNameNor,
				barThickness: 16,
				barPercentage: 0.5
			}],
			labels: this.labelsNameData
		};
		this.datasetExpe = [{
			label: 'Total',
			backgroundColor: (ctx) => this.colorFromRaw(ctx),
			tree: this.dataset,
			labels: {
				display: true,
				formatter: (ctx) => {
					if ((ctx.raw._data.label.length * 5) + ((ctx.raw._data.label.split(' ').length - 1) * 2) < ctx.raw.w) { //si puede entrar el texto en el cuadrado del mapa
						var numero = ctx.raw._data.value;
						if (numero >= 1400000) {
							numero = numero.toString().substring(0, numero.toString().length - 6) + 'M';
						} else if (numero >= 1400) {
							numero = numero.toString().substring(0, numero.toString().length - 3) + 'K';
						}
						return [ctx.raw._data.label, `(${numero})`];
					}
					return '';
				},
				color: (ctx) => this.colorFontFromRawExp(ctx)
			},
			key: 'value'
		}];
		loadScript(this, (chartjs + '/chart.min.js')).then(() => {
			loadScript(this, (charttreemapjs + '/chartjs-chart-treemap.js')).then(() => {

				//Chart de familia
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
				//this.loading = false;
				this.showSpinnerFirst = false;

				//Chart de producto
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

				//Chart de name
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
			}).catch(error => {
				console.log(error);
				//this.loading = false;
				this.showSpinnerFirst = false;
			});
		}).catch(error => {
			console.log(error);
			//this.loading = false;
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
							if (data >= 1400000) {
								data = data.toString().substring(0, data.toString().length - 6) + 'M';
							} else if (data >= 1400) {
								data = data.toString().substring(0, data.toString().length - 3) + 'K';
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
		if (num == '2') {
			config = {
				type: 'bar',
				data: this.datasetName,
				options: {
					locale: 'es-ES',
					onClick: (event, elements, chart) => {
						// this.loading = true;
						// this.loadingTable = true;
						if (elements[0] != null) {
							if (this.filterName == null || this.filterName != chart.config._config.data.labels[elements[0].index]) {
								this.filterName = chart.config._config.data.labels[elements[0].index];
								this.selectedNames = [this.filterName];
								this.template.querySelector('[data-id="searchNameMulti"]').refreshAll();
								this.template.querySelector('[data-id="searchNameMulti"]').selectedvalues = this.selectedNames;
								this.template.querySelector('[data-id="searchNameMulti"]').refreshOrginalList();
								this.destacadas = false;
								this.filters = {
									isDestacada: false,
									isPendienteFirma: this.pendienteFirma,
									isPrio: this.priorizado,
									orderBy: this.orderBy,
									orderingCriterion: this.orderingCriterion
								};

								this.moreFilters = {
									oficina: this.numOficinaEmpresa,
									employee: this.selectedEmployees,
									origen: 'all',
									stage: this.selectedEstado,
									esg: this.esg
								};
								if (this.orderBy === 'C') {
									this.orderBy = 'O';
									//this.filters.orderBy = 'O';
								}
							} else {
								this.filterName = null;
								this.selectedNames = [];
								this.template.querySelector('[data-id="searchNameMulti"]').refreshAll();
								this.destacadas = false;
								this.filters = {
									isDestacada: false,
									isPendienteFirma: this.pendienteFirma,
									isPrio: this.priorizado,
									orderBy: this.orderBy,
									orderingCriterion: this.orderingCriterion

								};

								this.moreFilters = {
									oficina: this.numOficinaEmpresa,
									employee: this.selectedEmployees,
									origen: 'all',
									stage: this.selectedEstado,
									esg: this.esg
								};
								if (this.orderBy === 'O' && this.selectedProducts.length === 0 && this.filterExpe != null) {
									this.orderBy = 'GC';
									//this.filters.orderBy = 'C';
								}
							}
							this.resetTablePag();
							this.getOpp();
						}
					},
					indexAxis: 'y',
					cutout: 30,
					scales: {
						x: {
							display: false,
							grid: {
								drawOnChartArea: false
							},
							stacked: true
						},
						y: {
							grid: {
								drawOnChartArea: false
							},
							stacked: true,
							ticks: {
								callback: function (value) {
									var label = this.getLabelForValue(value);
									if (label != null && label.length > 26) {
										label = this.getLabelForValue(value).substr(0, 26) + '...';
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
		} else if (num == '1') {
			config = {
				type: 'bar',
				data: this.datasetProduct,
				options: {
					locale: 'es-ES',
					onClick: (event, elements, chart) => {
						// this.loading = true;
						// this.loadingTable = true;
						if (elements[0] != null) {
							if (this.filterProduct == null || this.filterProduct != chart.config._config.data.labels[elements[0].index]) {
								this.filterProduct = chart.config._config.data.labels[elements[0].index];
								this.selectedProducts = [this.labelsProductId.get(this.filterProduct)];
								this.selectedlabels = [this.filterProduct];
								this.labelsProduct = [this.filterProduct];
								this.template.querySelector('[data-id="searchProductMulti"]').refreshAll();
								this.template.querySelector('[data-id="searchProductMulti"]').selectedlabels = this.selectedlabels;
								this.template.querySelector('[data-id="searchProductMulti"]').selectedvalues = this.selectedProducts;
								this.template.querySelector('[data-id="searchProductMulti"]').refreshOrginalList();

								this.destacadas = false;
								this.filters = {
									isDestacada: false,
									isPendienteFirma: this.pendienteFirma,
									isPrio: this.priorizado,
									orderBy: this.orderBy,
									orderingCriterion: this.orderingCriterion
								};


								this.moreFilters = {
									oficina: this.numOficinaEmpresa,
									employee: this.selectedEmployees,
									origen: 'all',
									stage: this.selectedEstado,
									esg: this.esg
								};
								if (this.orderBy === 'C') {
									this.orderBy = 'O';
									//.orderBy = 'O';
								}
							} else {
								this.filterProduct = null;
								this.selectedProducts = [];
								this.selectedlabels = [];
								this.labelsProduct = [];
								this.template.querySelector('[data-id="searchProductMulti"]').refreshAll();
								this.destacadas = false;
								this.filters = {
									isDestacada: false,
									isPendienteFirma: this.pendienteFirma,
									isPrio: this.priorizado,
									orderBy: this.orderBy,
									orderingCriterion: this.orderingCriterion
								};

								this.moreFilters = {
									oficina: this.numOficinaEmpresa,
									employee: this.selectedEmployees,
									origen: 'all',
									stage: this.selectedEstado,
									esg: this.esg
								};
								if (this.orderBy === 'O' && this.selectedNames.length == 0 && this.filterExpe != null) {
									this.orderBy = 'C';
									//this.filters.orderBy = 'C';
								}
							}
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
						x: {
							display: false,
							grid: {
								drawOnChartArea: false
							},
							stacked: true
						},
						y: {
							grid: {
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
		} else if (num == '3') {
			config = {
				type: 'treemap',
				data: {
					datasets: this.datasetExpe
				},
				options: {
					locale: 'es-ES',
					onClick: (event, elements, chart) => {
						// this.loading = true;
						// this.loadingTable = true;
						if (elements[0] != null) {
							if (this.labelFilterExpe == chart.config._config.data.datasets[0].data[elements[0].index]._data.label) {
								this.filterExpe = null;
								this.labelFilterExpe = null;
								this.destacadas = false;
								this.filters = {
									isDestacada: false,
									isPendienteFirma: this.pendienteFirma,
									isPrio: this.priorizado,
									orderBy: this.orderBy,
									orderingCriterion: this.orderingCriterion
								};
								this.moreFilters = {
									oficina: this.numOficinaEmpresa,
									employee: this.selectedEmployees,
									origen: 'all',
									stage: this.selectedEstado,
									esg: this.esg
								};
								if (this.orderBy === 'C') {
									this.orderBy = 'O';
									//this.filters.orderBy = 'O';
								}
							} else {
								this.onClickFam = true;
								this.filterExpe = chart.config._config.data.datasets[0].data[elements[0].index]._data.listProduct;
								this.labelFilterExpe = chart.config._config.data.datasets[0].data[elements[0].index]._data.label;
								this.destacadas = false;
								this.filters = {
									isDestacada: false,
									isPendienteFirma: this.pendienteFirma,
									isPrio: this.priorizado,
									orderBy: this.orderBy,
									orderingCriterion: this.orderingCriterion
								};

								this.moreFilters = {
									oficina: this.numOficinaEmpresa,
									employee: this.selectedEmployees,
									origen: 'all',
									stage: this.selectedEstado,
									esg: this.esg
								};
								this.selectedFamilia = [this.filterExpe[0].familia];
								this.template.querySelector('[data-id="searchFamiliaMulti"]').refreshAll();
								this.template.querySelector('[data-id="searchFamiliaMulti"]').selectedFamilia = this.selectedFamilia;
								this.template.querySelector('[data-id="searchFamiliaMulti"]').labelFilterExpe = this.selectedFamilia;
								this.template.querySelector('[data-id="searchFamiliaMulti"]').selectedvalues = this.selectedFamilia;
								this.template.querySelector('[data-id="searchFamiliaMulti"]').refreshOrginalList();

								if (this.orderBy === 'O' && this.selectedProducts.length === 0 && this.selectedNames.length === 0) {
									this.orderBy = 'C';
									//this.filters.orderBy = 'C';
								}
							}
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
						x: {
							display: false,
							grid: {
								drawOnChartArea: false
							},
							stacked: true
						},
						y: {
							grid: {
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


	setNumber(num) {
		var listNums = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9];
		if (listNums.includes(num)) {
			num = '0' + num;
		}
		return num;
	}

	getDataChart() {
		var filterWithOthersCharts = false;
		getDataToChart({ listOppExp: this.listOppSearch, listOpp: this.listOppExpe, filterWithOthersCharts: filterWithOthersCharts })
			.then(result => {
				if (result != null) {
					this.dataset = result;
					this.getCharts();
				}

				var optionsFamiliaWithOutOrder = new Map();
				var dataFamilia = new Map();
				var listAdded = [];


				for (var i = 0; i < result.length; i++) {
					if (result[i].label != null && result[i].listProduct != null && !listAdded.includes(result[i].label) && this.selectedFamilia != null && this.selectedFamilia.includes(result[i].label)) {
						listAdded.push(result[i].label);
						optionsFamiliaWithOutOrder.set(result[i].label, { label: result[i].label, value: result[i].label, selected: true });
					} else if (result[i].label != null && result[i].listProduct != null && !listAdded.includes(result[i].label)) {
						listAdded.push(result[i].label);
						optionsFamiliaWithOutOrder.set(result[i].label, { label: result[i].label, value: result[i].label, selected: false });

					}
					if (dataFamilia.get(result[i].label) != null) {
						dataFamilia.set(result[i].label, dataFamilia.get(result[i].label) + 1);
					} else {
						dataFamilia.set(result[i].label, 1);
					}
				}

				this.optionsFamilia = [];


				var mapArraPro = Array.from(dataFamilia).sort((a, b) => b[1] - a[1]);
				var mapPro = new Map(mapArraPro);
				var iterPro = mapPro.keys();
				for (var q = 0; q < optionsFamiliaWithOutOrder.size; q++) {
					var pro = iterPro.next().value;
					if (optionsFamiliaWithOutOrder.get(pro) != null) {
						this.optionsFamilia.push(optionsFamiliaWithOutOrder.get(pro));
					}
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

	colorFromRawPro(ctx) {
		var color;
		if (ctx.dataIndex !== null && ((this.filterProduct != null && this.filterProduct !== this.labelsProData[ctx.dataIndex]) || ((this.selectedlabels === null && this.selectedlabels?.length === 0) || (this.selectedlabels !== null && this.selectedlabels?.length > 0 && !this.selectedlabels.includes(this.labelsProData[ctx.dataIndex]))))) {
			color = 'rgb(134, 136, 137)';
		} else {
			color = 'rgb(0,126,174)';
		}
		return color;
	}

	colorFromRawName(ctx) {
		var color;
		if (ctx.dataIndex !== null && ((this.filterName !== null && this.filterName !== this.labelsNameData[ctx.dataIndex]) || ((this.selectedNames === null && this.selectedNames.length === 0) || (this.selectedNames !== null && this.selectedNames.length > 0 && !this.selectedNames.includes(this.labelsNameData[ctx.dataIndex]))))) {
			color = 'rgb(134, 136, 137)';
		} else {
			color = 'rgb(0,126,174)';
		}
		return color;
	}

	resetTablePag() {
		this.showPrevious = false;
		this.showNext = true;
		this.page = 1;
	}


	handleSearchName(e) {
		if ((e.detail.selectedvalues.length > 0 || (this.selectedNames.length > 0 && e.detail.selectedvalues.length == 0)) && JSON.stringify(this.selectedNames) != JSON.stringify(e.detail.selectedvalues)) {
			var valuesNames = [];
			for (var i = 0; i < e.detail.selectedvalues.length; i++) {
				valuesNames.push(e.detail.selectedvalues[i]);
			}
			this.selectedNames = valuesNames;
			this.filterName = null;
			this.template.querySelector('[data-id="borderProduct"]').style.height = '';
			this.template.querySelector('[data-id="borderName"]').style.height = '';
			this.template.querySelector('[data-id="borderExp"]').style.height = '';
			if (this.orderBy === 'C') {
				this.orderBy = 'O';
				//this.filters.orderBy = 'O';
			} else if (e.detail.selectedvalues.length === 0 && this.orderBy === 'O' && this.selectedProducts.length === 0 && this.filterExpe != null) {
				this.orderBy = 'C';
				//this.filters.orderBy = 'C';
			}
			this.filters = {
				isDestacada: false,
				isPendienteFirma: this.pendienteFirma,
				isPrio: this.priorizado,
				orderBy: this.orderBy,
				orderingCriterion: this.orderingCriterion
			};

			this.destacadas = false;
			this.getOpp();
		}
	}

	closePillName(event) {
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
			//this.filters.orderBy = 'C';
		}
		this.getOpp();
	}

	handleSearchProductGrafico(e) {
		if ((e.detail.selectedvalues.length > 0 || (this.selectedProducts.length > 0 && e.detail.selectedvalues.length == 0)) && JSON.stringify(this.selectedProducts) != JSON.stringify(e.detail.selectedvalues)) {
			this.selectedProducts = e.detail.selectedvalues;
			this.selectedlabels = e.detail.selectedlabels;
			this.filterProduct = null;
			this.template.querySelector('[data-id="borderProduct"]').style.height = '';
			this.template.querySelector('[data-id="borderName"]').style.height = '';
			this.template.querySelector('[data-id="borderExp"]').style.height = '';
			if (this.orderBy === 'C') {
				this.orderBy = 'O';
				//this.filters.orderBy = 'O';
			} else if (e.detail.selectedvalues.length === 0 && this.orderBy === 'O' && this.selectedNames.length === 0 && this.filterExpe != null) {
				this.orderBy = 'C';
				//this.filters.orderBy = 'C';
			}
			this.filters = {
				isDestacada: false,
				isPendienteFirma: this.pendienteFirma,
				isPrio: this.priorizado,
				orderBy: this.orderBy,
				orderingCriterion: this.orderingCriterion
			};

			this.destacadas = false;
			this.getOpp();
		}
	}


	@track allValue = null;
	handleSearchFamiliaGrafico(e) {
		if ((e.detail.selectedvalues.length > 0 || (this.selectedFamilia.length > 0 && e.detail.selectedvalues.length == 0)) && JSON.stringify(this.selectedFamilia) != JSON.stringify(e.detail.selectedvalues)) {
			this.selectedFamilia = e.detail.selectedvalues;

			this.dataset.forEach(element => {
				this.selectedFamilia.forEach(element2 => {
					if (element.label === element2) {
						this.filterExpe = [...element.listProduct];
						if (this.allValue == null) {
							this.allValue = element.listProduct;
						} else {
							this.allValue = this.allValue.concat(element.listProduct);

						}
					}
				});
			});

			this.filterExpe = this.allValue;
			this.allValue = null;

			this.template.querySelector('[data-id="borderProduct"]').style.height = '';
			this.template.querySelector('[data-id="borderName"]').style.height = '';
			this.template.querySelector('[data-id="borderExp"]').style.height = '';
			if (this.orderBy === 'C') {
				this.orderBy = 'O';
				//this.filters.orderBy = 'O';
			} else if (e.detail.selectedvalues.length === 0 && this.orderBy === 'O' && this.selectedNames.length === 0 && this.filterExpe != null) {
				this.orderBy = 'C';
				//this.filters.orderBy = 'C';
			}

		}

		this.filters = {
			isDestacada: false,
			isPendienteFirma: this.pendienteFirma,
			isPrio: this.priorizado,
			orderBy: this.orderBy,
			orderingCriterion: this.orderingCriterion
		};

		this.destacadas = false;


		this.getOpp();


	}
	closePillProd(event) {
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
			//this.filters.orderBy = 'C';
		}
		this.getOpp();
	}

	closePillFamilia(event) {
		let selection = event.target.dataset.value;
		let selectedpills2 = this.selectedFamilia;
		let pillIndex2 = selectedpills2.indexOf(selection);
		this.selectedFamilia.splice(pillIndex2, 1);

		if (this.onClickFam) {
			this.filterExpe = null;
			this.labelFilterExpe = null;
		} else {
			for (let index = this.filterExpe.length - 1; index >= 0; index--) {
				if (this.filterExpe[index].familia == selection) {
					this.filterExpe.splice(index, 1);
				}
			}
		}



		this.template.querySelector('[data-id="searchFamiliaMulti"]').selectedlabels = this.selectedFamilia;
		this.template.querySelector('[data-id="searchFamiliaMulti"]').selectedvalues = this.selectedFamilia;
		this.template.querySelector('[data-id="searchFamiliaMulti"]').refreshOrginalList();
		this.template.querySelector('[data-id="borderProduct"]').style.height = '';
		this.template.querySelector('[data-id="borderName"]').style.height = '';
		this.template.querySelector('[data-id="borderExp"]').style.height = '';

		this.getOpp();

		this.onClickFam = false;
	}



	handleRowAction(event) {
		if (event.detail.action.name === 'createEvent') {
			this[NavigationMixin.Navigate]({
				type: 'standard__component',
				attributes: {
					// componentName: "c__cibe_GestionAgilParent"
					componentName: "c__cibe_NewEventParent"
				},
				state: {
					c__recId: event.detail.row.clienteId.substring(1),
					c__id: event.detail.row.cliente,
					c__oportunidadId: event.detail.row.oppId.substring(1)
				}
			});
		}



	}

	handleAplicarMoreFilters() {

		// this.loadingTable = true;
		// this.loading = true;
		let employee = this.selectedEmployees.slice();
		let participeTeam = this.selectedParticipe.slice();
		let productoSelected = this.selectedProductsFilter.slice();
		let estado = this.selectedEstado.slice();
		this.moreFilters = {
			oficina: this.numOficinaEmpresa,
			employee: employee,
			origen: this.origenFilter,
			stage: estado,
			probabilidad: this.targetProbabilidad,//this.potencial,
			dateProFrom: this.fechaProximaGestionD,// this.fechaGestionFrom,
			dateProUntil: this.fechaProximaGestionH,// this.fechaGestionUntil,
			dateVenFrom: this.fechaCierreD,//this.fechaVencimientoFrom,
			dateVenUntil: this.fechaCierreH,// this.fechaVencimientoUntil,
			pais: this.targetPaises,
			operacion: this.targetTipoOperacion,
			modeloAtencion: this.targetAttentionModel,
			producto: productoSelected,
			esg: this.esg,
			participante: participeTeam
		};

		this.filters = {
			isDestacada: false,
			isPendienteFirma: this.pendienteFirma,
			isPrio: this.priorizado,
			orderBy: this.orderBy,
			orderingCriterion: this.orderingCriterion
		};


		this.destacadas = false;
		// this.disabledAplicarMoreFilters = true;

		if (this.selectedEmployees == null || this.selectedEmployees == '') {
			const evt = new ShowToastEvent({
				title: 'Error',
				message: 'Debe rellenar el empleado asignado',
				variant: 'error',
				mode: 'error'
			});
			this.dispatchEvent(evt);
		} else {
			this.resetTablePag();
			this.getOpp();
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
			for (var i = 0; i < moreFilter.length; i++) {
				for (var a = 0; a < selected.length; a++) {
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
	//Mi Oficina
	handleSearchMOf(event) {
		lookupSearch(event.detail)
			.then((results) => {
				if (event.detail.myOffice == 'true') {
					this.template.querySelector('[data-id="lookupMO"]> c-av_-lookup').setSearchResults(results);
				} else {
					this.template.querySelector('[data-id="lookupAssig"]> c-av_-lookup').setSearchResults(results);
				}
			})
			.catch((error) => {
				this.notifyUser('Lookup Error', labels.errorOcc + labels.miOficinaLab + '.', 'error');
				console.error('Lookup error', JSON.stringify(error));
				this.errors = [error];
			});
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

	handleCloseModal() {
		this.isModalOpen = false;
	}

	handleModal(event) {
		if (this.filterList != null && this.selectedItems > 0) {
			if (event.target.className === 'my-office-true') {
				this.actionType = 'oppoAsignar';
			} else {
				this.actionType = 'oppoAsignarOtraOficina';
			}
			this.isModalOpen = true;
		} else if (this.filterList == null) {
			this.actionType = 'noEmpleado';
			this.isModalOpen = true;
		} else {
			this.actionType = 'noOppos';
			this.isModalOpen = true;
		}
	}

	doAction(event) {
		var actionType = event.detail.action;
		if (actionType == 'oppoAsignar') {
			this.handleSave();
			this.template.querySelector('[data-id="lookupMO"]> c-av_-lookup').handleClearSelection();
			this.selectedItems = null;
			this.filterList = null;
		} else if (actionType == 'oppoAsignarOtraOficina') {
			this.handleSave();
			this.template.querySelector('[data-id="lookupAssig"]> c-av_-lookup').handleClearSelection();
			this.selectedItems = null;
			this.filterList = null;
		} else {
			this.handleCloseModal();
		}
	}

	handleSave() {
		this.loadingTable = true;
		this.loading = true;
		var el = this.template.querySelector('lightning-datatable');
		var selected = el.getSelectedRows();
		// pop up de confirmacion
		if (selected != null && selected.length > 0) {
			var selectedIds = [];
			for (let i = 0; i < selected.length; i++) {
				selectedIds.push(selected[i].oppId.substring(1));
			}


			// // pop up de confirmacion
			// if(selected != null && selected.length > 0){
			// 	Selected es 0 que no se ejecuted
			//assign({contactId : this.filterList, selectedRows : selected})
			assign({ objectName: 'Opportunity', contactId: this.filterList, selectedRowIds: selectedIds })
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
					this.loadingTable = false;
					//this.loading = false;
					this.getOpp();//volver a lanzar la query
					this.handleCloseModal();
					this.template.querySelector('lightning-datatable').selectedRows = [];
				})
				.catch(error => {
					console.log(error);
					this.loadingTable = false;
					//this.loading = false;
					this.handleCloseModal();
				});
		} else {
			this.handleCloseModal();
		}
	}

	//flow
	handleClickOppo() {
		getActions({ actionSetting: this.actionSetting })
			.then(data => {
				this.isLoaded = false;
				this.flowlabel = data[0].label;
				this.flowName = data[0].name;
				this.flowOutput = data[0].output;
				this.redirectId = null;
				this.isShowFlowAction = true;
			}).catch(error => {
				this.showToast(this.labels.error, this.labels.errorActualizandoEvento, 'error', 'pester');
				this.isLoaded = false;
			});
	}

	hideFlowAction() {
		this.isShowFlowAction = false;
	}



	getSelectedName(event) {
		this.selectedItems = event.detail.selectedRows.length;
	}

	handleStatusChange(event) {
		const status = event.detail.status;
		const outputVariables = event.detail.outputVariables;
		if (outputVariables) {
			outputVariables.forEach(e => {
				this.flowOutput.split(',').forEach(v => {
					if (e.name == v && e.value) {
						this.redirectId = e.value;
					}
				});
			});
		}
		if (status === 'FINISHED') {
			this.isShowFlowAction = false;
			const selectedEvent = new CustomEvent('closetab', { detail: { recordId: this.redirectId } });
			this.dispatchEvent(selectedEvent);
			eval('$A.get("e.force:refreshView").fire();');
			if (this.redirectId) {
				var redirect = eval('$A.get("e.force:navigateToURL");');
				redirect.setParams({
					"url": "/" + this.redirectId
				});
				redirect.fire();
			}
		}
	}

	colorFromRaw(ctx) {
		var color;
		if (ctx.type !== 'data') {
			return 'transparent';
		}
		if (this.labelFilterExpe != null && ctx.raw._data != null && this.labelFilterExpe != ctx.raw._data.label) {
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

	unSelectEstado(event) {


		var pillIndex = event.detail.index ? event.detail.index : event.detail.name;
		const itemPill = this.selectedEstado;
		itemPill.splice(pillIndex, 1);
		this.selectedEstado = [...itemPill];

		if (this.selectedEstado.length === 0) {
			this.estadoDiv = false;
			this.statusFilter = '';
		}
		//this.disabledAplicarMoreFilters = !this.viewMoreFilter();
	}


	unSelectEmployee(cmp) {
		let divToDel = cmp.target.parentNode;
		for (let i = 0; i < this.selectedEmployees.length; i++) {
			if (this.selectedEmployees[i].id === cmp.target.name) {
				this.selectedEmployees.splice(i, 1);
			} else if (this.selectedEmployees[i].id != null) {
				this.employeeFilter = this.selectedEmployees[i].id;
			}
		}
		divToDel.classList.add('delete');
		cmp.target.remove();
		if (this.selectedEmployees.length === 0) {
			this.employeesDiv = false;
			this.employeeFilter = '';
		}
		this.disabledAplicarMoreFilters = !this.viewMoreFilter();
	}
	unSelectProduct(event) {
		var pillIndex = event.detail.index ? event.detail.index : event.detail.name;
		const itemPill = this.selectedProductsFilter;
		itemPill.splice(pillIndex, 1);
		this.selectedProductsFilter = [...itemPill];

		if (this.selectedProductsFilter.length === 0) {
			this.showSelectedProducts = false;
			this.initialSelection = null;
		}

		//this.disabledAplicarMoreFilters = !this.viewMoreFilter();
	}

	unSelectParticipe(event) {

		var pillIndex = event.detail.index ? event.detail.index : event.detail.name;
		const itemPill = this.selectedParticipe;
		itemPill.splice(pillIndex, 1);
		this.selectedParticipe = [...itemPill];
		this.selectIdPar = [...itemPill];

		if (this.selectedParticipe.length === 0) {
			this.showSelectedParticipe = false;
			this.initialSelection = null;
		}
	}

	handleDestacadas(event) {
		// this.loading = true;
		//this.loadingTable = true;
		this.expandedTreeGRows = [];
		this.destacadas = event.target.checked;
		this.filters = {
			isDestacada: event.target.checked,
			isPendienteFirma: this.pendienteFirma,
			isPrio: this.priorizado,
			orderBy: this.orderBy,
			orderingCriterion: this.orderingCriterion
		};


		this.resetTablePag();
		this.getOpp();
	}

	handlePendienteFirma(event) {
		this.pendienteFirma = event.target.checked;
		this.disabledAplicar = !this.viewFilters();
	}

	handlePriorizador(event) {
		this.priorizado = event.target.checked;
		this.disabledAplicar = !this.viewFilters();
	}

	viewFilters() {
		var resultado = false;
		if (this.filters != null && this.filters.destacadas != this.destacadas) {
			resultado = true;
		} else if (this.filters != null && this.filters.pendienteFirma != this.pendienteFirma) {
			resultado = true;
		} else if (this.filters != null && this.filters.priorizado != this.priorizado) {
			resultado = true;
		} else if (this.filters != null && this.filters.orderBy != this.orderBy) {
			resultado = true;
		} else if (this.filters != null && this.filters.orderingCriterion != this.orderingCriterion) {
			resultado = true;
		} else if (this.filters != null && this.filters.limite != this.limit) {
			resultado = true;
		}
		return resultado;
	}

	get optionsLimit() {
		return [
			{ label: '20', value: '20' },
			{ label: '50', value: '50' },
			{ label: '100', value: '100' }
		];
	}

	handleLimit(event) {
		this.limit = event.target.value;
		this.disabledAplicar = !this.viewFilters();
	}

	handleAplicar() {
		this.expandedTreeGRows = [];
		this.filters = {
			isDestacada: this.destacadas,
			isPendienteFirma: this.pendienteFirma,
			isPrio: this.priorizado,
			orderBy: this.orderBy,
			orderingCriterion: this.orderingCriterion
		};

		this.disabledAplicar = true;
		this.resetTablePag();
		this.getOpp();
	}


	get optionsOrderBy() {
		return [
			{ label: 'GC', value: 'CIBE_GrupoComercial__r.CIBE_GrupoComercial__c' },
			{ label: 'Origen', value: 'RecordType.Name' },
			{ label: 'Etapa', value: 'StageName' },
			{ label: 'Nombre de la Oportunidad', value: 'Name' },
			{ label: 'Producto', value: 'AV_PF__r.Name' },
			{ label: 'Importe', value: 'Amount' },
			{ label: 'Divisa', value: 'CIBE_Divisa__c' },
			{ label: 'Financiación sostenible', value: 'CIBE_ESG__c' },
			{ label: 'Probabilidad éxito', value: 'CIBE_ProbabilidadExito__c' },
			{ label: 'Fecha última gestión', value: 'AV_FechaModificacion__c' },
			{ label: 'Próxima gestión', value: 'AV_FechaProximoRecordatorio__c' },
			{ label: 'Fecha cierre', value: 'CloseDate' },
			{ label: 'Fecha último contacto con el cliente', value: 'Account.AV_LastContactDate__c' },
			{ label: 'Fecha próxima cita ', value: 'CIBE_NextMeetingDate__c' },
			{ label: 'Propietario ', value: 'Owner.Name' }
		];
	}
	get optionsOrderingCriterion() {
		return [
			{ label: 'Ascendente', value: 'ASC' },
			{ label: 'Descendente', value: 'DESC' }
		];
	}

	handleOrderBy(event) {
		this.orderBy = event.target.value;
		this.disabledAplicar = !this.viewFilters();
	}

	handleOrderingCriterion(event) {
		this.orderingCriterion = event.target.value;
		this.disabledAplicar = !this.viewFilters();
	}


	previous() {
		this.pageNumber = Math.max(0, this.pageNumber - 1);
		this.updatePage();
	}

	first() {
		this.pageNumber = 0;
		this.updatePage();
	}

	next() {
		if ((this.pageNumber + 1) <= this.totalPages) {
			this.loading = true;
			this.loadingTable = true;
			this.pageNumber = this.pageNumber + 1;
			this.updatePage();
		}
	}

	last() {
		this.pageNumber = this.pageNumber = this.totalPages;
		this.updatePage();
	}

	updatePage() {
		this.pageData = this.listOppTable.slice(this.pageNumber * parseInt(this.limit, 0), this.pageNumber * parseInt(this.limit, 0) + parseInt(this.limit, 0));
		this.loading = false;
		this.loadingTable = false;

	}

	get getPageNumber() {
		return (this.pageNumber + 1);
	}

	get getTotalPageNumber() {
		return (this.totalPages + 1);
	}


	previous2() {
		this.pageNumber2 = Math.max(0, this.pageNumber2 - 1);
		this.updatePage2();
	}

	first2() {
		this.pageNumber2 = 0;
		this.updatePage2();
	}

	next2() {
		if ((this.pageNumber2 + 1) <= this.totalPages2) {
			this.pageNumber2 = this.pageNumber2 + 1;
			this.updatePage2();
		}
	}

	last2() {
		this.pageNumber2 = this.pageNumber2 = this.totalPages2;
		this.updatePage2();
	}

	updatePage2() {
		this.pageData2 = this.gridData.slice(this.pageNumber2 * parseInt(this.limit), this.pageNumber2 * parseInt(this.limit) + parseInt(this.limit));


	}

	get getPageNumber2() {
		return (this.pageNumber2 + 1);
	}

	get getTotalPageNumber2() {
		return (this.totalPages2 + 1);
	}

}