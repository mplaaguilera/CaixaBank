import { LightningElement, track, api,wire  } from 'lwc';
import { CloseActionScreenEvent } from 'lightning/actions';
import { refreshApex } from '@salesforce/apex';
import comprobarCampos from '@salesforce/apex/SIR_LCMP_EnviarFormulario.comprobarCampos';
import enviarProceso from '@salesforce/apex/SIR_LCMP_EnviarFormulario.enviarProceso';
import enviarForm from '@salesforce/apex/SIR_LCMP_EnviarFormulario.enviarForm';


export default class Sir_lwc_EnviarFormulario extends LightningElement {
    @api recordId;
    @track pasoUno = true;
    @track pasoDos = false;
    @track disabledCerrar = true;
    @track mensajeEspera = true;
    @track mensajeOK = false;
    @track mensajeKO = false;
    @track mensajeError;
    @track codigoError;
    resultado;
    primeraVez = true;

    wiredResults;

    @wire(comprobarCampos, { idFormulario: '$recordId'})
    imperativeWiring(result) {
        this.wiredResults = result;
        this.refresh();
        if(result.data) { 
            if(result.data == 'OK'){
                if(this.primeraVez == true){
                    this.enviarProcesoSirec();
                }              
            }  else {
                this.mensajeError = result.data;
                this.disabledCerrar = false;
                this.mensajeEspera = false;
                this.mensajeOK = false;
                this.mensajeKO = true;
            }          
        }else if(result.error) {
            this.mensajeError = result.error;
            this.disabledCerrar = false;
            this.mensajeEspera = false;
            this.mensajeOK = false;
            this.mensajeKO = true;
        }
    } 


    @api
    refresh() {
        return refreshApex(this.wiredResults); 
    }


    enviarProcesoSirec() {
        enviarProceso({idFormulario: this.recordId}).then(result => { 
            if(result.length >= 0){
                if(result[0] == 'OK'){
                    this.primeraVez = false;
                    this.disabledCerrar = false;
                    this.mensajeEspera = false;
                    this.mensajeKO = false;
                    this.mensajeOK = true;
                    this.pasoUno = false;
                    this.pasoDos = true;
                    this.enviarFormulario();
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

    enviarFormulario() {
        enviarForm({idFormulario: this.recordId}).then(result => { 
            if(result.length >= 0){
                if(result[0] == 'OK'){
                    this.primeraVez = false;
                    this.disabledCerrar = false;
                    this.mensajeEspera = false;
                    this.mensajeKO = false;
                    this.mensajeOK = true;
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