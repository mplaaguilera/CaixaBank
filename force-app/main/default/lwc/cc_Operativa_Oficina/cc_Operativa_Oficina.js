import {LightningElement, api, track, wire} from 'lwc';
import {NavigationMixin} from 'lightning/navigation';
import {ShowToastEvent} from 'lightning/platformShowToastEvent';
import {refreshApex} from '@salesforce/apex';
import getDatos from '@salesforce/apex/CC_Operativa_Oficina_Controller.getDatos';
import crearTarea from '@salesforce/apex/CC_Operativa_Oficina_Controller.crearTarea';
import buscarOficinas from '@salesforce/apex/CC_Operativa_Oficina_Controller.buscarOficinas';
import altaCitaGestor from '@salesforce/apex/CC_Operativa_Oficina_Controller.altaCitaGestor';
import esClienteDigital from '@salesforce/apex/CC_Operativa_Oficina_Controller.esClienteDigital';
import dniTestamentaria from '@salesforce/apex/CC_Operativa_Oficina_Controller.dniTestamentaria';
import crearOportunidad from '@salesforce/apex/CC_Operativa_Oficina_Controller.crearOportunidad';
import realizarTraslado3N from '@salesforce/apex/CC_Operativa_Oficina_Controller.realizarTraslado3N';
import buscarGestoresGlobal from '@salesforce/apex/CC_Operativa_Oficina_Controller.buscarGestoresGlobal';
import getUrlNumeroOficinaApex from '@salesforce/apex/CC_Operativa_Oficina_Controller.getUrlNumeroOficina';
import obtenerGestoresBackup from '@salesforce/apex/CC_Operativa_Oficina_Controller.obtenerGestoresBackup';
import recuperarCampoDerivar from '@salesforce/apex/CC_Operativa_Oficina_Controller.recuperarCampoDerivar';
import obtenerFechasDisponiblidadGestor from '@salesforce/apex/CC_Operativa_Oficina_Controller.obtenerFechasDisponiblidadGestor';
import obtenerHorasDisponiblidadGestor from '@salesforce/apex/CC_Operativa_Oficina_Controller.obtenerHorasDisponiblidadGestor';
//import buscarGestores from '@salesforce/apex/CC_Operativa_Oficina_Controller.buscarGestores';
//import preguntaEnrollmentDatosSi from '@salesforce/apex/CC_Operativa_Oficina_Controller.preguntaEnrollmentDatosSi';

export default class ccOperativaOficina extends NavigationMixin(LightningElement) {
	
	@api recordId;
	
	@track gestores = [];
	
	showSpinner = false;
		
	mostrarBuscadorOficina = false;

	mostrarModalDNITestamentaria = false;
	
	mostrarModalCita;
	
	alertaTexto;
	
	esClienteDigital;
	
	tieneGestor;
	
	numeroGestor;
	
	numeroGestorKO = false;
	
	nombreGestor;

	fecha;
	
	gestorGenerico = false;
	
	oficinaGestor;
	
	nombreGestorAsignado;
	
	gestorAsignadoCoincide = true;
	
	mensajeErrorInt;
	
	cargandoGestor;
	
	gestor;

	dni;
	
	motivoVentas;
	
	cambioOficina = false;
	
	cambioGestor = false;
	
	mostrarModalGestionGestorAsignado;
	
	mostrarModalGestionGestorGenerico;
	
	mostrarModalCreacionTarea;
	
	ocultarOpcionCitaGestor;
	
	fechasDisponibilidad;
	
	horasDisponibilidad;
	
	disponibilidadConsultada;
	
	existeBackup;
	
	gestorBackupActivoDos;
	
	gestorElegido;
	
	nombreGestorElegido;
	
	lookupOficinaResultadoSeleccionado = '';
	
	lookupOficinaInputValue = '';
	
	lookupOficinaResultados = [];
	
	oficinaPrincipal;
	
	lookupOficinaTimeout;
	
	lookupGestorResultadoSeleccionado = '';
	
	lookupGestorInputValue = '';
	
	lookupGestorResultados = [];
	
	lookupGestorTimeout;
	
	enviarTareaOficinaCliente = false;
	
	mostrarTareaModalCitaGestor = false;
	
	mostrarBuscadorGestor = false;
	
	crearTareaCitaGestor = false;
	
	tipoCita = 42;
	
	clienteTieneGestor = false;
	
	ocultarBotonCita = false;
	
	horaCitaSelecionada;
	
	grupoColaborador;
	
	preguntaGrupoColaborador;
	
	comentariosTarea;
	
	realizarRemitido;
		
	preguntaCajeros;
	
	preguntaCajerosExternos;
	
	preguntaRealizarRemitido;

	preguntaSenal;

	toastRemitir;

	toastCajerosExternos;

	toastDniInvalido;

	urlCajeros;

	_wiredDatosResult;

	toastTrasladarDesdeDerivar;

	derivar = false;

	archivos = [];

	mostrarModalPreguntaRealizarRemitido = false;

