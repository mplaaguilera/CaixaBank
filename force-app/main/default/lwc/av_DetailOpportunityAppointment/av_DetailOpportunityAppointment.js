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


const SEPARADOR = '{|}';

export default class Av_DetailOpportunityAppointment extends NavigationMixin(LightningElement) {

	label = {
		mainOpp,
		markMainOpp,
		statusOpp,
		amount,
		detail
	};
	@api comesfromevent;
	@api opposselected;
	@api opposselectedagended;
	@api oppislinked;
	@api oppo;
	@api initialState;
	@api nolocalizado; 
	isPotencial;  
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
	@track closedate;
	@track neededToggle = false; 
	@track isInserted = true;
	@track prioritingCustomer;
	@track noofrecerhastaToSend;
	@track productName;
	@track isnewprodtosend;
	@track owneridopp;  
	subestado;   
	statusNow;
	checkedOld;
	currentNameButton;
	asterisk = true;
	asteriskComentary = false;
	@api vinculed = false;
	@api mainVinculed = false;
	@api vinculeButtons = false;
	@api mainButtons = false;
	@track allStages = [];
	@track unfoldCmp = false;
	@track otherEntity = false
	@track secundaryInputs = false;
	@track showMoreInfo = false;
	@track switchNextManagement = false;
	@track switchPotencial = false;
	@track switchResolution = false;
	@track switchImportSelf = false;
	@track switchImportOtherEntity = false;
	@track switchComentary = false;
	@track switchSubProduct = false;
	@track switchMargin = false;
	@track switchOtherEntity = false;
	@track switchSubImport = false;
	isAgendado = false;
	@track historyCommentWithDate;
	@track historyComment;
	@track historyCommentDate;
	@track historyCommentDateLabel;
	@track especialInputLabel = 'Próxima Gestión';
	@api potentiallist;
	@api resolutionlist;
	@api buttondelete;
	@track showButtonDelete = false;
	isModalDeleteOpen = false
	arrowClass = "customArrowRightDefault";
	agendadoClass = "customEventDefault";
	@api isnewprod;
	checkClass = this.isnewprod ? "customCheckDefaultTask":"customCheckDefault";
	closeClass = "customCloseDefault";
	nolocalizadoClass = 'customNoLocalizadoDefault';  
	banClass = "customBanDefault";
	gestion = 'En gestión/insistir-gestion';
	gestionAgendar = 'En gestión/insistir-agendar';
	CLOSED_STATUS_OK;
	CLOSED_STATUS_BAD;
	LABEL_CLOSED_BAD;
	@track showNoOfrecerHasta = false;
	@track asteriskNoOfrecer = true;
	get pathMap()  {
		return {'arrow':'En gestión/insistir-gestion',
		'agendado':'En gestión/insistir-agendar',
		'check':(this.isnewprod) ?'Producto Contratado' :'Cerrado positivo',
		'close': (this.isnewprod) ?'Producto Rechazado' :'No interesado'
		,'nolocalizado':'Potencial' 
		}
	}


	get classMap () 
{	 return {
		'arrow':'customArrowRight',
		'agendado':'customEvent',
		'check': (this.isnewprod) ? 'customCheckTask':'customCheck',
		'close':'customClose',
		'nolocalizado': 'customNoLocalizado'  
	}
}
	get classMapDefault () {	
		return {
		'arrow':'customArrowRightDefault',
		'agendado':'customEventDefault',
		'check': (this.isnewprod) ? 'customCheckDefaultTask':'customCheckDefault',
		'close':'customCloseDefault',
		'nolocalizado':'customNoLocalizadoDefault'  
	    }
    }
	
	find = '';
	pathToSend;
	proximaGestionToSend;
	subestadoToSend; 
	expectativaToSend;
	resolucionToSend;
	importePropioToSend;
	comentarioToSend;
	tenenciaToSend;
	otraEntidadToSend;
	subProductoToSend = null;
	marginToSend;
	cuotaToSend;
	importeOtraEntidadToSend;
	isModalOpen = false;
	isToggleActive = false;
	todayString = this.getTodayString();
	now = new Date(Date.now()).toISOString();
	firstClickNewOppo = true;
	firstOpp = true;
	validable  = false;
	actualValuePath;
	interruptor= false; 
	interruptor2= false; 
	interruptor3 = false; 
	

