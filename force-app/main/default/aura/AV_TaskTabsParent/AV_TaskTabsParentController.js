({
    handleApplicationEvent : function(cmp, event) {
        cmp.set("v.isrefreshing", false);
        var message = event.getParam("message");
        // set the handler attributes based on event data
        if(message == 'REFRESH') {
            cmp.set("v.isrefreshing", true);
        }
    }
})