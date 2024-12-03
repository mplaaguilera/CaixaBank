({
    selectQueue : function(component) {
        var getSelectQueue = component.get("v.oQueue");
        var compEvent = component.getEvent("oSelectedQueueTransfer");
        compEvent.setParams({"queueByEvent" : getSelectQueue });  
        compEvent.fire();
    }
})