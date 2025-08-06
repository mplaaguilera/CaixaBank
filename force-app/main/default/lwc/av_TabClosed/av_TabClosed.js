import { LightningElement, track, api, wire} from 'lwc';

import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { createRecord } from 'lightning/uiRecordApi';

import updateTask 		         from '@salesforce/apex/AV_TabManagementTask_Controller.updateTask';
import getRecordType             from '@salesforce/apex/AV_TabManagementTask_Controller.getRecordType';
import getTaskStatus             from '@salesforce/apex/AV_TabManagementTask_Controller.getTaskStatus';
import getExpClienteData		 from '@salesforce/apex/AV_TabManagementTask_Controller.getExperienciaClienteData';
import AV_CMP_ErrorMessage 		 from '@salesforce/label/c.AV_CMP_ErrorMessage';
import getPickList            	 from '@salesforce/apex/AV_TabManagementTask_Controller.getPickListValuesByRecordTypeId';
import getResponseHGM			 from '@salesforce/apex/AV_TabManagementTask_Controller.getResponseHGM';
import getIsIntouch              from '@salesforce/apex/AV_TabManagementTask_Controller.getIsIntouch';

import { getRecord } from 'lightning/uiRecordApi';
import Id from '@salesforce/user/Id';
import USER_EXTERNAL_ID from '@salesforce/schema/User.AV_ExternalID__c';

export default class Av_TabClosed extends LightningElement {

	@api recordId;
	@track comment;
	@track fecha;
	@track error;
    @track recordType;
    @track showState = false;
	@track showSpinner = false;
	@api progressValue;
	@track options;
	@track disableBtn = false;
	@track status;
	@track boton=true;
	@track isExperiencia = false;

	//picklist tipo
	value;
	//picklist motivo action
	// motivos = '';
	@track motivos = [];
	@track actions=[];
	//valoración
	@track valoracion = null;
	@track requiredComment = false;
	@track requiredMotivos = false;
	@track requiredAcciones = false;
	@track labels = [];
	@track percepcion = true;
	@track currentDate = new Date().toISOString().substring(0,10);
	@track isSaved = false;
	//picklist estado
	@track valueEstado = 'Gestionada positiva';
    userExternalId;

	@wire(getRecord,{recordId:Id,fields:[USER_EXTERNAL_ID]})
	wiredUser({error,data}){
		if(data){
			this.userExternalId = data.fields.AV_ExternalID__c.value;
			this.getIsIntouchEmployee();
			
		}else if(error){
			console.log(error);
		}
	}

	getIsIntouchEmployee() {
		getIsIntouch({userExternalId: this.userExternalId})
			.then((results) => {
				var isIntouch = results;
				if(isIntouch){
					this.value = 'CTF';
				}else{
					this.value = 'LMD';
				}
			})
			.catch((error) => {
				console.log('Display ShowToastEvent error (catch): ', error);
				this.dispatchEvent(
					new ShowToastEvent({
						title: AV_CMP_ErrorMessage,
						message: JSON.stringify(error),
						variant: 'error'
					})
				);
			});
	}


	get optionsEstado() {
		return [
			{ label: 'Gestionada negativa', value: 'Gestionada negativa' },
			{ label: 'Gestionada positiva', value: 'Gestionada positiva' }
		];
	}

	get optionsValoracion() {
        return [
            { label: 'Ha empeorado', value: 'P' },
            { label: 'Indiferente', value: 'I' },
			{ label: 'Ha mejorado', value: 'M' }
        ];
    }

	get optionsAcciones() {
        return [
            { label: 'Ofrecer y explicar cita previa', value: 'OECP' },
            { label: 'Acompañar uso y conocimiento NOW', value: 'AUCN' },
            { label: 'Explicar precio/comisiones aplicadas', value: 'EPCA' },
            { label: 'Explicar ventajas Modelo Store', value: 'EVMS' },
            { label: 'Revisar problema no resuelto', value: 'RPNR' },
            { label: 'Disculparse por la calidad de servicio y aplicar mejoras en el centro', value: 'DCSAMC' },
            { label: 'Detectar el error y dar solución', value: 'DEDS' },
            { label: 'Aplicar descuento, reembolso, etc.', value: 'ADRE' },
            { label: 'Ofrecer producto acorde con necesidad cliente', value: 'OPANC' },
            { label: 'Facilitar nombre y datos contacto gestor', value: 'FNDCG' },
            { label: 'Reportar mejora a SSCC', value: 'RMSSCC' },
            { label: 'Otras', value: 'Otras' }
        ];
    }

