import {LightningElement, api, track, wire} from 'lwc';
//import {refreshApex} from '@salesforce/apex';
import {updateRecord, getRecord, getFieldValue} from 'lightning/uiRecordApi';
import {ShowToastEvent} from 'lightning/platformShowToastEvent';
import {NavigationMixin} from 'lightning/navigation';
import currentUserId from '@salesforce/user/Id';

//import datosCaso from '@salesforce/apex/HDT_EmailSendController.datosCaso';
import buscarColaborador from '@salesforce/apex/HDT_EmailSendController.buscarColaborador';
import obtenerEmailFromHDT from '@salesforce/apex/HDT_EmailSendController.obtenerEmailFromHDT';
import hdtgetCustomPermissions from '@salesforce/apex/HDT_EmailSendController.hdtgetCustomPermissions';
import validarCamposCaso from '@salesforce/apex/HDT_EmailSendController.validarCamposCaso';
import getMCCGrupoList from '@salesforce/apex/HDT_EmailSendController.getMCCGrupoList';
//import validarCanalAutenticacion from '@salesforce/apex/HDT_EmailSendController.validarCanalAutenticacion';
import recuperaMailEmpleado from '@salesforce/apex/HDT_EmailSendController.recuperaMailEmpleado';
import crearTaskWebCollab from '@salesforce/apex/HDT_EmailSendController.crearTaskWebCollab';
import updateTaskWebCollab from '@salesforce/apex/HDT_EmailSendController.updateTaskWebCollab';
import vaciarPlantilla from '@salesforce/apex/HDT_EmailSendController.vaciarPlantilla';
import cambiarPropietario from '@salesforce/apex/HDT_EmailSendController.cambiarPropietario';
import getPlantillaGrupoList from '@salesforce/apex/HDT_EmailSendController.getPlantillaGrupoList';
import buscarGruposColaboradores from '@salesforce/apex/HDT_EmailSendController.buscarGruposColaboradores';
import buscarPlantillasResponder from '@salesforce/apex/HDT_EmailSendController.buscarPlantillasResponder';
import actualizarCaso from '@salesforce/apex/HDT_EmailSendController.actualizarCaso';
import guardaTipoGestion from '@salesforce/apex/HDT_EmailSendController.guardaTipoGestion';
import buscarColaboradorGestor from '@salesforce/apex/HDT_EmailSendController.buscarColaboradorGestor';
//import obtenerHorasDisponiblidadGestor from '@salesforce/apex/HDT_EmailSendController.obtenerHorasDisponiblidadGestor';
import getPlantillasResponder from '@salesforce/apex/HDT_EmailSendController.getPlantillasResponder';
import buscarCorreoContacto from '@salesforce/apex/HDT_EmailSendController.buscarCorreoContacto';
import existeCarpeta from '@salesforce/apex/HDT_EmailSendController.existeCarpeta';
import getCarpetas from '@salesforce/apex/HDT_EmailSendController.getCarpetas';
//import obtenerFechasDisponiblidadGestor from '@salesforce/apex/HDT_EmailSendController.obtenerFechasDisponiblidadGestor';
//import autoasignarmeCaso from '@salesforce/apex/HDT_EmailSendController.autoasignarmeCaso';
import esClienteDigital from '@salesforce/apex/HDT_EmailSendController.esClienteDigital';
import buscarGrupos3N from '@salesforce/apex/HDT_EmailSendController.buscarGrupos3N';
import devolver from '@salesforce/apex/HDT_EmailSendController.devolver';
import vincularLlamada from '@salesforce/apex/HDT_EmailSendController.vincularLlamadaEnCurso';



//Campos
import CASE_ID from '@salesforce/schema/Case.Id';
import CASE_DETALLES_CONSULTA from '@salesforce/schema/Case.CC_Detalles_Consulta__c';
import CASE_RECORDTYPE from '@salesforce/schema/Case.RecordTypeId';
import CASE_RECORDTYPE_DEVELOPER_NAME from '@salesforce/schema/Case.RecordType.DeveloperName';
import CASE_CONTACT from '@salesforce/schema/Case.ContactId';
import CASE_ACCOUNT from '@salesforce/schema/Case.AccountId';
import CASE_ACCOUNT_RECORTYPE_DEVELOPER_NAME from '@salesforce/schema/Case.Account.RecordType.DeveloperName';
import CASE_ACCOUNT_MARCA_SENIOR from '@salesforce/schema/Case.Account.CC_Marca_senior__c';
import CASE_TIPO_CLIENTE from '@salesforce/schema/Case.CC_Tipo_Cliente__c';
import CASE_CANAL_PROCEDENCIA from '@salesforce/schema/Case.CC_Canal_Procedencia__c';
import CASE_CONTACT_PHONE from '@salesforce/schema/Case.Contact.Phone';
import CASE_TIPO_CLIENTE_FORMULA from '@salesforce/schema/Case.CC_Tipo_Cliente_Formula__c';
import CASE_ORIGIN from '@salesforce/schema/Case.Origin';
import CASE_STATUS from '@salesforce/schema/Case.Status';
import CASE_SUBJECT from '@salesforce/schema/Case.Subject';
import CASE_CREATE_DATE from '@salesforce/schema/Case.CreatedDate';
import CASE_IDIOMA from '@salesforce/schema/Case.CC_Idioma__c';
import CASE_CANAL_RESPUESTA from '@salesforce/schema/Case.CC_Canal_Respuesta__c';
import CASE_OWNER from '@salesforce/schema/Case.OwnerId';
import CASE_GRUPO_3N from '@salesforce/schema/Case.CC_Grupo_3N__c';
import CASE_CC_NO_IDENTIFICADO from '@salesforce/schema/Case.CC_No_Identificado__c';
import CASE_CC_EN_TERCER_NIVEL from '@salesforce/schema/Case.CC_En_Tercer_Nivel__c';
import CASE_CC_CANAL_OPERATIVO from '@salesforce/schema/Case.CC_Canal_Operativo__c';
import CASE_CC_MC_CAUSA from '@salesforce/schema/Case.CC_MCC_Causa__c';
import CASE_CC_MCC_SOLUCION from '@salesforce/schema/Case.CC_MCC_Solucion__c';
import CASE_PARENT from '@salesforce/schema/Case.ParentId';
import CASE_PARENT_RECORDTYPE_DEVELOPER_NAME from '@salesforce/schema/Case.Parent.RecordType.DeveloperName';

const CAMPOS_CASO = [
	CASE_PARENT, CASE_CC_MCC_SOLUCION, CASE_CC_MC_CAUSA, CASE_CC_CANAL_OPERATIVO, CASE_CC_EN_TERCER_NIVEL,
	CASE_CC_NO_IDENTIFICADO, CASE_OWNER, CASE_CANAL_RESPUESTA, CASE_IDIOMA,	CASE_CREATE_DATE, CASE_SUBJECT,
	CASE_TIPO_CLIENTE_FORMULA, CASE_CONTACT_PHONE, CASE_CANAL_PROCEDENCIA, CASE_TIPO_CLIENTE,
	CASE_ACCOUNT_MARCA_SENIOR, CASE_CONTACT, CASE_RECORDTYPE, CASE_GRUPO_3N, CASE_RECORDTYPE_DEVELOPER_NAME,
	CASE_ORIGIN, CASE_STATUS, CASE_DETALLES_CONSULTA, CASE_ACCOUNT, CASE_ACCOUNT_RECORTYPE_DEVELOPER_NAME,
	CASE_PARENT_RECORDTYPE_DEVELOPER_NAME
];

//eslint-disable-next-line new-cap
export default class hdtCaseOptionButtons extends NavigationMixin(LightningElement) {

	@api recordId;

	verTodasLasPlantillas = false;

	idPlantillaSeleccionada;

	@track selectedRecord = {};

	//Tiene que recoger CC_Grupo_Colaborador__c
	message = '';

	@track solucion;

	resultadosGrupoTercerNivel = [];

	numeroGestor = '';

	tieneGestor = false;

	mensajeErrorInt = '';

	deshabilitarEscalar = false;

	tipoGestion3N = '';

	verTodosLosGrupos3N = false;

	gestoresBackup = [];

	fechasDisponibilidad = [];

	horasDisponibilidad = [];

	nombreGestor = '';

	disponibilidadConsultada = false;

	gestorAsignadoCoincide = false;

	resultadoGrupoTercerNivelName;

	resultadoGrupoTercerNivelCola;

	resultadosPlantillasMostrar = false;

	//Idioma para recoger el idioma de la plantilla seleccionada y luego recogerla en la clase EmailSendController
	idiomaSeleccionCombo = '';

	@track oCaso;

	idioma;

	canalProcedencia;

	canalRespuesta;

	canalOperativo;

	estadoCaso = '';

	canalEntrada;

	tipoCliente;

	casoEnTercerNivel = false;

	tipoRegistro = '';

	comentario = '';

	ampliarInformacionDevolucion1N = false;

	comentariosTarea;

	accountRecordtypeDeveloperName;

	mostrarBotonesPendienteColaborador;

	mostrarBotonesPendienteInterno;

	mostrarBotonesPendienteCliente;

	habilitarLync;

	mostrarIniLync;

	mostrarFinLync;

	deshabilitarQAPropuestasMejora = false;

	nombreBoton;

	validarCamposCaso;

	AccountId = '';

	causa;

	permisos = {};

	listOfSearchRecords = [];

	tipoGestion;

	ContactId;

	@track optionsGrupo = [];

	noIdentificado;

	botonOperativa;

	tipoOperativa;

	existeCarpeta;

	@track opcionesIdiomaFolder = [];

	carpetaIdiomaSeleccionada = false;

