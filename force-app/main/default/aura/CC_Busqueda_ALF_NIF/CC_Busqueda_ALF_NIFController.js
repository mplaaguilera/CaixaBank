({
	doInit: function(component) {
		if (component.get('v.sObjectName') === 'Opportunity') {
			component.set('v.identificacionPrevia', false); //No aplica para oportunidades
		} else {
			let recordType;
			let cliente;
			let contacto;
			let datosRegistro = component.get('c.datosRegistro');
			datosRegistro.setParam('recordId', component.get('v.recordId'));
			/*
			datosRegistro.setParams({
				sObjectName: component.get('v.sObjectName'),
				recordId: component.get('v.recordId')
			});
			*/
			datosRegistro.setCallback(this, responseDatosRegistro => {
				if (responseDatosRegistro.getState() === 'SUCCESS') {
					let registro = responseDatosRegistro.getReturnValue();

					if (component.get('v.sObjectName') === 'CC_Llamada__c') {
						component.set('v.identificacionPrevia', registro.CC_No_Identificado__c);
						component.set('v.llamadaFinalizada', Boolean(registro.CC_Fecha_Fin__c));

					} else if (component.get('v.sObjectName') === 'Case') {
						component.set('v.identificacionPrevia', registro.AccountId && registro.ContactId || registro.CC_No_Identificado__c);
						component.set('v.llamadaFinalizada', false); //Este motivo no aplica para casos
						recordType =  registro.RecordType.DeveloperName ? registro.RecordType.DeveloperName : '';
						cliente = registro.AccountId ?  registro.AccountId : '';
						contacto = registro.Contact && registro.Contact.RecordType && registro.Contact.RecordType.DeveloperName ? registro.Contact.RecordType.DeveloperName : '';
					}

					/*
					} else if (component.get('v.sObjectName') === 'Opportunity') {
						component.set('v.identificacionPrevia', false); //Este motivo no aplica para oportunidades
						component.set('v.llamadaFinalizada', false); //Este motivo no aplica para oportunidades
					}
					*/
					if (component.get('v.sObjectName') === 'Case' && recordType === 'CC_Cliente' && (cliente !== null && cliente !== '')) {
						if (!registro.CC_Representante__c && contacto !== 'CIBE_Apoderado') {
							let getRepresentantesOrContactosCliente;
							getRepresentantesOrContactosCliente = component.get('c.getRepresentantesOrContactosCliente');
							getRepresentantesOrContactosCliente.setParam('sCliente', cliente);
							getRepresentantesOrContactosCliente.setCallback(this, response => {
								if (response.getState() === 'SUCCESS') {
									let retorno = response.getReturnValue();
									if (retorno !== null) {
										//if (retorno[0].representante != undefined) {
										//Son representantes
										component.set('v.oRepresentantes', retorno);
										component.set('v.sTipoPersona', retorno[0].tipoPersonaCliente);
										if (retorno[0].tipoPersonaCliente === 'F') {
											component.set('v.bMostrarRepresentantesPersonaFisica', true);
											component.set('v.bMostrarRepresentantesPersonaJuridica', false);
										} else if (retorno[0].tipoPersonaCliente === 'J') {
											component.set('v.bMostrarRepresentantesPersonaJuridica', true);
											component.set('v.bMostrarRepresentantesPersonaFisica', false);
										}
										//}
									}
								} else {
									//Mostrar error
									component.set('v.bError', true);
									component.set('v.sMensErr', 'Se ha producido un error al actualizar el registro (consulta contactos/representantes).');
								}
								$A.get('e.force:refreshView').fire();
							});
							$A.enqueueAction(getRepresentantesOrContactosCliente);
						}
					}
				}
			});
			$A.enqueueAction(datosRegistro);
		}
	},

	recordUpdated: function(component, event) {
		if (event.getParams().changeType === 'CHANGED') {
			if (component.get('v.sObjectName') === 'Opportunity') {
				component.find('oppData').reloadRecord();
			} else {
				$A.enqueueAction(component.get('c.doInit'));
			}
		} else if (event.getParams().changeType === 'ERROR') {
			console.error(component.get('v.errorLds'));
		}
	},

	buscarAlfabetico: function(component, event, helper) {
		if (component.get('v.sObjectName') === 'CC_Llamada__c' && component.get('v.llamadaFinalizada')) {
			helper.mostrarToast('error', 'Operativa no disponible', 'No se permite identificar manualmente porque la llamada está finalizada.');
		} else {
			//Gestión visual secciones
			//component.set('v.bEsperaALF', true);
			component.set('v.bRes', false);
			component.set('v.bMostrarContactos', false);
			component.set('v.bMostrarRepresentantesPersonaFisica', false);
			component.set('v.bMostrarRepresentantesPersonaJuridica', false);
			component.set('v.bError', false);
			component.set('v.bInfo', false);

			const getEsPropietarioCaso = component.get('c.getEsPropietarioCaso');
			getEsPropietarioCaso.setParam('recordId', component.get('v.recordId'));
			getEsPropietarioCaso.setCallback(this, response => {
				if (response.getState() === 'SUCCESS') {
					const esPropietario = response.getReturnValue();
					if (esPropietario) {
						component.set('v.bEsperaALF', true);
						let getIdentidad = component.get('c.getIdentidad');
						getIdentidad.setParams({
							'tipoBusqueda': component.find('tipoBusqueda').get('v.value'),
							'valorBusqueda': component.get('v.sBusqueda').trim()
						});
						getIdentidad.setCallback(this, responseGetIdentidad => {
							if (responseGetIdentidad.getState() === 'SUCCESS') {
								let oMap = responseGetIdentidad.getReturnValue();
								if (oMap !== null) {
									if (oMap.CUENTAS.length > 0) {
										component.set('v.bRes', true);
										component.set('v.oCuentas', oMap.CUENTAS);
									} else {
										//Mostrar mensaje sin resultados
										component.set('v.bInfo', true);
										component.set('v.sMensInfo', 'No se ha identificado ningún cliente.');
									}
								} else {
									//Mostrar mensaje sin resultados
									component.set('v.bInfo', true);
									component.set('v.sMensInfo', 'No se ha identificado ningún cliente.');
								}
								$A.get('e.force:refreshView').fire();
							} else {
								//Mostrar error
								component.set('v.bError', true);
								component.set('v.sMensErr', 'Se ha producido un error al realizar la consulta.');
							}
							component.set('v.bEsperaALF', false);
						});
						$A.enqueueAction(getIdentidad);
					} else {
						//component.set('v.bEsperaALF', false);
						component.set('v.bError', true);
						component.set('v.sMensErr', 'Debe ser propietario del registro para iniciar la identificación.');
					}
				} else {
					//Mostrar error
					component.set('v.bError', true);
					component.set('v.sMensErr', 'Se ha producido un error al realizar la consulta.');
				}
			});
			$A.enqueueAction(getEsPropietarioCaso);
		}
	},

	navegarOrigen: function(component, event) {
		let sObectEvent = $A.get('e.force:navigateToSObject');
		sObectEvent.setParam('recordId', event.srcElement.name);
		sObectEvent.fire();
	},

	asociarSoloAcc: function(component, event, helper) {
		//Gestión visual secciones
		component.set('v.bEsperaSFDC', true);
		component.set('v.bRes', false);
		component.set('v.bMostrarContactos', false);
		component.set('v.bMostrarRepresentantesPersonaFisica', false);
		component.set('v.bMostrarRepresentantesPersonaJuridica', false);
		component.set('v.bError', false);
		component.set('v.bInfo', false);

		let sCuenta = event.getSource().get('v.name');
		let sTipoRegistro = component.get('v.sObjectName');
		if (sTipoRegistro === 'Case') {
			let setClienteCaso = component.get('c.setClienteCaso');
			setClienteCaso.setParams({
				sID: sCuenta,
				sTipo: 'Cuenta',
				sCasoId: component.get('v.recordId')
			});
			setClienteCaso.setCallback(this, response => {
				component.set('v.bEsperaSFDC', false);
				if (response.getState() === 'SUCCESS') {
					let sRetorno = response.getReturnValue();
					if (sRetorno !== null) {
						if (sRetorno !== '') {
							//Error detectado
							component.set('v.bError', true);
							component.set('v.sMensErr', sRetorno);
						} else {
							//Cuenta vinculada
							helper.mostrarToast('success', 'Se asoció correctamente la cuenta al caso', 'Se asoció correctamente la cuenta al caso.');
							let actualizarIdentificacion = component.get('c.actualizarIdentificacion');
							actualizarIdentificacion.setParams({
								recordId: component.get('v.recordId'),
								noIdentificado: false,
								tipoRegistro: sTipoRegistro,
								sCliente: sCuenta
							});
							actualizarIdentificacion.setCallback(this, responseActualizarIdentificacion => {
								if (responseActualizarIdentificacion.getState() === 'SUCCESS') {
									component.set('v.identificacionPrevia', true);
									component.set('v.sBusqueda', '');
									let oRetorno = responseActualizarIdentificacion.getReturnValue();
									if (oRetorno) {
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
												getContactoAsoc.setParam('sCuenta', sCuenta);
												getContactoAsoc.setCallback(this, responseGetContactoAsoc => {
													if (responseGetContactoAsoc.getState() === 'SUCCESS') {
														if (responseGetContactoAsoc.getReturnValue()) {
															component.set('v.contactoId', responseGetContactoAsoc.getReturnValue());
															helper.openSubtabContacto(component, false);
														}
													}
												});
												$A.enqueueAction(getContactoAsoc);
											}
										}
									}
								} else {
									//Mostrar error
									component.set('v.bError', true);
									component.set('v.sMensErr', 'Se ha producido un error al actualizar el registro (consulta contactos/representantes).');
								}
							});
							$A.enqueueAction(actualizarIdentificacion);
						}
					}
				} else {
					//Mostrar error
					component.set('v.bError', true);
					component.set('v.sMensErr', 'Se ha producido un error al actualizar el caso.');
				}
				$A.get('e.force:refreshView').fire();
			});
			$A.enqueueAction(setClienteCaso);

		} else if (sTipoRegistro === 'CC_Llamada__c') {
			let sLlamada = component.get('v.recordId');
			let setClienteLlamada = component.get('c.setClienteLlamada');
			setClienteLlamada.setParams({
				sID: sCuenta,
				sTipo: 'Cuenta',
				sLlamadaId: sLlamada
			});
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
							//Cuenta vinculada
							helper.mostrarToast('success', 'Se asoció correctamente la cuenta a la llamada', 'Se asoció correctamente la cuenta a la llamada.');
							component.set('v.cuentaId', sCuenta);
							let actualizarIdentificacion = component.get('c.actualizarIdentificacion');
							actualizarIdentificacion.setParams({
								recordId: component.get('v.recordId'),
								noIdentificado: false,
								tipoRegistro: sTipoRegistro,
								sCliente: sCuenta
							});
							actualizarIdentificacion.setCallback(this, responseActualizarIdentificacion => {
								if (responseActualizarIdentificacion.getState() === 'SUCCESS') {
									component.set('v.identificacionPrevia', true);
									component.set('v.sBusqueda', '');
									let oRetorno = responseActualizarIdentificacion.getReturnValue();
									if (oRetorno) {
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
												getContactoAsoc.setParam('sCuenta', sCuenta);
												getContactoAsoc.setCallback(this, responseGetContactoAsoc => {
													if (responseGetContactoAsoc.getState() === 'SUCCESS') {
														if (responseGetContactoAsoc.getReturnValue() !== null) {
															component.set('v.contactoId', responseGetContactoAsoc.getReturnValue());
															helper.openSubtabContacto(component, false);
														}
													}
												});
												$A.enqueueAction(getContactoAsoc);
											}
										}
									}

								}
							});
							$A.enqueueAction(actualizarIdentificacion);
							helper.openSubtabCuenta(component, false);
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
			setClienteOpportunity.setParams({
				sID: sCuenta,
				sTipo: 'Cuenta',
				recordId: component.get('v.recordId')
			});
			setClienteOpportunity.setCallback(this, response => {
				component.set('v.bEsperaSFDC', false);
				if (response.getState() === 'SUCCESS') { //Vincular OK
					//Cuenta vinculada
					helper.mostrarToast('success', 'Se asoció correctamente la cuenta a la oportunidad', 'Se asoció correctamente la cuenta ' + response.getReturnValue() + ' a la oportunidad.');
					$A.get('e.force:refreshView').fire();

				} else if (response.getState() === 'ERROR') { //Vincular KO
					component.set('v.bError', true);
					component.set('v.sMensErr', 'Se ha producido un error al actualizar la oportunidad: ' + setClienteOpportunity.getError()[0].message);
				}
			});
			$A.enqueueAction(setClienteOpportunity);
		}

		/*let getRepresentantesOrContactosCliente;
		if (sTipoRegistro === 'CC_Llamada__c' || sTipoRegistro === 'Case') {
		//getRepresentantesOrContactosCliente = component.get('c.getContactosCliente');
		getRepresentantesOrContactosCliente = component.get('c.getRepresentantesOrContactosCliente');
		getRepresentantesOrContactosCliente.setParam('sCliente', sCuenta);
		getRepresentantesOrContactosCliente.setCallback(this, response => {
			if (response.getState() === 'SUCCESS') {
		let oRetorno = response.getReturnValue();
		if (oRetorno !== null) {
		console.log('oRetorno1: '+oRetorno[0].tipoPersonaCliente);
		console.log('bMostrarRepresentantesPersonaFisica0: '+component.get('v.bMostrarRepresentantesPersonaFisica'));
		if (oRetorno[0].representante != undefined) {
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
		getContactoAsoc.setParam('sCuenta', sCuenta);
		getContactoAsoc.setCallback(this, responseGetContactoAsoc => {
			if (responseGetContactoAsoc.getState() === 'SUCCESS') {
		let sRetorno = responseGetContactoAsoc.getReturnValue();
		if (sRetorno !== null) {
		component.set('v.contactoId', sRetorno);
		helper.openSubtabContacto(component, false);
		}
		}
		});
		$A.enqueueAction(getContactoAsoc);
		}
		}
		console.log('bMostrarRepresentantesPersonaFisica2: '+component.get('v.bMostrarRepresentantesPersonaFisica'));

		}
		} else {
		//Mostrar error
		component.set('v.bError', true);
		component.set('v.sMensErr', 'Se ha producido un error al actualizar el registro (consulta contactos/representantes).');
		}
		$A.get('e.force:refreshView').fire();
		});
		$A.enqueueAction(getRepresentantesOrContactosCliente);
		}*/
	},

	asociarAcc: function(component, event, helper) {
		let sCuenta = event.getSource().get('v.name');
		component.set('v.bEsperaSFDC', true);
		let sTipoRegistro = component.get('v.sObjectName');
		if (sTipoRegistro === 'Case') {
			let setClienteCaso = component.get('c.setClienteCaso');
			setClienteCaso.setParams({
				sID: sCuenta,
				sTipo: 'Cuenta',
				sCasoId: component.get('v.recordId')
			});
			setClienteCaso.setCallback(this, response => {
				component.set('v.bEsperaSFDC', false);
				component.set('v.bError', false);
				if (response.getState() === 'SUCCESS') {
					let sRetorno = response.getReturnValue();
					if (sRetorno !== null && sRetorno !== '') {
						//Error detectado
						component.set('v.bError', true);
						component.set('v.sMensErr', sRetorno);
					}
				} else {
					//Mostrar error
					component.set('v.bError', true);
					component.set('v.sMensErr', 'Se ha producido un error al actualizar el caso.');
				}
				$A.get('e.force:refreshView').fire();
			});
			$A.enqueueAction(setClienteCaso);

		} else if (sTipoRegistro === 'CC_Llamada__c') {
			let setClienteLlamada = component.get('c.setClienteLlamada');
			setClienteLlamada.setParams({
				sID: sCuenta,
				sTipo: 'Cuenta',
				sLlamadaId: component.get('v.recordId')
			});
			setClienteLlamada.setCallback(this, response => {
				component.set('v.bEsperaSFDC', false);
				component.set('v.bError', false);
				if (response.getState() === 'SUCCESS') {
					let sRetorno = response.getReturnValue();
					if (sRetorno !== null) {
						if (sRetorno !== '') {
							//Error detectado.
							component.set('v.bError', true);
							component.set('v.sMensErr', sRetorno);
						}
						component.set('v.cuentaId', sCuenta);
						helper.openSubtabCuenta(component, false);
					}
				} else {
					//Mostrar error
					component.set('v.bError', true);
					component.set('v.sMensErr', 'Se ha producido un error al realizar la actualización de la llamada.');
				}
				$A.get('e.force:refreshView').fire();
			});
			$A.enqueueAction(setClienteLlamada);
		}
	},

	asociarRepresentante: function(component, event, helper) {

		let sRepresentanteId = event.getSource().get('v.name');
		component.set('v.bEsperaSFDC', true);
		component.set('v.bRes', false);
		component.set('v.bMostrarRepresentantesPersonaFisica', false);
		component.set('v.bMostrarRepresentantesPersonaJuridica', false);
		component.set('v.bMostrarContactos', false);
		component.set('v.bError', false);
		component.set('v.bInfo', false);

		let sTipoRegistro = component.get('v.sObjectName');

		if (sTipoRegistro === 'Case') {
			let setClienteCaso = component.get('c.setClienteCaso');
			setClienteCaso.setParams({
				sID: sRepresentanteId,
				sTipo: 'Representante',
				sCasoId: component.get('v.recordId')
			});
			setClienteCaso.setCallback(this, response => {
				component.set('v.bEsperaSFDC', false);
				if (response.getState() === 'SUCCESS') {
					let sRetorno = response.getReturnValue();
					if (sRetorno !== null) {
						if (sRetorno !== '') {
							//Error detectado
							component.set('v.bError', true);
							component.set('v.sMensErr', sRetorno);
						} else {
							//Representante vinculado
							helper.mostrarToast('success', 'Se asoció correctamente el representante al caso', 'Se asoció correctamente el representante al caso.');
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
			$A.enqueueAction(setClienteCaso);

		} else if (sTipoRegistro === 'CC_Llamada__c') { //Representante en la llamada
			let setClienteLlamada = component.get('c.setClienteLlamada');
			setClienteLlamada.setParams({
				sID: sRepresentanteId,
				sTipo: 'Representante',
				sLlamadaId: component.get('v.recordId')
			});
			setClienteLlamada.setCallback(this, response => {
				component.set('v.bEsperaSFDC', false);
				component.set('v.bError', false);
				if (response.getState() === 'SUCCESS') {
					let sRetorno = response.getReturnValue();
					if (sRetorno !== null) {
						if (sRetorno !== '') { //Error detectado
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

	asociarContacto: function(component, event, helper) {
		let sContactoId = event.getSource().get('v.name');
		component.set('v.bEsperaSFDC', true);
		component.set('v.bRes', false);
		component.set('v.bMostrarRepresentantesPersonaFisica', false);
		component.set('v.bMostrarRepresentantesPersonaJuridica', false);
		component.set('v.bMostrarContactos', false);
		component.set('v.bError', false);
		component.set('v.bInfo', false);

		const sTipoRegistro = component.get('v.sObjectName');
		if (sTipoRegistro === 'Case') {
			let setClienteCaso = component.get('c.setClienteCaso');
			setClienteCaso.setParams({
				sID: sContactoId,
				sTipo: 'Contacto',
				sCasoId: component.get('v.recordId')
			});
			setClienteCaso.setCallback(this, response => {
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
							helper.mostrarToast('success', 'Se asoció correctamente el contacto al registro', 'Se asoció correctamente el contacto al registro.');
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
			$A.enqueueAction(setClienteCaso);

		} else if (sTipoRegistro === 'CC_Llamada__c') {
			let setClienteLlamada = component.get('c.setClienteLlamada');
			setClienteLlamada.setParams({
				sID: sContactoId,
				sTipo: 'Contacto',
				sLlamadaId: component.get('v.recordId')
			});
			setClienteLlamada.setCallback(this, response => {
				component.set('v.bEsperaSFDC', false);
				if (response.getState() === 'SUCCESS') {
					let sRetorno = response.getReturnValue();
					if (sRetorno !== null) {
						if (sRetorno !== '') {
							//Error detectado.
							component.set('v.bError', true);
							component.set('v.sMensErr', sRetorno);
						} else {
							//Contacto vinculado.
							helper.mostrarToast('success', 'Se asoció correctamente el contacto seleccionado a la llamada', 'Se asoció correctamente el contacto seleccionado a la llamada.');
							component.set('v.contactoId', sContactoId);
							component.set('v.sBusqueda', '');
							helper.openSubtabContacto(component, false);
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
			setClienteOpportunity.setParams({
				sID: sContactoId,
				sTipo: 'Contacto',
				recordId: component.get('v.recordId')
			});
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
							helper.mostrarToast('success', 'Se asoció correctamente el contacto a la oportunidad', 'Se asoció correctamente el contacto a la oportunidad.');
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

	volverACuentas: function(component) {
		component.set('v.bEsperaSFDC', false);
		component.set('v.bRes', true);
		component.set('v.bMostrarContactos', false);
		component.set('v.bMostrarRepresentantesPersonaFisica', false);
		component.set('v.bMostrarRepresentantesPersonaJuridica', false);
		component.set('v.bError', false);
		component.set('v.bInfo', false);
		$A.get('e.force:refreshView').fire();
	},

	valorBusquedaTeclaPulsada: function(component, event) {
		if (event.which === 13) { //Intro
			$A.enqueueAction(component.get('c.buscarAlfabetico'));
		}
	},

	handleActualizarIdentificacion: function(component, event, helper) {
		component.set('v.bEsperaSFDC', true);
		let actualizarIdentificacion = component.get('c.actualizarIdentificacion');
		actualizarIdentificacion.setParams({
			recordId: component.get('v.recordId'),
			noIdentificado: true,
			tipoRegistro: component.get('v.sObjectName'),
			sCliente: null
		});
		actualizarIdentificacion.setCallback(this, response => {
			if (response.getState() === 'SUCCESS') {
				component.set('v.identificacionPrevia', true);
				const mensajeToast = 'El cliente ' + (component.get('v.sObjectName') === 'Case' ? 'del caso' : 'de la llamada') + ' no se ha identificado.';
				helper.mostrarToast('info', 'Cliente no se ha identificado', mensajeToast);
			}
			$A.get('e.force:refreshView').fire();
			component.set('v.bEsperaSFDC', false);
		});
		$A.enqueueAction(actualizarIdentificacion);
	},

	handleChange: function(component) {
		component.set('v.sBusqueda', component.get('v.sBusqueda').toUpperCase());

		component.set('v.bInfo', false);
		component.set('v.bError', false);
		if (!component.get('v.sBusqueda')) {
			component.set('v.bRes', false);
			component.set('v.bMostrarContactos', false);
			component.set('v.bMostrarRepresentantesPersonaFisica', false);
			component.set('v.bMostrarRepresentantesPersonaJuridica', false);
		}
	},

	handleActualizarIdentificacionCliente: function(component, event, helper) {
		component.find('oppData').reloadRecord(true, $A.getCallback(() => {
			const noSeIdentificaNew = !component.get('v.oportunidad.CSBD_No_Identificado__c');
			component.set('v.oportunidad.CSBD_No_Identificado__c', noSeIdentificaNew);
			component.set('v.oportunidad.AccountId', null);
			component.set('v.oportunidad.CSBD_Contact__c', null);

			component.find('oppData').saveRecord($A.getCallback(saveResult => {
				if (saveResult.state === 'SUCCESS') {
					const title = component.get('v.sObjectName') === 'Opportunity' ? 'Se actualizó la oportunidad' : 'Se actualizó el caso';
					const message = noSeIdentificaNew ? 'Marca "Cliente no se identifica" guardada correctamente' : 'Marca "Cliente no se identifica" desmarcada correctamente';
					helper.mostrarToast('success', title, message);
				} else if (saveResult.state === 'ERROR') {
					const title = component.get('v.sObjectName') === 'Opportunity' ? 'Problema actualizando la oportunidad' : 'Problema actualizando el caso';
					helper.mostrarToast('error', title, saveResult.getError()[0].message);
				}
			}));
		}));
	},

	menuNoSeIdentificaOnSelect: function(component, event) {
		if (event.getParam('value') === 'Opportunity') {
			$A.enqueueAction(component.get('c.handleActualizarIdentificacionCliente'));
		} else {
			$A.enqueueAction(component.get('c.handleActualizarIdentificacion'));
		}
	},

	csbdMessageChannelOnmessage: function(component, message) {
		const {recordId, type} = message.getParams();
		if (recordId === component.get('v.recordId')) {
			if (type === 'identificarFocus') {
				const inputBusqueda = component.find('valorBusqueda');
				window.addEventListener('scrollend', () => inputBusqueda.focus(), {once: true});
				inputBusqueda.getElement().scrollIntoView({block: 'center', behavior: 'smooth'});
			}
		}
	}
});