	get optionsMotivo() {
		return [
			{ label: 'Modelo de oficina', value: 'MO' },			
			{ label: 'Facilidad de contacto', value: 'FC' },
			{ label: 'Cierre oficina', value: 'CO' },
			{ label: 'Cambio de gestor', value: 'CG' },
			{ label: 'Atención y trato', value: 'AT' },
			{ label: 'Competencia del Gestor ', value: 'COG' },
			{ label: 'NOW (Web o App)', value: 'NOW' },
			{ label: 'Cajeros', value: 'C' },
			{ label: 'Producto', value: 'P' },
			{ label: 'Precio y/o comisiones', value: 'PC' },
			{ label: 'Colas y tiempos de espera', value: 'CTE' },
			{ label: 'Problema no resuelto', value: 'PNR' },
			{ label: 'Morosidad', value: 'M' },
			{ label: 'Gestión Postventa', value: 'GP' },
			{ label: 'Otros', value: 'Otros' }
		];
	}

	handleChange(event) {
		this.value = event.detail.value;
	}

	handleChangeEstado(event) {
		this.valueEstado = event.detail.value;
	}

	//cambio fecha
	handleChangeDate(event) {
		this.fecha = event.target.value;
	}

	//cambio comentario
	handleChangeComment(event) {
		this.comment = event.target.value;
	}

	handleChangeMotive(event) {
		this.motivos = event.detail.value;
		this.requiredMotivos = (this.motivos.length === 0);
		this.isCommentRequired();
	}

	handleActions(event) {
		this.actions = event.detail.value; 
		this.requiredAcciones = (this.actions.length === 0);
		this.isCommentRequired();
	}

	handleValoracion(event) {
		this.valoracion = JSON.parse(JSON.stringify(event.detail.value));
		this.percepcion = false;
	}

	isCommentRequired() {
		if (typeof this.motivos !== 'undefined' || typeof this.actions !== 'undefined') {
			if ((this.motivos.includes('Otros') || this.actions.includes('Otras')) && (typeof this.comment === 'undefined' || this.comment === null ||this.comment === '')) {
				this.requiredComment = true;
				var commentField = this.template.querySelector('.comentario-ancho-exp');
				this.template.querySelector('.asterisk').style.display = 'block';
				commentField.focus();
			} else {
				this.requiredComment = false;
				this.template.querySelector('.asterisk').style.display = 'none';
			}
		}
	}

	isMotivoAccionesRequired(){
		// if ( this.motivos.length === 0 || this.actions.length === 0) {
		if (typeof this.motivos == 'undefined' || typeof this.actions == 'undefined') {
			this.requiredMotivos = true;
			this.requiredAcciones = true; 
				var commentField = this.template.querySelector('.slds-form-element slds-is-editing motivosAcciones');
				// this.template.querySelector('.asterisk').style.display = 'block';
				commentField.focus();
			} else {
				this.requiredMotivos = false;
				this.requiredAcciones = false;
				// this.template.querySelector('.asterisk').style.display = 'none';
			}
		}
	

