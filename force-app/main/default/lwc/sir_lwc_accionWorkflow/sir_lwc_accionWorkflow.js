import { LightningElement, track, api,wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { CloseActionScreenEvent } from 'lightning/actions';
import uId from '@salesforce/user/Id';
import getProceso from '@salesforce/apex/SIR_LCMP_accionWorkflow.getProceso';
import getAccionProceso from '@salesforce/apex/SIR_LCMP_accionWorkflow.getAccionProceso';
import getAccion from '@salesforce/apex/SIR_LCMP_accionWorkflow.getAccion';
import getPicklistIntervinientes from '@salesforce/apex/SIR_LCMP_accionWorkflow.getPicklistIntervinientes';
import getPicklistContactos from '@salesforce/apex/SIR_LCMP_accionWorkflow.getPicklistContactos';
import insertAccion from '@salesforce/apex/SIR_LCMP_accionWorkflow.insertAccion';
import updateAccion from '@salesforce/apex/SIR_LCMP_accionWorkflow.updateAccion';
import enviarAccion from '@salesforce/apex/SIR_LCMP_accionWorkflow.enviarAccion';
import buscarIdsAccion from '@salesforce/apex/SIR_LCMP_accionWorkflow.buscarIdsAccion';


import {loadStyle } from 'lightning/platformResourceLoader';
import recurso from '@salesforce/resourceUrl/SIR_proceso';

import { getPicklistValuesByRecordType } from 'lightning/uiObjectInfoApi';
import ACCIONES_OBJECT from '@salesforce/schema/SIREC__SIREC_obj_acciones__c';

export default class Sir_lwc_accionWorkflow extends LightningElement {
    @api recordId;
    @api objectApiName;
    @track objectInfoAcciones;
    @track objectInfoProceso;
    @track rtIdAccPRESOL;
    @track rtIdAccIMPA;
    @track rtIdAccEmpFlujo;
    @track rtIdProcesoPRESOL;
    @track rtIdProcesoIMPA;
    @track rtIdProcesoEmpFlujo;
    @track recordTypeDeveloperNameProceso;

    @track nuevaAccion = false;
    @track titulo = null;
    @track errorPropietario = false;
    @track mensajeError = null;
    @track codigoError = null;
    @track errorGeneral = false;
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
    @track idTarea = null;
    @track fechaContacto = null;
    @track fechaCarga = null;
    @track fechaMinima = null;
    @track tipoTarea = null;
    @track codTarea = null;
    @track recordTypeIdProceso;
    @track recordTypeIdAcc;
    @track idAccount = null;
    
    @track valueTipo = null;
    @track valueResultado = null;
    @track valueAccion = null;
    @track comentarios = null;
    @track responsable = null;
    @track optionsInterviniente = [];
    @track interviniente = null;
    @track optionsResultado = [];
    @track optionsContacto = [];
    @track contacto = null;
    @track contactoCargo = null;
    
    @track disableAcciones = true;
    @track disableResultado = true;
    @track disableResponsable = false;
    @track disableFechaContacto = false;
    @track disableTipo = false;
    @track disableInterviniente = false;
    @track disableComentario = false;
    @track disableContacto = false;
    
    @track form = [];
    @track userId = uId;
    @track idAccion = null;
    @track accion = null;
    @track errorWS = false;
    
    @track fichaProceso = false;
    @track fichaAccion = false;

    @track siguienteTarea = false;
    @track sigTareaRecord = null;
    @track wiredAccion;

    @track isLoaded = false;
    @track mostrarInterviniente = false;
    @track mostrarContacto = false;
    @track recordtypeAccion;


    // cargamos con el recurso estatico los estilos
    connectedCallback(){
        loadStyle(this, recurso);
    }
    
    /*@wire(getObjectInfo, { objectApiName: ACCIONES_OBJECT })
    objectInfoAcciones;
    @wire(getObjectInfo, { objectApiName: PROCESO_OBJECT })
    objectInfoProceso;*/

    
    /*Se obtienen los valores de las Picklist en funcion del RT de Accion*/
    @wire(getPicklistValuesByRecordType, { objectApiName: ACCIONES_OBJECT, recordTypeId: '$rtIdAccPRESOL'})
    resultPicklistValuesPresol;
    @wire(getPicklistValuesByRecordType, { objectApiName: ACCIONES_OBJECT, recordTypeId: '$rtIdAccIMPA'})
    resultPicklistValuesImpa;
    @wire(getPicklistValuesByRecordType, { objectApiName: ACCIONES_OBJECT, recordTypeId: '$rtIdAccEmpFlujo'})
    resultPicklistValuesEmpFlujo;

    /* Se hace consulta sobre el proceso para obtener la información de la tarea */
    @wire(getProceso, { idProceso: '$recordId' }) // objectInfoAcciones: '$objectInfoAcciones', objectInfoProceso: '$objectInfoProceso'
    getProceso(value) { 
        this.wiredAccion = value;
        const { data, error } = value;        
        if(data){
            this.recordTypeDeveloperNameProceso = data[0].RecordType.DeveloperName;
            buscarIdsAccion({rtDevelop : this.recordTypeDeveloperNameProceso}).then(result => { 
                //Se obtiene el rt de Accion del proceso actual
                this.recordtypeAccion = result;

                if(this.recordTypeDeveloperNameProceso === 'SIREC_rt_procesoAmistoso'){ //PROCESO_RECORDTYPE_DEVELOPER_NAME_IMPA
                    this.rtIdAccIMPA = result;
                }else if (this.recordTypeDeveloperNameProceso === 'SIRE_RT_Amistoso') { //PROCESO_RECORDTYPE_DEVELOPER_NAME_EMP_FLUJO
                    this.rtIdAccEmpFlujo = result;
                } else if (this.recordTypeDeveloperNameProceso === 'SIREC_rt_Anticipacion') { //PROCESO_RECORDTYPE_DEVELOPER_NAME_PRESOL
                    this.rtIdAccPRESOL = result;
                }else{
                    return null;
                }

                //Si se ha pulsado sobre el boton "Gestion Tarea Pendiente" en la ficha de PROCESO
                if(data.length > 0){
                    this.fichaProceso = true;
                    this.proceso = data; 
                    this.idAccount = this.proceso[0].SIREC__SIREC_fld_cliente__c;
                    this.idTarea = this.proceso[0].SIREC__SIREC_fld_tarea__c;
                    this.tipoTarea = this.proceso[0].SIREC__SIREC_fld_tarea__r.SIREC__SIREC_fld_tipo_tarea__c;
                    this.codTarea = this.proceso[0].SIREC__SIREC_fld_tarea__r.SIREC__SIREC_fld_codigo_tarea__c;
                    this.recordTypeIdProceso = this.proceso[0].RecordTypeId;

                    //Se setea el id del rt de acción en función del rt del proceso 
                    if(this.recordTypeDeveloperNameProceso === 'SIREC_rt_procesoAmistoso'){
                        this.recordTypeIdAcc = this.rtIdAccIMPA;
                        this.mostrarInterviniente = true;
                        this.mostrarContacto = false;
                        this.fechaMinima = this.proceso[0].SIREC__SIREC_fld_fechaInicio__c;        
                    } else if(this.recordTypeDeveloperNameProceso === 'SIREC_rt_Anticipacion'){
                        this.recordTypeIdAcc = this.rtIdAccPRESOL;
                        this.mostrarInterviniente = true;
                        this.mostrarContacto = false;
                        this.fechaMinima = this.proceso[0].SIR_fechaCarga__c;                               
                    } else if(this.recordTypeDeveloperNameProceso === 'SIRE_RT_Amistoso'){
                        this.recordTypeIdAcc = this.rtIdAccEmpFlujo;
                        this.mostrarInterviniente = false;
                        this.mostrarContacto = true;
                        this.fechaMinima = this.proceso[0].SIREC__SIREC_fld_fechaInicio__c;        
                    } else {
                        this.recordTypeIdAcc = this.rtIdAccIMPA;
                        this.mostrarInterviniente = true;
                        this.mostrarContacto = false;
                        this.fechaMinima = this.proceso[0].SIREC__SIREC_fld_fechaInicio__c;                              
                    }

                    //Comprobamos si ya existe una accion en curso, o si por el contrario es una nueva accion
                    //Se considerean acciones en curso aquellas cuyo estado es: En curso, Enviado, Pendiente de Sincronizar
                    getAccionProceso({idTarea : this.idTarea}).then(result => { 
                        // Es una modificacion de accion desde ficha PROCESO
                        if(result.length > 0){
                            this.accion = result;
                            this.idAccion = this.accion[0].Id;

                            this.nuevaAccion = false;
                            this.titulo = 'Modificación';                        
                            //Mostramos el formulario de modificacion de accion                 
                            this.informarFormAccionProceso(this.idAccion); 
                        } else { //Es una nueva accion
                            this.nombreProceso = this.proceso[0].Name;
                            this.estrategia = this.proceso[0].SIREC__SIREC_fld_estrategia__c;
                            this.descEstrategia = this.proceso[0].SIREC__SIREC_fld_descEstrategiaCatalogo__c;
                            this.titulo = 'Nueva';                                        
                            //Mostramos el formulario de creacion de accion                                         
                            this.crearFormAccion();                            
                        }
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
    }

    /* Método de creacion de pop-up Nueva Accion */
    crearFormAccion(){
        this.nuevaAccion = true;
        this.botonGuardar = true;
        this.nombreBoton = 'Guardar';               
        var today = new Date();
        if(this.fechaContacto === '' ||  this.fechaContacto == null){
            this.fechaContacto = today.toISOString();            
        }
        this.responsable = this.userId;
        if(this.recordTypeDeveloperNameProceso === 'SIRE_RT_Amistoso'){
            getPicklistContactos({idAccount: this.idAccount}).then(result => {
                if(result.length === 0){
                    this.nombreBoton = 'Guardar'; 
                    this.disabledGuardar = true;
                    this.mensajeKO = true;
                    this.mensajeError = 'No existe un Contacto para esta Empresa, por favor cree uno antes de seguir. Puede crearlo en Ficha Cliente, sección Información Clientes, apartado Contactos.'; 
                } else {
                    this.optionsContacto = result;
                    this.interviniente = this.proceso[0].SIREC__SIREC_fld_cliente__c;              
                    this.formularioVisible = true;
                }                                  
            });
        } else {
            getPicklistIntervinientes({idProceso : this.recordId}).then(result => { 
                this.optionsInterviniente = result; 
                for (var i = 0; i < result.length; i++) {
                    if(result[i].value === this.proceso[0].SIREC__SIREC_fld_cliente__c){
                        this.interviniente = result[i].value;
                    }
                }                      
                this.formularioVisible = true;          
            });  
        }                          
    }

    /* Método de creacion de pop-up Modificacion Accion desde ficha Proceso*/
    informarFormAccionProceso(idAccion){  
        this.idAccion = idAccion; 
        var today = new Date();
        if(this.fechaContacto === '' || this.fechaContacto == null){
            this.fechaContacto = today.toISOString();            
        }

        //Se obtiene la info de la accion existente
        getAccion({idAccion: this.idAccion}).then(result => { 
            this.accion = result;                      
            this.disableAcciones = false;
            this.disableResultado = false; 

            if(this.recordTypeDeveloperNameProceso === 'SIRE_RT_Amistoso'){                
                getPicklistContactos({idAccount: this.idAccount}).then(result => {
                    if(result.length === 0){
                        this.nombreBoton = 'Guardar'; 
                        this.disabledGuardar = true;
                        this.mensajeKO = true;
                        this.mensajeError = 'No existe un Contacto para esta Empresa, por favor cree uno antes de seguir. Puede crearlo en Ficha Cliente, sección Información Clientes, apartado Contactos.'; 
                    } else {
                        this.optionsContacto = result; 
                        for (var i = 0; i < result.length; i++) {
                            if(result[i].value === this.accion[0].SIR_contactoAccionEmp__c){
                                this.contacto = result[i].value;
                            }
                        } 
                        this.interviniente = this.proceso[0].SIREC__SIREC_fld_cliente__c;
                        this.continuarInformacionComun();   
                    }                                 
                });
            } else {
                getPicklistIntervinientes({idProceso: this.accion[0].SIREC__SIREC_fld_proceso__c}).then(result => { 
                    this.optionsInterviniente = result; 
                    for (var i = 0; i < result.length; i++) {
                        if(result[i].value === this.accion[0].SIREC__SIREC_fld_proceso__r.SIREC__SIREC_fld_cliente__c){
                            this.interviniente = result[i].value;
                        }
                    } 
                    this.continuarInformacionComun();                                    
                });
            }
        }); 
    }

    continuarInformacionComun(){
        // Informamos los campos del pop-up con el resultado de la query de Accion
        this.nombreProceso = this.accion[0].SIREC__SIREC_fld_proceso__r.Name;        
        this.userId = this.accion[0].SIREC__SIREC_fld_responsable__c;
        this.fechaContacto = this.accion[0].SIREC__SIREC_fld_fechaContacto__c;
        this.valueTipo = this.accion[0].SIREC__SIREC_fld_tipo__c;                        
        this.interviniente = this.accion[0].SIREC__SIREC_fld_interviniente__c;
        this.comentarios = this.accion[0].SIREC__SIREC_fld_comentarios__c;
        this.responsable = this.accion[0].SIREC__SIREC_fld_responsable__c;
        this.valueAccion = this.accion[0].SIREC__SIREC_fld_accion__c;
        this.valueResultado = this.accion[0].SIREC__SIREC_fld_resultado__c;
        //Se filtran valores que no deben aparecer en el campo Resultado
        if(this.recordTypeDeveloperNameProceso === 'SIREC_rt_Anticipacion'){
            let key = this.resultPicklistValuesPresol.data.picklistFieldValues.SIREC__SIREC_fld_resultado__c.controllerValues[this.valueAccion];
            this.optionsResultado = this.resultPicklistValuesPresol.data.picklistFieldValues.SIREC__SIREC_fld_resultado__c.values.filter(opt => opt.validFor.includes(key)).filter(ilo => !ilo.value.includes(26));                 
        } else if(this.recordTypeDeveloperNameProceso === 'SIREC_rt_procesoAmistoso'){
            let key = this.resultPicklistValuesImpa.data.picklistFieldValues.SIREC__SIREC_fld_resultado__c.controllerValues[this.valueAccion];
            this.optionsResultado = this.resultPicklistValuesImpa.data.picklistFieldValues.SIREC__SIREC_fld_resultado__c.values.filter(opt => opt.validFor.includes(key)).filter(ilo => !ilo.value.includes(26) && !ilo.value.includes(25) && !ilo.value.includes(24));
        } else if(this.recordTypeDeveloperNameProceso === 'SIRE_RT_Amistoso'){
            let key = this.resultPicklistValuesEmpFlujo.data.picklistFieldValues.SIREC__SIREC_fld_resultado__c.controllerValues[this.valueAccion];
            this.optionsResultado = this.resultPicklistValuesEmpFlujo.data.picklistFieldValues.SIREC__SIREC_fld_resultado__c.values.filter(opt => opt.validFor.includes(key)).filter(ilo => !ilo.value.includes(26) && !ilo.value.includes(25) && !ilo.value.includes(24));
        }

        //Se mira el estado de la accion y si está en algún estado distinto de "En curso" se bloquea la edicion de los campos
        if(this.accion[0].SIREC__SIREC_fld_estado__c !== 'En curso'){
            this.disableAcciones = true;
            this.disableResultado = true;
            this.disableResponsable = true;
            this.disableFechaContacto = true;
            this.disableTipo = true;
            this.disableInterviniente = true;
            this.disableContacto = true;
            this.disableComentario = true;
            this.nombreBoton = 'Enviar';
        }else{
            this.nombreBoton = 'Guardar';
        }
        this.botonGuardar = true; 
        this.disabledGuardar = false;
        this.formularioVisible = true;
    }

    changeFecha(event){ 
        this.fechaContacto = event.target.value;
        this.validaciones();
    }

    changeTipo(event){        
        this.disableAcciones = false; 
        this.valueTipo = event.target.value;
        this.valueResultado = null;
        this.validaciones();
    }

    changeAccion(event){         
        this.disableResultado = false; 
        this.valueAccion = event.target.value;
        this.valueResultado = null;
        this.validaciones();
        //Se filtran valores que no deben aparecer en el campo Resultado
        if(this.recordTypeDeveloperNameProceso === 'SIREC_rt_Anticipacion'){
            let key = this.resultPicklistValuesPresol.data.picklistFieldValues.SIREC__SIREC_fld_resultado__c.controllerValues[this.valueAccion];
            this.optionsResultado = this.resultPicklistValuesPresol.data.picklistFieldValues.SIREC__SIREC_fld_resultado__c.values.filter(opt => opt.validFor.includes(key)).filter(ilo => !ilo.value.includes(26));                 
        } else if(this.recordTypeDeveloperNameProceso === 'SIREC_rt_procesoAmistoso'){
            let key = this.resultPicklistValuesImpa.data.picklistFieldValues.SIREC__SIREC_fld_resultado__c.controllerValues[this.valueAccion];
            this.optionsResultado = this.resultPicklistValuesImpa.data.picklistFieldValues.SIREC__SIREC_fld_resultado__c.values.filter(opt => opt.validFor.includes(key)).filter(ilo => !ilo.value.includes(26) && !ilo.value.includes(25) && !ilo.value.includes(24));
        } else if(this.recordTypeDeveloperNameProceso === 'SIRE_RT_Amistoso'){            
            let key = this.resultPicklistValuesEmpFlujo.data.picklistFieldValues.SIREC__SIREC_fld_resultado__c.controllerValues[this.valueAccion];
            this.optionsResultado = this.resultPicklistValuesEmpFlujo.data.picklistFieldValues.SIREC__SIREC_fld_resultado__c.values.filter(opt => opt.validFor.includes(key)).filter(ilo => !ilo.value.includes(26) && !ilo.value.includes(25) && !ilo.value.includes(24));
        }
    }

    changeResultado(event){ 
        this.valueResultado = event.target.value; 
        this.validaciones();
    }

    changeComentarios(event){ 
        this.comentarios = event.target.value;
        this.validaciones();
    }

    changeResponsable(event){
        this.responsable = event.target.value;
        this.validaciones();
    }

    changeInterviniente(event){
        this.interviniente = event.target.value;
        this.validaciones();
    }

    changeContacto(event){
        this.contacto = event.target.value;
        for(let i = 0; i < this.optionsContacto.length; i++){ 
            if(this.optionsContacto[i].value === this.contacto){
                this.contactoCargo = this.optionsContacto[i].label;
            }
        }
        this.validaciones();
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
        //Validación de comentario
        if (this.comentarios != null && this.comentarios.length > 500) {
            this.errorGeneral = true;
            this.mensajeError = this.mensajeError + '- El comentario no puede contener más de 500 caracteres.\n';
        }
        
        let today = new Date();
        today = today.toISOString(); 
        if(this.valueResultado !== '' && this.valueResultado != null && this.valueResultado !== undefined && this.fechaContacto>today){ 
            this.errorGeneral = true;
            this.mensajeError = this.mensajeError + '- La fecha no puede ser superior a la de hoy cuando se tiene un resultado informado. \n'; 
        }

        if (this.fechaContacto < this.fechaMinima && this.fechaMinima != null) {
            this.errorGeneral = true;
            this.mensajeError = this.mensajeError + '- La fecha no puede ser inferior a la fecha de inicio/carga del proceso.'; 
        }

        // Si la accion es de recordType EmpFlujo entonces se mira si esta informado el campo Contacto, en caso de cualquier otro RT se da como OK porque no es obligatorio
        var contactoOk = false;
        if(this.recordTypeIdAcc === this.rtIdAccEmpFlujo && this.contacto !== undefined || this.recordTypeIdAcc !== this.rtIdAccEmpFlujo){
            contactoOk = true;
        } else {
            contactoOk = false;
        }
        
        if(this.interviniente !== undefined && this.responsable !== undefined && this.responsable !== '' && this.valueAccion !== undefined 
            && this.valueAccion !== '' && this.valueAccion != null && this.valueTipo !== undefined && this.fechaContacto !== undefined 
            && contactoOk === true && !this.errorGeneral){
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

    /* Método para la creacion/modificacion del registro de Accion */
    save() {
        this.disabledGuardar = true;
        this.disabledCerrar = true;
        //Se recogen y guardan las respuestas seleccionadas por el usuario
        this.form = [];
        this.form.push(this.comprobarValor(this.fechaContacto));
        this.form.push(this.comprobarValor(this.valueTipo));
        this.form.push(this.comprobarValor(this.valueAccion));
        this.form.push(this.comprobarValor(this.valueResultado));
        this.form.push(this.comprobarValor(this.comentarios));
        this.form.push(this.comprobarValor(this.responsable));
        this.form.push(this.comprobarValor(this.interviniente));
        this.form.push(this.comprobarValor(this.recordId));
        this.form.push(this.comprobarValor(this.contacto));
        this.form.push(this.comprobarValor(this.contactoCargo));                 
        this.form.push(this.comprobarValor(this.estrategia));
        this.form.push(this.comprobarValor(this.recordTypeIdAcc));
        this.form.push(this.comprobarValor(this.descEstrategia));
        this.form.push(this.comprobarValor(this.idTarea));

        //Si es una nueva Accion
        if(this.nuevaAccion){
            //Se llama al metodo de creacion de accion
            insertAccion({data: this.form}).then(result => {
                var resultadoInsert = result;
                resultadoInsert = resultadoInsert.split('-');     
                //Si la accion se crea correctamente
                if(resultadoInsert[0] === 'OK'){
                    var resultadoInsertSplit2 = resultadoInsert[1].split('@');       
                    this.idAccion = resultadoInsertSplit2[1]; 
                    //Si el resultado esta informado se llama al WS altaAccion                   
                    if(resultadoInsertSplit2[0] === 'true'){
                        this.idAccion = resultadoInsertSplit2[1];
                        this.enviarAccionWS();
                    } 
                    //Si el resultado no esta informado se cierra el pop-up y se notifica al usuario de la correcta creacion de la accion
                    else {                       
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
                //si la acción no se ha creado correctamente
                else{
                    this.disabledCerrar = false;
                    this.botonGuardar = false;
                    this.formularioVisible = false;
                    this.mensajeKO = true;
                    this.mensajeError = 'Se ha producido un error en la creación de la Acción. Pruebe de nuevo más tarde.';
                }               
            })
            .catch(error => {            
                this.disabledCerrar = false;
                this.botonGuardar = false;
                this.formularioVisible = false;
                this.mensajeKO = true;
                this.mensajeError = error;
            });
        } 
        //Si es una modificacion de una Accion existente
        else {
            //Se modifica desde la Ficha de PROCESO
            if(this.fichaProceso){
                //Se llama al metodo que actualiza la accion
                updateAccion({data: this.form, idAccion: this.idAccion, idProceso: this.recordId}).then(result => {
                    var resultadoUpdate = result;
                    resultadoUpdate = resultadoUpdate.split('-');
                    //Si la modificacion se realiza correctamente                 
                    if(resultadoUpdate[0] === 'OK'){   
                        // Se llama al WS porque el resultado esta informado                          
                        if(resultadoUpdate[1] === 'true'){                            
                            this.enviarAccionWS();    
                        } else {                     
                            this.dispatchEvent(
                                new ShowToastEvent({
                                    title: 'Modificado',
                                    message: 'Se ha modificado correctamente',
                                    variant: 'success',
                                    mode: 'pester'
                                })
                            );                
                            this.dispatchEvent(new CloseActionScreenEvent());  
                            window.location.reload();    
                        }                                     
                    } 
                    //si la acción no se ha modificado correctamente
                    else{
                        this.disabledCerrar = false;
                        this.botonGuardar = false;
                        this.formularioVisible = false;
                        this.mensajeKO = true;
                        this.mensajeError = 'Se ha producido un error en la modificación de la Acción. Pruebe de nuevo más tarde.';
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
    }

    /* Método para enviar el registro de Accion al WS altaAccion */
    enviarAccionWS(){ 
        /* Modificacion HSC 20/10 -- Las acciones no se anidan */
        this.isLoaded = true;

        //Se modifica desde la Ficha de PROCESO
        if(this.fichaProceso){
            enviarAccion({idAccion: this.idAccion, idProceso: this.recordId}).then(result => {   
                if(result.length >= 0){
                    /* Modificacion HSC 20/10 -- Las acciones no se anidan */
                    this.isLoaded = false;
                    //Si el envio ha ido bien y el WS devuelve un OK
                    if(result[0] === 'OK'){  
                        /// cga - si se envia a sirec y ha dado ok se anida
                        this.dispatchEvent(new CustomEvent('siguiente'));
                    }
                    //Si el envio NO ha ido bien y el WS NO devuelve un OK  
                    else {
                        /* Modificacion HSC 20/10 -- Las acciones no se anidan */
                        this.isLoaded = false;                    
                        this.mensajeError = result[1];
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
                /* Modificacion HSC 20/10 -- Las acciones no se anidan */
                this.isLoaded = false;           
                this.mensajeError = error;
                this.disabledCerrar = false;
                this.mensajeKO = true;
                this.formularioVisible = false;
            }); 
        }
    }

    /* Método para cerrar el pop-up de Accion y refrescar */
    cancel() {
        this.dispatchEvent(new CloseActionScreenEvent());
        window.location.reload();
    }
}