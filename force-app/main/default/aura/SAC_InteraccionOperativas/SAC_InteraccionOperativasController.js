({
    init : function(component, event, helper) {
        
        var mostrarBoton = component.get('c.mostrarBoton');
        mostrarBoton.setParams({
            'interaccionId':component.get('v.recordId'),
            'idUser': $A.get('$SObjectType.CurrentUser.Id') 
        });

        mostrarBoton.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set('v.mostrarBoton', response.getReturnValue().mostrarBoton);
                component.set('v.interaccion', response.getReturnValue().interaccion);
            }
        });     
        $A.enqueueAction(mostrarBoton); 

        var mostrarBotonPropiedadConsultas = component.get('c.mostrarBotonPropiedadConsultas');
        mostrarBotonPropiedadConsultas.setParams({
            'interaccionId':component.get('v.recordId')
        });

        mostrarBotonPropiedadConsultas.setCallback(this, function(response){
            var estado = response.getState();
            if(estado == "SUCCESS"){
                component.set('v.mostrarBotonPropiedadConsultas', response.getReturnValue());
            }
        })
        $A.enqueueAction(mostrarBotonPropiedadConsultas);

        var esPropietario = component.get('c.esPropietario');
        esPropietario.setParams({
            'interaccionId':component.get('v.recordId')
        });

        esPropietario.setCallback(this, function(response){
            var estado = response.getState();
            if(estado == "SUCCESS"){
                component.set('v.esPropietario', response.getReturnValue());
            }
        })
        $A.enqueueAction(esPropietario); 

        var esConsulta = component.get('c.esConsulta');
        esConsulta.setParams({
            'interaccionId':component.get('v.recordId')
        });

        esConsulta.setCallback(this, function(response){
            var estado = response.getState();
            if(estado == "SUCCESS"){
                component.set('v.esConsulta', response.getReturnValue());
            }
        })
        $A.enqueueAction(esConsulta);
    },

    tomarPropiedad : function(component, event, helper) {

        var tomarEnPropiedad = component.get('c.tomarPropiedadInteraccion');
        tomarEnPropiedad.setParams({
            'interaccionId':component.get('v.recordId'),
            'idUser':$A.get('$SObjectType.CurrentUser.Id')
        });

        tomarEnPropiedad.setCallback(this, function(response){
            var estado = response.getState();
            if(estado == "SUCCESS"){
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Éxito!",
                    "message": "Se ha cambiado el propietario correctamente.",
                    "type": "success"
                });
                toastEvent.fire(); 
                component.set('v.mostrarBoton',false);
                $A.get('e.force:refreshView').fire(); 
            } else {
                var errors = response.getError();
                var errorMessage = "No se pudo tomar en propiedad.";
    
                // Verifica si hay errores y obtén el mensaje de error si está disponible
                if (errors && Array.isArray(errors) && errors.length > 0 && errors[0] && errors[0].message) {
                    errorMessage = errors[0].message;
                }
    
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Error",
                    "message": errorMessage,
                    "type": "error"
                });
                toastEvent.fire();
            }
        })

        $A.enqueueAction(tomarEnPropiedad); 
    },

    devolver : function(component) {

        var devolverLaInteraccion = component.get('c.devolverInteraccion');
        devolverLaInteraccion.setParams({
            'interaccionId':component.get('v.recordId')
        });

        devolverLaInteraccion.setCallback(this, function(response){
            var estado = response.getState();
            if(estado == "SUCCESS"){
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Éxito!",
                    "message": "Se ha devuelto el registro correctamente.",
                    "type": "success"
                });
                toastEvent.fire(); 
                component.set('v.esPropietario',false);
                $A.get('e.force:refreshView').fire(); 
            } else {
                var errors = response.getError();
                var errorMessage = "No se pudo devolver.";
    
                // Verifica si hay errores y obtén el mensaje de error si está disponible
                if (errors && Array.isArray(errors) && errors.length > 0 && errors[0] && errors[0].message) {
                    errorMessage = errors[0].message;
                }
    
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Error",
                    "message": errorMessage,
                    "type": "error"
                });
                toastEvent.fire();
            }
        })
        $A.enqueueAction(devolverLaInteraccion); 
    },

    volverEscalar : function(component) {
        var volverEscalar = component.get('c.volverAEscalar');
        let propuesta = component.get('v.propuestaLetrado');
        volverEscalar.setParams({
            'interaccionId':component.get('v.recordId'),
            'propuestaLet':propuesta
        });

        volverEscalar.setCallback(this, function(response){
            var estado = response.getState();
            if(estado == "SUCCESS"){
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Éxito!",
                    "message": "Se ha vuelto a escalar correctamente.",
                    "type": "success"
                });
                toastEvent.fire(); 
                component.set('v.esPropietario',false);
                $A.get('e.force:refreshView').fire(); 
            } else {
                var errors = response.getError();
                var errorMessage = "No se pudo volver a escalar. Por favor, inténtalo de nuevo.";
    
                // Verifica si hay errores y obtén el mensaje de error si está disponible
                if (errors && Array.isArray(errors) && errors.length > 0 && errors[0] && errors[0].message) {
                    errorMessage = errors[0].message;
                }
    
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Error",
                    "message": errorMessage,
                    "type": "error"
                });
                toastEvent.fire();
            }
        })
        $A.enqueueAction(volverEscalar);
        component.set("v.isModalOpen", false);
    },

    cancelaEscalado : function(component) {
        var cancelarElEscalado = component.get('c.cancelarEscalado');
        cancelarElEscalado.setParams({
            'interaccionId':component.get('v.recordId')
        });

        cancelarElEscalado.setCallback(this, function(response){
            var estado = response.getState();
            if(estado == "SUCCESS"){
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Éxito!",
                    "message": "Se ha cancelado el escalado.",
                    "type": "success"
                });
                toastEvent.fire(); 
                component.set('v.esPropietario',false);
                $A.get('e.force:refreshView').fire(); 
            } else {
                var errors = response.getError();
                var errorMessage = "No se pudo cancelar.";
    
                // Verifica si hay errores y obtén el mensaje de error si está disponible
                if (errors && Array.isArray(errors) && errors.length > 0 && errors[0] && errors[0].message) {
                    errorMessage = errors[0].message;
                }
    
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Error",
                    "message": errorMessage,
                    "type": "error"
                });
                toastEvent.fire();
            }
        })
        $A.enqueueAction(cancelarElEscalado); 
    },

    openModal: function(component, event, helper) {
        component.set("v.isModalOpen", true);
    },

    closeModal: function(component, event, helper) {
        component.set("v.isModalOpen", false);
    },

    marcaPendienteRespuestaDefinitiva : function(component) {
        var pendienteRespuestaDefinitiva = component.get('c.marcarPendienteRespuestaDefinitiva');
        pendienteRespuestaDefinitiva.setParams({
            'interaccionId':component.get('v.recordId')
        });

        pendienteRespuestaDefinitiva.setCallback(this, function(response){
            var estado = response.getState();
            if(estado == "SUCCESS"){
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Éxito!",
                    "message": "Se ha marcado la consulta como pendiente de respuesta definitiva.",
                    "type": "success"
                });
                toastEvent.fire(); 
                $A.get('e.force:refreshView').fire(); 
            } else {
                var errors = response.getError();
                var errorMessage = "No se pudo marcar la consulta como pendiente de respuesta definitiva.";
    
                // Verifica si hay errores y obtén el mensaje de error si está disponible
                if (errors && Array.isArray(errors) && errors.length > 0 && errors[0] && errors[0].message) {
                    errorMessage = errors[0].message;
                }
    
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Error",
                    "message": errorMessage,
                    "type": "error"
                });
                toastEvent.fire();
            }
        })
        $A.enqueueAction(pendienteRespuestaDefinitiva); 
    }
})