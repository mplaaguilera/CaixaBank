({
	 doInit : function(component, event, helper) {
         
         var action = component.get("c.hasCustomPermission");
         action.setCallback(this, function(response) {
             var result = response.getReturnValue();
             if (result === true) {
				component.set("v.isBPR",true);
             }
             else if (result === false) {
                component.set("v.isBPR",false);
             }

         });

         $A.enqueueAction(action);

    }
})