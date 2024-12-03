import { LightningElement, api, wire, track } from 'lwc';
import { CurrentPageReference } from 'lightning/navigation';
import getQueryRecordTypeProceso from '@salesforce/apex/SIRE_LCMP_HomeGestorPreventivo.getQueryRecordTypeProceso';
import getUsuarioLogeado from '@salesforce/apex/SIRE_LCMP_HomeGestorPreventivo.getUsuarioLogeado';
import getQueryProcesos from '@salesforce/apex/SIRE_LCMP_HomeGestorPreventivo.getQueryProcesos';
import getQueryReports from '@salesforce/apex/SIRE_LCMP_HomeGestorPreventivo.getQueryReports';
import { getPicklistValues } from 'lightning/uiObjectInfoApi';
import ESTRATEGIA_FIELD from '@salesforce/schema/SIREC__SIREC_obj_proceso__c.SIREC__SIREC_fld_estrategia__c';
import {refreshApex} from '@salesforce/apex';
import USER_ID from '@salesforce/user/Id';


const columnsProcesoPendienteRiesgosGestor = [
    {label: 'Cliente',  fieldName: 'idCliente',  type: 'url',  typeAttributes: {label: { fieldName: 'cliente' }}, sortable: true }, 
    {label: 'Grupo', fieldName: 'grupo', type: 'text', sortable: true},
    {label: 'Estrategia',  fieldName: 'idProceso',  type: 'url',  typeAttributes: {label: { fieldName: 'estrategia' }}, sortable: true },
    {label: 'Fecha Inicio', fieldName: 'fechaInicio', type: 'date', sortable: true, fixedWidth: 130},   
    {label: 'Fecha Situación', fieldName: 'fechaSituacion', type: 'date', sortable: true, fixedWidth: 155},
    {label: 'Propuesta Negocio', fieldName: 'propuestaNegocio', type: 'text', sortable: true},
    {label: 'Analista', fieldName: 'analista', type: 'text', sortable: true}, 
    {label: 'Deuda Total', fieldName: 'deudaTotal', type: 'currency', sortable: true, fixedWidth: 155},  
    {label: 'Rating', fieldName: 'rating', type: 'number', sortable: true}    
];
const columnsProcesoPendienteRiesgosAnalista = [
    {label: 'Cliente',  fieldName: 'idCliente',  type: 'url',  typeAttributes: {label: { fieldName: 'cliente' }}, sortable: true }, 
    {label: 'Grupo', fieldName: 'grupo', type: 'text', sortable: true},
    {label: 'Estrategia',  fieldName: 'idProceso',  type: 'url',  typeAttributes: {label: { fieldName: 'estrategia' }}, sortable: true },
    {label: 'Fecha Inicio', fieldName: 'fechaInicio', type: 'date', sortable: true, fixedWidth: 130},   
    {label: 'Fecha Situación', fieldName: 'fechaSituacion', type: 'date', sortable: true, fixedWidth: 155},
    {label: 'Propuesta Negocio', fieldName: 'propuestaNegocio', type: 'text', sortable: true},
    {label: 'Gestor', fieldName: 'gestor', type: 'text', sortable: true}, 
    {label: 'Deuda Total', fieldName: 'deudaTotal', type: 'currency', sortable: true, fixedWidth: 155},  
    {label: 'Rating', fieldName: 'rating', type: 'number', sortable: true}    
];

