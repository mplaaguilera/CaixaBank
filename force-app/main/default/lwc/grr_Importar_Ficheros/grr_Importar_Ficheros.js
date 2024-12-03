import { LightningElement,wire,api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { getRecord } from 'lightning/uiRecordApi';
import getUrlImport  from '@salesforce/apex/GRR_Importar_Ficheros_Controller.getUrlImport';  
import CARGA_ID from '@salesforce/schema/GRR_Carga__c.Id';
import CARGA_TIPO_FICHERO from '@salesforce/schema/GRR_Carga__c.GRR_TipoDeFichero__c';
const FIELDS_CARGA = [CARGA_ID, CARGA_TIPO_FICHERO]; 
export default class grr_Importar_Ficheros extends NavigationMixin(LightningElement) {
  @api recordId;
  error;
  tipo;

  @wire(getRecord, { recordId: '$recordId', fields: FIELDS_CARGA })
    wiredCarga({ error, data }) {
        
        if (data) { 
            this.tipo=data.fields.GRR_TipoDeFichero__c.value;
        } else if (error) {
            console.log('Error en wiredCarga:', error);
        }
    }

    navigateToWebPage() {

        getUrlImport({ tipoObjeto: this.tipo})
            .then(result => {
                this.urlImport=result;
                window.open(result, '_blank');
                
                
                
            }).catch(error => {
                console.error('Error en el proceso de importación:', error);
                this.mostrarToast('Error', 'Error en el proceso de importación', error.body.message);
            });
        
      }
    
}