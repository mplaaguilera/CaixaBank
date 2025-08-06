({
    doInit: function(component, event, helper){
        helper.show(component);
        //var actualData = component.get("v.data");
        helper.getInitData(component);
    }
})