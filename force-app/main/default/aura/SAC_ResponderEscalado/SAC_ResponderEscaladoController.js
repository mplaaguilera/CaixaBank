({
    doInit : function(component, event, helper) {
            var action2 = component.get("c.getPickListValuesIntoListConclusion");
            action2.setCallback(this, function(response){
                var state = response.getState();
                var options = component.get('v.options');
                if (state === "SUCCESS") { 
                    let titulos = response.getReturnValue();
                    for (var miTitulo in titulos) {
                        let titulo = titulos[miTitulo];
                        options.push({ label: titulo.nombrePlantilla, value: titulo.idPlantilla });
                    }            
    
                    component.set('v.options', JSON.parse(JSON.stringify(options)));
                }
                else{                 
                    var errors = action.getError();
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        title: 'No se ha podido recuperar el campo motivo',
                        message: errors[0].message,
                        type: 'error'
                    });
                    toastEvent.fire();
                }
            });
            $A.enqueueAction(action2);
            var action = component.get("c.getEscalado");
            action.setParams({interaccionId : component.get("v.recordId")});
            action.setCallback(this, function(response){
                var state = response.getState();
                if (state === "SUCCESS") { 
                   const escalado = response.getReturnValue();

                   if(escalado){
                        if(escalado.SAC_Estado__c == 'SAC_Borrador'){
                            if(escalado.SAC_ImporteAutorizado__c) {
                                component.set("v.importe", escalado.SAC_ImporteAutorizado__c);
                            } 
                            if(escalado.SAC_Respuesta__c) {
                                component.set("v.valorRespuesta", escalado.SAC_Respuesta__c);
                            } 
                            if(escalado.SAC_Conclusion__c) {
                                component.set("v.conclusion", escalado.SAC_Conclusion__c);
                            } 
                        }
                   }
                }
                else{                 
                    var errors = action.getError();
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        title: 'Fallo al recuperar el escalado',
                        message: errors[0].message,
                        type: 'error'
                    });
                    toastEvent.fire();
                }
            });
            $A.enqueueAction(action);
    },

    cerrarAction : function(component, event, helper) {
        var dismissActionPanel = $A.get("e.force:closeQuickAction");
        dismissActionPanel.fire();
        eval("$A.get('e.force:refreshView').fire();");
    },

    handleUploadFinished: function (component, event) {
        // Crear una lista con los ContentVersionId de los archivos cargados
        let uploadedFiles = event.getParam("files");
        let contentVersionIds = [];
        uploadedFiles.forEach(function (file) {
            contentVersionIds.push(file.contentVersionId);
        });

        var recordId = component.get("v.recordId");
        var copiarArchivo = component.get("c.insertarAdjuntoCaso");
        copiarArchivo.setParams({'interaccionId' : recordId , 'listaContentVersionIds' : contentVersionIds});
        copiarArchivo.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS") { 

                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Éxito!",
                    "message": "Los archivos se han subido con éxito.",
                    "type": "success"
                });
                toastEvent.fire(); 
                
            }
        });
        $A.enqueueAction(copiarArchivo);
    },
    
    valorConclusion: function (cmp, event) {
        cmp.set('v.conclusion', event.getParam("value"));
    },
    // valorImporte: function (cmp, event) {
    //     cmp.set('v.importe', event.getParam("value"));
    // },
    responder : function(component, event, helper){

        var action = component.get("c.responderEscalado");
        //var importe = component.get("v.importe");
        var respuesta = component.get('v.valorRespuesta');
        var conclusion = component.get("v.conclusion");
        
        //if (importe != null && respuesta != null && conclusion != '' && respuesta != '') {
        if (respuesta != null && conclusion != '' && respuesta != '') {
            //action.setParams({interaccionId : component.get("v.recordId"), 'conclusion' : conclusion, 'importe' : importe, 'respuesta' : respuesta});
            action.setParams({interaccionId : component.get("v.recordId"), 'conclusion' : conclusion, 'respuesta' : respuesta});
            action.setCallback(this, function(response){
                var state = response.getState();
                if (state === "SUCCESS") { 
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        title: 'Escalado respondido',
                        message: 'Se ha respondido el escalado con éxito!',
                        type: 'success'
                    });
                    toastEvent.fire();
                }
                else{                 
                    var errors = action.getError();
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        title: 'Fallo al responder el escalado',
                        message: errors[0].message,
                        type: 'error'
                    });
                    toastEvent.fire();
                }
                var dismissActionPanel = $A.get("e.force:closeQuickAction");
                dismissActionPanel.fire();
                eval("$A.get('e.force:refreshView').fire();");
            });
            $A.enqueueAction(action);
        } else {
            let toastParams = {
                title: "Precaución",
                //message: "Recuerde completar el importe, la conclusión y la respuesta.", 
                message: "Recuerde completar la conclusión y la respuesta.", 
                type: "warning"
            };
            let toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams(toastParams);
            toastEvent.fire();
        }
    },

    guardarEscalado : function(component, event, helper){

        var action = component.get("c.guardarUnEscalado");
        //var importe = component.get("v.importe");
        var respuesta = component.get('v.valorRespuesta');
        var conclusion = component.get("v.conclusion");
        
            //action.setParams({interaccionId : component.get("v.recordId"), 'conclusion' : conclusion, 'importe' : importe, 'respuesta' : respuesta});
            action.setParams({interaccionId : component.get("v.recordId"), 'conclusion' : conclusion, 'respuesta' : respuesta});
            action.setCallback(this, function(response){
                var state = response.getState();
                if (state === "SUCCESS") { 
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        title: 'Escalado Guardado',
                        message: 'Se ha guardado su escalado con éxito!',
                        type: 'success'
                    });
                    toastEvent.fire();
                }
                else{                 
                    var errors = action.getError();
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        title: 'Fallo al Guardar el escalado',
                        message: errors[0].message,
                        type: 'error'
                    });
                    toastEvent.fire();
                }
                var dismissActionPanel = $A.get("e.force:closeQuickAction");
                dismissActionPanel.fire();
                eval("$A.get('e.force:refreshView').fire();");
            });
            $A.enqueueAction(action);
    }
})