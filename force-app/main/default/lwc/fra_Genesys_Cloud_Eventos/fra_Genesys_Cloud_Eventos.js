/*eslint-disable @lwc/lwc/no-async-await, no-extra-parens */
import {LightningElement, wire, track} from 'lwc';
import {getRecord, getFieldValue} from 'lightning/uiRecordApi';
import {MessageContext, publish, subscribe, unsubscribe} from 'lightning/messageService';
import messageChannelPurecloud from '@salesforce/messageChannel/purecloud__ClientEvent__c';
import {NavigationMixin} from 'lightning/navigation';

import {
	CATEGORIES_RELEVANTES,
	METODOS_APEX,
	METODOS_APEX_TRIGGERS,
	conversionApexInputs,
	METODOS_APEX_TEST_INPUTS,
	PLANTILLAS_MODAL_SIMULAR_OPCIONES,
	PLANTILLAS_MODAL_SIMULAR,
	PLANTILLA_MODAL_SIMULAR_API,
	formatearApexInput
} from './metodosApex';

import {
	errorApex,
	mensajeErrorExcepcion,
	copiarAlPortapapeles,
	TIPOS_BANNER,
	HISTORIAL_TIPOS,
	actualizarBotonesAtributos,
	resaltarBotonMetodoApex,
	mostrarToast,
	copiarObjeto
} from './utils';

import USER_ID from '@salesforce/user/Id';
import USER_PROFILE_NAME from '@salesforce/schema/User.Profile.Name';
import USER_ROLE_NAME from '@salesforce/schema/User.UserRole.Name';
import USER_NAME from '@salesforce/schema/User.Name';
import USER_EMP_NUMBER from '@salesforce/schema/User.EmployeeNumber';

//eslint-disable-next-line camelcase, new-cap
export default class fra_Genesys_Cloud_Eventos extends NavigationMixin(LightningElement) {

	usuario;

	subscription;

	interactionId = 'N/A';

	tipoBanner = TIPOS_BANNER.offline;

	botonesAtributos = actualizarBotonesAtributos(false);

	metodosApex = METODOS_APEX;

	metodosApexInputsTests = METODOS_APEX_TEST_INPUTS;

	metodoApexInputTestEditando;

	botonesMetodoApexOntransitionendBind = {};

	plantillasModalSimularOpciones = PLANTILLAS_MODAL_SIMULAR_OPCIONES;

	@track logs = [];

	@track logsVisibles = [];

	mostrarSoloEventosRelevantes = true;

	scrollAutomaticoHistorial = true;

	renderizarModales = false;

	simularRespuestaApiPurecloud = false;

	@wire(MessageContext) messageContext;

	@wire(getRecord, {recordId: USER_ID, fields: [USER_PROFILE_NAME, USER_ROLE_NAME, USER_NAME, USER_EMP_NUMBER]})
	wiredUser({error, data}) {
		if (!this.usuario && data) {
			this.usuario = data;
			let infoUsuario = 'Usuario: ' + getFieldValue(data, USER_NAME) + ' (' + getFieldValue(data, USER_EMP_NUMBER) + ')';
			infoUsuario += '\nPerfil: ' + getFieldValue(data, USER_PROFILE_NAME) + ', Rol: ' + getFieldValue(data, USER_ROLE_NAME);
			this.logHistorial('info', infoUsuario);
			if (getFieldValue(data, USER_PROFILE_NAME) === 'System Administrator') {
				//eslint-disable-next-line @lwc/lwc/no-async-operation
				window.setTimeout(() => this.mostrarControles(), 400);
			}
		} else if (error) {
			console.error(error);
		}
	}

	connectedCallback() {
		this.subscribeToMessageChannel();
	}

	disconnectedCallback() {
		this.unsubscribeToMessageChannel();
	}

