import { LightningElement, api , wire, track} from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from "lightning/navigation";
import { refreshApex } from '@salesforce/apex';


import getEvent from '@salesforce/apex/CIBE_PathEventCIBController.getEvent';
import updateEvent from '@salesforce/apex/CIBE_PathEventCIBController.updateEvent';


//Labels

import planificada from '@salesforce/label/c.CIBE_Planificada';
import cancelada from '@salesforce/label/c.CIBE_Cancelada';
import realizada from '@salesforce/label/c.CIBE_Realizada';
import vencida from '@salesforce/label/c.CIBE_Vencida';
import guardar from '@salesforce/label/c.CIBE_Guardar';
import cargando from '@salesforce/label/c.CIBE_Cargando';
import citaActualizada from '@salesforce/label/c.CIBE_EventoActualizadoCorrectamente';
import citaActualizadaCorrectamente from '@salesforce/label/c.CIBE_EventoActualizadoCorrectamente';
import id from '@salesforce/user/Id';



export default class Cibe_PathEventCIB extends NavigationMixin(LightningElement) {

    @api recordId;
    @api objectApiName;

    @track event;
    @track stageName;
    @track recordTypeId;
    @track productId;
    @track isCibe;
    @track rememberDate;
    @track prioritizingClient;
    @track isImpComisiones = false;
    @track isImpBalance = false; 

    @track correctRecordType;

    @track stage;
    @track loading = false;
    hasRendered = false;
    disabledButton = false;
    isModalOpen = false;
    @track closeDate;

    labels = {
        planificada,
        cancelada,
        realizada,
        vencida,
        guardar,
        cargando,
        citaActualizada,
        citaActualizadaCorrectamente
    }

    @track _wiredData;
    @wire(getEvent, {recordId: '$recordId'})
    getEvent(wireResult){
        this._wiredData = wireResult;
        const { data, error } = wireResult;
        if(data){

            this.event = data;
            this.stageName = data[0].CSBD_Evento_Estado__c;
            this.closeDate = data[0].CloseDate;

           
            var step = this.template.querySelector('li[data-stage="' + this.stageName + '"]');
            if(step) {
                var oldStep = this.template.querySelector('li[data-current="true"]');
                step.classList.add('slds-is-active');
                step.setAttribute('data-active', 'true');
                step.classList.add('slds-is-current');
                step.setAttribute('data-current', 'true');
                step.classList.remove('slds-is-incomplete');
                if(oldStep && oldStep != step) {
                    oldStep.classList.remove('slds-is-active');
                    oldStep.setAttribute('data-active', 'false');
                    oldStep.classList.remove('slds-is-current');
                    oldStep.setAttribute('data-current', 'false');
                    oldStep.classList.add('slds-is-incomplete');
                    console.log('### oldStep ', oldStep);
                    console.log('### oldStep == step ', oldStep == step);
                    
                }
            }
            this.stage = data[0].CSBD_Evento_Estado__c;
            this.hasRendered = true;

            if(this.stage == 'Vencida'){
                this.disabledButton = true;
            }else if(this.stage == 'Cancelada'){
                this.disabledButton = true;
            }else if(this.stage == 'Realizada'){
                this.disabledButton = true;
            }else if(this.stage == 'Planificada'){
                this.disabledButton = false;
            }
    

        }else if(error) {
            var result = JSON.parse(JSON.stringify(error));
            console.log('Error loading: ', result);
        }
    }

    click (event) {
        event.preventDefault();
        var stageName = event.target.getAttribute('data-stage');
        var step = this.template.querySelector('li[data-stage="' + stageName + '"]');
        var oldStep = this.template.querySelector('li[data-active="true"]');
        if(step && oldStep) {
            oldStep.classList.remove('slds-is-active');
            oldStep.setAttribute('data-active', 'false');
            step.classList.add('slds-is-active');
            step.setAttribute('data-active', 'true');
            this.stage = stageName;
        }  

        if(this.stageName == 'Vencida' && (this.stage == 'Cancelada' || this.stage == 'Realizada' || this.stage == 'Planificada')){
            this.disabledButton = false;
        }else if(this.stageName == 'Cancelada' && this.stage == 'Realizada'){
            this.disabledButton = false;
        }else if(this.stageName == 'Realizada' && this.stage == 'Cancelada'){
            this.disabledButton = false;
        }else if(this.stage == 'Vencida' || this.stage == 'Planificada'){
            this.disabledButton = true;
        }else if(this.stageName == 'Planificada' && (this.stage == 'Cancelada' || this.stage == 'Realizada')){
            this.disabledButton = false;
        }

        console.log(this.stage);
    }

    handleClick(event){
        this.loading = true;
        updateEvent({recordId:this.recordId, stage: this.stage})
        .then((result => {
            console.log(result);
            if(!result){
                this.handleSuccess();
            }else{
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error',
                        message: result,
                        variant: 'error'
                    })
                );
                this.loading = false;
                var oldStep = this.template.querySelector('li[data-active="true"]');
                var step = this.template.querySelector('li[data-active="false"]');
                if(step && oldStep) {
                    oldStep.classList.remove('slds-is-active');
                    oldStep.setAttribute('data-active', 'false');
                    step.classList.add('slds-is-active');
                    step.setAttribute('data-active', 'true');
                }  
            }
            
        }))
        .cacth((error) =>{
            console.log(error);
        })
    }

    handleSubmit() {
        this.loading = true;
    }

    handleSuccess() {
        refreshApex(this._wiredData)
            .finally(() => {
                this.loading = false;
            });
        this.dispatchEvent(
            new ShowToastEvent({
                title: this.labels.citaActualizada,
                message: this.labels.citaActualizadaCorrectamente,
                variant: 'success'
            })
        );
    }

    handleError(event) {
        this.loading = false;
        this.dispatchEvent(
            new ShowToastEvent({
                title: event.detail.message,
                message: event.detail.detail,
                variant: 'error'
            })
        );
    }
}