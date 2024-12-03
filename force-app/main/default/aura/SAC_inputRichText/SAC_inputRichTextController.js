({
    reescalado: function(component, event, helper) {
        component.set('v.isOpen', !component.get('v.isOpen'));
        var el =  document.getElementById(component.getGlobalId('name-input'));
        el.focus();
    }
})