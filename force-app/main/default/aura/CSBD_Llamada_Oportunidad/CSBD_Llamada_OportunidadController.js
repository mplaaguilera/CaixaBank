({
	doInit: function(component) {
		let getIdOportunidad = component.get('c.getIdOportunidad');
		getIdOportunidad.setParam('idLlamada', component.get('v.recordId'));
		getIdOportunidad.setCallback(this, response => {
			if (response.getState() === 'SUCCESS') {
				component.set('v.idOportunidad', response.getReturnValue());
			} else {
				console.error('Error recuperando la oportunidad vinculada a la llamada');
				console.error(getIdOportunidad.getError());
			}
			component.set('v.cargando', false);
		});
		$A.enqueueAction(getIdOportunidad);
	},

	abrirDetalleOportunidad: function(component) {
		if (component.get('v.idOportunidad')) {
			let navEvt = $A.get('e.force:navigateToSObject');
			navEvt.setParams({'recordId': component.get('v.idOportunidad')});
			navEvt.fire();
		}
	}
});