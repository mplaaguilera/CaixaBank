({
    mostrarToast: function(tipo, titulo, mensaje) {
		let toastEvent = $A.get('e.force:showToast');
		toastEvent.setParams({'type': tipo, 'title': titulo, 'message': mensaje});
		toastEvent.fire();
	}
})