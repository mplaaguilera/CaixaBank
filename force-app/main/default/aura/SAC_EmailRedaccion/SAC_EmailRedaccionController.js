({
    doInit : function(component, event, helper) {
        //obtener info 
        var action = component.get('c.obtenerDatosEmail');
        action.setParams({'idCaso': component.get("v.recordId")});

        action.setCallback(this, function(response) {
			var state = response.getState();
            if (state === "SUCCESS") {
                var wrapper = response.getReturnValue();

                component.set('v.para', wrapper.para );
                component.set('v.asunto', wrapper.asunto);
                component.set('v.cuerpo', wrapper.cuerpo);
                component.set('v.copia', wrapper.copia);

                component.set('v.caso', wrapper.caso);

                component.set('v.ficherosAdjuntos', wrapper.adjuntos);
            }
            else{
                var errors = response.getError();
                let toastParams = {
                    title: "Error",
                    message: errors[0].pageErrors[0].message, 
                    type: "error"
                };
                let toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams(toastParams);
                toastEvent.fire();
            }
        })

        $A.enqueueAction(action);
        
    },

    handleApplicationEvent : function(component, event, helper) {
        component.set('v.checkActivado', event.getParam("checkboxRedaccion") );
        component.set('v.procedencia', event.getParam("procedencia") );
    }
})