	idiomaPlantilla = '';

	@track opcionesTratamientoFolder = [];

	procesoFinalSeleccion = false;

	@track options3N = [
		{label: 'Castellano', value: 'Castellano'},
		{label: 'Catalán', value: 'Català'},
		{label: 'Inglés', value: 'Inglés'}
	];

	@track listaPlantillas = [];

	emailWebCollab;

	grupoSeleccionado = false;

	plantillaEstaSeleccionada;

	remitir = false;

	@track remitir2;

	plantillaSeleccionadaValue;

	@track plantillaSeleccionadaName;

	grupoSeleccionadoValue = '';

	@track grupoSeleccionadoName;

	@track actualFirstOptionPlantilla;

	actualFirstOptionGrupo;

	@track optionsPlantilla;

	verTodosLosGrupos = false;

	uncheckedPlantilla = false;

	@track optionsPlantillaResponder;

	@track actualFirstOptionPlantillaSolicitud;

	@track SearchKeyWordPlantilla;

	@track listOfSearchRecordsPlantilla;

	@track selectedRecordPlantilla;

	@track myMap;

	esClienteDigital = false;

	gestorBackupActivo = false;

	gestorBackupActivoDos = false;

	existeBackup = false;

	value = 'es';

	resultadosGruposMostrar = false;

	resultadosGrupos;

	//Se utiliza para recoger el buzon por defecto del Email de HDT
	buzonEnviopordefecto;


	plantillasFiltro = [];

	Grupo3NNoSeleccionado = false;

	get idiomasPlantillas() {
		return [
			{label: 'Castellano', value: 'es'},
			{label: 'Catalan', value: 'ca'},
			{label: 'Ingles', value: 'eng'}
		];
	}

	get resultadosPlantillasSinDatos() {
		return this.plantillasFiltro.length === 0;
	}

	get permisosresponderempleado() {
		let permiso = false;
		if (this.permisos.HDT_Responder_Empleado) {
			permiso = true;
		} else {
			permiso = false;
		}
		return permiso;
	}

	get tipodetareadevolver() {
		return this.nombreBoton === 'Devolver Nivel 1';
	}

	get tipodetareamensaje() {
		let tareadevolver = '';

		if (this.nombreBoton === 'Devolver Nivel 1') {
			tareadevolver = 'Indique el motivo de la devolución a primer nivel.';
		} else {
			tareadevolver = 'Indique el motivo del rechazo para el traslado a tercer nivel.';
		}
		return tareadevolver;
	}

	get tipodetarearechazar() {
		return this.nombreBoton === 'Rechazar Nivel 1';
	}

	get solitarInformacionSMS() {
		return this.canalRespuesta === 'SMS' && this.tipoRegistro !== 'CC_CSI_Bankia';
	}

	get isPlantillaSeleccionadaNull() {
		return !this.plantillaSeleccionadaValue;
	}

	get responderEmpleado() {
		return this.canalRespuesta === 'Chat' || this.canalRespuesta === 'Phone';
	}

	get remitirGrupoColaborador() {
		return this.remitir ? 'Remitir a grupo colaborador' : 'Trasladar a grupo colaborador';
	}

	get remitirSeleccionaGrupo() {
		if (this.remitir2) {
			return 'Seleccione el grupo colaborador al que remitir el caso.';
		} else {
			return 'Seleccione el grupo colaborador al que trasladar la gestión del caso.';
		}
	}

	get uncheckedPlantillaProcesoFinal() {
		return !this.uncheckedPlantilla && this.procesoFinalSeleccion;
	}

	get mostrarBotonTrasladar3N() {
		return this.permisos.HDT_Trasladar_3N && !this.casoEnTercerNivel;
	}

	get mostrarBotonDevolver1N() {
		return getFieldValue(this.caso, CASE_CC_EN_TERCER_NIVEL) && this.permisos.HDT_Devolver_1N;
	}

	get mostrarBotonRechazar1N() {
		return getFieldValue(this.caso, CASE_CC_EN_TERCER_NIVEL) && this.permisos.HDT_Rechazar_1N;
	}

	get mostrarBotonTrasladarIncidencia() {
		return getFieldValue(this.caso, CASE_CC_EN_TERCER_NIVEL) && this.permisos.HDT_Asociar_Incidencia;
	}

	get mostrarBotonTomarPropiedad() {
		return getFieldValue(this.caso, CASE_OWNER) !== currentUserId && this.permisos.HDT_Autoasignarme_Caso;
	}

	get mostrarBotonCitaGestor() {
		return this.tipoRegistro === 'CC_Cliente' && this.accountRecordtypeDeveloperName === 'CC_ClientePA';
	}

	get mostrarBotonSolicitarInfoChat() {
		return this.permisos.HDT_Solicitar_Informacion && this.canalRespuesta !== 'SMS';
	}

	get mostrarBotonSolicitarInfoPhone() {
		return this.permisos.HDT_Solicitar_Informacion && this.canalRespuesta === 'SMS';
	}

	@wire(getRecord, {recordId: '$recordId', fields: CAMPOS_CASO})
	wiredRecord({error, data}) {
		if (error) {
			console.error(error);
			let mensajeError;
			if (Array.isArray(error.body)) {
				mensajeError = error.body.map(e => e.message).join(', ');
			} else if (typeof error.body.message === 'string') {
				mensajeError = error.body.message;
			}
			this.mostrarToast('error', 'Problema recuperando los datos del caso', mensajeError);

		} else if (data) {
			this.caso = data;
			let detallesconsulta;
			let account;
			let status;
			let caseorigin;

			account = getFieldValue(this.caso, CASE_ACCOUNT);
			status = getFieldValue(this.caso, CASE_STATUS);
			caseorigin = getFieldValue(this.caso, CASE_ORIGIN);
			this.idioma = getFieldValue(this.caso, CASE_IDIOMA);
			this.canalProcedencia = getFieldValue(this.caso, CASE_CANAL_PROCEDENCIA);
			this.canalRespuesta = getFieldValue(this.caso, CASE_CANAL_RESPUESTA);
			this.estadoCaso = getFieldValue(this.caso, CASE_STATUS);
			this.canalOperativo = getFieldValue(this.caso, CASE_CC_CANAL_OPERATIVO);
			this.causa = getFieldValue(this.caso, CASE_CC_MC_CAUSA);
			this.canalEntrada = caseorigin;
			this.resultadoGrupoTercerNivelName = getFieldValue(this.caso, CASE_GRUPO_3N);
			this.solucion = getFieldValue(this.caso, CASE_CC_MCC_SOLUCION);
			this.noIdentificado = getFieldValue(this.caso, CASE_CC_NO_IDENTIFICADO);
			this.tipoCliente = getFieldValue(this.caso, CASE_TIPO_CLIENTE);
			this.casoEnTercerNivel = getFieldValue(this.caso, CASE_CC_EN_TERCER_NIVEL);
			this.tipoRegistro = getFieldValue(this.caso, CASE_RECORDTYPE_DEVELOPER_NAME);
			this.AccountId = getFieldValue(this.caso, CASE_ACCOUNT);
			this.ContactId = getFieldValue(this.caso, CASE_CONTACT);

			this.caso = data;
			this.oCaso = data;

			if (detallesconsulta) {
				this.comentariosTarea = getFieldValue(this.caso, CASE_DETALLES_CONSULTA);
			}
			if (account) {
				this.accountRecordtypeDeveloperName = getFieldValue(this.caso, CASE_ACCOUNT_RECORTYPE_DEVELOPER_NAME);
			}
			if (status === 'Activo') {
				this.mostrarBotonesPendienteColaborador = true;
				this.mostrarBotonesPendienteInterno = true;
				this.mostrarBotonesPendienteCliente = true;
			} else {
				this.mostrarBotonesPendienteColaborador = false;
				this.mostrarBotonesPendienteInterno = false;
				this.mostrarBotonesPendienteCliente = false;
			}

			if (caseorigin === 'Phone' || caseorigin === 'Chat') {
				if (CASE_RECORDTYPE_DEVELOPER_NAME === 'HDT_Empleado') {
					this.habilitarLync = true;
					this.mostrarIniLync = true;
				}
			} else if (caseorigin === 'Propuestas de mejora') {
				this.deshabilitarQAPropuestasMejora = true;

			} else {
				this.habilitarLync = false;
			}

			if (!Object.keys(this.permisos).length) {
				this.obtenerPermisos();
			}
		}
	}

	checkboxPlantillaChange() {
		this.SearchKeyWordPlantilla = null;
		this.listOfSearchRecordsPlantilla = null;
		this.plantillaSeleccionadaValue = null;
		this.plantillaSeleccionadaName = null;
		this.plantillaEstaSeleccionada = false;
		this.plantillaSeleccionada = null;
	}

	devolver1N() {
		let micomentario = this.template.querySelector('[data-id="inputMotivoDevolucion"]').value;
		if (micomentario.length === 0) {
			this.mostrarToast('error', 'Datos del Caso.', 'Es necesario indicar un motivo para continuar.');
		} else {
			devolver({
				recordId: this.recordId,
				comentario: micomentario,
				tipo: this.tipoTarea,
				ampliarInformacion: this.ampliarInformacionDevolucion1N
			})
			.then(result => {
				let res = result;
				if (res === 'KO') {
					this.mostrarToast('error', 'Datos del Caso', 'Debes informar el campo Resolución 3Nivel en la gestión del caso para continuar');
				} else {
					this.casoEnTercerNivel = false;
					this.resultadoGrupoTercerNivelName = '';
					this.casoEnTercerNivel = false;
					this.cerrarModalDevolver1N();
				}
			})
			.catch(error => {
				console.error('error : ' + JSON.stringify(error));
				this.mostrarToast('error', 'Error', error[0].message);
			});
		}
	}

