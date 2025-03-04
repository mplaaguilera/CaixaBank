import {LightningElement, api, wire, track} from 'lwc';
import {getRecord, getFieldValue, updateRecord} from 'lightning/uiRecordApi';
import {ShowToastEvent} from 'lightning/platformShowToastEvent';

import OPPTY_IDENTIFICADOR from '@salesforce/schema/Opportunity.CSBD_Identificador__c';
import OPPTY_MEDIOS_PAGO_JSON from '@salesforce/schema/Opportunity.CSBD_MediosPagoJson__c';
import OPPTY_TIPO_CONSTRUCCION from '@salesforce/schema/Opportunity.CSBD_TipoConstruccion2__c';
import OPPTY_PRECIO_INMUEBLE from '@salesforce/schema/Opportunity.CSBD_PrecioInmueble__c';
import OPPTY_AMOUNT from '@salesforce/schema/Opportunity.Amount';
import OPPTY_APORTACION_INICIAL from '@salesforce/schema/Opportunity.CSBD_AportacionInicial__c';
import OPPTY_DONACION from '@salesforce/schema/Opportunity.CSBD_OC_Donacion__c';

const CAMPOS = [OPPTY_IDENTIFICADOR, OPPTY_MEDIOS_PAGO_JSON, OPPTY_TIPO_CONSTRUCCION,
	OPPTY_PRECIO_INMUEBLE, OPPTY_AMOUNT, OPPTY_APORTACION_INICIAL, OPPTY_DONACION];

export default class csbdMediosDePago extends LightningElement {

	@api recordId;

	@track oportunidad;

	@track mediosPago = {};

	get pagosTotal() {
		let pagosTotal = getFieldValue(this.oportunidad, OPPTY_PRECIO_INMUEBLE) ?? 0;
		pagosTotal -= getFieldValue(this.oportunidad, OPPTY_APORTACION_INICIAL) ?? 0;
		pagosTotal -= this.mediosPago.pagosProvisionFondosVendedor ?? 0;
		return pagosTotal;
	}

	get desgloseTotalImportes() {
		const parse = x => x ? parseFloat(x) : 0;
		let desgloseTotalImportes = parse(this.mediosPago.desglosePagos1Importe);
		desgloseTotalImportes += parse(this.mediosPago.desglosePagos2Importe);
		desgloseTotalImportes += parse(this.mediosPago.desglosePagos3Importe);
		desgloseTotalImportes += parse(this.mediosPago.desglosePagos4Importe);
		desgloseTotalImportes += parse(this.mediosPago.desglosePagos5Importe);
		desgloseTotalImportes += parse(this.mediosPago.desglosePagos6Importe);
		desgloseTotalImportes += parse(this.mediosPago.desglosePagos7Importe);
		desgloseTotalImportes += parse(this.mediosPago.desglosePagos8Importe);
		desgloseTotalImportes += parse(this.mediosPago.desglosePagos9Importe);
		desgloseTotalImportes += parse(this.mediosPago.desglosePagos10Importe);
		return desgloseTotalImportes;
	}

	get desembolsoPrestamoTotal() {
		let desembolsoPrestamoTotal = getFieldValue(this.oportunidad, OPPTY_AMOUNT) ?? 0;
		desembolsoPrestamoTotal -= this.mediosPago.desembolsoPrestamoPrevision ?? 0;
		return desembolsoPrestamoTotal;
	}

	get aportarClienteIva() {
		let aportarClienteIva = 0;
		if (getFieldValue(this.oportunidad, OPPTY_TIPO_CONSTRUCCION) === 'Nueva construcción') {
			aportarClienteIva = (getFieldValue(this.oportunidad, OPPTY_PRECIO_INMUEBLE) ?? 0) * 0.1;
		}
		return aportarClienteIva;
	}

