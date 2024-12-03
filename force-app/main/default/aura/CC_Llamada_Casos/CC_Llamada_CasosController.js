({
	doInit: function(component) {
		let action = component.get('c.getCasos');
		action.setParam('recordId', component.get('v.recordId'));
		action.setCallback(this, response => {
			if (response.getState() === 'SUCCESS') {
				component.set('v.casos', response.getReturnValue());
			}
		});
		//eslint-disable-next-line @lwc/lwc/no-async-operation
		setTimeout(() => $A.enqueueAction(action), 100);
	},

	handleClick: function(component, event) {
		let workspaceAPI = component.find('workspace');
		workspaceAPI.openSubtab({
			parentTabId: workspaceAPI.getEnclosingTabId(),
			url: '/lightning/r/Case/' + component.get('v.casos')[event.getSource().get('v.name')].Id + '/view',
			focus: true
		});
	},

	agregarCaso: function(component, event) {
		let listaCasos = component.get('v.casos');
		listaCasos.push(event.getParam('caso'));
		component.set('v.casos', listaCasos);
	}
});