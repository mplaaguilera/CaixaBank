/*eslint no-console: ["error", { allow: ["warn", "error"] }] */

import { LightningElement, api, track, wire } from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { RefreshEvent } from 'lightning/refresh';
import { updateRecord } from 'lightning/uiRecordApi';
import LightningModal from 'lightning/modal';
import CASE_OBJECT from '@salesforce/schema/Case';

// import methods
import getResultadoGenial from '@salesforce/apex/SAC_GenialView_Controller.getResultadoGenial';
import obtenerPretensionesIA from '@salesforce/apex/SAC_GenialView_Controller.obtenerPretensionesIA';
import obtenerRecordTypeReclamacion from '@salesforce/apex/SAC_GenialView_Controller.obtenerRecordTypeReclamacion';
import obtenerReclamantesSecundariosIA from '@salesforce/apex/SAC_GenialView_Controller.obtenerReclamantesSecundariosIA';
import obtenerValoracionResumen from '@salesforce/apex/SAC_GenialView_Controller.getValorResumen';
import saveValoracionResumen from '@salesforce/apex/SAC_GenialView_Controller.guardarValorResumen';
import asignarReclamantes from '@salesforce/apex/SAC_GenialView_Controller.asignarReclamantes';
import getCustomSetting from '@salesforce/apex/SAC_GenialView_Controller.getCustomSettings';


//import fields
//Campos de Case
import CASEID from '@salesforce/schema/Case.Id';
import CASERT from '@salesforce/schema/Case.RecordTypeId';
import ESTADO from '@salesforce/schema/Case.SAC_GenialEstado__c';
import CANAL from '@salesforce/schema/Case.Origin';
//import VALORESUMEN from '@salesforce/schema/Case.SAC_Genial_Valoracion_Resumen__c';

//Datos del reclamante
import ACCOUNTNAME from '@salesforce/schema/Case.AccountId';
import ACCOUNTNIF from '@salesforce/schema/Case.CC_SuppliedNIF__c';
import USARDATOS from '@salesforce/schema/Case.SAC_UsarDatos__c';

//Datos del Representante
import TIPODEREPRESENTANTE from '@salesforce/schema/Case.SAC_TipoDeRepresentante__c';
import TIPODEDOCUMENTO from '@salesforce/schema/Case.SAC_TipoDeDocumento__c';
import NUMERODELDOCUMENTO from '@salesforce/schema/Case.SAC_NumeroDelDocumento__c';
import NOMBRECOMPLETO from '@salesforce/schema/Case.SAC_NombreRepresentante__c';
import TELEFONODECONTACTOREP from '@salesforce/schema/Case.SAC_TelefonoRepresentante__c';
import CORREOELECTRONICOREP from '@salesforce/schema/Case.SAC_EmailRepresentante__c';
import DESPACHOREPRESENTANTE from '@salesforce/schema/Case.SAC_DespachoRepresentante__c';

import DIRECCIONREP from '@salesforce/schema/Case.SAC_DireccionRepresentante__c';
import CODIGOPOSTALREP from '@salesforce/schema/Case.SAC_CodigoPostalRepresentante__c';
import POBLACIONREP from '@salesforce/schema/Case.SAC_PoblacionRepresentante__c';
import PROVINCIAREP from '@salesforce/schema/Case.SAC_ProvinciaRepresentante__c';
import PAISREP from '@salesforce/schema/Case.SAC_PaisRepresentante__c';
import DIRECCIONPOSTALREP from '@salesforce/schema/Case.SAC_DireccionPostal__c';
import PODERREP from '@salesforce/schema/Case.SAC_PoderRepresentante__c';

//DETALLES( SOLO LOS CAMPOS DE DATOS IA)
import IMPORTETIPO from '@salesforce/schema/Case.SAC_Importe_Tipo__c';
import IMPORTERECLAMADO from '@salesforce/schema/Case.CC_Importe_Reclamado__c';
import FECHARECEPCION from '@salesforce/schema/Case.SAC_FechaRecepcion__c';

import NATURALEZA from '@salesforce/schema/Case.SAC_Naturaleza__c';
import IDIOMA from '@salesforce/schema/Case.CC_Idioma__c';
import OFICINAAFECTADA from '@salesforce/schema/Case.CC_Oficina_Afectada_Lookup__c';

//Categorizacion MCC
import MCCTEMATICA from '@salesforce/schema/Case.CC_MCC_Tematica__c';
import MCCMOTIVO from '@salesforce/schema/Case.CC_MCC_Motivo__c';

import MCCPRODSERV from '@salesforce/schema/Case.CC_MCC_ProdServ__c';
import SEGDETALLE from '@salesforce/schema/Case.SEG_Detalle__c';
import MCCRESUMEN from '@salesforce/schema/Case.SAC_Resumen__c'; 

