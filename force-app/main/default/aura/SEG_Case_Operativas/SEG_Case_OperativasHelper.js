({
	reinit: function(component) {
		//component.find('caseData').reloadRecord(true);
		$A.get('e.force:refreshView').fire();
	},

	mostrarToast: function(tipo, titulo, mensaje) {
		let toastEvent = $A.get('e.force:showToast');
		let duracionToast = 4000;
		if (tipo != 'success')
		{
			duracionToast = 10000;
		}
		toastEvent.setParams({ 'title': titulo, 'message': mensaje, 'type': tipo, 'mode': 'dismissable', 'duration': duracionToast });
		toastEvent.fire();
	},

	setDataAnexos: function(component) {
		let getAnexos = component.get('c.getFilesCase');
		getAnexos.setParam('casoId', component.get('v.recordId'));
		getAnexos.setCallback(this, response => {
			if (response.getState() === 'SUCCESS') {
				component.set('v.dataAnexos', response.getReturnValue());
			}
		});
		$A.enqueueAction(getAnexos);
	},

	fetchCRSeguimiento: function(component) {
		let action = component.get('c.fetchCRSeguimientoController');
		action.setCallback(this, function (response) {
			let values = [];
			let result = response.getReturnValue();
			for (let key in result) {
				values.push({
					label: result[key],
					value: key
				});
			}
			component.set('v.CRs', values);
		});
		$A.enqueueAction(action);
		window.setTimeout($A.getCallback(() => component.find('inputNombresContratos').focus()), 400);
	},

	fetchEmail: function(component) {
		let actionEm = component.get('c.fetchEmailsCaso');
		actionEm.setParam('caseId', component.get('v.recordId'));
		actionEm.setCallback(this, function (response) {
			let values = [];
			let result = response.getReturnValue();
			for (let key in result) {
				values.push({
					label: result[key],
					value: key
				});
			}
			component.set('v.Emailcaso', values);
		});
		$A.enqueueAction(actionEm);
	},

	fetchEmailcaso: function(component) {
		let actionEm = component.get('c.fetchEmailsCaso');
		actionEm.setParam('caseId', component.get('v.caseId'));
		actionEm.setCallback(this, function (response) {
			let values = [];
			let result = response.getReturnValue();
			for (let key in result) {
				values.push({
					label: result[key],
					value: key
				});
			}
			component.set('v.Emailcaso', values);
		});
		$A.enqueueAction(actionEm);
	},

	abrirTab: function(component, idCaso) {
		let workspaceAPI = component.find('workspace');
		workspaceAPI.openTab({recordId: idCaso, focus: true})
		.then(tab => workspaceAPI.getTabInfo({tabId: tab}))
		.catch(error => {
			console.error(error);
		});
	},

	postChatter: function(component, idCaso, operativa, notaTipificada, observaciones) {
		let publicar = component.get('c.postOnChatter');
		publicar.setParams({
			caseId: idCaso,
			operativa: operativa,
			notaTipificada: notaTipificada,
			observaciones: observaciones
		});
		publicar.setCallback(this, response => {
			var helper = this;
			helper.reinit(component);
		});
		$A.enqueueAction(publicar);
	},

	formatBytes:function(bytes,decimals) {
		if (bytes === 0) {
			return '0 Bytes';
		}
		var k = 1024,
			dm = decimals || 2,
			sizes = ['Bytes', 'KB', 'MB', 'GB', 'TB', 'PB', 'EB', 'ZB', 'YB'],
			i = Math.floor(Math.log(bytes) / Math.log(k));
		return parseFloat((bytes / Math.pow(k, i)).toFixed(dm)) + ' ' + sizes[i];
	}
});