import { LightningElement,api, track } from 'lwc';
import { ShowToastEvent } 	    from 'lightning/platformShowToastEvent';
import CIBE_CMP_ErrorMessage 		from '@salesforce/label/c.CIBE_CMP_ErrorMessage';
import getHistory 		       from '@salesforce/apex/CIBE_TabManagementTask_Controller.getManagementHistory';

//Labels
import fecha from '@salesforce/label/c.CIBE_Fecha';
import estado from '@salesforce/label/c.CIBE_Estado';
import tipo from '@salesforce/label/c.CIBE_Tipo';
import comentario from '@salesforce/label/c.CIBE_Comentario';
import recordatorio from '@salesforce/label/c.CIBE_Recordatorio';

export default class Cibe_ManagementHistory extends LightningElement {

	labels = {
		tipo, 
		comentario,
		estado,
		fecha,
		recordatorio
	};

	columns = [
		{ label: this.labels.fecha, fieldName: 'dateManagement', type: 'date',
			typeAttributes: {
				day: 'numeric',
				month: 'numeric',
				year: 'numeric'
			},
			cellAttributes: { class: { fieldName: 't1' }},  hideDefaultActions: true 
		},
		{ label: this.labels.estado, fieldName: 'status', type: 'text', cellAttributes: { class: { fieldName: 't1' } } , hideDefaultActions: true},
		{ label: this.labels.tipo, fieldName: 'type', type: 'text', cellAttributes: { class: { fieldName: 't1' } } , hideDefaultActions: true},
		{ label: this.labels.comentario, fieldName: 'comment',  type: 'text', cellAttributes: { class: { fieldName: 't1' }} , hideDefaultActions: true,wrapText:true},
		{ label: this.labels.recordatorio, fieldName: 'reminder', type: 'date',
			typeAttributes: {
				day: 'numeric',
				month: 'numeric',
				year: 'numeric',
				hour: '2-digit',
				minute: '2-digit'
			},
			cellAttributes: { class: { fieldName: 't1' }  }, hideDefaultActions: true
		}
	];

	@api recordId;
	@track data = [];

	@track progressValue = 0;
	hanldeProgressValueChange(event) {
		this.progressValue = event.detail;
	}

	@api
	refresh() {
		this.getData();
	}

	connectedCallback() {
		this.getData();
	}
	
	getData(){
		getHistory({id: this.recordId})
		.then(result => {
			this.data = result;       
		})
		.catch(error => {
			const evt = new ShowToastEvent({
				title: CIBE_CMP_ErrorMessage,
				message: JSON.stringify(error),
				variant: 'error'
			});
			this.dispatchEvent(evt);
		});
	}
}