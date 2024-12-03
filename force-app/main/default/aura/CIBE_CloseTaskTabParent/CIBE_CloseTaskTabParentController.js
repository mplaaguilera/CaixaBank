({
    doInit : function(component, event, helper) {
        var workspaceAPI = component.find("workspace");
        workspaceAPI.getFocusedTabInfo().then(function(response) {
            var focusedTabId = response.tabId;
            workspaceAPI.setTabLabel({
                tabId: focusedTabId,
                label: $A.get("$Label.c.CIBE_CerrarTareaEInformarOportunidad")
            });
            workspaceAPI.setTabIcon({
                tabId: focusedTabId,
                icon: "standard:opportunity",
                iconAlt: "Tarea-Oportunidad"
            });
        })
        .catch(function(error) {
            console.log(error);
        });
    },

    closeFocusedTab : function(component, event, helper) {
        var appEvent = $A.get("e.c:AV_ReportAppEvent");
        appEvent.setParams({
            "message" : "REFRESH" });
        appEvent.fire();

        var workspaceAPI = component.find("workspace");
        workspaceAPI.getFocusedTabInfo().then(function(response) {
            var focusedTabId = response.tabId;
            workspaceAPI.closeTab({tabId: focusedTabId});
        })
        .catch(function(error) {
            console.log(error);
        });
    }
})