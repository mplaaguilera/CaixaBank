import { LightningElement, api, wire,track } from 'lwc';
import { CurrentPageReference  } from 'lightning/navigation';
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent }   from 'lightning/platformShowToastEvent';
import { refreshApex } from '@salesforce/apex';


import updateRecords        from '@salesforce/apex/CIBE_Oportunidades_Vinculadas_Controller.updateRecords';
import updateEvents         from '@salesforce/apex/CIBE_Oportunidades_Vinculadas_Controller.updateEvent';
import getRecords           from '@salesforce/apex/CIBE_callReportController.getRecords';
import roleEmp             from '@salesforce/apex/CIBE_Oportunidades_Vinculadas_Controller.roleEMP';
import roleCib             from '@salesforce/apex/CIBE_Oportunidades_Vinculadas_Controller.roleCIB';


//flow
import getActions   from '@salesforce/apex/CIBE_Oportunidades_Vinculadas_Controller.getActions';

//Labels
import paraReportar from '@salesforce/label/c.CIBE_ParaReportarCorrectamenteOportunidades';
import actualizarListado from '@salesforce/label/c.CIBE_ActualizarListadoOportunidadEvento';
import informarEstado from '@salesforce/label/c.CIBE_InformarEstadoDetalleOportunidades';
import grabarReporte from '@salesforce/label/c.CIBE_GrabarReporte';
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



export default class Cibe_CloseEventTab  extends NavigationMixin (LightningElement) {

    labels = {
        paraReportar, 
        actualizarListado,
        informarEstado,
        grabarReporte,
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
        altaTarea
    };

    @api recordId;
    @track listUpdateValues ={};
    @api actionSetting = 'CIBE_AltaDeEvento';
    @track flowlabel;
    @track flowName;
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

    showSpinner = false;
    saveButton = true;

    @track roleEmp = false;
    @track roleCib = false;



    @wire(CurrentPageReference)
    setCurrentPageReference(currentPageReference) {
        this.currentPageReference = currentPageReference;
        console.log(this.currentPageReference);
    }

    @track _wiredData;
    @wire(getRecords, { recordId : '$recordId'})
	wiredgetRecords(wiredData) {
        this._wiredData = wiredData;
        const {data, error} = wiredData;
        
        if(data){
            console.log('data ' + JSON.stringify(data));
            if(data.activityExtension) {
                this.clienteNuevo = data.activityExtension.CIBE_ClienteNuevo__c;
                this.clienteEspaña = data.activityExtension.CIBE_ClienteEspana__c;
                this.antecedentes = data.activityExtension.CIBE_InformacionComplementariaGestor__c;
                this.conclusionGestor = data.activityExtension.CIBE_ConclusionesGestor__c;
                this.conclusionCliente = data.activityExtension.CIBE_ConclusionesCliente__c;
                this.proximosPasos = data.activityExtension.CIBE_ProximosPasosCliente__c;
                this.categoriaAenor = data.activityExtension.CIBE_CategoriaAenor__c;
                this.relacionCliente = data.activityExtension.CIBE_RelacionCliente__c;
            }
            if(data.ev) {
                this.comment = data.ev.Description;
                this.accountId = data.ev.AccountId;
            }
        }else if(error){
            console.log(error);
        }
    }

    @wire(roleEmp)
	getRoleEmp({data, error}) {
        if(data) {
            this.roleEmp = data;
		} else if(error) {
			console.log(error);
		}
    }

    @wire(roleCib)
    getRoleCib({data, error}) {
        if(data) {
            this.roleCib = data;
        } else if(error) {
            console.log(error);
        }
    }


  
    

    connectedCallback(){
        this.recordId = this.currentPageReference.state.c__recId;
        const selectedEvent = new CustomEvent("renametab");
		this.dispatchEvent(selectedEvent);
    }

    enableSpinner() {
        this.showSpinner = true;
    }

    disableSpinner() {
        this.showSpinner = false;
    }
    
    handleDataAbuelo(event){
        this.listUpdateValues[event.detail.id]=event.detail; 
    }

    handleComment (event) {
        this.comment = event.target.value;    
    }

    handleClienteNuevo(event){
        this.clienteNuevo = event.target.checked;
    }

    handleClienteEspana(event){
        this.clienteEspaña = event.target.checked;
    }

    handleAntecedentes(event){
        this.antecedentes = event.target.value;
    }

    handleConclusionesGestor(event){
        this.conclusionGestor = event.target.value;
    }

    handleConclusionesCliente(event){
        this.conclusionCliente = event.target.value;
    }

    handleProximosPasos(event){
        this.proximosPasos = event.target.value;
    }

    handleCategoriaAenor(event){
        this.categoriaAenor = event.target.value;
    }

    handleRelacionCliente(event){
        this.relacionCliente = event.target.value;
    }


   

    updateRecords2(){
        this.enableSpinner();
        console.log('### this.listUpdateValues');
        console.log(this.listUpdateValues);
        updateRecords({listOppRecords: Object.values(this.listUpdateValues)})
            .then(result => {
                this.getActions();
            })
            .catch(error => {
                this.showToast(this.labels.error, error.body.pageErrors[0].message, 'error', 'pester');
                this.disableSpinner();
            });
    }
    
