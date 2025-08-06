({   
    doInit : function(component, event, helper) {
    var action = component.get('c.obtenerDatosEmail');
    var idCase = component.get('v.recordId');
    action.setParams({'idCaso':component.get('v.recordId')});
    action.setCallback(this, function(response) {
        var state = response.getState();
        
        if(state === 'SUCCESS'){
            
            var wrapper = response.getReturnValue();
            component.set('v.para', wrapper.para );
            component.set('v.asunto', wrapper.asunto);
            component.set('v.copiaOculta', wrapper.copiaOculta);
            component.set('v.copia', wrapper.copia);
            component.set('v.cuerpo', wrapper.cuerpo);
            component.set('v.caso', wrapper.caso);
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
            $A.get('e.force:refreshView').fire();
        }
    })

    $A.enqueueAction(action);
},

    reenviarRedaccion : function(component, event, helper) {
        component.set("v.confirmarOperacion", false);
        component.set('v.isLoading', true);
        let idsFicherosAdjuntos = component.get("v.idsFicherosAdjuntos");   
        
        helper.cargarTagsImgCuerpo(component, false);

        var action = component.get("c.reenviarRedaccionEmail");
        action.setParams({'idCaso':component.get("v.recordId"), "newPara": component.get("v.para"),  "newCopia": component.get("v.copia"), "newCopiaOculta": component.get("v.copiaOculta"), "newAsunto": component.get("v.asunto"), 'idsAdjuntos': JSON.stringify(idsFicherosAdjuntos), "newCuerpo": component.get("v.cuerpo")});
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
    cambiaPara : function(component, event, helper) {
        component.set('v.para', event.getParam("value"));
    },

    cambiaCopia : function(component, event, helper) {
        component.set('v.copia', event.getParam("value"));
    },

    cambiaCopiaOculta : function(component, event, helper) {
        component.set('v.copiaOculta', event.getParam("value"));
    },

    cambiaAsunto : function(component, event, helper) {
        component.set('v.asunto', event.getParam("value"));
    },

    receiveLWCDataDocumento: function (cmp, event, helper) {
		cmp.set("v.archivoSubido", event.getParam("dataToSend"));
        eval("$A.get('e.force:refreshView').fire();");
	},

    abrirConfirmarOperacion : function(component, event, helper) {   
        
        helper.cargarTagsImgCuerpo(component, true); 

        if(component.get('v.todasImgConTag')){
            component.set("v.editarReenvio", false);
            component.set("v.confirmarOperacion", true);
        }else{
            component.set('v.todasImgConTag', true);

            let toastParams = {
                title: "Advertencia!",
                message: 'Todas las imágenes enviadas deben tener una descripción informada. Revíselas con el botón "Modificar descripción imágenes"',  
                type: "warning"
            };
            let toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams(toastParams);
            toastEvent.fire();
        }
	},

    cerrarConfirmarOperacion : function(component, event, helper) {      	
		component.set("v.confirmarOperacion", false);
	},

    abrirEditarReenvio : function(component, event, helper) {      	
		component.set("v.editarReenvio", true);
	},

    cerrarEditarReenvio : function(component, event, helper) {      	
		component.set("v.editarReenvio", false);
	}
})