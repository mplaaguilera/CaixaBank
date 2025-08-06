import { LightningElement, track, wire, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getRecord, getFieldValue} from 'lightning/uiRecordApi';
import { RefreshEvent } from 'lightning/refresh';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import CASO_OBJECT from '@salesforce/schema/Case'; 

//Campos reclamación
import IDFIELD from '@salesforce/schema/Case.Id';
import CASE_EXTENSION from '@salesforce/schema/Case.CBK_Case_Extension_Id__c';
import IDRECLAMACION from '@salesforce/schema/Case.SAC_Reclamacion__c';
import RECLAMACION_EXTENSION from '@salesforce/schema/Case.SAC_Reclamacion__r.CBK_Case_Extension_Id__c';
import DECISION_PRETENSION_FIELD from '@salesforce/schema/Case.CBK_Case_Extension_Id__r.SPV_DecisionPretensionLetrado__c';
import ANALISISDESISTIMIENTO_FIELD from '@salesforce/schema/Case.CBK_Case_Extension_Id__r.SPV_AnalisisDesistimiento__c';
import ANALISISALLANAMIENTO_FIELD from '@salesforce/schema/Case.CBK_Case_Extension_Id__r.SPV_AnalisisAllanamiento__c';
import MOTIVODESISTIMIENTO_FIELD from '@salesforce/schema/Case.CBK_Case_Extension_Id__r.SPV_MotivoDesistimiento__c';
import MOTIVOALLANAMIENTO_FIELD from '@salesforce/schema/Case.CBK_Case_Extension_Id__r.SPV_MotivoAllanamiento__c';
import ENTIDADAFECTADA_FIELD from '@salesforce/schema/Case.SAC_Entidad_Afectada__c';

import obtenerValoresPicklist from '@salesforce/apex/SPV_LCMP_PaginaDetallesPretension.obtenerValoresPicklist';
import updatearCaseExtension from '@salesforce/apex/SPV_LCMP_PaginaDetallesPretension.updatearCaseExtension';
import updateRecordsForm from '@salesforce/apex/SPV_LCMP_PaginaDetallesPretension.updateRecordsForm';


const fields = [IDFIELD, CASE_EXTENSION, IDRECLAMACION, RECLAMACION_EXTENSION, DECISION_PRETENSION_FIELD, ANALISISDESISTIMIENTO_FIELD, ANALISISALLANAMIENTO_FIELD, MOTIVODESISTIMIENTO_FIELD, MOTIVOALLANAMIENTO_FIELD, ENTIDADAFECTADA_FIELD];

export default class Spv_PaginaDetallesPretension extends LightningElement {
    @api recordId;
    @api objectApiName;

    @track caso;
    @track idCaso;
    @track idReclamacion;
    @track caseExtensionId;
    @track caseExtensionIdReclamacion;
    @track spinnerLoading = false;

    @track editarCampos = false; //Se pone a true cuando quiere que los campos se muestren en modo formulario

    @track mostrarSeccionVidaCaixa = false; // Controla la visibilidad de la seccion VidaCaixa
    @track mostrarSubSeccionAlegaciones = false; // Controla la visibilidad de la subseccion Alegaciones
    @track mostrarSubSeccionAllanamiento = false; // Controla la visibilidad de la subseccion Allanamiento
    @track mostrarSubSeccionDesistimiento = false; // Controla la visibilidad de la subseccion Desistimiento
    @track mostrarSubSeccionInadmision = false; // Controla la visibilidad de la subseccion Inadmision

    @track selectedOptionAnalisisDesistimiento = '';
    @track selectedOptionAnalisisAllanamiento = '';
    @track selectedOptionMotivoDesistimiento = '';
    @track selectedOptionMotivoAllanamiento = '';
    optionsAnalisis = [];
    optionsMotivo = [];
    placeholderAnalisisDesistimiento = '--Ninguno--';
    placeholderAnalisisAllanamiento = '--Ninguno--';
    placeholderMotivoDesistimiento = '--Ninguno--';
    placeholderMotivoAllamiento = '--Ninguno--';


    //Controlar desplegable: Datos del reclamante
    @track toggleSeccionDatosReclamantes = "slds-section slds-is-open";
    @track expandirDatosReclamantes = true;

    //Controlar desplegable: Detalles
    @track toggleSeccionDetalles = "slds-section slds-is-open";
    @track expandirDetalles = true;

