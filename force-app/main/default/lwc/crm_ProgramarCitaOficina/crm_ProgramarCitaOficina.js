import {LightningElement} from 'lwc';
import FORM_FACTOR from '@salesforce/client/formFactor';

export default class crmProgramarCitaOficina extends LightningElement {

	formFactor = FORM_FACTOR;

	diasSemana = [];

	horasVisibles = ['09:00', '10:00', '11:00', '12:00', '13:00', '14:00', '15:00', '16:00', '17:00'];

	mensajeSeleccion;

	connectedCallback() {
		const dias = [
			{label: 'Lunes', slots: ['12:00', '13:00', '16:00', '17:00']},
			{label: 'Martes', slots: ['09:00', '10:00', '11:00', '12:00', '13:00']},
			{label: 'Miércoles', slots: ['09:00', '12:00', '13:00', '16:00', '17:00']},
			{label: 'Jueves', slots: ['09:00', '10:00', '11:00', '12:00', '13:00', '16:00', '17:00']},
			{label: 'Viernes', slots: ['09:00', '11:00', '12:00', '13:00', '16:00', '17:00']},
		];

		this.diasSemana = dias.map(dia => {
			const slots = this.horasVisibles.map(hora => {
				const classes = ['divSlot', 'slds-align_absolute-center'];
				const disponible = dia.slots.includes(hora);
				disponible && classes.push('disponible');
				return {hora, disponible, classes};
			});
			return {label: dia.label, slots};
		});
	}

	slotOnclick({currentTarget}) {
		if (currentTarget.classList.contains('disponible')) {
			this.template.querySelectorAll('div.divSlot').forEach(slot => slot.classList.remove('seleccionado'));
			currentTarget.classList.add('seleccionado');
			const divMensajeSeleccion = this.template.querySelector('div.divMensajeSeleccion');
			divMensajeSeleccion.classList.remove('mostrar');
			divMensajeSeleccion.classList.add('ocultar');
			window.setTimeout(()=> {
				this.mensajeSeleccion = `${currentTarget.dataset.dia} a las ${currentTarget.dataset.hora}.`;
				divMensajeSeleccion.classList.remove('ocultar');
				divMensajeSeleccion.classList.add('mostrar');
			}, 80);
		}
	}
}