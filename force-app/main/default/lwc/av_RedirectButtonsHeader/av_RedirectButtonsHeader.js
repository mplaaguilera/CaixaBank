import { LightningElement,api } from 'lwc';

export default class Av_RedirectButtonsHeader extends LightningElement {


    @api labelbutton;

    get isModifyButton(){
        return(this.labelbutton == 'Editar')
    }

    
}