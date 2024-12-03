import { LightningElement, wire, api, track } from 'lwc';
import getProcesos from '@salesforce/apex/SIRE_LCMP_procesosActivosGrupoEconomico.getProcesos';
import {loadStyle} from 'lightning/platformResourceLoader';
import recursoCSS from '@salesforce/resourceUrl/SIR_lightningTreeGrid';

const COLUMNS = [
    {label: 'Empresa',  fieldName: 'idEmpresa',  type: 'url',  typeAttributes: {label: { fieldName: 'nombreEmpresa' }} },
    {label: 'Tipo Proceso', fieldName: 'tipoProceso', type: 'text', initialWidth: 130}, 
    {label: 'Estrategia',  fieldName: 'idProceso',  type: 'url',  typeAttributes: {label: { fieldName: 'estrategia' }} }, 
    {label: 'Fecha Inicio', fieldName: 'fechaInicio', type: 'date', initialWidth: 112},   
    {label: 'Fecha Situación', fieldName: 'fechaSituacion', type: 'date', initialWidth: 136},
    {label: 'Situación', fieldName: 'situacion', type: 'text'},   
    {label: 'Deuda Total', fieldName: 'deudaTotal', type: 'currency', initialWidth: 120},     
    {label: 'Máx. nº días impago', fieldName: 'diasImpago', type: 'number', initialWidth: 166},   
    {label: 'Gestor', fieldName: 'gestor', type: 'text'},   
    {label: 'Propuesta', fieldName: 'propuesta', type: 'text'},
    {label: 'Aplica Grupo', fieldName: 'propuestaNivelGrupo', type: 'text', initialWidth: 120}  
];

export default class Sire_lwc_procesosActivosGrupoEconomico extends LightningElement {  
    @api recordId;
    gridColumns = COLUMNS;  
    @track procesos; 
    @track titulo = 'Procesos Activos'  
    
    @wire(getProcesos, {idCliente: '$recordId'})
    getProcesos({error, data}) { 
        if(data){
            var totalProcesos = 0;
            for(var i=0; i < data.length; i++){   
                totalProcesos = totalProcesos + data[i].items.length;
            }
            this.titulo = 'Procesos Activos (' + totalProcesos + ')';
            var tempjson = JSON.parse(JSON.stringify(data).split('items').join('_children'));
            this.procesos = tempjson;           
            loadStyle(this, recursoCSS);                   
        }
    } 

    renderedCallback(){        
        if(this.procesos != undefined){
            const gridInicial = this.template.querySelector('lightning-tree-grid');           
            gridInicial.expandAll();  
        }        
    }
    
    clickToExpandAll(e) {
        const grid = this.template.querySelector('lightning-tree-grid');
        grid.expandAll();
    }

    clickToCollapseAll(e) {
        const grid = this.template.querySelector('lightning-tree-grid');
        grid.collapseAll();
    }

}