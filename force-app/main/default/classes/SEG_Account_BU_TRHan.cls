public with sharing class SEG_Account_BU_TRHan extends CC_TriggerHandlerBase {

	public override void mainEntry(CC_TriggerParameters tp) {
        process((List<Account>)tp.newList, (Map<Id, Account>)tp.newMap, (List<Account>)tp.oldList, (Map<Id, Account>)tp.oldMap);
	}

	private void process(List<Account> listNewObj, Map<Id, Account> mapNewObj, List<Account> listOldObj, Map<Id, Account> mapOldObj) {
		Id rtCliente = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();
		Id clienteSeg = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('CC_ClienteSEG').getRecordTypeId();
		List<Account> lstSeg = new List<Account>();

		for (Account lstNObj : listNewObj) {
			if (lstNObj.recordTypeId == rtCliente || lstNObj.recordTypeId == clienteSeg) {
				lstSeg.add(lstNObj);
			}
		}
		actualizacionGestorComercial(lstSeg, mapOldObj); // Método para la actualización del campo SEG_Gestor_Comercial_Actual__c al modificar el campo SEG_Prioridad_Carterizacion_Segmentos__c
		actualizacionGestor(lstSeg, mapOldObj);
		actualizacionGestorOperativaNacional(lstSeg, mapOldObj);// Método para la actualización del campo SEG_Gestor_Operativa_Nacional_Actual__c
	}

	// Método para la actualización del campo SEG_Gestor_Comercial_Actual__c al modificar el campo SEG_Prioridad_Carterizacion_Segmentos__c
	private void actualizacionGestorComercial(List<Account> lstAccountNuevos, Map<Id, Account> mapAccountsViejos) {
		List<Account> lstAccountUpdt = new List<Account>();
		//recorrer la lista de cuentas nuevas que se actualicen
		for (Account rLstAccNew : lstAccountNuevos) {
			//comprobar que se haya modificado el campo SEG_Prioridad_Carterizacion_Segmentos__c
			if (rLstAccNew.SEG_Prioridad_Carterizacion_Segmentos__c != mapAccountsViejos.get(rLstAccNew.id).SEG_Prioridad_Carterizacion_Segmentos__c) {
				// si se ha modificado, rellenar el campo SEG_Gestor_Comercial_Actual__c con los datos del gestor que toque
				lstAccountUpdt.add(rLstAccNew);
			}
		}

		//comprobar que NO esté vacía
		if (!lstAccountUpdt.isEmpty()) {
			Set <Id> setIdsAcc = new Set <Id>();
			for (Account accLst : lstAccountUpdt) {
				if (!accLst.SEG_Prioridad_Carterizacion_Segmentos__c && accLst.AV_EAPGestor__c != null) {
					setIdsAcc.add(accLst.AV_EAPGestor__c);
				}else if (accLst.SEG_Prioridad_Carterizacion_Segmentos__c && accLst.SEG_Empleado_gestor_Segmentos__c != null) {
					setIdsAcc.add(accLst.SEG_Empleado_gestor_Segmentos__c);
				}
			}


			//saco una query para sacar los nombres y apellidos de los Accounts que estén dentro de lstAccountUpdt
			if (!setIdsAcc.isEmpty()) {
				Map <Id, Contact> mapContactPer = new Map <Id, Contact> ([SELECT id, Name FROM Contact WHERE id IN :setIdsAcc]);

				for (Account accLstUpdt : lstAccountUpdt) {
					if (accLstUpdt.AV_EAPGestor__c != null  && !accLstUpdt.SEG_Prioridad_Carterizacion_Segmentos__c && mapContactPer.containsKey(accLstUpdt.AV_EAPGestor__c)) {
						accLstUpdt.SEG_Gestor_Comercial_Actual__c = mapContactPer.get(accLstUpdt.AV_EAPGestor__c).Name;
					}else if(accLstUpdt.SEG_Empleado_gestor_Segmentos__c != null  && accLstUpdt.SEG_Prioridad_Carterizacion_Segmentos__c && mapContactPer.containsKey(accLstUpdt.SEG_Empleado_gestor_Segmentos__c)){
						accLstUpdt.SEG_Gestor_Comercial_Actual__c = mapContactPer.get(accLstUpdt.SEG_Empleado_gestor_Segmentos__c).Name;
					}
				}
			}			
		}
	}

	// Método para la actualización del campo SEG_Gestor_Comercial_Actual__c al modificar los campos de los gestores
	private void actualizacionGestor(List<Account> lstAccountNuevos, Map<Id, Account> mapAccountsViejos) {
		List<Account> lstAccountUpdt = new List<Account>();
		//recorrer la lista de cuentas nuevas que se actualicen
		for (Account rLstAccNew : lstAccountNuevos) {
			//comprobar que se haya modificado el campo SEG_Prioridad_Carterizacion_Segmentos__c
			if ((rLstAccNew.AV_EAPGestor__c != mapAccountsViejos.get(rLstAccNew.id).AV_EAPGestor__c && rLstAccNew.AV_EAPGestor__c != null) || (rLstAccNew.SEG_Empleado_gestor_Segmentos__c != mapAccountsViejos.get(rLstAccNew.id).SEG_Empleado_gestor_Segmentos__c && rLstAccNew.SEG_Empleado_gestor_Segmentos__c != null)) {
				// si se ha modificado, rellenar el campo SEG_Gestor_Comercial_Actual__c con los datos del gestor que toque
				lstAccountUpdt.add(rLstAccNew);
			}
		}

		//comprobar que NO esté vacía
		if (!lstAccountUpdt.isEmpty()) {
			Set <Id> setIdsAcc = new Set <Id>();
			for (Account accLst : lstAccountUpdt) {
				if (!accLst.SEG_Prioridad_Carterizacion_Segmentos__c) {
					setIdsAcc.add(accLst.AV_EAPGestor__c);
				}else if (accLst.SEG_Prioridad_Carterizacion_Segmentos__c) {
					setIdsAcc.add(accLst.SEG_Empleado_gestor_Segmentos__c);
				}
			}

			//saco una query para sacar los nombres y apellidos de los Accounts que estén dentro de lstAccountUpdt
			if (!setIdsAcc.isEmpty()) {
				Map <Id, Contact> mapContactPer = new Map <Id, Contact> ([SELECT id, Name FROM Contact WHERE id IN :setIdsAcc]);

				for (Account accLstUpdt : lstAccountUpdt) {
					if (accLstUpdt.AV_EAPGestor__c != null && !accLstUpdt.SEG_Prioridad_Carterizacion_Segmentos__c && mapContactPer.containsKey(accLstUpdt.AV_EAPGestor__c)) {
						accLstUpdt.SEG_Gestor_Comercial_Actual__c = mapContactPer.get(accLstUpdt.AV_EAPGestor__c).Name;
					}else if(accLstUpdt.SEG_Empleado_gestor_Segmentos__c != null  && accLstUpdt.SEG_Prioridad_Carterizacion_Segmentos__c && mapContactPer.containsKey(accLstUpdt.SEG_Empleado_gestor_Segmentos__c)){
						accLstUpdt.SEG_Gestor_Comercial_Actual__c = mapContactPer.get(accLstUpdt.SEG_Empleado_gestor_Segmentos__c).Name;
					}
				}
			}			
		}
	}

	//Método para la actualización del campo SEG_GestorOperativaNacionalActual__c para poder utilizarse como filtro en el objeto Case
    private void actualizacionGestorOperativaNacional(List<Account> lstAccountNuevos, Map<Id, Account> mapAccountsViejos) {
		List<Account> lstAccountUpdt = new List<Account>();
		//recorrer la lista de cuentas nuevas que se actualicen
		for (Account rLstAccNew : lstAccountNuevos) {
			//comprobar que se haya modificado el campo SEG_GestorOperativaNacional__c
			if (rLstAccNew.SEG_GestorOperativaNacional__c != mapAccountsViejos.get(rLstAccNew.id).SEG_GestorOperativaNacional__c) {
				// si se ha modificado, rellenar el campo SEG_GestorOperativaNacionalActual__c con los datos del gestor que toque
				lstAccountUpdt.add(rLstAccNew);
			}
		}

		//comprobar que NO esté vacía
		if (!lstAccountUpdt.isEmpty()) {
			Set <Id> setIdsAcc = new Set <Id>();
			for (Account accLst : lstAccountUpdt) {
				if (accLst.SEG_GestorOperativaNacional__c != null) {
					setIdsAcc.add(accLst.SEG_GestorOperativaNacional__c);
				}
			}

			//saco una query para sacar los nombres y apellidos de los Accounts que estén dentro de setIdsAcc
			if (!setIdsAcc.isEmpty()) {
				Map <Id, Contact> mapContactPer = new Map <Id, Contact> ([SELECT id, Name FROM Contact WHERE id IN :setIdsAcc]);

				for (Account accLstUpdt : lstAccountUpdt) {
					if (accLstUpdt.SEG_GestorOperativaNacional__c != null && mapContactPer.containsKey(accLstUpdt.SEG_GestorOperativaNacional__c)) {
						accLstUpdt.SEG_GestorOperativaNacionalActual__c = mapContactPer.get(accLstUpdt.SEG_GestorOperativaNacional__c).Name;
					}
				}
			}
		}
	}
}