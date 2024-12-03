({
	init: function(component, event, helper) {
		helper.consultaExcepciones(component, helper, 'Ini');
    },
    
    recordUpdated: function(component, event, helper) {
        var eventParams = event.getParams();
        if(eventParams.changeType === "CHANGED") {
            var changedFields = eventParams.changedFields;

            //console.log('Fields that are changed: ' + JSON.stringify(changedFields));
            var resultsToast = $A.get("e.force:showToast");
            
            var lstcampos='';
            for(var campo in changedFields){
                lstcampos = lstcampos + campo + ',';
            }
            
            var tipo='Otros';
            console.log(lstcampos);
            if (lstcampos!='SystemModstamp,'){
                if (lstcampos.indexOf("OwnerId")>-1) {
                    tipo='Cambio de propietario';
                }
	            helper.consultaExcepciones(component, helper, tipo);    
            }
        }
    }
})