import { LightningElement, api, track, wire } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import USER_ID from "@salesforce/user/Id";
//import { getRecord } 					from 'lightning/uiRecordApi';

// lmg
import { updateRecord } from 'lightning/uiRecordApi';
import { getPicklistValues, getObjectInfo } from 'lightning/uiObjectInfoApi';
import divisa_FIELD from '@salesforce/schema/Opportunity.CIBE_Divisa__c'
import opportunity_Object from '@salesforce/schema/Opportunity'


//labels
import mainOpp from '@salesforce/label/c.AV_MainOpportunity';
import markMainOpp from '@salesforce/label/c.AV_MarkMainOpportunity';
import statusOpp from '@salesforce/label/c.CIBE_CurrentStatus';
import amount from '@salesforce/label/c.AV_Importe';
import detail from '@salesforce/label/c.AV_Detalle';
import fechaCierre from '@salesforce/label/c.CIBE_FechaCierre';
import comentario from '@salesforce/label/c.CIBE_Comentario';
import prodOtraEntidad from '@salesforce/label/c.CIBE_ProductoOtraEntidad';
import entidad from '@salesforce/label/c.CIBE_Entidad';
import vencimiento from '@salesforce/label/c.CIBE_Vencimiento';
import precio from '@salesforce/label/c.CIBE_Precio';
import margen from '@salesforce/label/c.CIBE_Margen';
import impactoCom from '@salesforce/label/c.CIBE_ImpactoComisiones';
import impactoBal from '@salesforce/label/c.CIBE_ImpactoBalance';
import divisa from '@salesforce/label/c.CIBE_Divisa';
import probabilidad from '@salesforce/label/c.CIBE_ProbabilidadExito';
import importe from '@salesforce/label/c.CIBE_Importe';
import confidencial from '@salesforce/label/c.CIBE_Confidencial';
import guardar from '@salesforce/label/c.CIBE_Guardar';
import ultComentario from '@salesforce/label/c.CIBE_LastComment';
import estado from '@salesforce/label/c.CIBE_Motivo';
import cerradoNegativo from '@salesforce/label/c.CIBE_CerradoNegativo';
import cerradoPositivo from '@salesforce/label/c.CIBE_CerradoPositivo';
import vencida from '@salesforce/label/c.CIBE_Vencida';
import potencial from '@salesforce/label/c.CIBE_Potencial';
import pendienteFirma from '@salesforce/label/c.CIBE_PendienteFirma';
import enCurso from '@salesforce/label/c.CIBE_EnCurso';
import agendar from '@salesforce/label/c.CIBE_Agendar';
import cerradaPositiva from '@salesforce/label/c.CIBE_CerradaPositiva';
import cerradaNegativa from '@salesforce/label/c.CIBE_CerradaNegativa';
import anulada from '@salesforce/label/c.CIBE_Anulada';
import esg from '@salesforce/label/c.CIBE_FinanciacionSostenible';
import competencia from '@salesforce/label/c.CIBE_Competencia';
import desistidaCliente from '@salesforce/label/c.CIBE_DesistidaCliente';
import desistidaOficina from '@salesforce/label/c.CIBE_DesistidaOficina';
import denegadaPoliticaFinanciacionSostenible from '@salesforce/label/c.CIBE_DenegadaPoliticaFinanciacionSostenible';
import producto from '@salesforce/label/c.CIBE_Producto';
import riesgos from '@salesforce/label/c.CIBE_Riesgos';
import otros from '@salesforce/label/c.CIBE_Otros';

import alta from '@salesforce/label/c.CIBE_AltaMotivo';
import media from '@salesforce/label/c.CIBE_Media';
import baja from '@salesforce/label/c.CIBE_BajaMotivo';

//import
import updateChecked from '@salesforce/apex/CIBE_NewEventOppDetail_Controller.updateChecked';
import updatePendienteFirma from '@salesforce/apex/CIBE_NewEventOppDetail_Controller.updatePendienteFirma';
import updateCanceled from '@salesforce/apex/CIBE_NewEventOppDetail_Controller.updateCanceled';
import updateClosed from '@salesforce/apex/CIBE_NewEventOppDetail_Controller.updateClosed';
import vinculateOpportunity from '@salesforce/apex/CIBE_NewEventOppDetail_Controller.vinculateOpportunity';
import disVinculateOpportunity from '@salesforce/apex/CIBE_NewEventOppDetail_Controller.disVinculateOpportunity';
import makePrincipal from '@salesforce/apex/CIBE_NewEventOppDetail_Controller.makePrincipal';
import getActivityDate from '@salesforce/apex/CIBE_NewEventOppDetail_Controller.getActivityDate';
import createOrUpdateOpportunities from '@salesforce/apex/CIBE_NewEventController.createOrUpdateOpportunities';
import vinculateOpportunitiesWO from '@salesforce/apex/CIBE_NewEventControllerWO.vinculateOpposToTheNewEvent';
import updateAccessList from '@salesforce/apex/CIBE_NewEventController.updateAccessList';
//import palabrasProhibidas					from '@salesforce/apex/AV_ForbiddenWords.validateRecords';



const PROXIMGESTIONLABEL = 'Próxima Gestión';
const NOOFRECERLABEL = 'No ofrecer hasta';
const IDPROVISIONAL = 'idProvisional';
const SEPARADOR = '{|}';

export default class cibe_NewEventOppDetail extends NavigationMixin(LightningElement) {

