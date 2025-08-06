({
    init : function(component, event, helper) { 

       var mostrarLosBotones = component.get('c.mostrarBotones');
       mostrarLosBotones.setParams({
           'tareaId':component.get('v.recordId'),
           'idUser': $A.get('$SObjectType.CurrentUser.Id') 
       });

       mostrarLosBotones.setCallback(this, function(response){
           var state = response.getState();
           if (state === "SUCCESS") { 
                
                let array = JSON.stringify(response.getReturnValue());
                
                if(array[1] == 1){                     
                    component.set('v.mostrarTomarPropiedad', true);
                }else{
                    component.set('v.mostrarTomarPropiedad', false);
                }

                if(array[2] == 1){ 
                    component.set('v.mostrarFinalizarTarea', true);
                }else{
                    component.set('v.mostrarFinalizarTarea', false);
                }
                
                if(array[3] == 1){ 
                    component.set('v.mostrarDevolver', true);
                }else{
                    component.set('v.mostrarDevolver', false);
                }

                if(array[4] == 1){ 
                    component.set('v.mostrarProrrogar', true);
                }else{
                    component.set('v.mostrarProrrogar', false);
                }

                if(array[5] == 1){ 
                    component.set('v.mostrarNotificar', true);
                }else{
                    component.set('v.mostrarNotificar', false);
                }

                if(array[6] == 1){ 
                    component.set('v.mostrarEnvioTarea', true);
                }else{
                    component.set('v.mostrarEnvioTarea', false);
                }

                if(array[7] == 1){ 
                    component.set('v.mostrarDevolverGestLet', true);
                }else{
                    component.set('v.mostrarDevolverGestLet', false);
                }
               
           }
       });
       

       setTimeout(function(){ $A.enqueueAction(mostrarLosBotones);  }, 400);

    },

    tomarPropiedad : function(component, event, helper) {

        /*var spinner = component.find('mySpinner');
        $A.util.removeClass(spinner, "slds-hide");*/
        component.set('v.isLoading', true); 

        var tomarEnPropiedad = component.get('c.tomarPropiedadTarea');
        tomarEnPropiedad.setParams({
            'tareaId':component.get('v.recordId'),
            'idUser':$A.get('$SObjectType.CurrentUser.Id')
        });

        tomarEnPropiedad.setCallback(this, function(response){
            var estado = response.getState();
            if(estado == "SUCCESS"){
                //$A.util.addClass(spinner, "slds-hide");
                component.set('v.isLoading', false); 
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Éxito!",
                    "message": "Se ha cambiado el propietario correctamente.",
                    "type": "success"
                });
                toastEvent.fire(); 
                $A.get('e.force:refreshView').fire(); 
                
            }
        })

        $A.enqueueAction(tomarEnPropiedad); 
        
    },

    

    devolverLaTarea : function(component, event, helper) {

        /*var spinner = component.find('mySpinner');
        $A.util.removeClass(spinner, "slds-hide");*/
        component.set('v.isLoading', true); 

        var devolverTarea = component.get('c.devolverTarea');
        devolverTarea.setParams({
            'tareaId':component.get('v.recordId'),
            'idUser':$A.get('$SObjectType.CurrentUser.Id')
        });

        devolverTarea.setCallback(this, function(response){
            var estado = response.getState();
            if(estado == "SUCCESS"){
                //$A.util.addClass(spinner, "slds-hide");
                component.set('v.isLoading', false); 
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Éxito!",
                    "message": "La tarea ha sido devuelta",
                    "type": "success"
                });
                toastEvent.fire(); 
                component.set('v.mostrarDevolver', false);
                $A.get('e.force:refreshView').fire();               
            }
        })

        $A.enqueueAction(devolverTarea); 
    },

    devolverTareaGestLet : function(component, event, helper) {
        //Controlar que el campo motivo esté lleno
        let motivo = component.get('v.motivoDevolver');
        if (motivo == null || motivo == '' || motivo == undefined) {
            var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Atención!",
                    "message": "Debe rellenar el campo motivo de devolución",
                    "type": "warning"
                });
                toastEvent.fire(); 
        } else {
            //Si el campo está lleno, se llama a apex para empezar con el método devolver
            component.set('v.modalDevolverGestLet', false);
            component.set('v.isLoading', true); 
            var accionDevolverTarea = component.get('c.devolverTareaGestorLetrado');
            accionDevolverTarea.setParams({
                'tareaId':component.get('v.recordId'),
                'idUser':$A.get('$SObjectType.CurrentUser.Id'),
                'motivoDevolucion':motivo
            });
            accionDevolverTarea.setCallback(this, function(response){
                var estado = response.getState();
                if(estado == "SUCCESS"){
                    component.set('v.isLoading', false); 
                    component.set('v.motivoDevolver', '');
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "Éxito!",
                        "message": "La tarea ha sido devuelta",
                        "type": "success"
                    });
                    toastEvent.fire(); 
                    $A.get('e.force:refreshView').fire();
                }
                if(estado == "ERROR"){
                    component.set('v.isLoading', false);
                    let errors = response.getError();
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "Error",
                        "message": errors[0].message,
                        "type": "error"
                    });
                    toastEvent.fire(); 
                    $A.get('e.force:refreshView').fire();
                }
            })
        }

        $A.enqueueAction(accionDevolverTarea); 
    },

    prorrogarLaTarea : function(component, event, helper) {
        component.set('v.isLoading', true);               
        component.find("editForm").submit();

        // var haProrrogado = component.get('c.clicPorroga');
        // haProrrogado.setParams({
        //     'tareaId':component.get('v.recordId'),
        //     'idUser': $A.get('$SObjectType.CurrentUser.Id') 
        // });

        component.set('v.isLoading', false);
        /*var spinner = component.find('mySpinner');
        $A.util.removeClass(spinner, "slds-hide");*/
        //$A.enqueueAction(haProrrogado); 
    }, 

    handleSuccess : function(component, event, helper) {

        /*var spinner = component.find('mySpinner');
        $A.util.addClass(spinner, "slds-hide");*/
        component.set('v.isLoading', true); 
        component.set("v.isModalOpen", false);

        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": "Éxito!",
            "message": "La fecha de vencimiento de prórroga se ha modificado",
            "type": "success"
        });

        toastEvent.fire();
        component.set('v.isLoading', false); 

    }, 

    notificar : function(component, event, helper) {

        var cuerpoNotifi = component.find('cuerpoNotificacion').get('v.value');

        if(cuerpoNotifi != undefined){

            var spinner = component.find('mySpinner');
            $A.util.removeClass(spinner, "slds-hide");

            var notificarPropietario = component.get('c.notificarPropietarioAccion');
            notificarPropietario.setParams({
                'tareaId':component.get('v.recordId'),
                'mensaje':cuerpoNotifi
                });
            
                notificarPropietario.setCallback(this, function(response){
                var estado = response.getState();
                if(estado == "SUCCESS"){
                    
                    component.set("v.isModalNotificar", false);
                    $A.util.addClass(spinner, "slds-hide");

                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "Éxito!",
                        "message": "La notificación ha sido enviada",
                        "type": "success"
                    });

                    toastEvent.fire(); 
                    $A.get('e.force:refreshView').fire(); 
                    
                    var publicar = component.get("c.postOnChatter");
		            publicar.setParams({ 'tareaId': component.get('v.recordId'),
                                         'observacion':cuerpoNotifi
                                        });

                    $A.enqueueAction(publicar);
                }
            })
            $A.enqueueAction(notificarPropietario); 

        }else{

            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "title": "Advertencia!",
                "message": "Debes rellenar el título y el cuerpo de la notificación",
                "type": "warning"
            });
    
            toastEvent.fire(); 
        }
    },

    popupProrrogar: function(component, event, helper) {
        // Modal de prorrogar
        component.set("v.isModalOpen", true);
        
    },

    popupNotificar: function(component, event, helper) {
        // Modal de notificar
        component.set("v.isModalNotificar", true);
        
    },

    closeModalNotificar: function(component, event, helper) {
        // Set isModalNotificar attribute to false
        component.set("v.isModalNotificar", false);
        
    },
  
    closeModel: function(component, event, helper) {

        var spinner = component.find('mySpinner');
        $A.util.addClass(spinner, "slds-hide");
        
       // Set isModalOpen attribute to false  
        component.set("v.isModalOpen", false);
    },

    popupFinalizar: function(component, event, helper){
        var antecentesRevisados = component.get('c.devolverAntecedentesRevisados');
        antecentesRevisados.setParams({
            'tareaId':component.get('v.recordId')
        })

        antecentesRevisados.setCallback(this, function(response){
            var estado = response.getState();
            if(estado == "SUCCESS"){
                component.set('v.isLoading', false); 
                let checkAntecedentes = response.getReturnValue();
                if(checkAntecedentes === true) {
        component.set('v.isModalOpenFinalizar', true);
                } else {
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "Error",
                        "message": "Para finalizar la tarea se deben revisar los antecedentes de la reclamación y marcar el campo Antecedentes Revisados de la tarea.",
                        "type": "error"
                    });
                    toastEvent.fire(); 
                    $A.get('e.force:refreshView').fire();  
                }
                
            }else{
                component.set('v.isLoading', false); 
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Error",
                    "message": "No se ha cargado el campo antecedentes revisados correctamente.",
                    "type": "error"
                });
                toastEvent.fire(); 
                $A.get('e.force:refreshView').fire();    
            }
        })

        $A.enqueueAction(antecentesRevisados);
        
       
        
    },
    
    closeModalFinalizar: function(component, event, helper) {
        // Set isModalOpen attribute to false  
        component.set("v.isModalOpenFinalizar", false);
    },

    closeModalFinalizar2: function(component, event, helper) {
        // Set isModalOpen attribute to false  
        component.set("v.isModalOpenFinalizar2", false);
    },

    popupObservaciones: function(component, event, helper){
        component.set("v.isModalOpenFinalizar", false);
        component.set("v.isModalOpenFinalizar2", false);
        let estado = event.getSource().getLocalId();
        component.set("v.estadoFinalizar", estado);
        helper.cargarComentarios(component, event, helper);
        component.set('v.isModalObservaciones', true);
        
    },
    
    closeModalObservaciones: function(component, event, helper) {
        component.set("v.isModalObservaciones", false);
    },

    finalizarLaTareaObservaciones : function(component, event, helper) {        
        helper.finalizarLaTareaConObservaciones(component, event, helper); 
    },

    finalizarTareaJS : function(component, event, helper) {
        // Set isModalOpen attribute to false  
        component.set('v.estadoFinalizar', event.getSource().getLocalId());
        component.set("v.isModalOpenFinalizar", false);
        component.set("v.isModalOpenFinalizar2", true);
    },
    finalizarTarea2 : function(component, event, helper) { 
        component.set('v.estadoFinalizar', event.getSource().getLocalId());        
        component.set("v.isModalOpenFinalizar2", false);        
        helper.finalizarLaTarea(component, event, helper);
    },

    closeModalObservacionesTareaFinalizada : function(component, event, helper) {
        // Set isModalOpen attribute to false  
        component.set("v.modalTareaFinalizada", false);
    },

    abrirModalDevolverGestLet : function(component, event, helper) {
        // Set isModalOpen attribute to false  
        component.set("v.modalDevolverGestLet", true);
    },

    cerrarModalDevolverGestLet : function(component, event, helper) {
        // Set isModalOpen attribute to false  
        component.set("v.modalDevolverGestLet", false);
    },

    enviarTareaJS : function(component, event, helper) {
        let spinner = component.find('mySpinner');
        $A.util.removeClass(spinner, "slds-hide");

        let envioTareaJs = component.get('c.enviarTarea');
        let id = component.get('v.recordId');

        envioTareaJs.setParams({'tareaId': id});
        envioTareaJs.setCallback(this, function(response){
            var estado = response.getState();
            if(estado == "SUCCESS"){
                //US723742 - Raúl Santos - 05/03/2024 - Añadir lógica envio emails blackList. Comprueba si los emails son correctos. Si no son correctos muestra mensaje informativo pero continua el proceso
                let emailsInvalidos = response.getReturnValue();

                if(emailsInvalidos !== ''){
                    var toastEventWarning = $A.get("e.force:showToast");
                    toastEventWarning.setParams({
                        "title": "Advertencia!",
                        "message": "No se ha enviado el email correspondiente a la oficina. No está permitido el envío de emails a esta dirección: " + emailsInvalidos + " de correo electrónico.",
                        "type": "warning",
                        "duration": 8000
                    });
                    $A.util.addClass(spinner, "slds-hide");
                    toastEventWarning.fire(); 
                }

                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Éxito!",
                    "message": "La tarea ha sido enviada",
                    "type": "success"
                });
                $A.util.addClass(spinner, "slds-hide");
                toastEvent.fire(); 
                $A.get('e.force:refreshView').fire(); 

            } else {
                var errors = response.getError();
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Error",
                    "message": errors[0].message,
                    "type": "error"
                });
                $A.util.addClass(spinner, "slds-hide");
                toastEvent.fire(); 
                $A.get('e.force:refreshView').fire(); 
            }
        })

        $A.enqueueAction(envioTareaJs);
    },

    changeMotivoDevolver : function(component, event, helper) {
        component.set('v.motivoDevolver', event.getParam("value"));
    }

})