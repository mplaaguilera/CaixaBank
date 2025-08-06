import { LightningElement, api, wire } from 'lwc';
import { CurrentPageReference  } from 'lightning/navigation';
import { ShowToastEvent }   from 'lightning/platformShowToastEvent';
import { createRecord }     from 'lightning/uiRecordApi';
import validatePFNewOppAndForbiddenWords from '@salesforce/apex/AV_NewOpportunity_Controller.validatePFNewOppAndForbiddenWords';

import saveOppRecords       from '@salesforce/apex/AV_NewOpportunity_Controller.saveOppRecords';
import doPendingTasksExist  from '@salesforce/apex/AV_TabManagementEvent_Controller.doPendingTasksExist';
import updateEvent          from '@salesforce/apex/AV_TabManagementEvent_Controller.updateEvent';
import getEventData         from '@salesforce/apex/AV_TabManagementEvent_Controller.getEventData';
import updateTasksAviso     from '@salesforce/apex/AV_PendingTasks_Controller.updateTasksAviso';

//Labels
import successLabel         from '@salesforce/label/c.AV_CMP_SuccessEvent';
import successUnlinkMsgLabel from '@salesforce/label/c.AV_CMP_ReportCompleted';
import errorMsgLabel        from '@salesforce/label/c.AV_CMP_SaveMsgError';
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


export default class Av_CloseEventAndOppTab extends LightningElement {

    listOppTask = [];
    listTaskPending = [];
    newOpp = [];
    showSpinner = false;
    saveButton = false;
    pendingTask = false;
    comment;
    type;
    fecha;
    status = 'Gestionada positiva';
    @api recordId;
    @api showNewoppo = false;
	initialStageOppo = {};
	initialIncludeOppo = {};
	listComments = [];
	listNames = [];
	accountId;
    @wire(CurrentPageReference)
    setCurrentPageReference(currentPageReference) {
        this.currentPageReference = currentPageReference;
    }
    connectedCallback(){
        this.recordId = this.currentPageReference.state.c__recId;
        const selectedEvent = new CustomEvent("renametab");
		this.dispatchEvent(selectedEvent);
        this.getEventData();
        this.doPendingTasksExist();
    }

    doPendingTasksExist() {
        doPendingTasksExist({id: this.recordId})
            .then(result => {
                if (result) {
                    this.pendingTask = true;
                }
            })
            .catch(error => {
				console.log('Display ShowToastEvent error (catch): ', error);
                this.dispatchEvent(
					new ShowToastEvent({
						title: AV_CMP_ErrorMessage,
						message: JSON.stringify(error),
						variant: 'error'
					})
				);
            });
    }

    handleNewOpp(){
        this.showNewoppo = true;
    }

    handleRefresh() {
        this.listOppTask=[];
    }

    handleDataReport(event) { //trae del hijo
        var listData = [];
        for(let i = 0; i < this.listOppTask.length; i++) {
            if(this.listOppTask[i].id != event.detail.id) {
                listData.push(this.listOppTask[i]);
            }
        }
        listData.push(event.detail);
        this.listOppTask = listData;
        listData.forEach(opp => {
			if(!Object.keys(this.initialStageOppo).includes(opp['id'])){
				this.initialStageOppo[opp['id']]= opp['path'];
			}
			if(!Object.keys(this.initialIncludeOppo).includes(opp['id'])){
				this.initialIncludeOppo[opp['id']] = opp['incluir'];
			}
		})
	}

    handleDataOpp(event) {
        var listData = [];
        listData.push(event.detail);
        this.newOpp = listData;
    }

    handelCancelNewOpp() {
        this.newOpp = [];
        this.showNewoppo = false;
    }

    handleSave(){
        this.fecha = new Date().toISOString().substring(0,10);
        var listOppTskAux = this.listOppTask;
        var listAllOpps; 
		let newOppId = null;
        if(this.newOpp.length > 0) {
            listAllOpps = listOppTskAux.concat(this.newOpp);
            newOppId = this.newOpp[0]['producto'];
        } else {
            listAllOpps = listOppTskAux;
        }
        this.enableSpinner();
		let result = this.validateOppos(listAllOpps);
		if(result == 'OK'){
            validatePFNewOppAndForbiddenWords(
				{prodId : newOppId,
                tskId : this.recordId,
				comments : this.listComments,
				names : this.listNames
			}).then(result => {
                if(result == 'OK') {
                    this.updateEvent(listAllOpps);
                } else if(result == 'KO'){
                    this.showToast('Error', errorMsgLabel, 'error', 'pester');
                    this.disableSpinner();
                }else if (result.includes('Warning')) {
					this.showToast('Warning', result, 'warning', 'sticky');
					this.updateEvent(listAllOpps);
				} else {
                    this.showToast('Error', result, 'error', 'pester');
                    this.disableSpinner();
                }
            }).catch(error => {
				console.log(error);
				this.showToast('Error', errorMsgLabel, 'error', 'pester');
				this.disableSpinner();
			})
        }else{
            this.showToast('Error', result, 'error', 'pester');
            this.disableSpinner();

        }
    
    }

    updateEvent(listAllOpps) {
        updateEvent({id: this.recordId, comment: this.comment})
            .then(result => {
                if (result == 'OK') {
					let param = this.parseOppos(listAllOpps);
                    this.updateOpp(param);
				} else {
					this.showToast('Error', result, 'error', 'pester');
                    this.disableSpinner();
				}
            })
            .catch(error => {
				console.log(error);
                this.showToast('Error', 'Error actualizando el evento', 'error', 'pester');
                this.disableSpinner();
			});
    }

