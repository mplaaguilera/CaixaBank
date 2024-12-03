({
    doInit : function(component, event, helper) {
        let titulo = "Planificar Cita"
        var workspaceAPI = component.find("workspaceCmp");
        workspaceAPI.getEnclosingTabId().then( enclosingTab => {
            workspaceAPI.getTabURL({tabId:enclosingTab}).then(function(reponseUrl) {
				component.set("v.origenTabUrl" , reponseUrl);
			});
            component.set("v.origenTab",enclosingTab);
            workspaceAPI.setTabLabel({
                tabId: enclosingTab,
                label: titulo
            });
            workspaceAPI.setTabIcon({
                tabId: enclosingTab,
                icon: "standard:event",
                iconAlt: "Cliente"
            });                
        }).catch(error => {
        console.log('error => ',error)
        })
    },
   
    closeFocusedTabFinish : function(component, evt, helper) {
        var newEventId = evt.getParam("neweventid");
        var workspaceAPI = component.find("workspaceCmp");
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
		var origenTab = component.get("v.origenTab");
		var workspaceAPI = component.find("workspaceCmp");
		workspaceAPI.closeTab({tabId: origenTab});

	
	},
    onPageReferenceChange: function(component, event, helper) {
		var myPageRef = component.get("v.pageReference");
		component.set("v.id", myPageRef.state.c__recId);
	},

	focusedTab : function(component, event, helper) {
		// var workspaceAPI = component.find("workspaceCmp");
        // workspaceAPI.getEnclosingTabId().then(enclosingTab =>{
        //     workspaceAPI.openSubtab({parentTabId: enclosingTab,url:component.get("v.origenTabUrl"),focus:true}).then(() =>{
        //     })
        //     .catch(function(error) {
        //         console.log(error);
        //     });
        // })
        component.find("workspaceCmp").openTab({url: component.get('v.origenTabUrl'),focus:true});
	},
    closeFocusedTabAndClose : function(component, event, helper) {
		var id = component.get("v.id");
		var origenTab = component.get("v.origenTab");
		var workspaceAPI = component.find("workspaceCmp");
		workspaceAPI.openTab({url: '#/sObject/'+id+'/view',focus:true});
		workspaceAPI.closeTab({tabId: origenTab});
	
	},	focusRecordTab : function(component, event, helper) {
		var id = component.get("v.id");
		var workspaceAPI = component.find("workspaceCmp");
		workspaceAPI.openTab({url: '#/sObject/'+id+'/view',focus:true});
			
	
	}
    // closeFocusedTab: function(cmp){
    //     var workspaceAPI = cmp.find("workspaceCmp");
    //     workspaceAPI.getEnclosingTabId().then(tab => {
    //         workspaceAPI.closeTab({tabId:tab});
    //     })
    // }
})