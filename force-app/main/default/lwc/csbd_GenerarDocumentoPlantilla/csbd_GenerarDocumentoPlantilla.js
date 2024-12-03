import {LightningElement, api, wire, track} from 'lwc';
import {NavigationMixin} from 'lightning/navigation';
import {ShowToastEvent} from 'lightning/platformShowToastEvent';

import verCarpetaInicialApex from '@salesforce/apex/CSBD_GenerarDocumentoPlantilla_Apex.verCarpetaInicial';
import verCarpetaApex from '@salesforce/apex/CSBD_GenerarDocumentoPlantilla_Apex.verCarpeta';
import buscarPlantillasApex from '@salesforce/apex/CSBD_GenerarDocumentoPlantilla_Apex.buscarPlantillas';
import cuerpoPlantillaApex from '@salesforce/apex/CSBD_GenerarDocumentoPlantilla_Apex.cuerpoPlantilla';

//eslint-disable-next-line new-cap
export default class csbdGenerarDocumentoPlantilla extends NavigationMixin(LightningElement) {
	@api recordId;

	@api botonDisabled;

	@api carpetaRaizDeveloperName;

	carpetaRaiz;

	carpetaActual;

	@track ruta = [];

	plantillaSeleccionada;

	lookupBusquedaInputValue = '';

	lookupBusquedaResultados = [];

	lookupBusquedaTimeout;

	@wire(verCarpetaInicialApex, {carpetaDeveloperName: '$carpetaRaizDeveloperName'})
	wiredCarpetaInicial({error, data}) {
		if (data) {
			const carpetaInicial = JSON.parse(JSON.stringify(data)); //copia del objeto
			carpetaInicial.carpeta.Name = 'Carpetas públicas';
			this.carpetaRaiz = {...carpetaInicial};
			this.carpetaActual = {...carpetaInicial};
			this.ruta = [{...carpetaInicial.carpeta}];
			this.template.querySelector('.lookupBusquedaInput').disabled = !carpetaInicial.plantillas.length;
		} else if (error) {
			console.error(error);
		}
	}

	verCarpeta(idCarpeta, rutaActual = [...this.ruta]) {
		if (idCarpeta === this.carpetaRaiz.carpeta.Id) {
			this.carpetaActual = {...this.carpetaRaiz};
			this.ruta = [{...this.carpetaRaiz.carpeta}];
		} else if (idCarpeta !== this.carpetaActual.carpeta.Id) {
			verCarpetaApex({idCarpeta})
			.then(nuevaCarpetaActual => {
				this.carpetaActual = {...nuevaCarpetaActual};
				this.ruta = rutaActual.concat([{...nuevaCarpetaActual.carpeta}]);
				const verticalNavigationSelectedItem = this.carpetaRaiz.subcarpetas.find(c => c.Id === nuevaCarpetaActual.carpeta.Id)?.Id;
				this.template.querySelector('.verticalNavigation').selectedItem = verticalNavigationSelectedItem;
			}).catch(error => {
				console.error(error);
				this.toast('error', 'Problema recuperando contenido de la carpeta');
			}).finally(() => this.template.querySelector('.lookupBusquedaInput').disabled = !this.carpetaActual.plantillas.length);
		}
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
		const resultadoSeleccionado = this.lookupBusquedaResultados.find(resultado => resultado.Id === event.currentTarget.dataset.id);
		this.plantillaSeleccionada = resultadoSeleccionado;
		this.lookupBusquedaInputValue = '';
		this.lookupBusquedaResultados = [];
	}

	lookupBusquedaInputOnchange(event) {
		window.clearTimeout(this.lookupBusquedaTimeout);
		this.lookupBusquedaInputValue = event.detail.value;
		if (this.lookupBusquedaInputValue.length > 1) {
			//eslint-disable-next-line @lwc/lwc/no-async-operation
			this.lookupBusquedaTimeout = window.setTimeout(() => this.buscarPlantillas(this.carpetaActual.carpeta.Id, this.lookupBusquedaInputValue), 500);
		} else {
			const lookupBusqueda = this.template.querySelector('.lookupBusqueda');
			lookupBusqueda.classList.remove('slds-is-open');
			this.lookupBusquedaResultados = [];
		}
	}

	lookupBusquedaInputOnkeydown(event) {
		if (event.keyCode === 27) { //ESC
			event.stopPropagation();
		}
	}

	buscarPlantillas(idCarpeta, cadenaBusqueda) {
		const lookupBusqueda = this.template.querySelector('.lookupBusqueda');
		const lookupBusquedaInput = lookupBusqueda.querySelector('.lookupBusquedaInput');
		lookupBusquedaInput.isLoading = true;
		buscarPlantillasApex({idCarpeta, cadenaBusqueda})
		.then(plantillas => {
			this.lookupBusquedaResultados = plantillas;
			lookupBusqueda.classList.add('slds-is-open');
		}).catch(error => {
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
			this.dispatchEvent(new CustomEvent('eventoaplicar', {detail: cuerpoPlantilla}));
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

}