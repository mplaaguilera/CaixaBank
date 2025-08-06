import { LightningElement, track, api } from 'lwc';
import { CloseActionScreenEvent } from 'lightning/actions';
import getQueryProceso from '@salesforce/apex/SIRE_LCMP_ListaDocumentoEE.getQueryProceso';
import callWsDocumentoEE from '@salesforce/apex/SIRE_LCMP_ListaDocumentoEE.callWsDocumentoEE';
import callWsDownloadDocumentoEE from '@salesforce/apex/SIRE_LCMP_ListaDocumentoEE.callWsDownloadDocumentoEE';
import sendDocumentoEE from '@salesforce/apex/SIRE_LCMP_ListaDocumentoEE.sendDocumentoEE';

const columnsDocumento = [
    { label: 'Nombre del documento', fieldName: 'nombreDocumento', type: 'text', typeAttributes: { tooltip: { fieldName: 'idDocument' } }},
    { label: 'Tipo documento', fieldName: 'tipoDocumento', type: 'text', initialWidth: 150 },    
    { label: '', fieldName: 'situacionContable', type: 'button', initialWidth: 200, 
        typeAttributes: {iconName: 'utility:download', label: 'Descargar documento', name: 'verDocumento', title: 'verDocumento', disabled: { fieldName: 'disabledBotonDescargar' }} }   
];

export default class Sire_lwc_ListaDocumentoEE extends LightningElement {
    columnsDocumento = [];
    columnsDocumento = columnsDocumento;
    
    @api recordId;
    @track numperso = '';
    @track tareaId = '';
    @track noHayResultados = false;
    @track documentos;
    @track preSelectedRows = [];
    @track respuestaWsEE;
    @track idDocumentoSeleccionado = '';  
    @track nombreDocSeleccionado = '';
    @track tipoDocSeleccionado = '';
    @track infoMetadata = '';
    @track matricula = '';
    @track mensajeError;
    @track mostrarError = false;
    @track disabledGuardar = true;
    @track disabledCancelar = true;
    @track isLoaded = true;
    @track tituloTabla = '';
    @track wiredResult;  

