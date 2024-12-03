import { LightningElement, api,track, wire } from 'lwc';
import getMessagesBar from '@salesforce/apex/CBK_NotificationBar_Controller.getNotificationMessages';
import registerMessageByOwner from '@salesforce/apex/CBK_NotificationBar_Controller.registerMessageByOwner';
import { refreshApex } from '@salesforce/apex';
import { getRecord, getFieldValue  } from 'lightning/uiRecordApi';
import { CurrentPageReference } from 'lightning/navigation'; //NavigationMixin,
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

import ID_FIELD from '@salesforce/user/Id';
//import ROLE_FIELD from '@salesforce/schema/User.UserRole.Name';
//import NAME_FIELD from '@salesforce/schema/User.Name';


export default class Cbk_LWC_Notification extends LightningElement {
	@api InputApp;
	@api recordId;
	interacciones= [];
	interacciones2= []; 
	@track userId = ID_FIELD;
	@track last;
	@track page = '';
	@track rId = '';

	@wire(CurrentPageReference)
		getStateParameters(currentPageReference) {
		   if (currentPageReference) {
				this.interacciones= [];
				this.interacciones2= [];
				this.urlStateParameters = currentPageReference.state;
				if (currentPageReference.attributes.recordId != 'undefined' ){
					this.page = currentPageReference.attributes.actionName;
					this.rId = currentPageReference.attributes.recordId;

					console.info(JSON.stringify(currentPageReference));

				}else{
					this.page = currentPageReference.attributes.actionName;
				}

				console.info('RecordId' + JSON.stringify(this.rId + ' ' + this.page));
				if (this.InputApp != null && this.InputApp != ''){
					this.getAlert();
				}
			}
	}

	getAlert(){
		this.interacciones = [];
		console.info('get alert: '+  JSON.stringify(this.InputApp + ' ' + this.userId));
		
		getMessagesBar({app: this.InputApp, ownerId: this.userId})
						.then((data) => {
								console.info('Messages: '+  JSON.stringify(data));
								this.error = undefined;
								this.interacciones = data;
								for(var i=0; i < this.interacciones.length; i++){
									this.interacciones2.push(this.interacciones[i].name);
								}

								if (this.rId != null && this.rId != '' && this.interacciones !== null && this.interacciones.length > 0){
									this.last = this.interacciones2.sort().at(-1);
									this.checkCustomSetting(this.last,this.interacciones);
								}
							})
							.catch(error => {
								this.error = error;
								console.log('Error: '+  JSON.stringify(this.error));
							}
						);
	}

	checkCustomSetting(){
		registerMessageByOwner({messagesJson: JSON.stringify(this.interacciones), ownerId: this.userId, LastNoti: String(this.last)})
				.then((data2) => {        
						this.error = undefined;
						this.interacciones2 = data2;
						for(var i=0; i < this.interacciones2.length; i++){
							this.dispatchEvent(
											new ShowToastEvent({
												title: this.interacciones2[i].title,
												message: this.interacciones2[i].msg,
												variant: this.interacciones2[i].alertType,
												mode: 'sticky',
											}),
										);
						}
					})
					.catch(error => {
						this.error = error;
						/*this.dispatchEvent(
							new ShowToastEvent({
								title: 'Error',
								message: 'Show Alert Error: ' + this.error,
								variant: 'error',
							}),
						);*/
						console.log('Error: '+  JSON.stringify(this.error));
					}
				);
	}
}