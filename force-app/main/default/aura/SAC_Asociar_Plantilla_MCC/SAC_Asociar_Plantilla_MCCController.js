({
    init : function(component, event, helper) {
        /*var itemsPlantillas = [];
        var getPlantillas = component.get('c.getPlantillas');
        getPlantillas.setParam('carpeta', 'SAC_REDACCION_ES');

        getPlantillas.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var arr = response.getReturnValue() ;
                arr.forEach(function(element) {
                    itemsPlantillas.push({value: element.Id, label: element.Name});
                    
                });
                component.set('v.opcionesPlantillaES', itemsPlantillas);
            }
        });
        $A.enqueueAction(getPlantillas);*/
    },
    handleCreateLoad: function (component, event, helper) {
        var recordUi = event.getParam("recordUi");
        var tipo_plantila = recordUi.record.fields["SAC_TipoPlantilla__c"].value;

        var itemsPlantillasES = [];
        var itemsPlantillasCAT = [];
        var itemsPlantillasING = [];
        var itemsPlantillasEUSK = [];
        var itemsPlantillasVAL = [];
        var itemsPlantillasGAL = [];

        var getPlantillasES = component.get('c.getPlantillas');
        var getPlantillasCAT = component.get('c.getPlantillas');
        var getPlantillasING = component.get('c.getPlantillas');
        var getPlantillasEUSK = component.get('c.getPlantillas');
        var getPlantillasVAL = component.get('c.getPlantillas');
        var getPlantillasGAL = component.get('c.getPlantillas');
        getPlantillasES.setParam('carpeta', tipo_plantila+'_ES');
        getPlantillasCAT.setParam('carpeta', tipo_plantila+'_CAT');
        getPlantillasING.setParam('carpeta', tipo_plantila+'_ING');
        getPlantillasEUSK.setParam('carpeta', tipo_plantila+'_EUSK');
        getPlantillasVAL.setParam('carpeta', tipo_plantila+'_VAL');
        getPlantillasGAL.setParam('carpeta', tipo_plantila+'_GAL');

        getPlantillasES.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var arr = response.getReturnValue() ;
                arr.forEach(function(element) {
                    itemsPlantillasES.push({value: element.Id, label: element.Name});
                    
                });
                component.set('v.opcionesPlantillaES', itemsPlantillasES);
            }
        });

        getPlantillasCAT.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var arr = response.getReturnValue() ;
                arr.forEach(function(element) {
                    itemsPlantillasCAT.push({value: element.Id, label: element.Name});
                    
                });
                component.set('v.opcionesPlantillaCAT', itemsPlantillasCAT);
            }
        });

        getPlantillasING.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var arr = response.getReturnValue() ;
                arr.forEach(function(element) {
                    itemsPlantillasING.push({value: element.Id, label: element.Name});
                    
                });
                component.set('v.opcionesPlantillaING', itemsPlantillasING);
            }
        });

        getPlantillasEUSK.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var arr = response.getReturnValue() ;
                arr.forEach(function(element) {
                    itemsPlantillasEUSK.push({value: element.Id, label: element.Name});
                    
                });
                component.set('v.opcionesPlantillaEUSK', itemsPlantillasEUSK);
            }
        });

        getPlantillasVAL.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var arr = response.getReturnValue() ;
                arr.forEach(function(element) {
                    itemsPlantillasVAL.push({value: element.Id, label: element.Name});
                    
                });
                component.set('v.opcionesPlantillaVAL', itemsPlantillasVAL);
            }
        });

        getPlantillasGAL.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var arr = response.getReturnValue() ;
                arr.forEach(function(element) {
                    itemsPlantillasGAL.push({value: element.Id, label: element.Name});
                    
                });
                component.set('v.opcionesPlantillaGAL', itemsPlantillasGAL);
            }
        });

        $A.enqueueAction(getPlantillasES);
        $A.enqueueAction(getPlantillasCAT);
        $A.enqueueAction(getPlantillasING);
        $A.enqueueAction(getPlantillasEUSK);
        $A.enqueueAction(getPlantillasVAL);
        $A.enqueueAction(getPlantillasGAL);

        component.find("PlantillaCastellano").set("v.value", recordUi.record.fields["SAC_PlantillaCastellanoId__c"].value);
        component.find("PlantillaCatalan").set("v.value", recordUi.record.fields["SAC_PlantillaCatalanId__c"].value);
        component.find("PlantillaIngles").set("v.value", recordUi.record.fields["SAC_PlantillaInglesId__c"].value);
        component.find("PlantillaEuskera").set("v.value", recordUi.record.fields["SAC_PlantillaEuskeraId__c"].value);
        component.find("PlantillaValenciano").set("v.value", recordUi.record.fields["SAC_PlantillaValencianoId__c"].value);
        component.find("PlantillaGallego").set("v.value", recordUi.record.fields["SAC_PlantillaGallegoId__c"].value);

        console.log(recordUi.record.fields["SAC_PlantillaCatalanId__c"]);


    },
    /*update : function(component,event,helper) {
        component.find("SAC_PlantillaCastellanoId").set("v.value",component.find("PlantillaCastellano").get("v.value") );
        component.find("SAC_PlantillaCatalanId").set("v.value", component.find("PlantillaCatalan").get("v.value") );
        component.find("SAC_PlantillaInglesId").set("v.value", component.find("PlantillaIngles").get("v.value"));
        
        component.find("SAC_PlantillaIngles").set("v.value", helper.buscarlabel(component.get('v.opcionesPlantillaING'),component.find("PlantillaIngles").get("v.value")));
        //component.find("editForm").submit();
     },*/
    updateES : function(component,event,helper) {
        component.find("SAC_PlantillaCastellanoId").set("v.value",component.find("PlantillaCastellano").get("v.value") );
        component.find("SAC_PlantillaCastellano").set("v.value", helper.buscarlabel(component.get('v.opcionesPlantillaES'),component.find("PlantillaCastellano").get("v.value")));

     },
     updateCAT : function(component,event,helper) {
        component.find("SAC_PlantillaCatalanId").set("v.value", component.find("PlantillaCatalan").get("v.value") );
        component.find("SAC_PlantillaCatalan").set("v.value", helper.buscarlabel(component.get('v.opcionesPlantillaCAT'),component.find("PlantillaCatalan").get("v.value")));
     },
     updateING : function(component,event,helper) {
        component.find("SAC_PlantillaInglesId").set("v.value", component.find("PlantillaIngles").get("v.value"));
        component.find("SAC_PlantillaIngles").set("v.value", helper.buscarlabel(component.get('v.opcionesPlantillaING'),component.find("PlantillaIngles").get("v.value")));
     },
     updateEUSK : function(component,event,helper) {
        component.find("SAC_PlantillaEuskeraId").set("v.value",component.find("PlantillaEuskera").get("v.value") );
        component.find("SAC_PlantillaEuskera").set("v.value", helper.buscarlabel(component.get('v.opcionesPlantillaEUSK'),component.find("PlantillaEuskera").get("v.value")));

     },
     updateVAL : function(component,event,helper) {
        component.find("SAC_PlantillaValencianoId").set("v.value", component.find("PlantillaValenciano").get("v.value") );
        component.find("SAC_PlantillaValenciano").set("v.value", helper.buscarlabel(component.get('v.opcionesPlantillaVAL'),component.find("PlantillaValenciano").get("v.value")));
     },
     updateGAL : function(component,event,helper) {
        component.find("SAC_PlantillaGallegoId").set("v.value", component.find("PlantillaGallego").get("v.value"));
        component.find("SAC_PlantillaGallego").set("v.value", helper.buscarlabel(component.get('v.opcionesPlantillaGAL'),component.find("PlantillaGallego").get("v.value")));
     },
     onSubmit: function(component, event) {
		component.set('v.spinner', true);
	 },
     onSuccess:function(component, event) {
        component.set('v.spinner', false);
		let toastEvent = $A.get('e.force:showToast');
		toastEvent.setParams({'title': 'Plantillas vinculadas', 'message': 'Se han vinculado las plantillas ', 'type': 'success'});
		toastEvent.fire();
	 }
})