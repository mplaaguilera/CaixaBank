({
	doInit: function(component) {
		let action = component.get('c.auraGestionMaximo');
		action.setParams({
            oID: component.get('v.recordId')
        });
		action.setCallback(this, response => {
			if (response.getState() === 'SUCCESS') {
				let sRetorno = response.getReturnValue();
				if (sRetorno) {
					component.set('v.sMensaje', sRetorno);
				} else {
					component.set('v.sMensaje', 'Datos enviados correctamente!');
					component.set('v.bError', false);
				}
			} else {
				component.set('v.sMensaje', 'Los datos no se han enviado correctamente. Vuelva a intentarlo, si el problema persiste contacte con el administrador de la aplicación.');
			}
			component.set('v.bWebServ', true);
			component.set('v.bEspera', false);
			$A.get('e.force:refreshView').fire();
		});
		$A.enqueueAction(action);
	},

	cerrarDialogo: function(component, event, helper) {
		$A.get('e.force:closeQuickAction').fire();
	}
});