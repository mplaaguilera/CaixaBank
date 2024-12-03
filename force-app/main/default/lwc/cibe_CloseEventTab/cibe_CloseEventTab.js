import { LightningElement, api, wire, track } from 'lwc';
import { CurrentPageReference } from 'lightning/navigation';
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { RefreshEvent } from 'lightning/refresh';


import updateRecords from '@salesforce/apex/CIBE_Oportunidades_Vinculadas_Controller.updateRecords';
import updateEvents from '@salesforce/apex/CIBE_Oportunidades_Vinculadas_Controller.updateEvent';
import getRecords from '@salesforce/apex/CIBE_callReportController.getRecords';
import roleEmp from '@salesforce/apex/CIBE_Oportunidades_Vinculadas_Controller.roleEMP';
import getName from '@salesforce/apex/CIBE_Header_Controller.getAccountInfo';
import searchProduct from '@salesforce/apex/CIBE_NewEventController.searchProduct';
import getAccountOpportunitiesGC from '@salesforce/apex/CIBE_NewEventOppDetail_Controller.getOpportunitiesFromEventGC';
import getAccountTask from '@salesforce/apex/CIBE_NewEventTaskDetail_Controller.getAccountTask';
import getAccountTaskGC from '@salesforce/apex/CIBE_NewEventTaskDetail_Controller.getAccountTaskGCFromEvent';
import geCountRelatedOpp from '@salesforce/apex/CIBE_NewEventOppDetail_Controller.geCountRelated';
import createOrUpdateOpportunities from '@salesforce/apex/CIBE_NewEventController.createOrUpdateOpportunities';
import insertTask from '@salesforce/apex/CIBE_NewEventTaskDetail_Controller.insertTask';
import geTaskFromEvent from '@salesforce/apex/CIBE_NewEventTaskDetail_Controller.geTaskFromEvent';
import vinculateOpportunitiesWO from '@salesforce/apex/CIBE_NewEventControllerWO.vinculateOpposToTheNewEvent';
import palabrasProhibidas from '@salesforce/apex/CIBE_ForbiddenWords.validateRecords';

//flow
import getActions from '@salesforce/apex/CIBE_Oportunidades_Vinculadas_Controller.getActions';

//Labels
import paraReportar from '@salesforce/label/c.CIBE_ParaReportarCorrectamenteOportunidades';
import actualizarListado from '@salesforce/label/c.CIBE_ActualizarListadoOportunidadEvento';
import informarEstado from '@salesforce/label/c.CIBE_InformarEstadoDetalleOportunidades';
import conclusionesGestor from '@salesforce/label/c.CIBE_ConclusionesGestor';
import conclusionesCliente from '@salesforce/label/c.CIBE_ConclusionesCliente';
import proximosPasos from '@salesforce/label/c.CIBE_ProximosPasos';
import infoComplementariaGestor from '@salesforce/label/c.CIBE_InfoComplemetariaGestor';
import clienteEspana from '@salesforce/label/c.CIBE_ClienteEspana';
import clienteNuevo from '@salesforce/label/c.CIBE_ClienteNuevo';
import cerrarAltaEvento from '@salesforce/label/c.CIBE_cerrarYAltaEvento';
import cerrarAltaTarea from '@salesforce/label/c.CIBE_cerrarYAltaTarea';
import newOpportunity from '@salesforce/label/c.CIBE_New_Opportunity';
import createNewOpportunity from '@salesforce/label/c.CIBE_Create_Opportunity';
import comentario from '@salesforce/label/c.CIBE_Comentario';
import eventoFinalizado from '@salesforce/label/c.CIBE_EventoFinalizado';
import eventoSeCierraAutomaticamente from '@salesforce/label/c.CIBE_EventoSeCierraAutomaticamente';
import correcto from '@salesforce/label/c.CIBE_Correcto';
import error from '@salesforce/label/c.CIBE_Error';
import eventoExito from '@salesforce/label/c.CIBE_EventoCerradoConExito';
import errorActualizandoEvento from '@salesforce/label/c.CIBE_ErrorActualizandoEvento';
import categoriaAenor from '@salesforce/label/c.CIBE_CategoriaAenor';
import relacionCliente from '@salesforce/label/c.CIBE_RelacionCliente';
import tareaCreada from '@salesforce/label/c.CIBE_TareaCreada';
import citaCreada from '@salesforce/label/c.CIBE_CitaCreada';
import altaEvento from '@salesforce/label/c.CIBE_AltaEvento';
import altaTarea from '@salesforce/label/c.CIBE_AltaTarea';
import oportunidades from '@salesforce/label/c.CIBE_Oportunidades';
import vinculadas from '@salesforce/label/c.CIBE_Vinculadas';
import cita from '@salesforce/label/c.CIBE_Event';
import add from '@salesforce/label/c.CIBE_Add';
import addOpp from '@salesforce/label/c.CIBE_AddOpp';
import searhProduct from '@salesforce/label/c.CIBE_BuscarProductos';
import vincularTodasOpp from '@salesforce/label/c.CIBE_VincularTodasOportunidades';
import tareas from '@salesforce/label/c.CIBE_Tareas';
import faltanDatos from '@salesforce/label/c.CIBE_FaltanDatos';
import errorCP from '@salesforce/label/c.CIBE_ErrorCP';
import errorHI from '@salesforce/label/c.CIBE_ErrorHI';
import errorHF from '@salesforce/label/c.CIBE_ErrorHF';
import errorState from '@salesforce/label/c.CIBE_ErrorEstadoRelleno';
import cerrarCita from '@salesforce/label/c.CIBE_CerrarCitaEv';

