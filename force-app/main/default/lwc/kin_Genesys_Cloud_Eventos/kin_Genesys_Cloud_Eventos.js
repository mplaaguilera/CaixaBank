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
	formatearApexInput,
	purecloudConversationApi
} from './metodosApex';

import {
	errorApex,
	mensajeErrorExcepcion,
	copiarAlPortapapeles,
	TIPOS_BANNER,
	HISTORIAL_TIPOS,
	actualizarBotonesAtributos,
	mostrarToast,
	copiarObjeto
} from './utils';

import USER_ID from '@salesforce/user/Id';
import USER_PROFILE_NAME from '@salesforce/schema/User.Profile.Name';
import USER_ROLE_NAME from '@salesforce/schema/User.UserRole.Name';
import USER_NAME from '@salesforce/schema/User.Name';
import USER_EMP_NUMBER from '@salesforce/schema/User.EmployeeNumber';

//eslint-disable-next-line camelcase, new-cap
export default class kin_Genesys_Cloud_Eventos extends NavigationMixin(LightningElement) {

	usuario;

	subscription;

	interactionId = 'N/A';

	tipoBanner = TIPOS_BANNER.offline;

	botonesAtributos = actualizarBotonesAtributos(false);

	metodosApex = METODOS_APEX;

	metodosApexInputsTests = METODOS_APEX_TEST_INPUTS;

	metodoApexInputTestEditando;

	plantillasModalSimularOpciones = PLANTILLAS_MODAL_SIMULAR_OPCIONES;

	@track logs = [];

	@track logsVisibles = [];

	mostrarSoloEventosRelevantes = true;

	scrollAutomaticoHistorial = true;

	renderizarModales = false;

	simularRespuestaApiPurecloud = false;