	mostrarModalPreguntaEnrollmentDatos= false;

	flowDerivar = false;

	mostrarFlowDerivar = false;

	toastNoClienteError;
	
	//preguntaEnrollment;

	//preguntaEnrollmentDatos;

	toastEnrollmentNo;

	//toastEnrollmentDatosSi;

	//toastEnrollmentDatosNo;

	preguntaCSBDContratar;

	preguntaCSBDContratar2;

	toastCrearOportunidad;

	toastCSBDNoContratar;

	urlTF;

	ambitoFraude;

	realizarRemitidoDesdeMetodo;

	toastCajerosIncidencias;

	tituloCajerosIncidencias;

	toastNoCliente;

	gestorGenericoName;

	filterGestor = {
		criteria: [
			{
				fieldPath: 'RecordType.DeveloperName',
				operator: 'eq',
				value: 'CC_Empleado'
			},
			/*{
				fieldPath: 'Account',
				operator: 'eq',
				value: this.oficinaPrincipal
			}, */
			{
				fieldPath: 'Account.RecordType.DeveloperName',
				operator: 'eq',
				value: 'CC_CentroCaixaBank'
			}
		]
	};
	
	displayInfoGestor = {
		primaryField: 'Name',
		additionalFields: ['CC_Matricula__c']
	};
	
	opcionesCitaDigital = [{label: 'Llamada telefónica', value: '43'}];
	
	opcionesCita = [
		{label: 'Entrevista', value: '42'},
		{label: 'Llamada telefónica', value: '43'}
	];
	
	@wire(getDatos, {recordId: '$recordId'})
	wiredDatos(response) {
		let error = response && response.error;
		let data = response && response.data;
		this._wiredDatosResult = response;
		refreshApex(this._wiredDatosResult);
		if (error) {
			console.error(error);
			this.toast('error', 'Problema recuperando los datos principales', error.body.message);
			this.cerrarModal();
		} else if (data) {
			const resultado = data;
			this.fecha = new Date().toISOString().substring(0, 10);
			this.derivar = resultado.derivar;
			this.toastTrasladarDesdeDerivar = resultado.toastTrasladarDesdeDerivar;
			this.ambitoFraude = resultado.ambitoFraude;
			this.grupoColaborador = resultado.grupoColaborador;
			this.alertaTexto = resultado.alerta;
			this.toastCSBDNoContratar = resultado.toastCSBDNoContratar;
			this.toastNoClienteError = resultado.toastNoClienteError;
			this.toastTrasladar3N = resultado.toastTrasladar3N;
			this.realizarRemitidoDesdeMetodo = resultado.realizarRemitido;
			this.toastCajerosIncidencias = resultado.toastCajerosIncidencias;
			this.tituloCajerosIncidencias = resultado.tituloCajerosIncidencias;
			this.toastNoCliente = resultado.toastNoCliente;
			this.oficinaPrincipal = resultado.oficinaPrincipal;
			this.gestorGenericoName = resultado.gestorGenericoName;
			console.log('VM data resultado.gestorGenericoName ' + this.gestorGenericoName);
			if(this.oficinaPrincipal) {
				for(let i = 0; i < resultado.gestores.length; i++) {
					this.gestores.push({label: resultado.gestores[i].Name, value: resultado.gestores[i].Id});
				}
			}
			if(this.toastTrasladar3N && !this.alertaTexto && !this.ambitoFraude && !this.grupoColaborador) {
				this.realizarTraslado3N();
			}
			if(this.realizarRemitidoDesdeMetodo && !this.alertaTexto && !this.grupoColaborador && !this.ambitoFraude) {
				this.handleRemitir();
			} else if (this.realizarRemitidoDesdeMetodo && (this.alertaTexto || this.grupoColaborador || this.ambitoFraude)) {
				this.abrirModal();
			}
			if(resultado.preguntaCSBDContratar) {
				this.preguntaCSBDContratar = resultado.preguntaCSBDContratar;
				this.preguntaCSBDContratar2 = resultado.preguntaCSBDContratar2;
				this.toastCrearOportunidad = resultado.toastCrearOportunidad;
			}
			if(this.toastCSBDNoContratar && !this.alertaTexto && !this.grupoColaborador && !this.ambitoFraude) {
				this.crearOportunidad();
			}
			if(this.toastCajerosIncidencias && !this.alertaTexto && !this.grupoColaborador && !this.ambitoFraude) {
				this.toast('error', this.tituloCajerosIncidencias, resultado.toastCajerosIncidencias);
				this.cerrarModal();
			} else if (this.toastCajerosIncidencias && (this.alertaTexto || this.grupoColaborador || this.ambitoFraude)) {
				this.abrirModal();
			}
			if(this.toastNoClienteError && !this.alertaTexto && !this.grupoColaborador && !this.ambitoFraude) {
				this.toast('error', 'Error en los datos', resultado.toastNoClienteError);
				this.cerrarModal();
			} else {
				this.abrirModal();
			}
			if(resultado.preguntaCajeros) {
				this.preguntaCajeros = resultado.preguntaCajeros;
				this.preguntaCajerosExternos = resultado.preguntaCajerosExternos;
				this.toastCajerosExternos = resultado.toastCajerosExternos;
				this.urlCajeros = resultado.urlCajeros;
			}
			/*if(resultado.preguntaEnrollment){
				this.preguntaEnrollment= resultado.preguntaEnrollment;
				this.preguntaEnrollmentDatos= resultado.preguntaEnrollmentDatos;
				//this.toastEnrollmentNo = resultado.toastEnrollmentNo;
				this.toastEnrollmentDatosSi = resultado.toastEnrollmentDatosSi;
				this.toastEnrollmentDatosNo = resultado.toastEnrollmentDatosNo;
			}*/
			if(resultado.preguntaRealizarRemitido) {
				this.preguntaSenal = resultado.preguntaSenal;
				this.toastRemitir = resultado.toastRemitir;
				this.preguntaRealizarRemitido = resultado.preguntaRealizarRemitido;
				if(!resultado.toastCajerosIncidencias && !this.alertaTexto && !this.grupoColaborador && !this.ambitoFraude) {
					this.abrirModal();
				}
			} /*else {*/
				if(resultado.comentarioCambioGestor) {
					this.comentariosTarea = resultado.comentarioCambioGestor;
				} else if(resultado.comentarioCambioOficina) {
					this.comentariosTarea = resultado.comentarioCambioOficina;
				}
				/*this.grupoColaborador = resultado.grupoColaborador;
				this.alertaTexto = resultado.alerta;*/
				this.preguntaGrupoColaborador = resultado.preguntaGrupoColaborador;
				this.gestor = resultado.gestor;
				this.motivoVentas = resultado.motivoVentas;
				this.mostrarModalGestionGestorAsignado = resultado.mostrarModalGestionGestorAsignado;
				this.mostrarModalGestionGestorGenerico = resultado.mostrarModalGestionGestorGenerico;
				this.mostrarModalCreacionTarea = resultado.mostrarModalCreacionTarea;
				this.mostrarModalDNITestamentaria = resultado.mostrarModalDNITestamentaria;
				//this.toastDniInvalido = resultado.toastDniInvalido;
				this.cambioOficina = resultado.cambioOficina;
				this.cambioGestor = resultado.cambioGestor;
				this.clienteTieneGestor = resultado.clienteTieneGestor;
				this.flowDerivar = resultado.flowDerivar;
				this.urlTF = resultado.urlTF;
				this.numperso = resultado.numperso;
				this.nif = resultado.nif;
				if((this.grupoColaborador === null || this.grupoColaborador === undefined) && this.flowDerivar === true){
					this.mostrarFlowDerivar = this.flowDerivar;
				}
				if(this.comentariosTarea === undefined) {
					this.comentariosTarea = resultado.detallesConsulta;
				}				
				if (!this.alertaTexto && !this.toastTrasladar3N && !this.toastCSBDNoContratar) {
					this.handleContinuarProceso();
				}
				this.llamadaIntegracionClienteDigital();
				if(!resultado.toastCajerosIncidencias && !this.alertaTexto && !this.grupoColaborador && !this.ambitoFraude && !this.realizarRemitidoDesdeMetodo) {
					this.abrirModal();
				}
			//}
		}
		window.setTimeout(() =>	this.dispatchEvent(new CustomEvent('desactivarspinner', {detail: {data: null}})), 400);
	}

