import { LightningElement, api, wire, track } from 'lwc';
import { getRecord, getFieldValue, updateRecord } from 'lightning/uiRecordApi';
import { getPicklistValues } from "lightning/uiObjectInfoApi";
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { RefreshEvent } from 'lightning/refresh';

//Campos
import CASEID_FIELD from "@salesforce/schema/Case.Id";
import STATUS_FIELD from "@salesforce/schema/Case.Status";
import SUBESTADO_FIELD from "@salesforce/schema/Case.SEG_Subestado__c";
import RECORDTYPEID_FIELD from "@salesforce/schema/Case.RecordTypeId";
import RECORDTYPENAME_FIELD from "@salesforce/schema/Case.RecordType.DeveloperName";
import ISCLOSED_FIELD from "@salesforce/schema/Case.IsClosed";
import MOTIVOCOMPLEMENTARIA_FIELD from "@salesforce/schema/Case.SPV_MotivoComplementariaOrganismo__c";
import RECTIFICADO_FIELD from "@salesforce/schema/Case.SPV_Rectificado__c";
import FECHARECEPCIONRESOLUCION_FIELD from "@salesforce/schema/Case.SPV_FechaRecepcionResolucion__c";
import ORGANISMO_FIELD from "@salesforce/schema/Case.SPV_Organismo__c";
//Llamadas Apex
import getPretensiones from '@salesforce/apex/SPV_LCMP_PathEstadosReclamacion.getPretensiones';
import pasarFaseNegociacion from '@salesforce/apex/SPV_LCMP_PathEstadosReclamacion.pasarFaseNegociacion';
import pasarFaseEnvioOrgRectificacion from '@salesforce/apex/SPV_LCMP_PathEstadosReclamacion.pasarFaseEnvioOrgRectificacion';

const caseFields = [CASEID_FIELD, STATUS_FIELD, SUBESTADO_FIELD, RECORDTYPEID_FIELD, ISCLOSED_FIELD, RECORDTYPENAME_FIELD, MOTIVOCOMPLEMENTARIA_FIELD, RECTIFICADO_FIELD, FECHARECEPCIONRESOLUCION_FIELD, ORGANISMO_FIELD];

const columns = [
    { label: 'Temática', fieldName: 'CC_MCC_Tematica' }, 
    { label: 'Producto/Servicio', fieldName: 'CC_MCC_ProdServ'},
    { label: 'Motivo', fieldName: 'CC_MCC_Motivo'},
    { label: 'Detalle', fieldName: 'SEG_Detalle'}
];

export default class Spv_PathEstadosReclamacion extends LightningElement {
    @api recordId;
    statusValues; //Almacenar los valores de la picklist status
	subestadosData; //Almacenar la data de la picklist subestado
	subestadosValues = []; //Almacenar los valores de la picklist subestado (solo los valores dependientes del status)
    @track statusSeleccionado = 'SAC_001'; //Indicar el status seleccionado
    subestadoSeleccionado; //Indicar el subestado seleccionado
	@track subestadoSeleccionadoOnLastClick = '';
	isLoading = false;
	@track status;
	@track generarProgressIndicator = false;		//Variable con la que se controla que se genere el path de estados cuando todos los datos requeridos ya están calculados y no antes
	@track subestado;
	@track seleccionadoSubestado = false;
	@track mostrarPasoEnvioOrgRecti = false;
	@track mostrarNoRectificar = false;
	@track mostrarRectificar = false;

	@track isModalOpenPretensiones = false;
	pretensiones = [];
    columns = columns;
    mostrarBoton = true;
    lstSelectedRecords = [];

	@track statusAlta = 'SAC_001';
	@track statusAnalisisDecision = 'SPV_AnalisisDecision';
    @track statusEnvio = 'SPV_Envio';
    @track statusPendienteRespuestaOrganismo = 'SPV_PendienteRespuestaOrganismo';
    @track statusAnalisisComplementariaOrganismo = 'SPV_AnalisisComplementariaOrganismo'
    @track statusEnvioComplementaria = 'SPV_EnvioComplementaria';
    @track statusRecepcionResolucion = 'SPV_RecepcionResolucion';
    @track statusRectificacion = 'SPV_Rectificacion';
    @track statusEnvioRectificacion = 'SPV_EnvioRectificacion';
    @track statusResolucion = 'SAC_003';
    @track statusDescartada = 'Descartado';
    @track statusCerrar = 'Cerrado';
	@track statusBaja = 'SAC_009';

