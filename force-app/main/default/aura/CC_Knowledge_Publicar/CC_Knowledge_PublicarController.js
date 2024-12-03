({
    cargarArticulos : function(component, event, helper) {
       
        let validarGuardar = component.get('c.publicarArticulo');
        validarGuardar.setParams({'recordId': component.get('v.recordId')});

        validarGuardar.setCallback(this, function(response) {

            if (response.getState() === "SUCCESS") {
                var storeResponse = response.getReturnValue();
                
                component.set("v.sePuedePublicar", storeResponse);
            }
    
        });
        $A.enqueueAction(validarGuardar);
        $A.get("e.force:closeQuickAction").fire();
    },


    handleClickCancelar : function(component, event, helper) {
        $A.get("e.force:closeQuickAction").fire(); 
    }
    
})