({
    Inicial : function(component, event, helper) {

        let idRegistro = component.get('v.recordId');
        let soloActual = component.get('v.registroActual');
        let fieldApi = component.get('v.fieldApiName');
        let objectApi = component.get('v.objectApiName');

        if(soloActual){

            component.set('v.verSF', false);
            component.set('v.verActual', true);
        }

        if(fieldApi != undefined && objectApi != undefined){

        var recuperarDatos = component.get('c.recuperarDatos');
        recuperarDatos.setParams({'idRegistro': idRegistro, 'fieldApiName' : component.get('v.fieldApiName'), 'objectApiName' : component.get('v.objectApiName')});
        recuperarDatos.setCallback(this, function(response) {
            var state = response.getState();
            if(state === 'SUCCESS'){
                component.set('v.escalado', response.getReturnValue());
                let escalado = component.get('v.escalado');
                component.set('v.reclamacionId', escalado[component.get('v.fieldApiName')]);

                if(soloActual==false){

                var adjuntosCase = component.get('c.recuperaAdjuntos');
                adjuntosCase.setParams({'id':component.get('v.reclamacionId')});
                adjuntosCase.setCallback(this, function(response) {
                var state = response.getState();
                if(state === 'SUCCESS'){
                    let ficherosAdjuntosCase = response.getReturnValue();
                    var selected = [];
                    component.set('v.ficherosAdjuntosCase', ficherosAdjuntosCase);
                    helper.actualizaSeleccionadosCase(component, event);
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

            $A.enqueueAction(adjuntosCase);

            }

            var adjuntosEscalado = component.get('c.recuperaAdjuntos');
            adjuntosEscalado.setParams({'id':idRegistro});
            adjuntosEscalado.setCallback(this, function(response) {
                var state = response.getState();
                if(state === 'SUCCESS'){
                    let ficherosAdjuntos = response.getReturnValue();
                    var selected = [];
                component.set('v.ficherosAdjuntos', ficherosAdjuntos);
                helper.actualizaSeleccionados(component, event);
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

        $A.enqueueAction(adjuntosEscalado);

            }else{
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

        $A.enqueueAction(recuperarDatos);

    }
    },

    handleSelect: function(component, event, helper) {
        var selected = event.getParam('name');
        let soloActual = component.get('v.registroActual');

        if(soloActual==false){
            component.set('v.verSF', selected=='SF');
        }

        component.set('v.verLocal', selected=='EQUIPO');
        component.set('v.verActual', selected=='REGISTRO');
        component.set('v.selectedItem', selected);

    },
    ficheroSeleccionado: function(component, event, helper) {
        component.set('v.ContentDocumentId',event.currentTarget.id);
    },

    abrirPopUpEliminar: function(component, event, helper) {

        component.set('v.popUpEliminar', true);
        component.set('v.idAdjuntoEliminar', event.getSource().get("v.value"));
        component.set('v.nameAdjuntoEliminar', event.getSource().get("v.name"));


    },

    cerrarrPopUpEliminar: function(component, event, helper) {

        component.set('v.popUpEliminar', false);

    },

    desvincularRegistro: function(component, event, helper) {
        
        let pills = component.get('v.pills');
        for(let j = 0; j < pills.length; j++){
            if(pills[j].id == component.get('v.idAdjuntoEliminar')){
                pills.splice(j, 1);
            }
        }
        component.set('v.pills', pills);

        let desvincularAdjunto = component.get('c.desvincularAdjunto');
        desvincularAdjunto.setParams({'idDocument': component.get('v.idAdjuntoEliminar'), 'id' : component.get('v.recordId')});
        desvincularAdjunto.setCallback(this, function(response) {
                var state = response.getState();
            if(state === 'SUCCESS'){
                component.set('v.popUpEliminar', false);
                $A.get('e.force:refreshView').fire();
                let toastParams = {
                    title: "Archivo desvinculado",
                    message: 'El archivo se ha desvinculado con éxito', 
                    type: "success"
                };
                let toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams(toastParams);
                toastEvent.fire();
            }else{
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

            $A.enqueueAction(desvincularAdjunto);

    },

    eliminarRegistro: function(component, event, helper) {
        
        let pills = component.get('v.pills');
        for(let j = 0; j < pills.length; j++){
            if(pills[j].id == component.get('v.idAdjuntoEliminar')){
                pills.splice(j, 1);
            }
        }
        component.set('v.pills', pills);

        let eliminaAdjunto = component.get('c.eliminarAdjunto');
        eliminaAdjunto.setParams({'idDocument': component.get('v.idAdjuntoEliminar')});
        eliminaAdjunto.setCallback(this, function(response) {
                var state = response.getState();
            if(state === 'SUCCESS'){
                component.set('v.popUpEliminar', false);
                $A.get('e.force:refreshView').fire();
                let toastParams = {
                    title: "Archivo eliminado",
                    message: 'El archivo se ha eliminado con éxito', 
                    type: "success"
                };
                let toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams(toastParams);
                toastEvent.fire();
            }else{
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

            $A.enqueueAction(eliminaAdjunto);
    },

    eliminaTemporal: function(component, event, helper) {
        var pills = component.get('v.pills');
        let eliminaAdjunto = component.get('c.eliminarAdjunto');
        eliminaAdjunto.setParams({'idDocument':event.getSource().get("v.value")});
        eliminaAdjunto.setCallback(this, function(response) {
                var state = response.getState();
            if(state === 'SUCCESS'){
                for(let j = 0; j < pills.length; j++){
                    if(pills[j].id == event.getSource().get("v.value")){
                        pills.splice(j, 1);
                    }
                }
                component.set('v.pills', pills);
                $A.get('e.force:refreshView').fire();
                let toastParams = {
                    title: "Archivo eliminado",
                    message: 'El archivo que acaba de subir se ha eliminado con éxito', 
                    type: "success"
                };
                let toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams(toastParams);
                toastEvent.fire();
            }else{
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

            $A.enqueueAction(eliminaAdjunto);
        
    },

    actualizaFicheros: function(component, event, helper) {
        helper.actualizaSeleccionados(component, event);

        let soloActual = component.get('v.registroActual');

        if(soloActual==false){
        helper.actualizaSeleccionadosCase(component, event);
        }
    },

    vincularConRegistro : function(component, event, helper){

        let pills = component.get('v.pills');
        pills.push({
            type: 'icon',
            id: event.getSource().get("v.value"),
            label: event.getSource().get("v.name"),
            iconName: 'doctype:attachment',
            origen: 'SF'
        });
        component.set('v.pills', pills);

        let soloActual = component.get('v.registroActual');

        if(soloActual==false){

        let replicarAdjuntos = component.get('c.replicarAdjuntosCase');
            replicarAdjuntos.setParams({'idDocument': event.getSource().get("v.value"), 'id': component.get('v.recordId')});
            replicarAdjuntos.setCallback(this, function(response) {
                var state = response.getState();
            if(state === 'SUCCESS'){
                if(response.getReturnValue() == true){
                    let toastParams = {
                        title: "El archivo no se ha subido!",
                        message:'El archivo que quiere adjuntar ya está adjuntado al registro', 
                        type: "warning"
                    };
                    let toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams(toastParams);
                    toastEvent.fire();
                }
                $A.get('e.force:refreshView').fire();
            }else{
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

            $A.enqueueAction(replicarAdjuntos);

        }
    },
    handleUploadFinished : function(component, event, helper) {
        let pills = component.get('v.pills');
        let uploadedFiles = event.getParam("files");
        for(let i = 0; i < uploadedFiles.length; i++){
            pills.push({
                type: 'icon',
                id: uploadedFiles[i].documentId,
                label: uploadedFiles[i].name,
                iconName: 'doctype:attachment',
                origen: 'PC'
            });
            
            let soloActual = component.get('v.registroActual');

            if(soloActual==false){

            let replicarAdjuntos = component.get('c.replicarAdjuntosCase');
            replicarAdjuntos.setParams({'idDocument': uploadedFiles[i].documentId, 'id': component.get('v.reclamacionId')});
            replicarAdjuntos.setCallback(this, function(response) {
                var state = response.getState();
            if(state === 'SUCCESS'){
                if(response.getReturnValue() == true){
                    let toastParams = {
                        title: "El archivo no se ha subido!",
                        message:'El archivo que quiere adjuntar ya está adjuntado al registro', 
                        type: "error"
                    };
                    let toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams(toastParams);
                    toastEvent.fire();
                }

                $A.get('e.force:refreshView').fire();
            }else{
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

            $A.enqueueAction(replicarAdjuntos);
        }
        }
        component.set('v.pills', pills);
        $A.get('e.force:refreshView').fire();
    },

    myFunction: function(component, event, helper) {
        component.set('v.isOpen', !component.get('v.isOpen'));
    },

    ocultarFile: function(component, event, helper) {
        let oculta = component.get('c.ocultarContentVersion');
        oculta.setParams({'id': event.getSource().get("v.value")});
        oculta.setCallback(this, function(response) {
            var state = response.getState();
            helper.cambioIconoVisibilidad(component, event.getSource().get("v.value"), true);
        });
        $A.enqueueAction(oculta);
    },
    desocultarFile: function(component, event, helper) {
        let oculta = component.get('c.desocultarContentVersion');
        oculta.setParams({'id': event.getSource().get("v.value")});
        oculta.setCallback(this, function(response) {
            var state = response.getState();
            helper.cambioIconoVisibilidad(component, event.getSource().get("v.value"), false);

        });
        $A.enqueueAction(oculta);

/*
        var ficheros= component.get('v.ficherosAdjuntosVisibles');
        var fIndex = ficheros.findIndex(p => p.Id == event.getSource().get("v.value"));
        alert(ficheros[fIndex].SAC_Oculto__c);
        ficheros[fIndex].SAC_Oculto__c = false;
        component.set('v.ficherosAdjuntosVisibles',ficheros);

        var ficheros= component.get('v.ficherosAdjuntos');
        var fIndex = ficheros.findIndex(p => p.Id == event.getSource().get("v.value"));
        alert(ficheros[fIndex].SAC_Oculto__c);
        ficheros[fIndex].SAC_Oculto__c = false;
        component.set('v.ficherosAdjuntos',ficheros);*/

        //helper.cambioIconoVisibilidad(component, event.getSource().get("v.value"), false);

    }
        /*
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
    */
})