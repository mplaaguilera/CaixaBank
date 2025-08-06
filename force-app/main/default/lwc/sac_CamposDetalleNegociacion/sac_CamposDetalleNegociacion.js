import { LightningElement, track, wire, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getRecord, getFieldValue} from 'lightning/uiRecordApi';
import { RefreshEvent } from 'lightning/refresh';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';

//Campos reclamación
import NEGOCIACION_FINALIZADA_FIELD from '@salesforce/schema/Case.SAC_NegociacionFinalizada__c';
import RESULTADO_NEGOCIACION_FIELD from '@salesforce/schema/Case.SAC_ResultadoNegociacion__c';
import RECLAMANTE_CONFORME_NEGOCIACION_FIELD from '@salesforce/schema/Case.SAC_ReclamanteConformeNegociacion__c';
import ANTECEDENTES_REVISADOS_NEGOCIACION_FIELD from '@salesforce/schema/Case.SAC_Antecedentes_Revisados_Negociacion__c';

//Llamadas Apex
import getNegociacionesPretension from '@salesforce/apex/SAC_LCMP_CamposDetalleNegociacion.getNegociacionesPretension';

const fields = [ NEGOCIACION_FINALIZADA_FIELD, RESULTADO_NEGOCIACION_FIELD, RECLAMANTE_CONFORME_NEGOCIACION_FIELD, ANTECEDENTES_REVISADOS_NEGOCIACION_FIELD
];

export default class Sac_CamposDetalleNegociacion extends LightningElement {
    @api recordId;
    @api objectApiName;
    @track listPretensionesNegociacion = [];
    @track mostrarNegociaciones = false;

    //Controlar Desplegable: Negociación
    @track toggleSeccionPretensiones = "slds-section slds-is-open cuerpo-subseccion";

    @wire (getNegociacionesPretension, {'casoId': '$recordId'})
    wiredNegociaciones({data, error}){
        if(data){
            this.listPretensionesNegociacion = data;
            this.mostrarNegociaciones = true;
        }
    }

    handleExpandirPretension(event){
        let buttonid = event.currentTarget.dataset.name;
        
        let currentsection = this.template.querySelector('[data-id="' + buttonid + '"]');
        if (currentsection.className.search('slds-is-open') == -1) {
            currentsection.className = 'slds-section slds-is-open cuerpo-subseccion';
        } else {
            currentsection.className = 'slds-section cuerpo-subseccion';
        }
    }
}