	@track organismoConsumo = 'SPV_Consumo';
    //Recuperar registro con los campos definidos en la constante caseFields
    @wire(getRecord, {
        recordId: "$recordId",
        fields: caseFields
    })
    record;

	@wire(getRecord, { recordId: '$recordId', fields: caseFields })
    wiredGetRecord({error, data}) {
        if (data) {
			this.generarProgressIndicator = false;
			this.status = data.fields.Status.value;
			//this.subestado = data.fields.SEG_Subestado__c.value;
		 	//this.seleccionadoSubestado = false;
			if(data.fields.RecordType.value.fields.DeveloperName.value == 'SPV_Pretension' && data.fields.Status.value == 'SAC_007') {
				const botonActualizar = this.template.querySelector('.botonActualizar');
				botonActualizar.disabled = true;
			}
		}
    }

	/*opcion1(){
		if (this.caseStatus === this.statusAlta || this.caseStatus === this.statusAnalisisDecision || this.caseStatus === this.statusEnvio || this.caseStatus === this.statusPendienteRespuestaOrganismo || this.caseStatus === this.statusRecepcionResolucion || this.caseStatus === this.statusCerrar) {
			return true;
		}else{
			return false;
		}
	}*/

    @wire(getPicklistValues, { recordTypeId: '$record.data.recordTypeId', fieldApiName: STATUS_FIELD, fields: caseFields })
    valoresPicklistStatus({data}) {
        if (data) {
			this.generarProgressIndicator = false;
            this.statusValues = this.sortStatusValues(data.values);
			if(this.caseOrganismo != this.organismoConsumo){
				// Alta, Análisis, Envío, Pendiente Respuesta Organismo, Resolución y Cerrado
				if (this.caseStatus === this.statusAlta || this.caseStatus === this.statusAnalisisDecision || this.caseStatus === this.statusEnvio || this.caseStatus === this.statusPendienteRespuestaOrganismo || this.caseStatus === this.statusRecepcionResolucion || this.caseStatus === this.statusCerrar) {
					const estadosExcluidos = [
						'SPV_AnalisisComplementariaOrganismo',
						'SPV_EnvioComplementaria',
						'SPV_Rectificacion',
						'SPV_EnvioRectificacion',
						'Rechazado',
						'Descartado',
						'SAC_009'
					];
					this.statusValues = this.statusValues.filter(status => 
						!estadosExcluidos.includes(status.value)
					);
					
				}
				// Análisis Complementaria Organismo y Envío Complementaria
				else if(this.caseStatus === this.statusAnalisisComplementariaOrganismo || this.caseStatus === this.statusEnvioComplementaria){
					const estadosExcluidos = [
						'Descartado',
						'SPV_Rectificacion',
						'SPV_EnvioRectificacion',
						'SAC_009'
					];
					this.statusValues = this.statusValues.filter(status => 
						!estadosExcluidos.includes(status.value)
					);
				}
				// Rectificación y Envío Rectificación
				else if(this.caseStatus === this.statusRectificacion || this.caseStatus === this.statusEnvioRectificacion){
					const estadosExcluidos = [
						'Descartado',
						'SPV_AnalisisComplementariaOrganismo',
						'SPV_EnvioComplementaria',
						'Rechazado',
						'SAC_009'
					];

					this.statusValues = this.statusValues.filter(status => 
						!estadosExcluidos.includes(status.value)
					);
				}	
				// Descartado
				else if (this.caseStatus === this.statusDescartada) {
					const estadosExcluidos = [
						'SAC_002',
						'SPV_AnalisisDecision',
						'SPV_Envio',
						'SPV_PendienteRespuestaOrganismo',
						'SPV_AnalisisComplementariaOrganismo',
						'SPV_EnvioComplementaria',
						'SPV_RecepcionResolucion',
						'SPV_Rectificacion',
						'SPV_EnvioRectificacion',
						'Rechazado',
						'Cerrado',
						'SAC_009'
					];
					this.statusValues = this.statusValues.filter(status => 
						!estadosExcluidos.includes(status.value));
					
				}
				// Baja
				else if (this.caseStatus === this.statusBaja) {
					const estadosExcluidos = [
						'SAC_001',
						'SAC_002',
						'SPV_AnalisisDecision',
						'SPV_Envio',
						'SPV_PendienteRespuestaOrganismo',
						'SPV_AnalisisComplementariaOrganismo',
						'SPV_EnvioComplementaria',
						'SPV_RecepcionResolucion',
						'SPV_Rectificacion',
						'SPV_EnvioRectificacion',
						'Rechazado',
						'Cerrado',
						'Descartado'
					];
					this.statusValues = this.statusValues.filter(status => 
						!estadosExcluidos.includes(status.value));
					
				}
			}else{
				// Alta, Análisis, Envío, Pendiente Respuesta Organismo, Resolución y Cerrado
				if (this.caseStatus === this.statusAlta || this.caseStatus === this.statusAnalisisDecision || this.caseStatus === this.statusEnvio || this.caseStatus === this.statusCerrar) {
					const estadosExcluidos = [
						'SPV_PendienteRespuestaOrganismo',
						'SPV_RecepcionResolucion',
						'SPV_AnalisisComplementariaOrganismo',
						'SPV_EnvioComplementaria',
						'SPV_Rectificacion',
						'SPV_EnvioRectificacion',
						'Rechazado',
						'Descartado',
						'SAC_009'
					];
					this.statusValues = this.statusValues.filter(status => 
						!estadosExcluidos.includes(status.value)
					);
					
				}
				// Análisis Complementaria Organismo y Envío Complementaria
				else if(this.caseStatus === this.statusAnalisisComplementariaOrganismo || this.caseStatus === this.statusEnvioComplementaria){
					const estadosExcluidos = [
						'SPV_PendienteRespuestaOrganismo',
						'SPV_RecepcionResolucion',
						'SPV_Rectificacion',
						'SPV_EnvioRectificacion',
						'Descartado',
						'SAC_009'
					];
					this.statusValues = this.statusValues.filter(status => 
						!estadosExcluidos.includes(status.value)
					);
				}	
				// Descartado
				else if (this.caseStatus === this.statusDescartada) {
					const estadosExcluidos = [
						'SAC_002',
						'SPV_AnalisisDecision',
						'SPV_Envio',
						'SPV_PendienteRespuestaOrganismo',
						'SPV_AnalisisComplementariaOrganismo',
						'SPV_EnvioComplementaria',
						'SPV_RecepcionResolucion',
						'SPV_Rectificacion',
						'SPV_EnvioRectificacion',
						'Rechazado',
						'Cerrado',
						'SAC_009'
					];
					this.statusValues = this.statusValues.filter(status => 
						!estadosExcluidos.includes(status.value));
				}
				// Baja
				else if (this.caseStatus === this.statusBaja) {
					const estadosExcluidos = [
						'SAC_001',
						'SAC_002',
						'SPV_AnalisisDecision',
						'SPV_Envio',
						'SPV_PendienteRespuestaOrganismo',
						'SPV_AnalisisComplementariaOrganismo',
						'SPV_EnvioComplementaria',
						'SPV_RecepcionResolucion',
						'SPV_Rectificacion',
						'SPV_EnvioRectificacion',
						'Rechazado',
						'Cerrado',
						'Descartado'
					];
					this.statusValues = this.statusValues.filter(status => 
						!estadosExcluidos.includes(status.value));
					
				}
			}
			// Cerrado
			/*else if (this.caseStatus === 'Cerrado') {
				const estadosExcluidos = [
					'Rechazado',
				];

				if (this.caseMotivoComplementaria === null) {
					estadosExcluidos.push('SPV_AnalisisComplementariaOrganismo');
					estadosExcluidos.push('SPV_EnvioComplementaria');
				}
				if (this.caseRectificado === false) {
					estadosExcluidos.push('SPV_Rectificacion');
					estadosExcluidos.push('SPV_EnvioRectificacion');
				}
				this.statusValues = this.statusValues.filter(status => 
					!estadosExcluidos.includes(status.value));
				
			}*/

			
			//for (let i in this.statusValues) {
			//	if(data.fieldApiName == 'SAC_001' || data.fieldApiName == 'SAC_002' || data.fieldApiName == 'SAC_Envio' || data.fieldApiName == 'SAC_PendienteRespuestaOrganismo'){
			//		if(this.statusValues[i].label === 'SPV_AnalisisComplementariaOrganismo' || this.statusValues[i].label === 'SPV_EnvioComplementaria' || this.statusValues[i].label === 'SPV_RecepcionResolucion' || this.statusValues[i].label === 'SPV_Rectificacion' || this.statusValues[i].label === 'SPV_EnvioRectificacion' || this.statusValues[i].label === 'Descartado') {
			//			this.statusValues.splice(i, 1);
			//		}
			//	}else if(data.fieldApiName == 'Descartado'){
			//		if((this.statusValues[i].label === 'SPV_002' /*&& data.fields.SPV_EsAnalisis__c == false*/) || (this.statusValues[i].label === 'SPV_Envio' /*&& data.fields.SPV_EsEnvio__c == false*/) || (this.statusValues[i].label === 'SPV_PendienteRespuestaOrganismo' /*&& data.fields.SPV_EsPRO__c == false*/) || (this.statusValues[i].label === 'SPV_AnalisisComplementariaOrganismo' && data.fields.SPV_MotivoComplementariaOrganismo__c == null) || (this.statusValues[i].label === 'SPV_Rectificacion' && data.fields.SPV_Rectificado__c == null) || (this.statusValues[i].label === 'SPV_RecepcionResolucion' && data.fields.SPV_FechaRecepcionResolucion__c == null)) {
			//			this.statusValues.splice(i, 1);
			//		}
			//	}else if(data.fieldApiName == 'Descartado'){
			//
			//	}else{
			//
			//	}
				//if(this.statusValues[i].label === 'Negociación' && this.recordTypeName === 'SPV_Reclamacion') {
					//this.statusValues.splice(i, 1);
				//}

			//}

            //Indicar el estado seleccionado
			this.statusSeleccionado = this.caseStatus;
			this.generarProgressIndicator = true;

        }
    }

