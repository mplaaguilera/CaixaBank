import { LightningElement,wire,api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { getRecord } from 'lightning/uiRecordApi';
import getReportId  from '@salesforce/apex/GRR_Obtener_Informe_Controller.getReportId';
 import CARGA_ID from '@salesforce/schema/GRR_Carga__c.Id';
const FIELDS_CARGA = [CARGA_ID];
export default class grr_Obtener_Informe extends NavigationMixin(LightningElement) {
  @api recordId;
  reportId;
  error;

  @wire(getRecord, { recordId: '$recordId', fields: FIELDS_CARGA })
    wiredCarga({ error, data }) {
        
        if (data) {
            this.carga = data; 
            
        } else if (error) {
            console.log('Error en wiredCarga:', error);
        }
    }

   @wire(getReportId)
   report({data,error}){
     if(data){
       this.reportId=data;
     }
     else if(error){
     this.error=error;
     }
  }
  
  redirectToReport(evt) {
        evt.preventDefault();
        evt.stopPropagation();
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: this.reportId,
                objectApiName: 'Report',
                actionName: 'view'
            },
            state: {
                fv0:this.recordId

            }
        });
    }
    
}