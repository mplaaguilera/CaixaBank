/*eslint no-console: ["error", { allow: ["warn", "error"] }] */
import { LightningElement, track, api, wire} from 'lwc';
import { getRecord, getFieldValue, updateRecord } from "lightning/uiRecordApi";

//campos opportunity
import RESUMEN_ARGUMENTARIO from '@salesforce/schema/Opportunity.CSBD_CondicionesPromos__c';
import INFORMACION_ADICIONAL from '@salesforce/schema/Opportunity.CSBD_InformacionAdicional__c';
import ID_FIELD from "@salesforce/schema/Opportunity.Id";
import IDPRODUCTO from "@salesforce/schema/Opportunity.CSBD_Producto__c";
import REFRESCOSARGUMENTARIO from '@salesforce/schema/Opportunity.CSBD_GPTRefrescosArgumentario__c';

//apex
import resolverPrompt from '@salesforce/apex/CSBD_ChatGPT_Controller.resolverPrompt';

import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class Csbd_resumenArgumentario extends LightningElement {
    @api recordId;
    //@api planArg;
    @track isLoadingArgu;
    primerRender = true;
    @track idProdcutoVar;
    @track _planArg;
    @api
    get planArg() {
        return this._planArg;
    }

    set planArg(value) {
        this._planArg = value;
        //this.handlePlanArgChange();
        if(this.primerRender && typeof this.resumen.data !== "undefined" && this.resumenArgumentario === null){
            this.primerRender = false;
            this.handleRefrescarArgu();
        }
    }
    
    @track muestraCopiaArgu = false;
    @track copiaResArgu = null;

    @wire (getRecord, { recordId: '$recordId', fields: [ RESUMEN_ARGUMENTARIO, INFORMACION_ADICIONAL, IDPRODUCTO, REFRESCOSARGUMENTARIO ] }) resumen;


    get resumenArgumentario() {
        return getFieldValue(this.resumen.data, RESUMEN_ARGUMENTARIO);
    }

    get informacionAdicional() {
        return getFieldValue(this.resumen.data, INFORMACION_ADICIONAL);
    }

    get IdProducto() {
        return getFieldValue(this.resumen.data, IDPRODUCTO);
    }

    get refrescosArgumentario() {
        return getFieldValue(this.resumen.data, REFRESCOSARGUMENTARIO);
    }

    renderedCallback() {
        if(this.primerRender && typeof this.resumen.data !== "undefined" && this.resumenArgumentario === null && typeof this.planArg !== "undefined"){
            this.idProdcutoVar = this.IdProducto;
            this.primerRender = false;
            this.handleRefrescarArgu();
        }
        if(this.muestraCopiaArgu && this.resumenArgumentario !== undefined && this.resumenArgumentario !== null){
            this.muestraCopiaArgu = false;
        }                
        if(typeof this.resumen.data !== "undefined" && (this.idProdcutoVar === null || this.idProdcutoVar === undefined) && this.IdProducto !== null ){
            this.idProdcutoVar = this.IdProducto;
        }
        if(typeof this.resumen.data !== "undefined" && this.idProdcutoVar !== undefined && this.IdProducto !== null && this.idProdcutoVar !== this.IdProducto){
            this.handleRefrescarArgu();
            this.idProdcutoVar = this.IdProducto;
        }
    }

    handleRefrescarArgu() {
        this.isLoadingArgu = true;
        resolverPrompt({oppId: this.recordId, apiPrompt: this.planArg})
            .then(response => {
                response = this.limpiarRespuesta(response);
                const fields = {};
                fields[RESUMEN_ARGUMENTARIO.fieldApiName] = response;
                fields[ID_FIELD.fieldApiName] = this.recordId;
                fields[REFRESCOSARGUMENTARIO.fieldApiName] = this.refrescosArgumentario === null ? 1 : this.refrescosArgumentario + 1;
                const recordInput = {fields};
                updateRecord(recordInput);
                //guardar el valor generado para mostrarlo mientras se hace el update
                this.copiaResArgu = response;
                this.muestraCopiaArgu = true;
                this.notifyUser('Éxito', 'Refresco del argumentario realizado', 'success');
                this.isLoadingArgu = false;
            })
            .catch(error => {
                console.error('Error refrescando el argumentario', error);
                this.notifyUser('Error', 'Error refrescando el argumentario', 'error');
                this.isLoadingArgu = false;
            });
        
    }

    handleSubmitArgu(event){
        event.preventDefault();       // stop the form from submitting
        this.isLoadingArgu = true;
        const fields = event.detail.fields;
        //si ha cambiado la informacion adicional, hay que hacer un update
        if(fields.CSBD_InformacionAdicional__c !== this.informacionAdicional){
            this.template.querySelector('lightning-record-edit-form').submit(fields);
        }
        //en el argumentario se usa el mismo prompt tanto si hay info adicional como si no
        this.handleRefrescarArgu();
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