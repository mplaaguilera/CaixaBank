import { LightningElement, api, track } from 'lwc';
import { ShowToastEvent } 	    from 'lightning/platformShowToastEvent';
import FORM_FACTOR from '@salesforce/client/formFactor';

//Methods
import retrieveListOpp from '@salesforce/apex/AV_ListOpportunities_Controller.retrieveListOpp';
import getStatusValues from '@salesforce/apex/AV_ListOpportunities_Controller.getStatusValues';
import retrieveListWithOutTask from '@salesforce/apex/AV_ListOpportunities_Controller.retrieveListWithOutTask';
import getRecInfo from '@salesforce/apex/AV_ListOpportunities_Controller.getRecordInfo';
import saveOppRecords from '@salesforce/apex/AV_NewOpportunity_Controller.saveOppRecords';
import validatePFNewOppAndForbiddenWords from '@salesforce/apex/AV_NewOpportunity_Controller.validatePFNewOppAndForbiddenWords';
//Labels
import 	opp from '@salesforce/label/c.AV_oppoTask';
import 	oppLinked from '@salesforce/label/c.AV_OppLinked';
import 	oppUnLinked from '@salesforce/label/c.AV_OppUnLinked';
import 	oppUnLinkedMobile from '@salesforce/label/c.AV_OppUnLinkedMobile';
import 	noDataFoundLabel from '@salesforce/label/c.AV_CMP_NoDataFound';
// import 	errorMsgLabel from '@salesforce/label/c.AV_CMP_SaveMsgError';
import  interestDecimalLabel from '@salesforce/label/c.AV_ValidateInterestDecimalType';
import  amountDecimalLabel from '@salesforce/label/c.AV_ValidateAmountDecimalType';
import  feeAmountDecimalLabel from '@salesforce/label/c.AV_ValidateFeeAmountDecimalType';
import  expectedMarginDecimalLabel from '@salesforce/label/c.AV_ValidateExpectedMarginDecimalType';
import  validateOppNextManagementDate from '@salesforce/label/c.AV_ValidateOppNextManagementDate';
import  validateOppStatusPrioritizedClients from '@salesforce/label/c.AV_ValidateOppStatusPrioritizedClients';
import  validateOppComment from '@salesforce/label/c.AV_ValidateOppComment';
import  validateOppWithSale from '@salesforce/label/c.AV_ValidateOppWithSale';
import  validateOppResolution from '@salesforce/label/c.AV_ValidateOppResolution';
import  validateOppStage from '@salesforce/label/c.AV_ValidateOppStage';
import  validateOppNextManagementDateNull from '@salesforce/label/c.AV_ValidateOppNextManagementDateNull';
import  validateOppNextManagementDate2 from '@salesforce/label/c.AV_ValidateOppNextManagementDate2';
import init from '@salesforce/apex/AM_Case_Gestion_Controller.init';



export default class Av_ListOpportunities extends LightningElement {
	
	@api recid;
	@api sobjname;
	@api newrecord;
	@api isreport;
	@api eventnoplanificado;

	label = {
		oppLinked,
		oppUnLinked,
		oppUnLinkedMobile,
		noDataFoundLabel,
		opp
	};

	icon = 'standard:opportunity';
	vinculatedOpportunities = [];
	@track listOpp;
	@track listaVincular=[];
	@track listOppNotRelated;
	@track stagesValuesOppTask;
	@track stagesValuesOpp;
	@track showSpinner = true;
	@track recInfo;
	@track taskHeaderId;
	@track onlyOneOppTask = false;
	@track isEvent=false;
	@track recordInfo;
	listComments = [];
	listNames = [];
	initialStageOppo = {};
	initialIncludeOppo = {};
	get isBrowser() {
		if(FORM_FACTOR == 'Large'){
			this.formFactorBrowser = true;
		}else{
			this.formFactorBrowser = false;
		}

		return this.formFactorBrowser;
	  }

	connectedCallback() {
		if (this.sobjname=='Event') {
			this.isEvent=true;
		}
		if (this.eventnoplanificado == null) {
			this.eventnoplanificado =false;
		}
		this.getRecordInfo();
		
	}