	numeroGestoresKO() {
		let esKO = false;
		if (this.numeroGestor === 'KO') {
			esKO = true;

		} else {
			esKO = false;
		}
		return esKO;
	}

	resetDisponibilidadConsultada() {
		this.disponibilidadConsultada = false;
	}

	modalResponderClienteTeclaPulsada(event) {
		if (event.keyCode === 27) { //ESC
			this.cerrarModalResponderCliente();
		}
	}

	modalDevolver1NTeclaPulsada(event) {
		if (event.keyCode === 27) { //ESC
			this.cerrarModalDevolver1N();
		}
	}

	cerrarModalDevolver1N() {

		const modal1 = this.template.querySelector('[data-id="ModalboxDevolver1N"]');
		modal1.classList.remove('slds-fade-in-open');

		const backdrop = this.template.querySelector('[data-id="backdrop"]');
		backdrop.classList.remove('slds-backdrop_open');

		this.comentario = null;

	}


	cerrarModalResponderCliente() {

		let selectItemIdioma = this.template.querySelector('[data-id="selectItemIdioma"]').value;

		if (selectItemIdioma) {
			this.template.querySelector('[data-id="selectItemIdioma"]').value = null;

			let selectItemTratamiento = this.template.querySelector('[data-id="selectItemTratamiento"]').value;

			if (selectItemTratamiento) {

				this.template.querySelector('[data-id="selectItemTratamiento"]').value = null;
				if (!this.uncheckedPlantilla) {
					let selectItemPlantilla = this.template.querySelector('[data-id="selectItemPlantilla"]').value;
					if (selectItemPlantilla) {
						this.template.querySelector('[data-id="selectItemPlantilla"]').value = null;
					}
				}
			}
		}

		this.plantillaSeleccionada = null;
		this.plantillaSeleccionadaValue = null;
		this.carpetaIdioma = '';
		this.carpetaIdiomaSeleccionada = false;
		this.opcionesIdiomaFolder = null;
		this.opcionesTratamientoFolder = null;
		this.carpetaFinal = null;
		this.procesoFinalSeleccion = false;
		this.tipoOperativa = '';

		//Cierra el modal de Responder a cliente
		//this.deseleccionarPlantilla2();
		const modal1 = this.template.querySelector('[data-id="ModalboxResponderCliente"]');
		modal1.classList.remove('slds-fade-in-open');

		const backdrop = this.template.querySelector('[data-id="backdrop"]');
		backdrop.classList.remove('slds-backdrop_open');
	}


	modalCitaGestorTeclaPulsada(event) {

		if (event.keyCode === 27) { //ESC
			this.modalCitaGestorCerrar();
		}
	}

	modalCitaGestorCerrar() {
		this.template.querySelector('[data-id="modalCitaGestor"]').classList.remove('slds-fade-in-open');
		this.template.querySelector('[data-id="backdrop"]').classList.remove('slds-backdrop--open');
		this.cargandoGestor = false;
		this.disponibilidadConsultada = false;
	}

	mmodalCitaGestorAbrir() {
		this.template.querySelector('[data-id="modalCitaGestor"]').classList.add('slds-fade-in-open');
		this.template.querySelector('[data-id="backdrop"]').classList.add('slds-backdrop--open');
		this.buscarClienteDigital('Cita gestor');
	}

	buscarClienteDigital(tipoActividad) {

		this.cargandoGestor = true;
		esClienteDigital({recordId: this.recordId, tipoActividad: tipoActividad})
		.then(result => {
			let value = result;
			if (value.resultado === 'OK') {
				this.esClienteDigital = value.clienteDigital;
				if (value.empleado1) {
					this.tieneGestor = true;
					this.numeroGestor = value.empleado1;
					this.nombreGestor = value.gestorClienteName;
					this.oficinaGestor = value.oficina1;
				}
				if (value.gestorAsignadoCoincide === false) {
					this.gestorAsignadoCoincide = false;
					this.nombreGestorAsignado = value.nombreGestorAsignado;
				} else if (value.resultado === 'KO') {
					this.numeroGestor = 'KO';
					this.mensajeErrorInt = value.mensajeError;
				}
				this.cargandoGestor = false;
			}
		});
	}

	onClickAutoasignarme() {

		this.template.querySelector('[data-id="Autoasignarme"]').disabled = true;
		const fields = {};
		fields[CASE_ID.fieldApiName] = this.recordId;
		fields[CASE_OWNER.fieldApiName] = currentUserId;
		fields[CASE_STATUS.fieldApiName] = 'Activo';

		updateRecord({fields})
		.then(() => this.mostrarToast('success', 'Ahora es el propietario del caso', 'Se actualizó correctamente el propietario del caso'))
		.catch(error => {
			console.error(error);
			this.mostrarToast('error', 'Problema actualizando propietario del caso', error.body.message);
		}).finally(() => {
			let botonTomarPropiedad = this.template.querySelector('[data-id="Autoasignarme"]');
			if (botonTomarPropiedad) {
				botonTomarPropiedad.disabled = false;
			}
		});
	}

	//Funciones referentes al Remitir Colaborador
	remitirColaborador() {

		let plantilla = '';
		let nombrePlantilla = '';
		this.llamarBuzonEmail();

		if (this.uncheckedPlantilla) {
			plantilla = this.selectedRecordPlantilla.Id;
			nombrePlantilla = this.selectedRecordPlantilla.Name;
			this.plantillaSeleccionadaValue = plantilla;
			this.plantillaSeleccionadaName = nombrePlantilla;

		}

		//Se guarda el nombre de la plantilla para poder enviar el correo, con la plantilla correspondiente
		actualizarCaso({
			idCaso: this.recordId,
			plantilla: this.plantillaSeleccionadaValue,
			informarReferenciaCorreo: true,
			tratamiento: '',
			operativa: this.tipoOperativa,
			canalRespuesta: 'Email',
			canalProcedencia: this.canalProcedencia,
			tipoRegistro: this.tipoRegistro
		})
		.then(() => {

		});

		//Recuperar destinatarios
		let listCC = [];
		let listPara = [];
		//Se guarda el nombre de la plantilla para poder enviar el correo, con la plantilla correspondiente
		buscarColaboradorGestor({
			idCaso: this.recordId,
			idGrupoColaborador: this.grupoSeleccionadoValue
		})
		.then(result => {
			let map = result;
			for (let key in map) {
				if (map[key] === 'Para') {
					listPara.push(key);
				} else if (map[key] === 'CC') {
					listCC.push(key);
				}
			}
			this.myMap = result;
			//Preparar borrador de correo con la plantilla seleccionada
			let operativa = '';
			if (this.tipoOperativa === 'trasladar') {
				operativa = 'Traslado Colaborador';
			} else if (this.tipoOperativa === 'remitir') {
				operativa = 'Remitir Colaborador';
			}
			
			this.sendEmail(this.buzonEnviopordefecto, nombrePlantilla, operativa, listPara, listCC, this.grupoSeleccionadoName);
			this.cerrarModalTrasladarColaborador();
		});
	}

	llamarBuzonEmail() {
		obtenerEmailFromHDT({idiomaCaso: this.idiomaSeleccionCombo})
		.then(result => this.buzonEnviopordefecto = result)
		.catch(error => console.error(error));
	}

	inputBuscarGruposOnChange(event) {
		window.clearTimeout(this.idTimeoutBuscarGrupos);
		this.idGrupoSeleccionado = null;
		let negocio = 'HDT';
		let cadenaBusqueda;
		if (event.currentTarget.dataset.operativa === 'Trasladar') {
			cadenaBusqueda = this.template.querySelector('.inputBuscarGruposTrasladar').value;
		} else {
			cadenaBusqueda = this.template.querySelector('.inputBuscarGruposRemitir').value;
		}
		if (cadenaBusqueda) {
			//eslint-disable-next-line @lwc/lwc/no-async-operation
			this.idTimeoutBuscarGrupos = window.setTimeout(() => {
				buscarGruposColaboradores({cadenaBusqueda: cadenaBusqueda, negocio: negocio})
				.then(response => {
					this.resultadosGrupos = response;
					this.resultadosGruposMostrar = true;
				}).catch(error => {
					console.error(JSON.stringify(error));
					this.mostrarToast('error', 'Problema recuperando resultados', JSON.stringify(error));
				});
			}, 400);
		} else {
			this.resultadosGruposMostrar = false;
			this.resultadosGrupos = [];
		}
	}

	inputBuscarGruposTrasladarOnBlur() {
		//eslint-disable-next-line @lwc/lwc/no-async-operation
		window.setTimeout(() => this.resultadosGruposMostrar = false, 200);
	}

	inputBuscarGruposTrasladarOnFocus() {
		this.resultadosGruposMostrar = this.template.querySelector('.inputBuscarGruposTrasladar').value;
	}

	inputOnKeyDown(event) {
		//Al pulsar la tecla ESC con foco en un input, solo se cierra el modal si no tiene valor
		if (event.currentTarget.value) {
			event.stopPropagation();
		}
	}

	obtenerPermisos() {
		hdtgetCustomPermissions({nombreGrupo3N: this.resultadoGrupoTercerNivelName, casoId: this.recordId})
		.then(permisos => this.permisos = {...permisos, vincularLlamada: true})
		.catch(error => {
			console.error(error);
			this.mostrarToast('error', 'Problema recibiendo los datos de los permisos', JSON.stringify(error));
		});
	}

