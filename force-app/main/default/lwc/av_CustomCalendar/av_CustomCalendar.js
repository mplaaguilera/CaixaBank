import { LightningElement, api, track, wire } from 'lwc';
import { loadScript, loadStyle } from 'lightning/platformResourceLoader';
// import FullCalendarJS from '@salesforce/resourceUrl/fullcalendarv3';
import FullCalendarJS from '@salesforce/resourceUrl/AV_FullCalendarJSV3';

import es from '@salesforce/resourceUrl/AV_esLocaleCalendar';
import getEvents from '@salesforce/apex/AV_CustomCalendar_Controller.retrieveEvents';
import USER_ID from '@salesforce/user/Id';

export default class Av_CustomCalendar extends LightningElement {

    @api timeRange;
    @api currentDate;
    @api userId;
    @api evSubject;
    @api gestorOverwrite;


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

	@api availableActions = [];

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

		if(this.timeRange == undefined){
			this.timeRange = this.timerange
		}
		if(this.currentDate == undefined){
			this.currentDate = this.currentdate
		}
		if(this.userId == undefined){
			this.userId = this.userid
		}
		if(this.evSubject == undefined){
			this.evSubject = this.evsubject
		}
        if(this.gestorOverwrite == undefined){
            this.gestorOverwrite = this.gestoroverwrite
        }
	
}
    
    renderedCallback() {
        this.convertLwcInputs();
        this.maxTime = (this.gestorOverwrite) ? "21:00:00":"18:00:00";
        this.renderDate = new Date(this.currentDate.toString());

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
                                            })
                                    })
                                    .catch(error => {
                                        console.log('Error al cargar: locale/es.js', error);
                                    })

                            })
                            .catch(error => {
                                console.log('Error al cargar: fullcalendar.min.js', error);
                            })
                    })
                    .catch(error => {
                        console.log('Error al cargar: moment.min.js', error);
                    })
            })
            .catch(error => {
                console.log('Error al cargar: jquery.min.js', error);
            })

    }

    getCssMetrics(metricInPx,event){
        let growFactor;
        let value = parseInt(metricInPx.split('px')[0],10);
        if(event != null){
            let duration = new Date(event.end).getTime() - new Date(event.start).getTime();
            duration /= (1000*60);
            growFactor = 60 / duration;
        }else{
            growFactor = 1.3;
        }

        return value*growFactor+'px';
    }
    setTimeHeaderString(start,end){
        let hoursStart;
        let minutesEnd;
        let hoursEnd
        let minutesStart;
            hoursStart = start.getHours();
            minutesStart = start.getMinutes()

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
        getEvents({ userId: that.userId, dateDay: that.convertDate(new Date(that.currentDate)) })
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
            slotMaxTime: (that.gestorOverwrite) ? "21:00:00":"18:00:00",
            slotLabelInterval: '01:00:00',
            // slotDuration: '01:00:00',
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

                        let duration = new Date(event.end).getTime() - new Date(event.start).getTime();
                        duration /= (1000*60);

                        if(duration == 15){
                            let timeHeader = that.setTimeHeaderString(new Date(event.start),new Date(event.end));
                            element.html('');
                            element.append($("<div>",{"width":"max-content"}).html(timeHeader));
                            element.append($("<div>").html(event.title));
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
            eventAfterAllRender: function()
            {
                $('.fc-event-container').css('z-index','auto');                 
                $(ele).fullCalendar('clientEvents').forEach(evt => {
                    let a = $('.'+evt._id);
                    a.css('z-index',(evt.isZoomed)?2:1);                    
                })
            },
            timeFormat: 'HH:mm',
            minTime: that.minTime,
            maxTime: that.maxTime,
            weekends: false,
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
                let start = event.start;
                let end = event.end;
                let overlap = false;
                $(ele).fullCalendar('clientEvents').forEach(function (existingEvent) {
                    if (existingEvent.start < end && existingEvent.end > start) {
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
                that._initTime = new Date(date.format());
                that._endTime = that.calculateEndDate(that._initTime, that.timeRange);
                if(!that.gestorOverwrite){
                    that.events.forEach(evt=>{
                            if(that.timeInRange(evt.start,evt.end,that._initTime)){
                                validation = false;
                                return;
                            };
                    })
                }
                if (that.arrEvent.length === 0 && validation) {
                $(ele).fullCalendar('removeEvents', 1);
                    let newEvent = {
                        id: 1,
                        title: that.evSubject,
                        start: that._initTime,
                        end: that._endTime,
                        allDay: false,
                        editable: true,
                        durationEditable: false,
                        color: that.backgroundColorNewEvents,
                        overlap: that.gestorOverwrite
                    };
                    $(ele).fullCalendar('renderEvent', newEvent);
                    that.arrEvent.push(newEvent);
                }
            },
            eventDrop: function (event, delta, revertFunc) {
                    let transEvents = [];
                    $(ele).fullCalendar('clientEvents').forEach(evt => {
                        evt.isZoomed = false;
                        transEvents.push(evt);
                    })

                    $(ele).fullCalendar('updateEvents',transEvents);
                that._initTime = new Date(event.start.format());
                that._endTime = that.calculateEndDate(that._initTime, that.timeRange);

            }
        });
        let newClassNextButton = 'fc-state-default-sin-image';
        // $('.fc-view').css({'z-index':'none !important','position':'absolute'});
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
            that.currentDate = moment.format();
            getEvents({ userId: that.userId, dateDay: that.convertDate(new Date(that.currentDate)) })
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
                })
                
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
                that.currentDate = moment.format();
                getEvents({ userId: that.userId, dateDay: that.convertDate(new Date(that.currentDate)) })
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
                })
        });
        let newClassTodayButton = 'fc-state-default-sin-image';
        $('head').append('<style>.' + newClassTodayButton + ' {border: 1px solid; background-color: #f5f5f5; border-color: #e6e6e6 #e6e6e6 #bfbfbf; border-color: rgba(0,0,0,.1) rgba(0,0,0,.1) rgba(0,0,0,.25); color: #333;text-shadow: 0 1px 1px rgba(255,255,255,.75);box-shadow: inset 0 1px 0 rgba(255,255,255,.2), 0 1px 2px rgba(0,0,0,.05);}</style>');
        $('.fc-today-button').removeClass('fc-state-default').addClass(newClassTodayButton);
        $('.fc-today-button').css('background-color', 'white');
        $('.fc-today-button').css('color', '#1644F1');
        $('.fc-today-button').click(function () {
            that.arrEvent = [];
            var moment = $(ele).fullCalendar('getDate');
            that.currentDate = moment.format();
            getEvents({ userId: that.userId, dateDay: that.convertDate(new Date(that.currentDate)) })
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
                })
        });

    }



    calculateEndDate(startDate, timeRange) {
        let endDate = new Date();
        endDate.setTime(startDate.getTime() + (timeRange * 60 * 1000));
        return endDate;
    }

    convertDate(fe) {
        return `${fe.getFullYear()}-${(fe.getMonth() + 1).toString().padStart(2, '0')}-${fe.getDate().toString().padStart(2, '0')}`;
    }

    mapEvents(ev) {
      
        return ev.map(event => ({
            title: (event.RecordType.DeveloperName === 'AV_EventosGestorA' && (USER_ID != this.userId))?
            'Ocupado':event.Subject,
            // title: this.processPrivacity(event),
            start: this.parseGMT(event.StartDateTime),
            end: this.parseGMT(event.EndDateTime),
            editable: false,
            color: this.backgroundColorOldEvents,
            textColor: this.textColorOldEvents,
            borderColor: this.borderColorOldEvents,
            isZoomed:false
        }));
    }

    processPrivacity(event){
        let rt = event.RecordType.DeveloperName;
        if( rt === 'AV_EventosGestorA' && (USER_ID != this.userId)){
            return 'Ocupado';
        }else{
            return event.Subject;
        }

    }

    parseGMT(isoDate){
        let a = new Date(isoDate);
        return new Date(
            Date.UTC(
                a.getFullYear(),
                a.getMonth(),
                a.getDate(),
                a.getHours(),
                a.getMinutes(),
                0
            )
        ).toISOString();
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
        return this._initTime;
    }

    @api
    get endTime() {
        return this._endTime;
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

}