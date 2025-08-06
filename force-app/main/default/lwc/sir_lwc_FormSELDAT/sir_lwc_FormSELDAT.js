import { LightningElement, api, track, wire } from 'lwc';
import { CloseActionScreenEvent } from 'lightning/actions';
import {refreshApex} from '@salesforce/apex';

import getTarea from '@salesforce/apex/sir_LCMP_FormSELDAT.getTarea';
//import sendAndSaveTarea from '@salesforce/apex/sir_LCMP_FormSELDAT.sendAndSaveTarea'; 
import updateTarea from '@salesforce/apex/sir_LCMP_FormSELDAT.updateTarea'; 


export default class Sir_lwc_FormSELDAT extends LightningElement {

    @api recordId;

    _getRecordResponse;

    @track nombreBoton = 'Guardar y enviar';
    @track tareaId = null;
    @track tareaRecord = null;
    @track estadoTarea = null;
    @track codRespuesta = null;
    @track codigos = null;
    @track descripciones = null;
    @track seleccion = null;

    @track seleccionM = 'Seleccione al menos una opción: '
    @track seleccionS = 'Seleccione una opción: '

    @track valueSELS = [];
    @track valueSELM = [];
    @track valueDATF = [];
    @track valueDATN = [];
    @track valueDATA = [];
    @track comentario = null;

    @track isSELS = false;
    @track isSELM = false;
    @track req_questionSEL = null;
    
    @track isDAT = false;
    @track isDATF = false;
    @track isDATN = false;
    @track isDATA = false;
    @track labelDATF = 'Introduzca una fecha';
    @track labelDATN = 'Introduzca un importe';
    @track labelDATA = 'Introduzca un texto (Máximo 2.000 caracteres)';

    @track formularioVisible = false;
    @track mensajeError = null;
    @track codigoError = null;
    @track mensajeKO = false;
    @track errorPropietario = false;

    @track disabledCerrar = false;
    @track disabledGuardar = true;
    @track disableRadio = false;
    @track disableCheck = false;
    @track disableDATF = false;
    @track disableDATN = false;
    @track disableDATA = false;

    @track siguienteTarea = false;
    @track sigTareaRecord;

    @track wiredTarea;
    @track wiredResultTarea = [];

    @track errorGeneral;
    @track mensajeErrorComentario;
    
    get options() {
        var options= [];
        var opcionesArray =[];
        var opcionesDescArray =[];

        if(this.codigos !== null && typeof this.codigos !== undefined && this.codigos !== ''){
            opcionesArray = this.codigos.split("|");
        }
        if(this.descripciones !== null && typeof this.descripciones !== undefined && this.descripciones !== ''){
            opcionesDescArray = this.descripciones.split("|");
        }

        opcionesArray.forEach(addOption);
            function addOption(value, index) {
                options.push({ label: opcionesDescArray[index], value: value });
            }

        return options;
    }
    
    @api
    refrescarDatos() {     
        this.disabledCerrar = false;  
        //
        this.disabledGuardar = true;
    /*    this.disableRadio = false;
        this.disableCheck = false;
        this.disableDATF = false;
        this.disableDATN = false;
        this.disableDATA = false;*/
        //
        this.seleccion = null; 
        this.valueSELS = [];
        this.valueSELM = [];
        this.valueDATF = [];
        this.valueDATN = [];
        this.valueDATA = [];
        this.comentario = null;
        refreshApex(this.wiredResultTarea);
    }


