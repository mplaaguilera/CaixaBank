import { LightningElement, api, track, wire } from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';

import Id from '@salesforce/user/Id';
import FUNCTION from '@salesforce/schema/User.AV_Funcion__c';

import getWorkingTime from '@salesforce/apex/AV_NewEventCalendar_Controller.getWorkingTime';
import getSelectionTime from '@salesforce/apex/AV_NewEventCalendar_Controller.getSelectionTime';
import getCalendarHalfHourRange from '@salesforce/apex/AV_NewEventCalendar_Controller.getCalendarHalfHourRange';
import retrieveEvents from '@salesforce/apex/AV_NewEventCalendar_Controller.retrieveEvents';
import formatStartAndEndTimes from '@salesforce/apex/AV_NewEventCalendar_Controller.formatStartAndEndTimes';
// Labels
import calendarDateLabel from '@salesforce/label/c.AV_CalendarDateSel';
import errorCalendar1Label from '@salesforce/label/c.AV_CalendarNoTimeRange1';
import errorCalendar2Label from '@salesforce/label/c.AV_CalendarNoTimeRange2';
import errorCalendar3Label from '@salesforce/label/c.AV_CalendarNoTimeRange3';
import otroHorario from '@salesforce/label/c.CIBE_ElegirOtroHorario';
import noReuniones from '@salesforce/label/c.CIBE_NoPermitenReuniones';
import seleccionarHorario from '@salesforce/label/c.CIBE_SeleccionarHorario';

const CAL_NEWEVENT_HTML = `<div data-id="newEvent" class="new-event-color event-div slds-box slds-box_x-small"><p data-id="newEventText">#evSubject</p></div>`;
const CAL_EVENT_HTML = `<div data-id="#existingEvent" class="ext-event-color event-div slds-box slds-box_x-small"><p data-id="#existingEventText">#evSubject</p></div>`;
const MANAGER = 'Gestor';
 
export default class Av_NewEventCalendar extends LightningElement {
	
	@api timeRange;
	@api currentDate;
	@api userId;
	@api evSubject;

	@track listWorkingTime;
	@track listCalendarRangeTime;
	@track listUserEvents;
	@track listSelectionTimes;
	@track wierdMargin = 0;
	@track countResize = 0;
	@track showAnotherSchedule;
	@track userFunction;
	
	@track timeFinal='22:00';
	

	@track _initTime;
	@track _endTime;
	@track _finalDate;
	@track _checkTime;
	@track _invalidateTime;
	@track customStartTime;

	currentUserId = Id;

	label = {
		calendarDateLabel,
		errorCalendar1Label,
		errorCalendar2Label,
		errorCalendar3Label,
		otroHorario,
		noReuniones,
		seleccionarHorario
	};

	@wire(getRecord,{recordId:Id,fields:[FUNCTION]})
	wiredUser({error,data}){
		if(data){
			this.userFunction = data.fields.AV_Funcion__c.value;
			if(!this.currentUserId.includes(this.userId) && this.userFunction == MANAGER){
				this.showAnotherSchedule = false;
			}else{
				this.showAnotherSchedule = true;
			}
		}else if(error){
			console.log(error);
		}
	}

	connectedCallback() {
		window.addEventListener('resize', this.doResize);
		this.getTimeFromMins(this.timeRange);
		this._finalDate = this.currentDate;
		this._checkTime = true;
		this._invalidateTime=false;
		this.getWorkingTime();
		this.getSelectionTime();
		this.getCalendarHalfHourRange();
		this.retrieveEvents(this._finalDate);
	}

	getTimeFromMins(mins) {
		var h = mins / 60 | 0,
			m = mins % 60 | 0;
		var hour=22;
		var min=0;
		hour=hour-h;
		if (m!=0) {
			hour=hour-1;
			min=60-m;
		}else {
			min='00';
		}
		this.timeFinal=hour+':'+min;
	}

	renderedCallback() {
		
		let calendarDivHeight = this.template.querySelector(`[data-id="mainCalendar"]`).getBoundingClientRect().height;
		this.template.querySelector(`[data-id="mainWorkTime"]`).style.height = calendarDivHeight + 'px';
		this.template.querySelector('.overflow-div').style.height = calendarDivHeight + 'px';
		
		if(this.listCalendarRangeTime != undefined) {
			this.setOverflowDivWidth();
		}

		if(this.listUserEvents != undefined) {
			this.drawExistingEvents(this.listUserEvents);
		}	
	}

