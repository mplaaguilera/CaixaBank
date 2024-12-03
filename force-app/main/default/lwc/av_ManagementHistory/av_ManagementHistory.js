import { LightningElement,api, track } from 'lwc';
import { ShowToastEvent } 	    from 'lightning/platformShowToastEvent';
import AV_CMP_ErrorMessage 		from '@salesforce/label/c.AV_CMP_ErrorMessage';
import getHistory 		       from '@salesforce/apex/AV_TabManagementTask_Controller.getManagementHistory';


const columns = [
	{ label: 'Fecha', fieldName: 'dateManagement', type: 'date',
	 typeAttributes: {
		day: 'numeric',
		month: 'numeric',
		year: 'numeric'
	  },
	  cellAttributes: { class: { fieldName: 't1' }},  hideDefaultActions: true 
	},
	{ label: 'Estado', fieldName: 'status', type: 'text', cellAttributes: { class: { fieldName: 't1' } } , hideDefaultActions: true},
	{ label: 'Tipo', fieldName: 'type', type: 'text', cellAttributes: { class: { fieldName: 't1' } } , hideDefaultActions: true},
	{ label: 'Comentario', fieldName: 'comment',  type: 'text', cellAttributes: { class: { fieldName: 't1' }} , hideDefaultActions: true,wrapText:true},
	{ label: 'Recordatorio', fieldName: 'reminder', type: 'date',
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
export default class Av_ManagementHistory extends LightningElement {
	@api recordId;
	@track data = [];
	columns = columns;

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
				title: AV_CMP_ErrorMessage,
				message: JSON.stringify(error),
				variant: 'error'
			});
			this.dispatchEvent(evt);
		});
	}
}