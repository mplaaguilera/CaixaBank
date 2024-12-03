import { LightningElement, api, wire, track} from 'lwc';

//apex methods
import retrieveValue from '@salesforce/apex/CIBE_TaskDetail_Controller.getValueLabel';
//Labels 
import tarea from '@salesforce/label/c.CIBE_Task';
import asunto from '@salesforce/label/c.CIBE_Asunto';
import cliente from '@salesforce/label/c.CIBE_Cliente';
import vencimiento from '@salesforce/label/c.CIBE_Vencimiento';

export default class Cibe_TaskDetail extends LightningElement {

	labels = {
        tarea,
		asunto,
		cliente,
		vencimiento
	};

	@api subject;
	@api startdate;
    @api client;
    @api taskPriority;

    @track priorityShow;
	
	@wire(retrieveValue, {priority: '$taskPriority'})
	getPriority({ error, data }) {
		if (data) {
			this.priorityShow = data;
		} else if(error) {
			console.log(error);
		}
	}

}