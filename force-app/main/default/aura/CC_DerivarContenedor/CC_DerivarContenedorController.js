({
    onDerivarInteraccionChannel: function(component, message) {
		//solo  proceso si el evento fue lanzado con el record en cuestion
		if (message.getParam("origen") === "otp" && message.getParam("destino") === "derivarPopup"
		&& message.getParam("recordId") === component.get("v.recordId")) {
			component.set('v.mostrarDerivar', true);
			$A.util.removeClass(component.find('lwcDerivar'), 'slds-hide');
		}
	},

	handleCerrarModalDerivar : function(component) {
		component.set('v.mostrarDerivar', false);
		$A.util.addClass(component.find('lwcDerivar'), 'slds-hide');
	}
})