import { LightningElement, api, track, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
    
//Methods
import getRecInfo from '@salesforce/apex/CIBE_Oportunidades_Vinculadas_Controller.getRecordInfo';
import retrieveListWithOutTask from '@salesforce/apex/CIBE_Oportunidades_Vinculadas_Controller.retrieveListWithOutTask';
import roleCib             from '@salesforce/apex/CIBE_Oportunidades_Vinculadas_Controller.roleCIB2';



//flow
import getActions   from '@salesforce/apex/CIBE_Oportunidades_Vinculadas_Controller.getActions';

//Labels
import oppVinculadas from '@salesforce/label/c.CIBE_OportunidadesVinculadas';
import oppDisponibles from '@salesforce/label/c.CIBE_OportunidadesDisponiblesDelCliente';
import newOpportunity from '@salesforce/label/c.CIBE_New_Opportunity';
import error from '@salesforce/label/c.CIBE_Error';
import errorActualizandoEvento from '@salesforce/label/c.CIBE_ErrorActualizandoEvento';
import nuevaOportunidad from '@salesforce/label/c.CIBE_New_Opportunity';





export default class Cibe_ListOpportunities extends LightningElement {

    labels = {
        oppVinculadas,
        oppDisponibles,
        newOpportunity,
        error,
        errorActualizandoEvento,
        nuevaOportunidad
    };
        
        @api recid;
        @api recordId;
        @api editable;
        @api sobjname = 'Event';
        @track rId;
        @track recInfo;
        @track listOpp;
        @track showSpinner = false;

        @track roleCib = false;
        @api actionSetting = 'CIBE_AltaDeEvento';
        @track flowlabel;
        @track flowName;
        @track flowOutput;
        @track redirectId;
        inputVariables;
        @track isModalOpen = false;

    
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
                    if(result != null) {
                        this.recInfo = result;
                        
                        console.log('recInfo: ');
                        console.log(this.recInfo);

                        this.getDataOpp(rid);
                    }
                })
                .catch(error => {
                    this.showToast('Error', error.body.message, 'error');
                }).finally(() => {
                    this.disableSpinner();
                });
        }

        getDataOpp(rid) {
            retrieveListWithOutTask({listTareaOpp : this.recInfo, recordId : rid, objectName : this.sobjname})
                .then(result => {
                    if(result != null) {
                        this.listOpp = result;
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
            this.listOpp = [];
            if(this.recid!=null){
                this.getRecordInfo(this.recid);
            }else{
                this.getRecordInfo(this.recordId);
            }
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


        getActions() {
            getActions({ actionSetting: this.actionSetting })
            .then(data=>{
                this.disableSpinner();
                this.flowlabel = data[0].label;
                this.flowName = data[0].name;
                this.flowOutput = data[0].output;
                this.redirectId = null;
            }) .catch(error => {
                this.showToast(this.labels.error, this.labels.errorActualizandoEvento, 'error', 'pester');
                this.disableSpinner();
            });
        }


        handleComboBoxChange(){
            this.isModalOpen = true;
            if(this.actionSetting != 'CIBE_New_Opportunity_CIB' && this.roleCib){
                this.actionSetting = 'CIBE_New_Opportunity_CIB';
            }
            this.inputVariables = [{
                name: 'recordId',
                type: 'String',
                value: this.recordId
            }];
            this.flowlabel = this.labels.newOpportunity;
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