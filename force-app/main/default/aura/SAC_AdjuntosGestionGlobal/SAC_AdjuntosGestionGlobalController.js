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

        if(fieldApi && objectApi){
            var recuperarDatos = component.get('c.recuperarDatos');
            recuperarDatos.setParams({'idRegistro': idRegistro, 'fieldApiName' : component.get('v.fieldApiName'), 'objectApiName' : component.get('v.objectApiName')});
            recuperarDatos.setCallback(this, function(response) {
                var state = response.getState();
                if(state === 'SUCCESS'){
                    component.set('v.escalado', response.getReturnValue().objeto);
                    component.set('v.esUserGeneral', response.getReturnValue().usuarioGeneral);
                    
                    var rtRegistro = response.getReturnValue().objeto.RecordType.DeveloperName;
                    component.set('v.rtRegistro', rtRegistro);

                    //Añadido bloques clasificación ficheros
                    component.set('v.mostrarBloques', response.getReturnValue().mostrarBloques);
                    var resultBloques = response.getReturnValue().sacBloquePicklistValues;
                    helper.procesarBloquesClasificacion(component, resultBloques);
                    //Fin añadido

                    if(component.get('v.esUserGeneral') === true){
                        component.set('v.mostrarOculto', true);
                    }else{
                        component.set('v.mostrarOculto', false);
                    }

                    if(fieldApi === 'CC_CasoRelacionado__c'){
                        component.set('v.esRecAsociadaASPV', true);
                    }

                    let escalado = component.get('v.escalado');
                    component.set('v.parentId', escalado[component.get('v.fieldApiName')]);

                        
                    if(soloActual===false){

                        var idReg = component.get('v.parentId');

                        var adjuntosCase = component.get('c.recuperaAdjuntos');
                        adjuntosCase.setParams({'id': idReg});
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
                    var idReg2 = '';
                    if(fieldApi === 'CC_CasoRelacionado__c'){
                        idReg2 = response.getReturnValue().idCasoRelacionado;
                    }else{
                        idReg2 = idRegistro;
                    }

                    var adjuntosEscalado = component.get('c.recuperaAdjuntos');
                    adjuntosEscalado.setParams({'id':idReg2});
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

        if(soloActual===false){
            component.set('v.verSF', selected=='SF');
        }

        component.set('v.verLocal', selected=='EQUIPO');
        component.set('v.verActual', selected=='REGISTRO');
        component.set('v.selectedItem', selected);

    },
    ficheroSeleccionado: function(component, event, helper) {
        component.set('v.ContentDocumentId',event.currentTarget.id);
        component.set('v.ContentDocumentIdSPV',event.currentTarget.id);


        component.set("v.mostrarGrupos", false);
        
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
                    message: 'El archivo se ha eliminado de ' + component.get('v.recordName') + ' con éxito', 
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

        if(soloActual===false){
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
        let ponerTramitacion = false;
        let replicarAdjuntos = component.get('c.replicarAdjuntosCase');
            replicarAdjuntos.setParams({'idDocument': event.getSource().get("v.value"), 'id': component.get('v.recordId'), 'soloActual': soloActual, 'ponerTramitacion': ponerTramitacion});
            replicarAdjuntos.setCallback(this, function(response) {
                var state = response.getState();
            if(state === 'SUCCESS'){
                if(response.getReturnValue() === true){
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
            let ponerTramitacion = true;
            let replicarAdjuntos = component.get('c.replicarAdjuntosCase');
            replicarAdjuntos.setParams({'idDocument': uploadedFiles[i].documentId, 'id': component.get('v.parentId'), 'soloActual': soloActual, 'ponerTramitacion': ponerTramitacion});
            replicarAdjuntos.setCallback(this, function(response) {
                var state = response.getState();
            if(state === 'SUCCESS'){
                // if(response.getReturnValue() === true){
                //     let toastParams = {
                //         title: "El archivo no se ha subido!",
                //         message:'El archivo que quiere adjuntar ya está adjuntado al registro --2', 
                //         type: "error"
                //     };
                //     let toastEvent = $A.get("e.force:showToast");
                //     toastEvent.setParams(toastParams);
                //     toastEvent.fire();
                // }

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
        component.set('v.pills', pills);
        $A.get('e.force:refreshView').fire();
    },

    myFunctionAbrir: function(component, event, helper) {
        component.set('v.isOpen', !component.get('v.isOpen'));
        component.set('v.modalAdjuntarArchivos', true);
    },

    myFunctionCerrar: function(component, event, helper) {
        component.set('v.isOpen', !component.get('v.isOpen'));
        component.set('v.modalAdjuntarArchivos', false);
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
    },

    handleBlur : function( component, event, helper ){
        helper.handleBlurHelper(component, event);
    },

    mostrarOpciones1 : function( component, event, helper ) {
        component.set("v.saltarValidacion", true);
        helper.mostrarOpcionesHelper(component, event);
    },

    mostrarOpciones : function( component, event, helper ) {
        helper.mostrarOpcionesHelper(component, event);
    },

    filtroBusqueda : function( component, event, helper ) {
       
        let tipoDocCargado = event.getSource().get("v.value");

        if((tipoDocCargado !== null && tipoDocCargado !== '' && tipoDocCargado !== undefined) || component.get('v.saltarValidacion') === true){
            component.set("v.tipoDocumento", tipoDocCargado); 
        }

        if( !$A.util.isEmpty(component.get('v.tipoDocumento')) ) {
            // Una vez borrado, poder volver a buscar escribiendo
            if(component.get("v.mostrarGrupos") === false){
                component.set("v.mostrarGrupos", true);
            }

            component.set("v.cadenaVacia", false);
            component.set("v.cerrar", 0);
            helper.filtroBusquedaHelper(component, event);
            
        } else {
            if(component.get("v.cerrar") === 0 && component.get("v.cadenaVacia") === false){ 
                component.set("v.cerrar", 1);
                var options = component.get("v.opcionesMaestroAdjuntos");
                options.forEach( function(element,index) {
                    element.isVisible = true;
                });
                component.set("v.opcionesMaestroAdjuntos", options);
                if(!$A.util.isEmpty(component.get('v.opcionesMaestroAdjuntos'))) {
                    $A.util.addClass(component.find('gruposCombobox'),'slds-is-open'); 
                } 
            }else{
                component.set("v.cerrar", 0);
                component.set("v.opcionesMaestroAdjuntos", false);
                component.set("v.value", '');
                component.set("v.cadenaVacia", false);
            }
        }     
    },

    seleccionarGrupo : function( component, event, helper ) {
        if(!$A.util.isEmpty(event.currentTarget.id)) {
            helper.seleccionarGrupoHelper(component, event);
        }
    },

    abrirModalClasificar: function(component, event, helper) {
        component.set('v.modalClasificar', true);
        component.set('v.selectedFichero', event.getSource().get("v.value"));
        /*var fieldMap = [];
        var ficheroSeleccionado = component.get('v.selectedFichero');
        var opcionesBloques = component.get('v.bloquesAdjunto');
        for(var key in opcionesBloques){
            if(ficheroSeleccionado.SAC_Bloque__c != opcionesBloques[key].value) {
                fieldMap.push({value: opcionesBloques[key].value, label: opcionesBloques[key].label});
            }
        }
        component.set("v.opcionesBloques", fieldMap);*/
        //component.set("v.selectedClasificacion", fieldMap[0].value);
    },

    cerrarModalClasificar: function(component, event, helper) {
        component.set('v.modalClasificar', false);
        component.set("v.opcionesBloquesSeleccionadas", []);
    },

    handleChangeClasificado: function(component, event, helper) {
        //component.set("v.selectedClasificacion", event.getSource().get("v.value"));
        var selectedValues = event.getParam("value");
        component.set("v.opcionesBloquesSeleccionadas", selectedValues);
    },

    cambiarClasificacionFichero: function(component, event, helper) {
        component.set('v.disableButtons', true);
        let cambioClasificacion = component.get('c.cambiarClasificacion');
        cambioClasificacion.setParams({'idAdjunto': component.get('v.selectedFichero.Id'), 'listaValoresBloque': component.get('v.opcionesBloquesSeleccionadas')});
        cambioClasificacion.setCallback(this, function(response) {
            var state = response.getState();
            if(state === 'SUCCESS'){
                let toastParams = {
                    title: "Clasificación modificada",
                    message:'Se ha modificado el bloque del fichero', 
                    type: "success"
                };
                let toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams(toastParams);
                toastEvent.fire();
                
                component.set("v.opcionesBloquesSeleccionadas", []);
                component.set('v.modalClasificar', false);
                component.set('v.disableButtons', false);
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

                component.set("v.opcionesBloquesSeleccionadas", []);
                component.set('v.modalClasificar', false);
                component.set('v.disableButtons', false);
                $A.get('e.force:refreshView').fire();
            }            
            })
            $A.enqueueAction(cambioClasificacion);
    },

    handleActualizarVista: function (component, event, helper) {
        $A.get('e.force:refreshView').fire();
    },

    handleMostrarMiniatura: function (component, event, helper) {
        let docId = event.getParam('contentDocId');
        component.set('v.ContentDocumentIdSPV', docId);
    }
})