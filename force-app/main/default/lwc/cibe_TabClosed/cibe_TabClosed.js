import { LightningElement, track, api} from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { createRecord } from 'lightning/uiRecordApi';

import updateTask 		         from '@salesforce/apex/CIBE_TabManagementTask_Controller.updateTask';
import getRecordType             from '@salesforce/apex/CIBE_TabManagementTask_Controller.getRecordType';
import getTaskStatus             from '@salesforce/apex/CIBE_TabManagementTask_Controller.getTaskStatus';
import getExpClienteData		 from '@salesforce/apex/CIBE_TabManagementTask_Controller.getExperienciaClienteData';
import CIBE_CMP_ErrorMessage 	 from '@salesforce/label/c.CIBE_CMP_ErrorMessage';
import getPickList            	 from '@salesforce/apex/CIBE_TabManagementTask_Controller.getPickListValuesByRecordTypeId';
import getResponseHGM			 from '@salesforce/apex/CIBE_TabManagementTask_Controller.validateHGM';
import CIBE_CMP_ErrorValidateHGM from '@salesforce/label/c.CIBE_CMP_ErrorValidateHGM';

//Labels
import tipo from '@salesforce/label/c.CIBE_Tipo';
import comentario from '@salesforce/label/c.CIBE_Comentario';
import fechaGestion from '@salesforce/label/c.CIBE_FechaGestion';
import estado from '@salesforce/label/c.CIBE_Estado';
import motivosPrincipales from '@salesforce/label/c.CIBE_MotivosPrincipales';
import gestionadaNegativa from '@salesforce/label/c.CIBE_GestionadaNegativa';
import gestionadaPositiva from '@salesforce/label/c.CIBE_GestionadaPositiva';
import error from '@salesforce/label/c.CIBE_Error';
import seleccionados from '@salesforce/label/c.CIBE_Seleccionados';
import disponibles from '@salesforce/label/c.CIBE_Disponibles';

import haEmpeorado from '@salesforce/label/c.CIBE_HaEmpeorado';
import indiferente from '@salesforce/label/c.CIBE_Indiferente';
import haMejorado from '@salesforce/label/c.CIBE_HaMejorado';

import accionesARealizar from '@salesforce/label/c.CIBE_AccionesARealizar';
import comoCreesGestion from '@salesforce/label/c.CIBE_ComoCreesGestion';
import porFavorSeleccioneUnaOpcion from '@salesforce/label/c.CIBE_PorFavorSeleccioneUnaOpcion';
import grabar from '@salesforce/label/c.CIBE_Grabar';
import alGestionarEstaTarea from '@salesforce/label/c.CIBE_AlGestionarEstaTarea';
import seleccionarMotivoAccion from '@salesforce/label/c.CIBE_MSG_SeleccionarMotivoAccion';
import relleneComentario from '@salesforce/label/c.CIBE_MSG_RelleneComentario';
import disculparsePorLaCalidad from '@salesforce/label/c.CIBE_DisculparsePorLaCalidad';

import detectarErrorYSolucion from '@salesforce/label/c.CIBE_DetectarErrorYSolucion';
import revisarProblemaNoResuelto from '@salesforce/label/c.CIBE_RevisarProblemaNoResuelto';
import explicarPrecioComisionesAplicadas from '@salesforce/label/c.CIBE_ExplicarPrecioComisionesAplicadas';
import ofrecerDetalleExplicacionProducto from '@salesforce/label/c.CIBE_OfrecerDetalleExplicacionProducto';
import ofrecerProductoAcordeNecesidad from '@salesforce/label/c.CIBE_OfrecerProductoAcordeNecesidad';
import explicarModeloEspecializadoYPropuesta from '@salesforce/label/c.CIBE_ExplicarModeloEspecializadoYPropuesta';
import facilitarNombreDatosContacto from '@salesforce/label/c.CIBE_FacilitarNombreDatosContacto';
import otros from '@salesforce/label/c.CIBE_Otros';

import atencionYTrato from '@salesforce/label/c.CIBE_AtencionYTrato';
import pocaAgilidad from '@salesforce/label/c.CIBE_PocaAgilidad';
import problemaNoResuelto from '@salesforce/label/c.CIBE_ProblemaNoResuelto';
import precioComisiones from '@salesforce/label/c.CIBE_PrecioComisiones';
import claridadExplicaciones from '@salesforce/label/c.CIBE_ClaridadExplicaciones';
import producto from '@salesforce/label/c.CIBE_Producto';
import dificultadContacto from '@salesforce/label/c.CIBE_DificultadContacto';
import noReconoceGestor from '@salesforce/label/c.CIBE_NoReconoceGestor';
import cambioGestor from '@salesforce/label/c.CIBE_CambioGestor';
import noConcesionRiesgos from '@salesforce/label/c.CIBE_NoConcesionRiesgos';
import nowWebApp from '@salesforce/label/c.CIBE_NowWebApp';

export default class Cibe_TabClosed extends LightningElement {

