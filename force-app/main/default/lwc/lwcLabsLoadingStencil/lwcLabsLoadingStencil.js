import { LightningElement, api } from 'lwc';
export default class LwcLabsLoadingStencil extends LightningElement {
    @api type = 'activity';
    @api spinner = 'false';
    items = [];
    rows = [];
    columns = [];

    get isActivity(){
        return this.type === 'activity';
    }
    get isPath(){
        return this.type === 'path';
    }
    get isTable(){
        return this.type === 'table';
    }
    get isList(){
        return this.type === 'list';
    }
    get showSpinner(){
        return this.spinner === 'true';
    }
    connectedCallback(){
        this.items = Array.from(Array(5).keys());
        this.rows = Array.from(Array(10).keys());
    }
}