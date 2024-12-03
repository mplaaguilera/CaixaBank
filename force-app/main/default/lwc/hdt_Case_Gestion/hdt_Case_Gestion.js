import {LightningElement, api, wire} from 'lwc';
import {getRecord, getFieldValue} from 'lightning/uiRecordApi';
import {ShowToastEvent} from 'lightning/platformShowToastEvent';

//Apex
import validarGuardar from '@salesforce/apex/HDT_Clasificacion_Casos_Controller.validarGuardar';
import getProductos from '@salesforce/apex/HDT_Clasificacion_Casos_Controller.getProductos';
import getSoluciones from '@salesforce/apex/HDT_Clasificacion_Casos_Controller.getSoluciones';
import getMotivos from '@salesforce/apex/HDT_Clasificacion_Casos_Controller.getMotivos';
import getCampanas from '@salesforce/apex/HDT_Clasificacion_Casos_Controller.getCampanas';
import getCausas from '@salesforce/apex/HDT_Clasificacion_Casos_Controller.getCausas';
import getErroresTf7 from '@salesforce/apex/HDT_Clasificacion_Casos_Controller.getErroresTf7';
import crearActividadRetipificacion from '@salesforce/apex/HDT_Clasificacion_Casos_Controller.crearActividadRetipificacion';
import reabrirTareaTrasladoColaborador from '@salesforce/apex/HDT_Clasificacion_Casos_Controller.reabrirTareaTrasladoColaborador';
import cerrarActividadSolicitudInformacion from '@salesforce/apex/HDT_Clasificacion_Casos_Controller.cerrarActividadSolicitudInformacion';
import clasificacionRapida from '@salesforce/apex/HDT_Clasificacion_Casos_Controller.clasificacionRapida';
import getTematicas from '@salesforce/apex/HDT_Clasificacion_Casos_Controller.getTematicas';
import actividadesTrasladoColaborador from '@salesforce/apex/HDT_Clasificacion_Casos_Controller.actividadesTrasladoColaborador';

//Campos
import STATUS from '@salesforce/schema/Case.Status';
import RECORDTYPE_NAME from '@salesforce/schema/Case.RecordType.Name';
import RECORDTYPE_DEVELOPERNAME from '@salesforce/schema/Case.RecordType.DeveloperName';
import ISCLOSED from '@salesforce/schema/Case.IsClosed';
import TERCER_NIVEL from '@salesforce/schema/Case.CC_En_Tercer_Nivel__c';
import ORIGIN from '@salesforce/schema/Case.Origin';
import CANAL_RESOLUCION from '@salesforce/schema/Case.CC_Canal_Resolucion__c';
import CANAL_PROCEDENCIA from '@salesforce/schema/Case.CC_Canal_Procedencia__c';
import TEMATICA from '@salesforce/schema/Case.CC_MCC_Tematica__c';
import TEMATICA_NAME from '@salesforce/schema/Case.CC_MCC_Tematica__r.Name';
import PRODSERV from '@salesforce/schema/Case.CC_MCC_ProdServ__c';
import PRODSERV_NAME from '@salesforce/schema/Case.CC_MCC_ProdServ__r.Name';
import MOTIVO from '@salesforce/schema/Case.CC_MCC_Motivo__c';
import MOTIVO_NAME from '@salesforce/schema/Case.CC_MCC_Motivo__r.Name';
import CAUSA from '@salesforce/schema/Case.CC_MCC_Causa__c';
import CAUSA_NAME from '@salesforce/schema/Case.CC_MCC_Causa__r.Name';
import SOLUCION from '@salesforce/schema/Case.CC_MCC_Solucion__c';
import SOLUCION_NAME from '@salesforce/schema/Case.CC_MCC_Solucion__r.Name';
import CAMPANA from '@salesforce/schema/Case.CC_Campana__c';
import CAMPANA_NAME from '@salesforce/schema/Case.CC_Campana__r.Name';
import CASENUMBER from '@salesforce/schema/Case.CaseNumber';
import GRUPO3N from '@salesforce/schema/Case.CC_Grupo_3N__c';
import CANAL_EMPLEADO from '@salesforce/schema/Case.Canal_del_Empleado__c';
import NO_IDENTIFICADO from '@salesforce/schema/Case.CC_No_Identificado__c';
import CONTACT_ID from '@salesforce/schema/Case.ContactId';
import ERROR_TF7 from '@salesforce/schema/Case.CC_Error_TF7__c';

