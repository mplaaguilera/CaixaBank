/*eslint no-console: ["error", { allow: ["warn", "error"] }] */
import { LightningElement, track, api, wire} from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { getRecord, getFieldValue } from "lightning/uiRecordApi";

import mensajeIAResponsable from '@salesforce/label/c.CSBD_MensajeIAResponsable';

import IDPRODUCTO from "@salesforce/schema/Opportunity.CSBD_Producto__c";

import obtenerMetadataPrompts from '@salesforce/apex/CSBD_ChatGPT_Controller.obtenerMetadataPrompts';

//habilitar el codigo para mixin navigation
export default class Csbd_resumenOppAgentforce extends NavigationMixin(LightningElement) {

    @api recordId;
    @api planOpo;
    @api planAmpli;

    @track toggleIconResumenIA = "slds-section slds-is-open";
    @track bExpanseResumenIA = true;

    //nombre del producto
    @wire(getRecord, { recordId: '$recordId', fields: [ IDPRODUCTO ] }) oportunidad;

    //wire para obtener el prompt a utilizar
    @wire(obtenerMetadataPrompts, { producto: '$producto' })
    wiredPrompts({ error, data }) {
        if (data != null) {
            this.planOpo = data[0].CSBD_PromptOportunidadAUtilizar__c;
            this.planAmpli = data[0].CSBD_PromptAmpliadaAUtilizar__c;

            //console.log('this.planArg ' + this.planArg);
        } else if (error) {
            console.error('Error fetching prompts: ' + JSON.stringify(error));
        }
    }

    //obtener el producto de la oportunidad
    get producto() {
        return getFieldValue(this.oportunidad.data, IDPRODUCTO);
    }

    label = {
        mensajeIAResponsable
    };

    handleExpandableResumenIA() {
        if(this.bExpanseResumenIA){
            this.bExpanseResumenIA = false;
            this.toggleIconResumenIA = "slds-section"; 
        } else {
            this.bExpanseResumenIA = true;
            this.toggleIconResumenIA = "slds-section slds-is-open";
        }
    }

}