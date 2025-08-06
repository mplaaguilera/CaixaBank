({
	handleRellenarMail: function(component, event) {
		let args = {
			'actionName': 'Case.GRR_Enviar_Correo',
			'targetFields': {
				'ToAddress': {'value': event.getParam('para')},
				'CcAddress': {'value': event.getParam('cc')},
				'CC_Grupo_Colab__c': {'value': event.getParam('grupo')},
				'CC_Procedencia__c': {'value': event.getParam('operativa')}, //'Traslado Colaborador'},
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