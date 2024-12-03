({
	handleRellenarMail: function(component, event) {
		let args = {
			'actionName': 'Case.TMS_Email',
			'targetFields': {
				'ToAddress': {'value': event.getParam('para')},
				'CcAddress': {'value': event.getParam('cc')},
				'BccAddress': {'value': ''}
			}
		};
		component.find('quickActionAPI').setActionFieldValues(args);
	},

	handleCerrarPestana: function(component, event) {
		let workspaceAPI = component.find('workspaceAPI');
		workspaceAPI.getFocusedTabInfo().
			then(response => workspaceAPI.openTab({recordId: event.getParam('idNuevoCaso'), focus: true})
				.then(() => workspaceAPI.closeTab({tabId: response.tabId})));
	}
});