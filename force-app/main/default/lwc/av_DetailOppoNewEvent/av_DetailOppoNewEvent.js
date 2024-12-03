import { LightningElement,api,track } from 'lwc';
import getSubProduct from '@salesforce/apex/AV_ReportAppointment_Controller.searchByProduct';
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

//labels
import mainOpp from '@salesforce/label/c.AV_MainOpportunity';
import markMainOpp from '@salesforce/label/c.AV_MarkMainOpportunity';
import statusOpp from '@salesforce/label/c.AV_CurrentStatus';
import amount from '@salesforce/label/c.AV_Importe';
import detail from '@salesforce/label/c.AV_Detalle';

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
		detail
	};
	@api oppo;
	@api comesfromevent;
	@track id;
	@track name;
	@track path;
	@track oppoDate;
	@track comentario;
	@track initPotential;
	@track initResolution;
	@track importePropio;
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
	@track owneridopp;  
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
	now = new Date(Date.now()).toISOString();
	firstClickNewOppo = true;

	@api initialState;

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
			if(this.oppo.isTheLastItem){
				this.dispatchEvent( new CustomEvent('vinculateall'));
			}
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
		this.statusNow = this.oppo.Stage;
		this.id = this.oppo.Id;
		this.name = this.oppo.Name;
		this.path = this.oppo.Stage;
		this.oppoDate=  this.oppo.Fecha;
		this.comentario = this.oppo.Comentarios;
		this.fecha = this.oppo.Fecha;
		this.initPotential = this.oppo.Potencial;
		this.importePropio = this.oppo.ImportePropio;
		this.margin = this.oppo.Margen;
		this.mainPF = this.oppo.ProductoMain;
		this.cuota = this.oppo.ImporteCuota;
		this.importeOtraEntidad = this.oppo.ImporteOtraEntidad;
		this.otraEntidad = (this.oppo.OtraEntidad == 'S');
		this.otraEntidadNombre = this.oppo.OtraEntidadNombre;
		this.isInserted = (this.oppo.NotInserted == undefined);
		this.vinculed = (this.comesfromevent) ? this.oppo.isVinculed :  (this.oppo.isVinculed != undefined);
		this.mainVinculed = (this.comesfromevent) ? (this.oppo.mainVinculed):false;
		this.deleteCheckOnOffTask =  this.oppo.PrioritzingCustomer;
		this.historyCommentWithDate = this.oppo.HistoryComment;
		this.owneridopp = this.oppo.owneridopp;  
		if(this.historyCommentWithDate != '' && this.historyCommentWithDate != undefined){
			this.historyCommentDate = this.historyCommentWithDate.split(SEPARADOR)[0];
			this.historyComment = this.historyCommentWithDate.split(SEPARADOR)[1];
			this.historyCommentDateLabel = 'Último comentario - '+this.historyCommentDate;
		}else{
			this.historyCommentDateLabel = '';
			
		}

		this.initialState = {
			sobjectype:'Opportunity',
			Id:this.id,
			StageName:this.path,
			AV_Comentarios__c:this.comentario,
			AV_FechaProximoRecordatorio__c:this.oppoDate,
			AV_Potencial__c:this.initPotential,
			AV_MarginEuro__c:this.margin,
			AV_PF__c:this.mainPF,
			AV_Cuota__c:this.cuota,
			Amount:this.ImporteOtraEntidad,
			AV_Tenencia__c:this.oppo.OtraEntidad,
			AV_Entidad__c:this.otraEntidadNombre,
			AV_ByProduct__c:this.oppo.SubProductId,
			AV_OrigenApp__c:'AV_BackReport',
			AV_IncludeInPrioritizingCustomers__c:this.oppo.PrioritzingCustomer
			,OwnerId : this.owneridopp  

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

		if (this.checkedOld == this.pathMap[e.target.name]) { //Para poner el valor antiguo si quita el check
			this.statusNow = this.oppo.Stage;
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
					newPath:this.path,
					Name:this.name,
					ProdId:this.mainPF,
					proximaGestion:this.proximaGestionToSend,
					expectativa:this.expectativaToSend,
					importe:this.importePropioToSend,
					comentario:this.comentarioToSend,
					tenencia:this.tenenciaToSend,
					otraEntidad:this.otraEntidadToSend,
					fechaOtraEntidad:this.fechaOtraEntidadToSend,
					subProducto:this.subProductoToSend,
					margin:this.marginToSend,
					cuota:this.cuotaToSend,
					importeOtraEntidad:this.importeOtraEntidadToSend,
					mainVinculed:this.mainVinculed,
					isVinculed:this.vinculed,
					priorizado:this.deleteCheckOnOffTask,
					recordtype:this.oppo.RecordType
					,owneridopp:this.owneridopp  
				}
				
			})
		)
	}
   

	handleChangePotencial(e){
		this.expectativaToSend = e.target.value;
		this.sendDataToController();
	}



	evaluateNumericInput(e){
		let lastChar = e.target.value.slice(-1);
		let isThereDecimal = e.target.value.slice(0,-1).includes(DECIMAL);
		return (isNaN(parseInt(lastChar,10)) && (lastChar != DECIMAL || isThereDecimal) ) || (lastChar == DECIMAL && e.target.value.length == 1);
	}

	handleChangeImportePropio(e){
		this.importePropioToSend= e.target.value;
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
		let error = null;
		var validateDecimal = /^[0-9]*(\,?)[0-9]+$/;
		if(this.importePropioToSend != null && this.importePropioToSend != ''){
			if(!this.importePropioToSend.match(validateDecimal)){
				this.showToast('Error', 'El campo de Importe es de tipo decimal. El formato correcto es: 123,12', 'error', 'pester');
				error = 'KO';
			}
		}
		if(this.marginToSend != null && this.marginToSend != ''){
			if(!this.marginToSend.match(validateDecimal)){
				this.showToast('Error', 'El campo Margen es de tipo decimal. El formato correcto es: 123,12', 'error', 'pester');
				error = 'KO';
			}
		}
		if(this.importeOtraEntidadToSend != null && this.importeOtraEntidadToSend != ''){
			if(!this.importeOtraEntidadToSend.match(validateDecimal)){
				this.showToast('Error', 'El campo Importe es de tipo decimal. El formato correcto es: 123,12', 'error', 'pester');
				error = 'KO';
			}
		}
		if(this.cuotaToSend != null && this.cuotaToSend != ''){
			if(!this.cuotaToSend.match(validateDecimal)){
				this.showToast('Error', 'El campo Importe cuota es de tipo decimal. El formato correcto es: 123,12', 'error', 'pester');
				error = 'KO';
			}
		}

		if(this.template.querySelector('[data-id="vencimientoinput"]') != null && !this.template.querySelector('[data-id="vencimientoinput"]').reportValidity()){
			this.showToast('Error', 'No puedes indiciar una fecha de vencimiento en pasado', 'error', 'pester');
			error = 'KO';
		}


		if(error == null){
			this.isModalOpen = false;
		}
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
}