	async handleMessage(message) {
		//Se actualiza el id de interacción vigente
		if (message.type === 'Interaction' && message.data.id) {
			this.interactionId = message.data.id;
		}
		let nombreMetodoApex;
		if (CATEGORIES_RELEVANTES.includes(message.category)) {
			nombreMetodoApex = await this.identificarTrigger(message);
		}
		await this.logEvento(message, nombreMetodoApex); //Se registra el evento recibido en el historial

		if (nombreMetodoApex) {
			try {
				//Añadir custom attributes antes de la invocación al método Apex
				const estadoConsultaFRA = message.data.attributes?.['Participant.estadoConsultaFRA'];
				switch (nombreMetodoApex) {
					case 'iniciarTransferenciaCiega':
						await this.addCustomAttributes({estadoConsultaFRA: 'blindTransferFRA', agenteOrigenId: USER_ID, agenteDestinoId: null});
					break;
					case 'iniciarConsulta':
						if (!estadoConsultaFRA) {
							await this.addCustomAttributes({estadoConsultaFRA: 'iniciandoFRA', agenteOrigenId: USER_ID, agenteDestinoId: null});
						} 
					break;
					case 'finalizarConsulta':
						if (estadoConsultaFRA==='consulta') {
							await this.addCustomAttributes({estadoConsultaFRA: null, agenteOrigenId: null, agenteDestinoId: null});
						}
					break;
					case 'finalizarConsultaExterna':
						await this.addCustomAttributes({estadoConsultaFRA: null, agenteOrigenId: null, agenteDestinoId: null});
					break;
					case 'completarConsulta':
						await this.addCustomAttributes({transferenciaFRA: 'ok'});
					break;
					default:			
				}
				
				//Añadir custom attributes antes de la invocación al método Apex
				/*const estadoConsultaFRA = message.data.attributes?.['Participant.estadoConsultaFRA'];
				if (nombreMetodoApex === 'blindTransfer' && !estadoConsultaFRA) {
					await this.addCustomAttributes({estadoConsultaFRA: 'blindTransferFRA', agenteOrigenId: USER_ID, agenteDestinoId: null});
				} else if (nombreMetodoApex === 'iniciarConsulta' && !estadoConsultaFRA) {
					//Al iniciar consulta se añade un custom attribute para que al descolgar el agente destino de la consulta
					//se pueda diferenciar una llamada entrante de una consulta entrante (ambos vienen con category: "connect")
					await this.addCustomAttributes({estadoConsultaFRA: 'iniciandoFRA', agenteOrigenId: USER_ID, agenteDestinoId: null});

				} else if ((nombreMetodoApex === 'finalizarConsulta' || nombreMetodoApex === 'completarConsulta') && estadoConsultaFRA==='consulta') { //|| nombreMetodoApex === 'cancelarConsulta'
					await this.addCustomAttributes({estadoConsultaFRA: null, agenteOrigenId: null, agenteDestinoId: null});
				}*/

				//Se realiza la invocación al método Apex si aplica
				const metodoApexInput = await conversionApexInputs(nombreMetodoApex, message, this.interactionId, this);
				if (metodoApexInput) {
					await this.invocarMetodoApex(nombreMetodoApex, metodoApexInput);
					await resaltarBotonMetodoApex(nombreMetodoApex, this);
				}
			} catch (e) {
				console.error(e);
				await this.logHistorial('error', mensajeErrorExcepcion(e));
			}

		}
	}

