import { LightningElement, api, wire } from 'lwc';
import currentUserId from '@salesforce/user/Id';
import { getRecord, getFieldValue, updateRecord } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

import buscar from '@salesforce/apex/CC_BuscadorClasificaciones_Controller.buscar';
import clasificacionesRecientes from '@salesforce/apex/CC_BuscadorClasificaciones_Controller.clasificacionesRecientes';

import CASE_CASE_NUMBER from '@salesforce/schema/Case.CaseNumber';
import CASE_OWNER_ID from '@salesforce/schema/Case.OwnerId';
import CASE_IS_CLOSED from '@salesforce/schema/Case.IsClosed';
import CASE_TEMATICA_ID from '@salesforce/schema/Case.CC_MCC_Motivo__r.CC_Producto_Servicio__r.CC_Tematica__c';
import CASE_TEMATICA_NAME from '@salesforce/schema/Case.CC_MCC_Motivo__r.CC_Producto_Servicio__r.CC_Tematica__r.Name';
import CASE_TEMATICA_COLOR from '@salesforce/schema/Case.CC_MCC_Motivo__r.CC_Producto_Servicio__r.CC_Tematica__r.CC_Color_En_Buscador__c';
import CASE_PRODUCTO_ID from '@salesforce/schema/Case.CC_MCC_Motivo__r.CC_Producto_Servicio__c';
import CASE_PRODUCTO_NAME from '@salesforce/schema/Case.CC_MCC_Motivo__r.CC_Producto_Servicio__r.Name';
import CASE_PRODUCTO_COLOR from '@salesforce/schema/Case.CC_MCC_Motivo__r.CC_Producto_Servicio__r.CC_Color_En_Buscador__c';
import CASE_MOTIVO_ID from '@salesforce/schema/Case.CC_MCC_Motivo__c';
import CASE_MOTIVO_NAME from '@salesforce/schema/Case.CC_MCC_Motivo__r.Name';
import CASE_MOTIVO_COLOR from '@salesforce/schema/Case.CC_MCC_Motivo__r.CC_Color_En_Buscador__c';
import CASE_MOTIVO_DETALLE from '@salesforce/schema/Case.CC_MCC_Motivo__r.CC_Detalle__c';

const CASE_FIELDS = [
	CASE_OWNER_ID, CASE_CASE_NUMBER, CASE_IS_CLOSED,
	CASE_TEMATICA_ID, CASE_TEMATICA_NAME, CASE_TEMATICA_COLOR,
	CASE_PRODUCTO_ID, CASE_PRODUCTO_NAME, CASE_PRODUCTO_COLOR,
	CASE_MOTIVO_ID, CASE_MOTIVO_NAME, CASE_MOTIVO_COLOR, CASE_MOTIVO_DETALLE
];

export default class ccBuscadorClasificaciones extends LightningElement {
	@api recordId;

	funcionRenderedCallback = () => {
		if (!this.recordId) {
			this.buscadorAbrir(this.template.querySelector('.buscador'));
		}
	};

	caso;

	mostrandoRecientes = true;

	idTimeoutBusqueda;

	recientes;

	opcionesTipoBusqueda = [
		{ nombre: 'Clasificaciones', iconoClasslist: '', inputBuscarPlaceholder: 'Buscar temáticas, productos/servicios, motivos...' },
		{ nombre: 'Temáticas', iconoClasslist: 'slds-hide', inputBuscarPlaceholder: 'Buscar temáticas...' },
		{ nombre: 'Productos/Servicios', iconoClasslist: 'slds-hide', inputBuscarPlaceholder: 'Buscar productos/servicios...' },
		{ nombre: 'Motivos', iconoClasslist: 'slds-hide', inputBuscarPlaceholder: 'Buscar motivos...' },
	];

	tipoBusqueda = this.opcionesTipoBusqueda[0];

	valorBusqueda;

	resultados = [];

	resultadosIndexSeleccionado = 0;

	clasificacionSeleccionada;

	guardando = false;

	resultadosBuscadorCerrarBind;

	tipoBusquedaCerrarBind;

