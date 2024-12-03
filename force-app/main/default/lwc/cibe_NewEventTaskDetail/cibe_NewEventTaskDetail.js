import { LightningElement, api, track, wire } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import USER_ID from "@salesforce/user/Id";


//labels
import mainOpp from '@salesforce/label/c.AV_MainOpportunity';
import markMainOpp from '@salesforce/label/c.AV_MarkMainOpportunity';
import statusOpp from '@salesforce/label/c.CIBE_CurrentStatus';
import fechaCierre from '@salesforce/label/c.CIBE_FechaCierre';
import agendar from '@salesforce/label/c.CIBE_Agendar';
import gestionadaPositiva from '@salesforce/label/c.CIBE_GestionadaPositiva';
import gestionadaNegativa from '@salesforce/label/c.CIBE_GestionadaNegativa';
import pendiente from '@salesforce/label/c.CIBE_Pendiente';
import pendienteNoLocalizado from '@salesforce/label/c.CIBE_PendienteNoLocalizado';
import ultComentario from '@salesforce/label/c.CIBE_LastComment';

import vinculateTask from '@salesforce/apex/CIBE_NewEventTaskDetail_Controller.vinculateTask';
import disVinculateTask from '@salesforce/apex/CIBE_NewEventTaskDetail_Controller.disVinculateTask';


const IDPROVISIONAL = 'idProvisional';
const SEPARADOR = '{|}';

export default class cibe_newEventTaskDetail extends NavigationMixin(LightningElement) {

	label = {
		agendar, gestionadaPositiva, gestionadaNegativa,
		mainOpp,
		markMainOpp,
		statusOpp,
		fechaCierre,
		ultComentario,
		pendiente,
		pendienteNoLocalizado
	};

	@api isFuture;
	@api gestionAgil;
	isInsistir = false;

	@api isEditable;
	@api newEventHeaderId;
	@api tarea;
	@api noEvento;
	// @api comesfromevent;
	@track id;
	@track name;
	@track status;
	@track path;
	@track tareaDate;
	@track tareaDateFront;
	@track comentario;
	@track isInserted = true;
	@track historyCommentWithDate;
	@track historyComment;
	@track historyCommentDate;
	@track historyCommentDateLabel;
	@track allCheck = false;
	statusNow;
	statusNowLabel;
	@track owner;
	@track userId = USER_ID;
	@track isOwner;
	@track tipo;
	@track personaContacto;

	checkedOld; // Guarda si está seleccionada o deseleccionada
	currentNameButton;
	// @api vinculed = false;
	@api vinculed;

	@api mainVinculed = false;

	@track allStages = [];
	@track unfoldCmp = false; // variable para mostrar campos del primer boton
	@track showComents = true;
	@track isAgendado = false;

	@api potentiallist;

	firstClickNewOppo = true;
	headerId;

	agendadoClass = "customInsisDefault";
	checkClass = "customCheckDefault";
	closeClass = "customCloseDefault";
	insisClass = "customInsisDefault";
	arrowClass = "customArrowRightDefault";


	labelsMap = {

		'Gestionada positiva': this.label.gestionadaPositiva,
		'Managed Positevely': this.label.gestionadaPositiva,
		'Gestionada negativa': this.label.gestionadaNegativa,
		'Managed Negatively': this.label.gestionadaNegativa,
		'Pendiente': this.label.pendiente,
		'Pending': this.label.pendiente,
		'Pendiente no localizado': this.label.pendienteNoLocalizado,
		'Pending not located': this.label.pendienteNoLocalizado

	}
	pathMap = {
		'check': this.label.gestionadaPositiva,
		'close': this.label.gestionadaNegativa
	}
	classMap = {
		'agendado': 'customInsis',
		'check': 'customCheck',
		'close': 'customClose',
		'arrow': 'customArrowRight',
		'insistir': 'customInsis'
	}
	classMapDefault = {
		'agendado': 'customInsisDefault',
		'check': 'customCheckDefault',
		'close': 'customCloseDefault',
		'penfir': 'customPFDefault',
		'insistir': 'customInsisDefault',
		'arrow': 'customArrowRightDefault'
	}

	@api showName;


	get todayString() { return new Date().toJSON().slice(0, 10) };

	connectedCallback() {
		this.fillVars();
	}

