({
    init : function(component, event, helper) {        
        
        var getOptions = component.get("c.getPickListValuesIntoList");
        getOptions.setCallback(this, function(response){
            var state = response.getState();
            var initOptions = [];
            component.set('v.options', initOptions);
            var options = component.get('v.options');
            
            if (state === "SUCCESS") {
                let titulos = response.getReturnValue();
                for (var miTitulo in titulos) {
                    var contador = 1;
                    let titulo = titulos[miTitulo];
                    options.push({ label: titulo.nombrePlantilla, value: titulo.idPlantilla });
                    contador = contador + 1;
                }            
                
                component.set('v.options', JSON.parse(JSON.stringify(options)));
                var prueba = component.get('v.options');
                
                var getCaso = component.get('c.recuperarCaso');
                getCaso.setParam('caseId', component.get('v.recordId'));
                
                getCaso.setCallback(this, function(response) {
                    
                    var state = response.getState();
                    if (state === "SUCCESS") {        			
                        component.set('v.caso', response.getReturnValue());
                        component.set('v.accountId', response.getReturnValue().AccountId);
                        component.set('v.metodoEnvio', response.getReturnValue().CC_Canal_Respuesta__c);
                        
                        if(response.getReturnValue().Status == 'SAC_005'){
                            
                            component.set('v.disableGestionar', true); 
                            component.set('v.disableDescartar', true); 
                            component.set('v.disableDerivar', true); 
                            component.set('v.esPropietario', true);
                            component.set('v.esPropietarioLetrado', true);
                            component.set('v.noEsPropietario', false);
                            component.set('v.estaEnLaCola', true);
                        }
                        else{
                            var getUser = component.get('c.recuperarUser');
                            //Get userId
                            getUser.setCallback(this, function(response){                              
                                component.set('v.user', response.getReturnValue().UserId);
                                component.set('v.isGestor', response.getReturnValue().SAC_General != undefined);
                                if(component.get('v.user') === component.get('v.caso.OwnerId')){
                                    component.set('v.esPropietario', true); 
                                    component.set('v.noEsPropietario', false);
                                    component.set('v.estaEnLaCola', false);  
                                }else{
                                    component.set('v.esPropietario', false); 
                                    component.set('v.noEsPropietario', true);
                                    component.set('v.estaEnLaCola', true);
                                }
                                
                                if(response.getReturnValue().UserName === component.get('v.caso.SAC_Letrado__c')){
                                    component.set('v.esPropietarioLetrado', true);
                                }else{
                                    component.set('v.esPropietarioLetrado', false);
                                }
                            });
                            $A.enqueueAction(getUser); 
                        }				
                        component.set('v.showAllButtons',true);
                    }            
                });
                
                $A.enqueueAction(getCaso);
                
            }
        })
        $A.enqueueAction(getOptions);
    },
    
    tomarPropiedadConsulta : function(component, event, helper) {
        
        var idCase = component.get("v.recordId");
        var OwnerId = $A.get('$SObjectType.CurrentUser.Id');
        
        var actValidacionMultiple = component.get("c.multiplesCasosMismoAccountConsulta");
        actValidacionMultiple.setParams({
            'caseId': idCase,  
            'ownerId' : OwnerId
        });
        
        actValidacionMultiple.setCallback(this, function(response) {
            var state = response.getState();
            
            if(state == "SUCCESS") {
                if (response.getReturnValue() && component.get("v.modalSRultiplesCasos") == false)
                {
                    component.set("v.modalSRultiplesCasos", true);
                }
                else{
                    var action = component.get("c.tomarPropiedadCasoConsulta");
                    action.setParams({
                        'caseId': idCase,  
                        'ownerId' : OwnerId
                    });
                    
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "Éxito!",
                        "message": "Se ha cambiado el propietario correctamente.",
                        "type": "success"
                    });
                    
                    action.setCallback(this, function(response) {
                        var state = response.getState();
                        if(state == "SUCCESS") {
                            component.set("v.modalSRultiplesCasos", false);
                            component.set("v.accts", response.getReturnValue());
                            toastEvent.fire();
                            $A.get('e.force:refreshView').fire();
                            helper.reinit(component);
                            
                        }
                        else
                        {
                            var errors = response.getError();
                            let toastParams = {
                                title: "Error",
                                message: errors[0].message, 
                                type: "error"
                            };
                            let toastEvent = $A.get("e.force:showToast");
                            toastEvent.setParams(toastParams);
                            toastEvent.fire();
                            component.set("v.modalSRultiplesCasos", false);
                        }
                    });
                    
                    $A.enqueueAction(action);
                }
            }
        });
        $A.enqueueAction(actValidacionMultiple);
        
    },
    
    abrirModalAdvertenciaDevolverConsulta : function(component, event, helper) {
        
        var idCase = component.get("v.recordId");        
        var OwnerId = $A.get('$SObjectType.CurrentUser.Id');
        
        var actValidacionMultiple = component.get("c.casosMismoAccountAsignadosConsulta");
        actValidacionMultiple.setParams({
            'caseId': idCase,  
            'ownerId' : OwnerId
        });
        
        actValidacionMultiple.setCallback(this, function(response) {
            var state = response.getState();
            
            if(state == "SUCCESS" && response.getReturnValue()) {
                component.set("v.modalAdvertencia", true);
            }
            else{
                helper.fetchMotivos(component,event);
                component.set("v.esDevolverLetrado", false);
                component.set("v.modalCola", true);
                component.set("v.selectedMotivo",null);
            }
        });
        $A.enqueueAction(actValidacionMultiple);
    },
    
    devolverPropiedadLetrado : function(component, event, helper) {
        helper.fetchMotivos(component,event);
        component.set("v.esDevolverLetrado", true);
        component.set("v.modalCola", true);
        component.set("v.selectedMotivo",null);
    },
    
    abrirModalSegBO : function(component, event, helper) {
        helper.fetchMotivos(component,event);      	
        component.set("v.modalAdvertencia", false);
        component.set("v.modalCola", true);
        component.set("v.selectedMotivo",null);
    },
    
    devolverACola: function (component, event, helper) {
        
        component.find("motivosDevlver").reportValidity();
        component.find("observacionId").reportValidity();
        
        if(component.get('v.selectedMotivo')!= null && component.find("observacionId").get("v.value")!= null && component.find("observacionId").get("v.value")!= "" )
        {
            var idCase = component.get("v.recordId");
            var motivos = component.get('v.motivosDevolver');
            var motivo = component.get('v.selectedMotivo');
            var motivoLabel;
            if(motivo!=null){
                motivoLabel = motivos.find(function(item){return item.value == motivo}).label;
            }
            
            if(component.get("v.esDevolverLetrado")){
                component.set("v.isLoading", true);
                var devolver = component.get("c.devolverLetradoConsulta");
                var obserInput = component.find("observacionId").get("v.value");
                var publicar = component.get("c.postOnChatterDevolverLetrado");
                publicar.setParams({ 'caseId': idCase, 'observacion': obserInput, 'motivo': motivoLabel });
                devolver.setParams({ 'caseId': idCase, 'motivo': motivo });
                
                $A.enqueueAction(devolver);
                
                devolver.setCallback(this, function (response) {
                    var state = response.getState();
                    if (state == "SUCCESS") {
                        component.set("v.isLoading", false);
                        component.set("v.esDevolverLetrado", false);
                        component.set("v.modalCola", false);
                        $A.get('e.force:refreshView').fire();
                        helper.reinit(component);
                        component.set("v.modalCola", false);
                        helper.mostrarToast('success', 'Propiedad letrado devuelta', 'La propiedad de letrado de la consulta se ha devuelto a la cola genérica', component);
                    }else{
                        component.set("v.isLoading", false);
                        var errors = response.getError();
                        if (errors && errors[0] && errors[0].message) {
                            helper.mostrarToast('error', 'No se ha podido devolver', 'Error inesperado contacta con el administrador: ' + errors[0].message);
                        }else{
                            helper.mostrarToast('error', 'No se ha podido devolver', 'Error inesperado contacta con el administrador');
                        }
                    }
                });
                
                $A.enqueueAction(publicar);
                
            }else{
                var devolver = component.get("c.devolverCaso");
                var obserInput = component.find("observacionId").get("v.value");
                var publicar = component.get("c.postOnChatter");
                publicar.setParams({ 'caseId': idCase, 'observacion': obserInput, 'motivo': motivoLabel });
                devolver.setParams({ 'caseId': idCase, 'motivo': motivo });
                
                $A.enqueueAction(devolver);
                
                devolver.setCallback(this, function (response) {
                    var state = response.getState();
                    if (state == "SUCCESS") {
                        component.set("v.modalCola", false);
                        $A.get('e.force:refreshView').fire();
                        helper.reinit(component);
                        component.set("v.modalCola", false);
                        helper.mostrarToast('success', 'Consulta devuelta', 'La Consulta se ha devuelto a la cola genérica', component);
                    }else{
                        var errors = response.getError();
                        if (errors && errors[0] && errors[0].message) {
                            helper.mostrarToast('error', 'No se ha podido devolver', 'Error inesperado contacta con el administrador: ' + errors[0].message);
                        }else{
                            helper.mostrarToast('error', 'No se ha podido devolver', 'Error inesperado contacta con el administrador');
                        }
                    }
                });
                
                $A.enqueueAction(publicar);
            }
        }
    },
    modalAsignarDevolverCerrar: function(component){
        component.set("v.esDevolverLetrado", false);
        component.set("v.modalCola", false);
    },
    modalAdvertenciaDevolverCerrar: function(component){
        component.set("v.modalAdvertencia", false);
    },
    derivacion: function(component){
        var flow = component.find("flowData");
        
        var inputVariables = [
            {
                name : "recordId",
                type : "String",
                value: component.get("v.recordId")
            }
        ];
        
        flow.startFlow("SAC_Derivar", inputVariables);
    },
    
    descartar : function(component, event, helper) {
        let origenConsulta = component.get('v.caso').SAC_OrigenConsulta__c;
        var comprobarUsuario = component.get('c.checkUserPermission');  
        var permisoUsuario = false;
        comprobarUsuario.setCallback(this, function (response) {
            var state = response.getState();
            if (state == "SUCCESS") {
                permisoUsuario = response.getReturnValue();
                if((origenConsulta == '' || origenConsulta == null) && !permisoUsuario){
                    let toastEvent = $A.get('e.force:showToast');
                    toastEvent.setParams({'title': 'Fallo al actualizar.', 'message': 'Para gestionar la consulta primero debe de indicar el origen de la misma.', 'type': 'error', 'mode': 'dismissable', 'duration': 4000});
                    toastEvent.fire();
                }
                else{
                    component.set("v.clickDescartar", true);
                }
            }else{
                var errors = response.getError();
                if (errors && errors[0] && errors[0].message) {
                    helper.mostrarToast('error', 'No se ha podido descartar', 'Error inesperado contacta con el administrador: ' + errors[0].message);
                }else{
                    helper.mostrarToast('error', 'No se ha podido descartar', 'Error inesperado contacta con el administrador');
                }
            }
        });
        $A.enqueueAction(comprobarUsuario);
        
        /*
		var idCase = component.get("v.recordId");		
		var descartarConsulta = component.get('c.modificarEstadoCaso');        
		descartarConsulta.setParams({
            'caseId': idCase,  
            'estado' : 'SAC_013' //Descartada
        });

		descartarConsulta.setCallback(this, function (response) {
			var state = response.getState();
			if (state == "SUCCESS") {
				$A.get('e.force:refreshView').fire();
				helper.reinit(component);
				helper.mostrarToast('success', 'Consulta descartada', 'La Consulta se ha descartado correctamente', component);
			}else{
				var errors = response.getError();
				if (errors && errors[0] && errors[0].message) {
					helper.mostrarToast('error', 'No se ha podido descartar', 'Error inesperado contacta con el administrador: ' + errors[0].message);
				}else{
					helper.mostrarToast('error', 'No se ha podido descartar', 'Error inesperado contacta con el administrador');
				}
			}
		});

		
		$A.enqueueAction(descartarConsulta);*/
    },
    
    volver : function(component, event, helper) {
        component.set("v.clickDescartar", false);
        
    },
    
    continuar : function(component, event, helper) {
        component.find("motivoDescarte").reportValidity();
        //alert('mot'+component.get('v.motivoDescarte'));
        //alert('txt'+component.get('v.motivoDescarteTXT'));
        if(component.get('v.motivoDescarte')== 'SAC_Otros')
        {
            component.find("motivoDescarteTXT").reportValidity();
        }
        if(component.get('v.motivoDescarte')!= null)
        {
            if((component.get('v.motivoDescarteTXT') != null && component.get('v.motivoDescarteTXT') != "") || component.get('v.motivoDescarte')!= 'SAC_Otros')
            {
                component.set("v.clickDescartar", false);
                component.set("v.isLoading", true);
                var idCase = component.get("v.recordId");		
                var motivoDescarte = component.get("v.motivoDescarte");
                var descartarConsulta = component.get('c.descartarConsulta');        
                descartarConsulta.setParams({
                    'caseId': idCase,  
                    'estado' : 'SAC_013', //Descartada
                    'motivo' : motivoDescarte
                });
                
                /*if(motivoDescarte!=null){
					motivoLabel = options.find(function(item){return item.value == motivoDescarte}).label;
				}*/
                var options = component.get("v.options");
                var publicar = component.get("c.postOnChatterDescartar");
                publicar.setParams({ 'caseId': idCase, 'observacion': component.get('v.motivoDescarteTXT') , 'motivo': options.find(function(item){return item.value == motivoDescarte}).label });
                
                
                
                descartarConsulta.setCallback(this, function (response) {
                    var state = response.getState();
                    if (state == "SUCCESS") {
                        $A.enqueueAction(publicar);
                        component.set("v.isLoading", false);
                        $A.get('e.force:refreshView').fire();
                        helper.reinit(component);
                        helper.mostrarToast('success', 'Consulta descartada', 'La Consulta se ha descartado correctamente', component);
                    }else{
                        var errors = response.getError();
                        component.set("v.isLoading", false);
                        if (errors && errors[0] && errors[0].message) {
                            helper.mostrarToast('error', 'No se ha podido descartar', 'Error inesperado contacta con el administrador: ' + errors[0].message);
                        }else{
                            helper.mostrarToast('error', 'No se ha podido descartar', 'Error inesperado contacta con el administrador');
                        }
                    }
                });
                
                
                $A.enqueueAction(descartarConsulta);
            }
        }
    },
    
    motivoDescarte : function(component, event, helper) {
        component.set('v.motivoDescarte', event.getParam("value"));
    },
    
    mostrarModalResolver: function(component, event){
        component.set('v.modalResolver', true);
        
    },
    
    ocultarModalResolver: function(component, event){
        component.set('v.modalResolver', false);
    },
    
    mostrarModalResolverEmail: function(component, event){
        var accountId = component.get('v.accountId');
        let noIdentificado = component.get('v.caso').CC_No_Identificado__c;
        let origenConsulta = component.get('v.caso').SAC_OrigenConsulta__c;
        let canalrespuesta = component.get('v.caso').CC_Canal_Respuesta__c;
        
        if(origenConsulta == '' || origenConsulta == null ){
            let toastEvent = $A.get('e.force:showToast');
            toastEvent.setParams({'title': 'Canal entrada.', 'message': 'Para gestionar la consulta primero debe de indicar el origen de la misma.', 'type': 'error', 'mode': 'dismissable', 'duration': 4000});
            toastEvent.fire();
        }else if(canalrespuesta !='Email' && canalrespuesta !='SAC_CartaPostal'){
            let toastEvent = $A.get('e.force:showToast');
            toastEvent.setParams({'title': 'Canal del respuesta.', 'message': 'Compruebe que tenga un canal de respuesta válido.', 'type': 'error', 'mode': 'dismissable', 'duration': 4000});
            toastEvent.fire();
        }
            else{
                if(accountId != undefined || noIdentificado==true){
                    component.set("v.modalResolverEmail", true);
                }else{
                    let toastEvent = $A.get('e.force:showToast');
                    toastEvent.setParams({'title': 'Cliente no informado', 'message': 'Para resolver la consulta es necesario informar el cliente', 'type': 'error', 'mode': 'dismissable', 'duration': 4000});
                    toastEvent.fire();
                }
            }
    },
    ocultarModalResolverEmail: function(component){
        component.set("v.modalResolverEmail", false);
        component.set('v.modalResolver', false);
    },
    handleComponentEvent : function(component, event, helper) {        
        
        var idCase = component.get("v.recordId");
        
        var resolverConsulta = component.get('c.modificarEstadoCaso');        
        resolverConsulta.setParams({
            'caseId': idCase,  
            'estado' : 'SAC_012', //Gestionada
            'motivo' : ''
        });
        resolverConsulta.setCallback(this, function (response) {
            var state = response.getState();
            
            if (state == "SUCCESS") {
                component.set("v.isLoading", false);
                component.set("v.modalResolverEmail", false);
                component.set("v.modalResolver", false);
                $A.get('e.force:refreshView').fire();
                helper.reinit(component);
                helper.mostrarToast('success', 'Consulta Gestionada', 'La Consulta se ha gestionado correctamente', component);
            }else{
                var errors = response.getError();
                component.set("v.isLoading", false);
                if (errors && errors[0] && errors[0].message) {
                    helper.mostrarToast('error', 'No se ha podido gestionar', 'Error inesperado contacta con el administrador: ' + errors[0].message);
                }else{
                    helper.mostrarToast('error', 'No se ha podido gestionar', 'Error inesperado contacta con el administrador');
                }
            }
        });
        
        
        $A.enqueueAction(resolverConsulta);
    }  
    
    ,derivacionModal: function(component){
        var accountId = component.get('v.accountId');
        let noIdentificado = component.get('v.caso').CC_No_Identificado__c;
        let origenConsulta = component.get('v.caso').SAC_OrigenConsulta__c;
        
        if(origenConsulta == '' || origenConsulta == null){
            let toastEvent = $A.get('e.force:showToast');
            toastEvent.setParams({'title': 'Fallo al actualizar.', 'message': 'Para gestionar la consulta primero debe de indicar el origen de la misma.', 'type': 'error', 'mode': 'dismissable', 'duration': 4000});
            toastEvent.fire();
        }
        else{
            if(accountId != undefined || noIdentificado==true){
                component.set("v.derivar", true);
            }else{
                let toastEvent = $A.get('e.force:showToast');
                toastEvent.setParams({'title': 'Cliente no informado', 
                                      'message': 'Para derivar la consulta es necesario informar el cliente', 
                                      'type': 'error',
                                      'mode': 'dismissable',
                                      'duration': 4000});
                toastEvent.fire();
            }
        }
    }
    
    ,cerrarDerivarModal: function(component){
        component.set("v.derivar", false);
    }
    
    
    ,convertirModalConsultaCOPS: function(component){
        let origenConsulta = component.get('v.caso').SAC_OrigenConsulta__c;
        
        if(origenConsulta == '' || origenConsulta == null){
            let toastEvent = $A.get('e.force:showToast');
            toastEvent.setParams({'title': 'Fallo al actualizar.', 'message': 'Para gestionar la consulta primero debe de indicar el origen de la misma.', 'type': 'error', 'mode': 'dismissable', 'duration': 4000});
            toastEvent.fire();
        }
        else{
            component.set("v.modalConvertir", true);
            component.set("v.convertirConsultaCOPS", true);
        }
    },
    
    convertirModalReclamacion: function(component){
        let origenConsulta = component.get('v.caso').SAC_OrigenConsulta__c;
        
        if(origenConsulta == '' || origenConsulta == null){
            let toastEvent = $A.get('e.force:showToast');
            toastEvent.setParams({'title': 'Fallo al actualizar.', 'message': 'Para gestionar la consulta primero debe de indicar el origen de la misma.', 'type': 'error', 'mode': 'dismissable', 'duration': 4000});
            toastEvent.fire();
        }
        else{
            component.set("v.modalConvertir", true);
            component.set("v.convertirReclamacion", true);
        }
    },
    
    cerrarConvertirModal: function(component){
        component.set("v.modalConvertir", false);
    },
    
    
    convertirAReclamacion :  function(component, event, helper){
        component.set("v.isLoading", true);
        component.set("v.modalConvertir", false);
        component.set("v.convertirReclamacion", false);
        component.set("v.convertirConsultaCOPS", false);
        let idConsulta = component.get("v.recordId");
        let resolucion = component.get("c.convertirReclamacion");
        resolucion.setParams({'caseId': idConsulta, 'naturaleza' : 'Reclamacion'});
        resolucion.setCallback(this, function (response) {
            var state = response.getState();
            
            if (state == "SUCCESS") {
                $A.get('e.force:refreshView').fire();
                
                component.set("v.isLoading", false);
                helper.mostrarToast('success', 'Consulta gestionada', 'La Consulta ha sido convertida.', component);
            }
            else{
                $A.get('e.force:refreshView').fire();
                component.set("v.isLoading", false);
                helper.mostrarToast('error', 'Error al gestionar la consulta', 'La Consulta no ha sido convertida.', component);
            }
            
        });
        $A.enqueueAction(resolucion);
    },
    
    
    convertirAConsultaSAC :  function(component, event, helper){
        component.set("v.isLoading", true);
        component.set("v.modalConvertir", false);
        component.set("v.convertirReclamacion", false);
        component.set("v.convertirConsultaCOPS", false);
        let idConsulta = component.get("v.recordId");
        let resolucion = component.get("c.convertirReclamacion");
        resolucion.setParams({'caseId': idConsulta, 'naturaleza' : 'Consulta'});
        resolucion.setCallback(this, function (response) {
            var state = response.getState();
            
            if (state == "SUCCESS") {
                $A.get('e.force:refreshView').fire();
                
                component.set("v.isLoading", false);
                helper.mostrarToast('success', 'Consulta gestionada', 'La Consulta ha sido convertida.', component);
            }
            else{
                $A.get('e.force:refreshView').fire();
                component.set("v.isLoading", false);
                helper.mostrarToast('error', 'Error al gestionar la consulta', 'La Consulta no ha sido convertida.', component);
            }
            
        });
        $A.enqueueAction(resolucion);
    },
    
    openModalECOPS : function(component, event, helper) {
        var accountId = component.get('v.accountId');
        let noIdentificado = component.get('v.caso').CC_No_Identificado__c;
        let origenConsulta = component.get('v.caso').SAC_OrigenConsulta__c;
        
        if(origenConsulta == '' || origenConsulta == null){
            let toastEvent = $A.get('e.force:showToast');
            toastEvent.setParams({'title': 'Fallo al actualizar.', 'message': 'Para gestionar la consulta primero debe de indicar el origen de la misma.', 'type': 'error', 'mode': 'dismissable', 'duration': 4000});
            toastEvent.fire();
        }
        else{
            if(accountId != undefined || noIdentificado==true){
                component.set("v.isModalOpenECOPS", "true");
                var textarea = component.find("motivoEscaladoCOPS");
                textarea.focus();
            }else{
                let toastEvent = $A.get('e.force:showToast');
                toastEvent.setParams({'title': 'Cliente no informado', 
                                      'message': 'Para escalar la consulta es necesario informar el cliente', 
                                      'type': 'error',
                                      'mode': 'dismissable',
                                      'duration': 4000});
                toastEvent.fire();
            }
        }
    },
    closeModalECOPS : function(component, event, helper) {
        component.set("v.motivoEscaladoCOPS","");
        component.set("v.isModalOpenECOPS", "false");
    },
    setEscaladoCOPS : function(component, event, helper) {
        var idCase = component.get("v.recordId");
        let motivoEscaladoCOPS = component.get("v.motivoEscaladoCOPS");
        if (motivoEscaladoCOPS != '' && motivoEscaladoCOPS != null)
        {
            var escalarCOPS = component.get('c.escalarCOPS');        
            escalarCOPS.setParams({
                'caseId': idCase,  
                'motivo' : motivoEscaladoCOPS
            });
            escalarCOPS.setCallback(this, function (response) {
                var state = response.getState();
                
                if (state == "SUCCESS") {
                    component.set("v.isLoading", false);
                    component.set("v.modalResolverEmail", false);
                    component.set("v.isModalOpenECOPS", "false");
                    component.set("v.motivoEscaladoCOPS","");
                    $A.get('e.force:refreshView').fire();
                    helper.reinit(component);
                    helper.mostrarToast('success', 'Consulta escalada', 'La Consulta se ha escalado a COPS correctamente', component);
                    
                    
                    
                }else{
                    var errors = response.getError();
                    component.set("v.isLoading", false);
                    if (errors && errors[0] && errors[0].message) {
                        helper.mostrarToast('error', 'No se ha podido gestionar', 'Error inesperado contacta con el administrador: ' + errors[0].message);
                    }else{
                        helper.mostrarToast('error', 'No se ha podido gestionar', 'Error inesperado contacta con el administrador');
                    }
                }
            });
            
            
            $A.enqueueAction(escalarCOPS);
            component.set("v.isModalOpenECOPS", "false");
        }
        else
        {
            var textarea = component.find("motivoEscaladoCOPS");
            textarea.reportValidity();
            
        }
    },
    openModalDCOPS : function(component, event, helper) {
        component.set("v.isModalOpenDCOPS", "true");
    },
    closeModalDCOPS : function(component, event, helper) {
        component.set("v.motivoEscaladoCOPS","");
        component.set("v.isModalOpenDCOPS", "false");
    },
    setDevolucionEscalado : function(component, event, helper) {
        var idCase = component.get("v.recordId");
        let motivoEscaladoCOPS = component.get("v.motivoEscaladoCOPS");
        if (motivoEscaladoCOPS != '' && motivoEscaladoCOPS != null)
        {
            var escalarCOPS = component.get('c.retornarEscaladoConsulta');        
            escalarCOPS.setParams({
                'caseId': idCase,  
                'motivo' : motivoEscaladoCOPS
            });
            escalarCOPS.setCallback(this, function (response) {
                var state = response.getState();
                
                if (state == "SUCCESS") {
                    component.set("v.isLoading", false);
                    component.set("v.isModalOpenDCOPS", "false");
                    component.set("v.motivoEscaladoCOPS","");
                    helper.mostrarToast('success', 'Consulta devuelta', 'La Consulta se ha devuelto al grupo original', component);
                    $A.get('e.force:refreshView').fire();
                    helper.reinit(component);
                }else{
                    var errors = response.getError();
                    component.set("v.isLoading", false);
                    if (errors && errors[0] && errors[0].message) {
                        helper.mostrarToast('error', 'No se ha podido gestionar', 'Error inesperado contacta con el administrador: ' + errors[0].message);
                    }else{
                        helper.mostrarToast('error', 'No se ha podido gestionar', 'Error inesperado contacta con el administrador');
                    }
                }
            });
            
            
            $A.enqueueAction(escalarCOPS);
            component.set("v.isModalOpenDCOPS", "false");
        }
        else
        {
            var textarea = component.find("motivoDEscaladoCOPS");
            textarea.reportValidity();
            
        }
    },
    
    modalReabrir: function (component) {
        component.set("v.reabrir", true);
    },
    
    cerrarModalReabrir: function (component) {
        component.set("v.reabrir", false);
    },
    
    reabrir : function(component, event, helper) {
        component.find("motivoId").reportValidity();
        
        if(component.find("motivoId").get("v.value")!= null && component.find("motivoId").get("v.value")!= ""){
            component.set("v.reabrir", false);
            component.set("v.isLoading", true);
            var idCase = component.get("v.recordId");
            var motivoReabrir = component.find("motivoId").get("v.value");
            var reabrirAct = component.get("c.reabrirConsulta");
            reabrirAct.setParams({ 'caseId': idCase, 'motivoReabrir' : motivoReabrir });
            reabrirAct.setCallback(this, function (response) {
                var state = response.getState();
                if (state == "SUCCESS") {
                    component.set("v.isLoading", false);
                    
                    $A.get('e.force:refreshView').fire();
                    helper.reinit(component);
                    helper.mostrarToast('success', 'Consulta reabierta', 'La Consulta ha vuelto a su estado anterior', component);
                    
                }
                else{
                    component.set("v.isLoading", false);
                    
                    helper.mostrarToast('error', 'Error al reabrir la consulta', 'La Consulta no puede volver a su estado anterior', component);
                }
                
            })
            
            $A.enqueueAction(reabrirAct);
            
            component.find("motivoId").set("v.value", '');
        }
    },
    
    finalizar :  function(component, event, helper){
        component.set("v.isLoading", true);
        component.set("v.modalResolverEmail", false);
        component.set("v.modalResolver", false);
        let idConsulta = component.get("v.recordId");
        let resolucion = component.get("c.resolverCartaPostal");
        resolucion.setParams({'idCaso': idConsulta});
        resolucion.setCallback(this, function (response) {
            var state = response.getState();
            
            if (state == "SUCCESS") {
                $A.get('e.force:refreshView').fire();
                
                component.set("v.isLoading", false);
                helper.mostrarToast('success', 'Consulta gestionada', 'La Consulta ha sido resuelta.', component);
            }
            else{
                $A.get('e.force:refreshView').fire();
                component.set("v.isLoading", false);
                helper.mostrarToast('error', 'Error al gestionar la consulta', 'La Consulta no ha sido resuelta.', component);
            }
            
        });
        $A.enqueueAction(resolucion);
    },
    
    finalizarSinContactar:  function(component, event, helper){
        let idConsulta = component.get("v.recordId");
        let origenConsulta = component.get('v.caso').SAC_OrigenConsulta__c;
        //alert('id' + idConsulta);
        if(origenConsulta == '' || origenConsulta == null){
            let toastEvent = $A.get('e.force:showToast');
            toastEvent.setParams({'title': 'Canal entrada.', 'message': 'Para gestionar la consulta primero debe de indicar el origen de la misma.', 'type': 'error', 'mode': 'dismissable', 'duration': 4000});
            toastEvent.fire();
        } else {
            component.set("v.isLoading", true);
            component.set("v.modalResolverEmail", false);
            component.set("v.modalResolver", false);
            let resolucion = component.get("c.modificarEstadoCaso");
            resolucion.setParams({'caseId': idConsulta, 'estado': 'SAC_012', 'motivo': null});
            resolucion.setCallback(this, function (response) {
                var state = response.getState();
                
                if (state == "SUCCESS") {
                    $A.get('e.force:refreshView').fire();
                    
                    component.set("v.isLoading", false);
                    helper.mostrarToast('success', 'Consulta gestionada', 'La Consulta ha sido resuelta.', component);
                }
                else{
                    $A.get('e.force:refreshView').fire();
                    component.set("v.isLoading", false);
                    var errors = response.getError();
                    //alert(JSON.stringify(errors));
                    helper.mostrarToast('error', 'Error al gestionar la consulta', 'La Consulta no ha sido resuelta.', component);
                }
                
            });
            $A.enqueueAction(resolucion);
        }
    },
    
    tomarPropiedadLetrado : function(component, event, helper) {
        
        var idCase = component.get("v.recordId");
        var OwnerId = $A.get('$SObjectType.CurrentUser.Id');
        
        var action = component.get("c.tomarPropiedadLetradoConsulta");
        action.setParams({
            'caseId': idCase,  
            'ownerId' : OwnerId
        });
        
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": "Éxito!",
            "message": "Se ha cambiado el propietario letrado correctamente.",
            "type": "success"
        });
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(state == "SUCCESS") {
                toastEvent.fire();
                $A.get('e.force:refreshView').fire();
                helper.reinit(component);
            }
            else
            {
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
    }
})