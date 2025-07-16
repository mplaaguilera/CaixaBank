({
	doInit: function(component) {
		let action = component.get('c.inadmitirButtonVisibleOrHidden');
		action.setParams({
			recId: component.get('v.recordId'),
			cumpleCriterio: component.get('v.cumpleCriterio')
		});
		action.setCallback(this, response => {
			if (response.getState() === 'SUCCESS') {
				if (response.getReturnValue()) {
					component.set('v.showButton', true);
				}
			} else {
				let errors = response.getError();
				console.error('Error al obtener el valor de la inadmitirButtonVisibleOrHidden', errors);
				let toastEvent = $A.get('e.force:showToast');
				toastEvent.setParams({title: 'Error', message: errors[0].message, type: 'error'});
				toastEvent.fire();
			}
		});
		$A.enqueueAction(action);
	},

	openComponent: function(component) {
		component.set('v.showComponent', !component.get('v.showComponent'));
	},

	handleApplicationEvent: function(component, event) {
		component.set('v.showComponent', event.getParam('showComponente'));
		component.set('v.showButton', event.getParam('showButton'));
	}
});