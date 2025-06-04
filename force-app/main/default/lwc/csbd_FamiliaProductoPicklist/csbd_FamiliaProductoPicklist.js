import {LightningElement, api, wire} from 'lwc';
import {MessageContext, subscribe, unsubscribe} from 'lightning/messageService';
import csbdOpportunityMessageChannel from '@salesforce/messageChannel/CSBD_Opportunity_MessageChannel__c';
import currentUserId from '@salesforce/user/Id';
import {getRecord, updateRecord, getFieldValue, notifyRecordUpdateAvailable} from 'lightning/uiRecordApi';
import LightningConfirm from 'lightning/confirm';
import {ShowToastEvent} from 'lightning/platformShowToastEvent';
import {errorApex, formatExcepcion} from 'c/csbd_lwcUtils';

import getFamiliasApex from '@salesforce/apex/CSBD_FamiliaProductoPicklistController.getFamilias';
import getProductosApex from '@salesforce/apex/CSBD_FamiliaProductoPicklistController.getProductos';
import getEmpresasApex from '@salesforce/apex/CSBD_FamiliaProductoPicklistController.getEmpresas';
import getMotivosMacApex from '@salesforce/apex/CSBD_FamiliaProductoPicklistController.getMotivosMac';

import OPP_RT_NAME from '@salesforce/schema/Opportunity.RecordType.Name';
import OPP_OWNER_ID from '@salesforce/schema/Opportunity.OwnerId';
import OPP_FAMILIA_PROD from '@salesforce/schema/Opportunity.CSBD_Familia_Producto__c';
import OPP_PRODUCTO from '@salesforce/schema/Opportunity.CSBD_Producto__c';
import OPP_EMPRESA from '@salesforce/schema/Opportunity.CSBD_Empresa_Proveedora__c';
import OPP_FINALIDAD from '@salesforce/schema/Opportunity.CSBD_Finalidad__c';
import OPP_VEHICULO from '@salesforce/schema/Opportunity.CSBD_Vehiculo_Renting__c';
import OPP_DETALLE_PROD from '@salesforce/schema/Opportunity.CSBD_Detalle_producto__c';
import OPP_CANAL from '@salesforce/schema/Opportunity.CSBD_Canal__c';
import OPP_MOTIVO_MAC from '@salesforce/schema/Opportunity.CSBD_Motivo_MAC__c';
import OPP_NOW_ORIGEN from '@salesforce/schema/Opportunity.CSBD_Now_Origen__c';
import OPP_NOW_ORIGEN_FUENTE from '@salesforce/schema/Opportunity.CSBD_Now_Origen_Fuente__c';
import OPP_NOW_ORIGEN_ENTORNO from '@salesforce/schema/Opportunity.CSBD_Now_Origen_Entorno__c';
import OPP_NOW_ORIGEN_PAGINA from '@salesforce/schema/Opportunity.CSBD_Now_Origen_Pagina__c';
import OPP_NOW_ORIGEN_TIPO_CAMPAÑA from '@salesforce/schema/Opportunity.CSBD_Now_Origen_Tipo_Campanya__c';
import OPP_NOW_ORIGEN_MEDIO from '@salesforce/schema/Opportunity.CSBD_Now_Origen_Medio__c';
import OPP_NOW_ORIGEN_NOMBRE_CAMPAÑA from '@salesforce/schema/Opportunity.CSBD_Now_Origen_Nombre_Campanya__c';
import OPP_DELIMITADOR from '@salesforce/schema/Opportunity.CSBD_Delimitador__c';
import OPP_GARANTIA from '@salesforce/schema/Opportunity.CSBD_Garantia__c';

const OPP_FIELDS = [
	OPP_RT_NAME, OPP_OWNER_ID,
	OPP_EMPRESA, OPP_FAMILIA_PROD, OPP_PRODUCTO, OPP_MOTIVO_MAC,
	OPP_FINALIDAD, OPP_DETALLE_PROD, OPP_VEHICULO, OPP_CANAL,
	OPP_NOW_ORIGEN, OPP_NOW_ORIGEN_FUENTE, OPP_NOW_ORIGEN_ENTORNO,
	OPP_NOW_ORIGEN_PAGINA, OPP_NOW_ORIGEN_TIPO_CAMPAÑA,
	OPP_NOW_ORIGEN_MEDIO, OPP_NOW_ORIGEN_NOMBRE_CAMPAÑA,
	OPP_DELIMITADOR, OPP_GARANTIA
];

