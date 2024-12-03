import { LightningElement,api,track, wire } 	from 'lwc';
import { NavigationMixin } 				from 'lightning/navigation';
import { ShowToastEvent } 				from 'lightning/platformShowToastEvent';
import USER_ID              			from "@salesforce/user/Id";


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
import gestionadaPositiva from '@salesforce/label/c.CIBE_GestionadaPositiva';
import gestionadaNegativa from '@salesforce/label/c.CIBE_GestionadaNegativa';
import pendiente from '@salesforce/label/c.CIBE_Pendiente';
import pendienteNoLocalizado from '@salesforce/label/c.CIBE_PendienteNoLocalizado';
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
import updateChecked     		   			from '@salesforce/apex/CIBE_NewEventTaskDetail_Controller.updateChecked';
import updateCanceled     		   			from '@salesforce/apex/CIBE_NewEventTaskDetail_Controller.updateCanceled';
import updateComment     		   			from '@salesforce/apex/CIBE_NewEventTaskDetail_Controller.updateComment';
import vinculateTask     		   			from '@salesforce/apex/CIBE_NewEventTaskDetail_Controller.vinculateTask';
import disVinculateTask     		   		from '@salesforce/apex/CIBE_NewEventTaskDetail_Controller.disVinculateTask';
import makePrincipal     		   			from '@salesforce/apex/CIBE_NewEventTaskDetail_Controller.makePrincipal';
import getActivityDate    		   			from '@salesforce/apex/CIBE_NewEventOppDetail_Controller.getActivityDate';

const PROXIMGESTIONLABEL = 'Próxima Gestión';
const NOOFRECERLABEL = 'No ofrecer hasta';
const IDPROVISIONAL = 'idProvisional';
const SEPARADOR = '{|}';

