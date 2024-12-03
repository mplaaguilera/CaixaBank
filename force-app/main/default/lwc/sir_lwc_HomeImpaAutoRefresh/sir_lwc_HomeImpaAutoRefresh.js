import { LightningElement, api, wire, track } from 'lwc';
import { NavigationMixin, CurrentPageReference } from 'lightning/navigation';
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
    @track listCharts;
    @track arrayTitulosCajitas = ['E.1 – Frenar pase a contable', 'E.2 – Nuevos impagos', 'E.3 – Cura del subjetivo', 'E.4 – Frenar pase a siguiente tramo', 'E.5 – Colectivos Prioritarios', 'E.6 – Otras Estrategias'];
    @track cajitas;
    @track estrategiasImpa = ['10001','10002', '10003','10004', '10005', '10006'];
    @track estrategiasImpaOFI = ['30016','30017', '30018','30019', '30071', '30020'];
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

    /**
     * Executed when Aura parent component detects its tab is focused.
     */
     @api
     refreshCmp() {
        refreshApex(this.wiredResultProcesos);
        //refreshApex(this.wiredResultFormularios);
        //refreshApex(this.wiredResultAcciones);
        // Ponemos en la variable el dia y la hora actual
        this.now = Date.now();
    }

    @wire(CurrentPageReference)
    setCurrentPageReference(currentPageReference) {
        refreshApex(this.wiredResultProcesos);
        //refreshApex(this.wiredResultFormularios);
        //refreshApex(this.wiredResultAcciones);
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
        this.formulariosSincronizar;
        this.acciones = null;
        this.informeProcesosActivos = null;
        this.informeFormulariosPendientes = null;
        this.informeFormulariosSincro = null;
        this.informeAcciones = null;
        this.informeProcesosEstrategias = null;
        if(result.data){ 
            let estrategia1 = 0;
            let estrategia2 = 0;
            let estrategia3 = 0;
            let estrategia4 = 0;
            let estrategia5 = 0;
            let estrategia6 = 0;
            let currentData = [];
            for(let i = 0; i < result.data.length; i++){        
                // Calculamos los procesos que tienen la situacion 'Pendiente Inicio Gestion' y los clasificiamos por estrategia
                if(result.data[i].SIR_fld_Situacion_SF__c == 'SF_INIGEST'){                
                    if(result.data[i].SIREC__SIREC_fld_estrategia__c == this.estrategiasImpa[0] || result.data[i].SIREC__SIREC_fld_estrategia__c == this.estrategiasImpaOFI[0]){
                        estrategia1 = estrategia1 + 1;
                    }
                    if(result.data[i].SIREC__SIREC_fld_estrategia__c == this.estrategiasImpa[1] || result.data[i].SIREC__SIREC_fld_estrategia__c == this.estrategiasImpaOFI[1]){
                        estrategia2 = estrategia2 + 1;
                    }
                    if(result.data[i].SIREC__SIREC_fld_estrategia__c == this.estrategiasImpa[2] || result.data[i].SIREC__SIREC_fld_estrategia__c == this.estrategiasImpaOFI[2]){
                        estrategia3 = estrategia3 + 1;
                    }
                    if(result.data[i].SIREC__SIREC_fld_estrategia__c == this.estrategiasImpa[3] || result.data[i].SIREC__SIREC_fld_estrategia__c == this.estrategiasImpaOFI[3]){
                        estrategia4 = estrategia4 + 1;
                    }
                    if(result.data[i].SIREC__SIREC_fld_estrategia__c == this.estrategiasImpa[4] || result.data[i].SIREC__SIREC_fld_estrategia__c == this.estrategiasImpaOFI[4]){
                        estrategia5 = estrategia5 + 1;
                    }
                    if(result.data[i].SIREC__SIREC_fld_estrategia__c == this.estrategiasImpa[5] || result.data[i].SIREC__SIREC_fld_estrategia__c == this.estrategiasImpaOFI[5]){
                        estrategia6 = estrategia6 + 1;
                    }  
                } 
                // Calculamos los procesos ya inicioados pero que no esten finalizados
                if(result.data[i].SIR_fld_Situacion_SF__c != 'SF_INIGEST'){ 
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
                    if (result.data[i].SIR_FechaPaseContable__c == undefined) {
                        rowData.fechaPaseContable = ''
                    } else {
                        rowData.fechaPaseContable = result.data[i].SIR_FechaPaseContable__c;
                    }
                    if(result.data[i].SIR_DeudaTotal__c == undefined){
                        rowData.deudaTotal = ''; 
                    } else {
                        rowData.deudaTotal = result.data[i].SIR_DeudaTotal__c; 
                    }
                    if(result.data[i].SIR_DeudaVencidaImpagada__c == undefined){
                        rowData.deudaVencida = ''; 
                    } else {
                        rowData.deudaVencida = result.data[i].SIR_DeudaVencidaImpagada__c; 
                    }
                    if(result.data[i].SIR_MaximoDiasImpago__c == undefined){
                        rowData.diasImpago = ''; 
                    } else {
                        rowData.diasImpago = result.data[i].SIR_MaximoDiasImpago__c; 
                    }
                    if(result.data[i].SIR_AlertaSIREC__c == undefined){
                        rowData.alerta = ''; 
                    } else {
                        rowData.alerta = result.data[i].SIR_AlertaSIREC__c; 
                    }  
                    if(result.data[i].SIR_FechaCompromisoPago__c == undefined){
                        rowData.fechaCompromisoPago = ''; 
                    } else {
                        rowData.fechaCompromisoPago = result.data[i].SIR_FechaCompromisoPago__c; 
                    }  
                    if(result.data[i].SIR_CompromisoPagoIncumplido__c == undefined){
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
            }

            // Pendientes Inicio Gestion y su clasificacion por estrategia
            var estrategiasCajitas = [];
            estrategiasCajitas.push(estrategia1);
            estrategiasCajitas.push(estrategia2);
            estrategiasCajitas.push(estrategia3);
            estrategiasCajitas.push(estrategia4);
            estrategiasCajitas.push(estrategia5);
            estrategiasCajitas.push(estrategia6);

            // Ponemos los resultados de procesos ya iniciados en la variable de front
            this.procesos = currentData;     
            // Ordenamos por el campo Alerta
            let cloneData = [...this.procesos];
            cloneData.sort(this.sortBy('alerta', -1, undefined));
            this.procesos = cloneData;
            this.sortDirection = 'desc';
            this.sortedBy = 'alerta';

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
                        if(result[i].SIR_deudaTotal__c == undefined){
                            rowData.deudaTotal = ''; 
                        } else {
                            rowData.deudaTotal = result[i].SIR_deudaTotal__c; 
                        } 
                        currentDataForm.push(rowData);
                        this.numTotalFormulariosCurso = this.numTotalFormulariosCurso + 1;
        
                        // Calculamos los formualrios ya inicioados pero que no esten finalizados
                        if(result[i].SIR_Estado__c == 'Pendiente de enviar'){  
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
                        this.informeFormulariosSincro =  '/lightning/r/Report/' +  this.resultQueryReport[0].Id + '/view';
                        // Posicion 1 esta el report de Acciones pendientes de sincro
                        this.informeAcciones =  '/lightning/r/Report/' +  this.resultQueryReport[1].Id + '/view'; 
                        // Montamos la estructura de datos de las cajitas Pendiente Inicio Gestion por Estrategia
                        this.cajitas = [];
                        for(let i = 0; i <= 5; i++){
                            let cajitaIndividual = [];
                            cajitaIndividual.titulo = this.arrayTitulosCajitas[i];
                            // Posicion de la 2 a la 7 esta el report estrategias
                            cajitaIndividual.url = '/lightning/r/Report/' +  this.resultQueryReport[i+2].Id + '/view';
                            cajitaIndividual.numTotal = estrategiasCajitas[i];
                            this.cajitas.push(cajitaIndividual);
                        }
                        // Posicion 8 esta el report de Formularios en Curso
                        this.informeFormulariosPendientes =  '/lightning/r/Report/' +  this.resultQueryReport[8].Id + '/view';
                        // Posicion 9 esta el report de Procesos Estrategias
                        this.informeProcesosEstrategias =  '/lightning/r/Report/' +  this.resultQueryReport[9].Id + '/view'; 
                        // Posicion 10 esta el report de Procesos Activos
                        this.informeProcesosActivos =  '/lightning/r/Report/' +  this.resultQueryReport[10].Id + '/view'; 
              
                        // Ponemos en la variable el dia y la hora actual.
                        this.now = Date.now();           
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
    }

    /*@wire(getQueryFormularios, {})
    wiredDataForm(result) {
        this.wiredResultFormularios = result;        
        if(result.data){ 
            let currentDataForm = [];
            let currentDataFormSincro = []; 
            for(let i = 0; i < result.data.length; i++){            
                // Calculamos los formualrios ya iniciados y los pendientes de sincronizar                    
                let rowData = {};
                if(result.data[i].SIR_Persona__c != null){
                    rowData.idCliente = '/lightning/r/Account/' + result.data[i].SIR_Persona__c + '/view';
                    rowData.cliente = result.data[i].SIR_Persona__r.Name;
                } 
                rowData.tipo = result.data[i].RecordType.Name;                   
                rowData.idFormulario = '/lightning/r/SIR_FormularioRefinanciacion__c/' + result.data[i].Id + '/view';
                rowData.formNombre = result.data[i].Name;  
                rowData.fechaSituacion = result.data[i].SIR_fechaSituacion__c;
                rowData.estado = result.data[i].SIR_Estado__c;
                rowData.lastModified = result.data[i].LastModifiedDate;
                if(result.data[i].SIR_deudaTotal__c == undefined){
                    rowData.deudaTotal = ''; 
                } else {
                    rowData.deudaTotal = result.data[i].SIR_deudaTotal__c; 
                } 
                currentDataForm.push(rowData);
                this.numTotalFormulariosCurso = this.numTotalFormulariosCurso + 1;

                // Calculamos los formualrios ya inicioados pero que no esten finalizados
                if(result.data[i].SIR_Estado__c == 'Pendiente de enviar'){  
                    let rowData = {};
                    if(result.data[i].SIR_Persona__c != null){
                        rowData.idCliente = '/lightning/r/Account/' + result.data[i].SIR_Persona__c + '/view';
                        rowData.cliente = result.data[i].SIR_Persona__r.Name;
                    }                   
                    rowData.idFormulario = '/lightning/r/SIR_FormularioRefinanciacion__c/' + result.data[i].Id + '/view';
                    rowData.formNombre = result.data[i].Name;  
                    rowData.fechaSituacion = result.data[i].SIR_fechaSituacion__c;                                      
                    currentDataFormSincro.push(rowData);
                    this.numTotalFormularios = this.numTotalFormularios + 1;
                }
            }
            // Ponemos los resultados de formularios en Curso y Pendientes de Sincro en la variable de front
            this.formularios = currentDataForm;
            // Ponemos los resultados de formularios pendientes sincronizar en la variable de front
            this.formulariosSincronizar = currentDataFormSincro;              
        }     
    }*/

    // Query para traernos las Acciones pendientes de sincronizar
    /*@wire(getQueryAcciones, {})
    wiredDataAcciones(result) {
        this.wiredResultAcciones = result;       
        if(result.data){ 
            let currentDataAcciones = []; 
            for(let i = 0; i < result.data.length; i++){            
                // Calculamos las Acciones              
                let rowData = {};
                if(result.data[i].SIREC__SIREC_fld_interviniente__c != null){
                    rowData.idCliente = '/lightning/r/Account/' + result.data[i].SIREC__SIREC_fld_interviniente__c + '/view';
                    rowData.cliente = result.data[i].SIREC__SIREC_fld_interviniente__r.Name;
                } 
                rowData.tipo = result.data[i].SIREC__SIREC_fld_tipo__c;                   
                rowData.idAccion = '/lightning/r/SIREC__SIREC_obj_acciones__c/' + result.data[i].Id + '/view';
                rowData.accionNombre = result.data[i].Name;  
                rowData.resultado = result.data[i].SIREC__SIREC_fld_resultado__c;
                rowData.situacion = result.data[i].SIREC__SIREC_fld_proceso__r.SIR_fld_Situacion_SF__c;
                rowData.fechaSituacion = result.data[i].SIREC__SIREC_fld_proceso__r.SIREC__SIREC_fld_fechaSituacion__c;
                currentDataAcciones.push(rowData);
                this.numTotalAcciones = this.numTotalAcciones + 1;
            }
            // Ponemos los resultados de formularios en Curso en la variable de front
            this.acciones = currentDataAcciones;
        }     
    }*/

    goReport(event){
        let urlReport = event.target.dataset.url;
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: urlReport,
                objectApiName: 'Report',
                actionName: 'view'
            }           
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
        cloneData.sort(this.sortBy(sortedBy, sortDirection === 'asc' ? 1 : -1));
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
        cloneData.sort(this.sortBy(sortedBy, sortDirection === 'asc' ? 1 : -1));
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
        cloneData.sort(this.sortBy(sortedBy, sortDirection === 'asc' ? 1 : -1));
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
        cloneData.sort(this.sortBy(sortedBy, sortDirection === 'asc' ? 1 : -1));
        this.acciones = cloneData;
        this.sortDirectionAcciones = sortDirection;
        this.sortedByAcciones = sortedBy;
    }

            
}