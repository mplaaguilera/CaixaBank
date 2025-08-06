({
    initLabel : function(cmp,event,helper) {
        var action = cmp.get("c.setLabel");
        action.setCallback(this,function(response){
            if(response.getState() === 'SUCCESS'){
                   var utilityAPI = cmp.find("utilitybar2");
                       utilityAPI.setUtilityLabel({
                       label: response.getReturnValue()
                    });
                }
            });
        $A.enqueueAction(action)
    },
    refreshComponent : function(cmp, event, helper) {
        var componente = cmp.find("cederPermisosCmp");
        componente.switchSpinner();
        componente.checkForPermissionsGivenToUsers();
    },
    handleShowModalNew: function(cmp, evt, helper) {
        let numeroDePermisos = cmp.get("v.numPermiso");
        $A.createComponent("c:av_newPermisoModal", {
            "permisosDisponibles":numeroDePermisos,
            "onexitmodal": cmp.getReference("c.refreshComponent")            
        },
        function(content, status) {
             cmp.find('overlayLib').showCustomModal({
                       header: null,
                       body: content,
                       closeCallback: function() {
                       }
                   })
           });
        },
        setNumPerm: function(component,event){
            component.set("v.numPermiso",event.getParam('numPerm'));
        },
        handleShowModalUpdt: function(cmp,evt,helper){
            $A.createComponent("c:av_updatePermiso",{
                "permiso":evt.getParam('info'),
                "onrefresh": cmp.getReference("c.refreshComponent")
            },
            function(content,status){
                cmp.find('overlayLib').showCustomModal({
                    header:null,
                    body:content,
                    closeCallBack:function(){
                    }
                })
            });
        }
})