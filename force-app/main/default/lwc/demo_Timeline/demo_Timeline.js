import {LightningElement, api} from 'lwc';
//import {getRecord, getFieldValue} from 'lightning/uiRecordApi';
import {NavigationMixin} from 'lightning/navigation';
import SampleData from './sampleData.js';

import getData from '@salesforce/apex/demo_Timeline_Apex.getData';

import CASE_RECORDTYPE_DEVELOPERNAME from '@salesforce/schema/Case.RecordType.DeveloperName';
import ACCOUNT_RECORDTYPE_DEVELOPERNAME from '@salesforce/schema/Account.RecordType.DeveloperName';

const CLASES_SECTION_TITLE_ACTION = {
	false: {class: 'slds-button slds-section__title-action', iconName: 'utility:date_input'},
	true: {class: 'slds-button slds-section__title-action sectionTitleActionResaltar', iconName: 'utility:clock'}
};

const CLASES_TIMELINE_ITEM = {
	task: 'slds-timeline__item_expandable slds-timeline__item_task',
	event: 'slds-timeline__item_expandable slds-timeline__item_event',
	messaging: 'slds-timeline__item_expandable slds-timeline__item_call',
	email: 'slds-timeline__item_expandable slds-timeline__item_email',
	case: 'slds-timeline__item_expandable timeline__item_case',
	chat: 'slds-timeline__item_expandable timeline__item_chat',
	llamada: 'slds-timeline__item_expandable timeline__item_llamada',
	einstein: 'slds-timeline__item_expandable timeline__item_einstein'
};

//eslint-disable-next-line camelcase, new-cap
export default class demoTimeline extends NavigationMixin(LightningElement) {

	@api recordId;

	@api objectApiName;

	fields = [];

	casoRecordTypeDeveloperName;

	opciones = {
		agruparPorMeses: true,
		agruparProximos: true,
		orden: 1, //1: DESC, 2: ASC
		usarDatosPrueba: false,
		mostrarRelacionados: true,
		desarrollo: false,
		objetos: {
			'Tarea': {
				objectApiName: 'Task',
				iconName: 'standard:task', colorConector: 'task', visible: true,
				campoTitulo: 'Subject', campoSubtitulo: 'Owner.Name', campoFecha: 'ActivityDate',
				campo1: 'Status', campo2: 'ActivityDate', campo3: 'Description'
			},
			'Evento': {
				objectApiName: 'Event',
				iconName: 'standard:event', colorConector: 'event', visible: true,
				campoTitulo: 'Subject', campoSubtitulo: 'Owner.Name', campoFecha: 'StartDateTime',
				campo1: 'DurationInMinutes', campo2: 'EndDateTime', campo3: 'Description'
			},
			'Llamada': {
				objectApiName: 'VoiceCall',
				iconName: 'standard:voice_call', colorConector: 'llamada', visible: true,
				campoTitulo: 'SDO_Service_Case_Subject__c', campoSubtitulo: 'Owner.Name', campoFecha: 'CallStartDateTime',
				campo1: 'CallDisposition', campo2: 'CallEndDateTime', campo3: 'Description'
			},
			'Correo': {
				objectApiName: 'EmailMessage',
				iconName: 'standard:email', colorConector: 'email', visible: true,
				campoTitulo: 'Subject', campoSubtitulo: 'ToAddress', campoFecha: 'MessageDate',
				campo1: 'FromAddress', campo2: 'ToAddress', campo3: 'HtmlBody', campo3Html: true
			},
			'Chat': {
				objectApiName: 'LiveChatTranscript',
				iconName: 'standard:live_chat', colorConector: 'chat', visible: true,
				campoTitulo: 'CC_Subject__c', campoSubtitulo: 'Owner.Name', campoFecha: 'StartTime',
				campo1: 'Status', campo2: 'ChatDuration', campo3: 'OperatorMessageCount'
			},
			'Whatsapp': {
				objectApiName: 'MessagingSession',
				iconName: 'standard:messaging_session', colorConector: 'messaging', visible: true,
				campoTitulo: 'SDO_LiveMessaging_Subject__c', campoSubtitulo: 'Owner.Name', campoFecha: 'StartTime',
				campo1: 'Status', campo2: 'StartTime', campo3: 'ChannelType'
			},
			'Caso': {
				objectApiName: 'Case',
				iconName: 'standard:case', colorConector: 'case', visible: true,
				campoTitulo: 'CaseNumber', campoSubtitulo: 'Owner.Name', campoFecha: 'CreatedDate',
				campo1: 'Status', campo2: 'Origin', campo3: 'Priority'
			},
			'Einstein': {
				objectApiName: 'Einstein',
				iconName: 'standard:story', colorConector: 'einstein', visible: true,
				campoTitulo: 'Name', campoSubtitulo: 'Owner.Name', campoFecha: 'CreatedDate',
				campo1: 'Status', campo2: 'Name', campo3: 'Name'
			}
		}
	};

