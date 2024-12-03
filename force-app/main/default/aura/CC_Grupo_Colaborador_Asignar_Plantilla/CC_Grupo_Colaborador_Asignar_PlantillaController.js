({
    iniciar: function(component, event, helper) {
        let grupoPlantilla = component.get("v.grupoPlantilla");
        grupoPlantilla.CC_Grupo_Colaborador__c = component.get("v.recordId");
        helper.loadOperativas(component);
    },

    handlePlantillaSeleccionada: function(component, event) {
        var grupoPlantilla = component.get("v.grupoPlantilla");
        component.set("v.plantillaSeleccionada", true);
        grupoPlantilla.CC_Plantilla_DeveloperName__c = event.getParam("value");
        var opcionesPlantilla = component.get("v.opcionesPlantilla");
        opcionesPlantilla.forEach(function(valor, indice, lista) {
            if (valor.value ==  grupoPlantilla.CC_Plantilla_DeveloperName__c) {
                grupoPlantilla.CC_Plantilla_Name__c = valor.label;
            }
        });
    },

    handleOperativaSeleccionada: function(component, event, helper) {
        component.set("v.carpetaOperativa", event.getParam("value"));
        var grupoPlantilla = component.get("v.grupoPlantilla");
        if (event.getParam("value").includes('Trasladar')) {
            grupoPlantilla.CC_Operativa__c = 'Trasladar';
        } else if (event.getParam("value").includes('Remitir')) {
            grupoPlantilla.CC_Operativa__c = 'Remitir';
        }
        helper.loadPlantillas(component);
    },

    handleClickAceptar: function(component, event, helper) {
        var grupoPlantilla = component.get("v.grupoPlantilla");

        if (grupoPlantilla.CC_Plantilla_Name__c != undefined && grupoPlantilla.CC_Plantilla_DeveloperName__c != undefined) {
            var action = component.get("c.guardar");
            action.setParams({'plantilla': grupoPlantilla});
            action.setCallback(this, function(response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    $A.get("e.force:closeQuickAction").fire();
                    helper.showToast();
                }
            });
            $A.enqueueAction(action);
            $A.get('e.force:refreshView').fire()
        }
    },

    handleClickCancelar: function() {
        $A.get("e.force:closeQuickAction").fire(); 
    }
})