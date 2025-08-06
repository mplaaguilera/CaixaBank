import { LightningElement, wire, track, api } from "lwc";
import { CurrentPageReference } from "lightning/navigation";
import LANG from "@salesforce/i18n/lang";
import searchProduct from "@salesforce/apex/CIBE_NewEventController.searchProduct";
import createEvent from "@salesforce/apex/CIBE_NewEventCIBController.createEvent";
import callApiTeams from "@salesforce/apex/CIBE_NewEventCIBController.callApiTeams";
// import createOrUpdateOpportunities     		   from '@salesforce/apex/CIBE_NewEventCIBController.createOrUpdateOpportunities';
import deleteCreatedEventOrAttendes from "@salesforce/apex/CIBE_NewEventCIBController.backupEventsAndAttendes";
import vinculateOpportunitiesWO from "@salesforce/apex/CIBE_NewEventControllerWO.vinculateOpposToTheNewEvent";
// import linkOpp     	   	   					   from '@salesforce/apex/CIBE_Oportunidades_Vinculadas_Controller.linkOpp';

import updateAccessList from "@salesforce/apex/CIBE_NewEventCIBController.updateAccessList";
import processAsistentes from "@salesforce/apex/CIBE_NewEventCIBController.processAsistentes";
import createProductCIB from "@salesforce/apex/CIBE_NewEventCIBController.createProductCIB";

import { ShowToastEvent } from "lightning/platformShowToastEvent";

import { getRecord } from "lightning/uiRecordApi";
import { NavigationMixin } from "lightning/navigation";

import ISBPR from "@salesforce/customPermission/AV_PrivateBanking";

import USER_ID from "@salesforce/user/Id";
import FUNCION from "@salesforce/schema/User.AV_Funcion__c";
import getAccountSinCliente from "@salesforce/apex/CIBE_NewEventCIBController.getAccountSinCliente";

//import upsertOpportunity					  	from '@salesforce/apex/CIBE_NewEventOppDetail_Controller.upsertOpportunity';
//import getAccountOpportunities					from '@salesforce/apex/CIBE_NewEventOppDetail_Controller.getAccountOpportunities';
//import SystemModstamp from '@salesforce/schema/Account.SystemModstamp';

import duracion from "@salesforce/label/c.CIBE_Duracion";
import horafin from "@salesforce/label/c.CIBE_Horafin";
import horainicio from "@salesforce/label/c.CIBE_Horainicio";
import fecha from "@salesforce/label/c.CIBE_Fecha";
import modocal from "@salesforce/label/c.CIBE_ModoCalendario";
import fechahora from "@salesforce/label/c.CIBE_FechaHora";
import oportunidades from "@salesforce/label/c.CIBE_Oportunidades";
import vinculadas from "@salesforce/label/c.CIBE_Vinculadas";

import cita from "@salesforce/label/c.CIBE_Event";
import selFechaFutura from "@salesforce/label/c.CIBE_SeleccioneFechaFutura";
import indicaFecha from "@salesforce/label/c.CIBE_IndicaFecha";
import forFechaCorrecto from "@salesforce/label/c.CIBE_IntroduceFechaFormato";
import indicaHoraInicio from "@salesforce/label/c.CIBE_IndicaHoraInicio";
import indicaHoraFin from "@salesforce/label/c.CIBE_IndicaHoraFin";
import introduzcaUbicacion from "@salesforce/label/c.CIBE_IntroduzcaUbicacion";
import anyadir from "@salesforce/label/c.CIBE_Add";
import cancelar from "@salesforce/label/c.CIBE_Cancelar";
import finalizar from "@salesforce/label/c.CIBE_Finalizar";
import citaCreada from "@salesforce/label/c.CIBE_CitaCreada";

import faltanDatos from '@salesforce/label/c.CIBE_FaltanDatos';
import errorCalendar from '@salesforce/label/c.CIBE_ErrorCalendar';
import errorAsunto from '@salesforce/label/c.CIBE_ErrorAsunto';
import errorOwner from '@salesforce/label/c.CIBE_ErrorOwner';
import errorCliente from '@salesforce/label/c.CIBE_ErrorCliente';
import eventWithoutClient from '@salesforce/label/c.CIBE_EventWithoutClient';

const FIELDS_TO_RETRIEVE = ["AV_Potencial__c"];
const GESTOR = "Gestor";
const IDPROVISIONAL = "idProvisional";
const SEPARATOR = "{|}";
const FIELDS = ["Account.Name"];

