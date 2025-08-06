import { LightningElement, api, wire, track } from 'lwc';
import USER_ID from '@salesforce/user/Id';
import NAME from '@salesforce/schema/User.Name';
import CENTER from '@salesforce/schema/User.AV_NumeroOficinaEmpresa__c';
import { getRecord } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import ISBPR from '@salesforce/customPermission/AV_PrivateBanking';

import searchEmployee from '@salesforce/apex/CIBE_NewEventController.searchEmployees';
import getContactosApoderados from '@salesforce/apex/CIBE_NewEventController.getContactosApoderados';
import getContactoPrincipal from '@salesforce/apex/CIBE_NewEventController.getContactoPrincipal';
import searchCXB from '@salesforce/apex/CIBE_NewEventController.searchUserCXB';
import searchEMP from '@salesforce/apex/CIBE_NewEventController.searchUserEMP';
import searchUserTeamCXB from '@salesforce/apex/CIBE_NewEventController.searchUserTeamCXB';
import getGrupoComercial from '@salesforce/apex/CIBE_NewEventController.getGrupoComercial';
import getAsistentesEmp from '@salesforce/apex/CIBE_NewEventController.getAssistEMP';


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

//asistente no reg
import addEmpresaGrupo from '@salesforce/label/c.CIBE_AddEmpresaGrupo';
import escribirEmail from '@salesforce/label/c.CIBE_EscribirEmail';
import asistentesNoRegistrados from '@salesforce/label/c.CIBE_AsistentesNoRegistrados';
import anyadir from '@salesforce/label/c.CIBE_Add';
import nombre from '@salesforce/label/c.CIBE_Nombre';
import email from '@salesforce/label/c.CIBE_Email';
import tipoAsistente from '@salesforce/label/c.CIBE_TipoAsistente';
import enviarCita from '@salesforce/label/c.CIBE_EnviarCita';
import SobjectType from '@salesforce/schema/RecordType.SobjectType';

//modificaciones fusion gestion agil y nueva cita 15/10/2024
import customCss from '@salesforce/resourceUrl/CustomCssRecordForm';
import { loadStyle } from 'lightning/platformResourceLoader';
import llamadaFallida from '@salesforce/label/c.CIBE_LlamadaFallida'
import c2cMakeCall from '@salesforce/apex/AV_SObjectRelatedInfoCController.c2cMakeCall';




