import { LightningElement, api, wire, track } from 'lwc';
import USER_ID from '@salesforce/user/Id';
import NAME from '@salesforce/schema/User.Name';
import CENTER from '@salesforce/schema/User.AV_NumeroOficinaEmpresa__c';
import { getRecord } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import ISBPR from '@salesforce/customPermission/AV_PrivateBanking';

import searchEmployee from '@salesforce/apex/CIBE_NewEventController.searchEmployees';
import getContactoPrincipal from '@salesforce/apex/CIBE_NewEventController.getContactoPrincipal';
import searchCXB from '@salesforce/apex/CIBE_NewEventController.searchUserCXB';
import searchEMP from '@salesforce/apex/CIBE_NewEventController.searchUserEMP';
import searchUserTeamCXB from '@salesforce/apex/CIBE_NewEventController.searchUserTeamCXB';
import c2cMakeCall from '@salesforce/apex/AV_SObjectRelatedInfoCController.c2cMakeCall';
// import searchProduct from '@salesforce/apex/CIBE_NewEventController.searchProduct';
// import getAccountOpportunities from '@salesforce/apex/CIBE_NewEventOppDetail_Controller.getAccountOpportunities';
import getAccountTask from '@salesforce/apex/CIBE_NewEventTaskDetail_Controller.getAccountTask';


//labels
import asunto from '@salesforce/label/c.CIBE_Asunto';
import owner from '@salesforce/label/c.CIBE_Owner';
import ubicacion from '@salesforce/label/c.CIBE_Ubicacion';
import comentario from '@salesforce/label/c.CIBE_Comentario';
import confidencial from '@salesforce/label/c.CIBE_Confidencial';
import datosCita from '@salesforce/label/c.CIBE_DatosEvento';
import confidencialidad from '@salesforce/label/c.CIBE_Confidencialidad';
import contactoprincipal from '@salesforce/label/c.CIBE_ContactoPrincipal';
import noasistenteapoderado from '@salesforce/label/c.CIBE_NoAsistenteApoderado';
import msjnoapaoderado from '@salesforce/label/c.CIBE_MsjNoApoderado';
import asistentesEmpresas from '@salesforce/label/c.CIBE_AsistentesEmpresas';
import buscaContacto from '@salesforce/label/c.CIBE_BuscaContacto';
import tipoCita from '@salesforce/label/c.CIBE_TipoCita';
import visitaCliente from '@salesforce/label/c.CIBE_VisitaCliente';
import entrevistaCentro from '@salesforce/label/c.CIBE_EntrevistaCentro';
import llamada from '@salesforce/label/c.CIBE_Llamada';
import videollamada from '@salesforce/label/c.CIBE_Videollamada';
import citaSinVincular from '@salesforce/label/c.CIBE_CitaSinVincular';
import organizador from '@salesforce/label/c.CIBE_Organizador';
import asistentesCaixa from '@salesforce/label/c.CIBE_AsistentesCaixabank';
import escribeAqui from '@salesforce/label/c.CIBE_EscribeAqui';
import entidad from '@salesforce/label/c.CIBE_Entidad';
import asisCXB from '@salesforce/label/c.CIBE_AsistentesCaixabank';
import commentPlaceholder from '@salesforce/label/c.CIBE_EscribeAqui';
import buscaEmpleado from '@salesforce/label/c.CIBE_BuscaEmpleado';
import muro from '@salesforce/label/c.CIBE_Muro';
import duracion from '@salesforce/label/c.CIBE_Duracion';
import horafin from '@salesforce/label/c.CIBE_Horafin';
import horainicio from '@salesforce/label/c.CIBE_Horainicio';
import fecha from '@salesforce/label/c.CIBE_Fecha';
import modocal from '@salesforce/label/c.CIBE_ModoCalendario';
import fechahora from '@salesforce/label/c.CIBE_FechaHora';
import add from '@salesforce/label/c.CIBE_Add';
import oportunidades from '@salesforce/label/c.CIBE_Oportunidades';
import vinculadas from '@salesforce/label/c.CIBE_Vinculadas';
import addOpp from '@salesforce/label/c.CIBE_AddOpp';
import searhProduct from '@salesforce/label/c.CIBE_BuscarProductos';
import llamadaFallida from '@salesforce/label/c.CIBE_LlamadaFallida'




