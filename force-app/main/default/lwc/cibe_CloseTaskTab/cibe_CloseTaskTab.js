import { LightningElement, api, wire,track } from 'lwc';
import { CurrentPageReference  } from 'lightning/navigation';
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent }   from 'lightning/platformShowToastEvent';

import updateRecords        from '@salesforce/apex/CIBE_Oportunidades_Vinculadas_Controller.updateRecords';
import updateTasks         from '@salesforce/apex/CIBE_Oportunidades_Vinculadas_Controller.updateTask';
import insertManagementHistory  from '@salesforce/apex/CIBE_Oportunidades_Vinculadas_Controller.insertManagementHistory';
import getTaskFields  from '@salesforce/apex/CIBE_Oportunidades_Vinculadas_Controller.getTaskFields';
import getTaskRecordType  from '@salesforce/apex/CIBE_Oportunidades_Vinculadas_Controller.getTaskRecordTypeName';
import roleEmp             from '@salesforce/apex/CIBE_Oportunidades_Vinculadas_Controller.roleEMP';
import roleCib             from '@salesforce/apex/CIBE_Oportunidades_Vinculadas_Controller.roleCIB';

//Labels
import paraReportar from '@salesforce/label/c.CIBE_ParaReportarCorrectamenteOportunidades';
import actualizarListado from '@salesforce/label/c.CIBE_ActualizarListadoOportunidadesea';
import informarEstado from '@salesforce/label/c.CIBE_InformarEstadoDetalleOportunidades';
import grabarReporte from '@salesforce/label/c.CIBE_GrabarReporte';
import tareaExito from '@salesforce/label/c.CIBE_TareaCerradaConExito';
import errorActTarea from '@salesforce/label/c.CIBE_ErrorActualizandoTarea';
import correcto from '@salesforce/label/c.CIBE_Correcto';
import error from '@salesforce/label/c.CIBE_Error';
import newOpportunity from '@salesforce/label/c.CIBE_New_Opportunity';
import createOpportunity from '@salesforce/label/c.CIBE_Create_Opportunity';
import cerrarTareaAltaCita from '@salesforce/label/c.CIBE_CerrarTareaAltaCita';
import cerrarTareaAltaTarea from '@salesforce/label/c.CIBE_CerrarTareaAltaTarea';
import tareaCreada from '@salesforce/label/c.CIBE_TareaCreada';
import citaCreada from '@salesforce/label/c.CIBE_CitaCreada';
import altaEvento from '@salesforce/label/c.CIBE_AltaEvento';
import altaTarea from '@salesforce/label/c.CIBE_AltaTarea';

export default class Cibe_CloseTaskTab extends LightningElement {

    labels = {
        paraReportar, 
        actualizarListado,
        informarEstado,
        grabarReporte,
        tareaExito,
        errorActTarea,
        correcto,
        error,
        newOpportunity,
        createOpportunity,
        cerrarTareaAltaCita,
        cerrarTareaAltaTarea,
        tareaCreada,
        citaCreada,
        altaEvento,
        altaTarea
    };
    
    @api recordId;
    @track listUpdateValues ={};
    @track estado;
    @track tipo;
    @track fecha;
    @track comentario;
    @track contacto;
    @track rtAccCliente;


    @track comment;
    actionSetting = '';
    showSpinner = false;
    saveButton = true;

    
    inputVariables;
    flowHeader;

    @track accountId;
    @track recordtype;
    @track roleEmp = false;
    @track roleCib = false;
    @track isShowFlowActionOpp = false;
    @track launchFlow = false;
    @track flowSpinner;
    flowName;

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

    @wire(CurrentPageReference)
    setCurrentPageReference(currentPageReference) {
        this.currentPageReference = currentPageReference;
    }

    connectedCallback(){
        this.recordId = this.currentPageReference.state.c__recId;
        const selectedEvent = new CustomEvent("renametab");
		this.dispatchEvent(selectedEvent);
    }


