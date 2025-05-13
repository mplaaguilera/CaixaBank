import {LightningElement, track, api, wire} from 'lwc';

import ejecutarPrompt from '@salesforce/apex/CSBD_ChatGPT_Controller.einsteinGPT';
import ID_FIELD from '@salesforce/schema/Opportunity.Id';
//import IDPRODUCTO from "@salesforce/schema/Opportunity.CSBD_Producto__c";
import HISTORICO_CHAT from '@salesforce/schema/Opportunity.CSBD_GptHistorico__c';
import PREGUNTA_CHAT from '@salesforce/schema/Opportunity.CSBD_Pregunta__c';
import INTERACCIONES from '@salesforce/schema/Opportunity.CSBD_GPTInteraccionesAsistente__c';
//import RESUMEN_PRODUCTO_RED from '@salesforce/schema/Opportunity.CSBD_ResumenProductoReducido__c';
import {getRecord, getFieldValue, updateRecord} from 'lightning/uiRecordApi'; //updateRecord
import {ShowToastEvent} from 'lightning/platformShowToastEvent';


export default class csbdChatGPT extends LightningElement {

	@api recordId;

	@track messages = [{id: 1,
		text: '¡Hola! Soy tu asistente personal para las dudas que tengas del producto. ¿En qué te puedo ayudar?',
		class: 'slds-chat-message__text slds-chat-message__text_inbound',
		class2: 'slds-chat-listitem slds-chat-listitem_inbound',
		user: 'IA'}];

	userInput = '';

	//@track isLoading = false;
	@track bloquearTexto = false;

	//@track idProdcutoVar;
	@track primerRender = true;

	vRender = false;

	vUpdate = false;

	@wire(getRecord, {recordId: '$recordId', fields: [ID_FIELD, HISTORICO_CHAT, PREGUNTA_CHAT, INTERACCIONES]}) chat;

	get historicoChat() {
		return getFieldValue(this.chat.data, HISTORICO_CHAT);
	}

	//número de veces que el gestor interactúa con el chat
	get interacciones() {
		return getFieldValue(this.chat.data, INTERACCIONES);
	}

	renderedCallback() {

		this.scrollFondo();
		if (typeof this.chat.data !== 'undefined' && this.primerRender) {
			this.primerRender = false;
			if (this.historicoChat !== null) {
				this.messages = JSON.parse(this.historicoChat);
			}
			this.scrollFondo();
		}

		if (typeof this.chat.data !== 'undefined') {
			if (this.vUpdate) {
				this.vUpdate = false;
				this.vRender = true;
			} else if (!this.vRender) {
				this.vRender = true;
				if (this.historicoChat !== null) {
					this.messages = JSON.parse(this.historicoChat);
				}
				this.scrollFondo();
			} else {
				this.vRender = false;
			}
		}
	}

	handleInputChange(event) {
		this.userInput = event.target.value;
		this.vRender = true;
	}

	handleSend() {
		this.vRender = true;
		this.bloquearTexto = true;
		if (this.userInput.trim() === '') {
			return;
		}
		const userMessage = {
			id: this.messages.length + 1,
			text: this.userInput,
			class: 'slds-chat-message__text slds-chat-message__text_outbound-agent',
			class2: 'slds-chat-listitem slds-chat-listitem_outbound',
			user: 'Agente'
		};
		this.messages = [...this.messages, userMessage];
		const userMessage2 = {
			id: 9999,
			text: '',
			class: 'slds-icon-typing slds-is-animated',
			class2: 'slds-chat-listitem slds-chat-listitem_inbound',
			user: 'IA',
			escribiendo: true
		};
		this.messages = [...this.messages, userMessage2];
		this.scrollFondo();
		ejecutarPrompt({pregunta: this.userInput, oppId: this.recordId})
			.then(response => {
				const botMessage = {
					id: this.messages.length + 1,
					text: this.limpiarRespuesta(response),
					class: 'slds-chat-message__text slds-chat-message__text_inbound',
					class2: 'slds-chat-listitem slds-chat-listitem_inbound',
					user: 'IA'
				};
				this.bloquearTexto = false;
				this.messages.pop();
				this.messages = [...this.messages, botMessage];
				this.userInput = '';
				this.vUpdate = true;
				const fields = {};
				fields[HISTORICO_CHAT.fieldApiName] = JSON.stringify(this.messages);
				fields[ID_FIELD.fieldApiName] = this.recordId;
				fields[INTERACCIONES.fieldApiName] = this.interacciones === null ? 1 : this.interacciones + 1;
				const recordInput = {fields};
				updateRecord(recordInput);
			})
			.catch(error => {
				//mostrar un mensaje de error en el chat
				const errorMessage = {
					id: this.messages.length + 1,
					text: 'Se ha producido un error. Intentalo de nuevo mas tarde',
					class: 'slds-chat-message__text slds-chat-message__text_delivery-failure',
					class2: 'slds-chat-listitem slds-chat-listitem_inbound',
					user: 'IA',
					role: 'alert'
				};
				this.messages.pop();
				this.messages = [...this.messages, errorMessage];
				this.userInput = '';
				this.bloquearTexto = false;
			});
		this.scrollFondo();

	}

	//en ocasiones open IA encabeza los mensajes con tags html de esta manera
	limpiarRespuesta(response) {
		//quitar comas invertidas y html
		return response.replace(/```html|```/g, '').trim();
	}

	scrollFondo() {
		const container = this.template.querySelector('[data-id="chat-container"]');
		if (container) {
			container.scrollTop = container.scrollHeight;
		}
	}

	handleEnter(event) {

		this.userInput = event.target.value;
		if (event.keyCode === 13) {
			this.userInput = event.target.value;
			this.handleSend();
		}

	}

	handleEliminarHist() {
		//limpia el chat de preguntas y respuesta para empezar de 0 sin contexto
		this.vUpdate = true;
		this.messages = [{id: 1,
			text: '¡Hola! Soy tu asistente personal para las dudas que tengas del producto. ¿En qué te puedo ayudar?',
			class: 'slds-chat-message__text slds-chat-message__text_inbound',
			class2: 'slds-chat-listitem slds-chat-listitem_inbound',
			user: 'IA'}];
		const fields = {};
		fields[HISTORICO_CHAT.fieldApiName] = JSON.stringify(this.messages);
		fields[ID_FIELD.fieldApiName] = this.recordId;
		const recordInput = {fields};
		updateRecord(recordInput);
	}

	notifyUser(title, message, variant) {
		if (this.notifyViaAlerts) {
			//Notify via alert
			//eslint-disable-next-line no-alert
			alert(`${title}\n${message}`);
		} else {
			//Notify via toast
			const toastEvent = new ShowToastEvent({title, message, variant});
			this.dispatchEvent(toastEvent);
		}
	}


}