//imports para la cabecera cibe_RecordForm:
import getClientInfo from '@salesforce/apex/CIBE_EditEvent_Controller.getInfoCliente';
import updateEvent from '@salesforce/apex/CIBE_EditEvent_Controller.updateEvent';
import { getFocusedTabInfo, closeTab, setTabLabel, IsConsoleNavigation } from 'lightning/platformWorkspaceApi';
import callApiTeams from '@salesforce/apex/CIBE_NewEventController.callApiTeams';


const GESTOR = 'Gestor';
const IDPROVISIONAL = 'idProvisional';
const SEPARATOR = '{|}';
const FIELDS = ['Account.Name'];
import USER_ID from '@salesforce/user/Id';

export default class Cibe_CloseEventTab extends NavigationMixin(LightningElement) {

    labels = {
        paraReportar,
        actualizarListado,
        informarEstado,
        comentario,
        eventoFinalizado,
        eventoSeCierraAutomaticamente,
        correcto,
        error,
        eventoExito,
        errorActualizandoEvento,
        conclusionesGestor,
        conclusionesCliente,
        proximosPasos,
        infoComplementariaGestor,
        clienteEspana,
        clienteNuevo,
        cerrarAltaEvento,
        cerrarAltaTarea,
        categoriaAenor,
        relacionCliente,
        newOpportunity,
        createNewOpportunity,
        tareaCreada,
        citaCreada,
        altaEvento,
        altaTarea,
        oportunidades,
        vinculadas,
        cita,
        add,
        addOpp,
        searhProduct,
        vincularTodasOpp,
        tareas,
        faltanDatos,
        errorCP,
        errorHI,
        errorHF,
        errorState,
        cerrarCita
    };

    @track opp = null;
    @api recordId;
    @track listUpdateValues = {};
    @api actionSetting = 'CIBE_Nueva_Tarea';
    @track flowlabel;
    @track flowName = 'CIBE_Nueva_Tarea';
    @track flowOutput;
    @track redirectId;
    @track objectAPIName;
    @track isShowFlowActionOpp = false;
    @track comment;
    @track antecedentes;
    @track conclusionGestor;
    @track conclusionCliente;
    @track proximosPasos;
    @track clienteNuevo = false;
    @track clienteEspaña = false;
    @track categoriaAenor;
    @track relacionCliente;
    @track accountId;
    inputVariables;
    @track name;
    @track recordType;
    @track isIntouch;
    @track nameRecord;
    @track account;
    @track oppPrincipal;

    showSpinner = false;
    saveButton = true;
    nextScreen = true;
    mensajeError = 'vacio';
    palabras = 'vacio';

    @track roleEmp = false;
    @track roleCib = false;
    @track nameTask;
    @track taskNewList = [];
    showTaskNewList = false;
    @track flowHeader = '';
    @track taskPrincipal;
    @track taskPrincipalId;

    //lmg valores de CIBE_NewEventTab
    opposCount = 0;
    @track buttonEnabled = true;
    @track buttonEnabledTask = true;
    listAccountOpportunities = [];
    newEventHeaderId;
    productToAdd = true;
    get tomorrow() {
        let msInADay = 24 * 60 * 60 * 1000;
        let msForTomorrow = (new Date().getTime()) + msInADay;
        return new Date(msForTomorrow).toJSON().slice(0, 10);
    }
    activityDateToSend = this.tomorrow;
    selectedProds = [];
    @track oppoList;
    @track oppoNewList = [];
    showOppNewList = false;
    idProvisional = 0;
    // potentialList;
    // Task
    listAccountTask = [];
    taskCount = 0;
    tareaObj = {};
    @track task;
    rcCheckOnOffBackUp;
    createdTasksIds = [];
    currentMainVinculedTask;
    oppoObj = {};
    checkOnOffTasksBackUp;
    caosCheckOnOffBackUp;
    taskAndOpposRel;
    createdOpposIds = [];
    newEvent;
    newEventInserted;
    initialDuration;
    isFuture = false;
    fechaEvento;
    setFields = ['Name', 'AV_Comentarios__c'];
    setFieldsTask = ['Subject', 'Description'];

    renderComponent = false;
    inforecord;
    changeEventUpdated;
    clickOrigin;
    @wire(IsConsoleNavigation) isConsoleNavigation;

    //PPM Grupos Comerciales
    mapAccountOppos = [];
    mapAccountTask = [];
    @track selectedIds;
    activeSections = ['A', 'B'];
    activeSectionsMessage = '';
    @track optionsClients = [];
    //cambio GC tareas
    mapAccountTask = [];
    @track valueClient;
    @track valueClientTask;

    infoByClientOppAndTasks;


    connectedCallback() {
        const selectedEvent = new CustomEvent("renametab");
        if (this.recordId) {
            this.geCountRelatedOpp();
            this.dispatchEvent(selectedEvent);
            this.getinfoclient();
        }
    }

