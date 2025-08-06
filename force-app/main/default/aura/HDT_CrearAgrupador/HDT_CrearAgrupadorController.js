({
    doInit: function (component, event, helper) {
        
        // Inicializar los datos.
        var sRecordId = component.get("v.recordId");
        var action = component.get("c.getAgrupadorCaso");
        var oCaso;
        var descripcion2 = "";


        action.setParams({'sRecordId': sRecordId});
        action.setCallback(this, function(response) {
            if (response.getState() === "SUCCESS") {
                var oMap = response.getReturnValue();
                oCaso = oMap["CASO"];
                var bCrear = false;
                var bAsociar = false;
                var bEstado = false;
                var bNotificado = false;
                if (oMap !== null) {
                    for (var key in oMap) {
                        if (key === "AGRUPADOR") {
                            component.set("v.oAgrupador", oMap[key]);
                            if (oMap[key] !== null) {
                                component.set("v.agrupadorId", oMap[key].Id);
                            }
                        } else if (key === "CASO") {
                            component.set("v.oCaso", oMap[key]);
                            var descripcion = oMap[key].CC_Detalles_Consulta__c;

                            //Nueva Funcionalidad para convertir saltos de linea /n por <br>
                            // Creado por Moisés Cano - 16-10-2023        
                            descripcion = descripcion.replace(/\n/g, "<br>");
                            component.set("v.oCaso.CC_Detalles_Consulta__c", descripcion);

                            var sAux = "";
                            if (oMap[key].CC_NotIncidencia__c === "1") {
                                sAux = "1";
                            } else if (oMap[key].CC_NotIncidencia__c === "2") {
                                sAux = "0";
                                bNotificado = true;
                            } else {
                                sAux = "0";
                            }
                            // Inicializar la marca de notificación.
                            component.find("bNotificar").set("v.value",sAux);
                        } else  if (key === "CONTACTNAME") {
                            component.set("v.sContactName", oMap[key]);
                        } else if (key === "RT_AGR") {
                            if (oMap[key] !== null) {
                                var oTemp = [];
                                var oMapAux = oMap[key];
                                var sPriVal = "";
                                for (var keyAux in oMapAux) {
                                    oTemp.push({value:oMapAux[keyAux], key:keyAux}); //Here we are creating the list to show on UI.
                                    if (sPriVal === "") {
                                        sPriVal = oMapAux[keyAux];
                                    }
                                }
                                component.set("v.oRTAgrup", oTemp);
                                component.set("v.oRTSel", sPriVal);
                            }
                        } else if (key === "GRUPO_DFLT") {
                            component.set("v.grupoDflt", oMap[key]);
                        } else if (key === "PERM_ASOCIAR") {
                            component.set("v.bAsociar", oMap[key]);
                            bAsociar = oMap[key];
                        } else if (key === "PERM_CREAR") {
                            component.set("v.bCrear", oMap[key]);
                            bCrear = oMap[key];
                        } else if (key === "PERM_ESTADO") {
                            component.set("v.bEstado", oMap[key]);
                            bEstado = oMap[key];
                        } else if (key === "CLASIFMAXIMO") {
                            component.set("v.sClasifMaximo", oMap[key]);
                        }
                    }
                    
                    // Gestión del estado inicial del caso.
                    if (!bEstado) {
                        bCrear = false;
                        bAsociar = false;
                    }
                    
                    // Un cliente notificado, no permite modificar de entrada.
                    var bModifCanal = true;
                    if (bNotificado || !bEstado) {
                        bModifCanal = false;
                    }
                    
                    // Gestión visual de datos.
                    var sAgrupadorIni = component.get("v.agrupadorId");
                    if (sAgrupadorIni !== null) {
                        if (sAgrupadorIni !== '') {
                            // Inicialización visual.
                            component.set("v.bNewInc", false);
                            component.set("v.bAsocInc", bAsociar);
                            component.set("v.bCasoInc", !bAsociar);
                            component.set("v.bPermiteAsociar",false);
                            component.set("v.bCanalNotif", bModifCanal);
                        } else {
                            // Inicialización visual.
                            component.set("v.bNewInc", bCrear);
                            component.set("v.bAsocInc", bAsociar);
                            component.set("v.bCasoInc", !bAsociar);
                            component.set("v.bPermiteAsociar",true);
                            component.set("v.bCanalNotif", bModifCanal);
                        }
                    } else {
                        // Inicialización visual.
                        component.set("v.bNewInc", bCrear);
                        component.set("v.bAsocInc", bAsociar);
                        component.set("v.bCasoInc", !bAsociar);
                        component.set("v.bPermiteAsociar",true);
                        component.set("v.bCanalNotif", bModifCanal);
                    }
                }
            }
        });
        $A.enqueueAction(action);

        component.set("v.cssStyle", "<style>.cuf-scroller-outside {background: rgb(255, 255, 255) !important;}</style>");
        
        component.set('v.oColumnas', [{label: 'Agrupador', fieldName: 'Name', type: 'text'},
                                        {label: 'Título', fieldName: 'CC_Titulo__c', type: 'text'},
                                        {label: 'Fecha detección', fieldName: 'CC_Fecha_Deteccion__c', type: 'date'}]);
       
    },

    

    validarDatosNotif: function(component, event, helper) {
        event.preventDefault();
        var fields = event.getParam("fields");
        var sNotif = component.find("bNotificar").get("v.value");
        
        var sCanal = '';
        var sDest = '';
        
        if (fields["CC_CanalNotifCli__c"] != null) {
            sCanal = fields["CC_CanalNotifCli__c"];
        }
        
        if (fields["CC_MailTelfNotif__c"] != null) {
            sDest = fields["CC_MailTelfNotif__c"];
        }
        
        sCanal = sCanal.trim();
        sDest = sDest.trim();
        
        if (sNotif == '1' && (sCanal == '' || sCanal != 'Twitter' && sDest == '')) {
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({"title": "Validación", "message": "Se han de informar todos los datos para la notificación de cierre.", "type": "error"});
            toastEvent.fire();
        } else {
            //Asignar nuevo valor.
            fields["CC_NotIncidencia__c"] = sNotif;
            
           	//Lanzar la actualización de los datos.
            component.find("editNotif").submit(fields);
        }
    },

    confirmarNotif: function(component, event, helper) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({"title": "Actualizado!", "message": "Canal de notificación del caso actualizado.", "type": "success"});
        toastEvent.fire();
    },

    errorDatosNotif: function(component, event, helper) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({"title": "Error","message": event.getParam('detail') ,"type": "error"});
        toastEvent.fire();
    },

    verAgrupActivos: function(component, event, helper) {
        let action = component.get("c.getAgrupadoresActivos");
        action.setCallback(this, function(response) {
            if (response.getState() === "SUCCESS") {
				component.set("v.oAgrActivos", response.getReturnValue());
                component.set("v.bVerAgrupActivos", true);
			}
        });
        $A.enqueueAction(action);
    },

    cerrarAgrupActivos: function(component, event, helper) {
        component.set("v.bVerAgrupActivos", false);
    },
    
    validarDatosCaso: function(component, event, helper) {
        event.preventDefault();
        var sCasoId = component.get("v.recordId");
		var action = component.get("c.validarCamposCaso");
        action.setParams({'sCasoId': sCasoId});
        action.setCallback(this, function(response) {
            if (response.getState() === "SUCCESS") {
                var result = response.getReturnValue();
                if (result != '') {
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({"title": "No se puede actualizar.","message": result,"type": "error"});
                    toastEvent.fire();
                } else {
                    var fields = event.getParam("fields");
                    // Lanzar la actualización de los datos.
                    component.find("asocAgrup").submit(fields);
                }
            }
        });
        $A.enqueueAction(action);

    },
    
    validarDatosCreacion: function(component, event, helper) {

        event.preventDefault();
        var sCasoId = component.get("v.recordId");
        var action = component.get("c.validarCamposCaso");
        action.setParams({'sCasoId': sCasoId});
        action.setCallback(this, function(response) {
            if (response.getState() === "SUCCESS") {
                var result = response.getReturnValue();
                if (result != '') {
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({"title": "No se puede actualizar.","message": result,"type": "error"});
                    toastEvent.fire();
                } else {
                    var fields = event.getParam("fields");
                    // Lanzar la actualización de los datos.
                    component.find("creaAgrup").submit(fields);
                }
            }
        });
        $A.enqueueAction(action);
    },
    
    confirmarAsoc: function(component, event, helper) {
        var sCasoId = component.get("v.recordId");
        var sAgrupadorId = component.find("CC_AgruapdorAsocId").get("v.value");
        
        var action = component.get("c.setAgrupadorCaso");
        action.setParams({'sCasoId': sCasoId, 'sAgrupadorId': sAgrupadorId});
        action.setCallback(this, function(response) {
            if (response.getState() === "SUCCESS") {
                var result = response.getReturnValue();
                if (result != '') {
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({"title": "No se puede actualizar.","message": result,"type": "error"});
                    toastEvent.fire();
                } else {
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({"title": "Actualizado!","message": "Agrupador del caso actualizado.","type": "success"});
                    toastEvent.fire();
                }
				$A.get('e.force:refreshView').fire();
            }
        });
        $A.enqueueAction(action);
        
        var bAsociar = component.get("v.bAsociar");
        var bCrear = component.get("v.bCrear");
        var bNotif = component.get("v.bCanalNotif");
        
        // Gestión visual.
        if (sAgrupadorId !== null) {
            if (sAgrupadorId !== '') {
                // Inicialización visual.
                component.set("v.bNewInc", false);
                component.set("v.bAsocInc", bAsociar);
                component.set("v.bCasoInc", !bAsociar);
                component.set("v.bPermiteAsociar", false);
                component.set("v.bCanalNotif", bNotif);
            } else {
                // Inicialización visual.
                component.set("v.bNewInc", bCrear);
                component.set("v.bAsocInc", bAsociar);
                component.set("v.bCasoInc", !bAsociar);
                component.set("v.bPermiteAsociar", true);
                component.set("v.bCanalNotif", bNotif);
            }
        } else {
            // Inicialización visual.
            component.set("v.bNewInc", bCrear);
            component.set("v.bAsocInc", bAsociar);
            component.set("v.bCasoInc", !bAsociar);
            component.set("v.bPermiteAsociar", true);
            component.set("v.bCanalNotif", bNotif);
        }
    },

    errorAsoc: function(component, event, helper) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({"title": "Error","message": event.getParam('detail') ,"type": "error"});
        toastEvent.fire();
    },

    selAgrupadorActivo: function(component, event, helper) {
        // Sólo se permite seleccionar un elemento.
        var selectedRows = event.getParam('selectedRows');
        //var setRows = []; Para selecciones de varios elementos.
        var sSel;
        for (var i = 0; i < selectedRows.length; i++ ) {
            sSel = selectedRows[i];
        }
        component.set("v.agrupadorSel", sSel);
    },

    asocAgrupadorActivo: function(component, event, helper) {
        var sSel = component.get("v.agrupadorSel");
        if (sSel != null) {
			component.find("CC_AgruapdorAsocId").set("v.value", sSel.Id);
            component.set("v.bVerAgrupActivos", false);
            
            // Lanzar submit.
            component.find("asocAgrup").submit();
        }
    },

    verAgrupadorActivo: function(component, event, helper) {
        var sSel = component.get("v.agrupadorSel");
        if (sSel != null) {
            var navEvt = $A.get("e.force:navigateToSObject");
            navEvt.setParams({"recordId": sSel.Id});
            navEvt.fire();
        }
    },

    verAgrupSel: function(component, event, helper) {
        var sSel = component.find("CC_AgruapdorAsocId").get("v.value");
        if (sSel != null) {
            var navEvt = $A.get("e.force:navigateToSObject");
            navEvt.setParams({"recordId": sSel});
            navEvt.fire();
        }
    },

    cambioTipo: function(component, event, helper) {
        var sSel = component.find("tipoAgrId").get("v.value");
        if (sSel != null) {
			component.set("v.oRTSel", sSel);
        }
    },

    confirmarCrea: function(component, event, helper) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({"title": "Creado!","message": "Agrupador del caso creado.","type": "success"});
        toastEvent.fire();
        
        var oResp = event.getParam("response");
        var sAgrupadorId = '';
        if (oResp != null) {
            sAgrupadorId = oResp.id;
            
            // Asignar el valor al formulario de asociación.
            component.find("CC_AgruapdorAsocId").set("v.value", sAgrupadorId);
        }

        var sCasoId = component.get("v.recordId");
        var action = component.get("c.setAgrupadorCaso");
        action.setParams({'sCasoId': sCasoId, 'sAgrupadorId': sAgrupadorId});
        action.setCallback(this, function(response) {
            if (response.getState() === "SUCCESS") {
				// PENDIENTE SI MOSTRAMOS ERROR.
				$A.get('e.force:refreshView').fire();
            }
        });
        $A.enqueueAction(action);
        
        var bAsociar = component.get("v.bAsociar");
        var bCrear = component.get("v.bCrear");
        var bNotif = component.get("v.bCanalNotif");
        
        // Gestión visual de datos.
        if (sAgrupadorId !== null) {
            if (sAgrupadorId !== '') {
                // Inicialización visual.
                component.set("v.bNewInc", false);
                component.set("v.bAsocInc", bAsociar);
                component.set("v.bCasoInc", !bAsociar);
                component.set("v.bPermiteAsociar", false);
                component.set("v.bCanalNotif", bNotif);
            } else {
                // Inicialización visual.
                component.set("v.bNewInc", bCrear);
                component.set("v.bAsocInc", bAsociar);
                component.set("v.bCasoInc", !bAsociar);
                component.set("v.bPermiteAsociar", true);
                component.set("v.bCanalNotif", bNotif);
            }
        } else {
            // Inicialización visual.
            component.set("v.bNewInc", bCrear);
            component.set("v.bAsocInc", bAsociar);
            component.set("v.bCasoInc", !bAsociar);
            component.set("v.bPermiteAsociar", true);
            component.set("v.bCanalNotif", bNotif);
        }
        
        if (sAgrupadorId != null) {
            if (sAgrupadorId != "") {
                var navEvt = $A.get("e.force:navigateToSObject");
                navEvt.setParams({"recordId": sAgrupadorId});
                navEvt.fire();
            }
        }
    },

	verAgrupadorAsoc: function(component, event, helper) {
        var sSel = component.get("v.agrupadorId");
        if (sSel != null) {
            var navEvt = $A.get("e.force:navigateToSObject");
            navEvt.setParams({"recordId": sSel});
            navEvt.fire();
        }
    },

    cambioNotif: function(component, event, helper) {
        component.set("v.sCanalNotif", event.getSource().get('v.value'));
    }
})