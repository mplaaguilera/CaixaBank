({
	doInit : function(component, event, helper) {
        //Carga de los enlaces según atributos del caso
        var action = component.get("c.getEnlaces");
        //action.setParams({"sObjectName" : component.get("v.sObjectName"), "recordId" : component.get("v.recordId")});
        
        //Al recibir la respuesta se actualizan los enlaces mostrados
        action.setCallback(this, function(response) {
                                    var state = response.getState();
                                    if (state === "SUCCESS") {
                                        //console.log(JSON.stringify(response.getReturnValue()));
                                        component.set("v.enlaces", response.getReturnValue());
                                        //component.set("v.canalProcedencia", response.getReturnValue().canalProcedencia);
                                    } else {
                                        console.log("No es posible recuperar la lista de enlaces." + state);
                                    }
        						 });
        
        $A.enqueueAction(action);
	}
})