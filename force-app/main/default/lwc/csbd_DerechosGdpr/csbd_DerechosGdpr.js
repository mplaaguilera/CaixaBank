import {LightningElement, api, wire} from 'lwc';
import {getRecord, getFieldValue} from 'lightning/uiRecordApi';
import LightningConfirm from 'lightning/confirm';
import {NavigationMixin} from 'lightning/navigation';
import {encodeDefaultFieldValues} from 'lightning/pageReferenceUtils';

import {errorApex, publicarEvento} from 'c/csbd_lwcUtils';
import {DATATABLE_COLUMNS} from './utils';

import getTiposDerechoApex from '@salesforce/apex/CSBD_DerechosGdpr_Apex.getTiposDerecho';
import getDerechosGdprApex from '@salesforce/apex/CSBD_DerechosGdpr_Apex.getDerechosGdpr';

import OPPTY_IDENTIFICADOR from '@salesforce/schema/Opportunity.CSBD_Identificador__c';
import OPPTY_ACCOUNT_ID from '@salesforce/schema/Opportunity.AccountId';
import OPPTY_ACCOUNT_NAME from '@salesforce/schema/Opportunity.Account.Name';
import OPPTY_ACCOUNT_NUMPERSO from '@salesforce/schema/Opportunity.Account.AV_NumPerso__c';
import OPPTY_ACCOUNT_NUMERO_DOCUMENTO from '@salesforce/schema/Opportunity.Account.CC_Numero_Documento__c';
import OPPTY_ACCOUNT_OFICINA_GESTORA_NAME from '@salesforce/schema/Opportunity.Account.CC_OficinaGestoraId__r.Name';
import OPPTY_ACCOUNT_OFICINA_GESTORA_BILLING_STREET from '@salesforce/schema/Opportunity.Account.CC_OficinaGestoraId__r.BillingStreet';
import OPPTY_ACCOUNT_OFICINA_GESTORA_BILLING_POSTAL_CODE from '@salesforce/schema/Opportunity.Account.CC_OficinaGestoraId__r.BillingPostalCode';
import OPPTY_ACCOUNT_OFICINA_GESTORA_BILLING_CITY from '@salesforce/schema/Opportunity.Account.CC_OficinaGestoraId__r.BillingCity';
import OPPTY_ACCOUNT_OFICINA_GESTORA_BILLING_STATE from '@salesforce/schema/Opportunity.Account.CC_OficinaGestoraId__r.BillingState';
import OPPTY_ACCOUNT_BILLING_STREET from '@salesforce/schema/Opportunity.Account.BillingStreet';
import OPPTY_ACCOUNT_BILLING_POSTAL_CODE from '@salesforce/schema/Opportunity.Account.BillingPostalCode';
import OPPTY_ACCOUNT_BILLING_CITY from '@salesforce/schema/Opportunity.Account.BillingCity';
import OPPTY_ACCOUNT_BILLING_STATE from '@salesforce/schema/Opportunity.Account.BillingState';
import OPPTY_ACCOUNT_PHONE from '@salesforce/schema/Opportunity.Account.Phone';
import OPPTY_ACCOUNT_EMAIL from '@salesforce/schema/Opportunity.Account.CC_Email__c';
import OPPTY_CONTACT_FIRST_NAME from '@salesforce/schema/Opportunity.CSBD_Contact__r.FirstName';
import OPPTY_CONTACT_LAST_NAME from '@salesforce/schema/Opportunity.CSBD_Contact__r.LastName';
import OPPTY_CONTACT_FECHA_NACIMIENTO from '@salesforce/schema/Opportunity.CSBD_Contact__r.CC_FechaNac__c';