import ESPRINCIPAL from '@salesforce/schema/Case.SAC_EsPrincipal__c'; 
import EMAILRECLAMANTE from '@salesforce/schema/Case.OS_Email__c';

import RESNIF from '@salesforce/schema/SAC_Genial_Resultado__c.SAC_SuppliedNIF__c';
import mensajeIAResponsable from '@salesforce/label/c.SAC_MensajeIAResponsable';

const FIELDSCASE = [CASEID,CASERT,ESTADO,ACCOUNTNAME,ACCOUNTNIF,USARDATOS,TIPODEREPRESENTANTE,TIPODEDOCUMENTO,NUMERODELDOCUMENTO,NOMBRECOMPLETO,TELEFONODECONTACTOREP,CORREOELECTRONICOREP,DESPACHOREPRESENTANTE,DIRECCIONREP,CODIGOPOSTALREP,POBLACIONREP,PROVINCIAREP,PAISREP,DIRECCIONPOSTALREP,PODERREP,IMPORTETIPO,IMPORTERECLAMADO,FECHARECEPCION,NATURALEZA,IDIOMA,OFICINAAFECTADA,MCCTEMATICA,MCCMOTIVO,MCCPRODSERV,SEGDETALLE,ESPRINCIPAL,EMAILRECLAMANTE,MCCRESUMEN,CANAL];
const FIELDSRESULTADO = [RESNIF];

export default class Sac_GenialView extends LightningElement {
    iconoInformativo = 'utility:info_alt';
    @api recordId;
    @api objectApiName;
    
    @track idResultadoGenial;
    @track iconosCampos;

    @track cargando = true;
    @track idGenialValido = false;

    @track pruebaModificacion = 0;
    @track objetoCase = {};

    @track esReclamacion = false;

    @track estadoEnviado = false;
    @track estadoRespondidoShadow = false;
    @track estadoRespondido = false;
    @track estadoErrorEnvío = false;

    @track toggleIconReclamante = "slds-section slds-is-open";
    @track bExpanseReclamante = true;
    @track toggleIconRepresentante = "slds-section slds-is-open";
    @track bExpanseRepresentante = true;
    @track toggleIconDetalles = "slds-section slds-is-open";
    @track bExpanseDetalles = true;
    @track toggleIconMCC = "slds-section slds-is-open";
    @track bExpanseMCC = true;
    @track togglePretensiones = "slds-section slds-is-open";
    @track bExpansePretensiones = true;

    @track pretensionesIA = [];

    @track rtReclamacion = null;

    @track toggleReclamantesSec = "slds-section slds-is-open";
    @track bExpanseReclamantesSec = true;
    @track reclamantesSecIA = [];
    @track hayReclamantesSec = false;

    @track likeClass = '';
    @track dislikeClass = '';
    //@track valresumen = VALORESUMEN;

    @track bAsignarReclamantes = false;
    @track esConfirmado = false;
    @track checkError = false;
    @track checkBoxClass = 'slds-form-element';
    @track cargando2 = false;
    @track tieneDocumento = false;
    @track canal = false;

    label = {
        mensajeIAResponsable
    };

    handleExpandableReclamante() {
        if(this.bExpanseReclamante){
            this.bExpanseReclamante = false;
            this.toggleIconReclamante = "slds-section"; 
        } else {
            this.bExpanseReclamante = true;
            this.toggleIconReclamante = "slds-section slds-is-open";
        }
    }
    handleExpandableRepresentante() {
        if(this.bExpanseRepresentante){
            this.bExpanseRepresentante = false;
            this.toggleIconRepresentante = "slds-section"; 
        } else {
            this.bExpanseRepresentante = true;
            this.toggleIconRepresentante = "slds-section slds-is-open";
        }
    }
    handleExpandableDetalles() {
        if(this.bExpanseDetalles){
            this.bExpanseDetalles = false;
            this.toggleIconDetalles = "slds-section"; 
        } else {
            this.bExpanseDetalles = true;
            this.toggleIconDetalles = "slds-section slds-is-open";
        }
    }
    handleExpandableMCC() {
        if(this.bExpanseMCC){
            this.bExpanseMCC = false;
            this.toggleIconMCC = "slds-section"; 
        } else {
            this.bExpanseMCC = true;
            this.toggleIconMCC = "slds-section slds-is-open";
        }
    }

    handleExpandablePretensiones() {
        if(this.bExpansePretensiones){
            this.bExpansePretensiones = false;
            this.togglePretensiones = "slds-section"; 
        } else {
            this.bExpansePretensiones = true;
            this.togglePretensiones = "slds-section slds-is-open";
        }
    }