const columnsProcesoPendienteConsensoGestor = [
    {label: 'Cliente',  fieldName: 'idCliente',  type: 'url',  typeAttributes: {label: { fieldName: 'cliente' }}, sortable: true }, 
    {label: 'Grupo', fieldName: 'grupo', type: 'text', sortable: true},
    {label: 'Estrategia',  fieldName: 'idProceso',  type: 'url',  typeAttributes: {label: { fieldName: 'estrategia' }}, sortable: true },
    {label: 'Fecha Inicio', fieldName: 'fechaInicio', type: 'date', sortable: true, fixedWidth: 130},   
    {label: 'Fecha Situación', fieldName: 'fechaSituacion', type: 'date', sortable: true, fixedWidth: 155},
    {label: 'Propuesta Negocio', fieldName: 'propuestaNegocio', type: 'text', sortable: true},
    {label: 'Propuesta Riesgos', fieldName: 'propuestaRiesgos', type: 'text', sortable: true},
    {label: 'Analista', fieldName: 'analista', type: 'text', sortable: true}, 
    {label: 'Deuda Total', fieldName: 'deudaTotal', type: 'currency', sortable: true, fixedWidth: 155},  
    {label: 'Rating', fieldName: 'rating', type: 'number', sortable: true}    
];
const columnsProcesoPendienteConsensoAnalista = [
    {label: 'Cliente',  fieldName: 'idCliente',  type: 'url',  typeAttributes: {label: { fieldName: 'cliente' }}, sortable: true }, 
    {label: 'Grupo', fieldName: 'grupo', type: 'text', sortable: true},
    {label: 'Estrategia',  fieldName: 'idProceso',  type: 'url',  typeAttributes: {label: { fieldName: 'estrategia' }}, sortable: true },
    {label: 'Fecha Inicio', fieldName: 'fechaInicio', type: 'date', sortable: true, fixedWidth: 130},   
    {label: 'Fecha Situación', fieldName: 'fechaSituacion', type: 'date', sortable: true, fixedWidth: 155},
    {label: 'Propuesta Negocio', fieldName: 'propuestaNegocio', type: 'text', sortable: true},
    {label: 'Propuesta Riesgos', fieldName: 'propuestaRiesgos', type: 'text', sortable: true},
    {label: 'Gestor', fieldName: 'gestor', type: 'text', sortable: true}, 
    {label: 'Deuda Total', fieldName: 'deudaTotal', type: 'currency', sortable: true, fixedWidth: 155},  
    {label: 'Rating', fieldName: 'rating', type: 'number', sortable: true}    
];

const columnsProcesoGestionadosCargaActual = [
    {label: 'Cliente',  fieldName: 'idCliente',  type: 'url',  typeAttributes: {label: { fieldName: 'cliente' }}, sortable: true }, 
    {label: 'Grupo', fieldName: 'grupo', type: 'text', sortable: true},
    {label: 'Estrategia',  fieldName: 'idProceso',  type: 'url',  typeAttributes: {label: { fieldName: 'estrategia' }}, sortable: true },
    {label: 'Fecha Inicio', fieldName: 'fechaInicio', type: 'date', sortable: true, fixedWidth: 130},   
    {label: 'Situación', fieldName: 'situacion', type: 'text', sortable: true},
    {label: 'Fecha Situación', fieldName: 'fechaSituacion', type: 'date', sortable: true, fixedWidth: 155},
    {label: 'Tipo Gestión', fieldName: 'tipoGestion', type: 'text', sortable: true},
    {label: 'Analista/Gestor', fieldName: 'analistaGestor', type: 'text', sortable: true}, 
    {label: 'Propuesta', fieldName: 'propuesta', type: 'text', sortable: true}
];

const columnsTareas = [
    {label: 'Proceso',  fieldName: 'idProceso',  type: 'url',  typeAttributes: {label: { fieldName: 'proceso' }}, sortable: true },
    {label: 'Estrategia', fieldName: 'estrategia', type: 'text', sortable: true},
    {label: 'Situación', fieldName: 'situacion', type: 'text', sortable: true},        
    {label: 'Fecha Situación', fieldName: 'fechaSituacion', type: 'date', sortable: true},
    {label: 'Tarea',  fieldName: 'tareaNombre', type: 'text', sortable: true },
    {label: 'Tipo',  fieldName: 'tipo', type: 'text', sortable: true}
];

export default class Sire_lwc_HomeGestorPreventivo extends LightningElement {
    // General
    @track resultQueryReport;
    @track now = Date.now();
    @track wiredResultProcesos= [];
    @track idRecordType = '';
    @track usuarioLogeadoEsAnalista;

