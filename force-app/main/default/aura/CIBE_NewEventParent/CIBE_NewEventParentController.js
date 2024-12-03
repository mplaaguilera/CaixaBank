({
    doInit : function(component, event, helper) {
        var pageRef = component.get("v.pageReference");
        console.log('123 ' + JSON.stringify(pageRef));
        var accountName = pageRef.state.c__id;
        console.log('123 ' + accountName);
        //component.set("recId", accountId);
        var myPageRef = component.get("v.pageReference");
        component.set("v.oportunidadId", myPageRef.state.c__oportunidadId);
        var workspaceAPI = component.find("workspace");
        workspaceAPI.getFocusedTabInfo().then(function(response) {
            var focusedTabId = response.tabId;
            workspaceAPI.isSubtab({
                tabId: focusedTabId
            }).then(function(response) {
                if (response) {
                    workspaceAPI.setTabLabel({
                        tabId: focusedTabId,
                        label: accountName
                    });
                    workspaceAPI.setTabIcon({
                        tabId: focusedTabId,
                        icon: "standard:event",
                        iconAlt: "Cliente"
                    });
                }
                else {
                    workspaceAPI.getEnclosingTabId().then(function(tabId) {
                        workspaceAPI.setTabLabel({
                            tabId: tabId,
                            label: accountName
                        });
                        workspaceAPI.setTabIcon({
                            tabId: tabId,
                            icon: "standard:event",
                            iconAlt: "Cliente"
                        });
                })
                }
            });   
        })
        .catch(function(error) {
            console.log(error);
        });
    },

    closeFocusedTabFinish : function(component, evt, helper) {
        var newEventId = evt.getParam("neweventid");
        var workspaceAPI = component.find("workspace");
        workspaceAPI.getEnclosingTabId().then(enclosingTab =>{
            workspaceAPI.openSubtab({parentTabId: enclosingTab,recordId:newEventId,focus:true}).then(() =>{
                var workspaceAPI2 = component.find("workspaceCmp");
                workspaceAPI2.closeTab({tabId: component.get("v.origenTab")});
            })
            .catch(function(error) {
                console.log(error);
            });
        })
        
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
    },
    closeFocusedTab : function(component, event, helper) {
		var origenTab = component.get("v.origenTab");
		var workspaceAPI = component.find("workspace");
		workspaceAPI.closeTab({tabId: origenTab});

	
	},
    onPageReferenceChange: function(component, event, helper) {
		var myPageRef = component.get("v.pageReference");
		component.set("v.id", myPageRef.state.c__recId);
	},

	focusedTab : function(component, event, helper) {
        component.find("workspace").openTab({url: component.get('v.origenTabUrl'),focus:true});
	},
    closeFocusedTabAndClose : function(component, event, helper) {
		var id = component.get("v.id");
		var origenTab = component.get("v.origenTab");
		var workspaceAPI = component.find("workspace");
		workspaceAPI.openTab({url: '#/sObject/'+id+'/view',focus:true});
		workspaceAPI.closeTab({tabId: origenTab});
	
	},	focusRecordTab : function(component, event, helper) {
		var id = component.get("v.id");
		var workspaceAPI = component.find("workspace");
		workspaceAPI.openTab({url: '#/sObject/'+id+'/view',focus:true});
			
	
	}

})