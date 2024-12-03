({
    doInit : function(component, event, helper) {

        var action = component.get("c.recuperarCaseInfo");
        action.setParams({ caseId : component.get("v.recordId") });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                let respuesta =  response.getReturnValue();
                
                component.set('v.ultimaActualizacion', respuesta.caso.SAC_FechaUltimaSolicitud__c);
                component.set('v.antecedentesRevisados',  respuesta.caso.SAC_Antecedentes_Revisados__c);

                if(respuesta.caso.SAC_FechaUltimaSolicitud__c === null || respuesta.caso.SAC_FechaUltimaSolicitud__c === undefined){
                    helper.buscarAntecedentes(component, event, helper);
                }
                
                if(respuesta.userOwner === true || respuesta.esCOPSAJ === true){
                    component.set('v.permisosEditar',  true);
                }
            } else {
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
        $A.enqueueAction(action);
	},
    
    buscarAntecedentes : function(component, event, helper) {

        helper.buscarAntecedentes(component, event, helper);

    },

    guardar : function(component, event, helper) {
        helper.setCheckRevisados(component, event);
    }
})