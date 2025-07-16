({
    doInit : function(component, event, helper) {
        var action = component.get('c.obtieneAdjuntos');
        var idCase = component.get('v.caso.Id');
        action.setParams({'id':component.get('v.caso.Id')});
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(state === 'SUCCESS'){
                let ficherosAdjuntos = response.getReturnValue();
                let ficherosBorrados = component.get('v.ficherosBorrados');
                //NGM
                //No mostramos los elementos que han sido borrados previamente en esta ejecución
                for(let i = 0; i < ficherosBorrados.length; i++){
                    for(let j = 0; j < listaNombres.length; j++){
                        if(listaNombres[j].Id == ficherosBorrados[i]){
                            listaNombres.splice(j, 1);
                        }
                    }
                }
                component.set('v.ficherosAdjuntos', ficherosAdjuntos);

                // US670077 cuando se cargan los adjuntos de la reclamacion automaticamente en la derivación, evitar que entre por aqui
                if(component.get('v.adjuntosDerivar') === false){
                    let idsFicherosAdjuntos = [];
                    ficherosAdjuntos.forEach(file => idsFicherosAdjuntos.push((file.contentVersionId)));
                    component.set('v.idsFicherosAdjuntos', idsFicherosAdjuntos);
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
                $A.get('e.force:refreshView').fire();
            }
        })

        $A.enqueueAction(action);
    },

    cambiaPara : function(component, event, helper) {
        component.set('v.para', event.getParam("value"));
    },

    cambiaCopia : function(component, event, helper) {
        component.set('v.copia', event.getParam("value"));
    },

    cambiaCopiaOculta : function(component, event, helper) {
        component.set('v.copiaOculta', event.getParam("value"));
    },

    cambiaAsunto : function(component, event, helper) {
        component.set('v.asunto', event.getParam("value"));
    },

    muestraModal : function(component, event, helper) {
        var para = component.get("v.para");        
        if(para != null){
            component.set('v.modalValidar', false);
            component.set('v.muestraModal', true);
        }else{
            let toastParams = {
                title: "Precaución",
                message: "Recuerde completar la dirección de correo.", 
                type: "warning"
            };
            let toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams(toastParams);
            toastEvent.fire();
        }        
    },

    ocultaModal : function(component, event, helper) {
        component.set('v.muestraModal', false);
    },

    muestraModalValidar : function(component, event, helper) {
        let procedencia = component.get('v.procedencia');
        if(procedencia == 'SAC_003' || procedencia == 'Inadmision') {
            var action = component.get('c.getDocumentRedaccion');
            action.setParams({'id':component.get('v.caso.Id')});
            action.setCallback(this, function(response) {
                    var state = response.getState();
                    if(state === 'SUCCESS'){
                        let nonValidatedItems = [];
                        let returnValues = response.getReturnValue();
                        if (Array.isArray(returnValues)) {
                            returnValues.forEach(function(item) {
                                if(item.SAC_ValidadoCV__c == false){
                                    nonValidatedItems.push(item);
                                }
                            });
                        }
                        if(nonValidatedItems.length > 0 ){
                            component.set('v.modalValidar', true);
                        }else{
                            component.set('v.muestraModal', true);
                        }
                    }
                });
            $A.enqueueAction(action);
        } else {
            component.set('v.muestraModal', true);
        }
    },
    
    ocultaModalValidar : function(component, event, helper) {
        component.set('v.modalValidar', false);
    },

    handleUploadFinished : function(component, event, helper) {
        var action = component.get('c.obtieneAdjuntos');
        action.setParams({'id':component.get('v.caso.Id')});
        action.setCallback(this, function(response) {
			var state = response.getState();
            if(state === 'SUCCESS'){

                //Controlamos que los documentos subidos esta ejecución sean los únicos que se puedan borrar del sistema
                let uploadedFiles = event.getParam("files");
                let documentosSubidosEstaEjecucion = component.get('v.documentosSubidosEstaEjecucion');
                let listaNombres = response.getReturnValue();
                let ficherosBorrados = component.get('v.ficherosBorrados');
               
                uploadedFiles.forEach(file => {
                    documentosSubidosEstaEjecucion.push((file.contentVersionId));
                });

                component.set('v.documentosSubidosEstaEjecucion', documentosSubidosEstaEjecucion);

                //NGM
                //No mostramos los elementos que han sido borrados previamente en esta ejecución
                for(let i = 0; i < ficherosBorrados.length; i++){
                    for(let j = 0; j < listaNombres.length; j++){
                        if(listaNombres[j].Id == ficherosBorrados[i]){
                            listaNombres.splice(j, 1);
                        }
                    }
                }
                component.set('v.ficherosAdjuntos', listaNombres);

                let toastParams = {
                    title: "Éxito",
                    message: 'Archivos subidos y adjuntados al correo electrónico', 
                    type: "success"
                };
                let toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams(toastParams);
                toastEvent.fire();
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

    borrarAdjunto : function(component, event, helper){
        component.set('v.isLoading', true);
        let idContentVersion = event.getSource().get("v.name");

        let ficherosBorrados = component.get('v.ficherosBorrados');
        ficherosBorrados.push(idContentVersion);
        component.set('v.ficherosBorrados', ficherosBorrados);

        let documentosSubidosEstaEjecucion = component.get('v.documentosSubidosEstaEjecucion');
        //Si el documento ha sido subido en esta ejecución, lo borramos
        if(documentosSubidosEstaEjecucion && documentosSubidosEstaEjecucion.includes(idContentVersion)){
            var action = component.get('c.eliminaRegistro');
            action.setParams({'id': idContentVersion});
            action.setCallback(this, function(response) {
                var state = response.getState();
                if(state === 'SUCCESS'){
                    let listaNombres = response.getReturnValue();
                    //NGM
                    //No mostramos los elementos que han sido borrados previamente en esta ejecución

                    for(let i = 0; i < ficherosBorrados.length; i++){
                        for(let j = 0; j < listaNombres.length; j++){
                            if(listaNombres[j].Id == ficherosBorrados[i]){
                                listaNombres.splice(j, 1);
                            }
                        }
                    }
                    component.set('v.ficherosAdjuntos', listaNombres);
                    let idsFicherosAdjuntos = [];
                    listaNombres.forEach(file => idsFicherosAdjuntos.push((file.contentVersionId)));
                    component.set('v.idsFicherosAdjuntos', idsFicherosAdjuntos);
                    let toastParams = {
                        title: "Éxito",
                        message: 'Archivo eliminado.', 
                        type: "success"
                    };
                    
                    let toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams(toastParams);
                    toastEvent.fire();
                    component.set('v.isLoading', false);
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
                    component.set('v.isLoading', false);
                }
            })
            $A.enqueueAction(action);
        }
        //Si no se ha subido el documento en esta ejecución, lo borramos solo de la lista de elementos a enviar
        else{
            let ficherosAdjuntos = component.get('v.ficherosAdjuntos');
            let idsFicherosAdjuntos = component.get('v.idsFicherosAdjuntos');
            for(let i = 0; i < ficherosAdjuntos.length; i++){ 
                
                if (ficherosAdjuntos[i].Id == idContentVersion) { 
                    idsFicherosAdjuntos.splice(i, 1);
                    ficherosAdjuntos.splice(i, 1); 
                }
            }

            component.set('v.ficherosAdjuntos', ficherosAdjuntos);
            component.set('v.idsFicherosAdjuntos', idsFicherosAdjuntos);

            let toastParams = {
                title: "Éxito",
                message: 'Archivo eliminado del envío.', 
                type: "success"
            };
            
            let toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams(toastParams);
            toastEvent.fire();

            component.set('v.isLoading', false);
        }

    },

    previsualizarDoc : function (cmp, event) {
        var idArchivo = event.getSource().get("v.name");
        $A.get('e.lightning:openFiles').fire({
            recordIds: [idArchivo]
        });
    },

    //US723742 - Raúl Santos - 05/03/2024 - Añadir lógica envio emails blackList. Comprueba si los emails son correctos. Si son correctos continua el proceso, sino muestra mensaje informativo
    comprobarEmails : function (component, event, helper){

        component.set('v.isLoading', true);
        component.set('v.muestraModal', false);
        /*let ficherosAdjuntos = component.get("v.ficherosAdjuntos");
        let idsFicherosAdjuntos = [];
        for(let i = 0; i <ficherosAdjuntos.length; i++){
            idsFicherosAdjuntos.push(ficherosAdjuntos[i].Id);
        }*/

        var actionComprobarEmails = component.get("c.comprobarEmailsEnvio");
        actionComprobarEmails.setParams({'para': component.get("v.para"), 'copia': component.get("v.copia"), 'copiaOculta': component.get("v.copiaOculta")});
        actionComprobarEmails.setCallback(this, function(response) {
			var state = response.getState();
            if (state === "SUCCESS") {
                let emailsNoValidos = response.getReturnValue();

                if(emailsNoValidos === ''){
                    //Todas las direcciones de email son validas (ninguna está activa en la blackList) luego podemos continuar el proceso de envio
                    var procedencia = component.get("v.procedencia");

                    if(procedencia == 'SAC_003' || procedencia == 'Inadmision'){
                        helper.enviarRedaccionMail(component, event);
                    }else if(procedencia == 'Consulta' || procedencia == 'Resolver' || procedencia == 'ConsultaDeReclamacion'){
                        helper.enviarConsultaMail(component, event);
                    }else if(procedencia == 'Prorrogar'){
                        helper.enviarProrrogaMail(component, event);
                    }
                    
                }else{
                    //Alguna de las direcciones de email no son validas (alguna está activa en la blackList) luego notificamos esto al usuario
                    component.set('v.isLoading', false);
                    let toastParams = {
                        title: "Error",
                        message: "No está permitido el envío de emails a esta dirección: " + emailsNoValidos + " de correo electrónico, por favor elimínela para proceder al envío",
                        type: "error"
                    };
                    let toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams(toastParams);
                    toastEvent.fire();
                }
            }
            else{
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
        })

        $A.enqueueAction(actionComprobarEmails);
    },

    validarDocumentacion :  function(component, event, helper){
        var checkmarcado = component.get("v.checkConfirmacionValidacion");

        if (checkmarcado) {
            $A.enqueueAction(component.get('c.comprobarEmails'));
        }else {
            var toastEventWarning = $A.get("e.force:showToast");
            toastEventWarning.setParams({
                "title": "Advertencia",
                "message": "Debe confirmar que ha validado la correspondencia entre reclamante y documentación adjunta",
                "type": "warning"
            });
            toastEventWarning.fire();
        }
    },

    handleEventRichText : function(component, event, helper) {       
        //Recibo el evento desde el LWC y almaceno el nuevo mapa de tags de las imagenes
        var message = event.getParam('data');
        component.set("v.imageTagsMap", message);
    },

    handleEventFlagCambioPlantilla : function(component, event, helper) {        
        //Recibo el evento desde el LWC y almaceno el valor en el flag de cambio plantilla
        var message = event.getParam('data');
        component.set("v.flagCambioPlantillaPadre", message);
    },

    handleEventModificarImagen : function(component, event, helper) {
        //Recibo el evento desde el LWC y almaceno el nuevo mapa de tags de las imagenes
        var imagenes = event.getParam('imgMap');
        component.set("v.imageTagsMap", imagenes);
    }
})