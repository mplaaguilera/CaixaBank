({
    refrescado : function(component) {
        
        var getCaso = component.get('c.recuperarCaso');
        getCaso.setParam('caseId', component.get('v.recordId'));
        
        getCaso.setCallback(this, function(response) {
        	var state = response.getState();
            if (state === "SUCCESS") {
				
                component.set('v.caso', response.getReturnValue());
        	}            
        });
        
		$A.enqueueAction(getCaso); 
	}
})