	async identificarTrigger(message) {
		const estadoConsultaFRA = message.data.attributes?.['Participant.estadoConsultaFRA'] ?? '';
		const transferenciaFRA = message.data.attributes?.['Participant.transferenciaFRA'] ?? '';
		const llamadaIdFRA = message.data.attributes?.['Participant.llamadaIdFRA'] ?? '';
		const direction = message.data.direction ?? '';

		switch (message.category) {
			case 'connect':
				if (estadoConsultaFRA === 'blindTransferFRA' && direction === 'Inbound') {
					return 'registrarblindTransfer';
				}
				if ((estadoConsultaFRA === 'iniciandoFRA') ||(llamadaIdFRA !==''  && direction === 'Inbound')) {
					if (!message.data.queueName.includes('_CC_')) {
						return 'registrarConsulta';
					}
				}	
			break;
			case 'disconnect':
				if (estadoConsultaFRA === 'consultaFRA'	&& message.data?.attributes?.['Participant.agenteOrigenId'] !== USER_ID) {
					return 'finalizarConsulta';
				}
			break;
			case 'acw':
				if (estadoConsultaFRA === 'iniciandoFRA' && transferenciaFRA === 'ok') {
					return 'finalizarConsultaExterna';
				}
			break;
			case 'blindTransfer':
				if (message.category === 'blindTransfer') {
					return 'iniciarTransferenciaCiega';
				}
			break;
			default:
		  }

		
		
		/*const estadoConsultaFRA = message.data.attributes?.['Participant.estadoConsultaFRA'];
		const llamadaIdFRA = message.data.attributes?.['Participant.llamadaIdFRA'] ?? '';
		const direction = message.data.direction ?? '';
		

		if (estadoConsultaFRA === 'blindTransferFRA' && message.category === 'connect'   && direction === 'Inbound'){
			return 'registrarblindTransfer';
		}
		else if ((estadoConsultaFRA === 'iniciandoFRA' && message.category === 'connect') ||(llamadaIdFRA !==''  && direction === 'Inbound' && message.category === 'connect')) {
			if (!message.data.queueName.includes('_CC_')) return 'registrarConsulta';
		} else if (estadoConsultaFRA === 'consultaFRA' && message.category === 'disconnect'
		&& message.data?.attributes?.['Participant.agenteOrigenId'] !== USER_ID) {
			return 'finalizarConsulta';
		} else if ((estadoConsultaFRA === 'iniciandoFRA') && message.category === 'completeConsultTransfer') {
			await this.addCustomAttributes({estadoConsultaFRA: null, agenteOrigenId: null, agenteDestinoId: null});
			return 'finalizarConsultaExterna';
		}
		if (message.category === 'blindTransfer') 
		{
		await this.addCustomAttributes({estadoConsultaFRA: 'blindTransferFRA', agenteOrigenId: USER_ID, agenteDestinoId: null});
		return 'iniciarTransferenciaCiega'; 
		}
		*/

		//eslint-disable-next-line @salesforce/aura/ecma-intrinsics
		for (let [nombreMetodoApex, condiciones] of Object.entries(METODOS_APEX_TRIGGERS)) {
			if (condiciones && message.category === condiciones.category
			&& (!condiciones.direction || !message.data.direction || condiciones.direction === message.data.direction)) {
				return nombreMetodoApex;
			}
		}
		return null;
		
	}

	//eslint-disable-next-line @lwc/lwc/no-async-await
	async invocarMetodoApex(nombreMetodoApex, metodoApexInput) {
		const timestampInicioApex = performance.now();
		await this.cambiarTipoBanner('pendienteApex');
		await this.logHistorial('Invocación Apex', 'Apex "' + nombreMetodoApex + '"\n', formatearApexInput(metodoApexInput));

		//Llamada al método Apex
		const metodoApex = this.metodosApex.find(mA => mA.nombre === nombreMetodoApex).metodoApex;
		try {
			//alert(window.location.search);
			const retornoApex = await metodoApex(metodoApexInput);
			const duracion = Math.round((performance.now() - timestampInicioApex) / 100) / 10;
			await this.logHistorial('Respuesta Apex', 'Respuesta Apex "' + nombreMetodoApex + '" (' + duracion + 's)', JSON.stringify(retornoApex, null, 3));

			//Añadir custom attributes después de la invocación al método Apex
			if (nombreMetodoApex === 'registrarLlamadaEntrante') {
				await this.addCustomAttributes({
					llamadaIdFRA: retornoApex.llamada.Id,
					casoIdFRA: retornoApex?.caso.Id,
					encuestaId: retornoApex?.encuestaId
				});
			} else if (nombreMetodoApex === 'registrarLlamadaSaliente') {
				await this.addCustomAttributes({llamadaIdFRA: retornoApex.llamada.Id});
			} else if (nombreMetodoApex === 'registrarConsulta') {
				await this.addCustomAttributes({estadoConsultaFRA: 'consultaFRA', agenteDestinoId: USER_ID});
			}
			else if (nombreMetodoApex === 'registrarblindTransfer') {
				await this.addCustomAttributes({llamadaIdFRA: retornoApex.llamada.Id});
			}

			//Se abre pestaña nueva si aplica
			const abrirTab = this.metodosApex.find(mA => mA.nombre === nombreMetodoApex).abrirTab;
			if (abrirTab === 'llamada') {
				this.navegarRegistro(retornoApex.llamada.Id);
			} else if (abrirTab === 'caso') {
				this.navegarRegistro(retornoApex.caso.Id);
			}
		} catch (error) {
			errorApex(error, 'Error Apex "' + nombreMetodoApex + '"');
			const logMensajeErrorTexto = error.body.exceptionType + ': ' + error.body.message + '.\n\nHilo de ejecución:\n' + error.body.stackTrace;
			this.logHistorial('error', 'Error Apex "' + nombreMetodoApex + '" (' + Math.round((performance.now() - timestampInicioApex) / 100) / 10 + 's)', logMensajeErrorTexto);
		} finally {
			this.cambiarTipoBanner('online');
		}
	}

