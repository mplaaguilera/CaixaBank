({
	doInit : function(component, event, helper) {
		component.set('v.usarComponente', true);
		component.set('v.procedencia', 'subsanacion');

		var motivos = component.get("c.listaMotivos");
		motivos.setCallback(this, function(response){
			var state = response.getState();
			if (state === "SUCCESS") {
	
				component.set('v.values', response.getReturnValue());
			}
		});
		$A.enqueueAction(motivos);

		var idCase = component.get("v.recordId");
		var propietario = component.get("c.esPropietario");
        propietario.setParams({'record': idCase});
        propietario.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {

				component.set('v.existenDatos', true);
                component.set('v.esPropietario', response.getReturnValue());
			
				var datos = component.get("c.recuperarDatosCaso");
       			datos.setParams({'record': idCase});
        		datos.setCallback(this, function(response) {
            	var state = response.getState();
            	if (state === "SUCCESS") {

					component.set('v.caso', response.getReturnValue());
					var caso = component.get('v.caso');
					if(caso.RecordType.Name == 'Pretension'){
						component.set('v.metodoEnvio', caso.SAC_Reclamacion__r.CC_Canal_Respuesta__c);
						component.set('v.recordType', 'pretension');
						if(caso.SEG_Detalle__r.SAC_AcompanyaLlamada__c){
							component.set('v.necesitaGestionLlamada', true);
						}
					}
					else if(caso.RecordType.Name == 'Reclamacion'){
						component.set('v.metodoEnvio', caso.CC_Canal_Respuesta__c);
						component.set('v.recordType', 'reclamacion');
						if(caso.CC_AcuseRecibo__c === '2'){
							component.set('v.acuseReciboEnviado', true);
						}
						if(caso.CC_Idioma__c != undefined){
							component.set('v.idiomaInformado', true);
						}
					}
					else{
						component.set('v.recordType', '');
					}

					if(caso.Status == 'SAC_001'){	

						component.set('v.alta', true);
						
					}else if(caso.Status == 'SAC_002'){

						component.set('v.analisis', true);

					}else{

						component.set('v.alta', false);
						component.set('v.analisis', false);
					}

					var llamadaPara = component.get("c.obtenerPara");
					llamadaPara.setParams({'caso': caso, 'recTypeName': caso.RecordType.Name});
					llamadaPara.setCallback(this, function(response) {
						var state = response.getState();
						if (state === "SUCCESS") {						
							component.set('v.para', response.getReturnValue());
						}
					});
					$A.enqueueAction(llamadaPara);
					
					/*
					var plantillaSubsanacion = component.get('c.getPlantillaSubsanacion');
					plantillaSubsanacion.setParams({'record': idCase});
					plantillaSubsanacion.setCallback(this, function(response) {
						var state = response.getState();
						if (state === "SUCCESS") {
							var wrapper = response.getReturnValue();
							component.set('v.idTemplateCliente', wrapper.idTemplate);
							component.set('v.para', wrapper.paraTemplate);
							component.set('v.asunto', wrapper.subjectTemplate);
							component.set('v.cuerpo', wrapper.htmlValueTemplate);
						}
						else{
							var errors = response.getError();
							let toastParams = {
								title: "Error",
								message: errors[0].pageErrors[0].message, 
								type: "error"
							};
							let toastEvent = $A.get("e.force:showToast");
							toastEvent.setParams(toastParams);
							toastEvent.fire();
						}
					})
					$A.enqueueAction(plantillaSubsanacion);
					*/
					
				}
			});
			$A.enqueueAction(datos);
			
			}
		});
		$A.enqueueAction(propietario);
                                    

	},

	openModalSubsanacion : function(component, event, helper){

		component.set('v.isModalOpenSubsanacion', true);
		helper.setFicherosBorrados(component, event);
	},

	closeModalSubsanacion : function(component, event, helper){

		component.set('v.isModalOpenSubsanacion', false);
	},

	clickReclamacion : function(component, event, helper){

		var idCase = component.get("v.recordId");
		let tieneCanalRespuesta = component.get("v.metodoEnvio");
		if(tieneCanalRespuesta == 'Email' || tieneCanalRespuesta == 'SAC_CartaPostal'){
			var tienePretensiones = component.get("c.tienePretensiones");
			tienePretensiones.setParams({'record': idCase});
			tienePretensiones.setCallback(this, function(response){
				var state = response.getState();
				if (state === "SUCCESS") {
	
					if (response.getReturnValue() === true){
						helper.setFicherosBorrados(component, event);
						component.set('v.isModalOpenSubsanacion', true);
	
					}else{
	
						var toastEvent = $A.get("e.force:showToast");
						toastEvent.setParams({
							"title": 'No tiene pretension',
							"message": 'No se puede cambiar de estado si no hay pretensiones activas',
							"type":'error'
						});
						toastEvent.fire();
					
						$A.get('e.force:refreshView').fire();
					}
	
				}
			});
			$A.enqueueAction(tienePretensiones);
		}
		else{
			var mensaje = $A.get("e.force:showToast");
			mensaje.setParams({
				"title": 'No tiene un canal de respuesta asignado.',
				"message": 'Rellene el canal de respuesta para poder efectuar la subsanación.',
				"type":'error'
			});
			mensaje.fire();
			$A.get('e.force:refreshView').fire();
		}
		

	},

	setSubsanacion : function(component, event, helper){

		let canalRespuesta = component.get("v.metodoEnvio");
		let idCase = component.get('v.recordId');
		let motivo = component.get("v.motivoSeleccionado");
		let estado = 'SAC_006';

		if(motivo != ''){

			if(canalRespuesta == 'Email'){

				let para = component.get('v.para');
				let copia = component.get('v.copia');
				// let cuerpo = component.get('v.cuerpo');
				let asunto = component.get('v.asunto');
				let ficherosAdjuntos = component.get('v.ficherosAdjuntos');
				let idsFicherosAdjuntos = [];
		
				//Controlar que el campo 'para' no esté vacío
				if (para == null || para == '') {
					let toastParams = {
					title: "Precaución",
					message: "Recuerde completar la dirección de correo", 
					type: "warning"
					};
					let toastEvent = $A.get("e.force:showToast");
					toastEvent.setParams(toastParams);
					toastEvent.fire();
				} else {
		
					component.set('v.isLoading', true);				

					//US723742 - Raúl Santos - 05/03/2024 - Añadir lógica envio emails blackList. Comprueba si los emails son correctos. Si son correctos continua el proceso, sino muestra mensaje informativo
					var actionComprobarEmails = component.get("c.comprobarEmailsEnvio");
					actionComprobarEmails.setParams({'para': para, 'copia': copia, 'copiaOculta': component.get('v.copiaOculta')});
					actionComprobarEmails.setCallback(this, function(response) {
						var state = response.getState();
            			if (state === "SUCCESS") {
							let emailsNoValidos = response.getReturnValue();

							if(emailsNoValidos === ''){								
								for(let i = 0; i < ficherosAdjuntos.length; i++){
									idsFicherosAdjuntos.push(ficherosAdjuntos[i].Id);
								}
								idsFicherosAdjuntos = component.get('v.idsFicherosAdjuntos');

								helper.cargarTagsImgCuerpo(component);

								if(component.get('v.todasImgConTag')){

									component.set('v.isModalOpenSubsanacion', false);

									var subsanar = component.get("c.subsanarCaso");
									subsanar.setParams({'record': idCase, 'motivo': motivo, 'newStatus': estado, 'para':para, 'copia':copia, 'copiaOculta': component.get('v.copiaOculta'),'cuerpo': component.get('v.cuerpo'), 'asunto':asunto, 'ficherosAdjuntos': JSON.stringify(idsFicherosAdjuntos)});
									subsanar.setCallback(this, function(response) {
										component.set('v.isLoading', false);
										var state = response.getState();
										if (state === "SUCCESS") {
											component.set('v.alta', false);
											component.set('v.analisis', false);
							
											var toastEvent = $A.get("e.force:showToast");
											toastEvent.setParams({
												"title": "Estado actualizado",
												"message": 'Se ha actualizado el estado de la reclamación.',
												"type": "success"
											});
											toastEvent.fire();
											
											$A.get('e.force:refreshView').fire();
											
										}else if(state === "ERROR"){ 
											var errors = response.getError();
											if(errors){
												if(errors[0] && errors[0].message){
													const toastEvent = $A.get("e.force:showToast");
													let toastParams = {
														title: "Error",
														message: errors[0].message, 
														type: "error"
													};
													toastEvent.setParams(toastParams);
													toastEvent.fire();
												}
											}										
										}						
									});
							
									$A.enqueueAction(subsanar);
								}else{
									component.set('v.todasImgConTag', true);
									component.set('v.isLoading', false);

									let toastParams = {
										title: "Advertencia!",
										message: 'Todas las imágenes enviadas deben tener una descripción informada. Revíselas con el botón "Modificar descripción imágenes"',  
										type: "warning"
									};
									let toastEvent = $A.get("e.force:showToast");
									toastEvent.setParams(toastParams);
									toastEvent.fire();
								}
							}else{
								//Alguna de las direcciones de email no son validas (alguna está activa en la blackList) luego notificamos esto al usuario
								component.set('v.isLoading', false);
								let toastParams = {
									title: "Error",
									message: "No está permitido el envío de emails a esta dirección: " + emailsNoValidos + " de correo electrónico, por favor elimínela para proceder al envío",
									type: "error"
								};
								let toastEvent = $A.get("e.force:showToast");
								toastEvent.setParams(toastParams);
								toastEvent.fire();
							}
						}else{
							component.set('v.isLoading', false);
							var errors = response.getError();
							let toastParams = {
								title: "Error",
								message: errors[0].message,
								type: "error"
							};
							let toastEvent = $A.get("e.force:showToast");
							toastEvent.setParams(toastParams);
							toastEvent.fire();
						}
					})

					$A.enqueueAction(actionComprobarEmails);
				}
			}
			else if(canalRespuesta == 'SAC_CartaPostal'){
				component.set('v.isLoading', true);
				component.set('v.isModalOpenSubsanacion', false);
				var subsanarCarta = component.get("c.subsanarCasoCartaPostal");
				subsanarCarta.setParams({'record': idCase, 'motivo': motivo, 'newStatus': estado});
				subsanarCarta.setCallback(this, function(response) {
					component.set('v.isLoading', false);
					var state = response.getState();
					if (state === "SUCCESS") {
						component.set('v.alta', false);
						component.set('v.analisis', false);

						var toastEvent = $A.get("e.force:showToast");
						toastEvent.setParams({
							"title": "Estado actualizado",
							"message": 'Se ha actualizado el estado de la reclamación y se ha generado la tarea.',
							"type": "success"
						});
						toastEvent.fire();
						
						$A.get('e.force:refreshView').fire();

						let navService = component.find("navService");
						var pageReference = {
							type: 'standard__recordPage',
							attributes: {
								objectApiName: 'SAC_Accion__c',
								actionName: 'view',
								recordId: response.getReturnValue()
							}
						};
						navService.navigate(pageReference);
						
					}else if(state === "ERROR"){
						var error = response.getError();

						if(error[0].message != null){
							let toastParams = {
								title: "Error",
								message: error[0].message, 
								type: "error"
							};

							let toastEvent = $A.get("e.force:showToast");
							toastEvent.setParams(toastParams);
							toastEvent.fire();
						}else if(error[0].pageErrors[0].message){
							let toastParams = {
								title: "Error",
								message: error[0].pageErrors[0].message, 
								type: "error"
							};

							let toastEvent = $A.get("e.force:showToast");
							toastEvent.setParams(toastParams);
							toastEvent.fire();
					}
					}
				});
				$A.enqueueAction(subsanarCarta);

			}

		}else{

			var toastEvent = $A.get("e.force:showToast");
				toastEvent.setParams({
					"title": 'No hay motivo',
					"message": 'Es necesario informar un motivo para poder subsanar.',
					"type": "error"
				});
			toastEvent.fire();			
		}
		
	},
	
	modifiaMotivo : function(component, event, helper){


		helper.recuperarPlantilla(component, event, helper);

	},

	/*openModalIdioma : function(component, event, helper){
		component.set('v.isModalOpenIdioma', true);
	},

	closeModalIdioma : function(component, event, helper){

		component.set('v.isModalOpenIdioma', false);
	},

	aceptarAvisoIdioma : function(component, event, helper){
		
		var idiomaValido = component.get("v.idiomaInformado");

		if(idiomaValido){

			var checkmarcado = component.get("v.checkConfirmacionValidacion");

			if (checkmarcado) {
				component.set('v.isModalOpenIdioma', false);
				$A.enqueueAction(component.get('c.clickReclamacion'));
			}else {
				var toastEventWarning = $A.get("e.force:showToast");
				toastEventWarning.setParams({
					"title": "Advertencia",
					"message": "Debe confirmar que ha validado el idioma de la reclamación",
					"type": "warning"
				});
				toastEventWarning.fire();
			}

		}else{
			var toastEventWarning = $A.get("e.force:showToast");
			toastEventWarning.setParams({
				"title": "Advertencia",
				"message": "Debe completar el idioma de la reclamación",
				"type": "warning"
			});
			toastEventWarning.fire();
		}
	}*/
})