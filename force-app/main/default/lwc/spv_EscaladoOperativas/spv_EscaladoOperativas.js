import { LightningElement, api, wire, track } from 'lwc';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import { getPicklistValues } from "lightning/uiObjectInfoApi";
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { RefreshEvent } from "lightning/refresh";
import idUsuario from "@salesforce/user/Id";
//Campos
import RECORDTYPEID_FIELD from "@salesforce/schema/SAC_Interaccion__c.RecordTypeId";
import OWNERID_FIELD from "@salesforce/schema/SAC_Interaccion__c.OwnerId";
import TIPODERESPUESTA_FIELD from "@salesforce/schema/SAC_Interaccion__c.SPV_TipoRespuesta__c";
import MOTIVORECHAZO_FIELD from "@salesforce/schema/SAC_Interaccion__c.SPV_MotivoRechazo__c";
import GRUPOESCALADO_FIELD from "@salesforce/schema/SAC_Interaccion__c.SAC_GrupoColaborador__c";
import ESTADO_FIELD from "@salesforce/schema/SAC_Interaccion__c.SAC_Estado__c";
import CREATEDBYID_FIELD from "@salesforce/schema/SAC_Interaccion__c.CreatedById";
import CASOESCALADO_FIELD from "@salesforce/schema/SAC_Interaccion__c.SAC_CasoEscalado__c";
import MOTIVOESCALADO_FIELD from "@salesforce/schema/SAC_Interaccion__c.SAC_MotivoEscalado__c";

//Métodos apex
import tomarPropiedadEscaladoApex from '@salesforce/apex/SPV_LCMP_EscaladoOperativas.tomarPropiedadEscalado';
import devolverEscaladoAlGrupoApex from '@salesforce/apex/SPV_LCMP_EscaladoOperativas.devolverEscaladoAlGrupo';
import responderEscaladoApex from '@salesforce/apex/SPV_LCMP_EscaladoOperativas.responderEscalado';
import enviarEscaladoApex from '@salesforce/apex/SPV_LCMP_EscaladoOperativas.enviarEscalado';

const escaladoFields = [RECORDTYPEID_FIELD, OWNERID_FIELD, TIPODERESPUESTA_FIELD, MOTIVORECHAZO_FIELD, GRUPOESCALADO_FIELD, ESTADO_FIELD, CREATEDBYID_FIELD, CASOESCALADO_FIELD, MOTIVOESCALADO_FIELD];

export default class Spv_EscaladoOperativas extends LightningElement {
    @api recordId; //Id del registro en el que se encuentra el componente
    @track userId = idUsuario; //Id del usuario actual
    @track mostrarModalResponder = false; //Mostrar el modal de responder escalado
    @track picklistTipoRespuestaValues; //Valores de la picklist tipo de respuesta
    @track selectedValueTipoRespuesta; //Valor seleccionado en el tipo de respuesta
    @track picklistMotivoRechazoValues; //Valores de la picklist motivo de rechazo
    @track selectedValueMotivoRechazo; //Valor seleccionado en el motivo de rechazo
    @track mostrarComentarios = false; //Mostrar el campo comentarios al responder el escalado
    @track mostrarMotivoRechazo = false; //Mostrar el campo motivo de rechazo al responder el escalado
    @track mostrarSpinner = false; //Mostrar el spinner
    @track comentarios; //Valor de los comentarios introducidos al responder escalado

    //Recuperar registro con los campos definidos en la constante escaladoFields
    @wire(getRecord, {
        recordId: "$recordId",
        fields: escaladoFields
    })
    record;

    //Recuperar los valores de la picklist SPV_TipoRespuesta a través del recordtypeid del registro (recuperado con getrecord)
    @wire(getPicklistValues, { recordTypeId: '$record.data.recordTypeId', fieldApiName: TIPODERESPUESTA_FIELD })
    valoresPicklistTipoRespuesta({data}) {
        if (data) {
            //Recuperar valores ordenandolos
            this.picklistTipoRespuestaValues = data.values;
        }
    }

    //Recuperar los valores de la picklist SPV_MotivoRechazo a través del recordtypeid del registro (recuperado con getrecord)
    @wire(getPicklistValues, { recordTypeId: '$record.data.recordTypeId', fieldApiName: MOTIVORECHAZO_FIELD })
    valoresPicklistMotivoRechazo({data}) {
        if (data) {
            //Recuperar valores ordenandolos
            this.picklistMotivoRechazoValues = data.values;
        }
    }

