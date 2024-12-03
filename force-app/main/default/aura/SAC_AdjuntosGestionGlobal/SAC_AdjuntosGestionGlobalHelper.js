({
    actualizaSeleccionadosCase : function(component, event) {
        let strBusqueda = component.get('v.busqueda');
        let ficherosVisiblesCase = component.get('v.ficherosAdjuntosCase');
        let ficherosAdjuntosFiltradoCase = [];
        let pills = component.get('v.pills');
        let ficheroSeleccionadoCase = false;

        for(let i = 0; i < ficherosVisiblesCase.length; i++){
            ficheroSeleccionadoCase = false;
            for(let j = 0; j < pills.length; j++){
                if(ficherosVisiblesCase[i].ContentDocumentId == pills[j].id){
                    ficheroSeleccionadoCase = true;
                }
            }
            ficherosVisiblesCase[i].seleccionado = ficheroSeleccionadoCase;
        }
        
        for(let i = 0; i < ficherosVisiblesCase.length; i++){
            if(ficherosVisiblesCase[i].Title.includes(strBusqueda)){
                ficherosAdjuntosFiltradoCase.push(ficherosVisiblesCase[i]);
            }
        }
        component.set('v.ficherosAdjuntosCase',ficherosVisiblesCase);
        component.set('v.ficherosAdjuntosVisiblesCase', ficherosAdjuntosFiltradoCase);

        let idsFicherosAdjuntos = [];
        pills.forEach(file => idsFicherosAdjuntos.push((file.id)));
        component.set('v.idsFicherosAdjuntos', idsFicherosAdjuntos);
    },

    actualizaSeleccionados : function(component, event) {
        let strBusqueda = component.get('v.busqueda');
        let ficherosAdjuntosFiltrado = [];
        let ficherosVisibles = component.get('v.ficherosAdjuntos');
        let pills = component.get('v.pills');
        let ficheroSeleccionado = false;

        for(let i = 0; i < ficherosVisibles.length; i++){
            ficheroSeleccionado = false;
            for(let j = 0; j < pills.length; j++){
                if(ficherosVisibles[i].ContentDocumentId == pills[j].id){
                    ficheroSeleccionado = true;
                }
            }
            ficherosVisibles[i].seleccionado = ficheroSeleccionado;
        }
        
        for(let i = 0; i < ficherosVisibles.length; i++){
            if(ficherosVisibles[i].Title.includes(strBusqueda)){
                ficherosAdjuntosFiltrado.push(ficherosVisibles[i]);
            }
        }
        component.set('v.ficherosAdjuntos',ficherosVisibles);
        component.set('v.ficherosAdjuntosVisibles', ficherosAdjuntosFiltrado);

        let idsFicherosAdjuntos = [];
        pills.forEach(file => idsFicherosAdjuntos.push((file.id)));
        component.set('v.idsFicherosAdjuntos', idsFicherosAdjuntos);
    },
    cambioIconoVisibilidad: function(component, contentVersion, oculto) {
        let ficherosVisibles = component.get('v.ficherosAdjuntos');
        let ficherosAdjuntosFiltrado = component.get('v.ficherosAdjuntosVisibles');
        let ficherosVisiblesCase = component.get('v.ficherosAdjuntosCase');
        let ficherosAdjuntosFiltradoCase = component.get('v.ficherosAdjuntosVisiblesCase');

        var index = ficherosVisibles.findIndex(p => p.Id == contentVersion);
        if (index > -1) {
            ficherosVisibles[index].SAC_Oculto__c = oculto;
        }
        
        index = ficherosAdjuntosFiltrado.findIndex(p => p.Id == contentVersion);
        if (index > -1) {
            ficherosAdjuntosFiltrado[index].SAC_Oculto__c = oculto;
        }

        index = ficherosVisiblesCase.findIndex(p => p.Id == contentVersion);
        if (index > -1) {
            ficherosVisiblesCase[index].SAC_Oculto__c = oculto;
        }

        index = ficherosAdjuntosFiltradoCase.findIndex(p => p.Id == contentVersion);
        if (index > -1) {
            ficherosAdjuntosFiltradoCase[index].SAC_Oculto__c = oculto;
        }

        component.set('v.ficherosAdjuntos',ficherosVisibles);
        component.set('v.ficherosAdjuntosVisibles', ficherosAdjuntosFiltrado);
        component.set('v.ficherosAdjuntosCase',ficherosVisiblesCase);
        component.set('v.ficherosAdjuntosVisiblesCase', ficherosAdjuntosFiltradoCase);

    },

    handleBlurHelper : function(component, event) {

        if(component.get('v.tipoDocCargado') !== null && component.get('v.tipoDocCargado') !== '' && component.get('v.tipoDocCargado') !== undefined){
            component.set('v.flagIdReCargado', component.get('v.adjuntoId'));
            component.set('v.tipoDocumento', component.get('v.tipoDocCargado'));
        }else{
            component.set('v.tipoDocumento', '');
        }
        
        component.set("v.saltarValidacion", false);
        component.set('v.ContentDocumentId', '');
        component.set('v.mostrarGrupos', false);        
        $A.util.removeClass(component.find('gruposCombobox'),'slds-is-open'); 
        $A.get('e.force:refreshView').fire();
    },

    filtroBusquedaHelper : function(component, event) {

        component.set("v.mensaje", '');
        var cadenaBusqueda = component.get('v.tipoDocumento');
        var options = component.get("v.opcionesMaestroAdjuntos");
        var caracteresMin = component.get('v.caracteresMin');
        if(cadenaBusqueda.length >= caracteresMin) {
            var flag = true;
            options.forEach( function(element,index) {
                if(element.Name.toLowerCase().trim().includes(cadenaBusqueda.toLowerCase().trim())) {
                    element.isVisible = true;
                    flag = false;
                } else {
                    element.isVisible = false;
                }
            });
            component.set("v.opcionesMaestroAdjuntos",options);
            if(flag) {
                component.set("v.mensaje", "No hay resultados para '" + cadenaBusqueda + "'");
                if(component.get('v.saltarValidacion') === false){
                    component.set('v.tipoDocumento', component.get('v.tipoDocCargado'));
                }
            }
        }
        $A.util.addClass(component.find('gruposCombobox'),'slds-is-open');
    },

    seleccionarGrupoHelper : function(component, event) {
        var options = component.get('v.opcionesMaestroAdjuntos');
        var grupoAbuscar = component.get('v.tipoDocumento');
        var value;
  
        options.forEach( function(element, index) {
            if(element.Name === event.currentTarget.id) {
                value = element.Name;
                grupoAbuscar = element.Name;

                // tenemos uqe pasaarle como id, el valor de la variable que hemos recogido en el controller 
                let asignarTipoAdjunto = component.get('c.asignarTipoAdjunto');
                asignarTipoAdjunto.setParams({'idAdjunto': component.get('v.adjuntoId'), 'ficherosAdjuntos': component.get('v.ficherosAdjuntos'), 'maestroAdjuntos': element});
                asignarTipoAdjunto.setCallback(this, function(response) {
                    var state = response.getState();
                    if(state === 'SUCCESS'){
                        component.set('v.value', value);
                        component.set('v.opcionesMaestroAdjuntos', options);
                        if(component.get('v.tipoDocCargado') !== null && component.get('v.tipoDocCargado') !== '' && component.get('v.tipoDocCargado') !== undefined){
                            component.set('v.flagIdReCargado', component.get('v.adjuntoId'));
                        }
                        component.set("v.saltarValidacion", false);
                        component.set('v.tipoDocumento', grupoAbuscar);
                        component.set('v.mostrarGrupos', false);
                
                        $A.util.removeClass(component.find('gruposCombobox'),'slds-is-open'); 
                        $A.get('e.force:refreshView').fire();
                    }
                    else{
                        var errors = response.getError();
                        let toastParams = {
                            title: "Error",
                            message: "Error al asociar un tipo de documento al adjunto seleccionado.", 
                            type: "error"
                        };
                        let toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams(toastParams);
                        toastEvent.fire();
                        $A.get('e.force:refreshView').fire();
                    }
                });
                $A.enqueueAction(asignarTipoAdjunto);
            }
        });       
    },

    mostrarOpcionesHelper : function( component, event, helper ) {

        let idRegistro = component.get('v.recordId');

        var tiposAdjuntos = component.get('c.recuperaTipoAdjuntos');
        tiposAdjuntos.setParams({'id':idRegistro});
        tiposAdjuntos.setCallback(this, function(response) {
        var state = response.getState();
        if(state === 'SUCCESS'){
            let opcionesMaestroAdjuntos = response.getReturnValue();
            component.set('v.opcionesMaestroAdjuntos', opcionesMaestroAdjuntos);

            if(opcionesMaestroAdjuntos != null){
                component.set("v.tipoDocCargado", event.getSource().get("v.value"));
                if(component.get('v.saltarValidacion') === false){
                    component.set("v.flagIdReCargado", '');
                }
                
                component.set('v.adjuntoId', event.getSource().get("v.name"));
                var disabled = component.get("v.disabled");
                component.set("v.mostrarGrupos", true);
    
                if(!disabled) {
                    component.set("v.mensaje", '');

                    if(component.get('v.saltarValidacion') === false){
                        component.set('v.tipoDocumento', '');
                    }
                    
                    var options = component.get("v.opcionesMaestroAdjuntos");
                    options.forEach( function(element,index) {
                        element.isVisible = true;
                    });
                    component.set("v.opcionesMaestroAdjuntos", options);
                    if(!$A.util.isEmpty(component.get('v.opcionesMaestroAdjuntos'))) {
                        $A.util.addClass(component.find('gruposCombobox'),'slds-is-open');
                    } 
                }
            }
        }else{
            var errors = response.getError();
            let toastParams = {
                title: "Error",
                message: 'Error al recuperar los maestros de temas de tipo adjunto', 
                type: "error"
            };
            let toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams(toastParams);
            toastEvent.fire();
            $A.get('e.force:refreshView').fire();
        }
        })
        $A.enqueueAction(tiposAdjuntos);
    },

    procesarBloquesClasificacion: function(component, resultBloques) {
        var fieldMap = [];
        for(var key in resultBloques){
            fieldMap.push({value: key, label: resultBloques[key]});
        }
        component.set("v.bloquesAdjunto", fieldMap);
    
        var bloquesAdjunto = component.get("v.bloquesAdjunto");
        // Crear un array para almacenar los nombres de las secciones (necesario para indicar que secciones deben aparecer abiertas por defecto)
        var nombresSecciones = [];
        // Iterar sobre los elementos de las secciones y extraer sus nombres
        bloquesAdjunto.forEach(function(bloque) {
            nombresSecciones.push(bloque.value);
        });
        // Establecer el valor de "v.activeSectionNames" con el array de nombres de secciones
        component.set("v.activeSectionNames", nombresSecciones);
    }
})