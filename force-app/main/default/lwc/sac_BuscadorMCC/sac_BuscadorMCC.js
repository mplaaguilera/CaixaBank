import { LightningElement, track, api, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { RefreshEvent } from 'lightning/refresh';

import buscarResultados from '@salesforce/apex/SAC_LCMP_BuscadorMCCController.buscarResultados';
import buscarGruposDetalle from '@salesforce/apex/SAC_LCMP_BuscadorMCCController.buscarGruposDetalle';
import actualizarCaso from '@salesforce/apex/SAC_LCMP_BuscadorMCCController.actualizarCaso';

import obtenerClasificacionActual from '@salesforce/apex/SAC_LCMP_BuscadorMCCController.obtenerClasificacionActual';



export default class Sac_BuscadorMCC extends LightningElement {
    // Variables pasadas del aura
    @api nuevaPretension;
    @api cambioMCC;
    @api puedeGuardar;
    @api recordId;

    // Variables generales
    @track estaAbierto = false;
    @track opcionSeleccionada = false;
    @track searchInput = '';
    @track message;
    @track tipoBuscador = '';
    @track idSelect = '';
    @track mensajeMuchosResultados = 'Más resultados encontrados, escriba para filtrar...';
    @track listMCC = [];
    @track cadenaGrupos = '';
    @track mostrarBotonAnadir = true;
    @track mostrarBotonGuardar = true;
    @track spinnerLoading = false;

    // Variables filtro Temática
    @track mostrarOpcionesTematica = false;
    @track searchInputTematica = '';
    @track idMccSelectTematica = '';
    @track filteredResultsTematica = [];

    // Variables filtro Producto
    @track mostrarOpcionesProducto = false;
    @track disabledProducto = true;
    @track searchInputProducto = '';
    @track idMccSelectProducto = '';
    @track filteredResultsProducto = [];

    // Variables filtro Motivo
    @track mostrarOpcionesMotivo = false;
    @track disabledMotivo = true;
    @track searchInputMotivo = '';
    @track idMccSelectMotivo = '';
    @track filteredResultsMotivo = [];

    // Variables filtro Detalle
    @track mostrarOpcionesDetalle = false;
    @track disabledDetalle = false;
    @track searchInputDetalle = '';
    @track idMccSelectDetalle = '';
    @track filteredResultsDetalle = [];
    @track listaGrupos = [];
    @track mostrarGruposDetalle = false;
    @track mostrarMensajeNoGrupos = false;

    // Método búsqueda niveles MCC
    @wire(obtenerClasificacionActual, { recordId: '$recordId'})
    wiredClasificacionActual({ error, data }) {
        if(data) {
            if(this.cambioMCC) {
                // Se muestra la clasificación actual de la pretensión
                this.searchInputTematica = data.CC_MCC_Tematica__r.Name;
                this.idMccSelectTematica = data.CC_MCC_Tematica__c;

                this.searchInputProducto = data.CC_MCC_ProdServ__r.Name;
                this.idMccSelectProducto = data.CC_MCC_ProdServ__c;
                
                this.searchInputMotivo = data.CC_MCC_Motivo__r.Name;
                this.idMccSelectMotivo = data.CC_MCC_Motivo__c;

                this.searchInputDetalle = data.SEG_Detalle__r.Name;
                this.idMccSelectDetalle = data.SEG_Detalle__c;

                // Se permite modificar todos los niveles
                this.disabledMotivo = false;
                this.disabledProducto = false;
            }
        }
    }

    // Método búsqueda niveles MCC
    @wire(buscarResultados, { searchTerm: '$searchInput', tipoBusqueda: '$tipoBuscador', id: '$idSelect' })
    wiredSearchResults({ error, data }) {
        if (data == '' || data == undefined) {
            if(this.tipoBuscador === 'buscadorTematica'){
                this.filteredResultsTematica = '';
            }
            if(this.tipoBuscador === 'buscadorProducto'){
                this.filteredResultsProducto = '';
            }
            if(this.tipoBuscador === 'buscadorMotivo'){
                this.filteredResultsMotivo = '';
            }
            if(this.tipoBuscador === 'buscadorDetalle'){
                this.filteredResultsDetalle = '';
            }
            if(this.tipoBuscador === 'buscadorNivelDetalle'){
                this.filteredResultsDetalle = '';
            }
            if(this.searchInput === ''){
                this.message = "No hay resultados";
            }else{
                this.message = "No hay resultados para '" + this.searchInput + "'";
            }
        }else {
            this.message = '';

            if(data.length >= 50){
                this.hayMasResultados = true;
            }else{
                this.hayMasResultados = false;
            }

            if(this.tipoBuscador === 'buscadorTematica'){
                this.filteredResultsTematica = data;
            }
            if(this.tipoBuscador === 'buscadorProducto'){
                this.filteredResultsProducto = data;
            }
            if(this.tipoBuscador === 'buscadorMotivo'){
                this.filteredResultsMotivo = data;
            }
            if(this.tipoBuscador === 'buscadorDetalle'){
                this.filteredResultsDetalle = data;
            }
            if(this.tipoBuscador === 'buscadorNivelDetalle' ){
                this.filteredResultsDetalle = data;
            }
        }
    }


    // Métodos filtro Temática
    blurTematica(){
        this.mostrarOpcionesTematica = false;
        this.estaAbierto = false;

        if(this.opcionSeleccionada === false){
            this.searchInput = '';
            this.searchInputTematica = '';
            this.idMccSelectTematica = '';

            // Si se modifica la Temática se bloquean los niveles inferiores y se vacían sus valores
            this.disabledProducto = true;
            this.searchInputProducto = '';
            this.idMccSelectProducto = '';
            this.disabledMotivo = true;
            this.searchInputMotivo = '';
            this.idMccSelectMotivo = '';
            this.disabledDetalle = false;
            this.searchInputDetalle = '';
            this.idMccSelectDetalle = '';
            this.mostrarGruposDetalle = false;
            this.mostrarMensajeNoGrupos = false;
            this.mostrarBotonAnadir = true;
            this.mostrarBotonGuardar = true;
        }
    }

    mostrarOpcTematica(event){
        this.searchInput = '';
        this.tipoBuscador = event.target.name;
        this.opcionSeleccionada = false;

        if(this.estaAbierto === false){
            this.estaAbierto = true;

            setTimeout(() => {
                this.searchInputTematica = '';
                this.mostrarOpcionesTematica = true;
            }, 150);
        }else{
            this.estaAbierto = false;
            this.mostrarOpcionesTematica = false;
        }
    }

    selectTematica(event){
        const selectedValue = event.currentTarget.dataset.value;
        const resultName = event.currentTarget.dataset.name;

        this.searchInput = '';
        this.opcionSeleccionada = true;
        this.searchInputTematica = resultName;
        this.idMccSelectTematica = selectedValue;
        this.disabledProducto = false;

        // Si se modifica la Temática se bloquean los niveles inferiores y se vacían sus valores
        this.searchInputProducto = '';
        this.disabledMotivo = true;
        this.searchInputMotivo = '';
        this.disabledDetalle = true;
        this.searchInputDetalle = '';
        this.mostrarGruposDetalle = false;
        this.mostrarMensajeNoGrupos = false;
        this.mostrarBotonAnadir = true;
        this.mostrarBotonGuardar = true;

        this.mostrarOpcionesTematica = false;
    }

    filtrarOpcTematica(event){
        this.tipoBuscador = event.target.name;

        this.opcionSeleccionada = false;
        this.searchInputTematica = event.target.value;
        this.searchInput = this.searchInputTematica;

        // Si se modifica la Temática se bloquean los niveles inferiores y se vacían sus valores
        this.disabledProducto = true;
        this.searchInputProducto = '';
        this.disabledMotivo = true;
        this.searchInputMotivo = '';
        this.disabledDetalle = true;
        this.searchInputDetalle = '';
        this.mostrarGruposDetalle = false;
        this.mostrarMensajeNoGrupos = false;
        this.mostrarBotonAnadir = true;
        this.mostrarBotonGuardar = true;

        if(this.searchInput.length > 2){
            this.message = '';
        }
    }


    // Métodos filtro Producto/Servicio
    blurProducto(){
        this.mostrarOpcionesProducto = false;
        this.estaAbierto = false;

        if(this.opcionSeleccionada === false){
            this.searchInput = '';
            this.searchInputProducto = '';
            this.idMccSelectProducto = '';

            // Si se modifica el Producto se bloquean los niveles inferiores y se vacían sus valores
            this.disabledMotivo = true;
            this.searchInputMotivo = '';
            this.idMccSelectMotivo = '';
            this.disabledDetalle = true;
            this.searchInputDetalle = '';
            this.idMccSelectDetalle = '';
            this.mostrarGruposDetalle = false;
            this.mostrarMensajeNoGrupos = false;
            this.mostrarBotonAnadir = true;
            this.mostrarBotonGuardar = true;
        }
    }

    mostrarOpcProducto(event){
        this.searchInput = '';
        this.idSelect = this.idMccSelectTematica;
        this.tipoBuscador = event.target.name;
        this.opcionSeleccionada = false;

        if(this.estaAbierto === false){
            this.estaAbierto = true;

            setTimeout(() => {
                this.searchInputProducto = '';
                this.mostrarOpcionesProducto = true;
            }, 150);
        }else{
            this.estaAbierto = false;
            this.mostrarOpcionesProducto = false;
        }
    }

    selectProducto(event){
        const selectedValue = event.currentTarget.dataset.value;
        const resultName = event.currentTarget.dataset.name;

        this.searchInput = '';
        this.opcionSeleccionada = true;
        this.searchInputProducto = resultName;
        this.idMccSelectProducto = selectedValue;
        this.disabledMotivo = false;

        // Si se modifica el Producto se bloquean los niveles inferiores y se vacían sus valores
        this.searchInputMotivo = '';
        this.disabledDetalle = true;
        this.searchInputDetalle = '';
        this.mostrarGruposDetalle = false;
        this.mostrarMensajeNoGrupos = false;
        this.mostrarBotonAnadir = true;
        this.mostrarBotonGuardar = true;

        this.mostrarOpcionesProducto = false;
    }

    filtrarOpcProducto(event){
        this.tipoBuscador = event.target.name;

        this.opcionSeleccionada = false;
        this.searchInputProducto = event.target.value;
        this.searchInput = this.searchInputProducto;

        // Si se modifica el Producto se bloquean los niveles inferiores y se vacían sus valores
        this.disabledMotivo = true;
        this.searchInputMotivo = '';
        this.disabledDetalle = true;
        this.searchInputDetalle = '';
        this.mostrarGruposDetalle = false;
        this.mostrarMensajeNoGrupos = false;
        this.mostrarBotonAnadir = true;
        this.mostrarBotonGuardar = true;

        if(this.searchInput.length > 2){
            this.message = '';
        }
    }

    // Métodos filtro Motivo
    blurMotivo(){
        this.mostrarOpcionesMotivo = false;
        this.estaAbierto = false;

        if(this.opcionSeleccionada === false){
            this.searchInput = '';
            this.searchInputMotivo = '';
            this.idMccSelectMotivo = '';

            // Si se modifica el Motivo se bloquean los niveles inferiores y se vacían sus valores
            this.disabledDetalle = true;
            this.searchInputDetalle = '';
            this.idMccSelectDetalle= '';
            this.mostrarGruposDetalle = false;
            this.mostrarMensajeNoGrupos = false;
            this.mostrarBotonAnadir = true;
            this.mostrarBotonGuardar = true;
        }
    }

    mostrarOpcMotivo(event){
        this.searchInput = '';
        this.idSelect = this.idMccSelectProducto;
        this.tipoBuscador = event.target.name;
        this.opcionSeleccionada = false;

        if(this.estaAbierto === false){
            this.estaAbierto = true;

            setTimeout(() => {
                this.searchInputMotivo = '';
                this.mostrarOpcionesMotivo = true;
            }, 150);
        }else{
            this.estaAbierto = false;
            this.mostrarOpcionesMotivo = false;
        }
    }

    selectMotivo(event){
        const selectedValue = event.currentTarget.dataset.value;
        const resultName = event.currentTarget.dataset.name;

        this.searchInput = '';
        this.opcionSeleccionada = true;
        this.searchInputMotivo = resultName;
        this.idMccSelectMotivo = selectedValue;
        this.disabledDetalle = false;

        // Si se modifica el Motivo se bloquean los niveles inferiores y se vacían sus valores
        this.searchInputDetalle = '';
        this.mostrarGruposDetalle = false;
        this.mostrarMensajeNoGrupos = false;
        this.mostrarBotonAnadir = true;
        this.mostrarBotonGuardar = true;

        this.mostrarOpcionesMotivo = false;
    }

    filtrarOpcMotivo(event){
        this.tipoBuscador = event.target.name;

        this.opcionSeleccionada = false;
        this.searchInputMotivo = event.target.value;
        this.searchInput = this.searchInputMotivo;

        // Si se modifica el Motivo se bloquean los niveles inferiores y se vacían sus valores
        this.disabledDetalle = true;
        this.searchInputDetalle = '';
        this.mostrarGruposDetalle = false;
        this.mostrarMensajeNoGrupos = false;
        this.mostrarBotonAnadir = true;
        this.mostrarBotonGuardar = true;

        if(this.searchInput.length > 2){
            this.message = '';
        }
    }


    // Métodos filtro Detalle
    blurDetalle(){
        this.mostrarOpcionesDetalle = false;
        this.estaAbierto = false;

        if(this.opcionSeleccionada === false){
            this.searchInput = '';
            this.searchInputDetalle = '';
            this.idMccSelectDetalle= '';
            this.mostrarGruposDetalle = false;
            this.mostrarMensajeNoGrupos = false;
            this.mostrarBotonAnadir = true;
            this.mostrarBotonGuardar = true;
        }
    }

    mostrarOpcDetalle(event){
        this.searchInput = '';
        this.idSelect = this.idMccSelectMotivo;

        // Si no hay ningún valor en el motivo quiere decir que es una búsqueda desde el nivel detalle
        if(this.idMccSelectMotivo == '') {
            this.tipoBuscador = 'buscadorNivelDetalle';
        } else {
            this.tipoBuscador = event.target.name;
        }

        this.opcionSeleccionada = false;

        if(this.estaAbierto === false){
            this.estaAbierto = true;

            setTimeout(() => {
                this.searchInputDetalle = '';
                this.mostrarOpcionesDetalle = true;
            }, 150);
        }else{
            this.estaAbierto = false;
            this.mostrarOpcionesDetalle = false;
        }
    }

    selectDetalle(event){
        const selectedValue = event.currentTarget.dataset.value;
        const resultName = event.currentTarget.dataset.name;

        if(this.idMccSelectMotivo == '') {
            // Se muestra la clasificación completa del detalle seleccionado en caso de que sea una búsqueda desde el detalle
            this.searchInputMotivo = event.currentTarget.dataset.namemotivo;
            this.idMccSelectMotivo = event.currentTarget.dataset.idmotivo;

            this.searchInputProducto = event.currentTarget.dataset.nameproducto;
            this.idMccSelectProducto = event.currentTarget.dataset.idproducto;

            this.searchInputTematica = event.currentTarget.dataset.nametematica;
            this.idMccSelectTematica = event.currentTarget.dataset.idtematica;

            // Se permite modificar todos los niveles
            this.disabledMotivo = false;
            this.disabledProducto = false;
        }

        //this.searchInput = '';
        this.opcionSeleccionada = true;
        this.searchInputDetalle = resultName;
        this.idMccSelectDetalle = selectedValue;
        this.mostrarBotonAnadir = false;
        // Si tiene permisos para guardar y se han seleccionado todos los niveles del MCC se habilita el botón de guardar
        if(this.puedeGuardar) {
            this.mostrarBotonGuardar = false;
        }

        this.mostrarOpcionesDetalle = false;

        buscarGruposDetalle({ idDetalle: this.idMccSelectDetalle}).then(result => {
            this.listaGrupos = result;

            if(this.listaGrupos.length === 0){
                this.mostrarGruposDetalle = false;
                this.mostrarMensajeNoGrupos = true;
            }
            else{
                for(let indice=0; indice < this.listaGrupos.length; indice++){
                    if(indice === 0){
                        this.cadenaGrupos = this.listaGrupos[indice].CC_Grupo_Colaborador__r.Name;
                    } else {
                        this.cadenaGrupos = this.cadenaGrupos + ', ' + this.listaGrupos[indice].CC_Grupo_Colaborador__r.Name;
                    }
                }
                this.mostrarGruposDetalle = true;
                this.mostrarMensajeNoGrupos = false;
            }
        })
        .catch(error => {
            const evt = new ShowToastEvent({
                title: 'Error',
                message: 'Fallo al recuperar los grupos colaboradores del detalle',
                variant: 'error'
            });
            this.dispatchEvent(evt);
        })
    }

    filtrarOpcDetalle(event){
        // Si no hay ningún valor en el motivo quiere decir que es una búsqueda desde el nivel detalle
        if(this.idMccSelectMotivo == '') {
            this.tipoBuscador = 'buscadorNivelDetalle';
        } else {
            this.tipoBuscador = event.target.name;
        }

        this.opcionSeleccionada = false;
        this.searchInputDetalle = event.target.value;
        this.searchInput = this.searchInputDetalle;

        if(this.searchInput.length > 2){
            this.message = '';
        }
    }

    // Botón añadir nueva pretensión
    handleClickAnadir(event){
        if(this.idMccSelectTematica === '' ||  this.idMccSelectProducto === '' || this.idMccSelectMotivo === '' || this.idMccSelectDetalle === '') {
            const evt = new ShowToastEvent({
                title: 'Error',
                message: 'Recuerde rellenar todos los niveles del MCC',
                variant: 'error'
            });
            this.dispatchEvent(evt);
        } else {
            this.listMCC = [];
            for(let i=0; i < this.filteredResultsDetalle.length; i++){
                if(this.filteredResultsDetalle[i].Id === this.idMccSelectDetalle){
                    this.listMCC.push(this.filteredResultsDetalle[i]);
                }
            }
            let dataToSend = this.listMCC;
            //Custom event en el que se manda la info que queremos enviar al componente padre
            const sendDataEvent = new CustomEvent('senddata', {
                detail: {dataToSend}
            });

            //Hacemos el dispatch event del evento que hemos creado
            this.dispatchEvent(sendDataEvent);


            // Si se modifica la Temática se bloquean los niveles inferiores y se vacían sus valores
            this.searchInput = '';
            this.searchInputTematica = '';
            this.idMccSelectTematica = '';
            this.disabledProducto = true;
            this.searchInputProducto = '';
            this.idMccSelectProducto = '';
            this.disabledMotivo = true;
            this.searchInputMotivo = '';
            this.idMccSelectMotivo = '';
            this.searchInputDetalle = '';
            this.idMccSelectDetalle = '';
            this.mostrarGruposDetalle = false;
            this.mostrarMensajeNoGrupos = false;
            this.mostrarBotonAnadir = true;
            this.mostrarBotonGuardar = true;

            // Mensaje de pretensión añadida
            const evt = new ShowToastEvent({
                title: 'Pretensión añadida',
                message: 'Se ha añadido una nueva pretensión a crear.',
                variant: 'success'
            });
            this.dispatchEvent(evt);
        }
    }


    // Botón cambiar MCC pretensión
    handleClickGuardar(event){
        if(this.idMccSelectTematica === '' ||  this.idMccSelectProducto === '' || this.idMccSelectMotivo === '' || this.idMccSelectDetalle === '') {
            const evt = new ShowToastEvent({
                title: 'Error',
                message: 'Recuerde rellenar todos los niveles del MCC',
                variant: 'error'
            });
            this.dispatchEvent(evt);
        } else {
            this.spinnerLoading = true;

            actualizarCaso({recordId: this.recordId, idDetalle: this.idMccSelectDetalle}).then(result => {  
                this.spinnerLoading = false;
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Éxito',
                        message: 'La clasificación de la pretensión ha sido cambiada con éxito',
                        variant: 'success'
                    })
                );
                this.dispatchEvent(new RefreshEvent());
                let dataToSend = false;
                //Custom event en el que se manda la info que queremos enviar al componente padre
                const sendDataEvent = new CustomEvent('senddata', {
                    detail: {dataToSend}
                });

                //Hacemos el dispatch event del evento que hemos creado
                this.dispatchEvent(sendDataEvent);
                this.dispatchEvent(new RefreshEvent());
            })
            .catch(error => {
                this.spinnerLoading = false;
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error al cambiar la clasificación de la pretensión',
                        message: error.body.message,
                        variant: 'error'
                    })
                ); 
                this.dispatchEvent(new RefreshEvent());
            })
        }
    }
}