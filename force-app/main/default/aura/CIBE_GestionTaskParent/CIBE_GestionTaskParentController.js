({
    doInit: function (component, e, helper) {
        $A.get("e.force:closeQuickAction").fire();
        var accountName = 'Gestion Tarea';
        var workspaceAPI = component.find("workspace");
        var mypagrefId = component.get('v.recordId');
		component.set("v.id", mypagrefId);
        workspaceAPI.getFocusedTabInfo().then(function (response) {
            var focusedTabId = response.tabId;
            focusedTabId = 'CIBE_GestionTarea';
            workspaceAPI.isSubtab({
                tabId: focusedTabId,
                state: {
                }
            }).then(function (response) {
                console.log('Parent isSubtab response',response);
                if (response) {

                }
                else {
                    workspaceAPI.getEnclosingTabId().then(function (tabId) {
                        workspaceAPI.setTabLabel({
                            tabId: tabId,
                            label: accountName
                        });
                        workspaceAPI.setTabIcon({
                            tabId: tabId,
                            icon: "standard:task",
                            iconAlt: "Task"
                        });
                    })
                }
            });
        })
            .catch(function (error) {
                console.log(error);
            });
    },

    closeFocusedTabFinish: function (component, evt, helper) {
        var newEventId = evt.getParam("neweventid");
        var workspaceAPI = component.find("workspace");
        workspaceAPI.getEnclosingTabId().then(enclosingTab => {
            workspaceAPI.openSubtab({ parentTabId: enclosingTab, recordId: newEventId, focus: true }).then(() => {
                var workspaceAPI2 = component.find("workspaceCmp");
                workspaceAPI2.closeTab({ tabId: component.get("v.origenTab") });
            })
                .catch(function (error) {
                    console.log(error);
                });
        })

    },

    closeFocusedTab: function (component, event, helper) {

        var workspaceAPI = component.find("workspace");
        workspaceAPI.getFocusedTabInfo().then(function (response) {
            var focusedTabId = response.tabId;
            workspaceAPI.closeTab({ tabId: focusedTabId });
        })
            .catch(function (error) {
                console.log(error);
            });
    },
    closeFocusedTab: function (component, event, helper) {
        var origenTab = component.get("v.origenTab");
        var workspaceAPI = component.find("workspace");
        workspaceAPI.closeTab({ tabId: origenTab });


    },
    onPageReferenceChange: function (component, event, helper) {
        var mypagrefId = component.get('v.recId');
		component.set("v.id", mypagrefId);
    },

    focusedTab: function (component, event, helper) {
        component.find("workspace").openTab({ url: component.get('v.origenTabUrl'), focus: true });
    },
    closeFocusedTabAndClose: function (component, event, helper) {
        var id = component.get("v.id");
        var origenTab = component.get("v.origenTab");
        var workspaceAPI = component.find("workspace");
        workspaceAPI.openTab({ url: '#/sObject/' + id + '/view', focus: true });
        workspaceAPI.closeTab({ tabId: origenTab });

    }, focusRecordTab: function (component, event, helper) {
        var id = component.get("v.id");
        var workspaceAPI = component.find("workspace");
        workspaceAPI.openTab({ url: '#/sObject/' + id + '/view', focus: true });
    }

})