	//Recuperar los valores de la picklist subestado a través del recordtypeid del registro (recuperado con getrecord)
    /*@wire(getPicklistValues, { recordTypeId: '$record.data.recordTypeId', fieldApiName: SUBESTADO_FIELD })
    valoresPicklistSubestado({data}) {
        if (data) {
            //Recuperar data de la picklist subestado
			this.subestadosData = data;
			//Recuperar los subestados dependientes del status actual
			this.subestadosValues = this.filtrarSubestadoDependiente(this.caseStatus);
            //Indicar el subestado seleccionado
            this.subestadoSeleccionado = this.caseSubestado;
        }
    }*/

    //Getters de valores de campos
	get caseOrganismo() {
        return getFieldValue(this.record.data, ORGANISMO_FIELD);
    }
    get caseStatus() {
        return getFieldValue(this.record.data, STATUS_FIELD);
    }
	/*get caseSubestado() {
        return getFieldValue(this.record.data, SUBESTADO_FIELD);
    }*/
	get caseIsClosed() {
        return getFieldValue(this.record.data, ISCLOSED_FIELD);
    }
	get recordTypeName() {
        return getFieldValue(this.record.data, RECORDTYPENAME_FIELD);
    }

	get esPretension() {
        return this.recordTypeName == 'SPV_Pretension' ? true : false;
    }
	get caseMotivoComplementaria() {
        return getFieldValue(this.record.data, MOTIVOCOMPLEMENTARIA_FIELD);
    }
	get caseFechaRecepcionResolucion() {
        return getFieldValue(this.record.data, FECHARECEPCIONRESOLUCION_FIELD);
    }
	get caseRectificado() {
        return getFieldValue(this.record.data, RECTIFICADO_FIELD);
    }




