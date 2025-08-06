({
    sumaDiasFechaVencimiento: function (cmp) {
        var action = cmp.get("c.sumaDiasFechaVencimiento");
        var recordId = cmp.get("v.recordId");
       
        action.setParams({
            recordId : recordId
        });
        action.setCallback(this,function(response) {
            
            if (response.getState() === "SUCCESS") {
                $A.get("e.force:closeQuickAction").fire();
                $A.get("e.force:refreshView").fire();
            }else{
                $A.get("e.force:closeQuickAction").fire();
                $A.get("e.force:refreshView").fire();
                //Error
            }
        });
        $A.enqueueAction(action);
     

    },
   
    
});