import { LightningElement, api, track } from 'lwc';
import { CloseActionScreenEvent } from 'lightning/actions';
import getTarea from '@salesforce/apex/SIR_LCMP_TareaCTL.getTarea';
import llamadaWS from '@salesforce/apex/SIR_LCMP_TareaCTL.llamadaWS';

export default class Sir_lwc_TareaCTL extends LightningElement {
    @api isLoaded = false;
    @api recordId;

    @track errorPropietario = false;
    @track mensajeKO = false;
    @track mensajeError = null;
    @track codigoError = null;

    connectedCallback(){
        getTarea({procesoId: this.recordId}).then(result => { 
            this.isLoaded = true;
            if(result){ 
                this.tareaRecord = result;
                this.tareaId = this.tareaRecord.SIREC__SIREC_fld_tarea__c;
                this.estadoTarea = this.tareaRecord.SIREC__SIREC_fld_tarea__r.SIREC__SIREC_fld_estado__c;                
                llamadaWS({tareaId: this.tareaId}).then(result => {
                    if(result.length >= 0){
                        //Si el resultado del WS es OK 
                        if(result[0] === 'OK'){
                            this.dispatchEvent(new CustomEvent('siguiente'));
                        }else{
                            //Se muestra el error
                            this.isLoaded = false;
                            this.mensajeKO = true;
                            this.mensajeError = 'Se ha producido un problema. ' + result[1];
                            this.codigoError = result[2];
                        }
                    }
                })                      
            }                                    
        })
        .catch(error => {
            this.isLoaded = false;
            //Se muestra el error
            this.mensajeKO = true;
            this.mensajeError = error;
            this.errorPropietario = false; 
        });
    } 

    closeQuickAction() {
        this.dispatchEvent(new CloseActionScreenEvent());
        window.location.reload();
    }
}