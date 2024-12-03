({
    init : function(component, event, helper) {
        var itemsPlantillas = [];
        var itemsPlantillasInteraccion = [];

        var getPlantillas = component.get('c.getPlantillas');
        getPlantillas.setParam('carpeta', 'Derivacion');

        getPlantillas.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var arr = response.getReturnValue() ;
                arr.forEach(function(element) {
                    itemsPlantillas.push({value: element.Id, label: element.Name});
                });
                component.set('v.opcionesPlantilla', itemsPlantillas);
            }
        });
        $A.enqueueAction(getPlantillas);

        var getPlantillasInteraccion = component.get('c.getPlantillas');
        getPlantillasInteraccion.setParam('carpeta', 'Consulta');

        getPlantillasInteraccion.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var arr = response.getReturnValue() ;
                arr.forEach(function(element) {
                    itemsPlantillasInteraccion.push({value: element.Id, label: element.Name});
                });
                component.set('v.opcionesPlantillaInteraccion', itemsPlantillasInteraccion);
            }
        });
        $A.enqueueAction(getPlantillasInteraccion);

    },
    update : function(component,event,helper) {
        component.find("PlantillaConsultaId").set("v.value",component.find("PlantillaConsultaName").get("v.value") );
        component.find("PlantillaReclamacionId").set("v.value", component.find("PlantillaReclamacionName").get("v.value") );
        component.find("PlantillaInteraccionId").set("v.value", component.find("PlantillaInteraccionName").get("v.value") );
     //   component.find("PlantillaReclamanteId").set("v.value", component.find("PlantillaReclamanteName").get("v.value"));
        
        //component.find("editForm").submit();
     },
    recordLoaded : function(component, event, helper) {
        var recordUi = event.getParam("recordUi");
        
        component.find("PlantillaConsultaName").set("v.value", recordUi.record.fields["SAC_PlantillaConsultaId__c"].value);
        component.find("PlantillaReclamacionName").set("v.value", recordUi.record.fields["SAC_PlantillaReclamacionId__c"].value);
        component.find("PlantillaInteraccionName").set("v.value", recordUi.record.fields["SAC_PlantillaInteraccionId__c"].value);
     //   component.find("PlantillaReclamanteName").set("v.value", recordUi.record.fields["SAC_PlantillaReclamanteId__c"].value);

     },
     editar : function(component, event, helper) {
        component.set('v.readonly', false);
     },
     noeditar : function(component, event, helper) {
        component.set('v.readonly', true);
        $A.get('e.force:refreshView').fire();
     },
     guardar : function(component, event, helper) {
        component.set('v.readonly', true);
        component.find("editForm").submit();
     }
})