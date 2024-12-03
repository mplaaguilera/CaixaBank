({
    activar : function(cmp) {
		var action = cmp.get("c.updateStatus");
        var recordId = cmp.get("v.recordId");
            
        console.log("recordId: "+recordId);
        action.setParams({
            leadOppId: recordId
        });
        action.setCallback(this, function(response) {
            if (response.getState() === "SUCCESS") {
                var desactivo = response.getReturnValue();
                console.log("Desactivo: "+desactivo);
                cmp.set("v.isActive", desactivo);
                $A.get("e.force:closeQuickAction").fire();
                $A.get("e.force:refreshView").fire();
            }else{
                //Error
            }
            });
            $A.enqueueAction(action);
    }
})