const OPPTY_FIELDS = [
	OPPTY_IDENTIFICADOR, OPPTY_ACCOUNT_ID, OPPTY_ACCOUNT_NAME, OPPTY_ACCOUNT_OFICINA_GESTORA_NAME,
	OPPTY_ACCOUNT_OFICINA_GESTORA_BILLING_STREET, OPPTY_ACCOUNT_OFICINA_GESTORA_BILLING_POSTAL_CODE,
	OPPTY_ACCOUNT_OFICINA_GESTORA_BILLING_CITY, OPPTY_ACCOUNT_OFICINA_GESTORA_BILLING_STATE,
	OPPTY_ACCOUNT_BILLING_STREET, OPPTY_ACCOUNT_BILLING_POSTAL_CODE, OPPTY_ACCOUNT_BILLING_CITY,
	OPPTY_ACCOUNT_BILLING_STATE, OPPTY_ACCOUNT_PHONE, OPPTY_ACCOUNT_EMAIL, OPPTY_CONTACT_FIRST_NAME,
	OPPTY_CONTACT_LAST_NAME, OPPTY_CONTACT_FECHA_NACIMIENTO, OPPTY_ACCOUNT_NUMPERSO, OPPTY_ACCOUNT_NUMERO_DOCUMENTO
];

//eslint-disable-next-line
export default class csbdDerechosGdpr extends NavigationMixin(LightningElement) {

	componente = {spinner: false, funcionesBind: {}};

	@api recordId;

	oportunidad;

	datatableColumns = DATATABLE_COLUMNS;

	datatableData = {oportunidad: [], cliente: []};

	tiposDerecho = [];

	@wire(getTiposDerechoApex, {})
	wiredTiposDerecho({data: tiposDerecho, error: errorGetTiposDerecho}) {
		if (tiposDerecho) {
			tiposDerecho = [...tiposDerecho];
			tiposDerecho.sort((a, b) => a.label.localeCompare(b.label));
			this.tiposDerecho = tiposDerecho;
		} else if (errorGetTiposDerecho) {
			errorApex(this, errorGetTiposDerecho, 'Problema recuperando los tipos de derecho ejercibles');
		}
	}

	@wire(getRecord, {recordId: '$recordId', fields: OPPTY_FIELDS})
	wiredOpportunity({data, error: errorGetRecord}) {
		if (data) {
			this.oportunidad = {
				...data,
				_identificador: getFieldValue(data, OPPTY_IDENTIFICADOR),
				_accountName: getFieldValue(data, OPPTY_ACCOUNT_NAME) ?? null,
				_accountNumeroDocumento: getFieldValue(data, OPPTY_ACCOUNT_NUMERO_DOCUMENTO) ?? null,
				_accountOficinaGestoraName: getFieldValue(data, OPPTY_ACCOUNT_OFICINA_GESTORA_NAME) ?? null,
				_accountOficinaGestoraBillingStreet: getFieldValue(data, OPPTY_ACCOUNT_OFICINA_GESTORA_BILLING_STREET) ?? null,
				_accountOficinaGestoraBillingPostalCode: getFieldValue(data, OPPTY_ACCOUNT_OFICINA_GESTORA_BILLING_POSTAL_CODE) ?? null,
				_accountOficinaGestoraBillingCity: getFieldValue(data, OPPTY_ACCOUNT_OFICINA_GESTORA_BILLING_CITY) ?? null,
				_accountOficinaGestoraBillingState: getFieldValue(data, OPPTY_ACCOUNT_OFICINA_GESTORA_BILLING_STATE) ?? null,
				_accountBillingStreet: getFieldValue(data, OPPTY_ACCOUNT_BILLING_STREET) ?? null,
				_accountBillingPostalCode: getFieldValue(data, OPPTY_ACCOUNT_BILLING_POSTAL_CODE) ?? null,
				_accountBillingCity: getFieldValue(data, OPPTY_ACCOUNT_BILLING_CITY) ?? null,
				_accountBillingState: getFieldValue(data, OPPTY_ACCOUNT_BILLING_STATE) ?? null,
				_accountPhone: getFieldValue(data, OPPTY_ACCOUNT_PHONE) ?? null,
				_accountEmail: getFieldValue(data, OPPTY_ACCOUNT_EMAIL) ?? null,
				_contactFirstName: getFieldValue(data, OPPTY_CONTACT_FIRST_NAME) ?? null,
				_contactLastName: getFieldValue(data, OPPTY_CONTACT_LAST_NAME) ?? null,
				_contactFechaNacimiento: getFieldValue(data, OPPTY_CONTACT_FECHA_NACIMIENTO) ?? null
			};
			this.getDerechosGdpr();
		} else if (errorGetRecord) {
			errorApex(this, errorGetRecord, 'Problema recuperando los datos de la oportunidad');
		}
	}

