import { LightningElement, api } from 'lwc';
// Labels
import evento from '@salesforce/label/c.CIBE_Event';
import asunto from '@salesforce/label/c.CIBE_Asunto';
import cliente from '@salesforce/label/c.CIBE_Cliente';
import cuando from '@salesforce/label/c.CIBE_Cuando';


export default class Cibe_EventDetail extends LightningElement {

    @api subject;
	@api startdate;
	@api client;
	
	labels= {
		evento,
		asunto,
		cliente,
		cuando
	};
}