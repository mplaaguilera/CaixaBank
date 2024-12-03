({	
    cargarMiembroHelper: function(component) {
		var pageReference = component.get("v.pageReference");
		component.set("v.idMiembro", pageReference.state.c__idMiembro);
        
        //Llamar a la función cargarMiembro
        var action = component.get("c.cargarMiembro");
        action.setParams({
            'idMiembro': pageReference.state.c__idMiembro
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.campaignMember", response.getReturnValue());
            }
        });
        $A.enqueueAction(action);
    },
    
    cambiarEstado: function (component, event, helper) {
        var campaignMemberId = component.get("v.idMiembro");
        
        var action = component.get("c.actualizarEstado");
        action.setParams({
            'memberId': campaignMemberId
        });
        action.setCallback(this, function(response) {
            var estado = response.getState();
            var respuesta = response.getReturnValue();
            if (estado === "SUCCESS") {
                if(respuesta === "OK")
                {
                    this.showToast(component, event, helper);
                    $A.get('e.force:refreshView').fire(); 
                }
            }
        });
        $A.enqueueAction(action);      
    },
    
    showToast : function(component, event, helper) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            mode: 'dismissible',
            message: 'Se ha confirmado la asistencia del miembro de la campaña.',
            type: 'success'
        });
        toastEvent.fire();
    }
})