import { LightningElement, track, api, wire } from 'lwc';
import { CloseActionScreenEvent } from 'lightning/actions';
import { NavigationMixin,CurrentPageReference } from 'lightning/navigation';
import apexCrearRegistros from '@salesforce/apex/SIR_LCMP_NewFormRefi.crearRegistros';
import apexQueryContratosConDeuda from '@salesforce/apex/SIR_LCMP_NewFormRefi.queryContratosConDeuda';
import apexQueryContratosSinDeuda from '@salesforce/apex/SIR_LCMP_NewFormRefi.queryContratosSinDeuda';

import isEnabledNuevoProceso from '@salesforce/apex/SIR_LCMP_NewFormRefi.isEnabledNuevoProceso';

const columnsContratoDeuda = [
    { label: 'Número de Contrato', fieldName: 'numContract', type: 'text', initialWidth: 126, typeAttributes: { tooltip: { fieldName: 'idContract' } }},
    { label: 'Producto', fieldName: 'tipoCon', type: 'text' },
    { label: 'Situación contable', fieldName: 'situacionContable', type: 'text' },
    { label: 'Situación Administrativa', fieldName: 'situacionMorosidad', type: 'text' },
    { label: 'Cuota', fieldName: 'cuota', type: 'currency' },    
    { label: 'Deuda total', fieldName: 'deudaTotal', type: 'currency' },
    { label: 'Deuda Pendiente de vencer', fieldName: 'deudaPendiente', type: 'currency' },
    { label: 'Deuda Vencida', fieldName: 'deudaImpagada', type: 'currency' },
    { label: 'Días Impagados', fieldName: 'diasImpago', type: 'number' }
];
const columnsContratoSinDeuda = [
    { label: 'Número de Contrato', fieldName: 'numContract', type: 'text', initialWidth: 126, typeAttributes: { tooltip: { fieldName: 'idContract' } }},
    { label: 'Producto', fieldName: 'tipoCon', type: 'text' },
    { label: 'Situación contable', fieldName: 'situacionContable', type: 'text' },
    { label: 'Situación Administrativa', fieldName: 'situacionMorosidad', type: 'text' }, 
    { label: 'Cuota', fieldName: 'cuota', type: 'currency' },   
    { label: 'Deuda total', fieldName: 'deudaTotal', type: 'currency' },
    { label: 'Deuda Pendiente de vencer', fieldName: 'deudaPendiente', type: 'currency' },
    { label: 'Deuda Vencida', fieldName: 'deudaImpagada', type: 'currency' },
    { label: 'Días Impagados', fieldName: 'diasImpago', type: 'number' }
];

export default class Sir_lwc_NewFormRefi extends NavigationMixin(LightningElement) {
    contratosConDeuda = [];
    contratosSinDeuda = [];
    columnsContratoDeuda = columnsContratoDeuda;
    columnsContratoSinDeuda = columnsContratoSinDeuda;
    
    @api recordId;   
    selectedContractIdConDeuda;
    selectedContractIdSinDeuda;
    idsContratosSeleccionados;
    @track mensajeError;
    @track mostrarError = false;

    //@track mostrarParteUno = true;
    @track mostrarParteUno = false;
    @track mostrarParteDos = false;

    @track noHayContratosDeuda = false;
    @track noHayContratosSin = false;

    /* P2253-712 - Modificacion HSC 02/12/2022 - Mostrar todo en una pantalla unificada */
    //@track mostrarSiguiente = false;
    //@track infoPaso = 'Paso 1: Selecciona los contratos a refinanciar';
    @track title = 'Nuevo Proceso de Refinanciación';
    @track mostrarCrear = false;
    

    @track showButton = false;
    @track showFormComponent = false;

    /* P2253-569 - INICIO Modificacion HSC 25/10/2022 - Mostrar mensaje inicial antes de comenzar el proceso de Refi*/
    @track mostrarParteCero = true;
    @track mostrarContinuar = true;
    @track tituloMensaje = 'Recuerda: ';
    @track mensajeInicial = 'Para los clientes con préstamos hipotecarios, vivienda habitual, que manifiesten tener dificultades de pago y se encuentren en el umbral de exclusión, se les informará puntualmente de la existencia del Código de Buenas Prácticas y se recogerá su firma en el anexo informativo.';
    @track disableSave = false;
    /* P2253-569 - FIN Modificacion HSC 25/10/2022 - Mostrar mensaje inicial antes de comenzar el proceso de Refi*/

