import {LightningElement, api, wire, track} from 'lwc';
import {getRecord, getFieldValue, updateRecord} from 'lightning/uiRecordApi';
import {ShowToastEvent} from 'lightning/platformShowToastEvent';
import LightningConfirm from 'lightning/confirm';

import OPPTY_FINCAS_JSON from '@salesforce/schema/Opportunity.CSBD_FincasJson__c';
import OPPTY_IDENTIFICADOR from '@salesforce/schema/Opportunity.CSBD_Identificador__c';

export default class csbdListaFincas extends LightningElement {

	@api recordId;

	editando = false;

	oportunidad;

	@track fincaSeleccionada;

	fincaSeleccionadaSinModificar;

	opcionesTipoFinca = [
		{label: 'Vivienda', value: 'Vivienda'},
		{label: 'Garaje', value: 'Garaje'},
		{label: 'Trastero', value: 'Trastero'},
		{label: 'Local', value: 'Local'},
		{label: 'Otros', value: 'Otros'}
	];

	opcionesCompraventaHipoteca = [
		{label: 'Compraventa', value: 'Compraventa'},
		{label: 'Hipoteca', value: 'Hipoteca'},
		{label: 'Compraventa + Hipoteca', value: 'Compraventa + Hipoteca'}
	];

	columns = [
		{label: null, hideLabel: true, fixedWidth: 34, hideDefaultActions: true, cellAttributes: {iconName: {fieldName: 'icono'}}},
		{label: 'Código de catastro', fieldName: 'codigoCatastro', hideDefaultActions: true},
		{label: 'Tipo', fieldName: 'tipoFinca', initialWidth: 76, hideDefaultActions: true},
		{label: 'Número', fieldName: 'numeroFinca', initialWidth: 100, hideDefaultActions: true},
		{label: 'Núm. RP', fieldName: 'numeroRp', initialWidth: 90, hideDefaultActions: true},
		{label: 'Localidad', fieldName: 'localidad', initialWidth: 150, hideDefaultActions: true},
		{label: '€ Compraventa', fieldName: 'importeCompraventa', type: 'currency', initialWidth: 125, hideDefaultActions: true},
		{label: '€ Hipoteca', fieldName: 'importeHipoteca', type: 'currency', initialWidth: 100, hideDefaultActions: true},
		{label: 'Compraventa/Hipoteca', fieldName: 'compraventaHipoteca', initialWidth: 162, hideDefaultActions: true}
	];

	fincas = [];

	get botonNuevaDisabled() {
		return this.editando || this.fincas.length === 3;
	}

	get botonEliminarDisabled() {
		return this.editando || !this.fincaSeleccionada || this.fincaSeleccionada.nueva;
	}

	get botonesCancelarGuardarDisabled() {
		return !this.editando;
	}

	@wire(getRecord, {recordId: '$recordId', fields: [OPPTY_FINCAS_JSON, OPPTY_IDENTIFICADOR]})
	async wiredRecord({data, error: errorGetRecord}) {
		try {
			if (data) {
				this.oportunidad = data;
				const jsonFincas = getFieldValue(data, OPPTY_FINCAS_JSON);
				if (jsonFincas) {
					const fincas = JSON.parse(jsonFincas).map(f => ({...f, nueva: false}));
					if (fincas.length) {
						this.fincas = fincas;
						if (!this.fincaSeleccionada) {
							this.seleccionarFinca(fincas[0].id);
						}
					}
				}
			} else if (errorGetRecord) {
				throw errorGetRecord;
			}
		} catch (error) {
			console.error(error);
			this.toast('error', 'Problema recuperando los datos de la oportunidad', error.message ?? error);
		}
	}

	nuevaFinca() {
		this.inicioEditar();
		const idNuevaFinca = (new Date().getTime() % 1000).toString().padStart(3, '0');
		this.fincas = [...this.fincas, {
			nueva: true,
			id: idNuevaFinca,
			codigoCatastro: null,
			tipoFinca: 'Vivienda',
			numeroFinca: null,
			numeroRp: null,
			localidad: null,
			importeCompraventa: null,
			importeHipoteca: null,
			compraventaHipoteca: 'Compraventa'
		}];
		this.seleccionarFinca(idNuevaFinca);
		window.setTimeout(() => this.template.querySelector('.codigoCatastro').focus(), 0);
	}

	datatableOnrowselection(event) {
		if (this.fincaSeleccionadaValida()) {
			if (event.detail.selectedRows.length) {
				this.seleccionarFinca(event.detail.selectedRows[0].id);
			}
		} else {
			event.detail.selectedRows = this.template.querySelector('.datatableFincas').selectedRows;
		}
	}

	seleccionarFinca(idFinca) {
		const datatableFincas = this.template.querySelector('.datatableFincas');
		if (idFinca) {
			this.fincas = this.fincas.map(f => ({...f, icono: null}));
			this.fincaSeleccionada = this.fincas.find(f => f.id === idFinca);
			this.fincaSeleccionada.icono = 'standard:address';
			datatableFincas.selectedRows = [idFinca];
			if (!this.fincaSeleccionada.nueva) {
				window.setTimeout(() => {
					const campos = this.template.querySelectorAll('div.campos lightning-input, div.campos lightning-combobox');
					campos.forEach(c => c.reportValidity());
				}, 0);
			}
		} else {
			this.fincaSeleccionada = null;
			datatableFincas.selectedRows = [];
		}
	}

