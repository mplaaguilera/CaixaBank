/**********************************************************************************************************************
Name:	  AV_NotifyExpCliTaskSchedulable
Copyright © 2023  CaixaBank
------------------------------------------------------------------------------------------------
Proposito: Clase que gestiona las notificaciones programadas para las tareas experiencia cliente.
------------------------------------------------------------------------------------------------
Historial
---------------------
VERSION		USER_STORY	        AUTHOR		   		DATE				Description
1.0			  US464358		        Luis Fernandez	   13/02/2023		Init version
***********************************************************************************************************************/

public with sharing class AV_NotifyExpCliTaskSchedulable extends CBK_SCH_Queueable_Abstract {
   
    public override void execute(QueueableContext ctx) {
      List<CBK_SCH_PendingProcess__c> incomingPendingProcessList = this.lstInfoProcess;
      work(incomingPendingProcessList);

  }

  private void work(List<CBK_SCH_PendingProcess__c> incomingPendingProcessList) {
   for(CBK_SCH_PendingProcess__c processList : incomingPendingProcessList){
      AV_TaskTriggerHelper.executeNotification(processList.Param1__c,processList.RecordId__c);
   }

  }

}