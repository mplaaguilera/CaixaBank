import { LightningElement, api, track, wire } from 'lwc';
import { loadScript, loadStyle } from 'lightning/platformResourceLoader';
// import FullCalendarJS from '@salesforce/resourceUrl/fullcalendarv3';
import FullCalendarJS from '@salesforce/resourceUrl/AV_FullCalendarJSV3';
import { getRecord } from 'lightning/uiRecordApi';
import es from '@salesforce/resourceUrl/AV_esLocaleCalendar';
import getEvents from '@salesforce/apex/AV_CustomCalendar_Controller.retrieveEvents';
import USER_ID from '@salesforce/user/Id';
import TimeZoneSidKey from '@salesforce/schema/User.TimeZoneSidKey';

export default class Av_CustomCalendar extends LightningElement {

	@api timeRange;
	@api currentDate;
	@api userId;
	@api evSubject;
	@api gestorOverwrite;

	timeZoneOffset;
	//Variables cuando es llamado desde otro lwc

	@api timerange;
	@api currentdate;
	@api userid;
	@api evsubject;
	@api gestoroverwrite;

	@track _initTime;
	@track _endTime;
	@track _finalDate;
	@track _checkTime;
	@track _invalidateTime;
	@track customStartTime;
	@track showOneEvent=false
	timeZoneSidKey;
	_initTimeToSend;
	_endTimeToSend;

	@api availableActions = [];
    @wire(getRecord, { recordId: USER_ID, fields: [TimeZoneSidKey] })
    wiredUser({ error, data }) {
        if (data) {
            this.timeZoneSidKey = data.fields.TimeZoneSidKey.value;
			this.timeZoneOffset = this.calculateOffset(this.timeZoneSidKey);
        } else if (error) {
            console.error('Error fetching TimeZoneSidKey:', error);
        }
    }
	get isFlow(){
		return this.availableActions.includes('NEXT');
	}
	jsInitialised = false;
	@track readyCalendar = false;
	overlapCustom = false;
	arrEvent = [];
	renderDate;
	events;
	//colour of the events that were already on the calendar
	backgroundColorOldEvents = '#f3f2f2';
	textColorOldEvents = '#444444';
	borderColorOldEvents = '#828282';
	//colour of the event to be created new 
	backgroundColorNewEvents = '#1644F1';
	minTime = "08:00:00";
	maxTime;

	convertLwcInputs(){
		if(this.timerange == undefined){
			this.timerange = this.timeRange
		}
		if(this.currentdate == undefined){
			this.currentdate = this.currentDate
		}
		if(this.userid == undefined){
			this.userid = this.userId
		}
		if(this.evsubject == undefined){
			this.evsubject = this.evSubject
		}
		if(this.gestoroverwrite == undefined){
			this.gestoroverwrite = this.gestorOverwrite
		}
	}

	@api
	addEvent(date) { 
		var that = this;
		const ele = this.template.querySelector('div.fullcalendarjs');
		that.arrEvent = [];               
		let transEvents = [];
		that._initTime = new Date(JSON.stringify(date).replaceAll('"',''));
		$(ele).fullCalendar('gotoDate',that._initTime);
		getEvents({ userId: that.userid, dateDay: that.convertDate(that._initTime) })
		.then((data) => {
			if (data) {
				that.events = that.mapEvents(data);
				$(ele).fullCalendar('removeEvents');
				$(ele).fullCalendar('addEventSource', that.events);
			}
			$(ele).fullCalendar('clientEvents').forEach(evt => {
				evt.isZoomed = false;
				transEvents.push(evt);
			});
			$(ele).fullCalendar('updateEvents',transEvents);
			let validation = true;
			that._initTime = that.parseGMT(date.toISOString());
			that._endTime = that.addMinutesUTC(that._initTime, that.timerange);
			let initTimeAux = that.correctOffSet(  new Date(that._initTime));
			that._initTimeToSend  = new Date(initTimeAux);
			that._endTime = that.addMinutesUTC(that._initTime,that.timerange);
			let endTimeAux = (that.calculateEndDate(initTimeAux, that.timerange));
			that._endTimeToSend = new Date(endTimeAux);

			if(that.evsubject == null || that.evsubject == ''){
				validation = false;
			}
			if(!that.gestoroverwrite){
				that.events.forEach(evt=>{
					if(that.timeInRange(evt.start_origen,evt.end_origen,that._initTime)){
						validation = false;
						return;
					}
				});
			}	
			if (that.arrEvent.length === 0 && validation) {
				$(ele).fullCalendar('removeEvents', 1);
				let newEvent = {
					id: 1,
					title: that.evsubject,
					start: that._initTime,
					end: that._endTime,
					start_origen: initTimeAux,
					end_origen: endTimeAux,
					allDay: false,
					editable: true,
					durationEditable: false,
					color: that.backgroundColorNewEvents,
					overlap: that.gestoroverwrite
				};
				$(ele).fullCalendar('renderEvent', newEvent);
				that.arrEvent.push(newEvent);
			}
		
			let initTimeToSend = (typeof that._initTime == 'string') ? that._initTime : that._initTime.toISOString(); 
			let endTimeToSend = (typeof that._endTime == 'string') ? that._endTime : that._endTime.toISOString(); 
		that.dispatchEvent(new CustomEvent('eventcreatecalendar',{
				
				detail:{
					initTiment:initTimeToSend,
					endTime:endTimeToSend,
					validation: validation
				}
			}));
		})
		.catch(error => {
			console.log('error ', error);
		});
	}

