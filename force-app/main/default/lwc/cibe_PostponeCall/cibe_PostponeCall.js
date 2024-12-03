import { LightningElement, track, api, wire} from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { createRecord} from 'lightning/uiRecordApi';

import updateTask 		        from '@salesforce/apex/CIBE_TabManagementTask_Controller.updateTaskReminder';
import getTaskStatus            from '@salesforce/apex/CIBE_TabManagementTask_Controller.getTaskStatus';
import getRecordType            from '@salesforce/apex/CIBE_TabManagementTask_Controller.getRecordType';
import getRecord            from '@salesforce/apex/CIBE_TabManagementTask_Controller.getRecord';

import CIBE_CMP_ErrorMessage 		from '@salesforce/label/c.CIBE_CMP_ErrorMessage';

//Labels 

import recordar from '@salesforce/label/c.CIBE_RecordarEl';
import aLas from '@salesforce/label/c.CIBE_ALas';
import comentario from '@salesforce/label/c.CIBE_Comentario';
import grabar from '@salesforce/label/c.CIBE_Grabar';

export default class Cibe_PostponeCall extends LightningElement {

	labels = {
		recordar,
		aLas,
		comentario,
		grabar
	};

    @api recordId;
	@track comment;
    @track reminderDate;
    @track reminderTime;
    @track reminderDateTime;
	@track fecha;
	@track error;

	@track today;
	
	@api progressValue;
	@track recordType;
	@track showSpinner = false;
	@track disableBtn = false;
	@track boton= false;

	@track value = [];


	

	//cambio fecha
	handleChangeReminderDate(event) {
        this.reminderDate = event.target.value;
    }

    //cambio Time
	handleChangeReminderTime(event) {
        this.reminderTime = event.target.value;
	}

	//cambio comentario
	handleChangeComment(event) {
		this.comment = event.target.value;
	}

	@api
	botonDisabled() {
		// Desactiva botón 'Grabar' si la tarea ha sido cerrada
		getTaskStatus({id: this.recordId})
		.then(tarea => {
			
			if(this.recordType == 'CIBE_GestionarPriorizadosCIB' || this.recordType == 'CIBE_GestionarPriorizadosEMP' || this.recordType == 'CIBE_AlertaComercialCIB' || this.recordType == 'CIBE_AlertaComercialEMP'){
				if(tarea.ActivityDate < this.fecha){
					this.disableBtn = true;
					this.template.querySelector('[data-id="btnGrabar"]').classList.add('buttonStyleDisabled');
				}
			} else if (this.recordType == 'CIBE_ExperienciaClienteCIB' || this.recordType == 'CIBE_ExperienciaClienteEMP') {
				if(tarea.IsClosed || tarea.Status == 'Gestionada positiva'){ //tarea.ActivityDate < this.currentDate
					this.disableBtn = true;
					this.template.querySelector('[data-id="btnGrabar"]').classList.add('buttonStyleDisabled');
				}
			} else if(this.recordType == 'CIBE_OnboardingCIB' || this.recordType == 'CIBE_OnboardingEMP' ){
				if(tarea.ActivityDate < this.fecha || tarea.Status == 'Gestionada positiva'){
					this.disableBtn = true;
					this.template.querySelector('[data-id="btnGrabar"]').classList.add('buttonStyleDisabled');
				}
			} else if (this.recordType == 'CIBE_AvisosCIB' || this.recordType == 'CIBE_AvisosEMP') {
				var date = new Date(tarea.ActivityDate);
				date.setDate(date.getDate() + 7);
				var day = date.getDate();
				if (day <= 9) {
					day='0'+day;
				}
				var month = date.getMonth()+1;
				if (month <= 9) {
					month='0'+month;
				}
				var year = date.getFullYear();
				var fechave=year+'-'+month+'-'+day;
				if (fechave < this.fecha) {
					this.disableBtn = true;
					this.template.querySelector('[data-id="btnGrabar"]').classList.add('buttonStyleDisabled');
				}
			}
		})
		.catch(error => {
			console.log('Display ShowToastEvent error (catch): ', error);
			this.dispatchEvent(
				new ShowToastEvent({
					title: CIBE_CMP_ErrorMessage,
					message: JSON.stringify(error),
					variant: 'error'
				})
			);
		});
	}

