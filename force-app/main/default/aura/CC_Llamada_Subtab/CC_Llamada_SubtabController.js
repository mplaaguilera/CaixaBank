({
	doInit: function(component) {
		const getCuentasContactosCasos = component.get('c.getCuentasContactosCasos');
		getCuentasContactosCasos.setParam('idLlamada', component.get('v.recordId'));
		getCuentasContactosCasos.setCallback(this, response => {
			if (response.getState() === 'SUCCESS') {

				const openSubtab = (objectName, recordId) => {
					if (recordId) {
						let workspaceAPI = component.find('workspace');
						workspaceAPI.openSubtab({
							parentTabId: workspaceAPI.getEnclosingTabId(),
							url: '/lightning/r/' + objectName + '/' + recordId + '/view',
							focus: false
						}).catch(error => console.error(error));
					}
				};

				const retorno = response.getReturnValue();
				openSubtab('Account', retorno.idCuenta);
				openSubtab('Contact', retorno.idContacto);
				retorno.idCasos.forEach(idCaso => openSubtab('Case', idCaso));
			}
		});
		$A.enqueueAction(getCuentasContactosCasos);
	}
});