	@api
	changeSubjectEvent(subjectEvent) { 
		var that = this;
		const ele = this.template.querySelector('div.fullcalendarjs');
		that.arrEvent = [];               
		let validation = true;
		if(subjectEvent == null || subjectEvent == ''){
			validation = false;
		}
		let initTimeAux = that.correctOffSet(  new Date(that._initTime));
		let endTimeAux = (that.calculateEndDate(initTimeAux, that.timerange));

		if(!that.gestoroverwrite){
			that.events.forEach(evt=>{
				if(that.timeInRange(evt.start_origen,evt.end_origen,that._initTime)){
					validation = false;
					return;
				}
			});
		}
		if (that.arrEvent.length === 0 && validation) {
			$(ele).fullCalendar('removeEvents', 1);
			let newEvent = {
				id: 1,
				title: subjectEvent,
				start: that._initTime,
				end : that._endTime,
				start_origen: initTimeAux,
				end_origen: endTimeAux,
				allDay: false,
				editable: true,
				durationEditable: false,
				color: that.backgroundColorNewEvents,
				overlap: that.gestoroverwrite
			};
			$(ele).fullCalendar('renderEvent', newEvent);
			that.arrEvent.push(newEvent);
		}
		let initTimeToSend = (typeof that._initTime == 'string') ? that._initTime : that._initTime.toISOString(); 
		let endTimeToSend = (typeof that._endTime == 'string') ? that._endTime : that._endTime.toISOString(); 
		that.dispatchEvent(new CustomEvent('eventcreatecalendar',{
			detail:{
				initTiment:initTimeToSend,
				endTime:endTimeToSend,
				validation: validation
			}
		}));
	}

