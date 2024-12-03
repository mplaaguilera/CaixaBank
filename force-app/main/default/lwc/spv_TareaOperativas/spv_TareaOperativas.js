import { LightningElement, api, wire, track } from 'lwc';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import { getPicklistValues } from "lightning/uiObjectInfoApi";
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { RefreshEvent } from "lightning/refresh";
import idUsuario from "@salesforce/user/Id";
//Campos
import OWNERID_FIELD from "@salesforce/schema/SAC_Accion__c.OwnerId";
import MAESTRODEVELOPERNAME_FIELD from "@salesforce/schema/SAC_Accion__c.SAC_MaestroAccionesReclamacion__r.SAC_DeveloperName__c";
import ESTADO_FIELD from "@salesforce/schema/SAC_Accion__c.SAC_Estado__c";
import OWNERRECID_FIELD from "@salesforce/schema/SAC_Accion__c.SAC_Reclamacion__r.OwnerId";
import OWNERPRETID_FIELD from "@salesforce/schema/SAC_Accion__c.SAC_Reclamacion__r.SAC_PretensionPrincipal__r.OwnerId";
//Métodos Apex
import tomarPropiedadTareaApex from '@salesforce/apex/SPV_LCMP_TareaOperativas.tomarPropiedadTarea';
import devolverTareaApex from '@salesforce/apex/SPV_LCMP_TareaOperativas.devolverTarea';
import devolverTareaGestorLetradoApex from '@salesforce/apex/SPV_LCMP_TareaOperativas.devolverTareaGestorLetrado';
import enviarTareaApex from '@salesforce/apex/SPV_LCMP_TareaOperativas.enviarTarea';
import prorrogarTareaApex from '@salesforce/apex/SPV_LCMP_TareaOperativas.prorrogarTarea';
import descartarTareaApex from '@salesforce/apex/SPV_LCMP_TareaOperativas.descartarTarea';
import finalizarIncompletaApex from '@salesforce/apex/SPV_LCMP_TareaOperativas.finalizarIncompleta';
import finalizarTareaApex from '@salesforce/apex/SPV_LCMP_TareaOperativas.finalizarTarea';
import enviarTareaGGHApex from '@salesforce/apex/SPV_LCMP_TareaOperativas.enviarTareaGGH';
import finalizarTareaGGHApex from '@salesforce/apex/SPV_LCMP_TareaOperativas.finalizarTareaGGH';
import notificarTareaResolutor from '@salesforce/apex/SPV_LCMP_TareaOperativas.notificarTareaResolutor';

const tareaFields = [OWNERID_FIELD, MAESTRODEVELOPERNAME_FIELD, ESTADO_FIELD, OWNERRECID_FIELD, OWNERPRETID_FIELD];

export default class Spv_TareaOperativas extends LightningElement {
    @api recordId; //Id del registro en el que se encuentra el componente
    userId = idUsuario; //Id del usuario actual
    mostrarSpinner = false; //Mostrar el spinner
    mostrarModalDevolverGestorLetrado = false; //Mostrar el modal de devolver al gestor o al letrado
    mostrarModalFinalizar = false; //Mostrar el modal de finalizar
    mostrarModalProrrogar = false; //Mostrar el modal de prorrogar
    mostrarBotonesPrincipalesFinalizar = false; //Mostrar los botones descartar, finalizada incompleta y finalizada del modal finalizar tarea
    mostrarBotonesDescartar = false; //Mostrar los botones de descartar tarea del modal finalizar tarea
    mostrarBotonesFinalizadaIncompleta = false; //Mostrar los botones de finalizada incompleta del modal finalizar tarea
    mostrarBotonesFinalizada = false; //Mostrar los botones de finalizada del modal finalizar tarea
    mostrarComentarios = false; //Mostrar el input comentarios del modal finalizar tarea
    motivoDevolver = ''; //Campo para indicar el motivo de devolver la tarea al gestor o al letrado
    comentariosFinalizarTarea = ''; //Campo comentarios para cuando finalizamos la tarea
    fechaProrroga = ''; //Campo para indicar la fecha de prorroga introducida
    bloquearBotonEnviarGGH = false;
    mostrarModalNotificar = false;
    comentariosNotificar = '';