	async recuperarCampoDerivar() {
		let resultado = false;
		recuperarCampoDerivar({recordId: this.recordId})
		.then(retorno => {
			resultado = retorno;
		})
		.catch(error => {
			console.error(error);
			this.toast('error', 'Problema recuperando los datos de campo derivar', error.body.message);
			this.cerrarModal();
		}).finally(() => this.derivar = resultado);
	}
	
	abrirModal() {
		this.template.querySelector('.modal').classList.add('slds-fade-in-open');
		this.template.querySelector('.backdrop').classList.add('slds-backdrop--open');
	}
	
	cerrarModal() {
		this.template.querySelector('.backdrop').classList.remove('slds-backdrop--open');
		this.template.querySelector('.modal').classList.remove('slds-fade-in-open');
		//eslint-disable-next-line @lwc/lwc/no-async-operation
		window.setTimeout(() =>	this.dispatchEvent(new CustomEvent('modalcerrado', {detail: {data: null}})), 400);
	}
	
	handleContinuarProceso() {
		this.alertaTexto = false;
		if((!this.grupoColaborador || this.toastTrasladar3N) && !this.ambitoFraude) {
			this.handleGrupoColaboradorDerivar();
		}
		if (this.mostrarModalCita) {
			this.mostrarModalCita = false;
		}
	}
	
	ocultarModalCitaGestor() {
		this.mostrarModalCita = false;
		this.mostrarModalCreacionTarea = true;
		this.crearTareaCitaGestor = true;
	}

