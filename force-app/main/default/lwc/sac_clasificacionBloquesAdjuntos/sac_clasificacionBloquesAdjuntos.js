import { LightningElement, api, wire, track } from 'lwc';
import { getObjectInfo } from "lightning/uiObjectInfoApi";
import { getPicklistValues } from "lightning/uiObjectInfoApi";
import { getRecord, getFieldValue} from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import CONTENTVERSION_OBJECT from "@salesforce/schema/ContentVersion";
import CASENUMBER from '@salesforce/schema/Case.CaseNumber';
import NUMEXPSPV from '@salesforce/schema/Case.SPV_NumExpediente__c';
import SAC_BLOQUE_FIELD from "@salesforce/schema/ContentVersion.SAC_Bloque__c";
import cambiarClasificacionApex from '@salesforce/apex/SAC_LCMP_GestionAdjuntosGlobal.cambiarClasificacion';
import recuperaTipoAdjuntosApex from '@salesforce/apex/SAC_LCMP_GestionAdjuntosGlobal.recuperaTipoAdjuntos';
import asignarTipoAdjuntoApex from '@salesforce/apex/SAC_LCMP_GestionAdjuntosGlobal.asignarTipoAdjunto';
import cambiarTituloFichero from '@salesforce/apex/SAC_LCMP_GestionAdjuntosGlobal.cambiarTituloFichero';



const fields = [CASENUMBER, NUMEXPSPV];
export default class Sac_clasificacionBloquesAdjuntos extends LightningElement {
    @api recordId;
    @api objectApiName;
    @api fichero;
    @api bloqueAcordeon;
    @api mostrarOculto;
    @api esUserGeneral;
    @api esRecAsociadaASPV;
    @api recordTypeRegistro;
    @track recordTypeId;
    @track sacBloqueValues;
    @track modalClasificar = false;
    @track selectedFichero;
    @track disableButtons;
    @track opcionesBloquesFichero;
    @track opcionesBloquesSeleccionadas;
    @track esRespuesta;

    
    bloqueContieneElFichero;
    ContentDocumentId;
    mostrarGrupos;
    formatoHoras12 = false;
    opcionesMaestroAdjuntos;
    opcionesMaestroAdjuntosBackup = [];  //Copia de seguridad para el filtrado de tipo documentos
    resultadoEncontrado = true;
    mensaje = '';
    nombreTipoAdjunto = '';
    
    
    @wire(getRecord, { recordId: '$recordId', fields })
    case;

    get caseNumberReclamacion() {
        return getFieldValue(this.case.data, CASENUMBER);
    }

    get numExpRecSPV() {
        return getFieldValue(this.case.data, NUMEXPSPV);
    }

    @wire(getObjectInfo, { objectApiName: CONTENTVERSION_OBJECT })
    objectInfo({data}) {
        if (data) {
            this.recordTypeId = data.defaultRecordTypeId;
        }
    }

    @wire(getPicklistValues, { recordTypeId: '$recordTypeId', fieldApiName: SAC_BLOQUE_FIELD })
    valoresPicklistSAC_Bloque__c({data}) {
        if (data) {
            this.sacBloqueValues = data.values;
            if (this.fichero && this.bloqueAcordeon) {
                if(this.bloqueAcordeon == 'SAC_Respuesta'){
                    this.esRespuesta = true;
                }else{
                    this.esRespuesta = false;
                }
                if (this.fichero.SAC_Bloque__c) {
                    // Convertir el campo multipicklist en un array de strings
                    const sacBloqueArray = this.fichero.SAC_Bloque__c.split(';');
                    // Verificar si el array contiene el valor de bloqueAcordeon
                    if (sacBloqueArray.includes(this.bloqueAcordeon)) {
                        this.bloqueContieneElFichero = true;
                        //Guardar los valores que contiene el campo en una lista
                        this.opcionesBloquesFichero = sacBloqueArray;
                        this.opcionesBloquesSeleccionadas = this.opcionesBloquesFichero;
                    } else {
                        this.bloqueContieneElFichero = false;
                    }
                }
            }
            if (data && this.fichero && this.fichero.SAC_TipoAdjunto__r) {
                this.nombreTipoAdjunto = this.fichero.SAC_TipoAdjunto__r.Name;
            }
        }
    }

    get mostrarOcultoOrFileVisible() {
        return this.mostrarOculto || this.fichero.SAC_Oculto__c === false;
    }