	@api
    get initTime(){
        return this._initTime;
	}

	@api
    get endTime(){
        return this._endTime;
	}
	
	@api
	get finalDate(){
		return this._finalDate;
    }
	@api
	get checkTime() {
		return this._checkTime;
	}
	@api
	get invalidateTime() {
		return this._invalidateTime;
	}

	//Call apex method that calculate the times and duration choices for the event
	getWorkingTime() {
		getWorkingTime({range: this.timeRange})
			.then(result => {
				this.listWorkingTime = JSON.parse(result);
			/* 	let auxTimeList = [];
				for(let timeSel of this.listWorkingTime) {
					auxTimeList.push(timeSel.startTime);
				}
				this.listSelectionTimes = auxTimeList; */
			})
			.catch(error => {
				console.log(error);
			});
	}

	getSelectionTime() {
		getSelectionTime()
			.then(result => {
				let auxTimeList = [];
				for(let timeSel of JSON.parse(result)) {
					auxTimeList.push(timeSel.startTime);
				}
				this.listSelectionTimes = auxTimeList;
			})
			.catch(error => {
				console.log(error);
			});
	}

	//Call apex method that calculate the half hour time zones in order to draw the calendar table
	getCalendarHalfHourRange() {
		getCalendarHalfHourRange()
			.then(result => {
				this.listCalendarRangeTime = JSON.parse(result);
			})
			.catch(error => {
				console.log(error);
			});
	}

	//Call apex method that retrieve the events of the date selected by the user
	retrieveEvents(auxDate) {
		retrieveEvents({eventDate: auxDate, userId: this.userId})
			.then(result => {
				if (result != null) {
					this.listUserEvents = JSON.parse(result);
					this.deleteAllDrawedEvents();
					this.drawExistingEvents(this.listUserEvents);
					this.setOverflowDivWidth();
				}
			})
			.catch(error => {
				console.log(error);
			});
	}

	//Call apex method that retrieve the events of the date selected by the user in the lwc screen
	retrieveEventsAfter(auxDate) {
		retrieveEvents({eventDate: auxDate, userId: this.userId})
			.then(result => {
				if (result != null) {
					this.listUserEvents = JSON.parse(result);
					this.deleteAllDrawedEvents();
					this.drawExistingEvents(this.listUserEvents);
					this.setOverflowDivWidth();
				}
			})
			.catch(error => {
				console.log(error);
			});
	}

	//Call apex method that calculate the times and duration choices for the event
	formatStartAndEndTimes(auxDate, auxSTime, auxETime) {
		formatStartAndEndTimes({eventDate: auxDate, startTime: auxSTime, endTime: auxETime})
			.then(result => {
				this._checkTime=true;
				this._invalidateTime=false;
				let res = JSON.parse(result);
				this._initTime = res.sTime;
				this._endTime = res.eTime;
			})
			.catch(error => {
				console.log(error);
			});
	}

	//onClick function for the event time selection and draws that event in the calendar div
	handleAddEvent(event) {
		const buttonClass = event.target.className;
		const startTimeTarget = event.target.dataset.targetId;
		const endTimeTarget = event.target.title;

		if(!buttonClass.includes('disabled-sel')) {
			this.enableSelection(startTimeTarget);
			const parentCalendarDiv = this.template.querySelector('.overflow-div');
			let evToDelete = parentCalendarDiv.querySelectorAll(`[data-id="newEvent"]`);
			for(let oldEv of evToDelete) {
				parentCalendarDiv.removeChild(oldEv);
			}
			parentCalendarDiv.innerHTML += CAL_NEWEVENT_HTML.replace('#evSubject', this.evSubject);

			const cellHeight = this.template.querySelector(`[data-id="cell"]`).getBoundingClientRect().height;
			const heightMultiplier = this.timeRange/30;
			
			let topMultiplier = 0;
			for(let timeSel of this.listSelectionTimes) {
				if(timeSel === startTimeTarget) {
					topMultiplier = this.listSelectionTimes.indexOf(timeSel, 0) / 30;
				}
			}

			let newEventDiv = parentCalendarDiv.querySelector(`[data-id="newEvent"]`);
			newEventDiv.style.top = ((cellHeight * topMultiplier) - this.wierdMargin) + 'px';
			newEventDiv.style.height = (cellHeight * heightMultiplier) + 'px';
			if(this.timeRange == 15) {
				let newEventText = parentCalendarDiv.querySelector(`[data-id="newEventText"]`);
				newEventText.style.position = 'absolute';
				newEventText.style.top = '-10%';
			}
			this.formatStartAndEndTimes(this._finalDate, startTimeTarget, endTimeTarget);
		}
	}

