({
	doInit: function(component) {
		let checkPrestamosAction = component.get('c.checkPrestamos');
		checkPrestamosAction.setParam('recId', component.get('v.recordId'));
		checkPrestamosAction.setCallback(this, response => {
			let state = response.getState();
			if (state === 'SUCCESS') {
				component.set('v.hayPrestamos', Boolean(response.getReturnValue()));
			} else {
				console.error('Error al obtener los préstamos', response.getError());
			}
		});
		$A.enqueueAction(checkPrestamosAction);
	},

	handleValidationCheck: function(component, event) {
		component.set('v.cumpleCriterio', event.getParam('hasValidation'));
		component.set('v.spinner', false);
	}
});