	//Método para determinar si hay que mostrar los subestados
	haySubEstadoDisponible() {
		return this.subestadosValues.length > 0 ? true : false;
	}

    //Método para ordenar los valores de la picklist status según se necesite
    sortStatusValues(statusValues) {
        //Estados ordenados
        let sortOrder = {
            "SAC_001": 0, //Alta
            "SPV_AnalisisDecision": 1,
			"SPV_Envio": 2,
			"SPV_PendienteRespuestaOrganismo": 3,
			"SPV_AnalisisComplementariaOrganismo": 4,
			"SPV_EnvioComplementaria": 5,
			"SPV_RecepcionResolucion": 6,
			"SPV_Rectificacion": 7,
			"SPV_EnvioRectificacion": 8,
			"Descartado": 9,
			"Cerrado": 10
        };
    
        //Ordenar los valores de la picklist con el orden definido en la variable sortOrder
        let sortedValues = Array.from(statusValues).sort((a, b) => {
            return sortOrder[a.value] - sortOrder[b.value];
        });
        return sortedValues;
    }

	//Método para filtrar los subestados y mostrar únicamente los subestados dependientes de cada status
	/*filtrarSubestadoDependiente(estadoDelCaso) {
        let key = this.subestadosData.controllerValues[estadoDelCaso];
        return this.subestadosData.values.filter(opt => opt.validFor.includes(key));
    }*/

