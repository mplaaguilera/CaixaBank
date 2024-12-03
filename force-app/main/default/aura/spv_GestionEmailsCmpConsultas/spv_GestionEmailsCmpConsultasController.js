({
    inicio : function(component, event, helper) {

        let obtenerInformacion = component.get('c.obtenerInformacion');
        obtenerInformacion.setParams({'record': component.get('v.recordId')})
        obtenerInformacion.setCallback(this, function(response) {
			let state = response.getState();
            if (state === "SUCCESS") {
                let respuesta = response.getReturnValue();
                component.set('v.paraGrupo', respuesta.paraEmail);
                component.set('v.asuntoGrupo', respuesta.asuntoEmail);
                component.set('v.cuerpoGrupo', respuesta.cuerpoEmail);
                // component.set('v.paraGrupo', respuesta.paraEmail);
                component.set('v.casoRelacionado', respuesta.casoRelacionado);
                component.set('v.noEsOficinas', respuesta.noEsOficinas);
                component.set('v.consulta', respuesta.consulta);
            }
            else{
                let errors = response.getError();
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

        setTimeout(function(){ 
            $A.enqueueAction(obtenerInformacion);
        }, 1000);
    }
})