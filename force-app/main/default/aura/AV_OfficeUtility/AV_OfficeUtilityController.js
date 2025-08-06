({
    getIds : function(cmp, event, helper) {
        helper.showSpinner(cmp);
        var action = cmp.get("c.getOffices");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                cmp.set("v.accs", response.getReturnValue());
            } else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        // log the error passed in to AuraHandledException
                        console.log("Error message: " + 
                                 errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }
            }
            helper.hideSpinner(cmp);
        });
        $A.enqueueAction(action);
    },

    updateOffice : function(cmp, event, helper) {
        helper.showSpinner(cmp);
        var action = cmp.get("c.updateUserOffice");
        action.setParams({newOffice : event.target.id});
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                console.log('response', response.getReturnValue());
                if (response.getReturnValue() == 'OK') {
                    helper.displayToastSuccess(cmp, 'Oficina actualizada');
                    //getIds();
                } else {
                    helper.displayToastError(cmp, $A.get("$Label.c.AV_CMP_SaveMsgError"));
                }
            } else if (state === "ERROR") {
                helper.displayToastError(cmp, $A.get("$Label.c.AV_CMP_SaveMsgError"));
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        // log the error passed in to AuraHandledException
                        console.log("Error message: " + 
                                 errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }
            }
            helper.hideSpinner(cmp);
        });
        $A.enqueueAction(action);
    },

    setUtilityLabel : function(component, event, helper) {
        var label = component.get("v.office");
        setTimeout(function() {
            var utilityAPI = component.find("utilitybar");
            utilityAPI.setUtilityLabel({
                label: label
            });
        }, 500);
    },

    getOffice : function(cmp, event, helper) {
        var action = cmp.get("c.getCurrentOffice");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var isRefreshed = cmp.get("v.isRefreshed");
                if (isRefreshed) {
                    var findChildChangeOffice = cmp.find('childChangeOffice');
                    findChildChangeOffice.getOffices();
                }
                var utilityAPI = cmp.find("utilitybar");
                utilityAPI.setUtilityLabel({
                    label: response.getReturnValue()
                });
            } else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        // log the error passed in to AuraHandledException
                        console.log("Error message: " + 
                                 errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }
            }
            helper.hideSpinner(cmp);
        });
        $A.enqueueAction(action);
    },

    refreshComponent : function(cmp, event, helper) {
        $A.get('e.force:refreshView').fire();
        cmp.set("v.isRefreshed", true);
    }
})