import { LightningElement, wire, track, api } from 'lwc';
import { CurrentPageReference } from 'lightning/navigation';
import searchProduct from '@salesforce/apex/CIBE_NewEventController.searchProduct';
import createEvent from '@salesforce/apex/CIBE_NewEventController.createEvent';
import callApiTeams from '@salesforce/apex/CIBE_NewEventController.callApiTeams';
import createOrUpdateOpportunities from '@salesforce/apex/CIBE_NewEventController.createOrUpdateOpportunities';
import deleteCreatedEventOrAttendes from '@salesforce/apex/CIBE_NewEventController.backupEventsAndAttendes';
import updateAccessList from '@salesforce/apex/CIBE_NewEventController.updateAccessList';
import vinculateOpportunitiesWO from '@salesforce/apex/CIBE_NewEventControllerWO.vinculateOpposToTheNewEvent';
import getAccountOpportunities from '@salesforce/apex/CIBE_NewEventOppDetail_Controller.getAccountOpportunities';
import getAccountTask from '@salesforce/apex/CIBE_NewEventTaskDetail_Controller.getAccountTask';
import createOrUpdateTasks from '@salesforce/apex/CIBE_NewEventController.createOrUpdateTasks';
import vinculateTasksWO from '@salesforce/apex/CIBE_NewEventControllerWO.vinculateTasksToTheNewEvent';
import getOpp from '@salesforce/apex/CIBE_NewEventController.getOpp';
import palabrasProhibidas from '@salesforce/apex/CIBE_ForbiddenWords.validateRecords';


import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getRecord } from 'lightning/uiRecordApi';
import { NavigationMixin } from 'lightning/navigation';
import USER_ID from '@salesforce/user/Id';
import FUNCION from '@salesforce/schema/User.AV_Funcion__c';

// labels
import duracion from '@salesforce/label/c.CIBE_Duracion';
import horafin from '@salesforce/label/c.CIBE_Horafin';
import horainicio from '@salesforce/label/c.CIBE_Horainicio';
import fecha from '@salesforce/label/c.CIBE_Fecha';
import modocal from '@salesforce/label/c.CIBE_ModoCalendario';
import fechahora from '@salesforce/label/c.CIBE_FechaHora';
import oportunidades from '@salesforce/label/c.CIBE_Oportunidades';
import vinculadas from '@salesforce/label/c.CIBE_Vinculadas';
import cita from '@salesforce/label/c.CIBE_Event';
import add from '@salesforce/label/c.CIBE_Add';
import addOpp from '@salesforce/label/c.CIBE_AddOpp';
import searhProduct from '@salesforce/label/c.CIBE_BuscarProductos';
import cancelar from '@salesforce/label/c.CIBE_Cancelar';
import siguiente from '@salesforce/label/c.CIBE_Siguiente';
import anterior from '@salesforce/label/c.CIBE_Anterior';
import finalizar from '@salesforce/label/c.CIBE_Finalizar';
import laboral from '@salesforce/label/c.CIBE_Laboral';
import completo from '@salesforce/label/c.CIBE_Completo';
import errorAsunto from '@salesforce/label/c.CIBE_ErrorAsunto';
import errorImporte from '@salesforce/label/c.CIBE_ErrorImporte';
import errorOwner from '@salesforce/label/c.CIBE_ErrorOwner';
import faltanDatos from '@salesforce/label/c.CIBE_FaltanDatos';
import errorCalendar from '@salesforce/label/c.CIBE_ErrorCalendar';
import errorCP from '@salesforce/label/c.CIBE_ErrorCP';
import errorHI from '@salesforce/label/c.CIBE_ErrorHI';
import errorHF from '@salesforce/label/c.CIBE_ErrorHF';
import errorDuracion from '@salesforce/label/c.CIBE_ErrorDuracion';
import errorFranja from '@salesforce/label/c.CIBE_ErrorFranja';
import citaOK from '@salesforce/label/c.CIBE_CitaCreadaCorrectamente';
import errorState from '@salesforce/label/c.CIBE_ErrorEstadoRelleno';
import vincularTodasOpp from '@salesforce/label/c.CIBE_VincularTodasOportunidades';
import tareas from '@salesforce/label/c.CIBE_Tareas';
import altaTarea from '@salesforce/label/c.CIBE_AltaTarea';
import tareaCreada from '@salesforce/label/c.CIBE_TareaCreada';


const GESTOR = 'Gestor';
const IDPROVISIONAL = 'idProvisional';
const SEPARATOR = '{|}';
const FIELDS = ['Account.Name'];


export default class Cibe_GestionAgilOpp extends NavigationMixin(LightningElement) {

    label = {
        duracion,
        horafin,
        horainicio,
        fecha,
        modocal,
        fechahora,
        oportunidades,
        vinculadas,
        cita,
        add,
        addOpp,
        searhProduct,
        cancelar,
        siguiente,
        anterior,
        finalizar,
        laboral,
        completo,
        errorAsunto,
        errorImporte,
        errorOwner,
        faltanDatos,
        errorCalendar,
        errorCP,
        errorHI,
        errorHF,
        errorDuracion,
        errorFranja,
        citaOK,
        errorState,
        vincularTodasOpp,
        tareas,
        altaTarea,
        tareaCreada
    }


    @track buttonEnabled = true;
    @track buttonEnabledTask = true;
    @api opposscheduled;
    @track opposscheduledagended = [];
    @api comesfromevent;
    @api reportedevent;
    @api reportedetask;
    @api oportunidadId;
    newEventHeaderId;
    thereisoppos;
    backEventReported = null;
    recordId;
    clientinfo;
    newEvent;
    newEventInserted;
    oppoObj = {};
    oportunidadVin = false;