export default class cibe_NewEventReportDetail extends LightningElement {

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
		escribirEmail,
		asistentesNoRegistrados,
		anyadir,
		nombre,
		email,
		tipoAsistente,
		enviarCita,
		llamadaFallida,
		addEmpresaGrupo

	}

	//variables para cibe_newEventTab
	@api clientinfo;//Contiene el id y el nombre del cliente
	@api issummary;
	@api timeinfo;
	@api recordId;
	@api clientname;

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
	selectedAttendesToSendId = [];

	typeToSend;
	accountName;
	employeeName;
	contactPersonName;
	attendeesNamesEMP;
	attendeesNamesCXB;
	officeName;
	typeName;
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
	showSpinner = true;

	@track selectedAttendesCXB = [];
	multiSelectionAttendeeCXB = 0;

	@track selectedAttendesEMP = [];
	multiSelectionAttendeeEMP = 0;

	@track confidencial = false;
	@track noOportunidades = false;
	@track asunto;
	//asunto;
	@track optionsApoderados;
	@track apoderado = 'sinContacto';
	@track apoderadoName;
	@track sinApoderado = false;
	@track noRegistrado;
	valueRadioButton = 'VC';
	@track ubicacion = true;
	@track ubicacionText;
	selectedItem;
	@track comentarios;
	@track empresaGr = false;
	@track lstGrpsEMP = [];


	@track initialSelection = [];
	@track apoderadosAttendes = [];
	@track attendeeSelectionName;
	selectedRows;
	@track selectedIds = [];

	//ass no reg
	buttonDisabledAttendees = true;
	@track email;
	// @track selectedAttendes = [];
	selectedAttendes = [];
	añadirAttende = false;
	// @track preSelectedRows = [];
	@track selectedData = [];
	@track currentlySelectedData = [];
	@track attendeData = [];
	noRegistrado = false;
	multiSelectionAttNoReg = 0;

	@track optionsGC;
	@track empresaGCSel;
	@track selectedClientsGC = [];
	@track clienteGCName;

	today = new Date().toJSON().slice(0, 10);


	//emoji para añadir al asunto:

	llamadaEmoji = '☎️ ';;
	citaOficinaEmoji = '🏢 ';
	citaTelefonicaEmoji = '📱 ';
	videollamadaEmoji = '📹 ';
	citaEnOtraOficinaEmoji = '📍 ';
	visitaClienteEmoji = '💼 ';
	emojiCita;
	asuntoSinEmoji;


	renderComponent = false;
	mapType = {
		'VC': 'Visita cliente',
		'EC': 'Entrevista centro',
		'LMD': 'Llamada',
		'VLD': 'Videollamada'
	}

	connectedCallback() {
		if (this.clientinfo) {
			this.renderComponent = true;
			if (this.showSpinner) {
				this.showSpinner = false;
			}
			this.selectedIds.push(this.clientinfo.accountId);
			this.selectedClientsGC.push({ id: this.clientinfo.accountId, value: this.clientinfo.name });
		}
	}

	renderedCallback() {
		this.sendEventInfoToParent();
	}

	@wire(getRecord, { recordId: USER_ID, fields: [NAME, CENTER] })
	wiredUser({ error, data }) {

		if (data && this.clientinfo != null && this.initialclient == null) {
			this.initialemployee = [{ id: USER_ID, title: data.fields.Name.value, icon: 'standard:account' }]; // gestor emp
			this.initialclient = [{ id: this.clientinfo.accountId, title: this.clientinfo.name, icon: 'standard:user' }];
			this.accountName = this.clientinfo.name;
			this.employeeName = data.fields.Name.value;
			this.clientToSend = this.clientinfo.accountId;
			this.selectedItem = 'LMD';
			this.checkContactType();
			this.asuntoSinEmoji = this.initialclient[0].title + ' - Caixabank ';
			this.emojiCita = this.setIconCita(this.selectedItem);
			this.asunto = this.emojiCita + this.asuntoSinEmoji;
			this.subjectToSend = this.asunto;
			this.renderComponent = true;
			if (this.showSpinner) {
				this.showSpinner = false;
			}
			this.sendEventInfoToParent();

		} else if (error) {
			this.error = error;
		}
	}


	setIconCita(eventType) {
		if (eventType === 'LMD') {
			return this.llamadaEmoji;
		} else if (eventType === 'VLD') {
			return this.videollamadaEmoji;
		} else if (eventType === 'VC') {
			return this.visitaClienteEmoji;
		} else if (eventType === 'EC') {
			return this.citaOficinaEmoji;
		}
		return ''

	}

	handleSearchEmployee(e) {
		searchEmployee({ searchTerm: e.detail.searchTerm })
			.then(result => {
				if (result != null) {
					this.template.querySelector('[data-id="employeelookup"]').setSearchResults(result);
				}
			}).catch(error => {
				console.error(error);
			});
	}

	handleSelectionEmployee() {
		this.employeeToSend = null;
		let employeeSelection = this.template.querySelector('[data-id="employeelookup"]').getSelection()[0];

		if (employeeSelection != null && employeeSelection != undefined) {
			this.employeeToSend = employeeSelection.id;
			this.employeeName = employeeSelection.title;
			this.initialemployee = [{ id: employeeSelection.id, title: employeeSelection.title, icon: 'standard:account' }];

			this.sendEventInfoToParent();
		} else {
			this.employeeToSend = null;
			this.employeeName = null;
			this.sendEventInfoToParent();
		}
	}

	handleSearchClick(e) {
		let targetId = e.target.dataset.id;
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
		searchCXB({ searchTerm: e.detail.searchTerm, selectedIds: this.selectedAttendesToSendId })
			.then((results) => {
				this.template.querySelector('[data-id="attendeeslookupCXB"]').setSearchResults(results);

			})
			.catch((error) => {
				console.error(error);
				this.errors = [error];
			});
	}


	handleSelectionAttendee(e) {
		let targetId = e.target.dataset.id;
		let attendeeLookup = this.template.querySelector(`[data-id="${targetId}"]`);
		let attendeeSelection = attendeeLookup.getSelection()[0];
		if (attendeeSelection != null && attendeeSelection != undefined) {
			const alreadySelected = this.selectedAttendesCXB.some(item => item.id === attendeeSelection.id);
			if (!alreadySelected) {
				this.selectedAttendesCXB.push({
					id: attendeeSelection.id,
					label: attendeeSelection.title,
					bucleId: ++this.multiSelectionAttendeeCXB
				});
			}
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
		attendeeLookup.handleBlur();
		this.removeFocus();

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
		searchEMP({ searchTerm: e.detail.searchTerm, selectedIds: this.selectedAttendesToSendId, cliente: this.clientToSend })
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
			const alreadySelected = this.selectedAttendesEMP.some(item => item.id === attendeeSelection.id);
			if (!alreadySelected) {
				this.selectedAttendesEMP.push({
					id: attendeeSelection.id,
					label: attendeeSelection.title,
					bucleId: ++this.multiSelectionAttendeeEMP
				});
			}

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
		this.removeFocus();
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

	handleRemoveAttendeNR(e) {
		let idToDel = e.target.name;
		const indexToRemove = this.selectedAttendes.findIndex(attende => attende.id === idToDel);
		if (indexToRemove !== -1) {
			this.selectedAttendes.splice(indexToRemove, 1);
			this.attendeData.splice(indexToRemove, 1);
		}

		this.sendEventInfoToParent();

	}
	handleRemoveAttendeGC(e) {
		let idToDel = e.target.name;
		this.clienteGCName = '';

		for (let i = 0; i < this.selectedClientsGC.length; i++) {
			if (this.selectedClientsGC[i].id === idToDel) {

				this.selectedClientsGC.splice(i, 1);
				break;
			}

			if (i == this.selectedClientsGC.length - 1) {
				this.clienteGCName = this.clienteGCName + this.selectedClientsGC[i].label;
			} else {
				this.clienteGCName = this.clienteGCName + this.selectedClientsGC[i].label + ', ';
			}
		}
		console.log('this.selectedIds ', this.selectedIds);
		this.selectedIds = this.selectedIds.filter(sel => sel !== idToDel);
		this.selectedIds = [...this.selectedIds];
		console.log('this.selectedIds ', this.selectedIds);
		this.sendEventInfoToParent();
		this.attendesEMP = this.selectedClientsGC.length > 0
	}

	sendEventInfoToParent() {
		if (this.selectedAttendesCXB.length > 0) {
			this.selectedAttendesCXB.forEach(att => {
				if (this.selectedAttendesToSendId === undefined || !this.selectedAttendesToSendId.includes(att.id)) {
					this.selectedAttendesToSend.push(att);
					this.selectedAttendesToSendId.push(att.id);
				}
			});
		}

		if (this.selectedAttendesEMP.length > 0) {
			this.selectedAttendesEMP.forEach(att => {
				if (this.selectedAttendesToSendId === undefined || !this.selectedAttendesToSendId.includes(att.id)) {
					this.selectedAttendesToSend.push(att);
					this.selectedAttendesToSendId.push(att.id);
				}
			});
		}

		//no-reg
		if (this.attendeData.length > 0) {
			this.attendeData.forEach(att => {
				if (this.selectedAttendesToSend === undefined || !this.selectedAttendesToSend.includes(att)) {
					this.selectedAttendesToSend.push(att);
				}
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
					selectedClients: this.selectedClientsGC,
					selectedClientsId: this.selectedIds
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


	@wire(getContactoPrincipal, { accountId: '$clientinfo.accountId', lstAccountId: '$selectedIds' })
	getContactoPrincipal(result) {
		console.log('this.selectedIds ', this.selectedIds);
		console.log('wire  result', result);
		if (result.data) {
			let options = [];
			this.getDefaultMainContactList(result.data);
			result.data.forEach(element => {
				this.datosPersonaContacto = result.data;
				if (element.Contact.RecordType.DeveloperName === 'CIBE_ContactoComercial') {
					options.push({ label: element.Contact.Name + ' - Cont. comercial - ' + element.Contact.Account.Name, value: element.Contact.Id });
				} else if (element.Contact.RecordType.DeveloperName === 'CIBE_Apoderado' && element.Contact.CIBE_Carrec__c !== '00016' && (element.Contact.CIBE_FechaVencimiento__c >= this.today || element.Contact.CIBE_FechaVencimiento__c == null)) {
					options.push({ label: element.Contact.Name + ' - Apoderado - ' + element.Contact.Account.Name, value: element.Contact.Id });
				} else if (element.Contact.RecordType.DeveloperName === 'CIBE_Apoderado' && element.Contact.CIBE_Carrec__c === '00016' || (element.Contact.CIBE_FechaVencimiento__c < this.today)) {
					options.push({ label: element.Contact.Name + ' - Cont. comercial - ' + element.Contact.Account.Name, value: element.Contact.Id });
				}

			});

			options.push({ label: '', value: 'sinContacto' });
			this.optionsApoderados = options;

		} else if (result.error) {
			console.error(result.error);
		}
	}


	handleUbicacion(event) {
		this.ubicacionText = event.target.value;
		this.sendEventInfoToParent();
	}

	handleAsunto(event) {
		this.subjectToSend = '';
		this.subjectToSend = event.target.value;
		this.sendEventInfoToParent();
	}

	handleChangeApoderado(event) {
		this.apoderado = event.detail.value;
		this.apoderadoName = this.optionsApoderados.find(opt => opt.value === event.detail.value).label;

		if (this.apoderado === 'sinContacto') {
			this.sinApoderado = true;
		} else {
			this.sinApoderado = false;
		}
		this.datosPersonaContacto.forEach(pc => {
			if (pc.ContactId === this.apoderado) {
				this.phoneField = pc.Contact.Phone != null ? pc.Contact.Phone : pc.Contact.Account != null ? pc.Contact.Account.CIBE_Movil__c : '';
			}
		})
		this.sendEventInfoToParent();
	}



	handleChangeGC(event) {
		let labelClienteSelecionado;
		let idClienteSelecionado;

		this.empresaGCSel = event.detail.value;

		labelClienteSelecionado = this.optionsGC.find(opt => opt.value === event.detail.value).label;
		idClienteSelecionado = this.optionsGC.find(opt => opt.value === event.detail.value).value;
		if (idClienteSelecionado === 'todosClientes') {
			this.selectedClientsGC = [];
			this.selectedIds = [];
			this.selectedIds.push(this.clientinfo.accountId);
			this.selectedClientsGC.push({ id: this.clientinfo.accountId, value: this.clientinfo.name });
			this.optionsGC.forEach(opt => {
				if (opt.value !== idClienteSelecionado) {
					this.selectedClientsGC.push({ id: opt.value, value: opt.label });
					this.selectedIds.push(opt.value);
				}
			})
		} else {
			this.selectedClientsGC.push({ id: idClienteSelecionado, value: labelClienteSelecionado });
			// this.selectedIds.push(idClienteSelecionado);
			this.selectedIds = [...this.selectedIds, idClienteSelecionado]
		}
		this.sendEventInfoToParent();
	}

	handleConfidencial(event) {
		this.confidencial = event.target.checked;
		this.sendEventInfoToParent();
	}

	handleEmpresaGrupo(event) {
		this.empresaGr = event.target.checked;
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

	columns = [
		{ label: 'Nombre Cliente', fieldName: 'icon', type: 'url', typeAttributes: { label: { fieldName: 'subtitle' } }, initialWidth: 270, hideDefaultActions: true }
	]

	@track _wiredData;
	@wire(getGrupoComercial, { recordId: '$clientinfo.accountId' })
	getGrupoComercial(wiredData) {
		//GC
		this._wiredData = wiredData;
		const { data, error } = wiredData;
		this.totalPage = 1;
		let optionsAux = [];

		if (data) {
			optionsAux.push({ label: 'TODOS LOS CLIENTES', value: 'todosClientes' });
			this.data = data.map((item) => {
				const iconObj = { ...item };
				optionsAux.push({ label: item.subtitle, value: item.icon.replace('/', '') });
				return iconObj;
			});

			if (this.data[0] != undefined && this.data[0].nOpps != null) {
				this.totalPage = Math.ceil(this.data[0].nOpps / 10);
			}
			if (this.offSet === this.offSetUpdate) {
				this.page = 1;
				this.rowOffset = 0;
			}
			this.optionsGC = optionsAux;

			this.isLoading = false;
		} else if (error) {
			this.isLoading = false;
			console.error(error);
		} else {
			this.isLoading = false;
			this.totalPage = 1;
		}
	}


	//ADD ASISTENTES NO reg

	handleEnter(event) {
		if (event.keyCode === 13) {
			const emailInput = this.template.querySelector('lightning-input[data-id="email"]');
			let validation = emailInput.checkValidity();
			if (!validation) {
				emailInput.reportValidity();
			} else {
				emailInput.reportValidity();
				this.handleEmailEnter();
			}
		}
	}


	handleEmail(event) {
		this.email = event.target.value;
	}

	handleEmailEnter() {
		let contador = Math.floor(Math.random() * 100);
		if (this.email !== null && this.selectedItem !== 'VLD') {
			let objEmail = {
				id: 'Idprovisional' + contador,
				email: this.email,
				tipoAsistente: 'No registrado',
				bucleId: ++this.multiSelectionAttNoReg
			}
			this.selectedAttendes.push(objEmail);
			this.attendeData.push(objEmail);
		} else if (this.email !== null && this.selectedItem === 'VLD') {
			let objEmailVLD = {
				id: 'Idprovisional' + contador,
				label: this.email,
				bucleId: ++this.multiSelectionAttNoReg
			}
			this.selectedAttendes.push(objEmailVLD);
			this.attendeData.push(objEmail);
		}
		this.sendEventInfoToParent();
		this.email = null;
	}


	//modificaciones fusión gestion agil y nueva cita:

	// variables:
	gestionSC = false;
	initialDuration;//la duración que tendrá la cita en función del tipo de cita seleccionado.
	//This variable can be set to false if the selected appointment type does not generate an event to hide certain fields. For example, email, wall and management without commercial contact.
	hideFieldsWhenNoEvent = false;
	phoneField;

	/**
	  * Loads from the static resources a css that allows to style the radio-group to look horizontal.
	  */
	renderedCallback() {
		Promise.all([
			loadStyle(this, customCss)
		])
	}

	/**
	 * each of the radio-group options and their values.
	 */
	get contactTypeOptions() {
		return [
			{ label: 'Visita cliente', value: 'VC' },
			{ label: 'Entrevista centro', value: 'EC' },
			{ label: 'LLamada', value: 'LMD' },
			{ label: 'Videollamada', value: 'VLD' },
			{ label: 'Email, sms, etc.', value: 'ESE' },
			{ label: 'Muro', value: '030' },
			{ label: 'Gestión sin contacto comercial', value: 'GSCC' }
		];
	}

	/**
	 * This method is triggered each time an option is changed in the radio-group.
	 * @param {*} event with the current value of the selection
	 */
	handleChangeContactType(event) {
		this.selectedItem = event.detail.value;
		this.checkContactType();
		this.emojiCita = this.setIconCita(this.selectedItem);
		this.asunto = this.emojiCita + this.asuntoSinEmoji;
		this.subjectToSend = this.asunto;
		this.sendEventInfoToParent();

	}


	checkContactType() {
		if (this.selectedItem === 'EC' || this.selectedItem === 'VC') {
			this.initialDuration = '60';
			this.showOfficeNumber = this.selectedItem === 'EC' ? true : false;
		} else if (this.selectedItem === 'LMD' || this.selectedItem === 'VLD') {
			this.initialDuration = '30';
			this.showOfficeNumber = false;
		}

		if (this.selectedItem !== 'VC') {
			this.ubicacion = false;
		} else if (this.selectedItem === 'VC') {
			this.ubicacion = true;
			this.showOfficeNumber = false;
		}
		if (this.selectedItem == 'ESE' || this.selectedItem == '030') {
			// this.issummary = false;
			this.hideFieldsWhenNoEvent = true;
			this.showOfficeNumber = false;
			this.gestionSC = false;
		} else if (this.selectedItem == 'GSCC') {
			// this.issummary = false;
			this.hideFieldsWhenNoEvent = true;
			this.gestionSC = true;
			this.showOfficeNumber = false;

		} else {
			// this.issummary = false;
			this.hideFieldsWhenNoEvent = false;
			this.gestionSC = false;
		}
	}

	//click to call
	handlePhone() {
		if (this.phoneField) {
			this.makeCall(this.phoneField);
		}
	}

	makeCall(calledDevice) {
		c2cMakeCall({ calledDevice: calledDevice })
			.then(result => {
				const [typeMessage, message] = result;
				this.showToast(typeMessage, message, typeMessage);
				this.showSpinner = false;
			})
			.catch(error => {
				console.error('Error:', error);
				this.showToast('Error', this.labels.CIBE_LlamadaFallida, 'error');
				this.showSpinner = false;
			});
	}


	getDefaultMainContactList(contactList) {
		getAsistentesEmp({ contacts: contactList })
			.then(result => {
				if (result) {
					this.defaultContactList = result;
				}
			})
			.catch(error => {
				console.log('error ', error)
			})
	}

	setDefaultContactList() {
		this.template.querySelector('[data-id="attendeeslookupEMP"]').setSearchResults(this.defaultContactList);
	}

	removeFocus() {
		const boton = this.template.querySelector('[data-id="invisibleButton"]');
		if (boton) {
			boton.focus();
		}
	}

}