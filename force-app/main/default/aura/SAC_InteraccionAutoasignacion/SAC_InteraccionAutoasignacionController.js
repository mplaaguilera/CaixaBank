({
    init : function(component, event, helper) {
        
        var idInteraccion = component.get("v.recordId");
        var OwnerId = $A.get('$SObjectType.CurrentUser.Id');
        var asignaInteraccion = component.get('c.autoasignarPropiedadInteraccion');

        asignaInteraccion.setParams({
            'interaccionId': idInteraccion,  
            'ownerId' : OwnerId
        });

        asignaInteraccion.setCallback(this, function(response){
        
                var state = response.getState();
                if(state == "SUCCESS") {
                    $A.get('e.force:refreshView').fire();
                }
        });

        $A.enqueueAction(asignaInteraccion); 
	}
})