	handleAddCustomEvent(event){
		this._checkTime = true;
		const buttonClass = event.target.className;
		var startString = this.customStartTime.split(":");
		var startHr = parseInt(startString[0],10);
		var startMin = parseInt(startString[1],10);
		if(startHr < 10){
			startHr = "0"+startHr;
		}
		var endHr = startHr;
		var endMin = startMin;
		endMin = startMin + this.timeRange;
		//below avoids values like 05:75...
		if(endMin >= 60){
			endHr++;
			endMin =  Math.ceil(((endMin / 60) -1) * 60);
			if(endMin < 10){
				endMin = "0"+ endMin;
			}
		}
		if(startMin < 10){
			startMin = "0"+startMin;
		}
		if(endHr < 10){
			endHr = "0"+endHr;
		}
		const startTimeTarget = startHr +":"+ startMin;
		const endTimeTarget = endHr +":"+endMin;
		console.log(startTimeTarget);
		console.log(endTimeTarget);
		
		this.enableSelection(startTimeTarget);
		const parentCalendarDiv = this.template.querySelector('.overflow-div');
		let evToDelete = parentCalendarDiv.querySelectorAll(`[data-id="newEvent"]`);
		for(let oldEv of evToDelete) {
			parentCalendarDiv.removeChild(oldEv);
		}
		
		parentCalendarDiv.innerHTML += CAL_NEWEVENT_HTML.replace('#evSubject', this.evSubject);
		const cellHeight = this.template.querySelector(`[data-id="cell"]`).getBoundingClientRect().height;
		const heightMultiplier = this.timeRange/30;
		
		let topMultiplier = 0;
		for(let timeSel of this.listSelectionTimes) {
			if(timeSel === startTimeTarget) {
				topMultiplier = this.listSelectionTimes.indexOf(timeSel, 0) / 30;
			}
		}

		let newEventDiv = parentCalendarDiv.querySelector(`[data-id="newEvent"]`);
		newEventDiv.style.top = ((cellHeight * topMultiplier) - this.wierdMargin) + 'px';
		newEventDiv.style.height = (cellHeight * heightMultiplier) + 'px';
		if(this.timeRange == 15) {
			let newEventText = parentCalendarDiv.querySelector(`[data-id="newEventText"]`);
			newEventText.style.position = 'absolute';
			newEventText.style.top = '-10%';
		}
		if (startTimeTarget<=this.timeFinal && startTimeTarget>='07:00') {
			this.formatStartAndEndTimes(this._finalDate, startTimeTarget, endTimeTarget);
		} else {
			this._invalidateTime=true;
		}
	}

