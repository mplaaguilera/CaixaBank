import { LightningElement, wire, api, track } from 'lwc';
import getProcesos from '@salesforce/apex/SIR_LCMP_ListaProcesosClientePRESOL.getProcesos';
import getURL from '@salesforce/apex/SIR_LCMP_ListaProcesosClientePRESOL.getURL';

const columns = [
    {label: 'PROCESO', fieldName: 'Name', type: 'text'},
    {label: 'ESTRATEGIA', fieldName: 'SIREC__SIREC_fld_estrategia__c', type: 'text'},
    {label: 'SITUACIÓN', fieldName: 'SIREC__SIREC_fld_situacion__c', type: 'text'},
    {label: 'FECHA SITUACIÓN', fieldName: 'SIREC__SIREC_fld_fechaSituacion__c', type: 'date'}, 
    {label: 'FECHA INICIO', fieldName: 'SIREC__SIREC_fld_fechaInicio__c', type: 'date'},    
];

export default class Sir_lwc_ListaProcesosClientePRESOL extends LightningElement {
    columns = columns;    
    @api recordId;
    @track procesos;
    @track tituloTabla;
    @track visible;

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
            this.tituloTabla = 'PRESOL - Preventivo Activos (' +  data.length + ')'; 
            if(data.length == 0){
                this.visible = false;
            } else {
                this.visible = true;
            }
        }                 
    }


    goToCliente(){
        getURL({idCliente: this.recordId}).then(result => {            
            window.open(result);
        });
    }

}