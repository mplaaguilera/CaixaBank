import { LightningElement, api, track, wire } from 'lwc';
import { getRecord, getFieldValue, updateRecord } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { RefreshEvent } from 'lightning/refresh';
import { refreshApex } from '@salesforce/apex';

//Llamadas Apex
import getPretensiones from '@salesforce/apex/SPV_LCMP_CamposNegociacion.getPretensiones';
import addPretensionesNegociacionReclamacion from '@salesforce/apex/SPV_LCMP_CamposNegociacion.addPretensionesNegociacionReclamacion';
import activarNegociacionPretension from '@salesforce/apex/SPV_LCMP_CamposNegociacion.activarNegociacionPretension';
import eliminarPretensionNegociacion from '@salesforce/apex/SPV_LCMP_CamposNegociacion.eliminarPretensionNegociacion';

const columns = [
    { label: 'Temática', fieldName: 'CC_MCC_Tematica' }, 
    { label: 'Producto/Servicio', fieldName: 'CC_MCC_ProdServ'},
    { label: 'Motivo', fieldName: 'CC_MCC_Motivo'},
    { label: 'Detalle', fieldName: 'SEG_Detalle'}
];

const FIELDS = ['Case.SAC_CasoNegociado__c', 'Case.CBK_Case_Extension_Id__r.SPV_CasoEnNegociacion__c'];

export default class Spv_CamposNegociacion extends LightningElement {
    @api recordId;
    @api objectApiName;

    @track spinnerLoading = false;
    @track isLoading = false;
    @track pretensiones = [];
    @track editarCampos = false; //Se pone a true cuando quiere que los campos se muestren en modo formulario
    @track pretensionEliminar = ''; 
    @track casoEnNegociacion = false;
    @track unicaPretension = false; // Indica que es la única pretensión en negociación por lo que no se puede eliminar

    @track modalAddPretension = false;
    @track modalEliminarPretension = false;
    @track mostrarBotonSeleccionPretensiones = true;

    pretensionesAdd = [];
    columns = columns;
    lstSelectedRecords = [];
    wiredPretensionesList;

    @wire(getRecord, { recordId: '$recordId', fields: FIELDS })
    wiredGetRecord({data, error}){
        if(data){
            refreshApex(this.wiredPretensionesList);
            this.casoEnNegociacion = data.fields.CBK_Case_Extension_Id__r.value.fields.SPV_CasoEnNegociacion__c.value;
        }
    }

    @wire(getPretensiones, { casoId: '$recordId'})
    getPretensiones(result){
        this.wiredPretensionesList = result; 
        
        if(result.data){
            this.pretensiones = result.data;
            if(this.pretensiones.length == 1) {
                this.unicaPretension = true;
            } else {
                this.unicaPretension = false;
            }
        }
    } 

    handleEditarCampos(event){
        if(this.editarCampos == false){
            this.editarCampos = true;
        }else{
            this.editarCampos = false;
        } 
    }

    handleSuccessEditar(event){
        const updatedRecord = event.detail.id;
        this.lanzarToast('Éxito', 'Se han actualizado campos correctamente.', 'success');

        this.editarCampos = false;  //Se cierran los campos de modo edición
        this.spinnerLoading = false;
    }

    handleSubmit(event) {
        this.spinnerLoading = true;
        const fields = event.detail.fields;

        this.template.querySelectorAll('lightning-record-edit-form').forEach((form) => {form.submit()});
    }


    onClickAnadirPretensiones(){
        addPretensionesNegociacionReclamacion({'idCaso': this.recordId})
        .then(data=>{
            this.pretensionesAdd = data;

            if(!this.pretensionesAdd.length) {
                this.lanzarToast('Error', 'No hay pretensiones disponibles para añadir a la reclamación.', 'warning');
            } else if(this.pretensionesAdd) {
                let casos = [];
                this.pretensionesAdd.forEach(pretensionRecuperada => {
                    let pretension = {};
                    pretension.Id = pretensionRecuperada.Id;
                    pretension.CC_MCC_Tematica = pretensionRecuperada.CC_MCC_Tematica__r.Name;
                    pretension.CC_MCC_ProdServ = pretensionRecuperada.CC_MCC_ProdServ__r.Name;
                    pretension.CC_MCC_Motivo = pretensionRecuperada.CC_MCC_Motivo__r.Name;
                    pretension.SEG_Detalle = pretensionRecuperada.SEG_Detalle__r.Name;
                    casos.push(pretension);
                });
                this.pretensionesAdd = casos;
                
                this.modalAddPretension = true;
            }
        })
        .catch(error => {
            this.isLoading = false;
            this.lanzarToast('Error', this.extractErrorMessage(error), 'error');
        }); 
        this.refreshView();
    }

    handleRowSelection() {
        var selectedRecords =  this.template.querySelector("lightning-datatable").getSelectedRows();
        if(selectedRecords.length > 0){
            this.mostrarBotonSeleccionPretensiones = false;
            this.lstSelectedRecords = selectedRecords;
        } else {
            this.mostrarBotonSeleccionPretensiones = true;
        }  
    }

    closeModalAddPretension(){
        this.mostrarBotonSeleccionPretensiones = true;
        this.modalAddPretension = false;
    }

    negociarPretensiones() {
        this.isLoading = true;
		activarNegociacionPretension({'caseId': this.recordId, 'pretensionesNegociacion': this.lstSelectedRecords}).then(() =>{
            this.isLoading = false;
            this.modalAddPretension = false;
            refreshApex(this.wiredPretensionesList);
            this.refreshView();
            this.lanzarToast('Éxito!', 'La pretensión ha sido añadida a la negociación', 'success');   
        })
        .catch(error => {
            this.modalAddPretension = false;
            this.isLoading = false;
            this.lanzarToast('Error', 'Error al añadir la pretensión a la negociación: ' + this.extractErrorMessage(error), 'error');
        });
    }

    onClickEliminarPretension(event){
        this.modalEliminarPretension = true;
        var pretensionId = event.target.dataset.id;
        this.pretensionEliminar = pretensionId;
    }

    eliminarPretension(){
        this.spinnerLoading = true;

        eliminarPretensionNegociacion({'caseId': this.pretensionEliminar}).then(()=>{
            this.spinnerLoading = false;
            this.modalEliminarPretension = false;
            refreshApex(this.wiredPretensionesList);
            this.refreshView();
            this.lanzarToast('Éxito!', 'La pretensión ha sido eliminada de la negociación', 'success');         
        }).catch(error =>{
            this.spinnerLoading = false;
            this.modalEliminarPretension = false;
            this.lanzarToast('Error', 'Error al eliminar la pretensión de la negociación: ' + this.extractErrorMessage(error), 'error');
        });

    }

    closeModalEliminarPretension(){
        this.modalEliminarPretension = false;
    }

    lanzarToast(titulo, mensaje, variante) {
        const toastEvent = new ShowToastEvent({
            title: titulo,
            message: mensaje,
            variant: variante
        });
        this.dispatchEvent(toastEvent);
    }

    // Método para extraer el mensaje de error de la regla de validación
    extractErrorMessage(error) {
        if (error.body && error.body.message) {
            return error.body.message;
        } else if (error.body && error.body.pageErrors && error.body.pageErrors.length > 0) {
            return error.body.pageErrors[0].message;
        } else {
            return 'Error desconocido';
        }
    }

    refreshView() {
        this.dispatchEvent(new RefreshEvent());
    }
}