	label = {
		agendar, cerradaPositiva, cerradaNegativa, anulada,
		mainOpp,
		markMainOpp,
		statusOpp,
		amount,
		detail,
		fechaCierre,
		comentario,
		confidencial,
		prodOtraEntidad,
		entidad,
		vencimiento,
		precio,
		margen,
		impactoCom,
		impactoBal,
		divisa,
		probabilidad,
		importe,
		guardar,
		ultComentario,
		estado,
		cerradoPositivo, cerradoNegativo, vencida, potencial, pendienteFirma, enCurso,
		esg,
		competencia, desistidaCliente, desistidaOficina, denegadaPoliticaFinanciacionSostenible, producto, riesgos, otros,
		alta, media, baja
	};
	@api recordId
	@api oppislinked;
	@api isEditable;
	@api isCPositiva;
	@api proximaGestion
	isInsistir = false;
	isInsistirNo = false;
	isPenfir = false;
	@track showSpinner = false;
	@api oportunidadVin;
	@api newEventHeaderId;
	@api principal;
	@api noEvento;
	// var cibe_ViewOppRelatedEvent
	@api oppo;
	@api eventid;
	@api main;
	@track id;
	@track name;
	@track path;
	@track oppoDate;
	@track oppoDateFront;
	@track comentario;
	@track initPotential;
	@track initResolution;
	@track amount;
	@track margin;
	@track importeOtraEntidad;
	@track otraEntidad;
	@track otraEntidadNombre;
	@track subProductInitial;
	@track subProductId;
	@track cuota;
	@track mainPF;
	@track isInserted = true;
	@track historyCommentWithDate;
	@track historyComment;
	@track historyCommentDate;
	@track historyCommentDateLabel;
	@track allCheck = false;
	@track cliente;
	isGuardarDisabled = false;

	//lmg
	@track values;
	statusNow;
	statusNowLabel;
	owner;
	userId = USER_ID;
	isOwner;
	teamOpp;

	// activityDate = ACTIVITY_DATE_ID;
	checkedOld;
	currentNameButton;
	@api vinculed = false;
	@api mainVinculed = false;
	@api vinculeButtons = false;
	@api mainButtons = false;
	@track allStages = [];
	@track unfoldCmp = false; // variable para mostrar campos del primer boton
	@track showComents = true;
	@track otherEntity = false;
	@track secundaryInputs = false;
	@track showMoreInfo = false;
	@track isAgendado = false;
	@track especialInputLabel = PROXIMGESTIONLABEL;
	// @api potentiallist;
	@api resolutionlist;
	@track showState = false; // variable para mostrar campos del estado Cerrado Negativo
	isModalDeleteOpen = false;

	//Nombres Class CSS
	arrowClass = "customArrowRightDefault";
	agendadoClass = "customEventDefault";
	checkClass = "customCheckDefault";
	closeClass = "customCloseDefault";
	banClass = "customBanDefault";
	pfClass = "customPFDefault";
	insisClass = "customInsisDefault";
	//estados
	POTENCIAL = 'Potencial';
	// GESTION = 'En gestión/insistir';
	CERRADOPOSI = 'CIBE_Cerrado positivo';
	CERRADONEGA = 'Cerrado negativo';
	VENCIDO = 'Vencido';
	// CERRPOSI = 'Cerrado positivo';
	// CERRNEGA = 'No interesado';
	// NOAPTO = 'No apto';
	// GESTIONSPLIT = 'gestion';
	// AGENDARSPLIT = 'agendar';

	labelsMap = {
		'En curso': this.label.enCurso,
		'Ongoing': this.label.enCurso,
		'Potencial': this.label.potencial,
		'Potential': this.label.potencial,
		'Pendiente de firma': this.label.pendienteFirma,
		'Sign Pending': this.label.pendienteFirma,
		'Vencido': this.label.vencida,
		'Out of Date': this.label.vencida,
		'Cerrada positiva': this.label.cerradoPositivo,
		'Closed Positively': this.label.cerradoPositivo,
		'Cerrada negativa': this.label.cerradoNegativo,
		'Closed Negatively': this.label.cerradoNegativo,

		'CIBE_Pendiente_Firma': this.label.pendienteFirma,
		'CIBE_Vencido': this.label.vencida,
		'CIBE_Cerrado positivo': this.label.cerradoPositivo,
		'Cerrado negativo': this.label.cerradoNegativo
	}
	pathMap = {
		'check': this.CERRADOPOSI,
		'close': this.CERRADONEGA,
		'ban': this.CERRADONEGA,
		'penfir': 'CIBE_Pendiente_Firma'
	}
	classMap = {
		'arrow': 'customArrowRight',
		'agendado': 'customEvent',
		'check': 'customCheck',
		'close': 'customClose',
		'penfir': 'customPF',
		'insistir': 'customInsis'
	}
	classMapDefault = {
		'arrow': 'customArrowRightDefault',
		'agendado': 'customEventDefault',
		'check': 'customCheckDefault',
		'close': 'customCloseDefault',
		'penfir': 'customPFDefault',
		'insistir': 'customInsisDefault'
	}
	find = '';
	pathToSend;
	proximaGestionToSend;
	expectativaToSend;
	importePropioToSend;
	@track comentarioToSend;
	subProductoToSend = null;
	deleteCheckOnOffTask;
	isModalOpen = false;
	isToggleActive = false;
	get todayString() { return new Date().toJSON().slice(0, 10) };
	// todayString = this.getTodayString();
	now = new Date(Date.now()).toISOString();
	firstClickNewOppo = true;


	//popUp
	divisa;
	impactoBalance;
	impactoComisiones;
	entidad;
	vencimiento;
	precio;
	margen;
	esg = false;
	confidencial = false;
	//campos PendienteFirma
	@track fechaProxGest;
	@track fechaCierre;
	//var fecha Event
	@api isFuture;
	@track probabilidad = 'Media';