	handleComponentEvent(event) {
		const selectedRecord = event.detail.accountByEvent;
		this.selectedRecord = selectedRecord;
		this.obtenerPlantillasGrupo();

		const lookupPill = this.template.querySelector('[data-id=\'lookup-pill\']');
		lookupPill.classList.add('slds-show');
		lookupPill.classList.remove('slds-hide');

		const searchRes = this.template.querySelector('[data-id=\'searchRes\']');
		searchRes.classList.add('slds-is-close');
		searchRes.classList.remove('slds-is-open');

		const lookupField = this.template.querySelector('[data-id=\'lookupField\']');
		lookupField.classList.add('slds-hide');
		lookupField.classList.remove('slds-show');
	}


	resultadoGrupoTercerNivelOnclick(event) {

		//let idGrupoTercerNivelSeleccionado = event.currentTarget.dataset.id;
		this.resultadoGrupoTercerNivelCola = event.currentTarget.dataset.cola;
		this.resultadoGrupoTercerNivelName = event.currentTarget.dataset.name;
		this.Grupo3NNoSeleccionado = false;
	}

	handleComponentEventPlantilla(component, event) {
		component.selectedRecordPlantilla = event.detail.plantillaByEvent;
		component.template.querySelector('[data-id="lookup-pill-plantilla"]').classList.remove('slds-hide');
		component.template.querySelector('[data-id="lookup-pill-plantilla"]').classList.add('slds-show');
		component.template.querySelector('[data-id="searchResPlantilla"]').classList.remove('slds-is-open');
		component.template.querySelector('[data-id="searchResPlantilla"]').classList.add('slds-is-close');
		component.template.querySelector('[data-id="lookupFieldPlantilla"]').classList.remove('slds-show');
		component.template.querySelector('[data-id="lookupFieldPlantilla"]').classList.add('slds-hide');
	}


	handleComponentEventPlantilla2(event) {
		const targetId = event.currentTarget.id;
		const plantillaSeleccionada = this.listOfSearchRecordsPlantilla.find(plantilla => plantilla.Id === targetId);

		this.plantillaSeleccionada = plantillaSeleccionada;
		this.plantillaSeleccionadaValue = plantillaSeleccionada.Id;
		this.plantillaSeleccionadaName = plantillaSeleccionada.Name;
	}

	handleComponentEventPlantilla3(event) {
		const targetId = event.currentTarget.id;
		const plantillaSeleccionada = this.resultadosGrupoTercerNivel.find(plantilla => plantilla.Id === targetId);

		this.plantillaSeleccionada = plantillaSeleccionada;
		this.plantillaSeleccionadaValue = plantillaSeleccionada.Id;
		this.plantillaSeleccionadaName = plantillaSeleccionada.Name;
	}

	handleCarpetaTratamientoSeleccionada(event) {

		this.procesoFinalSeleccion = true;
		this.tratamiento = event.target.value;
		this.getPlantillasResponder(event);
	}

	toogleAmpliarInfoDevolver1N(event) {
		this.ampliarInformacionDevolucion1N = event.target.checked;
	}


	toggleVerTodasLasPlantillasOnChange(event) {

		this.verTodasLasPlantillas = event.target.checked;
		this.idPlantillaSeleccionada = null;

		if (this.verTodasLasPlantillas) {
			this.uncheckedPlantilla = false;
		} else {
			this.uncheckedPlantilla = true;
		}
	}

	inputBuscarPlantillasTrasladarOnBlur() {
		//eslint-disable-next-line @lwc/lwc/no-async-operation
		this.resultadosPlantillasMostrar = false;
	}

	inputBuscarPlantillasOnChange(event) {

		this.idPlantillaSeleccionada = null;
		let cadenaBusqueda;
		if (event.currentTarget.dataset.operativa === 'Trasladar') {
			cadenaBusqueda = this.template.querySelector('.inputBuscarPlantillasTrasladar').value;
		} else {
			//cadenaBusqueda = this.template.querySelector('.inputBuscarPlantillasRemitir').value;
		}
		if (cadenaBusqueda) {
			this.resultadosPlantillasMostrar = true;
			this.plantillasFiltro = this.plantillas.filter(plantilla => plantilla.label.toLowerCase().includes(cadenaBusqueda.toLowerCase()));
		} else {
			this.resultadosPlantillasMostrar = false;
		}
	}

	inputBuscarPlantillasTrasladarOnFocus() {
		this.resultadosPlantillasMostrar = true;
	}

	allGrupos(event) {

		this.verTodosLosGrupos = event.target.checked;
		this.grupoSeleccionado = false;

		if (this.verTodosLosGrupos) {
			this.canalProcedencia = false;
		} else {
			this.plantillaEstaSeleccionada = false;
			this.getPicklistMCCGrupo(event);
		}

	}

	deseleccionarPlantilla2() {
		//Eliminar el grupo seleccionado
		this.template.querySelector('[data-id="selectItemPlantilla"]').value = null;
		this.listOfSearchRecordsPlantilla = null;
		this.plantillaSeleccionadaValue = null;
		this.plantillaSeleccionadaName = null;
		this.plantillaEstaSeleccionada = false;
		this.plantillaSeleccionada = null;
	}

	seleccionarPlantilla(event) {
		this.plantillaEstaSeleccionada = true;
		const tipoOperativa = this.tipoOperativa;

		if (this.verTodasLasPlantillas) {
			this.template.querySelector('.inputBuscarPlantillasTrasladar').value = event.currentTarget.dataset.name;
			this.idPlantillaSeleccionada = event.currentTarget.dataset.id;
			this.resultadosPlantillasMostrar = false;
			this.plantillaSeleccionadaValue = event.currentTarget.dataset.id;
			this.plantillaSeleccionadaName = event.currentTarget.dataset.name;
		}

		if (tipoOperativa === 'trasladar' || tipoOperativa === 'remitir') {
			this.actualFirstOptionPlantilla = event.target.value;
			const optionsPlantilla = this.optionsPlantilla;
			for (let key in optionsPlantilla) {
				if (event.target.value === optionsPlantilla[key].value) {
					this.plantillaSeleccionadaValue = optionsPlantilla[key].value;
					this.plantillaSeleccionadaName = optionsPlantilla[key].label;
				}
			}
		} else if (tipoOperativa === 'responder') {
			this.actualFirstOptionPlantilla = event.target.value;
			const picklistFirstOptionsPlantilla = this.optionsPlantillaResponder;
			for (let key in picklistFirstOptionsPlantilla) {
				if (event.target.value === picklistFirstOptionsPlantilla[key].value) {
					this.plantillaSeleccionadaValue = picklistFirstOptionsPlantilla[key].value;
					this.plantillaSeleccionadaName = picklistFirstOptionsPlantilla[key].label;
				}
			}
		} else {
			this.actualFirstOptionPlantillaSolicitud = event.target.value;
			const optionsPlantillaResponder = this.optionsPlantillaResponder;
			for (let key in optionsPlantillaResponder) {
				if (event.target.value === optionsPlantillaResponder[key].value) {
					this.plantillaSeleccionadaValue = optionsPlantillaResponder[key].value;
					this.plantillaSeleccionadaName = optionsPlantillaResponder[key].label;
				}
			}
		}
	}

	getPlantillasResponder() {
		getPlantillasResponder({recordId: this.recordId, carpeta: this.tratamiento})
		.then(result => this.optionsPlantillaResponder = result);
	}

	allGrupos3N(event) {

		this.verTodosLosGrupos3N = event.target.checked;
		this.resultadosGrupoTercerNivel = [];
		if (!this.verTodosLosGrupos3N) {
			this.getPicklistMCCGrupo3N();
		}
	}

	trasladarColaborador() {
		//this.template.querySelector('.modalTrasladarTrasladar').disabled = true;

		let plantilla = '';
		let nombrePlantilla = '';
		this.llamarBuzonEmail();

		if (this.uncheckedPlantilla) {
			plantilla = this.selectedRecordPlantilla.Id;
			nombrePlantilla = this.selectedRecordPlantilla.Name;
			this.plantillaSeleccionadaValue = plantilla;
			this.plantillaSeleccionadaName = nombrePlantilla;
		}

		//Se guarda el nombre de la plantilla para poder enviar el correo, con la plantilla correspondiente
		actualizarCaso({
			idCaso: this.recordId,
			plantilla: this.plantillaSeleccionadaValue,
			informarReferenciaCorreo: true,
			tratamiento: '',
			operativa: this.tipoOperativa,
			canalRespuesta: 'Email',
			canalProcedencia: this.canalProcedencia,
			tipoRegistro: this.tipoRegistro
		})
		.then(() => {
			let listCC = [];
			let listPara = [];

			buscarColaborador({idGrupoColaborador: this.grupoSeleccionadoValue})
			.then(result2 => {

				let direcciones = result2;
				for (let indice in direcciones) {
					if (direcciones[indice] === 'Para') {
						listPara.push(indice);
					} else if (direcciones[indice] === 'CC') {
						listCC.push(indice);
					}
				}

				this.myMap = result2;

				let operativa = '';
				if (this.tipoOperativa === 'trasladar') {
					operativa = 'Traslado Colaborador';
				}

				if (this.tipoOperativa === 'remitir') {
					operativa = 'Remitir Colaborador';
				}

				
				this.sendEmail(this.buzonEnviopordefecto, nombrePlantilla, operativa, listPara, listCC, this.grupoSeleccionadoName);
				this.cerrarModalTrasladarColaborador();

			});
		})
		.catch(error => {
			console.error(error);
			this.mostrarToast('error', 'Problema generando el borrador de correo el caso', JSON.stringify(error));

		});
	}