export default class Cibe_ViewTaskRelatedDetail extends NavigationMixin(LightningElement) {

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
        gestionadaPositiva,
        gestionadaNegativa,
        pendiente,
        pendienteNoLocalizado,
		esg,
		competencia,
		desistidaCliente,
		desistidaOficina,
		denegadaPoliticaFinanciacionSostenible,
		producto,
		riesgos,
		otros,
		alta,
		media,
		baja
	};

	@api recordId
	@api oppislinked;
	@api isEditable;
	@api proximaGestion
	@api newEventHeaderId;
	@api isFuture;
	@api oppo;
    @api tsk;
	@api eventid;
	@api main;
	@api comesfromevent;
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

	statusNow;
	statusNowLabel;
	owner;
	userId = USER_ID;
	isOwner;
	checkedOld;
	currentNameButton;
	@api vinculed = false;
	@api mainVinculed;
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
	@track showState= false; // variable para mostrar campos del tercer boton

	arrowClass = "customArrowRightDefault";
	agendadoClass = "customInsisDefault";
	checkClass = "customCheckDefault";
	closeClass = "customCloseDefault";
	banClass = "customBanDefault";
	insisClass="customInsisDefault";

	POTENCIAL = 'Potencial';
	GESTION = 'En gestión/insistir';
	CERRADOPOSI = 'Gestionada positiva'
	CERRADONEGA = 'Gestionada negativa'
	VENCIDO = 'Vencido';

	labelsMap = {
        'Gestionada positiva': this.label.gestionadaPositiva,
        'Managed Positevely': this.label.gestionadaPositiva,
        'Gestionada negativa':this.label.gestionadaNegativa,
        'Managed Negatively':this.label.gestionadaNegativa,
        'Pendiente':this.label.pendiente,
        'Pending':this.label.pendiente,
        'Pendiente no localizado':this.label.pendienteNoLocalizado,
        'Pending not located':this.label.pendienteNoLocalizado
    
    }
	pathMap = {
		'check':this.CERRADOPOSI,
		'close':this.CERRADONEGA,
		'ban':this.CERRADONEGA
	}
	classMap = {
		'arrow':'customArrowRight',
		'agendado':'customInsis',
		'check':'customCheck',
		'close':'customClose',
		'ban':'customBan',
		'insistir':'customInsis'

	}
	classMapDefault = {
		'arrow':'customArrowRightDefault',
		'agendado':'customInsisDefault',
		'check':'customCheckDefault',
		'close':'customCloseDefault',
		'ban':'customBanDefault',
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


	@track probabilidad = 'Media';
	@track state;

    //////////////////nuevo
    @track recordType;
    @track accountId;
    @track subject;
    @track activityDate;
    @track comments;
    @track commentsLastModifieddate;
    @track isVinculated;
    @track isPrincipal;
    @track status;
    @track headerId;
    @track checked;
    @track closedLost;
    @track relaccionadoCitaId;
    @api principal;
    @api esPrincipal;
        

	connectedCallback(){
		this.fillVars();
		
	}

	getTodayString(){
		let d = new Date();
		return d.getFullYear() + '-'+(d.getMonth() +1) +'-' + d.getDate()
	}
	
	renderedCallback(){
		if(this.id?.includes(IDPROVISIONAL) && this.firstClickNewOppo && !this.comesfromevent){
			this.template.querySelector('[data-id="agendado"]').click();
			this.firstClickNewOppo = false;
		}
		
		if(this.comesfromevent && this.firstClickNewOppo){
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
		this.tareaDate=  this.tsk.activityDate;
		this.id = this.tsk.id,
		this.recordType = this.tsk.rt,
		this.accountId = this.tsk.accountId,
		this.name = this.tsk.subject,
		this.activityDate = this.tsk.activityDate,
		this.owner = this.tsk.owner,
		this.comments = this.tsk.comments,
		this.commentsLastModifieddate = this.tsk.commentsLastModifieddate,
		this.isVinculated = this.tsk.isVinculated;
		this.isPrincipal = this.tsk.isPrincipal;
		this.isEditable = this.tsk.isEditable;
		this.statusNow = this.tsk.status;
		this.status = this.tsk.status;
		this.statusNowLabel = this.labelsMap[this.statusNow];
		this.headerId = this.tsk.headerId;
        this.checked = this.tsk.checked;
        this.closedLost = this.tsk.closedLost;
        this.relaccionadoCitaId = this.tsk.relaccionadoCitaId;
		this.comentarioToSend = this.tsk.comments;
	
		if(this.owner == this.userId){
			this.isOwner = true;
		}else{
			this.isOwner = false;
		}
        if(this.tsk.isVinculated){
            this.agendadoClass = this.classMap['agendado'];
			this.insisClass = this.classMap['agendado'];
            this.unfoldCmp = true;
            this.vinculed = true;
        }
		if (this.tsk.status == this.CERRADOPOSI) {
			this.checkClass = (this.checkClass == this.classMapDefault['check'])			
			? this.classMap['check']
			: this.classMapDefault['check'];
			
		} else if (this.tsk.status == this.CERRADONEGA) {
			this.closeClass = (this.closeClass == this.classMapDefault['close'])
			? this.classMap['close']
			: this.classMapDefault['close'];
		}

		this.mainVinculed = this.tsk.isPrincipal !== undefined ? this.tsk.isPrincipal : false;

		this.sendDataToController();
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
		if(buttonToAvoid != 'arrow' ){
			this.arrowClass = this.classMapDefault['arrow'];
		}    
		if(buttonToAvoid != 'agendado'){
			this.agendadoClass = this.classMapDefault['agendado'];
			this.insisClass = this.classMapDefault['agendado'];
		}
		if(buttonToAvoid != 'check' ){
			this.checkClass = this.classMapDefault['check'];
		}
		if(buttonToAvoid != 'close'){
			this.closeClass = this.classMapDefault['close'];
		}
		if(buttonToAvoid != 'ban'){
			this.banClass = this.classMapDefault['ban'];            
		}
	}
	primerClic = true;
	buttonClicked;
	handleToggleClick() {
        this.buttonClicked = !this.buttonClicked; //set to true if false, false if true.
        this.cssClass = this.buttonClicked ? 'cssClass' : 'slds-button slds-button_destructive';
    }


	oldValue;
	primerClic =  true;
	handlePath(e){
		this.template.querySelector('[data-id="'+e.target.name+'"]').blur();
		this.resetCustomButtons(e.target.name);
		this.currentNameButton = e.target.name;
		this.path = this.pathMap[e.target.name];
		let vinculedBefore = this.vinculed;
		if(this.currentNameButton === 'noAgendado'){
			this.vinculed = false;
			this.unfoldCmp = false;
			this.showState = false;
			this.showComents = true;
			this.isPrincipal = false;
			this.insisClass = this.classMapDefault['noAgendado'];
		}else if(this.currentNameButton === 'agendado'){
			this.oldValue = (this.oldValue === this.currentNameButton) ? null : this.currentNameButton;
			this.statusNow = this.tsk.status;
			this.statusNowLabel = this.labelsMap[this.statusNow];
			this.unfoldCmp = true;
			this.vinculed = true;
			this.showComents = false;
			this.insisClass = this.classMap['agendado'];
		}else  if(this.currentNameButton === 'check'){
            updateChecked({recordId: this.tsk.id})
            .then((result => {
            }))
            .catch((error =>{
                console.log(error);
            }))
			this.state = null;
			if(this.oldValue === this.currentNameButton){
				this.statusNow = this.tsk.status;
				this.statusNowLabel = this.labelsMap[this.statusNow];
				this.oldValue = null;
			} else{
				this.statusNow = this.path;
				this.statusNowLabel = this.labelsMap[this.statusNow];
				this.oldValue = this.currentNameButton;
			}
			this.showComents = true;
			this.unfoldCmp = false;
			this.showState = false;
			this.vinculed = true;
			this.checkClass = (this.checkClass == this.classMapDefault[e.target.name])			
			? this.classMap[e.target.name]
			: this.classMapDefault[e.target.name];
			this.agendadoClass = this.classMap['agendado'];
			if(this.oldValue !== this.currentNameButton && !(this.currentNameButton == 'agendado' && this.currentNameButton == 'noAgendado') ){
				this.vinculed = !this.vinculed;
			}
		} else if(this.currentNameButton === 'close'){
			updateCanceled({recordId: this.tsk.id})
            .then((result => {
				console.log('updateCanceled',result);
            }))
            .catch((error =>{
                console.log(error);
            }))
			this.state = null;
			if(this.oldValue == this.currentNameButton){
				this.showState = !this.showState;
				this.statusNow = this.tsk.status;
				this.statusNowLabel = this.labelsMap[this.statusNow];
				this.oldValue = null;
			} else{
				this.showState = !this.showState;
				this.statusNow = this.path;
				this.statusNowLabel = this.labelsMap[this.statusNow];
				this.oldValue = this.currentNameButton;
			}
			this.unfoldCmp = false;
			this.showComents = false;
			this.vinculed = true;
			this.closeClass = (this.closeClass == this.classMapDefault[e.target.name])
			? this.classMap[e.target.name]
			: this.classMapDefault[e.target.name];
			this.agendadoClass = this.classMap['agendado'];
			if(this.oldValue !== this.currentNameButton && !(this.currentNameButton == 'agendado' && this.currentNameButton == 'noAgendado') ){
				this.vinculed = !this.vinculed;
			}
		}
		if(vinculedBefore != this.vinculed){
			this.vinculed ? this.vinculate() : this.desvinculate();
		}
		this.unfoldCmp =  this.vinculed === false ? false : this.unfoldCmp ;
        this.handleVincular();
	}

	vinculate(){
		vinculateTask({recordId: this.eventid, taskId: this.tsk.id})
		.then((() => {
			this.dispatchEvent(new CustomEvent('recounttasks'));
		}))
		.catch((error =>{
			console.log(error);
		}))
	}
	
	desvinculate(){
		disVinculateTask({recordId: this.eventid, taskId: this.tsk.id})
		.then((() => {
			this.dispatchEvent(new CustomEvent('recounttasks'));
		}))
		.catch((error =>{
			console.log(error);
		}))
	}

	handleMain(){
		this.spinner = true;

		makePrincipal({recordId: this.eventid, taskId: this.tsk.id})
		.then((result => {
			console.log(result);
			this.dispatchEvent(new CustomEvent('resfreshdatatask'));

		}))
		.catch((error =>{
			console.log(error);
		}))
	
	}

	@api
	handleVincular(){
		/*if(this.oldValue !== this.currentNameButton && !(this.currentNameButton == 'agendado' && this.currentNameButton == 'noAgendado') ){
			this.vinculed = !this.vinculed;
		}*/
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
			new CustomEvent('senddatafromtarea',
			{
				detail:{
					id:this.id,
					rt:this.rt,
					accountId:this.accountId,
					subject:this.name,
					tareaDate: this.tareaDate,
					status:this.status,
					owner:this.owner,
					vinculed:this.vinculed,
					mainVinculed:this.mainVinculed,
					headerId:this.headerId,
					isEditable: this.isEditable,
					comentario:this.comentarioToSend
				}
			})
		)
	}

	handleChangeComentario(e){
		this.comentarioToSend = e.target.value;
		if(this.id!=null){
			updateComment({recordId: this.tsk.id, comentarioToSend:this.comentarioToSend})
            .then((result => {
				console.log(result);
            }))
            .catch((error =>{
                console.log(error);
            }))
		}
	}

	openDetailWindow(){
		this.isModalOpen = true;
	}

	closeModal(){
		this.isModalOpen = false;
	}

	handleSave(){
		//this.sendDataToController();
		this.isModalOpen = false;
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
	scrollIntoElement(id){
		this.template.querySelector('[data-id="'+id+'"]').scrollIntoView({
			behavior: 'auto',
			block: 'center',
			inline: 'center'
		});;
	}

	@track _wiredData;
	@wire(getActivityDate, {eventId:'$newEventHeaderId'})
    getActivityDate(result) { 
		this._wiredData = result;
		const {data, error} = this._wiredData;
		if (data)  {
			this.isFuture = data;
		} else if (error) {
			console.log(error);
		}
	}
}