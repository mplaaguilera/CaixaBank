import { LightningElement, api, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import isAssetActive from '@salesforce/apex/HDT_CaseAssetController.isAssetActive';
import mensajeValidacionPreguntas from '@salesforce/apex/HDT_CaseAssetController.mensajeValidacionPreguntas';
import conseguirAssetSecundarioCaso from '@salesforce/apex/HDT_CaseAssetController.isSegundoAssetActive';

export default class Hdt_MostrarMensaje_Activos_Casos extends LightningElement {
    mostrarError = false;
    @api titulo ;
    @api mensaje ; 
    @api recordId; // ID del caso
    @api validacion = 'ACTIVO_KO';

    connectedCallback() {
        this.checkAssetStatus();
        this.recuperarMensajeToast();
    }

    checkAssetStatus() {
        isAssetActive({ caseId: this.recordId })
            .then((result) => {
                this.mostrarError = result; // Mostrar error si el Asset está activo
            })
            .catch((error) => {
                this.mostrarToast('error', 'No se pudo actualizar Caso', error);
            });
    }

    recuperarMensajeToast() {
        mensajeValidacionPreguntas({ validacion: this.validacion })
            .then(result => {
                this.titulo = result.Name;
                this.mensaje = result.CC_Valor__c;
                //this.mostrarToast(this.tipo, tituloMensaje, mensaje);
            })
            .catch(error => {
                this.mostrarToast('error', 'No se pudo actualizar Caso', error);
            });
    }

    mostrarToast(tipo, titulo, mensaje) {
		this.dispatchEvent(new ShowToastEvent({variant: tipo, title: titulo, message: mensaje, mode: 'dismissable', duration: 4000}));
	}

}