const CAMPOS_CASO = [
	RECORDTYPE_NAME, RECORDTYPE_DEVELOPERNAME, ISCLOSED, TERCER_NIVEL, ORIGIN,
	CANAL_RESOLUCION, CANAL_PROCEDENCIA, STATUS, TEMATICA, TEMATICA_NAME,
	PRODSERV, PRODSERV_NAME, MOTIVO, MOTIVO_NAME, CAUSA, CAUSA_NAME, SOLUCION,
	SOLUCION_NAME, CAMPANA, CAMPANA_NAME, CASENUMBER, GRUPO3N, CANAL_EMPLEADO,
	CANAL_EMPLEADO, NO_IDENTIFICADO, CONTACT_ID, ERROR_TF7
];

//eslint-disable-next-line camelcase
export default class hdt_Case_Gestion extends LightningElement {

	@api recordId;

	caso;

	casoOrigen;

	opcionesCanalOperativo;

	opcionesTematicas;

	opcionesProductos;

	opcionesMotivos;

	opcionesCausas;

	opcionesSoluciones;

	opcionesCampanas;

	opcionesErrores;

	opcionesMccCargadas = {
		canalesOperativos: false,
		tematicas: false,
		productos: false,
		motivos: false,
		causas: false,
		soluciones: false,
		campanas: false,
		erroresTf7: false
	};

	comboboxesInformados = {
		canalOperativo: false,
		tematica: false,
		producto: false,
		motivo: false,
		causa: false,
		solucion: false,
		campaña: false
	};

	tematicaAnterior;

	productoAnterior;

	motivoAnterior;

	retipificar = false;

	cerrarCaso = false;

	guardando = false;

	casoCerrado = false;

	casoPromoCaixa = false;

	cambiarEstadoActivo = false;

	caseOriginPropuestasMejora = false;

	caseOriginFAQ = false;

	errorTf7;

	cambiarEstadoPendienteColaboradorChecked = false;

	get caseOriginNoPropuestasMejora() {
		return !this.caseOriginPropuestasMejora;
	}

	get disabled1() {
		return this.casoCerrado || this.guardando;
	}

	get disabled2() {
		return this.casoCerrado || this.guardando || getFieldValue(this.caso, TERCER_NIVEL);
	}

	get disabled3() {
		return this.guardando || this.casoCerrado || getFieldValue(this.caso, CANAL_RESOLUCION) !== 'Clases Pasivas' && getFieldValue(this.caso, CANAL_RESOLUCION) !== 'RRHH';
	}

	get disabled4() {
		return this.casoCerrado || this.guardando || !this.comboboxesInformados.causa;
	}

	get disabled5() {
		return this.casoCerrado || this.guardando || !this.comboboxesInformados.motivo;
	}

	get disabled7() {
		return this.casoCerrado || this.guardando || !this.comboboxesInformados.tematica;
	}

	get disabled8() {
		return this.casoCerrado || this.guardando || !this.comboboxesInformados.producto;
	}

	get disabled9() {
		return this.guardando || this.casoCerrado || this.casoPromoCaixa && getFieldValue(this.caso, TERCER_NIVEL);
	}

	get disabled10() {
		return this.casoCerrado || this.cambiarEstadoPendienteColaboradorChecked || this.guardando;
	}

	get variantGuardar() {
		return this.cambiarEstadoPendienteColaboradorChecked ? 'destructive-text' : 'neutral';
	}

