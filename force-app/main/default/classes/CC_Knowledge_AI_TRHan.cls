public with sharing class CC_Knowledge_AI_TRHan extends CC_TriggerHandlerBase {
    public override void mainEntry(CC_TriggerParameters tp) {
        process((List<Knowledge__kav>)tp.newList, (Map<Id, Knowledge__kav>)tp.newMap);
    }

    private void process(List<Knowledge__kav> listNewObj, Map<Id, Knowledge__kav> mapNewObj) {

        //Process builder Knowledge Publicar pasado a trigger. Este Process builder NO tiene filtros de record type
        schedulableKnowledge(listNewObj);
        
        Id idRtInformacionGeneral = Schema.SObjectType.Knowledge__kav.getRecordTypeInfosByDeveloperName().get('CC_Informacion_General').getRecordTypeId();
        Id idRtCCProcedimiento = Schema.SObjectType.Knowledge__kav.getRecordTypeInfosByDeveloperName().get('CC_Procedimiento').getRecordTypeId();
        Id idRtCCArbol = Schema.SObjectType.Knowledge__kav.getRecordTypeInfosByDeveloperName().get('CC_Arbol_Decision').getRecordTypeId();
        Id idRtCCFicha = Schema.SObjectType.Knowledge__kav.getRecordTypeInfosByDeveloperName().get('CC_Ficha_Producto').getRecordTypeId();
        Id idRtCCPregunta = Schema.SObjectType.Knowledge__kav.getRecordTypeInfosByDeveloperName().get('CC_Pregunta_Respuesta').getRecordTypeId();
        Id idRtCCVideo = Schema.SObjectType.Knowledge__kav.getRecordTypeInfosByDeveloperName().get('CC_Video').getRecordTypeId();
        List<Id>listaCC = new List<Id>();
        List<Id>listaArticulos = new List<Id>();
        List<Knowledge__kav>listaKnowledge = new List<Knowledge__kav>();
        listaCC.add(idRtInformacionGeneral);
        listaCC.add(idRtCCProcedimiento);
        listaCC.add(idRtCCArbol);
        listaCC.add(idRtCCFicha);
        listaCC.add(idRtCCPregunta);
        listaCC.add(idRtCCVideo);

    //Procedemos a asignar como propietario de los knowledge la cola para que los agregados a la cola tengan permisos de editar por código
        for(Knowledge__kav l : listNewObj){
            listaArticulos.add(l.Id);
        }
    List<Knowledge__kav> articulo = [SELECT id, OwnerId, CC_Tipo__c, PublishStatus, RecordTypeId   from Knowledge__kav where id IN :listaArticulos];
    List<Group> colasKnowledge = [SELECT id, DeveloperName  FROM Group WHERE DeveloperName IN ('CC_Knowledge_Cliente','CC_Knowledge_Empleado') and Type = 'Queue'];
    id colaKnowledgeCliente;
    id colaKnowledgeEmpleado;
        if(!colasKnowledge.isEmpty()){
        for (Group g : colasKnowledge)
        {
            if (g.DeveloperName == 'CC_Knowledge_Cliente'){
              	colaKnowledgeCliente = g.id;  
            }else if(g.DeveloperName == 'CC_Knowledge_Empleado'){
                colaKnowledgeEmpleado = g.id;
            }   
        }
            
        for (Knowledge__kav k : articulo){
            
        if(k.CC_Tipo__c != null && !listaCC.isEmpty()){
        	if (k.CC_Tipo__c == 'Cliente' && k.OwnerId != colaKnowledgeCliente && k.PublishStatus == 'Draft' && listaCC.contains(k.recordTypeId)){
            	k.OwnerId = colaKnowledgeCliente;
                listaKnowledge.add(k);
        	}else if(k.CC_Tipo__c == 'Empleado' && k.OwnerId != colaKnowledgeEmpleado && k.PublishStatus == 'Draft'&& listaCC.contains(k.recordTypeId)){
            	k.OwnerId = colaKnowledgeEmpleado;
                listaKnowledge.add(k);
        		}
        	}    
    	}
    }
	update listaKnowledge;


    }

    private void schedulableKnowledge(List<Knowledge__kav> listNewObj) {
        List<CBK_SCH_PendingProcess__c> listaPendingProcess = new List<CBK_SCH_PendingProcess__c>();
        CC_KnowledgeCaseHandler.KnowledgeSettings config = CC_KnowledgeCaseHandler.getCustomSetting();
        Integer diasNotificacion = config?.diasAvisoDespues ?? 0;

        for (Knowledge__kav newKnowledge : listNewObj) {
            if (newKnowledge.CC_Fecha_Inicio_Publicacion__c != null && newKnowledge.CC_Fecha_Inicio_Publicacion__c >= CBK_UtilsDate.nowSYS() && newKnowledge.PublishStatus != 'Archived' && newKnowledge.ValidationStatus == 'Validated') {
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

            if (newKnowledge.CC_Fecha_Caducidad__c != null && newKnowledge.CC_Fecha_Caducidad__c >= CBK_UtilsDate.nowSYS()) { 
                //Preparar pending process despublicar
                CBK_SCH_PendingProcess__c pendingProcessKnowDesPubli = new CBK_SCH_PendingProcess__c();
                pendingProcessKnowDesPubli.recordId__c = newKnowledge.Id;
                pendingProcessKnowDesPubli.Schedule_Time__c = newKnowledge.CC_Fecha_Caducidad__c;
                pendingProcessKnowDesPubli.className__c = 'CC_SchedulableKnowledge';
                pendingProcessKnowDesPubli.Param1__c = 'actualizarEstadoPublicacion';
                pendingProcessKnowDesPubli.Param2__c = 'despublicar';
                listaPendingProcess.add(pendingProcessKnowDesPubli);

                //Preparar pending process notificacion vencimiento
                if (diasNotificacion > 0) {
                    CBK_SCH_PendingProcess__c pendingProcessNotificacion = new CBK_SCH_PendingProcess__c();
                    pendingProcessNotificacion.recordId__c = newKnowledge.Id;
                    pendingProcessNotificacion.Schedule_Time__c = newKnowledge.CC_Fecha_Caducidad__c.addDays(diasNotificacion);
                    pendingProcessNotificacion.className__c = 'CC_SchedulableKnowledge';
                    pendingProcessNotificacion.Param1__c = 'notificacionVencimiento';
                    pendingProcessNotificacion.Param2__c = 'articuloVencido';
                    listaPendingProcess.add(pendingProcessNotificacion);
                }
            }
        }

        if (!listaPendingProcess.isEmpty()) {
            insert listaPendingProcess;
        }
    }
}