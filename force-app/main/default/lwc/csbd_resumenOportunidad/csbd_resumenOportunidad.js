/*eslint no-console: ["error", { allow: ["warn", "error"] }] */
import { LightningElement, track, api, wire} from 'lwc';
import { getRecord, getFieldValue, updateRecord } from "lightning/uiRecordApi";

//campos
import RESUMEN_OPORTUNIDAD from '@salesforce/schema/Opportunity.CSBD_GptResumenInicialRich__c';
import INSTRUCCIONES_GPT from '@salesforce/schema/Opportunity.CSBD_InstruccionesGPT__c';
import ID_FIELD from "@salesforce/schema/Opportunity.Id";
import REFRESCOSOPORTUNIDAD from '@salesforce/schema/Opportunity.CSBD_GPTRefrescosOportunidad__c';
import IDPRODUCTO from "@salesforce/schema/Opportunity.CSBD_Producto__c";
import ACCOUNTID from "@salesforce/schema/Opportunity.AccountId";

//apex
import resolverPrompt from '@salesforce/apex/CSBD_ChatGPT_Controller.resolverPrompt';
//import getCliPremiumData from '@salesforce/apex/CSBD_UpdateCliPremium_Controller.getCliPremiumData';
//import getGDPR from '@salesforce/apex/CSBD_GDPR_Controller.getGDPRForAI';
//import getOwnedProducts from '@salesforce/apex/CSBD_MapaProductos_Integration.getOwnedProducts';

