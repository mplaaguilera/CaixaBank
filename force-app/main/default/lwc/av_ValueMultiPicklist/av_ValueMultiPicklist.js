import { LightningElement, api } from 'lwc';

export default class Av_ValueMultiPicklist extends LightningElement {
    @api selected = false;
    @api label;
    @api value;

    handleSelect(event) {
        if(this.selected){
            this.selected = false;
        }else{
            this.selected = true;
        } 
    }
}