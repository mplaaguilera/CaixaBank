/*eslint no-console: ["error", { allow: ["warn", "error"] }] */
import { LightningElement, api, track, wire } from 'lwc';
import resolverPrompt from '@salesforce/apex/CSBD_ChatGPT_Controller.resolverPrompt';
import RESUMEN_PRODUCTO from '@salesforce/schema/Opportunity.CSBD_GptResumenProducto__c';
import ID_FIELD from "@salesforce/schema/Opportunity.Id";
import IDPRODUCTO from "@salesforce/schema/Opportunity.CSBD_Producto__c";
import { getRecord, getFieldValue, updateRecord } from "lightning/uiRecordApi";
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import REFRESCOSPRODUCTO from '@salesforce/schema/Opportunity.CSBD_GPTRefrescosProducto__c';

export default class Csbd_resumenProducto extends LightningElement {
    @api recordId;
    //@api planProd;
    @track _planProd;
    @api
    get planProd() {
        return this._planProd;
    }

    set planProd(value) {
        this._planProd = value;
        //this.handlePlanArgChange();
        if(this.primerRender && typeof this.chat.data !== "undefined"
            && this.IdProducto !== null && this.resumenProducto === null){
                // Refresco rendered
            this.primerRender = false;
            this.handleRefrescarProd();
        }
    }
    @track isLoadingProd = false;
    @track bloquearTexto = false;
    @track idProdcutoVar;
    primerRender = true;
    
    @track muestraCopiaProd = false;
    @track copiaResProd = null;

    @wire(getRecord, { recordId: '$recordId', fields: [ RESUMEN_PRODUCTO, IDPRODUCTO, REFRESCOSPRODUCTO ] }) chat;

    connectedCallback(){
        this.idProdcutoVar = this.IdProducto;
        if(typeof this.chat.data !== "undefined" && this.primerRender && this.IdProducto !== null 
            && this.resumenProducto === null && typeof this.planProd !== "undefined"){
            //this.idProdcutoVar = this.IdProducto;
            this.primerRender = false;
            this.handleRefrescarProd();
           /*  if(this.IdProducto !== null && this.resumenProducto === null && typeof this.planProd !== "undefined"){
                this.handleRefrescarProd();
            } */
        }
    }
    
    get resumenProducto() {
        return getFieldValue(this.chat.data, RESUMEN_PRODUCTO);
    }

    get IdProducto() {
        return getFieldValue(this.chat.data, IDPRODUCTO);
    }

    get refrescosProducto() {
        return getFieldValue(this.chat.data, REFRESCOSPRODUCTO);
    }

    renderedCallback() {
        if(typeof this.chat.data !== "undefined" && this.primerRender && this.IdProducto !== null 
            && this.resumenProducto === null && typeof this.planProd !== "undefined"){
            this.idProdcutoVar = this.IdProducto;
            this.primerRender = false;
            this.handleRefrescarProd();
           /*  if(this.IdProducto !== null && this.resumenProducto === null && typeof this.planProd !== "undefined"){
                this.handleRefrescarProd();
            } */
        }
        if(typeof this.chat.data !== "undefined" && typeof this.idProdcutoVar !== "undefined" && 
            this.IdProducto !== null && this.idProdcutoVar !== this.IdProducto){
            this.handleRefrescarProd();
            this.idProdcutoVar = this.IdProducto;
            
        }
        
        if(this.muestraCopiaProd && this.resumenProducto !== undefined && this.resumenProducto !== null){
            this.muestraCopiaProd = false;
        }
    }
    
    handleRefrescarProd() {
        this.isLoadingProd = true;
        resolverPrompt({oppId: this.recordId, apiPrompt: this.planProd}) //'CSBD_ResumenProducto'
            .then(response => {
                response = this.limpiarRespuesta(response);
                const fields = {};
                fields[RESUMEN_PRODUCTO.fieldApiName] = response;
                fields[ID_FIELD.fieldApiName] = this.recordId;
                fields[REFRESCOSPRODUCTO.fieldApiName] = this.refrescosProducto === null ? 1 : this.refrescosProducto + 1;
                const recordInput = {fields};
                updateRecord(recordInput);
                //guardar el valor generado para mostrarlo mientras se hace el update
                this.copiaResProd = response;
                this.muestraCopiaProd = true;
                this.notifyUser('Éxito', 'Refresco del producto realizado', 'success');
                this.isLoadingProd = false;
            })
            .catch(error => {
                console.error('Error refrescando el resumen del producto', error);
                this.notifyUser('Error', 'Error refrescando el resumen del producto', 'error');
                this.isLoadingProd = false;
            });
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

}