    //Controlar desplegable: VidaCaixa
    @track toggleSeccionVidaCaixa = "slds-section slds-is-open";
    @track expandirVidaCaixa = true;

    //Controlar desplegable seccion: Decisión Análisis
    @track toggleSeccionDecisionAnalisis = "slds-section slds-is-open";
    @track expandirDecisionAnalisis = true;
    @track mostrarDesplegablerDecisionAnalisis = false;

    //Controlar Subdesplegable: Antecedentes SAC
    @track toggleSubSeccionAntecedentes = "slds-section slds-is-open";
    @track expandirAntecedentesSAC = true;

    //Controlar Subdesplegable: Valoración documentación posible
    @track toggleSubSeccionValoracion = "slds-section slds-is-open";
    @track expandirValoracion = true;
    
    //Controlar Subdesplegable: Comprobaciones realizadas
    @track toggleSubSeccionComprobaciones = "slds-section slds-is-open";
    @track expandirComprobaciones = true;

    //Controlar Subdesplegable: Pretensiones
    @track toggleSubSeccionPretensiones = "slds-section slds-is-open";
    @track expandirPretensiones = true;

    //Controlar Subdesplegable: Allanamiento
    @track toggleSubSeccionAllanamiento = "slds-section slds-is-open";
    @track expandirAllanamiento = true;

    //Controlar Subdesplegable: Desistimiento
    @track toggleSubSeccionDesistimiento = "slds-section slds-is-open";
    @track expandirDesistimiento = true;

    //Controlar Subdesplegable: Decisión Final
    @track toggleSubSeccionDecisionFinal = "slds-section slds-is-open";
    @track expandirDecisionFinal = true;


    @wire(getObjectInfo, {objectApiName: CASO_OBJECT})
    objectInfoCase;

    @wire(getRecord, { recordId: '$recordId', fields })
    wiredCase({error, data}){
        if(data){
            this.caso = data;
            this.idCaso = data.fields.Id.value;
            this.idReclamacion = data.fields.SAC_Reclamacion__c.value;
            this.caseExtensionId = data.fields.CBK_Case_Extension_Id__c.value;
            this.caseExtensionIdReclamacion = data.fields.CBK_Case_Extension_Id__c.value;
        
            // Recuperar valores picklist parametrizables
            if(data.fields.CBK_Case_Extension_Id__r.value.fields.SPV_AnalisisDesistimiento__c.value) {
                this.placeholderAnalisisDesistimiento = data.fields.CBK_Case_Extension_Id__r.value.fields.SPV_AnalisisDesistimiento__c.value;
            }
            if(data.fields.CBK_Case_Extension_Id__r.value.fields.SPV_AnalisisAllanamiento__c.value) {
                this.placeholderAnalisisAllanamiento = data.fields.CBK_Case_Extension_Id__r.value.fields.SPV_AnalisisAllanamiento__c.value;
            }
            if(data.fields.CBK_Case_Extension_Id__r.value.fields.SPV_MotivoDesistimiento__c.value) {
                this.placeholderMotivoDesistimiento = data.fields.CBK_Case_Extension_Id__r.value.fields.SPV_MotivoDesistimiento__c.value;
            }
            if(data.fields.CBK_Case_Extension_Id__r.value.fields.SPV_MotivoAllanamiento__c.value) {
                this.placeholderMotivoAllamiento = data.fields.CBK_Case_Extension_Id__r.value.fields.SPV_MotivoAllanamiento__c.value;
            }

            // Comprobar si se tienen que mostrar las subsecciones
            if(data.fields.CBK_Case_Extension_Id__r.value.fields.SPV_DecisionPretensionLetrado__c.value === 'Alegaciones') {
                this.mostrarSubSeccionAlegaciones = true;
            } else if(data.fields.CBK_Case_Extension_Id__r.value.fields.SPV_DecisionPretensionLetrado__c.value === 'Allanamiento') {
                this.mostrarSubSeccionAllanamiento = true;
            } else if(data.fields.CBK_Case_Extension_Id__r.value.fields.SPV_DecisionPretensionLetrado__c.value === 'Desistimiento') {
                this.mostrarSubSeccionDesistimiento = true;
            } else if(data.fields.CBK_Case_Extension_Id__r.value.fields.SPV_DecisionPretensionLetrado__c.value === 'Inadmisión') {
                this.mostrarSubSeccionInadmision = true;
            }
            
            // Comprobar si se tiene que mostrar la seccion VidaCaixa
            if(data.fields.SAC_Entidad_Afectada__c.value === 'SAC_007') {
                this.mostrarSeccionVidaCaixa = true;
            }
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
        }
    }


