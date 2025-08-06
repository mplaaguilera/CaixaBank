({
	doInit: function(component) {
		let tipoBuscador = component.get('v.tipoBuscador');
		if (tipoBuscador === 'registroVinculado') {
			let datosRegistro = component.get('c.datosRegistro');
			datosRegistro.setParams({'recordId': component.get('v.recordId')});
			datosRegistro.setCallback(this, response => {
				console.log('response ' + response.getState());
				if (response.getState() === 'SUCCESS') {
					let respuesta = response.getReturnValue();
					let registro = respuesta.infoCaso;
					let permissionSetBool = respuesta.permissionSetSup;
					if (component.get('v.sObjectName') === 'Case') {
						//Caso
						if ((registro.AccountId && registro.ContactId || registro.CC_No_Identificado__c) && permissionSetBool === false ){
							component.set('v.identificacionPrevia', false );
						} 
						
						if (registro.AccountId != null && registro.Account.Name != null){
							var inputBuscador = component.find("valorBusqueda");
							inputBuscador.set("v.value", registro.Account.Name);
						}
						//Nuevo para Segmentos.
						component.set('v.tipoCaso', registro.RecordType.DeveloperName);
						component.set('v.estadoCaso', registro.Status);
					}
				}
			});
			$A.enqueueAction(datosRegistro);
		}
		let datosALF = component.get('c.datosParamALFBackgroundAura');
		datosALF.setCallback(this, response => {
			if (response.getState() === 'SUCCESS') {
				let retorno = response.getReturnValue();
				component.set('v.alfBackground', retorno);
			}
		})
		$A.enqueueAction(datosALF);
	},

	recordUpdated: function(component, event) {
		let tipoBuscador = component.get('v.tipoBuscador');
		if (tipoBuscador === 'registroVinculado') {
			if (event.getParams().changeType === 'CHANGED') {
				if ('CC_No_Identificado__c' in event.getParams().changedFields
					|| 'CC_Fecha_Fin__c' in event.getParams().changedFields
					|| 'AccountId' in event.getParams().changedFields
					|| 'ContactId' in event.getParams().changedFields) {
					$A.enqueueAction(component.get('c.doInit'));
				}
			}
		}
	},

	iniciarBusqueda: function(component, event, helper) {
		//Gestión visual secciones
		helper.resetErrores(component);
		helper.resetResultados(component);
		helper.resetResultadosApex(component);
		helper.resetFiltroContactos(component);
		helper.resetCuentaSeleccionada(component);

		let tipoBuscador = component.get('v.tipoBuscador');
		if (tipoBuscador === 'registroVinculado') {
			let getEsPropietarioCaso = component.get('c.getEsPropietarioObjeto');
			getEsPropietarioCaso.setParams({'recordId': component.get('v.recordId')});
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
		} else {
			//Modo sin registro vinculado.

			//Buscar cuentas y contactos.
			helper.buscarDatosClientes(component);
		}
	},

	asociarCuenta: function(component, event, helper) {
		component.set('v.bEsperaSFDC', true);
		helper.resetCuentaSeleccionada(component);
		helper.resetErrores(component);
		let sCuenta = event.getSource().get('v.name');
		component.set('v.cuentaSel', sCuenta);
		let setBackgroundAlf = component.get('v.alfBackground');
		let sTipoRegistro = component.get('v.sObjectName');

		let tipoBuscador = component.get('v.tipoBuscador');
		if (tipoBuscador === 'registroVinculado') {
			if (sTipoRegistro === 'Case') {
				//Actualizar el AccountId del caso.
				let setClienteCaso = component.get('c.setClienteContactoCaso');
				setClienteCaso.setParams({'clienteId': sCuenta, 'contactoId': '', 'casoId': component.get('v.recordId')});
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
								helper.resetResultados(component);
								helper.resetResultadosApex(component);
								helper.resetFiltroContactos(component);

								//helper.mostrarToast('success', 'Se asoció correctamente la cuenta al caso', 'Se asoció correctamente la cuenta al caso.');
								component.set('v.identificacionPrevia', true);

								//Buscar los contactos del cliente asociado.
								helper.buscarDatosClientes(component);
							}
						}
					} else {
						//Mostrar error
						component.set('v.bError', true);
						component.set('v.sMensErr', 'Se ha producido un error al actualizar el caso.');
						console.error('Error <c.setClienteContactoCaso>. Detalle: ' + JSON.stringify(response.getError()));
					}
					$A.get('e.force:refreshView').fire();
				});
				$A.enqueueAction(setClienteCaso);

				let actualizarClienteALF = component.get('c.actualizarClienteAlfabetico');
				actualizarClienteALF.setParams({'clienteId': sCuenta});
				actualizarClienteALF.setCallback(this, response => {
					let tituloToast = '';
					let mensajeToast = '';
					if (response.getState() === 'SUCCESS') {
						let retornoALF = response.getReturnValue();
						if (retornoALF !== null) {
							if (retornoALF.errorUser !== '') {
								tituloToast = retornoALF.errorUser;
								mensajeToast = 'La operativa se puede seguir realizando aunque no se ha refrescado la información de ALF. Detalle: ' + retornoALF.errorDetail;
								mensajeToast = mensajeToast.replace(/[\\[\]{}]/g, '');
								helper.mostrarToast('warning', tituloToast, mensajeToast);
							}
						}
					} else {
						//Mostrar error
						tituloToast = 'Error al refrescar los datos del cliente desde Alfabético.';
						mensajeToast = 'La operativa se puede seguir realizando aunque no se ha refrescado la información de ALF. Detalle: ' + JSON.stringify(response.getError());
						mensajeToast = mensajeToast.replace(/[\\[\]{}]/g, '');
						helper.mostrarToast('warning', tituloToast, mensajeToast);
					}
					$A.get('e.force:refreshView').fire();
				});
				console.log('Valor parametro alf asinc : ' + component.get('v.alfBackground'));
				if (setBackgroundAlf === 'Y') {
					actualizarClienteALF.setBackground();
				}
				$A.enqueueAction(actualizarClienteALF);
			}
		} else {
			//Modo sin registro vinculado.
			component.set('v.bEsperaSFDC', false);
			component.set('v.searchAccountId', sCuenta);
			component.set('v.searchContactId', '');
			component.find('accountData').reloadRecord();

			let actualizarClienteAlfabetico = component.get('c.actualizarClienteAlfabetico');
			actualizarClienteAlfabetico.setParams({'clienteId': sCuenta});
			actualizarClienteAlfabetico.setCallback(this, response => {
				if (response.getState() === 'SUCCESS') {

					let retornoALF = response.getReturnValue();
					if (retornoALF !== null) {
						if (retornoALF.errorUser !== '') {
							console.error('Error <c.actualizarClienteAlfabetico>. Detalle (user): ' + retornoALF.errorUser);
							console.error('Error <c.actualizarClienteAlfabetico>. Detalle (detail): ' + retornoALF.errorDetail);
							console.error('Error <c.actualizarClienteAlfabetico>. Detalle (code): ' + retornoALF.error);
						}
					}
				} else {
					//Error detectado. Se registra error en la consola.
					console.error('Error <c.actualizarClienteAlfabetico>. Detalle: ' + JSON.stringify(response.getError()));
				}

				//Enlazar con la búsqueda de contactos.
				helper.buscarDatosClientes(component);
			});
			$A.enqueueAction(actualizarClienteAlfabetico);
		}
	},

	asociarContacto: function(component, event, helper) {
		component.set('v.bEsperaSFDC', true);
		helper.resetErrores(component);
		let setBackgroundAlf = component.get('v.alfBackground');
		let registroSeleccionado = event.getSource().get('v.name').split('##');
		let sTipoRegistro = component.get('v.sObjectName');

		let tipoBuscador = component.get('v.tipoBuscador');
		if (tipoBuscador === 'registroVinculado') {
			if (sTipoRegistro === 'Case') {
				//Actualizar el ContactId y AccountId del caso.
				let setClienteCaso = component.get('c.setClienteContactoCaso');
				setClienteCaso.setParams({'clienteId': registroSeleccionado[0], 'contactoId': registroSeleccionado[1], 'casoId': component.get('v.recordId')});
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
								//helper.mostrarToast('success', 'Se asoció correctamente el contacto al caso', 'Se asoció correctamente el contacto al caso.');
								component.set('v.identificacionPrevia', true);
								component.set('v.sBusqueda', '');
								helper.resetResultados(component);
								helper.resetResultadosApex(component);
								helper.resetFiltroContactos(component);
								helper.resetCuentaSeleccionada(component);
							}
						}
					} else {
						//Mostrar error
						component.set('v.bError', true);
						component.set('v.sMensErr', 'Se ha producido un error al actualizar el caso.');
						console.error('Error <c.setClienteContactoCaso>. Detalle: ' + JSON.stringify(response.getError()));
					}
					$A.get('e.force:refreshView').fire();
				});
				$A.enqueueAction(setClienteCaso);

				let actualizarClienteALF = component.get('c.actualizarClienteAlfabetico');
				actualizarClienteALF.setParams({'clienteId': registroSeleccionado[0]});
				actualizarClienteALF.setCallback(this, response => {
					let tituloToast = '';
					let mensajeToast = '';
					if (response.getState() === 'SUCCESS') {
						let retornoALF = response.getReturnValue();
						if (retornoALF !== null) {
							if (retornoALF.errorUser !== '') {
								tituloToast = retornoALF.errorUser;
								mensajeToast = 'La operativa se puede seguir realizando aunque no se ha refrescado la información de ALF. Detalle: ' + retornoALF.errorDetail;
								mensajeToast = mensajeToast.replace(/[\\[\]{}]/g, '');
								helper.mostrarToast('warning', tituloToast, mensajeToast);
							}
						}
					} else {
						//Mostrar error
						tituloToast = 'Error al refrescar los datos del cliente desde Alfabético.';
						mensajeToast = 'La operativa se puede seguir realizando aunque no se ha refrescado la información de ALF. Detalle: ' + JSON.stringify(response.getError());
						mensajeToast = mensajeToast.replace(/[\\[\]{}]/g, '');
						helper.mostrarToast('warning', tituloToast, mensajeToast);
					}
					$A.get('e.force:refreshView').fire();
				});
				if (setBackgroundAlf === 'Y') {
					actualizarClienteALF.setBackground();
				}
				$A.enqueueAction(actualizarClienteALF);
			}
		} else {
			//Modo sin registro vinculado.
			component.set('v.bEsperaSFDC', false);
			component.set('v.searchAccountId', registroSeleccionado[0]);
			component.set('v.searchContactId', registroSeleccionado[1]);
			component.find('accountData').reloadRecord();
			component.find('contactData').reloadRecord();

			helper.resetErrores(component);
			helper.resetResultados(component);
			helper.resetResultadosApex(component);
			helper.resetFiltroContactos(component);
			helper.resetCuentaSeleccionada(component);

			let actualizarClienteAlfabetico = component.get('c.actualizarClienteAlfabetico');
			actualizarClienteAlfabetico.setParams({'clienteId': registroSeleccionado[0]});
			actualizarClienteAlfabetico.setCallback(this, response => {
				if (response.getState() === 'SUCCESS') {
					let retornoALF = response.getReturnValue();
					if (retornoALF !== null) {
						if (retornoALF.errorUser !== '') {
							console.error('Error <c.actualizarClienteAlfabetico>. Detalle (user): ' + retornoALF.errorUser);
							console.error('Error <c.actualizarClienteAlfabetico>. Detalle (detail): ' + retornoALF.errorDetail);
							console.error('Error <c.actualizarClienteAlfabetico>. Detalle (code): ' + retornoALF.error);
						}
					}
				} else {
					//Error detectado. Se registra error en la consola.
					console.error('Error <c.actualizarClienteAlfabetico>. Detalle: ' + JSON.stringify(response.getError()));
				}
			});
			$A.enqueueAction(actualizarClienteAlfabetico);
		}
	},

	lanzarBusqueda: function(component, event) {
		if (event.which === 13 && component.get('v.sBusqueda') !== '') { //Intro
			$A.enqueueAction(component.get('c.iniciarBusqueda'));
		}
	},

	cambioValorBusqueda: function(component, event, helper) {
		helper.resetErrores(component);
		if (!component.get('v.sBusqueda')) {
			helper.resetResultados(component);
			helper.resetResultadosApex(component);
			helper.resetFiltroContactos(component);
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
			helper.resetFiltroContactos(component);
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

	beforePage: function(component) {
		let pagina = component.get('v.pagina');
		pagina = pagina - 1;
		if (pagina < 0) {
			pagina = 1;
		}
		component.set('v.pagina', pagina);
		let oMap = component.get('v.searchResult');
		component.set('v.oCuentas', oMap['BUSQUEDA_CUENTAS_' + component.get('v.pagina').toString()]);
		component.set('v.oContactos', oMap['BUSQUEDA_CONTACTOS_' + component.get('v.pagina').toString()]);
	},

	nextPage: function(component) {
		let pagina = component.get('v.pagina');
		let totalPaginas = component.get('v.totalPaginas');
		pagina = pagina + 1;
		if (pagina > totalPaginas) {
			pagina = totalPaginas;
		}
		component.set('v.pagina', pagina);
		let oMap = component.get('v.searchResult');
		component.set('v.oCuentas', oMap['BUSQUEDA_CUENTAS_' + component.get('v.pagina').toString()]);
		component.set('v.oContactos', oMap['BUSQUEDA_CONTACTOS_' + component.get('v.pagina').toString()]);
	},

	handleActualizarIdentificacion: function(component, event, helper) {
		component.set('v.bEsperaSFDC', true);
		let action = component.get('c.actualizarIdentificacion');
		action.setParams({'recordId': component.get('v.recordId'), 'noIdentificado': true, 'tipoRegistro': component.get('v.sObjectName')});
		action.setCallback(this, response => {
			if (response.getState() === 'SUCCESS') {
				component.set('v.identificacionPrevia', true);
				helper.mostrarToast('info', 'Cliente no se ha identificado', 'El cliente ' + (component.get('v.sObjectName') === 'Case' ? 'del caso' : 'de la llamada') + ' no se ha identificado.');
			}
			$A.get('e.force:refreshView').fire();
			component.set('v.bEsperaSFDC', false);
		});
		$A.enqueueAction(action);
	},

	recordDataAccountUpdated: function(component, event) {
		if (event.getParams().changeType === 'LOADED' || event.getParams().changeType === 'CHANGED') {
			component.set('v.searchAccountName', component.get('v.cuentaData.Name'));

		} else if (event.getParams().changeType === 'ERROR') {
			console.error(component.get('v.ldsError'));
		}
	},

	recordDataContactUpdated: function(component, event) {
		if (event.getParams().changeType === 'LOADED' || event.getParams().changeType === 'CHANGED') {
			component.set('v.searchContactName', component.get('v.contactoData.Name'));

		} else if (event.getParams().changeType === 'ERROR') {
			console.error(component.get('v.ldsError'));
		}
	}

});