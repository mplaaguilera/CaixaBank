import { LightningElement, wire, api, track } from 'lwc';
import { loadStyle } from 'lightning/platformResourceLoader';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

import customCss from '@salesforce/resourceUrl/CustomCssRecordForm';

//labels
import confidencialidad from '@salesforce/label/c.CIBE_Confidencialidad';
import fecha from '@salesforce/label/c.CIBE_Fecha';
import horainicio from '@salesforce/label/c.CIBE_Horainicio';
import duracion from '@salesforce/label/c.CIBE_Duracion';
import asunto from '@salesforce/label/c.CIBE_Asunto';
import buscaEmpleado from '@salesforce/label/c.CIBE_BuscaEmpleado';
import owner from '@salesforce/label/c.CIBE_Owner';
import contactoprincipal from '@salesforce/label/c.CIBE_ContactoPrincipal';
import msjnoapaoderado from '@salesforce/label/c.CIBE_MsjNoApoderado';
import asisCXB from '@salesforce/label/c.CIBE_AsistentesCaixabank';
import buscaContacto from '@salesforce/label/c.CIBE_BuscaContacto';
import asistentesEmpresas from '@salesforce/label/c.CIBE_AsistentesEmpresas';
import ubicacion from '@salesforce/label/c.CIBE_Ubicacion';
import commentPlaceholder from '@salesforce/label/c.CIBE_EscribeAqui';
import comentario from '@salesforce/label/c.CIBE_Comentario';

//apex:
import searchEmployee from '@salesforce/apex/CIBE_NewEventController.searchEmployees';
import getContactoPrincipal from '@salesforce/apex/CIBE_NewEventController.getContactoPrincipal';
import searchCXB from '@salesforce/apex/CIBE_NewEventController.searchUserCXB';
import searchEMP from '@salesforce/apex/CIBE_NewEventController.searchUserEMP';
import getGrupoComercial from '@salesforce/apex/CIBE_NewEventController.getGrupoComercial';
import updateEventGC from '@salesforce/apex/CIBE_NewEventController.updateEventGC';

export default class Cibe_RecordForm extends LightningElement {

    renderComponent = false;

    labels = { confidencialidad, fecha, horainicio, duracion, asunto, buscaEmpleado, owner, contactoprincipal, msjnoapaoderado, asisCXB, buscaContacto, asistentesEmpresas, ubicacion, commentPlaceholder, comentario };    //PRIMERA FILA
    confidencial;
    contactType;
    activityDateToSend;
    currentHour;
    duration;
    //SEGUNDA FILA
    durationToSend;
    asunto;
    apoderado;
    phoneField;

    //TERCERA FILA
    ubicacionText;
    comentarios;
    initialemployee;
    optionsApoderados;
    timeFin;

    @track selectedAttendesEMP = [];
    @track selectedAttendesCXB = [];
    selectedAttendesToSend = [];
    attendeesNamesEMP;
    attendeesNamesCXB;
    multiSelectionAttendeeCXB = 0;
    multiSelectionAttendeeEMP = 0;

    showLocationInput = true;
    attendesCXB = false;
    attendesEMP = false;

    employeeToSend = null;
    employeeName = null;
    datosPersonaContacto;
    utcDateTime;
    hideInputsDateTime = false;

    @api inforecord
    @api origin;
    @track empresaGr = false;
    @track optionsGC;
    @track empresaGCSel;
    @track selectedClientsGC = [];
    @track selectedIdsGC = [];

    @track clienteGCName;

    connectedCallback() {
        this.hideInputsDateTime = this.origin === 'editEvent' ? true : false;
        if (this.inforecord) {
            this.getMainContact(this.inforecord.accountId);
            this.associateFields(this.inforecord);
            this.checkFieldVisibilityAndDuration();
        }
    }

    /**
     * Loads from the static resources a css that allows to style the radio-group to look horizontal.
     */
    renderedCallback() {
        Promise.all([
            loadStyle(this, customCss)
        ])
    }

    get today() {
        var date = new Date();
        var isoString = date.toISOString();
        return isoString.slice(0, 10);
    }
    /**
     * each of the radio-group options and their values.
     */
    get contactTypeOptions() {
        return [
            { label: 'Visita cliente', value: 'VC' },
            { label: 'Entrevista centro', value: 'EC' },
            { label: 'LLamada', value: 'LMD' },
            { label: 'Videollamada', value: 'VLD' }
        ];
    }
    /**
     * each of the options in duration combobox and their values.
     */
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

