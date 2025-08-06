import { LightningElement, wire, api, track } from 'lwc';
import getProcesos from '@salesforce/apex/SIRE_LCMP_ListaProcesosGestorPreventivo.getProcesos';
import getURL from '@salesforce/apex/SIRE_LCMP_ListaProcesosGestorPreventivo.getURL';

import titulo from '@salesforce/label/c.SIRE_TituloPreventivo';
import cliente from '@salesforce/label/c.SIRE_Cliente';
import proceso from '@salesforce/label/c.SIRE_Proceso';
import estrategia from '@salesforce/label/c.SIRE_Estrategia';
import situacion from '@salesforce/label/c.SIRE_Situacion';
import fechaSituacion from '@salesforce/label/c.SIRE_FechaSituacion';
import fechaInicio from '@salesforce/label/c.SIRE_FechaInicio';
import boton from '@salesforce/label/c.SIRE_MisClientesSolucionesEmpresas';

export default class Sire_lwc_ListaProcesosGestorPreventivo extends LightningElement {
    labels = { titulo, cliente, proceso, estrategia, situacion, fechaSituacion, fechaInicio, boton };
    columns = [
        {label: this.labels.cliente, fieldName: 'ClienteURL', type: 'url', typeAttributes: {label: { fieldName: 'Cliente' }} }, 
        {label: this.labels.proceso, fieldName: 'Name', type: 'text'},
        {label: this.labels.estrategia, fieldName: 'SIREC__SIREC_fld_descEstrategiaCatalogo__c', type: 'text'},
        {label: this.labels.situacion, fieldName: 'SIREC__SIREC_fld_situacion__c', type: 'text'},
        {label: this.labels.fechaSituacion, fieldName: 'SIREC__SIREC_fld_fechaSituacion__c', type: 'date'},   
        {label: this.labels.fechaInicio, fieldName: 'SIREC__SIREC_fld_fechaInicio__c', type: 'date'}    
    ];    
    @api recordId;
    @track procesos;
    @track tituloTabla;
    @track boton = this.labels.boton;

    @wire(getProcesos, {})
    getProcesos({ error, data }) { 
        if(data){
            let currentData = [];
            for (var i = 0; i < 10 && i < data.length; i++) {
                let rowData = {};
                
                if (data[i].SIREC__SIREC_fld_cliente__c) {
                    if (data[i].SIREC__SIREC_fld_cliente__r.Name) {
                        rowData.Cliente = data[i].SIREC__SIREC_fld_cliente__r.Name;
                        rowData.ClienteURL = '/lightning/r/Account/' +data[i].SIREC__SIREC_fld_cliente__r.Id+'/view';
                    }
                }

                rowData.Name = data[i].Name;
                rowData.SIREC__SIREC_fld_descEstrategiaCatalogo__c = data[i].SIREC__SIREC_fld_descEstrategiaCatalogo__c;
                rowData.SIREC__SIREC_fld_fechaInicio__c = data[i].SIREC__SIREC_fld_fechaInicio__c;
                rowData.SIREC__SIREC_fld_situacion__c = data[i].SIREC__SIREC_fld_situacion__c;
                rowData.SIREC__SIREC_fld_fechaSituacion__c = data[i].SIREC__SIREC_fld_fechaSituacion__c;
                currentData.push(rowData);
            }         
            this.procesos = currentData;
            this.tituloTabla = this.labels.titulo + ' (' +  data.length + ')';          
        }                 
    }

    goToCliente(){
        getURL({}).then(result => {   
            window.open(result); 
        });
    }
}