	@wire(getRecord, {recordId: '$recordId', fields: CAMPOS_CASO})
	wiredRecord({error, data}) {
		if (error) {
			this.mostrarToast('error', 'Problema recuperando los datos del caso', JSON.stringify(error));
		} else if (data) {
			this.caso = data;
			this.casoCerrado = getFieldValue(data, ISCLOSED);
			this.caseOriginPropuestasMejora = getFieldValue(data, ORIGIN) === 'Propuestas de mejora';
			this.caseOriginFAQ = getFieldValue(data, ORIGIN) === 'FAQ';
			this.template.querySelector('[data-id="cambiarEstadoActivo"]').disabled = getFieldValue(data, STATUS) !== 'Pendiente Cliente';

			if (getFieldValue(data, TEMATICA)) {
				if (!this.opcionesMccCargadas.tematicas) {
					this.opcionesTematicas = [{value: getFieldValue(data, TEMATICA), label: getFieldValue(data, TEMATICA_NAME)}];
				}
				this.template.querySelector('[data-id="selectItemTematica"]').value = getFieldValue(data, TEMATICA);
				this.comboboxesInformados.tematica = true;
			}
			if (getFieldValue(this.caso, PRODSERV)) {
				if (!this.opcionesMccCargadas.productos) {
					this.opcionesProductos = [{value: getFieldValue(data, PRODSERV), label: getFieldValue(data, PRODSERV_NAME)}];
				}
				this.template.querySelector('[data-id="selectItemProducto"]').value = getFieldValue(data, PRODSERV);
				this.comboboxesInformados.producto = true;
			}
			if (getFieldValue(data, MOTIVO)) {
				if (!this.opcionesMccCargadas.motivos) {
					this.opcionesMotivos = [{value: getFieldValue(data, MOTIVO), label: getFieldValue(data, MOTIVO_NAME)}];
				}
				this.template.querySelector('[data-id="selectItemMotivo"]').value = getFieldValue(data, MOTIVO);
				this.comboboxesInformados.motivo = true;
			}
			if (getFieldValue(data, CAUSA)) {
				if (!this.opcionesMccCargadas.causas) {
					this.opcionesCausas = [{value: getFieldValue(data, CAUSA), label: getFieldValue(data, CAUSA_NAME)}];
				}
				this.template.querySelector('[data-id="selectItemCausa"]').value = getFieldValue(data, CAUSA);
				this.comboboxesInformados.causa = true;
			} else {
				this.opcionesCausas = [];
				this.template.querySelector('[data-id="selectItemCausa"]').value = null;
				this.comboboxesInformados.causa = false;
				this.opcionesMccCargadas.causas = false;
			}
			if (getFieldValue(data, SOLUCION)) {
				if (!this.opcionesMccCargadas.soluciones) {
					this.opcionesSoluciones = [{value: getFieldValue(data, SOLUCION), label: getFieldValue(data, SOLUCION_NAME)}];
				}
				this.template.querySelector('[data-id="selectItemSolucion"]').value = getFieldValue(data, SOLUCION);
				this.comboboxesInformados.solucion = true;
			} else {
				this.opcionesSoluciones = [];
				this.template.querySelector('[data-id="selectItemSolucion"]').value = null;
				this.comboboxesInformados.solucion = false;
				this.opcionesMccCargadas.soluciones = false;
			}
			if (getFieldValue(data, CAMPANA)) {
				if (!this.opcionesMccCargadas.campanas) {
					this.opcionesCampanas = [{value: getFieldValue(data, CAMPANA), label: getFieldValue(data, CAMPANA_NAME)}];
				}
				this.template.querySelector('[data-id="selectItemCampana"]').value = getFieldValue(data, CAMPANA);
				this.comboboxesInformados.campaña = true;
			}
			if (getFieldValue(data, ERROR_TF7)) {
				if (!this.opcionesMccCargadas.erroresTf7) {
					this.opcionesErrores = [{value: getFieldValue(data, ERROR_TF7), label: getFieldValue(data, ERROR_TF7)}];
				}
				this.errorTf7 = getFieldValue(data, ERROR_TF7);
			}
			this.tieneActividadesTrasladoColaborador();
		}
	}

	tieneActividadesTrasladoColaborador() {
		if (getFieldValue(this.caso, STATUS) !== 'Activo') {
			this.template.querySelector('[data-id="cambiarEstadoPendienteColaborador"]').disabled = true;
		} else {
			actividadesTrasladoColaborador({recordId: this.recordId})
			.then(tieneActividades => this.template.querySelector('[data-id="cambiarEstadoPendienteColaborador"]').disabled = !tieneActividades);
		}
	}

