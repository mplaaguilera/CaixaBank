({
    reenviarRedaccion : function(component, event, helper) {
        component.set("v.confirmarOperacion", false);
        component.set('v.isLoading', true);

        var action = component.get("c.reenviarRedaccionEmail");
        action.setParams({'idCaso':component.get("v.recordId")});
        action.setCallback(this, function(response) {
            var state =  response.getState();
            if(state === 'SUCCESS'){
                component.set('v.isLoading', false);

                //US723742 - Raúl Santos - 05/03/2024 - Añadir lógica envio emails blackList. Comprueba si el mensaje es OK es que se ha enviado el email, si es diferente es que hay emails no válidos
                let mensaje = response.getReturnValue();

                if(mensaje === 'OK'){
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "Éxito!",
                        "message": "Se ha reenviado la redacción correctamente.",
                        "type": "success"
                    });
                    toastEvent.fire();
                    $A.get('e.force:refreshView').fire();
                }else if(mensaje !== '' && mensaje !== null && mensaje !== undefined){
                    var toastEventWarning = $A.get("e.force:showToast");
                    toastEventWarning.setParams({
                        "title": "Advertencia!",
                        "message": "No se ha reenviado la redacción. No está permitido el envío de emails a esta dirección: " + mensaje + " de correo electrónico.",
                        "type": "warning",
                        "duration": 8000
                    });
                    toastEventWarning.fire();
                    $A.get('e.force:refreshView').fire();
                }
            }else{
                component.set('v.isLoading', false);

                var errors = response.getError();
                let toastParams = {
                    title: "Error",
                    message: errors[0].message, 
                    type: "error"
                };

                let toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams(toastParams);
                toastEvent.fire();
            }

        });

        $A.enqueueAction(action);

    },

    abrirConfirmarOperacion : function(component, event, helper) {      	
		component.set("v.confirmarOperacion", true);
	},

    cerrarConfirmarOperacion : function(component, event, helper) {      	
		component.set("v.confirmarOperacion", false);
	}
})