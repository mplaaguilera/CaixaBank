({
    openModal : function(component, event, helper) {
        component.set("v.isModalOpen", "true");
    },
    closeModal : function(component, event, helper) {
        component.set("v.isModalOpen", "false");
    },
    doInit :function(component, event, helpe){
        var idCase = component.get("v.recordId");
		var propietario = component.get("c.esPropietario");
        propietario.setParams({'record': idCase});
        propietario.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {

                component.set('v.esPropietario', response.getReturnValue());
            }
        });
        $A.enqueueAction(propietario);
    }
})