	mccClasificacionRapida() {
		let detallesConsulta = this.template.querySelector('[data-id="CC_Detalles_Consulta__c"]').value;
		const tipoContacto = this.template.querySelector('[data-id="CC_Tipo_Contacto__c"]').value;
		const selectItemMotivo = this.template.querySelector('[data-id="selectItemMotivo"]').value;

		if (selectItemMotivo !== '' && tipoContacto === 'Incidencia') {
			clasificacionRapida({motivoId: getFieldValue(this.caso, RECORDTYPE_DEVELOPERNAME)})
			.then(result => {
				let retorno = result;
				if (retorno !== '') {
					if (detallesConsulta) {
						if (!detallesConsulta.includes(retorno)) {
							detallesConsulta = detallesConsulta + ' ' + retorno;
						}
					} else {
						detallesConsulta = retorno;
					}
				}
			});
		}
	}

	funcionesMotivo() {
		this.handleMotivoSeleccionado();
		this.mccClasificacionRapida();
	}

	comboboxTematicasFocus() {
		if (!this.opcionesMccCargadas.tematicas) {
			this.getOptionsTematicas();
		}
	}

	handleTematicaSeleccionada() {
		this.template.querySelector('[data-id="selectItemProducto"]').value = null;
		this.template.querySelector('[data-id="selectItemMotivo"]').value = null;
		this.template.querySelector('[data-id="selectItemCausa"]').value = null;
		this.template.querySelector('[data-id="selectItemSolucion"]').value = null;

		this.opcionesProductos = [];
		this.opcionesMotivos = [];
		this.opcionesCausas = [];
		this.opcionesSoluciones = [];

		this.comboboxesInformados.tematica = true;
		this.comboboxesInformados.producto = false;
		this.comboboxesInformados.motivo = false;
		this.comboboxesInformados.causa = false;
		this.comboboxesInformados.solucion = false;
		this.opcionesMccCargadas.productos = false;

		this.getOptionsProductos();
	}

	comboboxProductosFocus() {
		if (!this.opcionesMccCargadas.productos) {
			this.getOptionsProductos();
		}
	}

	handleProductoSeleccionado() {
		this.opcionesMotivos = null;
		this.opcionesCausas = null;
		this.opcionesSoluciones = null;

		this.template.querySelector('[data-id="selectItemMotivo"]').value = null;
		this.template.querySelector('[data-id="selectItemCausa"]').value = null;
		this.template.querySelector('[data-id="selectItemSolucion"]').value = null;

		this.comboboxesInformados.producto = true;
		this.comboboxesInformados.motivo = false;
		this.comboboxesInformados.causa = false;
		this.comboboxesInformados.solucion = false;
		this.opcionesMccCargadas.motivos = false;

		this.getOptionsMotivos();
	}

	comboboxMotivosFocus() {
		if (!this.opcionesMccCargadas.motivos) {
			this.getOptionsMotivos();
		}
	}

	handleMotivoSeleccionado() {
		this.opcionesCausas = null;
		this.opcionesSoluciones = null;
		this.template.querySelector('[data-id="selectItemCausa"]').value = null;
		this.template.querySelector('[data-id="selectItemSolucion"]').value = null;
		this.comboboxesInformados.motivo = true;
		this.comboboxesInformados.causa = false;
		this.comboboxesInformados.solucion = false;
		this.opcionesMccCargadas.causas = false;
		this.getOptionsCausas();
	}

	comboboxCausasFocus() {
		if (!this.opcionesMccCargadas.causas) {
			this.getOptionsCausas();
		}
	}

	handleCausaSeleccionada() {
		this.opcionesSoluciones = null;
		this.comboboxesInformados.causa = true;
		this.comboboxesInformados.solucion = false;
		this.opcionesMccCargadas.soluciones = false;

		this.template.querySelector('[data-id="selectItemSolucion"]').value = null;
		this.getOptionsSoluciones();
	}

	comboboxSolucionesFocus() {
		if (!this.opcionesMccCargadas.soluciones) {
			this.getOptionsSoluciones();
		}
	}

	comboboxCampanasFocus() {
		if (!this.opcionesMccCargadas.campanas) {
			this.getOptionsCampanas();
		}
	}

	comboboxErroresTF7Focus() {
		if (!this.opcionesMccCargadas.erroresTf7) {
			this.getOptionsErroresTf7();
		}
	}

