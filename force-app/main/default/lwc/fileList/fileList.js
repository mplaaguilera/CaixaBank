import { LightningElement, wire, api, track } from "lwc";
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import { RefreshEvent } from 'lightning/refresh';
import getRelatedFiles from "@salesforce/apex/SEG_FileController.getFilesList";
import getFileVersionDetails from "@salesforce/apex/SEG_FileController.getFileVersionDetails";
import createContentDocLink from "@salesforce/apex/SEG_FileController.createContentDocLink";
import uploadFileModify from "@salesforce/apex/SEG_FileController.uploadFileModify";
import deleteUploadedFile from "@salesforce/apex/SEG_FileController.deleteUploadedFile";
import deleteFiles from "@salesforce/apex/SEG_FileController.deleteFiles";
import { deleteRecord, createRecord, updateRecord } from "lightning/uiRecordApi";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import { refreshApex } from "@salesforce/apex";
import DESCRIPTION_FIELD from '@salesforce/schema/ContentVersion.Description';
import SEG_FIRMADO__C_FIELD from '@salesforce/schema/ContentVersion.SEG_Firmado__c';
import SEG_GDD__C_FIELD from '@salesforce/schema/ContentVersion.SEG_GDD__c';
import ID_FIELD from '@salesforce/schema/ContentVersion.Id';
import CONTENTDOCUMENTID_FIELD from '@salesforce/schema/ContentDocumentLink.Id';

import { NavigationMixin } from 'lightning/navigation';

const actions = [
  { label: "Historial de versiones", name: "show_details" },
  { label: "Subir nueva versión", name: "upload_version" },
  { label: "Eliminar archivo", name: "delete" }
];

const BASE64EXP = new RegExp(/^data(.*)base64,/);
const columns = [
  {
    label: "Archivo",
    fieldName: "id",
    type: "filePreview",
    initialWidth: 150,
    typeAttributes: {
      anchorText: { fieldName: "title" },
      versionId: { fieldName: "latestVersionId" }
    }
  },
  { label: "Subido por", fieldName: "createdBy", type: "string", initialWidth: 150 },
  { label: "Fecha de subida", fieldName: "createdDate", type: "date", typeAttributes:{
                                                                        month: 'numeric',
                                                                        day: 'numeric',
                                                                        year: 'numeric',
                                                                        hour:'2-digit' ,
                                                                        minute:'2-digit',
                                                                        second: '2-digit', 
                                                                        timeZone:'Europe/Paris'
                                                                      }, initialWidth: 150 },
  { label: "Descripción", fieldName: "description", type: "string", editable: true, initialWidth: 150 },
  { label: "Firmado", fieldName: "firmado", type: "boolean", editable: true, initialWidth: 150 },
  { label: "Id de versión", fieldName: "latestVersionId", type: "String", initialWidth: 150 },
  { label: "GDD", fieldName: "gdd", type: "string", editable: true, initialWidth: 150},
  { label: "Tamaño", fieldName: "contentSize", type: "integer", initialWidth: 150},
  { type: "action", typeAttributes: { rowActions: actions } }
];

const versionColumns = [
  {
    label: "Descargar",
    fieldName: "id",
    type: "filePreview",
    typeAttributes: {
      anchorText: "Download⇣"
    }
  },
  { label: "Título", fieldName: "title", type: "string" },
  { label: "Razón para el cambio", fieldName: "reasonForChange", type: "string" },
  { label: "Subido por", fieldName: "createdBy", type: "string" },
  { label: "Fecha de subida", fieldName: "createdDate", type: "date", typeAttributes:{
                                                                        month: 'numeric',
                                                                        day: 'numeric',
                                                                        year: 'numeric',
                                                                        hour:'2-digit' ,
                                                                        minute:'2-digit',
                                                                        second: '2-digit',
                                                                        timeZone:'Europe/Paris'
                                                                      } },
  { label: "Descripción", fieldName: "description", type: "string" },
  { label: "Firmado", fieldName: "firmado", type: "boolean" },
  { label: "GDD", fieldName: "gdd", type: "string"},
  { label: "Tamaño", fieldName: "contentSize", type: "integer"},
];

