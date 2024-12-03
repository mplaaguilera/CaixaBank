({
	llamadaUpdated: function(component, event, helper) {
		if (event.getParams().changeType === 'ERROR') {
			helper.mostrarToast('error', 'Problema recuperando datos de la llamada', component.get('v.errorLds'));
		}
	},

	handleClickAceptar: function(component, event, helper) {
		let inputAsunto = component.find('asunto');
		inputAsunto.reportValidity();

		if (inputAsunto.get('v.value')) {
			if (!component.get('v.llamada.CC_Cuenta__c') && !component.get('v.llamada.CC_No_Identificado__c')) {
				helper.mostrarToast('info', 'Llamada no identificada', 'Debes identificar previamente al cliente o marcar la llamada como "No se identifica"');
			} else if (component.get('v.llamada.CC_Fecha_Fin__c') && !component.get('v.llamada.HDT_Desborde__c')) {
				helper.mostrarToast('info', 'Llamada finalizada', 'No se permite crear un caso desde una llamada finalizada');
			} else {
				component.set('v.spinner', true);
				let devolverMensaje = component.get('c.devolverMensaje');
				devolverMensaje.setParam('recordId', component.get('v.recordId'));
				devolverMensaje.setCallback(this, responseDevolverMensaje => {
					if (responseDevolverMensaje.getState() === 'SUCCESS') {
						if (responseDevolverMensaje.getReturnValue() != null) {
							let retorno = responseDevolverMensaje.getReturnValue();
							let toastEvent = $A.get('e.force:showToast');
							toastEvent.setParams({
								duration: 5000, type: 'info',
								title: 'Ya existe un caso para esta llamada', message: 'Mensaje',
								messageTemplate: 'No es posible crear un caso nuevo, ya hay uno abierto para esta llamada (caso {1})',
								messageTemplateData: ['Salesforce', {url: retorno.getMensaje, label: retorno.getCaso.CaseNumber}]
							});
							toastEvent.fire();
							component.set('v.spinner', false);
						} else {
							let crearCasoLlamada = component.get('c.crearCasoLlamada');
							crearCasoLlamada.setParams({recordId: component.get('v.recordId'), asunto: inputAsunto.get('v.value')});
							crearCasoLlamada.setCallback(this, responseCrearCasoLlamada => {
								if (responseCrearCasoLlamada.getState() === 'SUCCESS') {
									let caso = responseCrearCasoLlamada.getReturnValue();

									let casoCreadoEvento = $A.get('e.c:CC_Llamada_Caso_Creado_Event');
									casoCreadoEvento.setParam('caso', caso);
									casoCreadoEvento.fire();

									helper.mostrarToast('success', 'Se creó Caso', 'Se creó correctamente el caso ' + caso.CaseNumber);

									helper.openSubtabCaso(component, caso.Id);
									component.find('asunto').set('v.value', '');
									component.set('v.spinner', false);
								} else if (responseCrearCasoLlamada.getState() === 'ERROR') {
									let errores = responseCrearCasoLlamada.getError();
									console.error(JSON.stringify(errores));
									helper.mostrarToast('error', 'Problema creando caso', errores[0].message);
									component.set('v.spinner', false);
								}
							});
							$A.enqueueAction(crearCasoLlamada);
						}
					}
				});
				$A.enqueueAction(devolverMensaje);
			}
		}
	},

	asuntoTeclaPulsada: function(component, event) {
		if (event.which === 13) { //Tecla Intro
			$A.enqueueAction(component.get('c.handleClickAceptar'));
			//eslint-disable-next-line @lwc/lwc/no-async-operation
			window.setTimeout($A.getCallback(() => component.find('botonCrearCaso').focus()), 0);
		}
	}
});