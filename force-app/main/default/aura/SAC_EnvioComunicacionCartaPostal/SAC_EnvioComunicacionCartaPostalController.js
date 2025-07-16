({
    init : function(component, event, helper) {
        let getInfo = component.get('c.getInfoPostal');
        getInfo.setParams({'caseId': component.get("v.recordId")});
        getInfo.setCallback(this, function(response) {
			let state = response.getState();
            if (state === "SUCCESS") {
                let respuesta = response.getReturnValue();
            //    console.log(JSON.stringify(respuesta));
                component.set('v.nombreTitularEC', respuesta.nombreTitular);
                component.set('v.direccionEC', respuesta.direccionEnvio);
            //    console.log(component.get("v.direccionEnvio"));
                component.set('v.poblacionEC', respuesta.poblacion);
                component.set('v.codigoPostalEC', respuesta.codigoPostal);
                component.set('v.provinciaEC', respuesta.provincia);
                component.set('v.paisEC', respuesta.pais);
                component.set('v.cuerpoEC', respuesta.cuerpo);
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
    },

    generarDoc : function(component, event, helper) {
        
        component.set('v.isLoading', true);
        let guardarDocumento = component.get('c.envioCarta');
        guardarDocumento.setParams({'record': component.get('v.recordId')});
        console.log('record ' + component.get('v.recordId'));
        guardarDocumento.setCallback(this, function(response) {
			let state = response.getState();
            if (state === "SUCCESS") {
                component.set('v.isLoading', false);
                component.set('v.modalParaProrrogar', false);
                let toastParams = {
                    title: "Carta enviada",
                    message: 'La carta ha sido enviada, debe refrescar la página.', 
                    type: "success"
                };
                let toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams(toastParams);
                toastEvent.fire();
            }
            else{
                component.set('v.isLoading', false);
                $A.get('e.force:refreshView').fire();

                let errors = response.getError();
                console.log(errors);
                let toastParams = {
                    title: "Error",
                    message: 'Debe refrescar la página, no se ha realizado ningún envío.', 
                    type: "error"
                };
                let toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams(toastParams);
                toastEvent.fire();
                
            }
        });
        
        $A.enqueueAction(guardarDocumento);
    },

    generarDocProrroga : function(component, event, helper) {
        
        component.set('v.isLoading', true);
        let guardarDocumento = component.get('c.envioCartaProrroga');
        guardarDocumento.setParams({'record': component.get('v.recordId')});
        guardarDocumento.setCallback(this, function(response) {
			let state = response.getState();
            if (state === "SUCCESS") {
                component.set('v.isLoading', false);
                component.set('v.modalParaProrrogar', false);
                let toastParams = {
                    title: "Carta enviada",
                    message: 'La carta ha sido enviada, debe refrescar la página.', 
                    type: "success"
                };
                let toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams(toastParams);
                toastEvent.fire();

                let navService = component.find("navService");
                var pageReference = {
                    type: 'standard__recordPage',
                    attributes: {
                        objectApiName: 'SAC_Accion__c',
                        actionName: 'view',
                        recordId: response.getReturnValue()
                    },
                };
                navService.navigate(pageReference);
            }
            else{
                component.set('v.isLoading', false);
                $A.get('e.force:refreshView').fire();

                let errors = response.getError();
                console.log(errors);
                let toastParams = {
                    title: "Error",
                    message: 'Debe refrescar la página, no se ha realizado ningún envío.', 
                    type: "error"
                };
                let toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams(toastParams);
                toastEvent.fire();
                
            }
        });
        
        $A.enqueueAction(guardarDocumento);
    }


})