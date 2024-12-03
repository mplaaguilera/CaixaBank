import { LightningElement, wire, track, api } from 'lwc';
import wrapperCabecera from '@salesforce/apex/SIRE_LCMP_PerfilCliente.wrapperCabecera';

export default class Sire_lwc_perfilCliente extends LightningElement {

@api recordId;   
@track wrapper;
@track vacio = false;

@wire(wrapperCabecera, { recordId: '$recordId' }) 
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