import {LightningElement, api, wire} from 'lwc';
import getActivityTimeline from '@salesforce/apex/CC_activityTimeline_Controller.getActivityTimeline';

//eslint-disable-next-line camelcase
export default class Cc_Case_Twitter_Timeline extends LightningElement {
	@api recordId;

	@wire(getActivityTimeline, {recordId: '$recordId', tipo: 'Social', origen: 'Case'})
	interacciones;
}