	//Método para seleccionar el status y filtrar sus respectivos subestados
	/**statusOnclick(event) {
		//this.desactivarBotonActualizar(event);

		//Ahora:
		this.seleccionadoSubestado = false;

		if (!this.caseIsClosed) {
			this.statusSeleccionado = event.currentTarget.dataset.etapaValue;
			this.subestadosValues = this.filtrarSubestadoDependiente(this.statusSeleccionado);
			//Si hay subestados disponibles para este estado, se pone el subestado seleccionado en el primer subestado disponible. Si no hay, se pone como null
			this.subestadoSeleccionado = this.subestadosValues.length > 0 ? this.subestadosValues[0].value : null;
			//Vaciar subestadoSeleccionadoOnLastClick para indicar que hay que seleccionar un sub estado
			this.subestadoSeleccionadoOnLastClick = '';
		}
	}*/
	/*
	desactivarBotonActualizar(event) {
		
		// Solamente activar el botón de actualizar estado en la pretensión cuando se rechace
		if(this.recordTypeName === 'SPV_Pretension' && event.currentTarget.dataset.etapaValue === 'Descartado') {
			const botonActualizar = this.template.querySelector('.botonActualizar');
			botonActualizar.disabled = false;
		} else if(this.recordTypeName === 'SPV_Pretension' && event.currentTarget.dataset.etapaValue !== 'Descartado') {
			const botonActualizar = this.template.querySelector('.botonActualizar');
			botonActualizar.disabled = true;
		}

		// Solamente activar el botón de actualizar estado en estado de alta de la reclamación cuando se seleccione análsis
		if(this.recordTypeName === 'SPV_Reclamacion' && this.status === 'SAC_001' && event.currentTarget.dataset.etapaValue !== 'SAC_002') {
			const botonActualizar = this.template.querySelector('.botonActualizar');
			botonActualizar.disabled = true;
		} else if(this.recordTypeName === 'SPV_Reclamacion' && this.status === 'SAC_001' && event.currentTarget.dataset.etapaValue === 'SAC_002') {
			const botonActualizar = this.template.querySelector('.botonActualizar');
			botonActualizar.disabled = false;
		}

		// Solamente activar el botón de actualizar estado en estado de análisis de la reclamación cuando se seleccione envío organismos
		if(this.recordTypeName === 'SPV_Reclamacion' && this.status === 'SAC_002' && (event.currentTarget.dataset.etapaValue !== 'SPV_EnvioOrganismos' && event.currentTarget.dataset.etapaValue !== 'SAC_002')) {
			const botonActualizar = this.template.querySelector('.botonActualizar');
			botonActualizar.disabled = true;
		} else if(this.recordTypeName === 'SPV_Reclamacion' && this.status === 'SAC_002' && (event.currentTarget.dataset.etapaValue === 'SPV_EnvioOrganismos' || event.currentTarget.dataset.etapaValue === 'SAC_002')) {
			const botonActualizar = this.template.querySelector('.botonActualizar');
			botonActualizar.disabled = false;
		}

		// Solamente activar el botón de actualizar estado en estado de análisis de la reclamación cuando se seleccione envío organismos
		if(this.recordTypeName === 'SPV_Reclamacion' && this.status === 'SPV_EnvioOrganismos' && event.currentTarget.dataset.etapaValue !== 'SPV_EnvioOrganismos') {
			const botonActualizar = this.template.querySelector('.botonActualizar');
			botonActualizar.disabled = true;
		} else if(this.recordTypeName === 'SPV_Reclamacion' && this.status === 'SPV_EnvioOrganismos' && event.currentTarget.dataset.etapaValue === 'SPV_EnvioOrganismos') {
			const botonActualizar = this.template.querySelector('.botonActualizar');
			botonActualizar.disabled = false;
		}

		// Solamente activar el botón de actualizar estado en estado de Pendiente de respuesta organismo de la reclamación cuando se seleccione cerrado
		if(this.recordTypeName === 'SPV_Reclamacion' && this.status === 'SPV_PendienteRespuestaOrganismos' && (event.currentTarget.dataset.etapaValue !== 'SPV_PendienteRespuestaOrganismos' && event.currentTarget.dataset.etapaValue !== 'Cerrado')) {
			const botonActualizar = this.template.querySelector('.botonActualizar');
			botonActualizar.disabled = true;
		} else if(this.recordTypeName === 'SPV_Reclamacion' && this.status === 'SPV_PendienteRespuestaOrganismos' && (event.currentTarget.dataset.etapaValue === 'SPV_PendienteRespuestaOrganismos' || event.currentTarget.dataset.etapaValue === 'Cerrado')) {
			const botonActualizar = this.template.querySelector('.botonActualizar');
			botonActualizar.disabled = false;
		}

		// // Solamente activar el botón de actualizar estado en estado de Rectificacion de la reclamación cuando se seleccione Envio Organismos
		if(this.recordTypeName === 'SPV_Reclamacion' && this.status === 'SPV_Rectificacion' && (event.currentTarget.dataset.etapaValue !== 'SPV_Rectificacion' && event.currentTarget.dataset.etapaValue !== 'SPV_EnvioOrganismos')) {
			const botonActualizar = this.template.querySelector('.botonActualizar');
			botonActualizar.disabled = true;
		} else if(this.recordTypeName === 'SPV_Reclamacion' && this.status === 'SPV_Rectificacion' && (event.currentTarget.dataset.etapaValue === 'SPV_Rectificacion' || event.currentTarget.dataset.etapaValue === 'SPV_EnvioOrganismos')) {
			const botonActualizar = this.template.querySelector('.botonActualizar');
			botonActualizar.disabled = false;
		}

		// Solamente activar el botón de actualizar estado en estado de cerrado cuando se selccione un subestado de cerrado
		if(this.recordTypeName === 'SPV_Reclamacion' && this.status === 'Cerrado' && event.currentTarget.dataset.etapaValue !== 'Cerrado') {
			const botonActualizar = this.template.querySelector('.botonActualizar');
			botonActualizar.disabled = true;
		} else if(this.recordTypeName === 'SPV_Reclamacion' && this.status === 'Cerrado' && event.currentTarget.dataset.etapaValue === 'Cerrado') {
			const botonActualizar = this.template.querySelector('.botonActualizar');
			botonActualizar.disabled = false;
		}

		//Cuando estás en esado de Descartar, no permitir actualizar el estado
		if(this.recordTypeName === 'SPV_Reclamacion' && this.status === 'Descartado'){
			const botonActualizar = this.template.querySelector('.botonActualizar');
			botonActualizar.disabled = true;
		}
		
	}*/

