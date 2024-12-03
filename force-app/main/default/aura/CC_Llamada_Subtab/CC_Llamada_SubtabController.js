({
	doInit: function(component, event, helper) {
		let getCuentasContactosCasos = component.get('c.getCuentasContactosCasos');
		getCuentasContactosCasos.setParam('idLlamada', component.get('v.recordId'));
		getCuentasContactosCasos.setCallback(this, response => {
			if (response.getState() === 'SUCCESS') {
				let retorno = response.getReturnValue();
				helper.openSubtab(component, 'Account', retorno.idCuenta);
				helper.openSubtab(component, 'Contact', retorno.idContacto);
				retorno.idCasos.forEach(idCaso => helper.openSubtab(component, 'Case', idCaso));
			}
		});
		$A.enqueueAction(getCuentasContactosCasos);
	}
});