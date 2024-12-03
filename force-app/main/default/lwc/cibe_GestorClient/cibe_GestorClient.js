import { LightningElement, api, wire } from 'lwc';

import getGestor from '@salesforce/apex/CIBE_GestorClient_Controller.getGestor';

//labels
import gestorCliente from '@salesforce/label/c.CIBE_GestorCliente';

export default class Cibe_GestorClient extends LightningElement {

    @api recordId;

    label = {
        gestorCliente
    };

    gestores = [];

    @wire (getGestor, {recordId : '$recordId'})
    getGestor({error, data}){
        if(data){
            console.log('ok');
            console.log('gestores ' + data);
            this.gestores = data;
        }else if (error){
            console.log(error);
        }
    }

}