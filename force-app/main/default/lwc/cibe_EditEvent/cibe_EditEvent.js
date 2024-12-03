import { LightningElement, wire, api } from 'lwc';
import cita from '@salesforce/label/c.CIBE_Event';
import getClientInfo from '@salesforce/apex/CIBE_EditEvent_Controller.getInfoCliente';
import updateEvent from '@salesforce/apex/CIBE_EditEvent_Controller.updateEvent';
import { CurrentPageReference, NavigationMixin } from 'lightning/navigation';
import { getRecord } from 'lightning/uiRecordApi';
import { EnclosingTabId, getTabInfo, getFocusedTabInfo, closeTab, setTabLabel, IsConsoleNavigation } from 'lightning/platformWorkspaceApi';

import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import fechahora from '@salesforce/label/c.CIBE_FechaHora';
import duracion from '@salesforce/label/c.CIBE_Duracion';
import horafin from '@salesforce/label/c.CIBE_Horafin';
import horainicio from '@salesforce/label/c.CIBE_Horainicio';
import fecha from '@salesforce/label/c.CIBE_Fecha';
import modocal from '@salesforce/label/c.CIBE_ModoCalendario';
import add from '@salesforce/label/c.CIBE_Add';
import laboral from '@salesforce/label/c.CIBE_Laboral';
import completo from '@salesforce/label/c.CIBE_Completo';
import callApiTeams from '@salesforce/apex/CIBE_NewEventController.callApiTeams';
import USER_ID from '@salesforce/user/Id';
import FUNCION from '@salesforce/schema/User.AV_Funcion__c';
const GESTOR = 'Gestor';

export default class Cibe_EditEvent extends NavigationMixin(LightningElement) {
    recordId;

    url;
    urlParams = new URLSearchParams(window.location.search);
    renderComponent = false;
    inforecord;
    labels = { cita }
    changeEventUpdated;
    //calendar variables
    employeeToCalendar;
    activityDateToCalendar;
    subjectToCalendar;
    currentUserFunction;
    overlapToCalendar;
    initialDuration;
    durationToSend;
    renderCalendar = false;
    label = {
        fechahora, duracion, horafin, horainicio, fecha, modocal, add, laboral, completo
    }
    calendarValue = 'laboral';
    calendarBoolean = true;
    get tomorrow() {
        let msInADay = 24 * 60 * 60 * 1000;
        let msForTomorrow = (new Date().getTime()) + msInADay;
        return new Date(msForTomorrow).toJSON().slice(0, 10);
    }
    activityDateToSend;
    timeInicio;
    timeFin;
    timeInfo;
    dateIni;
    dateFin;
    mapDurationText = {
        5: '5 min',
        15: '15 min',
        30: '30 min',
        60: '1 h',
        120: '2 h',
        0: 'Otra'
    }
    get optionsTime() {
        return [
            { label: '5 min', value: '5' },
            { label: '15 min', value: '15' },
            { label: '30 min', value: '30' },
            { label: '1 h', value: '60' },
            { label: '2 h', value: '120' },
            { label: 'Otra', value: '0' }
        ];
    }

    @api showFooter;
    @wire(EnclosingTabId) enclosingTabId;
    @wire(CurrentPageReference) pageRef;
    @wire(IsConsoleNavigation) isConsoleNavigation;

    @wire(getRecord, { recordId: USER_ID, fields: [FUNCION] })
    wiredUser({ error, data }) {
        if (data) {
            this.currentUserFunction = data.fields.AV_Funcion__c.value;
        } else if (error) {
            console.log('Error ', error);
        }
    }


    connectedCallback() {
        this.showFooter = (this.showFooter === '' || this.showFooter == null || this.showFooter == undefined) ? true : this.showFooter
        this.getTabInfoToRecordId();
    }

    /**
     * Retrieve current tab info and close it.
     */
    async closeTab() {
        const { tabId } = await getFocusedTabInfo();
        await closeTab(tabId);
    }

