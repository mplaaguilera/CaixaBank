import { LightningElement, api, wire, track } from 'lwc';
import { RefreshEvent } from 'lightning/refresh';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import CASO_OBJECT from '@salesforce/schema/Case'; 


const fields = [
    'Case.Status',
    'Case.SAC_TipoConsumidor__c'
];

export default class Sac_ComprobarConsumidor extends LightningElement {

    @track mostrarAviso = false;
    @api recordId;


    @wire (getObjectInfo, {objectApiName: CASO_OBJECT})
    objectInfo;

    @wire(getRecord, {recordId: '$recordId', fields})
    actualCase({data, error}){
        if(data){
            this.existenDatos = data;
            this.mostrarAviso = true;
            /*if(this.existenDatos.fields.Status.value === 'SAC_001' || this.existenDatos.fields.Status.value === 'SAC_002'){
                console.log('muestra aviso');
                this.mostrarAviso = true;
            }else{
                this.mostrarAviso = false;
            }*/
        }
            
    };



}