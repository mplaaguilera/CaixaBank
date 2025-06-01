public with sharing class CC_Opportunity_BU_TRHan extends CC_TriggerHandlerBase {
	public override void mainEntry(CC_TriggerParameters tp) {
		process((List<Opportunity>)tp.newList, (Map<Id, Opportunity>)tp.newMap, (List<Opportunity>)tp.oldList, (Map<Id, Opportunity>)tp.oldMap);
	}

	private void process(List<Opportunity> listNewObj, Map<Id, Opportunity> mapNewObj, List<Opportunity> listOldObj, Map<Id, Opportunity> mapOldObj) {
		listNewObj = descartarOportunidadesNoCsbd(listNewObj);

		if(!listNewObj.isEmpty()) {
			importeObligatorioCerrarOportunidad(listNewObj, mapOldObj);
			cambioEtapaVentas(listNewObj, mapOldObj);
			actualizarPropietarioEstandar(listNewObj, mapOldObj);
			actualizarUltimaEtapaVentas(listNewObj, mapOldObj);
			actualizarFechaCierre(listNewObj, mapOldObj);
			actualizarEstado(listNewObj, mapOldObj); //Actualizar estado de la Opportunity de "Nueva" a "Activa" cuando la acepta un agente
			cambioPropietarioInicial(listNewObj, mapOldObj);
			cuentaActualizada(listNewObj, mapOldObj);
			contactoActualizado(listNewObj, mapOldObj);
			actualizarNombreOportunidad(listNewObj, mapOldObj);
			cambioPropietarioHipoteca(listNewObj, mapOldObj);
			actualizarProducto(listNewObj, mapOldObj);
			scheduleReclamacionesCliente(listNewObj, mapOldObj);
			enviarEmailIntouch(listNewObj, mapOldObj);
			noIdentificaClienteBU(listNewObj, mapOldObj);
			crearTitularHipotecas(listNewObj, mapOldObj);
			calcularTMO(listNewObj, mapOldObj);
			informarCampoPrioridad(listNewObj, mapOldObj);
			crearAccountTitularHipoteca(listNewObj, mapOldObj);
			if (FeatureManagement.checkPermission('CSBD_UsuarioPromptsIA')) {
				comprobarCumpleCondicionesIAEinstein(listNewObj, mapOldObj);
			}
		}
	}

	public static void noIdentificaClienteBU(List<Opportunity> listNewObj, Map<Id, Opportunity> mapOldObj) {
		for(Opportunity newOportunidad : listNewObj) {
			if(newOportunidad.CSBD_No_Identificado__c && ((newOportunidad.AccountId != mapOldObj.get(newOportunidad.Id).AccountId && newOportunidad.AccountId != null) || (newOportunidad.CSBD_Contact__c != mapOldObj.get(newOportunidad.Id).CSBD_Contact__c && newOportunidad.CSBD_Contact__c != null))) {
				newOportunidad.CSBD_No_Identificado__c = false;
			}
		}
	}

	private static void cambioPropietarioHipoteca(List<Opportunity> listNewObj, Map<Id, Opportunity> mapOldObj) {
		Boolean enviarNotificaciones = false;
		for (Opportunity newOportunidad : listNewObj) {
			if (Schema.SObjectType.Opportunity.getRecordTypeInfosById().get(newOportunidad.RecordTypeId).getDeveloperName() == 'CSBD_Hipoteca'
			&& mapOldObj.get(newOportunidad.Id).OwnerId != newOportunidad.OwnerId
			&& String.isNotBlank(newOportunidad.OwnerId)) {
				enviarNotificaciones = true;
				break;
			}
		}
		if (enviarNotificaciones) {
			Id idCustomNotification = [SELECT Id FROM CustomNotificationType WHERE DeveloperName = 'CC_Notificacion'].Id;
			for (Opportunity newOportunidad : listNewObj) {
				if (Schema.SObjectType.Opportunity.getRecordTypeInfosById().get(newOportunidad.RecordTypeId).getDeveloperName() == 'CSBD_Hipoteca'
				&& mapOldObj.get(newOportunidad.Id).OwnerId != newOportunidad.OwnerId
				&& String.isNotBlank(newOportunidad.OwnerId)) {
					try {
						Messaging.CustomNotification notification = new Messaging.CustomNotification();
						notification.setTitle('Asignación de hipoteca ' + newOportunidad.CSBD_Identificador__c);
						notification.setBody('Es el propietario de la oportunidad ' + newOportunidad.CSBD_Identificador__c + '.');
						notification.setNotificationTypeId(idCustomNotification);
						notification.setTargetId(newOportunidad.Id);
						notification.send(new Set<String>{newOportunidad.OwnerId});
					} catch (Exception e) {
						CBK_Log.error(e);
					}
				}
			}
		}
	}

	private static void cuentaActualizada(List<Opportunity> listNewObj, Map<Id, Opportunity> mapOldObj) {
		List<Id> idCuentas = new List<Id>();
		for (Opportunity newOportunidad : listNewObj) {
			if (mapOldObj.get(newOportunidad.Id).AccountId != newOportunidad.AccountId) {
				if (String.isBlank(newOportunidad.AccountId)) {
					//Se ha desvinculado la cuenta, se desvincula también el contacto
					newOportunidad.CSBD_Contact__c = null;
				} else {
					//Se ha vinculado una nueva cuenta a la oportunidad
					idCuentas.add(newOportunidad.AccountId);
				}
			}
		}
		if (!idCuentas.isEmpty()) {
			Map<Id, Account> cuentas = new Map<Id, Account>([SELECT PersonContactId FROM Account
																WHERE Id IN :idCuentas AND RecordType.DeveloperName = 'CC_ClientePA']);
			for (Opportunity newOportunidad : listNewObj) {
				if (mapOldObj.get(newOportunidad.Id).AccountId != newOportunidad.AccountId
				&& cuentas.containsKey(newOportunidad.AccountId)) {
					newOportunidad.CSBD_Contact__c = cuentas.get(newOportunidad.AccountId).PersonContactId;
				}
			}
		}
	}

	private static void contactoActualizado(List<Opportunity> listNewObj, Map<Id, Opportunity> mapOldObj) {
		List<Id> idContactos = new List<Id>();
		for (Opportunity newOportunidad : listNewObj) {
			if (mapOldObj.get(newOportunidad.Id).CSBD_Contact__c != newOportunidad.CSBD_Contact__c
			&& String.isNotBlank(newOportunidad.CSBD_Contact__c)
			&& (String.isBlank(newOportunidad.CSBD_Email_Solicitud__c) || String.isBlank(newOportunidad.CSBD_Telefono_Solicitud__c))) {
				//Se ha vinculado un nuevo contacto a una oportunidad que no tiene email y teléfono informados
				idContactos.add(newOportunidad.CSBD_Contact__c);
			}
		}
		if (!idContactos.isEmpty()) {
			//Se informa mail y teléfono del contacto en la oportunidad si ésta no tiene alguno de ellos informado
			Map<Id, Contact> contactos = new Map<Id, Contact>([SELECT Email, Phone, MobilePhone FROM Contact WHERE Id IN :idContactos]);
			for (Opportunity newOportunidad : listNewObj) {
				if (mapOldObj.get(newOportunidad.Id).CSBD_Contact__c != newOportunidad.CSBD_Contact__c
				&& contactos.containsKey(newOportunidad.CSBD_Contact__c)) {
					if (String.isBlank(newOportunidad.CSBD_Email_Solicitud__c)) {
						newOportunidad.CSBD_Email_Solicitud__c = contactos.get(newOportunidad.CSBD_Contact__c).Email;
					}
					if (String.isBlank(newOportunidad.CSBD_Telefono_Solicitud__c)) {
						if (String.isNotBlank(contactos.get(newOportunidad.CSBD_Contact__c).MobilePhone)) {
							newOportunidad.CSBD_Telefono_Solicitud__c = contactos.get(newOportunidad.CSBD_Contact__c).MobilePhone;
						} else {
							newOportunidad.CSBD_Telefono_Solicitud__c = contactos.get(newOportunidad.CSBD_Contact__c).Phone;
						}
					}
				}
			}
		}
	}

	private static void cambioPropietarioInicial(List<Opportunity> listNewObj, Map<Id, Opportunity> mapOldObj) {
		for (Opportunity newOportunidad : listNewObj) {
			if (mapOldObj.get(newOportunidad.Id).CSBD_Estado__c == 'Nueva'
			&& mapOldObj.get(newOportunidad.Id).OwnerId != newOportunidad.OwnerId) {
				newOportunidad.CSBD_Estado__c = 'Activa';
			}
		}
	}

	private static void cambioEtapaVentas(List<Opportunity> listNewObj, Map<Id, Opportunity> mapOldObj) {
		Boolean comprobarEtapaVentas = false;
		for (Opportunity newOportunidad : listNewObj) {
			if (mapOldObj.get(newOportunidad.Id).StageName != newOportunidad.StageName) {
				comprobarEtapaVentas = true;
				break;
			}
		}
		if (comprobarEtapaVentas) {
			List<String> nombreEtapasFinales = CC_MetodosUtiles.listaCampo([SELECT ApiName FROM OpportunityStage WHERE IsClosed = true], 'ApiName', true);
			for (Opportunity newOportunidad : listNewObj) {
				if (mapOldObj.get(newOportunidad.Id).StageName != newOportunidad.StageName
				&& nombreEtapasFinales.contains(newOportunidad.StageName)
				&& newOportunidad.CSBD_Estado__c != 'Cerrada'
				&& newOportunidad.CSBD_Estado__c != 'Rechazada') {
					newOportunidad.addError('La finalización de la gestión de la oportunidad debe realizarse mediante la operativa "Cerrar".');
				}
			}
		}
	}

	private static void actualizarPropietarioEstandar(List<Opportunity> listNewObj, Map<Id, Opportunity> mapOldObj) {
		//La Quick Action "CSBD_Cambiar_Propietario" no permite modificar el OwnerId directamente,
		//así que utilizamos este campo auxiliar y actualizamos el owner en este trigger
		for (Opportunity newOportunidad : listNewObj) {
			Opportunity oldOportunidad = mapOldObj.get(newOportunidad.Id);
			if (newOportunidad.CSBD_Propietario_Aux__c != oldOportunidad.CSBD_Propietario_Aux__c) {
				newOportunidad.OwnerId = newOportunidad.CSBD_Propietario_Aux__c;
			}
		}
	}

	private static void actualizarUltimaEtapaVentas(List<Opportunity> listNewObj, Map<Id, Opportunity> mapOldObj) {
		for (Opportunity newOportunidad : listNewObj) {
			Opportunity oldOportunidad = mapOldObj.get(newOportunidad.Id);
			if (newOportunidad.StageName != oldOportunidad.StageName) {
				newOportunidad.CSBD_Ultima_Etapa_Ventas__c = oldOportunidad.StageName;
			}
		}
	}

	private static void actualizarNombreOportunidad(List<Opportunity> listNewObj, Map<Id, Opportunity> mapOldObj) {
		List<Opportunity> oportunidadesActualizar =  new List<Opportunity>();
		for (Opportunity newOportunidad : listNewObj) {
			Opportunity oldOportunidad = mapOldObj.get(newOportunidad.Id);
			if (newOportunidad.Name != oldOportunidad.Name) {
				oportunidadesActualizar.add(newOportunidad);
			}
		}
		if(!oportunidadesActualizar.isEmpty()) {
			CSBD_Opportunity.actualizarNombreOportunidades(oportunidadesActualizar);
		}
	}

	private static void actualizarFechaCierre(List<Opportunity> listNewObj, Map<Id, Opportunity> mapOldObj) {
		List<Opportunity> oportunidadesActualizar =  new List<Opportunity>();
		for (Opportunity newOportunidad : listNewObj) {
			Opportunity oldOportunidad = mapOldObj.get(newOportunidad.Id);
			if (newOportunidad.CloseDate != oldOportunidad.CloseDate) {
				newOportunidad.AV_FechaModificacion__c = newOportunidad.CloseDate;
				newOportunidad.CSBD_Closed_date_time__c = Datetime.now();
			}
		}
	}

	//Actualizar estado de la Opportunity de "Nueva" a "Activa" cuando la acepta un agente
	private static void actualizarEstado(List<Opportunity> listNewObj, Map<Id, Opportunity> mapOldObj) {
		Set<Id> ownerIdsToUpdate = new Set<Id>();
		Map<Id, String> ownerDepartments = new Map<Id, String>();

		// Recopila los OwnerIds que necesitan actualización
		for (Opportunity oportunidad : listNewObj) {
			Opportunity oldOportunidad = mapOldObj.get(oportunidad.Id);
			if (oportunidad.OwnerId != oldOportunidad.OwnerId) {
				ownerIdsToUpdate.add(oportunidad.OwnerId);
			}
		}

		// Consulta los User correspondientes a los OwnerIds solo si es necesario
		if (!ownerIdsToUpdate.isEmpty()) {
			for (User owner : [SELECT Id, Department FROM User WHERE Id IN :ownerIdsToUpdate and Department != null]) {
				ownerDepartments.put(owner.Id, owner.Department);
			}
		}

		for (Opportunity updOportunidad : listNewObj) {
			Opportunity oldOportunidad = mapOldObj.get(updOportunidad.Id);
			if (updOportunidad.OwnerId != oldOportunidad.OwnerId) {
				if (ownerDepartments.containsKey(updOportunidad.OwnerId)) {
					updOportunidad.CSBD_Equipo__c = ownerDepartments.get(updOportunidad.OwnerId);
				}else{
					updOportunidad.CSBD_Equipo__c = '';
				}
				if (updOportunidad.CSBD_Estado__c == 'Nueva') {
					updOportunidad.CSBD_Estado__c = 'Activa';
				}
			}
		}
	}


	private static void actualizarProducto(List<Opportunity> listNewObj, Map<Id, Opportunity> mapOldObj) {
		Set<String> productosCSBD = new Set<String>();
		List<Opportunity> actualizarOportunidades = new List<Opportunity>();
		for (Opportunity updOportunidad : listNewObj) {
			Opportunity oldOportunidad = mapOldObj.get(updOportunidad.Id);
			if (updOportunidad.CSBD_Producto__c != oldOportunidad.CSBD_Producto__c && !String.isBlank(updOportunidad.CSBD_Producto__c)) {
				productosCSBD.add(updOportunidad.CSBD_Producto__c);
				actualizarOportunidades.add(updOportunidad);
			}
		}
		//Se establece la relación entre el valor guardado en CSBD_Producto__c y Product2 para guardarlo en AV_PF__c
		if(!productosCSBD.isEmpty()){
			List<CC_Lista_Valores__c> valoresProducto = [SELECT CC_Valor2__c, CSBD_Product2__c FROM CC_Lista_Valores__c WHERE CSBD_Product2__c != null AND RecordType.DeveloperName = 'CC_Valor'
										AND CC_Lista__r.Name = 'CSBD: Relación de valores Now - Salesforce: Empresa, familia y producto'
										AND CC_Valor2__c IN :productosCSBD AND CC_Activa__c = TRUE];

			if(!valoresProducto.isEmpty()){
				Map<String, String> product2Valor2 = new Map<String, String>();
				for(CC_Lista_Valores__c valor : valoresProducto){
					product2Valor2.put(valor.CC_Valor2__c,valor.CSBD_Product2__c);
				}
				for(Opportunity opportunity : actualizarOportunidades){
					if(product2Valor2.containsKey(opportunity.CSBD_Producto__c)){
						opportunity.AV_PF__c = product2Valor2.get(opportunity.CSBD_Producto__c);
					}
				}
			}
		}
	}

	//Cambio de PB a FW - Ejecución reclamaciones cliente: Inserto registros en CBK_SCH_PendingProcess__c para programar acciones
	private static void scheduleReclamacionesCliente(List<Opportunity> listNewObj, Map<Id, Opportunity> mapOldObj){

		List<CBK_SCH_PendingProcess__c> pendingProcessInsertList = new List<CBK_SCH_PendingProcess__c>();

		for (Opportunity oportunidad: listNewObj){
			Opportunity oldOportunidad = mapOldObj.get(oportunidad.Id);
			if(oldOportunidad.CSBD_Estado__c != oportunidad.CSBD_Estado__c && oportunidad.CSBD_Estado__c == 'Pendiente Cliente'
				&& oportunidad.CSBD_Email_Solicitud__c != null && oportunidad.CSBD_Contact__c != null){
					//1ª reclamación - 3 días
					CBK_SCH_PendingProcess__c pendingProcessReclamacion1 = new CBK_SCH_PendingProcess__c();
					pendingProcessReclamacion1.RecordId__c = oportunidad.Id;
					pendingProcessReclamacion1.Param1__c = '1'; //numeroReclamacion
					pendingProcessReclamacion1.Schedule_Time__c = system.now().addDays(3);
					pendingProcessReclamacion1.ClassName__c = 'CBK_SCH_CSBD_ScheduleReclamaCliente';
					pendingProcessInsertList.add(pendingProcessReclamacion1);

					//2ª reclamación - 6 días
					CBK_SCH_PendingProcess__c pendingProcessReclamacion2 = new CBK_SCH_PendingProcess__c();
					pendingProcessReclamacion2.RecordId__c = oportunidad.Id;
					pendingProcessReclamacion2.Param1__c = '2'; //numeroReclamacion
					pendingProcessReclamacion2.Schedule_Time__c = system.now().addDays(6);
					pendingProcessReclamacion2.ClassName__c = 'CBK_SCH_CSBD_ScheduleReclamaCliente';
					pendingProcessInsertList.add(pendingProcessReclamacion2);

					//3ª reclamación - 9 días
					CBK_SCH_PendingProcess__c pendingProcessReclamacion3 = new CBK_SCH_PendingProcess__c();
					pendingProcessReclamacion3.RecordId__c = oportunidad.Id;
					pendingProcessReclamacion3.Param1__c = '3'; //numeroReclamacion
					pendingProcessReclamacion3.Schedule_Time__c = system.now().addDays(9);
					pendingProcessReclamacion3.ClassName__c = 'CBK_SCH_CSBD_ScheduleReclamaCliente';
					pendingProcessInsertList.add(pendingProcessReclamacion3);
			}
		}
		Insert pendingProcessInsertList;
	}

	//Importe > 0 obligatorio al formalizar oportunidad
	private static void importeObligatorioCerrarOportunidad(List<Opportunity> listNewObj, Map<Id, Opportunity> mapOldObj){

		Set<String> tiposOportunidadValidar = new Set<String>();
		List<Opportunity> oportunidadesValidar = new List<Opportunity>();

		for (Opportunity oportunidad: listNewObj){
			Opportunity oldOportunidad = mapOldObj.get(oportunidad.Id);
			if(oportunidad.StageName == 'Formalizada' && oportunidad.StageName != oldOportunidad.StageName && (oportunidad.Amount == 0 || oportunidad.Amount == null)){
				String recordtypeName = Schema.SObjectType.Opportunity.getRecordTypeInfosById().get(oportunidad.RecordtypeId).getName();
				tiposOportunidadValidar.add(recordtypeName);
				oportunidadesValidar.add(oportunidad);
			}
		}
		if(!oportunidadesValidar.isEmpty()) {
			Set<String> tiposOportunidadActivos = new Set<String>();

			//Solo se impedirá la formalización de las oportunidades cuyo recordtype.name esté dato de alta en los names de los registros de está lista de valores
			for(CC_Lista_Valores__c valorListaObligatorio: [SELECT Name FROM CC_Lista_Valores__c WHERE CC_Lista__r.Name = 'CSBD: Oportunidades importe obligatorio formalizar'
																									AND Name = :tiposOportunidadValidar AND CC_Activa__c = true]) {
				tiposOportunidadActivos.add(valorListaObligatorio.Name);
			}

			if(!tiposOportunidadActivos.isEmpty()) {
				for (Opportunity oportunidadValidar: oportunidadesValidar) {
					String recordtypeName = Schema.SObjectType.Opportunity.getRecordTypeInfosById().get(oportunidadValidar.RecordtypeId).getName();
					if(tiposOportunidadActivos.contains(recordtypeName)) {
						oportunidadValidar.addError('No se puede formalizar una oportunidad con importe 0€');
					}
				}
			}
		}
	}

	private static void enviarEmailIntouch(List<Opportunity> listNewObj, Map<Id, Opportunity> mapOldObj){
		Map<Id, String> mapIdReferencia = new Map<Id, String>();
		Map<Id, String> mapIdPlantilla = new Map<Id, String>();
		Set<Id> createdByIdSet = new Set<Id>();

		for(Opportunity oportunidad : listNewObj){
			if(oportunidad.CSBD_Empresa_Proveedora__c == 'inTouch' && oportunidad.CSBD_Estado__c == 'Cerrada' && oportunidad.StageName == 'Formalizada' && oportunidad.CSBD_Estado__c != mapOldObj.get(oportunidad.Id).CSBD_Estado__c){
				String referencia = CSBD_Opportunity.obtenerReferenciaCorreo(oportunidad.Id);
				oportunidad.CSBD_Referencia_Correo_Saliente__c = referencia;
				String masterLabel = 'Cierre InTouch Formalizada CAS';

				mapIdReferencia.put(oportunidad.Id, referencia);
				mapIdPlantilla.put(oportunidad.Id, masterLabel);
				createdByIdSet.add(oportunidad.CreatedById);
			}
			if(oportunidad.CSBD_Empresa_Proveedora__c == 'inTouch' && oportunidad.CSBD_Estado__c == 'Cerrada' && oportunidad.StageName == 'Perdida' && oportunidad.CSBD_Estado__c != mapOldObj.get(oportunidad.Id).CSBD_Estado__c){
				String referencia = CSBD_Opportunity.obtenerReferenciaCorreo(oportunidad.Id);
				oportunidad.CSBD_Referencia_Correo_Saliente__c = referencia;
				String masterLabel = 'Cierre InTouch Perdida CAS';

				mapIdReferencia.put(oportunidad.Id, referencia);
				mapIdPlantilla.put(oportunidad.Id, masterLabel);
				createdByIdSet.add(oportunidad.CreatedById);
			}
		}
		if(!mapIdReferencia.isEmpty() && !mapIdPlantilla.isEmpty()) {
			CSBD_Opportunity.enviarEmailIntouch(mapIdReferencia, mapIdPlantilla, createdByIdSet);
		}
	}

	private static void crearTitularHipotecas(List<Opportunity> listNewObj, Map<Id, Opportunity> mapOldObj) {
		//Cuando informamos cliente comprobamos si la hipoteca tiene titular, si no lo tiene lo creamos automáticamente
		List<Opportunity> oportunidadesCrearTitular = new List<Opportunity>();
		Set<Id> idsCliente = new Set<Id>();
		for (Opportunity newOpportunity : listNewObj) {
			if(newOpportunity.RecordtypeId == Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('CSBD_Hipoteca').getRecordTypeId() && newOpportunity.CSBD_ContactoTitular1__c == null) {
				if (newOpportunity.AccountId != mapOldObj.get(newOpportunity.Id).AccountId && newOpportunity.AccountId != null ) {
					oportunidadesCrearTitular.add(newOpportunity);
					idsCliente.add(newOpportunity.AccountId);
				}
			}
		}

		CSBD_Opportunity.crearTitularHipotecas(oportunidadesCrearTitular, idsCliente);
	}

	private static void crearAccountTitularHipoteca(List<Opportunity> listNewObj, Map<Id, Opportunity> mapOldObj) {
		List<Opportunity> oportunidadesCrearAccount = new List<Opportunity>();
		List<Contact> contactosAActualizar = new List<Contact>();
		List<Account> cuentasTitularInsert = new List<Account>();
		Set<Id> contactoTitularIds = new Set<Id>();
		Id recordTypeIdHipoteca = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('CSBD_Hipoteca').getRecordTypeId();
		Id recordTypeIdAccount = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('CSBD_TitularHipoteca').getRecordTypeId();

		for (Opportunity newOpportunity : listNewObj) {
			if (newOpportunity.RecordtypeId == recordTypeIdHipoteca &&
			((newOpportunity.CSBD_ContactoTitular1__c != null && mapOldObj.get(newOpportunity.Id).CSBD_ContactoTitular1__c == null) ||
			(newOpportunity.CSBD_ContactoTitular2__c != null && mapOldObj.get(newOpportunity.Id).CSBD_ContactoTitular2__c == null))) {
				if (newOpportunity.CSBD_ContactoTitular1__c != null) {
					contactoTitularIds.add(newOpportunity.CSBD_ContactoTitular1__c);
				}
				if (newOpportunity.CSBD_ContactoTitular2__c != null) {
					contactoTitularIds.add(newOpportunity.CSBD_ContactoTitular2__c);
				}
				oportunidadesCrearAccount.add(newOpportunity);
			}
		}

		Map<Id, Contact> mapContactoTitular = new Map<Id, Contact>([SELECT AccountId FROM Contact WHERE Id IN :contactoTitularIds]);
		Map <Id, Account> mapContactoCuenta = new Map<Id, Account>();

		for (Opportunity newOpportunity : oportunidadesCrearAccount) {
			Contact contactoTitular1 = mapContactoTitular.get(newOpportunity.CSBD_ContactoTitular1__c);
			Contact contactoTitular2 = mapContactoTitular.get(newOpportunity.CSBD_ContactoTitular2__c);

			if (contactoTitular1?.AccountId == null && contactoTitular2?.AccountId == null) {
				Account cuentaTitulares = new Account(RecordTypeId = recordTypeIdAccount, Name = 'Cuenta titulares petición ' + newOpportunity.CSBD_Identificador__c);
				cuentasTitularInsert.add(cuentaTitulares);
				if (contactoTitular1 != null) {
					contactosAActualizar.add(contactoTitular1);
					mapContactoCuenta.put(contactoTitular1.Id, cuentaTitulares);
				}
				if (contactoTitular2 != null) {
					contactosAActualizar.add(contactoTitular2);
					mapContactoCuenta.put(contactoTitular2.Id, cuentaTitulares);
				}
			} else if (contactoTitular1?.AccountId == null && contactoTitular2?.AccountId != null && contactoTitular1 != null) {
				contactoTitular1.AccountId = contactoTitular2.AccountId;
				contactosAActualizar.add(contactoTitular1);
			} else if (contactoTitular1?.AccountId != null && contactoTitular2?.AccountId == null && contactoTitular2 != null) {
				contactoTitular2.AccountId = contactoTitular1.AccountId;
				contactosAActualizar.add(contactoTitular2);
			}
		}

		if (!cuentasTitularInsert.isEmpty()) insert cuentasTitularInsert;

		for (Contact contacto : contactosAActualizar) {
			if (contacto.AccountId == null) {
				Account cuentaTitular = mapContactoCuenta.get(contacto.Id);
				if (cuentaTitular != null) {
					contacto.AccountId = cuentaTitular.Id;
				}
			}
		}

		if (!contactosAActualizar.isEmpty()) update contactosAActualizar;
	}

	private static List<Opportunity> descartarOportunidadesNoCsbd(List<Opportunity> oportunidades) {
		List<Opportunity> oportunidadesCsbd = new List<Opportunity>();
		Map<Id, Schema.RecordTypeInfo> recordTypeInfos = Schema.SObjectType.Opportunity.getRecordTypeInfosById();
		for (Opportunity oportunidad : oportunidades) {
			if (recordTypeInfos.get(oportunidad.RecordTypeId).getDeveloperName().startsWith('CSBD_')) {
				oportunidadesCsbd.add(oportunidad);
			}
		}
		return oportunidadesCsbd;
	}

	private static void calcularTMO(List<Opportunity> listNewObj, Map<Id, Opportunity> mapOldObj) {
		Map<Id, Opportunity> idOportunidad = new Map<Id, Opportunity>();
		for (Opportunity oportunidad: listNewObj) {
			if(!mapOldObj.get(oportunidad.Id).isClosed && oportunidad.isClosed && (oportunidad.CSBD_SLA_TMO__c == null || oportunidad.CSBD_SLA_TMO__c == 0) && oportunidad.CSBD_PrimerContactoSLA__c != null) {
				oportunidad.CSBD_SLA_TMO__c = 0;
				oportunidad.CSBD_SLA_TMO__c = (Integer)((System.now().getTime() - oportunidad.CSBD_PrimerContactoSLA__c.getTime()) / (1000));
			}
		}
	}

	public static void informarCampoPrioridad(List<Opportunity> listNewObj, Map<Id, Opportunity> mapOldObj) {
		Id idRecordTypeHipoteca = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('CSBD_Hipoteca').getRecordTypeId();

		List<Opportunity> oportunidades = new List<Opportunity>();
		for (Opportunity newOportunidad : listNewObj) {
			Opportunity oldOportunidad = mapOldObj.get(newOportunidad.Id);
			if (newOportunidad.RecordTypeId == idRecordTypeHipoteca
				&& (newOportunidad.CSBD_Tasacion__c != oldOportunidad.CSBD_Tasacion__c
				|| newOportunidad.CSBD_Urgencia__c != oldOportunidad.CSBD_Urgencia__c
				|| newOportunidad.CSBD_UsoVivienda2__c != oldOportunidad.CSBD_UsoVivienda2__c
				|| newOportunidad.Amount != oldOportunidad.Amount
				|| newOportunidad.CSBD_ContactoTitular1__c != oldOportunidad.CSBD_ContactoTitular1__c
				|| newOportunidad.CSBD_AportacionInicial__c != oldOportunidad.CSBD_AportacionInicial__c
				|| newOportunidad.CSBD_TipoOperacion2__c != oldOportunidad.CSBD_TipoOperacion2__c
				|| newOportunidad.CSBD_Datos_Calculo_DTI__c != oldOportunidad.CSBD_Datos_Calculo_DTI__c)) {

				oportunidades.add(newOportunidad);
			}
		}

		if(!oportunidades.isEmpty()){
			CSBD_Hipoteca.informarCampoPrioridad(oportunidades, null);
		}
	}

	public static void comprobarCumpleCondicionesIAEinstein(List<Opportunity> listNewObj, Map<Id, Opportunity> mapOldObj) {
		List<Opportunity> oportunidades = new List<Opportunity>();
		for (Opportunity newOportunidad : listNewObj) {
			Opportunity oldOportunidad = mapOldObj.get(newOportunidad.Id);
			if (newOportunidad.CSBD_Producto__c != oldOportunidad.CSBD_Producto__c) {
				oportunidades.add(newOportunidad);
			}
		}

		if (!oportunidades.isEmpty()) {
			CSBD_EinsteinUtils.marcarCheckPromptSiCumple(oportunidades);
		}
	}
}