	connectedCallback() {
        this.today = new Date();
        this.today.setHours(this.today.getHours() + 1);
        this.reminderDate=this.today.toISOString().substring(0,10);
        this.reminderTime=this.today.toTimeString().substring(0,5);
		this.fecha=this.today.toISOString().substring(0,10);
		this.recordId;

		this.getRecordType();
	}

	@api
	getRecordType() {
        getRecordType({id: this.recordId})
            .then(result => {
				this.recordType = result;
				this.botonDisabled();
            })
            .catch(error => {
				console.log('Display ShowToastEvent error (catch): ', error);
                this.dispatchEvent(
					new ShowToastEvent({
						title: CIBE_CMP_ErrorMessage,
						message: JSON.stringify(error),
						variant: 'error'
					})
				);
            });
	}

	handleSave() {
		this.enableSpinner();
		this.updateTarea();
	}

	updateTarea(){
        //Update Task
        this.reminderDateTime = new Date(this.reminderDate + ' ' + this.reminderTime);
		updateTask({id: this.recordId, reminderDateTime: this.reminderDateTime, comentario: this.comment})
			.then(result => {
                if(result == 'OK') {
					if(this.value[0].Status == 'Pendiente no localizado' && this.comment == null){
						this.insertHistorialGestion();
					}else{
						this.progressValue = "ManagementHistory";
						const selectedEvent = new CustomEvent("progressvaluechange", {
							detail: {
								progress: this.progressValue,
								boton: this.boton
							}
							});
						this.dispatchEvent(selectedEvent);
						this.disableSpinner();
					}
				}else {
					this.dispatchEvent(
						new ShowToastEvent({
							title: 'Error',
							message: result,
							variant: 'error'
						})
					);
					this.disableSpinner();
				}          
			})
			.catch(error => {
				console.log('Display ShowToastEvent error (catch): ',error);
                this.dispatchEvent(
					new ShowToastEvent({
						title: CIBE_CMP_ErrorMessage,
						message: JSON.stringify(error),
						variant: 'error'
					})
				);
				this.disableSpinner();
			}).fin
	}

	insertHistorialGestion() {
		//Insert AV_ManagementHistory__c
		var record = {
			"apiName": "AV_ManagementHistory__c",
			"fields": {
				"AV_ActivityId__c":this.recordId,
				"AV_Date__c": this.today.toISOString().substring(0,10),
                "AV_Status__c": "Posponer-Llamar más tarde",
                "AV_Reminder__c": this.reminderDateTime,
				"AV_Comment__c":this.comment
			}
		};
		createRecord(record)
			.then(() => {
				this.comment='';
				this.today = new Date();
                this.reminderDate=this.today.toISOString().substring(0,10);
                this.reminderTime=this.today.toTimeString().substring(0,5);
				this.progressValue = "ManagementHistory";
				// Creates the event with the data.
				const selectedEvent = new CustomEvent("progressvaluechange", {
					detail: {
						progress: this.progressValue,
						boton: this.boton
					}
					});
				// Dispatches the event.
				this.dispatchEvent(selectedEvent);
			})
			.catch(error => {
				this.dispatchEvent(
					new ShowToastEvent({
						title: 'Error creating record',
						message: JSON.stringify(error),
						variant: 'error'
					})
				);
				this.disableSpinner();
			});
			this.disableSpinner();
	}

	disableSpinner() {
        this.showSpinner = false;
    }

    enableSpinner() {
        this.showSpinner = true;
	}


	
    @wire(getRecord, {recordId : '$recordId'})
    wiredValues({error, data}){
		if(data){
			this.value = data;
		}else if(error){
			Console.log(error);
		}
	}

	
}