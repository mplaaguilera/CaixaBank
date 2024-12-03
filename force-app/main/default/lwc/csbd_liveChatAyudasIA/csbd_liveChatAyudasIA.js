import { LightningElement, api, wire } from 'lwc';
import { getRecord, getFieldValue } from "lightning/uiRecordApi";
import { NavigationMixin } from 'lightning/navigation';
import { log } from 'lightning/logger';

import ID_OPORTUNIDAD from '@salesforce/schema/LiveChatTranscript.CSBD_Oportunidad_Id__c';

import mensajeIAResponsable from '@salesforce/label/c.CSBD_MensajeIAResponsable';

export default class Csbd_liveChatAyudasIA extends NavigationMixin(LightningElement) {
    @api recordId;
    @api oppId;
    @api planOpo;
    @api planAmpli;
    @api planProd;
    @api planArg;
    primerAcceso = true;

    //navegar a la vista ampliada
    navigateToParentComponent() {

        let msg = {
            identifier: "GPT ChatTranscript Tabs",
            message: "Click in 'Vista Completa' button"
        }
        log(msg);
        this[NavigationMixin.Navigate]({
            type: 'standard__component',
            attributes: {
                componentName: 'c__csbd_gptAmpliado'
            },
            state: {
                c__recordId: this.idOportunidad
            }
        });
    }

    label = {
        mensajeIAResponsable
    };

    @wire (getRecord, { recordId: '$recordId', fields: [ ID_OPORTUNIDAD] }) chat;

    get idOportunidad() {
        return getFieldValue(this.chat.data, ID_OPORTUNIDAD);
    }

    //capturamos el click a la tab para cazar el evento y ponerlo en el lightning logger
    handleTabClick(event) {
        //evitar contar el acceso de carga de la página
        if(!this.primerAcceso){
            this.primerAcceso = false;
            let msg = {
                identifier: "GPT ChatTranscript Tabs",
                message: "Click in " + event.target.value + " tab"
            }
            log(msg);
        } else {
            this.primerAcceso = false;
        }
    }

}