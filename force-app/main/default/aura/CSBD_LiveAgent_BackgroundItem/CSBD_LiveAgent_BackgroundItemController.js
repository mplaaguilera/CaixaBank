({
	onCloseWork: function(component, event, helper) {
		//Cerrar trabajos
		const omniToolkit = component.find('omniToolkit');
		omniToolkit.getAgentWorks()
		.then(agentWorks => {
			JSON.parse(agentWorks.works)
			.filter(work => work.workItemId.substring(0, 15) === event.getParam('recordId').substring(0, 15))
			.forEach(work => omniToolkit.closeAgentWork({workId: work.workId}));
		});

		//Modificar oportunidad
		helper.callApex(component, 'onCloseChatEvent', {recordId: event.getParam('recordId')})
		.catch(error => console.error('CSBD_LiveAgent_BackgroundController ERROR: ' + JSON.stringify(error, null, 3)));
	}
});