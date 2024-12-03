public with sharing class SEG_Account_BI_TRHan extends CC_TriggerHandlerBase {
    
	public override void mainEntry(CC_TriggerParameters tp) {
        process((List<Account>)tp.newList, (Map<Id, Account>)tp.newMap);
	}

    private void process(List<Account> listNewObj, Map<Id, Account> mapNewObj) {

        Id rtCliente = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();
		Id clienteSeg = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('CC_ClienteSEG').getRecordTypeId();
		List<Account> lstSeg = new List<Account>();

		for (Account lstNObj : listNewObj) {
			if (lstNObj.recordTypeId == rtCliente || lstNObj.recordTypeId == clienteSeg) {
				lstSeg.add(lstNObj);
			}
		}

        asignacionNegocio(listNewObj);
        actualizacionGestorComercial(lstSeg); // Método para la actualización del campo SEG_Gestor_Comercial_Actual__c al modificar el campo SEG_Prioridad_Carterizacion_Segmentos__c
        actualizacionGestorOperativaNacional(lstSeg);
	}

    private void asignacionNegocio(List<Account> listNewObj) {
        List<UserAppInfo> userAppInfo = [SELECT Id, AppDefinitionId FROM UserAppInfo WHERE UserId = :UserInfo.getUserId() LIMIT 1];
        String appName='';

        if (userAppInfo.size()>0) {
            List<AppDefinition> appDefinition = [SELECT DeveloperName FROM AppDefinition Where DurableId = :userAppInfo[0].AppDefinitionId LIMIT 1];
			if (appDefinition.size()>0) {
                appName=appDefinition[0].DeveloperName;
            }
        }

        if (Test.isRunningTest()) {
            appName='SEG_Segmentos'; 
        }
        
        if(appName == 'SEG_Segmentos'){
            Id colaboradorAccountRT = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('CC_Colaborador').getRecordTypeId();     
            for (Account cnt : listNewObj) {
                if ((cnt.recordtypeId == colaboradorAccountRT) && (cnt.CBK_Negocio__c == null)){
                    cnt.CBK_Negocio__c='Segmentos';
                }
            } 
        }
    }

    // Método para la actualización del campo SEG_Gestor_Comercial_Actual__c al modificar el campo SEG_Prioridad_Carterizacion_Segmentos__c
	private void actualizacionGestorComercial(List<Account> listNewObj) {
        Id rtCliente = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();
        Set <Id> setIdsAcc = new Set <Id>();
        for (Account accLst : listNewObj) {
            if(accLst.recordTypeId == rtCliente && !accLst.SEG_Prioridad_Carterizacion_Segmentos__c && accLst.AV_EAPGestor__c != null){
                setIdsAcc.add(accLst.AV_EAPGestor__c);
            } else if (!accLst.SEG_Prioridad_Carterizacion_Segmentos__c && accLst.AV_EAPGestor__c != null) {
                setIdsAcc.add(accLst.AV_EAPGestor__c);
            }else if (accLst.SEG_Prioridad_Carterizacion_Segmentos__c && accLst.SEG_Empleado_gestor_Segmentos__c != null) {
                setIdsAcc.add(accLst.SEG_Empleado_gestor_Segmentos__c);
            }
        }
        
        if (!setIdsAcc.isEmpty()) {
            Map <Id, Contact> mapContactPer = new Map <Id, Contact> ([SELECT id, Name FROM Contact WHERE id IN :setIdsAcc]);

            for (Account accLstUpdt : listNewObj) {
                if (accLstUpdt.AV_EAPGestor__c != null && !accLstUpdt.SEG_Prioridad_Carterizacion_Segmentos__c && mapContactPer.containsKey(accLstUpdt.AV_EAPGestor__c)) {
                    accLstUpdt.SEG_Gestor_Comercial_Actual__c = mapContactPer.get(accLstUpdt.AV_EAPGestor__c).Name;
                }else if(accLstUpdt.SEG_Empleado_gestor_Segmentos__c != null && accLstUpdt.SEG_Prioridad_Carterizacion_Segmentos__c && mapContactPer.containsKey(accLstUpdt.SEG_Empleado_gestor_Segmentos__c)){
                    accLstUpdt.SEG_Gestor_Comercial_Actual__c = mapContactPer.get(accLstUpdt.SEG_Empleado_gestor_Segmentos__c).Name;
                }
            }
        }			
	}
    //Método para la actualización del campo SEG_GestorOperativaNacionalActual__c para poder utilizarse como filtro en el objeto Case
    private void actualizacionGestorOperativaNacional(List<Account> listNewObj) {
        Id rtCliente = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();
        Set <Id> setIdsAcc = new Set <Id>();
        for (Account accLst : listNewObj) {
            if(accLst.recordTypeId == rtCliente && accLst.SEG_GestorOperativaNacional__c != null){
                setIdsAcc.add(accLst.SEG_GestorOperativaNacional__c);
            }
        }

        if (!setIdsAcc.isEmpty()) {
            Map <Id, Contact> mapContactPer = new Map <Id, Contact> ([SELECT id, Name FROM Contact WHERE id IN :setIdsAcc]);

            for (Account accLstUpdt : listNewObj) {
                if (accLstUpdt.SEG_GestorOperativaNacional__c != null && mapContactPer.containsKey(accLstUpdt.SEG_GestorOperativaNacional__c)) {
                    accLstUpdt.SEG_GestorOperativaNacionalActual__c = mapContactPer.get(accLstUpdt.SEG_GestorOperativaNacional__c).Name;
                }
            }
        }	
    }
}