import { LightningElement, api, track } from 'lwc';
import createProductCase from '@salesforce/apex/SAC_LCMP_ProductosPretension.createProductCase';

export default class Sac_ProductCaseLayout extends LightningElement {
    @api recordId;  // El recordId se recibe desde la página donde se inserta el componente

    @track SAC_Pretension__c = '';
    @track Name = '';
    @track SAC_Descripcion__c = '';
    @track SAC_FechaApertura__c = '';
    @track SAC_FechaCancelacion__c = '';
    @track N_Contrato__c = '';
    @track SAC_Tipo__c = '';

    connectedCallback() {
        // Cuando el recordId cambie, actualiza el campo SAC_Pretension__c
        if (this.recordId) {
            this.SAC_Pretension__c = this.recordId;
        }
    }

    handleInputChange(event) {
        const field = event.target.name;
        this[field] = event.target.value;  // Usamos setters dinámicos para actualizar solo los campos que cambian
    }

    handleSave() {
        const productCase = {
            SAC_Pretension__c: this.SAC_Pretension__c,
            Name: this.Name,
            SAC_Descripcion__c: this.SAC_Descripcion__c,
            SAC_FechaApertura__c: this.SAC_FechaApertura__c,
            SAC_FechaCancelacion__c: this.SAC_FechaCancelacion__c,
            N_Contrato__c: this.N_Contrato__c,
            SAC_Tipo__c: this.SAC_Tipo__c
        };

        createProductCase({ productCase })
            .then(result => {
                console.log('Producto creado con éxito', result);
            })
            .catch(error => {
                console.error('Error al crear producto', error);
            });
    }

    get fields() {
        return [
            { label: 'Descripción', name: 'SAC_Descripcion__c', value: this.SAC_Descripcion__c, type: 'text' },
            { label: 'Fecha apertura', name: 'SAC_FechaApertura__c', value: this.SAC_FechaApertura__c, type: 'date' },
            { label: 'Fecha cancelación', name: 'SAC_FechaCancelacion__c', value: this.SAC_FechaCancelacion__c, type: 'date' },
            { label: 'Nº Contrato', name: 'N_Contrato__c', value: this.N_Contrato__c, type: 'text' },
            { label: 'Tipo', name: 'SAC_Tipo__c', value: this.SAC_Tipo__c, type: 'text' },
        ];
    }
}