/*eslint-disable no-undef */
({
	inicializar: function (component, event, helper) {
		//let X = '';
		let recordId = component.get('v.recordId');
		let contador = component.get('v.contador');
		if (recordId != null) {
			//Recuperar franja del día.
			let franjaHoraria = helper.franjaDia();
			let mensajes = [];
			let elementTransfer = {};
			//Obtenemos campos de Live Chat Transcript

			let sAreaChat = '';
			let resultado = {};

			let getLiveChatTranscript = component.get('c.getLiveChatTranscript_v2');
			getLiveChatTranscript.setParams({ 'recordId': recordId, 'franjaHoraria': franjaHoraria });
			getLiveChatTranscript.setCallback(this, function (response) {
				if (response.getState() === 'SUCCESS') {
					let respuestaDatos = response.getReturnValue();
					//console.log('respuestaDatos: ' + JSON.stringify(respuestaDatos));

					let stopAndGo = '';
					let transfer = '';
					let sEmployeeNumber = '';
					let company = '';
					//let encuesta = '';
					if (respuestaDatos !== null) {
						//console.log('respuestaDatos - OK');
						for (let key in respuestaDatos) {
							if (key === 'DatosChat' && respuestaDatos[key].length === 1) {
								resultado = respuestaDatos[key][0];
							} else if (key === 'AreaChat') {
								sAreaChat = respuestaDatos[key];
								component.set('v.areaChat', respuestaDatos[key]);
							} else if (key === 'IdsGlobales') {
								component.set('v.oIdentGlobales', respuestaDatos[key]);
							} else if (key === 'IdiomasChat') {
								let oIdiomasChat = respuestaDatos[key];
								let oOpcionesIdioma = [];
								if (oIdiomasChat !== null) {
									for (let idiomaKey in oIdiomasChat) {
										if (Object.prototype.hasOwnProperty.call(oIdiomasChat, idiomaKey)) {
											let element = {};
											element.label = oIdiomasChat[idiomaKey];
											element.value = idiomaKey;
											oOpcionesIdioma.push(element);
										}
									}
								}
								component.set('v.radioOptions', oOpcionesIdioma);
								//US461779: Visualizar Nº stop&go Se suplanta el contador de casos Hidden por el contador de stop&go
								//} else if (key === "ContadorHidden") {
								//component.set("v.contadorHidden", respuestaDatos[key]);
							} else if (key === 'ContadorStopAndGo') {
								component.set('v.contadorStopAndGo', respuestaDatos[key]);
							} else if (key === 'MensajeBienvenida') {
								mensajes = respuestaDatos[key];
							} else if (key === 'DatosTransferir') {
								elementTransfer = respuestaDatos[key];
							} else if (key === 'StopAndGo') {
								stopAndGo = respuestaDatos[key];
								if (stopAndGo === 'Si') {
									component.set('v.stopAndGo', respuestaDatos[key]);
								}
							} else if (key === 'Perfil') {
								component.set('v.perfil', respuestaDatos[key]);
							} else if (key === 'Pilotaje') {
								component.set('v.pilotaje', respuestaDatos[key]);
							} else if (key === 'EmployeeNumber') {
								sEmployeeNumber = respuestaDatos[key];
								//} else if (key === 'Encuesta') {
								//encuesta = respuestaDatos[key];
							} else if (key === 'Company') {
								company = respuestaDatos[key];
							} else if (key === 'ContadorTransfer') {
								component.set('v.contadorTransfer', respuestaDatos[key]);
							} else if (key === 'Transfer') {
								transfer = respuestaDatos[key];
								if (transfer === 'Si') {
									component.set('v.transfer', respuestaDatos[key]);
								}
							}

						}
					} else {
						console.error('respuestaDatos - KO');
					}

					component.set('v.liveChatTranscript', resultado);
					component.set('v.radioValue', resultado.CC_IdiomaCV__c);
					component.set('v.origen', resultado.CC_Canal_Procedencia__c);
					component.set('v.caseId', resultado.CaseId);
					component.set('v.cognitiveId', resultado.CC_Id_Cognitive__c);
					component.set('v.contactoId', resultado.ContactId);
					component.set('v.areaChat', sAreaChat);
					component.set('v.tipoChat', resultado.CC_Tipo__c);
					component.set('v.espacio', resultado.CC_Espacio__c);
					component.set('v.aplicacion', resultado.CC_Aplicacion__c);
					component.set('v.habilitarC2C', resultado.CC_Habilitar_Escalar_C2C__c);
					component.set('v.aplicacionOrigen', resultado.CC_Aplicacion_Origen__c);
					//Dana New
					component.set('v.agenteIniciaChat', resultado.CC_Nickname__c);

					//Whatsapp
					if (resultado.CC_Aplicacion_Origen__c === 'Whatsapp') {
						component.set('v.sourceApp', resultado.CC_Source_Aplicacion_Corpus__c);
						component.set('v.sourceConversationId', resultado.CC_Source_Conversation_Id__c);

						let actionWhats = component.get('c.getContexto');
						actionWhats.setParams({
							sourceApp: resultado.CC_Source_Aplicacion_Corpus__c,
							sourceConversationId: resultado.CC_Source_Conversation_Id__c,
							recordId: recordId,
							caseId: resultado.CaseId
						});
						actionWhats.setCallback(this, actionWhatsResponse => {
							if (actionWhatsResponse.getState() === 'SUCCESS') {
								let ccRefreshChatHistory = $A.get('e.c:CC_Refresh_ChatHistory');
								ccRefreshChatHistory.setParams({ 'recordId': component.get('v.recordId'), 'cognitivo': true });
								ccRefreshChatHistory.fire();
							}
						});
						$A.enqueueAction(actionWhats);
					}

					//Levantar FAQs automáticamente cuando es Hidden.
					if (resultado.CC_Tipo__c === 'Hidden') {
						//eslint-disable-next-line @lwc/lwc/no-async-operation
						window.setTimeout($A.getCallback(() => {
							let liveAgentEvent = $A.get('e.c:CC_LiveAgent_Event');
							liveAgentEvent.setParams({ 'showBuscar': true });
							liveAgentEvent.setParams({ 'recordId': recordId });
							liveAgentEvent.setParams({ 'idioma': resultado.CC_IdiomaCV__c });
							liveAgentEvent.setParams({ 'areaChat': sAreaChat });
							liveAgentEvent.setParams({ 'espacio': resultado.CC_Espacio__c });
							liveAgentEvent.fire();
						}), 350);
					}
					//Comprobación: si la aplicación es CSI Bankia, no se puede cambiar el idioma, por defecto sera 'es'
					if (resultado.CC_Aplicacion__c === 'CC_OFICINAS_CSI') {
						component.set('v.radioButtonDisabled', 'true');
					}

					let categoria = resultado.CC_Categoria__c;
					if (categoria === undefined) {
						categoria = null;
					}
					component.set('v.categoria', categoria);

					//if (sAreaChat === 'Empleado' || sAreaChat === 'Cliente') {
					let conversationKit = component.find('conversationKit');
					recordId = recordId.substring(0, 15);
					//var nombreAgente = resultado.Owner.Name;
					let nombreAgente = resultado.Owner.FirstName;
					//var msg = '<auto>Chat aceptado por: '+nombreAgente;
					//conversationKit.sendMessage({recordId: recordId, message: { text : msg}});
					let type = 'AGENT_ACTION';
					let data2;
					let data;
					if (!resultado.CC_Bienvenida__c || resultado.CC_Tipo__c == 'Hidden') {
						data2 = {
							'responseType': 'AGENT',
							'name': nombreAgente,
							'icon': 'img\/ImgAgente.jpg',
							'agentId': sEmployeeNumber,
							'company': company
						};
						data = JSON.stringify(data2);
						conversationKit.sendCustomEvent({
							recordId: recordId,
							type: type,
							data: data
						});
					}
					if (resultado.CC_Bienvenida__c === false && resultado.CC_Tipo__c !== 'Hidden') {
						//var conversationKit = component.find("conversationKit");
						//recordId = recordId.substring(0, 15);
						let mensaje = '';
						if (mensajes.length) {
							//Random + replace de los tags
							mensaje = mensajes[Math.floor(Math.random() * mensajes.length)]
								.replace('{!saludo}', helper.saludo(resultado.CC_IdiomaCV__c))
								.replace('{!cliente}', resultado.CC_Nickname__c)
								.replace('{!agente}', resultado.Owner.Alias);

						} else {
							mensaje = helper.saludo(resultado.CC_IdiomaCV__c) + ' ';
							if (resultado.CC_IdiomaCV__c === 'ca') {
								mensaje = mensaje + 'sóc ' + resultado.Owner.Alias + ' i t\'ajudaré amb la teva consulta.';
							} else {
								mensaje = mensaje + 'soy ' + resultado.Owner.Alias + ' y te ayudaré con tu consulta.';
							}
						}

						//Enviamos el mensaje de bienvenida
						conversationKit.sendMessage({ recordId: recordId, message: { text: mensaje } });
					}


					//Envio el id del Caso a Cognitive
					if (resultado.CaseId != null) {
						let conversation = component.find('conversationKit');
						let chatId = component.get('v.recordId');
						let casoId = component.get('v.caseId');
						chatId = chatId.substring(0, 15);
						type = 'IDSR';
						data2 = { 'responseType': 'IDSR', 'msg': casoId };
						data = JSON.stringify(data2);
						conversation.sendCustomEvent({
							recordId: chatId,
							type: type,
							data: data
						});
					}

					//Crear tarea Stop&Go
					if (stopAndGo === 'Si') {
						recordId = recordId.substring(0, 15);
						let recordId2 = component.get('v.recordId');
						let cognitiveId = component.get('v.cognitiveId');
						let caseId = component.get('v.caseId');
						//let codCognitive = component.get('v.codCognitive');
						let msg = null;
						let createActivity = component.get('c.CreateActivity');
						createActivity.setParams({
							recordId: caseId,
							comentario: msg,
							cognitiveId: cognitiveId,
							subject: 'Chat - Stop&Go',
							transcriptId: recordId2,
							tipo: 'Stop&Go',
							telefono: null,
							espacio: null,
							categoria: null
						});
						createActivity.setCallback(this, responseCreateActivity => {
							if (responseCreateActivity.getState() === 'SUCCESS') {
								$A.get('e.force:refreshView').fire();
							}
						});
						$A.enqueueAction(createActivity);
					}
				} else {
					if (contador === 1) {
						let a = component.get('c.inicializar');
						contador = contador + 1;
						component.set('v.contador', contador);
						$A.enqueueAction(a);
					}
				}
	
			});
			$A.enqueueAction(getLiveChatTranscript);

			//eslint-disable-next-line @lwc/lwc/no-async-operation
			window.setTimeout($A.getCallback(() => {
				//Asignar el caso.
				let action = component.get('c.gestionChatOwner_Interno2');
				action.setParams({ chatsEntrantes: recordId });
				$A.enqueueAction(action);
			}), 300);
		}
	},

	sendMessage: function (cmp) {
		//var msg= evt.getSource().get("v.label");
		let msg;
		if (cmp.get('v.radioValue') === 'ca') {
			msg = 'Crec que he resolt el teu dubte. Tens més preguntes?';
		} else {
			msg = 'Creo que he resuelto tu duda. ¿Tienes alguna otra consulta?';
		}

		//var msg= "¿Puedo ayudarte en algo más?";
		let conversationKit = cmp.find('conversationKit');
		let recordId = cmp.get('v.recordId');
		recordId = recordId.substring(0, 15);
		conversationKit.sendMessage({
			recordId: recordId,
			message: { text: msg }
		});
	},

	onChangeLanguage: function (component) {
		let changeLanguage = component.get('c.changeLanguage');
		let liveChatTranscript = component.get('v.liveChatTranscript');
		let idiomaSel = component.get('v.radioValue');
		let sAreaChat = component.get('v.areaChat');
		let chatId = liveChatTranscript.Id;
		let caseId = liveChatTranscript.CaseId;
		changeLanguage.setParams({
			caseId: caseId,
			chatId: chatId,
			idioma: idiomaSel,
			sAreaChat: sAreaChat
		});

		changeLanguage.setCallback(this, response => {
			let state = response.getState();
			if (component.isValid() && state === 'SUCCESS') {
				let cognitiveCode = 'CAMBIO_IDIOMA';
				let agentMsg = '<auto>Mensaje Sistema. Cambio de idioma';
				let sEstadoCambio = 'KO';
				let sIdiomaAnt = '';

				let oMap = response.getReturnValue();
				if (oMap !== null) {
					for (let key in oMap) {
						if (key === 'MensajeChat' && oMap[key] !== null) {
							agentMsg = oMap[key].CC_Mensaje_Agente_es__c;
							cognitiveCode = oMap[key].CC_Codigo_Cognitive__c;
						} else if (key === 'IdsGlobales') {
							component.set('v.oIdentGlobales', oMap[key]);
						} else if (key === 'Estado') {
							sEstadoCambio = oMap[key];
						} else if (key === 'idiomaAnterior') {
							sIdiomaAnt = oMap[key];
						}
					}
				}

				if (!cognitiveCode) {
					cognitiveCode = 'CAMBIO_IDIOMA';
					agentMsg = '<auto>Mensaje Sistema. Cambio de idioma';
				}

				if (sEstadoCambio === 'OK') {
					let conversationKit = component.find('conversationKit');
					let chatId = component.get('v.recordId');
					chatId = chatId.substring(0, 15);
					let idiomaMensaje = component.get('v.radioValue');

					//Enviamos el mensaje de cambio de idioma al agente.
					conversationKit.sendMessage({
						recordId: chatId,
						message: { text: agentMsg }
					});

					//Enviar CustomEvent para informar del cambio de idioma a Cognitivo.
					let type = 'AGENT_ACTION';
					let data2 = {
						'responseType': cognitiveCode,
						'idioma': idiomaMensaje
					};
					let data = JSON.stringify(data2);
					conversationKit.sendCustomEvent({
						recordId: chatId,
						type: type,
						data: data
					}).then(() => {
						//console.log('OK');
					}, () => {
						//console.log('KO');
					});

					let evt = $A.get('e.c:CC_Refresh_FAQ');
					evt.setParams({ 'recordId': component.get('v.recordId') });
					evt.fire();
				} else {
					//Error al realizar el cambio de idioma.
					component.set('v.radioValue', sIdiomaAnt);

					let toastEvent = $A.get('e.force:showToast');
					toastEvent.setParams({ 'title': 'Error al cambiar el idioma', 'message': 'No se ha podido realizar el cambio de idioma. Vuelva a intentarlo de nuevo, si el problema persiste póngase en contacto con el administrador del sistema.', 'type': 'error' });
					toastEvent.fire();

					$A.get('e.force:refreshView').fire();
				}
			}
		});
		$A.enqueueAction(changeLanguage);
	},

	buscar: function (cmp) {
		let ccLiveAgentEvent = $A.get('e.c:CC_LiveAgent_Event');
		ccLiveAgentEvent.setParams({ 'showBuscar': true });
		ccLiveAgentEvent.setParams({ 'recordId': cmp.get('v.recordId') });
		ccLiveAgentEvent.setParams({ 'idioma': cmp.get('v.radioValue') });
		ccLiveAgentEvent.setParams({ 'areaChat': cmp.get('v.areaChat') });
		ccLiveAgentEvent.setParams({ 'espacio': cmp.get('v.espacio') });
		ccLiveAgentEvent.fire();
	},

	noSoportada: function (cmp) {
		let action = cmp.get('c.getMensajesChat');
		action.setParams({
			sCodigoMsj: 'No Soportada',
			idioma: cmp.get('v.radioValue'),
			//oGlobalIds : cmp.get("v.oIdentGlobales"),
			oGlobalIds: null,
			sOrigen: cmp.get('v.origen'),
			sAreaChat: cmp.get('v.areaChat')
		});

		action.setCallback(this, function (response) {
			let list = response.getReturnValue();
			if (list !== null) {
				let auto = [];
				let listAuto;
				let codCognitive;
				codCognitive = list[0].CC_Codigo_Cognitive__c;

				let msgCognitivo = [];
				list.forEach(mensaje => {
					msgCognitivo.push(mensaje.CC_Respuesta_Mensaje_Automatico_es__c);
					auto.push(mensaje.CC_Mensaje_Agente_es__c);
				});

				list = msgCognitivo;
				listAuto = auto;
				cmp.set('v.picklistValues', list);

				//Control
				if (list.length === 1) {
					cmp.set('v.showNoSoportada', false);
					let conversationKit = cmp.find('conversationKit');
					let chatId = cmp.get('v.recordId');
					let chatId2 = cmp.get('v.recordId');
					let caseId = cmp.get('v.caseId');
					let cognitiveId = cmp.get('v.cognitiveId');
					let valor;
					let autoMsg;
					chatId = chatId.substring(0, 15);

					for (let item = 0; item < list.length; item++) {
						valor = list[item];
					}

					for (let jtem = 0; jtem < listAuto.length; jtem++) {
						autoMsg = listAuto[jtem];
					}

					conversationKit.sendMessage({
						recordId: chatId,
						message: { text: autoMsg }
					});

					//Recuperar el código de cognitive
					let type = 'AGENT_ACTION';
					let data2 = {
						'responseType': codCognitive, //"MSG",
						'txtMsg': valor
					};
					let data = JSON.stringify(data2);
					conversationKit.sendCustomEvent({
						recordId: chatId,
						type: type,
						data: data
					}).then(() => {
						//console.log('OK');
					}, () => {
						//console.log('KO');
					});
					//Crear la actividad de No Soportada
					let createActivity = cmp.get('c.CreateActivity');
					createActivity.setParams({
						recordId: caseId,
						comentario: valor,
						cognitiveId: cognitiveId,
						subject: 'Chat - No Soportada',
						tipo: 'No soportada',
						transcriptId: chatId2,
						telefono: null,
						espacio: null,
						categoria: null
					});

					createActivity.setCallback(this, responseCreateActivity => {
						if (responseCreateActivity.getState() === 'SUCCESS') {
							$A.get('e.force:refreshView').fire();
						}
					});
					$A.enqueueAction(createActivity);
					//$A.enqueueAction(cmp.get('c.finalizarchat'));

				} else if (list.length > 1) {
					cmp.find('compNoSoportada').refresh();
					cmp.set('v.showNoSoportada', true);
				}
			}
		});
		$A.enqueueAction(action);
	},

	abrirModalReformular: function (component) {

		let getMensajesChat = component.get('c.getMensajesChat');
		getMensajesChat.setParams({
			sCodigoMsj: 'Reformular',
			idioma: component.get('v.radioValue'),
			//oGlobalIds : component.get("v.oIdentGlobales"),
			oGlobalIds: null,
			sOrigen: component.get('v.origen'),
			sAreaChat: component.get('v.areaChat')
		});

		getMensajesChat.setCallback(this, response => {
			let list = response.getReturnValue();
			if (list !== null) {
				if (list.length > 0) {
					let msgCognitivo = [];
					let auto = [];
					let codCognitive = [];

					list.forEach(mensaje => {
						msgCognitivo.push(mensaje.CC_Respuesta_Mensaje_Automatico_es__c);
						auto.push(mensaje.CC_Mensaje_Agente_es__c);
						codCognitive.push(mensaje.CC_Codigo_Cognitive__c);
					});

					list = msgCognitivo;
					component.set('v.picklistValues', list);
					component.set('v.codCognitive', codCognitive);
					component.set('v.auto', auto);
				} else {
					component.set('v.picklistValues', list);
				}

				$A.util.addClass(component.find('ModalboxReformular'), 'slds-fade-in-open');
				$A.util.addClass(component.find('backdrop'), 'slds-backdrop--open');
			}
		});
		$A.enqueueAction(getMensajesChat);
	},


	reformular: function (cmp) {
		let conversationKit = cmp.find('conversationKit');
		let recordId = cmp.get('v.recordId').substring(0, 15);
		let recordId2 = cmp.get('v.recordId');
		let cognitiveId = cmp.get('v.cognitiveId');
		let caseId = cmp.get('v.caseId');
		let msgCog = cmp.get('v.picklistValues');
		let codCognitive = cmp.get('v.codCognitive');
		let autoMsg = cmp.get('v.auto');
		let autoIter = cmp.find('selectId').get('v.value');
		let auto;
		let msg;
		let codCognitivo;

		if (autoIter === '') {
			return;
		}

		auto = autoMsg[autoIter];
		msg = msgCog[autoIter];
		codCognitivo = codCognitive[autoIter];
		conversationKit.sendMessage({ recordId: recordId, message: { text: auto } });
		cmp.set('v.isActive', false);
		cmp.set('v.valor', '');
		//Envio del evento a Watson
		let type = 'AGENT_ACTION';
		let data2 = {
			'responseType': 'REFORMULAR',
			'faq': null,
			'doc': null,
			'msg': codCognitivo,
			'c2c': null,
			'noDisconnect': 0,
			'txtMsg': null,
			'dedicacion': null,
			'idioma': null,
			'idiomaSeleccionado': null
		};

		let data = JSON.stringify(data2);
		conversationKit.sendCustomEvent({
			recordId: recordId,
			type: type,
			data: data
		}).then(() => {
			//console.log('OK');
		}, () => {
			//console.log('KO');
		});

		//Crear la actividad de Reformular
		let action = cmp.get('c.CreateActivity');
		action.setParams({
			recordId: caseId,
			comentario: msg,
			cognitiveId: cognitiveId,
			subject: 'Chat - Reformular',
			transcriptId: recordId2,
			tipo: 'Reformular',
			telefono: null,
			espacio: null,
			categoria: null
		});
		action.setCallback(this, response => {
			if (response.getState() === 'SUCCESS') {

				$A.get('e.force:refreshView').fire();
			}
			$A.enqueueAction(cmp.get('c.cerrarModalReformular'));
			//$A.enqueueAction(cmp.get('c.finalizarchat'));
		});
		$A.enqueueAction(action);
	},

	cerrarModalReformular: function (component) {
		$A.util.removeClass(component.find('ModalboxReformular'), 'slds-fade-in-open');
		$A.util.removeClass(component.find('backdrop'), 'slds-backdrop--open');
	},

	finalizarchat: function (component) {
		let conversationKit = component.find('conversationKit');
		let recordId = component.get('v.recordId');
		if (component.get('v.tipoChat') === 'Hidden') {
			conversationKit.endChat({
				recordId: recordId
			}).then(result => {
				if (result) {
					console.log('Successfully ended chat');
				} else {
					console.log('Failed to end chat');
				}
			});
		}
	},

	abrirModalEscalar: function (component, event, helper) {
		helper.getPicklistEspacios(component);
		helper.getPicklistCategoria(component);

		if (component.get('v.categoria') === undefined) {
			component.set('v.categoria', '--Selecciona una categoría--');
		}

		$A.util.addClass(component.find('ModalboxEscalar'), 'slds-fade-in-open');
		$A.util.addClass(component.find('backdrop'), 'slds-backdrop--open');

	},

	cerrarModalEscalar: function (component) {
		$A.util.removeClass(component.find('ModalboxEscalar'), 'slds-fade-in-open');
		$A.util.removeClass(component.find('backdrop'), 'slds-backdrop--open');
	},

	c2c: function (component) {
		let recordId = component.get('v.recordId');
		let categoria = component.get('v.categoria');
		let espacio = component.get('v.espacio');
		let descripcion;
		let telefono;

		//Obtenemos campos de Live Chat Transcript
		let getLiveChatTranscript = component.get('c.datosLiveChatTranscript');
		getLiveChatTranscript.setParams({
			'recordId': recordId,
			'idioma': component.get('v.radioValue'),
			'categoria': categoria,
			'espacio': null
		});

		getLiveChatTranscript.setCallback(this, function (response) {
			if (response.getState() === 'SUCCESS') {
				let respuestaDatos = response.getReturnValue();
				if (respuestaDatos !== null) {
					for (let key in respuestaDatos) {
						if (key === 'Categoria') {
							categoria = respuestaDatos[key];
						} else if (key === 'DescripcionCategoria') {
							descripcion = respuestaDatos[key];
						} else if (key === 'Espacio') {
							espacio = respuestaDatos[key];
						} else if (key === 'Telefono') {
							telefono = respuestaDatos[key];
						}
					}
				}
			}
			let conversationKit = component.find('conversationKit');
			recordId = recordId.substring(0, 15);
			let cognitiveId = component.get('v.cognitiveId');
			let caseId = component.get('v.caseId');
			let msg = '<auto>Se ha realizado un C2C';
			conversationKit.sendMessage({
				recordId: recordId,
				message: { text: msg }
			});
			let type = 'AGENT_ACTION';
			let data2 = {
				'responseType': 'C2C',
				'c2c': {
					'category': categoria,
					'description': descripcion,
					'phone': telefono,
					'space': null,
					'descriptionSpace': null
				}
			};
			let data = JSON.stringify(data2);
			conversationKit.sendCustomEvent({
				recordId: recordId,
				type: type,
				data: data
			}).then(() => {
				//console.log('OK');
			}, () => {
				//console.log('KO');
			});
			//Crear la actividad de C2C
			let createActivity = component.get('c.CreateActivity');
			createActivity.setParams({
				recordId: caseId,
				comentario: msg,
				cognitiveId: cognitiveId,
				subject: 'Chat - C2C',
				transcriptId: recordId,
				tipo: 'C2C',
				telefono: telefono,
				espacio: espacio,
				categoria: categoria
			});
			createActivity.setCallback(this, response => {
				if (response.getState() === 'SUCCESS') {
					$A.get('e.force:refreshView').fire();
				}
				$A.enqueueAction(component.get('c.cerrarModalEscalar'));
			});
			$A.enqueueAction(createActivity);
		});
		$A.enqueueAction(getLiveChatTranscript);
	},

	escalar: function (component) {

		let recordId = component.get('v.recordId');
		let categoria = component.get('v.categoria');
		let descripcionCategoria;
		let espacio = component.get('v.espacio');
		let descripcionEspacio;
		let telefono;

		//Obtenemos campos de Live Chat Transcript
		let getLiveChatTranscript = component.get('c.datosLiveChatTranscript');
		getLiveChatTranscript.setParams({
			'recordId': recordId,
			'idioma': component.get('v.radioValue'),
			'categoria': categoria,
			'espacio': null
		});

		getLiveChatTranscript.setCallback(this, function (response) {
			if (response.getState() === 'SUCCESS') {
				let respuestaDatos = response.getReturnValue();
				if (respuestaDatos !== null) {
					for (let key in respuestaDatos) {
						if (key === 'Categoria') {
							categoria = respuestaDatos[key];
						} else if (key === 'DescripcionCategoria') {
							descripcionCategoria = respuestaDatos[key];
						} else if (key === 'DescripcionEspacio') {
							descripcionEspacio = respuestaDatos[key];
						} else if (key === 'Telefono') {
							telefono = respuestaDatos[key];
						}
					}
				}
			}
			let conversationKit = component.find('conversationKit');
			recordId = recordId.substring(0, 15);
			let cognitiveId = component.get('v.cognitiveId');
			let caseId = component.get('v.caseId');
			let msg = '<auto>Se ha realizado un escalado';
			conversationKit.sendMessage({
				recordId: recordId,
				message: { text: msg }
			});
			let type = 'AGENT_ACTION';
			let data2 = {
				'responseType': 'CHAT',
				'c2c': {
					'category': categoria,
					'description': descripcionCategoria,
					'phone': telefono,
					'space': espacio,
					'descriptionSpace': descripcionEspacio
				}
			};
			let data = JSON.stringify(data2);
			conversationKit.sendCustomEvent({
				recordId: recordId,
				type: type,
				data: data
			}).then(() => {
				//console.log('OK');
			}, () => {
				//console.log('KO');
			});
			//Crear la actividad de escalar
			let action = component.get('c.CreateActivity');
			action.setParams({
				recordId: caseId,
				comentario: msg,
				cognitiveId: cognitiveId,
				subject: 'Chat - Escalar',
				transcriptId: recordId,
				tipo: 'Escalar',
				telefono: telefono,
				espacio: espacio,
				categoria: categoria
			});
			action.setCallback(this, response => {
				if (response.getState() === 'SUCCESS') {
					$A.get('e.force:refreshView').fire();
				}
				$A.enqueueAction(component.get('c.cerrarModalEscalar'));
				//$A.enqueueAction(cmp.get('c.finalizarchat'));
			});
			$A.enqueueAction(action);
		});
		$A.enqueueAction(getLiveChatTranscript);
	},

	abrirModalReclasificar: function (component, event, helper) {
		helper.getPicklistEspacios(component);
		if (component.get('v.tipoChat') !== 'Hidden') {
			helper.getPicklistCategoria(component);
		}

		$A.util.addClass(component.find('ModalboxReclasificar'), 'slds-fade-in-open');
		$A.util.addClass(component.find('backdrop'), 'slds-backdrop--open');
	},

	cerrarModalReclasificar: function (component) {
		component.set('v.transferirChecked', false);
        component.set('v.transferAPP', false);
		$A.util.removeClass(component.find('ModalboxReclasificar'), 'slds-fade-in-open');
		$A.util.removeClass(component.find('backdrop'), 'slds-backdrop--open');
	},
        
        reclasificar: function (component) {
		let recordId = component.get('v.recordId');
		let categoria = component.get('v.categoria');
		let espacio = component.get('v.espacio');
		let transferir = component.get('v.transferirChecked');
		let tipoChat = component.get('v.tipoChat');
		let descripcionEspacio;
		let descripcionCategoria;
		let telefono;
		let desconectar = 0;
		let caseId = component.get('v.caseId');
		let cognitiveId = component.get('v.cognitiveId');
        let doFind = false;
        let enviarEvento = true;
        let transferAPP = component.get('v.transferAPP');
       // console.log('transferAPP: '+transferAPP);
       
		let action = component.get('c.actualizarLiveChat');
		action.setParams({
			recordId: recordId,
			espacio: espacio,
			categoria: categoria,
			transferir: transferir
		});
		action.setCallback(this, function (response) {
			if (response.getState() === 'SUCCESS') {
				//Obtenemos campos de Live Chat Transcript
				let getLiveChatTranscript = component.get('c.datosLiveChatTranscriptTransfer');
				getLiveChatTranscript.setParams({
					'recordId': recordId,
					'idioma': component.get('v.radioValue'),
					'categoria': categoria,
					'espacio': espacio,
					'tipoChat': tipoChat,
                    'actualizar': true
				});

				getLiveChatTranscript.setCallback(this, function (response) {
					if (response.getState() === 'SUCCESS') {
                        //console.log('datosLiveChatTranscriptTransfer');
						let respuestaDatos = response.getReturnValue();
						if (respuestaDatos !== null) {
							for (let key in respuestaDatos) {
								if (key === 'DescripcionCategoria') {
									descripcionCategoria = respuestaDatos[key];
								} else if (key === 'DescripcionEspacio') {
									descripcionEspacio = respuestaDatos[key];
								} else if (key === 'Telefono') {
									telefono = respuestaDatos[key];
								}else if (key === 'doFind') {
									if (respuestaDatos[key] == 'False') {
										doFind = true;
									}
								} /*else if (key === 'Piloto') {
									if (respuestaDatos[key] == 'Si') {
										desconectar = 0;
									}
								}*/
							}
						}
					//}
                     
					let conversationKit = component.find('conversationKit');
					recordId = recordId.substring(0, 15);
					//var msg = '<auto>Este chat se va a transferir';
					//conversationKit.sendMessage({recordId: recordId, message: { text : msg}});
					let type = 'AGENT_ACTION';
					let data2;
					if (categoria == null || categoria == '') {

						data2 = {
							'responseType': 'TRANSFER',
							'noDisconnect': desconectar,
							'c2c': {
								'category': null,
								'description': null,
								'phone': null,
								'space': espacio,
								'descriptionSpace': descripcionEspacio
							}
						};
					} else {
                        if(doFind){
                            component.set('v.transferAPP', true);
                            enviarEvento = false;
                            data2 = {
                                'responseType': 'TRANSFER',
                                'noDisconnect': desconectar,
                                'doFind' : true,
                                'c2c': {
                                    'category': categoria,
                                    'description': descripcionCategoria,
                                    'phone': telefono,
                                    'space': espacio,
                                    'descriptionSpace': descripcionEspacio
                                }
                            };    
                        }else{
                            
                            data2 = {
                                'responseType': 'TRANSFER',
                                'noDisconnect': desconectar,
								'doFind' : true,
                                'c2c': {
                                    'category': categoria,
                                    'description': descripcionCategoria,
                                    'phone': telefono,
                                    'space': espacio,
                                    'descriptionSpace': descripcionEspacio
                                }
                            };
                        }
					}
					//window.setTimeout($A.getCallback(() => {
			
					
					if (desconectar === 1) {
						component.set('v.mostrarMensaje', true);
						let toastEvent = $A.get('e.force:showToast');
						toastEvent.setParams({ 'title': 'Finalizar transfer', 'message': 'Recuerda que debes finalizar el transfer por la operativa actual.', 'type': 'warning' });
						toastEvent.fire();
					} else {
						let crearActividad = component.get('c.CreateActivity');
						crearActividad.setParams({
							recordId: caseId,
							comentario: 'Este chat se ha transferido',
							subject: 'Chat - Transferir',
							tipo: 'Transferir',
							cognitiveId: cognitiveId,
							transcriptId: recordId,
							telefono: null,
							espacio: espacio,
							categoria: categoria
						});

						crearActividad.setCallback(this, response => {
							let state = response.getState();
							if (state === 'SUCCESS') {
								$A.get('e.force:refreshView').fire();
							}
						});
						$A.enqueueAction(crearActividad);
					}
                        //console.log('EnviarEvento: '+enviarEvento);
                        if(enviarEvento){
                            // console.log('senCustom');
                            let data = JSON.stringify(data2);
                            conversationKit.sendCustomEvent({
                                recordId: recordId,
                                type: type,
                                data: data
                            }).then(() => {
                                //console.log('OK');
                            }, () => {
                                //console.log('KO');
                            });
                            
                            $A.get('e.force:refreshView').fire();
                            
                        }else{
                            $A.util.addClass(component.find('ModalboxReclasificar'), 'slds-fade-in-open');
                            $A.util.addClass(component.find('backdrop'), 'slds-backdrop--open');    
                        }
                    
                        //}), 600);
                    }
				});
				$A.enqueueAction(getLiveChatTranscript);

				$A.enqueueAction(component.get('c.cerrarModalReclasificar'));
			}
		});
		$A.enqueueAction(action);

	},
        
    transferAPP: function (component) {
        let recordId = component.get('v.recordId');
        let categoria = component.get('v.categoria');
        let espacio = component.get('v.espacio');
        let transferir = component.get('v.transferirChecked');
        let tipoChat = component.get('v.tipoChat');
        let descripcionEspacio;
        let descripcionCategoria;
        let telefono;
        let desconectar = 0;
        let caseId = component.get('v.caseId');
        let cognitiveId = component.get('v.cognitiveId');
        let doFind = false;
        let enviarEvento = true;
        let transferAPP = component.get('v.transferAPP');
        //console.log('transferAPP1: '+transferAPP);
        
        
        //Obtenemos campos de Live Chat Transcript
        let getLiveChatTranscript = component.get('c.datosLiveChatTranscriptTransfer');
        getLiveChatTranscript.setParams({
            'recordId': recordId,
            'idioma': component.get('v.radioValue'),
            'categoria': categoria,
            'espacio': espacio,
            'tipoChat': tipoChat,
            'actualizar': false
        });
        
        getLiveChatTranscript.setCallback(this, function (response) {
            if (response.getState() === 'SUCCESS') {
                //console.log('datosLiveChatTranscriptTransfer');
                let respuestaDatos = response.getReturnValue();
                if (respuestaDatos !== null) {
                    for (let key in respuestaDatos) {
                        if (key === 'DescripcionCategoria') {
                            descripcionCategoria = respuestaDatos[key];
                        } else if (key === 'DescripcionEspacio') {
                            descripcionEspacio = respuestaDatos[key];
                        } else if (key === 'Telefono') {
                            telefono = respuestaDatos[key];
                        }else if (key === 'doFind') {
                            if (respuestaDatos[key] == 'False') {
                                doFind = true;
                            }
                        } /*else if (key === 'Piloto') {
									if (respuestaDatos[key] == 'Si') {
										desconectar = 0;
									}
								}*/
                            }
                        }
                        //}
                        
                        let conversationKit = component.find('conversationKit');
                        recordId = recordId.substring(0, 15);
                        //var msg = '<auto>Este chat se va a transferir';
                        //conversationKit.sendMessage({recordId: recordId, message: { text : msg}});
                        let type = 'AGENT_ACTION';
                        let data2;
                        if (categoria == null || categoria == '') {
                            
                            data2 = {
                                'responseType': 'TRANSFER',
                                'noDisconnect': desconectar,
                                'c2c': {
                                    'category': null,
                                    'description': null,
                                    'phone': null,
                                    'space': espacio,
                                    'descriptionSpace': descripcionEspacio
                                }
                            };
                        } else {
                            
                            if(doFind){
                                data2 = {
                                    'responseType': 'TRANSFER',
                                    'noDisconnect': desconectar,
                                    'doFind' : true,
                                    'c2c': {
                                        'category': categoria,
                                        'description': descripcionCategoria,
                                        'phone': telefono,
                                        'space': espacio,
                                        'descriptionSpace': descripcionEspacio
                                    }
                                };    
                            }else{
                                
                                data2 = {
                                    'responseType': 'TRANSFER',
                                    'noDisconnect': desconectar,
                                    'doFind' : true,
                                    'c2c': {
                                        'category': categoria,
                                        'description': descripcionCategoria,
                                        'phone': telefono,
                                        'space': espacio,
                                        'descriptionSpace': descripcionEspacio
                                    }
                                };
                            }
                        }
                        
                        
                        
                        //console.log('senCustom1');
                        let data = JSON.stringify(data2);
                        conversationKit.sendCustomEvent({
                            recordId: recordId,
                            type: type,
                            data: data
                        }).then(() => {
                            //console.log('OK');
                        }, () => {
                            //console.log('KO');
                        });
                        
                        $A.get('e.force:refreshView').fire();
                        
                    }
                    
                });
        $A.enqueueAction(getLiveChatTranscript);
        
        $A.enqueueAction(component.get('c.cerrarModalReclasificar'));
    
	},

	handleEspacioSeleccionado: function (component, event, helper) {
		let actualOption = component.find('firstOptionEspacios').get('v.value');
		component.set('v.espacio', actualOption);
		component.set('v.selectedFirstOption', actualOption);

		//component.set("v.actualFirstOption", actualOption);
		let picklistOptionsEspacio = component.get('v.picklistFirstOptionEspacio');

		for (let key in picklistOptionsEspacio) {
			if (actualOption === picklistOptionsEspacio[key].picklistValue) {
				component.set('v.optionFirstLabel', picklistOptionsEspacio[key].picklistLabel);
			}
		}
		if (component.get('v.tipoChat') !== 'Hidden') {
			helper.getPicklistCategoria(component);
			component.set('v.categoria', '');
		} else {
			component.set('v.categoria', '');
			component.set('v.transferirChecked', true);
		}
	},

	onCodeSelectFirstChangeEspacio: function (component, event, helper) {
		let actualOption = component.find('firstOptionEspacio').get('v.value');
		component.set('v.espacio', actualOption);
		component.set('v.selectedFirstOption', actualOption);

		//component.set("v.actualFirstOption", actualOption);
		let picklistOptionsEspacio = component.get('v.picklistFirstOptionEspacio');

		for (let key in picklistOptionsEspacio) {
			if (actualOption === picklistOptionsEspacio[key].picklistValue) {
				component.set('v.optionFirstLabel', picklistOptionsEspacio[key].picklistLabel);
			}
		}
		if (component.get('v.tipoChat') !== 'Hidden') {
			helper.getPicklistCategoria(component);
			component.set('v.categoria', '');
		} else {
			component.set('v.categoria', '');
			//component.set("v.transferirChecked",true);
		}
	},


	handleCategoriaSeleccionada: function (cmp) {
		let actualOption = cmp.find('firstOptionCategorias').get('v.value');
		cmp.set('v.categoria', actualOption);
		cmp.set('v.selectedFirstOption', actualOption);
		cmp.set('v.transferirChecked', true);
		//cmp.set("v.actualFirstOption", actualOption);
		let picklistOptionsCategoria = cmp.get('v.picklistFirstOptionsCategoria');

		for (let key in picklistOptionsCategoria) {
			if (actualOption === picklistOptionsCategoria[key].picklistValue) {
				cmp.set('v.optionFirstLabel', picklistOptionsCategoria[key].picklistLabel);
			}
		}
	},

	transferir: function (component) {
		let transferir = component.get('v.transferirChecked');
		component.set('v.transferirChecked', transferir);
	},

	sendFIN: function (cmp) {
		let sAreaChat = cmp.get('v.areaChat');

		let action = cmp.get('c.getMensajesChat');
		action.setParams({
			sCodigoMsj: 'Finalizar',
			idioma: cmp.get('v.radioValue'),
			//oGlobalIds : cmp.get("v.oIdentGlobales"),
			oGlobalIds: null,
			sOrigen: '',
			sAreaChat: sAreaChat
		});

		action.setCallback(this, response => {
			let list = response.getReturnValue();
			let valor;
			let auto;
			let codCognitive;

			if (list !== null) {
				if (list.length > 0) {
					let aleatorio = Math.floor(Math.random() * list.length);
					let conversationKit = cmp.find('conversationKit');
					let chatId = cmp.get('v.recordId');
					chatId = chatId.substring(0, 15);
					auto = list[aleatorio].CC_Mensaje_Agente_es__c;
					valor = list[aleatorio].CC_Respuesta_Mensaje_Automatico_es__c;
					codCognitive = list[aleatorio].CC_Codigo_Cognitive__c;

					conversationKit.sendMessage({
						recordId: chatId,
						message: { text: auto }
					});

					let type = 'AGENT_ACTION';
					let data2 = {
						'responseType': codCognitive,
						'txtMsg': valor
					};
					let data = JSON.stringify(data2);
					conversationKit.sendCustomEvent({
						recordId: chatId,
						type: type,
						data: data
					}).then(() => {
						//console.log('OK');
					}, () => {
						//console.log('KO');
					});
				}
			}
		});
		$A.enqueueAction(action);
	},

	onCloseWork: function (cmp, evt) {

		//console.log('entramos');
		//$A.enqueueAction(cmp.get('c.sendFIN'));


		let omniAPI = cmp.find('omniToolkit');
		let recordId = evt.getParam('recordId');
		let recordId2 = cmp.get('v.recordId');
        
		recordId2 = recordId2.substring(0, 15);
		let works = '';
		if (recordId === recordId2) {
			let cerrarCaso = cmp.get('c.cerrarCaso');
            cerrarCaso.setParams({ 'recordId': recordId});
			cerrarCaso.setCallback(this, response => {
				if (response.getState() === 'SUCCESS') {
					$A.get('e.force:refreshView').fire();
				}
			});
			$A.enqueueAction(cerrarCaso);

			omniAPI.getAgentWorks().then(result => {
				works = JSON.parse(result.works);
				for (let i = 0; i < works.length; i++) {
					let workItem = works[i].workItemId;
					if (workItem.substring(0, 15) === recordId2) {
						omniAPI.closeAgentWork({ workId: works[i].workId });
					}
				}
			});

			//**** INI: CIERRE DE PESTAÑA PARA Hidden
			if (cmp.get('v.tipoChat') === 'Hidden') {
				let workspaceAPI = cmp.find('workspace');
				workspaceAPI.getAllTabInfo().then(response => {
					//console.log(response);
					for (let tb in response) {
						if (response[tb].recordId === cmp.get('v.recordId')) {
							workspaceAPI.closeTab({ tabId: response[tb].tabId });
						}
					}
				});
			}
			//**** END: CIERRE DE PESTAÑA PARA Hidden
		}
	},

	onCustomEvent: function (cmp, evt) {
		if (cmp.get('v.recordId') != null && cmp.get('v.recordId') !== undefined) {
			let cognitiveId = cmp.get('v.cognitiveId');
            let transferAPP = cmp.get('v.transferAPP');
			let liveChatTranscript = cmp.get('v.liveChatTranscript');
			let data = evt.getParam('data');
			let type = evt.getParam('type');
			let caseId = cmp.get('v.caseId');
			let chatId = cmp.get('v.recordId');
			chatId = chatId.substring(0, 15);

			if (type === 'TimeOutInactividad' && data === 'TimeOutInactividad' && liveChatTranscript !== null && liveChatTranscript !== undefined) {
				//Crear la actividad de Time-Out
				let action = cmp.get('c.CreateActivity');
				action.setParams({
					recordId: caseId,
					comentario: 'Se ha producido un time out por inactividad.',
					subject: 'Conversación - Time Out',
					tipo: 'Time Out',
					cognitiveId: cognitiveId,
					transcriptId: liveChatTranscript.Id,
					telefono: null,
					espacio: null,
					categoria: null
				});

				action.setCallback(this, response => {
					let state = response.getState();
					if (state === 'SUCCESS') {
						$A.get('e.force:refreshView').fire();
					}
				});
				$A.enqueueAction(action);
				let action2 = cmp.get('c.UpdateLiveChatTrans');
				action2.setParams({
					recordId: chatId
				});
				action2.setCallback(this, response => {
					let state = response.getState();
					if (state === 'SUCCESS') {
						$A.get('e.force:refreshView').fire();
					}
				});
				$A.enqueueAction(action2);
				//Incluimos la llamada al metodo cerrarCaso, para que si se trata de Hidden que los cierre
				let cerrarCaso = cmp.get('c.cerrarCaso');
				cerrarCaso.setParams({ 'recordId': chatId });
				cerrarCaso.setCallback(this, response => {
					if (response.getState() === 'SUCCESS') {
						$A.get('e.force:refreshView').fire();
					}
				});
				$A.enqueueAction(cerrarCaso);
			}
		}
	},

	onCodeSelectFirstChange: function (cmp) {
		let actualOption = cmp.find('firstOptionCategoria').get('v.value');

		if (actualOption !== '--Selecciona una categoría--') {
			cmp.set('v.habilitarEscalar', false);
		} else {
			cmp.set('v.habilitarEscalar', true);
		}

		cmp.set('v.categoria', actualOption);
		cmp.set('v.selectedFirstOption', actualOption);
		//cmp.set("v.actualFirstOption", actualOption);
		let picklistOptionsCategoria = cmp.get('v.picklistFirstOptionsCategoria');

		for (let key in picklistOptionsCategoria) {
			if (actualOption === picklistOptionsCategoria[key].picklistValue) {
				cmp.set('v.optionFirstLabel', picklistOptionsCategoria[key].picklistLabel);
			}
		}
	},

	pausar: function (cmp, evt, hlp) {
		hlp.recuperarMensajesPausa(cmp).then(() => {

		let label = evt.getSource().get('v.label');
		let start, end;
		let data2;
		let mensaje = cmp.get('v.mensaje');

		//Usamos la etiqueta del boton para saber si el chat esta pausado o no
		if (label === 'Pausar') {
			cmp.set('v.isButtonActive', 'true');
			cmp.set('v.mostrarContador', false);
			hlp.clearAgentTimer(cmp);
			hlp.recuperarMensajesReanudar(cmp); //Dana New
			//Guardamos el momento de inicio de la pausa
			start = new Date();
			cmp.set('v.start', start);

			//Aumentamos en 1 el número de pausas
			let pauses = cmp.get('v.pauses');
			pauses++;
			cmp.set('v.pauses', pauses);

			//Crear la actividad de pausa
			let action = cmp.get('c.CreateActivityPausa');
			action.setParams({
				recordId: cmp.get('v.caseId'),
				cognitiveId: cmp.get('v.cognitiveId'),
				transcriptId: cmp.get('v.recordId'),
				nPausas: pauses
			});
			action.setCallback(this, response => {
				if (response.getState() === 'SUCCESS') {
					cmp.set('v.taskId', response.getReturnValue());
				}
			});
			$A.enqueueAction(action);
			//Start - US395380 - Incorporar carrusel de mensajes de espera de pausa de agente
			//Seteamos los contadores de tiempo para que vallan apareciendo en el orden correcto y como fueron pedidos.
			//eslint-disable-next-line @lwc/lwc/no-async-operation
			let timer1 = setTimeout(() => {
				hlp.mostrarAlerta(cmp, mensaje[0]);
				//eslint-disable-next-line @lwc/lwc/no-async-operation
				let timer2 = setTimeout(() => {
					hlp.mostrarAlerta(cmp, mensaje[1]);
					//eslint-disable-next-line @lwc/lwc/no-async-operation
					let timer3 = setTimeout(() => {
						hlp.mostrarAlerta(cmp, mensaje[2]);
						//eslint-disable-next-line @lwc/lwc/no-async-operation
						let timer4 = setInterval(() => hlp.mostrarAlerta(cmp, mensaje[1]), 60000);
						cmp.set('v.timer4', timer4);
					}, 75000);
					cmp.set('v.timer3', timer3);
				}, 75000);
				cmp.set('v.timer2', timer2);
			}, 1000);
			cmp.set('v.timer1', timer1);
			//END - US395380 - Incorporar carrusel de mensajes de espera de pausa de agente
			//Preparamos los datos para pasarle a cognitivo - PAUSAR
			data2 = {
				'responseType': 'PAUSAR',
				'accion': 'pausar'
			};
			//Cambiamos la etiqueta del botón
			evt.getSource().set('v.label', 'Retomar');
		} else {
			cmp.set('v.isButtonActive', 'false');
			cmp.set('v.mostrarContador', true);
			hlp.contadorFunction( cmp, hlp);
			//Paramos el intervalo

			clearTimeout(cmp.get('v.timer1'));
			clearTimeout(cmp.get('v.timer2'));
			clearTimeout(cmp.get('v.timer3'));
			clearInterval(cmp.get('v.timer4'));
			//Obtenemos los momentos de inicio y cierre
			start = cmp.get('v.start');
			end = new Date();
			//preparamos los datos para pasarle a cognitivo - RETOMAR
			data2 = {
				'responseType': 'PAUSAR',
				'accion': 'retomar'
			};
			//Reanudamos el chat y cambiamos la etiqueta del botón
			hlp.reaundarChat(cmp, hlp, start, end);
			evt.getSource().set('v.label', 'Pausar');
		}

		//Enviamos los datos preparados a cognitovo
		let type = 'AGENT_ACTION';
		let recordId = cmp.get('v.recordId');
		let conversationKit = cmp.find('conversationKit');
		recordId = recordId.substring(0, 15);
		let data = JSON.stringify(data2);
		conversationKit.sendCustomEvent({
			recordId: recordId,
			type: type,
			data: data
		}).then(() => {
			//console.log('OK');
		}, () => {
			//console.log('KO');
		});

	}).catch(error => {
		console.error("Error en validacionesBasicas:", error);
	});
	},

	onAgentSend: function( component, event, helper ) {
		let eventRecordId = event.getParam( "recordId" );
		let checkCurrentChat = helper.checkRecordId( component, eventRecordId );			
			if ( checkCurrentChat ) {
				helper.contadorFunction( component, helper);
			}
    },

	onNewMessage: function( component, event, helper ) {
		let eventRecordId = event.getParam( "recordId" );
		let checkCurrentChat = helper.checkRecordId( component, eventRecordId );			
			if ( checkCurrentChat ) {
         		helper.contadorFunction( component, helper );
			}
		 
    },
	onChatEnded: function( component, event, helper ) {
		let eventRecordId = event.getParam( "recordId" );
		let checkCurrentChat = helper.checkRecordId( component, eventRecordId );			
			if ( checkCurrentChat ) {
				helper.clearAgentTimer( component );
				component.set( "v.agentTimer", "" );
			}
		}

	
});