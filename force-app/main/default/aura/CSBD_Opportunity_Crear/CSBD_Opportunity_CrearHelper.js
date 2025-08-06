({
	mostrarToast: function(tipo, titulo, mensaje) {
		let toastEvent = $A.get('e.force:showToast');
		toastEvent.setParams({type: tipo, title: titulo, message: mensaje});
		toastEvent.fire();
	},

	minimizarPanel: function(component) {
		let utilityAPI = component.find('utilitybar');
		utilityAPI.getUtilityInfo().then(response => {
			if (response.utilityVisible) {
				utilityAPI.minimizeUtility();
			}
		}).catch(error => console.error(error));
	},

	abrirTab: function(component, recordId) {
		component.find('workspace').openTab({recordId, focus: true});
	}
});