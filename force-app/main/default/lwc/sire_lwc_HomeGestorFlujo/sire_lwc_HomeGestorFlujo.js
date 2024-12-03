import {LightningElement,api,wire,track} from 'lwc';
import {CurrentPageReference} from 'lightning/navigation';
import getAgrupacionesEstrategias from '@salesforce/apex/SIRE_LCMP_HomeGestorFlujo.getAgrupacionesEstrategias';
import getQueryProcesos from '@salesforce/apex/SIRE_LCMP_HomeGestorFlujo.getQueryProcesos';
import getQueryReports from '@salesforce/apex/SIRE_LCMP_HomeGestorFlujo.getQueryReports';
import {refreshApex} from '@salesforce/apex';

const columnsProceso = [
    {label: 'Cliente',  fieldName: 'idCliente',  type: 'url',  typeAttributes: {label: { fieldName: 'cliente' }}, sortable: true }, 
    {label: 'Grupo', fieldName: 'grupo', type: 'text', sortable: true},
    {label: 'Proceso',  fieldName: 'idProceso',  type: 'url',  typeAttributes: {label: { fieldName: 'procesoNombre' }}, sortable: true }, 
    {label: 'Deuda Total', fieldName: 'deudaTotal', type: 'currency', sortable: true},     
    {label: 'Máx. nº días impago', fieldName: 'diasImpago', type: 'number', sortable: true},   
    {label: 'Situación SF', fieldName: 'situacion', type: 'text', sortable: true},
    {label: 'Fecha Situación', fieldName: 'fechaSituacion', type: 'date', sortable: true},
    {label: 'Alerta SIREC', fieldName: 'alerta', type: 'text', sortable: true},
    {label: 'Días superando umbral (Máx. Núm)', fieldName: 'diasSuperaUmbral', type: 'number', sortable: true},
    {label: 'Salida PP estimada', fieldName: 'fechaSalidaPP', type: 'date', sortable: true},
    {label: 'Impacto dudoso', fieldName: 'impactoDudoso', type: 'currency', sortable: true},
    {label: 'Gestor', fieldName: 'gestor', type: 'text', sortable: true} 
];

const columnsTareas = [
    {label: 'Proceso',  fieldName: 'idProceso',  type: 'url',  typeAttributes: {label: { fieldName: 'proceso' }}, sortable: true },
    {label: 'Estrategia', fieldName: 'estrategia', type: 'text', sortable: true},
    {label: 'Situación', fieldName: 'situacion', type: 'text', sortable: true},        
    {label: 'Fecha Situación', fieldName: 'fechaSituacion', type: 'date', sortable: true},
    {label: 'Tarea',  fieldName: 'tareaNombre', type: 'text', sortable: true },
    {label: 'Tipo',  fieldName: 'tipo', type: 'text', sortable: true}
];

export default class Sire_lwc_HomeGestorFlujo extends LightningElement {
    // General
    @track resultQueryReport;
    @track now = Date.now();
    @track wiredResultProcesos= [];

    // Cajitas
    @track arrayTitulosCajitas = [];
    @track cajitas;
    @track estrategiasFlujoCodigo = [];
    @track numCajitasFila = '';
    @track numTotalCajitas = 0;
    
    // Procesos Activos
    @track procesos;        
    @track informeProcesosActivos;
    @track numTotalProcesosActivo = 0;
    @track columnsProceso = columnsProceso;    
    @track defaultSortDirection = 'asc';
    @track procesosSortDirection = 'asc'; 
    @track procesosSortedBy;

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
    
    @track numMaxCajitasPorLinea = 0;

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
      
