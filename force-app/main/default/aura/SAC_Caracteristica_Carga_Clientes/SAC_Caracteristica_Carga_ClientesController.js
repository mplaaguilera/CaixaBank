({

    Inicial : function(component, event, helper) {

        var idCaracteristica = component.get("v.recordId");

        var getCaracteristica = component.get("c.recuperarCaracteristica");
        getCaracteristica.setParam("caracteristicaId", idCaracteristica);

        getCaracteristica.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var caractActual = response.getReturnValue();

                if(caractActual.RecordType.DeveloperName == 'SAC_CaracteristicaRepresentante'){
                    component.set('v.caractRepresentante', true); 
                    component.set('v.tituloCard', 'Cargar CIFs/despachos'); 
                }else if(caractActual.RecordType.DeveloperName == 'SAC_CaracteristicaClienteCuenta'){
                    component.set('v.caractCliente', true); 
                    component.set('v.tituloCard', 'Cargar cuentas'); 
                }

            }else{
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    title: 'Error',
                    message: 'Error al recuperar la información de la característica',
                    type: 'error'
                });
                toastEvent.fire();
            }
        });

        $A.enqueueAction(getCaracteristica);
    },

	handleClickCancelar : function(component, event, helper) {
        $A.get("e.force:closeQuickAction").fire(); 
    },

	handleClickAceptar : function(component, event, helper) {
        $A.get('e.force:refreshView').fire();
        $A.get("e.force:closeQuickAction").fire(); 

        if(component.get('v.caractRepresentante')){
            component.set('v.comunicarCargaRepresentantes', true);
        }
    },

	handleShowLogToast : function(component, event, helper) {
        var myData = event.getParam('myData');
        var logUrl = myData[0];
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            mode: 'sticky',
            title: 'Carga finalizada',
            message: 'Informe',
            type: 'success',
            key: 'utility:check',
            messageTemplate: 'Descargue el informe {0}',
            messageTemplateData: [
                {
                    url: logUrl,
                    label: 'aquí'
                }
            ]
        });
        toastEvent.fire();
    } 
})