    ficheroSeleccionado(event) {
        let id = event.currentTarget.id;

        // Comprueba si el id contiene un guion seguido de uno o más números
        let regex = /-(\d+)$/;
        let match = id.match(regex);

        if (match) {
            // Si se encuentra un guion seguido de uno o más números, se guarda solo la parte a la izquierda del guion
            id = id.split(match[0])[0];
        }
        this.ContentDocumentId = id;
        this.mostrarGrupos = false;

        const mostrarMiniaturaDocumentoEvent = new CustomEvent('mostrarminiaturadocumento', {
            detail: {
                contentDocId: this.ContentDocumentId
            }
        });
        this.dispatchEvent(mostrarMiniaturaDocumentoEvent);
    }

    abrirModalClasificar(event) {
        this.modalClasificar = true;
        this.selectedFichero = event.target.value;
    }

    cerrarModalClasificar(event) {
        this.modalClasificar = false;
        this.opcionesBloquesSeleccionadas = [];
    }

    handleChangeClasificado(event) {
        // Obtener los valores seleccionados del evento
        const selectedValues = event.detail.value;
        this.opcionesBloquesSeleccionadas = selectedValues;
    }

    handleChangeValidar(event) {
        let idFichero = event.target.value;
        let nameFichero = event.target.name;
        let validado = event.target.checked;

        if(this.recordTypeRegistro.startsWith('SPV')){
            if (event.target.name.startsWith(this.numExpRecSPV) && validado == false) {
                // Realiza la lógica adicional aquí
                cambiarTituloFichero({idAdjunto: idFichero, titulo: nameFichero, prefijo: this.numExpRecSPV, validadoCV : validado})
                .then(()=>{
                    this.showToast("Fichero desvalidado", "Se ha desvalidado el fichero con la reclamación", "success");
                    // Lanzar evento al componente padre para que refresque la vista
                    const actualizarVistaEvent = new CustomEvent('actualizarvista');
                    this.dispatchEvent(actualizarVistaEvent);
                })
                .catch(error => {
                    this.showToast("Error", error.body.pageErrors[0].message, "error");
                    // Lanzar evento al componente padre para que refresque la vista
                    const actualizarVistaEvent = new CustomEvent('actualizarvista');
                    this.dispatchEvent(actualizarVistaEvent);
                });
    
            } else if(!event.target.name.startsWith(this.numExpRecSPV) && validado == true) {
                // Realiza otra lógica aquí si es necesario
                cambiarTituloFichero({idAdjunto: idFichero, titulo: nameFichero, prefijo: this.numExpRecSPV, validadoCV : validado})
                .then(()=>{
                    this.showToast("Fichero validado", "Se ha validado el fichero con la reclamación", "success");
                    // Lanzar evento al componente padre para que refresque la vista
                    const actualizarVistaEvent = new CustomEvent('actualizarvista');
                    this.dispatchEvent(actualizarVistaEvent);
                })
                .catch(error => {
                    this.showToast("Error", error.body.pageErrors[0].message, "error");
                    // Lanzar evento al componente padre para que refresque la vista
                    const actualizarVistaEvent = new CustomEvent('actualizarvista');
                    this.dispatchEvent(actualizarVistaEvent);
                });
    
            }
        }else{
            if (event.target.name.startsWith(this.caseNumberReclamacion) && validado == false) {
                // Realiza la lógica adicional aquí
                cambiarTituloFichero({idAdjunto: idFichero, titulo: nameFichero, prefijo: this.caseNumberReclamacion, validadoCV : validado})
                .then(()=>{
                    this.showToast("Fichero desvalidado", "Se ha desvalidado el fichero con la reclamación", "success");
                    // Lanzar evento al componente padre para que refresque la vista
                    const actualizarVistaEvent = new CustomEvent('actualizarvista');
                    this.dispatchEvent(actualizarVistaEvent);
                })
                .catch(error => {
                    this.showToast("Error", error.body.pageErrors[0].message, "error");
                    // Lanzar evento al componente padre para que refresque la vista
                    const actualizarVistaEvent = new CustomEvent('actualizarvista');
                    this.dispatchEvent(actualizarVistaEvent);
                });
    
            } else if(!event.target.name.startsWith(this.caseNumberReclamacion) && validado == true) {
                // Realiza otra lógica aquí si es necesario
                cambiarTituloFichero({idAdjunto: idFichero, titulo: nameFichero, prefijo: this.caseNumberReclamacion, validadoCV : validado})
                .then(()=>{
                    this.showToast("Fichero validado", "Se ha validado el fichero con la reclamación", "success");
                    // Lanzar evento al componente padre para que refresque la vista
                    const actualizarVistaEvent = new CustomEvent('actualizarvista');
                    this.dispatchEvent(actualizarVistaEvent);
                })
                .catch(error => {
                    this.showToast("Error", error.body.pageErrors[0].message, "error");
                    // Lanzar evento al componente padre para que refresque la vista
                    const actualizarVistaEvent = new CustomEvent('actualizarvista');
                    this.dispatchEvent(actualizarVistaEvent);
                });
    
            }
        }
    }

