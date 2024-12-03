({
    loadCarpetasOperativa: function(component,event,helper) {
		var opcionesOperativaFolder = [
        ];
        var action = component.get("c.getCarpetas");
        action.setParams({
            'carpetaDeveloperName': null
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var arr = response.getReturnValue() ;
                arr.forEach(function(element) {
					 opcionesOperativaFolder.push({ value: element.DeveloperName, label: element.Name });
				});
                component.set("v.opcionesOperativaFolder", opcionesOperativaFolder);
                component.set("v.carpetaTipoComunicacionSeleccionada", false);
                //component.set("v.carpetaTipoComunicacion", '');
                component.set("v.carpetaCanalSeleccionado", false);
                component.set("v.carpetaCanalComunicacion", '');                
                component.set("v.procesoFinalSeleccion", false);
                component.set("v.carpetaFinal", '');
                component.set("v.plantillaSeleccionada", false);  
            }
        });
        $A.enqueueAction(action);
    },
    
    loadCarpetasCanal: function(component,event,helper) {
		var opcionesCanalComunicacionFolder = [
        ];
        var carpetaTipoComunicacion = component.get("v.carpetaTipoComunicacion");
        var action = component.get("c.getCarpetas");
        action.setParams({
            'carpetaDeveloperName': carpetaTipoComunicacion
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var arr = response.getReturnValue() ;
                arr.forEach(function(element) {
					 opcionesCanalComunicacionFolder.push({ value: element.DeveloperName, label: element.Name });
				});
                component.set("v.opcionesCanalComunicacionFolder", opcionesCanalComunicacionFolder);
                component.set("v.carpetaTipoComunicacion", '');
                component.set("v.carpetaCanalSeleccionado", false);
                component.set("v.carpetaCanalComunicacion", '');  
                component.set("v.procesoFinalSeleccion", false);
                component.set("v.carpetaFinal", '');
                component.set("v.plantillaSeleccionada", false); 
            }
        });
        $A.enqueueAction(action);
    },
    
    loadCarpetasIdioma: function(component,event,helper) {
		var opcionesIdiomaComunicacionFolder = [
        ];
        var carpetaCanalComunicacion = component.get("v.carpetaCanalComunicacion");
        var action = component.get("c.getCarpetas");
        action.setParams({
            'carpetaDeveloperName': carpetaCanalComunicacion
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var arr = response.getReturnValue() ;
                arr.forEach(function(element) {
					 opcionesIdiomaComunicacionFolder.push({ value: element.DeveloperName, label: element.Name });
				});
                component.set("v.opcionesIdiomaComunicacionFolder", opcionesIdiomaComunicacionFolder);      
                component.set("v.procesoFinalSeleccion", false);
                component.set("v.carpetaFinal", '');
                component.set("v.plantillaSeleccionada", false); 
            }
            if (opcionesIdiomaComunicacionFolder.length != 0) {
                component.set("v.carpetaCanalSeleccionado", true);
            }
        });
        $A.enqueueAction(action);
    },
    
	loadPlantillas: function (component,event,helper) {
        var mccId = component.get("v.recordId");
        var carpetaFinal = component.get("v.carpetaFinal")
        var opcionesPlantilla = [  
        ];

        var carpetaTipoComunicacion = component.get("v.carpetaTipoComunicacion");
        if (carpetaTipoComunicacion != carpetaFinal && carpetaTipoComunicacion != '') {
            var action = component.get("c.getPlantillas");
            action.setParams({
                'carpeta': carpetaTipoComunicacion
            });
            action.setCallback(this, function(response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    var arr = response.getReturnValue() ;
                    arr.forEach(function(element) {
                        opcionesPlantilla.push({ value: element.Id, label: element.Name });
                    });
                }
            });
            $A.enqueueAction(action);
        }

        var action = component.get("c.getPlantillas");
        action.setParams({
            'mccId': mccId,
            'carpeta': carpetaFinal
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var arr = response.getReturnValue() ;
                arr.forEach(function(element) {
					opcionesPlantilla.push({ value: element.Id, label: element.Name });
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