	cargando = false;

	mensajeError;

	opcionesOrdenacion = [{label: 'Más antiguos primero', value: '-1'}, {label: 'Más recientes primero', value: '1'}];

	datos = [];

	sampleData = new SampleData();

	cerrarPopoverOpcionesBind;

	contenidoSeccionContraerTransitionEndBind;

	cerrarPopoverOpcionesTransitionEndBind;

	connectedCallback() {
		if (this.objectApiName === 'Case') {
			this.fields = [CASE_RECORDTYPE_DEVELOPERNAME];
		} if (this.objectApiName === 'Account') {
			this.fields = [ACCOUNT_RECORDTYPE_DEVELOPERNAME];
		}

		if (this.opciones.usarDatosPrueba) {
			this.datos = this.sampleData.getSampleData();
		} else {
			this.getDatos();
		}
	}

	/*
	@wire(getRecord, {recordId: '$recordId', fields: '$fields'})
	wiredRecord({data, error}) {
		if (data) {
			this.casoRecordTypeName = getFieldValue(data, this.fields[0]);
			if (this.casoRecordTypeName === 'CRM_Interaccion') {
				this.interaccion = true;
			}
		} else if (error) {
			console.error(error);
		}
	}
	*/

	getDatos() {
		if (!this.opciones.usarDatosPrueba) {
			this.cargando = true;
			getData({objectApiName: this.objectApiName, recordId: this.recordId, opcionesObjetos: this.opciones.objetos})
				.then(data => {
					//console.table(data);
					if (!this.opciones.mostrarRelacionados) {
						let dataFiltrada = data.filter(element => element.idPadre === this.recordId);
						console.log(dataFiltrada);
						this.datos = this.formatearDatos(dataFiltrada);
						this.mensajeError = null;
					} else {
						this.datos = this.formatearDatos(data);
						this.mensajeError = null;
					}
				}).catch(error => {
					console.error(error);
					this.mensajeError = error.body?.message ?? error.message;
					//eslint-disable-next-line no-return-assign
				}).finally(() => this.cargando = false);
		}
	}

