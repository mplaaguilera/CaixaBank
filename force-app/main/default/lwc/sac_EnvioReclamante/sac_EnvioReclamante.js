import { LightningElement, api, wire, track } from 'lwc';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import CASE_OBJECT from '@salesforce/schema/Case';
import envioReclamante from '@salesforce/apex/SAC_LCMP_EnvioReclamante.envioReclamante';
import cerrarCasos from '@salesforce/apex/SAC_LCMP_EnvioReclamante.cerrarCasos';
import reclamacionEjecucion from '@salesforce/apex/SAC_LCMP_EnvioReclamante.reclamacionEjecucion';
import { getRecord } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class Sac_EnvioReclamante extends LightningElement {

    @api recordId;
    @api spinnerLoading = false;
    @track acciones;
    @track error;
    @track isModalNoAccionesOpen = false;
    @track isModalSiAccionesOpen = false;

    @wire(getRecord, { recordId: '$recordId' })
    case;

    openModalNoAcciones() {
        this.spinnerLoading = true;
        this.isModalNoAccionesOpen = true;
        this.spinnerLoading = false;
    }

    closeModalNoAcciones() {
        this.isModalNoAccionesOpen = false;
    }

    openModalSiAcciones() {
        this.spinnerLoading = true;
        this.isModalSiAccionesOpen = true;
        this.spinnerLoading = false;
    }

    closeModalSiAcciones() {
        this.isModalSiAccionesOpen = false;
    }

    submitDetailsModalNoAcciones() {
        this.spinnerLoading = true;
            cerrarCasos({caseId: this.recordId}).then(result => {

                const evt = new ShowToastEvent({
                    title: 'Envío efectuado',
                    message: 'Se ha completado el envío al reclamante y se ha cerrado la reclamación y sus pretensiones',
                    variant: 'success'
                });
    
                this.dispatchEvent(evt);
                this.spinnerLoading = false;
                eval("$A.get('e.force:refreshView').fire();");
            })
            .catch(error => {
                
                const evt = new ShowToastEvent({
                    title: 'No se ha podido completar el envío',
                    message: error.body.message,
                    variant: 'error'
                });

                this.dispatchEvent(evt);
                this.spinnerLoading = false;
            });
        this.isModalNoAccionesOpen = false;
    }

    submitDetailsModalSiAcciones() {
        this.spinnerLoading = true;
        reclamacionEjecucion({ caseId: this.recordId }).then(result => { //Esta llamada al metodo habrá que quitarla del modal en el futuro

                const evt = new ShowToastEvent({
                    title: 'Envío efectuado',
                    message: 'Se ha completado el envío al reclamante. Reclamación pasada a ejecución y sus pretensiones a cerrado',
                    variant: 'success'
                });
    
                this.dispatchEvent(evt);
                this.spinnerLoading = false;
                eval("$A.get('e.force:refreshView').fire();");
            })
            .catch(error => {
                
                const evt = new ShowToastEvent({
                    title: 'No se ha podido completar el envío',
                    message: error.body.message,
                    variant: 'error'
                });

                this.dispatchEvent(evt);
                this.spinnerLoading = false;
            });
        this.isModalSiAccionesOpen = false;
        
    }

    comprobarAccionesReclamacion() {
        envioReclamante({ caseId: this.recordId })
            .then(result => {
                this.acciones = result;

                if(this.acciones == ''){
                    this.openModalNoAcciones();
                } else {
                    this.openModalSiAcciones();
                }
            })
            .catch(error => {
                this.error = error;
            });
    }

}