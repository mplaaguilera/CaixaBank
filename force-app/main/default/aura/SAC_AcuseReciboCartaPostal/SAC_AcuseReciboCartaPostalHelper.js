({
    envioAcuseEmailAuto : function(component, event, helper) {
		component.set('v.isLoading', true);
        component.set("v.envioAcusePulsado", false);
        let caso = component.get('v.caso');
        let viaEnvio = component.get('v.viaEnvio');

        var envio = component.get("c.envioEmailManual");
        envio.setParams({'casoApex': caso, 'viaEnvio': viaEnvio});
        envio.setCallback(this, function(response) {
            component.set('v.isLoading', false);
            var state = response.getState();
            
            if (state === "SUCCESS") {
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Acuse enviado",
                    "message": 'Se ha enviado la notificación al cliente.',
                    "type": "success"
                });
                component.set('v.envioCartaPostal', false);
                component.set('v.envioEmail', false);
                component.set("v.envioAcusePulsado", false);
                toastEvent.fire();                
                $A.get('e.force:refreshView').fire();
            }
            else{
                var error = response.getError();
                let toastParams = {
                    title: "Error",
                    //message: "El email destino no es válido.", 
                    message: error[0].message, 
                    type: "error"
                };

                let toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams(toastParams);
                toastEvent.fire();
            }
        });
        $A.enqueueAction(envio);
        //component.set('v.envioEmail', false);    
	},
})