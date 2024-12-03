({
	init : function(component, event, helper) {
        
        var idCase = component.get("v.recordId");
        var OwnerId = $A.get('$SObjectType.CurrentUser.Id');

        var asignaCaso = component.get('c.autoasignarPropiedadCaso');
        asignaCaso.setParams({
            'caseId': idCase,  
            'ownerId' : OwnerId
        });
        asignaCaso.setCallback(this, function(response){
        
                var state = response.getState();
                if(state == "SUCCESS") {
                    var refrescar = response.getReturnValue();
                    if(refrescar == true) {
                        $A.get('e.force:refreshView').fire();
                    }
                    /*window.setTimeout(
                            $A.getCallback(function() {
                                $A.get('e.force:refreshView').fire();
                            }), 100)*/
                }
        });

        $A.enqueueAction(asignaCaso); 

	}
})