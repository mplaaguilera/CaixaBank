import { LightningElement, wire, track, api } from 'lwc';
import wrapperCabecera from '@salesforce/apex/SIR_LCMP_GetProfileClient.wrapperCabecera';

export default class Sir_lwc_cabeceraCliente extends LightningElement {

@api recordId;   
@track wrapper;
@track vacio = false;
@api tipoFicha;
@wire(wrapperCabecera, { recordId: '$recordId' /*, tipoFicha: '$tipoFicha' */}) // 
    wrapperCabecera({ error, data }) {
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