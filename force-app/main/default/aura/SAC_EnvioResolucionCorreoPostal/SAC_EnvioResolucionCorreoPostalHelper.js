({
    finalizar: function (component, event) {
        component.set("v.isLoading", true);
        let id = component.get("v.recordId");
        let idsFicherosAdjuntos = component.get("v.idsFicherosAdjuntos");
        console.log('CGR idsFicherosAdjuntos', JSON.stringify(idsFicherosAdjuntos));
        
    
        // Primero llamar a finalizarRedaccionCartaPostal
        let finalizarRedaccion = component.get("c.finalizarRedaccionCartaPostal");
        finalizarRedaccion.setParams({
            'caseId': id,
            'para': component.get("v.para"),
            'copia': component.get("v.copia"),
            'copiaOculta': component.get("v.copiaOculta"),
            'cuerpo': component.get("v.cuerpo"),
            'asunto': component.get("v.asunto"),
            'idAdjuntos': JSON.stringify(idsFicherosAdjuntos),
        });
    
        finalizarRedaccion.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                let emailsInvalidos = response.getReturnValue();
                component.set("v.isLoading", false);
    
                if (emailsInvalidos !== "") {
                    var toastEventWarning = $A.get("e.force:showToast");
                    toastEventWarning.setParams({
                        title: "Advertencia!",
                        message:
                            "No se ha enviado el email correspondiente a la oficina. No está permitido el envío de emails a esta dirección: " +
                            emailsInvalidos,
                        type: "warning",
                        duration: 8000,
                    });
                    toastEventWarning.fire();
                }
    
                // Mensaje de éxito final para la redacción
                let toastEventFinal = $A.get("e.force:showToast");
                toastEventFinal.setParams({
                    title: "Redacción finalizada",
                    message:
                        "La reclamación avanza al siguiente estado ejecutando sus acciones pertinentes.",
                    type: "success",
                    duration: 4000,
                });
                toastEventFinal.fire();
            } else {
                // Manejo de errores al finalizar la redacción
                var errors = response.getError();
                let toastParams = {
                    title: "Error",
                    message: errors[0].message,
                    type: "error",
                };
                component.set("v.isLoading", false);
                let toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams(toastParams);
                toastEvent.fire();
            }
        });
        $A.enqueueAction(finalizarRedaccion);
    },

    fetchOptions: function (component) {
        // Llama al método Apex para obtener opciones iniciales
        const action = component.get("c.obtenerGrupos");
        action.setParams({ caseId: component.get("v.recordId") });

        action.setCallback(this, function (response) {
            const state = response.getState();
            if (state === "SUCCESS") {
                const options = response.getReturnValue();
                component.set("v.optionsGruposTarea", options);
                component.set("v.filteredOptionsGruposTarea", options);
            } else {
                console.error("Error al obtener las opciones:", response.getError());
            }
        });

        $A.enqueueAction(action);
    },

    filterOptions: function (component, searchTerm) {        
        const options = component.get("v.optionsGruposTarea");
        const filtered = options.filter(option =>
            option.Name.toLowerCase().includes(searchTerm.toLowerCase())
        );
        component.set("v.filteredOptionsGruposTarea", filtered);
    }
})