    connectedCallback(){       
        getQueryProceso({recordId: this.recordId}).then(result => {
            if(result){                 
                this.wiredResult = result; 
                //Se obtiene el numperso del cliente del proceso
                this.numperso = result[0].SIREC__SIREC_fld_cliente__r.AV_NumPerso__c;
                this.tareaId = result[0].SIREC__SIREC_fld_tarea__c;
                // Se obtiene el titulo de la tarea
                this.tituloTabla = result[0].SIREC__SIREC_fld_tarea__r.Name;
                // Matricula del Owner del Proceso
                this.matricula = result[0].Owner.EmployeeNumber;
                // Id documento recuperado de BBDD (solo informado en caso de que este en Pendiente Sincronizar)
                this.idDocumentoBBDD = result[0].SIREC__SIREC_fld_tarea__r.SIR_IdDocumentoEE__c;
                // Llamamos al WS para traer todos los documentos de EE
                if(this.numperso != '' && this.numperso != undefined && this.numperso != null){
                    callWsDocumentoEE({numperso: this.numperso}).then(result => {                             
                        if(result.length >= 0){
                            //Si el resultado del WS es OK 
                            if(result[0] == 'OK'){
                                if(result[1].length > 2){
                                    var registroSeleccionadoBBDD = [];
                                    var limite = 0;
                                    this.respuestaWsEE = JSON.parse(result[1]);
                                    let parseJsonRespuesta = JSON.parse(result[1]);                            
                                    let currentData = [];
                                    for (var i = 0; i < parseJsonRespuesta.length; i++) {
                                        let rowData = {};                                                   
                                        rowData.idDocument = parseJsonRespuesta[i].metadata.documentId;   // Id Documento
                                        rowData.nombreDocumento = parseJsonRespuesta[i].metadata.documentDescription; // Nombre documento                   
                                        rowData.tipoDocumento = parseJsonRespuesta[i].metadata.format; // Tipo documento                                        
                                        parseJsonRespuesta[i].metadata.empleado = this.matricula;                                     
                                        rowData.metadata = '{"metadata":' + JSON.stringify(parseJsonRespuesta[i].metadata) + '}';
                                        rowData.disabledBotonDescargar = false ;         
                                        currentData.push(rowData);
                                       
                                        if(this.idDocumentoBBDD == parseJsonRespuesta[i].metadata.documentId && limite == 0){
                                            registroSeleccionadoBBDD.push(parseJsonRespuesta[i].metadata.documentId);
                                            limite ++;
                                            this.idDocumentoSeleccionado = rowData.idDocument; 
                                            this.nombreDocSeleccionado = rowData.nombreDocumento; 
                                            this.tipoDocSeleccionado = rowData.tipoDocumento; 
                                            this.infoMetadata = rowData.metadata; 
                                            this.disabledGuardar = false;               
                                        }
                                    }                     
                                    this.documentos = currentData; 
                                   
                                    if(registroSeleccionadoBBDD != null && registroSeleccionadoBBDD != undefined && registroSeleccionadoBBDD != ''){
                                        this.preSelectedRows = registroSeleccionadoBBDD;
                                    }                                 
                                    //Se muestra la tabla en el frontal
                                    this.mostrarTabla(true);
                                    this.noHayResultados = false;
                                } else {
                                    this.mostrarTabla(false);
                                    this.noHayResultados = true; 
                                }                               
                                this.disabledCancelar = false;   
                                this.isLoaded = false; 
                            } else {
                                this.mensajeError = 'Se ha producido un problema. ' + result[1];
                                this.codigoError = result[2];
                                this.mostrarError = true;
                                this.mostrarTabla(false);
                                this.isLoaded = false; 
                                this.disabledCancelar = false;                          
                            }
                        }
                    })
                    .catch(error => {
                        this.mensajeError = error;
                        this.mostrarError = true;
                        this.mostrarTabla(false); 
                        this.isLoaded = false;
                        this.disabledCancelar = false;
                    });
                } else {
                    this.mensajeError = 'Se ha producido un problema. ';
                    this.codigoError = 'El cliente no tiene informado el Número de Persona';
                    this.mostrarError = true;
                    this.mostrarTabla(false); 
                    this.isLoaded = false;
                    this.disabledCancelar = false;
                }            
            }
        })
        .catch(error => {
            this.mensajeError = error;
            this.mostrarError = true;
            this.mostrarTabla(false); 
            this.disabledCancelar = false;
        }); 
    }   

  
    handleRowAction(event) {
        // Ponemos los botones de la tabla en disabled
        this.documentos = this.documentos.map((record) => ({ ...record, disabledBotonDescargar: true }));       
        this.disabledGuardar = true; 
        this.disabledCancelar = true;
        const row = event.detail.row;
        let jsonRow = JSON.stringify(row);
        let jsonParseRow = JSON.parse(jsonRow);
        let idDocumento = jsonParseRow.idDocument; 
        // Aqui llamariamos al metodo de la clase apex SIRE_LCMP_ListaDocumentoEE que realiza la llamada al WS para mostrar el Documento pasando por parametro el documentId
        if(idDocumento != null && idDocumento != undefined && idDocumento != ''){ 
            callWsDownloadDocumentoEE({idDocumento: idDocumento}).then(result => {    
                if(result.length >= 0){                    
                    //Si el resultado del WS es OK 
                    if(result[0] == 'OK'){                     
                        var jsonRespuesta = JSON.parse(result[1]);
                        var b64 = jsonRespuesta.file;
                        var extension = jsonRespuesta.metadata.format;
                        var nombreDocumento = jsonRespuesta.metadata.documentDescription + '.' + extension;
           
                        const arrayBuffer = new Uint8Array([...window.atob(b64)].map(char => char.charCodeAt(0)));
                        const fileLink = document.createElement('a');                        
                        fileLink.href = window.URL.createObjectURL(new Blob([arrayBuffer]));
                        fileLink.setAttribute('download', nombreDocumento);
                        document.body.appendChild(fileLink);
                                                     
                        fileLink.click();

                        // Ponemos los botones de la tabla activados
                        this.documentos = this.documentos.map((record) => ({ ...record, disabledBotonDescargar: false }));
                        // El botón de Cancelar lo activamos y el de Guardar calculamos si se ha de activar o no
                        this.disabledCancelar = false;
                        if(this.idDocumentoSeleccionado != '' && this.idDocumentoSeleccionado != undefined && this.idDocumentoSeleccionado != null){
                            this.disabledGuardar = false;
                        } else {
                            this.disabledGuardar = true;
                        }                        
                    } else {
                        this.mensajeError = 'Se ha producido un problema. ' + result[1];
                        this.codigoError = result[2];
                        this.mostrarError = true;
                        this.mostrarTabla(false); 
                        this.isLoaded = false;
                        //Se muestra el error
                        this.isLoaded = false;
                        this.disabledCancelar = false;                           
                    }
                }
            })
            .catch(error => {
                this.mensajeError = error;
                this.mostrarError = true;
                this.mostrarTabla(false); 
                this.isLoaded = false;
                this.disabledCancelar = false;
            });             
        }        
    }
    
   
    // Recogemos el ID del documento que han seleccionado
    getSelectedDocument(event) {   
        this.preSelectedRows = [];
        this.preSelectedRows = event.detail.selectedRows[0].idDocument;      
        this.idDocumentoSeleccionado = event.detail.selectedRows[0].idDocument; 
        this.nombreDocSeleccionado = event.detail.selectedRows[0].nombreDocumento; 
        this.tipoDocSeleccionado = event.detail.selectedRows[0].tipoDocumento; 
        this.infoMetadata = event.detail.selectedRows[0].metadata; 
        this.disabledGuardar = false;               
    }
  

