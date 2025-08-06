({
	doInit : function(component, event, helper) {
        let titulo = "Buscador de oportunidades"
        var workspaceAPI = component.find("workspaceCmp");
        workspaceAPI.getEnclosingTabId().then( enclosingTab => {
            component.set("v.origenTab",enclosingTab);
            workspaceAPI.getTabURL({tabId:enclosingTab}).then(function(reponseUrl) {
                component.set("v.origenTabUrl" , reponseUrl);
            });
            workspaceAPI.setTabLabel({
                tabId: enclosingTab,
                label: titulo
            });
            workspaceAPI.setTabIcon({
                tabId: enclosingTab,
                icon: "standard:service_report",
                iconAlt: "Buscador de oportunidades"
            });                
        }).catch(error => {
            console.log('error => ',error)
        });
	},
	closeFocusedTab : function(component, event, helper) {
		var origenTab = component.get("v.origenTab");
		var workspaceAPI = component.find("workspaceCmp");
		workspaceAPI.closeTab({tabId: origenTab});
	},

	closeFocusedTabAndClose : function(component, event, helper) {
		var id = component.get("v.id");
		var origenTab = component.get("v.origenTab");
		var workspaceAPI = component.find("workspaceCmp");
		workspaceAPI.openTab({url: '#/sObject/'+id+'/view',focus:true});
		workspaceAPI.closeTab({tabId: origenTab});
	},

	focusRecordTab : function(component, event, helper) {
		var id = component.get("v.id");
		var workspaceAPI = component.find("workspaceCmp");
		workspaceAPI.openTab({url: '#/sObject/'+id+'/view',focus:true});
	},

	onPageReferenceChange: function(component, event, helper) {
		var myPageRef = component.get("v.pageReference");
		component.set("v.id", myPageRef.state.c__recId);
	},

	focusedTab : function(component) {
		component.find("workspaceCmp").openTab({url: component.get('v.origenTabUrl'),focus:true});
	}
})