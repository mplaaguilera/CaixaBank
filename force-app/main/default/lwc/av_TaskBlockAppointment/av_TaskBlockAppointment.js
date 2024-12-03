import { LightningElement,api,track,wire } from 'lwc';

import getTask from '@salesforce/apex/AV_ReportAppointment_Controller.retrieveAccountTask';

export default class Av_TaskBlockAppointment extends LightningElement {

	@api accountid;
	@api recordId;
	@track listTasks;
	emptyCmp = false;
	gp = "gp";
	gn = "gn";
	showSpinner = true;
	taskObj = {};
	
	connectedCallback() {
		getTask({ accountId: this.accountid})
		.then(result=> {
			if (result != null) {
				this.emptyCmp = true;
				this.listTasks = result;
				this.dispatchEvent(
					new CustomEvent('counttasks',{
						detail: result.length != 0
					})
				)
			}
			this.showSpinner = false;
		}).catch(error => {
			console.log(error);
			this.showSpinner = false;
		})
	}

	buildTaskObj(event){
		if(Object.keys(this.taskObj).includes(event.detail.id) && this.taskObj[event.detail.id].status == event.detail.status && (this.taskObj[event.detail.id].comment != null && this.taskObj[event.detail.id].comment == event.detail.comment)){
			delete this.taskObj[event.detail.id];
		}else{
			this.taskObj[event.detail.id] = event.detail;
		}
		this.dispatchEvent(
			new CustomEvent('settaskfromcontroller',{
				detail:this.taskObj
			})
		)
	}
}