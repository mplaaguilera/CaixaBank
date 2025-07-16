import { LightningElement, api, wire, track } from 'lwc';
import { RefreshEvent } from 'lightning/refresh';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getRecord} from 'lightning/uiRecordApi';

import recuperarDirectorioRaiz from '@salesforce/apex/SAC_LCMP_RecuperarPlantillas.recuperarDirectorioRaiz';
import cambioCarpeta from '@salesforce/apex/SAC_LCMP_RecuperarPlantillas.cambioCarpeta';
import volverHaciaArriba from '@salesforce/apex/SAC_LCMP_RecuperarPlantillas.volverHaciaArriba';
import obtenerDatosTemplate from '@salesforce/apex/SAC_LCMP_RecuperarPlantillas.obtenerDatosTemplate';
import buscarPlantillas from '@salesforce/apex/SAC_LCMP_RecuperarPlantillas.buscarPlantillas';
import validarPretensiones from '@salesforce/apex/SAC_LCMP_RecuperarPlantillas.validarPretensiones';

//Campos reclamación
import IDIOMA_FIELD from '@salesforce/schema/Case.CC_Idioma__c';
import RECORDTYPE_FIELD from '@salesforce/schema/Case.RecordTypeId';
import ENTIDAD_AFECTADA_FIELD from '@salesforce/schema/Case.SAC_Entidad_Afectada__c';


const fields = [IDIOMA_FIELD, RECORDTYPE_FIELD, ENTIDAD_AFECTADA_FIELD];

export default class Sac_RecuperarPlantillasRedaccion extends LightningElement {
    // Variable que se comunica con el lwc sAC_GeneracionDocumento
    @api cambiarPlantilla = false;

    // Variable que se comunica con el aura SAC_DocumentoRedaccion
    @api carpetaRaiz;
    @api botonDisabled;

    @api recordId;

    // Variables generales
    @track abrirModalPlantillas = false;
    @track idCarpetaRaiz;
    @track nombreCarpetaRaiz;
    @track idPadre;
    @track items = [];
    @track ruta = [];
    @track noEsPlantilla = true;
    @track puedeVolver = true;
    @track cuerpoPlantilla;
    @track headerPlantilla;
    @track footerPlantilla;
    @track llamarLWCEdicion = false;
    @track mostrarDirectorio = true;
    @track spinnerLoading = false;
    @track aplicado = false;

    @track mensajeNoResultados = false;
    @track mensajeBusqueda = false;

    @track itemsBusqueda = [];
    @track valorBusqueda;

    @track caso;
    @track idiomaReclamacion = '';
    @track recordTypeCaso;
    @track entAfectada = '';


    //Se obtiene cuál es el idioma del caso
    @wire(getRecord, { recordId: '$recordId', fields })
    wiredCase({error, data}){
        if(data){
            this.caso = data;
            this.idiomaReclamacion = data.fields.CC_Idioma__c.value;
            this.recordTypeCaso = data.fields.RecordTypeId.value;
            this.entAfectada = data.fields.SAC_Entidad_Afectada__c.value;
        }
    }

    // Se obtiene los datos de la carpeta Raiz
    @wire(recuperarDirectorioRaiz, {carpetaRaiz: '$carpetaRaiz'}) 
    directorioRaiz({ error, data }) {
        if(data){   
            let nombrePadre = '';
		    let idDelPadre = '';
            let plantillas = JSON.parse(data.elementosDirectorio);
            this.idCarpetaRaiz = data.carpetaRaiz.Id;
            this.nombreCarpetaRaiz = data.carpetaRaiz.Name;

            for(var miPlantilla in plantillas) {
                let plantilla = plantillas[miPlantilla];
                nombrePadre = plantilla.labelParent;
                idDelPadre = plantilla.idParent;
            }
            this.ruta.push({ label: nombrePadre, value: idDelPadre });
            this.items = plantillas;

        }
        if(error){
			this.mostrarToast('error', 'ERROR', JSON.stringify(error));
        }        
    };


