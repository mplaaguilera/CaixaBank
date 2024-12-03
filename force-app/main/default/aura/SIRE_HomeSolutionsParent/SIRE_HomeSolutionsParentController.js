({
    onTabFocused : function(component, event, helper) {
        var focusedTabId = event.getParam('currentTabId');
        var workspaceAPI = component.find("workspace");
        if (focusedTabId == null) {
            //component.find('mcparent').refreshCmp();
            var c = component.find('mcchild');
            if (c != null) {
                c.refreshCmp();
            }
        } else {
            workspaceAPI.getTabInfo({
                tabId : focusedTabId,
                callback : function(error, response){
                    console.log(response);
                }
            });
        }
    }
})