import {LightningElement, track} from 'lwc';
import {ShowToastEvent} from 'lightning/platformShowToastEvent';

import getProyectosApex from '@salesforce/apex/CBK_DataManagerCreateFields_Apex.getProyectos';
import getReleasesApex from '@salesforce/apex/CBK_DataManagerCreateFields_Apex.getReleases';
import getSolicitudesApex from '@salesforce/apex/CBK_DataManagerCreateFields_Apex.getSolicitudes';

export default class cbkDataManagerCreateFields extends LightningElement {

	usuarioOt = false;

	releases = [];

	releasesName = [];

	releaseSeleccionada;

	estados = ['Draft', 'Pending', 'Approved'];

	@track datatableSolicitudes = {data: [], columns: [], sortedBy: 'CreatedDate', sortedDirection: 'asc'};

	@track solicitudSeleccionada = {};

	async connectedCallback() {
		this.getReleases();
		this.datatableSolicitudes.columns = [
			{label: 'Creada', type: 'date', fieldName: 'CreatedDate', initialWidth: 110, sortable: true,
				typeAttributes: {year: '2-digit', month: 'numeric', day: '2-digit', hour: 'numeric', minute: 'numeric'}},
			{label: 'Solicitud', type: 'url', fieldName: '_url', initialWidth: 107, sortable: true,
				typeAttributes: {label: {fieldName: 'Name'}, target: '_self', tooltip: {fieldName: 'Name'}}},
			{label: 'API Name', fieldName: 'API_Name__c', initialWidth: 210, sortable: true},
			{label: 'Object', type: 'url', fieldName: '_objectUrl', initialWidth: 125, sortable: true,
				typeAttributes: {label: {fieldName: '_objectApiName', target: '_self', tooltip: {fieldName: '_objectUrl'}}}},
			{label: 'Release', type: 'url', fieldName: '_releaseUrl', initialWidth: 240, sortable: true,
				typeAttributes: {label: {fieldName: '_releaseName'}, target: '_self', tooltip: {fieldName: '_releaseName'}}},
			{label: 'Estado', fieldName: 'Status__c', initialWidth: 120, sortable: true,
				cellAttributes: {iconName: {fieldName: '_estadoIconName'}, class: 'prova'}}, //{fieldName: '_estadoIconClass'}}},
			{label: 'Tipo', fieldName: '_recordTypeName', initialWidth: 90, sortable: true},
			{label: 'Proyectos', type: 'pills', fieldName: '_proyectos',
				typeAttributes: {proyectos: {fieldName: '_proyectos'}, colores: await this.getEstilosPillsProyectos()}}
		];
		this.getSolicitudes(true);
	}

	async getSolicitudes(seleccionarPrimerRegistro = false) {
		const solicitudes = await getSolicitudesApex({});
		const iconosEstado = {
			Draft: {iconName: 'utility:edit', iconClass: null},
			Pending: {iconName: 'utility:clock', iconClass: null},
			Approved: {iconName: 'utility:success', iconClass: 'slds-icon-text-success'},
			Denied: {iconName: 'utility:clear', iconClass: 'slds-icon-text-error'}
		};
		this.datatableSolicitudes.data = solicitudes.map(s => ({
			...s,
			_url: '/' + s.Id,
			_recordTypeName: s.RecordType.Name,
			_objectApiName: s.RecordType.DeveloperName === 'Field' ? s.Object__r?.API_Name__c : s.API_Name__c,
			_objectUrl: '/' + (s.RecordType.DeveloperName === 'Field' ? s.Object__c : s.Id),
			_proyectos: s.Proyectos__c?.split(';').sort(),
			_estado: s.Status__c,
			_estadoIconName: iconosEstado[s.Status__c].iconName,
			_estadoIconClass: iconosEstado[s.Status__c].iconClass,
			_releaseName: s.Release__r?.Name, _releaseUrl: s.Release__c ? '/' + s.Release__c : null,
			_releaseIconName: s.Release__c ? 'custom:custom13' : null
		}));
		this.datatableSolicitudes.fechaActualizacion = this.formatearFecha(new Date());

		if (seleccionarPrimerRegistro && solicitudes.length) {
			//eslint-disable-next-line @lwc/lwc/no-async-operation
			this.seleccionarSolicitud(this.datatableSolicitudes.data[0]);
			this.template.querySelector('.datatableSolicitudes').selectedRows = [this.datatableSolicitudes.data[0].Id];
		}
	}

