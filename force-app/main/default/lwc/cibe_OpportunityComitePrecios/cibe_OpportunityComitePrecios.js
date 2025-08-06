import { LightningElement, api, track, wire } from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';
import { NavigationMixin } from "lightning/navigation";
// Fields
import TIPO_SIMULA_OPP from '@salesforce/schema/Opportunity.CIBE_Tipo_de_simulacion__c';
import NUMBER_SIMULA_OPP from '@salesforce/schema/Opportunity.CIBE_Numero_de_Simulador__c';

// Methods
import getUrl  from '@salesforce/apex/CIBE_OpportunityComitePrecios.getUrl';

//Labels 
import accesoInforme from '@salesforce/label/c.CIBE_AccesoInforme';

export default class cibe_OpportunityComitePrecios extends NavigationMixin(LightningElement) {

    @api recordId;
    @api apiNameField; 

    @track tipoSimula = null;
    @track nSimula = null;
    @track ref_ext = null;
    @track url;
    buttonActive = false;

    labels = {
        accesoInforme
    }
    @wire(getRecord, { recordId: '$recordId', fields: [TIPO_SIMULA_OPP] })
    getInformePrecios({ error, data }){
        console.log('getInformePrecios - buttonDisabled: ' +this.buttonDisabled);
        if(data ){
            if(data.fields.CIBE_Tipo_de_simulacion__c.value =='Empresa'){
                this.tipoSimula ='SC';
                this.setButtonVisibility();
            }
            else if(data.fields.CIBE_Tipo_de_simulacion__c.value =='Grupo'){
                this.tipoSimula ='SG';
                this.setButtonVisibility();
            }
            console.log('tipoSimula: ' +this.tipoSimula);
        } else if(error){
            console.log(error);
        }
    }

    @wire(getRecord, { recordId: '$recordId', fields: [NUMBER_SIMULA_OPP] })
    getInformePreciosC({ error, data }){
        console.log('getInformePreciosC - buttonDisabled: ' +this.buttonDisabled);
        if(data){
            this.nSimula = data.fields.CIBE_Numero_de_Simulador__c.value;
            this.ref_ext = this.tipoSimula+this.nSimula;
            console.log('getInformePreciosC - ref_ext: ' +this.ref_ext);

        } else if(error){
            console.log(error);
        }
    }

        @wire(getUrl, { ref_ext: '$ref_ext' })
    getUrlInforme({ error, data }){
        console.log('ref_ext: ' +this.ref_ext);
        if(data){
            this.url = data;
        } else if(error){
            console.log(error);
        }
    }

    setButtonVisibility() {
        this.buttonActive = true;
    }

}