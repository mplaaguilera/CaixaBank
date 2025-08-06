import { LightningElement, api, wire, track } from 'lwc';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import generarFAQSRelevantes from '@salesforce/apex/CC_IA_FAQSRelevantes_Controller.generarFAQSRelevantes';
import { NavigationMixin } from 'lightning/navigation';
import CANAL_PROCEDENCIA_FIELD from '@salesforce/schema/Case.CC_Canal_Procedencia__c';



export default class CC_IA_FAQSRelevantes extends NavigationMixin(LightningElement) {
    @api recordId; // Asegúrate de tener el recordId si es necesario
    @track relevantes; // Variable para almacenar el texto de la respuesta
    @track error; // Variable para almacenar posibles errores
    @track isLoadingOpp;
    @track sinDatos;
    error;
    showSpinner = false;
    a_Record_URL;
    info;
    caseRecord;
    canalProcedencia;

    @wire(getRecord, { recordId: '$recordId', fields: [CANAL_PROCEDENCIA_FIELD] })
    wiredRecord({ error, data }) {
      if (data) {
        this.canalProcedencia = getFieldValue(data, CANAL_PROCEDENCIA_FIELD);
        this.obtenerFAQSRelevantes();
      } else if (error) {
        console.error(error);
        this.notifyUser('Error', 'Problema obteniendo los datos del caso' + error.body.message, 'error');

      }
    }
    // Llamar al método de Apex
    connectedCallback() {
      this.sinDatos = false;
      this.isLoadingOpp = true;
    //this.obtenerFAQSRelevantes();
    
    }

    obtenerFAQSRelevantes() {
      //const canalProcedencia = getFieldValue(this.caseRecord.data, CANAL_PROCEDENCIA_FIELD); 
        generarFAQSRelevantes({ caseId: this.recordId, canalProcedencia: this.canalProcedencia })
            .then(response => {
              const datos = JSON.parse(response);
              this.relevantes = datos.Cases.map(caso => ({
                id: caso.ID,
                titulo: caso.Titulo,
                Fragmento: caso.Fragmento,
                url: window.location.origin + '/' +  caso.ID 
              })
            )
            console.log('@@Respuesta nula' ,datos.Cases[0].Titulo);
            if(datos.Cases[0].Titulo=='No se han encontrado artículos relacionados'){
              this.sinDatos = true;  
            };
            this.isLoadingOpp = false;
            })
            .catch(error => {
                this.error = error; // Manejar el error
                this.isLoadingOpp = false;
                this.sinDatos = true;     
            });
    }

    handleOpenTab(event) {
      const url = event.target.dataset.url;
        if (url) {
          this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
              attributes: {
              recordId: url,
              objectApiName:'Case',
              actionName:'view'
              },
            state: {
             navigationLocation: 'LIST_VIEW'
             }
              });
            }
  }
  notifyUser(title, message, variant) {
    const toastEvent = new ShowToastEvent({ title, message, variant });
    this.dispatchEvent(toastEvent);
  }
}