	//@track probabilidad;
	@track state;
	//upCreateOpp
	@api oppoObj = {};
	checkOnOffTasksBackUp;
	caosCheckOnOffBackUp;
	taskAndOpposRel;
	createdOpposIds = [];
	showDeleteButtonOpp = false;
	@api showName;
	// @api clientName;

	connectedCallback() {
		this.fillVars();
	}

	@track _wiredData;
	@wire(getActivityDate, { eventId: '$newEventHeaderId' })
	getActivityDate(result) {
		this._wiredData = result;
		const { data, error } = this._wiredData;
		if (data) {
			//this.isFuture = data;

		} else if (error) {
			console.log(error);
		}
	}

	getTodayString() {
		let d = new Date();
		return d.getFullYear() + '-' + (d.getMonth() + 1) + '-' + d.getDate()
	}

	renderedCallback() {
		let oVin = this.oppo !== undefined && this.oppo.isVinculated !== undefined ? this.oppo.isVinculated : false;
		if ((this.id.includes(IDPROVISIONAL) || oVin) && this.firstClickNewOppo) {
			if (this.isFuture) {
				if (this.id.includes(IDPROVISIONAL) && this.firstClickNewOppo) {

					if (this.template.querySelector('[data-id="agendado"]') != null) {
						this.template.querySelector('[data-id="agendado"]').click();
						this.firstClickNewOppo = false;
					} else {
						if (this.template.querySelector('[data-id="noAgendado"]') != null) {
							this.template.querySelector('[data-id="noAgendado"]').click();
						} else {
							this.unfoldCmp = true;
							this.firstClickNewOppo = false;
						}
					}
				}
			}
			if (!this.isFuture) {
				if (this.id.includes(IDPROVISIONAL) && this.firstClickNewOppo) {

					if (this.template.querySelector('[data-id="insistir"]') != null) {
						this.template.querySelector('[data-id="insistir"]').click();
					} else {
						this.insisClass = this.classMap['insistir'];
						this.isInsistir = true;
					}
				}
				this.firstClickNewOppo = false;
			}
		}

		if (this.oportunidadVin && this.firstClickNewOppo) {
			if (this.template.querySelector('[data-id="agendado"]') != null) {
				this.template.querySelector('[data-id="agendado"]').click();
				this.agendadoClass = this.classMap['agendado'];
				this.firstClickNewOppo = false;
			}
			if (this.template.querySelector('[data-id="noAgendado"]') != null) {
				this.firstClickNewOppo = false;
			}
			if (this.template.querySelector('[data-id="insistir"]') != null) {
				this.template.querySelector('[data-id="insistir"]').click();
				this.firstClickNewOppo = false;
			}
		}
		//this.sendDataToController();
	}

	parseTodayDate() {
		let a = new Date(Date.now());
		let month = this.fillNumbers(a.getMonth() + 1);
		let day = this.fillNumbers(a.getDate());
		return a.getFullYear() + '-' + month + '-' + day;
	}

	fillNumbers(n) {
		return n > 9 ? "" + n : "0" + n;
	}

	showToast(title, message, variant, mode) {
		var event = new ShowToastEvent({
			title: title,
			message: message,
			variant: variant,
			mode: mode
		});
		this.dispatchEvent(event);
	}

	fillVars() {
		this.showDeleteButtonOpp = this.oppo.id.startsWith('idProvisional') ? true : false;
		this.teamOpp = this.oppo.teamOpp;
		//this.teamOpp.split(" ");
		this.impactoComisiones = this.oppo.comissionImpact;
		this.precio = this.oppo.price;
		this.divisa = this.oppo.divisa;
		this.impactoBalance = this.oppo.impactoBalance;
		this.esg = this.oppo.ESG;
		this.confidencial = this.oppo.confidential;
		this.entidad = this.oppo.entity;
		this.vencimiento = this.oppo.vencimiento;
		this.margen = this.oppo.margin;
		this.comentario = this.oppo.comments;
		this.comentarioToSend = this.oppo.comments;
		if (this.oppo.probability != undefined) {
			this.probabilidad = this.oppo.probability;
		}

		this.isEditable = this.oppo.isEditable;
		this.proximaGestion = this.oppo.proximaGestion;
		this.statusNow = this.oppo.status;
		this.statusNowLabel = this.labelsMap[this.statusNow];
		this.owner = this.oppo.owner;

		this.id = this.oppo.id;
		this.name = this.oppo.name;
		var [year, month, day] = this.oppo.closeDate.split('-');
		day = day.lenght < 2 ? '0' + day : day;
		month = month.lenght < 2 ? '0' + month : month;
		this.oppoDate = this.oppo.closeDate;
		this.fechaCierre = this.oppo.closeDate;
		this.oppoDateFront = day + '-' + month + '-' + year;
		this.amount = this.oppo.amount == null ? '' : this.oppo.amount;
		this.margin = this.oppo.margin;
		this.mainPF = this.oppo.productId;
		this.otraEntidad = this.oppo.entity;
		this.isInserted = (this.oppo.NotInserted == undefined || (this.oppo.NotInserted != undefined && this.oppo.NotInserted == false));
		this.cliente = (this.oppo.accountId !== undefined) ? this.oppo.accountId : this.oppo.cliente;
		//this.vinculed = this.oppo.isVinculated;
		this.mainVinculed = (this.oppo.isPrincipal != undefined) ? this.oppo.isPrincipal : false;
		this.vinculed = (this.oppo.isVinculed != undefined) ? this.oppo.isVinculed : false;
		// this.mainVinculed = (this.comesfromevent) ? (this.oppo.isPrincipal):false;
		this.historyCommentWithDate = this.oppo.commentsLastModifieddate;
		if (this.historyCommentWithDate != '' && this.historyCommentWithDate != undefined) {
			this.historyCommentDate = this.historyCommentWithDate.split('T')[0];
			this.historyComment = this.historyCommentWithDate.split(SEPARADOR)[1];
			this.historyCommentDateLabel = this.label.ultComentario + ' - ' + this.historyCommentDate;
		} else {
			this.historyCommentDateLabel = '';
		}
		this.state = this.oppo.state;

		if (this.owner == this.userId) {
			this.isOwner = true;
		} else {
			this.isOwner = false;
		}

		if (this.teamOpp != null && this.teamOpp.includes(USER_ID)) {
			this.isOwner = true;
		}

		if (this.oppo.isVinculated) {
			if (this.isFuture) {
				this.agendadoClass = this.classMap['agendado'];
				if (this.isOwner) {
					this.unfoldCmp = true;
				} else {
					this.unfoldCmp = false;
				}
			} else {
				this.insisClass = this.classMap['insistir'];
				this.unfoldCmp = false;
				if (this.isOwner) {
					this.isInsistir = true;
				} else {
					this.isInsistir = false;
				}
			}
			this.vinculed = true;
		}


		this.fechaProxGest = this.oppo.proximaGestion;
		this.sendDataToController();
	}


