import {LightningElement, api, wire, track} from 'lwc';
import {getRecord, getFieldValue} from 'lightning/uiRecordApi';

import OPP_IS_CLOSED from '@salesforce/schema/Opportunity.IsClosed';
import OPP_PRODUCTO_MIFID from '@salesforce/schema/Opportunity.CSBD_Producto_MIFID__c';
import OPP_TELEFONO from '@salesforce/schema/Opportunity.CSBD_Telefono_Solicitud__c';
import OPP_TIPO_BONIFICADO from '@salesforce/schema/Opportunity.CSBD_TipoBonificado__c';
import OPP_CANAL from '@salesforce/schema/Opportunity.CSBD_Canal__c';
import OPP_CONTACTO from '@salesforce/schema/Opportunity.CSBD_Contact__c';
import OPP_CLIENTE_PORTAL_IDENTIFICADO from '@salesforce/schema/Opportunity.CSBD_Cliente_Portal_Identificado__c';

//eslint-disable-next-line
export default class csbdAlertaTelefonia extends LightningElement {

	@api recordId;

	cargaInicial = true;


	@track alertas = {
		productoMifid: {mostrar: false, visto: false},
		tipoBonificado: {mostrar: false, visto: false},
		identificarClientePortal: {mostrar: false, visto: false}
	};

	@track datos = {telefonoSolicitud: null, tipoBonificado: null};

	@wire(getRecord, {recordId: '$recordId', fields: [OPP_IS_CLOSED, OPP_PRODUCTO_MIFID, OPP_TELEFONO, OPP_TIPO_BONIFICADO, OPP_CANAL, OPP_CONTACTO, OPP_CLIENTE_PORTAL_IDENTIFICADO]})
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
					this.datos.telefonoSolicitud = getFieldValue(data, OPP_TELEFONO)?.replace(/\s/g, '').replace(/^\+34/, '');
				}
				if (getFieldValue(data, OPP_CANAL) === 'portal' && !getFieldValue(data, OPP_CONTACTO) && !getFieldValue(data, OPP_CLIENTE_PORTAL_IDENTIFICADO)) {
					this.alertas.identificarClientePortal.mostrar = true;
				}

				if (this.cargaInicial) {
					//eslint-disable-next-line @lwc/lwc/no-async-operation
					window.setTimeout(() => {
						if (this.alertas.tipoBonificado.mostrar && !this.alertas.tipoBonificado.visto) {
							this.abrirModal('tipoBonificado');
						} else if (this.alertas.productoMifid.mostrar && !this.alertas.productoMifid.visto) {
							this.abrirModal('productoMifid');
						} else if (this.alertas.identificarClientePortal.mostrar && !this.alertas.identificarClientePortal.visto) {
							this.abrirModal('identificarClientePortal');
						}
					}, 400);
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
			const botonCerrar = this.template.querySelector('.' + nombreModal + 'BotonCerrar');
			window.setTimeout(() => {
				botonCerrar.disabled = false;
				botonCerrar.focus();
			}, 210);
		}, 40);
	}

	cerrarModal(nombreModal) {
		const modal = this.template.querySelector('section.' + nombreModal);
		if (modal) {
			modal.classList.remove('modalAbierto');
			//eslint-disable-next-line @lwc/lwc/no-async-operation
			window.setTimeout(() => modal.classList.add('slds-hide'), 360);

			if (nombreModal === 'tipoBonificado' && this.alertas.productoMifid.mostrar) {
				this.abrirModal('productoMifid');
			} else if (nombreModal === 'productoMifid' && this.alertas.identificarClientePortal.mostrar) {
				this.abrirModal('identificarClientePortal');
			} else {
				this.template.querySelector('.slds-backdrop').classList.remove('slds-backdrop_open');
			}
		}
	}

	botonCerrarModalOnclick({currentTarget: {dataset: {nombreModal}}}) {
		this.cerrarModal(nombreModal);
	}

	modalContainerOnclick({currentTarget}) {
		currentTarget.querySelector('button.botonCerrar').focus();
	}

	modalTeclaPulsada({currentTarget: {dataset: {nombreModal}}, keyCode}) {
		keyCode === 27 && this.cerrarModal(nombreModal); //Tecla ESC
	}
}