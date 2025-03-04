import {LightningElement, api} from 'lwc';
import currentUserId from '@salesforce/user/Id';
import {NavigationMixin} from 'lightning/navigation';
import {errorApex} from 'c/csbd_lwcUtils';

import {
	formatNombreCalendario,
	publicarEvento,
	prepararEventosTramo,
	generarFechaTramos,
	ajustarColor,
	tramoLabel
} from './utils';

import initApex from '@salesforce/apex/CSBD_DisponibilidadGestores_Apex.init';
import getEventosGestoresApex from '@salesforce/apex/CSBD_DisponibilidadGestores_Apex.getEventosGestores';

//eslint-disable-next-line camelcase, new-cap
export default class csbd_DisponibilidadGestores extends NavigationMixin(LightningElement) {
	componente = {
		currentUserName: null,
		calendariosContainerClass: ['gridCalendariosContainer', 'slds-is-relative'],
		funcionesBind: {}
	};

	@api mostrarDetallesEventos = false;

	@api get fecha() {
		return this._fecha;
	}

	set fecha(nuevaFecha) {
		this.cambioFecha(nuevaFecha, true);
	}

	@api get idGestor() {
		return this._idGestor;
	}

	set idGestor(nuevoIdGestor) {
		this._idGestor = nuevoIdGestor;
	}

	@api get numCalendarios() {
		return this.calendarViews?.length ?? 0;
	}

	_fecha;

	fechaTramos = [];

	calendarViews;

	getEventosGestoresTimestamp = new Date();

	_idGestor = null;

	idTramoSeleccionado;

	async cambioFecha(nuevaFecha, cambioParent = true) {
		//this._idGestor = null;
		const mismoDia = this._fecha?.toDateString() === nuevaFecha?.toDateString();
		this._fecha = nuevaFecha;
		if (!mismoDia) {
			this.fechaTramos = generarFechaTramos(nuevaFecha);
			if (this.calendarViews) {
				await this.setCalendarViewsTramos();
				await this.getEventosGestores();
			}
		}
		window.setTimeout(() => {
			const divTramo = this.template.querySelector(`div.calendarViewTramo[data-hora="${tramoLabel(nuevaFecha)}"][data-publisher-id="${this._idGestor}"]`);
			if (divTramo) {
				const tramoRect = divTramo.getBoundingClientRect();
				const containerRect = this.refs.gridCalendariosContainer.getBoundingClientRect();
				const tramoVisible = tramoRect.top >= containerRect.top && tramoRect.bottom <= containerRect.bottom;
				if (tramoVisible) {
					this.seleccionar(divTramo, false);
				} else {
					divTramo.scrollIntoView({behavior: 'smooth', block: 'center'});
					window.setTimeout(() => this.seleccionar(divTramo, false), 210);
				}
			}
		}, 200);
		!cambioParent && publicarEvento(this, 'updatefecha', {fecha: nuevaFecha});
	}

	@api async scrollToHorarioLaboral() {
		const primerTramoHorarioLaboral = this.template.querySelector('div.calendarViewTramo[data-es-horario-laboral="true"]');
		if (primerTramoHorarioLaboral) {
			const horaInicialHorarioLaboral = primerTramoHorarioLaboral.dataset.horaEnPunto ?? 0;
			const horaAnteriorHorarioLaboral = Math.max(0, horaInicialHorarioLaboral - 1);
			const tramoAnteriorHorarioLaboral = this.template.querySelector(`div.calendarViewTramo[data-hora-en-punto="${horaAnteriorHorarioLaboral}"]`);
			if (tramoAnteriorHorarioLaboral) {
				tramoAnteriorHorarioLaboral.scrollIntoView({behavior: 'smooth'});
			}
		}
	}

	async connectedCallback() {
		const retorno = await initApex();
		this.componente.currentUserName = retorno.currentUserName;
		this.setCalendarViews(retorno.calendarViewShares);
	}

	async setCalendarViews(calendarViewShares) {
		calendarViewShares = calendarViewShares.filter(cvs => cvs.Parent.Publisher.Type === 'User');

		publicarEvento(this, 'updatecalendarios', {
			numCalendarios: calendarViewShares.length ?? 0,
			width: Math.max(400, 105 + calendarViewShares.length * 155)
		});

		this.calendarViews = [
			//Calendario personal
			{
				id: currentUserId,
				publisherId: currentUserId,
				publisherName: this.componente.currentUserName,
				color: '#cbe8f5',
				tramos: []
			},
			//Calendarios compartidos
			...calendarViewShares.map(cvs => ({
				id: cvs.Id,
				publisherId: cvs.Parent.PublisherId,
				publisherName: formatNombreCalendario(cvs.Parent.Publisher.Name),
				color: ajustarColor(cvs.Parent.Color),
				tramos: []
			}))
		];
		await this.setCalendarViewsTramos();
		this.getEventosGestores();
	}