    selectedProds = [];
    selectedTask = [];
    @track oppoList;
    @track oppoNewList = [];
    @track taskNewList = [];
    potentialList;
    showSpinner = false;
    noComercial = false;
    dateIniFinal;
    dateFinFinal;
    editedOpportunitiesFromReport;
    newRecordFromTaskReport;
    reportedActivityHeaderId;
    updatedClientTasksBack;
    //Variables para el calendario
    durationToCalendar;
    activityDateToCalendar;
    employeeToCalendar;
    subjectToCalendar;
    overlapToCalendar = false;
    currentMainVinculed;
    nextScreen = false;
    today = new Date().toJSON().slice(0, 10);
    newRecordFromReportHeaderId
    showCalendar = false;
    currentUserFunction;
    productToAdd = true;
    idProvisional = 0;
    //rollback vars
    createdEventId;
    createdAttendesOrEventId = [];
    createdOpposIds = [];
    copyOpposBeforeUpdt;
    updatedOpposId;
    altaDeActividadLabel = 'Alta de actividad';
    checkOnOffTasksBackUp;
    caosCheckOnOffBackUp;
    taskAndOpposRel;
    accountId;
    initialDuration;
    calendarValue = 'laboral';
    calendarBoolean = true;
    durationToSend;
    mensajeError = 'vacio';
    palabras = 'vacio';
    validaOpp = false;
    validaEvnt = false;
    setFields = ['Name', 'AV_Comentarios__c'];
    setFieldsTask = ['Subject', 'Description'];
    @track opp = null;

    // Opp
    listAccountOpportunities = [];
    opposCount = 0;
    // Task
    listAccountTask = [];
    taskCount = 0;
    tareaObj = {};
    @track task;
    rcCheckOnOffBackUp;
    createdTasksIds = [];
    currentMainVinculedTask;

    //Event 
    @track estadoEvento;

    //flow tarea
    @track actionSetting;
    @track launchFlow = false;
    inputVariables;

    @track nameTask;

    mapTypeDuration = {
        'EC': '60',
        'VC': '60',
        'LMD': '30',
        'VLD': '30'
    }
    mapDurationText = {
        5: '5 min',
        15: '15 min',
        30: '30 min',
        60: '1 h',
        120: '2 h',
        0: 'Otra'
    }


    disableButtonCancel = false;
    disableButtonSave = false;
    disableButtonBack = false;
    disableButtonCloseMeeting = false;
    disabledButtonSaveMeeting = false;

    isShowModal = false;
    isAgilCerrada = false;
    buttonOrigin;

    horaActual = this.setHours(new Date().getHours()) + ':' + this.setHours(new Date().getMinutes());
    sumarHora = this.setHours(new Date().getHours() + 1);
    timeInicio = this.horaActual.substring(3, 5) >= 1 && this.horaActual.substring(3, 5) < 30 ? this.horaActual.substring(0, 2) + ":30" + this.horaActual.substring(6, this.horaActual.length) : this.sumarHora + ':00';

    @wire(getRecord, { recordId: '$accountId', fields: FIELDS })
    account;

    get accountName() {
        return this.account.data ? this.account.data.fields.Name.value : '';
    }
    get tomorrow() {
        let msInADay = 24 * 60 * 60 * 1000;
        let msForTomorrow = (new Date().getTime()) + msInADay;
        return new Date(msForTomorrow).toJSON().slice(0, 10);
    }
    activityDateToSend = this.tomorrow;
    timeFin;
    timeInfo;

    get optionsCalendario() {
        return [
            { label: this.label.laboral, value: 'laboral' },
            { label: this.label.completo, value: 'completo' }
        ];
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

    setHours(hour) {
        var listNums = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9];
        if (listNums.includes(hour)) {
            hour = '0' + hour;
        }
        return hour;
    }

    @wire(CurrentPageReference)
    setCurrentPageReference(currentPageReference) {
        this.currentPageReference = currentPageReference;
        this.recordId = this.currentPageReference.state.c__oppId;
        this.accountId = this.currentPageReference.state.c__recId;
        this.clientinfo = {
            id: this.recordId,
            name: this.currentPageReference.state.c__id,
            intouch: this.currentPageReference.state.c__intouch,
            recordtype: this.currentPageReference.state.c__rt,
            accountId: this.accountId
        };
        this.durationToSend = parseInt(this.initialDuration, 10);
        var iniDate = new Date(this.activityDateToSend + ' ' + this.timeInicio);
        iniDate.setHours(iniDate.getHours(), iniDate.getMinutes() + this.durationToSend, '00');
        this.timeFin = this.setHours(iniDate.getHours()) + ':' + this.setHours(iniDate.getMinutes());
        this.timeInfo = {
            date: this.formatDate(this.activityDateToSend),
            hourini: this.timeInicio,
            hourfin: this.timeFin,
            duration: this.mapDurationText[this.durationToSend]
        };
    }

    @wire(getRecord, { recordId: USER_ID, fields: [FUNCION] })
    wiredUser({ error, data }) {
        if (data) {
            this.currentUserFunction = data.fields.AV_Funcion__c.value;
        } else if (error) {
            this.error = error;
        }
    }


    validateInputsAddEvents() {
        var dateSend = new Date(this.activityDateToSend);
        if (this.timeInicio == null || this.timeInicio == '' || !this.template.querySelector('[data-id="timeInicioInput"]').reportValidity()) {
            this.scrollIntoElement('timeInicioInput');
            this.showToast(this.label.faltanDatos, this.label.errorHI, 'error');
            return false;
        }
        if (this.timeFin == null || this.timeFin == '' || !this.template.querySelector('[data-id="timeFinInput"]').reportValidity()) {
            this.scrollIntoElement('timeFinInput');
            this.showToast(this.label.faltanDatos, this.label.errorHF, 'error');
            return false;
        }
        var iniDate = new Date(this.activityDateToSend + ' ' + this.timeInicio);
        var finDate = new Date(this.activityDateToSend + ' ' + this.timeFin);
        var numDiff = finDate.getTime() - iniDate.getTime();
        numDiff /= (1000 * 60);
        if (numDiff < 5) {
            this.showToast(this.label.faltanDatos, this.label.errorDuracion, 'error');
            return false;
        }
        return true;
    }



