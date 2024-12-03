import { LightningElement, api, wire, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { RefreshEvent } from 'lightning/refresh';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import getPretensiones from '@salesforce/apex/SAC_LCMP_RedaccionFinal.getPretensiones';
import finalizarRedaccionNegociacion from '@salesforce/apex/SAC_LCMP_RedaccionFinal.finalizarRedaccionNegociacion';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import CASO_OBJECT from '@salesforce/schema/Case';

const fields = [
    'Case.Status',
    'Case.SAC_Antecedentes_Revisados_Negociacion__c',
    'Case.SAC_ReclamanteConformeNegociacion__c'
];

const columns = [
    { label: 'Temática', fieldName: 'CC_MCC_Tematica' }, 
    { label: 'Producto/Servicio', fieldName: 'CC_MCC_ProdServ'},
    { label: 'Motivo', fieldName: 'CC_MCC_Motivo'},
    { label: 'Detalle', fieldName: 'SEG_Detalle'}
];

export default class SAC_ResolverNegociarRedaccion extends LightningElement {
    @api recordId;
    @api isLoading = false; 
    @api checkMail;

    @track isModalOpenPretensiones = false;

    existenDatos;
    numPretensiones;
    antecedentesRevisados;
    reclamanteConforme
    estado;

    pretensiones = [];
    columns = columns;
    mostrarBoton = true;
    lstSelectedRecords = [];

    @wire (getObjectInfo, {objectApiName: CASO_OBJECT})
    objectInfo;

    @wire(getRecord, {recordId: '$recordId', fields})
    actualCase({data, error}){
        if(error) {
            let message = 'Ha ocurrido un error';
            if (Array.isArray(error.body)) {
                message = error.body.map(e => e.message).join(', ');
            } else if (typeof error.body.message === 'string') {
                message = error.body.message;
            }
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error recuperando el caso',
                    message,
                    variant: 'error'
                })
            );
        } else if(data) {
            this.existenDatos = data;
            this.antecedentesRevisados = this.existenDatos.fields.SAC_Antecedentes_Revisados_Negociacion__c.value;
            this.reclamanteConforme = this.existenDatos.fields.SAC_ReclamanteConformeNegociacion__c.value;
            this.estado = this.existenDatos.fields.Status.value;
        }     
    };

    @wire(getPretensiones, { idCaso: '$recordId'}) 
    pretension({ error, data }) {
        this.pretensiones = data;
        if(this.pretensiones) {
            let casos = [];
            this.pretensiones.forEach(pretensionRecuperada => {
                let pretension = {};
                pretension.Id = pretensionRecuperada.Id;
                pretension.CC_MCC_Tematica = pretensionRecuperada.CC_MCC_Tematica__r.Name;
                pretension.CC_MCC_ProdServ = pretensionRecuperada.CC_MCC_ProdServ__r.Name;
                pretension.CC_MCC_Motivo = pretensionRecuperada.CC_MCC_Motivo__r.Name;
                pretension.SEG_Detalle = pretensionRecuperada.SEG_Detalle__r.Name;
                casos.push(pretension);
            });
            this.pretensiones = casos;
            this.numPretensiones = this.pretensiones.length;
        } 
        else if (error) {
            this.error = error;
            this.pretensiones = undefined;
        }
    };

    resolver(){
        if(this.reclamanteConforme === false) {
            this.isLoading = false;
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Fallo al actualizar',
                    message: 'Debe marcar el campo reclamante conforme para negociación antes de pasar a la negociación.',
                    variant: 'error'
                })
            );
        } else if (this.antecedentesRevisados === false) {
            this.isLoading = false;
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Fallo al actualizar',
                    message: 'Debe refrescar los antecedentes y marcar el check Antecedentes Revisados Negociacion antes de pasar a la negociación.',
                    variant: 'error'
                })
            ); 
        } else {
            if(this.numPretensiones > 1) {
                this.isModalOpenPretensiones = true;    
            } else {
                this.isLoading = true;
                // Llamada a la función para negociar la unipretension
                finalizarRedaccionNegociacion({idCaso: this.recordId, envioMail: this.checkMail, pretensionesNegociacion: this.pretensiones}).then(result =>{
                    this.isLoading = false;
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Estado actualizado',
                            message: 'Se ha resuelto la reclamación y pasado a la fase de negociación',
                            variant: 'success'
                        })
                    );
                    
                    this.dispatchEvent(new RefreshEvent());
                })
                .catch(error => {
                    this.isLoading = false;
                    this.errorMsg = error;
        
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Fallo al actualizar',
                            message: error.body.message,
                            variant: 'error'
                        })
                    );
                }) 
            }
        }
    }

    handleRowSelection() {
    var selectedRecords =  this.template.querySelector("lightning-datatable").getSelectedRows();
        if(selectedRecords.length > 0){
            this.mostrarBoton = false;
            this.lstSelectedRecords = selectedRecords;
        } else {
            this.mostrarBoton = true;
        }  
    }

    resolverPretensiones() {
        this.isLoading = true;
        finalizarRedaccionNegociacion({idCaso: this.recordId, envioMail: this.checkMail, pretensionesNegociacion: this.lstSelectedRecords}).then(result =>{
            this.isLoading = false;
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Estado actualizado',
                    message: 'Se ha resuelto la reclamación y pasado a la fase de negociación',
                    variant: 'success'
                })
            );
            
            this.dispatchEvent(new RefreshEvent());
            this.isModalOpenPretensiones = false;
        })
        .catch(error => {
            this.isLoading = false;
            this.isModalOpenPretensiones = false;
            this.errorMsg = error;

            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Fallo al actualizar',
                    message: error.body.message,
                    variant: 'error'
                })
            );
        }) 
    }

    closeModalPretensiones(){
        this.isModalOpenPretensiones = false;
    }
}