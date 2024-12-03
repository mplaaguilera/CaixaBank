({
    casoSelect: function(component) {
        component.set('v.selectedCaseNumber', component.find('ParentCase').get('v.value'));
	},
	
    relacionarConParentCase: function(component, event, helper) {
		//Validación de campos requeridos
		let validarCampos = component.get('c.validarCampos');
		validarCampos.setParams({
			'casoId': component.get('v.selectedCaseNumber'),
			'casoPadreId': component.get('v.recordId')
		});
		validarCampos.setCallback(this, response => {
			if (response.getState() === 'SUCCESS') {
				let camposNoValidos = response.getReturnValue();
				if (camposNoValidos.length > 0) {
					//Validación de campos requeridos KO
					let mensaje = '';
					//Se comprueba si la clasificación está inactiva
					if (camposNoValidos.indexOf('Clasificación inactiva') > -1) {
						//Si lo está se prepara el mensaje y se quita el elemento del
						//array para que no salga en la lista de campos no informados.
						mensaje = 'El caso está vinculado con una clasificación que ya no está activa. ';
						camposNoValidos.splice(camposNoValidos.indexOf('Clasificación inactiva'), 1);
					}
					if (camposNoValidos.indexOf('Agrupador Cerrado') > -1) {
						//Si lo está se prepara el mensaje y se quita el elemento del
						//array para que no salga en la lista de campos no informados.
						mensaje = 'El Agrupador de Casos debe estar Activo';
						camposNoValidos.splice(camposNoValidos.indexOf('Agrupador Cerrado'), 1);
					}
					if (camposNoValidos.length > 0) {
						//El resto de elementos son campos obligatorios actualmente nulos
						mensaje += 'Debe informar los siguientes campos obligatorios: ' + camposNoValidos.join(', ') + '.';
					}
					if (mensaje !== '') {
						helper.mostrarToast('error', 'Operativa no disponible', mensaje);
					}
				} else {
					let relacionarParent = component.get('c.relacionarConParentCaseController');
					relacionarParent.setParams({
						'childCaseId': component.get('v.selectedCaseNumber'),
						'recordId': component.get('v.recordId')
					});
					relacionarParent.setCallback(this, respuesta => {
						if (respuesta.getState() === 'SUCCESS') {
							component.set('v.selectedCaseNumber', null);
							$A.get('e.force:refreshView').fire();
						}
					});
					$A.enqueueAction(relacionarParent);
				}
			} 
		});
		$A.enqueueAction(validarCampos);

    }
})