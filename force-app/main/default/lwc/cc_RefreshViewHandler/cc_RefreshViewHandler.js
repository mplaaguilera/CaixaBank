import { LightningElement, api, wire } from 'lwc';
import { RefreshEvent } from "lightning/refresh";
import { subscribe, unsubscribe, APPLICATION_SCOPE, MessageContext, publish } from 'lightning/messageService';
import derivarInteraccionChannel from "@salesforce/messageChannel/CC_DerivarInteraccionChannel__c";
import { createMessageContext } from 'lightning/messageService';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import { refreshApex } from '@salesforce/apex';

export default class Cc_RefreshViewHandler extends LightningElement {

    @api recordId;

    messageContext = createMessageContext();

    subscription = null;

    wiredRecord;

    // Wire el registro para poder refrescarlo
    @wire(getRecord, { recordId: '$recordId', fields: ['Id'] })
    wiredRecord(result) {
        this.wiredRecord = result;
    }

    connectedCallback(){
        this.subscribeToMessageChannel();
    }

    subscribeToMessageChannel() {
        if (!this.subscription) {
            this.subscription = subscribe(
            this.messageContext,
            derivarInteraccionChannel,
            (message) => this.procesarMensajeDerivarInteraccion(message),
            { scope: APPLICATION_SCOPE },
            );
        }
    }

    unsubscribeToMessageChannel() {
		unsubscribe(this.subscription);
		this.subscription = null;
	}

    procesarMensajeDerivarInteraccion(message) {
        let datosAdicionales = message.datosAdicionales; 
        let origen = message.origen;
        let destino = message.destino;
        let recordId = message.recordId;

        if(recordId !== this.recordId) {
			//No se ejecuta porque no es el case que se esta mostrando en el modal		
			return;
		}


        if(destino == "refreshViewHandler" && origen == "mccClasificarGuardar") {
            console.log('DMV -- refreshViewHandler');
            this.refreshData();
        }
      
	}	

    // Nuevo método para refrescar los datos
    refreshData() {
        // Primero intentamos refrescar el Lightning Data Service
        if (this.wiredRecord) {
            refreshApex(this.wiredRecord)
                .then(() => {
                    // Después de refrescar el LDS, disparamos el evento de refresh
                    this.dispatchEvent(new RefreshEvent());
                })
                .catch(error => {
                    console.error('Error refreshing data:', error);
                    // Si falla el refresh del LDS, al menos intentamos el RefreshEvent
                    this.dispatchEvent(new RefreshEvent());
                });
        } else {
            // Si no hay wiredRecord, usamos el RefreshEvent como fallback
            this.dispatchEvent(new RefreshEvent());
        }
    }

}