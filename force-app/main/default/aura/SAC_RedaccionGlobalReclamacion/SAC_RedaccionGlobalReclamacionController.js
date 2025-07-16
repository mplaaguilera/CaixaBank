({
    doInit: function(component, event, helper){
        var idCase = component.get("v.recordId");
        var action = component.get("c.devolverCaso");
        var tieneContratos;
        
        action.setParams({'id': idCase});
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {

                component.set('v.caso', response.getReturnValue());
                component.set('v.fechaRes', response.getReturnValue().OS_Fecha_Resolucion__c);

                var caso = component.get('v.caso');
                //component.set('v.procedencia', caso.Status);
                component.set('v.metodoEnvio', caso.CC_Canal_Respuesta__c);

                var sentido = caso.SAC_SentidoResolucion__c;
                var argumento = caso.SAC_MotivoSentidoResolucion__c;
                var motivoInadmision = caso.SAC_MotivoInadmision__c;
                if(sentido == 'SAC_004'){
                    component.set('v.procedencia', 'Inadmision');
                    component.set('v.esInadmision', true);
                    component.set('v.motivoInad', motivoInadmision);

                }else{
                    component.set('v.procedencia', caso.Status);
                    component.set('v.esInadmision', false);
                }

                if(caso.CC_Oficina_Afectada_Lookup__c !== undefined && caso.CC_Oficina_Afectada_Lookup__r.CC_Email__c !== undefined){
                    component.set('v.CCO', caso.CC_Oficina_Afectada_Lookup__r.CC_Email__c);
                }

                var procedencia = component.get("v.procedencia");

                if(caso.Status === 'Cerrado' || caso.Status === 'SAC_004'){
                    var actionRedaccionCliente = component.get("c.comprobarComunicacionRedaccionCliente");
                    
                    actionRedaccionCliente.setParams({'id': idCase, 'metodoEnvio': caso.CC_Canal_Respuesta__c});
                    actionRedaccionCliente.setCallback(this, function(response) {
                        var state = response.getState();
                        if (state === "SUCCESS") {
                            component.set('v.comunicacionCliente', response.getReturnValue());
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
                        }
                    });

                    $A.enqueueAction(actionRedaccionCliente);
                }else{
                    var act = component.get("c.compruebaPDFs");
                    act.setParams({'id': idCase});
                    act.setCallback(this, function(response) {
                        var state = response.getState();
                        if (state === "SUCCESS") {
                            component.set('v.archivoSubido', response.getReturnValue());
                            if(response.getReturnValue()){
                                var appEvent = $A.get("e.c:SAC_PertimiteEmailRedaccion");
                                appEvent.setParams({
                                    "etapa1" : true,
                                    "etapa2" : true,
                                    "etapa3" : false, 
                                    "checkboxRedaccion" : false,
                                    "procedencia" : procedencia });
                                appEvent.fire();
                            }else{           
                                var appEvent = $A.get("e.c:SAC_PertimiteEmailRedaccion");
                                appEvent.setParams({
                                    "etapa1" : true,
                                    "etapa2" : false,
                                    "etapa3" : false, 
                                    "checkboxRedaccion" : false,
                                    "procedencia" : procedencia });
                                appEvent.fire();
                            }
                            
                            
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

                                    component.set('v.argRes', argumento);
                                    component.set('v.senRes', sentido);

                                    var action3 = component.get("c.recuperarPermiso");
                                    action3.setParams({'reclamacion': caso});
                                    var arg = component.get('v.argRes');
                                    var sen = component.get('v.senRes');
                                    var etp2 = component.get('v.etapa2');
                                    
                                    if(typeof arg !== "undefined" && typeof sen !== "undefined" && etp2 == true){
                                        
                                        var appEvent = $A.get("e.c:SAC_PertimiteEmailRedaccion");
                                        appEvent.setParams({
                                            "etapa1" : true,
                                            "etapa2" : true,
                                            "etapa3" : true, 
                                            "checkboxRedaccion" : false,
                                            "procedencia" : procedencia});
                                        appEvent.fire();
                                    }
                                    
                                    action3.setCallback(this, function(response){
                                        var state = response.getState();
                                        if (state === "SUCCESS") {
                                            var permisoUsuario = response.getReturnValue();
                                            if(caso.Status == 'SAC_003' && permisoUsuario == true){
                                                component.set('v.usarComponente', true);
                                                
                                                //Comprobar si las pretensiones tienen contratos activos
                                                var action6 = component.get('c.getContratoPretension');
                                                action6.setParams({'idCaso' : idCase});
                                                action6.setCallback(this, function(response) {
                                                    var state = response.getState();
                                                    if(state === "SUCCESS"){
                                                        if(response.getReturnValue() === true){
                                                            component.set('v.tieneContratos', false);
                                                            component.set('v.mensaje', 'La reclamación debe tener dado de alta al menos un contrato en cada una de sus pretensiones');
                                                        }else{
                                                            component.set('v.tieneContratos', true);
                                                        }
                                                    }
                                                })
                                                $A.enqueueAction(action6);
                                                                    
                                                var action5 = component.get('c.getDocument');
                                                action5.setParams({'idCaso' : idCase});
                                                action5.setCallback(this, function(response) {
                                                    var state = response.getState();
                                                    if (state === "SUCCESS") {       
                                                        component.set('v.documentoResolucion', response.getReturnValue());

                                                        //obtener info 
                                                        var action4 = component.get('c.obtenerDatosEmail');
                                                        action4.setParams({'idCaso': component.get("v.recordId"), 'soloEmail': false});
                                                        action4.setCallback(this, function(response) {
                                                            var state = response.getState();
                                                            if (state === "SUCCESS") {
                                                                
                                                                var wrapper = response.getReturnValue();
                                                                component.set('v.para', wrapper.para );
                                                                component.set('v.asunto', wrapper.asunto);
                                                                component.set('v.cuerpo', wrapper.cuerpo);
                                                                component.set('v.copia', wrapper.copia);

                                                                component.set('v.caso', wrapper.caso);
                                                                component.set('v.ficherosAdjuntos', wrapper.adjuntos);

                                                        
                                                            }
                                                            else{
                                                                var errors = response.getError()
                                                                let toastParams;
                                                                
                                                                if(errors[0].message){
                                                                    toastParams = {
                                                                        title: "Error",
                                                                        message: errors[0].message, 
                                                                        type: "error"
                                                                    };
                                                                }else{
                                                                    toastParams = {
                                                                        title: "Error",
                                                                        message: errors[0].pageErrors[0].message, 
                                                                        type: "error"
                                                                    };
                                                                }
                                                                let toastEvent = $A.get("e.force:showToast");
                                                                toastEvent.setParams(toastParams);
                                                                toastEvent.fire();
                                                            }
                                                        })

                                                        $A.enqueueAction(action4);
                                                    }
                                                    else{
                                                        
                                                        var errors = response.getError();
                                                            let toastParams;
                                                            if(errors[0].message){
                                                                toastParams = {
                                                                title: "Error",
                                                                message: errors[0].message, 
                                                                type: "error"
                                                                };
                                                            }else{
                                                                toastParams = {
                                                                title: "Error",
                                                                message: errors[0].pageErrors[0].message, 
                                                                type: "error"
                                                                    };
                                                            }
                                                        let toastEvent = $A.get("e.force:showToast");
                                                        toastEvent.setParams(toastParams);
                                                        toastEvent.fire();
                                                    }
                                                })
                                                $A.enqueueAction(action5);

                                                //obtener info 
                                                var action4 = component.get('c.obtenerDatosEmail');
                                                action4.setParams({'idCaso': component.get("v.recordId"), 'soloEmail': false});
                                                action4.setCallback(this, function(response) {
                                                    var state = response.getState();
                                                    if (state === "SUCCESS") {
                                                        var wrapper = response.getReturnValue();
                                                        component.set('v.para', wrapper.para );
                                                        component.set('v.asunto', wrapper.asunto);
                                                        component.set('v.cuerpo', wrapper.cuerpo);
                                                        component.set('v.copia', wrapper.copia);

                                                        component.set('v.caso', wrapper.caso);
                                                        component.set('v.ficherosAdjuntos', wrapper.adjuntos);

                                                        
                                                    }
                                                    else{
                                                        var errors = response.getError();
                                                        let toastParams;
                                                        
                                                        if(errors[0].message){
                                                            toastParams = {
                                                            title: "Error",
                                                            message: errors[0].message, 
                                                            type: "error"
                                                            };
                                                        }else{
                                                            toastParams = {
                                                            title: "Error",
                                                            message: errors[0].pageErrors[0].message, 
                                                            type: "error"
                                                                };
                                                        }
                                                        let toastEvent = $A.get("e.force:showToast");
                                                        toastEvent.setParams(toastParams);
                                                        toastEvent.fire();
                                                    }
                                                })

                                                $A.enqueueAction(action4);
            
                                            }
                                        }

                                    });
                                    $A.enqueueAction(action3);
                                }
                            });
                
                            $A.enqueueAction(action2);
                        
                            var action7 = component.get("c.getPickListMotivoInadmision");
                            action7.setCallback(this, function(response){
                                var state = response.getState();
                                var optionsMotivo = component.get('v.optionsMotivo');

                                if (state === "SUCCESS") {
                                    let motivos = response.getReturnValue();
                                    for (var miMotivo in motivos) {
                                        let motivo = motivos[miMotivo];
                                        optionsMotivo.push({ label: motivo.nombrePlantilla, value: motivo.idPlantilla });
                                    }            
                                    component.set('v.optionsMotivo', JSON.parse(JSON.stringify(optionsMotivo)));
                                }
                            });
                            $A.enqueueAction(action7);
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
                    $A.enqueueAction(act);
                    
                    if(caso.SAC_FechaRecepcion__c == null){
                        component.set('v.mensaje', 'La fecha de recepción de la reclamación no está informada');
                    } else if(caso.SAC_Entidad_Afectada__c == null || caso.SAC_EntidadProductora__c == null) {
                        component.set('v.mensaje', 'La entidad afectada o la entidad productora de la reclamación no está informada');
                    } else if(caso.SAC_Naturaleza__c == null) {
                        component.set('v.mensaje', 'El campo naturaleza de la reclamación no está informado');
                    }else{
                        //Validaciones Escalado
                        var actionVal = component.get("c.validacionEscalado");
                    
                        actionVal.setParams({'idCaso': idCase});
                        actionVal.setCallback(this, function(response) {
                            var state = response.getState();
                            if (state === "SUCCESS") {      
                                var result = response.getReturnValue();                  
                                component.set('v.validacionEscalado', result.validacionesEscalados.escalado);
                                component.set('v.validacionEscaladoPresi', result.validacionesEscalados.presidencia);
                                component.set('v.validacionLlamadaSeguimiento', result.validacionLlamada);
                                component.set('v.mensaje', result.validacionesEscalados.mensaje);
                            }
                            else{
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
                        $A.enqueueAction(actionVal);
                    }  
                }  
            }
        });

        $A.enqueueAction(action);
    },

    handleApplicationEvent : function(component, event, helper) {
        component.set('v.etapa2', event.getParam("etapa2") );
        component.set('v.etapa3', event.getParam("etapa3") );
    },

    finalizar :  function(component, event, helper){
        component.set("v.isLoading", true);
		let id = component.get("v.recordId");
        let finalizarRedaccion = component.get("c.finalizarRedaccionCartaPostal");
        finalizarRedaccion.setParams({'idCaso' : id});
        finalizarRedaccion.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
				$A.get('e.force:refreshView').fire();
                component.set("v.isLoading", false);
                toastEvent.setParams({
                    'title': 'Redacción finalizada', 
                    'message': 'La reclamación avanza al siguiente estado ejecutando sus acciones pertinentes', 
                    'type': 'success', 
                    'mode': 'dismissable', 
                    'duration': 4000});
                toastEvent.fire();
            }
            else{
				$A.get('e.force:refreshView').fire();
                component.set("v.isLoading", false);
                var errors = response.getError();

                let toastParams;
                if(errors[0].message){
                    toastParams = {
                    title: "Error",
                    message: errors[0].message, 
                    type: "error"
                    };
                }else{
                    toastParams = {
                    title: "Error",
                    message: errors[0].pageErrors[0].message, 
                    type: "error"
                        };
                }

                let toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams(toastParams);
                toastEvent.fire();
            }
        });
        $A.enqueueAction(finalizarRedaccion);

	}
})