	closeModals() {
		this.generandoBorrador = false;
		this.verTodasLasPlantillas = false;
		this.template.querySelectorAll('.slds-modal').forEach(modal => modal.classList.remove('slds-fade-in-open'));
		this.template.querySelector('.backdropModales').classList.remove('slds-backdrop_open');
	}

	sendEmail(buzonpordefecto, plantilla, operativa, destinatariosPara, destinatariosCc, nombreGrupo) {

		this.dispatchEvent(new CustomEvent('rellenarmail', {
			detail: {
				buzonpordefecto: buzonpordefecto,
				plantilla: plantilla,
				operativa: operativa,
				para: destinatariosPara,
				cc: destinatariosCc,
				grupo: nombreGrupo,
			}
		}));
	}

	handleCarpetaIdiomaSeleccionada(event) {
		this.idiomaPlantilla = event.detail.value;
		//Recuperar el label asociado al valor seleccionado
		const opcionIdiomaSeleccionada = this.opcionesIdiomaFolder.find(opcion => opcion.value === event.detail.value);
		this.idiomaSeleccionCombo = opcionIdiomaSeleccionada.label;

		this.loadCarpetasTratamiento(event);
	}

	//Función para ejecutar el traslado de operativa a 3N.
	trasladar3N() {
		this.deshabilitarEscalar = true;
		let recordId = this.recordId;
		let colaName;
		let grupoName;
		let unchecked = this.verTodosLosGrupos3N;
		if (unchecked) {
			colaName = this.resultadoGrupoTercerNivelCola;
			grupoName = this.resultadoGrupoTercerNivelName;
		} else {
			colaName = this.grupoSeleccionadoValue;
			grupoName = this.grupoSeleccionadoName;
		}

		let tipoGestion = this.tipoGestion3N;
		let comentario = '';

		guardaTipoGestion({sIdCaso: this.recordId, tipoGestion: tipoGestion})
		.then(() => {
			cambiarPropietario({grupoName: grupoName, colaName: colaName, recordId: recordId, comentario: comentario})
			.then(() => {

				this.cerrarModalTrasladar3N();
				this.casoEnTercerNivel = true;
				location.reload(); //¿?¿??
			});

		}).catch(error => console.error(error));



	}

	cerrarModalSolicitarInfo() {
		const selectItemIdioma = this.template.querySelector('[data-id="selectItemIdiomaSol"]').value;
		if (selectItemIdioma) {
			this.template.querySelector('[data-id="selectItemIdiomaSol"]').value = null;
			let selectItemTratamiento = this.template.querySelector('[data-id="selectItemTratamientoSol"]').value;
			if (selectItemTratamiento) {
				this.template.querySelector('[data-id="selectItemTratamientoSol"]').value = null;
				let selectItemPlantilla = this.template.querySelector('[data-id="selectItemPlantillaSol"]').value;
				if (selectItemPlantilla) {
					this.template.querySelector('[data-id="selectItemPlantillaSol"]').value = null;
				}
			}
		}

		//Cierra el modal de Solicitud de información
		this.plantillaSeleccionadaValue = null;
		this.plantillaSeleccionadaName = '';
		this.actualFirstOptionPlantillaSolicitud = '';
		this.optionsPlantillaSolicitud = null;
		this.carpetaIdioma = '';
		this.carpetaIdiomaSeleccionada = false;
		this.opcionesIdiomaFolder = null;
		this.opcionesTratamientoFolder = null;
		this.carpetaFinal = null;
		this.procesoFinalSeleccion = false;
		this.tipoOperativa = '';
		let cmpTarget = this.template.querySelector('[data-id="ModalboxSolicitarInfo"]');
		cmpTarget.classList.remove('slds-fade-in-open');
		let cmpBack = this.template.querySelector('[data-id="backdrop"]');
		cmpBack.classList.remove('slds-backdrop_open');
	}

	modalSolicitarInfoTeclaPulsada(event) {
		if (event.keyCode === 27) { //ESC
			this.cerrarModalSolicitarInfo();
		}
	}

	modalTrasladarColaboradorTeclaPulsada(event) {
		if (event.keyCode === 27) { //ESC
			this.cerrarModalTrasladarColaborador();
		}
	}

	modalTrasladar3NTeclaPulsada(event) {
		if (event.keyCode === 27) {
			this.cerrarModalTrasladar3N();
		}
	}

	seleccionarGrupo(event) {
		if (event.currentTarget.dataset.operativa === 'Trasladar') {
			this.template.querySelector('.inputBuscarGrupos').value = event.currentTarget.dataset.name;

		} else {
			this.template.querySelector('.inputBuscarPlantillasRemitir').value = event.currentTarget.dataset.name;
		}

		this.obtenerPlantillasGrupo(event);
		//Aqui tengo que agregar el grupo seleccionado
		this.idPlantillaSeleccionada = event.currentTarget.dataset.id;
		this.resultadosPlantillasMostrar = false;
	}

	cerrarModalTrasladar3N() {

		const selectGroups3N = this.template.querySelector('[data-id="selectGroups3N"]');
		if (selectGroups3N) {
			selectGroups3N.value = null;
		}

		this.grupoSeleccionadoValue = '';
		this.grupoSeleccionadoName = '';
		this.actualFirstOptionGrupo = '';
		this.resultadosGrupoTercerNivel = [];
		this.verTodosLosGrupos3N = false;
		this.grupoSeleccionado = false;

		const modalbox3Nivel = this.template.querySelector('[data-id="Modalbox3Nivel"]');
		if (modalbox3Nivel) {
			modalbox3Nivel.classList.remove('slds-fade-in-open');
		}

		const modalbackdrop3Nivel = this.template.querySelector('[data-id="backdrop"]');
		if (modalbackdrop3Nivel) {
			modalbackdrop3Nivel.classList.remove('slds-backdrop_open');
		}

		this.deseleccionarGrupo3N();
	}

	seleccionarGrupo3N(event) {

		let unchecked = this.verTodosLosGrupos3N;
		let grupoId = '';
		let grupoName = '';
		if (unchecked) {
			grupoId = this.selectedRecord.Id;
			grupoName = this.selectedRecord.Name;
			this.grupoSeleccionadoValue = grupoId;
			this.grupoSeleccionadoName = grupoName;
		} else {
			grupoId = event.target.value;
			this.actualFirstOptionGrupo = grupoId;
			let picklistFirstOptionsGrupo = this.resultadosGrupoTercerNivel;
			for (let key in picklistFirstOptionsGrupo) {
				if (grupoId === picklistFirstOptionsGrupo[key].value) {
					this.grupoSeleccionadoValue = picklistFirstOptionsGrupo[key].value;
					this.grupoSeleccionadoName = picklistFirstOptionsGrupo[key].label;
				}
			}
		}
	}

	buscarGrupos3N(cadenaBusqueda) {
		buscarGrupos3N({cadenaBusqueda: cadenaBusqueda})
		.then(grupos3N => {
			if (!grupos3N.length) {
				this.message = 'No hay resultados.';
			}
			this.resultadosGrupoTercerNivel = grupos3N;

		}).catch(error => {
			console.error(error);
		});
	}

	teclaPulsadaLookupGrupo3N(event) {
		let getInputkeyWordGroup = event.currentTarget.value;
		const searchResGroup = this.template.querySelector('.searchResGroup');
		if (getInputkeyWordGroup.length) {
			searchResGroup.classList.add('slds-is-open');
			searchResGroup.classList.remove('slds-is-close');
			this.Grupo3NNoSeleccionado = true;
			this.buscarGrupos3N(getInputkeyWordGroup);
		} else {
			this.resultadosGrupoTercerNivel = [];
			searchResGroup.classList.add('slds-is-close');
			searchResGroup.classList.remove('slds-is-open');
		}
	}

	deseleccionarGrupo3N() {
		const pillTarget = this.template.querySelector('.slds-pill');
		if (pillTarget) {
			pillTarget.classList.add('slds-hide');
			pillTarget.classList.remove('slds-show');
		}

		const lookUpTarget = this.template.querySelector('.slds-lookup');
		if (lookUpTarget) {
			lookUpTarget.classList.add('slds-show');
			lookUpTarget.classList.remove('slds-hide');
		}
		this.resultadoGrupoTercerNivelName = '';

		this.resultadosGrupoTercerNivel = [];

		const tipoGestion = this.template.querySelectorAll('.tipoGestion');
		if (tipoGestion && tipoGestion.length > 0) {
			tipoGestion[0].style.display = 'none';
		}

		this.tipoGestion3N = '';
	}

	//Comienzo botón para validar las operativas correspondientes.
	//1.- Trasladar a Colaborador

