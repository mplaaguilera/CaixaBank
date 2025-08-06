({
	doInit: function(component) {
		let action = component.get('c.getCasos');
		action.setParam('recordId', component.get('v.recordId'));
		action.setCallback(this, response => {
			if (response.getState() === 'SUCCESS') {
				component.set('v.casos', response.getReturnValue());
			}
		});
		$A.enqueueAction(action);
	},

	handleClick: function(component, event) {
		let index = event.getSource().get('v.name');
		let casos = component.get('v.casos');
		let workspaceAPI = component.find('workspace');
		workspaceAPI.openSubtab({
			parentTabId: workspaceAPI.getEnclosingTabId(),
			url: '/lightning/r/Case/' + casos[index].Id + '/view',
			focus: true
		});
	}
});