    //Recuperar registro con los campos definidos en la constante tareaFields
    @wire(getRecord, {
        recordId: "$recordId",
        fields: tareaFields
    })
    record;

    //Getters de valores de campos
    get tareaOwnerId() {
        return getFieldValue(this.record.data, OWNERID_FIELD);
    }
    get maestroAccionesDeveloperName() {
        return getFieldValue(this.record.data, MAESTRODEVELOPERNAME_FIELD);
    }
    get estadoTarea() {
        return getFieldValue(this.record.data, ESTADO_FIELD);
    }
    get reclamacionOwnerId(){
        return getFieldValue(this.record.data, OWNERRECID_FIELD);
    }
    get pretensionOwnerId(){
        return getFieldValue(this.record.data, OWNERPRETID_FIELD);
    }

    //Getters visibilidad botones
    get disableBotonTomarPropiedad() {
        //Si el usuario es el mismo que ya tiene la tarea o el estado está en pendiente de enviar, finalizada, finalizada incompleta o descartada se debe deshabilitar
        if (this.tareaOwnerId == this.userId || this.estadoTarea == 'SAC_PendienteEnviar' || this.estadoTarea == 'SAC_Finalizada' || this.estadoTarea == 'SAC_FinalizadaIncompleta' || this.estadoTarea == 'SAC_Descartada') {
            return true;
        } else {
            return false;
        }
    }
    get disableBotonDevolverTarea() {
        //Si el usuario es el mismo que el owner actual de la tarea y el estado es diferente a pendiente enviar, a devuelta, finalizada, finalizada incompleta y descartada debe estar activo
        if (this.tareaOwnerId == this.userId && this.estadoTarea != 'SAC_PendienteEnviar' && this.estadoTarea != 'SAC_Devuelta' && this.estadoTarea != 'SAC_Finalizada' && this.estadoTarea != 'SAC_FinalizadaIncompleta' && this.estadoTarea != 'SAC_Descartada') {
            return false;
        } else {
            return true;
        }
    }
    get disableBotonEnviar() {
        //Si el estado es diferente a pendiente de enviar y diferente a devuelta, es que ya está enviado y no debe estar activo
        if (this.estadoTarea != 'SAC_PendienteEnviar' && this.estadoTarea != 'SAC_Devuelta') {
            return true;
        } else {
            return false;
        }
    }
    get disableBotonDevolverGestorLetrado() {
        //Si el estado es en gestión o pendiente de asignar, se debe mostrar el botón
        if (this.estadoTarea == 'SAC_EnGestion' || this.estadoTarea == 'SAC_PendienteAsignar') {
            return false;
        } else {
            return true;
        }
    }
    get disableBotonProrrogar() {
        //Si el estado es diferente a pendiente de enviar y diferente a devuelta, se debe mostrar el botón
        if (this.estadoTarea == 'SAC_PendienteAsignar' || this.estadoTarea == 'SAC_EnGestion') {
            return false;
        } else {
            return true;
        }
    }
    get disableBotonFinalizar() {
        //Si el estado es SAC_PendienteEnviar, SAC_PendienteAsignar, SAC_EnGestion o SAC_Devuelta, se debe mostrar el botón
        if (this.estadoTarea == 'SAC_PendienteEnviar' || this.estadoTarea == 'SAC_PendienteAsignar' || this.estadoTarea == 'SAC_EnGestion' || this.estadoTarea == 'SAC_Devuelta') {
            return false;
        } else {
            return true;
        }
    }
    get mostrarBotoneraGGH() {
        //Si el maestro de acciones de la tarea tiene el SAC_DeveloperName__c como SPV_GGH, se debe mostrar la botonera de GGH. Si no, se mostrará la botonera normal
        if (this.maestroAccionesDeveloperName == 'SPV_GGH') {
            return true;
        } else {
            return false;
        }
    }
    get disableBotonesGGH() {
        //Si el estado es pendiente de enviar o pendiente reenvio, el boton esta activo
        if (this.bloquearBotonEnviarGGH == false && (this.estadoTarea == 'SAC_PendienteEnviar' || this.estadoTarea == 'SAC_PteReenvio')) {
            return false;
        } else {
            return true;
        }
    }
    get disableBotonNotificar() {
        //Si el usuario en ejecución es el gestor o letrado, y la tarea no esta en ningulo de los estados detallados, el boton esta activo
        if ((this.userId == this.reclamacionOwnerId || this.userId == this.pretensionOwnerId) && (this.estadoTarea != 'SAC_Devuelta' && this.estadoTarea != 'SAC_Finalizada' && this.estadoTarea != 'SAC_FinalizadaIncompleta' && this.estadoTarea != 'SAC_PendienteEnviar' && this.estadoTarea != 'SAC_StandBy' && this.estadoTarea != 'SAC_Descartada')) {
            return false;
        } else {
            return true;
        }
    }
    
