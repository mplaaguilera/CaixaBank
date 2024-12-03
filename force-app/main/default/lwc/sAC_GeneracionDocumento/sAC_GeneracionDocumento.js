import { LightningElement, api, wire, track } from 'lwc';
import { getRecord, getFieldValue} from 'lightning/uiRecordApi';
import compruebaDocumentoRedaccion from '@salesforce/apex/SAC_LCMP_GeneracionDocumento.compruebaDocumentoRedaccion';
import generarDocumentoRedaccion from '@salesforce/apex/SAC_LCMP_GeneracionDocumento.generarDocumentoRedaccion';
import getRuta from '@salesforce/apex/SAC_LCMP_GeneracionDocumento.getRuta';
import getRutaVS from '@salesforce/apex/SAC_LCMP_GeneracionDocumento.getRutaVS';
import insertarimagen from '@salesforce/apex/SAC_LCMP_GeneracionDocumento.insertarimagen';

import { RefreshEvent } from 'lightning/refresh';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

//Campos reclamación
import IDIOMA_FIELD from '@salesforce/schema/Case.CC_Idioma__c';


const fields = [IDIOMA_FIELD];
export default class SAC_GeneracionDocumento extends LightningElement {

    @track idRedaccion;
    @track iteracionRefresco = 0;
    @track act;
    @track ruta;
    @track rutaVS;
    @track rutaRespuesta;
    @track idDocumento;
    @track isProgressing = false;
    @track progress = 0;
    @track casoId;
    @track botonGenerar = true;
    @track listaArchivos =[];
    @track llamadaSelector = false;
    @track guardado = false;
    @track spinnerLoading = false;
    @track realizadaPrimeraLlamada = false;
    messageFromVF = '';
    @track mostrarInsertarImagen = false;
    @track rutaimagen;
    @track mostrarMensajeNoImagen = false;
    mensajeNoImagen = 'Solo se permiten insertar imágenes, el texto se eliminará automáticamente';

    @track caso;
    @track idiomaReclamacion = '';
   
    @api recordId;  
    @api cuerpo;
    @api cuerpoPrevio;
    @api mostrarEdicion = false;
    @api ocultarBoton = false;
    @api llamadaPlantillas = false;
    @api footer;
    @api header;
    @api botonDisabled;


    //Se obtiene cuál es el idioma del caso
    @wire(getRecord, { recordId: '$recordId', fields })
    wiredCase({error, data}){
        if(data){
            this.caso = data;
            this.idiomaReclamacion = data.fields.CC_Idioma__c.value;
            console.log('el idioma ' + JSON.stringify(this.idiomaReclamacion));
        }
    }


    handleSubmit(event){
        event.preventDefault();   
        const fields = event.detail.fields;
        fields.SAC_DocPDF__c = this.cuerpo;
        console.log('this.cuerpo ' +this.cuerpo);
        // Utiliza una expresión regular para encontrar todas las ocurrencias de <br><br>
        //const regex = /<br\s*\/?><br\s*\/?>/gi;
        
        // Reemplaza todas las ocurrencias de <br><br> por </span></p><p>
        // const updatedHtml = this.cuerpo.replace(regex, '<p></p>');
        // fields.SAC_DocPDF__c = updatedHtml;
        // console.log('this.cuerpo DESPUESS ' +fields.SAC_DocPDF__c);

        // const sinBr = this.cuerpo.replace(/<br\s*>/gi, '');
        // fields.SAC_DocPDF__c = sinBr;
        // console.log('this.cuerpo DESPUESS ' +fields.SAC_DocPDF__c);

        const conDisplayBlock = this.cuerpo.replace(/(<br\s*\/?>\s*){2}/gi, '</p><p>');

        fields.SAC_DocPDF__c = conDisplayBlock;
        console.log('this.cuerpo DESPUES ' +fields.SAC_DocPDF__c);

        if(this.idiomaReclamacion == 'en'){     //Si el idioma es inglés
            fields["SAC_NombrePlantillaLateral__c"] = '';
            console.log('INGLÉS');
        }else if(this.idiomaReclamacion == 'ca'){       //Si el idioma es catalán
            fields["SAC_NombrePlantillaLateral__c"] = '';
            console.log('CATALÁN');
        }else{          //Si el idioma es Castellano o cualquier otro, se usa la plantilla en castellano
            fields["SAC_NombrePlantillaLateral__c"] = 'SAC_CartaPlantilla';
            console.log('CASTELLANO');
        }

        //fields["SAC_NombrePlantillaLateral__c"] = 'HOLAAAAAAAAAAAAA';
        
        this.template.querySelector('lightning-record-edit-form').submit(fields);
    }