    //Getters de valores de campos
    get escaladoOwnerId() {
        return getFieldValue(this.record.data, OWNERID_FIELD);
    }
    get grupoEscalado() {
        return getFieldValue(this.record.data, GRUPOESCALADO_FIELD);
    }
    get estadoEscalado() {
        return getFieldValue(this.record.data, ESTADO_FIELD);
    }
    get createdById() {
        return getFieldValue(this.record.data, CREATEDBYID_FIELD);
    }
    get reclamacionId() {
        return getFieldValue(this.record.data, CASOESCALADO_FIELD);
    }
    get motivoEscalado() {
        return getFieldValue(this.record.data, MOTIVOESCALADO_FIELD);
    }

    //Getters visibilidad botones
    get disableBotonTomarPropiedad() {
        //Si el usuario es el mismo que ya tiene el escalado o el estado está en pendiente de enviar, se debe deshabilitar
        if (this.escaladoOwnerId == this.userId || this.estadoEscalado == 'SPV_PendienteEnviar') {
            return true;
        } else {
            return false;
        }
    }
    get disableBotonDevolverEscalado() {
        //Si el usuario es el mismo que el owner actual del escalado y el estado es diferente a enviado, debe estar activo
        if (this.escaladoOwnerId == this.userId && this.estadoEscalado != 'SPV_PendienteEnviar') {
            return false;
        } else {
            return true;
        }
    }
    get disableBotonEnviar() {
        //Si el estado es diferente a pendiente de enviar, es que ya está enviado y no debe estar activo
        if (this.estadoEscalado != 'SPV_PendienteEnviar') {
            return true;
        } else {
            return false;
        }
    }

    //Botón tomar en propiedad (llamada a apex)
    handleTomarPropiedad() {
        //Activar el spinner
        this.handleActivarSpinner();
        //LLamada a apex
        tomarPropiedadEscaladoApex({ escaladoId: this.recordId, grupoEscalado: this.grupoEscalado, usuarioActualId: this.userId })
            .then(result => {
                //Mensaje de éxito
                this.lanzarToast('Éxito', 'Se ha tomado en propiedad el escalado', 'success');
                //Refrescar el componente
                this.refrescarComponente();
                //Desactivar el spinner
                this.handleDesactivarSpinner();
            })
            .catch(error => {
                //Mensaje de error
                this.lanzarToast('Error', 'Error al tomar la propiedad: ' + error.body.message, 'error');
                //Desactivar el spinner
                this.handleDesactivarSpinner();
            });
    }

    //Botón devolver escalado (llamada a apex)
    handleDevolverEscalado() {
        //Activar el spinner
        this.handleActivarSpinner();
        //LLamada a apex
        devolverEscaladoAlGrupoApex({ escaladoId: this.recordId })
            .then(result => {
                //Mensaje de éxito
                this.lanzarToast('Éxito', 'Se ha devuelto el escalado al grupo', 'success');
                //Refrescar el componente
                this.refrescarComponente();
                //Desactivar el spinner
                this.handleDesactivarSpinner();
            })
            .catch(error => {
                //Mensaje de error
                this.lanzarToast('Error', 'Error al devolver el escalado: ' + error.body.message, 'error');
                //Desactivar el spinner
                this.handleDesactivarSpinner();
            });
    }

    //Botón enviar escalado (llamada a apex)
    handleEnviarEscalado() {
        //Activar el spinner
        this.handleActivarSpinner();
        //LLamada a apex
        enviarEscaladoApex({ escaladoId: this.recordId, casoId: this.reclamacionId, motivo: this.motivoEscalado})
            .then(result => {
                //Mensaje de éxito
                this.lanzarToast('Éxito', 'Se ha enviado el escalado', 'success');
                //Refrescar el componente
                this.refrescarComponente();
                //Desactivar el spinner
                this.handleDesactivarSpinner();
            })
            .catch(error => {
                //Mensaje de error
                this.lanzarToast('Error', 'Error al enviar el escalado: ' + error.body.message, 'error');
                //Desactivar el spinner
                this.handleDesactivarSpinner();
            });
    }