	getDerechosGdpr(cache = true) {
		const timestamp = cache ? Date.now().toString() : null;
		return getDerechosGdprApex({
			recordId: this.recordId,
			accountId: getFieldValue(this.oportunidad, OPPTY_ACCOUNT_ID),
			timestamp
		}).then(derechos => {
			const derechosAux = derechos.map(derecho => ({
				...derecho,
				_url: `/${derecho.Id}`,
				_tipo: derecho.RecordType.Name,
				_oportunidadIdentificador: derecho.CSBD_Opportunity__r?.CSBD_Identificador__c ?? null,
				_oportunidadUrl: derecho.CSBD_Opportunity__c ? `/${derecho.CSBD_Opportunity__c}` : null
			}));
			this.datatableData.oportunidad = derechosAux.filter(derecho => derecho.CSBD_Opportunity__c === this.recordId);
			this.datatableData.cliente = derechosAux.filter(derecho => derecho.CSBD_Opportunity__c !== this.recordId
				&& derecho.CC_Cliente__c === getFieldValue(this.oportunidad, OPPTY_ACCOUNT_ID));
			this.datatableData = {...this.datatableData};
		}).catch(error => errorApex(this, error, 'Problema recuperando el histórico de derechos ejercidos'));
	}

	@api abrirModal() {
		this.refs.backdropModal.classList.add('slds-backdrop_open');
		this.refs.modalDerechosGdpr.classList.add('slds-fade-in-open');
		setTimeout(() => this.refs.botonCancelar.focus(), 90);
	}

	botonRefrescarOnclick(event) {
		this.getDerechosGdpr(false);
		const botonActualizar = event.currentTarget;
		this.componente.funcionesBind.botonActualizarOnanimationend = this.botonActualizarOnanimationend.bind(this, botonActualizar);
		botonActualizar.addEventListener('animationend', this.componente.funcionesBind.botonActualizarOnanimationend);
		botonActualizar.classList.add('rotar');
	}

	botonActualizarOnanimationend(botonActualizar) {
		botonActualizar.removeEventListener('animationend', this.componente.funcionesBind.botonActualizarOnanimationend);
		botonActualizar.classList.remove('rotar');
	}

	cerrarModal() {
		const modalNuevoDerecho = this.refs.modalNuevoDerecho;
		if (modalNuevoDerecho) {
			modalNuevoDerecho.classList.remove('slds-fade-in-open');
		}
		const modalDerechosGdpr = this.refs.modalDerechosGdpr;
		if (modalDerechosGdpr) {
			modalDerechosGdpr.classList.remove('slds-fade-in-open');
		}
		this.refs.backdropModal.classList.remove('slds-backdrop_open');

		setTimeout(() => publicarEvento(this, 'modalcerrado', {nombreModal: 'modalDerechosGdpr'}), 200);
	}

	modalTeclaPulsada({keyCode}) {
		if (keyCode === 27) {
			this.cerrarModal();
		}
	}

	modalNuevoDerechoAbrir() {
		this.refs.modalDerechosGdpr.classList.remove('slds-fade-in-open');
		setTimeout(() => {
			this.refs.comboboxTiposDerecho.setCustomValidity('');
			this.refs.comboboxTiposDerecho.reportValidity();
			this.refs.inputDatosVerificados.checked = false;
			this.refs.labelDatosVerificados.classList.remove('slds-text-color_error');
			this.refs.modalNuevoDerecho.classList.add('slds-fade-in-open');
			setTimeout(() => this.refs.comboboxTiposDerecho.focus(), 90);
		}, 50);
	}

