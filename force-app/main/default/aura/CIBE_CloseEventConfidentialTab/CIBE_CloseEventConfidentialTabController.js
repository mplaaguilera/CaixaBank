({
    doInit  : function(component, event, helper) {

        var recordId = component.get('v.recordId');
        console.log(recordId);

        let action = component.get("c.getFields");
        action.setParams({
            recordId: recordId
        });

        action.setCallback(this, function(response){
            let state = response.getState();
            if(state==="SUCCESS"){
                let fieldsStr = response.getReturnValue();
                console.log("fields => ",fieldsStr);

                var confidencialidad = fieldsStr[0].CIBE_Confidential__c;
                var acceso = fieldsStr[0].AV_Task__r.CIBE_ConfidentialEventAccess__c;

                if(confidencialidad == true && acceso == false){
                    var workspaceAPI = component.find("workspace");
                    workspaceAPI.getFocusedTabInfo().then(function(response) {
                        var focusedTabId = response.tabId;
                        setTimeout(() => {
                            workspaceAPI.closeTab({tabId: focusedTabId});
                        }, 3000);
                    })
                    .catch(function(error) {
                        console.log(error);
                    });
                }

            }
        });
        $A.enqueueAction(action);

       
    }
})