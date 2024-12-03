({
    toggleProgress: function (cmp) {
        if (cmp.get('v.isProgressing')) {
            // stop
            cmp.set('v.isProgressing', false);
            clearInterval(cmp._interval);
        } else {
            // start
            cmp.set('v.isProgressing', true);
            cmp._interval = setInterval($A.getCallback(function () {
                var progress = cmp.get('v.progress');
                if (progress == 100)
                {
                    cmp.set('v.progress', 0 );
                    //$A.get('e.force:refreshView').fire();
                }
                else{
                    cmp.set('v.progress', progress +1 );
                }  
                
            }), 20);
        }
    },
    refrescado : function(component, event, helper) {
        helper.refrescado(component);

        var casoOldId = component.get('v.caso.Id');
        component.set('v.stado',component.get('v.caso.Status'));
        var casoOldStatus = component.get('v.stado');
      //  alert(casoOldStatus);

        setTimeout(function(){ 
            helper.refrescado(component);
            var casoNewId = component.get('v.caso.Id');
            var casoNewStatus = component.get('v.caso.Status');
            component.set('v.stado',casoNewStatus);
            //alert(casoOldStatus + " - " + casoNewStatus);

            if (casoOldId == casoNewId)
            {

                if (casoOldStatus != casoNewStatus)
                {
                    $A.get('e.force:refreshView').fire();
                }
            }

        }, 3000);
    },
    forzarRefresco: function(component, event, helper) {
        $A.get('e.force:refreshView').fire();
    }
})