	@api
	changeOwnerEvent(userId, gestorOverWrite ) { 
		const ele2 = this.template.querySelector('div.fullcalendarjs');
		$(ele2).fullCalendar('destroy');
		var initialLocaleCode = 'es';
		var that = this;
		const ele = this.template.querySelector('div.fullcalendarjs');
		that.arrEvent = [];
		var moment = $(ele).fullCalendar('getDate');
		this.maxTime = (gestorOverWrite) ? "21:00:00":"18:00:00";
		this.renderDate = new Date(this.currentdate.toString());
		getEvents({ userId: userId, dateDay: that.convertDate(new Date(that.currentdate)) })
		.then((data) => {
			if (data) {
				that.events = that.mapEvents(data);
				$(ele).fullCalendar('removeEvents');
				$(ele).fullCalendar('addEventSource', that.events);
			}
			this.readyCalendar = true;
		})
		.catch(error => {
			console.log('error ', error
			);
		});
		$(ele).fullCalendar({
			defaultView: 'agendaWeek',
			slotMinTime: "08:00:00",
			slotMaxTime: (gestorOverWrite) ? "21:00:00":"18:00:00",
			slotLabelInterval: '01:00:00',
			slotLabelFormat: 'HH:mm',
			height:'fit-content',
			contentHeight:'auto',
			header: {
				left: 'prev,next ',
				center: 'title',
				right: 'today'
			},
			views: {
				agenda: {
					titleFormat: 'MMMM YYYY'
				}
			},
			eventRender: function (event, element) {
				element.addClass(event._id);
				if(event.isZoomed){
					element.css({
					'padding':'1rem',
					'height':'fit-content',
					'width':'fit-content',
					'text-align':'center',
					'font-weight':'bold',
					'font-size':'medium',
					'opacity':'1'
				});
				}else{
					element.css({
						'padding':'auto',
						'height':'auto',
						'width':'auto',
						'text-align':'auto',
						'font-weight':'auto',
						"max-width": "100px",
						'opacity':'1'
					});
				}
				let timeHeader = that.setTimeHeaderString(new Date(event.start_origen),new Date(event.end_origen),event.id);
				element.html('');
				let duration = new Date(event.end_origen).getTime() - new Date(event.start_origen).getTime();
				duration /= (1000*60);
				var heightLeft = '100%';
				if(duration < 30) {
					var numberPx = (duration*20.5)/30;
					var stringPx = numberPx.toString().replace(',','.');
					var px = stringPx;
					if(stringPx.includes('.')) {
						px = stringPx.split('.')[0]+'.'+stringPx.split('.')[1].substring(0,2);
					}
					heightLeft = px+'px';
				}
				if (event.id != 1) {
					element.append($('<div style="width:3px; height: '+heightLeft+'; border-left: 4px solid gray; float: left;"></div>')).append($("<div>").append($("<div>").html(timeHeader).append($("<div>").html(event.title))));
				} else {
					element.append($('<div style="width:3px; height: '+heightLeft+'; border-left: 4px solid white; float: left;"></div>')).append($("<div>").append($("<div>").html(timeHeader).append($("<div>").html(event.title))));
				}
			},
			eventClick: function(event,element){
				if(event.id != 1){
					let transEvents = [];
					$(ele).fullCalendar('clientEvents').forEach(evt => {
						evt.isZoomed = false;
						transEvents.push(evt);
					})
					event.isZoomed = !event.isZoomed;
					transEvents.push(event);
					$(ele).fullCalendar('updateEvents',transEvents);
				}
			},
			eventAfterAllRender: function() {
				$('.fc-event-container').css('z-index','auto');                 
				$(ele).fullCalendar('clientEvents').forEach(evt => {
					let a = $('.'+evt._id);
					a.css('z-index',(evt.isZoomed)?2:1);                    
				})
			},
			timeFormat: 'HH:mm',
			minTime: that.minTime,
			maxTime: that.maxTime,
			weekends: true,
			hiddenDays: [0],
			slotEventOverlap: false,
			allDaySlot: false,
			locale: initialLocaleCode,
			defaultDate: that.renderDate,
			navLinks: false,
			editable: false,
			eventLimit: true,
			events: that.events,
			dragScroll: true,
			droppable: true,
			weekNumbers: false,
			aspectRatio: 2.2,
			slotLabelDidMount: function (date, cell) {
				var end = moment(cell.end).subtract(1, 'minutes');
				if (end.format('HH:mm') === '18:00') {
					cell.hide();
				}
			},
			selectOverlap: function (event) {
				let start = event.start_origen;
				let end = event.end_origen;
				let overlap = false;
				$(ele).fullCalendar('clientEvents').forEach(function (existingEvent) {
					if (existingEvent.start_origen < end && existingEvent.end_origen > start) {
						overlap = true;
						return false; // Detener el ciclo si se encuentra un solapamiento
					}
				});
				return !overlap; // Devuelve verdadero si no hay solapamiento
			},
			dayClick: function (date, jsEvent, view) {
				//render new event on calendar
				that.arrEvent = [];               
				let transEvents = [];
				$(ele).fullCalendar('clientEvents').forEach(evt => {
					evt.isZoomed = false;
					transEvents.push(evt);
				})
				$(ele).fullCalendar('updateEvents',transEvents);
				let validation = true;
				that._initTime = date.format();
				let initTimeAux = that.correctOffSet(  new Date(that._initTime));
				that._endTime = that.addMinutesUTC(that._initTime,that.timerange);
				let endTimeAux = (that.calculateEndDate(initTimeAux, that.timerange));
				if(that.evsubject == null || that.evsubject == ''){
					validation = false;
				}
				if(!that.gestoroverwrite){
					that.events.forEach(evt=>{
						if(that.timeInRange(evt.start_origen,evt.end_origen,that._initTime)){
							validation = false;
							return;
						}
					});
				}
				if (that.arrEvent.length === 0 && validation) {
					$(ele).fullCalendar('removeEvents', 1);
					let newEvent = {
						id: 1,
						title: that.evsubject,
						start: that._initTime,
						end:  that._endTime,
						start_origen: initTimeAux,
						end_origen: endTimeAux,
						allDay: false,
						editable: true,
						durationEditable: false,
						color: that.backgroundColorNewEvents,
						overlap: that.gestoroverwrite
					};
					$(ele).fullCalendar('renderEvent', newEvent);
					that.arrEvent.push(newEvent);
				}
				let initTimeToSend = (typeof that._initTime == 'string') ? that._initTime : that._initTime.toISOString(); 
		let endTimeToSend = (typeof that._endTime == 'string') ? that._endTime : that._endTime.toISOString(); 
		that.dispatchEvent(new CustomEvent('eventcreatecalendar',{
					detail:{
						initTiment:initTimeToSend,
						endTime:endTimeToSend,
						validation: validation
					}
				}));
			},
			eventDrop: function (event, delta, revertFunc) {
				let transEvents = [];
				$(ele).fullCalendar('clientEvents').forEach(evt => {
					evt.isZoomed = false;
					transEvents.push(evt);
				})
				$(ele).fullCalendar('updateEvents',transEvents);
				event.start_origen = that.correctOffSet(new Date(event.start.format()));
				event.end_origen = that.correctOffSet(new Date(event.end.format()));
				that._initTime = new Date(event.start.format());
				that._endTime = that.calculateEndDate(that._initTime, that.timerange);
				$(ele).fullCalendar('removeEvents', 1);
				$(ele).fullCalendar('renderEvent', event);
				that._initTimeToSend =  new Date(event.start_origen);
				that._endTimeToSend = new Date(event.end_origen);
				let initTimeToSend = (typeof that._initTime == 'string') ? that._initTime : that._initTime.toISOString(); 
		let endTimeToSend = (typeof that._endTime == 'string') ? that._endTime : that._endTime.toISOString(); 
		that.dispatchEvent(new CustomEvent('eventcreatecalendar',{
					detail:{
						initTiment:initTimeToSend,
						endTime:endTimeToSend,
						validation: true
					}
				}));
			}
		});
		let newClassNextButton = 'fc-state-default-sin-image';
		for (var i = 0; i < $("tr.fc-row").length; i++) {
			$(".fc-row:eq(" + i + ")").css("z-index", ($("tr.fc-row").length - i));
		}
		$('head').append('<style>.' + newClassNextButton + ' {border: 1px solid; background-color: #f5f5f5; border-color: #e6e6e6 #e6e6e6 #bfbfbf; border-color: rgba(0,0,0,.1) rgba(0,0,0,.1) rgba(0,0,0,.25); color: #333;text-shadow: 0 1px 1px rgba(255,255,255,.75);box-shadow: inset 0 1px 0 rgba(255,255,255,.2), 0 1px 2px rgba(0,0,0,.05);}</style>');
		$('.fc-next-button').removeClass('fc-state-default').addClass(newClassNextButton);
		$('.fc-next-button').css('background-color', 'white');
		$('.fc-next-button').css('color', '#1644F1');
		$('.fc-next-button').click(function () {
			that.arrEvent = [];
			var moment = $(ele).fullCalendar('getDate');
			that.currentdate = moment.format();
			getEvents({ userId: that.userid, dateDay: that.convertDate(new Date(that.currentdate)) })
			.then((data) => {
				if (data) {
					that.events = that.mapEvents(data);
					$(ele).fullCalendar('removeEvents');
					$(ele).fullCalendar('addEventSource', that.events);
				}
			})
			.catch(error => {
				console.log('error ', error);
			});
		});
		let newClassPrevButton = 'fc-state-default-sin-image';
		$('head').append('<style>.' + newClassPrevButton + ' {border: 1px solid; background-color: #f5f5f5; border-color: #e6e6e6 #e6e6e6 #bfbfbf; border-color: rgba(0,0,0,.1) rgba(0,0,0,.1) rgba(0,0,0,.25); color: #333;text-shadow: 0 1px 1px rgba(255,255,255,.75);box-shadow: inset 0 1px 0 rgba(255,255,255,.2), 0 1px 2px rgba(0,0,0,.05);}</style>');
		$('.fc-prev-button').removeClass('fc-state-default').addClass(newClassPrevButton);
		$('.fc-prev-button').css('background-color', 'white');
		$('.fc-prev-button').css('color', '#1644F1');
		$('.fc-center').css('text-transform','capitalize');
		$('.fc-prev-button').click(function () {
			that.arrEvent = [];
			var moment = $(ele).fullCalendar('getDate');
			that.currentdate = moment.format();
			getEvents({ userId: that.userid, dateDay: that.convertDate(new Date(that.currentdate)) })
			.then((data) => {   
				if (data) {
					that.events = that.mapEvents(data);
					$(ele).fullCalendar('removeEvents');
					$(ele).fullCalendar('addEventSource', that.events);
				}
			})
			.catch(error => {
				console.log('error ', error);
			});
		});
		let newClassTodayButton = 'fc-state-default-sin-image';
		$('head').append('<style>.' + newClassTodayButton + ' {border: 1px solid; background-color: #f5f5f5; border-color: #e6e6e6 #e6e6e6 #bfbfbf; border-color: rgba(0,0,0,.1) rgba(0,0,0,.1) rgba(0,0,0,.25); color: #333;text-shadow: 0 1px 1px rgba(255,255,255,.75);box-shadow: inset 0 1px 0 rgba(255,255,255,.2), 0 1px 2px rgba(0,0,0,.05);}</style>');
		$('.fc-today-button').removeClass('fc-state-default').addClass(newClassTodayButton);
		$('.fc-today-button').css('background-color', 'white');
		$('.fc-today-button').css('color', '#1644F1');
		$('.fc-today-button').click(function () {
			that.arrEvent = [];
			var moment = $(ele).fullCalendar('getDate');
			that.currentdate = moment.format();
			getEvents({ userId: that.userid, dateDay: that.convertDate(new Date(that.currentdate)) })
			.then((data) => {
				if (data) {
					that.events = that.mapEvents(data);
					$(ele).fullCalendar('removeEvents');
					$(ele).fullCalendar('addEventSource', that.events);
				}
			})
			.catch(error => {
				console.log('error ', error);
			});
		});
	}
	