    @wire(CurrentPageReference)
    getStateParameters(currentPageReference) {
       if (currentPageReference) {       
            // Llamamos al metodo apexQueryContratosConDeuda del controlador externo para traer los contratos CON deuda
            apexQueryContratosConDeuda({idAccount: this.recordId}).then(result => {                
                if(result){
                    let currentData = [];
                    for (var i = 0; i < result.length; i++) {
                        //for (var i = 0; i < 10 && i < result.length; i++) {
                        let rowData = {};
                        if(result[i].SIREC__SIREC_fld_contract__c != null){                            
                            rowData.idContract = result[i].SIREC__SIREC_fld_contract__c;   
                            rowData.numContract = result[i].SIREC__SIREC_fld_contract__r.SIREC__SIREC_fld_numeContrato__c;                    
                            rowData.tipoCon = result[i].SIREC__SIREC_fld_contract__r.SIREC__SIREC_fld_tipoContrato__c;                        
                            rowData.situacionContable = result[i].SIREC__SIREC_fld_contract__r.SIREC__SIREC_fld_sitContable__c;
                            rowData.situacionMorosidad = result[i].SIREC__SIREC_fld_contract__r.SIREC__SIREC_fld_sitMorosidade__c;
                            rowData.cuota = result[i].SIREC__SIREC_fld_contract__r.SIREC__SIREC_fld_importeImpagado__c;
                            rowData.deudaTotal = result[i].SIREC__SIREC_fld_contract__r.SIREC__SIREC_fld_deudaTotalContrato__c;
                            rowData.deudaPendiente = result[i].SIREC__SIREC_fld_contract__r.SIREC__SIREC_fld_deudaPendienteVencimiento__cc;
                            rowData.deudaImpagada = result[i].SIREC__SIREC_fld_contract__r.SIREC__SIREC_fld_deudaVencidaImpagada__c;
                            rowData.diasImpago = result[i].SIREC__SIREC_fld_contract__r.SIREC__SIREC_fld_diasImpagados__c;
                        }
                        currentData.push(rowData);
                    }      
                    this.contratosConDeuda = currentData;
                    /*if(this.contratosConDeuda.length == 0){
                        this.noHayContratosDeuda = true;
                        this.mostrarParteUno = false;
                    }else{
                        this.mostrarParteUno = true;
                    }*/

                    // Llamamos al metodo apexQueryContratosSinDeuda del controlador externo para traer los contratos SIN deuda 
                    apexQueryContratosSinDeuda({idAccount: this.recordId}).then(result => {
                        if(result){
                            let currentData = [];
                            for (var i = 0; i < result.length; i++) {
                            //for (var i = 0; i < 10 && i < result.length; i++) {
                                let rowData = {};
                                if(result[i].SIREC__SIREC_fld_contract__c != null){
                                    rowData.idContract = result[i].SIREC__SIREC_fld_contract__c;   
                                    rowData.numContract = result[i].SIREC__SIREC_fld_contract__r.SIREC__SIREC_fld_numeContrato__c;                    
                                    rowData.tipoCon = result[i].SIREC__SIREC_fld_contract__r.SIREC__SIREC_fld_tipoContrato__c;                        
                                    rowData.situacionContable = result[i].SIREC__SIREC_fld_contract__r.SIREC__SIREC_fld_sitContable__c;
                                    rowData.situacionMorosidad = result[i].SIREC__SIREC_fld_contract__r.SIREC__SIREC_fld_sitMorosidade__c;
                                    rowData.cuota = result[i].SIREC__SIREC_fld_contract__r.SIREC__SIREC_fld_importeImpagado__c;
                                    rowData.deudaTotal = result[i].SIREC__SIREC_fld_contract__r.SIREC__SIREC_fld_deudaTotalContrato__c;
                                    rowData.deudaPendiente = result[i].SIREC__SIREC_fld_contract__r.SIREC__SIREC_fld_deudaPendienteVencimiento__cc;
                                    rowData.deudaImpagada = result[i].SIREC__SIREC_fld_contract__r.SIREC__SIREC_fld_deudaVencidaImpagada__c;
                                    rowData.diasImpago = result[i].SIREC__SIREC_fld_contract__r.SIREC__SIREC_fld_diasImpagados__c;
                                }
                                currentData.push(rowData);
                            }      
                            this.contratosSinDeuda = currentData;  
                        }                 
                    })
                    .catch(error => {
                       // this.mensajeError = error;
                        this.mostrarError = true;
                    });  
                }
            })
            .catch(error => {
                //this.mensajeError = error;
                this.mostrarError = true;
            });              
       }
    }

    renderedCallback() {
        isEnabledNuevoProceso({idAccount: this.recordId}).then(result => {
            this.showButton = result; 
        });
    }
    showForm() {
        this.showFormComponent = true;
    }

