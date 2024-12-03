import { LightningElement, api } from 'lwc';

export default class Cibe_Input extends LightningElement {

    @api type = "text";
    @api label;
    @api value;
    @api placeholder = "";
    @api required = false;
    @api disabled = false;
    @api hasIcon = false;
    @api icon;

}