import {LightningElement, api, wire} from 'lwc';

import getPrestamosByAccountId from '@salesforce/apex/SAC_VisualizacionPrestamos.getPrestamosByAccountId';

const TITULOS = {'SAC_Prestamo': 'Préstamos', 'SAC_Titular_Prestamo': 'Titular Préstamo', 'SAC_Titular_Cuenta': 'Titular Cuenta'};

export default class prestamoList extends LightningElement {
	@api recordId;

	prestamos;

	showErrorMessage = false;

	@wire(getPrestamosByAccountId, {recId: '$recordId'})
	wiredprestamos({error, data: prestamos}) {
		if (prestamos) {
			const self = this;
			setTimeout(() => {
				this.prestamos = Object.keys(prestamos).map(rt => ({
					tableTitle: TITULOS[rt],
					prestamoRT: rt === 'SAC_Prestamo',
					titularPrestamoRT: rt === 'SAC_Titular_Prestamo',
					titularCuentaRT: rt === 'SAC_Titular_Cuenta',
					prestamos: prestamos[rt].map(p => ({...p, showDetails: false}))
				}));
				self.dispatchEvent(new CustomEvent('validationcheck', {
					detail: {hasValidation: Object.values(prestamos).flat().some(p => p.validation)}}));
			}, 0);

		} else if (error) {
			this.prestamos = null;
			this.showErrorMessage = true;
		}
	}

	abrirCerrarDetalles({currentTarget: botonMostrarDetalles}) {
		botonMostrarDetalles.closest('article.slds-card').classList.toggle('detallesVisibles');
	}
}