/**********************************************************************************************************************
 Name:	  
 Copyright © 2021  CaixaBank
=======================================================================================================================
Proposito: Clase handler para el After Update del Trigger del custom object CBK_PurgeProcess__c
=======================================================================================================================
Historial
---------------------
	VERSION		USER_STORY			AUTHOR				DATE				Description
	1.0								Francisco Zaragoza	25/11/2021			Init version
***********************************************************************************************************************/
public class CBK_PurgeProcess_AU_TRHan   extends CC_TriggerHandlerBase{
	/**
    * @description Metodo de entrada invocado en el after update del trigger 
    * @author   fzaragoza | 25/11/2021 
    * @param    tp  Parametros del trigger (CC_TriggerParameters)
    **/
	public override void mainEntry(CC_TriggerParameters tp) {
		process((List<CBK_PurgeProcess__c>)tp.newList, (Map<Id, CBK_PurgeProcess__c>)tp.newMap, (List<CBK_PurgeProcess__c>) tp.oldList, (Map<Id, CBK_PurgeProcess__c>) tp.oldMap);
	}
	
    /**
    * @description Método de procesamiento invocado desde el método entrada invocado en el after insert del trigger 
    * @author   fzaragoza | 25/11/2021 
    * @param    listNewObj  Lista de los nuevos valores de objetos del trigger  (List<CBK_PurgeProcess__c>)
    * @param    mapNewObj  Mapa por el ID de objeto de los nuevos valores de objetos del trigger (Map<Id, CBK_PurgeProcess__c>)
    * @param    listOldObj Lista de los anteriores valores de objetos del trigger (List<CBK_PurgeProcess__c>)
    * @param    mapOldObj  Mapa por el ID de objeto de los anteriores valores de objetos del trigger (Map<Id, CBK_PurgeProcess__c>)
    **/
	private void process(List<CBK_PurgeProcess__c> listNewObj, Map<Id, CBK_PurgeProcess__c> mapNewObj, List<CBK_PurgeProcess__c> listOldObj, Map<Id, CBK_PurgeProcess__c> mapOldObj) {
		List<CBK_PurgeProcess__c>  lstScheduleInsert = new List<CBK_PurgeProcess__c>();
        List<CBK_PurgeProcess__c>  lstScheduleUpdate = new List<CBK_PurgeProcess__c>();
        List<CBK_PurgeProcess__c>  lstScheduleDelete = new List<CBK_PurgeProcess__c>();
        for (CBK_PurgeProcess__c purgeProcess : listNewObj){
            if(purgeProcess.CBK_Activo__c == true && purgeProcess.CBK_Estado__c == 'Autorizado' && mapOldObj.get(purgeProcess.Id).CBK_Activo__c == false){
                lstScheduleInsert.add(purgeProcess);
            }
            if(purgeProcess.CBK_Activo__c == false && mapOldObj.get(purgeProcess.Id).CBK_Activo__c == true){
                lstScheduleDelete.add(purgeProcess);
            }
            if(purgeProcess.CBK_Activo__c == true  && ( purgeProcess.CBK_LastExec_Sched__c != mapOldObj.get(purgeProcess.Id).CBK_LastExec_Sched__c ||
                        purgeProcess.CBK_Notif__c != mapOldObj.get(purgeProcess.Id).CBK_Notif__c ||
                        purgeProcess.CBK_Email_Notif__c != mapOldObj.get(purgeProcess.Id).CBK_Email_Notif__c ||
                        purgeProcess.CBK_Lunes__c != mapOldObj.get(purgeProcess.Id).CBK_Lunes__c ||
                        purgeProcess.CBK_Martes__c != mapOldObj.get(purgeProcess.Id).CBK_Martes__c ||
                        purgeProcess.CBK_Miercoles__c != mapOldObj.get(purgeProcess.Id).CBK_Miercoles__c ||
                        purgeProcess.CBK_Jueves__c != mapOldObj.get(purgeProcess.Id).CBK_Jueves__c ||
                        purgeProcess.CBK_Viernes__c != mapOldObj.get(purgeProcess.Id).CBK_Viernes__c ||
                        purgeProcess.CBK_Sabado__c != mapOldObj.get(purgeProcess.Id).CBK_Sabado__c ||
                        purgeProcess.CBK_Domingo__c != mapOldObj.get(purgeProcess.Id).CBK_Domingo__c ||
                        purgeProcess.CBK_Periodicidad__c != mapOldObj.get(purgeProcess.Id).CBK_Periodicidad__c ||
                        purgeProcess.CBK_BatchSize__c != mapOldObj.get(purgeProcess.Id).CBK_BatchSize__c||
                        purgeProcess.CBK_Dependencia__c != mapOldObj.get(purgeProcess.Id).CBK_Dependencia__c||
                        purgeProcess.CBK_Priority__c != mapOldObj.get(purgeProcess.Id).CBK_Priority__c)
            ){
                lstScheduleUpdate.add(purgeProcess);
            }
        }
        CBK_PurgeProcess_Utils.generarPlanificaciones (lstScheduleInsert);
        CBK_PurgeProcess_Utils.actualizarPlanificaciones (lstScheduleUpdate);
        CBK_PurgeProcess_Utils.eliminarPlanificaciones (lstScheduleDelete);
        CBK_PurgeProcess_Utils.recalculoPlanificaciones();
	}
}