    @wire(getTarea, {
        procesoId: '$recordId'
    })wiredTarea(result) {
        this.wiredResultTarea = result;
        if(result.data){ 
            //Se obtiene la tarea
            this.tareaRecord = result.data;
            this.tareaId = this.tareaRecord.SIREC__SIREC_fld_tarea__c;
            this.estadoTarea = this.tareaRecord.SIREC__SIREC_fld_tarea__r.SIREC__SIREC_fld_estado__c;

            //Si existen valores previos seleccionados se precargan
            if(this.tareaRecord.SIREC__SIREC_fld_tarea__r.SIREC__SIREC_fld_SEL_respuestas_cod__c != null && this.tareaRecord.SIREC__SIREC_fld_tarea__r.SIREC__SIREC_fld_SEL_respuestas_cod__c != '') {
                if(this.tareaRecord.SIREC__SIREC_fld_tarea__r.SIREC__SIREC_fld_seleccion__c == 'S'){
                    this.valueSELS = this.tareaRecord.SIREC__SIREC_fld_tarea__r.SIREC__SIREC_fld_SEL_respuestas_cod__c;
                    this.seleccion = this.valueSELS.toString();
                }else if(this.tareaRecord.SIREC__SIREC_fld_tarea__r.SIREC__SIREC_fld_seleccion__c == 'M'){
                    this.valueSELM = this.tareaRecord.SIREC__SIREC_fld_tarea__r.SIREC__SIREC_fld_SEL_respuestas_cod__c;
                    this.seleccion = this.valueSELM.toString();
                }
            }else if(this.tareaRecord.SIREC__SIREC_fld_tarea__r.SIREC__SIREC_fld_DAT_fecha__c != null && this.tareaRecord.SIREC__SIREC_fld_tarea__r.SIREC__SIREC_fld_DAT_fecha__c != ''){
                this.valueDATF = this.tareaRecord.SIREC__SIREC_fld_tarea__r.SIREC__SIREC_fld_DAT_fecha__c
                this.seleccion = this.valueDATF;
            }else if(this.tareaRecord.SIREC__SIREC_fld_tarea__r.SIREC__SIREC_fld_DAT_importe__c != null && this.tareaRecord.SIREC__SIREC_fld_tarea__r.SIREC__SIREC_fld_DAT_importe__c != ''){
                this.valueDATN = this.tareaRecord.SIREC__SIREC_fld_tarea__r.SIREC__SIREC_fld_DAT_importe__c;
                this.seleccion = this.valueDATN;
            }else if(this.tareaRecord.SIREC__SIREC_fld_tarea__r.SIREC__SIREC_fld_DAT_textoLargo__c != null && this.tareaRecord.SIREC__SIREC_fld_tarea__r.SIREC__SIREC_fld_DAT_textoLargo__c != ''){
                this.valueDATA = this.tareaRecord.SIREC__SIREC_fld_tarea__r.SIREC__SIREC_fld_DAT_textoLargo__c;
                this.seleccion = this.valueDATA;
            }else if(this.tareaRecord.SIREC__SIREC_fld_tarea__r.SIREC__SIREC_fld_comentarios__c != null && this.tareaRecord.SIREC__SIREC_fld_tarea__r.SIREC__SIREC_fld_comentarios__c != ''){
                this.comentario = this.tareaRecord.SIREC__SIREC_fld_tarea__r.SIREC__SIREC_fld_comentarios__c;
            }

            //Se comprueba que alguno de los campos tenga valor para habilitar el botón de "Guardar"
            if( this.seleccion != null && this.seleccion != '' ){
                this.disabledGuardar = false;
            }
           
            //Se mira el estado de la tarea y si está Pdte Sincronización se deshabilita la edicion
            if(this.estadoTarea == 'Pendiente Sincronización'){
                this.nombreBoton = 'Enviar';
              /*  this.disableRadio = true;
                this.disableCheck = true;
                this.disableDATF = true;
                this.disableDATN = true;
                this.disableDATA = true;*/
            }
            this.isSELS = false;
            this.isSELM = false;     
            this.isDAT = false;
            this.isDATF = false;
            this.isDATN = false;
            this.isDATA = false;

            //Se muestra un formulario u otro en funcion de la tarea
            if(this.tareaRecord.SIREC__SIREC_fld_tarea__r.SIREC__SIREC_fld_tipo_tarea__c == 'SEL'){
                this.codigos = this.tareaRecord.SIREC__SIREC_fld_tarea__r.SIREC__SIREC_fld_SEL_opciones_cod__c;
                this.descripciones = this.tareaRecord.SIREC__SIREC_fld_tarea__r.SIREC__SIREC_fld_SEL_opciones_desc__c;
                this.req_questionSEL = this.tareaRecord.SIREC__SIREC_fld_tarea__r.SIREC__SIREC_fld_tituloInfo__c;
                if( this.tareaRecord.SIREC__SIREC_fld_tarea__r.SIREC__SIREC_fld_seleccion__c == 'S'){
                    this.isSELS = true;
                } 
                if( this.tareaRecord.SIREC__SIREC_fld_tarea__r.SIREC__SIREC_fld_seleccion__c == 'M'){
                    this.isSELM = true;
                } 
            }
            else if(this.tareaRecord.SIREC__SIREC_fld_tarea__r.SIREC__SIREC_fld_tipo_tarea__c == 'DAT'){
                this.isDAT = true;
                this.req_questionDAT = this.tareaRecord.SIREC__SIREC_fld_tarea__r.SIREC__SIREC_fld_tituloInfo__c;
                if( this.tareaRecord.SIREC__SIREC_fld_tarea__r.SIREC__SIREC_fld_seleccion__c == 'F'){
                    this.isDATF = true;
                } 
                if( this.tareaRecord.SIREC__SIREC_fld_tarea__r.SIREC__SIREC_fld_seleccion__c == 'N'){
                    this.isDATN = true;
                } 
                if( this.tareaRecord.SIREC__SIREC_fld_tarea__r.SIREC__SIREC_fld_seleccion__c == 'A'){
                    this.isDATA = true;
                } 
            }

            //Se muestra el formulario
            this.formularioVisible = true;          
           
        }else {
            this.tarea = 'error';
            this.formularioVisible = false;
        }
    }