export default class csbdFamiliaProductoPicklist extends LightningElement {
	@api recordId;

	subscription;

	boundHandleClick;

	boundHandleWindowClick;

	oportunidad;

	editando = false;

	mensajeError;

	spinner = false;

	opcionesCargadas = {empresas: false, familiasProducto: false, productos: false, motivosMac: false};

	opcionesEmpresaProveedora = [];

	empresaProveedora = this.valueToOpcion('--Ninguno--');

	opcionesFamiliaProducto = [];

	familiaProducto = this.valueToOpcion('--Ninguno--');

	opcionesProducto = [];

	producto = this.valueToOpcion('--Ninguno--');

	opcionesMotivoMac = [];

	motivoMac = this.valueToOpcion('--Ninguno--');

	formularioOrigenVisible = false;

	vehiculo;

	finalidad;

	detalleProducto;

	delimitador;

	garantia;

	canal;

	origen;

	detallesOrigen = {
		hayDetalles: false,
		fuente: null,
		entorno: null,
		pagina: null,
		tipoCampaña: null,
		medio: null,
		nombreCampaña: null
	};

	mostrar = {
		motivoMac: false,
		finalidad: false,
		detalleProducto: false,
		vehiculo: false,
		camposPrestamoPersonaJuridica: false
	};

	//funcionEventListener = this.windowOnclick;

	@wire(MessageContext) messageContext;


	@wire(getRecord, {recordId: '$recordId', fields: OPP_FIELDS})
	wiredRecord({error, data}) {
		if (data) {
			this.oportunidad = data;
			if (this.editando) {
				return;
			}

			const editados = this.template.querySelectorAll('div.slds-form-element.slds-is-edited');
			editados.forEach(c => c.classList.remove('slds-is-edited'));

			const formatFieldValue = fieldValue => fieldValue ?? '--Ninguno--';

			const empresaProveedora = formatFieldValue(getFieldValue(data, OPP_EMPRESA));
			if (empresaProveedora !== this.empresaProveedora?.value) {
				this.empresaProveedora = this.valueToOpcion(empresaProveedora);
			}
			if (!this.opcionesEmpresaProveedora.length && !this.opcionesCargadas.empresas) {
				this.opcionesEmpresaProveedora = [this.empresaProveedora];
			}

			const familiaProducto = formatFieldValue(getFieldValue(data, OPP_FAMILIA_PROD));
			if (familiaProducto !== this.familiaProducto?.value) {
				this.familiaProducto = this.valueToOpcion(familiaProducto);
			}
			if (!this.opcionesFamiliaProducto.length && !this.opcionesCargadas.familiasProducto) {
				this.opcionesFamiliaProducto = [this.familiaProducto];
			}

			const producto = formatFieldValue(getFieldValue(data, OPP_PRODUCTO));
			if (producto !== this.producto?.value) {
				this.producto = this.valueToOpcion(producto);
			}
			if (!this.opcionesProducto.length && !this.opcionesCargadas.productos) {
				this.opcionesProducto = [this.producto];
			}

			this.mostrar.motivoMac = getFieldValue(data, OPP_RT_NAME) === 'CSCC';
			if (this.mostrar.motivoMac) {
				const motivoMac = formatFieldValue(getFieldValue(data, OPP_MOTIVO_MAC));
				if (motivoMac !== this.motivoMac?.value) {
					this.motivoMac = this.valueToOpcion(motivoMac);
					if (!this.opcionesMotivoMac.length || !this.opcionesCargadas.motivosMac) {
						this.opcionesMotivoMac = [this.motivoMac];
					}
				}
			}

			this.mostrar.finalidad = familiaProducto === 'Hipotecas';
			if (this.mostrar.finalidad) {
				this.finalidad = getFieldValue(data, OPP_FINALIDAD);
			}

			this.mostrar.detalleProducto = familiaProducto === 'Wivai' || producto === 'Wivai';
			if (this.mostrar.detalleProducto) {
				this.detalleProducto = getFieldValue(data, OPP_DETALLE_PROD);
			}

			this.mostrar.vehiculo = familiaProducto === 'Renting' || producto === 'Renting';
			if (this.mostrar.vehiculo) {
				this.vehiculo = getFieldValue(data, OPP_VEHICULO);
			}

			this.mostrar.camposPrestamoPersonaJuridica = getFieldValue(data, OPP_RT_NAME) === 'Consumo';
			if (this.mostrar.camposPrestamoPersonaJuridica) {
				this.delimitador = getFieldValue(data, OPP_DELIMITADOR);
				this.garantia = getFieldValue(data, OPP_GARANTIA);
			}

			this.canal = getFieldValue(data, OPP_CANAL);
			this.origen = getFieldValue(data, OPP_NOW_ORIGEN);
			this.detallesOrigen = {
				fuente: getFieldValue(data, OPP_NOW_ORIGEN_FUENTE),
				entorno: getFieldValue(data, OPP_NOW_ORIGEN_ENTORNO),
				pagina: getFieldValue(data, OPP_NOW_ORIGEN_PAGINA),
				tipoCampaña: getFieldValue(data, OPP_NOW_ORIGEN_TIPO_CAMPAÑA),
				medio: getFieldValue(data, OPP_NOW_ORIGEN_MEDIO),
				nombreCampaña: getFieldValue(data, OPP_NOW_ORIGEN_NOMBRE_CAMPAÑA)
			};
			this.detallesOrigen.hayDetalles = this.objetoConAlgunValor(this.detallesOrigen);
			this.detallesOrigen = {...this.detallesOrigen};

		} else if (error) {
			console.error(error);
			this.toast('error', 'Problema recuperando los datos del producto de la oportunidad', JSON.stringify(error));
		}
	}