    handleUploadFinished(event) {
        const uploadedFiles = event.detail.files;
		
		this.archivos = uploadedFiles;
    }
	
	handleCrearTareaGestor() {
		if(!this.template.querySelector('.comentariosTarea').value || !this.template.querySelector('.fechaActividad').value) {
			this.toast('warning', 'Campos vacíos', 'Por favor, informe todos los campos del formulario');
		} else {
			this.showSpinner = true;
			crearTarea({
				recordId: this.recordId,
				asunto: 'Solicitud contacto gestor (Contact Center)',
				fechaActividad: this.template.querySelector('.fechaActividad').value,
				comentarios: this.template.querySelector('.comentariosTarea').value,
				archivos : this.archivos == null ? null : this.archivos.map(item => item.contentVersionId),
				oficinaDestino: this.lookupOficinaResultadoSeleccionado.Id,
				enviarTareaOficinaCliente: this.enviarTareaOficinaCliente,
				crearTareaCitaGestor: this.crearTareaCitaGestor,
				gestorSeleccionadoBuscador: this.lookupGestorResultadoSeleccionado
			}).then(resultado => {
				if (!resultado.cuenta || !resultado.cuenta.Id) {
					this.toast('Success', 'Tarea creada con éxito', resultado.mensaje);
				} else {
					this.mostrarToastOficinaResultado(resultado.mensaje, resultado.cuenta.Id, 'Tarea');
				}
				this.cerrarModal();
			}).catch(error => {
				console.error(error);
				this.toast('error', 'Problema creando la tarea', error.body.message);
				this.cerrarModal();
			});
		}
	}
	
	mostrarToastOficinaResultado(mensajeToast, idCuenta, tipo) {
		getUrlNumeroOficinaApex({recordId: idCuenta})
		.then(resultado => {
			if (resultado.url) {
				this.toast('success', tipo + ' creada con éxito', mensajeToast + ' {1}', ['Salesforce', {
					url: resultado.url, label: resultado.numeroOficina
				}]);
			}
		});
	}
	
	toast(variant, title, message, messageData) {
		this.dispatchEvent(new ShowToastEvent({
			variant,
			title,
			message,
			mode: messageData ? 'sticky' : 'dismissable',
			duration: messageData ? null : 9000,
			messageData
		}));
	}
	
	async llamadaIntegracionClienteDigital() {
		this.cargandoGestor = true;
		try {
			const resultado = await esClienteDigital({recordId: this.recordId, tipoActividad: ''});
			console.log('VM DATOS '  + JSON.stringify(resultado));
			if (resultado.resultado === 'OK') {
				this.esClienteDigital = resultado.clienteDigital;
				if (resultado.empleado1) {
					this.tieneGestor = true;
					this.numeroGestor = resultado.empleado1;
					this.nombreGestor = resultado.gestorClienteName;
					this.oficinaGestor = resultado.oficina1;
					if (this.oficinaGestor === '3223' || this.oficinaGestor === '03223') {
						this.ocultarOpcionCitaGestor = true;
					}
				} else {
					console.log('VM resultado.gestorClienteName ' + resultado.gestorClienteName);
					console.log('VM resultado.gestorGenericoName ' + this.gestorGenericoName);
					if (resultado.gestorClienteName === this.gestorGenericoName) {
						this.nombreGestor = resultado.gestorClienteName;
						this.gestorGenerico = true;
						this.nombreGestorAsignado = resultado.nombreGestorAsignado;
					}
				}
				if (resultado.gestorAsignadoCoincide === 'false') {
					this.gestorAsignadoCoincide = false;
					this.nombreGestorAsignado = resultado.nombreGestorAsignado;
				}
			} else if (resultado.resultado === 'KO') {
				console.log('VM DATOS '  + JSON.stringify(resultado));
				this.numeroGestor = 'KO';
				this.numeroGestorKO = true;
				this.mensajeErrorInt = resultado.mensajeError;
			}
		} catch (error) {
			console.error(error);
			this.toast('error', 'Problema recuperando los datos desde la integración', error.body.message);
			this.cerrarModal();
		} finally {
			this.cargandoGestor = false;
			console.log('VM gestorAsignadoCoincide ' + this.gestorAsignadoCoincide);
			console.log('VM gestorGenerico ' + this.gestorGenerico);
		}
	}
	
	modalTeclaPulsada(event) {
		if (event.keyCode === 27) { //ESC
			this.cerrarModal();
		}
	}
	
	handleAbrirModalCita() {
		this.mostrarModalCita = true;
		this.mostrarModalGestionGestorAsignado = false;
	}
	
	handleGestionGestorDistintoSi() {
		this.mostrarModalCreacionTarea = true;
		this.mostrarModalGestionGestorGenerico = false;
		this.enviarTareaOficinaCliente = true;
		this.mostrarModalCita = false;
	}
	
	handleGestionGestorDistintoNo() {
		this.mostrarModalCreacionTarea = true;
		this.mostrarModalGestionGestorGenerico = false;
		this.enviarTareaOficinaCliente = false;
		this.cambioOficina = true;
		this.mostrarBuscadorOficina = true;
	}
	
