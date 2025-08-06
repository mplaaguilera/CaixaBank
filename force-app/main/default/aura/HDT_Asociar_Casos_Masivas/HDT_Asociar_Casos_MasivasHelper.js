({
	verCaso: function(idCaso) {
		let navEvt = $A.get('e.force:navigateToSObject');
		navEvt.setParams({'recordId': idCaso});
		navEvt.fire();
	},

	mostrarToast: function(tipo, titulo, mensaje) {
		let toastEvent = $A.get('e.force:showToast');
		toastEvent.setParams({'title': titulo, 'message': mensaje, 'type': tipo, 'mode': 'dismissable', 'duration': 4000});
		toastEvent.fire();
	}
});