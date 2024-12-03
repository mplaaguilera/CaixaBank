({
    doInit : function(component, event, helper) {
        var action = component.get('c.requiereEscaladoCOPS');
        action.setParams({'id':component.get('v.recordId')});
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(state === 'SUCCESS'){
                component.set('v.mensaje', response.getReturnValue());
            }
        })

        $A.enqueueAction(action);
    }
})