	//Método para seleccionar el subestado
	/*subestadoOnclick(event) {

		//Antes (para los subestados como ciclo de vida):
		//this.subestadoSeleccionado = event.target.value;
		//this.subestadoSeleccionadoOnLastClick = event.target.value;

		//Ahora:
		this.seleccionadoSubestado = true;
		this.subestadoSeleccionado = event.target.dataset.id;
		this.subestadoSeleccionadoOnLastClick = event.target.dataset.id;

		this.desactivarBotonActualizarSubestado();
	}*/

	/*desactivarBotonActualizarSubestado(){

		//Si esta en estado Rectificacion
		if(this.recordTypeName === 'SPV_Reclamacion' && this.status === 'SPV_Rectificacion'){

			//Si esta en subestado Analisis rectificaciom, solo podrá ir a subestados rectificar o no rectificar
			if(this.subestado === 'SPV_AnalisisRectificacion'){
				if(this.subestadoSeleccionadoOnLastClick !== 'SPV_Rectificar' && this.subestadoSeleccionadoOnLastClick !== 'SPV_No_rectificar'){
					const botonActualizar = this.template.querySelector('.botonActualizar');
					botonActualizar.disabled = true;
				}else{
					const botonActualizar = this.template.querySelector('.botonActualizar');
					botonActualizar.disabled = false;
				}
			}else if(this.subestado === 'SPV_Rectificar' || this.subestado === 'SPV_No_Rectificar'){ //Si esta en subestado Rectificar o No rectificar, podrá pasar al subestado 'Rectificación' del envio organismos
				if(this.subestadoSeleccionadoOnLastClick !== 'SPV_SubRectificacion'){
					const botonActualizar = this.template.querySelector('.botonActualizar');
					botonActualizar.disabled = true;
				}else{
					const botonActualizar = this.template.querySelector('.botonActualizar');
					botonActualizar.disabled = false;
				}
			}
			
		}
	}*/