	refreshCmp(){
		this.enableSpinner();
		this.listOpp = undefined;
		this.listaVincular = [];
		this.onlyOneOppTask = false;
		this.listOppNotRelated = undefined;
		this.stagesValuesOppTask = undefined;
		this.stagesValuesOpp = undefined;
		this.dispatchEvent(new CustomEvent('refreshlink'));
		this.getDataOppTask();
		this.getDataOpp();
	}

	refreshMainCmp(){
		this.enableSpinner();
		this.listOpp = undefined;
		this.onlyOneOppTask = false;
		this.stagesValuesOppTask = undefined;
		this.getDataOppTask();
	}

	getDataOppTask(){
		retrieveListOpp({recordInfoJson: this.recInfo})
			.then(result => {
				if(result != null) {
					this.listOpp = result;
					if(this.listOpp.length == 0){
						this.sendResultToFlow('OK');//Si no hay oportunidades limpieamos el mensaje de error
					}
					this.listaVincular = [];
					if(this.listOpp.length === 1) {
						this.onlyOneOppTask = true;
					}
					this.getStatus('Opportunity', 'StageName');
				} else {
					this.disableSpinner();
					this.listOpp = [];
				}
			})
			.catch(error => {
				this.showToast('Error', error.body.message, 'error');
				console.log(error.body);
				this.disableSpinner();
		});
	}

	getDataOpp() {
		retrieveListWithOutTask({recordInfoJson: this.recInfo})
			.then(result => {
				if(result != null) {
					this.listOppNotRelated = result;
					this.getStatus('Opportunity', 'StageName');
				} else {
					this.disableSpinner();
				}
			})
			.catch(error => {
				this.showToast('Error', error.body.message, 'error');
				console.log(error.body);
				this.disableSpinner();
		});
	}

	getRecordInfo(){
		getRecInfo({recordId: this.recid, objectName: this.sobjname})
			.then(result => {
				if(result != null) {
					this.recInfo = result;
					this.taskHeaderId = JSON.parse(result).taskHeader;
					this.recordInfo = JSON.parse(result);
					this.getDataOppTask();
					this.getDataOpp();
				}
			})
			.catch(error => {
				this.showToast('Error', error.body.message, 'error');
				this.disableSpinner();
		});
	}

	getStatus(objName, fldName){
		getStatusValues({objectName: objName, fieldName: fldName})
			.then(result => {
				if(objName === 'Opportunity') {
					this.stagesValuesOppTask = result;
					for(var item of this.template.querySelectorAll('c-av_-detail-opp-task')) {
						item.pathValues(this.stagesValuesOppTask);
					}
				} else if(objName === 'Opportunity') {
					this.stagesValuesOpp = result;
					for(var item of this.template.querySelectorAll('c-av_-detail-opp')) {
						item.pathValues(this.stagesValuesOpp);
					}
				}
				this.disableSpinner();
			})
			.catch(error => {
				this.showToast('Error', error.body.message, 'error');
				this.disableSpinner();
		});
	}

	callLaunchFlow(event) {
		var flowName = event.detail.flow;
		var oppId = event.detail.recId;
		const flwEvent = new CustomEvent('launchflow', {
			detail: {
				value: flowName,
				oppId: oppId
			}
		});
		this.dispatchEvent(flwEvent);
	}

	disableSpinner() {
		this.showSpinner = false;
	}

	enableSpinner() {
		this.showSpinner = true;
	}

	showToast(title, message, variant) {
		const event = new ShowToastEvent({
			title: title,
			message: message,
			variant: variant
		});
		this.dispatchEvent(event);
	}

	sendData(event) {       
	
		const sendData = new CustomEvent('datareport', {
			detail: event.detail
		});
		this.dispatchEvent(sendData);
	}

