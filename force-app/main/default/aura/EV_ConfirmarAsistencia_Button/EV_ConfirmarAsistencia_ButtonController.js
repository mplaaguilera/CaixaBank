({
    iniciar: function (component, event, helper) {
        helper.getEstadoActual(component, event, helper);       
    },
    
    handleConfirmarAsistencia: function (component, event, helper) {
        helper.cambiarEstado(component, event, helper); 
        helper.getEstadoActual(component, event, helper);        
    }
})