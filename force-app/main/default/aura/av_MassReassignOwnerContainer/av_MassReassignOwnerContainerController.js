({
	 doInit : function(component, event, helper) {
         
         var action = component.get("c.hasCustomPermission");
         action.setCallback(this, function(response) {
             var result = response.getReturnValue();
             if (result === true) {
				component.set("v.isBPR",true);
             }
             else if (result === false) {
                component.set("v.isBPR",false);
             }

         });

         $A.enqueueAction(action);

         
 		 let ref = component.get('v.pageReference');
         let fromHome = ref.state.c__fromHome;
         component.set( 'v.fromHome', fromHome);
         
         if(component.get("v.fromHome")){
             var workspaceAPI = component.find("workspace");
             workspaceAPI.getFocusedTabInfo().then(function(response) {
             var focusedTabId = response.Id;
             workspaceAPI.focusTab({tabId: focusedTabId});
             workspaceAPI.setTabLabel({
                 tabId: focusedTabId,
                 label: "Tareas"
             });
             workspaceAPI.setTabIcon({
                 tabId: focusedTabId,
                 icon: "standard:note",
                 iconAlt: "Focused Tab"
             });
            })
       }
    }
})