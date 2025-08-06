import {LightningElement, api} from 'lwc';

export default class csbdDatatableCell extends LightningElement {
	@api content;

	@api type;

	isText = false;

	isNumber = false;

	isCurrency = false;

	isPercent = false;

	contentPercent;

	connectedCallback() {
		if (this.type === 'number') {
			this.isNumber = true;
		} else if (this.type === 'currency') {
			this.isCurrency = true;
		} else if (this.type === 'percent') {
			this.contentPercent = this.content / 100;
			this.isPercent = true;
		} else { //text
			this.isText = true;
		}
	}

	renderedCallback() {
		console.log('renderedCallback');
	}
}