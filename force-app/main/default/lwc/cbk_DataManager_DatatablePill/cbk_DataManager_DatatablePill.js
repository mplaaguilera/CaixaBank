import {LightningElement, api} from 'lwc';

export default class cbkDataManagerDatatablePill extends LightningElement {


	@api items;

	@api colores;

	pills = [];

	tooltip;

	connectedCallback() {
		this.pills = this.items?.map(item => ({label: item, style: this.colores?.[item].style})) ?? [];
		this.tooltip = this.items?.join(' · ');
	}
}