	handleGestionGestorAsignadoNo() {
		this.mostrarModalCreacionTarea = true;
		this.mostrarModalGestionGestorAsignado = false;
		this.mostrarBuscadorGestor = true;
	}
	
	resetDisponibilidadConsultada(event) {
		this.disponibilidadConsultada = false;
		this.ocultarBotonCita = true;
		this.tipoCita = event.detail.value;
	}
	
	mostrarGestorBackup() {
		if (gestorBackupActivo) {
			this.fechasDisponibilidad = null;
			this.horasDisponibilidad = null;
			this.disponibilidadConsultada = false;
			this.ocultarBotonCita = true;
			obtenerGestoresBackup({recordId: this.recordId, numeroGestor, numeroGestor, tipoCita})
			.then(resultado => {
				this.gestoresBackup = resultado;
				if (!resultado) {
					this.existeBackup = true;
				}
				this.gestorBackupActivoDos = true;
			})
			.catch(error => {
				console.error(error);
				this.toast('error', 'Problema recuperando los datos del gestor backup', error.body.message);
				this.cerrarModal();
			});
		} else {
			this.gestorBackupActivoDos = false;
			this.fechasDisponibilidad = null;
			this.horasDisponibilidad = null;
			this.disponibilidadConsultada = false;
			this.ocultarBotonCita = true;
		}
	}
	
	consultarFechasDisponibilidadGestor() {
		var codigoEvento;
		if(this.tipoCita == 'LLamada telefónica') {
			codigoEvento = '43';
		} else {
			codigoEvento = '42';
		}
		obtenerFechasDisponiblidadGestor({recordId: this.recordId, employeeId: this.numeroGestor, gestorElegidoId: this.numeroGestor, eventType: codigoEvento})
		.then(resultado => {
			this.disponibilidadConsultada = true;
			this.ocultarBotonCita = false;
			this.fechasDisponibilidad = resultado;
		})
		.catch(error => {
			console.error(error);
			this.toast('error', 'Problema recuperando los datos de disponibilidad de fechas del gestor', error.body.message);
			this.cerrarModal();
		});
	}
	
	consultarHorasDisponibilidadGestor() {
		var codigoEvento;
		if(this.tipoCita == 'LLamada telefónica') {
			codigoEvento = '43';
		} else {
			codigoEvento = '42';
		}
		let fechasDisponibilidad = this.template.querySelector('lightning-combobox').value;
		obtenerHorasDisponiblidadGestor({recordId: this.recordId, employeeId: this.numeroGestor, gestorElegidoId: this.numeroGestor, eventType: codigoEvento, fechaElegida: fechasDisponibilidad})
		.then(resultado => {
			this.horasDisponibilidad = resultado;
		})
		.catch(error => {
			console.error(error);
			this.toast('error', 'Problema recuperando los datos de disponibilidad de horas del gestor', error.body.message);
			this.cerrarModal();
		});
		this.gestorElegido =  this.numeroGestor;
		this.nombreGestorElegido = this.nombreGestor;
	}
	
	guardarHorasDisponibilidad(event) {
		this.horaCitaSelecionada = event.detail.value;
	}
	
	consultarFechasDisponibilidadBackup() {
		obtenerFechasDisponiblidadGestor({recordId, numeroGestor, numeroGestor, tipoCita})
		.then(resultado => {
			this.disponibilidadConsultada = true;
			this.ocultarBotonCita = false;
			this.fechasDisponibilidad = resultado;
		})
		.catch(error => {
			console.error(error);
			this.toast('error', 'Problema recuperando los datos de disponiblidad de fechas del gestor backup', error.body.message);
			this.cerrarModal();
		});
	}
	
	consultarHorasDisponibilidadBackup() {
		let fechasDisponibilidad = this.template.querySelector('lightning-combobox').value;
		obtenerHorasDisponiblidadGestor({recordId, numeroGestor, numeroGestor, tipoCita, fechasDisponibilidad})
		.then(resultado => {
			this.horasDisponibilidad = resultado;
		})
		.catch(error => {
			console.error(error);
			this.toast('error', 'Problema recuperando los datos de disponiblidad de horas del gestor backup', error.body.message);
			this.cerrarModal();
		});		
		component.set('v.gestorElegido', component.find('gestoresBackup').get('v.value'));
		let gestorSeleccionado = component.find('gestoresBackup').get('v.value');
		let labelGestoreleccionado = component.get('v.gestoresBackup').find(gestor => gestor.value === gestorSeleccionado).label;
		component.set('v.nombreGestorElegido', labelGestoreleccionado);
		
	}
	