	connectedCallback() {
		!this.subscription && (this.subscription = subscribe(
			this.messageContext, csbdOpportunityMessageChannel, message => this.messageChannelOnmessage(message)
		));
	}

	disconnectedCallback() {
		unsubscribe(this.subscription);
		this.subscription = null;
	}

	comboboxEmpresasOnfocus() {
		if (!this.opcionesCargadas.empresas) {
			this.getEmpresas();
		}
	}

	getEmpresas() {
		const comboboxEmpresas = this.template.querySelector('.comboboxEmpresas');
		comboboxEmpresas.spinnerActive = true;
		getEmpresasApex({nombreRecordType: getFieldValue(this.oportunidad, OPP_RT_NAME)})
		.then(empresasProveedoras => {
			let empresasProveedorasAux = empresasProveedoras.map(e => this.valueToOpcion(e.Name));
			if (!empresasProveedorasAux.some(e => e.value === this.empresaProveedora.value)) {
				empresasProveedorasAux.push(this.valueToOpcion(this.empresaProveedora.value));
			}
			empresasProveedorasAux.sort((a, b) => a?.label?.localeCompare(b?.label));
			this.opcionesEmpresaProveedora = empresasProveedorasAux;
			this.opcionesCargadas.empresas = true;
		}).catch(error => errorApex(this, error, 'Problema recuperando la lista de empresas proveedoras seleccionables'))
		.finally(() => comboboxEmpresas.spinnerActive = false);
	}

	comboboxEmpresasOnchange({detail: {value: nuevaEmpresa}}) {
		this.familiaProducto = this.valueToOpcion('--Ninguno--');
		this.opcionesFamiliaProducto = [this.familiaProducto];
		this.opcionesCargadas.familiasProducto = false;
		this.producto = this.valueToOpcion('--Ninguno--');
		this.opcionesProducto = [this.producto];
		this.opcionesCargadas.productos = false;
		this.motivoMac = this.valueToOpcion('--Ninguno--');
		this.opcionesMotivoMac = [this.motivoMac];
		this.opcionesCargadas.motivosMac = false;
		this.empresaProveedora = this.valueToOpcion(nuevaEmpresa);
		if (nuevaEmpresa !== '--Ninguno--') {
			this.template.querySelector('.comboboxFamilias').focus();
		}
		const comboboxes = this.template.querySelectorAll('div.slds-form-element:has(.comboboxEmpresas, .comboboxProductos, .comboboxFamilias)');
		comboboxes.forEach(c => c.classList.add('slds-is-edited'));
		//this.actualizarOportunidad();
	}

	comboboxFamiliasProductoOnfocus() {
		if (!this.opcionesCargadas.familiasProducto) {
			this.getFamiliasProducto();
		}
	}

	getFamiliasProducto() {
		const comboboxFamilias = this.template.querySelector('.comboboxFamilias');
		comboboxFamilias.spinnerActive = true;
		getFamiliasApex({nombreRecordType: getFieldValue(this.oportunidad, OPP_RT_NAME), empresaProveedora: this.empresaProveedora.value})
		.then(familiasProducto => {
			let familiasProductoAux = familiasProducto.map(f => this.valueToOpcion(f.Name));
			if (!familiasProductoAux.some(f => f.value === this.familiaProducto.value)) {
				familiasProductoAux.push(this.valueToOpcion(this.familiaProducto.value));
			}
			familiasProductoAux.sort((a, b) => a?.label?.localeCompare(b?.label));
			this.opcionesFamiliaProducto = familiasProductoAux;
			this.opcionesCargadas.familiasProducto = true;
		}).catch(error => errorApex(this, error, 'Problema recuperando la lista de familias de producto seleccionables'))
		.finally(() => comboboxFamilias.spinnerActive = false);
	}

