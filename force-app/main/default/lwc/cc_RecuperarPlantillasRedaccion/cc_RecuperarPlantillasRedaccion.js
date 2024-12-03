import { LightningElement, api, wire, track } from 'lwc';
import { RefreshEvent } from 'lightning/refresh';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

import recuperarDirectorioRaiz from '@salesforce/apex/CC_RecuperarPlantillas.recuperarDirectorioRaiz';
import cambioCarpeta from '@salesforce/apex/CC_RecuperarPlantillas.cambioCarpeta';
import volverHaciaArriba from '@salesforce/apex/CC_RecuperarPlantillas.volverHaciaArriba';
import obtenerDatosTemplate from '@salesforce/apex/CC_RecuperarPlantillas.obtenerDatosTemplate';
import buscarPlantillas from '@salesforce/apex/CC_RecuperarPlantillas.buscarPlantillas';

//import obtenerTemplateSubject from '@salesforce/apex/CC_RecuperarPlantillas.obtenerTemplateSubject';


export default class CC_RecuperarPlantillas extends LightningElement {
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
    //@track subjectPlantilla;
    @track llamarLWCEdicion = false;

    @track mensajeNoResultados = false;
    @track mensajeBusqueda = false;

    @track itemsBusqueda = [];
    @track valorBusqueda;

    // quitar
    @track mostrarDirectorio = true;

    // Se obtiene los datos de la carpeta Raiz
    // @wire(recuperarDirectorioRaiz, {carpetaRaiz: '$carpetaRaiz'}) 
    // directorioRaiz({ error, data }) {
    //     if(data){   
    //         //console.log('data recuperarPlantillas ' + JSON.stringify(data));
    //         let plantillas = JSON.parse(data);
    //         console.log('recuperarPlantillasCarpeta ----- this.items ' + JSON.stringify(this.items));	
    //         this.idCarpetaRaiz = plantillas.name;
    //         console.log('this.idCarpetaRaiz ' + this.idCarpetaRaiz);
    //         this.nombreCarpetaRaiz = plantillas.label;
    //         console.log('this.nombreCarpetaRaiz ' + this.nombreCarpetaRaiz);
	// 		this.items = [plantillas];
    //     }
    //     if(error){
    //         console.log(error);
    //     }        
    // };

    @wire(recuperarDirectorioRaiz, {carpetaRaiz: '$carpetaRaiz'}) 
    directorioRaiz({ error, data }) {
        if(data){   
            console.log('Viene de llamada a recuperarDirectorioRaiz ' + JSON.stringify(data));
            let nombrePadre = '';
		    let idDelPadre = '';
            let plantillas = JSON.parse(data.elementosDirectorio);

            console.log('Viene de llamada a recuperarDirectorioRaiz data.carpetaRaiz ' + JSON.stringify(data.carpetaRaiz));
            this.idCarpetaRaiz = data.carpetaRaiz.Id;
            console.log('this.idCarpetaRaiz ' + this.idCarpetaRaiz);
            this.nombreCarpetaRaiz = data.carpetaRaiz.Name;
            console.log('this.nombreCarpetaRaiz ' + this.nombreCarpetaRaiz);
            //console.log('plantillas' + JSON.stringify(plantillas));
            //console.log('Viene de llamada a cambioCarpeta handleSelect ' + JSON.stringify(result));
            //console.log('plantillas' + JSON.stringify(plantillas));
            for(var miPlantilla in plantillas) {
                let plantilla = plantillas[miPlantilla];
                nombrePadre = plantilla.labelParent;
                idDelPadre = plantilla.idParent;
            }
            //console.log('Sale del for nombrePadre ' + nombrePadre + ' idDelPadre ' + idDelPadre);
            this.ruta.push({ label: nombrePadre, value: idDelPadre });
            //console.log('this.ruta ' + JSON.stringify(this.ruta));
            this.items = plantillas;
            //console.log('this.items ' + JSON.stringify(this.items));

        }
        if(error){
            console.log(error);
        }        
    };

    // handleeventodocumento(event) {
    //     this.llamarLWCEdicion = event.detail;
    // }