    /* P2253-569 - INICIO Modificacion HSC 25/10/2022 - Mostrar mensaje inicial antes de comenzar el proceso de Refi*/
    continuar(){
        this.title = 'SELECCIONA LOS CONTRATOS A REFINANCIAR';
        this.mostrarParteCero = false;
        this.mostrarContinuar = false;
        //this.mostrarSiguiente = true;

        if(this.contratosConDeuda.length === 0){
            this.noHayContratosDeuda = true;
            this.mostrarParteUno = false;
        }else{
            this.mostrarParteUno = true;
        }

        /* P2253-712 - Modificacion HSC 02/12/2022 - Mostrar todo en una pantalla unificada */
        if(this.contratosSinDeuda.length === 0){
            this.noHayContratosSin = true;
            this.mostrarParteDos = false;
        } else {
            this.mostrarParteDos = true;
        }
        this.mostrarCrear = true;        
    }
    /* P2253-569 - FIN Modificacion HSC 25/10/2022 - Mostrar mensaje inicial antes de comenzar el proceso de Refi*/


    // Boton SIGUIENTE
    /* P2253-712 - Modificacion HSC 02/12/2022 - Mostrar todo en una pantalla unificada
    siguiente(){
        this.noHayContratosDeuda = false;
        this.mostrarSiguiente = false;
        this.mostrarParteUno = false;
        this.infoPaso = 'Paso 2: Seleccione los contratos sin impago';
        if(this.contratosSinDeuda.length == 0){
            this.noHayContratosSin = true;
            this.mostrarParteDos = false;
        }else{
            this.mostrarParteDos = true;
        }  
        this.mostrarCrear = true;   
    }*/

    // Recogemos los id de las filas seleccionadas de la tabla de Contratos Con deuda
    getSelectedIdConDeuda(event) {        
        this.selectedContractIdConDeuda = [];
        const selectedRows = event.detail.selectedRows;
        for (let i = 0; i < selectedRows.length; i++){
            this.selectedContractIdConDeuda.push(selectedRows[i].idContract);             
        }
    }


    // Recogemos los id de las filas seleccionadas de la tabla de Contratos Sin deuda
    getSelectedIdSinDeuda(event) {
        this.selectedContractIdSinDeuda = [];
        const selectedRows = event.detail.selectedRows;
        for (let i = 0; i < selectedRows.length; i++){
            this.selectedContractIdSinDeuda.push(selectedRows[i].idContract);
        }
    }


    // Boton CREAR
    crear() {
        this.idsContratosSeleccionados = [];

        if(this.selectedContractIdConDeuda == undefined && this.selectedContractIdSinDeuda != undefined){
            this.idsContratosSeleccionados.push(this.selectedContractIdSinDeuda); 
        } else if(this.selectedContractIdConDeuda != undefined && this.selectedContractIdSinDeuda == undefined){
            this.idsContratosSeleccionados.push(this.selectedContractIdConDeuda); 
        } else{
            this.idsContratosSeleccionados.push(this.selectedContractIdConDeuda); 
            this.idsContratosSeleccionados.push(this.selectedContractIdSinDeuda);
        } 
    
        this.idsContratosSeleccionados = this.idsContratosSeleccionados.toString();

            // Llamamos al metodo apexCrearRegistros del controlador externo para realizar la creacion de registros       
            apexCrearRegistros({idAccount: this.recordId, idContracts: this.idsContratosSeleccionados}).then(result => {
                this.selectedContractId = null;
                // Navega al nuevo registro de Formulario (SIR_FormularioRefinanciacion__c) 
                this[NavigationMixin.Navigate]({
                    type:'standard__recordPage',
                    attributes:{
                        "recordId": result,
                        "objectApiName": "SIR_FormularioRefinanciacion__c",
                        "actionName": "view"
                    }
                }); 
                this.closeAction();
            })
            .catch(error => {
                //this.mensajeError = error;
                this.mostrarError = true;
            });     
    }

    /* P2253-569 - INICIO Modificacion HSC 25/10/2022 - Mostrar mensaje inicial antes de comenzar el proceso de Refi*/
    // Para cerrar el modal
    /*closeAction(){
        this.showFormComponent = false;
        this.infoPaso = 'Paso 1: Seleccione los contratos con impago';
        this.mostrarSiguiente = true;
        this.mostrarCrear = false; 
        this.mostrarParteUno = true;
        this.mostrarParteUno = false;
        this.this.mostrarParteDos = false;
        this.contratosConDeuda = [];
        this.contratosSinDeuda = [];
    }*/
    // Para cerrar el modal
    closeAction(){
        this.showFormComponent = false;
        this.mostrarParteCero = true;
        this.mostrarParteUno = false;
        this.mostrarParteDos = false;
        this.noHayContratosDeuda = false;
        this.noHayContratosSin = false;
        this.mostrarError = false;

        this.title = 'Nuevo Proceso de Refinanciación';
        //this.infoPaso = 'Paso 1: Seleccione los contratos con impago';
        this.mostrarContinuar = true;
        //this.mostrarSiguiente = false;
        this.mostrarCrear = false; 
       
        //this.contratosConDeuda = [];
        //this.contratosSinDeuda = [];
    }
    /* P2253-569 - FIN Modificacion HSC 25/10/2022 - Mostrar mensaje inicial antes de comenzar el proceso de Refi*/
}