    @wire(getQueryProcesos, {})
    wiredData(result) {
        this.wiredResultProcesos = result;
        // Inicializamos las variables para que cuando se actualice las queries
        this.numTotalProcesosActivo = 0;
        this.procesos = null;     
        this.informeProcesosActivos = null;   
        
        this.numMaxCajitasPorLinea = 0;
        this.numTotalCajitas = 0;
        this.numCajitasFila = '';
        
        getAgrupacionesEstrategias({}).then(resultAgrupaciones => {       
            this.estrategiasFlujoCodigo = [];
            this.arrayTitulosCajitas = [];
            // Montamos las Estrategias Dinamicas, creando las variables con las estrategias
            for(let i = 0; i < resultAgrupaciones.length; i++){
                // Miramos cuantas cajas por linea es el maximo, lo miramos mediante el 'maxCajas'
                if(resultAgrupaciones[i].Name === 'maxCajas'){
                    this.numMaxCajitasPorLinea = resultAgrupaciones[i].SIREC__SIREC_fld_Codigo__c;
                } else {
                    if(!this.estrategiasFlujoCodigo.includes(resultAgrupaciones[i].SIREC__SIREC_fld_CodigoAgrupador__c)){
                        this.arrayTitulosCajitas.push(resultAgrupaciones[i].SIREC__SIREC_fld_DescAgrupador__c);
                        this.estrategiasFlujoCodigo.push(resultAgrupaciones[i].SIREC__SIREC_fld_CodigoAgrupador__c);
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
                let currentData = [];
                let currentDataTareas = [];      
                for(let i = 0; i < result.data.length; i++){        
                    // Calculamos los procesos que tienen la situacion 'Pendiente Inicio Gestion' y los clasificiamos por estrategia
                    if(result.data[i].SIR_fld_Situacion_SF__c === 'FEPEIN'){     
                        if(result.data[i].SIREC__SIREC_fld_codigoAgrupador__c !== undefined){           
                            if(this.estrategiasFlujoCodigo.includes(result.data[i].SIREC__SIREC_fld_codigoAgrupador__c)){
                                let numArray = this.estrategiasFlujoCodigo.indexOf(result.data[i].SIREC__SIREC_fld_codigoAgrupador__c);
                                estrategiasCajitas[numArray] = estrategiasCajitas[numArray] + 1;
                            }
                        }                    
                    }                          
                    // Calculamos los procesos ya iniciados pero que no esten finalizados
                    if(result.data[i].SIR_fld_Situacion_SF__c !== 'FEPEIN'){ 
                        let rowData = {};
                        if(result.data[i].SIREC__SIREC_fld_cliente__c != null){
                            rowData.idCliente = '/lightning/r/Account/' + result.data[i].SIREC__SIREC_fld_cliente__c + '/view';
                            rowData.cliente = result.data[i].SIREC__SIREC_fld_cliente__r.Name;
                        } 
                        rowData.grupo = result.data[i].SIREC__SIREC_fld_cliente__r.CIBE_GrupoEconomico__c;                   
                        rowData.idProceso = '/lightning/r/SIREC__SIREC_obj_proceso__c/' + result.data[i].Id + '/view';
                        rowData.procesoNombre = result.data[i].Name;                         
                        if(result.data[i].SIR_DeudaTotal__c === undefined){
                            rowData.deudaTotal = ''; 
                        } else {
                            rowData.deudaTotal = result.data[i].SIR_DeudaTotal__c; 
                        }                        
                        if(result.data[i].SIR_MaximoDiasImpago__c === undefined){
                            rowData.diasImpago = ''; 
                        } else {
                            rowData.diasImpago = result.data[i].SIR_MaximoDiasImpago__c; 
                        }
                        if(result.data[i].SIR_AlertaSIREC__c === undefined){
                            rowData.alerta = ''; 
                        } else {
                            rowData.alerta = result.data[i].SIR_AlertaSIREC__c; 
                        }                        
                        rowData.situacion = result.data[i].situacion;       
                        rowData.fechaSituacion = result.data[i].SIREC__SIREC_fld_fechaSituacion__c; 
                        
                        if(result.data[i].SIR_DiasSuperandoUmbrales__c === undefined){
                            rowData.diasSuperaUmbral = ''; 
                        } else {
                            rowData.diasSuperaUmbral = result.data[i].SIR_DiasSuperandoUmbrales__c; 
                        } 
                        rowData.fechaSalidaPP = result.data[i].SIR_FechaEstimadaSalidaPP__c; 
                        if(result.data[i].SIR_ImpactoDudoso__c === undefined){
                            rowData.impactoDudoso = ''; 
                        } else {
                            rowData.impactoDudoso = result.data[i].SIR_ImpactoDudoso__c; 
                        }                        
                        rowData.gestor = result.data[i].Owner.Name;                                                  
                        currentData.push(rowData);
                        this.numTotalProcesosActivo = this.numTotalProcesosActivo + 1;
                    }
                    // Procesos con TAREAS Pendientes de Sincronizar y Enviadas
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
                // Ponemos los resultados de procesos ya iniciados en la variable de front
                this.procesos = currentData;     
                // Ordenamos por el campo Alerta
                let cloneData = [...this.procesos];
                cloneData.sort(this.sortBy('alerta', -1, undefined));
                this.procesos = cloneData;
                this.sortDirection = 'desc';
                this.sortedBy = 'alerta';
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
                        // Posicion 2 resultante de la query es el report de Estrategias Dinamicas
                        cajitaIndividual.url = '/lightning/r/Report/' +  this.resultQueryReport[2].Id + '/view?fv0='+this.estrategiasFlujoCodigo[i];
                        cajitaIndividual.numTotal = estrategiasCajitas[i];
                        this.cajitas.push(cajitaIndividual);
                    }
                    // Posicion 0 esta el report de Procesos Activos
                    this.informeProcesosActivos = '/lightning/r/Report/' + this.resultQueryReport[0].Id + '/view'; 
                    // Posicion 1 esta el report de Procesos Activos
                    this.informeProcesosEstrategias = '/lightning/r/Report/' + this.resultQueryReport[1].Id + '/view'; 
                    // Posicion 2 esta el report de Tareas Pendiente Sincronizar
                    this.informeTareasPendientes = '/lightning/r/Report/' + this.resultQueryReport[3].Id + '/view';  
                    // Ponemos en la variable el dia y la hora actual.
                    this.now = Date.now();           
                })
                .catch(error => {
                    this.mensajeError = error;
                });                                   
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
        const cloneData = [...this.procesos];
        if(sortedBy === 'idCliente'){
			cloneData.sort(this.sortBy('cliente', sortDirection === 'asc' ? 1 : -1));
		} else if(sortedBy === 'idProceso'){
			cloneData.sort(this.sortBy('procesoNombre', sortDirection === 'asc' ? 1 : -1));
		} else {
			cloneData.sort(this.sortBy(sortedBy, sortDirection === 'asc' ? 1 : -1));
		}    
        this.procesos = cloneData;
        this.procesosSortDirection = sortDirection;
        this.procesosSortedBy = sortedBy;
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