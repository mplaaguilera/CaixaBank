/*eslint-disable @lwc/lwc/no-async-await */
import {LightningElement, api, track, wire} from 'lwc';
import {getRecord, getFieldValue} from 'lightning/uiRecordApi';
import {ShowToastEvent} from 'lightning/platformShowToastEvent';
import {NavigationMixin} from 'lightning/navigation';
import UserId from '@salesforce/user/Id';
import {RESOLUCIONES, ETAPAS} from './options';

import obtenerOportunidadesHijasApex from '@salesforce/apex/CSBD_ProductoOportunidadHija.obtenerOportunidadesHijas';
import crearOportunidadesApex from '@salesforce/apex/CSBD_ProductoOportunidadHija.crearOportunidadesHijas';
import obtenerProductosApex from '@salesforce/apex/CSBD_ProductoOportunidadHija.obtenerProductos';
import buscarCuentasApex from '@salesforce/apex/CSBD_ProductoOportunidadHija.searchAccounts';
import duplicarApex from '@salesforce/apex/CSBD_ProductoOportunidadHija.duplicarOpp';

import OPP_RECORD_TYPE from '@salesforce/schema/Opportunity.RecordType.Name';
import OPP_RECORD_TYPE_DEVELOPER from '@salesforce/schema/Opportunity.RecordType.DeveloperName';
import OPP_OWNER from '@salesforce/schema/Opportunity.OwnerId';
import OPP_STAGE from '@salesforce/schema/Opportunity.StageName';
import CSBD_RESUMEN from '@salesforce/schema/Opportunity.CSBD_Resumen__c';
import CSBD_PARENTID from '@salesforce/schema/Opportunity.CSBD_Parent_Id__c';

const ESTADOS_FINALES = ['Rechazada', 'Formalizada', 'Perdida'];

//eslint-disable-next-line new-cap
export default class csbdProductoOportunidadHija extends NavigationMixin(LightningElement) {
	@api recordId;

	oportunidad;

	habilitar2oTitular = false;

	oportunidadesHijas = {enCurso: [], formalizadas: [], perdidas: []};

	mostrarOportunidadesHijas = false;

	mostrarResolucion = false;

	comboboxProductosOptionsMaster = [];

	comboboxProductosOptions = [];

	@track productosSeleccionados = [];

	comboboxEtapaOptions = ETAPAS;

	comboboxResolucionOptions = [];

	resoluciones = RESOLUCIONES;

	modal1Abierto = false;

	modal2Abierto = false;

	lookupClienteResultados = [];

	lookupClienteSeleccionado;

	lookupClienteInputValue = '';

	lookupClienteTimeout;

	productosCreados=[];

	@wire(getRecord, {recordId: '$recordId', fields: [OPP_RECORD_TYPE, OPP_OWNER, OPP_STAGE, OPP_RECORD_TYPE_DEVELOPER, CSBD_RESUMEN, CSBD_PARENTID]})
	wiredRecord({error, data}) {
		if (data) {
			this.oportunidad = data;
			this.habilitar2oTitular = !getFieldValue(data, CSBD_PARENTID);
			window.setTimeout(() => this.obtenerOportunidadesHijas(), 1500);
		} else if (error) {
			console.error(error);
			this.mostrarToast('error', 'Problema obteniendo los datos de la oportunidad', '');
		}
	}

	obtenerOportunidadesHijas() {
		obtenerOportunidadesHijasApex({oportunidadId: this.recordId})
		.then(response => {
			if (response.length) {
				const oportunidades = response.map(o => {
					this.productosCreados.push(o.CSBD_Producto__c);
					const producto = o.CSBD_Producto__c ? o.CSBD_Producto__c : o.CSBD_Familia_Producto__c ? o.CSBD_Familia_Producto__c : o.Name;
					return {...o, producto: producto};
				});
				this.oportunidadesHijas.formalizadas = oportunidades
					.filter(o => o.StageName === 'Formalizada')
					.sort((a, b) => a.producto.localeCompare(b.producto));
				this.oportunidadesHijas.perdidas = oportunidades
					.filter(o => ['Perdida', 'Rechazada'].includes(o.StageName))
					.sort((a, b) => a.producto.localeCompare(b.producto));
				this.oportunidadesHijas.enCurso = oportunidades
					.filter(o => !['Formalizada', 'Perdida', 'Rechazada'].includes(o.StageName))
					.sort((a, b) => a.producto.localeCompare(b.producto));
				this.oportunidadesHijas = {...this.oportunidadesHijas};
				this.comboboxProductosOptions = [];
				this.comboboxProductosOptionsMaster = [];
				this.mostrarOportunidadesHijas = true;
			} else {
				this.mostrarOportunidadesHijas = false;
			}
		}).catch(error => console.error(error));
	}

