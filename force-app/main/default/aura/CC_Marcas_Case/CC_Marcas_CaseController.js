/* eslint-disable no-undef */
({
    doInit: function(component, event, helper) {
        // Recuperar ID del caso
        let recordId = component.get("v.recordId");
        if (recordId == undefined) {
            //Se está creando el registro, no se dispone de recordId, se extrae el parentRecordId
            var value = helper.getParameterByName('inContextOfRef');            
            if(value != null || value != undefined){              
                var context = JSON.parse(window.atob(value));
                component.set("v.recordId", context.attributes.recordId);                
                //Iniciar carga Combobox
                helper.getDatosCaso(component);
            }else{
                window.history.back();
            }        	
        }        
    },

    submit: function(component) {
        //Envío de la petición de creación
        component.set('v.spinner', true);
    },

    success: function(component, event, helper) {
        //Abrir nueva pestaña con la marca recién creado
        helper.mostrarToast('success', 'Se vinculó marca al caso', 'Se vinculó correctamente la marca seleccionada al caso.');
        let retorno = event.getParams();
        component.set('v.recordId', retorno.response.id);
        $A.enqueueAction(component.get('c.cerrarTab'));
        component.set('v.spinner', false);
    },

    error: function(component, event, helper) {
        //Error en la creación
        let errors = event.getParams();
        helper.mostrarToast('error', 'No se pudo vincular la marca al caso', JSON.stringify(errors));
        component.set('v.spinner', false);
    },

    cerrarTab: function(component) {
        //Cerrar pestaña actual
        let workspaceAPI = component.find("workspace");
        workspaceAPI.getFocusedTabInfo()
        .then(response => workspaceAPI.closeTab({'tabId': response.tabId}))
        .then(() => $A.get('e.force:refreshView').fire());
    },

    handleLoad: function(cmp) {
        cmp.set("v.spinner", false);
    },
            
    handleOptionSelected: function(cmp, event) {
        cmp.set("v.idMarca", event.getParam("value"));
    }
})