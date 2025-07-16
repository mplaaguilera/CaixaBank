import { LightningElement, api, wire, track } from 'lwc';
import compruebaDocumentoRedaccion from '@salesforce/apex/SAC_LCMP_GeneracionDocumento.compruebaDocumentoRedaccion';
import generarDocumentoRedaccion from '@salesforce/apex/SAC_LCMP_GeneracionDocumento.generarDocumentoRedaccion';
import getRuta from '@salesforce/apex/SAC_LCMP_GeneracionDocumento.getRuta';
import { RefreshEvent } from 'lightning/refresh';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';


export default class SAC_GeneracionDocumento extends LightningElement {

    @track idRedaccion;
    @track iteracionRefresco = 0;
    @track act;
    @track ruta;
    @track isProgressing = false;
    @track progress = 0;
    @track casoId;
    @track botonGenerar = true;
    @track listaArchivos =[];
    @track llamadaSelector = false;
    @track guardado = false;
    @track spinnerLoading = false;
    @track reenvio = false;
   
    @api recordId;  
    @api cuerpo;
    @api cuerpoPrevio;
    @api mostrarEdicion = false;
    @api ocultarBoton = false;
    @api footer;
    @api header;
    @api botonDisabled;




    formats = [
        'font',
        'size',
        'bold',
        'italic',
        'underline',
        'strike',
        'list',
        'indent',
        'align',
        'link',
        'image',
        'clean',
        'table',
        'header',
        'color',
        'background'
    ];

    handleRichTextChange(event) {
        this.cuerpo = event.target.value;
        this.botonGenerar = true;
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



    guardar(){
        this.template.querySelector('lightning-record-edit-form').submit();
        this.botonGenerar = false;
        this.guardado = true;
    }

    abrirEdicion(){
        this.mostrarEdicion = true;
       compruebaDocumentoRedaccion({'id': this.recordId }).then(result => {
       if(result){
       // Asigna el resultado del @wire a una variable separada en lugar de la misma función
         this.documentoGuardado = result;       
       // Comprueba si result.data existe antes de acceder a sus propiedades
            if (result.SAC_Cuerpo__c != null && result.SAC_Cuerpo__c !== " ") {
                this.cuerpo = result.SAC_Cuerpo__c;
                this.footer = result.SAC_Footer__c;
                this.header = result.SAC_Header__c;
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
        generarDocumentoRedaccion({'id': this.idRedaccion,  'reenvio': this.reenvio  }).then(result => {
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
        this.cuerpo = event.detail.cuerpo;
        this.footer = event.detail.footer;
    }


    handleEventoAbierto(event){
        this.mostrarEdicion = true;
    }


///TiNY

    vfRoot = "https://caixabankcc--devservice--c.sandbox.vf.force.com";
    messageFromVF = ''
 
    connectedCallback() {
        window.addEventListener("message", (message) => {
            console.log('message.origin',message.origin);
            if (message.origin !== this.vfRoot) {
                //Not the expected origin
                return;
            }
            
            //handle the message
            if (message.data.name == "ContenidoHTML") {
                this.messageFromVF = message.data.payload;
                console.log('Ffrom VF ',this.messageFromVF);
                                
                //const nameField = this.template.querySelector('lightning-input-field[data-id="SAC_Cuerpo__c"]');
                //nameField.value =this.messageFromVF;
                //this.template.querySelector('lightning-record-edit-form').submit();

                this.cuerpo = this.messageFromVF;
                this.botonGenerar = true;
                this.guardar();

            }
        });
    }

    callVFPageMethod() {
        var vfWindow = this.template.querySelector("iframe").contentWindow;
        let paramData = this.cuerpo;
        vfWindow.postMessage(paramData, this.vfRoot);
    }
}