import {LightningElement, api, wire} from 'lwc';
import currentUserId from '@salesforce/user/Id';
import {getRecord, updateRecord, getFieldValue} from 'lightning/uiRecordApi';
import {ShowToastEvent} from 'lightning/platformShowToastEvent';
import {errorApex} from 'c/csbd_lwcUtils';

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

const OPP_FIELDS = [
	OPP_RT_NAME, OPP_OWNER_ID,
	OPP_EMPRESA, OPP_FAMILIA_PROD, OPP_PRODUCTO, OPP_MOTIVO_MAC,
	OPP_FINALIDAD, OPP_DETALLE_PROD, OPP_VEHICULO, OPP_CANAL,
	OPP_NOW_ORIGEN, OPP_NOW_ORIGEN_FUENTE, OPP_NOW_ORIGEN_ENTORNO,
	OPP_NOW_ORIGEN_PAGINA, OPP_NOW_ORIGEN_TIPO_CAMPAÑA,
	OPP_NOW_ORIGEN_MEDIO, OPP_NOW_ORIGEN_NOMBRE_CAMPAÑA
];

export default class csbdFamiliaProductoPicklist extends LightningElement {
	@api recordId;

	getRecordTimestamp;

	oportunidad;

	editando = false;

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

	mostrar = {motivoMac: false, finalidad: false, detalleProducto: false, vehiculo: false};

	funcionEventListener;

	@wire(getRecord, {recordId: '$recordId', fields: OPP_FIELDS, timestamp: '$getRecordTimestamp'})
	wiredRecord({error, data}) {
		if (data) {
			const editados = this.template.querySelectorAll('div.slds-form-element.slds-is-edited');
			editados.forEach(c => c.classList.remove('slds-is-edited'));

			this.oportunidad = data;

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

			this.mostrar.motivoMac = getFieldValue(data, OPP_RT_NAME) === 'AC';
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
			empresasProveedorasAux.sort((a, b) => a.label.localeCompare(b.label));
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
			familiasProductoAux.sort((a, b) => a.label.localeCompare(b.label));
			this.opcionesFamiliaProducto = familiasProductoAux;
			this.opcionesCargadas.familiasProducto = true;
		}).catch(error => errorApex(this, error, 'Problema recuperando la lista de familias de producto seleccionables'))
		.finally(() => comboboxFamilias.spinnerActive = false);
	}

	comboboxFamiliasProductoOnchange({detail: {value: nuevaFamiliaProducto}}) {
		this.producto = this.valueToOpcion('--Ninguno--');
		this.opcionesProducto = [this.producto];
		this.opcionesCargadas.productos = false;
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
			productosAux.sort((a, b) => a.label.localeCompare(b.label));
			this.opcionesProducto = productosAux;
			this.opcionesCargadas.productos = true;
		}).catch(error => errorApex(this, error, 'Problema recuperando la lista de productos seleccionables'))
		.finally(() => comboboxProductos.spinnerActive = false);
	}

	comboboxProductosOnchange({currentTarget: comboboxProductos, detail: {value: nuevoProducto}}) {
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
		getMotivosMacApex({})
		.then(motivosMac => {
			let motivosMacAux = motivosMac.map(m => this.valueToOpcion(m.Name));
			if (!motivosMacAux.some(m => m.value === this.motivoMac.value)) {
				motivosMacAux.push(this.valueToOpcion(this.motivoMac.value));
			}
			motivosMacAux.sort((a, b) => a.label.localeCompare(b.label));
			this.opcionesMotivoMac = motivosMacAux;
			this.opcionesCargadas.motivosMac = true;
		}).catch(error => errorApex(this, error, 'Problema recuperando la lista de motivos AC seleccionables'))
		.finally(() => comboboxMotivosMac.spinnerActive = false);
	}

	comboboxMotivosMacOnchange({currentTarget: comboboxMotivosMac, detail: {value: nuevoMotivo}}) {
		this.motivoMac = this.valueToOpcion(nuevoMotivo);
		comboboxMotivosMac.closest('div.slds-form-element').classList.add('slds-is-edited');
	}

	actualizarOportunidad() {
		this.spinner = true;
		const formatOpcion = valor => valor === '--Ninguno--' ? null : valor;
		const fields = {};
		fields.Id = this.recordId;
		fields[OPP_EMPRESA.fieldApiName] = formatOpcion(this.empresaProveedora?.value);
		fields[OPP_FAMILIA_PROD.fieldApiName] = formatOpcion(this.familiaProducto?.value);
		fields[OPP_PRODUCTO.fieldApiName] = formatOpcion(this.producto?.value);
		fields[OPP_MOTIVO_MAC.fieldApiName] = formatOpcion(this.motivoMac?.value);
		const recordInput = {fields};
		updateRecord(recordInput)
		.then(() => {
			const editados = this.template.querySelectorAll('div.slds-form-element.slds-is-edited');
			editados.forEach(c => c.classList.remove('slds-is-edited'));
		}).catch(error => {
			console.error(error);
			if (error.body.output && error.body.output.errors && error.body.output.errors.length) {
				this.toast('error', 'Problema actualizando la oportunidad', error.body.output.errors[0].message);
			}
		}).finally(() => this.spinner = false);
	}

	inicioEditando() {
		this.editando = true;
		this.funcionEventListener = this.windowOnclick.bind(this);
		window.addEventListener('click', this.funcionEventListener);
	}

	finEditando(guardarCambios = true) {
		if (guardarCambios) {
			if (getFieldValue(this.oportunidad, OPP_OWNER_ID) !== currentUserId) {
				this.toast('error', 'No eres el propietario de la oportunidad', 'Solo el propietario de la oportunidad puede modificarla');
			} else {
				guardarCambios && this.actualizarOportunidad();
				this.editando = false;
				window.removeEventListener('click', this.funcionEventListener);
			}
		} else {
			this.editando = false;
			window.removeEventListener('click', this.funcionEventListener);
		}
	}

	tituloSeccionOnclick() {
		this.template.querySelector('.seccion').classList.toggle('slds-is-open');
	}

	stopPropagation(event) {
		event.stopPropagation();
	}

	windowOnclick() {
		this.finEditando();
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

	deshacer() {
		const sinValor = this.valueToOpcion('--Ninguno--');
		this.empresaProveedora = sinValor;
		this.familiaProducto = sinValor;
		this.producto = sinValor;

		this.opcionesEmpresaProveedora = [];
		this.opcionesFamiliaProducto = [];
		this.opcionesProducto = [];

		this.opcionesCargadas = {
			empresas: false, familiasProducto: false, productos: false, motivosMac: false
		};

		this.getRecordTimestamp = new Date(); //Refresca el getRecord()
		this.finEditando(false);
	}

}