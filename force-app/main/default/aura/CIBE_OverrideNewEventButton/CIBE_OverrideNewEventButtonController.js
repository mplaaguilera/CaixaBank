({
    doInit : function(component, event, helper) {

        var action = component.get("c.getRoleUser");
        var recordTypeId = component.get("v.pageReference").state.recordTypeId;
        console.log('*** recordTypeId ' + recordTypeId);
        var cibe = 'CIBE';
        action.setParams({ recordType : recordTypeId });


        action.setCallback( this, function(actionResult) {
            var state = actionResult.getState();

            if (state === "SUCCESS"){
                var result = actionResult.getReturnValue();
                //component.set("v.value",result);
                if(result === cibe || result === 'errorEMP'){
                    component.set("v.value",cibe);
                }else if(result === 'altaEMP'){
                    var createRecordEvent = $A.get("e.force:createRecord");
                    createRecordEvent.setParams({
                        "entityApiName": "Event",
                        "recordTypeId" : recordTypeId
                    });
                    createRecordEvent.fire();
                }else {
                    var createRecordEvent2 = $A.get("e.force:createRecord");
                    createRecordEvent2.setParams({
                        "entityApiName": "Event",
                        "recordTypeId" : recordTypeId
                    });
                    createRecordEvent2.fire();
                }
            }
        });
        $A.enqueueAction(action);
    }


    // closeFocusedTabFinish : function(component, evt, helper) {
    //     var newEventId = evt.getParam("neweventid");
    //     var workspaceAPI = component.find("workspace");
    //     workspaceAPI.getEnclosingTabId().then(enclosingTab =>{
    //         workspaceAPI.openSubtab({parentTabId: enclosingTab,recordId:newEventId,focus:true}).then(() =>{
    //             var workspaceAPI2 = component.find("workspaceCmp");
    //             workspaceAPI2.closeTab({tabId: component.get("v.origenTab")});
    //         })
    //         .catch(function(error) {
    //             console.log(error);
    //         });
    //     })
        
    // },

    // closeFocusedTab : function(component, event, helper) {

    //     var workspaceAPI = component.find("workspace");
    //     workspaceAPI.getFocusedTabInfo().then(function(response) {
    //         var focusedTabId = response.tabId;
    //         workspaceAPI.closeTab({tabId: focusedTabId});
    //     })
    //     .catch(function(error) {
    //         console.log(error);
    //     });
    // },

    // closeFocusedTab : function(component, event, helper) {
	// 	var origenTab = component.get("v.origenTab");
	// 	var workspaceAPI = component.find("workspace");
	// 	workspaceAPI.closeTab({tabId: origenTab});

	
	// },

    // onPageReferenceChange: function(component, event, helper) {
	// 	var myPageRef = component.get("v.pageReference");
	// 	component.set("v.id", myPageRef.state.c__recId);
	// },

	// focusedTab : function(component, event, helper) {
    //     component.find("workspace").openTab({url: component.get('v.origenTabUrl'),focus:true});
	// },
    
    // closeFocusedTabAndClose : function(component, event, helper) {
	// 	var id = component.get("v.id");
	// 	var origenTab = component.get("v.origenTab");
	// 	var workspaceAPI = component.find("workspace");
	// 	workspaceAPI.openTab({url: '#/sObject/'+id+'/view',focus:true});
	// 	workspaceAPI.closeTab({tabId: origenTab});
	
	// },	
    
    // focusRecordTab : function(component, event, helper) {
	// 	var id = component.get("v.id");
	// 	var workspaceAPI = component.find("workspace");
	// 	workspaceAPI.openTab({url: '#/sObject/'+id+'/view',focus:true});
			
	
	// }


})