	formatearDatos(data) {
		const nombreOpcionesObjetos = {Task: 'Tarea', Event: 'Evento', VoiceCall: 'Llamada', EmailMessage: 'Correo', LiveChatTranscript: 'Chat', MessagingSession: 'Whatsapp', Case: 'Caso'};
		const icnonosObjetos = {Case: 'utility:case', Account: 'utility:company', Contact: 'utility:contact'};
		//Ordenación de los registros
		data = data.sort((a, b) => {
			if (!Object.prototype.hasOwnProperty.call(b, 'campoFechaValor')) {
				return -1; //Los registros sin fecha siempre van al final
				//eslint-disable-next-line no-else-return
			} else {
				return this.opciones.orden * new Date(b.campoFechaValor).valueOf() - new Date(a.campoFechaValor).valueOf();
			}
		});

		//Preparación de las secciones
		let secciones = data.map(registro => this.datetimeFormatMesAño(registro));
		secciones = [... new Set(secciones)];
		let datos = secciones.map(nombreSeccion => ({
			nombreSeccion: nombreSeccion, items: [],
			class: CLASES_SECTION_TITLE_ACTION[nombreSeccion === 'Próximos'].class,
			iconName: CLASES_SECTION_TITLE_ACTION[nombreSeccion === 'Próximos'].iconName
		}));

		//Añadir cada registro a la sección a la que pertenece
		data.forEach(registro => {
			datos.find(seccion => seccion.nombreSeccion === this.datetimeFormatMesAño(registro)).items.push({
				id: registro.id,
				objectApiName: registro.objectApiName,
				idPadre: this.casoRecordTypeDeveloperName === 'Interacción' ? '' : registro.idPadre === this.recordId ? '' : registro.idPadre,
				mostrarIconoPadre: registro.padreRecordTypeDeveloperName === 'CRM_Interaccion' && registro.idPadre !== this.recordId,
				padreObjectRecordName: nombreOpcionesObjetos[registro.padreObjectRecordName],
				padreIcono: icnonosObjetos[registro.padreObjectRecordName],
				padreTooltip: registro.padreTooltip ? 'Ver detalle de la interacción ' + registro.padreTooltip : null,
				titulo: registro.titulo,
				subtitulo: registro.subtitulo,
				fecha: this.formatearCampo(registro, registro.campoFechaLabel, registro.campoFechaValor, true),
				campo1Label: registro.campo1Label,
				campo1Valor: this.formatearCampo(registro, registro.campo1Label, registro.campo1Valor),
				campo2Label: registro.campo2Label,
				campo2Valor: this.formatearCampo(registro, registro.campo2Label, registro.campo2Valor),
				campo3Label: registro.campo3Label,
				campo3Valor: this.formatearCampo(registro, registro.campo3Label, registro.campo3Valor),
				campo3Html: this.opciones.objetos[nombreOpcionesObjetos[registro.objectApiName]]?.campo3Html,
				iconName: this.opciones.objetos[nombreOpcionesObjetos[registro.objectApiName]]?.iconName,
				clases: CLASES_TIMELINE_ITEM[this.opciones.objetos[nombreOpcionesObjetos[registro.objectApiName]]?.colorConector],
				visible: true
			});
		});
		return datos;
	}

	opcionAgruparPorMesesOnchange(event) {
		this.template.querySelectorAll('.slds-section:not(.slds-is-open)').forEach(seccionCerrada => this.expandirSeccion([seccionCerrada]));
		this.opciones = {...this.opciones, agruparPorMeses: event.detail.checked};
	}

	opcionAgruparProximosOnchange(event) {
		this.opciones = {...this.opciones, agruparProximos: event.detail.checked};
		this.getDatos();
	}

	opcionOrdenOnchange(event) {
		this.opciones = {...this.opciones, orden: event.detail.value};
		this.getDatos();
	}

	opcionMostrarRelacionados(event) {
		this.opciones = {...this.opciones, mostrarRelacionados: event.detail.checked};
		this.getDatos();
	}

	opcionUsarDatosPruebaOnchange(event) {
		this.opciones = {...this.opciones, usarDatosPrueba: event.detail.checked};
		if (event.detail.checked) {
			this.datos = this.sampleData.getSampleData();
		} else {
			this.getDatos();
		}
	}

	expandirContraerItem(event) {
		this.template.querySelector('[data-item-id="' + event.currentTarget.dataset.id + '"]').classList.toggle('slds-is-open');
		event.stopPropagation();
	}

	tituloItemOnclick(event) {
		const seccionNavegacion = this.datos.find(seccion => seccion.nombreSeccion === event.currentTarget.dataset.nombreSeccion);
		const itemNavegacion = seccionNavegacion.items.find(item => item.id === event.currentTarget.dataset.id);
		this.navegarDetalleRegistro(itemNavegacion.objectApiName, itemNavegacion.id);
	}

	navegarDetalleRegistro(objectApiName, id) {
		this[NavigationMixin.Navigate]({
			type: 'standard__recordPage',
			attributes: {recordId: id, objectApiName: objectApiName, actionName: 'view'}
		});
	}

	mostrarCerrarPopoverOpciones(event) {
		let popoverOpciones = this.template.querySelector('.popoverOpciones');
		if (popoverOpciones.classList.contains('popoverOpcionesVisible')) {
			this.cerrarPopoverOpciones(popoverOpciones);
		} else {
			popoverOpciones.classList.remove('slds-hide');
			//eslint-disable-next-line @lwc/lwc/no-async-operation
			window.setTimeout(() => {
				popoverOpciones.classList.add('popoverOpcionesVisible');
				this.cerrarPopoverOpcionesBind = this.cerrarPopoverOpciones.bind(this, popoverOpciones);
				window.addEventListener('click', this.cerrarPopoverOpcionesBind);
			}, 0);
		}
		event.stopPropagation();
	}

