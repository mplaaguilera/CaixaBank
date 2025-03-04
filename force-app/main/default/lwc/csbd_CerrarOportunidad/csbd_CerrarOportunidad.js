import {LightningElement, api, wire} from 'lwc';
import {getRecord, getFieldValue} from 'lightning/uiRecordApi';
import {errorApex, publicarEvento, toast} from 'c/csbd_lwcUtils';

import OPP_PRODUCTO from '@salesforce/schema/Opportunity.CSBD_Producto__c';
import OPP_CONTACT from '@salesforce/schema/Opportunity.CSBD_Contact__c';
import OPP_NO_IDENTIFICADO from '@salesforce/schema/Opportunity.CSBD_No_Identificado__c';
import OPP_RT_NAME from '@salesforce/schema/Opportunity.RecordType.Name';
import OPP_RT_DEVNAME from '@salesforce/schema/Opportunity.RecordType.DeveloperName';
import OPP_NOTAS_GESTOR from '@salesforce/schema/Opportunity.CSBD_Notas_gestor__c';
import OPP_AMOUNT from '@salesforce/schema/Opportunity.Amount';

import cerrarOportunidadApex from '@salesforce/apex/CSBD_Opportunity_Operativas_Controller.cerrarOportunidad';
import obtenerOportunidadesHijasApex from '@salesforce/apex/CSBD_Opportunity_Operativas_Controller.obtenerOportunidadesHijas';
import obtenerResolucionesApex from '@salesforce/apex/CSBD_Opportunity_Operativas_Controller.obtenerResoluciones';
import obtenerEntidadesCompetenciaApex from '@salesforce/apex/CSBD_Opportunity_Operativas_Controller.obtenerEntidades';

const OPP_FIELDS = [OPP_PRODUCTO, OPP_CONTACT, OPP_NO_IDENTIFICADO, OPP_RT_NAME, OPP_RT_DEVNAME, OPP_CONTACT, OPP_AMOUNT];

export default class csbdCerrarOportunidad extends LightningElement {

	modalAbierto = false;

	@api recordId;

	oportunidad;

	cerrarEtapas = [];

	cerrarResoluciones = [];

	entidadesCompetencia = [];

	mostrarNotificacion = false;

	mostrarMotivoRechazo = false;

	mostrarTipoBonificado = false;

	wireGetRecordTimestamp = null;

	@wire(getRecord, {recordId: '$recordId', fields: OPP_FIELDS, wireTimestamp: '$wireGetRecordTimestamp'})
	wiredRecord({error, data: oportunidad}) {
		if (oportunidad) {
			this.oportunidad = oportunidad;
			this.mostrarNotificacion = !getFieldValue(oportunidad, OPP_CONTACT) && !getFieldValue(oportunidad, OPP_NO_IDENTIFICADO);

			if (this.modalAbierto) {
				this.abrirModal();
			}
		} else if (error) {
			errorApex(this, error, 'Error recuperando los datos de la oportunidad');
		}
	}

	modalCerrar() {
		this.modalAbierto = false;
		this.refs.modalCerrarOportunidad.addEventListener('transitionend', () => {
			publicarEvento(this, 'modalcerrado', {nombreModal: 'modalCerrarOportunidad'});
		}, {once: true});
		this.refs.modalCerrarOportunidad.classList.remove('slds-fade-in-open');
		this.refs.backdropModal.classList.remove('slds-backdrop_open');
	}

	modalTeclaPulsada({keyCode}) {
		keyCode === 27 && this.modalCerrar();
	}

	@api abrirModal() {
		const modalCerrarOportunidad = this.refs.modalCerrarOportunidad;
		if (modalCerrarOportunidad.classList.contains('slds-fade-in-open')) {
			return;
		}
		this.modalAbierto = true;
		if (!this.oportunidad) {
			return; //Si el getRecord no ha acabado, el modal se abrirá cuando acabe
		} else if (!getFieldValue(this.oportunidad, OPP_PRODUCTO)) {
			this.modalAbierto = false;
			toast('info', 'Oportunidad sin producto', 'Es necesario que la oportunidad tenga un producto para poder cerrarla');
			return;
		}

		//Preparar opciones del desplegable de etapas finales
		const etapasFinales = [{label: 'Rechazada', value: 'Rechazada'}];
		if (getFieldValue(this.oportunidad, 'Opportunity.CSBD_Contact__c') || getFieldValue(this.oportunidad, 'Opportunity.CSBD_No_Identificado__c')) {
			etapasFinales.push({label: 'Formalizada', value: 'Formalizada'}, {label: 'Perdida', value: 'Perdida'});
		}
		this.cerrarEtapas = etapasFinales;

		const inputEtapa = this.refs.inputEtapa;
		if (etapasFinales.length === 1) {
			inputEtapa.value = etapasFinales[0].value;
			this.inputEtapaOnchange();
		}

		this.refs.backdropModal.classList.add('slds-backdrop_open');
		modalCerrarOportunidad.classList.add('slds-fade-in-open');
		this.seleccionarControl(inputEtapa.value ? 'inputResolucion' : 'inputEtapa', 50);
	}

