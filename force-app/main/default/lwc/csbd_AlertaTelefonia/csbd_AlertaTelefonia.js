import {LightningElement, api, wire, track} from 'lwc';
import {getRecord, getFieldValue} from 'lightning/uiRecordApi';

import OPP_IS_CLOSED from '@salesforce/schema/Opportunity.IsClosed';
import OPP_PRODUCTO_MIFID from '@salesforce/schema/Opportunity.CSBD_Producto_MIFID__c';
import OPP_TELEFONO from '@salesforce/schema/Opportunity.CSBD_Telefono_Solicitud__c';
import OPP_TIPO_BONIFICADO from '@salesforce/schema/Opportunity.CSBD_TipoBonificado__c';

//eslint-disable-next-line
export default class csbdAlertaTelefonia extends LightningElement {

	@api recordId;

	cargaInicial = true;

	@track alertas = {
		productoMifid: {mostrar: false, visto: false},
		tipoBonificado: {mostrar: false, visto: false}
	};

	@track datos = {telefonoSolicitud: null, tipoBonificado: null};

	@wire(getRecord, {recordId: '$recordId', fields: [OPP_IS_CLOSED, OPP_PRODUCTO_MIFID, OPP_TELEFONO, OPP_TIPO_BONIFICADO]})
	wiredOportunidad({data, error}) {
		if (error) {
			console.error(error);
		} else if (data) {
			if (!getFieldValue(data, OPP_IS_CLOSED)) {

				if (getFieldValue(data, OPP_TIPO_BONIFICADO)) {
					this.alertas.tipoBonificado.mostrar = true;
					this.datos.tipoBonificado = getFieldValue(data, OPP_TIPO_BONIFICADO);
				}
				if (getFieldValue(data, OPP_PRODUCTO_MIFID)) {
					this.alertas.productoMifid.mostrar = true;
					this.datos.telefonoSolicitud = getFieldValue(data, OPP_TELEFONO);
				}

				if (this.cargaInicial) {
					//eslint-disable-next-line @lwc/lwc/no-async-operation
					window.setTimeout(() => {
						if (this.alertas.tipoBonificado.mostrar && !this.alertas.tipoBonificado.visto) {
							this.abrirModal('tipoBonificado');
						} else if (this.alertas.productoMifid.mostrar && !this.alertas.productoMifid.visto) {
							this.abrirModal('productoMifid');
						}
					}, 700);
				}
				this.cargaInicial = false;
			}
		}
	}

	abrirModal(nombreModal) {
		const modal = this.template.querySelector('section.' + nombreModal);
		modal.classList.remove('slds-hide');
		//eslint-disable-next-line @lwc/lwc/no-async-operation
		window.setTimeout(() => {
			this.alertas[nombreModal].visto = true;
			this.template.querySelector('.slds-backdrop').classList.add('slds-backdrop_open');
			modal.classList.add('modalAbierto');
			//eslint-disable-next-line @lwc/lwc/no-async-operation
			window.setTimeout(() => this.template.querySelector('.' + nombreModal + 'BotonCerrar').disabled = false, 1100);
		}, 180);
	}

	cerrarModal(event) {
		const nombreModal = event.currentTarget.dataset.nombreModal;
		const modal = this.template.querySelector('section.' + nombreModal);
		if (modal) {
			modal.classList.remove('modalAbierto');
			//eslint-disable-next-line @lwc/lwc/no-async-operation
			window.setTimeout(() => modal.classList.add('slds-hide'), 360);

			if (nombreModal === 'tipoBonificado' && this.alertas.productoMifid.mostrar) {
				this.abrirModal('productoMifid');
			} else {
				this.template.querySelector('.slds-backdrop').classList.remove('slds-backdrop_open');
			}
		}
	}
}