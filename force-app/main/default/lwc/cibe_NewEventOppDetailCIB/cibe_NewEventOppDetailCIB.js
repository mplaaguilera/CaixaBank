import { LightningElement,api,track } from 'lwc';
import getSubProduct from '@salesforce/apex/AV_ReportAppointment_Controller.searchByProduct';
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

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
import esg from '@salesforce/label/c.CIBE_FinanciacionSostenible';  


const PROXIMGESTIONLABEL = 'Próxima Gestión';
const NOOFRECERLABEL = 'No ofrecer hasta';
const IDPROVISIONAL = 'idProvisional';
const SEPARADOR = '{|}';




export default class Av_DetailOpportunityAppointment extends NavigationMixin(LightningElement) {

	label = {
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
		esg
	};

	@api isEditable;
	@api proximaGestion

	@api newEventHeaderId;

	@api oppo;
	@api comesfromevent;
	@track id;
	@track name;
	@track path;
	@track oppoDate;
	oppoDate
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
	checkedOld;
	currentNameButton;
	@api vinculed = false;
	@api mainVinculed = false;
	@api vinculeButtons = false;
	@api mainButtons = false;
	@track allStages = [];
	@track unfoldCmp = false;
	@track otherEntity = false
	@track secundaryInputs = false;
	@track showMoreInfo = false;
	isAgendado = false;
	@track especialInputLabel = PROXIMGESTIONLABEL;
	@api potentiallist;
	@api resolutionlist;
	arrowClass = "customArrowRightDefault";
	agendadoClass = "customEventDefault";
	checkClass = "customCheckDefault";
	closeClass = "customCloseDefault";
	banClass = "customBanDefault";
	POTENCIAL = 'Potencial';
	GESTION = 'En gestión/insistir';
	CERRPOSI = 'Cerrado positivo';
	CERRNEGA = 'No interesado';
	NOAPTO = 'No apto';
	VENCIDO = 'Vencido';
	GESTIONSPLIT = 'gestion';
	AGENDARSPLIT = 'agendar';
	pathMap = {
		'agendado':this.GESTION
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
	tenenciaToSend;
	otraEntidadToSend;
	subProductoToSend = null;
	marginToSend;
	cuotaToSend;
	importeOtraEntidadToSend;
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

	@api initialState;


	@track probabilidad = 'Media';

	connectedCallback(){
		this.fillVars();
		
	}

	getTodayString(){
		let d = new Date();
		return d.getFullYear() + '-'+(d.getMonth() +1) +'-' + d.getDate()
	}
	
	renderedCallback(){
		if(this.id.includes(IDPROVISIONAL) && this.firstClickNewOppo && !this.comesfromevent){
			this.template.querySelector('[data-id="agendado"]').click();
			this.firstClickNewOppo = false;
		}
		
		if(this.comesfromevent && this.firstClickNewOppo){
			this.firstClickNewOppo = false;
			this.sendDataToController();
			/*if(this.oppo.isTheLastItem){
				this.dispatchEvent( new CustomEvent('vinculateall'));
			}*/
		}
		
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
		this.isEditable = this.oppo.isEditable;
		this.proximaGestion = this.oppo.proximaGestion;
		//

		this.statusNow = this.oppo.status;
		this.id = this.oppo.id;
		this.name = this.oppo.name;
		//this.path = this.oppo.status;
		var [year, month, day] = this.oppo.closeDate.split('-');
		day = day.lenght < 2 ? '0' + day : day;
		month = month.lenght < 2 ? '0' + month : month; 
		this.oppoDate=  this.oppo.closeDate;
		console.log('## this.oppoDate - ', this.oppoDate );
		this.oppoDateFront = day + '-' + month + '-' + year;
		console.log('## this.oppoDateFront - ', this.oppoDateFront );
		//this.fecha = this.oppo.Fecha;
		//this.initPotential = this.oppo.Potencial;
		this.amount = this.oppo.amount == null ? '' : this.oppo.amount;
		this.margin = this.oppo.margin;
		this.mainPF = this.oppo.productId;
		//this.cuota = this.oppo.ImporteCuota;
		//this.importeOtraEntidad = this.oppo.ImporteOtraEntidad;
		this.otraEntidad = this.oppo.entity;
		//this.otraEntidadNombre = this.oppo.OtraEntidadNombre;
		this.isInserted = (this.oppo.NotInserted == undefined);
		this.vinculed = this.oppo.isVinculated;
		// this.mainVinculed = false;
		console.log('isInserted => ',this.isInserted);
		this.mainVinculed = this.oppo.isPrincipal;
		//this.deleteCheckOnOffTask =  this.oppo.PrioritzingCustomer;
		this.historyCommentWithDate = this.oppo.commentsLastModifieddate;
		//console.log(this.historyCommentDate);
		if(this.historyCommentWithDate != '' && this.historyCommentWithDate != undefined){
			this.historyCommentDate = this.historyCommentWithDate.split(SEPARADOR)[0];
			this.historyComment = this.historyCommentWithDate.split(SEPARADOR)[1];
			this.historyCommentDateLabel = 'Último comentario - '+this.historyCommentDate;
			
			console.log(this.comentario);
		}else{
			this.historyCommentDateLabel = '';
			
		}

		this.initialState = {
			sobjectype:'Opportunity',
			Id:this.id,
			StageName:this.statusNow,
			AV_Comentarios__c:this.comentario,
			AV_Potencial__c:this.initPotential,
			AV_MarginEuro__c:this.margin,
			AV_PF__c:this.mainPF,
			AV_Cuota__c:this.cuota,
			Amount:this.ImporteOtraEntidad,
			//AV_Tenencia__c:this.oppo.OtraEntidad,
			AV_Entidad__c:this.otraEntidadNombre,
			//AV_ByProduct__c:this.oppo.SubProductId,
			AV_OrigenApp__c:'AV_BackReport',
			AV_IncludeInPrioritizingCustomers__c:this.oppo.PrioritzingCustomer

		}

		// if(!this.id.includes(IDPROVISIONAL)){
		// 	this.sendDataToController();
		// }
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

	handlePath(e){

		console.log(this.isEditable);

		if (this.checkedOld == this.pathMap[e.target.name]) { //Para poner el valor antiguo si quita el check
			this.statusNow = this.oppo.status;
			this.checkedOld = null;
		} else {
			this.checkedOld = this.pathMap[e.target.name];
		}
		this.template.querySelector('[data-id="'+e.target.name+'"]').blur();
		this.currentNameButton = e.target.name;
		this.path = this.pathMap[e.target.name];
		this.isAgendado = false;
		this.unfoldCmp = !this.unfoldCmp;
        this.resetVars();
        this.resetFieldsPopUp();
        this.subProductInitial = null;
        this.path = this.pathMap[e.target.name];
        this.isAgendado = true;
        this.agendadoClass = (this.agendadoClass == this.classMapDefault[e.target.name])
        ? this.classMap[e.target.name]
        : this.classMapDefault[e.target.name];
        this.handleVincular();
		this.sendDataToController();
	}

	cleanEntityVars(){
		this.otraEntidadToSend = null;
		this.fechaOtraEntidadToSend = null;
		this.importeOtraEntidadToSend = null;
		this.cuotaToSend = null;
		this.sendDataToController();
	}

	handleSearchByProduct(e){
		this.find = e.detail.searchTerm;
		getSubProduct({searchTerm:e.target.searchTerm,product:this.mainPF})
			.then(result =>{
				if(result){
					this.template.querySelector('[data-id="clookup2"]').setSearchResults(result);
				}
			}).catch(error =>{
				console.log(error);
			})
	}

	handleSearchClick(event){
		if (this.find == '' && this.subProductoToSend == null) {
			getSubProduct({ searchTerm: event.detail.searchTerm,  product: this.mainPF })
				.then((results) => {
					if (results != null) {
						this.template.querySelector('[data-id="clookup2"]').setSearchResults(results);
					}
				})
				.catch((error) => {
					console.error('Lookup error', JSON.stringify(error));
					this.errors = [error];
				});
		}
	}

	handleSelectionChangeByProduct() {
		const cmp = this.template.querySelector('[data-id="clookup2"]')
		let selection = cmp.getSelection();
		if (selection.length !== 0) {
			this.subProductInitial = selection[0];
			this.subProductoToSend = this.subProductInitial.id;	
			this.sendDataToController();
		} else{
			cmp.handleBlur();
			this.subProductoToSend = null;
			this.sendDataToController();
		}
	}

	@api
	handleMain(){
		console.log('estrella');
		this.dispatchEvent(
			new CustomEvent('mainclick',{
				detail:{
					oppoId:this.id
				}
			})
		);
	}

	@api
	handleVincular(){
		this.vinculed = !this.vinculed;
		this.dispatchEvent(
			new CustomEvent('vinculateaction',{
				detail:{
					sum:this.vinculed,
					oppoId:this.id
				}
			})
		);
	}

	resetVars(){
		this.comentarioToSend = null;
		// this.proximaGestionToSend = null;
		this.expectativaToSend = null;
		this.expectativaToSend = '';
		this.importePropioToSend = null;
		this.tenenciaToSend = null;
		this.otraEntidadToSend = null;
		this.fechaOtraEntidadToSend = null;
		this.subProductoToSend = null;
		this.marginToSend = null;
		this.cuotaToSend = null;
		this.importeOtraEntidadToSend = null;
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
					isEditable: this.isEditable,
					proximaGestion: this.proximaGestion,
					oppoDate: this.oppoDate

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

	
   

	// handleChangeProbabilidad(e){
	// 	this.expectativaToSend = e.target.value;
	// 	this.sendDataToController();
	// }

	handleChangeProbabilidad(e){
		this.probabilidad = e.target.value;
		this.sendDataToController();
	}



	evaluateNumericInput(e){
		let lastChar = e.target.value.slice(-1);
		let isThereDecimal = e.target.value.slice(0,-1).includes(DECIMAL);
		return (isNaN(parseInt(lastChar,10)) && (lastChar != DECIMAL || isThereDecimal) ) || (lastChar == DECIMAL && e.target.value.length == 1);
	}

	handleChangeImportePropio(e){
		this.amount= e.detail.value;
		this.sendDataToController();
	}


	handleChangeComentario(e){
		this.comentarioToSend = e.target.value;
		this.sendDataToController();
	}

	handleChangeOtraEntidad(e){
		this.otraEntidadToSend= e.target.value;
		this.tenenciaToSend = (this.otraEntidadToSend != '');
		this.sendDataToController();
	}

	handleChangeImporteOtraEntidad(e){
		this.importeOtraEntidadToSend = e.target.value;
		this.sendDataToController();
	}
	
	handleChangeFechaOtraEntidad(e){
		this.fechaOtraEntidadToSend = e.target.value;
		// if(e.target.reportValidity()){
		// }else{
		// 	e.target.value = '';
		// 	this.fechaOtraEntidadToSend = null;
		// }
		this.sendDataToController();
	}

	handleChangeMargin(e){
		this.marginToSend = e.target.value;
		this.sendDataToController();
	}

	handleChangeCuota(e){
		this.cuotaToSend = e.target.value;
		this.sendDataToController()
	}

	openDetailWindow(){
		this.isModalOpen = true;
	}

	closeModal(){
		// let error = null;
		// var validateDecimal = /^[0-9]*(\,?)[0-9]+$/;
		// if(this.importePropioToSend != null && this.importePropioToSend != ''){
		// 	if(!this.importePropioToSend.match(validateDecimal)){
		// 		this.showToast('Error', 'El campo de Importe es de tipo decimal. El formato correcto es: 123,12', 'error', 'pester');
		// 		error = 'KO';
		// 	}
		// }
		// if(this.marginToSend != null && this.marginToSend != ''){
		// 	if(!this.marginToSend.match(validateDecimal)){
		// 		this.showToast('Error', 'El campo Margen es de tipo decimal. El formato correcto es: 123,12', 'error', 'pester');
		// 		error = 'KO';
		// 	}
		// }
		// if(this.importeOtraEntidadToSend != null && this.importeOtraEntidadToSend != ''){
		// 	if(!this.importeOtraEntidadToSend.match(validateDecimal)){
		// 		this.showToast('Error', 'El campo Importe es de tipo decimal. El formato correcto es: 123,12', 'error', 'pester');
		// 		error = 'KO';
		// 	}
		// }
		// if(this.cuotaToSend != null && this.cuotaToSend != ''){
		// 	if(!this.cuotaToSend.match(validateDecimal)){
		// 		this.showToast('Error', 'El campo Importe cuota es de tipo decimal. El formato correcto es: 123,12', 'error', 'pester');
		// 		error = 'KO';
		// 	}
		// }

		// if(this.template.querySelector('[data-id="vencimientoinput"]') != null && !this.template.querySelector('[data-id="vencimientoinput"]').reportValidity()){
		// 	this.showToast('Error', 'No puedes indiciar una fecha de vencimiento en pasado', 'error', 'pester');
		// 	error = 'KO';
		// }


		// if(error == null){
		// 	this.isModalOpen = false;
		// }
		this.isModalOpen = false;
	}

	resetFieldsPopUp(){
		this.importePropioToSend = null;
		this.marginToSend = null;
		this.otraEntidadToSend = null;
		this.fechaOtraEntidadToSend = null;
		this.importeOtraEntidadToSend = null;
		this.cuotaToSend = null;
		this.isToggleActive = false;
	}

	handleToggleClick(event){
		this.isToggleActive = event.target.checked;
		if(!this.isToggleActive){
			this.cleanEntityVars();
		}
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
					,50);//Graduacion de la opacidad del borde rojo
				}
				,500);//Tiempo que tarda en empezar a desaparecer 
	}

    @track optionsProbabilidad = [
        {label: 'Alta', value: 'Alta'},
        {label: 'Media', value: 'Media'},
        {label: 'Baja', value: 'Baja'},
    ];

	@api
	validateRequiredInputs(){
		console.log('@@@' + this.amount);
		if(this.amount == null || this.amount == ''){
			console.log('entra');
			this.scrollIntoElement('importe');
		   	this.showToast('Faltan datos','Introduce un importe para la oportunidad','error')
		   return false;
		}

		return true;
	}

	scrollIntoElement(id){
		this.template.querySelector('[data-id="'+id+'"]').scrollIntoView({
			behavior: 'auto',
			block: 'center',
			inline: 'center'
		});;
	}
}