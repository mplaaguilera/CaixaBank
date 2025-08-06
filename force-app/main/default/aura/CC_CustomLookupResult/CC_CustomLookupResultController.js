({
    seleccionarResultado: function(component) {
        let compEvent = component.getEvent("oSelectedAccountEvent");
        compEvent.setParam('accountByEvent', component.get('v.grupo'));
        compEvent.fire();
    }
})