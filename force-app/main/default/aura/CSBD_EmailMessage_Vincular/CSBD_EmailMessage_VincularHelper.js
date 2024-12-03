({
	mostrarToast: function(titulo, mensaje, tipo) {
		let toastEvent = $A.get('e.force:showToast');
		toastEvent.setParams({title: titulo, message: mensaje, type: tipo, mode: 'dismissable', duration: '4000'});
		toastEvent.fire();
	}
});