    selectorArbol(event) {
        this.spinnerLoading = true;
        this.mensajeBusqueda = false;
        this.mensajeNoResultados = false;
        this.idPlantilla = event.target.name;
        let nombrePadre = '';
		let idDelPadre = event.target.name;

        //console.log('idPlantilla ' + this.idPlantilla);

        if(this.idPlantilla.substring(0, 3) == '00l') {
            this.noEsPlantilla = true;
            this.idPadre = event.target.name;

            //quitar
            this.mostrarDirectorio = true;
            //console.log('this.noEsPlantilla ' + this.noEsPlantilla);
            if(this.idPlantilla != this.idCarpetaRaiz) {
                this.puedeVolver = false;
            } else {
                this.puedeVolver = true;
            }
            //console.log('this.noEsPlantilla ' + this.noEsPlantilla);
            cambioCarpeta({idPadre: this.idPlantilla}).then(result => {              
                if(result){
                    //console.log('Viene de llamada a cambioCarpeta selectorArbol ' + JSON.stringify(result));
                    let plantillas = JSON.parse(result);
                    //console.log('plantillas' + JSON.stringify(plantillas));
					for(var miPlantilla in plantillas) {
						let plantilla = plantillas[miPlantilla];
						nombrePadre = plantilla.labelParent;
						idDelPadre = plantilla.idParent;
					}
                    //console.log('Sale del for nombrePadre selectorArbol ' + nombrePadre + ' idDelPadre ' + idDelPadre);

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
                    //console.log('this.ruta ' + JSON.stringify(this.ruta));

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

        //console.log('idPlantilla ' + this.idPlantilla);

        if(this.idPlantilla.substring(0, 3) == '00l') {
            this.noEsPlantilla = true;
            this.idPadre = event.target.name;
            //console.log('this.noEsPlantilla ' + this.noEsPlantilla);
            if(this.idPlantilla != this.idCarpetaRaiz) {
                this.puedeVolver = false;
            } else {
                this.puedeVolver = true;
            }
            //console.log('this.noEsPlantilla ' + this.noEsPlantilla);
            cambioCarpeta({idPadre: this.idPlantilla}).then(result => {              
                if(result){
                    //console.log('Viene de llamada a cambioCarpeta handleSelect ' + JSON.stringify(result));
                    let plantillas = JSON.parse(result);
                    //console.log('plantillas' + JSON.stringify(plantillas));
					for(var miPlantilla in plantillas) {
						let plantilla = plantillas[miPlantilla];
						nombrePadre = plantilla.labelParent;
						idDelPadre = plantilla.idParent;
					}
                    //console.log('Sale del for nombrePadre ' + nombrePadre + ' idDelPadre ' + idDelPadre);
                    this.ruta.push({ label: nombrePadre, value: idDelPadre });
                    //console.log('this.ruta ' + JSON.stringify(this.ruta));
                    this.items = plantillas;
                    //console.log('this.items ' + JSON.stringify(this.items));
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
            //console.log('noEsPlantilla' +this.noEsPlantilla);
		}
    }


    botonVolver(event) {
        this.spinnerLoading = true;
        this.noEsPlantilla = true;

        if(this.idCarpetaRaiz != this.idPadre) {
            volverHaciaArriba({idPadre: this.idPadre}).then(result => {              
                if(result){
                    console.log('Viene de llamada a volverHaciaArriba' + JSON.stringify(result));
                    let plantillas = JSON.parse(result);
                    //console.log('plantillas' + JSON.stringify(plantillas));
					for(var miPlantilla in plantillas) {
						let plantilla = plantillas[miPlantilla];
						this.idPadre = plantilla.idParent;
					}

                    this.ruta.pop();
                    this.items = plantillas;
                    //console.log('this.items ' + JSON.stringify(this.items));
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
        //console.log('idPlantilla ' + this.idPlantilla);
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
            //console.log('recordId ' + this.recordId);
            obtenerDatosTemplate({'idTemplate': this.idPlantilla, 'idObject': this.recordId}).then(result => {              
                if(result){
                    console.log('Viene de llamada a obtenerTemplateBody' + JSON.stringify(result));
                    this.cuerpoPlantilla = result.cuerpo;
                    this.headerPlantilla = result.header;
                    this.footerPlantilla = result.footer;
                    console.log('this.cuerpoPlantilla ' + this.cuerpoPlantilla); 
                    console.log('this.headerPlantilla ' + this.headerPlantilla); 
                    console.log('this.footerPlantilla ' + this.footerPlantilla); 

                    // obtenerTemplateSubject({'idTemplate': this.idPlantilla, 'idObject': this.recordId,  'idObjectAux': this.recordId}).then(result => {              
                    //     if(result){
                    //         console.log('Viene de llamada a obtenerTemplateSubject' + JSON.stringify(result));
                    //         this.subjectPlantilla = result;
                            this.dispatchEvent(
                                new ShowToastEvent({
                                    title: 'Cambio aplicado',
                                    message: 'Se ha sustituido el cuerpo del email con el valor de la plantilla.',
                                    variant: 'success'
                                })
                            ); 
                            this.dispatchEvent(new RefreshEvent());
                            this.llamarLWCEdicion = true;
                            //console.log('this.llamarLWCEdicion ' + this.llamarLWCEdicion);
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
                            
                    //    }
                    // })
                    // .catch(error => {
                    //     this.spinnerLoading = false;
                    //     this.dispatchEvent(
                    //         new ShowToastEvent({
                    //             title: 'Error',
                    //             message: 'Error al obtener el subject de la plantilla',
                    //             variant: 'error'
                    //         })
                    //     ); 
                    //     this.dispatchEvent(new RefreshEvent());
                    // })   
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

        // if(this.idCarpetaRaiz != this.idPadre) {
        //     volverHaciaArriba({idPadre: this.idPadre}).then(result => {              
        //         if(result){
        //             console.log('Viene de llamada a cambioCarpeta' + JSON.stringify(result));
        //             let plantillas = JSON.parse(result);
        //             console.log('plantillas' + JSON.stringify(plantillas));
		// 			for(var miPlantilla in plantillas) {
		// 				let plantilla = plantillas[miPlantilla];
		// 				this.idPadre = plantilla.idParent;
		// 			}
        //             console.log('this.ruta ' + JSON.stringify(this.ruta));
        //             this.items = plantillas;
        //             console.log('this.items ' + JSON.stringify(this.items));
        //             this.spinnerLoading = false;
        //             if(this.idCarpetaRaiz === this.idPadre) {
        //                 this.puedeVolver = true;
        //             }
        //         }
        //     })
        //     .catch(error => {
        //         this.spinnerLoading = false;
        //         this.dispatchEvent(
        //             new ShowToastEvent({
        //                 title: 'Error',
        //                 message: 'Error al volver a la anterior ruta',
        //                 variant: 'error'
        //             })
        //         ); 
        //         this.dispatchEvent(new RefreshEvent());
        //     })   
        // } else {
        //     this.puedeVolver = true;
        //     this.spinnerLoading = false;
        // }
    }


    mostrarModalPlantillas() {
        this.abrirModalPlantillas = true;
    }

    cerrarModalPlantillas() {
        this.abrirModalPlantillas = false;
        //this.puedeVolver = true;
        this.noEsPlantilla = true;
        this.itemsBusqueda = [];
        this.valorBusqueda = '';

        //quitar
        this.mostrarDirectorio = true;
        //this.ruta = [];

        // if(this.cambiarPlantilla) {
        //     console.log('Entra en evento a mandar');
        //     //Custom event en el que se manda la info que queremos enviar al componente padre
        //     const sendDataEvent = new CustomEvent('eventoselector', {
        //         detail: false
        //     });
    
        //     //Hacemos el dispatch event del evento que hemos creado
        //     this.dispatchEvent(sendDataEvent);
        // } else {
            // let dataToSend = false;
            // //Custom event en el que se manda la info que queremos enviar al componente padre
            // const sendDataEvent = new CustomEvent('senddata', {
            //     detail: {dataToSend}
            // });
    
            // //Hacemos el dispatch event del evento que hemos creado
            // this.dispatchEvent(sendDataEvent);
        //} 
    }


    handleEnter(evt) {
        this.spinnerLoading = true;
        const isEnterKey = evt.keyCode === 13;
        console.log('evt.length ' + evt.target.value.length);
        if(isEnterKey && evt.target.value.length < 3) {
            this.itemsBusqueda = [];
            this.mensajeBusqueda = true;
            this.mensajeNoResultados = false;
            this.spinnerLoading = false;

            // quitar
            this.mostrarDirectorio = false;
            this.puedeVolver = true;
        } else if(isEnterKey && evt.target.value.length >= 3) {
            this.mensajeBusqueda = false;
            this.valorBusqueda = evt.target.value;
            buscarPlantillas({valorBusqueda: this.valorBusqueda, idCarpeta: this.idCarpetaRaiz, nombreCarpeta: this.nombreCarpetaRaiz}).then(result => {              
                if(result){
                    console.log('Viene de llamada a buscarPlantillas handleSelect ' + JSON.stringify(result));
                    let plantillas = JSON.parse(result);
                    console.log('plantillas' + JSON.stringify(plantillas));
                    console.log('plantillas.length ' + plantillas.length);
                    if(plantillas.length === 0) {
                        this.mensajeNoResultados = true;
                    } else {
                        this.mensajeNoResultados = false;
                    }
					for(var miPlantilla in plantillas) {
						let plantilla = plantillas[miPlantilla];
						// nombrePadre = plantilla.labelParent;
						// idDelPadre = plantilla.idParent;
					}
                    // console.log('Sale del for nombrePadre ' + nombrePadre + ' idDelPadre ' + idDelPadre);
                    // this.ruta.push({ label: nombrePadre, value: idDelPadre });
                    // console.log('this.ruta ' + JSON.stringify(this.ruta));
                    this.itemsBusqueda = plantillas;

                    // quitar
                    this.mostrarDirectorio = false;
                    this.puedeVolver = true;

                    console.log('this.itemsBusqueda ' + JSON.stringify(this.itemsBusqueda));
                    this.spinnerLoading = false;
                }
            })
            .catch(error => {
                this.spinnerLoading = false;
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error',
                        //message: 'Error al obtener las plantillas buscadas',
                        message: error.body.message,
                        variant: 'error'
                    })
                ); 
                this.dispatchEvent(new RefreshEvent());
            })   
        }
    }
}