    handleSuccess(event) {
        const record = event.detail;
        const apiName = record.apiName;
        const myRecordId = record.id; // ID of updated or created record

        this.idRedaccion = myRecordId;
        this.iteracionRefresco += 1;
        this.act = `&n=${this.iteracionRefresco}`;
        this.isProgressing = false;
        clearInterval(this._interval);
        this.progress = 0;
        getRuta({}).then(result => {
            if(result){
                this.ruta = 'https://' + result + '/apex/SAC_DocumentoRedaccionPDF?id=' + this.idRedaccion + this.act;
            }
        });
    }

    abrirEdicion(){
        this.mostrarEdicion = true;
       compruebaDocumentoRedaccion({'id': this.recordId }).then(result => {
       if(result){
            // Asigna el resultado del @wire a una variable separada en lugar de la misma función
            this.documentoGuardado = result;       
            // Comprueba si result.data existe antes de acceder a sus propiedades
            if (result.SAC_DocPDF__c != null && result.SAC_DocPDF__c !== " ") {
                this.cuerpo = result.SAC_DocPDF__c.replace(/(<br\s*\/?>\s*){2}/gi, '</p><p>');
                console.log('HTML PASADO A TINY 1 ' + this.cuerpo);
                this.footer = result.SAC_Footer__c;
                this.header = result.SAC_Header__c;
                this.idDocumento = result.Id;
                
                getRuta({}).then(result => {
                    if(result){
                        this.rutaVS = 'https://' + result + '/apex/SAC_EditorHTMLPlantillas?id=' + this.recordId;
                    }
                });
                var vfWindow = this.template.querySelector("iframe").contentWindow;
                var parametros = {datos : this.cuerpo, origen: "cuerpo"}
                
                vfWindow.postMessage(parametros, this.rutaVS);
            }
        }
    });
   }
    
    cerrarEdicion() {
        this.mostrarEdicion = false;
        this.botonGenerar = true;
        if(this.guardado) {
            let dataToSend = true;
            //Custom event en el que se manda la info que queremos enviar al componente padre
                    const sendDataEvent = new CustomEvent('senddataguardado', {
                    detail: {dataToSend}
            });

            //Hacemos el dispatch event del evento que hemos creado
            this.dispatchEvent(sendDataEvent);
        }
    }

   

    llamarSelectorPlantillas(){
        this.llamadaSelector = true;
    }

