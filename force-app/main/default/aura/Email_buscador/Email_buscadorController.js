({
	init: function(component) {
		let getInfoCaso = component.get('c.getInfoCaso');
		getInfoCaso.setParams({'caseId': component.get('v.caseId')});
		getInfoCaso.setCallback(this, response => {
			if (response.getState() === 'SUCCESS') {
				component.set('v.organizacionCaso', response.getReturnValue().SEG_Organizacion__c);
				if(response.getReturnValue().SEG_Contactos_SOE_JSON__c != null && response.getReturnValue().SEG_Contactos_SOE_JSON__c != ''){
					component.set('v.esSOE', true);
				}
				if(response.getReturnValue().SEG_Contactos_OSN_JSON__c != null && response.getReturnValue().SEG_Contactos_OSN_JSON__c != ''){
					component.set('v.esOSN', true);
				}
			} else {
				//Mostrar error
				component.set('v.bError', true);
				component.set('v.sMensErr', 'Se ha producido un error al realizar la consulta.');
			}
		});
		$A.enqueueAction(getInfoCaso);
	},

	iniciarBusqueda: function(component, event, helper) {
		//Gestión visual secciones
		helper.resetErrores(component);
		helper.resetResultados(component);
		helper.resetResultadosApex(component);
		helper.resetCuentaSeleccionada(component);

		let getEsPropietarioCaso = component.get('c.getEsPropietarioObjeto');
		getEsPropietarioCaso.setParams({'recordId': component.get('v.caseId')});
		getEsPropietarioCaso.setCallback(this, response => {
			if (response.getState() === 'SUCCESS') {
				if (response.getReturnValue()) { //Es propietario
					//Buscar cuentas y contactos.
					helper.buscarDatosClientes(component);
				} else {
					component.set('v.bError', true);
					component.set('v.sMensErr', 'Debe ser propietario del registro para poder iniciar la identificación.');
				}
			} else {
				//Mostrar error
				component.set('v.bError', true);
				component.set('v.sMensErr', 'Se ha producido un error al realizar la consulta.');
			}
		});
		$A.enqueueAction(getEsPropietarioCaso);
	},

	lanzarBusqueda: function(component, event) {
		if (event.which === 13 && component.get('v.sBusqueda')) { //Intro
			$A.enqueueAction(component.get('c.iniciarBusqueda'));
		}
	},

	buscarContactosBoton: function(component, event, helper) {
		//Gestión visual secciones
		helper.resetErrores(component);
		helper.resetResultados(component);
		helper.resetResultadosApex(component);
		helper.resetCuentaSeleccionada(component);

		let getEsPropietarioCaso = component.get('c.getEsPropietarioObjeto');
		getEsPropietarioCaso.setParams({'recordId': component.get('v.caseId')});
		getEsPropietarioCaso.setCallback(this, response => {
			if (response.getState() === 'SUCCESS') {
				if (response.getReturnValue()) { //Es propietario
					//Buscar cuentas y contactos.
					helper.buscarContactosBoton(component, event);
					component.find('valorBusqueda').focus();
				} else {
					component.set('v.bError', true);
					component.set('v.sMensErr', 'Debe ser propietario del registro para poder iniciar la identificación.');
				}
			} else {
				//Mostrar error
				component.set('v.bError', true);
				component.set('v.sMensErr', 'Se ha producido un error al realizar la consulta.');
			}
		});
		$A.enqueueAction(getEsPropietarioCaso);
	},

	cambioValorBusqueda: function(component, event, helper) {
		helper.resetErrores(component);
		if (!component.get('v.sBusqueda')) {
			helper.resetResultados(component);
			helper.resetResultadosApex(component);
			helper.resetCuentaSeleccionada(component);
		}
	},

	refinarBusquedaContacto: function(component, event, helper) {
		helper.resetErrores(component);
		helper.resetResultados(component);
		helper.buscarDatosClientes(component);
	},

	handleChangeContact: function(component, event, helper) {
		helper.resetErrores(component);

		//Método para resetear la búsqueda de contactos.
		if (!component.get('v.valueSearch')) {
			helper.resetResultados(component);
			helper.resetResultadosApex(component);
			helper.buscarDatosClientes(component);
		}
	},

	valueSearchKeyContact: function(component, event, helper) {
		//Método para iniciar la búsqueda por INTRO.
		if (event.which === 13 && component.get('v.valueSearch') !== '') { //Intro
			helper.resetErrores(component);
			helper.resetResultados(component);
			helper.buscarDatosClientes(component);
		}
	},

	navegarOrigen: function(component, event) {
		let sObectEvent = $A.get('e.force:navigateToSObject');
		sObectEvent.setParams({'recordId': event.srcElement.name});
		sObectEvent.fire();
	},

	seleccionarPrincipal: function(component, event, helper) {
		let lstPara = component.get('v.contactPara');
		let lstCopia = component.get('v.contactCopia');
		let lstCCO = component.get('v.contactCCO');
		let idCaso = component.get('v.caseId');
		//Se blanquea la información de los contactos del SOE y OSN por si se hubiera pulsado anteriormente
		component.set('v.nombreContactoSOEOSN', '');
		component.set('v.emailContactoSOEOSN', '');

		let idDestinatarioPrincipal = event.currentTarget.name;
		let tipoDestinatarioPrincipal = event.currentTarget.dataset.tipodestinatarioprincipal;
		component.set('v.tipoDestinatarioPrincipal', tipoDestinatarioPrincipal);
		if (tipoDestinatarioPrincipal === 'Grupo colaborador') {
			component.set('v.nombreGrupoColaboradorPrincipal', event.currentTarget.dataset.nombregrupocolabprincipal);
		}
		
		let cmpEvent = component.getEvent('cargarEvento');
		cmpEvent.setParams({retContact: idDestinatarioPrincipal});
		cmpEvent.fire();

		let getDatosDestinatario = component.get('c.getDatosDestinatario');
		getDatosDestinatario.setParam('recordId', idDestinatarioPrincipal);
		getDatosDestinatario.setCallback(this, response => {
			if (response.getState() === 'SUCCESS') {
				let values = [];
				let result = response.getReturnValue();
				for (let key in result) {
					if (Object.prototype.hasOwnProperty.call(result, key)) {
						values.push({label: result[key], value: key});
						component.set('v.contactPara', result[key]);
					}
				}
				component.set('v.dataPara', values);
				component.set('v.mostrarResultados', false);
			} else if (response.getState() === 'ERROR') {
				let errors = response.getError();
				helper.mostrarToast('error', 'Error recuperando datos del destinatario', errors[0].message);
				console.error(JSON.stringify(errors));
			}
		});
		$A.enqueueAction(getDatosDestinatario);

		let getColaboradores = component.get('c.colaboradoresPara');
		getColaboradores.setParam('idGrupo', idDestinatarioPrincipal);
		getColaboradores.setCallback(this, response => {
			if (response.getState() === 'SUCCESS') {
				let result = response.getReturnValue();
				for (let i = 0; result.length > i; i++) {
					if (result[i].CC_Para_CC__c === 'Para') {
						lstPara.push(' ' + result[i].CC_Email__c);
						component.set('v.contactPara', lstPara);
						let cmpEventpara = component.getEvent('cargarListaPara');
						cmpEventpara.setParams({'lstGrupoPara': lstPara});
						cmpEventpara.fire();
					} else if (result[i].CC_Para_CC__c === 'CC') {
						lstCopia.push(' ' + result[i].CC_Email__c);
						component.set('v.contactCopia', lstCopia);
					} else if (result[i].CC_Para_CC__c === 'CCO') {
						lstCCO.push(' ' + result[i].CC_Email__c);
						component.set('v.contactCCO', lstCCO);
					}
				}
			} else {
				console.error('No es un grupo colaborador');
			}
		});
		$A.enqueueAction(getColaboradores);

		let canalComunicacionPara = component.get('c.canalComunicacionPara');
		canalComunicacionPara.setParams({idCaso: idCaso, idContacto: idDestinatarioPrincipal});
		canalComunicacionPara.setCallback(this, response => {
			if (response.getState() === 'SUCCESS') {
				let retorno = response.getReturnValue();
				retorno.Para.forEach(direccion => lstPara.push(' ' + direccion));
				retorno.Cc.forEach(direccion => lstCopia.push(' ' + direccion));
				retorno.Cco.forEach(direccion => lstCCO.push(' ' + direccion));

				component.set('v.contactPara', lstPara);
				component.set('v.contactCopia', lstCopia);
				component.set('v.contactCCO', lstCCO);

				helper.logicaSeleccionarNuevo(component);
			} else if (response.getState() === 'ERROR') {
				let errors = response.getError();
				helper.mostrarToast('error', 'Error recuperando canales de comunicación', errors[0].message);
				console.error(JSON.stringify(errors));
			}
		});
		$A.enqueueAction(canalComunicacionPara);
	},

	//Funcionalidad para cuando se selecciona un contacto principal de SOE u OSN
	seleccionarPrincipalSOE_OSN: function(component, event, helper) {
		let lstPara = [];
        var nombreContact = event.currentTarget.dataset.nombre;
        var apellidoContact = event.currentTarget.dataset.apellido;
		var contactoPpal = event.currentTarget.name;
		lstPara.push(contactoPpal);
		component.set('v.contactPara', lstPara);
		component.set('v.nombreContactoSOEOSN', nombreContact + ' ' + apellidoContact);
		component.set('v.emailContactoSOEOSN', contactoPpal);

		helper.logicaSeleccionarNuevo(component);
	},

	//ELB: Añadida funcion de buscar Canales de comunicación y eliminar duplicados.
	seleccionarPara: function(component, event, helper) {
		let idBoton = event.getSource().getLocalId();
		component.set('v.botonPulsado', idBoton);
		let emailPara = event.getSource().get('v.name');
		let noCanales = false;
		let listaValoresPara = null;
		let listaValoresCc = null;
		let listaValoresCco = null;
		let listaEmailComprobadaPara = [];
		let listaEmailComprobadaCc = null;
		let listaEmailComprobadaCco = null;

		//Añadimos los correos en el array
		if (component.get('v.contactPara')) {
			listaValoresPara = component.get('v.contactPara');
		}
		if (component.get('v.contactCopia')) {
			listaValoresCc = component.get('v.contactCopia');
		}
		if (component.get('v.contactCCO')) {
			listaValoresCco = component.get('v.contactCCO');
		}

		if (emailPara != null && emailPara !== 'Sin correo') {
			let emailsParaCanales = component.get('c.getCanalesComunicacion');
			emailsParaCanales.setParams({'caseId': component.get('v.caseId'), 'emails': emailPara, 'noCanales': noCanales, 'idBotonEntrada': idBoton});
			emailsParaCanales.setCallback(this, response => {
				let listaEmailFinal = response.getReturnValue();
				let emailsCanalesComPara = listaEmailFinal.listadoPara;
				let emailsCanalesComCc = listaEmailFinal.listadoCc;
				let emailsCanalesComCco = listaEmailFinal.listadoCco;
				let arrayPara = [];
				let arrayCc = [];
				let arrayCco = [];

				if (emailsCanalesComPara !== null) {
					//Trabajamos con las listas para el Para
					for (let i = 0; i < emailsCanalesComPara.length; i++) {
						arrayPara.push(emailsCanalesComPara[i].replace(/ /g, ''));
					}
					for (let i = 0; i < arrayPara.length; i++) {
						if (listaEmailComprobadaPara.length === 0) {
							listaEmailComprobadaPara.push(arrayPara[i]);
						} else {
							listaEmailComprobadaPara.push(' ' + arrayPara[i]);
						}
					}
					if (listaEmailComprobadaPara != null) {
						let listaFinalMailsPara = listaValoresPara.concat(listaEmailComprobadaPara);
						let arrayNoDuplicatesPara = [];
						let arrayEmailsPara = [];

						for (let i = 0; i < Object.keys(listaFinalMailsPara).length; i++) {
							arrayEmailsPara.push(listaFinalMailsPara[i].replace(/ /g, ''));
						}
						arrayNoDuplicatesPara = [...new Set(arrayEmailsPara)];
						let listaFinalLimpiaPara = [];
						for (let i = 0; i < arrayNoDuplicatesPara.length; i++) {
							if (listaFinalLimpiaPara.length === 0) {
								listaFinalLimpiaPara.push(arrayNoDuplicatesPara[i]);
							} else {
								listaFinalLimpiaPara.push(' ' + arrayNoDuplicatesPara[i]);
							}
						}
						component.set('v.contactPara', listaFinalLimpiaPara);
					}
				}

				if (emailsCanalesComCc !== null) {
					//Trabajamos con las listas para el Cc
					for (let i = 0; i < emailsCanalesComCc.length; i++) {
						if (arrayCc.length === 0) {
							arrayCc.push(emailsCanalesComCc[i].replace(/ /g, ''));
						} else {
							arrayCc.push(emailsCanalesComCc[i].replace(/ /g, ''));
						}
					}
					for (let i = 0; i < arrayCc.length; i++) {
						if (listaValoresCc == null || typeof listaValoresCc === 'undefined' || Object.keys(listaValoresCc).length === 0) {
							if (listaEmailComprobadaCc === null) {
								listaEmailComprobadaCc = [];
								listaEmailComprobadaCc.push(arrayCc[i]);
							} else {
								listaEmailComprobadaCc.push(' ' + arrayCc[i]);
							}
						} else {
							if (listaEmailComprobadaCc == null) {
								listaEmailComprobadaCc = [];
								listaEmailComprobadaCc.push(' ' + arrayCc[i]);
							} else {
								listaEmailComprobadaCc.push(' ' + arrayCc[i]);
							}
						}
					}
					if (listaEmailComprobadaCc != null) {
						let listaFinalMailsCc = listaValoresCc.concat(listaEmailComprobadaCc);
						let arrayNoDuplicatesCc = [];
						let arrayEmailsCc = [];

						for (let i = 0; i < Object.keys(listaFinalMailsCc).length; i++) {
							let s = listaFinalMailsCc[i].replace(/ /g, '');
							arrayEmailsCc.push(s);
						}
						arrayNoDuplicatesCc = [...new Set(arrayEmailsCc)];
						let listaFinalLimpiaCc = [];
						for (let i = 0; i < arrayNoDuplicatesCc.length; i++) {
							if (listaFinalLimpiaCc.length === 0) {
								listaFinalLimpiaCc.push(arrayNoDuplicatesCc[i]);
							} else {
								listaFinalLimpiaCc.push(' ' + arrayNoDuplicatesCc[i]);
							}
						}
						component.set('v.contactCopia', listaFinalLimpiaCc);
					}
				}

				if (emailsCanalesComCco != null) {
					//Trabajamos con las listas para el Cco
					for (let i = 0; i < emailsCanalesComCco.length; i++) {
						if (arrayCco.length === 0) {
							arrayCco.push(emailsCanalesComCco[i].replace(/ /g, ''));
						} else {
							arrayCco.push(emailsCanalesComCco[i].replace(/ /g, ''));
						}
					}
					for (let i = 0; i < arrayCco.length; i++) {
						if (listaValoresCco == null || typeof listaValoresCco === 'undefined' || Object.keys(listaValoresCco).length === 0) {
							if (listaEmailComprobadaCco == null) {
								listaEmailComprobadaCco = [];
								listaEmailComprobadaCco.push(arrayCco[i]);
							} else {
								listaEmailComprobadaCco.push(' ' + arrayCco[i]);
							}
						} else {
							if (listaEmailComprobadaCco == null) {
								listaEmailComprobadaCco = [];
								listaEmailComprobadaCco.push(' ' + arrayCco[i]);
							} else {
								listaEmailComprobadaCco.push(' ' + arrayCco[i]);
							}
						}
					}
					if (listaEmailComprobadaCco != null) {
						let listaFinalMailsCco = listaValoresCco.concat(listaEmailComprobadaCco);
						let arrayNoDuplicatesCco = [];
						let arrayEmailsCco = [];

						for (let i = 0; i < Object.keys(listaFinalMailsCco).length; i++) {
							arrayEmailsCco.push(listaFinalMailsCco[i].replace(/ /g, ''));
						}
						arrayNoDuplicatesCco = [...new Set(arrayEmailsCco)];
						let listaFinalLimpiaCco = [];
						for (let i = 0; i < arrayNoDuplicatesCco.length; i++) {
							if (listaFinalLimpiaCco.length === 0) {
								listaFinalLimpiaCco.push(arrayNoDuplicatesCco[i]);
							} else {
								listaFinalLimpiaCco.push(' ' + arrayNoDuplicatesCco[i]);
							}
						}
						component.set('v.contactCCO', listaFinalLimpiaCco);
					}
				} else {
					component.set('v.contactPara', listaValoresPara);
					component.set('v.contactCC', listaValoresCc);
					component.set('v.contactCCO', listaValoresCco);

					helper.mostrarToastQuick('error', 'Error', 'Por favor, introduzca un email valido');
				}
			});
			$A.enqueueAction(emailsParaCanales);
		}
	},

	//ELB: Añadida funcion de buscar Canales de comunicación y eliminar duplicados.
	seleccionarCC: function(component, event, helper) {
		let emailCC = event.getSource().get('v.name');
		let idBoton = event.getSource().getLocalId();
		component.set('v.botonPulsado', idBoton);
		let listaValoresCc;
		let listaEmailComprobadaCc = null;

		if (typeof component.get('v.contactCopia') === 'undefined') {
			listaValoresCc = null;
		} else {
			listaValoresCc = component.get('v.contactCopia');
		}


		//Añadimos los correos en el array
		if (emailCC != null && emailCC !== 'Sin correo') {
			let getCanalesComunicacion = component.get('c.getCanalesComunicacion');
			getCanalesComunicacion.setParams({
				caseId: component.get('v.caseId'),
				emails: emailCC,
				noCanales: true,
				idBotonEntrada: idBoton
			});
			getCanalesComunicacion.setCallback(this, response => {
				let respuesta = response.getReturnValue();
				let emailsCanalesComCc = respuesta.listadoCc;
				let arrayCc = [];

				if (emailsCanalesComCc != null) {
					//Trabajamos con las listas para el Cc
					for (let i = 0; i < emailsCanalesComCc.length; i++) {
						if (arrayCc.length === 0) {
							arrayCc.push(emailsCanalesComCc[i].replace(/ /g, ''));
						} else {
							arrayCc.push(emailsCanalesComCc[i].replace(/ /g, ''));
						}
					}
					for (let i = 0; i < arrayCc.length; i++) {
						if (listaValoresCc == null || typeof listaValoresCc === 'undefined' || Object.keys(listaValoresCc).length === 0) {
							if (listaEmailComprobadaCc == null) {
								listaEmailComprobadaCc = [];
								listaEmailComprobadaCc.push(arrayCc[i]);
							} else {
								listaEmailComprobadaCc.push(' ' + arrayCc[i]);
							}
						} else {
							if (listaEmailComprobadaCc == null) {
								listaEmailComprobadaCc = [];
								listaEmailComprobadaCc.push(' ' + arrayCc[i]);
							} else {
								listaEmailComprobadaCc.push(' ' + arrayCc[i]);
							}
						}
					}
					if (listaEmailComprobadaCc != null) {
						let listaFinalMailsCc;
						if (listaValoresCc == null) {
							listaFinalMailsCc = listaEmailComprobadaCc;
						} else {
							listaFinalMailsCc = listaValoresCc.concat(listaEmailComprobadaCc);
						}

						let arrayNoDuplicatesCc = [];
						let arrayEmailsCc = [];

						for (let i = 0; i < Object.keys(listaFinalMailsCc).length; i++) {
							let string = listaFinalMailsCc[i].replace(/ /g, '');
							arrayEmailsCc.push(string);
						}
						arrayNoDuplicatesCc = [...new Set(arrayEmailsCc)];
						let listaFinalLimpiaCc = [];
						for (let i = 0; i < arrayNoDuplicatesCc.length; i++) {
							if (listaFinalLimpiaCc.length === 0) {
								listaFinalLimpiaCc.push(arrayNoDuplicatesCc[i]);
							} else {
								listaFinalLimpiaCc.push(' ' + arrayNoDuplicatesCc[i]);
							}
						}
						component.set('v.contactCopia', listaFinalLimpiaCc);
					} else {
						component.set('v.contactCopia', listaValoresCc);
						helper.mostrarToastQuick('error', 'Error añadiendo destinatario', 'Por favor, introduzca un email valido.');
					}
				}
			});
			$A.enqueueAction(getCanalesComunicacion);
		}
	},

	//ELB: Añadida funcion de buscar Canales de comunicación y eliminar duplicados.
	seleccionarCCO: function(component, event) {
		let emailCCO = event.getSource().get('v.name');
		let noCanales = true;
		let idBoton = event.getSource().getLocalId();
		component.set('v.botonPulsado', idBoton);
		let listaValoresCco;
		let toastEvent = $A.get('e.force:showToast');
		let listaEmailComprobadaCco = null;

		if (typeof component.get('v.contactCCO') === 'undefined') {
			listaValoresCco = null;
		} else {
			listaValoresCco = component.get('v.contactCCO');
		}

		//Añadimos los correos en el array
		if (emailCCO && emailCCO !== 'Sin correo') {
			let getCanalesComunicacion = component.get('c.getCanalesComunicacion');
			getCanalesComunicacion.setParams({'caseId': component.get('v.caseId'), 'emails': emailCCO, 'noCanales': noCanales, 'idBotonEntrada': idBoton});
			getCanalesComunicacion.setCallback(this, response => {
				let emailsCanalesComCco = response.getReturnValue().listadoCco;
				let arrayCco = [];

				if (emailsCanalesComCco != null) {
					//Trabajamos con las listas para el Cco
					for (let i = 0; i < emailsCanalesComCco.length; i++) {
						arrayCco.push(emailsCanalesComCco[i].replace(/ /g, ''));
					}

					for (let i = 0; i < arrayCco.length; i++) {
						if (listaValoresCco == null || typeof listaValoresCco === 'undefined' || Object.keys(listaValoresCco).length === 0) {
							if (listaEmailComprobadaCco == null) {
								listaEmailComprobadaCco = [];
								listaEmailComprobadaCco.push(arrayCco[i]);
							} else {
								listaEmailComprobadaCco.push(' ' + arrayCco[i]);
							}
						} else {
							if (listaEmailComprobadaCco == null) {
								listaEmailComprobadaCco = [];
								listaEmailComprobadaCco.push(' ' + arrayCco[i]);
							} else {
								listaEmailComprobadaCco.push(' ' + arrayCco[i]);
							}
						}
					}
					if (listaEmailComprobadaCco != null) {
						let listaFinalMailsCco;
						if (listaValoresCco == null) {
							listaFinalMailsCco = listaEmailComprobadaCco;
						} else {
							listaFinalMailsCco = listaValoresCco.concat(listaEmailComprobadaCco);
						}

						let arrayNoDuplicatesCco = [];
						let arrayEmailsCco = [];

						for (let i = 0; i < Object.keys(listaFinalMailsCco).length; i++) {
							arrayEmailsCco.push(listaFinalMailsCco[i].replace(/ /g, ''));
						}

						arrayNoDuplicatesCco = [...new Set(arrayEmailsCco)];
						let listaFinalLimpiaCco = [];
						for (let i = 0; i < arrayNoDuplicatesCco.length; i++) {
							if (listaFinalLimpiaCco.length === 0) {
								listaFinalLimpiaCco.push(arrayNoDuplicatesCco[i]);
							} else {
								listaFinalLimpiaCco.push(' ' + arrayNoDuplicatesCco[i]);
							}
						}
						component.set('v.contactCCO', listaFinalLimpiaCco);
					} else {
						component.set('v.contactCCO', listaValoresCco);
						toastEvent.setParams({
							title: 'Error',
							message: 'Por favor, introduzca un email valido.',
							duration: '50',
							type: 'error',
							mode: 'dismissible',
						});
						toastEvent.fire();
					}
				}
			});
			$A.enqueueAction(getCanalesComunicacion);
		}
	},

	seleccionarGrupo: function(component, event) {
		let grupoId = event.getSource().get('v.name');
		let lstPara = component.get('v.contactPara');
		let lstCopia = component.get('v.contactCopia');
		let lstCCO = component.get('v.contactCCO');
		let idCase = component.get('v.caseId');
		var arrayNoDuplicatesPara = [];
		var arrayNoDuplicatesCc = [];
		var arrayNoDuplicatesCco = [];

		let getColaboradores = component.get('c.colaboradoresPara');
		getColaboradores.setParam('idGrupo', grupoId);
		getColaboradores.setCallback(this, response => {
			if (response.getState() === 'SUCCESS') {
				let result = response.getReturnValue();
				for (let i = 0; result.length > i; i++) {
					if (result[i].CC_Para_CC__c === 'Para') {
						lstPara.push(' ' + result[i].CC_Email__c);
						arrayNoDuplicatesPara = [...new Set(lstPara)];
						//component.set('v.contactPara', arrayNoDuplicatesPara);
					} else if (result[i].CC_Para_CC__c === 'CC') {
						lstCopia.push(' ' + result[i].CC_Email__c);
						arrayNoDuplicatesCc = [...new Set(lstCopia)];
						//component.set('v.contactCopia', arrayNoDuplicatesCc);
					} else if (result[i].CC_Para_CC__c === 'CCO') {
						lstCCO.push(' ' + result[i].CC_Email__c);
						arrayNoDuplicatesCco = [...new Set(lstCCO)];
						//component.set('v.contactCCO', arrayNoDuplicatesCco);
					}
				}
				
				let getCanales = component.get('c.getCanalesComunicacionGrupo');
				getCanales.setParams({'idGrupo': grupoId, 'idCaso': idCase});
				getCanales.setCallback(this, response => {
					if (response.getState() === 'SUCCESS') {
						let result = response.getReturnValue();
						let emailsCanalesComPara = result.listadoPara;
						let emailsCanalesComCc = result.listadoCc;
						let emailsCanalesComCco = result.listadoCco;
						let listaEmailComprobadaPara = [];
						let listaEmailComprobadaCc = [];
						let listaEmailComprobadaCco= [];
						let listaValoresPara = component.get('v.contactPara').concat(arrayNoDuplicatesPara);
						let listaValoresCc = component.get('v.contactCopia').concat(arrayNoDuplicatesCc);
						let listaValoresCco = component.get('v.contactCCO').concat(arrayNoDuplicatesCco);
						let listafinalPara = [];
						let listafinalCC = [];
						let listafinalCCO = [];
						let arrayPara = [];
						let arrayCc = [];
						let arrayCco = [];
						arrayNoDuplicatesPara = [];
						arrayNoDuplicatesCc = [];
						arrayNoDuplicatesCco = [];

						//añadir valores al para.
						if (emailsCanalesComPara === undefined || emailsCanalesComPara == null){
							listafinalPara = listaValoresPara;
					}
						else{
							listafinalPara = listaValoresPara.concat(emailsCanalesComPara);
				}
						for (let i = 0; i < listafinalPara.length; i++) {
							arrayPara.push(listafinalPara[i].replace(/ /g, ''));
						}
						arrayNoDuplicatesPara = [...new Set(arrayPara)];
						for (let i = 0; i < arrayNoDuplicatesPara.length; i++) {
							if (listaEmailComprobadaPara.length === 0) {
								listaEmailComprobadaPara.push(arrayNoDuplicatesPara[i]);
							} else {
								listaEmailComprobadaPara.push(' ' + arrayNoDuplicatesPara[i]);
							}
						}
						component.set('v.contactPara',listaEmailComprobadaPara);

						//añadir valores al cc.
						if (emailsCanalesComCc === undefined || emailsCanalesComCc == null){
							listafinalCC = listaValoresCc;
						}
						else{
							listafinalCC = listaValoresCc.concat(emailsCanalesComCc);
						}

						for (let i = 0; i < listafinalCC.length; i++) {
							arrayCc.push(listafinalCC[i].replace(/ /g, ''));
						}
						arrayNoDuplicatesCc = [...new Set(arrayCc)];
						for (let i = 0; i < arrayNoDuplicatesCc.length; i++) {
							if (listaEmailComprobadaCc.length === 0) {
								listaEmailComprobadaCc.push(arrayNoDuplicatesCc[i]);
							} else {
								listaEmailComprobadaCc.push(' ' + arrayNoDuplicatesCc[i]);
							}
						}
						component.set('v.contactCopia',listaEmailComprobadaCc);

						//añadir valores al cco.
						if (emailsCanalesComCco === undefined || emailsCanalesComCco == null){
							listafinalCCO = listaValoresCco;
						}
						else {
							listafinalCCO = listaValoresCco.concat(emailsCanalesComCco);		
			}

						for (let i = 0; i < listafinalCCO.length; i++) {
							arrayCco.push(listafinalCCO[i].replace(/ /g, ''));
						}
						arrayNoDuplicatesCco = [...new Set(arrayCco)];
						for (let i = 0; i < arrayNoDuplicatesCco.length; i++) {
							if (listaEmailComprobadaCco.length === 0) {
								listaEmailComprobadaCco.push(arrayNoDuplicatesCco[i]);
							} else {
								listaEmailComprobadaCco.push(' ' + arrayNoDuplicatesCco[i]);
							}
						}
						component.set('v.contactCCO',listaEmailComprobadaCco);
					}
				});
				$A.enqueueAction(getCanales);
			}
		});
		$A.enqueueAction(getColaboradores);
	}
});