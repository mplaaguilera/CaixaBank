({
	getCasos: function(component, sinCache) {
		const casos3nApex = component.get('c.casos3n');
		casos3nApex.setParam('sinCache', sinCache);
		casos3nApex.setCallback(this, response => {
			if (response.getState() === 'SUCCESS') {
				const casos = response.getReturnValue();
				const utilityBarApi = component.find('utilityBarApi');
				utilityBarApi.setUtilityLabel({label: 'Casos 3N' + (casos.length ? ': ' + casos.length : '')});
				utilityBarApi.setUtilityHighlighted({highlighted: component.get('v.resaltar') && Boolean(casos.length)});
				component.set('v.casos', casos);
				component.set('v.fechaActualizacion', $A.localizationService.formatDateTime(new Date(), 'H:mm'));
			}
		});
		$A.enqueueAction(casos3nApex);
		const botonRefrescar = component.find('botonRefrescar');
		$A.util.addClass(botonRefrescar, 'rotar');
		//eslint-disable-next-line @lwc/lwc/no-async-operation
		window.setTimeout(() => $A.util.removeClass(botonRefrescar, 'rotar'), 470);
	},

	navigateToList: function(component, idListview) {
		const navEvent = $A.get('e.force:navigateToList');
		navEvent.setParams({listViewId: idListview, listViewName: null, scope: 'Case'});
		navEvent.fire();

		component.find('utilityBarApi').minimizeUtility();
	}
});