	navigateToRecord(event) {
		let recordToGo = event.target.name;
		this[NavigationMixin.Navigate]({
			type: 'standard__recordPage',
			attributes: {
				objectApiName: 'Opportunity',
				recordId: recordToGo,
				actionName: 'view'
			}
		})
	}

	resetCustomButtons(buttonToAvoid) {
		//Actualiza los que no son el seleccionado¿?
		if (!this.isFuture) {
			// if (buttonToAvoid != 'arrow') {
			// 	this.arrowClass = this.classMapDefault['arrow'];
			// }
			if (buttonToAvoid !== 'agendado') {
				this.agendadoClass = this.classMapDefault['agendado'];
			}

		}
		if (buttonToAvoid !== 'agendado') {
			if (buttonToAvoid !== 'check') {
				this.checkClass = this.classMapDefault['check'];
			}
			if (buttonToAvoid !== 'close') {
				this.closeClass = this.classMapDefault['close'];
			}
			if (buttonToAvoid !== 'insistir') {
				this.insisClass = this.classMapDefault['insistir'];
			}
			if (buttonToAvoid !== 'penfir') {
				this.pfClass = this.classMapDefault['penfir'];
			}
		}
	}


	resetearBotonesAfuturo(botondelClick) {
		if (botondelClick === 'penfir') {
			this.checkClass = this.classMapDefault['check'];
			this.closeClass = this.classMapDefault['close'];
			this.insisClass = this.classMapDefault['insistir'];
		}
		if (botondelClick === 'check') {
			this.insisClass = this.classMapDefault['insistir'];
			this.pfClass = this.classMapDefault['penfir'];
			this.closeClass = this.classMapDefault['close'];
			this.agendadoClass = this.classMapDefault['agendado'];
		}
		if (botondelClick === 'close') {
			this.insisClass = this.classMapDefault['insistir'];
			this.pfClass = this.classMapDefault['penfir'];
			this.checkClass = this.classMapDefault['check'];
		}
		if (botondelClick === 'insistir') {
			this.pfClass = this.classMapDefault['penfir'];
		}
	}






	buttonClicked;
	handleToggleClick() {
		this.buttonClicked = !this.buttonClicked; //set to true if false, false if true.
		this.cssClass = this.buttonClicked ? 'cssClass' : 'slds-button slds-button_destructive';
	}


