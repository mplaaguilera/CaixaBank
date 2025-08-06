import { LightningElement, api, track, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
    
//Methods

import getRecInfo from '@salesforce/apex/CIBE_Related_Task_Controller.getRecordInfo';
import retrieveListWithOutTask from '@salesforce/apex/CIBE_Related_Task_Controller.retrieveListWithOutMeeting';
import roleCib             from '@salesforce/apex/CIBE_Oportunidades_Vinculadas_Controller.roleCIB2';


//Labels
import tareasVinculadas from '@salesforce/label/c.CIBE_TareasVinculadas';
import tareasDisponibles from '@salesforce/label/c.CIBE_TareasDisponiblesDelCliente';
import nuevaTarea from '@salesforce/label/c.CIBE_NuevaTarea';

export default class cibe_RelatedTaskList extends LightningElement {

    labels = {
        tareasVinculadas,
        tareasDisponibles,
        nuevaTarea
    };
        
        @api recid;
        @api recordId;
        @api editable;
        @api sobjname = 'Event';
        @api listToUpdate;
        @track rId;
        @track recInfo;
        @track listTask;
        @track showSpinner = false;
        @track isModalOpen = false;
        @track roleCib = false;
    
        connectedCallback() {
            this.enableSpinner();
            if(this.recid!=null){
                this.rId = this.recid;
                this.getRecordInfo(this.recid);
            }else{
                this.rId = this.recordId;
                this.getRecordInfo(this.recordId);
            }
        }

        getRecordInfo(rid){
            getRecInfo({recordId: rid, objectName: this.sobjname})
                .then(result => {
                    //if(result != null) {
                        this.recInfo = result;
                        this.getDataTask(rid);
                    //}
                })
                .catch(error => {
                    this.showToast('Error', error.body.message, 'error');
                }).finally(() => {
                    this.disableSpinner();
                });
        }

        getDataTask(rid) {
            retrieveListWithOutTask({recordId : rid})
                .then(result => {
                    if(result != null) {
                        this.listTask = result;
                    }
                }).catch(error => {
                    this.showToast('Error', error.body.message, 'error');
                }).finally(() => {
                    this.disableSpinner();
                });
        }

        showToast(title, message, variant) {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: title,
                    message: message,
                    variant: variant
            }));
        }

        refreshCmp(){
            this.enableSpinner();
            this.recInfo = [];
            this.listTask = [];
            if(this.recid!=null){
                this.getRecordInfo(this.recid);
            }else{
                this.getRecordInfo(this.recordId);
            }
            //window.location.reload();
        }

        enableSpinner() {
            this.showSpinner = true;
        }

        disableSpinner() {
            this.showSpinner = false;
        }

        get isSingleOpp () {
            return (this.recInfo.length === 1);
        }

        handleDataPadre(event) {
            this.dispatchEvent(
                new CustomEvent('datareport', {
                    detail: event.detail
            }));
        }

        refresh(event) {
            this.showSpinner = true;
            this.getDataOpp();
            this.showSpinner = false;
        }

        @wire(roleCib)
        getRoleCib({data, error}) {
            if(data) {
                this.roleCib = data;
            } else if(error) {
                console.log(error);
            }
        }

        createTask(){
            this.isModalOpen = true;
            if(this.actionSetting != 'CIBE_Nueva_Tarea' && this.roleCib){
                this.actionSetting = 'CIBE_Nueva_Tarea';
            }
            this.inputVariables = [{
                name: 'recordId',
                type: 'String',
                value: this.recordId
            }];
            this.flowlabel = 'Nueva Tarea';
            this.flowName = this.actionSetting;
        }

        handleStatusChangeOpp(event) {
            const status = event.detail.status;
            if(status === 'FINISHED_SCREEN' || status === "FINISHED") {
                this.isModalOpen = false;
                this.refreshCmp();
            }
            
        }

        closeModal(){
            this.isModalOpen = false;
        }
}