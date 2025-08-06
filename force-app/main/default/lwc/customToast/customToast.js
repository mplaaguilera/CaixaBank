import { LightningElement, api } from 'lwc';

export default class CustomToast extends LightningElement {
    @api cuerpo;
    @api tipo;

    get isError(){
        return this.tipo == 'error' ? true : false;
    }
}