	@api
	botonDisabled() {
		// Desactiva botón 'Grabar' si la tarea ha sido cerrada
		getTaskStatus({id: this.recordId})
		.then(tarea => {
			if(this.recordType == 'AV_Priorizador' || this.recordType == 'AV_AlertaComercial'){
				if(tarea.ActivityDate < this.fecha){
					this.disableBtn = true;
					this.template.querySelector('[data-id="btnGrabar"]').classList.add('buttonStyleDisabled');
				}
			} else if (this.recordType == 'AV_ExperienciaCliente') {
				if(tarea.IsClosed || tarea.Status == 'Gestionada positiva'){ //tarea.ActivityDate < this.currentDate
					this.disableBtn = true;
					this.template.querySelector('[data-id="btnGrabar"]').classList.add('buttonStyleDisabled');
					
				}else{
					let calendar = this.template.querySelector('[data-id="calendar"]')
					calendar.disabled = true
					calendar.value=this.currentDate
				
				}
			} else if(this.recordType == 'AV_Onboarding' ){
				if(tarea.ActivityDate < this.fecha || tarea.Status == 'Gestionada positiva'){
					this.disableBtn = true;
					this.template.querySelector('[data-id="btnGrabar"]').classList.add('buttonStyleDisabled');
				}
			} else if (this.recordType == 'AV_MorosidadNormativa') {
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
					title: AV_CMP_ErrorMessage,
					message: JSON.stringify(error),
					variant: 'error'
				})
			);
		});
	}

	connectedCallback() {
		var today = new Date();
		this.fecha=today.toISOString().substring(0,10);
		this.getRecordType();
		if (!this.disableBtn) {
			this.getPreviousData();
		}
		this.getPickListType('CBK_Activity_Extension__c', 'AV_MotivoCierreExperienciaCliente__c', 'AV_ActivityExtMotivoExperienciaCliente');
		this.getPickListType('Task', 'AV_Tipo__c', 'AV_TaskTipoExperienciaCliente');
	}

	handleSave() {
		if (this.isExperiencia) {
			this.isCommentRequired();
			this.isMotivoAccionesRequired();
			if(this.motivos.length === 0){
				this.showToast('Error', 'Debes seleccionar como mínimo un Motivo y una Acción a realizar.', 'error');
			}
			if(this.actions.length === 0){
				this.showToast('Error', 'Debes seleccionar como mínimo un Motivo y una Acción a realizar.', 'error');
			}
			if (this.requiredComment) {
				this.showToast('Error', 'Por favor rellene con un comentario el motivo de la gestión.', 'error');
			}
			if (this.percepcion) {
				this.template.querySelector('p').style.display = 'block';
			}
			if (!this.requiredComment && !this.percepcion && this.actions.length > 0 && this.motivos.length > 0) {
				this.template.querySelector('p').style.display = 'none';
				this.enableSpinner();
				this.updateTarea();
			}
		} else {
			this.enableSpinner();
			this.updateTarea();
		}
		this.isSaved = true;
	}

	showToast(title, message, variant) {
        var event = new ShowToastEvent({
            title: title,
			message: message,
			variant: variant
        });
        this.dispatchEvent(event);
    }

	@api
	getPreviousData() {
		getExpClienteData({id: this.recordId})
			.then(result => {
				if (result != null) {
					this.fecha = typeof result.fechaGestion !== 'undefined' ? result.fechaGestion : null;
					this.value = typeof result.tipo !== 'undefined' ? result.tipo : null;
					this.comment = typeof result.comment !== 'undefined' ? result.comment : null;
					this.valoracion = typeof result.valoracion !== 'undefined' ? result.valoracion : null;
					if (typeof result.motivo !== 'undefined') {
						this.motivos = result.motivo.split(";");
					}
					if (typeof result.acciones !== 'undefined') {
						this.actions = result.acciones.split(";");
					}
					this.isSaved = false;
				}
			})
			.catch(error => {
				//this.showToast('Error', 'Error cargando datos.', error);
				
			});
	}

	updateTarea(){
		var acts = this.actions != null && this.actions.length !== 0 ? this.actions.toString().split(',').join(';') : null;
		var mots = this.motivos != null && this.motivos.length !== 0 ? this.motivos.toString().split(',').join(';') : null;
		updateTask({id: this.recordId, estado: this.valueEstado, tipo: this.value, fecha: this.fecha, comentario: this.comment, acciones: acts, motivo: mots, valoracion: this.valoracion})
			.then(result => {
                if(result == 'OK') {
					this.getResponseHGM();
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
						title: AV_CMP_ErrorMessage,
						message: JSON.stringify(error),
						variant: 'error'
					})
				);
				this.disableSpinner();
			});
	}

	insertHistorialGestion() {
		//Insert AV_ManagementHistory__c@
		var record = {
			"apiName": "AV_ManagementHistory__c",
			"fields": {
				"AV_ActivityId__c":this.recordId,
				"AV_Date__c": this.fecha,
				"AV_Type__c": this.value,
				"AV_Status__c":this.valueEstado,
				"AV_Comment__c":this.comment
			}
		};
		createRecord(record)
			.then(() => {
				//this.comment='';
				this.value = 'LMD';
				this.valueEstado = 'Gestionada positiva';
				var today = new Date();
				//this.fecha=today.toISOString().substring(0,10);
				this.progressValue = "ManagementHistory";
				// Creates the event with the data.
				const selectedEvent = new CustomEvent("progressvaluechange", {
					detail: {
						progress: this.progressValue,
						boton: this.boton,
						closing: true
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
            .then(recordType => {
                if ('AV_ExperienciaCliente' == recordType ||
                'AV_Onboarding' == recordType ||
                'AV_MorosidadNormativa' == recordType) {
                    this.showState = true;
                }
				if ('AV_ExperienciaCliente' == recordType) {
					this.isExperiencia = true;
				}
				this.recordType = recordType;
				this.botonDisabled();
            })
            .catch(error => {
				console.log('Display ShowToastEvent error (catch): ', error);
                this.dispatchEvent(
					new ShowToastEvent({
						title: AV_CMP_ErrorMessage,
						message: JSON.stringify(error),
						variant: 'error'
					})
				);
            });
	}
	
	getPickListType(objectName, field, picklistDevName) {
        getPickList({objectName: objectName, recordId: this.recordId, fieldApiName: field, picklistDevName: picklistDevName})
            .then(result => {
				if ('AV_Tipo__c' == field) {
					this.options = result;
				}
            })
            .catch(error => {
				console.log('Display ShowToastEvent error (catch): ', error);
                this.dispatchEvent(
					new ShowToastEvent({
						title: AV_CMP_ErrorMessage,
						message: JSON.stringify(error),
						variant: 'error'
					})
				);
            });
    }

	getResponseHGM() {
		getResponseHGM({id: this.recordId, managementDateTask: this.fecha})
			.then(result => {
					this.insertHistorialGestion();
					this.disableSpinner();
            })
            .catch(error => {
				console.log('Display ShowToastEvent error (catch): ', error);
				this.disableSpinner();
            });
	}

	disableSpinner() {
        this.showSpinner = false;
    }

    enableSpinner() {
        this.showSpinner = true;
    }




}