	get aportarClienteTotalImporte() {
		let aportarClienteTotalImporte = this.pagosTotal;
		aportarClienteTotalImporte += this.aportarClienteIva ?? 0;
		//aportarClienteTotalImporte -= this.mediosPago.desembolsoPrestamoPrevision ?? 0;
		aportarClienteTotalImporte -= this.desembolsoPrestamoTotal ?? 0;
		return aportarClienteTotalImporte;
	}

	/*
	get totalFondosPropiosOld() {
		const importeCompraventa = getFieldValue(this.oportunidad, OPPTY_PRECIO_INMUEBLE) ?? 0;
		let totalFondosPropios = importeCompraventa - (getFieldValue(this.oportunidad, OPPTY_AMOUNT) ?? 0);
		totalFondosPropios += importeCompraventa * 0.1;
		return totalFondosPropios;
	}
	*/

	get totalFondosPropios() {
		const segundaMano = getFieldValue(this.oportunidad, OPPTY_TIPO_CONSTRUCCION) === 'Segunda mano';

		let totalFondosPropios = getFieldValue(this.oportunidad, OPPTY_PRECIO_INMUEBLE) ?? 0;
		totalFondosPropios *= segundaMano ? 1 : 1.1;
		totalFondosPropios -= getFieldValue(this.oportunidad, OPPTY_APORTACION_INICIAL) ?? 0;
		totalFondosPropios -= getFieldValue(this.oportunidad, OPPTY_AMOUNT) ?? 0;
		totalFondosPropios += Number(this.mediosPago.desembolsoPrestamoPrevision ?? 0);
		return totalFondosPropios;
	}

	get totalDonacion() {
		let totalDonacion = this.pagosTotal;
		totalDonacion -= getFieldValue(this.oportunidad, OPPTY_APORTACION_INICIAL) ?? 0;
		totalDonacion -= getFieldValue(this.oportunidad, OPPTY_DONACION) ?? 0;
		return totalDonacion;
	}

	@wire(getRecord, {recordId: '$recordId', fields: CAMPOS})
	async wiredRecord({data, error: errorGetRecord}) {
		try {
			if (data) {
				this.oportunidad = data;
				const jsonMediosPago = getFieldValue(data, OPPTY_MEDIOS_PAGO_JSON);
				if (jsonMediosPago) {
					this.mediosPago = JSON.parse(jsonMediosPago);
				}
			} else if (errorGetRecord) {
				throw errorGetRecord;
			}
		} catch (error) {
			console.error(error);
			this.toast('error', 'Problema recuperando los datos de la oportunidad', error.body?.message ?? error);
		}
	}

	seccionOnclick(event) {
		event.currentTarget.closest('.slds-section').classList.toggle('slds-is-open');
	}

	campoOnchange(event) {
		this.mediosPago[event.currentTarget.dataset.campo] = event.detail.value;
	}

	guardar(event) {
		const botonGuardar = event.currentTarget;
		botonGuardar.disabled = true;

		//Si ningún campo tiene valor se vacía el campo, si no se guarda JSON
		let mediosPagoJson = '';
		if (Object.values(this.mediosPago).some(v => v !== null && v !== '')) {
			mediosPagoJson = JSON.stringify(this.mediosPago, null, 3);
		}

		const campos = {};
		campos.Id = this.recordId;
		campos[OPPTY_MEDIOS_PAGO_JSON.fieldApiName] = mediosPagoJson;
		updateRecord({fields: campos})
		.then(() => this.toast('success', 'Se actualizó correctamente la oportunidad', 'Se actualizó correctamente la oportunidad ' + getFieldValue(this.oportunidad, OPPTY_IDENTIFICADOR)))
		.catch(error => {
			console.error(error);
			this.toast('error', 'Problema actualizando Oportunidad', error.body?.message);
		}).finally(() => botonGuardar.disabled = false);
	}

	toast(variant, title, message) {
		dispatchEvent(new ShowToastEvent({variant, title, message, mode: 'dismissable', duration: 4000}));
	}
}