import { LightningElement, track, api, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { CloseActionScreenEvent } from 'lightning/actions';
import uId from '@salesforce/user/Id';
import { /*getObjectInfo,*/ getPicklistValuesByRecordType } from 'lightning/uiObjectInfoApi';
//import LightningAlert from "lightning/alert";


import comprobarPropietarioProceso from '@salesforce/apex/SIR_LCMP_accionSinWorkflow.comprobarPropietarioProceso';
import comprobarPropietarioAccion from '@salesforce/apex/SIR_LCMP_accionSinWorkflow.comprobarPropietarioAccion';
import getProceso from '@salesforce/apex/SIR_LCMP_accionSinWorkflow.getProceso';
import getAccion from '@salesforce/apex/SIR_LCMP_accionSinWorkflow.getAccion';
import getPicklistIntervinientes from '@salesforce/apex/SIR_LCMP_accionSinWorkflow.getPicklistIntervinientes';
import insertAccion from '@salesforce/apex/SIR_LCMP_accionSinWorkflow.insertAccion';
import updateAccion from '@salesforce/apex/SIR_LCMP_accionSinWorkflow.updateAccion';
import enviarAccion from '@salesforce/apex/SIR_LCMP_accionSinWorkflow.enviarAccion';
//import buscarIdsProceso from '@salesforce/apex/SIR_LCMP_accionSinWorkflow.buscarIdsProceso';
import buscarIdsAccion from '@salesforce/apex/SIR_LCMP_accionSinWorkflow.buscarIdsAccion';
import ACCIONES_OBJECT from '@salesforce/schema/SIREC__SIREC_obj_acciones__c';

import {loadStyle } from 'lightning/platformResourceLoader';
import recurso from '@salesforce/resourceUrl/SIR_proceso';


export default class Sir_lwc_accionSinWorkflow extends LightningElement {
    @api recordId;
    @api objectApiName;
    @track recordIdAccion;
    @track activarFechaCompromiso = false;

    @track recordTypeId;
    @track rtIdAccPRESOL;
    @track rtIdAccIMPA;
    @track accionesMetadata;

    @track nuevaAccion = false;
    @track titulo = null;
    @track errorPropietario = false;
    @track errorComentario = false;
    @track errorFecha = false;
    @track errorGeneral = false;
    @track mensajeError = null;
    @track codigoError = null;
    @track mensajeKO = false;
    @track formularioVisible = false;

    @track disabledCerrar = false;
    @track disabledGuardar = true;
    @track botonGuardar = false;
    @track nombreBoton = null;

    @track proceso = null;
    @track nombreProceso = null;
    @track estrategia = null;
    @track descEstrategia = null;
    @track fechaContacto = null;
    @track fechaCompromisoPago = null;
    @track fechaMinima = null;

    @track valueTipo = null;
    @track valueResultado = null;
    @track valueAccion = null;
    @track comentarios = '';
    @track responsable = null;
    @track optionsInterviniente = [];
    @track optionsResultado = [];
    
    @track interviniente = null;
    @track disableAcciones = true;
    @track disableResultado = true;
    @track disableResponsable = false;
    @track disableFechaContacto = false;
    @track disableTipo = false;
    @track disableInterviniente = false;
    @track disableComentario = false;
    @track disableFechaCompromiso = false;
    
    @track form = [];
    @track userId = uId;
    @track idAccion = null;
    @track accion = null;
    @track errorWS = false;
    
    @track fichaProceso = false;
    @track fichaAccion = false;

    @track recordTypeIdProcesoPresol;
    @track recordtypeAccionPresol;
    @track recordtypeAccionAmistoso;

    // cargamos con el recurso estatico los estilos
    connectedCallback(){
        loadStyle(this, recurso);
    }

   /* @wire(getObjectInfo, { objectApiName: ACCIONES_OBJECT })
    accionObjectInfo;

    @wire(getObjectInfo, { objectApiName: PROCESOS_OBJECT })
    procesoObjectInfo;

    @wire(getObjectInfo, {objectApiName: ACCIONES_OBJECT})
    accionesMetadata;*/
    
    @wire(getPicklistValuesByRecordType, { objectApiName: ACCIONES_OBJECT, recordTypeId: '$recordtypeAccionAmistoso' })
    resultPicklistValuesImpa;

    @wire(getPicklistValuesByRecordType, { objectApiName: ACCIONES_OBJECT, recordTypeId: '$recordtypeAccionPresol' })
    resultPicklistValuesPresol;

    
    @wire(getProceso, { idProceso: '$recordId'})
    getProceso({ error, data }) {
        if(data){
            /*const rtisAcc = this.accionesMetadata.data.recordTypeInfos;
            this.rtIdAccPRESOL = Object.keys(rtisAcc).find(rti => rtisAcc[rti].name === 'Acción Preventivo');
            this.rtIdAccIMPA = Object.keys(rtisAcc).find(rti => rtisAcc[rti].name === 'Acción Amistoso');*/
            //buscarIdsProceso({}).then(result => {
                //this.recordTypeIdProcesoPresol = result;                        
                buscarIdsAccion({}).then(result => { 
                    this.recordtypeAccionAmistoso = result;
                    // Si hay resultado es Nueva Accion
                    if(data.length > 0){
                        this.proceso = data; 
                        this.nombreProceso = this.proceso[0].Name;
                        this.estrategia = this.proceso[0].SIREC__SIREC_fld_estrategia__c;
                        this.descEstrategia = this.proceso[0].SIREC__SIREC_fld_descEstrategiaCatalogo__c;
                        /*if(this.proceso[0].RecordTypeId === this.recordTypeIdProcesoPresol){
                            this.recordIdAccion = this.recordtypeAccionPresol;
                            this.fechaMinima = this.proceso[0].SIR_fechaCarga__c;                 
                        } else {*/
                            this.recordIdAccion = this.recordtypeAccionAmistoso;
                            this.fechaMinima = this.proceso[0].SIREC__SIREC_fld_fechaInicio__c;
                        //}
                        this.titulo = 'Nueva'; 
                        // Comprobamos si es propietario del proceso
                        comprobarPropietarioProceso({idProceso: this.recordId}).then(result => {                   
                            if(result === 'OK'){                                           
                                this.crearFormAccion();
                            } else {
                                this.mensajeError = result;
                                this.errorPropietario = true; 
                            }                         
                        })
                        .catch(error => {
                            this.mensajeError = error;
                            this.errorPropietario = true;    
                        });
                    } else {
                        // Es una modificacion de accion
                        this.nuevaAccion = false;
                        this.titulo = 'Modificación';
                        // Comprobamos si es propietario de la accion
                        comprobarPropietarioAccion({idAccion: this.recordId}).then(result => {                     
                            if(result === 'OK'){                    
                                this.informarFormAccion();                       
                            } else {
                                this.mensajeError = result;
                                this.errorPropietario = true;   
                            }    
                        })
                        .catch(error => {
                            this.mensajeError = error;
                            this.errorPropietario = true;  
                        });                
                    }                  
                })
                .catch(error => {
                    this.mensajeError = error;  
                });                               
                             
        }
    }  


    crearFormAccion(){
        this.nuevaAccion = true;
        this.botonGuardar = true;
        this.nombreBoton = 'Guardar';               
        var today = new Date();
        if(this.fechaContacto === '' ||  this.fechaContacto == null){
            this.fechaContacto = today.toISOString();            
        }
         
        getPicklistIntervinientes({idProceso: this.recordId}).then(result => { 
            this.optionsInterviniente = result; 
            for (var i = 0; i < result.length; i++) {
                if(result[i].value === this.proceso[0].SIREC__SIREC_fld_cliente__c){
                    this.interviniente = result[i].value;
                }
            }                     
            this.responsable = this.userId;   
            this.formularioVisible = true;          
        });                    
    }


    informarFormAccionProceso(idAccion){  
        this.idAccion = idAccion; 

        var today = new Date();
        if(this.fechaContacto === '' ||  this.fechaContacto === null){
            this.fechaContacto = today.toISOString();            
        }
        getAccion({idAccion: this.idAccion}).then(result => { 
            this.accion = result;                      
            this.disableAcciones = false;
            this.disableResultado = false;            
            getPicklistIntervinientes({idProceso: this.accion[0].SIREC__SIREC_fld_proceso__c}).then(result => { 
                this.optionsInterviniente = result; 
                for (var i = 0; i < result.length; i++) {
                    if(result[i].value === this.accion[0].SIREC__SIREC_fld_proceso__r.SIREC__SIREC_fld_cliente__c){
                        this.interviniente = result[i].value;
                    }
                } 
                this.nombreProceso = this.accion[0].SIREC__SIREC_fld_proceso__r.Name;
                // Informamos los campos del form con el resultado de la query de Accion
                this.userId = this.accion[0].SIREC__SIREC_fld_responsable__c;
                this.fechaContacto = this.accion[0].SIREC__SIREC_fld_fechaContacto__c;
                this.valueTipo = this.accion[0].SIREC__SIREC_fld_tipo__c;                        
                this.interviniente = this.accion[0].SIREC__SIREC_fld_interviniente__c;
                this.comentarios = this.accion[0].SIREC__SIREC_fld_comentarios__c;
                this.responsable = this.accion[0].SIREC__SIREC_fld_responsable__c;
                this.valueAccion = this.accion[0].SIREC__SIREC_fld_accion__c;
                this.valueResultado = this.accion[0].SIREC__SIREC_fld_resultado__c;
                /*if (this.accion[0].record === this.recordTypeIdProcesoPresol) {
                    this.fechaMinima = this.accion[0].SIR_fechaCarga__c;                 
                } else {*/
                    this.fechaMinima = this.data[0].SIREC__SIREC_fld_fechaInicio__c;
                //}
                //Se mira el estado de la accion y si está en Pendiente sincronización se bloquea la edicion de los campos
                if(this.accion[0].SIREC__SIREC_fld_estado__c === 'Pendiente Sincronización'){
                    this.disableAcciones = true;
                    this.disableResultado = true;
                    this.disableResponsable = true;
                    this.disableFechaContacto = true;
                    this.disableTipo = true;
                    this.disableInterviniente = true;
                    this.disableComentario = true;

                    this.nombreBoton = 'Enviar';
                }else{
                    this.nombreBoton = 'Guardar';
                }

                this.botonGuardar = true; 
                this.disabledGuardar = false;
                this.formularioVisible = true;
                                      
            });
        }); 
    }

    informarFormAccion(){          
        var today = new Date();
        if(this.fechaContacto === '' ||  this.fechaContacto == null){
            this.fechaContacto = today.toISOString();            
            this.today = this.fechaContacto;
        }      
        getAccion({idAccion: this.recordId}).then(result => { 
            this.accion = result;                      
            this.disableAcciones = false;
            this.disableResultado = false; 
            
            /*if(this.accion[0].SIREC__SIREC_fld_proceso__r.RecordTypeId === this.recordTypeIdProcesoPresol){
                this.recordIdAccion = this.recordtypeAccionPresol;
                this.fechaMinima = this.accion[0].SIREC__SIREC_fld_proceso__r.SIR_fechaCarga__c        
            } else {*/
                this.recordIdAccion = this.recordtypeAccionAmistoso;
                this.fechaMinima = this.accion[0].SIREC__SIREC_fld_proceso__r.SIREC__SIREC_fld_fechaInicio__c        
            //}

            getPicklistIntervinientes({idProceso: this.accion[0].SIREC__SIREC_fld_proceso__c}).then(result => { 
                this.optionsInterviniente = result; 
                for (var i = 0; i < result.length; i++) {
                    if(result[i].value === this.accion[0].SIREC__SIREC_fld_proceso__r.SIREC__SIREC_fld_cliente__c){
                        this.interviniente = result[i].value;
                    }
                } 
                this.nombreProceso = this.accion[0].SIREC__SIREC_fld_proceso__r.Name;
                // Informamos los campos del form con el resultado de la query de Accion
                this.userId = this.accion[0].SIREC__SIREC_fld_responsable__c;
                this.fechaContacto = this.accion[0].SIREC__SIREC_fld_fechaContacto__c;
                this.valueTipo = this.accion[0].SIREC__SIREC_fld_tipo__c;                        
                this.interviniente = this.accion[0].SIREC__SIREC_fld_interviniente__c;
                this.comentarios = this.accion[0].SIREC__SIREC_fld_comentarios__c;
                this.responsable = this.accion[0].SIREC__SIREC_fld_responsable__c;
                this.valueAccion = this.accion[0].SIREC__SIREC_fld_accion__c;
                this.valueResultado = this.accion[0].SIREC__SIREC_fld_resultado__c;
                if(this.accion[0].SIR_FechaCompromisoPago__c != null && this.accion[0].SIR_FechaCompromisoPago__c !== ''){
                    this.fechaCompromiso = this.accion[0].SIR_FechaCompromisoPago__c;
                }                

                //Se mira el estado de la accion y si está en Pendiente sincronización se bloquea la edicion de los campos
                if(this.accion[0].SIREC__SIREC_fld_estado__c === 'Pendiente Sincronización'){
                    this.disableAcciones = true;
                    this.disableResultado = true;
                    this.disableResponsable = true;
                    this.disableFechaContacto = true;
                    this.disableTipo = true;
                    this.disableInterviniente = true;
                    this.disableComentario = true;
                    this.disableFechaCompromiso = true;

                    this.nombreBoton = 'Enviar';
                }else{
                    this.nombreBoton = 'Guardar';
                } 
                this.botonGuardar = true; 
                this.disabledGuardar = false;
                this.formularioVisible = true; 
                
                let key = this.resultPicklistValuesImpa.data.picklistFieldValues.SIREC__SIREC_fld_resultado__c.controllerValues[this.valueAccion];
                //26 en este codigo es el valor de ilocalizado
                //25 en este codigo es el valor de Compromiso de pago incumplido
                //24 en este codigo es el valor de No colabora con acuerdo incumplido
                this.optionsResultado = this.resultPicklistValuesImpa.data.picklistFieldValues.SIREC__SIREC_fld_resultado__c.values.filter(opt => opt.validFor.includes(key)).filter(ilo => !ilo.value.includes(26) && !ilo.value.includes(25) && !ilo.value.includes(24));
                                              
            });
        });                          
    }


    changeFecha(event){ 
        this.fechaContacto = event.target.value;
        /*if(this.interviniente != undefined && this.responsable != undefined && this.responsable != '' && this.valueAccion != undefined && this.valueTipo != undefined
            && this.fechaContacto != undefined){
                this.disabledGuardar = false;
        } else {
            this.disabledGuardar = true;
        }
        //this.comprobarComentario();
        this.comprobarFecha();*/
        this.validaciones();

}

    changeTipo(event){        
        this.disableAcciones = false; 
        this.valueTipo = event.target.value;
        this.valueResultado = null;
        this.validaciones();
        //this.comprobarComentario();
        //this.comprobarFecha();
        //this.disabledGuardar = true;
    }


    changeAccion(event){         
        this.disableResultado = false; 
        this.valueAccion = event.target.value;
        this.valueResultado = null;
        //this.comprobarComentario();
        /*this.comprobarFecha();
        if(this.interviniente != undefined && this.responsable != undefined && this.responsable != '' && this.valueAccion != undefined && this.valueTipo != undefined
            && this.fechaContacto != undefined && this.valueAccion!=''){
                this.disabledGuardar = false;
        } else {
            this.disabledGuardar = true;
        }*/
        this.validaciones();
        let key = this.resultPicklistValuesImpa.data.picklistFieldValues.SIREC__SIREC_fld_resultado__c.controllerValues[this.valueAccion];
        //26 en este codigo es el valor de ilocalizado
        //25 en este codigo es el valor de Compromiso de pago incumplido
        //24 en este codigo es el valor de No colabora con acuerdo incumplido
        this.optionsResultado = this.resultPicklistValuesImpa.data.picklistFieldValues.SIREC__SIREC_fld_resultado__c.values.filter(opt => opt.validFor.includes(key)).filter(ilo => !ilo.value.includes(26) && !ilo.value.includes(25) && !ilo.value.includes(24));
    }
    

    changeResultado(event){ 
        this.valueResultado = event.target.value;  
        this.validaciones();
        //this.comprobarComentario();
        //this.comprobarFecha();
    }

    changeComentarios(event){ 
        this.comentarios = event.target.value;
        this.validaciones();
        //this.comprobarComentario();
    }

    changeResponsable(event){
        this.responsable = event.target.value;
        this.validaciones();

        /*if(this.interviniente != undefined && this.responsable != undefined && this.responsable != '' && this.valueAccion != undefined && this.valueTipo != undefined
            && this.fechaContacto != undefined){
                this.disabledGuardar = false;
        } else {
            this.disabledGuardar = true;
        }*/
        //this.comprobarComentario();
    }

    changeInterviniente(event){
        this.interviniente = event.target.value;
        this.validaciones();

        /*if(this.interviniente != undefined && this.responsable != undefined && this.responsable != '' && this.valueAccion != undefined && this.valueTipo != undefined
            && this.fechaContacto != undefined){
                this.disabledGuardar = false;
        } else {
            this.disabledGuardar = true;
        }*/
        //this.comprobarComentario();    
    }

    changeFechaCompromisoPago(event){ 
        this.fechaCompromisoPago = event.target.value;
        //this.comprobarComentario();
    }

    comprobarValor(valor){
        if(valor === null || valor === undefined){
            valor= '';
        }
        valor = valor.toString();
        return valor;
    }

    validaciones(){
        //Validar que todos los campos requeridos estén informados para activar el botón guardar
        this.errorGeneral = false;
        this.mensajeError = '';        
        if(this.valueResultado === '17'){
            this.activarFechaCompromiso = true;
        } else {
            this.activarFechaCompromiso = false;
            this.fechaCompromisoPago = null;
        }

        //Validación de comentario
        if (this.comentarios != null && this.comentarios.length > 500) {
            this.errorGeneral = true;
            this.mensajeError = this.mensajeError + '-El comentario no puede contener más de 500 caracteres.\n';
        }
        
        let today = new Date();
        today = today.toISOString(); 

        if(this.valueResultado !=='' && this.valueResultado != null && this.valueResultado !== undefined && this.fechaContacto>today){ 
            this.errorGeneral = true;
            this.mensajeError = this.mensajeError + '-La fecha no puede ser superior a la de hoy cuando se tiene un resultado informado. \n'; 
        }

        if (this.fechaContacto < this.fechaMinima) {
            this.errorGeneral = true;
            this.mensajeError = this.mensajeError + '-La fecha no puede ser inferior a la fecha de inicio/carga del proceso.'; 
        }

        if(this.interviniente !== undefined && this.responsable !== undefined && this.responsable !== '' && this.valueAccion !== undefined 
            && this.valueAccion !== '' && this.valueAccion != null && this.valueTipo !== undefined && this.fechaContacto !== undefined && !this.errorGeneral){
            this.disabledGuardar = false;
            if (this.valueResultado !=='' && this.valueResultado != null && this.valueResultado !== undefined) {
                this.nombreBoton = 'Guardar y enviar';
            }else{
                this.nombreBoton = 'Guardar'; 
            }
        }else{
            this.nombreBoton = 'Guardar'; 
            this.disabledGuardar = true;
        }

    }   
    


    save() {
        this.disabledGuardar = true;
        this.disabledCerrar = true;
        this.form = [];
        this.form.push(this.comprobarValor(this.fechaContacto));
        this.form.push(this.comprobarValor(this.valueTipo));
        this.form.push(this.comprobarValor(this.valueAccion));
        this.form.push(this.comprobarValor(this.valueResultado));
        this.form.push(this.comprobarValor(this.comentarios));
        this.form.push(this.comprobarValor(this.responsable));
        this.form.push(this.comprobarValor(this.interviniente));
        this.form.push(this.comprobarValor(this.recordId)); 
        this.form.push(this.comprobarValor(this.estrategia));
        this.form.push(this.comprobarValor(this.fechaCompromisoPago));
        this.form.push(this.comprobarValor(this.descEstrategia));   
          
        if(this.nuevaAccion){
            this.form.push(this.comprobarValor(this.recordIdAccion));
            insertAccion({data: this.form}).then(result => {
                var resultadoInsert = result;
                resultadoInsert = resultadoInsert.split('-');     
                if(resultadoInsert[0] === 'OK'){
                    var resultadoInsertSplit2 = resultadoInsert[1].split('@');       
                    this.idAccion = resultadoInsertSplit2[1];                    
                    if(resultadoInsertSplit2[0] === 'true'){
                        this.idAccion = resultadoInsertSplit2[1];
                        // Se llama al WS porque el resultado esta informado
                        this.enviarAccionWS();
                    } else {                       
                        this.dispatchEvent(
                            new ShowToastEvent({
                                title: 'Creado',
                                message: 'Se ha creado correctamente',
                                variant: 'success',
                                mode: 'pester'
                            })
                        ); 
                        this.dispatchEvent(new CloseActionScreenEvent());
                        window.location.reload();       
                    }                                     
                }               
            })
            .catch(error => {
                this.disabledCerrar = false;
                this.botonGuardar = false;
                this.formularioVisible = false;
                this.mensajeKO = true;
                this.mensajeError = error;
            });
        } else {    //Se modifica         
            this.idAccion = this.recordId;
            updateAccion({data: this.form, idAccion: this.recordId}).then(result => {
                var resultadoUpdate = result;
                resultadoUpdate = resultadoUpdate.split('-');                 
                if(resultadoUpdate[0] === 'OK'){                             
                    if(resultadoUpdate[1] === 'true'){                            
                        // Se llama al WS porque el resultado esta informado
                        this.enviarAccionWS();
                    } else {                     
                        this.dispatchEvent(
                            new ShowToastEvent({
                                title: 'Modificado',
                                message: 'Se ha modificado correctamente',
                                variant: 'success'
                            })
                        );                
                        this.dispatchEvent(new CloseActionScreenEvent());  
                        window.location.reload();    
                    }                                     
                }              
            })
            .catch(error => {
                this.botonGuardar = false;
                this.disabledCerrar = false;
                this.formularioVisible = false;
                this.mensajeKO = true;
                this.mensajeError = error;
            });            
        }                                 
    }

    enviarAccionWS(){   
        enviarAccion({idAccion: this.idAccion}).then(result => {   
            if(result.length >= 0){
                if(result[0] === 'OK'){   
                    if(this.nuevaAccion === true){
                        this.dispatchEvent(
                            new ShowToastEvent({
                                title: 'Creado',
                                message: 'Se ha creado y enviado correctamente',
                                variant: 'success'
                            })
                        );                        
                    } else {
                        this.dispatchEvent(
                            new ShowToastEvent({
                                title: 'Modificado',
                                message: 'Se ha modificado y enviado correctamente',
                                variant: 'success'
                            })
                        );
                    }  
                    this.dispatchEvent(new CloseActionScreenEvent());
                    window.location.reload();                        
                }  else {
                    this.mensajeError = 'Se ha creado/modificado correctamente la acción pero ha ocurrido un problema en la sincronización. ' + result[1];
                    this.codigoError = result[2]; 
                    this.botonGuardar = true;                   
                    this.disabledCerrar = false;  
                    this.mensajeKO = true;
                    this.formularioVisible = false;
                    this.errorWS = true;
                }
            }      
        })
        .catch(error => {
            this.mensajeError = error;
            this.disabledCerrar = false;
            this.mensajeKO = true;
            this.formularioVisible = false;
        });   
    }

    cancel() {
        this.dispatchEvent(new CloseActionScreenEvent());
        window.location.reload();  
    }
}