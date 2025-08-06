({
    getInitData : function(cmp) {
        var getInitDataCall = cmp.get('c.getInitData');
        getInitDataCall.setParams({ "recordId" : cmp.get("v.recordId")});
        getInitDataCall.setCallback(this, function(response){
            //store state of response
            var state = response.getState();
            if (state === "SUCCESS") {
                var data = response.getReturnValue();
                if(!data){
                    console.log("error", "empty data");
                } else {
                    cmp.set("v.data", data);
                }
            } else {
                console.log("error", response.getError());
            }
            this.hide(cmp);
        });
        getInitDataCall.setBackground();
        $A.enqueueAction(getInitDataCall);
    },

    show: function (cmp) {
        var spinner = cmp.find("mySpinner");
        $A.util.removeClass(spinner, "slds-hide");
        $A.util.addClass(spinner, "slds-show");
    },

    hide: function (cmp) {
        var spinner = cmp.find("mySpinner");
        $A.util.removeClass(spinner, "slds-show");
        $A.util.addClass(spinner, "slds-hide");
    }
})