	lookupDeseleccionar() {
		if(this.comentariosTarea) {
			const comentariosTareaReplace = this.comentariosTarea.replace(this.lookupOficinaResultadoSeleccionado.Name + '.', '[oficina destino]');
			if(comentariosTareaReplace.includes(this.lookupOficinaResultadoSeleccionado.Name)) {
				let t = 0;
				const regex = new RegExp(this.lookupOficinaResultadoSeleccionado.Name, 'g');
				this.comentariosTarea = this.comentariosTarea.replace(regex, match => ++t === 2 ? '[oficina destino]' : match);
			} else {
				this.comentariosTarea = comentariosTareaReplace;
			}
		}
		this.lookupOficinaResultadoSeleccionado = null;
		//eslint-disable-next-line @lwc/lwc/no-async-operation
		window.setTimeout(() => {
			this.lookupOficinaAbrir();
			this.template.querySelector('.lookupOficinaInput').focus();
		}, 200);
	}
	
	lookupOficinaOnchange(event) {
		this.lookupOficinaInputValue = event.detail.value;
		window.clearTimeout(this.lookupOficinaTimeout);
		if (this.lookupOficinaInputValue.length > 2) {
			//eslint-disable-next-line @lwc/lwc/no-async-operation
			this.lookupOficinaTimeout = window.setTimeout(() => this.buscarOficinas(this.lookupOficinaInputValue), 500);
		} else {
			event.target.isLoading = false;
			this.template.querySelector('.lookupOficina').classList.remove('slds-is-open');
			this.lookupOficinaResultados = [];
		}
	}
	
	lookupOficinaAbrir() {
		const lookupOficinaInput = this.template.querySelector('.lookupOficinaInput');
		lookupOficinaInput.setCustomValidity('');
		lookupOficinaInput.reportValidity();
		if (this.lookupOficinaInputValue.length > 1) {
			this.template.querySelector('.lookupOficina').classList.add('slds-is-open');
		}
	}
	
	lookupOficinaCerrar() {
		//eslint-disable-next-line @lwc/lwc/no-async-operation
		window.setTimeout(() => {
			const lookupOficina = this.template.querySelector('.lookupOficina');
			if (lookupOficina) {
				lookupOficina.classList.remove('slds-is-open');
			}
		}, 150);
	}
	
	lookupOficinaSeleccionar(event) {
		const oficina = this.lookupOficinaResultados.find(c => c.Id === event.currentTarget.dataset.id);
		this.lookupOficinaResultadoSeleccionado = oficina;
		if(this.comentariosTarea) {
			this.comentariosTarea = this.comentariosTarea.replace('[oficina destino]', this.lookupOficinaResultadoSeleccionado.Name);
		}
	}
	
	lookupGestorDeseleccionar() {		
		this.lookupGestorResultadoSeleccionado = null;
		//eslint-disable-next-line @lwc/lwc/no-async-operation
		window.setTimeout(() => {
			this.lookupGestorAbrir();
			this.template.querySelector('.lookupGestorInput').focus();
		}, 200);
	}
	
	lookupGestorOnchange(event) {
		this.lookupGestorInputValue = event.detail.value;
		window.clearTimeout(this.lookupGestorTimeout);
		if (this.lookupGestorInputValue.length > 2) {
			//eslint-disable-next-line @lwc/lwc/no-async-operation
			this.lookupGestorTimeout = window.setTimeout(() => this.buscarGestoresGlobal(this.lookupGestorInputValue), 500);
		} else {
			event.target.isLoading = false;
			this.template.querySelector('.lookupGestor').classList.remove('slds-is-open');
			this.lookupGestorResultados = [];
		}
	}
	
	lookupGestorAbrir() {
		const lookupGestorInput = this.template.querySelector('.lookupGestorInput');
		lookupGestorInput.setCustomValidity('');
		lookupGestorInput.reportValidity();
		if (this.lookupGestorInputValue.length > 1) {
			this.template.querySelector('.lookupGestor').classList.add('slds-is-open');
		}
	}
	
	lookupGestorCerrar() {
		//eslint-disable-next-line @lwc/lwc/no-async-operation
		window.setTimeout(() => {
			const lookupGestor = this.template.querySelector('.lookupGestor');
			if (lookupGestor) {
				lookupGestor.classList.remove('slds-is-open');
			}
		}, 150);
	}
	
	lookupGestorSeleccionar(event) {
		const gestor = this.lookupGestorResultados.find(c => c.Id === event.currentTarget.dataset.id);
		this.lookupGestorResultadoSeleccionado = gestor;
	}
	
	buscarOficinas(cadenaBusqueda) {
		let lookupOficinaInput = this.template.querySelector('.lookupOficinaInput');
		lookupOficinaInput.isLoading = true;
		buscarOficinas({cadenaBusqueda: cadenaBusqueda})
		.then(oficinas => {
			if (cadenaBusqueda === this.lookupOficinaInputValue) {
				//No se ha modificado la cadena de búsqueda durante la ejecución del Apex
				this.lookupOficinaResultados = oficinas;
				this.template.querySelector('.lookupOficina').classList.add('slds-is-open');
			}
		})
		.catch(error => {
			console.error(error);
			this.toast('error', 'Problema buscando oficinas', error.body.message);
			this.cerrarModal();
		})
		.finally(() => lookupOficinaInput.isLoading = false);
	}
	
