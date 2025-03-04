({
	init: function(component) {
		let checkPSResponsable = component.get('c.checkPSResponsable');
		checkPSResponsable.setCallback(this, response => {
			if (response.getState() === 'SUCCESS') {
				const retorno = response.getReturnValue();
				component.set('v.esResponsable', retorno.esResponsable);
				component.set('v.esAdministrador', retorno.esAdministrador);

				const oportunidad = component.get('v.oportunidad');
				const botonesActivos = component.get('v.botonesActivos');
				botonesActivos.botonReactivarActivo = oportunidad.IsClosed && (retorno.esResponsable || ['Hipoteca', 'Acción comercial'].includes(oportunidad.RecordType.Name));
				botonesActivos.botonAsignacionAutoActivo = retorno.esAdministrador && ['Nueva', 'Activa'].includes(oportunidad.CSBD_Estado__c);
				component.set('v.botonesActivos', botonesActivos);
			}
		});
		window.setTimeout($A.getCallback(() => $A.enqueueAction(checkPSResponsable)), 3000);
	},

	botonRefrescarBotoneraOnclick: function(component, event) {
		component.find('opportunityData').reloadRecord(true);
		const botonRefrescarBotonera = event.getSource();
		$A.util.addClass(botonRefrescarBotonera, 'rotar');
		window.setTimeout($A.getCallback(() => $A.util.removeClass(event.currentTarget, 'rotar')), 470);
	},

	recordUpdated: function(component, event, helper) {
		if (event.getParams().changeType === 'CHANGED') {
			//const camposRelevantes = [
			//'OwnerId', 'IsClosed', 'CSBD_Estado__c', 'CSBD_Empresa_Proveedora__c', 'CSBD_Contact__c', 'AccountId',
			//'CSBD_No_Identificado__c', 'CSBD_Fecha_Cita__c', 'CSBD_Fecha_Firma__c', 'CSBD_Familia_Producto__c'
			//];
			//if (Object.keys(event.getParams().changedFields).some(campo => camposRelevantes.includes(campo))) {
			window.setTimeout($A.getCallback(() => component.find('opportunityData').reloadRecord(false)), 0);
			//}

		} else if (event.getParams().changeType === 'LOADED') {
			const ownerId = component.get('v.oportunidad').OwnerId;
			if (ownerId !== $A.get('$SObjectType.CurrentUser.Id')) {
				//actualizar owner oportunidad desde omnichannel
				let actualizarOwnerOportunidadApex = component.get('c.actualizarOwnerOportunidad');
				actualizarOwnerOportunidadApex.setParams({idOpportunity: component.get('v.recordId'), ownerId});
				actualizarOwnerOportunidadApex.setCallback(this, response => {
					if (response.getState() === 'SUCCESS' && response.getReturnValue()) {
						component.find('opportunityData').reloadRecord(true);
						//$A.get('e.force:refreshView').fire();
					}
				});
				$A.enqueueAction(actualizarOwnerOportunidadApex);
			}
			helper.refrescarBotones(component);

		} else if (event.getParams().changeType === 'ERROR') {
			console.error(component.get('v.errorLds'));
			helper.mostrarToast('Problema recuperando los datos de la oportunidad', 'No ha sido posible recuperar los datos de la oportunidad: ' + component.get('v.errorLds'), 'error');
		}
		component.set('v.mostrarBotones', true);
	},

	trasladoImagin: function(component, event, helper) {
		let trasladoImaginBank = component.get('c.trasladoImaginBank');
		trasladoImaginBank.setParams({
			idOportunidad: component.get('v.recordId'),
			nombreEtapaVentas: 'Rechazada',
			resolucion: 'Traspasada a Imagin'
		});
		trasladoImaginBank.setCallback(this, response => {
			if (response.getState() === 'SUCCESS') {
				helper.mostrarToast('Oportunidad traspasada a Imagin', 'La oportunidad ' + component.get('v.oportunidad.CSBD_Identificador__c') + ' ha sido traspasada a Imagin mediante correo electrónico.', 'success');
				component.find('opportunityData').reloadRecord(true);
				//$A.get('e.force:refreshView').fire();
			} else if (response.getState() === 'ERROR') {
				helper.mostrarToast('Problema realizando el traspaso a Imagin', JSON.stringify(trasladoImaginBank.getError()[0].message), 'error');
			}
		});
		$A.enqueueAction(trasladoImaginBank);
	},

	copiarNIF: function(component, event, helper) {
		let oportunidad = component.get('v.oportunidad');
		if (oportunidad.Account.CC_Numero_Documento__c) {
			helper.copiarTextoAlPortapapeles(oportunidad.Account.CC_Numero_Documento__c, 'Se ha copiado el NIF ' + oportunidad.Account.CC_Numero_Documento__c + ' (' + oportunidad.Account.Name + ') al portapapeles');
		} else {
			helper.mostrarToast('El NIF del cliente no está informado', 'La cuenta no tiene el número de documento de identidad informado', 'info');
		}
	},

	solicitudesAnteriores: function(component, event, helper) {
		//Muestra la información retornada mediante un Toast
		helper.apex(component, 'numeroOportunidadesAnteriores', {
			idAccount: component.get('v.oportunidad.AccountId'),
			recordTypeDevName: component.get('v.oportunidad.RecordType.DeveloperName')
		}).then(retorno => helper.mostrarToastSticky(retorno.titulo, retorno.mensaje, 'info'))
		.catch(textoError => helper.mostrarToast('Error', textoError, 'error'));
	},

	botonAmpliarVencimiento: function(component, event, helper) {
		component.set('v.cargarModales', true);
		component.find('prorrogaFechaAltaVencimientoContinuar').set('v.disabled', false);
		let fechaVencimiento = new Date(component.get('v.oportunidad.CSBD_Fecha_vencimiento_alta__c'));
		fechaVencimiento.setMonth(fechaVencimiento.getMonth() + 1);
		component.set('v.fechaAmpliarVencimiento', fechaVencimiento.toISOString());
		$A.util.addClass(component.find('modalProrrogaFechaAltaVencimiento'), 'slds-fade-in-open');
		$A.util.addClass(component.find('modalBackdrop'), 'slds-backdrop_open');
		helper.seleccionarControl(component, 'prorrogaFechaAltaVencimiento', 50);
	},

	abrirModalEnviarCorreo: function(component, event, helper) {
		//Refrescar datos para recuperar CSBD_Email_Solicitud__c si se ha identificado el cliente una vez cargado el Aura
		component.find('opportunityData').reloadRecord();

		if (!component.get('v.oportunidad.CSBD_Email_Solicitud__c')) {
			helper.mostrarToast('Debe informar el destinatario', 'Debe informar una dirección de correo en el campo "Email solicitud" de la oportunidad.', 'error');
		} else {
			//Recuperar carpetas de idioma
			let subdirectoriosOperativas = component.get('c.subdirectorios');
			subdirectoriosOperativas.setParam('rutaDevName', 'CSBD_Correo_Electronico');
			subdirectoriosOperativas.setCallback(this, response => {
				if (response.getState() === 'SUCCESS') {
					//Las opciones del desplegable de idiomas son los subdirectorios recuperados
					let listaIdiomas = [];
					response.getReturnValue().forEach(subdirectorio => listaIdiomas.push({'value': subdirectorio.DeveloperName, 'label': subdirectorio.Name}));
					component.set('v.enviarCorreoIdiomas', listaIdiomas);

					//La opción preseleccionada es el idioma de la oportunidad (o 'Castellano' por defecto)
					let idiomaOportunidad = listaIdiomas.find(idioma => idioma.label === component.get('v.oportunidad.CSBD_Idioma_Solicitud__c'));
					component.set('v.enviarCorreoIdioma', idiomaOportunidad.value ? idiomaOportunidad.value : 'CSBD_Operativas_SolInfo_ESP');

					//Recuperar tratamientos disponibles para el idioma pre-seleccionado
					$A.enqueueAction(component.get('c.seleccionaEnviarCorreoIdioma'));
				}
			});
			$A.enqueueAction(subdirectoriosOperativas);

			component.set('v.cargarModales', true);
			$A.util.addClass(component.find('modalEnviarCorreo'), 'slds-fade-in-open');
			$A.util.addClass(component.find('modalBackdrop'), 'slds-backdrop_open');
		}
	},

	seleccionaEnviarCorreoIdioma: function(component, event, helper) {
		component.set('v.enviarCorreoPlantilla', '');
		let subdirectoriosIdioma = component.get('c.subdirectorios');
		subdirectoriosIdioma.setParam('rutaDevName', component.find('inputEnviarCorreoIdioma').get('v.value'));
		subdirectoriosIdioma.setCallback(this, response => {
			if (response.getState() === 'SUCCESS') {
				let listaTratamientos = [];
				response.getReturnValue().forEach(element => {
					if (element.Name === 'Formal' || element.Name === 'Informal' || element.Name === 'Genérico') {
						listaTratamientos.push({'value': element.DeveloperName, 'label': element.Name});
					}
				});
				component.set('v.enviarCorreoTratamientos', listaTratamientos);
				if (listaTratamientos.some(element => element.label === 'Informal')) {
					//Por defecto se selecciona el tratamiento "Informal" si este existe
					component.find('inputEnviarCorreoTratamiento').set('v.value', listaTratamientos.find(element => element.label === 'Informal').value);
					$A.enqueueAction(component.get('c.seleccionaEnviarCorreoTratamiento'));
				} else if (listaTratamientos.length === 1) {
					//Hay un único tratamiento para el idioma seleccionado
					component.find('inputEnviarCorreoTratamiento').set('v.value', listaTratamientos[0].value);
					$A.enqueueAction(component.get('c.seleccionaEnviarCorreoTratamiento'));
				} else {
					//Foco en el deplegable de tratamientos
					helper.seleccionarControl(component, 'inputEnviarCorreoTratamiento', 50);
				}
			}
		});
		$A.enqueueAction(subdirectoriosIdioma);
	},

	seleccionaEnviarCorreoTratamiento: function(component, event, helper) {
		component.set('v.enviarCorreoPlantilla', '');
		let plantillas = component.get('c.plantillas');
		plantillas.setParam('rutaDevName', component.find('inputEnviarCorreoTratamiento').get('v.value'));
		plantillas.setCallback(this, response => {
			if (response.getState() === 'SUCCESS') {
				let listaPlantillas = [];
				response.getReturnValue().forEach(element => listaPlantillas.push({'value': element.DeveloperName, 'label': element.Name}));
				component.set('v.enviarCorreoPlantillas', listaPlantillas);
				helper.seleccionarControl(component, 'inputEnviarCorreoPlantilla', 50);
			}
		});
		$A.enqueueAction(plantillas);
	},

	cerrarModalEnviarCorreo: function(component) {
		$A.util.removeClass(component.find('modalEnviarCorreo'), 'slds-fade-in-open');
		$A.util.removeClass(component.find('modalBackdrop'), 'slds-backdrop_open');
		component.set('v.cargarModales', false);
	},

	togglePendienteClienteChange: function(component, event, helper) {
		if (component.find('togglePendienteCliente').get('v.checked')
		&& component.get('v.oportunidad.RecordType.DeveloperName') === 'CSBD_Prestamo'
		&& !component.get('v.oportunidad.CSBD_Telefono_Solicitud__c')) {
			helper.mostrarToast('No se enviarán reclamaciones por SMS', 'Las reclamaciones automáticas por SMS no se enviarán al cliente si no informa el campo "Teléfono solicitud" de la oportunidad.', 'warning');
		}
	},

	generarBorradorCorreo: function(component, event, helper) {
		//Se guarda el nombre de la plantilla para poder enviar el correo, con la plantilla correspondiente.
		let developerNamePlantilla = component.find('inputEnviarCorreoPlantilla').get('v.value');
		let prepararOportunidadParaEnvioCorreo = component.get('c.prepararOportunidadParaEnvioCorreo');
		prepararOportunidadParaEnvioCorreo.setParams({
			idOpportunity: component.get('v.recordId'),
			developerNamePlantilla: developerNamePlantilla,
			informarReferenciaCorreo: true,
			pendienteCliente: component.find('togglePendienteCliente').get('v.checked')
		});
		prepararOportunidadParaEnvioCorreo.setCallback(this, response => {
			if (response.getState() === 'SUCCESS') {
				//Invocar quick action para abrir el editor de correo
				let actionAPI = component.find('quickActionAPI');
				let argsAction = {
					actionName: 'Opportunity.CSBD_Email',
					targetFields: {
						ToAddress: {value: component.get('v.oportunidad.CSBD_Email_Solicitud__c')},
						CcAddress: {value: ''}, BccAddress: {value: ''},
						Subject: {value: response.getReturnValue().Subject},
						HtmlBody: {value: response.getReturnValue().HtmlValue}
					}
				};
				actionAPI.selectAction(argsAction)
				.then(() => actionAPI.setActionFieldValues(argsAction))
				.catch(e => {
					if (e.errors) {
						helper.mostrarToast('Seleccione la pestaña "Actividades/Correos"', 'El editor de correos debe estar visible para poder generar el borrador.	', 'info');
						console.error('Error preparando el borrador del correo saliente.\n' + e.errors);
					}
				});
			}
		});
		$A.enqueueAction(prepararOportunidadParaEnvioCorreo);
		$A.enqueueAction(component.get('c.cerrarModalEnviarCorreo'));
	},

	abrirModalEnviarNotificacion: function(component, event, helper) {
		component.set('v.cargarModales', true);
		//Refrescar datos para recuperar CSBD_Telefono_Solicitud__c si se ha identificado el cliente una vez cargado el Aura
		component.find('opportunityData').reloadRecord();

		if (!component.get('v.oportunidad.CSBD_Telefono_Solicitud__c')) {
			helper.mostrarToast('Debe informar el destinatario', 'Debe informar un número de teléfono en el campo "Teléfono solicitud" de la oportunidad.', 'error');
		} else {
			component.find('inputEnviarNotificacionDestinatario').set('v.value', component.get('v.oportunidad.CSBD_Telefono_Solicitud__c'));

			//Cargar carpetas de idioma
			let subdirectoriosOperativas = component.get('c.subdirectorios');
			subdirectoriosOperativas.setParam('rutaDevName', 'CSBD_Enviar_Notificacion');
			subdirectoriosOperativas.setCallback(this, response => {
				if (response.getState() === 'SUCCESS') {
					let listaIdiomas = [];
					response.getReturnValue().forEach(element => listaIdiomas.push({value: element.DeveloperName, label: element.Name}));
					component.set('v.enviarNotificacionIdiomas', listaIdiomas);

					//La opción preseleccionada es el idioma de la oportunidad (por defecto 'Castellano')
					let idiomaOportunidad = listaIdiomas.find(idioma => idioma.label === component.get('v.oportunidad.CSBD_Idioma_Solicitud__c'));
					component.set('v.enviarNotificacionIdioma', idiomaOportunidad.value ? idiomaOportunidad.value : 'CSBD_Enviar_Notificacion_ESP');

					//Carga de las plantillas de SMS
					$A.enqueueAction(component.get('c.seleccionaEnviarNotificacionIdioma'));
				}
			});
			$A.enqueueAction(subdirectoriosOperativas);

			//Mostrar modal
			component.set('v.enviarNotificacionEnvioDeshabilitado', false);
			$A.util.addClass(component.find('modalEnviarNotificacion'), 'slds-fade-in-open');
			$A.util.addClass(component.find('modalBackdrop'), 'slds-backdrop_open');
		}
	},

	seleccionaEnviarNotificacionIdioma: function(component, event, helper) {
		let plantillas = component.get('c.plantillas');
		plantillas.setParam('rutaDevName', component.find('inputEnviarNotificacionIdioma').get('v.value'));
		plantillas.setCallback(this, response => {
			if (response.getState() === 'SUCCESS') {
				let listaPlantillas = [];
				response.getReturnValue().forEach(element => listaPlantillas.push({value: element.DeveloperName, label: element.Name}));
				component.set('v.enviarNotificacionPlantillas', listaPlantillas);
				helper.seleccionarControl(component, 'inputEnviarNotificacionPlantilla', 50);
			}
		});
		$A.enqueueAction(plantillas);
	},

	seleccionaEnviarNotificacionPlantilla: function(component, event, helper) {
		let plantillaCuerpo = component.get('c.plantillaCuerpo');
		plantillaCuerpo.setParams({
			developerName: component.find('inputEnviarNotificacionPlantilla').get('v.value'),
			convertirATextoPlano: true,
			sObjectId: component.get('v.recordId')
		});
		plantillaCuerpo.setCallback(this, response => {
			if (response.getState() === 'SUCCESS') {
				//Cargar contenido de la plantilla en el campo de del modal
				component.find('inputEnviarNotificacionContenido').set('v.value', response.getReturnValue());
				helper.seleccionarControl(component, 'inputEnviarNotificacionContenido');
				//Actualizar contador de caracteres restantes
				$A.enqueueAction(component.get('c.actualizarEnviarNotificacionCaracteresRestantes'));
			}
		});
		$A.enqueueAction(plantillaCuerpo);
	},

	actualizarEnviarNotificacionCaracteresRestantes: function(component) {
		let caracteresRestantes = 160 - component.find('inputEnviarNotificacionContenido').get('v.value').length;
		component.set('v.enviarNotificacionCaracteresRestantes', caracteresRestantes);

		if (caracteresRestantes < 21) {
			$A.util.addClass(component.find('divEnviarNotificacionCaracteresRestantes'), 'csbd-rojo');
		} else {
			$A.util.removeClass(component.find('divEnviarNotificacionCaracteresRestantes'), 'csbd-rojo');
		}
	},

	cerrarModalEnviarNotificacion: function(component) {
		$A.util.removeClass(component.find('modalEnviarNotificacion'), 'slds-fade-in-open');
		$A.util.removeClass(component.find('modalBackdrop'), 'slds-backdrop_open');
		component.set('v.cargarModales', false);
	},

	enviarNotificacion: function(component, event, helper) {
		//Mostrar mensaje d de campos obligatorios
		let inputEnviarNotificacionDestinatario = component.find('inputEnviarNotificacionDestinatario');
		inputEnviarNotificacionDestinatario.showHelpMessageIfInvalid();
		let inputEnviarNotificacionContenido = component.find('inputEnviarNotificacionContenido');
		inputEnviarNotificacionContenido.showHelpMessageIfInvalid();

		if (inputEnviarNotificacionDestinatario.get('v.validity').valid && inputEnviarNotificacionContenido.get('v.validity').valid) {
			let destinatario = inputEnviarNotificacionDestinatario.get('v.value');
			component.set('v.enviarNotificacionEnvioDeshabilitado', true);

			let enviarSMS = component.get('c.enviarNotificacinPushSMS');
			enviarSMS.setParams({
				sObjectId: component.get('v.recordId'),
				destinatario: destinatario,
				texto: inputEnviarNotificacionContenido.get('v.value')
			});
			enviarSMS.setCallback(this, response => {
				if (response.getState() === 'SUCCESS') {
					let resultado = response.getReturnValue();
					if (resultado === 'OK') {
						helper.mostrarToast('Se envió SMS', 'Se envió correctamente el SMS al destinatario ' + destinatario, 'success');
						$A.enqueueAction(component.get('c.cerrarModalEnviarNotificacion'));
						component.find('opportunityData').reloadRecord(true);
						//$A.get('e.force:refreshView').fire();
					} else {
						helper.mostrarToast('No se pudo enviar el SMS', resultado, 'error');
					}
				} else if (response.getState() === 'ERROR') {
					console.error(enviarSMS.getError());
					helper.mostrarToast('No se pudo enviar el SMS', enviarSMS.getError()[0].message, 'error');
				}
				component.set('v.enviarNotificacionEnvioDeshabilitado', false);
			});
			$A.enqueueAction(enviarSMS);
		}
	},

	abrirModalAgendarFirma: function(component, event, helper) {
		component.set('v.cargarModales', true);
		$A.util.addClass(component.find('modalAgendarCita'), 'slds-fade-in-open');
		$A.util.addClass(component.find('modalBackdrop'), 'slds-backdrop_open');
		helper.seleccionarControl(component, 'cerrarModalAgendarFirma', 50);
	},

	cerrarModalAgendarFirma: function(component) {
		$A.util.removeClass(component.find('modalAgendarCita'), 'slds-fade-in-open');
		$A.util.removeClass(component.find('modalBackdrop'), 'slds-backdrop_open');
		component.set('v.cargarModales', false);
	},

	agendarFirma: function(component, event, helper) {
		let inputAgendarFirma = component.find('inputAgendarFirma');
		//Se programa para una fecha y hora
		inputAgendarFirma.showHelpMessageIfInvalid();

		if (inputAgendarFirma.get('v.validity').valid) {
			const botonAceptar = component.find('modalAgendarFirmaAceptar');
			botonAceptar.set('v.disabled', true);
			helper.apex(component, 'agendarFirmaApex', {
				recordId: component.get('v.recordId'),
				tipoFirma: component.find('inputTipoFirma').get('v.checked'),
				startDateTime: inputAgendarFirma.get('v.value')
			}).then(() => {
				component.find('opportunityData').reloadRecord(true);
				//$A.get('e.force:refreshView').fire();
				helper.mostrarToast('Se programó firma', 'Se programó una firma con el cliente para el ' + helper.formatearFecha(Date.parse(inputAgendarFirma.get('v.value'))), 'success');
				$A.enqueueAction(component.get('c.cerrarModalAgendarFirma'));
			}).catch(textoError => {
				console.error(textoError);
				helper.mostrarToast('error', textoError, 'error');
			}).finally(() => botonAceptar.set('v.disabled', false));
		}
	},

	abrirModalCancelarFirma: function(component, event, helper) {
		component.set('v.cargarModales', true);
		$A.util.addClass(component.find('modalCancelarFirma'), 'slds-fade-in-open');
		$A.util.addClass(component.find('modalBackdrop'), 'slds-backdrop_open');
		helper.seleccionarControl(component, 'modalCancelarFirmaCerrar', 50);
	},

	cerrarModalCancelarFirma: function(component) {
		$A.util.removeClass(component.find('modalCancelarFirma'), 'slds-fade-in-open');
		$A.util.removeClass(component.find('modalBackdrop'), 'slds-backdrop_open');
		component.set('v.cargarModales', false);
	},

	cancelarFirma: function(component, event, helper) {
		helper.apex(component, 'cancelarFirmaApex', {recordId: component.get('v.recordId')})
		.then(firmaCancelada => {
			if (firmaCancelada) {
				component.find('opportunityData').reloadRecord(true);
				helper.mostrarToast('Se canceló firma', 'Se ha cancelado la firma para el ' + helper.formatearFecha(firmaCancelada.StartDateTime), 'info');
			} else {
				helper.mostrarToast('Sin firmas programadas', 'No existían firmas pendientes con el cliente que cancelar.', 'info');
			}
		}).catch(textoError => {
			helper.mostrarToast('No se pudo cancelar firma', textoError, 'error');
		});
		$A.enqueueAction(component.get('c.cerrarModalCancelarFirma'));
	},

	abrirModalProgramar: function(component) {
		component.set('v.cargarModales', true);
		component.set('v.modalProgramarCita', true);
		window.setTimeout($A.getCallback(() => component.find('modalProgramarCita').abrirModal()), 50);
		/*
		component.set('v.cargarModales', true);
		if (!component.find('modalProgramarInputFecha').get('v.value')) {
			const ahora = new Date();
			const ahoraIso = ahora.toISOString();
			component.find('modalProgramarInputFecha').set('v.value', ahoraIso);
			component.set('v.modalProgramarInputFechaValueAnterior', ahoraIso);
			const modalProgramarCalendarioDisponibilidad = component.find('modalProgramarCalendarioDisponibilidad');
			if (modalProgramarCalendarioDisponibilidad) {
				modalProgramarCalendarioDisponibilidad.set('v.fecha', ahora);
			}
		}
		window.setTimeout($A.getCallback(() => {
			$A.util.addClass(component.find('modalProgramar'), 'slds-fade-in-open');
			$A.util.addClass(component.find('modalBackdrop'), 'slds-backdrop_open');
			helper.seleccionarControl(component, 'modalProgramarInputFecha', 0);
		}), 400);
		*/
	},

	cerrarModalProgramar: function(component) {
		$A.util.removeClass(component.find('modalProgramar'), 'slds-fade-in-open');
		$A.util.removeClass(component.find('modalBackdrop'), 'slds-backdrop_open');
		component.set('v.programarCitaTipoAsignacion', 'A gestor específico');
		component.set('v.cargarModales', false);
	},

	programar: function(component, event, helper) {
		const inputFecha = component.find('modalProgramarInputFecha');
		let programarNuevoPropietarioSeleccionado = component.get('v.programarNuevoPropietarioSeleccionado');
		//Si se mantiene el propietario de la oportunidad se recupera el usuario en concreto
		let propietarioId = null;
		//if (!component.get('v.programarReasignacionAutomatica')) {
		if (component.get('v.programarCitaTipoAsignacion') === 'A gestor específico') {
			if (typeof programarNuevoPropietarioSeleccionado !== 'string') {
				component.find('inputProgramarBuscarPropietario').reportValidity();
			} else {
				propietarioId = programarNuevoPropietarioSeleccionado;
			}
		}
		if (typeof programarNuevoPropietarioSeleccionado === 'string') {
			//Se programa para una fecha y hora
			inputFecha.showHelpMessageIfInvalid();

			if (inputFecha.get('v.validity').valid) {
				component.find('modalProgramarAceptar').set('v.disabled', true);
				let argsProgramarCita = {
					recordId: component.get('v.recordId'),
					asignacionAuto: component.get('v.programarCitaTipoAsignacion') === 'Automática',
					comprobarContacto: component.find('inputComprobarContacto').get('v.checked'),
					idPropietario: propietarioId,
					startDateTime: inputFecha.get('v.value')
				};
				helper.apex(component, 'programarCita', argsProgramarCita)
				.then(() => {
					helper.mostrarToast('Se programó cita', 'Se programó una cita con el cliente para el ' + helper.formatearFecha(Date.parse(inputFecha.get('v.value'))), 'success');
					$A.enqueueAction(component.get('c.cerrarModalProgramar'));
					//$A.get('e.force:refreshView').fire();
					component.find('opportunityData').reloadRecord(true);

				}).catch(textoError => {
					console.error(textoError);
					helper.mostrarToast('Problema programando la cita', textoError, 'error');
				}).finally(() => component.find('modalProgramarAceptar').set('v.disabled', false));

			}
		}
	},

	abrirModalDesprogramar: function(component, event, helper) {
		component.set('v.cargarModales', true);
		$A.util.addClass(component.find('modalDesprogramarCita'), 'slds-fade-in-open');
		$A.util.addClass(component.find('modalBackdrop'), 'slds-backdrop_open');
		helper.seleccionarControl(component, 'cerrarModalDesprogramar', 50);
	},

	cerrarModalDesprogramar: function(component) {
		$A.util.removeClass(component.find('modalDesprogramarCita'), 'slds-fade-in-open');
		$A.util.removeClass(component.find('modalBackdrop'), 'slds-backdrop_open');
		component.set('v.cargarModales', false);
	},

	desprogramar: function(component, event, helper) {
		component.find('modalDesprogramarCitaAceptar').set('v.disabled', true);
		helper.apex(component, 'desprogramarCita', {recordId: component.get('v.recordId')})
		.then(eventoDesprogramado => {
			if (eventoDesprogramado) {
				helper.mostrarToast('Se desprogramó cita', 'Se ha cancelado la cita para el ' + helper.formatearFecha(eventoDesprogramado.StartDateTime), 'info');
			} else {
				helper.mostrarToast('Sin citas programadas', 'No existían citas pendientes con el cliente que cancelar.', 'info');
			}
			$A.enqueueAction(component.get('c.cerrarModalDesprogramar'));
			component.find('opportunityData').reloadRecord(true);
		}).catch(textoError => {
			console.error(textoError);
			helper.mostrarToast('Problema desprogramando la cita', textoError, 'error');
		}).finally(() => component.find('modalDesprogramarCitaAceptar').set('v.disabled', false));
	},

	abrirModalCerrar: function(component, event, helper) {
		if (!component.get('v.oportunidad.CSBD_Producto__c')) {
			helper.mostrarToast('Oportunidad sin producto', 'Es necesario que la oportunidad tenga un producto para poder cerrarla', 'info');
		} else {
			component.set('v.cargarModales', true);

			//Preparar opciones del desplegable de etapas finales
			let etapasFinales;
			if (component.get('v.oportunidad.CSBD_Contact__c')
			|| component.get('v.oportunidad.CSBD_No_Identificado__c')) {
				etapasFinales = [
					{label: 'Formalizada', value: 'Formalizada'},
					{label: 'Perdida', value: 'Perdida'},
					{label: 'Rechazada', value: 'Rechazada'}
				];
			} else { //Si el contacto de la oportunidad no está informado solo se permite rechazar
				etapasFinales = [{label: 'Rechazada', value: 'Rechazada'}];
			}
			component.set('v.cerrarEtapas', etapasFinales);
			if (etapasFinales.length === 1) {
				component.find('inputCerrarEtapa').set('v.value', etapasFinales[0].value);
				$A.enqueueAction(component.get('c.seleccionarCerrarEtapa'));
			}

			$A.util.addClass(component.find('modalCerrar'), 'slds-fade-in-open');
			$A.util.addClass(component.find('modalBackdrop'), 'slds-backdrop_open');
			//Foco en el desplegable de etapa final o de resolución
			if (etapasFinales.length !== 1) {
				helper.seleccionarControl(component, 'inputCerrarEtapa', 50);
			}
		}
	},

	cerrarModalCerrar: function(component) {
		$A.util.removeClass(component.find('modalCerrar'), 'slds-fade-in-open');
		$A.util.removeClass(component.find('modalBackdrop'), 'slds-backdrop_open');
		component.set('v.cargarModales', false);
	},

	seleccionarCerrarEtapa: function(component, event, helper) {
		let resultado = component.find('inputCerrarEtapa').get('v.value');
		if (resultado === 'Formalizada') {
			let oportunidadesHijasAbiertas = component.get('c.obtenerOportunidadesHijas');
			oportunidadesHijasAbiertas.setParam('idOportunidad', component.get('v.recordId'));
			oportunidadesHijasAbiertas.setCallback(this, response => {
				if (response.getState() === 'SUCCESS') {
					if (response.getReturnValue()) {
						helper.mostrarToast('Cierre no permitido', 'La oportunidad tiene acciones comerciales abiertas', 'info');
					}
				} else if (response.getState() === 'ERROR') {
					helper.mostrarToast('Error consultando acciones comerciales', oportunidadesHijasAbiertas.getError()[0].message, 'error');
				}
			});
			$A.enqueueAction(oportunidadesHijasAbiertas);
		}

		let obtenerResolucionesApex = component.get('c.obtenerResoluciones');
		obtenerResolucionesApex.setParams({
			producto: component.get('v.oportunidad.CSBD_Producto__c'),
			nombreRecordType: component.get('v.oportunidad.RecordType.Name'),
			etapa: resultado
		});
		obtenerResolucionesApex.setCallback(this, response => {
			if (response.getState() === 'SUCCESS') {
				let inputCerrarResolucion = component.find('inputCerrarResolucion');
				inputCerrarResolucion.set('v.value', null);
				const resoluciones = response.getReturnValue();
				component.set('v.cerrarResoluciones', resoluciones.map(resolucion => ({label: resolucion, value: resolucion})));
				const esDesistimiento = component.get('v.oportunidad.RecordType.DeveloperName') === 'CSBD_Desistimiento';
				if (esDesistimiento && resultado === 'Formalizada') {
					inputCerrarResolucion.set('v.value', 'Desistimiento realizado');
				} else if (esDesistimiento && resultado === 'Rechazada') {
					inputCerrarResolucion.set('v.value', 'Duplicada');
				} else if (resoluciones.length === 1) {
					inputCerrarResolucion.set('v.value', resoluciones[0]);
				}
				helper.seleccionarControl(component, 'inputCerrarResolucion', 40);
			}
		});
		$A.enqueueAction(obtenerResolucionesApex);
	},

	cerrar: function(component, event, helper) {
		let campos = new Map();

		let notasGestor;

		let inputCerrarEtapa = component.find('inputCerrarEtapa');
		inputCerrarEtapa.checkValidity();
		inputCerrarEtapa.reportValidity();

		let inputCerrarResolucion = component.find('inputCerrarResolucion');
		inputCerrarResolucion.checkValidity();
		inputCerrarResolucion.reportValidity();

		let inputMotivoRechazo = component.find('inputMotivoRechazo');
		if (inputMotivoRechazo) {
			inputMotivoRechazo.checkValidity();
			inputMotivoRechazo.reportValidity();
			if (inputMotivoRechazo.get('v.validity').valid) {

				notasGestor = component.get('v.oportunidad.CSBD_Notas_gestor__c') ? inputMotivoRechazo.get('v.value') + '\n' + component.get('v.oportunidad.CSBD_Notas_gestor__c') : inputMotivoRechazo.get('v.value');

				campos.set('CSBD_Notas_gestor__c', notasGestor);
			}
		}

		let inputTipoOfertado = component.find('inputTipoOfertado');
		if (inputTipoOfertado) {
			inputTipoOfertado.checkValidity();
			inputTipoOfertado.reportValidity();
			if (inputTipoOfertado.get('v.validity').valid) {
				campos.set('CSBD_TipoOfertado__c', parseFloat(inputTipoOfertado.get('v.value')));
			}
		}

		let inputEntidadCompetencia = component.find('inputEntidadCompetencia');
		if (inputEntidadCompetencia) {
			inputTipoOfertado.checkValidity();
			inputTipoOfertado.reportValidity();
			if (inputEntidadCompetencia.get('v.validity').valid) {
				campos.set('CSBD_EntidadCompetencia__c', inputEntidadCompetencia.get('v.value'));
			}
		}

		if (inputCerrarEtapa.get('v.validity').valid
		&& inputCerrarResolucion.get('v.validity').valid
		&& !inputMotivoRechazo || inputCerrarEtapa.get('v.validity').valid && inputCerrarResolucion.get('v.validity').valid && inputMotivoRechazo && inputMotivoRechazo.get('v.validity').valid) {
			component.find('botonCerrarCerrar').set('v.disabled', true);
			let cerrarOportunidad = component.get('c.cerrarOportunidad');
			cerrarOportunidad.setParams({
				recordId: component.get('v.recordId'),
				nombreEtapaVentas: inputCerrarEtapa.get('v.value'),
				resolucion: inputCerrarResolucion.get('v.value'),
				campos: Object.fromEntries(campos)
			});
			cerrarOportunidad.setCallback(this, response => {
				if (response.getState() === 'SUCCESS') {
					helper.mostrarToast('Se cerró oportunidad ' + response.getReturnValue().CSBD_Identificador__c, 'La oportunidad se cerró satisfactoriamente', 'success');
					component.find('opportunityData').reloadRecord(true);
					//$A.get('e.force:refreshView').fire();
					$A.enqueueAction(component.get('c.cerrarModalCerrar'));
				} else {
					console.error(cerrarOportunidad.getError());
					helper.mostrarToast('Problema cerrando la oportunidad', cerrarOportunidad.getError()[0].message, 'error');
				}
				component.find('botonCerrarCerrar').set('v.disabled', false);
			});
			$A.enqueueAction(cerrarOportunidad);
		}

	},

	seleccionarCerrarResolucion: function(component, event, helper) {
		let resultado = component.find('inputCerrarResolucion').get('v.value');
		if (resultado === 'Competencia') {
			let obtenerEntidad = component.get('c.obtenerEntidades');
			obtenerEntidad.setCallback(this, response => {
				if (response.getState() === 'SUCCESS') {
					let inputEntidadCompetencia = component.find('inputEntidadCompetencia');
					inputEntidadCompetencia.set('v.value', null);
					const entidades = response.getReturnValue();
					component.set('v.entidadesCompetencia', entidades.map(entidad => ({label: entidad, value: entidad})));
					helper.seleccionarControl(component, 'inputEntidadCompetencia', 40);
				}
			});
			$A.enqueueAction(obtenerEntidad);

			component.set('v.mostrarTipoBonificado', true);
			component.set('v.mostrarMotivoRechazo', false);
		} else if (resultado === 'Devolución a contact') {
			component.set('v.mostrarMotivoRechazo', true);
			component.set('v.mostrarTipoBonificado', false);
		} else {
			component.set('v.mostrarMotivoRechazo', false);
			component.set('v.mostrarTipoBonificado', false);
		}
	},

	abrirModalReactivar: function(component, event, helper) {
		component.set('v.cargarModales', true);
		//Por defecto se volverá a la penúltima etapa de ventas
		component.find('inputReactivarEtapa').set('v.value', component.get('v.oportunidad.CSBD_Ultima_Etapa_Ventas__c'));

		$A.util.addClass(component.find('modalReactivar'), 'slds-fade-in-open');
		$A.util.addClass(component.find('modalBackdrop'), 'slds-backdrop_open');
		helper.seleccionarControl(component, 'inputReactivarEtapa', 50);
	},

	cerrarModalReactivar: function(component) {
		$A.util.removeClass(component.find('modalReactivar'), 'slds-fade-in-open');
		$A.util.removeClass(component.find('modalBackdrop'), 'slds-backdrop_open');
		component.set('v.cargarModales', false);
	},

	reactivar: function(component, event, helper) {
		let inputReactivarEtapa = component.find('inputReactivarEtapa');
		inputReactivarEtapa.showHelpMessageIfInvalid();

		if (inputReactivarEtapa.get('v.validity').valid) {
			component.find('botonReactivarReactivar').set('v.disabled', true);
			let reactivarOportunidad = component.get('c.reactivarOportunidad');
			reactivarOportunidad.setParams({
				recordId: component.get('v.recordId'),
				nombreEtapaVentas: inputReactivarEtapa.get('v.value')
			});
			reactivarOportunidad.setCallback(this, response => {
				if (response.getState() === 'SUCCESS') {
					helper.mostrarToast('Se reactivó oportunidad ' + response.getReturnValue().CSBD_Identificador__c, 'La oportunidad se reactivó satisfactoriamente.', 'success');
					component.find('opportunityData').reloadRecord(true);
					//$A.get('e.force:refreshView').fire();
					$A.enqueueAction(component.get('c.cerrarModalReactivar'));
				} else {
					console.error(reactivarOportunidad.getError());
					helper.mostrarToast('No se ha podido reactivar la oportunidad', JSON.stringify(response.getError()), 'error');
				}
				component.find('botonReactivarReactivar').set('v.disabled', false);
			});
			$A.enqueueAction(reactivarOportunidad);
		}
	},

	abrirOtrasOperativas: function(component) {
		window.clearTimeout(component.get('v.otrasOperativasTimeout'));
		$A.util.addClass(component.find('popoverOtrasOperativas'), 'visible');
	},

	cerrarOtrasOperativas: function(component) {
		const popover = component.find('popoverOtrasOperativas');
		component.set('v.otrasOperativasTimeout', window.setTimeout($A.getCallback(() => $A.util.removeClass(popover, 'visible')), 220));
	},

	modalEnviarCorreoTeclaPulsada: function(component, event) {
		if (event.keyCode === 27) { //ESC
			$A.enqueueAction(component.get('c.cerrarModalEnviarCorreo'));
		}
	},

	modalEnviarNotificacionTeclaPulsada: function(component, event) {
		if (event.keyCode === 27) { //ESC
			$A.enqueueAction(component.get('c.cerrarModalEnviarNotificacion'));
		}
	},

	modalAgendarCitaTeclaPulsada: function(component, event) {
		if (event.keyCode === 27) { //ESC
			$A.enqueueAction(component.get('c.cerrarModalAgendarFirma'));
		}
	},

	modalProgramarTeclaPulsada: function(component, event) {
		if (event.keyCode === 27) { //ESC
			$A.enqueueAction(component.get('c.cerrarModalProgramar'));
		}
	},

	modalCerrarTeclaPulsada: function(component, event) {
		if (event.keyCode === 27) { //ESC
			$A.enqueueAction(component.get('c.cerrarModalCerrar'));
		}
	},

	modalReactivarTeclaPulsada: function(component, event) {
		if (event.keyCode === 27) { //ESC
			$A.enqueueAction(component.get('c.cerrarModalReactivar'));
		}
	},

	modalDesprogramarCitaTeclaPulsada: function(component, event) {
		if (event.keyCode === 27) { //ESC
			$A.enqueueAction(component.get('c.cerrarModalDesprogramar'));
		}
	},

	modalCancelarFirmaTeclaPulsada: function(component, event) {
		if (event.keyCode === 27) { //ESC
			$A.enqueueAction(component.get('c.cerrarModalCancelarFirma'));
		}
	},

	modalAsignarAutoTeclaPulsada: function(component, event) {
		if (event.keyCode === 27) { //ESC
			$A.enqueueAction(component.get('c.cerrarModalAsignarAuto'));
		}
	},

	modalClonarTeclaPulsada: function(component, event) {
		if (event.keyCode === 27) { //ESC
			$A.enqueueAction(component.get('c.cerrarModalDuplicar'));
		}
	},

	modalConvertirAHipotecaTeclaPulsada: function(component, event) {
		if (event.keyCode === 27) { //ESC
			$A.enqueueAction(component.get('c.cerrarModalConvertirAHipoteca'));
		}
	},

	modalPendienteInternoTeclaPulsada: function(component, event) {
		if (event.keyCode === 27) { //ESC
			$A.enqueueAction(component.get('c.cerrarModalPendienteInterno'));
		}
	},

	modalProrrogaFechaAltaVencimientoTeclaPulsada: function(component, event) {
		if (event.keyCode === 27) { //ESC
			$A.enqueueAction(component.get('c.cerrarModalProrrogaFechaAltaVencimiento'));
		}
	},

	abrirModalAsignarAuto: function(component, event, helper) {
		component.set('v.cargarModales', true);
		$A.util.addClass(component.find('modalAsignarAuto'), 'slds-fade-in-open');
		$A.util.addClass(component.find('modalBackdrop'), 'slds-backdrop_open');
		helper.seleccionarControl(component, 'modalAsignarAutoCancelar', 50);
	},

	abrirModalPendienteInterno: function(component, event, helper) {
		component.set('v.cargarModales', true);

		const recordType = component.get('v.oportunidad.RecordType.DeveloperName');
		const rtsSinMotivoPendienteInterno = ['CSBD_Hipoteca', 'CSBD_Feedback', 'CSBD_PROAutomatica', 'CSBD_Soporte_Digital', 'CSBD_MAC'];
		const mostrarInputMotivos = component.get('v.oportunidad.CSBD_Estado__c') !== 'Pendiente Interno' && !rtsSinMotivoPendienteInterno.includes(recordType);
		component.set('v.pendienteInternoMostrarInputMotivos', mostrarInputMotivos);

		if (component.get('v.oportunidad.CSBD_Estado__c') === 'Pendiente Interno') {
			component.set('v.modalPendienteInternoTexto', '¿Quieres reanudar la gestión de la oportunidad?');
			component.find('pendienteInternoAceptar').set('v.label', 'Reanudar');
			component.find('pendienteInternoAceptar').set('v.iconName', 'utility:play');
		} else {
			component.set('v.modalPendienteInternoTexto', '¿Quieres cambiar el estado de la oportunidad a "Pendiente Interno"?');
			component.find('pendienteInternoAceptar').set('v.label', 'Pendiente Interno');
			component.find('pendienteInternoAceptar').set('v.iconName', 'utility:stop');

			if (mostrarInputMotivos) {
				let motivos = [];
				if (recordType === 'CSBD_Accion_Comercial') {
					motivos = [
						{label: 'Aprobada pte. Escritura', value: 'Aprobada pte. Escritura'},
						{label: 'Aprobada pte. FEIN', value: 'Aprobada pte. FEIN'},
						{label: 'Aprobada pte. OK cliente', value: 'Aprobada pte. OK cliente'},
						{label: 'Aprobada pte. Tasación', value: 'Aprobada pte. Tasación'},
						{label: 'Cliente no localizado', value: 'Cliente no localizado'},
						{label: 'Esperando llamada cliente', value: 'Esperando llamada cliente'},
						{label: 'Interno', value: 'Interno'},
						{label: 'Pendiente contactar oficina', value: 'Pendiente contactar oficina'},
						{label: 'Pendiente de aprobación', value: 'Pendiente de aprobación'},
						{label: 'Pendiente de documentación', value: 'Pendiente de documentación'},
						{label: 'Pendiente de firma', value: 'Pendiente de firma'},
						{label: 'Pendiente de tasación', value: 'Pendiente de tasación'},
						{label: 'Pendiente escrituración', value: 'Pendiente escrituración'},
						{label: 'Pendiente informe', value: 'Pendiente informe'},
						{label: 'Pendiente iniciar SIA', value: 'Pendiente iniciar SIA'},
						{label: 'Pendiente muro', value: 'Pendiente muro'},
						{label: 'Pendiente OK cliente', value: 'Pendiente OK cliente'},
						{label: 'SIA en trámite', value: 'SIA en trámite'},
						{label: 'Trasladada CARP', value: 'Trasladada CARP'},
						{label: 'Trasladada DT Tarifa', value: 'Trasladada DT Tarifa'},
						{label: 'Trasladada oficina', value: 'Trasladada oficina'}
					];
				} else if (['CSBD_Chat', 'CSBD_CMB', 'CSBD_CMN', 'CSBD_Llamada_Servicio'].includes(recordType)) {
					motivos = [
						{label: 'Cliente no localizado', value: 'Cliente no localizado'},
						{label: 'Esperando llamada cliente', value: 'Esperando llamada cliente'},
						{label: 'Interno', value: 'Interno'}
					];
				} else if (['CSBD_Desistimiento', 'CSBD_DesistimientoPAI'].includes(recordType)) {
					motivos = [
						{label: 'Interno', value: 'Interno'}
					];
				} else if (recordType === 'CSBD_Prestamo') {
					motivos = [
						{label: 'Cliente no localizado', value: 'Cliente no localizado'},
						{label: 'Esperando llamada cliente', value: 'Esperando llamada cliente'},
						{label: 'Interno', value: 'Interno'},
						{label: 'Pendiente contactar oficina', value: 'Pendiente contactar oficina'},
						{label: 'Pendiente de aprobación', value: 'Pendiente de aprobación'},
						{label: 'Pendiente de documentación', value: 'Pendiente de documentación'},
						{label: 'Pendiente de firma', value: 'Pendiente de firma'},
						{label: 'Pendiente informe', value: 'Pendiente informe'},
						{label: 'Pendiente muro', value: 'Pendiente muro'},
						{label: 'Trasladada CARP', value: 'Trasladada CARP'},
						{label: 'Trasladada oficina', value: 'Trasladada oficina'}
					];
				} else if (recordType === 'CSBD_Renting') {
					motivos = [
						{label: 'Cliente no localizado', value: 'Cliente no localizado'},
						{label: 'Esperando llamada cliente', value: 'Esperando llamada cliente'},
						{label: 'Interno', value: 'Interno'},
						{label: 'Pendiente de documentación', value: 'Pendiente de documentación'},
						{label: 'Pendiente de firma', value: 'Pendiente de firma'},
						{label: 'Trasladada CARP', value: 'Trasladada CARP'},
						{label: 'Trasladada oficina', value: 'Trasladada oficina'}
					];
				} else if (recordType === 'CSBD_TPV' || recordType === 'CSBD_Compra_Estrella') {
					motivos = [
						{label: 'Cliente no localizado', value: 'Cliente no localizado'},
						{label: 'Esperando llamada cliente', value: 'Esperando llamada cliente'},
						{label: 'Interno', value: 'Interno'}
					];
				}
				component.find('inputMotivoPendienteInterno').set('v.options', motivos);
			}
		}

		$A.util.addClass(component.find('modalPendienteInterno'), 'slds-fade-in-open');
		$A.util.addClass(component.find('modalBackdrop'), 'slds-backdrop_open');
		helper.seleccionarControl(component, 'pendienteInternoCancelar', 50);
	},

	cerrarModalAsignarAuto: function(component) {
		$A.util.removeClass(component.find('modalAsignarAuto'), 'slds-fade-in-open');
		$A.util.removeClass(component.find('modalBackdrop'), 'slds-backdrop_open');
		component.set('v.cargarModales', false);
	},

	cerrarModalProrrogaFechaAltaVencimiento: function(component) {
		$A.util.removeClass(component.find('modalProrrogaFechaAltaVencimiento'), 'slds-fade-in-open');
		$A.util.removeClass(component.find('modalBackdrop'), 'slds-backdrop_open');
		component.set('v.cargarModales', false);
	},

	pendienteInterno: function(component, event, helper) {
		if (component.get('v.oportunidad.CSBD_Estado__c') !== 'Pendiente Interno') {
			//Dejar la oportunidad en estado pendiente interno
			const rtsSinMotivoPendienteInterno = ['CSBD_Hipoteca', 'CSBD_Feedback', 'CSBD_PROAutomatica', 'CSBD_Soporte_Digital', 'CSBD_MAC'];
			if (!rtsSinMotivoPendienteInterno.includes(component.get('v.oportunidad.RecordType.DeveloperName'))) {
				let inputMotivoPendienteInterno = component.find('inputMotivoPendienteInterno');
				inputMotivoPendienteInterno.showHelpMessageIfInvalid();
				if (!inputMotivoPendienteInterno.get('v.validity').valid) {
					return;
				}
				component.set('v.oportunidad.CSBD_Motivo_Pendiente_Interno__c', inputMotivoPendienteInterno.get('v.value'));
			}
			component.find('pendienteInternoAceptar').set('v.disabled', true);
			component.set('v.oportunidad.CSBD_Estado__c', 'Pendiente Interno');
			component.find('opportunityData').saveRecord($A.getCallback(saveResult => {
				if (saveResult.state === 'SUCCESS') {
					helper.mostrarToast('Oportunidad pendiente interno', 'La oportunidad ' + component.get('v.oportunidad.CSBD_Identificador__c') + ' está en estado "Pendiente Interno"', 'success');
					$A.enqueueAction(component.get('c.cerrarModalPendienteInterno'));
				} else if (saveResult.state === 'ERROR') {
					console.error(JSON.stringify(saveResult.error));
					helper.mostrarToast('Problema cambiando estado a "Pendiente Interno"', JSON.stringify(saveResult.error), 'error');
				}
				component.find('pendienteInternoAceptar').set('v.disabled', false);
			}));

		} else {
			//Reactivar la oportunidad
			component.find('pendienteInternoAceptar').set('v.disabled', true);
			component.set('v.oportunidad.CSBD_Estado__c', 'Activa');
			component.find('opportunityData').saveRecord($A.getCallback(saveResult => {
				if (saveResult.state === 'SUCCESS') {
					helper.mostrarToast('Se reactivó la oportunidad', 'La oportunidad ' + component.get('v.oportunidad.CSBD_Identificador__c') + ' está en estado "Activa"', 'success');
					$A.enqueueAction(component.get('c.cerrarModalPendienteInterno'));
				} else if (saveResult.state === 'ERROR') {
					console.error(JSON.stringify(saveResult.error));
					helper.mostrarToast('Problema reactivando la oportunidad', JSON.stringify(saveResult.error), 'error');
				}
				component.find('pendienteInternoAceptar').set('v.disabled', false);
			}));
		}
	},

	cerrarModalPendienteInterno: function(component) {
		$A.util.removeClass(component.find('modalPendienteInterno'), 'slds-fade-in-open');
		$A.util.removeClass(component.find('modalBackdrop'), 'slds-backdrop_open');
		component.set('v.cargarModales', false);
	},

	abrirModalDuplicar: function(component, event, helper) {
		//Obtener lista de record types seleccionables
		let recordTypesOportunidadCSBD = component.get('c.recordTypesOportunidadCSBD');
		recordTypesOportunidadCSBD.setCallback(this, response => {
			if (response.getState() === 'SUCCESS') {
				let valores = [];
				response.getReturnValue().forEach(recordType => valores.push({value: recordType.DeveloperName, label: recordType.Name}));
				component.set('v.clonarOportunidadRecordTypes', valores);

				//Abrir modal
				component.set('v.cargarModales', true);
				$A.util.addClass(component.find('modalClonar'), 'slds-fade-in-open');
				$A.util.addClass(component.find('modalBackdrop'), 'slds-backdrop_open');

				component.find('inputClonarOportunidadRecordTypes').set('v.value', component.get('v.oportunidad.RecordType.DeveloperName'));

				helper.seleccionarControl(component, 'inputClonarOportunidadRecordTypes', 50);
			} else if (response.getState() === 'ERROR') {
				helper.mostrarToast('Problema recuperando los tipos de oportunidad', 'No se ha podido recuperar el listado de tipos de oportunidad.', 'error');
			}
		});
		$A.enqueueAction(recordTypesOportunidadCSBD);
	},

	cerrarModalDuplicar: function(component) {
		$A.util.removeClass(component.find('modalClonar'), 'slds-fade-in-open');
		$A.util.removeClass(component.find('modalBackdrop'), 'slds-backdrop_open');
		component.set('v.cargarModales', false);
	},

	cerrarModalConvertirAHipoteca: function(component) {
		$A.util.removeClass(component.find('modalConvertirAHipoteca'), 'slds-fade-in-open');
		$A.util.removeClass(component.find('modalBackdrop'), 'slds-backdrop_open');
		component.set('v.cargarModales', false);
	},

	asignarAuto: function(component, event, helper) {
		helper.apex(component, 'solicitarAltaOmnichannel', {idOportunidad: component.get('v.recordId')})
		.then(() => {
			component.find('opportunityData').reloadRecord(true);
			//window.setTimeout($A.getCallback(() => $A.get('e.force:refreshView').fire()), 1000);
			helper.mostrarToast('Asignación automática solicitada', 'Asignación automática solicitada a Omnichannel para la oportunidad ' + component.get('v.oportunidad.CSBD_Identificador__c'), 'success');
			$A.enqueueAction(component.get('c.cerrarModalAsignarAuto'));
		}).catch(textoError => helper.mostrarToast('Problema solicitando asignación automática', textoError, 'error'));
	},

	menuFinalizarAsignarAuto: function(component, event, helper) {
		if (event.getParam('value') === 'finalizarAsignarAuto') {
			helper.apex(component, 'solicitarBajaOmnichannel', {idOportunidad: component.get('v.recordId')})
			.then(() => {
				helper.mostrarToast('Fin de asignación automática solicitado', 'Fin de asignación automática solicitado a Omnichannel para la oportunidad ' + component.get('v.oportunidad.CSBD_Identificador__c'), 'info');
				$A.enqueueAction(component.get('c.cerrarModalAsignarAuto'));
				component.find('opportunityData').reloadRecord(true);
				//window.setTimeout($A.getCallback(() => $A.get('e.force:refreshView').fire()), 1000);
			}).catch(textoError => helper.mostrarToast('Problema solicitando asignación automática', textoError, 'error'));
		}
	},

	actualizarDatosRiesgo: function(component, event, helper) {
		helper.apex(component, 'actualizarDatosRiesgoContacto', {idOportunidad: component.get('v.recordId')})
		.then(() => {
			helper.mostrarToast('Se actualizó la información financiera del contacto', 'Se actualizó la información financiera del contacto', 'success');
			component.find('opportunityData').reloadRecord(true);
			//window.setTimeout($A.getCallback(() => $A.get('e.force:refreshView').fire()), 1000);
		}).catch(textoError => helper.mostrarToast('Problema actualizando la información financiera del contacto', textoError, 'error'));
	},

	duplicar: function(component, event, helper) {
		component.find('botonDuplicarOportunidad').set('v.disabled', true);
		let duplicar = component.get('c.duplicarOportunidad');
		duplicar.setParams({
			oportunidad: component.get('v.oportunidad'),
			recordTypeDeveloperName: component.find('inputClonarOportunidadRecordTypes').get('v.value'),
			empresa: component.find('inputClonarOportunidadEmpresa').get('v.value')
		});
		duplicar.setCallback(this, response => {
			if (response.getState() === 'SUCCESS') {
				helper.abrirTab(component, response.getReturnValue().Id);
				helper.mostrarToast('Se clonó Oportunidad', 'Se clonó correctamente la oportunidad.', 'success');
				$A.enqueueAction(component.get('c.cerrarModalDuplicar'));
			} else if (response.getState() === 'ERROR') {
				helper.mostrarToast('No se pudo clonar Oportunidad', duplicar.getError()[0].message, 'error');
			}
			component.find('botonDuplicarOportunidad').set('v.disabled', false);
		});
		$A.enqueueAction(duplicar);
	},

	tomarPropiedad: function(component, event, helper) {
		component.set('v.oportunidad.OwnerId', $A.get('$SObjectType.CurrentUser.Id'));
		component.find('opportunityData').saveRecord($A.getCallback(saveResult => {
			if (saveResult.state === 'SUCCESS') {
				helper.mostrarToast('Se reasignó Oportunidad', 'Ahora es el propietario de la oportunidad ' + component.get('v.oportunidad.CSBD_Identificador__c'), 'success');
			} else if (saveResult.state === 'ERROR') {
				helper.mostrarToast('error', 'No se reasignó Oportunidad', JSON.stringify(saveResult.error));
			}
		}));
	},

	confirmarProrrogaAlta: function(component, event, helper) {
		component.find('prorrogaFechaAltaVencimientoContinuar').set('v.disabled', true);
		let ampliarVencimiento = component.get('c.ampliarVencimiento');
		ampliarVencimiento.setParams({
			idOportunidad: component.get('v.recordId'),
			fechaVencimiento: component.get('v.oportunidad.CSBD_Fecha_vencimiento_alta__c')
		});
		ampliarVencimiento.setCallback(this, response => {
			if (response.getState() === 'SUCCESS') {
				component.find('opportunityData').reloadRecord(true);
				//$A.get('e.force:refreshView').fire();
				const fecha = new Date(response.getReturnValue());
				let fechaString = `${fecha.getDate()}/${fecha.getMonth() + 1}/${fecha.getFullYear()}`;
				fechaString += `, ${(fecha.getHours() < 10 ? '0' : '') + fecha.getHours()}:${(fecha.getMinutes() < 10 ? '0' : '') + fecha.getMinutes()}`;
				$A.enqueueAction(component.get('c.cerrarModalProrrogaFechaAltaVencimiento'));
				helper.mostrarToast('Se amplió el plazo de vencimiento', 'La nueva fecha de vencimiento de alta es ' + fechaString, 'success');
			} else if (response.getState() === 'ERROR') {
				console.error(ampliarVencimiento.getError());
				helper.mostrarToast('Problema posponiendo la fecha de vencimiento', ampliarVencimiento.getError()[0].message, 'error');
			}
			component.find('prorrogaFechaAltaVencimientoContinuar').set('v.disabled', false);
		});
		$A.enqueueAction(ampliarVencimiento);
	},

	abrirModalTrasladoSia: function(component, event, helper) {
		component.set('v.cargarModales', true);

		//Traslados
		let ingresosTitular1 = null;
		let ingresosTitular2 = null;
		let totalIngresosTitulares = null;
		const datosCalculoDtiString = component.get('v.oportunidad.CSBD_Datos_Calculo_DTI__c');
		if (datosCalculoDtiString) {
			const datosCalculoDti = JSON.parse(component.get('v.oportunidad.CSBD_Datos_Calculo_DTI__c'));
			ingresosTitular1 = parseInt(datosCalculoDti.primerTitular.nominasNetas.ingresos, 10);
			totalIngresosTitulares = ingresosTitular1;
			if (datosCalculoDti.segundoTitular.nominasNetas) {
				ingresosTitular2 = parseInt(datosCalculoDti.segundoTitular.nominasNetas.ingresos, 10);
				totalIngresosTitulares += ingresosTitular2;
			}
		}

		const numeroDocumento = component.get('v.oportunidad.Account.CC_Numero_Documento__c');

		let valorTtraslados = '';
		valorTtraslados += numeroDocumento ? numeroDocumento + '\n\n' : '';
		valorTtraslados += 'Canal: ' + component.get('v.oportunidad.RecordType.Name');
		valorTtraslados += '\nLínea: ' + component.get('v.oportunidad.CSBD_Producto__c');
		valorTtraslados += '\nIngresos mes Tit. 1: ';
		if (ingresosTitular1 !== null) {
			valorTtraslados += ingresosTitular1.toFixed(2) + '€';
		}
		valorTtraslados += '\nIngresos mes Tit. 2: ';
		if (ingresosTitular2 !== null) {
			valorTtraslados += ingresosTitular2.toFixed(2) + '€';
		}
		valorTtraslados += '\nTOTAL Ingresos mes: ';
		if (totalIngresosTitulares !== null) {
			valorTtraslados += totalIngresosTitulares.toFixed(2) + '€';
		}
		valorTtraslados += '\nPlazo: ' + component.get('v.oportunidad.CSBD_Now_Plazo__c') + '\n';
		valorTtraslados += '\nModalidad tipo de interés: ' + component.get('v.oportunidad.CSBD_TipoInteres2__c');
		valorTtraslados += '\nTipo sin bonificar: ';
		if (component.get('v.oportunidad.CSBD_TIN_Inicial__c')) {
			valorTtraslados += component.get('v.oportunidad.CSBD_TIN_Inicial__c').toFixed(2) + '%';
		}
		valorTtraslados += '\n';
		valorTtraslados += '\nTipo bonificado: ';
		if (component.get('v.oportunidad.CSBD_TIN_Inicial__c')) {
			valorTtraslados += (component.get('v.oportunidad.CSBD_TIN_Inicial__c') - 0.75).toFixed(2) + '%';
		}
		valorTtraslados += '\n';
		valorTtraslados += '\nVinculación asociada a la operación:\n';
		valorTtraslados = valorTtraslados.replace(/null\n/g, '\n');
		component.find('modalTrasladoSiaTextareaTraslados').set('v.value', valorTtraslados);

		//Aprobada
		let valorAprobada = 'Aprobada - ' + component.get('v.oportunidad.Account.CC_Numero_Documento__c');
		valorAprobada = valorAprobada.replace(/null\n/g, '\n');
		component.find('modalTrasladoSiaTextareaAprobada').set('v.value', valorAprobada);

		//Fecha firma
		let valorFechaFirma = 'Fecha firma - ';
		valorFechaFirma += component.get('v.oportunidad.Account.CC_Numero_Documento__c') + ' - ';
		valorFechaFirma += helper.modalSiaFormatearFecha(component.get('v.oportunidad.CSBD_Fecha_Firma__c')) + ' - ';
		if (component.get('v.oportunidad.Amount')) {
			valorFechaFirma += component.get('v.oportunidad.Amount').toLocaleString() + '€';
		}
		valorFechaFirma += ' - ';
		if (component.get('v.oportunidad.CSBD_Now_Plazo__c')) {
			valorFechaFirma += component.get('v.oportunidad.CSBD_Now_Plazo__c') + ' meses';
		}
		valorFechaFirma += ' - ';
		if (component.get('v.oportunidad.CSBD_TIN_Inicial__c')) {
			valorFechaFirma += (component.get('v.oportunidad.CSBD_TIN_Inicial__c') - 0.75).toFixed(2).toString() + '%';
		}
		valorFechaFirma += ' - ';
		valorFechaFirma += 'Modalidad: ' + component.get('v.oportunidad.CSBD_TipoInteres2__c');
		valorFechaFirma = valorFechaFirma.replace(/ null/g, ' ');
		component.find('modalTrasladoSiaTextareaFechaFirma').set('v.value', valorFechaFirma);

		//Firmada
		let valorFirmada = 'Firmada - ';
		valorFirmada += component.get('v.oportunidad.Account.CC_Numero_Documento__c') + ' - ';
		valorFirmada += component.get('v.oportunidad.RecordType.Name') + ' - ';
		if (component.get('v.oportunidad.Amount')) {
			valorFirmada += component.get('v.oportunidad.Amount').toLocaleString() + '€';
		}
		valorFirmada += ' - ';
		if (component.get('v.oportunidad.CSBD_Now_Plazo__c')) {
			valorFirmada += component.get('v.oportunidad.CSBD_Now_Plazo__c') + ' meses';
		}
		valorFirmada += ' - ';
		if (component.get('v.oportunidad.CSBD_TIN_Inicial__c')) {
			valorFirmada += (component.get('v.oportunidad.CSBD_TIN_Inicial__c') - 0.75).toFixed(2).toString() + '%';
		}
		valorFirmada += ' - ';
		valorFirmada += 'Modalidad: ' + component.get('v.oportunidad.CSBD_TipoInteres2__c');
		valorFirmada = valorFirmada.replace(/ null/g, ' ');
		component.find('modalTrasladoSiaTextareaFirmada').set('v.value', valorFirmada);

		$A.util.addClass(component.find('modalBackdrop'), 'slds-backdrop_open');
		$A.util.addClass(component.find('modalTrasladoSia'), 'slds-fade-in-open');
		window.setTimeout($A.getCallback(() => component.find('modalTrasladoSiaCancelar').focus()), 200);
	},

	cerrarModalTrasladoSia: function(component) {
		$A.util.removeClass(component.find('modalTrasladoSia'), 'slds-fade-in-open');
		$A.util.removeClass(component.find('modalBackdrop'), 'slds-backdrop_open');
		component.set('v.cargarModales', false);
	},

	abrirModalInformeSia: function(component, event, helper) {
		component.set('v.cargarModales', true);
		helper.informeSiaCuerpo(component);
		$A.util.addClass(component.find('modalBackdrop'), 'slds-backdrop_open');
		$A.util.addClass(component.find('modalInformeSia'), 'slds-fade-in-open');
		window.setTimeout($A.getCallback(() => component.find('modalInformeSiaCancelar').focus()), 200);
	},

	cerrarModalInformeSia: function(component) {
		$A.util.removeClass(component.find('modalInformeSia'), 'slds-fade-in-open');
		$A.util.removeClass(component.find('modalBackdrop'), 'slds-backdrop_open');
		component.set('v.cargarModales', false);
	},

	modalTrasladoSiaTeclaPulsada: function(component, event) {
		if (event.keyCode === 27) { //ESC
			$A.enqueueAction(component.get('c.cerrarModalTrasladoSia'));
		}
	},

	modalInformeSiaTeclaPulsada: function(component, event) {
		if (event.keyCode === 27) { //ESC
			$A.enqueueAction(component.get('c.cerrarModalInformeSia'));
		}
	},

	modalInformeSiaCopiarAlPortapapeles: function(component, event, helper) {
		const idBoton = event.getSource().getLocalId();
		if (idBoton === 'modalTrasladoSiaCopiarTraslados') {
			helper.copiarTextoAlPortapapeles(component.find('modalTrasladoSiaTextareaTraslados').get('v.value'));
		} else if (idBoton === 'modalTrasladoSiaCopiarAprobada') {
			helper.copiarTextoAlPortapapeles(component.find('modalTrasladoSiaTextareaAprobada').get('v.value'));
		} else if (idBoton === 'modalTrasladoSiaCopiarFechafirma') {
			helper.copiarTextoAlPortapapeles(component.find('modalTrasladoSiaTextareaFechaFirma').get('v.value'));
		} else if (idBoton === 'modalTrasladoSiaCopiarFirmada') {
			helper.copiarTextoAlPortapapeles(component.find('modalTrasladoSiaTextareaFirmada').get('v.value'));
		} else if (idBoton === 'modalInformeSiaCopiarInfoSia') {
			helper.copiarTextoAlPortapapeles(component.find('modalInformeSiaTextareaInfoSia').get('v.value'));
		}
		helper.modalSiaAnimarBotonCopiar(component, idBoton);
	},

	modalTareaGestorAbrir: function(component, event, helper) {
		component.set('v.cargarModales', true);
		component.set('v.comentariosTarea', component.get('v.oportunidad.Description'));

		if (component.get('v.oportunidad.AV_PF__c')) {
			$A.util.addClass(component.find('modalTareaGestor'), 'slds-fade-in-open');
			$A.util.addClass(component.find('modalBackdrop'), 'slds-backdrop_open');
			window.setTimeout($A.getCallback(() => component.find('modalTareaGestorCancelar').focus()), 200);
		} else {
			helper.mostrarToast('Operativa no disponible', 'La oportunidad no se puede derivar a gestor porque no tiene producto PF', 'info');
		}
	},

	modalTareaGestorCerrar: function(component) {
		$A.util.removeClass(component.find('modalTareaGestor'), 'slds-fade-in-open');
		$A.util.removeClass(component.find('modalBackdrop'), 'slds-backdrop_open');
		component.set('v.cargarModales', false);
	},

	modalTareaGestorTeclaPulsada: function(component, event) {
		if (event.keyCode === 27) { //ESC
			$A.enqueueAction(component.get('c.modalTareaGestorCerrar'));
		}
	},

	crearTarea: function(component, event, helper) {
		const modalInformeSiaTextareaInfoSia = component.find('comentariosTarea');
		if (!modalInformeSiaTextareaInfoSia.get('v.value')) {
			modalInformeSiaTextareaInfoSia.reportValidity();
		} else {
			component.set('v.cargandoGestor', true);
			let crearTareaGestor = component.get('c.crearTareaGestor');
			crearTareaGestor.setParams({
				recordId: component.get('v.recordId'),
				numeroGestor: component.get('v.oportunidad.Account.AV_EAPGestor__r.CC_Matricula__c'),
				idGestor: component.get('v.oportunidad.Account.AV_EAPGestor__c'),
				comentarios: component.find('comentariosTarea').get('v.value')
			});
			crearTareaGestor.setCallback(this, response => {
				alert(response.getState());
				if (response.getState() === 'SUCCESS') {
					alert ('funciona');
					
					helper.mostrarToast('Oportunidad ' + response.getReturnValue().CSBD_Identificador__c + ' creada con éxito', 'Podrá localizar la oportunidad en la ficha del cliente', 'success')
					 let cerrarOportunidad = component.get('c.cerrarOportunidad');
					 cerrarOportunidad.setParams({
					 	recordId: component.get('v.recordId'),
					 	nombreEtapaVentas: 'Perdida',
					 	resolucion: 'Traslado a oficina'
					 });
					 cerrarOportunidad.setCallback(this, responseCerrarOportunidad => {
						alert(response.getState());
					 	if (responseCerrarOportunidad.getState() === 'SUCCESS') {
					 		helper.mostrarToast('Oportunidad ' + component.get('v.oportunidad.CSBD_Identificador__c') + ' cerrada con éxito', 'La oportunidad se ha cerrado como Perdida', 'info');
					 		$A.enqueueAction(component.get('c.modalTareaGestorCerrar'));
					 		component.find('opportunityData').reloadRecord(true);
					 		//$A.get('e.force:refreshView').fire();
					 	} else {
					 		helper.mostrarToast('Problema cerrando la oportunidad', JSON.stringify(responseCerrarOportunidad.getError()), 'error');
					 	}
					 	component.set('v.cargandoGestor', false);
					 });
					 $A.enqueueAction(cerrarOportunidad);
				} else {
					console.error(response.getError());
					component.set('v.cargandoGestor', false);
					helper.mostrarToast('Problema creando la oportunidad para el gestor', 'El proceso de creación de la oportunidad ha fallado', 'error');

				}
			});
			$A.enqueueAction(crearTareaGestor);
		}
	},

	buttonmenuSiaOnselect: function(component, event) {
		if (event.getParam('value') === 'Informe SIA') {
			$A.enqueueAction(component.get('c.abrirModalInformeSia'));
		}
	},

	abrirModalConvertirAHipoteca: function(component) {
		component.set('v.cargarModales', true);
		$A.util.addClass(component.find('modalConvertirAHipoteca'), 'slds-fade-in-open');
		$A.util.addClass(component.find('modalBackdrop'), 'slds-backdrop_open');
		window.setTimeout($A.getCallback(() => component.find('modalConvertirAHipotecaCancelar').focus()), 200);
	},

	convertir: function(component, event, helper) {
		component.find('botonConvertirOportunidad').set('v.disabled', true);
		const familiaProducto = component.get('v.oportunidad.CSBD_Familia_Producto__c');
		const nuevoRecordType = familiaProducto === 'Hipotecas' ? 'CSBD_Hipoteca' : 'CSBD_Prestamo';
		let convertirOportunidadApex = component.get('c.convertirOportunidad');
		convertirOportunidadApex.setParams({
			oportunidad: component.get('v.oportunidad'),
			recordTypeDeveloperName: nuevoRecordType
		});
		convertirOportunidadApex.setCallback(this, responseConvertirOportunidad => {
			if (responseConvertirOportunidad.getState() === 'SUCCESS') {
				helper.mostrarToast('Se creó la oportunidad', 'La oportunidad de tipo ' + component.get('v.tipoOperativaConvertir') + 'se creó correctamente.', 'success');

				let cerrarOportunidadApex = component.get('c.cerrarOportunidad');
				cerrarOportunidadApex.setParams({
					recordId: component.get('v.recordId'),
					nombreEtapaVentas: 'Perdida',
					resolucion: 'Traslado a CSBD'
				});
				cerrarOportunidadApex.setCallback(this, responseCerrarOportunidad => {
					if (responseCerrarOportunidad.getState() === 'SUCCESS') {
						helper.mostrarToast('Se cerró oportunidad', 'La oportunidad ' + component.get('v.oportunidad.CSBD_Identificador__c') + ' se ha cerrado con etapa "Perdida"', 'info');
						$A.enqueueAction(component.get('c.cerrarModalConvertirAHipoteca'));
						component.find('opportunityData').reloadRecord(true);
						helper.abrirTab(component, responseConvertirOportunidad.getReturnValue().Id);
					} else {
						console.error(responseCerrarOportunidad.getError());
						helper.mostrarToast('Problema cerrando la oportunidad', JSON.stringify(responseCerrarOportunidad.getError()), 'error');
					}
					component.find('botonConvertirOportunidad').set('v.disabled', false);
				});
				$A.enqueueAction(cerrarOportunidadApex);
			} else if (responseConvertirOportunidad.getState() === 'ERROR') {
				console.error(convertirOportunidadApex.getError());
				helper.mostrarToast('Problema convirtiendo la oportunidad en hipoteca', convertirOportunidadApex.getError()[0].message, 'error');
				component.find('botonConvertirOportunidad').set('v.disabled', false);
			}
		});
		$A.enqueueAction(convertirOportunidadApex);
	},

	abrirModalAutenticacionOtp: function(component) {
		component.set('v.cargarModales', true);
		component.set('v.modalAutenticacionOtp', true);
		window.setTimeout($A.getCallback(() => component.find('modalAutenticacionOtp').abrirModal(true)), 50);
	},

	abrirModalGdpr: function(component) {
		component.set('v.cargarModales', true);
		component.set('v.modalDerechosGdpr', true);
		window.setTimeout($A.getCallback(() => component.find('modalDerechosGdpr').abrirModal()), 50);
	},

	cerrarModalHijo: function(component, event) {
		component.set('v.' + event.getParam('nombreModal'), false);
		component.set('v.cargarModales', false);
	},

	calendarioDisponibilidadOnupdatecalendarios: function() {
		//const segunDisponibilidad = component.get('v.programarCitaTipoAsignacion') === 'Según disponibilidad';
		//helper.cambiarContenido(component, segunDisponibilidad);
	},

	calendarioDisponibilidadOnupdatefecha: function(component, event) {
		const inputFecha = component.find('modalProgramarInputFecha');
		component.set('v.modalProgramarInputFechaValueAnterior', inputFecha.get('v.value'));
		inputFecha.set('v.value', event.getParam('fecha').toISOString());

		$A.util.addClass(inputFecha, 'csbd_flash_dia');
		window.setTimeout($A.getCallback(() => $A.util.removeClass(inputFecha, 'csbd_flash_dia')), 600);

		$A.util.addClass(inputFecha, 'csbd_flash_hora');
		window.setTimeout($A.getCallback(() => $A.util.removeClass(inputFecha, 'csbd_flash_hora')), 600);
	},

	modalProgramarInputFechaOnchange: function(component, event) {
		const fechaOld = new Date(component.get('v.modalProgramarInputFechaValueAnterior'));
		const fechaNewIso = event.getParam('value');
		const fechaNew = new Date(fechaNewIso);

		const calendarioDisponibilidad = component.find('modalProgramarCalendarioDisponibilidad');
		calendarioDisponibilidad.set('v.fecha', fechaNew);

		const mismoDia = fechaOld.toDateString() === fechaNew.toDateString();
		if (!mismoDia) {
			calendarioDisponibilidad.scrollToHorarioLaboral();
		}
		component.set('v.modalProgramarInputFechaValueAnterior', fechaNewIso);
	},

	programarCitaTipoAsignacionOptionsOnchange: function(component, event, helper) {
		try {
			const tipoActual = component.get('v.programarCitaTipoAsignacion');
			const tipoNew = event.getParam('value');
			/*
			const acciones = $A.getCallback(() => {
			if (tipoNew === 'Según disponibilidad') {
				const fecha = new Date(component.find('modalProgramarInputFecha').get('v.value'));
				component.find('modalProgramarCalendarioDisponibilidad').set('v.fecha', fecha);
			}
			component.set('v.programarCitaTipoAsignacion', event.getParam('value'));
		});
		*/
			component.set('v.programarCitaTipoAsignacion', tipoNew);
			helper.cambiarSeccion(component, tipoActual, tipoNew);
		} catch (error) {
			console.error(error);
			helper.mostrarToast('Problema cambiando la sección', 'El proceso de cambio de sección ha fallado', 'error');
		}
	},

	buttonMenuProgramarOnselect: function(component, event) {
		if (event.getParam('value') === 'programarCita') {
			$A.enqueueAction(component.get('c.abrirModalProgramar'));
		} else if (event.getParam('value') === 'programarFirma') {
			$A.enqueueAction(component.get('c.abrirModalAgendarFirma'));
		}
	}
});