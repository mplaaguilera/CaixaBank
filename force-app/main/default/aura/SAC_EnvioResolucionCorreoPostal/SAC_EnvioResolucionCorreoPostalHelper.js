({
    finalizar :  function(component, event){
        component.set("v.isLoading", true);
		let id = component.get("v.recordId");
        let idDocumentoRedaccion = component.get("v.idDoc");
        let finalizarRedaccion = component.get("c.finalizarRedaccionCartaPostal");
        finalizarRedaccion.setParams({'caseId' : id, 'para': component.get("v.para"), 'copia': component.get("v.copia"), 'copiaOculta': component.get("v.copiaOculta"), 'cuerpo': component.get("v.cuerpo"), 'asunto': component.get("v.asunto"), 'idAdjuntos': JSON.stringify(idDocumentoRedaccion)});
        component.find('editForm').submit();
        
        finalizarRedaccion.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                let emailsInvalidos = response.getReturnValue();
				component.set("v.isLoading", false);

                //US723742 - Raúl Santos - 05/03/2024 - Añadir lógica envio emails blackList. Comprueba si los emails son válidos. Si no son válidos muestra mensaje informativo
                if(emailsInvalidos !== ''){
                    var toastEventWarning = $A.get("e.force:showToast");
                    toastEventWarning.setParams({
                        "title": "Advertencia!",
                        "message": "No se ha enviado el email correspondiente a la oficina. No está permitido el envío de emails a esta dirección: " + emailsInvalidos + " de correo electrónico.",
                        "type": "warning",
                        "duration": 8000
                    });
                    // $A.util.addClass(spinner, "slds-hide");
                    toastEventWarning.fire(); 
                }

                let toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    'title': 'Redacción finalizada', 
                    'message': 'La reclamación avanza al siguiente estado ejecutando sus acciones pertinentes', 
                    'type': 'success', 
                    'mode': 'dismissable', 
                    'duration': 4000});
                toastEvent.fire();
                $A.get('e.force:refreshView').fire();
            }
            else{
                component.set("v.isLoading", false);
                var errors = response.getError();
                let toastParams = {
                    title: "Error",
                    message: errors[0].message, 
                    type: "error"
                };
                component.set("v.isLoading", false);
                let toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams(toastParams);
                toastEvent.fire();

                $A.get('e.force:refreshView').fire();
            }
        });
        $A.enqueueAction(finalizarRedaccion);
	}
})