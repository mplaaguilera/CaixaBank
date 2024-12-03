({
    doInit : function(component) {        
        var dismissActionPanel = $A.get("e.force:closeQuickAction");
        dismissActionPanel.fire();
        
        var action = component.get("c.FinalizarEvento");
        action.setParams({
            "campaignId":component.get('v.recordId')
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            var result = response.getReturnValue();
            if (state === "SUCCESS"){                 
                if(result === "OK"){
                    this.toastAll(component, "Evento finalizado! Se han enviado las encuestas de satisfacción.", "Success", "Éxito");
                }else{
                    this.toastAll(component, result, "Error", "Error");
                }
                var dismissActionPanel = $A.get("e.force:closeQuickAction");
                dismissActionPanel.fire();
            }
        });
        $A.enqueueAction(action);
    },
    
    toastAll : function(component, message, type, title) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            mode: 'dismissible',
            title: title,
            type: type,
            message: message,
            key: 'info_alt', 
            duaration: '5000'
        }); 
        toastEvent.fire();
    }
})