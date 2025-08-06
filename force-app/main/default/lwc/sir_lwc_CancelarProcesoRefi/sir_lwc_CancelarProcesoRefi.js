import { LightningElement, track, api,wire  } from 'lwc';
import { CloseActionScreenEvent } from 'lightning/actions';
import comprobarPropietario from '@salesforce/apex/SIR_LCMP_CancelarProcesoRefi.comprobarPropietario';
import cancelarProceso from '@salesforce/apex/SIR_LCMP_CancelarProcesoRefi.cancelarProceso';
import updateRegistros from '@salesforce/apex/SIR_LCMP_CancelarProcesoRefi.updateRegistros';

export default class Sir_lwc_CancelarProcesoRefi extends LightningElement {
    @api recordId;
    @track confirmacion = false;
    @track procesoCancelar = true;
    @track disabledCerrar = false;
    @track mensajeEspera = true;
    @track mensajeOK = false;
    @track mensajeKO = false;
    @track error;

    @wire(comprobarPropietario, {idProceso: '$recordId'})
    comprobarPropietario({ error, data }) {           
        if(data){
            if(data == 'OK'){                
                this.procesoCancelar = false;
                this.mensajeEspera = false; 
                this.confirmacion = true;                
            }  else {
                this.mensajeError = data;
                this.procesoCancelar = true;
                this.mensajeEspera = false; 
                this.disabledCerrar = false;
                this.mensajeEspera = false;
                this.mensajeOK = false;
                this.mensajeKO = true;
            }       
        } else if(error){
            console.log(error);
            this.mensajeError = error;
            this.disabledCerrar = false;
            this.mensajeEspera = false;
            this.mensajeOK = false;
            this.mensajeKO = true;
        }
    }


    canProceso() {
        cancelarProceso({idProceso: this.recordId}).then(result => { 
            if(result.length >= 0){
                if(result[0] == 'OK'){                    
                    this.modificarRegistros();
                }  else {
                    console.log(result);
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
            console.log(error);
            this.mensajeError = error;
            this.disabledCerrar = false;
            this.mensajeEspera = false;
            this.mensajeOK = false;
            this.mensajeKO = true;
        });  
    }


    modificarRegistros() {
        updateRegistros({idProceso: this.recordId}).then(result => {             
            if(result == 'OK'){                    
                this.disabledCerrar = false;
                this.mensajeEspera = false;
                this.mensajeKO = false;
                this.mensajeOK = true;
                this.pasoUno = false;
                this.pasoDos = true;
            }  else {
                console.log(result);
                this.mensajeError = result;                   
                this.disabledCerrar = false;
                this.mensajeEspera = false;
                this.mensajeOK = false;
                this.mensajeKO = true;
            }            
        })
        .catch(error => {
            console.log(error);
            this.mensajeError = error;
            this.disabledCerrar = false;
            this.mensajeEspera = false;
            this.mensajeOK = false;
            this.mensajeKO = true;
        });  
    }


    siCancelar(){        
        this.confirmacion = false;
        this.procesoCancelar = true;
        this.mensajeEspera = true;
        this.canProceso();
    }


    cancelar() {
        this.dispatchEvent(new CloseActionScreenEvent()); 
    }

}