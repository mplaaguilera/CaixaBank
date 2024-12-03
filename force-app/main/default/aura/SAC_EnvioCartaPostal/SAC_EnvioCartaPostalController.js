({
    recuperacionDatosPostales : function(component, event, helper) {
        
        if (event.getParams().changeType === 'LOADED' || event.getParams().changeType === 'CHANGED') {
            let getInfo = component.get('c.getInfoPostal');
            getInfo.setParams({'caseId': component.get("v.recordId")});
            getInfo.setCallback(this, function(response) {
                let state = response.getState();
                if (state === "SUCCESS") {
                    let respuesta = response.getReturnValue();

                    component.set('v.nombreTitular', respuesta.nombreTitular);
                    component.set('v.direccionEnvio', respuesta.direccionEnvio);

                    if(respuesta.nombreTitular != undefined){
                        component.set('v.hayContacto', true);
                        if(respuesta.direccionEnvio != undefined){
                            component.set('v.hayDireccion', true);
                        }
                    }

                    component.set('v.poblacionEC', respuesta.poblacion);
                    component.set('v.codigoPostalEC', respuesta.codigoPostal);
                    component.set('v.provinciaEC', respuesta.provincia);
                    component.set('v.paisEC', respuesta.pais);
                    component.set('v.cuerpoCliente', respuesta.cuerpo);
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
            });
            $A.enqueueAction(getInfo);
        }
    }
})