import { LightningElement, api, wire, track } from 'lwc';
import { CurrentPageReference } from 'lightning/navigation';
import getAgrupacionesEstrategias from '@salesforce/apex/SIR_LCMP_HomeImpaAutoRefresh.getAgrupacionesEstrategias';
import getQueryProcesos from '@salesforce/apex/SIR_LCMP_HomeImpaAutoRefresh.getQueryProcesos';
import getQueryFormularios from '@salesforce/apex/SIR_LCMP_HomeImpaAutoRefresh.getQueryFormularios';
import getQueryAcciones from '@salesforce/apex/SIR_LCMP_HomeImpaAutoRefresh.getQueryAcciones';
import getQueryReports from '@salesforce/apex/SIR_LCMP_HomeImpaAutoRefresh.getQueryReports';
import {loadStyle } from 'lightning/platformResourceLoader';
import recurso from '@salesforce/resourceUrl/Sir_lwc_HomeImpaAutoRefresh';
import {refreshApex} from '@salesforce/apex';

const columnsProceso = [
    {label: 'Cliente',  fieldName: 'idCliente',  type: 'url',  typeAttributes: {label: { fieldName: 'cliente' }}, sortable: true }, 
    {label: 'Estrategia', fieldName: 'estrategia', type: 'text', sortable: true},
    {label: 'Fecha Inicio Estrategia', fieldName: 'fechaEstrategia', type: 'date', sortable: true},
    {label: 'Proceso',  fieldName: 'idProceso',  type: 'url',  typeAttributes: {label: { fieldName: 'procesoNombre' }}, sortable: true }, 
    {label: 'Fecha Inicio', fieldName: 'fechaInicio', type: 'date', sortable: true},   
    {label: 'Deuda Total', fieldName: 'deudaTotal', type: 'currency', sortable: true},
    {label: 'Deuda Vencida', fieldName: 'deudaVencida', type: 'currency', sortable: true},    
    {label: 'Máx. nº días impago', fieldName: 'diasImpago', type: 'number', sortable: true},
    {label: 'Fecha pase a contable', fieldName: 'fechaPaseContable', type: 'date', sortable: true},
    {label: 'Situación SF', fieldName: 'situacion', type: 'text', sortable: true},
    {label: 'Fecha Situación', fieldName: 'fechaSituacion', type: 'date', sortable: true},
    {label: 'Compromiso Pago', fieldName: 'fechaCompromisoPago', type: 'date', cellAttributes: { class: { fieldName: 'icono' } } ,sortable: true}, 
    {label: 'Alerta SIREC', fieldName: 'alerta', type: 'text', sortable: true} 
];
const columnsFormulario = [
    {label: 'Cliente',  fieldName: 'idCliente',  type: 'url',  typeAttributes: {label: { fieldName: 'cliente' }}, sortable: true }, 
    {label: 'Tipo', fieldName: 'tipo', type: 'text', sortable: true},
    {label: 'Formulario',  fieldName: 'idFormulario',  type: 'url',  typeAttributes: {label: { fieldName: 'formNombre' }}, sortable: true },     
    {label: 'Fecha Situación', fieldName: 'fechaSituacion', type: 'date', sortable: true},   
    {label: 'Estado', fieldName: 'estado', type: 'text', sortable: true},
    {label: 'Última modificación', fieldName: 'lastModified', type: 'date', sortable: true},  
    {label: 'Deuda Total', fieldName: 'deudaTotal', type: 'currency', sortable: true}
];

const columnsFormularioSincronizar = [
    {label: 'Cliente',  fieldName: 'idCliente',  type: 'url',  typeAttributes: {label: { fieldName: 'cliente' }}, sortable: true },    
    {label: 'Formulario',  fieldName: 'idFormulario',  type: 'url',  typeAttributes: {label: { fieldName: 'formNombre' }}, sortable: true },     
    {label: 'Fecha Situación', fieldName: 'fechaSituacion', type: 'date', sortable: true}
];

