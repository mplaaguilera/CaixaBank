({
	init : function(component, event, helper) {
        
        var idTarea = component.get("v.recordId");
        var OwnerId = $A.get('$SObjectType.CurrentUser.Id');
        var asignaTarea = component.get('c.autoasignarPropiedadTarea');

        asignaTarea.setParams({
            'tareaId': idTarea,  
            'ownerId' : OwnerId
        });

        asignaTarea.setCallback(this, function(response){
        
                var state = response.getState();
                if(state == "SUCCESS") {
                    var refrescar = response.getReturnValue();
                    if(refrescar == true) {
                        $A.get('e.force:refreshView').fire();
                    }
                }
        });

        $A.enqueueAction(asignaTarea); 
	}
})