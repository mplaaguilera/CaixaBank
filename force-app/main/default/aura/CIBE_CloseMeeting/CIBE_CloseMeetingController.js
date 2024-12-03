({
    init: function (component, event, helper) {
        $A.get("e.force:closeQuickAction").fire();
        $A.get('e.force:refreshView').fire();
        let recordId = component.get('v.recordId');
        var workspaceAPI = component.find("workspace");
        console.log('workspaceAPI ', workspaceAPI);
        console.log('recordId ', recordId);

        let pageReferenceCustom = {
            type: 'standard__navItemPage',
            attributes: {
                apiName: 'Cibe_CerrarCita'
            },state: {
                c__recId: recordId
            }
        };

        console.log('pageReferenceCustom 1', pageReferenceCustom);
        console.log('workspaceAPI FT', workspaceAPI.getFocusedTabInfo());

        workspaceAPI.getFocusedTabInfo().then(function (response) {
            console.log('response ', response);
            var focusedTabId = response.tabId;
            console.log('focusedTabId ', focusedTabId);
            console.log('pageReferenceCustom 2', pageReferenceCustom);
          
            workspaceAPI.openSubtab({
                parentTabId: response.tabId,
                pageReference: pageReferenceCustom,
                focus:true
            }).catch(function (error){
                console.log('openSubtab ',error);
            })

            workspaceAPI.setTabLabel({
                tabId: focusedTabId
            });

        })
            .catch(function (error) {
                console.log(error)
            })
    }

})