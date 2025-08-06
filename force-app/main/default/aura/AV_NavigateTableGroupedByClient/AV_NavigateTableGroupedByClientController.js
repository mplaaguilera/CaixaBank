({
    init: function (component, event, helper) {
        var pageReference = component.get("v.pageReference");
        var param1 = pageReference.state.c__param1;
        component.set("v.param1", param1);

        var workspaceAPI = component.find("workspace");
        workspaceAPI.getFocusedTabInfo().then(function (response) {
            var focusedTabId = response.tabId;
            workspaceAPI.setTabLabel({
                tabId: focusedTabId,
                label: "Clientes a gestionar priorizados"
            });
            workspaceAPI.setTabIcon({
                tabId: focusedTabId,
                icon: "standard:report",
                iconAlt: "Clientes a gestionar priorizados"
            });
        })
            .catch(function (error) {
                console.log(error);
            });
    }

})