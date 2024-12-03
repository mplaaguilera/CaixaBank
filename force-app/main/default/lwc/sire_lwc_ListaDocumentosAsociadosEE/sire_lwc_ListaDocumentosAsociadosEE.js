import { LightningElement, wire, api, track } from 'lwc';
import getQueryTareasDoc from '@salesforce/apex/SIRE_LCMP_ListaDocumentoAsociadosEE.getQueryTareasDoc';
import callWsDownloadDocumentoEE from '@salesforce/apex/SIRE_LCMP_ListaDocumentoAsociadosEE.callWsDownloadDocumentoEE';

const columnsDocumento = [
    { label: 'Nombre del documento', fieldName: 'nombreDocumento', type: 'text', typeAttributes: { tooltip: { fieldName: 'idDocument' } }},
    { label: 'Tipo documento', fieldName: 'tipoDocumento', type: 'text'},
    { label: 'Adjuntado por', fieldName: 'modificadoName', type: 'text'},
    { label: 'Fecha', fieldName: 'modificadoFecha', type: 'date'},    
    { label: '', fieldName: 'situacionContable', type: 'button', 
        typeAttributes: {iconName: 'utility:download', label: 'Descargar documento', name: 'verDocumento', title: 'verDocumento', disabled: { fieldName: 'disabledBotonDescargar' }} }   
];

export default class Sire_lwc_ListaDocumentosAsociadosEE extends LightningElement {    
    @api recordId;
    columnsDocumento = columnsDocumento; 
    @track documentos; 
    @track titulo;   
    @track tablaVisible = false;
    @track noHayDatos = false;
    @track mensajeError;
    @track mostrarError = false;    
    
    @wire(getQueryTareasDoc, {recordId: '$recordId'})
    getProcesos({error, data}) { 
        if(data){
            this.titulo = 'Documentos (' + data.length + ')';
            if(data.length === 0){
                this.noHayDatos = true;
            } else {
                this.tablaVisible = true;                
                let currentData = [];
                for (var i = 0; i < data.length; i++) {
                    let rowData = {};    
                    rowData.idDocument = data[i].SIR_IdDocumentoEE__c;   // Id Documento
                    rowData.nombreDocumento = data[i].SIR_NombreDocumentoEE__c; // Nombre documento                   
                    rowData.tipoDocumento = data[i].SIR_TipoDocumentoEE__c; // Tipo documento   
                    rowData.modificadoName = data[i].LastModifiedBy.Name;
                    rowData.modificadoFecha = data[i].LastModifiedDate;
                    rowData.disabledBotonDescargar = false;   
                    currentData.push(rowData);
                }                     
                this.documentos = currentData;
            }             
        }  
    }

    handleRowAction(event) {
        this.mostrarError = false;
        // Ponemos los botones de la tabla en disabled
        this.documentos = this.documentos.map((record) => ({ ...record, disabledBotonDescargar: true }));
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
                    } else {
                        this.mensajeError = 'Se ha producido un problema con la descarga del documento. ' + result[1];
                        this.codigoError = result[2];
                        this.mostrarError = true; 
                        // Ponemos los botones de la tabla activados
                        this.documentos = this.documentos.map((record) => ({ ...record, disabledBotonDescargar: false }));                            
                    }
                }
            })
            .catch(error => {
                // Ponemos los botones de la tabla activados
                this.documentos = this.documentos.map((record) => ({ ...record, disabledBotonDescargar: false })); 
                this.mensajeError = error;
                this.mostrarError = true;
            });             
        }
    }   
}