	async setCalendarViewsTramos() {
		const inicializarTramos = publisherId => this.fechaTramos.map(fechaTramo => ({
			key: `${publisherId}.${fechaTramo.fecha.toISOString()}`,
			seleccionado: false,
			fecha: fechaTramo.fecha,
			label: fechaTramo.label,
			sinEventos: true,
			eventos: [],
			tramoInicialEvento: false,
			horaEnPunto: fechaTramo.horaEnPunto,
			esHoraEnPunto: fechaTramo.esHoraEnPunto,
			esHorarioLaboral: fechaTramo.esHorarioLaboral
		}));
		this.calendarViews.forEach(cv => cv.tramos = inicializarTramos(cv.publisherId));
		this.calendarViews = [...this.calendarViews];
	}

	async getEventosGestores(cache = true) {
		!cache && (this.getEventosGestoresTimestamp = new Date());
		getEventosGestoresApex({
			fecha: this._fecha,
			idGestores: this.calendarViews.map(c => c.publisherId),
			getEventosGestoresTimestamp: this.getEventosGestoresTimestamp

		}).then(eventosGestores => {
			this.calendarViews.forEach(cv => {
				const eventosGestor = eventosGestores[cv.publisherId];
				if (eventosGestor) {
					cv.tramos.forEach((tramoActual, i, tramos) => {
						const inicioTramoActual = tramoActual.fecha;
						//const finTramoActual = new Date(inicioTramoActual.getTime() + 3600000);
						const finTramoActual = new Date(inicioTramoActual.getTime() + 1800000);
						let eventosTramoActual = eventosGestor.filter(e => {
							const inicioEvento = new Date(e.StartDateTime);
							const finEvento = new Date(e.EndDateTime);
							return inicioEvento < finTramoActual && finEvento > inicioTramoActual;
						});
						eventosTramoActual = prepararEventosTramo(cv, tramos, i, eventosTramoActual, this.mostrarDetallesEventos);

						if (eventosTramoActual.some(e => !e.esTramoInicial)) {
							tramoActual.style = 'border-top: none !important;';
						}

						tramos[i] = {
							...tramoActual,
							eventos: eventosTramoActual,
							sinEventos: !eventosTramoActual.length
						};
					});
				}
			});

			this.calendarViews.forEach(cv => {
				const tramos = cv.tramos;
				tramos.forEach((tramo, i) => {
					const eventos = tramo.eventos.map(e => ({...e, positionStyle: e.style}));
					tramos[i] = {...tramo, eventos};
				});
			});
			window.setTimeout(() => {
				this.calendarViews = [...this.calendarViews];
			}, 0);

		}).catch(error => errorApex(this, error, 'Problema recuperando los eventos de la fecha indicada'));
	}

	botonRefrescarEventosOnclick(event) {
		this.getEventosGestores(false); //Refrescar sin cache
		const botonRefrescarEventos = event.currentTarget;
		this.componente.funcionesBind.botonRefrescarOnanimationend = this.botonRefrescarEventosOnanimationend.bind(this, botonRefrescarEventos);
		botonRefrescarEventos.addEventListener('animationend', this.componente.funcionesBind.botonRefrescarOnanimationend);
		botonRefrescarEventos.classList.add('rotar');
	}

	botonRefrescarEventosOnanimationend(botonRefrescarEventos) {
		botonRefrescarEventos.removeEventListener('animationend', this.componente.funcionesBind.botonRefrescarOnanimationend);
		botonRefrescarEventos.classList.remove('rotar');
	}

	verCalendario() {
		this[NavigationMixin.Navigate]({
			type: 'standard__objectPage',
			attributes: {objectApiName: 'Event', actionName: 'home'},
			state: {view: 'availability', startDate: this.fecha.toISOString().split('T')[0]}
		});
	}

	eventoOnmouseenter({currentTarget: {dataset: {id}}}) {
		this.template.querySelectorAll(`span.evento[data-id="${id}"]`).forEach(evento => {
			evento.classList.add('resaltado');
		});
	}

	eventoOnmouseleave({currentTarget: {dataset: {id}}}) {
		this.template.querySelectorAll(`span.evento[data-id="${id}"]`).forEach(evento => {
			evento.classList.remove('resaltado');
		});
	}

	calendarViewTramoOnclick({currentTarget: divTramo, currentTarget: {dataset: {sinEventos}}}) {
		if (sinEventos === 'true') {
			this.seleccionar(divTramo);
		}
	}

