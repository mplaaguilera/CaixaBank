({	
	handleActualizarIdentificacion : function(component, event, helper) {
		component.find('caseData').reloadRecord(true, $A.getCallback(saveResult => {
            component.set('v.caso.CC_No_Identificado__c', true);
            component.set('v.caso.ContactId', null);
            component.set('v.caso.AccountId', null);
            component.set('v.caso.CC_IdentCliente__c', '0');
            component.find('caseData').saveRecord($A.getCallback(saveResult => {

            if (saveResult.state === 'SUCCESS') {
                helper.mostrarToast('info', 'Cliente no identificado', 'El cliente no se ha identificado.');
        	} 
			else if (saveResult.state === 'ERROR') {
            	helper.mostrarToast('error', 'Error actualizando el caso', 'Error actualizando el caso.');
            }
            }));
        }));
    }
})