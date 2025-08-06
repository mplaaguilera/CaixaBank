({
	doInit : function(component, event, helper) {
        let titulo = "Reporte del cliente"
        var workspaceAPI = component.find("workspaceCmp");
		var myPageRef = component.get("v.pageReference");

		let objName = myPageRef.state.c__objectname;
			workspaceAPI.getEnclosingTabId().then( enclosingTab => {
				component.set("v.origenTab",enclosingTab);
				if(objName == 'Opportunity'){
						workspaceAPI.getAllTabInfo().then(response => {
							response.forEach(mainTab => {

									if(mainTab.subtabs != null){
										(mainTab.subtabs).forEach(tab => {
											if(tab.tabId === enclosingTab ){
												workspaceAPI.getTabURL({tabId:enclosingTab}).then(function(reponseUrl) {
													component.set("v.origenTabUrl" , reponseUrl);
												});
												component.set('v.reportTab',tab.tabId);	
												workspaceAPI.setTabLabel({
													tabId: tab.tabId,
													label: 'Reportar oportunidad'
												});
												
												workspaceAPI.setTabIcon({
													tabId: tab.tabId,
													icon: "standard:opportunity",
													iconAlt: "Oportunidad"
												});        
											return;
											}
											
										});
									}

							})

						})
				}else{

					workspaceAPI.getTabURL({tabId:enclosingTab}).then(function(reponseUrl) {
						component.set("v.origenTabUrl" , reponseUrl);
					});
					workspaceAPI.setTabLabel({
						tabId: enclosingTab,
						label: titulo
					});
					workspaceAPI.setTabIcon({
						tabId: enclosingTab,
						icon: "standard:account",
						iconAlt: "Cliente"
					});                
				}

			}).catch(error => {
				console.log('error => ',error)
			});
		},
	closeFocusedTab : function(component, event, helper) {
		var origenTab = component.get("v.origenTab");
		var workspaceAPI = component.find("workspaceCmp");
		var myPageRef = component.get("v.pageReference");
		let objName = myPageRef.state.c__objectname;
		if(objName != 'Opportunity'){
			
			workspaceAPI.closeTab({tabId: origenTab});
		}else{
			workspaceAPI.closeTab({tabId: component.get('v.reportTab')});
		}
	
	},

	closeFocusedTabAndClose : function(component, event, helper) {
		var id = component.get("v.id");
		var origenTab = component.get("v.origenTab");
		var workspaceAPI = component.find("workspaceCmp");
		var myPageRef = component.get("v.pageReference");
		let objName = myPageRef.state.c__objectname;
		if(objName != 'Opportunity'){

		workspaceAPI.openTab({url: '#/sObject/'+id+'/view',focus:true});
		workspaceAPI.closeTab({tabId: origenTab});
		}else{
			workspaceAPI.openSubtab({parentTabId:origenTab,recordId:id,focus:true});
			workspaceAPI.closeTab({tabId: component.get('v.reportTab')});
		}
	},

	focusRecordTab : function(component, event, helper) {
		var id = component.get("v.id");
		var workspaceAPI = component.find("workspaceCmp");
		var myPageRef = component.get("v.pageReference");
		let objName = myPageRef.state.c__objectname;
		var origenTab = component.get("v.origenTab");
		
		if(objName != 'Opportunity'){
			workspaceAPI.openTab({url: '#/sObject/'+id+'/view',focus:true});
			
		}else{
			workspaceAPI.openSubtab({parentTabId:origenTab,recordId:id,focus:true});	
		}
	},

	onPageReferenceChange: function(component, event, helper) {
		var myPageRef = component.get("v.pageReference");
		component.set("v.id", myPageRef.state.c__recId);
	},

	focusedTab : function(component) {
		component.find("workspaceCmp").openTab({url: component.get('v.origenTabUrl'),focus:true});
	}
})