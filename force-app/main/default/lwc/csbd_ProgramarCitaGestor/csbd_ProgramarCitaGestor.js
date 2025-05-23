import {LightningElement, api, wire} from 'lwc';
import {getRecord, getFieldValue} from 'lightning/uiRecordApi';
import {errorApex, publicarEvento, transitionThenCallback, toast} from 'c/csbd_lwcUtils';

import OPP_GESTOR_NAME from '@salesforce/schema/Opportunity.Account.AV_EAPGestor__r.Name';

export default class csbdProgramarCitaGestor extends LightningElement {

	modalAbierto = false;

    spinner = false;

	@api recordId;

	tipoCitaOptions = [
		{label: 'Cita presencial', value: 'Cita presencial'},
		{label: 'Cita telefónica', value: 'Cita telefónica'}
	];

	fechasOptions = {
		dias: [
			{label: 'Lunes 1 de junio', value: 'Lunes 1 de junio'},
			{label: 'Miércoles 3 de junio', value: 'Miércoles 3 de junio'},
			{label: 'Jueves 4 de junio', value: 'Jueves 4 de junio'},
			{label: 'Sábado 6 de junio', value: 'Sábado 6 de junio'},
			{label: 'Domingo 7 de junio', value: 'Domingo 7 de junio'},
			{label: 'Martes 9 de junio', value: 'Martes 9 de junio'},
			{label: 'Miércoles 10 de junio', value: 'Miércoles 10 de junio'},
			{label: 'Jueves 11 de junio', value: 'Jueves 11 de junio'},
			{label: 'Viernes 12 de junio', value: 'Viernes 12 de junio'},
			{label: 'Sábado 13 de junio', value: 'Sábado 13 de junio'},
			{label: 'Domingo 14 de junio', value: 'Domingo 14 de junio'}
		],
		horas: [
			{label: '10:00 - 11:00', value: '10:00'},
			{label: '11:00 - 12:00', value: '11:00'},
			{label: '12:00 - 13:00', value: '12:00'}
		]
	}

	oportunidad;

	spinner;

	@wire(getRecord, {recordId: '$recordId', fields: [OPP_GESTOR_NAME]})
	wiredRecord({error, data: oportunidad}) {
		if (oportunidad) {
			let _nombreGestor = getFieldValue(oportunidad, OPP_GESTOR_NAME);
			if (_nombreGestor === 'No asignado') {
				_nombreGestor = null;
			}
			this.oportunidad = {...oportunidad, _nombreGestor};
			this.modalAbierto && this.abrirModal();

		} else if (error) {
			errorApex(this, error, 'Problema recuperando los datos de la oportunidad');
		}
	}

	@api abrirModal() {
		const modalProgramarCitaGestor = this.refs.modalProgramarCitaGestor;
		if (modalProgramarCitaGestor.classList.contains('slds-fade-in-open')) {
			return;
		}
		this.modalAbierto = true;
		if (!this.oportunidad) {
			return; //Si el getRecord no ha acabado, el modal se abrirá cuando acabe
		}

        this.refs.backdropModal.classList.add('slds-backdrop_open');
        transitionThenCallback(modalProgramarCitaGestor, 'slds-fade-in-open', () => {
            this.refs.inputAsunto.focus();
            publicarEvento(this, 'modalabierto', {nombreModal: 'modalProgramarCitaGestor'});
        }, 'opacity');
	}

	modalCerrar() {
		transitionThenCallback(
			this.refs.modalProgramarCitaGestor, 'slds-fade-in-open',
			() => publicarEvento(this, 'modalcerrado', {nombreModal: 'modalProgramarCitaGestor'}),
			'opacity'
		);
		this.refs.backdropModal.classList.remove('slds-backdrop_open');
	}

	modalTeclaPulsada({keyCode}) {
        if (keyCode === 27 && this.refs.modalProgramarCitaGestor.classList.contains('slds-fade-in-open')) {
			this.modalCerrar();
		}
	}

	programarCitaGestor() {
		const {inputAsunto, inputFecha, inputHora} = this.refs;
		const ok = [inputAsunto, inputFecha, inputHora].reduce((ok, input) => {
			input.reportValidity();
			return ok && input.validity.valid;
		}, true);

		if (ok) {
			this.spinner = true;
			setTimeout(() => {
				this.modalCerrar();
				toast('success', 'Se programó cita con el gestor', 'Se programó correctamente la cita con el gestor para el día DD/MM a las HH:MM');
				this.spinner = false;
			}, 4000);
		}
	}
}