	get mostrarClasificacionActual() {
		return this.recordId && getFieldValue(this.caso, CASE_TEMATICA_ID) && getFieldValue(this.caso, CASE_PRODUCTO_ID) && getFieldValue(this.caso, CASE_MOTIVO_ID);
	}

	get botonGuardarLabel() {
		return this.mostrarClasificacionActual ? 'Reclasificar' : 'Clasificar';
	}

	get soloLectura() {
		return this.recordId && getFieldValue(this.caso, CASE_OWNER_ID) !== currentUserId || getFieldValue(this.caso, CASE_IS_CLOSED) || this.guardando;
	}

	get botonGuardarMostrar() {
		return this.recordId && this.clasificacionSeleccionada;
	}

	get botonGuardarDisabled() {
		return this.soloLectura || !this.clasificacionSeleccionada;
	}

	get hayResultados() {
		return this.resultados.length > 0;
	}

	renderedCallback() {
		if (this.funcionRenderedCallback) {
			try {
				this.funcionRenderedCallback.call(this);
				this.funcionRenderedCallback = null;
			} catch {
				console.error('error renderedCallback');
			}
		}
	}

	@wire(getRecord, { recordId: '$recordId', fields: CASE_FIELDS })
	wiredRecord({ error, data }) {
		if (data) {
			this.caso = {
				...data,
				styleTematica: 'border-color: ' + getFieldValue(data, CASE_TEMATICA_COLOR) + ';',
				styleProducto: 'border-color: ' + getFieldValue(data, CASE_PRODUCTO_COLOR) + ';',
				styleMotivo: 'border-color: ' + getFieldValue(data, CASE_MOTIVO_COLOR) + ';',
				clasificacionCompleta: getFieldValue(data, CASE_TEMATICA_NAME) + ' → ' + getFieldValue(data, CASE_PRODUCTO_NAME) + ' → ' + getFieldValue(data, CASE_MOTIVO_NAME)
			};
			console.log(this.caso);
			if (!getFieldValue(this.caso, CASE_MOTIVO_ID)) {
				this.buscadorAbrir(this.template.querySelector('.buscador'), false); //abrir buscador sin foco
			}
		} else if (error) {
			console.error(error);
			this.mostrarToast('error', 'Problema obteniendo datos del caso', error.body.message);
		}
	}

	buscadorAbrir(buscador, focus = true) {
		buscador.classList.remove('slds-hidden', 'buscadorOculto');
		let botonMostrarOcultar = this.template.querySelector('.botonMostrarOcultar');
		if (botonMostrarOcultar) {
			botonMostrarOcultar.tooltip = 'Ocultar buscador de clasificaciones';
			botonMostrarOcultar.iconName = 'utility:chevronup';
		}
		if (focus) {
			//eslint-disable-next-line @lwc/lwc/no-async-operation
			window.setTimeout(() => this.template.querySelector('.inputBuscar')?.focus(), this.recordId ? 0 : 1500, this);
		}
	}

	buscadorCerrar(buscador) {
		buscador.classList.add('buscadorOculto');
		this.buscadorCerrarTransitionEndBind = this.buscadorCerrarTransitionEnd.bind(this, buscador);
		buscador.addEventListener('transitionend', this.buscadorCerrarTransitionEndBind);
		let botonMostrarOcultar = this.template.querySelector('.botonMostrarOcultar');
		if (botonMostrarOcultar) {
			botonMostrarOcultar.tooltip = 'Mostrar buscador de clasificaciones';
			botonMostrarOcultar.iconName = 'utility:search';
		}
	}

	buscadorCerrarTransitionEnd(buscador) {
		buscador.classList.add('slds-hidden');
		buscador.removeEventListener('transitionend', this.buscadorCerrarTransitionEndBind);
	}

	clasificacionActualOnmousedown(event) {
		event = event || window.event;
		if (!event.which || event.which !== 3 && !event.button || event.button !== 2) {
			//No es click derecho, mostrar u ocultar el buscador
			let buscador = this.template.querySelector('.buscador');
			if (buscador.classList.contains('slds-hidden')) {
				this.buscadorAbrir(buscador);
			} else {
				this.buscadorCerrar(buscador);
			}
		}
	}

