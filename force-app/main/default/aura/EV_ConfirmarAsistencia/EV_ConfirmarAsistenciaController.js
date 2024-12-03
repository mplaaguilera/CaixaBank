({
	init : function(component, event, helper) {
        helper.cargarMiembroHelper(component);
	},

	toggleInfoEstado : function(component, event, helper) {
        component.set("v.infoEstadoActivo", !component.get("v.infoEstadoActivo"));
    },
    
    handleConfirmarAsistencia: function (component, event, helper) {
        helper.cambiarEstado(component, event, helper); 
    }
})