	async seleccionar(divTramo, blink = true) {
		if (!divTramo.classList.contains('seleccionado')) {
			this.template.querySelectorAll('span.evento.seleccionadoConEventos').forEach(t => t.classList.remove('seleccionadoConEventos'));

			const {key, publisherId, hora, sinEventos} = divTramo.dataset;
			if (sinEventos === 'false') {
				this.template.querySelectorAll(`span.evento[data-publisher-id="${publisherId}"][data-hora="${hora}"]`).forEach(evento => {
					this.template.querySelectorAll(`span.evento[data-id="${evento.dataset.id}"]`).forEach(span => {
						span.classList.add('seleccionadoConEventos');
					});
				});
				publicarEvento(this, 'gestorseleccionado', {fecha: this._fecha, idGestor: publisherId, disponible: false});
				return;
			}
			const calendarViewTramos = this.calendarViews.find(c => c.publisherId === publisherId).tramos;
			const calendarViewTramo = calendarViewTramos.find(c => c.key === key);
			if (calendarViewTramo && !calendarViewTramo.eventos.length) {
				this.template.querySelectorAll('div.calendarViewTramo.seleccionado').forEach(t => t.classList.remove('seleccionado'));

				this._fecha = calendarViewTramo.fecha;
				//const cambioGestorSeleccionado = this._idGestor !== publisherId;
				this._idGestor = publisherId;
				calendarViewTramo.seleccionado = true;
				this.idTramoSeleccionado = key + '_' + sinEventos;

				publicarEvento(this, 'gestorseleccionado', {fecha: this._fecha, idGestor: publisherId, disponible: true});

				//Deseleccionar los tramos previamente seleccionados y seleccionar el nuevo
				this.calendarViews.forEach(c => c.tramos.forEach(t => t.seleccionado = false));
				divTramo.classList.add('seleccionado');

				if (blink) {
					await new Promise(resolve => {
						divTramo.addEventListener('animationend', resolve, {once: true});
						divTramo.classList.add('blink');
					});
					divTramo.classList.remove('blink');
				}

				//Animar los controles de hora y gestor seleccionado
				/*
				if (cambioGestorSeleccionado) {
					const recordPicker = this.template.querySelector('lightning-record-picker');
					await new Promise(resolve => {
						recordPicker.addEventListener('animationend', () => {
							resolve();
							recordPicker.removeEventListener('animationend', resolve);
						});
						recordPicker.classList.add('seleccionado');
					});
					recordPicker.classList.remove('seleccionado');
				}
				*/
			}
		}
	}

	eventoOnclick(event) {
		event.stopPropagation();
		this[NavigationMixin.Navigate]({type: 'standard__recordPage', attributes: {
			recordId: event.currentTarget.dataset.id, actionName: 'view'
		}});
	}

	diaAnteriorSiguienteOnclick({currentTarget: {dataset: {offset}}}) {
		const nuevaFecha = new Date(this._fecha);
		nuevaFecha.setDate(nuevaFecha.getDate() + parseInt(offset, 10));
		this.cambioFecha(nuevaFecha, false);
	}

	calendarViewTramoOnmouseenter(event) {
		if (event.currentTarget.dataset.sinEventos === 'true') {
			const hora = event.currentTarget.dataset.hora;
			const horaEnPunto = event.currentTarget.dataset.horaEnPunto;
			const publisherId = event.currentTarget.dataset.publisherId;

			this.template.querySelectorAll(`
			div.calendarViewTramo[data-hora="${hora}"],
			div.gridCalendariosColumnaHorasTramo[data-hora-en-punto="${horaEnPunto}"],
			div.gridCalendariosFilaCabecera div.cabeceraColumnaCalendario[data-publisher-id="${publisherId}"],
			div.gridCalendariosColumnaCalendarView[data-publisher-id="${publisherId}"] div.calendarViewTramo
			`).forEach(e => e.classList.add('resaltado'));
		}
	}

	calendarViewTramoOnmouseleave(event) {
		const hora = event.currentTarget.dataset.hora;
		const horaEnPunto = event.currentTarget.dataset.horaEnPunto;
		const publisherId = event.currentTarget.dataset.publisherId;

		this.template.querySelectorAll(`
			div.calendarViewTramo[data-hora="${hora}"],
			div.gridCalendariosColumnaHorasTramo[data-hora-en-punto="${horaEnPunto}"],
			div.gridCalendariosFilaCabecera div.cabeceraColumnaCalendario[data-publisher-id="${publisherId}"],
			div.gridCalendariosColumnaCalendarView[data-publisher-id="${publisherId}"] div.calendarViewTramo
		`).forEach(e => e.classList.remove('resaltado'));
	}
}