	label = {
        tipo, 
		comentario,
		fechaGestion,
		estado,
		motivosPrincipales,
		gestionadaPositiva,
		gestionadaNegativa,
		error,
		seleccionados,
		disponibles,

		haEmpeorado,
		indiferente,
		haMejorado,

		accionesARealizar,
		comoCreesGestion,
		porFavorSeleccioneUnaOpcion,
		grabar,
		alGestionarEstaTarea,
		seleccionarMotivoAccion,
		relleneComentario,
		disculparsePorLaCalidad,

		atencionYTrato,
		pocaAgilidad,
		problemaNoResuelto,
		precioComisiones,
		claridadExplicaciones,
		producto,
		dificultadContacto,
		noReconoceGestor,
		cambioGestor,
		noConcesionRiesgos,
		nowWebApp,

		detectarErrorYSolucion,
		revisarProblemaNoResuelto,
		explicarPrecioComisionesAplicadas,
		ofrecerDetalleExplicacionProducto,
		ofrecerProductoAcordeNecesidad,
		explicarModeloEspecializadoYPropuesta,
		facilitarNombreDatosContacto,
		otros
    };

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
	@track value = 'LT';
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


	get optionsEstado() {
		return [
			{ label: this.label.gestionadaNegativa, value: 'Gestionada negativa' },
			{ label: this.label.gestionadaPositiva, value: 'Gestionada positiva' }
		];
	}

	get optionsValoracion() {
        return [
            { label: this.label.haEmpeorado, value: 'P' },
            { label: this.label.indiferente, value: 'I' },
			{ label: this.label.haMejorado, value: 'M' }
        ];
    }

	get optionsAcciones() {
        return [
			{ label: this.label.disculparsePorLaCalidad, value: 'DCSAM' },
            { label: this.label.detectarErrorYSolucion, value: 'DEDS' },
            { label: this.label.revisarProblemaNoResuelto, value: 'RPNR' },
            { label: this.label.explicarPrecioComisionesAplicadas, value: 'EPCA' },
			{ label: this.label.ofrecerDetalleExplicacionProducto, value: 'ODEPS' },
            { label: this.label.ofrecerProductoAcordeNecesidad, value: 'OPANC' },
			{ label: this.label.explicarModeloEspecializadoYPropuesta, value: 'EMEPV' },
            { label: this.label.facilitarNombreDatosContacto, value: 'FNDC' },
            { label: this.label.otros, value: 'Otros' }
            // { label: 'Ofrecer y explicar cita previa', value: 'OECP' },
            // { label: 'Acompañar uso y conocimiento NOW', value: 'AUCN' },
            // { label: 'Explicar ventajas Modelo Store', value: 'EVMS' },
            // { label: 'Aplicar descuento, reembolso, etc.', value: 'ADRE' },
            // { label: 'Reportar mejora a SSCC', value: 'RMSSCC' },
        ];
    }
	
	get optionsMotivo() {
		return [
			{ label: this.label.atencionYTrato, value: 'AT' },
			{ label: this.label.pocaAgilidad, value: 'PA' },
			{ label: this.label.problemaNoResuelto, value: 'PNR' },
			{ label: this.label.precioComisiones, value: 'PC' },
			{ label: this.label.claridadExplicaciones, value: 'CE' },
			{ label: this.label.producto, value: 'P' },
			{ label: this.label.dificultadContacto, value: 'DC' },
			{ label: this.label.cambioGestor, value: 'CG' },
			{ label: this.label.noReconoceGestor, value: 'NoG' },
			{ label: this.label.noConcesionRiesgos, value: 'NoR' },
			{ label: this.label.nowWebApp, value: 'NOW' },
			{ label: this.label.otros, value: 'Otros' }
			// { label: 'Modelo de oficina', value: 'MO' },			
			// { label: 'Facilidad de contacto', value: 'FC' },
			// { label: 'Cierre oficina', value: 'CO' },
			// { label: 'Competencia del Gestor ', value: 'COG' },
			// { label: 'Cajeros', value: 'C' },
			// { label: 'Colas y tiempos de espera', value: 'CTE' },
			// { label: 'Morosidad', value: 'M' },
			// { label: 'Gestión Postventa', value: 'GP' },
		];
	}