    /**
     * This method is triggered each time an option is changed in the radio-group.
     * @param {*} event with the current value of the selection
     */
    handleChangeContactType(event) {
        this.contactType = event.detail.value;
        this.checkFieldVisibilityAndDuration();
        this.sendDataToUpdate();
    }

    /**
     * This method is triggered each time an option is changed input toggle.
     * @param {*} event with the current value of the selection
     */
    handleConfidencial(event) {
        this.confidencial = event.target.checked;
        this.sendDataToUpdate();
    }

    /**
     * This method is triggered each time an option is changed in lightning-input inputDate.
     * @param {*} event with the current value of the selection
     */
    handleChangeActivityDate(event) {
        this.template.querySelector('[data-id="activityDateInput"]').reportValidity();
        this.activityDateToSend = event.target.value;
        this.sendDataToUpdate();
    }

    /**
     * This method is triggered each time an option is changed in lightning-input inputTime.
     * @param {*} event with the current value of the selection
     */
    handleChangeTimeInicio(event) {
        this.currentHour = event.target.value;
        this.sendDataToUpdate();
    }

    handleChangeDuration(event) {
        this.duration = event.target.value;
        this.sendDataToUpdate();
    }

    handleAsunto(event) {
        this.asunto = event.target.value;
        this.sendDataToUpdate();
    }

    handleSelectionEmployee() {
        let employeeSelection = this.template.querySelector('[data-id="employeelookup"]').getSelection()[0];

        if (employeeSelection != null && employeeSelection != undefined) {
            this.employeeToSend = employeeSelection.id;
            this.employeeName = employeeSelection.title;
            this.initialemployee = [{ id: employeeSelection.id, title: employeeSelection.title, icon: 'standard:account' }];
        }
        this.sendDataToUpdate();
    }
    handleSearchEmployee(event) {
        this.searchEmployee(event.detail.searchTerm);
        this.sendDataToUpdate();
    }


    handleChangeApoderado(event) {
        this.apoderado = event.detail.value;

        const contact = this.datosPersonaContacto.find(pc => pc.ContactId === this.apoderado);
        if (contact) {
            this.phoneField = contact.Contact.Phone !== null ? contact.Contact.Phone : contact.Contact.Account.CIBE_Movil__c;
        } else {
            this.phoneField = null;
        }

        this.sendDataToUpdate();
    }

    handleComentarios(event) {
        this.comentarios = event.target.value;
        this.sendDataToUpdate();
    }

    handleUbicacion(event) {
        this.ubicacionText = event.target.value;
        this.sendDataToUpdate();
    }

    handlePhone() {
        if (this.phoneField != undefined) {
            this.makeCall(this.phoneField);
        }
    }


    handleSelectionAttendee(e) {
        let attendeeLookup = this.template.querySelector(`[data-id="${e.target.dataset.id}"]`);
        let attendeeSelection = attendeeLookup.getSelection()[0];
        if (e.target.dataset.id === 'attendeeslookupCXB') {
            if (attendeeSelection != null && attendeeSelection != undefined) {
                this.selectedAttendesCXB.push({
                    id: attendeeSelection.id,
                    label: attendeeSelection.title,
                    bucleId: ++this.multiSelectionAttendeeCXB
                }
                );
                this.attendesCXB = true;
                attendeeLookup.handleClearSelection();
            }
            this.attendeesNamesCXB = '';
            for (let i = 0; i < this.selectedAttendesCXB.length; i++) {
                if (i == this.selectedAttendesCXB.length - 1) {
                    this.attendeesNamesCXB = this.attendeesNamesCXB + this.selectedAttendesCXB[i].label;
                } else {
                    this.attendeesNamesCXB = this.attendeesNamesCXB + this.selectedAttendesCXB[i].label + ', ';
                }
            }
        } else {
            if (attendeeSelection != null && attendeeSelection != undefined) {
                this.selectedAttendesEMP.push({
                    id: attendeeSelection.id,
                    label: attendeeSelection.title,
                    bucleId: ++this.multiSelectionAttendeeEMP
                }
                );
                this.attendesEMP = true;
                attendeeLookup.handleClearSelection();
            }
            this.attendeesNamesEMP = '';
            for (let i = 0; i < this.selectedAttendesEMP.length; i++) {
                if (i == this.selectedAttendesEMP.length - 1) {
                    this.attendeesNamesEMP = this.attendeesNamesEMP + this.selectedAttendesEMP[i].label;
                } else {
                    this.attendeesNamesEMP = this.attendeesNamesEMP + this.selectedAttendesEMP[i].label + ', ';
                }
            }
        }
        this.sendDataToUpdate();
    }

