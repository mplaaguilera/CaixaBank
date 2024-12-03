import { LightningElement, wire, api, track } from 'lwc';
import getProcesos from '@salesforce/apex/SIR_LCMP_arbolEstrategiasProceso.getProcesos';
import {loadStyle} from 'lightning/platformResourceLoader';
import recursoCSS from '@salesforce/resourceUrl/SIR_lightningTreeGrid';

const COLUMNS = [
    { type: 'url', fieldName: 'idProceso', label: 'Proceso',
        typeAttributes: {
            label: { fieldName: 'name' }
        },initialWidth: 210 },    
    { type: 'date', fieldName: 'fechaInicio', label: 'Fecha Inicio' }, //Inicio en Estrategia o Inicio Proceso Refi 
    { type: 'date', fieldName: 'fechaFin', label: 'Fecha Fin' }, // Estrategia
    { type: 'text', fieldName: 'estrategia', label: 'Estrategia' },
    { type: 'text', fieldName: 'situacion', label: 'Situación' },
    { type: 'date', fieldName: 'fechaSituacion', label: 'Fecha Situación' },
    { type: 'text', fieldName:'alertaSirec', label: 'Alerta SIREC'}, //PRUEBAS AÑADIR CAMPO ALERTASIREC
    { type: 'text', fieldName: 'gestor', label: 'Gestor' }   
];

export default class Sir_lwc_arbolEstrategiasProceso extends LightningElement {    
    @api recordId;
    gridColumns = COLUMNS;  
    @track procesos; 
    @track titulo;   
    
    
    @wire(getProcesos, {idCliente: '$recordId'})
    getProcesos({error, data}) { 
        if(data){
            this.titulo = 'Procesos del ciclo activo (' + data.length + ')';
            var res = data;
            var tempjson = JSON.parse(JSON.stringify(data).split('items').join('_children'));
            this.procesos = tempjson;
            loadStyle(this, recursoCSS);
        }  
    }
    

}