    // Cajitas
    @track arrayTitulosCajitas = [];
    @track cajitas;
    @track estrategiasPreventivoCodigo = [];
    @track numCajitasFila = '';
    @track numTotalCajitas = 0;    

    @track defaultSortDirection = 'asc';      

    // Procesos Pendiente Riesgos
    @track procesosPendienteRiesgos;        
    @track informeProcesosPendienteRiesgos;
    @track numTotalProcesosPendienteRiesgos = 0;
    @track columnsProcesoPendienteRiesgos;
    @track columnsProcesoPendienteRiesgosAnalista;
    @track columnsProcesoPendienteRiesgosGestor;
    @track procesosPendienteRiesgosSortDirection = 'asc'; 
    @track procesosPendienteRiesgoSortedBy;

    // Procesos Pendiente Consenso
    @track procesosPendienteConsenso;        
    @track informeProcesosPendienteConsenso;
    @track numTotalProcesosPendienteConsenso = 0;
    @track columnsProcesoPendienteConsenso;
    @track columnsProcesoPendienteConsensoAnalista;
    @track columnsProcesoPendienteConsensoGestor;    
    @track procesosPendienteConsensoSortDirection = 'asc'; 
    @track procesosPendienteConsensoSortedBy;

    // Procesos Gestionados Carga Actual
    @track procesosGestionadosCargaActual;        
    @track informeProcesosGestionadosCargaActual;
    @track numTotalProcesosGestionadosCargaActual = 0;
    @track columnsProcesoGestionadosCargaActual = columnsProcesoGestionadosCargaActual;
    @track procesosGestionadosCargaActualSortDirection = 'asc'; 
    @track procesosGestionadosCargaActualSortedBy;

    // Grafico Procesos-Estrategias
    @track informeProcesosEstrategias;

    // Tareas pendientes sincronizar
    @track tareasPendientes;
    @track numTareasPendientes = 0;
    @track columnsTareas = columnsTareas; 
    @track showTableTareas = false;
    @track sortDirectionTareas = 'asc';
    @track sortedByTareas;
    @track informeTareasPendientes;    
    
    // Actualizar datos al cambiar de pestaña
    @api
    refreshCmp() {
       refreshApex(this.wiredResultProcesos);
       // Ponemos en la variable el dia y la hora actual
       this.now = Date.now();
    }
    @wire(CurrentPageReference)
    setCurrentPageReference(currentPageReference) {
        refreshApex(this.wiredResultProcesos);
        // Ponemos en la variable el dia y la hora actual
        this.now = Date.now();
    }
    // Fin Actualizar datos al cambiar de pestaña
  
    connectedCallback() { 
        getQueryRecordTypeProceso({}).then(result => {            
            this.idRecordType = result;  
            getUsuarioLogeado({usuarioLogeado: USER_ID}).then(result => {          
                this.usuarioLogeadoEsAnalista = result;        
            })
            .catch(error => {
                this.mensajeError = error;
            });       
        })
        .catch(error => {
            this.mensajeError = error;
        }); 
    }     
    
    @wire(getPicklistValues, { recordTypeId: '$idRecordType', fieldApiName: ESTRATEGIA_FIELD })
    estrategiasPreventivo;