    @wire(CurrentPageReference)
    currPage(pageRef) {
        if (pageRef.state && pageRef.state.c__recId) {
            this.recordId = pageRef.state.c__recId;
            this.currentPageReference = pageRef;
        } else if (pageRef.attributes && pageRef.attributes.recordId) {
            this.recordId = pageRef.attributes.recordId;
            this.currentPageReference = pageRef;
        }
    }



    @wire(getName, { recordId: '$recordId' })
    getNameData(wireResult) {
        let data = wireResult.data;
        let error = wireResult.error;
        this._wiredName = wireResult;

        if (data) {
            this.name = data[0];
            this.recordType = data[1];
            this.isIntouch = data[2];
            this.nameRecord = data[0];
            this.account = data[4];

        } else if (error) {
            console.log(error);
        }

    }

    async closeTab() {
        const { tabId } = await getFocusedTabInfo();
        await closeTab(tabId);
    }


    @track _wiredData;
    @wire(getRecords, { recordId: '$recordId' })
    wiredgetRecords(wiredData) {
        this._wiredData = wiredData;
        const { data, error } = wiredData;

        if (data) {
            if (data.ev) {
                this.comment = data.ev.Description;
                this.accountId = data.ev.AccountId;
            }
            if (this.accountId != undefined && this.accountId != null) {
                this.getAccountOpportunitiesGC();
                this.geTaskFromEvent();
            }
        } else if (error) {
            console.log(error);
        }
    }

    handleNewTask(event) {
        this.nameTask = event.target.value;
    }

    @wire(roleEmp)
    getRoleEmp({ data, error }) {
        if (data) {
            this.roleEmp = data;
        } else if (error) {
            console.log(error);
        }
    }

    async setTabLabel() {
        if (!this.isConsoleNavigation) {
            return;
        }
        const { tabId } = await getFocusedTabInfo();
        setTabLabel(tabId, 'Cerrar cita');
    }


    //nueva tarea
    handleAddTask() {
        if (this.nameTask != null && this.nameTask != '') {
            this.showSpinner = true;
            let clienteS = this.valueClientTask ? this.valueClientTask : this.inforecord.accountId;
            let clienteSelected = this.optionsClients.find(opt => opt.value === clienteS).label;
            var isMain = true;

            if (this.tareaObj != null) {
                for (let id in this.tareaObj) {
                    if (this.tareaObj[id]['mainVinculed']) {
                        isMain = false;
                    }
                }
            }

            let tareaToinsert = {
                id: IDPROVISIONAL + this.idProvisional++,
                subject: this.nameTask,
                Subject: this.nameTask,
                activityDate: this.activityDateToSend,
                ActivityDate: this.activityDateToSend,
                status: 'Pendiente',
                Status: 'Pendiente',
                accountId: this.accountId,
                WhatId: clienteS,
                isEditable: true,
                notInserted: true,
                headerId: '',
                isPrincipal: isMain,
                isVinculated: true,
                accountName: clienteSelected,
                isOwner: true,
                owner: USER_ID
            };

            let listToAdd = [];
            this.taskNewList.push(tareaToinsert);
            listToAdd.push(tareaToinsert);
            this.showTaskNewList = true;
            this.nameTask = null;
            insertTask({ record: listToAdd, recordId: this.recordId })
                .then((result => {
                    if (result == 'OK') {
                        this.geTaskFromEvent();
                        this.showToast(this.labels.correcto, 'Tarea insertada correctamente', 'success');
                        listToAdd = [];
                    } else {
                        this.showSpinner = false;
                        this.showToast('Error', 'Error al insertar la tarea', 'error');
                    }

                }))
                .catch((error => {
                    this.showSpinner = false;
                    this.showToast('Error', 'Error al insertar la tarea', 'error');
                    console.log(error);
                }))
        }
    }

    geTaskFromEvent() {
        geTaskFromEvent({ eventId: this.recordId })
            .then(result => {
                if (result) {
                    this.eventid = this.recordId;
                    this.listAccountTask = [];
                    this.taskCount = 0;
                    result.forEach(r => {
                        if (r.isVinculated) {
                            this.taskCount++;
                        }
                        if (r.isPrincipal) {
                            this.taskPrincipalId = r.id;
                        }
                    })
                    this.listAccountTask = result;
                    this.showSpinner = false;
                } else if (error) {
                    this.showSpinner = false;
                    console.log('error', error);
                }
            }).catch(error => {
                this.showSpinner = false;
                console.log('error ', error);

            })
    }