	renderedCallback() {
		this.convertLwcInputs();
		this.maxTime = (this.gestoroverwrite) ? "21:00:00":"18:00:00";
		this.renderDate = new Date(this.currentdate.toString());
		if (this.jsInitialised) {
			return;
		}
		this.jsInitialised = true;
		loadScript(this, FullCalendarJS + '/FullCalenderV3/jquery.min.js')
		.then(() => {
			loadScript(this, FullCalendarJS + '/FullCalenderV3/moment.min.js')
			.then(() => {
				loadScript(this, FullCalendarJS + '/FullCalenderV3/fullcalendar.min.js')
				.then(() => {
					loadScript(this, FullCalendarJS + '/FullCalenderV3/locale/es.js')
					.then(() => {
						loadStyle(this, FullCalendarJS + '/FullCalenderV3/fullcalendar.min.css')
						.then(() => {
							this.initialiseCalendarJs();
						})
						.catch(error => {
							console.log('Error al cargar: fullcalendar.min.css', error);
						});
					})
					.catch(error => {
						console.log('Error al cargar: locale/es.js', error);
					});
				})
				.catch(error => {
					console.log('Error al cargar: fullcalendar.min.js', error);
				});
			})
			.catch(error => {
				console.log('Error al cargar: moment.min.js', error);
			});
		})
		.catch(error => {
			console.log('Error al cargar: jquery.min.js', error);
		});
	}

