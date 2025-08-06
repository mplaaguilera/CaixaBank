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
    },
    desvincular: function(component, event, helper) {
        
        let pills = component.get('v.pills');
        for(let j = 0; j < pills.length; j++){
            if(pills[j].id == event.getSource().get("v.value")){
                pills.splice(j, 1);
            }
        }
        component.set('v.pills', pills);
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