    //Botón responder escalado (llamada a apex)
    handleResponderEscalado() {
        //Comprobar si estan los campos rellenos. Si no lo estan, muestra un toast. Si lo estan, continua con la llamada a apex.
        if (this.comprobarCamposRellenos()) {
            //Activar el spinner
            this.handleActivarSpinner();
            //LLamada a apex
            responderEscaladoApex({ escaladoId: this.recordId, tipoRespuesta: this.selectedValueTipoRespuesta, comentarios: this.comentarios, motivoRechazo: this.selectedValueMotivoRechazo, creadorEscaladoId: this.createdById, casoId: this.reclamacionId })
            .then(result => {
                //Mensaje de éxito
                this.lanzarToast('Éxito', 'Se ha respondido el escalado', 'success');
                //Refrescar el componente
                this.refrescarComponente();
                //Desactivar el spinner
                this.handleDesactivarSpinner();
            })
            .catch(error => {
                //Mensaje de error
                this.lanzarToast('Error', 'Error al responder: ' + error.body.message, 'error');
                //Desactivar el spinner
                this.handleDesactivarSpinner();
            });
            //Cerrar modal de responder
            this.cerrarModalResponder();
        }
    }

    //Comprobar que todos los campos se han rellenado al responder el escalado
    comprobarCamposRellenos() {
        let camposCompletos = true;
        let mensaje = '';
    
        if (!this.selectedValueTipoRespuesta) {
            camposCompletos = false;
            mensaje = 'Debes seleccionar un tipo de respuesta';
        } else if (this.selectedValueTipoRespuesta === 'SPV_AceptadoConModificaciones' && !this.comentarios) {
            camposCompletos = false;
            mensaje = 'Debes completar el campo respuesta';
        } else if (this.selectedValueTipoRespuesta === 'SPV_Rechazado') {
            if (!this.selectedValueMotivoRechazo) {
                camposCompletos = false;
                mensaje = 'Debes seleccionar un motivo de rechazo';
            } else if (!this.comentarios) {
                camposCompletos = false;
                mensaje = 'Debes completar el campo respuesta';
            }
        }
    
        if (!camposCompletos) {
            const toastEvent = new ShowToastEvent({
                title: 'Advertencia',
                message: mensaje,
                variant: 'warning'
            });
            this.dispatchEvent(toastEvent);
        }
    
        return camposCompletos;
    }

    //Manejar el tipo de respuesta seleccionado por el usuario
    handleTipoRespuestaChange(event) {
        this.selectedValueTipoRespuesta = event.detail.value;

        //Si el motivo es aceptado, se cierran los comentarios y el motivo rechazo
        if (this.selectedValueTipoRespuesta == 'SPV_Aceptado') {
            this.mostrarComentarios = false;
            this.mostrarMotivoRechazo = false;
        }
        //Si el motivo es aceptado con modificaciones, se muestra el campo comentarios y se cierra el motivo rechazo
        else if (this.selectedValueTipoRespuesta == 'SPV_AceptadoConModificaciones') {
            this.mostrarComentarios = true;
            this.mostrarMotivoRechazo = false;
        }
        //Si el motivo es rechazado, se cierran los comentarios y se muestra el motivo rechazo (con la variable mostrar motivo rezhazo ya se añade un campo comentarios)
        else if (this.selectedValueTipoRespuesta == 'SPV_Rechazado') {
            this.mostrarComentarios = false;
            this.mostrarMotivoRechazo = true;
        }
    }

    //Manejar el motivo de rechazo seleccionado por el usuario
    handleMotivoRechazoChange(event) {
        this.selectedValueMotivoRechazo = event.detail.value;
    }

    //Manejar los comentarios introducidos por el usuario
    handleComentariosChange(event) {
        this.comentarios = event.detail.value;
    }

    lanzarToast(titulo, mensaje, variante) {
        const toastEvent = new ShowToastEvent({
            title: titulo,
            message: mensaje,
            variant: variante
        });
        this.dispatchEvent(toastEvent);
    }

    //Abre el modal de responder
    abrirModalResponder() {
        this.mostrarModalResponder = true;
    }

    //Cierra el modal de responder
    cerrarModalResponder() {
        this.mostrarModalResponder = false;
    }

    //Activar el spinner
    handleActivarSpinner() {
        this.mostrarSpinner = true;
    }

    //Desactivar el spinner
    handleDesactivarSpinner() {
        this.mostrarSpinner = false;
    }

    //Refresca el componente
    refrescarComponente() {
        this.dispatchEvent(new RefreshEvent());
    }
}