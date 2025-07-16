import { LightningElement, api, track, wire } from 'lwc';
import getRuta from '@salesforce/apex/SPV_LCMP_GeneracionDocumento.getRuta';
import getRutaVS from '@salesforce/apex/SPV_LCMP_GeneracionDocumento.getRutaVS';
import insertarimagen from '@salesforce/apex/SPV_LCMP_GeneracionDocumento.insertarimagen';
import generarDocumento from '@salesforce/apex/SPV_LCMP_GeneracionDocumento.generarDocumento';
import comprobarDocumentoGuardado from '@salesforce/apex/SPV_LCMP_GeneracionDocumento.comprobarDocumentoGuardado';

import { RefreshEvent } from 'lightning/refresh';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';



export default class Spv_GeneracionDocumento extends LightningElement {

    @api recordId;
    @api carpetaRaiz = 'SPV_PlantillasRedaccion';
    @api proyecto = 'SPV';

    @api mostrarEdicion = false;
    @api ocultarBoton = false;
    @api header;
    @api footer;
    @api cuerpo;

    @track rutaVS;
    @track ruta;
    @track mostrarInsertarImagen = false;
    @track rutaRespuesta;
    messageFromVF = '';
    @track botonGenerar = true;
    @track rutaimagen;
    @track spinnerLoading = false;
    @track mostrarMensajeNoImagen = false;
    mensajeNoImagen = 'Solo se permiten insertar imágenes, el texto se eliminará automáticamente';
    @track idDocumento;
    @track idDocGenerado;
    @track iteracionRefresco = 0;
    @track act;
    @track isProgressing = false;
    @track progress = 0;
    @track tieneDocGuardado = false;
    @track textEditado = false;
    @track modalSalirSinGuardar = false;
    @track documentoGenerado = false;

    //Desarrollo descripcion (alt) imagenes
    @track modalAñadirDesc = false;
    @track disabledInsertImg = false;
    @track flagImgInsert = false;
    @track cuerpoSinGuardar;
    @track todasImgConTag = true;
    imagenes = [];
    imgAltMap = new Map();
    


    @wire(comprobarDocumentoGuardado, {id: '$recordId'}) 
    wiredDocGuardado({ error, data }) {        
        if(data){   
            if(data.SAC_SAC_URL__c != '' && data.SAC_URL__c != null){
                this.tieneDocGuardado = false;
            }else{
                this.tieneDocGuardado = true;
                this.header = data.SAC_Header__c;
                this.footer = data.SAC_Footer__c;
            }
        }else{
            this.tieneDocGuardado = false;
        }   
    };

    connectedCallback() {
        getRuta({}).then(result => {
            if(result){
                this.rutaVS = 'https://' + result + '/apex/SPV_EditorHTMLPlantillas?id=' + this.recordId;
            }
        });
        setTimeout(() => {
            if(this.template.querySelector("iframe")){
                var vfWindow = this.template.querySelector("iframe").contentWindow;
                var parametros = {datos : this.cuerpo, origen: "cuerpo"}
                
                vfWindow.postMessage(parametros, this.rutaVS);
            }
        }, 3000);

        window.addEventListener("message", (message) => {  
            getRuta({}).then(result => {
                if(result){                    
                    this.rutaRespuesta = 'https://' + result;    
                    
                    if (message.origin !== this.rutaRespuesta) {
                        //Not the expected origin
                        return;
                    }
                    
                    if(!message.data.guardado){
                        this.textEditado = true;
                        this.flagImgInsert = false;
                    }
                    
                    //handle the message
                    if (message.data.guardado && message.data.name == this.recordId) {
                        this.messageFromVF = message.data.payload;
                        this.cuerpo = this.messageFromVF;

                        if(!this.flagImgInsert){

                            this.comprobarTodasImgAlt();

                            if(this.todasImgConTag){
                                this.textEditado = false;
                                this.cuerpoSinGuardar = this.cuerpo; //Guardo, por lo tanto almaceno el ultimo cuerpo guardado

                                const botonSubmit = this.template.querySelector( ".botonOculto");
                
                                if(botonSubmit){ 
                                    botonSubmit.click();
                                }
                                this.botonGenerar = false;
                            }else{
                                this.showToast('Advertencia!', 'Todas las imágenes deben tener una descripción informada. Revíselas y posteriormente continue el proceso.', 'warning')
                            }
                        }else{
                            this.textEditado = true;
                            this.flagImgInsert = false;
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

    cerrarEdicion() {          
        if(this.textEditado){
            this.modalSalirSinGuardar = true;
        }else{
            this.mostrarEdicion = false;
        }
    }

    generarDoc(){
        this.spinnerLoading = true;
        generarDocumento({'id': this.idDocGenerado}).then(result => {
            this.mostrarEdicion = false;
            this.botonGenerar = true;
            this.tieneDocGuardado = false;
            this.documentoGenerado = true;
           
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

    aplicarPlantillaDoc(event){ 
        this.idDocGenerado = '';
        this.botonGenerar = true
        this.mostrarEdicion = true;
        this.textEditado = true;

        this.cuerpo = event.detail.cuerpoPlantillaAct;
        this.footer = event.detail.footerPlantillaAct;
        this.header = event.detail.headerPlantillaAct;

        this.callVFPageMethod();
    }

    aplicarPlantillaDocPpio(event){
        this.idDocGenerado = '';
        this.botonGenerar = true;
        this.mostrarEdicion = true;

        
        this.cuerpo = event.detail.cuerpoPlantillaAct;
        this.footer = event.detail.footerPlantillaAct;
        this.header = event.detail.headerPlantillaAct;
       
        // this.callVFPageMethod();
        setTimeout(() => {
            this.callVFPageMethod();
        }, 3000);
    }

    callVFPageMethod() {  
        getRutaVS({}).then(result => {
            if(result){
                this.rutaVS = result + this.recordId;
            }
        });   
        setTimeout(() => {
            if(this.template.querySelector("iframe")){
                var vfWindow = this.template.querySelector("iframe").contentWindow;
                var parametros = {datos : this.cuerpo, origen: "cuerpo"}
                    
                vfWindow.postMessage(parametros, this.rutaVS);
            }
        }, 1000);
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

    handleSubmit(event){        
        const fields = event.detail.fields;
        fields.SAC_DocPDF__c = this.cuerpo;
        fields["SAC_Header__c"] = this.header;
        fields["SAC_Footer__c"] = this.footer;
        this.template.querySelector('lightning-record-edit-form').submit(fields);
    }

    handleSuccess(event) {  
        this.tieneDocGuardado = true;

        const record = event.detail;
        const apiName = record.apiName;
        const myRecordId = record.id;

        this.idDocGenerado = myRecordId;
        this.iteracionRefresco += 1;
        this.act = `&n=${this.iteracionRefresco}`;
        this.isProgressing = false;
        clearInterval(this._interval);
        this.progress = 0;
        
        getRuta({}).then(result => {
            if(result){
                this.ruta = 'https://' + result + '/apex/SAC_DocumentoRedaccionPDF?id=' + this.idDocGenerado + this.act;
            }
        });
    }

    continuarEdiciónDoc(){
        this.textEditado = false;
        this.botonGenerar = true;
        this.idDocGenerado = '';
        this.ruta = '';
        this.mostrarEdicion = true;
    }

    closeModalSalir(){
        this.modalSalirSinGuardar = false;
    }

    confirmarSalir(){
        this.modalSalirSinGuardar = false;
        this.mostrarEdicion = false;
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

    showToast(title, message, variant) {
        const event = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant
        });
        this.dispatchEvent(event);
    }
}