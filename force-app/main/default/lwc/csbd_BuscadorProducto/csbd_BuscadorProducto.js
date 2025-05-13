import {LightningElement, api, wire} from 'lwc';
import {getRecord, getFieldValue} from 'lightning/uiRecordApi';
import {errorApex, esperar, publicarEvento} from 'c/csbd_lwcUtils';

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
		if (this.busqueda) {
			this.abrirDropdown();
		} else {
			this.cerrarDropdown();
		}
	}

	inputOnchange({currentTarget: input, detail: {value: busqueda}}) {

		this.busqueda = busqueda;
		window.clearTimeout(this.componente.inputOnchangeTimeout);
		if (!busqueda) {
			this.cerrarDropdown();
		} else {
			this.abrirDropdown();
			this.componente.inputOnchangeTimeout = window.setTimeout(async () => {
				await this.getEmpresasProveedoras();

				if (busqueda.length === 1) {
					this.refs.buscador.classList.remove('sinResultados');
					this.refs.buscador.classList.add('sinBusqueda');
					this.abrirDropdown();
				} else {
					input.isLoading = true;
					this.refs.buscador.classList.remove('sinBusqueda');
					//this.refs.buscador.classList.add('sinResultados');

					this.componente.renderResultados = true;
					this.resultados = await this.buscarProductos(busqueda);
					if (this.resultados.length) {
						await esperar(0).then(() => {
							const dropdown = this.refs.dropdown;
							dropdown.offsetHeight;
							const newHeight = Math.min(dropdown.scrollHeight + 2, 400);
							dropdown.style.maxHeight = newHeight + 'px';

							this.refs.buscador.classList.remove('sinResultados');
							input.isLoading = false;
						});
					} else {
						this.refs.buscador.classList.add('sinResultados');
						input.isLoading = false;
					}
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
					empresaLabel: empresa.replace(new RegExp(busqueda, 'gi'), match => `<strong>${match}</strong>`),
					resaltarEmpresa: empresa.includes(busqueda),
					familia: producto.CC_Lista__r.Name,
					familiaLabel: producto.CC_Lista__r.Name.replace(new RegExp(busqueda, 'gi'), match => `<strong>${match}</strong>`),
					resaltarFamilia: producto.CC_Lista__r.Name.includes(busqueda),
					producto: producto.Name,
					productoLabel: producto.Name.replace(new RegExp(busqueda, 'gi'), match => `<strong>${match}</strong>`),
					resaltarProducto: producto.Name.includes(busqueda),
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
		esperar(0).then(() => {
			if (!this.refs.input.value) {
				return;
			}
			if (!this.refs.buscador.classList.contains('slds-is-open')) {
				const backdrop = this.refs.backdrop;
				backdrop.addEventListener('click', event => {
					event.stopPropagation();
					this.cerrarDropdown();
				}, {once: true});
				backdrop.classList.add('slds-backdrop_open');

				/*const dropdown = this.refs.dropdown;
				dropdown.addEventListener('transitionend', () => {
					dropdown.scrollIntoView({behavior: 'smooth', block: 'center', inline: 'nearest'});
				}, {once: true}); */
				this.refs.buscador.classList.add('slds-is-open');
			}

			this.refs.dropdown.style.maxHeight = Math.min(this.refs.dropdown.scrollHeight + 2, 400) + 'px';
		});
	}

	cerrarDropdown() {
		this.refs.dropdown.style.maxHeight = '0px';
		esperar(150).then(() => {
			this.refs.buscador.classList.remove('slds-is-open');
			this.refs.backdrop.classList.remove('slds-backdrop_open');
		});
	}

	resultadoSeleccionar({currentTarget: {dataset: {idResultado}}}) {
		esperar(50).then(() => {
			this.cerrarDropdown();
			esperar(150).then(() => {
				//this.resultadoSeleccionado = this.resultados.find(r => r.idResultado === idResultado);
				//publicarEvento(this, 'resultadoseleccionado', {resultado: this.resultadoSeleccionado});
				//this.template.querySelector('div.slds-combobox_container').classList.add('slds-has-selection');
				publicarEvento(this, 'resultadoseleccionado', {resultado: this.resultados.find(r => r.idResultado === idResultado)});
			});
		});
	}

	resultadoDeseleccionar() {
		this.resultadoSeleccionado = null;
		this.template.querySelector('div.slds-combobox_container').classList.remove('slds-has-selection');
		if (this.busqueda) {
			this.abrirDropdown();
		}
	}
}