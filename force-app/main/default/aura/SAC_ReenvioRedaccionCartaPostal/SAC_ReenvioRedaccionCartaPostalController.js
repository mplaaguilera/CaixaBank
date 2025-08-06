({
    doInit : function(component, event, helper) {
        var action = component.get('c.obtenerDatosDireccion');
        var idCase = component.get('v.recordId');
        action.setParams({'idCaso':component.get('v.recordId')});
        action.setCallback(this, function(response) {
            var state = response.getState();
            
            if(state === 'SUCCESS'){                
                
                var wrapper = response.getReturnValue();
                console.log('wrapper ' + wrapper.pais);

                component.set('v.direccion', wrapper.direccion );
                component.set('v.poblacion', wrapper.poblacion);
                component.set('v.codigoPostal', wrapper.codigoPostal);
                component.set('v.provincia', wrapper.provincia);                
                component.set('v.pais', wrapper.pais);

                let paises = wrapper.opcionesPais;
                var options = component.get('v.options');
                
                for (var miPais in paises) {
                    let pais = paises[miPais];
                    options.push({ label: pais.nombrePlantilla, value: pais.idPlantilla });
                }       
                
                component.set('v.options', JSON.parse(JSON.stringify(options)));

            }
            else{
                var errors = response.getError();
                let toastParams = {
                    title: "Error",
                    message: errors[0].pageErrors[0].message, 
                    type: "error"
                };
                let toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams(toastParams);
                toastEvent.fire();
                $A.get('e.force:refreshView').fire();
            }
        })
    
        $A.enqueueAction(action);
    },


    reenviarRedaccion : function(component, event, helper) { 
        component.set("v.confirmarOperacion", false);
        component.set('v.isLoading', true);
        let idsFicherosAdjuntos = component.get("v.idsFicherosAdjuntos");
        console.log('CGR idsFicherosAdjuntos', JSON.stringify(idsFicherosAdjuntos));
        var action = component.get("c.reenvioRedaccionCartaPostal");
        console.log('Carta postal');
        action.setParams({'idCaso':component.get("v.recordId"), 'newDireccion':component.get("v.direccion"), 'newPoblacion':component.get("v.poblacion"), 'newProvincia':component.get("v.provincia"), 'newCodigoPostal':component.get("v.codigoPostal"), 'newPais':component.get("v.pais"), 'idAdjuntos': JSON.stringify(idsFicherosAdjuntos)});
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set('v.isLoading', false);
                $A.get('e.force:refreshView').fire(); 

                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Éxito!",
                    "message": "Se ha reenviado la redacción correctamente.",
                    "type": "success"
                });
                toastEvent.fire();
                let navService = component.find("navService");
                var pageReference = {
                    type: 'standard__recordPage',
                    attributes: {
                        objectApiName: 'SAC_Accion__c',
                        actionName: 'view',
                        recordId: response.getReturnValue()
                    },
                };
                navService.navigate(pageReference);
            }else{
                component.set('v.isLoading', false);

                var errors = response.getError();
                let toastParams = {
                    title: "Error",
                    message: errors[0].message, 
                    type: "error"
                };

                let toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams(toastParams);
                toastEvent.fire();                
            }
        });
        $A.enqueueAction(action);

    },

    cambiaPoblacion : function(component, event, helper) {
        component.set('v.poblacion', event.getParam("value"));
    },

    cambiaProvincia : function(component, event, helper) {
        component.set('v.provincia', event.getParam("value"));
    },

    cambiaDireccion : function(component, event, helper) {
        component.set('v.direccion', event.getParam("value"));
    },

    cambiaCP : function(component, event, helper) {
        component.set('v.codigoPostal', event.getParam("value"));
    },

    cambioPais: function (cmp, event) {
        cmp.set('v.paisSeleccionado', event.getParam("value"));
    },

    receiveLWCDataDocumento: function (cmp, event, helper) {
		cmp.set("v.archivoSubido", event.getParam("dataToSend"));
        eval("$A.get('e.force:refreshView').fire();");
	},


    abrirConfirmarOperacion :function(component, event, helper) {
        component.set("v.editarReenvio", false);
        component.set('v.confirmarOperacion', true);
    },
    cerrarConfirmarOperacion :function(component, event, helper) {
        component.set('v.confirmarOperacion', false);
    },

    abrirEditarReenvio : function(component, event, helper) {      	
		component.set("v.editarReenvio", true);
	},

    cerrarEditarReenvio : function(component, event, helper) {      	
		component.set("v.editarReenvio", false);
	}

})