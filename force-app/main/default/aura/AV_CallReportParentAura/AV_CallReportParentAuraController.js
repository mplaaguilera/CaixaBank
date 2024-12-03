({
    doInit : function(component, event, helper) {
        let titulo = "  Reportar llamada"
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
                icon: "utility:call",
                iconAlt: "Cliente",
                iconSize: "small"
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
    onPageReferenceChange: function(component) {
		var myPageRef = component.get("v.pageReference");
        let recordIdToRedirect;
        if((window.location.pathname).split('/').includes('r')){
            let arrayUrl = (window.location.pathname).split('/');
            recordIdToRedirect = arrayUrl[4];
            component.set('v.itsRecordAccount',arrayUrl[3] === 'Account');
        }else if(myPageRef.state.ws != null) {
            component.set('v.itsRecordAccount',true);
            recordIdToRedirect = myPageRef.state.ws.split('/')[4];
        }
            component.set("v.id", recordIdToRedirect);

	},

	focusedTab : function(component, event, helper) {
        component.find("workspaceCmp").openTab({url: component.get('v.origenTabUrl'),focus:true});
	},
    closeFocusedTabAndClose : function(component, event, helper) {
		var id = component.get("v.id");
		var origenTab = component.get("v.origenTab");
		var workspaceAPI = component.find("workspaceCmp");
		workspaceAPI.openTab({url: '#/sObject/'+id+'/view',focus:true});
		workspaceAPI.closeTab({tabId: origenTab});
        
	},	focusRecordTab : function(component, event, helper) {
		var workspaceAPI = component.find("workspaceCmp");
        var origenTab = component.get("v.origenTab");
        var pageReference = {
            type : 'standard__namedPage',
            attributes: {
                pageName: 'home'
            }
        };
        component.find("workspaceCmp").openTab({pageReference: pageReference,focus:true});
	
	}
})