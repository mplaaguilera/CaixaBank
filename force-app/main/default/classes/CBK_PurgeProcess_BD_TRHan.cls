/**********************************************************************************************************************
 Name:	  
 Copyright © 2021  CaixaBank
=======================================================================================================================
Proposito: Clase handler para el Before Delete del Trigger del custom object CBK_PurgeProcess__c
=======================================================================================================================
Historial
---------------------
	VERSION		USER_STORY			AUTHOR				DATE				Description
	1.0								Francisco Zaragoza	25/11/2021			Init version
***********************************************************************************************************************/
public with sharing class CBK_PurgeProcess_BD_TRHan   extends CC_TriggerHandlerBase{
	
    /**
    * @description Metodo de entrada invocado en el before delete del trigger 
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
		CBK_PurgeProcess_Utils.eliminarPlanificaciones (listOldObj);
        CBK_PurgeProcess_Utils.recalculoPlanificaciones();
	}
}