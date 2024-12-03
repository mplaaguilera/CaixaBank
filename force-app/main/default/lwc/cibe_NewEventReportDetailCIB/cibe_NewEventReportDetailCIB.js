import { LightningElement, api, wire, track } from 'lwc';
import USER_ID from '@salesforce/user/Id';
import NAME from '@salesforce/schema/User.Name';
import CENTER from '@salesforce/schema/User.AV_NumeroOficinaEmpresa__c';
import { getRecord } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import ISBPR from '@salesforce/customPermission/AV_PrivateBanking';
import { refreshApex } from '@salesforce/apex';

import searchEmployee from '@salesforce/apex/CIBE_NewEventController.searchEmployees';
// import getContactosApoderados from '@salesforce/apex/CIBE_NewEventController.getContactosApoderados';
import searchCXB from '@salesforce/apex/CIBE_NewEventController.searchUserCXB';
import searchUserTeamCXB from '@salesforce/apex/CIBE_NewEventController.searchUserTeamCXB';
import searchUserClientes from '@salesforce/apex/CIBE_NewEventCIBController.searchUserClientes';
import getPicklistValues from '@salesforce/apex/CIBE_NewEventCIBController.getRegardingPicklistValue';

import searchFamily from '@salesforce/apex/CIBE_NewOpportunity_Controller_CIB.searchFamily';
import searchProductsCIB from '@salesforce/apex/CIBE_NewOpportunity_Controller_CIB.search';
import getAccountSinCliente from '@salesforce/apex/CIBE_NewEventCIBController.getAccountSinCliente';

// import lookupSearchAccount from '@salesforce/apex/CIBE_MassReassignOwnerOpps_Controller.searchAccount';
import lookupSearchAccount from '@salesforce/apex/CIBE_NewOpportunity_Controller_CIB.searchCliente';

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
import llamadaTelefono from '@salesforce/label/c.CIBE_LlamadaTelefonica';
import videollamada from '@salesforce/label/c.CIBE_Videollamada';
import citaSinVincular from '@salesforce/label/c.CIBE_CitaSinVincular';
import organizador from '@salesforce/label/c.CIBE_Organizador';
import asistentesCaixa from '@salesforce/label/c.CIBE_AsistentesCaixabank';
import escribeAqui from '@salesforce/label/c.CIBE_EscribeAqui';
import entidad from '@salesforce/label/c.CIBE_Entidad';

import ofiCliente from '@salesforce/label/c.CIBE_OficinasCliente';
import ofiCaixabank from '@salesforce/label/c.CIBE_OficinaCaixabank';
import buscaEmpleado from '@salesforce/label/c.CIBE_BuscaEmpleado';
import asuntoCita from '@salesforce/label/c.CIBE_AsuntoCita';
import asistentes from '@salesforce/label/c.CIBE_Asistentes';
import asistentesNoRegistrados from '@salesforce/label/c.CIBE_AsistentesNoRegistrados';
import escribirEmail from '@salesforce/label/c.CIBE_EscribirEmail';
import anyadir from '@salesforce/label/c.CIBE_Add';
import producto from '@salesforce/label/c.CIBE_Producto';
import familia from '@salesforce/label/c.CIBE_Familia';
import buscarFamilia from '@salesforce/label/c.CIBE_BuscarFamilia';
import buscarProducto from '@salesforce/label/c.CIBE_BuscarProductos';
import comentarioProducto from '@salesforce/label/c.CIBE_IntroduzcaCommentarioProducto';
import asistentesClientes from '@salesforce/label/c.CIBE_AsistentesClientes';
import nombre from '@salesforce/label/c.CIBE_Nombre';
import email from '@salesforce/label/c.CIBE_Email';
import tipoAsistente from '@salesforce/label/c.CIBE_TipoAsistente';
import enviarCita from '@salesforce/label/c.CIBE_EnviarCita';
import descripcion from '@salesforce/label/c.CIBE_Descripcion';
import Otradescripcion from '@salesforce/label/c.CIBE_OtrDescripcion';
import client from '@salesforce/label/c.CIBE_ClienteTarea';