    /**
     * Checks if it gets the recordId to call the method that fetches the information of the current event. 
     * If it has recordId it will call to get the information and set the tab label.
     */
    getTabInfoToRecordId() {
        if (this.enclosingTabId) {
            getTabInfo(this.enclosingTabId).then((tabInfo) => {
                if (tabInfo.pageReference.state && tabInfo.pageReference.state.c__recId) {
                    this.recordId = tabInfo.pageReference.state.c__recId;
                } else if (tabInfo.pageReference.attributes && tabInfo.pageReference.attributes.recordId) {
                    this.recordId = tabInfo.pageReference.attributes.recordId;
                }
                if (this.recordId) {
                    this.getinfoclient();
                    this.setTabLabel();
                }

            }).catch((error) => {
                console.log(error);
            });
        }
    }

    /**
     * Allow set tab label.
     */
    async setTabLabel() {
        if (!this.isConsoleNavigation) {
            return;
        }
        const { tabId } = await getFocusedTabInfo();
        setTabLabel(tabId, 'Modificar cita');
    }

    /**
     * Return options available in calendar
     */
    get optionsCalendario() {
        return [
            { label: this.label.laboral, value: 'laboral' },
            { label: this.label.completo, value: 'completo' }
        ];
    }

    convertirHora(hora) {
        let partes = hora.split(":");
        let date = new Date();
        date.setHours(parseInt(partes[0], 10), parseInt(partes[1], 10), 0, 0);
        return date;
    }


    /**
     * Retrieve the data of the current event via the recordId.
     * When it has the event information, it sets the variable that allows the component to be rendered to true.
     */
    getinfoclient() {
        getClientInfo({ id: this.recordId })
            .then(result => {
                if (result) {
                    this.inforecord = {
                        id: result.ev.Id,
                        name: result.ev.Account.Name,
                        recordtype: result.ev.RecordType.DeveloperName,
                        creteById: result.ev.CreatedById,
                        recordTypeId: result.ev.RecordType.Id,
                        accountId: result.ev.Account.Id,
                        contactPerson: result.ev.WhoId ? result.ev.WhoId : 'sinContacto',
                        contactoPId: result.ev.WhoId ? result.ev.WhoId : '',
                        contactoPName: result.ev.WhoId ? result.ev.WhoId : '',
                        ownerId: result.ev.Owner.Id,
                        ownerName: result.ev.Owner.Name,
                        subject: result.ev.Subject,
                        // description: result.ev.Description,
                        description: result.comentario,
                        contactType: result.ev.AV_Tipo__c,
                        startDateTime: result.ev.StartDateTime,
                        endDateTime: result.ev.EndDateTime,
                        activityDate: result.ev.ActivityDate,
                        location: result.ev.Location,
                        confidencial: result.ev.CIBE_Confidential__c,
                        asistentesCBX: result.asistentesCBX,
                        asistentesEMP: result.asistentesEMP
                    };

                    if (this.inforecord) {
                        this.activityDateToSend = this.inforecord.activityDate;
                        this.timeInicio = this.getFormatedHour(this.inforecord.startDateTime);
                        this.timeFin = this.getFormatedHour(this.inforecord.endDateTime);

                        let horaInicio = this.convertirHora(this.timeInicio);
                        let horaFin = this.convertirHora(this.timeFin);

                        let limiteInicio = this.convertirHora("06:00");
                        let limiteFin = this.convertirHora("18:00");

                        let esLaboral = true;

                        if (horaInicio < limiteInicio || horaInicio >= limiteFin) {
                            esLaboral = false;
                        }
                        if (horaFin <= limiteInicio || horaFin > limiteFin) {
                            esLaboral = false;
                        }

                        if (esLaboral) {
                            this.calendarValue = 'laboral';
                        } else {
                            this.calendarValue = 'completo';
                        }

                        this.calendarBoolean = this.calendarValue === 'laboral';
                        this.overlapToCalendar = this.calendarBoolean;

                        let minutes = Math.abs(new Date(this.inforecord.startDateTime) - new Date(this.inforecord.endDateTime)) / 60000;
                        this.durationToSend = minutes;
                        this.initialDuration = minutes.toString();
                        this.inforecord.eventDuration = this.durationToSend;
                        this.renderComponent = true;
                    }
                }
            })
            .catch(error => {
                console.log('error -> ', error);
            });
    }



