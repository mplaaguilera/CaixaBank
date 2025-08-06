import { LightningElement, api, wire, track  } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
//import { refreshApex } from '@salesforce/apex';

//Campos
import CONNID_FIELD from '@salesforce/schema/CC_Llamada__c.CC_ConnId__c';
import CUENTA_FIELD from '@salesforce/schema/CC_Llamada__c.CC_Cuenta__c';
import ID_FIELD from '@salesforce/schema/CC_Llamada__c.Id';

//Métodos
import recuperarDatos from '@salesforce/apex/CC_LCMP_conversationUnit.comprobarDatos';

const fields = [ID_FIELD, CONNID_FIELD, CUENTA_FIELD];

export default class Cc_conversationUnitList extends LightningElement {

    @api recordId;
    @api spinnerLoading = false;
    @api hayDatos = false;
    @track conversaciones = [];
    error;

    @wire(getRecord, { recordId: '$recordId', fields })
    llama;

    get idCogLlamada() {
        return getFieldValue(this.llama.data, CONNID_FIELD);
    }
    get cuentaLlamada() {
        return getFieldValue(this.llama.data, CUENTA_FIELD);
    }
    get idLlamada(){
        return getFieldValue(this.llama.data, ID_FIELD);
    }


    _wiredResult; //Variable para recoger el resultado del metodo wired recuperarDatos


    connectedCallback(){
        recuperarDatos({llamadaId: this.recordId })
        .then(result => {
            this._wiredResult = result;
            this.hayDatos = true;
            result.forEach(conver => {
                conver.padreConver.CC_Feedback__c = conver.picklistFeedback;
                var startDate = new Date(conver.padreConver.CC_FechaInicio__c);
                var dateLabel = 'Conversación del ' + startDate.getDate().toString() + '/' + (startDate.getMonth()+1).toString() + '/' + startDate.getFullYear().toString() + ' a las ' + startDate.getHours().toString().padStart(2,'0') + ':' + startDate.getMinutes().toString().padStart(2,'0') + ':' + startDate.getSeconds().toString().padStart(2,'0');
                conver.padreConver.label = dateLabel;
                this.conversaciones.push(conver);
            });
            
        })
        .catch(error => { 
            this.hayDatos = false;
            this.spinnerLoading = false;
        });
    }

    /*recuperarClick(){
        this.spinnerLoading = true;
        this.dispatchEvent(new ShowToastEvent({
            title: 'Tabla refrescada',
            message: 'Los datos han sido actualizados',
            variant: 'success',
        }),);
        recuperarDatos({llamadaId: this.recordId })
        .then(result => {
            this.hayDatos = true;
            this.conversaciones = [];
            this._wiredResult = result;
            result.forEach(conver => {
                conver.padreConver.CC_Feedback__c = conver.picklistFeedback;
                this.conversaciones.push(conver);
                this.spinnerLoading = false; 
            });
        })
        .catch(error => { 
            this.hayDatos = false;
            this.spinnerLoading = false;
        });
    }*/
}