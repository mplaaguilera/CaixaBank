({
    iniciar: function (component, event, helper) {
        var mccId = component.get("v.recordId");
        helper.loadCarpetasOperativa(component,event,helper); 
    },
    
    handleCarpetaOperativaSeleccionada: function (component, event,helper) {
        component.set("v.carpetaTipoComunicacionSeleccionada", true);
        component.set("v.carpetaTipoComunicacion",event.getParam("value"));
        helper.loadCarpetasCanal(component,event,helper);       
    },
    
    handleCanalSeleccionado: function (component, event,helper) {
        component.set("v.carpetaCanalSeleccionado", true);
        component.set("v.carpetaCanalComunicacion", event.getParam("value"));
        helper.loadCarpetasIdioma(component,event,helper);      
    },
    
    handleIdiomaSeleccionado: function (component, event,helper) {
        component.set("v.procesoFinalSeleccion", true);
        component.set("v.carpetaFinal",event.getParam("value"));
        helper.loadPlantillas(component,event,helper);      
    },
    
    handlePlantillaSeleccionada: function (component, event) {
        component.set("v.plantillaSeleccionada", true);
        var templateId = event.getParam("value");
        var opcionesPlantilla = component.get("v.opcionesPlantilla");
        opcionesPlantilla.forEach(function(valor,indice,lista){
            if(valor.value ==  templateId) {
                component.set("v.templateName", valor.label);
                component.set("v.templateId", templateId);
            }
        });        
    },
    
    handleClickAceptar: function(component,event,helper) {
		var campaignId = component.get("v.recordId");        
        var carpetaCanal = component.get("v.carpetaFinal");
        var templateName = component.get("v.templateName");
        var templateDeveloperName = component.get("v.templateId");
        
        var action = component.get("c.guardarPlantilla");
        action.setParams({
            'campaignId' : campaignId,
            'carpeta': carpetaCanal,
            'template' : templateName,
            'templateDev' : templateDeveloperName
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                $A.get("e.force:closeQuickAction").fire();
                helper.showToast(component,event,helper);
            }
        });
        $A.enqueueAction(action);
        $A.get('e.force:refreshView').fire()
    },
    
    handleClickCancelar : function(component, event, helper) {
        $A.get("e.force:closeQuickAction").fire(); 
    }
})