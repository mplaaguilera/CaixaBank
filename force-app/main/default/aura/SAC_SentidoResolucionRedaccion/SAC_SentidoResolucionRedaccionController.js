({
    argumentoRes: function (cmp, event) {
        cmp.set('v.argRes', event.getParam("value"));
    },

    sentidoRes: function (cmp, event) {
        cmp.set('v.senRes', event.getParam("value"));
        var sentido = cmp.get('v.senRes');
        if(sentido == "SAC_004"){
            cmp.set('v.esInadmision', true);
        }else{
            cmp.set('v.esInadmision', false);

        }
    },
    motivoInad: function (cmp, event) {
        cmp.set('v.motInad', event.getParam("value"));
    },

    guardarResolucion: function (component, event){
        component.set('v.isLoading', !component.get('v.isLoading'));
        var idCase = component.get("v.recordId");
        var sentido = component.get('v.senRes');
        var argumento = component.get('v.argRes');
        var motivoInadmision = component.get('v.motInad');
        if (motivoInadmision == null && sentido == 'SAC_004') {
            let toastParams = {
                title: "Motivo inadmisión",
                message: 'El campo motivo inadmisión está vacío.',
                type: "warning"
            };
            let toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams(toastParams);
            toastEvent.fire();
            component.set('v.isLoading', !component.get('v.isLoading'));
            return;
        }
        var action = component.get("c.guardarResolucionApex");        
        var procedencia = component.get("v.procedencia");
        action.setParams({'id': idCase, 'sentido': sentido, 'argumento': argumento, 'motivoInad': motivoInadmision});
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {

                var appEvent = $A.get("e.c:SAC_PertimiteEmailRedaccion");
                appEvent.setParams({
                    "etapa1" : true,
                    "etapa2" : true,
                    "etapa3" : true, 
                    "checkboxRedaccion" : false,
                    "procedencia" : procedencia});
                appEvent.fire();
                
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
    }
})