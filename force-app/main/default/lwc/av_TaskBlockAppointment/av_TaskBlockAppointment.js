import { LightningElement,api,track,wire } from 'lwc';

import getTask from '@salesforce/apex/AV_ReportAppointment_Controller.retrieveAccountTask';

export default class Av_TaskBlockAppointment extends LightningElement {

	@api accountid;
	@api recordid;
	@track listTasks;
	emptyCmp = false;
	gp = "gp";
	gn = "gn";
	showSpinner = true;
	taskObj = {};
	
	connectedCallback() {
		getTask({ accountId: this.accountid,recordId:this.recordid})
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
		if(!event.detail.vinculed){
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