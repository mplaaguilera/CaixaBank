({
    selectGroup : function(component, event, helper){      
        var getSelectGroup = component.get("v.oGroup");
        var compEvent = component.getEvent("oSelectedGroup2NEvent");
        compEvent.setParams({"groupByEvent" : getSelectGroup });  
        compEvent.fire();
    },
})