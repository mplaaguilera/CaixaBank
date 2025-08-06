import { LightningElement, api, wire, track } from 'lwc';
import { getRecord, getFieldValue} from 'lightning/uiRecordApi';
import compruebaCartaPrevia from '@salesforce/apex/SAC_LCMP_GeneracionCartaPostal.compruebaCartaPrevia';
import getRuta from '@salesforce/apex/SAC_LCMP_GeneracionCartaPostal.getRuta';
import getRutaVS from '@salesforce/apex/SAC_LCMP_GeneracionCartaPostal.getRutaVS';
import insertarimagen from '@salesforce/apex/SAC_LCMP_GeneracionCartaPostal.insertarimagen';
import getHeaderAndFooterMTP from '@salesforce/apex/SAC_LCMP_GeneracionCartaPostal.getHeaderAndFooterMTP';


import { RefreshEvent } from 'lightning/refresh';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

//Campos reclamación
import IDIOMA_FIELD from '@salesforce/schema/Case.CC_Idioma__c';
import RECORDTYPE_FIELD from '@salesforce/schema/Case.RecordType.DeveloperName';
import RECORDTYPEID_FIELD from '@salesforce/schema/Case.RecordTypeId';
import ENTIDAD_AFECTADA_FIELD from '@salesforce/schema/Case.SAC_Entidad_Afectada__c';

const fields = [IDIOMA_FIELD, RECORDTYPE_FIELD, ENTIDAD_AFECTADA_FIELD, RECORDTYPEID_FIELD];
export default class SAC_GeneracionDocumento extends LightningElement {

    // @track idRedaccion;
    @track iteracionRefresco = 0;
    @track act;
    @track ruta;
    @track rutaVS;
    @track rutaRespuesta;
    @track idCarta;
    @track isProgressing = false;
    @track progress = 0;
    @track casoId;
    // @track botonGenerar = true;
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
    @api nombreTitular;
    @api direccionTotal;
    @api direccion;
    @api provincia;
    @api poblacion;
    @api paisSeleccionado;
    @api paisValue;
    @api codigoPostal;
    @api plantilla;
    @api procedencia;
    @api cuerpo;
    // @api cuerpoPrevio;
    @api mostrarEdicion = false;
    @api ocultarBoton = false;
    @api llamadaPlantillas = false;
    @api footer;
    @api header;
    @api botonDisabled;
    @api reenvio = false; // Esta variable decide el texto del botón

