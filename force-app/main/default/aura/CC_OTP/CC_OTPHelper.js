({
	//Validaciones basicas.
	existeOTPCasoHelper: function(component, event, helper) {
		this.recuperarDatosBasicos(component, event, helper).then(() => {
			let recuperarMensajes;
			let mostrarError = true;
			if (component.get('v.llamadas') === false) {
				recuperarMensajes = 'SIN_LLAMADAS';
			} else if (component.get('v.clienteBloqueado') === true) {
				recuperarMensajes = 'CLIENTE_BLOQUEADO';
			} else if (component.get('v.idCliente') === undefined && component.get('v.idContacto') === undefined) {
				recuperarMensajes = 'SIN_CUENTA_CONTACTO';
			} else if (component.get('v.idCliente') === undefined) {
				recuperarMensajes = 'SIN_CUENTA';
			} else if (component.get('v.representante') === false && component.get('v.clienteMenor') === true) {
				recuperarMensajes = 'CLIENTE_MENOR_SIN_REPRESENTANTE';
			} else {
				if (component.get('v.estadoAut') !== 'APPROVED' && !component.get('v.pendienteEnvio') && !component.get('v.pendienteValidar')) {
					component.set('v.mostrarError', false);
					component.set('v.disabledBotones', false);
				} else {
					component.set('v.disabledBotones', true);
				}
			}
			if (mostrarError && recuperarMensajes != null) {
				component.set('v.disabledBotones', true);
				let recuperarMensajeToast = component.get('c.mensajeValidacionPreguntas');
				recuperarMensajeToast.setParams({'validacion': recuperarMensajes});
				recuperarMensajeToast.setCallback(this, response => {
					if (response.getState() === 'SUCCESS') {
						let tituloMensaje = response.getReturnValue();
						component.set('v.titulo', tituloMensaje.Name);
						component.set('v.mensaje', tituloMensaje.CC_Valor__c);
						component.set('v.mostrarError', true);
					}
				});
				$A.enqueueAction(recuperarMensajeToast);
			} else if (component.get('v.clienteBloqueado') === false && component.get('v.nuevoIntento') === true) {
				this.lanzarNuevoIntento(component);
				component.set('v.disabledBotones', false);
			}
		}).catch(error => {
			console.error('Error en validacionesBasicas:', error);
		});
	},

	//Recuperar los datos basicos para las validaciones
	recuperarDatosBasicos: function(component, event, helper) {
		return new Promise((resolve, reject) => {
			let existeOTPCaso = component.get('c.existeBloqueoNuevo');
			existeOTPCaso.setParams({'recordId': component.get('v.recordId')});
			existeOTPCaso.setCallback(this, function(response) {
				if (response.getState() === 'SUCCESS') {
					let respuestaDatos = response.getReturnValue();
					if (respuestaDatos != null) {
						for (let key in respuestaDatos) {
							if (key === 'Llamadas') {
								component.set('v.llamadas', respuestaDatos[key]);
							} else if (key === 'Cliente Bloqueado') {
								component.set('v.clienteBloqueado', respuestaDatos[key]);
							} else if (key === 'Idioma') {
								component.set('v.idioma', respuestaDatos[key]);
							} else if (key === 'AccountId') {
								component.set('v.idCliente', respuestaDatos[key]);
							} else if (key === 'ContactId') {
								component.set('v.idContacto', respuestaDatos[key]);
							} else if (key === 'OTPIntentos') {
								component.set('v.intentos', respuestaDatos[key]);
							} else if (key === 'EstadoAut') {
								component.set('v.estadoAut', respuestaDatos[key]);
							} else if (key === 'OwnerId') {
								component.set('v.ownerId', respuestaDatos[key]);
							} else if (key === 'TipoCliente') {
								component.set('v.tipoCliente', respuestaDatos[key]);
							} else if (key === 'ClienteMenor') {
								component.set('v.clienteMenor', respuestaDatos[key]);
							} else if (key === 'Representante') {
								component.set('v.representante', respuestaDatos[key]);
							} else if (key === 'MostrarBotonEmergencia') {
								component.set('v.mostrarBotonEmergencia', respuestaDatos[key]);
							}
						}
						let obtenerOTPCliente = component.get('c.obtenerOTPCliente');
						obtenerOTPCliente.setParams({'recordId': component.get('v.recordId'), 'idCliente': component.get('v.idCliente')});
						obtenerOTPCliente.setCallback(this, function(response) {
							if (response.getState() === 'SUCCESS') {
								let result = response.getReturnValue();
								if (result && result.length > 0) {
									let estado = result[0].estado;
									component.set('v.otpCliente', result);
									component.set('v.nivel', result[0].nivel);
									if (estado === 'Pdte. Envío') {
										component.set('v.recordIdPdteEnvio', result[0].idOTP);
										component.set('v.pendienteEnvio', true);
										component.set('v.pendienteValidar', false);
									} else if (estado === 'Pdte. Validar') {
										component.set('v.recordIdPdteValidar', result[0].idOTP);
										component.set('v.pendienteEnvio', false);
										component.set('v.pendienteValidar', true);
									} else {
										component.set('v.pendienteEnvio', false);
										component.set('v.pendienteValidar', false);
									}
								} else {
									component.set('v.pendienteEnvio', false);
									component.set('v.pendienteValidar', false);
									component.set('v.otpCliente', null);
								}
							}
							let obtenerHistoricoOTPCliente = component.get('c.obtenerHistoricoOTPCliente');
							obtenerHistoricoOTPCliente.setParams({'recordId': component.get('v.recordId'), 'idCliente': component.get('v.idCliente')});
							obtenerHistoricoOTPCliente.setCallback(this, response => {
								if (response.getState() === 'SUCCESS') {
									component.set('v.historicoOtpCliente', response.getReturnValue());
									resolve();
								} else if (response.getState() === 'ERROR') {
									console.error(response.getError());
									reject(response.getError());
								}
							});
							$A.enqueueAction(obtenerHistoricoOTPCliente);

						});
						$A.enqueueAction(obtenerOTPCliente);
					} else {
						resolve();
					}

				} else if (response.getState() === 'ERROR') {
					console.error(response.getError());
					reject(response.getError());
				}
			});
			$A.enqueueAction(existeOTPCaso);
		});
	},

	//Si quedan intentos para validar, le damos la opcion al agente de volver a lanzar alguna autenticacion
	lanzarNuevoIntento: function(component) {
		$A.util.addClass(component.find('ModalboxValidarIntento'), 'slds-fade-in-open');
		$A.util.addClass(component.find('ModalBackdropValidarDos'), 'slds-backdrop--open');
		let recuperarMensajeToast = component.get('c.mensajeValidacionPreguntas');
		recuperarMensajeToast.setParams({'validacion': 'VALIDAR_NUEVAMENTE'});
		recuperarMensajeToast.setCallback(this, response => {
			if (response.getState() === 'SUCCESS') {
				let tituloMensaje = response.getReturnValue();
				component.set('v.tituloNuevaValidacion', tituloMensaje.Name);
				component.set('v.mensajeNuevaValidacion', tituloMensaje.CC_Valor__c);
			}
		});
		$A.enqueueAction(recuperarMensajeToast);
	},

	//Obtener reguntas de Emergencia
	obtenerPreguntasEmergencia: function(component) {
		let preguntasOtpBasicas = component.get('c.preguntasOTP');
		preguntasOtpBasicas.setParams({'lista': 'Preguntas Básicas OTPSMS'});
		preguntasOtpBasicas.setCallback(this, response => {
			if (response.getState() === 'SUCCESS') {
				let options = [];
				let retorno = response.getReturnValue();
				retorno.forEach(option => {
					let element = {};
					element.value = String(option.Id);
					element.label = option.CC_Valor__c;
					options.push(element);
				});
				component.set('v.preguntasBasicas', options);
			} else if (response.getState() === 'ERROR') {
				console.error(response.getError());
			}
		});
		$A.enqueueAction(preguntasOtpBasicas);

		let preguntasOtpAleatorias = component.get('c.preguntasOTP');
		preguntasOtpAleatorias.setParams({'lista': 'Preguntas Aleatorias OTPSMS'});
		preguntasOtpAleatorias.setCallback(this, response => {
			if (response.getState() === 'SUCCESS') {
				let options = [];
				let retorno = response.getReturnValue();
				retorno.forEach(option => {
					let element = {};
					element.value = String(option.Id);
					element.label = option.CC_Valor__c;
					options.push(element);
				});
				component.set('v.preguntasAleatorias', options);
			} else if (response.getState() === 'ERROR') {
				console.error(response.getError());
			}
		});
		$A.enqueueAction(preguntasOtpAleatorias);

	},

	//Obtener preguntas aleatorias de segundo nivel y parametrizar tipo y maximo de caracteres
	obtenerPreguntasAleatorias: function(component) {
		let preguntasOtp2Nivel = component.get('c.preguntasOTP2Nivel');
		preguntasOtp2Nivel.setParams({'lista': 'Preguntas OTPSMS 2 Nivel', 'recordId': component.get('v.recordId')});
		preguntasOtp2Nivel.setCallback(this, function(response) {
			if (response.getState() === 'SUCCESS') {
				let retorno = response.getReturnValue();
				for (let key in retorno) {
					if (key === 'Pregunta1') {
						component.set('v.labelPregunta1', retorno[key]);
					} else if (key === 'Pregunta2') {
						component.set('v.labelPregunta2', retorno[key]);
					} else if (key === 'TextoAyudaPregunta1') {
						component.set('v.textoAyudaPregunta1', retorno[key]);
					} else if (key === 'TextoAyudaPregunta2') {
						component.set('v.textoAyudaPregunta2', retorno[key]);
					} else if (key === 'error') {
						component.set('v.datosVacios', valor);
					} else if (key === 'OmitirPreguntas') {
						component.set('v.omitirPreguntasNvl2', retorno[key]);

					}
				}
				if (component.get('v.omitirPreguntasNvl2') === false) {
					if (component.get('v.labelPregunta1') != null && (component.get('v.labelPregunta1').toLowerCase().includes('cuenta') || component.get('v.labelPregunta1').toLowerCase().includes('tarjeta') || component.get('v.labelPregunta1').toLowerCase().includes('año'))) {
						component.set('v.maxLengthPregunta1', 4);
						component.set('v.minLengthPregunta1', 4);
						component.set('v.typePregunta1', 'text');
					} else if (component.get('v.labelPregunta1') != null && component.get('v.labelPregunta1').toLowerCase().includes('edad')) {
						component.set('v.maxLengthPregunta1', 2);
						component.set('v.minLengthPregunta1', 2);
						component.set('v.typePregunta1', 'text');
					} else {
						component.set('v.maxLengthPregunta1', 255);
						component.set('v.minLengthPregunta1', 1);
						component.set('v.typePregunta1', 'text');
					}
					if (component.get('v.labelPregunta2') != null && (component.get('v.labelPregunta2').toLowerCase().includes('cuenta') || component.get('v.labelPregunta2').toLowerCase().includes('tarjeta') || component.get('v.labelPregunta2').toLowerCase().includes('año'))) {
						component.set('v.maxLengthPregunta2', 4);
						component.set('v.minLengthPregunta2', 4);
						component.set('v.typePregunta2', 'text');
					} else if (component.get('v.labelPregunta2') != null && component.get('v.labelPregunta2').toLowerCase().includes('edad')) {
						component.set('v.maxLengthPregunta2', 2);
						component.set('v.minLengthPregunta2', 2);
						component.set('v.typePregunta2', 'text');
					} else {
						component.set('v.maxLengthPregunta2', 255);
						component.set('v.minLengthPregunta2', 1);
						component.set('v.typePregunta2', 'text');
					}

					if (component.get('v.datosVacios') || component.get('v.labelPregunta1') == null || component.get('v.labelPregunta2') == null) {
						this.recuperarMensajeToast(component, 'error', 'DATOS_VACIOS');
						component.set('v.disabledBotones', false);
					} else {
						if (component.get('v.labelPregunta1') != null && component.get('v.labelPregunta2') != null) {
							$A.util.addClass(component.find('ModalboxPreguntas'), 'slds-fade-in-open');
							$A.util.addClass(component.find('ModalBackdropPreguntas'), 'slds-backdrop--open');
							window.setTimeout($A.getCallback(() => component.find('Validado').focus()), 0);
						}
					}
				} else {
					$A.enqueueAction(component.get('c.enviarNivelDos'));
				}
			} else if (response.getState() === 'ERROR') {
				console.error(response.getError());
			}
		});
		$A.enqueueAction(preguntasOtp2Nivel);

	},

	//Mostrar toast
	mostrarToast: function(tipo, titulo, mensaje) {
		let toastEvent = $A.get('e.force:showToast');
		toastEvent.setParams({title: titulo, message: mensaje, type: tipo, mode: 'dismissable', duration: '4000'});
		toastEvent.fire();
	},

	//Envia autenticacion digital/cierra la de emergencia.
	enviarSegundoNivelAux: function(component, event) {
		let recordId = component.get('v.recordId');
		let nivel = component.get('v.nivelSeleccionado');
		let idCliente = component.get('v.idCliente');
		let ownerId = component.get('v.ownerId');
		if (nivel === null || nivel === undefined) {
			nivel = event.getSource().getLocalId();
			component.set('v.nivelSeleccionado', event.getSource().getLocalId());
		}
		let nombreBoton = event.getSource().getLocalId();
		let valido = nombreBoton === 'Validado';
		if (nivel === 'Nivel 1' || nivel === 'Emergencia') {
			//Se envía un email al cliente
			let gestionesSegunNivel = component.get('c.gestionesSegunNivel');
			gestionesSegunNivel.setParams({'casoId': recordId, 'valido': valido, 'nivel': nivel});
			gestionesSegunNivel.setCallback(this, response => {
				if (response.getState() === 'SUCCESS') {
					let resultado = response.getReturnValue();
					if (resultado === 'Email' || resultado === 'OK') {
						$A.enqueueAction(component.get('c.cerrarModalPreguntas'));
					} else if (resultado === 'Email no informado') {
						helper.mostrarToast('error', 'Operativa no disponible', 'El campo "Email/Teléfono notificación" del caso no tiene el email informado del cliente.');
						$A.enqueueAction(component.get('c.cerrarModalPreguntas'));
					} else {
						component.set('v.noValidado', true);
						component.set('v.mensajeNoValidado', resultado);
						$A.enqueueAction(component.get('c.cerrarModalPreguntas'));
					}
				}
			});
			$A.enqueueAction(gestionesSegunNivel);
		} else if (nivel === 'Cliente Digital') {
			let clienteDigitalApex = component.get('c.clienteDigital');
			clienteDigitalApex.setParams({'casoId': recordId, 'idCliente': idCliente, 'ownerId': ownerId});
			clienteDigitalApex.setCallback(this, function(response) {
				component.set('v.nivel', nivel);
				if (response.getState() === 'SUCCESS') {
					let resultado = response.getReturnValue();
					if (resultado === 'OK') {
						$A.enqueueAction(component.get('c.enviarAutenticacionClienteDigital'));
						$A.enqueueAction(component.get('c.doInit'));

					} else if (resultado === 'NOK') {
						this.recuperarMensajeToast(component, 'error', 'SIN_LLAMADAS');
					} else if (resultado === 'Cliente Bloqueado') {
						this.recuperarMensajeToast(component, 'error', 'CLIENTE_BLOQUEADO');
						$A.enqueueAction(component.get('c.doInit'));
						component.set('v.disabledBotones', false);
					}
				}
			});
			$A.enqueueAction(clienteDigitalApex);
		}
	},

	//Genera comunicacion de nivel 2
	generarComunicacionNivelDos: function(component, event, helper) {
		return new Promise((resolve, reject) => {
			let valido = true;
			if (component.get('v.validacionPregunta1') === false || component.get('v.validacionPregunta2') === false) {
				valido = false;
			}
			let segundoNivelApex = component.get('c.segundoNivel');
			segundoNivelApex.setParams({
				'casoId': component.get('v.recordId'),
				'valido': valido,
				'nivel': 'Nivel 2',
				'pregunta1': component.get('v.labelPregunta1'),
				'pregunta2': component.get('v.labelPregunta2'),
				'respuesta1': component.get('v.valorInputPregunta1'),
				'respuesta2': component.get('v.valorInputPregunta2'),
				'validacion1': component.get('v.validacionPregunta1'),
				'validacion2': component.get('v.validacionPregunta2'),
				'enviarSMS': component.get('v.OmitirSMSNvl2'),
				'enviarPreguntas': component.get('v.omitirPreguntasNvl2')
			});
			segundoNivelApex.setCallback(this, response => {
				if (response.getState() === 'SUCCESS') {
					let retorno = response.getReturnValue();
					let resultado;
					for (let key in retorno) {
						if (key === 'Resultado') {
							resultado = retorno[key];
						} else if (key === 'Id') {
							component.set('v.recordIdPdteValidar', retorno[key]);
						}
					}
					if (resultado === 'OK') {
						$A.enqueueAction(component.get('c.cerrarModalPreguntas'));
					} else if (component.get('v.omitirPreguntasNvl2')) {
						$A.enqueueAction(component.get('c.cerrarModalPreguntas'));
					} else {
						component.set('v.noValidado', true);
						component.set('v.nuevoIntento', true);
						component.set('v.mensajeNoValidado', resultado);
						$A.enqueueAction(component.get('c.cerrarModalPreguntas'));
					}
					resolve();
				} else if (response.getState() === 'ERROR') {
					console.error(response.getError());
					reject(response.getError());
				}
			});
			$A.enqueueAction(segundoNivelApex);
		});
	},

	//Comprueba que las respuestas de nivel 2 no tengan caracteres no permitidos
	comprobarPreguntas: function(component, event) {
		const regexTelefono = /[a-zA-Z`!@#$%^&*()_\-=\[\]{};:\\|,.<>\/?~]/;
		const regexNumerico = /[a-zA-Z`!@#$%^&*()_\-=\[\]{};:\\|,.<>\/?~+]/;
		let tipoPregunta1 = component.get('v.typePregunta1');
		let valorPregunta1 = component.get('v.valorInputPregunta1');
		let tipoPregunta2 = component.get('v.typePregunta2');
		let valorPregunta2 = component.get('v.valorInputPregunta2');

		if (tipoPregunta1 === 'number') {
			component.set('v.caracteresNoPermitidos1', regexNumerico.test(valorPregunta1));
		} else if (component.get('v.labelPregunta1').toLowerCase().includes('teléfono')) {
			component.set('v.caracteresNoPermitidos1', regexTelefono.test(valorPregunta1));
		} else if (component.get('v.labelPregunta1').toLowerCase().includes('tarjeta') || component.get('v.labelPregunta1').toLowerCase().includes('cuenta') || component.get('v.labelPregunta2').toLowerCase().includes('cuenta') || component.get('v.labelPregunta1').toLowerCase().includes('año') || component.get('v.labelPregunta1').toLowerCase().includes('edad')) {
			component.set('v.caracteresNoPermitidos1', regexNumerico.test(valorPregunta1));
		}

		if (tipoPregunta2 === 'number') {
			component.set('v.caracteresNoPermitidos2', regexNumerico.test(valorPregunta2));
		} else if (component.get('v.labelPregunta2').toLowerCase().includes('teléfono')) {
			component.set('v.caracteresNoPermitidos2', regexTelefono.test(valorPregunta2));
		} else if (component.get('v.labelPregunta2').toLowerCase().includes('tarjeta') || component.get('v.labelPregunta2').toLowerCase().includes('cuenta') || component.get('v.labelPregunta2').toLowerCase().includes('cuenta') || component.get('v.labelPregunta2').toLowerCase().includes('año') || component.get('v.labelPregunta1').toLowerCase().includes('edad')) {
			component.set('v.caracteresNoPermitidos2', regexNumerico.test(valorPregunta2));
		}

		if (tipoPregunta1 === 'number') {
			if (valorPregunta1 > 9999) {
				component.set('v.caracteresNoPermitidos1', true);
			}
		}
		if (tipoPregunta2 === 'number') {
			if (valorPregunta2 > 9999) {
				component.set('v.caracteresNoPermitidos2', true);
			}
		}

	},

	recuperarMensajeToast: function(component, tipo, validacion) {
		let recuperarMensajeToast = component.get('c.mensajeValidacionPreguntas');
		recuperarMensajeToast.setParams({'validacion': validacion});
		recuperarMensajeToast.setCallback(this, function(response) {
			if (response.getState() === 'SUCCESS') {
				let tituloMensaje = response.getReturnValue();
				this.mostrarToast(tipo, tituloMensaje.Name, tituloMensaje.CC_Valor__c);
			}
		});
		$A.enqueueAction(recuperarMensajeToast);
	}
});