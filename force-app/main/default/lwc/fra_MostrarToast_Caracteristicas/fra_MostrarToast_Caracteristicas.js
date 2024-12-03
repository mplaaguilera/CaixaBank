import { LightningElement, api, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import conseguirCaracteristicaContactoCaso from '@salesforce/apex/FRA_Caracteristicas_Controller.conseguirCaracteristicaContactoCaso';
import conseguirCaracteristicaCuentaCaso from '@salesforce/apex/FRA_Caracteristicas_Controller.conseguirCaracteristicaCuenta';
import caseId from '@salesforce/schema/Case.Id';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';

export default class Fra_MostrarToast_Caracteristicas_Caso extends LightningElement {
    
    @api recordId;
    @api objectApiName;

    @wire(getRecord, { recordId: '$recordId', fields: [caseId] })
    wiredRecord({ error, data }) {
        if (data) {
            this.loadContactCaracteristicasCaso(this.recordId);
        }
    }

    // Buscamos las características del Contacto y la Cuenta asociadas al Caso
    loadContactCaracteristicasCaso(idCaso) {
        let caracteristicas = [];

        // Llamada a conseguirCaracteristicaContactoCaso
        conseguirCaracteristicaContactoCaso({ idCaso: idCaso })
            .then(result => {
                if (result && result.length > 0) {
                    result.forEach(item => {
                            caracteristicas.push(this.formatCaracteristicas([item]));
                    });
                }
            })
            .catch(error => { /* Error handling si fuera necesario */ });

        // Llamada a conseguirCaracteristicaCuentaCaso
        conseguirCaracteristicaCuentaCaso({ idCaso: idCaso })
            .then(result => {
                if (result && result.length > 0) {
                    result.forEach(item => {
                            caracteristicas.push(this.formatCaracteristicas([item]));
                    });
                }

                // Mostrar toast combinado si hay características
                if (caracteristicas.length > 0) {
                    this.showToast(
                        'Características asignadas en el Caso:', 
                        caracteristicas.join('\n'), 
                        'warning'
                    );
                }
            })
            .catch(error => { /* Error handling si fuera necesario */ });
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

    formatCaracteristicas(caracteristicas) {
        return caracteristicas.map(caracteristica => {
            return `${caracteristica.CC_Caracteristica__r.CC_Descripcion__c}`;
        }).join('\n');
    }
}