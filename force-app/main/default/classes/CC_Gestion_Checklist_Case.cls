public with sharing class CC_Gestion_Checklist_Case {
    public static void chequearChecklistAlGuardar(Case caso){
        Id recordId = caso.Id;
        Integer cantidadTareas = 0;
        String mensajeTareas = CC_Settings__c.getValues('CC_MensajeTareasProtocolarias')?.CC_Configuracion_1__c;
        
        // Verificar si hay tareas cargadas en la lista listControles

        String motivoCaso = caso.CC_MCC_Motivo__c;

        // Juntion Object
        Set<Id> maestroTemaIds = new Set<Id>();
        for (CC_TareaMotivo__c tareaMotivo : [
            SELECT CC_Checklist__c 
            FROM CC_TareaMotivo__c 
            WHERE CC_MCC_Motivo__c = :motivoCaso 
            AND CC_Tarea_Motivo_Activa__c = true
        ]) {
            maestroTemaIds.add(tareaMotivo.CC_Checklist__c);
        }

        // Maestro Temas Checklist
        Set<Id> maestroTemasChecklist = new Set<Id>();
        for (SAC_MaestroTemas__c checklist : [
            SELECT Id 
            FROM SAC_MaestroTemas__c 
            WHERE Id 
            IN :maestroTemaIds
            AND RecordTypeId = :CC_TareasProtocolarias.RECTYPECHECKLIST 
        ]) {
            maestroTemasChecklist.add(checklist.Id);
        }

        List<SAC_MaestroTemas__c> listControles = [
            SELECT Id, Name, SAC_Descripcion__c, SAC_Seccion__c, SAC_Activo__c, CC_Maestro_Temas__c
            FROM SAC_MaestroTemas__c 
            WHERE CC_Maestro_Temas__c IN :maestroTemasChecklist 
            AND RecordTypeId = :CC_TareasProtocolarias.RECTYPETAREAS 
            AND SAC_Seccion__c <> null 
            ORDER BY SAC_Seccion__c, Name
        ];
    
    
        List<SAC_Marca_Case__c> tareasCompletadas = [
            SELECT Id, CC_TareaCompletada__c, CC_No_Aplica__c, SAC_Marca__r.Name 
            FROM SAC_Marca_Case__c 
            WHERE SAC_Case__c = :recordId 
            AND SAC_Marca__r.RecordTypeId = :CC_TareasProtocolarias.RECTYPETAREAS
            AND CC_Motivo_del_Caso__c = :caso.CC_Motivo__c
        ];
    
        Map<String, SAC_Marca_Case__c> mapaTareasCompletadas = new Map<String, SAC_Marca_Case__c>();
        for (SAC_Marca_Case__c tarea : tareasCompletadas) {
            mapaTareasCompletadas.put(tarea.SAC_Marca__r.Name, tarea);
        }
    
        Boolean todasTareasCompletadas = true;
        for (SAC_MaestroTemas__c control : listControles) {
            SAC_Marca_Case__c marcaCaso = mapaTareasCompletadas.get(control.Name);
            if (marcaCaso == null || (!marcaCaso.CC_TareaCompletada__c && !marcaCaso.CC_No_Aplica__c)) {
                todasTareasCompletadas = false;
                break;
            }
        }
        if (!todasTareasCompletadas) {
            throw new AuraHandledException(mensajeTareas);
        }
    }
}