    @wire(getTaskFields, {taskId : '$recordId'})
    taskFields({ data, error }) {
        if(data){
            this.record = data;
            this.accountId  = this.record.AccountId;
        }else if(error){
            console.log(error);
        }
    }

    
    @wire(getTaskRecordType, {taskId : '$recordId'})
    taskRecordType({ data, error }) {
        if(data){
            console.log(data);
            this.recordtype = data;
            
            

        }else if(error){
            console.log(error);
        }
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

    handelCancelNewOpp(){
        this.isShowFlowActionOpp = false;
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
    
    handleDataPadre(event) {
       this.estado =  event.detail.estado;
       this.tipo =  event.detail.tipo;
       this.fecha =  event.detail.fecha;
       this.comentario =  event.detail.comentario;
       this.contacto =  event.detail.contacto;
       this.rtAccCliente =  event.detail.rtAccCliente;

    }


    handleSave(){
        this.enableSpinner();
        if(Object.keys(this.listUpdateValues).length>0) {
            updateRecords({listOppRecords: Object.values(this.listUpdateValues)})
                .then(result => {
                    this.updateTask();
                    this.insertHistorialGestion();
                })
                .catch(error => {
                    this.showToast(this.labels.error, error, 'error', 'pester');
            });
        } else {
            this.updateTask();
            this.insertHistorialGestion();
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

    navigateToEvent() {
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: this.recordId,
                objectApiName: 'Event',
                actionName: 'view'
            }
        });
    }
    navigateToTask() {
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: this.recordId,
                objectApiName: 'Task',
                actionName: 'view'
            }
        });
    }

    updateTask() {
        updateTasks({recordId: this.recordId, comentario: this.comentario, estado: this.estado, tipo: this.tipo})
            .then(result => {
                this.disableSpinner();
                this.showToast(this.labels.correcto, this.labels.tareaExito, 'success', 'pester');
                const selectedEvent = new CustomEvent("closetab");
				this.dispatchEvent(selectedEvent);
                //this.navigateToTask();
            })
            .catch(error => {
                this.showToast(this.labels.error, this.labels.errorActTarea, 'error', 'pester');
                this.disableSpinner();
			});
    }

    updateTask2() {
        updateTasks({recordId: this.recordId, comentario: this.comentario, estado: this.estado, tipo: this.tipo})
            .then(result => {
                this.disableSpinner();
                this.showToast(this.labels.correcto, this.labels.tareaExito, 'success', 'pester');
                
            })
            .catch(error => {
                this.showToast(this.labels.error, this.labels.errorActTarea, 'error', 'pester');
                this.disableSpinner();
			});
    }

    insertHistorialGestion() {
        insertManagementHistory({recordId: this.recordId, comentario: this.comentario, estado: this.estado,tipo: this.tipo})
        .then(result => {
           
        })
        .catch(error => {
            this.showToast(this.labels.correcto, this.labels.errorActTarea, 'error', 'pester');
            this.disableSpinner();
        });
    }

    handleStatusChangeOpp(event) {
        const status = event.detail.status;
        if(status === 'FINISHED_SCREEN' || status === "FINISHED") {
            this.isShowFlowActionOpp = false;
        }
        
    }


    hideFlowAction(event) {
        this.noOpportunity = true;
        const selectedEvent = new CustomEvent("closetab");
		this.dispatchEvent(selectedEvent);
    }

    handleSaveCreateMeeting(){
        //this.enableSpinner();
        this.flowSpinner = true;
        this.actionSetting = 'CIBE_AltaDeEvento';
        this.launchFlow = true;
        this.flowHeader = this.labels.altaEvento;

        this.inputVariables = [{
            name: 'recordId',
            type: 'String',
            value: this.accountId
        }];

        if(Object.keys(this.listUpdateValues).length>0) {
            updateRecords({listOppRecords: Object.values(this.listUpdateValues)})
                .then(result => {
                    this.updateTask2();
                    this.insertHistorialGestion();
                })
                .catch(error => {
                    this.showToast(this.labels.error, error, 'error', 'pester');
            });
        } else {
            this.updateTask2();
            this.insertHistorialGestion();
        }
        this.flowSpinner = false;


    }


    handleSaveCreateTask(){
        //this.enableSpinner();
        this.flowSpinner = true;
        this.actionSetting = 'CIBE_Nueva_Tarea';
        this.launchFlow = true;
        this.flowHeader = this.labels.altaTarea;

        this.inputVariables = [{
            name: 'recordId',
            type: 'String',
            value: this.accountId
        }];

        if(Object.keys(this.listUpdateValues).length>0) {
            updateRecords({listOppRecords: Object.values(this.listUpdateValues)})
                .then(result => {
                    this.updateTask2();
                    this.insertHistorialGestion();
                })
                .catch(error => {
                    this.showToast(this.labels.error, error, 'error', 'pester');
            });
        } else {
            this.updateTask2();
            this.insertHistorialGestion();
        }

    }

    handleStatusChange(event) {
        const status = event.detail.status;
        if(status === 'FINISHED_SCREEN' || status === "FINISHED") {
            this.launchFlow = false;
            const selectedEvent = new CustomEvent("closetab");
		    this.dispatchEvent(selectedEvent);
            if(this.actionSetting == 'CIBE_AltaDeEvento'){
                this.showToast('', this.labels.citaCreada, 'success', 'pester');
            }else if(this.actionSetting == 'CIBE_Nueva_Tarea'){
                this.showToast('', this.labels.tareaCreada, 'success', 'pester');
            }   
        }
        
    }

    handleClose(){
		this.launchFlow = false;
        this.handleSave();
		const selectedEvent = new CustomEvent("closetab");
		this.dispatchEvent(selectedEvent);
	}

}