	renderedCallback() {
		if (this.id.includes(IDPROVISIONAL) && this.firstClickNewOppo) {
			this.agendadoClass = this.classMap['agendado'];
			if (this.template.querySelector('[data-id="insistir"]') != null) {
				this.template.querySelector('[data-id="insistir"]').click();
			} else {
				this.insisClass = this.classMap['insistir'];
				this.isInsistir = true;
			}
			if (this.template.querySelector('[data-id="agendado"]') != null) {
				this.template.querySelector('[data-id="agendado"]').click();
			}
			this.firstClickNewOppo = false;
		} else {
			if (this.firstClickNewOppo && this.vinculed && this.template.querySelector('[data-id="agendado"]') != null) {
				this.agendadoClass = this.classMap['agendado'];
				this.template.querySelector('[data-id="agendado"]').click();
				this.firstClickNewOppo = false;
			} else if (this.firstClickNewOppo && this.vinculed && this.template.querySelector('[data-id="agendado"]') == null) {
				this.agendadoClass = this.classMap['agendado'];
				this.firstClickNewOppo = false;
			}
		}

		if (this.firstClickNewOppo) {
			this.firstClickNewOppo = false;
			this.sendDataToController();

		}
		this.sendDataToController();

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
		this.tareaDate = this.tarea.activityDate;
		this.headerId = this.tarea.headerId;
		this.id = this.tarea.id != undefined ? this.tarea.id : IDPROVISIONAL;
		this.rt = this.tarea.rt;
		this.accountId = this.tarea.accountId;
		this.name = this.tarea.subject;
		this.status = this.tarea.status;
		this.owner = this.tarea.owner;
		this.comentario = this.tarea.comments;
		this.historyCommentWithDate = this.tarea.commentsLastModifieddate;
		this.isInserted = (this.tarea.notInserted == undefined);
		this.tipo = this.tarea.tipo;
		this.personaContacto = this.tarea.personaContacto;

		if (this.historyCommentWithDate != '' && this.historyCommentWithDate != undefined) {
			this.historyCommentDate = this.historyCommentWithDate.split('T')[0];
			this.historyComment = this.historyCommentWithDate.split(SEPARADOR)[1];
			this.historyCommentDateLabel = this.label.ultComentario + ' - ' + this.historyCommentDate;
		} else {
			this.historyCommentDateLabel = '';

		}

		if (this.tarea.activityDate != null) {
			var [year, month, day] = this.tarea.activityDate.split('-');
			day = day.lenght < 2 ? '0' + day : day;
			month = month.lenght < 2 ? '0' + month : month;
			this.tareaDate = this.tarea.activityDate;
			this.tareaDateFront = day + '-' + month + '-' + year;

		}

		if (this.owner == this.userId) {
			this.isOwner = true;
		} else {
			this.isOwner = false;
		}

		this.vinculed = this.tarea.isVinculated;
		this.mainVinculed = this.tarea.isPrincipal;
		this.isEditable = this.tarea.isEditable;
	}

	navigateToRecord(event) {
		let recordToGo = event.target.name;
		this[NavigationMixin.Navigate]({
			type: 'standard__recordPage',
			attributes: {
				objectApiName: 'Account',
				recordId: recordToGo,
				actionName: 'view'
			}
		})
	}

	resetCustomButtons(buttonToAvoid) {
		if (buttonToAvoid != 'agendado') {
			this.agendadoClass = this.classMapDefault['agendado'];
			this.insisClass = this.classMapDefault['agendado'];
		}
		if (buttonToAvoid != 'check') {
			this.checkClass = this.classMapDefault['check'];
		}
		if (buttonToAvoid != 'close') {
			this.closeClass = this.classMapDefault['close'];
		}
	}

