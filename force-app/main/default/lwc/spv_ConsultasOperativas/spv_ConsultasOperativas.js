import { LightningElement, api, wire, track } from 'lwc';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import ESTADO_FIELD from "@salesforce/schema/SAC_Interaccion__c.SAC_Estado__c";
import GRUPO_EXTERNO from "@salesforce/schema/SAC_Interaccion__c.SAC_GrupoColaborador__r.SAC_Externo__c";
import GRUPO_DEV_NAME from "@salesforce/schema/SAC_Interaccion__c.SAC_GrupoColaborador__r.SAC_DeveloperName__c";
import OWNERID_FIELD from "@salesforce/schema/SAC_Interaccion__c.OwnerId";
import GRUPOCONSULTA_FIELD from "@salesforce/schema/SAC_Interaccion__c.SAC_GrupoColaborador__c";
import { RefreshEvent } from "lightning/refresh";
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import idUsuario from "@salesforce/user/Id";
import marcarPendienteRespuestaDefinitiva from '@salesforce/apex/SPV_LCMP_ConsultasOperativas.marcarPendienteRespuestaDefinitiva';
import tomarPropiedadConsulta from '@salesforce/apex/SPV_LCMP_ConsultasOperativas.tomarPropiedadConsulta';
import devolverConsultaAlGrupo from '@salesforce/apex/SPV_LCMP_ConsultasOperativas.devolverConsultaAlGrupo';


const consultaFields = [ESTADO_FIELD, GRUPO_EXTERNO, GRUPO_DEV_NAME, OWNERID_FIELD, GRUPOCONSULTA_FIELD];


export default class Spv_ConsultasOperativas extends LightningElement {

    @api recordId; //Id del registro en el que se encuentra el componente
    @track userId = idUsuario;

    //Recuperar registro con los campos definidos en la constante consultaFields
    @wire(getRecord, {
        recordId: "$recordId",
        fields: consultaFields
    })
    record;

    get consultaEstado() {
        return getFieldValue(this.record.data, ESTADO_FIELD);
    }

    get grupoExterno() {
        return getFieldValue(this.record.data, GRUPO_EXTERNO);
    }

    get devNameGrupo() {
        return getFieldValue(this.record.data, GRUPO_DEV_NAME);
    }

    get consultaOwnerId() {
        return getFieldValue(this.record.data, OWNERID_FIELD);
    }

    get grupoConsulta() {
        return getFieldValue(this.record.data, GRUPOCONSULTA_FIELD);
    }

    //Getters visibilidad botones
    get visibilidadPteRespuesta() {
        //Si la consulta esta en estado 'Resuelta' se debe mostrar el botón
        if (this.consultaEstado == 'SAC_Resuelta' && this.devNameGrupo != "OFICINA") {
            return true;
        } else {
            return false;
        }
    }

    get visibilidadTomarPropiedadyDevolver() {
        //Si es una consulta interna y no es de oficina
        if (this.grupoExterno == false && this.devNameGrupo != "OFICINA") {
            return true;
        } else {
            return false;
        }
    }

    get disableBotonTomarPropiedad() {
        //Si el usuario es el mismo que ya tiene la consulta se debe deshabilitar
        if (this.consultaOwnerId == this.userId) {
            return true;
        } else {
            return false;
        }
    }

    get disableBotonDevolver() {
        //Si el usuario es el mismo que el owner actual de la consulta debe estar activo
        if (this.consultaOwnerId == this.userId) {
            return false;
        } else {
            return true;
        }
    }

    marcarPteRespuestaDef() {
        this.handleActivarSpinner();

        marcarPendienteRespuestaDefinitiva({ consultaId: this.recordId })
            .then(result => {
                this.lanzarToast('Éxito', 'Se ha marcado la consulta como pendiente de respuesta definitiva.', 'success');
                this.refrescarComponente();
                this.handleDesactivarSpinner();
            })
            .catch(error => {
                this.lanzarToast('Error', 'No se pudo marcar la consulta como pendiente de respuesta definitiva: ' + error.body.message, 'error');
                this.handleDesactivarSpinner();
            }
        );
    }

    tomarPropiedad(){
        //Activar el spinner
        this.handleActivarSpinner();

        tomarPropiedadConsulta({ consultaId: this.recordId, grupoConsulta: this.grupoConsulta, usuarioActualId: this.userId })
            .then(result => {
                //Mensaje de éxito
                this.lanzarToast('Éxito', 'Se ha tomado en propiedad la consulta', 'success');
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

    devolverConsulta(){

        //Activar el spinner
        this.handleActivarSpinner();

        devolverConsultaAlGrupo({ consultaId: this.recordId })
            .then(result => {
                //Mensaje de éxito
                this.lanzarToast('Éxito', 'Se ha devuelto la consulta al grupo', 'success');
                //Refrescar el componente
                this.refrescarComponente();
                //Desactivar el spinner
                this.handleDesactivarSpinner();
            })
            .catch(error => {
                //Mensaje de error
                this.lanzarToast('Error', 'Error al devolver la consulta: ' + error.body.message, 'error');
                //Desactivar el spinner
                this.handleDesactivarSpinner();
            });
    }

    //Activar el spinner
    handleActivarSpinner() {
        this.mostrarSpinner = true;
    }

    //Desactivar el spinner
    handleDesactivarSpinner() {
        this.mostrarSpinner = false;
    }

    lanzarToast(titulo, mensaje, variante) {
        const toastEvent = new ShowToastEvent({
            title: titulo,
            message: mensaje,
            variant: variante
        });
        this.dispatchEvent(toastEvent);
    }

    //Refresca el componente
    refrescarComponente() {
        this.dispatchEvent(new RefreshEvent());
    }
}