    handleSearchClick(e) {
        this.searchUserTeamCbx(this.infoObj.accountId);
        this.sendDataToUpdate();
    }


    handleSearchAttendes(e) {
        if (e.target.dataset.id === 'attendeeslookupCXB') {
            this.searchCxb(e.detail.searchTerm, this.selectedAttendesToSend)
        } else {
            this.searchEmp(e.detail.searchTerm, this.selectedAttendesToSend);
        }
        this.sendDataToUpdate();
    }


    handleRemoveAttende(e) {
        let idToDel = e.target.name;
        if (e.target.dataset.id === 'attendeesCXB') {
            this.attendeesNamesCXB = '';
            for (let i = 0; i < this.selectedAttendesCXB.length; i++) {
                if (this.selectedAttendesCXB[i].id === idToDel) {
                    this.selectedAttendesCXB.splice(i, 1);
                    break;
                }
                if (i == this.selectedAttendesCXB.length - 1) {
                    this.attendeesNamesCXB = this.attendeesNamesCXB + this.selectedAttendesCXB[i].label;
                } else {
                    this.attendeesNamesCXB = this.attendeesNamesCXB + this.selectedAttendesCXB[i].label + ', ';
                }
            }
            this.attendesCXB = this.selectedAttendesCXB.length > 0;
        }
        else {
            this.attendeesNamesEMP = '';
            for (let i = 0; i < this.selectedAttendesEMP.length; i++) {
                if (this.selectedAttendesEMP[i].id === idToDel) {
                    this.selectedAttendesEMP.splice(i, 1);
                    break;
                }
                if (i == this.selectedAttendesEMP.length - 1) {
                    this.attendeesNamesEMP = this.attendeesNamesEMP + this.selectedAttendesEMP[i].label;
                } else {
                    this.attendeesNamesEMP = this.attendeesNamesEMP + this.selectedAttendesEMP[i].label + ', ';
                }
            }
            this.attendesEMP = this.selectedAttendesEMP.length > 0
        }
        this.sendDataToUpdate();
    }

    /**
     * Depending on the type of contact chosen in the radio-button, the visibility of the fields will change.
     * This method is in charge of validating which fields should or should not be shown.
     */
    checkFieldVisibilityAndDuration() {
        if (this.contactType === 'EC' || this.contactType === 'LMD' || this.contactType === 'VLD') {
            this.showLocationInput = false;
            this.duration = (this.contactType === 'EC') ? '60' : '30';
        } else {
            this.showLocationInput = true;
            this.duration = '60';
        }
    }