	sendDataFlow(event) {
		this.showSpinner=true;
		var listData = [];
		let newOpp;
		let alreadyVinculated = this.listaVincular.map(opp => opp["id"]);
		if(alreadyVinculated.length > 0){
			if(!alreadyVinculated.includes(event.detail.id)){
				this.listaVincular.push(event.detail);
			}else{
				let reloadArray;
				for(let i = 0; i<this.listaVincular.length ; i++){
					if(this.listaVincular[i].id == event.detail.id){
						reloadArray = i;
						break;
					}
				}
				this.listaVincular.splice(reloadArray,1);
				this.listaVincular.push(event.detail);
			}
		}else{
			this.listaVincular.push(event.detail);
		}
		this.listComments = [];
		this.listNames = [];
		let validation = this.validateOppos(this.listaVincular);
		if(validation == 'OK'){
			let newProd = newOpp != null ? newOpp['producto'] : null;
			let newProdTskId = newOpp != null ? newOpp['taskid'] : null;
			this.sendResultToFlow(validation);
			validatePFNewOppAndForbiddenWords({prodId:newProd,tskId:newProdTskId,comments:this.listComments})
			.then(result => {
				if(result == 'OK' || result.includes('Warning')){
					saveOppRecords({listOppRecords: this.parseOppos(this.listaVincular), idTask: this.recid})
					.then(result => {
						this.sendResultToFlow(result);
						this.showSpinner = false;
						if(result != 'OK'){
							this.showToast('Error', result, 'error', 'pester');
						}	
					}).catch(error => {
						this.showSpinner = false;
						console.log(error);
					})
				}else{
					this.showSpinner = false;
					this.sendResultToFlow(result);
					this.showToast('Error', result, 'error', 'pester');
				}
			}).catch(error => {
				console.log(error);
				this.showToast('Error', error, 'error', 'pester');
			})
		}else{
			this.showSpinner = false;
			this.sendResultToFlow(validation);
			this.showToast('Error', validation, 'error', 'pester');
		}
	}

	parseOppos(opposToWork){
		let result = [];
		opposToWork.forEach(opp =>{
			let nextOpp = {
				sobjectType : 'Opportunity',
				Id : opp['id'], 
				StageName : opp['path'], 
				AV_FechaProximoRecordatorio__c : opp['fechagestion'], 
				AV_IncludeInPrioritizingCustomers__c : opp['incluir'], 
				AV_FechaVencimiento__c : opp['fechavencimiento'], 
				AV_Entidad__c : opp['entidad'], 
				AV_Comentarios__c : opp['comentario'], 
				Amount : opp['importe'], 
				AV_TipoInteres__c : opp['interes'], 
				AV_PF__c : opp['producto'], 
				Name : opp['oportunidad'], 
				AV_Cuota__c : opp['cuota'], 
				AV_LicensePlate__c : opp['matricula'], 
				AV_Tenencia__c : opp['otraentidadpick'], 
				AV_OrigenApp__c : 'AV_SalesforceReport',
				AV_Potencial__c : opp['potencial'], 
				AV_Resolucion__c : opp['resolucion'], 
				AV_AmountEuro__c : opp['amount'], 
				AV_MarginEuro__c : opp['margin'], 
				AV_ByProduct__c : opp['byProduct'], 
				RecordTypeId : opp['oppRecordType']
			};

			let closedStatus = ['Cerrado negativo','Cerrado positivo','No apto','No interesado'];
			if(nextOpp.Id != null){
				if(closedStatus.includes(nextOpp.StageName)){
					nextOpp.AV_IncludeInPrioritizingCustomers__c = false;
				}
			}

			result.push(nextOpp);
		})

		return result;
	}
	sendResultToFlow(result){
		this.dispatchEvent(new CustomEvent('textflow', {
			detail:{
				textError:result
			}
		}));
	}