export default class Cibe_GestionAgilReportDetail extends LightningElement {

	labels = {
		asunto,
		owner,
		ubicacion,
		comentario,
		confidencial,
		entidad,
		datosCita,
		confidencialidad,
		contactoprincipal,
		noasistenteapoderado,
		msjnoapaoderado,
		asistentesEmpresas,
		buscaContacto,
		tipoCita,
		visitaCliente,
		entrevistaCentro,
		llamada,
		videollamada,
		citaSinVincular,
		organizador,
		asistentesCaixa,
		escribeAqui,
		asisCXB,
		commentPlaceholder,
		buscaEmpleado,
		muro,
		duracion,
		horafin,
		horainicio,
		fecha,
		modocal,
		fechahora,
		add,
		oportunidades,
		vinculadas,
		addOpp,
		searhProduct,
		llamadaFallida
	}

	//variables para cibe_newEventTab
	@api clientinfo;//Contiene el id y el nombre del cliente
	@api issummary = false; //seteadoa  true por el 1º valor del radio button.
	@api timeinfo;
	@api recordId;
	@api clientname;
	gestionSC = false;

	initialemployee;
	error;
	initialclient = null;
	//variables de input

	clientToSend;
	employeeToSend = USER_ID;
	centerToSend;
	contactToSend;
	attendesToSend = [];
	@track subjectToSend;
	selectedAttendesToSend = [];
	typeToSend;
	accountName;
	employeeName;
	contactPersonName;
	attendeesNamesEMP;
	attendeesNamesCXB;
	officeName;
	typeName;
	datosPersonaContacto;

	otherOfficeNumberToSend;
	//Variables de if:true
	attendesCXB = false;
	attendesEMP = false;
	isIntouch;
	showUbication;
	showOfficeInput;
	isPersonaJuridica;
	disabledContact = false;
	isBpr = ISBPR;

	@track selectedAttendesCXB = [];
	multiSelectionAttendeeCXB = 0;

	@track selectedAttendesEMP = [];
	multiSelectionAttendeeEMP = 0;

	@track confidencial = false;
	@track noOportunidades = false;
	@track asunto;
	//asunto;
	// @track optionsEstado;
	estadoPorDefecto = 'Gestionada positiva';
	@track optionsApoderados;
	@track apoderado = 'sinContacto';
	@track apoderadoName;
	@track sinApoderado = false;
	@track noRegistrado;
	valueRadioButton = 'VC';
	@track ubicacion = true;
	@track ubicacionText;
	@track phoneField;
	selectedItem = 'VC';
	initialDuration = '60';
	@track comentarios;
	@track initialSelection = [];
	@track apoderadosAttendes = [];
	@track attendeeSelectionName;
	accountId;
	newEventHeaderId;
	oppoObj = {};
	oportunidadVin = false;
	isFuture = false;
	renderComponent = false;

	//Opp
	opposCount = 0;
	productToAdd = true;
	listAccountOpportunities = [];
	@track oppoNewList = [];
	selectedProds = [];
	@track oppPrincipal;
	currentMainVinculed;
	durationToSend = '60';
	activityDateToSend;
	showSpinner = true;

	// Task
	listAccountTask = [];
	taskCount = 0;
	@track taskNewList = [];
	selectedTask = [];

	horaActual;

	get today() {
		var date = new Date();
		var isoString = date.toISOString();
		return isoString.slice(0, 10);
	}
	handleChangeActivityDate(e) {
		this.template.querySelector('[data-id="activityDateInput"]').reportValidity();
		this.activityDateToSend = e.target.value;
		this.sendEventInfoToParent();
	}

	connectedCallback() {
		this.selectedItem = 'LMD';
		this.typeName = this.mapType[this.selectedItem];
		this.checkContactType();
		if (this.clientinfo) {
			this.renderComponent = true;
			this.showSpinner = false;
		}
	}


