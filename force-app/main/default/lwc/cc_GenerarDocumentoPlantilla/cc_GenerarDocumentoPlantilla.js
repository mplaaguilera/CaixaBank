import {LightningElement, api, wire, track} from 'lwc';
import {NavigationMixin} from 'lightning/navigation';
import {ShowToastEvent} from 'lightning/platformShowToastEvent';

import verCarpetaInicialApex from '@salesforce/apex/CC_GenerarDocumentoPlantilla_Apex.verCarpetaInicial';
import verCarpetaApex from '@salesforce/apex/CC_GenerarDocumentoPlantilla_Apex.verCarpeta';
import buscarPlantillasApex from '@salesforce/apex/CC_GenerarDocumentoPlantilla_Apex.buscarPlantillas';
//import cuerpoPlantillaApex from '@salesforce/apex/CC_GenerarDocumentoPlantilla_Apex.cuerpoPlantilla';

import cuerpoPlantillaApex from '@salesforce/apex/CC_GenerarDocumentoPlantilla_Apex.obtenerDatosTemplate';

import cargarPlantillasMCCApex from '@salesforce/apex/CC_GenerarDocumentoPlantilla_Apex.cargarPlantillasMCC';
import buscarPlantillasMCCApex from '@salesforce/apex/CC_GenerarDocumentoPlantilla_Apex.buscarPlantillasMCC';


//eslint-disable-next-line new-cap
export default class ccGenerarDocumentoPlantilla extends NavigationMixin(LightningElement) {
	@api recordId;

	@api carpetaRaizDeveloperName;

	carpetaRaiz;

	carpetaActual;

	plantillas;

	plantillasFiltro;

	@track ruta = [];

	plantillaSeleccionada;

	lookupBusquedaInputValue = '';

	lookupBusquedaResultados = [];

	lookupBusquedaTimeout;

	@wire(cargarPlantillasMCCApex, {idCaso: '$recordId'})
	wiredCargarPlantillasMCC({error, data}) {
		
		if (data) {
			this.plantillas = data;
			this.plantillasFiltro = data;
		} else if (error) {
			console.error(error);
		}
	}

/*
	@wire(verCarpetaInicialApex, {carpetaDeveloperName: '$carpetaRaizDeveloperName'})
	wiredCarpetaInicial({error, data}) {
		if (data) {
			const carpetaInicial = JSON.parse(JSON.stringify(data)); //copia del objeto
			carpetaInicial.carpeta.Name = 'Plantillas CC';
			this.carpetaRaiz = {...carpetaInicial};
			this.carpetaActual = {...carpetaInicial};
			this.ruta = [{...carpetaInicial.carpeta}];
			this.template.querySelector('.lookupBusquedaInput').disabled = !carpetaInicial.plantillas.length;
		} else if (error) {
			console.error(error);
		}
	}*/

	verCarpeta(idCarpeta, rutaActual = [...this.ruta]) {
		if (idCarpeta === this.carpetaRaiz.carpeta.Id) {
			this.carpetaActual = {...this.carpetaRaiz};
			this.ruta = [{...this.carpetaRaiz.carpeta}];
			this.template.querySelector('.lookupBusquedaInput').disabled = !this.carpetaActual.plantillas.length;

		} else if (idCarpeta !== this.carpetaActual.carpeta.Id) {
			verCarpetaApex({idCarpeta})
			.then(nuevaCarpetaActual => {
				this.carpetaActual = {...nuevaCarpetaActual};
				this.ruta = rutaActual.concat([{...nuevaCarpetaActual.carpeta}]);
				const verticalNavigationSelectedItem = this.carpetaRaiz.subcarpetas.find(c => c.Id === nuevaCarpetaActual.carpeta.Id)?.Id;
				this.template.querySelector('.verticalNavigation').selectedItem = verticalNavigationSelectedItem;
				this.template.querySelector('.lookupBusquedaInput').disabled = !this.carpetaActual.plantillas.length;

			}).catch(error => {
				console.error(error);
				this.toast('error', 'Problema recuperando contenido de la carpeta');
			});
		}
		//this.template.querySelector('.lookupBusquedaInput').disabled = !this.carpetaActual.plantillas.length;
	}

	verticalNavigationOnselect(event) {
		if (event.currentTarget.selectedItem) {
			this.verCarpeta(event.detail.name, [this.carpetaRaiz.carpeta]);
		}
	}

	breadcumbOnclick(event) {
		if (event.currentTarget.dataset.id !== this.carpetaActual.carpeta.Id) {
			//No es la carpeta actual
			if (event.currentTarget.dataset.id === this.carpetaRaiz.carpeta.Id) {
				//Carpeta raíz, se vacía la ruta
				this.verCarpeta(event.currentTarget.dataset.id, []);
			} else {
				//No es carpeta raíz, se vacía la ruta a partir de la carpeta seleccionada
				const indice = this.ruta.findIndex(carpeta => carpeta.Id === event.currentTarget.dataset.id);
				if (indice !== -1) {
					this.ruta = this.ruta.slice(0, indice);
				}
				this.verCarpeta(event.currentTarget.dataset.id);
			}
		}
	}

	lookupBusquedaSeleccionarResultado(event) {	
		
		const resultadoSeleccionado = this.plantillas.find(plantilla => plantilla.Id === event.currentTarget.dataset.id);
		
		this.plantillaSeleccionada = resultadoSeleccionado;
		this.lookupBusquedaInputValue = '';
		this.lookupBusquedaResultados = [];
		this.template.querySelector('.botonAplicar').disabled = false;
	}

