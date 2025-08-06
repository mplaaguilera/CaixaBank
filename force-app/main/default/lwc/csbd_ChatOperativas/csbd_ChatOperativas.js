import {LightningElement, api, wire, track} from 'lwc';
import {getRecord, getFieldValue} from 'lightning/uiRecordApi';
import locale from '@salesforce/i18n/locale';
import currentUserId from '@salesforce/user/Id';
import {errorApex, toast, copiarTextoAlPortapapeles, usuarioDesarrollador} from 'c/csbd_lwcUtils';

import initApex from '@salesforce/apex/CSBD_ChatOperativas_Apex.init';

import CHAT_OPPORTUNITY_ID from '@salesforce/schema/LiveChatTranscript.CSBD_Oportunidad_Id__c';
import OPP_ACCOUNT_NUMDOC from '@salesforce/schema/Opportunity.Account.CC_Numero_Documento__c';
import OPP_ACCOUNT_NAME from '@salesforce/schema/Opportunity.Account.Name';
import OPP_OWNER from '@salesforce/schema/Opportunity.OwnerId';
import OPP_ESTADO from '@salesforce/schema/Opportunity.CSBD_Estado__c';
import OPP_CONTACT from '@salesforce/schema/Opportunity.CSBD_Contact__c';
import OPP_IS_CLOSED from '@salesforce/schema/Opportunity.IsClosed';
import OPP_FECHA_CITA from '@salesforce/schema/Opportunity.CSBD_Fecha_Cita__c';
import OPP_NO_IDENTIFICADO from '@salesforce/schema/Opportunity.CSBD_No_Identificado__c';

const OPP_FIELDS_GETRECORD = [
	OPP_ACCOUNT_NUMDOC, OPP_ACCOUNT_NAME, OPP_OWNER, OPP_ESTADO, OPP_CONTACT, OPP_IS_CLOSED, OPP_NO_IDENTIFICADO, OPP_FECHA_CITA
];

export default class csbdChatOperativas extends LightningElement {

	@api recordId;

	usuarioDesarrollador = false;

	idOportunidad;

	oportunidad = {_pendienteCita: false, _fechaCita: null, _cerrada: false};

	botonesDisabled = {
		copiarNifAlPortapapeles: true,
		programarCita: true,
		desprogramarCita: true,
		derivarGestor: true,
		cerrarOportunidad: true,
		reactivarOportunidad: true
	};

	@track modalesVisibles = {};

	@wire(getRecord, {recordId: '$recordId', fields: [CHAT_OPPORTUNITY_ID]})
	wiredChat({error, data: chat}) {
		if (chat) {
			this.idOportunidad = getFieldValue(chat, CHAT_OPPORTUNITY_ID);
		} else if (error) {
			errorApex(this, error, 'Error recuperando la oportunidad vinculada al chat');
		}
	}

	@wire(getRecord, {recordId: '$idOportunidad', fields: OPP_FIELDS_GETRECORD})
	wiredOpportunity({error, data: oportunidad}) {
		if (oportunidad) {
			const esPropietario = getFieldValue(oportunidad, OPP_OWNER) === currentUserId;
			const isClosed = getFieldValue(oportunidad, OPP_IS_CLOSED);
			const contactoInformado = Boolean(getFieldValue(oportunidad, OPP_CONTACT));
			const noIdentificado = Boolean(getFieldValue(oportunidad, OPP_NO_IDENTIFICADO));
			const estado = getFieldValue(oportunidad, OPP_ESTADO);
			const pendienteCita = estado === 'Pendiente Cita';
			const fechaCita = pendienteCita ? this.formatFecha(new Date(getFieldValue(oportunidad, OPP_FECHA_CITA))) : null;

			this.oportunidad = {
				...oportunidad,
				_pendienteCita: pendienteCita,
				_fechaCita: fechaCita,
				_abierta: !isClosed,
				_cerrada: isClosed
			};

			this.botonesDisabled = {
				copiarNifAlPortapapeles: !contactoInformado,
				programarCita: !['Activa', 'Pendiente Interno'].includes(estado) || !esPropietario || !contactoInformado && !noIdentificado,
				desprogramarCita: estado !== 'Pendiente Cita' || !esPropietario || !contactoInformado && !noIdentificado,
				derivarGestor: !contactoInformado || isClosed || estado === 'Nueva' || !esPropietario,
				cerrarOportunidad: estado !== 'Activa' || !esPropietario,
				reactivarOportunidad: !esPropietario
			};
		} else if (error) {
			errorApex(this, error, 'Error recuperando los datos de la oportunidad');
		}
	}

	async connectedCallback() {
		this.usuarioDesarrollador = await usuarioDesarrollador();
	}

	abrirModal({currentTarget: {dataset: {modal: nombreModal}}}) {
		this.modalesVisibles = {[nombreModal]: true};
		setTimeout(() => this.refs[nombreModal].abrirModal(), 20);
	}

	modalAbierto({detail: {nombreModal}}) {
		this.template.querySelectorAll('lightning-button').forEach(b => b.style.pointerEvents = 'none');
		this.template.querySelector(`lightning-button[data-modal="${nombreModal}"]`).variant = 'brand';
	}

	modalCerrado({detail: {nombreModal}}) {
		this.modalesVisibles[nombreModal] = false;
		this.template.querySelectorAll('lightning-button').forEach(b => b.style.pointerEvents = 'auto');
		const boton = this.template.querySelector(`lightning-button[data-modal="${nombreModal}"]`);
		boton && (boton.variant = boton.dataset.variant);
	}

	async copiarNifAlPortapapeles() {
		const nif = getFieldValue(this.oportunidad, OPP_ACCOUNT_NUMDOC);
		if (nif) {
			try {
				await copiarTextoAlPortapapeles(nif);
				toast('success', 'Se copió NIF', `Se ha copiado el NIF ${nif} (${getFieldValue(this.oportunidad, OPP_ACCOUNT_NAME)}) al portapapeles`);
			} catch (error) {
				console.error(error);
			}
		} else {
			toast('info', 'El NIF del cliente no está informado', 'La cuenta no tiene el número de documento de identidad informado');
		}
	}

	formatFecha(fecha) {
		const format = new Intl.DateTimeFormat(locale, {day: 'numeric', month: 'short', hour: '2-digit', minute: '2-digit', hour12: false});
		const parts = format.formatToParts(fecha);
		const dia = parts.find(p => p.type === 'day').value;
		const mes = (parts.find(p => p.type === 'month')?.value ?? '').toLowerCase().replace(/^./, c => c.toUpperCase());
		const hora = parts.find(p => p.type === 'hour').value;
		const minut = parts.find(p => p.type === 'minute').value;
		return `${dia} ${mes} ${hora}:${minut}`;
	}
}