	oldValue;
	handlePath(e) {
		this.template.querySelector('[data-id="' + e.target.name + '"]').blur();
		if (this.isFuture) {
			this.resetearBotonesAfuturo(e.target.name);
		} else {
			this.resetCustomButtons(e.target.name);
		}
		this.currentNameButton = e.target.name;
		this.path = this.pathMap[e.target.name];
		let beforeVinculated = this.vinculed;

		if (this.currentNameButton === 'noAgendado') {
			if (!this.isFuture) {
				this.vinculed = false;
				//this.isMain = false;
				this.unfoldCmp = false;
				this.showState = false;
				this.showComents = true;
				this.isCPositiva = false;
				this.isInsistir = false;
				this.isInsistirNo = false;
				this.isPenfir = false;
			} else {
				this.vinculed = false;
			}
		} else if (this.currentNameButton === 'agendado') {
			this.oldValue = (this.oldValue === this.currentNameButton) ? null : this.currentNameButton;
			this.showState = false;

			if (e.target.dataset.future !== 'future') {
				this.unfoldCmp = true;
				this.vinculed = true;
				this.showComents = false;
				this.isCPositiva = false;
				this.isInsistir = false;
				this.isInsistirNo = false;
				this.isPenfir = false;
				this.agendadoClass = this.classMap['agendado'];
			} else {
				this.vinculed = !this.vinculed;
				this.agendadoClass = this.vinculed ? this.classMap['agendado'] : this.classMapDefault['agendado'];

			}
		} else if (this.currentNameButton === 'check') {
			// this.state = null;
			this.showComents = true;
			this.unfoldCmp = false;
			this.showState = false;
			if (e.target.dataset.future !== 'future') {
				if (!this.vinculed) {
					this.vinculed = true;
				} else {
					if (this.oldValue == this.currentNameButton) {
						this.vinculed = false;

					}
				}
			}
			if (!this.isCPositiva) { this.isCPositiva = true; } else { this.isCPositiva = false; }
			if (this.oldValue === this.currentNameButton) {
				this.statusNow = this.oppo.status;
				this.statusNowLabel = this.labelsMap[this.statusNow];
				this.oldValue = null;

			} else {
				this.statusNow = this.path;
				this.statusNowLabel = this.labelsMap[this.statusNow];
				this.oldValue = this.currentNameButton;

			}
			this.isInsistir = false;
			this.isInsistirNo = false;
			this.isPenfir = false;

			this.checkClass = (this.checkClass == this.classMapDefault[e.target.name])
				? this.classMap[e.target.name]
				: this.classMapDefault[e.target.name];

			this.updateClosePositively();

		} else if (this.currentNameButton === 'close') {
			// this.state = null;
			this.unfoldCmp = false;
			this.showComents = false;
			if (!this.isFuture) {
				if (!this.vinculed) {
					this.vinculed = true;

				} else {
					if (this.oldValue == this.currentNameButton) {
						// this.mainVinculed = false;
						this.vinculed = false;
					}
				}
			}
			if (!this.showState) { this.showState = true; } else { this.showState = false; }
			if (this.oldValue == this.currentNameButton) {
				this.statusNow = this.oppo.status;
				this.statusNowLabel = this.labelsMap[this.statusNow];
				this.oldValue = null;
			} else {
				this.statusNow = this.path;
				this.statusNowLabel = this.labelsMap[this.statusNow];
				this.oldValue = this.currentNameButton;

			}
			this.isCPositiva = false;
			this.isInsistir = false;
			this.isInsistirNo = false;
			this.isPenfir = false;
			this.closeClass = (this.closeClass == this.classMapDefault[e.target.name])
				? this.classMap[e.target.name]
				: this.classMapDefault[e.target.name];
		}

		this.unfoldCmp = this.vinculed === false ? false : this.unfoldCmp;
		if (beforeVinculated !== this.vinculed) {

			if (this.vinculed) {
				if (this.oppo.id.startsWith('006')) {
					this.vinculate();
				}
				this.handleVincular();
			} else {
				if (this.oppo.id.startsWith('006')) {
					this.desvinculate();
				}
				this.handleVincular();
			}

		}
		//this.handleVincular(); 
		this.sendDataToController();

	}
	vinculate() {
		let idEventoCreandose = this.newEventHeaderId !== undefined ? this.newEventHeaderId : this.eventid;

		vinculateOpportunity({ recordId: idEventoCreandose, opportunityId: this.oppo.id })
			.then((result => {
				this.dispatchEvent(new CustomEvent('resfreshdata'));
				if (this.oppo.principal) {
					this.mainVinculed = true;
				}
			}))
			.catch((error => {
				console.log(error);
			}))
	}
	desvinculate() {
		let idEventoCreandose = this.newEventHeaderId !== undefined ? this.newEventHeaderId : this.eventid;
		disVinculateOpportunity({ recordId: idEventoCreandose, opportunityId: this.oppo.id })
			.then((result => {
				this.dispatchEvent(new CustomEvent('resfreshdata'));

			}))
			.catch((error => {
				console.log(error);
			}))
	}
	handleInsPath(e) {
		this.currentNameButton = e.target.name;
		this.template.querySelector('[data-id="' + e.target.name + '"]').blur();
		if (this.isFuture) {
			this.resetearBotonesAfuturo(e.target.name);
		} else {
			this.resetCustomButtons(e.target.name);
		}
		this.path = this.pathMap[e.target.name];
		let beforeVinculed = this.vinculed;
		if (this.currentNameButton === 'insistir') {
			// this.statusNow = this.oppo.status;
			// this.statusNowLabel = this.labelsMap[this.statusNow];
			this.unfoldCmp = false;
			if (!this.isFuture) {
				if (!this.vinculed) {
					this.vinculed = true;
				} else {
					if (this.oldValue === this.currentNameButton) {
						// this.mainVinculed = false;
						this.vinculed = false;
					}
				}
			} else {
				this.vinculed = !this.vinculed ? true : true;
			}

			if (beforeVinculed != this.vinculed) {
				if (this.vinculed) {
					if (this.oppo.id.startsWith('006')) {
						this.vinculate();
					}
					if (this.insisClass === 'customInsisDefault') {
						this.handleVincular();
					} else {
						this.vinculed = false;
					}
				} else {
					if (this.oppo.id.startsWith('006')) {
						this.desvinculate();
					}
					this.handleVincular();
				}
				this.sendDataToController();

			}


			this.oldValue = (this.oldValue === this.currentNameButton) ? null : this.currentNameButton;
			this.showComents = false;
			this.isCPositiva = false;
			if (!this.isInsistir) { this.isInsistir = true; } else { this.isInsistir = false; }
			this.isInsistirNo = false;
			this.isPenfir = false;
			this.showState = false;
			this.insisClass = (this.insisClass == this.classMapDefault[e.target.name])
				? this.classMap[e.target.name]
				: this.classMapDefault[e.target.name];



			if (this.checkClass === 'customCheck') {
				this.checkClass = this.classMapDefault['check'];
			}

			if (this.closeClass === 'customClose') {
				this.closeClass = this.classMapDefault['close'];
			}
		}
	}

