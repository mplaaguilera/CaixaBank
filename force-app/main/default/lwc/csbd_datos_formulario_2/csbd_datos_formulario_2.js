import {LightningElement, api, wire} from 'lwc';
import {NavigationMixin} from 'lightning/navigation';
import {copiarTextoAlPortapapeles, errorApex} from 'c/csbd_lwcUtils';

import getSolicitud from '@salesforce/apex/CSBD_Datos_Formulario_Controller.getSolicitud';

//eslint-disable-next-line new-cap
export default class csbdDatosFormulario2 extends NavigationMixin(LightningElement) {
	@api recordId;

	renderizar = false;

	solicitud;

	solicitudResultados;

	solicitudReferencia;

	tareaSolicitudRecibida;

	@wire(getSolicitud, {idOportunidad: '$recordId'})
	wiredSolicitud({error, data}) {
		if (error) {
			errorApex(error, 'Problema obteniendo los datos de la petición');
		} else {
			if (data && data.datosFormulario.length) {
				this.solicitudReferencia = data.datosFormulario.find(atributo => atributo.nombre === 'referencia_usuario')?.valor;
				this.solicitud = data.datosFormulario;
				this.solicitudResultados = data.datosFormulario;
				this.tareaSolicitudRecibida = data.tareaSolicitudRecibida;
				//eslint-disable-next-line @lwc/lwc/no-async-operation
				window.setTimeout(() => this.template.querySelector('lightning-input').focus(), 400);
			}
			this.renderizar = true;
		}
	}

	copiarJsonAlPortapapeles(event) {
		const cuerpoPeticion = JSON.stringify(JSON.parse(this.tareaSolicitudRecibida.Description), null, 3);
		copiarTextoAlPortapapeles(cuerpoPeticion);

		//Feedback visual
		const boton = event.target;
		event.target.iconName = 'utility:check';
		//eslint-disable-next-line @lwc/lwc/no-async-operation
		window.setTimeout(() => boton.iconName = 'utility:merge_field', 1000);
	}

	verDetalleTarea() {
		this[NavigationMixin.Navigate]({
			type: 'standard__recordPage',
			attributes: {recordId: this.tareaSolicitudRecibida.Id, actionName: 'view'}
		});
	}

	filtrarAtributos(event) {
		const textoBusqueda = event.detail.value.toLowerCase();
		this.solicitudResultados = this.solicitud.filter(
			atributo => atributo.nombre.toLowerCase().includes(textoBusqueda) || atributo.valor.toLowerCase().includes(textoBusqueda)
		);
	}

	copiarValor(event) {
		copiarTextoAlPortapapeles(event.target.dataset.valor);
	}
}