import {LightningElement, api, track, wire} from 'lwc';
//import getCitas from '@salesforce/apex/CC_Cancelar_Cita_Controller.getCitas';
import {ShowToastEvent} from 'lightning/platformShowToastEvent';
import getDatos from '@salesforce/apex/CC_Operativa_Oficina_Controller.getDatos';

const COLUMNS = [
    {label: 'Fecha', fieldName: 'CreatedDate', type: 'date', sortable: true, initialWidth: 138,
    typeAttributes: {day: 'numeric', month: 'numeric', year: 'numeric', hour: '2-digit', minute: '2-digit', hour12: false}},
    {label: 'Caso', type: 'url', fieldName: '_url', initialWidth: 96,
    typeAttributes: {label: {fieldName: 'CaseNumber'}, tooltip: 'Ver detalle'}},
    {label: 'Asunto', fieldName: 'Subject'},
    {label: 'Tipo', fieldName: '_recordTypeName', initialWidth: 110},
    {label: 'Email del contacto', type: 'email', fieldName: '_contactEmail'}
];

export default class Cc_Cancelar_Cita extends LightningElement {
    @api recordId;
    
    datatableColumns = COLUMNS;
    datatableData = [];
    mostrarModal = false;
    fechasBusqueda = {
        desde: new Date().toISOString(),
        hasta: new Date().toISOString()
    };
    spinner = true;
    
    /*@wire(getCitas, {recordId: '$recordId'})
    wiredDatos({error, data}) {
        if (error) {
            console.error(error);
            this.toast('error', 'Problema recuperando los datos', error);
            this.cerrarModal();
        } else if (data) {
            this.datatableData = data;
            
        }
    }*/
    
    
    @wire(getDatos, {recordId: '$recordId'})
    wiredDatos({error, data}) {
        if (error) {
            console.error(error);
            this.toast('error', 'Problema recuperando los datos', error);
            this.cerrarModal();
        } else if (data) {
            console.log('abrir modal');
            this.abrirModal();
        }
    }
    
    buscarCitas() {
        this.spinner = true;
        this.fechasBusqueda = {
            desde: this.template.querySelector('lightning-input.inputFechaDesde').value,
            hasta: this.template.querySelector('lightning-input.inputFechaHasta').value
        };
        /*getCitasApex({
            idAgrupador: this.recordId,
            fechaInicio: this.fechasBusqueda.desde,
            fechaFin: this.fechasBusqueda.hasta,
            busquedaFechas: true
        })
        .then(casos => this.datatableData = this.formatDatatableData(casos))
        .catch(error => {
            console.error(error);
            this.toast('error', 'Problema recuperando los datos', error);
        }).finally(() => this.spinner = false);*/
    }
    
    abrirModal() {
        console.log('entra abrir modal');
        this.mostrarModal = true;
        this.template.querySelector('.modal').classList.add('slds-fade-in-open');
        this.template.querySelector('.backdrop').classList.add('slds-backdrop--open');
    }
    
    datatableOnrowselection(event) {
        this.datatableSelectedRows = event.detail.selectedRows;
    }
    
    modalTeclaPulsada(event) {
        if (event.keyCode === 27) { //ESC
            this.cerrarModal();
        }
    }
    
    cerrarModal() {
        this.template.querySelector('.backdrop').classList.remove('slds-backdrop--open');
        this.template.querySelector('.modal').classList.remove('slds-fade-in-open');
        //eslint-disable-next-line @lwc/lwc/no-async-operation
        window.setTimeout(() =>	this.dispatchEvent(new CustomEvent('modalcerrado', {detail: {data: null}})), 400);
    }
}