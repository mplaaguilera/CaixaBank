({
    recordDataUpdated : function(component, event, helper) {

        if (event.getParams().changeType === 'CHANGED') {
            component.set('v.envioRealizado', false); 
        }else if (event.getParams().changeType === 'ERROR') {
			console.error(component.get('v.ldsError'));
		}
    },

    // init : function(component, event, helper) {

    //     var idTarea = component.get('v.recordId');
    //     var getTarea = component.get('c.recuperarTarea');
    //     getTarea.setParam('tareaId', idTarea);
        
    //     getTarea.setCallback(this, function(response) {
    //     	var state = response.getState();
    //         if (state === "SUCCESS") {
    //             var tareaActual = response.getReturnValue();
	// 			component.set('v.tarea', tareaActual);
    //         }
    //     });
    //     $A.enqueueAction(getTarea); 

    // },


    enviarGGHJS : function(component, event, helper) {
         
        let spinner = component.find('mySpinner'); 
        $A.util.removeClass(spinner, "slds-hide"); 

        let envioTareaJs = component.get('c.enviarTareaGGH');
        let id = component.get('v.recordId');
        envioTareaJs.setParams({'tareaId': id});
        envioTareaJs.setCallback(this, function(response){
            var estado = response.getState();
            if(estado == "SUCCESS"){  
                component.set('v.envioRealizado', true);               
                window.setTimeout(
                    $A.getCallback(function() {
                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            "title": "Éxito!",
                            "message": "La tarea ha sido enviada. Por favor espere y refresque la pagina para comprobar si la conexión ha sido exitosa.",
                            "type": "warning"
                        });
                        toastEvent.fire(); 
                        $A.util.addClass(spinner, "slds-hide");
                        $A.get('e.force:refreshView').fire();
                    }), 3000)                
            }
            if(estado == "ERROR"){
                var error = response.getError();                             
                var mensaje = error[0].message;

                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "mode":'sticky',
                    "title": "Error!",
                    "message": mensaje,
                    "type": "error"
                });
                $A.util.addClass(spinner, "slds-hide");
                toastEvent.fire(); 
                $A.get('e.force:refreshView').fire(); 
            }
        })
        $A.enqueueAction(envioTareaJs);
    },

    finalizarTarea : function(component, event, helper) {

         component.set('v.isLoading', true);  
        
         var finalizarTarea = component.get('c.finalizarTareaGGH');
         finalizarTarea.setParams({
             'tareaId':component.get('v.recordId')
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
})