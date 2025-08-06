import {LightningElement, api} from 'lwc';

export default class csbdPill extends LightningElement {
	@api botonCerrar;

	@api backgroundColor;

	@api color;

	@api iconName;

	@api label;

	get pillActionStyle() {
		return `background-color: ${this.backgroundColor}; color: ${this.color};`;
	}

	connectedCallback() {
		const hostStyle = this.template.host.style;
		hostStyle.setProperty('--csbd-pill-background-color', this.backgroundColor);
	}
}