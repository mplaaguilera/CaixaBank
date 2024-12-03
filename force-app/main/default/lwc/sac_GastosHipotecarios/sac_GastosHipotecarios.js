import { LightningElement, api, track, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import comprobarTareas from '@salesforce/apex/SAC_LCMP_GastosHipotecarios.comprobarTareas';
import modificarImportesTarea from '@salesforce/apex/SAC_LCMP_GastosHipotecarios.modificarImportesTarea';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import sacOtrosGastosField from '@salesforce/schema/Case.SAC_Otros_gastos__c';
import sacOriginField from '@salesforce/schema/Case.Origin';


export default class Sac_GastosHipotecarios extends LightningElement {
 
    @api recordId;
    @api spinnerLoading = false;
    @track A1;
    @track A2; 
    @track A3;
    @track A4; 
    @track A5;
    @track resultA;
    @track readOnly = true;
    sacOtrosGastosValue;
    sacOriginValue;
    showSacOtrosGastos = false;

    @wire(getRecord, { recordId: '$recordId', fields: [sacOtrosGastosField, sacOriginField] })
    caseRecord({ error, data }) {
        if (data) {
            this.sacOtrosGastosValue = data.fields.SAC_Otros_gastos__c.value;
            this.sacOriginValue = data.fields.Origin.value;
            if(this.sacOtrosGastosValue != null && this.sacOriginValue == 'SAC_Formulario'){
                this.showSacOtrosGastos = true;
            }
        } else if (error) {
            console.error('Error retrieving SAC_Otros_gastos__c:', error);
        }
    }

    @wire(getRecord, { recordId: '$recordId'})
    case;
    
    @wire(comprobarTareas, { caseId: '$recordId' })
    tareasGGH(result){
        this.readOnly = result.data;
    }

    handleSubmit(event) {
        this.spinnerLoading = true;

        // Get data from submitted form
        const fields = event.detail.fields;
        // Here you can execute any logic before submit
        // and set or modify existing fields
        fields.CC_Importe_Reclamado__c = Number(fields.SAC_ImpReclamadoNotaria__c) + Number(fields.SAC_ImpReclamadoGestoria__c) + Number(fields.SAC_ImpReclamadoRegistros__c) + Number(fields.SAC_ImpReclamadoTasacion__c) + Number(fields.SAC_ImpReclamadoInteresesLegales__c);
        fields.SAC_Importe_Resuelto__c = Number(fields.SAC_ImpResueltoNotaria__c) + Number(fields.SAC_ImpResueltoGestoria__c) + Number(fields.SAC_ImpResueltoRegistros__c) + Number(fields.SAC_ImpResueltoTasacion__c) + Number(fields.SAC_ImpResueltoInteresesLegales__c);

        let arrayImportes= [
                    Number(fields.SAC_ImpResueltoNotaria__c),
                    Number(fields.SAC_ImpResueltoGestoria__c),
                    Number(fields.SAC_ImpResueltoRegistros__c),
                    Number(fields.SAC_ImpResueltoTasacion__c),
                    Number(fields.SAC_ImpResueltoInteresesLegales__c)]

        
        this.template.querySelector('lightning-record-edit-form').submit(fields);

        modificarImportesTarea({caseId: this.recordId, arrayImportes: arrayImportes}).then(result => {
            
        }).catch(error => {
            this.isLoading = false;
            this.errorMsg = error;

            console.log(error);
            this.dispatchEvent(
            new ShowToastEvent({
                title: 'Fallo al actualizar los importes en la tarea',
                message: error.message,
                variant: 'error'
            }),);
        })

    }
    handleSuccess(event) {
        const updatedRecord = event.detail.id;
        console.log('onsuccess: ', updatedRecord);
        const toast = new ShowToastEvent({
            title: 'Gestión del caso',
            message: 'Se han actualizado campos del caso.',
            variant: 'success'
        });
        this.dispatchEvent(toast);
        this.spinnerLoading = false;
    }

}