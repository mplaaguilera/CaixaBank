({

	openSubtabCuenta: function(component, focus) {
		let workspaceAPI = component.find('workspace');
		workspaceAPI.openSubtab({
			'parentTabId': workspaceAPI.getEnclosingTabId(),
			'url': '/lightning/r/Account/' + component.get('v.cuentaId') + '/view',
			'focus': focus
		});
	},

	openSubtabContacto: function(component, focus) {
		let workspaceAPI = component.find('workspace');
		workspaceAPI.openSubtab({
			'parentTabId': workspaceAPI.getEnclosingTabId(),
			'url': '/lightning/r/Contact/' + component.get('v.contactoId') + '/view',
			'focus': focus
		});
	},

	mostrarToast: function(tipo, titulo, mensaje) {
		let toastEvent = $A.get('e.force:showToast');
		toastEvent.setParams({'title': titulo, 'message': mensaje, 'type': tipo, 'mode': 'dismissible', 'duration': 4000});
		toastEvent.fire();
	},

	mostrarError: function(component, errors){
		if (errors) {
			component.set('v.bError', true);
			if (errors[0] && errors[0].message) {
				component.set('v.sMensErr', errors[0].message);
			}
		} else {
			component.set('v.sMensErr', 'Error desconocido.');
		}
	},

	modalCerrar : function(component, event) {      	
		component.set("v.modalSRultiplesCasos", false);
	},

	asociarRepresentante: function(component, event) {
		let sRepresentanteId = component.get("v.rastroId");
		component.set('v.bEsperaSFDC', true);
		component.set('v.bRes', false);
		component.set('v.bMostrarRepresentantesPersonaFisica', false);
		component.set('v.bMostrarRepresentantesPersonaJuridica', false);
		component.set('v.bMostrarContactos', false);
		component.set('v.bError', false);
		component.set('v.bInfo', false);

		let sTipoRegistro = component.get('v.sObjectName');
		if (sTipoRegistro === 'Case') {
			let sCaso = component.get('v.recordId');
			let action = component.get('c.setClienteCaso');
			action.setParams({'sID': sRepresentanteId, 'sTipo': 'Representante', 'sCasoId': sCaso});
			action.setCallback(this, response => {
				component.set('v.bEsperaSFDC', false);
				component.set('v.bEsperaPopUp', false);
				if (response.getState() === 'SUCCESS') {
					let sRetorno = response.getReturnValue();
					if (sRetorno !== null) {
						if (sRetorno !== '') {
							//Error detectado
							component.set('v.bError', true);
							component.set('v.sMensErr', sRetorno);
						} else {
							//Representante vinculado
							this.mostrarToast('success', 'Se asoció correctamente el representante al caso', 'Se asoció correctamente el representante al caso.');
							component.set('v.sBusqueda', '');
						}
					}
				} else {
					//Mostrar error
					component.set('v.bError', true);
					component.set('v.sMensErr', 'Se ha producido un error al actualizar el registro.');
				}
				$A.get('e.force:refreshView').fire();
			});
			$A.enqueueAction(action);
		} else if (sTipoRegistro === 'CC_Llamada__c') { //Representante en la llamada
			let sLlamada = component.get('v.recordId');
			let setClienteLlamada = component.get('c.setClienteLlamada');
			setClienteLlamada.setParams({'sID': sRepresentanteId, 'sTipo': 'Representante', 'sLlamadaId': sLlamada});
			setClienteLlamada.setCallback(this, response => {
				component.set('v.bEsperaSFDC', false);
				component.set('v.bError', false);
				if (response.getState() === 'SUCCESS') {
					let sRetorno = response.getReturnValue();
					if (sRetorno !== null) {
						if (sRetorno !== '') {
							//Error detectado
							component.set('v.bError', true);
							component.set('v.sMensErr', sRetorno);
						}
					}
				} else {
					//Mostrar error
					component.set('v.bError', true);
					component.set('v.sMensErr', 'Se ha producido un error al actualizar el registro.');
				}
				$A.get('e.force:refreshView').fire();
			});
			$A.enqueueAction(setClienteLlamada);
		}
	},

	asociarSoloAcc: function(component, event) {
		//Gestión visual secciones
		component.set('v.bEsperaSFDC', true);
		component.set('v.bRes', false);
		component.set('v.bMostrarContactos', false);
		component.set('v.bMostrarRepresentantesPersonaFisica', false);
		component.set('v.bMostrarRepresentantesPersonaJuridica', false);
		component.set('v.bError', false);
		component.set('v.bInfo', false);
		let sCuenta = component.get("v.rastroId");
		let sTipoRegistro = component.get('v.sObjectName');
		if (sTipoRegistro === 'Case') {
			let setClienteCaso = component.get('c.setClienteCaso');
			setClienteCaso.setParams({'sID': sCuenta, 'sTipo': 'Cuenta', 'sCasoId': component.get('v.recordId')});
			setClienteCaso.setCallback(this, response => {
				component.set('v.bEsperaSFDC', false);
				component.set('v.bEsperaPopUp', false);
				if (response.getState() === 'SUCCESS') {
					//Cuenta vinculada
					this.mostrarToast('success', 'Se asoció correctamente la cuenta al caso', 'Se asoció correctamente la cuenta al caso.');
					let action = component.get('c.actualizarIdentificacion');
					action.setParams({'recordId': component.get('v.recordId'), 'noIdentificado': false, 'tipoRegistro': sTipoRegistro});
					action.setCallback(this, response => {
						if (response.getState() === 'SUCCESS') {
							component.set('v.identificacionPrevia', true);
							component.set('v.sBusqueda', '');
						}
					});
					$A.enqueueAction(action);
				} else {
					var errors = response.getError();
					this.mostrarError(component, errors);
					component.set('v.bError', true);
					component.set('v.sMensErr', response.getError()[0].pageErrors[0].message);
				}
				$A.get('e.force:refreshView').fire();
			});
			$A.enqueueAction(setClienteCaso);

		}

		let getRepresentantesOrContactosCliente;
		if (sTipoRegistro === 'CC_Llamada__c' || sTipoRegistro === 'Case') {
			//getRepresentantesOrContactosCliente = component.get('c.getContactosCliente');
			getRepresentantesOrContactosCliente = component.get('c.getRepresentantesOrContactosCliente');

			getRepresentantesOrContactosCliente.setParams({'sCliente': sCuenta});
			getRepresentantesOrContactosCliente.setCallback(this, response => {
				if (response.getState() === 'SUCCESS') {
					let oRetorno = response.getReturnValue();
					if (oRetorno !== null) {
						if (oRetorno[0].representante) {
							//Son representantes
							component.set('v.oRepresentantes', oRetorno);
							component.set('v.sTipoPersona', oRetorno[0].tipoPersonaCliente);
							if (oRetorno[0].tipoPersonaCliente === 'F') {
								component.set('v.bMostrarRepresentantesPersonaFisica', true);
								component.set('v.bMostrarRepresentantesPersonaJuridica', false);
							} else if (oRetorno[0].tipoPersonaCliente === 'J') {
								component.set('v.bMostrarRepresentantesPersonaJuridica', true);
								component.set('v.bMostrarRepresentantesPersonaFisica', false);
							}
						} else {
							//Son contactos
							if (oRetorno.length > 1) {
								//Hay más de un contacto
								component.set('v.oContactos', oRetorno);
								component.set('v.bMostrarContactos', true);
							} else if (oRetorno.length === 1) {
								let getContactoAsoc = component.get('c.getContactoAsoc');
								getContactoAsoc.setParams({'sCuenta': sCuenta});
								getContactoAsoc.setCallback(this, response => {
									if (response.getState() === 'SUCCESS') {
										let sRetorno = response.getReturnValue();
										if (sRetorno !== null) {
											component.set('v.contactoId', sRetorno);
											this.openSubtabContacto(component, false);
										}
									}
								});
								$A.enqueueAction(getContactoAsoc);
							}
						}
					}
					component.set('v.bEsperaSFDC', false);
				} else {
					//Mostrar error
					component.set('v.bError', true);
					component.set('v.sMensErr', 'Se ha producido un error al actualizar el registro (consulta contactos/representantes).');
				}
				$A.get('e.force:refreshView').fire();
			});
			$A.enqueueAction(getRepresentantesOrContactosCliente);
		}
	},

	asociarContacto: function(component, event) {
		let sContactoId = component.get("v.rastroId");
		component.set('v.bEsperaSFDC', true);
		component.set('v.bRes', false);
		component.set('v.bMostrarRepresentantesPersonaFisica', false);
		component.set('v.bMostrarRepresentantesPersonaJuridica', false);
		component.set('v.bMostrarContactos', false);
		component.set('v.bError', false);
		component.set('v.bInfo', false);

		let sTipoRegistro = component.get('v.sObjectName');
		if (sTipoRegistro === 'Case') {
			let sCaso = component.get('v.recordId');
			let action = component.get('c.setClienteCaso');
			action.setParams({'sID': sContactoId, 'sTipo': 'Contacto', 'sCasoId': sCaso});
			action.setCallback(this, response => {
				component.set('v.bEsperaSFDC', false);
				component.set('v.bEsperaPopUp', false);
				if (response.getState() === 'SUCCESS') {
					let sRetorno = response.getReturnValue();
					if (sRetorno !== null) {
						if (sRetorno !== '') {
							//Error detectado
							component.set('v.bError', true);
							component.set('v.sMensErr', sRetorno);
						} else {
							//Contacto vinculado
							this.mostrarToast('success', 'Se asoció correctamente el contacto al registro', 'Se asoció correctamente el contacto al registro.');
							component.set('v.sBusqueda', '');
						}
					}
				} else {
					//Mostrar error
					component.set('v.bError', true);
					component.set('v.sMensErr', 'Se ha producido un error al actualizar el registro.');
				}
				$A.get('e.force:refreshView').fire();
			});
			$A.enqueueAction(action);

		} else if (sTipoRegistro === 'CC_Llamada__c') {
			let sLlamada = component.get('v.recordId');
			let setClienteLlamada = component.get('c.setClienteLlamada');
			setClienteLlamada.setParams({'sID': sContactoId, 'sTipo': 'Contacto', 'sLlamadaId': sLlamada});
			setClienteLlamada.setCallback(this, response => {
				component.set('v.bEsperaSFDC', false);
				if (response.getState() === 'SUCCESS') {
					let sRetorno = response.getReturnValue();
					if (sRetorno !== null) {
						if (sRetorno !== '') {
							//Error detectado
							component.set('v.bError', true);
							component.set('v.sMensErr', sRetorno);
						} else {
							//Contacto vinculado
							this.mostrarToast('success', 'Se asoció correctamente el contacto seleccionado a la llamada', 'Se asoció correctamente el contacto seleccionado a la llamada.');
							component.set('v.contactoId', sContactoId);
							component.set('v.sBusqueda', '');
							this.openSubtabContacto(component, false);
						}
					}
				} else {
					//Mostrar error
					component.set('v.bError', true);
					component.set('v.sMensErr', 'Se ha producido un error al realizar la actualización de la llamada.');
				}
				$A.get('e.force:refreshView').fire();
			});
			$A.enqueueAction(setClienteLlamada);

		} else if (sTipoRegistro === 'Opportunity') {
			let setClienteOpportunity = component.get('c.setClienteOpportunity');
			setClienteOpportunity.setParams({'sID': sContactoId, 'sTipo': 'Contacto', 'recordId': component.get('v.recordId')});
			setClienteOpportunity.setCallback(this, response => {
				component.set('v.bEsperaSFDC', false);
				if (response.getState() === 'SUCCESS') {
					let sRetorno = response.getReturnValue();
					if (sRetorno !== null) {
						if (sRetorno !== '') {
							//Error detectado
							component.set('v.bError', true);
							component.set('v.sMensErr', sRetorno);
						} else {
							//Contacto vinculado
							this.mostrarToast('success', 'Se asoció correctamente el contacto a la oportunidad', 'Se asoció correctamente el contacto a la oportunidad.');
							component.set('v.sBusqueda', '');
						}
					}
				} else {
					//Mostrar error
					component.set('v.bError', true);
					component.set('v.sMensErr', 'Se ha producido un error al actualizar el registro.');
				}
				$A.get('e.force:refreshView').fire();
			});
			$A.enqueueAction(setClienteOpportunity);
		}
	},

	insertarPermisos: function(component, event) {

		let sCuenta = event.getParams().response.id;
		//var payload = ;
		let insertarPermisos = component.get("c.insertarPermisosAccount");
		insertarPermisos.setParams({'cuenta': sCuenta});
		insertarPermisos.setCallback(this, function(response) {
			if(response.getState()==="SUCCESS"){
				component.set('v.cuentaId',sCuenta);
			}
		})
		$A.enqueueAction(insertarPermisos);
	},

	getRepresentantesOcontactos: function(component, event) {

		if(component.get('v.showContacts')===false){
			component.set('v.bRes',false);
		}
		let sCuenta = event.getParams().response.id;
		let getRepresentantesOrContactosCliente = component.get('c.getRepresentantesOrContactosCliente');
		getRepresentantesOrContactosCliente.setParam('sCliente', sCuenta);
		getRepresentantesOrContactosCliente.setCallback(this, response => {
			if (response.getState() === 'SUCCESS') {
				let oRetorno = response.getReturnValue();
				if (oRetorno !== null) {
					if (oRetorno[0].representante !== undefined && oRetorno[0].representante !== false ) {
						//Son representantes
						component.set('v.oRepresentantes', oRetorno);
						component.set('v.sTipoPersona', oRetorno[0].tipoPersonaCliente);
						if (oRetorno[0].tipoPersonaCliente === 'F') {
							component.set('v.bMostrarRepresentantesPersonaFisica', true);
							component.set('v.bMostrarRepresentantesPersonaJuridica', false);
						} else if (oRetorno[0].tipoPersonaCliente === 'J') {
							component.set('v.bMostrarRepresentantesPersonaJuridica', true);
							component.set('v.bMostrarRepresentantesPersonaFisica', false);
						}
					} else {
						//Son contactos
						if (oRetorno.length > 1) {
							//Hay más de un contacto
							component.set('v.oContactos', oRetorno);
							component.set('v.bMostrarContactos', true);
						} else if (oRetorno.length === 1) {
							component.set('v.contactoId',oRetorno[0].idContacto);
							component.set('v.oContactos', oRetorno);
							component.set('v.bMostrarContactos', true);
						}
					}
				}
			} else {
				//Mostrar error
				component.set('v.bError', true);
				component.set('v.sMensErr', 'Se ha producido un error al actualizar el registro (consulta contactos/representantes).');
			}
		   // $A.get('e.force:refreshView').fire();
		    component.set('v.esperaInsertNoCliente', false);
		});
		$A.enqueueAction(getRepresentantesOrContactosCliente);
	}
});