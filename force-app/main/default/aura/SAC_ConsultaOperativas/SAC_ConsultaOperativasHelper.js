({
    fetchMotivos: function(component, event) {
        var action = component.get("c.fetchMotivos");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                var fieldMap = [];
                for(var key in result){
                    fieldMap.push({value: key, label: result[key]});
                }
                component.set("v.motivosDevolver", fieldMap);
            }
        });
			
        $A.enqueueAction(action);
    },
    mostrarToast: function(tipo, titulo, mensaje, component) {
		let toastEvent = $A.get('e.force:showToast');
		toastEvent.setParams({'title': titulo, 'message': mensaje, 'type': tipo, 'mode': 'dismissable', 'duration': 4000});
		toastEvent.fire();
        component.set('v.user', response.getReturnValue().UserId);
	},
    reinit : function(component) {
        
        var getCaso = component.get('c.recuperarCaso');
        getCaso.setParam('caseId', component.get('v.recordId'));
        
        getCaso.setCallback(this, function(response) {
        	var state = response.getState();
            if (state === "SUCCESS") {
				
                component.set('v.caso', response.getReturnValue());

                if(response.getReturnValue().Status == 'SAC_005'){
                    component.set('v.disableGestionar', true); 
                    component.set('v.disableDescartar', true); 
                    component.set('v.disableDerivar', true); 
					component.set('v.esPropietario', true);
					component.set('v.estaEnLaCola', true);
                }
                else{
                    var getUser = component.get('c.recuperarUser');
                    getUser.setCallback(this, function(response){
                    
                        component.set('v.user', response.getReturnValue().UserId);
                        if(component.get('v.user') === component.get('v.caso.OwnerId')){
                            component.set('v.esPropietario', true);  
                            component.set('v.estaEnLaCola', false);  
                        }else{
                            component.set('v.esPropietario', false);  
                            component.set('v.estaEnLaCola', true);
                        }
                    });
                    $A.get('e.force:refreshView').fire();
                    $A.enqueueAction(getUser); 
                }
               
        	}            
        });
        
		$A.enqueueAction(getCaso); 
	}


})