    @track hayCartaPendiente = false;
    @track edicionEnvio = false;
    @track habilitado = false;

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
                this.carpetaRaiz = 'PlantillasSPV';
            } else {
                this.carpetaRaiz = 'PlantillasSAC';
            }
        }
    }

    handleSubmit(event){    
        event.preventDefault(); 
        getHeaderAndFooterMTP({ idioma: this.idiomaReclamacion, entidadAfectada : this.entidadAfectadaReclamacion, recordType: this.recordTypeId})
            .then((result) => {
                    this.headerMTP = result.header;
                    this.footerMTP = result.footer;

                    const fields = event.detail.fields;
                    fields.SAC_Direccion__c = this.direccion;
                    fields.SAC_Poblacion__c = this.poblacion;
                    fields.SAC_Provincia__c = this.provincia;
                    fields.SAC_CodigoPostal__c = this.codigoPostal;
                    fields.SAC_Pais__c = this.paisSeleccionado;
                    
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

        this.idCarta = myRecordId;
        this.iteracionRefresco += 1;
        this.act = `&n=${this.iteracionRefresco}`;
        this.isProgressing = false;
        clearInterval(this._interval);
        this.progress = 0;
        getRuta({}).then(result => {
            if(result){
                this.ruta = 'https://' + result + '/apex/SAC_CartaPDF?id=' + this.idCarta + this.act;
            }
        });
    }

    abrirEdicion(){
        this.mostrarEdicion = true;
        compruebaCartaPrevia({'caseId': this.recordId, 'tipoCarta': this.procedencia }).then(result => {
            if(result){ 

                // Si existe contenido previo, lo asignamos
                if (result.docPDF && result.docPDF.trim() !== "") {
                    this.cuerpo = result.docPDF.replace(/(<br\s*\/?>\s*){2}|<br\s*\/?>&nbsp;/gi, '</p><p>');
                } else {
                    if(this.plantilla != null && this.plantilla != '') {
                        this.cuerpo = this.plantilla.replace(/(<br\s*\/?>\s*){2}|<br\s*\/?>&nbsp;/gi, '</p><p>');
                    }
                }            

                this.footer = result.footer;
                this.header = result.header;

                getRuta({}).then(rutaResult => {
                    if (rutaResult) {
                        
                        this.rutaVS = 'https://' + rutaResult + '/apex/SAC_EditorHTMLPlantillasCarta?id=' + this.recordId + '&procedencia=' + this.procedencia;

                        // Esperamos a que el iframe esté disponible antes de enviar el contenido
                        setTimeout(() => {
                            let vfWindow = this.template.querySelector("iframe")?.contentWindow;
                            if (vfWindow) {
                                vfWindow.postMessage({ datos: this.cuerpo, origen: "cuerpo" }, this.rutaVS);
                            }
                        }, 2000); // Retraso para asegurar carga
                    }
                });

            }
        });
    }
    
    cerrarEdicion() {
        this.mostrarEdicion = false;        

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

    handleEventoAplicar(event){
        this.header = event.detail.header;
        this.cuerpo = event.detail.cuerpo.replace(/(<br\s*\/?>\s*){2}|<br\s*\/?>&nbsp;/gi, '</p><p>');
        this.footer = event.detail.footer;

        this.callVFPageMethod();
    }

    handleEventoAbierto(event){
        this.mostrarEdicion = true;
    }    

    handleInputChange(event) {        
        const field = event.target.name;        
        this[field] = event.target.value;
    }
 
    connectedCallback() {
        if(this.llamadaPlantillas && !this.realizadaPrimeraLlamada) {
            this.realizadaPrimeraLlamada = true;

            getRuta({}).then(result => {
                if(result){
                    this.rutaVS = 'https://' + result + '/apex/SAC_EditorHTMLPlantillasCarta?id=' + this.recordId + '&procedencia=' + this.procedencia;
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
        
        // Lógica de inicio
        compruebaCartaPrevia({ caseId: this.recordId, tipoCarta: this.procedencia })
        .then(response => {            
            if (response.idCarta != null && response.idCarta != "") {
                this.hayCartaPendiente = true;
            }
            this.idCarta = response.idCarta;
            // this.urlVisFo = response.urlVF;
            this.direccion = response.direccion;
            this.codigoPostal = response.cp;
            this.poblacion = response.poblacion;
            this.provincia = response.provincia;
            this.paisSeleccionado = response.pais;

            let paises = response.opcionesPais;


            this.options = paises.map(pais => ({ label: pais.nombrePlantilla, value: pais.idPlantilla }));

            // Comprobar si paisSeleccionado es igual a algún pais.nombrePlantilla
            const paisEncontrado = this.options.find(pais => pais.label.toLowerCase() === this.paisSeleccionado.toLowerCase() || pais.value === this.paisSeleccionado);
            if (paisEncontrado) {
                this.paisSeleccionado = paisEncontrado.value;
            }else{
                this.paisSeleccionado = '000';
            }

            this.cuerpo = response.cuerpo;

            let dirTotal = '';
            if (this.direccion) {
                dirTotal = this.direccion;
            }
            if (this.codigoPostal) {
                dirTotal = dirTotal ? `${dirTotal}, ${this.codigoPostal}` : this.codigoPostal;
            }
            if (this.poblacion) {
                dirTotal = dirTotal ? `${dirTotal}, ${this.poblacion}` : this.poblacion;
            }
            if (this.provincia) {
                dirTotal = dirTotal ? `${dirTotal}, ${this.provincia}` : this.provincia;
            }
            if (this.paisSeleccionado) {
                dirTotal = dirTotal ? `${dirTotal}, ${this.paisSeleccionado}` : this.paisSeleccionado;
            }
            this.direccionTotal = dirTotal;

            if (this.direccion && this.poblacion && this.provincia && this.codigoPostal) {
                this.habilitado = true;
            }
        })
        .catch(error => {
            this.showToast('Error', 'El PDF no ha sido cargado.', 'error');
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
                this.rutaVS = result + this.recordId + '&procedencia=' + this.procedencia;
            }
        });   
        setTimeout(() => {
            var vfWindow = this.template.querySelector("iframe").contentWindow;
            var parametros = {datos : this.cuerpo, origen: "cuerpo"}
                
            vfWindow.postMessage(parametros, this.rutaVS);
        }, 2000);
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

    cargarPorDefecto() {
        
        this.cuerpo = this.plantilla.replace(/(<br\s*\/?>\s*){2}|<br\s*\/?>&nbsp;/gi, '</p><p>');

        getRuta({}).then(rutaResult => {
            if (rutaResult) {
                this.rutaVS = 'https://' + rutaResult + '/apex/SAC_EditorHTMLPlantillasCarta?id=' + this.recordId + '&procedencia=' + this.procedencia;

                // Esperamos a que el iframe esté disponible antes de enviar el contenido
                setTimeout(() => {
                    let vfWindow = this.template.querySelector("iframe")?.contentWindow;
                    if (vfWindow) {
                        vfWindow.postMessage({ datos: this.cuerpo, origen: "cuerpo" }, this.rutaVS);
                    } 
                }, 2000); // Retraso para asegurar carga
            }
        });
    }

    mostrarEdicionEnvio() {
        if (this.edicionEnvio) {
            // Guardar los datos de dirección de la carta
            this.template.querySelector('lightning-record-edit-form').submit();
            let direccionCarta = this.direccion;
            let poblacionCarta = this.poblacion;
            let provinciaCarta = this.provincia;
            // let paisCarta = this.paisSeleccionado;
            let codigoPostalCarta = this.codigoPostal;

            if (direccionCarta && poblacionCarta && provinciaCarta && codigoPostalCarta) {
                this.habilitado = true;
            } else {
                this.habilitado = false;
            }

            this.edicionEnvio = false;
            this.showToast('Datos actualizados.', 'Los datos de dirección postal de la carta han sido modificados.', 'success');
        } else {
            this.edicionEnvio = true;
        }
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
                            this.rutaVS = result + this.recordId + '&procedencia=' + this.procedencia;
                        }
                    });   
                    
                    setTimeout(() => {
                        var vfWindow = this.template.querySelector("iframe").contentWindow;
                        var parametros = {datos : this.rutaimagen, origen: "imagen"}
                            
                        vfWindow.postMessage(parametros, this.rutaVS);

                        this.modalAñadirDesc = false;
                        this.disabledInsertImg = false;                        
                        this.flagImgInsert = true;
                    }, 1000);        
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

    get edicionEnvioLabel() {
        return this.edicionEnvio ? 'Guardar datos de envío' : 'Modificar datos de envío';
    }

    get botonLabel() {        
        return this.hayCartaPendiente ? 'Continuar edición' : 'Crear Carta';
    }
}