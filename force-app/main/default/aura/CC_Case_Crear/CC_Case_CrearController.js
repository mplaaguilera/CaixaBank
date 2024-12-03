({
	doInit: function(component, helper) {
		let recordTypeId = component.get('v.pageReference.state.recordTypeId');
		let recordId = component.get("v.recordId");

		//comprobar el rol del usuario actual
		let comprobarRol = component.get('c.comprobarRol');
		comprobarRol.setCallback(this, responseComprobarRol => {
			if (responseComprobarRol.getState() === 'SUCCESS') {
				let nombreRol = responseComprobarRol.getReturnValue().nombreRol;
				component.set('v.nombreRol', nombreRol);
				if (nombreRol !== 'SPV General' && nombreRol !== 'SAC General' && nombreRol !== 'SACH' && nombreRol !== 'Segmentos' && nombreRol !== 'Testamentarías' && nombreRol !== 'GRR' && nombreRol !== 'GRR Agente') {
					let obtenerVariablesCOPS = component.get('c.obtenerVariablesCOPS');
					obtenerVariablesCOPS.setParams({"recordTypeId": recordTypeId, "recordId": recordId});
					obtenerVariablesCOPS.setCallback(this, responseObtenerVariablesCOPS => {
						if (responseObtenerVariablesCOPS.getState() === 'SUCCESS') {
							let retorno = responseObtenerVariablesCOPS.getReturnValue();
							component.set('v.negocio', retorno.recordTypeDeveloperName);
							component.set('v.userDepartment', retorno.usuarioDepartamento);
							if (retorno.perfilUsuario === 'OS' && retorno.recordTypeDeveloperName === 'OS' && retorno.usuarioDepartamento) {
								component.set('v.procedenciasCops', true);
							} else if (retorno.perfilUsuario === 'CC' || retorno.perfilUsuario === 'System Administrator' || retorno.recordTypeDeveloperName === 'CC' || retorno.recordTypeDeveloperName === 'OS') {
								component.set('v.recordTypeId',retorno.recordTypeId);
								component.set('v.canalProcedenciaRequired', true);
								if (retorno.esClienteCC === 'true'){
									component.set('v.esClienteCC', true);
								}
							}
							if ((retorno.perfilUsuario === 'System Administrator' || retorno.perfilUsuario === 'OS') && retorno.recordTypeDeveloperName === 'OS') {
								component.set('v.grupoTrabajoCops', true);
							}
						} else if (responseObtenerVariablesCOPS.getState() === 'ERROR') {
							console.error(JSON.stringify(obtenerVariablesCOPS.getError()));
						}
					});
					$A.enqueueAction(obtenerVariablesCOPS);
				} else {
					if (!recordTypeId) {
						recordTypeId = responseComprobarRol.getReturnValue().recordTypeId;
					}
					if (nombreRol === 'SACH') {
						component.set('v.canalProcedenciaRequired', true);
					} else if (nombreRol === 'GRR' || nombreRol === 'GRR Agente') { 
						let getProcedenciaUsuarioGRR = component.get('c.getProcedenciaUsuarioGRR');
						getProcedenciaUsuarioGRR.setCallback(this, responseProcedenciaGRR => {
							if (responseProcedenciaGRR.getState() === 'SUCCESS') {
								component.set('v.valorGRR', responseProcedenciaGRR.getReturnValue());
							} else if (responseProcedenciaGRR.getState() === 'ERROR') {
								console.error(JSON.stringify(getProcedenciaUsuarioGRR.getError()));
							}
						});
						$A.enqueueAction(getProcedenciaUsuarioGRR);

						component.set('v.canalProcedenciaRequired', true);
						component.set('v.esClienteGRR', true);
					}
					if (nombreRol === 'Testamentarías') {
						component.set('v.canalProcedenciaRequired', true);
						component.set('v.esClienteTMS', true);
					}
					if (nombreRol === 'SPV General') {
						component.set('v.spinner', false);
						component.set('v.esCasoSPV', true);
					}
				}
				component.set('v.recordTypeId', recordTypeId);
				component.set('v.mostrarRecordEditForm', true);

			} else if (responseComprobarRol.getState() === 'ERROR') {
				console.error(JSON.stringify(comprobarRol.getError()));
			}
		});
		$A.enqueueAction(comprobarRol);

		//US713663 - Segmentos - Crear caso nuevo incorporando el NIF del cliente
		let isPerfilSegmentos = component.get('c.isPerfilSegmentos');
		isPerfilSegmentos.setCallback(this, responseIsPerfilSegmentos => {
			if (responseIsPerfilSegmentos.getState() === 'SUCCESS') {
				let retorno = responseIsPerfilSegmentos.getReturnValue();
				if (retorno === true) {
					component.set('v.casoSegmentos', true);
					component.find('canalEntradaElse').set('v.value','Oficina');
					component.set('v.mostrarRecordEditForm', true);
				}
			} else if (responseIsPerfilSegmentos.getState() === 'ERROR') {
				console.error(JSON.stringify(isPerfilSegmentos.getError()));
			}
		});
		$A.enqueueAction(isPerfilSegmentos);
		///FIN - US713663 - Segmentos
	},

	getCanalesProcedencia: function(component) {
		let listaCanalesProcedencia = [];

		if (component.find('canalEntrada').get('v.value') === 'Agenda de Riesgos') {
			listaCanalesProcedencia = [{label: 'Buzón CCI Holabank', value: 'Buzón CCI Holabank'}];

		} else if (component.find('canalEntrada').get('v.value') === 'Email') {
			if (component.get('v.userDepartment').includes('BOS')) {
				listaCanalesProcedencia.push(
					{label: 'Buzón KYC Renewal', value: 'Buzón KYC Renewal'},
					{label: 'Buzón Service Desk', value: 'Buzón Service Desk'}
				);
			}

			if (component.get('v.userDepartment').includes('EFECTIVO')) {
				listaCanalesProcedencia.push({label: 'Buzón Efectivo', value: 'Buzón Efectivo COPS'});
			}

			if (component.get('v.userDepartment').includes('GOC')) {
				listaCanalesProcedencia.push(
					{label: 'Buzón Contact Center International', value: 'Buzón Contact Center International'},
					{label: 'Buzón International Support', value: 'Buzón International Support'},
					{label: 'Buzón International Operations', value: 'Buzón International Operations'},
					{label: 'Buzón CC Confirming International', value: 'Buzón CC Confirming International'}
				);
			}

			if (component.get('v.userDepartment').includes('HOLABANK')) {
				listaCanalesProcedencia.push({label: 'Buzón CCI Holabank', value: 'Buzón CCI Holabank'});
			}

			if (component.get('v.userDepartment').includes('UAC')) {
				listaCanalesProcedencia.push(
					{label: 'Buzón Export Online', value: 'Buzón Export Online'},
					{label: 'Buzón Comercio Exterior', value: 'Buzón Comercio Exterior'},
					{label: 'Buzón Calidad Créditos Documentarios', value: 'Buzón Calidad Créditos Documentarios'}
				);
			}

			if (component.get('v.userDepartment').includes('UAFE')) {
				listaCanalesProcedencia.push(
					{label: 'Buzón Contact Center Confirming', value: 'Buzón Contact Center Confirming'},
					{label: 'Buzón UAFE', value: 'Buzón UAFE'},
					{label: 'Buzón UAFE Express', value: 'Buzón UAFE Express'},
					{label: 'Buzón Crédito Stock', value: 'Buzón Crédito Stock'},
					{label: 'Buzón Factoring Sindicados', value: 'Buzón Factoring Sindicados'},
					{label: 'Buzón Inditex Suppliers', value: 'Buzón Inditex Suppliers'}
				);
			}

			if (component.get('v.userDepartment').includes('EXPFIN')) {
				listaCanalesProcedencia.push({label: 'Buzón Export Finance', value: 'Buzón Export Finance'});
			}

			if (component.get('v.userDepartment').includes('OPCOMEX')) {
				listaCanalesProcedencia.push({label: 'Buzón Operativa Comex', value: 'Buzón Operativa Comex'});
			}

			if (component.get('v.userDepartment').includes('FINCOMEX')) {
				listaCanalesProcedencia.push({label: 'Buzón Financiación Comex', value: 'Buzón Financiación Comex'});
			}

			if (component.get('v.userDepartment').includes('GESTORIAS')) {
				listaCanalesProcedencia.push({label: 'Buzón Servicio Firma', value: 'Buzón Servicio Firma'});
			}

			if (component.get('v.userDepartment').includes('AVALES')) {
				listaCanalesProcedencia.push({label: 'Buzón Avales Internacionales', value: 'Buzón Avales Internacionales'});
			}

		} else if (component.find('canalEntrada').get('v.value') === 'Phone') {
			if (component.get('v.userDepartment').includes('BOS')) {
				listaCanalesProcedencia.push({label: 'Teléfono COPS Bancos', value: 'Teléfono COPS Bancos'});
			}
			if (component.get('v.userDepartment').includes('EFECTIVO')) {
				listaCanalesProcedencia.push({label: 'Teléfono Efectivo', value: 'Teléfono Efectivo'});
			}
			if (component.get('v.userDepartment').includes('GOC')) {
				listaCanalesProcedencia.push({label: 'Teléfono COPS Internacional', value: 'Teléfono COPS Internacional'});
			}
			if (component.get('v.userDepartment').includes('HOLABANK')) {
				listaCanalesProcedencia.push({label: 'Teléfono CCI HOLABANK', value: 'Teléfono CCI HOLABANK'});
			}
			if (component.get('v.userDepartment').includes('UAC')) {
				listaCanalesProcedencia.push(
					{label: 'Teléfono COPS Clientes', value: 'Teléfono COPS atención clientes'},
					{label: 'Teléfono COPS Oficinas', value: 'Teléfono COPS atención empleados'},
					{label: 'Teléfono COPS Oficinas C2C', value: 'Teléfono COPS Oficinas C2C'}
				);
			}
			if (component.get('v.userDepartment').includes('UAFE')) {
				listaCanalesProcedencia.push(
					{label: 'Teléfono UAFE', value: 'Teléfono UAFE'},
					{label: 'Teléfono CC Confirming', value: 'Teléfono CC Confirming'},
					{label: 'Teléfono Inditex Nacional', value: 'Teléfono Inditex Nacional'},
					{label: 'Teléfono Inditex Internacional', value: 'Teléfono Inditex Internacional'},
					{label: 'Teléfono Crédito Stock', value: 'Teléfono Crédito Stock'},
					{label: 'Teléfono UAFE Especialistas', value: 'Teléfono UAFE Especialistas'}
				);
			}
			if (component.get('v.userDepartment').includes('GESTORIAS')) {
				listaCanalesProcedencia.push({label: 'Teléfono Servicio Firma', value: 'Teléfono Servicio Firma'});
			}
			if (component.get('v.userDepartment').includes('AVALES')) {
				listaCanalesProcedencia.push({label: 'Teléfono COPS Avales Internacionales', value: 'Teléfono COPS Avales Internacionales'});
			}
		} else if (component.find('canalEntrada').get('v.value') === 'Valija digital') {
			listaCanalesProcedencia = [{label: 'Valija Digital', value: 'Valija Digital'}];
		}
		component.set('v.opcionesProcedencia', listaCanalesProcedencia);
	},

	load: function(component) {
		//Finalización de la carga del formulario mediante Lightning Data Service
		component.set('v.spinner', false);
	},

	submit: function(component, event) {
		event.preventDefault();
		var errores = false;

		if(component.get('v.procedenciasCops')){
			if (!component.find("desplegableProcedencia").checkValidity()){
				errores = true;
			}
		}
		if(component.get('v.grupoTrabajoCops')){
			if (!component.find("desplegableGT").checkValidity()){
				errores = true;
			}
		}
		if (!errores){
			component.find("formulario").submit();

			component.set('v.spinner', true);
		}	

	},

	comprobacion: function(component, event) {
		$A.enqueueAction(component.get('c.comprobacionCOPS'));
	},

	comprobacionCOPS: function(component, event) {
		if(component.get('v.procedenciasCops')){
			if (!component.find("desplegableProcedencia").checkValidity()){
				component.find("desplegableProcedencia").showHelpMessageIfInvalid();
			}
		}
		if(component.get('v.grupoTrabajoCops')){
			if (!component.find("desplegableGT").checkValidity()){
				component.find("desplegableGT").showHelpMessageIfInvalid();
			}
		}
	},

	success: function(component, event) {
		let contacto = component.get("v.recordId");
		//Caso creado
		let retorno = event.getParams();
		component.set('v.recordId', retorno.response.id);
		//Si el caso se el objeto Contact con el recordType CC_Empleado se asocia directamente al caso
		let asociarContactoCCEmpleado = component.get('c.asociarContactoCCEmpleado');
		asociarContactoCCEmpleado.setParams({"recordId": retorno.response.id,
											"contactId": contacto});
		$A.enqueueAction(asociarContactoCCEmpleado);
		//Abrir nueva pestaña con el caso recién creado
		$A.enqueueAction(component.get('c.abrirTab'));
		//Crear actividad de creación de caso (COPS)
		let crearActividadCasoNuevo = component.get('c.crearActividadCasoNuevo');
		crearActividadCasoNuevo.setParam('recordId', retorno.response.id);
		$A.enqueueAction(crearActividadCasoNuevo);
		
		//Mostrar Toast de confirmación
		let toastEvent = $A.get('e.force:showToast');
		toastEvent.setParams({title: 'Se creó Caso', message: 'Se creó correctamente el caso ' + retorno.response.fields.CaseNumber.value, type: 'success'});
		toastEvent.fire();

		component.set('v.spinner', false);
	},

	error: function(component, event) {
		//Error en la creación
		console.error(event.getParam('detail'));
		component.set('v.spinner', false);
		//component.find('botonEnviar').set('v.disabled', false);
		//Mostrar Toast de error
		let toastEvent = $A.get('e.force:showToast');
		toastEvent.setParams({title: 'Error creando Caso.', message: event.getParam('detail'), type: 'error'});
		toastEvent.fire();
	},

	abrirTab: function(component) {
		//Abrir pestaña nueva y cerrar pestaña actual.
		let workspaceAPI = component.find('workspace');

		//Debe hacerse en este orden según issue W-5711798
		//https://success.salesforce.com/issues_view?id=a1p3A000000BMOgQAO&

		workspaceAPI.getFocusedTabInfo().then(response => {
			workspaceAPI.openTab({recordId: component.get('v.recordId'), focus: true})
				.then(() => workspaceAPI.closeTab({tabId: response.tabId}));
		});
	},

	cerrarTab: function(component) {
		//Cerrar pestaña actual
		let workspaceAPI = component.find('workspace');
		workspaceAPI.getFocusedTabInfo().then(response => workspaceAPI.closeTab({tabId: response.tabId}));
	},

	grabarProcedenciaUno: function(component) {
		//se fuerza espera para evitar error en el método grabarProcedencia al obtener valor del combobox antes de que se haya registrado
		component.set('v.valorProcedencia', component.find('desplegableProcedencia').get('v.value'));
		var a = component.get('c.grabarProcedencia');
		$A.enqueueAction(a) 
	},

	grabarProcedenciaDos: function(component) {
		//se fuerza espera para evitar error en el método grabarProcedencia al obtener valor del combobox antes de que se haya registrado
		component.set('v.valorProcedencia', component.find('desplegableProcedenciaDos').get('v.value'));
		var a = component.get('c.grabarProcedencia');
		$A.enqueueAction(a) 
	},

	grabarProcedencia: function(component) {
		if(component.get('v.procedenciasCops')){
			//Grabar el canal de procedencia en base de datos - combobox
			component.find('CC_Canal_Procedencia__c').set('v.value', component.get('v.valorProcedencia'));
			let obtenerTipoContacto = component.get('c.obtenerTipoContacto');
			obtenerTipoContacto.setParam('canalProd', component.get('v.valorProcedencia'));
			obtenerTipoContacto.setCallback(this, response => {
				if (response.getState() === 'SUCCESS') {
					component.set('v.valorContacto', response.getReturnValue());
				}
			});
			$A.enqueueAction(obtenerTipoContacto);
		}

		if(component.get('v.grupoTrabajoCops')){
			
			component.find('desplegableGT').set('v.value', null);
			component.find('OS_GrupoTrabajo__c').set('v.value', null);
			
			var getGruposTrabajo = component.get('c.getGruposTrabajo');
			$A.enqueueAction(getGruposTrabajo);			
		}
	},

	getGruposTrabajo: function(component) {
		let listaGT = [];
		let obtenerGruposTrabajo = component.get('c.obtenerGruposTrabajo');

		obtenerGruposTrabajo.setParam('canalProd', component.get('v.valorProcedencia'));
		obtenerGruposTrabajo.setCallback(this, response => {
			if (response.getState() === 'SUCCESS') {
				response.getReturnValue().forEach(grupo => {
					listaGT.push({label: grupo, value: grupo});
				});

				component.set('v.opcionesGT', listaGT);
			} 
		});
		$A.enqueueAction(obtenerGruposTrabajo);
	},

	grabarGrupoTrabajo: function(component) {
		component.find('OS_GrupoTrabajo__c').set('v.value', component.find('desplegableGT').get('v.value'));

		// component.find('CC_Canal_Procedencia__c').set('v.value', component.find('desplegableProcedencia').get('v.value'));

	},

	//US713663 - Segmentos - Crear caso nuevo incorporando el NIF del cliente
	validezNif: function(component) {
		var nifIndicado = component.find('modalCrearNuevoCasoNIF').get('v.value');
		var resultNIF = component.find("resultNIF").getElement();
		if(nifIndicado.length > 7){
			resultNIF.innerHTML = "Se comprobará al guardar";
			if($A.util.hasClass(resultNIF, 'textoRojo')) {
				$A.util.removeClass(resultNIF, 'textoRojo');
				$A.util.toggleClass(resultNIF, 'textoVerde');
			} else if(!$A.util.hasClass(resultNIF, 'textoVerde')){
				$A.util.toggleClass(resultNIF, 'textoVerde');
			}
		} else {
			resultNIF.innerHTML = "NIF no válido";
			if($A.util.hasClass(resultNIF, 'textoVerde')) {
				$A.util.removeClass(resultNIF, 'textoVerde');
				$A.util.toggleClass(resultNIF, 'textoRojo');
			} else if(!$A.util.hasClass(resultNIF, 'textoRojo')){
				$A.util.toggleClass(resultNIF, 'textoRojo');
			}
		}

	},

	identificarNIF: function(component) {
		//var regex = /^(?<!\d)\d{8}(?!\d)[A-z]/; - Se desestima el uso del regex
		var nifIndicado = component.find('modalCrearNuevoCasoNIF').get('v.value');
		var resultNIF = component.find("resultNIF").getElement();
		if(nifIndicado.length > 7){
			let obtencionNIF = component.get('c.obtencionNIF');
			obtencionNIF.setParams({"nif": nifIndicado});
			obtencionNIF.setCallback(this, responseBbtencionNIF => {
				if (responseBbtencionNIF.getState() === 'SUCCESS') {
					let result = responseBbtencionNIF.getReturnValue();
					if(result[0] === 'error'){
						component.set('v.nif', null);
						component.set('v.org', null);
						component.set('v.zona', null);
						resultNIF.innerHTML = 'NIF no existente';
						if($A.util.hasClass(resultNIF, 'textoVerde')) {
							$A.util.removeClass(resultNIF, 'textoVerde');
							$A.util.toggleClass(resultNIF, 'textoRojo');
						} else if(!$A.util.hasClass(resultNIF, 'textoRojo')){
							$A.util.toggleClass(resultNIF, 'textoRojo');
						}
					} else if(result[1] === 'errorOrgZona'){
						component.set('v.nif', null);
						component.set('v.org', null);
						component.set('v.zona', null);
						resultNIF.innerHTML = 'La cuenta carece de Org/Zona';
						if($A.util.hasClass(resultNIF, 'textoVerde')) {
							$A.util.removeClass(resultNIF, 'textoVerde');
							$A.util.toggleClass(resultNIF, 'textoRojo');
						} else if(!$A.util.hasClass(resultNIF, 'textoRojo')){
							$A.util.toggleClass(resultNIF, 'textoRojo');
						}
					} else {
						component.set('v.nif', result[0]);
						component.set('v.org', result[1]);
						component.set('v.zona', result[2]);
						resultNIF.innerHTML = "NIF válido";
						if($A.util.hasClass(resultNIF, 'textoRojo')) {
							$A.util.removeClass(resultNIF, 'textoRojo');
							$A.util.toggleClass(resultNIF, 'textoVerde');
						} else if(!$A.util.hasClass(resultNIF, 'textoVerde')){
							$A.util.toggleClass(resultNIF, 'textoVerde');
						}
					}
				} else if (responseBbtencionNIF.getState() === 'ERROR') {
					console.error(JSON.stringify(obtencionNIF.getError()));
				}
			});
			$A.enqueueAction(obtencionNIF);
		} else {
			component.set('v.nif', null);
			component.set('v.org', null);
			component.set('v.zona', null);
			resultNIF.innerHTML = "NIF no válido";
			if($A.util.hasClass(resultNIF, 'textoVerde')) {
				$A.util.removeClass(resultNIF, 'textoVerde');
				$A.util.toggleClass(resultNIF, 'textoRojo');
			} else if(!$A.util.hasClass(resultNIF, 'textoRojo')){
				$A.util.toggleClass(resultNIF, 'textoRojo');
			}
		}
	},
	//FIN - US713663 - Segmentos

	//SPV - Abrir/Cerrar TAB en la creación del caso
	handleRecSPVChange: function(component,event){
		var cerrarTabSF  = event.getParam("cerrarTab");
		var abrirTabSF  = event.getParam("abrirTab");

		if(cerrarTabSF){
			var a = component.get('c.cerrarTab');
			$A.enqueueAction(a) 
		}

		if(abrirTabSF){
			var idRecSPV  = event.getParam("idReclamacion");
			component.set('v.recordId', idRecSPV);

			var a = component.get('c.abrirTab');
			$A.enqueueAction(a) 
		}
	}
});