import { LightningElement, api, track, wire } from 'lwc';
import { NavigationMixin, CurrentPageReference } from 'lightning/navigation';
import getData from '@salesforce/apex/SIR_LCMP_HomeSolutions.getData';
import getURL from '@salesforce/apex/SIR_LCMP_HomeSolutions.getURL';
import {refreshApex} from '@salesforce/apex';

export default class Sir_lwc_HomeSolutions extends NavigationMixin(LightningElement) {

    @api tiposProcesosName;
    @track title;
    @track numRecords;
    @track loading = false;

    @track wiredResult = [];
    @track wiredCurrentPageReference = [];

    @api
    retrieveCharts() {
        refreshApex(this.wiredResult);
    }

    @wire(getData, {
        tiposProcesos : '$tiposProcesosName'
    })wiredData(result) {
        this.wiredResult = result;
        this.loading = true;
        if(result.data){             
            for(var key in result.data){
                if(key == this.tiposProcesosName){
                    this.title = key;
                    this.numRecords = result.data[key];
                    this.template.querySelector('article').classList.add('cursor-link');
                    this.template.querySelector('span').classList.remove('cursor-default');
                }
            } 
            this.loading = false;      
        }
    }

    @wire(CurrentPageReference)
    setCurrentPageReference(currentPageReference) {
        refreshApex(this.wiredResult);
    }

    goToHome(){
        getURL({proceso: this.tiposProcesosName}).then(result => {            
            this[NavigationMixin.Navigate]({
                type: 'standard__webPage',
                attributes: {
                    url: result
                }
            });
        });
    }    
}