	gestionaGuardarCerrar(event) {
		this.cerrarCaso = event.currentTarget.dataset.id === 'submitGuardarCerrar';
		if (this.cerrarCaso) {
			//Validaciones locales de campos obligatorios para el cierre
			let camposObligatoriosNoInformados = ['\n'];

			if (getFieldValue(this.caso, ORIGIN).includes('Propuestas de mejora') || getFieldValue(this.caso, ORIGIN).includes('Chat')
			&& !this.template.querySelector('[data-id="CC_Detalles_Consulta__c"]').value) { //Comentar la condicion en la daily
				camposObligatoriosNoInformados.push('Detalles consulta');
			}

			if (!getFieldValue(this.caso, ORIGIN).includes('Propuestas de mejora') && !getFieldValue(this.caso, ORIGIN).includes('Email - Revisar')) {
				if (!this.template.querySelector('[data-id="CC_Tipo_Contacto__c"]').value) {
					camposObligatoriosNoInformados.push('Tipo de contacto');
				}
				if (!this.template.querySelector('[data-id="selectItemTematica"]').value) {
					camposObligatoriosNoInformados.push('Temática');
				}
				if (!this.template.querySelector('[data-id="selectItemProducto"]').value) {
					camposObligatoriosNoInformados.push('Producto/Servicio');
				}
				if (!this.template.querySelector('[data-id="selectItemMotivo"]').value) {
					camposObligatoriosNoInformados.push('Motivo');
				}
				if (!this.template.querySelector('[data-id="selectItemCausa"]').value) {
					camposObligatoriosNoInformados.push('Causa');
				}
				if (!this.template.querySelector('[data-id="selectItemCausa"]').value) {
					camposObligatoriosNoInformados.push('Solución');
				}
				if (!this.template.querySelector('[data-id="CC_Idioma__c"]').value) {
					camposObligatoriosNoInformados.push('Idioma');
				}
				if(!this.template.querySelector('[data-id="HDT_Tipo_de_Cierre__c"]').value){
					camposObligatoriosNoInformados.push('Tipo de Cierre');
				}
			}

			if (getFieldValue(this.caso, CANAL_EMPLEADO) !== 'Hidden'
			&& !getFieldValue(this.caso, NO_IDENTIFICADO)
			&& !getFieldValue(this.caso, CONTACT_ID)) {
				camposObligatoriosNoInformados.push('Cuenta y contacto');
			}

			if (camposObligatoriosNoInformados.length > 1) {
				this.mostrarToast('info', 'Campos obligatorios', 'Es necesario que informes Los siguientes campos antes de cerrar el caso:' + camposObligatoriosNoInformados.join('\n\u00a0\u00a0\u00a0\u00a0\u00a0·\u00a0\u00a0'));
				return;
			}
		}

		this.guardando = true;

		//Validaciones en servidor
		let recordId = this.recordId;
		let nuevoCanalRespuesta = getFieldValue(this.caso, ORIGIN) !== 'Propuestas de mejora' ? this.template.querySelector('[data-id="modificarResp"]').value : null;
		let nuevoCanalOperativo = null;
		let nuevaTematica = this.template.querySelector('[data-id="selectItemTematica"]').value;
		let nuevoProducto = this.template.querySelector('[data-id="selectItemProducto"]').value;
		let nuevoMotivo = this.template.querySelector('[data-id="selectItemMotivo"]').value;
		validarGuardar({
			recordId: recordId,
			nuevoCanalRespuesta: nuevoCanalRespuesta,
			nuevoCanalOperativo: nuevoCanalOperativo,
			nuevaTematica: nuevaTematica,
			nuevoProducto: nuevoProducto,
			nuevoMotivo: nuevoMotivo
		}).then(result => {
			//Se guarda la clasificación anterior para poder registrar la
			//actividad de reclasificación en el recordEditFormOnSuccess
			let retorno = result;
			this.retipificar = retorno.retipificar;
			this.tematicaAnterior = retorno.tematicaAnteriorName;
			this.productoAnterior = retorno.productoAnteriorName;
			this.motivoAnterior = retorno.motivoAnteriorName;

			let idTematica = this.template.querySelector('[data-id="selectItemTematica"]').value;
			let idProducto = this.template.querySelector('[data-id="selectItemProducto"]').value;
			let idMotivo = this.template.querySelector('[data-id="selectItemMotivo"]').value;
			let idCausa = this.template.querySelector('[data-id="selectItemCausa"]').value;
			let idSolucion = this.template.querySelector('[data-id="selectItemSolucion"]').value;

			this.template.querySelector('[data-id="tematicaSeleccionadaOculto"]').value = idTematica ? idTematica : null;
			this.template.querySelector('[data-id="productoSeleccionadoOculto"]').value = idProducto ? idProducto : null;
			this.template.querySelector('[data-id="motivoSeleccionadoOculto"]').value = idMotivo ? idMotivo : null;
			this.template.querySelector('[data-id="causaSeleccionadaOculto"]').value = idCausa ? idCausa : null;
			this.template.querySelector('[data-id="solucionSeleccionadaOculto"]').value = idSolucion ? idSolucion : null;
			this.template.querySelector('[data-id="campanaSeleccionadaOculto"]').value = this.template.querySelector('[data-id="selectItemCampana"]').value;
			this.template.querySelector('[data-id="errorTerminalSeleccionadoOculto"]').value = this.template.querySelector('[data-id="selectItemErroresTF7"]').value;

			if (this.cerrarCaso) {
				this.template.querySelector('[data-id="tematicaInternaSeleccionadaOculto"]').value = idTematica ? this.opcionesTematicas.find(t => t.value === idTematica).label : null;
				this.template.querySelector('[data-id="productoInternoSeleccionadaOculto"]').value = idProducto ? this.opcionesProductos.find(t => t.value === idProducto).label : null;
				this.template.querySelector('[data-id="motivoInternoSeleccionadaOculto"]').value = idMotivo ? this.opcionesMotivos.find(t => t.value === idMotivo).label : null;
				this.template.querySelector('[data-id="causaInternaSeleccionadaOculto"]').value = idCausa ? this.opcionesCausas.find(t => t.value === idCausa).label : null;
				this.template.querySelector('[data-id="solucionInternaSeleccionadaOculto"]').value = idSolucion ? this.opcionesSoluciones.find(t => t.value === idSolucion).label : null;
				let today = new Date();
				this.template.querySelector('[data-id="cerradoOperativa"]').value = today.toISOString();
				this.template.querySelector('[data-id="estado"]').value = 'Cerrado';
			} else if (this.template.querySelector('[data-id="cambiarEstadoPendienteColaborador"]').checked) {
				this.template.querySelector('[data-id="estado"]').value = 'Pendiente Colaborador';
			} else {
				this.template.querySelector('[data-id="estado"]').value = getFieldValue(this.caso, STATUS);
			}
			this.template.querySelector('[data-id="recordEditForm"]').submit();

		}).catch(error => {
			//Se muestra un Toast de error y no se sigue adelante con el update de la recordEditForm
			this.mostrarToast('error', 'No se pudo actualizar Caso', error);
			this.guardando = false;
		});
	}