	comboboxFamiliasProductoOnchange({detail: {value: nuevaFamiliaProducto}}) {
		this.producto = this.valueToOpcion('--Ninguno--');
		this.opcionesProducto = [this.producto];
		this.opcionesCargadas.productos = false;
		this.motivoMac = this.valueToOpcion('--Ninguno--');
		this.opcionesMotivoMac = [this.motivoMac];
		this.opcionesCargadas.motivosMac = false;
		this.familiaProducto = this.valueToOpcion(nuevaFamiliaProducto);
		if (nuevaFamiliaProducto !== '--Ninguno--') {
			this.template.querySelector('.comboboxProductos').focus();
		}
		const comboboxes = this.template.querySelectorAll('div.slds-form-element:has(lightning-combobox.comboboxProductos, lightning-combobox.comboboxFamilias)');
		comboboxes.forEach(c => c.classList.add('slds-is-edited'));
	}

	comboboxProductosOnfocus() {
		if (!this.opcionesCargadas.productos) {
			this.getProductos();
		}
	}

	getProductos() {
		const comboboxProductos = this.template.querySelector('.comboboxProductos');
		comboboxProductos.spinnerActive = true;
		getProductosApex({familia: this.familiaProducto.value, nombreRecordType: getFieldValue(this.oportunidad, OPP_RT_NAME)})
		.then(productos => {
			let productosAux = productos.map(p => this.valueToOpcion(p.Name));
			if (!productosAux.some(p => p.value === this.producto.value)) {
				productosAux.push(this.valueToOpcion(this.producto.value));
			}
			productosAux.sort((a, b) => a?.label?.localeCompare(b?.label));
			this.opcionesProducto = productosAux;
			this.opcionesCargadas.productos = true;
		}).catch(error => errorApex(this, error, 'Problema recuperando la lista de productos seleccionables'))
		.finally(() => comboboxProductos.spinnerActive = false);
	}

	comboboxProductosOnchange({currentTarget: comboboxProductos, detail: {value: nuevoProducto}}) {
		this.motivoMac = this.valueToOpcion('--Ninguno--');
		this.opcionesMotivoMac = [this.motivoMac];
		this.opcionesCargadas.motivosMac = false;
		this.producto = this.valueToOpcion(nuevoProducto);
		comboboxProductos.closest('div.slds-form-element').classList.add('slds-is-edited');
	}

	comboboxMotivosMacOnfocus() {
		if (!this.opcionesCargadas.motivosMac) {
			this.getMotivosMac();
		}
	}

	getMotivosMac() {
		const comboboxMotivosMac = this.template.querySelector('.comboboxMotivosMac');
		comboboxMotivosMac.spinnerActive = true;
		getMotivosMacApex({producto: this.producto.value})
		.then(motivosMac => {
			let motivosMacAux = motivosMac.map(m => this.valueToOpcion(m.CC_Lista__r.Name));
			if (!motivosMacAux.some(m => m.value === this.motivoMac.value)) {
				motivosMacAux.push(this.valueToOpcion(this.motivoMac.value));
			}
			motivosMacAux.sort((a, b) => a?.label?.localeCompare(b?.label));
			this.opcionesMotivoMac = motivosMacAux;
			this.opcionesCargadas.motivosMac = true;
		}).catch(error => errorApex(this, error, 'Problema recuperando la lista de Motivos CSCC seleccionables'))
		.finally(() => comboboxMotivosMac.spinnerActive = false);
	}

	comboboxMotivosMacOnchange({currentTarget: comboboxMotivosMac, detail: {value: nuevoMotivo}}) {
		this.motivoMac = this.valueToOpcion(nuevoMotivo);
		comboboxMotivosMac.closest('div.slds-form-element').classList.add('slds-is-edited');
	}

	inicioEditando() {
		this.editando = true;
		this.boundHandleClick = this.handleClick.bind(this);
		this.boundHandleWindowClick = this.handleWindowClick.bind(this);
		this.template.addEventListener('click', this.boundHandleClick);
		window.addEventListener('click', this.boundHandleWindowClick);
		this.refs.cardComponente.classList.add('editando');
	}

