import { LightningElement, track, wire, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getRecord, getFieldValue} from 'lightning/uiRecordApi';
import { RefreshEvent } from 'lightning/refresh';
import { NavigationMixin } from 'lightning/navigation';

//Llamadas Apex
import getPretensiones from '@salesforce/apex/SPV_LCMP_CamposNegociacion.getPretensiones';


export default class Spv_CamposNegociacionReclamacion extends NavigationMixin(LightningElement) {
    @api recordId;
    @api objectApiName;
    @track pretensiones = [];
    @track idPretensionView;



    @wire(getPretensiones, { casoId: '$recordId'})
    getPretensiones({ error, data }){
        if(data){
            this.pretensiones = data;
        }
    } 


    //Al pulsar sobre un id de pretensión, te lleva a ella
    verPretensionClick(event){
        console.log('entra ' + event.currentTarget.name);
        this.idPretensionView = event.currentTarget.name;
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                "objectApiName": "Case",
                "recordId": this.idPretensionView,
                "actionName": "view"
            }
        });
    }



}