import {LightningElement, api, wire} from 'lwc';
import {getRecord, getFieldValue} from 'lightning/uiRecordApi';
import {errorApex, toast} from 'c/csbd_lwcUtils';

import getEmpresasProveedorasApex from '@salesforce/apex/CSBD_BuscadorProducto_Apex.getEmpresasProveedoras';
import getProductosApex from '@salesforce/apex/CSBD_BuscadorProducto_Apex.getProductos';

import OPP_RECORDTYPE_NAME from '@salesforce/schema/Opportunity.RecordType.Name';
import OPP_EMPRESA_PROVEEDORA from '@salesforce/schema/Opportunity.CSBD_Empresa_Proveedora__c';

export default class csbdBuscadorProducto extends LightningElement {

	componente = {inputOnchangeTimeout: null, renderResultados: false};

	@api recordId;

	oportunidad;

	empresasProveedoras;

	busqueda = '';

	resultados = [];

	resultadoSeleccionado;

	renderedCallback() {
		if (this.componente.renderResultados) {
			this.componente.renderResultados = false;
			this.refs.buscador.classList.toggle('sinResultados', !this.resultados.length);
			this.refs.input.isLoading = false;
		}
	}

	@wire(getRecord, {recordId: '$recordId', fields: [OPP_RECORDTYPE_NAME, OPP_EMPRESA_PROVEEDORA]})
	wireOpportunity({error, data}) {
		if (error) {
			errorApex(error);
		} else {
			this.oportunidad = data;
		}
	}

	inputOnfocus() {
		//this.refs.buscador.classList.toggle('slds-is-open', this.busqueda);
		if (this.busqueda) {
			this.abrirDropdown();
		} else {
			this.cerrarDropdown();
		}
	}

	inputOnblur() {
		//this.refs.buscador.classList.remove('slds-is-open');
		this.cerrarDropdown();
	}

	inputOnchange({currentTarget: input, detail: {value: busqueda}}) {
		this.busqueda = busqueda;
		window.clearTimeout(this.componente.inputOnchangeTimeout);
		if (!busqueda) {
			this.cerrarDropdown();
		} else {
			this.abrirDropdown();
			this.componente.inputOnchangeTimeout = window.setTimeout(async () => {
				this.resultados = [];

				if (busqueda.length === 1) {
					this.refs.buscador.classList.remove('sinResultados');
					this.refs.buscador.classList.add('sinBusqueda');
				} else {
					this.refs.buscador.classList.remove('sinBusqueda');
					//this.refs.buscador.classList.add('sinResultados');

					/*
					input.isLoading = true;
					if (busqueda) {
						this.abrirDropdown();
					} else {
						this.cerrarDropdown();
					}
					*/
					await this.getEmpresasProveedoras();
					this.componente.renderResultados = true;
					this.resultados = await this.buscarProductos(busqueda);
				}
			}, 500);
		}
	}

	async getEmpresasProveedoras() {
		if (!this.empresasProveedoras) {
			const recordTypeName = getFieldValue(this.oportunidad, OPP_RECORDTYPE_NAME);
			const empresasProveedoras = await getEmpresasProveedorasApex({recordTypeName});
			this.empresasProveedoras = empresasProveedoras.map(e => e.Name);
		}
	}

	async buscarProductos(busqueda, recordTypeName = getFieldValue(this.oportunidad, OPP_RECORDTYPE_NAME)) {
		let resultados = [];
		const productos = await getProductosApex({recordTypeName, busqueda});
		productos.forEach(producto => {
			const familiaEmpresaMulti = producto.CC_Lista__r.CSBD_Empresa_Proveedora_Multi__c ?? '';
			const familiaEmpresas = familiaEmpresaMulti.includes(';') ? familiaEmpresaMulti.split(';') : [familiaEmpresaMulti];
			familiaEmpresas.filter(familiaEmpresa => this.empresasProveedoras.includes(familiaEmpresa)).forEach(empresa => {
				resultados.push({
					idResultado: `${empresa}.${producto.CC_Lista__c}.${producto.Name}`,
					empresa,
					familia: producto.CC_Lista__r.Name,
					producto: producto.Name,
					title: `${empresa} → ${producto.CC_Lista__r.Name} → ${producto.Name}`
				});
			});
		});
		const empresaOportunidad = getFieldValue(this.oportunidad, OPP_EMPRESA_PROVEEDORA);
		if (empresaOportunidad) {
			resultados = resultados.filter(r => r.empresa === empresaOportunidad);
		}
		return resultados.sort((a, b) => a.empresa.localeCompare(b.empresa)
			|| a.familia.localeCompare(b.familia)
			|| a.producto.localeCompare(b.producto));
	}

	abrirDropdown() {
		this.refs.backdrop.classList.add('slds-backdrop_open');
		this.refs.buscador.classList.toggle('slds-is-open', this.busqueda);
	}

	cerrarDropdown() {
		this.refs.buscador.classList.remove('slds-is-open');
		this.refs.backdrop.classList.remove('slds-backdrop_open');
	}

	resultadoSeleccionar({currentTarget: {dataset: {idResultado}}}) {
		this.cerrarDropdown();
		window.setTimeout(() => {
			this.resultadoSeleccionado = this.resultados.find(r => r.idResultado === idResultado);
			this.template.querySelector('div.slds-combobox_container').classList.add('slds-has-selection');
		}, 160);
	}

	resultadoDeseleccionar() {
		this.resultadoSeleccionado = null;
		this.template.querySelector('div.slds-combobox_container').classList.remove('slds-has-selection');
		if (this.busqueda) {
			this.abrirDropdown();
		}
	}
}