	async modal1Abrir() {
		if (!this.comboboxProductosOptionsMaster.length) {
			await this.obtenerProductos();
		} else {
			this.comboboxProductosOptions = [...this.comboboxProductosOptionsMaster];
		}

		let mensajeToast;
		if (UserId !== getFieldValue(this.oportunidad, OPP_OWNER)) {
			mensajeToast = 'Debe ser el propietario de la oportunidad';
		} else if (ESTADOS_FINALES.includes(getFieldValue(this.oportunidad, OPP_STAGE))) {
			mensajeToast = 'La oportunidad debe estar activa';
		} else if (!this.comboboxProductosOptions.length) {
			mensajeToast = 'No hay acciones comerciales definidas para oportunnidades de tipo "' + getFieldValue(this.oportunidad, OPP_RECORD_TYPE) + '"';
		}

		if (mensajeToast) {
			this.mostrarToast('info', 'Alta de acciones comerciales no disponible', mensajeToast);
		} else {
			this.productosSeleccionados = [];
			this.modal1Abierto = true;
			//eslint-disable-next-line @lwc/lwc/no-async-operation
			window.setTimeout(() => {
				this.template.querySelector('.backdrop').classList.add('slds-backdrop_open');
				this.template.querySelector('.modal1').classList.add('slds-fade-in-open');
				this.template.querySelector('.modal1Cancelar').focus();
			}, 300);
		}
	}

	async obtenerProductos() {
		await obtenerProductosApex({nombreRecordType: getFieldValue(this.oportunidad, OPP_RECORD_TYPE)})
		.then(productos => {
			this.comboboxProductosOptionsMaster = productos.map(p => ({label: p.CC_Valor2__c, value: p.CC_Valor2__c}));
			this.comboboxProductosOptionsMaster = this.comboboxProductosOptionsMaster.filter(o => !this.productosCreados.includes(o.value));
			this.comboboxProductosOptionsMaster.sort((a, b) => a.value.toUpperCase().localeCompare(b.value.toUpperCase()));
			this.comboboxProductosOptionsMaster = [...this.comboboxProductosOptionsMaster];
			this.comboboxProductosOptions = [...this.comboboxProductosOptionsMaster];
		}).catch(error => console.error(error));
	}

	modal1Cerrar() {
		this.template.querySelector('.modal1').classList.remove('slds-fade-in-open');
		this.template.querySelector('.backdrop').classList.remove('slds-backdrop_open');
		//eslint-disable-next-line @lwc/lwc/no-async-operation
		window.setTimeout(() => {
			this.modal1Abierto = false;
			this.mostrarResolucion = false;
		}, 400);
	}

	modal1GuardarOnclick() {
		const productos = this.template.querySelector('.comboboxProductos');
		const etapa = this.template.querySelector('.comboboxEtapa');
		const resolucion = this.template.querySelector('.comboboxResolucion');

		if (!this.productosSeleccionados.length) {
			productos.setCustomValidity('Selecciona al menos un producto.');
			productos.reportValidity();
		}
		etapa.reportValidity();
		if (this.mostrarResolucion) {
			resolucion.reportValidity();
		}
		if (productos.validity.valid && etapa.validity.valid && (!resolucion || resolucion.validity.valid)) {
			this.crearOportunidades();
		}
	}

	comboboxProductosOnchange(event) {
		event.target.setCustomValidity('');
		event.target.reportValidity();
		this.productosSeleccionados.push(event.detail.value);
		this.comboboxProductosOptions.splice(this.comboboxProductosOptions.findIndex(o => o.value === event.detail.value), 1);
		event.currentTarget.value = null;
		this.comboboxProductosOptions = [...this.comboboxProductosOptions];
	}

