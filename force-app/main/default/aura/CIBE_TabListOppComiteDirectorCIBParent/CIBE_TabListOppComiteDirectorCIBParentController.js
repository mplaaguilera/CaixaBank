({
    doInit : function(component, event, helper) {
        var workspaceAPI = component.find("workspace");
        workspaceAPI.getFocusedTabInfo().then(function(response) {
            var focusedTabId = response.tabId;
            workspaceAPI.setTabLabel({
                tabId: focusedTabId,
                label: $A.get("$Label.c.CIBE_ComiteDirector") + ' CIB'
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