    validateRequiredInputs2() {
        if (this.opp == null) {
            return true
        } else {

            if (this.nextScreen == true && (this.opp['newPath'] != 'Cerrado negativo') && (this.opp['newPath'] != 'Cerrado positivo') && (
                this.opp['fechaProxGest'] == '' || this.opp['fechaProxGest'] == null)) {
                this.showToast('Error', 'Es obligatorio informar el campo Fecha proxima Gestion en la Oportunidad ' + this.opp['Name'], 'Error');
                return false;
            }

            if (this.nextScreen == true
                && ((this.opp['newPath'] == 'Cerrado negativo') && (this.opp['state'] == '' || this.opp['state'] == null))) {
                this.showToast('Error', this.label.errorState, 'Error'); errorState
                return false;
            }

            return true;
        }

    }



    buildOppoObj(e) {
        let nextOppo = (e.detail != null) ? e.detail : e;
        let id = (e.detail != null) ? e.detail.id : e.Id;
        let vinculed = (e.detail != null) ? e.detail.isVinculed : e.isVinculed;
        if (Object.keys(this.oppoObj).includes(id) && !vinculed) {
            delete this.oppoObj[id];
        } else if (vinculed) {
            this.oppoObj[id] = nextOppo;
        }
        this.opp = e.detail;

    }

    handleMainOpp(e) {
        let itemOppId = e.detail.oppoId;
        this.currentMainVinculed = itemOppId;
        let auxList;
        if (this.comesfromevent) {
            auxList = this.listAccountOpportunities;
        } else {
            if (this.oppoList == [] || this.oppoList == undefined) {
                auxList = this.oppoNewList;
            } else {
                auxList = this.oppoList.concat(this.oppoNewList);
            }
        }

        this.listAccountOpportunities.forEach(opp => {

            this.template.querySelector('[data-id="' + opp.id + '"]').mainVinculed = (opp.id === itemOppId);
            opp.isPrincipal = (opp.id === itemOppId);
            if (opp.id === itemOppId && Object.keys(this.oppoObj).includes(itemOppId)) {
                this.oppoObj[itemOppId]['mainVinculed'] = true;
            }
        })
    }


    handleMainTask(e) {
        let itemTaskId = e.detail.tareaId;
        this.currentMainVinculedTask = itemTaskId;
        let auxList = this.listAccountTask;

        this.listAccountTask.forEach(task => {

            if (task.isPrincipal) {
                task.isPrincipal = false;
            }

            this.template.querySelector('[data-id="' + task.id + '"]').mainVinculed = (task.id === itemTaskId);
            task.isPrincipal = (task.id === itemTaskId);
            if (task.id === itemTaskId && Object.keys(this.tareaObj).includes(itemTaskId)) {
                task.isPrincipal = true;
                this.tareaObj[itemTaskId]['mainVinculed'] = true;
            }
        })
    }

    /*****************************************************************************************************************/

    buildTaskObj(e) {
        let nextTask = (e.detail != null) ? e.detail : e
        let id = (e.detail != null) ? e.detail.id : e.Id;
        let vinculed = (e.detail != null) ? e.detail.vinculed : e.vinculed;
        if (Object.keys(this.tareaObj).includes(id) && !vinculed) {
            delete this.tareaObj[id];
        } else if (vinculed) {
            this.tareaObj[id] = nextTask;
        }

        this.task = e.detail;
    }
    /*****************************************************************************************************************/


    handleVinculationOpp(e) {

        let itemOppId = e.detail.oppoId;
        let onlyOneVinculed = (this.opposCount <= 1)
        let auxList;

        if (this.comesfromevent) {
            auxList = this.listAccountOpportunities;
        } else {
            if (this.listAccountOpportunities == undefined) {
                auxList = this.oppoNewList;
            } else {
                auxList = this.listAccountOpportunities.concat(this.oppoNewList);
            }
        }

        if (e.detail.sum) {
            this.opposCount++;
            if (this.oppPrincipal == null) {
                this.template.querySelector('[data-id="' + itemOppId + '"]').mainVinculed = true;
                this.currentMainVinculed = itemOppId;
                this.oppPrincipal = e.detail;
            }


        } else {
            if (this.opposCount > 0) {
                this.opposCount--;
            }
            if (e.detail.oppoId == this.oppPrincipal.oppoId) {
                var isMain = false;
                auxList.forEach(opp => {
                    if (opp.id == e.detail.oppoId) {
                        this.template.querySelector('[data-id="' + opp.id + '"]').mainVinculed = false;
                    }
                    else if (opp.isVinculated && !isMain) {
                        this.oppPrincipal.oppoId = opp.id;
                        isMain = true;
                    } else {
                        this.template.querySelector('[data-id="' + opp.id + '"]').mainVinculed = false;
                    }
                });
            }
        }

        this.listAccountOpportunities.forEach(opp => {
            if (e.detail.oppoId === opp.id) {
                opp.isVinculated = e.detail.sum;
            }

            if (this.oppPrincipal != null && opp.id === this.oppPrincipal.oppoId) {
                opp.isPrincipal = true;
            } else {
                opp.isPrincipal = false;
            }
        })

        if (this.oppPrincipal) {
            this.template.querySelector('[data-id="' + this.oppPrincipal.oppoId + '"]').mainVinculed = true;
        }
    }