	validacionesOperativa(event) {
		this.botonOperativa = '';
		this.nombreBoton = event.target.dataset.id;

		if (getFieldValue(this.caso, CASE_OWNER) !== currentUserId) {
			this.mostrarToast('info', 'No eres el propietario del caso', 'Esta operativa solo está disponible si es propietario del caso');
		} else {
			if (this.estadoCaso === 'Activo' || this.estadoCaso === 'Pendiente Interno' && this.nombreBoton === 'Devolver Nivel 1' || this.estadoCaso === 'Pendiente Incidencia' && this.nombreBoton === 'Trasladar Incidencia' || this.estadoCaso === 'Pendiente Colaborador' && (this.nombreBoton === 'Responder Cliente Email' || this.nombreBoton === 'Responder Cliente SMS')) {
				this.mostrarBotonesPendienteColaborador = true;
				this.mostrarBotonesPendienteInterno = true;
				this.mostrarBotonesPendienteCliente = true;

				if (getFieldValue(this.caso, CASE_OWNER).startsWith('00G')) {
					this.mostrarToast('error', 'Operativa no disponible', 'Para poder realizar esta operativa, el caso debe estar asignado a un usuario.');
				} else {
					validarCamposCaso({recordId: this.recordId})
					.then(responseValidarCamposCaso => {
						let camposNoValidos = responseValidarCamposCaso;
						if (camposNoValidos.length) {
							let mensaje = '';
							//Se comprueba si la clasificación está inactiva
							if (camposNoValidos.indexOf('Clasificación inactiva') > -1) {
								//Si lo está se prepara el mensaje y se quita el elemento del array
								mensaje = 'La clasificación actual del caso ha sido inactivada, debe reclasificarlo. ';
								camposNoValidos.splice(camposNoValidos.indexOf('Clasificación inactiva'), 1);
							}
							if (camposNoValidos.length && this.nombreBoton === 'Solicitud Info Email') {
								if (!this.canalOperativo && this.tipoRegistro === 'CC_Cliente') {
									camposNoValidos.push('Canal operativo');
								}
								mensaje += 'Debe informar los siguientes campos obligatorios: ' + camposNoValidos.join(', ') + '.';

							} else if (camposNoValidos.length) {
								//El resto de elementos son campos obligatorios actualmente nulos
								mensaje += 'Debe informar los siguientes campos obligatorios: ' + camposNoValidos.join(', ') + '.';
							}

							if (mensaje) {
								this.mostrarToast('error', 'Operativa no disponible', mensaje);
							}
						} else {
							//Aqui tenemos todos los campos necesarios rellenos
							//Validación de campo OK
							//Comprobar que la cuenta y contactó estén rellenados
							this.botonOperativa = this.nombreBoton;
							if (this.nombreBoton === 'Trasladar Colaborador' || this.nombreBoton === 'Remitir Colaborador') {

								if ((!this.AccountId || !this.ContactId) && !this.noIdentificado) {
									this.mostrarToast('error', 'Datos del Caso', 'Para poder realizar esta operativa, el caso debe estar vinculado a una cuenta y un contacto');
								} else {
									//Llamada Modal "Trasladar Colaborador" o "Remitir Colaborador"
									this.abrirModalTrasladarColaborador();
								}
							} else if (this.nombreBoton === 'Trasladar 3N') {
								if ((!this.AccountId || !this.ContactId) && !this.noIdentificado) {
									this.mostrarToast('error', 'Datos del Caso', 'Para poder realizar esta operativa, el caso debe estar vinculado a una cuenta y un contacto');
								} else {
									//Trasladar Caso 3N
									this.abrirModalTrasladar3N();
								}
							} else if (this.nombreBoton === 'Devolver Nivel 1' || this.nombreBoton === 'Rechazar Nivel 1') {
								//Devolver caso a 1N
								this.abrirModalDevolver1N();
							} else if (this.nombreBoton === 'Trasladar Incidencia') {
								//Llamada para trasladar incidencia
								//Obligatoriedad de campos al trasladar incidencia
								if (!this.AccountId || !this.ContactId && !this.noIdentificado ||
									!this.canalProcedencia || !this.canalEntrada || !this.canalOperativo || !this.causa || !this.solucion) {
									this.mostrarToast('error', 'Datos del Caso', 'Debes informar los campos Canal de entrada, Canal de procedencia, Idioma, Tipo de contacto, Canal operativo, Causa y Solución, Cuenta y Contacto');
								} else {
									//Trasladar a Incidencia
									//this.dispatchEvent(new CustomEvent('abrirquickactionincidencia', {}));
									this.abrirQuickActionIncidencia();
								}

							} else if (this.nombreBoton === 'Solicitud Info Chat' || this.nombreBoton === 'Solicitud Info Phone' || this.nombreBoton === 'Solicitud Info Apps') {
								if (this.nombreBoton === 'Solicitud Info Chat') {
									if (!this.canalOperativo && this.tipoRegistro === 'CC_Cliente'
										|| (!this.AccountId || !this.ContactId) && !this.noIdentificado) {
										this.mostrarToast('error', 'Datos del Caso', 'Debes informar los campos Canal operativo, Cuenta y Contacto');
									} else {
										this.abrirModalSolicitarInfo();
									}
								} else {
									//Solicitar Informacion
									this.abrirModalSolicitarInfo();
								}
							} else if (this.nombreBoton === 'Responder Cliente Email' || this.nombreBoton === 'Responder Cliente SMS' || this.nombreBoton === 'Responder Cliente Twitter' || this.nombreBoton === 'Responder Cliente Apps') {
								if (this.nombreBoton === 'Responder Cliente Email' && (!this.AccountId || !this.ContactId) && !this.noIdentificado) {
									this.mostrarToast('error', 'Datos del Caso', 'Para poder realizar esta operativa, el caso debe estar vinculado a una cuenta y un contacto');
								} else {

									//**************************************/
									//Procedimiento para Responder a Empleado
									this.abrirModalResponderCliente();
								}
							} else if (this.nombreBoton === 'IniLync') {
								this.inicializarLync(this.recordId);

							} else if (this.nombreBoton === 'FinLync') {

								this.finalizarLync(this.recordId);

							}
						}
					});
				}
			} else {
				this.mostrarBotonesPendienteColaborador = false;
				this.mostrarBotonesPendienteInterno = false;
				this.mostrarBotonesPendienteCliente = false;
				this.mostrarToast('error', 'Operativa no disponible', 'Esta operativa solo está disponible para casos activos');
			}
		}
	}

	responderCliente() {
		let miPlantilla = this.plantillaSeleccionadaName;
		this.llamarBuzonEmail();

		actualizarCaso({
			idCaso: this.recordId,
			plantilla: this.plantillaSeleccionadaValue,
			informarReferenciaCorreo: true,
			tratamiento: this.tratamiento,
			operativa: this.tipoOperativa,
			canalRespuesta: this.canalRespuesta,
			canalProcedencia: this.canalProcedencia,
			tipoRegistro: this.tipoRegistro
		})
			.then(() => {
				buscarCorreoContacto({idCaso: this.recordId})
				.then(result => {
					this.result = result;
					this.sendEmail(this.buzonEnviopordefecto, miPlantilla, 'Responder Cliente', result, '', this.grupoSeleccionadoName);
				}).catch(error => console.error(error));
			});
		this.cerrarModalResponderCliente();
	}

	//Inicio Métodos Devolver/Derivar al SAC
	onClickDevolverAlSac() {
		/**
			* Todos los casos que nos derivan con cualquier RT de SAC?
			* Actividad 'Devuelto al SAC'
			* ParentId y Parent.Recordtype == SAC --> OK
			* Dudas: Qué caso se debe devolver a SAC?
			* Con devolver se refiere a que igual el caso esté en estado 'pendiente algo'/'cerrado' y que cuando nosotros le damos a Devolver el caso pase a 'Activo' (del SAC)?
			* Cuando lo devolvemos ellos pueden volver a derivanoslo? Entonces la actividad esta pendiente hasta que nos lo deriven de nuevo?
			*/
		this.template.querySelector('[data-id="derivarAlSAC"]').disabled = true;
		//let motivoDevolver = 'Error en la asignación, falta de competencia de Contact Center';

		updateTaskWebCollab({casoContactCenter: this.recordId})
			.then(() => {
				this.mostrarToast('success', 'Caso derivado', 'El caso se ha devuelto al SAC.');
				this.dispatchEvent(new CustomEvent('refreshview'));
			});
	}

	handleVaciarPlantilla() {
		vaciarPlantilla({recordId: this.recordId})
			.then(() => {
			})
			.catch(() => {
			});
	}

	onClickDerivarAlSac() {
		/**
			* Actividad 'Derivado a SAC'
			* Canal de entrada 'Email' y canal de procedencia 'Formulario web' --> OK
			* Dudas: Al crear la actividad nuestro caso pasa a 'Pendiente algo' o se cierra?
			* La actividad esta abierta? Sac nos devuelve el caso? Si nos lo devuelve, completamos la actividad de 'Derivado al SAC'?
			* La opción de derivar a parte de que esté activa en la lista depende también del canal de entrada email y canal de procedencia formulario web? Resumen US y tarea dicen cosas distintas.
			*/
		this.template.querySelector('[data-id="derivarAlSAC"]').disabled = true;
		const motivoDerivar = 'Asignación de caso al SAC';

		updateTaskWebCollab({casoContactCenter: this.oCaso, motivo: motivoDerivar})
			.then(() => {
				this.mostrarToast('success', 'Caso derivado', 'El caso se ha derivado al SAC.');
				this.dispatchEvent(new CustomEvent('refreshview'));
			});
	}

	finalizarLync() {

		let email = this.emailWebCollab;

		updateTaskWebCollab({recordId: this.recordId})
			.then(result11 => {

				const idTask = result11;
				if (idTask != null && idTask !== '') {
					/*
					*   Construcción link webcollab formato: webcollab://1|8-12345|8-67890|alex.bonich@dxc.com
					*   Indicador de método: si se recibe un 1, se invocará a la función Iniciar, si se recibe un 0, se invocará a la función Finalizar.
					*   Id SR: identificador de base de datos de la SR.
					*   Id Actividad: identificador de base de datos de la actividad creada específicamente para WebCollaboration.
					*   Email: dirección de correo electrónico del empleado.
					*/
					//var newwindow = window.open('/apex/CallReportDataComponentPage','Call Report' '_blank');

					const url = `webcollab://0|${this.recordId}|${idTask}|${email}`;
					window.open(url);
				}

			});

		this.mostrarIniLync = true;
		this.mostrarFinLync = false;
	}