	buscarGestoresGlobal(cadenaBusqueda) {
		let lookupGestorInput = this.template.querySelector('.lookupGestorInput');
		lookupGestorInput.isLoading = true;
		buscarGestoresGlobal({cadenaBusqueda: cadenaBusqueda})
		.then(gestores => {
			if (cadenaBusqueda === this.lookupGestorInputValue) {
				//No se ha modificado la cadena de búsqueda durante la ejecución del Apex
				this.lookupGestorResultados = gestores;
				this.template.querySelector('.lookupGestor').classList.add('slds-is-open');
			}
		})
		.catch(error => {
			console.error(error);
			this.toast('error', 'Problema buscando gestores', error.body.message);
			this.cerrarModal();
		})
		.finally(() => lookupGestorInput.isLoading = false);
	}
	
	confirmarCitaGestor() {
		if (!this.template.querySelector('.asuntoEvento').value || !this.template.querySelector('.fechasDisponibilidad').value) {
			this.toast('warning', 'Campos vacíos', 'Por favor, informe todos los campos del formulario');
		} else {
			if (this.esClienteDigital) {
				this.tipoCita = 43;
			}
			this.cargandoGestor = true;
			this.disponibilidadConsultada = false;
			this.ocultarBotonCita = true;
			altaCitaGestor({
				recordId: this.recordId,
				empleadoEx: this.gestorElegido,
				nombreGestor: this.nombreGestorElegido,
				centroEx: this.oficinaGestor,
				asunto: this.template.querySelector('.asuntoEvento').value,
				fecContacto: this.template.querySelector('.fechasDisponibilidad').value,
				horaIni: this.horaCitaSelecionada,
				medio: this.tipoCita})
				.then(resultado => {
					if (resultado.resultat === 'OK') {
						if(this.tipoCita == '43') {
							this.toast('success', 'Cita creada con éxito', resultado.mensaje);
						} else {
							this.mostrarToastOficinaResultado(resultado.mensaje, resultado.cuenta, 'Cita');
						}
						this.cerrarModal();
					} else {
						this.toast('error', 'No es posible crear la cita', resultado.txtError);
						this.cerrarModal();
					}
				})
				.catch(error => {
					console.error(error);
					this.toast('error', 'Error al confirmar la cita', error.body.message);
					this.cerrarModal();
				});
			}
		}
		
		checkCrearTareaOnchange() {
			var checkBoxMostrarTarea = this.template.querySelector('.checkBoxCitaGestor').checked;
			if(checkBoxMostrarTarea) {
				this.mostrarTareaModalCitaGestor = true;
			} else {
				this.mostrarTareaModalCitaGestor = false;
			}
		}
		
		get inputVariables(){
			return [
				{
					name: 'recordId',
					type: 'String',
					value: this.recordId
				}
        	];
	   	}
		
		handleStatusChange(event) {
			this.value = event.detail.status;
			if (this.value === 'FINISHED') {
				this.cerrarModal();
			}
		}
	   
		handleGrupoColaboradorDerivar() {
			this.mostrarFlowDerivar = this.flowDerivar;
			this.grupoColaborador = false;
				if(this.realizarRemitidoDesdeMetodo) {	
					if(!this.ambitoFraude) {
						this.handleRemitir();
					}
				}
				if(this.toastTrasladar3N && !this.preguntaSenal) {
					this.realizarTraslado3N();
				}
				if(this.toastCSBDNoContratar) {
					this.crearOportunidad();
				}
				if(this.toastCajerosIncidencias) {
					this.toast('error', this.tituloCajerosIncidencias, this.toastCajerosIncidencias);
					this.cerrarModal();
				}
				if(this.toastNoClienteError) {
					this.toast('error', 'Error en los datos', this.toastNoClienteError);
					this.cerrarModal();
				}
				if(this.preguntaRealizarRemitido) {
					if(!this.toastCajerosIncidencias) {
						this.abrirModal();
					}
				}
			}
		
		handleGrupoColaboradorTrasladar() {
			this.recuperarCampoDerivar();
			if(!this.derivar) {
				this.cerrarModal();
				this.toast('alert', 'Alerta', this.toastTrasladarDesdeDerivar);
			} else {
				window.setTimeout(() =>	this.dispatchEvent(new CustomEvent('realizartrasladocolaborador', {detail: {data: null}})), 400);
				this.cerrarModal();
			}
		}

		comprobarDNI() {
			if(this.mostrarModalDNITestamentaria) {
				this.dni = this.template.querySelector('.DNITestamentaria').value;
				if(!this.template.querySelector('.DNITestamentaria').value) {
					this.toast('warning', 'Campos vacíos', 'Por favor, informe un documento');
				} else {
					this.showSpinner = true;
					dniTestamentaria({
						dni: this.dni,
						recordId: this.recordId})
					.then(retorno => {
						this.handleRemitir();
					})
					.catch(error => {
						console.error(error);
						this.toast('error', 'Problema estableciendo dni', error.body.message);
						return false;
					}).finally(() => {
						this.showSpinner = false;
					});
				}
			}
		}
		
