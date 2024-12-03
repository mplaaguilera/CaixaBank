({
	openSubtabCaso: function(component, idCaso) {
		let workspaceAPI = component.find('workspace');
		component.find('workspace').openSubtab({parentTabId: workspaceAPI.getEnclosingTabId(), url: '/lightning/r/Case/' + idCaso + '/view', focus: true});
	},

	mostrarToast: function(tipo, titulo, mensaje) {
		let toastEvent = $A.get('e.force:showToast');
		toastEvent.setParams({title: titulo, message: mensaje, type: tipo, mode: 'dismissable', duration: 4000});
		toastEvent.fire();
	},
});