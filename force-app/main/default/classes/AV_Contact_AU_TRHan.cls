/**********************************************************************************************************************
 Name:	  AV_Contact_AU_TRHan
 Copyright © 2021  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Clase para Trigger de User AfterUpdate
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
	VERSION		USER_STORY		AUTHOR				DATE				Description
	1.0			US208429		Víctor Santiago		26/04/2021			Init version
	1.1 		US586011		Luis Fernández		13/06/2023			Added processBPRRole call
***********************************************************************************************************************/
public class AV_Contact_AU_TRHan extends CC_TriggerHandlerBase {
    
    public override void mainEntry(CC_TriggerParameters tp) {
		process((List<Contact>)tp.newList, (Map<Id, Contact>)tp.newMap, (List<Contact>) tp.oldList, (Map<Id, Contact>) tp.oldMap);
	}
	
	private void process(List<Contact> listNewObj, Map<Id, Contact> mapNewObj, List<Contact> listOldObj, Map<Id, Contact> mapOldObj) {
		//General check the Record type's for intouch project
		List<Contact> listData = AV_ContactTriggerHelper.checkGeneralRT(listNewObj);
		
		if (listData!=null && !listData.isEmpty()){
            // Lógica de negocio a ejecutar
            AV_ContactTriggerHelper.updateUserFuncion(listData, mapOldObj);
			AV_ContactTriggerHelper.processBPRRole(listData,mapOldObj);
        }
	}

}