	setTimeHeaderString(start,end,id){

		var hoursToRest = Math.floor(start.getTimezoneOffset() / 60);
		if(id != 1) {
			start.setHours(start.getHours() + hoursToRest,start.getMinutes(),'00');
			end.setHours(end.getHours() + hoursToRest,end.getMinutes(),'00');
		}
		let hoursStart;
		let minutesEnd;
		let hoursEnd
		let minutesStart;
		hoursStart = start.getHours();
		minutesStart = start.getMinutes();
		if (parseInt(hoursStart,10) < 10){
			hoursStart =('0'+hoursStart);
		}
		if (parseInt(minutesStart,10) < 10){
			minutesStart =('0'+minutesStart);
		}
		hoursEnd = end.getHours();
		minutesEnd = end.getMinutes();
		if(parseInt(hoursEnd,10) < 10){
			hoursEnd =('0'+hoursEnd);
		}
		if (parseInt(minutesEnd,10) < 10){
			minutesEnd =('0'+minutesEnd);
		}
		return hoursStart+':'+minutesStart+' - '+hoursEnd+':'+minutesEnd;
	}

	initialiseCalendarJs() {
		var initialLocaleCode = 'es';
		var that = this;
		const ele = this.template.querySelector('div.fullcalendarjs');
		that.arrEvent = [];
		var moment = $(ele).fullCalendar('getDate');
		getEvents({ userId: that.userid, dateDay: that.convertDate(new Date(that.currentdate)) })
		.then((data) => {
			if (data) {
				that.events = that.mapEvents(data);
				$(ele).fullCalendar('removeEvents');
				$(ele).fullCalendar('addEventSource', that.events);
			}
			this.readyCalendar = true;
		})
		.catch(error => {
			console.log('error ', error);
		});
		$(ele).fullCalendar({
			defaultView: 'agendaWeek',
			slotMinTime: "08:00:00",
			slotMaxTime: (that.gestoroverwrite) ? "21:00:00":"18:00:00",
			slotLabelInterval: '01:00:00',
			slotLabelFormat: 'HH:mm',
			height:'fit-content',
			timezone: 'UTC',
			contentHeight:'auto',
			header: {
				left: 'prev,next ',
				center: 'title',
				right: 'today'
			},
			views: {
				agenda: {
					titleFormat: 'MMMM YYYY'
				}
			},
			eventRender: function (event, element) {
				element.addClass(event._id);
				if(event.isZoomed){
					element.css({
					'padding':'1rem',
					'height':'fit-content',
					'width':'fit-content',
					'text-align':'center',
					'font-weight':'bold',
					'font-size':'medium',
					'opacity':'1'
				});
				}else{
					element.css({
						'padding':'auto',
						'height':'auto',
						'width':'auto',
						'text-align':'auto',
						'font-weight':'auto',
						"max-width": "100px",
						'opacity':'1'
					});
				}
				let timeHeader = that.setTimeHeaderString(new Date(event.start_origen),new Date(event.end_origen),event.id);
				element.html('');
				let duration = new Date(event.end_origen).getTime() - new Date(event.start_origen).getTime();
				duration /= (1000*60);
				var heightLeft = '100%';
				if(duration < 30) {
					var numberPx = (duration*20.5)/30;
					var stringPx = numberPx.toString().replace(',','.');
					var px = stringPx;
					if(stringPx.includes('.')) {
						px = stringPx.split('.')[0]+'.'+stringPx.split('.')[1].substring(0,2);
					}
					heightLeft = px+'px';
				}
				if (event.id != 1) {
					element.append($('<div style="width:3px; height: '+heightLeft+'; border-left: 4px solid gray; float: left;"></div>')).append($("<div>").append($("<div>").html(timeHeader).append($("<div>").html(event.title))));
				} else {
					element.append($('<div style="width:3px; height: '+heightLeft+'; border-left: 4px solid white; float: left;"></div>')).append($("<div>").append($("<div>").html(timeHeader).append($("<div>").html(event.title))));
				}
			},
			eventClick: function(event,element){
				if(event.id != 1){
					let transEvents = [];
					$(ele).fullCalendar('clientEvents').forEach(evt => {
						evt.isZoomed = false;
						transEvents.push(evt);
					});
					event.isZoomed = !event.isZoomed;
					transEvents.push(event);
					$(ele).fullCalendar('updateEvents',transEvents);
				}
			},
			eventAfterAllRender: function() {
				$('.fc-event-container').css('z-index','auto');                 
				$(ele).fullCalendar('clientEvents').forEach(evt => {
					let a = $('.'+evt._id);
					a.css('z-index',(evt.isZoomed)?2:1);                    
				})
				that.dispatchEvent(new CustomEvent('calendarrendered',{
					detail:{
						rendered: true
					}
					
				}));
			},

			
			timeFormat: 'HH:mm',
			minTime: that.minTime,
			maxTime: that.maxTime,
			weekends: true,
			hiddenDays: [0],
			slotEventOverlap: false,
			allDaySlot: false,
			locale: initialLocaleCode,
			defaultDate: that.renderDate,
			navLinks: false,
			editable: false,
			eventLimit: true,
			events: that.events,
			dragScroll: true,
			droppable: true,
			weekNumbers: false,
			aspectRatio: 2.2,
			slotLabelDidMount: function (date, cell) {
				var end = moment(cell.end).subtract(1, 'minutes');
				if (end.format('HH:mm') === '18:00') {
					cell.hide();
				}
			},
			selectOverlap: function (event) {
				let start = event.start_origen;
				let end = event.end_origen;
				let overlap = false;
				$(ele).fullCalendar('clientEvents').forEach(function (existingEvent) {
					if (existingEvent.start_origen < end && existingEvent.end_origen > start) {
						overlap = true;
						return false; // Detener el ciclo si se encuentra un solapamiento
					}
				});
				return !overlap; // Devuelve verdadero si no hay solapamiento
			},
			dayClick: function (date, jsEvent, view) {
				//render new event on calendar
				that.arrEvent = [];               
				let transEvents = [];
				$(ele).fullCalendar('clientEvents').forEach(evt => {
					evt.isZoomed = false;
					transEvents.push(evt);
				})
				$(ele).fullCalendar('updateEvents',transEvents);
				let validation = true;
				that._initTime = date.format();

				let initTimeAux = that.correctOffSet(  new Date(that._initTime));
				that._initTimeToSend  = new Date(initTimeAux);
				that._endTime = that.addMinutesUTC(that._initTime,that.timerange);
				let endTimeAux = (that.calculateEndDate(initTimeAux, that.timerange));
				that._endTimeToSend = new Date(endTimeAux);
				if(that.evsubject == null || that.evsubject == ''){
					validation = false;
				}
				if(!that.gestoroverwrite){
					that.events.forEach(evt=>{
						if(that.timeInRange(evt.start_origen,evt.end_origen,that._initTime)){
							validation = false;
							return;
						}
					});
				}

				if (that.arrEvent.length === 0 && validation) {
					$(ele).fullCalendar('removeEvents', 1);
					let newEvent = {
						id: 1,
						title: that.evsubject,
						start: that._initTime,
						end:  that._endTime,
						start_origen: initTimeAux,
						end_origen: endTimeAux,
						allDay: false,
						editable: true,
						durationEditable: false,
						color: that.backgroundColorNewEvents,
						overlap: that.gestoroverwrite
					};
					$(ele).fullCalendar('renderEvent', newEvent);
					that.arrEvent.push(newEvent);
				}
				let initTimeToSend = (typeof that._initTime == 'string') ? that._initTime : that._initTime.toISOString(); 
		let endTimeToSend = (typeof that._endTime == 'string') ? that._endTime : that._endTime.toISOString(); 
		that.dispatchEvent(new CustomEvent('eventcreatecalendar',{
					detail:{
						initTiment:initTimeToSend,
						endTime:endTimeToSend,
						validation: validation
					}
				}));

				
			},
		
			eventDrop: function (event, delta, revertFunc) {
				let transEvents = [];
				$(ele).fullCalendar('clientEvents').forEach(evt => {
					evt.isZoomed = false;
					transEvents.push(evt);
				});
				$(ele).fullCalendar('updateEvents',transEvents);
				event.start_origen = that.correctOffSet(new Date(event.start.format()));
				event.end_origen = that.correctOffSet(new Date(event.end.format()));
				that._initTime = new Date(event.start.format());
				that._endTime = that.calculateEndDate(that._initTime, that.timerange);
				$(ele).fullCalendar('removeEvents', 1);
				$(ele).fullCalendar('renderEvent', event);
				that._initTimeToSend =  new Date(event.start_origen);
				that._endTimeToSend = new Date(event.end_origen);
				let initTimeToSend = (typeof that._initTime == 'string') ? that._initTime : that._initTime.toISOString(); 
				let endTimeToSend = (typeof that._endTime == 'string') ? that._endTime : that._endTime.toISOString(); 
		that.dispatchEvent(new CustomEvent('eventcreatecalendar',{
					detail:{
						initTiment:initTimeToSend,
						endTime:endTimeToSend,
						validation: true
					}
				}));
			}
			
		});
		let newClassNextButton = 'fc-state-default-sin-image';
		for (var i = 0; i < $("tr.fc-row").length; i++) {
			$(".fc-row:eq(" + i + ")").css("z-index", ($("tr.fc-row").length - i));
		}
		$('head').append('<style>.' + newClassNextButton + ' {border: 1px solid; background-color: #f5f5f5; border-color: #e6e6e6 #e6e6e6 #bfbfbf; border-color: rgba(0,0,0,.1) rgba(0,0,0,.1) rgba(0,0,0,.25); color: #333;text-shadow: 0 1px 1px rgba(255,255,255,.75);box-shadow: inset 0 1px 0 rgba(255,255,255,.2), 0 1px 2px rgba(0,0,0,.05);}</style>');
		$('.fc-next-button').removeClass('fc-state-default').addClass(newClassNextButton);
		$('.fc-next-button').css('background-color', 'white');
		$('.fc-next-button').css('color', '#1644F1');
		$('.fc-next-button').click(function () {
			that.arrEvent = [];
			var moment = $(ele).fullCalendar('getDate');
			that.currentdate = moment.format();
			getEvents({ userId: that.userid, dateDay: that.convertDate(new Date(that.currentdate)) })
			.then((data) => {
				if (data) {
					that.events = that.mapEvents(data);
					$(ele).fullCalendar('removeEvents');
					$(ele).fullCalendar('addEventSource', that.events);
				}
			})
			.catch(error => {
				console.log('error ', error);
			});
		});
		let newClassPrevButton = 'fc-state-default-sin-image';
		$('head').append('<style>.' + newClassPrevButton + ' {border: 1px solid; background-color: #f5f5f5; border-color: #e6e6e6 #e6e6e6 #bfbfbf; border-color: rgba(0,0,0,.1) rgba(0,0,0,.1) rgba(0,0,0,.25); color: #333;text-shadow: 0 1px 1px rgba(255,255,255,.75);box-shadow: inset 0 1px 0 rgba(255,255,255,.2), 0 1px 2px rgba(0,0,0,.05);}</style>');
		$('.fc-prev-button').removeClass('fc-state-default').addClass(newClassPrevButton);
		$('.fc-prev-button').css('background-color', 'white');
		$('.fc-prev-button').css('color', '#1644F1');
		$('.fc-center').css('text-transform','capitalize');
		$('.fc-prev-button').click(function () {
			that.arrEvent = [];
			var moment = $(ele).fullCalendar('getDate');
			that.currentdate = moment.format();
			getEvents({ userId: that.userid, dateDay: that.convertDate(new Date(that.currentdate)) })
			.then((data) => {   
				if (data) {
					that.events = that.mapEvents(data);
					$(ele).fullCalendar('removeEvents');
					$(ele).fullCalendar('addEventSource', that.events);
				}
			})
			.catch(error => {
				console.log('error ', error
				);
			});
		});
		let newClassTodayButton = 'fc-state-default-sin-image';
		$('head').append('<style>.' + newClassTodayButton + ' {border: 1px solid; background-color: #f5f5f5; border-color: #e6e6e6 #e6e6e6 #bfbfbf; border-color: rgba(0,0,0,.1) rgba(0,0,0,.1) rgba(0,0,0,.25); color: #333;text-shadow: 0 1px 1px rgba(255,255,255,.75);box-shadow: inset 0 1px 0 rgba(255,255,255,.2), 0 1px 2px rgba(0,0,0,.05);}</style>');
		$('.fc-today-button').removeClass('fc-state-default').addClass(newClassTodayButton);
		$('.fc-today-button').css('background-color', 'white');
		$('.fc-today-button').css('color', '#1644F1');
		$('.fc-today-button').click(function () {
			that.arrEvent = [];
			var moment = $(ele).fullCalendar('getDate');
			that.currentdate = moment.format();
			getEvents({ userId: that.userid, dateDay: that.convertDate(new Date(that.currentdate)) })
			.then((data) => {
				if (data) {
					that.events = that.mapEvents(data);
					$(ele).fullCalendar('removeEvents');
					$(ele).fullCalendar('addEventSource', that.events);
				}
			})
			.catch(error => {
				console.log('error ', error
				);
			});
		});
	}



