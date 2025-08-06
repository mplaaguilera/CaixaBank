({
  
    handlePreview : function (component, event) {
        var CaseId = component.get("v.caso.Id");        
        var navEvt = $A.get("e.force:navigateToSObject");
        navEvt.setParams({ "recordId": CaseId });
        navEvt.fire();
    },
    
    handleClick : function (component, event,asignar) {
        var CaseId = component.get("v.caso.Id");
        var QueueId = component.get("v.caso.OwnerId");
        var CaseNumber = component.get("v.caso.CaseNumber");
        var toastEvent = $A.get("e.force:showToast");
        var action = component.get("c.acceptCase");
        var utilityAPI = component.find("buzonbar");
        
        action.setParams({
            'CaseId': CaseId,
            'QueueId': QueueId
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var event = component.getEvent("refrescar");
                event.setParam("refrescar", true);
                event.fire();
                
                var resultado = response.getReturnValue() ;
                if (resultado){                    
                    toastEvent.setParams({
                        "type": "success",
                        "title": "Success!",
                        "message": "Se le ha asignado el caso " + CaseNumber + " correctamente."
                    });
                    toastEvent.fire();
                } else {
                    toastEvent.setParams({
                        "type": "Error",
                        "title": "Error!",
                        "message": "No es posible asignar el caso " + CaseNumber + " ."
                    });
                    toastEvent.fire();                    
                }
            } else {
                    toastEvent.setParams({
                        "type": "Error",
                        "title": "Error!",
                        "message": "No es posible asignar el caso " + CaseNumber + " ."
                    });
                    toastEvent.fire();              
            } 
        });
		$A.enqueueAction(action);
        
        var utilityAPI = component.find("buzonbar");
        utilityAPI.minimizeUtility();
        var navEvt = $A.get("e.force:navigateToSObject");
        $A.get('e.force:refreshView').fire();
        navEvt.setParams({ "recordId": CaseId });
        navEvt.fire();
        
    }
})