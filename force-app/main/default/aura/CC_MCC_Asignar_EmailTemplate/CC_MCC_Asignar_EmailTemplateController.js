({
    iniciar: function (component, event, helper) {
        var mccId = component.get("v.recordId");
        var mccPlantilla = component.get("v.mccPlantilla");
        mccPlantilla.CC_MCC__c = mccId;
        helper.loadCarpetasOperativa(component,event,helper); 
    },
    //Comprobar si selecciona si es sdocs
    loadItemPlantillaOptions: function (component, event, helper) {
        var opts = [
            { value: "SDOCS", label: "Plantillas S-Docs" },
            { value: "SALESFORCE", label: "Plantillas Salesforce " }
        ];
        component.set("v.optionsItemPlantilla", opts);
    },    
    loadItemPlantillaOptionsFormato: function (component, event, helper) {
        var opts = [
            { value: "PDF", label: "PDF" },
            { value: "HTML", label: "HTML" }
        ];
        component.set("v.optionsItemPlantillaFormato", opts);
    },    
    loadItemPlantillaOptionsLenguaje: function (component, event, helper) {
        var opts = [
            { value: "Castellano", label: "Castellano" },
            { value: "Catalan", label: "Catalan" },
            { value: "Ingles", label: "Ingles" }
        ];
        component.set("v.optionsItemPlantillaLenguaje", opts);
    },    
    handleValidarPlantillaElegida: function (component, event, helper) {
        component.set("v.nombrePlantillaElegido", true);    
        var mccPlantilla = component.get("v.mccPlantilla");
        mccPlantilla.CC_MCC_Plantilla_DeveloperName__c = event.getParam("value");
        var opcionesPlantilla = component.get("v.opcionesNombrePlantilla");
        opcionesPlantilla.forEach(function(valor,indice,lista){
            if(valor.value ==  mccPlantilla.CC_MCC_Plantilla_DeveloperName__c) {
                mccPlantilla.CC_MCC_Plantilla_Name__c = valor.label;
                mccPlantilla.CC_Id_SDOC_Plantilla__c  = valor.value;
            }
        });
    },   

    handleCarpetaOperativaSeleccionada: function (component, event,helper) {
        component.set("v.carpetaOperativa",event.getParam("value"));
        helper.loadCarpetasIdioma(component,event,helper);       
    },
    handleCarpetaIdiomaSeleccionada: function (component, event,helper) {
        component.set("v.carpetaIdioma",event.getParam("value"));
        helper.loadCarpetasTratamiento(component,event,helper);   
    },
    handleCarpetaTratamientoSeleccionada: function (component, event,helper) {
        component.set("v.procesoFinalSeleccion", true);
        component.set("v.carpetaFinal",event.getParam("value"));
        helper.loadPlantillas(component,event,helper);     
    },
    handlePlantillaSeleccionada: function (component, event) {
        var mccPlantilla = component.get("v.mccPlantilla");
        component.set("v.plantillaSeleccionada", true);
        mccPlantilla.CC_MCC_Plantilla_DeveloperName__c = event.getParam("value");
        var opcionesPlantilla = component.get("v.opcionesPlantilla");
        opcionesPlantilla.forEach(function(valor,indice,lista){
            if(valor.value ==  mccPlantilla.CC_MCC_Plantilla_DeveloperName__c) {
                mccPlantilla.CC_MCC_Plantilla_Name__c = valor.label;
            }
        });
        
    },
    handleClickAceptar: function(component,event,helper) {
        var mccPlantilla = component.get("v.mccPlantilla");
        if (mccPlantilla.CC_MCC_Plantilla_Name__c != undefined && mccPlantilla.CC_MCC_Plantilla_DeveloperName__c != undefined){
            if(component.get("v.tipoplantilla") != 'SDOCS'){
                mccPlantilla.CC_Id_SDOC_Plantilla__c  = null;
            }
            var action = component.get("c.guardar");
            action.setParams({
                'plantilla': mccPlantilla
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
        }
    },
    handleClickCancelar : function(component, event, helper) {
        $A.get("e.force:closeQuickAction").fire(); 
    },
    buscarPlantillaSDOC : function(component, event, helper) {
        component.set("v.nombrePlantillaElegido", false);
        helper.loadPlantillaSDOC(component,event,helper);    
    },
})