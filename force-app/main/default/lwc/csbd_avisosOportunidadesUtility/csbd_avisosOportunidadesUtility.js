import {LightningElement} from 'lwc';
import {NavigationMixin} from 'lightning/navigation';
import {errorApex} from 'c/csbd_lwcUtils';
import {Aviso, mostrarToastCsbd} from './utils';

import getFrecuenciaAvisosAutoApex from '@salesforce/apex/CSBD_AvisosOportunidadesUtility_Apex.getFrecuenciaAvisosAuto';
import getNuevasSolicitudesPhdApex from '@salesforce/apex/CSBD_AvisosOportunidadesUtility_Apex.getNuevasSolicitudesPhd';

//eslint-disable-next-line new-cap
export default class csbdAvisosOportunidadesUtility extends NavigationMixin(LightningElement) {

	frecuenciaAvisosAuto;

	idTimeout;

	avisos = [];

	async connectedCallback() {
		const frecuenciaAvisosAuto = await getFrecuenciaAvisosAutoApex({});
		if (frecuenciaAvisosAuto) {
			this.frecuenciaAvisosAuto = frecuenciaAvisosAuto * 60000;
			this.programarProximoAviso();
		}
	}

	disconnectedCallback() {
		clearTimeout(this.idTimeout);
	}

	programarProximoAviso() {
		if (this.frecuenciaAvisosAuto) {
			this.idTimeout = setTimeout(this.getAvisos.bind(this), this.frecuenciaAvisosAuto);
		}
	}

	async getAvisos() {
		const nuevosAvisos = [];

		try {
			//Nuevas solicitudes PHD
			const nuevasSolicitudesPhd = await this.getNuevasSolicitudesPhd();
			if (nuevasSolicitudesPhd && nuevasSolicitudesPhd.length) {
				nuevosAvisos.push(nuevasSolicitudesPhd);
			}

			const avisosActualizados = [...nuevosAvisos, ...this.avisos];
			this.avisos = avisosActualizados.slice(0, 300);

			//Reiniciem el temporitzador quan es crida manualment
			this.programarProximoAviso();
		} catch (error) {
			errorApex(error);
		}
	}

	async getNuevasSolicitudesPhd() {
		try {
			const nuevasSolicitudesPhd = await getNuevasSolicitudesPhdApex();
			if (nuevasSolicitudesPhd.length) {
				//Añadir aviso al historial
				const titulo = `Hay ${nuevasSolicitudesPhd.length} ${nuevasSolicitudesPhd.length === 1 ? 'oportunidad' : 'oportunidades'} Facilitea con nuevas búsquedas en plataformas digitales.`;
				this.avisos = [new Aviso(titulo, this.verListview), ...this.avisos];

				//Mostrar toast CSBD (toast custom basado en la especificación SLDS estandar)
				let toastMessage;
				if (nuevasSolicitudesPhd.length === 1) {
					toastMessage = 'El cliente hizo una nueva búsqueda para la hipoteca:';
				} else {
					toastMessage = `Los clientes hicieron nuevas búsquedas para ${nuevasSolicitudesPhd.length} hipotecas:`;
				}
				mostrarToastCsbd({
					titulo: 'Oportunidades Facilitea con nuevas búsquedas en plataformas digitales',
					mensaje: toastMessage,
					lista: nuevasSolicitudesPhd.map(opp => ({
						label: opp.CSBD_Identificador__c,
						title: 'Ver detalle',
						detalle: opp.Account?.Name.toUpperCase() ?? '',
						recordId: opp.Id,
						funcion: recordId => this.verDetalleRegistro(recordId),
						bullet: true
					})),
					icono: 'screen',
					backgroundColor: 'rgb(176 204 206)'
				});
			}
		} catch (error) {
			errorApex(error);
		}
	}

	async eliminarAvisos() {
		this.avisos = [];
	}

	verDetalleRegistro(recordId) {
		this[NavigationMixin.Navigate]({type: 'standard__recordPage', attributes: {recordId, actionName: 'view'}});
	}

	verListview() {
		this[NavigationMixin.Navigate]({
			type: 'standard__objectPage',
			attributes: {objectApiName: 'Opportunity', actionName: 'list'},
			state: {filterName: 'CSBD_Opportunity_Facilitea_Listview'}
		});
	}
}