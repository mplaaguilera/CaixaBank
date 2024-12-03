({
    doInit : function(component, event, helper) {
        var action = component.get('c.recogerCaso');
        action.setParams({'caseId': component.get("v.recordId")});

        action.setCallback(this, function(response) {
			var state = response.getState();
            if (state === "SUCCESS") {
                var respuesta = response.getReturnValue();
                component.set('v.caso', respuesta);
            }
            else{
                var errors = response.getError();
                let toastParams = {
                    title: "Error",
                    message: errors[0].pageErrors[0].message, 
                    type: "error"
                };
                let toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams(toastParams);
                toastEvent.fire();
            }
        })

        $A.enqueueAction(action);
    }
})