	handlePFPath(e) {
		this.currentNameButton = e.target.name;
		this.template.querySelector('[data-id="' + e.target.name + '"]').blur();
		//Cambia las clases css de los botones no selecionados.
		if (this.isFuture) {
			this.resetearBotonesAfuturo(e.target.name)
		} else {
			this.resetCustomButtons(e.target.name);
		}
		this.path = this.pathMap[e.target.name];//para que sirve esto, devuelve lo mismo que currentNameButton ¿?
		let beforevinculed = this.vinculed;
		if (this.currentNameButton === 'penfir') {
			if (this.oppo.id != null && this.oppo.id != undefined && this.oppo.id.startsWith('006')) {
				updatePendienteFirma({ recordId: this.oppo.id })
					.then((result => {
						this.dispatchEvent(new CustomEvent('resfreshdata'));
					}))
					.catch((error => {
						console.log(error);
					}))
				this.sendDataToController();

			}
			if (!this.isFuture) {
				//a pasado.
				if (!this.vinculed) {
					this.vinculed = true;
				} else if (this.oldValue === this.currentNameButton) {
					this.vinculed = false;
				}

			} else {
				this.vinculed = true;
			}

			if (beforevinculed != this.vinculed) {
				if (this.vinculed) {
					if (this.oppo.id != null && this.oppo.id != undefined) {
						this.vinculate();
						if (this.pfClass === 'customPFDefault') {
							this.handleVincular();
						} else {
							this.vinculed = false;
						}
					}
				} else {
					this.desvinculate();
					this.handleVincular();
				}
			}
			if (this.oldValue === this.currentNameButton) {
				this.statusNow = this.oppo.status;
				this.statusNowLabel = this.labelsMap[this.statusNow];
				this.oldValue = null;

			} else {
				this.statusNow = this.path;
				this.statusNowLabel = this.labelsMap[this.statusNow];
				this.oldValue = this.currentNameButton;

			}

			this.unfoldCmp = false;
			this.showComents = false;
			this.isCPositiva = false;
			if (!this.isPenfir) { this.isPenfir = true; } else { this.isPenfir = false; }
			this.isInsistir = false;
			this.isInsistirNo = false;
			this.showState = false;
			this.pfClass = (this.pfClass == this.classMapDefault[e.target.name])
				? this.classMap[e.target.name]
				: this.classMapDefault[e.target.name];
		}
	}

	handleMain() {
		this.dispatchEvent(
			new CustomEvent('mainclick', {
				detail: {
					oppoId: this.id
				}
			})
		);
	}

	@api
	handleVincular() {

		if (this.vinculed == true) {
			this.agendadoClass = this.classMap['agendado'];
		} else {
			this.agendadoClass = this.classMapDefault['agendado'];
		}
		this.dispatchEvent(
			new CustomEvent('vinculateaction', {
				detail: {
					sum: this.vinculed,
					oppoId: this.id
				}
			})
		);
	}

	sendDataToController() {
		this.dispatchEvent(
			new CustomEvent('senddatafromoppo',
				{
					detail: {
						id: this.id,
						newPath: this.statusNow,
						Name: this.name,
						ProdId: this.mainPF,
						probabilidad: this.probabilidad,
						importe: this.amount,
						comentario: this.comentario,
						mainVinculed: this.mainVinculed,
						isVinculed: this.vinculed,
						recordtype: this.oppo.RecordType,
						divisa: this.divisa,
						impactoBalance: this.impactoBalance,
						impactoComisiones: this.impactoComisiones,
						entidad: this.entidad,
						vencimiento: this.vencimiento,
						precio: this.precio,
						margen: this.margen,
						confidencial: this.confidencial,
						esg: this.esg,
						isEditable: this.isEditable,
						proximaGestion: this.proximaGestion,
						oppoDate: this.oppoDate,
						state: this.state,
						fechaCierre: this.fechaCierre,
						fechaProxGest: this.fechaProxGest,
						ownerId: this.owner,
						accountId: this.cliente
					}
				})

		)
	}

	handleChangeDivisa(e) {
		this.divisa = e.target.value;
		this.sendDataToController();
	}

	handleChangeImpactoBalance(e) {
		this.impactoBalance = e.target.value;
		this.sendDataToController();
	}

	handleChangeImpactoComisiones(e) {
		this.impactoComisiones = e.target.value;
		this.sendDataToController();
	}

	handleChangeEntidad(e) {
		this.entidad = e.target.value;
		this.sendDataToController();
	}

	handleChangeVencimiento(e) {
		this.vencimiento = e.target.value;
		this.sendDataToController();
	}

	handleChangePrecio(e) {
		this.precio = e.target.value;
		this.sendDataToController();
	}

	handleChangeMargen(e) {
		this.margen = e.target.value;
		this.sendDataToController();
	}

	handleConfidencial(e) {
		this.confidencial = e.target.checked;
		this.sendDataToController();
	}

	handleESG(e) {
		this.esg = e.target.checked;
		this.sendDataToController();
	}

	handleChangeProbabilidad(e) {
		this.probabilidad = e.target.value;
		this.sendDataToController();
	}

	handleChangeEstado(e) {
		this.state = e.target.value;
		if (this.state != null) {

			updateClosed({ recordId: this.oppo.id, cerradoNegativo: this.state })
				.then((result => {
					this.showToast("Éxito", "Oportunidad actualizada correctamente", "success");
				}))
				.catch((error => {
					console.log(error);
				}))

			vinculateOpportunity({ recordId: this.newEventHeaderId, opportunityId: this.oppo.id })
				.then((result => {
					this.dispatchEvent(new CustomEvent('resfreshdata'))
				}))
				.catch((error => {
					console.log(error);
				}))
		}
		this.sendDataToController();
	}

	updateClosePositively() {
		updateChecked({ recordId: this.oppo.id })
			.then((result) => {
				this.showToast("Éxito", "Oportunidad actualizada correctamente", "success");
			})
			.catch((error => {
				console.log('error ', error);
			}))
	}

