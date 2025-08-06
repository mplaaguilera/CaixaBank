({
    handleComponentEvent : function(component) {
        var actionAPI = component.find("quickActionAPI");
        var args = { actionName: "CC_Agrupador__c.CC_Send_Email", 
                    targetFields: { ToAddress:  {value: listPara},
                                    CcAddress:  {value: ''},
                                    BccAddress: {value: ''}}}; 
        actionAPI.selectAction(args).then(() => {
            actionAPI.setActionFieldValues(args);
            
        }).catch(function(e) {
            if (e.errors) {
                console.log('ERROR preparando el borrador del correo saliente.');
            }
        });
    }
})