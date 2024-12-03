({
    reenviarRedaccion : function(component, event, helper) { 
        component.set("v.confirmarOperacion", false);
        component.set('v.isLoading', true);
        var action = component.get("c.reenvioRedaccionCartaPostal");
        console.log('Carta postal');
        action.setParams({'idCaso':component.get("v.recordId")});
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set('v.isLoading', false);
                $A.get('e.force:refreshView').fire(); 

                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Éxito!",
                    "message": "Se ha reenviado la redacción correctamente.",
                    "type": "success"
                });
                toastEvent.fire();
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
    abrirConfirmarOperacion :function(component, event, helper) {
        component.set('v.confirmarOperacion', true);
    },
    cerrarConfirmarOperacion :function(component, event, helper) {
        component.set('v.confirmarOperacion', false);
    }

})