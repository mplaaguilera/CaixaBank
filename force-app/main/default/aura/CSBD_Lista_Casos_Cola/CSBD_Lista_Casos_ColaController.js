({
	init: function(component) {
		//Casos 3N
		const isMemberQueue = component.get('c.checkIsMember');
		isMemberQueue.setCallback(this, response => {
			if (response.getState() === 'SUCCESS') {
				const esMiembroCola3n = response.getReturnValue().esMiembroCola3n;
				component.set('v.esMiembroCola3n', esMiembroCola3n);
				component.set('v.esAdmin', response.getReturnValue().esAdmin);
				component.set('v.resaltar', !response.getReturnValue().esAdmin);

				if (esMiembroCola3n) {
					$A.enqueueAction(component.get('c.getCasos'));
					//eslint-disable-next-line @lwc/lwc/no-async-operation
					window.setInterval($A.getCallback(() => $A.enqueueAction(component.get('c.getCasos'))), 240000);
				}
			}
		});
		window.setTimeout($A.getCallback(() => $A.enqueueAction(isMemberQueue)), 10000);
	},


	getCasosSinCache: function(component, event, helper) {
		helper.getCasos(component, true);
	},

	getCasos: function(component, event, helper) {
		helper.getCasos(component, false);
	},

	navegarListview: function(component, event, helper) {
		if (component.get('v.idListviewCasos3n')) {
			helper.navigateToList(component, component.get('v.idListviewCasos3n'));
		} else {
			const getListviewCasos3nIdApex = component.get('c.getListviewCasos3nId');
			getListviewCasos3nIdApex.setCallback(this, response => {
				if (response.getState() === 'SUCCESS' && response.getReturnValue()) {
					component.set('v.idListviewCasos3n', response.getReturnValue());
					$A.enqueueAction(component.get('c.navegarListview'));
				}
			});
			$A.enqueueAction(getListviewCasos3nIdApex);
		}
	}
});