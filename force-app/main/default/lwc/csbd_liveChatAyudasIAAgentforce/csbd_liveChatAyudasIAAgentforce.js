/*eslint no-console: ["error", { allow: ["warn", "error"] }] */
import { LightningElement, track, api, wire} from 'lwc';
import { getRecord, getFieldValue } from "lightning/uiRecordApi";
import { NavigationMixin } from 'lightning/navigation';
import { log } from 'lightning/logger';

import ID_OPORTUNIDAD from '@salesforce/schema/LiveChatTranscript.CSBD_Oportunidad_Id__c';
import ID_PRODUCTO from '@salesforce/schema/LiveChatTranscript.CSBD_Oportunidad_Id__r.CSBD_Producto__c';

import mensajeIAResponsable from '@salesforce/label/c.CSBD_MensajeIAResponsable';

import obtenerMetadataPrompts from '@salesforce/apex/CSBD_ChatGPT_Controller.obtenerMetadataPrompts';
import obtenerProductosComparables from '@salesforce/apex/CSBD_ChatGPT_Controller.obtenerProductosComparables';

export default class Csbd_liveChatAyudasIA extends NavigationMixin(LightningElement) {
    @api recordId;
    @api oppId;
    @api planOpo;
    @api planAmpli;
    @api planProd;
    @api planArg;
    @api planProdFlex = 'CSBD_Resumen_Producto_Flex';
    @api planArgFlex = 'CSBD_Condiciones_Y_Promos_Flex';
    primerAcceso = true;
    
    productosComparables = [];
    hayProductosComparables = false;

	@track toggleIconResumenIA = "slds-section slds-is-open";
	@track bExpanseResumenIA = true;
    
    //wire para obtener el prompt a utilizar
    @wire(obtenerMetadataPrompts, { producto: '$producto' })
    wiredPrompts({ error, data }) {
        if (data != null) {
            this.planArg = data[0].CSBD_PromptArgumentarioAUtilizar__c;
            this.planOpo = data[0].CSBD_PromptOportunidadAUtilizar__c;
            this.planAmpli = data[0].CSBD_PromptAmpliadaAUtilizar__c;
            this.planProd = data[0].CSBD_PromptProductoAUtilizar__c;

            //console.log('this.planArg ' + this.planArg);
        } else if (error) {
            console.error('Error fetching prompts: ' + JSON.stringify(error));
        }
    }

    //wire para obtener los productos a mostrar en subpestañas
    @wire(obtenerProductosComparables, { producto: '$producto' })
    wiredProductos({ error, data }) {
        if (data != null) {
            // console.log('wire obtenerProductosComparables');
            this.productosComparables = [];
            this.hayProductosComparables = data.length > 0;
            for (let i = 0; i < data.length; i++) {
                this.productosComparables.push({id: i, name: data[i].CSBD_Nombre_producto_2__c});
            }
        } else if (error) {
            console.error('Error fetching other products: ' + JSON.stringify(error));
        }
    }

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

    @wire (getRecord, { recordId: '$recordId', fields: [ ID_OPORTUNIDAD, ID_PRODUCTO] }) chat;

    get idOportunidad() {
        return getFieldValue(this.chat.data, ID_OPORTUNIDAD);
    }

    //obtener el producto de la oportunidad
    get producto() {
        return getFieldValue(this.chat.data, ID_PRODUCTO);
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