	cerrarPopoverOpciones(popoverOpciones) {
		popoverOpciones.classList.remove('popoverOpcionesVisible');
		this.cerrarPopoverOpcionesTransitionEndBind = this.cerrarPopoverOpcionesTransitionEnd.bind(this, popoverOpciones);
		popoverOpciones.addEventListener('transitionend', this.cerrarPopoverOpcionesTransitionEndBind);
		window.removeEventListener('click', this.cerrarPopoverOpcionesBind);
	}

	cerrarPopoverOpcionesTransitionEnd(popoverOpciones) {
		popoverOpciones.classList.add('slds-hide');
		popoverOpciones.removeEventListener('transitionend', this.cerrarPopoverOpcionesTransitionEndBind);
	}

	tituloSeccionOnclick(event) {
		event.currentTarget.style.pointerEvents = 'none';
		this.expandirContraerSeccion(this.template.querySelector('[data-nombre-seccion="' + event.currentTarget.dataset.nombreSeccion + '"]').closest('.slds-section'));
	}

	expandirContraerSeccion(seccion) {
		if (seccion.classList.contains('slds-is-open')) {
			this.contraerSeccion(seccion, false);
		} else {
			this.expandirSeccion([seccion]);
		}
	}

	expandirSeccion(secciones) {
		secciones.forEach(seccion => seccion.querySelector('.contenidoSeccion').classList.remove('contenidoSeccionOculto'));
		//eslint-disable-next-line @lwc/lwc/no-async-operation
		window.setTimeout(() => {
			secciones.forEach(seccion => {
				seccion.classList.add('slds-is-open');
				seccion.querySelector('.slds-section__title').style.pointerEvents = 'initial';
			});
		}, 70);
	}

	contraerSeccion(seccion, animado = true) {
		let contenidoSeccion = seccion.querySelector('div.contenidoSeccion');
		if (animado) {
			this.contenidoSeccionContraerTransitionEndBind = this.contenidoSeccionContraerTransitionEnd.bind(this, seccion, seccion.querySelector('.slds-section__title'), contenidoSeccion);
			contenidoSeccion.addEventListener('transitionend', this.contenidoSeccionContraerTransitionEndBind);
		} else {
			seccion.classList.remove('slds-is-open');
			seccion.querySelector('.slds-section__title').style.pointerEvents = 'initial';
		}
		contenidoSeccion.classList.add('contenidoSeccionOculto');
	}

	contenidoSeccionContraerTransitionEnd(seccion, tituloSeccion, contenidoSeccion) {
		seccion.classList.remove('slds-is-open');
		tituloSeccion.style.pointerEvents = 'initial';
		contenidoSeccion.removeEventListener('transitionend', this.contenidoSeccionContraerTransitionEndBind);
	}

	botonContraerTodoOnclick(event) {
		this.contraerItemsSeccion(event.currentTarget.dataset.id);
		event.stopPropagation();
	}

	contraerItemsSeccion(idSeccion) {
		this.expandirSeccion([this.template.querySelector('[data-nombre-seccion="' + idSeccion + '"]').closest('.slds-section')]);
		this.template.querySelectorAll('div[data-nombre-seccion-padre="' + idSeccion + '"').forEach(
			item => item.classList.remove('slds-is-open')
		);
	}

	botonExpandirTodoOnclick(event) {
		this.expandirItemsSeccion(event.currentTarget.dataset.id);
		event.stopPropagation();
	}

	expandirItemsSeccion(idSeccion) {
		let seccion = this.template.querySelector('[data-nombre-seccion="' + idSeccion + '"]').closest('.slds-section');
		this.expandirSeccion([seccion]);
		seccion.classList.add('slds-is-open');
		seccion.querySelectorAll('.slds-timeline__item_expandable[data-nombre-seccion-padre="' + idSeccion + '"').forEach(
			item => item.classList.add('slds-is-open')
		);
	}