    updateOrCreateTasks() {
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

    enableSpinner() {
        this.showSpinner = true;
    }

    disableSpinner() {
        this.showSpinner = false;
    }

    handleDataAbuelo(event) {
        this.listUpdateValues[event.detail.id] = event.detail;
    }

    handleComment(event) {
        this.comment = event.target.value;
    }

    updateRecords2() {
        this.enableSpinner();

        if (this.listUpdateValues != null) {
            updateRecords({ listOppRecords: Object.values(this.listUpdateValues) })
                .then(result => {
                    this.getActions();
                })
                .catch(error => {
                    console.log(error);
                    this.showToast(this.labels.error, error.body.pageErrors[0].message, 'error', 'pester');
                    this.disableSpinner();
                });
        }
    }

    handleSave(origin) {
        this.enableSpinner();
        let auxList = null;
        let auxListV = [];
        if (this.oppoNewList != null) {
            auxList = this.listAccountOpportunities.concat(this.oppoNewList);
        } else {
            auxList = this.listAccountOpportunities;
        }

        if (auxList != null) {
            auxList.forEach(oppV => {
                if (oppV.isVinculated && oppV.isEditable) {
                    if (this.oppoObj.length !== 0) {
                        if (this.oppoObj[oppV.id]['newPath'] != 'CIBE_Vencido') {
                            oppV.status = this.oppoObj[oppV.id]['newPath'];
                        }
                        if (oppV.status != 'CIBE_Vencido') {
                            auxListV.push(oppV);
                        }
                    }
                }
            })

            var next = this.validateRequiredInputsOpp();

            if (next) {
                this.updateOrCreateOpportunities();
                updateRecords({ listOppRecords: Object.values(auxListV) })
                    .then(result => {
                        this.handleCreateEvent();
                    })
                    .catch(error => {
                        this.showToast(this.labels.error, error.body.pageErrors[0].message, 'error', 'pester');
                        this.disableSpinner();
                    });
            } else {
                this.disableSpinner();
                if (this.mensajeError != 'vacio') {
                    this.showToast('Error', this.mensajeError, 'Error');
                }
            }
        } else {
            this.handleCreateEvent();
        }
    }

    showToast(title, message, variant, mode) {
        const event = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
            mode: mode
        });
        this.dispatchEvent(event);
    }

    updateEvents() {
        updateEvents({ recordId: this.recordId })
            .then(result => {
                this.showToast(this.labels.correcto, this.labels.eventoExito, 'success', 'pester');

            })
            .catch(error => {
                console.log(error);
                this.showToast(this.labels.error, this.labels.errorActualizandoEvento, 'error', 'pester');
            }).finally(() => {
                this.disableSpinner();
                this.refresh();
            });
    }

    updateEventsCT() {
        updateEvents({ recordId: this.recordId })
            .then(result => {
            })
            .catch(error => {
                console.log('updateEventsCT', error);
                this.showToast(this.labels.error, this.labels.errorActualizandoEvento, 'error', 'pester');
            }).finally(() => {
                if (this.showSpinner) {
                    this.disableSpinner();
                }
                this.dispatchEvent(new RefreshEvent());
            });
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
            return true;
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
                        this.mensajeError = this.labels.errorState + ' en la Oportunidad ' + opor.name;
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
    getActions() {
        getActions({ actionSetting: this.actionSetting })
            .then(data => {
                this.flowlabel = data[0].label;
                this.flowName = data[0].name;
                this.flowOutput = data[0].output;
                this.redirectId = null;
                this.handleCreateEvent();
            }).catch(error => {
                console.log(error);
                this.showToast(this.labels.error, this.labels.errorActualizandoEvento, 'error', 'pester');
                this.disableSpinner();
            });
    }

    handleClickEvent(e) {
        this.clickOrigin = e.currentTarget.dataset.detail;
        this.palabrasProhibidas(e);
        if (this.mensajeError != 'vacio') {
            this.showToast('Error', this.mensajeError, 'Error');
        } else {
            this.handleCloseTab();
            this.navigateToTab('CIBE_PlanificarCita');
        }
    }

    navigateToTab(tabName) {
        this[NavigationMixin.Navigate]({
            type: 'standard__navItemPage',
            attributes: {
                // CustomTabs from managed packages are identified by their
                // namespace prefix followed by two underscores followed by the
                // developer name. E.g. 'namespace__TabName'
                apiName: tabName
            }, state: {
                c__recId: this.account,
                c__id: this.name,
                c__rt: this.recordType,
                c__intouch: this.isIntouch,
                c__account: this.account
            }
        });
    }

    handleStatusChange(event) {
        let objDetails = event.detail;
        if (objDetails.status === 'FINISHED_SCREEN' || objDetails.status === "FINISHED") {
            this.closeTab();
            this.showModal = false;
            this.launchFlow = false;
            if (this.actionSetting == 'CIBE_AltaDeEvento') {
                this.showToast('', this.labels.citaCreada, 'success', 'pester');
            } else if (this.actionSetting == 'CIBE_Nueva_Tarea') {
                this.showToast('', this.labels.tareaCreada, 'success', 'pester');
            }
            this.handleCreateEvent();
        }
    }

    handleStatusChangeOpp(event) {
        const status = event.detail.status;
        if (status === 'FINISHED_SCREEN' || status === "FINISHED") {
            this.isShowFlowActionOpp = false;
        }
    }

    handelCancelNewOpp() {
        this.isShowFlowActionOpp = false;
    }

    handleClickTarea(e) {
        this.clickOrigin = e.currentTarget.dataset.detail;
        this.enableSpinner();
        let next;
        let auxList = null;
        if (this.oppoNewList != null) {
            auxList = this.listAccountOpportunities.concat(this.oppoNewList);
        } else {
            auxList = this.listAccountOpportunities;
        }
        if (auxList != null) {
            next = this.validateRequiredInputsOpp();
        }

        if (this.mensajeError != 'vacio' || !next) {
            this.showToast('Error', this.mensajeError, 'Error');
        } else {

            this.inputVariables = [{
                name: 'recordId',
                type: 'String',
                value: this.accountId
            }];

            this.actionSetting = 'CIBE_Nueva_Tarea';
            this.launchFlow = true;
            this.getActions();
        }
    }

    handleComboBoxChange() {
        this.isShowFlowActionOpp = true;
        if (this.actionSetting != 'CIBE_New_Opportunity' && this.roleEmp) {
            this.actionSetting = 'CIBE_New_Opportunity';
        }
        else if (this.actionSetting != 'CIBE_New_Opportunity_CIB' && this.roleCib) {
            this.actionSetting = 'CIBE_New_Opportunity_CIB';
        }
        this.inputVariables = [{
            name: 'recordId',
            type: 'String',
            value: this.recordId
        }];
        this.flowlabel = this.labels.newOpportunity;
        this.flowName = this.actionSetting;
    }

    refresh() {
        this.geCountRelatedOpp();
    }

    handleClose() {
        this.launchFlow = false;
        this.updateRecords2();
        this.closeTab();
    }

    handleCloseTab() {
        this.launchFlow = false;
        this.handleCreateEvent();
        this.closeTab();
    }

    /************************************************LISTADO OPPOS*****************************************************************/

    vinculateAllOpp() {
        this.buttonEnabled = false;
        let auxList;
        if (this.oppoNewList != null) {
            auxList = this.listAccountOpportunities.concat(this.oppoNewList);
        } else {
            auxList = this.listAccountOpportunities;
        }
        this.auxList.forEach(opp => {
            let detailOppo = this.template.querySelector('[data-id="' + opp.id + '"]');
            detailOppo.handleVinculateAllOpp(opp.isPrincipal);
        })
    }

    desvincular() {
        this.buttonEnabled = true;
        let auxList;
        if (this.oppoNewList != null) {
            auxList = this.listAccountOpportunities.concat(this.oppoNewList);
        } else {
            auxList = this.listAccountOpportunities;
        }
        auxList.forEach(opp => {
            let detailOppo = this.template.querySelector('[data-id="' + opp.id + '"]');
            detailOppo.handleDesvincularOpp();
        })
    }

    //para oportunidades
    handleSearchProduct(e) {
        searchProduct({ searchTerm: e.detail.searchTerm, recordId: this.accountId })
            .then((results) => {
                this.template.querySelector('[data-id="newproductlookup"]').setSearchResults(results);
            })
            .catch((error) => {
                this.showToast('Lookup Error', 'An error occured while searching with the lookup field.', 'error');
                console.error('Lookup error', JSON.stringify(error));
                this.errors = [error];
            });
    }
    handleSelectionProduct() {
        this.evaluateProductToAdd();
    }
    evaluateProductToAdd() {
        this.productToAdd = this.template.querySelector("[data-id='newproductlookup']").getSelection().length == 0;
    }

    addDaysToDate = (date, n) => {
        const d = new Date(date);
        d.setDate(d.getDate() + n);
        return d.toISOString().split('T')[0];
    };

    //para oportunidades
    handleAddOppo() {
        let cmp = this.template.querySelector("[data-id='newproductlookup']");
        let selection = cmp.getSelection()[0];
        let clienteS = this.valueClient ? this.valueClient : this.inforecord.accountId;
        let clienteSelected = this.optionsClients.find(opt => opt.value === clienteS).label;
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
                    accountId: clienteS,
                    NotInserted: true,
                    isEditable: true,
                    proximaGestion: this.activityDateToSend,
                    fechaProxGest: this.activityDateToSend,
                    accountName: clienteSelected
                }
            );
            this.showOppNewList = true;
            if (this.oppoObj.length !== 0) {
                // this.palabrasProhibidas();

                this.updateOrCreateOpportunities();
            }
        }
        cmp.handleClearSelection();
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

    handleVinculationOpp(e) {
        (e.detail.sum) ? this.contadorOpp++ : this.contadorOpp--;
        let itemOppId = e.detail.oppoId;
        let auxList;
        if (this.listAccountOpportunities == undefined) {
            auxList = this.oppoNewList;
        } else {
            auxList = this.listAccountOpportunities.concat(this.oppoNewList);
        }

        var oppoDetail = this.template.querySelector('[data-id="' + itemOppId + '"]');
        if (e.detail.sum) {
            if (this.contadorOpp <= 1) {
                oppoDetail.mainVinculed = true;
            }
        } else {
            if (this.contadorOpp < 1) {
                oppoDetail.mainVinculed = false;
            } else {
                if (oppoDetail.mainVinculed) {
                    var cont = true;
                    auxList.forEach(opp => {
                        var oppoDetailToMain = this.template.querySelector('[data-id="' + opp.id + '"]');
                        if (opp.id != itemOppId && cont && oppoDetailToMain.vinculed) {
                            oppoDetailToMain.mainVinculed = true;
                            cont = false;
                        }
                    })
                    oppoDetail.mainVinculed = false;
                }
            }
        }
    }

    handleVinculationAll(e) {
        let itemOppId = e.detail.oppoId;
        this.opposCount = this.listAccountOpportunities.length;
        let auxList;
        if (this.listAccountOpportunities == undefined) {
            auxList = this.oppoNewList;
        } else {
            auxList = this.listAccountOpportunities.concat(this.oppoNewList);
        }

        if (this.oppPrincipal == null) {
            this.template.querySelector('[data-id="' + itemOppId + '"]').mainVinculed = true;
            this.currentMainVinculed = itemOppId;
            this.oppPrincipal = e.detail;
            this.oppPrincipal.main = true;
        } else {
            auxList.forEach(opp => {
                let oppoDetail = this.template.querySelector('[data-id="' + opp.id + '"]');
                if (this.oppPrincipal && opp.id !== this.oppPrincipal.oppoId) {
                    oppoDetail.mainVinculed = false;
                }
            })

            if (this.oppPrincipal && this.oppPrincipal.allCheck == false) {
                this.oppPrincipal = null;
                this.opposCount = 0;
            }

        }

        this.listAccountOpportunities.forEach(opp => {
            opp.isVinculated = true;

            if (this.oppPrincipal != null && opp.id === this.oppPrincipal.oppoId) {
                opp.isPrincipal = true;
            }
        })
    }


    desvincularTodas(e) {
        this.opposCount = 0;
        let itemOppId = e.detail.oppoId;
        let auxList;
        if (this.listAccountOpportunities != undefined && this.listAccountOpportunities != null) {
            auxList = this.listAccountOpportunities;
        }

        this.template.querySelector('[data-id="' + itemOppId + '"]').mainVinculed = false;
        this.oppPrincipal = null;
    }

    handleMainTask(e) {
        let itemTskd = e.detail.tareaId;
        this.currentMainVinculed = itemTskd;
        let auxList = this.listAccountTask;
        let tsksIds = this.listAccountTask.map(tsk => tsk.id);

        auxList.forEach(tsk => {
            if (tsk.isPrincipal) {
                tsk.isPrincipal = false;
                if(this.template.querySelector('[data-id="' + tsk.id + '"]')){
                    this.template.querySelector('[data-id="' + tsk.id + '"]').mainVinculed = false;
                }
                tsk.mainVinculed = false;
                if(this.tareaObj[tsk.id]){
                    this.tareaObj[tsk.id].mainVinculed = false;
                }
            }
            if(this.template.querySelector('[data-id="' + tsk.id + '"]')){
                this.template.querySelector('[data-id="' + tsk.id + '"]').mainVinculed = (tsk.id === itemTskd);
            }
            if (tsk.id === itemTskd && tsksIds.includes(itemTskd) && this.taskPrincipalId != undefined && tsk.id != this.taskPrincipalId) {
                tsk.mainVinculed = true;
                this.taskPrincipalId = tsk.id;
            }
        })
    }

    handleMainOpp(e) {
        let itemOppId = e.detail.oppoId;
        this.currentMainVinculed = itemOppId;
        let auxList;
        auxList = this.listAccountOpportunities;
        if (this.oppoNewList.length > 0) {
            auxList = auxList.concat(this.oppoNewList);

        }

        auxList.forEach(opp => {
            this.template.querySelector('[data-id="' + opp.id + '"]').mainVinculed = (opp.id === itemOppId);
            if (opp.id === itemOppId && Object.keys(this.oppoObj).includes(itemOppId)) {
                this.oppoObj[itemOppId]['mainVinculed'] = true;
            }
        })
    }

    @track contadorOpp;
    @track _wiredDataCountOpp

    geCountRelatedOpp() {

        geCountRelatedOpp({ eventId: this.recordId }).then(result => {
            if (result != null) {
                this.contadorOpp = result;
            } else if (error) {
                console.log(error);
            }
        }
        ).catch(error => {
            console.log(error)
        })
    }

    updateOrCreateOpportunities() {
        for (let oppo in this.oppoObj) {
            if ((oppo == this.opp['id']) && (this.oppoObj[oppo]['newPath'] != 'CIBE_Cerrado positivo' && this.oppoObj[oppo]['newPath'] != 'Cerrado negativo')) {
                this.oppoObj[oppo]['proximaGestion'] = this.opp['fechaProxGest'];
                this.oppoObj[oppo]['fechaProxGest'] = this.opp['fechaProxGest'];
                this.oppoObj[oppo]['fechaCierre'] = this.opp['fechaCierre'];
                this.oppoObj[oppo]['oppoDate'] = this.opp['fechaCierre'];
            }
        }

        createOrUpdateOpportunities({ opposToInsertOrUpdate: this.oppoObj, accountId: this.accountId, dateIni: this.dateIniFinal })
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
                }
            }).catch(error => {
                //BACKUP ATTENDES
                console.log(error);
            });
    }

    // vincula cuando crea opp desde el lookup
    vinculateOpportunities() {
        let preBuildCaoList = [];
        let updatedOrCreatedOppos = [];
        for (let id in this.oppoObj) {
            let currentOppo = this.oppoObj[id]
            updatedOrCreatedOppos.push(currentOppo['id']);
            preBuildCaoList.push(
                {
                    AV_Opportunity__c: currentOppo['id'],
                    AV_Task__c: this.recordId,
                    AV_IsMain__c: this.template.querySelector('[data-id="' + id + '"]').mainVinculed,
                    AV_OrigenApp__c: 'AV_SalesforceClientReport'
                }
            );
        }

        vinculateOpportunitiesWO({
            caosToInsert: preBuildCaoList,
            evtId: this.recordId
        })
            .then(result => {
                console.log(result);

            }).catch(error => {
                console.log(error);
            });
    }

    handleVinculationAllTask(e) {

        let itemTaskId = e.detail.tareaId;
        let onlyOneVinculedTask = (this.taskCount <= 1);
        let auxList;
        auxList = this.listAccountTask;

        if (this.taskPrincipal == null) {
            this.template.querySelector('[data-id="' + itemTaskId + '"]').mainVinculed = true;
            this.currentMainVinculedTask = itemTaskId;
            this.taskPrincipal = e.detail;
            this.taskPrincipal.main = true;
        } else {

            auxList.forEach(task => {
                let tareaDetail = this.template.querySelector('[data-id="' + task.id + '"]');
                if (this.taskPrincipal && task.id !== this.taskPrincipal.tareaId) {
                    tareaDetail.mainVinculed = onlyOneVinculedTask && e.detail.sum;
                }
            })

            if (this.taskPrincipal && this.taskPrincipal.allCheck == false) {
                this.taskPrincipal = null;
                this.taskCount = 0;
            }
        }

        this.listAccountTask.forEach(task => {
            task.isVinculated = true;

            if (this.taskPrincipal != null && task.id === this.taskPrincipal.tareaId) {
                task.isPrincipal = true;
            } else {
                task.isPrincipal = false;
            }
        })
    }

    desvincularTodasTask(e) {
        this.taskCount = 0;
        let itemTaskId = e.detail.tareaId;
        let auxList;
        auxList = this.listAccountTask;

        this.template.querySelector('[data-id="' + itemTaskId + '"]').mainVinculed = false;
        this.taskPrincipal = null;
    }

    // handleVinculation vinvula de una en una tarea
    handleVinculationTask(e) {
        let itemTskId = e.detail.tareaId;
        (e.detail.sum) ? this.taskCount++ : this.taskCount--;
        var tskDetail = this.template.querySelector('[data-id="' + itemTskId + '"]');

        if (e.detail.sum) {
            if (this.taskCount <= 1) {
                tskDetail.mainVinculed = true;
            }
        } else {
            if (this.taskCount < 1) {
                tskDetail.mainVinculed = false;
            } else {
                if (tskDetail.mainVinculed) {
                    var cont = true;
                    listAccountTask.forEach(tsk => {
                        var taskDetailToMain = this.template.querySelector('[data-id="' + tsk.id + '"]');
                        if (tsk.id != itemTskId && cont && taskDetailToMain.vinculed) {
                            taskDetailToMain.mainVinculed = true;
                            cont = false;
                        }
                    })
                    tskDetail.mainVinculed = false;
                }
            }
        }
    }
    /*****************************************************************************************************************/

    buildTaskObj(e) {
        let nextTask = (e.detail != null) ? e.detail : e;
        let id = (e.detail != null) ? e.detail.id : e.Id;
        let vinculed = (e.detail != null) ? e.detail.vinculed : e.vinculed;
        let main = (e.detail != null) ? e.detail.mainVinculed : e.mainVinculed;
        var taskDetailToMain = this.template.querySelector('[data-id="' + id + '"]');
        if (!main && this.taskPrincipalId == id) {
            e.detail.mainVinculed = true;
            taskDetailToMain.mainVinculed = true;
            main = true;
        }

        if (Object.keys(this.tareaObj).includes(id) && !vinculed) {
            delete this.tareaObj[id];
        } else if (vinculed) {
            this.tareaObj[id] = nextTask;
        }
        this.task = e.detail;
    }

    palabrasProhibidas(e) {
        this.enableSpinner();
        this.clickOrigin = e.currentTarget.dataset.detail;

        palabrasProhibidas({ oppoWrappedList: this.oppoObj, taskWrappedList: this.tareaObj, setFields: this.setFields, setFieldsTask: this.setFieldsTask })
            .then(result => {
                this.palabras = result;
                if (result == 'OK') {
                    this.handleSave(this.clickOrigin);
                } else {
                    this.showToast('Error', this.palabras, 'Error');
                }
            }).catch(error => {
                console.log('palabrasProhibidas: ', error);
            })
    }


    /**
     * Retrieve the data of the current event via the recordId.
     * When it has the event information, it sets the variable that allows the component to be rendered to true.
     */
    getinfoclient() {
        getClientInfo({ id: this.recordId })
            .then(result => {
                if (result) {
                    this.setTabLabel();
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
                        //description: result.ev.Description,
                        description: result.comentario,
                        contactType: result.ev.AV_Tipo__c,
                        startDateTime: this.checkDateTime(result.ev.StartDateTime),
                        endDateTime: result.ev.EndDateTime,
                        activityDate: result.ev.ActivityDate,
                        location: result.ev.Location,
                        confidencial: result.ev.CIBE_Confidential__c,
                        asistentesCBX: result.asistentesCBX,
                        asistentesEMP: result.asistentesEMP,
                        gruposComerciales: result.gruposComerciales
                    };
                    if (result.gruposComerciales) {
                        this.selectedIds = result.gruposComerciales.split(',');
                    }
                    if (this.selectedIds) {
                        this.getAccountOpportunitiesGC();
                        this.getAccountTask();
                        //this.geTaskFromEvent();


                    }

                    if (this.inforecord) {
                        this.renderComponent = true;
                    }
                }
            })
            .catch(error => {
                console.log('error -> ', error);
            });
    }

    /**
     * Change the appointment status to "Gestionada Positiva" by adding a field to the object that stores the current event information.
     * Call apex to update.
     */
    handleCreateEvent() {
        //cambia el estado a Gestionado Positiva para cerrar la cita.
        this.changeEventUpdated.ev.csbdEventoEstado = 'Gestionada Positiva';
        //this.
        this.eventToUpdate(this.changeEventUpdated);
    }

    /**
     * Close tab.
     */
    handleCancel() {
        this.closeTab();
    }

    /**
     * Saves each of the updates that are made to the child component of the event in the changeEventUpdated object
     */
    setEventObject(e) {
        this.changeEventUpdated = e.detail;
        let clientesSel = this.changeEventUpdated.ev.selectedClients;

        if (clientesSel && this.inforecord) {
            this.optionsClients = [];
            this.selectedIds = [];
            this.selectedIds.push(this.inforecord.accountId);
            this.optionsClients.push({ label: this.inforecord.name, value: this.inforecord.accountId });

            clientesSel.forEach(clie => {
                if (!this.selectedIds.includes(clie.id)) {
                    this.selectedIds.push(clie.id);
                    this.optionsClients.push({ label: clie.value, value: clie.id });
                }
            })

            if (this.selectedIds) {
                this.getAccountOpportunitiesGC();
                this.getAccountTask();
            }
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
     * Checks if the click comes from the close button to close the current tab and displays a message with the result. Finally, disable the screen spinner.
     * @param {*} evento 
     */
    eventToUpdate(evento) {
        updateEvent({ evtToUpdate: JSON.stringify(evento.ev) })
            .then(result => {
                if (result) {
                    if (evento.attendees.length > 0 || evento.ev.WhoId !== null) {
                        this.createAttendes(result[0], evento.attendees, evento.ev.WhoId);
                    }
                    this.showToast(this.labels.correcto, this.labels.eventoExito, 'success', 'pester');
                    //si la llamada viene el botón cerrar cita se cerrará la pestaña.
                    if (this.clickOrigin === 'cerrarCita') {
                        this.closeTab();
                    }
                } else {
                    this.showToast('Error actualizano el evento!', 'El evento no ha podido ser actualizado.', 'error');
                }
            })
            .catch(error => {
                if (this.clickOrigin === 'cerrarCita') {
                    console.log(error);
                    this.showToast(this.labels.error, this.labels.errorActualizandoEvento, 'error', 'pester');
                }
            })
            .finally(() => {
                this.disableSpinner();
                this.refresh();
            });
    }


    /**
     * Checks if the date passed by parameter is greater or less than the current time.
     * If it's greater, sets the date to the current time, and if it's less, retains the date provided.
     * @param {*} dateTime 
     * @returns correct dateTime
     */
    checkDateTime(dateTime) {
        var currentDateTime = new Date().toISOString();
        if (dateTime > currentDateTime) {
            dateTime = currentDateTime;
        }
        return dateTime;
    }

    /**
     * Borra la opp que le llega por parámetro del componente hijo y igual el contador de vinculadas al length de la lista de opp que hay creadas.
     * @param {*} event 
     */
    handleOppoDelete(event) {
        const oppoIdToDelete = event.detail;
        if (this.oppPrincipal && this.oppPrincipal.oppoId === oppoIdToDelete) {
            this.oppPrincipal = null;
        }
        this.oppoNewList = this.oppoNewList.filter(opp => opp.id !== oppoIdToDelete);
        delete this.oppoObj[oppoIdToDelete];
        this.contadorOpp = Object.keys(this.oppoObj).length
        if (this.oppoNewList.length === 0) {
            this.showOppNewList = false;
        }
    }

    //Cambios PPM añadir GC
    getAccountOpportunitiesGC() {
        getAccountOpportunitiesGC({ eventId: this.recordId, lstAccounts: this.selectedIds })
            .then(result => {
                this.listAccountOpportunities = result;
            })
            .catch(error => {
                console.log('error getAccountOpportunitiesGC: ' + JSON.stringify(error));
            })
    }

    getAccountTask() {
        getAccountTask({ lstAccounts: this.selectedIds })
            .then((result => {
                this.listAccountTask = result;
                this.getMapAccTask();
            }))
            .catch((error => {
                console.log(error);
            }))
    }


    getMapAccTask() {
        getAccountTaskGC({ eventId: this.recordId, lstAccounts: this.selectedIds })
            .then(result => {
                this.mapAccountTask = result;
                this.infoByClientOppAndTasks = this.mergeArrays(this.listAccountOpportunities, this.mapAccountTask)
            }).catch(error => {
                console.log(error);
            })
    }

    handleChangeClients(event) {
        this.valueClient = event.detail.value;
    }

    handleChangeClientsTask(event) {
        this.valueClientTask = event.detail.value;
    }

    handleSectionToggle(event) {
        const openSections = event.detail.openSections;

        if (openSections.length === 0) {
            this.activeSectionsMessage = 'All sections are closed';
        } else {
            this.activeSectionsMessage =
                'Open sections: ' + openSections.join(', ');
        }
    }

    mergeArrays(arr1, arr2) {
        const clienteMap = new Map();

        arr1.forEach(clienteObj => {
            const { cliente, lstOppWr } = clienteObj;
            if (!clienteMap.has(cliente)) {
                clienteMap.set(cliente, { cliente, twList: [], lstOppWr: [] });
            }
            clienteMap.get(cliente).lstOppWr.push(...lstOppWr);
        });

        arr2.forEach(clienteObj => {
            const { cliente, twList } = clienteObj;
            if (!clienteMap.has(cliente)) {
                clienteMap.set(cliente, { cliente, twList: [], lstOppWr: [] });
            }
            clienteMap.get(cliente).twList.push(...twList);
        });

        return Array.from(clienteMap.values());
    }
}