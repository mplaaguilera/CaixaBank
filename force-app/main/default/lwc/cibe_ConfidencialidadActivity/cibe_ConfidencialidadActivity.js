import { LightningElement, api , wire, track} from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from "lightning/navigation";

//Controller
import getRecord from '@salesforce/apex/CIBE_ConfidencialidadActivityController.getRecord';saveRecord
import saveRecord from '@salesforce/apex/CIBE_ConfidencialidadActivityController.saveRecord';
import createNotification from '@salesforce/apex/CIBE_ConfidencialidadActivityController.createNotification';
import isOwner from '@salesforce/apex/CIBE_ConfidencialidadActivityController.isOwner';


//Labels
import cargando from '@salesforce/label/c.CIBE_Cargando';
import cerrar from '@salesforce/label/c.CIBE_Cerrar';
import guardar from '@salesforce/label/c.CIBE_Guardar';
import cancelar from '@salesforce/label/c.CIBE_Cancelar';
import confidencial from '@salesforce/label/c.CIBE_EventoConfidencial';
import eventToConfidential from '@salesforce/label/c.CIBE_EventToConfidential';
import confirmacionCambiarConfidencialidad from '@salesforce/label/c.CIBE_ConfirmacionCambiarConfidencialidad';

import opConfidencialGestionadaPorEquipoAsignado from '@salesforce/label/c.CIBE_OpConfidencialGestionadaPorEquipoAsignado';
import oportunidadActualizada from '@salesforce/label/c.CIBE_OportunidadActualizada';
import oportunidadActualizadaCorrectamente from '@salesforce/label/c.CIBE_OportunidadActualizadaCorrectamente';
import problemaAlEnviarNotificaciones from '@salesforce/label/c.CIBE_ProblemaAlEnviarNotificaciones';


export default class Cibe_Confidencialidad extends NavigationMixin(LightningElement) {

    @api recordId;

    @track confidential;

    @track showModal = false;
    @track loading = false;

    @track hasNotPermission = false;
    
    labels = {
        cargando,
        cerrar,
        cancelar,
        guardar,
        confidencial,
        eventToConfidential,
        confirmacionCambiarConfidencialidad
    }

    @track _wiredData;

    @wire(getRecord, { recordId: '$recordId' })
    getRecordData(wiredData) {
        this._wiredData = wiredData;
        const { data, error } = wiredData;
        if(data) {
            var result = JSON.parse(JSON.stringify(data));
            this.confidential = result.confidential;
        }else if(error) {
            console.log(error);
        }
    };

    @wire(isOwner, { recordId : '$recordId'})
    isOwneer({error, data}){
        if(data){
            console.log(data);
            this.hasNotPermission = data;
        }else if(error){
            console.log(error);
        }
    }

    handleChange (event) {
        this.confidential = event.target.checked;
        this.showModal = true;
    }
    
    handleClose() {
        this.confidential = !this.confidential;
        this.showModal = false;
    }

    handleSave () {
        this.loading = true;
        this.showModal = false;

        saveRecord({ recordId : this.recordId, confidential : this.confidential })
            .then(e => {
                if(this.confidential) {
                    createNotification({recordId : this.recordId}).then(result => {
                        this.dispatchEvent(
                            new ShowToastEvent({
                                title: this.labels.oportunidadActualizada,
                                message: this.labels.oportunidadActualizadaCorrectamente,
                                variant: 'success'
                            })
                        ); 
                    }).catch(error => {
                        this.confidential = !this.confidential;
                        console.log(error);

                        const evt = new ShowToastEvent({
                            title: this.labels.problemaAlEnviarNotificaciones,
                            message: JSON.stringify(error),
                            variant: 'error'
                        });
                        this.dispatchEvent(evt);
                    });
                }
            }).catch(error => {
                this.confidential = !this.confidential;
                console.log(error);

                const evt = new ShowToastEvent({
                    title: this.labels.problemaAlEnviarNotificaciones,
                    message: JSON.stringify(error),
                    variant: 'error'
                });
                this.dispatchEvent(evt);
            }).finally(() => {
                this.loading = false;
            });
    }

}