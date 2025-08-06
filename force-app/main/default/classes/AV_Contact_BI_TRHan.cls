/**********************************************************************************************************************
 Name:	  AV_Contact_BI_TRHan
 Copyright © 2023  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Clase para Trigger de Contact Before Insert
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
	VERSION		USER_STORY		AUTHOR				DATE				Description
	1.0			US590740		Lucía Muñoz		    08/06/2023			Init version
***********************************************************************************************************************/
public with sharing class AV_Contact_BI_TRHan extends CC_TriggerHandlerBase{

    public override void mainEntry(CC_TriggerParameters tp) {
		process((List<Contact>)tp.newList, (Map<Id, Contact>)tp.newMap, (List<Contact>) tp.oldList, (Map<Id, Contact>) tp.oldMap);
	}

    private void process(List<Contact> listNewObj, Map<Id, Contact> mapNewObj, List<Contact> listOldObj, Map<Id, Contact> mapOldObj) {
        //General check the Record type's for intouch project
		List<Contact> listData = AV_ContactTriggerHelper.checkGeneralRT(listNewObj);
		
		List<Contact> listCibeData = AV_ContactTriggerHelper.checkCibeRTs(listNewObj);
		
		if (listData!=null && !listData.isEmpty()){
            // Lógica de negocio a ejecutar
            //AV_ContactTriggerHelper.updateUserFuncion(listData, mapOldObj);
			AV_ContactTriggerHelper.updateContactMatriculaInvalid(listData);
            
        }
        if (listCibeData!=null && !listCibeData.isEmpty()){
        	AV_ContactTriggerHelper.migrateApoderados(listCibeData);
        }

		if(listNewObj != null && !listNewObj.isEmpty()){
			AV_ContactTriggerHelper.employeeExists(listNewObj);
		}
		if (listNewObj != null && !listNewObj.isEmpty()) {
			AV_ContactTriggerHelper.isPoolContact(listNewObj, mapOldObj);
		}
	}

}