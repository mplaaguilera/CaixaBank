({  
    buscarAntecedentes : function(component, event, helper) {
        
		component.set('v.spinner', true);
        let clientes = [];
        let getDNI = component.get("c.obtenerDNIReclamantes");
        getDNI.setParams({
            'caseId': component.get("v.recordId")
        });
        getDNI.setCallback(this, function(response){
            let state = response.getState();
                if (state === "SUCCESS") {

                    var action = component.get("c.recuperarCaseInfo");
                    action.setParams({ caseId : component.get("v.recordId") });
                    action.setCallback(this, function(response) {
                    var state = response.getState();

                    if (state === "SUCCESS") {
                        component.set('v.ultimaActualizacion', response.getReturnValue().caso.SAC_FechaUltimaSolicitud__c);
                        $A.get('e.force:refreshView').fire();
                    }
                    });
                    $A.enqueueAction(action);
                }
	    	component.set('v.spinner', false);
        });
        $A.enqueueAction(getDNI);

    },

    setCheckRevisados : function(component, event){

        let establecerCheck = component.get("c.establecerCheckRevisados");
        establecerCheck.setParams({
            'caseId':  component.get("v.recordId"),
            'revisados': component.get('v.antecedentesRevisados')
        });
        establecerCheck.setCallback(this, function(response){
            let state = response.getState();
            if (state === "ERROR") {
                var errors = response.getError();
                let toastParams = {
                    title: "Error",
                    message: errors[0].pageErrors[0].message, 
                    type: "error"
                };
                let toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams(toastParams);
                toastEvent.fire();
            }
        });
        $A.enqueueAction(establecerCheck);
    }
})