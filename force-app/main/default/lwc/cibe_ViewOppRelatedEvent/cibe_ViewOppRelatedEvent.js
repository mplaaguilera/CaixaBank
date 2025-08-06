import { LightningElement,wire,track, api }    	from 'lwc';
import { NavigationMixin } 						from 'lightning/navigation';
import { ShowToastEvent } 						from 'lightning/platformShowToastEvent';
import { CurrentPageReference  } 	   		   	from 'lightning/navigation';
import USER_ID              					from "@salesforce/user/Id";
import { refreshApex } from '@salesforce/apex';
import { createRecord } from "lightning/uiRecordApi";






//labels
import add from '@salesforce/label/c.CIBE_Add';
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
import estado from '@salesforce/label/c.CIBE_Estado';  
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
import oportunidades from '@salesforce/label/c.CIBE_Oportunidades';
import vinculadas from '@salesforce/label/c.CIBE_Vinculadas';
import newOpportunity from '@salesforce/label/c.CIBE_New_Opportunity';
import nuevaOportunidad from '@salesforce/label/c.CIBE_New_Opportunity';

const PROXIMGESTIONLABEL = 'Próxima Gestión';
const NOOFRECERLABEL = 'No ofrecer hasta';
const IDPROVISIONAL = 'idProvisional';
const SEPARADOR = '{|}';

//clases
import getOpportunitiesFromEvent					from '@salesforce/apex/CIBE_NewEventOppDetail_Controller.getOpportunitiesFromEvent';
import geTaskFromEvent					from '@salesforce/apex/CIBE_NewEventTaskDetail_Controller.geTaskFromEvent';
import geCountRelated     		   			from '@salesforce/apex/CIBE_NewEventTaskDetail_Controller.geCountRelated';
import geCountRelatedOpp     		   			from '@salesforce/apex/CIBE_NewEventOppDetail_Controller.geCountRelated';
import insertTask     		   			from '@salesforce/apex/CIBE_NewEventTaskDetail_Controller.insertTask';
import getEvent     		   			from '@salesforce/apex/CIBE_NewEventTaskDetail_Controller.getEvent';
import getActivityDate    		   			from '@salesforce/apex/CIBE_NewEventOppDetail_Controller.getActivityDate';



