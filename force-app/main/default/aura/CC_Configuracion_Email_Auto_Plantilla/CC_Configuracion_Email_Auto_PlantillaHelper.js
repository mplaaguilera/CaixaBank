({
	loadCarpetasOperativa: function(component,event,helper) {
		var opcionesOperativaFolder = [
        ];
        var action = component.get("c.getCarpetas");
        action.setParams({
            'carpetaDeveloperName': null,
            'idReclamacion': component.get("v.recordId")
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var arr = response.getReturnValue() ;
                arr.forEach(function(element) {
					 opcionesOperativaFolder.push({ value: element.DeveloperName, label: element.Name });
				});
                component.set("v.opcionesOperativaFolder", opcionesOperativaFolder);
            }
        });
        $A.enqueueAction(action);
    },
    loadCarpetasIdioma: function(component,event,helper) {
		var opcionesIdiomaFolder = [
        ];
        var carpetaOperativa = component.get("v.carpetaOperativa");
        var action = component.get("c.getCarpetas");
        action.setParams({
            'carpetaDeveloperName': carpetaOperativa
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var arr = response.getReturnValue() ;
                arr.forEach(function(element) {
					 opcionesIdiomaFolder.push({ value: element.DeveloperName, label: element.Name });
				});
                component.set("v.opcionesIdiomaFolder", opcionesIdiomaFolder);
            }
            if (opcionesIdiomaFolder.length == 0) {
                component.set("v.procesoFinalSeleccion", true);
                component.set("v.carpetaFinal",carpetaOperativa);
                helper.loadPlantillas(component,event,helper);  
            }
            else {
                component.set("v.carpetaOperativaSeleccionada", true);
            }
        });
        $A.enqueueAction(action);
    },

	loadPlantillas: function (component,event,helper) {
        var carpetaFinal = component.get("v.carpetaFinal")
        var opcionesPlantilla = [
        ];
        var action = component.get("c.getPlantillas");
        action.setParams({
            'carpeta': carpetaFinal
        })
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var arr = response.getReturnValue() ;
                arr.forEach(function(element) {
					opcionesPlantilla.push({ value: element.DeveloperName, label: element.Name });
				});
                component.set("v.opcionesPlantilla", opcionesPlantilla);
            }
        });
		$A.enqueueAction(action);
    },
    showToast : function(component, event, helper) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            mode: 'dismissible',
            message: 'Se ha asignado la plantilla.',
            type: 'success'
        });
        toastEvent.fire();
    }
})