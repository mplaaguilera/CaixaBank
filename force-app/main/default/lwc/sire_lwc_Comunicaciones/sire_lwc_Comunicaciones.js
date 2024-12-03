import { LightningElement, track, wire, api } from 'lwc';
import getComunicaciones from '@salesforce/apex/SIRE_LCMP_Comunicaciones.getComunicaciones';
/* Inicio Modificacion HSC 04/10/2022 -- US424115 */
import getQueryAcciones from '@salesforce/apex/SIRE_LCMP_Comunicaciones.getQueryAcciones';
import getQueryReports from '@salesforce/apex/SIRE_LCMP_Comunicaciones.getQueryReports';
import {refreshApex} from '@salesforce/apex';
import { CurrentPageReference } from 'lightning/navigation';

const columnsAcciones = [
  {label: 'Cliente',  fieldName: 'idCliente',  type: 'url',  typeAttributes: {label: { fieldName: 'cliente' }}, sortable: true }, 
  {label: 'Tipo', fieldName: 'idAccion', type: 'url', typeAttributes: {label: { fieldName: 'tipo' }}, sortable: true},
  {label: 'Estrategia',  fieldName: 'idProceso',  type: 'url',  typeAttributes: {label: { fieldName: 'estrategia' }}, sortable: true }, 
  {label: 'Situación', fieldName: 'situacion', type: 'text', sortable: true}
];
/* Fin Modificacion HSC 04/10/2022 -- US424115 */

export default class Sire_lwc_Comunicaciones extends LightningElement {
    //@track visible = false;
    @track notificacionesVisible = false;
    @track comunicaciones;
    /* Inicio Modificacion HSC 04/10/2022 -- US424115 */
    @track columnsAcciones = columnsAcciones;
    @track acciones;
    @track informeAccionesHoy;
    @track preventivo;

    @track defaultSortDirection = 'asc';
    @track sortDirection = 'asc';
    @track sortedBy;

    @track pageRef;
    @track numAcc;
    @track showTable = false;

    @track wiredResultAccion = [];

    @api
    refreshCmp() { 
      // Ponemos un setTimeout (hace esperar los milisegundos que ponga antes de ejecutar lo de dentro) porque iba demasiado rapido y no daba tiempo a cargar URL     
      setTimeout(() => { 
        refreshApex(this.wiredResultAccion);
        this.getQueries(); 
      }, 100);      
    }

    @wire(CurrentPageReference)
    setCurrentPageReference(currentPageReference) {
        refreshApex(this.wiredResultAccion);
    }

    /* Fin Modificacion HSC 04/10/2022 -- US424115 */
    @wire(getComunicaciones, {})
    getComunicaciones({error, data}) { 
        if(data){          
            this.comunicaciones = data;
           // this.visible = true;
        }     
    }

    @wire(getQueryAcciones, {
        url: (window.location).toString()
    })wiredData(result) {
        this.wiredResultAccion = result;
        if(result.data){ 
            let currentData = [];
            this.numAcc = result.data.length;
            if(this.numAcc > 0){
                this.showTable = true;
            } else {
                this.showTable = false;
            }
            let url = (window.location).toString();
            if (url.includes('SIRE_Inicio_Preventivo')) {
                this.preventivo = true;
            }else{
                this.preventivo = false;
            }
            for(let i = 0; i < result.data.length; i++){            
                // Calculamos las Acciones              
                let rowData = {};
                if(result.data[i].SIREC__SIREC_fld_interviniente__c != null){
                    rowData.idCliente = '/lightning/r/Account/' + result.data[i].SIREC__SIREC_fld_interviniente__c + '/view';
                    rowData.cliente = result.data[i].SIREC__SIREC_fld_interviniente__r.Name;
                }             
                rowData.tipo = result.data[i].SIREC__SIREC_fld_tipo__c;                   
                rowData.idAccion = '/lightning/r/SIREC__SIREC_obj_acciones__c/' + result.data[i].Id + '/view';            
                if(result.data[i].SIREC__SIREC_fld_proceso__c != null){
                rowData.situacion = result.data[i].SIREC__SIREC_fld_proceso__r.SIR_fld_Situacion_SF__c;
                rowData.idProceso = '/lightning/r/SIREC__SIREC_obj_proceso__c/' + result.data[i].SIREC__SIREC_fld_proceso__r.Id + '/view';
                rowData.estrategia = result.data[i].SIREC__SIREC_fld_proceso__r.SIREC__SIREC_fld_estrategia__c;
                }              
                currentData.push(rowData);            
            }
            // Ponemos los resultados de procesos ya iniciados en la variable de front
            this.acciones = currentData;
            // Ordenamos por el campo situacion
            let cloneData = [...this.acciones];
            cloneData.sort(this.sortBy('situacion', -1, undefined));
            this.acciones = cloneData;
            this.sortDirection = 'desc';
            this.sortedBy = 'situacion';
            
            // Query para traernos los ID's de los reports para que puedan ver el informe entero
            getQueryReports({url: (window.location).toString()}).then(result => {           
                let resultQueryReport = result;
                if(resultQueryReport.length !== 0){
                    this.informeAccionesHoy =  '/lightning/r/Report/' +  resultQueryReport[0].Id + '/view'; 
                }                         
            }); 
        }     
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
        a = key(a);
        b = key(b);
        return reverse * ((a > b) - (b > a));
    };        
  }
  onHandleSort(event) {
      const { fieldName: sortedBy, sortDirection } = event.detail;
      const cloneData = [...this.acciones];
      cloneData.sort(this.sortBy(sortedBy, sortDirection === 'asc' ? 1 : -1));
      this.acciones = cloneData;
      this.sortDirection = sortDirection;
      this.sortedBy = sortedBy;
  }
  /* Fin Modificacion HSC 04/10/2022 -- US424115 */
}