	mapType = {
		'VC': 'Visita cliente',
		'EC': 'Entrevista centro',
		'LMD': 'Llamada',
		'VLD': 'Videollamada',
		'ESE': 'Email,sms,etc',
		'030': 'Muro',
		'GSCC': 'Gestion sin contacto comercial'
	}

	get optionsTime() {
		return [
			{ label: '5 min', value: '5' },
			{ label: '15 min', value: '15' },
			{ label: '30 min', value: '30' },
			{ label: '1 h', value: '60' },
			{ label: '2 h', value: '120' },
			{ label: 'Otra', value: '0' }
		];
	}

	get optionsEstado() {
		return [
			{ label: 'Gestionada positiva', value: 'Gestionada positiva' },
			{ label: 'Gestionada negativa', value: 'Gestionada negativa' }
		];
	}

	setHours(hour) {
		var listNums = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9];
		if (listNums.includes(hour)) {
			hour = '0' + hour;
		}
		return hour;
	}

	@wire(getRecord, { recordId: USER_ID, fields: [NAME, CENTER] })
	wiredUser({ error, data }) {

		if (data && this.clientinfo != null && this.initialclient == null) {
			this.activityDateToSend = this.today;
			this.horaActual = this.setHours(new Date().getHours()) + ':' + this.setHours(new Date().getMinutes());
			this.initialemployee = [{ id: USER_ID, title: data.fields.Name.value, icon: 'standard:account' }]; // gestor emp
			this.initialclient = [{ id: this.clientinfo.accountId, title: this.clientinfo.name, icon: 'standard:user' }];
			this.accountName = this.clientinfo.name;
			this.employeeName = data.fields.Name.value;
			this.clientToSend = this.clientinfo.accountId;
			this.selectedItem = 'VC';
			this.typeName = this.mapType[this.selectedItem];
			this.asunto = this.initialclient[0].title + ' - ';
			this.subjectToSend = this.initialclient[0].title + ' - ';
			let iniDate = new Date(this.activityDateToSend + ' ' + this.horaActual);
			iniDate.setHours(iniDate.getHours(), iniDate.getMinutes() + parseInt(this.durationToSend, 0), '00');
			this.timeFin = this.setHours(iniDate.getHours()) + ':' + this.setHours(iniDate.getMinutes());
			this.renderComponent = true;
			if (this.showSpinner) {
				this.showSpinner = false;
			}

			this.sendEventInfoToParent();

		} else if (error) {
			this.error = error;
		}
	}


	handleSearchEmployee(e) {
		searchEmployee({ searchTerm: e.detail.searchTerm })
			.then(result => {
				if (result != null) {
					this.template.querySelector('[data-id="employeelookup"]').setSearchResults(result);
				}
			}).catch(error => {
				console.log(error);
			});
	}
	handleSelectionEmployee() {
		let employeeSelection = this.template.querySelector('[data-id="employeelookup"]').getSelection()[0];

		if (employeeSelection != null && employeeSelection != undefined) {
			this.employeeToSend = employeeSelection.id;
			this.employeeName = employeeSelection.title;
			this.initialemployee = [{ id: employeeSelection.id, title: employeeSelection.title, icon: 'standard:account' }];
		} else {
			this.employeeToSend = null;
			this.employeeName = null;
		}

		this.sendEventInfoToParent();
	}

	handleSearchClick(e) {
		searchUserTeamCXB({ recordId: this.clientinfo.accountId })
			.then((results) => {
				this.template.querySelector('[data-id="attendeeslookupCXB"]').setSearchResults(results);
			})
			.catch((error) => {
				console.error(error);
				this.errors = [error];
			});
	}

	handleSearchAttendes(e) {
		searchCXB({ searchTerm: e.detail.searchTerm, selectedIds: this.selectedAttendesToSend })
			.then((results) => {
				this.template.querySelector('[data-id="attendeeslookupCXB"]').setSearchResults(results);
			})
			.catch((error) => {
				console.error(error);
				this.errors = [error];
			});
	}

	handleSelectionAttendee() {
		let attendeeLookup = this.template.querySelector('[data-id="attendeeslookupCXB"]');
		let attendeeSelection = attendeeLookup.getSelection()[0];
		if (attendeeSelection != null && attendeeSelection != undefined) {
			this.selectedAttendesCXB.push({
				id: attendeeSelection.id,
				label: attendeeSelection.title,
				bucleId: ++this.multiSelectionAttendeeCXB
			}
			);
			this.attendesCXB = true;
			attendeeLookup.handleClearSelection();
			this.sendEventInfoToParent();
		}
		this.attendeesNamesCXB = '';
		for (let i = 0; i < this.selectedAttendesCXB.length; i++) {
			if (i == this.selectedAttendesCXB.length - 1) {
				this.attendeesNamesCXB = this.attendeesNamesCXB + this.selectedAttendesCXB[i].label;
			} else {
				this.attendeesNamesCXB = this.attendeesNamesCXB + this.selectedAttendesCXB[i].label + ', ';
			}
		}
	}
	handleRemoveAttende(e) {
		let idToDel = e.target.name;
		this.attendeesNamesCXB = '';
		for (let i = 0; i < this.selectedAttendesCXB.length; i++) {
			if (this.selectedAttendesCXB[i].id === idToDel) {
				this.selectedAttendesCXB.splice(i, 1);
				break;
			}
			if (i == this.selectedAttendesCXB.length - 1) {
				this.attendeesNamesCXB = this.attendeesNamesCXB + this.selectedAttendesCXB[i].label;
			} else {
				this.attendeesNamesCXB = this.attendeesNamesCXB + this.selectedAttendesCXB[i].label + ', ';
			}
		}
		this.sendEventInfoToParent();
		this.attendesCXB = this.selectedAttendesCXB.length > 0;
	}

	handleSearchAttendes2(e) {

		searchEMP({ searchTerm: e.detail.searchTerm, selectedIds: this.selectedAttendesToSend, cliente: this.clientToSend })
			.then((results) => {
				this.template.querySelector('[data-id="attendeeslookupEMP"]').setSearchResults(results);
			})
			.catch((error) => {
				console.error(error);
				this.errors = [error];
			});
	}

	handleSelectionAttendee2() {
		let attendeeLookup = this.template.querySelector('[data-id="attendeeslookupEMP"]');
		let attendeeSelection = attendeeLookup.getSelection()[0];
		if (attendeeSelection != null && attendeeSelection != undefined) {
			this.selectedAttendesEMP.push({
				id: attendeeSelection.id,
				label: attendeeSelection.title,
				bucleId: ++this.multiSelectionAttendeeEMP
			}
			);
			this.attendesEMP = true;
			attendeeLookup.handleClearSelection();
			this.sendEventInfoToParent();
		}
		this.attendeesNamesEMP = '';
		for (let i = 0; i < this.selectedAttendesEMP.length; i++) {
			if (i == this.selectedAttendesEMP.length - 1) {
				this.attendeesNamesEMP = this.attendeesNamesEMP + this.selectedAttendesEMP[i].label;
			} else {
				this.attendeesNamesEMP = this.attendeesNamesEMP + this.selectedAttendesEMP[i].label + ', ';
			}
		}
	}

	handleRemoveAttende2(e) {
		let idToDel = e.target.name;
		this.attendeesNamesEMP = '';
		for (let i = 0; i < this.selectedAttendesEMP.length; i++) {
			if (this.selectedAttendesEMP[i].id === idToDel) {
				this.selectedAttendesEMP.splice(i, 1);
				break;
			}
			if (i == this.selectedAttendesEMP.length - 1) {
				this.attendeesNamesEMP = this.attendeesNamesEMP + this.selectedAttendesEMP[i].label;
			} else {
				this.attendeesNamesEMP = this.attendeesNamesEMP + this.selectedAttendesEMP[i].label + ', ';
			}
		}
		this.sendEventInfoToParent();
		this.attendesEMP = this.selectedAttendesEMP.length > 0
	}

	setMonths(month) {
		month = month + 1;
		var listNums = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9];
		if (listNums.includes(month)) {
			month = '0' + month;
		}
		return month;
	}

	formatDate(date) {
		var dateToFormat = new Date(date);
		return this.setHours(dateToFormat.getDate()) + '/' + this.setMonths(dateToFormat.getMonth()) + '/' + dateToFormat.getFullYear();
	}

	sendEventInfoToParent() {
		this.selectedAttendesToSend = [];
		if (this.selectedAttendesCXB.length > 0) {
			this.selectedAttendesCXB.forEach(att => {
				this.selectedAttendesToSend.push(att.id);
			});
		}

		if (this.selectedAttendesEMP.length > 0) {
			this.selectedAttendesEMP.forEach(att => {
				this.selectedAttendesToSend.push(att.id);
			});
		}

		this.dispatchEvent(
			new CustomEvent('eventinfo', {
				detail: {
					owner: this.employeeToSend,
					personaContacto: this.apoderado,
					attendes: this.selectedAttendesToSend,
					subject: this.subjectToSend,
					otherOfficeNumber: this.otherOfficeNumberToSend,
					confidencial: this.confidencial,
					tipoCita: this.selectedItem,
					ubicacionText: this.ubicacionText,
					noOportunidades: this.noOportunidades,
					comentarios: this.comentarios,
					client: this.initialclient[0].id,
					startDateTime: new Date(this.activityDateToSend + ' ' + this.horaActual),
					endDateTime: new Date(this.activityDateToSend + ' ' + this.timeFin),
					activityDate: this.activityDateToSend,
					estadoTask: this.estadoPorDefecto
				}
			})
		)

	}

	scrollIntoElement(id) {
		this.template.querySelector('[data-id="' + id + '"]').scrollIntoView({
			behavior: 'auto',
			block: 'center',
			inline: 'center'
		});;
	}

	showToast(title, message, variant) {
		var event = new ShowToastEvent({
			title: title,
			message: message,
			variant: variant,
			mode: 'pester'
		});
		this.dispatchEvent(event);
	}

	@wire(getContactoPrincipal, { accountId: '$clientinfo.accountId' })
	getContactoPrincipal({ error, data }) {
		if (data) {
			let options = [];
			data.forEach(element => {
				this.datosPersonaContacto = data;
				if (element.Contact.RecordType.DeveloperName === 'CIBE_ContactoComercial') {
					options.push({ label: element.Contact.Name + ' - Contacto comercial', value: element.Contact.Id });
				} else if (element.Contact.RecordType.DeveloperName === 'CIBE_Apoderado' && element.Contact.CIBE_Carrec__c !== '00016' && (element.Contact.CIBE_FechaVencimiento__c >= this.today || element.Contact.CIBE_FechaVencimiento__c == null)) {
					options.push({ label: element.Contact.Name + ' - Apoderado', value: element.Contact.Id });
				} else if (element.Contact.RecordType.DeveloperName === 'CIBE_Apoderado' && element.Contact.CIBE_Carrec__c === '00016' || (element.Contact.CIBE_FechaVencimiento__c < this.today)) {
					options.push({ label: element.Contact.Name + ' - Contacto comercial', value: element.Contact.Id });
				}
			});

			options.push({ label: '', value: 'sinContacto' });
			this.optionsApoderados = options;

		} else if (error) {
			console.log(error);
		}
	}

	handleRadioChange(event) {
		this.selectedItem = event.target.value;
		this.typeName = this.mapType[this.selectedItem];
		this.checkContactType(event);
		this.sendEventInfoToParent();
	}


	checkContactType() {
		if (this.selectedItem === 'EC' || this.selectedItem === 'VC') {
			this.initialDuration = '60';
			this.durationToSend = '60';
		} else if (this.selectedItem === 'LMD' || this.selectedItem === 'VLD') {
			this.initialDuration = '30';
			this.durationToSend = '30';
		}

		let iniDate = new Date(this.activityDateToSend + ' ' + this.horaActual);
		iniDate.setHours(iniDate.getHours(), iniDate.getMinutes() + parseInt(this.durationToSend, 0), '00');
		this.timeFin = this.setHours(iniDate.getHours()) + ':' + this.setHours(iniDate.getMinutes());


		if (this.selectedItem !== 'VC') {
			this.ubicacion = false;
		} else if (this.selectedItem === 'VC') {
			this.ubicacion = true;
		}
		if (this.selectedItem == 'ESE' || this.selectedItem == '030') {
			this.issummary = true;
			this.gestionSC = false;
		} else if (this.selectedItem == 'GSCC') {
			this.issummary = true;
			this.gestionSC = true;
		} else {
			this.issummary = false;
			this.gestionSC = false;
		}
	}





	handleUbicacion(event) {
		this.ubicacionText = event.target.value;
		this.sendEventInfoToParent();
	}
	handlePhone() {
		if (this.phoneField != undefined) {
			this.makeCall(this.phoneField);
		}
	}
	handleAsunto(event) {
		this.asunto = event.target.value;
		this.subjectToSend = this.asunto;
		this.sendEventInfoToParent();
	}

	handleChangeApoderado(event) {
		this.apoderado = event.detail.value;
		this.datosPersonaContacto.forEach(pc => {
			if (pc.Id === this.apoderado) {
				this.phoneField = pc.Phone != null ? pc.Phone : pc.Account.CIBE_Movil__c;
			}
		})
		this.sendEventInfoToParent();
	}

	handleChangeEstado(event) {
		this.estadoPorDefecto = event.detail.value;
		this.sendEventInfoToParent();
	}

	handleConfidencial(event) {
		this.confidencial = event.target.checked;
		this.sendEventInfoToParent();
	}

	handleOportunidades(event) {
		this.noOportunidades = event.target.checked;
		this.sendEventInfoToParent();
	}

	handleComentarios(event) {
		this.comentarios = event.target.value;
		this.sendEventInfoToParent();
	}

	makeCall(calledDevice) {
		const mess = this.labels.CIBE_LlamadaFallida;
		if (!calledDevice || calledDevice == null) {
			this.showToast('Error', mess, 'error');
			console.log(error);
			this.isShowSpinner = false;
			return;
		}
		c2cMakeCall({ calledDevice: calledDevice })
			.then(result => {
				const [typeMessage, message] = result;
				this.showToast(typeMessage, message, typeMessage);
				this.isShowSpinner = false;
			})
			.catch(error => {
				console.log('Error:', error);
				this.showToast('Error', mess, 'error');
				this.isShowSpinner = false;
			});
	}

	handleChangeDuration(e) {
		this.durationToSend = parseInt(e.target.value);
		this.initialDuration = e.target.value;
		var iniDate = new Date(this.activityDateToSend + ' ' + this.horaActual);
		iniDate.setHours(iniDate.getHours(), iniDate.getMinutes() + this.durationToSend, '00');
		this.timeFin = this.setHours(iniDate.getHours()) + ':' + this.setHours(iniDate.getMinutes());

		this.sendEventInfoToParent();
	}

	handleChangeTimeFin(e) {
		this.timeFin = e.target.value;
		var iniDate = new Date(this.activityDateToSend + ' ' + this.timeInicio);
		var finDate = new Date(this.activityDateToSend + ' ' + this.timeFin);
		var numDiff = finDate.getTime() - iniDate.getTime();
		numDiff /= (1000 * 60);
		if (numDiff != 5 && numDiff != 15 && numDiff != 30 && numDiff != 60 && numDiff != 120) {
			this.durationToSend = 0;
		} else {
			this.durationToSend = numDiff;
		}
		this.sendEventInfoToParent();
	}

	handleChangeTimeInicio(e) {
		this.horaActual = e.target.value;
		var iniDate = new Date(this.activityDateToSend + ' ' + this.timeInicio);
		var finDate = new Date(this.activityDateToSend + ' ' + this.timeFin);
		var numDiff = finDate.getTime() - iniDate.getTime();
		numDiff /= (1000 * 60);
		if (numDiff != 5 && numDiff != 15 && numDiff != 30 && numDiff != 60 && numDiff != 120) {
			this.durationToSend = 0;
		} else {
			this.durationToSend = numDiff;
		}
		this.sendEventInfoToParent();
	}
}