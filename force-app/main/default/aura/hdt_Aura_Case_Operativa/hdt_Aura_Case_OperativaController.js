({
	handleRellenarMail: function(component, event) {
		let args = {
			'actionName': 'Case.HDT_Email_Colaborador',
			'targetFields': {
				'ToAddress': {'value': event.getParam('para')},
				'ValidatedFromAddress' : {'value': event.getParam('buzonpordefecto')},
				'CC_Plantilla__c': {'value': event.getParam('plantilla')},
				'CcAddress': {'value': event.getParam('cc')},
				'CC_Grupo_Colab__c': {'value': event.getParam('grupo')},
				'CC_Procedencia__c': {'value': event.getParam('operativa')},
				'BccAddress': {'value': ''}
			}
		};

		component.find('quickActionAPI').setActionFieldValues(args);
		//component.find('quickActionAPI').setActionFieldValues(args);
	},

	handleCerrarPestana: function(component, event) {
		let workspaceAPI = component.find('workspaceAPI');
		workspaceAPI.getFocusedTabInfo().
			then(response => workspaceAPI.openTab({recordId: event.getParam('idNuevoCaso'), focus: true})
				.then(() => workspaceAPI.closeTab({tabId: response.tabId})));
	},

	handleRellenarTrasladar: function(component, event) {
	
		let args = {
			'actionName': 'Case.HDT_Indicencia'
		};
		component.find('quickActionAPI').selectAction(args);
	}
	
});