({
    fetchCountHelper : function(component, event, helper) {
        component.set('v.mycolumnsCount', [
            {label: 'Servicio', fieldName: 'servicio', type: 'text'},
            {label: 'DXC', fieldName: 'contadorDXC', type: 'Integer'},
            {label: 'MST', fieldName: 'contadorMST', type: 'Integer'},
            ]);
        var action = component.get("c.datosTotal");
        action.setParams({
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS") {
            	let mapResult = response.getReturnValue();
                let contadorMST = 0;
                let contadorDXC = 0;
                component.set("v.skillReqListCount", mapResult);
            	let recordList = [];
                for (var key in mapResult) {
                    if(mapResult[key].proveedor == 'DXC'){
                    	contadorDXC = contadorDXC +1;    
                    }else if(mapResult[key].proveedor == 'MST'){
                     	contadorMST = contadorMST +1;       
                    } 
        		}
        		component.set("v.contadorDXC", contadorDXC);
        		component.set("v.contadorMST", contadorMST);
            }
        });
        $A.enqueueAction(action);
    }
    
    
})