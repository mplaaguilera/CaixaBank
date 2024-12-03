({
    doInit : function(cmp, event, helper) {
        $A.get("e.force:closeQuickAction").fire();
        var workspaceAPI = cmp.find("workspaceCmp");
        let action = cmp.get('c.getAccountInfo');
        action.setParams({recordId : cmp.get('v.recordId')});
        action.setCallback(this,function(response){
            if(response.getState() === 'SUCCESS'){
                let data = response.getReturnValue();
                let pageReferenceCustom = {
                    type: 'standard__navItemPage',
                    attributes: {
                        apiName: 'AV_PlanificarCita'
                    },state: {
                        c__matricula : data.contactPlate,
                        c__clientNumper: data.clientNumper
                    }
                };
                workspaceAPI.getFocusedTabInfo().then(enclosingTab =>{
                    workspaceAPI.openSubtab({
                        parentTabId:enclosingTab.tabId,
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