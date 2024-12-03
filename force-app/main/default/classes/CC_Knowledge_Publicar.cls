public with sharing class CC_Knowledge_Publicar {
	@AuraEnabled
    public static Boolean publicarArticulo(Id recordId){
        KnowledgeArticleVersion articulo =[SELECT Id, KnowledgeArticleId, PublishStatus, ValidationStatus FROM KnowledgeArticleVersion WHERE Id =:recordId];
        Boolean publicar = false;
        if (articulo.PublishStatus == 'Draft' && articulo.ValidationStatus == 'Validated'){
            KbManagement.PublishingService.publishArticle(articulo.KnowledgeArticleId, true);
            Set<Id> idVersionArticulos = new Set<Id>();
            idVersionArticulos.add(articulo.Id);
            CC_MCC_Knowledge_Actualizar.obtenerMCCKnowledge(idVersionArticulos);
            publicar = true;
        }
        else{
            publicar = false;
        }
        return publicar;
    }

    @InvocableMethod
    public static void actualizarEstadoPublicacion(List<EstadoKnowledge> input) {
         Map<Id, KnowledgeArticleVersion> articulos = obtenerArticulos(input);
         List<Knowledge__kav> actualizarEstadoArticulos = new List<Knowledge__kav>();
         Boolean publicarODespublicar;
        
        // Recorrer los articulos a enviar correo
        for (EstadoKnowledge estadoArticulos : input) {  
            publicarODespublicar = estadoArticulos?.estadoArticulo == 'publicar' ? true : false;

             if(publicarODespublicar && articulos.get(estadoArticulos?.idArticulo)?.PublishStatus == 'Draft'){
                KbManagement.PublishingService.publishArticle(articulos.get(estadoArticulos?.idArticulo)?.KnowledgeArticleId, true); 
            }
            if(estadoArticulos.estadoArticulo == 'despublicar' && (articulos.get(estadoArticulos.idArticulo).PublishStatus == 'Online' || articulos.get(estadoArticulos.idArticulo).PublishStatus == 'Publicado')){
                KbManagement.PublishingService.archiveOnlineArticle(articulos.get(estadoArticulos.idArticulo).KnowledgeArticleId, null);
            }
            
        }
    }
    
    public static Map<Id, KnowledgeArticleVersion> obtenerArticulos(List<EstadoKnowledge> input) {
        List<Id> idArticulos = new List<Id>();
        for (EstadoKnowledge estadoArticulo : input) {
            idArticulos.add(estadoArticulo.idArticulo);
        }
        return new Map<Id, KnowledgeArticleVersion>(
            [SELECT Id, KnowledgeArticleId, PublishStatus
             FROM KnowledgeArticleVersion WHERE Id IN :idArticulos]
        );
    }
    
    public class EstadoKnowledge {      
        @InvocableVariable(required=true)
        public Id idArticulo;
        
        @InvocableVariable(required=true)
        public String estadoArticulo;
    }
}