	/*get subestadosYApecto(){

		//Por el if entra cuando recarga la página, para ver si el subestado del caso es alguno de los que hay y hay que marcarlo
		//O cuando al clickar sobre un estado, este es el actual de nuevo, asique debe mostrarse el subestado actual ya marcado
		if((this.caseSubestado != null || this.caseSubestado != '') && this.seleccionadoSubestado == false && this.caseStatus == this.statusSeleccionado){
			
			return this.subestadosValues.map(subestado => ({
				value: subestado.value,
				label: subestado.label,
				class: this.caseSubestado === subestado.value ? 'slds-button_neutral subestado_seleccionado' : 'slds-button_neutral subestado_no_seleccionado'
			}));
		}else{	//Por aquí entra cuando seleccionas un subEstado, para marcar el seleccionado y desmarcar los demás
			
			//Recorro la lista de subestados, asignandole una class a cada uno para el html
			return this.subestadosValues.map(subestado => ({
				value: subestado.value,
				label: subestado.label,
				class: this.subestadoSeleccionadoOnLastClick === subestado.value ? 'slds-button_neutral subestado_seleccionado' : 'slds-button_neutral subestado_no_seleccionado'
			}));
		}


	}*/

	/*
	botonActualizarOnclick() {
		const botonActualizar = this.template.querySelector('.botonActualizar');

		if (!this.subestadoSeleccionadoOnLastClick && this.haySubEstadoDisponible()) {
			this.mostrarToast('info', 'Es necesario seleccionar un subestado', '');
		}else if(this.statusSeleccionado == 'SAC_001' && this.status != 'SAC_002'){
			this.mostrarToast('info', 'Pasar a Alta', 'Es necesario estar en el estado de Análisis');
		} 
		else {
			botonActualizar.disabled = true;
			// Funcionalidad que recupera las pretensiones de la reclamación para poder seleccionar en el pop up aquellas que van a pasar a negociación
			if(this.subestadoSeleccionado == 'Negociacion') {
				// Llamada a la función para negociar la unipretension
                getPretensiones({idCaso: this.recordId}).then(result =>{
                    this.pretensiones = result;
					if(this.pretensiones) {
						let casos = [];
						this.pretensiones.forEach(pretensionRecuperada => {
							let pretension = {};
							pretension.Id = pretensionRecuperada.Id;
							pretension.CC_MCC_Tematica = pretensionRecuperada.CC_MCC_Tematica__r.Name;
							pretension.CC_MCC_ProdServ = pretensionRecuperada.CC_MCC_ProdServ__r.Name;
							pretension.CC_MCC_Motivo = pretensionRecuperada.CC_MCC_Motivo__r.Name;
							pretension.SEG_Detalle = pretensionRecuperada.SEG_Detalle__r.Name;
							casos.push(pretension);
						});
						this.pretensiones = casos;
						this.isModalOpenPretensiones = true;
						botonActualizar.disabled = false;
					} 
					else if (error) {
						this.error = error;
						this.pretensiones = undefined;
					}
                })
                .catch(error => {
                    this.errorMsg = error;
					botonActualizar.disabled = false;
					//Mostrar el mensaje de error en el toast
					this.mostrarToast('error', 'Fallo al obtener las pretensiones', error.body.message);
                })     
			} else if(this.statusSeleccionado == 'SAC_007') {
				this.mostrarToast('error', 'Error actualizando el estado de la pretensión', 'No se puede pasar al estado de negociación desde la pretensión, hágalo desde la reclamación.');
			} 
			else {
				
				const fields = {};
				fields[CASEID_FIELD.fieldApiName] = this.recordId;
				fields[STATUS_FIELD.fieldApiName] = this.statusSeleccionado;
				fields[SUBESTADO_FIELD.fieldApiName] = this.subestadoSeleccionado;
				const recordInput = {fields};
				updateRecord(recordInput)
				.then(() => {
					if(this.statusSeleccionado == 'SPV_Rectificacion' && (this.subestadoSeleccionado == 'SPV_Rectificar' || this.subestadoSeleccionado == 'SPV_No_rectificar')){

						if(this.subestadoSeleccionado == 'SPV_Rectificar'){
							this.mostrarRectificar = true;
							this.mostrarNoRectificar = false;
						}else if(this.subestadoSeleccionado == 'SPV_No_rectificar'){
							this.mostrarRectificar = false;
							this.mostrarNoRectificar = true;
						}

						this.mostrarPasoEnvioOrgRecti = true;
						
					}else{
						this.mostrarToast('success', 'Se actualizó el caso', 'Se actualizó correctamente el estado del caso');
					}
				})
				.catch(error => {
					//Mostrar errores
					let errorMessage = 'Error al intentar actualizar el caso';
					if (error.body && error.body.output && error.body.output.errors) {
						const errors = error.body.output.errors;
						errorMessage = errors.map(err => err.message).join(', ');
					} else if (error.body.message) {
						errorMessage = error.body.message;
					}
		
					//Mostrar el mensaje de error en el toast


					this.mostrarToast('error', 'Error actualizando el caso', errorMessage);
				}).finally(() => botonActualizar.disabled = false);
			}	
		}
	}*/