	inputBuscarOnfocus(event) {
		if (this.recientes) {
			this.resultadosBuscadorAbrir();
		} else {
			let inputBuscar = event.currentTarget;
			inputBuscar.isLoading = true;
			clasificacionesRecientes()
				.then(recientes => {
					recientes = [...recientes];
					recientes = this.resaltarResultados(recientes);
					this.recientes = [...recientes];
					this.actualizarResultados([...recientes]);
					this.resultadosBuscadorAbrir();
				}).catch(error => console.error(error))
				.finally(() => inputBuscar.isLoading = false);
		}
	}

	resultadosBuscadorAbrir() {
		this.actualizarResultados(this.resultados);
		let backdrop = this.recordId ? this.template.querySelector('.slds-backdrop') : null;
		backdrop?.classList.add('slds-backdrop_open');
		let resultados = this.template.querySelector('.resultados');
		this.template.querySelector('.divResultados').classList.remove('divResultadosOculto');
		this.resultadosBuscadorCerrarBind = this.resultadosBuscadorCerrar.bind(this, resultados, backdrop);
		this.template.querySelector('.inputBuscar').addEventListener('blur', this.resultadosBuscadorCerrarBind);
	}

	resultadosBuscadorCerrar(resultados, backdrop) {
		if (!resultados) {
			resultados = this.template.querySelector('.resultados');
		}
		if (!backdrop) {
			backdrop = this.template.querySelector('.slds-backdrop');
		}

		this.template.querySelector('.divResultados').classList.add('divResultadosOculto');
		backdrop?.classList.remove('slds-backdrop_open');

		this.template.querySelector('.inputBuscar').removeEventListener('blur', this.resultadosBuscadorCerrarBind);
	}

	inputBuscarOnchange(event) {
		window.clearTimeout(this.idTimeoutBusqueda);
		let inputBuscar = event.currentTarget;
		this.valorBusqueda = inputBuscar.value;
		//eslint-disable-next-line @lwc/lwc/no-async-operation
		this.idTimeoutBusqueda = window.setTimeout(() => {
			if (inputBuscar.value.length < 3) {
				this.actualizarResultados(this.recientes);
				this.mostrandoRecientes = true;
			} else {
				this.buscarClasificaciones(inputBuscar.value, inputBuscar);
			}
		}, 180);
	}

	buscarClasificaciones(valorBusqueda, inputBuscar = this.template.querySelector('.inputBuscar')) {
		inputBuscar.isLoading = true;
		buscar({ tipoBusqueda: this.tipoBusqueda.nombre, valorBusqueda: valorBusqueda.replace(/ /g, '%') })
			.then(resultados => {
				resultados = this.resaltarResultados(resultados);
				this.actualizarResultados(resultados);
				this.mostrandoRecientes = false;
			}).catch(error => {
				console.error(error);
				this.mostrarToast('error', 'Problema buscando las clasificaciones', error.body.message);
			}).finally(() => inputBuscar.isLoading = false);
	}

	resaltarResultados(resultados) {
		if (this.valorBusqueda) {
			const terminosBusqueda = this.valorBusqueda.toLowerCase().split(' ');
			const coincide = texto => terminosBusqueda.some(termino => termino && texto.includes(termino));
			resultados = resultados.map(resultado => resultado = {
				...resultado,
				classListTematica: coincide(resultado.CC_Producto_Servicio__r.CC_Tematica__r.Name.toLowerCase()) ? 'badgeResultado badgeResultadoMatch' : 'badgeResultado',
				styleTematica: resultado.CC_Producto_Servicio__r.CC_Tematica__r.CC_Color_En_Buscador__c ? 'border-color: ' + resultado.CC_Producto_Servicio__r.CC_Tematica__r.CC_Color_En_Buscador__c + ';' : '',
				classListProducto: coincide(resultado.CC_Producto_Servicio__r.Name.toLowerCase()) ? 'badgeResultado badgeResultadoMatch' : 'badgeResultado',
				styleProducto: resultado.CC_Producto_Servicio__r.CC_Color_En_Buscador__c ? 'border-color: ' + resultado.CC_Producto_Servicio__r.CC_Color_En_Buscador__c + ';' : '',
				classListMotivo: coincide(resultado.Name.toLowerCase()) ? 'badgeResultado badgeResultadoMatch' : 'badgeResultado',
				styleMotivo: resultado.CC_Color_En_Buscador__c ? 'border-color: ' + resultado.CC_Color_En_Buscador__c + ';' : ''
			});
		} else {
			resultados = resultados.map(resultado => resultado = {
				...resultado,
				classListTematica: 'badgeResultado', classListProducto: 'badgeResultado', classListMotivo: 'badgeResultado'
			});
		}
		return resultados;
	}

