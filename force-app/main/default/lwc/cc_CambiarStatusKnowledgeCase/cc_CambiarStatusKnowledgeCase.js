import { LightningElement, api, wire } from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';
import { CloseActionScreenEvent } from 'lightning/actions';
import {ShowToastEvent} from 'lightning/platformShowToastEvent';
import { getRecordNotifyChange } from 'lightning/uiRecordApi';
import changeStatusKnowledgeCase from '@salesforce/apex/CC_CaseStatusKnowledgeController.changeStatusKnowledgeCase';
import getConfiguraciones from '@salesforce/apex/CC_CaseStatusKnowledgeController.getConfiguraciones';


const STATUS_FIELD = 'Case.Status';
const CASE_EXTENSION_FIELD = 'Case.CBK_Case_Extension_Id__r.CC_Articulo_Relacionado__c';
const DETALLE_CONSULTA_FIELD = 'Case.CC_Detalles_Consulta__c';
const FIELDS = [STATUS_FIELD, CASE_EXTENSION_FIELD, DETALLE_CONSULTA_FIELD];

export default class ccCambiarStatusKnowledgeCase extends LightningElement {
    @api recordId;

     // Combobox 1
    estadoValue = ''; 
    estadoOptions = [];

    // Combobox 2
    accionValue = '';
    accionOptions = [
        { label: 'Archivar', value: 'Archivar' },
        { label: 'Renovar', value: 'Renovar' },
        { label: 'Actualizar', value: 'Actualizar' }
    ];

    caseRecord;
    isLoading = false;
    errorMessage = '';
    configuraciones = {};

    // Lightning Data Service para obtener el Status del caso
    @wire(getRecord, { recordId: '$recordId', fields: FIELDS })
    wiredRecord({ error, data }) {
        if (data) {
            this.caseRecord = data;
            const status = this.caseRecord.fields.Status.value;
            if (status === 'Activo') {
                this.estadoOptions = [
                    { label: 'Cerrado', value: 'Cerrado' },
                    { label: 'Pendiente Colaborador', value: 'Pendiente Colaborador' }
                ];
                this.estadoValue = this.estadoOptions[0].value;
            }else if (status === 'Pendiente Colaborador' || status === 'Cerrado') {
                this.errorMessage = 'El caso debe estar activo para poder cambiar el estado.';
            }else{
                this.errorMessage = 'El estado del caso no es válido para su modificación.';
            }

            //obtener las configuraciones
            getConfiguraciones()
            .then(result => {
                this.configuraciones = result;               
            })
            .catch(error => {
                this.errorMessage = error.body?.message || 'Hubo un error al obtener las configuraciones.';
            });
        } else if (error) {
            this.errorMessage = error.body?.message || 'Hubo un error al obtener el caso.';
        }
    }
 
    get showAccionCombobox() {
        return this.estadoValue === 'Cerrado';
    }

    get saveDisabled() {
        if (this.isLoading) {return true;}
        if (this.errorMessage){return true;}
        if (this.estadoValue === 'Cerrado') {
            return this.accionValue === '';
        }
        // Si el estado es Pendiente Colaborador, solo valida el estado
        return this.estadoValue === '';
    }

    get accionHelpText() {
        switch (this.accionValue) {
            case 'Archivar':
                return this.configuraciones.avisoArchivar || '';
            case 'Renovar':
                return this.configuraciones.avisoRenovar || '';
            case 'Actualizar':
                return this.configuraciones.avisoActualizar || '';
            default:
                return '';
        }
    }

    handleEstadoChange(event) {
        this.estadoValue = event.detail.value;
        if (this.estadoValue !== 'Cerrado') {
            this.accionValue = '';
        }
    }

    handleAccionChange(event) {
        this.accionValue = event.detail.value;
    }

    handleCancel() {
        this.dispatchEvent(new CloseActionScreenEvent());
    }

    handleSave() {       
        if (!this.validateForm()) {
            return;
        }        
        this.isLoading = true;
        changeStatusKnowledgeCase({ 
            caseId: this.recordId, 
            status: this.estadoValue, 
            action: this.accionValue 
        })
        .then(() => {
            this.isLoading = false;
            getRecordNotifyChange([{ recordId: this.recordId }]);
            this.dispatchEvent(new ShowToastEvent({
                title: 'Success',
                message: 'El caso se ha actualizado correctamente.',
                variant: 'success'
            }));           
            this.dispatchEvent(new CloseActionScreenEvent());
        })
        .catch(error => {
            this.isLoading = false;
            this.dispatchEvent(new ShowToastEvent({
                title: 'Error al actualizar el caso',
                message: error.body?.message || 'Hubo un error al actualizar el caso.',
                variant: 'error'
            }));
            this.dispatchEvent(new CloseActionScreenEvent());
        });
    }

    validateForm() {
        const { inputEstado, inputAccion } = this.refs;
        let isValid = true;
        if (inputEstado) {
            inputEstado.reportValidity();
            isValid = isValid && inputEstado.checkValidity();
        }
        // Solo valida acción si el estado es Cerrado
        if (this.estadoValue === 'Cerrado' && inputAccion) {
            inputAccion.reportValidity();
            isValid = isValid && inputAccion.checkValidity();
        }
        return isValid;
    }
}