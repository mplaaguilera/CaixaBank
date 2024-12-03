import { LightningElement, wire, api, track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { RefreshEvent } from 'lightning/refresh';
import USER_ID from "@salesforce/user/Id";

// Import labels
import oportunidades from '@salesforce/label/c.CIBE_Oportunidades';
import vinculadas from '@salesforce/label/c.CIBE_Vinculadas';
import searhProduct from '@salesforce/label/c.CIBE_BuscarProductos';
import addOpp from '@salesforce/label/c.CIBE_AddOpp';
import cita from '@salesforce/label/c.CIBE_Event';
import add from '@salesforce/label/c.CIBE_Add';
import tareas from '@salesforce/label/c.CIBE_Tareas';
import correcto from '@salesforce/label/c.CIBE_Correcto';


//Import Apex
import searchProduct from '@salesforce/apex/CIBE_NewEventController.searchProduct';
import createOrUpdateOpportunities from '@salesforce/apex/CIBE_NewEventController.createOrUpdateOpportunities';
import getAccountOpportunitiesGC from '@salesforce/apex/CIBE_NewEventOppDetail_Controller.getOpportunitiesFromEventGC';
import getGrupoComercial from '@salesforce/apex/CIBE_NewEventController.getGrupoComercial';
import getClientInfo from '@salesforce/apex/CIBE_EditEvent_Controller.getInfoCliente';
import updateEventGC from '@salesforce/apex/CIBE_NewEventController.updateEventGC';

import getAccountTaskGC from '@salesforce/apex/CIBE_NewEventTaskDetail_Controller.getAccountTaskGCFromEvent';
import getAccountTask from '@salesforce/apex/CIBE_NewEventTaskDetail_Controller.getAccountTask';
import insertTask from '@salesforce/apex/CIBE_NewEventTaskDetail_Controller.insertTask';
import vinculateOpportunitiesWO from '@salesforce/apex/CIBE_NewEventControllerWO.vinculateOpposToTheNewEvent';
import geCountRelatedOpp from '@salesforce/apex/CIBE_NewEventOppDetail_Controller.geCountRelated';
import geTaskFromEvent from '@salesforce/apex/CIBE_NewEventTaskDetail_Controller.geTaskFromEvent';
import palabrasProhibidas from '@salesforce/apex/CIBE_ForbiddenWords.validateRecords';


const IDPROVISIONAL = 'idProvisional';
const FIELDS = ['Account.Name'];

export default class Cibe_EditEventsRelatedObject extends NavigationMixin(LightningElement) {
    labels = {
        oportunidades,
        vinculadas,
        cita,
        add,
        addOpp,
        searhProduct,
        tareas,
        correcto
    };

// Variables Generales
    @api recordId;
    isEventFuture = false;
    hasGC = false;
    renderComponent = false;
    inforecord;
    activityDateToSend;
    idProvisional = 0;
    dateStr;
    idInsert = 0;
    isInsert = false;
    showOppNewList = false;
	showTaskNewList = false;
    infoByClientOppAndTasks;
    userId = USER_ID;

    

    //PPM Grupos Comerciales
    mapAccountOppos = [];
    mapAccountTask = [];
    activeSections = ['A','B'];
    activeSectionsMessage = '';
    @track optionsClients = [];
    @track valueClient;
    @track valueClientTask;
    selectedIds = [];
    @track empresaGr = false;
    @track optionsGC;
    @track empresaGCSel;
    @track selectedClientsGC = [];

    // Variables Oportunidad
        @track contadorOpp;
        productToAdd = true;
        selectedProds = [];
        @track oppoNewList = [];
        listAccountOpportunities = [];
        oppoObj = {};
        checkOnOffTasksBackUp;
        caosCheckOnOffBackUp;
        taskAndOpposRel;
        createdOpposIds = [];
        oportunidadVin = false;
        mapOpposIds = [];
        currentMainVinculed;
    //Variables Tarea
        listAccountTask = [];
        taskCount = 0;
        tareaObj = {};
        @track task;
        rcCheckOnOffBackUp;
        createdTasksIds = [];
        currentMainVinculedTask;
        @track nameTask;
        @track taskNewList = [];


        connectedCallback(){
                if(this.recordId){
                    this.getinfoclient();
                    this.geCountRelatedOpp();
                    this.geTaskFromEvent();
                }
        }

    // fun Product Opp
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

    handleAddOppo() {
        let cmp = this.template.querySelector("[data-id='newproductlookup']");
        let selection = cmp.getSelection()[0];
        let clienteS = this.valueClient? this.valueClient: this.inforecord.accountId;
        this.valueClient = clienteS;
        let clienteSelected = this.optionsClients.find(opt => opt.value === clienteS).label;

        const d = new Date(this.activityDateToSend);
		d.setDate(d.getDate() + 7);
		this.dateStr = d.getUTCFullYear() + '-' + (d.getMonth() + 1) + '-' + d.getDate();

        if (selection) {
            this.oppoNewList.push(
                {
                    id: IDPROVISIONAL + this.idProvisional++,
                    name: selection.title,
                    closeDate: this.dateStr,
                    status: 'En curso',
                    productId: selection.id,
                    accountId: clienteS,
                    accountName: clienteSelected,
                    NotInserted: true,
                    isEditable: true,
                    isVinculated:false,
                    isVinculed:false,
                    proximaGestion: this.activityDateToSend,
                    fechaProxGest: this.activityDateToSend,
                    owner: this.userId
                }
            );

            this.showOppNewList = true;
        }
        cmp.handleClearSelection();
    }

    updateOrCreateOpportunities() {
        for (let oppo in this.oppoObj) {
            if ((oppo == this.opp['id']) && (this.oppoObj[oppo]['newPath'] != 'CIBE_Cerrado positivo' && this.oppoObj[oppo]['newPath'] != 'Cerrado negativo')) {
                this.oppoObj[oppo]['proximaGestion'] = this.opp['fechaProxGest'];
                this.oppoObj[oppo]['fechaProxGest'] = this.opp['fechaProxGest'];
                this.oppoObj[oppo]['fechaCierre'] = this.opp['fechaCierre'];
                this.oppoObj[oppo]['oppoDate'] = this.opp['fechaCierre'];
                // this.oppoObj[oppo]['accountId'] = this.valueClient;
            }
        }

        createOrUpdateOpportunities({ opposToInsertOrUpdate: this.oppoObj, accountId: this.valueClient})
            .then(result => {
                if (result.errorList == null) {
                    this.oppoObj = result.editedOpportunities;
                    this.checkOnOffTasksBackUp = result.taskToRestoreBack;
                    this.caosCheckOnOffBackUp = result.caoToRestoreBack;
                    this.taskAndOpposRel = result.taskOpposRelation;

                    for (let oppo in this.oppoObj) {
                        if (oppo.includes(IDPROVISIONAL) && !this.createdOpposIds.includes(this.oppoObj[oppo]['id'])) {
                            this.createdOpposIds.push(this.oppoObj[oppo]['id']);
                        }

                        if (oppo.includes(IDPROVISIONAL) &&  !this.mapOpposIds.includes(oppo) && !this.oppoObj[oppo]['id'].includes(IDPROVISIONAL) ){
                            this.mapOpposIds.push({key:oppo , value: this.oppoObj[oppo]['id']});
                        }
                    }

                    // if(this.isInsert == true){
                        this.vinculateOpportunities();
                    //     this.isInsert = false;
                    // }

                } else {
                    result.errorList.forEach(err => {
                        console.log(err);
                    })
                }
            }).catch(error => {
                console.log(error);
            });
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
            this.contadorOpp = Object.keys(this.oppoObj).length;
        }

        // vincula cuando crea opp desde el lookup
        vinculateOpportunities() {
            let preBuildCaoList = [];
            let updatedOrCreatedOppos = [];

            for (let id in this.oppoObj) {
                let currentOppo = this.oppoObj[id];
                updatedOrCreatedOppos.push(currentOppo['id']);

                preBuildCaoList.push(
                    {
                        AV_Opportunity__c: currentOppo['id'],
                        AV_Task__c: this.recordId,
                        // AV_IsMain__c: this.template.querySelector('[data-id="' + id + '"]').mainVinculed,
                        AV_IsMain__c:  this.oppoObj[id]['mainVinculed'],
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

    //Clinete GC
	handleChangeClients(event) {
		this.valueClient = event.detail.value;
	}

	handleChangeClientsTask(event) {
        this.valueClientTask = event.detail.value;
    }
    
    handleRemoveAttendeGC(e) {
		let idToDel = e.target.name;
		this.clienteGCName = '';
        let grupocomercial = '';

		for (let i = 0; i < this.selectedClientsGC.length; i++) {
			if (this.selectedClientsGC[i].id === idToDel) {
				this.selectedClientsGC.splice(i, 1);
                this.selectedIds.splice(i, 1);
				break;
			}
			if (i == this.selectedClientsGC.length - 1) {
				this.clienteGCName = this.clienteGCName + this.selectedClientsGC[i].label;
			} else {
				this.clienteGCName = this.clienteGCName + this.selectedClientsGC[i].label + ', ';
			}
		}
		for (let i = 0; i < this.optionsClients.length; i++) {
			if (this.optionsClients[i].value === idToDel) {
				this.optionsClients.splice(i, 1);
				break;
			}
        }

        for (let i = 0; i < this.selectedIds.length; i++) {
			if (this.selectedIds[i] === idToDel) {
				this.selectedIds.splice(i, 1);
				break;
			}
        }

        if(this.selectedIds){
            this.selectedIds.forEach(sel => {
                if(grupocomercial){
                    grupocomercial = grupocomercial+','+ sel;
                }else{
                    grupocomercial = sel;
                }
			})
        }

        updateEventGC({ evento: this.recordId, gruposComerciales: grupocomercial });
        if(this.selectedIds){
            this.getAccountOpportunitiesGC();
            this.getAccountTask();                
        }    
	}

    getAccountTask(){
        getAccountTask({ lstAccounts: this.selectedIds })
        .then((result => {
            this.listAccountTask = result;
            this.getMapAccTask();
        }))
        .catch((error => {
            console.log(error);
        }))
    }
    

    getMapAccTask(){
		getAccountTaskGC({eventId: this.recordId, lstAccounts: this.selectedIds})
		.then(result => {
			this.mapAccountTask = result;
            this.infoByClientOppAndTasks = this.mergeArrays(this.listAccountOpportunities, this.mapAccountTask)
		}).catch(error => {
			console.log(error);
		})
	}

        //Cambios PPM añadir GC
        getAccountOpportunitiesGC(){
            getAccountOpportunitiesGC({ eventId: this.recordId, lstAccounts: this.selectedIds })
            .then(result => {
                this.listAccountOpportunities = result;    
            })
            .catch(error => {
                console.log('error getAccountOpportunitiesGC: '+JSON.stringify(error));
            })
        }
    
    //se construye el listado de objeto de opp
    buildOppoObj(e) {
        let nextOppo = (e.detail != null) ? e.detail : e;
        let id = (e.detail != null) ? e.detail.id : e.Id;
        let vinculed = (e.detail != null) ? e.detail.isVinculed : e.isVinculed;
        this.opp = e.detail;

        if (Object.keys(this.oppoObj).includes(id) && !vinculed) {
            delete this.oppoObj[id];
        } else if (vinculed && this.opp.id.includes(IDPROVISIONAL) && id != this.idInsert) {
                this.oppoObj[id] = nextOppo;
                this.idInsert = id;
                this.isInsert = true;
                this.updateOrCreateOpportunities();
        }else if (vinculed && this.opp.id.includes(IDPROVISIONAL) && id == this.idInsert) {
                this.oppoObj[id] = nextOppo;
                if(this.mapOpposIds){
                    this.oppoObj[id]['id'] = this.mapOpposIds.find(opt => opt.key === id).value;
                }
                this.updateOrCreateOpportunities();
        }
        
    }

    //vinculada
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

    // principal
    handleMainOpp(e) {
        let itemOppId = e.detail.oppoId;
        this.currentMainVinculed = itemOppId;
        let auxList;
        auxList = this.listAccountOpportunities;
        if (this.oppoNewList.length > 0) {
            auxList = auxList.concat(this.oppoNewList);
        }

        auxList.forEach(opp => {
            // this.template.querySelector('[data-id="' + opp.id + '"]').mainVinculed = (opp.id === itemOppId);
            if (opp.id === itemOppId && Object.keys(this.oppoObj).includes(itemOppId)) {
                this.oppoObj[itemOppId]['mainVinculed'] = true;
            }
        })
    }

    // validacion opp  
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

    handleSectionToggle(event) {
        const openSections = event.detail.openSections;
        if (openSections.length === 0) {
            this.activeSectionsMessage = 'All sections are closed';
        } else {
            this.activeSectionsMessage =
                'Open sections: ' + openSections.join(', ');
        }
    }

    handleEmpresaGrupo(event) {
		this.empresaGr = event.target.checked;
	}

    handleChangeGC(event) {
		let labelClienteSelecionado;
		let idClienteSelecionado;
        let grupocomercial;
		this.empresaGCSel = event.detail.value;

		labelClienteSelecionado = this.optionsGC.find(opt => opt.value === event.detail.value).label;
		idClienteSelecionado = this.optionsGC.find(opt => opt.value === event.detail.value).value;

		if (idClienteSelecionado === 'todosClientes') {
			this.selectedClientsGC = [];
            this.selectedIds = [];
            this.optionsClients = [];

            this.selectedIds.push(this.inforecord.accountId);
			this.selectedClientsGC.push({ id: this.inforecord.accountId, value: this.inforecord.name });
            this.optionsClients.push({label:this.inforecord.name, value:this.inforecord.accountId});

			this.optionsGC.forEach(opt => {
				if (opt.value !== idClienteSelecionado) {
					this.selectedClientsGC.push({ id: opt.value, value: opt.label });
                    this.optionsClients.push({label:opt.label, value:opt.value});
					this.selectedIds.push(opt.value);
				}
			})
		} else {
			this.selectedClientsGC.push({ id: idClienteSelecionado, value: labelClienteSelecionado });
			this.selectedIds.push(idClienteSelecionado);
            this.optionsClients.push({label:labelClienteSelecionado, value:idClienteSelecionado});

		}

        if(this.selectedClientsGC){
            this.selectedIds.forEach(sel => {
                if(grupocomercial){
                    grupocomercial = grupocomercial+','+ sel;
                }else{
                    grupocomercial = sel;
                }
			})

            updateEventGC({ evento: this.recordId, gruposComerciales: grupocomercial });
        }
        if(this.selectedIds){
            this.getAccountOpportunitiesGC();
            this.getAccountTask();                
        }   
	}

    @track _wiredData;
	@wire(getGrupoComercial, { recordId: '$inforecord.accountId' })
	getGrupoComercial(wiredData) {
		//GC
		this._wiredData = wiredData;
		const { data, error } = wiredData;
		let optionsAux = [];

		if (data) {
			optionsAux.push({ label: 'TODOS LOS CLIENTES', value: 'todosClientes' });
			this.data = data.map((item) => {
				const iconObj = { ...item };
				optionsAux.push({ label: item.subtitle, value: item.icon.replace('/', '') });
				return iconObj;
			});

			this.optionsGC = optionsAux;
            this.getGC();
			this.isLoading = false;

		} else if (error) {
			this.isLoading = false;
			console.log(error);
		} else {
			this.isLoading = false;
		}
	}

    getGC() {
        this.selectedClientsGC = [];
        let arrayGC;
        let cont = 0;
        if(this.inforecord.gruposComerciales){
            arrayGC = this.inforecord.gruposComerciales.split(',');
        }
        if(arrayGC){
            arrayGC.forEach(gc => {
                cont++;
                if(this.optionsGC){
                    this.optionsGC.forEach(opt => {
                        if(opt != undefined){
                            if(opt.value === gc){
                                this.selectedClientsGC.push({ id: opt.value, value: opt.label });
                                this.optionsClients.push({label:opt.label, value:opt.value});
                                this.selectedIds.push(this.inforecord.accountId);
                            }
                        }
                    })
                }
            })
        }
        if(cont > 1){
            this.empresaGr = true;
        }
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
                        accountId: result.ev.Account.Id,
                        subject: result.ev.Subject,
                        startDateTime: result.ev.StartDateTime,
                        endDateTime: result.ev.EndDateTime,
                        activityDate: result.ev.ActivityDate,
                        gruposComerciales: result.gruposComerciales
                    };
                    if(this.inforecord.accountId){
                        this.valueClient = this.inforecord.accountId;
                        this.valueClientTask = this.inforecord.accountId;
                        this.optionsClients.push({label:this.inforecord.name, value:this.inforecord.accountId});

                    }
                    if(result.gruposComerciales){
                        var currentDateTime = new Date().toISOString();
                        if (this.inforecord.startDateTime > currentDateTime) {
                            this.isEventFuture = true;
                        }
                    }
                    if(result.gruposComerciales){
                        this.selectedIds = result.gruposComerciales.split(',');
                        //LMG
                    }

                    if(this.inforecord.activityDate){
                        this.activityDateToSend = this.inforecord.activityDate;
                    }

                    if(this.selectedIds){
                        this.renderComponent = true;
                        this.getAccountOpportunitiesGC();
                        this.getAccountTask();
                    }else{
                        this.selectedIds = this.inforecord.accountId;
                        this.renderComponent = true;
                        this.getAccountOpportunitiesGC();
                        this.getAccountTask();
                    }
                }
            })
            .catch(error => {
                console.log('error -> ', error);
            });
    }
    //TAREAS
    handleNewTask(event) {
        this.nameTask = event.target.value;
    }
        //nueva tarea
        handleAddTask() {
            if (this.nameTask != null && this.nameTask != '') {
                let clienteS = this.valueClientTask? this.valueClientTask: this.inforecord.accountId;
                this.showSpinner = true;
                let clienteSelected = this.optionsClients.find(opt => opt.value === clienteS).label;

                const d = new Date(this.activityDateToSend);
                var dateStr = d.getUTCFullYear() + '-' + (d.getMonth() + 1) + '-' + d.getDate();
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
                    // activityDate: dateStr,
                    // ActivityDate: dateStr,
                    activityDate: this.activityDateToSend,
                    ActivityDate: this.activityDateToSend,
                    status: 'Pendiente',
                    Status: 'Pendiente',
                    accountId: clienteS,
                    WhatId: clienteS,
                    notInserted: true,
                    isEditable: true,
                    headerId: '',
                    isPrincipal: isMain,
                    isVinculated: true,
                    accountName: clienteSelected,
                    isOwner: true
                };
    
                let listToAdd = [];
                this.taskNewList.push(tareaToinsert);
                listToAdd.push(tareaToinsert);

                this.showTaskNewList = true;
                this.nameTask = null;
                insertTask({ record: listToAdd, recordId: this.recordId })
                    .then((result => {
                        if (result == 'OK') {
                            // this.geTaskFromEvent();
                            this.showToast(this.labels.correcto, 'Tarea insertada correctamente', 'success');
                        } else {
                            this.showSpinner = false;
                            this.showToast('Error', 'Error al insertar la tarea', 'error');
                            this.taskNewList = [];
                        }
    
                    }))
                    .catch((error => {
                        this.showSpinner = false;
                        this.showToast('Error', 'Error al insertar la tarea', 'error');
                        console.log(error);
                    }))
            }
        }


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
                        console.log(error);
                    }
                }).catch(error => {
                    this.showSpinner = false;
                    console.log(error);
                })
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
    
    //c/fusion lista tareas y Opp
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

    handleMainTask(e) {
		let itemTaskId = e.detail.tareaId;
		this.currentMainVinculedTask = itemTaskId;

		this.listAccountTask.forEach(task => {
                if(this.template.querySelector('[data-id="' + task.id + '"]')){
                    this.template.querySelector('[data-id="' + task.id + '"]').mainVinculed = (task.id === itemTaskId);
                }
			task.isPrincipal = (task.id === itemTaskId);
			if (task.id === itemTaskId && Object.keys(this.tareaObj).includes(itemTaskId)) {
				this.taskPrincipal = {
					sum: true,
					tareaId: itemTaskId
				};
                this.tareaObj[task.id]['mainVinculed'] = true;
                
			} else if (task.id !== itemTaskId && Object.keys(this.tareaObj).includes(task.id) && this.tareaObj[task.id]['mainVinculed']) {
				this.tareaObj[task.id]['mainVinculed'] = false;
			}
		})

		this.taskNewList.forEach(task => {
            if(this.template.querySelector('[data-id="' + task.id + '"]')){
                this.template.querySelector('[data-id="' + task.id + '"]').mainVinculed = (task.id === itemTaskId);
            }
            task.isPrincipal = (task.id === itemTaskId);
			if (task.id === itemTaskId && Object.keys(this.tareaObj).includes(itemTaskId)) {
				this.tareaObj[itemTaskId]['mainVinculed'] = true;
				this.taskPrincipal = {
					sum: true,
					tareaId: itemTaskId
				};
			} else if (task.id !== itemTaskId && Object.keys(this.tareaObj).includes(task.id) && this.tareaObj[task.id]['mainVinculed']) {
				this.tareaObj[task.id]['mainVinculed'] = false;
			}
		})
	}
    refreshDatatask(){
		this.geTaskFromEvent();
	}

}//fin clase