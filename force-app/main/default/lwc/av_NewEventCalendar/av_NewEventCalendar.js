import { LightningElement, api } from 'lwc';

 
export default class Av_NewEventCalendar extends LightningElement {
	
	@api timeRange;
	@api currentDate;
	@api userId;
	@api evSubject;
	@api finalDate; 
	@api initTime;
	@api endTime;
	@api checkTime;
	@api invalidateTime;

}