	pasoDeRectEnvioOrg(){
		this.isLoading = true;
		this.mostrarPasoEnvioOrgRecti = false;
		let nuevoEstado = 'SPV_EnvioOrganismos';
		let nuevoSubestado = 'SPV_SubRectificacion';
		pasarFaseEnvioOrgRectificacion({'idCaso': this.recordId, 'nuevoEstado': nuevoEstado, 'nuevoSubestado': nuevoSubestado}).then(() => {
			this.isLoading = false;
			this.refreshView();
			this.seleccionadoSubestado = false;
			this.subestadoSeleccionado = 'SPV_SubRectificacion';
			this.mostrarToast('success', 'Se actualizó el caso', 'Se actualizó correctamente el estado del caso');
		})
		.catch(error => {
			this.errorMsg = error;
			// botonActualizar.disabled = false;
			//Mostrar el mensaje de error en el toast
			this.mostrarToast('error', 'Fallo al pasar la reclamación a estado Envio Organismos', error.body.message);
		})     
	}

	//Método para mostrar un toast con los parametros introducidos
	mostrarToast(variant, title, message) {
		this.dispatchEvent(new ShowToastEvent({variant: variant, title: title, message: message, mode: 'dismissable', duration: 4000}));
	}

	refreshView() {
        this.dispatchEvent(new RefreshEvent());
    }

	handleRowSelection() {
	var selectedRecords =  this.template.querySelector("lightning-datatable").getSelectedRows();
		if(selectedRecords.length > 0){
			this.mostrarBoton = false;
			this.lstSelectedRecords = selectedRecords;
		} else {
			this.mostrarBoton = true;
		}  
	}

	closeModalPretensiones(){
        this.isModalOpenPretensiones = false;
		this.mostrarBoton = true;
		const botonActualizar = this.template.querySelector('.botonActualizar');
		botonActualizar.disabled = false;
    }

	negociarPretensiones() {
        this.isLoading = true;

		pasarFaseNegociacion({idCaso: this.recordId, estado: this.statusSeleccionado, pretensionesNegociacion: this.lstSelectedRecords}).then(result =>{
            this.isLoading = false;
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Estado actualizado',
                    message: 'Se ha pasado a la fase de negociación',
                    variant: 'success'
                })
            );
            
            this.dispatchEvent(new RefreshEvent());
            this.isModalOpenPretensiones = false;
        })
        .catch(error => {
            this.isLoading = false;
            this.isModalOpenPretensiones = false;
            this.errorMsg = error;

            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Fallo al actualizar',
                    message: error.body.message,
                    variant: 'error'
                })
            );
        }) 
    }
}