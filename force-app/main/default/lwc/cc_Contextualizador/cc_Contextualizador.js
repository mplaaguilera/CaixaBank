import { LightningElement, api, wire, track } from 'lwc';
import contextualizador from '@salesforce/apex/CC_WS_Contextualizador.ccWSContextualizador';
import NUMPERSON from '@salesforce/schema/Case.Account.CC_NumPerso__c';
import CASEID from '@salesforce/schema/Case.Id';
import CUENTA from '@salesforce/schema/CC_Llamada__c.CC_Cuenta__c';
import LLAMADA from '@salesforce/schema/CC_Llamada__c.Id';
//import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';

export default class cc_Contextualizador extends LightningElement {
    @api recordId;
    @track context = {};
    @track infoMostrar = false;
    @track idCuenta = null;
    @track idObjeto = null;
    @track tipoObjeto = null;
    @track ejecuciones = false;
    @api objectApiName;

    @wire(getRecord, { recordId: '$recordId', fields: '$cargarCampos' })
    wiredRecord({ error, data }) {
        if (error) {
            //this.mostrarToast('error', 'Problema recuperando los datos la cuenta', JSON.stringify(error));
        } else if (data) {
            if (this.objectApiName === 'Case') {
                this.idCuenta = getFieldValue(data, NUMPERSON);
                this.idObjeto = getFieldValue(data, CASEID);
                this.tipoObjeto = 'Case';
                if (this.idCuenta == null && this.idObjeto == null) {
                    console.log('Error, campos no informados Case');
                    return;
                }
            } else {
                this.idCuenta = getFieldValue(data, CUENTA);
                this.idObjeto = getFieldValue(data, LLAMADA);
                this.tipoObjeto = 'Llamada';
                if (this.idCuenta == null && this.idObjeto == null) {
                    console.log('Error, campos no informados Llamada');
                    return;
                }
            }
            contextualizador({
                idCuenta: this.idCuenta,
                idObjeto: this.idObjeto,
                tipoObjeto: this.tipoObjeto
            })
                .then(response => {
                    this.context = this.setContext(response);
                    if (this.context != null && this.context.MotivoDenegacion != null) {
                        this.infoMostrar = true;
                    }
                })
                .catch(error => {
                    // console.error(JSON.stringify(error));
                    // this.mostrarToast('error', 'Problema validando los datos la cuenta', error.body.message);
                });
        }
    }

    setContext(response) {
        return response;
    }

    get cargarCampos() {
        console.log("cargarCampos: ", this.objectApiName);
        if (this.objectApiName === 'CC_Llamada__c') {
            return [LLAMADA, CUENTA];
        } else {
            return [NUMPERSON, CASEID];
        }

    };

    // mostrarToast(variable, titulo, mensaje) {
    //     this.dispatchEvent(new ShowToastEvent({
    //         variant: variable, title: titulo, message: mensaje, mode: 'dismissable', duration: 4000
    //     }));
    // } 

}