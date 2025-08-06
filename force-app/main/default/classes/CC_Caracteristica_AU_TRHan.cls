public with sharing class CC_Caracteristica_AU_TRHan extends CC_TriggerHandlerBase {

	public override void mainEntry(CC_TriggerParameters tp) {
		  process((List<CC_Caracteristica__c>)tp.newList, (Map<Id, CC_Caracteristica__c>)tp.newMap, (Map<Id, CC_Caracteristica__c>)tp.oldMap);
	}

	private void process(List<CC_Caracteristica__c> listNewObj, Map<Id, CC_Caracteristica__c> mapNewObj, Map<Id, CC_Caracteristica__c> mapOldObj) {
        notificarCaracteristicaDesuso(listNewObj, mapNewObj);
		updateContactOrAccountOldRelated(mapNewObj, mapOldObj);
	}

	private void notificarCaracteristicaDesuso(List<CC_Caracteristica__c> listNewObj, Map<Id, CC_Caracteristica__c> mapNewObj) {
		Integer diasUltimaAsociacion = 180;
		Set<String> destinatarios = new Set<String>();
		Id grupoCoordinadores = [SELECT Id FROM Group WHERE DeveloperName = 'Coordinadores' LIMIT 1].Id;
		destinatarios.add(grupoCoordinadores.toString());
		String tipoNoficicacion = [SELECT Id from CustomNotificationType WHERE DeveloperName = 'CC_Marca_Desuso' LIMIT 1].Id;
		String tituloNotificacion = 'Marca en desuso';
		for (CC_Caracteristica__c caracteristica : listNewObj) {
			if (caracteristica.CC_Dias_ultima_asociacion__c > diasUltimaAsociacion && caracteristica.CC_Activo__c == true) {
				String textoNotificacion = 'La marca ' + caracteristica.Name + ' está en desuso.';
				Boolean haFallado = CC_Notificacion_Metodos.enviarNotificacion (destinatarios, caracteristica.Id, tituloNotificacion, tipoNoficicacion, textoNotificacion);
				if (!haFallado) {
					system.debug('Notificación enviada correctamente');
				}else{
					system.debug('Error al enviar la notificación');
				}
			}
		}
	}

	private void updateContactOrAccountOldRelated(Map<Id, CC_Caracteristica__c> mapNewObj, Map<Id, CC_Caracteristica__c> mapOldObj){
		Map<Id,Contact> mapContactsToUpdateById = new Map<Id,Contact>();
        Map<Id,Account> mapAccountsToUpdateById = new Map<Id,Account>();
		Set<Id> caracteristicasInactivadas = new Set<Id>();
		Set<Id> caracteristicasActivadas = new Set<Id>();
		Set<Id> contactosParaInactivar = new Set<Id>();
		Set<Id> cuentasParaInactivar = new Set<Id>();
		//Recorremos las Caracteristicas y revisamos si han pasado a inactivas y las guardamos en el set y lo mismo con las Activas
		for(CC_Caracteristica__c caracteristica : mapNewObj.values()) {
			if (mapOldObj.containsKey(caracteristica.Id)) {
				CC_Caracteristica__c oldCaracteristica = mapOldObj.get(caracteristica.Id);
				if (caracteristica.CC_Activo__c == false && oldCaracteristica.CC_Activo__c == true) {
					caracteristicasInactivadas.add(caracteristica.Id);
				}
				if (caracteristica.CC_Activo__c == true && oldCaracteristica.CC_Activo__c == false) {
					caracteristicasActivadas.add(caracteristica.Id);
				}
			}
		}
		if(!caracteristicasInactivadas.isEmpty() || !caracteristicasActivadas.isEmpty()) {
			//Extraigo los detalles junto con los campos CC_Tiene_Caracteristica_Detalle__c de contact y account relacionados, de las caracteristicas que han cambiado de status
			List<CC_Caracteristica_Detalle__c> lstCaracteristicaDetalle = [SELECT Id, CC_Caracteristica__c, 
																			CC_Cliente__c, CC_Cliente__r.CC_Tiene_Caracteristica_Detalle__c, 
																			CC_Empleado__c, CC_Empleado__r.CC_Tiene_Caracteristica_Detalle__c,
																			CC_Cuenta__c, CC_Cuenta__r.CC_Tiene_Caracteristica_Detalle__c,
																			CC_Centro_CaixaBank__c , CC_Centro_CaixaBank__r.CC_Tiene_Caracteristica_Detalle__c
																		FROM CC_Caracteristica_Detalle__c 
																		WHERE (CC_Caracteristica__c IN :caracteristicasInactivadas OR CC_Caracteristica__c IN :caracteristicasActivadas)
																		AND CC_Caracteristica__r.OS_Negocio__c = 'CC'];
			// Recorro los detalles y actualizo los contactos y cuentas que no tengan ya el valor a true y cuya caracteristica este activa
			// y me guardo las cuentas y contactos de los detalles cuya caracteristica este inactiva para despues
			for(CC_Caracteristica_Detalle__c detalle : lstCaracteristicaDetalle) {
				if(detalle.CC_Caracteristica__c != null && caracteristicasActivadas.contains(detalle.CC_Caracteristica__c)) {
					//Control de que las nuevas cuentas o contactos tengan el campo CC_Tiene_Caracteristica_Detalle__c a true, sino los actualizo
					if (detalle.CC_Cliente__c != null && !detalle.CC_Cliente__r.CC_Tiene_Caracteristica_Detalle__c) {
						Contact c = new Contact(Id = detalle.CC_Cliente__c);
						c.CC_Tiene_Caracteristica_Detalle__c = true;
						mapContactsToUpdateById.put(detalle.CC_Cliente__c,c);
					}
					if (detalle.CC_Empleado__c != null && !detalle.CC_Empleado__r.CC_Tiene_Caracteristica_Detalle__c) {
						Contact c = new Contact(Id = detalle.CC_Empleado__c);
						c.CC_Tiene_Caracteristica_Detalle__c = true;
						mapContactsToUpdateById.put(detalle.CC_Empleado__c,c);
					}
					if (detalle.CC_Cuenta__c != null && !detalle.CC_Cuenta__r.CC_Tiene_Caracteristica_Detalle__c) {
						Account a = new Account(Id = detalle.CC_Cuenta__c);
						a.CC_Tiene_Caracteristica_Detalle__c = true;
						mapAccountsToUpdateById.put(detalle.CC_Cuenta__c,a);
					}
					if (detalle.CC_Centro_CaixaBank__c != null && !detalle.CC_Centro_CaixaBank__r.CC_Tiene_Caracteristica_Detalle__c) {
						Account a = new Account(Id = detalle.CC_Centro_CaixaBank__c);
						a.CC_Tiene_Caracteristica_Detalle__c = true;
						mapAccountsToUpdateById.put(detalle.CC_Centro_CaixaBank__c,a);
					}
				} else if(detalle.CC_Caracteristica__c != null && caracteristicasInactivadas.contains(detalle.CC_Caracteristica__c)) {
					if(detalle.CC_Cliente__c != null && detalle.CC_Cliente__r.CC_Tiene_Caracteristica_Detalle__c){
						contactosParaInactivar.add(detalle.CC_Cliente__c);
					}
					if(detalle.CC_Empleado__c != null && detalle.CC_Empleado__r.CC_Tiene_Caracteristica_Detalle__c){
						contactosParaInactivar.add(detalle.CC_Empleado__c);
					}
					if(detalle.CC_Cuenta__c != null && detalle.CC_Cuenta__r.CC_Tiene_Caracteristica_Detalle__c){
						cuentasParaInactivar.add(detalle.CC_Cuenta__c);
					}
					if(detalle.CC_Centro_CaixaBank__c != null && detalle.CC_Centro_CaixaBank__r.CC_Tiene_Caracteristica_Detalle__c){
						cuentasParaInactivar.add(detalle.CC_Centro_CaixaBank__c);
					}
				}
			}
			// Reviso si hay contactos o cuentas para inactivar para revisar si han de desactivarse o no
			if(!contactosParaInactivar.isEmpty() || !cuentasParaInactivar.isEmpty()){
				//Reviso si existen detalles que tengan caracteristicas activas para los contactos y cuentas que se han de inactivar
				List<CC_Caracteristica_Detalle__c> lstCaracteristicaDetalle2 = [SELECT Id, CC_Caracteristica__c, CC_Caracteristica__r.CC_Activo__c,
																				CC_Cliente__c, CC_Cliente__r.CC_Tiene_Caracteristica_Detalle__c, 
																				CC_Empleado__c, CC_Empleado__r.CC_Tiene_Caracteristica_Detalle__c,
																				CC_Cuenta__c, CC_Cuenta__r.CC_Tiene_Caracteristica_Detalle__c,
																				CC_Centro_CaixaBank__c , CC_Centro_CaixaBank__r.CC_Tiene_Caracteristica_Detalle__c
																			FROM CC_Caracteristica_Detalle__c 
																			WHERE (CC_Cliente__c IN :contactosParaInactivar OR CC_Empleado__c IN :contactosParaInactivar OR 
																					CC_Cuenta__c IN :cuentasParaInactivar OR CC_Centro_CaixaBank__c IN :cuentasParaInactivar)
																			AND CC_Caracteristica__r.CC_Activo__c = true];
				// Recorro los detalles y quito los contactos y cuentas de los sets de inactivacion
				for(CC_Caracteristica_Detalle__c detalle: lstCaracteristicaDetalle2) {
					if(detalle.CC_Cliente__c != null && contactosParaInactivar.contains(detalle.CC_Cliente__c)){
						contactosParaInactivar.remove(detalle.CC_Cliente__c);
					}
					if(detalle.CC_Empleado__c != null && contactosParaInactivar.contains(detalle.CC_Empleado__c)){
						contactosParaInactivar.remove(detalle.CC_Empleado__c);
					}
					if(detalle.CC_Cuenta__c != null && cuentasParaInactivar.contains(detalle.CC_Cuenta__c)){
						cuentasParaInactivar.remove(detalle.CC_Cuenta__c);
					}
					if(detalle.CC_Centro_CaixaBank__c != null && cuentasParaInactivar.contains(detalle.CC_Centro_CaixaBank__c)){
						cuentasParaInactivar.remove(detalle.CC_Centro_CaixaBank__c);
					}
				}
				//Reviso si quedan contactos o cuentas que haya que desactivar, de ser asi,
				//significa que ya no tienen Detalles Caracteristicas asociadas que cumplan por lo que hay que ponerles el campo CC_Tiene_Caracteristica_Detalle__c a false
				if(!contactosParaInactivar.isEmpty()) {
					for(Id contactId : contactosParaInactivar) {
						Contact c = new Contact(Id = contactId);
						c.CC_Tiene_Caracteristica_Detalle__c = false;
						mapContactsToUpdateById.put(contactId, c);
					}
				}
				if(!cuentasParaInactivar.isEmpty()) {
					for(Id accountId : cuentasParaInactivar) {
						Account a = new Account(Id = accountId);
						a.CC_Tiene_Caracteristica_Detalle__c = false;
						mapAccountsToUpdateById.put(accountId, a);
					}
				}
			}
			// Actualizo los contactos y cuentas tanto los que hay que poner a true como los que haya que poner a false
			if(!mapContactsToUpdateById.isEmpty()) {
				update mapContactsToUpdateById.values();
			}
			if(!mapAccountsToUpdateById.isEmpty()) {
				update mapAccountsToUpdateById.values();
			}
		}
	}
}