	inputBuscarOnkeydown(event) {
		if (this.resultados.length) {
			if (event.which === 38 || event.which === 40) {
				const resultadosIndexSeleccionadoOld = this.resultadosIndexSeleccionado;
				event.preventDefault();
				if (event.which === 38 && this.resultadosIndexSeleccionado > 0) { //↑
					this.resultadosIndexSeleccionado--;
				} else if (event.which === 40 && this.resultadosIndexSeleccionado < this.resultados.length - 1) { //↓
					this.resultadosIndexSeleccionado++;
				}
				if (this.resultadosIndexSeleccionado !== resultadosIndexSeleccionadoOld) {
					let resultadoSpans = this.template.querySelectorAll('.spanResultado');
					resultadoSpans.forEach(resultadoSpan => resultadoSpan.classList.remove('spanResultadoSeleccionado'));
					resultadoSpans[this.resultadosIndexSeleccionado].classList.add('spanResultadoSeleccionado');
				}
			} else if (event.which === 13 && this.resultadosIndexSeleccionado !== -1) { //Intro
				let resultadoSpans = this.template.querySelectorAll('.spanResultado');
				this.seleccionarResultado(resultadoSpans[this.resultadosIndexSeleccionado].closest('.resultado').dataset.id);
				event.preventDefault();
			}
		}
		if (event.which === 27 && !event.currentTarget.value) { //ESC
			this.template.querySelector('.spanDummy').focus();
			event.stopPropagation();
		}
	}

	resultadoOnmousedown(event) {
		event = event || window.event;
		if (!event.which || event.which !== 3 && !event.button || event.button !== 2) {
			//No es click derecho
			this.seleccionarResultado(event.currentTarget.dataset.id);
		} else {
			event.preventDefault();
		}
	}

	seleccionarResultado(idResultado) {
		this.resultadosBuscadorCerrar();
		//eslint-disable-next-line @lwc/lwc/no-async-operation
		window.setTimeout((id => {
			this.clasificacionSeleccionada = { ...this.resultados.find(resultado => resultado.Id === id) };
			//eslint-disable-next-line @lwc/lwc/no-async-operation
			window.setTimeout(() => {
				this.template.querySelector('.clasificacionSeleccionada').classList.add('clasificacionSeleccionadaVisible');
				this.template.querySelector('.botonGuardar')?.focus();
			}, 100, this);
		}).bind(this, idResultado), 100);
	}

	deseleccionarResultado() {
		this.template.querySelector('.clasificacionSeleccionada').classList.remove('clasificacionSeleccionadaVisible');
		//eslint-disable-next-line @lwc/lwc/no-async-operation
		window.setTimeout(() => {
			this.clasificacionSeleccionada = null;
			//eslint-disable-next-line @lwc/lwc/no-async-operation
			window.setTimeout(() => {
				let inputBuscar = this.template.querySelector('.inputBuscar');
				if (inputBuscar) {
					inputBuscar.focus();
				}
			}, 200);
		}, 65, this);
	}

