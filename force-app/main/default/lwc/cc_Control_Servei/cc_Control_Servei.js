import {LightningElement, api, wire} from 'lwc';
import {getRecord, getFieldValue} from 'lightning/uiRecordApi';
import {ShowToastEvent} from 'lightning/platformShowToastEvent';
import {CloseActionScreenEvent} from 'lightning/actions';

import AGRUPADOR_NAME from '@salesforce/schema/CC_Agrupador__c.Name';
import AGRUPADOR_ESTADO from '@salesforce/schema/CC_Agrupador__c.CC_Estado__c';

import initApex from '@salesforce/apex/CC_Control_Servei_Controller.init';
import getCasosApex from '@salesforce/apex/CC_Control_Servei_Controller.getCasos';
import enviarComunicacionApex from '@salesforce/apex/CC_Control_Servei_Controller.enviarComunicacion';
import gestionarImagenes from '@salesforce/apex/CC_Control_Servei_Controller.gestionarImagenesInlineRedactarMail';
//import gestionarImagenes from '@salesforce/apex/CC_Control_Servei_Controller.testImagenesGestionar';


const COLUMNS = [
	{label: 'Fecha', fieldName: 'CreatedDate', type: 'date', sortable: true, initialWidth: 138,
		typeAttributes: {day: 'numeric', month: 'numeric', year: 'numeric', hour: '2-digit', minute: '2-digit', hour12: false}},
	{label: 'Caso', type: 'url', fieldName: '_url', initialWidth: 96,
		typeAttributes: {label: {fieldName: 'CaseNumber'}, tooltip: 'Ver detalle'}},
	{label: 'Asunto', fieldName: 'Subject'},
	{label: 'Tipo', fieldName: '_recordTypeName', initialWidth: 110},
	{label: 'Email del contacto', type: 'email', fieldName: '_contactEmail'}
];

export default class ccControlServei extends LightningElement {

	@api recordId;

	spinner = true;

	datatableColumns = COLUMNS;

	datatableData = [];

	datatableSelectedRows = [];

	cuerpo;

	formats = [
		'font', 'size', 'bold', 'italic', 'underline', 'strike', 'list', 'indent',
		'align', 'link', 'image', 'clean', 'table', 'header', 'color', 'background'
	];

	fechasBusqueda = {
		desde: new Date().toISOString(),
		hasta: new Date().toISOString()
	};

	get botonEnviarDisabled() {
		return this.spinner || !this.datatableSelectedRows.length;
	}

	@wire(getRecord, {recordId: '$recordId', fields: [AGRUPADOR_NAME, AGRUPADOR_ESTADO]})
	async wiredAgrupador({error, data}) {
		let cerrarQuickAction = true;
		if (error) {
			console.error(error);
			this.toast('error', 'Problema recuperando los datos del agrupador', error);
		} else if (data) {
			if (getFieldValue(data, AGRUPADOR_ESTADO) === 'Cerrado') {
				this.toast('info', 'El agrupador está cerrado', 'Solo se pueden enviar notificaciones de agrupadores en gestión');
			} else {
				const retorno = await initApex({
					idAgrupador: this.recordId,
					fechaInicio: this.fechasBusqueda.desde,
					fechaFin: this.fechasBusqueda.hasta
				});
				if (!retorno.permiso) {
					this.toast('error', 'Permisos de usuario insuficientes', 'Contacta con su responsable para realizar esta operación');
				} else {
					if (!retorno.casos.length) {
						this.toast('info', 'El agrupador no tiene casos -    ' + retorno.casos.length , `El agrupador ${getFieldValue(data, AGRUPADOR_NAME)} no tiene casos asociados`);
					} else {
						this.datatableData = this.formatDatatableData(retorno.casos);
						this.cuerpo = retorno.htmlPlantilla;
						cerrarQuickAction = false;
					}
				}
			}
		}
		if (cerrarQuickAction) {
			this.cerrarQuickAction();
		} else {
			this.template.querySelector('div.body').classList.remove('oculto');
			this.spinner = false;
		}
	}

	async enviarComunicacion() {

		this.spinner = true;
		// let plantilla;
		// gestionarImagenes({cuerpoMail: this.cuerpo})
		// .then(result => {
		// 	this.cuerpo = result;
		// 	//this.toast('success', 'Imágenes parseadas con éxito');
		// 	this.cerrarQuickAction();
		// }).catch(error => {
		// 	console.error(error);
		// 	this.spinner = false;
		// 	//console.toast('error', 'Problema preparando imágenes parseadas con éxito', error);
		// });

		// plantilla = this.cuerpo;
		
		enviarComunicacionApex({plantilla: this.cuerpo, casos: this.datatableSelectedRows})
		.then(() => {
			this.toast('success', 'Comunicaciones enviadas con éxito');
			this.cerrarQuickAction();
		}).catch(error => {
			console.error(error);
			this.toast('error', 'Problema preparando el envío de las comunicaciones', error);
		}).finally(() => this.spinner = false);
	}

	handleChange(event) {
		this.cuerpo = this.template.querySelector('lightning-input-rich-text').value;

	}

	buscarCasosPorFecha() {
		this.spinner = true;
		this.fechasBusqueda = {
			desde: this.template.querySelector('lightning-input.inputFechaDesde').value,
			hasta: this.template.querySelector('lightning-input.inputFechaHasta').value
		};
		getCasosApex({
			idAgrupador: this.recordId,
			fechaInicio: this.fechasBusqueda.desde,
			fechaFin: this.fechasBusqueda.hasta,
			busquedaFechas: true
		})
		.then(casos => this.datatableData = this.formatDatatableData(casos))
		.catch(error => {
			console.error(error);
			this.toast('error', 'Problema recuperando los datos', error);
		}).finally(() => this.spinner = false);
	}

	datatableOnrowselection(event) {
		this.datatableSelectedRows = event.detail.selectedRows;
	}

	formatDatatableData(casos) {
		return casos.map(caso => ({...caso,
			_url: '/' + caso.Id,
			_recordTypeName: caso.RecordType.Name,
			_contactEmail: caso.Contact?.Email
		}));
	}

	toast(variant, title, message) {
		this.dispatchEvent(new ShowToastEvent({variant, title, message}));
	}

	cerrarQuickAction() {
		this.dispatchEvent(new CloseActionScreenEvent());
	}
}