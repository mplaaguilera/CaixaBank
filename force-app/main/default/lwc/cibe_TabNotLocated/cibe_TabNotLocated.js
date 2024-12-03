import { LightningElement, track, api,wire} from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { createRecord } from 'lightning/uiRecordApi';

import getPickList            from '@salesforce/apex/CIBE_TabManagementTask_Controller.getPickListValuesByRecordTypeId';
import getRecordType            from '@salesforce/apex/CIBE_TabManagementTask_Controller.getRecordType';
import updateTask 		        from '@salesforce/apex/CIBE_TabManagementTask_Controller.updateTaskNotLocated';
import getTaskStatus            from '@salesforce/apex/CIBE_TabManagementTask_Controller.getTaskStatus';
import CIBE_CMP_ErrorMessage 	from '@salesforce/label/c.CIBE_CMP_ErrorMessage';

// Labels 

import fechaGestion from '@salesforce/label/c.CIBE_FechaGestion';
import tipo from '@salesforce/label/c.CIBE_Tipo';
import comentario from '@salesforce/label/c.CIBE_Comentario';
import grabar from '@salesforce/label/c.CIBE_Grabar';

export default class Cibe_TabNotLocated extends LightningElement {

	labels = {
		fechaGestion,
		tipo,
		comentario,
		grabar
	};
	
	@api recordId;
	@api objectApiName;
	@track comment;
	@track fecha;
	@track error;
	@track showSpinner = false;
	@api progressValue;
	@track recordType;
	@track options;
	@track disableBtn = false;
	@track boton = false;
	@api experienciaCliente = false;

	//picklist tipo
	@track value = 'LT';
	handleChange(event) {
		this.value = event.detail.value;
	}

	//picklist estado
	@track value2 = 'Pendiente no localizado';

	//cambio fecha
	handleChangeDate(event) {
		this.fecha = event.target.value;
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
				if(tarea.IsClosed || tarea.Status == 'Gestionada positiva'){ 
					this.disableBtn = true;
					this.template.querySelector('[data-id="btnGrabar"]').classList.add('buttonStyleDisabled');
				}
			} else if(this.recordType == 'CIBE_OnboardingCIB' || this.recordType == 'CIBE_OnboardingEMP'){
				if(tarea.ActivityDate < this.fecha || tarea.Status == 'Gestionada positiva'){
					this.disableBtn = true;
					this.template.querySelector('[data-id="btnGrabar"]').classList.add('buttonStyleDisabled');
				}
			} else if (this.recordType == 'CIBE_AvisosEMP' || this.recordType == 'CIBE_AvisosCIB') {
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
		var today = new Date();
		this.fecha=today.toISOString().substring(0,10);
		this.recordId;
		this.objectApiName;
		this.getPickListType();
		this.getRecordType();
	}

	handleSave() {
		this.enableSpinner();
		this.updateTarea();
	}

	updateTarea(){
		//Update Task
		updateTask({id: this.recordId, estado: this.value2, tipo: this.value, fecha: this.fecha, comentario: this.comment})
			.then(result => {
                if(result == 'OK') {
					this.insertHistorialGestion();
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
                this.dispatchEvent(
					new ShowToastEvent({
						title: CIBE_CMP_ErrorMessage,
						message: JSON.stringify(error),
						variant: 'error'
					})
				);
				this.disableSpinner();
			});
	}

	insertHistorialGestion() {
		//Insert AV_ManagementHistory__c
		var record = {
			"apiName": "AV_ManagementHistory__c",
			"fields": {
				"AV_ActivityId__c":this.recordId,
				"AV_Date__c": this.fecha,
				"AV_Type__c": this.value,
				"AV_Status__c":this.value2 ,
				"AV_Comment__c":this.comment
			}
		};
		createRecord(record)
			.then(() => {
				this.comment='';
				this.value = 'LMD';
				this.value2 = 'Pendiente no localizado';
				var today = new Date();
				this.fecha=today.toISOString().substring(0,10);
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

	@api
	getRecordType() {
        getRecordType({id: this.recordId})
            .then(result => {
				this.recordType = result;
				this.botonDisabled();
				if(this.recordType == 'CIBE_ExperienciaClienteCIB' || this.recordType == 'CIBE_ExperienciaClienteEMP'){
					this.experienciaCliente = true;
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

	getPickListType() {
        getPickList({objectName: 'Task', recordId: this.recordId, fieldApiName: 'AV_Tipo__c', picklistDevName: 'CIBE_TaskTipo'})
            .then(result => {
                this.options=result;
			 })
            .catch(error => {
                this.dispatchEvent(
					new ShowToastEvent({
						title: CIBE_CMP_ErrorMessage,
						message: JSON.stringify(error),
						variant: 'error'
					})
				);
            });
    }
	
	disableSpinner() {
        this.showSpinner = false;
    }

    enableSpinner() {
        this.showSpinner = true;
    }
}