export default class cibe_newEventTabCIB extends NavigationMixin(LightningElement) {
	label = {
		cita,
		duracion,
		horafin,
		horainicio,
		fecha,
		modocal,
		fechahora,
		oportunidades,
		vinculadas,
		selFechaFutura,
		indicaFecha,
		forFechaCorrecto,
		indicaHoraInicio,
		indicaHoraFin,
		introduzcaUbicacion,
		anyadir,
		cancelar,
		finalizar,
		citaCreada,
		faltanDatos,
		errorCalendar,
		errorAsunto,
		errorOwner,
		errorCliente,
		eventWithoutClient
	};

	//@wire(EnclosingTabId) tabId;
	isSubTab;

	@api opposscheduled;
	@track opposscheduledagended = [];
	@api comesfromevent;
	@api reportedevent;
	@api reportedetask;
	newEventHeaderId;
	thereisoppos;
	backEventReported = null;
	recordId;
	clientinfo;
	newEvent;
	newEventInserted;
	oppoObj = {};
	opposCount = 0;
	selectedProds = [];
	@track oppoList;
	@track oppoNewList = [];
	potentialList;
	showSpinner = false;
	noComercial = false;
	showUbication = false;
	ubication;
	dateIniFinal;
	dateFinFinal;
	editedOpportunitiesFromReport;
	newRecordFromTaskReport;
	reportedActivityHeaderId;
	updatedClientTasksBack;
	//Variables para el calendario
	durationToCalendar;
	activityDateToCalendar;
	employeeToCalendar;
	subjectToCalendar;
	overlapToCalendar = false;
	currentMainVinculed;
	nextScreen = false;
	today = new Date().toJSON().slice(0, 10);
	newRecordFromReportHeaderId;
	showCalendar = false;
	currentUserFunction;
	productToAdd = true;
	idProvisional = 0;
	//rollback vars
	createdEventId;
	createdAttendesOrEventId = [];
	createdOpposIds = [];
	copyOpposBeforeUpdt;
	updatedOpposId;
	altaDeActividadLabel = "Alta de actividad";
	checkOnOffTasksBackUp;
	caosCheckOnOffBackUp;
	taskAndOpposRel;
	accountId;
	initialDuration = "60";
	initialDuration;
	calendarValue = "laboral";
	calendarBoolean = true;
	durationToSend;
	showSinCliente;

	@track opp;

	//listAccountOpportunities = [];

	mapTypeDuration = {
		OCL: "60",
		OCX: "60",
		LT: "30",
		VLD: "30"
	};
	mapDurationText = {
		5: "5 min",
		15: "15 min",
		30: "30 min",
		60: "1 h",
		120: "2 h",
		0: "Otra"
	};

	disableButtonCancel = false;
	disableButtonSave = false;

	horaActual = this.setHours(new Date().getHours()) + ":" + this.setHours(new Date().getMinutes());

	sumarHora = this.setHours(new Date().getHours() + 1);

	timeInicio = this.horaActual.substring(3, 5) >= 1 && this.horaActual.substring(3, 5) < 30 ? this.horaActual.substring(0, 2) + ":30" + this.horaActual.substring(6, this.horaActual.length) : this.sumarHora + ":00";

	@wire(getRecord, { recordId: "$accountId", fields: FIELDS })
	account;

	get accountName() {
		return this.account.data ? this.account.data.fields.Name.value : "prueba";
	}
	get tomorrow() {
		let msInADay = 24 * 60 * 60 * 1000;
		let msForTomorrow = new Date().getTime() + msInADay;
		return new Date(msForTomorrow).toJSON().slice(0, 10);
	}
	activityDateToSend = this.tomorrow;
	timeFin;
	timeInfo;

	get optionsCalendario() {
		return [
			{ label: LANG === "es" ? "laboral" : "working", value: "laboral" },
			{ label: LANG === "es" ? "completo" : "complete", value: "completo" }
		];
	}

	get optionsTime() {
		return [
			{ label: "5 min", value: "5" },
			{ label: "15 min", value: "15" },
			{ label: "30 min", value: "30" },
			{ label: "1 h", value: "60" },
			{ label: "2 h", value: "120" },
			{ label: "Otra", value: "0" }
		];
	}

