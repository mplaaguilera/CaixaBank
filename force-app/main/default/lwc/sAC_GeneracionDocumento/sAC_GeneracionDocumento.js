import { LightningElement, api, wire, track } from 'lwc';
import { getRecord, getFieldValue} from 'lightning/uiRecordApi';
import compruebaDocumentoRedaccion from '@salesforce/apex/SAC_LCMP_GeneracionDocumento.compruebaDocumentoRedaccion';
import generarDocumentoRedaccion from '@salesforce/apex/SAC_LCMP_GeneracionDocumento.generarDocumentoRedaccion';
import getRuta from '@salesforce/apex/SAC_LCMP_GeneracionDocumento.getRuta';
import getRutaVS from '@salesforce/apex/SAC_LCMP_GeneracionDocumento.getRutaVS';
import insertarimagen from '@salesforce/apex/SAC_LCMP_GeneracionDocumento.insertarimagen';
import getHeaderAndFooterMTP from '@salesforce/apex/SAC_LCMP_GeneracionDocumento.getHeaderAndFooterMTP';


import { RefreshEvent } from 'lightning/refresh';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

//Campos reclamación
import IDIOMA_FIELD from '@salesforce/schema/Case.CC_Idioma__c';
import RECORDTYPE_FIELD from '@salesforce/schema/Case.RecordType.DeveloperName';
import RECORDTYPEID_FIELD from '@salesforce/schema/Case.RecordTypeId';
import ENTIDAD_AFECTADA_FIELD from '@salesforce/schema/Case.SAC_Entidad_Afectada__c';