	handleChangeImportePropio(e) {
		this.amount = e.detail.value;
		this.sendDataToController();

	}

	handleChangeFechaCierre(e) {
		this.fechaCierre = e.detail.value;
		this.sendDataToController();
		var hoyms = Date.now();
		const hoy = new Date(hoyms);
		hoy.setHours(0);
		hoy.setMinutes(0);
		hoy.setSeconds(0);
		const dfc = new Date(this.fechaCierre);
		dfc.setHours(0);
		dfc.setMinutes(1);
		var fechaMax = new Date(hoyms);
		fechaMax.setDate(fechaMax.getDate() + 547);
		if (this.fechaCierre != undefined && this.id != null && this.id.startsWith('006') && dfc < fechaMax && (dfc > hoy) &&
			(this.statusNow != this.CERRADOPOSI || this.statusNow != this.CERRADONEGA)) {
			this.handleSavePF();
		} else {
			if ((!this.id.includes(IDPROVISIONAL))) {
				//this.showToast('Error','Introduzca una fecha de cierre no inferior desde la fecha actual o superior a 18 meses','Error');
			}
		}
		this.sendDataToController();
	}
	handleChangeFechaProxGestion(e) {
		this.fechaProxGest = e.detail.value;
		this.sendDataToController();
		var hoyms = Date.now();
		const hoy = new Date(hoyms);
		hoy.setHours(0);
		hoy.setMinutes(0);
		hoy.setSeconds(0);
		const dfpg = new Date(this.fechaProxGest);
		dfpg.setHours(0);
		dfpg.setMinutes(1);
		if (this.id != null && this.id.startsWith('006') && this.fechaProxGest != undefined
			&& this.fechaProxGest < this.fechaCierre && (dfpg > hoy)) {
			this.handleSavePF();
		} else {
			if ((!this.id.includes(IDPROVISIONAL))) {
				//this.showToast('Error','La fecha de próxima gestión no puede ser superior a la fecha de cierre ni inferior a la fecha actual ','Error');
			}
		}
		this.sendDataToController();
	}

	handleChangeComentario(e) {
		this.comentario = e.target.value;
		this.sendDataToController();
		const returnValues = {
			Id: this.id,
			AV_Comentarios__c: this.comentario
		};
		const fields = Object.assign({}, returnValues);
		const recordInput = { fields };
		if (this.id != null && this.id.startsWith('006')) {
			this.showSpinner = true;
			updateRecord(recordInput).then(() => {
				this.showToast("Éxito", "Oportunidad actualizada correctamente", "success");
				this.showSpinner = false;
			}).catch(error => {
				console.log(error);
				this.showSpinner = false;
			});
		}
	}

	openDetailWindow() {
		this.isModalOpen = true;
	}

	closeModal() {
		this.isModalOpen = false;
	}

	handleSave() {
		this.sendDataToController();
		this.isModalOpen = false;
	}

	handleSavePF() {
		this.showSpinner = true;
		const returnValues = {
			Id: this.id,
			AV_FechaProximoRecordatorio__c: this.fechaProxGest,
			CloseDate: this.fechaCierre,
			AV_Comentarios__c: this.comentario
		};
		const fields = Object.assign({}, returnValues);
		const recordInput = { fields };
		updateRecord(recordInput).then(() => {
			this.showToast("Éxito", "Oportunidad actualizada correctamente", "success");
			this.showSpinner = false;
		}).catch(error => {
			console.log(error);
			this.showSpinner = false;
		});

	}

	handleSave2() {
		this.showSpinner = true;
		this.isGuardarDisabled = true;

		var amountAux = this.amount != this.oppo.amount ? this.amount : this.oppo.amount;
		var impactoBalanceAux = this.impactoBalance != this.oppo.impactoBalance ? this.impactoBalance : this.oppo.impactoBalance;
		var esgAux = this.esg != this.oppo.ESG ? this.esg : this.oppo.ESG;
		var probabilidadAux = this.probabilidad != null && this.probabilidad != undefined ? this.probabilidad : 'Media';//
		var comentarioAux = this.comentario != null ? this.comentario : '';//
		var divisaAux = this.divisa != this.oppo.divisa ? this.divisa : this.oppo.divisa;
		var comisionesAux = this.impactoComisiones != null ? this.impactoComisiones : '';//
		var entidadAux = this.entidad != this.oppo.entity ? this.entidad : this.oppo.entity;//
		var fechaVencimientoAux = this.vencimiento != this.oppo.vencimiento ? this.vencimiento : this.oppo.vencimiento;
		var importeOOAux = this.precio != this.oppo.price ? this.precio : this.oppo.price;
		var margenAux = this.margin != this.oppo.margin ? this.margin : this.oppo.margin;
		var confidencialAux = this.confidencial != this.oppo.confidential ? this.confidencial : this.oppo.confidential;

		const returnValues = {
			Id: this.id,
			CIBE_AmountDivisa__c: amountAux,
			CIBE_BalanceDivisa__c: impactoBalanceAux,
			CIBE_ESG__c: esgAux,
			CIBE_ProbabilidadExito__c: probabilidadAux,
			AV_Comentarios__c: comentarioAux,
			CIBE_Divisa__c: divisaAux,
			CIBE_ComisionesDivisa__c: comisionesAux,
			AV_Entidad__c: entidadAux,
			AV_FechaVencimiento__c: fechaVencimientoAux,
			CIBE_ImporteOtraEntidad__c: importeOOAux,
			CIBE_Margen__c: margenAux,
			AV_ClienteConfidencial__c: confidencialAux
		};

		const fields = Object.assign({}, returnValues);
		const recordInput = { fields };

		if (this.id != null && this.id.startsWith('006')) {

			updateRecord(recordInput).then(() => {
				this.showToast("Éxito", "Oportunidad actualizada correctamente", "success");
				this.isModalOpen = false;
				this.showSpinner = false;
				this.isGuardarDisabled = false;
			}).catch(error => {
				console.log(error);
				this.isModalOpen = false;
				this.showSpinner = false;
				this.isGuardarDisabled = false;
			});

		} else {

			this.isModalOpen = false;
			this.showSpinner = false;
			this.isGuardarDisabled = false;

		}
	}

