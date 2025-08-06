import { LightningElement, api, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import actualizarCV from '@salesforce/apex/SAC_LCMP_InputRichText.actualizarCV';


export default class Sac_inputRichTextLWC extends LightningElement {
    @api recordId;
    @api value;
    @api labelVisible;
    @api label;

    @track isOpen = false;
    @track modalAñadirDesc = false;
    @track valueTagImg = '';
    @track saltarChangeInput = false;
    @track recargoCambioP = false;
    @track saltarSetMapa = false;
    @track srcNewImage = '';

    previousValue = '';
    latestRichTextValue = '';
    imageAltMap = new Map();
    _flagCambioPlantilla;


    connectedCallback() {
        this.checkValueC();
    }

    @api
    get flagCambioPlantilla() {       
        return this._flagCambioPlantilla;
    }

    set flagCambioPlantilla(value) {           
        this._flagCambioPlantilla = value;
        this.handleFlagCambioPlantilla();
    }

    @api
    get imageTagsMap(){        
        return this.imageAltMap;
    }
    
    set imageTagsMap(value){
        if(value && !this.saltarSetMapa){
            this.imageAltMap = value;
        }else{            
            this.saltarSetMapa = false;
        }
    }

    reescalado(){
        this.isOpen = !this.isOpen;

        if(!this.isOpen){            
            setTimeout(() => {
                const richTextElement = this.template.querySelector('[data-id="richText1"]');
            
                if (richTextElement) {                    
                    richTextElement.focus();
                }
            }, 0);
        }else{
            setTimeout(() => {
                const richTextElement = this.template.querySelector('[data-id="richText2"]');
            
                if (richTextElement) {                    
                    richTextElement.focus();
                }
            }, 0);
        }
    }

    handleRichTextChange(event) { 
        
        const newValue = event.target.value;        

        //Evitar la entrada tras guardar el tag de una nueva imagen
        if(!this.saltarChangeInput){           
                        
            //Recuperar las imagenes del texto previo y del actual
            const oldImages = this.extractImages(this.previousValue);
            const newImages = this.extractImages(newValue);
            
            //Buscador de una nueva imagen
            const addedImage = newImages.find((newImg, index) => {                
                return (
                    !oldImages[index] ||
                    newImg.src !== oldImages[index].src ||
                    newImg.alt !== oldImages[index].alt
                );
            });

            //Si encuentra una nueva imagen
            if(newImages.length > oldImages.length && addedImage) {
                //Marcar la última imagen insertada con un atributo personalizado
                addedImage.setAttribute('data-last-added', 'true');

                //Actualizar el contenido del rich text con la imagen marcada
                const updatedDoc = new DOMParser().parseFromString(newValue, 'text/html');
                const updatedImages = Array.from(updatedDoc.querySelectorAll('img'));
                const addedImageIndex = newImages.indexOf(addedImage);
                updatedImages[addedImageIndex].setAttribute('data-last-added', 'true');
                this.srcNewImage = updatedImages[addedImageIndex].src;                
                this.latestRichTextValue = updatedDoc.body.innerHTML;

                //Ponemos el campo SAC_BloqueoTotalVisibilidad__c del ContentVersion generado a true, para que estas imágenes no aparezcan en el cmp de adj
                const match = this.srcNewImage.match(/download\/([a-zA-Z0-9]+)/);

                if (match) {                    
                    const idContentVersion = match[1];

                    actualizarCV({ idCV: idContentVersion })
                    .catch(error => {
                        this.showToast('Error', 'Error al insertar la imagen en el cuerpo', 'error');
                    });
                }

                //Mostrar el modal para solicitar la descripción de la imagen
                this.abrirModalAlt();
            }       

            //Almacenar el valor actual como el valor anterior para la próxima comparación
            this.previousValue = newValue;
        }else{
            //Si se hace un cambio de plantilla se deben procesar las nuevas imagenes para modificar el mapa de img
            if(!this.recargoCambioP){
                this.previousValue = newValue;            
            }else{                
                this.cargarTagImgEmailTemplate(this.value);
            }
            this.saltarChangeInput = !this.saltarChangeInput;
        }
    }

    inputOnKeyDown(event) {
        if(event.ctrlKey && event.key === 'v'){            
            setTimeout(() => {
                this.desactivarBlurRichText();
                event.preventDefault();
            }, 0);
        }  
    }

    cerrarModalDescImagen(){
        this.showToast('Error', 'Es obligatorio añadir una descripción a la imagen', 'error');
    }

    guardarDescImagen(){
        if(this.valueTagImg != ''){
            
            const parser = new DOMParser();
            const doc = parser.parseFromString(this.latestRichTextValue, 'text/html');
            const newImage = doc.querySelector('img[data-last-added="true"]');
            
            if (newImage) {
                //Eliminar el atributo personalizado 'data-last-added'
                newImage.removeAttribute('data-last-added');
                //Guardar en el mapa el nuevo par img-tag
                this.imageAltMap.set(newImage.src, this.valueTagImg);
                //Cerrar el modal y parametrizaciones varias
                // this.saltarChangeInput = true;
                this.latestRichTextValue = doc.body.innerHTML;
                // this.value = doc.body.innerHTML;
                this.valueTagImg = '';
                this.srcNewImage = '';
                this.modalAñadirDesc = false;
                this.saltarSetMapa = true;                

                //Envío un evento al aura con el mapa de tags actualizado
                this.dispatchEvent(new CustomEvent('evtinforichtext', {
                    detail: {
                        data: this.imageAltMap
                    }
                }));
            }
        }else{
            this.showToast('Error', 'Es obligatorio añadir una descripción a la imagen', 'error');
        }
    }

    handleChangTag(event){       
        this.valueTagImg = event.target.value; 
        event.stopPropagation();
    }

    extractImages(content) {
        const parser = new DOMParser();
        const doc = parser.parseFromString(content, 'text/html');

        return Array.from(doc.querySelectorAll('img'));
    }
    
    abrirModalAlt() {
        this.modalAñadirDesc = true;

        this.desactivarBlurRichText();
    }

    desactivarBlurRichText(){
        if(!this.isOpen){
            const richTextElement = this.template.querySelector('[data-id="richText1"]');
            
            if (richTextElement) {
                richTextElement.blur();
            }
        }else{
            const richTextElement = this.template.querySelector('[data-id="richText2"]');

            if (richTextElement) {
                richTextElement.blur();
            }
        }
    }

    checkValueC() {
        //Para evitar errores, y debido a que en ciertas ocasiones al llamar a este LWC en un primer instante this.value = undefined, nos aseguramos que este cargue con el valor correcto
        if(this.value !== undefined) {
            this.previousValue = this.value;

            //Al cargar el email template inicial, debo comprobar si este tiene imagenes con etiqueta 'alt'
            this.cargarTagImgEmailTemplate(this.value);
        }else {
            setTimeout(() => {
                this.checkValueC();
            }, 1000);
        }
    }

    handleFlagCambioPlantilla() {        
        setTimeout(() => {
            if (this._flagCambioPlantilla) {               
                //Para evitar errores, y debido a que en ciertas ocasiones al llamar a este LWC en un primer instante this.value = this.previousValue (el nuevo cuerpo de la plantilla no se ha recibido), nos aseguramos que este cargue con el valor correcto
                if(this.value !== this.previousValue) {
                    this.saltarChangeInput = true;
                    this.recargoCambioP = false;
                    this.previousValue = this.value;
                    
                    //Al cambiar de email template con el botón de 'Cambiar plantilla', debo comprobar si este tiene imagenes con etiqueta 'alt'
                    this.cargarTagImgEmailTemplate(this.value);
        
                    //Envío un evento al aura para indicar que he recibido el cambio de plantilla, y que actualice el flag a false
                    this.dispatchEvent(new CustomEvent('evtflagcambioplantilla', {
                        detail: {
                            data: false
                        }
                    }));
        
                    this._flagCambioPlantilla = false;
                }
                else {
                    this.saltarChangeInput = true;
                    this.recargoCambioP = true;
                    
                    setTimeout(() => {
                        this.handleFlagCambioPlantilla();
                    }, 1000);
                }
            }
        }, 1000);
    }

    cargarTagImgEmailTemplate(cuerpo) {      

        //Buscar si la plantilla trae imagenes
        var parser = new DOMParser();
        var doc = parser.parseFromString(cuerpo, 'text/html');
        var images = Array.from(doc.querySelectorAll('img'));
        const baseUrl = doc.baseURI;       
        
        //Si se han detectado imagenes en la plantilla, las procesamos
        if(images.length > 0){            
            //Recorro las imagenes, y si tiene atributo alt la añado en el mapa de tags
            images.forEach((image) => {                
                if(image.src && image.src !== baseUrl){  //El navegador por defecto si una img viene con src='' le asigna la url base, para evitar que en caso de varias img sin src                     
                    this.imageAltMap.set(image.src, image.alt);       //el mapa se rellene con un alt erroneo, añadimos la condición 'image.src !== baseUrl'                  
                }
            });
        
            //Envío un evento al aura con el mapa de tags actualizado
            this.dispatchEvent(new CustomEvent('evtinforichtext', {
                detail: {
                    data: this.imageAltMap
                }
            }));
        }
    }

    showToast(title, message, type) {
        const event = new ShowToastEvent({
            title: title,
            message: message,
            variant: type
        });
        this.dispatchEvent(event);
    }
}