	calculateEndDate(startDate, timerange) {
		let endDate = new Date();
		endDate.setTime(startDate.getTime() + (timerange * 60 * 1000));
		return endDate;
	}

	convertDate(fe) {
		return `${fe.getFullYear()}-${(fe.getMonth() + 1).toString().padStart(2, '0')}-${fe.getDate().toString().padStart(2, '0')}`;
	}

	mapEvents(ev) {
		return ev.map(event => ({
			title: (event.RecordType.DeveloperName === 'AV_EventosGestorA' && (USER_ID != this.userid))?
			'Ocupado':event.Subject,
			start: this.parseGMT(event.StartDateTime),
			end: this.parseGMTEnd(event.StartDateTime, event.EndDateTime),
			start_origen: this.parseGMT(event.StartDateTime),
			end_origen: this.parseGMT(event.EndDateTime),
			editable: false,
			color: this.backgroundColorOldEvents,
			textColor: this.textColorOldEvents,
			borderColor: this.borderColorOldEvents,
			isZoomed:false
		}));
	}

	processPrivacity(event){
		let rt = event.RecordType.DeveloperName;
		if( rt === 'AV_EventosGestorA' && (USER_ID != this.userid)){
			return 'Ocupado';
		}else{
			return event.Subject;
		}
	}