    cambiarClasificacionFichero() {
        this.disableButtons = true;

        cambiarClasificacionApex({
            idAdjunto: this.selectedFichero.Id,
            listaValoresBloque: this.opcionesBloquesSeleccionadas
        })
        .then(result => {
            this.showToast("Clasificación modificada", "Se ha modificado el bloque del fichero", "success");
            this.opcionesBloquesSeleccionadas = [];
            this.modalClasificar = false;
            this.disableButtons = false;
            // Lanzar evento al componente padre para que refresque la vista
            const actualizarVistaEvent = new CustomEvent('actualizarvista');
            this.dispatchEvent(actualizarVistaEvent);
        })
        .catch(error => {
            this.showToast("Error", error.body.pageErrors[0].message, "error");

            this.opcionesBloquesSeleccionadas = [];
            this.modalClasificar = false;
            this.disableButtons = false;
            // Lanzar evento al componente padre para que refresque la vista
            const actualizarVistaEvent = new CustomEvent('actualizarvista');
            this.dispatchEvent(actualizarVistaEvent);
        });
    }

    showToast(title, message, type) {
        const event = new ShowToastEvent({
            title: title,
            message: message,
            variant: type
        });
        this.dispatchEvent(event);
    }

    get tieneTipoAdjunto() {
        return this.fichero && this.fichero.SAC_TipoAdjunto__r && this.fichero.SAC_TipoAdjunto__r.Name !== '';
    }

    handleBlur(event) {
        this.mostrarGrupos = false;
    }
    
    mostrarOpciones(event) {
        // Lógica para mostrar las opciones cuando se hace clic en el primer input (onclick)
        recuperaTipoAdjuntosApex({
            id: ''
        })
        .then(result => {
            this.opcionesMaestroAdjuntos = result;
            if (this.opcionesMaestroAdjuntos != null) {
                this.mostrarGrupos = true;
                this.mensaje = '';
            }
        })
        .catch(error => {
            this.showToast('Error', 'Error al recuperar los maestros de temas de tipo adjunto', 'error');
        });
    }
    
    filtroBusqueda(event) {
        // Lógica para filtrar la búsqueda (onkeyup)

        //Si la lista de copia de seguridad está vacía, la informo con las opciones de tipos de adjuntos
        if(this.opcionesMaestroAdjuntosBackup.length === 0) {
            this.opcionesMaestroAdjuntosBackup = this.opcionesMaestroAdjuntos.slice();
        }

        const inputBusqueda = event.target.value;
        
        //Trabajo con la copia de seguridad, y filtro en ella el valor de entrada
        const resultadosFiltrados = this.opcionesMaestroAdjuntosBackup.filter(item => {
            return item.Name.toLowerCase().includes(inputBusqueda.toLowerCase());                                     
        });

        if(resultadosFiltrados.length > 0){
            //Almaceno en las opciones de adjuntos los valores filtrados para mostrarlos correctamente en el front
            this.resultadoEncontrado = true;
            this.opcionesMaestroAdjuntos = resultadosFiltrados;  
        }else{
            //Muestro mensaje de resultados no encontrados
            this.resultadoEncontrado = false;
            this.mensaje = 'No hay resultados para "' + inputBusqueda + '".';
        }
    }
    
    seleccionarGrupo(event) {
        // Realizar acciones con el elemento, por ejemplo, mostrar el ID en la consola
        let listFicherosAdjuntos = [];
        listFicherosAdjuntos.push(this.fichero);
        let optionIndex = event.currentTarget.dataset.index; // Recupera el índice del objeto clicado
        let maestroAdjuntosClicado = this.opcionesMaestroAdjuntos[optionIndex]; // Obtiene el objeto correspondiente en la lista opcionesMaestroAdjuntos
        asignarTipoAdjuntoApex({
            idAdjunto: this.fichero.Id,
            ficherosAdjuntos: listFicherosAdjuntos,
            maestroAdjuntos: maestroAdjuntosClicado
        })
        .then(result => {
            // Lanzar evento al componente padre para que refresque la vista
            const actualizarVistaEvent = new CustomEvent('actualizarvista');
            this.dispatchEvent(actualizarVistaEvent);
        })
        .catch(error => {
            this.showToast('Error', 'Error al recuperar los maestros de temas de tipo adjunto', 'error');
        });
    }

}