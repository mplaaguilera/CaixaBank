import { LightningElement,api,track,wire } 	from 'lwc';
import { NavigationMixin } 				from 'lightning/navigation';
import { ShowToastEvent } 				from 'lightning/platformShowToastEvent';
import USER_ID              			from "@salesforce/user/Id";
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
import updateChecked     		   			from '@salesforce/apex/CIBE_NewEventOppDetail_Controller.updateChecked';
import updatePendienteFirma     		   	from '@salesforce/apex/CIBE_NewEventOppDetail_Controller.updatePendienteFirma';
import updateCanceled     		   			from '@salesforce/apex/CIBE_NewEventOppDetail_Controller.updateCanceled';
import updateClosed     		   			from '@salesforce/apex/CIBE_NewEventOppDetail_Controller.updateClosed';
import vinculateOpportunity     		   	from '@salesforce/apex/CIBE_NewEventOppDetail_Controller.vinculateOpportunity';
import disVinculateOpportunity     		   	from '@salesforce/apex/CIBE_NewEventOppDetail_Controller.disVinculateOpportunity';
import makePrincipal     		   			from '@salesforce/apex/CIBE_NewEventOppDetail_Controller.makePrincipal';
import getActivityDate    		   			from '@salesforce/apex/CIBE_NewEventOppDetail_Controller.getActivityDate';
import createOrUpdateOpportunities     		from '@salesforce/apex/CIBE_NewEventController.createOrUpdateOpportunities';


const PROXIMGESTIONLABEL = 'Próxima Gestión';
const NOOFRECERLABEL = 'No ofrecer hasta';
const IDPROVISIONAL = 'idProvisional';
const SEPARADOR = '{|}';

export default class Cibe_ViewOppRelatedDetail extends NavigationMixin(LightningElement) {

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
	// @api isEditable;
	@api isCPositiva;	
	@api proximaGestion
	

	@api newEventHeaderId;
	@api principal;
	// var cibe_ViewOppRelatedEvent
	@api oppo;
	@api eventid;
	@api main;
	// @api comesfromevent;
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
	//lmg
	@track values;
	statusNow;
	statusNowLabel;
	owner;
	userId = USER_ID;
	isOwner;
	// activityDate = ACTIVITY_DATE_ID;
	cero = 0;

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
	@api potentiallist;
	@api resolutionlist;
	@track showState= false; // variable para mostrar campos del estado Cerrado Negativo

