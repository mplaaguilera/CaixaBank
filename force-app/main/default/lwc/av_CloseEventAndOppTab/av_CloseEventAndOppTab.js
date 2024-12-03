import { LightningElement, api, wire } from 'lwc';
import { CurrentPageReference  } from 'lightning/navigation';
import { ShowToastEvent }   from 'lightning/platformShowToastEvent';
import { createRecord }     from 'lightning/uiRecordApi';

import saveOppRecords       from '@salesforce/apex/AV_NewOpportunity_Controller.saveOppRecords';
import validateOppRecords   from '@salesforce/apex/AV_NewOpportunity_Controller.validateOppRecords';
import doPendingTasksExist  from '@salesforce/apex/AV_TabManagementEvent_Controller.doPendingTasksExist';
import updateEvent          from '@salesforce/apex/AV_TabManagementEvent_Controller.updateEvent';
import getEventData         from '@salesforce/apex/AV_TabManagementEvent_Controller.getEventData';
import updateTasksAviso     from '@salesforce/apex/AV_PendingTasks_Controller.updateTasksAviso';

//Labels
import successLabel         from '@salesforce/label/c.AV_CMP_SuccessEvent';
import successUnlinkMsgLabel from '@salesforce/label/c.AV_CMP_ReportCompleted';
import errorMsgLabel        from '@salesforce/label/c.AV_CMP_SaveMsgError';

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
        /*this.enableSpinner();
        saveOppRecords({listOppRecords: this.listOppTask})
            .then(result => {
                if (result != 'OK' && result != 'KO') {
                    this.showToast('Error', result, 'error', 'pester');
                    this.disableSpinner();
                }
                if (result == 'OK') {
                    this.showToast('Success', 'Oportunidad guardada con éxito.', 'success');
                    this.disableSpinner();
                }
            })
            .catch(error => {
                console.log(error);
                this.showToast('Error', result, 'error', 'pester');
                this.disableSpinner();
        });*/
	}

    handleDataOpp(event) {
        var listData = [];
        listData.push(event.detail);
        this.newOpp = listData;
        //this.sendDataFlow(event);
    }

    handelCancelNewOpp() {
        this.newOpp = [];
        this.showNewoppo = false;
    }

    handleSave(){
        this.fecha = new Date().toISOString().substring(0,10);
        var listOppTskAux = this.listOppTask;
        var listAllOpps; 
        if(this.newOpp.length > 0) {
            listAllOpps = listOppTskAux.concat(this.newOpp);
        } else {
            listAllOpps = listOppTskAux;
        }
        this.enableSpinner();
        validateOppRecords({listOppRecords: listAllOpps, listParseOppRecords: null})
            .then(result => {
                if(result == 'OK') {
                    this.updateEvent(listAllOpps);
                    //this.updateOpp(listAllOpps);
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
            })
            .catch(error => {
                console.log(error);
                this.showToast('Error', error, 'error', 'pester');
                this.disableSpinner();
        });
    }

    updateEvent(listAllOpps) {
        updateEvent({id: this.recordId, comment: this.comment})
            .then(result => {
                if (result == 'OK') {
                    this.updateOpp(listAllOpps);
                    /*if (this.listTaskPending.length!=0) {
                        this.updateTareasAviso();
                    } else {
                        this.insertHistorialGestion();
                    }*/
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
        saveOppRecords({listOppRecords: listAllOpps})
            .then(result => {
                if(result == 'OK') {
                    //this.updateEvent();
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
				"AV_Status__c": this.status,
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
}