    // handleVinculation vinvula de una en una tarea
    handleVinculationTask(e) {

        let itemTaskId = e.detail.tareaId;
        let onlyOneVinculedTask = (this.taskCount <= 1)
        let auxList;
        auxList = this.listAccountTask;
        if (e.detail.sum) {
            this.taskCount++;
            if (this.taskPrincipal == null) {
                this.template.querySelector('[data-id="' + itemTaskId + '"]').mainVinculed = true;
                this.currentMainVinculedTask = itemTaskId;
                this.taskPrincipal = e.detail;
            }
        } else {
            this.taskCount--;
            if (e.detail.tareaId == this.taskPrincipal.tareaId) {
                var isMain = false;
                auxList.forEach(task => {
                    if (task.id == e.detail.tareaId) {
                        this.template.querySelector('[data-id="' + task.id + '"]').mainVinculed = false;
                    }
                    else if (task.isVinculated && !isMain) {
                        this.taskPrincipal.tareaId = task.id;
                        isMain = true;
                    } else {
                        this.template.querySelector('[data-id="' + task.id + '"]').mainVinculed = false;
                    }
                });
            }
        }
        this.listAccountTask.forEach(task => {
            if (e.detail.tareaId === task.id) {
                task.isVinculated = e.detail.sum;
            }
            if (this.taskPrincipal != null && task.id === this.taskPrincipal.tareaId) {
                task.isPrincipal = true;
            } else {
                task.isPrincipal = false;
            }
        })
        if (this.taskPrincipal) {
            this.template.querySelector('[data-id="' + this.taskPrincipal.tareaId + '"]').mainVinculed = true;
        }
    }

    //para oportunidades
    handleSearchProduct(e) {
        searchProduct({ searchTerm: e.detail.searchTerm, recordId: this.accountId })
            .then((results) => {
                this.template.querySelector('[data-id="newproductlookup"]').setSearchResults(results);
            })
            .catch((error) => {
                this.notifyUser('Lookup Error', 'An error occured while searching with the lookup field.', 'error');
                console.error('Lookup error', JSON.stringify(error));
                this.errors = [error];
            });
    }

    evaluateProductToAdd() {
        this.productToAdd = this.template.querySelector("[data-id='newproductlookup']").getSelection().length == 0;
    }


    //para oportunidades
    handleAddOppo() {
        let cmp = this.template.querySelector("[data-id='newproductlookup']");
        let selection = cmp.getSelection()[0];
        const d = new Date(this.activityDateToSend);
        d.setDate(d.getDate() + 7);
        var dateStr = d.getUTCFullYear() + '-' + (d.getMonth() + 1) + '-' + d.getDate();

        if (selection != null) {
            this.selectedProds.push(selection.id);
            this.oppoNewList.push(
                {
                    id: IDPROVISIONAL + this.idProvisional++,
                    name: selection.title,
                    closeDate: dateStr,
                    status: 'En curso',
                    productId: selection.id,
                    AccountId: this.accountId,
                    NotInserted: true,
                    isEditable: true
                }
            );

            getAccountOpportunities({ accountId: this.accountId, eventHeader: this.newEventHeaderId })
                .then((result => {
                    let newListOppAux = result;
                    newListOppAux.sort((a, b) => a.closeDate.localeCompare(b.closeDate));
                    let index = newListOppAux.findIndex(opportunity => opportunity.id === this.recordId);
                    if (index !== -1) {
                        let [elementToMove] = newListOppAux.splice(index, 1);
                    }
                    this.listAccountOpportunities = newListOppAux;
                }))
                .catch((error => {
                    console.log(error);
                }))
            getAccountTask({ accountId: this.accountId, eventHeader: this.newEventHeaderId })
                .then((result => {
                    this.listAccountTask = result;
                }))
                .catch((error => {
                    console.log(error);
                }))
        }
        cmp.handleClearSelection();
    }


    formatDate(date) {
        var dateToFormat = new Date(date);
        return this.setHours(dateToFormat.getDate()) + '/' + this.setMonths(dateToFormat.getMonth()) + '/' + dateToFormat.getFullYear();
    }