	pillProductoOnremove(event) {
		this.productosSeleccionados.splice(this.productosSeleccionados.indexOf(event.target.name), 1);
		this.comboboxProductosOptions.push({label: event.target.name, value: event.target.name});
		this.comboboxProductosOptions.sort((a, b) => a.value.toUpperCase().localeCompare(b.value.toUpperCase()));
		this.comboboxProductosOptions = [...this.comboboxProductosOptions];
	}

	comboboxEtapaOnchange(event) {
		if (!ESTADOS_FINALES.includes(event.target.value)) {
			this.mostrarResolucion = false;
		} else {
			this.comboboxResolucionOptions = this.resoluciones[event.target.value];
			if (this.mostrarResolucion) {
				this.template.querySelector('.comboboxResolucion').value = null;
			} else {
				this.mostrarResolucion = true;
			}
		}
	}

	crearOportunidades() {
		const modal1Guardar = this.template.querySelector('.modal1Guardar');
		modal1Guardar.disabled = true;
		const comboboxResolucion = this.template.querySelector('.comboboxResolucion');
		crearOportunidadesApex({
			productos: this.productosSeleccionados,
			estado: this.template.querySelector('.comboboxEtapa').value,
			parentId: this.recordId,
			nombreRecordType: getFieldValue(this.oportunidad, OPP_RECORD_TYPE),
			resolucion: comboboxResolucion && comboboxResolucion.value
		}).then(identificadores => {
			this.modal1Cerrar();
			let mensajeToast;
			if (identificadores.length === 1) {
				mensajeToast = 'Se creó correctamente la acción comercial';
			} else {
				mensajeToast = 'Se crearon correctamente ' + identificadores.length + ' acciones comerciales: ' + identificadores.join(', ');
			}
			this.mostrarToast('success', 'Se crearon Acciones comerciales', mensajeToast);
			this.obtenerOportunidadesHijas();
		}).catch(error => {
			console.error(error);
			this.mostrarToast('error', 'No se han creado correctamente las Acciones comerciales ');
		}).finally(() => modal1Guardar.disabled = false);
	}

	mostrarToast(variant, title, message) {
		this.dispatchEvent(new ShowToastEvent({variant: variant, title: title, message: message, mode: 'dismissable', duration: 4000}));
	}

	modal2Abrir() {
		this.modal2Abierto = true;
		//eslint-disable-next-line @lwc/lwc/no-async-operation
		window.setTimeout(() => {
			this.template.querySelector('.backdrop').classList.add('slds-backdrop_open');
			this.template.querySelector('.modal2').classList.add('slds-fade-in-open');
			this.template.querySelector('.lookupClienteInput').focus();
		}, 200);
	}

	modal2Cerrar() {
		this.template.querySelector('.backdrop').classList.remove('slds-backdrop_open');
		this.template.querySelector('.modal2').classList.remove('slds-fade-in-open');
		//eslint-disable-next-line @lwc/lwc/no-async-operation
		window.setTimeout(() => {
			this.modal2Abierto = false;
		}, 400);
	}

	modal2GuardarOnclick() {
		if (this.lookupClienteSeleccionado) {
			const modal2Guardar = this.template.querySelector('.modal2Guardar');
			modal2Guardar.disabled = true;
			duplicarApex({
				oppId: this.recordId,
				rt: getFieldValue(this.oportunidad, OPP_RECORD_TYPE_DEVELOPER),
				accId: this.lookupClienteSeleccionado.Id
			}).then(result => {
				this.modal2Cerrar();
				this.mostrarToast('success', 'Oportunidad creada correctamente.', '');
				this.navegarRegistro(result.Id);
				this.obtenerOportunidadesHijas();
			}).catch(error => {
				console.error(error);
				this.mostrarToast('error', 'Error al crear la oportunidad', error.body.message);
			}).finally(() => modal2Guardar.disabled = true);
		} else {
			const lookupClienteInput = this.template.querySelector('.lookupClienteInput');
			lookupClienteInput.setCustomValidity('Completa este campo.');
			lookupClienteInput.reportValidity();
		}
	}

