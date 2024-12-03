/**********************************************************************************************************************
 Name:	  AV_Contact_BU_TRHan
 Copyright © 2021  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Clase para Trigger de User BeforeUpdate
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
	VERSION		USER_STORY		AUTHOR				DATE				Description
	1.0			US208429		Víctor Santiago		26/04/2021			Init version
	1.1			FIX				David Rufo			19/05/2021			Fixed query loop problem
	1.2			US590740		Lucía Muñoz		    08/06/2023			Llamada al metodo updateContactMatriculaInvalid


***********************************************************************************************************************/
public class AV_Contact_BU_TRHan extends CC_TriggerHandlerBase {

    public override void mainEntry(CC_TriggerParameters tp) {
		process((List<Contact>)tp.newList, (Map<Id, Contact>)tp.newMap, (List<Contact>) tp.oldList, (Map<Id, Contact>) tp.oldMap);
	}
	
	private void process(List<Contact> listNewObj, Map<Id, Contact> mapNewObj, List<Contact> listOldObj, Map<Id, Contact> mapOldObj) {
        //General check the Record type's for intouch project
		List<Contact> listData = AV_ContactTriggerHelper.checkGeneralRT(listNewObj);
        
        //General check the Record type's for intouch project
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