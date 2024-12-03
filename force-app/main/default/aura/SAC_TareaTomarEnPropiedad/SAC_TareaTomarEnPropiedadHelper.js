({
    finalizarLaTarea : function(component, event, helper) {

        component.set('v.isLoading', true);

        var observaciones = ' '
        var finalizarTarea = component.get('c.finalizarTarea');
        finalizarTarea.setParams({
            'tareaId':component.get('v.recordId'),
            'idUser':$A.get('$SObjectType.CurrentUser.Id'),
            'observaciones' : observaciones
        });

        finalizarTarea.setCallback(this, function(response){
            var estado = response.getState();
            if(estado == "SUCCESS"){
                //$A.util.addClass(spinner, "slds-hide");
                component.set('v.isLoading', false); 
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Éxito!",
                    "message": "Se ha finalizado la tarea.",
                    "type": "success"
                });
                toastEvent.fire(); 
                $A.get('e.force:refreshView').fire(); 
          
            }
        }
    ),

    $A.enqueueAction(finalizarTarea); 
    },

    finalizarLaTareaConObservaciones : function(component, event, helper) {       
        var observaciones = '' + component.find('observaciones').get('v.value');        
        var estado = component.get("v.estadoFinalizar");

        //Controlar si el estado que vamos a introducir es descartada y si el campo observaciones es más largo de 255
        if(estado == 'SAC_Descartada' && observaciones.length > 255) {
            var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "Atención",
                        "message": "El campo no puede superar los 255 carácteres",
                        "type": "warning"
                    });
                    toastEvent.fire(); 
        } else {
            component.set("v.isModalObservaciones", false);
            component.set('v.isLoading', true);
            var finalizarTarea = component.get('c.finalizarTareaObservacion');
            finalizarTarea.setParams({
                'tareaId':component.get('v.recordId'),
                'idUser':$A.get('$SObjectType.CurrentUser.Id'),
                'observaciones' : observaciones,
                'estado' : estado
            });
    
            finalizarTarea.setCallback(this, function(response){
                var estado = response.getState();
                if(estado == "SUCCESS"){
                    //$A.util.addClass(spinner, "slds-hide");
                    component.set('v.isLoading', false); 
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "Éxito!",
                        "message": "Se ha finalizado la tarea.",
                        "type": "success"
                    });
                    toastEvent.fire(); 
                    $A.get('e.force:refreshView').fire();                 
                }
            })
    
            $A.enqueueAction(finalizarTarea); 
        }
    },

    cargarComentarios : function(component, event, helper) {

        var cargarObservaciones = component.get('c.cargarComentarios2');
        cargarObservaciones.setParams({'tareaId' : component.get('v.recordId')});

        cargarObservaciones.setCallback(this, function(response){
            var estado = response.getState();
            if(estado == "SUCCESS"){
                //$A.util.addClass(spinner, "slds-hide");
                component.set('v.isLoading', false); 
                let comentarios2 = JSON.stringify(response.getReturnValue());

                comentarios2 = comentarios2.replaceAll(`"`, ` `);
                component.set('v.observaciones', comentarios2);
                
            }else{
                component.set('v.isLoading', false); 
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Éxito!",
                    "message": "No se han cargado correctamente los comentarios.",
                    "type": "error"
                });
                toastEvent.fire(); 
                $A.get('e.force:refreshView').fire();    
            }

        })

        $A.enqueueAction(cargarObservaciones); 
    }
})