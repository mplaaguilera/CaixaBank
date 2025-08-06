public with sharing class CC_CaseStatusKnowledgeController {
   @AuraEnabled
   public static void changeStatusKnowledgeCase(Id caseId, String status, String action) {
        try {
            Case caseRecord = [
                SELECT Id, Status, 
                    CBK_Case_Extension_Id__c,
                    CBK_Case_Extension_Id__r.CC_Articulo_Relacionado__c
                FROM Case 
                WHERE Id = :caseId
            ];
          
            
            if(caseRecord.CBK_Case_Extension_Id__c == null || caseRecord.CBK_Case_Extension_Id__r.CC_Articulo_Relacionado__c == null) {
                CC_CustomException.throwCustomException('Este caso no tiene articulo relacionado. Esta funcionalidad es para casos Knowledge.');
            }
           
            caseRecord.Status = status;
            if (status == 'Cerrado') {
                Id articuloId = caseRecord.CBK_Case_Extension_Id__r.CC_Articulo_Relacionado__c;
                KnowledgeArticleVersion art = [SELECT Id, KnowledgeArticleId, PublishStatus FROM KnowledgeArticleVersion WHERE Id = :articuloId LIMIT 1];
                if (action == 'Archivar') {   
                    if (art.PublishStatus == 'Online') {
                        KbManagement.PublishingService.archiveOnlineArticle(art.KnowledgeArticleId, null);
                    }
                } else if (action == 'Renovar') {
                    // Crear un nuevo borrador y extender la caducidad si la acción es Reactivar
                    Id newDraftVersionId;
                    if (art.PublishStatus == 'Online') {
                        newDraftVersionId = KbManagement.PublishingService.editOnlineArticle(art.KnowledgeArticleId, false);
                    } else if (art.PublishStatus == 'Archived') {
                        newDraftVersionId = KbManagement.PublishingService.editArchivedArticle(art.KnowledgeArticleId);
                    }
                    if (newDraftVersionId != null) {
                        Knowledge__kav newDraft = new Knowledge__kav(
                            Id = newDraftVersionId,
                            CC_Fecha_Caducidad__c = CBK_UtilsDate.nowDT().addYears(1),
                            CC_Fecha_Inicio_Publicacion__c = CBK_UtilsDate.nowDT().addMinutes(1) //por la regla de validacion. 
                        );
                        update newDraft;
                        // Volver a publicar el artículo
                        KbManagement.PublishingService.scheduleForPublication(art.KnowledgeArticleId, null);
                    }else{
                        CC_CustomException.throwCustomException('No se pudo renovar el artículo. Ha ocurrido un error creando la versión draft.');
                    }
                } else if (action == 'Actualizar') {
                    // Validar si el artículo está online y si la fecha de caducidad está en el año siguiente.
                    //Integer anioSiguiente = Date.today().year() + 1;
                    List<Knowledge__kav> versionesOnline = [
                        SELECT Id, CC_Fecha_Caducidad__c
                        FROM Knowledge__kav
                        WHERE KnowledgeArticleId = :art.KnowledgeArticleId
                        AND PublishStatus = 'Online'
                        AND CC_Fecha_Caducidad__c = NEXT_YEAR
                        ORDER BY LastModifiedDate DESC
                        LIMIT 1
                    ];
                    if (versionesOnline.isEmpty()) {
                    // No se puede cerrar el caso. 
                       CC_CustomException.throwCustomException('No se puede cerrar el caso porque el articulo no tiene una versión online con fecha de caducidad en el año siguiente.');
                    }
                }

                caseRecord.CC_Detalles_Consulta__c = 'Cerrado por el usuario con la acción: ' + action;
                caseRecord.CC_Detalles_Solucion__c = action;
                caseRecord.CC_CierreAutomaticoCSBD__c = true; //Para bypass validación del trigger de caso (Debe usar el botón \'Guardar y Cerrar\' o la operativa correspondiente)
                
            }
            
            update caseRecord;

            Task tareaCambioStatus = CC_KnowledgeCaseHandler.crearTareaCambioStatus(caseRecord.Id, status, action);
            insert tareaCambioStatus;

        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
   }

    @AuraEnabled
    public static Map<String, Object> getConfiguraciones() {
        try {
            CC_KnowledgeCaseHandler.KnowledgeSettings config = CC_KnowledgeCaseHandler.getCustomSetting();
            Map<String, Object> result = new Map<String, Object>();
            result.put('avisoArchivar', config.avisoArchivar);
            result.put('avisoRenovar', config.avisoRenovar);
            result.put('avisoActualizar', config.avisoActualizar);       
            return result;
        } catch (Exception e) {
            throw new AuraHandledException('Error al obtener las configuraciones: ' + e.getMessage());
        }
    }

}