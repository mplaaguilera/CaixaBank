({
    doInit : function(component, event, helper) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": "Warning!",
            "message": "No pueden crearse SocialPost desde esta pantalla",
            "type": "warning"
        });
        toastEvent.fire();
    }
})