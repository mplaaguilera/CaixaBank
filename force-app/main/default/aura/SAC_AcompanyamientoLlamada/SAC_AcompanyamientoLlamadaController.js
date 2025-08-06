({
    doInit : function(component, event, helper) {
        //console.log('dento init');
        let getInfo = component.get("c.getInfoInit");
        let registro = component.get("v.recordId");
        getInfo.setParams({'recordId' : registro});
        getInfo.setCallback(this, function(response){
            //console.log('dentro callback ' + response.getState());
            var state = response.getState();
            if (state === "SUCCESS") {
                //console.log('dentro success');
                let result = response.getReturnValue();
                //console.log('result ' + result);
                component.set('v.necesitaGestion', result.eval);
                component.set('v.estado', result.caso.Status);
                //component.set('v.botonPulsado', result.caso.SAC_RedaccionFinal__c);
                //alert(JSON.stringify(result));
                //component.set('v.necesitaGestion', true);
            }
        });
        $A.enqueueAction(getInfo);
    },

    llamadaNueva : function(component, event, helper) {        
        component.set('v.isLoading', true);
        let accionesEnApex = component.get("c.ejecutarApex");
        let registro = component.get("v.recordId");
        accionesEnApex.setParams({'recordId' : registro});
        accionesEnApex.setCallback(this, function(response){
            var state = response.getState();
            if(state === "SUCCESS"){
                let toastParams = {
                    title: "Acción ejecutada",
                    message: 'Ha creado la llamada de acompañamiento y se ha dejado constancia de ello en el registro.', 
                    type: "success"
                };        
                component.set('v.isLoading', false);
                let toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams(toastParams);
                toastEvent.fire();
                $A.get('e.force:refreshView').fire();
            }
            else{
                let toastParams = {
                    title: "Error al generar la llamada",
                    message: 'Ha surgido un error al crear la llamada de acompañamiento', 
                    type: "error"
                };        
                component.set('v.isLoading', false);
                let toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams(toastParams);
                toastEvent.fire();
                $A.get('e.force:refreshView').fire();
            }
        });
        $A.enqueueAction(accionesEnApex);
    }
})