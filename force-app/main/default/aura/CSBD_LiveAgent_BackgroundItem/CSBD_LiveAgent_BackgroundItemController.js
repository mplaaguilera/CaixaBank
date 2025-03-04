({
	onCloseWork: function(component, event, helper) {
		//Cerrar trabajos
		const omniToolkit = component.find('omniToolkit');
		omniToolkit.getAgentWorks().then(result => {
			const recordIdAux = event.getParam('recordId').substring(0, 15);
			JSON.parse(result.works)
			.filter(work => work.workItemId.substring(0, 15) === recordIdAux)
			.forEach(work => omniToolkit.closeAgentWork({workId: work.workId}));
		});

		//Modificar oportunidad
		helper.callApex(component, 'onCloseChatEvent', {recordId: event.getParam('recordId')})
		.catch(error => console.error('CSBD_LiveAgent_BackgroundController ERROR: ' + error));
	}
});