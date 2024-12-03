({
	handleClickActivar : function(component, event, helper) {
        var action = component.get("c.activarUsuariosCSO");
        action.setParams({"recordIds": component.get("v.selectedRecords")});
		action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                console.log('Success');
                $A.get('e.force:refreshView').fire();
            }
        });
		$A.enqueueAction(action);
        $A.get("e.force:closeQuickAction").fire(); 
    },
	handleSelection : function(component, event, helper) {
        component.set("v.selectedRecords",event.getParam("seletedRows"));
		console.log(component.get("v.selectedRecords"));
    }
})