const columnsAcciones = [
    {label: 'Acción',  fieldName: 'idAccion',  type: 'url',  typeAttributes: {label: { fieldName: 'accionNombre' }}, sortable: true }, 
    {label: 'Tipo', fieldName: 'tipo', type: 'text', sortable: true},
    {label: 'Resultado', fieldName: 'resultado', type: 'text', sortable: true},
    {label: 'Interviniente',  fieldName: 'idCliente',  type: 'url',  typeAttributes: {label: { fieldName: 'cliente' }}, sortable: true }, 
    {label: 'Situación', fieldName: 'situacion', type: 'text', sortable: true},        
    {label: 'Fecha Situación', fieldName: 'fechaSituacion', type: 'date', sortable: true}
];

export default class Sir_lwc_HomeImpaAutoRefresh extends LightningElement {

    // Cajitas
    @track arrayTitulosCajitas = [];
    @track cajitas;
    @track estrategiasImpaCodigo = [];
    @track numCajitasFila = '';
    @track numTotalCajitas = 0;

    @track listCharts;
    @track resultQueryReport;
    @track procesos;
    @track columnsProceso = columnsProceso; 
    @track formularios;
    @track columnsFormulario = columnsFormulario;
    @track formulariosSincronizar;
    @track columnsFormularioSincronizar = columnsFormularioSincronizar;
    @track acciones;
    @track columnsAcciones = columnsAcciones;
    @track informeProcesosActivos;
    @track informeFormulariosPendientes;
    @track informeFormulariosSincro;
    @track informeAcciones;
    @track informeProcesosEstrategias;
    @track defaultSortDirection = 'asc';
    
    @track numTotalFormularios = 0;
    @track numTotalFormulariosCurso = 0;
    @track numTotalAcciones = 0;
    @track numTotalProcesosActivo = 0;

    @api hasHeader;
    @api headerIcon;
    @api headerTitle;
    @api headerSubtitle;
    @api listDatasets;

    @track sortDirection = 'asc';
    @track sortDirectionFormularioSincro = 'asc';
    @track sortDirectionFormularioCurso = 'asc';
    @track sortDirectionAcciones = 'asc';
    @track sortedBy;
    @track sortedByFormularioCurso;
    @track sortedByFormularioSincro;
    @track sortedByAcciones;    

    @track now = Date.now();
    @track wiredResultProcesos= [];
    @track wiredResultFormularios=[];
    @track wiredResultAcciones=[];

    @track showTableAccionesSincronizar = false;
    @track showTableFormulariosSincronizar = false;

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
        this.numTotalFormularios = 0;
        this.numTotalAcciones = 0;
        this.numTotalFormulariosCurso = 0;
        this.numTotalProcesosActivo = 0;
        this.procesos = null;
        this.formularios = null;
        this.formulariosSincronizar = null;
        this.acciones = null;
        this.informeProcesosActivos = null;
        this.informeFormulariosPendientes = null;
        this.informeFormulariosSincro = null;
        this.informeAcciones = null;
        this.informeProcesosEstrategias = null;
        this.showTableAccionesSincronizar = false;
        this.showTableFormulariosSincronizar = false;
        
        this.numTotalCajitas = 0;
        this.numCajitasFila = '';
        this.numMaxCajitasPorLinea = 0;

