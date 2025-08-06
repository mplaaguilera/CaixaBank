import {LightningElement, api} from 'lwc';

export default class segIllustration extends LightningElement {
	@api tipo = 'Going Camping';

	@api size;

	@api mensaje;

	renderedCallback() {
		const illustration = this.template.querySelector('div.slds-illustration');
		if (illustration) {
			const illustrationSizeClasses = {small: 'slds-illustration_small', large: 'slds-illustration_large'};
			illustration.classList.remove(...['slds-illustration_small', 'slds-illustration_large']);
			illustration.classList.add(illustrationSizeClasses[this.size] || 'slds-illustration_large');
		}
	}

	get tipoGoingCamping() {
		return this.tipo === 'Going Camping';
	}

	get tipoMaintenance() {
		return this.tipo === 'Maintenance';
	}

	get tipoDesert() {
		return this.tipo === 'Desert';
	}

	get tipoOpenRoad() {
		return this.tipo === 'Open Road';
	}

	get tipoResearch() {
		return this.tipo === 'Research';
	}
}