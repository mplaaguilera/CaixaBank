import {LightningElement, api} from 'lwc';

export default class SsegIllustration extends LightningElement {
	@api tipo = 'Going Camping';

	@api mensaje;

	get tipoGoingCamping() {
		return this.tipo === 'Going Camping';
	}

	get tipoMaintenance() {
		return this.tipo === 'Maintenance';
	}

	get tipoDesert() {
		return this.tipo === 'Desert';
	}
}