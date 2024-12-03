({
	loadPlantillas: function(component) {
        var grupoId = component.get("v.recordId");
        var carpetaOperativa = component.get("v.carpetaOperativa");
        var opcionesPlantilla = [];

        var action = component.get("c.getPlantillas");
        action.setParams({
            'grupoId': grupoId,
            'carpetaOperativa': carpetaOperativa
        })
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var arr = response.getReturnValue();
                arr.forEach(function(element) {
					opcionesPlantilla.push({'value': element.DeveloperName, 'label': element.Name});
				});
                component.set("v.opcionesPlantilla", opcionesPlantilla);
                component.set("v.carpetaOperativaSeleccionada", true);
            }
        });

		$A.enqueueAction(action);

        
       
       

    },

    loadOperativas: function(component) {
        var opcionesOperativa = [];
        var action = component.get("c.getOperativas");
        action.setParams({
            'grupo': component.get('v.recordId')
        })
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var arr = response.getReturnValue();
                if(arr == ''){
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        'mode': 'dismissible',
                        'message': 'No se ha encontrado ninguna carpeta.',
                        'type': 'error'
                    });
                    toastEvent.fire();
                } else {
                    arr.forEach(function(element) {
                        opcionesOperativa.push({ value: element.DeveloperName, label: element.Name });
                    });
                    component.set("v.opcionesOperativa", opcionesOperativa);
                }  
            }
        });
		$A.enqueueAction(action);
    },

    showToast: function() {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            'mode': 'dismissible',
            'message': 'Se ha asignado la plantilla.',
            'type': 'success'
        });
        toastEvent.fire();
    }
})