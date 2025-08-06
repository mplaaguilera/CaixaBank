import { LightningElement,api,wire } from 'lwc';
import { CurrentPageReference  } from 'lightning/navigation';
import { ShowToastEvent }   from 'lightning/platformShowToastEvent';
import { updateRecord,getRecord } from 'lightning/uiRecordApi';
import { CloseActionScreenEvent } from 'lightning/actions';

import FECHA_PROX_GEST from '@salesforce/schema/Opportunity.AV_FechaProximoRecordatorio__c';
import FECHA_CIERRE from '@salesforce/schema/Opportunity.CloseDate';
import FECHA_ACTIVACION from '@salesforce/schema/Opportunity.AV_FechaActivacion__c';
import PRIORIZADO from '@salesforce/schema/Opportunity.AV_IncludeInPrioritizingCustomers__c';
import STAGE from '@salesforce/schema/Opportunity.StageName';
import ID_FIELD from '@salesforce/schema/Opportunity.Id';
import ORIGENAPP from '@salesforce/schema/Opportunity.AV_OrigenApp__c';

import openStageLabel from '@salesforce/label/c.AV_GESTIONINSISTIR';
import reportApp from '@salesforce/label/c.AV_SalesForceOrigenApp';
import reactivateOppo from '@salesforce/label/c.AV_ReactivateOppo';
import reactivateOppo2 from '@salesforce/label/c.AV_ReactivateOppo2';
import InManagementInsist from '@salesforce/label/c.AV_InManagementInsist';
import includeOppo from '@salesforce/label/c.AV_IncludeOppo';

export default class Av_ReactivateOppo extends LightningElement {
    @api recordId;
    @api objectApiName;
    emptyDate=true;
    dateToSend=null;
    priorizador = true;
    loading = false;
    hasActivationDate=false;
    label={reactivateOppo,reactivateOppo2,InManagementInsist,includeOppo};

    @wire(CurrentPageReference)
	setCurrentPageReference(currentPageReference) {
		this.currentPageReference = currentPageReference;
	}
/**
 * Miramos el valor de AV_FechaActivación para saber si hay que llenarlo o no. (Se llena si está vacío.)
 */
@wire(getRecord, { recordId: '$recordId', fields: [FECHA_ACTIVACION] })
wiredOpportunity({data}) {
    if(data){
        let fecha = data.fields.AV_FechaActivacion__c.value;
        if(fecha){
            this.hasActivationDate = true;
        }
    }
}

    connectedCallback(){
        this.recordId = this.currentPageReference.state.recordId;
    }

   handleSuccess(e) {
    this.loading = true;
    const fields = {};
    //LLenamos el objeto con los campos que vamos a actualizar
    fields[ID_FIELD.fieldApiName] = this.recordId;
    fields[FECHA_PROX_GEST.fieldApiName] = this.dateToSend;
    // fields[FECHA_CIERRE.fieldApiName] = this.dateToSend;
    fields[PRIORIZADO.fieldApiName] = this.priorizador;
    fields[ORIGENAPP.fieldApiName] = reportApp;
    if(!this.hasActivationDate) {
        let today = new Date();
        today = today.toISOString().substring(0, 10);
        fields[FECHA_ACTIVACION.fieldApiName] = today;
    }
    fields[STAGE.fieldApiName] = openStageLabel;
    const updatedFields = { fields }; 
    updateRecord(updatedFields).then(() =>{     
        this.showExitToast(); 
    }).catch(error =>{
      this.showErrorToast(error);
    })
}

showExitToast(){
    this.loading=false;
    this.closeModalWindow();
    this.dispatchEvent(
        new ShowToastEvent({
            title: 'Oportunidad reactivada correctamente',
            message: 'Fecha próxima gestión: '+this.dateToSend,
            variant: 'success'
        })
    );

}

showErrorToast(error){
    this.loading=false;
    if(error==null){
        this.closeModalWindow();
    } 
    let msg = (error!= null)?error:'Error desconocido. Consulta con tu administrador';
    this.dispatchEvent(
        new ShowToastEvent({
            title: 'Para reactivar la oportunidad debe seleccionar una fecha a futuro',
            message: msg,
            variant: 'error'
        })
    );
}

closeModalWindow(){
    this.dispatchEvent(new CloseActionScreenEvent());
}
/*handleChangeDate(e){
    if(e.target.value!=null){
        this.emptyDate=false;
        this.dateToSend=e.target.value;
    }else{
        this.emptyDate=true;
    }
}*/

handleChangeDate(e){
    if(e.target.value!=null){
        var today = new Date();
        var yesterday = new Date(today.setDate(today.getDate()-1));
        var fecha = new Date(e.target.value);
        if (fecha >= yesterday) {
        this.emptyDate=false;
        this.dateToSend=e.target.value;
        // var fecha = today.getFullYear() + '-' + today.getMonth() + '-' + today.getDate();
        // console.log('e',e.target.value);
        // console.log('fecha',fecha);
        // console.log('validar booleano '+ (e.target.value>=new Date()))
        // var newDate = new Date(e.target.value);
        // console.log('newDate',newDate);
        // var newDateFormatted = newDate.getFullYear() + '-' + newDate.getMonth() + '-' + newDate.getDate();
        // console.log('newDateFormatted >= fecha',newDateFormatted >= fecha);
        // // if (newDateFormatted >= fecha) {
        }else{
            this.emptyDate=true;
            this.showErrorToast('');
        }
    }else{
        this.emptyDate=true;
    }
}

handleIncluir(){
    this.priorizador = (this.priorizador)?false:true;
}
}