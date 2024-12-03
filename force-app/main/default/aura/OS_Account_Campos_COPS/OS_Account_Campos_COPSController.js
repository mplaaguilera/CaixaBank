({
	doInit: function(component) {
		let init = component.get('c.init');
		init.setParam('recordId', component.get('v.recordId'));
		init.setCallback(this, responseInit => {
			if (responseInit.getState() === 'SUCCESS') {
				let retorno = responseInit.getReturnValue();
				component.set('v.carteras', retorno.carteras);
				component.set('v.carterasCentroManipulador', retorno.carterasCentroManipulador);
				component.find('OS_Premium__c').set('v.checked', retorno.OS_Premium__c);
				component.find('OS_Cartera__c').set('v.value', retorno.OS_Cartera__c);
				component.find('CBK_HolaBank__c').set('v.checked', retorno.CBK_HolaBank__c);
				component.find('OS_Centro_Manipulador__c').set('v.value', retorno.OS_Centro_Manipulador__c);
				component.find('SEG_No_enviar_Acuse_Recibo__pc').set('v.checked', retorno.SEG_No_enviar_Acuse_Recibo__pc);
				component.find('SEG_No_enviar_Acuse_Recibo__c').set('v.checked', retorno.SEG_No_enviar_Acuse_Recibo__c);
				component.set('v.centroCaixabank', retorno.recordtype === 'CC_CentroCaixaBank');
				component.set('v.personAccount', retorno.recordtype === 'CC_ClientePA');
				component.set('v.clienteAccount', retorno.recordtype === 'CC_Cliente');
				//component.set('v.recordtype', retorno.recordtype);
				component.set('v.objectAccount', retorno.objectAccount === 'Yes');
				component.set('v.objectContact', retorno.objectContact === 'Yes');
			}
		});
		$A.enqueueAction(init);
	},

	guardarDatos: function(component, event, helper) {
		//Si es objeto cuenta
		if (component.get('v.objectAccount')) {
			if (component.get('v.personAccount')) {
				let guardar = component.get('c.guardarPA');
				guardar.setParams({
					'recordId': component.get('v.recordId'),
					'cartera': component.find('OS_Cartera__c').get('v.value'),
					'premium': component.find('OS_Premium__c').get('v.checked'),
					'acuse': component.find('SEG_No_enviar_Acuse_Recibo__pc') ? component.find('SEG_No_enviar_Acuse_Recibo__pc').get('v.checked') : false
				});

				guardar.setCallback(this, responseGuardar => {
					if (responseGuardar.getState() === 'SUCCESS') {
						helper.mostrarToast('success', 'Se actualizó Cuenta', 'Se actualizaron correctamente los datos COPS de la cuenta.');
						//$A.get('e.force:refreshView').fire();

					} else if (responseGuardar.getState() === 'ERROR') {
						let errors = guardar.getError();
						if (errors) {
							let mensajeError = '';
							errors.forEach(error => mensajeError += error.message + '\n');
							helper.mostrarToast('error', 'No se pudo actualizar Cuenta', mensajeError);
						}
					}
				});
				$A.enqueueAction(guardar);
			} else if (component.get('v.clienteAccount')) {
				let guardar = component.get('c.guardar');
				guardar.setParams({
					'recordId': component.get('v.recordId'),
					'cartera': component.find('OS_Cartera__c').get('v.value'),
					'premium': component.find('OS_Premium__c').get('v.checked'),
					'holabank': component.find('CBK_HolaBank__c') ? component.find('CBK_HolaBank__c').get('v.checked') : false,
					'acuse': component.find('SEG_No_enviar_Acuse_Recibo__pc') ? component.find('SEG_No_enviar_Acuse_Recibo__pc').get('v.checked') : false
				});

				guardar.setCallback(this, responseGuardar => {
					if (responseGuardar.getState() === 'SUCCESS') {
						helper.mostrarToast('success', 'Se actualizó Cuenta', 'Se actualizaron correctamente los datos COPS de la cuenta.');
						//$A.get('e.force:refreshView').fire();

					} else if (responseGuardar.getState() === 'ERROR') {
						let errors = guardar.getError();
						if (errors) {
							let mensajeError = '';
							errors.forEach(error => mensajeError += error.message + '\n');
							helper.mostrarToast('error', 'No se pudo actualizar Cuenta', mensajeError);
						}
					}
				});
				$A.enqueueAction(guardar);
			} else {
				let guardar = component.get('c.guardar');
				guardar.setParams({
					'recordId': component.get('v.recordId'),
					'cartera': component.find('OS_Cartera__c').get('v.value'),
					'premium': component.find('OS_Premium__c').get('v.checked'),
					'holabank': component.find('CBK_HolaBank__c') ? component.find('CBK_HolaBank__c').get('v.checked') : false,
					'centroManipulador': component.find('OS_Centro_Manipulador__c').get('v.value')
					//'centroManipulador': component.find('OS_Centro_Manipulador__c') ? component.find('OS_Centro_Manipulador__c').get('v.value') : null
				});

				guardar.setCallback(this, responseGuardar => {
					if (responseGuardar.getState() === 'SUCCESS') {
						helper.mostrarToast('success', 'Se actualizó Cuenta', 'Se actualizaron correctamente los datos COPS de la cuenta.');
						//$A.get('e.force:refreshView').fire();

					} else if (responseGuardar.getState() === 'ERROR') {
						let errors = guardar.getError();
						if (errors) {
							let mensajeError = '';
							errors.forEach(error => mensajeError += error.message + '\n');
							helper.mostrarToast('error', 'No se pudo actualizar Cuenta', mensajeError);
						}
					}
				});
				$A.enqueueAction(guardar);
			}
		}
		//Si es objeto contacto
		else {
			let guardar = component.get('c.guardarContact');

			guardar.setParams({
				'recordId': component.get('v.recordId'),
				'acuse': component.find('SEG_No_enviar_Acuse_Recibo__c') ? component.find('SEG_No_enviar_Acuse_Recibo__c').get('v.checked') : false
			});

			guardar.setCallback(this, responseGuardar => {

				if (responseGuardar.getState() === 'SUCCESS') {
					helper.mostrarToast('success', 'Se actualizó Cuenta', 'Se actualizó correctamente el datos COPS del contacto.');
					//$A.get('e.force:refreshView').fire();

				} else if (responseGuardar.getState() === 'ERROR') {
					let errors = guardar.getError();
					if (errors) {
						let mensajeError = '';
						errors.forEach(error => mensajeError += error.message + '\n');
						helper.mostrarToast('error', 'No se pudo actualizar Contacto', mensajeError);
					}
				}
			});
			$A.enqueueAction(guardar);
		}

	}
});