    selectorArbol(event) {
        this.spinnerLoading = true;
        this.mensajeBusqueda = false;
        this.mensajeNoResultados = false;
        this.idPlantilla = event.target.name;
        let nombrePadre = '';
		let idDelPadre = event.target.name;

        if(this.idPlantilla.substring(0, 3) == '00l') {
            this.noEsPlantilla = true;
            this.idPadre = event.target.name;

            this.mostrarDirectorio = true;
            if(this.idPlantilla != this.idCarpetaRaiz) {
                this.puedeVolver = false;
            } else {
                this.puedeVolver = true;
            }
            cambioCarpeta({idPadre: this.idPlantilla}).then(result => {              
                if(result){
                    let plantillas = JSON.parse(result);
					for(var miPlantilla in plantillas) {
						let plantilla = plantillas[miPlantilla];
						nombrePadre = plantilla.labelParent;
						idDelPadre = plantilla.idParent;
					}

					let copyOfRuta = this.ruta;
					this.ruta = [];
					let comparador = true;
					for(var nodo in copyOfRuta) {
						let elemento = copyOfRuta[nodo];
						if(comparador){
							this.ruta.push({ label: elemento.label, value: elemento.value });
						}
						else{ break; }

						if(elemento.value == idDelPadre){
							comparador = false;
						}
						
					}

                    this.items = plantillas;
                    this.spinnerLoading = false;
                }
            })
            .catch(error => {
                this.spinnerLoading = false;
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error',
                        message: 'Error al obtener la carpeta seleccionada',
                        variant: 'error'
                    })
                ); 
                this.dispatchEvent(new RefreshEvent());
            })   
        } else {
			this.spinnerLoading = false;
			this.noEsPlantilla = false;
		}
    }


    handleSelect(event) {
        this.spinnerLoading = true;
        this.mensajeBusqueda = false;
        this.mensajeNoResultados = false;
        this.idPlantilla = event.target.name;
        let nombrePadre = '';
		let idDelPadre = event.target.name;


        if(this.idPlantilla.substring(0, 3) == '00l') {
            this.noEsPlantilla = true;
            this.idPadre = event.target.name;
            if(this.idPlantilla != this.idCarpetaRaiz) {
                this.puedeVolver = false;
            } else {
                this.puedeVolver = true;
            }
            cambioCarpeta({idPadre: this.idPlantilla}).then(result => {              
                if(result){
                    let plantillas = JSON.parse(result);
					for(var miPlantilla in plantillas) {
						let plantilla = plantillas[miPlantilla];
						nombrePadre = plantilla.labelParent;
						idDelPadre = plantilla.idParent;
					}
                    this.ruta.push({ label: nombrePadre, value: idDelPadre });
                    this.items = plantillas;
                    this.spinnerLoading = false;
                }
            })
            .catch(error => {
                this.spinnerLoading = false;
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error',
                        message: 'Error al obtener la carpeta seleccionada',
                        variant: 'error'
                    })
                ); 
                this.dispatchEvent(new RefreshEvent());
            })   
        } else {
			this.spinnerLoading = false;
			this.noEsPlantilla = false;
		}
    }


    botonVolver(event) {
        this.spinnerLoading = true;
        this.noEsPlantilla = true;

        if(this.idCarpetaRaiz != this.idPadre) {
            volverHaciaArriba({idPadre: this.idPadre}).then(result => {              
                if(result){
                    let plantillas = JSON.parse(result);
					for(var miPlantilla in plantillas) {
						let plantilla = plantillas[miPlantilla];
						this.idPadre = plantilla.idParent;
					}

                    this.ruta.pop();
                    this.items = plantillas;
                    this.spinnerLoading = false;
                    if(this.idCarpetaRaiz === this.idPadre) {
                        this.puedeVolver = true;
                    }
                }
            })
            .catch(error => {
                this.spinnerLoading = false;
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error',
                        message: 'Error al volver a la anterior ruta',
                        variant: 'error'
                    })
                ); 
                this.dispatchEvent(new RefreshEvent());
            })   
        } else {
            this.puedeVolver = true;
            this.spinnerLoading = false;
        }
    }


    botonAplicar(event) {
        this.spinnerLoading = true;
        this.noEsPlantilla = true;
        if(this.idPlantilla.substring(0, 3) != '00X') {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Elemento seleccionado invalido',
                    message: 'Seleccione una plantilla, y no una carpeta.',
                    variant: 'error'
                })
            ); 
            this.dispatchEvent(new RefreshEvent());
		}
		else {
            obtenerDatosTemplate({'idTemplate': this.idPlantilla, 'idObject': this.recordId, 'idioma': this.idiomaReclamacion, 'recordType' : this.recordTypeCaso, 'entidadAfectada' : this.entAfectada}).then(result => {              
                if(result){
                    this.cuerpoPlantilla = result.cuerpo;
                    this.headerPlantilla = result.header;
                    this.footerPlantilla = result.footer;

                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Cambio aplicado',
                            message: 'Se ha sustituido el cuerpo del email con el valor de la plantilla.',
                            variant: 'success'
                        })
                    ); 
                    this.dispatchEvent(new RefreshEvent());
                    if(this.llamarLWCEdicion) {
                        this.aplicado = true;
                    }

                    this.llamarLWCEdicion = true;
                    this.cerrarModalPlantillas();
                    this.spinnerLoading = false;

                    // Se manda la información de la plantilla seleccionada al cambiar la plantilla al componente sAC_GeneracionDocumento
                    if(this.cambiarPlantilla) {
                        //Custom event en el que se manda la info que queremos enviar al componente padre
                        const sendDataEvent = new CustomEvent('eventoaplicar', {
                            detail: result
                        });
                
                        //Hacemos el dispatch event del evento que hemos creado
                        this.dispatchEvent(sendDataEvent);
                    }
                }
            })
            .catch(error => {
                this.spinnerLoading = false;
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error',
                        message: 'Error al obtener los datos de la plantillas',
                        variant: 'error'
                    })
                ); 
                this.dispatchEvent(new RefreshEvent());
            })   
        }
    }


    mostrarModalPlantillas() {
        this.spinnerLoading = true;

        if(this.cambiarPlantilla) {
            this.spinnerLoading = false;
            this.abrirModalPlantillas = true;
        } else {
            validarPretensiones({idCaso: this.recordId}).then(result => {    
                if(result) {
                    this.spinnerLoading = false;
                    this.abrirModalPlantillas = true;
                } else {
                    this.spinnerLoading = false;
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: "Error al preparar la documentación",
                            message: 'No todas las pretensiones están listas para la redacción final.', 
                            variant: 'error'
                        })
                    ); 
                }
            })
            .catch(error => {
                this.spinnerLoading = false;
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: "Error",
                        message: 'Error al comprobar si las pretensiones están listas para la redacción final.', 
                        variant: 'error'
                    })
                ); 
                this.dispatchEvent(new RefreshEvent());
            })  
        }  
    }

    cerrarModalPlantillas() {
        this.abrirModalPlantillas = false;
        this.noEsPlantilla = true;
        this.itemsBusqueda = [];
        this.valorBusqueda = '';
        this.mostrarDirectorio = true;
    }


    handleEnter(evt) {
        this.spinnerLoading = true;
        const isEnterKey = evt.keyCode === 13;
        if(isEnterKey && evt.target.value.length < 3) {
            this.itemsBusqueda = [];
            this.mensajeBusqueda = true;
            this.mensajeNoResultados = false;
            this.spinnerLoading = false;
            this.mostrarDirectorio = false;
            this.puedeVolver = true;
        } else if(isEnterKey && evt.target.value.length >= 3) {
            this.mensajeBusqueda = false;
            this.valorBusqueda = evt.target.value;
            buscarPlantillas({valorBusqueda: this.valorBusqueda, idCarpeta: this.idCarpetaRaiz, nombreCarpeta: this.nombreCarpetaRaiz}).then(result => {              
                if(result){
                    let plantillas = JSON.parse(result);
                    if(plantillas.length === 0) {
                        this.mensajeNoResultados = true;
                    } else {
                        this.mensajeNoResultados = false;
                    }
					for(var miPlantilla in plantillas) {
						let plantilla = plantillas[miPlantilla];
					}

                    this.itemsBusqueda = plantillas;
                    this.mostrarDirectorio = false;
                    this.puedeVolver = true;

                    this.spinnerLoading = false;
                }
            })
            .catch(error => {
                this.spinnerLoading = false;
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error',
                        message: 'Error al obtener las plantillas buscadas',
                        variant: 'error'
                    })
                ); 
                this.dispatchEvent(new RefreshEvent());
            })   
        }
    }

    handleEventoGuardado(event){
        let dataToSend = true;
        //Custom event en el que se manda la info que queremos enviar al componente padre
            const sendDataEvent = new CustomEvent('senddataguardado', {
            detail: {dataToSend}
        });

        //Hacemos el dispatch event del evento que hemos creado
        this.dispatchEvent(sendDataEvent);
    }

    handleEventoGenerar(event){
        let dataToSend = true;
        //Custom event en el que se manda la info que queremos enviar al componente padre
            const sendDataEvent = new CustomEvent('senddatagenerar', {
            detail: {dataToSend}
        });

        //Hacemos el dispatch event del evento que hemos creado
        this.dispatchEvent(sendDataEvent);
    }

    mostrarToast(tipo, titulo, mensaje) {
		this.dispatchEvent(new ShowToastEvent({
			variant: tipo, title: titulo, message: mensaje, mode: 'dismissable', duration: 4000
		}));
	}
}