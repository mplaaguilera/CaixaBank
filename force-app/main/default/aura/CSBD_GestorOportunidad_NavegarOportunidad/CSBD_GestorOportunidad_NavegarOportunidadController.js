({
    navegarOportunidad: function(component, event) {
        if (event.getParams().changeType === 'LOADED') {
            let workspaceAPI = component.find('workspace');
            
            workspaceAPI.getFocusedTabInfo()
            .then(focusedTabInfo => {
                workspaceAPI.openTab({recordId: component.get('v.gestorOportunidad.CSBD_Oportunidad__c'), focus: true})
                    .then(function(response) {
                        var focusedTabId = response.tabId;
                        workspaceAPI.closeTab({tabId: focusedTabId});
                    });
            });
        }
    }
});