	recordEditFormOnSuccess() {
		this.guardando = false;

		if (this.cerrarCaso) {
			this.mostrarToast('success', 'Se cerró Caso', 'Se cerró correctamente el caso ' + getFieldValue(this.caso, CASENUMBER));
			this.cerrarCaso = false;
		} else {
			this.mostrarToast('success', 'Se actualizó Caso', 'Se actualizaron correctamente los datos del caso ' + getFieldValue(this.caso, CASENUMBER));
		}

		//Si se ha modificado la clasificación se crea la actividad de retipificación
		crearActividadRetipificacion({
			recordId: this.recordId,
			tematicaAnterior: this.tematicaAnterior,
			productoAnterior: this.productoAnterior,
			motivoAnterior: this.motivoAnterior
		});

		this.retipificar = false;

		//Casilla "Cambiar estado a Pendiente Colaborador" marcada
		let cambiarEstadoPendienteColaborador = this.template.querySelector('[data-id="cambiarEstadoPendienteColaborador"]');
		if (cambiarEstadoPendienteColaborador.checked) {
			reabrirTareaTrasladoColaborador({recordId: this.recordId})
			.then(() => cambiarEstadoPendienteColaborador.checked = false);
		}

		//Casilla "Cambiar estado a Activo" marcada, ejecuta el proceso para cerrar las actividades de solicitud informacion
		let cambiarEstadoActivo = this.template.querySelector('[data-id="cambiarEstadoActivo"]');
		if (cambiarEstadoActivo.checked) {
			cerrarActividadSolicitudInformacion({recordId: this.recordId})
			.then(() => this.cambiarEstadoActivo.checked = false);
		}
	}

