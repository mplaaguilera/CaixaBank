({
	doInit : function(component, event, helper) {
       
		component.set('v.firstPartURL', '/lightning/r/EmailMessage/' );
		component.set('v.thirdPartURL', '/view');
        var action = component.get("c.recuperarComunicacionesEmail");
        action.setParams({ caseId : component.get("v.recordId") });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var headingInfo = response.getReturnValue();
               
                component.set("v.comunicationList", headingInfo);
               
            } else {
                 
                console.log("error: "+errors[0].message);
            } 
        });
        $A.enqueueAction(action);
	}
	
})