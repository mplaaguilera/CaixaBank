({
    doInit : function(cmp, event, helper) {
        $A.get("e.force:closeQuickAction").fire();
        var workspaceAPI = cmp.find("workspaceCmp");
        let action = cmp.get('c.getActions');
        //let action = cmp.get('c.getAccountInfo');
        action.setParams({recordId : cmp.get('v.recordId')});
        let recordId = cmp.get('v.recordId');
        action.setCallback(this,function(response){
            if(response.getState() === 'SUCCESS'){
                let data = response.getReturnValue();
                let pageReferenceCustom = {
                    type: 'standard__navItemPage',
                    attributes: {
                        apiName: 'CIBE_GestionTarea'
                    },state: {
                        c__recId:recordId
                    }
                };

                workspaceAPI.getFocusedTabInfo().then(enclosingTab =>{
                    workspaceAPI.openSubtab({
                        parentTabId:enclosingTab.tabId,
                        //parentTabId:'CIBE_GestionTarea',
                        pageReference:pageReferenceCustom,
                        id:null
                    })
                })
                
            }
            
        })
            $A.enqueueAction(action);
        
    },
    closeFocusedTab : function(component, event, helper) {
        var workspaceAPI = component.find("workspaceCmp");
        workspaceAPI.getFocusedTabInfo().then(function(response) {
            var focusedTabId = response.tabId;
            workspaceAPI.closeTab({tabId: focusedTabId});
        })
        .catch(function(error) {
            console.log(error);
        });
    }
})