	connectedCallback(){	
		this.fillVars();
	}
	
	getTodayString(){
		let d = new Date();
		return d.getFullYear() + '-'+(d.getMonth() +1) +'-' + d.getDate()
	}

	@api
	clickbutton(){
		this.template.querySelector('[data-id="agendado"]').click();	
	}
	
	renderedCallback(){
		this.showButtonDelete = true;
		if(!this.comesfromevent){
			if(this.nolocalizado != true){
				if(this.id.includes('idProvisional') && this.firstClickNewOppo){
					this.template.querySelector('[data-id="arrow"]').click();
					this.sendDataToController();
					this.firstClickNewOppo = false;
				}
				if(this.vinculed && this.firstOpp){
					this.template.querySelector('[data-id="arrow"]').click();
					this.firstOpp= false;
				}
				
				if(this.mainVinculed && this.interruptor && this.interruptor2 == false){
					this.interruptor2 = true;
					this.template.querySelector('[data-id="arrow"]').click();
					this.interruptor = false; 
	
				}
				if(this.mainVinculed == false && this.vinculed == true && this.nolocalizado == false && this.interruptor == true && this.interruptor3 == false){
					this.interruptor3 = true;
					this.template.querySelector('[data-id="arrow"]').click();
					this.interruptor = false;
					
					
				}
				
			}else if(this.nolocalizado){
				
				if(this.vinculed && this.interruptor == false && this.initialState.StageName =='Potencial'  ){  
					this.template.querySelector('[data-id="nolocalizado"]').click();
					this.interruptor = true;
					this.interruptor2 = false; 
					this.interruptor3 = false;  
				}
				
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
		this.checkClass = this.isnewprod ? "customCheckDefaultTask":"customCheckDefault";
		this.CLOSED_STATUS_OK = (this.isnewprod) ?'Producto Contratado' :'Cerrado positivo';
		this.CLOSED_STATUS_BAD = (this.isnewprod) ?'Producto Rechazado' :'No interesado';
		this.LABEL_CLOSED_BAD =(this.isnewprod) ?'Producto Rechazado' :'Cerrada negativa';
		this.statusNow = (this.oppo.Stage == 'En gestión/insistir') ? 'En Gestión' : this.oppo.Stage;
		this.id = this.oppo.Id;
		this.name = this.oppo.Name;
		this.path = this.oppo.Stage;
		this.oppoDate= this.oppo.Fecha;
		this.comentario = this.oppo.Comentarios;
		this.initPotential = this.oppo.Potencial;
		this.importePropio = this.oppo.ImportePropio;
		this.margin = this.oppo.Margen;
		this.mainPF = this.oppo.ProductoMain;
		this.cuota = this.oppo.ImporteCuota;
		this.importeOtraEntidad = this.oppo.ImporteOtraEntidad;
		this.otraEntidad = (this.oppo.OtraEntidad == 'S');
		this.switchOtherEntity = this.otraEntidad;
		this.otraEntidadNombre = this.oppo.OtraEntidadNombre;
		this.closeDate = this.oppo.CloseDate;
		this.isInserted = (this.oppo.NotInserted == undefined);
		this.vinculed = (this.comesfromevent) ? this.oppo.isVinculed :  (this.oppo.isVinculed != undefined);
		this.mainVinculed = (this.comesfromevent) ? (this.oppo.mainVinculed):false;
		this.prioritingCustomer = this.oppo.Prioritzed;
		this.productName = this.oppo.ProductName;
		this.subestadoToSend = this.oppo.Subestado;  
		this.isnewprodtosend = this.oppo.IsNewProduct;
		this.proximaGestionToSend = this.oppo.Fecha;
		this.historyCommentWithDate = this.oppo.HistoryComment;
		this.owneridopp = this.oppo.owneridopp;  
		if(this.historyCommentWithDate != '' && this.historyCommentWithDate != undefined){
			this.historyCommentDate = this.historyCommentWithDate.split(SEPARADOR)[0];
			this.historyComment = this.historyCommentWithDate.split(SEPARADOR)[1];
			this.historyCommentDateLabel = 'Último comentario - '+this.historyCommentDate;
		}else{
			this.historyCommentDateLabel = '';
			
		}
		if(this.path ==='Potencial'){
			this.isPotencial = true;
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
			AV_IncludeInPrioritizingCustomers__c:this.prioritingCustomer
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

	switchOtherEntityMethod(e){
		this.switchOtherEntity = e.target.checked;
		this.otraEntidad = e.target.checked;
		this.computeSwitch();
	}

	switchMoreInfo(e){
		this.showMoreInfo = e.target.checked;
		this.computeSwitch();
	}

	computeSwitch(){    
		this.secundaryInputs = (this.switchOtherEntity || this.showMoreInfo);
	}

	resetSwitches(){
		this.switchNextManagement = false;
		this.switchPotencial = false;
		this.switchResolution = false;
		this.switchImportSelf = false;
		this.switchImportOtherEntity = false;
		this.switchComentary = false;
		this.switchSubProduct = false;
		this.switchMargin = false;
		this.switchSubImport = false;
		this.showMoreInfo = false;
		this.secundaryInputs = false;
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
		if(buttonToAvoid != 'nolocalizado'){
			this.nolocalizadoClass = this.classMapDefault['nolocalizado'];            
		}
	}

	evaluateAgendeds(condition){
		this.dispatchEvent(
			new CustomEvent(
				'notifyagended',{
					detail:{sum:condition}
				}
			))
	}

	handlePath(e){
		this.showNoOfrecerHasta = false;
		this.firstOpp= false;
		this.validable = true;
		this.template.querySelector('[data-id="'+e.target.name+'"]').blur();
		this.resetCustomButtons(e.target.name);
		let oldValue = this.currentNameButton; 
		this.actualValuePath = e.target.name;
		this.currentNameButton = e.target.name;
		this.especialInputLabel = 'Próxima Gestión';
		this.path = this.pathMap[e.target.name];
		this.isAgendado = false;
		var auxPath;
		
		if(this.path.split('-').length > 1){
			auxPath = this.path.split('-');
			this.path = auxPath[1];
			this.neededToggle = true;
		}else{
			this.neededToggle = (this.path != this.CLOSED_STATUS_OK);
		}
		if (!this.id.includes('idProvisional')) {
			if (this.checkedOld == this.path) { //Para poner el valor antiguo si quita el check
				this.statusNow = (this.oppo.Stage == 'En gestión/insistir') ? 'En Gestión' : this.oppo.Stage;
				this.checkedOld = null;
			} else {
				this.checkedOld = this.path;
			}
		} else {
			if (this.path != this.CLOSED_STATUS_OK && this.path != this.CLOSED_STATUS_BAD && this.path == 'agendar' && this.path == 'gestion'){ // Para que no se ponga el apiname de los valores de cerrados
				this.statusNow = (this.oppo.Stage == 'En gestión/insistir') ? 'En Gestión' : this.oppo.Stage;
			} else if (this.path == this.CLOSED_STATUS_OK) {
				this.statusNow = this.CLOSED_STATUS_OK;
			} else if (this.path == this.CLOSED_STATUS_BAD) {
				this.statusNow = this.LABEL_CLOSED_BAD;
			} else if (this.path == 'agendar' || this.path == 'gestion') {
				this.statusNow = 'En Gestión';
			} 
			if (this.checkedOld == this.path) { //Para poner el valor antiguo si quita el check
				this.statusNow = (this.oppo.Stage == 'En gestión/insistir') ? 'En Gestión' : this.oppo.Stage;
				this.checkedOld = null;
			} else {
				this.checkedOld = this.path;
			}
		}
		
		if(this.path === 'Potencial'){
			this.unfoldCmp = false;
			this.switchOtherEntity = false;
			this.nolocalizadoClass = (this.nolocalizadoClass == this.classMapDefault[e.target.name])
			?this.classMap[e.target.name]            
			:this.classMapDefault[e.target.name];;   
			
			
			if(this.nolocalizado){ 
				if(this.vinculed == false){
					this.unfoldCmp = true; 
				}
				this.subestadoToSend = 'No localizada';
				const fechaYHoraActual = new Date();

				const dia = fechaYHoraActual.getDate().toString().padStart(2, '0'); 
				const mes = (fechaYHoraActual.getMonth() + 1).toString().padStart(2, '0'); // Se suma 1 ya que los meses van de 0 a 11
				const año = fechaYHoraActual.getFullYear();

				const fechaFormateada = `${dia}/${mes}/${año}`;
				const horas = fechaYHoraActual.getHours().toString().padStart(2, '0');
				const minutos = fechaYHoraActual.getMinutes().toString().padStart(2, '0');
				const horaFormateada = horas + ':' + minutos;
				
				this.comentarioToSend = 'No localizado - '+horaFormateada+' - '+ fechaFormateada;  
				
				if(oldValue == this.currentNameButton){
					this.handleVincular();
				}
				else if((oldValue == undefined || oldValue == null) && this.currentNameButton == 'nolocalizado'){ 
					
					if(!this.vinculed){
						this.vinculed = false;
						this.mainVinculed= false;
						this.interruptor = true;
						this.handleVincular();
					}	
				}
			}
			
			
		}else{
			if(this.interruptor2){
				oldValue = 'nolocalizado';
			}
			
				
			if(oldValue != this.currentNameButton){
				this.unfoldCmp = true;
				this.switchOtherEntity = this.otraEntidad;
				if(!this.vinculed){
					this.handleVincular();
				}
				if(oldValue == 'agendado'){
					this.evaluateAgendeds(false);
				}
				if(this.currentNameButton == 'agendado'){
					this.evaluateAgendeds(true);
				}
			}else{
				this.unfoldCmp = !this.unfoldCmp;
				if(!this.unfoldCmp){
					this.resetVars();
				}
				if(this.currentNameButton == 'agendado'){
					this.evaluateAgendeds(this.unfoldCmp);
				}

				if(this.oppislinked == null) {
					this.handleVincular();
				} else {
					this.validable = false;
					if(this.vinculed == false){
						this.vinculed =true
					}else{
						this.vinculed = false;
					}
				}
			}
			if(this.path != 'Vencido'){
				this.resetSwitches();
			}
			if(this.path == 'gestion'){
				this.resetVars();
				this.resetFieldsPopUp();
				this.subProductInitial = null;
				this.path = this.pathMap[e.target.name];
				this.asterisk = true;
				this.asteriskComentary = false;
				this.oppoDate = '';
				this.switchNextManagement = true;
				this.switchPotencial = true;
				this.switchImportSelf = true;
				this.switchImportOtherEntity = true;
				this.switchComentary = true;
				this.switchSubProduct = true;
				this.switchMargin = true;
				this.arrowClass = (this.arrowClass == this.classMapDefault[e.target.name])
				?this.classMap[e.target.name]
				:this.classMapDefault[e.target.name];
				const fieldComentary =  this.template.querySelector('[data-id="comentario"]');
				if(fieldComentary){
					fieldComentary.value = '';
				}
				const fieldOppoDate = this.template.querySelector('[data-id="nextManagementeDate"]');
				if(fieldOppoDate){
					fieldOppoDate.value = '';
				}
			}else if(this.path == 'agendar'){
				this.resetVars();
				this.resetFieldsPopUp();
				if(!this.isInserted){           
					this.proximaGestionToSend = this.parseTodayDate(); 
				}
				this.subProductInitial = null;
				this.path = this.pathMap[e.target.name];
				this.asterisk = false;
				this.asteriskComentary = false;
				this.switchPotencial = true;
				this.switchImportSelf = true;
				this.switchImportOtherEntity = true;
				this.isAgendado = true;
				this.switchComentary = true;
				this.switchSubProduct = true;
				this.switchMargin = true;
				this.agendadoClass = (this.agendadoClass == this.classMapDefault[e.target.name])
				? this.classMap[e.target.name]
				: this.classMapDefault[e.target.name];
				const fieldComentary =  this.template.querySelector('[data-id="comentario"]');
				if(fieldComentary){
					fieldComentary.value = '';
				}
			}else if(this.path == this.CLOSED_STATUS_OK){
				this.resetVars();
				this.resetFieldsPopUp();
				if(!this.isInserted){               
					this.proximaGestionToSend = this.parseTodayDate();
				}
				this.subProductInitial = null;
				this.path = this.pathMap[e.target.name];
				this.asterisk = false;
				this.asteriskComentary = false;
				this.switchImportSelf = true;
				this.switchImportOtherEntity = true;
				this.switchComentary = true;
				this.switchSubProduct = true;
				this.switchMargin = true;
				this.checkClass = (this.checkClass == this.classMapDefault[e.target.name])
				? this.classMap[e.target.name]
				: this.classMapDefault[e.target.name];
				const fieldComentary =  this.template.querySelector('[data-id="comentario"]');
				if(fieldComentary){
					fieldComentary.value = '';
				}
			}else if(this.path == this.CLOSED_STATUS_BAD){
				this.resetVars();
				this.resetFieldsPopUp();
				if(!this.isInserted){
					this.proximaGestionToSend = this.parseTodayDate();
				}
				this.subProductInitial = null;
				this.path = this.pathMap[e.target.name];
				this.asterisk = false;
				this.switchResolution = true;
				this.switchComentary = true;
				this.switchSubProduct = true;
				this.switchImportOtherEntity = true;
				this.closeClass = (this.closeClass == this.classMapDefault[e.target.name])
				? this.classMap[e.target.name]
				: this.classMapDefault[e.target.name];
				const fieldComentary =  this.template.querySelector('[data-id="comentario"]');
				if(fieldComentary){
					fieldComentary.value = '';
				}
			}
		}
		if(auxPath != null){
			this.path=auxPath[0];
		}
	
	
		this.sendDataToController();
		this.computeSwitch();
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
		if(this.subProductoToSend == null){
			this.subProductInitial = null;
		}
	}

	handleSelectionChangeByProduct(event) {
		const selection = this.template.querySelector('[data-id="clookup2"]').getSelection();
		if (selection.length !== 0) {
			this.subProductInitial = selection[0];
			this.subProductoToSend = this.subProductInitial.id;	
			this.sendDataToController();
		} else{
			this.template.querySelector('[data-id="clookup2"]').handleBlur();
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
					main:this.mainVinculed,
					oppoId:this.id
				}
			})
		);
	}

	resetVars(){
		this.comentarioToSend = null;
		this.proximaGestionToSend = null;
		this.expectativaToSend = null;
		this.expectativaToSend = '';
		this.resolucionToSend = null;
		this.importePropioToSend = null;
		this.tenenciaToSend = null;
		this.otraEntidadToSend = null;
		this.fechaOtraEntidadToSend = null;
		this.subProductoToSend = null;
		this.marginToSend = null;
		this.cuotaToSend = null;
		this.importeOtraEntidadToSend = null;
		this.subProductoToSend = null;  
		this.noofrecerhastaToSend = null;
		this.asteriskNoOfrecer = true;
		this.asterisk = true;
	}
	@api
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
					resolucion:this.resolucionToSend,
					importe:this.importePropioToSend,
					comentario:this.comentarioToSend,
					tenencia:this.tenenciaToSend,
					otraEntidad:this.otraEntidadToSend,
					fechaOtraEntidad:this.fechaOtraEntidadToSend,
					subProducto:this.subProductoToSend,
					margin:this.marginToSend,
					cuota:this.cuotaToSend,
					importeOtraEntidad:this.importeOtraEntidadToSend,
					closedate:this.closeDate,
					mainVinculed:this.mainVinculed,
					isVinculed:this.vinculed,
					agendado:this.isAgendado,
					validable:this.validable,
					prioritzingCustomer:this.prioritingCustomer,
					productName : this.productName,
					subestado : this.subestadoToSend,  
					noofrecerhasta: this.noofrecerhastaToSend,
					isnewprod: this.isnewprodtosend
					,owneridopp : this.owneridopp      
				}
			})
		)
	}


   
	handleChangeFecha(e){
		if(e.target.value != null){
			this.proximaGestionToSend = e.target.value;
			this.asterisk = false;
		}else{
			e.target.value = '';
			this.proximaGestionToSend = null;
			this.asterisk = true;
		}
		this.sendDataToController();
	}

	handleChangePotencial(e){
		this.expectativaToSend = e.target.value;
		this.sendDataToController();
	}

	handleChangeResolucion(e){
		this.resolucionToSend = e.target.value;
		if(this.resolucionToSend == 'O'){
			this.showNoOfrecerHasta = false;
			if (e.target.value != null){
				this.asteriskComentary = true;
			}else{
				this.asteriskComentary = false;
			}
		}else if(this.resolucionToSend == 'No Apto'){
			this.asteriskComentary = false;
			this.showNoOfrecerHasta = true;
		}else{
			this.showNoOfrecerHasta = false;
			this.asteriskComentary = false;
		}
		this.sendDataToController();
	}

	handleChangeImportePropio(e){
		this.importePropioToSend= e.target.value;
		this.sendDataToController();
	}


	handleChangeComentario(e){
		if (e.target.value != null){
			this.asteriskComentary = false;
		}else{
			this.asteriskComentary = true;
		}
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
		if(e.target.reportValidity()){
			this.fechaOtraEntidadToSend = e.target.value;
		}else{
			e.target.value = '';
			this.fechaOtraEntidadToSend = null;
		}
		this.sendDataToController();
	}

	handleChangeMargin(e){
		this.marginToSend = e.target.value;
		this.sendDataToController();
	}

	handleChangeCuota(e){
		this.cuotaToSend = e.target.value;
		this.sendDataToController();
	}

	openDetailWindow(){
		this.isModalOpen = true;
	}

	closeModal(){
		let error = null;
		var nowReference = new Date().toJSON().slice(0, 10);
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
		if(this.fechaOtraEntidadToSend < nowReference){
			this.showToast('Error', 'La fecha no puede ser inferior a hoy.', 'error', 'pester');
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

	handleChangeNoOfrecerHasta(e){
		this.noofrecerhastaToSend = e.target.value;
		if(this.noofrecerhastaToSend != null ){
			this.asteriskNoOfrecer = false;
		}else{
			this.asteriskNoOfrecer = true;
		}
		this.sendDataToController();

	}
	@api
	highlightBadInput(){
		this.template.querySelector('[data-id="mainDiv"]').style.border = "solid 1.5px rgba(255,0,0,1)";
		let interval;
		let opacity = 1;
		var gradoOp = 50;
		let opacityLevel = 0.15;
		setTimeout(
			(resul)=>{
				interval = setInterval(
					(resul2) =>{
						opacity -= opacityLevel;
						this.template.querySelector('[data-id="mainDiv"]').style.border = 'solid 1.5px rgba(255,0,0,'+opacity+')';
						if(opacity < 0){
							this.template.querySelector('[data-id="mainDiv"]').style.border = '';
							clearInterval(interval);
						}
					}
					,gradoOp);//Graduacion de la opacidad del borde rojo
				}
				,2500);//Tiempo que tarda en empezar a desaparecer 
	}

	openDeleteWindow(){
		this.isModalDeleteOpen = true;
	}

	closeDeleteWindow(){
		this.isModalDeleteOpen = false;
	}

	handleDelete() {
        const deleteEvent = new CustomEvent('deleteoppo', {
            detail: this.oppo.Id
        });
		this.evaluateAgendeds(false);
        this.dispatchEvent(deleteEvent);
		
    }
	
}