({
    traerGrupos :function(component, event){
        //Traer los grupos de derivacion o consultas
        let buscarGrupos = component.get('c.buscarGrupos');
        buscarGrupos.setParams({'derivacionOconsulta': component.get("v.derivacionOconsulta")});
        buscarGrupos.setCallback(this, function(response) {
			let state = response.getState();
            if (state === "SUCCESS") {
                let respuestaGrupos = response.getReturnValue();
                component.set('v.grupos', respuestaGrupos);
                component.set('v.options', respuestaGrupos);
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

        $A.enqueueAction(buscarGrupos);
    },

    handleBlurHelper : function(component, event) {
        var selectedValue = component.get('v.value');
        var previousLabel;
        var count = 0;
        var options = component.get("v.options");
        options.forEach( function(element, index) {
            if(element.Name === selectedValue) {
                previousLabel = element.Name;
            }
            if(element.selected) {
                count++;
            }
        });

        component.set('v.grupoAbuscar', previousLabel);
    },

    filtroBusquedaHelper : function(component, event) {
        component.set("v.mensaje", '');
        var cadenaBusqueda = component.get('v.grupoAbuscar');
        var options = component.get("v.options");
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
            component.set("v.options",options);
            if(flag) {
                component.set("v.mensaje", "No hay resultados para '" + cadenaBusqueda + "'");
                component.set('v.grupoAbuscar', cadenaBusqueda);
            }
        }
        $A.util.addClass(component.find('gruposCombobox'),'slds-is-open');
    },

    seleccionarGrupoHelper : function(component, event) {
        var options = component.get('v.options');
        var grupoAbuscar = component.get('v.grupoAbuscar');
        var grupoAbuscarId = component.get('v.grupoAbuscar');
        var paraGrupo = component.get('v.paraGrupo');
        var copiaGrupo = component.get('v.copiaGrupo');
        var value;
  
        options.forEach( function(element, index) {
            if(element.Name === event.currentTarget.id) {
                value = element.Name;
                grupoAbuscar = element.Name;
                grupoAbuscarId = element.Id;
                if(element.SAC_Email__c != null){
                    paraGrupo = element.SAC_Email__c; 
                }else{
                    paraGrupo = '';
                }
                if(element.SAC_Email2__c != null || element.SAC_Email3__c != null){
                    if(element.SAC_Email2__c != null && element.SAC_Email3__c != null){
                        copiaGrupo = element.SAC_Email2__c + ';' + element.SAC_Email3__c;
                    }
                    else if(element.SAC_Email2__c != null && element.SAC_Email3__c == null){
                        copiaGrupo = element.SAC_Email2__c;
                    }
                    else if(element.SAC_Email2__c == null && element.SAC_Email3__c != null){
                        copiaGrupo = element.SAC_Email3__c;
                    }
                }
                else{
                    copiaGrupo = ''; 
                }      
            }
        });

        component.set('v.value', value);
        component.set('v.options', options);
        component.set('v.grupoAbuscar', grupoAbuscar);
        component.set('v.grupoAbuscarId', grupoAbuscarId);
        component.set('v.paraGrupo', paraGrupo);
        component.set('v.copiaGrupo', copiaGrupo);
        component.set('v.mostrarGrupos', false);

        $A.util.removeClass(component.find('gruposCombobox'),'slds-is-open'); 
    },

    confirmarSeleccionHelper : function(component, event) {
        
        component.set('v.para', component.get('v.paraGrupo'));
        component.set('v.CC', component.get('v.copiaGrupo'));
        component.set('v.grupoAbuscar', '');
        component.set('v.grupoAbuscarId', '');
        component.set('v.isLoading', false);     
    },


    cambiarContactoReclamante : function(component, event){
        var reclamante = component.get('v.reclamanteSelected');
        console.log('Kevin: ' + reclamante);

        // Llamar al método de Apex
        var action = component.get("c.cambiarContactoReclamante");
        action.setParams({
            reclamanteId: reclamante,
            idCaso: component.get("v.recordId")
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                // Manejar la respuesta si es necesario
                 var doInitAction = component.get("c.doInit");
            $A.enqueueAction(doInitAction);
                component.set('v.isLoading', false);   
            } else {
                // Manejar errores si ocurren
            }
        });
        $A.enqueueAction(action);

        

        
    }
})