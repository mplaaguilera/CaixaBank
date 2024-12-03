/**********************************************************************************************************************
 Name:	  AV_Task_BI_TRHan_Test
 Copyright © 2020  CaixaBank
=======================================================================================================================
Proposito: Clase de Test para AV_Task_BI_TRHan
=======================================================================================================================
Historial
---------------------
	VERSION		USER_STORY		AUTHOR					DATE				Description
	1.0			App FSC			Carolina Alonso	   		24/04/2020			Init version
	1.1			App FSC			Carolina Alonso			06/05/2020			Change logic in test class
	1.2			App FSC			Jashanpreet Singh		14/10/2020			Logic in class AV_TaskTriggerHelper_Test
	1.3			US147562		Sandra Gómez			14/01/2020			Added new method createCRMTask
***********************************************************************************************************************/
@isTest
public class AV_Task_BI_TRHan_Test extends CC_TriggerHandlerBase{

	public override void mainEntry(CC_TriggerParameters tp) {
		process((List<Task>)tp.newList, (Map<Id, Task>)tp.newMap, (List<Task>) tp.oldList, (Map<Id, Task>) tp.oldMap);
	}
	
	private void process(List<Task> listNewObj, Map<Id, Task> mapNewObj, List<Task> listOldObj, Map<Id, Task> mapOldObj) {
        //General check the Record type's for intouch project
        List<Task> listData = AV_TaskTriggerHelper.checkGeneralRT(listNewObj);
        
        if (listData!=null && !listData.isEmpty()){
            AV_TaskTriggerHelper.createCRMTask(listData, mapOldObj);
        }
    }
	
}