	botonMostrarObjetoOnclick(event) {
		let opcionesObjeto = this.opciones.objetos[event.currentTarget.dataset.objeto];
		opcionesObjeto.visible = !opcionesObjeto.visible;
		event.currentTarget.classList.toggle('opcionesBotonMostrarObjetoDeseleccionado');

		let objetosVisibles = [];
		for (let key in this.opciones.objetos) {
			if (Object.prototype.hasOwnProperty.call(this.opciones.objetos, key) && this.opciones.objetos[key].visible) {
				objetosVisibles.push(this.opciones.objetos[key].objectApiName);
			}
		}

		this.datos = this.datos.map(seccion => ({
			...seccion, items: seccion.items.map(item => {
				let newItem = item;
				if (item.objectApiName === opcionesObjeto.objectApiName) {
					newItem = {...item, visible: objetosVisibles.includes(item.objectApiName)};
				}
				return newItem;
			})
		}));
	}

	contraerSecciones() {
		this.template.querySelectorAll('h3.slds-section__title').forEach(tituloSeccion => {
			this.contraerSeccion(tituloSeccion.closest('.slds-section'), false);
		});
	}

	expandirSecciones() {
		let secciones = [];
		this.template.querySelectorAll('h3.slds-section__title').forEach(tituloSeccion => {
			secciones.push(tituloSeccion.closest('.slds-section'));
		});
		this.expandirSeccion(secciones);
	}

	eventStopPropagation(event) {
		event.stopPropagation();
	}

	datetimeFormatMesAño(registro) {
		const nombresMesLargos = {
			0: 'Enero', 1: 'Febrero', 2: 'Marzo', 3: 'Abril', 4: 'Mayo', 5: 'Junio', 6: 'Julio',
			7: 'Agosto', 8: 'Septiembre', 9: 'Octubre', 10: 'Noviembre', 11: 'Diciembre'
		};

		let fechaRegistro = new Date(registro.campoFechaValor);
		if (!Object.prototype.hasOwnProperty.call(registro, 'campoFechaValor')) {
			return 'Sin fecha';
		} else if (this.opciones.agruparProximos && fechaRegistro > new Date()) {
			return 'Próximos';
			//eslint-disable-next-line no-else-return
		} else {
			return nombresMesLargos[fechaRegistro.getMonth()] + ' · ' + fechaRegistro.getFullYear();
		}
	}

	formatearCampo(registro, campoLabel, campoValor, texto = false) {
		if (!campoValor) {
			return null;
			//eslint-disable-next-line no-else-return
		} else {
			if (!Object.prototype.hasOwnProperty.call(registro.mapaSoloFecha, campoLabel)) {
				return campoValor;
				//eslint-disable-next-line no-else-return
			} else {
				const nombresMesCortos = {0: 'ene', 1: 'feb', 2: 'mar', 3: 'abr', 4: 'may', 5: 'jun', 6: 'jul', 7: 'ago', 8: 'sep', 9: 'oct', 10: 'nov', 11: 'dic'};
				const nombresDiasSemanaCortos = {0: 'lun', 1: 'mar', 2: 'mié', 3: 'jue', 4: 'vie', 5: 'sáb', 6: 'dom'};

				let campoValorDatetime = new Date(campoValor);
				let retorno;
				if (texto) {
					retorno = nombresDiasSemanaCortos[campoValorDatetime.getDay()] + ' ' + campoValorDatetime.getDate() + ' ' + nombresMesCortos[campoValorDatetime.getMonth()];
					if (new Date().getFullYear() !== campoValorDatetime.getFullYear()) {
						retorno += ' ' + campoValorDatetime.getFullYear().toString().slice(-2);
					}
					if (!registro.mapaSoloFecha[campoLabel]) {
						retorno += ' | ' + campoValorDatetime.getHours() + ':' + campoValorDatetime.getMinutes().toString().padStart(2, '0');
					}
				} else {
					retorno = campoValorDatetime.getDate() + '/' + (campoValorDatetime.getMonth() + 1) + '/' + campoValorDatetime.getFullYear();
					if (!registro.mapaSoloFecha[campoLabel]) {
						retorno += ' ' + campoValorDatetime.getHours() + ':' + campoValorDatetime.getMinutes().toString().padStart(2, '0');
					}
				}
				return retorno;
			}
		}
	}

	spanInteraccionOnclick(event) {
		this.navegarDetalleRegistro('Case', event.currentTarget.dataset.idInteraccion);
	}
}