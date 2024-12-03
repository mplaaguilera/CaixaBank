({
	init : function(component, event, helper) {

		var getDocumento = component.get('c.recuperarDocumento');
        getDocumento.setParam('documentoEnviarId', component.get('v.recordId'));
        getDocumento.setCallback(this, function(response) {
        	var state = response.getState();
            if (state === "SUCCESS") {
				
                component.set('v.idDocumento', response.getReturnValue());
			}
		});

		$A.enqueueAction(getDocumento);
		
	}
})