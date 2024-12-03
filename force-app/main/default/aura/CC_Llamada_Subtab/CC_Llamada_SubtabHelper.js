({
	openSubtab: function(component, objectName, recordId) {
		if (recordId) {
			let workspaceAPI = component.find('workspace');
			workspaceAPI.openSubtab({
				parentTabId: workspaceAPI.getEnclosingTabId(),
				url: '/lightning/r/' + objectName + '/' + recordId + '/view',
				focus: false
			}).catch(error => console.error(error));
		}
	}
});