    /**
     * It is called from the close button of the layout and sends the last update of the fields to the eventToUpdate method to update them.
     */
    handleCreateEvent() {
        this.eventToUpdate(this.changeEventUpdated);
    }

    /**
     * It is called from the cancel button on the layout and closes the tab without any further action.
     */
    handleCancel() {
        this.closeTab();
    }

    /**
     * Receives each of the child's updates and stores them in the changeEventUpdated object.
     */
    setEventObject(e) {
        this.changeEventUpdated = e.detail;
        this.employeeToCalendar = this.changeEventUpdated.ev.OwnerId;
        this.activityDateToCalendar = this.changeEventUpdated.ev.ActivityDate;
        this.subjectToCalendar = this.changeEventUpdated.ev.Subject;
        if (this.changeEventUpdated.ev.Tipo !== this.inforecord.contactType) {
            this.initialDuration = this.changeEventUpdated.ev.Duration;
            this.durationToSend = this.changeEventUpdated.ev.Duration;
            this.durationToCalendar = this.durationToSend;
        } else {
            this.durationToSend = parseInt(this.initialDuration, 10);
            this.durationToCalendar = this.durationToSend;
        }
        if (this.changeEventUpdated.ev.OwnerId == USER_ID) {
            this.overlapToCalendar = true;
        } else {
            this.overlapToCalendar = this.currentUserFunction != GESTOR;
        }
        if (this.activityDateToCalendar) {
            this.renderCalendar = true;
        }
    }

    /**
      * Apex call to create the attendee relationship
      * @param {*} newEventInserted 
      * @param {*} attendesList 
      * @param {*} mainContact 
      */
    createAttendes(newEventInserted, attendesList, mainContact) {
        callApiTeams({ evt: newEventInserted, attendes: attendesList, contactoPrincipal: mainContact })
            .then(result => {
            })
            .catch(error => {
                console.log(error)
            })
    }

    /**
     * Passes the event to update as a string
     * If you have a list of attendees, create the relationship. 
     * Check if result its ok to close the current tab and displays a message with the result.
     * @param {*} evento 
     */
    eventToUpdate(evento) {
        updateEvent({ evtToUpdate: JSON.stringify(evento.ev) })
            .then(result => {
                if (result) {
                    if (result) {
                        if (evento.attendees.length > 0 || evento.ev.WhoId !== null) {
                            this.createAttendes(result[0], evento.attendees, evento.ev.WhoId);

                        }
                        this.showNotification('¡Evento actualizado!', 'El evento ha sido actualizado correctamente.', 'success');
                        this.closeTab();
                    } else {
                        this.showNotification('Error actualizano el evento!', 'El evento no ha podido ser actualizado.', 'error');
                    }
                }
            })
            .catch(error => {
                console.log('error ', error);
            })
    }