	validateOppos(opposToWork){
		let decimalFieldsToError = {
			'interes' :	interestDecimalLabel,
			'importe' :	amountDecimalLabel,
			'cuota'   :	feeAmountDecimalLabel,
			'amount'  :	amountDecimalLabel,
			'margin'  :	expectedMarginDecimalLabel
		};
		let today = new Date();
		today.setHours(0,0,0,0);
		let automaticStages = ['Con venta','Vencido','Potencial'];
		let validationStatus = ['Cerrado positivo','No interesado','En gestión/insistir','No apto'];
		let validationStatus2 = ['No interesado','Potencial','Cerrado positivo'];
		let dateStages = ['Potencial','En gestión/insistir','No apto'];

		let decimalRegex = /^(\d+,\d{1,2}(?!,)|\d+)$/;
		let result = 'OK';
		opposToWork.forEach(opp =>{
			let validated = true;
			if(!Object.keys(this.initialStageOppo).includes(opp['id'])){
				this.initialStageOppo[opp['id']]= opp['path'];
			}
			if(!Object.keys(this.initialIncludeOppo).includes(opp['id'])){
				this.initialIncludeOppo[opp['id']] = opp['incluir'];
			}
			for(let key in opp){
				if(Object.keys(decimalFieldsToError).includes(key) && opp[key] != null && opp[key] != undefined && opp[key] != '' && !decimalRegex.test(opp[key])){
					validated = false;
					result = decimalFieldsToError[key];
					break;
				}
			}
			if(!validated){
				return;
			}
			let currentRtDevName;
			if(opp['oppRecordType'] != null){
				currentRtDevName = opp['oppRecordTypeDevName'];

			}
			let currentStage = opp['path'];

			if(opp['id'] == null ||  opp['id'] == undefined){
					if(opp['fechagestion'] == null || opp['fechagestion'] == undefined){
						result = validateOppNextManagementDateNull;
						return;
					}
					if(opp['fechagestion'] != null && (new Date(opp['fechagestion'] < today))){
						result = validateOppNextManagementDate;
						return;
					}
					if(opp['incluir'] && opp['path'] != 'En gestión/insistir' && opp['path'] != 'Potencial'){
						result = validateOppStatusPrioritizedClients;
						return;
					}

				if(opp['comentario'] != null && opp['comentario'].length > 4000){
					result = validateOppComment;
					return;
				}
				 if(automaticStages.includes(opp['path'])){
					result = validateOppStage;
					return;
				}
			}else{
				let rtNames = ['AV_CallMe', 'AV_AlertaComercial', 'AV_Sugerencia', 'AV_Propuesta'];
				let initialStage = this.initialStageOppo[opp['id']];
				if(initialStage == 'Con venta' && (validationStatus.includes(currentStage)) && rtNames.includes(currentRtDevName)){
					result = validateOppWithSale;
					return;
				}
				if(opp['incluir'] && !this.initialIncludeOppo[opp['id']] ){
					if(opp['path'] != 'En gestión/insistir' && opp['path'] != 'Potencial'){
					   result = validateOppStatusPrioritizedClients;
					   return;
				   }
			   }
			   if( (currentStage == 'Con venta' && initialStage != 'Con venta')
			   ||(currentStage == 'Vencido' && initialStage != 'Vencido')
			   ||(currentStage == 'Potencial' && initialStage != 'Potencial')){
			   result = validateOppStage;
			   return;
		   }
			   if(dateStages.includes(opp['path'])){

				if(opp['fechagestion'] == null){
					result = validateOppNextManagementDateNull;
					return;
				}
				if(opp['fechagestion'] != null && (new Date(opp['fechagestion']) < today)){
					result = validateOppNextManagementDate;
					return;
				}
			}
				if(opp['comentario'] != null && opp['comentario'].length > 4000){
					result = validateOppComment;
					return;
				}
				if((opp['comentario'] == null ||opp['comentario'].trim().length == 0) && opp['resolucion'] == 'O'){
					result = validateOppResolution;
					return;
				} 
			
				
				if(opp['fechagestion'] == null && (currentStage == 'En gestión/insistir' ||currentStage == 'No Apto')){
					result = validateOppNextManagementDateNull;
					return;
				}
				if(new Date(opp['fechagestion']) < today && !validationStatus2.includes(currentStage)){
					result = validateOppNextManagementDate2;
					return;
				}
				this.listComments.push(opp['comentario']);
				this.listNames.push(opp['oportunidad']);
			}
		})

		return result;
	}
}