    setMonths(month) {
        month = month + 1;
        var listNums = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9];
        if (listNums.includes(month)) {
            month = '0' + month;
        }
        return month;
    }

    handleCreateEvent(e) {
        this.validaEvnt = this.validateRequiredInputs2();
        if (Object.keys(this.oppoObj).length !== 0) {
            this.validaOpp = this.validateRequiredInputsOpp();
        } else {
            this.validaOpp = true;
        }

        if (this.validaEvnt == true && this.validaOpp == true && this.createEventBasedOnEventType) {
            let eventToInsert = {
                sobjectype: 'Event',
                WhatId: this.newEvent['client'],
                WhoId: this.newEvent['personaContacto'] == 'sinContacto' ? null : this.newEvent['personaContacto'],
                AV_Center__c: this.newEvent['center'],
                OwnerId: this.newEvent['owner'],
                Subject: this.newEvent['subject'],
                Description: this.newEvent['comentarios'],
                AV_Tipo__c: this.newEvent['tipoCita'],
                StartDateTime: this.newEvent['startDateTime'],
                EndDateTime: this.newEvent['endDateTime'],
                ActivityDate: this.newEvent['activityDate'],
                AV_BranchPhysicalMeet__c: this.newEvent['otherOfficeNumber'],
                Location: this.newEvent['ubicacionText'],
                CIBE_Confidential__c: this.newEvent['confidencial']
            }

            if (eventToInsert.StartDateTime.getTime() >= Date.now()) {
                this.estadoEvento = 'Pendiente';
            } else {
                this.estadoEvento = 'Gestionada Positiva';
            }
            if (Object.keys(this.tareaObj).length === 0 && Object.keys(this.oppoObj).length === 0 && this.isShowModal === false) {
                this.isShowModal = true;
            } else {
                this.startReportLogic(eventToInsert);
            }

        } else if (!this.createEventBasedOnEventType) {
            if (Object.keys(this.oppoObj).length !== 0) {
                if (this.validaEvnt == true && this.validaOpp == true) {
                    this.updateOrCreateOpportunities();
                    this.showToast('Oportunidad actualizada', '', 'success');
                    if (Object.keys(this.tareaObj).length !== 0) {
                        this.updateOrCreateTasks();
                        this.showToast('Tarea actualizada', '', 'success');
                    }
                } else {
                    this.showToast('Error', this.mensajeError, 'Error');
                }

            } else if (Object.keys(this.tareaObj).length !== 0) {
                if (this.validaEvnt == true && this.validaOpp == true) {
                    this.updateOrCreateTasks();
                    this.showToast('Tarea actualizada', '', 'success');
                } else {
                    this.showToast('Error', this.mensajeError, 'Error');
                }
            }
            if (this.validaEvnt == true && this.validaOpp == true) {
                this.finishReport();
            }
        }
        if (this.mensajeError != 'vacio') {
            this.showToast('Error', this.mensajeError, 'Error');
        }
    }

    startReportLogic(eventToInsert) {
        this.showSpinner = true;
        createEvent({ evt: eventToInsert, est: this.estadoEvento })
            .then(result => {
                if (result.errorResult == undefined) {
                    this.newEventInserted = result.newEvent;
                    this.createdEventId = result.newEventIdWithHeader.split(SEPARATOR)[0];
                    this.newEventHeaderId = result.newEventIdWithHeader.split(SEPARATOR)[1];
                    this.createdAttendesOrEventId.push(this.createdEventId);

                    if (this.mensajeError === 'vacio') {
                        if (this.newEvent['attendes'].length > 0 || (this.newEvent['personaContacto'] !== null && this.newEvent['personaContacto'] !== 'sinContacto')) {
                            this.createAttendes();
                        } else if (Object.keys(this.oppoObj).length !== 0) {
                            this.updateOrCreateOpportunities();
                            this.showToast('Oportunidad actualizada', '', 'success');
                            if (Object.keys(this.tareaObj).length !== 0) {
                                this.updateOrCreateTasks();
                                this.showToast('Tarea actualizada', '', 'success');
                            }
                        } else if (Object.keys(this.tareaObj).length !== 0) {
                            this.updateOrCreateTasks();
                            this.showToast('Tarea actualizada', '', 'success');
                        } else if (this.newEvent['confidencial'] == true) {

                            //**** AVP_ SE DEBERÍA SACAR ESTA LLAMADA A UN MÉTODO. 24/05/2024 */
                            updateAccessList({ recordId: this.createdEventId })
                                .then((result => {
                                    console.log('updateAccessList result-> ', result);
                                }))
                                .catch((error => {
                                    console.log('updateAccessList error-> ', error);
                                }))
                        }

                        if (this.oportunidadId != null) {
                            let preBuildCaoList = [];
                            preBuildCaoList.push(
                                {
                                    AV_Opportunity__c: this.oportunidadId,
                                    AV_Task__c: this.newEventHeaderId,
                                    AV_IsMain__c: false,
                                    AV_OrigenApp__c: 'AV_SalesforceClientReport'
                                }
                            );

                            //**** AVP_ SE DEBERÍA SACAR ESTA LLAMADA A UN MÉTODO. 24/05/2024 */
                            vinculateOpportunitiesWO({
                                caosToInsert: preBuildCaoList,
                                evtId: this.createdEventId
                            })
                                .then(result => {
                                    if (result == true) {
                                        this.showToast('Error al actualizar', 'La fecha de próxima gestión no puede ser superior a la fecha de cierre ni inferior a la fecha actual', 'Error')
                                    }
                                }).catch(error => {
                                    console.log(error);
                                });
                        }

                        this.showToast(this.label.citaOK, result, 'success');
                    }

                } else {
                    console.log('createEvent - error', result);
                    this.showToast('Error creando el evento', result, 'error');
                    this.handleError();
                }

            }).catch(error => {
                console.log('createEvent - error ', error);
                this.showToast('Error creando el evento', error, 'error');
                this.handleError();

            })
            .finally(() => {
                if (this.mensajeError === 'vacio') {
                    this.finishReport();
                } else {
                    this.showToast('Error creando el evento', this.mensajeError, 'error');
                    this.showSpinner = false;
                }
            })
    }


    // metodo para crear opp desde el lookup
    updateOrCreateOpportunities() {
        for (let oppo in this.oppoObj) {
            if ((this.oppoObj[oppo]['newPath'] === 'CIBE_Cerrado positivo' || this.oppoObj[oppo]['newPath'] === 'Cerrado negativo')) {
                this.isAgilCerrada = true;
                this.oppoObj[oppo]['fechaCierre'] = this.newEvent['activityDate'];
            }

        }
        //**** AVP_ SE DEBERÍA SACAR ESTA LLAMADA A UN MÉTODO. 24/05/2024 */
        createOrUpdateOpportunities({ opposToInsertOrUpdate: this.oppoObj, accountId: this.accountId, dateIni: this.dateIniFinal, agil: this.isAgilCerrada })
            .then(result => {
                if (result.errorList == null) {
                    this.oppoObj = result.editedOpportunities;
                    this.checkOnOffTasksBackUp = result.taskToRestoreBack;
                    this.caosCheckOnOffBackUp = result.caoToRestoreBack;
                    this.taskAndOpposRel = result.taskOpposRelation;
                    for (let oppo in this.oppoObj) {
                        if (oppo.includes(IDPROVISIONAL)) {
                            this.createdOpposIds.push(this.oppoObj[oppo]['id']);
                        }
                    }
                    this.vinculateOpportunities();
                } else {
                    result.errorList.forEach(err => {
                        console.log(err);
                    })
                    this.deleteEventRegisters();
                    //BACKUP ATTENDES
                }
            }).catch(error => {
                //BACKUP ATTENDES
                console.log(error);
                this.deleteEventRegisters();
            });
    }

    updateOrCreateTasks() {
        let contacto = this.newEvent['personaContacto'] == 'sinContacto' ? null : this.newEvent['personaContacto'];
        for (let task in this.tareaObj) {
            if (this.tareaObj[task]['vinculed']) {
                if (contacto != null) {
                    this.tareaObj[task]['personaContacto'] = contacto;
                }
                this.tareaObj[task]['tipo'] = this.newEvent['tipoCita'];
            }
        }
        createOrUpdateTasks({ tasksToInsertOrUpdate: this.tareaObj, accountId: this.accountId })
            .then(result => {
                if (result.errorList == null || result.errorList == '') {
                    this.tareaObj = result.editedTasks;
                    this.checkOnOffTasksBackUp = result.taskToRestoreBack;
                    this.rcCheckOnOffBackUp = result.RCToRestoreBack;
                    this.taskAndOpposRel = result.taskOpposRelation;
                    this.vinculateTasks();
                } else {
                    result.errorList.forEach(err => {
                    })
                    this.deleteEventRegisters();
                    //BACKUP ATTENDES
                }
            }).catch(error => {
                //BACKUP ATTENDES
                console.log(error);
                this.deleteEventRegisters();
            });
    }

    deleteEventRegisters() {
        deleteCreatedEventOrAttendes({ recordsToDelete: this.createdAttendesOrEventId, jsonEventToBackReport: this.backEventReported, newRecordFromTaskToDel: this.newRecordFromTaskReport })
            .then(result => {
                if (result == 'OK') {
                    this.showToast(
                        'Error actualizando las oportunidades',
                        'Se han desecho todos los cambios.',
                        'Error');
                } else {
                    this.showToast(
                        'Error actualizando las oportunidades',
                        'El evento ha quedado registrado mal. Por favor, eliminelo manualmente.',
                        'Error');
                }
                this.handleError();
            }).catch(error => {
                console.log(error);
                this.showToast(
                    'Error actualizando las oportunidades',
                    'El evento ha quedado registrado mal. Por favor, eliminelo manualmente.',
                    'Error');
            });
        this.handleError();
    }

    handleCancel() {
        this.dispatchEvent(new CustomEvent('closetab'))
    }

    handleFinish() {
        console.log('handleFinish');
        this.dispatchEvent(new CustomEvent('closetab'))
    }


    handleError() {
        this.dispatchEvent(new CustomEvent('focustab'));
    }

    // vincula cuando crea opp desde el lookup
    vinculateOpportunities() {
        let preBuildCaoList = [];
        let updatedOrCreatedOppos = [];
        for (let id in this.oppoObj) {
            let currentOppo = this.oppoObj[id]
            updatedOrCreatedOppos.push(currentOppo['id'])
            preBuildCaoList.push(
                {
                    AV_Opportunity__c: currentOppo['id'],
                    AV_Task__c: this.createdEventId,
                    AV_IsMain__c: this.template.querySelector('[data-id="' + id + '"]').mainVinculed,
                    AV_OrigenApp__c: 'AV_SalesforceClientReport'
                }
            );
        }


        //**** AVP_ SE DEBERÍA SACAR ESTA LLAMADA A UN MÉTODO. 24/05/2024 */
        vinculateOpportunitiesWO({
            caosToInsert: preBuildCaoList,
            evtId: this.createdEventId
        })
            .then(result => {
                if (result == 'OK') {
                }

                if (this.newEvent['confidencial'] == true) {
                    //**** AVP_ SE DEBERÍA SACAR ESTA LLAMADA A UN MÉTODO. 24/05/2024 */
                    updateAccessList({ recordId: this.createdEventId })
                        .then((result => {

                        }))
                        .catch((error => {
                            console.log(error);
                        }))
                }


            }).catch(error => {
                console.log(error);
            });
    }

    vinculateTasks() {
        let preBuildRCList = [];
        let updatedOrCreatedTasks = [];
        for (let id in this.tareaObj) {
            let currentTarea = this.tareaObj[id];
            updatedOrCreatedTasks.push(currentTarea['id']);
            preBuildRCList.push(
                {
                    sobjectType: 'CIBE_RelaccionadoCita__c',
                    CIBE_TareaRelaccionada__c: currentTarea['headerId'],
                    CIBE_CitaRelaccionada__c: this.newEventHeaderId,
                    CIBE_IsMain__c: this.template.querySelector('[data-id="' + id + '"]').mainVinculed
                }
            );
        }

        //**** AVP_ SE DEBERÍA SACAR ESTA LLAMADA A UN MÉTODO. 24/05/2024 */
        vinculateTasksWO({
            rcToInsert: preBuildRCList
        })

            .then(result => {
                if (result == 'OK') {
                    console.log('result OK');
                }
                if (this.newEvent['confidencial'] == true) {
                    updateAccessList({ recordId: this.createdEventId })
                        .then((result => {

                        }))
                        .catch((error => {
                            console.log(error);
                        }))
                }


            }).catch(error => {
                console.log(error);
            });
    }

    finishReport() {

        if (this.buttonOrigin === 'cierreAltaCita') {
            this[NavigationMixin.Navigate]({
                type: 'standard__component',
                attributes: {
                    componentName: "c__cibe_NewEventParent"
                },
                state: {
                    c__recId: this.accountId,
                    c__id: this.currentPageReference.state.c__id
                }
            });
        } else {
            this[NavigationMixin.Navigate]({
                type: "standard__recordPage",
                attributes: {
                    recordId: this.accountId,
                    objectApiName: "Account",
                    actionName: "view"
                }
            });
        }

        setTimeout(() => {
            this.handleFinish();
            this.showSpinner = false;
        }, 3000)

    }

    createAttendes() {
        callApiTeams({ evt: this.newEventInserted, attendes: this.newEvent['attendes'], contactoPrincipal: this.newEvent['personaContacto'] })
            .then(result => {
                if (Object.keys(this.oppoObj).length !== 0) {
                    this.updateOrCreateOpportunities();
                    if (Object.keys(this.tareaObj).length !== 0) {
                        this.updateOrCreateTasks();
                    }
                }
                else if (Object.keys(this.tareaObj).length !== 0) {
                    this.updateOrCreateTasks();
                }

            }).catch(error => {
                this.deleteEventRegisters();

                console.log(error)
            })
    }


    //para oportunidades
    handleSelectionProduct() {
        this.evaluateProductToAdd();
    }

    showToast(title, message, variant) {
        var event = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
            mode: 'pester'
        });
        this.dispatchEvent(event);
    }


    cierreAltaCita(e) {
        this.buttonOrigin = 'cierreAltaCita';
        this.handleCreateEvent();
    }

    @track altaTarea = false;

    cierreAltaTarea(e) {
        this.altaTarea = true;
        this.handleCreateEvent(e);
    }

    handleStatusChange(event) {
        let objDetails = event.detail;
        if (objDetails.status === 'FINISHED_SCREEN' || objDetails.status === "FINISHED") {
            const selectedEvent = new CustomEvent("closetab");
            this.dispatchEvent(selectedEvent);
            this.showModal = false;
            this.launchFlow = false;
            this.showToast('', this.label.tareaCreada, 'success', 'pester');
        }
    }

    handleClose() {
        this.launchFlow = false;
        const selectedEvent = new CustomEvent("closetab");
        this.dispatchEvent(selectedEvent);
    }

    handleNewTask(event) {
        this.nameTask = event.target.value;
    }

    //nueva tarea
    handleAddTask() {
        const d = new Date(this.activityDateToSend);
        var dateStr = d.getUTCFullYear() + '-' + (d.getMonth() + 1) + '-' + d.getDate();
        if (this.nameTask != null) {
            this.taskNewList.push(
                {
                    id: IDPROVISIONAL + this.idProvisional++,
                    subject: this.nameTask,
                    activityDate: dateStr,
                    status: 'Pendiente',
                    accountId: this.accountId,
                    NotInserted: true,
                    isEditable: true,
                    headerId: '',
                    owner: this.newEvent['owner']
                }
            );
            getAccountTask({ accountId: this.accountId, eventHeader: this.newEventHeaderId })
                .then((result => {
                    this.listAccountTask = result;
                }))
                .catch((error => {
                    console.log(error);
                }))
        }
        this.nameTask = null;
    }


    validateRequiredInputsOpp() {
        let auxList = null;
        this.mensajeError = 'vacio';
        if (this.oppoNewList != null) {
            auxList = this.listAccountOpportunities.concat(this.oppoNewList);
        } else {
            auxList = this.listAccountOpportunities;
        }
        if (auxList == null) {
            return true
        } else {
            var hoyms = Date.now();
            const hoy = new Date(hoyms);
            hoy.setHours(0);
            hoy.setMinutes(0);
            hoy.setSeconds(0);
            var fechaMax = new Date(hoyms);
            fechaMax.setDate(fechaMax.getDate() + 547);

            auxList.forEach(opor => {
                if (this.oppoObj[opor.id] != undefined && this.oppoObj[opor.id]['isVinculed'] && this.mensajeError === 'vacio') {
                    const dfc = new Date(this.oppoObj[opor.id]['fechaCierre']);
                    dfc.setHours(0);
                    dfc.setMinutes(1);
                    const dfpg = new Date(this.oppoObj[opor.id]['fechaProxGest']);
                    dfpg.setHours(0);
                    dfpg.setMinutes(1);
                    var estado = this.oppoObj[opor.id]['newPath'];
                    if (estado != 'CIBE_Cerrado positivo' && estado != 'Cerrado negativo') {
                        if (this.mensajeError === 'vacio' && this.oppoObj[opor.id]['fechaProxGest'] == null) {
                            this.mensajeError = 'Es obligatorio informar el campo Fecha próxima gestión en la Oportunidad ' + opor.name;
                        }
                        if ((this.mensajeError === 'vacio' && this.oppoObj[opor.id]['fechaCierre'] == null)) {
                            this.mensajeError = 'Es obligatorio informar el campo Fecha cierre en la Oportunidad ' + opor.name;
                        }
                        if (this.mensajeError === 'vacio' && (dfc < hoy || dfc > fechaMax)) {
                            this.mensajeError = 'Introduzca una fecha de cierre no inferior desde la fecha actual o superior a 18 meses en la Oportunidad ' + opor.name;
                        }
                        if ((this.mensajeError === 'vacio' && (dfpg > dfc) || (dfpg < hoy))) {
                            this.mensajeError = 'La fecha de próxima gestión no puede ser superior a la fecha de cierre ni inferior a la fecha actual en la Oportunidad ' + opor.name;
                        }
                    }
                    if (this.mensajeError === 'vacio' && this.oppoObj[opor.id]['newPath'] == 'Cerrado negativo' && (this.oppoObj[opor.id]['state'] == null)) {
                        this.mensajeError = this.label.errorState + ' en la Oportunidad ' + opor.name;
                    }
                }
            })
        }
        if (this.mensajeError != 'vacio') {
            this.showToast('Error', this.mensajeError, 'Error');
            return false;
        } else {
            return true;
        }

    }

    // ----------------------------------AVP---------------------------------------

    renderComponent = false;
    createEventBasedOnEventType;

    /**
     * Se llamará desde el connectedCallBack a los controladores para recuperar la lista tanto de opp como de tareas del Account correspondiente.
     * además, en la variable this.recordId tendremos el id del registro desde el que se accede a este lwc.
     */
    connectedCallback() {
        //recuperamos las opportunidades de la account:
        this.getOpportunityByAccountId();
        //recuperamos las tareas de la account:
        this.getTaskByAccountId();
        //id opp desde la que se hizo click y la que hay que vincular.
    }

    /**
     * Recupera las opportunidades en función del accountId y llama al método getOpportunity()
     */

    getOpportunityByAccountId() {
        getAccountOpportunities({ accountId: this.accountId })
            .then((result => {
                this.listAccountOpportunities = result;
                this.listAccountOpportunities.sort((a, b) => a.closeDate.localeCompare(b.closeDate));
                let index = this.listAccountOpportunities.findIndex(opportunity => opportunity.id === this.recordId);
                if (index !== -1) {
                    // Eliminar el elemento de su posición actual
                    let [elementToMove] = this.listAccountOpportunities.splice(index, 1);
                    // Insertar el elemento al inicio del array
                    // this.listAccountOpportunities.unshift(elementToMove);
                }

                this.getOpportunity();
            }))
            .catch((error => {
                console.log(error);
            }))
    }

    /**
     * Genera una lista con la oportunidad desde la que se accede al lwc pasandole el recordId.
     * Esta lista se pasará al componente c-cibe_-new-event-opp-detail con la configuración correspondiente en el html para que pinte la opp como principal y 
     * con el botón insistir preseleccionado.
     * Si la lista contiene al menos un elemento se renderizará el componente poniendo al true la variable renderComponent
     */
    getOpportunity() {
        getOpp({ recordId: this.recordId })
            .then(result => {
                this.oppoNewList.push({
                    id: result[0].Id,
                    name: result[0].Name,
                    closeDate: result[0].CloseDate,
                    status: result[0].StageName,
                    accountId: result[0].AccountId,
                    owner: result[0].OwnerId,
                    proximaGestion: result[0].AV_FechaProximoRecordatorio__c,
                    comments: result[0].AV_Comentarios__c
                });
                this.oportunidadVin = true;
                if (this.oppoNewList !== null || this.oppoNewList !== undefined) {
                    this.renderComponent = true;
                }

            }).catch(error => {
                console.log(error);
            });
    }


    /**
     * Recuper la lista de tareas asociadas al accountId que se le pasa por parámetro.
     */
    getTaskByAccountId() {
        getAccountTask({ accountId: this.accountId })
            .then((result => {
                this.listAccountTask = result;
            }))
            .catch((error => {
                console.log(error);
            }))
    }

    setEventObject(e) {
        this.newEvent = e.detail;
        this.initialDuration = this.mapTypeDuration[this.newEvent['tipoCita']];
        //AVP_
        if (this.newEvent['tipoCita'] === 'ESE' || this.newEvent['tipoCita'] === '030' || this.newEvent['tipoCita'] === 'GSCC') {
            this.createEventBasedOnEventType = false;
        } else {
            this.createEventBasedOnEventType = true;
        }

        this.noOportunidades = this.newEvent['noOportunidades'];
        this.durationToSend = parseInt(this.initialDuration, 10);
        this.durationToCalendar = this.durationToSend;
        this.activityDateToCalendar = this.activityDateToSend;

        if (this.newEvent['owner'] == USER_ID) {
            this.overlapToCalendar = true;
        } else {
            this.overlapToCalendar = this.currentUserFunction != GESTOR;
        }
        if (this.employeeToCalendar != this.newEvent['owner'] && this.showCalendar) {
            this.employeeToCalendar = this.newEvent['owner'];
            if (this.calendarBoolean) {
                this.template.querySelector('[data-id="customcalendar"]').changeOwnerEvent(this.employeeToCalendar, this.overlapToCalendar);
            } else {
                this.template.querySelector('[data-id="customcalendarCompleto"]').changeOwnerEvent(this.employeeToCalendar, this.overlapToCalendar);
            }
        }
        this.employeeToCalendar = this.newEvent['owner'];

        if (this.newEvent['subject'] != undefined && this.subjectToCalendar != this.newEvent['subject']) {
            this.subjectToCalendar = this.newEvent['subject'];
        }
        let calendar = this.template.querySelector('[data-id="customcalendar"]');

        if (calendar != null) {
            let inittime = calendar.initTime;
            let finaltime = calendar.endTime;

            if (inittime != null && finaltime != null) {
                if (this.subjectToCalendar != undefined && this.subjectToCalendar != null) {
                    calendar.changeSubjectEvent(this.subjectToCalendar);
                } else if (this.newEvent['subject'] != undefined && this.newEvent['subject'] != null) {
                    calendar.changeSubjectEvent(this.newEvent['subject']);
                }
            }
        }

        this.noComercial = this.newEvent['nocomercial'];
        var iniDate = new Date(this.activityDateToSend + ' ' + this.timeInicio);
        iniDate.setHours(iniDate.getHours(), iniDate.getMinutes() + this.durationToSend, '00');
        this.timeFin = this.setHours(iniDate.getHours()) + ':' + this.setHours(iniDate.getMinutes());
        this.timeInfo = {
            date: this.formatDate(this.activityDateToSend),
            hourini: this.timeInicio,
            hourfin: this.timeFin,
            duration: this.mapDurationText[this.durationToSend]
        };
        this.showCalendar = true;
    }

    hideModalBox() {
        this.isShowModal = false;
    }

    palabrasProhibidas() {
        palabrasProhibidas({ oppoWrappedList: this.oppoObj, taskWrappedList: this.tareaObj, setFields: this.setFields, setFieldsTask: this.setFieldsTask })
            .then(result => {
                this.palabras = result;
                if (result == 'OK') {
                    this.handleCreateEvent();
                } else {
                    this.showToast('Error', this.palabras, 'Error');
                }

            }).catch(error => {
                console.log('palabrasProhibidas: ', error);
            })
    }

    /**
     * Borra la opp que le llega por parámetro del componente hijo y igual el contador de vinculadas al length de la lista de opp que hay creadas.
     * @param {*} event 
     */
    handleOppoDelete(event) {
        const oppoIdToDelete = event.detail;
        //comprueba si la oportunidad principal es igual que la que hay que borrar.
        if (this.oppPrincipal.oppoId === oppoIdToDelete) {
            this.oppPrincipal = null;
        }
        this.oppoNewList = this.oppoNewList.filter(opp => opp.id !== oppoIdToDelete);
        delete this.oppoObj[oppoIdToDelete];
        this.opposCount = Object.keys(this.oppoObj).length
    }

}