import {LightningElement, api, wire} from 'lwc';
import getActivityTimeline from '@salesforce/apex/CC_activityTimeline_Controller.getActivityTimeline';

export default class Cc_Contact_TimeLine extends LightningElement {
    @api recordId;

    @wire(getActivityTimeline, {recordId: '$recordId', tipo: 'All', origen: 'Contact'})
    Interacciones;
}