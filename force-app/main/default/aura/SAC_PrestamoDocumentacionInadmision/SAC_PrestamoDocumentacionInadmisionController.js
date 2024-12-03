({
    doInit: function(component, event, helper){
        var idCase = component.get("v.recordId");
        var action4 = component.get("c.compruebaDocumentoInadmision");
        action4.setParams({'caseId': idCase});
        action4.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS"){
                var docGuardado = response.getReturnValue();
                if(docGuardado == true){
                    component.set('v.tieneDocGuardado', true);
                }
            }
            else{
                var errors = response.getError();
                let toastParams = {
                    title: "Error",
                    message: 'Ha ocurrido un error al recuperar documentos.', 
                    type: "error"
                };
                let toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams(toastParams);
                toastEvent.fire();
            }
        });
        $A.enqueueAction(action4);
        helper.fetchCVRespuesta(component);
    },
 
    visualizarDocumento : function(component, event, helper) {
        var idCase = component.get("v.recordId");
        var action = component.get("c.visualizarDocumentoInadmision");
        action.setParams({'caseId': idCase});
        action.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS"){
                var urlResponse = response.getReturnValue();
                window.open(urlResponse, '_blank');
            }else{
                var errors = response.getError();
                let toastParams = {
                    title: "Error",
                    message: 'Ha ocurrido un error al recuperar documentos.', 
                    type: "error"
                };
                let toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams(toastParams);
                toastEvent.fire();
            }
        });
        $A.enqueueAction(action);
    },
    generarDocumento : function(component, event, helper) {
        var idCase = component.get("v.recordId");
        var caso = component.get("v.caso");
        var motivoInad = component.get("v.motivo");
        var action4 = component.get("c.generarDocumentoInadmision");
        action4.setParams({'caseId': idCase, 'idioma': caso.CC_Idioma__c, 'motivoInadmision': motivoInad});
        action4.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS"){
                component.set('v.tieneDocGuardado', true);
                let toastParams = {
                    title: "Success",
                    message: 'Se ha generado el documento de inadmisión.', 
                    type: "success"
                };
                let toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams(toastParams);
                toastEvent.fire();
            }
            else{
                var errors = response.getError();
                let toastParams = {
                    title: "Error",
                    message: 'Ha ocurrido un error al recuperar documentos.', 
                    type: "error"
                };
                let toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams(toastParams);
                toastEvent.fire();
            }
        });
        $A.enqueueAction(action4);
        $A.get("e.force:refreshView").fire();
        helper.fetchCVRespuesta(component);
    }
})