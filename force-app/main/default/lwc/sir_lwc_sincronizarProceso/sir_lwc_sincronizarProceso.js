import { LightningElement, track, api } from 'lwc';
import { CloseActionScreenEvent } from 'lightning/actions';
import LightningModal from 'lightning/modal';

import sincronizarProceso from '@salesforce/apex/SIR_LCMP_SincronizarProceso.sincronizarProceso';

export default class Sir_lwc_sincronizarProceso extends LightningElement{
    
    @api recordId;   
   
    @track mensajeError = null;
    @track codigoError = null;
    
    @track parteSincronizar = true;
    @track parteGestionar = false;

    @track loadingVisible = true;
    @track mensajeOKVisible = false;    
    @track mensajeKO = false;
 
    @track botonCancelarVisible = true;
    @track botonCerrarVisible = false;

    @track disabledCancelar = true;
    @track disabledCerrar = true;
    @track disabledContinuar = true;
   
    connectedCallback(){   
        setTimeout(() => {                    
            sincronizarProceso({procesoId: this.recordId}).then(result => {
                if(result != undefined && result.length >= 0){ 
                    //Si el resultado del WS es OK 
                    if(result[0] == 'OK'){                   
                        this.loadingVisible = false;
                        this.mensajeOKVisible = true;    
                        this.mensajeKO = false;
                    
                        this.botonCancelarVisible = false;
                        this.botonCerrarVisible = true;
        
                        this.disabledCancelar = true;
                        this.disabledCerrar = false;
                        this.disabledContinuar = false;                    
                    } else { //Si el resultado del WS es KO se muestra el error
                        this.mensajeError = result[1];
                        this.codigoError = result[2];
        
                        this.loadingVisible = false;
                        this.mensajeOKVisible = false;    
                        this.mensajeKO = true;
                    
                        this.botonCancelarVisible = true;
                        this.botonCerrarVisible = false;
        
                        this.disabledCancelar = false;
                        this.disabledCerrar = true;
                        this.disabledContinuar = true;
                    }           
                } else if(result.error){
                    this.mensajeError = result.body.message;
                    this.codigoError = result.body.stackTrace;
        
                    this.loadingVisible = false;
                    this.mensajeOKVisible = false;    
                    this.mensajeKO = true;
                
                    this.botonCancelarVisible = true;
                    this.botonCerrarVisible = false;
        
                    this.disabledCancelar = false;
                    this.disabledCerrar = true;
                    this.disabledContinuar = true;
                }
            })
            .catch(error => {
                console.log('Error');
                console.log(error);            
            });      
        }, 100);           
    }

    continuarGestion(){
        this.parteSincronizar = false;
        this.parteGestionar = true;      
    }

    cancelar() {
        this.dispatchEvent(new CloseActionScreenEvent());       
    }

    cerrar() {
        this.dispatchEvent(new CloseActionScreenEvent());
        window.location.reload();
    }  

}