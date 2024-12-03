({
	openSubtabCuenta: function(component, focus) {
		let workspaceAPI = component.find('workspace');
		workspaceAPI.openSubtab({
			'parentTabId': workspaceAPI.getEnclosingTabId(),
			'url': '/lightning/r/Account/' + component.get('v.cuentaId') + '/view',
			'focus': focus
		});
	},

	openSubtabContacto: function(component, focus) {
		let workspaceAPI = component.find('workspace');
		workspaceAPI.openSubtab({
			'parentTabId': workspaceAPI.getEnclosingTabId(),
			'url': '/lightning/r/Contact/' + component.get('v.contactoId') + '/view',
			'focus': focus
		});
	},

	mostrarToast: function(tipo, titulo, mensaje) {
		let toastEvent = $A.get('e.force:showToast');
		toastEvent.setParams({'title': titulo, 'message': mensaje, 'type': tipo, 'mode': 'dismissible', 'duration': 4000});
		toastEvent.fire();
	}
});