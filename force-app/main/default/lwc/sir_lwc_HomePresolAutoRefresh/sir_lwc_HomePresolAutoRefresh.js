import { LightningElement, wire, track, api } from 'lwc';
import getQueryProcesos from '@salesforce/apex/SIR_LCMP_HomePresolAutoRefresh.getQueryProcesos';
import getQueryReports from '@salesforce/apex/SIR_LCMP_HomePresolAutoRefresh.getQueryReports';
import getAgrupacionesEstrategias from '@salesforce/apex/SIR_LCMP_HomePresolAutoRefresh.getAgrupacionesEstrategias';
import {loadStyle } from 'lightning/platformResourceLoader';
import recurso from '@salesforce/resourceUrl/Sir_lwc_HomeImpaAutoRefresh';
import {refreshApex} from '@salesforce/apex';
import { CurrentPageReference } from 'lightning/navigation';

const columnsProcesosEnGestion = [
    {label: 'Cliente',  fieldName: 'idCliente',  type: 'url',  typeAttributes: {label: { fieldName: 'cliente' }}, sortable: true }, 
    {label: 'Proceso',  fieldName: 'idProceso',  type: 'url',  typeAttributes: {label: { fieldName: 'procesoNombre' }}, sortable: true },
    {label: 'Estrategia', fieldName: 'estrategia', type: 'text', sortable: true},
    {label: 'Situación SF', fieldName: 'situacion', type: 'text', sortable: true},
    {label: 'Fecha Situación', fieldName: 'fechaSituacion', type: 'date', sortable: true},
    {label: 'Segmento PRESOL', fieldName: 'segmento', type: 'text', sortable: true},   
    {label: 'Tenencia ICO', fieldName: 'tenencia', type: 'text', sortable: true},   
    {label: 'Aviso centralizado', fieldName: 'aviso', type: 'text', sortable: true},  
    {label: 'Saldo Activo', fieldName: 'saldoActivo', type: 'currency', sortable: true},
    {label: 'Motivo Inclusión', fieldName: 'motivoInclusion', type: 'text', sortable: true},  
    {label: 'Rating Scoring', fieldName: 'rating', type: 'text', sortable: true} 
];
const columnsProcesosGestionados = [
    {label: 'Cliente',  fieldName: 'idCliente',  type: 'url',  typeAttributes: {label: { fieldName: 'cliente' }}, sortable: true }, 
    {label: 'Proceso',  fieldName: 'idProceso',  type: 'url',  typeAttributes: {label: { fieldName: 'procesoNombre' }}, sortable: true },
    {label: 'Estrategia', fieldName: 'estrategia', type: 'text', sortable: true},
    {label: 'Situación SF', fieldName: 'situacion', type: 'text', sortable: true},
    {label: 'Fecha Situación', fieldName: 'fechaSituacion', type: 'date', sortable: true},
    {label: 'Segmento PRESOL', fieldName: 'segmento', type: 'text', sortable: true},   
    {label: 'Tenencia ICO', fieldName: 'tenencia', type: 'text', sortable: true},   
    {label: 'Aviso centralizado', fieldName: 'aviso', type: 'text', sortable: true},  
    {label: 'Saldo Activo', fieldName: 'saldoActivo', type: 'currency', sortable: true},
    {label: 'Motivo Inclusión', fieldName: 'motivoInclusion', type: 'text', sortable: true},  
    {label: 'Rating Scoring', fieldName: 'rating', type: 'text', sortable: true} 
];

const columnsAcciones = [
    {label: 'Acción',  fieldName: 'idAccion',  type: 'url',  typeAttributes: {label: { fieldName: 'accionNombre' }}, sortable: true },
    {label: 'Tipo', fieldName: 'tipo', type: 'text', sortable: true},
    {label: 'Resultado', fieldName: 'resultado', type: 'text', sortable: true},
    {label: 'Interviniente',  fieldName: 'idCliente',  type: 'url',  typeAttributes: {label: { fieldName: 'cliente' }}, sortable: true },
    {label: 'Situación', fieldName: 'situacion', type: 'text', sortable: true},        
    {label: 'Fecha Situación', fieldName: 'fechaSituacion', type: 'date', sortable: true}
];

