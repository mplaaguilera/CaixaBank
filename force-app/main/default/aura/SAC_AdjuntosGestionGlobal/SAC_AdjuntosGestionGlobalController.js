({
    Inicial : function(component, event, helper) {
        
        let idRegistro = component.get('v.recordId');
        let soloActual = component.get('v.registroActual');
        let fieldApi = component.get('v.fieldApiName');
        let objectApi = component.get('v.objectApiName');

        //Vaciar los atributos de selección para clasificación múltiple
        component.set("v.mapFicherosClasifMultiple", {});
        component.set('v.habilitarBtnClasifMultiple', false);
        component.set('v.habilitarBtnBloque', '');    
        component.set('v.bloqueUnElemento', '');

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

                    if(component.get('v.fieldApiName') === 'SPV_TareaRelacionada__r.SAC_Reclamacion__c'){
                        component.set('v.parentId', escalado['SPV_TareaRelacionada__r']['SAC_Reclamacion__c']);
                    }else{
                        component.set('v.parentId', escalado[component.get('v.fieldApiName')]);
                    }
                        
                    if(soloActual===false){

                        var idReg = component.get('v.parentId');                        

                        var adjuntosCase = component.get('c.recuperaAdjuntos');
                        adjuntosCase.setParams({'id': idReg});
                        adjuntosCase.setCallback(this, function(response) {
                        var state = response.getState();
                            if(state === 'SUCCESS'){ 
                                let ficherosAdjuntosCase = response.getReturnValue();
                                console.log('LOS ADJUNTOS RECIBIDOS ' + ficherosAdjuntosCase);
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
                                                            console.log('LOS ADJUNTOS RECIBIDOS 2' + JSON.stringify(ficherosAdjuntos));
                            var selected = [];

                            //AÑADIDO NUEVOOO - ÁLEX
                            /*for(let i = 0; i < ficherosAdjuntos.length; i++){
                                if(ficherosAdjuntos[i].SAC_Bloque__c.includes('SAC_Tramitacion')){
                                 //console.log('esta en tramitacionnnnnn ');
                                //ficherosAdjuntos[i].estaEnTramitacion = true;
                                }
                            }*/
                            //------------------

                            component.set('v.ficherosAdjuntos', ficherosAdjuntos);

                            if(ficherosAdjuntos.length !== 0){
                                component.set('v.deleteLastCV', '1');
                            }

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
        
        let ficherosAdjuntos = component.get('v.ficherosAdjuntos');
        var numAdjuntos = ficherosAdjuntos.length;
        var idAdjuntoBorrado = '';
        
        for(let j = 0; j < ficherosAdjuntos.length; j++){            
            if(ficherosAdjuntos[j].ContentDocumentId == component.get('v.idAdjuntoEliminar')){

                //Es el ultimo fichero de la lista                
                if(numAdjuntos - 1 === j){
                    idAdjuntoBorrado = ficherosAdjuntos[j].ContentDocumentId;
                }
                
                ficherosAdjuntos.splice(j, 1);
            }
        }
        component.set('v.ficherosAdjuntos', ficherosAdjuntos);
        
        //DE107472 error al eliminar ficheros
        if(ficherosAdjuntos.length === 0){
            component.set('v.deleteLastCV', '2');
        }else{
            if(idAdjuntoBorrado != ''){
                component.set('v.deleteLastCV', idAdjuntoBorrado);
            }else{
                component.set('v.deleteLastCV', '1');
            }
        }
        
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
                let mensageError;
                if(errors[0].message) {
                    mensageError = errors[0].message;                    
                    
                    if(mensageError.includes('FIELD_CUSTOM_VALIDATION_EXCEPTION')){                       
                        let regex = /FIELD_CUSTOM_VALIDATION_EXCEPTION,(.*)/;
                        let resultado = mensageError.match(regex);
                        
                        if (resultado && resultado.length > 1) {
                            mensageError = resultado[1];
                        }                        
                    }
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
        component.set('v.modalClasificarMultiple', false);
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
        component.set('v.modalClasificarMultiple', false);
        component.set("v.opcionesBloquesSeleccionadas", []);
    },

    handleChangeClasificado: function(component, event, helper) {
        var selectedValues = event.getParam("value");
        component.set("v.opcionesBloquesSeleccionadas", selectedValues);
    },

    cambiarClasificacionFichero: function(component, event, helper) {
        component.set('v.disableButtons', true);

        var idsFicheros = new Set();
        var msgExito = '';

        if(component.get('v.modalClasificarMultiple')){
            
            var myMap = component.get("v.mapFicherosClasifMultiple");

            for(var key in myMap){
                idsFicheros.add(key);
            }
            msgExito = 'Se ha modificado el bloque de los ficheros';
        }else{
            var idFichero = component.get('v.selectedFichero.ContentDocumentId');
            idsFicheros.add(idFichero);
            msgExito = 'Se ha modificado el bloque del fichero';
        }
        
        if(idsFicheros && Array.from(idsFicheros).length > 0){           
            let cambioClasificacion = component.get('c.cambiarClasificacion');
            cambioClasificacion.setParams({'listIdAdjuntos': Array.from(idsFicheros), 'listaValoresBloque': component.get('v.opcionesBloquesSeleccionadas'), 'caseId': component.get('v.recordId')});
            cambioClasificacion.setCallback(this, function(response) {
                var state = response.getState();
                if(state === 'SUCCESS'){
                    let toastParams = {
                        title: "Clasificación modificada",
                        message: msgExito, 
                        type: "success"
                    };
                    let toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams(toastParams);
                    toastEvent.fire();
                    
                    component.set("v.opcionesBloquesSeleccionadas", []);
                    component.set('v.modalClasificar', false);
                    component.set('v.disableButtons', false);

                    //Vaciar los atributos de selección para clasificación múltiple
                    component.set('v.modalClasificarMultiple', false);
                    component.set("v.mapFicherosClasifMultiple", {});
                    component.set('v.habilitarBtnClasifMultiple', false);
                    component.set('v.habilitarBtnBloque', '');    
                    component.set('v.bloqueUnElemento', '');
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
                    component.set('v.modalClasificarMultiple', false);

                    //Vaciar los atributos de selección para clasificación múltiple
                    component.set('v.modalClasificarMultiple', false);
                    component.set("v.mapFicherosClasifMultiple", {});
                    component.set('v.habilitarBtnClasifMultiple', false);
                    component.set('v.habilitarBtnBloque', ''); 
                    component.set('v.bloqueUnElemento', '');   
                    $A.get('e.force:refreshView').fire();
                }            
            })
            $A.enqueueAction(cambioClasificacion);
        }
    },

    handleActualizarVista: function (component, event, helper) {
        $A.get('e.force:refreshView').fire();
    },

    handleMostrarMiniatura: function (component, event, helper) {
        let docId = event.getParam('contentDocId');        

        //Es un documento del lwc hijo
        if(docId){
            if(docId != component.get('v.ContentDocumentIdSPV')){
                component.set('v.ContentDocumentIdSPV', docId);
                component.set('v.mostrarMiniatura', true); 
            }else{
                component.set('v.mostrarMiniatura', !component.get('v.mostrarMiniatura')); 
            }   
        }else{ //Documento de Casesin clasificar, o de obj diferente a Case
            let idFich = event.currentTarget.name;            

            if(idFich != component.get('v.ContentDocumentIdSPV')){
                component.set('v.mostrarMiniatura', true); 
            }else{
                component.set('v.mostrarMiniatura', !component.get('v.mostrarMiniatura')); 
            }
        }
    },

    handleMultipleClasif: function (component, event, helper) {

        var idFichero = '';
        var bloqueFichero = '';
        var marcadoFichero = '';
        var bloqActSelec = '';
        var mostrarBtnDefault = true;

        var myMap = component.get("v.mapFicherosClasifMultiple");
        if (!myMap) {
            myMap = {};
        }

        //Si viene del LWC hijo, recuperamos la información que nos devuelve
        if(event.getParam("idFichero")){
            idFichero = event.getParam("idFichero");
            bloqueFichero = event.getParam("bloqueFichero");
            marcadoFichero = event.getParam("marcadoFichero");
            bloqActSelec = event.getParam("bloqueActual");
        }else{ //Si es un fichero directo desde el padre (bloque de 'Sin clasificar')
            idFichero = event.getSource().get("v.value");
            bloqueFichero = 'No_Clasificado';
            marcadoFichero = event.getSource().get("v.checked");
            bloqActSelec = 'No_Clasificado';
        }

        //Si el fichero viene marcado
        if(marcadoFichero){
            //Si ya esta en el mapa, significa que ha sido marcado en otro bloque, luego mostramos el mensaje de advertencia, sumamos una marca al fichero, y añadimos a la lista de bloques el bloque actual desde el que se selecciona el fichero
            if(myMap.hasOwnProperty(idFichero) && bloqueFichero != 'No_Clasificado'){
                mostrarBtnDefault = false;
                myMap[idFichero].numero += 1;
                myMap[idFichero].listBloqueSelect.push(bloqActSelec);

                let toastParams = {
                    title: "Advertencia!",
                    message:'Para la clasificación múltiple debe seleccionar únicamente ficheros del mismo bloque.', 
                    type: "warning"
                };
                let toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams(toastParams);
                toastEvent.fire();
            }else{  //Sino, añadimos el fichero al mapa con marca = 1
                let listAct = [];
                listAct.push(bloqActSelec);
                myMap[idFichero] = {bloque: bloqueFichero, numero: 1, listBloqueSelect: listAct};
            }            
        }else{
            //Si viene desmarcado comprobamos si esta en el mapa
            if(myMap.hasOwnProperty(idFichero)){
                //Si únicamente esta una vez en el mapa (fichero marcado una sola vez) lo eliminamos del mapa
                if(myMap[idFichero].numero === 1){
                    delete myMap[idFichero];
                }else{ //Si viene marcado varias veces, restamos una marca al fichero y eliminamos de la lista de bloques el bloque actual desde el que se deselecciona el fichero
                    myMap[idFichero].numero -= 1; 
                    myMap[idFichero].listBloqueSelect = myMap[idFichero].listBloqueSelect.filter(function (item) {
                        return item !== bloqActSelec;
                    });
                }
            }
        }        

        //Validar y actvar/desactivar la clasificación multimple de ficheros
        if(mostrarBtnDefault && Object.keys(myMap).length !== 0){            
            var bloquesUnicos = new Set();

            for(var key in myMap){
                var bloque = myMap[key].listBloqueSelect[0];
                bloquesUnicos.add(bloque);
            }            

            if(Array.from(bloquesUnicos).length > 1){                
                //Desactivar botón de clasificación múltiple
                component.set('v.habilitarBtnClasifMultiple', false);

                let toastParams = {
                    title: "Advertencia!",
                    message:'Para la clasificación múltiple debe seleccionar únicamente ficheros del mismo bloque.', 
                    type: "warning"
                };
                let toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams(toastParams);
                toastEvent.fire();
            }else if(Array.from(bloquesUnicos).length === 1){

                let arrayOfKeys = Object.keys(myMap);
                let firstKey = arrayOfKeys[0];
                

                if(Object.keys(myMap).length === 1) {
                    //Almacena el nombre del bloque donde se selecciona el fichero
                    component.set('v.habilitarBtnBloque', myMap[firstKey].listBloqueSelect[0]);  

                    //Activar botón de clasificación múltiple
                    component.set('v.bloqueUnElemento', myMap[firstKey].bloque);    
                    component.set('v.habilitarBtnClasifMultiple', true);
                }else{
                    var setNameBloques = new Set();                    

                    for(var key in myMap){
                        setNameBloques.add(myMap[key].bloque);
                    }

                    if(Array.from(setNameBloques).length > 1){
                        //Desactivar botón de clasificación múltiple
                        component.set('v.habilitarBtnClasifMultiple', false);

                        let toastParams = {
                                title: "Advertencia!",
                                message: 'Ha seleccionado ficheros que se encuentran en varios bloques. Debe seleccionar ficheros que pertenezcan exactamente a los mismos bloques.', 
                                type: "warning"
                            };
                        let toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams(toastParams);
                        toastEvent.fire();
                    }else{
                        //Almacena el nombre del bloque donde se selecciona el fichero
                        component.set('v.habilitarBtnBloque', myMap[firstKey].listBloqueSelect[0]);  

                        //Activar botón de clasificación múltiple
                        component.set('v.bloqueUnElemento', myMap[firstKey].bloque);    
                        component.set('v.habilitarBtnClasifMultiple', true);
                    }
                }              
            }
        }else{            
            //Desactivar botón de clasificación múltiple
            component.set('v.habilitarBtnClasifMultiple', false);
        }

        component.set("v.mapFicherosClasifMultiple", myMap);         
    },

    abrirClasifMultiple: function (component, event, helper) {        
        var bloqueActual = component.get('v.bloqueUnElemento');

        // Convertir el campo multipicklist en un array de strings
        const sacBloqueArray = bloqueActual.split(';');
        component.set("v.opcionesBloquesSeleccionadas", sacBloqueArray);

       
        component.set('v.modalClasificarMultiple', true);
        component.set('v.modalClasificar', true);
    }
})