        getAgrupacionesEstrategias({}).then(resultAgrupaciones => {       
            this.estrategiasImpaCodigo = [];
            this.arrayTitulosCajitas = []; 
            // Montamos las Estrategias Dinamicas, creando las variables con las estrategias
            for(let i = 0; i < resultAgrupaciones.length; i++){ 
                // Miramos cuantas cajas por linea es el maximo, lo miramos mediante el 'maxCajas'
                if(resultAgrupaciones[i].Name === 'maxCajas'){
                    this.numMaxCajitasPorLinea = resultAgrupaciones[i].SIREC__SIREC_fld_Codigo__c;
                } else {
                    if(!this.estrategiasImpaCodigo.includes(resultAgrupaciones[i].SIREC__SIREC_fld_CodigoAgrupador__c)){
                        this.arrayTitulosCajitas.push(resultAgrupaciones[i].SIREC__SIREC_fld_DescAgrupador__c);
                        this.estrategiasImpaCodigo.push(resultAgrupaciones[i].SIREC__SIREC_fld_CodigoAgrupador__c);
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
                var currentData = [];            
                for(let i = 0; i < result.data.length; i++){       
                    // Cajitas
                    if(result.data[i].SIR_agrupacionSituacion__c === 'Pendiente'){ 
                        if(result.data[i].SIREC__SIREC_fld_codigoAgrupador__c !== undefined){
                            if(this.estrategiasImpaCodigo.includes(result.data[i].SIREC__SIREC_fld_codigoAgrupador__c)){
                                let numArray = this.estrategiasImpaCodigo.indexOf(result.data[i].SIREC__SIREC_fld_codigoAgrupador__c);
                                estrategiasCajitas[numArray] = estrategiasCajitas[numArray] + 1;
                            }    
                        }                                            
                    }  
                    // Tabla Procesos Activos
                    // Calculamos los procesos ya inicioados pero que no esten finalizados
                    if(result.data[i].SIR_fld_Situacion_SF__c !== 'SF_INIGEST'){ 
                        let rowData = {};
                        if(result.data[i].SIREC__SIREC_fld_cliente__c != null){
                            rowData.idCliente = '/lightning/r/Account/' + result.data[i].SIREC__SIREC_fld_cliente__c + '/view';
                            rowData.cliente = result.data[i].SIREC__SIREC_fld_cliente__r.Name;
                        } 
                        rowData.estrategia = result.data[i].estrategia;
                        rowData.fechaEstrategia = result.data[i].SIR_FechaInicioEstrategia__c;                    
                        rowData.idProceso = '/lightning/r/SIREC__SIREC_obj_proceso__c/' + result.data[i].Id + '/view';
                        rowData.procesoNombre = result.data[i].Name;  
                        rowData.fechaInicio = result.data[i].SIREC__SIREC_fld_fechaInicio__c;
                        if (result.data[i].SIR_FechaPaseContable__c === undefined) {
                            rowData.fechaPaseContable = '';
                        } else {
                            rowData.fechaPaseContable = result.data[i].SIR_FechaPaseContable__c;
                        }
                        if(result.data[i].SIR_DeudaTotal__c === undefined){
                            rowData.deudaTotal = ''; 
                        } else {
                            rowData.deudaTotal = result.data[i].SIR_DeudaTotal__c; 
                        }
                        if(result.data[i].SIR_DeudaVencidaImpagada__c === undefined){
                            rowData.deudaVencida = ''; 
                        } else {
                            rowData.deudaVencida = result.data[i].SIR_DeudaVencidaImpagada__c; 
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
                        if(result.data[i].SIR_FechaCompromisoPago__c === undefined){
                            rowData.fechaCompromisoPago = ''; 
                        } else {
                            rowData.fechaCompromisoPago = result.data[i].SIR_FechaCompromisoPago__c; 
                        }  
                        if(result.data[i].SIR_CompromisoPagoIncumplido__c === undefined){
                            rowData.icono = ''; 
                        } else {
                            if(result.data[i].SIR_CompromisoPagoIncumplido__c.includes('Red')){
                                rowData.icono = 'rojo';
                            } else {
                                rowData.icono = 'naranja';  
                            }
                        }                              
                        rowData.situacion = result.data[i].situacion;       
                        rowData.fechaSituacion = result.data[i].SIREC__SIREC_fld_fechaSituacion__c;                                                  
                        currentData.push(rowData);
                        this.numTotalProcesosActivo = this.numTotalProcesosActivo + 1;
                    }  
                    this.procesos = currentData;               
                    // Ordenamos por el campo Fecha Situacion
                    let cloneData = [...this.procesos];
                    cloneData.sort(this.sortBy('fechaSituacion', -1, undefined));
                    this.procesos = cloneData;
                    this.sortDirection = 'desc';
                    this.sortedBy = 'fechaSituacion';                 
                    
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
                }    
                // Query para traernos los formualrios  
                getQueryFormularios({}).then(result => { 
                    if(result){ 
                        let currentDataForm = [];
                        let currentDataFormSincro = []; 
                        for(let i = 0; i < result.length; i++){      
                            // Calculamos los formualrios ya iniciados y los pendientes de sincronizar                    
                            let rowData = {};
                            if(result[i].SIR_Persona__c != null){
                                rowData.idCliente = '/lightning/r/Account/' + result[i].SIR_Persona__c + '/view';
                                rowData.cliente = result[i].SIR_Persona__r.Name;
                            } 
                            rowData.tipo = result[i].RecordType.Name;                   
                            rowData.idFormulario = '/lightning/r/SIR_FormularioRefinanciacion__c/' + result[i].Id + '/view';
                            rowData.formNombre = result[i].Name;  
                            rowData.fechaSituacion = result[i].SIR_fechaSituacion__c;
                            rowData.estado = result[i].SIR_Estado__c;
                            rowData.lastModified = result[i].LastModifiedDate;
                            if(result[i].SIR_deudaTotal__c === undefined){
                                rowData.deudaTotal = ''; 
                            } else {
                                rowData.deudaTotal = result[i].SIR_deudaTotal__c; 
                            } 
                            currentDataForm.push(rowData);
                            this.numTotalFormulariosCurso = this.numTotalFormulariosCurso + 1;
            
                            // Calculamos los formualrios ya inicioados pero que no esten finalizados
                            if(result[i].SIR_Estado__c === 'Pendiente de enviar'){  
                                let rowData = {};
                                if(result[i].SIR_Persona__c != null){
                                    rowData.idCliente = '/lightning/r/Account/' + result[i].SIR_Persona__c + '/view';
                                    rowData.cliente = result[i].SIR_Persona__r.Name;
                                }                   
                                rowData.idFormulario = '/lightning/r/SIR_FormularioRefinanciacion__c/' + result[i].Id + '/view';
                                rowData.formNombre = result[i].Name;  
                                rowData.fechaSituacion = result[i].SIR_fechaSituacion__c;                                      
                                currentDataFormSincro.push(rowData);
                                this.numTotalFormularios = this.numTotalFormularios + 1;                                    
                                this.showTableFormulariosSincronizar = true;
                            }
                        }                        
                        // Ponemos los resultados de formularios en Curso y Pendientes de Sincro en la variable de front
                        this.formularios = currentDataForm;
                        // Ponemos los resultados de formularios pendientes sincronizar en la variable de front
                        this.formulariosSincronizar = currentDataFormSincro;              
                    }

                    // Query para traernos las Acciones pendientes de sincronizar 
                    getQueryAcciones({}).then(result => { 
                        if(result){ 
                            let currentDataAcciones = []; 
                            for(let i = 0; i < result.length; i++){            
                                // Calculamos las Acciones              
                                let rowData = {};
                                if(result[i].SIREC__SIREC_fld_interviniente__c != null){
                                    rowData.idCliente = '/lightning/r/Account/' + result[i].SIREC__SIREC_fld_interviniente__c + '/view';
                                    rowData.cliente = result[i].SIREC__SIREC_fld_interviniente__r.Name;
                                } 
                                rowData.tipo = result[i].SIREC__SIREC_fld_tipo__c;                   
                                rowData.idAccion = '/lightning/r/SIREC__SIREC_obj_acciones__c/' + result[i].Id + '/view';
                                rowData.accionNombre = result[i].Name;  
                                rowData.resultado = result[i].SIREC__SIREC_fld_resultado__c;
                                rowData.situacion = result[i].SIREC__SIREC_fld_proceso__r.SIR_fld_Situacion_SF__c;
                                rowData.fechaSituacion = result[i].SIREC__SIREC_fld_proceso__r.SIREC__SIREC_fld_fechaSituacion__c;
                                currentDataAcciones.push(rowData);
                                this.numTotalAcciones = this.numTotalAcciones + 1;
                                this.showTableAccionesSincronizar = true;
                            }
                            // Ponemos los resultados de formularios en Curso en la variable de front
                            this.acciones = currentDataAcciones;
                        }

                        // Query para traernos los ID's de los reports para que puedan ver el informe entero
                        getQueryReports({}).then(result => {
                            // El resultado de la query esta ordenado alfabeticamente por apiname del report
                            // Por lo que la posicion es determinante para saber que report es   
                            this.resultQueryReport = result;
                            // Posicion 0 (cero) esta el report de Formularios pendientes de sincro
                            this.informeFormulariosSincro = '/lightning/r/Report/' + this.resultQueryReport[0].Id + '/view';
                            // Posicion 1 esta el report de Acciones pendientes de sincro
                            this.informeAcciones =  '/lightning/r/Report/' + this.resultQueryReport[1].Id + '/view';                         
                            // Posicion 8 esta el report de Formularios en Curso
                            this.informeFormulariosPendientes = '/lightning/r/Report/' + this.resultQueryReport[3].Id + '/view';
                            // Posicion 9 esta el report de Procesos Estrategias
                            this.informeProcesosEstrategias = '/lightning/r/Report/' + this.resultQueryReport[4].Id + '/view'; 
                            // Posicion 10 esta el report de Procesos Activos
                            this.informeProcesosActivos = '/lightning/r/Report/' + this.resultQueryReport[5].Id + '/view';                        
                        
                            // Montamos la estructura de datos de las cajitas Pendiente Inicio Gestion por Estrategia
                            this.cajitas = [];
                            for(let i = 0; i < this.arrayTitulosCajitas.length; i++){
                                let cajitaIndividual = [];
                                cajitaIndividual.titulo = this.arrayTitulosCajitas[i];
                                // Posicion 2 resultante de la query es el report de Estrategias Dinamicas
                                cajitaIndividual.url = '/lightning/r/Report/' + this.resultQueryReport[2].Id + '/view?fv0='+this.estrategiasImpaCodigo[i];
                                cajitaIndividual.numTotal = estrategiasCajitas[i];
                                this.cajitas.push(cajitaIndividual);
                            }                                     
                        })
                        .catch(error => {
                            this.mensajeError = error;
                        });
                    })
                    .catch(error => {
                        this.mensajeError = error;
                    });
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
    
    // Tabla ProcesosActivos
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
        this.sortDirection = sortDirection;
        this.sortedBy = sortedBy;       
    }
    // Tabla Formularios en curso
    sortedByFormularioCurso(field, reverse, primer) {
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
    onHandleSortFormularioCurso(event) {
        const { fieldName: sortedBy, sortDirection } = event.detail;
        const cloneData = [...this.formularios];
        if(sortedBy === 'idCliente'){
			cloneData.sort(this.sortBy('cliente', sortDirection === 'asc' ? 1 : -1));
		} else if(sortedBy === 'idFormulario'){
			cloneData.sort(this.sortBy('formNombre', sortDirection === 'asc' ? 1 : -1));
		} else {
			cloneData.sort(this.sortBy(sortedBy, sortDirection === 'asc' ? 1 : -1));
		}
        this.formularios = cloneData;
        this.sortDirectionFormularioCurso = sortDirection;
        this.sortedByFormularioCurso = sortedBy;
    }
    // Tabla Formularios pendiente Sincro
    sortedByFormularioSincro(field, reverse, primer) {
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
    onHandleSortFormularioSincro(event) {
        const { fieldName: sortedBy, sortDirection } = event.detail;
        const cloneData = [...this.formulariosSincronizar];
        if(sortedBy === 'idCliente'){
			cloneData.sort(this.sortBy('cliente', sortDirection === 'asc' ? 1 : -1));
		} else if(sortedBy === 'idFormulario'){
			cloneData.sort(this.sortBy('formNombre', sortDirection === 'asc' ? 1 : -1));
		} else {
			cloneData.sort(this.sortBy(sortedBy, sortDirection === 'asc' ? 1 : -1));
		}
        this.formulariosSincronizar = cloneData;
        this.sortDirectionFormularioSincro = sortDirection;
        this.sortedByFormularioSincro = sortedBy;        
    }
    // Tabla Acciones
    sortedByAcciones(field, reverse, primer) {
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
        const cloneData = [...this.acciones];
        if(sortedBy === 'idCliente'){
			cloneData.sort(this.sortBy('cliente', sortDirection === 'asc' ? 1 : -1));
		} else if(sortedBy === 'idAccion'){
			cloneData.sort(this.sortBy('accionNombre', sortDirection === 'asc' ? 1 : -1));
		} else {
			cloneData.sort(this.sortBy(sortedBy, sortDirection === 'asc' ? 1 : -1));
		}
        this.acciones = cloneData;
        this.sortDirectionAcciones = sortDirection;
        this.sortedByAcciones = sortedBy;      
    }            
}