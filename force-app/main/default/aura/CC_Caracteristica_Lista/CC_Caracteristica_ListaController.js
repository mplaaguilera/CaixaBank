({
	init: function(component) {
        var getCaracteristicasConAviso = component.get("c.getCaracteristicasConAviso");
        getCaracteristicasConAviso.setParams({
            'sID' : component.get("v.recordId")
        });
        
        getCaracteristicasConAviso.setCallback(this, function(response){
            if (response.getState() === "SUCCESS" ) {
                var data = response.getReturnValue();        
                component.set('v.gridData', data);
                component.set('v.numCar', data.length);
            }else{
                console.log('There was a problem : '+response.getError());
            }
        });
        $A.enqueueAction(getCaracteristicasConAviso);

        /*
        var recordId = component.get("v.recordId");
        var sID = component.get("v.recordId");
        console.log('v.recordId : '+recordId);
        var getCaracteristicasConAviso = component.get("c.getCaracteristicasConAviso");
        console.log('v.getCaracteristicasConAviso : '+getCaracteristicasConAviso);
        console.log(getCaracteristicasConAviso);
        getCaracteristicasConAviso.setParams({sID: component.get("v.recordId")});
        console.log('v.sID : '+sID);
        getCaracteristicasConAviso.setCallback(response => {
            console.log('dentro');
            if (response.getState() === "SUCCESS") {
                console.log('dentro1');
                var data = response.getReturnValue();
                console.log('v.gridData : '+data);
                console.log('v.numCar : '+data.length);
                component.set('v.gridData', data);
                component.set('v.numCar', data.length);
            }else{
                console.log('dentro2');
                console.log('There was a problem : '+response.getError());
            }
        })
        $A.enqueueAction(getCaracteristicasConAviso);
        */
    }

})