    /* Método que guarda el valor seleccionado en el campo Comentarios */
    changeComentarios(event){ 
        this.comentario = event.target.value;
    }

    /*Metodo que obtiene los valores introducidos por el usuario*/
    getSelection(event){
        if(this.isDATF){
            this.valueDATF = event.detail.value;
            this.seleccion = this.valueDATF;
        }
        if(this.isDATN){
            this.valueDATN = event.detail.value;
            this.seleccion = this.valueDATN;
        }        
        if(this.isSELS){
            this.valueSELS = event.detail.value;
            this.seleccion = this.valueSELS.toString();
        }
        if(this.isSELM){
            this.valueSELM = event.detail.value;
            this.seleccion = this.valueSELM.toString();
        }
        //Se comprueba que alguno de los campos tenga valor para habilitar el botón de "Guardar"
        if( (this.valueSELM != null && this.valueSELM !== '') || (this.valueSELS != null && this.valueSELS !== '') ||
            (this.valueDATF != null && this.valueDATF !== '') || (this.valueDATN != null && this.valueDATN !== '')){
            this.disabledGuardar = false;
        }
        if(this.isDATA){           
            // Detectamos los caracteres que ocupan mas de 1 posicion de esta forma
            var utf8Bytes = new TextEncoder().encode(event.detail.value);
            var numCaracteres = utf8Bytes.length; 
            // Como el maxlength calcula el salto de linea como 1 caracter, realizamos logica para detectar los saltos de linea y sumar 1 en el contador    
            var ocurrencias = event.detail.value.matchAll(/\n/g);
            for(let ocu of ocurrencias) {
                numCaracteres = numCaracteres + 1;
            } 
            if(numCaracteres > 2000){
                this.disabledGuardar = true;
                this.errorGeneral = true;
                this.mensajeErrorComentario = 'El comentario no puede contener más de 2.000 caracteres.';
            } else if(event.detail.value === ''){
                this.disabledGuardar = true;
                this.errorGeneral = false;
            } else {     
                this.valueDATA = event.detail.value;
                this.seleccion = this.valueDATA;           
                this.disabledGuardar = false;
                this.errorGeneral = false;
            }            
        }
    }
    
    handleSaveAndSendClick(){
        this.disabledCerrar = true;
        this.disabledGuardar = true;
        updateTarea({tareaId: this.tareaId, seleccion : this.seleccion, comentario : this.comentario, send: true}).then(result => {
            if(result.length >= 0){
                //Si el resultado del WS es OK 
                if(result[0] === 'OK'){
                  /*  this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Enviado',
                            message: 'La Tarea se ha enviado correctamente',
                            variant: 'success',
                            mode: 'pester'
                        })
                    );*/
                    this.formularioVisible = false;
                    this.dispatchEvent(new CustomEvent('siguiente'));
                }
                //Si el resultado del WS es KO se muestra el error
                else{
                    //Se oculta el formulario
                    this.formularioVisible = false;
                    //Se muestra el error
                    this.mensajeKO = true;
                    this.mensajeError = result[1];
                    this.codigoError = result[2];
                    this.disabledCerrar = false;
                }   
            }  
        })
        .catch(error => {
            //Se oculta el formulario
            this.formularioVisible = false;
            //Se muestra el error
            this.mensajeKO = true;
            this.mensajeError = 'Se ha producido un problema. Por favor, pongase en contacto con su Administrador del sistema. ' + error;
            this.disabledCerrar = false;
        });
    }

    /* Metodo que cierra el pop-up y refresca la pantalla */
    closeQuickAction() {
        this.dispatchEvent(new CloseActionScreenEvent());
        window.location.reload();
    }
    
}