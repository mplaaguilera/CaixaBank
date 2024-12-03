({
	iniciar: function (component, event, helper) {
        var configReclamacionId = component.get("v.recordId");
        var configReclamacion = component.get("v.configReclamacion");
        configReclamacion.Id = configReclamacionId;
    },
    handleReclamacionSeleccionada: function (component, event,helper) {
        component.set("v.reclamacion",event.getParam("value"));
        component.set("v.reclamacionSeleccionada", true);
        helper.loadCarpetasOperativa(component,event,helper);     
    },
    handleCarpetaOperativaSeleccionada: function (component, event,helper) {
        component.set("v.carpetaOperativa",event.getParam("value"));
        helper.loadCarpetasIdioma(component,event,helper);     
    },
    handleCarpetaIdiomaSeleccionada: function (component, event,helper) {
        component.set("v.procesoFinalSeleccion", true);
        component.set("v.carpetaFinal",event.getParam("value"));
        helper.loadPlantillas(component,event,helper);     
    },
   handlePlantillaSeleccionada: function (component, event) {
       component.set("v.valido", true);
       var configReclamacion = component.get("v.configReclamacion");
       var configReclamacionId = component.get("v.recordId");
       var reclamacion = component.get("v.reclamacion");
       var opcionesPlantilla = component.get("v.opcionesPlantilla");
   
       if (component.get("v.carpetaFinal") == 'CC_Rec_Auto_Cliente_Cast' || component.get("v.carpetaFinal") == 'OS_Rec_Auto_Cliente_Cast'
            || component.get("v.carpetaFinal") == 'CC_Rec_Auto_Empleado_CSI_Bankia_Cast' )
       {
           	switch(reclamacion)
            {
                case '1':
                    configReclamacion.CC_Plantilla_1_Rec_Cliente_Cast__c = event.getParam("value");
                    opcionesPlantilla.forEach(function(valor,indice,lista){
                        if(valor.value ==  configReclamacion.CC_Plantilla_1_Rec_Cliente_Cast__c) {
                            configReclamacion.CC_Nombre_Plantilla_1_Rec_Cliente_Cast__c = valor.label;
                        }
                    });    
                    break;
                case '2':
                    configReclamacion.CC_Plantilla_2_Rec_Cliente_Cast__c = event.getParam("value");
                    opcionesPlantilla.forEach(function(valor,indice,lista){
                        if(valor.value ==  configReclamacion.CC_Plantilla_2_Rec_Cliente_Cast__c) {
                            configReclamacion.CC_Nombre_Plantilla_2_Rec_Cliente_Cast__c = valor.label;
                        }
                    });  
                    break;
                case '3':
                    configReclamacion.CC_Plantilla_3_Rec_Cliente_Cast__c = event.getParam("value");
                    opcionesPlantilla.forEach(function(valor,indice,lista){
                        if(valor.value ==  configReclamacion.CC_Plantilla_3_Rec_Cliente_Cast__c) {
                            configReclamacion.CC_Nombre_Plantilla_3_Rec_Cliente_Cast__c = valor.label;
                        }
                    });  
                    break;
            }
            
       }
       else if (component.get("v.carpetaFinal") == 'CC_Rec_Auto_Cliente_Cat' || component.get("v.carpetaFinal") == 'OS_Rec_Auto_Cliente_Cat')
       {
        	switch(reclamacion)
            {
                case '1':
                    configReclamacion.CC_Plantilla_1_Rec_Cliente_Cat__c = event.getParam("value");
                    opcionesPlantilla.forEach(function(valor,indice,lista){
                        if(valor.value ==  configReclamacion.CC_Plantilla_1_Rec_Cliente_Cat__c) {
                            configReclamacion.CC_Nombre_Plantilla_1_Rec_Cliente_Cat__c = valor.label;
                        }
                    });    
                    break;
                case '2':
                    configReclamacion.CC_Plantilla_2_Rec_Cliente_Cat__c = event.getParam("value");
                    opcionesPlantilla.forEach(function(valor,indice,lista){
                        if(valor.value ==  configReclamacion.CC_Plantilla_2_Rec_Cliente_Cat__c) {
                            configReclamacion.CC_Nombre_Plantilla_2_Rec_Cliente_Cat__c = valor.label;
                        }
                    });  
                    break;
                case '3':
                    configReclamacion.CC_Plantilla_3_Rec_Cliente_Cat__c = event.getParam("value");
                    opcionesPlantilla.forEach(function(valor,indice,lista){
                        if(valor.value ==  configReclamacion.CC_Plantilla_3_Rec_Cliente_Cat__c) {
                            configReclamacion.CC_Nombre_Plantilla_3_Rec_Cliente_Cat__c = valor.label;
                        }
                    });  
                    break;
            }
       }
       else if (component.get("v.carpetaFinal") == 'CC_Rec_Auto_Colaborador_Cast' || component.get("v.carpetaFinal") == 'OS_Rec_Auto_Colaborador_Cast'
                || component.get("v.carpetaFinal") == 'CC_Rec_Auto_Colaborador_CSI_Bankia_Cast' || component.get("v.carpetaFinal") == 'AM_Rec_Auto_Colaborador_Cast'
                || component.get("v.carpetaFinal") == 'SACH_Rec_Auto_Colaborador_Cast' || component.get("v.carpetaFinal") == 'HDT_Rec_Auto_Colaborador_Cast'
                || component.get("v.carpetaFinal") == 'GRR_Rec_Auto_Colaborador_Cast')
       {
          	switch(reclamacion)
            {
                case '1':
                    configReclamacion.CC_Plantilla_1_Rec_Colab_Cast__c = event.getParam("value");
                    opcionesPlantilla.forEach(function(valor,indice,lista){
                        if(valor.value ==  configReclamacion.CC_Plantilla_1_Rec_Colab_Cast__c) {
                            configReclamacion.CC_Nombre_Plantilla_1_Rec_Colab_Cast__c = valor.label;
                        }
                    });    
                    break;
                case '2':
                    configReclamacion.CC_Plantilla_2_Rec_Colab_Cast__c = event.getParam("value");
                    opcionesPlantilla.forEach(function(valor,indice,lista){
                        if(valor.value ==  configReclamacion.CC_Plantilla_2_Rec_Colab_Cast__c) {
                            configReclamacion.CC_Nombre_Plantilla_2_Rec_Colab_Cast__c = valor.label;
                        }
                    });  
                    break;
                case '3':
                    configReclamacion.CC_Plantilla_3_Rec_Colab_Cast__c = event.getParam("value");
                    opcionesPlantilla.forEach(function(valor,indice,lista){
                        if(valor.value ==  configReclamacion.CC_Plantilla_3_Rec_Colab_Cast__c) {
                            configReclamacion.CC_Nombre_Plantilla_3_Rec_Colab_Cast__c = valor.label;
                        }
                    });  
                    break;
            }
       }
       else if (component.get("v.carpetaFinal") == 'CC_Rec_Auto_Colaborador_Cat' || component.get("v.carpetaFinal") == 'OS_Rec_Auto_Colaborador_Cat'
                || component.get("v.carpetaFinal") == 'AM_Rec_Auto_Colaborador_Cat' || component.get("v.carpetaFinal") == 'SACH_Rec_Auto_Colaborador_Cat' 
                || component.get("v.carpetaFinal") == 'HDT_Rec_Auto_Colaborador_Cat' || component.get("v.carpetaFinal") == 'GRR_Rec_Auto_Colaborador_Cat')
       {
           	switch(reclamacion)
            {
                case '1':
                    configReclamacion.CC_Plantilla_1_Rec_Colab_Cat__c = event.getParam("value");
                    opcionesPlantilla.forEach(function(valor,indice,lista){
                        if(valor.value ==  configReclamacion.CC_Plantilla_1_Rec_Colab_Cat__c) {
                            configReclamacion.CC_Nombre_Plantilla_1_Rec_Colab_Cat__c = valor.label;
                        }
                    });    
                    break;
                case '2':
                    configReclamacion.CC_Plantilla_2_Rec_Colab_Cat__c = event.getParam("value");
                    opcionesPlantilla.forEach(function(valor,indice,lista){
                        if(valor.value ==  configReclamacion.CC_Plantilla_2_Rec_Colab_Cat__c) {
                            configReclamacion.CC_Nombre_Plantilla_2_Rec_Colab_Cat__c = valor.label;
                        }
                    });  
                    break;
                case '3':
                    configReclamacion.CC_Plantilla_3_Rec_Colab_Cat__c = event.getParam("value");
                    opcionesPlantilla.forEach(function(valor,indice,lista){
                        if(valor.value ==  configReclamacion.CC_Plantilla_3_Rec_Colab_Cat__c) {
                            configReclamacion.CC_Nombre_Plantilla_3_Rec_Colab_Cat__c = valor.label;
                        }
                    });  
                    break;
            }
       } 
    },

    handleClickAceptar: function(component,event,helper) {
        var configReclamacion = component.get("v.configReclamacion");     
        var action = component.get("c.guardar");
        action.setParams({
            'confRec': configReclamacion
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                helper.showToast(component,event,helper);
                $A.enqueueAction(component.get('c.handleClickCancelar'));
            }
        });
        $A.enqueueAction(action);
        
    },
    handleClickCancelar : function(component, event, helper) {
        //$A.get("e.force:closeQuickAction").fire(); 
        component.set("v.reclamacionSeleccionada", false);
        component.set("v.carpetaOperativaSeleccionada", false);
        component.set("v.procesoFinalSeleccion", false);
        component.set("v.valido", false);
        component.set("v.carpetaOperativa", false);
        component.set("v.carpetaIdiomaSeleccionada", false);
        component.set("v.reclamacion", "");
        component.find("selectItem1").set("v.value", "");     
        $A.get('e.force:refreshView').fire();
    }
})