	botonInvocarMetodoApex(event) {
		const nombreMetodoApex = event.currentTarget.dataset.nombre;
		this.invocarMetodoApex(nombreMetodoApex, this.metodosApexInputsTests[nombreMetodoApex]);
	}

	async logHistorial(tipo, titulo, texto, eventoCategory, nombreMetodoApexTriggered) {
		const nuevoLog = {
			key: this.logs.length.toString(), tipo: tipo,
			class: HISTORIAL_TIPOS[tipo].class,
			mensajeCabeceraClass: HISTORIAL_TIPOS[tipo].mensajeCabeceraClass,
			iconName: HISTORIAL_TIPOS[tipo].iconName,
			fecha: new Date().toLocaleTimeString(),
			tituloText: titulo, text: texto,
			eventoMessage: eventoCategory,
			apexTriggered: nombreMetodoApexTriggered
		};
		nuevoLog.relevante = this.esLogRelevante(nuevoLog);
		this.logs.unshift(nuevoLog);

		if (this.logs.length > 120) { //Máximo de 120 items en el historial
			this.logs.pop();
			this.filtrarLogsRelevantes();
		} else if (!this.mostrarSoloEventosRelevantes || nuevoLog.relevante) {
			this.logsVisibles.unshift(nuevoLog);
			this.scrollInicioHistorial();
		}
	}

	async logEvento(message, nombreMetodoApex) {
		this.logHistorial(
			'evento',
			null,
			JSON.stringify(message, null, 3),
			{category: message.category, type: message.type},
			nombreMetodoApex ? nombreMetodoApex : null
		);
	}

	async navegarRegistro(recordId) {
		this[NavigationMixin.Navigate]({
			type: 'standard__recordPage', attributes: {recordId: recordId, actionName: 'view'}
		});
	}

	buttonAddAttributesOnclick() {
		const addAttributesString = this.template.querySelector('.inputAddAtributes').value;
		if (addAttributesString) {
			let nuevosCustomAttributes = {};
			try {
				nuevosCustomAttributes = JSON.parse(addAttributesString);
			} catch (e) {
				console.error('Error parsing custom attributes: ' + JSON.stringify(e.message));
				return;
			}
			this.addCustomAttributes(nuevosCustomAttributes);
		}
	}

	async addCustomAttributes(nuevosCustomAttributes) {
		this.logHistorial('Custom attributes', 'Añadir custom attributes', JSON.stringify(nuevosCustomAttributes, null, 3));
		publish(this.messageContext, messageChannelPurecloud, {
			type: 'PureCloud.Interaction.addCustomAttributes',
			data: {attributes: nuevosCustomAttributes, id: this.interactionId}
		});
	}

	async modalAbrir(event) {
		const params = {
			nombreModal: event.currentTarget.dataset.nombreModal,
			elementoFocusClass: event.currentTarget.dataset.elementoFocusClass,
			metodoNombre: event.currentTarget.dataset.metodoNombre
		};

		if (!this.renderizarModales) {
			this.renderizarModales = true;
			//eslint-disable-next-line @lwc/lwc/no-async-operation
			const delay = ms => new Promise(resolve => window.setTimeout(resolve, ms));
			await delay(400);
		}

		const nombreModal = params.nombreModal;
		const modal = this.template.querySelector('.' + nombreModal);
		if (nombreModal === 'modalModificarInputApex') {
			this.metodoApexInputTestEditando = params.metodoNombre;
			const apexInput = this.metodosApexInputsTests[this.metodoApexInputTestEditando];
			const textareaJsonInputApexText = modal.querySelector('.textareaJsonInputApexText');
			textareaJsonInputApexText.value = formatearApexInput(apexInput);
			//eslint-disable-next-line @lwc/lwc/no-async-operation
			window.setTimeout(() =>	textareaJsonInputApexText.focus(), 60);

		} else if (nombreModal === 'modalSimularRecepcionEvento') {
			const textareaJsonSimularEvento = modal.querySelector('.textareaJsonSimularEvento');
			if (!textareaJsonSimularEvento.value) {
				const plantillaDefault = this.plantillasModalSimularOpciones.find(option => option.default).value;
				modal.querySelector('.comboboxCambiarPlantilla').value = plantillaDefault;
				this.cambiarPlantilla(plantillaDefault);
			}
			//eslint-disable-next-line @lwc/lwc/no-async-operation
			window.setTimeout(() =>	textareaJsonSimularEvento.focus(), 60);

		} else if (nombreModal === 'modalSimularRespuestaApiPurecloud') {
			const textareaJsonSimularApiPurecloud = modal.querySelector('.textareaJsonSimularApiPurecloud');
			textareaJsonSimularApiPurecloud.value = PLANTILLA_MODAL_SIMULAR_API;
		}

		modal.classList.add('slds-fade-in-open');
		this.template.querySelector('.slds-backdrop').classList.add('slds-backdrop_open');
		modal.querySelector(params.elementoFocusClass).focus();
	}

