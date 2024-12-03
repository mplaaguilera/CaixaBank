({
    init: function(component, event, helper) {
        if (component.get("v.renderizar"))
        {
            //Inicializa los campos de volumen
            var inicializarVolumenes = component.get("c.inicializarVolumenes");

            var recordId = component.get("v.recordId");
            if (recordId != undefined) {
                //Se está editando el registro, se dispone de recordId
                inicializarVolumenes.setParams({'recordId': recordId});
            } else {
                //Se está creando el registro, no se dispone de recordId, se extrae el parentRecordId
                var value = helper.getParameterByName(component , event, 'inContextOfRef');
                var context = JSON.parse(window.atob(value));
                component.set("v.parentRecordId", context.attributes.recordId);

                inicializarVolumenes.setParams({'recordId': component.get("v.parentRecordId")});
            }

            inicializarVolumenes.setCallback(this, function(response) {
                if (response.getState() === "SUCCESS") {
                    var mapaVolumenes = response.getReturnValue();
                    component.set('v.llamadasAtendidas', mapaVolumenes.llamadasAtendidas);
                    component.set('v.llamadasAtendidasParcial', mapaVolumenes.llamadasAtendidasParcial);
                    component.set('v.llamadasAbandonadasAnterior', mapaVolumenes.llamadasAbandonadasAnterior);
                    component.set('v.llamadasAbandonadas', mapaVolumenes.llamadasAbandonadasAnterior);
                    component.set('v.llamadasAbandonadasParcial', 0);
                    component.set('v.renderizar', false);
                } else {
                    //alert('Se ha producido un error recuperando el volumen de casos de la actualización de volumen anterior.');
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({ "title": "Error: ", "message": "Se ha producido un error recuperando el volumen de casos de la actualización de volumen anterior.", "type": "error" });
                    toastEvent.fire();
                }
            });
            $A.enqueueAction(inicializarVolumenes);

            //Inicializa la fecha de envío de la última actualización enviada
            var fechaUltimaNotificacion = component.get("c.fechaUltimaNotificacion");
            fechaUltimaNotificacion.setParams({'recordId': component.get("v.parentRecordId")});
            fechaUltimaNotificacion.setCallback(this, function(response) {
                if (response.getState() === "SUCCESS") {
                    component.set('v.fechaUltimoEnvio', response.getReturnValue());
                    component.set('v.cargando', false);
                } else {
                    //alert('Se ha producido un error recuperando el volumen de casos de la actualización de volumen anterior.');
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({ "title": "Error: ", "message": "Se ha producido un error recuperando el volumen de casos de la actualización de volumen anterior.", "type": "error" });
                    toastEvent.fire();
                }
            });
            $A.enqueueAction(fechaUltimaNotificacion);

        }
        
    },

    success: function(component, event, helper) {
        //Mostrar Toast de confirmación
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({ "title": "Success! ", "message": "Se creó Actualización de volumen.", "type": "success" });
        toastEvent.fire();

        //Cerrar pestaña de creación de la actualización de volumen
        let cerrarTab = component.get('c.cerrarTab');
        $A.enqueueAction(cerrarTab);        
    },

    error: function(component, event, helper) {
        var errors = event.getParams();
        console.log("response", JSON.stringify(errors));
        console.log(event.getParam('detail'));
        //alert('Ha habido un problema al guardar el registro de actualización de volumen.');
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({ "title": "Error: ", "message": "Ha habido un problema al guardar el registro de actualización de volumen.", "type": "error" });
        toastEvent.fire();
    },

    actualizarAbandonadasParcial: function(component, event, helper) {
        component.set('v.llamadasAbandonadasParcial', component.get('v.llamadasAbandonadas') - component.get('v.llamadasAbandonadasAnterior'));
    },

    cerrarTab: function(component, event, helper) {
        let workspaceAPI = component.find("workspace");

        //Cerrar pestaña de creación de la actualización de volumen
        workspaceAPI.getFocusedTabInfo()
        .then(responseTabInfo => {
            var parentTabId = responseTabInfo.parentTabId; //Id de la pestaña del agrupador
            workspaceAPI.closeTab({tabId: responseTabInfo.tabId})
            .then(() => {
                //Refrescar pestaña del agrupador
                //workspaceAPI.refreshTab({tabId: parentTabId, includeAllSubtabs: true});  (Este método no funciona)
                $A.get('e.force:refreshView').fire();
            });
        });
    }
})