	menuFiltrarHistorialCerrarBind;

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
				this.generarInteractionId();
				window.setTimeout(() => {
					const bannerEstadoSuscripcion = this.template.querySelector('.bannerEstadoSuscripcion');
					if (bannerEstadoSuscripcion) {
						bannerEstadoSuscripcion.focus();
					}
				}, 100);
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
		let nombreMetodoApex;
		if (CATEGORIES_RELEVANTES.includes(message.category)) {
			//Se actualiza el id de interacción vigente
			if (message.type === 'Interaction') {
				if (message.category === 'consultTransfer' && message.data) {
					this.interactionId = message.data;
				} else if (message.data.id) {
					this.interactionId = message.data.id;
				}
			}
			nombreMetodoApex = await this.identificarTrigger(message);
		}
		//await this.logEvento(message, nombreMetodoApex);
		await this.logHistorial( //Se registra el evento recibido en el historial
			'evento', null, JSON.stringify(message, null, 3), {category: message.category, type: message.type},
			(nombreMetodoApex ? {name: nombreMetodoApex, inbound: null} : null)
		);
		if (nombreMetodoApex) {
			try {
				//Añadir custom attributes antes de la invocación al método Apex
				const estadoConsulta = message.data.attributes?.['Participant.estadoConsulta'];
				if (nombreMetodoApex === 'iniciarConsulta' && !estadoConsulta) {
				//Al iniciar consulta se añade un custom attribute para que al descolgar el agente destino de la consulta
				//se pueda diferenciar una llamada entrante de una consulta entrante (ambos vienen con category: "connect")
					await this.addCustomAttributes({estadoConsulta: 'iniciando', agenteOrigenId: USER_ID, agenteDestinoId: null});

				} else if (nombreMetodoApex === 'finalizarConsulta' || nombreMetodoApex === 'completarConsulta') {
					await this.addCustomAttributes({estadoConsulta: null, agenteOrigenId: null, agenteDestinoId: null});
				}

				//Se realiza la invocación al método Apex si aplica
				const metodoApexInput = await conversionApexInputs(nombreMetodoApex, message, this.interactionId, this);
				if (metodoApexInput) {
					await this.invocarMetodoApex(nombreMetodoApex, metodoApexInput);
				}
			} catch (e) {
				console.error(e);
				await this.logHistorial('error', mensajeErrorExcepcion(e));
			}
		}
	}

	async identificarTrigger(message) {
	//eslint-disable-next-line @salesforce/aura/ecma-intrinsics, @lwc/lwc/no-for-of
		for (const nombreMetodoApexTrigger in METODOS_APEX_TRIGGERS) {
			if (Object.prototype.hasOwnProperty.call(METODOS_APEX_TRIGGERS, nombreMetodoApexTrigger)) {
				const condicionesTrigger = METODOS_APEX_TRIGGERS[nombreMetodoApexTrigger];
				if (this.cumpleCondicionesTrigger(message, condicionesTrigger)) {
					return nombreMetodoApexTrigger;
				}
			}
		}
		return null;
	}

	cumpleCondicionesTrigger(message, condiciones) {
		if (!message || !condiciones) {
			return false;
		}
		for (const key in condiciones) {
			if (Object.prototype.hasOwnProperty.call(condiciones, key)) {
				if (typeof condiciones[key] === 'object') {
					if (!this.cumpleCondicionesTrigger(message[key], condiciones[key])) {
						return false;
					}
				} else if (typeof condiciones[key] === 'string') {
					if (condiciones[key] === '***') {
						if (!message[key]) {
							return false;
						}
					} else {
						condiciones[key] = condiciones[key].replace('*USER_ID*', USER_ID);
						if (condiciones[key].startsWith('!')) {
							if (message[key] === condiciones[key].substring(1)) {
								return false;
							}
						} else {
							if (message[key] !== condiciones[key]) {
								return false;
							}
						}
					}
				} else if (typeof condiciones[key] === 'boolean') {
					if (condiciones[key] !== (message[key] ?? false)) {
						return false;
					}
				}
			}
		}
		return true;
	}

	//eslint-disable-next-line @lwc/lwc/no-async-await
	async invocarMetodoApex(nombreMetodoApex, metodoApexInput) {
		const timestampInicioApex = Date.now();
		await this.cambiarTipoBanner('pendienteApex');
		await this.logHistorial('Invocación Apex', 'Apex "' + nombreMetodoApex + '"\n', formatearApexInput(metodoApexInput));

		//Llamada al método Apex
		const metodoApex = this.metodosApex.find(mA => mA.nombre === nombreMetodoApex).metodoApex;
		try {
			const retornoApex = await metodoApex(metodoApexInput);
			const duracion = Math.round((Date.now() - timestampInicioApex) / 100) / 10;
			await this.logHistorial(
				'Respuesta Apex', 'Respuesta Apex "' + nombreMetodoApex + '" (' + duracion + 's)',
				retornoApex ? JSON.stringify(retornoApex, null, 3) : '',
				null, {name: retornoApex?.className, inbound: true}
			);

			//Añadir custom attributes después de la invocación al método Apex
			let nuevosCustomAttributes;
			if (nombreMetodoApex === 'registrarLlamadaEntrante') {
				nuevosCustomAttributes = {
					llamadaId: retornoApex.llamada.Id,
					casoId: retornoApex?.caso?.Id,
					encuestaId: retornoApex?.encuestaId
				};
			} else if (nombreMetodoApex === 'registrarLlamadaSaliente') {
				nuevosCustomAttributes = {
					llamadaId: retornoApex.llamada.Id,
					PD_SKILLIDIOMA: retornoApex?.idioma,
					PD_PROVEEDOR_FINAL_SELECCIONADO: retornoApex?.proveedor
				};
			} else if (nombreMetodoApex === 'iniciarLlamadaSalienteClickToDial') {
				nuevosCustomAttributes = {
					PD_SKILLIDIOMA: retornoApex?.idioma,
					PD_PROVEEDOR_FINAL_SELECCIONADO: retornoApex?.proveedor
				};
			} else if (nombreMetodoApex === 'registrarConsulta') {
				nuevosCustomAttributes = {
					estadoConsulta: 'consulta',
					agenteDestinoId: USER_ID
				};
			}
			if (nuevosCustomAttributes) {
				await this.addCustomAttributes(nuevosCustomAttributes);
			}

			//Se abre pestaña nueva si aplica
			const abrirTab = this.metodosApex.find(mA => mA.nombre === nombreMetodoApex).abrirTab;
			if (abrirTab === 'caso') {
				this.navegarRegistro(retornoApex.caso.Id);
			} else if (abrirTab === 'llamada') {
				this.navegarRegistro(retornoApex.llamada.Id);
			} else if (abrirTab === 'abrirTabId') {
				this.navegarRegistro(retornoApex.abrirTabId);
			}
		} catch (error) {
			errorApex(error, 'Error Apex "' + nombreMetodoApex + '"');
			const logMensajeErrorTexto = (error.body?.exceptionType ? error.body.exceptionType + ': ' : '') + error.body.message + '.\n\nHilo de ejecución:\n' + error.body.stackTrace;
			this.logHistorial('error', 'Error Apex "' + nombreMetodoApex + '" (' + Math.round((Date.now() - timestampInicioApex) / 100) / 10 + 's)', logMensajeErrorTexto);
		} finally {
			this.cambiarTipoBanner('online');
		}
	}

	botonInvocarMetodoApex(event) {
		const nombreMetodoApex = event.currentTarget.dataset.nombre;
		this.invocarMetodoApex(nombreMetodoApex, this.metodosApexInputsTests[nombreMetodoApex]);
	}

	async logHistorial(tipo, titulo, texto, eventoCategory, apexTriggered) {
		const nuevoLog = {
			key: this.logs.length ? this.logs[0].key + 1 : 0,
			tipo: tipo,
			class: HISTORIAL_TIPOS[tipo].class,
			mensajeCabeceraClass: HISTORIAL_TIPOS[tipo].mensajeCabeceraClass,
			iconName: HISTORIAL_TIPOS[tipo].iconName,
			fecha: new Date().toLocaleTimeString(),
			tituloText: titulo, text: texto ? texto : '',
			eventoMessage: eventoCategory,
			apexTriggered: apexTriggered ? {name: apexTriggered.name, inbound: apexTriggered.inbound} : null
		};
		nuevoLog.relevante = this.esLogRelevante(nuevoLog);
		this.logs.unshift(nuevoLog);

		if (this.logs.length > 120) { //Máximo de 120 items en el historial
			this.logs.pop();
		}
		if (this.logCumpleFiltros(nuevoLog)) {
			this.logsVisibles.unshift(nuevoLog);
		}
		this.scrollInicioHistorial();
	}

	logCumpleFiltros(log) {
		return (log.relevante || !this.mostrarSoloEventosRelevantes) && !HISTORIAL_TIPOS[log.tipo].hide;
	}

	async navegarRegistro(recordId) {
		this[NavigationMixin.Navigate]({
			type: 'standard__recordPage', attributes: {recordId: recordId, actionName: 'view'}
		});
	}

	inputAddAtributesOnblur(event) {
		const inputAddAtributes = event.currentTarget;
		const inputAddAtributesValue = inputAddAtributes.value;
		if (inputAddAtributesValue) {
			try {
				JSON.parse(inputAddAtributesValue);
				inputAddAtributes.setCustomValidity('');
			} catch {
				inputAddAtributes.setCustomValidity('El valor no es un JSON.');
			} finally {
				inputAddAtributes.reportValidity();
			}
		}
	}

	buttonAddAttributesOnclick() {
		const inputAddAtributes = this.template.querySelector('.inputAddAtributes');
		if (inputAddAtributes.validity.valid) {
			this.addCustomAttributes(JSON.parse(inputAddAtributes.value));
			inputAddAtributes.value = null;
			this.cerrarPopoverAddAttributes();
		}
	}

	async addCustomAttributes(nuevosCustomAttributes) {
		this.logHistorial('Custom attributes', 'Añadir custom attributes', JSON.stringify(nuevosCustomAttributes, null, 3));
		publish(this.messageContext, messageChannelPurecloud, {
			type: 'PureCloud.Interaction.addCustomAttributes',
			data: {attributes: nuevosCustomAttributes, id: this.interactionId}
		});
	}

	async modalAbrir({currentTarget: {dataset: {nombreModal, elementoFocusClass}}}) {
		if (!this.renderizarModales) {
			this.renderizarModales = true;
			//eslint-disable-next-line @lwc/lwc/no-async-operation
			const delay = () => new Promise(resolve => window.setTimeout(resolve, 200));
			await delay();
		}

		const modal = this.template.querySelector('.' + nombreModal);
		if (nombreModal === 'modalSimularRecepcionEvento') {
			const textareaJsonSimularEvento = modal.querySelector('.textareaJsonSimularEvento');
			if (!textareaJsonSimularEvento.value) {
				const plantillaDefault = this.plantillasModalSimularOpciones.find(option => option.default).value;
				modal.querySelector('.comboboxCambiarPlantilla').value = plantillaDefault;
				this.cambiarPlantilla(plantillaDefault);
			}
			//eslint-disable-next-line @lwc/lwc/no-async-operation
			window.setTimeout(() =>	{
				textareaJsonSimularEvento.scrollTop = 0;
			//textareaJsonSimularEvento.focus();
			}, 60);
		} else if (nombreModal === 'modalSimularRespuestaApiPurecloud') {
			const textareaJsonSimularApiPurecloud = modal.querySelector('.textareaJsonSimularApiPurecloud');
			textareaJsonSimularApiPurecloud.value = PLANTILLA_MODAL_SIMULAR_API;
		}

		this.template.querySelector('.slds-backdrop').classList.add('slds-backdrop_open');
		modal.classList.add('slds-fade-in-open');
		modal.querySelector(elementoFocusClass).focus();
	}

	cerrarModales() {
		this.template.querySelector('.slds-backdrop').classList.remove('slds-backdrop_open');
		this.template.querySelectorAll('.slds-modal').forEach(modal => modal.classList.remove('slds-fade-in-open'));
		this.metodoApexInputTestEditando = null;
	}

	modalTeclaPulsada(event) {
		if (event.keyCode === 27) { //ESC
			this.cerrarModales();
		}
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
				const log = this.logs.find(e => e.key === parseInt(eventoKey, 10));
				let textoPortapapeles = log.text ? log.text : '';
				if (log.tipo === 'info') {
					textoPortapapeles = log.tituloText + (textoPortapapeles ? '\n\n' + textoPortapapeles : '');
				}
				copiarAlPortapapeles(textoPortapapeles);
			} else {
				copiarAlPortapapeles(this.logs.reduce((textoSoFar, log) => {
					const textoNuevo = '\n\n· ' + log.fecha + ' - ' + log.tituloText + (log.text ? ':\n' + log.text : '');
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

	menuFiltrarHistorialItemOnclick({currentTarget: {dataset: {name: itemName}}}) {
		for (const key in HISTORIAL_TIPOS) {
			if (HISTORIAL_TIPOS[key].class === itemName) {
				HISTORIAL_TIPOS[key].hide = !HISTORIAL_TIPOS[key].hide;
				const itemIcon = this.template.querySelector('div.menuFiltrarHistorial li[data-name="' + itemName + '"] lightning-icon:last-child');
				itemIcon.iconName = HISTORIAL_TIPOS[key].hide ? null : 'utility:check';
				break;
			}
		}
		this.filtrarLogs();
	}

	toggleMostrarSoloEventosRelevantesOnchange(event) {
		this.mostrarSoloEventosRelevantes = event.detail.checked;
		this.filtrarLogs();
	}

	filtrarLogs() {
		this.logsVisibles = this.logs.filter(log => this.logCumpleFiltros(log));
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

	async invocarApiPurecloud() {
		await purecloudConversationApi(this.interactionId, null, this);
	}

	abrirPopoverAddAttributes() {
		const popover = this.template.querySelector('.popoverAddAttributes');
		popover.classList.remove('slds-hide');
		popover.querySelector('.inputAddAtributes').focus();
		this.cerrarPopoverAddAttributesBind = this.cerrarPopoverAddAttributes.bind(this);
		window.addEventListener('mousedown', this.cerrarPopoverAddAttributesBind);
	}

	cerrarPopoverAddAttributes() {
		window.removeEventListener('mousedown', this.cerrarPopoverAddAttributesBind);
		const popover = this.template.querySelector('.popoverAddAttributes');
		popover.classList.add('slds-hide');
	}

	stopPropagation(event) {
		event.stopPropagation();
	}

	menuFiltrarHistorialOnclick(event) {
		const menuFiltrarHistorial = event.currentTarget.closest('div.menuFiltrarHistorial');
		if (menuFiltrarHistorial.classList.contains('menuFiltrarHistorialAbierto')) {
			this.menuFiltrarHistorialCerrar();
		} else {
			this.menuFiltrarHistorialAbrir(menuFiltrarHistorial);
		}
	}

	menuFiltrarHistorialAbrir(menuFiltrarHistorial) {
		this.menuFiltrarHistorialCerrarBind = this.menuFiltrarHistorialCerrar.bind(this);
		window.addEventListener('click', this.menuFiltrarHistorialCerrarBind);
		menuFiltrarHistorial.classList.add('menuFiltrarHistorialAbierto');
	}

	menuFiltrarHistorialCerrar() {
		window.removeEventListener('click', this.menuFiltrarHistorialCerrarBind);
		this.template.querySelector('div.menuFiltrarHistorial').classList.remove('menuFiltrarHistorialAbierto');
	}
}