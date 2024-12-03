({
	init: function(component) {
		let checkPSResponsable = component.get('c.checkPSResponsable');
		checkPSResponsable.setCallback(this, response => {
			if (response.getState() === 'SUCCESS') {
				const retorno = response.getReturnValue();
				component.set('v.esResponsable', retorno.esResponsable);
				component.set('v.esAdministrador', retorno.esAdministrador);
			}
		});
		$A.enqueueAction(checkPSResponsable);
	},

	botonRefrescarBotoneraOnclick: function(component, event) {
		component.find('opportunityData').reloadRecord(true);
		const botonRefrescarBotonera = event.getSource();
		$A.util.addClass(botonRefrescarBotonera, 'rotar');
		//eslint-disable-next-line @lwc/lwc/no-async-operation
		window.setTimeout($A.getCallback(() => $A.util.removeClass(event.currentTarget, 'rotar')), 470);
	},

	oportunidadCargada: function(component, event, helper) {
		if (event.getParams().changeType === 'CHANGED') {
			component.find('opportunityData').reloadRecord();

		} else if (event.getParams().changeType === 'LOADED') {
			const oportunidad = component.get('v.oportunidad');
			const esPropietario = oportunidad.OwnerId === $A.get('$SObjectType.CurrentUser.Id');
			if (!esPropietario) {
				//actualizar owner oportunidad desde omnichannel
				let actualizarOwnerOportunidadApex = component.get('c.actualizarOwnerOportunidad');
				actualizarOwnerOportunidadApex.setParams({idOpportunity: component.get('v.recordId'), ownerId: component.get('v.oportunidad.OwnerId')});
				actualizarOwnerOportunidadApex.setCallback(this, response => {
					if (response.getState() === 'SUCCESS' && response.getReturnValue()) {
						$A.get('e.force:refreshView').fire();
					}
				});
				$A.enqueueAction(actualizarOwnerOportunidadApex);
			}

			const isClosed = oportunidad.IsClosed;
			const estado = oportunidad.CSBD_Estado__c;
			const imaginBank = oportunidad.CSBD_Empresa_Proveedora__c === 'imaginBank';
			const contactoInformado = Boolean(oportunidad.CSBD_Contact__c);
			let botonesActivos = {};
			component.set('v.esPropietario', esPropietario);
			if (esPropietario) {
				botonesActivos.botonTrasladoImagin = !isClosed && imaginBank && ['CMB', 'CMN'].includes(oportunidad.RecordType.Name);
				botonesActivos.botonPendienteInternoActivo = ['Activa', 'Pendiente Interno'].includes(estado);
				botonesActivos.botonCerrarActivo = estado === 'Activa';
				botonesActivos.botonReactivarActivo = isClosed && (component.get('v.esResponsable') && oportunidad.RecordType.Name !== 'Hipoteca' || oportunidad.RecordType.Name === 'Hipoteca');
				botonesActivos.botonAutenticarActivo = !isClosed && oportunidad.RecordType.Name === 'MAC' && oportunidad.AccountId;
				botonesActivos.botonAmpliarVencimiento = ['Activa', 'Pendiente Interno', 'Pendiente Cita', 'Pendiente Cliente'].includes(estado);
				botonesActivos.botonInformeSiaActivo = !isClosed && estado !== 'Nueva';

				if (contactoInformado || !contactoInformado && oportunidad.CSBD_No_Identificado__c) { //identificado
					botonesActivos.botonEnviarCorreoActivo = !isClosed && estado !== 'Nueva';
					botonesActivos.botonConvertirActivo = !isClosed;
					botonesActivos.botonEnviarNotificacionActivo = botonesActivos.botonEnviarCorreoActivo;
					botonesActivos.botonProgramarActivo = ['Activa', 'Pendiente Interno'].includes(estado);
					botonesActivos.botonDesprogramarActivo = estado === 'Pendiente Cita';
					botonesActivos.botonAgendarFirmaActivo = ['Activa', 'Pendiente Interno', 'Pendiente Cita', 'Pendiente Cliente'].includes(estado);
					botonesActivos.botonCancelarFirmaActivo = botonesActivos.botonAgendarFirmaActivo;
				}

				botonesActivos.botonTareaGestorActivo = contactoInformado && !isClosed && estado !== 'Nueva' ;
			}
			botonesActivos.botonCopiarNIFActivo = contactoInformado;
			botonesActivos.botonHistorialSolicitudesActivo = contactoInformado;
			botonesActivos.botonActualizarDatosRiesgoContactoActivo = contactoInformado;
			component.set('v.programarNuevoPropietarioSeleccionado', oportunidad.OwnerId);

			if (estado === 'Pendiente Cita') {
				component.set('v.fechaCitaFormateada', $A.localizationService.formatDateTime(oportunidad.CSBD_Fecha_Cita__c, 'd MMM HH:mm'));
			} else if (['Nueva', 'Activa'].includes(estado)) {
				botonesActivos.botonAsignacionAutoActivo = component.get('v.esAdministrador');
			}
			component.set('v.botonesActivos', botonesActivos);

			if (oportunidad.CSBD_Fecha_Firma__c) {
				component.set('v.fechaFirmaFormateada', $A.localizationService.formatDateTime(oportunidad.CSBD_Fecha_Firma__c, 'd MMM HH:mm'));
			}

			const familiaProducto = component.get('v.oportunidad.CSBD_Familia_Producto__c');
			if (familiaProducto === 'Hipotecas') {
				component.set('v.tipoOperativaConvertir', 'hipoteca');
			} else if (familiaProducto === 'Préstamos') {
				component.set('v.tipoOperativaConvertir', 'préstamo');
			}

		} else if (event.getParams().changeType === 'ERROR') {
			console.error(component.get('v.errorLds'));
			helper.mostrarToast('Sin datos de la oportunidad', 'No ha sido posible recuperar los datos de la oportunidad: ' + component.get('v.errorLds'), 'error');
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
			} else if (response.getState() === 'ERROR') {
				helper.mostrarToast('Problema realizando el traspaso a Imagin', JSON.stringify(trasladoImaginBank.getError()[0].message), 'error');
			}
			$A.get('e.force:refreshView').fire();
		});
		$A.enqueueAction(trasladoImaginBank);
	},

	copiarNIF: function(component, event, helper) {
		let oportunidad = component.get('v.oportunidad');
		//Copiar NIF al portapapeles
		if (oportunidad.Account.CC_Numero_Documento__c) {
			helper.copiarTextoAlPortapapeles(oportunidad.Account.CC_Numero_Documento__c, 'Se ha copiado el NIF ' + oportunidad.Account.CC_Numero_Documento__c + ' (' + oportunidad.Account.Name + ') al portapapeles.');
		} else {
			helper.mostrarToast('No se ha podido obtener el NIF', 'La cuenta no tiene el número de documento de identidad informado.', 'warning');
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
		$A.util.addClass(component.find('modalboxProrrogaFechaAltaVencimiento'), 'slds-fade-in-open');
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
			$A.util.addClass(component.find('modalboxEnviarCorreo'), 'slds-fade-in-open');
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
		$A.util.removeClass(component.find('modalboxEnviarCorreo'), 'slds-fade-in-open');
		$A.util.removeClass(component.find('modalBackdrop'), 'slds-backdrop_open');
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
			$A.util.addClass(component.find('modalboxEnviarNotificacion'), 'slds-fade-in-open');
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
		$A.util.removeClass(component.find('modalboxEnviarNotificacion'), 'slds-fade-in-open');
		$A.util.removeClass(component.find('modalBackdrop'), 'slds-backdrop_open');
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
						//Toast OK, ocultar modal y refrescar la vista
						helper.mostrarToast('Se envió SMS', 'Se envió correctamente el SMS al destinatario ' + destinatario, 'success');
						$A.enqueueAction(component.get('c.cerrarModalEnviarNotificacion'));
						$A.get('e.force:refreshView').fire();
					} else {
						//Toast KO
						helper.mostrarToast('No se pudo enviar el SMS', resultado, 'error');
					}
				} else if (response.getState() === 'ERROR') {
					helper.mostrarToast('No se pudo enviar el SMS', enviarSMS.getError()[0].message, 'error');
				}
				//Se vuelve a habilitar el botón
				component.set('v.enviarNotificacionEnvioDeshabilitado', false);
			});
			$A.enqueueAction(enviarSMS);
		}
	},

	abrirModalAgendarFirma: function(component, event, helper) {
		//Mostrar modal
		component.set('v.cargarModales', true);
		$A.util.addClass(component.find('modalboxAgendarCita'), 'slds-fade-in-open');
		$A.util.addClass(component.find('modalBackdrop'), 'slds-backdrop_open');
		helper.seleccionarControl(component, 'cerrarModalAgendarFirma', 50);
	},

	cerrarModalAgendarFirma: function(component) {
		//Ocultar modal
		$A.util.removeClass(component.find('modalboxAgendarCita'), 'slds-fade-in-open');
		$A.util.removeClass(component.find('modalBackdrop'), 'slds-backdrop_open');
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
				helper.mostrarToast('Se programó firma', 'Se programó una firma con el cliente para el ' + helper.formatearFecha(Date.parse(inputAgendarFirma.get('v.value'))), 'success');
				$A.enqueueAction(component.get('c.cerrarModalAgendarFirma'));
				$A.get('e.force:refreshView').fire();
			}).catch(textoError => {
				console.error(textoError);
				helper.mostrarToast('error', textoError, 'error');
			}).finally(() => botonAceptar.set('v.disabled', false));
		}
	},

	abrirModalCancelarFirma: function(component, event, helper) {
		component.set('v.cargarModales', true);
		$A.util.addClass(component.find('modalboxCancelarFirma'), 'slds-fade-in-open');
		$A.util.addClass(component.find('modalBackdrop'), 'slds-backdrop_open');
		helper.seleccionarControl(component, 'modalboxCancelarFirmaCerrar', 50);
	},

	cerrarModalCancelarFirma: function(component) {
		$A.util.removeClass(component.find('modalboxCancelarFirma'), 'slds-fade-in-open');
		$A.util.removeClass(component.find('modalBackdrop'), 'slds-backdrop_open');
	},

	cancelarFirma: function(component, event, helper) {
		helper.apex(component, 'cancelarFirmaApex', {recordId: component.get('v.recordId')})
		.then(firmaCancelada => {
			if (firmaCancelada) {
				helper.mostrarToast('Se canceló firma', 'Se ha cancelado la firma para el ' + helper.formatearFecha(firmaCancelada.StartDateTime), 'info');
				$A.get('e.force:refreshView').fire();
			} else {
				helper.mostrarToast('Sin firmas programadas', 'No existían firmas pendientes con el cliente que cancelar.', 'info');
			}
		}).catch(textoError => {
			helper.mostrarToast('No se pudo cancelar firma', textoError, 'error');
		});
		$A.enqueueAction(component.get('c.cerrarModalCancelarFirma'));
	},

	abrirModalProgramar: function(component, event, helper) {
		component.set('v.cargarModales', true);
		if (!component.find('inputProgramarFecha').get('v.value')) {
			component.find('inputProgramarFecha').set('v.value', new Date().toISOString());
		}
		$A.util.addClass(component.find('modalboxProgramar'), 'slds-fade-in-open');
		$A.util.addClass(component.find('modalBackdrop'), 'slds-backdrop_open');
		helper.seleccionarControl(component, 'modalboxProgramarCancelar', 50);
	},

	cerrarModalProgramar: function(component) {
		$A.util.removeClass(component.find('modalboxProgramar'), 'slds-fade-in-open');
		$A.util.removeClass(component.find('modalBackdrop'), 'slds-backdrop_open');
	},

	programar: function(component, event, helper) {
		let inputProgramarFecha = component.find('inputProgramarFecha');
		let programarNuevoPropietarioSeleccionado = component.get('v.programarNuevoPropietarioSeleccionado');
		//Si se mantiene el propietario de la oportunidad se recupera el usuario en concreto
		let propietarioId = null;
		if (!component.get('v.programarReasignacionAutomatica')) {
			if (typeof programarNuevoPropietarioSeleccionado !== 'string') {
				component.find('inputProgramarBuscarPropietario').reportValidity();
			} else {
				propietarioId = programarNuevoPropietarioSeleccionado;
			}
		}
		if (typeof programarNuevoPropietarioSeleccionado === 'string') {
			//Se programa para una fecha y hora
			inputProgramarFecha.showHelpMessageIfInvalid();

			if (inputProgramarFecha.get('v.validity').valid) {
				let argsProgramarCita = {
					recordId: component.get('v.recordId'),
					asignacionAuto: component.find('inputProgramarAsignacionAuto').get('v.checked'),
					comprobarContacto: component.find('inputComprobarContacto').get('v.checked'),
					idPropietario: propietarioId,
					startDateTime: inputProgramarFecha.get('v.value')
				};
				helper.apex(component, 'programarCita', argsProgramarCita)
				.then(() => {
					helper.mostrarToast('Se programó cita', 'Se programó una cita con el cliente para el ' + helper.formatearFecha(Date.parse(inputProgramarFecha.get('v.value'))), 'success');
					$A.get('e.force:refreshView').fire();
				})
				.catch(textoError => helper.mostrarToast('error', textoError, 'error'));

				$A.enqueueAction(component.get('c.cerrarModalProgramar'));
			}
		}
	},

	abrirModalDesprogramar: function(component, event, helper) {
		//Mostrar modal
		component.set('v.cargarModales', true);
		$A.util.addClass(component.find('modalboxDesprogramar'), 'slds-fade-in-open');
		$A.util.addClass(component.find('modalBackdrop'), 'slds-backdrop_open');
		helper.seleccionarControl(component, 'cerrarModalDesprogramar', 50);
	},

	cerrarModalDesprogramar: function(component) {
		//Ocultar modal
		$A.util.removeClass(component.find('modalboxDesprogramar'), 'slds-fade-in-open');
		$A.util.removeClass(component.find('modalBackdrop'), 'slds-backdrop_open');
	},

	desprogramar: function(component, event, helper) {
		helper.apex(component, 'desprogramarCita', {recordId: component.get('v.recordId')})
		.then(eventoDesprogramado => {
			$A.get('e.force:refreshView').fire();
			if (eventoDesprogramado) {
				helper.mostrarToast('Se desprogramó cita', 'Se ha cancelado la cita para el ' + helper.formatearFecha(eventoDesprogramado.StartDateTime), 'info');
			} else {
				helper.mostrarToast('Sin citas programadas', 'No existían citas pendientes con el cliente que cancelar.', 'info');
			}
		}).catch(textoError => {
			helper.mostrarToast('No se pudo desprogramar cita', textoError, 'error');
		});
		$A.enqueueAction(component.get('c.cerrarModalDesprogramar'));
	},

	abrirModalCerrar: function(component, event, helper) {
		if (component.get('v.oportunidad.CSBD_Producto__c') === null) {
			helper.mostrarToast('Oportunidad sin producto', 'Es necesario que la oportunidad tenga un producto para poder cerrarla.', 'info');
		} else {
			component.set('v.cargarModales', true);

			//Preparar opciones del desplegable de etapas finales
			let etapasFinales;
			if (component.get('v.oportunidad.CSBD_Contact__c') || component.get('v.oportunidad.CSBD_No_Identificado__c')) {
				etapasFinales = [
					{label: 'Formalizada', value: 'Formalizada'},
					{label: 'Perdida', value: 'Perdida'},
					{label: 'Rechazada', value: 'Rechazada'}
				];
			} else {
				//Si el contacto de la oportunidad no está informado solo se permite rechazar
				etapasFinales = [
					{label: 'Rechazada', value: 'Rechazada'}
				];
			}
			component.set('v.cerrarEtapas', etapasFinales);
			if (etapasFinales.length === 1) {
				component.find('inputCerrarEtapa').set('v.value', etapasFinales[0].value);
				$A.enqueueAction(component.get('c.seleccionarCerrarEtapa'));
			}

			//Abrir modal
			$A.util.addClass(component.find('modalboxCerrar'), 'slds-fade-in-open');
			$A.util.addClass(component.find('modalBackdrop'), 'slds-backdrop_open');

			//Foco en el desplegable de etapa final o de resolución
			if (etapasFinales.length !== 1) {
				helper.seleccionarControl(component, 'inputCerrarEtapa', 50);
			}
		}
	},

	cerrarModalCerrar: function(component) {
		$A.util.removeClass(component.find('modalboxCerrar'), 'slds-fade-in-open');
		$A.util.removeClass(component.find('modalBackdrop'), 'slds-backdrop_open');
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

		let obtenerResoluciones = component.get('c.obtenerResoluciones');
		obtenerResoluciones.setParams({
			producto: component.get('v.oportunidad.CSBD_Producto__c'),
			nombreRecordType: component.get('v.oportunidad.RecordType.Name'),
			etapa: resultado
		});
		obtenerResoluciones.setCallback(this, response => {
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
		$A.enqueueAction(obtenerResoluciones);
	},

	cerrar: function(component, event, helper) {
		let campos = new Map();

		let inputCerrarEtapa = component.find('inputCerrarEtapa');
		inputCerrarEtapa.checkValidity();
		inputCerrarEtapa.reportValidity();

		let inputCerrarResolucion = component.find('inputCerrarResolucion');
		inputCerrarResolucion.checkValidity();
		inputCerrarResolucion.reportValidity();

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

		if (inputCerrarEtapa.get('v.validity').valid && inputCerrarResolucion.get('v.validity').valid) {
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
					helper.mostrarToast('Se cerró oportunidad ' + response.getReturnValue().CSBD_Identificador__c, 'La oportunidad se cerró satisfactoriamente.', 'success');
					$A.enqueueAction(component.get('c.cerrarModalCerrar'));
					$A.get('e.force:refreshView').fire();
				} else {
					helper.mostrarToast('No se ha podido cerrar la oportunidad', cerrarOportunidad.getError()[0].message, 'error');
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
		} else {
			component.set('v.mostrarTipoBonificado', false);
		}
	},

	abrirModalReactivar: function(component, event, helper) {
		component.set('v.cargarModales', true);
		//Por defecto se volverá a la penúltima etapa de ventas
		component.find('inputReactivarEtapa').set('v.value', component.get('v.oportunidad.CSBD_Ultima_Etapa_Ventas__c'));

		$A.util.addClass(component.find('modalboxReactivar'), 'slds-fade-in-open');
		$A.util.addClass(component.find('modalBackdrop'), 'slds-backdrop_open');
		helper.seleccionarControl(component, 'inputReactivarEtapa', 50);
	},

	cerrarModalReactivar: function(component) {
		$A.util.removeClass(component.find('modalboxReactivar'), 'slds-fade-in-open');
		$A.util.removeClass(component.find('modalBackdrop'), 'slds-backdrop_open');
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
					$A.enqueueAction(component.get('c.cerrarModalReactivar'));
					$A.get('e.force:refreshView').fire();
				} else {
					helper.mostrarToast('No se ha podido cerrar la oportunidad', response.getReturnValue(), 'error');
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
		//eslint-disable-next-line @lwc/lwc/no-async-operation
		component.set('v.otrasOperativasTimeout', window.setTimeout($A.getCallback(() => $A.util.removeClass(popover, 'visible')), 220));
	},

	modalboxEnviarCorreoTeclaPulsada: function(component, event) {
		if (event.keyCode === 27) { //ESC
			$A.enqueueAction(component.get('c.cerrarModalEnviarCorreo'));
		}
	},

	modalboxEnviarNotificacionTeclaPulsada: function(component, event) {
		if (event.keyCode === 27) { //ESC
			$A.enqueueAction(component.get('c.cerrarModalEnviarNotificacion'));
		}
	},

	modalboxAgendarCitaTeclaPulsada: function(component, event) {
		if (event.keyCode === 27) { //ESC
			$A.enqueueAction(component.get('c.cerrarModalAgendarFirma'));
		}
	},

	modalboxProgramarTeclaPulsada: function(component, event) {
		if (event.keyCode === 27) { //ESC
			$A.enqueueAction(component.get('c.cerrarModalProgramar'));
		}
	},

	modalboxCerrarTeclaPulsada: function(component, event) {
		if (event.keyCode === 27) { //ESC
			$A.enqueueAction(component.get('c.cerrarModalCerrar'));
		}
	},

	modalboxReactivarTeclaPulsada: function(component, event) {
		if (event.keyCode === 27) { //ESC
			$A.enqueueAction(component.get('c.cerrarModalReactivar'));
		}
	},

	modalboxDesprogramarTeclaPulsada: function(component, event) {
		if (event.keyCode === 27) { //ESC
			$A.enqueueAction(component.get('c.cerrarModalDesprogramar'));
		}
	},

	modalboxCancelarFirmaTeclaPulsada: function(component, event) {
		if (event.keyCode === 27) { //ESC
			$A.enqueueAction(component.get('c.cerrarModalCancelarFirma'));
		}
	},

	modalboxAsignarAutoTeclaPulsada: function(component, event) {
		if (event.keyCode === 27) { //ESC
			$A.enqueueAction(component.get('c.cerrarModalAsignarAuto'));
		}
	},

	modalboxDuplicarTeclaPulsada: function(component, event) {
		if (event.keyCode === 27) { //ESC
			$A.enqueueAction(component.get('c.cerrarModalDuplicar'));
		}
	},

	modalConvertirAHipotecaTeclaPulsada: function(component, event) {
		if (event.keyCode === 27) { //ESC
			$A.enqueueAction(component.get('c.cerrarModalConvertirAHipoteca'));
		}
	},

	modalboxPendienteInternoTeclaPulsada: function(component, event) {
		if (event.keyCode === 27) { //ESC
			$A.enqueueAction(component.get('c.cerrarModalPendienteInterno'));
		}
	},

	modalboxProrrogaFechaAltaVencimientoTeclaPulsada: function(component, event) {
		if (event.keyCode === 27) { //ESC
			$A.enqueueAction(component.get('c.cerrarModalProrrogaFechaAltaVencimiento'));
		}
	},

	abrirModalAsignarAuto: function(component, event, helper) {
		component.set('v.cargarModales', true);
		$A.util.addClass(component.find('modalboxAsignarAuto'), 'slds-fade-in-open');
		$A.util.addClass(component.find('modalBackdrop'), 'slds-backdrop_open');
		helper.seleccionarControl(component, 'modalboxAsignarAutoCancelar', 50);
	},

	abrirModalPendienteInterno: function(component, event, helper) {
		component.set('v.cargarModales', true);

		const recordType = component.get('v.oportunidad.RecordType.DeveloperName');
		const rtsSinMotivoPendienteInterno = ['CSBD_Hipoteca', 'CSBD_Feedback', 'CSBD_PROAutomatica', 'CSBD_Soporte_Digital', 'CSBD_MAC'];
		const mostrarInputMotivos = component.get('v.oportunidad.CSBD_Estado__c') !== 'Pendiente Interno' && !rtsSinMotivoPendienteInterno.includes(recordType);
		component.set('v.pendienteInternoMostrarInputMotivos', mostrarInputMotivos);

		if (component.get('v.oportunidad.CSBD_Estado__c') === 'Pendiente Interno') {
			component.set('v.modalPendienteInternoTexto', '¿Quieres reanudar la gestión de la oportunidad?');
			component.find('pendienteInternoAceptar').set('v.label', 'Reactivar');
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
				/*
				} else if(recordTypeOpportunity === 'CSBD_Hipoteca'){
					motivos = [
						{label: 'Aprobada pte. Escritura', value: 'Aprobada pte. Escritura'},
						{label: 'Aprobada pte. FEIN', value: 'Aprobada pte. FEIN'},
						{label: 'Aprobada pte. Homologación', value: 'Aprobada pte. Homologación'},
						{label: 'Aprobada pte. OK cliente', value: 'Aprobada pte. OK cliente'},
						{label: 'Aprobada pte. Tasación', value: 'Aprobada pte. Tasación'},
						{label: 'Cliente no localizado', value: 'Cliente no localizado'},
						{label: 'Interno', value: 'Interno'},
						{label: 'Pendiente Acta Notarial', value: 'Pendiente Acta Notarial'},
						{label: 'Pendiente de documentación', value: 'Pendiente de documentación'},
						{label: 'Pendiente de firma', value: 'Pendiente de firma'},
						{label: 'Pendiente de tasación', value: 'Pendiente de tasación'},
						{label: 'Pendiente escrituración', value: 'Pendiente escrituración'},
						{label: 'Pendiente informe', value: 'Pendiente informe'},
						{label: 'Pendiente iniciar SIA', value: 'Pendiente iniciar SIA'},
						{label: 'Pendiente OK cliente', value: 'Pendiente OK cliente'},
						{label: 'Propuesta viable enviada', value: 'Propuesta viable enviada'},
						{label: 'SIA en trámite', value: 'SIA en trámite'},
						{label: 'Solicitada Prov. de Fondos CV/Hip.', value: 'Solicitada Prov. de Fondos CV/Hip.'},
						{label: 'Solicitar Emisión Cheques Bancarios', value: 'Solicitar Emisión Cheques Bancarios'},
						{label: 'Solicitud CIRBE/Nota Simple', value: 'Solicitud CIRBE/Nota Simple'},
						{label: 'Trasladada CARP', value: 'Trasladada CARP'},
						{label: 'Trasladada DT Tarifa', value: 'Trasladada DT Tarifa'}
					];
				}*/
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

		$A.util.addClass(component.find('modalboxPendienteInterno'), 'slds-fade-in-open');
		$A.util.addClass(component.find('modalBackdrop'), 'slds-backdrop_open');
		helper.seleccionarControl(component, 'pendienteInternoCancelar', 50);
	},

	cerrarModalAsignarAuto: function(component) {
		$A.util.removeClass(component.find('modalboxAsignarAuto'), 'slds-fade-in-open');
		$A.util.removeClass(component.find('modalBackdrop'), 'slds-backdrop_open');
	},

	cerrarModalProrrogaFechaAltaVencimiento: function(component) {
		$A.util.removeClass(component.find('modalboxProrrogaFechaAltaVencimiento'), 'slds-fade-in-open');
		$A.util.removeClass(component.find('modalBackdrop'), 'slds-backdrop_open');
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
		$A.util.removeClass(component.find('modalboxPendienteInterno'), 'slds-fade-in-open');
		$A.util.removeClass(component.find('modalBackdrop'), 'slds-backdrop_open');
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
				$A.util.addClass(component.find('modalboxDuplicar'), 'slds-fade-in-open');
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
		$A.util.removeClass(component.find('modalboxDuplicar'), 'slds-fade-in-open');
		$A.util.removeClass(component.find('modalBackdrop'), 'slds-backdrop_open');
	},

	cerrarModalConvertirAHipoteca: function(component) {
		$A.util.removeClass(component.find('modalConvertirAHipoteca'), 'slds-fade-in-open');
		$A.util.removeClass(component.find('modalBackdrop'), 'slds-backdrop_open');
	},

	asignarAuto: function(component, event, helper) {
		helper.apex(component, 'solicitarAltaOmnichannel', {idOportunidad: component.get('v.recordId')})
		.then(() => {
			helper.mostrarToast('Asignación automática solicitada', 'Asignación automática solicitada a Omnichannel para la oportunidad ' + component.get('v.oportunidad.CSBD_Identificador__c'), 'success');
			$A.enqueueAction(component.get('c.cerrarModalAsignarAuto'));
			//eslint-disable-next-line @lwc/lwc/no-async-operation
			window.setTimeout($A.getCallback(() => $A.get('e.force:refreshView').fire()), 1000);
		}).catch(textoError => helper.mostrarToast('Problema solicitando asignación automática', textoError, 'error'));
	},

	menuFinalizarAsignarAuto: function(component, event, helper) {
		if (event.getParam('value') === 'finalizarAsignarAuto') {
			helper.apex(component, 'solicitarBajaOmnichannel', {idOportunidad: component.get('v.recordId')})
			.then(() => {
				helper.mostrarToast('Fin de asignación automática solicitado', 'Fin de asignación automática solicitado a Omnichannel para la oportunidad ' + component.get('v.oportunidad.CSBD_Identificador__c'), 'info');
				$A.enqueueAction(component.get('c.cerrarModalAsignarAuto'));
				//eslint-disable-next-line @lwc/lwc/no-async-operation
				window.setTimeout($A.getCallback(() => $A.get('e.force:refreshView').fire()), 1000);
			}).catch(textoError => helper.mostrarToast('Problema solicitando asignación automática', textoError, 'error'));
		}
	},

	actualizarDatosRiesgo: function(component, event, helper) {
		helper.apex(component, 'actualizarDatosRiesgoContacto', {idOportunidad: component.get('v.recordId')})
		.then(() => {
			helper.mostrarToast('Se actualizó la información financiera del contacto', 'Se actualizó la información financiera del contacto', 'success');
			//eslint-disable-next-line @lwc/lwc/no-async-operation
			window.setTimeout($A.getCallback(() => $A.get('e.force:refreshView').fire()), 1000);
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
				const fecha = new Date(response.getReturnValue());
				let fechaString = `${fecha.getDate()}/${fecha.getMonth() + 1}/${fecha.getFullYear()}`;
				fechaString += `, ${(fecha.getHours() < 10 ? '0' : '') + fecha.getHours()}:${(fecha.getMinutes() < 10 ? '0' : '') + fecha.getMinutes()}`;
				helper.mostrarToast('Se amplió el plazo de vencimiento', 'La nueva fecha de vencimiento de alta es ' + fechaString, 'success');
				$A.enqueueAction(component.get('c.cerrarModalProrrogaFechaAltaVencimiento'));
				$A.get('e.force:refreshView').fire();
			} else if (response.getState() === 'ERROR') {
				console.error(ampliarVencimiento.getError());
				helper.mostrarToast('Problema posponiendo la fecha de vencimiento', ampliarVencimiento.getError()[0].message, 'error');
			}
			component.find('prorrogaFechaAltaVencimientoContinuar').set('v.disabled', false);
		});
		$A.enqueueAction(ampliarVencimiento);
	},

	abrirModalInformeSia: function(component, event, helper) {
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
			if (datosCalculoDti.segundoTitular) {
				ingresosTitular2 = parseInt(datosCalculoDti.segundoTitular.nominasNetas.ingresos, 10);
				totalIngresosTitulares += ingresosTitular2;
			}
		}

		let valorTtraslados = component.get('v.oportunidad.Account.CC_Numero_Documento__c') + '\n';
		valorTtraslados += '\nCanal: ' + component.get('v.oportunidad.RecordType.Name');
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
		component.find('modalInformeSiaTextareaTraslados').set('v.value', valorTtraslados);

		//Aprobada
		let valorAprobada = 'Aprobada - ' + component.get('v.oportunidad.Account.CC_Numero_Documento__c');
		valorAprobada = valorAprobada.replace(/null\n/g, '\n');
		component.find('modalInformeSiaTextareaAprobada').set('v.value', valorAprobada);

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
		component.find('modalInformeSiaTextareaFechaFirma').set('v.value', valorFechaFirma);

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
		component.find('modalInformeSiaTextareaFirmada').set('v.value', valorFirmada);

		$A.util.addClass(component.find('modalBackdrop'), 'slds-backdrop_open');
		$A.util.addClass(component.find('modalInformeSia'), 'slds-fade-in-open');
		//eslint-disable-next-line @lwc/lwc/no-async-operation
		window.setTimeout($A.getCallback(() => component.find('modalInformeSiaCancelar').focus()), 200);
	},

	cerrarModalInformeSia: function(component) {
		$A.util.removeClass(component.find('modalInformeSia'), 'slds-fade-in-open');
		$A.util.removeClass(component.find('modalBackdrop'), 'slds-backdrop_open');
	},

	abrirModalInformeSia2: function(component, event, helper) {
		component.set('v.cargarModales', true);

		const opp = component.get('v.oportunidad');

		let ltv = null, dtiNomina = null, dtiNominaBonificado = null, dtiIrpf = null, dtiIrpfBonificado = null;
		let totalNominas = null, totalIrpf = null;
		let ingresosTotales, deudasTotales = null;
		let totalIngresosNomina = 0, totalIngresosIrpf = 0; //Sin multiplicar por las mensualidades.

		const importeCompraventa = opp.CSBD_PrecioInmueble__c ? parseFloat(opp.CSBD_PrecioInmueble__c) : null;
		const importeHipoteca = opp.Amount ? parseFloat(opp.Amount) : 0;
		const plazo = opp.CSBD_Now_Plazo__c ? opp.CSBD_Now_Plazo__c : 0;

		let fondosPropios = importeCompraventa - importeHipoteca;
		let totalFondosPropios = fondosPropios;
		totalFondosPropios -= opp.CSBD_AportacionInicial__c ? parseFloat(opp.CSBD_AportacionInicial__c) : 0;
		totalFondosPropios -= opp.CSBD_OC_Donacion__c ? parseFloat(opp.CSBD_OC_Donacion__c) : 0;

		const tasa = 1 + opp.CSBD_TIN_Inicial__c / 100 / 12 - 1;
		let tasaBonificada;
		const interesBonificado = opp.CSBD_InteresBonificado__c >= 0 ? opp.CSBD_InteresBonificado__c : 0;
		if (interesBonificado) {
			//eslint-disable-next-line no-extra-parens
			tasaBonificada = (1 + (interesBonificado / 100) / 12) - 1;
		} else {
			tasaBonificada = tasa;
		}

		let cuotaBonificada = null, cuotaSinBonificar = null;
		if (plazo) {
			if (tasa === 0) {
				cuotaSinBonificar = importeHipoteca / (plazo * 12) / 12;
				cuotaBonificada = importeHipoteca / (plazo * 12) / 12;
			} else {
				const factorPresenteValorFuturo = Math.pow(1 + tasa, plazo);
				const factorPresenteValorFuturoBonificado = Math.pow(1 + tasaBonificada, plazo);
				cuotaSinBonificar = -tasa * (-importeHipoteca * factorPresenteValorFuturo) / (factorPresenteValorFuturo - 1);
				cuotaBonificada = -tasaBonificada * (-importeHipoteca * factorPresenteValorFuturoBonificado) / (factorPresenteValorFuturoBonificado - 1);
			}
		}

		let datosCalculo;
		if (component.get('v.oportunidad.CSBD_Datos_Calculo_DTI__c')) {
			try {
				datosCalculo = JSON.parse(component.get('v.oportunidad.CSBD_Datos_Calculo_DTI__c'));
				fondosPropios += importeCompraventa * datosCalculo.porcentajeGastosConstitucion;
				totalFondosPropios = fondosPropios;
				totalFondosPropios -= opp.CSBD_AportacionInicial__c ? parseFloat(opp.CSBD_AportacionInicial__c) : 0;
				totalFondosPropios -= opp.CSBD_OC_Donacion__c ? parseFloat(opp.CSBD_OC_Donacion__c) : 0;
				totalFondosPropios -= datosCalculo.ahorro ? parseFloat(datosCalculo.ahorro) : 0;

				if (Object.keys(datosCalculo.primerTitular).length) {
					const t1 = datosCalculo.primerTitular;
					let ingresosTit1Nomina = parseFloat(t1.nominasNetas.ingresos) * parseFloat(t1.nominasNetas.numPagosImpuestos);
					ingresosTit1Nomina += parseFloat(t1.otrosIngresos.ingresos) * parseFloat(t1.otrosIngresos.numPagosImpuestos);
					ingresosTit1Nomina += parseFloat(t1.ingresosAlquiler.ingresos) * parseFloat(t1.ingresosAlquiler.numPagosImpuestos);

					let ingresosTit1Irpf = parseFloat(t1.ingresosNetosIrpf.ingresos) - parseFloat(t1.ingresosNetosIrpf.numPagosImpuestos);
					ingresosTit1Irpf += parseFloat(t1.otrosIngresos.ingresos) * parseFloat(t1.otrosIngresos.numPagosImpuestos);
					ingresosTit1Irpf += parseFloat(t1.ingresosAlquiler.ingresos) * parseFloat(t1.ingresosAlquiler.numPagosImpuestos);

					totalNominas = parseFloat(t1.nominasNetas.ingresos) * parseFloat(t1.nominasNetas.numPagosImpuestos);
					totalIrpf = parseFloat(t1.ingresosNetosIrpf.ingresos) - parseFloat(t1.ingresosNetosIrpf.numPagosImpuestos);
					ingresosTotales = ingresosTit1Nomina ? ingresosTit1Nomina : ingresosTit1Irpf;

					totalIngresosNomina += parseFloat(t1.nominasNetas.ingresos) * parseFloat(t1.nominasNetas.numPagosImpuestos) / 12;
					totalIngresosNomina += parseFloat(t1.otrosIngresos.ingresos) * parseFloat(t1.otrosIngresos.numPagosImpuestos) / 12;
					totalIngresosNomina += parseFloat(t1.ingresosAlquiler.ingresos) * parseFloat(t1.ingresosAlquiler.numPagosImpuestos) / 12 / 2;

					totalIngresosIrpf += (parseFloat(t1.ingresosNetosIrpf.ingresos) - parseFloat(t1.ingresosNetosIrpf.numPagosImpuestos)) / 12;
					totalIngresosIrpf += parseFloat(t1.otrosIngresos.ingresos) * parseFloat(t1.otrosIngresos.numPagosImpuestos) / 12;
					totalIngresosIrpf += parseFloat(t1.ingresosAlquiler.ingresos) * parseFloat(t1.ingresosAlquiler.numPagosImpuestos) / 12 / 2;
				}

				if (Object.keys(datosCalculo.segundoTitular).length) {
					const t2 = datosCalculo.segundoTitular;
					let ingresosTit2Nomina = parseFloat(t2.nominasNetas.ingresos) * parseFloat(t2.nominasNetas.numPagosImpuestos);
					ingresosTit2Nomina += parseFloat(t2.otrosIngresos.ingresos) * parseFloat(t2.otrosIngresos.numPagosImpuestos);
					ingresosTit2Nomina += parseFloat(t2.ingresosAlquiler.ingresos) * parseFloat(t2.ingresosAlquiler.numPagosImpuestos);

					let ingresosTit2Irpf = parseFloat(t2.ingresosNetosIrpf.ingresos) - parseFloat(t2.ingresosNetosIrpf.numPagosImpuestos);
					ingresosTit2Irpf += parseFloat(t2.otrosIngresos.ingresos) * parseFloat(t2.otrosIngresos.numPagosImpuestos);
					ingresosTit2Irpf += parseFloat(t2.ingresosAlquiler.ingresos) * parseFloat(t2.ingresosAlquiler.numPagosImpuestos);

					totalNominas += parseFloat(t2.nominasNetas.ingresos) * parseFloat(t2.nominasNetas.numPagosImpuestos);
					totalIrpf += parseFloat(t2.ingresosNetosIrpf.ingresos) - parseFloat(t2.ingresosNetosIrpf.numPagosImpuestos);
					ingresosTotales += ingresosTit2Nomina > 0 ? ingresosTit2Nomina : ingresosTit2Irpf;

					totalIngresosNomina += parseFloat(t2.nominasNetas.ingresos) * parseFloat(t2.nominasNetas.numPagosImpuestos) / 12;
					totalIngresosNomina += parseFloat(t2.otrosIngresos.ingresos) * parseFloat(t2.otrosIngresos.numPagosImpuestos) / 12;
					totalIngresosNomina += parseFloat(t2.ingresosAlquiler.ingresos) * parseFloat(t2.ingresosAlquiler.numPagosImpuestos) / 12 / 2;

					totalIngresosIrpf += (parseFloat(t2.ingresosNetosIrpf.ingresos) - parseFloat(t2.ingresosNetosIrpf.numPagosImpuestos)) / 12;
					totalIngresosIrpf += parseFloat(t2.otrosIngresos.ingresos) * parseFloat(t2.otrosIngresos.numPagosImpuestos) / 12;
					totalIngresosIrpf += parseFloat(t2.ingresosAlquiler.ingresos) * parseFloat(t2.ingresosAlquiler.numPagosImpuestos) / 12 / 2;
				}

				deudasTotales = parseFloat(datosCalculo.deuda.hipoteca.primerTitular);
				deudasTotales += parseFloat(datosCalculo.deuda.prestamo.primerTitular);
				deudasTotales += parseFloat(datosCalculo.deuda.tarjetas.primerTitular);
				deudasTotales += parseFloat(datosCalculo.deuda.alquiler.primerTitular);
				deudasTotales += parseFloat(datosCalculo.deuda.hipoteca.segundoTitular);
				deudasTotales += parseFloat(datosCalculo.deuda.prestamo.segundoTitular);
				deudasTotales += parseFloat(datosCalculo.deuda.tarjetas.segundoTitular);
				deudasTotales += parseFloat(datosCalculo.deuda.alquiler.segundoTitular);
				deudasTotales += parseFloat(cuotaSinBonificar);

				let deudasTotalesBonificacion = parseFloat(datosCalculo.deuda.hipoteca.primerTitular);
				deudasTotalesBonificacion += parseFloat(datosCalculo.deuda.prestamo.primerTitular);
				deudasTotalesBonificacion += parseFloat(datosCalculo.deuda.tarjetas.primerTitular);
				deudasTotalesBonificacion += parseFloat(datosCalculo.deuda.alquiler.primerTitular);
				deudasTotalesBonificacion += parseFloat(datosCalculo.deuda.hipoteca.segundoTitular);
				deudasTotalesBonificacion += parseFloat(datosCalculo.deuda.prestamo.segundoTitular);
				deudasTotalesBonificacion += parseFloat(datosCalculo.deuda.tarjetas.segundoTitular);
				deudasTotalesBonificacion += parseFloat(datosCalculo.deuda.alquiler.segundoTitular);
				deudasTotalesBonificacion += parseFloat(cuotaBonificada);

				if (deudasTotales && plazo) {
					if (totalIngresosNomina) {
						dtiNomina = deudasTotales / totalIngresosNomina;
						dtiNominaBonificado = deudasTotalesBonificacion / totalIngresosNomina;
					}

					if (totalIngresosIrpf) {
						dtiIrpf = deudasTotales / totalIngresosIrpf;
						dtiIrpfBonificado = deudasTotalesBonificacion / totalIngresosIrpf;
					}
				}

			} catch (error) {
				console.error('Error parsing JSON (entrevista)', error);
				return;
			}
		}

		let datosFincas;
		if (component.get('v.oportunidad.CSBD_FincasJson__c')) {
			try {
				datosFincas = JSON.parse(component.get('v.oportunidad.CSBD_FincasJson__c'));


			} catch (error) {
				console.error('Error parsing JSON (fincas)', error);
				return;
			}
		}

		if (opp.Amount && opp.CSBD_PrecioInmueble__c) {
			ltv = opp.Amount / opp.CSBD_PrecioInmueble__c;
		}

		let texto = `OPERACIÓN SOLICITADA

FINALIDAD. ARGUMENTADA Y ACREDITADA DOCUMENTALMENTE

Operación de cliente/s procedente/s de un LEAD generado por el canal ${opp.CSBD_OC_Canal_Entrada__c ? `${opp.CSBD_OC_Canal_Entrada__c} + ${opp.CSBD_Now_Origen__c}` : opp.CSBD_Now_Origen__c}

Finalidad: ${opp.CSBD_TipoOperacion2__c} ${opp.CSBD_UsoVivienda2__c} de ${opp.CSBD_TipoConstruccion2__c} en ${opp.CSBD_Comunidad_Autonoma_2__c}
Se han entregado arras por importe de: ${helper.formatImporte(opp.CSBD_AportacionInicial__c)}

% sobre compra: ${helper.formatPorcentaje(helper.formatCalculo(ltv, 2, true))}
% sobre tasación: ${helper.formatPorcentaje(opp.CSBD_PorcentajeTasacion__c)}

OPERACIÓN: RESUMEN Y COMENTARIOS SEGÚN TIPOLOGÍA

Línea: ${opp.CSBD_Linea__c}
Importe del préstamo: ${helper.formatImporte(opp.Amount)}
Plazo: ${plazo}
Modalidad de tipo de interés: ${opp.CSBD_TipoInteres2__c}
Interés bonificado: ${helper.formatPorcentaje(interesBonificado)}
Interés sin bonificar: ${helper.formatPorcentaje(opp.CSBD_TIN_Inicial__c)}

Cuota: ${helper.formatImporte(helper.formatCalculo(cuotaBonificada, 2, true))}
Cuota sin bonificar: ${helper.formatImporte(helper.formatCalculo(cuotaSinBonificar, 2, true))}

GARANTÍAS

Valor de inversión COMPRAVENTA: ${helper.formatImporte(opp.CSBD_PrecioInmueble__c)}
% sobre inversión: ${helper.formatPorcentaje(helper.formatCalculo(ltv, 2, true))}
Valor tasación ESTIMADA: ${helper.formatImporte(opp.CSBD_Tasacion__c)}
% sobre tasación ESTIMADA: ${helper.formatPorcentaje(opp.CSBD_PorcentajeTasacion__c)}

${helper.informeSiaBloqueFincas(datosFincas)}

SOLICITANTES

Solicitantes CLIENTES CAIXABANK

${helper.informeSiaDescripcionTitulares(opp, datosCalculo)}

Los ingresos anuales totales ascienden a ${helper.formatImporte(helper.formatCalculo(ingresosTotales, 2, true))}
Los compromisos de pago anuales totales ascienden a ${helper.formatImporte(helper.formatCalculo(deudasTotales, 2, true))}

Origen de los fondos propios: ${helper.formatImporte(helper.formatCalculo(fondosPropios, 2, true))}

El importe estimado que debe aportar el cliente es de ${helper.formatImporte(totalFondosPropios)}

Régimen de residencia actual: ${opp.CSBD_Residencia_Actual__c}

CAPACIDAD DE DEVOLUCIÓN

Ingresos anuales netos según Nómina: ${helper.formatImporte(helper.formatCalculo(totalNominas, 2, true))}

Ingresos anuales netos según IRPF: ${helper.formatImporte(helper.formatCalculo(totalIrpf, 2, true))}
Compromisos anuales: ${helper.formatImporte(helper.formatCalculo(deudasTotales, 2, true))}
Cuota ptmo. anual: ${helper.formatImporte(helper.formatCalculo(cuotaBonificada, 2, true))}

DTI sin bonificar según nómina: ${helper.formatPorcentaje(helper.formatCalculo(dtiNomina, 2, true))}
DTI bonificado según nómina: ${helper.formatPorcentaje(helper.formatCalculo(dtiNominaBonificado, 2, true))}

DTI sin bonificar según IRPF: ${helper.formatPorcentaje(helper.formatCalculo(dtiIrpf, 2, true))}
DTI bonificado según IRPF: ${helper.formatPorcentaje(helper.formatCalculo(dtiIrpfBonificado, 2, true))}

DTI propuesta SIA: ...
PD propuesta SIA: ...

ANÁLISIS Y JUSTIFICACIÓN SCORING OPERACIÓN

El scoring de la operación es. El scoring cliente es: ...

Morosidad: ...

CIRBE EXTERNA

La CIRBE total asciende a. Origen: ...

SOLVENCIA

Patrimonio:...

RENTABILIDAD ACTUAL

La REN actual de: ...

Vinculación asociada a la operación: ...

CONCLUSIONES

CONCLUSIONES Y FIRMA
`;
		component.find('modalInformeSiaTextareaInfoSia').set('v.value', texto.replace(/null(\n|\s)?/g, ''));

		$A.util.addClass(component.find('modalBackdrop'), 'slds-backdrop_open');
		$A.util.addClass(component.find('modalInformeSia2'), 'slds-fade-in-open');
		window.setTimeout($A.getCallback(() => component.find('modalInformeSiaCancelar2').focus()), 200);
	},

	cerrarModalInformeSia2: function(component) {
		$A.util.removeClass(component.find('modalInformeSia2'), 'slds-fade-in-open');
		$A.util.removeClass(component.find('modalBackdrop'), 'slds-backdrop_open');
	},

	modalInformeSiaTeclaPulsada: function(component, event) {
		if (event.keyCode === 27) { //ESC
			$A.enqueueAction(component.get('c.cerrarModalInformeSia'));
		}
	},

	modalInformeSiaTeclaPulsada2: function(component, event) {
		if (event.keyCode === 27) { //ESC
			$A.enqueueAction(component.get('c.cerrarModalInformeSia2'));
		}
	},

	modalInformeSiaCopiarAlPortapapeles: function(component, event, helper) {
		const idBoton = event.getSource().getLocalId();
		if (idBoton === 'modalInformeSiaCopiarTraslados') {
			helper.copiarTextoAlPortapapeles(component.find('modalInformeSiaTextareaTraslados').get('v.value'));
		} else if (idBoton === 'modalInformeSiaCopiarAprobada') {
			helper.copiarTextoAlPortapapeles(component.find('modalInformeSiaTextareaAprobada').get('v.value'));
		} else if (idBoton === 'modalInformeSiaCopiarFechafirma') {
			helper.copiarTextoAlPortapapeles(component.find('modalInformeSiaTextareaFechaFirma').get('v.value'));
		} else if (idBoton === 'modalInformeSiaCopiarFirmada') {
			helper.copiarTextoAlPortapapeles(component.find('modalInformeSiaTextareaFirmada').get('v.value'));
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
			//eslint-disable-next-line @lwc/lwc/no-async-operation
			window.setTimeout($A.getCallback(() => component.find('modalTareaGestorCancelar').focus()), 200);
		} else {
			helper.mostrarToast('Operativa no disponible', 'La oportunidad no se puede derivar a gestor porque no tiene producto PF', 'info');
		}
	},

	modalTareaGestorCerrar: function(component) {
		$A.util.removeClass(component.find('modalTareaGestor'), 'slds-fade-in-open');
		$A.util.removeClass(component.find('modalBackdrop'), 'slds-backdrop_open');
	},

	modalTareaGestorTeclaPulsada: function(component, event) {
		if (event.keyCode === 27) { //ESC
			$A.enqueueAction(component.get('c.modalTareaGestorCerrar'));
		}
	},

	crearTarea: function(component, event, helper) {
		//component.find('opportunityData').reloadRecord();
		if (!component.find('comentariosTarea').get('v.value')) {
			helper.mostrarToast('Campos vacíos', 'Por favor, informa todos los campos del formulario', 'info');
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
				if (response.getState() === 'SUCCESS') {
					helper.mostrarToast('Oportunidad creada con éxito', 'Podrá localizar la oportunidad en la ficha del cliente', 'success');

					let cerrarOportunidad = component.get('c.cerrarOportunidad');
					cerrarOportunidad.setParams({
						recordId: component.get('v.recordId'),
						nombreEtapaVentas: 'Perdida',
						resolucion: 'Traslado a oficina'
					});
					cerrarOportunidad.setCallback(this, responseCerrarOportunidad => {
						if (responseCerrarOportunidad.getState() === 'SUCCESS') {
							helper.mostrarToast('Oportunidad cerrada con éxito', 'La oportunidad se ha cerrado como Perdida', 'success');
							$A.enqueueAction(component.get('c.modalTareaGestorCerrar'));
							$A.get('e.force:refreshView').fire();
						} else {
							helper.mostrarToast('Problema cerrando la oportunidad', JSON.stringify(responseCerrarOportunidad.getError()), 'error');
						}
						component.set('v.cargandoGestor', false);
					});
					$A.enqueueAction(cerrarOportunidad);
				} else {
					console.error(response.getError());
					component.set('v.cargandoGestor', false);
					helper.mostrarToast('No es posible crear la oportunidad', 'El proceso de creación de la oportunidad ha fallado', 'error');

				}
			});
			$A.enqueueAction(crearTareaGestor);
		}
	},

	buttonmenuSiaOnselect: function(component, event) {
		if (event.getParam('value') === 'Informe SIA') {
			$A.enqueueAction(component.get('c.abrirModalInformeSia2'));
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
		window.setTimeout($A.getCallback(() => component.find('modalAutenticacionOtp').abrirModal()), 200);
	}
});