	inputEtapaOnchange() {
		const inputEtapa = this.template.querySelector('.inputEtapa');
		inputEtapa.setCustomValidity('');
		const etapa = inputEtapa.value;
		if (etapa === 'Formalizada') {
			if (!getFieldValue(this.oportunidad, OPP_AMOUNT)) {
				inputEtapa.setCustomValidity('No se puede formalizar una oportunidad con importe 0€.');
			} else {
				obtenerOportunidadesHijasApex({idOportunidad: this.recordId})
				.then(abiertas => abiertas && inputEtapa.setCustomValidity('La oportunidad tiene acciones comerciales abiertas.'))
				.catch(error => errorApex(this, error, 'Error consultando acciones comerciales'));
			}
		}

		obtenerResolucionesApex({
			producto: getFieldValue(this.oportunidad, OPP_PRODUCTO),
			nombreRecordType: getFieldValue(this.oportunidad, OPP_RT_NAME),
			etapa
		}).then(resoluciones => {
			let inputResolucion =  this.template.querySelector('.inputResolucion');
			inputResolucion.value = null;
			this.cerrarResoluciones = resoluciones.map(resolucion => ({label: resolucion, value: resolucion}));

			const esDesistimiento = getFieldValue(this.oportunidad, OPP_RT_DEVNAME) === 'CSBD_Desistimiento';
			if (esDesistimiento && etapa === 'Formalizada') {
				inputResolucion.value = 'Desistimiento realizado';
			} else if (esDesistimiento && etapa === 'Rechazada') {
				inputResolucion.value = 'Duplicada';
			} else if (resoluciones.length === 1) {
				inputResolucion.value = resoluciones[0];
			}
			this.seleccionarControl('inputResolucion', 20);
		}).catch(error => errorApex(this, error, 'Error obteniendo la lista deresoluciones'));
	}

	inputResolucionOnchange() {
		this.mostrarMotivoRechazo = false;
		this.mostrarTipoBonificado = false;

		let resolucion = this.template.querySelector('.inputResolucion').value;
		if (resolucion === 'Competencia' && getFieldValue(this.oportunidad, OPP_RT_DEVNAME) === 'CSBD_Hipoteca') {
			obtenerEntidadesCompetenciaApex()
			.then(entidadesCompetencia => {
				this.template.querySelector('.inputEntidadCompetencia').value = null;
				this.entidadesCompetencia = entidadesCompetencia.map(entidad => ({label: entidad, value: entidad}));
			}).catch(error => errorApex(this, error, 'Error obteniendo entidades'));
			this.mostrarTipoBonificado = true;

		} else if (resolucion === 'Devolución a contact' && getFieldValue(this.oportunidad, OPP_RT_DEVNAME) === 'CSBD_MAC') {
			this.mostrarMotivoRechazo = true;
		}

		if (this.mostrarMotivoRechazo) {
			this.seleccionarControl('inputMotivoRechazo', 40);
		} else if (this.mostrarTipoBonificado) {
			this.seleccionarControl('inputTipoOfertado', 40);
		} else {
			this.seleccionarControl('botonAceptar', 40);
		}

		//if (resultado === 'Competencia') {
		//let obtenerEntidad = component.get('c.obtenerEntidades');
		//obtenerEntidad.setCallback(this, response => {
		//if (response.getState() === 'SUCCESS') {
		//let inputEntidadCompetencia = component.find('inputEntidadCompetencia');
		//inputEntidadCompetencia.set('v.value', null);
		//const entidades = response.getReturnValue();
		//component.set('v.entidadesCompetencia', entidades.map(entidad => ({label: entidad, value: entidad})));
		//helper.seleccionarControl(component, 'inputEntidadCompetencia', 40);
		//}
		//});
		//$A.enqueueAction(obtenerEntidad);
	}