    handleExpandableReclamantesSec() {
        if(this.bExpanseReclamantesSec){
            this.bExpanseReclamantesSec = false;
            this.toggleReclamantesSec = "slds-section"; 
        } else {
            this.bExpanseReclamantesSec = true;
            this.toggleReclamantesSec = "slds-section slds-is-open";
        }
    }

    //para hacerlo solo cuando se tienen los valores
    renderedCallback() {
        if (this.rtReclamacion != null && this.objetoCase.RecordTypeId == this.rtReclamacion){
            this.esReclamacion = true;
            this.cargando = false;
        }
        else { 
            this.esReclamacion = false;
            this.cargando = false;
        }
    }


    //obtener el id del record type SAC_Reclamacion de Caso
    @wire(obtenerRecordTypeReclamacion)
    getRtRec({ error, data }){
        if(data){
            this.rtReclamacion = data;
        } else if(error){
            console.error(error);
        }
    }

    //obtener si en el objeto resultado, hay nif necesario para mostrar el boton que vincula el reclamante a la reclamación
    //también el tipo de reclamante para mostrar o no la información del reclamante
    @wire(getRecord, {recordId: '$idResultadoGenial', fields : FIELDSRESULTADO})
    getResulRecord({error, data}){
        if(data) {
            if(data.fields["SAC_SuppliedNIF__c"].value !== null){
                this.tieneDocumento = true;
            }
        } else if (error) {
            console.error(error);
        }
    }

    //ver los updates mientras estas en la pagina, 
    @wire(getRecord, {recordId: '$recordId', fields : FIELDSCASE})
    getCaseRecord({ error, data }){
        if (data) {
            let objetoInterno = {};
            // let stringInterno = "{";
            // console.log(JSON.stringify(data));
            // console.log(JSON.stringify(data.fields));
            for (const campo in data.fields){
                // console.log(JSON.stringify(campo));
                // console.log(data.fields[campo].value);
                //let obj = `${campo}: ${data.fields[campo].value}`;
                if (Object.prototype.hasOwnProperty.call(data.fields, campo)) {
                // console.log(JSON.stringify(objetoInterno));

                // stringInterno = stringInterno + campo + ":" + data.fields[campo].value + ",";
                // console.log(stringInterno);

                // if (campo == 'RecordTypeId'){
                //     if(data.fields[campo].value == RTRECLAMACION){  //this.rtReclamacion
                //         this.esReclamacion = true;
                //     }
                //     else { 
                //         //if (data.fields[campo].value == RTPRETENSION)
                //         this.esReclamacion = false;
                //     }
                // }
                    objetoInterno[campo] = data.fields[campo].value;
                    if (campo == 'SAC_GenialEstado__c'){
                        if (data.fields[campo].value == 'SAC_001'){
                            //estado Enviado
                            this.estadoEnviado = true;
                            this.estadoRespondidoShadow = false;
                            this.estadoRespondido = false;
                            this.estadoErrorEnvío = false;
                        }                    
                        if (data.fields[campo].value == 'SAC_002'){
                            //estado Respondido(Shadow)
                            //this.estadoRespondidoShadow = true;
                            this.estadoEnviado = false;
                            //this.estadoRespondido = false;
                            this.estadoRespondido = true;
                            this.estadoErrorEnvío = false;
                        }                    
                        if (data.fields[campo].value == 'SAC_003'){
                            //estado Respondido
                            this.estadoRespondido = true;
                            this.estadoEnviado = false;
                            this.estadoRespondidoShadow = false;
                            this.estadoErrorEnvío = false;
                        }
                        if (data.fields[campo].value == 'SAC_004'){
                            //estado Error Envío
                            this.estadoErrorEnvío = true;
                            this.estadoEnviado = false;
                            this.estadoRespondidoShadow = false;
                            this.estadoRespondido = false;
                        }
                        if (data.fields[campo].value == 'SAC_006'){
                            //estado Error respuesta, actua como Respondido(Shadow)
                            //this.estadoRespondidoShadow = true;
                            this.estadoEnviado = false;
                            //this.estadoRespondido = false;
                            this.estadoRespondido = true;
                            this.estadoErrorEnvío = false;
                        }
                    }
                
                }
            }
            // //quitar ultima coma
            // stringInterno = stringInterno + "}";
            this.canal = objetoInterno["Origin"];
            this.objetoCase = objetoInterno;
            this.pruebaModificacion = this.pruebaModificacion+1;
        }else if(error){
            console.error(error);
        }
    }

    //a partir del Id del Caso se obtiene el SAC_ResultadoGenial asociado, o null si no hay ninguno
    @wire(getResultadoGenial, { casoOriginal: '$objetoCase'})
    getResGenId({ error, data }){
        if(data){
            if (data.id != null && data.iconosCampos != null){
                this.idResultadoGenial = data.id;
                this.iconosCampos = data.iconosCampos;
                this.idGenialValido = true;
            }
            //this.cargando = false;
        } else if(error){
            //this.cargando = false;
            console.error(error);
        }
    }