	@api
	highlightBadInput() {
		this.template.querySelector('[data-id="mainDiv"]').style.border = "solid 1.5px rgba(255,0,0,1)";
		let interval;
		let opacity = 1;
		setTimeout(
			() => {
				interval = setInterval(
					() => {
						opacity -= 0.15;
						this.template.querySelector('[data-id="mainDiv"]').style.border = 'solid 1.5px rgba(255,0,0,' + opacity + ')';
						if (opacity < 0) {
							this.template.querySelector('[data-id="mainDiv"]').style.border = '';
							clearInterval(interval);
						}
					}
					, 50);
			}
			, 500);
	}

	@track optionsProbabilidad = [
		{ label: this.label.alta, value: 'Alta' },
		{ label: this.label.media, value: 'Media' },
		{ label: this.label.baja, value: 'Baja' }
	];
	@track optionsEstado = [
		{ label: this.label.anulada, value: 'Anulada' },
		{ label: this.label.competencia, value: 'Competencia' },
		{ label: this.label.desistidaCliente, value: 'Desistida cliente' },
		{ label: this.label.desistidaOficina, value: 'Desistida comité sucursal/oficina' },
		{ label: this.label.producto, value: 'Producto' },
		{ label: this.label.riesgos, value: 'Riesgos' },
		{ label: this.label.precio, value: 'Precio' },
		{ label: this.label.denegadaPoliticaFinanciacionSostenible, value: 'Denegada por Política ESG' },
		{ label: this.label.otros, value: 'Otros' },
		{ label: 'No volver a ofrecer el producto', value: 'No volver a ofrecer el producto' },
		{ label: 'No gestionada', value: 'No gestionada' }
	];
	@wire(getObjectInfo, { objectApiName: opportunity_Object })
	opportunityObjectMetadata;

	@track optionsDivisa = [];
	@wire(getPicklistValues, { recordTypeId: "$opportunityObjectMetadata.data.defaultRecordTypeId", fieldApiName: divisa_FIELD })
	wirePickList({ error, data }) {
		if (data) {
			this.optionsDivisa = data.values;
		} else if (error) {
			console.log(error);
		}
	}
	scrollIntoElement(id) {
		this.template.querySelector('[data-id="' + id + '"]').scrollIntoView({
			behavior: 'auto',
			block: 'center',
			inline: 'center'
		});;
	}

	// metodo para crear opp desde el lookup
	updateOrCreateOpportunities() {
		//this.palabrasProhibidas();
		createOrUpdateOpportunities({ opposToInsertOrUpdate: this.oppoObj, accountId: this.cliente, dateIni: this.dateIniFinal })
			.then(result => {
				if (result.errorList == null) {
					this.oppoObj = result.editedOpportunities;
					this.checkOnOffTasksBackUp = result.taskToRestoreBack;
					this.caosCheckOnOffBackUp = result.caoToRestoreBack;
					this.taskAndOpposRel = result.taskOpposRelation;
					for (let oppo in this.oppoObj) {
						if (oppo.includes(IDPROVISIONAL)) {
							this.createdOpposIds.push(this.oppoObj[oppo]['id']);
						}
					}
					this.vinculateOpportunities();
				} else {
					result.errorList.forEach(err => {
						console.log('error ', err);
					})
					// this.deleteEventRegisters();
					//BACKUP ATTENDES
				}
			}).catch(error => {
				//BACKUP ATTENDES
				console.log('error ', error);
				// this.deleteEventRegisters();
			});
	}


	// vincula cuando crea opp desde el lookup
	vinculateOpportunities() {
		let preBuildCaoList = [];
		let updatedOrCreatedOppos = [];
		let idEventoCreandose = this.newEventHeaderId != null ? this.newEventHeaderId : this.eventid;
		for (let id in this.oppoObj) {
			let currentOppo = this.oppoObj[id]
			updatedOrCreatedOppos.push(currentOppo['id'])
			preBuildCaoList.push(
				{
					AV_Opportunity__c: currentOppo['id'],
					AV_Task__c: this.newEventHeaderId,
					AV_IsMain__c: this.template.querySelector('[data-id="' + id + '"]').mainVinculed,
					AV_OrigenApp__c: 'AV_SalesforceClientReport'
				}
			);
		}

		vinculateOpportunitiesWO({
			caosToInsert: preBuildCaoList,
			evtId: idEventoCreandose
		})
			.then(result => {
				// if(this.newEvent['confidencial'] == true ){
				updateAccessList({ recordId: idEventoCreandose })
					.then((result => {
					}))
					.catch((error => {
						console.log(error);
					}))
				// }
			}).catch(error => {
				console.log(error);
			});
	}



	openDeleteWindow() {
		this.isModalDeleteOpen = true;
	}

	closeDeleteWindow() {
		this.isModalDeleteOpen = false;
	}

	handleDelete() {
		const deleteEvent = new CustomEvent('deleteoppo', {
			detail: this.oppo.id
		});
		this.dispatchEvent(deleteEvent);
	}
}