	guardar() {
		this.guardando = true;
		const fields = {};
		fields['Id'] = this.recordId;
		fields['CC_MCC_Tematica__c'] = this.clasificacionSeleccionada.CC_Producto_Servicio__r.CC_Tematica__c;
		fields['CC_MCC_ProdServ__c'] = this.clasificacionSeleccionada.CC_Producto_Servicio__c;
		fields['CC_MCC_Motivo__c'] = this.clasificacionSeleccionada.Id;
		updateRecord({ fields })
			.then(() => {
				this.mostrarToast('success', 'Se actualizó clasificación del Caso', 'Se actualizó correctamente la clasificación del caso ' + getFieldValue(this.caso, CASE_CASE_NUMBER));
				this.clasificacionSeleccionada = null;
				this.actualizarResultados(this.recientes);
				this.valorBusqueda = '';
			}).catch(error => {
				console.error(JSON.stringify(error));
				this.mostrarToast('error', 'Problema actualizando la clasificación del caso', this.errorMessage(error));
			}).finally(() => this.guardando = false);
	}

	mostrarToast(tipo, titulo, mensaje) {
		this.dispatchEvent(new ShowToastEvent({
			variant: tipo, title: titulo, message: mensaje, mode: 'dismissable', duration: 4000
		}));
	}

	eventStopPropagation(event) {
		event.stopPropagation();
	}

	actualizarResultados(resultados) {
		this.resultadosIndexSeleccionado = -1;
		if (resultados) {
			this.resultados = resultados.map(resultado => {
				let clasificacionCompleta = resultado.CC_Producto_Servicio__r.CC_Tematica__r.Name;
				clasificacionCompleta += ' → ' + resultado.CC_Producto_Servicio__r.Name;
				clasificacionCompleta += ' → ' + resultado.Name;
				return { ...resultado, clasificacionCompleta: clasificacionCompleta };
			});
		}
	}

	menuTipoBusquedaOnclick(event) {
		let menuTipoBusquedaComboboxResultados = this.template.querySelector('.menuTipoBusqueda .slds-combobox');
		if (!menuTipoBusquedaComboboxResultados.classList.contains('slds-is-open')) {
			menuTipoBusquedaComboboxResultados.classList.add('slds-is-open');
			event.stopPropagation();
			this.tipoBusquedaCerrarBind = this.menuTipoBusquedaCerrar.bind(this, menuTipoBusquedaComboboxResultados);
			window.addEventListener('click', this.tipoBusquedaCerrarBind);
		} else {
			this.menuTipoBusquedaCerrar(menuTipoBusquedaComboboxResultados);
		}
	}

	menuTipoBusquedaCerrar(menuTipoBusquedaComboboxResultados = this.template.querySelector('.menuTipoBusqueda .slds-combobox')) {
		menuTipoBusquedaComboboxResultados.classList.remove('slds-is-open');
		window.removeEventListener('click', this.tipoBusquedaCerrarBind);
	}

	seleccionarTipoBusqueda(event) {
		const nuevoTipoBusqueda = this.opcionesTipoBusqueda.find(opcion => opcion.nombre === event.currentTarget.dataset.nombreTipoBusqueda);
		if (nuevoTipoBusqueda.nombre !== this.tipoBusqueda.nombre) {
			this.tipoBusqueda = nuevoTipoBusqueda;
			this.opcionesTipoBusqueda = this.opcionesTipoBusqueda.map(opcion => ({ ...opcion, iconoClasslist: opcion.nombre === this.tipoBusqueda.nombre ? '' : 'slds-hide' }));
			const inputBuscar = this.template.querySelector('.inputBuscar');
			this.buscarClasificaciones(inputBuscar.value, inputBuscar);
		}
		this.funcionRenderedCallback = () => this.template.querySelector('.inputBuscar').focus();
		this.menuTipoBusquedaCerrar();
	}

	inputBuscarOnclick(event) {
		if (this.template.querySelector('.menuTipoBusqueda .slds-combobox').classList.contains('slds-is-open')) {
			event.preventDefault();
		}
	}

	errorMessage(error) {
		if (error.body) {
			if (error.body.output) {
				return error.body.output.errors[0].message;
			} else {
				return error.body.message;
			}
		} else {
			return error.message;
		}
	}
}