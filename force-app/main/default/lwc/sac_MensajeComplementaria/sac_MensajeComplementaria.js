import { LightningElement, wire, api, track } from 'lwc';
import { RefreshEvent } from 'lightning/refresh';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getReclamacionVinculada from '@salesforce/apex/SAC_LCMP_MensajeComplementaria.getReclamacionVinculada';
import { NavigationMixin } from 'lightning/navigation'; 
import { getRecord, getRecordNotifyChange } from 'lightning/uiRecordApi';
import { refreshApex } from '@salesforce/apex';
import { updateRecord } from 'lightning/uiRecordApi';

const fields = [
    'Case.SAC_Naturaleza__c',
    'Case.CC_CasoRelacionado__c'
];


export default class Sac_MensajeComplementaria extends LightningElement {

    @api recordId;    
    @api caseId;

    @track esComplementaria = false;
    @track tieneReclamacionVinculada;
    @track reclamacionCaseNumber;
    @track datosCargados = false;
    existenDatos;
    naturaleza;


    @wire(getRecord, {recordId: '$recordId', fields})
    actualCase({data, error}){
         if(data) {
            this.existenDatos = data;
            this.naturaleza = this.existenDatos.fields.SAC_Naturaleza__c.value;
            if(this.naturaleza == 'SAC_007'){
                this.esComplementaria = true;
            }else{
                this.esComplementaria = false;
            }

            if(this.existenDatos.fields.CC_CasoRelacionado__c.value != null){
                getReclamacionVinculada({idReclamacionVinculada: this.existenDatos.fields.CC_CasoRelacionado__c.value}).then(result =>{
                    if(result != null){
                        this.tieneReclamacionVinculada = true;
                        this.reclamacionCaseNumber = result.CaseNumber;
                    }else{
                        this.tieneReclamacionVinculada = false;
                    }
                    this.datosCargados = true;
                })
                .catch(error => {        
                    this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Fallo al recuperar la reclamación vinculada.',
                        message: error.body.message,
                        variant: 'error'
                    }),);
    
                })
            }else{
                this.tieneReclamacionVinculada = false;
                this.datosCargados = true; //Se puede mostrar el mensaje de no hay vinculación para la complementaria
            }
        }     
    };


}