	parseGMT(isoDate){
		return this.addMinutesUTC(isoDate,(-1*this.timeZoneOffset));
	}

	parseGMTEnd(isoDateStart,isoDateEnd){
		let duration = new Date(isoDateEnd).getTime() - new Date(isoDateStart).getTime();
		duration /= (1000*60);
		let a =  this.addMinutesUTC(isoDateEnd,(-1*this.timeZoneOffset));
		if(duration < 30) {
			a = this.addMinutesUTC(isoDateStart,(-1*this.timeZoneOffset)+30);
		}
		return a;
	}

	timeInRange(start,end,evaluate){
		let a = new Date(start).getTime();
		let b = new Date(end).getTime();
		let c = new Date(
			Date.UTC(
				evaluate.getFullYear(),
				evaluate.getMonth(),
				evaluate.getDate(),
				evaluate.getHours(),
				evaluate.getMinutes(),
				0
			)
		).getTime();
		return (c>=a && c<b);
	}

	@api
	get initTime() {

		return this._initTimeToSend;
	}

	@api	
	get endTime() {
		return this._endTimeToSend;
	}

	@api
	get finalDate() {
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

	parseUTC(dateToParse){
		return new Date(Date.UTC(
			dateToParse.getFullYear(),
			dateToParse.getMonth(),
			dateToParse.getDate(),
			dateToParse.getHours(),
			dateToParse.getMinutes(),
			0


		));
	}

	correctOffSet(dateToCorrect){

		return new Date(dateToCorrect.setHours(dateToCorrect.getHours() + dateToCorrect.getTimezoneOffset()/60));
	}

	addMinutesUTC(utcString,minutes){
		let utcToDate = new Date(utcString);
		utcToDate.setUTCMinutes(utcToDate.getUTCMinutes() + minutes);
		return utcToDate.toISOString();
	}

	calculateOffset(timeZone) {
		const now = new Date();
		// Get the time in the target time zone as a UTC string
		const timeZoneDate = new Date(now.toLocaleString('en-US', { timeZone }));
		// Calculate the UTC offset in minutes
		const offset = (timeZoneDate.getTime() - now.getTime()) / 60000;
		// Adjust the offset to absolute UTC (remove the local time zone difference)
		const absoluteOffset = now.getTimezoneOffset() - offset;
		// return Math.round(offset);
		return Math.round(absoluteOffset);
    }
}