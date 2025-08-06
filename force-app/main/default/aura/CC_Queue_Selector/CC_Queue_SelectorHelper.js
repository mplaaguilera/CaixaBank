({
	loadColas: function (component,event,helper) {
        var opcionesCola = [ ];
        var action = component.get("c.getColas");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var arr = response.getReturnValue() ;
                arr.forEach(function(element) {
					opcionesCola.push({ value: element.Group.Name, label: element.Group.Name });
				});
                component.set("v.opcionesCola", opcionesCola);
            }
        });
		$A.enqueueAction(action);
    },
    
    loadItems: function (component,event,helper) {
        //var cola = event.getParam("value");
        var cola = component.get("v.cola");         

        var action = component.get("c.getItems");
       
        action.setParams({
            'Cola': cola
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.itemsCola", response.getReturnValue());         
            }
        });
   
		$A.enqueueAction(action);
    },
    
    handleUtilityClick : function(component,event,helper, response) {
        if (response.panelVisible) {
            this.loadItems(component,event,helper);   
    	}
	}
})