	setHours(hour) {
		var listNums = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9];
		if (listNums.includes(hour)) {
			hour = "0" + hour;
		}
		return hour;
	}

	@track oppId;

	@wire(CurrentPageReference)
	setCurrentPageReference(currentPageReference) {
		this.currentPageReference = currentPageReference;
		this.recordId = this.currentPageReference.state.c__recId;
		this.accountId = this.currentPageReference.state.c__account;
		this.oppId = this.currentPageReference.state.c__oppId;
		let clientName = this.currentPageReference.state.c__id;
		if (this.currentPageReference.state.c__sinCliente !== undefined) {
			this.showSinCliente = this.currentPageReference.state.c__sinCliente;
			clientName = this.showSinCliente ? this.label.eventWithoutClient : '';
		}
		this.clientinfo = {
			id: this.recordId,
			name: clientName,
			intouch: this.currentPageReference.state.c__intouch,
			recordtype: this.currentPageReference.state.c__rt,
			accountId: this.accountId
		};
		this.durationToSend = parseInt(this.initialDuration, 10);
		var iniDate = new Date(this.activityDateToSend + " " + this.timeInicio);
		iniDate.setHours(iniDate.getHours(), iniDate.getMinutes() + this.durationToSend, "00");
		this.timeFin = this.setHours(iniDate.getHours()) + ":" + this.setHours(iniDate.getMinutes());
		this.timeInfo = {
			date: this.formatDate(this.activityDateToSend),
			hourini: this.timeInicio,
			hourfin: this.timeFin,
			duration: this.mapDurationText[this.durationToSend]
		};
	}

	@wire(getRecord, { recordId: USER_ID, fields: [FUNCION] })
	wiredUser({ error, data }) {
		if (data) {
			this.currentUserFunction = data.fields.AV_Funcion__c.value;
		} else if (error) {
			this.error = error;
		}
	}

	handleChangeActivityDate(e) {
		this.template.querySelector('[data-id="activityDateInput"]').reportValidity();
		this.activityDateToSend = e.target.value;
		this.activityDateToCalendar = this.activityDateToSend;
		this.timeInfo = {
			date: this.formatDate(this.activityDateToSend),
			hourini: this.timeInicio,
			hourfin: this.timeFin,
			duration: this.mapDurationText[this.durationToSend]
		};
	}

	handleChangeTimeInicio(e) {
		this.timeInicio = e.target.value;
		var iniDate = new Date(this.activityDateToSend + " " + this.timeInicio);
		var finDate = new Date(this.activityDateToSend + " " + this.timeFin);
		var numDiff = finDate.getTime() - iniDate.getTime();
		numDiff /= 1000 * 60;
		if (numDiff != 5 && numDiff != 15 && numDiff != 30 && numDiff != 60 && numDiff != 120) {
			this.durationToSend = 0;
			this.initialDuration = "0";
		} else {
			this.durationToSend = numDiff;
			this.initialDuration = numDiff.toString();
		}
		if (this.durationToSend === 0) {
			this.durationToCalendar = numDiff;
		} else {
			this.durationToCalendar = this.durationToSend;
		}
		this.timeInfo = {
			date: this.formatDate(this.activityDateToSend),
			hourini: this.timeInicio,
			hourfin: this.timeFin,
			duration: this.mapDurationText[this.durationToSend]
		};
	}

	handleChangeTimeFin(e) {
		this.timeFin = e.target.value;
		var iniDate = new Date(this.activityDateToSend + " " + this.timeInicio);
		var finDate = new Date(this.activityDateToSend + " " + this.timeFin);
		var numDiff = finDate.getTime() - iniDate.getTime();
		numDiff /= 1000 * 60;
		if (numDiff != 5 && numDiff != 15 && numDiff != 30 && numDiff != 60 && numDiff != 120) {
			this.durationToSend = 0;
			this.initialDuration = "0";
		} else {
			this.durationToSend = numDiff;
			this.initialDuration = numDiff.toString();
		}
		if (this.durationToSend === 0) {
			this.durationToCalendar = numDiff;
		} else {
			this.durationToCalendar = this.durationToSend;
		}
		this.timeInfo = {
			date: this.formatDate(this.activityDateToSend),
			hourini: this.timeInicio,
			hourfin: this.timeFin,
			duration: this.mapDurationText[this.durationToSend]
		};
	}

	handleChangeDuration(e) {
		this.durationToSend = parseInt(e.target.value, 10);
		this.initialDuration = e.target.value;
		var iniDate = new Date(this.activityDateToSend + " " + this.timeInicio);
		var finDate = new Date(this.activityDateToSend + " " + this.timeFin);
		iniDate.setHours(iniDate.getHours(), iniDate.getMinutes() + this.durationToSend, "00");
		if (this.durationToSend === 0) {
			var numDiff = finDate.getTime() - iniDate.getTime();
			numDiff /= 1000 * 60;
			this.durationToCalendar = numDiff;
		} else {
			this.durationToCalendar = this.durationToSend;
			this.timeFin = this.setHours(iniDate.getHours()) + ":" + this.setHours(iniDate.getMinutes());
		}
		this.timeInfo = {
			date: this.formatDate(this.activityDateToSend),
			hourini: this.timeInicio,
			hourfin: this.timeFin,
			duration: this.mapDurationText[this.durationToSend]
		};
	}

	handleTime() {
		if (this.validateInputsAddEvents()) {
			if (this.durationToSend === 0) {
				var iniDate = new Date(this.activityDateToSend + " " + this.timeInicio);
				var finDate = new Date(this.activityDateToSend + " " + this.timeFin);
				var numDiff = finDate.getTime() - iniDate.getTime();
				numDiff /= 1000 * 60;
				this.durationToCalendar = numDiff;
			} else {
				this.durationToCalendar = this.durationToSend;
			}
			this.activityDateToCalendar = this.activityDateToSend;
			this.template.querySelector('[data-id="customcalendar"]').addEvent(new Date(this.activityDateToSend + " " + this.timeInicio));
			this.timeInfo = {
				date: this.formatDate(this.activityDateToSend),
				hourini: this.timeInicio,
				hourfin: this.timeFin,
				duration: this.mapDurationText[this.durationToSend]
			};
		}
	}

	handleCalendarMode(e) {
		this.calendarValue = e.target.value;
		this.calendarBoolean = this.calendarValue === "laboral" ? true : false;
	}

	handleUbicacion(e) {
		this.ubication = e.target.value;
	}

	filterListFromReport() {
		if (this.opposscheduled != null) {
			this.opposscheduled.forEach((oppo) => {
				if (oppo.Agendado) {
					this.opposscheduledagended.push(oppo);
				}
			});
		}

		this.thereisoppos = this.opposscheduledagended.length > 0;
	}

	setEventObject(e) {
		this.newEvent = e.detail;
		this.initialDuration = this.mapTypeDuration[this.newEvent["tipoCita"]];
		this.showUbication = this.newEvent["tipoCita"] === "OCX" || this.newEvent["tipoCita"] === "OCL" ? true : false;
		this.noOportunidades = this.newEvent["noOportunidades"];
		this.durationToSend = parseInt(this.initialDuration, 10);
		this.durationToCalendar = this.durationToSend;
		this.activityDateToCalendar = this.activityDateToSend;
		if (this.newEvent["owner"] === USER_ID) {
			this.overlapToCalendar = true;
		} else {
			this.overlapToCalendar = this.currentUserFunction != GESTOR;
		}
		if (this.employeeToCalendar != this.newEvent["owner"] && this.showCalendar) {
			this.employeeToCalendar = this.newEvent["owner"];
			if (this.calendarBoolean) {
				this.template.querySelector('[data-id="customcalendar"]').changeOwnerEvent(this.employeeToCalendar, this.overlapToCalendar);
			} else {
				this.template.querySelector('[data-id="customcalendarCompleto"]').changeOwnerEvent(this.employeeToCalendar, this.overlapToCalendar);
			}
		}
		this.employeeToCalendar = this.newEvent["owner"];
		if (this.subjectToCalendar != this.newEvent["subject"]) {
			this.subjectToCalendar = this.newEvent["subject"];
			let calendar = this.template.querySelector('[data-id="customcalendar"]');
			let inittime = calendar.initTime;
			let finaltime = calendar.endTime;
			if (inittime != null && finaltime != null) {
				calendar.changeSubjectEvent(this.subjectToCalendar);
			}
		}
		this.subjectToCalendar = this.newEvent["subject"];
		this.noComercial = this.newEvent["nocomercial"];
		var iniDate = new Date(this.activityDateToSend + " " + this.timeInicio);
		iniDate.setHours(iniDate.getHours(), iniDate.getMinutes() + this.durationToSend, "00");
		this.timeFin = this.setHours(iniDate.getHours()) + ":" + this.setHours(iniDate.getMinutes());
		this.timeInfo = {
			date: this.formatDate(this.activityDateToSend),
			hourini: this.timeInicio,
			hourfin: this.timeFin,
			duration: this.mapDurationText[this.durationToSend]
		};
		this.showCalendar = true;
	}

	handleSave() {
		this.nextScreen = true;
		var next = true;
		if (next) {
			next = this.validateRequiredInputs();
		}
		if (next) {
			let calendar = this.template.querySelector('[data-id="customcalendar"]');
			this.dateIniFinal = calendar.initTime;
			this.dateFinFinal = calendar.endTime;
		}
		this.nextScreen = next;
		if (this.nextScreen) {
			this.template.querySelector('[data-id="headerEvent"]').scrollIntoView({ behavior: "auto", block: "center", inline: "center" });
		}
	}

	validateInputsAddEvents() {
		if (this.activityDateToSend === null || this.activityDateToSend === undefined || this.activityDateToSend === "" || !this.template.querySelector('[data-id="activityDateInput"]').reportValidity()) {
			this.scrollIntoElement("activityDateInput");
			this.showToast("Faltan datos", "Por favor, introduce una fecha futura", "error");
			return false;
		}
		var dateSend = new Date(this.activityDateToSend);
		if (dateSend.getDay() === 0) {
			this.showToast("Fecha incorrecta", "Por favor, introduce una fecha que sea de lunes a sábado", "error");
			return false;
		}
		if (this.timeInicio === null || this.timeInicio === undefined || this.timeInicio === "" || !this.template.querySelector('[data-id="timeInicioInput"]').reportValidity()) {
			this.scrollIntoElement("timeInicioInput");
			this.showToast("Faltan datos", "Por favor, introduce una hora de inicio", "error");
			return false;
		}
		if (this.timeFin === null || this.timeFin === undefined || this.timeFin === "" || !this.template.querySelector('[data-id="timeFinInput"]').reportValidity()) {
			this.scrollIntoElement("timeFinInput");
			this.showToast("Faltan datos", "Por favor, introduce una hora de fin", "error");
			return false;
		}
		var iniDate = new Date(this.activityDateToSend + " " + this.timeInicio);
		var finDate = new Date(this.activityDateToSend + " " + this.timeFin);
		var numDiff = finDate.getTime() - iniDate.getTime();
		numDiff /= 1000 * 60;
		if (numDiff < 5) {
			this.showToast("Fecha incorrecta", "La duración mínima es de 5 minutos", "error");
			return false;
		}
		if (this.newEvent["owner"] === null || this.newEvent["owner"] === undefined || this.newEvent["owner"] === "") {
			this.showToast("Faltan datos", "Por favor, introduce un empleado/a asignado", "error");
			return false;
		}
		if (this.newEvent["client"] === null || this.newEvent["client"] === undefined || this.newEvent["client"] === "") {
			this.showToast("Faltan datos", "Por favor, introduce un cliente", "error");
			return false;
		}
		return true;
	}

	validateRequiredInputs() {
		let calendar = this.template.querySelector('[data-id="customcalendar"]');
		let inittime = calendar.initTime;
		let finaltime = calendar.endTime;
		if (inittime === undefined || finaltime === undefined || inittime === null || inittime === undefined || finaltime === null || finaltime === undefined || inittime === "" || finaltime === "") {
			this.showToast("Faltan datos", "Marca una franja en el calendario para continuar o darle al botón de añadir", "Error");
			return false;
		} else if (this.newEvent["subject"] === null || this.newEvent["subject"] === undefined || this.newEvent["subject"] === "") {
			this.showToast("Faltan datos", "Es necesario rellenar el asunto", "Error");
			return false;
		} else if (this.newEvent["owner"] === null || this.newEvent["owner"] === undefined || this.newEvent["owner"] === "") {
			this.showToast("Faltan datos", "Es necesario rellenar el organizador", "Error");
			return false;
		} else if (this.newEvent["tipoCita"] === null || this.newEvent["tipoCita"] === undefined || this.newEvent["tipoCita"] === "") {
			this.showToast("Faltan datos", "Es necesario rellenar el tipo de cita", "Error");
			return false;
		} else if (this.newEvent["personaContacto"] === "" || this.newEvent["tipoCita"] === null || this.newEvent["tipoCita"] === undefined) {
			this.showToast("Faltan datos", "Es necesario rellenar el contacto principal", "Error");
			return false;
		} else if (this.newEvent["importe"] === "" && this.nextScreen === true) {
			this.showToast("Faltan datos", "Es necesario rellenar el importe", "Error");
			return false;
		} else if (this.newEvent["client"] === "" && this.nextScreen === true) {
			this.showToast("Faltan datos", "Es necesario rellenar el cliente", "Error");
			return false;
		}
		return true;
	}

	validateRequiredInputs2() {
		if (this.nextScreen === true && (this.opp["importe"] === "" || this.opp["importe"] === null || this.opp["importe"] === undefined)) {
			this.showToast("Error", "Es necesario rellenar el importe", "Error");
			return false;
		}
		return true;
	}

	handleBack() {
		this.employeeToCalendar = this.newEvent["owner"];
		this.overlapToCalendar = true;
		this.dateFinFinal = null;
		this.dateIniFinal = null;
		this.nextScreen = false;
		this.oppoObj = {};
		this.opposCount = 0;
		this.nextScreen = false;
	}

	buildOppoObj(e) {
		let nextOppo = e.detail != null ? e.detail : e;
		let id = e.detail != null ? e.detail.id : e.Id;
		let vinculed = e.detail != null ? e.detail.isVinculed : e.isVinculed;
		if (Object.keys(this.oppoObj).includes(id) && !vinculed) {
			delete this.oppoObj[id];
		} else {
			this.oppoObj[id] = nextOppo;
		}

		this.opp = e.detail;
	}

	handleMainOpp(e) {
		let itemOppId = e.detail.oppoId;
		this.currentMainVinculed = itemOppId;
		let auxList = this.comesfromevent ? this.opposscheduledagended : this.oppoList.concat(this.oppoNewList);
		// let mainAgended;
		auxList.forEach((opp) => {
			this.template.querySelector('[data-id="' + opp.Id + '"]').mainVinculed = opp.Id === itemOppId;
			if (opp.Id === itemOppId && Object.keys(this.oppoObj).includes(itemOppId)) {
				//this.oppoObj[itemOppId]['mainVinculed'] = true;
			}
		});
	}

	vinculateall() {
		let mainAlreadyMarked = false;
		this.opposscheduledagended.forEach((opp) => {
			let detailOppo = this.template.querySelector('[data-id="' + opp.Id + '"]');
			detailOppo.handleVincular();

			if (opp.mainVinculed) {
				detailOppo.handleMain();
				mainAlreadyMarked = true;
			}
		});

		if (!mainAlreadyMarked) {
			Object.keys(this.oppoObj).forEach((oppId) => {
				let detailOppo = this.template.querySelector('[data-id="' + oppId + '"]');
				this.oppoObj[oppId]["mainVinculed"] = detailOppo.mainVinculed;
			});
		}
	}

	handleVinculation(e) {
		e.detail.sum ? this.opposCount++ : this.opposCount--;
		let itemOppId = e.detail.oppoId;
		let onlyOneVinculed = this.opposCount <= 1;
		let auxList = this.comesfromevent ? this.opposscheduledagended : this.oppoList.concat(this.oppoNewList);
		this.currentMainVinculed = null;
		let firtstVinculedId = null;
		if (onlyOneVinculed) {
			this.template.querySelector('[data-id="' + itemOppId + '"]').mainVinculed = true;
			this.currentMainVinculed = itemOppId;
		} else {
			this.template.querySelector('[data-id="' + itemOppId + '"]').mainVinculed = false;
		}
		if ((this.currentMainVinculed === null || this.currentMainVinculed === undefined) && firtstVinculedId != null) {
			this.template.querySelector('[data-id="' + firtstVinculedId + '"]').mainVinculed = true;
		}
	}

	handleSearchProduct(e) {
		searchProduct({ searchTerm: e.detail.searchTerm, recordId: this.accountId })
			.then((results) => {
				this.template.querySelector('[data-id="newproductlookup"]').setSearchResults(results);
			})
			.catch((error) => {
				this.notifyUser("Lookup Error", "An error occured while searching with the lookup field.", "error");
				console.error("Lookup error", JSON.stringify(error));
				this.errors = [error];
			});
	}

	evaluateProductToAdd() {
		this.productToAdd = this.template.querySelector("[data-id='newproductlookup']").getSelection().length === 0;
	}

	addDaysToDate = (date, n) => {
		const d = new Date(date);
		d.setDate(d.getDate() + n);
		return d.toISOString().split("T")[0];
	};

	eventCreateCalendar(e) {
		if (e.detail.validation.toString() === "false" && (this.newEvent["subject"] === null || this.newEvent["subject"] === undefined || this.newEvent["subject"] === "")) {
			this.showToast(this.label.faltanDatos, this.label.errorCalendar, "Error");
		} else {
			var dateIni = new Date(e.detail.initTiment.toString());
			var dateFin = new Date(e.detail.endTime.toString());
			this.activityDateToSend = dateIni.toJSON().slice(0, 10);
			this.timeInicio = this.setHours(dateIni.getHours()) + ":" + this.setHours(dateIni.getMinutes());
			this.timeFin = this.setHours(dateFin.getHours()) + ":" + this.setHours(dateFin.getMinutes());
			this.timeInfo = {
				date: this.formatDate(this.activityDateToSend),
				hourini: this.timeInicio,
				hourfin: this.timeFin,
				duration: this.mapDurationText[this.durationToSend]
			};
		}
	}

	formatDate(date) {
		var dateToFormat = new Date(date);
		return this.setHours(dateToFormat.getDate()) + "/" + this.setMonths(dateToFormat.getMonth()) + "/" + dateToFormat.getFullYear();
	}

	setMonths(month) {
		month = month + 1;
		var listNums = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9];
		if (listNums.includes(month)) {
			month = "0" + month;
		}
		return month;
	}

	handleCreateEvent() {
		var next = true;
		if (next) {
			let inittime = this.dateIniFinal;
			let finaltime = this.dateFinFinal;
			let calendar = this.template.querySelector('[data-id="customcalendar"]');
			if (calendar != null) {
				inittime = calendar.initTime;
				finaltime = calendar.endTime;
			}
			if (inittime === undefined || finaltime === undefined) {
				this.showToast(this.label.faltanDatos, this.label.errorCalendar, "Error");
			} else if (this.newEvent["owner"] === undefined || this.newEvent["owner"] === null || this.newEvent["owner"] === "") {
				this.showToast(this.label.faltanDatos, this.label.errorOwner, "Error");
			} else if (this.newEvent["client"] === undefined || this.newEvent["client"] === '') {
				this.showToast(this.label.faltanDatos, this.label.errorCliente, "Error");
			}

			else {
				var eventToInsert = {
					sobjectype: "Event",
					WhatId: this.newEvent["client"],
					OwnerId: this.newEvent["owner"],
					Subject: this.newEvent["subject"],
					Description: this.newEvent["comentarios"],
					AV_Tipo__c: this.newEvent["tipoCita"],
					StartDateTime: inittime,
					EndDateTime: finaltime,
					ActivityDate: this.activityDateToSend,
					Location: this.ubication,
					CIBE_Confidential__c: this.newEvent["confidencial"],
					FinServ__Regarding__c: this.newEvent["subject"],
					FinServ__Objectives__c: this.newEvent["subjectExtend"]
				};
				this.startReportLogic(eventToInsert);
			}
		}
	}

	startReportLogic(eventToInsert) {
		this.showSpinner = true;
		createEvent({ evt: eventToInsert })
			.then((result) => {
				if (result.errorResult == undefined) {
					this.newEventInserted = result.newEvent;
					this.createdEventId = result.newEventIdWithHeader.split(SEPARATOR)[0];
					this.newEventHeaderId = result.newEventIdWithHeader.split(SEPARATOR)[1];
					this.createdAttendesOrEventId.push(this.createdEventId);

					this.createAttendes();

					if (this.oppId != null) {
						let preBuildCaoList = [];
						preBuildCaoList.push({
							AV_Opportunity__c: this.oppId,
							AV_Task__c: this.newEventHeaderId,
							AV_IsMain__c: true,
							AV_OrigenApp__c: "AV_SalesforceClientReport"
						});

						vinculateOpportunitiesWO({
							caosToInsert: preBuildCaoList,
							evtId: this.createdEventId
						})
							.then((result) => {
								if (result == true) {
									this.showToast("Error al actualizar", "La fecha de próxima gestión no puede ser superior a la fecha de cierre ni inferior a la fecha actual", "Error");
								}
							})
							.catch((error) => {
								console.log(error);
							});
					}
					this.showToast(this.label.citaOK, result, "success");
				} else {
					this.showToast("Error creando el evento", result, "error");
					this.handleError();
				}
				// this.showToast(this.label.citaCreada, result,'success');
				//// this.finishReport();
			})
			.catch((error) => {
				console.log(error);
				this.showToast("Error creando el evento", error, "error");
				this.handleError();
			})
			.finally(() => {
				this.finishReport();
			});
	}

	deleteEventRegisters() {
		deleteCreatedEventOrAttendes({ recordsToDelete: this.createdAttendesOrEventId, jsonEventToBackReport: this.backEventReported, newRecordFromTaskToDel: this.newRecordFromTaskReport })
			.then((result) => {
				if (result === "OK") {
					this.showToast("Error actualizando las oportunidades", "Se han desecho todos los cambios.", "Error");
				} else {
					this.showToast("Error actualizando las oportunidades", "El evento ha quedado registrado mal. Por favor, eliminelo manualmente.", "Error");
				}
				this.handleError();
			})
			.catch((error) => {
				console.log(error);
				this.showToast("Error actualizando las oportunidades", "El evento ha quedado registrado mal. Por favor, eliminelo manualmente.", "Error");
			});
		this.handleError();
	}

	redirectToNewEvent() {
		this[NavigationMixin.Navigate]({
			type: "standard__recordPage",
			attributes: {
				objectApiName: "Event",
				recordId: this.createdEventId,
				actionName: "view"
			}
		});
	}

	handleCancel() {
		this.dispatchEvent(new CustomEvent("closetab"));
	}

	handleFinish() {
		this.dispatchEvent(new CustomEvent("closetab"));
		//this.dispatchEvent( new CustomEvent( 'closetabfinish',{detail:{neweventid:this.createdEventId}}));
	}

	handleCloseFinish() {
		this.dispatchEvent(new CustomEvent("closetabfinish", { detail: { neweventid: this.createdEventId } }));
	}

	handleError() {
		this.dispatchEvent(new CustomEvent("focustab"));
	}

	focusRecord() {
		this.dispatchEvent(new CustomEvent("focusrecordtab"));
	}

	changeTab() {
		this.dispatchEvent(new CustomEvent("renametab"));
	}

	finishReport() {
		this.handleFinish();

		this[NavigationMixin.Navigate]({
			type: "standard__recordPage",
			attributes: {
				recordId: this.createdEventId,
				objectApiName: "Event",
				actionName: "view"
			}
		});

		this.showSpinner = false;
	}

	backReportOpportunities() {
		let oldOpposToReportBack = [];
		for (let oppoId in this.oppoObj) {
			if (!oppoId.includes(IDPROVISIONAL)) {
				oldOpposToReportBack.push(this.template.querySelector('[data-id="' + oppoId + '"]').initialState);
			}
		}
		backCreatedOrUpdtOppos({
			createdIds: this.createdOpposIds,
			oldOppos: oldOpposToReportBack,
			tskToRestore: this.checkOnOffTasksBackUp,
			caoToRestore: this.caosCheckOnOffBackUp,
			entityRelations: this.taskAndOpposRel
		})
			.then((result) => {
				this.deleteEventRegisters();
				if (result != "OK") {
					this.showToast("Error vinculando las oportunidades con el evento", "Cuidado, no se han podido deshacer los cambios en las oportunidades", "warning");
				}
				this.showToast("Error en el reporte", "No se ha editado ni creado ninguna oportunidad,ni se ha creado ningún evento", "error");

				this.handleError();
			})
			.catch((error) => {
				console.log(error);
				this.showToast("Error vinculando las oportunidades con el evento", "Cuidado, no se han podido deshacer los cambios en las oportunidades", "warning");
			});
		this.handleError();
	}

	createAttendes() {
		processAsistentes({ evt: this.newEventInserted, asistentes: this.newEvent["attendes"].length > 0 ? this.newEvent["attendes"] : null, contactoPrincipal: null })
			.then((result) => {
				if (this.newEvent["product"].length > 0) {
					this.createProduct();
				} else if (this.newEvent["confidencial"] === true) {
					updateAccessList({ recordId: this.createdEventId })
						.then((result) => { })
						.catch((error) => {
							console.log(error);
						});
				}
			})
			.catch((error) => {
				this.deleteEventRegisters();
				console.log(error);
			});
	}

	handleSelectionProduct() {
		this.evaluateProductToAdd();
	}

	showToast(title, message, variant) {
		var event = new ShowToastEvent({
			title: title,
			message: message,
			variant: variant,
			mode: "pester"
		});
		this.dispatchEvent(event);
	}

	createProduct() {
		createProductCIB({ takedProducts: this.newEvent["product"], evt: this.newEventInserted })
			.then((result) => {
				if (this.newEvent["confidencial"] === true && this.newEvent["attendes"] === 0) {
					updateAccessList({ recordId: this.createdEventId })
						.then((result) => { })
						.catch((error) => {
							console.log(error);
						});
				}
			})
			.catch((error) => {
				this.deleteEventRegisters();
				console.log(error);
			});
	}

	@wire(getAccountSinCliente)
	getAccountSinCliente({ data, error }) {
		if (data) {
			this.accountSinclienteName = data[0].Name;
		} else if (error) {
			console.log(error);
		}
	}
}