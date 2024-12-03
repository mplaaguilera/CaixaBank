({
    doInit : function(component, event, helper) {
        //obtener info 
        var action = component.get('c.obtenerDatosEmail');
        action.setParams({'idCaso': component.get("v.recordId"), 'soloEmail': true});

        action.setCallback(this, function(response) {
			var state = response.getState();
            if (state === "SUCCESS") { 
                var wrapper = response.getReturnValue(); 

                component.set('v.para', wrapper.para);
                component.set('v.asunto', wrapper.asunto);
                component.set('v.cuerpo', wrapper.cuerpo);
                component.set('v.copia', wrapper.copia);
                component.set('v.caso', wrapper.caso);

                /*component.set('v.ficherosAdjuntos', wrapper.adjuntos);*/
                var procedencia = 'Consulta';
                component.set('v.procedencia', procedencia);

                let RecoPret = component.get('c.comprobrarRecordType'); 
                RecoPret.setParams({'idCaso': component.get("v.recordId")});
                RecoPret.setCallback(this, function(response){
                    let state = response.getState();
                    if (state === "SUCCESS") {
                        let respuesta = response.getReturnValue(); 
                        component.set('v.esReclamacionoPretension', respuesta);
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
                $A.enqueueAction(RecoPret);
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
        $A.enqueueAction(action);       
    },

    abrirModalGruposDerivacion : function(component, event, helper){ 
		//component.set('v.isLoading', true);
        component.set('v.derivacionOconsulta', 'derivar');
        component.set('v.labelInformacion', 'Selecciona el grupo de derivación');
		component.set('v.modalSeleccion', true);
        helper.traerGrupos(component, event);
	},

    abrirModalGruposConsulta : function(component, event, helper){
		//component.set('v.isLoading', true);
        component.set('v.derivacionOconsulta', 'consulta');
        component.set('v.labelInformacion', 'Selecciona el grupo de consultas');
		component.set('v.modalSeleccion', true);
        helper.traerGrupos(component, event);
	},

    cerrarModalSeleccion: function (component) {
        component.set('v.grupoAbuscar', '');
        component.set('v.grupoAbuscarId', '');
        //component.set('v.options', '');
        component.set('v.mostrarGrupos', false);  
        component.set("v.modalSeleccion", false);
    },

    handleBlur : function( component, event, helper ){
        helper.handleBlurHelper(component, event);
    },

    mostrarOpciones : function( component, event, helper ) {
        var disabled = component.get("v.disabled");
        component.set("v.mostrarGrupos", true);

        if(!disabled /*&& component.get("v.cerrar") == 0*/) {
            component.set("v.mensaje", '');
            component.set('v.grupoAbuscar', '');
            var options = component.get("v.options");
            options.forEach( function(element,index) {
                element.isVisible = true;
            });
            component.set("v.options", options);
            if(!$A.util.isEmpty(component.get('v.options'))) {
                $A.util.addClass(component.find('gruposCombobox'),'slds-is-open');
            } 
        }
    },

    filtroBusqueda : function( component, event, helper ) {
        if( !$A.util.isEmpty(component.get('v.grupoAbuscar')) ) {
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
                //$A.util.removeClass(component.find('resultsDiv'),'slds-is-open');
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

    confirmarSeleccion: function (component, event, helper) {
        component.set('v.isLoading', true); 
        component.set("v.modalSeleccion", false);

        helper.confirmarSeleccionHelper(component, event);
    }
})