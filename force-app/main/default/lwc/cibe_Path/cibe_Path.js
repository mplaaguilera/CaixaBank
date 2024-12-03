import { LightningElement, api , wire, track} from 'lwc';
import { getRecord } from "lightning/uiRecordApi";
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from "lightning/navigation";

import OPPORTUNITY_STAGENAME_FIELD from '@salesforce/schema/Opportunity.StageName';
import OPPORTUNITY_RECORDTYPE_FIELD from '@salesforce/schema/Opportunity.RecordTypeId';
import OPPORTUNITY_PRODUCT_FIELD  from '@salesforce/schema/Opportunity.AV_PF__c';
import getOpportunityFields     from '@salesforce/apex/CIBE_NewOpportunity_Controller_CIB.getOpportunityFields';


import getRecInfo from '@salesforce/apex/CIBE_Path_Opportunity_Controller.getRecordTypeVerification';
import oppEmp             from '@salesforce/apex/CIBE_Path_Opportunity_Controller.oppEmp';


//Labels

import potencial from '@salesforce/label/c.CIBE_Potencial';
import enCurso from '@salesforce/label/c.CIBE_EnCurso';
import pendienteFirma from '@salesforce/label/c.CIBE_PendienteFirma';
import cerradaPositiva from '@salesforce/label/c.CIBE_CerradaPositiva';
import cerradaNegativa from '@salesforce/label/c.CIBE_CerradaNegativa';
import vencida from '@salesforce/label/c.CIBE_Vencida';
import guardar from '@salesforce/label/c.CIBE_Guardar';
import cargando from '@salesforce/label/c.CIBE_Cargando';
import oportunidadActualizada from '@salesforce/label/c.CIBE_OportunidadActualizada';
import oportunidadActualizadaCorrectamente from '@salesforce/label/c.CIBE_OportunidadActualizadaCorrectamente';
import fechaProxGestionLabel from '@salesforce/label/c.CIBE_FechaProxGestion';
import incluirClienteLabel from '@salesforce/label/c.CIBE_IncluirCliPriorizados';
import cambioNoPermitido from '@salesforce/label/c.CIBE_CambioEstadoNoPermitido';
import errorOportunidad from '@salesforce/label/c.CIBE_ProblemUpdatingOportunity';


export default class cibe_Path extends NavigationMixin(LightningElement) {

    @api recordId;
    @api objectApiName;

    @track opportunity;
    @track stageName;
    @track recordTypeId;
    @track productId;
    @track isCibe;
    @track rememberDate;
    @track prioritizingClient;
    @track isImpComisiones = false;
    @track isImpBalance = false; 

    @track correctRecordType;
    @track roleEmp = false;

    @track stage;
    @track loading = false;
    hasRendered = false;
    barNoChanges = false;


    @track validacionPath = false;

    labels = {
        potencial,
        enCurso,
        pendienteFirma,
        cerradaPositiva,
        cerradaNegativa,
        vencida,
        guardar,
        cargando,
        oportunidadActualizada,
        oportunidadActualizadaCorrectamente,
        fechaProxGestionLabel,
        incluirClienteLabel,
        cambioNoPermitido,
        errorOportunidad
    }
    
    @wire(getRecord, { 
        recordId: '$recordId',
        fields: [OPPORTUNITY_STAGENAME_FIELD, OPPORTUNITY_RECORDTYPE_FIELD, OPPORTUNITY_PRODUCT_FIELD] 
        })
    getOpportunity({ error, data }) {
        if(data){
            var result = JSON.parse(JSON.stringify(data));
            this.opportunity = result;
            this.stageName = result.fields.StageName.value;
            this.recordTypeId = result.fields.RecordTypeId.value;
            this.productId = result.fields.AV_PF__c.value;
            getRecInfo({recordId : this.recordId})  
                .then(result => {
                    if(result != null) {
                        this.isCibe = result;
                    }
            });
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
            this.stage = result.fields.StageName.value;
            this.hasRendered = true;
        }else if(error) {
            var result = JSON.parse(JSON.stringify(error));
            console.log('Error loading: ', result);
        }
    };

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
        console.log(stageName);
        console.log( this.stage);
        console.log(step);
        console.log(JSON.stringify(oldStep));
    }

    get isEnCurso () {
        return this.stage == 'En curso';
    }

    get isCerradoNegativo () {
        return this.stage == 'Cerrado negativo';
    }

    get isCerradoPositivo () {
        if(this.isCibe == true){
            return this.stage == 'CIBE_Cerrado positivo';
        }else{
            return false;
        }
    }

    get noIsVencida () {
        return this.stage != 'CIBE_Vencido';
    }

    handleSubmit(event) {
        this.loading = true;
        if(this.roleEmp == true && this.stageName == 'CIBE_Vencido' && (this.stage == 'En curso' || this.stage == 'Potencial' || this.stage == 'CIBE_Pendiente_Firma')){
            event.preventDefault();
            this.validacionPath = true;
        }

        if(this.validacionPath){

            this.loading = false;
            this.dispatchEvent(
                new ShowToastEvent({
                    title: this.labels.errorOportunidad,
                    message: this.labels.cambioNoPermitido,
                    variant: 'error'
                })
            );
            this.validacionPath = false;
        }
    }

    handleSuccess() {
        this.loading = false;

      
            this.dispatchEvent(
                new ShowToastEvent({
                    title: this.labels.oportunidadActualizada,
                    message: this.labels.oportunidadActualizadaCorrectamente,
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

    handleRememberDate(event){
        this.rememberDate=event.target.value;
    }

    handlePrioritizingClient(event){
        this.prioritizingClient=event.target.value;
    }
    @wire(getOpportunityFields, {productoName:'$productId'})
    getOpportunityFields({error,data}) {
        if(data){
            data.forEach(d => {
                    if(d == 'CIBE_ImpactoDivisaComisionesCierreAnio__c') {
                        this.isImpComisiones = true;            
                    }
                    if(d == 'CIBE_ImpactoDivisaBalanceCierreAnio__c') {
                        this.isImpBalance = true;            
                    }
                });
        }else if(error) {
            console.log(error);
        }
    }

    @wire(oppEmp, { recordId : '$recordId' })
    oppEmp({ data, error }) {
        if(data){
            console.log(data);
            this.roleEmp = data;
        }else if(error){
            console.log(error);
        }
    }
}