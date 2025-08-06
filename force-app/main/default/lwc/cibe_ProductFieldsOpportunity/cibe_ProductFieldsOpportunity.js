import { LightningElement, track, api, wire } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';

//Methods
import getFields 		from '@salesforce/apex/Cibe_ProductFieldsOpportunity_Controller.getProductFieldsNewOppo';
import importe          from '@salesforce/label/c.CIBE_Importe';
import numeroUnidades   from '@salesforce/label/c.CIBE_N_Unidades';
export default class Cibe_ProductFieldsOpportunity extends NavigationMixin (LightningElement) {

    @api producto;
    @api importesaldo;
    @api numerounidades;
    @track listFields;
    @track returnValue;
    @track isImporte = false;
    @track isNUni= false;
    @track isImporteREQ = false;
    @track isNUniREQ= false;


    labels = {
        importe,
        numeroUnidades
    }

    connectedCallback(){
        this.getFields();
    }

    getFields(){
        getFields({idProduct: this.producto})
            .then(result => {
                this.listFields=result;
                Object.keys(result).forEach(key => {
                    if(this.listFields[key].name === 'importeSaldo'){
                        this.isImporte = true;
                        if(this.listFields[key].required){
                            this.isImporteREQ = true;
                        }
                    }
                    if(this.listFields[key].name === 'numeroUnidades'){
                        this.isNUni = true;
                        if(this.listFields[key].required){
                            this.isNUniREQ = true;
                        }
                    }
                });
            })
            .catch(error => {
                console.log(error);
        });
    }

    handleChange(event){
        this.sendData(event);
    }

    sendData(event) {
        if(event.target.name == 'importeSaldo' && this.importesaldo != event.target.value){
            this.importesaldo = event.target.value;
        }
        if(event.target.name == 'numeroUnidades'  && this.numerounidades != event.target.value){
            this.numerounidades = event.target.value;
        }
        const returnValue = {
            detail : {},
            req : {}
        };

        if(event.target.name) {
            returnValue.detail[event.target.name] = event.target.value;
            returnValue.req[event.target.name] = event.target.required;
            this.dispatchEvent(new CustomEvent('datareport', returnValue));
        }
    }

    get hasFields() {
        return this.listFields && this.listFields.length > 0;
    }

    get hasOne() {
        return this.listFields && this.listFields.length > 1;
    }

}