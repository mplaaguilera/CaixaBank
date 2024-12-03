({
	init: function(component, helper) {
		let cargar = component.get('c.initComponent');
		cargar.setParam('caseId', component.get('v.recordId'));
		cargar.setCallback(this, response => {
			let result = response.getReturnValue();
			let state = response.getState();
			if (state === 'SUCCESS') {
				//getCaso
				component.set('v.caseSubject', result.vGetCaso.Subject);
				component.set('v.dIdioma', result.vGetCaso.SEG_Idioma__c);
				component.set('v.caseStatus', result.vGetCaso.Status);
				component.set('v.caseGrupo', result.vGetCaso.SEG_Grupo__c);
				component.set('v.iniciando', component.get('v.iniciando') + 1);

				//cargarEmails
				component.set('v.emailList', result.vCargarEmails);
				let horaActual = new Date();
				component.set('v.horaActualizacion', horaActual.getHours().toString().padStart(2, '0') + ':' + horaActual.getMinutes().toString().padStart(2, '0'));
				component.set('v.iniciando', component.get('v.iniciando') + 1);

				//getPropietario
				component.set('v.esPropietario', result.vGetPropietario);
				component.set('v.iniciando', component.get('v.iniciando') + 1);

				//cargarFechaEmails
				component.set('v.emailDatesList', result.vCargarFechaEmails);
				component.set('v.iniciando', component.get('v.iniciando') + 1);

				//getDynamicUrlToApex
				component.set('v.urlOrg', result.vGetDynamicUrlToApex);
				component.set('v.iniciando', component.get('v.iniciando') + 1);

				//mostrarEmailReciente
				component.set('v.infoEmailInicial', result.vMostrarEmailReciente);
				component.set('v.currentEmail', result.vMostrarEmailReciente);

				//mostrarContact
				component.set('v.currentContact', result.vMostrarContact);
				component.set('v.iniciando', component.get('v.iniciando') + 1);

			} else if (state === 'ERROR') {
				let errors = response.getError();
				console.error(JSON.stringify(errors));
				helper.mostrarToast('error', 'Error recuperando correo', errors[0].message);
			}
		});
		$A.enqueueAction(cargar);

		component.set('v.columnasAnexos', [
			{label: 'Nombre', fieldName: 'ContentUrl', type: 'url', typeAttributes: {label: {fieldName: 'Title'}, target: '_blank'}},
			{label: 'Extensión', fieldName: 'FileExtension', type: 'text', initialWidth: 105},
			{
				label: 'Fecha', fieldName: 'CreatedDate', type: 'date', initialWidth: 137, typeAttributes: {
					month: '2-digit', day: '2-digit', year: 'numeric', hour: '2-digit', minute: '2-digit', timeZone: 'Europe/Paris'
				}
			},
			{label: 'Tamaño', fieldName: 'ContentSize', type: 'integer', initialWidth: 105}
		]);
	},

	casoUpdatedDataService: function(component, event) {
		if (event.getParams().changeType === 'LOADED' || event.getParams().changeType === 'CHANGED') {
			const caso = component.get('v.caso');
			component.set('v.noContacto', !caso.ContactId || !caso.SEG_Organizacion__c || !caso.SEG_Zona__c);
		} else if (event.getParams().changeType === 'ERROR') {
			console.error(component.get('v.errorLds'));
		}
	},

	cargarAnexos: function(component, event, helper) {
		let getAnexos = component.get('c.getFilesEmailReciente');
		getAnexos.setParam('caseId', component.get('v.recordId'));
		//Recuperamos anexos relacionados con el email y mostramos lista si contiene alguno
		getAnexos.setCallback(this, response => {
			if (response.getState() === 'SUCCESS') {
				let records = response.getReturnValue();
				records.forEach(record => {
					record.ContentUrl = urlpath + '/sfc/servlet.shepherd/version/download/' + record.Id + '?operationContext=S';
					record.ContentSize = helper.formatBytes(record.ContentSize, 2);
				});
				component.set('v.dataAnexos', records);
				if (response.getReturnValue().length > 0) {
					component.set('v.hasAnexos', true);
				} else {
					component.set('v.hasAnexos', false);
				}
			}
		});
		$A.enqueueAction(getAnexos);
	},

	cargarEmails: function(component) {
		let cargar = component.get('c.recuperarEmails');
		cargar.setParam('caseId', component.get('v.recordId'));
		cargar.setCallback(this, v => {
			component.set('v.emailList', v.getReturnValue());
			component.set('v.iniciando', component.get('v.iniciando') + 1);

			let horaActual = new Date();
			component.set('v.horaActualizacion', horaActual.getHours().toString().padStart(2, '0') + ':' + horaActual.getMinutes().toString().padStart(2, '0'));
		});
		$A.enqueueAction(cargar);
	},

	cargarFechaEmails: function(component) {
		let cargarFechas = component.get('c.recuperarFechaEmails');
		cargarFechas.setParam('caseId', component.get('v.recordId'));
		cargarFechas.setCallback(this, v => {
			component.set('v.emailDatesList', v.getReturnValue());
			component.set('v.iniciando', component.get('v.iniciando') + 1);
		});
		$A.enqueueAction(cargarFechas);
	},

	cargarEmailReciente: function(component, event, helper) {
		let mostrarEmailReciente = component.get('c.mostrarEmailReciente');
		mostrarEmailReciente.setParam('caseId', component.get('v.recordId'));
		mostrarEmailReciente.setCallback(this, responseMostrarEmailReciente => {
			let state = responseMostrarEmailReciente.getState();
			if (state === 'SUCCESS') {
				component.set('v.infoEmailInicial', responseMostrarEmailReciente.getReturnValue());
				component.set('v.currentEmail', responseMostrarEmailReciente.getReturnValue()); //!!!

				let mostrarContact = component.get('c.mostrarContact');
				mostrarContact.setParam('email', responseMostrarEmailReciente.getReturnValue());
				mostrarContact.setCallback(this, responseMostrarContact => {
					component.set('v.currentContact', responseMostrarContact.getReturnValue());
					component.set('v.iniciando', component.get('v.iniciando') + 1);
				});
				$A.enqueueAction(mostrarContact);
			} else if (state === 'ERROR') {
				let errors = responseMostrarEmailReciente.getError();
				console.error(JSON.stringify(errors));
				helper.mostrarToast('error', 'Error recuperando correo', errors[0].message);
			}
		});
		$A.enqueueAction(mostrarEmailReciente);

		let urlpath = window.location.href;
		let urlpathsplit = urlpath.split('/lightning/');
		urlpath = urlpathsplit[0];

		let getAnexos = component.get('c.getFilesEmailReciente');
		getAnexos.setParam('caseId', component.get('v.recordId'));
		//Recuperamos anexos relacionados con el email y mostramos lista si contiene alguno
		getAnexos.setCallback(this, response => {
			if (response.getState() === 'SUCCESS') {
				let records = response.getReturnValue();
				records.forEach(record => {
					record.ContentUrl = urlpath + '/sfc/servlet.shepherd/version/download/' + record.Id + '?operationContext=S';
					record.ContentSize = helper.formatBytes(record.ContentSize, 2);
				});
				component.set('v.dataAnexos', records);
				if (response.getReturnValue().length > 0) {
					component.set('v.hasAnexos', true);
				} else {
					component.set('v.hasAnexos', false);
				}
			}
		});
		$A.enqueueAction(getAnexos);
	},

	getValueFromApplicationEvent: function(cmp, event) {
		let ShowResultValue = event.getParam('retContact');
		cmp.set('v.contactId', ShowResultValue);

	},

	getListFromApplicationEvent: function(cmp, event) {
		let ShowResultLst = event.getParam('lstContactNuevo');
		cmp.set('v.newDestinatario', ShowResultLst);
	},

	getListParaFromApplicationEvent: function(cmp, event) {
		let ShowResultLstPara = event.getParam('lstGrupoPara');
		cmp.set('v.lstPara', ShowResultLstPara);

	},

	getCaso: function(component) {
		let recuperarCaso = component.get('c.recuperarCaso');
		recuperarCaso.setParam('caseId', component.get('v.recordId'));
		recuperarCaso.setCallback(this, response => {
			let caso = response.getReturnValue();
			component.set('v.caseSubject', caso.Subject);
			component.set('v.dIdioma', caso.SEG_Idioma__c);
			component.set('v.caseStatus', caso.Status);
			component.set('v.caseGrupo', caso.SEG_Grupo__c);
			component.set('v.iniciando', component.get('v.iniciando') + 1);
		});
		$A.enqueueAction(recuperarCaso);

		/*component.set('v.columnasAnexos', [
			{label: 'Nombre', fieldName: 'ContentUrl', type: 'url', typeAttributes: {
				label: {fieldName: 'Title'}, target: '_blank'
			}},
			{label: 'Extensión', fieldName: 'FileExtension', type: 'text', initialWidth: 105},
			{label: 'Fecha', fieldName: 'CreatedDate', type: 'date', typeAttributes:{
				month: '2-digit',day: '2-digit',year: 'numeric',hour:'2-digit' ,minute:'2-digit' ,timeZone:'Europe/Paris'}},
			{label: 'Tamaño', fieldName: 'ContentSize', type: 'integer', initialWidth: 105}
		]); */
	},

	getPropietario: function(component) {
		let propietario = component.get('c.esPropietario');
		propietario.setParam('caseId', component.get('v.recordId'));
		propietario.setCallback(this, v => {
			component.set('v.esPropietario', v.getReturnValue());
			component.set('v.iniciando', component.get('v.iniciando') + 1);
		});
		$A.enqueueAction(propietario);
	},

	getEmail: function(component, event, helper) {
		let mostrarEmail = component.get('c.mostrarEmail');
		mostrarEmail.setParams({emailId: event.currentTarget.name, caseId: component.get('v.recordId')});
		mostrarEmail.setCallback(this, responseMostrarEmail => {
			let stateMostrarEmail = responseMostrarEmail.getState();
			if (stateMostrarEmail === 'SUCCESS') {
				let email = responseMostrarEmail.getReturnValue();
				component.set('v.currentEmail', email);
				component.set('v.infoEmailRespuesta', email);

				let mostrarContact = component.get('c.mostrarContact');
				mostrarContact.setParam('email', email);
				mostrarContact.setCallback(this, responseMostrarContact => {
					let stateMostrarContact = responseMostrarContact.getState();
					if (stateMostrarContact === 'SUCCESS') {
						component.set('v.currentContact', responseMostrarContact.getReturnValue());
					} else if (stateMostrarContact === 'ERROR') {
						let errorsMostrarContact = responseMostrarContact.getError();
						helper.mostrarToast('error', 'Error recuperando correo', errorsMostrarContact[0].message);
						console.error(JSON.stringify(errorsMostrarContact));
					}
				});
				$A.enqueueAction(mostrarContact);
			} else if (stateMostrarEmail === 'ERROR') {
				let errorsMostrarEmail = responseMostrarEmail.getError();
				helper.mostrarToast('error', 'Error recuperando correo', errorsMostrarEmail[0].message);
				console.error(JSON.stringify(errorsMostrarEmail));
			}
		});
		$A.enqueueAction(mostrarEmail);

		let getBaseUrl = component.get('v.urlOrg');
		let getFilesEmail = component.get('c.getFilesEmail');
		getFilesEmail.setParam('emailId', event.currentTarget.name);

		//Recuperamos anexos relacionados con el email y mostramos lista si contiene alguno
		getFilesEmail.setCallback(this, response => {
			if (response.getState() === 'SUCCESS') {
				let records = response.getReturnValue();
				records.forEach(record => {
					record.ContentUrl = getBaseUrl + '/sfc/servlet.shepherd/version/download/' + record.Id + '?operationContext=S';
					record.ContentSize = helper.formatBytes(record.ContentSize, 2);
				});
				component.set('v.dataAnexos', records);
				component.set('v.hasAnexos', response.getReturnValue().length > 0);
			}
		});
		$A.enqueueAction(getFilesEmail);
		//component.set('v.rendermostrarModalCasosHijos', true);
	},

	/*ELB: Modificado metodo para añadir el boton que se pulsa (Responder o ResponderTodos). Añadida llamada al metodo
	* cargarEmailReciente para recargar los datos del ultimo email en caso de cancelar la edición del mensaje.
	*/
	abrirPlantillas: function(component, event) {
		let idBoton = event.getSource().getLocalId();
		component.set('v.botonPulsado', idBoton);
		component.set('v.abrirPlantillas', true);
		component.set('v.abrirBusqueda', false);
		component.set('v.cambioDestinatario', false);
		component.set('v.cuerpoNuevo', false);
		let listaValoresPara = component.get('v.lstPara');
		for (let i = 0; listaValoresPara.length >= i; i++) {
			listaValoresPara.splice(i, 1);
		}
		listaValoresPara.splice(0, 1);
		component.set('v.lstPara', listaValoresPara);
		let listaValoresCopia = component.get('v.lstCopia');
		for (let i = 0; listaValoresCopia.length >= i; i++) {
			listaValoresCopia.splice(i, 1);
		}
		listaValoresCopia.splice(0, 1);
		component.get('v.lstCopia', listaValoresCopia);
		let listaValoresCCO = component.get('v.lstCCO');
		for (let i = 0; listaValoresCCO.length >= i; i++) {
			listaValoresCCO.splice(i, 1);
		}
		listaValoresCCO.splice(0, 1);
		component.get('v.lstCCO', listaValoresCCO);
		//$A.enqueueAction(component.get('c.cargarEmailReciente'));
	},

	cerrarPlantillas: function(component) {
		component.set('v.abrirPlantillas', false);
		component.set('v.abrirBusqueda', false);
		component.set('v.contactId', '');
		component.set('v.infoEmailRespuesta', null);

	},

	abrirNuevo: function(component) {
		component.set('v.botonPulsado', 'botonNuevo');
		component.set('v.origenBuscador', 'principal');
		component.set('v.abrirBusqueda', true);
		component.set('v.cuerpoNuevo', true);
		component.set('v.deNuevo', true);
		component.set('v.abrirPlantillas', false);

		let listaValoresPara = component.get('v.lstPara');
		let listaValoresCopia = component.get('v.lstCopia');
		let listaValoresCCO = component.get('v.lstCCO');
		if (listaValoresPara != null) {
			for (let i = 0; listaValoresPara.length >= i; i++) {
				listaValoresPara.splice(i, 1);
			}
			listaValoresPara.splice(0, 1);

			component.set('v.lstPara', listaValoresPara);
		} else {
			component.set('v.lstPara', null);
		}
		if (listaValoresCopia != null) {
			for (let i = 0; listaValoresCopia.length >= i; i++) {
				listaValoresCopia.splice(i, 1);
			}
			listaValoresCopia.splice(0, 1);
			component.get('v.lstCopia', listaValoresCopia);
		} else {
			component.set('v.lstCopia', null);
		}
		if (listaValoresCCO != null) {
			for (let i = 0; listaValoresCCO.length >= i; i++) {
				listaValoresCCO.splice(i, 1);
			}
			listaValoresCCO.splice(0, 1);
			component.get('v.lstCCO', listaValoresCCO);
		} else {
			component.set('v.lstCCO', null);
		}
	},

	abrirRemitir: function(component) {
		component.set('v.botonPulsado', 'botonReenviar');
		component.set('v.origenBuscador', 'principal');
		component.set('v.abrirBusqueda', true);
		component.set('v.abrirPlantillas', false);
		component.set('v.cambioDestinatario', true);
		let listaValoresPara = component.get('v.lstPara');
		for (let i = 0; listaValoresPara.length >= i; i++) {
			listaValoresPara.splice(i, 1);
		}
		listaValoresPara.splice(0, 1);
		component.set('v.lstPara', listaValoresPara);
		let listaValoresCopia = component.get('v.lstCopia');
		for (let i = 0; listaValoresCopia.length >= i; i++) {
			listaValoresCopia.splice(i, 1);
		}
		listaValoresCopia.splice(0, 1);
		component.get('v.lstCopia', listaValoresCopia);
		//component.set('v.infoEmailRespuesta', null);
	},

	//ELB: Modificación para añadir el autocopiado en el Para, CC y BCC
	abrirRedactar: function(component) {
		let idBoton = component.get('v.botonPulsado');
		component.set('v.origenBuscador', 'destinatarios');
		component.set('v.abrirBusqueda', true);
		component.set('v.abrirRedactar', true);
		component.set('v.abrirPlantillas', false);
		component.set('v.registroId', component.get('v.contactId'));
		component.set('v.contactId', '');

		if (idBoton === 'RespUnico') {
			let getResponderPara = component.get('c.getResponderPara');
			getResponderPara.setParams({
				emailsPara: component.get('v.infoEmailRespuesta').FromAddress,
				caseId: component.get('v.recordId')
			});
			getResponderPara.setCallback(this, response => {
				let listaEmailFinal = response.getReturnValue();
				component.set('v.lstPara', listaEmailFinal.listadoPara);
				component.set('v.lstCopia', listaEmailFinal.listadoCc);
				component.set('v.lstCCO', listaEmailFinal.listadoCco);
			});
			$A.enqueueAction(getResponderPara);

		} else if (idBoton === 'RespMultiple') {
			let emails = component.get('v.infoEmailRespuesta');
			let getResponderPara2 = component.get('c.getResponderPara');
			let datos;
			if (emails.ToAddress) {
				datos = emails.FromAddress + '; ' + emails.ToAddress;
			} else {
				datos = emails.FromAddress;
			}
			getResponderPara2.setParams({
				emailsPara: datos,
				caseId: component.get('v.recordId')
			});
			getResponderPara2.setCallback(this, response => {
				let state = response.getState();
				if (state === 'SUCCESS') {
					let listaEmailFinal = response.getReturnValue();
					component.set('v.lstPara', listaEmailFinal.listadoPara);
					component.set('v.lstCopia', listaEmailFinal.listadoCc);
					component.set('v.lstCCO', listaEmailFinal.listadoCco);
				}
			});

			let getResponderMultipleCc = component.get('c.getResponderMultipleCc');
			getResponderMultipleCc.setParams({
				caseId: component.get('v.recordId'),
				direccionesCc: emails.CcAddress,
				//direccionesTo: emails.ToAddress
			});
			getResponderMultipleCc.setCallback(this, response => {
				component.set('v.lstCopia', response.getReturnValue());
			});

			let getResponderMultipleCco = component.get('c.getResponderMultipleCco');
			getResponderMultipleCco.setParams({'caseId': component.get('v.recordId'), 'direccionesCco': emails.BccAddress});
			getResponderMultipleCco.setCallback(this, b => {
				component.set('v.lstCCO', b.getReturnValue());
			});

			$A.enqueueAction(getResponderPara2);
			$A.enqueueAction(getResponderMultipleCc);
			$A.enqueueAction(getResponderMultipleCco);
		}
	},

	getDynamicUrlToApex: function(component) {
		let url = component.get('c.getDynamicUrl');
		url.setCallback(this, v => {
			component.set('v.urlOrg', v.getReturnValue());
		});
		$A.enqueueAction(url);
	},

	actualizarListaCorreos: function(component) {
		$A.enqueueAction(component.get('c.cargarEmails'));
		$A.enqueueAction(component.get('c.cargarFechaEmails'));
	},

	abrirEmailMessage: function(component) {
		let workspaceAPI = component.find('workspace');
		workspaceAPI.openSubtab({
			parentTabId: workspaceAPI.getEnclosingTabId(),
			recordId: component.get('v.currentEmail.Id'),
			focus: true
		});
	},

	checkContact: function(component) {
		let noContact = component.get('c.controlarContactyOrgZona');
		noContact.setParam('caseId', component.get('v.recordId'));
		noContact.setCallback(this, response => {
			if (response.getState() === 'SUCCESS') {
				component.set('v.noContacto', response.getReturnValue());
			}
		});
		$A.enqueueAction(noContact);
	},

	cerrarAvisoNoContacto: function(component) {
		component.set('v.avisoNoContacto', true);
	},

	scrollToTop: function() {
		document.getElementById('elementScroll').scrollTop = 0;
		window.scrollTo({top: 0, behavior: 'smooth'});
	}


});