({
    selectGroup : function(component, event, helper){      
        var getSelectGroup = component.get("v.oGroup");
        var compEvent = component.getEvent("oSelectedGroupEvent");
        compEvent.setParams({"groupByEvent" : getSelectGroup });  
        compEvent.fire();
    },
})