({
	init: function(component) {
		let esResponsableApex = component.get('c.esResponsable');
		esResponsableApex.setCallback(this, responseEsResponsable => {
			if (responseEsResponsable.getState() === 'SUCCESS') {
				let esResponsable = responseEsResponsable.getReturnValue();
				let getListviewsApex = component.get('c.getListviews');
				getListviewsApex.setParam('filtroDevName', esResponsable ? 'CSBD_Oportunidades_StageName_Kanban' : 'CSBD_Mis_Oportunidades_StageName_Kanban');
				getListviewsApex.setCallback(this, responseGetListviews => {
					if (responseGetListviews.getState() === 'SUCCESS') {
						component.set('v.listViews', responseGetListviews.getReturnValue());
					}
				});
				$A.enqueueAction(getListviewsApex);
			}
		});
		$A.enqueueAction(esResponsableApex);
	},

	navegar: function(component, event) {
		let navEvent = $A.get('e.force:navigateToList');
		navEvent.setParams({
			'listViewId': event.getSource().get('v.name'),
			'listViewName': null,
			'scope': 'Opportunity'
		});
		navEvent.fire();
	}
});