	botonActualizarOnclick() {
		this.getSolicitudes();
	}

	datatableOnrowselection(event) {
		if (event.detail.selectedRows.length) {
			const solicitud = event.detail.selectedRows[0];
			this.seleccionarSolicitud(solicitud);
		}
	}

	async seleccionarSolicitud(solicitud) {
		this.estados = ['Draft', 'Pending', solicitud?.Status__c === 'Denied' ? 'Denied' : 'Approved'];
		//eslint-disable-next-line @lwc/lwc/no-async-operation
		window.setTimeout(() => {
			this.solicitudSeleccionada = solicitud;
			this.template.querySelector('.botonClonar').disabled = false;
			this.template.querySelector('.botonRechazar').disabled = ['Approved', 'Denied'].includes(solicitud?.Status__c);
			this.template.querySelector('.botonSolicitar').disabled = !solicitud?.Id;
		}, 0);
	}

	formatearFecha(fecha) {
		const hora = fecha.getHours() + ':' + fecha.getMinutes() + ':' + fecha.getSeconds();
		return `${fecha.getDate()} de ${fecha.toLocaleString('default', {month: 'long'})} a las ${hora}`;
	}

	nuevaSolicitud() {
		//eslint-disable-next-line camelcase
		this.datatableSolicitudes.data.push({Id: null, Name: 'NUEVA', Field_Type__c: 'Custom'});
		this.datatableSolicitudes.data = [...this.datatableSolicitudes.data];
		this.seleccionarSolicitud(this.datatableSolicitudes.data[this.datatableSolicitudes.data.length - 1]);
	}

	guardar() {
		const inputs = Array.from(this.template.querySelectorAll('lightning-input-field.req'));
		inputs.forEach(f => f.reportValidity());
		if (!inputs.some(i => !i.value)) {
			this.template.querySelectorAll('lightning-input-field').forEach(f => f.disabled = true);
			this.template.querySelectorAll('footer.recordEditFormFooter > lightning-button').forEach(b => b.disabled = true);
			this.template.querySelector('.ref').submit();
		}
	}

	cancelar() {
		this.template.querySelectorAll('lightning-input-field').forEach(f => f.reset());
	}

	recordeditformOnsuccess() {
		this.template.querySelectorAll('lightning-input-field').forEach(f => f.disabled = false);
		this.template.querySelectorAll('footer.recordEditFormFooter > lightning-button').forEach(b => b.disabled = false);
		this.getSolicitudes();
		this.toast('success', 'Solicitud actualizada', 'Se guardó correctamente la solicitud ' + this.solicitudSeleccionada.Name);
	}

	seccionOnclick(event) {
		event.currentTarget.closest('div.slds-section').classList.toggle('slds-is-open');
	}

	toast(variant, title, message) {
		dispatchEvent(new ShowToastEvent({variant, title, message, mode: 'dismissable', duration: 4000}));
	}

	menuOpcionesListaOnselect(event) {
		if (event.detail.value === 'restablecerTamañoColumnas') {
			this.datatableSolicitudes.columns = [...this.datatableSolicitudes.columns];
		}
	}

	toggleUsuarioOtOnchange(event) {
		this.usuarioOt = event.detail.checked;
		const datatableSolicitudes = this.template.querySelector('.datatableSolicitudes');
		const selectedRows = datatableSolicitudes.selectedRows;
		datatableSolicitudes.maxRowSelection = event.detail.checked ? null : 1;
		datatableSolicitudes.columns = [...datatableSolicitudes.columns];
		datatableSolicitudes.selectedRows = selectedRows;
	}