const columnsTareas = [
    {label: 'Proceso',  fieldName: 'idProceso',  type: 'url',  typeAttributes: {label: { fieldName: 'proceso' }}, sortable: true },
    {label: 'Estrategia', fieldName: 'estrategia', type: 'text', sortable: true},
    {label: 'Situación', fieldName: 'situacion', type: 'text', sortable: true},        
    {label: 'Fecha Situación', fieldName: 'fechaSituacion', type: 'date', sortable: true},
    {label: 'Tarea',  fieldName: 'tareaNombre', type: 'text', sortable: true },
    {label: 'Tipo',  fieldName: 'tipo', type: 'text', sortable: true}
];

export default class Sir_lwc_HomePresolAutoRefresh extends LightningElement {
    // Cajitas
    @track arrayTitulosCajitas = [];
    @track cajitas;
    @track estrategiasPresolCodigo = [];
    @track numCajitasFila = '';
    @track numTotalCajitas = 0;
    @track idRecordType = '';
    
    //variables procesos en gestion
    @track procesosEnGestion;
    @track numProcesosEnGestion = 0;
    @track columnsProcesosEnGestion = columnsProcesosEnGestion; 
    @track showTableEnGestion = false;
    //variables procesos gestionados
    @track procesosGestionados;
    @track numProcesosGestionados = 0;
    @track columnsProcesosGestionados = columnsProcesosGestionados; 
    @track showTableGestionados = false;
    //variables acciones pendientes sincronizar
    @track accionesPendientes;
    @track numAccionesPendientes = 0;
    @track columnsAcciones = columnsAcciones;
    @track showTableAcciones = false; 
    //variables tareas pendientes sincronizar
    @track tareasPendientes;
    @track numTareasPendientes = 0;
    @track columnsTareas = columnsTareas; 
    @track showTableTareas = false;
    //variables informes
    @track informeProcesosEnGestion;
    @track informeProcesosGestionados;
    @track informeProcesosEstrategias;
    @track informeAccionesPendientes;
    @track informeTareasPendientes;

    //variables de ordenacion
    @track defaultSortDirection = 'asc';
    @track sortDirection = 'asc';
    @track sortDirectionEnGestion = 'asc';
    @track sortDirectionGestionados = 'asc';
    @track sortDirectionAcciones = 'asc';
    @track sortDirectionTareas = 'asc';

    @track sortedBy;
    @track sortedByEnGestion;
    @track sortedByGestionados;
    @track sortedByAcciones;
    @track sortedByTareas;

    @track now = Date.now();
    @track wiredResultProcesos= [];
    @track wiredResultAcciones= [];
    @track wiredResultTareas= [];

    @track numMaxCajitasPorLinea = 0;

    /**
     * Executed when Aura parent component detects its tab is focused.
     */
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
   
    connectedCallback() {        
        loadStyle(this, recurso); 
    } 