export default class cibe_ViewOppRelatedEvent extends NavigationMixin(LightningElement) {

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
        oportunidades,
        vinculadas,
		newOpportunity,
		nuevaOportunidad,
		add
	};
	isFuture
	idProvisional = 0;
	@api oppislinked;
	@api isEditable;
	@api proximaGestion
    @api recordId;
	@api newEventHeaderId;
	@track loadingOppos = false;
	@api oppo;
	@api tsk;
	@api eventid;
	@api taskid;
	//@api comesfromevent;
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
	statusNow;
	statusNowLabel;
	owner;
	userId = USER_ID;
	accountId;
	isOwner;

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
	isAgendado = false;
	@track especialInputLabel = PROXIMGESTIONLABEL;
	@api potentiallist;
	@api resolutionlist;
	@track showState= false; // variable para mostrar campos del tercer boton

	@api actionSetting = 'CIBE_AltaDeEvento';

    //traerse las oppo
    listAccountOpportunities = [];
    listAccountTask = [];

	arrowClass = "customArrowRightDefault";
	agendadoClass = "customEventDefault";
	checkClass = "customCheckDefault";
	closeClass = "customCloseDefault";
	banClass = "customBanDefault";
	POTENCIAL = 'Potencial';
	GESTION = 'En gestión/insistir';
	CERRADOPOSI = 'CIBE_Cerrado positivo'
	CERRADONEGA = 'Cerrado negativo'
	VENCIDO = 'Vencido';

	labelsMap = {
		'En curso': this.label.enCurso,
		'Ongoing': this.label.enCurso,
		'Potencial': this.label.potencial,
		'Potential': this.label.potencial,
		'Pendiente de firma': this.label.pendienteFirma,
		'Sign Pending': this.label.pendienteFirma,
		'Vencido': this.label.vencida,
		'Out of Date': this.label.vencida,
		'Cerrada positiva':this.label.cerradoPositivo,
		'Closed Positively':this.label.cerradoPositivo,
		'Cerrada negativa':this.label.cerradoNegativo,
		'Closed Negatively':this.label.cerradoNegativo,
		'CIBE_Pendiente_Firma': this.label.pendienteFirma,
		'CIBE_Vencido': this.label.vencida,
		'CIBE_Cerrado positivo': this.label.cerradoPositivo,
		'Cerrado negativo': this.label.cerradoNegativo
	}
	pathMap = {
		'check':this.CERRADOPOSI,
		'close':this.CERRADONEGA,
		'ban':this.CERRADONEGA
	}
	classMap = {
		'arrow':'customArrowRight',
		'agendado':'customEvent',
		'check':'customCheck',
		'close':'customClose',
		'ban':'customBan'
	}
	classMapDefault = {
		'arrow':'customArrowRightDefault',
		'agendado':'customEventDefault',
		'check':'customCheckDefault',
		'close':'customCloseDefault',
		'ban':'customBanDefault'
	}
	find = '';
	pathToSend;
	proximaGestionToSend;
	expectativaToSend;
	importePropioToSend;
	comentarioToSend;
	subProductoToSend = null;
	deleteCheckOnOffTask;
	isModalOpen = false;
	isToggleActive = false;
	get todayString() { return new Date().toJSON().slice(0,10)};
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

	@track probabilidad = 'Media';
	@track state;
	@track nameTask;
	@track activityDate;
	@track taskNewList = [];

	@track loading = false;
	@track _wiredData;

	getOpportunitiesFromEvent(){
		this.loadingOppos = true;
		getOpportunitiesFromEvent({eventId:this.recordId})
		.then(result => {
			if(result != null){
				this.eventid = this.recordId;
				this.listAccountOpportunities = result;
			}
			this.loadingOppos = false;
		}).catch(error => {
			this.loadingOppos = false;
			console.log(error);
		})
	}

	startload(){
		this.loadingOppos = true;
	}
	@track _wiredDataTask;
	geTaskFromEvent(){
		this.loading = true;
		geTaskFromEvent({eventId:this.recordId})
		.then(result => {

			if (result)  { 
				this.eventid = this.recordId;
				this.listAccountTask = [];
				this.listAccountTask = result;
				
			} else if (error) {
				console.log(error);
			}
			this.loading = false;
		}).catch(error => {
			this.loading = false;
			console.log(error);
		})	
	}
	recountoppos(){
		this.geCountRelatedOpp();
	}

	recounttasks(){
		this.getCountsRelated();
		
	}

	refreshDatatask(){
		this.geTaskFromEvent();
	}
	refreshDataoppo(){
		this.getOpportunitiesFromEvent();

	}
	connectedCallback(){
		this.getOpportunitiesFromEvent();
		this.geTaskFromEvent();
		this.getCountsRelated();
		this.geCountRelatedOpp();
	}

	@track _wiredDataCount
	@track contador;
	// @wire(geCountRelated, {eventId:'$recordId'})
	// getCountsRelated(_wiredDataCount){
	// 	this._wiredDataCount = _wiredDataCount;
    //     const {data, error} = _wiredDataCount;
	// 	console.log('entro al wired');
	// 	console.log('entro al wired');
	// 	if (data)  { 	
	// 		// this.contadorOpp = data[0].total;
	// 		this.contador = data[0].total;
	// 	} else if (error) {
	// 		console.log(error);
	// 	}
	// }
	
	
	getCountsRelated(){
		this.loading = true;
		geCountRelated({eventId : this.recordId})
		.then(result => { 
			if (result != null)  {	
				this.contador = result[0].total;
				this.geTaskFromEvent();
			} else if (error) {
				console.log(error);
			}
			this.loading = false;
		}		
	).catch(error => {
		console.log(error);
		this.loading = false;
	})
	}

	@track contadorOpp;
	@track _wiredDataCountOpp
	// @wire(geCountRelatedOpp, {eventId:'$recordId'})
	geCountRelatedOpp(){
		this.loadingOppos = true;
		geCountRelatedOpp({eventId : this.recordId}) 
		.then( result => { 
			if (result != null)  { 	
				// this.contadorOpp = data[0].total;
				this.contadorOpp = result;
				this.getOpportunitiesFromEvent();
			}
			this.loadingOppos = false;
		}).catch(error => {
			console.log(error);
			this.loadingOppos = false;
		})
	}

	handleComboBoxChange(){
		this.isModalOpen = true;
		if(this.actionSetting != 'CIBE_New_Opportunity'){
			this.actionSetting = 'CIBE_New_Opportunity';
		}
		this.inputVariables = [{
			name: 'recordId',
			type: 'String',
			value: this.recordId
		}];
		this.flowlabel = this.label.newOpportunity;
		this.flowName = this.actionSetting;
	}

	handleStatusChangeOpp(event) {
		const status = event.detail.status;
		if(status === 'FINISHED_SCREEN' || status === "FINISHED") {
			this.isModalOpen = false;
			this.geCountRelatedOpp();
		}
	}

	closeModal(){
		this.isModalOpen = false;
	}

	handleNewTask(event){
		this.nameTask = event.target.value;
	}

	@wire(getEvent, {recordId:'$recordId'})
	getEvent({error, data}) { 
		if (data)  { 	
			this.accountId = data[0].AccountId;
			this.activityDate = data[0].ActivityDate;
		} else if (error) {
			console.log(error);
		}
	}



	//nueva tarea
	handleAddTask(){
		if(this.nameTask != null && this.nameTask != ''){
			this.loading = true;
			this.taskNewList.push(
				{
					Subject:this.nameTask,
					ActivityDate: this.activityDate,
					Status:'Open',
					AccountId: this.accountId,
					WhatId: this.accountId, 
					OwnerId: this.userId
				}
			);
			this.nameTask = null;
			insertTask({record: this.taskNewList, recordId: this.recordId})
			.then((result => {
				if(result == 'OK'){
					this.taskNewList = [];
					this.showToast('','Tarea insertada correctamente','success');
					this.getCountsRelated();
				}else{
					this.showToast('','Error al insertar la tarea','error');
				}
				
				this.loading = false;
			}))
			.catch((error =>{
				this.loading = false;
				this.showToast('','Error al insertar la tarea','error');
				console.log(error);
			}))
		}
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

	@track _wiredDataFecha;
	@wire(getActivityDate, {eventId:'$recordId'})
    getActivityDate(result) { 
		this._wiredDataFecha = result;
		const {data, error} = this._wiredDataFecha;
		if (data)  {
			this.isFuture = data;
		} else if (error) {
			console.log(error);
		}
	}
}