import { LightningElement, api,track} from 'lwc';

//apex methods
import retrieveValue from '@salesforce/apex/AV_TaskDetailValue_Controller.getValueLabel';
 
export default class Av_TaskDetail extends LightningElement {

	@api subject;
	@api startdate;
    @api client;
    @api taskPriority;

    @track priorityShow;

    //Mapa api name y api value {'A','Alta'}
    //taskValue = getmap(taskPriority);
    connectedCallback() {
        this.retLabelValuePriority();
    }

    retLabelValuePriority(){
		retrieveValue({priority: this.taskPriority})
			.then(result => {
				if(result !== 'KO') {
                    this.priorityShow = result;
				}
			})
			.catch(error => {
				this.error = error;
				console.log(error);
			});
	}
    
}