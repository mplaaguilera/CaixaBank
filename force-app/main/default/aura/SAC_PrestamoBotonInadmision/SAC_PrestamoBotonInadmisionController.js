({
    doInit: function(component, event, helper){
        var idCase = component.get("v.recordId");
        var criterioExist = component.get("v.cumpleCriterio");
        var action = component.get("c.inadmitirButtonVisibleOrHidden");
        
        action.setParams({'recId': idCase, 'cumpleCriterio': criterioExist});
        action.setCallback(this, function(response) {
            var state = response.getState();
            var show = response.getReturnValue(); 
            if (state === "SUCCESS") {
                if(show == true){
                    component.set("v.showButton", true);
                }
            }else{
                var errors = response.getError();
                let toastParams = {
                    title: "Error",
                    message: errors[0].message, 
                    type: "error"
                };
                let toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams(toastParams);
                toastEvent.fire();
            }});
        $A.enqueueAction(action);
    },
    
    openComponent : function(component, event, helper) {
        var show = component.get("v.showComponent");
        if(show === true){
            component.set("v.showComponent", false);  
        }else{
            component.set("v.showComponent", true);
        }
    },
    handleApplicationEvent : function(component, event, helper) {
        component.set('v.showComponent', event.getParam("showComponente"));
        component.set('v.showButton', event.getParam("showButton"));
    }
})