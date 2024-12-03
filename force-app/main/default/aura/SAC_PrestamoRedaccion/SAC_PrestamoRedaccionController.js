({	
    doInit: function(component, event, helper){
        
        var idCase = component.get("v.recordId");
        var idPrestamo = component.get("v.selectedLookUpRecord.Id");
        var getCaseAction = component.get("c.devolverCaso");
        var motInadAction = component.get("c.motivoInadmision");
        if(idCase != null && idPrestamo != null && idPrestamo != 'undefined'){
            component.set('v.haySeleccion', true);
            component.set('v.isLoading', true);
            motInadAction.setParams({'recId': idCase, 'prestamoId' : idPrestamo});
            motInadAction.setCallback(this, function(response) {
                var state = response.getState();
                var validation = response.getReturnValue();       
                if (state === "SUCCESS") {
                    if(validation){
                        component.set('v.motivoInad', validation);
						component.set('v.isLoading', false);
                    }
                }else{
                    var errors = response.getError();
                    let toastParams = {
                        title: "Error",
                        message: errors[0].message, 
                        type: "error"
                    };
                    let toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams(toastParams);
                    toastEvent.fire();
                }});
            $A.enqueueAction(motInadAction);
        }else{
            component.set('v.haySeleccion', false);
        }
        getCaseAction.setParams({'id': idCase});
        getCaseAction.setCallback(this, function(response) {
            var state = response.getState();
            var motivo = response.getReturnValue().SAC_MotivoInadmision__c;
            if(motivo != null){
                component.set('v.showEmailSender', true);
            }
            if (state === "SUCCESS") {
                component.set('v.caso', response.getReturnValue());
                component.set('v.fechaRes', response.getReturnValue().OS_Fecha_Resolucion__c);
                var caso = component.get('v.caso');
                component.set('v.metodoEnvio', caso.CC_Canal_Respuesta__c);
                component.set('v.argRes', caso.SAC_MotivoSentidoResolucion__c);
                if(caso.CC_Oficina_Afectada_Lookup__c !== undefined && caso.CC_Oficina_Afectada_Lookup__r.CC_Email__c !== undefined){
                    component.set('v.CCO', caso.CC_Oficina_Afectada_Lookup__r.CC_Email__c);
                }
                var checkPdfAction = component.get("c.compruebaPDFs");
                checkPdfAction.setParams({'id': idCase});
                checkPdfAction.setCallback(this, function(response) {
                    var state = response.getState();
                    if (state === "SUCCESS") {
                        component.set('v.archivoSubido', response.getReturnValue());
                        var permisoAction = component.get("c.recuperarPermiso");
                        permisoAction.setParams({'reclamacion': caso});
                        permisoAction.setCallback(this, function(response){
                            var state = response.getState();
                            if (state === "SUCCESS") {
                                var permisoUsuario = response.getReturnValue();
                                if(permisoUsuario == true){
                                    component.set('v.usarComponente', true);
                                    //obtener info email
                                    var getEmailDataAction = component.get('c.obtenerDatosEmailInadmision');                                    
                                    getEmailDataAction.setParams({'idCaso': component.get("v.recordId")});
                                    getEmailDataAction.setCallback(this, function(response) {
                                        var state = response.getState();
                                        if (state === "SUCCESS") {
                                            var wrapper = response.getReturnValue();
                                            component.set('v.para', wrapper.para );
                                            component.set('v.asunto', wrapper.asunto);
                                            component.set('v.cuerpo', wrapper.cuerpo);
                                            component.set('v.copia', wrapper.copia);
                                            component.set('v.caso', wrapper.caso);
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
                                        }
                                    })
                                    $A.enqueueAction(getEmailDataAction);
                                }
                            }
                        });
                        $A.enqueueAction(permisoAction);
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
                $A.enqueueAction(checkPdfAction);
                if(caso.Status != 'SAC_001' && caso.Status != 'SAC_002'){
                    component.set('v.mensaje', 'El estado de la reclamación debe ser Alta o Análisis.');
                } else if(caso.SAC_FechaRecepcion__c == null){
                    component.set('v.mensaje', 'La fecha de recepción de la reclamación no está informada.');
                } else if(caso.SAC_Entidad_Afectada__c == null || caso.SAC_EntidadProductora__c == null) {
                    component.set('v.mensaje', 'La entidad afectada o la entidad productora de la reclamación no está informada.');
                } else if(caso.SAC_Naturaleza__c != 'SAC_004') {
                    component.set('v.mensaje', 'El campo naturaleza de la reclamación debe ser Reclamación.');
                } else if(caso.CC_Idioma__c == null){
                    component.set('v.mensaje', 'El campo idioma de la reclamación no está informado.');
                }
            }
        });
        $A.enqueueAction(getCaseAction);
    },
    handleApplicationEvent : function(component, event, helper) {
        component.set('v.showEmailSender', event.getParam("showEmailSender"));
    }
})