    //Botón tomar en propiedad (llamada a apex)
    handleTomarPropiedad() {
        //Activar el spinner
        this.handleActivarSpinner();
        //LLamada a apex
        tomarPropiedadTareaApex({ tareaId: this.recordId, usuarioActualId: this.userId })
            .then(result => {
                //Mensaje de éxito
                this.lanzarToast('Éxito', 'Se ha tomado en propiedad la tarea', 'success');
                //Refrescar el componente
                this.refrescarComponente();
                //Desactivar el spinner
                this.handleDesactivarSpinner();
            })
            .catch(error => {
                //Mensaje de error
                this.lanzarToast('Error', 'Error al tomar la propiedad: ' + this.extractErrorMessage(error), 'error');
                //Desactivar el spinner
                this.handleDesactivarSpinner();
            });
    }

    //Botón devolver tarea (llamada a apex)
    handleDevolverTarea() {
        //Activar el spinner
        this.handleActivarSpinner();
        //LLamada a apex
        devolverTareaApex({ tareaId: this.recordId })
            .then(result => {
                //Mensaje de éxito
                this.lanzarToast('Éxito', 'Se ha devuelto la tarea al grupo', 'success');
                //Refrescar el componente
                this.refrescarComponente();
                //Desactivar el spinner
                this.handleDesactivarSpinner();
            })
            .catch(error => {
                //Mensaje de error
                this.lanzarToast('Error', 'Error al devolver la tarea: ' + this.extractErrorMessage(error), 'error');
                //Desactivar el spinner
                this.handleDesactivarSpinner();
            });
    }

    //Botón devolver tarea al gestor o al letrado (llamada a apex)
    handleDevolverTareaGestorLetrado() {
        //Comprobar si el motivoDevolver está rellenado
        if (this.motivoDevolver === '') {
            //Mensaje de error
            this.lanzarToast('Atención', 'Por favor, indique el motivo de la devolución', 'warning');
            return; //Salir del método
        }
        //Activar el spinner
        this.handleActivarSpinner();
        //LLamada a apex
        devolverTareaGestorLetradoApex({ tareaId: this.recordId, motivoDevolucion: this.motivoDevolver })
            .then(result => {
                //Mensaje de éxito
                this.lanzarToast('Éxito', 'Se ha devuelto la tarea al gestor/letrado', 'success');
                //Cerrar modal
                this.handleCerrarModalDevolverGestorLetrado();
                //Refrescar el componente
                this.refrescarComponente();
                //Desactivar el spinner
                this.handleDesactivarSpinner();
            })
            .catch(error => {
                //Mensaje de error
                this.lanzarToast('Error', 'Error al devolver la tarea: ' + this.extractErrorMessage(error), 'error');
                //Cerrar modal
                this.handleCerrarModalDevolverGestorLetrado();
                //Desactivar el spinner
                this.handleDesactivarSpinner();
            });
    }

    //Botón enviar tarea (llamada a apex)
    handleEnviarTarea() {
        //Activar el spinner
        this.handleActivarSpinner();
        //LLamada a apex
        enviarTareaApex({ tareaId: this.recordId })
            .then(result => {
                //Mensaje de éxito
                this.lanzarToast('Éxito', 'Se ha enviado la tarea', 'success');
                //Refrescar el componente
                this.refrescarComponente();
                //Desactivar el spinner
                this.handleDesactivarSpinner();
            })
            .catch(error => {
                //Mensaje de error
                this.lanzarToast('Error', 'Error al enviar la tarea: ' + this.extractErrorMessage(error), 'error');
                //Desactivar el spinner
                this.handleDesactivarSpinner();
            });
    }

