({

	doInit: function(component, event, helper) {
		component.set('v.cssStyle', '<style>.cuf-scroller-outside {background: rgb(255, 255, 255) !important;}</style>');
		component.set('v.columnasOTPCliente', [{
			label: 'Acciones', type: 'button', typeAttributes: {
				label: {fieldName: 'nombreBoton'},
				name: {fieldName: 'nombreBoton'},
				title: {fieldName: 'nombreBoton'},
				//disabled: { fieldName: "isActive"},
				value: {fieldName: 'nombreBoton'},
				iconPosition: 'left'
			}
		},
		{label: 'Estado', fieldName: 'estado', type: 'text', sortable: false, initialWidth: 50},
		{label: 'Nivel', fieldName: 'nivel', type: 'text', sortable: false, initialWidth: 40},
		{
			label: 'Fecha envío', fieldName: 'fechaEnvio', type: 'date', sortable: true, typeAttributes: {
				year: 'numeric',
				month: 'numeric',
				day: '2-digit',
				hour: '2-digit',
				minute: '2-digit'
			}
		},
		{
			label: 'Fecha validación', fieldName: 'fechaValidacion', type: 'date', sortable: true, typeAttributes: {
				year: 'numeric',
				month: 'numeric',
				day: '2-digit',
				hour: '2-digit',
				minute: '2-digit'
			}
		},
		{label: 'Caso', fieldName: 'numeroCaso', type: 'text', sortable: false},

		{label: 'Intentos', fieldName: 'intentosValidacion', type: 'number', initialWidth: 70},

		{label: 'Código OTPSMS', fieldName: 'codigoOTP'},
		{label: 'Resultado validación', fieldName: 'resultado'},
		{label: 'Mensaje de error', fieldName: 'codigoError'}]);

		component.set('v.columnasOTPHistoricoCliente', [
			{label: 'Caso', fieldName: 'numeroCaso', type: 'text', sortable: false},
			{label: 'Estado', fieldName: 'estado', type: 'text', sortable: false},
			{label: 'Nivel', fieldName: 'nivel', type: 'text', sortable: false},
			{
				label: 'Fecha de envío', fieldName: 'fechaEnvio', type: 'date', sortable: true, typeAttributes: {
					year: 'numeric',
					month: 'numeric',
					day: '2-digit',
					hour: '2-digit',
					minute: '2-digit'
				}
			},
			{
				label: 'Fecha de validación', fieldName: 'fechaValidacion', type: 'date', sortable: true, typeAttributes: {
					year: 'numeric',
					month: 'numeric',
					day: '2-digit',
					hour: '2-digit',
					minute: '2-digit'
				}
			},
			{label: 'Intentos validación', fieldName: 'intentosValidacion', type: 'number', sortable: false},
			{label: 'Código OTPSMS', fieldName: 'codigoOTP', sortable: false},
			{label: 'Resultado de validación', fieldName: 'resultado', sortable: false},
			{label: 'Mensaje de error', fieldName: 'codigoError', sortable: false}
		]);
		helper.existeOTPCasoHelper(component, event, helper);
	},

	//Boton Nivel 2
	segundoNivelAut: function(component, event, helper) {
		component.set('v.nivelSeleccionado', event.getSource().getLocalId());
		component.set('v.disabledBotones', true);
		$A.enqueueAction(component.get('c.cerrarModalValidarDos'));
		let comprobarDatos2Nivel = component.get('c.comprobarDatos2Nivel');
		comprobarDatos2Nivel.setParams({'recordId': component.get('v.recordId')});
		comprobarDatos2Nivel.setCallback(this, response => {
			if (response.getState() === 'SUCCESS') {
				let respuesta = response.getReturnValue();
				if (respuesta === 'SIN DATOS') {
					helper.recuperarMensajeToast(component, 'error', 'DATOS_VACIOS');
					component.set('v.disabledBotones', false);
				} else if (respuesta === 'CLIENTE BLOQUEADO') {
					helper.recuperarMensajeToast(component, 'error', 'CLIENTE_BLOQUEADO');
				} else if (respuesta === 'SIN LLAMADAS') {
					helper.recuperarMensajeToast(component, 'error', 'SIN_LLAMADAS');
				} else if (respuesta === 'OK') {
					helper.obtenerPreguntasAleatorias(component);

				} else {
					console.error(response.getError());
				}
			} else {
				console.error(response.getError());
			}
		});
		$A.enqueueAction(comprobarDatos2Nivel);
	},

	//Boton Emergencia
	emergenciaAut: function(component, event, helper) {
		component.set('v.nivelSeleccionado', event.getSource().getLocalId());
		helper.obtenerPreguntasEmergencia(component);
		$A.util.addClass(component.find('ModalboxPreguntas'), 'slds-fade-in-open');
		$A.util.addClass(component.find('ModalBackdropPreguntas'), 'slds-backdrop--open');

		window.setTimeout($A.getCallback(() => component.find('Validado').focus()), 0);
	},

	//Boton Cliente Digital
	clienteDigitalAut: function(component, event, helper) {
		component.set('v.disabledBotones', true);
		component.set('v.nivelSeleccionado', event.getSource().getLocalId());
		$A.enqueueAction(component.get('c.cerrarModalValidarDos'));
		if (component.get('v.idCliente') === undefined) {
			component.set('v.idCliente', datos[0].AccountId);
		}
		let validarCanalAutenticacion = component.get('c.validarCanalAutenticacion');
		validarCanalAutenticacion.setParam('recordId', component.get('v.recordId'));
		validarCanalAutenticacion.setCallback(this, responseValidarCanalAutenticacion => {
			if (responseValidarCanalAutenticacion.getState() === 'SUCCESS') {
				let canalValido = responseValidarCanalAutenticacion.getReturnValue();
				if (canalValido != null) {
					if (canalValido) {
						$A.enqueueAction(helper.enviarSegundoNivelAux(component, event));

					} else {
						this.mostrarToast('error', 'Operativa no disponible', 'Operativa no disponible para este canal de entrada o tipo de cliente del caso.');
					}

				} else {
					component.set('v.disabledBotones', false);
					this.mostrarToast('error', 'Operativa no disponible', 'Operativa no disponible para este canal de entrada o tipo de cliente del caso.');
				}
			}
		});
		$A.enqueueAction(validarCanalAutenticacion);
	},

	//Boton Enviar/Validar de nivel 2
	accionRegistroController: function(component, event, helper) {
		let id = event.getParam('row').recordId;
		let actionName = event.getParam('row').nombreBoton;
		let nivel = component.get('v.nivel');
		let enviarRegistro;
		if (actionName === 'Enviar') {
			enviarRegistro = component.get('c.enviarRegistro');
			enviarRegistro.setParams({'recordId': id});

			enviarRegistro.setCallback(this, response => {
				if (response.getState() === 'SUCCESS') {
					component.set('v.validarRegistro', true);
					component.set('v.recordIdPdteValidar', id);
					$A.enqueueAction(component.get('c.abrirModalValidarRegistro'));
				}
			});
			$A.enqueueAction(enviarRegistro);
		} else if (actionName === 'Validar') {
			component.set('v.validarRegistro', true);
			component.set('v.recordIdPdteValidar', id);
			$A.enqueueAction(component.get('c.abrirModalValidarRegistro'));
		} else if (actionName === 'Cancelar') {
			component.set('v.recordIdPdteValidar', id);
			$A.enqueueAction(component.get('c.cancelarAut'));
		}
	},

	//Abrir modal de validar
	abrirModalValidarRegistro: function(component, event, helper) {
		component.set('v.disabledBotones', true);
		if (!component.get('v.validarRegistro')) {
			component.set('v.recordIdPdteValidar', event.getParam('row').recordId);
		}

		let comprobarIntentos = component.get('c.comprobarIntentos');
		comprobarIntentos.setParams({'casoId': component.get('v.recordId'), 'idCliente': component.get('v.idCliente')});
		comprobarIntentos.setCallback(this, response => {
			if (response.getState() === 'SUCCESS') {
				if (response.getReturnValue() === 'KO') {
					helper.mostrarToast('error', 'Operativa no disponible', 'Existe un bloqueo por reintentos.');
				} else if (response.getReturnValue() === 'Cliente Bloqueado') {
					helper.recuperarMensajeToast(component, 'error', 'CLIENTE_BLOQUEADO');
				} else {
					$A.util.addClass(component.find('ModalboxValidar'), 'slds-fade-in-open');
					$A.util.addClass(component.find('ModalBackdropValidar'), 'slds-backdrop--open');

					//Damos el foco a un elemento para que desde el primer momento funcione el cierre mediante la tecla ESC
					window.setTimeout($A.getCallback(() => component.find('botonValidar').focus()), 0);
				}
			}
		});
		$A.enqueueAction(comprobarIntentos);
	},

	//Validar registro de Cliente Digital
	validarRegistroController: function(component, event, helper) {
		event.preventDefault();
		component.set('v.disabledBotonValidar', true);
		let fields = event.getParams().fields;
		let codigoOTP = fields.CC_Codigo_OTPSMS__c;
		let otpId = component.get('v.recordIdPdteValidar');
		let nivel = component.get('v.nivel');
		let validarRegistro;
		if (nivel === 'Cliente Digital') {
			validarRegistro = component.get('c.validarAutorizacion');
			validarRegistro.setParams({'recordId': otpId, 'casoId': component.get('v.recordId')});
		} else {
			validarRegistro = component.get('c.validarRegistro');
			validarRegistro.setParams({'casoId': component.get('v.recordId'), 'otpId': otpId, 'codigoOTP': codigoOTP});
		}

		validarRegistro.setCallback(this, response => {
			if (response.getState() === 'SUCCESS') {
				let resultado = response.getReturnValue();
				if (resultado === 'OK') {
					let toastEvent = $A.get('e.force:showToast');
					toastEvent.setParams({
						message: 'Se ha validado correctamente.',
						key: 'info_alt', type: 'success', mode: 'dismissible', duration: '10000'
					});
					toastEvent.fire();
					$A.enqueueAction(component.get('c.cerrarModalValidar'));
					$A.enqueueAction(component.get('c.doInit'));
				} else if (resultado === 'La autorización ha sido aprobada por el cliente' || resultado === 'La autorización ha finalizado correctamente') {
					let toastEvent = $A.get('e.force:showToast');
					toastEvent.setParams({
						message: resultado,
						key: 'info_alt', type: 'success', mode: 'dismissible', duration: '10000'
					});
					toastEvent.fire();
					$A.enqueueAction(component.get('c.cerrarModalValidar'));
					$A.enqueueAction(component.get('c.doInit'));
				} else if (resultado === 'La autorización está pendiente (pendiente cliente)' || resultado === 'La autorización está en progreso (pendiente cliente)') {
					let toastEvent = $A.get('e.force:showToast');
					toastEvent.setParams({
						message: 'La autenticación está en progreso',
						key: 'info_alt', type: 'warning', mode: 'dismissible', duration: '10000'
					});
					toastEvent.fire();
					component.set('v.disabledBotonValidar', false);
				} else {
					component.set('v.nuevoIntento', true);
					let toastEvent = $A.get('e.force:showToast');
					if (nivel === 'Cliente Digital') {
						toastEvent.setParams({
							message: resultado,
							key: 'info_alt', type: 'error', mode: 'dismissible', duration: '10000'
						});
					} else {
						toastEvent.setParams({
							title: 'Error: ' + resultado, message: 'Se he producido un error en la validación.',
							key: 'info_alt', type: 'error', mode: 'dismissible', duration: '10000'
						});
					}

					toastEvent.fire();
					component.set('v.disabledBotonValidar', false);
					$A.enqueueAction(component.get('c.cerrarModalValidar'));
					$A.enqueueAction(component.get('c.doInit'));
				}
			} else {
				let errors = response.getError();
				let toastEvent = $A.get('e.force:showToast');
				if (nivel === 'Cliente Digital') {
					toastEvent.setParams({
						title: resultado, message: 'Se he producido un error en la validación.',
						key: 'info_alt', type: 'error', mode: 'dismissible', duration: '10000'
					});
				} else {
					toastEvent.setParams({
						title: errors, message: 'Se he producido un error en la validación.',
						key: 'info_alt', type: 'error', mode: 'dismissible', duration: '10000'
					});
				}
				toastEvent.fire();
				component.set('v.disabledBotonValidar', false);
				$A.enqueueAction(component.get('c.cerrarModalValidar'));
				$A.enqueueAction(component.get('c.doInit'));
			}
		});
		$A.enqueueAction(validarRegistro);
	},

	//Cerrar modal de preguntas Nivel 2 y Emergencia
	cerrarModalPreguntas: function(component) {
		component.set('v.valorInputPregunta1', null);
		component.set('v.valorInputPregunta2', null);
		component.set('v.noValidado', false);
		component.set('v.disabledBotonesValidar', false);
		component.set('v.disabledBotones', false);

		$A.util.removeClass(component.find('ModalboxPreguntas'), 'slds-fade-in-open');
		$A.util.removeClass(component.find('ModalBackdropPreguntas'), 'slds-backdrop--open');
		//$A.enqueueAction(component.get("c.doInit"));
	},

	//Icono de cruz
	cerrarModalValidar: function(component) {
		$A.util.removeClass(component.find('ModalboxValidar'), 'slds-fade-in-open');
		$A.util.removeClass(component.find('ModalBackdropValidar'), 'slds-backdrop--open');
	},

	cerrarModalValidarDos: function(component) {
		$A.util.removeClass(component.find('ModalboxValidarIntento'), 'slds-fade-in-open');
		$A.util.removeClass(component.find('ModalBackdropValidarDos'), 'slds-backdrop--open');
		component.set('v.nuevoIntento', false);
	},


	//Boton Validado de modal de Autenticacion de Emergencia
	enviarSegunNivel: function(component, event, helper) {
		component.set('v.disabledBotones', true);
		//let canalValido = false;
		let validarCanalAutenticacion = component.get('c.validarCanalAutenticacion');
		validarCanalAutenticacion.setParam('recordId', component.get('v.recordId'));
		validarCanalAutenticacion.setCallback(this, responseValidarCanalAutenticacion => {
			if (responseValidarCanalAutenticacion.getState() === 'SUCCESS') {
				let canalValido = responseValidarCanalAutenticacion.getReturnValue();
				if (canalValido != null) {
					if (canalValido) {
						$A.enqueueAction(helper.enviarSegundoNivelAux(component, event));
					} else {
						helper.mostrarToast('error', 'Operativa no disponible', 'Operativa no disponible para este canal de entrada o tipo de cliente del caso.');
					}
				}
			} else {
				component.set('v.disabledBotones', false);
				helper.mostrarToast('error', 'Operativa no disponible', 'Operativa no disponible para este canal de entrada o tipo de cliente del caso.');
			}
		});
		$A.enqueueAction(validarCanalAutenticacion);

	},

	//Boton Validar de autenticacion de Nivel 2
	enviarNivelDos: function(component, event, helper) {
		let respuestasErroneas = false;
		if (component.get('v.omitirPreguntasNvl2') === false) {
			helper.comprobarPreguntas(component, event); //Comprobamos las respuestas antes de hacer nada
			//Validacion preguntas Nivel 2
			if (component.get('v.valorInputPregunta1') == null || component.get('v.valorInputPregunta1') === '' || component.get('v.valorInputPregunta2') === null || component.get('v.valorInputPregunta2') === '') {
				helper.mostrarToast('error', 'Campos vacíos', 'Los campos no pueden estar en blanco.');
				component.set('v.disabledBotonesValidar', false);
				respuestasErroneas = true;
			} else if (component.get('v.valorInputPregunta1').length < component.get('v.minLengthPregunta1') || component.get('v.valorInputPregunta2').length < component.get('v.minLengthPregunta2')) {
				helper.mostrarToast('error', 'Valores incorrectos', 'Los campos no pueden tener longitud menor a la especificada.');
				component.set('v.disabledBotonesValidar', false);
				respuestasErroneas = true;
			} else if (component.get('v.caracteresNoPermitidos1') || component.get('v.caracteresNoPermitidos2')) {
				helper.mostrarToast('error', 'Caracteres no permitidos', 'Los campos no pueden tener caracteres no permitidos.');
				component.set('v.disabledBotonesValidar', false);
				respuestasErroneas = true;
			}
		}
		if (!respuestasErroneas) {
			let validacionPreguntas = component.get('c.validacionPreguntas');
			validacionPreguntas.setParams({
				'recordId': component.get('v.recordId'),
				'pregunta1': component.get('v.labelPregunta1'),
				'pregunta2': component.get('v.labelPregunta2'),
				'respuesta1': component.get('v.valorInputPregunta1'),
				'respuesta2': component.get('v.valorInputPregunta2')
			});
			validacionPreguntas.setCallback(this, function(response) {
				if (response.getState() === 'SUCCESS') {
					let resultado = validacionPreguntas.getReturnValue();
					component.set('v.validacionPregunta1', resultado[0]);
					component.set('v.validacionPregunta2', resultado[1]);
					component.set('v.OmitirSMSNvl2', resultado[2]);

					if ((component.get('v.validacionPregunta1') === false || component.get('v.validacionPregunta2') === false) && component.get('v.omitirPreguntasNvl2') === false) {
						helper.generarComunicacionNivelDos(component, event, helper).then(() => {
							helper.recuperarMensajeToast(component, 'error', 'NOK');
						}).catch(error => {
							console.error('Error en validacionesBasicas:', error);
						});
					} else {
						if (component.get('v.omitirPreguntasNvl2') === false) {
							helper.recuperarMensajeToast(component, 'success', 'OK');
						}
						let validarCanalAutenticacion = component.get('c.validarCanalAutenticacion');
						validarCanalAutenticacion.setParam('recordId', component.get('v.recordId'));
						validarCanalAutenticacion.setCallback(this, function(response) {
							if (response.getState() === 'SUCCESS') {
								let canalValido = response.getReturnValue();
								if (canalValido != null) {
									if (canalValido) {
										helper.generarComunicacionNivelDos(component, event, helper).then(() => {
											if (component.get('v.validacionPregunta1') === true && component.get('v.validacionPregunta2') === true || component.get('v.omitirPreguntasNvl2') === 'true') {
												if (component.get('v.OmitirSMSNvl2') === false) {
													let id = component.get('v.recordIdPdteValidar');
													let enviarRegistro = component.get('c.enviarRegistro');
													enviarRegistro.setParams({'recordId': id});
													enviarRegistro.setCallback(this, response => {
														if (response.getState() === 'SUCCESS') {
															component.set('v.validarRegistro', true);
															$A.enqueueAction(component.get('c.abrirModalValidarRegistro'));
														}
													});
													$A.enqueueAction(enviarRegistro);

												} else {
													$A.enqueueAction(component.get('c.cerrarModalPreguntas'));
												}
											}
										}).catch(error => {
											console.error('Error en validacionesBasicas:', error);
										});

									} else {
										helper.mostrarToast('error', 'Operativa no disponible', 'Operativa no disponible para este canal de entrada o tipo de cliente del caso.');
									}
								}

							} else {
								component.set('v.disabledBotones', false);
								helper.mostrarToast('error', 'Operativa no disponible', 'Operativa no disponible para este canal de entrada o tipo de cliente del caso.');
							}
						});
						$A.enqueueAction(validarCanalAutenticacion);
					}
				}
			});
			$A.enqueueAction(validacionPreguntas);
		}
	},

	//Cancelar autenticación
	cancelarAut: function(component, event, helper) {
		let recordId = component.get('v.recordId');
		component.set('v.disabledBotones', false);
		let id = component.get('v.recordIdPdteValidar');
		let mensajeCancelar = component.get('c.autenticacionCancelada');
		mensajeCancelar.setParams({'recordId': id, 'casoId': recordId});
        	$A.enqueueAction(mensajeCancelar);
		$A.enqueueAction(component.get('c.doInit'));
		helper.mostrarToast('warning', '', 'Se ha cancelado la validación.');

		if (event.getSource().get('v.name') === 'cancelarModal') {
			$A.enqueueAction(component.get('c.cerrarModalValidar'));
		}
	},

	noRecibido: function(component) {
		let recordId = component.get('v.recordId');
		if (component.get('v.recordIdPdteValidar') != undefined || component.get('v.recordIdPdteValidar') != null) {
			let mensajeNoValidado = component.get('c.mensajeNoRecibido');
			mensajeNoValidado.setParams({'recordId': component.get('v.recordIdPdteValidar'), 'casoId': recordId});
			$A.enqueueAction(mensajeNoValidado);
			component.set('v.disabledBotones', false);
			$A.enqueueAction(component.get('c.cerrarModalValidar'));
			$A.enqueueAction(component.get('c.doInit'));
		}
	},

	modalPreguntasTeclaPulsada: function(component, event) {
		if (event.keyCode === 27 && !component.get('v.disabledBotonesValidar')) { //ESC
			$A.enqueueAction(component.get('c.cerrarModalPreguntas'));
		}
	},

	modalValidarTeclaPulsada: function(component, event) {
		if (event.keyCode === 27) { //ESC
			$A.enqueueAction(component.get('c.cerrarModalValidar'));
		}
	},

	enviarAutenticacionClienteDigital: function(component) {
		let enviarRegistro;
		let recupOTP = component.get('c.getOTP');
		recupOTP.setParams({'casoId': component.get('v.recordId'), 'nivel': 'Cliente Digital', 'status': 'Pdte. Envío'});
		recupOTP.setCallback(this, function(response) {
			if (response.getState() === 'SUCCESS') {
				component.set('v.recordIdPdteValidar', response.getReturnValue());
			}
			enviarRegistro = component.get('c.enviarAutorizacion');
			enviarRegistro.setParams({'recordId': component.get('v.recordIdPdteValidar'), 'casoId': component.get('v.recordId')});
			enviarRegistro.setCallback(this, response => {
				if (response.getState() === 'SUCCESS') {
					if (response.getReturnValue() === 'KO') {
						$A.enqueueAction(component.get('c.doInit'));
						let toastEvent = $A.get('e.force:showToast');
						toastEvent.setParams({
							message: 'Error en la Autenticación.',
							key: 'info_alt', type: 'Error', mode: 'dismissible', duration: '10000'
						});
						toastEvent.fire();
					} else if (response.getReturnValue() === 'NOK') {
						let toastEvent = $A.get('e.force:showToast');
						toastEvent.setParams({
							message: 'Error en la Autenticación. No hay llamadas abiertas pendientes',
							key: 'info_alt', type: 'Error', mode: 'dismissible', duration: '10000'
						});
						toastEvent.fire();
					} else {
						component.set('v.validarRegistro', true);
						component.set('v.recordIdPdteValidar', component.get('v.recordIdPdteValidar'));
						$A.enqueueAction(component.get('c.abrirModalValidarRegistro'));
					}
				}
			});
			$A.enqueueAction(enviarRegistro);
		});
		$A.enqueueAction(recupOTP);

	},

	//Refresca el componente cuando detecta que se agrego una cuenta
	handleRecordUpdated: function(component, event, helper) {
		let eventParams = event.getParams();
		if (eventParams.changeType === 'CHANGED') {
			let changedFields = eventParams.changedFields;
			let camposCambiados = JSON.stringify(changedFields);
			if (camposCambiados.includes('AccountId') && changedFields.AccountId.oldValue == null && changedFields.AccountId.value != null ||
                camposCambiados.includes('Representante')) {
				component.set('v.disabledBotones', false);
			}
			$A.enqueueAction(component.get('c.doInit'));
		}
	}

});