export default class cibe_NewEventReportDetailCIB extends LightningElement {

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
		llamadaTelefono,
		videollamada,
		citaSinVincular,
		organizador,
		asistentesCaixa,
		escribeAqui,
		ofiCliente,
		ofiCaixabank,
		buscaEmpleado,
		asuntoCita,
		asistentes,
		asistentesNoRegistrados,
		escribirEmail,
		anyadir,
		producto,
		familia,
		buscarFamilia,
		buscarProducto,
		comentarioProducto,
		asistentesClientes,
		nombre,
		email,
		tipoAsistente,
		enviarCita,
		descripcion,
		Otradescripcion,
		client

	}

	@api clientinfo;//Contiene el id y el nombre del cliente
	@api issummary;
	@api timeinfo;

	@api recordId;
	@api clientname;
	@api showsincliente;
	showAccountInput = false;


	initialemployee;
	error;
	initialclient = [];
	initialAccount = null;
	//variables de input

	clientToSend;
	noComercial = false;
	employeeToSend = USER_ID;
	centerToSend;
	contactToSend;
	attendesToSend = [];
	subjectToSend;
	comentaryToSend;
	@track selectedAttendesToSend = [];
	typeToSend;
	ubicationToSend;
	accountName;
	employeeName;
	contactPersonName;
	attendeesNamesEMP;
	attendeesNamesCXB;
	officeName;
	typeName;

	officeToSend;
	otherOfficeNumberToSend;
	memorableInterviewToSend = false;
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

	/////////////////////////////////
	@track selectedAttendes = [];
	añadirAttende = false;
	añadirProduct = false;
	@track attendeData = [];
	noRegistrado = false;
	buttonDisabled = true;
	buttonDisabledAttendees = true;
	@track email;
	@track selectedId = [];
	@track selectedIdFamilia = [];
	@track selectedFamilia = [];
	@track selectedIdProduct = [];
	@track selectedProduct = [];
	@track attendeProducts = [];
	@track productComment;
	@track selectedProductToSend = [];




	@track confidencial = false;
	@track noOportunidades = false;
	@track asunto; //this.clientinfo?.name;
	// @track optionsApoderados;
	// @track apoderadoName;
	@track sinApoderado = false;
	@track noRegistrado;
	@track ubicacion = true;
	@track ubicacionText;
	selectedItem = 'VLD';
	@track comentarios;

	@track initialSelection = [];

	// @track apoderadosAttendes = [];

	@track attendeeSelectionName


	@track asuntoCita = false;
	@track picklistValues;

	mapType = {
		'LT': 'Llamada telefónica',
		'OCL': 'Oficinas Cliente',
		'OCX': 'Oficinas CaixaBank',
		'VLD': 'Videollamada'
	}

	@track producto;
	@track initialSelection = [];
	@track valueSubProducto;
	@track accountSinclienteName;
	@track accountSinclienteId;

	readyToRender = false;

	@wire(getRecord, { recordId: USER_ID, fields: [NAME, CENTER] })
	wiredUser({ error, data }) {
		if (data && this.clientinfo) {
			this.initialemployee = [{ id: USER_ID, title: data.fields.Name.value, icon: 'standard:user' }]; // gestor emp

			if (this.showsincliente !== undefined) {
				if (this.showsincliente) {
					this.getSinClienteAcc();
					this.showAccountInput = false;
				} else {
					this.showAccountInput = true;
					this.initialclient = [];
				}
			} else {
				this.initialclient = [{ id: this.clientinfo.accountId, title: this.clientinfo.name, icon: 'standard:account' }];
			}

			this.accountName = this.clientinfo.name;
			this.employeeName = data.fields.Name.value;
			this.clientToSend = this.clientinfo.accountId;
			this.selectedItem = 'VLD';
			this.typeName = this.mapType[this.selectedItem];
			this.readyToRender = true;
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
		this.employeeToSend = null;
		let employeeSelection = this.template.querySelector('[data-id="employeelookup"]').getSelection()[0];

		if (employeeSelection != null && employeeSelection != undefined) {
			this.employeeToSend = employeeSelection.id;
			this.employeeName = employeeSelection.title;
			this.initialemployee = [{ id: employeeSelection.id, title: employeeSelection.title, icon: 'standard:account' }];
			//this.centerToSend = employeeSelection.subtitle.split('-')[1];
			this.sendEventInfoToParent();
		} else {
			this.employeeToSend = null;
			this.employeeName = null;
			//this.centerToSend = null;
			this.sendEventInfoToParent();
		}


	}

	handleSearchAttendes(e) {

		searchCXB({ searchTerm: e.detail.searchTerm, selectedIds: this.selectedId })
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
		this.añadirAttende = true;
		attendeeLookup.handleClearSelection();

		if (attendeeSelection != null && attendeeSelection != undefined) {
			this.buttonDisabled = false;
			this.selectedAttendes.push({
				id: attendeeSelection.id,
				name: attendeeSelection.title,
				email: attendeeSelection.subtitle,
				tipoAsistente: 'CaixaBank',
				enviarCita: true
			}
			);
		}

		this.selectedAttendes.forEach(element => {

			if (this.selectedItem == 'VLD') {
				var myId = element.id;
				this.preSelectedRows = [...this.preSelectedRows, myId];
			} else if (element.tipoAsistente == 'CaixaBank') {
				var myId = element.id;
				this.preSelectedRows = [...this.preSelectedRows, myId];
			}

			var myId = element.id;
			this.selectedId = [...this.selectedId, myId];

			this.attendeData = [...this.attendeData, element];
			this.selectedAttendes = this.selectedAttendes.filter((i) => i.nombre === element.id);

		});

		this.sendEventInfoToParent();

	}


	handleSearchFamily(e) {
		searchFamily({ searchTerm: e.detail.searchTerm, producto: this.valueSubProducto })
			.then((results) => {
				this.template.querySelector('[data-id="familySearch"]').setSearchResults(results);
			})
			.catch((error) => {
				console.error(error);
				this.errors = [error];
			});
	}

	handleFamily(event) {
		let targetId = event.target.dataset.id;
		const selection = this.template.querySelector(`[data-id="${targetId}"]`).getSelection();
		this.buttonDisabled = false;

		if (selection.length !== 0) {
			for (let sel of selection) {
				this.producto = String(sel.id);
			}
		} else {
			this.producto = null;
			this.template.querySelector('[data-id="familySearch"]').selection = [];
			this.template.querySelector('[data-id="familySearch"]').handleBlur();
		}
		this.template.querySelector('[data-id="familySearch"]').handleBlur();
	}


	handleSearchFamilyClick(e) {
		if (this.producto == null) {
			searchFamily({ searchTerm: e.detail.searchTerm, producto: null })
				.then((results) => {
					this.template.querySelector('[data-id="familySearch"]').setSearchResults(results);
				})
				.catch((error) => {
					console.error(error);
					this.errors = [error];
				});
		}

	}

	handleSearchProduct(e) {
		searchProductsCIB({ searchTerm: e.detail.searchTerm, familia: this.producto })
			.then((results) => {
				this.template.querySelector('[data-id="productSearch"]').setSearchResults(results);
			})
			.catch((error) => {
				console.error(error);
				this.errors = [error];
			});
	}


	handleSearchProductClick(e) {
		if (this.valueSubProducto == null) {
			searchProductsCIB({ searchTerm: e.detail.searchTerm, familia: this.producto })
				.then((results) => {
					this.template.querySelector('[data-id="productSearch"]').setSearchResults(results);
				})
				.catch((error) => {
					console.error(error);
					this.errors = [error];
				});
		}

	}


	handleProduct(event) {
		let targetId = event.target.dataset.id;
		const selection = this.template.querySelector(`[data-id="${targetId}"]`).getSelection();
		this.buttonDisabled = false;

		if (selection.length !== 0) {
			for (let sel of selection) {
				this.valueSubProducto = String(sel.id);
			}
			this.autoSelectFamily(this.valueSubProducto);
		} else {
			this.valueSubProducto = null;
			this.template.querySelector('[data-id="productSearch"]').handleBlur();
		}
	}

	autoSelectFamily(valueProducto) {
		searchFamily({ searchTerm: '', producto: valueProducto })
			.then((results) => {
				let targetId = results[0].id;
				this.producto = targetId;
				this.template.querySelector('[data-id="familySearch"]').selection = results[0];
			})
			.catch((error) => {
				console.error('Lookup error', JSON.stringify(error));
				this.errors = [error];
			});
	}

	@track prueba;

	handleChangeSubject(e) {
		this.subjectToSend = e.target.value;

		if (this.subjectToSend === 'Otros') {
			this.asuntoCita = true;
		} else {
			this.asuntoCita = false;
		}

		this.sendEventInfoToParent();
	}

	sendEventInfoToParent() {
		this.selectedAttendesToSend = [];
		if (this.attendeData.length > 0) {
			this.attendeData.forEach(att => {
				this.selectedAttendesToSend.push(att);
			});
		}

		this.selectedProductToSend = [];
		if (this.attendeProducts.length > 0) {
			this.attendeProducts.forEach(att => {
				this.selectedProductToSend.push(att);
			});
		}

		this.dispatchEvent(
			new CustomEvent('eventinfo', {
				detail: {
					owner: this.employeeToSend,
					attendes: this.selectedAttendesToSend,
					subject: this.subjectToSend,
					subjectExtend: this.asunto,
					confidencial: this.confidencial,
					tipoCita: this.selectedItem,
					comentarios: this.comentarios,
					client: this.initialclient.length > 0 && (this.initialclient[0].id !== undefined) ? this.initialclient[0].id : this.accountSinclienteId,
					product: this.selectedProductToSend
				}
			}
			)
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

	handleRadioChange(event) {
		this.selectedItem = event.target.value;
		this.typeName = this.mapType[this.selectedItem];

		this.sendEventInfoToParent();
	}

	handleAsunto(event) {
		this.asunto = event.target.value;
		this.sendEventInfoToParent();
	}

	handleConfidencial(event) {
		this.confidencial = event.target.checked;
		this.sendEventInfoToParent();
	}


	handleComentarios(event) {
		this.comentarios = event.target.value;
		this.sendEventInfoToParent();
	}

	handleSearchAttendes3(e) {

		searchUserClientes({ searchTerm: e.detail.searchTerm, selectedIds: this.selectedId, recordId: this.initialclient[0].id })
			.then((results) => {
				this.template.querySelector('[data-id="attendeeslookupClientes"]').setSearchResults(results);
			})
			.catch((error) => {
				console.error(error);
				this.errors = [error];
			});
	}

	handleSelectionAttendee3() {
		let attendeeLookup = this.template.querySelector('[data-id="attendeeslookupClientes"]');
		let attendeeSelection = attendeeLookup.getSelection()[0];
		this.añadirAttende = true;
		attendeeLookup.handleClearSelection();

		if (attendeeSelection != null && attendeeSelection != undefined && this.selectedItem !== 'VLD') {
			this.buttonDisabled = false;
			this.selectedAttendes.push({
				id: attendeeSelection.id,
				name: attendeeSelection.title,
				email: attendeeSelection.subtitle,
				tipoAsistente: 'Cliente'
			}
			);
		} else if (attendeeSelection != null && attendeeSelection != undefined && this.selectedItem == 'VLD') {
			this.buttonDisabled = false;
			this.selectedAttendes.push({
				id: attendeeSelection.id,
				name: attendeeSelection.title,
				email: attendeeSelection.subtitle,
				tipoAsistente: 'Cliente',
				enviarCita: true
			}
			);
		}

		this.selectedAttendes.forEach(element => {

			if (this.selectedItem == 'VLD') {
				var myId = element.id;
				this.preSelectedRows = [...this.preSelectedRows, myId];
			} else if (element.tipoAsistente == 'CaixaBank') {
				var myId = element.id;
				this.preSelectedRows = [...this.preSelectedRows, myId];
			}

			var myId = element.id;
			this.selectedId = [...this.selectedId, myId];

			this.attendeData = [...this.attendeData, element];
			this.selectedAttendes = this.selectedAttendes.filter((i) => i.nombre === element.id);

		});

		this.sendEventInfoToParent();

	}

	@track preSelectedRows = [];


	handleClick() {

		this.añadirAttende = true;
		let attendeeLookup = this.template.querySelector('[data-id="attendeeslookupClientes"]');
		let attendeeLookup2 = this.template.querySelector('[data-id="attendeeslookupCXB"]');
		let email = this.template.querySelector('[data-id="email"]').value;
		attendeeLookup.handleClearSelection();
		attendeeLookup2.handleClearSelection();
		this.buttonDisabledAttendees = true;
		let contador = Math.floor(Math.random() * 100);


		if (this.email != null && this.selectedItem !== 'VLD') {
			this.selectedAttendes.push({
				id: 'Idprovisional' + contador,
				email: email,
				tipoAsistente: 'No registrado'
			}
			);
		} else if (this.email != null && this.selectedItem == 'VLD') {
			this.selectedAttendes.push({
				id: 'Idprovisional' + contador,
				email: email,
				tipoAsistente: 'No registrado',
				enviarCita: true
			}
			);
		}


		this.selectedAttendes.forEach(element => {

			if (this.selectedItem == 'VLD') {
				var myId = element.id;
				this.preSelectedRows = [...this.preSelectedRows, myId];
			} else if (element.tipoAsistente == 'CaixaBank') {
				var myId = element.id;
				this.preSelectedRows = [...this.preSelectedRows, myId];
			}

			this.attendeData = [...this.attendeData, element];
			this.selectedAttendes = this.selectedAttendes.filter((i) => i.nombre === element.id);

			this.sendEventInfoToParent();

		});

		this.email = null;

	}

	handleClickProduct() {
		this.añadirProduct = true;
		let familylookup = this.template.querySelector('[data-id="familySearch"]');
		let familySelection = familylookup.getSelection()[0];
		let productlookup = this.template.querySelector('[data-id="productSearch"]');
		let productSelection = productlookup.getSelection()[0];
		this.buttonDisabled = false;

		this.template.querySelector('lightning-input[data-id="comentarioProduct"]').value = '';

		familylookup.handleClearSelection();
		productlookup.handleClearSelection();



		if ((familySelection != null && familySelection != undefined) && (productSelection != null && productSelection != undefined)) {
			this.selectedProduct.push({
				idFamilia: familySelection.id,
				nameFamilia: familySelection.title,
				idProducto: productSelection.id,
				nameProducto: productSelection.title,
				comentario: this.productComment
			}
			);
		}

		this.selectedProduct.forEach(element => {
			this.attendeProducts = [...this.attendeProducts, element];
			this.selectedProduct = this.selectedProduct.filter((i) => i.idProducto !== element.idProducto);

		});


		this.sendEventInfoToParent();
		this.productComment = null;
	}

	@track selectedData = [];
	@track currentlySelectedData = [];

	handleRowSelection(event) {
		switch (event.detail.config.action) {
			case 'selectAllRows':
				for (let i = 0; i < event.detail.selectedRows.length; i++) {
					this.selectedData.push(event.detail.selectedRows[i]);
					this.currentlySelectedData.push(event.detail.selectedRows[i]);
				}
				this.selectedData.forEach(element => {
					element.enviarCita = true;
				});
				break;
			case 'deselectAllRows':
				this.attendeData.forEach(element => {
					element.enviarCita = false;
				});
				break;
			case 'rowSelect':
				this.selectedData.push(event.detail.config.value);
				const found = this.attendeData.find((element) => element.id == this.selectedData);
				found.enviarCita = true;
				break;
			case 'rowDeselect':
				this.selectedData.push(event.detail.config.value);
				const found2 = this.attendeData.find((element) => element.id == this.selectedData);
				found2.enviarCita = false;
				break;
			default:
				break;
		}

		this.selectedData = [];

	}

	columns = [
		{ label: this.labels.enviarCita, fieldName: 'cita', type: 'Boolean', initialWidth: 150 },
		{ label: this.labels.nombre, fieldName: 'name' },
		{ label: this.labels.email, fieldName: 'email' },
		{ label: this.labels.tipoAsistente, fieldName: 'tipoAsistente' },
		{ label: '', type: 'button-icon', typeAttributes: { iconName: 'utility:delete', name: 'delete' }, initialWidth: 80 }
	];

	columnsProduct = [
		{ label: this.labels.familia, fieldName: 'nameFamilia' },
		{ label: this.labels.producto, fieldName: 'nameProducto' },
		{ label: this.labels.comentario, fieldName: 'comentario' },
		{ label: '', type: 'button-icon', typeAttributes: { iconName: 'utility:delete', name: 'deleteProduct' }, initialWidth: 80 }
	];


	handleRowAction(event) {
		if (event.detail.action.name === 'delete') {
			this.attendeData = this.attendeData.filter((i) => i.email !== event.detail.row.email);
			const found = this.selectedId.find((element) => element == event.detail.row.id);

			const index = this.selectedId.indexOf(found);

			if (index > -1) {
				this.selectedId.splice(index, 1);
			}

		}

		if (this.attendeData.length <= 0) {
			this.añadirAttende = false;
		}

		this.sendEventInfoToParent();
	}


	handleRowActionProduct(event) {
		if (event.detail.action.name === 'deleteProduct') {
			this.attendeProducts = this.attendeProducts.filter((i) => i.idProducto !== event.detail.row.idProducto);
		}

		if (this.attendeProducts.length <= 0) {
			this.añadirProduct = false;
		}

	}

	handleEmail(event) {
		this.email = event.target.value;
		const emailPattern = /^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$/;    // expresión regular utilizada para validar el formato del correo electrónico    
		let isValidEmail = emailPattern.test(this.email); // comprueba que this.email cumple la expresión regular

		if (this.email != null && isValidEmail == true) {
			this.buttonDisabledAttendees = false;
		} else {
			this.buttonDisabledAttendees = true;
		}
	}

	handleEmailEnter() {
		this.añadirAttende = true;
		let emailValue = this.template.querySelector('[data-id="email"]').value;
		let contador = Math.floor(Math.random() * 100);

		if (this.email != null && this.selectedItem !== 'VLD') {
			this.selectedAttendes.push({
				id: 'Idprovisional' + contador,
				email: emailValue,
				tipoAsistente: 'No registrado'
			}
			);
		} else if (this.email != null && this.selectedItem == 'VLD') {
			this.selectedAttendes.push({
				id: 'Idprovisional' + contador,
				email: emailValue,
				tipoAsistente: 'No registrado',
				enviarCita: true
			}
			);
		}

		this.selectedAttendes.forEach(element => {

			this.selectedId.push(element.id);

			if (this.selectedItem == 'VLD') {
				var myId = element.id;
				this.preSelectedRows = [...this.preSelectedRows, myId];
			} else if (element.tipoAsistente == 'CaixaBank') {
				var myId = element.id;
				this.preSelectedRows = [...this.preSelectedRows, myId];
			}

			this.attendeData = [...this.attendeData, element];
			this.selectedAttendes = this.selectedAttendes.filter((i) => i.nombre === element.id);

			this.sendEventInfoToParent();

		});

		this.email = null;

	}

	handleEnter(event) {
		const emailPattern = /^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$/;    // expresión regular utilizada para validar el formato del correo electrónico    
		let isValidEmail = emailPattern.test(this.email); // comprueba que this.email cumple la expresión regular
		if (event.keyCode === 13 && isValidEmail == true) {
			this.handleEmailEnter();
			this.buttonDisabledAttendees = true;
		}
	}

	@wire(getPicklistValues)
	wiredPicklist({ data, error }) {
		if (data) {
			this.picklistValues = data;
		} else if (error) {
			console.log(error);
		}
	}

	handleProdComment(event) {
		this.productComment = event.target.value
	}

	handleFamilyLoseFocus() {
		this.template.querySelector('c-av_-lookup').scrollIntoView();
	}


	getSinClienteAcc() {
		getAccountSinCliente()
			.then(data => {
				if (data) {
					this.accountSinclienteId = data[0].Id;
					this.accountSinclienteName = data[0].Name;
					this.initialclient = [{ id: this.accountSinclienteId, title: this.accountSinclienteName, icon: 'standard:account' }];

				}
			}).catch(error => {
				console.log('Error ', error);
			})
	}

	handleSearchAccount(e) {
		lookupSearchAccount({ searchTerm: e.detail.searchTerm })
			.then(result => {
				if (result != null) {
					this.template.querySelector('[data-id="accountlookup"]').setSearchResults(result);
				}
			}).catch(error => {
				console.log(error);
			});
	}

	clientToSend;
	clientname;
	handleSelectionAccount() {
		this.clientToSend = null;
		let accountSelection = this.template.querySelector('[data-id="accountlookup"]').getSelection()[0];

		if (accountSelection !== null && accountSelection !== undefined) {
			this.clientToSend = accountSelection.id;
			this.clientname = accountSelection.title;
			this.initialclient = [{ id: accountSelection.id, title: accountSelection.title, icon: 'standard:account' }];
			this.sendEventInfoToParent();
		} else {
			this.clientToSend = null;
			this.clientname = null;
			this.sendEventInfoToParent();
		}


	}

}