	lookupBusquedaInputOnchange(event) {
		console.log('::: dentro onchange');
		console.log('::: event.detail.value: ' + event.detail.value);
		window.clearTimeout(this.lookupBusquedaTimeout);
		console.log('::: lookupBusquedaTimeout: ' + this.lookupBusquedaTimeout);
		this.lookupBusquedaInputValue = event.detail.value;
		console.log('::: lookupBusquedaInputValue: ' + lookupBusquedaInputValue);
		if (this.lookupBusquedaInputValue.length > 1) {
			console.log('::: dentro if');
			//eslint-disable-next-line @lwc/lwc/no-async-operation
			this.lookupBusquedaTimeout = window.setTimeout(() => this.buscarPlantillas(this.carpetaActual.carpeta.Id, this.lookupBusquedaInputValue), 500);
		} else {
			console.log('::: dentro else');
			const lookupBusqueda = this.template.querySelector('.lookupBusqueda');
			lookupBusqueda.classList.remove('slds-is-open');
			this.lookupBusquedaResultados = [];
		}
	}

	lookupBusquedaInputOnkeydown(event) {
		if (event.keyCode === 27 && event.currentTarget.value) { //ESC
			event.stopPropagation();
		}
	}

	buscarPlantillas(idCarpeta, cadenaBusqueda) {
		console.log('::: dentro buscarPlantillas');
		const lookupBusqueda = this.template.querySelector('.lookupBusqueda');
		const lookupBusquedaInput = lookupBusqueda.querySelector('.lookupBusquedaInput');
		lookupBusquedaInput.isLoading = true;
		console.log('::: antes buscarPlantillasApex: ' + idCarpeta);
		buscarPlantillasApex({idCarpeta, cadenaBusqueda})
		.then(plantillas => {
			console.log('::: dentro then: ' + plantillas);
			this.lookupBusquedaResultados = plantillas;
			console.log('::: lookupBusquedaResultados: ' + lookupBusquedaResultados);
			lookupBusqueda.classList.add('slds-is-open');
		}).catch(error => {
			console.log('::: dentro error');
			console.error(error);
			this.toast('error', 'Problema buscando plantillas', error.body.message);
		}).finally(() => lookupBusquedaInput.isLoading = false);
	}

	lookupBusquedaAbrir(event) {
		if (event.currentTarget.value.length > 1) {
			this.template.querySelector('.lookupBusqueda').classList.add('slds-is-open');
		}
	}

	lookupBusquedaCerrar() {
		//eslint-disable-next-line @lwc/lwc/no-async-operation
		window.setTimeout(() => this.template.querySelector('.lookupBusqueda').classList.remove('slds-is-open'), 100);
	}

	carpetaOnclick(event) {
		this.verCarpeta(event.currentTarget.dataset.id);
	}

	plantillaOnclick(event) {
		this.plantillaSeleccionada = this.carpetaActual.plantillas.find(p => p.Id === event.currentTarget.dataset.id);
		this.template.querySelector('.botonAplicar').disabled = false;
	}

	botonAplicarOnclick() {
		const botonAplicar = this.template.querySelector('.botonAplicar');
		botonAplicar.disabled = true;
		cuerpoPlantillaApex({idPlantilla: this.plantillaSeleccionada.Id, recordId: this.recordId})
		.then(cuerpoPlantilla => {

			this.dispatchEvent(new CustomEvent('eventoaplicar', {detail: {cuerpo: cuerpoPlantilla.cuerpo,  header: cuerpoPlantilla.header, footer: cuerpoPlantilla.footer,  idPlantilla: this.plantillaSeleccionada.Id}}));
			this.cerrarModalPlantillas();
		}).catch(error => {
			console.error(error);
			this.toast('error', 'Error', 'Error al obtener los datos de la plantillas');
		}).finally(() => botonAplicar.disabled = false);
	}

	mostrarModalPlantillas() {
		this.template.querySelector('.modalSeleccionarPlantilla').classList.add('slds-fade-in-open');
		this.dispatchEvent(new CustomEvent('modalabierto', {detail: {}}));
		this.template.querySelector('.botonCancelar').focus();
	}

	cerrarModalPlantillas() {
		this.template.querySelector('.modalSeleccionarPlantilla').classList.remove('slds-fade-in-open');
		this.dispatchEvent(new CustomEvent('modalcerrado', {detail: {}}));
	}

	modalSeleccionarPlantillaOnkeydown(event) {
		if (event.keyCode === 27) { //ESC
			this.cerrarModalPlantillas();
		}
	}

	toast(variant, title, message) {
		this.dispatchEvent(new ShowToastEvent({variant, title, message}));
	}

	navegarRegistroPlantilla(event) {
		this[NavigationMixin.Navigate]({
			type: 'standard__recordPage',
			attributes: {recordId: event.currentTarget.dataset.id, actionName: 'view'}
		});
	}

	test(event) {
		console.log('::: dentro test');
		console.log('::: plantillas: ' + event.target.value);
		input = event.target.value;
		this.plantillas = this.plantillasFiltro
            .filter( p => p.Name.includes(input));
		// buscarPlantillasMCCApex({plantillas})
		// .then(plantillas => {
		// 	console.log('::: dentro then: ' + this.plantillas);
		// }).catch(error => {
		// 	console.log('::: dentro error');
		// 	console.error(error);
		// 	this.toast('error', 'Problema buscando plantillas', error.body.message);
		// }).finally(() => console.log('::: test'));
	}
}