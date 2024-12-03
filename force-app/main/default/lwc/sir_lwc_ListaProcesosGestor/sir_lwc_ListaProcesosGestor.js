import { LightningElement, wire, api, track } from 'lwc';
import getProcesos from '@salesforce/apex/SIR_LCMP_ListaProcesosGestor.getProcesos';
import getURL from '@salesforce/apex/SIR_LCMP_ListaProcesosGestor.getURL';

const columns = [
    {label: 'CLIENTE', 
    fieldName: 'ClienteURL', 
    type: 'url', 
    typeAttributes: {label: { fieldName: 'Cliente' }}
    }, 
    {label: 'PROCESO', fieldName: 'Name', type: 'text'},
    {label: 'ESTRATEGIA', fieldName: 'SIREC__SIREC_fld_descEstrategiaCatalogo__c', type: 'text'},
    {label: 'SITUACIÓN', fieldName: 'SIR_fld_Situacion_SF__c', type: 'text'},
    {label: 'FECHA SITUACIÓN', fieldName: 'SIREC__SIREC_fld_fechaSituacion__c', type: 'date'},   
    {label: 'FECHA INICIO', fieldName: 'SIREC__SIREC_fld_fechaInicio__c', type: 'date'}    
];

export default class Sir_lwc_ListaProcesosGestor extends LightningElement {
    columns = columns;    
    @api recordId;
    @track procesos;
    @track tituloTabla;

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
                rowData.SIR_fld_Situacion_SF__c = data[i].SIR_fld_Situacion_SF__c;
                rowData.SIREC__SIREC_fld_fechaSituacion__c = data[i].SIREC__SIREC_fld_fechaSituacion__c;
                currentData.push(rowData);
            }         
            this.procesos = currentData;
            this.tituloTabla = 'Soluciones – Gestión Impago (1-90) (' +  data.length + ')';          
        }                 
    }

    goToCliente(){
        getURL({}).then(result => {            
          //  window.open(result, "_blank"); www.google.com/_vmcNewTab=true 
            window.open(result); 
        });
    }
}