    //Controlar cuando se pulsa en el lapiz de editar
    handleEditarCampos(event){
        if(this.editarCampos == false){
            this.editarCampos = true;
        }else{
            this.editarCampos = false;
        } 
    }

    handleSubmit(event){    
        event.preventDefault(); 
        
        const recordsMap = new Map(); 

        // Recorrer todos los lightning-record-edit-form en el componente
        this.template.querySelectorAll('lightning-record-edit-form').forEach((form) => {
            const recordId = form.dataset.recordId; // Extraer el recordId del atributo data-record-id

            // Si el recordId ya existe en el Map, usamos el objeto existente; si no, creamos uno nuevo
            let record = recordsMap.get(recordId) || { Id: recordId };

            const inputs = form.querySelectorAll('lightning-input-field');
            inputs.forEach((input) => {
                record[input.fieldName] = input.value; 
            });

            recordsMap.set(recordId, record);
        });
        
        if (recordsMap.has(this.caseExtensionId)) {
            let caseExtension = recordsMap.get(this.caseExtensionId);
    
            // Añadir los cambios hechos en las picklist parametrizables si se han realizados cambios
            if(this.selectedOptionAnalisisDesistimiento != '') {
                caseExtension.SPV_AnalisisDesistimiento__c = this.selectedOptionAnalisisDesistimiento;
            }
            if(this.selectedOptionAnalisisAllanamiento != '') {
                caseExtension.SPV_AnalisisAllanamiento__c = this.selectedOptionAnalisisAllanamiento;
            }
            if(this.selectedOptionMotivoDesistimiento != '') {
                caseExtension.SPV_MotivoDesistimiento__c = this.selectedOptionMotivoDesistimiento;
            }
            if(this.selectedOptionMotivoAllanamiento != '') {
                caseExtension.SPV_MotivoAllanamiento__c = this.selectedOptionMotivoAllanamiento;
            }
    
            recordsMap.set(this.caseExtensionId, caseExtension);
        } 

        // Convertir el Map en una lista de objetos
        const recordsToUpdate = Array.from(recordsMap.values());
        
        // Llamar al método Apex para actualizar los registros
        this.spinnerLoading = true;
        updateRecordsForm({'recordsToUpdate': recordsToUpdate})
            .then(() => {
                this.spinnerLoading = false;
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Éxito',
                        message: 'Se han actualizado los campos correctamente.',
                        variant: 'success'
                    })
                );
                this.editarCampos = false;  //Se cierran los campos de modo edición
                this.dispatchEvent(new RefreshEvent());
            })
            .catch((error) => {
                this.spinnerLoading = false;
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error',
                        message: 'Error al actualizar los campos.',
                        variant: 'error'
                    })
                );
                this.editarCampos = false;  //Se cierran los campos de modo edición
            });
    }


    // Controlar los campos picklist para mostrar las subsecciones solo en los casos requeridos
    handleDecisionPretensionChange(event) {
        // Obtén el valor del campo SPV_MotivoProrroga__c
        const selectedValue = event.detail.value;
        if(selectedValue == 'Alegaciones') {
            this.mostrarSubSeccionAlegaciones = true;
            // Ocultar las otras subsecciones
            this.mostrarSubSeccionAllanamiento = false;
            this.mostrarSubSeccionDesistimiento = false;
            this.mostrarSubSeccionInadmision = false;
        } else if(selectedValue == 'Allanamiento') {
            this.mostrarSubSeccionAllanamiento = true;
            // Ocultar las otras subsecciones
            this.mostrarSubSeccionAlegaciones = false;
            this.mostrarSubSeccionDesistimiento = false;
            this.mostrarSubSeccionInadmision = false;
        } else if(selectedValue == 'Desistimiento') {
            this.mostrarSubSeccionDesistimiento = true;
            // Ocultar las otras subsecciones
            this.mostrarSubSeccionAllanamiento = false;
            this.mostrarSubSeccionAlegaciones = false;
            this.mostrarSubSeccionInadmision = false;
        } else if(selectedValue == 'Inadmisión') {
            this.mostrarSubSeccionInadmision = true;
            // Ocultar las otras subsecciones
            this.mostrarSubSeccionAllanamiento = false;
            this.mostrarSubSeccionDesistimiento = false;
            this.mostrarSubSeccionAlegaciones = false;
        }
    }

    //Controlar el abrir y cerrar desplegables
    handleExpandirDatosReclamantes(){
        if(this.expandirDatosReclamantes){
            this.expandirDatosReclamantes = false;
            this.toggleSeccionDatosReclamantes = "slds-section"; 
        }else{
            this.expandirDatosReclamantes = true;
            this.toggleSeccionDatosReclamantes = "slds-section slds-is-open";
        }
    }

    handleExpandirDetalles(){
        if(this.expandirDetalles){
            this.expandirDetalles = false;
            this.toggleSeccionDetalles = "slds-section"; 
        }else{
            this.expandirDetalles = true;
            this.toggleSeccionDetalles = "slds-section slds-is-open";
        }
    }

    handleExpandirVidaCaixa(){
        if(this.expandirVidaCaixa){
            this.expandirVidaCaixa = false;
            this.toggleSeccionVidaCaixa = "slds-section"; 
        }else{
            this.expandirVidaCaixa = true;
            this.toggleSeccionVidaCaixa = "slds-section slds-is-open";
        }
    }

    handleExpandirDecisionAnalisis(){
        if(this.expandirDecisionAnalisis){
            this.expandirDecisionAnalisis = false;
            this.toggleSeccionDecisionAnalisis = "slds-section"; 
        }else{
            this.expandirDecisionAnalisis = true;
            this.toggleSeccionDecisionAnalisis = "slds-section slds-is-open";
        }
    }

    handleExpandirAntecedentesSAC(){
        if(this.expandirAntecedentesSAC){
            this.expandirAntecedentesSAC = false;
            this.toggleSubSeccionAntecedentes = "slds-section"; 
        }else{
            this.expandirAntecedentesSAC = true;
            this.toggleSubSeccionAntecedentes = "slds-section slds-is-open";
        }
    }

    handleExpandirValoracion(){
        if(this.expandirValoracion){
            this.expandirValoracion = false;
            this.toggleSubSeccionValoracion = "slds-section"; 
        }else{
            this.expandirValoracion = true;
            this.toggleSubSeccionValoracion = "slds-section slds-is-open";
        }
    }

    handleExpandirComprobaciones(){
        if(this.expandirComprobaciones){
            this.expandirComprobaciones = false;
            this.toggleSubSeccionComprobaciones = "slds-section"; 
        }else{
            this.expandirComprobaciones = true;
            this.toggleSubSeccionComprobaciones = "slds-section slds-is-open";
        }
    }

    handleExpandirPretensiones(){
        if(this.expandirPretensiones){
            this.expandirPretensiones = false;
            this.toggleSubSeccionPretensiones = "slds-section"; 
        }else{
            this.expandirPretensiones = true;
            this.toggleSubSeccionPretensiones = "slds-section slds-is-open";
        }
    }

    handleExpandirAllanamiento(){
        if(this.expandirAllanamiento){
            this.expandirAllanamiento = false;
            this.toggleSubSeccionAllanamiento = "slds-section"; 
        }else{
            this.expandirAllanamiento = true;
            this.toggleSubSeccionAllanamiento = "slds-section slds-is-open";
        }
    }

    handleExpandirDesistimiento(){
        if(this.expandirDesistimiento){
            this.expandirDesistimiento = false;
            this.toggleSubSeccionDesistimiento = "slds-section"; 
        }else{
            this.expandirDesistimiento = true;
            this.toggleSubSeccionDesistimiento = "slds-section slds-is-open";
        }
    }

    handleExpandirDecisionFinal(){
        if(this.expandirDecisionFinal){
            this.expandirDecisionFinal = false;
            this.toggleSubSeccionDecisionFinal = "slds-section"; 
        }else{
            this.expandirDecisionFinal = true;
            this.toggleSubSeccionDecisionFinal = "slds-section slds-is-open";
        }
    }


    handleOptionChangeAnalisisDesistimiento(event) {
        this.selectedOptionAnalisisDesistimiento = event.detail.value;
    }

    handleOptionChangeMotivoDesistimiento(event) {
        this.selectedOptionMotivoDesistimiento = event.detail.value;
    }


    handleOptionChangeAnalisisAllanamiento(event) {
        this.selectedOptionAnalisisAllanamiento = event.detail.value;
    }


    handleOptionChangeMotivoAllanamiento(event) {
        this.selectedOptionMotivoAllanamiento = event.detail.value;
    }

}