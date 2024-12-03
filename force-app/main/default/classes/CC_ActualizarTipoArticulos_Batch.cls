public class CC_ActualizarTipoArticulos_Batch implements Database.Batchable<SObject>, Database.Stateful {
	public CC_ActualizarTipoArticulos_Batch() {
        CBK_Log.debug('Iniciación - Batch CC_ActualizarTipoArticulos_Batch',logginglevel.INFO);
    }
    
    public Database.QueryLocator start(Database.BatchableContext bc) {
        String query = 'SELECT Title, KnowledgeArticleId, PublishStatus, CC_Tipo__c FROM Knowledge__kav WHERE (PublishStatus = \'Online\' OR PublishStatus = \'Draft\') AND IsLatestVersion = true AND (RecordType.DeveloperName=\'CC_Arbol_Decision\' OR RecordType.DeveloperName=\'CC_Ficha_Producto\' OR RecordType.DeveloperName=\'CC_Informacion_General\' OR RecordType.DeveloperName=\'CC_Pregunta_Respuesta\' OR RecordType.DeveloperName=\'CC_Procedimiento\' OR RecordType.DeveloperName=\'CC_Video\') AND (CC_Tipo__c = null OR CC_Tipo__c = \'\') ORDER BY LastModifiedDate DESC';
        return Database.getQueryLocator(query);
    }
    
    public void execute(Database.BatchableContext bc, List<Knowledge__kav> articlesPublishedOrDraft) {
        try {
            String prefix = 'CL-';
            Set<Id> setIdErrorWhenUnpublish = new Set<Id>();
            Set<Id> setIdPutOnDraft = new Set<Id>();
            List<Knowledge__kav> articlesToUpdate = new List<Knowledge__kav>();
            //Para aquellos que estan Published hay que generarle una version Draft antes.
            if (!articlesPublishedOrDraft.isEmpty()) {
                for (Knowledge__kav article : articlesPublishedOrDraft) {
                    if(article.PublishStatus == 'Online'){
                        try {
                            //Cuando se llama a este metodo, Salesforce crea automaticamente una versión Draft para esos articulos.
                            KbManagement.PublishingService.editOnlineArticle(article.KnowledgeArticleId, false);
                            setIdPutOnDraft.add(article.KnowledgeArticleId);
                        } catch (Exception e) {
                            //Si el artículo ya tiene una versión Draft, salta un error.
                            setIdErrorWhenUnpublish.add(article.KnowledgeArticleId);
                        }
                    }
                    //Articles en Draft se pueden actualizar directamente
                    else{
                        //hacer un trim title antes de comparar para quitar los espacios en blanco
                        if (article.Title.startsWith(prefix)) {
                            article.CC_Tipo__c = 'Cliente';
                        } else {
                            article.CC_Tipo__c = 'Empleado';
                        }
                        articlesToUpdate.add(article);
                    }
                }

                List <Knowledge__kav> articlesAfterDraft = [SELECT Id, KnowledgeArticleId, CC_Tipo__c, Title FROM Knowledge__kav
                WHERE PublishStatus = 'Draft'
                AND KnowledgeArticleId IN: setIdPutOnDraft
                AND (
                    RecordType.DeveloperName='CC_Arbol_Decision'
                    OR RecordType.DeveloperName='CC_Ficha_Producto'
                    OR RecordType.DeveloperName='CC_Informacion_General'
                    OR RecordType.DeveloperName='CC_Pregunta_Respuesta'
                    OR RecordType.DeveloperName='CC_Procedimiento'
                    OR RecordType.DeveloperName='CC_Video'
                )];
                for (Knowledge__kav article : articlesAfterDraft){
                    // Hacer un trim title antes de comparar para quitar los espacios en blanco
                    String titulo = article.Title.replace(' ', '');
                    // if (article.Title.startsWith(prefix)) {
                    if (titulo.startsWith(prefix)) {
                        article.CC_Tipo__c = 'Cliente';
                    } else {
                        article.CC_Tipo__c = 'Empleado';
                    }
                    articlesToUpdate.add(article);
                }

                if(!articlesToUpdate.isEmpty()){
                    update articlesToUpdate;
                    //---------------- SE VUELVEN A PUBLICAR TODOS LOS ARTÍCULOS QUE ESTABAN PUBLICADOS  ----------------------//
                    for (Knowledge__kav article : articlesToUpdate) {
                        //Solo se vuelven a publicar los articulos que no tenían versión Draft
                        if(!setIdErrorWhenUnpublish.contains(article.KnowledgeArticleId) && setIdPutOnDraft.contains(article.KnowledgeArticleId)) {
                            //Volver a publicar los que se pusieron en draft
                            try {
                            //Se usa el scheduleForPublication porque el publishArticle afecta 100 DMLs Rows del limite de SF por cada articulo
                            //el metodo scheduleForPublication con null en el segundo parametro, publica instantaneamente.
                                KbManagement.PublishingService.scheduleForPublication(article.KnowledgeArticleId, null);
                            } catch (Exception e) {
                                // Registra el error para revisión
                                CBK_Log.error(e,'Error al publicar  el artículo ' + article.KnowledgeArticleId + ': ' + e.getMessage());
                            }
                        }
                    }

                }
            }
        } catch (DmlException e) {
            CBK_Log.error(e);
        }
    }
    
    public void finish(Database.BatchableContext bc) {
        CBK_Log.debug('Finalización - Batch CC_ActualizarTipoArticulos_Batch',logginglevel.INFO);
    }
}