({
    init: function(component) {
        var getPicklistClasificacionesMaximo = component.get("c.getPicklistClasificacionesMaximo");
        getPicklistClasificacionesMaximo.setParams({ "recordId": component.get("v.recordId") });
        getPicklistClasificacionesMaximo.setCallback(this, function(response) {
            if (response.getState() === "SUCCESS") {
                component.set("v.clasificacionesMaximo", response.getReturnValue());
            }
        });
        $A.enqueueAction(getPicklistClasificacionesMaximo);
        
        var getPicklistGruposMaximo = component.get("c.getPicklistGruposMaximo");
        getPicklistGruposMaximo.setCallback(this, function(response) {
            if (response.getState() === "SUCCESS") {
                component.set("v.gruposMaximo", response.getReturnValue());
            }
        });
        $A.enqueueAction(getPicklistGruposMaximo);

        var getPicklistOpcionCallCenter = component.get("c.getPicklistOpcionCallCenter");
        getPicklistOpcionCallCenter.setCallback(this, function(response) {
            if (response.getState() === "SUCCESS") {
                component.set("v.opcionesCallCenter", response.getReturnValue());
            }
        });
        $A.enqueueAction(getPicklistOpcionCallCenter);

        var getValoresIniciales = component.get("c.getValoresIniciales");
        getValoresIniciales.setParams({ "recordId": component.get("v.recordId") });
        getValoresIniciales.setCallback(this, function(response) {
            if (response.getState() === "SUCCESS") {
                var obj = response.getReturnValue();
                component.set('v.rtGrupo', obj.rt);
                if (obj.agrupador.CC_GrupoMaximo__c != null && obj.agrupador.CC_GrupoMaximo__r.Name != undefined) {
                    var gruposMaximo = component.get("v.gruposMaximo");
                    for (var key in gruposMaximo) {
                        if (obj.agrupador.CC_GrupoMaximo__r.Name == gruposMaximo[key].label) {
                            //Se setean los atributos
                            component.set("v.grupoMaximoSelectValue", gruposMaximo[key].value);
                            component.set("v.grupoMaximoSelectName", gruposMaximo[key].label);
    
                            //Se setea el valor visible del desplegable
                            component.find("grupomaximo").set("v.value", gruposMaximo[key].value);
                        }
                    }
                }

                if (obj.agrupador.CC_Opcion_Call_Center__c != undefined) {
                    var opcionesCallCenter = component.get("v.opcionesCallCenter");
                    for (var key in opcionesCallCenter) {
                        if (obj.agrupador.CC_Opcion_Call_Center__c == opcionesCallCenter[key].label) {
                            //Se setean los atributos
                            component.set("v.opcionCallCenterSelectValue", opcionesCallCenter[key].value);
                            component.set("v.opcionCallCenterSelectName", opcionesCallCenter[key].label);
    
                            //Se setea el valor visible del desplegable
                            component.find("opcioncallcenter").set("v.value", opcionesCallCenter[key].value);
                        }
                    }
                }

                
                if (obj.agrupador.CC_Clasificacion_Maximo__c != undefined && obj.agrupador.CC_Clasificacion_Maximo__r.CC_Path__c != undefined) {
                    var clasificacionesMaximo = component.get("v.clasificacionesMaximo");
                    for (var key in clasificacionesMaximo) {
                        
                        if (obj.agrupador.CC_Clasificacion_Maximo__r.CC_Path__c == clasificacionesMaximo[key].label) {
                            //Se setean los atributos
                            component.set("v.clasificacionMaximoSelectValue", clasificacionesMaximo[key].value);
                            component.set("v.clasificacionMaximoSelectName", clasificacionesMaximo[key].label);
                            //Se setea el valor visible del desplegable
                            component.find("clasificacionmaximo").set("v.value", clasificacionesMaximo[key].value);
                            
                        }
                    }
                }
            }
        });
        $A.enqueueAction(getValoresIniciales);
    },

    guardar: function(component) {
        component.set('v.botonGuardar', true);
        var actualizaAgrupador = component.get("c.actualizaAgrupador");
        
        if(component.get('v.activarBuscador')){
            actualizaAgrupador.setParams({
                'recordId': component.get("v.recordId"),
                'clasificacionMaximo': component.get("v.valorClasificacionBuscador"), //Clasificación
                'grupoMaximo': component.get("v.valorGrupoBuscador"), //Id
                'opcionCallCenter': component.get("v.opcionCallCenterSelectName"), //Nombre
                'esBuscador': true
            });
        }
        else{
            actualizaAgrupador.setParams({
                'recordId': component.get("v.recordId"),
                'clasificacionMaximo': component.get("v.clasificacionMaximoSelectValue"), //Clasificación
                'grupoMaximo': component.get("v.grupoMaximoSelectValue"), //Id
                'opcionCallCenter': component.get("v.opcionCallCenterSelectName"), //Nombre
                'esBuscador': false
            });
        }
        
        actualizaAgrupador.setCallback(this, function(response) {
            if (response.getState() == "SUCCESS") {
                let toastEvent = $A.get('e.force:showToast');
                toastEvent.setParams({'title': 'Modificación completada', 'message': 'Se han actualizado los datos correctamente', 'type': 'success', 'duration': 4000});
                component.set('v.botonGuardar', false);
                toastEvent.fire();
                $A.get('e.force:refreshView').fire();
            }
            else{
                let toastEvent = $A.get('e.force:showToast');
                toastEvent.setParams({'title': 'Modificación fallida', 'message': response.getError(), 'type': 'error', 'duration': 4000});
                component.set('v.botonGuardar', false);
                toastEvent.fire();
            }
        });
        $A.enqueueAction(actualizaAgrupador);
    },

    seleccionaClasificacionMaximo: function(component, event) {
        var actualOption = event.getParam("value"); //Id

        var clasificacionesMaximo = component.get("v.clasificacionesMaximo");
        for (var key in clasificacionesMaximo) {
            if (actualOption === clasificacionesMaximo[key].value) {
                //Se setean los atributos
                component.set("v.clasificacionMaximoSelectValue", clasificacionesMaximo[key].value);
                component.set("v.clasificacionMaximoSelectName", clasificacionesMaximo[key].label);                
            }
        }
    },
    
    seleccionaGrupoMaximo: function(component, event) {
        var actualOption = event.getParam("value"); //Id

        var gruposMaximo = component.get("v.gruposMaximo");
        for (var key in gruposMaximo) {
            if (actualOption === gruposMaximo[key].value) {
                //Se setean los atributos
                component.set("v.grupoMaximoSelectValue", gruposMaximo[key].value);
                component.set("v.grupoMaximoSelectName", gruposMaximo[key].label);
            }
        }
    },

    seleccionaOpcionCallCenter: function(component, event) {
        var actualOption = event.getParam("value"); //Id

        var opcionesCallCenter = component.get("v.opcionesCallCenter");
        for (var key in opcionesCallCenter) {
            if (actualOption === opcionesCallCenter[key].value) {
                //Se setean los atributos
                component.set("v.opcionCallCenterSelectValue", opcionesCallCenter[key].value);
                component.set("v.opcionCallCenterSelectName", opcionesCallCenter[key].label);               
            }
        }
    },
    
    //Buscador de clasificaciones
    searchField: function(component, event) {
        var currentText = event.getSource().get("v.value");
        var resultBox = component.find('resultBox');
        component.set("v.LoadingText", true);
        if (currentText.length > 0) {
            $A.util.addClass(resultBox, 'slds-is-open');
        } else {
            $A.util.removeClass(resultBox, 'slds-is-open');
        }

        var action = component.get("c.getResults");
        action.setParams({
            "ObjectName": component.get("v.objectName"),
            "fieldName": component.get("v.fieldName"),
            "value": currentText,
            "propietario": component.get("v.propietario")
        });
        action.setCallback(this, function(response){
            if (response.getState() === "SUCCESS") {
                component.set("v.searchRecords", response.getReturnValue());
                if (component.get("v.searchRecords").length == 0) {
                    console.log('000000');
                }
            }
            else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " +
                                    errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }
            }
            component.set("v.LoadingText", false);
        });
        
        $A.enqueueAction(action);
    },
    
    setSelectedRecord : function(component, event) {
        var currentText = event.currentTarget.id;
        var resultBox = component.find('resultBox');
        $A.util.removeClass(resultBox, 'slds-is-open');
        //component.set("v.selectRecordName", currentText);
        component.set("v.selectRecordName", event.currentTarget.dataset.name);
        component.set("v.selectRecordId", currentText);
        component.set("v.clasificacionMaximoSelectValue", currentText);
        component.find('userinput').set("v.readonly", true);
    },
    
    resetData : function(component) {
        component.set("v.selectRecordName", "");
        component.set("v.selectRecordId", "");
        component.set("v.clasificacionMaximoSelectValue", "--Ninguno--");
        component.find('userinput').set("v.readonly", false);
    },
    
    handleChange: function (component) {
        
        var unchecked = component.get("v.activarBuscador");
        if (unchecked) {
            component.set("v.activarBuscador", false);
        } else {
            component.set("v.activarBuscador", true);
        }
    },

    modificacionTexoBuscador:  function (component, event) {
        let currentText = event.getSource().get("v.value");
        let id = event.getSource().getLocalId();
        let tamañoTexto = currentText.length;

        if( id === "clasificacionmaximo"){
            component.set("v.valorClasificacionBuscador", currentText);
            if(tamañoTexto > 3){
                //defino el metodo del controller al que necesito llamar
                //orden de ejecucion 1
                let consultaQuery = component.get("c.recuperarClasificacion");
                //defino los valores a pasarle a los parametros del metodo
                //orden de ejecucion 2
                consultaQuery.setParams({"cadenaBusqueda" : currentText});
                //defino comportamiento una vez que traigo los valores que seria la respuesta
                //orden de ejecucion 4
                consultaQuery.setCallback(this, function(response){
                    if (response.getState() === "SUCCESS") {
                       let respuesta = response.getReturnValue();
                       component.set('v.listaBuscadorClasificacion', respuesta);                      
                    }
                })
                //Encolar la ejecucion del metodo apex
                //orden de ejecucion 3 
                $A.enqueueAction(consultaQuery);
            }
        }
        else if (id === "grupomaximo"){
            component.set("v.valorGrupoBuscador", currentText);
            if(tamañoTexto > 3){
                let consultaQuery = component.get("c.recuperarGrupos");
                consultaQuery.setParams({"cadenaBusqueda" : currentText});
                consultaQuery.setCallback(this, function(response){
                    if (response.getState() === "SUCCESS") {
                        let respuesta = response.getReturnValue();               
                        component.set('v.listaBuscadorGrupo', respuesta);                       
                    }
                })

                $A.enqueueAction(consultaQuery);
            }
        }

    },

    guardarVariable: function(component, event) {
        let rt = event.currentTarget.title;
        if(rt == component.get('v.rtGrupo')){
            let grupoSeleccionado = component.get('v.listaBuscadorGrupo').find(clasificacion => clasificacion.Id === event.currentTarget.id);
            component.set('v.valorGrupoBuscador', grupoSeleccionado.Name);    
            component.set('v.listaBuscadorGrupo', null);
        }
        else{
            let clasificadorSeleccionado = component.get('v.listaBuscadorClasificacion').find(clasificacion => clasificacion.Id === event.currentTarget.id);
            component.set('v.valorClasificacionBuscador', clasificadorSeleccionado.Name);    
            component.set('v.listaBuscadorClasificacion', null);
        }
	}

})