    // Metodo que envia el documento seleccionado
    handleSaveAndSendClick() {
        this.disabledGuardar = true; 
        this.disabledCancelar = true; 
        this.mostrarTabla(false);        
        this.isLoaded = true; 
        var infoDocumento = this.idDocumentoSeleccionado + '@' + this.nombreDocSeleccionado + '@' + this.tipoDocSeleccionado + '@' + this.infoMetadata;
        sendDocumentoEE({infoDocumento: infoDocumento, tareaId: this.tareaId}).then(result => {                
            if(result.length >= 0){
                //Si el resultado del WS es OK 
                if(result[0] == 'OK'){                    
                    this.dispatchEvent(new CustomEvent('siguiente'));
                } else {
                    this.mensajeError = 'Se ha producido un problema. ' + result[1];
                    this.codigoError = result[2];
                    this.mostrarError = true;
                    this.mostrarTabla(false);
                    this.isLoaded = false;
                    this.disabledCancelar = false;                                              
                }
            }
        })
        .catch(error => {
            this.mensajeError = error;
            this.mostrarError = true;
            this.mostrarTabla(false);
            this.isLoaded = false;
            this.disabledCancelar = false;
        });
    }   
   

    // Metodo que cierra el pop-up y refresca la pantalla 
    closeQuickAction() {
        this.dispatchEvent(new CloseActionScreenEvent());
        window.location.reload();
    }  

    // Metodo para mostrar o ocultar tabla de resultados WS segun parametro
    mostrarTabla(accion){
        var elemento = this.template.querySelector('.tabla');        
        if(elemento != null && elemento != undefined){
            if(accion == true){   
               elemento.classList.remove('ocultarTabla');
            } else {
                elemento.classList.add('ocultarTabla');
            }     
        }           
    }
}