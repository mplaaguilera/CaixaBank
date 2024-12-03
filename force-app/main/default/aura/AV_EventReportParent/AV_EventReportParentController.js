({
	doInit : function(component, event, helper) {
        let titulo = "Reporte de cita"
        var workspaceAPI = component.find("workspaceCmp");
        workspaceAPI.getEnclosingTabId().then( enclosingTab => {
			component.set("v.origenTab",enclosingTab);
			workspaceAPI.getAllTabInfo().then(response => {
				response.forEach(mainTab => {
						if(mainTab.subtabs != null && mainTab.subtabs.length != 0){
							if(mainTab.focused){
								component.set("v.isHome",'false');
							}
							(mainTab.subtabs).forEach(tab => {
								if(tab.tabId === enclosingTab ){
									workspaceAPI.getTabURL({tabId:enclosingTab}).then(function(reponseUrl) {
										component.set("v.origenTabUrl" , reponseUrl);
									});
									component.set('v.reportTab',tab.tabId);	
									workspaceAPI.setTabLabel({
										tabId: enclosingTab,
										label: titulo
									});
									
									workspaceAPI.setTabIcon({
										tabId: enclosingTab,
										icon: "standard:event",
										iconAlt: "Event"
									});        
									return;
								}
								
							});
						}else{
							if(mainTab.focused){
								component.set("v.isHome",'true');
							}
							workspaceAPI.getTabURL({tabId:enclosingTab}).then(function(reponseUrl) {
							component.set("v.origenTabUrl" , reponseUrl);
						});
						component.set('v.reportTab',enclosingTab);	
						workspaceAPI.setTabLabel({
							tabId: enclosingTab,
							label: titulo
						});
						
						workspaceAPI.setTabIcon({
							tabId: enclosingTab,
							icon: "standard:event",
							iconAlt: "Event"
						});   
						}

				})


			})            
        }).catch(error => {
        	console.log('error => ',error)
        });
    },
		
	closeFocusedTab : function(component, event, helper) {
		var workspaceAPI = component.find("workspaceCmp");
		workspaceAPI.closeTab({tabId: component.get('v.reportTab')});
		if(component.get("v.isHome") == 'false'){
			workspaceAPI.openSubtab({parentTabId: component.get("v.origenTab"),recordId:component.get("v.id"),focus:true});

		}else{
			component.find("eventreport").navigateHome();
		}

	},

	closeFocusedTabAndClose : function(component, event, helper) {
		var workspaceAPI = component.find("workspaceCmp");
		workspaceAPI.closeTab({tabId: component.get('v.reportTab')});
		if(component.get("v.isHome") == 'false'){
			workspaceAPI.openSubtab({parentTabId:component.get("v.origenTab"),recordId:component.get("v.id"),focus:true});

		}else{
			component.find("eventreport").navigateHome();
		}

	},
        
    focusRecordTab : function(component, event, helper) {
		var appEvent = $A.get("e.c:AV_ReportAppEvent");
        appEvent.setParams({
            "message" : "REFRESH" });
        appEvent.fire();
		var id = component.get("v.id");
		var workspaceAPI = component.find("workspaceCmp");
		
		if(component.get("v.isHome") == 'false'){
			workspaceAPI.openSubtab({parentTabId: component.get("v.origenTab"),recordId:component.get("v.id"),focus:true});

		}else{
			component.find("eventreport").navigateHome();
		}
	
	},

	onPageReferenceChange: function(component, event, helper) {
		var myPageRef = component.get("v.pageReference");
		component.set("v.id", myPageRef.state.c__recId);
	},

	focusedTab : function(component, event, helper) {

	component.find("workspaceCmp").openTab({url: component.get('v.origenTabUrl'),focus:true});
		
	}
})