	modalNuevoDerechoCerrar() {
		this.refs.modalNuevoDerecho.classList.remove('slds-fade-in-open');
		this.refs.modalDerechosGdpr.classList.add('slds-fade-in-open');
		setTimeout(() => this.refs.botonCancelar.focus(), 100);
	}

	modalNuevoDerechoOnkeydown(event) {
		if (event.keyCode === 27) {
			this.modalNuevoDerechoCerrar();
		}
	}

	async modalNuevoDerechoEjercer() {
		const comboboxTiposDerecho = this.refs.comboboxTiposDerecho;
		if (!comboboxTiposDerecho.value) {
			comboboxTiposDerecho.setCustomValidity('Selecciona el tipo de derecho a ejercer');
			comboboxTiposDerecho.reportValidity();
			return;
		}
		const inputDatosVerificados = this.refs.inputDatosVerificados;
		if (!inputDatosVerificados.checked) {
			this.refs.labelDatosVerificados.classList.add('slds-text-color_error');
			inputDatosVerificados.focus();
			return;
		}

		const tipoDerecho = this.tiposDerecho.find(tipo => tipo.value === comboboxTiposDerecho.value)?.label;
		if (await LightningConfirm.open({
			variant: 'header', theme: 'alt-inverse', label: 'Ejercer "' + tipoDerecho + '"',
			message: '¿Confirmas que has verificado que los datos del cliente son correctos y que quieres continuar?'
		})) {
			this[NavigationMixin.Navigate]({
				type: 'standard__objectPage',
				attributes: {objectApiName: 'CC_Derecho__c', actionName: 'new'},
				state: {defaultFieldValues: encodeDefaultFieldValues({
					'CC_Nombre__c': getFieldValue(this.oportunidad, OPPTY_CONTACT_FIRST_NAME),
					'CC_Apellido1__c': getFieldValue(this.oportunidad, OPPTY_CONTACT_LAST_NAME),
					'CC_DocumentoCliente__c': getFieldValue(this.oportunidad, OPPTY_ACCOUNT_NUMERO_DOCUMENTO),
					'CC_NumPerso__c': getFieldValue(this.oportunidad, OPPTY_ACCOUNT_NUMPERSO),
					'CC_NombreVia__c': getFieldValue(this.oportunidad, OPPTY_ACCOUNT_BILLING_STREET),
					'CC_CodigoPostal__c': getFieldValue(this.oportunidad, OPPTY_ACCOUNT_BILLING_POSTAL_CODE),
					'CC_Localidad__c': getFieldValue(this.oportunidad, OPPTY_ACCOUNT_BILLING_CITY),
					'CSBD_Opportunity__c': this.recordId,
					'CC_Cliente__c': getFieldValue(this.oportunidad, OPPTY_ACCOUNT_ID)
				})}
			}, false);
			this.cerrarModal();
		}
	}

	navegarDetalleCliente() {
		this[NavigationMixin.Navigate]({
			type: 'standard__recordPage',
			objectApiName: 'Account',
			attributes: {recordId: getFieldValue(this.oportunidad, OPPTY_ACCOUNT_ID), actionName: 'view'}
		});
	}

	comboboxTiposDerechoOnchange(event) {
		event.currentTarget.setCustomValidity('');
		event.currentTarget.reportValidity();
		this.refs.labelDatosVerificados.classList.remove('slds-text-color_error');
		const inputDatosVerificados = this.refs.inputDatosVerificados;
		inputDatosVerificados.disabled = false;
		inputDatosVerificados.checked = false;
	}

	inputDatosVerificadosOnchange() {
		this.refs.labelDatosVerificados.classList.remove('slds-text-color_error');
	}
}