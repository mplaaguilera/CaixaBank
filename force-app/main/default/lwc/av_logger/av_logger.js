import { LightningElement, api } from 'lwc';
import { log } from 'lightning/logger';

export default class TrackerComponent extends LightningElement {
    @api identifier;
    @api message;

    connectedCallback() {
        this.logComponentLoad();
    }

    logComponentLoad() {
        let msg = {
            identifier: this.identifier,
            message: this.removeAccents(this.message)
        }
        log (msg);
    }

    removeAccents(text) {
        const withAccents = 'áéíóúÁÉÍÓÚüÜñÑ';
        const withoutAccents = 'aeiouAEIOUuUnN';
    
        return text.replace(/[áéíóúÁÉÍÓÚüÜñÑ]/g, match => 
            withoutAccents[withAccents.indexOf(match)]
        );
    }

}