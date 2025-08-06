/*eslint no-console: ["error", { allow: ["warn", "error"] }] */
import { LightningElement, api, wire, track } from 'lwc';
import { CurrentPageReference } from 'lightning/navigation';
//import { NavigationMixin } from 'lightning/navigation';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import IDOPP from '@salesforce/schema/Opportunity.Id';
import PRODUCTOOPP from '@salesforce/schema/Opportunity.CSBD_Producto__c';

import obtenerMetadataPrompts from '@salesforce/apex/CSBD_ChatGPT_Controller.obtenerMetadataPrompts';
import obtenerProductoOportunidad from '@salesforce/apex/CSBD_ChatGPT_Controller.obtenerProductoOportunidad';

import mensajeIAResponsable from '@salesforce/label/c.CSBD_MensajeIAResponsable';

const METAFIELDS = [
    'CSBD_AdministracionPromptsProductos__mdt.CSBD_EnviarAIA__c',
    'CSBD_AdministracionPromptsProductos__mdt.CSBD_PromptArgumentarioAUtilizar__c',
    'CSBD_AdministracionPromptsProductos__mdt.CSBD_PromptOportunidadAUtilizar__c',
    'CSBD_AdministracionPromptsProductos__mdt.CSBD_PromptProductoAUtilizar__c',
    'CSBD_AdministracionPromptsProductos__mdt.CSBD_PromptAmpliadaAUtilizar__c'
];

export default class Csbd_gptAmpliado extends LightningElement {
    @api recordId;
    @api planOpo;
    @api planAmpli;
    @api planProd;
    @api planArg;
    @track producto;

    label = {
        mensajeIAResponsable
    };

    //wire para obtener el prompt a utilizar
    @wire(obtenerMetadataPrompts, { producto: '$producto' })
    wiredPrompts({ error, data }) {
        if (data) {
            this.planArg = data[0].CSBD_PromptArgumentarioAUtilizar__c;
            this.planOpo = data[0].CSBD_PromptOportunidadAUtilizar__c;
            this.planAmpli = data[0].CSBD_PromptAmpliadaAUtilizar__c;
            this.planProd = data[0].CSBD_PromptProductoAUtilizar__c;
        } else if (error) {
            console.error('Error fetching prompts: ' + JSON.stringify(error));
        }
    }

    connectedCallback() {
        // Obtener el recordId desde el estado de la navegación
        const currentPageReference = this.pageReference;
        if (currentPageReference && currentPageReference.state) {
            this.recordId = currentPageReference.state.c__recordId;
        };

        obtenerProductoOportunidad({oppId : this.recordId })
            .then(result => {
                this.producto = result;
            })
            .catch(error => {
                console.error('Error fetching opportunity: ' + JSON.stringify(error));
            });
    }

    @wire(CurrentPageReference)
    pageReference;

}