    //Botón prorrogar tarea (llamada a apex)
    handleProrrogarTarea() {
        //Activar el spinner
        this.handleActivarSpinner();
        //LLamada a apex
        prorrogarTareaApex({ tareaId: this.recordId, fechaProrroga: this.fechaProrroga })
            .then(result => {
                //Mensaje de éxito
                this.lanzarToast('Éxito', 'Se ha prorrogado la tarea', 'success');
                //Cerrar modal
                this.handleCerrarModalProrrogar();
                //Refrescar el componente
                this.refrescarComponente();
                //Desactivar el spinner
                this.handleDesactivarSpinner();
            })
            .catch(error => {
                //Mensaje de error
                this.lanzarToast('Error', 'Error al prorrogar la tarea: ' + this.extractErrorMessage(error), 'error');
                //Desactivar el spinner
                this.handleDesactivarSpinner();
            });
    }

    //Botón descartar tarea (llamada a apex)
    handleDescartarTarea() {
        //Comprobar si la longitud de los comentarios es superior a 255. De ser asi, muestra toast informativo y sale del metodo
        if(this.comprobarLongitudComentarios()) {
            return;
        }
        //Activar el spinner
        this.handleActivarSpinner();
        //LLamada a apex
        descartarTareaApex({ tareaId: this.recordId, comentarios: this.comentariosFinalizarTarea })
            .then(result => {
                //Mensaje de éxito
                this.lanzarToast('Éxito', 'Se ha descartado la tarea', 'success');
                //Cerrar modal finalizar
                this.handleCerrarModalFinalizarTotal();
                //Refrescar el componente
                this.refrescarComponente();
                //Desactivar el spinner
                this.handleDesactivarSpinner();
            })
            .catch(error => {
                //Mensaje de error
                this.lanzarToast('Error', 'Error al descartar: ' + this.extractErrorMessage(error), 'error');
                //Desactivar el spinner
                this.handleDesactivarSpinner();
            });
    }

    //Botón finalizar incompleta (llamada a apex)
    handleFinalizarIncompleta() {
        //Comprobar si la longitud de los comentarios es superior a 255. De ser asi, muestra toast informativo y sale del metodo
        if(this.comprobarLongitudComentarios()) {
            return;
        }
        //Activar el spinner
        this.handleActivarSpinner();
        //LLamada a apex
        finalizarIncompletaApex({ tareaId: this.recordId, comentarios: this.comentariosFinalizarTarea })
            .then(result => {
                //Mensaje de éxito
                this.lanzarToast('Éxito', 'Se ha finalizado la tarea', 'success');
                //Cerrar modal finalizar
                this.handleCerrarModalFinalizarTotal();
                //Refrescar el componente
                this.refrescarComponente();
                //Desactivar el spinner
                this.handleDesactivarSpinner();
            })
            .catch(error => {
                //Mensaje de error
                this.lanzarToast('Error', 'Error al finalizar: ' + this.extractErrorMessage(error), 'error');
                //Desactivar el spinner
                this.handleDesactivarSpinner();
            });
    }

    //Botón finalizar (llamada a apex)
    handleFinalizarTarea() {
        //Comprobar si la longitud de los comentarios es superior a 255. De ser asi, muestra toast informativo y sale del metodo
        if(this.comprobarLongitudComentarios()) {
            return;
        }
        //Activar el spinner
        this.handleActivarSpinner();
        //LLamada a apex
        finalizarTareaApex({ tareaId: this.recordId, comentarios: this.comentariosFinalizarTarea })
            .then(result => {
                //Mensaje de éxito
                this.lanzarToast('Éxito', 'Se ha finalizado la tarea', 'success');
                //Cerrar modal finalizar
                this.handleCerrarModalFinalizarTotal();
                //Refrescar el componente
                this.refrescarComponente();
                //Desactivar el spinner
                this.handleDesactivarSpinner();
            })
            .catch(error => {
                //Mensaje de error
                this.lanzarToast('Error', 'Error al finalizar: ' + this.extractErrorMessage(error), 'error');
                //Desactivar el spinner
                this.handleDesactivarSpinner();
            });
    }

