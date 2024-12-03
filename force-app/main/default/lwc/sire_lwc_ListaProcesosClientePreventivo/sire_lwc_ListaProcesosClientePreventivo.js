import { LightningElement, wire, api, track } from 'lwc';
import getProcesos from '@salesforce/apex/SIRE_LCMP_ListaProcesosClientePreventivo.getProcesos';
import getURL from '@salesforce/apex/SIRE_LCMP_ListaProcesosClientePreventivo.getURL';

import titulo from '@salesforce/label/c.SIRE_TituloClientePreventivo';
import proceso from '@salesforce/label/c.SIRE_Proceso';
import estrategia from '@salesforce/label/c.SIRE_Estrategia';
import situacion from '@salesforce/label/c.SIRE_Situacion';
import fechaSituacion from '@salesforce/label/c.SIRE_FechaSituacion';
import fechaInicio from '@salesforce/label/c.SIRE_FechaInicio';
import boton from '@salesforce/label/c.SIRE_MisClientesSolucionesEmpresas';

export default class Sire_lwc_ListaProcesosClientePreventivo extends LightningElement {
    
    labels = { titulo, proceso, estrategia, situacion, fechaSituacion, fechaInicio, boton };
    columns = [
        {label: this.labels.proceso, fieldName: 'Name', type: 'text'},
        {label: this.labels.estrategia, fieldName: 'SIREC__SIREC_fld_estrategia__c', type: 'text'},
        {label: this.labels.situacion, fieldName: 'SIREC__SIREC_fld_situacion__c', type: 'text'},
        {label: this.labels.fechaSituacion, fieldName: 'SIREC__SIREC_fld_fechaSituacion__c', type: 'date'}, 
        {label: this.labels.fechaInicio, fieldName: 'SIREC__SIREC_fld_fechaInicio__c', type: 'date'}    
    ];       
    @api recordId;
    @track procesos;
    @track tituloTabla;
    @track boton = this.labels.boton;

    @wire(getProcesos, { idCliente: '$recordId'})
    getProcesos({ error, data }) { 
        if(data){
            let currentData = [];
            data.forEach((row) => {
                let rowData = {};
                rowData.Name = row.Name;
                rowData.SIREC__SIREC_fld_estrategia__c = row.SIREC__SIREC_fld_estrategia__c;
                rowData.SIREC__SIREC_fld_situacion__c = row.SIREC__SIREC_fld_situacion__c;
                rowData.SIREC__SIREC_fld_fechaSituacion__c = row.SIREC__SIREC_fld_fechaSituacion__c;
                rowData.SIREC__SIREC_fld_fechaInicio__c = row.SIREC__SIREC_fld_fechaInicio__c;
                currentData.push(rowData);
            });
            this.procesos = currentData;
            this.tituloTabla = this.labels.titulo + ' (' +  data.length + ')'; 
        }                 
    }

    goToCliente(){
        getURL({idCliente: this.recordId}).then(result => {            
            window.open(result);
        });
    }
}