	/*
	addAcc(event) {
		let variableAuxiliarCodigoboton = event.currentTarget.id;
		let idAVincular;
		for (let i = 0; i < variableAuxiliarCodigoboton.length - 1; i++) {
			if (variableAuxiliarCodigoboton.charAt(i) === '-') {
				idAVincular = variableAuxiliarCodigoboton.substring(0, i);
			}
		}
		let cuenta;

		for (let miCuenta in this.cuentasEncontradas) {
			if (this.cuentasEncontradas[miCuenta].Id === idAVincular) {
				cuenta = this.cuentasEncontradas[miCuenta];
			}
		}
		this.hayAcc = true;
		this.cuentaSeleccionada = cuenta;
		this.cuentasEncontradas = [];
		this.searchKey = cuenta.Name;
		if (cuenta.CC_Numero_Documento__c) {
			this.searchKey += ' - NIF: ' + cuenta.CC_Numero_Documento__c;
		}
	}
	*/

	menuHeaderOnselect(event) {
		if (event.detail.value === 'Segundo titular') {
			this.modal2Abrir();
		}
	}

	modalTeclaPulsada(event) {
		if (event.keyCode === 27) { //ESC
			if (event.currentTarget.dataset.modal === 'modal1') {
				this.modal1Cerrar();
			} else if (event.currentTarget.dataset.modal === 'modal2') {
				this.modal2Cerrar();
			}
		}
	}

	oportunidadOnclick(event) {
		this.navegarRegistro(event.currentTarget.dataset.id);
	}

	navegarRegistro(idRegistro) {
		this[NavigationMixin.Navigate]({
			type: 'standard__recordPage',
			attributes: {recordId: idRegistro, actionName: 'view'}
		});
	}

	lookupClienteAbrir() {
		const lookupClienteInput = this.template.querySelector('.lookupClienteInput');
		lookupClienteInput.setCustomValidity('');
		lookupClienteInput.reportValidity();
		if (this.lookupClienteInputValue.length > 1) {
			this.template.querySelector('.lookupCliente').classList.add('slds-is-open');
		}
	}

	lookupClienteCerrar() {
		//eslint-disable-next-line @lwc/lwc/no-async-operation
		window.setTimeout(() => {
			const lookupCliente = this.template.querySelector('.lookupCliente');
			if (lookupCliente) {
				lookupCliente.classList.remove('slds-is-open');
			}
		}, 150);
	}

	lookupClienteOnkeydown(event) {
		if (event.keyCode === 27 && this.lookupClienteInputValue) { //ESC
			event.stopPropagation();
		}
	}

	lookupClienteOnchange(event) {
		this.lookupClienteInputValue = event.detail.value;
		window.clearTimeout(this.lookupClienteTimeout);
		if (this.lookupClienteInputValue.length > 2) {
			//eslint-disable-next-line @lwc/lwc/no-async-operation
			this.lookupClienteTimeout = window.setTimeout(() => this.buscarClientes(this.lookupClienteInputValue), 500);
		} else {
			event.target.isLoading = false;
			this.template.querySelector('.lookupCliente').classList.remove('slds-is-open');
			this.lookupClienteResultados = [];
		}
	}

	lookupClienteSeleccionar(event) {
		const cliente = this.lookupClienteResultados.find(c => c.Id === event.currentTarget.dataset.id);
		this.lookupClienteSeleccionado = cliente;
	}

	lookupClienteDeseleccionar() {
		this.lookupClienteSeleccionado = null;
		//eslint-disable-next-line @lwc/lwc/no-async-operation
		window.setTimeout(() => {
			this.lookupClienteAbrir();
			this.template.querySelector('.lookupClienteInput').focus();
		}, 200);
	}

	buscarClientes(cadenaBusqueda) {
		let lookupClienteInput = this.template.querySelector('.lookupClienteInput');
		lookupClienteInput.isLoading = true;
		buscarCuentasApex({cadenaBusqueda: cadenaBusqueda})
		.then(clientes => {
			if (cadenaBusqueda === this.lookupClienteInputValue) {
				//No se ha modificado la cadena de búsqueda durante la ejecución del Apex
				this.lookupClienteResultados = clientes;
				this.template.querySelector('.lookupCliente').classList.add('slds-is-open');
			}
		}).catch(error => console.error(error))
		.finally(() => lookupClienteInput.isLoading = false);
	}
}