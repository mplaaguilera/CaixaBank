({
    doInit : function(component, event, helper) {
       
    },

    onDerivarInteraccionChannel: function(component, message, helper) {

		let datosAdicionales = message.getParam("datosAdicionales");
		let origen = message.getParam("origen");
		let destino = message.getParam("destino");		
		let recordId = message.getParam("recordId");

		let recordLocalId = component.get("v.recordId");
		//solo  proceso si el evento fue lanzado con el record en cuestion 
		if(recordId == recordLocalId){
			if(destino == "derivarPopup" && origen == "otp") {		
				//abrir modal de derivar
				component.set('v.mostrarDerivar', true);
				component.set('v.otpDerivar', true);
				$A.util.removeClass(component.find('derivarPopup'), 'slds-hidden');          
			}
		}
	},

	handleCerrarModalDerivar : function(component, event, helper) {
		component.set('v.mostrarDerivar', false);	
		$A.util.addClass(component.find('derivarPopup'), 'slds-hidden');
	}

   
})