    @wire(getQueryProcesos, {estrategiasPreventivo: '$estrategiasPreventivo'})
    wiredData(result) {
        this.wiredResultProcesos = result;
        // Inicializamos las variables para que cuando se actualice las queries
        this.numTotalProcesosPendienteRiesgos = 0;
        this.numTotalProcesosPendienteConsenso = 0;
        this.numTotalProcesosGestionadosCargaActual = 0;

        this.procesosPendienteRiesgos = null;     
        this.procesosPendienteConsenso = null;     
        this.procesosGestionadosCargaActual = null; 

        this.informeProcesosPendienteRiesgos = null;   
        this.informeProcesosPendienteConsenso = null;   
        this.informeProcesosGestionadosCargaActual = null;   
        
        // Se comprueba si ya se ha lanzado el wire de la picklist de estrategia, ya que si no se ha lanzado dara error
        if(this.estrategiasPreventivo.data != undefined){
            // Montamos las Estrategias Dinamicas, creando las variables con las estrategias
            for(let i = 0; i < this.estrategiasPreventivo.data.values.length; i++){ 
                this.arrayTitulosCajitas.push(this.estrategiasPreventivo.data.values[i].label);
                this.estrategiasPreventivoCodigo.push(this.estrategiasPreventivo.data.values[i].value);
            }
            // Creamos las TRES cajitas extras que NO son estrategias
            this.arrayTitulosCajitas.push('Fecha Revisión Vencida');
            this.estrategiasPreventivoCodigo.push('FechaRevisiónVencida');
            this.arrayTitulosCajitas.push('Incremento Riesgo');
            this.estrategiasPreventivoCodigo.push('IncrementoRiesgo');
            this.arrayTitulosCajitas.push('En periodo de espera');
            this.estrategiasPreventivoCodigo.push('EnPeriodoEspera');
            // Creamos N posiciones de la variable array de forma dinamica, 1 posicion por estrategia
            var estrategiasCajitas = [];
            for(let i = 0; i < this.arrayTitulosCajitas.length; i++){ 
                estrategiasCajitas[i] = 0;
            } 
            this.numTotalCajitas = estrategiasCajitas.length;           
            
            // Con la query montamos las cajitas y los procesos activos
            if(result.data){ 
                if(this.usuarioLogeadoEsAnalista === true){      
                    this.columnsProcesoPendienteRiesgos = columnsProcesoPendienteRiesgosAnalista; 
                    this.columnsProcesoPendienteConsenso = columnsProcesoPendienteConsensoAnalista; 
                } else {
                    this.columnsProcesoPendienteRiesgos = columnsProcesoPendienteRiesgosGestor;                    
                    this.columnsProcesoPendienteConsenso = columnsProcesoPendienteConsensoGestor;                         
                }  

                let currentData  = []; 
                let currentData2 = []; 
                let currentData3 = [];   
                let currentDataTareas = [];         
                for(let i = 0; i < result.data.length; i++){        
                    // Calculamos los procesos que tienen la situacion 'Pendiente Inicio Gestion' y los clasificiamos por estrategia
                    if(result.data[i].SIR_fld_Situacion_SF__c == 'SF_INIGEST'){                
                        if(this.estrategiasPreventivoCodigo.includes(result.data[i].SIREC__SIREC_fld_estrategia__c)){
                            let numArray = this.estrategiasPreventivoCodigo.indexOf(result.data[i].SIREC__SIREC_fld_estrategia__c);
                            estrategiasCajitas[numArray] = estrategiasCajitas[numArray] + 1;
                        }                    
                    } 
                    // Cajita Fecha Revisión Vencida: procesos con la situación ACCIÓN RESTRICTIVA VENCIDA y 'Nueva Fecha revisión pdte. Riesgos'
                    if(result.data[i].SIR_fld_Situacion_SF__c == 'SF_PVCAP5' || result.data[i].SIR_fld_Situacion_SF__c == 'SF_PVACA3'){                
                        let numArray = this.estrategiasPreventivoCodigo.indexOf('FechaRevisiónVencida');
                        estrategiasCajitas[numArray] = estrategiasCajitas[numArray] + 1;                   
                    }
                    // Cajita Incremento Riesgo: procesos con la situacion INCREMENTO RIESGOS
                    if(result.data[i].SIR_fld_Situacion_SF__c == 'SF_PVINRI'){                
                        let numArray = this.estrategiasPreventivoCodigo.indexOf('IncrementoRiesgo');
                        estrategiasCajitas[numArray] = estrategiasCajitas[numArray] + 1;                   
                    }
                    // Cajita En periodo de espera: procesos con agrupacionSituacion GESTIONADO EN ESPERA
                    if(result.data[i].SIR_agrupacionSituacion__c == 'Gestionado en Espera'){                
                        let numArray = this.estrategiasPreventivoCodigo.indexOf('EnPeriodoEspera');
                        estrategiasCajitas[numArray] = estrategiasCajitas[numArray] + 1;           
                    }                         
                    // Procesos Pendiente Riesgos: procesos con situacion  PDTE PROPUESTA RIESGOS
                    if(result.data[i].SIR_fld_Situacion_SF__c == 'SF_PVPPRI'){
                        let rowData = {};
                        if(result.data[i].SIREC__SIREC_fld_cliente__c != null){
                            rowData.idCliente = '/lightning/r/Account/' + result.data[i].SIREC__SIREC_fld_cliente__c + '/view';
                            rowData.cliente = result.data[i].SIREC__SIREC_fld_cliente__r.Name;
                        } 
                        rowData.grupo = result.data[i].SIR_GrupoEconomico__c;
                        rowData.idProceso = '/lightning/r/SIREC__SIREC_obj_proceso__c/' + result.data[i].Id + '/view';
                        rowData.estrategia = result.data[i].estrategia;                                   
                        rowData.fechaInicio = result.data[i].SIREC__SIREC_fld_fechaInicio__c;                        
                        rowData.fechaSituacion = result.data[i].SIREC__SIREC_fld_fechaSituacion__c;
                        rowData.propuestaNegocio = result.data[i].SIR_PropuestaNegocio__c;
                        if(this.usuarioLogeadoEsAnalista === true){                        
                            rowData.gestor = result.data[i].Owner.Name;  
                        } else {
                            if(result.data[i].SIR_AnalistaRiesgo__c != undefined){
                                rowData.analista = result.data[i].SIR_AnalistaRiesgo__r.Name;
                            }                       
                        }                        
                        if(result.data[i].SIR_DeudaTotal__c == undefined){
                            rowData.deudaTotal = ''; 
                        } else {
                            rowData.deudaTotal = result.data[i].SIR_DeudaTotal__c; 
                        }                      
                        rowData.rating = result.data[i].SIR_RatingScoring__c;                                                 
                        currentData.push(rowData);
                        this.numTotalProcesosPendienteRiesgos = this.numTotalProcesosPendienteRiesgos + 1;                 
                    }

                    // Procesos Pendiente Consenso: procesos con situacion PDTE CONCENSO
                    if(result.data[i].SIR_agrupacionSituacion__c == 'Pendiente Consenso'){ 
                        let rowData = {};
                        if(result.data[i].SIREC__SIREC_fld_cliente__c != null){
                            rowData.idCliente = '/lightning/r/Account/' + result.data[i].SIREC__SIREC_fld_cliente__c + '/view';
                            rowData.cliente = result.data[i].SIREC__SIREC_fld_cliente__r.Name;
                        } 
                        rowData.grupo = result.data[i].SIR_GrupoEconomico__c;
                        rowData.idProceso = '/lightning/r/SIREC__SIREC_obj_proceso__c/' + result.data[i].Id + '/view';
                        rowData.estrategia = result.data[i].estrategia;                                   
                        rowData.fechaInicio = result.data[i].SIREC__SIREC_fld_fechaInicio__c;                        
                        rowData.fechaSituacion = result.data[i].SIREC__SIREC_fld_fechaSituacion__c;
                        rowData.propuestaNegocio = result.data[i].SIR_PropuestaNegocio__c;
                        rowData.propuestaRiesgos = result.data[i].SIR_PropuestaRiesgo__c;
                        if(this.usuarioLogeadoEsAnalista === true){                        
                            rowData.gestor = result.data[i].Owner.Name;                             
                        } else {
                            if(result.data[i].SIR_AnalistaRiesgo__c != undefined){
                                rowData.analista = result.data[i].SIR_AnalistaRiesgo__r.Name;
                            }                        
                        }   
                        if(result.data[i].SIR_DeudaTotal__c == undefined){
                            rowData.deudaTotal = ''; 
                        } else {
                            rowData.deudaTotal = result.data[i].SIR_DeudaTotal__c; 
                        }                      
                        rowData.rating = result.data[i].SIR_RatingScoring__c;                                                 
                        currentData2.push(rowData);
                        this.numTotalProcesosPendienteConsenso = this.numTotalProcesosPendienteConsenso + 1;                    
                    }

                    // Procesos Carga Actual: procesos con SIR_agrupacionSituacion__c 'Gestionado en Espera' y que la SIREC__SIREC_fld_fechaSituacion__c >= SIR_fechaCarga__c
                    if(result.data[i].SIR_agrupacionSituacion__c == 'Gestionado en Espera' && result.data[i].SIREC__SIREC_fld_fechaSituacion__c >= result.data[i].SIR_fechaCarga__c){ 
                        let rowData = {};
                        if(result.data[i].SIREC__SIREC_fld_cliente__c != null){
                            rowData.idCliente = '/lightning/r/Account/' + result.data[i].SIREC__SIREC_fld_cliente__c + '/view';
                            rowData.cliente = result.data[i].SIREC__SIREC_fld_cliente__r.Name;
                        } 
                        rowData.grupo = result.data[i].SIR_GrupoEconomico__c;
                        rowData.idProceso = '/lightning/r/SIREC__SIREC_obj_proceso__c/' + result.data[i].Id + '/view';  
                        rowData.estrategia = result.data[i].estrategia;                                   
                        rowData.fechaInicio = result.data[i].SIREC__SIREC_fld_fechaInicio__c;                        
                        rowData.situacion = result.data[i].situacion;
                        rowData.fechaSituacion = result.data[i].SIREC__SIREC_fld_fechaSituacion__c;
                        rowData.tipoGestion = result.data[i].SIR_TipoGestionPREVEMP__c;                
                        if(result.data[i].SIR_AnalistaRiesgo__c != undefined){
                            rowData.analistaGestor = result.data[i].SIR_AnalistaRiesgo__r.Name + ' / ' + result.data[i].Owner.Name;
                        } else {
                            rowData.analistaGestor = 'Sin Analista / ' + result.data[i].Owner.Name;
                        }
                        rowData.propuesta = result.data[i].SIR_PropuestaProceso__c;                                                                       
                        currentData3.push(rowData);
                        this.numTotalProcesosGestionadosCargaActual = this.numTotalProcesosGestionadosCargaActual + 1;                    
                    }

                    // Procesos con TAREAS Pendientes de Sincronizar y Enviadas.
                    if(result.data[i].SIREC__SIREC_fld_tarea__c !== undefined 
                        && (result.data[i].SIREC__SIREC_fld_tarea__r.SIREC__SIREC_fld_estado__c === 'Pendiente Sincronización' 
                        || result.data[i].SIREC__SIREC_fld_tarea__r.SIREC__SIREC_fld_estado__c === 'Enviada')){ 
                        this.showTableTareas = true;              
                        let rowData = {};
                        rowData.idProceso = '/lightning/r/SIREC__SIREC_obj_proceso__c/' + result.data[i].Id + '/view';
                        rowData.proceso = result.data[i].Name;                        
                        rowData.estrategia = result.data[i].estrategia;
                        rowData.situacion = result.data[i].situacion;
                        rowData.fechaSituacion = result.data[i].SIREC__SIREC_fld_fechaSituacion__c;
                        rowData.tareaNombre = result.data[i].SIREC__SIREC_fld_tarea__r.Name;
                        rowData.tipo = result.data[i].SIREC__SIREC_fld_tarea__r.SIREC__SIREC_fld_tipo_tarea__c;                        
                        currentDataTareas.push(rowData);
                        this.numTareasPendientes = this.numTareasPendientes + 1;              
                    }
                } 
                
                if(this.numTotalCajitas >= 8){
                    this.numCajitasFila = 'slds-size_1-of-8';
                } else {
                    if(this.numTotalCajitas >= 4){
                        this.numCajitasFila = 'slds-size_1-of-' + this.numTotalCajitas;
                    } else {
                        var elemento = this.template.querySelectorAll('lightning-layout-item');
                        for (let i = 0; i < elemento.length; i++) {
                            if (i === 0) {
                                elemento[i].classList.add('paddingCajita');
                            }
                            elemento[i].classList.remove('slds-col');
                        }
                    }             
                }    

                // Ponemos los resultados de procesos Pendiente Riesgos en la variable de front
                this.procesosPendienteRiesgos = currentData; 
                let cloneData = [...this.procesosPendienteRiesgos];
                cloneData.sort(this.sortBy('fechaSituacion', -1, undefined));
                this.procesosPendienteRiesgos = cloneData;
                this.procesosPendienteRiesgosSortDirection = 'desc';
                this.procesosPendienteRiesgoSortedBy = 'fechaSituacion';

                // Ponemos los resultados de procesos Pendiente Consenso en la variable de front
                this.procesosPendienteConsenso = currentData2;  
                let cloneData2 = [...this.procesosPendienteConsenso];
                cloneData2.sort(this.sortBy('fechaSituacion', -1, undefined));
                this.procesosPendienteConsenso = cloneData2;
                this.procesosPendienteConsensoSortDirection = 'desc';
                this.procesosPendienteConsensoSortedBy = 'fechaSituacion'; 

                // Ponemos los resultados de procesos Gestionados Carga Actual en la variable de front
                this.procesosGestionadosCargaActual = currentData3;
                let cloneData3 = [...this.procesosGestionadosCargaActual];
                cloneData3.sort(this.sortBy('fechaSituacion', -1, undefined));
                this.procesosGestionadosCargaActual = cloneData3;
                this.procesosGestionadosCargaActualSortDirection = 'desc';
                this.procesosGestionadosCargaActualSortedBy = 'fechaSituacion';

                // Ponemos los resultados de procesos con Tareas pendiente Sincro en la variable de front
                this.tareasPendientes = currentDataTareas;
                let cloneData4 = [...this.tareasPendientes];
                cloneData4.sort(this.sortBy('fechaSituacion', -1, undefined));
                this.tareasPendientes = cloneData4;
                this.sortDirectionTareas = 'desc';
                this.sortedByTareas = 'fechaSituacion';
                
                // Query para traernos los ID's de los reports para que puedan ver el informe entero
                getQueryReports({}).then(result => { 
                    // El resultado de la query esta ordenado alfabeticamente por apiname del report
                    // Por lo que la posicion es determinante para saber que report es          
                    this.resultQueryReport = result;
                    // Montamos la estructura de datos de las cajitas Pendiente Inicio Gestion por Estrategia
                    this.cajitas = [];
                    for(let i = 0; i < this.arrayTitulosCajitas.length; i++){                           
                        let cajitaIndividual = [];
                        cajitaIndividual.titulo = this.arrayTitulosCajitas[i];
                        cajitaIndividual.clasesNumero = 'cursor-default no-select';
                        // Cajita En periodo de espera
                        if(i == (this.arrayTitulosCajitas.length - 1) ){
                            cajitaIndividual.clasesTitulo = 'card-title min-size-title slds-text-align_center colorTextoAzul';
                            cajitaIndividual.clasesNumero = 'cursor-default no-select colorTextoAzul';
                            // Posicion 2 resultante de la query es el report de Cajita En periodo de espera
                            cajitaIndividual.url = '/lightning/r/Report/' +  this.resultQueryReport[2].Id + '/view'; 
                        
                        // Cajita Incremento Riesgo
                        } else if(i == (this.arrayTitulosCajitas.length - 2) ){
                            cajitaIndividual.clasesTitulo = 'card-title min-size-title slds-text-align_center colorTextoRojo';
                            // Posicion 1 resultante de la query es el report de Cajita Incremento Riesgo
                            cajitaIndividual.url = '/lightning/r/Report/' +  this.resultQueryReport[1].Id + '/view'; 
                        
                        // Cajita Fecha Revision Vencida
                        } else if(i == (this.arrayTitulosCajitas.length - 3) ){
                            cajitaIndividual.clasesTitulo = 'card-title min-size-title slds-text-align_center colorTextoRojo';
                            // Posicion 0 resultante de la query es el report de Cajita Fecha Revision Vencida
                            cajitaIndividual.url = '/lightning/r/Report/' +  this.resultQueryReport[0].Id + '/view'; 
                        
                        // Cajitas Estrategia
                        } else {
                            cajitaIndividual.clasesTitulo = 'card-title min-size-title slds-text-align_center';
                            // Posicion 7 resultante de la query es el report de Estrategias Dinamicas
                            cajitaIndividual.url = '/lightning/r/Report/' +  this.resultQueryReport[7].Id + '/view?fv0='+this.estrategiasPreventivoCodigo[i]; 
                        }
                        cajitaIndividual.numTotal = estrategiasCajitas[i];
                        this.cajitas.push(cajitaIndividual);                           
                    }
                    // Posicion 4 esta el report de Procesos Carga Actual
                    this.informeProcesosGestionadosCargaActual = '/lightning/r/Report/' + this.resultQueryReport[4].Id + '/view'; 
                    // Posicion 5 esta el report de Procesos Pendiente Concenso
                    this.informeProcesosPendienteConsenso = '/lightning/r/Report/' + this.resultQueryReport[5].Id + '/view'; 
                    // Posicion 6 esta el report de Procesos Riesgos
                    this.informeProcesosPendienteRiesgos = '/lightning/r/Report/' + this.resultQueryReport[6].Id + '/view'; 
                    // Posicion 3 esta el report de Procesos Pendiente Iniciar (Grafico)
                    this.informeProcesosEstrategias = '/lightning/r/Report/' + this.resultQueryReport[3].Id + '/view';  //??????
                    // Posicion 8 esta el report de Tareas Pendiente Sincronizar
                    this.informeTareasPendientes = '/lightning/r/Report/' + this.resultQueryReport[8].Id + '/view';  
                    // Ponemos en la variable el dia y la hora actual.
                    this.now = Date.now();
                })
                .catch(error => {
                    this.mensajeError = error;
                });                        
            }
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

    onHandleSortPendienteRiesgos(event) {
        const { fieldName: sortedBy, sortDirection } = event.detail;
        const cloneData = [...this.procesosPendienteRiesgos];
        cloneData.sort(this.sortBy(sortedBy, sortDirection === 'asc' ? 1 : -1));
        this.procesosPendienteRiesgos = cloneData;
        this.procesosPendienteRiesgosSortDirection = sortDirection;
        this.procesosPendienteRiesgoSortedBy = sortedBy;
    } 
   
    onHandleSortPendienteConsenso(event) {
        const { fieldName: sortedBy, sortDirection } = event.detail;
        const cloneData = [...this.procesosPendienteConsenso];
        cloneData.sort(this.sortBy(sortedBy, sortDirection === 'asc' ? 1 : -1));
        this.procesosPendienteConsenso = cloneData;
        this.procesosPendienteConsensoSortDirection = sortDirection;
        this.procesosPendienteConsensoSortedBy = sortedBy;
    } 


    onHandleSortCargaActual(event) {
        const { fieldName: sortedBy, sortDirection } = event.detail;
        const cloneData = [...this.procesosGestionadosCargaActual];
        cloneData.sort(this.sortBy(sortedBy, sortDirection === 'asc' ? 1 : -1));
        this.procesosGestionadosCargaActual = cloneData;
        this.procesosGestionadosCargaActualSortDirection = sortDirection;
        this.procesosGestionadosCargaActualSortedBy = sortedBy;
    }     
    
    onHandleSortTareas(event) {
        const { fieldName: sortedBy, sortDirection } = event.detail;
        const cloneData = [...this.tareasPendientes];
        cloneData.sort(this.sortBy(sortedBy, sortDirection === 'asc' ? 1 : -1));
        this.tareasPendientes = cloneData;
        this.sortDirectionTareas = sortDirection;
        this.sortedByTareas = sortedBy;
    }
   
}