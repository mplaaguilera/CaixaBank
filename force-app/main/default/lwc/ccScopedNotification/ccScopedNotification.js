//Marc Pla, 25 junio 2019: "Scoped notification" flexible
//https://lightningdesignsystem.com/components/scoped-notifications/


import {LightningElement, api} from 'lwc';

const TEMA_CLASS = {
	'Claro': 'slds-scoped-notification_light',
	'Oscuro': 'slds-scoped-notification_dark',
	'Éxito': 'slds-theme_success',
	'Advertencia': 'slds-theme_warning',
	'Error': 'slds-theme_error'
};

export default class CcScopedNotification extends LightningElement {
	@api tema = 'Claro';

	@api texture;

	@api icono = 'info';

	@api mensaje = '';

	@api articleStyle;

	/*
	get articleClass() {
		let articleClass = 'slds-card' + (this.texture ? ' slds-theme_alert-texture' : '');
		if (this.tema === 'Claro') {
			articleClass += ' slds-scoped-notification_light';
		} else if (this.tema === 'Oscuro') {
			articleClass += ' slds-scoped-notification_dark';
		} else if (this.tema === 'Éxito') {
			articleClass += ' slds-theme_success';
		} else if (this.tema === 'Advertencia') {
			articleClass += ' slds-theme_warning';
		} else if (this.tema === 'Error') {
			articleClass += ' slds-theme_error';
		}
		return articleClass;
	}
	*/

	get articleClass() {
		let articleClass = 'slds-card';
		if (this.texture) {
			articleClass += ' slds-theme_alert-texture';
		}
		return articleClass + ' ' + (TEMA_CLASS[this.tema] || '');
	}

	get iconoNombre() {
		//Por consistencia visual los iconos siempre se recuperan del sprite 'utility'
		return 'utility:' + this.icono;
	}

	get iconoVariant() {
		return ['Oscuro', 'Éxito', 'Error', 'Advertencia'].includes(this.tema) ? 'inverse' : '';
	}
}