	handleClick(event) {
		//Si el click és dins del component, l'aturem aquí
		event.stopPropagation();
	}

	handleWindowClick(event) {
		//Si l'event ha arribat aquí és que ve de fora del component
		event.preventDefault();
		event.stopPropagation();

		if (this.spinner) {
			return;
		}

		if (!this.hayCambiosSinGuardar()) {
			this.finEditando(false);
			return;
		}

		this.mostrarDialogConfirmacion();
	}

	mostrarDialogConfirmacion() {
		//Eliminem els listeners abans de mostrar el diàleg
		this.removeEventListeners();

		//Guardem la posició actual del scroll
		const scrollPos = {
			x: window.scrollX,
			y: window.scrollY
		};

		LightningConfirm.open({
			variant: 'header',
			theme: 'warning',
			label: 'Descartar cambios',
			message: '¿Quieres descartar los cambios sin guardar?'
		}).then(result => {
			if (result) {
				this.finEditando(false);
			} else {
				//Esperem una mica abans de tornar a afegir els listeners
				//per evitar que capturin el click del botó de cancel
				window.setTimeout(() => {
					//Restaurem la posició del scroll
					window.scrollTo(scrollPos.x, scrollPos.y);

					this.boundHandleClick = this.handleClick.bind(this);
					this.boundHandleWindowClick = this.handleWindowClick.bind(this);
					this.template.addEventListener('click', this.boundHandleClick);
					window.addEventListener('click', this.boundHandleWindowClick);
				}, 0);
			}
		});
	}

	async finEditando(guardarCambios = true) {
		this.cerrarPopoverError();
		if (this.hayCambiosSinGuardar()) {
			if (guardarCambios) {
				if (getFieldValue(this.oportunidad, OPP_OWNER_ID) !== currentUserId) {
					this.abrirPopoverError('Solo el propietario de la oportunidad puede modificarla.');
					return;
				}
				if (!await this.actualizarOportunidad()) { //Error actualizando la oportunidad
					return;
				}
			} else {
				this.empresaProveedora = this.valueToOpcion(getFieldValue(this.oportunidad, OPP_EMPRESA));
				this.familiaProducto = this.valueToOpcion(getFieldValue(this.oportunidad, OPP_FAMILIA_PROD));
				this.producto = this.valueToOpcion(getFieldValue(this.oportunidad, OPP_PRODUCTO));
				this.motivoMac = this.valueToOpcion(getFieldValue(this.oportunidad, OPP_MOTIVO_MAC));
			}
		}

		this.editando = false;
		this.refs.cardComponente.classList.remove('editando', 'error');
		this.removeEventListeners();
	}

	removeEventListeners() {
		if (this.boundHandleClick) {
			this.template.removeEventListener('click', this.boundHandleClick);
			this.boundHandleClick = null;
		}
		if (this.boundHandleWindowClick) {
			window.removeEventListener('click', this.boundHandleWindowClick);
			this.boundHandleWindowClick = null;
		}
	}

	hayCambiosSinGuardar() {
		return [
			[OPP_EMPRESA, this.empresaProveedora], [OPP_FAMILIA_PROD, this.familiaProducto],
			[OPP_PRODUCTO, this.producto], [OPP_MOTIVO_MAC, this.motivoMac]
		].some(([campo, opcion]) => this.opcionToValue(opcion) !== getFieldValue(this.oportunidad, campo));
	}

	async actualizarOportunidad() {
		this.spinner = true;

		const fields = {};
		fields.Id = this.recordId;
		fields[OPP_EMPRESA.fieldApiName] = this.opcionToValue(this.empresaProveedora);
		fields[OPP_FAMILIA_PROD.fieldApiName] = this.opcionToValue(this.familiaProducto);
		fields[OPP_PRODUCTO.fieldApiName] = this.opcionToValue(this.producto);
		fields[OPP_MOTIVO_MAC.fieldApiName] = this.opcionToValue(this.motivoMac);
		const recordInput = {fields};

		let updateOk = true;
		try {
			await updateRecord(recordInput);
			notifyRecordUpdateAvailable([{recordId: this.recordId}]); //Evita un problema de refresco del Aura CSBD_Opportunity_Operativas
		} catch (error) {
			console.error(error);
			this.abrirPopoverError(formatExcepcion(error));
			updateOk = false;
		} finally {
			this.spinner = false;
		}
		return updateOk;
	}

	cancelar() {
		this.finEditando(false);
	}

