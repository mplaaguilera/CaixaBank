import {LightningElement, api, track, wire} from 'lwc';
import { encodeDefaultFieldValues } from "lightning/pageReferenceUtils";
import {NavigationMixin} from 'lightning/navigation';
//import { publish, MessageContext } from "lightning/messageService";
import {
    subscribe,
    unsubscribe,
    APPLICATION_SCOPE,
    MessageContext,
  } from "lightning/messageService";
import derivarInteraccionChannel from "@salesforce/messageChannel/CC_DerivarInteraccionChannel__c";

export default class Cc_EmailColaboradorAction extends NavigationMixin(LightningElement) {
	@wire(MessageContext)
	messageContext;

    subscription = null;

    @api recordId;
    @api listPara = [];
    @api listCC = [];
    @api plantillaName;
    @api segundaOficinaName;
    @api grupoColaborador;
    @api procedencia;


    connectedCallback(){
        this.subscribeToMessageChannel();
    }

 
    disconnectedCallback() {
        unsubscribe(this.messageContext, derivarInteraccionChannel);
    }

    subscribeToMessageChannel() {
        if (!this.subscription) {
            this.subscription = subscribe(
                this.messageContext,
                derivarInteraccionChannel,
                (message) => this.handleMessage(message),   
                { scope: APPLICATION_SCOPE },
            );
        }
    }

    handleMessage(message) {
        let datosAdicionales = message.datosAdicionales; 
        let origen = message.origen;
        let destino = message.destino;
        let recordId = message.recordId;

        if(recordId !== this.recordId) {
			//No se ejecuta porque no es el case que se esta mostrando en el modal		
			return;
		}
        if(destino == "enviarCorreoColaboradorAction" && origen == "caseOptionButtons") {
            this.abrirEmailColaboradorAction();
        }
        if(destino == "socialPublisherAction" && origen == "caseOptionButtons") {
            let solicitudInformacion = datosAdicionales === 'true' ? true : false;
            this.abrirSocialPublisherAction(solicitudInformacion);
        }
        if(destino == "trasladarIncidenciaAction" && origen == "caseOptionButtons") {
            this.abrirTrasladarIncidenciaAction();
        }
        if(destino == "autenticacionAction" && origen == "caseOptionButtons") {
            this.abrirAutenticacionAction();
        }
        if(destino == "derivarAction" && origen == "caseOptionButtons") {
            this.abrirDerivarAction();
        }
        if(destino == "gdprAction" && origen == "caseOptionButtons") {
            this.abrirGDPRAction();
        }
    }
	
   
    abrirEmailColaboradorAction(){
        let apiName = 'Case.Email_Colaborador';
        let defaultFieldValues = {       
            CC_Plantilla__c: this.plantillaName,
            CC_Segunda_Oficina__c: this.segundaOficinaName,
            CC_Grupo_Colab__c: this.grupoColaborador, 
            CC_Procedencia__c: this.procedencia
        };

        // Crear copias locales de los arrays
        if(!this.listPara || this.listPara.length == 0){
            this.listPara = []; 
        }
        if(!this.listCC || this.listCC.length == 0){
            this.listCC = [];
        }
        // Agregar las direcciones de prueba si es necesario
        const paraAddresses = [...this.listPara];
        const ccAddresses = [...this.listCC];

        // Agregar las direcciones de prueba si es necesario
        if (paraAddresses.length > 0) {
            defaultFieldValues.ToAddress = paraAddresses.join(';');
        }else if(paraAddresses.length == 0){
            defaultFieldValues.ToAddress ='';
        }

        if (ccAddresses.length > 0) {
            defaultFieldValues.CcAddress = ccAddresses.join(';');
        }

		let pageReference = {
			"type": "standard__quickAction",
			"attributes": {
				"apiName": apiName
			},
			"state": {
				recordId: this.recordId,
				defaultFieldValues: encodeDefaultFieldValues(defaultFieldValues)
			}		
		};
	
        this[NavigationMixin.Navigate](pageReference, true);
    }

    abrirSocialPublisherAction(solicitudInformacion){
        let apiName = 'Case.CC_Indicencia';
        let defaultFieldValues = {       
          //  CC_Solicitud_Informacion__c: solicitudInformacion
        };

		let pageReference = {			
            "type": "standard__quickAction",
            "attributes": {
                "apiName": apiName
            },
            "state": {
                "objectApiName": 'Case',
                "context": "RECORD_DETAIL",
                "recordId": this.recordId,
                "backgroundContext": "/lightning/r/Case/" + this.recordId + "/view"
            }
         }
        	
        this[NavigationMixin.Navigate](pageReference, true);
    }

    abrirTrasladarIncidenciaAction(){
        let apiName = 'Case.CC_Indicencia';
        let defaultFieldValues = {       
        };

		let pageReference = {			
            "type": "standard__quickAction",
            "attributes": {
                "apiName": apiName
            },
            "state": {
                "objectApiName": 'Case',
                "context": "RECORD_DETAIL",
                "recordId": this.recordId,
                "backgroundContext": "/lightning/r/Case/" + this.recordId + "/view"
            }
         }
        	
        //this[NavigationMixin.Navigate](pageReference, true);
        setTimeout(() => {
            this[NavigationMixin.Navigate](pageReference, true);
        }, 300); 
    }

    abrirAutenticacionAction(){
        let apiName = 'Case.CC_OTP';
        let defaultFieldValues = {       
        };

		let pageReference = {			
            "type": "standard__quickAction",
            "attributes": {
                "apiName": apiName
            },
            "state": {
                "objectApiName": 'Case',
                "context": "RECORD_DETAIL",
                "recordId": this.recordId,
                "backgroundContext": "/lightning/r/Case/" + this.recordId + "/view"
            }
         }
        	
        //this[NavigationMixin.Navigate](pageReference, true);
        setTimeout(() => {
            this[NavigationMixin.Navigate](pageReference, true);
        }, 300); 
    }

    abrirDerivarAction(){
        let apiName = 'Case.CC_DerivarQuickAction';
        let defaultFieldValues = {       
        };

		let pageReference = {			
            "type": "standard__quickAction",
            "attributes": {
                "apiName": apiName
            },
            "state": {
                "objectApiName": 'Case',
                "context": "RECORD_DETAIL",
                "recordId": this.recordId,
                "backgroundContext": "/lightning/r/Case/" + this.recordId + "/view"
            }
         }
        	
        //this[NavigationMixin.Navigate](pageReference, true);
        setTimeout(() => {
            this[NavigationMixin.Navigate](pageReference, true);
        }, 200);
    }

    abrirGDPRAction(){
        let apiName = 'Case.CC_GDPR';
        let defaultFieldValues = {       
        };

		let pageReference = {			
            "type": "standard__quickAction",
            "attributes": {
                "apiName": apiName
            },
            "state": {
                "objectApiName": 'Case',
                "context": "RECORD_DETAIL",
                "recordId": this.recordId,
                "backgroundContext": "/lightning/r/Case/" + this.recordId + "/view"
            }
         }
        	
        //this[NavigationMixin.Navigate](pageReference, true);
        setTimeout(() => {
            this[NavigationMixin.Navigate](pageReference, true);
        }, 200);
    }
}