	recordEditFormOnError(event) {
		this.guardando = false;
		this.cerrarCaso = false;
		this.mostrarToast('error', 'Error actualizando Caso', event.detail.detail);
	}

	getOptionsTematicas() {
		let selectItemTematica = this.template.querySelector('[data-id="selectItemTematica"]');
		selectItemTematica.spinnerActive = true;
		getTematicas({})
		.then(result => {
			this.opcionesTematicas = result;
			this.opcionesMccCargadas.tematicas = true;
			selectItemTematica.spinnerActive = false;

			if (result.length === 1) {
				selectItemTematica.value = this.opcionesTematicas[0].value;
				this.handleTematicaSeleccionada();
			}
		});
	}

	getOptionsProductos() {
		
		let tematica = this.template.querySelector('[data-id="selectItemTematica"]').value;
		let selectItemProducto = this.template.querySelector('[data-id="selectItemProducto"]');
		selectItemProducto.spinnerActive = true;
		getProductos({tematica: tematica})
		.then(productos => {
			this.opcionesProductos = productos;
			this.opcionesMccCargadas.productos = true;
			selectItemProducto.spinnerActive = false;
			if (productos.length === 1) {
				selectItemProducto.value = this.opcionesProductos[0].value;
				this.handleProductoSeleccionado();
			}
		});
	}

	getOptionsMotivos() {
		let producto = this.template.querySelector('[data-id="selectItemProducto"]').value;
		let selectItemMotivo = this.template.querySelector('[data-id="selectItemMotivo"]');
		selectItemMotivo.spinnerActive = true;
		getMotivos({producto: producto})
		.then(motivos => {
			this.opcionesMotivos = motivos;
			this.opcionesMccCargadas.motivos = true;
			selectItemMotivo.spinnerActive = false;

			if (motivos.length === 1) {
				selectItemMotivo.value = this.opcionesMotivos[0].value;
				this.handleMotivoSeleccionado();
			}
		});
	}

	getOptionsCausas() {
		let motivo = this.template.querySelector('[data-id="selectItemMotivo"]').value;
		let selectItemCausa = this.template.querySelector('[data-id="selectItemCausa"]');
		selectItemCausa.spinnerActive = true;
		getCausas({
			motivo: motivo
		})
		.then(result => {
			this.opcionesCausas = result;
			this.opcionesMccCargadas.causas = true;
			selectItemCausa.spinnerActive = false;
			if (result.length === 1) {
				this.template.querySelector('[data-id="selectItemCausa"]').value = this.opcionesCausas[0].value;
				this.handleCausaSeleccionada();
			}
		});
	}

	getOptionsSoluciones() {
		let causa = this.template.querySelector('[data-id="selectItemCausa"]').value;
		let selectItemSolucion = this.template.querySelector('[data-id="selectItemSolucion"]');
		selectItemSolucion.spinnerActive = true;
		getSoluciones({
			causa: causa
		})
		.then(result => {
			this.opcionesSoluciones = result;
			this.opcionesMccCargadas.soluciones = true;
			selectItemSolucion.spinnerActive = false;
			if (result.length === 1) {
				this.template.querySelector('[data-id="selectItemSolucion"]').value = this.opcionesSoluciones[0].value;
			}
		});
	}

	getOptionsCampanas() {
		let selectItemCampana = this.template.querySelector('[data-id="selectItemCampana"]');
		selectItemCampana.spinnerActive = true;
		getCampanas({})
		.then(result => {
			this.opcionesCampanas = result;
			this.opcionesMccCargadas.campanas = true;
			selectItemCampana.spinnerActive = false;
		});
	}

	getOptionsErroresTf7() {
		let selectItemErroresTF7 = this.template.querySelector('[data-id="selectItemErroresTF7"]');
		selectItemErroresTF7.spinnerActive = true;
		getErroresTf7({})
		.then(result => {
			this.opcionesErrores = result;
			this.opcionesMccCargadas.erroresTf7 = true;
			selectItemErroresTF7.spinnerActive = false;
		});
	}

	mostrarToast(tipo, titulo, mensaje) {
		this.dispatchEvent(new ShowToastEvent({variant: tipo, title: titulo, message: mensaje, mode: 'dismissable', duration: 4000}));
	}

	cambiarEstadoPendienteColaboradorOnchange(event) {
		this.cambiarEstadoPendienteColaboradorChecked = event.detail.checked;
	}
}