	async debug() {
		//eslint-disable-next-line no-console
		console.log('this.datatableSolicitudes.columns');
		//eslint-disable-next-line no-console
		console.log(JSON.stringify(this.datatableSolicitudes.columns, null, 3));
		//eslint-disable-next-line no-console
		console.log('');
		//eslint-disable-next-line no-console
		console.log('this.datatableSolicitudes.data');
	}

	async getEstilosPillsProyectos() {
		const proyectos = await getProyectosApex({});
		let estilosPills = {};
		proyectos.forEach((proyecto, i) => {
			if (!(proyecto in estilosPills)) {
				estilosPills[proyecto] = this.generarPillStyle(i + 1);
			}
		});
		return estilosPills;
	}

	generarPillStyle(i) {
		const hueToRgb = (p, q, t) => {
			if (t < 0) {t += 1}
			if (t > 1) {t -= 1}
			if (t < 1 / 6) {return p + (q - p) * 6 * t}
			if (t < 1 / 2) {return q}
			if (t < 2 / 3) {return p + (q - p) * (2 / 3 - t) * 6}
			return p;
		};
		let [h, s, l] = [1 / 14 * i, 0.7, 0.68];
		const q = l < 0.5 ? l * (1 + s) : l + s - l * s;
		const p = 2 * l - q;
		const bgColor = {
			r: Math.round(hueToRgb(p, q, h + 1 / 3) * 255),
			g: Math.round(hueToRgb(p, q, h) * 255),
			b: Math.round(hueToRgb(p, q, h - 1 / 3) * 255),
			a: 0.19
		};
		let style = 'min-height: unset; cursor: default;';
		style += ` background-color: rgba(${bgColor.r}, ${bgColor.g}, ${bgColor.b}, ${bgColor.a});`;
		return {style};
	}

	datatableSolicitudesOnsort(event) {
		let campoSort = event.detail.fieldName;
		this.datatableSolicitudes.sortedBy = campoSort;
		this.datatableSolicitudes.sortedDirection = event.detail.sortDirection;
		const column = this.datatableSolicitudes.columns.find(c => c.fieldName === campoSort);
		if (column.type === 'url') {
			campoSort = column.typeAttributes.label.fieldName;
		}
		let convertir;
		if (column.type === 'date') {
			convertir = valor => valor && new Date(valor);
		} else if (column.type === 'number') { //eslint-disable-next-line no-extra-parens
			convertir = valor => (valor != null ? valor : -1);
		} else { //eslint-disable-next-line no-extra-parens
			convertir = valor => (valor ?? '').toLowerCase();
		}
		this.datatableSolicitudes.data.sort((registro1, registro2) => {
			let sortedDirectionAux = event.detail.sortDirection === 'asc' ? 1 : -1;
			let valorRegistro1 = convertir(registro1[campoSort]);
			let valorRegistro2 = convertir(registro2[campoSort]);
			return valorRegistro1 < valorRegistro2 ? -sortedDirectionAux : sortedDirectionAux;
		});
		this.datatableSolicitudes.data = [...this.datatableSolicitudes.data];
	}

	async getReleases() {
		const releases = await getReleasesApex({});
		this.releases = releases;
		this.releasesName = releases.map(release => release.Name);
		this.releaseSeleccionada = this.proximaRelease(releases);
		alert(JSON.stringify(this.releaseSeleccionada, null, 3));
	}

	proximaRelease(releases) {
		let fechaMasCercana = null;
		const hoy = new Date();
		let releasesDate = releases.map(r => new Date(r.copado__Completion_Date__c));
		releasesDate = releasesDate.filter(fecha => fecha >= hoy);
		releasesDate.forEach(fecha => {
			if (!fechaMasCercana) {
				fechaMasCercana = fecha;
			} else if (fecha < fechaMasCercana) {
				fechaMasCercana = fecha;
			}
		});
		//eslint-disable-next-line camelcase
		return releases.find(r => r.copado__Completion_Date__c = fechaMasCercana).Name;
	}
}