	guardar() {
		this.finEditando();
	}

	tituloSeccionOnclick() {
		if (!this.editando) {
			this.refs.seccion.classList.toggle('slds-is-open');
		}
	}

	cardComponenteOnclick(event) {
		this.cerrarPopoverError();
		event.stopPropagation();
	}

	toast(variant, title, message) {
		this.dispatchEvent(new ShowToastEvent({variant: variant, title: title, message: message, mode: 'dismissable', duration: 4000}));
	}

	mostrarFormularioOrigen() {
		this.formularioOrigenVisible = !this.formularioOrigenVisible;
	}

	objetoConAlgunValor(objeto) {
		for (let clave in objeto) {
			if (Object.prototype.hasOwnProperty.call(objeto, clave) && objeto[clave]) {
				return true;
			}
		}
		return false;
	}

	valueToOpcion(value) {
		return {value, label: value, labelNoEdit: value === '--Ninguno--' ? null : value};
	}

	opcionToValue(opcion) {
		return opcion.value === '--Ninguno--' ? null : opcion.value;
	}

	deshacer({target: {dataset: {campo}}}) {
		const formatFieldValue = fieldValue => fieldValue ?? '--Ninguno--';
		this[campo] = {
			empresaProveedora: this.valueToOpcion(formatFieldValue(getFieldValue(this.oportunidad, OPP_EMPRESA))),
			familiaProducto: this.valueToOpcion(formatFieldValue(getFieldValue(this.oportunidad, OPP_FAMILIA_PROD))),
			producto: this.valueToOpcion(formatFieldValue(getFieldValue(this.oportunidad, OPP_PRODUCTO))),
			motivoMac: this.valueToOpcion(formatFieldValue(getFieldValue(this.oportunidad, OPP_MOTIVO_MAC)))
		}[campo];
	}

	botonErrorOnclick() {
		this.abrirPopoverError();
	}

	abrirPopoverError(mensajeError) {
		this.mensajeError = mensajeError || 'Problema actualizando la oportunidad.';
		this.refs.cardComponente.classList.add('error');
		this.refs.popoverError.classList.add('visible');
	}

	stopPropagation(event) {
		event.stopPropagation();
	}

	cerrarPopoverError() {
		this.refs.popoverError.classList.remove('visible');
	}

	buscadorResultadoSeleccionado({detail: {resultado: {empresa, familia, producto}}}) {
		this.opcionesCargadas = {empresas: false, familiasProducto: false, productos: false};

		const cambios = {
			empresaProveedora: this.empresaProveedora.value !== empresa,
			familiaProducto: this.familiaProducto.value !== familia,
			producto: this.producto.value !== producto
		};

		this.opcionesEmpresaProveedora = [this.valueToOpcion(empresa)];
		this.opcionesFamiliaProducto = [this.valueToOpcion(familia)];
		this.opcionesProducto = [this.valueToOpcion(producto)];

		this.empresaProveedora = this.valueToOpcion(empresa);
		this.familiaProducto = this.valueToOpcion(familia);
		this.producto = this.valueToOpcion(producto);

		let comboboxesSelector = [];
		if (cambios.empresaProveedora) {
			comboboxesSelector.push('.comboboxEmpresas');
		}
		if (cambios.familiaProducto) {
			comboboxesSelector.push('.comboboxFamilias');
		}
		if (cambios.producto) {
			comboboxesSelector.push('.comboboxProductos');
		}

		const comboboxes = this.template.querySelectorAll('div.slds-form-element:has(' + comboboxesSelector.join(', ') + ')');
		comboboxes.forEach(c => c.classList.add('slds-is-edited'));
	}

	messageChannelOnmessage({recordId, type}) {
		if (recordId === this.recordId && type === 'editarProducto') {
			setTimeout(() => {
				this.inicioEditando();
				setTimeout(() => {
					let comboboxFocus;
					if ((this.empresaProveedora?.value ?? '--Ninguno--') !== '--Ninguno--') {
						if ((this.familiaProducto?.value ?? '--Ninguno--') !== '--Ninguno--') {
							comboboxFocus = this.refs.comboboxProductos;
						} else {
							comboboxFocus = this.refs.comboboxFamilias;
						}
					} else {
						comboboxFocus = this.refs.comboboxEmpresas;
					}
					window.addEventListener('scrollend', () => comboboxFocus.focus(), {once: true});
					comboboxFocus.scrollIntoView({behavior: 'smooth', block: 'center'});
				}, 10);
			}, 0);
		}
	}
}