	//picklist tipo
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
		if (typeof this.motivos == 'undefined' || typeof this.actions == 'undefined') {
			this.requiredMotivos = true;
			this.requiredAcciones = true; 
				var commentField = this.template.querySelector('.slds-form-element slds-is-editing motivosAcciones');
				commentField.focus();
			} else {
				this.requiredMotivos = false;
				this.requiredAcciones = false;
			}
		}
	

	@api
	botonDisabled() {
		getTaskStatus({id: this.recordId})
		.then(tarea => {
			if(this.recordType == 'CIBE_GestionarPriorizadosCIB' || this.recordType == 'CIBE_GestionarPriorizadosEMP'  || this.recordType == 'CIBE_AlertaComercialCIB' || this.recordType == 'CIBE_AlertaComercialEMP'){
				if(tarea.ActivityDate < this.fecha){
					this.disableBtn = true;
					this.template.querySelector('[data-id="btnGrabar"]').classList.add('buttonStyleDisabled');
				}
			} else if (this.recordType == 'CIBE_ExperienciaClienteCIB' || this.recordType == 'CIBE_ExperienciaClienteEMP') {
				if(tarea.IsClosed || tarea.Status == 'Gestionada positiva'){
					this.disableBtn = true;
					this.template.querySelector('[data-id="btnGrabar"]').classList.add('buttonStyleDisabled');
					
				}else{
					let calendar = this.template.querySelector('[data-id="calendar"]')
					calendar.disabled = true
					calendar.value=this.currentDate
				
				}
			} else if(this.recordType == 'CIBE_OnboardingEMP' || this.recordType == 'CIBE_OnboardingCIB'){
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
		this.fecha = today.toISOString().substring(0,10);
		this.getRecordType();
		if (!this.disableBtn) {
			this.getPreviousData();
		}
		this.getPickListType('CBK_Activity_Extension__c', 'AV_MotivoCierreExperienciaCliente__c', 'AV_ActivityExtMotivoExperienciaCliente');
		this.getPickListType('Task', 'AV_Tipo__c', 'CIBE_TaskTipo');
		console.log(this.fecha);
	}

	handleSave() {
		if (this.isExperiencia) {
			this.isCommentRequired();
			this.isMotivoAccionesRequired();
			if(this.motivos.length == 0){
				this.showToast(this.labels.error, this.labels.seleccionarMotivoAccion, 'error');
			}
			if(this.actions.length == 0){
				this.showToast(this.labels.error, this.labels.seleccionarMotivoAccion, 'error');
			}
			if (this.requiredComment) {
				this.showToast(this.labels.error, this.labels.relleneComentario, 'error');
			}
			if (this.percepcion) {
				this.template.querySelector('p').style.display = 'block';
			}
			if (!this.requiredComment && !this.percepcion && this.actions.length > 0 && this.motivos.length > 0) {
				this.template.querySelector('p').style.display = 'none';
				this.enableSpinner();
				this.getResponseHGM();
			}
		} else {
			this.enableSpinner();
			this.updateTarea();
		}
		this.isSaved = true;
	}

	showToast(title, message, variant) {
        const event = new ShowToastEvent({
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
					this.fecha = typeof result.fechaGestion !== 'undefined' ? result.fechaGestion : this.fecha;
					this.value = typeof result.tipo !== 'undefined' ? result.tipo : this.value;
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
				console.log(result);
				// this.showToast('Error', 'Error cargando datos.', error);
				
			});
	}

	updateTarea(){
		var acts = this.actions != null && this.actions.length !== 0 ? this.actions.toString().split(',').join(';') : null;
		var mots = this.motivos != null && this.motivos.length !== 0 ? this.motivos.toString().split(',').join(';') : null;
		updateTask({id: this.recordId, estado: this.valueEstado, tipo: this.value, fecha: this.fecha, comentario: this.comment, acciones: acts, motivo: mots, valoracion: this.valoracion})
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
			}).finally(e => {
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
				"AV_Status__c":this.valueEstado,
				"AV_Comment__c":this.comment
			}
		};
		createRecord(record)
			.then(() => {
				//this.comment='';
				this.value = 'LT';
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
			});

		this.disableSpinner();
	}

	@api
    getRecordType() {
        getRecordType({id: this.recordId})
            .then(recordType => {
                if ('CIBE_ExperienciaClienteCIB' == recordType || 'CIBE_ExperienciaClienteEMP' == recordType || 'CIBE_OnboardingEMP' == recordType || 'CIBE_OnboardingCIB' == recordType || 'CIBE_AvisosCIB' == recordType || 'CIBE_AvisosEMP' == recordType) {
                    this.showState = true;
                }
				if ('CIBE_ExperienciaClienteCIB' == recordType || 'CIBE_ExperienciaClienteEMP' == recordType) {
					this.isExperiencia = true;
				}
				this.recordType = recordType;
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
						title: CIBE_CMP_ErrorMessage,
						message: JSON.stringify(error),
						variant: 'error'
					})
				);
            });
    }

	getResponseHGM() {
		console.log('managementDateTask: '+this.fecha);
		getResponseHGM({id: this.recordId, managementDateTask: this.fecha})
			.then(result => {
                if(result == 'OK') {
					this.updateTarea();			
				}else {
					this.dispatchEvent(
						new ShowToastEvent({
							title: 'Error',
							message: result,
							variant: 'error'
						})
					);
				}          
			})
            .catch(error => {
				console.log('Display ShowToastEvent error (catch): ', error);
				this.dispatchEvent(
					new ShowToastEvent({
						title: CIBE_CMP_ErrorValidateHGM,
						message: JSON.stringify(error),
						variant: 'error'
					})
				);
            }).finally(e => {
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