({
    doInit: function(component, event, helper){

        var idCase = component.get("v.recordId");
        var action4 = component.get("c.compruebaDocumentoRedaccion");
        action4.setParams({'id': idCase});
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

        var action2 = component.get("c.devolverCaso");
         
        action2.setParams({'id': idCase});
        action2.setCallback(this, function(response) {
        var state = response.getState();
        if (state === "SUCCESS") {

            component.set('v.caso', response.getReturnValue());
            if(response.getReturnValue().RecordType.DeveloperName == 'SPV_Reclamacion') {
                component.set('v.usarComponente', true);
                component.set('v.carpetaRaiz', 'SPV_PlantillasRedaccion');
                var action3 = component.get("c.getDocument");
                action3.setParams({'idCaso': idCase});
                action3.setCallback(this, function(response){
                    var state = response.getState();
                    if (state === "SUCCESS") {
                        component.set('v.documentoResolucion', response.getReturnValue());
                    }
                });
                $A.enqueueAction(action3);
            } else {
                component.set('v.carpetaRaiz', 'SAC_PlantillasRedaccion');

            }
        }
        });

        $A.enqueueAction(action2);
    }
    ,

    deshacer: function(component, event, helper) {
        var idCase = component.get("v.recordId");
        var ids = component.get("v.listaIds");
        component.set("v.checkBoton", false);
        var action = component.get("c.updateNombrePDF");
        action.setParams({'archivos': ids, 'id': idCase, 'borrarAnterior': false});
        action.setCallback(this, function(response) {
			var state = response.getState();
            if (state === "SUCCESS") {
                component.set('v.isLoading', false);
                let toastParams = {
					title: "Subida cancelada",
					message: 'Se ha detenido la operación.', 
					type: "success"
				};
				let toastEvent = $A.get("e.force:showToast");
    			toastEvent.setParams(toastParams);
                component.set('v.archivoSubido', true);
    			toastEvent.fire();

			}
			else
			{
				var errors = response.getError();
				let toastParams = {
					title: "Error",
					message: 'Ha ocurrido un error recuperando información de los documentos.', 
					type: "error"
				};
				let toastEvent = $A.get("e.force:showToast");
    			toastEvent.setParams(toastParams);
    			toastEvent.fire();
			}
		});

        $A.enqueueAction(action);
     },

     continuar: function(component, event, helper) {
        var procedencia = component.get('v.procedencia');
        var idCase = component.get("v.recordId");
        var ids = component.get("v.listaIds");
        component.set("v.checkBoton", false);
        var action = component.get("c.updateNombrePDF");
        action.setParams({'archivos': ids, 'id': idCase, 'borrarAnterior': true});
        action.setCallback(this, function(response) {
			var state = response.getState();
            if (state === "SUCCESS") {
                var action2 = component.get('c.getDocument');
                action2.setParams({'idCaso' : idCase, 'idDoc': ids});
                action2.setCallback(this, function(response) {
                    var state = response.getState();
                    if (state === "SUCCESS") {   
                        component.set('v.documentoResolucion', response.getReturnValue());
                    }
                    else{
                        var errors = response.getError();
                        let toastParams = {
                            title: "Error",
                            message: 'Ha ocurrido un error recuperando información de los documentos.', 
                            type: "error"
                        };
                        let toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams(toastParams);
                        toastEvent.fire();
                        $A.get('e.force:refreshView').fire();
                    }
                })

                var appEvent = $A.get("e.c:SAC_PertimiteEmailRedaccion");
                appEvent.setParams({
                    "etapa1" : true,
                    "etapa2" : true,
                    "etapa3" : false, 
                    "checkboxRedaccion" : false,
                    "procedencia" : procedencia});
                appEvent.fire();

                let toastParams = {
					title: "Subida completada",
					message: 'La subida del archivo ha finalizado con éxito.', 
					type: "success"
				};
				let toastEvent = $A.get("e.force:showToast");
    			toastEvent.setParams(toastParams);
                component.set('v.archivoSubido', true);
                component.set('v.isLoading', false);
    			toastEvent.fire();

                $A.enqueueAction(action2);
			}
			else
			{
				var errors = response.getError();
				let toastParams = {
					title: "Error",
					message: 'Ha ocurrido un error recuperando información de los documentos.', 
					type: "error"
				};
				let toastEvent = $A.get("e.force:showToast");
    			toastEvent.setParams(toastParams);
    			toastEvent.fire();
			}
		});

        $A.enqueueAction(action);
     },
    
    handleUploadFinished: function (cmp, event) {
        cmp.set('v.isLoading', true);
        var procedencia = cmp.get('v.procedencia');
        //llamada a apex para realizar la validacion de que las pretensiones esten listas para redaccion informal + validacion escalados completado de forma positiva
        var action = cmp.get("c.validacionRedaccion");
        var action2 = cmp.get("c.borraDocumento");
        var recordId = cmp.get("v.recordId");
        action.setParams({'idCaso' : recordId});
        action2.setParams({'idCaso' : recordId});
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                if(result.pretension === true){
                    var hayArchivo = cmp.get('v.archivoSubido');
                    if(hayArchivo){
                        cmp.set('v.checkBoton', true);
                    }
                    
                    var selectedFile = cmp.get('v.selectedContentVersionId');
                    var arrayIds = [];
                    arrayIds.push(selectedFile);     
                    var appEvent = $A.get("e.c:SAC_PertimiteEmailRedaccion");
                    appEvent.setParams({
                        "etapa1" : true,
                        "etapa2" : true,
                        "etapa3" : false, 
                        "checkboxRedaccion" : false,
                        "procedencia" : procedencia});
                    appEvent.fire();
            
                    cmp.set('v.listaIds', arrayIds);
                    cmp.set('v.archivoSubido', true);
                    cmp.set('v.isLoading', false);
                    cmp.set('v.modalAdjuntar', false);
                    $A.get('e.force:refreshView').fire();
                }
                else if(result.pretension === false){
                    //a falta de eliminar el archivo
                    action2.setCallback(this, function(response) {
                        var state = response.getState();
                        if (state === "SUCCESS") {
                            let toastParams = {
                                title: "Error al preparar la documentación",
                                message: 'No todas las pretensiones están listas para la redacción final.', 
                                type: "error"
                            };
                    
                            let toastEvent = $A.get("e.force:showToast");
                            toastEvent.setParams(toastParams);
                    
                            toastEvent.fire();
                            cmp.set('v.isLoading', false);
                            cmp.set('v.modalAdjuntar', false);
                        }
                    })
                    $A.enqueueAction(action2);
                }
            }
            else{ 
                let toastParams = {
                    title: "Error",
                    message: 'Ha ocurrido un error inesperado al subir el archivo.', 
                    type: "error"
                };
        
                let toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams(toastParams);
        
                toastEvent.fire();
                cmp.set('v.isLoading', false);
            }
        })
        $A.enqueueAction(action);
    },

    previsualizarDoc : function (cmp, event) {
        var idArchivo = cmp.get('v.documentoResolucion').ContentDocumentId;
        $A.get('e.lightning:openFiles').fire({
            recordIds: [idArchivo]
        });
    },

    muestraModalAdjuntar : function(component, event, helper) {
        component.set('v.modalAdjuntar', true);
    },

    ocultaModalAdjuntar : function(component, event, helper) {
        component.set('v.modalAdjuntar', false);
    },

    handleContentVersionSelection: function(component, event, helper) {
        var selectedContentVersionId = event.getSource().get("v.value");
        component.set("v.selectedContentVersionId", selectedContentVersionId);
    },

    receiveLWCDataDocumento: function (cmp, event, helper) {
		cmp.set("v.archivoSubido", event.getParam("dataToSend"));
        eval("$A.get('e.force:refreshView').fire();");
	},

    receiveLWCDataGuardado: function (cmp, event, helper) {
		cmp.set("v.tieneDocGuardado", event.getParam("dataToSend"));
    
	},

    receiveLWCDataGenerar: function (cmp, event, helper) {
		cmp.set("v.tieneDocGuardado", event.getParam("dataToSend"));
        cmp.set("v.archivoSubido", event.getParam("dataToSend"));
        eval("$A.get('e.force:refreshView').fire();");
    
	}
})