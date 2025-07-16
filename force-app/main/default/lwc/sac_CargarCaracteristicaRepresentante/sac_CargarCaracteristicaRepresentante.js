import { LightningElement, track, api, wire } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { refreshApex } from '@salesforce/apex';
import { RefreshEvent } from 'lightning/refresh';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getPicklistValues } from "lightning/uiObjectInfoApi";
import PICKLIST_DESPACHOS from '@salesforce/schema/Case.SAC_DespachoRepresentante__c'
import getAsignacionesCaracteristica from '@salesforce/apex/SAC_LCMP_CargarCaractRepresentante.getAsignacionesByCaractId';
import deleteAsignacion from '@salesforce/apex/SAC_LCMP_CargarCaractRepresentante.eliminarAsignacion';
import updateAsignacion from '@salesforce/apex/SAC_LCMP_CargarCaractRepresentante.actualizarAsignacion';
import newAsignacion from '@salesforce/apex/SAC_LCMP_CargarCaractRepresentante.crearAsignacion';
import obtenerValoresDespachoRepresentante from '@salesforce/apex/SAC_LCMP_CargarCaractRepresentante.obtenerValoresDespachoRepresentante';

const actions = [
    { label: 'Edit', name: 'show_edit' },
    { label: 'Delete', name: 'delete' }
];

const columns = [
    { label: 'Identificador', fieldName: 'SAC_Identificador__c', type: 'text', initialWidth: '100px',sortable: true },
    {
        type: 'action',
        typeAttributes: { rowActions: actions }
    }
];

export default class Sac_CargarCaracteristicaRepresentante extends NavigationMixin(LightningElement) {

    @api recordId;
    @api cargaMasiva; 
    sortedBy;
    sortedDirection;
    error;
    @track asignaciones;
    @track wiredAasignacionesResult;
    @track tituloTabla;
    @track picklistDespachoValues;
    @track spinnerLoading = false;
    @track modalEditar = false;
    @track modalNuevaAsignacion = false;
    @track mostrarCif = false;
    @track mostrarDespacho = false;
    @track valorAsignacion = '';
    @track idAsignacion = '';

    get columns() {
        return columns;
    }

    get primerPasoCreacion() {

        if(this.mostrarCif === false && this.mostrarDespacho === false){
            return true;
        }else{
            return false;
        }
    }

    @wire(getAsignacionesCaracteristica, { recordId: '$recordId' })
    wiredAasignacionesResult(result) {
        this.wiredAasignacionesResult = result;
        if (result.data) {
            this.asignaciones = result.data;
            this.error = undefined;
            this.tituloTabla = 'Asignaciones (' +  this.asignaciones.length + ')';
        } else if (result.error) {
            this.error = result.error;
            this.asignaciones = undefined;
        }
    }

    /*@wire(getPicklistValues, { recordTypeId: '012000000000000AAA', fieldApiName: PICKLIST_DESPACHOS })
    valoresPicklistDespachoRepresentante({data}) {
        if (data) {
            this.picklistDespachoValues = data.values;
        }
    }*/

    @wire(obtenerValoresDespachoRepresentante)
    wiredDespachosRepresentantes(result){
        if(result.data){
            this.picklistDespachoValues = result.data.map(item => ({
                label: item,
                value: item
            }));
        }
    }

    handleChangeDespacho(event){
        const selectedValue = event.detail.value;
        const selectedOption = this.picklistDespachoValues.find(option => option.value === selectedValue);
        this.valorAsignacion = selectedOption.label;

    }


    renderedCallback() {
        if (this.cargaMasiva) {
            this.handleRefreshClick();
        }
    }

    handleSortData(event) {
        const fieldName = event.detail.fieldName;
        const sortDirection = event.detail.sortDirection
        const cloneData = [...this.asignaciones];

        cloneData.sort(this.sortBy(fieldName, sortDirection === 'asc' ? 1 : -1));
        this.asignaciones = cloneData;
        this.sortedBy = fieldName;
        this.sortedDirection = sortDirection;
    }

