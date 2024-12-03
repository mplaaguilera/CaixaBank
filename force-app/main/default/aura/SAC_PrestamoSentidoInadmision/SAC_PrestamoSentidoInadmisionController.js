({
    motivoInad: function (cmp, event) {
        cmp.set('v.motivoInad', event.getParam("value"));
    },
    guardarResolucion: function (component, event){
        component.set('v.isLoading', !component.get('v.isLoading'));
        var idCase = component.get("v.recordId");
        var sentido = component.get('v.senRes');
        var argumento = component.get('v.argRes');
        var motivoInadmision = component.get('v.motivoInad');
        var action = component.get("c.guardarResolucionApex");        
        action.setParams({'id': idCase, 'sentido': sentido, 'argumento': argumento, 'motivoInad': motivoInadmision});
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var cmpEvent = component.getEvent("cmpEmail");
                cmpEvent.setParams({
                    "showEmailSender" : true}); 
                cmpEvent.fire();
                let toastParams = {
					title: "Acción completada",
					message: 'Se han actualizado los detalles de la reclamación.', 
					type: "success"
				};
				let toastEvent = $A.get("e.force:showToast");
    			toastEvent.setParams(toastParams);
                toastEvent.fire();
                component.set('v.isLoading', !component.get('v.isLoading'));
            }
            else{
                var errors = response.getError();
                let toastParams = {
                    title: "Error",
                    message: errors[0].message, 
                    type: "error"
                };
                let toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams(toastParams);
                toastEvent.fire();
                component.set('v.isLoading', !component.get('v.isLoading'));
            }

        });
        $A.enqueueAction(action);
    },
    argumentoRes: function (cmp, event) {
        cmp.set('v.argRes', event.getParam("value"));
    }
})