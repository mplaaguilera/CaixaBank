({
	casoUpdatedDataService: function (component, event, helper) {
		if (event.getParams().changeType === 'LOADED' || event.getParams().changeType === 'CHANGED') {
			
			if (component.get('v.caso.SEG_Grupo__c') == null && component.get('v.caso.ContactId') == null && component.get('v.caso.SEG_Zona__c') == null) {
       			component.set('v.bAviso', true);
				component.set('v.aviso', 'Recuerde informar el grupo de trabajo, el contacto, la organización y la zona del caso antes de realizar cualquier acción o comunicación.');
            }else if(component.get('v.caso.SEG_Grupo__c') == null && component.get('v.caso.ContactId') == null && component.get('v.caso.SEG_Zona__c') != null){
       			component.set('v.bAviso', true);
				component.set('v.aviso', 'Recuerde informar el grupo de trabajo y el contacto del caso antes de realizar cualquier acción o comunicación.');
            }else if(component.get('v.caso.SEG_Grupo__c') == null && component.get('v.caso.ContactId') != null && component.get('v.caso.SEG_Zona__c') == null){
       			component.set('v.bAviso', true);
				component.set('v.aviso', 'Recuerde informar el grupo de trabajo, la organización y la zona del caso antes de realizar cualquier acción o comunicación.');
            }else if(component.get('v.caso.SEG_Grupo__c') != null && component.get('v.caso.ContactId') == null && component.get('v.caso.SEG_Zona__c') == null){
       			component.set('v.bAviso', true);
				component.set('v.aviso', 'Recuerde informar el contacto, la organización y la zona del caso antes de realizar cualquier acción o comunicación.');
            }else if(component.get('v.caso.SEG_Grupo__c') != null && component.get('v.caso.ContactId') != null && component.get('v.caso.SEG_Zona__c') == null){
       			component.set('v.bAviso', true);
				component.set('v.aviso', 'Recuerde informar la organización y la zona del caso antes de realizar cualquier acción o comunicación.');
            }else if(component.get('v.caso.SEG_Grupo__c') != null && component.get('v.caso.ContactId') == null && component.get('v.caso.SEG_Zona__c') != null){
       			component.set('v.bAviso', true);
				component.set('v.aviso', 'Recuerde informar el contacto del caso antes de realizar cualquier acción o comunicación.');
            }else if(component.get('v.caso.SEG_Grupo__c') == null && component.get('v.caso.ContactId') != null && component.get('v.caso.SEG_Zona__c') != null){
       			component.set('v.bAviso', true);
				component.set('v.aviso', 'Recuerde informar el grupo de trabajo del caso antes de realizar cualquier acción o comunicación.');
            }else{
       			component.set('v.bAviso', false);
            }
		} else if (event.getParams().changeType === 'ERROR') {
			helper.mostrarToast('error', 'Sin datos del caso', 'No ha sido posible recuperar los datos del caso: ' + component.get('v.errorLds'));
		}
	},
	cerrarAviso: function (component) {
        component.set('v.bAviso', false);
	}
})