    sortBy(field, reverse, primer) {
        const key = primer
            ? function (x) {
                  return primer(x[field]);
              }
            : function (x) {
                  return x[field];
              };
    
        return function (a, b) {
            const valueA = key(a);
            const valueB = key(b);
    
            if (typeof valueA === 'boolean' && typeof valueB === 'boolean') {
                return reverse * (valueA === valueB ? 0 : (valueA ? -1 : 1));
            }
    
            const A = valueA ? valueA.toString().toUpperCase() : '';
            const B = valueB ? valueB.toString().toUpperCase() : '';
            let comparison = 0;
    
            if (A > B) {
                comparison = 1;
            } else if (A < B) {
                comparison = -1;
            }
            return reverse * comparison;
        };
    }

    handleRowAction(event) {
        const actionName = event.detail.action.name;
        const row = event.detail.row;

        switch (actionName) {
            case 'show_edit':
                this.editRow(row);
                break;
            case 'delete':
                this.deleteRow(row);
                break;
            default:
        }
    }

    editRow(row) {
        this.modalEditar = true;
        this.valorAsignacion = row.SAC_Identificador__c;
        this.idAsignacion = row.Id;
    }

    cerrarModalEditar(){
        this.modalEditar = false;
    }

    changeIdentificador(event) {
        this.valorAsignacion = event.target.value;
    }

    handleEditarIdentificador(){
        if(this.valorAsignacion === '' || this.valorAsignacion === undefined){
            this.lanzarToast('Advertencia', 'No puede guardar un identificador en blanco.', 'warning');
        }else{
            this.modalEditar = false;
            this.spinnerLoading = true;

            updateAsignacion( { 'asignacionId': this.idAsignacion, 'nuevoValor': this.valorAsignacion } ).then(() => {
                this.spinnerLoading = false;
                this.valorAsignacion = '';
                this.lanzarToast('Éxito', 'Asignación actualizada correctamente.', 'success');
                this.handleRefreshClick();
            })
            .catch(error => {
                this.lanzarToast('Error', 'Error al actualizar la asignación.', 'error');
            });
        }
    }

    deleteRow(row) {
        this.spinnerLoading = true;
        const asignacionId = row.Id;

        deleteAsignacion( {asignacionId} ).then(() => {
            this.spinnerLoading = false;
            this.lanzarToast('Éxito', 'Asignación eliminada correctamente.', 'success');
            this.handleRefreshClick();
        })
        .catch(error => {
            this.lanzarToast('Error', 'Error al eliminar la asignación.', 'error');
        });
    }    

    handleNuevaAsignacion(){
        this.modalNuevaAsignacion = true;
    }

    cerrarModalNuevaAsignacion(){
        this.modalNuevaAsignacion = false;
        this.mostrarCif = false;
        this.mostrarDespacho = false;
    }

    volverPasoUno(){
        this.valorAsignacion = '';
        this.mostrarCif = false;
        this.mostrarDespacho = false;
    }

    onclickCif(){
        this.mostrarCif = true;
    }

    changeCif(event){
        this.valorAsignacion = event.target.value;
    }

    onclickDespacho(){
        this.mostrarDespacho = true;
    }



    handleCrearAsignacion(){
        if(this.valorAsignacion === '' || this.valorAsignacion === undefined){
            this.lanzarToast('Advertencia', 'No puede insertar un identificador en blanco.', 'warning');
        }else{
            this.modalNuevaAsignacion = false;
            this.spinnerLoading = true;

            newAsignacion( { 'recordId': this.recordId, 'identificadorAsignacion': this.valorAsignacion } ).then(() => {
                this.spinnerLoading = false;
                this.mostrarCif = false;
                this.mostrarDespacho = false;
                this.valorAsignacion = '';
                this.lanzarToast('Éxito', 'Asignación insertada correctamente.', 'success');
                this.handleRefreshClick();
            })
            .catch(error => {
                this.lanzarToast('Error', 'Error al insertar la asignación.', 'error');
            });
        }
    }

    lanzarToast(titulo, mensaje, variante) {
        const toastEvent = new ShowToastEvent({
            title: titulo,
            message: mensaje,
            variant: variante
        });
        this.dispatchEvent(toastEvent);
    }

    handleRefreshClick() {
        return refreshApex(this.wiredAasignacionesResult);
    }

    refreshView() {
        this.dispatchEvent(new RefreshEvent());
    }
}