	updateOpp(listAllOpps){
        saveOppRecords({listOppRecords: listAllOpps, idTask: this.recordId})
            .then(result => {
                if(result == 'OK') {
                    if (this.listTaskPending.length!=0) {
                        this.updateTareasAviso();
                    } else {
                        this.insertHistorialGestion();
                    }
                } else if(result == 'KO'){
                    this.showToast('Error', errorMsgLabel, 'error', 'pester');
                    this.disableSpinner();
                } else if(result.includes('Warning')) {
					if (this.listTaskPending.length!=0) {
                        this.updateTareasAviso();
                    } else {
                        this.insertHistorialGestion();
                    }
				} else {
                    this.showToast('Error', result, 'error', 'pester');
                    this.disableSpinner();
                }
            })
            .catch(error => {
                console.log(error);
                this.showToast('Error', error.body.message, 'error', 'pester');
                this.disableSpinner();
        });
    }

    updateTareasAviso() {
    var dataJson=JSON.stringify(this.listTaskPending);
        updateTasksAviso({jsonString: dataJson})
            .then(result => {
                if(result == 'OK') {
                    this.insertHistorialGestion();
                } else if(result == 'KO'){
                    this.showToast('Error', errorMsgLabel, 'error', 'pester');
                    this.disableSpinner();
                } else {
                    this.showToast('Error', result, 'error', 'pester');
                    this.disableSpinner();
                }
            })
            .catch(error => {
                console.log(error);
                this.showToast('Error', error.body.message, 'error', 'pester');
                this.disableSpinner();
        });
    }

    insertHistorialGestion() {
		var record = {
			"apiName": "AV_ManagementHistory__c",
			"fields": {
				"AV_ActivityId__c": this.recordId,
				"AV_Date__c": this.fecha,
				"AV_Type__c": this.type,
				"AV_Status__c": this.status
			}
		};
		createRecord(record)
			.then(() => {
                this.showToast('Success', 'Evento cerrado con éxito', 'success', 'pester');
				this.disableSpinner();
				const selectedEvent = new CustomEvent("closetab");
				this.dispatchEvent(selectedEvent);
			})
			.catch(error => {
				this.showToast('Error', error.body.message, 'error', 'pester');
                this.disableSpinner();
		});
	}

    getEventData() {
        getEventData({id: this.recordId})
            .then(result => {
                this.comment = result.comment;
                this.type = result.tipo;
            })
            .catch(error => {
                console.log(error);
                this.showToast('Error', error.body.message, 'error', 'pester');
                this.disableSpinner();
            });
    }

    handleComment(event) {
        this.comment = event.target.value;
    }

    handleDataPendingTask(event) {
        var listData = [];
        for(let i = 0; i < this.listTaskPending.length; i++) {
            if(this.listTaskPending[i].id != event.detail.id) {
                listData.push(this.listTaskPending[i]);
            }
        }
        listData.push(event.detail);
        for(let i = 0; i < listData.length; i++) {
            if (listData[i].estado == null){
                listData.splice(i,1);
            }
        }
        this.listTaskPending = listData;
	}

    showToast(title, message, variant, mode) {
		const event = new ShowToastEvent({
			title: title,
			message: message,
			variant: variant,
			mode: mode
		});
		this.dispatchEvent(event);
	}

    disableSpinner() {
        this.showSpinner = false;
        this.saveButton = false;
    }

    enableSpinner() {
        this.showSpinner = true;
        this.saveButton = true;
    }

    fetchData() {
		var detail = {
			estado: this.status,
			tipo: this.type,
			fecha: this.fecha
		}

		return detail;
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
		let validationStatus = ['Cerrado positivo','Producto Contratado','No interesado','Producto Rechazado','En gestión/insistir'];
		let validationStatus2 = ['No interesado','Producto Rechazado','Potencial','Cerrado positivo','Producto Contratado'];
		let dateStages = ['Potencial','En gestión/insistir'];
		let decimalRegex = /^(\d+,\d{1,2}(?!,)|\d+)$/;
		let result = 'OK';
		this.listComments = [];
		this.listNames = [];
	
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
			if(opp['oppRecordTypeDevName'] != null){
				currentRtDevName = opp['oppRecordTypeDevName'];

			}
			let currentStage = opp['path'];

			if(opp['id'] == null ||  opp['id'] == undefined || opp['id'] == ""){
				if(opp['path'] == 'En gestión/insistir'){
					if(opp['fechagestion'] == null || opp['fechagestion'] == undefined){
						result = validateOppNextManagementDateNull;
						
						return;
					}
					
					if((opp['fechagestion'] != null && (new Date(opp['fechagestion']) < today))){
						
						result = validateOppNextManagementDate;
						
						return;
					}
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
				if( (currentStage == 'Con venta' && initialStage != 'Con venta')
					||(currentStage == 'Vencido' && initialStage != 'Vencido')
					||(currentStage == 'Potencial' && initialStage != 'Potencial')){
					result = validateOppStage;
					return;
				}
			}

			if(opp['fechagestion'] == null && (currentStage == 'En gestión/Insistir')){
				result = validateOppNextManagementDateNull;
				return;
			}
			if(new Date(opp['fechagestion']) < today && !validationStatus2.includes(currentStage)){
				result = validateOppNextManagementDate2;
				return;
			}
			this.listComments.push(opp['comentario']);
			this.listNames.push(opp['oportunidad']);
		})

		return result;
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

			let closedStatus = ['Cerrado negativo','Cerrado positivo','Producto Contratado','No interesado','Producto Rechazado'];
			if(nextOpp.Id != null){
				if(closedStatus.includes(nextOpp.StageName)){
					nextOpp.AV_IncludeInPrioritizingCustomers__c = false;
				}
			}
            if(nextOpp.Id == ''){
				nextOpp.AccountId = this.recordId;
				nextOpp.Id = null;

			}
			result.push(nextOpp);
		})
		return result;
	}
}