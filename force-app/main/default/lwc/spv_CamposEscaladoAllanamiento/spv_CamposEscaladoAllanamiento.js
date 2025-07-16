import { LightningElement, api, wire, track } from 'lwc';
import { getRecord, getFieldValue, updateRecord } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import obtenerValoresPicklist from '@salesforce/apex/SPV_LCMP_CamposEscaladoAllanamiento.obtenerValoresPicklist';
import MOTIVOALLANAMIENTO_FIELD from '@salesforce/schema/SAC_Interaccion__c.SPV_MotivoAllanamiento__c';
import ANALISISALLANAMIENTO_FIELD from '@salesforce/schema/SAC_Interaccion__c.SPV_AnalisisAllanamiento__c';
import ID_FIELD from '@salesforce/schema/SAC_Interaccion__c.Id';

const escaladoFields = [ID_FIELD, MOTIVOALLANAMIENTO_FIELD, ANALISISALLANAMIENTO_FIELD];

export default class Spv_CamposEscaladoAllanamiento extends LightningElement {
    @api recordId;
    @api selectedOptionMotivo = '';
    @api selectedOptionAnalisis = '';
    optionsAnalisis = [];
    optionsMotivo = [];
    placeholderEscaladoMotivo = '--Ninguno--';
    placeholderEscaladoAnalisis = '--Ninguno--';
    escaladoMotivo;
    escaladoAnalisis;
    @track editarCampos = false; //Se pone a true cuando quiere que los campos se muestren en modo formulario


    //Recuperar registro con los campos definidos en la constante caseFields
    @wire(getRecord, {recordId: "$recordId",fields: escaladoFields})
    escaladoData({error, data}) {
        if (data) {
            if(data.fields.SPV_MotivoAllanamiento__c.value) {
                this.escaladoMotivo = data.fields.SPV_MotivoAllanamiento__c.value;
                this.placeholderEscaladoMotivo = data.fields.SPV_MotivoAllanamiento__c.value;
            }
            if(data.fields.SPV_AnalisisAllanamiento__c.value) {
                this.escaladoAnalisis = data.fields.SPV_AnalisisAllanamiento__c.value;
                this.placeholderEscaladoAnalisis = data.fields.SPV_AnalisisAllanamiento__c.value;
            }
        } 
        else if (error) {
            console.log(error)
        } 
    }

    @wire(obtenerValoresPicklist)
    getValoresPicklist({ error, data }){
        if(data){
            this.optionsAnalisis =  data.valoresAnalisis.map(item => ({
                label: item,
                value: item
            }));
            this.optionsMotivo =  data.valoresMotivo.map(item => ({
                label: item,
                value: item
            }));
        } else if(error){
            console.log(error);
        }
    }

    handleOptionChangeMotivo(event) {
        this.selectedOptionMotivo = event.detail.value;
        this.escaladoMotivo = event.detail.value;
        const fields = {};
        fields[ID_FIELD.fieldApiName] = this.recordId;
        fields[MOTIVOALLANAMIENTO_FIELD.fieldApiName] = event.detail.value;
        const recordInput = {fields};
        this.editarCampos = false;
        updateRecord(recordInput)
        .then(() => this.mostrarToast('success', 'Se actualizó el caso', 'Se actualizó correctamente el motivo de allanamiento'))
        .catch(error => {
            //Mostrar errores
            let errorMessage = 'Error al intentar actualizar el caso';
            if (error.body && error.body.output && error.body.output.errors) {
                const errors = error.body.output.errors;
                errorMessage = errors.map(err => err.message).join(', ');
            } else if (error.body.message) {
                errorMessage = error.body.message;
            }

            //Mostrar el mensaje de error en el toast
            this.mostrarToast('error', 'Error actualizando el caso', errorMessage);
        })
    }

    handleOptionChangeAnalisis(event) {
        this.selectedOptionAnalisis = event.detail.value;
        this.escaladoAnalisis = event.detail.value;
        const fields = {};
        fields[ID_FIELD.fieldApiName] = this.recordId;
        fields[ANALISISALLANAMIENTO_FIELD.fieldApiName] = event.detail.value;
        const recordInput = {fields};
        this.editarCampos = false;
        updateRecord(recordInput)
        .then(() => this.mostrarToast('success', 'Se actualizó el caso', 'Se actualizó correctamente el análisis allanamiento/desistimiento'))
        .catch(error => {
            //Mostrar errores
            let errorMessage = 'Error al intentar actualizar el caso';
            if (error.body && error.body.output && error.body.output.errors) {
                const errors = error.body.output.errors;
                errorMessage = errors.map(err => err.message).join(', ');
            } else if (error.body.message) {
                errorMessage = error.body.message;
            }

            //Mostrar el mensaje de error en el toast
            this.mostrarToast('error', 'Error actualizando el caso', errorMessage);
        })
    }

    //Método para mostrar un toast con los parametros introducidos
	mostrarToast(variant, title, message) {
		this.dispatchEvent(new ShowToastEvent({variant: variant, title: title, message: message, mode: 'dismissable', duration: 4000}));
	}


    //Controlar cuando se pulsa en el lapiz de editar

    handleEditarCampos(event){
        if(this.editarCampos == false){
            this.editarCampos = true;
        }else{
            this.editarCampos = false;
        } 
    }
}