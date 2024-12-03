import { LightningElement, track, wire } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';


import getUrl  from '@salesforce/apex/CIBE_LinkCarterasController.getUrl';

import titulo from '@salesforce/label/c.CIBE_CarterasEquipo';

export default class Cibe_LinkCarteras extends NavigationMixin (LightningElement) {

    @track url;

    label = {
        titulo
    };

    @wire(getUrl)
    getUrl({ error, data }){
        if(data){
            this.url = data;
        } else if(error){
            console.log(error);
        }
    }
}