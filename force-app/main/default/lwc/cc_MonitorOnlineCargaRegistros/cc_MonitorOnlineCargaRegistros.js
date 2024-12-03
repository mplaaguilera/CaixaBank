import { LightningElement, track, api } from 'lwc';
import saveFile from '@salesforce/apex/CC_MonitorOnline_Carga.saveFile';
import {ShowToastEvent} from 'lightning/platformShowToastEvent';
import { CloseActionScreenEvent } from 'lightning/actions';

const columns = [
    { label: 'Fecha', fieldName: 'CC_Fecha__c' },
    { label: 'Proveedor', fieldName: 'CC_Proveedor__c' },
    { label: 'Hora 00', fieldName: 'CC_00__c' },
    { label: 'Hora 01', fieldName: 'CC_01__c' },
    { label: 'Hora 02', fieldName: 'CC_02__c' },
    { label: 'Hora 03', fieldName: 'CC_03__c' },
    { label: 'Hora 04', fieldName: 'CC_04__c' },
    { label: 'Hora 05', fieldName: 'CC_05__c' },
    { label: 'Hora 06', fieldName: 'CC_06__c' },
    { label: 'Hora 07', fieldName: 'CC_07__c' },
    { label: 'Hora 08', fieldName: 'CC_08__c' },
    { label: 'Hora 09', fieldName: 'CC_09__c' },
    { label: 'Hora 10', fieldName: 'CC_10__c' },
    { label: 'Hora 11', fieldName: 'CC_11__c' },
    { label: 'Hora 12', fieldName: 'CC_12__c' },
    { label: 'Hora 13', fieldName: 'CC_13__c' },
    { label: 'Hora 14', fieldName: 'CC_14__c' },
    { label: 'Hora 15', fieldName: 'CC_15__c' },
    { label: 'Hora 16', fieldName: 'CC_16__c' },
    { label: 'Hora 17', fieldName: 'CC_17__c' },
    { label: 'Hora 18', fieldName: 'CC_18__c' },
    { label: 'Hora 19', fieldName: 'CC_19__c' },
    { label: 'Hora 20', fieldName: 'CC_20__c' },
    { label: 'Hora 21', fieldName: 'CC_21__c' },
    { label: 'Hora 22', fieldName: 'CC_22__c' },
    { label: 'Hora 23', fieldName: 'CC_23__c' },
    // { label: 'Tipo de previsión', fieldName: 'CC_TipoDePrevisiones__c' },
    { label: 'Tipo de registro', fieldName: 'RecordTypeId' },
    { label: 'Servicio', fieldName: 'CC_Servicio__c' }
];

export default class Cc_MonitorOnlineCargaRegistros extends LightningElement
{
   @api recordid;
   @track columns = columns;
   @track data;
   @track fileName = '';
   @track UploadFile = 'Cargar archivo CSV';
   @track showLoadingSpinner = false;
   @track isTrue = false;

   selectedRecords;
   filesUploaded = [];
   file;
   fileContents;
   fileReader;
   content;
   MAX_FILE_SIZE = 1500000; 

   handleFilesChange(event){
       if(event.target.files.length > 0){
           this.filesUploaded = event.target.files;
           this.fileName = event.target.files[0].name;
       }
   }

   handleSave(){
       if(this.filesUploaded.length > 0){
           this.uploadHelper();
       } else {
           this.fileName = 'Por favor selecciona un archivo CSV para cargar.'; 
       }
   }

   uploadHelper(){
    this.file = this.filesUploaded[0];

    if (this.file.size > this.MAX_FILE_SIZE)
    {
        window.console.log('El tamaño del archivo excede el límite');
        return;
    }

    this.showLoadingSpinner = true;
    this.fileReader= new FileReader();
    this.fileReader.onloadend = (() =>
    {
        this.fileContents = this.fileReader.result;
        this.saveToFile();
    });
    this.fileReader.readAsText(this.file);
   }

   saveToFile(){
       saveFile({ base64Data: JSON.stringify(this.fileContents), cdbId: this.recordid})
       .then(result =>
        {
           this.data = result;
           this.fileName = this.fileName + ' - cargado correctamente';
           this.isTrue = false;
           this.showLoadingSpinner = false;

           this.dispatchEvent(
               new ShowToastEvent({
                   title: 'Cargado correctamente',
                   message: this.file.name + ' - cargado correctamente',
                   variant: 'success'
               }),
           );
       })
       .catch(error => {
           window.console.log(error);
           this.showLoadingSpinner = false;
           this.dispatchEvent(
               new ShowToastEvent({
                   title: 'Error al cargar el archivo',
                   message: error.message,
                   variant: 'error'
               }),
           );
       });
   }
   
    closeQuickAction(){
        this.dispatchEvent(new CloseActionScreenEvent());
    }
}