    handleSave(){
        this.enableSpinner();
        console.log('### this.listUpdateValues');
        console.log(this.listUpdateValues);
        if(Object.keys(this.listUpdateValues).length>0) {
            updateRecords({listOppRecords: Object.values(this.listUpdateValues)})
                .then(result => {
                    this.updateEvents();
                })                
                .catch(error => {
                    this.showToast(this.labels.error, error.body.message, 'error', 'pester');
            });
        } else {
            this.updateEvents();   
        }   
    }
/*
    handleClickOpportunity(){
        this.enableSpinner();
        this.createOpportunity = true;
        console.log('### this.listUpdateValues');
        console.log(this.listUpdateValues);
        if(Object.keys(this.listUpdateValues).length>0) {
            updateRecords({listOppRecords: Object.values(this.listUpdateValues)})
                .then(result => {
                    this.updateEvents();
                })                
                .catch(error => {
                    this.showToast(this.labels.error, error.body.message, 'error', 'pester');
            });
        } else {
            this.updateEvents();   
        }   
    }
    */

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
        updateEvents({recordId: this.recordId, comentario: this.comment, clienteNuevo: this.clienteNuevo, clienteEspana : this.clienteEspaña, antecedentes: this.antecedentes, conclusionGestor : this.conclusionGestor, conclusionCliente : this.conclusionCliente, proximosPasos: this.proximosPasos, categoriaAenor : this.categoriaAenor, relacionCliente : this.relacionCliente})
            .then(result => {
                this.showToast(this.labels.correcto, this.labels.eventoExito, 'success', 'pester');
                this.dispatchEvent(new CustomEvent('closetab'));
            })
            .catch(error => {
                this.showToast(this.labels.error, this.labels.errorActualizandoEvento, 'error', 'pester');
                console.log(error);
			}).finally(() => {
                this.disableSpinner();
                this.refresh();
                
            });
    }

    getActions() {
        getActions({ actionSetting: this.actionSetting })
        .then(data=>{
            this.disableSpinner();
            this.flowlabel = data[0].label;
            this.flowName = data[0].name;
            this.flowOutput = data[0].output;
            this.redirectId = null;
        }) .catch(error => {
            this.showToast(this.labels.error, this.labels.errorActualizandoEvento, 'error', 'pester');
            this.disableSpinner();
        });
    }

    handleClickEvent() {
        this.inputVariables = [{
            name: 'recordId',
            type: 'String',
            value: this.accountId
        }];
        if(this.actionSetting != 'CIBE_AltaDeEvento') {
            this.actionSetting = 'CIBE_AltaDeEvento';
        }
        this.flowHeader = this.labels.altaEvento;
        this.launchFlow = true;
        this.updateRecords2();
    }

    /*hideFlowAction(event) {
        if(!this.createOpportunity){
            this.isShowFlowAction = false;
        }else{
            this.isShowFlowAction = false;
            const selectedEvent = new CustomEvent("closetab");
            this.dispatchEvent(selectedEvent);
        }
    }*/

    get inputFlowVariables() {
        return [
            {
                name: 'recordId',
                type: 'String',
                value: this.recordId 
                //value: this.actionSetting == 'CIBE_AltaDeEvento' ? this.recordId : this.accountId
            }
        ];
    }
    
    handleStatusChange(event) {
        let objDetails = event.detail;
        console.log(JSON.stringify(event.detail));

        if(objDetails.status === 'FINISHED_SCREEN' ||  objDetails.status === "FINISHED") {
            const selectedEvent = new CustomEvent("closetab");
            this.dispatchEvent(selectedEvent);                
            this.showModal = false;
            this.launchFlow = false;
            if(this.actionSetting == 'CIBE_AltaDeEvento'){
                this.showToast('', this.labels.citaCreada, 'success', 'pester');
            }else if(this.actionSetting == 'CIBE_Nueva_Tarea'){
                this.showToast('', this.labels.tareaCreada, 'success', 'pester');
            }
            this.updateEvents();
        }
    }

    handleStatusChangeOpp(event) {
        const status = event.detail.status;
        if(status === 'FINISHED_SCREEN' || status === "FINISHED") {
            this.isShowFlowActionOpp = false;
        }
        
    }

    handelCancelNewOpp(){
        this.isShowFlowActionOpp = false;
    }

    handleClickTarea() {
        this.inputVariables = [{
            name: 'recordId',
            type: 'String',
            value: this.accountId
        }];
        if(this.actionSetting != 'CIBE_Nueva_Tarea'){
            this.actionSetting = 'CIBE_Nueva_Tarea';
        }
        this.flowHeader = this.labels.altaTarea;
        this.launchFlow = true;
        this.updateRecords2();
    }

    handleComboBoxChange(){
        this.isShowFlowActionOpp = true;
        if(this.actionSetting != 'CIBE_New_Opportunity' && this.roleEmp) {
            this.actionSetting = 'CIBE_New_Opportunity';
        }
        else if(this.actionSetting != 'CIBE_New_Opportunity_CIB' && this.roleCib){
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
        return refreshApex(this._wiredData); 
    }

    updateRecordView() {
        setTimeout(() => {
             eval("$A.get('e.force:refreshView').fire();");
        }, 1000); 
    }

    handleClose(){
		this.launchFlow = false;
        this.updateRecords2();
		const selectedEvent = new CustomEvent("closetab");
		this.dispatchEvent(selectedEvent);
	}
}