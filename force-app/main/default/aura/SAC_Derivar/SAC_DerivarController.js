({
    doInit : function(component, event, helper) {

        //Recupera el caso
        let tieneCuenta = component.get('c.getCaso');
        tieneCuenta.setParams({'caseId': component.get("v.recordId")});
        tieneCuenta.setCallback(this, function(response) {
			let state = response.getState();
            if (state === "SUCCESS") {
                let respuesta = response.getReturnValue();
                component.set('v.caso', respuesta);
                component.set('v.metodoEnvio', respuesta.CC_Canal_Respuesta__c);
                if(respuesta.AccountId !== undefined){
                    if(respuesta.Account.Name !== undefined){
                        component.set('v.nombreClientePostal', respuesta.Account.Name);
                    }
                    if(respuesta.Account.BillingCity !== undefined){
                        component.set('v.direccionEnvioPostal', respuesta.Account.BillingCity);
                    }
                    if(respuesta.Account.BillingStreet !== undefined){
                        component.set('v.callePostal', respuesta.Account.BillingStreet);
                    }
                    if(respuesta.Account.BillingPostalCode !== undefined){
                        component.set('v.codigoPostal', respuesta.Account.BillingPostalCode);
                    }
                }
            }
            else{
                let errors = response.getError();
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

        //Traer los grupos que tienen el check de permite derivación
        let buscarGrupos = component.get('c.buscarGrupos');
        buscarGrupos.setCallback(this, function(response) {
			let state = response.getState();
            if (state === "SUCCESS") {
                let respuestaGrupos = response.getReturnValue();
                component.set('v.grupos', respuestaGrupos);
                component.set('v.options', respuestaGrupos);

                $A.enqueueAction(tieneCuenta);
            }
            else{
                let errors = response.getError();
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

        helper.doInitStartHelper(component);
        $A.enqueueAction(buscarGrupos);
    }

    ,cerrarModalDerivacion : function(component, event, helper) {
        component.set('v.derivar', false);
    }

    ,siguientePantalla : function(component, event, helper) {
        var numeroPagina = component.get("v.numeroPantalla");
        component.find("inputLookup").reportValidity();
        if(component.get('v.activarBuscadorOficinas') === true){
            component.find("miCampoOficina").reportValidity();
        }
        if((component.get('v.activarBuscadorOficinas') === false && component.find("inputLookup").get("v.value")!= null && component.find("inputLookup").get("v.value")!= "") || (component.get('v.activarBuscadorOficinas') === true && component.find("inputLookup").get("v.value")!= null && component.find("inputLookup").get("v.value")!= "" && component.find("miCampoOficina").get("v.value")!= null && component.find("miCampoOficina").get("v.value")!= "")){
            if(numeroPagina === 1) {
                //traer plantillas mirando que tipo de caso es
                var actionGetPlantillas = component.get('c.getPlantillas');
                actionGetPlantillas.setParams({'grupoSeleccionado': component.get("v.grupoAbuscarId"), 'caseRecordType': component.get("v.caso.RecordType.DeveloperName"), 'caseId': component.get("v.recordId") });    
                actionGetPlantillas.setCallback(this, function(response) {
                    var state = response.getState();
                    if (state === "SUCCESS") {
                        var wrapper = response.getReturnValue();
                        component.set('v.idTemplateGrupo', wrapper.idTemplate);

                        //No tiene oficina en la derivacion
                        if(component.get('v.activarBuscadorOficinas') === false){
                            //Establecemos el para con el mail del grupo
                            component.set('v.paraGrupo', wrapper.paraTemplate);
                        }else if(component.get('v.activarBuscadorOficinas') === true){
                            //Establecemos el para con el mail de la oficina
                            if(component.get('v.emailOficina') === undefined || component.get('v.emailOficina') === ''){
                                component.set('v.paraGrupo', '');
                                let toastParams = {
                                    title: "Precaución",
                                    message: 'La oficina seleccionada no tiene un email asociado', 
                                    type: "warning"
                                };
                                let toastEvent = $A.get("e.force:showToast");
                                toastEvent.setParams(toastParams);
                                toastEvent.fire();
                            }else{
                                component.set('v.paraGrupo', component.get('v.emailOficina'));
                            } 
                        }

                        component.set('v.asuntoGrupo', wrapper.subjectTemplate);
                        component.set('v.cuerpoGrupo', wrapper.htmlValueTemplate);
                        component.set('v.nombreGrupoSeleccionado', wrapper.nombreGrupo);
                        component.set('v.idGrupoSeleccionado', wrapper.idGrupo);
                    }
                    else{
                        component.set('v.idTemplateGrupo', '');
                        component.set('v.paraGrupo', '');
                        component.set('v.asuntoGrupo', '');
                        component.set('v.cuerpoGrupo', '');
                        component.set('v.nombreGrupoSeleccionado', '');
                        component.set('v.idGrupoSeleccionado', '');

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
                $A.enqueueAction(actionGetPlantillas); 
            }
            numeroPagina = numeroPagina + 1;
            component.set("v.numeroPantalla", numeroPagina);
        }
    }

    ,anteriorPantalla : function(component, event, helper) {

        component.set("v.cerrar", 0);
        component.set("v.mostrarGrupos", false);
        var numeroPagina = component.get("v.numeroPantalla");       
        
        var enviaMailCliente = component.get('v.confirmEmailCliente');
        if (numeroPagina === 5) {
            if (enviaMailCliente === true) {
                numeroPagina = numeroPagina - 1;
            } else {
                numeroPagina = numeroPagina - 2;
            }
        } else {
            numeroPagina = numeroPagina - 1;    
        }
        component.set("v.numeroPantalla", numeroPagina);

        let pantalla = '';
        if(numeroPagina === 2){
            pantalla = 'cuerpoGrupo';
        }else if(numeroPagina === 4){
            pantalla = 'cuerpoCliente';
        }

        helper.cargarTagsImgCuerpo(component, pantalla, false); 
    }

    ,negarEmailReclamante : function(component, event, helper) {
        var numeroPagina = component.get("v.numeroPantalla");
        numeroPagina = numeroPagina + 2;
        component.set("v.numeroPantalla", numeroPagina);
        component.set("v.confirmEmailCliente", false);
    }

    ,confirmarEmailReclamante : function(component, event, helper) {
        var numeroPagina = component.get("v.numeroPantalla");
        //Llamada a apex para recoger la plantilla del cliente
        var actionGetPlantillaCliente = component.get('c.getPlantillaReclamante');
        actionGetPlantillaCliente.setParams({'grupoSeleccionado': component.get("v.idGrupoSeleccionado"), 'caseId': component.get("v.recordId")});
        actionGetPlantillaCliente.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var wrapper = response.getReturnValue();
                component.set('v.idTemplateCliente', wrapper.idTemplate);
                component.set('v.paraCliente', wrapper.paraTemplate);
                component.set('v.asuntoCliente', wrapper.subjectTemplate);
                component.set('v.cuerpoCliente', wrapper.htmlValueTemplate);
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
        $A.enqueueAction(actionGetPlantillaCliente);
        //Avanzar a la siguiente página y poner en true que se ha querido notificar al cliente
        numeroPagina = numeroPagina + 1;
        component.set("v.numeroPantalla", numeroPagina);
        component.set("v.confirmEmailCliente", true);
    }

    ,validarEnvioGrupo : function(component, event, helper) {
       
        var grupoSeleccionado = component.get("v.nombreGrupoSeleccionado");
        var paraGrupo = component.get("v.paraGrupo");
        if(grupoSeleccionado == null || grupoSeleccionado == ''){
            let toastParams = {
                title: "Error",
                message: "Debe seleccionar un grupo válido para continuar", 
                type: "Error"
            };
            let toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams(toastParams);
            toastEvent.fire();
        }else {
            if (paraGrupo == null || paraGrupo == '') {
                let toastParams = {
                title: "Precaución",
                message: "Recuerde completar la dirección de correo", 
                type: "warning"
                };
                let toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams(toastParams);
                toastEvent.fire();
            } else {
                //US723742 - Raúl Santos - 05/03/2024 - Añadir lógica envio emails blackList. Comprueba si los emails son correctos. Si son correctos continua el proceso, sino muestra mensaje informativo
                helper.comprobarEmails(component, event);
            }
        }
    }

    ,validarEnvioCliente : function(component, event, helper) {
        
        var paraCliente = component.get("v.paraCliente");
        let canalRespuesta = component.get("v.metodoEnvio");
        var hayCarta = false;

        if(canalRespuesta == 'SAC_CartaPostal'){
            var validarDocDerivacion = component.get('c.validarDocDerivacionCliente');
            validarDocDerivacion.setParams({'caseId': component.get("v.recordId")});
            validarDocDerivacion.setCallback(this, function(response) {
                var state = response.getState();

                if (state === "SUCCESS") {
                    hayCarta = response.getReturnValue();

                    if(!hayCarta){
                        let toastParams = {
                            title: "Precaución",
                            message: "Debe generar una carta antes de continuar", 
                            type: "warning"
                        };
                        let toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams(toastParams);
                        toastEvent.fire();
                    }else{
                        // helper.comprobarEmails(component, event);
                        var numeroPagina = component.get("v.numeroPantalla");
                        numeroPagina = numeroPagina + 1;
                        component.set("v.numeroPantalla", numeroPagina);
                    }
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
            $A.enqueueAction(validarDocDerivacion);
        }        

        if(canalRespuesta == 'Email') {

            if(paraCliente == null || paraCliente == ''){
                let toastParams = {
                    title: "Precaución",
                    message: "Recuerde completar la dirección de correo", 
                    type: "warning"
                };
                let toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams(toastParams);
                toastEvent.fire();
            }else{
                //US723742 - Raúl Santos - 05/03/2024 - Añadir lógica envio emails blackList. Comprueba si los emails son correctos. Si son correctos continua el proceso, sino muestra mensaje informativo
                helper.comprobarEmails(component, event);
            }
        } 
    }

    ,handleBlur : function( component, event, helper ){
        helper.handleBlurHelper(component, event);
    }

    ,mostrarOpciones : function( component, event, helper ) {
        var disabled = component.get("v.disabled");
        component.set('v.value', component.get('v.grupoAbuscar'));
      
        if(!disabled) {
            component.set("v.mensaje", '');
            var options;

            component.set("v.mostrarGrupos", true);
            component.set('v.grupoAbuscar', '');
            component.set('v.grupoAbuscarId', '');
            options = component.get("v.options");
            
            options.forEach( function(element,index) {
                element.isVisible = true;
            });

            component.set("v.options", options);
            if(!$A.util.isEmpty(component.get('v.options'))) {
                $A.util.addClass(component.find('gruposCombobox'),'slds-is-open');
            } 
        }
    }

    ,seleccionarGrupo : function( component, event, helper ) {
        if(!$A.util.isEmpty(event.currentTarget.id)) {
            helper.seleccionarGrupoHelper(component, event);
        }
    }

    ,seleccionarOficina : function( component, event, helper ) {

        component.set('v.oficinaSeleccionada', '');
        component.set('v.emailOficina', '');
        component.set('v.paraGrupo', '');

        //Traer la oficina de la org
        let buscarOficinas = component.get('c.buscarOficina');
        buscarOficinas.setParams({'idOficina': component.get("v.idOfiSeleccionada")[0]});
        buscarOficinas.setCallback(this, function(response) {
            
            let state = response.getState();
            if (state === "SUCCESS") {
                let respuestaOficinas = response.getReturnValue();

                respuestaOficinas.forEach(element => {
                    component.set('v.oficinaSeleccionada', element.Name);
                    component.set('v.emailOficina', element.CC_Email__c);
                });
            }
            else{
                let errors = response.getError();
                let toastParams = {
                    title: "Error",
                    message: errors[0].message, 
                    type: "error"
                };
                let toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams(toastParams);
                toastEvent.fire();
            }
        })

        $A.enqueueAction(buscarOficinas);

   
    }

    ,filtroBusqueda : function( component, event, helper ) {

        if( !$A.util.isEmpty(component.get('v.grupoAbuscar')) ) {
            // Una vez borrado, poder volver a buscar escribiendo
            if(component.get("v.mostrarGrupos") === false){
                component.set("v.mostrarGrupos", true);
            }
            component.set("v.cadenaVacia", false);
            component.set("v.cerrar", 0);
            helper.filtroBusquedaHelper(component);
        } else {
            if(component.get("v.cerrar") === 0 && component.get("v.cadenaVacia") === false){ 
                component.set("v.cerrar", 1);
                var options = component.get("v.options");
                options.forEach( function(element,index) {
                    element.isVisible = true;
                });
                component.set("v.options", options);
                if(!$A.util.isEmpty(component.get('v.options'))) {
                    $A.util.addClass(component.find('gruposCombobox'),'slds-is-open');
                } 
            }else{
                component.set("v.cerrar", 0);
                component.set("v.mostrarGrupos", false);
                component.set("v.value", '');
                component.set("v.cadenaVacia", false);
            }
        }    
    }

    ,finalizarDerivar : function(component, event, helper) {
        component.set("v.isLoading", true);
        let idsFicherosAdjuntosGrupoFinal = [];
        let idsFicherosAdjuntosClienteFinal = [];

        idsFicherosAdjuntosGrupoFinal = component.get("v.idsFicherosAdjuntosGrupo");
        idsFicherosAdjuntosClienteFinal = component.get("v.idsFicherosAdjuntosCliente");

        // Si al derivar se trata de un grupo oficina, concatenamos en el campo 'nombreGrupoSeleccionado' el grupo seleccionado seguido de la oficina seleccionada.
        // Para al finalizar la derivación rellenar el campo SAC_DerivadoA__c del objeto caso de la siguiente forma -> Grupo / Oficina
        var derivarA;

        if(component.get("v.activarBuscadorOficinas") === true){
            derivarA = component.get('v.nombreGrupoSeleccionado') + ' / ' + component.get('v.oficinaSeleccionada');
        }else{
            derivarA = component.get('v.nombreGrupoSeleccionado');
        }

        helper.cargarTagsImgCuerpo(component, 'cuerpoGrupo', false);        

        var envioCliente = component.get("v.confirmEmailCliente");
        var actionfinalizarDerivacion = component.get('c.finalizarDerivacion');
        actionfinalizarDerivacion.setParams({'caseId': component.get("v.recordId"),'para': component.get("v.paraGrupo"),'copia': component.get("v.CC"), 'copiaOculta': component.get("v.CCO"),'cuerpo': component.get("v.cuerpoGrupo"),'asunto': component.get("v.asuntoGrupo"), 'idsAdjuntos' : JSON.stringify(idsFicherosAdjuntosGrupoFinal), 'grupoSeleccionado' : derivarA});
        actionfinalizarDerivacion.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                //Si se ha decidido mandar email al cliente, se hace la llamada al método que lo envía
                let canalRespuesta = component.get("v.metodoEnvio");
                if (envioCliente === true && canalRespuesta === 'Email') {

                    helper.cargarTagsImgCuerpo(component, 'cuerpoCliente', false);

                    var actionEmailCliente = component.get('c.enviarEmailCliente');
                    actionEmailCliente.setParams({'caseId': component.get("v.recordId"),'paraCliente': component.get("v.paraCliente"),'copiaCliente': component.get("v.CCCliente"), 'copiaClienteOculta': component.get("v.CCOCliente"), 'cuerpoCliente': component.get("v.cuerpoCliente"),'asuntoCliente': component.get("v.asuntoCliente"), 'idsAdjuntos' : JSON.stringify(idsFicherosAdjuntosClienteFinal)});
                    actionEmailCliente.setCallback(this, function(response) {
                        var state = response.getState();
                        if (state === "SUCCESS") {
                            //Mostrar toast de éxito
                            let toastParams = {
                                title: "Éxito",
                                message: 'Se ha realizado la derivación con éxito', 
                                type: "success"
                            };
                            let toastEvent = $A.get("e.force:showToast");
                            toastEvent.setParams(toastParams);
                            toastEvent.fire();
                            component.set("v.isLoading", false);
                            component.set('v.derivar', false);
                            $A.get('e.force:refreshView').fire();
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
                    $A.enqueueAction(actionEmailCliente);
                } else if (envioCliente === true && canalRespuesta === 'SAC_CartaPostal'){
                    var actionCartaCliente = component.get("c.crearCartaPostalCV");
                    actionCartaCliente.setParams({'caseId': component.get("v.recordId")});
                    actionCartaCliente.setCallback(this, function(response) {
                        var state = response.getState();                        

                        if (state === "SUCCESS") {
                            //Mostrar toast de éxito
                            let toastParams = {
                                title: "Éxito",
                                message: 'Se ha realizado la derivación con éxito', 
                                type: "success"
                            };
                            let toastEvent = $A.get("e.force:showToast");
                            toastEvent.setParams(toastParams);
                            toastEvent.fire();
                            component.set("v.isLoading", false);
                            component.set('v.derivar', false);
                            $A.get('e.force:refreshView').fire();

                            let navService = component.find("navService");
                            var pageReference = {
                                type: 'standard__recordPage',
                                attributes: {
                                    objectApiName: 'SAC_Accion__c',
                                    actionName: 'view',
                                    recordId: response.getReturnValue()
                                }
                            };
                            navService.navigate(pageReference);
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
                    $A.enqueueAction(actionCartaCliente);
                } else{
                     //Mostrar toast de éxito
                     let toastParams = {
                        title: "Éxito",
                        message: 'Se ha realizado la derivación con éxito', 
                        type: "success"
                    };
                    let toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams(toastParams);
                    toastEvent.fire();
                    component.set("v.isLoading", false);
                    component.set('v.derivar', false);
                    $A.get('e.force:refreshView').fire();

                }
            } else {
                var errors = response.getError();

                let mensageError;
                if(errors[0].message) {
                    mensageError = errors[0].message;
                } else if(errors[0].pageErrors[0].message) {
                    mensageError = errors[0].pageErrors[0].message;
                }

                let toastParams = {
                    title: "Error",
                    message: mensageError, 
                    type: "error"
                };
                let toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams(toastParams);
                toastEvent.fire();
                component.set("v.isLoading", false);
                component.set('v.derivar', false);
                $A.get('e.force:refreshView').fire();
            }
        })
        $A.enqueueAction(actionfinalizarDerivacion);
    }
})