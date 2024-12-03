({
	inicializar: function(component) {
		//Recuperar el contexto de la creación (lightning:isUrlAddressable)

		let pageRef = component.get('v.pageReference');
		let state = pageRef.state;
		let base64Context = state.inContextOfRef;
		if (base64Context.startsWith('1.')) {
			base64Context = base64Context.substring(2);
		}
		let addressableContext = JSON.parse(window.atob(base64Context));

		//Tenemos la estructura del contexto de la página.
		let objetoPadre = addressableContext.attributes.objectApiName;
		let parentId = addressableContext.attributes.recordId;


		if (objetoPadre === 'Case') {
			//Acción NEW desde el caso.
			component.set('v.caseId', parentId);
			component.set('v.hasCase', true);
		}

		//Creación de la lista de estados.
		let estados = [];
		estados.push({
			label: 'Firmado',
			value: 'Firmado'
		});
		estados.push({
			label: 'No Firmado',
			value: 'No Firmado'
		});
		estados.push({
			label: 'No reclamar',
			value: 'No reclamar'
		});
		estados.push({
			label: 'Reclamaciones Agotadas',
			value: 'Reclamaciones Agotadas'
		});

		component.set('v.estados', estados);
		component.set('v.selectedEstado', 'No Firmado');
	},

	casoUpdatedDataService: function(component, event) {
		if (event.getParams().changeType === 'LOADED' || event.getParams().changeType === 'CHANGED') {
			if (event.getParams().changeType === 'CHANGED') {
				component.find('caseData').reloadRecord();

			}

			//Asignar los valores del caso padre.
			component.set('v.accountId', component.get('v.casoPadre.AccountId'));
			component.set('v.contactId', component.get('v.casoPadre.ContactId'));
			component.set('v.accountName', component.get('v.casoPadre.Account.Name'));
			component.set('v.contactName', component.get('v.casoPadre.Contact.Name'));

		} else if (event.getParams().changeType === 'ERROR') {
			console.error(component.get('v.errorLds'));
		}
	},
	closeTab: function(component) {

		let workspaceAPI = component.find('workspace');
		workspaceAPI.getFocusedTabInfo().then(response => {
			let focusedTabId = response.tabId;
			workspaceAPI.closeTab({tabId: focusedTabId});
		})
			.catch(error => {
				console.error(error);
			});
	},

	nuevaSR: function(component) {
		component.set('v.abrirSR', true);
	},

	crearCasoSeguimiento: function(component) {
		let toastCasoCreado = $A.get('e.force:showToast');
		let hasCase = component.get('v.hasCase');
		let crId = component.get('v.crId');
		let numeroOps = component.get('v.numeroOps');
		let estado = component.get('v.selectedEstado');
		let descripcion = component.get('v.descripcion');
		let accountId = component.get('v.accountId');
		let contactId = component.get('v.contactId');
		let FechaRecepcion = component.get('v.FechaRecepcion');
		let FechaContrato = component.get('v.FechaContrato');
		let contractId = component.get('v.contractId');
		let casoId;
		let exitoSR = true;

		//Validar datos de entrada obligatorios.
		if (contractId.length <= 0) {
			toastCasoCreado.setParams({
				'title': 'No se ha podido generar el contrato',
				'message': 'No se ha informado el número de contrato',
				'type': 'warning'
			});
			toastCasoCreado.fire();
			return;
		}

		if (accountId.length <= 0) {
			toastCasoCreado.setParams({
				'title': 'No se ha podido generar el contrato',
				'message': 'No se ha identificado el cliente',
				'type': 'warning'
			});
			toastCasoCreado.fire();
			return;
		}

		if (!hasCase && crId.length <= 0) {
			toastCasoCreado.setParams({
				'title': 'No se ha podido generar el contrato',
				'message': 'No se ha informado una clasificación rápida',
				'type': 'warning'
			});
			toastCasoCreado.fire();
			return;
		}

		//Inicializar el spinner.
		component.set('v.Spinner', true);

		if (!hasCase) {
			///// CREAR CASO
			let crearSR = component.get('c.crearSR');
			crearSR.setParams({
				'crId': crId,
				'numeroOps': numeroOps,
				'accountId': accountId,
				'contactId': contactId
			});
			crearSR.setCallback(this, function(response) {
				if (response.getState() === 'SUCCESS') {

					casoId = response.getReturnValue();
				} else {
					console.error('Error crearSR. ' + JSON.stringify(response.getError()));

					let errorCrerSr = 'Se ha producido un error en la creación del contrato (1). Detalle: ' + JSON.stringify(response.getError());
					errorCrerSr = errorCrerSr.replace(/[\\[\]{}]/g, '');

					exitoSR = false;
					component.set('v.Spinner', false);
					toastCasoCreado.setParams({
						'mode': 'sticky',
						'title': 'No se ha podido generar el contrato',
						'message': errorCrerSr,
						'type': 'error'
					});

					toastCasoCreado.fire();
				}

				if (exitoSR) {
					//// CREAR CONTRATO
					let crearContrato = component.get('c.crearContrato');
					crearContrato.setParams({
						'descripcion': descripcion,
						'FechaRecepcion': FechaRecepcion,
						'FechaContrato': FechaContrato,
						'contractId': contractId,
						'casoId': casoId,
						'estado': estado
					});
					crearContrato.setCallback(this, responseCrearContrato => {
						if (responseCrearContrato.getState() === 'SUCCESS') {
							component.set('v.Spinner', false);
							toastCasoCreado.setParams({
								'title': '¡Éxito!',
								'message': 'Se ha creado el contrato',
								'type': 'success'
							});
							toastCasoCreado.fire();

							let contratoGeneradoId = responseCrearContrato.getReturnValue();

							//Abrir pestaña nueva y cerrar pestaña actual.
							let workspaceAPI = component.find('workspace');

							//Debe hacerse en este orden según issue W-5711798
							//https://success.salesforce.com/issues_view?id=a1p3A000000BMOgQAO&

							workspaceAPI.getFocusedTabInfo().then(r => {
								workspaceAPI.openTab({'recordId': contratoGeneradoId, 'focus': true})
									.then(() => workspaceAPI.closeTab({tabId: r.tabId}));
							});
						} else {
							component.set('v.Spinner', false);

							console.error('Error crearContrato. ' + JSON.stringify(responseCrearContrato.getError()));

							let errors = responseCrearContrato.getError();
							let message = 'Unknown error';
							if (errors && Array.isArray(errors) && errors.length > 0) {
								message = errors[0].message;
							}
							if (message === 'No hay reclamaciones') {
								toastCasoCreado.setParams({
									'mode': 'sticky',
									'title': 'No se ha podido generar el contrato',
									'message': 'No podemos crear un contrato ya que la CR del caso no es de contratos y no tiene asociada plazos de reclamación',
									'type': 'error'
								});
							} else {
								let mensajeError = 'Se ha producido un error en la creación del contrato (2). Detalle: ' + JSON.stringify(responseCrearContrato.getError());
								mensajeError = mensajeError.replace(/[\\[\]{}]/g, '');

								toastCasoCreado.setParams({
									'mode': 'sticky',
									'title': 'No se ha podido generar el contrato',
									'message': mensajeError,
									'type': 'error'
								});
							}
							toastCasoCreado.fire();
						}
					});
					$A.enqueueAction(crearContrato);
				}
			});
			$A.enqueueAction(crearSR);
		}

		if (hasCase) {
			casoId = component.get('v.caseId');
			//// CREAR CONTRATO
			let crearContrato = component.get('c.crearContrato');
			crearContrato.setParams({
				'descripcion': descripcion,
				'FechaRecepcion': FechaRecepcion,
				'FechaContrato': FechaContrato,
				'contractId': contractId,
				'casoId': casoId,
				'estado': estado
			});
			crearContrato.setCallback(this, response => {
				if (response.getState() === 'SUCCESS') {
					component.set('v.Spinner', false);
					toastCasoCreado.setParams({
						'title': '¡Éxito!',
						'message': 'Se ha creado el contrato',
						'type': 'success'
					});

					toastCasoCreado.fire();

					let contratoGeneradoId = response.getReturnValue();

					let workspaceAPI = component.find('workspace');
					workspaceAPI.getFocusedTabInfo().then(tabResponse => {
						let closeTabId = tabResponse.tabId;
						let parentTabId = tabResponse.parentTabId;
						let isSubtab = tabResponse.isSubtab;
						if (isSubtab) {
							workspaceAPI.openSubtab({
								parentTabId: parentTabId,
								pageReference: {
									'type': 'standard__recordPage',
									'attributes': {
										'recordId': contratoGeneradoId,
										'actionName': 'view'
									},
									'state': {
										'c__name': contractId
									}
								}
							}).then(() => {
								workspaceAPI.closeTab({
									tabId: closeTabId
								}).catch(error => {
									console.error(error);
								});
							})
								.catch(error => {
									console.error(error);
								});
						}
					});
				} else {
					component.set('v.Spinner', false);

					console.error('Error crearContrato (CaseId). ' + JSON.stringify(response.getError()));

					let errors = response.getError();
					let message = 'Unknown error';
					if (errors && Array.isArray(errors) && errors.length > 0) {
						message = errors[0].message;
					}
					if (message === 'No hay reclamaciones') {
						toastCasoCreado.setParams({
							'mode': 'sticky',
							'title': 'No se ha podido generar el contrato',
							'message': 'No podemos crear un contrato ya que la CR del caso no es de contratos y no tiene asociada plazos de reclamación',
							'type': 'error'
						});
					} else {
						let errorAura = 'Se ha producido un error en la creación del contrato (3). Detalle: ' + JSON.stringify(response.getError());
						errorAura = errorAura.replace(/[\\[\]{}]/g, '');

						toastCasoCreado.setParams({
							'mode': 'sticky',
							'title': 'No se ha podido generar el contrato',
							'message': errorAura,
							'type': 'error'
						});
					}

					toastCasoCreado.fire();
				}
			});
			$A.enqueueAction(crearContrato);
		}
		component.set('v.descripcion', '');
		component.set('v.accountId', '');
		component.set('v.contactId', '');
		component.set('v.FechaRecepcion', '');
		component.set('v.FechaContrato', '');
		component.set('v.contractId', '');
	},
	getAccounts: function(component) {

		component.set('v.searchAvailable', false);
		component.set('v.contactName', '');
		component.set('v.contactId', '');

		//search anytime the term changes
		let searchKey = component.find('accName').get('v.value');
		//to improve performance, particularly for fast typers,
		//we wait a small delay to check when user is done typing
		let delayMillis = 500;
		//get timeout id of pending search action
		let timeoutId = component.get('v.searchTimeoutId');
		//cancel pending search action and reset timer
		clearTimeout(timeoutId);
		//delay doing search until user stops typing
		//this improves client-side and server-side performance
		timeoutId = setTimeout($A.getCallback(function() {
			let action = component.get('c.buscadorAccounts');
			action.setParams({'searchKey': searchKey});
			action.setCallback(this, response => {
				let values = [];
				let result = response.getReturnValue();
				for (let key in result) {
					if (Object.prototype.hasOwnProperty.call(result, key)) {
						values.push({
							label: result[key].Name,
							value: key
						});
					}
				}
				if (values[0] != null) {
					component.set('v.mostrarAccounts', true);
					component.set('v.accounts', values);

				} else {
					component.set('v.mostrarAccounts', false);
				}
			});
			$A.enqueueAction(action);
		}), delayMillis);

		component.set('v.searchTimeoutId', timeoutId);

	},
	seleccionarCuenta: function(component, event) {

		let selectedItem = event.currentTarget.name;
		let selectedId = event.target.id;
		component.set('v.accountName', selectedItem);
		component.set('v.accountId', selectedId);
		component.set('v.mostrarAccounts', false);
		component.set('v.searchAvailable', true);

	},
	getClientes: function(component) {
		let searchKey = component.find('conName').get('v.value');
		let relatedAccount = component.get('v.accountId');
		let delayMillis = 500;
		let timeoutId = component.get('v.searchTimeoutId');
		clearTimeout(timeoutId);
		timeoutId = setTimeout($A.getCallback(function() {
			let action = component.get('c.buscadorContacts');
			action.setParams({'searchKey': searchKey, 'relatedAccount': relatedAccount});
			action.setCallback(this, response => {
				let values = [];
				let result = response.getReturnValue();
				for (let key in result) {
					if (Object.prototype.hasOwnProperty.call(result, key)) {
						values.push({
							label: result[key].Name,
							value: key
						});
					}
				}
				if (values[0] != null) {
					component.set('v.mostrarContacts', true);
					component.set('v.contacts', values);

				} else {
					component.set('v.mostrarContacts', false);
				}
			});
			$A.enqueueAction(action);
		}), delayMillis);

		component.set('v.searchTimeoutId', timeoutId);
	},
	seleccionarContacto: function(component, event) {
		let selectedItem = event.currentTarget.name;
		let selectedId = event.target.id;
		component.set('v.contactName', selectedItem);
		component.set('v.contactId', selectedId);
		component.set('v.mostrarContacts', false);

	},

	getCR: function(component) {
		let searchKey = component.find('cRapidaName').get('v.value');
		clearTimeout(component.get('v.searchTimeoutId'));
		if (searchKey.length > 1) {
			component.find('cRapidaName').set('v.isLoading', true);
			component.set('v.searchTimeoutId', setTimeout($A.getCallback(function() {
				let action = component.get('c.buscadorCR');
				action.setParams({'searchKey': searchKey});
				action.setCallback(this, response => {
					let values = [];
					let result = response.getReturnValue();
					for (let key in result) {
						if (Object.prototype.hasOwnProperty.call(result, key)) {
							values.push({
								label: result[key].Name,
								value: key
							});
						}
					}
					if (values[0] != null) {
						component.set('v.mostrarCR', true);
						component.set('v.CRs', values);
					} else {
						component.set('v.mostrarCR', false);
					}
					component.find('cRapidaName').set('v.isLoading', false);
				});
				$A.enqueueAction(action);
			}), 500));
		}
	},

	seleccionarCR: function(component, event) {
		let selectedItem = event.currentTarget.name;
		console.log('LOG:  - selectedItem', selectedItem);
		let selectedId = event.currentTarget.id;
		console.log('LOG:  - selectedId', selectedId);
		component.set('v.crName', selectedItem);
		component.set('v.crId', selectedId);
		component.set('v.mostrarCR', false);

	},
	abrirModalBusqueda:	function(component) {
		$A.util.addClass(component.find('backdrop'), 'slds-fade-in-open');
		$A.util.addClass(component.find('modalBuscador'), 'slds-fade-in-open');
		window.setTimeout($A.getCallback(() => component.find('modalBuscadorBotonCancelar').focus()), 200);
	},
	cerrarModalBusqueda: function(component) {
		$A.util.removeClass(component.find('backdrop'), 'slds-fade-in-open');
		$A.util.removeClass(component.find('modalBuscador'), 'slds-fade-in-open');
	},
	modalTeclaPulsada: function(component, event) {
		if (event.keyCode === 27) { //Tecla ESC
			$A.util.removeClass(component.find('modalBuscador'), 'slds-fade-in-open');
			$A.util.removeClass(component.find('backdrop'), 'slds-fade-in-open');
		}
	}
});