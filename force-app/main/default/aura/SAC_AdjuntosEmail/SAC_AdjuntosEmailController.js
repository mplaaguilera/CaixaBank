({
    Inicial : function(component, event, helper) {
        //component.set('v.caseId', 'v.recordId');
        let pillsSet = [];
        component.set('v.pills', pillsSet);
        var action = component.get('c.recuperaAdjuntos');
        var actionDocInicio = component.get('c.getDocumentRedaccion');
        actionDocInicio.setParams({'id':component.get('v.caseId')});
        actionDocInicio.setCallback(this, function(response) {
                var state = response.getState();
                if(state === 'SUCCESS'){
                    let pills = [];
                    let nonValidatedItems = [];
                    let validatedItems = [];
                    let returnValues = response.getReturnValue();
                    if (Array.isArray(returnValues)) {
                        returnValues.forEach(function(item) {
                            if(item.SAC_ValidadoCV__c == false){
                                nonValidatedItems.push(item);
                            }else{
                                validatedItems.push(item);
                                pills.push({
                                    type: 'icon',
                                    id: item.ContentDocumentId,
                                    label: item.Title,
                                    iconName: 'doctype:attachment',
                                    origen: 'SF'
                                });
                            }
                        });
                    }
                    component.set('v.pills', pills);

                    if (nonValidatedItems.length > 0) {
                        component.set('v.nonValidatedItems', nonValidatedItems);
                        helper.showNonValidatedPopup(component, event);
                    }
        
                    component.set('v.validateItems', validatedItems);
                    helper.actualizaSeleccionados(component, event);
                }
            });
        action.setParams({'id':component.get('v.caseId')});
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(state === 'SUCCESS'){
                let ficherosAdjuntos = response.getReturnValue();
                var selected = [];
                component.set('v.ficherosAdjuntos', ficherosAdjuntos);
                helper.actualizaSeleccionados(component, event);
                
                if(component.get('v.seleccionarReclamacion'))
                {
                    $A.enqueueAction(actionDocInicio);
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

    handleSelect: function(component, event, helper) {
        var selected = event.getParam('name');
        component.set('v.verSF', selected=='SF');
        component.set('v.verLocal', selected=='EQUIPO');
        component.set('v.selectedItem', selected);

    },
    ficheroSeleccionado: function(component, event, helper) {
        component.set('v.ContentDocumentId',event.currentTarget.id);
    },
    adjuntar: function(component, event, helper) {
        
        let pills = component.get('v.pills');
        pills.push({
            type: 'icon',
            id: event.getSource().get("v.value"),
            label: event.getSource().get("v.name"),
            iconName: 'doctype:attachment',
            origen: 'SF'
        });
        component.set('v.pills', pills);
        //Añadido US785007 añadir el valor SAC_Salida al campo SAC_Bloque__c del fichero si el componente se encuentra en el envio de la redacción al cliente (procedencia = SAC_003 o Inadmision)
        let procedencia = component.get('v.procedencia');
        if (procedencia == 'SAC_003' || procedencia == 'Inadmision') {
            let action = component.get("c.actualizarSACBloqueField");
            action.setParams({fileId: event.getSource().get("v.value")});

            action.setCallback(this, function(response) {
                let state = response.getState();
                if (state === "SUCCESS") {
                    //Mostrar toast?
                }
            });

            $A.enqueueAction(action);
        }

        //Si es desde una consulta externa, vincular los ficheros con la consulta
        if(component.get('v.consultaId')){
            
            let fileId =  event.getSource().get("v.value");

            var actionFile = component.get('c.checkAdjuntoConsulta');
            actionFile.setParams({'consultaId': component.get('v.consultaId'), "fileId": fileId});
            actionFile.setCallback(this, function(response) {
                var state = response.getState();
                if(state !== 'SUCCESS'){
                    let toastParams = {
                        title: "Error",
                        message: "Error al adjuntar los archivos en la consulta", 
                        type: "error"
                    };
            
                    let toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams(toastParams);
            
                    toastEvent.fire();
                }
            });
            $A.enqueueAction(actionFile);
        }
    },
    desvincular: function(component, event, helper) {
        
        let pills = component.get('v.pills');
        for(let j = 0; j < pills.length; j++){
            if(pills[j].id == event.getSource().get("v.value")){
                pills.splice(j, 1);
            }
        }
        component.set('v.pills', pills);

        if(component.get('v.consultaId')){

            //Eliminar el ContentDocumentLink del adjunto con la consulta
            var actionDelete = component.get('c.deleteFileConsulta');
            actionDelete.setParams({'consultaId': component.get('v.consultaId'), 'fileId': event.getSource().get("v.value")});
            actionDelete.setCallback(this, function(response) {
                var state = response.getState();
                if(state !== 'SUCCESS'){
                    let toastParams = {
                        title: "Error",
                        message: "Error al desvincular el archivo de la consulta", 
                        type: "error"
                    };
            
                    let toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams(toastParams);
            
                    toastEvent.fire();
                }
            });
            $A.enqueueAction(actionDelete);
        }
    },
    eliminaTemporal: function(component, event, helper) {
        var pills = component.get('v.pills');
        var action = component.get('c.eliminaContentDocument');
        action.setParams({'id': event.getSource().get("v.value")});
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(state === 'SUCCESS'){
                for(let j = 0; j < pills.length; j++){
                    if(pills[j].id == event.getSource().get("v.value")){
                        pills.splice(j, 1);
                    }
                }
                component.set('v.pills', pills);
            }
            else{
                alert("error");
            }
        });
        $A.enqueueAction(action);
    },
    handleItemRemove: function (component, event) {
        var items = component.get('v.pills');
        var item = event.getParam("index");
        if(items[item].origen=='PC'){
            var action = component.get('c.eliminaContentDocument');
            action.setParams({'id': items[item].id});
            action.setCallback(this, function(response) {
                var state = response.getState();
                if(state === 'SUCCESS'){
                    items.splice(item, 1);
                    component.set('v.pills', items);
                }
                else{
                    alert("error");
                }
            });
            $A.enqueueAction(action);
        }
        else{
            if(component.get('v.consultaId')){

                //Eliminar el ContentDocumentLink del adjunto con la consulta
                var actionDelete = component.get('c.deleteFileConsulta');
                actionDelete.setParams({'consultaId': component.get('v.consultaId'), 'fileId': items[item].id});
                actionDelete.setCallback(this, function(response) {
                    var state = response.getState();
                    if(state !== 'SUCCESS'){
                        let toastParams = {
                            title: "Error",
                            message: "Error al desvincular el archivo de la consulta", 
                            type: "error"
                        };
                
                        let toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams(toastParams);
                
                        toastEvent.fire();
                    }
                });
                $A.enqueueAction(actionDelete);
            }
            items.splice(item, 1);
            component.set('v.pills', items);
        }
    },
    actualizaFicheros: function(component, event, helper) {
        helper.actualizaSeleccionados(component, event);
    },
    handleUploadFinished : function(component, event, helper) {
        let pills = component.get('v.pills');
        let uploadedFiles = event.getParam("files");
        let idFicheros = [];
        for(let i = 0; i < uploadedFiles.length; i++){
            pills.push({
                type: 'icon',
                id: uploadedFiles[i].documentId,
                label: uploadedFiles[i].name,
                iconName: 'doctype:attachment',
                origen: 'PC'
            });
            //Añadir las ids de los ficheros para poder mandarlos al metodo rellenarUltimaModFichero
            idFicheros.push(uploadedFiles[i].documentId);
        }
        component.set('v.pills', pills);

        //Llamada al metodo rellenarUltimaModFichero para actualizar el campo SAC_UltimaModificacionFichero__c del caso
        //Añadido US785007 añadir el valor SAC_Salida al campo SAC_Bloque__c del fichero si el componente se encuentra en el envio de la redacción al cliente (procedencia = SAC_003 o Inadmision)
        let procedencia = component.get('v.procedencia');
        let marcarRespuesta = false;
        if (procedencia == 'SAC_003' || procedencia == 'Inadmision') {
            marcarRespuesta = true;
        }
        var action = component.get('c.rellenarUltimaModFichero');
        action.setParams({'caseId': component.get('v.caseId'), "ficheros": idFicheros, "marcarRespuesta": marcarRespuesta});
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(state === 'SUCCESS'){
                //Success
            }
        });
        $A.enqueueAction(action);
        

        if(component.get('v.consultaId')){
            
            let fileIds = uploadedFiles.map(file => file.documentId);

            var action = component.get('c.linkFileToConsulta');
            action.setParams({'consultaId': component.get('v.consultaId'), "fileIds": fileIds});
            action.setCallback(this, function(response) {
                var state = response.getState();
                if(state !== 'SUCCESS'){
                    let toastParams = {
                        title: "Error",
                        message: "Error al adjuntar los archivos en la consulta", 
                        type: "error"
                    };
            
                    let toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams(toastParams);
            
                    toastEvent.fire();
                }
            });
            $A.enqueueAction(action);
        }
    },
    myFunction: function(component, event, helper) {
        component.set('v.isOpen', !component.get('v.isOpen'));
    },

    validateItem: function(component, event) {
        let idFichero = event.currentTarget.value;
        var actionValidar = component.get('c.validarFichero');

        actionValidar.setParams({'idFichero': idFichero});
        actionValidar.setCallback(this, function(response) {
            var state = response.getState();
                if(state === 'SUCCESS'){
                    let validatedItems = component.get('v.validateItems') || [];
                    let nonValidatedItems = component.get('v.nonValidatedItems') || [];

                    // Buscar el índice correcto usando ContentDocumentId
                    let index = nonValidatedItems.findIndex(item => item.ContentDocumentId === idFichero);

                    if (index !== -1) {
                        let itemValidado = nonValidatedItems.splice(index, 1)[0]; // Sacar el item de la lista no validada
                        validatedItems.push(itemValidado); // Agregarlo a la lista validada
                    }

                    // **IMPORTANTE:** Reasignar el array para que el framework detecte el cambio
                    component.set('v.validateItems', [...validatedItems]);
                    component.set('v.nonValidatedItems', [...nonValidatedItems]);

        
                    let toastParams = {
                        title: "Fichero Validado",
                        message: "Se ha validado fichero con la reclamación", 
                        type: "success"
                    };
            
                    let toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams(toastParams);
                    toastEvent.fire();
                    $A.get('e.force:refreshView').fire();

                }
        })
        $A.enqueueAction(actionValidar);

    }
    
})