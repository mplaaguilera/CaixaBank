({
	mostrarToast: function(tipo, mensaje, modo) {
		let toastEvent = $A.get('e.force:showToast');
        toastEvent.setParams({'message': mensaje, 'type': tipo, 'mode': modo});
		toastEvent.fire();
	},
    consultaExcepciones: function(component, helper , tipo) {
		let excepciones = component.get('c.getExcepcionesCase');
        excepciones.setParams({"CaseId": component.get('v.recordId'), "Tipo": tipo});
        console.log(excepciones);

		excepciones.setCallback(this, response => {
			let state = response.getState();
            console.log(response);
			if (state === 'SUCCESS') {
            	var lstTexto = response.getReturnValue();

                for(var i = 0; i < lstTexto.length; i++){
            		helper.mostrarToast('info', lstTexto[i], 'sticky');
                }            
			}
		});
		$A.enqueueAction(excepciones);
    }
})