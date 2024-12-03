({
	casoUpdatedDataService: function (component, event, helper) {
		if (event.getParams().changeType === 'LOADED' || event.getParams().changeType === 'CHANGED') {
			
			if (component.get('v.caso.Contact.RecordType.DeveloperName') !== 'CC_Empleado') {
				
				if (component.get('v.caso.Contact.RecordType.DeveloperName') === 'CC_Empleado' ||
					component.get('v.caso.SEG_Organizacion__c') === 'Financiación Estructurada' ||
					component.get('v.caso.SEG_Zona__c') === 'Financiación Estructurada' ||
					component.get('v.caso.SEG_Organizacion__c') === 'Centro Soporte Especialistas' ||
					component.get('v.caso.SEG_Zona__c') === 'Centro Soporte Especialistas') {
					component.set('v.discrepa', false);
				} else {
					component.set('v.discrepa', component.get('v.caso.Account.SEG_FormulaOrganizacion__c') !== component.get('v.caso.SEG_Organizacion__c')
					|| component.get('v.caso.Account.SEG_FormulaZona__c') !== component.get('v.caso.SEG_Zona__c'));
				}
			}
		} else if (event.getParams().changeType === 'ERROR') {
			helper.mostrarToast('error', 'Sin datos de otganización/zona del caso', 'No ha sido posible recuperar los datos del caso: ' + component.get('v.errorLds'));
		}
	},

	cerrarAviso: function (component) {
		component.set('v.discrepa', false);
	}
})