	//function that draws the current date events
	drawExistingEvents(listEvs) {
		let i = 0;
		this.wierdMargin = 0;

		const parentCalendarDiv = this.template.querySelector('.overflow-div');
		parentCalendarDiv.innerHTML = '';
		for(let ev of listEvs) {
			
			let evId = 'existingEvent' + i;
			let evTextId = 'existingEventText' + i;
			let evSubject;
			if(ev.clientName) {
				evSubject = ev.clientName + ' - ' + ev.subject;
			} else {
				evSubject = ev.subject;
			}

			if(this.userId == this.currentUserId.substring(0,15)) {
				parentCalendarDiv.innerHTML += CAL_EVENT_HTML.replace('#evSubject', evSubject).replace('#existingEvent', evId).replace('#existingEventText', evTextId);
			} else {
				parentCalendarDiv.innerHTML += CAL_EVENT_HTML.replace('#evSubject', 'Ocupado').replace('#existingEvent', evId).replace('#existingEventText', evTextId);
			}
			i++;
			
			const cellHeight = this.template.querySelector(`[data-id="cell"]`).getBoundingClientRect().height;
			const heightMultiplier = ev.duration / 30;
			const timeTarget = ev.startTime;
			
			let topMultiplier = 0;

			for(let timeSel of this.listSelectionTimes) {
				if(timeSel === timeTarget) {
					let timeTargetPosition = this.listSelectionTimes.indexOf(timeSel, 0);
					topMultiplier = timeTargetPosition / 30;
					let numBotSel = ev.duration / 1;
					for(let i=0; i<numBotSel; i++) {
						let auxPosition = timeTargetPosition + i;
						if((auxPosition) <= this.listSelectionTimes.length) {
							let auxTargetId = this.listSelectionTimes[auxPosition];
							if(auxTargetId !== undefined) {
								let timeAuxSelection = this.template.querySelector(`[data-target-id="${auxTargetId}"]`);
								if(timeAuxSelection){
									timeAuxSelection.classList.add('disabled-sel');
									timeAuxSelection.classList.add('hidden-button');
								}
								
							}
						}
					}
					
					let numTopSel = this.timeRange / 1;
					for(let i=0; i<numTopSel; i++) {
						let auxPosition = timeTargetPosition - i;
						if((auxPosition) >= 0) {
							let auxTargetId = this.listSelectionTimes[auxPosition];
							if(auxTargetId !== undefined) {
								let timeAuxSelection = this.template.querySelector(`[data-target-id="${auxTargetId}"]`);
								if(timeAuxSelection){
									timeAuxSelection.classList.add('disabled-sel');
									timeAuxSelection.classList.add('hidden-button');
								}
							}
						}
					}
				}
			}

			

			let existingEventDiv = parentCalendarDiv.querySelector(`[data-id="${evId}"]`);
			existingEventDiv.style.top = ((cellHeight * topMultiplier) - this.wierdMargin) + 'px';
			existingEventDiv.style.height = (cellHeight * heightMultiplier) + 'px';
			this.wierdMargin += cellHeight * heightMultiplier;
			if(ev.duration == 15) {
				let existingEventText = parentCalendarDiv.querySelector(`[data-id="${evTextId}"]`);
				existingEventText.style.position = 'absolute';
				existingEventText.style.top = '-10%';
			}
		}
		
		let hastime = false;
		let listTimes = this.template.querySelectorAll(`[data-id="button-time"]`);
		for(let button of listTimes) {
			if(!button.className.includes('disabled-sel')) {
				hastime = true;
				break;
			}
		}


		
	}

	//delete drawed items when user change the selected date
	deleteAllDrawedEvents() {
		const parentCalendarDiv = this.template.querySelector('.overflow-div');
		let childEvents = parentCalendarDiv.querySelectorAll('div');
		for(let child of childEvents) {
			parentCalendarDiv.removeChild(child);
		}

		let listTimes = this.template.querySelectorAll(`[data-id="button-time"]`);
		for(let workTime of listTimes) {
			workTime.classList.remove('disabled-sel');
			workTime.classList.remove('hidden-button');
			workTime.classList.remove('selected-worktime');
		}
	}

	handleChangeDate(event) {
		
		this._finalDate = event.target.value;
		this.listUserEvents = undefined;
		this.retrieveEventsAfter(this._finalDate);
	}

	handleChangeTime(event){
		this._checkTime = false;
		this._initTime = null;
		this._endTime = null;
		this.customStartTime = event.target.value;
		this.template.querySelector(`[data-id="button-custom-time"]`).click();
	}

	setOverflowDivWidth() {
		const cellWidth = this.template.querySelector(`[data-id="cell"]`).getBoundingClientRect().width;
		const cellTimeWidth = this.template.querySelector(`[data-id="cell-time"]`).getBoundingClientRect().width;
		this.template.querySelector('.overflow-div').style.width = cellWidth + 'px';
		this.template.querySelector('.overflow-div').style.marginLeft = cellTimeWidth + 'px';
	}

	enableSelection(selectedId) {
		let listTimes = this.template.querySelectorAll(`[data-id="button-time"]`);
		for(let workTime of listTimes) {
			if(workTime.dataset.targetId === selectedId) {
				workTime.classList.add('selected-worktime');
			} else {
				workTime.classList.remove('selected-worktime');
			}
		}
	}

	//horizontal resize for calendar div
	doResize = () => {
		this.countResize = this.countResize += 1;
		this.setOverflowDivWidth();
	};

}