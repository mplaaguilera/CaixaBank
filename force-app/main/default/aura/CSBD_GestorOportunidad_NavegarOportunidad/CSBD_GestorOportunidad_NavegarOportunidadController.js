({
	navegarOportunidad: function(component, event) {
		if (event.getParams().changeType === 'LOADED') {
			const workspaceAPI = component.find('workspace');
			workspaceAPI.openTab({recordId: component.get('v.gestorOportunidad.CSBD_Oportunidad__c'), focus: true})
			.then(response => workspaceAPI.closeTab({tabId: response.tabId}));
		}
	}
});