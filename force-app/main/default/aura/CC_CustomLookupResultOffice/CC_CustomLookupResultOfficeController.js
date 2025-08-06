({
	seleccionarResultado: function(component) {
		let compEvent = component.getEvent('oSelectedOfficeEvent');
		let copiaAux = [];
		compEvent.setParam('officeByEvent', component.get('v.oficina'));
		compEvent.setParam('segundaOficina', component.get('v.segundaOficina'));
		copiaAux.push(component.get('v.oficina.AV_DescFuncion__c'));
		copiaAux.push(component.get('v.oficina.AV_EAPGestor__pc'));
		component.set('v.para', component.get('v.oficina.CC_Email__c'));
		component.set('v.copia', copiaAux);

		compEvent.fire();
	}
});