({
	doInit : function(cmp, event, helper) {
		var action = cmp.get("c.redirectToParent");
        var recordId = cmp.get("v.recordId");
            
        action.setParams({
            recordId: recordId
        });
        action.setCallback(this, function(response) {
            if (response.getState() === "SUCCESS") {
                
                var parentId = response.getReturnValue();
                if(parentId!= null && parentId.length > 0){
                    var workspaceAPI = cmp.find("workspace");
                    workspaceAPI.getTabInfo()
                    .then(function(response) {
                        var closeTabId = response.tabId;
                        workspaceAPI.openTab({
                                recordId: parentId,
                                focus: true
                            })
                            .then(() => {
                                workspaceAPI.closeTab({
                                    tabId: closeTabId
                                });
                            });
                    })
                    .catch(function(error) {
                        console.log('action error: ', error.message);
                    });
                }
            }
            });
            $A.enqueueAction(action);
	}
})