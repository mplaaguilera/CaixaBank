import { LightningElement, track, api, wire } from 'lwc';
import ejecutarPrompt from '@salesforce/apex/CC_IA_ChatGpt_Controller.ejecutarPrompt';
import getCaseExtension from '@salesforce/apex/CC_IA_ChatGpt_Controller.getCaseExtension';
import actualizarCaseExtension from '@salesforce/apex/CC_IA_ChatGpt_Controller.actualizarCaseExtension';
import { getRecord, getFieldValue } from "lightning/uiRecordApi";
import CASE_EXTENSION_ID from '@salesforce/schema/Case.CBK_Case_Extension_Id__c';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class CcIaChatGpt extends LightningElement { 
    @api recordId; // ID del Caso
    @track caseExtensionId; // ID del Case Extension
    @track messages = [
        {
            id: 1,
            text: '¡Hola! Soy tu asistente personal para apoyarte con este caso. ¿En qué te puedo ayudar?',
            class: 'slds-chat-message__text slds-chat-message__text_inbound',
            class2: 'slds-chat-listitem slds-chat-listitem_inbound',
            user: 'IA'
        }
    ];
    userInput = '';
    @track bloquearTexto = false;
    @track primerRender = true;

    // Recuperar el ID de Case Extension desde el objeto Case
    @wire(getRecord, { recordId: '$recordId', fields: [CASE_EXTENSION_ID] })
    wiredCase({ error, data }) {
        if (data) {
            this.caseExtensionId = getFieldValue(data, CASE_EXTENSION_ID);
        } else if (error) {
            this.notifyUser('Error', 'Error al obtener Case Extension ID: ' + error.body.message, 'error');
        }
    }

    // Recuperar el historial del chat usando el Case Extension ID
    @wire(getCaseExtension, { caseExtensionId: '$caseExtensionId' })
    chat({ error, data }) {
        if (data) {
            const historico = data.CC_IA_Historico_ChatGpt__c;
            if (historico) {
                this.messages = JSON.parse(historico);
                this.scrollFondo();
            }
        } else if (error) {
            this.notifyUser('Error', 'Error recuperando el histórico del chat: ' + error.body.message, 'error');
        }
    }

    connectedCallback() {
        this.scrollFondo();
    }

    renderedCallback() {
        this.scrollFondo();
        if (this.primerRender) {
            this.primerRender = false;
            this.scrollFondo();
        }
    }
    handleInputChange(event) {
        this.userInput = event.target.value;
    }

    handleSend() {
        if (this.userInput.trim() === '') {
            this.notifyUser('Error', 'El mensaje no puede estar vacío', 'error');
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

        //mensaje "escribiendo"
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

        ejecutarPrompt({ pregunta: this.userInput, casoId: this.recordId })
            .then(response => {
                this.messages.pop(); // Eliminar el mensaje "escribiendo"
                const botMessage = {
                    id: this.messages.length + 1,
                    text: response,
                    class: 'slds-chat-message__text slds-chat-message__text_inbound',
                    class2: 'slds-chat-listitem slds-chat-listitem_inbound',
                    user: 'IA'
                };
                this.messages = [...this.messages, botMessage];
                this.userInput = '';

                actualizarCaseExtension({
                    casoId: this.recordId,
                    fields: {
                        historicoChat: JSON.stringify(this.messages),
                        interacciones: this.messages.filter(msg => msg.user === 'Agente').length
                    }
                });
            })
            .catch(error => {
                this.messages.pop(); // Eliminar el mensaje "escribiendo"
                const errorMessage = {
                    id: this.messages.length + 1,
                    text: 'Se ha producido un error. Inténtalo de nuevo más tarde.',
                    class: 'slds-chat-message__text slds-chat-message__text_delivery-failure',
                    class2: 'slds-chat-listitem slds-chat-listitem_inbound',
                    user: 'IA'
                };
                this.messages = [...this.messages, errorMessage];
            });
        this.scrollFondo();
    }

    handleEnter(event) {
        if (event.keyCode === 13) { // Verificar si la tecla Enter fue presionada
            this.handleSend();
        }
    }
    // Limpia el historial del chat
    handleEliminarHist() {
        this.messages = [
            {
                id: 1,
                text: '¡Hola! Soy tu asistente personal para apoyarte con este caso. ¿En qué te puedo ayudar?',
                class: 'slds-chat-message__text slds-chat-message__text_inbound',
                class2: 'slds-chat-listitem slds-chat-listitem_inbound',
                user: 'IA'
            }
        ];

        actualizarCaseExtension({
            casoId: this.recordId,
            fields: {
                historicoChat: JSON.stringify(this.messages),
                interacciones: 0
            }
        });
    }

    scrollFondo() {
        const container = this.template.querySelector('[data-id="chat-container"]');
        if (container) {
            container.scrollTo({
                top: container.scrollHeight,
                behavior: 'smooth'
            });
        }
    }

    notifyUser(title, message, variant) {
        const toastEvent = new ShowToastEvent({ title, message, variant });
        this.dispatchEvent(toastEvent);
    }
}