	inicializarLync() {
		recuperaMailEmpleado({recordId: this.recordId})
			.then(result10 => {

				const datos = result10;
				const email = datos[0].Contact.Email;
				const empleadoName = datos[0].Contact.Name;

				if (email !== null && email !== '') {
					this.emailWebCollab = email;

					crearTaskWebCollab({recordId: this.recordId, empleado: empleadoName})
					.then(responseCrearTareaWebCollab => {

						const idTask = responseCrearTareaWebCollab;
						if (idTask != null && idTask !== '') {
							/*
							*   Construcción link webcollab formato: webcollab://1|8-12345|8-67890|alex.bonich@dxc.com
							*   Indicador de método: si se recibe un 1, se invocará a la función Iniciar, si se recibe un 0, se invocará a la función Finalizar.
							*   Id SR: identificador de base de datos de la SR.
							*   Id Actividad: identificador de base de datos de la actividad creada específicamente para WebCollaboration.
							*   Email: dirección de correo electrónico del empleado.
							*/
							const url = `webcollab://1|${this.recordId}|${idTask}|${email}`;
							window.open(url);

						} else {
							let titulo = 'Error: ';
							let mensaje = 'El email del empleado debe estar informado a nivel de contacto.';
							let tipo = 'error';
							this.mostrarToast(tipo, titulo, mensaje);
						}
					});
				}
			});
		this.mostrarIniLync = false;
		this.mostrarFinLync = true;
	}


	//Funciones referentes al Responder Cliente
	abrirModalResponderCliente() {
		//Solo se abre el modal de Solicitar info si el canal de respuesta es Email, Chat o vacío.
		let canalRespuesta = this.canalRespuesta;
		if (canalRespuesta === 'Email' || canalRespuesta === 'Chat' || canalRespuesta === 'Phone' || canalRespuesta === '' || canalRespuesta == null || canalRespuesta === 'Backoffice') {
			//Abre el modal de Responder Cliente
			this.tipoOperativa = 'responder';

			const modal = this.template.querySelector('[data-id="ModalboxResponderCliente"]');
			modal.classList.add('slds-fade-in-open');
			const backdrop = this.template.querySelector('[data-id="backdrop"]');
			backdrop.classList.add('slds-backdrop_open');

			this.loadCarpetasIdioma();

			this.template.querySelector('.modalResponderEmpleadoCancelar').focus();
		}
	}

	solicitarInfo() {
		let miTipoOperativa = this.tipoOperativa;
		let miPlantilla = this.plantillaSeleccionadaName;
		this.llamarBuzonEmail();

		//Se guarda el nombre de la plantilla para poder enviar el correo, con la plantilla correspondiente
		actualizarCaso({
			idCaso: this.recordId,
			plantilla: this.plantillaSeleccionadaValue,
			informarReferenciaCorreo: true,
			tratamiento: '',
			operativa: this.tipoOperativa,
			canalRespuesta: this.canalRespuesta,
			canalProcedencia: this.canalProcedencia,
			tipoRegistro: this.tipoRegistro
		})
			.then(() => {
				buscarCorreoContacto({idCaso: this.recordId})
				.then(result => {
					let operativa = '';
					if (miTipoOperativa === 'trasladar') {
						operativa = 'Traslado Colaborador';
					}

					if (miTipoOperativa === 'remitir') {
						operativa = 'Remitir Colaborador';
					}

					if (miTipoOperativa === 'solicitar') {
						operativa = 'Solicitud Información';
					}
					this.sendEmail(this.buzonEnviopordefecto, miPlantilla, operativa, result, '', this.grupoSeleccionadoName);
				})
				.catch(error => {

					console.error(error);

				});
				//this.result = result;
				//return refreshApex(this.result);
			})
			.catch(error => {
				console.error(error);
			});
		//Cierre del modal
		this.cerrarModalSolicitarInfo();
	}

	abrirModalSolicitarInfo() {
		//Solo se abre el modal de Solicitar info si el canal de respuesta es Email, Chat o vacío y si el campo canal operativa esta definido.

		let canalRespuesta = this.canalRespuesta;
		if (canalRespuesta === 'Email' || canalRespuesta === 'Chat' || canalRespuesta === 'Phone' || canalRespuesta === 'Backoffice' || canalRespuesta === '' || canalRespuesta === null) {
			this.tipoOperativa = 'solicitar';
			const modal = this.template.querySelector('[data-id="ModalboxSolicitarInfo"]');
			modal.classList.add('slds-fade-in-open');
			const backdrop = this.template.querySelector('[data-id="backdrop"]');
			backdrop.classList.add('slds-backdrop_open');
			this.loadCarpetasIdioma();
		}
	}

	loadCarpetasIdioma() {
		let operativa = this.tipoOperativa;
		let canalProcedencia = this.canalProcedencia;
		canalProcedencia = canalProcedencia.replace(/\s/g, '');
		let idioma = this.idioma;
		//let idiomaAux = this.idioma;
		let tipoRegistro = this.tipoRegistro;
		let carpetaOperativa;
		let carpetaGenerica;

		if (operativa === 'responder') {
			if (tipoRegistro === 'HDT_Empleado') {
				carpetaOperativa = 'HDT_Responder_Empleado'; //+ canalProcedencia;
			} else {
				carpetaOperativa = 'HDT_Responder_' + canalProcedencia;
			}

		} else if (operativa === 'solicitar') {
			//idioma = 'CC_Solicitar_' + canalProcedencia + '_' + idioma;
			if (tipoRegistro === 'HDT_Empleado') {
				carpetaOperativa = 'HDT_Solicitar_Empleado';
			}
		}

		existeCarpeta({carpetaDeveloperName: carpetaOperativa})
			.then(result4 => {
				this.existeCarpeta = result4;
				if (operativa === 'responder') {
					if (tipoRegistro === 'HDT_Empleado') {
						idioma = 'HDT_Responder_Empleado_' + idioma;
						carpetaGenerica = 'HDT_Responder_Empleado';
					} else {
						idioma = 'HDT_Responder_' + idioma;
						carpetaGenerica = 'HDT_Responder';
					}
				} else if (operativa === 'solicitar') {
					if (tipoRegistro === 'HDT_Empleado') {
						idioma = 'HDT_Solicitar_Empleado_' + idioma;
						carpetaGenerica = 'HDT_Solicitar_Empleado';
					} else {
						idioma = 'HDT_Solicitar_' + idioma;
						carpetaGenerica = 'HDT_Solicitar';
					}
				}
			})
			.catch(error => {
				console.error(error);
			});


		getCarpetas({carpetaDeveloperName: carpetaOperativa, carpetaGenerica: carpetaGenerica})
			.then(result5 => {
				let arr = result5;
				let opciones = [];
				arr.forEach(element => opciones.push({value: element.DeveloperName, label: element.Name}));
				this.carpetaIdiomaSeleccionada = true;
				this.idiomaPlantilla = idioma;
				this.opcionesIdiomaFolder = opciones;
				
				if (operativa === 'responder') {
					this.template.querySelector('[data-id="selectItemIdioma"]').value = idioma;

				} else if (operativa === 'solicitar') {
					this.template.querySelector('[data-id="selectItemIdiomaSol"]').value = idioma;
				}
				this.loadCarpetasTratamiento();
			})
			.catch(error => {
				console.error(error);
			});
	}

	obtenerPlantillasGrupoBuscar(event) {

		let grupoId;
		if (this.verTodosLosGrupos) {
			this.template.querySelector('.inputBuscarGruposTrasladar').value = event.currentTarget.dataset.name;
			this.grupoSeleccionadoValue = event.currentTarget.dataset.id;
			grupoId = event.currentTarget.dataset.id;
			this.grupoSeleccionadoName = event.currentTarget.dataset.name;
		}

		//Aqui buscamos las plantillas de los grupos seleccionados
		getPlantillaGrupoList({grupoId: grupoId, tipoOperativa: this.tipoOperativa})
			.then(result => {
				this.optionsPlantilla = result;
				this.grupoSeleccionado = true;
				this.plantillas = result;
			});

	}

	obtenerPlantillasGrupo(event) {

		let grupoId;
		if (this.verTodosLosGrupos) {

			grupoId = this.selectedRecord.Id;
			this.grupoSeleccionadoValue = grupoId;
			this.grupoSeleccionadoName = this.selectedRecord.Name;
		} else {
			grupoId = event.detail.value;
			this.actualFirstOptionGrupo = grupoId;
			let picklistFirstOptionsGrupo = this.optionsGrupo;
			for (let key in picklistFirstOptionsGrupo) {
				if (grupoId === picklistFirstOptionsGrupo[key].value) {
					this.grupoSeleccionadoValue = picklistFirstOptionsGrupo[key].value;
					this.grupoSeleccionadoName = picklistFirstOptionsGrupo[key].label;
				}
			}
		}

		//Aqui buscamos las plantillas de los grupos seleccionados
		getPlantillaGrupoList({grupoId: grupoId, tipoOperativa: this.tipoOperativa})
			.then(result => {

				this.optionsPlantilla = result;
				this.plantillas = result;
				this.grupoSeleccionado = true;

			});
	}


	buscarPlantillasResponder(event, cadenaBusqueda) {

		let tratamiento = this.tratamiento;
		let operativa = this.tipoOperativa;
		let tipoRegistro = this.tipoRegistro;

		if (operativa === 'remitir') {
			if (tipoRegistro === 'HDT_Empleado') {
				tratamiento = 'HDT_Remitir_Empleado_es';
			} else {
				tratamiento = 'HDT_Remitir_es';
			}

		} else if (operativa === 'trasladar') {
			if (tipoRegistro === 'HDT_Empleado') {
				tratamiento = 'HDT_Trasladar_Empleado_es';
			} else {
				tratamiento = 'HDT_Trasladar_es';
			}
		}

		buscarPlantillasResponder({cadenaBusqueda: cadenaBusqueda, carpeta: tratamiento})
			.then(result => {
				let state = result;
				if (state === 'SUCCESS') {
					let storeResponse = state;
					if (storeResponse.length === 0) {
						this.message = 'No hay resultados.';
					}
					this.listOfSearchRecordsPlantilla = storeResponse;
				}
			});
	}

