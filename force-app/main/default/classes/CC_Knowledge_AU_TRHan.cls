public with sharing class CC_Knowledge_AU_TRHan extends CC_TriggerHandlerBase {
    public override void mainEntry(CC_TriggerParameters tp) {
        process((List<Knowledge__kav>)tp.newList, (Map<Id, Knowledge__kav>)tp.newMap, (List<Knowledge__kav>)tp.oldList, (Map<Id, Knowledge__kav>)tp.oldMap);
    }

    private void process(List<Knowledge__kav> listNewObj, Map<Id, Knowledge__kav> mapNewObj, List<Knowledge__kav> listOldObj, Map<Id, Knowledge__kav> mapOldObj) {

        //Process builder Knowledge Publicar pasado a trigger. Este Process builder NO tiene filtros de record type
        schedulableKnowledge(listNewObj, mapOldObj);

    }

    private void schedulableKnowledge(List<Knowledge__kav> listNewObj, Map<Id, Knowledge__kav> mapOldObj) {
        List<CBK_SCH_PendingProcess__c> listaPendingProcess = new List<CBK_SCH_PendingProcess__c>();
        Set<Id> knowledgeIdsConFechaCaducidadCambiada = new Set<Id>();
        CC_KnowledgeCaseHandler.KnowledgeSettings config = CC_KnowledgeCaseHandler.getCustomSetting();
        Integer diasAvisoDespues = config?.diasAvisoDespues ?? 0;

        for (Knowledge__kav newKnowledge : listNewObj) {
            if (newKnowledge.CC_Fecha_Inicio_Publicacion__c != mapOldObj.get(newKnowledge.Id).CC_Fecha_Inicio_Publicacion__c && 
                newKnowledge.CC_Fecha_Inicio_Publicacion__c != null && 
                newKnowledge.CC_Fecha_Inicio_Publicacion__c >= CBK_UtilsDate.nowSYS() && 
                newKnowledge.PublishStatus != 'Archived' && 
                newKnowledge.ValidationStatus == 'Validated') {
                //Preparar pending process publicar
                CBK_SCH_PendingProcess__c pendingProcessKnowPubli = new CBK_SCH_PendingProcess__c();
                pendingProcessKnowPubli.recordId__c = newKnowledge.Id;
                pendingProcessKnowPubli.Schedule_Time__c = newKnowledge.CC_Fecha_Inicio_Publicacion__c;
                pendingProcessKnowPubli.className__c = 'CC_SchedulableKnowledge';
                pendingProcessKnowPubli.Param1__c = 'actualizarEstadoPublicacion';
                pendingProcessKnowPubli.Param2__c = 'publicar';
                listaPendingProcess.add(pendingProcessKnowPubli);

                //Preparar pending process actualizar mccs
                CBK_SCH_PendingProcess__c pendingProcessKnowMCC = new CBK_SCH_PendingProcess__c();
                pendingProcessKnowMCC.recordId__c = newKnowledge.Id;
                pendingProcessKnowMCC.Schedule_Time__c = newKnowledge.CC_Fecha_Inicio_Publicacion__c;
                pendingProcessKnowMCC.className__c = 'CC_SchedulableKnowledge';
                pendingProcessKnowMCC.Param1__c = 'actualizarMCCKnowledge';
                pendingProcessKnowMCC.Param2__c = newKnowledge.PublishStatus;
                listaPendingProcess.add(pendingProcessKnowMCC);             
            }

            if (newKnowledge.CC_Fecha_Caducidad__c != null && 
                newKnowledge.CC_Fecha_Caducidad__c != mapOldObj.get(newKnowledge.Id).CC_Fecha_Caducidad__c &&
                newKnowledge.CC_Fecha_Caducidad__c >= CBK_UtilsDate.nowSYS()) {
                              
                //Preparar pending process despublicar
                CBK_SCH_PendingProcess__c pendingProcessKnowDesPubli = new CBK_SCH_PendingProcess__c();
                pendingProcessKnowDesPubli.recordId__c = newKnowledge.Id;
                pendingProcessKnowDesPubli.Schedule_Time__c = newKnowledge.CC_Fecha_Caducidad__c;
                pendingProcessKnowDesPubli.className__c = 'CC_SchedulableKnowledge';
                pendingProcessKnowDesPubli.Param1__c = 'actualizarEstadoPublicacion';
                pendingProcessKnowDesPubli.Param2__c = 'despublicar';
                listaPendingProcess.add(pendingProcessKnowDesPubli);

                //Preparar pending process notificacion vencimiento
                if (diasAvisoDespues > 0) {
                    CBK_SCH_PendingProcess__c pendingProcessNotificacion = new CBK_SCH_PendingProcess__c();
                    pendingProcessNotificacion.recordId__c = newKnowledge.Id;
                    pendingProcessNotificacion.Schedule_Time__c = newKnowledge.CC_Fecha_Caducidad__c.addDays(diasAvisoDespues);
                    pendingProcessNotificacion.className__c = 'CC_SchedulableKnowledge';
                    pendingProcessNotificacion.Param1__c = 'notificacionVencimiento';
                    pendingProcessNotificacion.Param2__c = 'articuloVencido';
                    listaPendingProcess.add(pendingProcessNotificacion);
                }

                // Recolectar el ID para eliminar todos los pending processes existentes
                knowledgeIdsConFechaCaducidadCambiada.add(newKnowledge.Id);
            }
        }

        // Eliminar todos los pending processes existentes para los Knowledge con fecha de caducidad cambiada
        if (!knowledgeIdsConFechaCaducidadCambiada.isEmpty()) {
            List<CBK_SCH_PendingProcess__c> pendingProcessesToDelete = [
                SELECT Id 
                FROM CBK_SCH_PendingProcess__c 
                WHERE recordId__c IN :knowledgeIdsConFechaCaducidadCambiada
                AND ((Param1__c = 'actualizarEstadoPublicacion' AND Param2__c = 'despublicar') OR 
                     (Param1__c = 'notificacionVencimiento' AND Param2__c = 'articuloVencido'))
                AND className__c = 'CC_SchedulableKnowledge' AND Queued__c = false
            ];
            
            if (!pendingProcessesToDelete.isEmpty()) {
                 delete pendingProcessesToDelete;
            }
        }

        if (!listaPendingProcess.isEmpty()) {
            insert listaPendingProcess;
        }
    }
}