		handleRemitir() {
			if(!this.derivar) {
				this.cerrarModal();
				this.toast('alert', 'Alerta', this.toastTrasladarDesdeDerivar);
			} else {
				window.setTimeout(() =>	this.dispatchEvent(new CustomEvent('realizarremitido', {detail: {data: null}})), 400);
				this.cerrarModal();
			}
		}

		handleMostrarMensajeRemitir() {
			this.cerrarModal();
			this.toast('warning', 'Atención', this.toastRemitir);
		}
		
		preguntaCajerosSi() {
			this.preguntaCajeros = '';
		}
		
		preguntaCajerosNo() {
			this.cerrarModal();
			this.toast('success', 'Atención', this.toastCajerosExternos);
		}
		
		preguntaCajerosExternosSi() {
			this.cerrarModal();
		}
		
		preguntaCajerosExternosNo() {
			this[NavigationMixin.GenerateUrl]({
				type: 'standard__webPage',
				attributes: {
					url: ''
				}
			}).then(url => {
				window.open(this.urlCajeros, "_blank");
			});
		}

		handleMostrarPreguntaRealizarRemitido(){
			this.mostrarModalPreguntaRealizarRemitido = true;
			this.preguntaSenal = false;
		}

		/*handleMostrarEnrollmentDatos(){
			this.mostrarModalPreguntaEnrollmentDatos = true;
		}*/

		/*preguntaEnrollmentNo() {
			this.preguntaEnrollment = false;
			this.mostrarModalCreacionTarea = true;
		}*/

		/*preguntaEnrollmentDatosSi(){
			this.showSpinner = true;
			preguntaEnrollmentDatosSi({recordId: this.recordId})
			.then(resultado => {
				this.toast('success','Operativa realizada correctamente', this.toastEnrollmentDatosSi);
			})
			.catch(error => {
				console.error(error);
				this.toast('error', 'Problema al realizar la operativa', error.body.message);
			}).finally(() => {
				this.showSpinner = false;
				this.cerrarModal();
			})
		}*/

		/*preguntaEnrollmentDatosNo(){
			this.cerrarModal();
			this.toast('success','Pendiente', this.toastEnrollmentDatosNo);
		}*/
		
		realizarTraslado3N() {
			this.showSpinner = true;
			realizarTraslado3N({recordId: this.recordId})
			.then(resultado => {
				this.toast('success', 'Caso trasladado con éxito', this.toastTrasladar3N);
			})
			.catch(error => {
				console.error(error);
				this.toast('error', 'Problema al trasladar el caso a Tercer Nivel', error.body.message);
			}).finally(() => {
				this.showSpinner = false;
				this.cerrarModal();
				this.dispatchEvent(new CustomEvent('refrescartab', {detail: {data: null}}));
			});
		}

		crearOportunidad() {
			this.showSpinner = true;
			let toast;
			crearOportunidad({recordId: this.recordId})
			.then(resultado => {
				if(this.toastCSBDNoContratar) {
					toast = this.toastCSBDNoContratar;
				} else {
					toast = this.toastCrearOportunidad;
				}
				this.toast('success', 'Oportunidad creada con éxito', toast);
			})
			.catch(error => {
				console.error(error);
				this.toast('error', 'Problema al crear la oportunidad', error.body.message);
			}).finally(() => {
				this.dispatchEvent(new CustomEvent('refrescartab', {detail: {data: null}}));
				this.showSpinner = true;
				this.cerrarModal();
			});
		}

		preguntaCSBDContratarSi() {
			this.preguntaCSBDContratar = null;
		}

		preguntaCSBDContratarNo() {
			this.crearOportunidad();			
		}

		preguntaCSBDContratar2Si() {
			this.crearOportunidad();
		}

		preguntaCSBDContratar2No() {
			this.toastCrearOportunidad = null;
			this.preguntaCSBDContratar2 = false;
		}

		linkTF() {
			this[NavigationMixin.GenerateUrl]({
				type: 'standard__webPage',
				attributes: {
					url: ''
				}
			}).then(url => {
				this.urlTF = this.urlTF.replace('{numperso}', '{' + this.numperso + '}');
				this.urlTF = this.urlTF.replace('{nif}', '{' + this.nif + '}');
				window.open(this.urlTF, "_blank");
			});
		}

		handlePreguntaSenalSi() {
			this.ambitoFraude = false;
			/*if(this.realizarRemitidoDesdeMetodo) {
				this.handleRemitir();
			}*/
			this.preguntaSenal = false;
			this.preguntaRealizarRemitido = false;
			this.toastTrasladarDesdeDerivar = false;
			this.toastRemitir = false;
			if(!this.grupoColaborador && !this.ambitoFraude) {
				this.handleGrupoColaboradorDerivar();
			}
		}

		get archivosLength() {
			return this.archivos ? this.archivos.length : 0;
		}
	}