const FIELDS = ['Case.Status'];

//export default class FileList extends LightningElement {
  export default class FileList extends NavigationMixin(LightningElement) {
  @api
  recordId;
  case;
  status;
  cerrado;
  _filesList;
  fileTitle;
  fileName;
  fileDescr;
  fileDescription;
  fileFirmado;
  fileGDDPlace;
  fileGDD;
  fileFirm;
  files = [];
  @api uploadedFileData;
  /*this.showAttachFields = false;
  this.attachmentReady = false;
  this.uploadedFileData = null;*/
  columns = columns;
  versionColumns = versionColumns;
  versionDetails = [];
  fileUpload = false;
  @api attachmentReady = false;
  @api showAttachFields = false;
  _currentDocId = null;
  showPreview = false;
  currentPreviewFileId = null;
  showSpinner = false;
  @api valor = 'test';
  @api acceptedFileFormats;
  @api fileUploaded;
  title;
  @track initialized = false;
  @track newFile = false;
  @track refreshTable = [];
  @track draftValues = [];
  @track saveDraftValues = [];

  // Crear e inicializar objeto para guardar la personalización de la tabla
  tablePersonalization;

  // Guardar la personalización en localStorage al redimensionar columnas de la tabla
  handleColumnResize(event) {
    if (event.detail.isUserTriggered) {
      let columnSizes = {};
      event.detail.columnWidths.forEach((columnWidth, index) => {
        columnSizes[columns[index].label] = columnWidth;
      });
      this.tablePersonalization = columnSizes;
      localStorage.setItem('tablePersonalization', JSON.stringify(this.tablePersonalization));
    }
  }
  
  // Cargar la personalización desde localStorage
  handleLoadColumnSizes() {
    const storedPersonalization = localStorage.getItem('tablePersonalization');
    if (storedPersonalization) {
      this.tablePersonalization = JSON.parse(storedPersonalization);
      // Establecer los tamaños de las columnas según la personalización cargada
      this.columns.forEach((column, index) => {
        if (this.tablePersonalization[column.label]) {
          column.initialWidth = this.tablePersonalization[column.label];
        }
      });
    }
  }

  // El connectedCallback se ejecuta al refrescar la página
  connectedCallback() {
    this.handleLoadColumnSizes();
  }

  handleFileNameChange(event) {
    this.fileTitle = event.detail.value;
  }
  handleFileDescriptionChange(event) {
    this.fileDescr = event.detail.value;
  }
  handleFileFirmadoChange(event) {
    this.fileFirm = event.detail.checked;
  }
  handleFileGDDChange(event) {
    this.fileGDD = event.detail.value;
  }
	/*get acceptedFormats() {
		return ['.pdf', '.png','.jpg','.jpeg','.docx'];
	}*/
  get accionesDisabled() {
		return !this.attachmentReady || !this.fileTitle;
	}
  get mostrarCampos() {
    return this.showAttachFields;
  }
  get desactivarUpload(){
    return this.uploadedFileData;
  }
 

  /*handleFileChange() {
    const inpFiles = this.template.querySelector("input.file").files;
    if (inpFiles && inpFiles.length > 0) {
      this.fileName = inpFiles[0].name;
      this.fileDescription = inpFiles[0].Description;
      this.fileFirmado = inpFiles[0].SEG_Firmado__c;
      this.fileGDDPlace = inpFiles[0].SEG_GDD__c;
    }
  }*/

  @wire(getRelatedFiles, { recordId: "$recordId" })
  getFilesList(filesList) {
    this._filesList = filesList;
    const { error, data } = filesList;
    if (!error && data) {
      this.files = data;
    }
  }

  @wire( getRecord, { recordId: '$recordId', fields: FIELDS } )
  wiredRecord({ error, data }) {

      if ( error ) {
          let message = 'Unknown error';
          if (Array.isArray(error.body)) {
              message = error.body.map(e => e.message).join(', ');
          } else if (typeof error.body.message === 'string') {
              message = error.body.message;
          }

      } else if ( data ) {

          this.case = data;
          this.status = this.case.fields.Status.value;
          if(this.status == 'Cerrado')
          {
            this.cerrado = true;
          }
      }
  }

  closeModal() {
    if (this.attachmentReady == true){
      deleteUploadedFile({versionArchivo: this.uploadedFileData.documentId})
      .then(() => {
        refreshApex(this._filesList);
      })
      .catch(error => {
        console.error(JSON.stringify(error));
      })
      .finally(() =>{
        this.newFile = false;
        this._currentDocId = null;
        this.fileUpload = false;
        this.versionDetails = [];
        this.fileName = "";
        this.fileTitle = "";
        this.fileDescr = "";
        this.fileDescription = "";
        this.fileFirm = false;
        this.fileFirmado = false;
        this.showAttachFields = false;
        this.attachmentReady = false;
        this.uploadedFileData = null;
        if (this.dialag) {
          this.dialag.closeModal();
        }
        //refresh
        this.dispatchEvent(new RefreshEvent());
      } );
    } else{this.newFile = false;
      this._currentDocId = null;
      this.fileUpload = false;
      this.versionDetails = [];
      this.fileName = "";
      this.fileTitle = "";
      this.fileDescr = "";
      this.fileDescription = "";
      this.fileFirm = false;
      this.fileFirmado = false;
      this.showAttachFields = false;
      refreshApex(this._filesList);
      if (this.dialag) {
        this.dialag.closeModal();
      }
      //refresh
      this.dispatchEvent(new RefreshEvent());
    } 
  }

  handleRowAction(event) {
    const action = event.detail.action.name;
    const row = event.detail.row;
    this._currentDocId = row.id;
    var fileName = row.title;
    if (action === "show_details") {
      this.fileUpload = false;
      this.title = `Historial de archivo - ${fileName}`;
      this.showVersionDetails(fileName);
    } else if (action === "upload_version") {
      this.fileUpload = true;
      if (this.dialag) {
        this.newFile = false;
        this.title = `Subir nueva versión del archivo - ${fileName}`;
        this.dialag.openmodal();
      }
    } else if (action === "delete") {
      this.deleteFilesIndiv([this._currentDocId]);
    }
  }

  deleteFilesIndiv(recordIds) {
    if (recordIds.length > 0) {
      let decision = confirm(
        `Seguro que quieres eliminar ${recordIds.length} registros?`
      );
      if (decision) {
        this._deleteRecordInd(recordIds);
      }
    }
  }

  _deleteRecordInd(recordIds) {
    Promise.all(recordIds.map((id) => deleteRecord(id)))
      .then(() => {
        refreshApex(this._filesList);
        this.dispatchEvent(
          new ShowToastEvent({
            variant: "success",
            message: `Registro eliminado correctamente`
          })
        );
      })
      .catch((err) => {
        this.dispatchEvent(
          new ShowToastEvent({
            title: 'Error',
            variant: "error",
            message: `Un error ha ocurrido al intentar eliminar los registros: ${err.body ? err.body.message || err.body.error : err
              }`
          })
        );
      });
  }

  handleSave(event) {
    const fields = {};
    fields[ID_FIELD.fieldApiName] = event.detail.draftValues[0].latestVersionId;
    fields[DESCRIPTION_FIELD.fieldApiName] = event.detail.draftValues[0].description;
    fields[SEG_FIRMADO__C_FIELD.fieldApiName] = event.detail.draftValues[0].firmado;
    fields[SEG_GDD__C_FIELD.fieldApiName] = event.detail.draftValues[0].gdd;
    const recordInput = { fields };

    updateRecord(recordInput)
      .then(() => {
        this.dispatchEvent(
          new ShowToastEvent({
            title: 'Success',
            message: 'Archivo actualizado',
            variant: 'success'
          })
        );
        // Display fresh data in the datatable
        return refreshApex(this._filesList).then(() => {

          // Clear all draft values in the datatable
          this.draftValues = [];

        });
      }).catch(error => {
        this.dispatchEvent(
          new ShowToastEvent({
            title: 'Error actualizando o recargando los registros',
            message: error.body.message,
            variant: 'error'
          })
        );
      });
  }

  /*handleSave(event) {

    let draftValues = event.detail.draftValues;

    const recordInputs = event.detail.draftValues.slice().map(draft => {
      const fields = Object.assign({}, draft);
      return { fields };
    });

    console.log('RECORDINPUTS', JSON.stringify(recordInputs));

    const promises = recordInputs.map(recordInput => updateRecord(recordInput));
    Promise.all(promises).then(() => {

      this.draftValues = [];

      return refreshApex(this.refreshTable);
    }).catch(error => {
      // Handle error
    });
  }*/

  newFileUpload() {
    this.newFile = true;
    this.fileUpload = true;
    this.title = 'Adjuntar archivos nuevos';
    if (this.dialag) {
      this.dialag.openmodal();
    }
  }

  get dialag() {
    return this.template.querySelector('c-dialog');
  }
  showVersionDetails() {
    getFileVersionDetails({ fileId: this._currentDocId })
      .then((result) => {
        this.versionDetails = result;
        if (this.dialag) {
          this.dialag.openmodal();
        }
      })
      .catch((err) => {
        console.error(JSON.stringify(err));
      });
  }
  handleError() {
    console.error(err);
    this.dispatchEvent(
      new ShowToastEvent({
        variant: "error",
        message: 'Fallo al subir el archivo: ${err.body.message || err.body.error}'
      })
    );
    this.showSpinner = false;
  }

  handleUploadFinished(event) {
    this.attachmentReady = true;
    this.showAttachFields = true;
		var uploadedFiles = event.detail.files;
    this.fileName = uploadedFiles[0].name;
    this.fileTitle = uploadedFiles[0].name;
    this.uploadedFileData = uploadedFiles[0];
	}

  handleUpload(event) {
    this.showSpinner = true;
    var fileVers = this.uploadedFileData.documentId;
    var Title =  this.fileTitle;
    var Description = this.fileDescr;
    var Firmado = this.fileFirm;
    var GDD = this.fileGDD;
    uploadFileModify({versionArchivo: fileVers, 
                      titulo: Title, 
                      descripcion: Description, 
                      firma: Firmado, 
                      gdd : GDD})
    .then(() => {
      this.dispatchEvent(
        new ShowToastEvent({
          variant: "success",
          message: `Versión de Documento de contenido creada ${cVersion.id}`
        })
      );
    })
    .catch(error => {
			console.error(JSON.stringify(error));
    })
    .finally(() =>{
      this.showSpinner = false;
      this.showAttachFields = false;
      this.attachmentReady = false;
      this.uploadedFileData = null;
      this.closeModal();
    } );
  }
      
  uploadFile(file, fileData, reasonForChange) {
    const payload = {
      Title: this.fileTitle || this.fileName,
      Description: this.fileDescr || this.fileDescription,
      SEG_Firmado__c: this.fileFirm || this.fileFirmado,
      SEG_GDD__c: this.fileGDD || this.fileGDDPlace,
      PathOnClient: file.name,
      ReasonForChange: reasonForChange,
      VersionData: fileData.replace(BASE64EXP, "")
    };
    if (this._currentDocId) {
      payload.ContentDocumentId = this._currentDocId;
    }
    createRecord({ apiName: "ContentVersion", fields: payload })
      .then((cVersion) => {
        this.showSpinner = false;
        if (!this._currentDocId) {
          this.createContentLink(cVersion.id);
        } else {
          this.closeModal();
          this.dispatchEvent(
            new ShowToastEvent({
              variant: "success",
              message: `Versión de Documento de contenido creada ${cVersion.id}`
            })
          );
        }
      })
      .catch((err) => {
        this.dispatchEvent(
          new ShowToastEvent({
            variant: "error",
            message: `Fallo al subir el archivo: ${err.body.message || err.body.error}`
          })
        );
        this.showSpinner = false;
      });
  }

  createContentLink(cvId) {
    createContentDocLink({
      contentVersionId: cvId,
      recordId: this.recordId,
    })
      .then((cId) => {
        this.closeModal();
        this.dispatchEvent(
          new ShowToastEvent({
            variant: "success",
            message: `Archivo subido correctamente ${cId}`
          })
        );
      })
      .catch((err) => {
        this.dispatchEvent(
          new ShowToastEvent({
            variant: "error",
            message: `An error occurred: ${err.body ? err.body.message || err.body.error : err
              }`
          })
        );
      });
  }
    downloadFile(){
      const selectedRowIds = this.template
      .querySelector("c-file-data-table[data-tablename='filestable']")
      .getSelectedRows()
      .map((row) => row.id);

    if (selectedRowIds.length > 0) {
      let decision = confirm(
        `Seguro que quieres descargar ${selectedRowIds.length} registro(s)?`
      );
      if (decision) {
        //console.log('dentro decision '+ decision);
        for(let fileid of selectedRowIds){
         /// console.log('dentro decision '+ fileid);
          this.downloadFileRI(fileid);

        }
        this.template.querySelector("c-file-data-table[data-tablename='filestable']").selectedRows = [];
      }
    }
  }

  getBaseUrl(){
    let baseUrl = 'https://'+location.host+'/';
    return baseUrl;
}

downloadFileRI(recordIds){
  //console.log('dentroevento downloadfile RI ' + recordIds);
  let baseUrl = this.getBaseUrl();
  //console.log('dentroevento downloadfile url ' + baseUrl + 'sfc/servlet.shepherd/document/download/' + recordIds);
  this[NavigationMixin.Navigate]({
    type: 'standard__webPage',
    attributes: {
        //url: window.location.origin + '/sfc/servlet.shepherd/document/download/' + fileId
        url: baseUrl + 'sfc/servlet.shepherd/document/download/' + recordIds
        }
      },false);
}

deleteFiles() {
  const selectedRowIds = this.template
    //.querySelector("c-custom-datatable[data-tablename='filestable']")
    .querySelector("c-file-data-table[data-tablename='filestable']")
    .getSelectedRows()
    .map((row) => row.id);
  if (selectedRowIds.length > 0) {
    //eslint-disable-next-line
    let decision = confirm(
      `Seguro que quieres borrar ${selectedRowIds.length} registro(s)?`
    );
    if (decision) {
      deleteFiles({
        versionArchivo: selectedRowIds
      })
        .then(() => {
          refreshApex(this._filesList);
        })
        .catch((err) => {
          this.dispatchEvent(
            new ShowToastEvent({
              variant: "error",
              message: `An error occurred: ${err.body ? err.body.message || err.body.error : err
                }`
            })
          );
        });
    }
  }
}

/*_deleteRecord(recordIds) {
  Promise.all(recordIds.map((id) => deleteRecord(id)))
    .then(() => {
      refreshApex(this._filesList);
      this.dispatchEvent(
        new ShowToastEvent({
          variant: "success",
          message: `Registro(s) borrado con éxito`
        })
      );
    })
    .catch((err) => {
      this.dispatchEvent(
        new ShowToastEvent({
          variant: "error",
          message: `Error mientras se borraban los registros: ${
            err.body ? err.body.message || err.body.error : err
          }`
        })
      );
    });
  } */

  handleSendValuesEvent(event){
    this.showAttachFields = event.detail.campos;
    this.attachmentReady = event.detail.adjuntos;
    this.uploadedFileData = null;
  }
}