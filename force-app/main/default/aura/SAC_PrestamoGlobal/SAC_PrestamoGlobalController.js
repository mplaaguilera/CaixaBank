({
    doInit: function(component, event, helper){
        var idCase = component.get("v.recordId");
        var checkPrestamosAction = component.get("c.checkPrestamos");
        component.set('v.haySeleccion', true);
        checkPrestamosAction.setParams({'recId': idCase});
        checkPrestamosAction.setCallback(this, function(response) {
            var state = response.getState();
            var prestamosExist = response.getReturnValue();            
            if (state === "SUCCESS") {
                if(prestamosExist == true){
                    component.set("v.hayPrestamos", true);
                }else{
                    component.set("v.hayPrestamos", false);
                }
            }
        });
        $A.enqueueAction(checkPrestamosAction);
    },

    handleValidationCheck : function(component, event, helper) {
        const hasValidation = event.getParam('hasValidation');
        component.set("v.cumpleCriterio", hasValidation);
        const spinnerLoading = event.getParam('spinnerLoading');
        component.set("v.isLoading", spinnerLoading);
    }
})