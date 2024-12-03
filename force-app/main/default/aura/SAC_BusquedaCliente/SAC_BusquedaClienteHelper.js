({
	helpInit: function(component){
		let datosRegistro = component.get('c.datosRegistro');
		datosRegistro.setParams({'recordId': component.get('v.recordId')});
		datosRegistro.setCallback(this, response => {
			if (response.getState() === 'SUCCESS') {
				let registro = response.getReturnValue();
				if (component.get('v.sObjectName') === 'CC_Llamada__c') {
					//Llamada
					component.set('v.identificacionPrevia', registro.CC_No_Identificado__c);
					component.set('v.llamadaFinalizada', Boolean(registro.CC_Fecha_Fin__c));
				} else if (component.get('v.sObjectName') === 'Case') {
					//Caso
					component.set('v.identificacionPrevia', registro.AccountId); //&& registro.ContactId);// || registro.CC_No_Identificado__c);
					component.set('v.clienteNoIdentificado', registro.CC_No_Identificado__c);
					component.set('v.llamadaFinalizada', false); //Este motivo no aplica para casos
					component.set('v.sacTipoDeCaso', registro.RecordType.DeveloperName);
					component.set('v.origenConsulta', registro.SAC_OrigenConsulta__c);
					component.set('v.SAC_casoRelacionado', registro.SAC_CasoRelacionado__c);
					
					let getRecType = component.get('c.getRecTypeCliente');
					getRecType.setCallback(this, response => {
						if (response.getState() === 'SUCCESS') {
							component.set('v.recordTypeNoCliente', response.getReturnValue());	
						}
					})
					$A.enqueueAction(getRecType);
				} else if (component.get('v.sObjectName') === 'Opportunity') {
					component.set('v.identificacionPrevia', false); //Este motivo no aplica para oportunidades
					component.set('v.llamadaFinalizada', false); //Este motivo no aplica para oportunidades
				}
			}
		});
		$A.enqueueAction(datosRegistro);
	},

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
		component.set('v.bEsperaSFDC', false);
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
					this.passDataToLWCsac_Reclamantes(component);
				} else {
					//Mostrar error
					component.set('v.bError', true);
					component.set('v.sMensErr', 'Se ha producido un error al actualizar el registro.');
				}
				$A.get('e.force:refreshView').fire();
			});
			$A.enqueueAction(action);
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

		let getRepresentantesOrContactosCliente;
		if (sTipoRegistro === 'Case') {
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
								let setClienteCaso = component.get('c.setClienteCaso');
								setClienteCaso.setParams({'sID': sCuenta, 'sTipo': 'Cuenta', 'sCasoId': component.get('v.recordId')});
								setClienteCaso.setCallback(this, response => {
									component.set('v.bEsperaSFDC', false);
									component.set('v.bEsperaPopUp', false);
									if (response.getState() === 'SUCCESS') {
										//Cuenta vinculada
										this.mostrarToast('success', 'Se asoció correctamente la cuenta al caso', 'Se asoció correctamente la cuenta al caso.');
										let action = component.get('c.actualizarIdentificacion');
										this.passDataToLWCsac_Reclamantes(component);
										action.setParams({'recordId': component.get('v.recordId'), 'noIdentificado': false, 'tipoRegistro': sTipoRegistro});
										action.setCallback(this, response => {
											if (response.getState() === 'SUCCESS') {
												component.set('v.identificacionPrevia', true);
												component.set('v.sBusqueda', '');
												this.passDataToLWCsac_Reclamantes(component);
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
							else{
								let setClienteCaso = component.get('c.setClienteCaso');
								setClienteCaso.setParams({'sID': sCuenta, 'sTipo': 'Cuenta', 'sCasoId': component.get('v.recordId')});
								setClienteCaso.setCallback(this, response => {
									component.set('v.bEsperaSFDC', false);
									component.set('v.bEsperaPopUp', false);
									if (response.getState() === 'SUCCESS') {
										//Cuenta vinculada
										this.mostrarToast('success', 'Se asoció correctamente la cuenta al caso', 'Se asoció correctamente la cuenta al caso.');
										let action = component.get('c.actualizarIdentificacion');
										this.passDataToLWCsac_Reclamantes(component);
										action.setParams({'recordId': component.get('v.recordId'), 'noIdentificado': false, 'tipoRegistro': sTipoRegistro});
										action.setCallback(this, response => {
											if (response.getState() === 'SUCCESS') {
												component.set('v.identificacionPrevia', true);
												component.set('v.sBusqueda', '');
												this.passDataToLWCsac_Reclamantes(component);
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
						}
						component.set('v.bEsperaSFDC', false);
						component.set('v.bEsperaPopUp', false);
					}else{
						//Mostrar error
						component.set('v.bError', true);
						component.set('v.sMensErr', 'Se ha producido un error al actualizar el registro (consulta contactos/representantes).');
						component.set('v.bEsperaSFDC', false);
						component.set('v.bEsperaPopUp', false);
					}					
				} else {
					//Mostrar error
					component.set('v.bError', true);
					component.set('v.sMensErr', 'Se ha producido un error al actualizar el registro (consulta contactos/representantes).');
					component.set('v.bEsperaSFDC', false);
					component.set('v.bEsperaPopUp', false);
				}
				component.set('v.bEsperaSFDC', false);
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
					this.passDataToLWCsac_Reclamantes(component);
				} else {
					//Mostrar error
					component.set('v.bError', true);
					component.set('v.sMensErr', 'Se ha producido un error al actualizar el registro.');
				}
				$A.get('e.force:refreshView').fire();
			});
			$A.enqueueAction(action);

		}
	},

	passDataToLWCsac_Reclamantes : function(component) {
		let ordenRefrescar = true;
		//We are calling the receieveData method in our Lightning Web Component here
		component.find("lwcReclamantes").receiveData(ordenRefrescar);
	},

	comprobarMultiplesReclamacionesCuenta: function(component, event, helper){

		component.set('v.bEsperaSFDC', true);
		let origen = component.get('v.origenConsulta');
		let rt = component.get('v.sacTipoDeCaso');
		let casoRelacionado = component.get('v.SAC_casoRelacionado');

		if( rt == 'SAC_Consulta'){
			if(origen === undefined){
				let toastEvent = $A.get('e.force:showToast');
				toastEvent.setParams({'title': 'Fallo al actualizar.', 'message': 'Para gestionar la consulta primero debe de indicar el origen de la misma.', 'type': 'error', 'mode': 'dismissable', 'duration': 4000});
				toastEvent.fire();
			}else{
				component.set('v.bEsperaSFDC', true);
				let accountId = event.getSource().get('v.name');
				component.set('v.rastroId', accountId);
				let action = component.get('c.comprobarMultiplesCasosCliente');
				action.setParams({'contactId': accountId, 'accountId': accountId});
				action.setCallback(this, response => {
					if (response.getState() === 'SUCCESS') {
							if (response.getReturnValue() && component.get("v.modalSRultiplesCasos") === false) {
								component.set("v.modalSRultiplesCasos", true);
							} else {
								this.asociarSoloAcc(component, event);
							}
					} else {
						//Mostrar error
						component.set('v.bError', true);
						component.set('v.sMensErr', 'Se ha producido un error al actualizar el registro.');
					}
					$A.get('e.force:refreshView').fire();
				});
				$A.enqueueAction(action);
				//helper.asociarSoloAcc(component, event);
			}
		} else if(rt == 'SAC_Reclamacion' && (casoRelacionado != null) ) {
			component.set('v.bEsperaSFDC', true);
			let accountId = event.getSource().get('v.name');
			component.set('v.rastroId', accountId);
			this.asociarSoloAcc(component, event);
		}
		else{
			component.set('v.bEsperaSFDC', true);
			let accountId = event.getSource().get('v.name');
			component.set('v.rastroId', accountId);
			let action = component.get('c.comprobarMultiplesCasosCliente');
			action.setParams({'contactId': accountId, 'accountId': accountId});
			action.setCallback(this, response => {
				if (response.getState() === 'SUCCESS') {
						if (response.getReturnValue() && component.get("v.modalSRultiplesCasos") === false) {
							component.set("v.modalSRultiplesCasos", true);
						} else {
							this.asociarSoloAcc(component, event);
						}
				} else {
					//Mostrar error
					component.set('v.bError', true);
					component.set('v.sMensErr', 'Se ha producido un error al actualizar el registro.');
				}
				$A.get('e.force:refreshView').fire();
			});
			$A.enqueueAction(action);
		}

	},

	asociarSoloAccSecundario: function(component, event, helper){

		//Gestión visual secciones
		let sCuenta = event.getSource().get('v.name');
		component.set('v.bEsperaSFDC', true);
		component.set('v.bRes', false);
		component.set('v.bError', false);
		component.set('v.bInfo', false);

		let sCaso = component.get('v.recordId');
		let action = component.get('c.crearReclamanteSecundario');
		action.setParams({'sID': sCuenta, 'sTipo': 'Cuenta', 'sCasoId': sCaso});
		action.setCallback(this, response => {
			component.set('v.bEsperaSFDC', false);
			if (response.getState() === 'SUCCESS') {
				//Contacto vinculado
				this.mostrarToast('success', 'Se asoció correctamente el reclamante secundario al registro', 'Se asoció correctamente el reclamante secundario al registro.');
				component.set('v.sBusqueda', '');
			} else {
				//Mostrar error
				var errors = response.getError();
				//helper.mostrarToast('Error', 'Error', errors[0].message);
				this.mostrarError(component, errors);
			}
			$A.get('e.force:refreshView').fire();
		});
		
		let ordenRefrescar = true;

		component.find("lwcReclamantes").receiveData(ordenRefrescar);
		$A.enqueueAction(action);
	}
});