({
    init: function (component, event, helper) {
        $A.get("e.force:closeQuickAction").fire();
        $A.get('e.force:refreshView').fire();
        let recordId = component.get('v.recordId');
        var workspaceAPI = component.find("workspace");
        console.log('workspaceAPI ', workspaceAPI);
        let pageReferenceCustom = {
            type: 'standard__navItemPage',
            attributes: {
                apiName: 'Cibe_ModificarCita'
            },state: {
                c__title: 'Modificar cita',
                c__recId: recordId
            }
        };
        console.log('pageReferenceCustom ', pageReferenceCustom);

        workspaceAPI.getFocusedTabInfo().then(function (response) {
            console.log('response ', response);
            var focusedTabId = response.tabId;
            console.log('focusedTabId ', focusedTabId);
            workspaceAPI.openSubtab({
                parentTabId: response.tabId,
                pageReference: pageReferenceCustom
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