    generarDoc(){
        this.spinnerLoading = true;
        generarDocumentoRedaccion({'id': this.idRedaccion }).then(result => {
            this.mostrarEdicion = false;
            this.botonGenerar = true;
            let dataToSend = true;
            //Custom event en el que se manda la info que queremos enviar al componente padre
            const sendDataEvent = new CustomEvent('senddata', {
                detail: {dataToSend}
            });
        
            //Hacemos el dispatch event del evento que hemos creado
            this.dispatchEvent(sendDataEvent);
            let dataGenerar = true;
            //Custom event en el que se manda la info que queremos enviar al componente padre
            const sendDataEventGenerar = new CustomEvent('senddatagenerar', {
            detail: {dataGenerar}
            });
        
            //Hacemos el dispatch event del evento que hemos creado
            this.dispatchEvent(sendDataEventGenerar);
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Exito',
                    message: 'Se ha generado el documento correctamente.',
                    variant: 'success'
                })
            ); 
            this.spinnerLoading = false;
            this.dispatchEvent(new RefreshEvent());
                
            
        }).catch(error => {
            this.spinnerLoading = false;
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error',
                    message: 'Error al generar el documento',
                    variant: 'error'
                })
            ); 
            this.dispatchEvent(new RefreshEvent());
        })   
    }

    handleEventoAplicar(event){
        this.botonGenerar = true;
        this.header = event.detail.header;
        this.cuerpo = event.detail.cuerpo.replace(/(<br\s*\/?>\s*){2}/gi, '</p><p>');
        console.log('HTML PASADO A TINY 2 ' + this.cuerpo);
        this.footer = event.detail.footer;

        this.callVFPageMethod();
    }


    handleEventoAbierto(event){
        this.mostrarEdicion = true;
    }    
    
 
    connectedCallback() {
        if(this.llamadaPlantillas && !this.realizadaPrimeraLlamada) {
            this.realizadaPrimeraLlamada = true;
            getRuta({}).then(result => {
                if(result){
                    this.rutaVS = 'https://' + result + '/apex/SAC_EditorHTMLPlantillas?id=' + this.recordId;
                }
            });
            setTimeout(() => {
                var vfWindow = this.template.querySelector("iframe").contentWindow;
                var parametros = {datos : this.cuerpo, origen: "cuerpo"}
                
                vfWindow.postMessage(parametros, this.rutaVS);
            }, 3000);
        }
        window.addEventListener("message", (message) => {
            getRuta({}).then(result => {
                if(result){
                    this.rutaRespuesta = 'https://' + result;

                    if (message.origin !== this.rutaRespuesta) {
                        //Not the expected origin
                        return;
                    }
                    
                    //handle the message
                    if (message.data.name == this.recordId) {
        
                        this.messageFromVF = message.data.payload;
        
                        this.cuerpo = this.messageFromVF;
                        const botonSubmit = this.template.querySelector( ".botonOculto");
        
                        if(botonSubmit){ 
                            botonSubmit.click();
                        }
                        this.botonGenerar = false;
                        this.guardado = true;
                    }
                }
            });
        });       
    }

    renderedCallback() {
        setTimeout(() => {
            this.template.querySelector(".divEditor").classList.remove("slds-hide");
            
        }, 3000);
    }

    callVFPageMethod() {
        getRutaVS({}).then(result => {
            if(result){
                this.rutaVS = result + this.recordId;
            }
        });   
        setTimeout(() => {
            var vfWindow = this.template.querySelector("iframe").contentWindow;
            var parametros = {datos : this.cuerpo, origen: "cuerpo"}
                
            vfWindow.postMessage(parametros, this.rutaVS);
        }, 500);
    }


    mostrarModalInsertarImagen() {
        this.mostrarInsertarImagen = true;
    }

    closeModalImagen() {
        this.mostrarInsertarImagen = false;
    }

    insertarImagen() {
        if(this.rutaimagen != null && this.rutaimagen != '') {
            insertarimagen({'id': this.recordId , 'imagen': this.rutaimagen}).then(result => {
                if(result){
                    this.rutaimagen = result;
                    getRutaVS({}).then(result => {
                        if(result){
                            this.rutaVS = result + this.recordId;
                        }
                    });   
                    setTimeout(() => {
                        var vfWindow = this.template.querySelector("iframe").contentWindow;
                        var parametros = {datos : this.rutaimagen, origen: "imagen"}
                            
                        vfWindow.postMessage(parametros, this.rutaVS);
                    }, 500);        
                }   
                
            }).catch(error => {
                this.spinnerLoading = false;
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error',
                        message: 'Error al insertar la imagen',
                        variant: 'error'
                    })
                ); 
                this.dispatchEvent(new RefreshEvent());
            })   
        }
        this.mostrarInsertarImagen = false;
    }

    handleRichTextChange(event) {        
        const regex = /<img[^>]*>/g;

        const imgs = event.target.value.match(regex);

        if (imgs !== null) {
            this.mostrarMensajeNoImagen = false;
            let result = event.target.value.replace(/<(img|p|br)[^>]*?>|<\/(img|p|br)>/g, "");
            if(result != null && result != '') {
                this.mostrarMensajeNoImagen = true;
            }
            if (imgs.length > 1) {
              const imgsString = "<p>" + imgs.join("</p><p>") + "</p>";
              this.rutaimagen = imgsString;
            } else {
              const imgsString = "<p>" + imgs[0] + "</p>";
              this.rutaimagen = imgsString;
            }
        } else {
            this.mostrarMensajeNoImagen = true;
            this.rutaimagen = '';
        }
    }


    inputOnKeyDown(event) {
        if ((event.ctrlKey && event.key === 'v') || event.key === 'Backspace' || event.key === 'Delete') return;
        event.preventDefault();
    }
}