    /**
     * When an error occur, we call this method to show the notification. 
     * @param {*} title The title of notification
     * @param {*} message The message the user sees
     * @param {*} variant If possible that the notificacion be an error or other, for example: success, warning and changes visual of notifications
     */
    showNotification(title, message, variant) {
        const evt = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant
        });
        this.dispatchEvent(evt);
    }


    //calendar methods
    // formatDate(date) {
    //     var dateToFormat = new Date(date);
    //     return this.setHours(dateToFormat.getDate()) + '/' + this.setMonths(dateToFormat.getMonth()) + '/' + dateToFormat.getFullYear();
    // }

    handleCalendarMode(e) {
        this.calendarValue = e.target.value;
        this.calendarBoolean = this.calendarValue == 'laboral' ? true : false;
        this.overlapToCalendar = this.calendarBoolean;

    }


    handleChangeActivityDate(e) {
        this.template.querySelector('[data-id="activityDateInput"]').reportValidity();
        this.activityDateToCalendar = e.target.value;
        this.activityDateToSend = e.target.value;

    }

    handleChangeTimeInicio(e) {
        this.timeInicio = e.target.value;


        var iniDate = new Date(this.activityDateToSend + ' ' + this.timeInicio);
        var finDate = new Date(this.activityDateToSend + ' ' + this.timeFin);
        var numDiff = finDate.getTime() - iniDate.getTime();
        numDiff /= (1000 * 60);
        if (numDiff != 5 && numDiff != 15 && numDiff != 30 && numDiff != 60 && numDiff != 120) {
            this.durationToSend = numDiff;
            this.initialDuration = '0';
        } else {
            this.durationToSend = numDiff;
            this.initialDuration = numDiff.toString();
        }
        if (this.durationToSend == 0) {
            this.durationToCalendar = numDiff;
        } else {
            this.durationToCalendar = this.durationToSend;

        }
        this.timeInfo = {
            date: this.formatDate(this.activityDateToSend),
            hourini: this.timeInicio,
            hourfin: this.timeFin,
            duration: this.mapDurationText[this.durationToSend]
        };
        this.changeEventUpdated.ev.Duration = this.durationToSend;
    }

    handleChangeTimeFin(e) {
        this.timeFin = e.target.value;

        var iniDate = new Date(this.activityDateToSend + ' ' + this.timeInicio);
        var finDate = new Date(this.activityDateToSend + ' ' + this.timeFin);
        var numDiff = finDate.getTime() - iniDate.getTime();
        numDiff /= (1000 * 60);
        if (numDiff != 5 && numDiff != 15 && numDiff != 30 && numDiff != 60 && numDiff != 120) {
            this.durationToSend = numDiff;
            this.initialDuration = '0';
        } else {
            this.durationToSend = numDiff;
            this.initialDuration = numDiff.toString();
        }
        if (this.durationToSend == 0) {
            this.durationToCalendar = numDiff;
        } else {
            this.durationToCalendar = this.durationToSend;
        }
        this.timeInfo = {
            date: this.formatDate(this.activityDateToSend),
            hourini: this.timeInicio,
            hourfin: this.timeFin,
            duration: this.mapDurationText[this.durationToSend]
        };
        this.changeEventUpdated.ev.Duration = this.durationToSend;
    }


    handleChangeDuration(e) {
        this.durationToSend = parseInt(e.target.value);
        this.initialDuration = e.target.value;
        var iniDate = new Date(this.activityDateToSend + ' ' + this.timeInicio);
        var finDate = new Date(this.activityDateToSend + ' ' + this.timeFin);
        iniDate.setHours(iniDate.getHours(), iniDate.getMinutes() + this.durationToSend, '00');
        if (this.durationToSend == 0) {
            var numDiff = finDate.getTime() - iniDate.getTime();
            numDiff /= (1000 * 60);
            this.durationToCalendar = numDiff;
        } else {
            this.durationToCalendar = this.durationToSend;
            this.timeFin = this.setHours(iniDate.getHours()) + ':' + this.setHours(iniDate.getMinutes());
        }
        this.timeInfo = {
            date: this.formatDate(this.activityDateToSend),
            hourini: this.timeInicio,
            hourfin: this.timeFin,
            duration: this.mapDurationText[this.durationToSend]
        };

        this.changeEventUpdated.ev.Duration = this.durationToSend;
    }





    eventCreateCalendar(e) {
        if (!e.detail.validation) {
            this.showToast('Error', this.label.errorAsunto, 'Error');
        } else {
            this.dateIni = new Date(e.detail.initTiment.toString());
            this.dateFin = new Date(e.detail.endTime.toString());
            this.activityDateToSend = this.formatUTCDate(e.detail.initTiment.toUTCString())
            let activityDateToSendFIN = this.formatUTCDate(e.detail.endTime.toUTCString())
            this.changeEventUpdated.ev.ActivityDate = this.activityDateToSend;
            this.changeEventUpdated.ev.StartDateTime = `${this.activityDateToSend} ${this.dateIni.getUTCHours() + ':' + this.setHours(this.dateIni.getMinutes())}`
            this.changeEventUpdated.ev.EndDateTime = `${activityDateToSendFIN} ${this.dateFin.getUTCHours() + ':' + this.setHours(this.dateFin.getMinutes())}`
            this.changeEventUpdated.ev.Duration = this.initialDuration;
            this.timeInicio = this.setHours(this.dateIni.getHours()) + ':' + this.setHours(this.dateIni.getMinutes());
            this.timeFin = this.setHours(this.dateFin.getHours()) + ':' + this.setHours(this.dateFin.getMinutes());
        }
    }


    setHours(hour) {
        var listNums = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9];
        if (listNums.includes(hour)) {
            hour = '0' + hour;
        }
        return hour;
    }

    setMonths(month) {
        month = month + 1;
        var listNums = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9];
        if (listNums.includes(month)) {
            month = '0' + month;
        }
        return month;
    }

    formatDate(date) {
        var dateToFormat = new Date(date.toString());
        return this.setHours(dateToFormat.getDate()) + '/' + this.setMonths(dateToFormat.getMonth()) + '/' + dateToFormat.getFullYear();
    }

    formatDateToCalendar(date) {
        var dateToFormat = new Date(date.toString());
        return dateToFormat.getFullYear() + '-' + this.setMonths(dateToFormat.getMonth()) + '-' + this.setHours(dateToFormat.getDate());
    }

    formatUTCDate(fechaUTC) {
        const partes = fechaUTC.split(' ');
        const meses = { Jan: '01', Feb: '02', Mar: '03', Apr: '04', May: '05', Jun: '06', Jul: '07', Aug: '08', Sep: '09', Oct: '10', Nov: '11', Dec: '12' };
        return `${partes[3]}-${meses[partes[2]]}-${partes[1]}`;
    }

    /**
   * Passing a date string and a time string as parameters, creates the dateTime to send to apex in correct format and UTC. 
   * @param {*} date 
   * @param {*} time 
   * @returns correct format and UTC date.
   */
    dateTimeToUTC(date, time) {
        var localDateTime = new Date(`${date} ${time}`);
        function pad(number) {
            return number < 10 ? '0' + number : number;
        }
        var utcYear = localDateTime.getUTCFullYear();
        var utcMonth = pad(localDateTime.getUTCMonth() + 1);
        var utcDay = pad(localDateTime.getUTCDate());
        var utcHours = pad(localDateTime.getUTCHours());
        var utcMinutes = pad(localDateTime.getUTCMinutes());

        var utcDateTimeString = `${utcYear}-${utcMonth}-${utcDay} ${utcHours}:${utcMinutes}`;
        this.utcDateTime = utcDateTimeString;
        return utcDateTimeString
    }

    /**
      * @param {*} isoDate date in ISO format
      * @returns the formatted time of a date received by parameter
      */
    getFormatedHour(isoDate) {
        const formattedHours = new Date(isoDate).getHours().toString().padStart(2, '0');
        const formattedMinutes = new Date(isoDate).getMinutes().toString().padStart(2, '0');
        const formattedTime = `${formattedHours}:${formattedMinutes}`;
        return formattedTime;
    }


    handleTime() {
        if (this.durationToSend == 0) {
            var iniDate = new Date(this.activityDateToSend + ' ' + this.timeInicio);
            var finDate = new Date(this.activityDateToSend + ' ' + this.timeFin);
            var numDiff = finDate.getTime() - iniDate.getTime();
            numDiff /= (1000 * 60);
            this.durationToCalendar = numDiff;
        } else {
            this.durationToCalendar = this.durationToSend;
        }
        this.activityDateToCalendar = this.activityDateToSend;
        this.template.querySelector('[data-id="customcalendar"]').modifyEvent(new Date(this.activityDateToSend + ' ' + this.timeInicio), this.durationToCalendar);
        this.timeInfo = {
            date: this.formatDate(this.activityDateToSend),
            hourini: this.timeInicio,
            hourfin: this.timeFin,
            duration: this.mapDurationText[this.durationToSend]
        };
        this.changeEventUpdated.ev.Duration = this.durationToSend;
    }




}