({
    seleccionarResultado: function(component) {
        let compEvent = component.getEvent("oSelectedEmpleadoEvent");
        compEvent.setParam('contactByEvent', component.get('v.empleado'));
        compEvent.fire();
    }
})