	cerrarModales() {
		this.template.querySelectorAll('.slds-modal').forEach(modal => modal.classList.remove('slds-fade-in-open'));
		this.template.querySelector('.slds-backdrop').classList.remove('slds-backdrop_open');
		this.metodoApexInputTestEditando = null;
	}

	modalTeclaPulsada(event) {
		if (event.keyCode === 27) { //ESC
			this.cerrarModales();
		}
	}

	modalModificarInputApexGuardar() {
		let apexInputNew;
		try {
			apexInputNew = JSON.parse(this.template.querySelector('.textareaJsonInputApexText').value);
		} catch {
			this.mostrarToast('error', 'JSON no válido');
			return;
		}
		if (apexInputNew.llamadaJson) {
			apexInputNew = {...apexInputNew, llamadaJson: JSON.stringify(apexInputNew.llamadaJson, null, 3)};
		}
		if (apexInputNew.consultaJson) {
			apexInputNew = {...apexInputNew, consultaJson: JSON.stringify(apexInputNew.consultaJson, null, 3)};
		}
		this.metodosApexInputsTests[this.metodoApexInputTestEditando] = apexInputNew;
		this.cerrarModales();
	}

	eliminarLog() {
		this.logs = [];
		this.logsVisibles = [];
	}

	copiar(event) {
		if (event.currentTarget.classList.contains('botonCopiarIdInteraccion')) {
			copiarAlPortapapeles(this.interactionId);
		} else {
			const eventoKey = event.currentTarget.dataset?.eventoKey;
			if (eventoKey) {
				const log = this.logs.find(e => e.key === eventoKey);
				let textoPortapapeles = log.text ? log.text : '';
				if (log.tipo === 'info') {
					textoPortapapeles = log.tituloText + (textoPortapapeles ? '\n\n' + textoPortapapeles : '');
				}
				copiarAlPortapapeles(textoPortapapeles);
			} else {
				copiarAlPortapapeles(this.logs.reduce((textoSoFar, log) => {
					const textoNuevo = '\n\n' + log.fecha + ':\n' + log.text;
					return textoSoFar + textoNuevo;
				}, '').replace('\n\n', ''));
			}
		}
	}

	subscribeToMessageChannel() {
		if (!this.subscription) {
			this.subscription = subscribe(
				this.messageContext,
				messageChannelPurecloud,
				message => this.handleMessage(message),
			);
			this.cambiarTipoBanner('online');
			this.logHistorial('info', 'Suscrito al canal purecloud__ClientEvent__c');
			this.botonesAtributos = actualizarBotonesAtributos(this.subscription);
		}
	}

	unsubscribeToMessageChannel() {
		unsubscribe(this.subscription);
		this.subscription = null;
		this.cambiarTipoBanner('offline');
		this.logHistorial('info', 'Fin de la suscripción');
		this.botonesAtributos = actualizarBotonesAtributos(this.subscription);
	}

	modalSimularRecepcionEventoPublicar() {
		let datosEvento;
		try {
			datosEvento = JSON.parse(this.template.querySelector('.textareaJsonSimularEvento').value);
		} catch {
			mostrarToast('error', 'JSON no válido');
			return;
		}
		this.logHistorial('info', 'Simular recepción de evento', JSON.stringify(datosEvento, null, 3));
		publish(this.messageContext, messageChannelPurecloud, datosEvento);
		this.cerrarModales();
	}

