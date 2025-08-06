({

    handleCarpetaOperativaSeleccionada: function (component, event,helper) {
        
        component.set("v.carpetaOperativa",event.getParam("value"));
        helper.loadCarpetasIdioma(component,event,helper);       
    },

    handleCarpetaIdiomaSeleccionada: function (component, event,helper) {
        
        component.set("v.procesoFinalSeleccion", true);
        component.set("v.carpetaFinal",event.getParam("value"));
        var carpetaFinaltest = component.get("v.carpetaFinal");
        helper.loadPlantillas(component,event,helper);     
    },
    
    seleccionarPlantilla: function(component, event, helper) {
        component.set("v.plantillaSeleccionada", true);
        var actualOption = event.getParam("value");
        var optionsPlantilla = component.get("v.opcionesPlantilla");
        for (let key in optionsPlantilla) {
             if (event.getParam("value") === optionsPlantilla[key].value) {
                 
                 component.set("v.plantillaSeleccionadaValue", optionsPlantilla[key].value);
                 component.set("v.plantillaSeleccionadaName", optionsPlantilla[key].label);
                 
             }
        }  
        console.log ('@@ actualOption = ' + actualOption);
    },
    
    
    
    cargarPlantilla: function(component, event, helper) {
        console.log('%% cargarPlantilla: dentro');
        var listCC = [];
        var listPara = [];
        var recordId = component.get("v.recordId");       
        var plantilla = component.get("v.plantillaSeleccionadaValue");
        
        var action = component.get("c.buscarColaborador");
         
        action.setParams({'agrupadorId': recordId});
        action.setCallback(this, function(response) {
            console.log('%% cargarPlantilla: buscarColaborador');
            if (response.getState() === "SUCCESS") {
                var direcciones = response.getReturnValue();
                for (var indice in direcciones) {
                    if (direcciones[indice] == 'Para') {
                        listPara.push(indice);
                    } else if (direcciones[indice] == 'CC') {
						listCC.push(indice);
                    }
                }
               var update = component.get("c.actualizarAgrupador");        
        	   update.setParams({'idAgrupador': recordId,
                          		 'plantilla': plantilla});
        	   update.setCallback(this, function(response) {
                    if (response.getState() === 'SUCCESS') {
                        var actionAPI = component.find("quickActionAPI");
                        var args = { actionName: "CC_Agrupador__c.CC_Send_Email", 
                                    targetFields: { ToAddress:  {value: listPara},
                                                    CcAddress:  {value: listCC},
                                                    BccAddress: {value: ''}}}; 
                        actionAPI.selectAction(args).then(() => {
                            actionAPI.setActionFieldValues(args);
                            
                        }).catch(function(e) {
                            if (e.errors) {
                                console.log('ERROR preparando el borrador del correo saliente.');
                            }
                        });
                        
                    }else {
                        console.log('ERROR recuperando dirección de correo del colaborador.');
                        
                    }
        		});
                $A.enqueueAction(update);
       
                $A.enqueueAction(component.get('c.cerrarModalEnviarCorreo'));
                $A.get('e.force:refreshView').fire();
                helper.showToast (component, event, helper);
                
            } else {
                alert('Error: ' + JSON.stringify(response.errors));
            }            
            
            
        });
		$A.enqueueAction(action);
        
        
                 
    },

    abrirModalEnviarCorreo: function(component,event,helper){
        helper.loadCarpetasOperativa(component,event,helper); 
        $A.util.addClass(component.find('ModalboxEnviarCorreoAgrupador'), 'slds-fade-in-open');
        $A.util.addClass(component.find('ModalbackdropEnviarCorreo'), 'slds-backdrop--open');
     },
                    
    cerrarModalEnviarCorreo: function(component) { 
        $A.util.removeClass(component.find('ModalboxEnviarCorreoAgrupador'), 'slds-fade-in-open');
        $A.util.removeClass(component.find('ModalbackdropEnviarCorreo'), 'slds-backdrop--open');
        
    },
                    
    
    handleClickCancelar : function(component, event, helper) {
        $A.get("e.force:closeQuickAction").fire(); 
    }
})