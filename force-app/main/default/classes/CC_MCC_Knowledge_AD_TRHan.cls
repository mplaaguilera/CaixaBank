public with sharing class CC_MCC_Knowledge_AD_TRHan extends CC_TriggerHandlerBase{
    
    public override void mainEntry(CC_TriggerParameters tp) {
		process((List<CBK_MCC_Knowledge__c>)tp.oldList);
	}
    
    @TestVisible
    private static void process(List<CBK_MCC_Knowledge__c> listOldObj) {
        quitarRelacionMCC(listOldObj);
	}
     
    public static void quitarRelacionMCC(List<CBK_MCC_Knowledge__c> listOldObj) {
        
        
        Set<Id> relacionesMCC = new Set<Id>();
        Set<Id> relacionesKnowledge = new Set<Id>();
        Map<Id,Id> mapRelacionMCCKnwldg =  new Map<Id,Id>(); //Variable para guardar las relaciones
        Map<Id, CBK_MCC_Knowledge__c> updateList = new Map<Id, CBK_MCC_Knowledge__c>(); //Variable para actualizar el objeto MCC_Knowledge con la nueva relación
        
        //Guardar las relaciones entre MCC y Knowledge
        for (CBK_MCC_Knowledge__c relacion : listOldObj) {
            CBK_MCC_Knowledge__c updateMCCKnowledge = new CBK_MCC_Knowledge__c();
            relacionesMCC.add(relacion.CBK_MCC__c);    
            relacionesKnowledge.add(relacion.CBK_Knowledge__c);
            mapRelacionMCCKnwldg.put(relacion.CBK_Knowledge__c, relacion.CBK_MCC__c);
            updateMCCKnowledge.Id = relacion.Id;
            updateMCCKnowledge.CBK_Knowledge__c = relacion.CBK_Knowledge__c;
            updateList.put(relacion.CBK_MCC__C, updateMCCKnowledge);
                  
        }
        //Obtener codigos externos de MCC y su clasificacion
        Map<Id, CC_MCC__c> mccs = new Map <Id, CC_MCC__c>([SELECT Id, RecordType.DeveloperName, CC_Codigo_Externo__c FROM CC_MCC__c WHERE Id IN :relacionesMCC]);
        Map<Id, Knowledge__kav> articulos = new Map <Id, Knowledge__kav>([SELECT Id, CBK_Codigo_Externo_Causa__c, CBK_Codigo_Externo_Motivo__c, CBK_Codigo_Externo_Producto__c, CBK_Codigo_Externo_Tematica__c  
                                                                        FROM Knowledge__kav WHERE Id IN :relacionesKnowledge]);
       
        //Obtener los registros Knowledge
        //Se obtiene el objetoKnowledgeArticleVersion que tendrá la versión del artículo y sobre el cual tenemos que trabajar
        Map <Id, KnowledgeArticleVersion> mapIdVersionKnowledge = new Map<Id, KnowledgeArticleVersion>([SELECT Id, KnowledgeArticleId FROM KnowledgeArticleVersion WHERE Id IN :relacionesKnowledge]);
        
        Map <Id, Id> mapRelacionesArticulos = new Map<Id, Id>();
        //Mapa con la relación: ID Artículo con su ID de la versión, el KnowledgeArticleId
        for (Id i : mapIdVersionKnowledge.keySet()){
            mapRelacionesArticulos.put(mapIdVersionKnowledge.get(i).KnowledgeArticleId, i);
        }
        List<KnowledgeArticleVersion> listIdVersionKnowledge = new List<KnowledgeArticleVersion>(mapIdVersionKnowledge.values());
        
        //Mapa con la relación del id del KnowledgeArticle con el MCC que está relacionado
        Map<Id, Id> mccKnowledgeArticle = new Map<Id, Id>();
        for (KnowledgeArticleVersion i : listIdVersionKnowledge){

            mccKnowledgeArticle.put(i.KnowledgeArticleId, mapRelacionMCCKnwldg.get(i.Id));

        }
        
        //Despublicar los artículos para poder modificarlos
        Map<Id,Id> mapDespublicado = new Map<Id, Id>();        
        for (Id i : mapIdVersionKnowledge.keySet()){
            
            String recordId = mapIdVersionKnowledge.get(i).KnowledgeArticleId;
            mapDespublicado = unPublishArticle(recordId);
                              
        }
        //Obtener las nuevas versiones que se han creado al despublicarlos
        Map<Id, KnowledgeArticleVersion> obtenidoIdQuery = new Map<Id, KnowledgeArticleVersion>([SELECT Id, KnowledgeArticleId 
                                                                                                FROM KnowledgeArticleVersion 
                                                                                                WHERE IsLatestVersion =  true AND Id IN :mapDespublicado.keySet()]);

        List<KnowledgeArticleVersion> obtenidos = new List<KnowledgeArticleVersion> (obtenidoIdQuery.values());
        List<Id> ids = new List<Id>();
        for (KnowledgeArticleVersion i : obtenidos){
            ids.add(i.KnowledgeArticleId);
        }
        //Obtener el articulo nuevo que se ha creado y que será el que se modificará
        List<Knowledge__kav> newArticle = new List<Knowledge__kav>([SELECT Id, CBK_Codigo_Externo_Causa__c, CBK_Codigo_Externo_Motivo__c, CBK_Codigo_Externo_Producto__c, CBK_Codigo_Externo_Tematica__c 
                                                                    FROM Knowledge__kav WHERE KnowledgeArticleId IN :ids]);

        Map<Id, Id> viejoNuevoArticulo = new Map<Id,Id>();

        //Obtener mcc relacionado y volverlo a publicar
        for (Knowledge__kav i : newArticle){
            viejoNuevoArticulo.put(mapRelacionesArticulos.get(mapDespublicado.get(i.Id)), i.Id);
            Id idMapDespublicado = mapDespublicado.get(i.Id);
            Id idMccRelacionado = mccKnowledgeArticle.get(idMapDespublicado);
            CC_MCC__c mccRelacionado = mccs.get(idMccRelacionado);
            updateArticle(mccRelacionado, i, idMapDespublicado);
        }

        //Actualizar todos los mcc_Knowledge a los que estaba linkado para que todos tengan la última version
        CC_MCC_Knowledge_AI_TRHan.actualizarMccs(viejoNuevoArticulo);

     }
    
    //Despublica el artículo
    public static Map <Id, Id> unPublishArticle(String recordId){
        Map<Id,Id> despublicadoIdVersion = new Map<Id,Id>();
        String newArticleId = KbManagement.PublishingService.editOnlineArticle(recordId, true);
        despublicadoIdVersion.put(newArticleId, recordId);
        return despublicadoIdVersion;
     }

    //Borra el código externo del artículo y lo vuelve a publicar
    public static String updateArticle(CC_MCC__c mcc, Knowledge__kav newArticle, String recordId){

        if (mcc.RecordType.DeveloperName == 'CC_Tematica'){
            newArticle.CBK_Codigo_Externo_Tematica__c = newArticle.CBK_Codigo_Externo_Tematica__c.remove(mcc.CC_Codigo_Externo__c +' -' );
       }else if (mcc.RecordType.DeveloperName == 'CC_Poducto_Servicio'){
            newArticle.CBK_Codigo_Externo_Producto__c = newArticle.CBK_Codigo_Externo_Producto__c.remove(mcc.CC_Codigo_Externo__c +' -' );
       }else if (mcc.RecordType.DeveloperName == 'CC_Motivo'){
            newArticle.CBK_Codigo_Externo_Motivo__c = newArticle.CBK_Codigo_Externo_Motivo__c.remove(mcc.CC_Codigo_Externo__c +' -' );
       }else if (mcc.RecordType.DeveloperName == 'CC_Causa'){
            newArticle.CBK_Codigo_Externo_Causa__c = newArticle.CBK_Codigo_Externo_Causa__c.remove(mcc.CC_Codigo_Externo__c +' -' );
       }   
        update newArticle;
        publishArticle(recordId);
        return recordId;

     }

    public static void publishArticle(String recordId){
        KbManagement.PublishingService.publishArticle(recordId, true);
    }
   
}