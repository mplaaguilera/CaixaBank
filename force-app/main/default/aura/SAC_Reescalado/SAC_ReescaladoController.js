({
    doInit : function(component, event, helper) {

        var action2 = component.get("c.getPickListValuesIntoList");
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

                var adjuntosEscalado = component.get('c.obtieneAdjuntos');
                adjuntosEscalado.setParams({'id': component.get("v.recordId")});
                adjuntosEscalado.setCallback(this, function(response) {
                    var state2 = response.getState();
                    if(state2 === 'SUCCESS'){
                        let ficherosAdjuntos = response.getReturnValue();
                        component.set('v.ficherosAdjuntos', ficherosAdjuntos);
                    }
                    else{
                        var errors2 = response.getError();
                        let toastParams = {
                            title: "Error",
                            message: errors2[0].pageErrors[0].message, 
                            type: "error"
                        };
                    let toastEvent2 = $A.get("e.force:showToast");
                    toastEvent2.setParams(toastParams);
                    toastEvent2.fire();
                    $A.get('e.force:refreshView').fire();
                    }
                })
                $A.enqueueAction(adjuntosEscalado);

            }
            else{                 
                var errors = action2.getError();
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
    },

    valorMotivo: function (cmp, event) {
        cmp.set('v.motivo', event.getParam("value"));
    },

    reescalar : function(component, event, helper) {
         
        var action = component.get("c.insertReescalado");
        var propuestaCops = component.find("propuestaCops").get("v.value");
        var observaciones = component.find("observaciones").get("v.value");
        var motivo = component.get("v.motivo");
        let button = component.find('buttonEscaladoId');
        button.set('v.disabled',true);

        if (motivo != null && propuestaCops != null && motivo != '' && propuestaCops != '') {
            action.setParams({interaccionId : component.get("v.recordId"), 'porpuestaCops' : propuestaCops, 'motivo' : motivo, 'observaciones' : observaciones});
            //publicar.setParams({ 'caseId': idCase, 'observacion': obserInput, 'motivo': motivoLabel });

            
            action.setCallback(this, function(response){
                var state = response.getState();
                if (state === "SUCCESS") { 
                    let idReescalado = response.getReturnValue();
                    component.set('v.idReescalado', idReescalado);
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        title: 'Re escalado creado',
                        message: 'Se ha re escalado con éxito!',
                        type: 'success'
                    });
                    toastEvent.fire();
                }
                else{                 
                    var errors = action.getError();
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        title: 'Fallo en el re escalado',
                        message: errors[0].message,
                        type: 'error'
                    });
                    toastEvent.fire();
                }
                // var dismissActionPanel = $A.get("e.force:closeQuickAction");
                // dismissActionPanel.fire();
                // eval("$A.get('e.force:refreshView').fire();");
                component.set("v.adjuntos", true);
            });
            $A.enqueueAction(action);
        } else {
            let toastParams = {
                title: "Precaución",
                message: "Recuerde completar la propuesta y el motivo.", 
                type: "warning"
            };
            let toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams(toastParams);
            toastEvent.fire();
            eval("$A.get('e.force:refreshView').fire();");
        }
    },

    cerrarAction : function(component, event, helper) {
        var dismissActionPanel = $A.get("e.force:closeQuickAction");
        dismissActionPanel.fire();
        eval("$A.get('e.force:refreshView').fire();");
    },

    handleUploadFinished: function (component, event) {
        var recordId = component.get("v.recordId");
        var copiarArchivo = component.get("c.insertarAdjuntoCaso");
        copiarArchivo.setParams({'interaccionId' : recordId});
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
    }

})