    //obtener pretensiones propuestas por la IA
    @wire(obtenerPretensionesIA, { reclamacionId: '$recordId'})
    getPretIA({ error, data }){
        if(data){
            this.pretensionesIA = data;
        } else if(error){
            console.error(error);
        }
    }

    //obtener reclamantes secundarios propuestos por la IA
    @wire(obtenerReclamantesSecundariosIA, { reclamacionId: '$recordId'})
    getRecSecIA({ error, data }){
        if(data){
            this.reclamantesSecIA = data;
            if (this.reclamantesSecIA.length > 0){
                this.hayReclamantesSec = true;
            }
            else{
                this.hayReclamantesSec = false;
            }
        } else if(error){
            //console.log(error);
            console.error(error);
        }
    }
    //Recuperamos valoración al inicializar el registro
    @wire(obtenerValoracionResumen, {casoId: '$recordId'})
    getValResumen({ error, data }){
        if (data) {
            const valoracion = data;
            if (valoracion === 'Positivo') {
                this.likeClass = 'success';
                this.dislikeClass = '';
            } else if (valoracion === 'Negativo') {
                this.likeClass = '';
                this.dislikeClass = 'destructive';
            } else {
                this.likeClass = '';
                this.dislikeClass = '';
            }
        }
    }

    //obtener el setting del canal para temas de visibilidad
    @wire(getCustomSetting, {canal: '$canal'})
    settingsCanal;

    //obtener booleano si tiene ya un account vinculado
    existeReclamante() {
        //console.log(this.template.querySelector("[data-id='accountPrincipal']").getDetails());
        if(JSON.stringify(this.objetoCase) !== "{}" && this.objetoCase["AccountId"] !== null)
        {
            return true;
        }
        return false;
    }

    get mostrarBoton() {
        this.template.querySelector("lightning-output-field");
        if(this.settingsCanal.data.SAC_BotonReclamante__c && !this.existeReclamante() && this.tieneDocumento){
            return true;
        }
        return false;
    }

    //Gestión Botones Valoración
    handleLike() {
        if(this.likeClass === '') {
            this.likeClass = 'success'; 
            this.updateCaseRecord('Positivo');
        } else {
            this.likeClass = '';
            this.updateCaseRecord('neutral');
        }
        this.dislikeClass = ''; 
    }
    handleDislike() {
        if(this.dislikeClass === '') {
            this.dislikeClass = 'destructive';
            this.updateCaseRecord('Negativo');
        } else {
            this.dislikeClass = '';
            this.updateCaseRecord('neutral');
        }
        this.likeClass = '';
    }
    updateCaseRecord(valoracion) {
        saveValoracionResumen({ casoId: this.recordId, valoracion: valoracion })
            .then(() => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Éxito',
                        message: 'Valoración actualizada correctamente.',
                        variant: 'success'
                    })
                );
            })
            .catch(error => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error al actualizar la valoración',
                        message: error.body.message,
                        variant: 'error'
                    })
                );
            });
    }

    asignarReclamantes(){
        //this.cargando = true;
        this.bAsignarReclamantes = true;
        /*asignarReclamantes({casoId: this.recordId})
            .then(() => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Éxito',
                        message: 'Reclamante/s asignados correctamente a la reclamación',
                        variant: 'success'
                    })
                );
                this.dispatchEvent(new RefreshEvent());
                this.cargando = false;
            })
            .catch(error => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error al actualizar la valoración',
                        message: error.body.message,
                        variant: 'error'
                    })
                );
                this.cargando = false;
            });*/
    }

    handleCancelar(){
        this.bAsignarReclamantes = false;
    }

    handleConfirmar(){
        if(this.esConfirmado){
            this.cargando2 = true;
            asignarReclamantes({casoId: this.recordId})
                .then(() => {
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Éxito',
                            message: 'Reclamante/s asignados correctamente a la reclamación',
                            variant: 'success'
                        })
                    );
                    this.cargando2 = false;
                    this.bAsignarReclamantes = false;
                    //this.dispatchEvent(new RefreshEvent());
                    window.location.reload(true);
                })
                .catch(error => {
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Error al actualizar la valoración',
                            message: error.body.message,
                            variant: 'error'
                        })
                    );
                    this.cargando2 = false;
                    this.bAsignarReclamantes = false;
                });
            } else {
                this.checkError = true;
                this.checkBoxClass = 'slds-form-element slds-has-error';
            }  
    }

    handleCheckboxCambio(event){
        if(event.target.checked === true){
            this.checkError = false;
            this.checkBoxClass = 'slds-form-element';
        }
        this.esConfirmado = event.target.checked;

    }
}