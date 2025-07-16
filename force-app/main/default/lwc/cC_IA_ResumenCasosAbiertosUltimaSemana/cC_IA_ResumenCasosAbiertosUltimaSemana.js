import { LightningElement, api, wire, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import generarResumenCasos from '@salesforce/apex/CC_IA_CasosUltimaSemana_Controller.generarResumenCasos';
import { NavigationMixin } from 'lightning/navigation';

export default class CC_IA_ResumenCasosAbiertosUltimaSemana extends NavigationMixin(LightningElement) {
    @api recordId; // Asegúrate de tener el recordId si es necesario
    @track resumenTexto; // Variable para almacenar el texto de la respuesta
    @track error; // Variable para almacenar posibles errores
    @track isLoadingOpp;
    @track sinDatos;
    resultado;
    tematica;
    numero;
    Url;
    asunto;
    enlace;
    error;
    showSpinner = false;
    bloques = [];

    // Llamar al método de Apex
    connectedCallback() {
        this.isLoadingOpp = true;
        this.sinDatos = false;
    this.obtenerResumen();
    }

    obtenerResumen() {
        generarResumenCasos({ caseId: this.recordId })
            .then(detallesConsulta => {
              const datos = JSON.parse(detallesConsulta);
              const regex = /^[0-9]*$/;
            if(regex.test(datos.Cases[0].Número)==true){
                this.resumenTexto = datos.Cases; // Asigna la respuesta a la variable resumenTexto    
            }else{
                this.sinDatos = true;
            }
            this.isLoadingOpp = false;
            })
            .catch(error => {
                this.error = error; // Manejar el error
                this.isLoadingOpp = false;
                this.toast('error', 'Error al obtener el resumen');
            });
    }

    handleOpenTab(event) {
        const url = event.target.getAttribute('data-url');
        if (url) {
            this[NavigationMixin.Navigate]({
                type: 'standard__recordPage',
                attributes: {
                    recordId: url,
                    objectApiName:'Case',
                    actionName:'view'
                },
                state: {
                  navigationLocation: 'LIST_VIEW'
                }

            });
        }
    }
    toast(variant, title, message = '') {
        this.dispatchEvent(new ShowToastEvent({ variant, title, message }));
    }
}