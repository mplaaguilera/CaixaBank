import { LightningElement, track, api, wire } from 'lwc';
import { CloseActionScreenEvent } from 'lightning/actions';
import queryContratos from '@salesforce/apex/SIR_LCMP_EditarContratosFormulario.queryContratos';
import queryContratatosFormulario from '@salesforce/apex/SIR_LCMP_EditarContratosFormulario.queryContratatosFormulario';
import apexCrearBorrarRegistros from '@salesforce/apex/SIR_LCMP_EditarContratosFormulario.apexCrearBorrarRegistros';
import apexQueryContratosConDeuda from '@salesforce/apex/SIR_LCMP_NewFormRefi.queryContratosConDeuda';
import apexQueryContratosSinDeuda from '@salesforce/apex/SIR_LCMP_NewFormRefi.queryContratosSinDeuda';

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

export default class Sir_lwc_EditarContratosFormulario extends LightningElement {
    contratosConDeuda = [];
    contratosSinDeuda = [];
    columnsContratoDeuda = columnsContratoDeuda;
    columnsContratoSinDeuda = columnsContratoSinDeuda;
    
    @api recordId;  
    @track idAccount;
    @track idProceso;
    @track preSelectedContractConDeuda = [];
    @track preSelectedContractSinDeuda = [];
    @track selectedContractIdConDeuda = [];
    @track selectedContractIdSinDeuda = [];
    @track mensajeError;
    @track mostrarError = false;
    @track noHayContratosDeuda = false;
    @track noHayContratosSin = false;
    @track mostrarCrear = false;   
    @track showButton = false;
    @track showFormComponent = false;    
    @track mostrarParteCero = true;
    @track mostrarContratosDeuda = false;
    @track mostrarContratosSinDeuda = false;
    @track mostrarContinuar = true;
    @track tituloMensaje = 'Recuerda: ';
    // @track mensajeInicial = 'Para los clientes con préstamos hipotecarios, vivienda habitual, que manifiesten tener dificultades de pago y se encuentren en el umbral de exclusión, se les informará puntualmente de la existencia del Código de Buenas Prácticas.';
    @track mensajeInicial = 'Al añadir o eliminar contratos al Formulario se recalcularán los valores de la pestaña Cargas Financieras y los valores editados se perderán.';
    @track disableSave = true;
    @track disableCancel = false;
    @track disableContinuar = true;

