({
	doInit: function(component) {
		let getSolicitud = component.get('c.getSolicitud');
		getSolicitud.setParam('idOportunidad', component.get('v.recordId'));
		getSolicitud.setCallback(this, response => {
			if (response.getState() === 'SUCCESS') {
				let retorno = response.getReturnValue();
				if (retorno.datosFormulario.length > 0) {
					let referenciaUsuario = retorno.datosFormulario.find(atributo => atributo.nombre === 'referencia_usuario');
					component.set('v.solicitudReferencia', referenciaUsuario !== undefined ? referenciaUsuario.valor : '');
					component.set('v.solicitud', retorno.datosFormulario);
					component.set('v.solicitudResultados', retorno.datosFormulario);
					component.set('v.tareaSolicitudRecibida', retorno.tareaSolicitudRecibida);
					window.setTimeout($A.getCallback(() => component.find('inputBuscar').focus()), 100);
				}
			} else if (response.getState() === 'ERROR') {
				console.error('error');
			}
			component.set('v.cargando', false);
		});
		$A.enqueueAction(getSolicitud);
	},

	mostrarBotonCopiar: function(component, event) {
		$A.util.toggleClass(event.currentTarget, 'csbd-invisible');
	},

	copiarValor: function(component, event) {
		let hiddenElement = document.createElement('input');
		hiddenElement.setAttribute('value', event.getSource().get('v.name'));
		document.body.appendChild(hiddenElement);
		hiddenElement.select();
		document.execCommand('copy');
		document.body.removeChild(hiddenElement);
	},

	copiarJson: function(component, event) {
		let hiddenElement = document.createElement('input');
		hiddenElement.setAttribute('value', component.get('v.tareaSolicitudRecibida.Description'));
		document.body.appendChild(hiddenElement);
		hiddenElement.select();
		document.execCommand('copy');
		document.body.removeChild(hiddenElement);

		let orignalLabel = event.getSource().get('v.label');
		event.getSource().set('v.iconName', 'utility:check');
		event.getSource().set('v.label', 'Cuerpo copiado al portapapeles');

		window.setTimeout($A.getCallback(() => {
			event.getSource().set('v.iconName', 'utility:merge_field');
			event.getSource().set('v.label', orignalLabel);
		}), 1000);
	},

	filtrarAtributos: function(component) {
		let textoBusqueda = component.find('inputBuscar').get('v.value').toLowerCase();
		let atributos = component.get('v.solicitud');
		component.set(
			'v.solicitudResultados',
			atributos.filter(atributo => atributo.nombre.toLowerCase().includes(textoBusqueda)
				|| atributo.valor.toLowerCase().includes(textoBusqueda))
		);
	},

	abrirTarea: function(component) {
		let navEvt = $A.get('e.force:navigateToSObject');
		navEvt.setParams({'recordId': component.get('v.tareaSolicitudRecibida.Id')});
		navEvt.fire();
	}
});