({
	doInit: function(component, event, helper) {
        helper.fetchCountHelper(component, event, helper);
        /* window.setInterval(
            $A.getCallback(function() {
				helper.fetchCountHelper(component, event, helper);
            }), 10000
        );*/
        
    },
    refrescar: function(component, event, helper) {
    	$A.enqueueAction(component.get('c.doInit'));
    },
    
    
})