    @wire(getQueryProcesos, {})
    wiredData(result) {
        this.wiredResultProcesos = result;
        // Inicializamos las variables para que cuando se actualice las queries
        this.numProcesosEnGestion = 0;
        this.numProcesosGestionados = 0;
        this.numAccionesPendientes = 0;
        this.numTareasPendientes = 0;
        this.procesosEnGestion = null;
        this.procesosGestionados = null;
        this.accionesPendientes = null;
        this.tareasPendientes = null;
        this.informeProcesosEnGestion = null;
        this.informeProcesosGestionados = null;
        this.informeProcesosEstrategias = null;
        this.informeAccionesPendientes = null;
        this.informeTareasPendientes = null;
        this.showTableEnGestion = false;
        this.showTableGestionados = false;
        this.showTableAcciones = false;
        this.showTableTareas = false;

        this.numMaxCajitasPorLinea = 0;
        this.numTotalCajitas = 0;
        this.numCajitasFila = '';
                
        getAgrupacionesEstrategias({}).then(resultAgrupaciones => {       
            this.estrategiasPresolCodigo = [];
            this.arrayTitulosCajitas = [];
            // Montamos las Estrategias Dinamicas, creando las variables con las estrategias
            for(let i = 0; i < resultAgrupaciones.length; i++){ 
                // Miramos cuantas cajas por linea es el maximo, lo miramos mediante el 'maxCajas'
                if(resultAgrupaciones[i].Name === 'maxCajas'){
                    this.numMaxCajitasPorLinea = resultAgrupaciones[i].SIREC__SIREC_fld_Codigo__c;
                } else {
                    if(!this.estrategiasPresolCodigo.includes(resultAgrupaciones[i].SIREC__SIREC_fld_CodigoAgrupador__c)){
                        this.arrayTitulosCajitas.push(resultAgrupaciones[i].SIREC__SIREC_fld_DescAgrupador__c);
                        this.estrategiasPresolCodigo.push(resultAgrupaciones[i].SIREC__SIREC_fld_CodigoAgrupador__c);
                    } 
                }                                    
            }
            this.numTotalCajitas = this.arrayTitulosCajitas.length;                       
            // Creamos N posiciones de la variable array de forma dinamica, 1 posicion por estrategia
            var estrategiasCajitas = [];
            for(let i = 0; i < this.numTotalCajitas; i++){ 
                estrategiasCajitas[i] = 0;
            }
        
            // Con la query montamos las cajitas y los procesos activos
            if(result.data){ 
                var currentDataEnGestion = []; 
                var currentDataGestionados = [];  
                         
                let currentDataTareas = [];   
                for(let i = 0; i < result.data.length; i++){        
                    // Cajitas
                    if(result.data[i].SIR_agrupacionSituacion__c === 'Pendiente'){ 
                        if(result.data[i].SIREC__SIREC_fld_codigoAgrupador__c !== undefined){
                            if(this.estrategiasPresolCodigo.includes(result.data[i].SIREC__SIREC_fld_codigoAgrupador__c)){
                                let numArray = this.estrategiasPresolCodigo.indexOf(result.data[i].SIREC__SIREC_fld_codigoAgrupador__c);
                                estrategiasCajitas[numArray] = estrategiasCajitas[numArray] + 1;
                            }    
                        }                   
                    }   
                    // Tabla Procesos En Gestion
                    if(result.data[i].SIR_agrupacionSituacion__c === 'En Gestión'){ 
                        let rowData = {};
                        if(result.data[i].SIREC__SIREC_fld_cliente__c != null){
                            rowData.idCliente = '/lightning/r/Account/' + result.data[i].SIREC__SIREC_fld_cliente__c + '/view';
                            rowData.cliente = result.data[i].SIREC__SIREC_fld_cliente__r.Name;
                        } 
                        rowData.idProceso = '/lightning/r/SIREC__SIREC_obj_proceso__c/' + result.data[i].Id + '/view';
                        rowData.procesoNombre = result.data[i].Name; 
                        rowData.estrategia = result.data[i].estrategia;                   
                        rowData.situacion = result.data[i].situacion;       
                        rowData.fechaSituacion = result.data[i].SIREC__SIREC_fld_fechaSituacion__c;
                        if(result.data[i].SIR_SegmentoPRESOL__c === undefined || result.data[i].SIR_SegmentoPRESOL__c === ''){
                            rowData.segmento = '-'; 
                        } else {
                            rowData.segmento = result.data[i].SIR_SegmentoPRESOL__c;
                        }
                        if(result.data[i].tenencia === undefined || result.data[i].tenencia === ''){
                            rowData.tenencia = '-'; 
                        } else {
                            rowData.tenencia = result.data[i].tenencia;
                        }
                        if(result.data[i].aviso === undefined || result.data[i].aviso === ''){
                            rowData.aviso = '-'; 
                        } else {
                            rowData.aviso = result.data[i].aviso;
                        }
                        if(result.data[i].SIR_saldActivo__c === undefined){
                            rowData.saldoActivo = ''; 
                        } else {
                            rowData.saldoActivo = result.data[i].SIR_saldActivo__c; 
                        }
                        if(result.data[i].SIR_MotivoInclusion__c === undefined || result.data[i].SIR_MotivoInclusion__c === ''){
                            rowData.motivoInclusion = '-'; 
                        } else {
                            rowData.motivoInclusion = result.data[i].SIR_MotivoInclusion__c;
                        }
                        if(result.data[i].SIR_RatingScoring__c === undefined || result.data[i].SIR_RatingScoring__c === ''){
                            rowData.rating = '-'; 
                        } else {
                            rowData.rating = result.data[i].SIR_RatingScoring__c;
                        }                                                
                        currentDataEnGestion.push(rowData);
                        this.numProcesosEnGestion = this.numProcesosEnGestion + 1;
                    }
                        
                    // Tabla Procesos Gestionados
                    if(result.data[i].SIR_agrupacionSituacion__c === 'Gestionado'){
                        let rowData = {};
                        if(result.data[i].SIREC__SIREC_fld_cliente__c != null){
                            rowData.idCliente = '/lightning/r/Account/' + result.data[i].SIREC__SIREC_fld_cliente__c + '/view';
                            rowData.cliente = result.data[i].SIREC__SIREC_fld_cliente__r.Name;
                        } 
                        rowData.idProceso = '/lightning/r/SIREC__SIREC_obj_proceso__c/' + result.data[i].Id + '/view';
                        rowData.procesoNombre = result.data[i].Name; 
                        rowData.estrategia = result.data[i].estrategia;                   
                        rowData.situacion = result.data[i].situacion;       
                        rowData.fechaSituacion = result.data[i].SIREC__SIREC_fld_fechaSituacion__c;

                        if(result.data[i].SIR_SegmentoPRESOL__c === undefined || result.data[i].SIR_SegmentoPRESOL__c === ''){
                            rowData.segmento = '-'; 
                        } else {
                            rowData.segmento = result.data[i].SIR_SegmentoPRESOL__c;
                        }
                        if(result.data[i].tenencia === undefined || result.data[i].tenencia === ''){
                            rowData.tenencia = '-'; 
                        } else {
                            rowData.tenencia = result.data[i].tenencia;
                        }
                        if(result.data[i].aviso === undefined || result.data[i].aviso === ''){
                            rowData.aviso = '-'; 
                        } else {
                            rowData.aviso = result.data[i].aviso;
                        }
                        if(result.data[i].SIR_saldActivo__c === undefined){
                            rowData.saldoActivo = ''; 
                        } else {
                            rowData.saldoActivo = result.data[i].SIR_saldActivo__c; 
                        }
                        if(result.data[i].SIR_MotivoInclusion__c === undefined || result.data[i].SIR_MotivoInclusion__c === ''){
                            rowData.motivoInclusion = '-'; 
                        } else {
                            rowData.motivoInclusion = result.data[i].SIR_MotivoInclusion__c;
                        }
                        if(result.data[i].SIR_RatingScoring__c === undefined || result.data[i].SIR_RatingScoring__c === ''){
                            rowData.rating = '-'; 
                        } else {
                            rowData.rating = result.data[i].SIR_RatingScoring__c;
                        }                                            
                        currentDataGestionados.push(rowData);
                        this.numProcesosGestionados = this.numProcesosGestionados + 1;
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
                this.procesosEnGestion = currentDataEnGestion;
                //Si hay procesos en gestion se muestra la tabla
                if(this.numProcesosEnGestion > 0){
                    this.showTableEnGestion = true;
                }
                // Ordenamos por el campo Fecha Situacion
                let cloneDataEnGestion = [...this.procesosEnGestion];
                cloneDataEnGestion.sort(this.sortBy('fechaSituacion', -1, undefined));
                this.procesosEnGestion = cloneDataEnGestion;
                this.sortDirectionEnGestion = 'desc';
                this.sortedByEnGestion = 'fechaSituacion'; 

                this.procesosGestionados = currentDataGestionados; 
                //Si hay procesos gestionados se muestra la tabla
                if(this.numProcesosGestionados > 0){
                    this.showTableGestionados = true;
                }
                // Ordenamos por el campo Fecha Situacion
                let cloneDataGestionados = [...this.procesosGestionados];
                cloneDataGestionados.sort(this.sortBy('fechaSituacion', -1, undefined));
                this.procesosGestionados = cloneDataGestionados;               
                this.sortDirectionGestionados = 'desc';
                this.sortedByGestionados = 'fechaSituacion';

                // Ponemos los resultados de procesos con Tareas pendiente Sincro en la variable de front
                this.tareasPendientes = currentDataTareas;
                let cloneData4 = [...this.tareasPendientes];
                cloneData4.sort(this.sortBy('fechaSituacion', -1, undefined));
                this.tareasPendientes = cloneData4;
                this.sortDirectionTareas = 'desc';
                this.sortedByTareas = 'fechaSituacion';

                // Indicamos en el frontal cuantas cajitas por linea debe de haber
                if(this.numTotalCajitas <= this.numMaxCajitasPorLinea){
                    // Si el num de cajitas es menor al numMaxCajitasPorLinea ponemos unos estilos para dispersar correctamente las cajitas, ya que sino se quedan todas juntas a la derecha
                    var elemento = this.template.querySelectorAll('lightning-layout-item');
                    for (let i = 0; i < elemento.length; i++) {
                        if (i === 0) {
                            elemento[i].classList.add('paddingCajita');
                        }
                        elemento[i].classList.remove('slds-col');
                    }
                } else {
                    this.numCajitasFila = 'slds-size_1-of-' + this.numMaxCajitasPorLinea;
                }
                
                // Ponemos en la variable el dia y la hora actual
                this.now = Date.now();

                // Query para traernos las Tareas pendientes de sincronizar
                /*getQueryTareas({}).then(result => {
                    if(result){              
                        let currentDataTareas = []; 
                        //Si hay tareas mostramos la tabla
                        if(result.length > 0){
                            this.showTableTareas = true;
                            for(let i = 0; i < result.length; i++){            
                                // Calculamos las Tareas              
                                let rowData = {};
                                if(result[i].SIREC__SIREC_fld_proceso__c != null){
                                    rowData.idProceso = '/lightning/r/SIREC__SIREC_obj_proceso__c/' + result[i].SIREC__SIREC_fld_proceso__c + '/view';
                                    rowData.proceso = result[i].SIREC__SIREC_fld_proceso__r.Name;
                                }
                                rowData.estrategia = result[i].SIREC__SIREC_fld_proceso__r.SIREC__SIREC_fld_descEstrategiaCatalogo__c;
                                rowData.situacion = result[i].SIREC__SIREC_fld_proceso__r.SIR_fld_Situacion_SF__c;
                                rowData.fechaSituacion = result[i].SIREC__SIREC_fld_proceso__r.SIREC__SIREC_fld_fechaSituacion__c; 
                                rowData.idTarea = '/lightning/r/SIREC__SIREC_obj_tarea__c/' + result[i].Id + '/view';
                                rowData.tareaNombre = result[i].Name; 
                                rowData.tipo = result[i].SIREC__SIREC_fld_tipo_tarea__c;   
                                
                                currentDataTareas.push(rowData);
                                this.numTareasPendientes = this.numTareasPendientes + 1;
                            }                    
                            this.tareasPendientes = currentDataTareas;
                        }
                    }*/

                    // Query para traernos los ID's de los reports para que puedan ver el informe entero
                    getQueryReports({}).then(result => {
                        // El resultado de la query esta ordenado alfabeticamente por apiname del report
                        // Por lo que la posicion es determinante para saber que report es          
                        this.resultQueryReport = result;
                        // Posicion 0 esta el report de Acciones Pendientes (sin workflow)
                        this.informeAccionesPendientes = '/lightning/r/Report/' +  this.resultQueryReport[0].Id + '/view';
                        // Posicion 1 esta el report de Procesos En Gestión
                        this.informeProcesosEnGestion =  '/lightning/r/Report/' +  this.resultQueryReport[1].Id + '/view';
                        // Posicion 2 esta el report de Procesos-Estrategias
                        this.informeProcesosEstrategias = '/lightning/r/Report/' +  this.resultQueryReport[2].Id + '/view';
                        // Posicion 3 esta el report de Procesos Gestionados
                        this.informeProcesosGestionados =  '/lightning/r/Report/' +  this.resultQueryReport[3].Id + '/view';

                        // Montamos la estructura de datos de las cajitas Pendiente Inicio Gestion por Estrategia
                        this.cajitas = [];
                        for(let i = 0; i < this.arrayTitulosCajitas.length; i++){
                            let cajitaIndividual = [];
                            cajitaIndividual.titulo = this.arrayTitulosCajitas[i];
                            // Posicion 2 resultante de la query es el report de Estrategias Dinamicas
                            cajitaIndividual.url = '/lightning/r/Report/' +  this.resultQueryReport[4].Id + '/view?fv0='+this.estrategiasPresolCodigo[i];
                            cajitaIndividual.numTotal = estrategiasCajitas[i];
                            this.cajitas.push(cajitaIndividual);
                        }      
                        // Posicion 5 esta el report de Tareas Pendientes (con workflow)
                        this.informeTareasPendientes = '/lightning/r/Report/' +  this.resultQueryReport[5].Id + '/view';                
                    })
                    .catch(error => {
                        this.mensajeError = error;
                    });

                /*})
                .catch(error => {
                    this.mensajeError = error;
                });*/
            }
            
        })
        .catch(error => {
            this.mensajeError = error;
        });     
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
        const cloneData = [...this.procesosEnGestion];
        if(sortedBy === 'idCliente'){
			cloneData.sort(this.sortBy('cliente', sortDirection === 'asc' ? 1 : -1));
		} else if(sortedBy === 'idProceso'){
			cloneData.sort(this.sortBy('procesoNombre', sortDirection === 'asc' ? 1 : -1));
		} else {
			cloneData.sort(this.sortBy(sortedBy, sortDirection === 'asc' ? 1 : -1));
		}
        this.procesosEnGestion = cloneData;
        this.sortDirectionEnGestion = sortDirection;
        this.sortedByEnGestion = sortedBy;       
    }

    sortByGestionados(field, reverse, primer) {
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
    
    onHandleSortGestionados(event) {
        const { fieldName: sortedBy, sortDirection } = event.detail;
        const cloneData = [...this.procesosGestionados];
        if(sortedBy === 'idCliente'){
			cloneData.sort(this.sortBy('cliente', sortDirection === 'asc' ? 1 : -1));
		} else if(sortedBy === 'idProceso'){
			cloneData.sort(this.sortBy('procesoNombre', sortDirection === 'asc' ? 1 : -1));
		} else {
			cloneData.sort(this.sortBy(sortedBy, sortDirection === 'asc' ? 1 : -1));
		}
        this.procesosGestionados = cloneData;
        this.sortDirectionGestionados = sortDirection;
        this.sortedByGestionados = sortedBy; 
    }

    sortByAcciones(field, reverse, primer) {
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

    onHandleSortAcciones(event) {
        const { fieldName: sortedBy, sortDirection } = event.detail;
        const cloneData = [...this.accionesPendientes];
        if(sortedBy === 'idCliente'){
			cloneData.sort(this.sortBy('cliente', sortDirection === 'asc' ? 1 : -1));
		} else if(sortedBy === 'idAccion'){
			cloneData.sort(this.sortBy('accionNombre', sortDirection === 'asc' ? 1 : -1));
		} else {
			cloneData.sort(this.sortBy(sortedBy, sortDirection === 'asc' ? 1 : -1));
		}
        this.accionesPendientes = cloneData;
        this.sortDirectionAcciones = sortDirection;
        this.sortedByAcciones = sortedBy;    
    }

    sortByTareas(field, reverse, primer) {
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

    onHandleSortTareas(event) {
        const { fieldName: sortedBy, sortDirection } = event.detail;
        const cloneData = [...this.tareasPendientes];
        if(sortedBy === 'idProceso'){
			cloneData.sort(this.sortBy('proceso', sortDirection === 'asc' ? 1 : -1));
		} else {
			cloneData.sort(this.sortBy(sortedBy, sortDirection === 'asc' ? 1 : -1));
		}
        this.tareasPendientes = cloneData;
        this.sortDirectionTareas = sortDirection;
        this.sortedByTareas = sortedBy;   
    }
    
}