    @wire(queryContratos, { idFormulario: '$recordId'})
    queryContratos({ error, data }) {               
        if(data){
            var dataTemporal = data.split('*');
            this.idAccount = dataTemporal[0];
            this.idProceso= dataTemporal[1];
            // Llamamos al metodo apexQueryContratosConDeuda del controlador externo para traer los contratos CON deuda
            apexQueryContratosConDeuda({idAccount: this.idAccount}).then(result => {                
                if(result){
                    let currentData = [];
                    for (var i = 0; i < result.length; i++) {
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

                    // Llamamos al metodo apexQueryContratosSinDeuda del controlador externo para traer los contratos SIN deuda 
                    apexQueryContratosSinDeuda({idAccount: this.idAccount}).then(result => {
                        if(result){
                            let currentData = [];
                            for (var i = 0; i < result.length; i++) {
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
                            // Llamamos al metodo queryContratatosFormulario del controlador externo para trae los contratos que ya existen en el Formulario
                            queryContratatosFormulario({idProceso: this.idProceso}).then(result => {                                
                                if(result){                                  
                                    var idSelectedConDeuda = [];
                                    for (var i = 0; i < result.length; i++) {
                                        for (var j = 0; j < this.contratosConDeuda.length; j++) {                                            
                                            if(result[i].SIREC__SIREC_fld_contract__c == this.contratosConDeuda[j].idContract){                                                
                                                idSelectedConDeuda.push(this.contratosConDeuda[j].idContract);                                                                                          
                                            }  
                                        }                                
                                    }
                                    this.preSelectedContractConDeuda = idSelectedConDeuda;
                                    this.selectedContractIdConDeuda = this.preSelectedContractConDeuda;                                  
                                    var idSelectedSinDeuda = [];
                                    for (var i = 0; i < result.length; i++) {
                                        for (var j = 0; j < this.contratosSinDeuda.length; j++) {
                                            if(result[i].SIREC__SIREC_fld_contract__c == this.contratosSinDeuda[j].idContract){
                                                idSelectedSinDeuda.push(this.contratosSinDeuda[j].idContract); 
                                            }  
                                        }                                
                                    }
                                    this.preSelectedContractSinDeuda = idSelectedSinDeuda; 
                                    this.selectedContractIdSinDeuda = this.preSelectedContractSinDeuda;   
                                    this.disableContinuar = false;                               
                                }                 
                            })
                            .catch(error => {
                                this.mensajeError = error;
                                this.mostrarError = true;
                            });  
                        }                 
                        })
                    .catch(error => {
                        this.mostrarError = true;
                    });  
                }
            })
            .catch(error => {
                this.mostrarError = true;
            });                
        }
    }
   
    continuar(){
        this.mostrarParteCero = false;
        this.mostrarContinuar = false;       
        if(this.contratosConDeuda.length === 0){
            this.noHayContratosDeuda = true;
            this.mostrarContratosDeuda = false;
        }else{
            this.mostrarContratosDeuda = true;
        } 
        if(this.contratosSinDeuda.length === 0){
            this.noHayContratosSin = true;
            this.mostrarContratosSinDeuda = false;
        } else {
            this.mostrarContratosSinDeuda = true;
        }
        this.mostrarCrear = true;                     
    }
   
    // Recogemos los id de las filas seleccionadas de la tabla de Contratos Con deuda
    getSelectedIdConDeuda(event) {        
        this.selectedContractIdConDeuda = [];
        const selectedRows = event.detail.selectedRows;
        for (let i = 0; i < selectedRows.length; i++){
            this.selectedContractIdConDeuda.push(selectedRows[i].idContract);             
        }
        if(this.selectedContractIdConDeuda.length !== 0 || this.selectedContractIdSinDeuda.length !== 0){
            this.disableSave = false; 
        } else {
            this.disableSave = true; 
        }
        
    }

    // Recogemos los id de las filas seleccionadas de la tabla de Contratos Sin deuda
    getSelectedIdSinDeuda(event) {
        this.selectedContractIdSinDeuda = [];
        const selectedRows = event.detail.selectedRows;
        for (let i = 0; i < selectedRows.length; i++){
            this.selectedContractIdSinDeuda.push(selectedRows[i].idContract);
        }
        if(this.selectedContractIdSinDeuda.length !== 0 || this.selectedContractIdConDeuda.length !== 0 ){
            this.disableSave = false; 
        } else {
            this.disableSave = true; 
        }        
    }

    // Boton guardar
    guardar() {
        this.disableSave = true;
        this.disableCancel = true;
        var idsContratosSeleccionados = [];            
        if(this.selectedContractIdSinDeuda != undefined && this.selectedContractIdSinDeuda.length !== 0){
            idsContratosSeleccionados.push(this.selectedContractIdSinDeuda); 
        } 
        if(this.selectedContractIdConDeuda != undefined && this.selectedContractIdConDeuda.length !== 0){
          idsContratosSeleccionados.push(this.selectedContractIdConDeuda); 
        }
        idsContratosSeleccionados = idsContratosSeleccionados.toString();
        var idsContratosAntiguos = [];        
        if(this.preSelectedContractSinDeuda != undefined && this.preSelectedContractSinDeuda.length !== 0){
            idsContratosAntiguos.push(this.preSelectedContractSinDeuda ); 
        } 
        if(this.preSelectedContractConDeuda  != undefined && this.preSelectedContractConDeuda.length !== 0){
            idsContratosAntiguos.push(this.preSelectedContractConDeuda); 
        } 
        idsContratosAntiguos = idsContratosAntiguos.toString();     
        // Llamamos al metodo apexCrearBorrarRegistros del controlador externo para realizar la creacion de registros y borrar los relaciones que ya no se desean 
        apexCrearBorrarRegistros({idFormulario: this.recordId, idProceso: this.idProceso, idAccount: this.idAccount, contractsAntiguos: idsContratosAntiguos, contractsNuevos: idsContratosSeleccionados}).then(result => {
            if(result == 'OK'){
                window.location.reload();
            } else {
                this.mensajeError = result;
                this.mostrarError = true;
                this.disableCancel = false;
            }            
        })
        .catch(error => {
            this.mensajeError = error;
            this.mostrarError = true;
        });    
    }
    
    // Para cerrar el modal
    closeAction(){        
        this.showFormComponent = false;
        this.mostrarParteCero = true;
        this.mostrarContratosDeuda = false;
        this.mostrarContratosSinDeuda = false;
        this.noHayContratosDeuda = false;
        this.noHayContratosSin = false;
        this.mostrarError = false;
        this.mostrarContinuar = true;
        this.mostrarCrear = false; 
        this.dispatchEvent(new CloseActionScreenEvent());       
    }
}