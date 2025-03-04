import {LightningElement, api, wire, track} from 'lwc';
import {getRecord, getFieldValue} from 'lightning/uiRecordApi';
import {errorApex, toast, copiarTextoAlPortapapeles} from 'c/csbd_lwcUtils';
import currentUserId from '@salesforce/user/Id';

import OPP_RELACIONADA from '@salesforce/schema/LiveChatTranscript.CSBD_Oportunidad_Id__c';
import OPP_ACCOUNT_NUMDOC from '@salesforce/schema/LiveChatTranscript.CSBD_Oportunidad_Id__r.Account.CC_Numero_Documento__c';
import OPP_ACCOUNT_NAME from '@salesforce/schema/LiveChatTranscript.CSBD_Oportunidad_Id__r.Account.Name';
import OPP_OWNER from '@salesforce/schema/LiveChatTranscript.CSBD_Oportunidad_Id__r.OwnerId';
import OPP_ESTADO from '@salesforce/schema/LiveChatTranscript.CSBD_Oportunidad_Id__r.CSBD_Estado__c';
import OPP_CONTACT from '@salesforce/schema/LiveChatTranscript.CSBD_Oportunidad_Id__r.CSBD_Contact__c';
import OPP_IS_CLOSED from '@salesforce/schema/LiveChatTranscript.CSBD_Oportunidad_Id__r.IsClosed';

const OPP_FIELDS_GETRECORD = [OPP_ACCOUNT_NUMDOC, OPP_ACCOUNT_NAME, OPP_RELACIONADA, OPP_OWNER, OPP_ESTADO, OPP_CONTACT, OPP_IS_CLOSED];

export default class csbdChatOperativas extends LightningElement {
	@api recordId;

	chat;

	idOportunidad;

	botonesDisabled = {};

	@track modalesVisibles = {};

	@wire(getRecord, {recordId: '$recordId', fields: OPP_FIELDS_GETRECORD})
	wiredRecord({error, data: chat}) {
		if (chat) {
			this.chat = chat;
			this.idOportunidad = getFieldValue(chat, OPP_RELACIONADA);
			const esPropietario = getFieldValue(chat, OPP_OWNER) === currentUserId;
			const isClosed = getFieldValue(chat, OPP_IS_CLOSED);
			const estado = getFieldValue(chat, OPP_ESTADO);
			const contactoInformado = Boolean(getFieldValue(chat, OPP_CONTACT));

			this.botonesDisabled = {
				cerrarOportunidad: estado !== 'Activa' || !esPropietario,
				derivarGestor: !contactoInformado || isClosed || estado === 'Nueva' || !esPropietario,
				copiarNifAlPortapapeles: !contactoInformado
			};
		} else if (error) {
			errorApex(this, error, 'Error recuperando los datos del chat');
		}
	}

	abrirModal({target: {dataset: {modal}}}) {
		this.modalesVisibles = {[modal]: true};
		setTimeout(() => this.refs[modal].abrirModal(), 20);
	}

	cerrarModal({detail: {nombreModal}}) {
		this.modalesVisibles[nombreModal] = false;
	}

	async copiarNifAlPortapapeles() {
		const nif = getFieldValue(this.chat, OPP_ACCOUNT_NUMDOC);
		if (nif) {
			try {
				await copiarTextoAlPortapapeles(nif);
				toast('success', 'Se copió NIF', `Se ha copiado el NIF ${nif} (${getFieldValue(this.chat, OPP_ACCOUNT_NAME)}) al portapapeles`);
			} catch (error) {
				console.error(error);
			}
		} else {
			toast('info', 'El NIF del cliente no está informado', 'La cuenta no tiene el número de documento de identidad informado');
		}
	}
}