	@track oldValue;
	handlePath(e) {

		this.template.querySelector('[data-id="' + e.target.name + '"]').blur();
		this.resetCustomButtons(e.target.name);

		this.currentNameButton = e.target.name;
		this.path = this.pathMap[e.target.name];
		let beforeVinculed = this.vinculed;
		if (this.currentNameButton === 'noAgendado') {
			this.vinculed = false;
			this.isPrincipal = false;
			this.status = this.tarea.status;
			this.oldValue = (this.oldValue === this.currentNameButton) ? null : this.currentNameButton;
			this.insisClass = this.classMapDefault['noAgendado'];

		} else if (this.currentNameButton === 'agendado') {
			this.oldValue = (this.oldValue === this.currentNameButton) ? null : this.currentNameButton;
			this.status = this.tarea.status;
			this.vinculed = true;
			this.insisClass = this.classMap['agendado'];

		} else if (this.currentNameButton === 'check') {
			if (this.oldValue == this.currentNameButton) {
				this.status = this.tarea.status;
				this.oldValue = null;
			} else {
				this.status = this.path;
				this.oldValue = this.currentNameButton;

			}
			this.vinculed = true;

			this.checkClass = (this.checkClass == this.classMapDefault[e.target.name])
				? this.classMap[e.target.name]
				: this.classMapDefault[e.target.name];
			this.agendadoClass = this.classMap['agendado'];

			if (this.oldValue !== this.currentNameButton && !(this.currentNameButton == 'agendado' && this.currentNameButton == 'noAgendado')) {
				this.vinculed = !this.vinculed;
			}

		} else if (this.currentNameButton === 'close') {
			if (this.oldValue == this.currentNameButton) {
				this.status = this.tarea.status;
				this.oldValue = null;
			} else {
				this.status = this.path;
				this.oldValue = this.currentNameButton;
			}

			this.vinculed = true;

			this.closeClass = (this.closeClass == this.classMapDefault[e.target.name])
				? this.classMap[e.target.name]
				: this.classMapDefault[e.target.name];
			this.agendadoClass = this.classMap['agendado'];

			if (this.oldValue !== this.currentNameButton && !(this.currentNameButton == 'agendado' && this.currentNameButton == 'noAgendado')) {
				this.vinculed = !this.vinculed;
			}
		}
		if (this.vinculed !== beforeVinculed) {
			if (!this.id.includes(IDPROVISIONAL)) {
				this.vinculed ? this.vinculate() : this.desvinculate();
				this.handleVincular();
			} else {
				this.handleVincular();
			}

		}
		this.sendDataToController();
	}

	@api handleMain() {
		this.dispatchEvent(
			new CustomEvent('mainclick', {
				detail: {
					tareaId: this.id
				}
			})
		);
	}

	allCheck = false;
	@api handleVinculateAllTask(isPrincipal) {
		this.allCheck = true;
		this.vinculed = true;
		this.mainVinculed = isPrincipal;
		if (this.vinculed == true) {
			this.agendadoClass = this.classMap['agendado'];

		} else {
			this.agendadoClass = this.classMapDefault['agendado'];
			this.checkClass = this.classMapDefault['check'];
			this.closeClass = this.classMapDefault['close'];
		}
		this.dispatchEvent(
			new CustomEvent('vinculateactionalltask', {
				detail: {
					sum: this.vinculed,
					tareaId: this.id,
					allCheck: this.allCheck
				}
			})
		);
	}

	@api handleDesvincularTask() {
		this.allCheck = false;
		this.isAgendado = false;
		this.vinculed = false;
		if (this.vinculed == true) {
			this.agendadoClass = this.classMap['agendado'];

		} else {
			this.agendadoClass = this.classMapDefault['agendado'];
			this.checkClass = this.classMapDefault['check'];
			this.closeClass = this.classMapDefault['close'];
		}

		this.dispatchEvent(
			new CustomEvent('desvinculartask', {
				detail: {
					sum: false,
					tareaId: this.id,
					main: false
				}
			})
		);
	}

	@api
	handleVincular() {
		if (this.vinculed) {
			this.agendadoClass = this.classMap['agendado'];
		} else {
			this.agendadoClass = this.classMapDefault['agendado'];
		}
		this.dispatchEvent(
			new CustomEvent('vinculateaction', {
				detail: {
					sum: this.vinculed,
					tareaId: this.id
				}
			})
		);
	}

	vinculate() {
		vinculateTask({ recordId: this.newEventHeaderId, taskId: this.id })
			.then((() => {
			}))
			.catch((error => {
				console.log(error);
			}))
	}

	desvinculate() {
		disVinculateTask({ recordId: this.newEventHeaderId, taskId: this.id })
			.then((() => {
			}))
			.catch((error => {
				console.log(error);
			}))
	}

	sendDataToController() {
		this.dispatchEvent(
			new CustomEvent('senddatafromtarea',
				{
					detail: {
						id: this.id,
						rt: this.rt,
						accountId: this.accountId,
						subject: this.name,
						tareaDate: this.tareaDate,
						status: this.status,
						owner: this.owner,
						comments: this.tarea.comments,
						commentsLastModifieddate: this.commentsLastModifieddate,
						vinculed: this.vinculed,
						mainVinculed: this.mainVinculed,
						headerId: this.headerId,
						isEditable: this.isEditable,
						comentario: this.comentario,
						tipo: this.tipo,
						personaContacto: this.personaContacto
					}
				})
		)
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

	scrollIntoElement(id) {
		this.template.querySelector('[data-id="' + id + '"]').scrollIntoView({
			behavior: 'auto',
			block: 'center',
			inline: 'center'
		});;
	}

	handleChangeComentario(e) {
		this.comentario = e.target.value;
		this.sendDataToController();
	}
}