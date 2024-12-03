({
	init: function(component) {
		//Inicializar acciones y columnas de la datatable de correos
		component.set('v.correosColumns', [{label: '', fieldName: '', initialWidth: 25, cellAttributes: {iconName: 'standard:email'}},
			{label: 'Fecha de recepción', fieldName: 'MessageDate', type: 'text', initialWidth: 190, iconName: 'utility:dayview'},
			{label: 'Asunto', fieldName: 'CC_Id_Aux__c', type: 'url', initialWidth: 450, iconName: 'utility:type_tool', typeAttributes: {label: {fieldName: 'Subject'}, target: '_self'}},
			{label: 'De', fieldName: 'FromAddress', type: 'text', iconName: 'utility:send'},
			{label: 'Para', fieldName: 'ToAddress', type: 'text', iconName: 'utility:email_open'},
			{label: 'Adjuntos', fieldName: 'HasAttachment', type: 'boolean', initialWidth: 100, iconName: 'utility:attach'},
			{type: 'action', typeAttributes: {rowActions: [
				{label: 'Vincular a oportunidad', name: 'CSBD_Vincular_Oportunidad', iconName: 'action:new_opportunity'},
				{label: 'Ver detalle', name: 'CSBD_Ver_Detalle_Correo', iconName: 'action:info'}
			]}}]);

		//Inicializar columnas de la datatable de oportunidades
		component.set('v.oportunidadesColumns', [{label: '', fieldName: '', initialWidth: 25, cellAttributes: {iconName: 'standard:opportunity'}},
			{label: 'Fecha de creación', fieldName: 'CreatedDate', type: 'text', initialWidth: 190, iconName: 'utility:dayview'},
			{label: 'Título', fieldName: 'CSBD_Id_Aux__c', type: 'url', initialWidth: 500, iconName: 'utility:type_tool', typeAttributes: {label: {fieldName: 'Name'}, target: '_self'}},
			{label: 'Estado', fieldName: 'CSBD_Estado__c', type: 'text', iconName: 'utility:bookmark'}]);

		//Obtener los correos sin vincular
		$A.enqueueAction(component.get('c.obtenerCorreos'));
	},

	obtenerCorreos: function(component, event, helper) {
		//Obtener correos CSBD no vinculados
		let obtenerCorreosNoVinculados = component.get('c.obtenerCorreosNoVinculados');
		let buzonCaixaBank = component.get('v.buzonCaixaBank');
		obtenerCorreosNoVinculados.setParams({'empresa': buzonCaixaBank ? 'CaixaBank' : 'imaginBank'});
		obtenerCorreosNoVinculados.setCallback(this, response => {
			if (response.getState() === 'SUCCESS') {
				let correos = response.getReturnValue();
				correos = correos.map(correo => {
					correo.MessageDate = $A.localizationService.formatDateTime(correo.MessageDate, 'dd-MM-yyyy HH:mm');
					return correo;
				});
				component.set('v.correos', correos);
			} else if (response.getState() === 'ERROR') {
				helper.mostrarToast('No es posible recuperar los correos', 'Se produjo un problema recuperando los correos no vinculados.', 'error');
			}
		});
		$A.enqueueAction(obtenerCorreosNoVinculados);
	},

	correosHandleRowSelection: function(component, event) {
		//Cambio en el dominio de filas seleccionadas
		component.set('v.correosNoneSelected', event.getParam('selectedRows').length === 0);
		component.set('v.correosSelectedRows', event.getParam('selectedRows'));
	},

	correosHandleRowActions: function(component, event) {
		//Lanza operativa en función de la acción ejecutada
		component.set('v.correosRow', event.getParam('row'));
		if (event.getParam('action').name === 'CSBD_Vincular_Oportunidad') {
			//Mostrar modal para vincular oportunidad
			$A.enqueueAction(component.get('c.abrirModalVincularOportunidad'));
		} else if (event.getParam('action').name === 'CSBD_Ver_Detalle_Correo') {
			component.find('workspace').openTab({'recordId': component.get('v.correosRow.Id'), 'focus': true})
				.then($A.get('e.force:closeQuickAction').fire());
		}
	},

	cambiarBuzon: function(component) {
		component.set('v.buzonCaixaBank', !component.get('v.buzonCaixaBank'));
		$A.enqueueAction(component.get('c.obtenerCorreos'));
	},

	abrirModalVincularOportunidad: function(component) {
		let obtenerOportunidades = component.get('c.obtenerOportunidades');
		obtenerOportunidades.setParams({
			'empresa': component.get('v.buzonCaixaBank') ? 'CaixaBank' : 'imaginBank',
			'direccionCorreo': component.get('v.correosRow.FromAddress')
		});
		obtenerOportunidades.setCallback(this, response => {
			if (response.getState() === 'SUCCESS') {
				let oportunidades = response.getReturnValue();
				component.set('v.mismoRemitente', oportunidades.length > 0);
				$A.util.addClass(component.find('modalBoxVincularOportunidad'), 'slds-fade-in-open');
				$A.util.addClass(component.find('modalbackdropVincularOportunidad'), 'slds-backdrop--open');
				if (oportunidades.length > 0) {
					oportunidades = oportunidades.map(oportunidad => {
						oportunidad.CreatedDate = $A.localizationService.formatDateTime(oportunidad.CreatedDate, 'dd-MM-yyyy HH:mm');
						return oportunidad;
					});
					component.set('v.oportunidades', oportunidades);
				} else {
					window.setTimeout($A.getCallback(() => component.find('inputIdentificadorOportunidad').focus()), 90);
				}
			}
		});
		$A.enqueueAction(obtenerOportunidades);
	},

	oportunidadesHandleRowSelection: function(component, event) {
		//Cambio en el dominio de filas seleccionadas
		component.set('v.oportunidadesNoneSelected', false);
		component.set('v.oportunidadesSelectedRows', event.getParam('selectedRows'));
	},

	cerrarModalVincularOportunidad: function(component) {
		$A.util.removeClass(component.find('modalBoxVincularOportunidad'), 'slds-fade-in-open');
		$A.util.removeClass(component.find('modalbackdropVincularOportunidad'), 'slds-backdrop--open');
	},

	vincular: function(component, event, helper) {
		component.set('v.oportunidadesNoneSelected', true);
		let numeroOportunidad;
		let vincularCorreoAOportunidad;
		if (component.get('v.mismoRemitente')) {
			numeroOportunidad = component.get('v.oportunidades').find(elem => elem.Id === component.get('v.oportunidadesSelectedRows')[0].Id).CSBD_Identificador__c;
			vincularCorreoAOportunidad = component.get('c.vincularCorreoAOportunidad');
			vincularCorreoAOportunidad.setParams({
				'idEmailMessage': component.get('v.correosRow.Id'),
				'idOpportunity': component.get('v.oportunidadesSelectedRows')[0].Id
			});
		} else {
			numeroOportunidad = component.find('inputIdentificadorOportunidad').get('v.value');
			vincularCorreoAOportunidad = component.get('c.vincularCorreoAOportunidadNumero');
			vincularCorreoAOportunidad.setParams({
				'idEmailMessage': component.get('v.correosRow.Id'),
				'numeroOportunidad': numeroOportunidad
			});
		}

		vincularCorreoAOportunidad.setCallback(this, response => {
			if (response.getState() === 'SUCCESS') {
				//Refrescar listado
				$A.enqueueAction(component.get('c.obtenerCorreos'));

				//Toast de confirmación
				helper.mostrarToast('Se vinculó el correo', 'Se vinculó correctamente el correo con asunto "' + component.get('v.correosRow.Subject') + '" a la oportunidad ' + numeroOportunidad, 'success');

				//Cerrar modal
				$A.util.removeClass(component.find('modalBoxVincularOportunidad'), 'slds-fade-in-open');
				$A.util.removeClass(component.find('modalbackdropVincularOportunidad'), 'slds-backdrop--open');

				if (component.find('abrirDetalleOportunidad').get('v.checked')) {
					component.find('workspace').openTab({'recordId': response.getReturnValue(), 'focus': true})
						.then($A.get('e.force:closeQuickAction').fire());
				}
			} else if (response.getState() === 'ERROR') {
				let errors = vincularCorreoAOportunidad.getError();
				if (errors) {
					var mensajeError = '';
					errors.forEach(error => mensajeError + error.message + '\n');
					helper.mostrarToast('No se pudo vincular correo a la oportunidad', mensajeError, 'error');
				}
			}
		});
		$A.enqueueAction(vincularCorreoAOportunidad);
	},

	rechazar: function(component, event, helper) {
		//Se prepara la lista de Ids seleccionados
		let idsEmailMessage = [];
		let correosSelectedRows = component.get('v.correosSelectedRows');
		correosSelectedRows.forEach(element => idsEmailMessage.push(element.Id));

		//Rechazar correos
		let rechazarCorreo = component.get('c.rechazarCorreo');
		rechazarCorreo.setParams({'idsEmailMessage': idsEmailMessage});
		rechazarCorreo.setCallback(this, response => {
			if (response.getState() === 'SUCCESS') {
				//Refrescar listado
				$A.enqueueAction(component.get('c.obtenerCorreos'));

				//Toast de confirmación
				if (correosSelectedRows.length === 1) {
					helper.mostrarToast('Se rechazó el correo', 'Se rechazó correctamente 1 correo.', 'info');
				} else {
					helper.mostrarToast('Se rechazaron los correos', 'Se rechazaron correctamente ' + correosSelectedRows.length + ' correos.', 'info');
				}

				$A.enqueueAction(component.get('c.cerrarModalConfirmacion'));
			}
		});
		$A.enqueueAction(rechazarCorreo);
	},

	abrirModalConfirmacion: function(component) {
		$A.util.addClass(component.find('modalBoxConfirmacion'), 'slds-fade-in-open');
		$A.util.addClass(component.find('modalbackdropConfirmacion'), 'slds-backdrop--open');
	},

	cerrarModalConfirmacion: function(component) {
		$A.util.removeClass(component.find('modalBoxConfirmacion'), 'slds-fade-in-open');
		$A.util.removeClass(component.find('modalbackdropConfirmacion'), 'slds-backdrop--open');
	},

	modalVincularOportunidadTeclaPulsada: function(component, event) {
		if (event.keyCode === 27) { //ESC
			$A.enqueueAction(component.get('c.cerrarModalVincularOportunidad'));
		}
	},

	cambiarModoVincular: function(component) {
		component.set('v.oportunidadesNoneSelected', true);
		component.set('v.mismoRemitente', !component.get('v.mismoRemitente'));
		if (!component.get('v.mismoRemitente')) {
			window.setTimeout($A.getCallback(() => component.find('inputIdentificadorOportunidad').focus()), 90);
		}
	},

	inputIdentificadorOportunidadOnChange: function(component) {
		component.set('v.oportunidadesNoneSelected', component.find('inputIdentificadorOportunidad').get('v.value').length < 10);
	}
});