import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class Csbd_resumenOportunidad extends LightningElement {
    @api recordId;
    //@api planOpo;
    @track _planOpo;
    //boleano para saber si se ha refrescado el api premium
    @track apiPremiumRefreshed = false;
    //booleano para saber si se ha refrescado los datos GDPR
    @track gdprRefreshed = false;
    @track productosRefreshed = false;
    //necesario para cazar el cambio de planOpo
    @api
    get planOpo() {
        return this._planOpo;
    }
    set planOpo(value) {
        //console.log('entra en planOpo');
        this._planOpo = value;
        //this.handlePlanArgChange();
        if(this.primerRender && typeof this.resumen.data !== "undefined" && this.resumenOportunidad === null){
            this.primerRender = false;
            this.handleRefrescarOpp();
        }
    }

    @api planAmpli;
    @track isLoadingOpp;
    @track muestraCopiaOpp = false;
    @track copiaResOpp = null;
    primerRender = true;
    primerProductoFlag = false;
    miProducto = '';
    miAccount = '';
    premiumLanzado = false;

    @wire (getRecord, { recordId: '$recordId', fields: [ RESUMEN_OPORTUNIDAD, INSTRUCCIONES_GPT, REFRESCOSOPORTUNIDAD, IDPRODUCTO, ACCOUNTID ] }) resumen;

    get resumenOportunidad() {
        return getFieldValue(this.resumen.data, RESUMEN_OPORTUNIDAD);
    }

    get intruccionesGPT() {
        return getFieldValue(this.resumen.data, INSTRUCCIONES_GPT);
    }

    get refrescosOportunidad() {    
        return getFieldValue(this.resumen.data, REFRESCOSOPORTUNIDAD);
    }

    get idProducto() {    
        return getFieldValue(this.resumen.data, IDPRODUCTO);
    }
    
    get accountId() {
        return getFieldValue(this.resumen.data, ACCOUNTID);
    }
   
    renderedCallback() {
        //lanzamiento api premium y GDPR
        if (
            typeof this.accountId !== "undefined" &&  this.accountId !== null && this.resumenOportunidad === null &&
            this.premiumLanzado === false
        ) {
            this.miAccount = this.accountId;
            this.getClientData();
            this.getGDPR();
            this.getProductos();
            this.premiumLanzado = true;
        }
        //detecta producto de inicio
        if(this.primerProductoFlag === false && this.resumen.data !== "undefined" && typeof this.idProducto !== "undefined" ){
            this.primerProductoFlag = true;
            this.miProducto = this.idProducto;
        }
        //detecta account de inicio
        if(this.miAccount === '' && this.resumen.data !== "undefined" && typeof this.accountId !== "undefined" ){
            this.miAccount = this.accountId;
        }
        //refresca si es el primer render y aun no se ha generado resumen, el apiPremium y el gdpr se han refrescado
        if(this.primerRender && typeof this.resumen.data !== "undefined" && this.apiPremiumRefreshed && this.gdprRefreshed
           && this.productosRefreshed && this.resumenOportunidad === null && typeof this.planOpo !== "undefined" && this.miAccount !== null){
            this.primerRender = false;
            this.handleRefrescarOpp();
        }
        //se usa para guardar el valor generado antes de hacer el update
        if(this.muestraCopiaOpp && typeof this.resumenOportunidad !== "undefined" && this.resumenOportunidad !== null){
            this.muestraCopiaOpp = false;
        }
        //detecta cambio de producto y refresca el resumen
        if(this.primerProductoFlag && typeof this.miProducto !== "undefined" && this.miProducto !== this.idProducto){
            this.miProducto = this.idProducto;
            this.handleRefrescarOpp();
        }
        //detecta cambio de account y refresca el resumen
        if(this.miAccount !== '' && this.miAccount !== this.accountId && this.miAccount !== null){
            this.miAccount = this.accountId;
            //poner flags a false para que se vuelvan a lanzar las llamadas
            this.apiPremiumRefreshed = false;
            this.gdprRefreshed = false;
            this.productosRefreshed = false;
            this.primerRender = true;
            //this.getClientData();
            //this.getGDPR();
            //this.getProductos();
        }
    }

   /*  connectedCallback() {
        //console.log('entra en connectedCallback');
        console.log('recordId2: ' + this.accountId);
        this.getClientData();
    } */

    handleRefrescarOpp() {
        this.isLoadingOpp = true;
        resolverPrompt({oppId: this.recordId, apiPrompt: this.planOpo})
            .then(response => {
                response = this.limpiarRespuesta(response);
                const fields = {};
                fields[RESUMEN_OPORTUNIDAD.fieldApiName] = response;
                fields[ID_FIELD.fieldApiName] = this.recordId;
                fields[REFRESCOSOPORTUNIDAD.fieldApiName] = this.refrescosOportunidad === null ? 1 : this.refrescosOportunidad + 1;
                const recordInput = {fields};
                updateRecord(recordInput);
                //guardar el valor generado para mostrarlo mientras se hace el update
                this.copiaResOpp = response;
                this.muestraCopiaOpp = true;
                this.notifyUser('Éxito', 'Refresco del resumen realizado', 'success');
                this.isLoadingOpp = false;
            })
            .catch(error => {
                console.error('Error refrescando el resumen de la oportunidad', error);
                this.notifyUser('Error', 'Error refrescando el resumen de la oportunidad', 'error');
                this.isLoadingOpp = false;
            });
    }

    handleSubmitOpp(event){
        event.preventDefault();       // stop the form from submitting
        this.isLoadingOpp = true;
        const fields = event.detail.fields;
        //si ha cambiado las instrucciones, hay que hacer un update
        if(fields.CSBD_InstruccionesGPT__c !== this.intruccionesGPT){
            // console.log("actualizar instrucciones");
            this.template.querySelector('lightning-record-edit-form').submit(fields);
        }
        //si las instrucciones estan vacias hacer un refresh del resumen
        if(fields.CSBD_InstruccionesGPT__c === null || fields.CSBD_InstruccionesGPT__c === ""){
            // console.log("refresh");
            this.handleRefrescarOpp();
        } else {
            // console.log("ampliacion");
            //si no estan vacias hay que hacer la ampliacion del resumen
            resolverPrompt({oppId: this.recordId, apiPrompt: this.planAmpli})
            .then(response => {
                response = this.limpiarRespuesta(response);
                const fields = {};
                fields[RESUMEN_OPORTUNIDAD.fieldApiName] = response;
                fields[ID_FIELD.fieldApiName] = this.recordId;

                fields[REFRESCOSOPORTUNIDAD.fieldApiName] = this.refrescosOportunidad === null ? 1 : this.refrescosOportunidad + 1;
                const recordInput = {fields};
                updateRecord(recordInput);
                this.notifyUser('Éxito', 'Ampliacion resumen realizada', 'success');
                this.isLoadingOpp = false;
            })
            .catch(error => {
                console.error('Error ampliando el resumen', error);
                this.notifyUser('Error', 'Error ampliando el resumen', 'error');
                this.isLoadingOpp = false;
            });
        }
    }

    notifyUser(title, message, variant) {
		if (this.notifyViaAlerts) {
			// Notify via alert
			// eslint-disable-next-line no-alert
			alert(`${title}\n${message}`);
		} else {
			// Notify via toast
			const toastEvent = new ShowToastEvent({ title, message, variant });
			this.dispatchEvent(toastEvent);
		}
	}

    //en ocasiones open IA encabeza los mensajes con tags html de esta manera
    limpiarRespuesta(response) {
        // quitar comas invertidas y html
        return response.replace(/```html|```/g, '').trim();
    }

    /*
    //hacer la conexion mediante API Premium para tener los datos actualizados del cliente antes de hacer el resumen
    getClientData() {
        //if(this.resumenOportunidad === null){
            this.isLoadingOpp = true;
        //}
		getCliPremiumData({recordId: this.accountId})
			.then(result => {
				if (result !== "OK") {
				console.error('Error API Premium: ', result);
				//this.dispatchEvent(new RefreshEvent());
				}
                this.apiPremiumRefreshed = true;
                //en caso de tener todos los datos y no tener resumen de la oportunidad, se lanza el LLM y que hayan acabado los refrescos de datos del cliente
                if(this.gdprRefreshed){
                    this.isLoadingOpp = false;
                    if(this.primerRender && this.productosRefreshed && typeof this.resumen.data !== "undefined"){
                    this.primerRender = false;     
                    this.handleRefrescarOpp();
                    }
                }    
			})
			.catch(error => {
				console.error('Display Premium ShowToastEvent error (catch): ', error);
                this.apiPremiumRefreshed = true;

                if(this.gdprRefreshed){
                    this.isLoadingOpp = false;
                    //en caso de tener todos los datos y no tener resumen de la oportunidad, se lanza el LLM y que hayan acabado los refrescos de datos del cliente
                    if(this.primerRender && this.productosRefreshed && typeof this.resumen.data !== "undefined"){
                        this.primerRender = false;
                        this.handleRefrescarOpp();
                    }
                }
                
			});
           
	}

    //funcion para obtener el GDPR
    getGDPR() {
        getGDPR({accountId: this.accountId})
            .then(result => {
                this.gdprRefreshed = true;
                //return result;
                if(this.apiPremiumRefreshed){
                    this.isLoadingOpp = false;
                    //en caso de tener todos los datos y no tener resumen de la oportunidad, se lanza el LLM y que hayan acabado los refrescos de datos del cliente
                    if(this.primerRender && this.productosRefreshed && typeof this.resumen.data !== "undefined"){
                        this.primerRender = false;
                        this.handleRefrescarOpp();
                    }
                }
            })
            .catch(error => {
                console.error('Error obteniendo GDPR: ', error);
                this.gdprRefreshed = true;

               if(this.apiPremiumRefreshed){
                    this.isLoadingOpp = false;
                    //en caso de tener todos los datos y no tener resumen de la oportunidad, se lanza el LLM y que hayan acabado los refrescos de datos del cliente
                    if(this.primerRender && this.productosRefreshed && typeof this.resumen.data !== "undefined"){
                        this.primerRender = false;
                        this.handleRefrescarOpp();
                    }
                }
            });
    }

   getProductos() {
    getOwnedProducts({accountId: this.accountId})
        .then(result => {
            this.productosRefreshed = true;
            if(this.apiPremiumRefreshed && this.gdprRefreshed && this.primerRender && typeof this.resumen.data !== "undefined"){
                this.primerRender = false;
                this.handleRefrescarOpp();
            }
        })
        .catch(error => {
            console.error('Error refrescando productos activos: ', error.message);
            this.productosRefreshed = true;
            if(this.apiPremiumRefreshed && this.gdprRefreshed && this.primerRender && typeof this.resumen.data !== "undefined"){
                this.primerRender = false;
                this.handleRefrescarOpp();
            }
        });
    }*/
}