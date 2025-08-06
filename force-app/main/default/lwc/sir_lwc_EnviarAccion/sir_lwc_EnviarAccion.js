import { LightningElement, track, api,wire  } from 'lwc';
import { CloseActionScreenEvent } from 'lightning/actions';
//import comprobarPropietarioAccion from '@salesforce/apex/SIR_LCMP_NuevaAccion.comprobarPropietarioAccion';
//import enviarAccion from '@salesforce/apex/SIR_LCMP_NuevaAccion.enviarAccion';

import comprobarPropietarioAccion from '@salesforce/apex/SIR_LCMP_accionSinWorkflow.comprobarPropietarioAccionReenvio';
import enviarAccion from '@salesforce/apex/SIR_LCMP_accionSinWorkflow.enviarAccion';

export default class Sir_lwc_EnviarAccion extends LightningElement {
    @api recordId;
    @track disabledCerrar = false;
    @track mensajeEspera = true;
    @track mensajeOK = false;
    @track mensajeKO = false;
    @track error;

    @wire(comprobarPropietarioAccion, {idAccion: '$recordId'})
    comprobarPropietarioAccion({ error, data }) {           
        if(data){
            if(data == 'OK'){               
                this.mensajeEspera = false;    
                this.enviarAccionWS();           
            }  else {
                this.mensajeError = data;              
                this.mensajeEspera = false; 
                this.disabledCerrar = false;
                this.mensajeEspera = false;
                this.mensajeOK = false;
                this.mensajeKO = true;
            }       
        } else if(error){
            this.mensajeError = error;
            this.disabledCerrar = false;
            this.mensajeEspera = false;
            this.mensajeOK = false;
            this.mensajeKO = true;
        }
    }

    enviarAccionWS() {
        enviarAccion({idAccion: this.recordId}).then(result => { 
            if(result.length >= 0){
                if(result[0] == 'OK'){                    
                    this.disabledCerrar = false;
                    this.mensajeEspera = false;
                    this.mensajeKO = false;
                    this.mensajeOK = true;
                    this.pasoUno = false;
                    this.pasoDos = true;
                }  else {
                    this.mensajeError = result[1];
                    this.codigoError = result[2];                    
                    this.disabledCerrar = false;
                    this.mensajeEspera = false;
                    this.mensajeOK = false;
                    this.mensajeKO = true;
                }
            }      
        })
        .catch(error => {
            this.mensajeError = error;
            this.disabledCerrar = false;
            this.mensajeEspera = false;
            this.mensajeOK = false;
            this.mensajeKO = true;
        });  
    }

    cancelar() {
        this.dispatchEvent(new CloseActionScreenEvent()); 
    }

}