    //Botón enviar tarea a GGH (llamada a apex)
    handleEnviarTareaGGH() {
        //Bloquear el boton de enviar a GGH para evitar pulsaciones de más
        this.bloquearBotonEnviarGGH = true;
        //Activar el spinner
        this.handleActivarSpinner();
        //LLamada a apex
        enviarTareaGGHApex({ tareaId: this.recordId })
            .then(result => {
                //Mensaje de éxito
                this.lanzarToast('Éxito', 'La tarea ha sido enviada. Por favor espere y refresque la pagina para comprobar si la conexión ha sido exitosa', 'success');
                //Refrescar el componente
                this.refrescarComponente();
                //Desactivar el spinner
                this.handleDesactivarSpinner();
            })
            .catch(error => {
                //Mensaje de error
                this.lanzarToast('Error', 'Error al enviar la tarea: ' + this.extractErrorMessage(error), 'error');
                //Desactivar el spinner
                this.handleDesactivarSpinner();
            });
    }

    //Botón finalizar tarea de GGH (llamada a apex)
    handleFinalizarTareaGGH() {
        //Activar el spinner
        this.handleActivarSpinner();
        //LLamada a apex
        finalizarTareaGGHApex({ tareaId: this.recordId })
            .then(result => {
                //Mensaje de éxito
                this.lanzarToast('Éxito', 'Se ha finalizado la tarea', 'success');
                //Refrescar el componente
                this.refrescarComponente();
                //Desactivar el spinner
                this.handleDesactivarSpinner();
            })
            .catch(error => {
                //Mensaje de error
                this.lanzarToast('Error', 'Error al finalizar la tarea: ' + this.extractErrorMessage(error), 'error');
                //Desactivar el spinner
                this.handleDesactivarSpinner();
            });
    }

    comprobarLongitudComentarios() {
        if (this.comentariosFinalizarTarea.length > 255) {
            //Mensaje de error
            this.lanzarToast('Atención', 'El campo de comentarios no puede contener más de 255 caracteres', 'warning');
            return true; //Devuelve true si el contenido excede los 255 caracteres
        } else {
            return false; //Devuelve false si el contenido está dentro del límite
        }
    }

    lanzarToast(titulo, mensaje, variante) {
        const toastEvent = new ShowToastEvent({
            title: titulo,
            message: mensaje,
            variant: variante
        });
        this.dispatchEvent(toastEvent);
    }

