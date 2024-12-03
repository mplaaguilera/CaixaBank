import { LightningElement, api, wire, track } from 'lwc';
import reclamacionesVinculadas from '@salesforce/apex/SAC_LCMP_DesvincularReclamacion.reclamacionesVinculadas';
import consultasVinculadas from '@salesforce/apex/SAC_LCMP_DesvincularReclamacion.consultasVinculadas';
import desvincularReclamacion from '@salesforce/apex/SAC_LCMP_DesvincularReclamacion.desvincularReclamacion';
import desvincularConsulta from '@salesforce/apex/SAC_LCMP_DesvincularReclamacion.desvincularConsulta';
import { getRecord } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';
import { refreshApex } from '@salesforce/apex';
import { updateRecord } from 'lightning/uiRecordApi';
import esPropietario from '@salesforce/apex/SAC_LCMP_UpdateStatus.esPropietario';

export default class Sac_DesvincularReclamacion extends NavigationMixin(LightningElement) {

    
    @api recordId;
    @api caseId;
    @api spinnerLoading = false;
    @track reclamaciones;
    @track consultas;
    @track mensajeDesvinculacion;
    @track error;
    @track ocultarReclamaciones = false;
    @track ocultarConsultas = false;

    @wire(getRecord, { recordId: '$recordId' })
    case;

     _wiredResult;
     _wiredResult2;


    @wire(reclamacionesVinculadas, { caseId: '$recordId' })
    casos(result){
        this._wiredResult = result; 
        if (result.data) {
            this.reclamaciones = result.data;

            if(result.data.length >= 1){
                this.ocultarReclamaciones = true;
            }else{
                this.ocultarReclamaciones = false;
            }

        }else if (result.error) {
            this.error = result.error;
        }
    }

    @wire(consultasVinculadas, { caseId: '$recordId' })
    consulta(result){
        this._wiredResult2 = result; 
        if (result.data) {
            this.consultas = result.data;

            if(result.data.length >= 1){
                this.ocultarConsultas = true;
            }else{
                this.ocultarConsultas = false;
            }

        }else if (result.error) {
            this.error = result.error;
        }
    }

    navigateToCase(evt) {

        evt.preventDefault();
        var variableAuxiliarCodigoboton = evt.currentTarget.id;
        for (var i = 0; i < variableAuxiliarCodigoboton.length - 1; i++) {
            if (variableAuxiliarCodigoboton.charAt(i) == '-') {
                this.caseId = variableAuxiliarCodigoboton.substring(0, i);
            }
        }
        evt.stopPropagation();

        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                "recordId": this.caseId,
                "objectApiName": "Case",
                "actionName": "view"
            }
        });

    }

    updateRecordView(recordId) {
        updateRecord({fields: { Id: recordId }});
    }

    desvincular(evt) {
        this.spinnerLoading = true;
        evt.preventDefault();
        var variableAuxiliarCodigoboton = evt.currentTarget.id;
        for (var i = 0; i < variableAuxiliarCodigoboton.length - 1; i++) {
            if (variableAuxiliarCodigoboton.charAt(i) == '-') {
                this.caseId = variableAuxiliarCodigoboton.substring(0, i);
            }
        }
        evt.stopPropagation();
        desvincularReclamacion({ caseId: this.caseId })
            .then(result => {
                this.mensajeDesvinculacion = result;
                this.dispatchEvent(new ShowToastEvent({
                    title: 'Reclamación desvinculada',
                    message: this.mensajeDesvinculacion,
                    variant: 'success'
                }),);
                this.spinnerLoading = false;
                refreshApex(this._wiredResult);
                this.updateRecordView(this.recordId);
            })
            .catch(error => {
                
                this.dispatchEvent(new ShowToastEvent({
                    title: 'No se ha podido desvincular la reclamación',
                    message: error.body.message,
                    variant: 'error'
                }),);
                this.spinnerLoading = false;
            });
    }

    desvincularConsultas(evt){
        this.spinnerLoading = true;
        evt.preventDefault();
        var variableAuxiliarCodigoboton = evt.currentTarget.id;
        for (var i = 0; i < variableAuxiliarCodigoboton.length - 1; i++) {
            if (variableAuxiliarCodigoboton.charAt(i) == '-') {
                this.caseId = variableAuxiliarCodigoboton.substring(0, i);
            }
        }
        evt.stopPropagation();
        desvincularConsulta({ caseId: this.caseId })
            .then(result => {
                this.mensajeDesvinculacion = result;
                this.dispatchEvent(new ShowToastEvent({
                    title: 'Consulta desvinculada',
                    message: this.mensajeDesvinculacion,
                    variant: 'success'
                }),);
                this.spinnerLoading = false;
                refreshApex(this._wiredResult2);
                this.updateRecordView(this.recordId);
            })
            .catch(error => {
                
                this.dispatchEvent(new ShowToastEvent({
                    title: 'No se ha podido desvincular la consulta',
                    message: error.body.message,
                    variant: 'error'
                }),);
                this.spinnerLoading = false;
            });
    }

}