	//Nombres Class CSS
	arrowClass = "customArrowRightDefault";
	agendadoClass = "customEventDefault";
	checkClass = "customCheckDefault";
	closeClass = "customCloseDefault";
	banClass = "customBanDefault";
	pfClass = "customPFDefault";
	insisClass="customInsisDefault";
	//estados
	POTENCIAL = 'Potencial';
	GESTION = 'En gestión/insistir';
	CERRADOPOSI = 'CIBE_Cerrado positivo'
	CERRADONEGA = 'Cerrado negativo'
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
		'ban':this.CERRADONEGA,
		'penfir':'CIBE_Pendiente_Firma'
	}
	classMap = {
		'arrow':'customArrowRight',
		'agendado':'customEvent',
		'check':'customCheck',
		'close':'customClose',
		'penfir':'customPF',
		'insistir':'customInsis'
	}
	classMapDefault = {
		'arrow':'customArrowRightDefault',
		'agendado':'customEventDefault',
		'check':'customCheckDefault',
		'close':'customCloseDefault',
		'penfir':'customPFDefault',
		'insistir':'customInsisDefault'
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
	@track isFuture = false;

	@track probabilidad = 'Media';
	@track state;
	oppoObj = {};
    checkOnOffTasksBackUp;
	caosCheckOnOffBackUp;
    taskAndOpposRel;
    createdOpposIds = [];

	connectedCallback(){
		this.fillVars();
	}
	
	@track _wiredData;
	@wire(getActivityDate, {eventId:'$eventid'})
    getActivityDate(result) { 
		this._wiredData = result;
		const {data, error} = this._wiredData;
		if (data)  {
			this.isFuture = data;
		} else if (error) {
			console.log(error);
		}
	}

	getTodayString(){
		let d = new Date();
		return d.getFullYear() + '-'+(d.getMonth() +1) +'-' + d.getDate()
	}
	
	renderedCallback(){
		if(this.id.includes(IDPROVISIONAL) && this.firstClickNewOppo){
			this.template.querySelector('[data-id="agendado"]').click();
			this.firstClickNewOppo = false;
		}
		if(this.firstClickNewOppo){
			this.firstClickNewOppo = false;
			this.sendDataToController();
		}
		this.sendDataToController();
	}

	parseTodayDate(){
		let a = new Date(Date.now());
		let month = this.fillNumbers(a.getMonth() +1);
		let day = this.fillNumbers(a.getDate());
		return a.getFullYear()+'-'+month+'-'+day; 
	}

	fillNumbers(n){
		return n > 9 ? "" + n: "0" + n;
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

	fillVars(){
		this.probabilidad = this.oppo.probability;
		this.impactoComisiones = this.oppo.comissionImpact,
		this.precio = this.oppo.price,
		this.divisa = this.oppo.divisa,
		this.impactoBalance = this.oppo.impactoBalance,
		this.esg = this.oppo.ESG,
		this.confidencial = this.oppo.confidential,
		this.entidad = this.oppo.entity,
		this.vencimiento = this.oppo.vencimiento,
		this.margen = this.oppo.margin,
		this.comentario = this.oppo.comments;
		// this.isEditable = this.oppo.isEditable;
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
		this.oppoDateFront = day + '-' + month + '-' + year;
		this.amount = this.oppo.amount == null ? '0' : this.oppo.amount;
		this.margin = this.oppo.margin;
		this.mainPF = this.oppo.productId;
		this.otraEntidad = this.oppo.entity;
		this.isInserted = (this.oppo.NotInserted == undefined);
		this.fechaCierre = this.oppo.closeDate;
		this.fechaProxGest = this.proximaGestion;
		this.vinculed = (this.oppo.isVinculed != undefined) ? this.oppo.isVinculed :  false;
		this.mainVinculed = false;
		this.historyCommentWithDate = this.oppo.commentsLastModifieddate;
		if(this.historyCommentWithDate != '' && this.historyCommentWithDate != undefined){
			this.historyCommentDate = this.historyCommentWithDate.split('T')[0];
			this.historyComment = this.historyCommentWithDate.split(SEPARADOR)[1];
			this.historyCommentDateLabel = this.label.ultComentario + ' - '  +this.historyCommentDate;
		}else{
			this.historyCommentDateLabel = '';
		}
		this.state = this.oppo.state;
		if(this.owner == this.userId){
			this.isOwner = true;
		}else{
			this.isOwner = false;
		}

        if(this.oppo.isVinculated){
            this.agendadoClass = this.classMap['agendado'];
            this.unfoldCmp = true;
            this.vinculed = true;
        }

        if(this.oppo.isPrincipal){
            this.mainVinculed = true;
        }
	}


	navigateToRecord(event){
		let recordToGo = event.target.name;
		this[NavigationMixin.Navigate]({
			type: 'standard__recordPage',
			attributes: {
				objectApiName: 'Opportunity',
				recordId: recordToGo,
				actionName:'view'
			}
		})
	}

	resetCustomButtons(buttonToAvoid){
		//Actualiza los que no son el seleccionado¿?
		if(buttonToAvoid != 'arrow' ){
			this.arrowClass = this.classMapDefault['arrow'];
		}    
		if(buttonToAvoid != 'agendado'){
			this.agendadoClass = this.classMapDefault['agendado'];
		}
		if(buttonToAvoid != 'check' ){
			this.checkClass = this.classMapDefault['check'];
		}
		if(buttonToAvoid != 'close'){
			this.closeClass = this.classMapDefault['close'];
		}
		if(buttonToAvoid != 'insistir'){
			this.insisClass = this.classMapDefault['insistir'];
		}
		if(buttonToAvoid != 'penfir'){
			this.pfClass = this.classMapDefault['penfir'];
		}
		// if(buttonToAvoid != 'ban'){
		// 	this.banClass = this.classMapDefault['ban'];            
		// }
	}
	buttonClicked;
	handleToggleClick() {
        this.buttonClicked = !this.buttonClicked; //set to true if false, false if true.
        this.cssClass = this.buttonClicked ? 'cssClass' : 'slds-button slds-button_destructive';
    }

	desvinculate(){
		disVinculateOpportunity({recordId: this.eventid, opportunityId: this.oppo.id})
		.then((result => {
			this.dispatchEvent(new CustomEvent('recountoppos'))
			
		}))
		.catch((error =>{
			console.log(error);
		}))

	}

	vinculate(){
		vinculateOpportunity({recordId: this.eventid, opportunityId: this.oppo.id})
		.then((result => {
			if(result == true){
				this.showToast('Error al actualizar', 'La fecha de próxima gestión no puede ser superior a la fecha de cierre ni inferior a la fecha actual', 'Error')
			}
			this.dispatchEvent(new CustomEvent('recountoppos'))
			if(this.principal){
				this.mainVinculed = true;
			}
		}))
		.catch((error =>{
			console.log(error);
		}))
	}

	oldValue;

	handlePath(e){
		this.dispatchEvent(new CustomEvent('startload'));
		this.template.querySelector('[data-id="'+e.target.name+'"]').blur();
		this.resetCustomButtons(e.target.name);
		this.currentNameButton = e.target.name;
		this.path = this.pathMap[e.target.name];
		let beforeVinculed = this.vinculed;
		if(this.currentNameButton === 'noAgendado'){
			this.vinculed = false;
			//this.isMain = false;
			this.unfoldCmp = false;
			this.showState = false;
			this.showComents = true;
			this.isPrincipal = false;
			this.isCPositiva = false;
			this.isInsistir = false;
		}else if(this.currentNameButton === 'agendado'){
			this.oldValue = (this.oldValue === this.currentNameButton) ? null : this.currentNameButton;
			this.statusNow = this.oppo.status;
			this.statusNowLabel = this.labelsMap[this.statusNow];
			this.unfoldCmp = true;
			this.vinculed = true;
			this.showComents = false;
			this.isCPositiva = false;
			this.isInsistir = false;
			this.showState = false;
			this.agendadoClass = this.classMap['agendado'];
		}
		this.unfoldCmp =  this.vinculed === false ? false : this.unfoldCmp ;
		if(beforeVinculed != this.vinculed){
			this.vinculed ? this.vinculate() : this.desvinculate();
			this.handleVincular();
		}
		this.sendDataToController();	
	}

	
	handleInsPath(e){
		this.currentNameButton = e.target.name;
		this.template.querySelector('[data-id="'+e.target.name+'"]').blur();
		this.resetCustomButtons(e.target.name);
		this.path = this.pathMap[e.target.name];

		if(this.currentNameButton === 'insistir'){
			vinculateOpportunity({recordId: this.eventid, opportunityId: this.oppo.id})
            .then((result => {
				if(result == true){
					this.showToast('Error al actualizar', 'La fecha de próxima gestión no puede ser superior a la fecha de cierre ni inferior a la fecha actual', 'Error')
				}
				this.dispatchEvent(new CustomEvent('resfreshdata'))
				if(this.principal){
                    this.mainVinculed = true;
                }
            }))
			this.oldValue = (this.oldValue === this.currentNameButton) ? null : this.currentNameButton;
			this.statusNow = this.oppo.status;
			this.statusNowLabel = this.labelsMap[this.statusNow];
			this.unfoldCmp = false;
			this.vinculed = true;
			this.showComents = false;
			this.isCPositiva = false;
			this.isInsistir = true;
			this.showState = false;

			this.insisClass = (this.insisClass == this.classMapDefault[e.target.name])
			? this.classMap[e.target.name]
			: this.classMapDefault[e.target.name];
		}
		this.sendDataToController();
	}
	handlePFPath(e){
		this.currentNameButton = e.target.name;
		this.template.querySelector('[data-id="'+e.target.name+'"]').blur();
		//Cambia las clases css de los botones no selecionados.
		this.resetCustomButtons(e.target.name);
		this.path = this.pathMap[e.target.name];//para que sirve esto, devuelve lo mismo que currentNameButton ¿?

		if(this.currentNameButton === 'penfir'){
			updatePendienteFirma({recordId: this.oppo.id})
            .then((result => {
				this.dispatchEvent(new CustomEvent('resfreshdata'));
            }))
            .catch((error =>{
                console.log(error);
            }))

			vinculateOpportunity({recordId: this.eventid, opportunityId: this.oppo.id})
            .then((result => {
				if(result == true){
					this.showToast('Error al actualizar', 'La fecha de próxima gestión no puede ser superior a la fecha de cierre ni inferior a la fecha actual', 'Error')
				}
				this.dispatchEvent(new CustomEvent('resfreshdata'))
				if(this.principal){
                    this.mainVinculed = true;
                }
            }))

			//REVISAR PARA QUE USAMOS EL OLDVALUE¿?
			this.oldValue = (this.oldValue === this.currentNameButton) ? null : this.currentNameButton;
			this.statusNow = this.oppo.status;
			this.statusNowLabel = this.labelsMap[this.statusNow];
			this.unfoldCmp = false;
			this.vinculed = true;
			this.showComents = false;
			this.isCPositiva = false;
			this.isInsistir = true;
			this.showState = false;
			this.pfClass = (this.pfClass == this.classMapDefault[e.target.name])
			? this.classMap[e.target.name]
			: this.classMapDefault[e.target.name];
		} 
		this.sendDataToController();
	}

	handleMain(){
		makePrincipal({recordId: this.eventid, opportunityId: this.oppo.id})
		.then((result => {
			this.dispatchEvent(new CustomEvent('resfreshdataoppo'))
		}))
		.catch((error =>{
			console.log(error);
		}))
	}

	@api
	handleVincular(){
		if (this.vinculed == true){
			this.agendadoClass = this.classMap['agendado'];
		} else{
			this.agendadoClass = this.classMapDefault['agendado'];
		}
		this.dispatchEvent(
			new CustomEvent('vinculateaction',{
				detail:{
					sum:this.vinculed,
					oppoId:this.id
				}
			})
		);
	}

	sendDataToController(){
		this.dispatchEvent(
			new CustomEvent('senddatafromoppo',
			{
				detail:{
					id:this.id,
					newPath:this.statusNow,
					Name:this.name,
					ProdId:this.mainPF,
					probabilidad:this.probabilidad,
					importe:this.amount,
					comentario:this.comentarioToSend,
					mainVinculed:this.mainVinculed,
					isVinculed:this.vinculed,
					recordtype:this.oppo.RecordType,
					divisa : this.divisa,
					impactoBalance: this.impactoBalance,
					impactoComisiones: this.impactoComisiones,
					entidad: this.entidad,
					vencimiento: this.vencimiento,
					precio: this.precio,
					margen:this.margen,
					confidencial:this.confidencial,
					esg:this.esg,
					// isEditable: this.isEditable,
					proximaGestion: this.proximaGestion,
					oppoDate: this.oppoDate,
					state: this.state,
					fechaCierre: this.fechaCierre,
					fechaProxGest: this.fechaProxGest
				}
			})
		)
	}

	handleChangeDivisa(e){
		this.divisa = e.target.value;
		this.sendDataToController();
	}
	
	handleChangeImpactoBalance(e){
		this.impactoBalance = e.target.value;
		this.sendDataToController();
	}

	handleChangeImpactoComisiones(e){
		this.impactoComisiones = e.target.value;
		this.sendDataToController();
	}

	handleChangeEntidad(e){
		this.entidad = e.target.value;
		this.sendDataToController();
	}

	handleChangeVencimiento(e){
		this.vencimiento = e.target.value;
		this.sendDataToController();
	}

	handleChangePrecio(e){
		this.precio = e.target.value;
		this.sendDataToController();
	}

	handleChangeMargen(e){
		this.margen = e.target.value;
		this.sendDataToController();
	}

	handleConfidencial(e){
		this.confidencial = e.target.checked;
		this.sendDataToController();
	}

	handleESG(e){
		this.esg = e.target.checked;
		this.sendDataToController();
	}

	handleChangeProbabilidad(e){
		this.probabilidad = e.target.value;
		this.sendDataToController();
	}

	handleChangeEstado(e){
		this.state = e.target.value;
		if(this.state != null ){
			updateClosed({recordId: this.oppo.id, cerradoNegativo: this.state})
			.then((result => {
				console.log('actualizado');
			}))
			.catch((error =>{
				console.log(error);
			}))
			vinculateOpportunity({recordId: this.eventid, opportunityId: this.oppo.id})
			.then((result => {
				if(result == true){
					this.showToast('Error al actualizar', 'La fecha de próxima gestión no puede ser superior a la fecha de cierre ni inferior a la fecha actual', 'Error')
				}
				this.dispatchEvent(new CustomEvent('resfreshdata'))
			}))
			.catch((error =>{
				console.log(error);
			}))
		}
		this.sendDataToController();
	}

	handleChangeImportePropio(e){
		this.amount = e.detail.value;
		this.sendDataToController();
	}

	handleChangeFechaCierre(e){
		this.fechaCierre = e.detail.value;
		if(this.fechaProxGest!=undefined){
			this.handleSavePF();
		}else{
			this.showToast("Warning","Es neceasior rellenar fecha próxima gestión","Warning");
		}
	}
	handleChangeFechaProxGestion(e){
		this.fechaProxGest = e.detail.value;
		if(this.fechaProxGest!=undefined){
			this.handleSavePF();
		}else{
			this.showToast("Warning","Es neceasior rellenar fecha próxima gestión","Warning");
		}
	}

	handleChangeComentario(e){
		const returnValues = {
            Id: this.id,
			AV_Comentarios__c: this.comentario
        };
		const fields = Object.assign({},returnValues);
		const recordInput = { fields };

		updateRecord(recordInput).then(() => {
			this.showToast("Success","Opportunity updated","success");
		})
	}

	openDetailWindow(){
		this.isModalOpen = true;
	}

	closeModal(){
		this.isModalOpen = false;
	}

	handleSave(){
		this.sendDataToController();
		this.isModalOpen = false;
	}

	handleSavePF(){
		const returnValues = {
            Id: this.id,
			AV_FechaProximoRecordatorio__c: this.fechaProxGest,
			CloseDate: this.fechaCierre
        };
		const fields = Object.assign({},returnValues);
		const recordInput = { fields };

		updateRecord(recordInput).then(() => {
			this.showToast("Success","Opportunity updated","success");
		})
	}

	handleSave2() {
		var amountAux = this.amount != this.oppo.amount ? this.amount : this.oppo.amount;
		var impactoBalanceAux = this.impactoBalance != this.oppo.impactoBalance ? this.impactoBalance : this.oppo.impactoBalance;
		var esgAux = this.esg != this.oppo.ESG ? this.esg : this.oppo.ESG;
		var probabilidadAux = this.probabilidad != null ? this.probabilidad : 'media';//
		var comentarioAux = this.comentarioToSend != null ? this.comentarioToSend : '';//
		var divisaAux = this.divisa != this.oppo.divisa ? this.divisa : this.oppo.divisa;
		var comisionesAux = this.divisa != null ? this.divisa:'';//
		var entidadAux = this.entidad != this.oppo.entity ? this.entidad : this.oppo.entity;//
		var fechaVencimientoAux = this.vencimiento!=this.oppo.vencimiento ? this.vencimiento : this.oppo.vencimiento;
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

		const fields = Object.assign({},returnValues);
		const recordInput = { fields };

		updateRecord(recordInput).then(() => {
			this.showToast("Success","Opportunity updated","success");
		})
    }

	@api
	highlightBadInput(){
		this.template.querySelector('[data-id="mainDiv"]').style.border = "solid 1.5px rgba(255,0,0,1)";
		let interval;
		let opacity = 1;
		setTimeout(
			()=>{
				interval = setInterval(
					() =>{
						opacity -= 0.15;
						this.template.querySelector('[data-id="mainDiv"]').style.border = 'solid 1.5px rgba(255,0,0,'+opacity+')';
						if(opacity < 0){
							this.template.querySelector('[data-id="mainDiv"]').style.border = '';
							clearInterval(interval);
						}
					}
					,50);
				}
				,500);
	}

    @track optionsProbabilidad = [
        {label: this.label.alta, value: 'Alta'},
        {label: this.label.media, value: 'Media'},
        {label: this.label.baja, value: 'Baja'}
    ];
	@track optionsEstado = [
		{label: this.label.anulada, value: 'Anulada'},
        {label: this.label.competencia, value: 'Competencia'},
        {label: this.label.desistidaCliente, value: 'Desistida cliente'},
		{label: this.label.desistidaOficina, value: 'Desistida comité sucursal/oficina'},
        {label: this.label.producto, value: 'Producto'},
        {label: this.label.riesgos, value: 'Riesgos'},
		{label: this.label.precio, value: 'Precio'},
		{label: this.label.denegadaPoliticaFinanciacionSostenible, value: 'Denegada por Política ESG'},
		{label: this.label.otros, value: 'Otros'}
    ];
	@wire(getObjectInfo, {objectApiName: opportunity_Object})
    opportunityObjectMetadata;

	@track optionsDivisa = [];
	@wire(getPicklistValues, {recordTypeId: "$opportunityObjectMetadata.data.defaultRecordTypeId", fieldApiName: divisa_FIELD})
    wirePickList({ error, data }) {
        if (data) {
            this.optionsDivisa = data.values;
        } else if (error) {
            console.log(error);
        }
    }
	scrollIntoElement(id){
		this.template.querySelector('[data-id="'+id+'"]').scrollIntoView({
			behavior: 'auto',
			block: 'center',
			inline: 'center'
		});;
	}

	updateOrCreateOpportunities(){
		for(let oppo in this.oppoObj){
			
			this.oppoObj[oppo]['proximaGestion'] = this.activityDateToSend;
		}
		var mapOpp;
		for(let oppo in this.oppoObj){
				mapOpp.push(this.oppoObj[oppo]['id'], oppo);
		}


		createOrUpdateOpportunities({opposToInsertOrUpdate:mapOpp,accountId:this.accountId, dateIni: this.dateIniFinal})
		.then(result => {
			if(result.errorList == null){
				this.oppoObj = result.editedOpportunities;
				this.checkOnOffTasksBackUp = result.taskToRestoreBack;
				this.caosCheckOnOffBackUp = result.caoToRestoreBack;
				this.taskAndOpposRel = result.taskOpposRelation;
				for(let oppo in this.oppoObj){
					if(oppo.includes(IDPROVISIONAL)){
						this.createdOpposIds.push(this.oppoObj[oppo]['id']);
					}
				}
				this.vinculateOpportunities();
			}else{
				result.errorList.forEach(err => {
					console.log(err);
				})
			}
		}).catch(error => {
			//BACKUP ATTENDES
			console.log(error);
		});	
	}

}