    sendDataToUpdate() {
        if (this.contactType === 'EC' || this.contactType === 'LMD' || this.contactType === 'VLD') {
            this.ubicacionText = null;
        }
        this.selectedAttendesToSend = [];
        if (this.selectedAttendesCXB.length > 0) {
            this.selectedAttendesCXB.forEach(att => {
                this.selectedAttendesToSend.push(att.id);
            });
        }

        if (this.selectedAttendesEMP.length > 0) {
            this.selectedAttendesEMP.forEach(att => {
                this.selectedAttendesToSend.push(att.id);
            });
        }

        let evtToUpdate = {
            ev: {
                Id: this.inforecord.id,
                RecordTypeId: this.inforecord.recordTypeId,
                WhatId: this.inforecord.accountId,
                WhoId: this.apoderado ? this.apoderado : null,
                OwnerId: this.initialemployee[0].id,
                Subject: this.asunto,
                Duration: this.duration,
                Description: this.comentarios ? this.comentarios : '',
                Tipo: this.contactType,
                StartDateTime: this.dateTimeToUTC(this.activityDateToSend, this.currentHour),
                EndDateTime: `${this.utcDateTime.split(' ')[0]} ${new Date(new Date().setHours(...(this.utcDateTime.split(' ')[1].split(":").map(Number)), 0, 0) + this.duration * 60000).toTimeString().slice(0, 5)}`,
                ActivityDate: this.activityDateToSend,
                Location: this.ubicacionText ? this.ubicacionText : '',
                Confidential: this.confidencial,
                selectedClients: this.selectedClientsGC,
                selectedClientsId: this.selectedIdsGC
            },
            attendees: this.selectedAttendesToSend
        }

        this.dispatchEvent(
            new CustomEvent('eventinfo', {
                detail: evtToUpdate
            })
        )
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


    associateFields(infoObj) {
        this.getMainContact(infoObj.accountId);
        this.confidencial = infoObj.confidencial;
        this.contactType = infoObj.contactType;
        this.activityDateToSend = new Date(infoObj.startDateTime).toISOString().substring(0, 10);
        this.currentHour = this.getFormatedHour(infoObj.startDateTime)
        this.initialemployee = [{ id: infoObj.ownerId, title: infoObj.ownerName, icon: 'standard:account' }];
        this.asunto = infoObj.subject;
        this.apoderado = infoObj.contactoPId ? infoObj.contactoPId : '';
        this.ubicacionText = infoObj.location;;
        this.comentarios = infoObj.description;
        if (infoObj.asistentesCBX) {
            this.selectedAttendesCXB = this.createAttendesList(infoObj.asistentesCBX);
            this.attendesCXB = true;
        }
        if (infoObj.asistentesEMP) {
            this.selectedAttendesEMP = this.createAttendesList(infoObj.asistentesEMP);
            this.attendesEMP = true;
        }
    }


    /**
     * If you pass it a list with the information of each attendees, it returns another list with the necessary format to paint them in the boxes
     * @param {*} origenListInfo list with the information of each attendees
     * @returns new formated list
     */
    createAttendesList(origenListInfo) {
        let listToSetAttendes = [];
        origenListInfo.forEach((assistent) => {
            listToSetAttendes.push({
                id: assistent.Id,
                label: assistent.FirstName,
                bucleId: ++this.multiSelectionAttendeeCXB
            })
        });
        return listToSetAttendes;
    }

    /**
     * 
     * @param {*} isoDate date in ISO format
     * @returns the formatted time of a date received by parameter
     */
    getFormatedHour(isoDate) {
        const formattedHours = new Date(isoDate).getHours().toString().padStart(2, '0');
        const formattedMinutes = new Date(isoDate).getMinutes().toString().padStart(2, '0');
        const formattedTime = `${formattedHours}:${formattedMinutes}`;
        return formattedTime;
    }


    makecall(phoneNumber) {
        console.log('make call phoneNumber ', phoneNumber);
    }


    searchEmployee(eventSearchTerm) {
        searchEmployee({ searchTerm: eventSearchTerm })
            .then(result => {
                if (result) {
                    this.template.querySelector('[data-id="employeelookup"]').setSearchResults(result);
                }
            }).catch(error => {
                console.log(error);
            });
    }


    searchEmp(searchTermParm, selectedAttendes) {
        searchEMP({ searchTerm: searchTermParm, selectedIds: selectedAttendes })
            .then((result) => {
                this.template.querySelector('[data-id="attendeeslookupEMP"]').setSearchResults(result);
            })
            .catch((error) => {
                console.error(error);
            });
    }


    searchCxb(searchTermParm, selectedAttendes) {
        searchCXB({ searchTerm: searchTermParm, selectedIds: selectedAttendes })
            .then((result) => {
                this.template.querySelector('[data-id="attendeeslookupCXB"]').setSearchResults(result);
            })
            .catch((error) => {
                console.error(error);
            });
    }

    searchUserTeamCbx(accId) {
        searchUserTeamCXB({ recordId: accId })
            .then((result) => {
                this.template.querySelector('[data-id="attendeeslookupCXB"]').setSearchResults(result);
            })
            .catch((error) => {
                console.error(error);
            });
    }

    //para el listado de contacto principal  si tiene whoid informarlo.

    getMainContact(accId) {
        getContactoPrincipal({ accountId: accId })
            .then((result) => {
                if (result) {
                    this.datosPersonaContacto = result;
                    let options = [];
                    result.forEach(element => {
                        if (element.Contact.RecordType.DeveloperName === 'CIBE_ContactoComercial') {
                            options.push({ label: element.Contact.Name + ' - Contacto comercial', value: element.Contact.Id });
                        } else if (element.Contact.RecordType.DeveloperName === 'CIBE_Apoderado' && element.Contact.CIBE_Carrec__c !== '00016' && (element.Contact.CIBE_FechaVencimiento__c >= this.today || element.Contact.CIBE_FechaVencimiento__c == null)) {
                            options.push({ label: element.Contact.Name + ' - Apoderado', value: element.Contact.Id });
                        } else if (element.Contact.RecordType.DeveloperName === 'CIBE_Apoderado' && element.Contact.CIBE_Carrec__c === '00016' || (element.Contact.CIBE_FechaVencimiento__c < this.today)) {
                            options.push({ label: element.Contact.Name + ' - Contacto comercial', value: element.Contact.Id });
                        }
                    });
                    this.optionsApoderados = options;
                    this.optionsApoderados.push({ label: '', value: null });
                    let ev = {
                        detail: {
                            value: this.apoderado
                        }
                    }
                    this.handleChangeApoderado(ev);
                    this.renderComponent = true;
                }
            })
            .catch((error) => {
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

    handleEmpresaGrupo(event) {
        this.empresaGr = event.target.checked;
    }

    handleChangeGC(event) {
        this.empresaGCSel = event.detail.value;
        let labelClienteSelecionado = this.optionsGC.find(opt => opt.value === this.empresaGCSel).label;
        let idClienteSelecionado = this.optionsGC.find(opt => opt.value === this.empresaGCSel).value;
        let grupocomercial;

        if (idClienteSelecionado === 'todosClientes') {
            this.selectedClientsGC = [];
            this.selectedIdsGC = [];
            this.selectedIdsGC.push(this.inforecord.accountId);
            this.selectedClientsGC.push({ id: this.inforecord.accountId, value: this.inforecord.name });

            this.optionsGC.forEach(opt => {
                if (opt.value !== idClienteSelecionado) {
                    this.selectedClientsGC.push({ id: opt.value, value: opt.label });
                    this.selectedIdsGC.push(opt.value);
                }
            })
        } else {
            this.selectedClientsGC.push({ id: idClienteSelecionado, value: labelClienteSelecionado });
            this.selectedIdsGC.push(idClienteSelecionado);
        }

        if (this.selectedClientsGC) {
            this.selectedIdsGC.forEach(sel => {
                if (grupocomercial) {
                    grupocomercial = grupocomercial + ',' + sel;
                } else {
                    grupocomercial = sel;
                }
            })

            updateEventGC({ evento: this.recordId, gruposComerciales: grupocomercial });
        }
        this.sendDataToUpdate();
    }

    handleRemoveAttendeGC(e) {
        let idToDel = e.target.name;
        this.clienteGCName = '';
        let grupocomercial;

        for (let i = 0; i < this.selectedClientsGC.length; i++) {
            if (this.selectedClientsGC[i].id === idToDel) {
                this.selectedClientsGC.splice(i, 1);
                break;
            }

            if (i == this.selectedClientsGC.length - 1) {
                this.clienteGCName = this.clienteGCName + this.selectedClientsGC[i].label;
            } else {
                this.clienteGCName = this.clienteGCName + this.selectedClientsGC[i].label + ', ';
            }
        }
        if (this.selectedClientsGC) {
            this.selectedIdsGC.forEach(sel => {
                if (grupocomercial) {
                    grupocomercial = grupocomercial + ',' + sel;
                } else {
                    grupocomercial = sel;
                }
            })
            updateEventGC({ evento: this.inforecord.id, gruposComerciales: grupocomercial });
        }
        this.sendDataToUpdate();
        this.attendesEMP = this.selectedClientsGC.length > 0
    }

    @track _wiredData;
    @wire(getGrupoComercial, { recordId: '$inforecord.accountId' })
    getGrupoComercial(wiredData) {
        //GC
        this._wiredData = wiredData;
        const { data, error } = wiredData;
        this.totalPage = 1;
        let optionsAux = [];

        if (data) {
            optionsAux.push({ label: 'TODOS LOS CLIENTES', value: 'todosClientes' });
            this.data = data.map((item) => {
                const iconObj = { ...item };
                optionsAux.push({ label: item.subtitle, value: item.icon.replace('/', '') });
                return iconObj;
            });

            if (this.data[0] != undefined && this.data[0].nOpps != null) {
                this.totalPage = Math.ceil(this.data[0].nOpps / 10);
            }
            if (this.offSet === this.offSetUpdate) {
                this.page = 1;
                this.rowOffset = 0;
            }

            this.optionsGC = optionsAux;
            this.empresaGr = true;
            this.getGC();
            this.isLoading = false;

        } else if (error) {
            this.isLoading = false;
            console.log(error);
        } else {
            this.isLoading = false;
            this.totalPage = 1;
        }
    }

    getGC() {
        this.selectedClientsGC = [];
        let arrayGC;
        if (this.inforecord.gruposComerciales) {
            arrayGC = this.inforecord.gruposComerciales.split(',');
        }
        if (arrayGC) {
            arrayGC.forEach(gc => {
                if (this.optionsGC) {
                    this.optionsGC.forEach(opt => {
                        if (opt != undefined) {
                            if (opt.value === gc) {
                                this.selectedClientsGC.push({ id: opt.value, value: opt.label });
                                this.selectedIdsGC.push(opt.value);
                            }
                        }
                    })
                }
            })
        }

    }
}