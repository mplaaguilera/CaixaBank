({
    init: function (component, event, helper) {
        var pageReference = component.get("v.pageReference");
        var rtName = pageReference.state.c__rtName;
        component.set("v.rtName", rtName);
        var isCIB = pageReference.state.c__isCIB;
        component.set("v.isCIB", isCIB);

        var workspaceAPI = component.find("workspace");
        workspaceAPI.getFocusedTabInfo().then(function (response) {
            var focusedTabId = response.tabId;
            workspaceAPI.setTabLabel({
                tabId: focusedTabId,
                label: $A.get("$Label.c.CIBE_ClientesPriorizados")
            });
            workspaceAPI.setTabIcon({
                tabId: focusedTabId,
                icon: "standard:report",
                iconAlt: $A.get("$Label.c.CIBE_ClientesPriorizados")
            });
        })
            .catch(function (error) {
                console.log(error);
            });
    }

})