import { LightningElement,api,track,wire } from 'lwc';

export default class Cbk_LWC_Notification_Show extends LightningElement {
@api msg;
@api isexpanded;
@track showMsg = false;
@track isChecked = false;
@track idNoti;

	changeState(){ 
        this.isexpanded=!this.isexpanded;
		this.showMsg = !this.showMsg;
    }

	nameChange(){ 
		this.isChecked = !this.isChecked;
    }
}