const fields = [IDIOMA_FIELD, RECORDTYPE_FIELD, ENTIDAD_AFECTADA_FIELD, RECORDTYPEID_FIELD];
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
    @track entidadAfectadaReclamacion = '';
    @track recordType;
    @track recordTypeId;
    @track carpetaRaiz;
    @track headerMTP = '';
    @track footerMTP = '';
   
    @api recordId;  
    @api cuerpo;
    @api cuerpoPrevio;
    @api mostrarEdicion = false;
    @api ocultarBoton = false;
    @api llamadaPlantillas = false;
    @api footer;
    @api header;
    @api botonDisabled;
    @api reenvio = false; // Esta variable decide el texto del botón

    //Desarrollo descripcion (alt) imagenes
    @track modalAñadirDesc = false;
    @track disabledInsertImg = false;
    @track flagImgInsert = false;
    @track cuerpoSinGuardar;
    @track todasImgConTag = true;
    imagenes = [];
    imgAltMap = new Map();


    //Se obtiene cuál es el idioma del caso
    @wire(getRecord, { recordId: '$recordId', fields })
    wiredCase({error, data}){
        if(data){
            this.caso = data;
            this.idiomaReclamacion = data.fields.CC_Idioma__c.value;
            this.entidadAfectadaReclamacion = data.fields.SAC_Entidad_Afectada__c.value;
            this.recordTypeId = getFieldValue(this.caso, RECORDTYPEID_FIELD);
            this.recordType = getFieldValue(this.caso, RECORDTYPE_FIELD);
            if(this.recordType === 'SPV_Reclamacion') {
                this.carpetaRaiz = 'SPV_PlantillasRedaccion';
            } else {
                this.carpetaRaiz = 'SAC_PlantillasRedaccion';
            }
        }
    }

    handleSubmit(event){
        getHeaderAndFooterMTP({ idioma: this.idiomaReclamacion, entidadAfectada : this.entidadAfectadaReclamacion, recordType: this.recordTypeId})
                .then((result) => {
                        this.headerMTP = result.header;
                        this.footerMTP = result.footer;

                        const fields = event.detail.fields;
        fields.SAC_DocPDF__c = this.cuerpo;

        const conDisplayBlock = this.cuerpo.replace(/(<br\s*\/?>\s*){2}|<br\s*\/?>&nbsp;/gi, '</p><p>');

        fields.SAC_DocPDF__c = conDisplayBlock;
        if(this.entidadAfectadaReclamacion == 'SAC_010'){ // Para MoneyToPay
            fields["SAC_NombrePlantillaLateral__c"] = null;
            fields["SAC_Header__c"] = this.headerMTP;
            fields["SAC_Footer__c"] = this.footerMTP;
        }else if(this.idiomaReclamacion == 'en'){     //Si el idioma es inglés
            fields["SAC_NombrePlantillaLateral__c"] = 'SAC_Lateral_ENG';
            fields["SAC_Header__c"] = this.headerMTP;
            fields["SAC_Footer__c"] = this.footerMTP;
        }else if(this.idiomaReclamacion == 'ca'){       //Si el idioma es catalán
            fields["SAC_NombrePlantillaLateral__c"] = 'SAC_Lateral_CAT';
            fields["SAC_Header__c"] = this.headerMTP;
            fields["SAC_Footer__c"] = this.footerMTP;
        }else{          //Si el idioma es Castellano o cualquier otro, se usa la plantilla en castellano
            fields["SAC_NombrePlantillaLateral__c"] = 'SAC_CartaPlantilla';
            fields["SAC_Header__c"] = this.headerMTP;
            fields["SAC_Footer__c"] = this.footerMTP;
        }
   
        this.template.querySelector('lightning-record-edit-form').submit(fields);

                })
                .catch(error => {
                    if(error.body.message != null) {
                        this.errorMsg = error.body.message;
                    } else {
                        this.errorMsg = error.body.pageErrors[0].message;
                    }
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Fallo al actualizar',
                            message: this.errorMsg,
                            variant: 'error'
                        })
                    );
                })
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
                    this.cuerpo = result.SAC_DocPDF__c.replace(/(<br\s*\/?>\s*){2}|<br\s*\/?>&nbsp;/gi, '</p><p>');
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
        }else{
            this.cuerpo = this.cuerpoSinGuardar;
        }
    }

    llamarSelectorPlantillas(){
        this.llamadaSelector = true;
    }

    generarDoc(){ //Aqui meter validacion todas img tienen alt
        this.spinnerLoading = true;
        generarDocumentoRedaccion({'id': this.idRedaccion, 'reenvio': this.reenvio }).then(result => {
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
        this.cuerpo = event.detail.cuerpo.replace(/(<br\s*\/?>\s*){2}|<br\s*\/?>&nbsp;/gi, '</p><p>');
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

                        if(!this.flagImgInsert){

                            this.comprobarTodasImgAlt();

                            if(this.todasImgConTag){
                                this.cuerpoSinGuardar = this.cuerpo; //Guardo, por lo tanto almaceno el ultimo cuerpo guardado

                                const botonSubmit = this.template.querySelector( ".botonOculto");
                
                                if(botonSubmit){ 
                                    botonSubmit.click();
                                }
                                this.botonGenerar = false;
                                this.guardado = true;
                            }else{
                                this.showToast('Advertencia!', 'Todas las imágenes deben tener una descripción informada. Revíselas y posteriormente continue el proceso.', 'warning')
                            }
                        }else{
                            this.flagImgInsert = false;
                            this.guardado = false;
                        }
                        
                    }
                }
            });
        });       
    }

    renderedCallback() {
        setTimeout(() => {
            if(this.template.querySelector(".divEditor")){
                this.template.querySelector(".divEditor").classList.remove("slds-hide");
            }            
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
            this.modalAñadirDesc = true;
        }

        this.mostrarInsertarImagen = false;
    }

    procesarRuta(){
        const imgRegex = /<img[^>]+src="([^"]+)"[^>]*>/g;

        //Iterar sobre todas las coincidencias de etiquetas <img>
        let match;
        while ((match = imgRegex.exec(this.rutaimagen)) !== null) {
            const src = match[1]; //Capturar el valor del atributo src

            // Verificar si el src existe en el Map
            if(this.imgAltMap.has(src)) {
                const alt = this.imgAltMap.get(src); // Obtener el alt desde el Map

                // Concatenar el alt al src (puedes definir cómo quieres concatenar)
                const nuevoImgTag = `<img src="${src}" alt="${alt}" title="${alt}">`;

                // Reemplazar el src en el string original
                this.rutaimagen = this.rutaimagen.replace(match[0], nuevoImgTag);
            }
        }
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
                //Creo un mapa con cada src de cada imagen y un atributo alt
                this.rellenarMapaImg(imgs);

                const imgsString = "<p>" + imgs.join("</p><p>") + "</p>";
                this.rutaimagen = imgsString;
            } else {
                //Creo un mapa con cada src de cada imagen y un atributo alt
                this.rellenarMapaImg(imgs);

                const imgsString = "<p>" + imgs[0] + "</p>";
                this.rutaimagen = imgsString;
            }
        } else {
            this.mostrarMensajeNoImagen = true;
            this.rutaimagen = '';
        }
    }

    rellenarMapaImg(rutaImagenes){

        this.imagenes = rutaImagenes ? rutaImagenes.map((tag) => {            

            const srcMatch = tag.match(/src="([^"]*)"/);

            if(srcMatch){
                return {
                    src: srcMatch[1],
                    alt: '',
                };
            }
        })
        : [];        
    }

    inputOnKeyDown(event) {
        if ((event.ctrlKey && event.key === 'v') || event.key === 'Backspace' || event.key === 'Delete') return;
        event.preventDefault();
    }

    get botonLabel() {
        return this.reenvio ? 'Editar Carta' : 'Generación Redacción Global';
    }

    cerrarModalDescImagen(){
        this.showToast('Error', 'Es obligatorio añadir una descripción a cada imagen', 'error');
    }

    guardarDescImagen(){

        var todasImgAlt = true;
        this.imgAltMap.clear();

        // Obtener todos los inputs en el DOM
        const inputs = this.template.querySelectorAll('lightning-input[data-id="inputAltImg"]');

        inputs.forEach((input) => {

            const src = input.dataset.value; //Identificar la imagen mediante su src
            const newAlt = input.value; //Valor del alt
            
            this.imgAltMap.set(src, newAlt);

            if(!newAlt){
                todasImgAlt = false;
            }
        }); 

        if(todasImgAlt){
            this.disabledInsertImg = true;           
            
            //Añadir a la ruta antes de generar la imagen el alt correspondiente de cada imagen
            this.procesarRuta();

            insertarimagen({'id': this.recordId , 'imagen': this.rutaimagen}).then(result => {
                if(result){
                    this.cuerpoSinGuardar = this.cuerpo;
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

                        this.modalAñadirDesc = false;
                        this.disabledInsertImg = false;                        
                        this.flagImgInsert = true;
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
        }else{
            this.showToast('Error', 'Es obligatorio añadir una descripción a cada imagen', 'error');
        }
    }

    showToast(title, message, variant) {
        const event = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant
        });
        this.dispatchEvent(event);
    }

    comprobarTodasImgAlt() {

        // Cadena HTML almacenada en this.cuerpo
        const htmlString = this.cuerpo;

        // Usar DOMParser para convertir la cadena HTML en un objeto DOM
        const parser = new DOMParser();
        const doc = parser.parseFromString(htmlString, 'text/html');

        // Seleccionar todas las etiquetas <img> en el DOM
        const images = doc.querySelectorAll('img');

        // Verificar si todas las imágenes tienen un atributo alt no vacío
        const todasTienenAlt = Array.from(images).every(img => {
            const alt = img.getAttribute('alt');
            return alt !== null && alt.trim() !== ''; // Verificar que alt no sea null y no esté vacío
        });

        this.todasImgConTag = todasTienenAlt;
    }
}