	teclaPulsadaLookupPlantilla2(event) {

		let getInputkeyWord = this.template.querySelector('[data-id="SearchKeyWordPlantilla"]');
		if (getInputkeyWord.length > 2) {

			this.buscarPlantillasResponder(event, getInputkeyWord);
		} else {

			this.listOfSearchRecordsPlantilla = null;
		}
	}

	teclaPulsadaLookupPlantilla(event) {

		let searchRes = this.template.querySelector('[data-id="searchResPlantilla"]');
		let getInputkeyWord = this.SearchKeyWordPlantilla;

		if (getInputkeyWord.length) {

			searchRes.classList.add('slds-is-open');
			searchRes.classList.remove('slds-is-close');

			if (getInputkeyWord.length > 2) {
				this.buscarPlantillasResponder(event, getInputkeyWord);
			}
		} else {

			searchRes.classList.add('slds-is-close');
			searchRes.classList.remove('slds-is-open');
			this.listOfSearchRecordsPlantilla = null;
		}
	}


	deseleccionarPlantilla() {
		//Eliminar el grupo seleccionado
		let pillTarget = this.template.querySelector('[data-id="lookup-pill-plantilla"]');

		pillTarget.classList.remove('slds-show');
		pillTarget.classList.add('slds-hide');

		let lookUpTarget = this.template.querySelector('[data-id="lookupFieldPlantilla"]');
		lookUpTarget.classList.add('slds-show');
		lookUpTarget.classList.remove('slds-hide');

		this.SearchKeyWordPlantilla = null;
		this.listOfSearchRecordsPlantilla = null;
		this.plantillaSeleccionadaValue = null;
		this.plantillaSeleccionadaName = null;
		this.plantillaEstaSeleccionada = false;
		this.plantillaSeleccionada = null;
	}

	cerrarModalTrasladarColaborador() {

		const selectGroups = this.template.querySelector('[data-id="selectGroups"]');
		if (selectGroups) {
			selectGroups.value = null;
		}

		this.plantillaSeleccionadaValue = null;
		this.plantillaSeleccionadaName = '';
		this.grupoSeleccionadoValue = '';
		this.grupoSeleccionadoName = '';
		this.actualFirstOptionPlantilla = '';
		this.actualFirstOptionGrupo = '';
		this.optionsPlantilla = null;
		this.optionsGrupo = null;
		this.verTodosLosGrupos = false;
		this.grupoSeleccionado = false;
		this.plantillaEstaSeleccionada = false;
		this.listOfSearchRecords = null;

		//Eliminar el grupo seleccionado
		let pillTarget = this.template.querySelector('[data-id="lookup-pill"]');

		if (pillTarget) {
			if (pillTarget.classList.contains('slds-show')) {
				pillTarget.classList.remove('slds-show');
				pillTarget.classList.add('slds-hide');
			} else {
				pillTarget.classList.remove('slds-hide');
				pillTarget.classList.add('slds-show');
			}
		}

		this.template.querySelector('[data-id="ModalboxColab"]').classList.remove('slds-fade-in-open');
		this.template.querySelector('[data-id="backdrop"]').classList.remove('slds-backdrop_open');

	}

	buscarGruposColaboradores(cadenaBusqueda) {
		buscarGruposColaboradores({cadenaBusqueda: cadenaBusqueda, negocio: 'HDT'})
			.then(result => {
				if (!result.length) {
					this.message = 'No hay resultados.';
				}
				this.listOfSearchRecords = result;
			});
	}

	teclaPulsadaLookupGrupoColaborador() {
		let searchRes = this.template.querySelector('[data-id="searchRes"]');
		let cadenaBusqueda = this.template.querySelector('.inputBuscarGrupos').value;
		let numero = cadenaBusqueda.length;
		if (numero === 0) {
			searchRes.classList.add('slds-is-close');
			searchRes.classList.remove('slds-is-open');
		} else {
			searchRes.classList.remove('slds-is-close');
			searchRes.classList.add('slds-is-open');
			this.buscarGruposColaboradores(cadenaBusqueda);
		}
	}


	loadCarpetasTratamiento() {
		let opcionesTratamientoFolder = [];
		let idioma = this.idiomaPlantilla;
		getCarpetas({carpetaDeveloperName: idioma, carpetaGenerica: ''})
			.then(result => {
				result.forEach(element => {
					opcionesTratamientoFolder.push({value: element.DeveloperName, label: element.Name});
				});
				this.opcionesTratamientoFolder = opcionesTratamientoFolder;
			})
			.catch(error => {
				console.error(error);
			});

		if (opcionesTratamientoFolder.length === 0) {
			this.procesoFinalSeleccion = true;
			this.idiomaPlantilla = idioma;
			//this.loadPlantillas();                          ¡ OJO PORQUE ESTE METODO NO EXISTE EN EL HELPER !
		} else {
			this.carpetaIdiomaSeleccionada = true;
		}
	}

	getPicklistMCCGrupo() {
		getMCCGrupoList({recordId: this.recordId, tipoGrupo: ''})
			.then(result2 => {
				this.optionsGrupo = result2;
			});
	}

	//Funcion para abrir modal de traslado o remitir a Colaborador
	abrirModalTrasladarColaborador() {

		if (this.botonOperativa === 'Trasladar Colaborador') {
			this.remitir = false;
			this.tipoOperativa = 'trasladar';
		} else {
			this.tipoOperativa = 'remitir';
			this.remitir = true;
		}

		this.getPicklistMCCGrupo();

		this.template.querySelector('[data-id="ModalboxColab"]').classList.add('slds-fade-in-open');
		this.template.querySelector('[data-id="backdrop"]').classList.add('slds-backdrop_open');

		//Poner el foco en el desplegable de grupos al abrir el modal
		this.template.querySelector('.modalTrasladarCancelar').focus();
	}

	//Funciones referentes al Trasladar a 3N
	abrirModalTrasladar3N() {

		this.getPicklistMCCGrupo3N();
		this.template.querySelector('[data-id="Modalbox3Nivel"]').classList.add('slds-fade-in-open');
		this.template.querySelector('[data-id="backdrop"]').classList.add('slds-backdrop_open');

		//Poner el foco en el desplegable de grupos al abrir el modal
		this.template.querySelector('.modalTrasladar3NCancelar').focus();

	}

	get remitirDevolver1N() {

		let textoadevolver = '';

		if (this.nombreBoton === 'Devolver Nivel 1') {
			textoadevolver = 'Devolver a 1N';
		} else {
			textoadevolver === 'Rechazar traslado';
		}

		return textoadevolver;
	}

	get remitirDevolver1NFooter() {

		let textoadevolver = '';
		if (this.nombreBoton === 'Devolver Nivel 1') {
			textoadevolver = 'Devolver';
		} else {
			textoadevolver = 'Rechazar';
		}

		return textoadevolver;
	}

	getPicklistMCCGrupo3N() {
		getMCCGrupoList({recordId: this.recordId, tipoGrupo: '3N'})
			.then(grupos3N => {
				this.resultadosGrupoTercerNivel = grupos3N;
			});
	}

	//Funciones referentes al Devolver a 1N
	abrirModalDevolver1N() {

		let nombreBoton = this.botonOperativa;

		if (nombreBoton === 'Devolver Nivel 1') {
			this.tipoTarea = 'devolver';
			this.template.querySelector('[data-id="ModalboxDevolver1N"]').classList.add('slds-fade-in-open');
			this.template.querySelector('[data-id="backdrop"]').classList.add('slds-backdrop_open');
		} else if (nombreBoton === 'Rechazar Nivel 1') {
			this.tipoTarea = 'rechazar';
			this.template.querySelector('[data-id="ModalboxDevolver1N"]').classList.add('slds-fade-in-open');
			this.template.querySelector('[data-id="backdrop"]').classList.add('slds-backdrop_open');
		}
		//Poner el foco en el desplegable de grupos al abrir el modal
		const selectGroups = this.template.querySelector('[data-id="inputMotivoDevolucion"]');
		if (selectGroups) {
			selectGroups.focus();
		}
	}

	abrirQuickActionIncidencia() {
		this.dispatchEvent(new CustomEvent('rellenarincidencia', {detail: {}}));
	}

	mostrarToast(tipo, titulo, mensaje) {
		this.dispatchEvent(new ShowToastEvent({variant: tipo, title: titulo, message: mensaje, mode: 'dismissable', duration: 4000}));
	}

	vincularLlamadaEnCurso() {
		vincularLlamada({recordId: this.recordId})
			.then(reponse => {
				this.mostrarToast('success', 'Se vinculó caso con llamada en curso', 'Se vinculó correctamente la llamada en curso ' + reponse + ' al caso');
			})
			.catch(error => {
				console.error(error);
				this.mostrarToast('info', 'Problema vinculando caso a llamada', error.body.message);
			});
	}

	/*
	obtenerUltimosDosCaracteres(carpetaPlantilla) {
		//Usando expresiones regulares para obtener los últimos dos caracteres del string
		let ultimosCaracteres = carpetaPlantilla.match(/[a-zA-Z]{2}$/);

		//Verificar si se encontraron los últimos dos caracteres y obtenerlos
		let resultado = ultimosCaracteres ? ultimosCaracteres[0] : '';

		return resultado;
	}
	*/
}