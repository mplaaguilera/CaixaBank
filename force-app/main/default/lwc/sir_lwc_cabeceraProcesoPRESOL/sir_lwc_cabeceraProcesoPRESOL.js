import { LightningElement, wire, track, api } from 'lwc';
import wrapperProcesoPRESOL from '@salesforce/apex/SIR_LCMP_GetProfileClient.wrapperProcesoPRESOL';

export default class Sir_lwc_cabeceraProcesoPRESOL extends LightningElement {

@api recordId;   
@track wrapper;
@track vacio = false;
@api tipoFicha;
@wire(wrapperProcesoPRESOL, { recordId: '$recordId'}) // 
    wrapperProcesoPRESOL({ error, data }) {
        if (data) {
            this.wrapper = data;
            console.log(this.wrapper);
            if(data.length === 0){
                this.vacio = true;
            }
        } else if (error) {
            console.log('error ');
        }
    }
}