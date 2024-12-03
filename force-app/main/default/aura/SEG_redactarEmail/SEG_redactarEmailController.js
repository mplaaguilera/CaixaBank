({
	cerrarRedactar: function(component) {
		component.set('v.isBusqueda', false);
		component.set('v.isRedactar', false);
		component.set('v.paraContacts', []);
		component.set('v.copiaContacts', []);
		component.set('v.ccoContacts', []);
		component.set('v.idRecord', '');
		component.find('inputFechaPlanificacion').set('v.value', '');
	},

	toggleCerrarCasoChange: function(component, event) {
		let cerrarCasoChecked = event.getSource().get('v.checked');
		component.set('v.checkCerrar', cerrarCasoChecked);
		if (cerrarCasoChecked) {
			component.set('v.fechaPlanificacionAux', component.get('v.fechaPlanificacion'));
			component.set('v.fechaPlanificacion', '');
			component.find('inputFechaPlanificacion').setCustomValidity('');
			component.find('inputFechaPlanificacion').reportValidity();
			component.set('v.numOperacionesCambio', true);
		} else {
			component.set('v.fechaPlanificacion', component.get('v.fechaPlanificacionAux'));
			component.find('inputFechaPlanificacion').reportValidity();
			component.set('v.numOperacionesCambio', false);
		}
	},

	inputFechaPlanificacionChange: function(component) {
		component.set('v.fechaPlanificacionAux', component.get('v.fechaPlanificacion'));
	},

	init: function(component, event, helper) {
		//Columnas para la tabla de anexos
		component.set('v.columnasAnexos', [
			{label: 'Título', fieldName: 'ContentUrl', type: 'url', typeAttributes: {
				label: {fieldName: 'Title'}, target: '_blank'}},
			{label: 'Extensión', fieldName: 'FileExtension', type: 'text', initialWidth: 105},
			{label: 'Fecha', fieldName: 'CreatedDate', type: 'date', initialWidth: 137, typeAttributes: {
				month: '2-digit', day: '2-digit', year: 'numeric', hour: '2-digit', minute: '2-digit', timeZone: 'Europe/Paris'}},
			{label: 'Tamaño', fieldName: 'ContentSize', type: 'integer', initialWidth: 105}
		]);

		//Recuperar fecha de planificación del caso
		let getFPlanificacion = component.get('c.getFPlanificacion');
		getFPlanificacion.setParam('casoId', component.get('v.caseId'));
		getFPlanificacion.setCallback(this, response => {
			if (response.getState() === 'SUCCESS') {
				let caso = response.getReturnValue();
				let fecha = caso.SEG_Fecha_planificaci_n__c;
				component.set('v.destinatariosNoIncluidos', caso.SEG_limiteToAddress__c);
				//component.set('v.listDestinatariosNoIncluidos', caso.SEG_toAddressNoAnadidos__c);
				component.set('v.casoYaPlanificado', fecha != null);
				component.set('v.fechaPlanificacion', fecha);

				//Si existe límite de direcciones se deshabilita el botón
				if(caso.SEG_limiteToAddress__c == true && component.get('v.botonPulsado') == 'RespMultiple' ){
					component.set('v.getLimitDirecciones', true);
				} else {
					component.set('v.getLimitDirecciones', false);
				}
			}
		});
		$A.enqueueAction(getFPlanificacion);

		component.set('v.fechaPlanificacionMin', new Date().toISOString());

		//Recipient.Name
		let finalParaTemplateName;
		let contactlistid = component.get('v.datContact.Id');
		let registroid = component.get('v.idRecord');

		if (registroid) {
			finalParaTemplateName = registroid;
		} else if (!registroid && contactlistid) {
			finalParaTemplateName = contactlistid;
		}
		let newEmail = component.get('v.nuevoEmail');
		let getEmailTemplate = component.get('c.getEmailTemplate');
		getEmailTemplate.setParams({
			caseId: component.get('v.caseId'),
			dataEmail: component.get('v.datosEmail'),
			idPlanIdi: component.get('v.idPlanIdioma'),
			idPlanOrg: component.get('v.idPlantillaOrg'),
			idPlan: component.get('v.idPlantilla'),
			finalParaTemplateName: finalParaTemplateName,
			bNuevo: newEmail
		});
		getEmailTemplate.setCallback(this, response => {
			let state = response.getState();
			if (state === 'SUCCESS') {
				let retorno = response.getReturnValue();
				let email = component.get('v.datosEmail');
				let emailbod = component.get('v.datosEmail.HtmlBody');

				if (retorno) {
					//Inicializar cuerpo
					if (newEmail) {
						if (email) {
							component.set('v.cuerpo', retorno.cuerpo);
						} else if (!emailbod) {
							component.set('v.cuerpo', retorno.cuerpo);
						} else {
							component.set('v.cuerpo', retorno.cuerpo + emailbod);
						}
					} else {
						component.set('v.cuerpo', retorno.cuerpo + emailbod);
					}

					//Inicializar asunto
					component.set('v.idPlantilla', null);
					component.set('v.idPlantillaOrg', null);
					if (newEmail) {
						component.set('v.asunto', retorno.asunto);
					} else if (!newEmail && component.get('v.datosEmail.Subject') && retorno.plantilla) {
						component.set('v.asunto', retorno.asunto);
					} else if (!newEmail && component.get('v.datosEmail.Subject') && !retorno.plantilla) {
						component.set('v.asunto', component.get('v.datosEmail.Subject'));
					}
				}
			} else if (state === 'ERROR') {
				let errors = response.getError();
				helper.mostrarToast('error', 'Error recuperando datos de la plantilla', errors[0].message);
				console.error(JSON.stringify(errors));
			}
		});
		$A.enqueueAction(getEmailTemplate);
		/*if (component.get('v.contactId')) {
			let getNombreEmailContacto = component.get('c.getNombreEmailContacto');
			getNombreEmailContacto.setParam('idContacto', component.get('v.contactId'));
			getNombreEmailContacto.setCallback(this, response => {
				let state = response.getState();
				if (state === 'SUCCESS') {
					component.set('v.contactPrincipal', response.getReturnValue());
				} else if (state === 'ERROR') {
					let errors = response.getError();
					console.error(JSON.stringify(errors));
				}
			});
			$A.enqueueAction(getNombreEmailContacto);
		}*/
	},

	sendEmail: function(component, event, helper) {
		//Validación de datos informados
		console.log('hago click boton');
		let validity = true;
		if (!component.find('inputAsunto').get('v.validity').valid) {
			component.find('inputAsunto').reportValidity();
			validity = false;
		}
		if (!component.find('inputFechaPlanificacion').get('v.validity').valid) {
			component.find('inputFechaPlanificacion').reportValidity();
			validity = false;
		}
		if (!validity) {
			return;
		}

		component.set('v.isLoading', true);
		let copiaList;
		let ccoList = component.get('v.ccoContacts');
		let paraList = component.get('v.paraContacts');
		//let cambioPara = component.get('v.aPara');

		//JAV - ELB
		if (ccoList) {
			let CcArray = component.get('v.copiaContacts');
			copiaList = CcArray;
		} else {
			copiaList = component.get('v.copiaContacts');
		}

		let contactlistid = component.get('v.datContact.Id');
		let registroid = component.get('v.idRecord');
		let esNuevo = component.get('v.nuevoEmail');
		let ficherosList = component.get('v.currentSelectedRowsAnexos');

		//variable para pasar el id del registro del email principal
		let idParaPrincip = '';
		if (registroid) {
			idParaPrincip = registroid;
		} else if (!registroid && contactlistid) {
			idParaPrincip = contactlistid;
		}

		let fechaPlan;
		//Fecha planifiación
		if (!component.get('v.checkCerrar')) {
			fechaPlan = component.find('inputFechaPlanificacion').get('v.value');
		}

		let newPara;
		/*if (cambioPara.length > 0) {
			newPara = cambioPara[0].label;
		}*/
		let enviarCorreo = component.get('c.enviarCorreo');
		enviarCorreo.setParams({
			'caseId': component.get('v.caseId'),
			'dataEmail': component.get('v.datosEmail'),
			'emailBody': component.get('v.cuerpo'),
			'subject': component.get('v.asunto'),
			'paraList': paraList,
			'copiaList': copiaList,
			//'cambioPara': newPara,
			'bRemitir': false,
			'bNuevo': esNuevo,
			'listaAnexos': ficherosList,
			'recordId': idParaPrincip,
			'cerrar': component.get('v.checkCerrar'),
			'revision': fechaPlan,
			'boton': component.get('v.botonPulsado'),
			'newDestino': component.get('v.otroDestinatario'),
			'bccList': ccoList
		});
		enviarCorreo.setCallback(this, response => {
			let state = response.getState();
			if (state === 'SUCCESS') {
				component.set('v.datosEmail', response.getReturnValue().emailMessage);
				component.set('v.currentEmail', response.getReturnValue().emailMessage);

				if (response.getReturnValue().casoPadre){
					helper.mostrarToast('error', 'Caso no Cerrado', 'El correo se envió correctamente, pero el caso no se pudo cerrar por tener vinculados pendientes')
				}
				else if (!response.getReturnValue().planificado && !response.getReturnValue().casoPadre) {
					helper.mostrarToast('success', 'Correo enviado', 'El correo se envió correctamente');
				} 
				else if(response.getReturnValue().planificado && !response.getReturnValue().casoPadre){
					helper.mostrarToast('success', 'Correo enviado', 'El correo se envió correctamente');
				}
				
				if (component.get('v.resultados').length === 0) {
					let getResultados = component.get('c.recuperarResultados');
					getResultados.setCallback(this, response => {
						let values = [];
						let result = response.getReturnValue();
						for (let key in result) {
							values.push({label: result[key], value: key});
						}
						component.set('v.resultados', values);
					});
					$A.enqueueAction(getResultados);
				}
				component.set('v.selectedNotasTip', 'Sin notas');

				//Resetear variables
				//component.set('v.aPara', []);
				component.set('v.idRecord', '');
				component.find('inputFechaPlanificacion').set('v.value', '');
				component.set('v.paraContacts', []);
				component.set('v.copiaContacts', []);
				component.set('v.ccoContacts', []);
				component.set('v.numOperacionesCaso', component.get('v.record.SEG_N_operaciones_del_caso__c'));
				if(component.get('v.record.SEG_Detalle__r.SEG_Criterio_imputacion_operaciones__c') != null){
					component.set('v.criterioImputacion', component.get('v.record.SEG_Detalle__r.SEG_Criterio_imputacion_operaciones__c'));
				} else if(component.get('v.record.CC_MCC_Motivo__r.SEG_Criterio_imputacion_operaciones__c') != null){
					component.set('v.criterioImputacion', component.get('v.record.CC_MCC_Motivo__r.SEG_Criterio_imputacion_operaciones__c'));
				} else if(component.get('v.record.CC_MCC_ProdServ__r.SEG_Criterio_imputacion_operaciones__c') != null){
					component.set('v.criterioImputacion', component.get('v.record.CC_MCC_ProdServ__r.SEG_Criterio_imputacion_operaciones__c'));
				} else if(component.get('v.record.CC_MCC_Tematica__r.SEG_Criterio_imputacion_operaciones__c') != null){
					component.set('v.criterioImputacion', component.get('v.record.CC_MCC_Tematica__r.SEG_Criterio_imputacion_operaciones__c'));
				}
				$A.util.addClass(component.find('backdrop'), 'slds-fade-in-open');
				$A.util.addClass(component.find('modalAsignarNotasEnvio'), 'slds-fade-in-open');
				window.setTimeout($A.getCallback(() => component.find('modalEnvioNotasBotonCancelar').focus()), 200);

			} else if (state === 'ERROR') {
				let errors = response.getError();
				if (errors && component.get('v.checkCerrar')) {
					helper.mostrarToast('error', 'No se ha podido enviar el correo', 'No se permite cerrar el caso si no se ha informado de la Temática, el Producto, el Motivo, el Nº de operaciones del caso o la cuenta està pendiente de asociar.');
					console.error('error'+JSON.stringify(errors));
				}
				else if (errors && !component.get('v.checkCerrar')){
					helper.mostrarToast('error', 'No se ha podido enviar el correo', errors[0].message);
				}
			}
			component.set('v.isLoading', false);
		});
		$A.enqueueAction(enviarCorreo);
	},

	dataAnexos: function(component, event, helper) {
		//Llamada al helper para rellenar datos de la tabla anexos
		helper.setDataAnexos(component, []);
	},

	selectedRowsAnexos: function(component, event) {
		let selectedRows = event.getParam('selectedRows');
		let currentSelectedRows = [];
		let currentSelectRowsInfo = [];
		selectedRows.forEach(selectedRow => {
			currentSelectedRows.push(selectedRow.ContentDocumentId);
			currentSelectRowsInfo.push(selectedRow);
		});
		component.set('v.dataAnexosMostrar', currentSelectRowsInfo);
		component.set('v.currentSelectedRowsAnexos', currentSelectedRows);
	},

	/*borrarUltimoPara: function(component) {
		let listaValores = component.get('v.paraContacts');
		let paraNoBorrable = component.get('v.contactPrincipal.Email');
		let paraContactoNoBorrable = component.get('v.datosEmail.FromAddress');
		let setFinal = new Set;
		let contieneFromAddress = true;
		for (let key in listaValores) {
			if (listaValores[key] != paraContactoNoBorrable) {
				contieneFromAddress = false;
			}
		}
		if (listaValores.length == 0) {
			contieneFromAddress = false;
		}
		console.log('nocontienefromAddress ' + listaValores.length);
		console.log('nocontienefromAddress ' + contieneFromAddress);
		console.log('nocontienefromAddress ' + listaValores);
		listaValores.splice(listaValores.length - 1, 1);
		if (paraNoBorrable != null) {
			setFinal.add(paraNoBorrable);
		} else if (paraNoBorrable == null && paraContactoNoBorrable != null && contieneFromAddress) {
			setFinal.add(paraContactoNoBorrable);
		}

		listaValores.forEach(item => setFinal.add(item));

		if (setFinal != null) {
			component.set('v.paraContacts', Array.from(setFinal));
		} else {
			component.set('v.paraContacts', listaValores);
		}

		document.getElementById('paras').value = component.get('v.paraContacts');
	},

	borrarUltimoCC: function(component) {
		let listaValores = component.get('v.copiaContacts');
		listaValores.splice(listaValores.length - 1, 1);
		component.set('v.copiaContacts', listaValores);
		document.getElementById('ccs').value = component.get('v.copiaContacts');
	},

	borrarUltimoCCO: function(component) {
		let listaValores = component.get('v.ccoContacts');
		listaValores.splice(listaValores.length - 1, 1);
		component.set('v.ccoContacts', listaValores);
		document.getElementById('ccos').value = component.get('v.ccoContacts');
	},*/

	/*borrarListaPara: function(component) {
		let listaBorradoPara = [];
		let paraNoBorrable = component.get('v.contactPrincipal.Email');
		let paraContactoNoBorrable = component.get('v.datosEmail.FromAddress');
		if (paraNoBorrable != null) {
			listaBorradoPara = paraNoBorrable;
		} else if (paraContactoNoBorrable != null && paraNoBorrable == null) {
			listaBorradoPara = paraContactoNoBorrable;
		} else {
			listaBorradoPara = [];
		}
		component.set('v.paraContacts', listaBorradoPara);
	},

	borrarListaCC: function(component) {
		let listaBorradoCc = [];
		component.set('v.copiaContacts', listaBorradoCc);
	},

	borrarListaCCO: function(component) {
		let listaBorradoCco = [];
		component.set('v.ccoContacts', listaBorradoCco);
	},*/

	/**ELB: Metodos para añadir en el listado de para, cc y cco los emails introducidos en el
			* campo nuevo destinatario.
			**/
	addListaPara: function(component, event) {
		let idBoton = event.getSource().getLocalId();
		component.set('v.botonAnadir', idBoton);
		let listaValoresPara;
		let listaValoresCc;
		let listaValoresCco;
		let emailListPara;
		let noContactos = false;
		let toastEvent = $A.get('e.force:showToast');
		let listaEmailComprobadaPara = [];
		let listaEmailComprobadaCc = [];
		let listaEmailComprobadaCco = [];

		//rellenamos listas con valores del para
		if (!component.get('v.paraContacts')) {
			listaValoresPara = null;
		} else {
			listaValoresPara = component.get('v.paraContacts');
		}
		//obtenemos los valores escritos manualmente
		if (component.get('v.addmail') === '') {
			emailListPara = null;
		} else {
			emailListPara = component.get('v.addmail');
		}
		//rellenamos listas con valores del cc
		if (!component.get('v.copiaContacts')) {
			listaValoresCc = null;
		} else {
			listaValoresCc = component.get('v.copiaContacts');
		}
		//rellenamos listas con valores del cco
		if (typeof component.get('v.ccoContacts') === 'undefined') {
			listaValoresCco = null;
		} else {
			listaValoresCco = component.get('v.ccoContacts');
		}

		if (emailListPara != null) {
			let emailsParaCanales = component.get('c.getCanalesComunicacionManuales');
			//let regex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
			let regex = /^[^\s@]+@[^\s@]+\.[^\s;\s@]+$/;
			
			emailsParaCanales.setParams({'caseId': component.get('v.caseId'), 'emails': emailListPara, 'noContactos': noContactos, 'idBotonEntrada': idBoton});
			emailsParaCanales.setCallback(this, apexReturn => {
				if (apexReturn.getState() == 'SUCCESS'){
					let listaEmailFinal = apexReturn.getReturnValue();
					let emailsCanalesComPara = listaEmailFinal.listadoPara;
					let emailsCanalesComCc = listaEmailFinal.listadoCc;
					let emailsCanalesComCco = listaEmailFinal.listadoCco;
					
					let arrayPara = [];
					let arrayCc = [];
					let arrayCco = [];

					//Trabajamos con las listas para el Para
					if (emailsCanalesComPara.length !== 0) {
						for (var i = 0; i < emailsCanalesComPara.length; i++) {
							if (arrayPara.length === 0) {
								var string = emailsCanalesComPara[i].replace(/ /g, '');
								arrayPara.push(string);
							} else {
								var string = emailsCanalesComPara[i].replace(/ /g, '');
								arrayPara.push(string);
							}
						}
						for (var i = 0; i < arrayPara.length; i++) {
							if (regex.test(arrayPara[i])) {
								if (listaValoresPara == null || typeof listaValoresPara === 'undefined' || Object.keys(listaValoresPara).length === 0) {
									if (listaEmailComprobadaPara == null) {
										listaEmailComprobadaPara = [];
										listaEmailComprobadaPara.push(arrayPara[i]);
									} else {
										listaEmailComprobadaPara.push(' ' + arrayPara[i]);
									}
								} else {
									if (listaEmailComprobadaPara == null) {
										listaEmailComprobadaPara = [];
										listaEmailComprobadaPara.push(' ' + arrayPara[i]);
									} else {
										listaEmailComprobadaPara.push(' ' + arrayPara[i]);
									}
								}
							} else {
								listaEmailComprobadaPara = null;
								break;
							}
						}
						if (listaEmailComprobadaPara != null) {
							var listaFinalMailsPara = [];
							if (listaValoresPara == null) {
								listaFinalMailsPara = listaEmailComprobadaPara;
							} else {
								listaFinalMailsPara = listaValoresPara.concat(listaEmailComprobadaPara);
							}
						}
						if (listaFinalMailsPara != null) {
							let arrayNoDuplicatesPara = [];
							let arrayEmailsPara = [];
	
							for (var i = 0; i < Object.keys(listaFinalMailsPara).length; i++) {
								var string = listaFinalMailsPara[i].replace(/ /g, '');
								arrayEmailsPara.push(string);
							}
							arrayNoDuplicatesPara = [...new Set(arrayEmailsPara)];
							for (var i = 0; i < arrayNoDuplicatesPara.length; i++) {
								if (listaFinalLimpiaPara == null) {
									var listaFinalLimpiaPara = [];
									listaFinalLimpiaPara.push(arrayNoDuplicatesPara[i]);
								} else {
									listaFinalLimpiaPara.push(' ' + arrayNoDuplicatesPara[i]);
								}
							}
							component.set('v.paraContacts', listaFinalLimpiaPara);
							component.set('v.addmail', '');
							component.set('v.mostrarBotonesAnyadirManual', false);
						} else {
							component.set('v.paraContacts', listaValoresPara);
							component.set('v.copiaContacts', listaValoresCc);
							component.set('v.ccoContacts', listaValoresCco);
							component.set('v.addmail', '');
							component.set('v.mostrarBotonesAnyadirManual', false);
	
							toastEvent.setParams({
								title: 'Error',
								message: 'Por favor, introduzca un email valido.',
								duration: '50',
								type: 'error',
								mode: 'dismissible'
							});
							toastEvent.fire();
						}
					}
					else{
						component.set('v.addmail', '');
						component.set('v.mostrarBotonesAnyadirManual', false);
					}
	
					//Trabajamos con las listas para el Cc
					if (emailsCanalesComCc.length !== 0) {
						for (var i = 0; i < emailsCanalesComCc.length; i++) {
							if (arrayCc.length === 0) {
								var string = emailsCanalesComCc[i].replace(/ /g, '');
								arrayCc.push(string);
							} else {
								var string = emailsCanalesComCc[i].replace(/ /g, '');
								arrayCc.push(string);
							}
						}
						for (var i = 0; i < arrayCc.length; i++) {
							if (regex.test(arrayCc[i])) {
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
							} else {
								listaEmailComprobadaCc = null;
								break;
							}
						}
						if (listaEmailComprobadaCc != null) {
							var listaFinalMailsCc = [];
							if (listaValoresCc == null) {
								listaFinalMailsCc = llistaEmailComprobadaCc;
							} else {
								listaFinalMailsCc = listaValoresCc.concat(listaEmailComprobadaCc);
							}
						}
						if (listaFinalMailsCc != null) {
							let arrayNoDuplicatesCc = [];
							let arrayEmailsCc = [];
	
							for (var i = 0; i < Object.keys(listaFinalMailsCc).length; i++) {
								var string = listaFinalMailsCc[i].replace(/ /g, '');
								arrayEmailsCc.push(string);
							}
							arrayNoDuplicatesCc = [...new Set(arrayEmailsCc)];
							for (var i = 0; i < arrayNoDuplicatesCc.length; i++) {
								if (listaFinalLimpiaCc == null) {
									var listaFinalLimpiaCc = [];
									listaFinalLimpiaCc.push(arrayNoDuplicatesCc[i]);
								} else {
									listaFinalLimpiaCc.push(' ' + arrayNoDuplicatesCc[i]);
								}
							}
							component.set('v.copiaContacts', listaFinalLimpiaCc);
							component.set('v.addmail', '');
							component.set('v.mostrarBotonesAnyadirManual', false);
						} else {
							component.set('v.paraContacts', listaValoresPara);
							component.set('v.copiaContacts', listaValoresCc);
							component.set('v.ccoContacts', listaValoresCco);
							component.set('v.addmail', '');
							component.set('v.mostrarBotonesAnyadirManual', false);
	
							toastEvent.setParams({
								title: 'Error',
								message: 'Por favor, introduzca un email valido.',
								duration: '50',
								type: 'error',
								mode: 'dismissible'
							});
							toastEvent.fire();
						}
					}
	
					//Trabajamos con las listas para el Cco
					if (emailsCanalesComCco.length !== 0) {
						for (var i = 0; i < emailsCanalesComCco.length; i++) {
							if (arrayCco.length === 0) {
								var string = emailsCanalesComCco[i].replace(/ /g, '');
								arrayCco.push(string);
							} else {
								var string = emailsCanalesComCco[i].replace(/ /g, '');
								arrayCco.push(string);
							}
						}
						for (var i = 0; i < arrayCco.length; i++) {
							if (regex.test(arrayCco[i])) {
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
							} else {
								listaEmailComprobadaCco = null;
								break;
							}
						}
						if (listaEmailComprobadaCco != null) {
							var listaFinalMailsCco = [];
							if (listaValoresCco == null) {
								listaFinalMailsCco = llistaEmailComprobadaCco;
							} else {
								listaFinalMailsCco = listaValoresCco.concat(listaEmailComprobadaCco);
							}
						}
						if (listaFinalMailsCco != null) {
							let arrayNoDuplicatesCco = [];
							let arrayEmailsCco = [];
	
							for (var i = 0; i < Object.keys(listaFinalMailsCco).length; i++) {
								var string = listaFinalMailsCco[i].replace(/ /g, '');
								arrayEmailsCco.push(string);
							}
							arrayNoDuplicatesCco = [...new Set(arrayEmailsCco)];
							for (var i = 0; i < arrayNoDuplicatesCco.length; i++) {
								if (listaFinalLimpiaCco == null) {
									var listaFinalLimpiaCco = [];
									listaFinalLimpiaCco.push(arrayNoDuplicatesCco[i]);
								} else {
									listaFinalLimpiaCco.push(' ' + arrayNoDuplicatesCco[i]);
								}
							}
							component.set('v.ccoContacts', listaFinalLimpiaCco);
							component.set('v.addmail', '');
							component.set('v.mostrarBotonesAnyadirManual', false);
						} else {
							component.set('v.paraContacts', listaValoresPara);
							component.set('v.copiaContacts', listaValoresCc);
							component.set('v.ccoContacts', listaValoresCco);
							component.set('v.addmail', '');
							component.set('v.mostrarBotonesAnyadirManual', false);
	
							toastEvent.setParams({
								title: 'Error',
								message: 'Por favor, introduzca un email valido.',
								duration: '50',
								type: 'error',
								mode: 'dismissible'
							});
							toastEvent.fire();
						}
					}	
				}
				else{
					component.set('v.addmail', '');
					component.set('v.mostrarBotonesAnyadirManual', false);
				}
				
			});
			$A.enqueueAction(emailsParaCanales);
		}
	},

	addListaCC: function(component, event) {
		let idBoton = event.getSource().getLocalId();
		component.set('v.botonAnadir', idBoton);
		let listaValoresCc;
		let emailListCc;
		let noContactos = true;
		let toastEvent = $A.get('e.force:showToast');
		let listaEmailComprobadaCc = null;

		if (typeof component.get('v.copiaContacts') === 'undefined') {
			listaValoresCc = null;
		} else {
			listaValoresCc = component.get('v.copiaContacts');
		}
		if (component.get('v.addmail') === '') {
			emailListCc = null;
		} else {
			emailListCc = component.get('v.addmail');
		}

		if (emailListCc != null) {
			let emailsCcCanales = component.get('c.getCanalesComunicacionManuales');
			let regex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
			emailsCcCanales.setParams({'caseId': component.get('v.caseId'), 'emails': emailListCc, 'NoContactos': noContactos, 'idBotonEntrada': idBoton});
			emailsCcCanales.setCallback(this, s => {
				let listaEmailFinal = s.getReturnValue();
				let emailsCanalesComCc = listaEmailFinal.listadoCc;
				let array = [];

				for (var i = 0; i < emailsCanalesComCc.length; i++) {
					if (array.length ===  0) {
						var string = emailsCanalesComCc[i].replace(/ /g, '');
						array.push(string);
					} else {
						var string = emailsCanalesComCc[i].replace(/ /g, '');
						array.push(string);
					}
				}
				for (var i = 0; i < array.length; i++) {
					if (regex.test(array[i]) ===  true) {
						if (listaValoresCc == null || typeof listaValoresCc === 'undefined' || Object.keys(listaValoresCc).length === 0) {
							if (listaEmailComprobadaCc == null) {
								listaEmailComprobadaCc = [];
								listaEmailComprobadaCc.push(array[i]);
							} else {
								listaEmailComprobadaCc.push(' ' + array[i]);
							}
						} else {
							if (listaEmailComprobadaCc == null) {
								listaEmailComprobadaCc = [];
								listaEmailComprobadaCc.push(' ' + array[i]);
							} else {
								listaEmailComprobadaCc.push(' ' + array[i]);
							}
						}
					} else {
						listaEmailComprobadaCc = null;
						break;
					}
				}
				if (listaEmailComprobadaCc != null) {
					let listaFinalMailsCc = listaValoresCc.concat(listaEmailComprobadaCc);
					let arrayNoDuplicates = [];
					let arrayEmails = [];

					for (var i = 0; i < Object.keys(listaFinalMailsCc).length; i++) {
						var string = listaFinalMailsCc[i].replace(/ /g, '');
						arrayEmails.push(string);
					}
					arrayNoDuplicates = [...new Set(arrayEmails)];
					for (var i = 0; i < arrayNoDuplicates.length; i++) {
						if (listaFinalLimpia == null) {
							var listaFinalLimpia = [];
							listaFinalLimpia.push(arrayNoDuplicates[i]);
						} else {
							listaFinalLimpia.push(' ' + arrayNoDuplicates[i]);
						}
					}
					component.set('v.copiaContacts', listaFinalLimpia);
					component.set('v.addmail', '');
					component.set('v.mostrarBotonesAnyadirManual', false);
				} else {
					component.set('v.copiaContacts', listaValoresCc);
					component.set('v.addmail', '');
					component.set('v.mostrarBotonesAnyadirManual', false);

					toastEvent.setParams({
						title: 'Error',
						message: 'Por favor, introduzca un email valido.',
						duration: '50',
						type: 'error',
						mode: 'dismissible'
					});
					toastEvent.fire();
				}
			});
			$A.enqueueAction(emailsCcCanales);
		}
	},

	addListaCCO: function(component, event, helper) {
		let idBoton = event.getSource().getLocalId();
		component.set('v.botonAnadir', idBoton);
		let listaValoresCco;
		let emailListCco;
		let noContactos = true;
		let toastEvent = $A.get('e.force:showToast');
		let listaEmailComprobadaCco = null;

		if (typeof component.get('v.ccoContacts') === 'undefined') {
			listaValoresCco = null;
		} else {
			listaValoresCco = component.get('v.ccoContacts');
		}
		if (component.get('v.addmail') === '') {
			emailListCco = null;
		} else {
			emailListCco = component.get('v.addmail');
		}

		if (emailListCco != null) {
			let emailsCcoCanales = component.get('c.getCanalesComunicacionManuales');
			let regex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
			emailsCcoCanales.setParams({'caseId': component.get('v.caseId'), 'emails': emailListCco, 'NoContactos': noContactos, 'idBotonEntrada': idBoton});
			emailsCcoCanales.setCallback(this, s => {
				let listaEmailFinal = s.getReturnValue();
				let emailsCanalesComCco = listaEmailFinal.listadoCco;
				let array = [];

				for (var i = 0; i < emailsCanalesComCco.length; i++) {
					if (array.length === 0) {
						var string = emailsCanalesComCco[i].replace(/ /g, '');
						array.push(string);
					} else {
						var string = emailsCanalesComCco[i].replace(/ /g, '');
						array.push(string);
					}
				}
				for (var i = 0; i < array.length; i++) {
					if (regex.test(array[i]) === true) {
						if (listaValoresCco == null || typeof listaValoresCco === 'undefined' || Object.keys(listaValoresCco).length === 0) {
							if (listaEmailComprobadaCco == null) {
								listaEmailComprobadaCco = [];
								listaEmailComprobadaCco.push(array[i]);
							} else {
								listaEmailComprobadaCco.push(' ' + array[i]);
							}
						} else {
							if (listaEmailComprobadaCco == null) {
								listaEmailComprobadaCco = [];
								listaEmailComprobadaCco.push(' ' + array[i]);
							} else {
								listaEmailComprobadaCco.push(' ' + array[i]);
							}
						}
					} else {
						listaEmailComprobadaCco = null;
						break;
					}
				}
				if (listaEmailComprobadaCco != null) {
					let listaFinalMailsCco = listaValoresCco.concat(listaEmailComprobadaCco);
					let arrayNoDuplicates = [];
					let arrayEmails = [];

					for (var i = 0; i < Object.keys(listaFinalMailsCco).length; i++) {
						var string = listaFinalMailsCco[i].replace(/ /g, '');
						arrayEmails.push(string);
					}
					arrayNoDuplicates = [...new Set(arrayEmails)];
					for (var i = 0; i < arrayNoDuplicates.length; i++) {
						if (listaFinalLimpia == null) {
							var listaFinalLimpia = [];
							listaFinalLimpia.push(arrayNoDuplicates[i]);
						} else {
							listaFinalLimpia.push(' ' + arrayNoDuplicates[i]);
						}
					}
					component.set('v.ccoContacts', listaFinalLimpia);
					component.set('v.addmail', '');
					component.set('v.mostrarBotonesAnyadirManual', false);
				} else {
					component.set('v.ccoContacts', listaValoresCco);
					component.set('v.addmail', '');
					component.set('v.mostrarBotonesAnyadirManual', false);

					toastEvent.setParams({
						title: 'Error',
						message: 'Por favor, introduzca un email valido.',
						duration: '50',
						type: 'error',
						mode: 'dismissible'
					});
					toastEvent.fire();
				}
			});
			$A.enqueueAction(emailsCcoCanales);
		}
	},

	//funcion after upload
	openfileUpload: function(component, event, helper) {
		let idsFilesUpload = [];
		event.getParam('files').forEach(file => idsFilesUpload.push(file.documentId));
		//Llamada al helper para actualizar datos de la tabla anexos
		helper.setDataAnexos(component, idsFilesUpload);
	},

	modalNotasEnvioCerrar: function(component) {
		if (component.get('v.checkCerrar') === true){
			component.set('v.isLoadingNotas', true);
			let idCase = component.get('v.caseId');
			let numOperacionesCaso = component.find("idNumOperaciones").get("v.value");
			let numOperacionesCasoInt = parseInt(numOperacionesCaso, 10);
			let numOperacionesOld = component.get('v.record.SEG_N_operaciones_del_caso__c');
			let numOperaciones = component.get('c.informarNumOperacionesCaso');
			numOperaciones.setParams({
				'caseId': idCase, 
				'numeroOperaciones': numOperacionesCasoInt,
				'numOperacionesOld': numOperacionesOld
			});
			numOperaciones.setCallback(this, response => {
				let state = response.getState();
				if (state === 'SUCCESS') {
					component.find('forceRecord').reloadRecord();
					$A.util.removeClass(component.find('backdrop'), 'slds-fade-in-open');
					$A.util.removeClass(component.find('modalAsignarNotasEnvio'), 'slds-fade-in-open');

					component.set('v.selectedNotasTip', 'Sin notas');
					component.set('v.isBusqueda', false);
					component.set('v.isRedactar', false);
					component.set('v.isLoadingNotas', false);
					component.set('v.hasAnexosSelected', false);
				}
				else if (state === 'ERROR') {
					console.log('callback error ' + response.getError());
				}
			});
			$A.enqueueAction(numOperaciones);
			}
		else{
			component.set('v.isLoadingNotas', true);
			component.find('forceRecord').reloadRecord();
			$A.util.removeClass(component.find('backdrop'), 'slds-fade-in-open');
			$A.util.removeClass(component.find('modalAsignarNotasEnvio'), 'slds-fade-in-open');
			component.set('v.selectedNotasTip', 'Sin notas');
			component.set('v.isBusqueda', false);
			component.set('v.isRedactar', false);
			component.set('v.isLoadingNotas', false);
			component.set('v.hasAnexosSelected', false);
		}
	},
	cerrarSiguiente: function(component) {
		component.set('v.numOperacionesCambio', false);
		//Div Inputs
		$A.util.removeClass(component.find('divInputResultados'), 'slds-show');
		$A.util.removeClass(component.find('divBotonesNumOperaciones'), 'slds-hide');
		$A.util.addClass(component.find('divInputResultados'), 'slds-hide');
		$A.util.addClass(component.find('divBotonesNumOperaciones'), 'slds-show');
	},

	notasEnvioCorreo: function(component, event, helper) {
		component.set('v.isLoadingNotas', true);
		let idCase = component.get('v.caseId');
		let notaTip = component.get('v.selectedNotasTip');
		let operativa = 'Envío de Correo';
		let obserInput = component.find('idObservacion').get('v.value');

		if (obserInput === undefined || obserInput === null || obserInput == '') {
			obserInput = 'Sin comentarios';
		}
		let publicar = component.get('c.postOnChatter');
		publicar.setParams({'caseId': idCase, 'observaciones': obserInput, 'operativa': operativa, 'notaTipificada': notaTip});
		publicar.setCallback(this, response => {
			let state = response.getState();
			if (state === 'SUCCESS') {
				$A.enqueueAction(component.get('c.modalNotasEnvioCerrar'));
			}
		});
		$A.enqueueAction(publicar);

	},

	modalNotasEnvioTeclaPulsada: function(component, event) {
		if (event.keyCode === 27) { //Tecla ESC
			$A.enqueueAction(component.get('c.modalNotasEnvioCerrar'));
		}
	},

	cargarNotasTipificadas: function(component) {
		let fetchNotasTipificadas = component.get('c.fetchNotasTipificadas');
		fetchNotasTipificadas.setParam('caseId', component.get('v.caseId'));
		fetchNotasTipificadas.setCallback(this, response => {
			let result = response.getReturnValue();
			let values = [];
			for (let key in result) {
				values.push({label: result[key], value: key});
			}
			values.push({label: 'Sin notas', value: 'Sin notas'});
			component.set('v.notasTipificadas', values);
		});
		$A.enqueueAction(fetchNotasTipificadas);
	},

	textareaOnChange: function(component) {
		component.set('v.mostrarBotonesAnyadirManual', component.get('v.addmail'));
	},

	scrollToTop: function() {
		document.getElementById('elementScroll').scrollTop = 0;
		window.scrollTo({top: 0, behavior: 'smooth'});
	},

	modalAdjuntarArchivosAbrir: function(component) {
		component.set('v.hasAnexosSelected', false);
		$A.util.addClass(component.find('backdrop'), 'slds-fade-in-open');
		$A.util.addClass(component.find('modalAdjuntarArchivos'), 'slds-fade-in-open');
	},

	modalAdjuntarArchivosCerrar: function(component) {
		$A.util.removeClass(component.find('backdrop'), 'slds-fade-in-open');
		$A.util.removeClass(component.find('modalAdjuntarArchivos'), 'slds-fade-in-open');
		component.set('v.currentSelectedRowsAnexos', '');
	},

	adjuntarArchivos: function(component) {
		component.set('v.hasAnexosSelected', true);
		$A.util.removeClass(component.find('backdrop'), 'slds-fade-in-open');
		$A.util.removeClass(component.find('modalAdjuntarArchivos'), 'slds-fade-in-open');
	},

	eliminarDireccion: function(component, event) {
		let params = event.getSource().get('v.name').split('|');
		let lista = component.get('v.' + params[0]);
		if(params[0] === 'paraContacts' && lista.length === 1){
			component.set('v.' + params[0], lista);
		}
		else{
			lista.splice(lista.indexOf(params[1]), 1);
			component.set('v.' + params[0], lista);
		}
		
	}
});