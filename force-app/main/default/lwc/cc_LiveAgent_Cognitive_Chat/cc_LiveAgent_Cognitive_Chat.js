import { LightningElement, api, wire } from 'lwc';
import getCognitiveChat from '@salesforce/apex/CC_LiveAgent_Controller.getCognitiveChat';


export default class cc_LiveAgent_Cognitive_Chat extends LightningElement {
    @api recordId;
    @wire(getCognitiveChat, { recordId: '$recordId' }) CognitiveChat;
}