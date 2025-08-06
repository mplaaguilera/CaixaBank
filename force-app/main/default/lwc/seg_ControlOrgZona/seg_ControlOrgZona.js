import { LightningElement, api, track, wire } from 'lwc';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import {ShowToastEvent} from 'lightning/platformShowToastEvent';

//Campos
import ID_CUENTA from '@salesforce/schema/Case.AccountId';
import ID_CONTACTO from '@salesforce/schema/Case.ContactId';
import CASE_ORG from '@salesforce/schema/Case.SEG_Organizacion__c';
import CASE_ZONA from '@salesforce/schema/Case.SEG_Zona__c';
import ACCOUNT_FORMULA_ORG from '@salesforce/schema/Case.Account.SEG_FormulaOrganizacion__c';
import ACCOUNT_FORMULA_ZONA from '@salesforce/schema/Case.Account.SEG_FormulaZona__c';
import CONTACT_DEVELOPER_NAME from '@salesforce/schema/Case.Contact.RecordType.DeveloperName';

//Apex
import obtenerMtd from '@salesforce/apex/SEG_DiscrepanciaOrgZona.obtenerMtd';
 
export default class Seg_ControlOrgZona extends LightningElement {

    @api recordId;
    @track tituloCard;
    lstExcepciones = [];
    discrepanciaOrgZona = true;
    caso;
    mostrarErrores = true;

    @wire(getRecord, { recordId: '$recordId', fields: [ID_CUENTA, ID_CONTACTO, CASE_ORG, CASE_ZONA, ACCOUNT_FORMULA_ORG, ACCOUNT_FORMULA_ZONA, CONTACT_DEVELOPER_NAME] })
    wiredRecord({error, data}) {
        if (error) {
            this.errorDatos(error);
        } else if (data) {
			this.caso = data;
            this.tituloCard = 'Caso: ' + getFieldValue(this.caso, CASE_ORG) + '/' + getFieldValue(this.caso, CASE_ZONA) + ', Peticionario: ' + getFieldValue(this.caso, ACCOUNT_FORMULA_ORG) + '/' + getFieldValue(this.caso, ACCOUNT_FORMULA_ZONA);
        }
        this.mostrarErrores = true;
    }

    get discrepancia() {
        this.discrepanciaOrgZona = true;
        if(this.caso){
            console.log('getFieldValue(this.caso, ACCOUNT_FORMULA_ZONA) - ' + getFieldValue(this.caso, ACCOUNT_FORMULA_ZONA));
            console.log('getFieldValue(this.caso, CASE_ZONA) - ' + getFieldValue(this.caso, CASE_ZONA));
            console.log('getFieldValue(this.caso, ACCOUNT_FORMULA_ORG) - ' + getFieldValue(this.caso, ACCOUNT_FORMULA_ORG));
            console.log('getFieldValue(this.caso, CASE_ORG) - ' + getFieldValue(this.caso, CASE_ORG));
            if(getFieldValue(this.caso, CONTACT_DEVELOPER_NAME) != 'CC_Empleado' && getFieldValue(this.caso, ACCOUNT_FORMULA_ZONA) == getFieldValue(this.caso, CASE_ZONA) && 
            getFieldValue(this.caso, ACCOUNT_FORMULA_ORG) == getFieldValue(this.caso, CASE_ORG)){
                this.discrepanciaOrgZona = false;
            } else {
                this.lstExcepciones.forEach(excepcion => {
                    if(excepcion.SEG_Organizacion__c == getFieldValue(this.caso, CASE_ORG) && excepcion.SEG_Zonas__c != null && excepcion.SEG_Zonas__c.includes(getFieldValue(this.caso, CASE_ZONA))){
                        this.discrepanciaOrgZona = false;
                    }
                });
            }
        }
        console.log('Arnau::');
        console.log(this.discrepanciaOrgZona);
        console.log(this.mostrarErrores);
		return this.discrepanciaOrgZona && this.mostrarErrores;
	}

    connectedCallback() {
        this.obtenerMtd();
    }

    obtenerMtd(){
        obtenerMtd()
        .then(result => {
            this.lstExcepciones = result;
        })
        .catch(error => {
            this.errorDatos(error);
        });
    }

    errorDatos(error){
        let mensajeError;
        if (Array.isArray(error.body)) {
            mensajeError = error.body.map(e => e.message).join(', ');
        } else if (typeof error.body.message === 'string') {
            mensajeError = error.body.message;
        }
        this.mostrarToast('error', 'Problema recuperando los datos del caso', mensajeError);
    }

    mostrarToast(tipo, titulo, mensaje) {
		this.dispatchEvent(new ShowToastEvent({
			variant: tipo, title: titulo, message: mensaje, mode: 'dismissable', duration: 4000
		}));
	}

    cerrarAviso() {
		this.mostrarErrores = false;
	}
}