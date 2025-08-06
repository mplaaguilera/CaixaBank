import { LightningElement, api } from 'lwc';
 
export default class Av_EventDetail extends LightningElement {

	@api subject;
	@api startdate;
	@api client;
}