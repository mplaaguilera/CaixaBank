({
    fetchCVRespuesta: function(component) {
        var idCase = component.get("v.recordId");
        var action = component.get('c.getCVRespuestas');
        action.setParams({'recordId': idCase});
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(state === "SUCCESS") {
                var contentVersions = response.getReturnValue();
                component.set("v.contentVersions", contentVersions);
                component.set("v.columns", [
                    { label: 'Title', fieldName: 'Title', type: 'text' }
                ]);
                if(contentVersions == null || contentVersions.length === 0){
                    component.set('v.hayDocs', true);
                }else{
                    component.set('v.hayDocs', false);

                }
                var docs = component.get('v.hayDocs');
            }
        });
        
        $A.enqueueAction(action);
    }
})