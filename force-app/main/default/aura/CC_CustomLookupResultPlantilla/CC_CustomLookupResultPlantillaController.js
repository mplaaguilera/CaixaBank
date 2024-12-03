({
	selectPlantilla : function(component, event, helper){   
        
        var getSelectPlantilla = component.get("v.oPlantilla");
        var compEvent = component.getEvent("oSelectedPlantillaEvent");
        compEvent.setParams({"plantillaByEvent" : getSelectPlantilla });  
        compEvent.fire();
    },
})