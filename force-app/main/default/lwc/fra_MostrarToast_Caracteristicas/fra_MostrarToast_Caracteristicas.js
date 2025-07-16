import { LightningElement, api, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import conseguirCaracteristicaContactoCaso from '@salesforce/apex/FRA_Caracteristicas_Controller.conseguirCaracteristicaContactoCaso';
import conseguirCaracteristicaCuentaCaso from '@salesforce/apex/FRA_Caracteristicas_Controller.conseguirCaracteristicaCuenta';
import conseguirCaracteristicaContactoLlamada from '@salesforce/apex/FRA_Caracteristicas_Controller.conseguirCaracteristicaContactoLlamada';
import conseguirCaracteristicaCuentaLlamada from '@salesforce/apex/FRA_Caracteristicas_Controller.conseguirCaracteristicaCuentaLlamada';
import caseId from '@salesforce/schema/Case.Id';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';

import llamadaId from '@salesforce/schema/CC_Llamada__c.Id';
import cuenta from '@salesforce/schema/CC_Llamada__c.CC_Cuenta__c';

export default class Fra_MostrarToast_Caracteristicas_Caso extends LightningElement {
    
    @api recordId;
    @api objectApiName;
    idObjeto = null;
    tipoObjeto = null;
    idCuenta = null;

    @wire(getRecord, { recordId: '$recordId', fields: '$cargarCampos' })
    wiredRecord({ error, data }) {
        if (data) {
            if (this.objectApiName === 'Case') {
                this.idObjeto = getFieldValue(data, caseId);
                this.tipoObjeto = 'Case';
            } else {
                this.idCuenta = getFieldValue(data, cuenta);
                this.idObjeto = getFieldValue(data, llamadaId);
                this.tipoObjeto = 'Llamada';
            }

            if (this.tipoObjeto === 'Llamada') {
                this.loadContactCaracteristicasLlamada(this.idObjeto);
            }else{
                this.loadContactCaracteristicasCaso(this.idObjeto);
            }
        }
    }

            
    showToast(title, message, variant) {
        const event = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
            mode: 'sticky' // Hacer el toast sticky
        });
        this.dispatchEvent(event);
    }


    get cargarCampos() {
        if (this.objectApiName === 'CC_Llamada__c') {
            return [llamadaId, cuenta];
        } else {
            return [caseId];
        }
    }

    loadContactCaracteristicasCaso(idCaso) {
        let cuentaCaracteristicas = [];
        let clienteCaracteristicas = [];
    
        conseguirCaracteristicaContactoCaso({ idCaso: idCaso })
            .then(result => {
                if (result && result.length > 0) {
                    clienteCaracteristicas = result.map(item => this.formatCaracteristicas(item));
                }
            })
            .catch(error => { });
    
        conseguirCaracteristicaCuentaCaso({ idCaso: idCaso })
            .then(result => {
                if (result && result.length > 0) {
                    cuentaCaracteristicas = result.map(item => this.formatCaracteristicas(item));
                }
    
                let mensajeToast='';
                if (cuentaCaracteristicas.length > 0) {
                    mensajeToast += 'Características de cuenta:\n' + cuentaCaracteristicas.join('\n') + '\n';
                }
                if (clienteCaracteristicas.length > 0) {

                    mensajeToast += 'Características de contacto:\n' + clienteCaracteristicas.join('\n');
                }
    
                if (cuentaCaracteristicas.length > 0 || clienteCaracteristicas.length > 0) {
                    this.showToast('Características del Caso:', mensajeToast, 'warning');
                }
            })
            .catch(error => { });
    }
    


    loadContactCaracteristicasLlamada(idLlamada) {
        let cuentaCaracteristicas = [];
        let clienteCaracteristicas = [];

        conseguirCaracteristicaContactoLlamada({ idLlamada: idLlamada })
            .then(result => {
                if (result && result.length > 0) {
                    clienteCaracteristicas = result.map(item => this.formatCaracteristicas(item));
                }
            })
            .catch(error => { });
    
        conseguirCaracteristicaCuentaLlamada({ idLlamada: idLlamada })
            .then(result => {
                if (result && result.length > 0) {
                    cuentaCaracteristicas = result.map(item => this.formatCaracteristicas(item));
                }

                let mensajeToast='';
                if (cuentaCaracteristicas.length > 0) {
                    this.showToast('Características de la cuenta:\n', cuentaCaracteristicas.join('\n'), 'warning');
                    //mensajeToast += 'Características de cuenta:\n' + cuentaCaracteristicas.join('\n') + '\n';
                }
                if (clienteCaracteristicas.length > 0) {
                    //mensajeToast += 'Características de contacto:\n' + clienteCaracteristicas.join('\n');
                    this.showToast('Características del Contacto:', clienteCaracteristicas.join('\n'), 'warning');
                }
    
                if (cuentaCaracteristicas.length > 0 || clienteCaracteristicas.length > 0) {
                    //this.showToast('Características de la Llamada:', mensajeToast, 'warning');
                }
            })
            .catch(error => { });
    }
    
    formatCaracteristicas(caracteristica) {
        return `${caracteristica.CC_Caracteristica__r.Name} - ${caracteristica.CC_Caracteristica__r.CC_Descripcion__c}`;
    }
    
}