	cerrarOportunidad() {
		//Validaciones
		const controles = ['.inputEtapa', '.inputResolucion', '.inputMotivoRechazo', '.inputTipoOfertado', '.inputEntidadCompetencia'];
		const ok = controles.reduce((validity, control) => {
			const input = this.template.querySelector(control);
			input && input.reportValidity();
			return validity && input?.validity.valid;
		}, true);

		if (ok) {
			//Actualizar oportunidad
			const inputTipoOfertado = this.refs.inputTipoOfertado;
			const inputEntidadCompetencia = this.refs.inputEntidadCompetencia;
			const campos = {
				'CSBD_TipoOfertado__c': inputTipoOfertado ? parseFloat(inputTipoOfertado.value) : null,
				'CSBD_EntidadCompetencia__c': inputEntidadCompetencia ? inputEntidadCompetencia.value : null
			};
			const inputMotivoRechazo = this.refs.inputMotivoRechazo;
			if (inputMotivoRechazo) {
				let notasGestorNew = inputMotivoRechazo.value;
				const notasGestorOld = getFieldValue(this.oportunidad, OPP_NOTAS_GESTOR);
				notasGestorOld && (notasGestorNew += '\n' + notasGestorOld);
				campos['CSBD_Notas_gestor__c'] = notasGestorNew;
			}

			this.refs.botonAceptar.disabled = true;
			cerrarOportunidadApex({
				recordId: this.recordId,
				nombreEtapaVentas: this.refs.inputEtapa.value,
				resolucion: this.refs.inputResolucion.value,
				campos
			}).then(oportunidad => {
				toast('success', 'Se cerró oportunidad ' + oportunidad.CSBD_Identificador__c, 'La oportunidad se cerró correctamente');
				this.wireGetRecordTimestamp = new Date();
				this.modalCerrar();
			}).catch(error => errorApex(this, error, 'Problema cerrando la oportunidad'))
			.finally(() => this.refs.botonAceptar.disabled = false);
		}
	}

	seleccionarControl(nombreControl, delay) {
		window.setTimeout(() => this.template.querySelector('.' + nombreControl).focus(), delay);
	}


	//cerrarOportunidad() {
	//let campos = new Map();

	//let notasGestor;

	//let inputEtapa = component.find('inputEtapa');
	//inputEtapa.checkValidity();
	//inputEtapa.reportValidity();

	//let inputResolucion = component.find('inputResolucion');
	//inputResolucion.checkValidity();
	//inputResolucion.reportValidity();

	//let inputMotivoRechazo = component.find('inputMotivoRechazo');
	//if (inputMotivoRechazo) {
	//inputMotivoRechazo.checkValidity();
	//inputMotivoRechazo.reportValidity();
	//if (inputMotivoRechazo.get('v.validity').valid) {

	//notasGestor = component.get('v.oportunidad.CSBD_Notas_gestor__c') ? inputMotivoRechazo.get('v.value') + '\n' + component.get('v.oportunidad.CSBD_Notas_gestor__c') : inputMotivoRechazo.get('v.value');

	//campos.set('CSBD_Notas_gestor__c', notasGestor);
	//}
	//}

	//let inputTipoOfertado = component.find('inputTipoOfertado');
	//if (inputTipoOfertado) {
	//inputTipoOfertado.checkValidity();
	//inputTipoOfertado.reportValidity();
	//if (inputTipoOfertado.get('v.validity').valid) {
	//campos.set('CSBD_TipoOfertado__c', parseFloat(inputTipoOfertado.get('v.value')));
	//}
	//}

	//let inputEntidadCompetencia = component.find('inputEntidadCompetencia');
	//if (inputEntidadCompetencia) {
	//inputTipoOfertado.checkValidity();
	//inputTipoOfertado.reportValidity();
	//if (inputEntidadCompetencia.get('v.validity').valid) {
	//campos.set('CSBD_EntidadCompetencia__c', inputEntidadCompetencia.get('v.value'));
	//}
	//}

	//if (inputEtapa.get('v.validity').valid
	//&& inputResolucion.get('v.validity').valid
	//&& !inputMotivoRechazo || inputEtapa.get('v.validity').valid && inputResolucion.get('v.validity').valid && inputMotivoRechazo && inputMotivoRechazo.get('v.validity').valid) {
	//component.find('botonAceptar').set('v.disabled', true);
	//let cerrarOportunidad = component.get('c.cerrarOportunidad');
	//cerrarOportunidad.setParams({
	//recordId: component.get('v.recordId'),
	//nombreEtapaVentas: inputEtapa.get('v.value'),
	//resolucion: inputResolucion.get('v.value'),
	//campos: Object.fromEntries(campos)
	//});
	//cerrarOportunidad.setCallback(this, response => {
	//if (response.getState() === 'SUCCESS') {
	//helper.mostrarToast('Se cerró oportunidad ' + response.getReturnValue().CSBD_Identificador__c, 'La oportunidad se cerró satisfactoriamente', 'success');
	//component.find('opportunityData').reloadRecord(true);
	//$A.enqueueAction(component.get('c.cerrarModalCerrar'));
	//} else {
	//console.error(cerrarOportunidad.getError());
	//helper.mostrarToast('Problema cerrando la oportunidad', cerrarOportunidad.getError()[0].message, 'error');
	//component.find('botonAceptar').set('v.disabled', false);
	//}
	//});
	//$A.enqueueAction(cerrarOportunidad);
	//}

	//}
}