    // Método para extraer el mensaje de error de la regla de validación
    extractErrorMessage(error) {
        if (error.body && error.body.message) {
            return error.body.message;
        } else if (error.body && error.body.pageErrors && error.body.pageErrors.length > 0) {
            return error.body.pageErrors[0].message;
        } else {
            return 'Error desconocido';
        }
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

    //Abrir modal devolver al gestor/letrado
    handleAbrirModalDevolverGestorLetrado() {
        this.mostrarModalDevolverGestorLetrado = true;
    }

    //Cerrar modal devolver al gestor/letrado
    handleCerrarModalDevolverGestorLetrado() {
        this.mostrarModalDevolverGestorLetrado = false;
    }

    //Abrir modal prorrogar
    handleAbrirModalProrrogar() {
        this.mostrarModalProrrogar = true;
    }

    //Cerrar modal prorrogar
    handleCerrarModalProrrogar() {
        this.mostrarModalProrrogar = false;
    }

    //Abrir el modal finalizar con los botones principales
    handleAbrirModalFinalizarConBotonesPrincipales() {
        this.handleAbrirModalFinalizar();
        this.handleMostrarBotonesPrincipalesFinalizar();
    }

    //Cerrar el modal finalizar y todos sus botones y elementos
    handleCerrarModalFinalizarTotal() {
        this.handleCerrarModalFinalizar();
        this.handleOcultarBotonesPrincipalesFinalizar();
        this.handleOcultarBotonesDescartar();
        this.handleOcultarBotonesFinalizadaIncompleta();
        this.handleOcultarBotonesFinalizada();
        this.handleOcultarComentarios();
    }

    //Abrir los botones de descartar y el input de comentarios cuando se le da a descartar
    handleAbrirDescartar() {
        this.handleMostrarBotonesDescartar();
        this.handleMostrarComentarios();
        this.handleOcultarBotonesPrincipalesFinalizar();
    }

    //Abrir los botones de finalizada incompleta y el input de comentarios cuando se le da a finalizada incompleta
    handleAbrirFinalizadaIncompleta() {
        this.handleMostrarBotonesFinalizadaIncompleta();
        this.handleMostrarComentarios();
        this.handleOcultarBotonesPrincipalesFinalizar();
    }

    //Abrir los botones de finalizada y el input de comentarios cuando se le da a finalizada incompleta
    handleAbrirFinalizada() {
        this.handleMostrarBotonesFinalizada();
        this.handleMostrarComentarios();
        this.handleOcultarBotonesPrincipalesFinalizar();
    }

    //Abrir modal finalizar
    handleAbrirModalFinalizar() {
        this.mostrarModalFinalizar = true;
    }

    //Cerrar modal finalizar
    handleCerrarModalFinalizar() {
        this.mostrarModalFinalizar = false;
    }

    //Mostrar los botones principales del modal finalizar (descartar, finalizada incompleta, finalizada)
    handleMostrarBotonesPrincipalesFinalizar() {
        this.mostrarBotonesPrincipalesFinalizar = true;
    }

    //Ocultar los botones principales del modal finalizar (descartar, finalizada incompleta, finalizada)
    handleOcultarBotonesPrincipalesFinalizar() {
        this.mostrarBotonesPrincipalesFinalizar = false;
    }

    //Mostrar botones descartar tarea
    handleMostrarBotonesDescartar() {
        this.mostrarBotonesDescartar = true;
    }

    //Ocultar botones descartar tarea
    handleOcultarBotonesDescartar() {
        this.mostrarBotonesDescartar = false;
    }

    //Mostrar botones finalizada incompleta
    handleMostrarBotonesFinalizadaIncompleta() {
        this.mostrarBotonesFinalizadaIncompleta = true;
    }

    //Ocultar botones finalizada incompleta
    handleOcultarBotonesFinalizadaIncompleta() {
        this.mostrarBotonesFinalizadaIncompleta = false;
    }

    //Mostrar botones finalizada
    handleMostrarBotonesFinalizada() {
        this.mostrarBotonesFinalizada = true;
    }

    //Ocultar botones finalizada
    handleOcultarBotonesFinalizada() {
        this.mostrarBotonesFinalizada = false;
    }

    //Mostrar el input comentarios del modal de finalizar tarea
    handleMostrarComentarios() {
        this.mostrarComentarios = true;
    }

    //Ocultar el input comentarios del modal de finalizar tarea
    handleOcultarComentarios() {
        this.mostrarComentarios = false;
    }

    //Onchange del motivo de devolución
    changeMotivoDevolver(event) {
        this.motivoDevolver = event.target.value;
    }

    //Onchange del input de comentarios del modal de finalizar tarea
    changeComentarios(event) {
        this.comentariosFinalizarTarea = event.target.value;
    }

    //Onchange del input de fecha de prorroga
    changeFechaProrroga(event) {
        this.fechaProrroga = event.target.value;
    }

    handleAbrirModalNotificar(){
        this.mostrarModalNotificar = true;
    }

    handleCerrarModalNotificar() {
        this.mostrarModalNotificar = false;
    }

    changeComentariosNotificar(event) {
        this.comentariosNotificar = event.target.value;
    }

    handleNotificarTarea() {
        //Activar el spinner
        this.handleActivarSpinner();
        this.handleCerrarModalNotificar();
        //LLamada a apex
        notificarTareaResolutor({ tareaId: this.recordId, comentarios: this.comentariosNotificar })
            .then(result => {
                //Mensaje de éxito
                this.lanzarToast('Éxito', 'Se ha enviado la notificación.', 'success');
                //Cerrar modal finalizar
                //Refrescar el componente
                this.refrescarComponente();
                //Desactivar el spinner
                this.handleDesactivarSpinner();
            })
            .catch(error => {
                //Mensaje de error
                this.lanzarToast('Error', 'Error al notificar la tarea: ' + this.extractErrorMessage(error), 'error');
                //Desactivar el spinner
                this.handleDesactivarSpinner();
            });
    }
}