	comboboxPlantillaJsonOnchange(event) {
		this.cambiarPlantilla(event.detail.value);
	}

	toggleSimularRespuestaApiPurecloudOnchange(event) {
		this.simularRespuestaApiPurecloud = event.detail.checked;
		const boton = this.template.querySelector('.botonAbrirModalSimularRespuestaApiPurecloud');
		if (this.simularRespuestaApiPurecloud) {
			boton.classList.add('iconoSeleccionable', 'iconoSeleccionado');
		} else {
			boton.classList.remove('iconoSeleccionable', 'iconoSeleccionado');
		}
	}

	toggleUsarIdActualOnchange(event) {
		this.cambiarPlantilla(this.template.querySelector('.comboboxCambiarPlantilla').value, event.detail.checked);
	}

	cambiarPlantilla(nombrePlantilla, mantenerInteractionId = this.template.querySelector('.toggleUsarIdActual').checked) {
		let plantilla = copiarObjeto(PLANTILLAS_MODAL_SIMULAR[nombrePlantilla]);
		if (mantenerInteractionId && this.interactionId && this.interactionId !== 'N/A' && plantilla.data) {
			plantilla.data.id = this.interactionId;
		}
		this.template.querySelector('.textareaJsonSimularEvento').value = JSON.stringify(plantilla, null, 3);
	}

	verSoloEventosRelevantes(event) {
		event.currentTarget.classList.toggle('iconoSeleccionado');
		this.mostrarSoloEventosRelevantes = !this.mostrarSoloEventosRelevantes;
		this.filtrarLogsRelevantes();
	}

	filtrarLogsRelevantes() {
		if (this.mostrarSoloEventosRelevantes) {
			this.logsVisibles = this.logs.filter(log => log.relevante);
		} else {
			this.logsVisibles = [...this.logs];
		}
	}

	esLogRelevante(log) {
		return log.tipo !== 'evento'
		|| CATEGORIES_RELEVANTES.includes(log.eventoMessage?.category) //Eventos de categorías relevantes
		|| log.eventoMessage?.type === 'PureCloud.Interaction.addCustomAttributes'; //Eventos de custom attributes
	}

	mostrarControlesOnclick() {
		this.mostrarControles();
	}

	mostrarControles(mostrar = true) {
		if (mostrar) {
			this.template.querySelector('.mostrarControles').classList.add('slds-hide');
			this.template.querySelectorAll('.controles').forEach(item => item.classList.remove('slds-hide'));
		} else {
			this.template.querySelector('.mostrarControles').classList.remove('slds-hide');
			this.template.querySelectorAll('.controles').forEach(item => item.classList.add('slds-hide'));
		}
		this.template.querySelector('.botonDesuscribir').disabled = !mostrar;
	}

	editarInteractionId(event) {
		const inputInteractionId = this.template.querySelector('.inputInteractionId');
		inputInteractionId.disabled = !inputInteractionId.disabled;
		if (inputInteractionId.disabled) {
			event.currentTarget.variant = 'border-filled';
		} else {
			event.currentTarget.variant = 'brand';
			//eslint-disable-next-line @lwc/lwc/no-async-operation
			window.setTimeout(() => inputInteractionId.focus(), 100);
		}
	}

	generarInteractionId() {
		let interactionId = '35e038b6-7f86-4d0c-b879-';
		const characters = 'abcdefghijklmnopqrstuvwxyz0123456789';
		for (let i = 0; i < 12; i++) {
			interactionId += characters.charAt(Math.floor(Math.random() * characters.length));
		}
		this.interactionId = interactionId;
	}

	inputInteractionIdOnchange(event) {
		this.interactionId = event.detail.value;
	}

	cambiarScrollAutomatico(event) {
		event.currentTarget.classList.toggle('iconoSeleccionado');
		this.scrollAutomaticoHistorial = !this.scrollAutomaticoHistorial;
	}

	scrollInicioHistorial() {
		if (this.scrollAutomaticoHistorial) {
			let logDiv = this.template.querySelector('.logDiv');
			if (logDiv) {
				logDiv.scrollTop = 0;
			}
		}
	}

	devLog() {
		this.mostrarControles(false);
	}

	async cambiarTipoBanner(tipo) {
		this.tipoBanner = TIPOS_BANNER[tipo];
	}
}