	fincaSeleccionadaOnchange(event) {
		this.inicioEditar();
		const campo = event.currentTarget.dataset.campo;
		this.fincaSeleccionada[campo] = event.detail.value.trim();
		this.fincas = [...this.fincas];
	}

	fincaSeleccionadaValida() {
		let fincaValida = true;
		const campos = this.template.querySelectorAll('div.campos lightning-input, div.campos lightning-combobox');
		campos.forEach(c => {
			fincaValida = fincaValida && c.checkValidity();
			c.reportValidity();
		});
		return fincaValida;
	}

	guardarFincas(event) {
		if (this.fincaSeleccionadaValida()) {
			event.currentTarget.disabled = true;

			const campos = {};
			campos.Id = this.recordId;
			campos[OPPTY_FINCAS_JSON.fieldApiName] = JSON.stringify(this.fincas, null, 3);
			updateRecord({fields: campos})
			.then(() => {
				this.fincaSeleccionada.nueva = false;
				this.fincaSeleccionadaSinModificar = null;
				this.toast('success', 'Se actualizó correctamente la oportunidad', 'Se actualizó correctamente la oportunidad ' + getFieldValue(this.oportunidad, OPPTY_IDENTIFICADOR));
				this.finEditar();
			}).catch(error => {
				console.error(error);
				this.toast('error', 'Problema actualizando Oportunidad', error.body?.message);
			});
		}
	}

	deshacerCambios() {
		if (this.fincaSeleccionada.nueva) {
			//Deshacer nueva finca
			const indexFincaSeleccionada = this.fincas.findIndex(f => f.id === this.fincaSeleccionada.id);
			this.fincas.splice(indexFincaSeleccionada, 1);
			this.fincas = [...this.fincas];
			if (!this.fincas.length) {
				this.seleccionarFinca(null);
			} else if (this.fincas.length === indexFincaSeleccionada) {
				this.seleccionarFinca(this.fincas[indexFincaSeleccionada - 1].id);
			} else if (this.fincas.length >= indexFincaSeleccionada) {
				this.seleccionarFinca(this.fincas[indexFincaSeleccionada].id);
			}
		} else {
			//Deshacer modificaciones de finca existente
			this.fincaSeleccionada = {...this.fincaSeleccionadaSinModificar};
			this.fincaSeleccionadaSinModificar = null;

			const indexFincaSeleccionada = this.fincas.findIndex(f => f.id === this.fincaSeleccionada.id);
			this.fincas[indexFincaSeleccionada] = this.fincaSeleccionada;
			this.fincas = [...this.fincas];

			window.setTimeout(() => {
				const campos = this.template.querySelectorAll('div.campos lightning-input, div.campos lightning-combobox');
				campos.forEach(c => c.reportValidity());
			}, 0);
		}
		this.finEditar();
	}

	async eliminarFincaSeleccionada() {
		if (await LightningConfirm.open({
			variant: 'header', theme: 'alt-inverse', label: 'Eliminar finca',
			message: '¿Quieres eliminar la finca seleccionada?'
		})) {
			const indexFincaSeleccionada = this.fincas.findIndex(f => f.id === this.fincaSeleccionada.id);
			this.fincas.splice(indexFincaSeleccionada, 1);
			this.fincas = [...this.fincas];
			if (!this.fincas.length) {
				this.seleccionarFinca(null);
			} else if (this.fincas.length === indexFincaSeleccionada) {
				this.seleccionarFinca(this.fincas[indexFincaSeleccionada - 1].id);
			} else if (this.fincas.length >= indexFincaSeleccionada - 1) {
				this.seleccionarFinca(this.fincas[indexFincaSeleccionada].id);
			}

			const campos = {};
			campos.Id = this.recordId;
			campos[OPPTY_FINCAS_JSON.fieldApiName] = JSON.stringify(this.fincas, null, 3);
			updateRecord({fields: campos})
			.then(() => this.toast('info', 'Se actualizó correctamente la oportunidad', 'Se eliminó correctamente la finca seleccionada'))
			.catch(error => {
				console.error(error);
				this.toast('error', 'Problema actualizando Oportunidad', error.body?.message);
			});
		}
	}

	toast(variant, title, message) {
		dispatchEvent(new ShowToastEvent({variant, title, message, mode: 'dismissable', duration: 4000}));
	}

	inicioEditar() {
		if (!this.fincaSeleccionadaSinModificar) {
			this.fincaSeleccionadaSinModificar = {...this.fincaSeleccionada};
		}
		this.editando = true;
		this.template.querySelector('.contenedor').classList.add('editando');
	}

	finEditar() {
		this.editando = false;
		this.template.querySelector('.contenedor').classList.remove('editando');
	}
}