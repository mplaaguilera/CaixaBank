import {LightningElement, api, wire} from 'lwc';
import getHistoryChatApex from '@salesforce/apex/CC_ChatHistory_Controller.getHistoryChat';
//import getVacio from '@salesforce/apex/CC_ChatHistory_Controller.getVacio';

//eslint-disable-next-line camelcase
export default class cc_Chat_History extends LightningElement {

	@api recordId;

	@api forzarCognitivo = false;

	vacio = false;

	historyChat = {};

	//Pendiente dar valor dinámicamente
	//@wire(getVacio, {recordId: '$recordId', cognitivo: '$forzarCognitivo'}) vacio;

	//@track receivedMessage = '';

	//@track subscription = null;

	/*
    connectedCallback() {
		eslint-disable-next-line @lwc/lwc/no-async-operation
		window.setTimeout(() => this.getHistoryChat(this.recordId, this.forzarCognitivo), 2000);
	}
    */

	@wire(getHistoryChatApex, {recordId: '$recordId', cognitivo: '$forzarCognitivo'})
	wiredHistoryChat({error, data}) {
		console.log('DPK Datos-->' + JSON.stringify(data));
		if (data) {
			this.historyChat = data.map((chat, index) => ({...chat, id: index}));
			this.vacio = !this.historyChat.length;
		} else if (error) {
			console.error(error);
		}
	}

	@api lwcRefresh(recordId1, cognitivo1) {
		//this.getHistoryChat(recordId1, cognitivo1);
		getHistoryChatApex({recordId: recordId1, cognitivo: cognitivo1})
		.then(response => {
			const newHistoryChat = {data: response};
			this.historyChat = {...newHistoryChat};
		}).catch(error => {
			console.error(error);
			//eslint-disable-next-line no-alert
			alert('error');
		});
	}

	/*
	getHistoryChat(recordId, forzarCognitivo) {
		getHistoryChatApex({recordId: recordId, cognitivo: forzarCognitivo})
		.then(response => {
			const newHistoryChat = {data: response};
			this.historyChat = {...newHistoryChat};
		}).catch(error => {
			console.error(error);
			//eslint-disable-next-line no-alert
			alert('error');
		});
	}
	*/
}