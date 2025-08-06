({
    getEstadoActual: function (component, event, helper) {
        var campaignMemberId = component.get("v.recordId");
        
        var action = component.get("c.esEstadoCorrecto");
        action.setParams({
            'memberId': campaignMemberId
        });
        action.setCallback(this, function(response) {
            var estado = response.getState();
            var botonVisible = response.getReturnValue();
            if (estado === "SUCCESS") {
            	component.set("v.botonVisible", botonVisible);
            }
        });
        $A.enqueueAction(action);      
        
    },
    
    cambiarEstado: function (component, event, helper) {
        var campaignMemberId = component.get("v.recordId");
        
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
                }
            }
        });
        $A.enqueueAction(action);      
        $A.get('e.force:refreshView').fire();        
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